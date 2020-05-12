
function Get-LongestItem{
    param(
        [Parameter(Mandatory = $true)]
        [array]$items,

        [Parameter(Mandatory = $true)]
        [scriptblock]$scriptBlock
    )

    $longestItem = ""
    foreach($item in $items){
        $itemValue = Invoke-Command -ScriptBlock $scriptBlock
        if($itemValue.Length -gt $longestItem.Length){
            $longestItem = $itemValue
        }
    }
    return $longestItem
}