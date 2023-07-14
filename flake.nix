{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        with nixpkgs.legacyPackages.${system};
        {
          formatter = nixpkgs-fmt;
          packages.default = stdenv.mkDerivation rec {
            pname = "chatgpt-shell-cli";
            # https://github.com/0xacx/chatGPT-shell-cli/blob/926587a2234b8ae3754a1db9715f4636205159dc/internal_dev/debmaker.sh#L117
            version = "0.0.1";
            src = self;

            buildInputs = [
              jq
              curl
            ];

            installPhase = ''
              install -D chatgpt.sh -t $out/bin
            '';

            meta = with lib; {
              homepage = "https://github.com/Freed-Wu/chatgpt-shell-cli";
              description = "";
              license = licenses.mit;
              maintainers = with maintainers; [ Freed-Wu ];
              platforms = platforms.unix;
            };
          };
        }
      );
}
