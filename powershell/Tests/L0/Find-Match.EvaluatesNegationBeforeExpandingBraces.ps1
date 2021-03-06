[CmdletBinding()]
param()

# Arrange.
. $PSScriptRoot\..\lib\Initialize-Test.ps1
Invoke-VstsTaskScript -ScriptBlock {
    $tempDirectory = [System.IO.Path]::Combine($env:TMP, [System.IO.Path]::GetRandomFileName())
    New-Item -Path $tempDirectory -ItemType Directory |
        ForEach-Object { $_.FullName }
    try {
        # Create the following layout:
        #   !hello.txt
        #   hello.txt
        #   world.txt
        New-Item -Path "$tempDirectory\!hello.txt" -ItemType File
        New-Item -Path "$tempDirectory\hello.txt" -ItemType File
        New-Item -Path "$tempDirectory\world.txt" -ItemType File
        $patterns = @(
            '*'
            '!{!hello.txt,world.txt}'
        )
        $matchOptions = New-VstsMatchOptions

        # Act.
        $actual = Find-VstsMatch -DefaultRoot $tempDirectory -Pattern $patterns -MatchOptions $matchOptions

        # Assert.
        $expected = "$tempDirectory\hello.txt"
        Assert-AreEqual ($expected | Sort-Object) $actual
    } finally {
        Remove-Item $tempDirectory -Recurse
    }
}