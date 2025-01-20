#!/bin/bash
# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 thisIsIan-W

# You can change it to another available link if the existing one is not reachable.
MIRROR_PREFIX_URL="https://ghp.p3terx.com"
TARGET_HOMEPROXY_CONFIG_PATH="/etc/config/homeproxy"
HOMEPROXY_CONFIG_URL="$MIRROR_PREFIX_URL/https://raw.githubusercontent.com/immortalwrt/homeproxy/master/root/etc/config/homeproxy"

SING_BOX_REPO="SagerNet/sing-box"
SING_BOX_API_URL="https://api.github.com/repos/$SING_BOX_REPO/tags"
SING_BOX_MIRROR_API_URL="https://gh-api.p3terx.com/repos/$SING_BOX_REPO/tags"

UCI_GLOBAL_CONFIG="homeproxy"

to_upper() {
  echo -e "$1" | tr "[a-z]" "[A-Z]"
}

log_error() {
  echo -e "\e[31mERROR: ${1}\e[0m"
}

log_warn() {
  echo -e "\e[33mWARNING: ${1}\e[0m"
}

match_node() {
  local -n array_to_match=$1
  local key=$2
  local tmp_key_to_match
  properly_matched_node_name=""
  for tmp_key_to_match in "${array_to_match[@]}"; do
    local t_key=$(to_upper "$key")
    local t_key_to_match=$(to_upper "$tmp_key_to_match")
    if [[ "$t_key" == "$t_key_to_match"* ]]; then
      properly_matched_node_name="$tmp_key_to_match"
      break
    fi
  done
}

config_map() {
  local -n array_ref=$1
  local -n map_ref=$2
  local -n map_order_ref=$3
  local entry

  for entry in "${array_ref[@]}"; do
    if [[ "$entry" == *"|"* ]]; then
      local key="${entry%%|*}"
      local values="${entry#*|}"
      map_order_ref+=("$key")
      IFS=$'\n' read -r -d '' -a urls <<<"$values"
      [ "${#urls[@]}" -le 0 ] && echo "WARN: The tag [${key}] is invalid and will be skipped..." && continue
      map_ref["$key"]="${urls[*]}"
    fi
  done
}

fetch_homeproxy_config_file() {
  echo -n "------ Fetching the original homeproxy file from GitHub......"
  local download_count=0
  while true; do
    ((download_count++))

    if [ "$download_count" -gt 5 ]; then
      echo ""
      log_error "Please check the network connection. The file download link is: $HOMEPROXY_CONFIG_URL"
      log_error "Failed to fetch the homeproxy file from GitHub. Exiting..."
      exit 1
    fi

    wget -qO "/tmp/homeproxy" "$HOMEPROXY_CONFIG_URL"
    if [ $? -ne 0 ]; then
      log_warn "Operation failed, will try again after 2 seconds!(total times: 5)......"
      sleep 2
    else
      mv /tmp/homeproxy "$TARGET_HOMEPROXY_CONFIG_PATH"
      chmod +x "$TARGET_HOMEPROXY_CONFIG_PATH"
      break
    fi
  done
  echo "done!"
}

subscribe() {
  if [ -z "${SUBSCRIPTION_URLS+x}" ] || [ ${#SUBSCRIPTION_URLS[@]} -eq 0 ]; then
    return 0
  fi

  local hp_log_file="/var/run/$UCI_GLOBAL_CONFIG/$UCI_GLOBAL_CONFIG.log"
  [ -f "$hp_log_file" ] && > "$hp_log_file"

  echo -n "------ Updating subscriptions (This may take some time, please wait) ......"
  for sub_url in ${SUBSCRIPTION_URLS[@]}; do
    uci add_list $UCI_GLOBAL_CONFIG.subscription.subscription_url=$sub_url
  done
  uci commit $UCI_GLOBAL_CONFIG.subscription.subscription_url

  # Execute the subscription logics.
  local update_subscription_file_path="/etc/homeproxy/scripts/update_subscriptions.uc"
  if [ ! -f "${update_subscription_file_path}" ] || [ ! -x "${update_subscription_file_path}" ]; then
    log_warn "An issue has been detected within your homeproxy files. Reinstall the application and subsequently attempt this option again!"
    return 0
  fi

  "${update_subscription_file_path}" 2>/dev/null
  if grep -Eiq 'unsupported|Failed to fetch|Error|FATAL' "$hp_log_file"; then
    echo ""
    grep -Ei 'unsupported|Failed to fetch|Error|FATAL' "$hp_log_file" | while IFS= read -r line; do
     log_warn "$line"
    done
    echo ""
  else
    echo "done!"
  fi
}

get_last_dns_server() {
  local last_dns_server_name="${DNS_SERVERS_MAP_KEY_ORDER_ARRAY[-1]}"
  local last_dns_servers_array=(${DNS_SERVERS_MAP[$last_dns_server_name]})
  local last_dns_server_element_count=${#last_dns_servers_array[@]}
  if [ "$last_dns_server_element_count" -eq 1 ]; then
    echo -e "$last_dns_server_name"
  else
    echo -e "${last_dns_server_name}_1"
  fi
}

gen_public_config() {
  echo -n "------ Generating public config......"
  local output_msg=$(uci get $UCI_GLOBAL_CONFIG.config 2>&1)
  if [[ "$output_msg" != *"Entry not found"* ]]; then
    uci delete $UCI_GLOBAL_CONFIG.config
  fi

  # Default configuration
  uci -q batch <<-EOF >"/dev/null"
    set $UCI_GLOBAL_CONFIG.routing.default_outbound=$DEFAULT_GLOBAL_OUTBOUND
    set $UCI_GLOBAL_CONFIG.routing.sniff_override='0'
    set $UCI_GLOBAL_CONFIG.routing.udp_timeout='300'
    set $UCI_GLOBAL_CONFIG.routing.bypass_cn_traffic='0'

    set $UCI_GLOBAL_CONFIG.config=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.config.routing_mode='custom'
    set $UCI_GLOBAL_CONFIG.config.routing_port='common'
    set $UCI_GLOBAL_CONFIG.config.proxy_mode='redirect_tproxy'
    set $UCI_GLOBAL_CONFIG.config.ipv6_support='0'

    del $UCI_GLOBAL_CONFIG.nodes_domain
    del $UCI_GLOBAL_CONFIG.dns
    del $UCI_GLOBAL_CONFIG.control.wan_proxy_ipv6_ips

    set $UCI_GLOBAL_CONFIG.dns=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.dns.dns_strategy='ipv4_only'
    set $UCI_GLOBAL_CONFIG.dns.default_strategy='ipv4_only'
    set $UCI_GLOBAL_CONFIG.dns.disable_cache='1'
    set $UCI_GLOBAL_CONFIG.dns.default_server=dns_server_$(get_last_dns_server)

    set $UCI_GLOBAL_CONFIG.dns_rule_any='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.label='dns_rule_any'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.server='default-dns'
    add_list $UCI_GLOBAL_CONFIG.dns_rule_any.outbound='any-out'
EOF

  uci commit $UCI_GLOBAL_CONFIG
  echo "done!"
}

gen_rule_sets_config() {
  for key in ${RULESET_MAP_KEY_ORDER_ARRAY[@]}; do
    RULESET_CONFIG_KEY_ORDER_ARRAY+=("$key")
    for url in ${RULESET_MAP[$key]}; do
      local file_type=0
      # A Linux-based absolute path.
      [[ -f "$url" && -s "$url" && ("$url" == *.srs || "$url" == *.json) ]] && file_type=1
      # A valid link
      [[ "$url" =~ ^(https?):// && ( "$url" =~ \.srs$ || "$url" =~ \.json$ ) ]] && file_type=2
      [ "$file_type" -eq 0 ] && echo -e "\n\e[33mWARN: [$url] is invalid, skipping this rule!\e[0m" && continue

      local tmp_rule_name=$(basename "$url")
      local rule_name="${tmp_rule_name%.*}"
      local rule_name_suffix="${tmp_rule_name##*.}"

      # Note that the character '-' should not be placed in the middle
      echo "$rule_name" | grep -q '[-.*#@!&]' && {
        rule_name=$(echo "$rule_name" | sed 's/[-.*#@!&]/_/g')
      }

      if grep -q "geoip" <<<"$url" && ! grep -q "geoip" <<<"$rule_name"; then
        rule_name="geoip_${rule_name}"
      elif grep -q "ip" <<<"$url" && ! grep -q "ip" <<<"$rule_name"; then
        rule_name="geoip_${rule_name}"
      elif grep -q "geosite" <<<"$url" && ! grep -q "geosite" <<<"$rule_name"; then
        rule_name="geosite_${rule_name}"
      fi

      [ -n "${RULESET_CONFIG_MAP["$key"]}" ] && {
        RULESET_CONFIG_MAP["$key"]="${RULESET_CONFIG_MAP["$key"]},$rule_name"
      } || {
        RULESET_CONFIG_MAP["$key"]="$rule_name"
      }

      printf "config ruleset '%s'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label '%s'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option enabled '1'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      [ "$file_type" -eq 1 ] && {
        printf "  option type 'local'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option path '%s'\n" "$url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      } || {
        printf "  option type 'remote'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option update_interval '24h'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option url '%s/%s'\n" "$MIRROR_PREFIX_URL" "$url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      }
      local extension="${tmp_rule_name##*.}"
      [ "$extension" = "srs" ] && {
        printf "  option format 'binary'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      } || {
        printf "  option format 'source'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      }
    done
  done
}

gen_dns_server_config() {
  for dns_key in "${DNS_SERVERS_MAP_KEY_ORDER_ARRAY[@]}"; do
    local server_url_count=1
    local dns_servers_array=(${DNS_SERVERS_MAP[$dns_key]})
    local dns_server_element_count=${#dns_servers_array[@]}

    for server_url in ${DNS_SERVERS_MAP[$dns_key]}; do
      local dns_server_name
      [ "$dns_server_element_count" -eq 1 ] && dns_server_name="${dns_key}" || dns_server_name="${dns_key}_${server_url_count}"

      printf "config dns_server 'dns_server_%s'\n" "$dns_server_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label 'dns_server_%s'\n" "$dns_server_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address '%s'\n" "$server_url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address_resolver 'default-dns'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option resolve_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option enabled '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

      match_node RULESET_CONFIG_KEY_ORDER_ARRAY "$dns_key"
      if [ -n "$properly_matched_node_name" ]; then
        printf "  option outbound '%s'\n\n" "routing_node_$properly_matched_node_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      else
        printf "  option outbound '%s'\n\n" "$DEFAULT_GLOBAL_OUTBOUND" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      fi
      ((server_url_count++))
    done
  done
}

CONFIG_TYPES=("dns|dns_rule" "outbound|routing_rule")

match_server_for_dns_rule() {
  # Inspect the provided dns rule and look for an appropriate dns server that corresponds to it.
  local template=$1
  local dns_key_array=("$2")

  if [ "$2" = "direct_out" ]; then 
    template+="
  option server 'default-dns'"
    echo -e "$template"
    return 0
  fi

  local matched_dns_server_name=""
  for tmp_dns_server_name in "${DNS_SERVERS_MAP_KEY_ORDER_ARRAY[@]}"; do
    properly_matched_node_name=""
    match_node dns_key_array "$tmp_dns_server_name"
    [ -n "$properly_matched_node_name" ] && matched_dns_server_name="$tmp_dns_server_name" && break
  done

  if [ -n "$matched_dns_server_name" ]; then
    template+="
  option server 'dns_server_${matched_dns_server_name}'"
    echo -e "$template"
    return 0
  fi
  
  if [ "$2" != "reject_out" ]; then
    local last_dns_server=$(get_last_dns_server)
    template+="
  option server 'dns_server_$last_dns_server'"
  fi
  echo -e "$template"
}

gen_rules_config() {
  local config_type="$1"
  local keyword
  for entry in "${CONFIG_TYPES[@]}"; do
    config_type_key="${entry%%|*}"
    [ "$config_type" = "$config_type_key" ] && keyword="${entry##*|}" && break
  done

  for key in ${RULESET_CONFIG_KEY_ORDER_ARRAY[@]}; do
    for value in ${RULESET_CONFIG_MAP[$key]}; do
      IFS=',' read -ra config_values <<<"${RULESET_CONFIG_MAP["$key"]}"
      local template="config ${keyword} '${keyword}_${key}'
  option label '${keyword}_${key}'
  option enabled '1'
  option mode 'default'"

      if [ "$config_type" = "outbound" ]; then
        template+="
  option source_ip_is_private '0'
  option ip_is_private '0'
  option rule_set_ipcidr_match_source '0'"
        if [ "$key" = "direct_out" ]; then
          template+="
  option outbound 'direct-out'"
        else
          template+="
  option outbound 'routing_node_${key}'"
        fi
      fi

      if [ "$key" = "reject_out" ]; then
        template="config ${keyword} '${keyword}_${key}_blocked'
  option label '${keyword}_${key}_blocked'
  option enabled '1'
  option mode 'default'"
        if [ "$config_type" = "outbound" ]; then
          template+="
  option outbound 'block-out'
  option rule_set_ipcidr_match_source '0'
  option source_ip_is_private '0'
  option ip_is_private '0'"
        else
          template+="
  option server 'block-dns'"
        fi
      fi

      if [ "$config_type" = "dns" ]; then
        local rulesets_count=0
        for value in "${config_values[@]}"; do
          grep -q "geoip" <<<"$value" || grep -q "ip" <<<"$value" && ((rulesets_count++))
        done
        # Bypass if the ruleset has only one URL, and that URL is an IP-based ruleset.
        [ "$rulesets_count" -eq ${#config_values[@]} ] && continue
        template=$(match_server_for_dns_rule "$template" "$key")
      fi

      printf "%s\n" "$template" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      for value in "${config_values[@]}"; do
        [ "$config_type" = "dns" ] && { grep -q "geoip" <<<"$value" || grep -q "ip" <<<"$value"; } && continue
        printf "  list rule_set '%s'\n" "$value" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      done
      printf "\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    done
  done
}

gen_routing_nodes_config() {
  for key in ${RULESET_CONFIG_KEY_ORDER_ARRAY[@]}; do
    if [ "$key" = "reject_out" ] || [ "$key" = "direct_out" ]; then
      continue
    fi
    printf "config routing_node 'routing_node_%s'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option label routing_node_%s\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option enabled '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option domain_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option node 'node_%s_outbound_nodes'\n\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
  done
}

upgrade_sing_box_core() {
  [ "$UPGRADE_SING_BOX_VERSION" != "y" ] && return 0

  echo -n "------ Upgrading sing-box to the latest version (This may take some time, please wait)......"
  local arch=$(uname -m)
  case "$arch" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    armv7l | armv7) arch="armv7" ;;
    armv6l | armv6) arch="armv6" ;;
    i386 | i686) arch="386" ;;
    *) echo "" && log_warn "The ${arch} architecture is unsupported, bypassing..." ; return 1 ;;
  esac

  local response=$(curl -fs --max-time 5 "$SING_BOX_API_URL")
  local failed_msg="Failed to establish connection with the remote repository, bypassing..."
  if [ -z "$response" ]; then
    response=$(curl -fs --max-time 5 "$SING_BOX_MIRROR_API_URL")
    [ -z "$response" ] && echo "" && log_warn "$failed_msg" && return 1
  fi

  local latest_tag=$(echo "$response" | jq -r '.[].name' | head -n 1)
  [ -z "$latest_tag" ] && echo -e "$failed_msg" && return 1
  local current_version=$(sing-box version | awk 'NR==1 {print $3}')
  [[ "$current_version" == "${latest_tag#v}" ]] && echo -en "\n\e[32mYour sing-box version is up-to-date --> $latest_tag!\e[0m" && return 0

  local full_link="$MIRROR_PREFIX_URL/https://github.com/$SING_BOX_REPO/releases/download/$latest_tag/sing-box-${latest_tag#v}-linux-$arch.tar.gz"
  local file_name=$(basename "$full_link")
  curl -sL -o "$file_name" "$full_link"
  [ $? -ne 0 ] && return 1

  tar -zxf "$file_name"
  cp "${file_name%.tar.gz}"/sing-box /usr/bin/sing-box
  rm -rf "${file_name%.tar.gz}"
  rm "$file_name"
  chmod +x /usr/bin/sing-box

  echo -e "done! \e[32mSing-box is upgraded to $latest_tag.\e[0m"
}

get_dedicated_configuration() {
  if [ -z "$DEDICATED_RULES_LINK" ]; then
    log_error "Missing configuration link, exiting..."
    exit 1
  fi

  DECICATED_RULES=$(curl -kfsSl --max-time 5 "$DEDICATED_RULES_LINK")
  if [ $? -ne 0 ]; then
    DECICATED_RULES=$(curl -kfsSl --max-time 5 "$MIRROR_PREFIX_URL/$DEDICATED_RULES_LINK")
    if [ $? -ne 0 ]; then
      echo "Failed to download the script from $DEDICATED_RULES_LINK"
      exit 1
    fi
  fi

  eval "$DECICATED_RULES"
}

gen_homeproxy_config() {
  get_dedicated_configuration

  config_map RULESET_URLS RULESET_MAP RULESET_MAP_KEY_ORDER_ARRAY
  config_map DNS_SERVERS DNS_SERVERS_MAP DNS_SERVERS_MAP_KEY_ORDER_ARRAY

  upgrade_sing_box_core
  echo ""

  if [ -f "$TARGET_HOMEPROXY_CONFIG_PATH" ]; then
    mv "$TARGET_HOMEPROXY_CONFIG_PATH" "$TARGET_HOMEPROXY_CONFIG_PATH.bak"
    echo -e "------ The file '$TARGET_HOMEPROXY_CONFIG_PATH' is backed up to ---> \e[32m$TARGET_HOMEPROXY_CONFIG_PATH.bak\e[0m"
  fi

  # Use the standard homeproxy configuration template as a guarantee.
  fetch_homeproxy_config_file
  # Pull all nodes from the subscription servers if specified.
  subscribe
  gen_public_config

  echo -n "------ Configuring rule sets..."
  gen_rule_sets_config
  echo "done!"

  echo -n "------ Configuring DNS servers..."
  gen_dns_server_config
  echo "done!"

  echo -n "------ Configuring DNS rules and routing rules..."
  gen_rules_config "dns"
  gen_rules_config "outbound"
  echo "done!"

  echo -n "------ Configuring routing nodes..."
  gen_routing_nodes_config
  echo "done!"
  
  local lan_ipv4_addr
  lan_ipv4_addr=$(ubus call network.interface.lan status | grep '\"address\"\: \"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
  [ -n "$lan_ipv4_addr" ] && {
    echo -e "\nThe execution of the script has finished ---> https://$lan_ipv4_addr/cgi-bin/luci/admin/services/homeproxy\n"
  } || echo -e "\nThe execution of the script has finished!\n"
}

entrance() {
  if [[ -z "${RULESET_URLS+x}" ]] || [[ "${#RULESET_URLS[@]}" -le 0 ]]; then
    log_error "The RULESET_URLS array wasn't found in the 'rules.sh' file, or it contains no valid elements at all. ARE YOU KIDDING ME?"
    log_error "Exiting..."
    exit 1
  fi
  if [[ -z "${DNS_SERVERS+x}" ]] || [[ "${#DNS_SERVERS[@]}" -le 0 ]]; then
    log_error "The DNS_SERVERS array wasn't found in the 'rules.sh' file, or it contains no valid elements at all. ARE YOU KIDDING ME?"
    log_error "Exiting..."
    exit 1
  fi

  echo ""
  echo ""
  echo -e "\e[32m*******************************************************************************************"
  echo ""
  echo ""
  echo ""
  echo ""
  echo "    A portable script to auto-generate homeproxy interface configuration transparently."
  echo ""
  echo ""
  echo ""
  echo ""
  echo -e "*******************************************************************************************\e[0m"
  echo ""
  log_warn "Please make sure that you have backed up the /etc/config/homeproxy file in advance!"
  log_warn "Running the script will overwrite the backup file from the previous execution."
  echo ""
  echo ""
  read -p "Please provide the link to your dedicated configuration file: " DEDICATED_RULES_LINK
  read -p "Do you want to upgrade the sing-box to the latest version? (y/n): " UPGRADE_SING_BOX_VERSION
  echo ""
  
  UPGRADE_SING_BOX_VERSION=$( [ "$UPGRADE_SING_BOX_VERSION" == "y" ] && echo "$UPGRADE_SING_BOX_VERSION" || echo "n" )
}

. rules.sh

declare -A RULESET_MAP
declare -a RULESET_MAP_KEY_ORDER_ARRAY
declare -A DNS_SERVERS_MAP
declare -a DNS_SERVERS_MAP_KEY_ORDER_ARRAY
declare -A DNS_SERVER_NAMES_MAP
declare -A RULESET_CONFIG_MAP
declare -a RULESET_CONFIG_KEY_ORDER_ARRAY

DEFAULT_GLOBAL_OUTBOUND="direct-out"
UPGRADE_SING_BOX_VERSION="y"
DEDICATED_RULES_LINK=""
DECICATED_RULES=""

entrance
gen_homeproxy_config
