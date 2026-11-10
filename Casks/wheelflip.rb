cask "wheelflip" do
  version "1.1.2"
  sha256 "da55e1f1c5ae5449de86ab21c39da663f9240a1d834667e49c4893224465b36a"

  url "https://github.com/tim-jordan-1/homebrew-wheelflip/releases/download/v#{version}/WheelFlip-#{version}.zip"
  name "WheelFlip"
  desc "Invert mouse wheel scrolling without changing the trackpad"
  homepage "https://github.com/tim-jordan-1/homebrew-wheelflip"

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
