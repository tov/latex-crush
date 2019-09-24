PKG		= crush

LATEX		= latex
LUALATEX	= lualatex
MAKEINDEX	= makeindex

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
### Packaging
###

$(PKG).zip: $(PKG)/
	zip -r $@ $^

$(PKG).tar.gz: $(PKG)/
	tar zcf $@ $^

$(PKG)/:
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

CLEAN = $(PKG).ind $(PKG).idx \
	$(PKG).gls $(PKG).glo $(PKG).aux $(PKG).log \
	$(PKG).out $(PKG).dvi $(PKG).ilg $(PKG).hd \
	$(PKG).toc

VCLEAN = $(CLEAN) $(PKG).pdf $(PKG).sty

clean:
	$(RM) $(CLEAN)

vclean:
	$(RM) $(VCLEAN)
