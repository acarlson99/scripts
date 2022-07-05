// node index.js -t=$ACCESS_TOKEN -p=$PLAYLIST_ID
// node index.js -c=$CLIENT_ID -s=$CLIENT_SECRET -p=$PLAYLIST_ID

var express = require("express"); // Express web server framework
var request = require("request"); // "Request" library
var cors = require("cors");
var querystring = require("querystring");
const { exit } = require("process");
const yargs = require("yargs");
const { string } = require("yargs");

var client_id = "ID"; // Your client id
var client_secret = "ID"; // Your secret
var redirect_uri = "http://localhost:8888/callback"; // Your redirect uri

var app = express();

app.use(express.static(__dirname + "/public")).use(cors());

app.get("/login", function (req, res) {
  // your application requests authorization
  var scope = "user-read-private user-read-email";
  res.redirect(
    "https://accounts.spotify.com/authorize?" +
      querystring.stringify({
        response_type: "code",
        client_id: client_id,
        scope: scope,
        redirect_uri: redirect_uri,
      })
  );
});

app.get("/callback", function (req, res) {
  // your application requests refresh and access tokens
  // after checking the state parameter

  var code = req.query.code || null;

  var authOptions = {
    url: "https://accounts.spotify.com/api/token",
    form: {
      code: code,
      redirect_uri: redirect_uri,
      grant_type: "authorization_code",
    },
    headers: {
      Authorization:
        "Basic " +
        new Buffer(client_id + ":" + client_secret).toString("base64"),
    },
    json: true,
  };

  request.post(authOptions, function (error, response, body) {
    if (!error && response.statusCode === 200) {
      // TODO: save these to file, refresh sometimes only if needed
      var access_token = body.access_token,
        refresh_token = body.refresh_token;
      setAccessToken(access_token, refresh_token);

      go(access_token, "77I2RaiAtwBlxgnvdRfW7D", true);
      res.redirect("/#done");
    } else {
      res.redirect(
        "/#" +
          querystring.stringify({
            error: "invalid_token",
          })
      );
    }
  });
});

function go(access_token, playlistID, doEncode = false) {
  var options = {
    url: "https://api.spotify.com/v1/playlists/" + playlistID + "/tracks",
    headers: { Authorization: "Bearer " + access_token },
    json: true,
  };

  // use the access token to access the Spotify Web API
  request.get(options, function (error, response, body) {
    if (error != null) {
      console.error(error);
      return;
    }
    body.items.map((o) => {
      let s = o.track.name + " " + o.track.artists.map((a) => a.name);
      if (doEncode) s = encodeURIComponent(s);
      console.log(s);
    });
    exit(0);
  });
}

function refreshToken(refresh_token) {
  var authOptions = {
    url: "https://accounts.spotify.com/api/token",
    headers: {
      Authorization:
        "Basic " +
        new Buffer(client_id + ":" + client_secret).toString("base64"),
    },
    form: {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
    },
    json: true,
  };

  request.post(authOptions, function (error, response, body) {
    if (!error && response.statusCode === 200) {
      setAccessToken(body.access_token);
    }
  });
}

function setAccessToken(access_token, refresh_token = null) {
  // TODO: write to file
  console.warn("using tok >", access_token);
}

const argv = yargs
  .option("raw", {
    alias: "r",
    description: "URL encode result",
    type: Boolean,
    default: false,
  })
  .option("playlistID", {
    alias: "p",
    description: "playlist id",
    type: string,
    required: true,
  })
  .command(
    "tok",
    "use auth token",
    (y) =>
      y.option("accessToken", {
        alias: "t",
        description: "access token to use",
        type: string,
        required: true,
      }),
    (argv) => {
      go(argv.accessToken, argv.playlistID, !argv.raw);
    }
  )
  .command(
    "auth",
    "authorize with clientID, clientSecret",
    (y) =>
      y
        .option("clientID", {
          alias: "c",
          description: "client id",
          type: string,
          required: true,
        })
        .option("clientSecret", {
          alias: "s",
          description: "client secret",
          type: string,
          required: true,
        }),
    (argv) => {
      console.warn("go to http://localhost:8888/login");
      client_id = argv.clientID;
      client_secret = argv.clientSecret;
    }
  )
  .help()
  .alias("help", "h").argv;

app.listen(8888);
