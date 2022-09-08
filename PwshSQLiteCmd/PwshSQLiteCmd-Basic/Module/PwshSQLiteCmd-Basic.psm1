$Script:SQLiteConnectionStack=[System.Collections.ArrayList]@()
function Get-CurrentSQLiteConnection{
    process{
        if( $Script:SQLiteConnectionStack.Length -gt 0){
            return $Script:SQLiteConnectionStack[-1]
        }
        
    }
}
function Resolve-SQLiteDataBase{
    param(
        [Parameter(ValueFromPipeline)]
        [string]
        $DataBaseLocation
    )
    process{
        if( -not($DataBaseLocation|Test-RelativePath)){            
            [System.Data.SQLite.SQLiteConnection]::CreateFile(($DataBaseLocation|Get-FullPathFromRelativePathToWorkspace))                   
        }
    }
}
function Connect-ToSQLiteDataBase{
    param(
        [Parameter(ValueFromPipeline)]
        [string]
        $DataBaseLocation
    )
    process{
        $DataBaseLocation|Resolve-SQLiteDataBase        
        [System.Data.SQLite.SQLiteConnection]$Connection=[System.Data.SQLite.SQLiteConnection]::new("data source="+($DataBaseLocation|Get-FullPathFromRelativePathToWorkspace))
        $Script:SQLiteConnectionStack.Add(($Connection))|Out-Null        
        $Connection.Open()       
    }
}
function Disconnect-SQLiteDataBase{
    process{
        (Get-CurrentSQLiteConnection).Close()
        $Script:SQLiteConnectionStack.Remove((Get-CurrentSQLiteConnection))
        
    }
}
function Invoke-QueueCommand{
    param(
        [string]
        $CommandText
    )
    process{
        $command=[System.Data.SQLite.SQLiteCommand]::new((Get-CurrentSQLiteConnection))
        $command.CommandText=$CommandText
        $command.ExecuteNonQuery()
        $reader=$command.ExecuteReader()
        while($reader.Read()){
            $reader
        }
    }
}