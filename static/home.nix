{ config, lib, pkgs, ... }:

let
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.keyboard = {
    layout = "us,gr";
    options = [
      #"compose:ralt"
    ];
  };

  home.packages = (let
    core = [
      pkgs.file
      pkgs.moreutils
      pkgs.tree
    ];
    editors = [
      pkgs.hunspell
    ] ++ hunspellDicts ++ [
      pkgs.emacs-all-the-icons-fonts
    ];
    fonts-base = [
      pkgs.dejavu_fonts
      pkgs.liberation_ttf
      pkgs.noto-fonts
      pkgs.symbola
    ];
    xorg-fonts-misc = [
      pkgs.xorg.fontarabicmisc
      pkgs.xorg.fontcursormisc
      pkgs.xorg.fontdaewoomisc
      pkgs.xorg.fontdecmisc
      pkgs.xorg.fontisasmisc
      pkgs.xorg.fontjismisc
      pkgs.xorg.fontmicromisc
      pkgs.xorg.fontmiscethiopic
      pkgs.xorg.fontmiscmeltho
      pkgs.xorg.fontmiscmisc
      pkgs.xorg.fontmuttmisc
      pkgs.xorg.fontschumachermisc
      pkgs.xorg.fontsonymisc
      pkgs.xorg.fontsunmisc
    ];
    fonts-extended-lt = fonts-base ++ [
      pkgs.caladea
      pkgs.cantarell-fonts
      pkgs.carlito
      # pkgs.font-droid (dropped in favor of noto?)
      # ttf-gelasio ( http://sorkintype.com/ )
      pkgs.google-fonts
      # gsfonts ( https://github.com/ArtifexSoftware/urw-base35-fonts )
      pkgs.gyre-fonts
      # ttf-impallari-cantora
      # ttf-signika ( https://fonts.google.com/specimen/Signika )
      pkgs.ubuntu_font_family
    ]; # ++ xorg-fonts-misc;
    fonts = fonts-extended-lt ++ [
      pkgs.corefonts
      pkgs.raleway
      # pkgs.vistafonts
    ];
    hunspellDicts = [
      pkgs.hunspellDicts.en-us
    ];

    media = [
      pkgs.ffmpeg
    ];

    misc = [
      pkgs.cowsay
      pkgs.fortune
      pkgs.w3m-full
      pkgs.megatools
      pkgs.ponysay
      pkgs.units
      pkgs.pstree
    ];
    nix = [
      pkgs.cachix
      # pkgs.niv.niv
      pkgs.nix-diff
      pkgs.nix-index
      pkgs.nix-top
      # pkgs.vulnix
    ];
    tools = [
      #pkgs.androidenv.androidPkgs_9_0.platform-tools
      pkgs.asciinema
      # pkgs.asciinema-edit
      pkgs.bind
      # pkgs.binutils
      pkgs.colordiff
      pkgs.diffstat
      #pkgs.nur.repos.bb010g.dwdiff
      pkgs.gitAndTools.git-imerge
      #pkgs.nur.repos.bb010g.git-revise
      pkgs.gnumake
      pkgs.hecate
      pkgs.hyperfine
      pkgs.icdiff
      #pkgs.nur.repos.mic92.inxi
      pkgs.ispell
      pkgs.just
      pkgs.lzip
      #pkgs-unstable.nur.repos.bb010g.mosh-unstable
      pkgs.ngrok
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs.sbcl
      pkgs.sublime-merge
      pkgs.tokei
      #pkgs.nur.repos.bb010g.ttyd
      pkgs.unzip
      #pkgs.nur.repos.bb010g.ydiff
      pkgs.terra
      pkgs.winetricks
      pkgs.protontricks
      pkgs.usbutils
    ];

    gui = lib.concatLists [
      gui-core
      gui-games
      gui-media
      gui-misc
      gui-tools
    ];

    gui-core = [
      pkgs.arandr
      pkgs.breeze-icons
      pkgs.breeze-qt5
      pkgs.glxinfo
      pkgs.gnome3.adwaita-icon-theme
      #pkgs-unstable.nur.repos.nexromancers.hacksaw
      pkgs.hicolor-icon-theme
      #pkgs-unstable.nur.repos.nexromancers.shotgun
      #pkgs.nur.repos.bb010g.st-bb010g-unstable
      pkgs.xsel
    ];

    gui-games = [
      pkgs.scummvm
      (pkgs.steam.override {
        # nativeOnly = true;
        extraPkgs = p: with p; [usbutils lsb-release procps dbus_daemon];
      })
      pkgs.steam-run-native
      pkgs.stepmania
      pkgs.lutris
    ];

    gui-media = [
      pkgs.evince
      pkgs.geeqie
      pkgs.gimp
      #pkgs-unstable-bb010g.grafx2
      pkgs.inkscape
      pkgs.kdeApplications.kolourpaint
      pkgs.krita
      (pkgs.mpv.override rec {
        archiveSupport = true;
        openalSupport = true;
      })
      pkgs.mtpaint
      pkgs.pinta
      pkgs.sxiv
      pkgs.youtube-dl
      pkgs.thunderbird
      pkgs.libsForQt5.vlc
    ];

    gui-misc = [
      pkgs.discord
      pkgs.zulip
      # ((pkgs.nur.repos.mozilla.lib.firefoxOverlay.firefoxVersion {
      #   name = "Firefox Nightly";
      #   # https://product-details.mozilla.org/1.0/firefox_versions.json
      #   #  : FIREFOX_NIGHTLY
      #   inherit (sources.firefox-nightly) version;
      #   # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
      #   # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
      #   #  : download -> url -> (parse)
      #   #  - https://archive.mozilla.org/pub/firefox/nightly/%Y/%m/%Y-%m-%d-%H-%m-%s-mozilla-central/firefox-${version}.en-US.${system}.tar.bz2
      #   #  : build -> date -> (parse) also works
      #   #  - %Y-%m-%dT%H:%m:%sZ
      #   #  need %Y-%m-%d-%H-%m-%s
      #   inherit (sources.firefox-nightly) timestamp;
      #   release = false;
      # }).overrideAttrs (o: {
      #   buildCommand = lib.replaceStrings [ ''
      #     --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
      #   '' ] [ ''
      #     --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
      #     --set SNAP_NAME firefox \
      #   '' ] o.buildCommand;
      # }))
      # pkgs.google-chrome
      pkgs.keybase-gui
      pkgs.mumble
      # for Firefox MozLz4a JSON files (.jsonlz4)
      # pkgs-unstable.nur.repos.bb010g.mozlz4-tool
      # (pkgs-unstable.qutebrowser.overrideAttrs (o: {
      #   buildInputs = o.buildInputs ++ hunspellDicts;
      # }))
      # pkgs-unstable.riot-desktop
      pkgs.tdesktop
      pkgs.texstudio
      # pkgs-unstable.wire-desktop
      pkgs.yed
    ];

    gui-tools = [
      pkgs.cantata
      pkgs.cmst
      pkgs.dmenu
      pkgs.freerdp
      pkgs.gnome3.gnome-system-monitor
      pkgs.ksysguard
      # pkgs-unstable-bb010g.nur.repos.bb010g.ipscan
      pkgs.notify-desktop
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.remmina
      pkgs.sqlitebrowser
      pkgs.surf
      pkgs.wireshark
      # pkgs-unstable.nur.repos.bb010g.xcolor
      pkgs.xournal
      pkgs.xorg.xbacklight
      pkgs.nextcloud-client
      pkgs.bcompare
    ];
  in lib.concatLists [
    core
    editors
    fonts
    gui
    media
    misc
    nix
    tools
  ]);

  services.unclutter = {
    enable = true;
    timeout = 5;
  };

  programs.alacritty = {
    enable = true;
  };

  programs.direnv = {enable = true;};
  programs.emacs = {enable = true;};
  programs.feh = {enable = true;};

  programs.git = {
    enable = true;
    # status = {
    #   submoduleSummary = "true";
    #   showStash = "true";
    # };
    # push = {
    #   recurseSubmodules = "check";
    # };
    # github = {
    #   user = "aiverson";
    # };
    package = pkgs.gitAndTools.gitFull;
    userEmail = "alexjiverson@gmail.com";
    userName = "aiverson";
  };

  programs.htop = {
    enable = true;
  };

  # programs.jq = {
  #   enable = true;
  # };

  programs.obs-studio = {
    enable = true;
  };

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs)
      collection-bibtexextra
      collection-context
      collection-fontsextra
      collection-formatsextra
      collection-games
      collection-humanities
      collection-latexextra
      collection-luatex
      collection-mathscience
      collection-music
      collection-pictures
      collection-pstricks
      collection-publishers
      scheme-small
      scheme-tetex
    ; };
  };

  # programs.tmux = {
  #   enable = true;
  # };

  # programs.zsh = (let
  #   inherit (lib) concatStringsSep;
  #   filterAttrs = f: e: lib.filter (n: f n e.${n}) (lib.attrNames e);
  #   trueAttrs = filterAttrs (n: v: v == true);
  #   zshAutoFunctions = {
  #     run-help = true;
  #     zargs = true;
  #     zcalc = true;
  #     zed = true;
  #     zmathfunc = true;
  #     zmv = true;
  #   };
  #   zshModules = {
  #     "zsh/complist" = true;
  #     "zsh/files" = ["-Fm" "b:zf_\\*"];
  #     "zsh/mathfunc" = true;
  #     "zsh/termcap" = true;
  #     "zsh/terminfo" = true;
  #   };
  #   zshOptions = [
  #     "APPEND_HISTORY"
  #     "AUTO_PUSHD"
  #     "COMPLETE_IN_WORD"
  #     "NO_BEEP"
  #     "EXTENDED_GLOB"
  #     "GLOB_COMPLETE"
  #     "GLOB_STAR_SHORT"
  #     "HIST_IGNORE_SPACE"
  #     "HIST_REDUCE_BLANKS"
  #     "HIST_SUBST_PATTERN"
  #     "HIST_VERIFY"
  #     "INTERACTIVE_COMMENTS"
  #     "KSH_GLOB"
  #     "LONG_LIST_JOBS"
  #     "NULL_GLOB"
  #     "PIPE_FAIL"
  #     "PROMPT_CR"
  #     "PROMPT_SP"
  #     "NO_RM_STAR_SILENT"
  #     "RM_STAR_WAIT"
  #   ];
  # in {
  #   enable = true;
  #   enableAutosuggestions = true;
  #   enableCompletion = true;
  #   # completionInit = /*zsh*/''
  #   #   setopt EXTENDED_GLOB
  #   #   autoload -U compinit
  #   #   for dump in ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+1); do
  #   #     compinit
  #   #     if [[ -s "$dump" && (! -s "$dump.zwc" || "$dump" -nt "$dump.zwc") ]]; then
  #   #       touch "$dump"
  #   #       zcompile "$dump"
  #   #     else
  #   #       touch "$dump"
  #   #       touch "$dump.zwc"
  #   #     fi
  #   #   done
  #   #   compinit -C
  #   # '';
  #   history = {
  #     expireDuplicatesFirst = true;
  #     extended = true;
  #     share = true;
  #     size = 100000;
  #   };
  #   initExtra = /*zsh*/''
  #     setopt ${concatStringsSep " " zshOptions}

  #     unalias run-help
  #     zmodload ${concatStringsSep " " (trueAttrs zshModules)}${
  #     concatStringsSep "\n" ([""] ++ (map
  #       (n: "zmodload ${lib.head zshModules.${n}} ${n} ${concatStringsSep " " (lib.tail zshModules.${n})}")
  #       (filterAttrs (n: v: lib.isList v) zshModules)
  #     ))}
  #     autoload -Uz ${concatStringsSep " " (trueAttrs zshAutoFunctions)}

  #     zmathfunc

  #     alias sudo='sudo '
  #     eval "$(dircolors -b)"
  #     alias ls='ls --color=auto -F '
  #     alias tree='tree -F '

  #     # for fast-syntax-highlighting
  #     zstyle :plugin:history-search-multi-word reset-prompt-protect 1

  #     zstyle ':completion:*' menu yes select

  #     # keyboard bindings
  #     #
  #     # if Zsh isn't working with your keyboard properly, try the following:
  #     #   autoload -Uz zkbd; zkbd
  #     # follow the prompts, and restart if necessary.
  #     # the file name printed at the end should match the output of:
  #     #   echo - "''${ZDOTDIR:-$HOME}/.zkbd/$TERM-$VENDOR-$OSTYPE"
  #     # move the file if necessary.
  #     typeset -g -A key
  #     load-bindkeys() {
  #       local zkbd_file="''${ZDOTDIR:-$HOME}/.zkbd/''${1:-$TERM-$VENDOR-$OSTYPE}"
  #       if [[ -e "$zkbd_file" ]]; then source "$zkbd_file"; fi

  #       _key-set() {
  #         local k="$1"; shift
  #         if (( ''${+key[$k]} )); then return; fi
  #         while (( ''${+1} )); do
  #           1="$(cat -v <<< "$1")"
  #           # print -r "key: changing $k from ''${(q+)key[$k]} to ''${(q+)1}"
  #           key[$k]="$1"
  #           if [[ -n "$1" ]]; then break; else shift; fi
  #         done
  #       }

  #       _key-set F1 "''${terminfo[kf1]}" "''${termcap[k1]}"
  #       _key-set F2 "''${terminfo[kf2]}" "''${termcap[k2]}"
  #       _key-set F3 "''${terminfo[kf3]}" "''${termcap[k3]}"
  #       _key-set F4 "''${terminfo[kf4]}" "''${termcap[k4]}"
  #       _key-set F5 "''${terminfo[kf5]}" "''${termcap[k5]}"
  #       _key-set F6 "''${terminfo[kf6]}" "''${termcap[k6]}"
  #       _key-set F7 "''${terminfo[kf7]}" "''${termcap[k7]}"
  #       _key-set F8 "''${terminfo[kf8]}" "''${termcap[k8]}"
  #       _key-set F9 "''${terminfo[kf9]}" "''${termcap[k9]}"
  #       _key-set F10 "''${terminfo[kf10]}" "''${termcap[F1]}"
  #       _key-set F11 "''${terminfo[kf11]}" "''${termcap[F2]}"
  #       _key-set F12 "''${terminfo[kf12]}" "''${termcap[F3]}"
  #       _key-set Backspace "''${terminfo[kbs]}" "''${termcap[kb]}"
  #       _key-set Insert "''${terminfo[kich1]}" "''${termcap[kI]}"
  #       _key-set Home "''${terminfo[khome]}" "''${termcap[kh]}"
  #       _key-set PageUp "''${terminfo[kpp]}" "''${termcap[kP]}"
  #       _key-set Delete "''${terminfo[kdch1]}" "''${termcap[kD]}"
  #       _key-set End "''${terminfo[kend]}" "''${termcap[@7]}"
  #       _key-set PageDown "''${terminfo[knp]}" "''${termcap[kN]}"
  #       _key-set BackTab "''${terminfo[cbt]}" "''${termcap[bt]}"
  #       _key-set Tab "''${terminfo[ht]}" "''${termcap[ta]}"
  #       _key-set Up "''${terminfo[kcuu1]}" "''${termcap[ku]}"
  #       _key-set Left "''${terminfo[kcub1]}" "''${termcap[kl]}"
  #       _key-set Down "''${terminfo[kcud1]}" "''${termcap[kd]}"
  #       _key-set Right "''${terminfo[kcuf1]}" "''${termcap[kr]}"

  #       bindkey -M menuselect '/' history-incremental-search-backward
  #       bindkey -M menuselect '?' history-incremental-search-forward
  #       [[ -n "''${key[BackTab]}" ]] && bindkey -M menuselect "''${key[BackTab]}" reverse-menu-complete

  #       unset -f _key-set
  #     }
  #     load-bindkeys

  #     # make sure term is in application mode when zle is active (for terminfo)
  #     # (thanks http://zshwiki.org/home/zle/bindkeys )
  #     if (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
  #       zle-line-init() { echoti smkx }; zle -N zle-line-init
  #       zle-line-finish() { echoti rmkx }; zle -N zle-line-finish
  #     fi
  #   '';
  #   # localVariables = {
  #   #   AGKOZAK_MULTILINE = "0";
  #   #   GENCOMPL_FPATH = "${config.xdg.cacheHome}/zsh-completion-generator";
  #   #   GENCOMPL_PY = "${pkgs.python3}/bin/python";
  #   #   TIMEFMT = ''
  #   #     %J   %U  user %S system %P cpu %*E total
  #   #     avg shared (code):         %X KB
  #   #     avg unshared (data/stack): %D KB
  #   #     total (sum):               %K KB
  #   #     max memory:                %M MB
  #   #     page faults from disk:     %F
  #   #     other page faults:         %R'';
  #   # };
  #   plugins = [
  #     # ordered
  #     #rec {
  #     #  name = "history-search-multi-word";
  #     #  src = sources.zsh-history-search-multi-word;
  #     #  file = "${name}.plugin.zsh";
  #     #}
  #     #rec {
  #     #  name = "autosuggestions";
  #     #  src = sources.zsh-autosuggestions;
  #     #  file = "zsh-${name}.plugin.zsh";
  #     #}
  #     # unordered
  #     # rec {
  #     #   name = "autoenv";
  #     #   src = builtins.toPath "${config.home.homeDirectory}/Documents/zsh-${name}";
  #     #   # src = sources.zsh-autoenv;
  #     #   file = "${name}.plugin.zsh";
  #     # }
  #     #rec {
  #     #  name = "nix-shell";
  #     #  src = sources.zsh-nix-shell;
  #     #  file = "${name}.plugin.zsh";
  #     #}
  #     # rec {
  #     #   name = "completion-generator";
  #     #   src = sources.zsh-completion-generator;
  #     #   file = "zsh-${name}.plugin.zsh";
  #     # }
  #     # ordered
  #     #rec {
  #     #  name = "fast-syntax-highlighting";
  #     #  src = sources.zsh-fast-syntax-highlighting;
  #     #  file = "${name}.plugin.zsh";
  #     #}
  #     #rec {
  #     #  name = "agkozak-zsh-prompt";
  #     #  src = sources.zsh-agkozak-zsh-prompt;
  #     #  file = "${name}.plugin.zsh";
  #     #}
  #   ];
  # });

  services.dunst = {
    enable = true;
  };

  xdg = {
    enable = true;

    configFile = {
      "fontconfig/fonts.conf".text = /*xml*/''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Ubuntu Mono</family>
    </prefer>
  </alias>
</fontconfig>
'';

      "nix/nix.conf".text = /*conf*/''
auto-optimise-store = true
keep-derivations = true
keep-outputs = true
'';
    };
  };

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = let
        zipToAttrs = lib.zipListsWith (n: v: { ${n} = v; });
        mergeAttrList = lib.foldr lib.mergeAttrs {};
        mergeAttrMap = f: l: mergeAttrList (lib.concatMap f l);

        modifier = "Mod4";
        arrowKeys = [ "Left" "Down" "Up" "Right" ];
        viKeys = [ "h" "j" "k" "l" ];
        workspaceNames = builtins.map toString (lib.range 1 40);
        workspaceKeys = lib.crossLists (m: k: "${m}${k}") [["" "Ctrl+" "Mod1+" "Ctrl+Mod1+"] [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ]];

        fonts = [ "monospace 10" ];

        dirNames = [ "left" "down" "up" "right" ];
        resizeActions = [ "shrink width" "grow height" "shrink height" "grow width" ];
        mode_system = "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown";
      in {
        bars = [ { inherit fonts; position = "bottom"; } ];
        inherit fonts;
        keybindings =  mergeAttrList [
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+${k}") ks) (map (d: "focus ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Shift+${k}") ks) (map (d: "move ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Ctrl+${k}") ks) (map (d: "move container to output ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Ctrl+Shift+${k}") ks) (map (d: "move workspace to output ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+${k}") workspaceKeys) (map (d: "workspace ${d}") workspaceNames)))
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+Shift+${k}") workspaceKeys) (map (d: "move workspace ${d}") workspaceNames)))
          {
            "${modifier}+Return" = "exec st";
            "${modifier}+Shift+Return" = "exec ${pkgs.enlightenment.terminology}/bin/terminology";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

            "${modifier}+a" = "focus parent";

            "${modifier}+r" = "mode resize";
            "${modifier}+Pause" = "mode \"${mode_system}\"";

            "${modifier}+g" = "split h";
            "${modifier}+v" = "split v";
            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";
            "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
            #"${modifier}+Control+q" = "exec bash -c \"i3-nagbar -t warning -m 'do you want to kill this window $(${pkgs.xdotool}/bin/xdotool selectwindow getwindowpid)\"";
            "--release ${modifier}+Ctrl+q" = "exec ${pkgs.xorg.xkill}/bin/xkill";
          }
        ];
        modes = {
          resize = mergeAttrList [
            (mergeAttrMap (ks: zipToAttrs ks (map (a: "resize ${a}") resizeActions)) [ viKeys arrowKeys ])
            {
              "Escape" = "mode default";
              "Return" = "mode default";
            }
          ];
          "${mode_system}" = let lock_command = "i3lock -c 555555";
                                 act_then_lock = (act: "${act} ; exec ${lock_command} ; mode default");
                             in {
            "l" = "exec ${lock_command}; mode default";
            "e" = "exec i3-msg exit";
            "s" = act_then_lock "exec systemctl suspend";
            "h" = act_then_lock "exec systemctl hibernate";
            "r" = "exec systemctl reboot";
            "Shift+s" = "exec systemctl poweroff";

            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };
        inherit modifier;
      };
    };
  };
}
