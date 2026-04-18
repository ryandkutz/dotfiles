{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader - Gen 2 VM (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use hyperv_drm instead of hyperv_fb for better RDP/enhanced session support
  boot.blacklistedKernelModules = [ "hyperv_fb" ];

  networking.hostName = "nixos-dev";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 + KDE Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.printing.enable = false;

  # Hyper-V guest integration services
  virtualisation.hypervGuest.enable = true;

  # XRDP with vsock patch for Hyper-V enhanced session
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "startplasma-x11";
    package = pkgs.xrdp.overrideAttrs (old: {
      configureFlags = (old.configureFlags or []) ++ [ "--enable-vsock" ];
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/etc/xrdp/xrdp.ini \
          --replace "use_vsock=false" "use_vsock=true" \
          --replace "port=3389" "port=vsock://-1:3389"
      '';
    });
  };

  systemd.services.xrdp.serviceConfig.ExecStart = lib.mkForce "${config.services.xrdp.package}/bin/xrdp --nodaemon --config /run/xrdp/xrdp.ini";

  # Required for xrdp to start X sessions
  environment.etc."X11/Xwrapper.config".text = ''
    allowed_users=anybody
  '';

  # User account
  users.users.ryan = {
    isNormalUser = true;
    description = "Ryan";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    # initialPassword = "changeme";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;

  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    # Core shell/CLI
    vim
    neovim
    wget
    curl
    git
    gh
    zsh
    tmux
    htop
    btop
    tree
    ripgrep
    fd
    fzf
    bat
    eza
    jq
    yq-go
    unzip
    zip
    file
    which
    dig
    openssh
    gnupg
    rcm

    # Editors / IDEs
    vscode

    # Languages & toolchains
    go
    python3
    python3Packages.pip
    nodejs_20
    rustup

    # Kubernetes
    kubectl
    kubectx
    kubernetes-helm
    k9s
    stern
    kustomize
    kind
    minikube
    fluxcd
    argocd
    cilium-cli
    istioctl

    # Cloud / IaC
    terraform
    opentofu
    azure-cli
    kubelogin

    # Container tooling
    docker-compose
    dive
    lazydocker

    # Misc dev
    gnumake
    gcc
    pkg-config
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-color-emoji
  ];

  system.stateVersion = "25.11";
}
