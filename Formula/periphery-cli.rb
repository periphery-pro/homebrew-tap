class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.2.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/v1.2.3/periphery-cli_1.2.3_macos_arm64.zip"
      sha256 ""
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/v1.2.3/periphery-cli_1.2.3_macos_x86_64.zip"
      sha256 ""
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/v1.2.3/periphery-cli_1.2.3_linux_arm64.zip"
      sha256 ""
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/v1.2.3/periphery-cli_1.2.3_linux_x86_64.zip"
      sha256 ""
    end
  end

  conflicts_with "periphery"

  def install
    bin.install "periphery"
  end

  test do
    system "#{bin}/periphery version"
  end
end
