PKG		= crush

LATEX		= latex
LUALATEX	= lualatex
MAKEINDEX	= makeindex
GITHUB		= https://github.com/tov/latex-$(PKG)

all: $(PKG).sty $(PKG).pdf

$(PKG).pdf: $(PKG).sty $(PKG).ind $(PKG).gls

###
### General LaTeX rules
###

%.sty: %.ins %.dtx
	$(RM) $@
	$(LATEX) $<

%.pdf: %.dtx
	$(LATEX) $<
	$(LUALATEX) $<

%.idx %.glo: %.dtx %.sty
	$(LATEX) $<

%.ind: %.idx
	$(MAKEINDEX) -s gind.ist $<

%.gls: %.glo
	$(MAKEINDEX) -s gglo.ist -o $@ $<

###
### GitHub Pages
###


upload-doc: doc/ $(PKG)/ $(PKG).zip $(PKG).tar.gz
	TMPDIR=`mktemp -d -t $(PKG)-gh-pages` &&                   \
	trap "rm -Rf $$TMPDIR" EXIT &&                             \
	cp -R $^ $$TMPDIR &&                                       \
	$(MAKE) -C $$TMPDIR publish-from-here

publish-from-here:
	rm -Rf .git .gitignore
	git init
	git add -v .
	git commit -m 'Publishing documentation.'
	git push -f $(GITHUB) master:gh-pages

###
### Packaging
###

$(PKG).zip: $(PKG)/
	zip -r $@ $^

$(PKG).tar.gz: $(PKG)/
	tar zcf $@ $^

$(PKG)/: $(shell git ls-files)
	git status
	rm -Rf $@
	git clone file://`pwd` $@
	make -C $@ dist

dist:
	make vclean
	make all
	make clean

###
### Cleaning
###

CLEAN = $(PKG)/ \
	$(PKG).ind $(PKG).idx $(PKG).gls $(PKG).glo \
	$(PKG).aux $(PKG).log $(PKG).out $(PKG).dvi \
	$(PKG).ilg $(PKG).hd $(PKG).toc $(PKG).zip \
	$(PKG).tar.gz

VCLEAN = $(CLEAN) $(PKG).pdf $(PKG).sty

clean:
	$(RM) $(CLEAN)

vclean:
	$(RM) $(VCLEAN)
