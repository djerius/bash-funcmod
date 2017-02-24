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

add-0 () {

    buffer+=0
    builtin return $1
}

add-1 () { buffer+=1; return 0; }
add-2 () { buffer+=2; return 0; }

around1 () {
    local orig=$1
    shift

    buffer+=3
    local rval=0
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

   after add-0 add-1
   after add-0 add-2

   add-0 22 && error "incorrect return value"
   cmp $? 22 "incorrect return value"

   cmp $buffer 012
}

@test "before" {

   buffer=

   before add-0 add-1
   before add-0 add-2

   add-0 23 && error "incorrect return value"
   cmp $? 23 "incorrect return value"

   cmp $buffer 210
}

@test "around" {

   buffer=

   around add-0 around1

   around add-0 around2

   add-0 24 && error "incorrect return value"
   cmp $? 24 "incorrect return value"

   cmp $buffer 53046
}

@test "before + after" {

   buffer=

   after add-0 add-1
   after add-0 add-2

   before add-0 add-1
   before add-0 add-2

   add-0 25 && error "incorrect return value"
   cmp $? 25 "incorrect return value"

   cmp $buffer 21012
}



@test "before + around" {

   buffer=

   before add-0 add-1
   before add-0 add-2

   around add-0 around1

   around add-0 around2

   add-0 26 && error "incorrect return value"
   cmp $? 26 "incorrect return value"

   cmp $buffer 2153046
}

@test "after + around" {

   buffer=

   after add-0 add-1
   after add-0 add-2

   around add-0 around1

   around add-0 around2

   add-0 27 && error "incorrect return value"
   cmp $? 27 "incorrect return value"

   cmp $buffer 5304612
}

@test "before + around + after " {

   buffer=

   before add-0 add-1
   before add-0 add-2

   around add-0 around1

   around add-0 around2


   after add-0 add-1
   after add-0 add-2

   add-0 28 && error "incorrect return value"
   cmp $? 28 "incorrect return value"

   cmp $buffer 215304612
}
