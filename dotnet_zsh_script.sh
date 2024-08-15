#dotnet script
function check_cd_command() {
  # Obtener el último comando del historial
  local last_command=$(fc -ln -2 | head -n 1)

  # Verificar si el último comando fue 'cd'
  if [[ $last_command == cd* ]]; then
    return 1 # Retornar 1 si fue 'cd'
  else
    return 0 # Retornar 0 si no fue 'cd'
  fi
}

function enter_dotnet_dir() {
  # No continuar si el último comando fue 'cd'
  check_cd_command
  if [ $? -eq 1 ]; then
    return
  fi

  # Verificar si el directorio tiene un repositorio Git
  if [ -d ".git" ]; then
    # Ejecuta `ls` al entrar en el directorio
    ls

    # Busca el archivo .sln con una profundidad máxima de 5
    local sln_file=$(find . -maxdepth 5 -name "*.sln" -print -quit)

    if [ -n "$sln_file" ]; then
      echo "You are in a .NET solution directory with Git." | lolcat
      echo "Select a project to navigate to:" | lolcat

      # Busca todas las carpetas que contienen archivos .csproj con una profundidad máxima de 5
      local csproj_dirs=($(find . -maxdepth 5 -name '*.csproj' -exec dirname {} \; | sort | uniq))

      if [ ${#csproj_dirs[@]} -eq 0 ]; then
        echo "No .csproj files found." | lolcat
        return
      fi

      # Usa fzf para seleccionar una carpeta
      local selected_dir=$(printf "%s\n" "${csproj_dirs[@]}" | fzf --prompt="Select a project: " --height=40% --border)

      # Si no se hace ninguna selección, salir del script
      if [ -z "$selected_dir" ]; then
        return
      fi

      # Verifica si tienes permiso para leer y ejecutar el directorio
      if [ -r "$selected_dir" ] && [ -x "$selected_dir" ]; then
        cd "$selected_dir"
        echo "You are now in $(pwd)" | lolcat
      else
        echo "No permission to enter the selected directory." | lolcat
      fi
    else
      echo "No .sln file found within 5 levels of depth." | lolcat
    fi
  fi
}

# Agrega la función para que se ejecute al cambiar de directorio
chpwd_functions+=(enter_dotnet_dir)
