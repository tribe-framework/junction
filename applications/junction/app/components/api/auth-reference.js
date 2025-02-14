import Component from '@glimmer/component';
import hljs from 'highlight.js';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class ApiAuthReference extends Component {
  @action
  highlightAll() {
    hljs.highlightAll();
  }
}
