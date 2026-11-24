import pageTitle from 'ember-page-title/helpers/page-title';
import didInsert from '../modifiers/did-insert.js';
import Header from '../components/header.gjs';
import { on } from '@ember/modifier';
import Arrows from '../components/logo/arrows.gjs';
import Wordmark from '../components/logo/wordmark.gjs';
<template>
  {{pageTitle "Public"}}

  <div class="d-none" {{didInsert @controller.initType}}></div>

  {{#if @controller.type.currentType.public_form.is_live}}

    <Header @webapp={{@model.modules.webapp}} @public={{true}} />

    <div class="above-footer px-2">

      <main class="flex-shrink-0 page a4 d2" style="min-height:75vh">

        <div class="container mx-auto text-center my-5">

          {{#if @controller.type.currentType.public_form.cover_url}}
            <img
              src="{{@controller.type.currentType.public_form.cover_url}}"
              class="img-fluid mx-auto rounded-5"
            />
          {{/if}}

          {{#if @controller.object.currentObject.id}}

            <div
              class="col-lg-6 mx-auto p-5 my-5 text-center text-muted bg-body border border-dashed rounded-5 bg-success"
            >
              <div class="text-center mb-3"><i
                  class="fa-solid fa-circle-check fa-5x text-success"
                ></i></div>
              <p class="fs-5 display-6">
                {{@controller.type.currentType.public_form.thankyou_text}}
              </p>
            </div>

          {{else}}

            {{#if @controller.type.currentType.public_form.title}}
              <h1
                class="my-5 text-primary"
              >{{@controller.type.currentType.public_form.title}}</h1>
            {{/if}}

            {{#if @controller.type.currentType.public_form.description}}
              <p
                class="col-lg-6 mx-auto fs-5 display-6"
              >{{@controller.type.currentType.public_form.description}}</p>
            {{/if}}

            {{#unless @controller.type.currentType.readonly}}
              {{#if @controller.type.currentType.public_form.button_text}}
                <div
                  class="d-flex align-items-center justify-content-center my-5"
                >
                  <button
                    {{on "click" @controller.openNewModal}}
                    type="button"
                    style="letter-spacing:1.4px"
                    class="text-uppercase fw-bolder btn btn-primary btn-lg"
                  >{{@controller.type.currentType.public_form.button_text}}
                    <Arrows @width="42" @color="#000" /></button>
                </div>
              {{else}}
                <div
                  class="d-flex align-items-center justify-content-center my-5"
                >
                  <button
                    {{on "click" @controller.openNewModal}}
                    type="button"
                    style="letter-spacing:1.4px"
                    class="text-uppercase fw-bolder btn btn-primary btn-lg"
                  >New
                    {{@controller.type.currentType.name}}
                    <Arrows @width="42" @color="#000" /></button>
                </div>
              {{/if}}
            {{/unless}}

          {{/if}}

          <div class="my-5">
            <div class="col-lg-5 mx-auto mt-5 py-5 text-center">
              <img
                src="https://junction.express/assets/img/auth.png"
                class="img-fluid"
                width="180"
              />
            </div>
            <a
              href="https://junction.express"
              target="new"
              class="col-3 col-md-2 col-lg-1 d-block mx-auto text-center text-decoration-none"
            >
              <div
                class="smaller text-uppercase text-{{@controller.colormodes.inverseMode}}"
                style="font-size:0.64em"
              >Powered by</div>
              <Wordmark @color="var(--bs-primary)" />
            </a>
          </div>

        </div>

      </main>

    </div>

  {{/if}}

  {{outlet}}
</template>
