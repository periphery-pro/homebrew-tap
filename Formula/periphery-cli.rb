class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.11"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.11/periphery-cli_1.0.0.beta.11_macos_arm64.zip"
      sha256 "52163d8bc0c13cd23ac6ab872707a9960e74bad7f9f3524db92297a137cd6dba"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.11/periphery-cli_1.0.0.beta.11_macos_x86_64.zip"
      sha256 "a4aac8b60404f9c87f843350616a5d27c6dc6dbc2147867ace1ce7cee1ea69ee"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.11/periphery-cli_1.0.0.beta.11_linux_arm64.zip"
      sha256 "dfbb4301b452be6bf0f86b2f43a5b873e4d801e10d16deee353b84bf53887f97"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.11/periphery-cli_1.0.0.beta.11_linux_x86_64.zip"
      sha256 "ca63120fb323ae94fd3a150ef347395c19a26df66fc12f454a82446bc351ae46"
    end
  end

  conflicts_with "periphery"

  def install
    libexec.install "periphery"
    libexec.install Dir["libIndexStore.*"]
    bin.install_symlink libexec/"periphery"

    if OS.mac?
      # Homebrew ad-hoc signs the bundled libraries. Allow loading them while
      # retaining the other hardened runtime protections.
      entitlements = buildpath/"periphery.entitlements.plist"
      entitlements.write <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>com.apple.security.cs.disable-library-validation</key>
            <true/>
          </dict>
        </plist>
      XML
      system "codesign", "--force", "--sign", "-", "--options=runtime",
             "--entitlements", entitlements, libexec/"periphery"
    end

    doc.install "LICENSE.md", "THIRD_PARTY_NOTICES.txt"
  end

  test do
    system bin/"periphery", "version"

    if OS.mac?
      system "codesign", "--verify", "--strict", libexec/"periphery"
      libexec.glob("*.dylib").each do |library|
        system "codesign", "--verify", "--strict", library
      end
    end
  end
end
