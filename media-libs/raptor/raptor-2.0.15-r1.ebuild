# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool

MY_PN=${PN}2
MY_P=${MY_PN}-${PV}

DESCRIPTION="The RDF Parser Toolkit"
HOMEPAGE="http://librdf.org/raptor/"
SRC_URI="http://download.librdf.org/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0 GPL-2 LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm ~arm64 ~hppa ia64 ppc ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+curl debug json static-libs unicode"

DEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	net-dns/libidn2:=
	curl? ( net-misc/curl )
	json? ( dev-libs/yajl )
	unicode? ( dev-libs/icu:= )
"
RDEPEND="${DEPEND}
	!media-libs/raptor:0
"
BDEPEND="
	>=sys-devel/bison-3
	>=sys-devel/flex-2.5.36
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}"

DOCS=( AUTHORS ChangeLog NEWS NOTICE README )
HTML_DOCS=( {NEWS,README,RELEASE,UPGRADING}.html )

PATCHES=( "${FILESDIR}/${P}-heap-overflow.patch" )

src_prepare() {
	default
	elibtoolize # Keep this for ~*-fbsd
}

src_configure() {
	# FIXME: It should be possible to use net-nntp/inn for libinn.h and -linn!

	local myeconfargs=(
		--with-html-dir="${EPREFIX}"/usr/share/gtk-doc/html
		$(usex curl --with-www=curl --with-www=xml)
		$(use_enable debug)
		$(use_with json yajl)
		$(use_enable static-libs static)
		$(usex unicode --with-icu-config="${EPREFIX}"/usr/bin/icu-config '')
	)

	econf "${myeconfargs[@]}"
}

src_test() {
	emake -j1 test
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
