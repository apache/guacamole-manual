
FILES=$(shell find -name "*.xml")

.PHONY: all clean link-docbook-xsl

all: html/index.html gug.pdf
	
clean:
	$(RM) docbook-xsl
	$(RM) -R html/
	$(RM) *.pdf *.fo

link-docbook-xsl:
	$(RM) docbook-xsl
	ln -s $(DOCBOOK_PATH) docbook-xsl

html/index.html: $(FILES) site.xslt link-docbook-xsl
	xsltproc -o html/ --xinclude site.xslt gug.xml

gug.fo: $(FILES) book.xslt link-docbook-xsl
	xsltproc -o gug.fo --xinclude book.xslt gug.xml

gug.pdf: gug.fo
	fop -c fop-conf.xml -fo gug.fo -pdf gug.pdf

