inputs:
with inputs;
with free.python3Packages;

buildPythonPackage rec {
  pname = "notify-send.py";
  version = "0.1.0";
  format = "flit";
  src = ./.;
  propagatedBuildInputs = [
  dbus-python pygobject3
  ];
}
