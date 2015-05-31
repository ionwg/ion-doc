#!/bin/bash

set -e # exit with nonzero exit code if anything fails
set -x
set -v

#asciidoctor_installed=$(gem list -i asciidoctor)
#pygments_installed=$(gem list -i pygments)

#if [ ! $asciidoctor_installed ]; then
#    printf '%s\n' "Installing asciidoctor"
#    gem install asciidoctor
#    printf '%s\n' "Installed asciidoctor"
#fi

#if [ ! $pygments_installed ]; then
#    printf '%s\n' "Installing pygments"
#    gem install pygments.rb
#    printf '%s\n' "Installed pygments"
#fi

printf '%s\n' "Running asciidoctor"
asciidoctor --safe -D build draft-ion.adoc
printf '%s\n' "Ran asciidoctor"

set +v
set +x

#rake foo