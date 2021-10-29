godot=/Applications/Godot.app/Contents/MacOS/Godot

pushd server
$godot --no-window --export linux exports/server.pck
popd