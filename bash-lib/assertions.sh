#!/usr/bin/env bash

log() {
	if [ -n "NMT_LOG" ]; then
		echo "$1" > $out/log
	fi
	echo "$1"
}

# Always failing assertion with a message.
#
# Example:
#     fail "It should have been but it wasn't to be"
function fail() {
    echo "$1"
		log "$1"
    exit 1
}

# Asserts the non-existence of a file system path.
#
# Example:
#     assertPathNotExists foo/bar.txt
#
function assertPathNotExists() {
    if [[ -e "$1" ]]; then
        fail "Expected $1 to be missing but it exists."
    fi
		log "OK: path $1 does not exist"
}

# Asserts the existence of a file.
#
# Example:
#     assertFileExists foo/bar.txt
#
function assertFileExists() {
    if [[ ! -f "$1" ]]; then
        fail "Expected $1 to exist but it was not found."
    fi
		log "OK: file $1 does exists"
}

function assertFileIsExecutable() {
    if [[ ! -x "$1" ]]; then
        fail "Expected $1 to be executable but it was not."
    fi
		log "OK: file $1 is executable" 
}

function assertFileIsNotExecutable() {
    if [[ -x "$1" ]]; then
        fail "Expected $1 to not be executable but it was."
    fi
		log "OK: file $1 is not executable"
}

function sourceFile() {
    assertFileExists "$1"
    # shellcheck disable=SC1090
    source "$1"
}

# Asserts that the given file contains the given line of text.
#
# Example:
#     assertFileContains foo/bar.txt "this line exists"
#
function assertFileContains() {
    if ! grep -qF "$2" "$1"; then
        fail "Expected $1 to contain $2 but it did not."
    fi
		log "OK: file $1 contains $2"
}

# Asserts that the content of a file matches a given regular
# expression.
#
# Example:
#     assertFileRegex foo/bar.txt "^this line exists$"
#
function assertFileRegex() {
    if ! grep -q "$2" "$1"; then
        fail "Expected $1 to match $2 but it did not."
    fi
		log "OK: file $1 contains $2"
}

# Asserts that the content of a file does not match a given regular
# expression.
#
# Example:
#     assertFileNotRegex foo/bar.txt "^this line is missing$"
#
function assertFileNotRegex() {
    if grep -q "$2" "$1"; then
        fail "Expected $1 to not match $2 but it did."
    fi
		log "OK: file $1 does not contains $2"
}

# Asserts that the content of a file matches another file.
#
# Example:
#     assertFileCompare foo/bar.txt bar-expected.txt
function assertFileContent() {
    if ! cmp -s "$1" "$2"; then
        fail "Expected $1 to be same as $2 but were different:
$(diff -du --label actual --label expected "$1" "$2")"
    fi
		log "OK: $1 is the same as $2"
}

# Asserts the existence of a symlink.
#
# Example:
#     assertLinkExists foo/bar
#
function assertLinkExists() {
    if [[ ! -L "$1" ]]; then
        fail "Expected symlink $1 to exist but it was not found."
    fi
		log "OK: $1 is a symlink"
}

# Asserts whether a symlink points to the appropriate file.
#
# Example:
#     assertLinkPointsTo foo/bar /etc/foo
#
function assertLinkPointsTo() {
    assertLinkExists "$1"

    target="$(readlink "$1")"

    # A symlink may point to a non-existing file so there is no need
    # to check if the path exists.
    if [[ "$target" != "$2" ]]; then
        fail "Symlink $1 was supposed to point to $2, but it actually points to $target."
    fi
		log "OK: $1 points to $2"
}

# Asserts the existence of a directory.
#
# Example:
#     assertDirectoryExists foo/bar
#
function assertDirectoryExists() {
    if [[ ! -d "$1" ]]; then
        fail "Expected directory $1 to exist but it was not found."
    fi
		log "OK: directory $1 exists"
}

# Asserts that a directory exists but is empty.
#
# Example:
#     assertDirectoryEmpty foo/bar
#
function assertDirectoryEmpty() {
    assertDirectoryExists "$1"

    local content
    content="$(find "$1" -mindepth 1 -maxdepth 1 -printf '%P\n')"

    if [[ $content ]]; then
        fail "Expected directory $1 to be empty but it contains
$content"
    fi
		log "OK: directory $1 is empty"
}

# Asserts that a directory exists and is not empty.
#
# Example:
#     assertDirectoryNotEmpty foo/bar
#
function assertDirectoryNotEmpty() {
    assertDirectoryExists "$1"

    if [[ ! $(find "$1" -mindepth 1 -maxdepth 1) ]]; then
        fail "Expected directory $1 to be not empty but it was."
    fi
		log "OK: directory $1 is not empty"
}
