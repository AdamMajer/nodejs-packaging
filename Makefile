
ALL_TARGETS = $(shell ls -d ?)
TARGET_STAMPS := $(addsuffix .target,${ALL_TARGETS}) changelog.target common.target
NODEJS_PROJECT ?= devel:languages:nodejs
CHANGELOG_TS := $(shell date)

TARGET_CHANGELOGS := $(wildcard ?/*.changes)

all: status

status: ${TARGET_STAMPS} changelog.target
	(cd ${NODEJS_PROJECT}; osc status)

commit:
	(cd ${NODEJS_PROJECT}; osc commit)

clean:
	rm -f ${TARGET_STAMPS}

distclean: clean
	rm -rf ${NODEJS_PROJECT}

${TARGET_STAMPS}:
	$(MAKE) ${@:.target=}

common.target: nodejs-common/*
	# Checkout nodejs-common, and simply copy the files over
	test -x ${NODEJS_PROJECT}/nodejs-common || osc co ${NODEJS_PROJECT} nodejs-common
	cp nodejs-common/* ${NODEJS_PROJECT}/nodejs-common
	touch common.target

changelog.target: common.changes
        # Prepend common changelog to the changelog files
	if [ $$(stat -c %s common.changes) -gt 0 ]; then \
		for changelog in ${TARGET_CHANGELOGS}; do \
			echo "Updating $$changelog changes..."; \
			cat common.changes $$changelog > $$changelog.tmp; \
			mv $$changelog.tmp $$changelog; \
		done; \
	fi
	truncate --size=0 common.changes
	touch changelog.target

${ALL_TARGETS}: changelog.target common.target
	# Fetch target project and overwrite it with current stuff
	test -x ${NODEJS_PROJECT}/nodejs$@ || osc co ${NODEJS_PROJECT} nodejs$@
	cp common/* ${NODEJS_PROJECT}/nodejs$@/
	cp $@/* ${NODEJS_PROJECT}/nodejs$@/
	
	# Parse spec file
	sed -f nodejs$@.sed nodejs.spec.in | perl patch.pl $@ > ${NODEJS_PROJECT}/nodejs$@/nodejs$@.spec
	
	# Verify that patches actually apply
	cd ${NODEJS_PROJECT}/nodejs$@ && \
	quilt setup --fast nodejs$@.spec && \
	cd node-v$@.*.? && \
	quilt push -a --fuzz=0

	touch $@.target

