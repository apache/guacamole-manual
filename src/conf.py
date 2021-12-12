# -*- coding: utf-8 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from datetime import date
import os, sys

#
# Project, version, and author information
#

project = u'Apache Guacamole'
version = u'1.4.0'

year = date.today().year
author = u'The Apache Software Foundation'
copyright = u'%s %s' % (year, author)

# Include "ext" directory in search path for custom Sphinx extensions
sys.path.insert(0, os.path.abspath('ext'))

#
# Global options
#

extensions = [
    'guac',
    'myst_parser',
    'sphinx.ext.ifconfig',
    'sphinx.ext.extlinks',
    'sphinx_inline_tabs'
]

# Allow shorthand notation for JIRA issue links
extlinks = {
    'jira': ( 'https://issues.apache.org/jira/browse/%s', '')
}

templates_path = [ '_templates' ]

# Do not parse files within include/ unless they are explicitly included with
# the "include" directive
exclude_patterns = [ 'include/**' ]

# Do not highlight source unless a Pygments lexer name is explicitly provided
highlight_language = 'none'

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "replacements",
    "smartquotes",
    "substitution"
]

myst_substitutions = {
    "version" : version
}

#
# HTML output options
#

html_theme = 'sphinx_rtd_theme'
html_title = u'Apache Guacamole Manual v%s' % version

html_static_path = [ '_static' ]
html_css_files = [ 'gug.css' ]

html_context = {
    'copyright_year' : year
}

