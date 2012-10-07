
all: index.html

clean:
	$(RM) *.html

%.html: %.xml
	xsltproc guac-www.xslt $*.xml > $*.html

