import Controller from '@ember/controller';
import { service } from '@ember/service';
import ENV from 'junction/config/environment';

export default class IndexController extends Controller {
  @service types;
  @service colormodes;

  get plausibleEmbedUrl() {
    if (!ENV.PLAUSIBLE_EMBED_URL) return null;
    const url = new URL(ENV.PLAUSIBLE_EMBED_URL);
    url.searchParams.set('embed', 'true');
    url.searchParams.set('theme', this.colormodes.mode);
    return url.toString();
  }
}