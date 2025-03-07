class Kettle < Formula
  desc "Pentaho Data Integration software"
  homepage "https://www.hitachivantara.com/en-us/products/data-management-analytics.html"
  url "https://downloads.sourceforge.net/project/pentaho/Pentaho-9.2/client-tools/pdi-ce-9.2.0.0-290.zip"
  sha256 "8e64d1125b2403df66f212488762f1558968a3900d079c730b2f6943e346a7e7"

  livecheck do
    url :stable
    regex(%r{url=.*?/pdi-ce[._-]v?(\d+(?:\.\d+)+(?:-\d+)?)\.(?:t|zip)}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "cdd9fda5c818bf2c51a61b508a21c20b93a036d1c2bce66d98ee3185b499b561"
  end

  depends_on arch: :x86_64
  depends_on "openjdk@8"

  def install
    rm_rf Dir["*.{bat}"]
    libexec.install Dir["*"]

    (etc+"kettle").install libexec+"pwd/carte-config-master-8080.xml" => "carte-config.xml"
    (etc+"kettle/.kettle").install libexec+"pwd/kettle.pwd"
    (etc+"kettle/simple-jndi").mkpath

    (var+"log/kettle").mkpath

    # We don't assume that carte, kitchen or pan are in anyway unique command names so we'll prepend "pdi"
    env = { BASEDIR: libexec, JAVA_HOME: Language::Java.java_home("1.8") }
    %w[carte kitchen pan].each do |command|
      (bin+"pdi#{command}").write_env_script libexec+"#{command}.sh", env
    end
  end

  plist_options manual: "pdicarte #{HOMEBREW_PREFIX}/etc/kettle/carte-config.xml"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/pdicarte</string>
            <string>#{etc}/kettle/carte-config.xml</string>
          </array>
          <key>EnvironmentVariables</key>
          <dict>
            <key>KETTLE_HOME</key>
            <string>#{etc}/kettle</string>
          </dict>
          <key>WorkingDirectory</key>
          <string>#{etc}/kettle</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/kettle/carte.log</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/kettle/carte.log</string>
          <key>RunAtLoad</key>
          <true/>
        </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/pdipan", "-file=#{libexec}/samples/transformations/Encrypt\ Password.ktr", "-level=RowLevel"
  end
end
