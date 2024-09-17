#!/bin/bash

. homeproxy_rules_defination.sh

UCI_GLOBAL_CONFIG="homeproxy"
FIRST_DNS_SERVER=""
TARGET_HOMEPROXY_CONFIG_PATH="/etc/config/homeproxy"
MIRROR_PREFIX_URL="https://mirror.ghproxy.com"
HOMEPROXY_CONFIG_URL="$MIRROR_PREFIX_URL/https://raw.githubusercontent.com/immortalwrt/homeproxy/master/root/etc/config/homeproxy"

# For Routing Rules -> route_clash_direct and DNS Rules -> dns_clash_direct using purpose. DO NOT change it!
DEFAULT_CLASH_DIRECT_OUTBOUND="routing_node_direct_out"

gen_random_secret() {
  tr -dc 'a-zA-Z0-9' </dev/urandom | head -c $1
}

download_original_config() {
  echo "------ 准备从 github 下载原始配置文件"
  local download_count=0
  while true; do
    ((download_count++))

    if [ "$download_count" -gt 5 ]; then
      echo "ERROR: 下载 homeproxy 配置失败，脚本退出！"
      echo "ERROR: 请检查网络连接！下载链接：$HOMEPROXY_CONFIG_URL"
      exit 1
    fi

    wget -qO "/tmp/homeproxy" "$HOMEPROXY_CONFIG_URL"
    if [ $? -ne 0 ]; then
      echo "第 $download_count 次尝试下载 homeproxy 配置失败(共 5 次)......"
      sleep 1
    else
      mv /tmp/homeproxy "$TARGET_HOMEPROXY_CONFIG_PATH"
      chmod +x "$TARGET_HOMEPROXY_CONFIG_PATH"
      break
    fi
  done
}

gen_dns_server_config() {
  local server_index=0
  for dns_key in "${DNS_SERVERS_MAP_KEY_ORDER[@]}"; do
    local server_url_count=1
    for server_url in ${DNS_SERVERS_MAP[$dns_key]}; do
      local dns_server_name="dns_server_${dns_key}_${server_url_count}"
      printf "config dns_server '%s'\n" "$dns_server_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option label '%s'\n" "$dns_server_name" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address '%s'\n" "$server_url" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address_resolver 'default-dns'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option address_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option resolve_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option outbound '%s'\n" "$DEFAULT_GLOBAL_OUTBOUND" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      printf "  option enabled '1'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      ((server_index++))
      ((server_url_count++))
    done
  done
}

gen_public_config() {
  if [ -f "$TARGET_HOMEPROXY_CONFIG_PATH" ]; then
    mv "$TARGET_HOMEPROXY_CONFIG_PATH" "$TARGET_HOMEPROXY_CONFIG_PATH.bak"
    echo "------ $TARGET_HOMEPROXY_CONFIG_PATH 文件已备份至 $TARGET_HOMEPROXY_CONFIG_PATH.bak"
  fi

  download_original_config

  echo "------ 准备生成默认节点、自定义节点"
  local output_msg=$(uci get $UCI_GLOBAL_CONFIG.config 2>&1)
  if [[ "$output_msg" != *"Entry not found"* ]]; then
      $(uci delete $UCI_GLOBAL_CONFIG.config)
  fi

  # Default configuration
  $(uci -q batch <<-EOF >"/dev/null"
    set $UCI_GLOBAL_CONFIG.routing.default_outbound=$DEFAULT_GLOBAL_OUTBOUND
    set $UCI_GLOBAL_CONFIG.routing.sniff_override='0'

    set $UCI_GLOBAL_CONFIG.routing.udp_timeout='300'

    set $UCI_GLOBAL_CONFIG.config=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.config.routing_mode='custom'
    set $UCI_GLOBAL_CONFIG.config.routing_port='all'
    set $UCI_GLOBAL_CONFIG.config.proxy_mode='redirect_tproxy'
    set $UCI_GLOBAL_CONFIG.config.ipv6_support='0'

    set $UCI_GLOBAL_CONFIG.experimental=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_port='9090'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_log_level='warn'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_enabled='1'
    set $UCI_GLOBAL_CONFIG.experimental.set_dash_backend='1'
    set $UCI_GLOBAL_CONFIG.experimental.clash_api_secret=$(gen_random_secret 20)
    set $UCI_GLOBAL_CONFIG.experimental.dashboard_repo='metacubex/metacubexd'

    delete $UCI_GLOBAL_CONFIG.nodes_domain
    delete $UCI_GLOBAL_CONFIG.dns

    set $UCI_GLOBAL_CONFIG.dns=$UCI_GLOBAL_CONFIG
    set $UCI_GLOBAL_CONFIG.dns.dns_strategy='ipv4_only'
    set $UCI_GLOBAL_CONFIG.dns.default_server=$FIRST_DNS_SERVER
    set $UCI_GLOBAL_CONFIG.dns.default_strategy='ipv4_only'

    set $UCI_GLOBAL_CONFIG.route_clash_direct='routing_rule'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.label='route_clash_direct'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.enabled='1'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.mode='default'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.clash_mode='direct'
    set $UCI_GLOBAL_CONFIG.route_clash_direct.outbound=$DEFAULT_CLASH_DIRECT_OUTBOUND

    set $UCI_GLOBAL_CONFIG.route_clash_global='routing_rule'
    set $UCI_GLOBAL_CONFIG.route_clash_global.label='route_clash_global'
    set $UCI_GLOBAL_CONFIG.route_clash_global.enabled='1'
    set $UCI_GLOBAL_CONFIG.route_clash_global.mode='default'
    set $UCI_GLOBAL_CONFIG.route_clash_global.clash_mode='global'
    set $UCI_GLOBAL_CONFIG.route_clash_global.outbound='routing_node_global'

    set $UCI_GLOBAL_CONFIG.dns_nodes_any='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_nodes_any.label='dns_nodes_any'
    set $UCI_GLOBAL_CONFIG.dns_nodes_any.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_nodes_any.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_nodes_any.server='default-dns'
    add_list $UCI_GLOBAL_CONFIG.dns_nodes_any.outbound='any-out'

    set $UCI_GLOBAL_CONFIG.dns_clash_direct='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_clash_direct.label='dns_clash_direct'
    set $UCI_GLOBAL_CONFIG.dns_clash_direct.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_clash_direct.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_clash_direct.clash_mode='direct'
    set $UCI_GLOBAL_CONFIG.dns_clash_direct.server='default-dns'

    set $UCI_GLOBAL_CONFIG.dns_clash_global='dns_rule'
    set $UCI_GLOBAL_CONFIG.dns_clash_global.label='dns_clash_global'
    set $UCI_GLOBAL_CONFIG.dns_clash_global.enabled='1'
    set $UCI_GLOBAL_CONFIG.dns_clash_global.mode='default'
    set $UCI_GLOBAL_CONFIG.dns_clash_global.clash_mode='global'
    set $UCI_GLOBAL_CONFIG.dns_clash_global.server=$FIRST_DNS_SERVER
EOF
)

  if [ "$AUTO_GEN_DEFAULT_NODES" -eq 1 ]; then
    $(uci -q batch <<-EOF >"/dev/null"
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select='routing_node'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.label='♻️ 自动选择出站'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.node='node_Auto_Select'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.domain_strategy='ipv4_only'
      set $UCI_GLOBAL_CONFIG.routing_node_auto_select.enabled='1'

      set $UCI_GLOBAL_CONFIG.routing_node_global='routing_node'
      set $UCI_GLOBAL_CONFIG.routing_node_global.label='🌏 全局代理出站'
      set $UCI_GLOBAL_CONFIG.routing_node_global.node='node_Global'
      set $UCI_GLOBAL_CONFIG.routing_node_global.domain_strategy='ipv4_only'
      set $UCI_GLOBAL_CONFIG.routing_node_global.enabled='1'

      set $UCI_GLOBAL_CONFIG.$DEFAULT_GLOBAL_OUTBOUND='routing_node'
      set $UCI_GLOBAL_CONFIG.$DEFAULT_GLOBAL_OUTBOUND.label='✌️ 手动选择出站'
      set $UCI_GLOBAL_CONFIG.$DEFAULT_GLOBAL_OUTBOUND.node='node_Manual_Select'
      set $UCI_GLOBAL_CONFIG.$DEFAULT_GLOBAL_OUTBOUND.domain_strategy='ipv4_only'
      set $UCI_GLOBAL_CONFIG.$DEFAULT_GLOBAL_OUTBOUND.enabled='1'

      set $UCI_GLOBAL_CONFIG.node_Auto_Select='node'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.label='♻️ 自动选择'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.type='urltest'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.test_url='http://cp.cloudflare.com'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.interval='10m'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.idle_timeout='30m'
      set $UCI_GLOBAL_CONFIG.node_Auto_Select.interrupt_exist_connections='1'

      set $UCI_GLOBAL_CONFIG.node_Global='node'
      set $UCI_GLOBAL_CONFIG.node_Global.label='🌏 全局代理'
      set $UCI_GLOBAL_CONFIG.node_Global.type='selector'
      set $UCI_GLOBAL_CONFIG.node_Global.interrupt_exist_connections='1'

      set $UCI_GLOBAL_CONFIG.node_Manual_Select='node'
      set $UCI_GLOBAL_CONFIG.node_Manual_Select.label='✌️ 手动选择'
      set $UCI_GLOBAL_CONFIG.node_Manual_Select.type='selector'
      set $UCI_GLOBAL_CONFIG.node_Manual_Select.interrupt_exist_connections='1'
EOF
)
  fi
  $(uci commit $UCI_GLOBAL_CONFIG)

  if [ -n "$CUSTOMIZED_NODES_STR" ]; then
    IFS='|' read -r -a customized_nodes <<< "$CUSTOMIZED_NODES_STR"
    for node in "${customized_nodes[@]}"; do
      local random_str=$(gen_random_secret 3)
      local node_name="node_${node}_${random_str}"
      local node_label="${node} 出站节点"
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

CONFIG_TYPES=("dns|dns_rule" "outbound|routing_rule" "outbound_node|routing_node")

gen_rules_config() {
  local config_type="$1"
  local keyword
  for entry in "${CONFIG_TYPES[@]}"; do
    config_type_key="${entry%%|*}"
    [ "$config_type" = "$config_type_key" ] && keyword="${entry##*|}" && break
  done

  if [ -z "$keyword" ]; then
    for key in ${RULESET_MAP_KEY_ORDER[@]}; do
      RULESET_CONFIG_KEY_ORDER_MAP+=("$key")
      for url in ${RULESET_MAP[$key]}; do
        local file_type=0
        # The specified URL is an absolute path, and it should point to a file that's larger than 0 and ends with either .srs or .json
        [[ -f "$url" && -s "$url" && ("$url" == *.srs || "$url" == *.json) ]] && file_type=1
        # The specified URL is a valid link
        [[ "$url" =~ ^(https?):// && ( "$url" =~ \.srs$ || "$url" =~ \.json$ ) ]] && file_type=2

        if [ "$file_type" -eq 0 ]; then
          echo "WARN --- 请确认 $url 链接或路径格式正确(若为路径则该文件必须存在且文件大小大于0)。跳过本条规则集！"
          continue
        fi

        local tmp_rule_name=$(basename "$url")
        local rule_name="${tmp_rule_name%.*}"
        local rule_name_suffix="${tmp_rule_name##*.}"

        # Note that the character '-' should not be placed in the middle
        $(echo "$rule_name" | grep -q '[-.*#@!&]') && rule_name=$(echo "$rule_name" | sed 's/[-.*#@!&]/_/g')
        grep -q "geoip" <<<"$url" && rule_name="geoip_$rule_name" || {
          grep -q "geosite" <<<"$url" && rule_name="geosite_$rule_name" || rule_name+="_"$(gen_random_secret 5)
        }
        echo "$tmp_rule_name 被重命名为: $rule_name.$rule_name_suffix"

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
    return 0
  fi

  for key in ${RULESET_CONFIG_KEY_ORDER_MAP[@]}; do
    for value in ${RULESET_CONFIG_MAP[$key]}; do
      if [ "$key" = "reject_out" ]; then
        [ "$config_type" = "outbound_node" ] && continue

        printf "config %s '%s_%s_blocked'\n" "$keyword" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option label '%s_%s_blocked'\n" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option enabled '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option mode 'default'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$config_type" = "outbound" ] && \
          printf "  option outbound 'block-out'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" || \
            printf "  option server 'block-dns'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      else
        printf "config %s '%s_%s'\n" "$keyword" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option label %s_%s\n" "$keyword" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
        printf "  option enabled '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$key" != "direct_out" ] && \
          printf "  option server '%s'\n" "$FIRST_DNS_SERVER" >>"$TARGET_HOMEPROXY_CONFIG_PATH" || \
            printf "  option server 'default-dns'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$config_type" = "dns" ] && printf "  option mode 'default'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$config_type" = "outbound" ] && \
          printf "  option outbound 'routing_node_%s'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
            printf "  option mode 'default'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"

        [ "$config_type" = "outbound_node" ] && \
          printf "  option domain_strategy 'ipv4_only'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
            printf "  option node 'node_%s_outbound_nodes'\n\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      fi

      [ "$config_type" = "outbound_node" ] && continue
      IFS=',' read -ra config_values <<<"${RULESET_CONFIG_MAP["$key"]}"
      for value in "${config_values[@]}"; do
        [ "$config_type" = "dns" ] && grep -q "geoip" <<<"$value" && continue
        printf "  list rule_set '%s'\n" "$value" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
      done
      printf "\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    done
  done
}

gen_custom_nodes_config() {
  for key in ${RULESET_MAP_KEY_ORDER[@]}; do
    # Don't have to create custom nodes for ad and privacy-focused rulesets.
    [ "$key" = "reject_out" ] && continue

    printf "config node 'node_%s_outbound_nodes'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option label '%s 出站节点'\n" "$key" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option type 'selector'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    printf "  option interrupt_exist_connections '1'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    [ "$key" = "direct_out" ] && {
      printf "  list order 'direct-out'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
      printf "  list order 'block-out'\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH" && \
      printf "  option default_selected 'direct-out'\n\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
    } || printf "\n" >>"$TARGET_HOMEPROXY_CONFIG_PATH"
  done
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

update_homeproxy_config() {
  config_map RULESET_URLS RULESET_MAP RULESET_MAP_KEY_ORDER
  config_map DNS_SERVERS DNS_SERVERS_MAP DNS_SERVERS_MAP_KEY_ORDER

  FIRST_DNS_SERVER="dns_server_${DNS_SERVERS_MAP_KEY_ORDER[0]}_1"

  gen_public_config

  echo "------ 生成 DNS 服务器配置"
  gen_dns_server_config

  echo "------ 根据 homeproxy_rules_defination.sh 配置文件内容生成自定义出站节点"
  gen_custom_nodes_config

  # DO NOT change the order!
  echo "------ 根据 homeproxy_rules_defination.sh 配置文件内容生成规则集、dns规则、出站、出站节点"
  gen_rules_config "ruleset"
  gen_rules_config "dns"
  gen_rules_config "outbound"
  gen_rules_config "outbound_node"
  echo ""

  local lan_ipv4_addr
  lan_ipv4_addr=$(ubus call network.interface.lan status | grep '\"address\"\: \"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
  [ -n "$lan_ipv4_addr" ] && \
    echo -e "脚本执行成功! 刷新 http://$lan_ipv4_addr/cgi-bin/luci/admin/services/homeproxy 页面查看!\n请手动在界面检查并修改出站信息!" || \
    echo -e "脚本执行成功，请手动在界面检查并修改出站信息!"
}

declare -A RULESET_MAP
declare -a RULESET_MAP_KEY_ORDER
declare -A DNS_SERVERS_MAP
declare -a DNS_SERVERS_MAP_KEY_ORDER
declare -A DNS_SERVER_NAMES_MAP
declare -A RULESET_CONFIG_MAP
declare -a RULESET_CONFIG_KEY_ORDER_MAP

AUTO_GEN_DEFAULT_NODES=1
AUTO_GEN_OTHER_NODES=2
CUSTOMIZED_NODES_STR=""

intro() {
  if [[ -z "${RULESET_URLS+x}" ]] || [[ "${#RULESET_URLS[@]}" -le 0 ]] || \
    [[ -z "${DNS_SERVERS+x}" ]] || [[ "${#DNS_SERVERS[@]}" -le 0 ]]; then
    echo "homeproxy_rules_defination.sh 中配置缺失，脚本退出"
    exit 1
  fi

  echo ""
  echo "WARN: 请提前备份 /etc/config/homeproxy 文件, 本脚本每次执行都会覆盖原有的.bak备份!"
  echo ""
  echo "是否需要生成配置文件规则集列表以外的自定义节点(按需取用, 不和规则集绑定, 且适用于懒得勾选一大堆机场节点的用户)? (1是, 2否)"
  read -p "请输入你的选择并回车: " AUTO_GEN_OTHER_NODES
  AUTO_GEN_OTHER_NODES=$( [ "$AUTO_GEN_OTHER_NODES" = "1" ] || \
    [ "$AUTO_GEN_OTHER_NODES" = "2" ] && echo "$AUTO_GEN_OTHER_NODES" || echo "2" )

  if [ "$AUTO_GEN_OTHER_NODES" = "1" ]; then
    echo ""
    echo "请输入自定义节点名(多个节点名之间使用英文半角|分隔, 仅支持英文大小写、数字及下划线, 前后不要保留空格, 不允许重复! 例如:node_x|node_y|node_z): "
    echo "(推荐使用 机场缩写_区域代码 或 规则集名称_node 或 节点缩写_node 的形式)"
    read CUSTOMIZED_NODES_STR
    IFS='|' read -r -a customized_nodes_array <<< "$CUSTOMIZED_NODES_STR"
    printf "将为你生成 【 "
    printf "%s出站节点 " "${customized_nodes_array[@]}"
    printf "】 ${#customized_nodes_array[@]} 个新的自定义节点！"
    echo ""
    echo ""
  fi

  echo "是否需要生成默认节点(自动选择/全局代理/手动选择, 不推荐生成)? (1是, 2否)"
  read -p "请输入你的选择并回车: " AUTO_GEN_DEFAULT_NODES
  AUTO_GEN_DEFAULT_NODES=$( [ "$AUTO_GEN_DEFAULT_NODES" = "1" ] || \
    [ "$AUTO_GEN_DEFAULT_NODES" = "2" ] && echo "$AUTO_GEN_DEFAULT_NODES" || echo "2" )
  echo ""
}

intro

[ "$AUTO_GEN_DEFAULT_NODES" -eq 1 ] && DEFAULT_GLOBAL_OUTBOUND="routing_node_manual_select" || DEFAULT_GLOBAL_OUTBOUND="direct-out"

update_homeproxy_config