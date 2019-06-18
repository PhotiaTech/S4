#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

# This file contains make commands for S4 fork.

# Photia Incorporated

#------------------------------------------------------------------------------#

# Set operating system specific variables.

ifeq ($(OS),Windows_NT)

  OBJDIR = build
  SHLIB_EXT = dll
  SHLIB_FLAGS = -shared -fpic
  LA_LIBS = -lopenblas -lgfortran -lquadmath
  LUA_INC =
  LUA_LIB = -Wl,-Bdynamic -llua -Wl,-Bstatic
  LUA_MODULE_LIB = -DLUA_BUILD_AS_DLL -Wl,-Bdynamic -llua.dll -Wl,-Bstatic

  CFLAGS += -DHAVE_BLAS -DHAVE_LAPACK -O2 -Wall -march=native -fcx-limited-range -fno-exceptions -static
  CXXFLAGS = $(CFLAGS)

  CC = gcc
  CXX = g++

else

  UNAME_S := $(shell uname -s)

  ifeq ($(UNAME_S),Linux)

    OBJDIR = build
    SHLIB_EXT = so
    SHLIB_FLAGS = -fPIC -shared
    LA_LIBS = -llapack -lblas
    LUA_INC = -I/usr/include/lua5.3
    LUA_LIB = -llua5.3
    LUA_MODULE_LIB =

    MPI_INC =
    MPI_LIB =

    CFLAGS   += -O3 -Wall -march=native -fcx-limited-range -fno-exceptions -fPIC
    CXXFLAGS += -O3 -Wall -march=native -fcx-limited-range -fno-exceptions -fPIC

    # If compiling with message passing interface (MPI), modify following to proper MPI compiler(s).
    CC = gcc
    CXX = g++

  endif

  ifeq ($(UNAME_S),Darwin)

    OBJDIR = build
    SHLIB_EXT = so
    SHLIB_FLAGS = -bundle -undefined dynamic_lookup
    LA_LIBS = -framework Accelerate
    LUA_INC = -I/usr/local/include/lua5.2
    LUA_LIB = -L/usr/local/lib -llua
    LUA_MODULE_LIB =

    OPTFLAGS = -O2
    CFLAGS += $(OPTFLAGS) -Wall
    CXXFLAGS += $(OPTFLAGS) -Wall -std=c++11

    CC = cc
    CXX = c++

  endif

endif

#------------------------------------------------------------------------------#

# Set common variables.

CPPFLAGS += -IS4 -IS4/RNP -IS4/kiss_fft

S4_LIBNAME = libS4.a

S4_LIBOBJS = \
	$(OBJDIR)/S4k/S4.o \
	$(OBJDIR)/S4k/rcwa.o \
	$(OBJDIR)/S4k/fmm_common.o \
	$(OBJDIR)/S4k/fmm_FFT.o \
	$(OBJDIR)/S4k/fmm_kottke.o \
	$(OBJDIR)/S4k/fmm_closed.o \
	$(OBJDIR)/S4k/fmm_PolBasisNV.o \
	$(OBJDIR)/S4k/fmm_PolBasisVL.o \
	$(OBJDIR)/S4k/fmm_PolBasisJones.o \
	$(OBJDIR)/S4k/fmm_experimental.o \
	$(OBJDIR)/S4k/fft_iface.o \
	$(OBJDIR)/S4k/pattern.o \
	$(OBJDIR)/S4k/intersection.o \
	$(OBJDIR)/S4k/predicates.o \
	$(OBJDIR)/S4k/numalloc.o \
	$(OBJDIR)/S4k/gsel.o \
	$(OBJDIR)/S4k/sort.o \
	$(OBJDIR)/S4k/kiss_fft.o \
	$(OBJDIR)/S4k/kiss_fftnd.o \
	$(OBJDIR)/S4k/SpectrumSampler.o \
	$(OBJDIR)/S4k/cubature.o \
	$(OBJDIR)/S4k/Interpolator.o \
	$(OBJDIR)/S4k/convert.o

ifndef LAPACK_LIB
  S4_LIBOBJS += $(OBJDIR)/S4k/Eigensystems.o
endif

#------------------------------------------------------------------------------#

# Set compile targets and build rules for core functionality.

all: $(OBJDIR)/$(S4_LIBNAME) $(OBJDIR)/S4 modules

S4mpi: $(OBJDIR)/S4mpi

objdir:
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/S4k
	mkdir -p $(OBJDIR)/modules

$(OBJDIR)/libS4.a: objdir $(S4_LIBOBJS)
	$(AR) crvs $@ $(S4_LIBOBJS)

$(OBJDIR)/S4k/S4.o: S4/S4.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/rcwa.o: S4/rcwa.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_common.o: S4/fmm/fmm_common.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_FFT.o: S4/fmm/fmm_FFT.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_kottke.o: S4/fmm/fmm_kottke.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_closed.o: S4/fmm/fmm_closed.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisNV.o: S4/fmm/fmm_PolBasisNV.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisVL.o: S4/fmm/fmm_PolBasisVL.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisJones.o: S4/fmm/fmm_PolBasisJones.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_experimental.o: S4/fmm/fmm_experimental.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fft_iface.o: S4/fmm/fft_iface.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/pattern.o: S4/pattern/pattern.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/intersection.o: S4/pattern/intersection.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/predicates.o: S4/pattern/predicates.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/numalloc.o: S4/numalloc.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/gsel.o: S4/gsel.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/sort.o: S4/sort.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fft.o: S4/kiss_fft/kiss_fft.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fftnd.o: S4/kiss_fft/tools/kiss_fftnd.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/SpectrumSampler.o: S4/SpectrumSampler.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/cubature.o: S4/cubature.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Interpolator.o: S4/Interpolator.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/convert.o: S4/convert.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Eigensystems.o: S4/RNP/Eigensystems.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf $(OBJDIR)

#------------------------------------------------------------------------------#

# Set compile targets and build rules for Lua interfacing.

$(OBJDIR)/S4k/main_lua.o: S4/main_lua.c objdir
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $< -o $@
$(OBJDIR)/S4: $(OBJDIR)/S4k/main_lua.o $(OBJDIR)/$(S4_LIBNAME)
	$(CXX) $(CFLAGS) $(CPPFLAGS) $< -o $@ -L$(OBJDIR) -lS4 $(LA_LIBS) $(LUA_LIB)

$(OBJDIR)/S4k/main_lua_mpi.o: S4/main_lua.c objdir
	$(CC) -c -DHAVE_MPI $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $(MPI_INC) $< -o $@
$(OBJDIR)/S4mpi: $(OBJDIR)/S4k/main_lua_mpi.o $(OBJDIR)/$(S4_LIBNAME)
	$(CXX) $(CFLAGS) $(CPPFLAGS) $< -o $@ -L$(OBJDIR) -lS4 $(LA_LIBS) $(LUA_LIB) $(MPI_LIB)

modules: \
	$(OBJDIR)/RCWA.$(SHLIB_EXT) \
	$(OBJDIR)/FunctionSampler1D.$(SHLIB_EXT) \
	$(OBJDIR)/FunctionSampler2D.$(SHLIB_EXT)

$(OBJDIR)/RCWA.$(SHLIB_EXT):
	 $(CC) $(LUA_INC) -O3 $(SHLIB_FLAGS) -fpic S4/main_lua.c -o $@ $(LUA_MODULE_LIB) -L$(OBJDIR) -lS4 $(LA_LIBS) -lstdc++
$(OBJDIR)/FunctionSampler1D.$(SHLIB_EXT): modules/function_sampler_1d.c modules/function_sampler_1d.h modules/lua_function_sampler_1d.c
	$(CC) -c $(OPTFLAGS) -fpic -Wall -I. modules/function_sampler_1d.c -o $(OBJDIR)/modules/function_sampler_1d.o
	$(CC) $(OPTFLAGS) $(SHLIB_FLAGS) -fpic -Wall $(LUA_INC) -o $@ $(OBJDIR)/modules/function_sampler_1d.o modules/lua_function_sampler_1d.c $(LUA_MODULE_LIB)
$(OBJDIR)/FunctionSampler2D.$(SHLIB_EXT): modules/function_sampler_2d.c modules/function_sampler_2d.h modules/lua_function_sampler_2d.c
	$(CC) -c $(OPTFLAGS) -fpic -Wall -I. modules/function_sampler_2d.c -o $(OBJDIR)/modules/function_sampler_2d.o
	$(CC) -c -O2 -fpic -Wall -I. modules/predicates.c -o $(OBJDIR)/modules/mod_predicates.o
	$(CC) $(OPTFLAGS) $(SHLIB_FLAGS) -fpic -Wall $(LUA_INC) -o $@ $(OBJDIR)/modules/function_sampler_2d.o $(OBJDIR)/modules/mod_predicates.o modules/lua_function_sampler_2d.c $(LUA_MODULE_LIB)

#------------------------------------------------------------------------------#

# Set compile targets and build rules for Python interfacing.

S4_pyext: objdir $(OBJDIR)/libS4.a
	echo "$(LIBS)" > $(OBJDIR)/tmp.txt
	sh gensetup.py.sh $(OBJDIR) $(OBJDIR)/$(S4_LIBNAME)
	python setup.py build

#------------------------------------------------------------------------------#

# Set compile targets and build rules for S4V2 extension code.

$(OBJDIR)/S4v2.$(SHLIB_EXT): $(OBJDIR)/$(S4_LIBNAME) S4/ext_lua.c
	$(CC) $(SHLIB_FLAGS) $(LUA_INC) S4/ext_lua.c -o $@ $(LUA_MODULE_LIB) -L$(OBJDIR) -lS4 $(LA_LIBS) -lstdc++
$(OBJDIR)/libS4_lua.a: $(OBJDIR)/$(S4_LIBNAME)
	$(CC) -c $(LUA_INC) S4/ext_lua.c -o $(OBJDIR)/ext_lua.o
	$(AR) crvs $@ $(OBJDIR)/ext_lua.o

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
