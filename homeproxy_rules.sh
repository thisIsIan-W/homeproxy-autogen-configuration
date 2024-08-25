#!/bin/bash

. homeproxy_rules_defination.sh

TMP_HOMEPROXY_DIR="/etc/config/homeproxy"
RULESET_MIRROR_PREFIX="https://mirror.ghproxy.com"
DEFAULT_OUTBOUND="routing_node_manual_select"
FIRST_DNS_SERVER=""

add_default_config() {
  cat >"$TMP_HOMEPROXY_DIR" <<EOF

config homeproxy 'infra'
  option __warning 'DO NOT EDIT THIS SECTION, OR YOU ARE ON YOUR OWN!'
  option common_port '22,53,80,143,443,465,853,873,993,995,8080,8443,9418'
  option mixed_port '5330'
  option redirect_port '5331'
  option tproxy_port '5332'
  option dns_port '5333'
  option china_dns_port '5334'
  option tun_name 'singtun0'
  option tun_addr4 '172.19.0.1/30'
  option tun_addr6 'fdfe:dcba:9876::1/126'
  option tun_mtu '9000'
  option table_mark '100'
  option self_mark '100'
  option tproxy_mark '101'
  option tun_mark '102'

config homeproxy 'config'
  option routing_mode 'custom'
  option routing_port 'common'
  option proxy_mode 'redirect_tproxy'
  option ipv6_support '0'

config homeproxy 'experimental'
  option clash_api_port '9090'
  option clash_api_log_level 'warn'
  option clash_api_enabled '1'
  option set_dash_backend '1'
  option clash_api_secret '123456'
  option dashboard_repo 'metacubex/metacubexd'

config homeproxy 'control'
  option lan_proxy_mode 'disabled'
  list wan_proxy_ipv4_ips '91.105.192.0/23'
  list wan_proxy_ipv4_ips '91.108.4.0/22'
  list wan_proxy_ipv4_ips '91.108.8.0/22'
  list wan_proxy_ipv4_ips '91.108.16.0/22'
  list wan_proxy_ipv4_ips '91.108.12.0/22'
  list wan_proxy_ipv4_ips '91.108.20.0/22'
  list wan_proxy_ipv4_ips '91.108.56.0/22'
  list wan_proxy_ipv4_ips '149.154.160.0/20'
  list wan_proxy_ipv4_ips '185.76.151.0/24'

config homeproxy 'routing'
  option sniff_override '0'
  option default_outbound '$DEFAULT_OUTBOUND'
  option bypass_cn_traffic '0'

config homeproxy 'server'
  option enabled '0'
  option auto_firewall '0'

config routing_rule 'route_clash_direct'
  option label 'route_clash_direct'
  option enabled '1'
  option mode 'default'
  option clash_mode 'direct'
  option outbound 'direct-out'

config routing_rule 'route_clash_global'
  option label 'route_clash_global'
  option enabled '1'
  option mode 'default'
  option clash_mode 'global'
  option outbound 'routing_node_global'

config homeproxy 'subscription'
  option auto_update '0'
  option allow_insecure '0'
  option packet_encoding 'xudp'
  option update_via_proxy '0'
  option filter_nodes 'blacklist'
  list filter_keywords 'Expiration|Remaining'
EOF
}

add_dns_config() {
  local enabled_setting
  local dns_server_str=""
  local count=0

  for dns_key in "${DNS_SERVERS_MAP_KEY_ORDER[@]}"; do
    local server_count=1
    for server_url in ${DNS_SERVERS_MAP[$dns_key]}; do
      local dns_server_name="dns_server_${dns_key}_${server_count}"
      # 拿第一个server_name作为默认DNS服务器出站
      [ $count -eq 0 ] && FIRST_DNS_SERVER="$dns_server_name"

      dns_server_str+="
config dns_server '${dns_server_name}'
  option label '${dns_server_name}'
  option address '${server_url}'
  option address_resolver 'default-dns'
  option address_strategy 'ipv4_only'
  option resolve_strategy 'ipv4_only'
  option outbound '$DEFAULT_OUTBOUND'
  option enabled '1'
"
      dns_server_str+="  ${enabled_setting}"
      dns_server_str+=$'\n'
      ((count++))
      ((server_count++))
    done
  done

  printf "%s\n" "$dns_server_str" >>"$TMP_HOMEPROXY_DIR"

  # 追加默认dns规则
  local default_dns_rules="
config homeproxy 'dns'
  option dns_strategy 'ipv4_only'
  option default_server '${FIRST_DNS_SERVER}'
  option default_strategy 'ipv4_only'
  option client_subnet '1.0.1.0'

config dns_rule 'nodes_any'
  option label 'nodes_any'
  option enabled '1'
  option mode 'default'
  list outbound 'any-out'
  option server 'default-dns'

config dns_rule 'clash_direct'
  option label 'clash_direct'
  option enabled '1'
  option mode 'default'
  option clash_mode 'direct'
  option server '${FIRST_DNS_SERVER}'
  list outbound 'direct-out'

config dns_rule 'clash_global'
  option label 'clash_global'
  option enabled '1'
  option mode 'default'
  option clash_mode 'global'
  option server '${FIRST_DNS_SERVER}'
  list outbound 'routing_node_global'
"
  printf "%s\n" "$default_dns_rules" >>"$TMP_HOMEPROXY_DIR"
}

add_rules_config() {
  local config_type="$1"
  local keyword
  local template

  if [ "$config_type" = "dns" ] || [ "$config_type" = "outbound" ] || [ "$config_type" = "outbound_node" ]; then
    case "$config_type" in
      "dns")
        keyword="dns_rule"
        ;;
      "outbound")
        keyword="routing_rule"
        ;;
      "outbound_node")
        keyword="routing_node"
        ;;
    esac

    if [ "$config_type" = "outbound_node" ]; then
      template="
config routing_node 'routing_node_auto_select'
  option label '♻️ 自动选择出站'
  option node 'node_Auto_Select'
  option domain_strategy 'ipv4_only'
  option enabled '1'

config routing_node 'routing_node_global'
  option label '🌏 全局代理出站'
  option node 'node_Global'
  option domain_strategy 'ipv4_only'
  option enabled '1'

config routing_node '$DEFAULT_OUTBOUND'
  option label '✌️ 手动选择出站'
  option node 'node_Manual_Select'
  option domain_strategy 'ipv4_only'
  option enabled '1'
"
      printf "%s\n" "$template" >>"$TMP_HOMEPROXY_DIR"
    fi

    for key in ${RULESET_CONFIG_KEY_ORDER_MAP[@]}; do

      for value in ${RULESET_CONFIG_MAP[$key]}; do
        if [ "$key" = "reject_out" ]; then
          if [ "$config_type" != "outbound_node" ]; then
            printf "config %s '%s_%s_blocked'\n" "$keyword" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
            printf "  option label '%s_%s_blocked'\n" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
            printf "  option enabled '1'\n" >>"$TMP_HOMEPROXY_DIR"
            printf "  option mode 'default'\n  option server 'block-dns'\n  option outbound 'block-out'\n" >>"$TMP_HOMEPROXY_DIR"
          fi
        else
          printf "config %s '%s_%s'\n" "$keyword" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
          printf "  option label %s_%s\n" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
          printf "  option enabled '1'\n" >>"$TMP_HOMEPROXY_DIR"

          [ "$key" != "direct_out" ] && printf "  option server '%s'\n" "$FIRST_DNS_SERVER" >>"$TMP_HOMEPROXY_DIR" || printf "  option server 'direct-out'\n" >>"$TMP_HOMEPROXY_DIR"

          if [ "$config_type" = "dns" ]; then
            printf "  option mode 'default'\n  list outbound 'routing_node_%s'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
          fi

          if [ "$config_type" = "outbound" ]; then
            printf "  option outbound 'routing_node_%s'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
          fi

          if [ "$config_type" = "outbound_node" ]; then
            printf "  option domain_strategy 'ipv4_only'\n" >>"$TMP_HOMEPROXY_DIR"
            printf "  option node 'node_%s_outbound_nodes'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
          fi
        fi

        # 规则集列表放最后
        IFS=',' read -ra config_values <<<"${RULESET_CONFIG_MAP["$key"]}"
        for value in "${config_values[@]}"; do
          # DNS不追加ip类型
          if [ "$config_type" = "dns" ] && grep -q "geoip" <<<"$value"; then
            continue
          fi
          printf "  list rule_set '%s'\n" "$value" >>"$TMP_HOMEPROXY_DIR"
        done
        printf "\n" >>"$TMP_HOMEPROXY_DIR"
      done

    done
  elif [ "$config_type" = "ruleset" ]; then

    for key in ${RULESET_MAP_KEY_ORDER[@]}; do
      RULESET_CONFIG_KEY_ORDER_MAP+=("$key")
      for url in ${RULESET_MAP[$key]}; do
        # Ruleset Settings 名称中不能包含"-"
        rule_name=$(basename "$url" | cut -d. -f1 | sed 's/-/_/g')

        grep -q "geoip" <<<"$url" && rule_name="geoip_$rule_name" || {
          grep -q "geosite" <<<"$url" && rule_name="geosite_$rule_name" || rule_name+="_"$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 8)
        }

        # 存在key则追加，否则直接插入
        if [ -n "${RULESET_CONFIG_MAP["$key"]}" ]; then
          RULESET_CONFIG_MAP["$key"]="${RULESET_CONFIG_MAP["$key"]},ruleset_$rule_name"
        else
          RULESET_CONFIG_MAP["$key"]="ruleset_$rule_name"
        fi

        cat <<EOF >>"$TMP_HOMEPROXY_DIR"
config ruleset 'ruleset_${rule_name}'
  option label 'ruleset_${rule_name}'
  option enabled '1'
  option type 'remote'
  option url '${RULESET_MIRROR_PREFIX}/${url}'
  option update_interval '24h'
EOF
        local filename=$(basename "$url")
        local extension="${filename##*.}"
        if [ "$extension" = "srs" ]; then
          printf "  option format 'binary'\n\n" >>"$TMP_HOMEPROXY_DIR"
        else
          printf "  option format 'source'\n\n" >>"$TMP_HOMEPROXY_DIR"
        fi
      done
    done
  fi
}

config_map() {
  local -n array_ref=$1
  local -n map_ref=$2
  local -n map_order_ref=$3
  local entry

  for entry in "${array_ref[@]}"; do
    local key="${entry%%|*}"
    local values="${entry#*|}"
    # mapfile -t urls <<<"$values"

    map_order_ref+=("$key")
    IFS=$'\n' read -r -d '' -a urls <<<"$values"
    map_ref["$key"]="${urls[*]}"
  done
}

add_custom_nodes_config() {
  local template
  template="
config node 'node_Auto_Select'
  option label '♻️ 自动选择'
  option type 'urltest'
  option test_url 'http://cp.cloudflare.com/'
  option interval '10m'
  option idle_timeout '30m'
  option interrupt_exist_connections '1'

config node 'node_Global'
  option label '🌏 全局代理'
  option type 'selector'
  option interrupt_exist_connections '1'

config node 'node_Manual_Select'
  option label '✌️ 手动选择'
  option type 'selector'
  option interrupt_exist_connections '1'

"
  printf "%s" "$template" >>"$TMP_HOMEPROXY_DIR"

  for key in ${RULESET_MAP_KEY_ORDER[@]}; do
    # 广告、隐私等拒绝出站的规则不需要生成自定义节点
    if [ "$key" = "reject_out" ]; then
      continue
    fi

    printf "config node 'node_%s_outbound_nodes'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
    printf "  option label '%s 出站节点'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
    if [ "$key" = "direct_out" ]; then
      printf "  option type 'direct'\n" >>"$TMP_HOMEPROXY_DIR"
    else
      printf "  option type 'selector'\n  option interrupt_exist_connections '1'\n\n" >>"$TMP_HOMEPROXY_DIR"
    fi
  done
}

update_homeproxy_config() {
  : >"$TMP_HOMEPROXY_DIR" || touch "$TMP_HOMEPROXY_DIR"
  chmod +x "$TMP_HOMEPROXY_DIR"

  config_map RULESET_URLS RULESET_MAP RULESET_MAP_KEY_ORDER
  config_map DNS_SERVERS DNS_SERVERS_MAP DNS_SERVERS_MAP_KEY_ORDER

  # 默认配置
  add_default_config
  # DNS服务器
  add_dns_config

  # 规则
  add_rules_config "ruleset"
  add_rules_config "dns"
  add_rules_config "outbound"
  add_rules_config "outbound_node"

  # 自定义出站节点
  add_custom_nodes_config
}

declare -A RULESET_MAP
declare -a RULESET_MAP_KEY_ORDER
declare -A DNS_SERVERS_MAP
declare -a DNS_SERVERS_MAP_KEY_ORDER
declare -A DNS_SERVER_NAMES_MAP
declare -A RULESET_CONFIG_MAP
declare -a RULESET_CONFIG_KEY_ORDER_MAP

update_homeproxy_config
