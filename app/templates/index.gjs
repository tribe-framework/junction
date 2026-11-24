import pageTitle from 'ember-page-title/helpers/page-title';
import Header from '../components/header.gjs';
import PageSummaryCard from '../components/page-summary-card.gjs';
import Footer from '../components/footer.gjs';
<template>
  {{pageTitle "Dashboard"}}

  <Header @webapp={{@model.modules.webapp}} />

  <div class="above-footer px-2">

    <main class="flex-shrink-0 page a4 d2 mb-5" style="min-height:75vh">

      <div class="container-xxl px-0 mx-auto">

        <PageSummaryCard />

        {{#if @controller.plausibleEmbedUrl}}
          <div class="col px-0 border border-1 border-primary mt-5">
            <iframe
              plausible-embed
              src={{@controller.plausibleEmbedUrl}}
              scrolling="yes"
              frameborder="0"
              loading="lazy"
              style="width: 1px; min-width: 100%; min-height: 1600px;"
            ></iframe>
          </div>
        {{/if}}

      </div>

    </main>

  </div>

  <Footer @webapp={{@model.modules.webapp}} />
  {{outlet}}
</template>
