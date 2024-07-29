#!/bin/bash

# Check for sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit
fi

# Stop the service
echo "Stopping the reminder service..."
systemctl stop reminder.service

# Disable the service
echo "Disabling the reminder service..."
systemctl disable reminder.service

# Remove the service file
echo "Removing the service file..."
rm /etc/systemd/system/reminder.service

# Reload systemd to apply changes
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Remove the reminder script
echo "Removing the reminder script..."
rm /home/$SUDO_USER/reminder_active.sh

echo "Uninstallation complete."
