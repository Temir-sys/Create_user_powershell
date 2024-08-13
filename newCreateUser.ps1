# Определение данных пользователя
$username = "NewUserName"        # Логин пользователя
$fullname = "New Full Name"      # Полное имя пользователя
$password = "qwerty12345"     # Пароль пользователя

# Преобразование пароля в защищённый формат
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Проверка, существует ли пользователь
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    Write-Host "Пользователь $username уже существует."
} else {
    # Создание нового локального пользователя
    New-LocalUser -Name $username -FullName $fullname -Password $securePassword -PasswordNeverExpires:$true -UserMayNotChangePassword:$false
    Write-Host "Пользователь $username успешно создан."
}

# SID для группы "Users" (S-1-5-32-545)
$usersGroupSid = "S-1-5-32-545"

# Получение всех локальных групп
$localGroups = Get-LocalGroup

# Проверка каждой группы на соответствие SID
foreach ($group in $localGroups) {
    $groupSid = (New-Object System.Security.Principal.NTAccount($group.Name)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    if ($groupSid -eq $usersGroupSid) {
        $groupName = $group.Name
        Write-Host "Найдено соответствие SID: Группа '$groupName'."
        
        # Добавление пользователя в найденную группу
        Add-LocalGroupMember -Group $groupName -Member $username
        Write-Host "Пользователь $username добавлен в группу '$groupName'."
        break
    }
}

if (-not $groupName) {
    Write-Host "Группа с SID '$usersGroupSid' не найдена."
}
