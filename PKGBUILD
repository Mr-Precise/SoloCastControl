# Maintainer: Precise

pkgname=solocastcontrol-git
pkgver=1.0
pkgrel=1
pkgdesc="A simple Bash script for controlling the HyperX SoloCast USB microphone (on/off, volume adjustment, status check)"
arch=('any')
url="https://github.com/Mr-Precise/SoloCastControl"
license=('GPL3')
depends=('alsa-utils' 'bash')
makedepends=('git' 'make')
provides=('solocastcontrol')
conflicts=('solocastcontrol')
source=("git+https://github.com/Mr-Precise/SoloCastControl.git")
sha256sums=('SKIP')

pkgver() {
  cd "${srcdir}/SoloCastControl"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "${srcdir}/SoloCastControl"
  make install DESTDIR="${pkgdir}" PREFIX=/usr
}
