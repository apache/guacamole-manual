
FILES=$(shell find -name "*.xml")

all: html/index.html gug.pdf
	
clean:
	$(RM) -R html/
	$(RM) *.pdf *.fo

html/index.html: $(FILES) site.xslt
	xsltproc -o html/ --xinclude site.xslt gug.xml

gug.fo: $(FILES) book.xslt
	xsltproc -o gug.fo --xinclude book.xslt gug.xml

gug.pdf: gug.fo
	fop -fo gug.fo -pdf gug.pdf

