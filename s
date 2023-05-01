#!/bin/bash
: ${AGENTS:='gpg,ssh'}

if [[ -z $GPG_ID ]]; then
  echo 'WARNING: GPG_ID empty!'
  : ${EVALS:="id_ed25519 id_rsa"}
else
  : ${EVALS:="id_ed25519 id_rsa $GPG_ID"}
fi

update_id () {
  #echo blech | gpg --no-options --use-agent --no-tty --sign --local-user $GPG__ID -o- >/dev/null 2>&1
  eval $(keychain --agents $AGENTS --nogui --eval $EVALS)
}

phile_czekr () {
  if [[ $DEBUG == true ]]; then
    printf "If $1 is older than $2 minutes then run the function $3\n"
  fi
  filename=$1
  function_to_run=$3
  if [[ ! -f $filename ]]; then
    touch "$filename" 
    $function_to_run
  else
    file_age_thresh=$(date -d "now - $2 minutes" +%s)
    file_age=$(sudo date -r "$filename" +%s)

    # ...and then just use integer math:
    if (( file_age <= file_age_thresh )); then
      touch "$filename" 
      $function_to_run
    #silent output
    #else
      #echo "$filename is up to date"
    fi
  fi
}

main () {
  # iF THIS_S_TMP is a directory then use it for a temporary lockfile 
  # to prevent us from spamming keychain everytime
  # to utilize this something like this would needed to be added to an RC file:
  # export THIS_S_TMP=$(mktemp --tmpdir='/tmp' --directory --suffix '.tmp' s.$USER.XXXXXXX)
  if [[ -d $THIS_S_TMP ]]; then
    : ${S_ID_UPDATE_INTERVAL:=15}
    : ${S_ID_LOCATION:="$THIS_S_TMP/.s.$USER.lock"}
    phile_czekr "$S_ID_LOCATION" "$S_ID_UPDATE_INTERVAL" update_id
  else
    update_id
  fi
  ssh $@
}

main $@
