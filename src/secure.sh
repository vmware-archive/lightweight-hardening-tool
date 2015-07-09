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

DATE="$(date +%Y%m%d%H%M%S)"
export LOG="/var/log/hardening/hardening_${DATE}.log"
SCRIPTS_DIR="$(dirname ${0})"

source "${SCRIPTS_DIR}/utils/utils.sh"

PROFILES_DIR="${SCRIPTS_DIR}/profiles"
PLUGINS_DIR="${SCRIPTS_DIR}/plugins"
DRY=false

usage() {
	cat << __EOF__
${0} [options]
	--profile=PROFILE_NAME					- profile you want to use (could be found under profiles/)
	--plugin={plugin1,plugin2...}				- list of plugins you want to run (ssh,dns...)
	--plugin-params="param1 param2"				- list of plugins parameters
	--profile-params={plugin_name:"param1,param2"@plugin_name:"param1,param2"}	- list of plugins parameters
	--dry							- dry run (wont change anything). Default is false
	--help|-h						- show this message
__EOF__
}

get_opts() {
	while [[ -n "${1}" ]]; do
		opt="${1}"
		val="${opt#*=}"
		shift
		case "${opt}" in
			--profile=*)
				IFS="," read -ra PROFILES <<< "${val}"
				;;
			--plugin=*)
				IFS="," read -ra PLUGINS <<< "${val}"
				;;
			--plugin-params=*)
				PLUGIN_PARAMS="${val}"
				;;
			--profile-params=*)
				PROFILE_PARAMS="${val}"
				;;
			--dry)
				DRY=true
				;;
			--help|-h)
				usage
				exit 0
				;;
			*)
				usage
				utils.die "Wrong option"
		esac
	done
}

validate() {
	[[ "${UID}" -eq 0 ]] \
		|| utils.die "You need to be root to execute this script"
}

main() {
	get_opts "${@}"
	validate
	utils.create_log "${LOG}"
	utils.log "secure" "Created log at ${LOG}"
	echo "Created log at ${LOG}"

	# running profile with profile params
	if [[ -n "${PROFILES}" \
		&& "${PROFILE_PARAMS}" ]]; then

		for profile in "${PROFILES[@]}"
		do
			[[ -f "${PROFILES_DIR}/${profile}" ]] \
				|| utils.die "Profile does not exists - ${PROFILES_DIR}/${profile}"

			sed -i -e '$a\' "${PROFILES_DIR}/${profile}"
			cat "${PROFILES_DIR}/${profile}" | while read plugin; do
				[[ -f "${PLUGINS_DIR}/${plugin}" ]] \
					|| utils.die "Plugin does not exists - ${PLUGINS_DIR}/${plugin}"

				echo "${PROFILE_PARAMS}" | grep -q "${plugin}:"
				if [[ "${PIPESTATUS[1]}" -eq 0 ]]; then
					local plugin_params="$(echo "${PROFILE_PARAMS}" \
						| awk -F"${plugin}" '{print $2}' \
						| cut -d'@' -f1 \
						| cut -d':' -f2 \
						| tr ',' ' ')"
					"${PLUGINS_DIR}/${plugin}" "${DRY}" "${plugin_params}"
				else
					"${PLUGINS_DIR}/${plugin}" "${DRY}"
				fi
			done
		done
		exit 0
	fi

	# running profile
	if [[ -n "${PROFILES}" ]]; then
		for profile in "${PROFILES[@]}"; do
			[[ -f "${PROFILES_DIR}/${profile}" ]] \
				|| utils.die "Profile does not exists - ${PROFILES_DIR}/${profile}"

			sed -i -e '$a\' "${PROFILES_DIR}/${profile}"
			cat "${PROFILES_DIR}/${profile}" | while read plugin; do
				[[ -f "${PLUGINS_DIR}/${plugin}" ]] || utils.die "Plugin does not exists - ${PLUGINS_DIR}/${plugin}"
				"${PLUGINS_DIR}/${plugin}" "${DRY}"
			done
		done
		exit 0
	fi

	# One plugin with parameters
	if [[ -n "${PLUGINS}" \
			&& "${PLUGIN_PARAMS}" ]]; then
		[[ "${#PLUGINS[@]}" -eq 1 ]] \
			|| utils.die "You cannot run multiple plugins with parameters."
		[[ -f "${PLUGINS_DIR}/${PLUGINS}" ]] \
			|| utils.die "Plugin does not exists - ${PLUGINS_DIR}/${PLUGINS}"
		"${PLUGINS_DIR}/${PLUGINS}" "${DRY}" ${PLUGIN_PARAMS}
		exit 0
	fi

	# one or more plugins without parameters
	if [[ -n "${PLUGINS}" ]]; then
		for plugin in "${PLUGINS[@]}"; do
			[[ -f "${PLUGINS_DIR}/${plugin}" ]] \
				|| utils.die "Plugin does not exists - ${PLUGINS_DIR}/${plugin}"
			"${PLUGINS_DIR}/${plugin}" "${DRY}"
		done
	fi

}

main "${@}"
