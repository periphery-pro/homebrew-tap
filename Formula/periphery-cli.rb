class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.3"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.3/periphery-cli_1.0.0.beta.3_macos_arm64.zip"
      sha256 "cb64814d35ea782f4cbd8544cf2f801798126668bfd177729a3ce735281410e8"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.3/periphery-cli_1.0.0.beta.3_macos_x86_64.zip"
      sha256 "6cd4f0fbcc255c550c46157fb750a233e68795d1b16a6e680ead1b77e9f9478e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.3/periphery-cli_1.0.0.beta.3_linux_arm64.zip"
      sha256 "e59b98279eef984d19acd467624f6fb4f04aab43fa6f2dd85fd1d60aba4241cd"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.3/periphery-cli_1.0.0.beta.3_linux_x86_64.zip"
      sha256 "03cbd36db8c62cd744741de76ea53133c08aa366b07e53ef542f43f111388033"
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
