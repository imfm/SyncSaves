# SyncSaves

*USE AT YOUR OWN RISK. I TAKE NO RESPONSIBILITY FOR ANY DAMAGE CAUSED TO YOUR SYSTEMS OR YOUR SAVE FILES. MAKE MANUAL BACKUPS BEFORE YOU RUN ANY SCRIPTS ON ANYTHING.*

These are scripts to synchronize games saves between multiple operating systems using Network Attached Storage or NAS. Designed to synchronize saves between a Windows PC and a Steam Deck, but should work with any Linux system. It will create a backup of your saves, a backup of the backup, and a backup of the backup's backup. I created this to synchronize save for games that don't support cloud saves (or don't support them properly) and non-steam games. Please be aware that some games saves can have ridiculous file sizes (i.e. Fallout 4).

This is currently kind of just a proof of concept. It works on my systems, but I really wouldn't recommend trying to use this on your system if you don't know what you're doing. I would love to create a nice clean installer, but that is not in the cards at the moment. 

These are just shell scripts, not new software. These are running built in applications in Linux and Windows for making efficient backups of files. The Windows scripts use Robocopy and the Linux scripts use Rsync which attempt to copy files from one directory to another, skipping any old or unchanged files. This script just helps to organize the paths to all the files and run backups on those. 

The first step is to setup the paths in the file "sync_saves.csv". In most cases you can use a single line for each game. In some cases like Shadow of the Tomb Raider, the file structure is so different between Windows and Linux that you will need to create a seperate line for each version. Each field is defined as:

game_name: Just an alias for the game, can be anything.
	Ex: MyGame
 
file_names: If you need to specify a specific file, put it here. Otherwise use *.* to copy everything.
	Ex: MyGame.sav
 
win_drive: The drive letter on the Windows machine where the save files are stored. Use NA is there is no Windows machine.
	Ex: C:
lin_drive: The mount point where the saves are stored on Linux specific to the user. The script will pull {lin_user} from the OS.
	Ex: \home\{lin_user}\SDCARD
 
win_path: The path to your save games on Windows specific to the user.  The script will pull {win_user} from the OS.
	Ex: \Users\{win_user}\AppData\Local
 
lin_path: The path to your save games, excluding the specific folder on Linux. For steam, this will often be a long, convoluted path to the WINE prefix folder. It is usually hidden under a folder called .local and uses a game ID which you will need to find (more on this later). In this instance, 1577120 is the Steam game ID for The Quarry. In these instances, after you find the prefix, the rest of the path will be identical to Windows which will be copied over under {win_path}.
	Ex: \.local\share\Steam\steamapps\compatdata\1577120\pfx\drive_c\{win_path}
 
lin_pfx_user: If the games are stored in a WINE prefix folder under a specific user put the username here.
	Ex: SteamUser123
 
all_path: The universal path to the game data.
	Ex: \MyGame\SavedData
 
save_folder: The actual game saves folder. Often preferences are saved next to the save games and you probably don’t want to share resolution and detail settings between your desktop PC and Steam Deck.
	Ex: \GameStudioInteractive\Saves
 
game_user: Some games generate a horrible random code for each user based on something like your steam user name. If that’s the case, put here. Otherwise use {NA}
	Ex: 0A12354AFFSA
 
skip_game: 1 if you don’t want to sync these files, but don’t want to delete the data for that game. 0 to process this line.
	Ex: 0
 
exclude_files: If the game stores unwanted data in the same folder as the saves (i.e. video settings), put it here to exclude it.
	Ex: video_settings.conf
 

Next setup the common configuration in "common.cfg":

win_cloud_drive: The windows network drive 
	Ex: win_cloud_drive=Y:
 
lin_cloud_drive: The mount point of the network drive on Linux
	Ex: lin_cloud_drive=/home/deck/mnt/y
 
alt_lin_cloud_drive: Alternate mount point for the network drive on Linux
	Ex: alt_lin_cloud_drive=/media/y
 
cloud_path: The folder on the network drive where all the saves will be stored
	Ex: cloud_path=\backups\saves\syncsave

In the end, you files will be copied from

Windows: \Users\{win_user}\AppData\Local\MyGame\SavedData\GameStudioInteractive\Saves\0A12354AFFSA\
Linux: \home\{lin_user}\SDCARD\.local\share\Steam\steamapps\compatdata\1577120\pfx\drive_c\{win_path}

To

NAS: Y:\backups\saves\syncsave\MyGame

How to run it?

On Windows, run "sync_saves.bat" to backup your files to the NAS, and run "sync_saves_update.bat" to pull down any new data. It SHOULD verify that it is copying the newest file before copying anything, but I can't make any guarantees. Also keep in mind that different file systems and NAS protocols handle timestamps differently and sometimes don't play nice with each other, so do lots of testing before using real files. There are number of ways to get this running automatically at startup on Windows. Here is one way:

1) Select the Start button and scroll to find the app you want to run at startup.
2) Right-click the app, select More, and then select Open file location. This opens the location where the shortcut to the app is saved. If there isn't an option for Open file location, it means the app can't run at startup.
3) With the file location open, press the Windows logo key + R, type shell:startup, then select OK. This opens the Startup folder.

This may not work on all systems. Getting it to run on shutdown is a bit more of a hassle. You will need Windows professional to do this. The easiest way to do this is with a local group policy:

1) go to your local group policy editor (Click Start, type gpedit.msc in the Start Search box, and then press ENTER.)
2) Once this is loaded, go to the following path: Computer Configuration > Windows Settings > Scripts (Startup/Shutdown) > Shutdown and add the script.

On Linux, run "sync_saves.sh" to backup your files to the NAS, and run "sync_saves_update.sh" to pull down any new data. Same caveats as above, don't just assume your file systems and file sharing protocols will play nice with file modification timestamps. Getting it to run automatically is incredibly complicated. I've included some services for systemd and some notes on how to set it up under the services folder, but I would not recommend you do it unless you are very comfortable with Linux. Also, most of the time the Steam Deck refuses to mount the network drive before running the script which prevents it from working properly.

The recommended method is to go to desktop mode, find the script, right click it and mark it as executable. Then add the script to you non-steam games and you can run it directly in gaming mode.

