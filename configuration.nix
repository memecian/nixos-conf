{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/lenovo/thinkpad/t520>
      ./hardware-configuration.nix
    ];

  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    device = "%InstallDisk%"; # set to your device, e.g., "/dev/sda"
  };

  # Enable networking
  networking.hostName = "radicalengineer"; # Define your hostname
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
 # 18n.defaultLocale = "en_US.UTF-8";
 # i18n.extraLocaleSettings = {
 #   XKB_LAYOUT = "de";
 #   XKB_MODEL = "pc105";
 # };
  
  console = {
     font = "Lat2-Terminus16";
     keyMap = lib.mkDefault "de";
     useXkbConfig = true; # use xkb.options in tty.
  };
  

  # Services configuration
  services.xserver = {
    enable = true;
    layout = "de";
    xkbModel = "pc105";
    displayManager.startx.enable = true;
    #displayManager.defaultSession = "none+twm"; # No desktop manager, just a window manager
    desktopManager.budgie.enable = true;
    #windowManager.twm.enable = true;
    libinput.enable = true;
    videoDrivers = [ "nvidiaLegacy390" ];
  };
  hardware.pulseaudio.enable = false;
  services.getty.autologinUser = "memecian";
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  # If you want to use JACK applications, uncomment this
   #jack.enable = true;
  }; 

 # Enable CUPS to print documents.
  # services.printing.enable = true;

    security.pam.services.startx.text = ''
    auth    requisite       pam_nologin.so
    auth    required        pam_env.so
    account required        pam_unix.so
  '';
  programs.zsh.enable = true; 
  users.users.memecian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "sudo" ]; # add additional groups as needed
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      wget
    ];
    initialPassword = "love";
    openssh.authorizedKeys.keys = [
      "your-ssh-public-key"
    ];
  };
  
  
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Define global environment
  environment.systemPackages = with pkgs; [
    sudo
    twm
    firefox
    pipewire
    mpv
    pipx
    vim
    tmux
    pavucontrol
    helvum
    neofetch
    killall
  ];

   
  # Allow members of the wheel group to gain root privileges
  security.sudo.wheelNeedsPassword = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
