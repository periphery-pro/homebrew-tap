class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.2/periphery-cli_1.0.0.beta.2_macos_arm64.zip"
      sha256 "48b574a6f5c868e8a3e07e3f5afdab39734c3624b23fc84f2380e58c0a837cfd"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.2/periphery-cli_1.0.0.beta.2_macos_x86_64.zip"
      sha256 "b7b48cfc2f678b902d62bb4a3f334e5bb6a85dd1dbb265d7bed3c431eda94897"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.2/periphery-cli_1.0.0.beta.2_linux_arm64.zip"
      sha256 "bbd4522813f06ddf59e52a88912f36d3de285195699c8dcd41588496cde4a878"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.2/periphery-cli_1.0.0.beta.2_linux_x86_64.zip"
      sha256 "5fa566769edc68fd5863d55eb804ac988d325f9642e3f26c1ac87b991fff5d07"
    end
  end

  conflicts_with "periphery"

  def install
    if OS.mac?
      odie <<~EOS unless MacOS::CLT.installed?
        Periphery requires the Xcode Command Line Tools at #{MacOS::CLT::PKG_PATH}.
        Install them with:
          xcode-select --install
      EOS

      bin.install "periphery"
      MachO::Tools.add_rpath bin/"periphery", "#{MacOS::CLT::PKG_PATH}/usr/lib"
      system "codesign", "--force", "--sign", "-",
             "--preserve-metadata=entitlements,flags,runtime", bin/"periphery"
    else
      bin.install "periphery"
      bin.install Dir["libIndexStore.*"]
    end
  end

  test do
    system bin/"periphery", "version"

    if OS.mac?
      assert_includes (bin/"periphery").rpaths, "#{MacOS::CLT::PKG_PATH}/usr/lib"
      refute_path_exists bin/"libIndexStore.dylib"
      system "codesign", "--verify", "--strict", bin/"periphery"
    end
  end
end
