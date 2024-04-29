--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_ALLOC_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_ALLOC_PRC_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzvatallocprcs.pls 120.2 2006/07/26 14:10:26 brathod ship $*/

  g_period_type_periodic    constant varchar2(30) := 'PERIODIC';
  g_period_type_annual      constant varchar2(30) := 'ANNUAL';
  g_fresh_allocation        constant varchar2(30) := 'FRESH ALLOCATION';
  g_error_allocation        constant varchar2(30) := 'ERROR ALLOCATION';

  g_source_ap constant varchar2(2) := 'AP';
  g_source_ar constant varchar2(2) := 'AR';
  g_source_gl constant varchar2(2) := 'GL';
  g_source_all constant varchar2(15) := 'ALL';
  g_ar_entitycode_receipts      constant varchar2(30) := 'RECEIPTS';
  g_ar_entitycode_transactions  constant varchar2(30) := 'TRANSACTIONS';

  g_yes constant varchar2(1) := 'Y';
  g_no constant varchar2(1) := 'N';
  g_alloc_errcode_rule_not_found  constant varchar2(30) := 'JG_ZZ_NO_RULE_APPLICABLE';
  g_alloc_errcode_vtt_not_found   constant varchar2(30) := 'JG_ZZ_NO_VTT_IN_RATE';
  /* g_alloc_errcode_cannot_create   constant varchar2(30) := 'JG_ZZ_NO_RULE_APPLICABLE'; */
  g_alloc_errcode_nrb_not_def     constant varchar2(30) := 'JG_ZZ_NO_NREC_BOX_IN_RULE';  -- IMPL

  /* API to flush the data */
  PROCEDURE purge_allocation_data(
    pn_reporting_status_id        number,           /* Primarykey Indicator for repEntity, tax_calerdar and source */
    pv_reallocate_flag            varchar2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  );

  PROCEDURE insert_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    pn_created_by              number,
    pn_last_updated_by         number,
    pn_last_update_login       number,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  );

  PROCEDURE update_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    pn_last_updated_by         number,
    pn_last_update_login       number,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  );

  PROCEDURE delete_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  );

  /* Main procedure that performs the allocation */
  PROCEDURE run_allocation (
    xv_errbuf                   OUT nocopy varchar2,       /*Out parameter for conc. program*/
    xv_retcode                  OUT nocopy varchar2,     /*Out parameter for conc. program*/
    pn_vat_reporting_entity_id      number,       /*this contains TRN, tax_calerdar etc. */
    pv_tax_calendar_period          varchar2,     /* calendar period for which allocation should run*/
    pv_source                       varchar2,     /*one of AP, AR, GL, ALL */
    pv_reallocate_flag              varchar2      /*'Y'- to reallocate all the previous allocation again*/
  );

  PROCEDURE allocate_box(
    pn_vat_reporting_entity_id    number,
    pv_period_type                VARCHAR2,
    pv_source                     VARCHAR2,
    pv_event_class_code           VARCHAR2,
    pv_tax                        VARCHAR2,
    pv_tax_status                 VARCHAR2,
    pv_tax_jurisdiction           VARCHAR2,
    pv_tax_rate_code              VARCHAR2,
    pv_tax_recoverable_flag       VARCHAR2,
    xv_tax_box                OUT nocopy VARCHAR2,
    xv_taxable_box            OUT nocopy VARCHAR2,
    xn_allocation_rule_id     OUT nocopy VARCHAR2,
    xv_error_code             OUT nocopy VARCHAR2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  );

  FUNCTION get_allocation_status(
      pn_reporting_status_id NUMBER
  ) return varchar2;

END JG_ZZ_VAT_ALLOC_PRC_PKG;

 

/
