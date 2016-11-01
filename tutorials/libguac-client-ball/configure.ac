# Project information
AC_PREREQ([2.61])
AC_INIT([libguac-client-ball], [0.1.0])
AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AM_SILENT_RULES([yes])

AC_CONFIG_MACRO_DIRS([m4])

# Check for required build tools
AC_PROG_CC
AC_PROG_CC_C99
AC_PROG_LIBTOOL

# Check for libguac
AC_CHECK_LIB([guac], [guac_client_stream_png],,
      AC_MSG_ERROR("libguac is required for communication via "
                   "the Guacamole protocol"))

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
