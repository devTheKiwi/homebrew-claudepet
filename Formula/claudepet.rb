class Claudepet < Formula
  desc "Dock 위를 돌아다니는 Claude Code 데스크탑 펫"
  homepage "https://devthekiwi.github.io/ClaudePet/"
  url "https://github.com/devTheKiwi/ClaudePet.git", tag: "v2.3.1"
  license "MIT"

  depends_on xcode: ["14.0", :build]
  depends_on macos: :ventura

  def install
    system "swift", "build", "-c", "release"

    # .app 번들 생성
    app_path = prefix/"ClaudePet.app"
    (app_path/"Contents/MacOS").mkpath
    (app_path/"Contents/Resources").mkpath
    cp ".build/release/ClaudePet", app_path/"Contents/MacOS/ClaudePet"

    # Info.plist
    (app_path/"Contents/Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>CFBundleExecutable</key><string>ClaudePet</string>
          <key>CFBundleIdentifier</key><string>com.claudepet.app</string>
          <key>CFBundleName</key><string>ClaudePet</string>
          <key>CFBundleVersion</key><string>#{version}</string>
          <key>CFBundleShortVersionString</key><string>#{version}</string>
          <key>LSMinimumSystemVersion</key><string>13.0</string>
          <key>LSUIElement</key><true/>
          <key>NSHighResolutionCapable</key><true/>
      </dict>
      </plist>
    PLIST

    # ~/Applications에 심볼릭 링크
    bin.install_symlink app_path/"Contents/MacOS/ClaudePet"
  end

  def post_install
    # .app을 ~/Applications로 복사
    target = File.expand_path("~/Applications/ClaudePet.app")
    source = prefix/"ClaudePet.app"
    FileUtils.rm_rf(target) if File.exist?(target)
    FileUtils.cp_r(source, target)

    # LaunchAgent 등록
    launch_agent = File.expand_path("~/Library/LaunchAgents/com.claudepet.app.plist")
    unless File.exist?(launch_agent)
      File.write(launch_agent, <<~PLIST)
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key><string>com.claudepet.app</string>
            <key>ProgramArguments</key>
            <array>
                <string>open</string>
                <string>#{target}</string>
            </array>
            <key>RunAtLoad</key><true/>
        </dict>
        </plist>
      PLIST
    end
  end

  def caveats
    <<~EOS
      ClaudePet이 ~/Applications/ClaudePet.app 에 설치되었습니다.

      실행: open ~/Applications/ClaudePet.app
      종료: 메뉴바 🐛 > 종료

      첫 실행 시 Claude Code 연동 팝업이 뜹니다.
    EOS
  end

  test do
    assert_predicate prefix/"ClaudePet.app/Contents/MacOS/ClaudePet", :exist?
  end
end
