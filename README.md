# hyprflow

The ultimate way to get rid of distractions and finally be productive in Hyprland

<details>
<summary>

### Backstory
</summary>

I used to have a major procrastination issue where I would struggle greatly to get work done at the computer. And it's especially difficult when you're in a system where your distractions could be a simple keybinding away. So I started looking into productivity/focus apps on linux. And....was utterly disappointed. 

#### Issue #1

Now a painful lack of variety of these apps on Linux aside, even the non-Linux ones aren't great. A lot of these apps only do one thing, which is they either kill stuff on the system, or it's a browser extension that blocks websites. Which means, you would need to take at least a couple of them and assemble into a system, which may or may not be janky and obnoxious to manage. The app killing ones didn't want to play ball consistenly on my system and the extensions were way too...theatrical for the lack of a better word, bombarding me with unnecessary functions and elaborate placeholder screens when you enter a blacklisted website, even though I simply need it to not let me enter, and that's it. Too...much for a very simple purpose it needs to serve

#### Issue #2

Some focus apps, which actually go beyond your simple Pomodoro technique for time management and try to forcefully cut you off from your distractions, offer to send you into a dark isolated void of a workspace with a selected handful of apps, where you simply don't want to be and want to leave as soon as you're done. I don't want that. I want to be in my usual environment, but with some very adaptive restrictions.

So, with that in mind, my ideal app would need to 1) simply not allow me to either open an app or visit a specific website in a browser. Just do that, and nothing else and 2) silently work in the background, selectively removing the distractions, while I'm still in my usual comfy and cozy environment

And that's why and how Hyprflow came to be. Well that, and needing some more things to test for my QA portfolio....
Anyways, how does it work?
</details>

It is a small and simple script that kills specific distractions

#### How specific?

It uses a combination of window class + keywords to block everything from an app, killing it completely, all the way to blocking a specific page on a specific website, while leaving everything else intact. Assuming you choose your keywords wisely, you can remove things that keep you from being productive with near "surgical" precision. Your favourite scrolling addiction pages? All of Steam or a specific game? A specific video on youtube or in your local player? You can be as vague or as tedious as you want.

For example, you could block YouTube in your personal browser, which is where your distractions live, but keep it available in your work browser, on your work account, in case you need youtube for work too. 

It has 3 levels of blocking:

1. Browser control: keeps you from accessing specific pages or entire websites

2. Window control: kills specific windows as soon as it detects you opening them or ones that had already been opened before you launched the script

3. App control: kills apps completely, in case window killing isn't enough since the app will re-spawn forcefully-closed windows automatically and annoy you. Steam likes to do that, for example. Also some other apps that minimize to the system tray after you close the window.


### How to get started

Clone the repository. Most of the setup is automated

#### Step 1. Installation

Launch ```setup.sh``` and it'll install everything you need. 

In case it doesn't work for you or you just want to do everything manually:

Install the packages: ```sudo pacman -S jq libnotify nodejs npm``` (if not using Arch Linux, use the appropriate command and package names for your system)

Install Playwright for browser control in the same directory you cloned ```npm install playwright```

Also, for browser control, you will need to make sure your browser launches in debug mode and is listening on a specific port(port numbers need to match in the launch command and inside the playwright script, use the default 9222 in most cases)

Example:

Instead of ```chromium``` it needs to be ```chromium --remote-debugging-port=9222```

Change that in your ```hyprland.conf``` (optionally anywhere else that has to do with launching a browser instance, such as the ```.desktop``` file for your browser in ```~/.local/share/share/applications``` for your xdg-open stuff)

❗IMPORTANT NOTE: 
As of right now, only Chromium-based browsers(Chrome, Brave, Edge etc.) are supported for playwright control. I hope to get Firefox protocols working at some point.

#### Step 2. Configuration and Usage

Once you're done with the installation, it's time to start setting it all up.
Inside ```hyprflow.sh```, you can specify the classes and the keywords in the three subsections for the 3 levels I mentioned earlier. To find out what classes your stuff has, use the ```hyprctl clients``` command while you have the windows and apps in question active. The classes are separated with a ```,``` and the keywords with a ```|```

Inside```hyprland.conf``` you will find examples and more detailed setup tips


#### Tips and Plans and Notes and Stuff:

- [VERY IMPORTANT] AI was involved in writing the code. I will always be open about that. This was not a five minute prompt writing session, this is a result of countless iterations, testing and several major changes in how it works. It's technically just something for me to actually use, and to test for a QA portfolio, but I decided to spread it to others, in case it helps them. If you are convinced that the script is trash simply because AI, then maybe it's not a project for you. However if you have valid criticism, I will always be happy to listen to that.

- Bind the script to a hotkey, which is how I use it personally. But people are different, and maybe that wouldn't be enough for you to restrain yourself from getting distracted again. I will keep it in a form of a script so that everyone can customize and use it as they need to. Create a toggle script to turn it on or off, or create an elaborate Pomodoro timer script to auto enable and disable the script, or whatever. You are in charge

- The flexibility is only limited by your ability to use keywords correctly. 

- I really want to get Firefox protocols working. If you are able to achieve that, tossing some hints, or maybe even a commit would be greatly appreaciated

- I have tons of features in my head to add to this, but I want to keep it simple. It's possible new features will be added, but they will most likely be disabled by default, and I will provide elaborate docs to help people enable them if they need them. If you have feature suggestions, you are more than welcome to drop it in the issues. As well as issues themselves, if you happen to have those too ;)




