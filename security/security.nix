inputs: with inputs;
with utility;
with builtins;
with lib;
{
  services = {
    usbguard = {
      enable = true;
      restoreControllerDeviceState = true;
      rules = (if pathExists ./usbguard.rules
               then readFile ./usbguard.rules
               else "")
            + (readFile ./usbguard-default.rules);
    };
    opensnitch = {
      enable = true;
    };
  };
}
