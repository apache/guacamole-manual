
#
# Build entire manual
#

all: html/index.html
	
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

# All XML files which the build depends on
FILES=$(shell find -name "*.xml")

html/index.html: $(FILES) src/site.xslt docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

