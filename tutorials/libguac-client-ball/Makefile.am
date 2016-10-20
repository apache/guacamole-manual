AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4
AM_CFLAGS = -Werror -Wall -pedantic

lib_LTLIBRARIES = libguac-client-ball.la

# All source files of libguac-client-ball
noinst_HEADERS = src/ball.h
libguac_client_ball_la_SOURCES = src/ball.c

# libtool versioning information
libguac_client_ball_la_LDFLAGS = -version-info 0:0:0
