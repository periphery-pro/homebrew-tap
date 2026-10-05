class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.8"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.8/periphery-cli_1.0.0.beta.8_macos_arm64.zip"
      sha256 "5a62b7143a8fbe79123ea38529d6b7293ce709fae1386125ff94b4726f5b7c06"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.8/periphery-cli_1.0.0.beta.8_macos_x86_64.zip"
      sha256 "ca36cee46800eab0cdcd478eb2495c339b09654724a2ddaa16c005ddd907bd6e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.8/periphery-cli_1.0.0.beta.8_linux_arm64.zip"
      sha256 "7c780908be439d3d1f37456d5ee3d8a87d78f1fdaacc0bbdfcafc286671f6542"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.8/periphery-cli_1.0.0.beta.8_linux_x86_64.zip"
      sha256 "e1676fa8d1bd440d246cbcde23dd9a38e20a619ea81fc5b61ceca51c16cc293b"
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
