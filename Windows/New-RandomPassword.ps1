function New-RandomPassword{
    param(
        [Parameter()]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 12,
        [Parameter()]
        [ValidateScript({$_ -ge $MinPasswordLength})]
        [Alias('Max')] 
        [int]$MaxPasswordLength = 18,
        [Parameter()]
        [ValidateScript({
        $CharTypeCount =4         
        ($_ * $CharTypeCount) -le $MinPasswordLength})] # 4 Distinct char types (UCase,LCase,Number and Special)
        [int]$MinCharofEachType = 2        
    )
    [Char[]]$LCChars = @()
    [Char[]]$UCChars = @()
    [Char[]]$NumChars = @()
    [Char[]]$SpecialChars = @()
    [Char[]]$allChars = @()
    for ([byte]$c = [char]'a'; $c -le [char]'z'; $c++){  
        $LCChars += [char]$c  
    }
    for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++){  
        $UCChars += [char]$c  
    }
    for ([byte]$c = [char]'0'; $c -le [char]'9'; $c++){  
        $NumChars += [char]$c  
    }
    for ([byte]$c = [char]33; $c -le [char]47; $c++){  
        $SpecialChars += [char]$c  
    }
    for ([byte]$c = [char]58; $c -le [char]64; $c++){  
        $SpecialChars += [char]$c  
    }
    for ([byte]$c = [char]91; $c -le [char]96; $c++){  
        $SpecialChars += [char]$c  
    }
    $allChars = $LCChars + $UCChars + $NumChars + $SpecialChars
    $PasswordLength = Get-Random -Minimum $MinPasswordLength -Maximum $MaxPasswordLength
    $pwd = @() 
    $count = 0;
    do{
        $pwd += Get-Random -InputObject $UCChars
        $count++
    } while ($count -lt $MinCharofEachType)
    $count = 0;
    do{
        $pwd += Get-Random -InputObject $LCChars
        $count++
    } while ($count -lt $MinCharofEachType)
    $count = 0;
    do{
        $pwd += Get-Random -InputObject $NumChars
        $count++
    } while ($count -lt $MinCharofEachType)
    $count = 0;
    do{
        $pwd += Get-Random -InputObject $SpecialChars
        $count++
    } while ($count -lt $MinCharofEachType)
    do {
        $pwd += Get-Random -InputObject $allChars
    
    } while ($pwd.Count -lt $PasswordLength)
    $shuffled = $pwd | Sort-Object{Get-Random}
    [string]$stringPwd = $null
    ForEach ($a in $shuffled){
        $stringPwd += $a.ToString()
    }
    return $stringPwd
}