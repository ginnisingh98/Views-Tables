--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_REP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_REP_UTILITY" AUTHID CURRENT_USER as
/* $Header: jgzzvatreputil_s.pls 120.3 2006/12/29 07:06:57 rjreddy ship $*/

  function get_last_processed_date
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2 /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
  )
  return date;

  procedure validate_process_initiation
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    pv_reallocate_flag            in                varchar2 default null,  /* Valid for allocation only, Possible values Y or N or nul */
    xn_reporting_status_id_ap     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xn_reporting_status_id_ar     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xn_reporting_status_id_gl     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  );


  procedure post_process_update
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    pn_process_id                 in                jg_zz_vat_rep_status.selection_process_id%type, /* Process id for SELECTION, ALLOCATION, FINAL REPORTING */
    pv_process_flag               in                jg_zz_vat_rep_status.selection_status_flag%type,
    pv_enable_allocations_flag    in                jg_zz_vat_rep_entities.enable_allocations_flag%type default null, /* only for final reporting process */
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  );


  function get_period_status
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pv_tax_calendar_year          in 	            number,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_report_name                in                varchar2,
    pv_vat_register_id            in                jg_zz_vat_registers_b.vat_register_id%type DEFAULT NULL
  ) return varchar2;


  procedure validate_entity_attributes
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  );

  function get_accounting_entity
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null
  ) return number;


  procedure create_accounting_entity
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xn_vat_reporting_entity_id    out   nocopy      number,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  );

  function get_reporting_identifier
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type default null,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    pv_called_from                in                varchar2 /* possible values - PARAMETER_FORM or TABLE_HANDLER */
  ) return varchar2;

  procedure maintain_selection_entities
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xn_vat_reporting_entity_id    out   nocopy      number,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  );

end jg_zz_vat_rep_utility;

/
