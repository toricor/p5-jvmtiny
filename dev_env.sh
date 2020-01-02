#!/bin/bash
set -e

#export PATH="$PATH"
export PERL5LIB="local/lib/perl5:lib"

exec "$@"