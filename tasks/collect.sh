#!/bin/bash

# Variables that need to be interpolated as part of the command won't show up here
# Should still be useful
_debug () {
  echo "DEBUG: running $@" >>"$_tmp.debug"
}

declare PT__installdir
source "$PT__installdir/healthcheck_lite/files/common.sh"
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

shopt -s nullglob extglob globstar || fail "This utility requires Bash >=4.0"
trap '_debug $BASH_COMMAND' DEBUG

(( $EUID == 0 )) || fail "This utility must be run as root"

tmp_dir=/var/tmp/puppet_modules
output_dir=/var/tmp/health_check_lite
output_file="$output_dir/health_check_lite.txt"
support_script_output_file="$output_dir/support_script_output.log"
# Not currently a parameter
ticket="${ticket:-HCL}"

[[ -d $output_dir ]] || {
  mkdir "$output_dir" || fail "Error creating output directory"
}

# Remove any files from previous runs
find "$output_dir" -mindepth 1 -delete || fail "Error removing previous files"

# Clone stdout, then redirect it to our output file for the following steps.
exec 3>&1
exec >>"$output_file"

echo "Puppet Enterprise HealthCheck Lite: $(date)"
echo

grep -i -v UUID /etc/puppetlabs/license.key

if puppet enterprise support --help | grep -q -- '--log-age'; then
  sup_args+=("--log-age" "3")
fi

if puppet enterprise support --help | grep -q -- '--classifier'; then
  sup_args+=("--classifier")
fi

if puppet enterprise support --help | grep -q -- '--dir'; then
  sup_args+=("--dir" "$output_dir")
fi

puppet enterprise support "${sup_args[@]}" &> "$support_script_output_file"

# Set --modulepath if we installed pe_tune to the temp directory
if [[ -d $tmp_dir/pe_tune ]]; then
  tune_cmd=("puppet" "pe" "tune" "--modulepath" "$tmp_dir")
else
  tune_cmd=("puppet" "infra" "tune")
fi

"${tune_cmd[@]}"
"${tune_cmd[@]}" --current

# If we don't have --dir, we'll need to find where the support script output landed
# Use globstar to find the newest file under /var/tmp and /tmp
if [[ ! ${sup_args[@]} =~ "--dir" ]]; then
  for f in /tmp/**/puppet_enterprise_support*gz /var/tmp/**/puppet_enterprise_support*gz; do
    [[ $f -nt $newest ]] && newest="$f"
  done

  [[ $newest ]] || fail "Error running support script"
  mv "$newest" "$output_dir"
fi

# Redirect stdout back to the original terminal/calling program
exec >&3

# Hack-ish, but we can tar everything into one file by unzipping, adding to the tarball, and zipping again
cd "$output_dir"
# We previously removed everything, so this should be the only .tar.gz
tarball=(*gz)
[[ -e $tarball ]] || fail "Error running support script"
gunzip "$tarball" || fail "Error building tarball"
tar uf "${tarball%*.gz}" !(*tar) "$_tmp" "$_tmp.debug" || fail "Error building tarball"
gzip "${tarball%*.gz}" || fail "Error building tarball"
rm !(*gz) || fail "Error building tarball"
cd - &>/dev/null

success \
  "{ \"status\": \"HealthCheck Lite complete. Please upload the resultant file to Puppet\", \"file\": \"${output_dir}/${tarball}\" }"
