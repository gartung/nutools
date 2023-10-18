########################################################################
# bootstrapModules.cmake
#
#   Support functions and macros for building distributions.
#
####################################
# Functions.
#
# * create_version_variables(<var-stem> [NAME <name>] [LIST] <version>...
#                            [QUALIFIERS <qualifier-list>)
#
#   Set variables X_NAME, X_VERSION and X_DOT_VERSION, where X is
#   <var-stem> converted to upper case. In most cases X_NAME will be
#   <var-stem>, but occasionally something else is appropriate and the
#   optional NAME should be used to specify something else (e.g. the UPS
#   product name or the bundle configuration filename stem). If either
#   LIST or more than one <version> is specified, the version variables
#   will have _LIST appended to their names. If QUALIFIERS is specified,
#   then X_QUAL will be set to <qualifier-list>, with \`:\' as the
#   delimiter.
#
# * create_product_variables(<product> <version>)
# * create_product_variable_list(<var-stem>
#                               [<product-version> [<product-version>]]
#                               [QUALIFIERS <qualifier-list>])
#
#   Deprecated functions retained for backward compatibility; their use
#   will elicit a warning.
#
# * create_pyqual_variables()
#
#   Create PYQUAL or PY2QUAL and PY3QUAL as appropriate, depending on
#   the required level of support for Python 2 and/or Python 3.
#
# * init_shell_fragment_vars()
#
#   Create CMake variables useful for expansion in bundle configuration
#   files via CMake's @VAR@ notation.
#
#   Variables defined:
#
#   * INIT_PYQUAL_VARS
#
#     This shell fragment will define pyver, pyqual and pylabel as
#     appropriate based on the required level of support for Python 2
#     and/or Python 3.
#
#   * BUILD_COMPILERS
#
#     This shell fragment will ensure the correct compilers are built
#     and available for the qualifier in use for the current
#     distribution.
#
#   N.B. init_shell_fragment_vars() should be called after all calls to
#   create_*() functions, but before any calls to process bundle
#   configuration files via (e.g.) distribution() or html().
#
# * distribution(<var-stem> [WITH_HTML])
#
#   Generate the bundle configuration ${X_NAME}-${X_DOT_VERSION}-cfg
#   from ${X_NAME}-cfg.in, where X is <var-stem> converted to upper
#   case. If WITH_HTML is specified, also generate the HTML file for
#   ${X_NAME}-${X_VERSION}.html from ${X_NAME}.html.in. This function
#   also generates the variable DIST_BUILD_SPEC and makes it
#   available during the file generation phase for substitution CMake's
#   @VAR@ notation.
#
########################################################################
cmake_policy(PUSH)
cmake_minimum_required(VERSION 2.8...3.27 FATAL_ERROR)

include(CMakeParseArguments)

set(SCISOFT_BUNDLE_URL https://scisoft.fnal.gov/scisoft/bundles CACHE STRING
  "Base URL for SciSoft bundles")
set(SPACK_ENV_BUNDLE_INCLUDE_LOCATION "SCISOFT" CACHE STRING
  "Whence to obtain included bundle YAML files")
set_property(CACHE SPACK_ENV_BUNDLE_INCLUDE_LOCATION PROPERTY STRINGS
  LOCAL
  SCISOFT
)

function(create_version_variables VAR_STEM)
  _verify_before_init_shell_fragment_vars(
    "create_version_variables(${ARGV})")
  cmake_parse_arguments(CVV "LIST" "NAME;SPACK_VERSION" "QUALIFIERS" ${ARGN})
  if (NOT VAR_STEM)
    message(FATAL_ERROR "vacuous VAR_STEM")
  elseif (NOT CVV_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "No versions specified")
  endif()
  string(TOUPPER ${VAR_STEM} VAR_STEM_UC)
  list(LENGTH CVV_UNPARSED_ARGUMENTS num_versions)
  if (CVV_LIST OR num_versions GREATER 1)
    set(list_suffix _LIST)
  else()
    set(list_suffix)
  endif()
  set(dot_versions)
  foreach(VERSION ${CVV_UNPARSED_ARGUMENTS})
    string(REPLACE "_" "." VDOT "${VERSION}")
    string(REGEX REPLACE "^v" "" VDOT "${VDOT}")
    list(APPEND dot_versions ${VDOT})
  endforeach()
  string(REGEX REPLACE "([0-9]+)[a-z]+(;|$)" "\\1\\2"
    spack_versions "${dot_versions}")
  string(REPLACE ";" " " versions "${CVV_UNPARSED_ARGUMENTS}")
  string(REPLACE ";" " " dot_versions "${dot_versions}")
  set(${VAR_STEM_UC}_VERSION${list_suffix} "${versions}" PARENT_SCOPE)
  set(${VAR_STEM_UC}_DOT_VERSION${list_suffix} "${dot_versions}" PARENT_SCOPE)
  if (list_suffix)
    set(${VAR_STEM_UC}_VERSION ${VERSION} PARENT_SCOPE)
    set(${VAR_STEM_UC}_DOT_VERSION ${VDOT} PARENT_SCOPE)
  endif()
  if (NOT CVV_SPACK_VERSION)
    string(REGEX REPLACE "([0-9]+)_?[a-z][0-9]?$" "\\1" CVV_SPACK_VERSION ${VDOT})
  endif()
  set(${VAR_STEM_UC}_SPACK_VERSION ${CVV_SPACK_VERSION} PARENT_SCOPE)
  if (NOT CVV_NAME)
    set(CVV_NAME "${VAR_STEM}")
  endif()
  set(${VAR_STEM_UC}_NAME "${CVV_NAME}" PARENT_SCOPE)
  if (CVV_QUALIFIERS)
    set(${VAR_STEM_UC}_QUAL "${CVV_QUALIFIERS}" PARENT_SCOPE)
  endif()
endfunction()

function(create_product_variables PRODUCT VERSION)
  message(WARNING "create_product_variables() is obsolete: "
    "use create_version_variables() instead")
  _verify_before_init_shell_fragment_vars(
    "create_product_variables(${ARGV})")
  create_version_variables(${PRODUCT} ${VERSION})
  string(TOUPPER ${PRODUCT} PRODUCT_UC)
  set(${PRODUCT_UC}_VERSION ${${PRODUCT_UC}_VERSION} PARENT_SCOPE)
  set(${PRODUCT_UC}_DOT_VERSION ${${PRODUCT_UC}_DOT_VERSION}
    PARENT_SCOPE)
endfunction()

function(create_product_variable_list PRODUCT VERSION)
  message(WARNING "create_product_variable_list() is obsolete: "
    "use create_version_variables() instead")
  _verify_before_init_shell_fragment_vars(
    "create_product_variable_list(${ARGV})")
  create_version_variables(${PRODUCT} ${VERSION} ${ARGN})
  string(TOUPPER ${PRODUCT} PRODUCT_UC)
  set(${PRODUCT_UC}_VERSION_LIST ${${PRODUCT_UC}_VERSION_LIST}
    PARENT_SCOPE)
  if (${PRODUCT_UC}_QUAL)
    set(${PRODUCT_UC}_QUAL ${${PRODUCT_UC}_QUAL} PARENT_SCOPE)
  endif()
endfunction()

macro(create_pyqual_variables)
  _verify_before_init_shell_fragment_vars("create_pyqual_variables()")
  if (PYTHON_VERSION)
    if (3.0.0 VERSION_GREATER PYTHON_DOT_VERSION AND PYTHON3_VERSION)
      _create_pyqual(${PYTHON_VERSION} PY2QUAL)
      _create_pyqual(${PYTHON3_VERSION} PY3QUAL)
    else()
      _create_pyqual(${PYTHON_VERSION} PYQUAL)
    endif()
  endif()
endmacro()

function(init_shell_fragment_vars)
  set(public_vars
    DEFINE_REQUIRE_BUILDFW_VERSION
    INIT_PYQUAL_VARS
    BUILD_COMPILERS
  )
  _init_shell_fragment_support_vars()
  set(DEFINE_REQUIRE_BUILDFW_VERSION
    "require_buildfw_version() {
  if version_greater \\
\$1 v\$(print_version | sed -e 's&^.*[ \\t]\\{1,\\}&&' -e 's&\\.&_&g' ); then
    echo \"Need buildFW \$1 or better.\" 1>&2
    return 1
  fi
}
")
  # INIT_PYQUAL_VARS supports two cases:
  #
  # 1. where we support both Python 2 and Python 3 via a 'py2' build
  #    label on the distribution, or
  #
  # 2. we have only one Python available.
  set(INIT_PYQUAL_VARS
    "########################################################################
# Set Python-related shell variables appropriately.
")
  if (PY3QUAL OR NOT 3.0.0 VERSION_GREATER PYTHON_DOT_VERSION)
    set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}
${_CHECK_OS_PYTHON3_SUPPORT}
")
  endif()
  set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}if [[ \${build_label} =~ (^|[-:])py2([-:]|\$) ]]; then")
  if (PY2QUAL AND PY3QUAL)
    set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}
  pyver=${PYTHON_VERSION}
  pyqual=${PY2QUAL}
  pylabel=:py2
else
  pyver=${PYTHON3_VERSION}
  pyqual=${PY3QUAL}
  unset pylabel
fi
")
  else()
    set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}
  echo \"Unsupported build label for this distribution.\" 1>&2
  return 1
fi

pyver=${PYTHON_VERSION}
pyqual=${PYQUAL}
unset pylabel
")
  endif()
  if (PY3QUAL OR NOT 3.0.0 VERSION_GREATER PYTHON_DOT_VERSION)
    set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}
if [[ \"\${pyqual}\" == p3* ]]; then
  check_os_python3_support
fi
")
  endif()
  set(INIT_PYQUAL_VARS "${INIT_PYQUAL_VARS}########################################################################
")

  set(BUILD_COMPILERS
    "${DEFINE_REQUIRE_BUILDFW_VERSION}
require_buildfw_version 5.03.00 || return

${_BUILD_COMPILERS_DETAIL}
")

  foreach (var ${public_vars})
    set(${var} "${${var}}" PARENT_SCOPE)
  endforeach()
endfunction()

function(distribution VAR_STEM)
  _verify_after_init_shell_fragment_vars("distribution(${ARGV})")
  cmake_parse_arguments(D "WITH_HTML" "" "" ${ARGN})
  string(TOUPPER ${VAR_STEM} VAR_STEM_UC)
  set(cfg_stem "${${VAR_STEM_UC}_NAME}-cfg")
  set(cfg_version "${${VAR_STEM_UC}_DOT_VERSION}")
  if (NOT cfg_version OR NOT ${VAR_STEM_UC}_NAME)
    message(FATAL_ERROR
      "distribution(${ARGV}) requires ${VAR_STEM_UC}_NAME and "
      "${VAR_STEM_UC}_DOT_VERSION to be set")
  endif()
  # Set DIST_BUILD_SPEC for possible expansion in .in files.
  set(DIST_BUILD_SPEC "${${VAR_STEM_UC}_NAME}-${cfg_version}")
  # Configure distribution -cfg file.
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${cfg_stem}.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${cfg_stem}-${cfg_version}" @ONLY)
  if (D_WITH_HTML) # Optional: configure HTML.
    set(html_stem "${${VAR_STEM_UC}_NAME}")
    set(html_version "${${VAR_STEM_UC}_VERSION}")
    if (NOT html_version)
      message(FATAL_ERROR
        "distribution(${ARGV}) requires ${VAR_STEM_UC}_VERSION to be set")
    endif()
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${html_stem}.html.in"
      "${CMAKE_CURRENT_BINARY_DIR}/${html_stem}-${html_version}.html"
      @ONLY)
  endif()
endfunction()

function(set_cmake_build_type build_type BUNDLE_CMAKE_BUILD_TYPE_VAR)
  set(result)
  if (build_type STREQUAL "prof")
    set(result RelWithDebInfo)
  elseif (build_type STREQUAL "debug")
    set(result Debug)
  elseif (build_type STREQUAL "opt")
    set(result Release)
  else()
    set(result "${build_type}")
  endif()
  set(${BUNDLE_CMAKE_BUILD_TYPE_VAR} "${result}" PARENT_SCOPE)
endfunction()

function(set_spack_native_compiler NATIVE_COMPILER_VAR_STEM)
  set(result)
  if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
    set(result gcc)
  elseif (CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set(result clang)
  elseif (CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    set(result apple_clang)
  else()
    message(FATAL_ERROR "unrecognized native compiler \"${CMAKE_C_COMPILER_ID}\"")
  endif()
  _set_spack_compiler_vars("${result}@${CMAKE_C_COMPILER_VERSION}" ${NATIVE_COMPILER_VAR_STEM})
endfunction()

function(set_spack_compiler_vars SPEC OUT_STEM)
  _set_spack_compiler_vars(${ARGV})
endfunction()

macro(_set_spack_compiler_vars SPEC OUT_STEM)
  if ("${SPEC}" MATCHES "^(clang|apple_clang|gcc)@(.*)$")
    set(SSCV_NAME "${CMAKE_MATCH_1}")
    set(SSCV_VERSION "${CMAKE_MATCH_2}")
    set("${OUT_STEM}_NAME" "${SSCV_NAME}" PARENT_SCOPE)
    if ("${ARGV2}")
      set(SSCV_CXX_STANDARD ${ARGV2})
      set(SSCV_CXX_STANDARD_OPT "- 'cxxstd=${SSCV_CXX_STANDARD}'")
    else()
      set(SSCV_CXX_STANDARD)
    endif()
    if ("${SSCV_NAME}" MATCHES "clang$")
      set(SSCV_PKG llvm)
      if ("${SSCV_NAME}" STREQUAL "clang")
        set(SSCV_CXXFLAGS "- 'cxxflags=-stdlib=libc++'")
      endif()
    else()
      set(SSCV_PKG ${SSCV_NAME})
      set(SSCV_CXXFLAGS)
    endif()
    set(${OUT_STEM}_PKG ${SSCV_PKG} PARENT_SCOPE)
    set(${OUT_STEM}_VERSION "${SSCV_VERSION}" PARENT_SCOPE)
    set(${OUT_STEM}_CXX_STANDARD "${SSCV_CXX_STANDARD}" PARENT_SCOPE)
    set(${OUT_STEM}_CXX_STANDARD_OPT "${SSCV_CXX_STANDARD_OPT}" PARENT_SCOPE)
    set(${OUT_STEM}_CXXFLAGS "${SSCV_CXXFLAGS}" PARENT_SCOPE)
    set(${OUT_STEM}_BUILD_SPEC "${SSCV_PKG}@${SSCV_VERSION}" PARENT_SCOPE)
    set(${OUT_STEM}_SPEC "${SSCV_NAME}@${SSCV_VERSION}" PARENT_SCOPE)
  elseif (NOT "${SPEC}" OR "${SPEC}" STREQUAL "@")
    foreach(SSCV_VAR_SUFFIX PKG VERSION CXX_STANDARD CXX_STANDARD_OPT CXXFLAGS BUILD_SPEC SPEC)
      set(${OUT_STEM}_${SSCV_VAR_SUFFIX} PARENT_SCOPE)
    endforeach()
  else()
    message(FATAL_ERROR "unrecognized compiler ${SPEC}")
  endif()
endmacro()

function(set_spack_main_compiler COMPILER_LABEL MAIN_COMPILER_VAR_STEM SECONDARY_COMPILER_VAR_STEM)
  set(MAIN_COMPILER_NAME)
  set(MAIN_COMPILER_VERSION)
  set(SECONDARY_COMPILER_NAME)
  set(SECONDARY_COMPILER_VERSION)
  set(cxxstd)
  set_spack_native_compiler(NC)
  if (COMPILER_LABEL STREQUAL "native")
    set(MAIN_COMPILER_NAME ${NC_NAME})
    set(MAIN_COMPILER_VERSION ${NC_VERSION})
    set(SECONDARY_COMPILER_NAME ${NC_NAME})
    set(SECONDARY_COMPILER_VERSION ${NC_VERSION})
  elseif (COMPILER_LABEL MATCHES "^([a-z])([0-9]+)$")
    # Traditional UPS "cqual" label.
    if ("${CMAKE_MATCH_1}" STREQUAL "c")
      set(MAIN_COMPILER_NAME clang)
      set(SECONDARY_COMPILER_NAME gcc)
      if ("${CMAKE_MATCH_2}" EQUAL 14)
        set(MAIN_COMPILER_VERSION "14.0.6")
        set(SECONDARY_COMPILER_VERSION "12.2.0")
      elseif ("${CMAKE_MATCH_2}" EQUAL 15)
        set(MAIN_COMPILER_VERSION "15.0.7")
        set(SECONDARY_COMPILER_VERSION "12.2.0")
      elseif ("${CMAKE_MATCH_2}" EQUAL 16)
        set(MAIN_COMPILER_VERSION "16.0.4")
        set(SECONDARY_COMPILER_VERSION "13.1.0")
        set(cxxstd 20)
      else()
        message(FATAL_ERROR "unsupported compiler label \"${COMPILER_LABEL}\"")
      endif()
    elseif ("${CMAKE_MATCH_1}" STREQUAL "e")
      set(MAIN_COMPILER_NAME gcc)
      set(SECONDARY_COMPILER_NAME)
      set(SECONDARY_COMPILER_VERSION)
      if ("${CMAKE_MATCH_2}" EQUAL 19)
        set(MAIN_COMPILER_VERSION "8.2.0")
      elseif ("${CMAKE_MATCH_2}" EQUAL 20)
        set(MAIN_COMPILER_VERSION "9.3.0")
      elseif ("${CMAKE_MATCH_2}" EQUAL 26)
        set(MAIN_COMPILER_VERSION "12.2.0")
      elseif ("${CMAKE_MATCH_2}" EQUAL 27)
        set(MAIN_COMPILER_VERSION "12.2.0")
        set(cxxstd 20)
      elseif ("${CMAKE_MATCH_2}" EQUAL 28)
        set(MAIN_COMPILER_VERSION "13.1.0")
        set(cxxstd 20)
      else()
        message(FATAL_ERROR "unsupported compiler label \"${COMPILER_LABEL}\"")
      endif()
    else()
      message(FATAL_ERROR "unrecognized compiler label \"${COMPILER_LABEL}\"")
    endif()
  elseif (COMPILER_LABEL MATCHES "^([^@]+)@([^%_]+)(%([^@]+)@([^_]+))?(_cxx([0-9a-f]+))?$")
    # Spack compiler spec.
    set(MAIN_COMPILER_NAME ${CMAKE_MATCH_1})
    if (MAIN_COMPILER_NAME STREQUAL "llvm")
      set(MAIN_COMPILER_NAME "clang")
    endif()
    set(MAIN_COMPILER_VERSION ${CMAKE_MATCH_2})
    if (NOT "${CMAKE_MATCH_3}" STREQUAL "")
      set(SECONDARY_COMPILER_NAME ${CMAKE_MATCH_4})
      set(SECONDARY_COMPILER_VERSION ${CMAKE_MATCH_5})
    endif()
    if (NOT "${CMAKE_MATCH_7}" STREQUAL "")
      set(cxxstd ${CMAKE_MATCH_7})
    endif()
  else()
    message(FATAL_ERROR "unrecognized compiler label \"${COMPILER_LABEL}\"")
  endif()
  if (NC_NAME STREQUAL SECONDARY_COMPILER_NAME
      AND SECONDARY_COMPILER_VERSION VERSION_LESS NC_VERSION)
    set(SECONDARY_COMPILER_VERSION ${NC_VERSION})
  endif()
  if (NOT cxxstd)
    set(cxxstd 17)
  endif()
  foreach (comp MAIN SECONDARY)
    _set_spack_compiler_vars(${${comp}_COMPILER_NAME}@${${comp}_COMPILER_VERSION} ${${comp}_COMPILER_VAR_STEM} ${cxxstd})
  endforeach()
endfunction()

function(spack_environment ENV)
  cmake_parse_arguments(SE "" "DOT_VERSION;NAME;SUFFIX" "EXTRA_SPEC" ${ARGN})
  string(TOUPPER ${ENV} ENV_UC)
  if (NOT SE_NAME)
    set(SE_NAME "${${ENV_UC}_NAME}")
  endif()
  if (NOT SE_DOT_VERSION)
    set(SE_DOT_VERSION "${${ENV_UC}_SPACK_VERSION}")
  endif()
  set(env_stem "${SE_NAME}")
  set(env_dot_version "${SE_DOT_VERSION}")
  string(TOUPPER ${env_stem} env_stem_UC)
  if (NOT (env_stem AND env_dot_version))
    message(FATAL_ERROR
      "spack_environment(${ENV}) requires ${ENV_UC}_NAME and "
      "${ENV_UC}_DOT_VERSION to be set or provided as arguments (NAME, DOT_VERSION)")
  endif()
  # Set ENV_BUILD_SPEC for possible expansion in .in files.
  set(ENV_BUILD_SPEC "${env_stem}${SE_SUFFIX}@${env_dot_version}")
  if (SE_EXTRA_SPEC)
    string(REPLACE ";" "-" ENV_BUILD_SPEC "${ENV_BUILD_SPEC};${SE_EXTRA_SPEC}")
  endif()
  set(ENV_BUILD_SPEC_YAML "${ENV_BUILD_SPEC}.yaml")
  if (SPACK_ENV_BUNDLE_INCLUDE_LOCATION STREQUAL "SCISOFT")
    set(scisoft_version "v${env_dot_version}")
    string(REPLACE "_" "." scisoft_version "${scisoft_version}")
    set(${env_stem_UC}_BUNDLE_LOCATION "${SCISOFT_BUNDLE_URL}/${env_stem}/${scisoft_version}/${ENV_BUILD_SPEC_YAML}" PARENT_SCOPE)
  elseif (SPACK_ENV_BUNDLE_INCLUDE_LOCATION STREQUAL "LOCAL")
    set(${env_stem_UC}_BUNDLE_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/${ENV_BUILD_SPEC_YAML}" PARENT_SCOPE)
  else()
    set(${env_stem_UC}_BUNDLE_LOCATION PARENT_SCOPE)
  endif()
  set(EXTRA_ENV_CONFIG "  concretizer:
    unify: when_possible
    reuse: true"
    )
  # Configure spack environment file.
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${env_stem}${SE_SUFFIX}.yaml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${ENV_BUILD_SPEC_YAML}")
endfunction()

########################################################################
# Private utility functions and macros.
#########################################################################

function(_create_pyqual VERSION_IN VAR)
  string(REPLACE "_" "" pyqual "${VERSION_IN}")
  string(REGEX REPLACE "^v" "p" pyqual "${pyqual}")
  set(${VAR} ${pyqual} PARENT_SCOPE)
endfunction()

macro(_init_shell_fragment_support_vars)
  set(_CHECK_OS_PYTHON3_SUPPORT
    "# Verify OS support for Python 3.
check_os_python3_support() {
  local flvr5=\$(ups flavor -5)
  if [[ \${flvr5##*-} == sl*6 ]]; then
    if want_unsupported; then
      echo \"INFO: Building unsupported Python3 build on SLF6 due to \\
\\\$CET_BUILD_UNSUPPORTED=\${CET_BUILD_UNSUPPORTED}\" 1>&2
    else
      msg=\"INFO: Python3 builds not supported on SLF6 -- \\
export CET_BUILD_UNSUPPORTED=1 to override.\"
      echo \"\$msg\" 1>&2
      rm -f \"\${manifest}\"
      [[ -d \"\${working_dir}/copyBack\" ]] && \\
        echo \"\${msg}\" > \"\${working_dir}/copyBack/skipping_build\"
      exit 0
    fi
  fi
}
")

  set(_CHECK_BASE_DETAIL
    "if [ \"\${bundle_name}\" = \"build_base\" ]; then
  bf_build_base=1
fi
")

  set(DEFINE_BF_BUILD_CMAKE
    "########################################################################
# Define a support function to build required CMake packages.
bf_build_cmake() {
  local cv
  local versions=(\${CMAKE_VERSION:-\"\$@\"})
  for cv in \${versions[@]:-${CMAKE_VERSION_LIST}}; do
    do_pull -f -n cmake \"\${cv}\" || \\
      { local no_binary_download=1
        do_build cmake \"\${cv}\"; }
  done
}
########################################################################
")
  set(DEFINE_BF_BUILD_CMAKE "${DEFINE_BF_BUILD_CMAKE}" PARENT_SCOPE)

  set(BF_BUILD_CMAKE
    "${DEFINE_BF_BUILD_CMAKE}
bf_build_cmake \\
")
  set(BF_BUILD_CMAKE "${BF_BUILD_CMAKE}" PARENT_SCOPE)

  set(_BUILD_COMPILERS_DETAIL
    "${DEFINE_BF_BUILD_CMAKE}
########################################################################
# Define a function to build required compiler packages and their
# prerequisites.
bf_build_compilers() {
  # Attempt to pull required_items.
  (( bf_build_base )) || ! maybe_pull_gcc && \\
    { local no_binary_download=1
      maybe_build_gcc; }
  bf_build_cmake
  (( bf_build_base )) || ! maybe_pull_other_compilers && \\
    { local no_binary_download=1
      maybe_build_other_compilers ${SQLITE_VERSION} \\
      ${PYTHON_VERSION}; }
}
########################################################################

########################################################################
# Actually build the compiler packages and their prerequisites.
${_CHECK_BASE_DETAIL}
bf_build_compilers && \\
  unset bf_build_base bf_build_compilers bf_handle_cmake
########################################################################
")
endmacro()

function(_verify_before_init_shell_fragment_vars PREAMBLE)
  if (INIT_PYQUAL_VARS)
    message(FATAL_ERROR "${PREAMBLE}: init_shell_fragment_vars() "
      "called too early")
  endif()
endfunction()

function(_verify_after_init_shell_fragment_vars PREAMBLE)
  if (NOT INIT_PYQUAL_VARS)
    message(FATAL_ERROR "${PREAMBLE}: init_shell_fragment_vars() "
      "called too late")
  endif()
endfunction()

cmake_policy(POP)
