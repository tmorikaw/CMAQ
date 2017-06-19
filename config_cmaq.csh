#!/bin/csh -f

# ================== CMAQ5.2 Configuration Script =================== #
# Requirements: I/O API & netCDF libraries                            #
#               PGI, Intel, or Gnu Fortran compiler                   #
#               MPICH for multiprocessor computing                    #
# Optional:     Git for GitHub source code repository                 #
#                                                                     #
# Note that this script was configured/tested on Red Hat Linux O/S    #
#                                                                     #
# To report problems or request help with this script/program:        #
#             http://www.cmascenter.org/help_desk.cfm                 #
# =================================================================== #

# ~~~~~~~~~~~~~~~~~~~~~~~~ Start EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#> Note to development and evaluation teams running at NCC:
#> You must "module load" the correct modules for intel, PGI, or 
#> gfortran. The BLDMAKE utility will insert the compiler path into 
#> the Makefile from the module-loaded environment. BLDMAKE reads the 
#> cfg.* file generated by the bldit script and inserts the compiler 
#> into the generated Makefile. Those compiler options are set here in 
#> config.cmaq.
   source /etc/profile.d/modules.csh 
# ~~~~~~~~~~~~~~~~~~~~~~~~~ End EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#> Model source code repository location
 setenv CMAQ_WORK $cwd   #This is working directory where the scripts
                         #will create links to libraries and folders
                         #for build directories, etc. The default is 
                         #to make this folder one level higher than the 
                         #top level of your CMAQ repo.
 setenv CMAQ_REPO ${CMAQ_WORK}/CMAQ_REPO

#===============================================================================
#> architecture & compiler specific settings
#===============================================================================

#> Set the compiler option
 if ( $#argv == 1 ) then
    #> Use the user's input to set the compiler parameter
    setenv compiler $1
 else if ( $#argv == 0 ) then
    #> If config.cmaq is called from Bldit.cctm or run.cctm, then this 
    #> variable is already defined
    if ( ! $?compiler ) then
      echo "Error: 'compiler' should be set either in the"
      echo "       environment or as input to config.cmaq"
      echo "       Example:> ./config.cmaq [compiler]"
      echo "       Options: intel | gcc | pgi"
      exit
    endif
 else
    #> More than one input was given. Exit this script just to
    #> be on the safe side.
    echo "Error: Too many inputs to config.cmaq. This script"
    echo "       is expecting only one input (the name of the"
    echo "       desired compiler"
    exit
 endif
 echo "Compiler is set to $compiler"


#> Compiler flags and settings
 switch ( $compiler )

#>  Intel fortran compiler......................................................
    case intel:
    
      # ~~~~~~~~~~~~~~~~~~~~~~~~ Start EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #> The following module combinations are available on Sol:
      #>    module load  intel/13.1  netcdf-4.3.1/intel-13.1  impi/4.1.0.024  ioapi-3.1/intel-13.1
      #>      For running w/ parallel_io: module load pnetcdf-1.4.1/intel-13.1
      #> 
      #>  Untested Alternative Configuration:
      #>    module load  intel/15.0  netcdf-4.3.2/intel-15.0  openmpi-1.10.2/intel-15.0
        module purge
        module load modules 
        module load  intel/13.1  netcdf-4.3.1/intel-13.1  impi/4.1.0.024 ioapi-3.1/intel-13.1
      # ~~~~~~~~~~~~~~~~~~~~~~~~~ End EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
        #> I/O API, netCDF, and MPI library locations
        setenv IOAPI_MOD_DIR  /usr/local/apps/ioapi-3.1/intel-13.1/Linux2_x86_64ifort #> I/O API precompiled modules
        setenv IOAPI_INCL_DIR /usr/local/apps/ioapi-3.1/intel-13.1/ioapi/fixed_src    #> I/O API include header files
        setenv IOAPI_LIB_DIR  /usr/local/apps/ioapi-3.1/intel-13.1/lib                #> I/O API libraries
        setenv NETCDF_LIB_DIR /usr/local/apps/netcdf-4.3.1/intel-13.1                 #> netCDF directory path
        setenv MPI_LIB_DIR    /usr/local/apps/intel/impi/4.1.0.024/intel64            #> MPI directory path
    
        #> Compiler Aliases and Flags
        setenv myFC mpiifort
        setenv myCC icc       
        setenv myFSTD "-O3 -fno-alias -mp1 -fp-model source"
        setenv myDBG  "-O0 -g -check bounds -check uninit -fpe0 -fno-alias -ftrapuv -traceback"
        setenv myLINK_FLAG "-openmp"
        setenv myFFLAGS "-fixed -132"
        setenv myFRFLAGS "-free"
        setenv myCFLAGS "-O2"
        setenv extra_lib "-lcurl"
        setenv mpi_lib ""    #> No Library specification needed for mpiifort
                             #> -lmpich for mvapich 
                             #> -lmpi for openmpi
    
        breaksw
    
#>  Portland Group fortran compiler.............................................
    case pgi:

      # ~~~~~~~~~~~~~~~~~~~~~~~~ Start EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #> The following module combinations are available on Sol:
        module purge
        module load modules 
        module load pgi/15.3  openmpi-1.8.6/pgi-15.3  netcdf-4.3.3/pgi-15.3 ioapi-3.1_150122/pgi-15.3
      # ~~~~~~~~~~~~~~~~~~~~~~~~~ End EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        #> I/O API, netCDF, and MPI library locations
        setenv IOAPI_MOD_DIR  /home/wdx/lib_sol/x86_64/pgi-15.3/ioapi_3.1/Linux2_x86_64pg  #> I/O API directory path
        setenv IOAPI_INCL_DIR /home/wdx/lib_sol/x86_64/pgi-15.3/ioapi_3.1/ioapi/fixed_src  #> I/O API directory path
        setenv IOAPI_LIB_DIR  /home/wdx/lib_sol/x86_64/pgi-15.3/ioapi_3.1/Linux2_x86_64pg  #> I/O API directory path
        setenv NETCDF_LIB_DIR /home/wdx/lib_sol/x86_64/pgi-15.3/netcdf                     #> netCDF directory path
        setenv MPI_LIB_DIR    /home/wdx/lib_sol/x86_64/pgi-15.3/mpich                      #> MPI directory path
    
        #> Compiler Aliases and Flags
        setenv myFC mpifort 
        setenv myCC pgcc
        setenv myLINK_FLAG ""
        setenv myFSTD "-O3"
        setenv myDBG  "-O0 -g -Mbounds -Mchkptr -traceback -Ktrap=fp"
        setenv myFFLAGS "-Mfixed -Mextend -mcmodel=medium"
        setenv myFRFLAGS "-Mfree -Mextend -mcmodel=medium"
        setenv myCFLAGS "-O2"
        #setenv extra_lib "-lcurl"
        setenv extra_lib "-lextra"
        setenv mpi_lib "-lmpi"   #> -lmpich for mvapich or -lmpi for openmpi
    
        breaksw
    
#>  gfortran compiler............................................................
    case gcc:
  
      # ~~~~~~~~~~~~~~~~~~~~~~~~ Start EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #> The following module combinations are available on Sol:
      #>    module load  gcc/4.9.1  openmpi-1.8.1/gcc-4.9.1  netcdf-4.3.1/gcc-4.4.7 ioapi-3.1/gcc-4.4.7
        module purge
        module load modules 
        module load  gcc/4.9.1  openmpi-1.8.1/gcc-4.9.1  netcdf-4.4.1/gcc-4.4.7  ioapi-3.1/gcc-4.4.7
      # ~~~~~~~~~~~~~~~~~~~~~~~~~ End EPA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        #> I/O API, netCDF, and MPI library locations
        setenv IOAPI_MOD_DIR  /home/wdx/lib/x86_64/gcc/ioapi_3.1/Linux2_x86_64gfort  #> I/O API directory path
        setenv IOAPI_INCL_DIR /home/wdx/lib/x86_64/gcc/ioapi_3.1/ioapi/fixed_src     #> I/O API directory path
        setenv IOAPI_LIB_DIR  /home/wdx/lib/x86_64/gcc/ioapi_3.1/Linux2_x86_64gfort  #> I/O API directory path
        setenv NETCDF_LIB_DIR /usr/local/apps/netcdf-4.4.1/gcc-4.4.7                 #> netCDF directory path
        setenv MPI_LIB_DIR    /usr/local/apps/openmpi-1.8.1/gcc-4.9.1                #> MPI directory path
    
        #> Compiler Aliases and Flags
        setenv myFC mpifort
        setenv myCC gcc
        setenv myFSTD "-O3 -funroll-loops -finit-character=32 -Wtabs -Wsurprising"
        setenv myDBG  "-Wall -O0 -g -fcheck=all -ffpe-trap=invalid,zero,overflow -fbacktrace"
        #setenv myDBG  "$myDBG -fimplicit-none"
        setenv myFFLAGS "-ffixed-form -ffixed-line-length-132 -funroll-loops -finit-character=32"
        setenv myFRFLAGS "-ffree-form -ffree-line-length-none -funroll-loops -finit-character=32"
        setenv myCFLAGS "-O2"
        setenv myLINK_FLAG ""
        setenv extra_lib ""
        setenv mpi_lib "-lmpi_mpifh"   #> -lmpich for mvapich or -lmpi for openmpi
    
        breaksw

    default:
        echo "*** Compiler $compiler not found"
        exit(2)
        breaksw

 endsw
 
#===============================================================================
 
#> I/O API, netCDF, and MPI libraries
 setenv netcdf_lib "-lnetcdf -lnetcdff"  #> -lnetcdff -lnetcdf for netCDF v4.2.0 and later
 setenv ioapi_lib "-lioapi" 
 setenv pnetcdf_lib "-lpnetcdf"

#> Query System Info and Current Working Directory
 setenv system "`uname -m`"
 setenv bld_os "`uname -s``uname -r | cut -d. -f1`"
 setenv lib_basedir $cwd/lib

#> Generate Library Locations
 setenv CMAQ_LIB    ${lib_basedir}/${system}/${compiler}
 setenv MPI_INCL    $CMAQ_LIB/mpi/include
 setenv NETCDF_DIR  $CMAQ_LIB/netcdf
 setenv PNETCDF_DIR $CMAQ_LIB/pnetcdf
 setenv IOAPI_DIR   $CMAQ_LIB/ioapi

 if ( ! -d $CMAQ_LIB ) mkdir -p $CMAQ_LIB
 if ( ! -d $CMAQ_LIB/mpi) ln -s $MPI_LIB_DIR $CMAQ_LIB/mpi
 if ( ! -d $NETCDF_DIR )  ln -s $NETCDF_LIB_DIR $NETCDF_DIR
 if ( ! -d $IOAPI_DIR ) then 
    mkdir $IOAPI_DIR
    ln -s $IOAPI_MOD_DIR  $IOAPI_DIR/modules
    ln -s $IOAPI_INCL_DIR $IOAPI_DIR/include_files
    ln -s $IOAPI_LIB_DIR  $IOAPI_DIR/lib
 endif

#> Check for netcdf and I/O API libs/includes, error if they don't exist
 if ( ! -e $NETCDF_DIR/lib/libnetcdf.a ) then 
    echo "ERROR: $NETCDF_DIR/lib/libnetcdf.a does not exist in your CMAQ_LIB directory!!! Check your installation before proceeding with CMAQ build."
    exit
 endif
 if ( ! -e $NETCDF_DIR/include/netcdf.h ) then 
    echo "ERROR: $NETCDF_DIR/include/netcdf.h does not exist in your CMAQ_LIB directory !!! Check your installation before proceeding with CMAQ build."
    exit
 endif
 if ( ! -e $IOAPI_DIR/lib/libioapi.a ) then 
    echo "ERROR: $IOAPI_DIR/lib/libioapi.a does not exist in your CMAQ_LIB directory!!! Check your installation before proceeding with CMAQ build."
    exit
 endif
 if ( ! -e $IOAPI_DIR/modules/m3utilio.mod ) then 
    echo "ERROR: $IOAPI_DIR/include/m3utilio.mod does not exist in your CMAQ_LIB directory!!! Check your installation before proceeding with CMAQ build."
    exit
 endif

#> Set executable id
 setenv EXEC_ID ${bld_os}_${system}${compiler}
