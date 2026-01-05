{ account, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = account.realname;
        email = account.email;
      };
    };
    signing = {
      key = builtins.head account.gpgkeys;
    };
  };
}
