#---------------------------------------------------------------------------
# Copyright 2011 The Open Source Electronic Health Record Agent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#---------------------------------------------------------------------------


CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)

PROJECT(VISTA NONE)

OPTION(BUILD_TESTING "Test the project" ON)																								#Options that will show up on the CMake Gui that allows customization of the project
OPTION(BUILD_REPORTS "Build Reports." OFF)
OPTION(WARNING_FAILURE "Use the XINDEX Condition output of warning as a failure condition for testing" ON)
mark_as_advanced(WARNING_FAILURE)

#The next two options designate what system will be used as the Mumps Environment, this dicates the way routines are found.
FIND_PROGRAM(CControl NAMES Ccontrol.exe HINTS "C:/InterSystems/TryCache/bin/" DOC "Path to the Ccontrol executable of Cache")
FIND_FILE(GTMPROFILE NAMES gtmprofile DOC "Path to the GTM Profile")

SET(FAILURE_CONDITIONS "F -" "W -")
IF(CControl)   																																#If CControl is found, the Cache system and paths are used
IF(BUILD_TESTING)  																															# Creates the Testing/Temporary/ directories used in CTest if the optino is selected 
	ENABLE_TESTING()
	INCLUDE(CTest)
ENDIF(BUILD_TESTING)

if( BUILD_REPORTS )																															# Creates the reports folder with style guides for submitting to the OSEHR journal if the option is selected
  add_subdirectory( Reports )
endif()
	
	FIND_PROGRAM(AutoHK NAMES AutoHotKey.exe DOC "Path to the executable for AutoHotKey")																								#AutoHotKey is our Windows Driver to automate the XINDEX routine
	FIND_PATH(VISTA_Path NAMES mgr DOC "Path to the VistA folder within Cache")
	if(0)
	#execute_process(COMMAND  ${AutoHK}  ${VISTA_SOURCE_DIR}/Routineslist.ahk)																#Calls the RD routine to print out the listing of the routines contained in the cache.dat
	FILE(STRINGS ${VISTA_Path}/routines.txt ListRoutines REGEX ^[A-Z])																		#Goes through the saved file and grabs the lines that contain Routine names (Lines that start with capital leters)
	
	FOREACH( Routines ${ListRoutines})
		STRING(SUBSTRING ${Routines} 0 8 FinalRoutine)																						#Grabs the first 8 characters, length of Routine name
		STRING(COMPARE NOTEQUAL ${FinalRoutine} "NAME    " nameflag)																		#Checks that it does not match either of two routines
		STRING(COMPARE NOTEQUAL ${FinalRoutine} "Total fo" totalflag)
		if(nameflag AND totalflag)
			STRING(STRIP ${FinalRoutine} FinalRoutine)																						#If it passes both, the ending spaces are stripped and the AHK, cmake file, and test are configured with the routines name
			configure_file(${VISTA_SOURCE_DIR}/AutoHotkey.ahk.in ${VISTA_BINARY_DIR}/Testing/${FinalRoutine}.ahk)							#Otherwise it is skipped.
			configure_file(${VISTA_SOURCE_DIR}/WinRoutine.cmake.in ${VISTA_BINARY_DIR}/Testing/${FinalRoutine}.cmake @ONLY)
			#ADD_TEST(${FinalRoutine}Test cmake -P ${VISTA_BINARY_DIR}/Testing/${FinalRoutine}.cmake)
			set_property(TEST ${FinalRoutine}Test PROPERTY FAIL_REGULAR_EXPRESSION "${FAILURE_CONDITIONS}" )								#This sets the failure property for the test.  If the strings "F -" or "W -" are detected in the output, the test is considered a failure"
		ENDIF()
	ENDFOREACH(Routines ${ListRoutines})
	ENDIF(0)
	FOREACH( Letter A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)																	#Calls the routines by the first letter of the name
	configure_file(${VISTA_SOURCE_DIR}/AutoHotkey.ahk.in ${VISTA_BINARY_DIR}/Testing/${Letter}Test.ahk)										#Configures the AHK script for testing, by replacing known variables in the .in file
	configure_file(${VISTA_SOURCE_DIR}/WinRoutine.cmake.in ${VISTA_BINARY_DIR}/Testing/${Letter}Test.cmake @ONLY)							#Configures the CMAKE testing 
	ADD_TEST(${Letter}Test cmake -P ${VISTA_BINARY_DIR}/Testing/${Letter}Test.cmake) 
	set_property(TEST ${Letter}Test PROPERTY FAIL_REGULAR_EXPRESSION "${FAILURE_CONDITIONS}" )	
	ENDFOREACH()
	return()
endif(CControl)
if(GTMPROFILE)
FIND_PROGRAM(EXPECT_EXEC NAMES expect)																										#Finds the scripting program for the Linux Based system

FIND_PATH (VISTA_ROUTINE_DIR NAMES Routines HINTS ${VISTA_SOURCE_DIR}/routines DOC "Path to the Routines folder within GT.M")				#Creates variables for the routines and globals directorys within GT.M
FIND_PATH (VISTA_GLOBALS_DIR NAMES Globals HINTS ${VISTA_SOURCE_DIR}/globals DOC " Path to the Globals folder within GT.M")

IF(BUILD_TESTING)																															# Creates the Testing/Temporary/ directories used in CTest if the option is selected 
	ENABLE_TESTING()
	INCLUDE(CTest)
ENDIF(BUILD_TESTING)

if( BUILD_REPORTS )																															# Creates the reports folder with style guides for submitting to the OSEHR journal if the option is selected.
  add_subdirectory( Reports )
  endif(BUILD_REPORTS)

file (GLOB ROUTINES ${VISTA_ROUTINE_DIR}/*.m)																								#Goes into the Routines directory and grabs all files with the extension ".m", it should find all the routines in that folder

FOREACH(ROUTINE ${ROUTINES})																												#For every value that was grabbed in the previous step
get_filename_component(RFILE ${ROUTINE} NAME_WE)																							#The files name is taken, leaving the extension behind

string(REGEX MATCH ^. CHAR1 ${RFILE})																										#This matches the first character on the files name
if(${CHAR1} STREQUAL "_")																													#An underscore ( _ ) is used as the file name's first charater to represent a routine that starst with the percent sign (%) 
	string(REGEX REPLACE ^[_] % RFILE ${RFILE})																								#This replaces the underscore in the string with a percent sign
ENDIF()

configure_file(${VISTA_SOURCE_DIR}/XINDEXscript.exp.in ${VISTA_BINARY_DIR}/Testing/${RFILE}.exp)											#Configures the Expect script with the name of the routine
configure_file(${VISTA_SOURCE_DIR}/RoutineTest.cmake.in ${VISTA_BINARY_DIR}/Testing/${RFILE}.cmake @ONLY)									#Configures the CMake file to be called by the correct test and call the correct script
ADD_TEST( ${RFILE}Test cmake -P ${VISTA_BINARY_DIR}/Testing/${RFILE}.cmake)																	#Adds the test to the list available
set_property(TEST ${RFILE}Test PROPERTY FAIL_REGULAR_EXPRESSION "${FAILURE_CONDITIONS}")																#Sets the failure conditions for the test, if either is found in the output the test is deemed to have failed.
ENDFOREACH()
configure_file(${VISTA_SOURCE_DIR}/Nightly.sh.in ${VISTA_BINARY_DIR}/Nightly.sh)
endif(GTMPROFILE)
