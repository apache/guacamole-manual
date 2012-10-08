
FILES=$(shell find -name "*.xml")

all: html/index.html gug.pdf
	
clean:
	$(RM) -R html/
	$(RM) *.pdf *.fo

html/index.html: $(FILES) site.xslt
	xsltproc -o html/ --xinclude site.xslt gug.xml

gug.fo: $(FILES) 
	xsltproc -o gug.fo --xinclude /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl gug.xml

gug.pdf: gug.fo
	fop -fo gug.fo -pdf gug.pdf

