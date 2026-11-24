import { helper } from '@ember/component/helper';
import ENV from 'junction/config/environment';

export default helper(function fileUrl([url]) {
  if (typeof url !== 'string' || url === '') {
    return url;
  }

  const apiUrl = (ENV.TribeENV.API_URL ?? '').replace(/\/+$/, '');

  if (apiUrl === '' || url.startsWith(apiUrl) || /^https?:\/\//i.test(url)) {
    return url;
  }

  return apiUrl + '/' + url.replace(/^\/+/, '');
});
