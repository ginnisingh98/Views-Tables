--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_BOX_ALLOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_BOX_ALLOCS_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzvatboxallocs.pls 120.1 2006/07/26 14:09:06 brathod ship $*/
/*------------------------------------------------------------------------------------------------------------
CHANGE HISTORY
1.  Vijay Shankar     20-Jan-2005                   File Version 120.0
                                                    Created.

2.  Bhavik Rathod     25-Jul-2005                   Bug: 5408280, File Version 120.1
                                                    Modified to uptake impact due to SIGN_FLAG column changes
                                                    Refer bug for more details
------------------------------------------------------------------------------------------------------------*/
  /* API to insert a single row */
  PROCEDURE INSERT_ROW(
      XN_VAT_BOX_ALLOCATION_ID    OUT  nocopy jg_zz_vat_box_allocs.VAT_BOX_ALLOCATION_ID%TYPE,
      PN_VAT_TRANSACTION_ID            jg_zz_vat_box_allocs.VAT_TRANSACTION_ID%TYPE,
      PV_PERIOD_TYPE                   jg_zz_vat_box_allocs.PERIOD_TYPE%TYPE,
      PN_ALLOCATION_RULE_ID            jg_zz_vat_box_allocs.ALLOCATION_RULE_ID%TYPE,
      PV_TAX_BOX                       jg_zz_vat_box_allocs.TAX_BOX%TYPE,
      Pv_TAXABLE_BOX                   jg_zz_vat_box_allocs.TAXABLE_BOX%TYPE,
      PV_TAX_RECOVERABLE_FLAG          jg_zz_vat_box_allocs.TAX_RECOVERABLE_FLAG%TYPE,
      pn_request_id                    jg_zz_vat_box_allocs.request_id%TYPE,
      pn_program_application_id        jg_zz_vat_box_allocs.program_application_id%TYPE,
      pn_program_id                    jg_zz_vat_box_allocs.program_id%TYPE,
      pn_program_login_id              jg_zz_vat_box_allocs.program_login_id%TYPE,
      pn_created_by                    number,
      pn_last_updated_by               number,
      pn_last_update_login             number,
      xv_return_status     out  nocopy  varchar2,
      xv_return_message    out  nocopy  varchar2
  );

  /* API to update a single row */
  PROCEDURE UPDATE_ROW(
      Pn_VAT_BOX_ALLOCATION_ID         jg_zz_vat_box_allocs.VAT_BOX_ALLOCATION_ID%TYPE,
      Pn_ALLOCATION_RULE_ID            jg_zz_vat_box_allocs.ALLOCATION_RULE_ID%TYPE,
      Pv_TAX_BOX                       jg_zz_vat_box_allocs.TAX_BOX%TYPE,
      Pv_TAXABLE_BOX                   jg_zz_vat_box_allocs.TAXABLE_BOX%TYPE,
      pn_request_id                    jg_zz_vat_box_allocs.request_id%TYPE,
      pn_program_login_id              jg_zz_vat_box_allocs.program_login_id%TYPE,
      pn_last_updated_by               number,
      pn_last_update_login             number,
      xv_return_status     out  nocopy  varchar2,
      xv_return_message    out  nocopy  varchar2
  );

  /* API to delete a single row */
  PROCEDURE DELETE_ROW(
      Pn_VAT_BOX_ALLOCATION_ID         jg_zz_vat_box_allocs.VAT_BOX_ALLOCATION_ID%TYPE,
      Pn_VAT_TRANSACTION_ID            jg_zz_vat_box_allocs.VAT_TRANSACTION_ID%TYPE,
      Pv_PERIOD_TYPE                   jg_zz_vat_box_allocs.PERIOD_TYPE%TYPE,
      xv_return_status     out  nocopy  varchar2,
      xv_return_message    out  nocopy  varchar2
  );

END JG_ZZ_VAT_BOX_ALLOCS_PKG;

 

/
