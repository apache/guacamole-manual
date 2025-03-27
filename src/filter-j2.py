#!/usr/bin/env python3
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

from jinja2 import Environment, BaseLoader
from pathlib import Path
import re

# The current stack of tabs, as dictated by prior calls to beginTab() and
# endTab(). If we are in a tab, the current tab is the last element of this
# list. If we are not in any tabs, this list is empty.
tabStack = []

def beginTab(tabName):
    """
    Notifies that we are entering the context of a tab having the given name.
    There is no requirement for tab naming except that names must be
    consistent.

    :param tabName:
        The name of the tab.

    :return string:
        Always an empty string.
    """
    global tabStack
    tabStack.append(tabName)
    return ''

def isTab(tabName):
    """
    Returns whether we are currently within a tab having the given name, as
    dictated by prior calls to beginTab() and endTab().

    :param tabName:
        The name of the tab to test.

    :return bool:
        True if we are currently within the tab having the given name, False
        otherwise.
    """
    global tabStack
    return tabStack[-1] == tabName

def endTab(tabName):
    """
    Notifies that we are leaving the context of a tab having the given name.
    There is no requirement for tab naming except that names must be
    consistent.

    :param tabName:
        The name of the tab.

    :return string:
        Always an empty string.
    """
    global tabStack
    assert tabName == tabStack.pop()
    return ''

def environmentName(value):
    """
    Transforms the given Guacamole property to its corresponding environment
    variable name.

    :param value:
        The property name to filter.

    :return string:
        The name of the environment variable that corresponds to the given
        property.
    """
    return value.upper().replace('-', '_')

def defListEntry(value):
    """
    Creates a definition list entry (the description of a term) from the given
    Markdown content.

    :param value:
        The string to filter.

    :return string:
        A definition list entry containing all of the given Markdown content.
    """
    return ': ' + '\n  '.join(value.split('\n')) + '\n'

def dockerComposeStr(value):
    """
    Formats the given value as a string that can be used within the YAML
    provided to Docker Compose. Characters within the string will be escaped as
    necessary.

    :param value:
        The string to filter.

    :return string:
        A properly escaped YAML string containing the provied value.
    """
    return "'" + value.replace("'", "''") + "'"

def shellStr(value):
    """
    Formats the given value as a string that can be used within the arguments
    of a shell command.  Characters within the string will be escaped as
    necessary.

    :param value:
        The string to filter.

    :return string:
        A properly escaped shell string containing the provied value.
    """
    return '"' + re.sub(r'([\$`"\\])', r'\\\1', value) + '"'

def splitPropertyTemplate(value):
    """
    Splits the provided property template (guacamole.properties snippet
    containing documentation for each property in comments) into a list of each
    property, example value, and corresponding documentation. Whether the
    property was commented-out is also included.

    The list returned is a list of dictionaries corresponding to each property,
    where each dictionary contains the following entries:

    "name"
      The name of the property.

    "value"
      An example value for the property.

    "documentation"
      Documentation describing the usage of the property.

    "commented"
      Whether the property was commented-out within the template.

    :param value:
        The string to filter.

    :return string:
        A list of dictionaries describing each property.
    """

    result = []
    property_docs = ''

    for line in value.splitlines():

        # Gradually accumulate documentation from comments that precede a
        # property/value pair
        if match := re.match(r'^# (\s*\S.*)$', line):
            content = match.group(1)
            property_docs += content + '\n'
            new_paragraph = False

        # Comments that are empty or consist of nothing but whitespace indicate
        # a new paragraph
        elif match := re.match(r'^#\s*$', line):
            property_docs += '\n'

        # Once a property/value pair is finally encountered, store the
        # documentation accumulated so far and move on to the next property
        elif match := re.match(r'^(#)?(\S+):\s+(.*)', line):

            comment_char = match.group(1)
            property = match.group(2)
            property_value = match.group(3)

            result.append({
                'name' : property,
                'value' : property_value,
                'documentation' : property_docs.strip(),
                'commented' : bool(comment_char)
            })

            property_docs = ''

        else:
            property_docs = ''

    return result 

class WorkingDirectoryFileSystemLoader(BaseLoader):
    """
    Jinja2 template loader that simply reads any requested template directly
    from the filesystem, interpreting the template name as a path relative to
    the current working directory.
    """

    def get_source(self, environment, template):
        """
        Retrieves the source for a requested template. The definition of this
        function is dictated by the BaseLoader class.

        See: https://jinja.palletsprojects.com/en/stable/api/#jinja2.BaseLoader.get_source
        """

        # Determine original template modification time (required for
        # implementing the final part of the resulting tuple: a function that
        # returns whether the template is up-to-date)
        templatePath = Path(template)
        templateModTime = templatePath.stat().st_mtime

        return (
            templatePath.read_text(encoding='utf-8'),
            template,
            lambda: templateModTime >= templatePath.stat().st_mtime
        )

# Read conf.py such that we have access to myst_substitutions for later
# inclusion in the template context
exec(compile(open('conf.py', 'rb').read(), 'conf.py', 'exec'))

env = Environment(autoescape=False,
                  loader=WorkingDirectoryFileSystemLoader())

# Add custom filters to Jinja environment
env.filters.update({
    'environmentName' : environmentName,
    'defListEntry' : defListEntry,
    'dockerComposeStr' : dockerComposeStr,
    'shellStr' : shellStr,
    'splitPropertyTemplate' : splitPropertyTemplate
})

env.globals.update({
    'beginTab' : beginTab,
    'isTab' : isTab,
    'endTab' : endTab
})

input_file = sys.argv[1]
output_file = sys.argv[2]

# Filter provided document(s)
template = env.get_template(input_file)
Path(output_file).write_text(template.render(myst_substitutions),
                             encoding='utf-8')

