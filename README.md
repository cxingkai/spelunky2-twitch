# Spelunky 2 Twitch Integration with Channel Point Rewards
Twitch integration with Spelunky 2 that uses channel point rewards to generate random events.

This was made possible thanks to [SilverStar07's repo](https://github.com/SilverStar07/Twitch-EventSub-Full-Implementation) on Twitch's EventSub. Please check them out!

# How to use
You can use this mod for your Spelunky 2 stream, but be warned: there are quite a lot of steps to set it up. If you have any questions, you can send me a message on Discord (pigcowhybrid), and I will hopefully be able to answer.

## Install dependencies
1. Pull this repo. Easiest way is probably to download the ZIP and extracting it.
2. Install [NodeJS](https://nodejs.org/en)
3. Go to the root folder of your copy of this repo and open up a terminal (Right click->Open in Terminal)
4. Run `npm install`
5. Install [Chocolatey](https://chocolatey.org/install).
6. Open up powershell and run `choco install openssl`. Note that if you used powershell to change execution policy in the previous step, you'll have to restart the powershell.
7. Install and authenticate [ngrok](https://ngrok.com/). Note that after installation, you should also go to "Your Authtoken" on the ngrok dashboard and follow the instructions there.

## Generate a certificate
1. Open a terminal in `src\cert`
2. Run `openssl genrsa -out key.pem`
3. Run `openssl req -new -key key.pem -out csr.pem`. You will be asked for some information. You don't need to fill in any field except for common name, which should be `localhost:4000`
4. Run `openssl x509 -req -days 9999 -in csr.pem -signkey key.pem -out cert.pem`

## Config setup
1. Open `src\config.js` with a source code editor like Notepad++. You will notice some fields to fill in.
2. In `username`, type in any name you want in between the quotation marks. "Spelunky 2 Bot" works just fine.
3. Go to [Twitch Chat OAuth Password Generator](https://twitchapps.com/tmi/) and press connect. Then, copy the given password (it should start with "oauth:") and paste it into the quotation marks for `password`
4. In `channels`, replace pigcowhybrid with the name of your twitch channel
5. Go to [Twitch Dev Console](https://dev.twitch.tv/console)https://dev.twitch.tv/console) and create an application. Copy the given client id and paste it into the field for `API_KEY`. Click `New Secret` and paste the given string into the field for `API_SECRET`.
6. Turn on your stream. Next, go to [Postman](https://www.postman.com/) and create a new http request. Set the command to GET and the url to `https://api.twitch.tv/helix/streams?user_login=[YOUR USERNAME]`, replacing [YOUR USERNAME] with your twitch username. Click send and you will see some data. Copy the string in the `user_id` field and paste it into the `broadcaster_id` field in the config file.
7. (Optional) Generate a random string for `TWITCH_SIGNING_SECRET`

## Give Twitch permission to your app
1. Open a terminal in `src`
2. Run `node bot.js`. You will get some errors but ignore them for now.
3. Go to `https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=[CLIENT ID]&redirect_uri=https://localhost:4000/redirect&scope=channel:read:redemptions`, replacing `[CLIENT ID]` with the client ID of your twitch app
4. Click accept to give permissions

## Mod setup
1. Install Modlunky if you haven't done so yet.
2. Copy the `Spelunky Twitch Integration` folder into `Spelunky 2\Mods\Packs`. You should see it show up in Modlunky.
3. Create a reward for your channel called `the magic button`. For details on how to change this, check the "How to edit" section below.

And we are finally done with the setup!

## How to use
1. Open the ngrok executable and run `ngrok http https://localhost:4000`
2. Copy the forwarding address (it should start with "https://" and end with ".app") and paste it in line 19 of `bot.js`, replacing the already existing address. Save `bot.js`.
3. Open a terminal in `src`
4. Run `node bot.js`
5. You are good to go! While playing Spelunky 2, if any viewer redeems "the magic button", you should get a random event.
6. When stopping your stream, press Ctrl + C on both terminal windows.

## How to edit
You may not want to have "the magic button" as the reward, but you can change it to something else. But before that, open `Spelunky Twitch Integration\Data\parse.lua`. Search for `if MSG == "the magic button"` and replace `the magic button` with whatever your reward is called.
