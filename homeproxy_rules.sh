#!/bin/bash
. homeproxy_rules_defination.sh

TMP_HOMEPROXY_DIR="/etc/config/homeproxy"
MIRROR_PREFIX_URL="https://mirror.ghproxy.com"
DEFAULT_HOMEPROXY_CONFIG_URL="$MIRROR_PREFIX_URL/https://raw.githubusercontent.com/immortalwrt/homeproxy/master/root/etc/config/homeproxy"

DEFAULT_OUTBOUND="routing_node_manual_select"
FIRST_DNS_SERVER=""

GLOBAL_CONFIG="homeproxy"

gen_random_secret() {
  tr -dc 'a-zA-Z0-9' </dev/urandom | head -c $1
}

download_original_config() {
  echo -e "准备从 $DEFAULT_HOMEPROXY_CONFIG_URL 下载原始 homeproxy 配置文件\n"
  local download_count=0
  while true; do
    ((download_count++))

    if [ "$download_count" -gt 5 ]; then
      echo "下载 homeproxy 配置失败，脚本执行失败，请检查网络连接！"
      exit 1
    fi

    wget -qO "/tmp/homeproxy" "$DEFAULT_HOMEPROXY_CONFIG_URL"
    if [ $? -ne 0 ]; then
      echo "第 $download_count 次尝试下载 homeproxy 配置失败(共 5 次)......"
      ((download_count++))
      sleep 1
    else
      mv /tmp/homeproxy "$TMP_HOMEPROXY_DIR"
      chmod +x "$TMP_HOMEPROXY_DIR"
      echo -e "homeproxy 配置文件下载成功，准备按照 homeproxy_rules_defination.sh 脚本内容执行修改......\n"
      break
    fi
  done
}

add_default_config() {
  if [ -f "$TMP_HOMEPROXY_DIR" ]; then
    mv "$TMP_HOMEPROXY_DIR" "$TMP_HOMEPROXY_DIR.bak"
    echo "$TMP_HOMEPROXY_DIR 文件已备份至 $TMP_HOMEPROXY_DIR.bak"
  fi

  download_original_config

  local output_msg=$(uci get $GLOBAL_CONFIG.config 2>&1)
  if [[ "$output_msg" != *"Entry not found"* ]]; then
      $(uci delete $GLOBAL_CONFIG.config)
  fi

  # Default configuration
  $(uci -q batch <<-EOF >"/dev/null"
    set $GLOBAL_CONFIG.routing.default_outbound=$DEFAULT_OUTBOUND
    set $GLOBAL_CONFIG.routing.sniff_override='0'

    set $GLOBAL_CONFIG.routing.udp_timeout='300'

    set $GLOBAL_CONFIG.config=$GLOBAL_CONFIG
    set $GLOBAL_CONFIG.config.routing_mode='custom'
    set $GLOBAL_CONFIG.config.routing_port='all'
    set $GLOBAL_CONFIG.config.proxy_mode='redirect_tproxy'
    set $GLOBAL_CONFIG.config.ipv6_support='0'

    set $GLOBAL_CONFIG.experimental=$GLOBAL_CONFIG
    set $GLOBAL_CONFIG.experimental.clash_api_port='9090'
    set $GLOBAL_CONFIG.experimental.clash_api_log_level='warn'
    set $GLOBAL_CONFIG.experimental.clash_api_enabled='1'
    set $GLOBAL_CONFIG.experimental.set_dash_backend='1'
    set $GLOBAL_CONFIG.experimental.clash_api_secret=$(gen_random_secret 20)
    set $GLOBAL_CONFIG.experimental.dashboard_repo='metacubex/metacubexd'

    delete $GLOBAL_CONFIG.nodes_domain
    delete $GLOBAL_CONFIG.dns

    set $GLOBAL_CONFIG.dns=$GLOBAL_CONFIG
    set $GLOBAL_CONFIG.dns.dns_strategy='ipv4_only'
    set $GLOBAL_CONFIG.dns.default_server=$FIRST_DNS_SERVER
    set $GLOBAL_CONFIG.dns.default_strategy='ipv4_only'
    set $GLOBAL_CONFIG.dns.client_subnet='1.0.1.0'

    set $GLOBAL_CONFIG.route_clash_direct='routing_rule'
    set $GLOBAL_CONFIG.route_clash_direct.label='route_clash_direct'
    set $GLOBAL_CONFIG.route_clash_direct.enabled='1'
    set $GLOBAL_CONFIG.route_clash_direct.mode='default'
    set $GLOBAL_CONFIG.route_clash_direct.clash_mode='direct'
    set $GLOBAL_CONFIG.route_clash_direct.outbound='direct-out'

    set $GLOBAL_CONFIG.route_clash_global='routing_rule'
    set $GLOBAL_CONFIG.route_clash_global.label='route_clash_global'
    set $GLOBAL_CONFIG.route_clash_global.enabled='1'
    set $GLOBAL_CONFIG.route_clash_global.mode='default'
    set $GLOBAL_CONFIG.route_clash_global.clash_mode='direct'
    set $GLOBAL_CONFIG.route_clash_global.outbound='routing_node_global'
    
    set $GLOBAL_CONFIG.dns_nodes_any='dns_rule'
    set $GLOBAL_CONFIG.dns_nodes_any.label='dns_nodes_any'
    set $GLOBAL_CONFIG.dns_nodes_any.enabled='1'
    set $GLOBAL_CONFIG.dns_nodes_any.mode='default'
    set $GLOBAL_CONFIG.dns_nodes_any.server='default-dns'
    add_list $GLOBAL_CONFIG.dns_nodes_any.outbound='any-out'

    set $GLOBAL_CONFIG.dns_clash_direct='dns_rule'
    set $GLOBAL_CONFIG.dns_clash_direct.label='dns_clash_direct'
    set $GLOBAL_CONFIG.dns_clash_direct.enabled='1'
    set $GLOBAL_CONFIG.dns_clash_direct.mode='default'
    set $GLOBAL_CONFIG.dns_clash_direct.clash_mode='direct'
    set $GLOBAL_CONFIG.dns_clash_direct.server=$FIRST_DNS_SERVER
    add_list $GLOBAL_CONFIG.dns_clash_direct.outbound='direct-out'

    set $GLOBAL_CONFIG.dns_clash_global='dns_rule'
    set $GLOBAL_CONFIG.dns_clash_global.label='dns_clash_global'
    set $GLOBAL_CONFIG.dns_clash_global.enabled='1'
    set $GLOBAL_CONFIG.dns_clash_global.mode='default'
    set $GLOBAL_CONFIG.dns_clash_global.clash_mode='global'
    set $GLOBAL_CONFIG.dns_clash_global.server=$FIRST_DNS_SERVER
    add_list $GLOBAL_CONFIG.dns_clash_global.outbound='routing_node_global'

    set $GLOBAL_CONFIG.routing_node_auto_select='routing_node'
    set $GLOBAL_CONFIG.routing_node_auto_select.label='♻️ 自动选择出站'
    set $GLOBAL_CONFIG.routing_node_auto_select.node='node_Auto_Select'
    set $GLOBAL_CONFIG.routing_node_auto_select.domain_strategy='ipv4_only'
    set $GLOBAL_CONFIG.routing_node_auto_select.enabled='1'

    set $GLOBAL_CONFIG.routing_node_global='routing_node'
    set $GLOBAL_CONFIG.routing_node_global.label='🌏 全局代理出站'
    set $GLOBAL_CONFIG.routing_node_global.node='node_Global'
    set $GLOBAL_CONFIG.routing_node_global.domain_strategy='ipv4_only'
    set $GLOBAL_CONFIG.routing_node_global.enabled='1'

    set $GLOBAL_CONFIG.$DEFAULT_OUTBOUND='routing_node'
    set $GLOBAL_CONFIG.$DEFAULT_OUTBOUND.label='✌️ 手动选择出站'
    set $GLOBAL_CONFIG.$DEFAULT_OUTBOUND.node='node_Manual_Select'
    set $GLOBAL_CONFIG.$DEFAULT_OUTBOUND.domain_strategy='ipv4_only'
    set $GLOBAL_CONFIG.$DEFAULT_OUTBOUND.enabled='1'

    set $GLOBAL_CONFIG.node_Auto_Select='node'
    set $GLOBAL_CONFIG.node_Auto_Select.label='♻️ 自动选择'
    set $GLOBAL_CONFIG.node_Auto_Select.type='urltest'
    set $GLOBAL_CONFIG.node_Auto_Select.test_url='http://cp.cloudflare.com'
    set $GLOBAL_CONFIG.node_Auto_Select.interval='10m'
    set $GLOBAL_CONFIG.node_Auto_Select.idle_timeout='30m'
    set $GLOBAL_CONFIG.node_Auto_Select.interrupt_exist_connections='1'

    set $GLOBAL_CONFIG.node_Global='node'
    set $GLOBAL_CONFIG.node_Global.label='🌏 全局代理'
    set $GLOBAL_CONFIG.node_Global.type='selector'
    set $GLOBAL_CONFIG.node_Global.interrupt_exist_connections='1'

    set $GLOBAL_CONFIG.node_Manual_Select='node'
    set $GLOBAL_CONFIG.node_Manual_Select.label='✌️ 手动选择'
    set $GLOBAL_CONFIG.node_Manual_Select.type='selector'
    set $GLOBAL_CONFIG.node_Manual_Select.interrupt_exist_connections='1'
EOF
)
  $(uci commit $GLOBAL_CONFIG)
}

gen_dns_config() {
  local count=0
  dns_server_str=""

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
      dns_server_str+=$'\n'
      ((count++))
      ((server_count++))
    done
  done
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

    for key in ${RULESET_CONFIG_KEY_ORDER_MAP[@]}; do
      for value in ${RULESET_CONFIG_MAP[$key]}; do
        if [ "$key" = "reject_out" ]; then
          if [ "$config_type" != "outbound_node" ]; then
            printf "config %s '%s_%s_blocked'\n" "$keyword" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
            printf "  option label '%s_%s_blocked'\n  option enabled '1'\n  option mode 'default'\n" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
            printf "  option server 'block-dns'\n  option outbound 'block-out'\n" >>"$TMP_HOMEPROXY_DIR"
          fi
        else
          printf "config %s '%s_%s'\n" "$keyword" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"
          printf "  option label %s_%s\n  option enabled '1'\n" "$keyword" "$key" >>"$TMP_HOMEPROXY_DIR"

          [ "$key" != "direct_out" ] && printf "  option server '%s'\n" "$FIRST_DNS_SERVER" >>"$TMP_HOMEPROXY_DIR" || printf "  option server 'default-dns'\n" >>"$TMP_HOMEPROXY_DIR"
          [ "$config_type" = "dns" ] && printf "  option mode 'default'\n  list outbound 'routing_node_%s'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
          [ "$config_type" = "outbound" ] &&  printf "  option outbound 'routing_node_%s'\n  option mode 'default'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
          [ "$config_type" = "outbound_node" ] && printf "  option domain_strategy 'ipv4_only'\n  option node 'node_%s_outbound_nodes'\n" "$key" >>"$TMP_HOMEPROXY_DIR"
        fi

        # 规则集列表放最后
        IFS=',' read -ra config_values <<<"${RULESET_CONFIG_MAP["$key"]}"
        for value in "${config_values[@]}"; do
          printf "  list rule_set '%s'\n" "$value" >>"$TMP_HOMEPROXY_DIR"
        done
        printf "\n" >>"$TMP_HOMEPROXY_DIR"
      done
    done

  elif [ "$config_type" = "ruleset" ]; then

    for key in ${RULESET_MAP_KEY_ORDER[@]}; do
      RULESET_CONFIG_KEY_ORDER_MAP+=("$key")
      for url in ${RULESET_MAP[$key]}; do
        local file_type=0
        [[ -f "$url" && -s "$url" && ("$url" == *.srs || "$url" == *.json) ]] && file_type=1 # json或srs文件且文件大小大于0
        [[ "$url" =~ ^(https?):// && ( "$url" =~ \.srs$ || "$url" =~ \.json$ ) ]] && file_type=2 # 合法url

        if [ "$file_type" -eq 0 ]; then
          echo "WARN --- 请确认 $url 链接或路径格式正确(若为路径则该文件必须存在且文件大小大于0)。跳过本条规则集！"
          continue
        fi

        local tmp_rule_name=$(basename "$url")
        local rule_name="${tmp_rule_name%.*}"
        if [[ "$rule_name" == *"@"* ]] || [[ "$rule_name" == *"*"* ]] || \
        [[ "$rule_name" == *"."* ]] || [[ "$rule_name" == *"#"* ]] || \
        [[ "$rule_name" == *"-"* ]]; then
          rule_name=$(echo "$rule_name" | sed 's/[@#*.-]/_/g')
        fi

        grep -q "geoip" <<<"$url" && rule_name="geoip_$rule_name" || {
          grep -q "geosite" <<<"$url" && rule_name="geosite_$rule_name" || rule_name+="_"$(gen_random_secret 5)
        }

        [ -n "${RULESET_CONFIG_MAP["$key"]}" ] && \
        RULESET_CONFIG_MAP["$key"]="${RULESET_CONFIG_MAP["$key"]},ruleset_$rule_name" || \
        RULESET_CONFIG_MAP["$key"]="ruleset_$rule_name"

        printf "config ruleset 'ruleset_%s'\n  option label 'ruleset_%s'\n  option enabled '1'\n" "$rule_name" "$rule_name" >>"$TMP_HOMEPROXY_DIR"

        [ "$file_type" -eq 1 ] && \
        printf "  option type 'local'\n  option path '%s'\n" "$url" >>"$TMP_HOMEPROXY_DIR" || \
        printf "  option type 'remote'\n  option update_interval '24h'\n  option url '%s/%s'\n" "$MIRROR_PREFIX_URL" "$url" >>"$TMP_HOMEPROXY_DIR"

        local extension="${tmp_rule_name##*.}"
        [ "$extension" = "srs" ] && \
        printf "  option format 'binary'\n\n" >>"$TMP_HOMEPROXY_DIR" || \
        printf "  option format 'source'\n\n" >>"$TMP_HOMEPROXY_DIR"
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
    map_order_ref+=("$key")
    IFS=$'\n' read -r -d '' -a urls <<<"$values"
    map_ref["$key"]="${urls[*]}"
  done
}

add_custom_nodes_config() {
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
  config_map RULESET_URLS RULESET_MAP RULESET_MAP_KEY_ORDER
  config_map DNS_SERVERS DNS_SERVERS_MAP DNS_SERVERS_MAP_KEY_ORDER

  # DNS服务器
  gen_dns_config
  # 默认配置
  add_default_config
  
  printf "%s\n" "$dns_server_str" >>"$TMP_HOMEPROXY_DIR"

  # 规则
  add_rules_config "ruleset"
  add_rules_config "dns"
  add_rules_config "outbound"
  add_rules_config "outbound_node"

  # 自定义出站节点
  add_custom_nodes_config

  local ipv4_status=$(ubus call network.interface.lan status | grep '\"address\"\: \"' | grep -oE '([0-9]{1,3}.){3}.[0-9]{1,3}' 2>/dev/null)
  [ -n "$ipv4_status" ] && echo -e "脚本执行成功，请手动刷新 http://$ipv4_status/cgi-bin/luci/admin/services/homeproxy 页面！" || echo -e "脚本执行成功！"
}

declare -A RULESET_MAP
declare -a RULESET_MAP_KEY_ORDER
declare -A DNS_SERVERS_MAP
declare -a DNS_SERVERS_MAP_KEY_ORDER
declare -A DNS_SERVER_NAMES_MAP
declare -A RULESET_CONFIG_MAP
declare -a RULESET_CONFIG_KEY_ORDER_MAP

update_homeproxy_config
