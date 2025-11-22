<#
.SYNOPSIS
    Increments a dot-separated version string with configurable rollover thresholds.

.DESCRIPTION
    The Increment-Version function takes a version string (e.g. "1.9.9" or "0.99") and increments
    the last numeric segment. If the incremented segment reaches or exceeds the threshold, it rolls
    over to zero and increments the previous segment. The major (leftmost) segment never rolls over;
    it simply increments when carry propagates into it. For non-major segments that are already at
    or above the threshold, the effective threshold is promoted to the next power of ten (e.g. 10 → 100,
    473 → 1000). This logic applies recursively across any number of segments (x.y.z.a.b.c).

.PARAMETER Version
    The version string to increment. Must be a dot-separated list of integers (e.g. "0.58", "1.0.3", "2.7.99").

.PARAMETER Threshold
    The base rollover threshold for segments. Defaults to 10.
    - If a segment is below this threshold, rollover occurs when it reaches the threshold.
    - If a segment is already at or above this threshold, its effective threshold is promoted
      to the next power of ten.

.EXAMPLE
    Increment-Version -Version "1.9.9" 
    Returns: "2.0.0"

.EXAMPLE
    Increment-Version -Version "1.9.9" -Threshold 100
    Returns: "1.9.10"

.EXAMPLE
    Increment-Version -Version "0.98" -Threshold 100
    Returns: "0.99"

.EXAMPLE
    Increment-Version -Version "1.92.9" -Threshold 10
    Returns: "1.93.0"

.EXAMPLE
    Increment-Version -Version "2.473.9" -Threshold 10
    Returns: "2.474.0"

.NOTES
    This function generalizes version incrementing to any depth of segments.
#>
function Get-auIncrementedVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Version,
        
        [int]$Threshold = 10
    )

    # Helper: next power of 10 strictly greater than n (for n >= 1)
    function Get-NextPowerOf10([int]$n) {
        if ($n -lt 1) { return 10 }
        [int][math]::Pow(10, [math]::Floor([math]::Log10([double]$n)) + 1)
    }

    $parts = $Version.Split('.') | ForEach-Object { [int]$_ }
    $original = [int[]]$parts.Clone()
    $last = $parts.Length - 1

    # 1) Increment the last segment
    $parts[$last]++

    # 2) Cascade carry from last to the left
    for ($i = $last; $i -ge 1; $i--) {
        # Effective threshold is based on the ORIGINAL value of this segment
        $effective =
            if ($original[$i] -lt $Threshold) { $Threshold }
            else { Get-NextPowerOf10 $original[$i] }

        if ($parts[$i] -ge $effective) {
            $parts[$i] = 0
            $parts[$i - 1]++
        }
    }

    # Major (index 0) never rolls over; it just increments as carry arrives.
    ($parts -join '.')
}