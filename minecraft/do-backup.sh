#!/usr/bin/env bash
MC=$HOME/mc
MC_BACKUP=$MC/minecraft-backup
SERVERS=$MC/active

$MC_BACKUP/backup.sh -a zstd -e zst -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o $MC/backups
export RESTIC_PASSWORD_FILE=$MC/restic-password.txt
$MC_BACKUP/backup-restic.sh -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o $MC/minecraft-restic
$MC_BACKUP/backup-restic.sh -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o sftp:intranet:/mnt/extstorage/backups/privatesurvival-restic
$MC_BACKUP/backup-restic.sh -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o sftp:francis:harddrive2/backups/minecraft-restic
$MC_BACKUP/backup-restic.sh -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o sftp:randall:minecraft-restic
$MC_BACKUP/backup-restic.sh -g -c -s privatesurvival -i $SERVERS/privatesurvival/world -o rclone:berkeley-drive-enc:/minecraft-restic
$MC_BACKUP/backup-restic.sh -g -c -s atm3 -i $SERVERS/atm3/world -o sftp:intranet:/mnt/extstorage/backups/privatesurvival-restic
$MC_BACKUP/backup-restic.sh -g -c -s atm3 -i $SERVERS/atm3/world -o rclone:berkeley-drive-enc:/minecraft-restic
