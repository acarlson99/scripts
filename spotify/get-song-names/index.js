// node index.js tok -t=$ACCESS_TOKEN -p=$PLAYLIST_ID
// node index.js auth -c=$CLIENT_ID -s=$CLIENT_SECRET -p=$PLAYLIST_ID

var express = require("express"); // Express web server framework
var request = require("request"); // "Request" library
var cors = require("cors");
var querystring = require("querystring");
const { exit } = require("process");
const yargs = require("yargs");
const { string } = require("yargs");
const fs = require("fs");

var client_id = "ID";
var client_secret = "ID";
var redirect_uri = "http://localhost:8888/callback";
var access_token = "";
var refresh_token = "";

var app = express();

app
  .use(express.static(__dirname + "/public"))
  .use(express.json())
  .use(cors());

app.get("/login", function (req, res) {
  // your application requests authorization
  var scope =
    "user-read-private user-read-email user-library-read playlist-modify-public playlist-modify-private playlist-read-private";
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
      access_token = body.access_token;
      refresh_token = body.refresh_token;
      setAccessToken(access_token, refresh_token);

      res.redirect("/#" + access_token);
      exit(0);
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

// TODO: make thingy to use this
app.post("/addToPlaylist", function (req, res) {
  // post request
  // {
  //   "id": "playlist-id",
  //   "uris": ["spotify:track:1", "spotify:track:2"],
  // }
  // curl localhost:8888/addToPlaylist -i -X POST -H "Content-Type: application/json" \
  //     -d '{"id":"1mzezGWHiPSMOkDFb2R1vm","uris":["spotify:track:7ouMYWpwJ422jRcDASZB7P"]}'
  console.log("req.body", req.body);
  console.log(encodeURIComponent(req.body.uris.join(",")));
  request.post(
    {
      url:
        "https://api.spotify.com/v1/playlists/" +
        req.body.id +
        "/tracks?uris=" +
        encodeURIComponent(req.body.uris.join(",")),
      headers: { Authorization: "Bearer " + access_token },
      json: true,
    },
    function (error, response, body) {
      res.sendStatus(response.statusCode);
      console.log(body);
    }
  );
});

function setAccessToken(access_token, refresh_token = null) {
  // TODO: write to file
  console.log("access_token", access_token);
  if (refresh_token) console.log("refresh_token", refresh_token);

  fs.writeFileSync("access_token", access_token, () => {});
  if (refresh_token) fs.writeFileSync("refresh_token", refresh_token, () => {});
}

const argv = yargs
  .command(
    "go",
    "use auth token",
    (y) =>
      y
        .option("raw", {
          alias: "r",
          description: "URL encode result",
          type: Boolean,
          default: false,
        })
        .option("accessToken", {
          alias: "t",
          description: "access token to use",
          type: string,
          required: true,
        })
        .option("playlistID", {
          alias: "p",
          description: "playlist id",
          type: string,
          required: false,
        }),
    (argv) => {
      access_token = argv.accessToken;
      playlistID = argv.playlistID;
      doEncode = !argv.raw;
      var options = {
        url: "https://api.spotify.com/v1/me/tracks",
        headers: { Authorization: "Bearer " + access_token },
        json: true,
      };
      if (argv.playlistID) {
        options.url =
          "https://api.spotify.com/v1/playlists/" + playlistID + "/tracks";
      }

      // FIXME: this only works for 20 songs at a time
      request.get(options, function (error, response, body) {
        if (error != null) {
          console.error(error);
          return;
        }
        console.log(body);
        let ids = body.items.map((o) => o.track.id);
        console.log(ids.length);
        let tracks = body.items;
        // let s = o.track.name + " " + o.track.artists.map((a) => a.name);
        // if (doEncode) s = encodeURIComponent(s);
        // console.log(s);
        // console.log(ids);

        request.get(
          {
            url:
              "https://api.spotify.com/v1/audio-features?ids=" + ids.join(","),
            headers: options.headers,
            json: true,
          },
          (error, response, body) => {
            let l = [];
            for (let i = 0; i < body.audio_features.length; i++) {
              let features = body.audio_features[i];
              let track = tracks[i];
              if (features.id != track.track.id) throw "fuck id doesn't match";
              l.push({ features: features, ...track });
            }
            app.get("/thing", (req, res) => {
              // from browser JSON.parse(atob(decodeURIComponent(window.location.hash.slice(1))))
              res.redirect(
                "/workshop.html#" + encodeURIComponent(btoa(JSON.stringify(l)))
              );
            });
            // console.log(l);
            // console.log(l.length);
            // TODO: send list to browser for filtering somehow
            // exit(0);
          }
        );
      });
    }
  )
  .command("auth", "authorize/refresh", (y) =>
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
      })
      .command(
        "get",
        "authorize",
        (y) => y,
        (argv) => {
          client_id = argv.clientID;
          client_secret = argv.clientSecret;

          console.warn("go to http://localhost:8888/login");
        }
      )
      .command(
        "refresh",
        "refresh token",
        (y) =>
          y.option("refreshToken", {
            alias: "t",
            description: "refresh token",
            type: string,
            required: true,
          }),
        (argv) => {
          client_id = argv.clientID;
          client_secret = argv.clientSecret;

          var authOptions = {
            url: "https://accounts.spotify.com/api/token",
            headers: {
              Authorization:
                "Basic " +
                new Buffer(client_id + ":" + client_secret).toString("base64"),
            },
            form: {
              grant_type: "refresh_token",
              refresh_token: argv.refreshToken,
            },
            json: true,
          };

          request.post(authOptions, function (error, response, body) {
            if (!error && response.statusCode === 200) {
              setAccessToken(body.access_token, body.refresh_token);
            }
            exit(0);
          });
        }
      )
  )
  .help()
  .alias("help", "h").argv;

app.listen(8888);
