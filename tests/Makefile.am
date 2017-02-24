include %D%/bats.mk

# so we can find funcmods.sh
AM_TESTS_ENVIRONMENT += PATH=$(abs_top_srcdir)/src:${PATH};

TESTS			+= %D%/funcmod.bats

EXTRA_DIST              +=			\
			$(TESTS)		\
			%D%/bats

