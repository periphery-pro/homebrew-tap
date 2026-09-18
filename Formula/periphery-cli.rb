class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.6"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.6/periphery-cli_1.0.0.beta.6_macos_arm64.zip"
      sha256 "1179469ca8bf4702d9de96957c76cc7de96483bca1ae0762db61c8fe66c2f9ea"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.6/periphery-cli_1.0.0.beta.6_macos_x86_64.zip"
      sha256 "c1ce86cbeb8bb199fb52a8e404b6b98d769ada8b7c7a88af845ac82ab4ee58ea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.6/periphery-cli_1.0.0.beta.6_linux_arm64.zip"
      sha256 "ef50e35ba9874686e16bdbdd20ad1707159b04d22b82c229648ab6afc8d46601"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.6/periphery-cli_1.0.0.beta.6_linux_x86_64.zip"
      sha256 "6cb8a7999e7167ddf86d7b5f17952ee58da51d51f1c014be6f237bd8a1c9fad6"
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
