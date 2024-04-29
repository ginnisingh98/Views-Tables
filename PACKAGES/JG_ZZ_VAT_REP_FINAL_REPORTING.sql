--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_REP_FINAL_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_REP_FINAL_REPORTING" AUTHID CURRENT_USER as
/* $Header: jgzzvatfinalprcs.pls 120.2.12010000.1 2008/07/28 08:01:18 appldev ship $*/
/* --------------------------------------------------------------------------
CHANGE HISTORY:
S.No      Date          Author and Details

1.       25-jan-2006    Aparajita. Created Version#120.0.

         29-Mar-2006    Aparajita. Modified for revised approach.Version#120.1

         28-Apr-2006    Aparajita. Version#120.2
                        Modified xv_errbuf to be of varchar2 type.

 -------------------------------------------------------------------------- */


  procedure execute_final_reporting
  (
    xv_errbuf                     out   nocopy  varchar2,       /*out parameter for conc. program*/
    xv_retcode                    out   nocopy  varchar2,       /*out parameter for conc. program*/
    pn_vat_reporting_entity_id    in            jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in            gl_periods.period_name%type,
    pv_source                     in            varchar2
  );


 gv_legal_reporting_status        constant  zx_lines.legal_reporting_status%type := '111111111111111';
 gn_api_version                   constant  number := 1.0;


end jg_zz_vat_rep_final_reporting;

/
