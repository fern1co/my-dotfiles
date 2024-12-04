{
pkgs,
lib,
config,
...}:
with lib; let
 cfg = config.modules.editors.nvim;
in {
  imports = [
  	./options.nix
  ];

  options.modules.editors.nvim = {
    enable = mkEnableOption "enable neovim editor";
  };

  config = 
    mkIf
    	cfg.enable 
	{
	  programs.nixvim = {
	    enable = true;
	    extraPlugins = with pkgs.vimPlugins; [plenary-nvim];
	    package = pkgs.neovim;
	};
   };
}
