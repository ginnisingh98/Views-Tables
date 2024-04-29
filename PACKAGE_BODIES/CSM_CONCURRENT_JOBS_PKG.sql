--------------------------------------------------------
--  DDL for Package Body CSM_CONCURRENT_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CONCURRENT_JOBS_PKG" AS
/* $Header: csmconcb.pls 120.1 2005/07/22 02:41:57 trajasek noship $ */


--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

PROCEDURE refresh_all_acc( x_retcode OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);
l_status  VARCHAR2(2000);
l_message VARCHAR2(2000);

BEGIN

  -- Do not run if the Palm application is not enabled
  IF NOT csm_util_pkg.is_field_service_palm_enabled THEN
    csm_util_pkg.log('Attempt made to start Concurrent Program while Field Service Palm Application Disabled'
                     ,'CSM_CONCURRENT_JOBS_PKG.refresh_all_acc',FND_LOG.LEVEL_PROCEDURE );
    RETURN;
  END IF;

  x_retcode := 0;
  -- refresh all acc tables

  csm_bus_process_txns_event_pkg.refresh_acc(l_status, l_message);

  csm_currency_event_pkg.refresh_acc(l_status, l_message);

  csm_lookup_event_pkg.refresh_acc(l_status, l_message);

  csm_messages_event_pkg.refresh_acc(l_status, l_message);

  csm_profile_event_pkg.refresh_acc(l_status, l_message);

  csm_state_transition_event_pkg.refresh_acc(l_status, l_message);

  csm_system_item_event_pkg.refresh_acc(l_status, l_message);

  csm_txn_bill_types_event_pkg.refresh_acc(l_status, l_message);

  csm_system_item_event_pkg.refresh_mtl_onhand_quantity(l_status, l_message);

  csm_uom_event_pkg.refresh_acc(l_status, l_message);

  csm_probcode_mapping_event_pkg.refresh_probcode_mapping_acc(l_status, l_message);

  csm_util_pkg.refresh_all_app_level_acc(l_status, l_message);

  csm_mtl_sec_inv_event_pkg.refresh_acc(l_status, l_message);

  csm_mtl_item_subinv_event_pkg.refresh_acc(l_status, l_message);

  csm_mtl_item_loc_event_pkg.refresh_acc(l_status, l_message);

  csm_mtl_sec_locators_event_pkg.refresh_acc(l_status, l_message);

  csm_mtl_parameters_event_pkg.refresh_acc(l_status, l_message);

  csm_csi_item_attr_event_pkg.refresh_acc(l_status, l_message);

  csm_lobs_event_pkg.conc_download_attachments(l_status, l_message);

  csm_notes_event_pkg.object_mappings_acc_processor;

EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     x_retcode := 2;
     fnd_file.put_line(fnd_file.log, 'CSM_CONCURRENT_JOBS_PKG.REFRESH_ALL_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
     csm_util_pkg.log(l_sqlerrmsg,'CSM_CONCURRENT_JOBS_PKG.REFRESH_ALL_ACC',FND_LOG.LEVEL_EXCEPTION);
END refresh_all_acc;

END CSM_CONCURRENT_JOBS_PKG;

/
