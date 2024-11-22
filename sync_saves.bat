@echo off
::setlocal EnableExtensions EnableDelayedExpansion
setlocal EnableDelayedExpansion

set op=%1%
if "%op%" == "" (set op=-backup)


echo "################################################################"
echo Syncing Saves
echo Operation is: %op%
::echo %USERNAME%
::set %FileFullPath% = "C:\Users\%USERNAME%\Documents\TestScripts\save_backup\test_db.csv"
set win_user=%USERNAME%
::set lin_user=deck
::set win_cloud_drive=X:
::set lin_cloud_drive=smb:\\193.186.50.50\xtra
::set cloud_path=\temp\test\

for /f "eol=- delims=" %%a in (common.cfg) do set "%%a"

::echo %win_user%
::echo %lin_user%
::echo %win_cloud_drive%
::echo %cloud_path%

for /f "skip=1 tokens=1-12,* delims=," %%a in (sync_saves.csv) do (
	echo ...
	set game_name=%%a
	echo game_name: !game_name!

	set win_path=%%e
	set win_path=!win_path:{win_user}=%win_user%!
	set full_path=%%c!win_path!%%h%%i
	set full_path=!full_path:{game_user}=%%j!
	set full_path=!full_path:{NA}=!
	set full_cloud_path=!win_cloud_drive!!cloud_path!\%%a
	set backup_path1=!win_cloud_drive!!cloud_path!\backup1\%%a
	set backup_path2=!win_cloud_drive!!cloud_path!\backup2\%%a
	
	set skip_game=%%k
	set exclude_files=%%l
	set backup_only=0
	
	IF !full_path:~-1!==\ (SET full_path=!full_path:~0,-1!)
	
	if !skip_game! == 1 (
		echo SKIPPING: %%a - !full_path!
	) else (
		::echo Syncing with operation: !op!
		if exist !full_path! (
			if !op! == -backup (
				set var=""
				::FOR /F "tokens=* USEBACKQ" %%Z IN (`robocopy !full_path! !full_cloud_path! /e /l /ns /njs /njh /ndl /fp`) DO (
				FOR /F "tokens=* USEBACKQ" %%Z IN (`robocopy !full_path! !full_cloud_path! /e /l /ns /njs /njh /fp /FFT`) DO (
					::echo %%Z
					set var=var%%Z
				)
				::echo var is !var!
				if !var! == "" (
					echo %%a No Backups Needed
				) else (
					echo "backing up previous backups..."
					echo robocopy "!backup_path1!" "!backup_path2!" %%b /s /xo /fft /xf !exclude_files!
					robocopy "!backup_path1!" "!backup_path2!" %%b /s /xo /fft /xf !exclude_files!
					echo "backing up previous saves..."
					echo robocopy "!full_cloud_path!" "!backup_path1!" %%b /s /xo /fft /xf !exclude_files!
					robocopy "!full_cloud_path!" "!backup_path1!" %%b /s /xo /fft /xf !exclude_files!
					echo "backing up current saves..."
					echo robocopy "!full_path!" "!full_cloud_path!" %%b /s /xo /fft /xf !exclude_files!
					robocopy "!full_path!" "!full_cloud_path!" %%b /s /xo /fft /xf !exclude_files!
				)
			)
			if !op! == -update (
				if !backup_only! == 1 (
					echo "..."
					echo !game_name! is set to backup ONLY
					echo "..."
				) else (
					echo "updating current saves..."
					echo robocopy "!full_cloud_path!" "!full_path!" %%b /s /xo /fft /xf !exclude_files!
					robocopy "!full_cloud_path!" "!full_path!" %%b /s /xo /fft /xf !exclude_files!
				)
			)
		) else (
			echo %%a not found, skipping: !full_path!
		)
	)
	echo ...

)

echo "################################################################"

echo Saving log to: %win_cloud_drive%%cloud_path%\sync_saves.log
::echo Last sync - %op% - by %USERNAME% on %date% >> sync_saves.log
echo Last sync - %op% - by %USERNAME% on %date% >> %win_cloud_drive%%cloud_path%\sync_saves.log

echo SAVES SYNCHRONIZED

TIMEOUT 5
::PAUSE
