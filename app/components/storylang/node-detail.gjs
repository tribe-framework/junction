import Component from '@glimmer/component';
import { action } from '@ember/object';
import { TYPE_COLOR, EDGE_COLOR } from './arc-diagram';

// ─── Component ──────────────────────────────────────────────────────────────
//
// Args:
//   @node       – { id, slug, type, data }
//   @edges      – edges already filtered to only those touching @node
//                 [{ source, target, kind }]
//   @allNodes   – full node list (used for navigate-on-click)
//   @onNavigate – (node) => void   navigate to a connected node
//   @onClose    – () => void       deselect / clear
//
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
export default class StorylangNodeDetailComponent extends Component {
  // ── Colour for the current node's type ───────────────────────────────────

  get typeColor() {
    return TYPE_COLOR[this.args.node?.type] ?? '#8895a7';
  }

  // ── Outgoing / incoming edge rows ─────────────────────────────────────────

  get outgoingEdges() {
    const slug = this.args.node?.slug;
    return (this.args.edges ?? [])
      .filter((e) => e.source === slug)
      .map((e) => ({
        slug: e.target,
        kind: e.kind,
        arrowColor: EDGE_COLOR[e.kind] ?? '#8895a7',
        direction: 'out',
      }));
  }

  get incomingEdges() {
    const slug = this.args.node?.slug;
    return (this.args.edges ?? [])
      .filter((e) => e.target === slug)
      .map((e) => ({
        slug: e.source,
        kind: e.kind,
        arrowColor: EDGE_COLOR[e.kind] ?? '#8895a7',
        direction: 'in',
      }));
  }

  get hasConnections() {
    return this.outgoingEdges.length > 0 || this.incomingEdges.length > 0;
  }

  // ── Data sections for the properties list ────────────────────────────────
  //
  // Each section: { title, items: [{ label, linked }] }

  get sections() {
    const d = this.args.node?.data;
    if (!d) return [];

    const toItems = (arr, linked = false) =>
      (arr ?? []).map((a) => ({
        label: typeof a === 'string' ? a : Object.keys(a)[0],
        linked,
      }));

    return [
      { title: 'Tracked Vars', items: toItems(d.tracked_vars) },
      { title: 'Inherited Args', items: toItems(d.inherited_args) },
      { title: 'Getters', items: toItems(d.getters) },
      { title: 'Actions', items: toItems(d.actions) },
      { title: 'Functions', items: toItems(d.functions) },
      { title: 'Services', items: toItems(d.services, true) },
      { title: 'Components', items: toItems(d.components, true) },
      { title: 'Modifiers', items: toItems(d.modifiers) },
    ].filter((s) => s.items.length > 0);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  @action
  navigateTo(slug) {
    const target = (this.args.allNodes ?? []).find((n) => n.slug === slug);
    if (target) this.args.onNavigate?.(target);
  }

  @action
  close() {
    this.args.onClose?.();
  }
  <template>
    {{! app/components/storylang/node-detail.hbs }}

    <style>
      /* ── NodeDetail component styles ── */

      .sl-nd-root {
        display: flex;
        flex-direction: column;
        height: 100%;
      }

      /* ── Sticky header ── */
      .sl-nd-head {
        padding: 18px 20px 14px;
        border-bottom: 1px solid #1e2530;
        position: sticky;
        top: 0;
        background: #0d1117;
        z-index: 2;
        display: flex;
        flex-direction: column;
        gap: 0;
      }

      .sl-nd-head-row {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 8px;
      }

      .sl-nd-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 2px 9px;
        border-radius: 99px;
        font-size: 0.68rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        margin-bottom: 8px;
        flex-shrink: 0;
      }

      .sl-nd-close {
        background: none;
        border: none;
        cursor: pointer;
        color: #3d4a58;
        padding: 2px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        flex-shrink: 0;
        margin-top: 1px;
        transition: color 0.12s;
      }

      .sl-nd-close:hover {
        color: #8895a7;
      }

      .sl-nd-slug {
        font-size: 0.88rem;
        font-weight: 600;
        color: #e8edf4;
        word-break: break-all;
        font-family: "Berkeley Mono", "Courier New", monospace;
        line-height: 1.4;
        flex: 1;
      }

      /* ── Body ── */
      .sl-nd-body {
        padding: 14px 20px;
        flex: 1;
        overflow-y: auto;
        scrollbar-width: thin;
        scrollbar-color: #1e2530 transparent;
      }

      .sl-nd-body::-webkit-scrollbar {
        width: 4px;
      }
      .sl-nd-body::-webkit-scrollbar-thumb {
        background: #1e2530;
        border-radius: 2px;
      }

      /* ── Sections ── */
      .sl-nd-section {
        margin-bottom: 18px;
      }

      .sl-nd-section-title {
        font-size: 0.65rem;
        font-weight: 600;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: #3d4a58;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 6px;
      }

      .sl-nd-section-title::after {
        content: "";
        flex: 1;
        height: 1px;
        background: #1e2530;
      }

      /* ── Tags ── */
      .sl-nd-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
      }

      .sl-nd-tag {
        padding: 2px 8px;
        border-radius: 5px;
        font-size: 0.68rem;
        font-weight: 500;
        background: #161b22;
        border: 1px solid #1e2530;
        color: #8895a7;
        font-family: "Berkeley Mono", "Courier New", monospace;
        line-height: 1.6;
      }

      .sl-nd-tag.linked {
        cursor: pointer;
        border-color: #2a3140;
        transition:
          border-color 0.12s,
          color 0.12s;
      }

      .sl-nd-tag.linked:hover {
        border-color: #4fc3f7;
        color: #4fc3f7;
      }

      /* ── Connection rows ── */
      .sl-nd-conn-row {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 5px;
      }

      .sl-nd-conn-arrow {
        font-size: 0.65rem;
        flex-shrink: 0;
        width: 12px;
        text-align: center;
      }

      .sl-nd-conn-kind {
        font-size: 0.65rem;
        color: #3d4a58;
        flex-shrink: 0;
        width: 56px;
      }

      .sl-nd-conn-slug {
        font-family: "Berkeley Mono", "Courier New", monospace;
        font-size: 0.68rem;
        cursor: pointer;
        padding: 1px 6px;
        border-radius: 4px;
        border: 1px solid #1e2530;
        background: #161b22;
        color: #8895a7;
        transition:
          border-color 0.12s,
          color 0.12s;
        word-break: break-all;
      }

      .sl-nd-conn-slug:hover {
        border-color: #4fc3f7;
        color: #4fc3f7;
      }
    </style>

    {{#if @node}}
      <div class="sl-nd-root">

        {{! ── Header ── }}
        <div class="sl-nd-head">

          <div class="sl-nd-head-row">
            <div>
              <div
                class="sl-nd-badge"
                style="background:{{this.typeColor}}22; color:{{this.typeColor}}; border:1px solid {{this.typeColor}}44;"
              >
                <svg width="6" height="6">
                  <circle cx="3" cy="3" r="3" fill={{this.typeColor}} />
                </svg>
                {{@node.type}}
              </div>
              <div class="sl-nd-slug">{{@node.slug}}</div>
            </div>

            <button
              class="sl-nd-close"
              type="button"
              {{on "click" this.close}}
              title="Deselect"
            >
              <svg
                width="14"
                height="14"
                viewBox="0 0 14 14"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M2 2l10 10M12 2L2 12" />
              </svg>
            </button>
          </div>

        </div>

        {{! ── Body ── }}
        <div class="sl-nd-body">

          {{! ── Connections ── }}
          {{#if this.hasConnections}}
            <div class="sl-nd-section">
              <div class="sl-nd-section-title">Connections</div>

              {{#each this.outgoingEdges as |edge|}}
                <div class="sl-nd-conn-row">
                  <span
                    class="sl-nd-conn-arrow"
                    style="color:{{edge.arrowColor}}"
                  >→</span>
                  <span class="sl-nd-conn-kind">{{edge.kind}}</span>
                  <span
                    class="sl-nd-conn-slug"
                    role="button"
                    {{on "click" (fn this.navigateTo edge.slug)}}
                  >{{edge.slug}}</span>
                </div>
              {{/each}}

              {{#each this.incomingEdges as |edge|}}
                <div class="sl-nd-conn-row">
                  <span
                    class="sl-nd-conn-arrow"
                    style="color:{{edge.arrowColor}}"
                  >←</span>
                  <span class="sl-nd-conn-kind">{{edge.kind}}</span>
                  <span
                    class="sl-nd-conn-slug"
                    role="button"
                    {{on "click" (fn this.navigateTo edge.slug)}}
                  >{{edge.slug}}</span>
                </div>
              {{/each}}
            </div>
          {{/if}}

          {{! ── Property sections ── }}
          {{#each this.sections as |section|}}
            <div class="sl-nd-section">
              <div class="sl-nd-section-title">{{section.title}}</div>
              <div class="sl-nd-tags">
                {{#each section.items as |item|}}
                  {{#if item.linked}}
                    <span
                      class="sl-nd-tag linked"
                      role="button"
                      {{on "click" (fn this.navigateTo item.label)}}
                    >{{item.label}}</span>
                  {{else}}
                    <span class="sl-nd-tag">{{item.label}}</span>
                  {{/if}}
                {{/each}}
              </div>
            </div>
          {{/each}}

        </div>

      </div>
    {{/if}}
  </template>
}
