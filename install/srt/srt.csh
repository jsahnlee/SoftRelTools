# Edit only the following line
setenv SRT_DIST /tmp/fakedist

setenv DEFAULT_SRT_DIST $SRT_DIST
alias srt_setup source '`srt_environment -X -c \!*`'
setenv PATH $SRT_DIST/releases/boot/bin/generic:$PATH
