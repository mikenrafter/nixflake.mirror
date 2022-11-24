inputs: with inputs; with utility;
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NIXOS"
      "/etc/NetworkManager/system-connections"
      "/var/lib/systemd/coredump"
      "/var/lib/docker"
      "/var/lib/lxd"
    ];
    files = [
      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"
      "/etc/machine-id"
      "/etc/adjtime"
      #"/etc/shadow"
    ];
  };
  #systemd.tmpfiles.rules = [
  #  (ln "/var/lib/NetworkManager/secret_key" )
  #];
  environment.etc = {
    #shadow.source = "/persist/etc/shadow";
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
