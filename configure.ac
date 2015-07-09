dnl
dnl hardening -- hardening tool for Linux servers
dnl Copyright (C) 2014-2015 VMware, Inc. All Rights Reserved.
dnl
dnl Licensed under the Apache License, Version 2.0 (the "License");
dnl you may not use this file except in compliance with the License.
dnl You may obtain a copy of the License at
dnl
dnl    http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.
dnl
AC_PREREQ(2.60)

define([VERSION_MAJOR], [1])
define([VERSION_MINOR], [1])
define([VERSION_FIX], [0])
define([VERSION_NUMBER], VERSION_MAJOR[.]VERSION_MINOR[.]VERSION_FIX)
define([VERSION_SUFFIX], [_master])

AC_INIT([hardening], VERSION_NUMBER[]VERSION_SUFFIX)

PACKAGE_RPM_VERSION="VERSION_NUMBER"
PACKAGE_RPM_RELEASE="0.0.$(echo VERSION_SUFFIX | sed 's/^_//')"
AC_SUBST([PACKAGE_RPM_VERSION])
AC_SUBST([PACKAGE_RPM_RELEASE])

AC_CONFIG_AUX_DIR([.])
AC_CONFIG_MACRO_DIR([m4])

AC_USE_SYSTEM_EXTENSIONS
AM_INIT_AUTOMAKE([1.9 tar-ustar])
AC_PROG_INSTALL
AC_PROG_SED

hardeningdir="\$(pkgdatadir)"
AC_SUBST([hardeningdir])

configdir="\$(hardeningdir)/conf_files"
AC_SUBST([configdir])

pluginsdir="\$(hardeningdir)/plugins"
AC_SUBST([pluginsdir])

profilesdir="\$(hardeningdir)/profiles"
AC_SUBST([profilesdir])

utilsdir="\$(hardeningdir)/utils"
AC_SUBST([utilsdir])

AC_CONFIG_FILES([
	Makefile
	hardening.spec
	src/Makefile
	src/conf_files/Makefile
	src/utils/Makefile
	src/plugins/Makefile
	src/profiles/Makefile
])
AC_OUTPUT
