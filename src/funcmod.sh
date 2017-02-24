#!/bin/bash -u

# CLOS like modifiers for bash functions.

_FUNCMOD_VERSION () { echo .03 ; }

_FUNCMOD_proxy () {

    local funcname=$1
    local list
    local var
    local normname=$(_FUNCMOD_normalize $funcname)
    shift

    var=_FUNCMOD_before_${normname}

    if [[ ${!var:+set} == set ]]
    then

	eval "list=( \${${var}[@]} )"
	for func in "${list[@]}"; do
	    eval $func "$@"
	done
    fi

    local rval=0
    _FUNCMOD_around_${normname} $@ || rval=$?

    var=_FUNCMOD_after_${normname}

    if [[ ${!var:+set} == set ]]
    then

	eval "list=( \${${var}[@]} )"
	for func in "${list[@]}" ; do
	    eval $func "$@"
	done
    fi

    builtin return $rval
}

_FUNCMOD_copy_func () {

    local src=$1
    local dst=$2

    local definition=$(declare -f $src)
    definition=${definition/#$src/$dst}

    eval "$definition"
}

_FUNCMOD_normalize () {

    local funcname=$1
    echo ${funcname//-/_0x2D_}
}

_FUNCMOD_func_name() {

    local normame=$1
    local cntr=_FUNCMOD_cnt_${normname}

    local n=${!cntr}

    echo _FUNCMOD_${n}_${normname}
}


_FUNCMOD_install_proxy() {

    local funcname=$1 normname=$2

    local cntr=_FUNCMOD_cnt_${normname}

    [[ ${!cntr:-} != '' ]] && return

    eval "$cntr=0"
    _FUNCMOD_copy_func $funcname _FUNCMOD_around_${normname}
    eval "$funcname() { _FUNCMOD_proxy $funcname \"$@\" ; }"
}

before() {

    local -a args=( "$@" )
    local last=$(( ${#args[*]} - 1 ))
    local modifier=${args[$last]}
    unset args[$last]

    local list
    local funcname

    for funcname in ${args[*]} ; do
	normname=$(_FUNCMOD_normalize $funcname)
	_FUNCMOD_install_proxy $funcname $normname
	list=_FUNCMOD_before_${normname}
	eval "$list=( $modifier \${${list}[@]} )"
    done
}

after() {

    local -a args=( "$@" )
    local last=$(( ${#args[*]} - 1 ))
    local modifier=${args[$last]}
    unset args[$last]

    local list
    local funcname normname

    for funcname in ${args[*]} ; do
	normname=$(_FUNCMOD_normalize $funcname)
	_FUNCMOD_install_proxy $funcname $normname
	list=_FUNCMOD_after_${normname}
	eval "$list+=( $modifier )"
    done
}



around() {

    local -a args=( "$@" )
    local last=$(( ${#args[*]} - 1 ))
    local modifier=${args[$last]}
    unset args[$last]

    local list
    local funcname normname

    for funcname in ${args[*]} ; do
	normname=$(_FUNCMOD_normalize $funcname)
	_FUNCMOD_install_proxy $funcname $normname
	local cntr=_FUNCMOD_cnt_${normname}
	builtin let  ++$cntr
	local orig=$(_FUNCMOD_func_name $funcname)
	_FUNCMOD_copy_func  _FUNCMOD_around_${normname} "$orig"

	eval "_FUNCMOD_around_${normname} () { $modifier $orig \"$@\" ; }"
    done

}
