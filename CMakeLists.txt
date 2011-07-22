cmake_minimum_required( VERSION 2.8 )

project( Alpha-01 )

include(CTest)
include(CPack)

option(BUILD_REPORTS "Build Reports." OFF)

file(GLOB_RECURSE M_FILES "*.m")

add_subdirectory( Testing )
add_subdirectory( Utilities )

if( BUILD_REPORTS )
  add_subdirectory( Reports )
endif()
