// Thin entry-point so Cloudflare has a running script per request.
// `wrangler tail` needs a Worker with a script — assets-only Workers
// return CF error 100311 ("Cannot tail a Worker which only has assets.").
// This handler just delegates to the ASSETS binding, so behaviour is
// identical to an assets-only Worker but logs are now tailable.

export default {
  async fetch(request, env) {
    return env.ASSETS.fetch(request);
  },
};
