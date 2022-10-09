# Copyright (c) 2022 Rivos Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
{
  lib,
  glibc,
  scons,
  stdenv,
  gitRef ? null,
  src,
  version,
}: let
  isaMappings = {
    x86_64 = "x86";
    arm64 = "arm64";
    riscv = "riscv";
  };
  targetISA = isaMappings."${stdenv.hostPlatform.linuxArch}";
in
  stdenv.mkDerivation rec {
    inherit src version;
    name = "gem5-m5ops-${version}";

    sourceRoot = "source/util/m5";

    buildInputs = lib.optional (stdenv.hostPlatform.libc == "glibc") glibc.static;

    nativeBuildInputs = [
      scons
    ];

    enableParallelBuilding = true;

    buildFlags = [
      "build/${targetISA}/out/m5"
      # TODO: this doesn't build
      #"build/${targetISA}/out/gem5OpJni.jar"
      "--verbose"
    ];

    installPhase = ''
      mkdir -p $out/{bin,lib}
      cp build/${targetISA}/out/m5 $out/bin/
      cp build/${targetISA}/out/libm5.a $out/lib/

      mkdir -p $out/include
      cp -r ${src}/include/* $out/include/
    '';

    meta = {
      description = "Gem5 m5ops";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.linux;
      homepage = "https://www.gem5.org/";
    };
  }
  // lib.optionalAttrs (gitRef != null) {GIT_COMMIT = gitRef;}
