

````markdown
# MoodShell 🐱💻

**MoodShell** is a quirky terminal-based mood tracker that keeps tabs on your daily feelings—right from the comfort of your command line. Track your moods, see trends, and reflect on your emotional patterns, all without leaving the terminal.  

---

## Features

- Prompt-based mood logging every time you open your terminal  
- Supports emoji, colors, and fun terminal formatting  
- Tracks streaks and most common moods  
- Generates weekly/monthly summaries in ASCII charts  
- Lightweight and completely terminal-friendly  

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Deltafsociety/moodlet.git
cd moodshell
````

2. Make the script executable:

```bash
chmod +x moodlet.sh
```

3. Optionally, add it to your `.bashrc` to log moods on terminal start:

```bash
echo "~/path/to/moodlet.sh" >> ~/.bashrc
```

---

## Usage

Run the script:

```bash
./moodlet.sh
```

You’ll be prompted to enter your mood. Example:

```text
How are you feeling today? 😎
```

Then your mood is logged and optionally displayed with your current streak and summary.

---

## Configuration

* Customize your moods in `moods.txt` (default emojis supported)
* Enable weekly summaries with `--summary` flag
* Change colors in `config.sh`

---

## Example

```text
Welcome back, Delta! 🌸
Today's mood: 😄
Longest happy streak: 3 days
Most frequent mood this week: 😎
```

---

## Future Ideas

* Mood reminders at random intervals
* Mood-based terminal themes
* Share your mood summaries via Git commits

---

## License

This project is licensed under the **GPL3**

---

Made with 💜 for hackers and anyone who loves tracking their vibes in the terminal.

```




