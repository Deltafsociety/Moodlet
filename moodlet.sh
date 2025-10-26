#!/bin/bash

# --- Configuration ---
# File to store the mood data (YYYY-MM-DD:MOOD)
DATA_FILE="$HOME/.terminal_mood_data.log"

# Define common 'happy' keywords/emojis for the streak calculation
HAPPY_MOODS="happy good great awesome joyful 😊 😁 😎 🥳 👍"
# --- End Configuration ---


# Function to log the current mood
log_mood() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Check if mood has already been logged today
    if grep -q "^$TODAY:" "$DATA_FILE" 2>/dev/null; then
        local CURRENT_MOOD=$(grep "^$TODAY:" "$DATA_FILE" | cut -d: -f2)
        echo -e "\nWelcome back! Your mood for **$TODAY** is already logged as: **$CURRENT_MOOD**"
        return
    fi

    echo -e "\n--- Terminal Mood Tracker ---"
    read -r -p "How are you feeling today (emoji or word)? " MOOD
    
    if [ -n "$MOOD" ]; then
        # Append the new log entry
        echo "$TODAY:$MOOD" >> "$DATA_FILE"
        echo -e "**Mood logged successfully!** ($MOOD)\n"
    else
        echo "Mood not logged. Feel free to log it next time!"
    fi
}

# Function to calculate and display statistics
calculate_stats() {
    echo -e "\n--- Mood Stats ---"

    if [ ! -f "$DATA_FILE" ]; then
        echo "No mood data logged yet. Log your first mood to see stats!"
        echo "------------------"
        return
    fi
    
    # 1. Most common mood this week
    # Calculate the date from 7 days ago
    local SEVEN_DAYS_AGO=$(date -d "7 days ago" +%Y-%m-%d)
    
    # Filter recent entries, cut out the date, count occurrences, sort, and get the top one
    local MOST_COMMON_MOOD=$(grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}:" "$DATA_FILE" | \
        awk -F: -v date_filter="$SEVEN_DAYS_AGO" '$1 >= date_filter { print $2 }' | \
        sort | uniq -c | sort -nr | head -n 1)

    if [ -n "$MOST_COMMON_MOOD" ]; then
        local COUNT=$(echo "$MOST_COMMON_MOOD" | awk '{print $1}')
        local MOOD_EMOJI=$(echo "$MOST_COMMON_MOOD" | awk '{print $2}')
        echo "**Most common mood this week:** ${MOOD_EMOJI} (logged ${COUNT} times)"
    else
        echo "**No mood data in the last 7 days.**"
    fi

    # 2. Longest streak of 'happy' days (using awk for complex logic)
    # The 'awk' script iterates through all logged dates and moods.
    local LONGEST_STREAK=$(awk -F: -v happy_list="$HAPPY_MOODS" '
        BEGIN { 
            # Initialize streak counters
            longest_streak = 0; 
            current_streak = 0; 
            last_date = "";
            # Convert happy list string to an array (for case-insensitive matching later)
            split(happy_list, happy_arr, " ");
        }
        
        {
            current_date = $1;
            mood_lower = tolower($2);
            
            # Check if current mood is "happy"
            is_happy = 0;
            for (i in happy_arr) {
                if (index(mood_lower, tolower(happy_arr[i])) > 0) {
                    is_happy = 1;
                    break;
                }
            }

            # If it is the first line, initialize last_date
            if (NR == 1) {
                if (is_happy) {
                    current_streak = 1;
                }
            } else {
                # Check if current date is exactly the day after the last date
                # We need a system call to calculate the difference in days
                "date -d \"" current_date "\" +%s" | getline current_ts
                "date -d \"" last_date "\" +%s" | getline last_ts
                
                # Difference in seconds / seconds in a day
                date_diff = (current_ts - last_ts) / 86400;

                if (date_diff == 1) {
                    # Day is consecutive
                    if (is_happy) {
                        current_streak++;
                    } else {
                        current_streak = 0;
                    }
                } else {
                    # Day is not consecutive (gap or out of order)
                    current_streak = is_happy ? 1 : 0;
                }
            }
            
            # Update longest streak
            if (current_streak > longest_streak) {
                longest_streak = current_streak;
            }

            last_date = current_date;
        }

        END {
            # Print the final longest streak value
            print longest_streak;
        }
    ' "$DATA_FILE" )

    if [ "$LONGEST_STREAK" -gt 0 ]; then
        echo "**Longest streak of 'happy' days:** $LONGEST_STREAK"
    else
        echo "**No happy streaks found yet.**"
    fi
    
    echo "------------------"
}

# Main execution
log_mood
calculate_stats
