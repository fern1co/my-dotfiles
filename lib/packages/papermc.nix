{ lib, stdenv, fetchurl, makeWrapper, jre }:

stdenv.mkDerivation rec {
  pname = "papermc";
  version = "1.21.10";
  build = "129";

  src = fetchurl {
    url = "https://api.papermc.io/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar";
    sha256 = "0c67b78bg977lfqq5gidn4krwwv7fh87mhmf2frcp7d069na5qvl";
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/papermc
    cp $src $out/lib/papermc/papermc.jar

    runHook postInstall
  '';

  meta = with lib; {
    description = "High performance Minecraft server implementation";
    homepage = "https://papermc.io";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
