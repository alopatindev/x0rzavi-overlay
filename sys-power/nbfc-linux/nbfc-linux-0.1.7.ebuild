# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info systemd

DESCRIPTION="NoteBook FanControl ported to Linux"
HOMEPAGE="https://github.com/nbfc-linux/nbfc-linux"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="main"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/nbfc-linux/${PN}.git"
else
	RESTRICT="mirror"
	SRC_URI="https://github.com/nbfc-linux/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="zsh-completion bash-completion fish-completion"

DEPEND="sys-apps/dmidecode"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

CONFIG_CHECK="
	ACPI_EC_DEBUGFS 
	~HWMON 
	X86_MSR
"
WARNING_HWMON="No hardware monitoring support detected!
			   nbfc-linux can not function without temperature
			   monitoring"

PATCHES="${FILESDIR}/${PN}-9999-Makefile-Dont-strip.patch"

src_compile() {
	emake PREFIX=/usr confdir=/etc sysddir=/lib/systemd/system DESTDIR="${D}"
}

src_install() {
	emake PREFIX=/usr confdir=/etc sysddir=/lib/systemd/system DESTDIR="${D}" install-c
	if ! use zsh-completion ; then
		rm -rf ${D}/usr/share/zsh || die "Removing unnecessary completions failed!"
	fi
	if ! use bash-completion ; then
		rm -rf ${D}/usr/share/bash-completion || die "Removing unnecessary completions failed!"
	fi
	if ! use fish-completion ; then
		rm -rf ${D}/usr/share/fish || die "Removing unnecessary completions failed!"
	fi
	einstalldocs
	newinitd ${FILESDIR}/nbfc_service.initd nbfc_service
}

pkg_postinst() {
	elog "nbfc-linux requires to monitor temperature sensors."
	elog "Ensure that there is proper support."
	elog " "
	elog "If you wish nbfc_service to get started on boot," 
	elog "use 'sudo systemctl enable nbfc_service' for systemd or"
	elog "use 'sudo rc-update add nbfc_service default' for openrc"
}
