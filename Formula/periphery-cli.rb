class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.7"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.7/periphery-cli_1.0.0.beta.7_macos_arm64.zip"
      sha256 "863dc25c36dc9a2e3f551394361310e324527c829ed8ccfb3b98e6e284f29206"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.7/periphery-cli_1.0.0.beta.7_macos_x86_64.zip"
      sha256 "6cf00bb9d0ba10eb54d0915716b6371e3e4e09b5c647f05fe7893f5f0bfdac92"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.7/periphery-cli_1.0.0.beta.7_linux_arm64.zip"
      sha256 "f83c1ce08e08b49ebfb0f6de1fd5b860817e78daaa945b641abbd14c3cf7feab"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.7/periphery-cli_1.0.0.beta.7_linux_x86_64.zip"
      sha256 "2cec49075884b9607b391aa40680c1c70a7e526b0e1f835dfd8ba17d32222995"
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
