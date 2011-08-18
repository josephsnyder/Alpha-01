The included files are the ones that I have configured to run the XINDEX regression test on a GT.M install of VistA.  All files, with the exception of the XINDX51Automatic.m should be placed in the folder that also contains the routine and globals folder.  

The XINDX51Automatic.m is a modified version of the original XINDX51.m, the difference lies near the end of the file.  Originally the XINDX51 has a timeout of 5 minutes (300 sec) after which the program halts itself and the routine stops running.  The file here was changed to eliminate that step of the process, it now waits 1 second and then displays the next page of output.  To properly run the testing, this automatic file needs to replace the XINDX51.m file that you have in the routines folder.  This is obviously not ideal.  We will need to fully automate an XINDEX routine while maintaining the manual version.  A completely automated version is the next step.

This program also uses the program Expect, a package available through Apt, which uses the *.exp files to execute the routine without human input.  The *.exp.in files are automatically configured during the CMake process for each routine's test.  The same goes for the *.cmake.in files which calls the .exp script.  The output of the configure steps go into the /Testing directory.  

The process was started nightly using a crontab which executes the *.sh in the binary directory.  This sets the proper environment variables to run GT.M, cd's to the binary directory and executes CTest.  The -j8 command specifies the number of tests that can be run in parallel and the -D Nightly describles what group in the dashboard the test belongs to.  This can be changed to push it to a "Continuous" or "Experimental" group.  

If not being run from the *.sh file, ensure that the GT.M environment is set explicitly.

The CTestConfigExternal.cmake is the dashboard that users without access to the Kitware Network should rename to CTestConfig.cmake and leave that in the source directory.  Internal Kitware users can use either CTestConfigInternal or -External to see a dashboard.
