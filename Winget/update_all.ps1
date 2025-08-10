<#
  To update all applications as part of imaging process.
  Requires desktop app installer to be above a certain version.
#>

winget upgrade --all --silent --include-unknown --accept-package-agreements --force --verbose
