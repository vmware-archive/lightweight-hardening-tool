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

#
# cron and at script (will be executed by cron and at plugins)
#

source "utils/utils.sh"

WHITE_LIST_FILE=""
BACK_LIST_FILE=""
WHITE_LIST=("root")
LOG_CMP=""

usage() {
	cat << __EOF__
	--dry=		- dry or not
	--whitelist= 	- white list
	--blacklist=	- back list
	--component=	- component name
__EOF__
}

get_opts() {
	while [[ -n "${1}" ]]; do
		opt="${1}"
		val="${opt#*=}"
		shift
		case "${opt}" in
			--dry=*)
				DRY="${val}"
				;;
			--whitelist=*)
				WHITE_LIST_FILE="${val}"
				;;
			--blacklist=*)
				BACK_LIST_FILE="${val}"
				;;
			--component=*)
				LOG_CMP="${val}"
				;;
			*)
				usage
				utils.die "Wrong option"
		esac
	done
}

run_job() {
	utils.log "${LOG_CMP}" "Checking the status of the ${LOG_CMP} white list"
	if [[ -f "${WHITE_LIST_FILE}" ]]; then
		utils.log_ok "${LOG_CMP}" "${WHITE_LIST_FILE} already exists. Nothing to do"
	else
		utils.log_warning "${LOG_CMP}" "${WHITE_LIST_FILE} does not exists. Need to create"
		if ! "${DRY}"; then
			utils.log "${LOG_CMP}" "Creating ${WHITE_LIST_FILE}"
			touch "${WHITE_LIST_FILE}"

		fi
	fi

	if ! "${DRY}"; then
		utils.log "${LOG_CMP}" "Adding users to the whitelist"
		for user in "${WHITE_LIST[@]}"; do
			if ! grep -q ^${user}$ "${WHITE_LIST_FILE}"; then
				utils.log "${LOG_CMP}" "Adding user:${user} to ${WHITE_LIST_FILE}"
				echo "${user}" >> "${WHITE_LIST_FILE}"
			else
				utils.log "${LOG_CMP}" "User:${user} is already in white list. Nothing to do"
			fi
		done
	fi

	utils.log "${LOG_CMP}" "Checking if ${BACK_LIST_FILE} exists"
	if [[ -f "${BACK_LIST_FILE}" ]]; then
		utils.log_warning "${LOG_CMP}" "${BACK_LIST_FILE} exists. Need to remove"
		if ! "${DRY}"; then
			rm -f "${BACK_LIST_FILE}"
			utils.log "${LOG_CMP}" "Removed ${BACK_LIST_FILE}"
		fi
	else
		utils.log_ok "${LOG_CMP}" "${BACK_LIST_FILE} does not exists. Nothing to do"
	fi
}

main() {
	get_opts "${@}"
	run_job
}

main "${@}"
