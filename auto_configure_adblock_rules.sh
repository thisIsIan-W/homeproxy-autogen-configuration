#!/bin/bash


#
# ************************************************************************************************
# 
# 
# 从 AdGuard 官网或其它渠道下载去广告规则到本地，并定时自动转换其为 sing-box 适配的 .srs 文件
# 
# 使用方式：
# 1. 上传脚本到你的设备上，目录随意；
# 2. 类 OpenWRT 系统可在 '系统(System) -> 启动项(Startup) -> 本地启动项(Local Startup)' 功能中添加以下代码(注意 & 符号不可删除！)：
#    bash /your_path/adblock_rules_update.sh &
# 3. 你也可以在每次系统重启后直接在控制台中输入 bash /your_path/adblock_rules_update.sh & 来启动此脚本
# 4. 除规URL(s)外，其余内容均不需要手动修改，除非你了解自己在做什么
#
#
# ************************************************************************************************
#

# Define your rule URL(s).
URLS=(
  "https://ghp.ci/https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt"
  "https://ghp.ci/https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt"
  # And more...
)

# Directory for downloaded files.
DEST_DIR="/etc/homeproxy/ruleset"
# The output file name for the combined rule files.
SRS_OUTPUT_FILE="${DEST_DIR}/adblockdns.srs"
# Time interval indicating how often the script should execute. By default, it's set to 8 hours(seconds).
INTERVAL=28800
# INTERVAL=$((60*60*8))
# Time limit for each execution, with a default of 10 minutes(seconds).
TIME_LIMIT_FOR_EXECUTION=600


# 
# Start ------ DO NOT change it or you are on your own!
#
TXT_TEMP_OUTPUT_FILE="${DEST_DIR}/adblock.txt"
SRS_TMP_OUTPUT_FILE="${DEST_DIR}/adblockdns_tmp.srs"
#
# End ------ DO NOT change it or you are on your own!
# 


write_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $*" >>"$DEST_DIR"/convert.log
}

write_error_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $*" >>"$DEST_DIR"/convert.log
}

download_rules() {
  start_time=$(date +%s)
  
  for url in ${URLS[@]}; do
    tmp_name=$(basename "$url")  
    
    while true; do
      current_time=$(date +%s)
      elapsed_time=$((current_time - start_time))
      
      if [ $elapsed_time -ge $TIME_LIMIT_FOR_EXECUTION ]; then
        write_error_log "The download has exceeded 10 minutes, terminating the entire loop"
        break
      fi
    
      sleep 5
      wget -O "$DEST_DIR/$tmp_name" "$url"
      
      if [ $? -ne 0 ]; then
        write_error_log "[$tmp_name] --> Download failed, awaiting the next attempt..."
        continue
      fi
      
      write_log "File [$tmp_name] has been successfully downloaded to the local system!"
      
      cat "$DEST_DIR/$tmp_name" >>"$TXT_TEMP_OUTPUT_FILE"
      rm "$DEST_DIR/$tmp_name"
      break
    done
  done
}

convert_rules() {
  # Make sure that the sing-box service has been installed on your system.
  sing-box rule-set convert --type adguard --output "$SRS_TMP_OUTPUT_FILE" "$TXT_TEMP_OUTPUT_FILE" >>"$DEST_DIR"/convert.log 2>&1
  rm "$TXT_TEMP_OUTPUT_FILE"
  mv "$SRS_TMP_OUTPUT_FILE" "$SRS_OUTPUT_FILE"
  write_log "The download and conversion process has been successfully completed!"
}


download_and_convert() {
  while true; do
    sing_start_status=$(ps -efw | grep '/usr/bin/sing-box run --config' | grep -v 'grep' | awk '{print $1}')  
    
    if [ -n "$sing_start_status" ] && [ "$sing_start_status" -gt 0 ]; then
      # Wait for the sing-box service to start completely or the downloading process may take too long.
      sleep 5
            
      begin_time=$(date +%s)
      
      download_rules
      convert_rules
      /etc/init.d/homeproxy restart
      
      end_time=$(date +%s)
      write_log "Time cost: $((end_time - begin_time)) seconds.\n\n\n"
      
      sleep "$INTERVAL"
    else
      write_error_log "Sing-box service is not running at the moment. Waiting 10 seconds before retrying!"
      sleep 10
    fi
  done
}

download_and_convert