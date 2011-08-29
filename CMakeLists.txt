CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)

PROJECT(VISTA)

OPTION(BUILD_TESTING "Test the project" ON)
OPTION(BUILD_REPORTS "Build Reports." OFF)

IF(WIN32)
IF(BUILD_TESTING)
	ENABLE_TESTING()
	INCLUDE(CTest)
ENDIF(BUILD_TESTING)

if( BUILD_REPORTS )
  add_subdirectory( Reports )
endif()

	FIND_PROGRAM(CControlExec NAMES InterCache)
	FIND_PROGRAM(AutoHK NAMES AutoHotKey)
	FIND_PATH(Cache_Path NAMES Cache_Dir)
	execute_process(COMMAND  ${AutoHK}  ${VISTA_SOURCE_DIR}/Routineslist.ahk)
	FILE(STRINGS ${Cache_Path}/VistA/routines.txt ListRoutines REGEX ^[A-Z])
	FOREACH( Routines ${ListRoutines})
		STRING(SUBSTRING ${Routines} 0 8 FinalRoutine)
		STRING(COMPARE NOTEQUAL ${FinalRoutine} "NAME    " nameflag)
		STRING(COMPARE NOTEQUAL ${FinalRoutine} "Total fo" totalflag)
		if(nameflag AND totalflag)
			STRING(STRIP ${FinalRoutine} FinalRoutine)
			configure_file(${VISTA_SOURCE_DIR}/AutoHotkey.ahk.in ${VISTA_BINARY_DIR}/Testing/${FinalRoutine}.ahk)
			ADD_TEST(${FinalRoutine}Test ${AutoHK}  ${VISTA_BINARY_DIR}/Testing/${FinalRoutine}.ahk)
			set_property(TEST ${FinalRoutine}Test PROPERTY FAIL_REGULAR_EXPRESSION "F -" "W -")
		ENDIF()
	ENDFOREACH(Routines ${ListRoutines})
	return()
endif(WIN32)

message("Not on Windows")
FIND_FILE(GTMPROFILE "Path to the GTM Profile")
FIND_PROGRAM(EXPECT_EXEC NAMES expect)

SET (VISTA_ROUTINE_DIR ${VISTA_SOURCE_DIR}/routines)
SET (VISTA_GLOBALS_DIR ${VISTA_SOURCE_DIR}/globals)

set( ENV{gtmgbldir}="${VISTA_GLOBALS_DIR}/mumps.gld")
execute_process(COMMAND export gtmroutines="${gtmroutines} ${VISTA_ROUTINE_DIR}")

IF(BUILD_TESTING)
	ENABLE_TESTING()
	INCLUDE(CTest)
ENDIF(BUILD_TESTING)

if( BUILD_REPORTS )
  add_subdirectory( Reports )
endif()


MAKE_DIRECTORY(${VISTA_BIN_DIR}/Testing/Temp/)

file (GLOB ROUTINES ${VISTA_ROUTINE_DIR}/*.m)


FOREACH(ROUTINE ${ROUTINES})
get_filename_component(RFILE ${ROUTINE} NAME_WE)
string(REGEX MATCH ^. CHAR1 ${RFILE})
if(${CHAR1} STREQUAL "_")
	string(REGEX REPLACE ^[_] % RFILE ${RFILE})
ENDIF()
configure_file(${VISTA_SOURCE_DIR}/XINDEXscript.exp.in ${VISTA_BINARY_DIR}/Testing/${RFILE}.exp)
configure_file(${VISTA_SOURCE_DIR}/RoutineTest.cmake.in ${VISTA_BINARY_DIR}/Testing/${RFILE}.cmake @ONLY)
ADD_TEST( ${RFILE}Test cmake -P ${VISTA_BINARY_DIR}/Testing/${RFILE}.cmake)
set_property(TEST ${RFILE}Test PROPERTY FAIL_REGULAR_EXPRESSION "F -" "W -")
ENDFOREACH()
