install-exec-hook : %D%/funcmod.sh
	$(mkdir_p) $(DESTDIR)$(libdir)
	$(INSTALL_PROGRAM) $(abs_top_srcdir)/%D%/funcmod.sh $(DESTDIR)$(libdir)

uninstall-local:
	rm -f $(DESTDIR)$(libdir)/funcmod.sh


# extra files to add to the distribution
EXTRA_DIST	+= %D%/funcmod.sh

#-------------------------------------------------------------------
# Snippets go after here, unless their docs say otherwise

# this must be an explicit list of man pages; no make variables allowed.
# currently, only section l man pages are supported.

POD_SFX = .pod
dist_manl_MANS = %D%/$(PACKAGE).l
PODS = %D%/$(PACKAGE)
POD_HTML = %D%/$(PACKAGE).html
POD_PDF  = %D%/$(PACKAGE).pdf

include %D%/pod_all.mk
include %D%/pod_readme.mk
include %D%/pod_readme_md.mk
