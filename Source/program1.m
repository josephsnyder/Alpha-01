#!/usr/bin/mumps
 kill ^a
 for i=1:1:9 s ^a(i)=1
 write $data(^a(1)),!      // writes 1
 write $order(^a("")),!    // writes 1
 write $order(^a(1)),!     // writes 2
 write $order(^a(9)),!     // writes empty string

 set i=5
 for j=1:1:5 set ^a(i,j)=j

 write $data(^a(5)),!      // write 11
 write $data(^a(5,1,)),!   // write 1
 write $data(^a(5,15)),!   // write 0
