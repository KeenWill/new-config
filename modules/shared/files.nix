{ pkgs, config, ... }:

let
oldPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFVrWZkf6wERr0iwo4/LB2If1etVtlJRS6J3+yXdNM/a william@williamgoeller.com";
in
{

  # ".ssh/id_github.pub" = {
  #   text = githubPublicKey;
  # };

  ".ssh/id_ed25519_old.pub" = {
    text = oldPublicKey;
  };

  # ".ssh/id_ed25519_old" = {
  #   source = config.age.secrets.id_ed25519_old.path;
  # };

  # Initializes Emacs with org-mode so we can tangle the main config
  ".emacs.d/init.el" = {
    text = builtins.readFile ../shared/config/emacs/init.el;
  };
}
