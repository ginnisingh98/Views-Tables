--------------------------------------------------------
--  DDL for Package CSD_MIGRATE_FROM_115X_PKG6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIGRATE_FROM_115X_PKG6" AUTHID CURRENT_USER as
/* $Header: csdmig6s.pls 120.1 2005/08/09 17:23:40 swai noship $ */

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_TASKS_MIG6                                                 */
/* description   : procedure for migrating Task data                             */
/*                 from 11.5.10 to R12                                           */
/* purpose      :  Create Repair Task record in CSD_TASKS                        */
/*-------------------------------------------------------------------------------*/
  PROCEDURE csd_task_mig6(p_slab_number IN NUMBER DEFAULT 1);
  PROCEDURE csd_flex_flow_mig6;

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_RO_DIAGNOSTIC_CODES_MIG6                                  */
/* description   : procedure for migrating Repair Order Diagnostic Code data     */
/*                 from 11.5.10 to R12                                           */
/* purpose      :  Update Diagnostic Item ID in CSD_RO_DIAGNOSTIC_CODES          */
/*-------------------------------------------------------------------------------*/
  PROCEDURE csd_ro_diagnostic_codes_mig6;

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_RO_SERVICE_CODES_MIG6                                     */
/* description   : procedure for migrating Repair Order Service Code data        */
/*                 from 11.5.10 to R12                                           */
/* purpose      :  Update Service Item ID in CSD_RO_SERVICE_CODES                */
/*-------------------------------------------------------------------------------*/
  PROCEDURE csd_ro_service_codes_mig6;

END CSD_Migrate_From_115X_PKG6;
 

/
