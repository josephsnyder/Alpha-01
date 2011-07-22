#
# Build the documentation
#
include (${CMAKE_ROOT}/Modules/Documentation.cmake)

mark_as_advanced(CLEAR BUILD_DOCUMENTATION)

# -------------------------------------------------------------
#
# Generate Doxygen configuration file in all configuration file
#
if( ${DOXYGEN_DOT_FOUND} )
  set( OSEHR_HAVE_DOT "YES" )
else()
  set( OSEHR_HAVE_DOT "NO" )
endif()

#
# Configure the script and the doxyfile, then add target
#
set( OSEHR_DOXYGEN_OUTPUT_DIR ${PROJECT_BINARY_DIR}/Utilities/Doxygen )

set( OSEHR_DOXYGEN_INPUT ${DOXYGEN_INCLUDE_DIRS} )

SET( OSEHR_DOXYGEN_DIAGRAMS YES )

configure_file(${PROJECT_SOURCE_DIR}/Utilities/Doxygen/doxygen.config.in
               ${PROJECT_BINARY_DIR}/Utilities/Doxygen/doxygen.config)


set( OSEHR_DOXYGEN_OUTPUT_DIR ${PROJECT_BINARY_DIR}/temp )

set( OSEHR_DOXYGEN_INPUT "\"INPUT_SINGLE_FILE\"" )

set( OSEHR_DOXYGEN_DIAGRAMS NO )

configure_file(${PROJECT_SOURCE_DIR}/Utilities/Doxygen/doxygen.config.in
               ${PROJECT_BINARY_DIR}/single-doxygen.config)

# -------------------------------------------------------------
if (BUILD_DOCUMENTATION)

  find_package( LATEX )

  if( NOT LATEX_COMPILER )
    message( "Warning: LaTeX not found. Formulas will not be generated in documentation." )
  endif()

  configure_file(${PROJECT_SOURCE_DIR}/Utilities/Doxygen/osehrdoxygen.pl.in
                 ${PROJECT_BINARY_DIR}/Utilities/Doxygen/osehrdoxygen.pl)

  add_custom_target(Documentation ALL
    COMMAND ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/Utilities/Doxygen/doxygen.config
    MAIN_DEPENDENCY ${PROJECT_BINARY_DIR}/Utilities/Doxygen/doxygen.config
    DEPENDS         ${PROJECT_BINARY_DIR}/Utilities/Doxygen/osehrdoxygen.pl
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/Utilities/Doxygen
    )

  message( STATUS
           "To generate Doxygen's documentation, you need to build the Documentation target"
         )

endif (BUILD_DOCUMENTATION)
