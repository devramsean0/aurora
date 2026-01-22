{ config, lib, pkgs, ... }:
{
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
        "network" = {
          format =  "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
        };
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
