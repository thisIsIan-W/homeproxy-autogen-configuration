#!/bin/bash

. rules.sh

UCI_GLOBAL_CONFIG="homeproxy"
FIRST_DNS_SERVER=""
MIRROR_PREFIX_URL="https://ghp.ci"
TARGET_HOMEPROXY_CONFIG_PATH="/etc/config/homeproxy"
HOMEPROXY_CONFIG_URL="$MIRROR_PREFIX_URL/https://raw.githubusercontent.com/immortalwrt/homeproxy/master/root/etc/config/homeproxy"


gen_random_secret() {
  tr -dc 'a-zA-Z0-9' </dev/urandom | head -c $1
}

to_upper() {
  echo -e "$1" | tr "[a-z]" "[A-Z]"
}

download_original_config_file() {
  echo -n "------ Downloading the original homeproxy file from GitHub......"
  local download_count=0
  while true; do
    ((download_count++))

    if [ "$download_count" -gt 5 ]; then
      echo "ERROR: Please check the network connection. The file download link is: $HOMEPROXY_CONFIG_URL"
      echo "ERROR: Failed to download the original homeproxy file from GitHub. Exiting..."
      exit 1
    fi

    wget -qO "/tmp/homeproxy" "$HOMEPROXY_CONFIG_URL"
    if [ $? -ne 0 ]; then
      echo "Download failed, will try again after 2 seconds!(total times: 5)......"
      sleep 2
    else
      mv /tmp/homeproxy "$TARGET_HOMEPROXY_CONFIG_PATH"
      chmod +x "$TARGET_HOMEPROXY_CONFIG_PATH"
      break
    fi
  done
  echo "done!"
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

gen_unified_outbound_nodes() {

  if [ -n "${UNIFIED_OUTBOUND_NODES+x}" ] && [ ${#UNIFIED_OUTBOUND_NODES[@]} -gt 0 ]; then
    for node in "${UNIFIED_OUTBOUND_NODES[@]}"; do
      local random_str=$(gen_random_secret 3)
      local node_name="node_${node}_${random_str}"

      local node_label="${node} outbound node"
      local routing_node_name="routing_node_${node}_${random_str}"
      local routing_node_label="routing_node_${node}"

      printf "config node '%s'\n" "$node_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label '%s'\n" "$node_label" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option type 'selector'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option interrupt_exist_connections '1'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

      printf "config routing_node '%s'\n" "$routing_node_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label '%s'\n" "$routing_node_label" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option node '%s'\n" "$node_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option domain_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option enabled '1'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    done
  fi
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

gen_public_config() {
  if [ -f "$TARGET_HOMEPROXY_CONFIG_PATH" ]; then
    mv "$TARGET_HOMEPROXY_CONFIG_PATH" "$TARGET_HOMEPROXY_CONFIG_PATH.bak"
    echo "------ The file '$TARGET_HOMEPROXY_CONFIG_PATH' has been successfully backed up to ---> $TARGET_HOMEPROXY_CONFIG_PATH.bak"
  fi

  download_original_config_file

  echo -n "------ Preparing to create default and custom nodes......"
  local output_msg=$(uci get $UCI_GLOBAL_CONFIG.config 2>&1)
  if [[ "$output_msg" != *"Entry not found"* ]]; then
      $(uci delete $UCI_GLOBAL_CONFIG.config)
  fi

  [ "$AUTO_GEN_DEFAULT_NODES" = "1" ] && DEFAULT_GLOBAL_OUTBOUND="routing_node_auto_select" || DEFAULT_GLOBAL_OUTBOUND="direct-out"

  if [ "$AUTO_GEN_DEFAULT_NODES" -eq 1 ]; then
    $(uci -q batch <<-EOF >"/dev/null"
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select='routing_node'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.label='♻️ Auto_Select'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.node='node_Auto_Select'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.domain_strategy='ipv4_only'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.enabled='1'

      set $UCI_GLOBAL_CONFIG.node_Auto_Select='node'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.label='♻️ Auto_Select_outbound_node'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.type='urltest'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.test_url='http://cp.cloudflare.com'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.interval='10m'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.idle_timeout='30m'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.interrupt_exist_connections='1'
EOF
)
  fi

  # Default configuration
  $(uci -q batch <<-EOF >"/dev/null"
    set $UCI_GLOBAL_CONFIG.routing.default_outbound=$DEFAULT_GLOBAL_OUTBOUND
    set $UCI_GLOBAL_CONFIG.routing.sniff_override='0'
    set $UCI_GLOBAL_CONFIG.routing.udp_timeout='300'

    set $UCI_GLOBAL_CONFIG.config=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.config.routing_mode='custom'
    set $UCI_GLOBAL_CONFIG.config.routing_port='common'
    set $UCI_GLOBAL_CONFIG.config.proxy_mode='redirect_tproxy'
    set $UCI_GLOBAL_CONFIG.config.ipv6_support='0'

    set $UCI_GLOBAL_CONFIG.experimental=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_port='9090'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_log_level='warn'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_enabled='1'
    set $UCI_GLOBAL_CONFIG.experimental.set_dash_backend='1'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_secret=$(gen_random_secret 20)
    set $UCI_GLOBAL_CONFIG.experimental.dashboard_repo='metacubex/yacd-meta'

    delete $UCI_GLOBAL_CONFIG.nodes_domain
    delete $UCI_GLOBAL_CONFIG.dns

    set $UCI_GLOBAL_CONFIG.dns=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.dns.dns_strategy='ipv4_only'
    set $UCI_GLOBAL_CONFIG.dns.default_server='default-dns'
    set $UCI_GLOBAL_CONFIG.dns.default_strategy='ipv4_only'
    set $UCI_GLOBAL_CONFIG.dns.disable_cache='1'

    set $UCI_GLOBAL_CONFIG.route_clash_direct='routing_rule'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.label='route_clash_direct'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.enabled='1'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.mode='default'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.clash_mode='direct'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.outbound='direct-out'

    set $UCI_GLOBAL_CONFIG.route_clash_global='routing_rule'
    set $UCI_GLOBAL_CONFIG.route_clash_global.label='route_clash_global'
    set $UCI_GLOBAL_CONFIG.route_clash_global.enabled='1'
    set $UCI_GLOBAL_CONFIG.route_clash_global.mode='default'
    set $UCI_GLOBAL_CONFIG.route_clash_global.clash_mode='global'
    set $UCI_GLOBAL_CONFIG.route_clash_global.outbound='direct-out'

    set $UCI_GLOBAL_CONFIG.dns_rule_any='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.label='dns_rule_any'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_rule_any.server='default-dns'
    add_list $UCI_GLOBAL_CONFIG.dns_rule_any.outbound='any-out'

    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct.label='dns_rule_clash_direct'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct.clash_mode='direct'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_direct.server='default-dns'

    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global.label='dns_rule_clash_global'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global.clash_mode='global'
    set $UCI_GLOBAL_CONFIG.dns_rule_clash_global.server='default-dns'
EOF
)
  $(uci commit $UCI_GLOBAL_CONFIG)
  echo "done!"
}

gen_custom_nodes_config() {

  gen_unified_outbound_nodes

  for key in ${RULESET_MAP_KEY_ORDER_ARRAY[@]}; do
    # Don't have to create custom nodes for ad and privacy-focused rulesets.
    if [ "$key" = "reject_out" ] || [ "$key" = "direct_out" ]; then 
      continue
    fi

    printf "config node 'node_%s_outbound_nodes'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option label '%s outbound node'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option type 'selector'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option interrupt_exist_connections '1'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
  done
}

gen_rule_sets_config() {

  for key in ${RULESET_MAP_KEY_ORDER_ARRAY[@]}; do
    RULESET_CONFIG_KEY_ORDER_ARRAY+=("$key")
    for url in ${RULESET_MAP[$key]}; do
      local file_type=0
      # The specified URL is an absolute path, and it should point to a file that's larger than 0 and ends with either .srs or .json
      [[ -f "$url" && -s "$url" && ("$url" == *.srs || "$url" == *.json) ]] && file_type=1
      # The specified URL is a valid link
      [[ "$url" =~ ^(https?):// && ( "$url" =~ \.srs$ || "$url" =~ \.json$ ) ]] && file_type=2

      if [ "$file_type" -eq 0 ]; then
        echo "WARN --- [$url] is invalid, skipping this rule!"
        continue
      fi

      local tmp_rule_name=$(basename "$url")
      local rule_name="${tmp_rule_name%.*}"
      local rule_name_suffix="${tmp_rule_name##*.}"

      # Note that the character '-' should not be placed in the middle
      $(echo "$rule_name" | grep -q '[-.*#@!&]') && rule_name=$(echo "$rule_name" | sed 's/[-.*#@!&]/_/g')

      if { grep -q "geoip" <<<"$url" && ! grep -q "geoip" <<<"$rule_name"; } ||
         { grep -q "ip" <<<"$url" && ! grep -q "ip" <<<"$rule_name"; }; then
          rule_name="geoip_$rule_name"
      elif grep -q "geosite" <<<"$url" && ! grep -q "geosite" <<<"$rule_name"; then
          rule_name="geosite_$rule_name"
      fi

      [ -n "${RULESET_CONFIG_MAP["$key"]}" ] && \
        RULESET_CONFIG_MAP["$key"]="${RULESET_CONFIG_MAP["$key"]},$rule_name" || \
        RULESET_CONFIG_MAP["$key"]="$rule_name"

      printf "config ruleset '%s'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label '%s'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option enabled '1'\n" "$rule_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

      [ "$file_type" -eq 1 ] && {
        printf "  option type 'local'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
        printf "  option path '%s'\n" "$url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      } || {
        printf "  option type 'remote'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
        printf "  option update_interval '24h'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
        printf "  option url '%s/%s'\n" "$MIRROR_PREFIX_URL" "$url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      }

      local extension="${tmp_rule_name##*.}"
      [ "$extension" = "srs" ] && \
        printf "  option format 'binary'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" || \
        printf "  option format 'source'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
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
      if [ "$dns_server_element_count" -eq 1 ]; then
        dns_server_name="${dns_key}"
      else
        dns_server_name="${dns_key}_${server_url_count}"
      fi

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
      if [ "$key" = "reject_out" ]; then
        printf "config %s '%s_%s_blocked'\n" "$keyword" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option label '%s_%s_blocked'\n" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option enabled '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option mode 'default'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$config_type" = "outbound" ] && \
          printf "  option outbound 'block-out'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" || \
          printf "  option server 'block-dns'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      else

        local template="config ${keyword} '${keyword}_${key}'
  option label '${keyword}_${key}'
  option enabled '1'"

        if [ "$config_type" = "dns" ]; then
          local rulesets_count=0
          for value in "${config_values[@]}"; do
             grep -q "geoip" <<<"$value" || grep -q "ip" <<<"$value" && ((rulesets_count++))
          done
          # Skip if the ruleset has only one URL, and that URL is an IP-based ruleset.
          [ "$rulesets_count" -eq ${#config_values[@]} ] && continue

          local dns_key_array=("$key")
          local matched_dns_server_name=""
          for tmp_dns_server_name in "${DNS_SERVERS_MAP_KEY_ORDER_ARRAY[@]}"; do
            properly_matched_node_name=""
            match_node dns_key_array "$tmp_dns_server_name"
            [ -n "$properly_matched_node_name" ] && matched_dns_server_name="$tmp_dns_server_name" && break
          done

          if [ -n "$matched_dns_server_name" ]; then
            template+="
  option server 'dns_server_${matched_dns_server_name}'"
          else
            if [[ "$key" != "reject_out" && "$key" != "direct_out" ]]; then
              local last_dns_server_name="${DNS_SERVERS_MAP_KEY_ORDER_ARRAY[-1]}"
              local last_dns_servers_array=(${DNS_SERVERS_MAP[$last_dns_server_name]})
              local last_dns_server_element_count=${#last_dns_servers_array[@]}
              [ "$last_dns_server_element_count" -eq 1 ] && \
                template+="
  option server 'dns_server_${last_dns_server_name}'" || \
                template+="
  option server 'dns_server_${last_dns_server_name}_1'"
            fi
          fi
        fi

        printf "%s\n" "$template" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        [ "$config_type" = "outbound" ] && printf "  option outbound 'routing_node_%s'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      fi

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

gen_homeproxy_config() {
  config_map RULESET_URLS RULESET_MAP RULESET_MAP_KEY_ORDER_ARRAY
  config_map DNS_SERVERS DNS_SERVERS_MAP DNS_SERVERS_MAP_KEY_ORDER_ARRAY

  gen_public_config

  echo -n "------ Configuring custom outbound nodes..."
  gen_custom_nodes_config
  echo "done!"

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
  echo ""

  local lan_ipv4_addr
  lan_ipv4_addr=$(ubus call network.interface.lan status | grep '\"address\"\: \"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
  [ -n "$lan_ipv4_addr" ] && \
    echo -e "Script executed successfully! Please visit http://$lan_ipv4_addr/cgi-bin/luci/admin/services/homeproxy to see the difference!\n" || \
    echo -e "Script executed successfully!\n"
}

declare -A RULESET_MAP
declare -a RULESET_MAP_KEY_ORDER_ARRAY
declare -A DNS_SERVERS_MAP
declare -a DNS_SERVERS_MAP_KEY_ORDER_ARRAY
declare -A DNS_SERVER_NAMES_MAP
declare -A RULESET_CONFIG_MAP
declare -a RULESET_CONFIG_KEY_ORDER_ARRAY

AUTO_GEN_DEFAULT_NODES=1
AUTO_GEN_OTHER_NODES=2

entrance() {
  if [[ -z "${RULESET_URLS+x}" ]] || [[ "${#RULESET_URLS[@]}" -le 0 ]] || \
    [[ -z "${DNS_SERVERS+x}" ]] || [[ "${#DNS_SERVERS[@]}" -le 0 ]]; then
    echo "ERROR: Error(s) detected in rules.sh. The script will now exit!"
    exit 1
  fi

  echo ""
  echo ""
  echo "***********************************************************************"
  echo ""
  echo ""
  echo ""
  echo "      ImmortalWRT (OpenWRT) homeproxy one-click generation script.       "
  echo ""
  echo ""
  echo ""
  echo "***********************************************************************"
  echo ""
  echo "WARN: Please make sure that you have backed up the /etc/config/homeproxy file in advance!"
  echo ""
  echo ""
  echo "Do you want to generate the 'Auto_Select' node? (1 for Yes, 2 for No; please specify the remaining nodes separately in the configuration file.)"
  read -p "Type in your choice and press Enter: " AUTO_GEN_DEFAULT_NODES
  AUTO_GEN_DEFAULT_NODES=$( [ "$AUTO_GEN_DEFAULT_NODES" = "1" ] && echo "$AUTO_GEN_DEFAULT_NODES" || echo "2" )
  echo ""
}

entrance
gen_homeproxy_config