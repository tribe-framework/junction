import { module, test } from 'qunit';
import { setupTest } from 'junction/tests/helpers';

module('Unit | Route | docs', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    let route = this.owner.lookup('route:docs');
    assert.ok(route);
  });
});
