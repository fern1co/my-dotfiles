# Darwin modules loader
# Import this file to load all darwin modules automatically
{ ... }:

{
  imports = [
    ./aerospace.nix
    ./sketchybar.nix
    ./yabai.nix
  ];
}
