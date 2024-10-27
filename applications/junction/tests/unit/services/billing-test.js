import { module, test } from 'qunit';
import { setupTest } from 'junction/tests/helpers';

module('Unit | Service | billing', function (hooks) {
  setupTest(hooks);

  // TODO: Replace this with your real tests.
  test('it exists', function (assert) {
    let service = this.owner.lookup('service:billing');
    assert.ok(service);
  });
});
