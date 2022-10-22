inputs: with inputs; with utility; let
  base    = "us";
  variant = "colemak";
  useVariant = false; # keep disabled... physical keyboard
in {}
// (if useVariant then { console.keyMap = variant; } else {})
// {
  services.xserver = {
    layout = base;
    xkbOptions = "compose:ralt";
  }
  // (if useVariant then { xkbVariant = variant; } else {})
  ;
}
