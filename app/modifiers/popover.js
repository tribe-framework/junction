import { modifier } from 'ember-modifier';
import { Popover } from 'bootstrap';

export default modifier(function popover(element /*, positional, named*/) {
  new Popover(element);
});
