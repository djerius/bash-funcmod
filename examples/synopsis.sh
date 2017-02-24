 source funcmod.sh

 func () { echo "func" ; }

 bfunc () { echo "before" ; }

 afunc () { echo "after" ; }

 rfunc () {
   local orig=$1
   shift

   echo "before orig"

   # invoke original function and save return value
   local rval=0
   $orig "$@" || rval=$?

   echo "after orig"

   # return original return value
   builtin return $rval
 }


 before func bfunc
 after func afunc
 around func rfunc

 func
