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

from docutils.nodes import Element
from docutils.parsers.rst import directives
from typing import List, Tuple

from sphinx import addnodes
from sphinx.addnodes import pending_xref
from sphinx.application import Sphinx
from sphinx.builders import Builder
from sphinx.directives import ObjectDescription
from sphinx.domains import Domain, ObjType
from sphinx.environment import BuildEnvironment
from sphinx.roles import XRefRole
from sphinx.util.docfields import TypedField
from sphinx.util.nodes import make_refnode

def phase(option_value):
    """
    Parses the given string, validating it against the set of valid Guacamole
    protocol session phase identifier strings ("handshake" or "interactive").

    :param option_value:
        The string to parse, as may be received from Sphinx as the value of a
        directive option.

    :return string:
        The provided, valid string.

    :raises ValueError:
        If the provided phase is invalid.
    """
    return directives.choice(option_value, ('handshake', 'interactive'))

def endpoint(option_value):
    """
    Parses the given string, validating it against the set of valid endpoint
    identifier strings ("client" or "server").

    :param option_value:
        The string to parse, as may be received from Sphinx as the value of a
        directive option.

    :return string:
        The provided, valid string.

    :raises ValueError:
        If the provided endpoint is invalid.
    """
    return directives.choice(option_value, ('client', 'server'))

def phase_set(option_value):
    """
    Parses the given string, converting it from a comma-separated list of
    values into a Python set of Guacamole protocol session phase identifier
    strings ("handshake" or "interactive").

    :param option_value:
        The string to parse, as may be received from Sphinx as the value of a
        directive option.

    :return set:
        A Python set containing all phase identifier strings within the
        provided comma-separated list.

    :raises ValueError:
        If any provided phase is invalid.
    """
    entries = directives.unchanged_required(option_value)
    return { phase(entry) for entry in entries.split(',') }

def endpoint_set(option_value):
    """
    Parses the given string, converting it from a comma-separated list of
    values into a Python set of endpoint identifier strings ("client" or
    "server").

    :param option_value:
        The string to parse, as may be received from Sphinx as the value of a
        directive option.

    :return set:
        A Python set containing all endpoint identifier strings within the
        provided comma-separated list.

    :raises ValueError:
        If any provided endpoint is invalid.
    """
    entries = directives.unchanged_required(option_value)
    return { endpoint(entry) for entry in entries.split(',') }

class GuacInstruction(ObjectDescription[Tuple[str, str]]):
    """
    Sphinx directive that represents a single Guacamole instruction. This
    directive allows the Guacamole manual to document Guacamole protocol
    instructions using minimal markup, just as the functions and structures of
    a library might be documented.
    """

    # Each of the attributes below are defined and inherited from the
    # superclass (ObjectDescription).

    domain = 'guac'

    doc_field_types = [
        TypedField('argument',
            label = "Arguments",
            names = ['arg'],
            can_collapse = True
        )
    ]

    option_spec = {
        'phase' : phase_set,
        'sent-by' : endpoint_set
    }

    def get_phases(self):
        """
        Returns the set of Guacamole protocol phases in which this instruction
        is valid, as declared by the "phase" directive option. An instruction
        may be valid in multiple phases. If no phase is declared, the
        "interactive" phase is assumed by default.

        :return set:
            The set of Guacamole protocol phases in which this instruction is
            valid.
        """
        return self.options.get('phase', { 'interactive' })

    def get_senders(self):
        """
        Returns the set of Guacamole protocol endpoints ("client" or "server")
        that may send this instruction, as declared by the "sent-by" directive
        option. An instruction may be sent by client, server, or both. If no
        endpoint is declared, the "server" endpoint is assumed by default.

        :return set:
            The set of Guacamole protocol endpoints that may send this
            instruction.
        """
        return self.options.get('sent-by', { 'server' })

    def handle_signature(self, sig, signode):

        # This function is inherited from the superclass (ObjectDescription).
        # The implementation is expected to override this function to define
        # the unique signature and name for the object being documented.

        signode.clear()
        signode += addnodes.desc_name(sig, sig)

        # Generate an internal, unique name for referring to this instruction
        # based on how the instruction is actually used (there may be multiple
        # definitions having the same instruction opcode yet different meanings
        # if sent by client vs. server or during the handshake vs. interactive
        # phases)
        unique_name = sig

        # Add "client-" prefix for all client-specific instructions
        if self.get_senders() == { 'client' }:
            unique_name = 'client-' + unique_name

        # Add "-handshake" suffix for all handshake-specific instructions
        if self.get_phases() == { 'handshake' }:
            unique_name += '-handshake'

        # NOTE: This value will be passed as the name to add_target_and_index()
        return unique_name

    def add_target_and_index(self, name, sig, sig_node):

        # This function is inherited from the superclass (ObjectDescription).
        # The implementation is expected to override this function to define a
        # unique ID for the object being documented, assigning that ID to the
        # "sig_node" (signature node). The "name" received here is expected to
        # be unique and will be the value returned by a corresponding call to
        # handle_signature().

        targetid = '%s-instruction' % (name)
        sig_node['ids'].append(targetid)
        self.state.document.note_explicit_target(sig_node)
        self.env.domaindata[self.domain]['instruction'][targetid] = self.env.docname, sig

class GuacDomain(Domain):
    """
    Sphinx domain specific to the Guacamole protocol, containing a single
    directive ("guac:instruction") that represents a single Guacamole
    instruction.
    """

    # Each of the attributes and functions below are defined and inherited from
    # the superclass (Domain).

    name = 'guac'
    label = 'Guacamole Protocol'

    initial_data = {

        # Mapping of instruction name to (docname, title) tuples, where docname
        # is the name of the document containing the object and title is opcode
        # of the instruction being documented
        'instruction' : {}

    }

    object_types = {
        'instruction' : ObjType('instruction')
    }

    directives = {
        'instruction' : GuacInstruction
    }

    roles = {
        'instruction' : XRefRole()
    }

    dangling_warnings = {
        'instruction' : "No documentation found for Guacamole instruction '%(target)s'"
    }

    def clear_doc(self, docname):

        # Clear all cached data associated with the given document
        instruction_list = self.data['instruction']
        for inst, doc in list(instruction_list.items()):
            if doc == docname:
                del instruction_list[inst]

    def resolve_xref(self, env, fromdocname, builder, typ, target, node, contnode):

        # Do not attempt to satisfy crossreferences for object types not
        # handled by this domain
        if typ not in self.data:
            return None

        # Do not attempt to satisfy crossreferences for unknown objects
        data = self.data[typ]
        if target not in data:
            return None

        # Retrieve target document and title from stored data
        (todocname, title) = data[target]

        return make_refnode(builder, fromdocname, todocname, target, contnode, title)

    def resolve_any_xref(self, env, fromdocname, builder, target, node, contnode):

        resolved = []

        # Search ALL types to enumerate all possible resolutions
        for typ in self.object_types:

            data = self.data[typ]

            # If the target exists within the set of known objects of the
            # current type, generate the required ('domain:role', node) tuple
            if target in data:
                (todocname, title) = data[target]
                resolved.append((
                    self.name + ':' + typ,
                    make_refnode(builder, fromdocname, todocname, target, contnode, title)
                ))

        return resolved

def setup(app: Sphinx):
    app.add_domain(GuacDomain)

