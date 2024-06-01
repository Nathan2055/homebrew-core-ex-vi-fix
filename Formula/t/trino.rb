class Trino < Formula
  include Language::Python::Shebang

  desc "Distributed SQL query engine for big data"
  homepage "https://trino.io"
  url "https://search.maven.org/remotecontent?filepath=io/trino/trino-server/449/trino-server-449.tar.gz", using: :nounzip
  sha256 "d0bf548e9c7e3288948490593a004c90b7ed09f867362305dbabb30e3514e27e"
  license "Apache-2.0"

  livecheck do
    url "https://search.maven.org/remotecontent?filepath=io/trino/trino-server/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, sonoma:         "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, ventura:        "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, monterey:       "ec60679ca16099efc6e138a6adb437323f824f1c176975b6f9ec2af13cb7c8d4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6f953f6faef1348fae9e63eab2b1c79336de225d45670f3b799c22ef85a8258a"
  end

  depends_on "gnu-tar" => :build
  depends_on "openjdk"
  depends_on "python@3.12"

  resource "trino-src" do
    url "https://github.com/trinodb/trino/archive/refs/tags/449.tar.gz", using: :nounzip
    sha256 "2d18554ae1850159633366af08cf7e394c73a9e37cf8d9d7d8963457c60a394a"
  end

  resource "trino-cli" do
    url "https://search.maven.org/remotecontent?filepath=io/trino/trino-cli/449/trino-cli-449-executable.jar"
    sha256 "dd43d8f5fbbceee79fddcb5dd5155ceac7edaf284faf1ef816d22fed32fc5d92"
  end

  def install
    odie "trino-src resource needs to be updated" if version != resource("trino-src").version
    odie "trino-cli resource needs to be updated" if version != resource("trino-cli").version

    # Manually extract tarball to avoid losing hardlinks which increases bottle
    # size from MBs to GBs. Remove once Homebrew is able to preserve hardlinks.
    # Ref: https://github.com/Homebrew/brew/pull/13154
    libexec.mkpath
    system "tar", "-C", libexec.to_s, "--strip-components", "1", "-xzf", "trino-server-#{version}.tar.gz"

    # Manually untar, since macOS-bundled tar produces the error:
    #   trino-363/plugin/trino-hive/src/test/resources/<truncated>.snappy.orc.crc: Failed to restore metadata
    # Remove when https://github.com/trinodb/trino/issues/8877 is fixed
    resource("trino-src").stage do |r|
      ENV.prepend_path "PATH", Formula["gnu-tar"].opt_libexec/"gnubin"
      system "tar", "-xzf", "trino-#{r.version}.tar.gz"
      (libexec/"etc").install Dir["trino-#{r.version}/core/docker/default/etc/*"]
      inreplace libexec/"etc/node.properties", "docker", tap.user.downcase
      inreplace libexec/"etc/node.properties", "/data/trino", var/"trino/data"
      inreplace libexec/"etc/jvm.config", %r{^-agentpath:/usr/lib/trino/bin/libjvmkill.so$\n}, ""
    end

    rewrite_shebang detected_python_shebang, libexec/"bin/launcher.py"
    (bin/"trino-server").write_env_script libexec/"bin/launcher", Language::Java.overridable_java_home_env

    resource("trino-cli").stage do
      libexec.install "trino-cli-#{version}-executable.jar"
      bin.write_jar_script libexec/"trino-cli-#{version}-executable.jar", "trino"
    end

    # Remove incompatible pre-built binaries
    libprocname_dirs = libexec.glob("bin/procname/*")
    # Keep the Linux-x86_64 directory to make bottles identical
    libprocname_dirs.reject! { |dir| dir.basename.to_s == "Linux-x86_64" } if build.bottle?
    libprocname_dirs.reject! { |dir| dir.basename.to_s == "#{OS.kernel_name}-#{Hardware::CPU.arch}" }
    libprocname_dirs.map(&:rmtree)
  end

  def post_install
    (var/"trino/data").mkpath
  end

  service do
    run [opt_bin/"trino-server", "run"]
    working_dir opt_libexec
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/trino --version")
    # A more complete test existed before but we removed it because it crashes macOS
    # https://github.com/Homebrew/homebrew-core/pull/153348
    # You can add it back when the following issue is fixed:
    # https://github.com/trinodb/trino/issues/18983#issuecomment-1794206475
    # https://bugs.openjdk.org/browse/CODETOOLS-7903448
  end
end
