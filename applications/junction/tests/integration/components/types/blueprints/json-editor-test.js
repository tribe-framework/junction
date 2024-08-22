import { module, test } from 'qunit';
import { setupRenderingTest } from 'junction/tests/helpers';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module(
  'Integration | Component | types/blueprints/json-editor',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      // Set any properties with this.set('myProperty', 'value');
      // Handle any actions with this.set('myAction', function(val) { ... });

      await render(hbs`<Types::Blueprints::JsonEditor />`);

      assert.dom().hasText('');

      // Template block usage:
      await render(hbs`
      <Types::Blueprints::JsonEditor>
        template block text
      </Types::Blueprints::JsonEditor>
    `);

      assert.dom().hasText('template block text');
    });
  },
);
