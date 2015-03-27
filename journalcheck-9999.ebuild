# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit git-2

EGIT_REPO_URI="git://github.com/lynix/journalcheck.git"
DESCRIPTION="A simple replacement for logcheck for usage with journald"
HOMEPAGE="http://lynix.github.com/journalcheck"
LICENSE="MIT"

KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_compile() { :; }

src_install() {
	emake install PREFIX="${D}/usr" || die "emake install failed"
}
