# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="${P/_/-}"

if [[ ${PV} == *9999 ]]; then
	inherit autotools git-r3
	EGIT_REPO_URI="https://github.com/audacious-media-player/audacious.git"
else
	SRC_URI="https://distfiles.audacious-media-player.org/${MY_P}.tar.bz2"
	KEYWORDS="~amd64 ~x86"
fi
inherit gnome2-utils xdg-utils

DESCRIPTION="Lightweight and versatile audio player"
HOMEPAGE="https://audacious-media-player.org/"
SRC_URI+=" mirror://gentoo/gentoo_ice-xmms-0.2.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
IUSE="nls qt5"

RDEPEND="
	>=dev-libs/dbus-glib-0.60
	>=dev-libs/glib-2.28
	>=x11-libs/cairo-1.2.6
	>=x11-libs/pango-1.8.0
	virtual/freedesktop-icon-theme
	!qt5? ( x11-libs/gtk+:2 )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( dev-util/intltool )
"
PDEPEND="~media-plugins/audacious-plugins-${PV}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	default
	[[ ${PV} == *9999 ]] && git-r3_src_unpack
}

src_prepare() {
	default
	if ! use nls; then
		sed -e "/SUBDIRS/s/ po//" -i Makefile || die # bug #512698
	fi
	[[ ${PV} == *9999 ]] && eautoreconf
}

src_configure() {
	# D-Bus is a mandatory dependency, remote control,
	# session management and some plugins depend on this.
	# Building without D-Bus is *unsupported* and a USE-flag
	# will not be added due to the bug reports that will result.
	# Bugs #197894, #199069, #207330, #208606
	econf \
		--disable-valgrind \
		--enable-dbus \
		$(use_enable nls) \
		$(use_enable !qt5 gtk) \
		$(use_enable qt5 qt)
}

src_install() {
	default

	# Gentoo_ice skin installation; bug #109772
	insinto /usr/share/audacious/Skins/gentoo_ice
	doins -r "${WORKDIR}"/gentoo_ice/.
	docinto gentoo_ice
	dodoc "${WORKDIR}"/README
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
