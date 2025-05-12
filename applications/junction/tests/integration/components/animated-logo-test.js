import { module, test } from 'qunit';
import { setupRenderingTest } from 'junction/tests/helpers';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Integration | Component | animated-logo', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    // Set any properties with this.set('myProperty', 'value');
    // Handle any actions with this.set('myAction', function(val) { ... });

    await render(hbs`<AnimatedLogo />`);

    assert.dom().hasText('');

    // Template block usage:
    await render(hbs`
      <AnimatedLogo>
        template block text
      </AnimatedLogo>
    `);

    assert.dom().hasText('template block text');
  });
});
