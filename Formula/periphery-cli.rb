class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.9"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.9/periphery-cli_1.0.0.beta.9_macos_arm64.zip"
      sha256 "45a553bfa56e1e1a22a86134ccbdd6a722357493cf0d769b24bbbd96fc860f47"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.9/periphery-cli_1.0.0.beta.9_macos_x86_64.zip"
      sha256 "51dcf875bca2e0172dba088e70f5aa15b00807e8033bf70b5f3da2ec4706db87"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.9/periphery-cli_1.0.0.beta.9_linux_arm64.zip"
      sha256 "1370b8d31dd68e6ec3969ace8feacc4f893b9ff3b46ec9e4702534d12b98554b"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.9/periphery-cli_1.0.0.beta.9_linux_x86_64.zip"
      sha256 "1024ed5e0c97eef58ad924027f84d53cab4f08a8e45f28133ec6fba433503ae1"
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
