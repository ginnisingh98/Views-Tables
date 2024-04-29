--------------------------------------------------------
--  DDL for Package CSD_MIGRATE_FROM_115X_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIGRATE_FROM_115X_PKG2" AUTHID CURRENT_USER as
/* $Header: csdmig2s.pls 115.1 2002/12/20 22:42:05 travikan noship $ */

/*------------------------------------------------------*/
/* procedure name: csd_repairs_pkg2                     */
/* description   : procedure for migrating repair lines */
/*                 data from 11.5.8 to 11.5.9           */
/*------------------------------------------------------*/

  PROCEDURE csd_repairs_mig2(p_slab_number IN NUMBER DEFAULT 1);

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_TYPES_B_MIG2                                       */
/* description   : procedure for migrating Material , Labor and Expense SAR      */
/*                 data in CSD_REPAIR_TYPES_B table in 11.5.8                    */
/*                 to CSD_REPAIR_TYPES_SAR table in 11.5.9                       */
/*-------------------------------------------------------------------------------*/

  PROCEDURE CSD_REPAIR_TYPES_B_MIG2;

END CSD_Migrate_From_115X_PKG2;

 

/
