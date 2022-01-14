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

#
# Build entire manual
#

all: html

#
# Clean build artifacts
#

clean:
	$(RM) -R build/

# All files which the build depends on
MD_FILES=$(shell find "./src" -name "*.md")
RST_FILES=$(shell find "./src" -name "*.rst")
PNG_FILES=$(shell find "./src" -name "*.png")

#
# HTML manual build
#

html: build/html/index.html

build/html/index.html: $(PNG_FILES) $(RST_FILES) $(MD_FILES)
	sphinx-build -b html -d build/doctrees src/ build/html

