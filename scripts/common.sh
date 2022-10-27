#!/bin/bash

CREDENTIALS="${HOME}/.ssh"

ensure_var()
{
    if [[ -z "${!1:-}" ]];
    then
        echo "${1} is unset"
        exit 1
    else
        echo "${1} is ${!1}"
    fi
}


