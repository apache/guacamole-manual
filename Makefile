
#
# Build entire manual
#

all: html/index.html html/gug.css html/images
	
#
# Clean build artifacts
#

clean:
	$(RM) docbook-xsl
	$(RM) -R html/

#
# Link Docbook XSL into build, if available
#

docbook-xsl:
	test -e "$(DOCBOOK_PATH)" && ln -s "$(DOCBOOK_PATH)" docbook-xsl

#
# HTML manual build
#

# All files which the build depends on
XML_FILES=$(shell find -path "./src/*" -name "*.xml")
PNG_FILES=$(shell find -path "./src/*" -name "*.png")

html/index.html: $(XML_FILES) src/site.xslt docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

html/gug.css: src/gug.css
	cp src/gug.css html/

html/images: $(PNG_FILES)
	mkdir -p html/images; cp -fv $(PNG_FILES) html/images/

