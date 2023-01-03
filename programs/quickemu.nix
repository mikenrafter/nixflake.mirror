##bash ~/.nix/build.sh
inputs: with inputs;
with frozen;
stdenv.mkDerivation rec {
	name = "quickemu";
	version="testing";
	src = fetchgit {
		url = "https://github.com/wimpysworld/quickemu.git";
		rev = "5c0a7885c9505e17dbad702d954d37838102bb20";
		sha256 = "85u8c3x9CUfviFZnix6s8J++zti8Ped6SK/YC6GTQ/M=";
	};
	buildInputs = [
		bash python38
		cdrtools
		coreutils #sed
		edk2 #-ovmf
		jq
		procps
		qemu
		spice-gtk
		swtpm
		usbutils
		util-linux
		wget
		xorg.xrandr
		zsync
		OVMFFull
		# OVMF-CSM
		# OVMF-secureBoot
		swtpm
		swtpm-tpm2
	];
	buildPhase = ''
	'';
	installPhase = ''
		mkdir -p $out/bin
		cp macrecovery quickemu quickget $out/bin
	'';
	meta = with lib; {
		description = "Scripts for quick and optimal setup of Linux/Mac/Windows virtual guests. (Qemu)";
		homepage = "https://github.com/wimpysworld/quickemu";
		license = licenses.mit;
		platforms = platforms.linux;
	};
}
