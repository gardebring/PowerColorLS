function Splat {
    param(
        [string]
        $FunctionName,

        [hashtable]
        $Params
    )

    & $FunctionName @Params
}