class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.4"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.4/periphery-cli_1.0.0.beta.4_macos_arm64.zip"
      sha256 "973c99188ec867c70350ff93c07a65fbaa5879d36ff8c39858b7a24ccf43a95e"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.4/periphery-cli_1.0.0.beta.4_macos_x86_64.zip"
      sha256 "b87faa32e34be3804e099d1a5c3191c7716df376b8fb0c2e7d94e887e82cbf9a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.4/periphery-cli_1.0.0.beta.4_linux_arm64.zip"
      sha256 "91e9bf3496ce1b85e051b0cb76c33a7c5b826ac340366e7a7cea1d771481778e"
    else
      url "https://github.com/periphery-pro/cli-releases/releases/download/1.0.0.beta.4/periphery-cli_1.0.0.beta.4_linux_x86_64.zip"
      sha256 "55200150e3d8a06d79b3109059b3d05edafaed406604e7242446e178d97f6e93"
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
