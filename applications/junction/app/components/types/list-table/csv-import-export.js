import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import Papa from 'papaparse';

export default class TypesListTableCsvImportExport extends Component {
  @service colormodes;
  @service object;
  @service type;
  @service types;
  @service store;
  @service gzip;

  @action
  async updateOnUpload(e) {
    this.type.loadingSearchResults = true;

    var donotomit = [];
    this.type.currentType.modules.forEach((m, i) => {
      if (
        m.var_type === undefined ||
        (m.var_type != 'json' && m.var_type != 'array')
      ) {
        donotomit.push(donotomit.input_slug);
      }
    });

    this.type.csvURL = e.url;

    try {
      const response = await fetch('/template_2025-02-18_1739887251.csv');
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const csvText = await response.text();
      
      let d = await this.gzip.compressAndEncode(csvText);
      console.log(d);

      let ud = await this.gzip.decodeAndDecompress(d);
      console.log(ud);


      // Stream big file in worker thread
      Papa.parse(csvText, {
        worker: true,
        step: (results) => {
          console.log('Row:', results.data);
        },
      });
    } catch (error) {
      console.error('Error fetching the CSV file:', error);
    }

    this.type.loadingSearchResults = false;
  }

  @action
  papaUnparseFormat() {
    this.type.loadingSearchResults = true;

    var mmm = [];
    mmm.push('id');
    this.type.currentType.modules.forEach((m) => {
      if (
        m.var_type === undefined ||
        (m.var_type != 'json' && m.var_type != 'array')
      ) {
        mmm.push(m.input_slug);
      }
    });

    var vvv = [];
    vvv.push(mmm);

    let papa = Papa.unparse(vvv);

    let dd = new Date();

    var hiddenElement = document.createElement('a');
    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(papa);
    hiddenElement.target = '_blank';

    //provide the name for the CSV file to be downloaded
    hiddenElement.download =
      'format_' +
      this.type.currentType.slug +
      '_' +
      dd.toISOString().split('T')[0] +
      '_' +
      Math.floor(dd / 1000) +
      '.csv';
    hiddenElement.click();
    this.type.loadingSearchResults = false;
  }

  @action
  async papaUnparse() {
    this.type.loadingSearchResults = true;
    let data = await this.store.query(this.type.currentType.slug, {
      sort: '-id',
      show_public_objects_only: false,
      page: { limit: -1, offset: 0 },
    });

    var mmm = [];
    mmm.push('id');
    mmm.push('type');
    mmm.push('slug');
    mmm.push('created_on');
    mmm.push('updated_on');
    this.type.currentType.modules.forEach((m) => {
      mmm.push(m.input_slug);
    });

    var vvv = [];
    vvv.push(mmm);

    var nnn = [];
    var jjj = [];
    data.forEach((obj) => {
      nnn = [];
      mmm.forEach((m) => {
        if (obj.modules[m] !== undefined) {
          if (typeof obj.modules[m] == 'object') {
            if (obj.modules[m].blocks !== undefined) {
              var jjj = [];
              obj.modules[m].blocks.forEach((o) => {
                jjj.push(o.data.text.replace(/<\/?[^>]+(>|$)/g, ''));
              });
              nnn.push(jjj.join('\n'));
            } else {
              nnn.push(JSON.stringify(obj.modules[m]));
            }
          } else if (typeof obj.modules[m] == 'array') {
            nnn.push(JSON.stringify(obj.modules[m]));
          } else nnn.push(obj.modules[m]);
        } else nnn.push('');
      });
      vvv.push(nnn);
    });
    let papa = Papa.unparse(vvv);

    let dd = new Date();

    var hiddenElement = document.createElement('a');
    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(papa);
    hiddenElement.target = '_blank';

    //provide the name for the CSV file to be downloaded
    hiddenElement.download =
      this.type.currentType.slug +
      '_' +
      dd.toISOString().split('T')[0] +
      '_' +
      Math.floor(dd / 1000) +
      '.csv';
    hiddenElement.click();
    this.type.loadingSearchResults = false;
  }
}
