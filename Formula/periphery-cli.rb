class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.1/periphery-cli_1.0.0.beta.1_macos_arm64.zip"
      sha256 "132fb5f0376027aed26bc2871fd651913d583abb6c5982a133c00fdb508df2e9"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.1/periphery-cli_1.0.0.beta.1_macos_x86_64.zip"
      sha256 "8a371e5bd36575462362b67524abd2b975c27aa30d3ad64132c158a00a69853b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.1/periphery-cli_1.0.0.beta.1_linux_arm64.zip"
      sha256 "2ba967a6cab83aedce93890e519ec0210d9284358b150c74e74175eb8d01cf2a"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.1/periphery-cli_1.0.0.beta.1_linux_x86_64.zip"
      sha256 "69b27a8dc573dc3207a077a709861214d4bb15b0d6bd5c85fd5181a960971953"
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
