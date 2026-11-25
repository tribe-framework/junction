import pageTitle from 'ember-page-title/helpers/page-title';
import Loading from '../components/loading.gjs';
import BasicDropdownWormhole from 'ember-basic-dropdown/components/basic-dropdown-wormhole';
import Webapp from '../components/types/webapp.gjs';
import NewModel from '../components/types/new-model.gjs';
import EditModel from '../components/types/edit-model.gjs';
import DeleteModel from '../components/types/delete-model.gjs';
import CsvImportExport from '../components/types/list-table/csv-import-export.gjs';
import BlueprintObjectModal from '../components/types/blueprint-object-modal.gjs';
import EditObjectModal from '../components/types/edit-object-modal.gjs';
import CopyObjectModal from '../components/types/copy-object-modal.gjs';
import Modal from '../components/types/modules/modal.gjs';
import TrackApiModal from '../components/types/track-api-modal.gjs';
import New from '../components/types/modules/new.gjs';
import Modal0 from '../components/types/public/modal.gjs';
import FindDuplicates from '../components/types/list-table/find-duplicates.gjs';
import VersionUpgradesModal from '../components/version-upgrades/modal.gjs';
<template>
  {{pageTitle "Junction"}}

  <Loading />

  {{outlet}}

  <BasicDropdownWormhole />
  <Webapp />
  <NewModel />
  <EditModel />
  <DeleteModel />
  <CsvImportExport />
  <BlueprintObjectModal />
  <EditObjectModal />
  <CopyObjectModal />
  <Modal />
  <TrackApiModal />
  <New />
  <Modal0 />
  <FindDuplicates />
  <VersionUpgradesModal />
</template>
