cask "wheelflip" do
  version "1.0"
  sha256 "b3e446ce86e857dd2115f4f42f9d15c7037026d4d285086f4d4177475301cb0c"

  url "https://github.com/tim-jordan-1/WheelFlip/releases/download/v#{version}/WheelFlip-#{version}.zip"
  name "WheelFlip"
  desc "Invert mouse wheel scrolling without changing the trackpad"
  homepage "https://github.com/tim-jordan-1/WheelFlip"

  depends_on macos: :ventura

  app "WheelFlip.app"

  # The app is ad-hoc signed and not notarized, so Gatekeeper blocks it while the quarantine flag is present.
  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/WheelFlip.app"],
        must_succeed: false
  end

  uninstall quit: "com.timjordan.WheelFlip"

  zap trash: "~/Library/Preferences/com.timjordan.WheelFlip.plist"
end
