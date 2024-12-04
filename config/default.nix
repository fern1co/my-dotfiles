{ specialArgs, ...}:
let 
  minimal = [
  ];
in {
  imports = [
    ./options.nix
  ]
++ (if specialArgs.minimal then minimal else [ ./plugins]);
}
