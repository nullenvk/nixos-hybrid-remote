{pkgs, scriptName, activeOutput, inactiveOutput, ...}:
pkgs.writeScriptBin "${scriptName}" ''
#!${pkgs.stdenv.shell}
export QT_QPA_PLATFORM=wayland
${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${inactiveOutput}.disable output.${activeOutput}.enable
${pkgs.kdePackages.qttools}/bin/qdbus org.kde.screensaver /ScreenSaver Lock
''
