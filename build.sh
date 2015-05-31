#!/bin/bash

set -e # exit with nonzero exit code if anything fails

asciidoctor_installed=$(gem list -i asciidoctor)
pygments_installed=$(gem list -i pygments)

if [ ! $asciidoctor_installed ]; then
    gem install asciidoctor
fi

if [ ! $pygments_installed ]; then
    gem install pygments.rb
fi

asciidoctor --safe -D build draft-ion.adoc

#rake foo