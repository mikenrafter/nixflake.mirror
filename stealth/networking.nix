inputs: with inputs;
{
  networking.networkmanager = {
    wifi.macAddress = "random";
    dispatcherScripts =
      [ {
        source = pkgs.writeText "upHook" ''

          RAND = `echo $RANDOM | md5sum`
          NAME = DESKTOP-${RAND^^}
          hostnamectl set-hostname $NAME &&
          logger "Hostname randomized to ${NAME}" ||
          logger "Hostname randomization failed"
      '';
        type = "pre-up";
      } ];
  };
}
