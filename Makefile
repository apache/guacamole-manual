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
OTHER_FILES=$(shell find ./src/ -name "__pycache__" -prune -o -type f -not -name "*.j2" -not -name "*.properties.in" -print)

# Files that will ultimately be processed by Sphinx
SPHINX_INPUT += $(J2_FILES:./src/%.j2=build/in/%)
SPHINX_INPUT += $(OTHER_FILES:./src/%=build/in/%)

#
# If not explicitly overridden by setting V=1, define a series of macros that
# hide the lengthy commands that are part of the build. These macros
# intentionally mimic the clean output that we get in the guacamole-server
# build via GNU Autotools and AM_SILENT_RULES().
#

ifeq ($(V), 0)
CP=@echo      "  CP     " $@;
JINJA=@echo   "  JINJA  " $@;
SPHINX=@echo  "  SPHINX " $@;
SPHINX_FLAGS?=-q
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
# Copy any source files that don't require additional processing to build input
#

build/in/%: src/%
	$(CP) $(ODIR) cp $< $@

#
# Automatic filtering of documentation using Jinja2
#

# NOTE: The complex usage of relative paths here is necessary to ensure
# filenames included/imported within Jinja templates are always consistently
# interpreted relative to the top-level document root, regardless of whether
# the template is evaluated within "src/" or "build/in/".
build/in/%: src/%.j2 src/conf.py
	$(JINJA) $(ODIR) cd src && ./filter-j2.py ../$< ../$@

#
# HTML manual build
#

html: build/html/index.html

build/html/index.html: $(SPHINX_INPUT)
	$(SPHINX) sphinx-build $(SPHINX_FLAGS) -b html -d build/doctrees build/in/ build/html

