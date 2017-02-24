#!/usr/bin/env bats

set -e

source funcmod.sh

error () { echo >&2 "$@" ; return 1 ; }
cmp () { [[ $1 == $2 ]] || {
     local got=$1 expected=$2
      shift 2
       error "$@"$'\n'"     got: $got"$'\n'"expected: $expected"
        }
}

add0 () { buffer+=0; return 22; }
add1 () { buffer+=1; return 0; }
add2 () { buffer+=2; return 0; }

around1 () {
    local orig=$1
    shift

    buffer+=3
    $orig "$@" || rval=$?
    buffer+=4
    builtin return $rval
}

around2 () {
    local orig=$1
    shift

    buffer+=5
    local rval=0
    $orig "$@" || rval=$?
    buffer+=6
    builtin return $rval
}

@test "after" {

   buffer=

   after add0 add1
   after add0 add2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 012
}

@test "before" {

   buffer=

   before add0 add1
   before add0 add2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 210
}

@test "around" {

   buffer=

   around add0 around1

   around add0 around2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 53046
}

@test "before + after" {

   buffer=

   after add0 add1
   after add0 add2

   before add0 add1
   before add0 add2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 21012
}



@test "before + around" {

   buffer=

   before add0 add1
   before add0 add2

   around add0 around1

   around add0 around2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 2153046
}

@test "after + around" {

   buffer=

   after add0 add1
   after add0 add2

   around add0 around1

   around add0 around2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 5304612
}

@test "before + around + after " {

   buffer=

   before add0 add1
   before add0 add2

   around add0 around1

   around add0 around2


   after add0 add1
   after add0 add2

   add0 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 215304612
}
