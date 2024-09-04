{pkgs, physOutput, remoteOutput, ...}:
pkgs.writeScriptBin "setdesktop-remote" ''
#!${pkgs.stdenv.shell}
export QT_QPA_PLATFORM=wayland
${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${physOutput}.disable output.${remoteOutput}.enable
${pkgs.kdePackages.qttools}/bin/qdbus org.kde.screensaver /ScreenSaver Lock
''
