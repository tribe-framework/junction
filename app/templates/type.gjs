import pageTitle from 'ember-page-title/helpers/page-title';
import Header from '../components/header.gjs';
import PageSummaryCard from '../components/page-summary-card.gjs';
import eq from 'ember-truth-helpers/helpers/eq';
import Uploader from '../components/files/uploader.gjs';
import AuthReference from '../components/api/auth-reference.gjs';
import lte from 'ember-truth-helpers/helpers/lte';
import onClickOutside from 'ember-click-outside/modifiers/on-click-outside';
import not from 'ember-truth-helpers/helpers/not';
import or from 'ember-truth-helpers/helpers/or';
import { on } from '@ember/modifier';
import TitleBar from '../components/types/list-table/title-bar.gjs';
import List from '../components/types/modules/list.gjs';
import Pagination from '../components/types/list-table/pagination.gjs';
import { get } from '@ember/helper';
import ListTable from '../components/types/list-table.gjs';
import Head from '../components/types/list-table/head.gjs';
import notEq from 'ember-truth-helpers/helpers/not-eq';
import Row from '../components/types/list-table/row.gjs';
import LoadingTableRow from '../components/types/list-table/loading-table-row.gjs';
import EmptyTableRow from '../components/types/list-table/empty-table-row.gjs';
import GoToTop from '../components/go-to-top.gjs';
import Footer from '../components/footer.gjs';
<template>
  {{pageTitle "Type"}}

  <Header @webapp={{@controller.type.types.json.modules.webapp}} />

  <div class="above-footer px-2">
    <main class="flex-shrink-0 page a4 d2 mb-5">
      <div class="container-xxl mx-auto px-0">
        <PageSummaryCard />

        {{#if (eq @controller.type.currentType.slug "file_record")}}
          <Uploader />
        {{/if}}

        {{#if (eq @controller.type.currentType.slug "apikey_record")}}
          <AuthReference />
        {{/if}}
      </div>

      {{#if @controller.type.currentType}}
        <div
          {{onClickOutside @controller.stopWobble}}
          class="mt-5 position-relative min-vh-100 row pb-5 overflow-x-hidden mb-5 border border-1 border-{{@controller.colormodes.inverseMode}}
            {{if
              (lte @controller.type.modulesThatWillBeListed.length 5)
              'container-xxl mx-auto'
              'mx-0'
            }}"
        >
          {{#if
            (not
              (or
                (eq @controller.type.currentType.slug "deleted_record")
                (eq @controller.type.currentType.slug "file_record")
              )
            )
          }}
            <div class="position-absolute top-0 text-end end-0 p-0 m-0">
              {{#if @controller.activateReordering}}
                <div class="btn-group" role="group"><button
                    id="track-new"
                    type="button"
                    {{on "click" @controller.stopWobble}}
                    class="text-capitalize btn-lg fw-normal border-0 btn"
                  ><i class="fa-solid fa-lock-open"></i></button></div>
              {{else}}
                <div class="btn-group" role="group"><button
                    id="track-new"
                    type="button"
                    {{on "click" @controller.startWobble}}
                    class="text-capitalize btn-lg fw-normal border-0 btn"
                  ><i class="fa-solid fa-lock"></i></button></div>
              {{/if}}
            </div>
          {{/if}}

          <div class="col px-0">
            <TitleBar
              @type={{@controller.type.currentType}}
              @search={{@controller.type.search}}
              @clearSearch={{@controller.type.clearSearch}}
              @updatePageLength={{@controller.type.updatePageLength}}
              @currentPageLength={{@controller.type.currentPageLength}}
              @selectedRowIDs={{@controller.type.selectedRowIDs}}
              @advancedSearch={{@controller.type.advancedSearch}}
              @showClearSearchButton={{@controller.type.showClearSearchButton}}
              @searchQuery={{@controller.type.searchQuery}}
              @advancedSearchQuery={{@controller.type.advancedSearchQuery}}
              @clearSearchQuery={{@controller.type.clearSearchQuery}}
              @changePageNumber={{@controller.type.changePageNumber}}
            />

            <List
              @activateReordering={{@controller.activateReordering}}
              @stopWobble={{@controller.stopWobble}}
            />

            <Pagination
              @type={{get
                @controller.type.types.json.modules
                @controller.type.currentType.slug
              }}
              @numberOfPages={{get
                @controller.type.currentNumberOfPages
                @controller.type.currentType.slug
              }}
              @pageLinks={{@controller.type.pageLinks}}
              @selectedRowIDs={{@controller.type.selectedRowIDs}}
              @changePageNumber={{@controller.type.changePageNumber}}
              @currentPageNumber={{@controller.type.currentPageNumber}}
              @totalObjects={{@controller.type.totalObjects}}
            />

            <ListTable
              @webapp={{@controller.type.types.json}}
              @type={{@controller.type.currentType}}
              @loadTypeObjects={{@controller.type.loadTypeObjects}}
              @selectedRowIDs={{@controller.type.selectedRowIDs}}
              @emptySelectedRowsInType={{@controller.type.emptySelectedRowsInType}}
            >

              <Head
                @updateSortField={{@controller.type.updateSortField}}
                @sortField={{@controller.type.sortField}}
                @type={{@controller.type.currentType}}
                @sortOrder={{@controller.type.sortOrder}}
              />

              <tbody>
                {{#each @controller.type.objectsInType as |object|}}
                  {{#if (notEq object.id "0")}}
                    <Row
                      @webapp={{@controller.type.types.json}}
                      @type={{@controller.type.currentType}}
                      @object={{object}}
                      @loadTypeObjects={{@controller.type.loadTypeObjects}}
                      @selectedRowIDs={{@controller.type.selectedRowIDs}}
                      @addToSelectedRowIDs={{@controller.type.addToSelectedRowIDs}}
                      @removeFromSelectedRowIDs={{@controller.type.removeFromSelectedRowIDs}}
                      @emptySelectedRowsInType={{@controller.type.emptySelectedRowsInType}}
                    />
                  {{else}}
                    {{#if @controller.type.loadingSearchResults}}
                      <LoadingTableRow @type={{@controller.type.currentType}} />
                    {{else}}
                      <EmptyTableRow @type={{@controller.type.currentType}} />
                    {{/if}}
                  {{/if}}
                {{else}}
                  {{#if @controller.type.loadingSearchResults}}
                    <LoadingTableRow @type={{@controller.type.currentType}} />
                  {{else}}
                    <EmptyTableRow @type={{@controller.type.currentType}} />
                  {{/if}}
                {{/each}}
              </tbody>

            </ListTable>
          </div>
        </div>
      {{/if}}

      <GoToTop />

    </main>

  </div>

  <Footer @webapp={{@controller.type.types.json.modules.webapp}} />

  {{outlet}}
</template>
