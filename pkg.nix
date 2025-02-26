{ stdenv
, lib
, fetchurl
, writeShellScript
, withAddons ? false
}:

let
  version = "3.4.1";

  updateScript = fetchurl {
    url = "https://github.com/openhab/openhab-docker/raw/8e1e2767fc36310dbc5ce87db54ac32780cd740a/debian/update";
    sha256 = "PqSn+bTqmOtg6K2BOssDyp05dqmfj15h1j/RqczWTUA=";
  };

  addons = fetchurl {
    url = "https://github.com/openhab/openhab-distro/releases/download/${version}/openhab-addons-${version}.kar";
    sha256 = "sha256-MvxGc5x1KSikT6AWXwcmhqBs/EOdjg2aEy9HaC2DMuM=";
  };
in
stdenv.mkDerivation {
  pname = "openhab";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openhab/openhab-distro/releases/download/${version}/openhab-${version}.tar.gz";
    sha256 = "sha256-Mvb2uv0lOtmjV/QbBtWIOZ+n5YidGhPS9u/GhQ4abAc=";
  };

  sourceRoot = ".";

  preUnpack = ''
    mkdir -p $out
    cd $out
  '';

  installPhase = ''
    find \( -name "*.bat" -o -name "*.ps1" -o -name "*.psm1" \) -delete
    
    mkdir $out/dist
    mv $out/conf $out/dist
    mv $out/userdata $out/dist

    sed '/You are already on openHAB/a exit 0' ${updateScript} > $out/runtime/bin/update

    install /dev/stdin $out/runtime/bin/copy-dist <<'EOF'
    #!/bin/sh -eu

    copyFolder() {
      if [ ! -e $1/$2 ]; then
        echo "Copying dist data to $1/$2"
        cp -a -t $1 ${placeholder "out"}/dist/$2
        chmod -R u+w $1/$2
      fi
    }

    copyFolder $1 conf
    copyFolder $1 userdata
    EOF
  '' + lib.optionalString withAddons ''
    ln -s ${addons} $out/addons/openhab-addons-${version}.kar
  '';

  meta = with lib; {
    description = "A vendor and technology agnostic open source automation software for your home";
    homepage = "https://www.openhab.org";
    license = licenses.epl20;
  };
}
