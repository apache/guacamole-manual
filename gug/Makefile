
CHAPTERS   := chapters
APPENDICES := appendices
REFERENCES := references 

HEADER=`cat header.html`
FOOTER=`cat footer.html`

html: book
	
pdf: book.pdf

clean:
	$(RM) -R book/
	$(RM) *.pdf *.fo

book: book.xml $(wildcard $(CHAPTERS)/*.xml) $(wildcard $(APPENDICES)/*.xml) $(wildcard $(REFERENCES)/*.xml) site.xslt
	xsltproc -o book/ --xinclude site.xslt book.xml

book.fo: book.xml $(wildcard $(CHAPTERS)/*.xml) $(wildcard $(APPENDICES)/*.xml) $(wildcard $(REFERENCES)/*.xml)
	xsltproc -o book.fo --xinclude /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl book.xml

book.pdf: book.fo
	fop -fo book.fo -pdf book.pdf

