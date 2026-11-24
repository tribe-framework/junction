import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

export default class GoToTopComponent extends Component {
  @service colormodes;

  @action
  goToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  <template>
    <div class="position-fixed bottom-0 end-0 m-3">
      <div
        class="text-{{this.colormodes.inverseMode}}"
        {{on "click" this.goToTop}}
      ><i class="fa-solid fa-circle-chevron-up fa-2x"></i></div>
    </div>
  </template>
}
