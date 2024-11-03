#!/bin/bash


#
# ************************************************************************************************
# 
# 
# 从 AdGuard 官网或其它渠道下载去广告规则到本地，并定时自动转换其为 sing-box 适配的 .srs 文件
# 
# 使用方式：
# 1. 上传脚本到你的设备上，目录随意，然后 'chmod +x auto_configure_adblock_rules.sh'；
# 2. 启动 sing-box 服务；
# 3. 类 OpenWRT 系统可在 '系统(System) -> 启动项(Startup) -> 本地启动项(Local Startup)' 功能中添加以下代码(注意 & 符号不可删除！)：
#    bash /your_path/auto_configure_adblock_rules.sh &
# 4. 你也可以在每次系统重启后直接在控制台中输入 bash /your_path/auto_configure_adblock_rules.sh & 并回车来启动此脚本
# 5. URLS 中定义原始规则集链接。如果无法正常下载，可以在每条链接前加入 "https://ghp.ci/" 前缀
# 6. INTERVAL 值为每次更新、合并并导出规则集的时间间隔，默认8小时(单位秒)
#
# 确保你提供的 URL(s) 无误且网络正常！
# 任何一条 URL 下载失败且重试次数超出时间限制(默认5分钟)就会中止后续下载、合并文件的过程，并等待 INTERVAL 秒后再次尝试从头下载！
#
#
# ************************************************************************************************
#

# Define your rule URL(s).
URLS=(
  "https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt"

  # And more...
)
# Time interval indicating how often the script should execute. By default, it's set to 8 hours(Unit: seconds).
# INTERVAL=28800
INTERVAL=30
# Specify the directory in which the rule-set file will be downloaded to the system.
DEST_DIR="/etc/homeproxy/ruleset"
# The output file name for the combined rule-set files.
SRS_OUTPUT_FILE="${DEST_DIR}/adblockdns.srs"
# Time limit for each execution, with a default of 5 minutes(seconds).
TIME_LIMIT_PER_EXECUTION=300
MAX_LOG_FILE_SIZE_KB=1024


write_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $*" >>"$DEST_DIR"/convert.log
}

write_error_log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $*" >>"$DEST_DIR"/convert.log
}

truncate_log_file() {
  [ -f "$DEST_DIR"/convert.log ] && \
    local file_size_kb=$(du -k "$DEST_DIR"/convert.log | cut -f1) && \
    [ "$file_size_kb" -gt "$MAX_LOG_FILE_SIZE_KB" ] && echo -n "" > "$DEST_DIR"/convert.log
}

download_rules() {
  start_time=$(date +%s)
  
  for url in ${URLS[@]}; do
    tmp_name=$(basename "$url")
    
    while true; do
      current_time=$(date +%s)
      elapsed_time=$((current_time - start_time))
      
      if [ $elapsed_time -ge $TIME_LIMIT_PER_EXECUTION ]; then
        write_error_log "The download has exceeded $TIME_LIMIT_PER_EXECUTION seconds, and the next downloading process will be launched after $INTERVAL seconds."
        sleep "$INTERVAL"
        return 1
      fi
    
      wget -O "$DEST_DIR/$tmp_name" "$url" >>"$DEST_DIR"/convert.log 2>&1
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
      sleep 3

      begin_time=$(date +%s)
      
      truncate_log_file
      download_rules
      [ $? -gt 0 ] && continue

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


TXT_TEMP_OUTPUT_FILE="${DEST_DIR}/adblock.txt"
SRS_TMP_OUTPUT_FILE="${DEST_DIR}/adblockdns_tmp.srs"

download_and_convert