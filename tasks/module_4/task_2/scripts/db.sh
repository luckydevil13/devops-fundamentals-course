#!/usr/bin/env bash

DB="../data/users.db"

show_help() {
    echo -e "Usage: db.sh [command]\n"
    echo "add - Add user to database"
    echo "help - Show help"
    echo "backup - Creates a new file, named %date%-users.db.backup which is a copy of current users.db"
    echo "restore - Takes the last created backup file and replaces users.db with it."
    echo "find - Find a user by name"
    echo "list - Show content of the users.db ( --inverse for inverse order)"
    exit 0
}

check_db() {
    if ! [ -f "$DB" ]; then
        read -p "DB does not exist. Do you want to create a new? (y/n) " answer
        if [[ "$answer" == "y" ]]; then
            touch "$DB"
            echo "New DB created."
        else
            echo "DB not created."
            exit 1
        fi
    fi
}

list_db() {
    local n=1
    cat_or_tac='cat'
    if [ "$1" == "--inverse" ]; then
        cat_or_tac='tac'
    fi

    if [ "$2" == "--inverse" ]; then
        tac "$DB" | awk '{a[NR]=$0}END{for (i=1;i<=NR;i++) print NR-i+1": "a[i]}'
    else
        while IFS=',' read -r -a line || [[ -n "$line" ]]; do
            user="${line[0]}"
            role="${line[1]}"
            echo "$n. $user, $role"
            ((n++))
        done <"../data/users.db" | $cat_or_tac
    fi
}

back_db() {
    cp "$DB" "../data/$(date +%Y-%m-%d)-users.db.backup"
    echo "backup done"
}

restore_db() {
    backup=$(ls -t ../data/*-users.db.backup)
    if [ -n "${backup}" ]; then
        cp -f "${backup}" "../data/users.db"
        echo "${backup} has been restored."
    else
        echo "No backup file found"
    fi
}

find_users() {
    read -p "Enter usernames separated by space: " users
    arr=($users)
    for user in "${arr[@]}"; do
        echo -e "\nsearch for $user..."
        if grep -q "^$user," "$DB"; then
            grep "^$user," "$DB"
        else
            echo User not found
        fi
    done
}

add_user() {
    read -p "Enter username (latin letters only): " username
    if [[ ! "$username" =~ ^[a-zA-Z]+$ ]]; then
        echo "only latin letters allowed, exit"
        exit 1
    fi

    if grep -q "^$username," "$DB"; then
        echo $username already exists
        exit 1
    fi

    read -p "Enter role for user (latin letters only): " role
    if [[ ! "$role" =~ ^[a-zA-Z]+$ ]]; then
        echo "only latin letters allowed, exit"
        exit 1
    fi

    echo -e "$username,$role" >>$DB
    echo User added to DB
}

if [ -z "$1" ]; then
    show_help
elif [ "$1" == 'help' ]; then
    show_help
elif [ "$1" == 'list' ]; then
    check_db
    list_db "$2"
elif [ "$1" == 'backup' ]; then
    check_db
    back_db
elif [ "$1" == 'restore' ]; then
    restore_db
elif [ "$1" == 'find' ]; then
    check_db
    find_users
elif [ "$1" == 'add' ]; then
    check_db
    add_user
else
    show_help
fi
