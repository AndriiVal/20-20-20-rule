#!/bin/bash

# Check for sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit
fi

# Install necessary packages
echo "Installing necessary packages..."
apt-get update
apt-get install -y libnotify-bin xprintidle

# Create the screen activity check script
echo "Creating the screen activity check script..."
cat << 'EOF' > /home/$SUDO_USER/reminder_active.sh
#!/bin/bash

while true; do
    # Get idle time in milliseconds
    IDLE_TIME=$(xprintidle)

    # If idle time is less than 5 minutes (300000 ms)
    if [ "$IDLE_TIME" -lt 300000 ]; then
        # Send reminder notification
        notify-send "20-20-20 Rule" "Time to take a break: look at something 20 feet (6 meters) away for 20 seconds."
        
        # Wait for 20 minutes
        sleep 1200
    else
        # Check every minute until the screen is active
        sleep 60
    fi
done
EOF

# Set execute permissions for the script
chmod +x /home/$SUDO_USER/reminder_active.sh
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/reminder_active.sh

# Create the systemd service
echo "Creating the systemd service..."
cat << EOF > /etc/systemd/system/reminder.service
[Unit]
Description=Reminder 20-20-20 Service
After=suspend.target

[Service]
ExecStart=/home/$SUDO_USER/reminder_active.sh
Restart=always
User=$SUDO_USER
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$SUDO_USER/.Xauthority

[Install]
WantedBy=multi-user.target suspend.target
EOF

# Enable and start the service
echo "Enabling and starting the service..."
systemctl daemon-reload
systemctl enable reminder.service
systemctl start reminder.service

echo "Installation complete. The reminder service is running and will automatically restart after sleep mode."
