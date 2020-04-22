self: super:
let
  # Get sha256 by running nix-prefetch-url --unpack https://github.com/[owner]/[name]/archive/[rev].tar.gz
  customVimPlugins = with super.vimUtils; {
    vim-haskell-module-name = buildVimPluginFrom2Nix {
      name = "vim-haskell-module-name";
      src  = super.fetchFromGitHub {
        owner  = "chkno";
        repo   = "vim-haskell-module-name";
        rev    = "6dcd594";
        sha256 = "126p0i4mw1f9nmzh96yxymaizja5vbl6z9k1y3zqhxq9nglgdvxb";
      };
    };
    # Needed until PR lands in unstable channel
    # my-coc-nvim = buildVimPluginFrom2Nix rec {
    #   pname = "coc-nvim";
    #   version = "0.0.73";
    #   src = super.fetchFromGitHub {
    #     owner = "neoclide";
    #     repo = "coc.nvim";
    #     rev = "v${version}";
    #     sha256 = "1z7573rbh806nmkh75hr1kbhxr4jysv6k9x01fcyjfwricpa3cf7";
    #   };
    # };
  };
in {
  myNeovim = self.pkgs.neovim.override {
    configure = {
      customRC = ''
        source $HOME/.config/nixpkgs/configs/nvim/init.vim
      '';
      packages.myVimPackages = with self.pkgs.unstable.vimPlugins // customVimPlugins; {
        start = [
          # UI plugins
          airline
          NeoSolarized
          vim-airline-themes
          vim-choosewin
          vim-devicons
          vim-startify

          # other plugins
          ale
          coc-nvim
          editorconfig-vim
          goyo-vim
          tabular
          vim-commentary
          vim-eunuch
          vim-fugitive
          vim-haskell-module-name
          vim-pencil
          vim-polyglot
          vim-surround
        ];
      };
    };
  };

  nvr-edit = super.writeShellScriptBin "n" ''
    if test -n "$NVIM_LISTEN_ADDRESS"; then
      ${super.pkgs.neovim-remote}/bin/nvr $@
    else
      nvim $@
    fi
  '';

  nvr-split = super.writeShellScriptBin "nh" ''
    if test -n "$NVIM_LISTEN_ADDRESS"; then
      ${super.pkgs.neovim-remote}/bin/nvr -o $@
    else
      echo "Not in Neovim"
      exit 1
    fi
  '';

  nvr-vsplit = super.writeShellScriptBin "nv" ''
    if test -n "$NVIM_LISTEN_ADDRESS"; then
      ${super.pkgs.neovim-remote}/bin/nvr -O $@
    else
      echo "Not in Neovim"
      exit 1
    fi
  '';

  nvr-tab = super.writeShellScriptBin "nt" ''
    if test -n "$NVIM_LISTEN_ADDRESS"; then
      ${super.pkgs.neovim-remote}/bin/nvr --remote-tab $@
    else
      echo "Not in Neovim"
      exit 1
    fi
  '';

  myNeovimEnv = super.buildEnv {
    name = "NeovimEnv";
    paths = with self.pkgs; [
      myNeovim
      neovim-remote

      nvr-edit
      nvr-split
      nvr-vsplit
      nvr-tab
    ];
  };
}
