import { modifier } from 'ember-modifier';
import { Tooltip } from 'bootstrap';

export default modifier(function tooltip(element /*, positional, named*/) {
  new Tooltip(element);
});
