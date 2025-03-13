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

#
# generate-j2-data.py - Generates a JSON file containing all substitutions
# defined by myst_substitutions within "conf.py", printing the result to
# STDOUT. This data can be consumed by jinjanator/j2cli to provide context to
# templates and avoid the complexity of using MyST to perform the substitions
# later (which would require double-escaping Jinja expressions).
#

import json

# Pull in the contents of the Sphinx conf.py
exec(compile(open('conf.py', 'rb').read(), 'conf.py', 'exec'))

# Dump all MyST Parser substitutions as JSON for consumption by
# jinjanator/j2cli
print(json.dumps(myst_substitutions))
