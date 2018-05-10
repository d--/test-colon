# test-colon.sh
#
# Provides a bash function literally called 'test:' that takes a test
# description string and wraps POSIX 'test' in some pretty colors and output.

function test:() {
  local red=''
  local green=''
  local reset=''

  if [[ "${TERM}" != 'dumb' && ! -z "${TERM}" ]]; then
    readonly red="$(tput setaf 1)"
    readonly green="$(tput setaf 2)"
    readonly reset="$(tput op)"
  fi

  local -r test_text="${1}"
  local -r test_file="${BASH_SOURCE[1]}"
  local -r test_line="${BASH_LINENO[0]}"
  shift
  if test "$@"; then
    echo "${green}PASSED: ${test_text}${reset}"
    return 0
  else
    printf "${red}FAILED"
    #
    #  If we're executing this from a prompt, ${BASH_SOURCE[1]} is empty.
    #
    #  In this case, we don't care to print out the executed code because the
    #  user literally just entered it.
    #
    #  Otherwise, in order to grab the command that was executed, we spin up a
    #  second instance of bash where we'll pipe the script from the test
    #  command onward, injecting a DEBUG trap to ensure that the command never
    #  executes but that it does print.
    #
    if [[ -z "${test_file}" ]]; then
      printf "\n"
    else
      printf ": (${test_file}:${test_line})\n"
      {
        echo "trap 'printf -- \"--> \${BASH_COMMAND}\n\" && exit' DEBUG"
        tail -n +${test_line} ${test_file}
      } | /bin/bash
    fi
    echo ""
    echo "Evaluated to:"
    echo "  test $@"
    echo "${reset}"
    return 1
  fi
}

