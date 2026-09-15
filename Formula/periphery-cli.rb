class PeripheryCli < Formula
  desc "Periphery"
  homepage "https://periphery.pro"
  version "1.0.0.beta.5"
  license :cannot_represent
  revision 1

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
    libexec.install "periphery"
    libexec.install Dir["libIndexStore.*", "libswiftDemangle.*", "retention.map"]
    bin.install_symlink libexec/"periphery"

    if OS.mac?
      # Homebrew rewrites and ad-hoc signs the bundled libraries. Drop hardened
      # runtime library validation so the executable can load those libraries.
      system "codesign", "--force", "--sign", "-", "--options=0", libexec/"periphery"
    end

    doc.install "LICENSE.md", "THIRD_PARTY_NOTICES.txt"
  end

  test do
    system bin/"periphery", "version"
    assert_path_exists doc/"LICENSE.md"
    assert_path_exists doc/"THIRD_PARTY_NOTICES.txt"

    if OS.mac?
      assert_path_exists libexec/"libIndexStore.dylib"
      refute_includes (libexec/"periphery").rpaths, "/Library/Developer/CommandLineTools/usr/lib"
      system "codesign", "--verify", "--strict", libexec/"periphery"
      libexec.glob("*.dylib").each do |library|
        system "codesign", "--verify", "--strict", library
      end
    else
      assert_predicate libexec.glob("libIndexStore.so*"), :any?
    end
  end
end
