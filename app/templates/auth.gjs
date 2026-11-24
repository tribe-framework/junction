import pageTitle from 'ember-page-title/helpers/page-title';
import Full from '../components/logo/full.gjs';
import { Input } from '@ember/component';
import { on } from '@ember/modifier';
<template>
  {{pageTitle "Auth"}}

  <main class="vh-100 w-100 d-flex align-items-center justify-content-center">
    <div class="col-10 col-md-7 col-lg-4 col-xxl-3 text-center">
      <Full @color="var(--bs-primary)" @width="360" />

      <div class="form-floating my-5">
        <Input
          @type="password"
          @value={{@controller.auth.inputPassword}}
          class="form-control border-dark border border-1"
          id="floatingPassword"
          placeholder="Password"
          @enter={{@controller.clickSubmitButton}}
        />
        <label for="floatingPassword">Password</label>
      </div>

      <button
        id="auth-submit-password-btn"
        class="w-100 btn btn-lg btn-outline-primary"
        {{on "click" @controller.auth.submitPassword}}
        type="button"
      >Sign in</button>
    </div>
  </main>

  {{outlet}}
</template>
