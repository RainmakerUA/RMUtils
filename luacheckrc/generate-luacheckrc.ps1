param ([string] $outFolder = $PSScriptRoot)

$apiListPattern = '*.txt'
$outFileExt = '.luacheckrc'

$stdPrologueFormat = "stds.{0} = {{`n`tread_globals = {{`n"
$twoTabs = "`t`t"
$threeTabs = "`t`t`t"
$fourTabs = "`t`t`t`t"
$stdEpilogue = "`t}`n}"
$optionFlags = @{
	'' = '';
	'+' = 'other_fields = true';
}

function ParseFile([string]$fileName) {
	$outConfigPath = [IO.Path]::ChangeExtension($fileName, ".gen$outFileExt")
	$name = [IO.Path]::GetFileNameWithoutExtension($fileName) -replace '^\d+',''

	$stdPrologueFormat -f $name | Out-File -FilePath $outConfigPath -NoNewline
	(Get-Content -Path $fileName) |
		? { $_ -and $_ -inotmatch '^\-\-' } |
		% {
			$cls, $func = $_ -split '\.';
			@{cls = if (! $func) { $null } else { $cls }; func = if (! $func) { $cls } else { $func } }
		} |
		Group-Object -Property cls |
		Sort-Object -CaseSensitive -Property @{ Expression = { $_.Values[0] } } |
		% {
			$group = $_
			$cls = $group.Values[0]
			if (! $cls) {
				$group.Group | Sort-Object -CaseSensitive -Property func |
					% {
						$all, $func, $flag = ($_.func | Select-String -Pattern '^(\w+)([+-.:]?)$').Matches[0].Groups | % { $_.Value }
						if(! $flag) { $flag = '' }
						$twoTabs + $func + (" = {{ {0} }},`n" -f $optionFlags[$flag])
					}
			}
			else {
				$twoTabs + $cls + " = {`n$($threeTabs)fields = {`n"
				$group.Group | Sort-Object -Property func | % { $fourTabs + $_.func + " = { read_only = true },`n" }
				"$($threeTabs)},`n$twoTabs},`n"
			}
		} | Out-File -FilePath $outConfigPath -NoNewline -Append
	$stdEpilogue | Out-File -FilePath $outConfigPath -Append
}

Get-ChildItem -Path (Join-Path $PSScriptRoot $apiListPattern) -File | % { ParseFile $_.FullName } | Out-Null

$outPath = Join-Path $outFolder $outFileExt #-Resolve
Get-Content "$PSScriptRoot\*$outFileExt" | Set-Content $outPath
