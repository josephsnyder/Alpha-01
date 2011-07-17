cmake_minimum_required( VERSION 2.8 )

project( Alpha-01 )

include(CTest)
include(CPack)

option(BUILD_REPORTS "Build Reports." OFF)

add_subdirectory( Testing )

if( BUILD_REPORTS )
  add_subdirectory( Reports )
endif()
