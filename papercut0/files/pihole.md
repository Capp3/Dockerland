# PiHole Setup

## Run this command to whitelist sites. Must be done in terminal, if docker than inside the container.

`pihole -w nyse.com nasdaq.com clients4.google.com clients2.google.com s.youtube.com video-stats.l.google.com android.clients.google.com reminders-pa.googleapis.com firestore.googleapis.com googleapis.l.google.com dl.google.com www.msftncsi.com outlook.office365.com products.office.com c.s-microsoft.com i.s-microsoft.com login.live.com login.microsoftonline.com g.live.com dl.delivery.mp.microsoft.com geo-prod.do.dsp.mp.microsoft.com displaycatalog.mp.microsoft.com sls.update.microsoft.com.akadns.net fe3.delivery.dsp.mp.microsoft.com.nsatc.net clientconfig.passport.net v10.events.data.microsoft.com v20.events.data.microsoft.com client-s.gateway.messenger.live.com xbox.ipv6.microsoft.com device.auth.xboxlive.com www.msftncsi.com title.mgt.xboxlive.com xsts.auth.xboxlive.com title.auth.xboxlive.com ctldl.windowsupdate.com attestation.xboxlive.com xboxexperiencesprod.experimentation.xboxlive.com xflight.xboxlive.com cert.mgt.xboxlive.com xkms.xboxlive.com def-vef.xboxlive.com notify.xboxlive.com help.ui.xboxlive.com licensing.xboxlive.com eds.xboxlive.com www.xboxlive.com v10.vortex-win.data.microsoft.com settings-win.data.microsoft.com s.gateway.messenger.live.com client-s.gateway.messenger.live.com ui.skype.com pricelist.skype.com apps.skype.com m.hotmail.com sa.symcb.com s{1..5}.symcb.com officeclient.microsoft.com spclient.wg.spotify.com apresolve.spotify.com plex.tv tvdb2.plex.tv pubsub.plex.bz proxy.plex.bz proxy02.pop.ord.plex.bz cpms.spop10.ams.plex.bz meta-db-worker02.pop.ric.plex.bz meta.plex.bz tvthemes.plexapp.com.cdn.cloudflare.net tvthemes.plexapp.com 106c06cd218b007d-b1e8a1331f68446599e96a4b46a050f5.ams.plex.services meta.plex.tv cpms35.spop10.ams.plex.bz proxy.plex.tv metrics.plex.tv pubsub.plex.tv status.plex.tv www.plex.tv node.plexapp.com nine.plugins.plexapp.com staging.plex.tv app.plex.tv o1.email.plex.tv o2.sg0.plex.tv dashboard.plex.tv gravatar.com thetvdb.com themoviedb.com services.sonarr.tv skyhook.sonarr.tv download.sonarr.tv apt.sonarr.tv forums.sonarr.tv placehold.it placeholdit.imgix.net dl.dropboxusercontent.com ns1.dropbox.com ns2.dropbox.com itunes.apple.com s.mzstatic.com appleid.apple.com fpdownload.adobe.com entitlement.auth.adobe.com livepassdl.conviva.com gfwsl.geforce.com connectivitycheck.android.com android.clients.google.com clients3.google.com connectivitycheck.gstatic.com msftncsi.com www.msftncsi.com ipv6.msftncsi.com captive.apple.com gsp1.apple.com www.apple.com  www.appleiphonecell.com prod.telemetry.ros.rockstargames.com tracking.epicgames.com`

### Additional Whitelisting
https://github.com/anudeepND/whitelist


## Find Block lists

https://www.opensourceagenda.com/tags/pihole-blocklists

## Regex filters for Pihole, additional to block lists
Run in terminal, inside container if needed.

### Activate Regex
`curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | sudo python3`

### Deactivate Regex
`curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/uninstall.py | sudo python3`

### Keep regexps up-to-date with cron (optional)
The following instructions will create a cron job to run every monday at 02:30 (adjust the time to suit your needs):

1. Edit the root user's crontab (`sudo crontab -u root -e`)

2. Enter the following:
```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
30 2 * * 1 /usr/bin/curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | /usr/bin/python3
```
3. Save changes

#### Removing the manually created cron job
If this script is the only thing you've added to the root user's crontab, you can run:

`sudo crontab -u root -r`

Otherwise, run:

`sudo crontab -u root -e` and remove the three lines listed above in the install instructions.