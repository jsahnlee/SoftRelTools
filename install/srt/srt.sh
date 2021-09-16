# Edit only the following line
SRT_DIST=/tmp/fakedist

export SRT_DIST
DEFAULT_SRT_DIST=$SRT_DIST
export DEFAULT_SRT_DIST
srt_setup () {
        . `srt_environment -X "$@"`
}
PATH=$SRT_DIST/releases/boot/bin/generic:$PATH
export PATH
