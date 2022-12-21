#!/bin/bash

set -Eeuo pipefail



### ARGS
vscode_extensions_dir=${1:-"$HOME/.vscode/extensions"}
vscode_version=${2:-$(code --version | head -n 1)}
_out_dir_default="exp/vsixes-$vscode_version-$(date +%s)"
out_dir="${3:-$_out_dir_default}"
nj="8"

echo "vscode_extensions_dir | $vscode_extensions_dir"
echo "vscode_version | $vscode_version"
echo "out_dir | $out_dir"
echo "nj | $nj"



### OPERATIONS
mkdir -p "$out_dir"



find "$vscode_extensions_dir" -mindepth 2 -maxdepth 2 -type f -name "package.json" \
    | while IFS= read f_package_json; do

        publisher=` cat ${f_package_json} | jq -r '.["publisher"]'`
        name=`      cat ${f_package_json} | jq -r '.["name"]'`
        version=`   cat ${f_package_json} | jq -r '.["version"]'`

        url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/${version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

        f_vsixes="$out_dir/${publisher}--${name}--${version}.vsix"

        aria2c -x "$nj" "$url" -o "$f_vsixes"

    done


