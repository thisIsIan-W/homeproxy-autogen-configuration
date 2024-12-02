#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#
#             更多模板请参考 rules_templates 文件夹下的文件！
#
# **                                                                                                **
# ****************************************************************************************************


SUBSCRIPTION_URLS=(
  # Define your subscription url(s) here.
  # The format should be: "URL#Your_proxy_server_name"
  # Note:
  #   If 'Your_proxy_server_name' includes Chinese characters, make sure to change the encoding of this file to UTF-8."

  "https://abc.xyz#airport01"
  "https://123.abc#airport02"

)


RULESET_URLS=(

  "reject_out|
  rule-set url1
  rule-set url2
  rule-set url3"

  "HongKong_common|
  rule-set url1
  rule-set url2
  rule-set url3"

  "HongKong_others|
  rule-set url1
  rule-set url2
  rule-set url3"

  "Japan_01|
  rule-set url1
  rule-set url2
  rule-set url3"

  "USA|
  rule-set url1
  rule-set url2
  rule-set url3"
  
  # ------------------ Define your list of other special rule-sets here. ------------------
  "google_ruleset01|
  rule-set url1
  rule-set url2
  rule-set url3"
  
  "google_ruleset02|
  rule-set url1
  rule-set url2
  rule-set url3"
  # ------------------ End. ------------------

  "direct_out|
  rule-set url1
  rule-set url2
  rule-set url3"

  # More...

)


DNS_SERVERS=(

  "HongKong_common_your_suffix|Your_dns_server_url"
  "HongKong_others_your_suffix|Your_dns_server_url"
  "Japan_01|Your_dns_server_url"
  "USA|Your_dns_server_url"
  "google_ruleset01|Your_dns_server_url"
  "google_ruleset02|Your_dns_server_url"

  # The first URL in the last tag of this array will be the default dns server's URL.
  # In this case, Your_dns_server_url1 will be chosen to be the one.
  "backup_servers|
  Your_dns_server_url1
  Your_dns_server_url2
  Your_dns_server_url3"
)