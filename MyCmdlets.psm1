# Function to test network connectivity by pinging a specified site
function Test-Ping {
    param (
        [string]$site = "www.google.com"  # Default site to ping
    )

    Write-Output "Testing network connectivity to $site..."

    # Use Test-Connection to check network connectivity
    $pingResult = Test-Connection -ComputerName $site -Count 4 -ErrorAction SilentlyContinue

    if ($pingResult) {
        Write-Output "Network connection to $site is successful!"
        # Select and display the relevant details of the ping result
        $pingResult | Select-Object Address, ResponseTime, StatusCode
    }
    else {
        Write-Output "Failed to connect to $site. Please check your network settings."
    }
}

# Function to generate a secure password and copy it to the clipboard
function New-Password {
    param(
        [bool]$specialChars = $true,  # Flag to include special characters in the password
        [string]$invalid = ""  # String of invalid characters to exclude from the password
    )

    # Define character sets for password generation
    $upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
    $lower = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
    $number = "0123456789".ToCharArray()
    $special = "!@#$%&=+?/".ToCharArray()
    $password = @()

    # Remove invalid special characters if specified
    if ($invalid.Length -gt 0) {
        Write-Output "Removing Invalid special characters..."
        $invalidSpecialChars = $invalid.ToCharArray()
        $special = $special | Where-Object { $invalidSpecialChars -notcontains $_ }
    }

    Write-Output "Building password..."
    # Generate password with specified character sets
    if ($specialChars) {
        $password += $special | Get-Random -Count 4
        $password += $upper | Get-Random -Count 5
        $password += $lower | Get-Random -Count 5
        $password += $number | Get-Random -Count 4
    }
    else {
        $password += $upper | Get-Random -Count 7
        $password += $lower | Get-Random -Count 7
        $password += $number | Get-Random -Count 5
    }

    # Shuffle the password array and convert it to a string
    $shuffled = $password | Get-Random -Count $password.Length
    $shuffled = -join $shuffled

    # Copy the generated password to the clipboard
    $shuffled | Set-Clipboard
    Write-Host "The password has been copied to your clipboard" -ForegroundColor Green
}

# Function to retrieve and display the definition of a word
function Get-Definition {
    param (
        [string]$word = "define"  # Default word to define
    )

    Write-Host "Defining the word $word..." -ForegroundColor Blue
    
    try {
        # Construct the API URL with the specified word
        $apiUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/$word"
        # Make the API request and get the response
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get

        if ($response -and $response[0]) {
            $meaning = $response[0].meanings
            Write-Host "Meanings:"
            
            foreach ($m in $meaning) {
                $partOfSpeech = $m.partOfSpeech
                $definitions = $m.definitions
                Write-Host "`nPart of Speech: $partOfSpeech" -ForegroundColor Yellow
                
                foreach ($definition in $definitions) {
                    Write-Output "- $($definition.definition)"
                }
            }
        }
    }
    catch [System.Net.WebException] {
        $errorResponse = $_.Exception.Response
        if ($errorResponse -and $errorResponse.Content) {
            # Handle and display API error response
            $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
            $errorContent = $reader.ReadToEnd()
            $errorData = ConvertFrom-Json $errorContent

            Write-Output "Error: $($errorData.title)"
            Write-Output "Message: $($errorData.message)"
            Write-Output "Resolution: $($errorData.resolution)"
        }
        else {
            Write-Host "We couldn't find definitions for the word you were looking for." -ForegroundColor Red
        }
    }
}

# Export the functions to make them available as cmdlets
Export-ModuleMember -Function Test-Ping
Export-ModuleMember -Function New-Password
Export-ModuleMember -Function Get-Definition
