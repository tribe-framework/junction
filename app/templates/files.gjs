import pageTitle from 'ember-page-title/helpers/page-title';
import Header from '../components/header.gjs';
import { Input } from '@ember/component';
import onKey from 'ember-keyboard/modifiers/on-key';
import { on } from '@ember/modifier';
import XToggle from '../components/x-toggle.gjs';
import { fn } from '@ember/helper';
import Footer from '../components/footer.gjs';
<template>
  {{pageTitle "Files"}}

  <Header @webapp={{@controller.types.json.modules.webapp}} />

  <div class="above-footer px-2">

    <main class="flex-shrink-0 page a4 d2 mb-5" style="min-height:75vh">

      <div class="container mx-auto px-2">
        <div
          class="py-3 px-3 mt-4 border border-1 border-dark text-center bg-body-tertiary rounded-0"
        >
          <h2 class="text-body-emphasis"><i
              class="fa-solid fa-magnifying-glass"
            ></i>
            <span>Search Inside Uploaded Files</span></h2>
          <div class="input-group mt-4">
            <Input
              @value={{@controller.query}}
              @type="text"
              class="form-control form-control-lg"
              placeholder="Type query (use re::phrase for complex search)"
              {{onKey "Enter" @controller.search}}
            />
            <button
              {{on "click" @controller.search}}
              type="button"
              class="btn btn-light btn-lg"
            ><i class="fa-solid fa-magnifying-glass"></i> Search</button>
          </div>
          <div
            class="mb-3 mt-3 d-flex align-items-center justify-content-between"
          >
            <div class="text-start">
              Use '##' as separater.
              <a
                href="https://github.com/tribe-framework/rephrase"
                target="new"
                class="fst-italic text-decoration-underline text-muted"
              >Learn more</a>
              about re::phrase.
            </div>
            <div class="d-flex align-content-center justify-content-end">
              <XToggle
                @theme="default"
                @size="small"
                @variant="light"
                @value={{@controller.deepSearch}}
                @onToggle={{fn (mut @controller.deepSearch)}}
              />
              <div class="text-end mx-2">Deep search (slower)</div>
            </div>
          </div>
        </div>
      </div>

      <div class="container mx-auto px-2">
        {{#if @controller.loading}}
          <div class="mx-auto my-5">
            <div
              class="spinner-grow text-{{@controller.colormodes.inverseMode}}"
              role="status"
            >
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
        {{else if @controller.results}}

          <table class="table mt-5">
            <thead>
              <tr>
                <th scope="col">{{@controller.getLength
                    @controller.results.by_file_name
                  }}
                  results with matching file name</th>
                <th scope="col">URL</th>
              </tr>
            </thead>
            <tbody>
              {{#each-in @controller.results.by_file_name as |name link|}}
                <tr>
                  <td>{{name}}</td>
                  <td><a
                      href="{{link}}"
                      target="new"
                      class="bt btn-sm btn-outline-primary"
                    >View
                      <i class="fa-solid fa-up-right-from-square"></i></a></td>
                </tr>
              {{/each-in}}
            </tbody>
          </table>

          <table class="table mt-5">
            <thead>
              <tr>
                <th scope="col">{{@controller.getLength
                    @controller.results.by_file_content
                  }}
                  results with matching file content</th>
                <th scope="col">URL</th>
              </tr>
            </thead>
            <tbody>
              {{#each-in @controller.results.by_file_content as |name link|}}
                <tr>
                  <td>{{name}}</td>
                  <td><a
                      href="{{link}}"
                      target="new"
                      class="bt btn-sm btn-outline-primary"
                    >View
                      <i class="fa-solid fa-up-right-from-square"></i></a></td>
                </tr>
              {{/each-in}}
            </tbody>
          </table>
        {{/if}}
      </div>

    </main>

  </div>

  <Footer @webapp={{@controller.types.json.modules.webapp}} />

  {{outlet}}
</template>
