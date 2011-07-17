#
# List here your tests.
#

find_program(MUMPS_EXECUTABLE NAMES mumps)

add_test(Test01 ${MUMPS_EXECUTABLE}  program1.mps)
