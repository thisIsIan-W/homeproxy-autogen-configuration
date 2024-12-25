#!/bin/bash


# Note: This operation will consume a large quantity of CPU resources!

###
MIRROR_PREFIX="https://ghgo.xyz"
AUTO_UPDATE_TIME="0 4 * * *"
URLS=(
  # Only GitHub links are supported for now.
  "https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt"
  "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/refs/heads/master/anti-ad-adguard.txt"

  # More...
)
###

DEST_DIR="/etc/homeproxy/ruleset"
LOG_FILE_PATH="${DEST_DIR}/convert.log"
SRS_OUTPUT_FILE_PATH="${DEST_DIR}/adblockdns.srs"
TIME_LIMIT_PER_EXECUTION=300
MAX_LOG_FILE_SIZE_KB=1024

write_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $*" >>"$LOG_FILE_PATH"
}

write_error_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $*" >>"$LOG_FILE_PATH"
}

gen_random_secret() {
  tr -dc 'a-zA-Z0-9_' </dev/urandom | head -c $1
}

truncate_log_file() {
  [ -f "$LOG_FILE_PATH" ] && \
    local file_size_kb=$(du -k "$LOG_FILE_PATH" | cut -f1) && \
    [ "$file_size_kb" -gt "$MAX_LOG_FILE_SIZE_KB" ] && > "$LOG_FILE_PATH"
}

fetch_rule_raw_files() {
  start_time=$(date +%s)
  
  for url in ${URLS[@]}; do
    tmp_name=$(gen_random_secret 15)"_"$(basename "$url")
    
    while true; do
      current_time=$(date +%s)
      elapsed_time=$((current_time - start_time))
      
      if [ $elapsed_time -ge $TIME_LIMIT_PER_EXECUTION ]; then
        write_error_log "The download has exceeded $TIME_LIMIT_PER_EXECUTION seconds, exiting..."
        DOWNLOAD_PROCESS_STOPPED=1
        return 1
      fi
    
      curl -sL -o "$DEST_DIR/$tmp_name" "$MIRROR_PREFIX"/"$url" >> "$LOG_FILE_PATH" 2>&1
      if [ $? -ne 0 ]; then
        write_error_log "[$tmp_name] --> Download failed, awaiting the next attempt..."
        continue
      fi
      
      write_log "File [$tmp_name] is successfully downloaded to the local system!"
      cat "$DEST_DIR/$tmp_name" >>"$TXT_TEMP_OUTPUT_FILE"
      rm "$DEST_DIR/$tmp_name"
      break
    done
  done
}

convert_rules() {
  # Make sure that the sing-box service has been installed on your system.
  sing-box rule-set convert --type adguard --output "$SRS_TMP_OUTPUT_FILE" "$TXT_TEMP_OUTPUT_FILE" >/dev/null 2>&1
  rm "$TXT_TEMP_OUTPUT_FILE"
  mv "$SRS_TMP_OUTPUT_FILE" "$SRS_OUTPUT_FILE_PATH"
  write_log "The download and conversion process is completed!"
}

register_crontab() {
  sed -i "/adblock_rules_update/d" "/etc/crontabs/root" 2>"/dev/null"
  echo -e "$AUTO_UPDATE_TIME cd '/etc/home''proxy' && bash adblock_rules_update.sh" >> "/etc/crontabs/root"
  /etc/init.d/cron restart >"/dev/null" 2>&1
}

entrance() {
  sleep 5
  DOWNLOAD_PROCESS_STOPPED=0

  begin_time=$(date +%s)
  
  truncate_log_file
  fetch_rule_raw_files
  [ "$DOWNLOAD_PROCESS_STOPPED" -eq 1 ] && exit 1
  convert_rules
  
  end_time=$(date +%s)
  write_log "Time cost: $((end_time - begin_time)) seconds.\n\n\n"
}

TXT_TEMP_OUTPUT_FILE="${DEST_DIR}/adblock.txt"
SRS_TMP_OUTPUT_FILE="${DEST_DIR}/adblockdns_tmp.srs"

register_crontab
entrance