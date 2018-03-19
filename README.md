# No Name Yet
This is a small soundboard program that is designed to be used for things like podcasts and live events. It has been created using
the Love2d games engine (http://www.love2d.org), although this is not it's original purpose it does a good job.

# How to Use It
Upon running the program for the first time the program will create a directory for sound tracks to be placed in
%appdata%\roaming\LOVE\SoundMaster2\music, you can simply copy all the sound files you want to this folder. Next, restart the
program and go to "File" and "Search for Tracks", the program will proceed to look in the above mentioned directory for files.
NOTE: This may take some time if you have many sound files or if there are particularly large files.

After the program has found all the files it will display them as a grid of buttons on in the window with the corresponding titles,
in order to play a sound file press on the button that has the correct title. If you cannot see the sound file it may be due to it
being located on the next page, you can change the page by going to the "Page" menu on the toolbar. When a sound file is playing you
will be able to see a green visualiser on the right side of the button showing the output of that sound file.

## Looping
The program allows you to loop sound files so they play again once finished, this can be done by just pressing the circular arrow
on the corresponding button.

## Bottom "Mixer" Panel

The bottom set of four panels allows you to change the pitch and volume of individual sound cues or all of them at once. The left most
panel labelled "Master" controls the overall volume of all sound cues played. On the right of these are three panels which are used for
individual sound cue manipulation. These can be assigned to any of the sound cues by first right clicking a sound cue and then
left clicking the panel to control it. Upon selecting a panel the label will change to the title of the selected track and the faders
will be set to control the volume and pitch of the track respectively. The "Set Colour" button will allow you to change the colour of
the selected sound cue to one of 8 colours.

# Roadmap

Here is a list of planned features:
- Saving of "sessions"
- Adding the ability to move sound cues around between and within pages

If you have any features you would like to see please feel free to suggest them.
