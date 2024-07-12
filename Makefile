SHELL=/bin/bash

# Project separator, so you can use different separator than :
PS := $(shell bash -c 'source osc_project_sep.sh && echo -n $$PS')
MAIN_PRJ ?= $(subst :,$(PS),devel:languages:nodejs)
STAGING_PRJ ?= $(subst :,$(PS),devel:languages:nodejs:staging)

RELEASED_TARGETS = $(shell ls -d nodejs? nodejs??)
STAGING_TARGETS = $(shell ls -d staging-??) staging-master
ALL_TARGETS = ${RELEASED_TARGETS} ${STAGING_TARGETS}

STAGING_TARGET_STAMPS := $(addsuffix .target,${STAGING_TARGETS})
RELEASED_TARGETS_STAMPS := $(addsuffix .target,${RELEASED_TARGETS})
TARGET_STAMPS := $(addsuffix .target,${ALL_TARGETS}) changelog.target common.target

COMMON_TARGETS := changelog.target common.target
RELEASE_TARGET_STAMPS := $(addsuffix .target,${RELEASE_TARGETS}) ${COMMON_TARGETS}
STAGING_TARGET_STAMPS := $(addsuffix .target,${STATING_TARGETS}) ${COMMON_TARGETS}

# staging and released versions are in different directories
define release_project
	$(if $(findstring staging,$(1)),$(STAGING_PRJ),$(MAIN_PRJ))
endef

# nodejs5 => 5
# staging-5 => 5
# staging-master => master
define nodejs_version
	$(if $(findstring master, $(1)), 42, \
		$(if $(findstring staging,$(1)), $(subst staging-,,$(1)), \
		$(if $(findstring nodejs,$(1)), $(subst nodejs,,$(1)))))
endef

CHANGELOG_TS := $(shell date)
TARGET_CHANGELOGS := $(wildcard nodejs??/*.changes)

all: status

status: ${TARGET_STAMPS} changelog.target
	(cd $(MAIN_PRJ); osc status)
	(cd $(STAGING_PRJ); osc status)

released-only: ${RELEASED_TARGETS_STAMPS} changelog.target
	(cd $(MAIN_PRJ); osc status)

clean:
	rm -f ${TARGET_STAMPS}

distclean: clean
	rm -rf $(MAIN_PRJ) $(STAGING_PRJ)

${TARGET_STAMPS}:
	$(MAKE) ${@:.target=}

common.target: nodejs-common/*
	# Checkout nodejs-common, and simply copy the files over
	$(eval PRJ=$(call release_project,$@))
	test -x $(PRJ)/nodejs-common || osc co $(PRJ) nodejs-common
	cp nodejs-common/* $(PRJ)/nodejs-common
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
	$(eval PRJ=$(call release_project,$@))
	$(eval GIT=$(if $(findstring staging,$@),1,0))
	$(eval NODEJS_VERSION=$(call nodejs_version,$@))
	$(eval D=$(PRJ)/nodejs$(NODEJS_VERSION))
	test -x $D || osc co $D
	cp common/* $D
	cp $@/* $D

	# Make sure we don't patch wrong version paths and values in paths and names
	# bsc#1159812 as an example
	cat $@/* |\
	grep -a '^+ .*\(node\|npm\|npx\)\([0-9]\+\)' |\
	sed -s 's,^.*\(node\|npm\|npx\)\([0-9]\+\).*$$,\2,' - |\
	grep -vc ${NODEJS_VERSION} |\
	grep -q '^0$$' || ( echo "Wrong node version found in patches $@" && false)

	if [ "$(findstring staging,$@)" == "staging" ]; then \
		sed -e 's,{{pwd}},$(PWD),' -f nodejs$(NODEJS_VERSION).sed _service.in > $D/_service && \
		cd $D && \
		find -maxdepth 1 -mindepth 1 -type d -name node-git\* -exec rm -rf {} \+ && \
		TAR_SCM_TESTMODE=1 osc service manualrun; \
	fi

	# (hack) make sure we unpack the sources
	./bundling.sh -N $(if $(findstring staging,$@),-g,) $(NODEJS_VERSION) > /dev/null

	# Parse spec file
	sed -e 's,{{git_node}},$(GIT),' \
		-f nodejs$(NODEJS_VERSION).sed \
		-f nodejs_$(if $(findstring staging,$@),git,releases).sed \
		-f <(./bundling.sh -M $(if $(findstring staging,$@),-g,) $(NODEJS_VERSION)) \
		-f <(./bundling.sh -N $(if $(findstring staging,$@),-g,) $(NODEJS_VERSION)) \
		-e 's,^Provides:\s\+bundled.*{{bundled.*version}}$$,,' \
		nodejs.spec.in \
		| perl patch.pl $@ > $D/nodejs$(NODEJS_VERSION).spec

	# Verify that patches actually apply
	cd $D && \
		( ! test -f _service || osc service manualrun set_version ) && \
		quilt setup --fast -v *.spec && \
		cd `find -maxdepth 1 -mindepth 1 -type d -name 'node-*' \! -name '*SPECPARTS'` && \
		quilt push -a --fuzz=0

	touch $@.target

