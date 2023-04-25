@echo off

SET FLASK_PORT=8001
SET FLASK_HOST=0.0.0.0
SET FLASK_APP=main.py


python -m flask run -p %FLASK_PORT% -h %FLASK_HOST% --debug