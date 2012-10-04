
CHAPTERS   := chapters
APPENDICES := appendices
REFERENCES := references 

all: html pdf
	
pdf: gug.pdf

clean:
	$(RM) -R html/
	$(RM) *.pdf *.fo

html: gug.xml $(wildcard $(CHAPTERS)/*.xml) $(wildcard $(APPENDICES)/*.xml) $(wildcard $(REFERENCES)/*.xml) site.xslt
	xsltproc -o html/ --xinclude site.xslt gug.xml

gug.fo: gug.xml $(wildcard $(CHAPTERS)/*.xml) $(wildcard $(APPENDICES)/*.xml) $(wildcard $(REFERENCES)/*.xml)
	xsltproc -o gug.fo --xinclude /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl gug.xml

gug.pdf: gug.fo
	fop -fo gug.fo -pdf gug.pdf

