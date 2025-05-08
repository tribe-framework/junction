import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

export default class InputFieldsVisualGuide extends Component {
	@tracked colorPrimary=(this.args.object.colorPrimary?this.args.object.colorPrimary:"#000000");
	@tracked colorSecondary=(this.args.object.colorSecondary?this.args.object.colorSecondary:"#cccccc");
	@tracked colorSuccess=(this.args.object.colorSuccess?this.args.object.colorSuccess:"#00ff00");
	@tracked colorInfo=(this.args.object.colorInfo?this.args.object.colorInfo:"#0000ff");
	@tracked colorWarning=(this.args.object.colorWarning?this.args.object.colorWarning:"#ffff00");
	@tracked colorDanger=(this.args.object.colorDanger?this.args.object.colorDanger:"#ff0000");
	@tracked colorDark=(this.args.object.colorDark?this.args.object.colorDark:"#333333");
	@tracked colorLight=(this.args.object.colorLight?this.args.object.colorLight:"#eeeeee");
	@tracked isRounded=(this.args.object.isRounded?this.args.object.isRounded:false);
	@tracked importFontURL1=(this.args.object.importFontURL1?this.args.object.importFontURL1:"https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700&display=swap");
	@tracked importFontURL2=(this.args.object.importFontURL2?this.args.object.importFontURL2:"");
	@tracked fontFamily1=(this.args.object.fontFamily1?this.args.object.fontFamily1:'"IBM Plex Mono", serif');
	@tracked fontFamily2=(this.args.object.fontFamily2?this.args.object.fontFamily2:'"IBM Plex Mono", serif');

	@action
	updateObject() {
		console.log('aaa');
		//this.args.mutObjectModuleValue(this.args.module.input_slug, files);
	}

	get scss() {
	    let font1 = '';
	    if (this.importFontURL1) {
	        font1 = `@import url('${this.importFontURL1}');`;
	    }

	    let font2 = '';
	    if (this.importFontURL2) {
	        font2 = `
@import url('${this.importFontURL2}');`;
	    }

	    return font1 + font2 + `

$font-family-sans-serif: '${this.fontFamily1}' !default;
$display-font-family: '${this.fontFamily2}' !default;

$primary: '${this.colorPrimary}' !default;
$secondary: '${this.colorSecondary}' !default;
$info: '${this.colorInfo}' !default;
$success: '${this.colorSuccess}' !default;
$warning: '${this.colorWarning}' !default;
$danger: '${this.colorDanger}' !default;
$light: '${this.colorDark}' !default;
$dark: '${this.colorLight}' !default;

$enable-rounded: '${this.isRounded}' !default;
$enable-negative-margins: true !default;
$enable-cssgrid: true !default;

$spacer: 1rem !default;
$spacers: (
  0: 0,
  1: $spacer * .25,
  2: $spacer * .5,
  3: $spacer,
  4: $spacer * 1.5,
  5: $spacer * 3,
  6: $spacer * 4.5,
  7: $spacer * 6,
  8: $spacer * 7.5,
  9: $spacer * 9,
  10: $spacer * 12,
) !default;

@import "node_modules/bootstrap/scss/bootstrap";
@import "node_modules/animate.css/animate";
	    `;
	}

}
