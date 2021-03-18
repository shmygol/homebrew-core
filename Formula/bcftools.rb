class Bcftools < Formula
  desc "Tools for BCF/VCF files and variant calling from samtools"
  homepage "https://www.htslib.org/"
  url "https://github.com/samtools/bcftools/releases/download/1.12/bcftools-1.12.tar.bz2"
  sha256 "7a0e6532b1495b9254e38c6698d955e5176c1ee08b760dfea2235ee161a024f5"
  # The bcftools source code is MIT/Expat-licensed, but when it is configured
  # with --enable-libgsl the resulting executable is GPL-licensed.
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 arm64_big_sur: "59762e9109882da66c1ebf0d0381f5d38cada1e58732025f0c91ab9cb85f0031"
    sha256 big_sur:       "67d1219c5df4b512f08199740257e15b38422ba461c2de3ef2ed0697c8e28305"
    sha256 catalina:      "fb3b25ef0fa059b400d4094e9719208c74b7665c45d378aec46f26efe5c179c6"
    sha256 mojave:        "cbc6f8a457ddb9d4e6c14a1b5f78023f66305aa9df7f8495252b9a774821fec9"
    sha256 high_sierra:   "d6ea207bfe680f637147e39e7cf2f3311709dc3c1964bdf5d3506d13200da7a8"
  end

  depends_on "gsl"
  depends_on "htslib"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-htslib=#{Formula["htslib"].opt_prefix}",
                          "--enable-libgsl"
    system "make", "install"
    pkgshare.install "test/query.vcf"
  end

  test do
    output = shell_output("#{bin}/bcftools stats #{pkgshare}/query.vcf")
    assert_match "number of SNPs:\t3", output
    assert_match "fixploidy", shell_output("#{bin}/bcftools plugin -l")
  end
end
