#!/bin/bash

# --- Configuration ---
# File to store the mood data (YYYY-MM-DD:MOOD)
# File to store the mood data (YYYY-MM-DD:MOOD)
DATA_FILE="$HOME/.terminal_mood_data.log"

# Automatically read the system's current username
USERNAME="${USER:-$(id -un)}"
# Default emoji for welcome message
DEFAULT_EMOJI="🌸"

# Define **POSITIVE/HAPPY** keywords/emojis for the streak calculation.
# The script will still log and track ALL moods (including angry, sad, etc.),
# but only moods on this list will count toward the "happy streak."
HAPPY_MOODS="happy good great awesome joyful excited amazing fantastic superb 😁 😊 😎 🥳 👍 ✨ 🤩"
# --- End Configuration ---

# Ensure the data file exists
touch "$DATA_FILE"

# Function to get the current day's mood, or prompt for a new one
get_current_mood() {
    local TODAY=$(date +%Y-%m-%d)
    local CURRENT_MOOD

    # Check if mood has already been logged today
    if grep -q "^$TODAY:" "$DATA_FILE"; then
        CURRENT_MOOD=$(grep "^$TODAY:" "$DATA_FILE" | cut -d: -f2)
        echo "$CURRENT_MOOD"
        return 0
    fi

    # If not logged, prompt the user
    echo -e "\nWelcome back, $USERNAME! $DEFAULT_EMOJI"
    read -r -p "How are you feeling today (emoji or word)? " MOOD

    if [ -n "$MOOD" ]; then
        # Append the new log entry
        echo "$TODAY:$MOOD" >> "$DATA_FILE"
        echo "$MOOD" # Return the newly logged mood
    else
        echo "$DEFAULT_EMOJI" # Return default if user skips
    fi
}

# Function to calculate and display statistics
calculate_stats() {
    local LONGEST_STREAK
    local SEVEN_DAYS_AGO
    local MOST_COMMON_MOOD

    # 1. Calculate the Longest Happy Streak (using awk for complex date logic)
    LONGEST_STREAK=$(awk -F: -v happy_list="$HAPPY_MOODS" '
        BEGIN {
            longest_streak = 0;
            current_streak = 0;
            last_date = "";
            split(happy_list, happy_arr, " ");
        }
        {
            current_date = $1;
            mood_lower = tolower($2);
            is_happy = 0;
            for (i in happy_arr) {
                if (index(mood_lower, tolower(happy_arr[i])) > 0) {
                    is_happy = 1;
                    break;
                }
            }

            if (NR == 1) {
                current_streak = is_happy ? 1 : 0;
            } else {
                "date -d \"" current_date "\" +%s" | getline current_ts
                "date -d \"" last_date "\" +%s" | getline last_ts
                date_diff = (current_ts - last_ts) / 86400;

                if (date_diff == 1) {
                    current_streak = is_happy ? current_streak + 1 : 0;
                } else {
                    current_streak = is_happy ? 1 : 0;
                }
            }

            if (current_streak > longest_streak) {
                longest_streak = current_streak;
            }
            last_date = current_date;
        }
        END { print longest_streak; }
    ' "$DATA_FILE" )


    # 2. Calculate Most Frequent Mood This Week
    SEVEN_DAYS_AGO=$(date -d "7 days ago" +%Y-%m-%d)

    MOST_COMMON_MOOD=$(grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}:" "$DATA_FILE" | \
        awk -F: -v date_filter="$SEVEN_DAYS_AGO" '$1 >= date_filter { print $2 }' | \
        sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

    if [ -z "$MOST_COMMON_MOOD" ]; then
        MOST_COMMON_MOOD="N/A"
    fi

    # 3. Print the formatted stats
    echo "Longest happy streak: ${LONGEST_STREAK} days"
    echo "Most frequent mood this week: ${MOST_COMMON_MOOD}"
}


# --- Main Execution ---

# 1. Get/Log Mood (No 'local' here, as we are in the main script body)
TODAYS_MOOD=$(get_current_mood)

# 2. Print the final output block
if [ -n "$TODAYS_MOOD" ]; then
    TODAY=$(date +%Y-%m-%d) # Note: Removed 'local'

    # Only print the Welcome line if the mood was ALREADY logged.
    # (If it wasn't, get_current_mood() already printed the prompt.)
    if grep -q "^$TODAY:" "$DATA_FILE"; then
         echo -e "\nWelcome back, $USERNAME! $DEFAULT_EMOJI"
    fi

    echo "Today's mood: ${TODAYS_MOOD}"
    calculate_stats
    echo "" # Final newline for a clean prompt
fi
