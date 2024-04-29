--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_BOX_ALLOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_BOX_ALLOCS_PKG" AS
/* $Header: jgzzvatboxallocb.pls 120.1 2006/07/26 14:09:37 brathod ship $*/
/*------------------------------------------------------------------------------------------------------------
CHANGE HISTORY
1.  Vijay Shankar     20-Jan-2005                   File Version 120.0
                                                    Created.

2.  Bhavik Rathod     25-Jul-2005                   Bug: 5408280, File Version 120.1
                                                    Modified to uptake impact due to SIGN_FLAG column changes
                                                    Refer bug for more details
------------------------------------------------------------------------------------------------------------*/

  /* API to insert a single row */
  procedure INSERT_ROW(
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
  ) is


  begin
      INSERT INTO jg_zz_vat_box_allocs(
        vat_box_allocation_id  ,
        vat_transaction_id     ,
        allocation_rule_id     ,
        period_type            ,
        tax_box                ,
        taxable_box            ,
        tax_recoverable_flag   ,
        request_id             ,
        program_application_id ,
        program_id             ,
        program_update_date    ,
        program_login_id       ,
        creation_date          ,
        created_by             ,
        last_update_date       ,
        last_updated_by        ,
        last_update_login
      ) VALUES (
        jg_zz_vat_box_allocs_s.nextval,
        pn_vat_transaction_id     ,
        pn_allocation_rule_id     ,
        pv_period_type            ,
        pv_tax_box                ,
        pv_taxable_box            ,
        pv_tax_recoverable_flag   ,
        pn_request_id             ,
        pn_program_application_id ,
        pn_program_id             ,
        sysdate    ,
        pn_program_login_id       ,
        sysdate          ,
        pn_created_by             ,
        sysdate       ,
        pn_last_updated_by        ,
        pn_last_update_login
      ) returning vat_box_allocation_id into xn_vat_box_allocation_id;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_box_allocs_pkg.insert_row ~ Unexpected Error -' || sqlerrm;

  end INSERT_ROW;

  /* API to update a single row */
  procedure UPDATE_ROW(
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
  ) is

  begin
    UPDATE jg_zz_vat_box_allocs
    SET allocation_rule_id  = pn_allocation_rule_id,
      tax_box               = nvl(pv_tax_box, tax_box),
      taxable_box           = nvl(pv_taxable_box, taxable_box),
      program_update_date   = sysdate,
      last_update_date      = sysdate,
      request_id            = pn_request_id,
      program_login_id      = pn_program_login_id,
      last_updated_by       = pn_last_updated_by,
      last_update_login     = pn_last_update_login
    WHERE vat_box_allocation_id = pn_vat_box_allocation_id;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_box_allocs_pkg.update_row ~ Unexpected Error -' || sqlerrm;

  end UPDATE_ROW;

  /* API to delete a single row */
  procedure DELETE_ROW(
      Pn_VAT_BOX_ALLOCATION_ID         jg_zz_vat_box_allocs.VAT_BOX_ALLOCATION_ID%TYPE,
      Pn_VAT_TRANSACTION_ID            jg_zz_vat_box_allocs.VAT_TRANSACTION_ID%TYPE,
      Pv_PERIOD_TYPE                   jg_zz_vat_box_allocs.PERIOD_TYPE%TYPE,
      xv_return_status     out  nocopy  varchar2,
      xv_return_message    out  nocopy  varchar2
  ) is

  begin
    if pn_vat_Box_allocation_id is not null then
      DELETE FROM jg_zz_vat_box_allocs
      WHERE vat_box_allocation_id = pn_vat_box_allocation_id;
    else
      DELETE FROM jg_zz_vat_box_allocs
      WHERE vat_transaction_id = pn_vat_transaction_id
      AND period_type = pv_period_type;
    end if;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_box_allocs_pkg.delete_row ~ Unexpected Error -' || sqlerrm;

  end DELETE_ROW;

end JG_ZZ_VAT_BOX_ALLOCS_PKG;

/
