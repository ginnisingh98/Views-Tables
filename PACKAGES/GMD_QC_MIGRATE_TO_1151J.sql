--------------------------------------------------------
--  DDL for Package GMD_QC_MIGRATE_TO_1151J
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_MIGRATE_TO_1151J" AUTHID CURRENT_USER AS
/* $Header: GMDQCMJS.pls 115.14 2004/08/09 16:41:28 bstone noship $ */

   /*------------------- GLOBAL CURSORS ----------------------*/
   /*  Get the vendor/supplier ids form purchasing */
   CURSOR g_get_supplier_ids (pvendor_id NUMBER) IS
      SELECT of_vendor_id, of_vendor_site_id
      FROM po_vend_mst
      WHERE  vendor_id = pvendor_id;

   FUNCTION Get_Base_Language RETURN VARCHAR2;

   PROCEDURE Migrate_Assay_Classes (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Action_Codes (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Hold_Reasons (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Tests_Base (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Tests_Translated (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Values_Base (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Values_Translated (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Chk_overlapping_Spec_Tests (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Specifications (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Samples (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Migrate_Results(p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Create_Sample_Results(p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

END GMD_QC_MIGRATE_TO_1151J;


 

/
