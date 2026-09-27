# shell.nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    llvmPackages.clang-unwrapped
    llvmPackages.lld
    llvmPackages.llvm

    gnumake

    dosfstools
    mtools

    util-linux

    qemu
  ];

  buildInputs = with pkgs; [ ];
}
