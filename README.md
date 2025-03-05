# Project description
![](.\Docs\Images\Example.png)
Have you always wanted to have a customizable Stream Deck like experience and with more flexibility?  

Grab yourself any touch screen [like this one](https://www.amazon.es/dp/B098762GVK?ref=nb_sb_ss_w_as-reorder_k1_1_11&amp=&crid=2DWMQKM8WM8E5&amp=&sprefix=touch+scree) and plug it into your pc and go crazy customizing as many profiles as you want with different icons, texts, colors and more!  

As this project is made with the scripting language AutoHotKey you will need to write your custom functions but you can do anything that you want.

# Table of contents
1. [Requirements](#requirements)
2. [Troubleshoot touch input](#troubleshoot-touch-input)
3. [How to use](#how-to-use)
    1. [Configure GuiConfig](#configure-guiconfig)
    2. [Configure Profiles](#configure-profiles)
    3. [Configure Profile Actions](#configure-profile-actions)
4. [Develop locally](#idleon-tools-develop)
<!-- 2. [Compile](#compile) -->

# Requirements  <a name="requirements"></a>  
<!-- You can run this tool as is by running the **ScreenDeck.exe** file if you are using the executable from any of the releases.   -->

<!-- If on the other hand you want to modify and run the source AHK files, you will need to have AutoHotKey v2.0 installed on your computer. More info in the [Compile](#compile) section.   -->
You can download the scripting language from here [AutoHotKey](https://www.autohotkey.com/download/ahk-v2.exe).  

To run the tool with AHK you will need to execute the **ScreenDeck.ahk** file.

# Troubleshoot touch input  <a name="troubleshoot-touch-input"></a>  
Windows sometimes will need to be calibrated when using multiple monitors and at least one of them has touch enabled.  

The problem is that when touching the screen your cursor will be moved and click in another position.  

The solution is the following:  

Go to the control panel by searching it in the windows start menu.
![control panel](.\Docs\Images\ControlPanel.png)

Search and enter the Tablet Pc Settings.
![control panel](.\Docs\Images\ControlPanelTabletPcSettings.png)

Start the setup and follow the screen instructions. Usually you press Enter to skip a non-touch screen or touch anywhere in the screen if needed.
![control panel](.\Docs\Images\TabletPcSettings.png)

# How to use  <a name="how-to-use"></a>  
When you first run the script a ScreenDeck.json file will be generated and the UI will be shown.  

If you move and resize the UI it will dynamically fill its contents.  

Also it saves its last location and size from the previous execution so it will always be loaded where you left it.  

If this feature is giving you errors because you changed your monitor settings you can always reset its position by right clicking the ScreenDeck tray icon and selecting `Reset Window size and cords`

![tray icon](.\Docs\Images\TrayIconContextMenu.png)

## Configure GuiConfig  <a name="configure-guiconfig"></a>  
You can add a top level object field named `GuiConfig` with any of the following examples:
```
"GuiConfig": {
    "DeckBackgroundColor": "1e7e1b",
    "DeckButtonMargin": 6,
    "DeckButtonSize": 95,
    "ShowTopBar": 0,
    "TopBackgroundColor": "657287"
},
```
You can set any of these to override the program defaults.  
- DeckBackgroundColor: Hex color code.
- DeckButtonMargin: Margin between buttons.
- DeckButtonSize: Button size in pixels (both width and height).
- ShowTopBar: 0 or 1 to hide or show the top bar.
- TopBackgroundColor: Hex color code.

## Configure Profiles  <a name="configure-profiles"></a>  
You can add a top level object field named `Profiles` like so:
```
"Profiles": {
    "_Default": {
        "Actions": {...}
        "DeckBackgroundColor": "1b7e67",
        "DeckButtonMargin": 6,
        "DeckButtonSize": 95
    },
    "Secondary": {
        "Actions": {...}
    },
},
```  
By default it will load the first alphabetically sorted profile by name each time the script runs.  
You can have as many profiles as needed.  

Currently you can override the following `GuiConfig` settings:
- DeckBackgroundColor
- DeckButtonMargin
- DeckButtonSize

## Configure Profile Actions  <a name="configure-profiles-actions"></a>  
Inside the profile `Actions` object you can add actions like so:

```
"Profiles": {
    "_Default": {
        "Actions": {
            "0": {
                "Profile": "Secondary",
                "Text": "Profile\nWork\nSecondary"
            },
            "1": {
                "Action": "OpenPersonalFolder",
                "Icon": "Folders/W11_yellow.png",
                "IconVerticalAlignment": 0.45000000000000001,
                "Profile": "Secondary",
                "Text": "PersonalFolder",
                "TextSize": 10,
                "TextVerticalAlignment": "0.85",
                "TextWeight": 700
            },
            "2": {
                "Action": "StartProgram",
                "Icon": "Programs/Program.ico"
            },
            "3": {
                "Action": "StartAnotherProgram",
                "DoubleClickAction": "StartAnotherProgramNewInstance",
                "Icon": "Programs/AnotherProgram.ico"
            },
            "4": {
                "Action": "StartVSWorkSpaceScreenDeck",
                "Icon": "Programs/VisualStudioCode.ico",
                "IconVerticalAlignment": 0.45000000000000001,
                "Text": "ScreenDeck",
                "TextSize": 10,
                "TextVerticalAlignment": "0.85",
                "TextWeight": 700
            },
        }
    },
    "Secondary": {...}
},
```  

All of the entries inside the `Actions` object have to be a unique number. This number is the index that will be used to show this action inside the ScreenDeck starting to count from the top left.  

Inside an action you can set the following fields:
- Action: Execute a function. You can create your custom functions inside the **CustomFunctions.ahk** file.  
- DoubleClickAction: Executes another function. The same as `Action`. This is to support multiple functions from the same deck button. In the example provided you can start or activate a program if already running but if you double click the button, it will always start a new instance of the program for example.  
- Icon: To set an icon to the ScreenDeck button.  
- IconVerticalAlignment: Specify the center of the icon vertically.  
- Text: Text to show. To include multiple lines use the `\n` characters.  
- TextSize: Text size.  
- TextVerticalAlignment: Specify the center of the text vertically.  
- TextWeight: Text weight.

# Develop locally  <a name="develop"></a>  
Clone this repository and you can start working on it directly.

The project is structured in the following files and folders:  
1. **Folders**:
    1. **Images**: Folder that contains the default project graphic files.  
    2. **lib**: Folder that contains the ahk json dll libraries.  
2. **Files**:
    1. **Classes.ahk**: Collection of classes that are being used by the script. Currently only holds the LoggerObject class.  
    2. **CommonFunctions.ahk**: Functions that are intended to be used inside the script core and outside if the user wants to use these helpers.  
    3. **CoreFunctions.ahk**: Functions that are meant to be used only by the script itself.
    4. **CustomFunctions.ahk**: Here the user will add custom functions that will be called from the ScreenDeck buttons.
    5. **Globals.ahk**: Global variables declaration. Intended to only be used by the script itself.
    6. **GUI.ahk**: All UI related script related functions.
    7. **ImagePut.ahk**: Library to be able to use gifs.
    8. **JSON.ahk**: Loads the native json dll to be able to read and write json files.
    9. **Macros-utf8.ahk**: Where the user can put macros/hotkeys/hotstrings.
    10. **ScreenDeck.ahk**: Main ahk file that includes all other files and the entry point when executed.

<!-- # Compile  <a name="compile"></a> 
To compile this script locate your AHK installation directory and run the Ahk2Exe with the following command:

```"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "PATH_TO_ScreenDeck.ahk" /icon "PATH_TO_\Images\ScreenDeck.ico" /out "PATH_TO_ScreenDeck.exe" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"```

Remember to change the paths to the ones from your computer and working directory. -->