cask "claudepet" do
  version "2.3.1"
  sha256 "f849b29836065f4f19d0a9b446a4e400005122551a16ec525a35370625a39231"

  url "https://github.com/devTheKiwi/ClaudePet/releases/download/v#{version}/ClaudePet.zip"
  name "ClaudePet"
  desc "Dock 위를 돌아다니는 Claude Code 데스크탑 펫"
  homepage "https://devthekiwi.github.io/ClaudePet/"

  app "ClaudePet.app"

  postflight do
    # 자동 시작 등록
    launch_agent = "#{Dir.home}/Library/LaunchAgents/com.claudepet.app.plist"
    unless File.exist?(launch_agent)
      File.write(launch_agent, <<~PLIST)
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.claudepet.app</string>
            <key>ProgramArguments</key>
            <array>
                <string>open</string>
                <string>#{appdir}/ClaudePet.app</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
        </dict>
        </plist>
      PLIST
    end
  end

  uninstall_postflight do
    launch_agent = "#{Dir.home}/Library/LaunchAgents/com.claudepet.app.plist"
    File.delete(launch_agent) if File.exist?(launch_agent)
  end
end
