########################################################################
# Adapted from build-framework to describe the nu and nulite
# distributions.
##################
# Build configuration files for SciSoft software distributions.
#
##################
# Creating canvas_product_stack manifests for non-numeric tags:
#
#   cmake -DCSVER=vX
#
# Conventionally-used values for X:
#
#   * develop
#
#       Compatible with current art development, including CI.
#
#   * art_v2_develop
#
#       Legacy art v2 maintenance.
#
#   * edge
#
#       Test stacks, not ready for CI.
#
##################
# Building the art suite from git:
#
#   * cmake -DASVER=v<branch-or-cp-tag> [-DCSVER=vX]
#
########################################################################

cmake_minimum_required(VERSION 2.8...3.27 FATAL_ERROR)

if (DEFINED ENV{CLANG_VERSION})
  message(FATAL_ERROR "UPS clang ($ENV{CLANG_VERSION}) must not be set up when generating distribution configurations")
elseif (DEFINED ENV{GCC_VERSION})
  message(FATAL_ERROR "UPS gcc ($ENV{GCC_VERSION}) must not be set up when generating distribution configurations")
endif()
project(nutools_bundles C)

# Define some necessary modules.
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap)
include(bootstrapModules)
include(defineBuildBase)


# tools and derivative variables.
set(BUNDLE_BUILD_TYPES debug opt prof)
set(BUNDLE_VERSION_SET s124 CACHE STRING "bundle version set")
if (ASVER STREQUAL "vdevelop" OR CSVER STREQUAL "vdevelop")
  set(BUNDLE_SUPPORTED_QUALS_INIT e28)
else()
  set(BUNDLE_SUPPORTED_QUALS_INIT e20 e26 e27 e28 c14 c15)
endif()

set(BUNDLE_SUPPORTED_QUALS ${BUNDLE_SUPPORTED_QUALS_INIT}
  CACHE STRING "bundle supported qualifiers")
string(REPLACE ";" "|" BUNDLE_SUPPORTED_QUALS_STRING "${BUNDLE_SUPPORTED_QUALS}")

# Define version set for desired version of art suite.
set(version_set "${BUNDLE_VERSION_SET}")
# for use in html
set( supported_quals_string "${BUNDLE_SUPPORTED_QUALS_STRING}")

# Legacy build-base.
create_version_variables(build_base_classic v6_3_0)

# Going forward.
create_version_variables(build_base v13_02_00)

# Package Management.
create_version_variables(cetpkgsupport v1_14_01)
create_version_variables(ups v6_1_1)
create_version_variables(upd v5_0_1)
create_version_variables(ninja v1_11_1)

# Handle Python version(s).
create_version_variables(python v3_9_13)
create_version_variables(python3 NAME python v3_9_13)
create_pyqual_variables()
create_version_variables(pycurl v7_45_2)

# CMake and cetmodules are special: define as many versions as necessary.
create_version_variables(cmake LIST
  v3_20_0 # Required until geant4 build script is updated to use newer ssibuildshims
  v3_22_2 # Required for TRACE v3_17_07
  v3_25_2
  v3_26_4
  v3_27_4
)
create_version_variables(cetbuildtools LIST v8_20_00)
# cetmodules v1_04_00 is required by TRACE >= v3_14_00.
create_version_variables(cetmodules1 v1_04_00)
# cetmodules, cetbuildtools, and mrb are special cases.
# include as many versions of them as necessary
create_version_variables(cetmodules LIST
  v3_16_00
  v3_21_00
  v3_21_01
  v3_21_02
  v3_22_01
  v3_22_02
  )
# create_version_variables(cetbuildtools LIST )
# mrb
create_version_variables(mrb_stack v6_09_05)
create_version_variables(mrb ${MRB_STACK_VERSION})
create_version_variables( hub v2_14_2 )

# art_suite
set(suite_rc_level)
set(stack_suffix c) # Reset when no longer needed
set(art_suffix c) # Reset when no longer needed
create_version_variables(canvas v3_15_02)
create_version_variables(canvas_stack ${CANVAS_VERSION}${stack_suffix})
create_version_variables(studio v1_02_00)
create_version_variables(canvas_root_io v1_12_03)
create_version_variables(art v3_13_02)
create_version_variables(art_suite NAME art ${ART_VERSION}${art_suffix})
create_version_variables(art_root_io v1_12_04)

# lite framework
create_version_variables(gallery v1_21_03)

# Tutorial
create_version_variables(toyExperiment v0_08_03)

create_version_variables(cry v1_7p)
create_version_variables(TRACE v3_17_09)
create_version_variables(artdaq_core v3_09_12)

create_version_variables(gmp v6_2_1)
create_version_variables(gdb v13_1)
create_version_variables(getopt v1_1_6) # for Darwin only.
create_version_variables(valgrind v3_21_0)
create_version_variables(git v2_40_1)
create_version_variables(gitflow v1_12_3)
create_version_variables(golang_bootstrap LIST v1_17 v1_19_5)
create_version_variables(golang v1_20)
create_version_variables(gh v2_25_1)

create_version_variables(igprof v5_9_16)

create_version_variables(iwyu v0_19)
create_version_variables(iwyu_dist NAME iwyu ${IWYU_VERSION})
create_version_variables(iwyu_clang v15_0_7)

create_version_variables(catch v3_3_2)
create_version_variables(range v3_0_12_0)
create_version_variables(guideline_sl v4_0_0)
create_version_variables(boost v1_82_0)
create_version_variables(fftw v3_3_10)
create_version_variables(sqlite v3_40_01_00)
create_version_variables(python v3_9_15)
create_version_variables(pybind11 v2_10_4)
create_version_variables(jemalloc v5_3_0d)
create_version_variables(cppunit v1_15_1f)
create_version_variables(clhep v2_4_6_4a)
create_version_variables(libxml2 v2_9_12)
create_version_variables(tbb v2021_9_0)
##################
create_version_variables(postgresql v15_3)
create_version_variables(pythia v6_4_28x)
create_version_variables(gsl v2_7)
##################
create_version_variables(openblas v0_3_23)
create_version_variables(numpy v1_24_3)
create_version_variables(scitokens_cpp v1_0_1a)
create_version_variables(xrootd v5_5_5a)
create_version_variables(root v6_28_06)

# jobsub-client prerequisites
create_version_variables(libxslt v1_1_34a)
create_version_variables(lxml v4_8_0)

# geant4
create_version_variables(geant4 v4_10_6_p01f SPACK_VERSION 10.6.1)
create_version_variables(xerces_c v3_2_3c)
create_version_variables(vecgeom v01_01_05c SPACK_VERSION 1.2.2:)
create_version_variables(qt v5_12_3a SPACK_VERSION 5.12.3:)
create_version_variables(expat v2_5_0 SPACK_VERSION 2.5.0:)
create_version_variables(g4abla v3_1)
create_version_variables(g4emlow v7_9_1)
create_version_variables(g4incl v1_0)
create_version_variables(g4neutron v4_6)
create_version_variables(g4nucleonxs v2_0)
create_version_variables(g4nuclide v2_2)
create_version_variables(g4particlexs v2_1)
create_version_variables(g4photon v5_5)
create_version_variables(g4pii v1_3)
create_version_variables(g4radiative v5_4)
create_version_variables(g4surface v2_1_1)
create_version_variables(g4tendl v1_3_2)
create_version_variables(geant4reweight v01_19_01)

# the latest releases of artg4tk are really part of larsoft
create_version_variables(artg4tk v07_00_01)
create_version_variables(larcoreobj v1_24_00)

# nu_extras
create_version_variables(cstxsd v4_0_0h)
create_version_variables(castxml v0_5_1)
create_version_variables(castxml_dist NAME castxml ${CASTXML_VERSION})
create_version_variables(castxml_clang v15_0_7)
create_version_variables(pygccxml v1_9_1)
#create_version_variables(pdfsets v5_9_1b)
create_version_variables(dk2nudata v01_08_00c)
create_version_variables(nusimdata v1_19_01)


set(suite_rc_level)

# art_suite
if (ASVER)
  if (ASVER MATCHES "^v(develop|art-v2-develop)")
    set(ASVER "${CMAKE_MATCH_1}")
  endif()
  if (CSVER)
    create_version_variables(canvas_stack NAME canvas_base ${CSVER})
  else()
    create_version_variables(canvas_stack NAME canvas_base v${ASVER})
  endif()
  foreach (pkg cetmodules cetlib_except hep_concurrency cetlib
      fhiclcpp messagefacility canvas art canvas_root_io art_root_io
      gallery critic)
    create_version_variables(${pkg} ${ASVER})
  endforeach()
  if (ASVER STREQUAL "develop")
    create_version_variables(critic_root_master NAME critic v${CRITIC_VERSION})
  endif()
else()
  create_version_variables(cetlib_except v1_09_01)
  create_version_variables(hep_concurrency v1_09_01)
  create_version_variables(cetlib v3_17_01)
  create_version_variables(fhiclcpp v4_18_01)
  create_version_variables(fhiclpy v4_03_02)
  create_version_variables(messagefacility v2_10_02)
  create_version_variables(canvas v3_15_02${suite_rc_level})
  set(stack_suffix) # Reset when no longer needed
  if (CSVER)
    create_version_variables(canvas_stack NAME canvas_base ${CSVER})
  else()
    create_version_variables(canvas_stack NAME canvas_base ${CANVAS_VERSION}${stack_suffix})
  endif()
  create_version_variables(canvas_root_io v1_12_03)
  create_version_variables(art v3_13_02${suite_rc_level})
  create_version_variables(art_root_io v1_12_04)
  create_version_variables(gallery v1_21_03${suite_rc_level})
  create_version_variables(critic v2_12_04${suite_rc_level})
endif()
create_version_variables(canvas_product_stack ${CANVAS_STACK_VERSION})

if (suite_rc_level OR ASVER)
  create_version_variables(art_suite NAME art ${ART_VERSION})
else()
  create_version_variables(art_suite NAME art ${ART_VERSION}${stack_suffix})
endif()

# mu - often the same as the art version
create_version_variables(mu_dist NAME mu ${ART_VERSION}${stack_suffix})
create_version_variables(mubase ${MU_DIST_VERSION})
create_version_variables(muse_dist NAME muse-ext ${ART_VERSION}${stack_suffix})

# nulite
create_version_variables(nutools v3_15_03)
create_version_variables(nulite ${NUTOOLS_VERSION})

# Tutorial
create_version_variables(toyExperiment v0_09_04)

create_version_variables(mpich v3_3_2)
create_version_variables(mvapich2 v2_3_3)
create_version_variables(caendigitizer v2_6_5)
create_version_variables(caencomm v1_2)
create_version_variables(caenvme v2_41)
create_version_variables(smc_compiler v7_1_0)
create_version_variables(pqxx v7_0_0)
create_version_variables(xmlrpc_c v1_51_06)
create_version_variables(artdaq v1_12_12)
create_version_variables(darksidecore v1_00_06)
create_version_variables(darkmon v1_00_08)
create_version_variables(ds50daq v1_04_04)
create_version_variables(lbne_raw_data v1_00_00)
create_version_variables(lbne_artdaq v0_08_00)

# ifdh
create_version_variables(libwda v2_30_0a)
create_version_variables(ifdhc v2_6_20)
create_version_variables(ifdhc_config v2_6_20)
create_version_variables(ifbeam v2_5_23)
create_version_variables(nucondb v2_5_23)
create_version_variables(ifdh_art v2_15_06)
# IFDH distribution.
create_version_variables(ifdh ${IFDH_ART_VERSION})

# larsoftobj - for use by hdf5_larsoftobj
create_version_variables(larsoftobj v1_06_01)

# hdf5_larsoftobj
create_version_variables(setuptools v22_0_5)
create_version_variables(hdf5 v1_12_2)
create_version_variables(mpi4py v3_1_3)
create_version_variables(h5py v3_6_0)
create_version_variables(hdf5_larsoftobj v3_00_00)
create_version_variables(pyyaml v6_0)
create_version_variables(scipy v1_8_0)
create_version_variables(python_tools v1_03_00)

# caffe - dropped
##create_version_variables(caffe v1_0l)
create_version_variables(leveldb v1_20c)
##create_version_variables(snappy v1_1_7c)
##create_version_variables(gflags v2_2_2)
##create_version_variables(glog v0_3_5b)
create_version_variables(protobuf v3_5_2a)
create_version_variables(lmdb v0_9_23)

########################################################################
# Sphinx et al.
create_version_variables(sphinx v7_2_6)
create_version_variables(sphinx_dist NAME sphinx ${SPHINX_VERSION})
create_version_variables(sphinx_python NAME python LIST
	v3_9_15
)
create_version_variables(sphinx_sqlite NAME sqlite LIST
  v3_40_01_00
)

# nu_extras
create_version_variables(genie v3_04_00d)
create_version_variables(genie_phyopt v3_04_00)
create_version_variables(genie_xsec v3_04_00)
create_version_variables(lhapdf v6_5_3)
create_version_variables(log4cpp v1_1_3d)
create_version_variables(dk2nudata v01_10_01d)
create_version_variables(dk2nugenie v01_10_01k)
create_version_variables(protobuf v3_15_8)
create_version_variables(pygccxml v2_2_1b)
create_version_variables(inclxx v5_2_9_5b)
# tensorflow
create_version_variables(eigen v3_4_0)
create_version_variables(bazelisk v1_10_1b)
create_version_variables(cython v0_29_33)
create_version_variables(giflib v5_2_1)
create_version_variables(libpng v1_6_37)
create_version_variables(nasm v2_14_02)
create_version_variables(libjpeg_turbo v2_1_0)
create_version_variables(tensorflow v2_6_4)
create_version_variables(tensorflow_dist NAME tensorflow ${TENSORFLOW_VERSION})

create_version_variables(sqlite v3_39_02_00)
create_version_variables(openblas v0_3_21)
create_version_variables(numpy v1_22_3c)
create_version_variables(tbb v2021_7_0)
create_version_variables(pybind11 v2_10_0)
create_version_variables(fftw v3_3_10)
create_version_variables(gmp v6_2_0)
create_version_variables(mpfr v4_1_0)
create_version_variables(grpc v1_35_0b)
#create_version_variables(opencv v4_7_0a)
create_version_variables(libtorch v1_13_1b)
create_version_variables(libtorch_dist NAME libtorch ${LIBTORCH_VERSION})
create_version_variables(triton v2_25_0b TRITON_SPACK_VERSION 2.25.0)
create_version_variables(triton_dist NAME triton ${TRITON_VERSION})

# TAUOLA C++ and friends
create_version_variables(hepmc3 v3_2_5)
create_version_variables(pythia8 v8_3_08)
create_version_variables(tauola v1_1_8k)
create_version_variables(tauola_dist NAME tauola ${TAUOLA_VERSION})

# CodeSynthesis XSD for NoVA.
#
# Special build-time-only xerces_c required for cstxsd.
create_version_variables(cstxsd_xerces_c NAME xerces_c v3_2_3a)
create_version_variables(cstxsd v4_0_0j)
create_version_variables(cstxsd_dist NAME cstxsd ${CSTXSD_VERSION})

# nutools
create_version_variables(nusimdata v1_27_02)
create_version_variables(nufinder v1_01_02)
create_version_variables(nuevdb v1_08_02)
create_version_variables(nug4 v1_15_02)
create_version_variables(nugen v1_19_06)
# nurandom and nusystematics are only used by LArSoft
create_version_variables(nurandom v1_10_02)
create_version_variables(systematicstools v01_03_03)
create_version_variables(nusystematics v01_03_12)

create_version_variables(nutools v3_15_04)
create_version_variables(nutools_dist NAME nutools ${NUTOOLS_VERSION})
set(nulite_suffix ) # Reset when no longer needed
create_version_variables(nulite ${NUTOOLS_VERSION}${nulite_suffix})

create_version_variables(nulite_base ${NULITE_VERSION})
create_version_variables(nubase ${NULITE_VERSION})
create_version_variables(nu ${NULITE_VERSION})

create_version_variables(ppfx v02_18_03)

# NOvA
create_version_variables(castxml v0_5_1)


########################################################################
# Spack-specific package versions.
set(BINUTILS_SPACK_VERSION 2.39:2)
set(GLEW_SPACK_VERSION 2.2.0:2)
set(PATCHELF_SPACK_VERSION 0.16.1:)

########################################################################
#       NO CALLS TO create_version_variables() BEYOND THIS POINT!      #
########################################################################

########################################################################
# Create PYQUAL, etc.
create_pyqual_variables()

# Initialize CMake variables containing shell fragments used by bundle
# configurations.
init_shell_fragment_vars()
define_build_base()

########################################################################
# No calls to create_version_variables() beyond this point.
########################################################################
# These files should be copied to SciSoft for each release.

# Define derivative variables used during expansion of distribution
# config files.

string(REGEX REPLACE "\\." "" ART_NOSEP_VERSION "${ART_DOT_VERSION}")
string(REGEX REPLACE "\\." "" GALLERY_NOSEP_VERSION "${GALLERY_DOT_VERSION}")
execute_process(COMMAND date
  OUTPUT_VARIABLE datime
  OUTPUT_STRIP_TRAILING_WHITESPACE )

# Define and generate UPS distribution configurations.

# nu (NOvA uses nu and nulite).
distribution(cstxsd_dist)
distribution(nubase)
distribution(nu WITH_HTML)
# nulite (LArSoft uses nulite, but not nu).

distribution(nulite_base)
distribution(nulite WITH_HTML)

# ifdh.
distribution(ifdh)

# libtorch.
distribution(libtorch_dist)

# triton.
distribution(triton_dist)

# tensorflow.
distribution(tensorflow_dist)

# Tauola C++ & friends.
distribution(tauola_dist)


########################################################################
# Spack environments (bundles)

# Ascertain native compiler
set_spack_native_compiler(NATIVE_COMPILER)

####################################
# Generate Spack environment configurations

##################
# Non-UPS configurations.
set(SPACK_SUPPORTED_COMPILERS)
set(SPACK_BUILD_TYPES prof)

# Add the native compiler if it's new enough
if (NOT (NATIVE_COMPILER_NAME STREQUAL "gcc" AND
      NATIVE_COMPILER_VERSION VERSION_LESS 9.3.0))
  set(SPACK_SUPPORTED_COMPILERS ${SPACK_SUPPORTED_COMPILERS} native)
endif()
if (NOT (ASVER STREQUAL "develop" OR CSVER STREQUAL "vdevelop"))
  set(SPACK_SUPPORTED_COMPILERS ${SPACK_SUPPORTED_COMPILERS}
    e20 e26 c15
  )
endif()
set(SPACK_SUPPORTED_COMPILERS e28 llvm@17.0.1%gcc@13.1.0_cxx20 ${SPACK_SUPPORTED_COMPILERS})

# Compiler-dependendent bundles.
foreach(compiler_label ${SPACK_SUPPORTED_COMPILERS})
  set(compiler_env_extra_spec)
  set_spack_main_compiler(${compiler_label} "MAIN_COMPILER" "SECONDARY_COMPILER")
  if (MAIN_COMPILER_NAME STREQUAL NATIVE_COMPILER_NAME AND
      (MAIN_COMPILER_VERSION VERSION_LESS NATIVE_COMPILER_VERSION OR
        (MAIN_COMPILER_VERSION VERSION_EQUAL NATIVE_COMPILER_VERSION AND
          MAIN_COMPILER_CXX_STANDARD STREQUAL NATIVE_COMPILER_STANDARD)))
    # Avoid duplication or any attempt to build a compiler with a newer
    # native compiler.
    continue()
  endif()
  if (MAIN_COMPILER_CXX_STANDARD)
    set(cxxstd_label cxx${MAIN_COMPILER_CXX_STANDARD})
  else()
    set(cxxstd_label)
  endif()
  if (NOT compiler_label STREQUAL native)
    if (SECONDARY_COMPILER_SPEC AND NOT SECONDARY_COMPILER_SPEC STREQUAL MAIN_COMPILER_SPEC)
      set(compiler_env_extra_spec ${SECONDARY_COMPILER_SPEC})
    endif()
    if (NOT SECONDARY_COMPILER_SPEC STREQUAL NATIVE_COMPILER_SPEC)
      set(compiler_env_extra_spec ${compiler_env_extra_spec} ${NATIVE_COMPILER_SPEC})
    endif()
    spack_environment(${MAIN_COMPILER_SPEC}
      NAME "${MAIN_COMPILER_NAME}"
      DOT_VERSION "${MAIN_COMPILER_VERSION}"
      EXTRA_SPEC
      ${compiler_env_extra_spec}
    )
  endif()
  foreach(build_type ${SPACK_BUILD_TYPES})
    set_cmake_build_type(${build_type} BUNDLE_CMAKE_BUILD_TYPE)
    foreach(env_name critic geant4 nulite)
      spack_environment(${env_name}
        EXTRA_SPEC ${MAIN_COMPILER_SPEC} ${cxxstd_label} ${build_type} ${NATIVE_COMPILER_SPEC}
      )
    endforeach()
    if (ASVER STREQUAL "develop")
      set(ROOT_SPACK_VERSION_safe "${ROOT_SPACK_VERSION}")
      set(ROOT_SPACK_VERSION master)
      spack_environment(critic_root_master
      EXTRA_SPEC root-master ${MAIN_COMPILER_SPEC} ${cxxstd_label} ${build_type} ${NATIVE_COMPILER_SPEC})
      set(ROOT_SPACK_VERSION "${ROOT_SPACK_VERSION_safe}")
    endif()
  endforeach()
endforeach()
########################################################################
