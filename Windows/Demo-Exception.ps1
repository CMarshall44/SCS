function Test-Exception{
    Try{
        $path = "C:\ThisDoesn't\Exist.txt"
        Remove-Item -Path $path -ErrorAction Stop
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        Write-Error -Exception ([System.IO.FileNotFoundException]::new("Could not find path: $path", $_.Exception)) -ErrorAction Stop
        #throw [System.IO.FileNotFoundException]::new("Could not find path: $Path", $_.Exception)
    }
    catch{
        #$_.Exception
    }
}

try{
    Test-Exception
}
catch{
    Write-Host $_.Exception
}