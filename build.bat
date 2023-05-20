pyinstaller -F --add-data "lib;lib" --add-data "render;render" --add-data "blueprints;blueprints" --paths "pyenv\scripts;lib;blueprints" main.py 
