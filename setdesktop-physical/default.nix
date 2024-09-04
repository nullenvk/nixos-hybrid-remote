{pkgs, physOutput, remoteOutput, ...}:
pkgs.writeScriptBin "setdesktop-physical" ''
#!${pkgs.stdenv.shell}
export QT_QPA_PLATFORM=wayland
${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${remoteOutput}.disable output.${physOutput}.enable
${pkgs.kdePackages.qttools}/bin/qdbus org.kde.screensaver /ScreenSaver Lock
''
