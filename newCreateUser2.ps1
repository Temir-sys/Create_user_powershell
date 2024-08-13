# Определение данных пользователя
$username = Read-Host "Введите имя пользователя (логин)"
$fullname = Read-Host "Введите полное имя пользователя"
$password = Read-Host "Введите пароль пользователя" -AsSecureString

# Преобразование пароля в защищённый формат
$securePassword = $password

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

# Функция для получения имени группы по SID
function Get-GroupNameBySid {
    param (
        [string]$sid
    )
    
    foreach ($group in $localGroups) {
        try {
            $groupSid = (New-Object System.Security.Principal.NTAccount($group.Name)).Translate([System.Security.Principal.SecurityIdentifier]).Value
            if ($groupSid -eq $sid) {
                return $group.Name
            }
        } catch {
            Write-Warning "Ошибка при проверке группы $($group.Name): $_"
        }
    }
    return $null
}

# Получение имени группы "Users"
$groupName = Get-GroupNameBySid -sid $usersGroupSid

if ($groupName) {
    # Добавление пользователя в найденную группу
    Add-LocalGroupMember -Group $groupName -Member $username
    Write-Host "Пользователь $username добавлен в группу '$groupName'."
} else {
    Write-Host "Группа с SID '$usersGroupSid' не найдена. Проверьте наличие группы, разрешающей интерактивный вход."
}
