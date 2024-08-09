#Определение группы, в которую будут добавлены пользователи
$groupName = "Developers"

# Проверка, Существует ли группа, если нет - создать ее
if (-not (Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue)) {
    New-LocalGroup -Name $groupName -Description "Group for developers"
    Write-Output "Group '$groupName' create." 
} else {
    Write-Output "Group '$groupName' already exists."
}

$username = Read-Host "username"
$fullName = Read-Host "fullname"
$password = Read-Host -AsSecureString "password"


if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
    # Создание нового пользователя
    New-LocalUser -Name $username -Password $password -FullName $fullName -Description "Created by script"
    Write-Output "The user '$username' create."
    
    # Добавление пользователя в группу
    Add-LocalGroupMember -Group $groupName -Member $username
    Write-Output "The user '$username' added to the group '$groupName'."
} else {
    Write-Output "The user '$username' already exists"
}

Write-Output "The process of creating a user and adding it to a group is complete."