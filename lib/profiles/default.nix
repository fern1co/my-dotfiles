# Profile loader - Automatically imports profiles based on host configuration
# Usage: import ./profiles { profiles = [ "base" "server" "development" ]; }
{ profiles ? [ ] }:

let
  # Convert profile name to path
  # Examples:
  #   "base" -> ./base/default.nix
  #   "server/digitalocean" -> ./server/digitalocean.nix
  profileToPath = profile:
    let
      parts = builtins.split "/" profile;
      hasSubdir = builtins.length parts > 1;
    in
      if hasSubdir
      then ./${profile}.nix
      else ./${profile}/default.nix;

  # Load a single profile
  loadProfile = profile: profileToPath profile;

in
  # Return list of profile imports
  builtins.map loadProfile profiles
