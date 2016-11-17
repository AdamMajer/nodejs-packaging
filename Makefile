#!/usr/bin/make --warn-undefined-variables

ALL_TARGETS := 4.target 6.target 7.target
NODEJS_PROJECT ?= devel:languages:nodejs
COMMON_CHANGELOG := common.changes.tmp

all: status

status: final.target ${COMMON_CHANGELOG}
	(cd ${NODEJS_PROJECT}; osc status)

commit:
	(cd ${NODEJS_PROJECT}; osc commit)

clean:
	rm -f ${ALL_TARGETS} final.target ${COMMON_CHANGELOG}

distclean: clean
	rm -rf ${NODEJS_PROJECT}

${COMMON_CHANGELOG}: common.changes
	cp common.changes ${COMMON_CHANGELOG}
	rm -f common.changes
	touch common.changes

final.target: ${ALL_TARGETS}
	touch final.target

${ALL_TARGETS}: ${COMMON_CHANGELOG}
	# Fetch target project and overwrite it with current stuff
	test -x ${NODEJS_PROJECT}/nodejs${@:.target=} || osc co ${NODEJS_PROJECT} nodejs${@:.target=}
	cp common/* ${NODEJS_PROJECT}/nodejs${@:.target=}/
	cp ${@:.target=}/* ${NODEJS_PROJECT}/nodejs${@:.target=}/
	
	# Parse spec file
	sed -f nodejs${@:.target=}.sed nodejs.spec.in > ${NODEJS_PROJECT}/nodejs${@:.target=}/nodejs${@:.target=}.spec
	
	# Prepend common changelog, if any
	if [ $$(stat -c %s ${COMMON_CHANGELOG}) -gt 0 ]; then \
		echo "Updating NodeJS${@:.target=} changes..."; \
		cat ${COMMON_CHANGELOG} ${NODEJS_PROJECT}/nodejs${@:.target=}/nodejs${@:.target=}.changes > nodejs.changes; \
		mv nodejs.changes ${NODEJS_PROJECT}/nodejs${@:.target=}/nodejs${@:.target=}.changes; \
	fi

	# Verify that patches actually apply
	cd ${NODEJS_PROJECT}/nodejs${@:.target=} && \
	quilt setup --fast nodejs${@:.target=}.spec && \
	cd node-v${@:.target=}.*.? && \
	quilt push -a --fuzz=0

	touch $@
