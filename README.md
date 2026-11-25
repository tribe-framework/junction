# Junction

**🚀 Build for publishing:**:

```bash
bash build.sh
```

## Develop against a live Tribe

Junction does not use an API key. It logs in with the live server's `JUNCTION_PASSWORD` and receives a session cookie. During `npm start`, the Vite dev server proxies Tribe requests to the live server so that the cookie works on `localhost`.

1. Copy `.env.sample` to `.env` and set these values:

   | Variable | Value |
   | --- | --- |
   | `TRIBE_API_URL` | The address of the local dev server, fixed to `http://localhost:4200` in `vite.config.mjs`. |
   | `TRIBE_LIVE_URL` | The address of the live Tribe, for example `https://tribe.domain.tld`. |
   | `JUNCTION_LIVE_URL` | The live server's `JUNCTION_URL`, exactly as set in its `.env`. |

2. Start the dev server:

   ```bash
   npm start
   ```

3. Log in with the live server's `JUNCTION_PASSWORD`.

The proxy forwards `/api.php`, `/auth.php`, `/uploads.php`, `/search.php` and `/uploads/` to `TRIBE_LIVE_URL`. It sends `JUNCTION_LIVE_URL` as the request's `Origin`, and it removes `Secure` and `Domain` from the session cookie so the browser keeps it on `http://localhost`.

Every change made this way writes to live data. Failed logins count towards the live server's limit of 10 per 15 minutes from your IP address.

`build.sh` moves `.env` aside before building, so these settings do not reach `dist`. The published `dist` reads `TRIBE_API_URL` from the server through `_head.php`.

Leave `TRIBE_LIVE_URL` empty to run Junction against a local Tribe without the proxy. In that case, set `TRIBE_API_URL` to the local Tribe address, for example `http://localhost:12000`, and serve Junction on the port set as `JUNCTION_PORT` in Tribe's `.env`.