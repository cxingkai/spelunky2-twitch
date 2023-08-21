const tmi = require('tmi.js');
const configuration = require('./config');
const axios = require('axios');
const fs = require('fs');
const express = require('express');
const httpsApp = express();
const httpsServer = require('https').createServer({
    key: fs.readFileSync("cert/key.pem"),
    cert: fs.readFileSync("cert/cert.pem")
}, httpsApp);
const crypto = require('crypto');
const https = require('https');
const os = require('os');

const chatbot = new tmi.client(configuration);
chatbot.on("message", chatMessageHandler);
chatbot.connect();

const ngrokURL = "https://1300-42-60-23-45.ngrok-free.app";
let access_token = "";

const logFileName = os.tmpdir() + "\\spelunky2TwitchLog.txt";
fs.writeFile(logFileName, "", (err) => {
    if (err) {
        console.log(err);
    }
    else {
        console.log("Log file created successfully at " + logFileName);
    }
});

const eventTypes = [
    "channel.channel_points_custom_reward_redemption.add",
    "stream.online",
    "channel.update"
];
const eventTypesConfig = {
    "channel.channel_points_custom_reward_redemption.add": {
        "type": "channel.channel_points_custom_reward_redemption.add",
        "version": "1",
        "condition":
            {
                "broadcaster_user_id": configuration.broadcaster_id
            }
    },
    "stream.online": {
        "type": "stream.online",
        "version": "1",
        "condition":
            {
                "broadcaster_user_id": configuration.broadcaster_id
            }
    },
    "channel.update": {
        "type": "channel.update",
        "version": "2",
        "condition":
            {
                "broadcaster_user_id": configuration.broadcaster_id
            }
    }
};
console.log("Number of events to subscribe to: " + eventTypes.length);

axios.post("https://id.twitch.tv/oauth2/token" +
    "?client_id=" + configuration.API_KEY +
    "&client_secret=" + configuration.API_SECRET +
    "&grant_type=client_credentials" +
    "&scope=channel:read:redemptions")
    .then(response => {
        const responseData = response.data;
        access_token = responseData.access_token;

        for (let i = 0; i < eventTypes.length; i++) {
            axios.post(ngrokURL + "/createWebhook?eventType=" + eventTypes[i])
                .then(() => {
                    console.log(i, "Webhook successfully established: " + eventTypes[i]);
                })
                .catch(webhookError => {
                    console.log("Webhook creation error: " + webhookError + ", EventType: " + eventTypes[i]);
                });
        }
    })
    .catch(error => {
        console.log(error);
    });

const verifyTwitchWebhookSignature = (request, response, buffer, encoding) => {
    const twitchMessageID = request.header("Twitch-Eventsub-Message-Id");
    const twitchTimeStamp = request.header("Twitch-Eventsub-Message-Timestamp");
    const twitchMessageSignature = request.header("Twitch-Eventsub-Message-Signature");
    const currentTimeStamp = Math.floor(new Date().getTime() / 1000);

    if (Math.abs(currentTimeStamp - twitchTimeStamp) > 600) {
        throw new Error("Signature is older than 10 minutes. Ignore this request.");
    }
    if (!configuration.TWITCH_SIGNING_SECRET) {
        throw new Error("The Twitch signing secret is missing.");
    }

    const ourMessageSignature = "sha256=" +
        crypto.createHmac("sha256", configuration.TWITCH_SIGNING_SECRET)
            .update(twitchMessageID + twitchTimeStamp + buffer)
            .digest("hex");

    if (twitchMessageSignature !== ourMessageSignature) {
        throw new Error("Invalid signature");
    }
    else {
        console.log("Signature verified");
    }
};

const twitchWebhookEventHandler = (webhookEvent) => {
    // Do whatever crazy stuff you want to do with events here!
    // For information on individual event attributes go to
    // https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types
    const webhookSubscriptionType = webhookEvent.subscription.type;
    let eventUsername = webhookEvent.event.user_name ? webhookEvent.event.user_name : '';
    console.log(webhookSubscriptionType);

    if (webhookSubscriptionType === "stream.online") {
        console.log("stream is live!");
    }
    else if (webhookSubscriptionType === "channel.update") {
        console.log("stream is updated!");
        fs.appendFile(logFileName, webhookEvent.event.broadcaster_user_name + ":"+ webhookEvent.event.title + "\r\n", function(err) {
            if (err) {
                throw err;
            }
            console.log('New Line added to log file');
        });
    }
    else if (webhookSubscriptionType === "channel.channel_points_custom_reward_redemption.add") {
        console.log("stream is updated!");
        fs.appendFile(logFileName, webhookEvent.event.user_name + ":" + webhookEvent.event.reward.title + "\r\n", function(err) {
            if (err) {
                throw err;
            }
            console.log('New Line added to log file');
        });
    }
    else {
        setTimeout(() => {
            // Put your code here to do something 30 seconds after the event,
            // or you change the stream title or game.
            
        }, 30000);
    }
};

function chatMessageHandler(channel, userState, message, self) {
    const wordArray = message.split(" ");

    if (wordArray[0].toLowerCase() === "!endstream") {
        axios.get("https://api.twitch.tv/helix/eventsub/subscriptions",
            {
                headers: {
                    "Client-Id": configuration.API_KEY,
                    Authorization: "Bearer " + access_token
                }
            })
            .then(response => {
                if (response.status === 200) {
                    const subscribedEvents = response.data;
                    console.log("Number of events to unsubscribe: " + subscribedEvents.data.length);

                    for (let i = 0; i < subscribedEvents.data.length; i++) {
                        axios.delete("https://api.twitch.tv/helix/eventsub/subscriptions?id=" +
                            subscribedEvents.data[i].id,
                            {
                                headers: {
                                    "Client-ID": configuration.API_KEY,
                                    Authorization: "Bearer " + access_token
                                }
                            }).then(() => {
                            console.log(i, subscribedEvents.data[i].type + " unsubscribed");
                        }).catch(webhookError => {
                            console.log("Webhook unsubscribe error: " + webhookError);
                        });
                    }
                }
                else {
                    console.log(response.status, response.data);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
}

httpsApp.use(express.static(__dirname + "/html"));
httpsApp.use(express.json({verify: verifyTwitchWebhookSignature}));

httpsServer.listen(4000, function () {
    console.log("HTTPS Server is started! Have fun!");
});

httpsApp.get('/redirect', function (request, response) {
    response.sendFile(__dirname + "/html/appAccessRedirect.html");
});

httpsApp.post('/twitchwebhooks/callback',
    async (request, response) => {
        // Handle the Twitch webhook challenge
        if (request.header("Twitch-EventSub-Message-Type") === "webhook_callback_verification") {
            console.log("Verifying the Webhook is from Twitch");
            response.writeHeader(200, {"Content-Type": "text/plain"});
            response.write(request.body.challenge);

            return response.end();
        }

        // Handle the Twitch event
        const eventBody = request.body;
        console.log("Recieving " +
            eventBody.subscription.type + " request for " +
            eventBody.event.broadcaster_user_name, eventBody);
        twitchWebhookEventHandler(eventBody);
        response.status(200).end();
    });

httpsApp.post('/createWebhook', (request, response) => {
    let createWebhookParameters = {
        host: "api.twitch.tv",
        path: "helix/eventsub/subscriptions",
        method: 'POST',
        headers: {
            "Content-Type": "application/json",
            "Client-ID": configuration.API_KEY,
            "Authorization": "Bearer " + access_token
        }
    };

    let createWebhookBody = {
        ...eventTypesConfig[request.query.eventType],
        "transport": {
            "method": "webhook",
            "callback": ngrokURL + "/twitchwebhooks/callback",
            "secret": configuration.TWITCH_SIGNING_SECRET
        }
    };

    let responseData = "";
    let webhookRequest = https.request(createWebhookParameters, (result) => {
        result.setEncoding('utf8');
        result.on('data', function (data) {
            responseData = responseData + data;
        }).on('end', function (result) {
            let responseBody = JSON.parse(responseData);
            response.send(responseBody);
        })
    });

    webhookRequest.on('error', (error) => {
        console.log(error);
    });
    webhookRequest.write(JSON.stringify(createWebhookBody));
    webhookRequest.end();
});