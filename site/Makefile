
all: index.html

clean:
	$(RM) *.html

index.html: index.xml
	xsltproc guac-www.xslt index.xml > index.html

