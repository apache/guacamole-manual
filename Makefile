#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

.PHONY: all clean book html

#
# Build entire manual
#

all: html book

#
# Clean build artifacts
#

clean:
	$(RM) docbook-xsl
	$(RM) -R html/ book/
	$(RM) *.pdf *.fo

#
# Link Docbook XSL into build, if available
#

docbook-xsl:
	test -e "$(DOCBOOK_PATH)" && ln -s "$(DOCBOOK_PATH)" docbook-xsl

# All files which the build depends on
XML_FILES=$(shell find -path "./src/*" -name "*.xml")
PNG_FILES=$(shell find -path "./src/*" -name "*.png")

#
# HTML manual build
#

html: html/index.html html/gug.css html/images
	
html/index.html: $(XML_FILES) src/site.xslt docbook-xsl
	cd src; xsltproc -o ../html/ --xinclude site.xslt gug.xml

html/gug.css: src/gug.css
	mkdir -p html; cp src/gug.css html/

html/images: $(PNG_FILES)
	mkdir -p html/images; cp -fv $(PNG_FILES) html/images/

#
# PDF manual build
#

book: book/gug.pdf
	
book/gug.fo: $(XML_FILES) src/book.xslt docbook-xsl
	cd src; xsltproc -o ../book/gug.fo --xinclude book.xslt gug.xml

book/gug.pdf: book/gug.fo
	cd src; fop -c fop-conf.xml -fo ../book/gug.fo -pdf ../book/gug.pdf

