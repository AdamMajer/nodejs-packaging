# This is only run on NodeJS official releases
#
s,{{URL}},Url:            https://nodejs.org,
s,{{SOURCES}},Source:         https://nodejs.org/dist/v%{version}/node-v%{version}.tar.xz \
Source1:        https://nodejs.org/dist/v%{version}/SHASUMS256.txt \
Source2:        https://nodejs.org/dist/v%{version}/SHASUMS256.txt.sig \
Source3:        nodejs.keyring,

