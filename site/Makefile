
all: index.html

clean:
	$(RM) *.html

%.html: %.xml guac-www.xslt
	xsltproc guac-www.xslt $*.xml > $*.html

