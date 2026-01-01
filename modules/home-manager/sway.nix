{ config, lib, osConfig ? {}, ... }:

let
  mod = "Mod4";
  ws1 = "1";
  ws2 = "2";
  ws3 = "3";
  ws4 = "4";
  ws5 = "5";
  hostname = osConfig.networking.hostname or "";
in
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;

      fonts = {
        names = [ "FiraCode" ];
        size = 8.0;
      };

      floating.modifier = mod;

      window.border = 2;

      output = {
        "*" = {
          bg = "#222222 solid_color";
        };
      };

      colors = {
        focused = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
          indicator = "#2e9ef4";
          childBorder = "#285577";
        };
        focusedInactive = {
          border = "#333333";
          background = "#5f676a";
          text = "#ffffff";
          indicator = "#484e50";
          childBorder = "#5f676a";
        };
        unfocused = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292d2e";
          childBorder = "#222222";
        };
        urgent = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
          indicator = "#900000";
          childBorder = "#900000";
        };
        placeholder = {
          border = "#000000";
          background = "#0c0c0c";
          text = "#ffffff";
          indicator = "#000000";
          childBorder = "#0c0c0c";
        };
        background = "#ffffff";
      };

      input = lib.mkIf (hostname != "maximus") {
        "*" = {
          xkb_layout = "gb";
        };
      };

      keybindings = {
        "${mod}+0" = "workspace number 10";
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";

        "${mod}+Down" = "focus down";
        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up" = "focus up";

        "${mod}+j" = "focus left";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus up";
        "${mod}+semicolon" = "focus right";

        "${mod}+Return" = "exec alacritty";
	"${mod}+d" = "exec dmenu_run";

        "${mod}+Shift+0" = "move container to workspace number 10";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";

        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+semicolon" = "move right";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+Shift+w+1" = "move container to workspace number ${ws1}";
        "${mod}+Shift+w+2" = "move container to workspace number ${ws2}";
        "${mod}+Shift+w+3" = "move container to workspace number ${ws3}";
        "${mod}+Shift+w+4" = "move container to workspace number ${ws4}";
        "${mod}+Shift+w+5" = "move container to workspace number ${ws5}";

        "${mod}+w+1" = "workspace number ${ws1}";
        "${mod}+w+2" = "workspace number ${ws2}";
        "${mod}+w+3" = "workspace number ${ws3}";
        "${mod}+w+4" = "workspace number ${ws4}";
        "${mod}+w+5" = "workspace number ${ws5}";

        "${mod}+a" = "focus parent";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+h" = "split h";
        "${mod}+v" = "split v";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";

        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
        "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
        "XF86MonBrightnessUp" = "exec xbacklight -inc 20";

        "${mod}+r" = "mode resize";
        "${mod}+Shift+x" = "exec sh -c 'i3lock -c 222222 & sleep 5 && xset dpms force off'";

	# Screenshots
	"${mod}+Shift+s" = "exec grimshot save screen $screenshot_out";
	"${mod}+Shift+w" = "exec grimshot  save active $screenshot_out";
	"${mod}+Shift+a" = "exec grimshot save area $screenshot_out";
      };

      modes = {
        resize = {
          "Down" = "resize grow height 10 px or 10 ppt";
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      bars = [ ];

      startup = [
        { command = "nm-applet"; }
      ];
    };

    extraConfig = ''
      set $screenshot_out "/home/$USER/Pictures/screenshots/screenshot-$(date +"%Y%m%d-%H%M%S").png"
      default_border normal 2
      default_floating_border normal 2
      hide_edge_borders none
      focus_wrapping yes
      focus_follows_mouse yes
      focus_on_window_activation smart
      mouse_warping output
      workspace_layout default
      workspace_auto_back_and_forth no
    '';
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        modules-center = [ ];
        modules-right = [
          "backlight"
          "pulseaudio"
          "battery"
          "network"
          "clock"
        ];
        "clock" = { format = "{:%a %b %d %H:%M}"; };
        "pulseaudio" = { format = " {volume}%"; };
        "backlight" = { format = " {percent}%"; };
        "battery" = { format = "{capacity}%"; format-alt = "{power}W"; };
        "network" = { format-wifi = " {signal}%"; format-ethernet = " {ifname}"; };
      };
    };
    style = ''
      * {
        font-family: FiraCode, monospace;
        font-size: 10pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #222222;
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #888888;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
        background-color: #285577;
        color: #ffffff;
        border-bottom: 2px solid #4c7899;
      }

      #workspaces button.urgent {
        background-color: #900000;
        color: #ffffff;
      }

      #workspaces button:hover {
        background-color: #5f676a;
        color: #ffffff;
      }

      #mode,
      #clock,
      #battery,
      #backlight,
      #network,
      #pulseaudio {
        padding: 0 10px;
        margin: 0 2px;
      }
    '';
  };
}

