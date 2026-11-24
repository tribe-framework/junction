import Service from '@ember/service';
import ENV from 'junction/config/environment';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

export default class AuthService extends Service {
  @service router;
  @service type;

  @tracked inputPassword = '';
  @tracked isLoggedIn = false;
  @tracked goToRouteAfterLogin = 'index';
  @tracked goToSlugAfterLogin = '';
  @tracked projectDescription = '';
  @tracked implementationSummary = '';
  @tracked blueprintLink = '';

  constructor() {
    super(...arguments);
    this.installTribeSession();
  }

  tribeUrl(path) {
    return (ENV.TribeENV?.API_URL ?? '').replace(/\/+$/, '') + path;
  }

  isTribeUrl(url) {
    const apiUrl = ENV.TribeENV?.API_URL ?? '';
    if (!apiUrl || !url) return false;
    try {
      const base = new URL(apiUrl, window.location.href);
      const target = new URL(String(url), window.location.href);
      const basePath = base.pathname.replace(/\/+$/, '') + '/';
      return (
        target.origin === base.origin &&
        (target.pathname + '/').startsWith(basePath)
      );
    } catch {
      return false;
    }
  }

  installTribeSession() {
    if (window.__tribeSessionInstalled) return;
    window.__tribeSessionInstalled = true;

    const isTribeUrl = (url) => this.isTribeUrl(url);

    const nativeFetch = window.fetch.bind(window);
    window.fetch = (input, init = {}) => {
      const url =
        typeof input === 'string' || input instanceof URL ? input : input?.url;
      if (isTribeUrl(url)) {
        return nativeFetch(input, { ...init, credentials: 'include' });
      }
      return nativeFetch(input, init);
    };

    const nativeOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (method, url, ...rest) {
      this.__tribeRequest = isTribeUrl(url);
      return nativeOpen.call(this, method, url, ...rest);
    };

    const nativeSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function (body) {
      if (this.__tribeRequest) this.withCredentials = true;
      return nativeSend.call(this, body);
    };
  }

  checkIfLoggedIn = async () => {
    this.type.loadingSearchResults = true;
    try {
      const response = await fetch(this.tribeUrl('/auth.php?action=status'), {
        headers: { Accept: 'application/json' },
      });
      const body = response.ok ? await response.json() : null;
      this.isLoggedIn = body?.authenticated === true;
    } catch {
      this.isLoggedIn = false;
    }
    this.type.loadingSearchResults = false;
    return this.isLoggedIn;
  };

  urlAfterLogin() {
    if (
      !this.goToRouteAfterLogin ||
      this.goToRouteAfterLogin == 'index' ||
      this.goToRouteAfterLogin == 'auth'
    ) {
      return this.router.urlFor('index');
    }
    if (this.goToSlugAfterLogin) {
      return this.router.urlFor(
        this.goToRouteAfterLogin,
        this.goToSlugAfterLogin,
      );
    }
    return this.router.urlFor(this.goToRouteAfterLogin);
  }

  @action
  async submitPassword() {
    this.type.loadingSearchResults = true;
    let response;
    try {
      response = await fetch(this.tribeUrl('/auth.php?action=login'), {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ password: this.inputPassword ?? '' }),
      });
    } catch {
      response = null;
    }
    this.inputPassword = '';
    this.type.loadingSearchResults = false;

    if (response?.ok) {
      this.isLoggedIn = true;
      window.location.assign(this.urlAfterLogin());
    } else if (response?.status === 429) {
      alert('Too many failed attempts. Try again later.');
    } else {
      alert('Incorrect password.');
    }
  }

  @action
  async justGoToRouteAfterLogin() {
    window.location.assign(this.urlAfterLogin());
  }

  @action
  async logout() {
    try {
      await fetch(this.tribeUrl('/auth.php?action=logout'), {
        method: 'POST',
        headers: { Accept: 'application/json' },
      });
    } finally {
      this.isLoggedIn = false;
      window.location.assign(this.router.urlFor('auth'));
    }
  }
}