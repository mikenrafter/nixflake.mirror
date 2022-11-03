inputs: with inputs; with utility;
{
  environment.persistence."/persist/cache" = {
    hideMounts = true;
    directories = [
      "/root/.cache"
    ];
    files = [
    ];
  };
}
