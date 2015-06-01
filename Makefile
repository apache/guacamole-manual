
.PHONY: all clean book html

#
# Build entire manual
#

all: html book

#
# Clean build artifacts
#

clean:
	$(RM) docbook-xsl
	$(RM) -R html/ book/
	$(RM) *.pdf *.fo

#
# Link Docbook XSL into build, if available
#

docbook-xsl:
	test -e "$(DOCBOOK_PATH)" && ln -s "$(DOCBOOK_PATH)" docbook-xsl

# All files which the build depends on
XML_FILES=$(shell find -path "./src/*" -name "*.xml")
PNG_FILES=$(shell find -path "./src/*" -name "*.png")

#
# HTML manual build
#

html: html/index.html html/gug.css html/images
	
html/index.html: $(XML_FILES) src/site.xslt docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

html/gug.css: src/gug.css
	mkdir -p html; cp src/gug.css html/

html/images: $(PNG_FILES)
	mkdir -p html/images; cp -fv $(PNG_FILES) html/images/

#
# PDF manual build
#

book: book/gug.pdf
	
book/gug.fo: $(XML_FILES) src/book.xslt docbook-xsl
	cd src; xsltproc -o ../book/gug.fo --xinclude book.xslt gug.xml

book/gug.pdf: book/gug.fo
	cd src; fop -c fop-conf.xml -fo ../book/gug.fo -pdf ../book/gug.pdf

