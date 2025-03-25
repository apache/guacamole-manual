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

import re

def environmentName(str):
    """
    Transforms the given Guacamole property to its corresponding environment
    variable name.

    :param str:
        The property name to filter.

    :return string:
        The name of the environment variable that corresponds to the given
        property.
    """
    return str.upper().replace('-', '_')

def defListEntry(str):
    """
    Creates a definition list entry (the description of a term) from the given
    Markdown content.

    :param str:
        The string to filter.

    :return string:
        A definition list entry containing all of the given Markdown content.
    """
    return ': ' + '\n  '.join(str.split('\n')) + '\n'

def dockerComposeStr(str):
    """
    Formats the given value as a string that can be used within the YAML
    provided to Docker Compose. Characters within the string will be escaped as
    necessary.

    :param str:
        The string to filter.

    :return string:
        A properly escaped YAML string containing the provied value.
    """
    return "'" + str.replace("'", "''") + "'"

def shellStr(str):
    """
    Formats the given value as a string that can be used within the arguments
    of a shell command.  Characters within the string will be escaped as
    necessary.

    :param str:
        The string to filter.

    :return string:
        A properly escaped shell string containing the provied value.
    """
    return '"' + re.sub(r'([\$`"\\])', r'\\\1', str) + '"'

def splitPropertyTemplate(str):
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

    :param str:
        The string to filter.

    :return string:
        A list of dictionaries describing each property.
    """

    result = []
    property_docs = ''

    for line in str.splitlines():

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

