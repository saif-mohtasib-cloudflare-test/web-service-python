/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url)

    if (url.pathname === "/secure") {
      const email = request.headers.get("cf-access-authenticated-user-email") || "Unknown"
      const country = request.headers.get("cf-ipcountry") || "XX"
      const timestamp = new Date().toISOString()

      return new Response(`
        <html>
          <head><title>This is the Secure Tunnel, No Sunshine, No Moonlight, Only Tungsten light</title></head>
          <body>
            <p>The ${email} authenticated at ${timestamp} from ${country}</p>
            <a href="/secure/${country}">View your country flag ;)</a>
          </body>
        </html>
      `, {
        headers: { "Content-Type": "text/html" }
      })
    }

    const countryMatch = url.pathname.match(/^\/secure\/([A-Z]{2})$/);
    if (countryMatch) {
      const code = countryMatch[1].toLowerCase();
      const object = await env.FLAGS_BUCKET.get(`${code}.png`);

      if (!object) {
        return new Response("Flag not found", { status: 404 });
      }

      return new Response(object.body, {
        headers: { "Content-Type": "image/png" }
      });
    }

    return new Response("Not Found", { status: 404 })
  }
}
