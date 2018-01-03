#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/amd64.sh
. "${CONFDIR}/arch/amd64.sh"

export OBJDIR=/var/tmp/jenkins/freebsd/obj

export DESTHOST=amd64
export CAPDDESTHOST=Amd64
export KERNCONF=GENERIC
