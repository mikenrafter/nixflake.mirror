inputs: with inputs; with utility;
{
  systemd.tmpfiles.rules = [
    (ln "/var/lib/NetworkManager/secret_key" )
    (ln "/var/lib/NetworkManager/seen-bssids")
    (ln "/var/lib/NetworkManager/timestamps" )
  ];
  environment.etc = {
    shadow.source = "/persist/etc/shadow";
    nixos.source  = "/persist/etc/nixos";
    NIXOS.source  = "/persist/etc/NIXOS";

    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";

    adjtime.source = "/persist/etc/adjtime";
    machine-id.source = "/persist/etc/machine-id";
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
