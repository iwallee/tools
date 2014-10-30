


FolderChangesView v1.65
Copyright (c) 2012 - 2014 Nir Sofer
Web site: http://www.nirsoft.net



Description
===========

FolderChangesView is a simple tool that monitors the folder or disk drive
that you choose and lists every filename that is being modified, created,
or deleted while the folder is being monitored.
You can use FolderChangesView with any local disk drive or with a remote
network share, as long as you have read permission to the selected folder.



System Requirements
===================


* This utility works on any version of Windows, starting from Windows
  2000 and up to Windows 8. Both 32-bit and 64-bit systems are supported.



Versions History
================


* Version 1.65:
  o Added "Don't show files that match the following wildcards"
    option.

* Version 1.64:
  o Added 'Always On Top' option.

* Version 1.63:
  o Added 'File Properties' option, which displays the file
    properties window of Windows Explorer.

* Version 1.62:
  o Added 'Explorer Copy' option (Ctrl+E), which allows you to copy
    one or more files and then paste them into opened folder in Windows
    Explorer.
  o Folders are now displayed with a folder icon.

* Version 1.61:
  o Added 'Clear Recent Files List' option to the 'Open Recent
    Configuration' menu.

* Version 1.60:
  o Added 'Keep last size/time information of deleted files' option.
  o Added option to display only files with the specified size range.
  o Added 'Sort On Every Update' option.

* Version 1.55:
  o You can now start monitoring folders with the last 5
    configurations you saved, directly from the tray menu.
  o Added 'Show Choose Folder Window On Start' option. You can turn
    it off if you don't want that the 'Choose Folder' window will appear
    when you start FolderChangesView.

* Version 1.50:
  o Added new columns: 'File Size', 'Modified Time', and 'Created
    Time', which displays the current date/time and size of the specified
    file.
  o Added 'Open Recent Configuration' menu, which allows you to
    easily load the last 10 configurations you previously saved.
  o Added /cfg command-line option, which instructs FolderChangesView
    to use a config file in another location instead if the default
    config file, for example:
    FolderChangesView.exe /cfg "%AppData%\FolderChangesView.cfg"

* Version 1.40:
  o Added option to save and load the entire configuration of
    FolderChangesView ('Save Configuration' and 'Load Configuration'
    under the File menu).

* Version 1.35:
  o Added option to show only files that match to the specified
    wildcards. (For example: *.html, *.xml)

* Version 1.30:
  o You can now specify one or more folders (in comma-delimited list)
    to exclude. Wildcards are also allowed. For example: in order to
    exclude all files under C:\Program Files and its subfolders, you
    should specify: C:\Program Files*

* Version 1.26:
  o You can now specify environment variables (For example:
    %appdata%) in the folder path to monitor.
  o Fixed bug: When specifying wrong folder, FolderChangesView
    entered into monitor mode without allowing you to stop it.

* Version 1.25:
  o Added 'Automatically Scroll Down On New Items' option.

* Version 1.22:
  o Fixed the flickering problem on Windows 7.

* Version 1.21:
  o Added 'Mark Odd/Even Rows' option, under the View menu. When it's
    turned on, the odd and even rows are displayed in different color, to
    make it easier to read a single line.
  o Added 'Auto Size Columns+Headers' option, which allows you to
    automatically resize the columns according to the row values and
    column headers.

* Version 1.20:
  o Added 'File Owner' column, which displays the owner of the
    specified file.

* Version 1.16:
  o Fixed issue: The properties and the 'Choose Folder' windows
    opened in the wrong monitor, on multi-monitors system.

* Version 1.15:
  o Added 'Put Icon On Tray' option.

* Version 1.10:
  o Added new command-line options: /Start , /BaseFolder , and
    /MonitorSubfolders
  o The 'Choose Folder' options are now saved in the .cfg file.

* Version 1.05:
  o Added 'Open Folder In Explorer' option.
  o Added 'Clear All Items' option, to clear all items without
    stopping and then starting again.
  o Fixed bug: The extension column displayed incorrect string for
    files located inside folders with a dot character.

* Version 1.00 - First release.



Start Using FolderChangesView
=============================

FolderChangesView doesn't require any installation process or additional
dll files. In order to start using it, simply run the executable file -
FolderChangesView.exe

After you run FolderChangesView, you have to choose the desired folder
that you want to monitor and then press the 'Ok' button. If you choose a
root folder (For example c:\ ) and the 'Monitor all subfolders under the
specified folder' option is turned on, FolderChangesView will monitor the
changes of the entire drive.

After pressing the 'Ok' button, FolderChangesView starts to monitor the
selected folder and displays all changes detected under this folder. The
counter columns (Modified Count, Created Count, and Deleted Count)
mention the type of change detected for every filename. For example, if a
filename has a value of 10 for both 'Created Count' and 'Deleted Count',
it means that the file has been deleted and created again 10 times.



Command-Line Options
====================



/Start
Start monitoring the folder immediately, without displaying the 'Select
Folder' dialog-box.

/BaseFolder <Folder>
Specifies the folder to monitor.

/MonitorSubfolders <0 | 1>
Specifies whether to monitor all subfolders. 0 = No, 1 = Yes.

/cfg <Filename>
Start FolderChangesView with the specified configuration file. For
example:
FolderChangesView.exe /cfg "c:\config\FolderChangesView.cfg"
FolderChangesView.exe /cfg "%AppData%\FolderChangesView.cfg"

Examples:
FolderChangesView.exe /Start /BaseFolder "C:\" /MonitorSubfolders 1
FolderChangesView.exe /Start /BaseFolder "C:\Program Files"



Translating FolderChangesView to other languages
================================================

In order to translate FolderChangesView to other language, follow the
instructions below:
1. Run FolderChangesView with /savelangfile parameter:
   FolderChangesView.exe /savelangfile
   A file named FolderChangesView_lng.ini will be created in the folder
   of FolderChangesView utility.
2. Open the created language file in Notepad or in any other text
   editor.
3. Translate all string entries to the desired language. Optionally,
   you can also add your name and/or a link to your Web site.
   (TranslatorName and TranslatorURL values) If you add this information,
   it'll be used in the 'About' window.
4. After you finish the translation, Run FolderChangesView, and all
   translated strings will be loaded from the language file.
   If you want to run FolderChangesView without the translation, simply
   rename the language file, or move it to another folder.



License
=======

This utility is released as freeware. You are allowed to freely
distribute this utility via floppy disk, CD-ROM, Internet, or in any
other way, as long as you don't charge anything for this and you don't
sell it or distribute it as a part of commercial product. If you
distribute this utility, you must include all files in the distribution
package, without any modification !



Disclaimer
==========

The software is provided "AS IS" without any warranty, either expressed
or implied, including, but not limited to, the implied warranties of
merchantability and fitness for a particular purpose. The author will not
be liable for any special, incidental, consequential or indirect damages
due to loss of data or any other reason.



Feedback
========

If you have any problem, suggestion, comment, or you found a bug in my
utility, you can send a message to nirsofer@yahoo.com
