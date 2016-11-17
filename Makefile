
ALL_TARGETS = $(shell ls -d ?)
TARGET_STAMPS := $(addsuffix .target,${ALL_TARGETS})
NODEJS_PROJECT ?= devel:languages:nodejs
COMMON_CHANGELOG := common.changes.tmp

all: status

status: ${TARGET_STAMPS} ${COMMON_CHANGELOG}
	(cd ${NODEJS_PROJECT}; osc status)

commit:
	(cd ${NODEJS_PROJECT}; osc commit)

clean:
	rm -f ${TARGET_STAMPS} ${COMMON_CHANGELOG}

distclean: clean
	rm -rf ${NODEJS_PROJECT}

${COMMON_CHANGELOG}: common.changes
	cp common.changes ${COMMON_CHANGELOG}
	rm -f common.changes
	touch common.changes

${TARGET_STAMPS}:
	$(MAKE) ${@:.target=}

${ALL_TARGETS}: ${COMMON_CHANGELOG}
	# Fetch target project and overwrite it with current stuff
	test -x ${NODEJS_PROJECT}/nodejs$@ || osc co ${NODEJS_PROJECT} nodejs$@
	cp common/* ${NODEJS_PROJECT}/nodejs$@/
	cp $@/* ${NODEJS_PROJECT}/nodejs$@/
	
	# Parse spec file
	sed -f nodejs$@.sed nodejs.spec.in > ${NODEJS_PROJECT}/nodejs$@/nodejs$@.spec
	
	# Prepend common changelog, if any
	if [ $$(stat -c %s ${COMMON_CHANGELOG}) -gt 0 ]; then \
		echo "Updating NodeJS$@ changes..."; \
		cat ${COMMON_CHANGELOG} ${NODEJS_PROJECT}/nodejs$@/nodejs$@.changes > nodejs.changes; \
		mv nodejs.changes ${NODEJS_PROJECT}/nodejs$@/nodejs$@.changes; \
	fi

	# Verify that patches actually apply
	cd ${NODEJS_PROJECT}/nodejs$@ && \
	quilt setup --fast nodejs$@.spec && \
	cd node-v$@.*.? && \
	quilt push -a --fuzz=0

	touch $@.target

