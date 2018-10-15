
MAIN_PRJ ?= devel:languages:nodejs
STAGING_PRJ ?= devel:languages:nodejs:staging


RELEASED_TARGETS = $(shell ls -d nodejs? nodejs??)
STAGING_TARGETS = $(shell ls -d staging-?? staging-?) staging-master
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
TARGET_CHANGELOGS := $(wildcard ?/*.changes ??/*.changes _git/*.changes staging-*/*.changes)

all: status

status: ${TARGET_STAMPS} changelog.target
	(cd $(MAIN_PRJ); osc status)
	(cd $(STAGING_PRJ); osc status)

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
	
	# Parse spec file
	sed -e 's,{{git_node}},$(GIT),' -f nodejs_$(if $(findstring staging,$@),git,releases).sed -f nodejs$(NODEJS_VERSION).sed nodejs.spec.in \
		| perl patch.pl $@ > $D/nodejs$(NODEJS_VERSION).spec
	
	# Parse _service file, if staging
	[ "$(findstring staging,$@)" != "staging" ] || \
		sed -e 's,{{pwd}},$(PWD),' -f nodejs$(NODEJS_VERSION).sed _service.in > $D/_service
	
	# Verify that patches actually apply in non-git version
	if [ "$(findstring staging,$@)" != "staging" ]; then \
		cd $D && quilt setup --fast *.spec && \
		cd `find -maxdepth 1 -mindepth 1 -type d -name node\*` && quilt push -a --fuzz=0; \
	fi
	touch $@.target

