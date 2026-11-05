class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.10"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.10/periphery-cli_1.0.0.beta.10_macos_arm64.zip"
      sha256 "bd56be7bcbb625fb861f15ea1901e747eb36dcaadc9a91bbe581e731226d3dff"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.10/periphery-cli_1.0.0.beta.10_macos_x86_64.zip"
      sha256 "b9014507ae8a6aee1c0d8a05aeab994cc4682c6ee7d994cfde714738273046e6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.10/periphery-cli_1.0.0.beta.10_linux_arm64.zip"
      sha256 "940d43f3fec113b1f70866d9fb12420eee9c70f99c4051e24eda636b4b9336d6"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.10/periphery-cli_1.0.0.beta.10_linux_x86_64.zip"
      sha256 "359c203a8824740be13de326d1fc8f811705c7fa1cf6f38a56415c24752f8755"
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
