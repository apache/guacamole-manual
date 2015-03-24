
FILES=$(shell find -name "*.xml")

.PHONY: all clean link-docbook-xsl

all: html/index.html
	
clean:
	$(RM) docbook-xsl
	$(RM) -R html/

link-docbook-xsl:
	$(RM) docbook-xsl
	ln -s $(DOCBOOK_PATH) docbook-xsl

html/index.html: $(FILES) src/site.xslt link-docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

