{ lib
, coreutils
, fetchurl
, gawk
, makeWrapper
, procps
, runCommand
, unzip
, zip
, environment
}:

with lib;
let
  openhab-cli = fetchurl {
    url = "https://raw.githubusercontent.com/openhab/openhab-linuxpkg/857165ab1c6437c701423cfc59e107b7299d33b4/resources/usr/bin/openhab-cli";
    sha256 = "sha256-KV1alUzPKIPColJliNujGBR7Ep2zswviqBNhPaSMBkY=";
    postFetch = ''
      patch -f $out <${./openhab-cli.patch}
    '';
  };
in
runCommand "openhab-cli"
{
  nativeBuildInputs = [ makeWrapper ];

  meta = {
    description = "Utility script to simplify the use of openHAB";
    homepage = "https://github.com/openhab/openhab-linuxpkg";
    license = licenses.epl20;
  };
} ''
  install -D -m 555 ${openhab-cli} $out/bin/openhab-cli
  wrapProgram $out/bin/openhab-cli \
    ${concatStrings (mapAttrsToList (n: v: ''
      --set ${n} ${v} \
    '') environment)
    } --prefix PATH : "${lib.makeBinPath [ coreutils zip unzip gawk procps ]}"
''
