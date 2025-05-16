import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import ENV from 'junction/config/environment';

export default class TypesBlueprintObjectModalComponent extends Component {
  @service object;

  unixTimestampToLocalTime = (unixTimestamp) => {
    const date = new Date(unixTimestamp * 1000); // Convert seconds to milliseconds

    return date.toLocaleDateString('en-UK', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    });
  };

  @action
  copyJSON(object, e) {
    e.target.innerHTML = 'Copied!';
    navigator.clipboard.writeText(JSON.stringify(object, null, '\t'));

    later(
      this,
      () => {
        e.target.innerHTML = '<i class="fa-solid fa-copy"></i> Copy JSON';
      },
      2000,
    );
  }

  @action
  copyAPILink(type, id, e) {
    e.target.innerHTML = 'Copied!';
    navigator.clipboard.writeText(
      ENV.TribeENV.API_URL + '/api.php/' + type + '/' + id,
    );

    later(
      this,
      () => {
        e.target.innerHTML = '<i class="fa-solid fa-copy"></i> Copy API URL';
      },
      2000,
    );
  }
}
