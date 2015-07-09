#!/bin/bash

#
# hardening -- hardening tool for Linux servers
# Copyright (C) 2014-2015 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

utils.die() {
	local msg="${1?}"
	echo -e "\e[31mFATAL\e[39m::${msg}"
	exit 1
}

utils.create_log() {
	local log="${1?}"
	mkdir -p "${log%/*}"
	[[ -e "${log}" ]] && utils.die "Cannot create log file, ${log} already exists"
	touch "${log}"
}

utils.log() {
	local cmp="${1?}"
	local msg="${2?}"
	echo "$(date +%F:%T)::${cmp}::${msg}" >> "${LOG}"
}

utils.if_iptables_rule_exists() {
	local port="${1?}"
	local chain="${2?}"
	local protocol="${3}"

	local out="$(iptables -nvL "${chain}" | tr -s ' ' ' ' | cut -d' ' -f5,12 | grep "${protocol}.*:${port}$")"

	if [[ -n "${out}" ]]; then
		return 0
	else
		return 1
	fi
}

utils.set_input_iptables_rule() {
	local dst_port="${1?}"
	local protocol="${2?}"
	local src_ip="${3}"

	if [[ -z "${src_ip}" ]]; then
		local cmd="iptables -A INPUT -p "${protocol}" --dport "${dst_port}" -m state --state NEW -j ACCEPT"
	else
		local cmd="iptables -A INPUT -p "${protocol}" -s "${src_ip}" --dport "${dst_port}" -m state --state NEW -j ACCEPT"
	fi

	utils.log "utils" "Running ${cmd}"

	${cmd}
}

utils.set_output_iptables_rule() {
	local dst_port="${1}"
	local protocol="${2}"
	local dst_ip="${3}"

	if [[ -z "${dst_port}" \
		&& -z "${protocol}" \
		&& -z "${dst_ip}" ]]; then
		local cmd="iptables -A OUTPUT -m state --state NEW -j ACCEPT"

	elif [[ -z "${dst_port}" \
                && -z "${protocol}" ]]; then
		local cmd="iptables -A OUTPUT -d ${dst_ip} -m state --state NEW -j ACCEPT"

	elif [[ -z "${dst_ip}" ]]; then
		local cmd="iptables -A OUTPUT -p "${protocol}" --dport "${dst_port}" -m state --state NEW -j ACCEPT"
	else
		local cmd="iptables -A OUTPUT -p "${protocol}" -d "${dst_ip}" --dport "${dst_port}" -m state --state NEW -j ACCEPT"
	fi

	utils.log "utils" "Running ${cmd}"

	${cmd}
}

utils.if_setting_exists() {
	local conf_file="${1?}"
	local setting="${2?}"

	if grep -q "${setting}" "${conf_file}"; then
		return 0
	else
		return 1
	fi
}

utils.log_warning() {
	local cmp="${1?}"
	local msg="${2?}"
	echo -e "$(date +%F:%T)::${cmp}::\e[93m${msg}\e[39m" >> "${LOG}"
}

utils.log_ok() {
	local cmp="${1?}"
	local msg="${2?}"
	echo -e "$(date +%F:%T)::${cmp}::\e[92m${msg}\e[39m" >> "${LOG}"
}

utils.log_error() {
	local cmp="${1?}"
	local msg="${2?}"
	echo -e "$(date +%F:%T)::${cmp}::\e[31m${msg}\e[39m" >> "${LOG}"
}

utils.log_start_plugin() {
	local cmp="${1?}"
	local msg="Started configuration plugin:${cmp}"
	echo -e "$(date +%F:%T)::${cmp}::\e[92m${msg}\e[39m" >> "${LOG}"
}

utils.log_end_plugin() {
	local cmp="${1?}"
	local msg="Finished configuration plugin:${cmp}"
	echo -e "$(date +%F:%T)::${cmp}::\e[92m${msg}\e[39m" >> "${LOG}"
}
