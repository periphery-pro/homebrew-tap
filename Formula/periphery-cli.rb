class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.5"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.5/periphery-cli_1.0.0.beta.5_macos_arm64.zip"
      sha256 "eac4488284b62664dd7994fb61adde6d787a2e31fdd6ec3f4fc2c71e2b0f768c"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.5/periphery-cli_1.0.0.beta.5_macos_x86_64.zip"
      sha256 "a9a474ec078e25c9e4a4b105933cfb3b41df19af8db27b643532a7d9387fdae9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.5/periphery-cli_1.0.0.beta.5_linux_arm64.zip"
      sha256 "17ef961769a465c5bd38f6255be68cf9c320dbf371c9799bd2f866e188d58bcc"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.5/periphery-cli_1.0.0.beta.5_linux_x86_64.zip"
      sha256 "85bb4c7a6df4585f8d6c8705fc2f03aa7d1b6c085c74ec0823531353f6d6d208"
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

    doc.install "LICENSE.md", "THIRD_PARTY_NOTICES.txt"
  end

  test do
    system bin/"periphery", "version"
    assert_path_exists doc/"LICENSE.md"
    assert_path_exists doc/"THIRD_PARTY_NOTICES.txt"

    if OS.mac?
      assert_includes (bin/"periphery").rpaths, "#{MacOS::CLT::PKG_PATH}/usr/lib"
      refute_path_exists bin/"libIndexStore.dylib"
      system "codesign", "--verify", "--strict", bin/"periphery"
    end
  end
end
