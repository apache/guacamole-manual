#!/usr/bin/perl
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
# generate-conf-docs.pl - Parses example guacamole.properties snippets to
# produce documentation for both the properties used in the snippet and their
# corresponding Docker environment variables. Example guacamole.properties
# excerpts and docker-compose.yml excerpts are also produced.
#
# USAGE: ./generate-conf-docs.pl --mode=MODE [FILES...]
#
# Parses each of the given files, writing all output to STDOUT. The provided
# MODE dictates the format of that output. Valid modes are:
#
# "property-docs" - Generate a Markdown definition list (MyST format) that
#   lists each property, where the property name is the term and the content of
#   all comments above that property are the definition. Markdown formatting
#   within the comment will be preserved. If a property is commented out, that
#   property will still be included in the documentation.
#
# "property-example" - Generate an example guacamole.properties snippet that
#   lists each individual property, including the value provided for that
#   property in the input file. Documentation from comments related to the
#   property are omitted from the output. If a property is commented out, that
#   property will still be included in the output snippet in commented-out
#   form.
#
# "environment-docs" - Generate a Markdown definition list (MyST format) that
#   lists each property, where the property's corresponding environment
#   variable name is the term and the content of all comments above that
#   property are the definition. Markdown formatting within the comment will be
#   preserved. If a property is commented out, the environment variable for
#   that property will still be included in the documentation.
#
# "docker-compose-example" - Generate an example docker-compose.yml snippet
#   that lists the environment variables that correspond to each individual
#   property, including the value provided for that property in the input file.
#   Documentation from comments related to the property are omitted from the
#   output. If a property is commented out, the environment variable
#   corresponding to that property will still be included in the output snippet
#   in commented-out form.
#
# "docker-command-example" - Generate an example "docker run" command that
#   shows "-e" options for each of the environment variables that correspond to
#   each individual property, including the value provided for that property in
#   the input file.  Documentation from comments related to the property are
#   omitted from the output. If a property is commented out, the environment
#   variable corresponding to that property will be omitted from the output
#   snippet.
#

use strict;
use warnings;

use Getopt::Long;

#
# Mapping of output modes to functions that print using the format that output
# mode requires. Each function accepts up to 4 arguments, in order:
#
# 1. The name of the property.
# 2. The Markdown-formatted documentation associated with that property
#    (extracted from comments above the property).
# 3. The value assigned to that property in the input file.
# 4. An arbitrary value that is truthy if the line containing the property as
#    commented out (falsy otherwise).
#
my %output_handlers = (

    'property-docs' => sub {
        print "`$_[0]`\n$_[1]\n";
    },

    'property-example' => sub {
        !$_[3] or print "#";
        print "$_[0]: $_[2]\n";
    },

    'environment-docs' => sub {
        $_[0] =~ tr/a-z-/A-Z_/;
        print "`$_[0]`\n$_[1]\n";
    },

    'docker-compose-example' => sub {
        !$_[3] or print "#";
        $_[0] =~ tr/a-z-/A-Z_/;
        $_[2] =~ s/'/''/g;
        print "$_[0]: '$_[2]'\n";
    },

    'docker-command-example' => sub {
        $_[0] =~ tr/a-z-/A-Z_/;
        $_[2] =~ s/[\$`"\\]/\\&/g;
        print "    -e $_[0]=\"$_[2]\" \\\n";
    }

);

#
# Mapping of output modes to the strings that should be printed at the
# beginning of all output, if any.
#
my %headers = (
    'docker-command-example' => "\$ docker run --name some-guacamole \\\n"
);

#
# Mapping of output modes to the strings that should be printed at the
# end of all output, if any.
#
my %footers = (
    'docker-command-example' => "    -d -p 8080:8080 guacamole/guacamole\n"
);

# Default to outputting property documentation
my $output_mode = "property-docs";

# Parse all options (currently there is only one: --mode)
GetOptions( 'mode=s' => \$output_mode ) or die;

# Verify the provided mode is valid, selecting the appropriate output function
# for the chosen mode
my $print_docs = $output_handlers{$output_mode} or die "Invalid output mode: $output_mode\n";

my $new_paragraph = 0;
my $property_docs = "";

print $headers{$output_mode} if defined $headers{$output_mode};
while (<>) {

    # Gradually accumulate documentation from comments that precede a
    # property/value pair
    if ((my $content) = m/^# (\S.*)$/) {

        if ($property_docs ne "") {
            if ($new_paragraph) {
                $property_docs .= "\n";
            }
            $property_docs .= " ";
        }
        else {
            $property_docs .= ":";
        }

        $property_docs .= " $content\n";
        $new_paragraph = 0;

    }

    # Comments that are empty or consist of nothing but whitespace indicate a
    # new paragraph
    elsif (m/^#\s*$/) {
        $new_paragraph = 1;
    }

    # Once a property/value pair is finally encountered, output the
    # documentation accumulated so far using the selected output function
    elsif ((my $comment_char, my $property, my $property_value) = m/^(#)?(\S+):\s+(.*)/) {
        &$print_docs($property, $property_docs, $property_value, defined($comment_char));
        $property_docs = "";
    }

}
print $footers{$output_mode} if defined $footers{$output_mode};

