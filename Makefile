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

.PHONY: all clean html

# Whether build should be verbose (default to non-verbose)
V?=0

# All files which the build depends on
J2_FILES=$(shell find "./src" -name "*.j2")
PROPERTIES_TEMPLATES=$(shell find "./src" -name "*.properties.in")
OTHER_FILES=$(shell find ./src/ -name "__pycache__" -prune -o -type f -not -name "*.j2" -not -name "*.properties.in" -print)

# Files that will ultimately be processed by Sphinx
SPHINX_INPUT += $(J2_FILES:./src/%.j2=build/in/%)
SPHINX_INPUT += $(PROPERTIES_TEMPLATES:./src/%.properties.in=build/in/%.properties.md)
SPHINX_INPUT += $(PROPERTIES_TEMPLATES:./src/%.properties.in=build/in/%.environment.md)
SPHINX_INPUT += $(PROPERTIES_TEMPLATES:./src/%.properties.in=build/in/%.example.properties)
SPHINX_INPUT += $(PROPERTIES_TEMPLATES:./src/%.properties.in=build/in/%.example.yml)
SPHINX_INPUT += $(PROPERTIES_TEMPLATES:./src/%.properties.in=build/in/%.example.txt)
SPHINX_INPUT += $(OTHER_FILES:./src/%=build/in/%)

#
# If not explicitly overridden by setting V=1, define a series of macros that
# hide the lengthy commands that are part of the build. These macros
# intentionally mimic the clean output that we get in the guacamole-server
# build via GNU Autotools and AM_SILENT_RULES().
#

ifeq ($(V), 0)
GEN=@echo     "  GEN    " $@;
CP=@echo      "  CP     " $@;
JINJA=@echo   "  JINJA  " $@;
SPHINX=@echo  "  SPHINX " $@;
SPHINX_FLAGS?=-q
endif

#
# The behavior between j2cli and jinjanator is slightly different, with
# jinjanator now outputting build information to STDERR unless --quiet is
# provided. Detect the available application and set the options appropriately
# (unless the J2 environment variable is overridden from the command line).
#

ifeq (, $(shell command -v jinjanate))
J2?=j2
else
J2?=jinjanate --quiet
endif

# Handy macro-like variable that automatically creates the parent directory for
# the output file of a target
ODIR=mkdir -p `dirname $@` &&

#
# Build entire manual
#

all: html

#
# Clean build artifacts
#

clean:
	$(RM) -R build/

#
# Automatic generation of property documentation/examples
#

build/in/%.properties.md: src/%.properties.in
	$(GEN) $(ODIR) ./generate-conf-docs.pl --mode=property-docs $< > $@

build/in/%.environment.md: src/%.properties.in
	$(GEN) $(ODIR) ./generate-conf-docs.pl --mode=environment-docs $< > $@

build/in/%.example.properties: src/%.properties.in
	$(GEN) $(ODIR) ./generate-conf-docs.pl --mode=property-example $< > $@

build/in/%.example.yml: src/%.properties.in
	$(GEN) $(ODIR) ./generate-conf-docs.pl --mode=docker-compose-example $< > $@

build/in/%.example.txt: src/%.properties.in
	$(GEN) $(ODIR) ./generate-conf-docs.pl --mode=docker-command-example $< > $@

#
# Copy any source files that don't require additional processing to build input
#

build/in/%: src/%
	$(CP) $(ODIR) cp $< $@

#
# Automatic filtering of documentation using Jinja2
#

build/in/myst_substitutions.json: src/conf.py
	$(GEN) $(ODIR) ./src/generate-j2-data.py > $@

# NOTE: The complex usage of dirname, basename, and PWD here is necessary to
# ensure filenames included/imported within Jinja templates are interpreted
# relative to the location of the template, rather than relative to the
# location of the entire build
build/in/%: src/%.j2 build/in/myst_substitutions.json
	$(JINJA) $(ODIR) cd `dirname $<` && $(J2) -o $(PWD)/$@ `basename $<` $(PWD)/build/in/myst_substitutions.json

#
# HTML manual build
#

html: build/html/index.html

build/html/index.html: $(SPHINX_INPUT)
	$(SPHINX) sphinx-build $(SPHINX_FLAGS) -b html -d build/doctrees build/in/ build/html

