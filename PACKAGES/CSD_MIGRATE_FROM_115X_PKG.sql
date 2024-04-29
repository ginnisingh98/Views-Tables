--------------------------------------------------------
--  DDL for Package CSD_MIGRATE_FROM_115X_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIGRATE_FROM_115X_PKG" AUTHID CURRENT_USER as
/* $Header: csdmig1s.pls 115.4 2002/09/28 01:29:00 vlakaman noship $ */

/*--------------------------------------------------*/
/* procedure name: csd_product_txn_lines_pkg        */
/* description   : procedure for migrating product  */
/*                 txn lines                        */
/*--------------------------------------------------*/

procedure csd_product_txn_lines_mig(p_slab_number IN NUMBER DEFAULT 1);

/*--------------------------------------------------*/
/* procedure name: csd_repairs_pkg                  */
/* description   : procedure for migrating repair   */
/*                 lines                            */
/*--------------------------------------------------*/

procedure csd_repairs_mig(p_slab_number IN NUMBER DEFAULT 1);


/*--------------------------------------------------*/
/* procedure name: Migrate_From_115X                */
/* description   : procedure for migrating Depot    */
/*                 CSD_REPAIR_ESTIMATE table        */
/*                 data from 11.5.7 to 11.5.8       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE CSD_REPAIR_ESTIMATE_MIG (p_slab_number IN NUMBER DEFAULT 1);

/*--------------------------------------------------*/
/* procedure name: Migrate_From_115X                */
/* description   : procedure for migrating Depot    */
/*                 CSD_REPAIR_ESTIMATE_LINES table  */
/*                 data from 11.5.7 to 11.5.8       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE CSD_REPAIR_ESTIMATE_LINES_MIG (p_slab_number IN NUMBER DEFAULT 1);

/*--------------------------------------------------*/
/* procedure name: Migrate_From_115X                */
/* description   : procedure for migrating Depot    */
/*                 CSD_REPAIR_JOB_XREF table        */
/*                 data from 11.5.7 to 11.5.8       */
/*--------------------------------------------------*/

PROCEDURE CSD_REPAIR_JOB_XREF_MIG (p_slab_number IN NUMBER DEFAULT 1);

/*--------------------------------------------------*/
/* procedure name: Migrate_From_115X                */
/* description   : procedure for migrating Depot    */
/*                 CSD_REPAIR_TYPES_B table         */
/*                 data from 11.5.7 to 11.5.8       */
/*--------------------------------------------------*/

PROCEDURE CSD_REPAIR_TYPES_B_MIG ;


END CSD_Migrate_From_115X_PKG;

 

/
