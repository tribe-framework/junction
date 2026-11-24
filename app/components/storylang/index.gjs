import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { TYPE_COLOR } from './arc-diagram';

// Canonical display order for node types
import ArcDiagram from './arc-diagram.gjs';
import NodeDetail from './node-detail.gjs';
import didInsert from '../../modifiers/did-insert.js';
const TYPE_ORDER = [
  'route',
  'service',
  'type',
  'helper',
  'modifier',
  'component',
];

export default class StorylangIndexComponent extends Component {
  @tracked selectedNode = null;
  @tracked model = null;
  @tracked isLoading = true;
  @tracked isEmpty = false;

  @action
  async loadModel() {
    try {
      const response = await fetch('/storylang.json');

      if (!response.ok) {
        this.isEmpty = true;
        return;
      }

      let data;
      try {
        data = await response.json();
      } catch {
        this.isEmpty = true;
        return;
      }

      // Treat missing or fully-empty data as the welcome state
      const hasContent =
        data &&
        [
          'routes',
          'services',
          'types',
          'helpers',
          'modifiers',
          'components',
        ].some((key) => Array.isArray(data[key]) && data[key].length > 0);

      if (hasContent) {
        this.model = data;
      } else {
        this.isEmpty = true;
      }
    } catch {
      this.isEmpty = true;
    } finally {
      this.isLoading = false;
    }
  }

  // ── Legend ────────────────────────────────────────────────────────────────

  get legendItems() {
    return TYPE_ORDER.map((t) => ({
      type: t,
      label: t + 's',
      color: TYPE_COLOR[t] ?? '#8895a7',
    }));
  }

  // ── Nodes ─────────────────────────────────────────────────────────────────

  get allNodes() {
    const model = this.model;
    if (!model) return [];

    const nodes = [];

    const addNodes = (items, type) => {
      if (!items) return;
      items.forEach((item) => {
        nodes.push({
          id: `${type}:${item.slug}`,
          slug: item.slug,
          type,
          data: item,
        });
      });
    };

    addNodes(model.routes, 'route');
    addNodes(model.services, 'service');
    addNodes(model.types, 'type');
    addNodes(model.helpers, 'helper');
    addNodes(model.modifiers, 'modifier');
    addNodes(model.components, 'component');

    return nodes;
  }

  get filteredNodes() {
    return this.allNodes;
  }

  // ── Edges ─────────────────────────────────────────────────────────────────

  get allEdges() {
    const nodes = this.allNodes;
    const nodeIndex = {};
    nodes.forEach((n, i) => {
      nodeIndex[n.slug] = i;
    });

    const edges = [];
    const model = this.model;

    const addEdges = (item, itemType) => {
      const sourceSlug = item.slug;

      if (item.services) {
        item.services.forEach((svc) => {
          edges.push({
            source: sourceSlug,
            target: svc,
            kind: 'service',
            sourceType: itemType,
          });
        });
      }

      if (item.components) {
        item.components.forEach((comp) => {
          edges.push({
            source: sourceSlug,
            target: comp,
            kind: 'component',
            sourceType: itemType,
          });
        });
      }
    };

    (model?.components || []).forEach((c) => addEdges(c, 'component'));
    (model?.routes || []).forEach((r) => addEdges(r, 'route'));
    (model?.services || []).forEach((s) => addEdges(s, 'service'));

    return edges;
  }

  get selectedNodeEdges() {
    if (!this.selectedNode) return [];
    return this.allEdges.filter(
      (e) =>
        e.source === this.selectedNode.slug ||
        e.target === this.selectedNode.slug,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  @action
  selectNode(node) {
    if (this.selectedNode?.id === node.id) {
      this.selectedNode = null;
    } else {
      this.selectedNode = node;
    }
  }

  @action
  clearSelection() {
    this.selectedNode = null;
  }
  <template>
    <style>
      /* ── Storylang Visualizer Styles ── */
      .sl-root {
        font-family: "Inter", "Segoe UI", system-ui, sans-serif;
        background: #0d1117;
        height: 100vh;
        color: #e6edf3;
        display: flex;
        flex-direction: column;
        overflow: hidden;
      }

      .sl-header {
        padding: 28px 40px 20px;
        border-bottom: 1px solid #21262d;
        display: flex;
        align-items: center;
        gap: 20px;
        flex-wrap: wrap;
        flex-shrink: 0;
        position: sticky;
        top: 0;
        z-index: 10;
        background: #0d1117;
      }

      .sl-header h1 {
        font-size: 1.25rem;
        font-weight: 600;
        letter-spacing: -0.01em;
        color: #f0f6fc;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
      }

      .sl-header h1 svg {
        opacity: 0.7;
      }

      .sl-legend {
        display: flex;
        gap: 14px;
        flex-wrap: wrap;
        margin-left: auto;
        align-items: center;
      }

      .sl-legend-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.72rem;
        font-weight: 500;
        color: #8b949e;
        letter-spacing: 0.03em;
        text-transform: capitalize;
      }

      .sl-legend-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        flex-shrink: 0;
      }

      .sl-body {
        display: flex;
        flex: 1;
        overflow-y: auto;
        overflow-x: hidden;
        align-items: flex-start;
      }

      /* ── Arc Diagram ── */
      .sl-diagram-wrap {
        flex: 1;
        overflow: visible;
        padding: 30px 0;
      }

      .sl-svg-container {
        display: flex;
        justify-content: center;
      }

      /* ── Node dots & labels ── */
      .sl-node-group {
        cursor: pointer;
      }

      .sl-node-group:hover .sl-node-dot {
        filter: brightness(1.3);
      }

      .sl-node-dot {
        transition:
          r 0.15s ease,
          filter 0.15s ease;
      }

      .sl-node-label {
        font-size: 11.5px;
        fill: #8b949e;
        transition: fill 0.15s ease;
        dominant-baseline: middle;
        font-family: "Inter", "Segoe UI", system-ui, sans-serif;
      }

      .sl-node-group.active .sl-node-label,
      .sl-node-group:hover .sl-node-label {
        fill: #e6edf3;
      }

      .sl-node-group.active .sl-node-dot {
        filter: brightness(1.4) drop-shadow(0 0 6px currentColor);
      }

      .sl-node-group.dimmed .sl-node-dot {
        opacity: 0.2;
      }

      .sl-node-group.dimmed .sl-node-label {
        opacity: 0.2;
      }

      /* ── Arcs ── */
      .sl-arc {
        fill: none;
        transition:
          opacity 0.2s ease,
          stroke-width 0.2s ease;
      }

      .sl-arc.dimmed {
        opacity: 0.03;
      }

      .sl-arc.highlighted {
        opacity: 0.85;
        stroke-width: 1.8px;
      }

      .sl-arc.default {
        opacity: 0.18;
        stroke-width: 1px;
      }

      /* ── Type badge on axis ── */
      .sl-type-label {
        font-size: 9px;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        fill: #30363d;
        font-family: "Inter", "Segoe UI", system-ui, sans-serif;
      }

      /* ── Detail Panel ── */
      .sl-panel {
        width: 300px;
        min-width: 300px;
        border-left: 1px solid #21262d;
        background: #0d1117;
        overflow-y: auto;
        padding: 0;
        scrollbar-width: thin;
        scrollbar-color: #21262d transparent;
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        max-height: 100vh;
        align-self: flex-start;
      }

      .sl-panel::-webkit-scrollbar {
        width: 6px;
      }

      .sl-panel::-webkit-scrollbar-thumb {
        background: #21262d;
        border-radius: 3px;
      }

      .sl-panel-empty {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
        gap: 10px;
        color: #30363d;
        padding: 40px;
        text-align: center;
      }

      .sl-panel-empty svg {
        opacity: 0.3;
        margin-bottom: 4px;
      }

      .sl-panel-empty p {
        font-size: 0.82rem;
        line-height: 1.5;
        margin: 0;
      }

      .sl-panel-header {
        padding: 20px 22px 14px;
        border-bottom: 1px solid #21262d;
        position: sticky;
        top: 0;
        background: #0d1117;
        z-index: 1;
      }

      .sl-panel-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 2px 9px;
        border-radius: 12px;
        font-size: 0.7rem;
        font-weight: 600;
        letter-spacing: 0.05em;
        text-transform: uppercase;
        margin-bottom: 8px;
      }

      .sl-panel-title {
        font-size: 0.95rem;
        font-weight: 600;
        color: #f0f6fc;
        word-break: break-all;
        margin: 0;
      }

      .sl-panel-body {
        padding: 16px 22px;
        flex: 1;
      }

      .sl-section {
        margin-bottom: 20px;
      }

      .sl-section-title {
        font-size: 0.68rem;
        font-weight: 600;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: #484f58;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 6px;
      }

      .sl-section-title::after {
        content: "";
        flex: 1;
        height: 1px;
        background: #21262d;
      }

      .sl-tag-list {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
      }

      .sl-tag {
        padding: 2px 8px;
        border-radius: 6px;
        font-size: 0.72rem;
        font-weight: 500;
        background: #161b22;
        border: 1px solid #21262d;
        color: #8b949e;
        font-family: "ui-monospace", "SFMono-Regular", monospace;
      }

      .sl-tag.linked {
        cursor: pointer;
        border-color: #30363d;
      }

      .sl-tag.linked:hover {
        border-color: #58a6ff;
        color: #58a6ff;
      }

      /* ── Connection count ── */
      .sl-connection-count {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 0;
        font-size: 0.8rem;
        color: #8b949e;
        border-bottom: 1px solid #21262d;
        margin-bottom: 14px;
      }

      .sl-conn-badge {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 0.72rem;
        font-weight: 600;
      }

      /* ── Welcome / empty state ── */
      .sl-welcome {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;
        gap: 16px;
        text-align: center;
        padding: 40px;
      }

      .sl-welcome-logo {
        width: 80px;
        height: 80px;
        margin-bottom: 8px;
        opacity: 0.85;
      }

      .sl-welcome-title {
        font-size: 1.6rem;
        font-weight: 700;
        color: #f0f6fc;
        margin: 0;
        letter-spacing: -0.02em;
      }

      .sl-welcome-sub {
        font-size: 0.9rem;
        color: #8b949e;
        margin: 0;
      }

      .sl-welcome-hint {
        font-size: 0.85rem;
        color: #484f58;
        margin: 0;
      }

      .sl-welcome-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        margin-top: 8px;
        padding: 9px 22px;
        border-radius: 8px;
        background: #a78bfa;
        color: #0d1117;
        font-size: 0.875rem;
        font-weight: 600;
        text-decoration: none;
        transition:
          background 0.15s ease,
          transform 0.1s ease;
      }

      .sl-welcome-btn:hover {
        background: #c4b5fd;
        transform: translateY(-1px);
      }
    </style>

    {{#if this.isEmpty}}

      {{! ── Welcome / empty state ── }}
      <div
        class="bg-white vh-100 w-100 d-flex align-items-center justify-content-center flex-column"
      >
        <h1 class="display-6">Welcome to Tribe</h1>
        <p class="lead">You have successfully installed
          <strong>ember-tribe</strong></p>
        <a
          href="https://tribe-framework.org"
          class="btn btn-success"
          target="_blank"
          rel="noopener noreferrer"
        >
          Read more
        </a>
      </div>

    {{else}}
      <div class="sl-root">

        {{! ── Header ── }}
        <header class="sl-header">
          <h1>
            Storylang
          </h1>

          <div class="sl-legend">
            {{#each this.legendItems as |item|}}
              <div class="sl-legend-item">
                <span
                  class="sl-legend-dot"
                  style="background:{{item.color}}"
                ></span>
                {{item.label}}
              </div>
            {{/each}}
          </div>
        </header>

        <div class="sl-body">

          {{! ── Arc Diagram ── }}
          <div class="sl-diagram-wrap">
            <div class="sl-svg-container">
              <ArcDiagram
                @nodes={{this.filteredNodes}}
                @edges={{this.allEdges}}
                @selectedNode={{this.selectedNode}}
                @onSelectNode={{this.selectNode}}
              />
            </div>
          </div>

          {{! ── Detail Panel ── }}
          <aside class="sl-panel">
            {{#if this.selectedNode}}
              <NodeDetail
                @node={{this.selectedNode}}
                @edges={{this.selectedNodeEdges}}
                @onClose={{this.clearSelection}}
                @onNavigate={{this.selectNode}}
                @allNodes={{this.allNodes}}
              />
            {{else}}
              <div class="sl-panel-empty">
                <p>Click any node on the diagram to inspect its connections and
                  properties.</p>
              </div>
            {{/if}}
          </aside>

        </div>
      </div>

    {{/if}}

    <div {{didInsert this.loadModel}}></div>
  </template>
}
