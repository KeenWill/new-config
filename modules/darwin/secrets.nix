{ config, pkgs, agenix, secrets, ... }:

let user = "williamgoeller"; in
{
  # Your secrets go here
  #
  # Note: the installWithSecrets command you ran to boostrap the machine actually copies over
  #       a Github key pair. However, if you want to store the keypair in your nix-secrets repo
  #       instead, you can reference the age files and specify the symlink path here. Then add your
  #       public key in shared/files.nix.
  #
  #       If you change the key name, you'll need to update the SSH extraConfig in shared/home-manager.nix
  #       so Github reads it correctly.

  # age.secrets.id_ed25519_old = {
    # rekeyFile = ./id_ed25519_old.age;
    # path = "/Users/${user}/.ssh/id_ed25519_old";
  # };
  # services.someService.passwordFile = config.age.secrets.id_ed25519_old.path;
  # ".ssh/id_ed25519_old" = {
  #   text = config.age.secrets.id_ed25519_old.path;
  # };

  
  # age.secrets."github-ssh-key" = {
  #   symlink = true;
  #   path = "/Users/${user}/.ssh/id_github";
  #   file =  "${secrets}/github-ssh-key.age";
  #   mode = "600";
  #   owner = "${user}";
  #   group = "staff";
  # };

  # age.secrets."github-signing-key" = {
  #   symlink = false;
  #   path = "/Users/${user}/.ssh/pgp_github.key";
  #   file =  "${secrets}/github-signing-key.age";
  #   mode = "600";
  #   owner = "${user}";
  # };

}
