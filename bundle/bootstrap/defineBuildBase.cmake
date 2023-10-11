macro(define_build_base)
  set(BUILD_BASE
    "# Require buildFW with correct do_pull behavior.
${DEFINE_REQUIRE_BUILDFW_VERSION}
require_buildfw_version 5.02.00 || return

# UPS.
check_ups ${UPS_VERSION}
# UPD.
build_noarch upd ${UPD_VERSION}
# Ninja (for modern Clang).
do_build ninja ${NINJA_VERSION}

${BUILD_COMPILERS}# GDB (not for Darwin).
if (( \${darwin:-0} == 0 )); then
  do_build gmp ${GMP_VERSION}
  do_build gdb ${GDB_VERSION}
fi
# Getopt (Darwin only).
(( \${darwin:-0} )) && { do_build getopt ${GETOPT_VERSION}; }
# Valgrind.
if (( \${darwin:-0} == 0 )) || ! [[ \$(uname -r | cut -d. -f 1) > 17 ]]; then
  do_build valgrind ${VALGRIND_VERSION}
fi
# Git (optional). build_git is set by buildFW.
(( \${build_git:-0} )) && do_build git ${GIT_VERSION}
# Gitflow.
do_build gitflow ${GITFLOW_VERSION}
####################################
# GH (Github CLI).

# Need to build Go, which may need an earlier version to be built
# first as a bootstrap.
for golang_version in ${GOLANG_BOOTSTRAP_VERSION_LIST} ${GOLANG_VERSION}; do
  do_build -m golang \${golang_version}
done
unset golang_version
# Now build GH
do_build gh ${GH_VERSION}
####################################
")
endmacro()
