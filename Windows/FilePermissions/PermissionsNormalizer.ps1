function get-filesandfolders($rootpath) {
  gci $rootpath | % {$_.FullName}
}


  $ErrorActionPreference = 'continue'

  $rootpath = '\\sebnetapp1a\Redirect\karentunison'

  $user = $rootpath.Split('\')[4]

  $script:FilesAndFolders = @()
  $script:FilesAndFolders += @(get-filesandfolders $rootpath)

  $i = 0

  write-host starting now with $FilesAndFolders.length entries

  $ErrorActionPreference = 'stop'


while($i -le ($FilesAndFolders.length -1))
{
    write-host pulling item for path $FilesAndFolders[$i]
    #using get-item instead because some of the folders have '[' or ']' character and Powershell throws exception trying to do a get-acl or set-acl on them.
    $item = gi -literalpath $FilesAndFolders[$i]

    write-host attempting to take ownership of $item `n

    $ErrorActionPreference = 'continue'

    if( $item.GetType().name -like 'directory*') {
    $dirowner = New-Object System.Security.AccessControl.DirectorySecurity
    $dirowner.setowner([System.Security.Principal.NTAccount]'builtin\administrators')
    $item.SetAccessControl($dirowner)

    write-host changing permissions `n

    $acl = $item.GetAccessControl()
    $permission1 = "Administrators","FullControl","Allow"
    $rule1 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission1
    $permission2 = "sebcolaundry\$user","Modify","Allow"
    $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission2
    $acl.addAccessRule($rule1)
    $acl.addAccessRule($rule2)
    $item.SetAccessControl($acl)

    write-host adding subfolders and files from directory `n length before $FilesAndFolders.Length
    $script:FilesAndFolderstemp = @(get-filesandfolders($FilesAndFolders[$i]))
    $script:FilesAndFolders += $script:FilesAndFolderstemp
    write-host new length $FilesAndFolders.Length

    }
    else {
    $fileowner = New-Object System.Security.AccessControl.FileSecurity
    $fileowner.setowner([System.Security.Principal.NTAccount]'builtin\administrators')
    $item.SetAccessControl($fileowner)

    write-host changing permissions `n

    $acl = $item.GetAccessControl()
    $permission1 = "Administrators","FullControl","Allow"
    $rule1 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission1
    $permission2 = "sebcolaundry\$user","Modify","Allow"
    $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission2
    $acl.addAccessRule($rule1)
    $acl.addAccessRule($rule2)
    $item.SetAccessControl($acl)
    }

    $i++
}

write-host finished with $FilesAndFolders.length entries
