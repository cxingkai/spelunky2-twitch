const config = {
    identity: {
        username: "", // bot's twitch username
        password: "" // bot's oauth key from https://twitchapps.com/tmi/
    },
    channels: ["pigcowhybrid"],
    API_KEY: "", // client id from app created in https://dev.twitch.tv/console
    API_SECRET: "", // client secret from app created in https://dev.twitch.tv/console
    TWITCH_SIGNING_SECRET: "3a24017dd2dfd0c85b09d48e289785377c9c1c568213e1c378218802e4159ca1", // you can change this with any random string you like
    broadcaster_id: "48509277" // Make a call to https://api.twitch.tv/helix/streams?user_login=yourusername and copy in the user_id from JSON.parse(body).data[0]
};

module.exports = config;