<#
.SYNOPSIS
    Generates one or more incremented version strings with configurable rollover thresholds.

.DESCRIPTION
    Get-auIncrementedVersion takes a version string and increments the last numeric segment.
    Threshold rollover rules apply: if a segment reaches or exceeds its effective threshold,
    it rolls over to zero and increments the previous segment. The major (leftmost) segment
    never rolls over; it simply increments when carry propagates into it. For non-major
    segments that are already at or above the threshold, the effective threshold is promoted
    to the next power of ten (e.g. 10 → 100, 473 → 1000). This logic applies recursively
    across any number of segments (x.y.z.a.b.c).

    If -Range is specified, the function produces an array of successive version numbers.
    If -MajorThreshold is specified, then at that iteration the function forces a rollover
    by setting the last segment to its maximum (Threshold-1, or next power-of-ten minus 1
    if already above Threshold). This simulates an author deciding to jump to the next
    major version.

.PARAMETER Version
    The version string to increment. Must be a dot-separated list of integers.

.PARAMETER Threshold
    Base rollover threshold for segments. Defaults to 10.

.PARAMETER Range
    Optional. If specified, the function will return an array of the next N version numbers.

.PARAMETER MajorThreshold
    Optional. Iteration index at which to force rollover to the next major version.

.EXAMPLE
    Get-auIncrementedVersion -Version "1.9.9" -Threshold 10
    Returns: "2.0.0"

.EXAMPLE
    Get-auIncrementedVersion -Version "0.99" -Threshold 10
    Returns: "1.0"

.EXAMPLE
    Get-auIncrementedVersion -Version "1.92.9" -Threshold 10
    Returns: "1.93.0"

.EXAMPLE
    Get-auIncrementedVersion -Version "0.58" -Threshold 100 -Range 15 -MajorThreshold 13
    Returns: "0.59","0.60",...,"0.69","1.0","1.1","1.2"

.OUTPUTS
    System.String or System.String[]
#>
function Get-auIncrementedVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Version,
        [int]$Threshold = 10,
        [int]$Range,
        [int]$MajorThreshold
    )

    function Get-NextPowerOf10([int]$n) {
        if ($n -lt 1) { return 10 }
        [int][math]::Pow(10, [math]::Floor([math]::Log10([double]$n)) + 1)
    }

    function Increment-One([string]$Ver, [int]$Thr) {
        $parts = $Ver.Split('.') | ForEach-Object { [int]$_ }
        $original = [int[]]$parts.Clone()
        $last = $parts.Length - 1

        $parts[$last]++

        for ($i = $last; $i -ge 1; $i--) {
            $effective =
                if ($original[$i] -lt $Thr) { $Thr }
                else { Get-NextPowerOf10 $original[$i] }

            if ($parts[$i] -ge $effective) {
                $parts[$i] = 0
                $parts[$i - 1]++
            }
        }

        ($parts -join '.')
    }

    if ($PSBoundParameters.ContainsKey('Range')) {
        $results = @()
        $current = $Version
        for ($i = 1; $i -le $Range; $i++) {
            if ($PSBoundParameters.ContainsKey('MajorThreshold') -and $i -eq $MajorThreshold) {
                $parts = $current.Split('.') | ForEach-Object { [int]$_ }
                $last = $parts.Length - 1
                $effective = if ($parts[$last] -lt $Threshold) { $Threshold }
                             else { Get-NextPowerOf10 $parts[$last] }
                $parts[$last] = $effective - 1
                $current = ($parts -join '.')
            }
            $current = Increment-One $current $Threshold
            $results += $current
        }
        return $results
    }
    else {
        return (Increment-One $Version $Threshold)
    }
}