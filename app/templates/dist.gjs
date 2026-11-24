import pageTitle from 'ember-page-title/helpers/page-title';
import Header from '../components/header.gjs';
import PageSummaryCard from '../components/page-summary-card.gjs';
import Dist from '../components/files/dist.gjs';
import Footer from '../components/footer.gjs';
<template>
  {{pageTitle "Dist"}}

  <Header @webapp={{@model.modules.webapp}} />

  <div class="above-footer px-2">

    <main class="flex-shrink-0 page a4 d2 mb-5" style="min-height:75vh">

      <div class="container-xxl px-0 mx-auto">
        <PageSummaryCard />

        <div class="col-lg-8 mx-auto">
          <Dist />
        </div>
      </div>

    </main>

  </div>

  <Footer @webapp={{@model.modules.webapp}} />
  {{outlet}}
</template>
