{ config, pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    # Terminal for run mode
    terminal = "${pkgs.kitty}/bin/kitty";

    # Theme using rasi format
    theme = ./rofi/config.rasi;

    # Extra configuration
    extraConfig = {
      modi = "drun,filebrowser,window,run";
      font = "Fira Sans 11";
      show-icons = true;
      display-drun = " ";
      display-run = " ";
      display-filebrowser = "";
      display-window = "";
      drun-display-format = "{name}";
      hover-select = false;
      scroll-method = 1;
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
      window-format = "{w} · {c} · {t}";
    };
  };

  # Rofi theme files
  home.file.".config/rofi/config.rasi".text = ''
    /*
    #  ____        __ _
    # |  _ \ ___  / _(_)
    # | |_) / _ \| |_| |
    # |  _ < (_) |  _| |
    # |_| \_\___/|_| |_|
    #
    # by Stephan Raabe (2023)
    # -----------------------------------------------------
    */

    /* ---- Configuration ---- */
    configuration {
        modi:                       "drun,filebrowser,window,run";
        font:                       "Fira Sans 11";
        show-icons:                 true;
        display-drun:                " ";
        display-run:                 " ";
        display-filebrowser:         "";
        display-window:              "";
        drun-display-format:        "{name}";
        hover-select:               false;
        scroll-method:              1;
        me-select-entry:            "";
        me-accept-entry:            "MousePrimary";
        window-format:              "{w} · {c} · {t}";
    }

    /* ---- Load colors ---- */
    @theme "~/.config/rofi/colors.rasi"

    /* ---- Window ---- */
    window {
        height:                      35em;
        width:                       56em;
        transparency:                "real";
        fullscreen:                  false;
        enabled:                     true;
        cursor:                      "default";
        spacing:                     0em;
        padding:                     0em;
        border:                      2px;
        border-color:                @primary;
        border-radius:               12px;
        background-color:            @background;
    }

    mainbox {
        enabled:                     true;
        spacing:                     0em;
        padding:                     0em;
        orientation:                 horizontal;
        children:                    [ "imagebox" , "listbox" ];
        background-color:            transparent;
    }

    imagebox {
        padding:                     20px;
        background-color:            transparent;
        orientation:                 vertical;
        children:                    [ "inputbar", "dummy", "mode-switcher" ];
    }

    dummy {
        background-color:            transparent;
    }

    /* ---- Mode Switcher ---- */
    mode-switcher {
        orientation:                 horizontal;
        width:                       6.6em;
        enabled:                     true;
        padding:                     1.5em;
        spacing:                     1.5em;
        background-color:            transparent;
    }

    button {
        padding:                     15px;
        border-radius:               2em;
        border:                      0;
        cursor:                      pointer;
        background-color:            @background;
        text-color:                  @on-surface;
    }

    button selected {
        padding:                     15px;
        border-radius:               2em;
        background-color:            @surface;
        text-color:                  @on-surface;
    }

    /* ---- Inputbar ---- */
    inputbar {
        enabled:                     true;
        margin:                      1em;
        children:                    [ "textbox-prompt-colon", "entry" ];
        border-radius:               2em;
        background-color:            @surface;
    }

    textbox-prompt-colon {
        enabled:                     true;
        expand:                      false;
        str:                         "  ";
        padding:                     1em 0.3em 0 0;
        text-color:                  @on-surface;
        background-color:            transparent;
    }

    entry {
        enabled:                     true;
        spacing:                     1em;
        padding:                     1em;
        text-color:                  @on-surface;
        cursor:                      text;
        placeholder:                 "Search";
        background-color:            transparent;
        placeholder-color:           inherit;
    }

    /* ---- Listview ---- */
    listbox {
        padding:                     0em;
        spacing:                     0em;
        orientation:                 horizontal;
        children:                    [ "listview" ];
        background-color:            @background;
    }

    listview {
        padding:                     1.5em;
        spacing:                     0.5em;
        enabled:                     true;
        columns:                     1;
        lines:                       10;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        cursor:                      "default";
        background-color:            transparent;
        text-color:                  @on-surface;
    }

    /* ---- Elements ---- */
    element {
        enabled:                     true;
        spacing:                     10px;
        padding:                     0.5em;
        cursor:                      pointer;
        background-color:            transparent;
        text-color:                  @on-surface;
    }

    element selected.normal {
        background-color:            @surface;
        text-color:                  @on-surface;
        border-radius:               1.5em;
    }

    element normal.normal {
        background-color:            inherit;
        text-color:                  @on-surface;
    }

    element-icon {
        size:                        3em;
        cursor:                      inherit;
        background-color:            transparent;
        text-color:                  inherit;
        border-radius:               0em;
    }

    element-text {
        vertical-align:              0.5;
        horizontal-align:            0.0;
        cursor:                      inherit;
        background-color:            transparent;
        text-color:                  inherit;
    }

    /* ---- Error message ---- */
    error-message {
        text-color:                  @on-surface;
        background-color:            @background;
        text-transform:              capitalize;
        children:                    [ "textbox" ];
    }

    textbox {
        text-color:                  inherit;
        background-color:            inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }
  '';

  home.file.".config/rofi/colors.rasi".text = ''
    * {
        background: rgba(255, 255, 255, 0.7);
        primary: #006973;
        primary-fixed: #9eeffc;
        primary-fixed-dim: #81d3e0;
        on-primary: #ffffff;
        on-primary-fixed: #001f24;
        on-primary-fixed-variant: #004f57;
        primary-container: #9eeffc;
        on-primary-container: #001f24;
        secondary: #4a6266;
        secondary-fixed: #cde7ec;
        secondary-fixed-dim: #b1cbd0;
        on-secondary: #ffffff;
        on-secondary-fixed: #051f22;
        on-secondary-fixed-variant: #334b4f;
        secondary-container: #cde7ec;
        on-secondary-container: #051f22;
        tertiary: #525e7d;
        tertiary-fixed: #d9e2ff;
        tertiary-fixed-dim: #bac6ea;
        on-tertiary: #ffffff;
        on-tertiary-fixed: #0e1b37;
        on-tertiary-fixed-variant: #3a4664;
        tertiary-container: #d9e2ff;
        on-tertiary-container: #0e1b37;
        error: #ba1a1a;
        on-error: #ffffff;
        error-container: #ffdad6;
        on-error-container: #410002;
        surface: #f5fafb;
        on-surface: #171d1e;
        on-surface-variant: #3f484a;
        outline: #6f797a;
        outline-variant: #bfc8ca;
        shadow: #000000;
        scrim: #000000;
        inverse-surface: #2b3132;
        inverse-on-surface: #ecf2f3;
        inverse-primary: #81d3e0;
        surface-dim: #d5dbdc;
        surface-bright: #f5fafb;
        surface-container-lowest: #ffffff;
        surface-container-low: #eff5f6;
        surface-container: #e9eff0;
        surface-container-high: #e3e9ea;
        surface-container-highest: #dee3e4;
    }
  '';

  # Compact variant for rofi-tmux
  home.file.".config/rofi/config-compact.rasi".text = ''
    /* ---- Configuration ---- */
    configuration {
        modi:                       "drun,filebrowser,window,run";
        font:                       "Fira Sans 11";
        show-icons:                 true;
        icon-theme:                 "Tela-circle-dracula";
        display-drun:                " ";
        display-run:                 " ";
        display-filebrowser:         " ";
        display-window:              " ";
        drun-display-format:        "{name}";
        hover-select:               false;
        scroll-method:              1;
        me-select-entry:            "";
        me-accept-entry:            "MousePrimary";
        window-format:              "{w} · {c} · {t}";
    }

    /* ---- Load colors ---- */
    @theme "~/.config/rofi/colors.rasi"

    /* ---- Window ---- */
    window {
        width:                        30em;
        x-offset:                     0em;
        y-offset:                     2em;
        spacing:                      0em;
        padding:                      0em;
        margin:                       0em;
        color:                        #FFFFFF;
        border:                       2px;
        border-color:                 @primary;
        cursor:                       "default";
        transparency:                 "real";
        location:                     north;
        anchor:                       north;
        fullscreen:                   false;
        enabled:                      true;
        border-radius:                12px;
        background-color:             transparent;
    }

    mainbox {
        enabled:                     true;
        spacing:                     0em;
        padding:                     0em;
        orientation:                 horizontal;
        children:                    [ "listbox" ];
        background-color:            transparent;
    }

    /* ---- Inputbar ---- */
    inputbar {
        enabled:                     true;
        spacing:                     0em;
        padding:                     1em;
        children:                    [ "textbox-prompt-colon", "entry" ];
        background-color:            @surface;
    }

    textbox-prompt-colon {
        enabled:                     true;
        expand:                      false;
        str:                         "  ";
        padding:                     0.5em 0.2em 0em 0em;
        text-color:                  @on-surface;
        border-radius:               2em 0em 0em 2em;
        background-color:            transparent;
    }

    entry {
        enabled:                     true;
        spacing:                     1em;
        padding:                     0.5em;
        background-color:            @surface;
        text-color:                  @on-surface;
        cursor:                      text;
        placeholder:                 "Search";
        placeholder-color:           inherit;
    }

    /* ---- Lists ---- */
    listbox {
        padding:                     0em;
        spacing:                     0em;
        orientation:                 vertical;
        children:                    [ "inputbar", "listview" , "message" ];
        background-color:            @background;
    }

    listview {
        padding:                     1em;
        spacing:                     0em;
        margin:                      0em;
        enabled:                     true;
        columns:                     1;
        lines:                       8;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        cursor:                      "default";
        background-color:            transparent;
        text-color:                  @on-surface;
    }

    /* ---- Elements ---- */
    element {
        enabled:                     true;
        padding:                     1em;
        margin:                      0em;
        cursor:                      pointer;
        background-color:            transparent;
        text-color:                  @on-surface;
        border-radius:               1.1em;
    }

    element selected.normal {
        background-color:            @surface;
        text-color:                  @on-surface;
        border-radius:               1.5em;
    }

    element normal.normal {
        background-color:            inherit;
        text-color:                  @on-surface;
    }

    element-icon {
        size:                        0em;
        cursor:                      inherit;
        background-color:            transparent;
        text-color:                  inherit;
        content:                     "";
    }

    element-text {
        vertical-align:              0.5;
        horizontal-align:            0.0;
        cursor:                      inherit;
        background-color:            transparent;
        text-color:                  inherit;
    }
  '';
}
