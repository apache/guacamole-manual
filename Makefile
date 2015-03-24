
FILES=$(shell find -name "*.xml")

all: html/index.html
	
clean:
	$(RM) docbook-xsl
	$(RM) -R html/

docbook-xsl:
	test -e "$(DOCBOOK_PATH)" && ln -s "$(DOCBOOK_PATH)" docbook-xsl

html/index.html: $(FILES) src/site.xslt docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

