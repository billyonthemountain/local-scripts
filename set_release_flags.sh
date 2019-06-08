unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

#This file contains the definitions for the optimization settings used by GentooLTO.
#source this file directly in your make.conf if you want to cherry-pick settings
#and don't want to use the make.conf.lto default configuration, defining the number of threads
#to use during the LTO process beforehand:

NTHREADS="4"

#source make.conf.lto.defines

#Guidelines:
#* Your CFLAGS should contain ${FLTO} and, depending on your gcc, -fuse-linker-plugin
#* Newer GCCs enable -fuse-linker-plugin by default.
#* If you want Graphite, include "${GRAPHITE}" in your CFLAGS
#* If you want -fipa-pta, include "${IPAPTA}" in your CFLAGS (undefined for now, issue #257)
#* Anything else is up to you, such as -march, -pipe, -O{3,2,s,1}, etc...
#* CXXFLAGS should be set to CFLAGS
#* Optionally, set other *FLAGS for languages compiled with GCC as well (See make.conf.lto)
#* LDFLAGS of your Gentoo profile should be respected.  Consider adding -Wl,--hash-style=gnu.
#  See make.conf.lto for more details.

#FLTO is of the form -flto[=n] where n is the number of threads to use during linking.
#It's usually a good idea to set this to the number of hardware threads in your system
FLTO="-flto=${NTHREADS}"

#GRAPHITE contains Graphite specific optimizations and other optimizations that are disabled at O3
#but don't influence the compiler's judgement.
#With GCC 8.1.0, -ftree-loop-distribution is enabled by default at -O3
GRAPHITE="-fgraphite-identity -floop-nest-optimize -ftree-loop-distribution"
#NOTE: To use graphite, make sure you have gcc compiled with graphite support (add graphite to your USE).  Otherwise GCC will complain!

IPAPTA="-fipa-pta"

#IPAPTA contains -fipa* opts that are disabled by default in GCC.  These are interprocedural optimizations.  For now this is only -fipa-pta.
#This option increases compile times, but can potentially produce better binaries, especially with LTO.
#Essentially, it allows the compiler to look into called function bodies when performing alias analysis

SEMINTERPOS="-fno-semantic-interposition"

# With -fno-semantic-interposition the compiler assumes that if interposition happens for functions the overwriting function will have precisely the same semantics (and side effects). Similarly if interposition happens for variables, the constructor of the variable will be the same. The flag has no effect for functions explicitly declared inline (where it is never allowed for interposition to change semantics) and for symbols explicitly declared weak.

NOCOMMON="-fno-common"

# This option only affects C code.  Only non-conformant C code needs -fcommon, which is enabled by default.  Clear Linux leaves this flag off by default.
# We may enable this at some point.  For now, there's a lot of breakages to work through.

SAFERFASTMATH="-fno-math-errno -fno-trapping-math"

#These are flags left off by default that we're planning to start using.  Clear Linux uses these in lieu of full -ffast-math optimizations
#They DO break compliance with ISO C++, so we'll be careful about introducing these.
#Relevant discussion: https://gcc.gnu.org/ml/gcc/2017-09/msg00079.html
#We may end up just going full -Ofast, with exceptions done in the usual way.

DEVIRTLTO="-fdevirtualize-at-ltrans"

#This allows GCC to perform devirtualization across object file boundaries using LTO.  It's off by default because it
#increases compilation time.

NOPLT="-fno-plt"

#This option omits the PLT from the executable, making calls go through the GOT directly.
#It inhibits lazy binding, so this is not enabled by default.  If you use prelink, this is
#strictly better than lazy binding.

#LTO takes a lot more memory than non-LTO processes.  You will likely not be able to emerge many packages
#in parallel unless you have a lot of memory available.  As an alternative, consider setting MAKEOPTS
#to parallelize according to NTHREADS, which should avoid that problem.  You may consider balancing between
#emerging in parallel with parallizing make as a compromise.

export MAKEOPTS="-j${NTHREADS}"

#Lastly, for cmake packages, you may want to set the default generator to Ninja.
#It is considerably faster than GNU make and can help build times.

export CMAKE_MAKEFILE_GENERATOR=ninja


CFLAGS="-march=native ${CFLAGS} -pipe -O2 -falign-functions=32"

#This enables your CFLAGS to inherit the default flags that GentooLTO uses.
#Note that you may want to enable -falign-functions=32 if you use an Intel processor (Sandy Bridge or later).
#See issue #164 for details.

export CFLAGS="${CFLAGS} ${GRAPHITE} ${DEVIRTLTO} ${IPAPTA} ${SEMINTERPOS} ${FLTO} -fuse-linker-plugin"

#Next, set your CXXFLAGS to CFLAGS:

export CXXFLAGS="${CFLAGS}"

#Your CXXFLAGS should be a superset of your CFLAGS.  Most people will never need to add anything extra to their CXXFLAGS.

#Your LDFLAGS should contain *ALL* of your CFLAGS for LTO to work.  It must receieve all optimization options, march, etc.
#package.cflags takes care of this for you--no need to manually add your {C,CXX}FLAGS here.
#It's usually a good idea to enable -Wl,--hash-style=gnu as well to help find packages which don't respect LDFLAGS
#Ensure that your profile's LDFLAGS are respected by including them first.

LDFLAGS="${LDFLAGS} -Wl,--hash-style=gnu ${CFLAGS}"

#NOTE: your profile likely contains -Wl,--as-needed and -Wl,-O1.
#The -Wl,-01 here is a separate option sent to the linker that optimizes shared object binary sizes
#It is NOT related to the -O option given to gcc and has no bearing on that option.
#For example, compiling using: -fuse-linker-plugin -flto -O3 -Wl,-O1:
#This will produce an LTO binary with -O3
#level optimization and also pass -O1 to the linker to reduce the shared object size.

export LDFLAGS="${LDFLAGS} -Wl,--as-needed -Wl,-O1"
