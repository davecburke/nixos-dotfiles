{ pkgs, ... }:
{
    users.users.dave = {
        isNormalUser = true;
        description = "David Burke";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
        #  thunderbird
        ];
        openssh.authorizedKeys.keys = [
        # Add your public keys here
        # Example: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... dave@laptop"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhg6D0OXHNT/HxtRiiK/8H3pGc9frkkKS9QeBs2kFKtS/LOCXpjGY96ERAkPshBuDdQOiGw8VNmm4RvxhrYU5+5OYK84rmTEt3SveLYtB+vVqsxDSvo3TL95Ek7SZBQkkX8ANYMtB3m7FFOQ48uLU2ons/hZQX/VU3gjOHDIeYWUQyCcvM5wKASux7VlrfQxnWDSB1dtkmgppyCjcmjbmWgx6/tPZcbUeGI7sBSTUoyztb/ArYSDouw1Znl/SyjFtirBU/DETbB+ePUtqkD2tVyrC9j/YvCBR4HhWeK3HVp0lNPCWZNsST2cb+WVSbqe2JtZA9XTIkdc9WRn3L9feRtojbzF4C+x/3GNm93ll1pxPq1LiMKNhxP08qzu44impagZV5lU0Gr5bEKmJkz2GadQYLyd0caloZ6i9UsKF4idiTCjOfvTjTkLOA1K/Bd3y5DVrU7JO1DnUK4Gcgl5ZcQC2YsBA3oitPxMy4Nk6qECmXMRWHlaWDLXs8pVF5QjE= dave@david-HP-ZBook"
        ];
    };
}
