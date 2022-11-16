inputs: with inputs; free.mkShell {
buildInputs = with free; [

  blender                   # 3d editor ftw
  cura                      # 3d slicer
  avidemux                  # a very basic video editor
  olive-editor              # a more complex video editor
  kdenlive                  # a more complex video editor
  ardour                    # music.mp3
  audacity                  # modify.mp3
  gimp                      # modify.img
  krita                     # paint.img
  akira-unstable            # SVGs.img

];

}
