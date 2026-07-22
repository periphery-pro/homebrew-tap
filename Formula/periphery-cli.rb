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
    bin.install "periphery"
    bin.install Dir["libIndexStore.*"]
  end

  def post_install
    return unless OS.mac?

    periphery_exe = bin/"periphery"

    # Match bundled libIndexStore to how `periphery` is actually signed after Brew's
    # install/relocate pass. If Brew re-signed the main binary ad hoc, downgrade the
    # dylib the same way so Team IDs match — we cannot apply Developer ID without the
    # maintainer key on the user's machine. If the binary still carries Developer ID,
    # leave the dylibs alone (they already match the release tarball).
    return unless periphery_adhoc_signed?(periphery_exe)

    dylibs = Dir["#{bin}/libIndexStore*.dylib"].sort
    return if dylibs.empty?

    system "codesign", "--sign", "-", "--force",
           "--preserve-metadata=entitlements,requirements,flags,runtime", *dylibs
  end

  def periphery_adhoc_signed?(executable)
    require "open3"
    stdout, stderr, status = Open3.capture3("codesign", "-dv", executable.to_s)
    text = "#{stderr}#{stdout}"
    return false if text.strip.empty?
    return true if /\bSignature=\s*adhoc\b/.match?(text)
    return false if /\bAuthority=\s*Developer ID\b/.match?(text)
    return true if /\bTeamIdentifier=\s*not set\b/.match?(text)

    status.success? && !/\bAuthority=/.match?(text)
  end

  test do
    system "#{bin}/periphery version"
  end
end
