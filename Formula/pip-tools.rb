class PipTools < Formula
  include Language::Python::Virtualenv

  desc "Locking and sync for Pip requirements files"
  homepage "https://pip-tools.readthedocs.io"
  url "https://files.pythonhosted.org/packages/62/f6/97bcd8a0c3c673ead0cbecfd7d0f98d856d94d4d791616f5989afcc17a9c/pip-tools-6.10.0.tar.gz"
  sha256 "7f9f7356052db6942b5aaabc8eba29983591ca0ad75affbf2f0a25d9361be624"
  license "BSD-3-Clause"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5a7874985453b406d9cab6809e608578a13633f5c1cff18f547fb835b9f0b3b6"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "fbc7de9e1713a9762d6fadcdee0c8a6e9600a61a8c0aa0da72627cf64733329b"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "988cda05ea6b30ccc999271c8c8c7c4efef8bb1f7a3d69a48bc647541e17f2eb"
    sha256 cellar: :any_skip_relocation, monterey:       "9dad132ca35234068d3716a5b95d1b24e6994a45470412a636fa137b51308f0b"
    sha256 cellar: :any_skip_relocation, big_sur:        "ffbc661d2b34e0918dc734863ba58bb0d7ca5c354045250c3a75e7e9d9b690d8"
    sha256 cellar: :any_skip_relocation, catalina:       "d7be0c000b8372f606a5669f528f4bdd83dffd4e96c212bd17650d53c967869d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "e95e704c0ac002e6d0c5708242611f1ab7ddf85b5f440043a7e0ebaa8cd2731f"
  end

  depends_on "python@3.11"

  resource "build" do
    url "https://files.pythonhosted.org/packages/0f/61/aaf43fbb36cc4308be8ac8088f52db9622b0dbf1f0880c1016ae6aa03f46/build-0.9.0.tar.gz"
    sha256 "1a07724e891cbd898923145eb7752ee7653674c511378eb9c7691aab1612bc3c"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/59/87/84326af34517fca8c58418d148f2403df25303e02736832403587318e9e8/click-8.1.3.tar.gz"
    sha256 "7682dc8afb30297001674575ea00d1814d808d6a36af415a82bd481d37ba7b8e"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/df/9e/d1a7217f69310c1db8fdf8ab396229f55a699ce34a203691794c5d1cad0c/packaging-21.3.tar.gz"
    sha256 "dd47c42927d89ab911e606518907cc2d3a1f38bbd026385970643f9c5b8ecfeb"
  end

  resource "pep517" do
    url "https://files.pythonhosted.org/packages/4d/19/e11fcc88288f68ae48e3aa9cf5a6fd092a88e629cb723465666c44d487a0/pep517-0.13.0.tar.gz"
    sha256 "ae69927c5c172be1add9203726d4b84cf3ebad1edcd5f71fcdc746e66e829f59"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/71/22/207523d16464c40a0310d2d4d8926daffa00ac1f5b1576170a32db749636/pyparsing-3.0.9.tar.gz"
    sha256 "2b020ecf7d21b687f219b71ecad3631f644a47f01403fa1d1036b0c6416d70fb"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/a2/b8/6a06ff0f13a00fc3c3e7d222a995526cbca26c1ad107691b6b1badbbabf1/wheel-0.38.4.tar.gz"
    sha256 "965f5259b566725405b05e7cf774052044b1ed30119b5d586b2703aafe8719ac"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      pip-tools
      typing-extensions
    EOS

    compiled = shell_output("#{bin}/pip-compile requirements.in -q -o -")
    assert_match "This file is autogenerated by pip-compile", compiled
    assert_match "# via pip-tools", compiled
  end
end
