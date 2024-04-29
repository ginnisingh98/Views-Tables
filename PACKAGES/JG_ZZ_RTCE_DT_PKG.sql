--------------------------------------------------------
--  DDL for Package JG_ZZ_RTCE_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_RTCE_DT_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztoarntrls.pls 120.4 2006/05/12 15:52:19 rpokkula ship $*/

  P_REPORTING_ENTITY_ID           number;
  P_FISCAL_YEAR                   number;
  P_DEC_TYPE                      varchar2(1);
  P_MIN_INV_AMT                   number;
  P_CALLED_FROM                   varchar2(40);
  gv_country                      XLE_FIRSTPARTY_INFORMATION_V.country%type ;
  gv_currency_code                gl_ledger_le_v.currency_code%type;
  gv_tax_reg_num                  ar_system_parameters.tax_registration_number%type;
  gn_legal_entity_id              number;
  gv_repent_id_number             XLE_FIRSTPARTY_INFORMATION_V.registration_number%type;
  gv_repent_trn                   JG_ZZ_VAT_REP_ENTITIES.TAX_REGISTRATION_NUMBER%type;
  gd_period_start_date            date;
  gd_period_end_date              date;
  gv_repent_name                  XLE_FIRSTPARTY_INFORMATION_V.name%type;
  gv_repent_address_line_1        XLE_FIRSTPARTY_INFORMATION_V.address_line_1%type ;
  gv_repent_address_line_2        XLE_FIRSTPARTY_INFORMATION_V.address_line_2%type ;
  gv_repent_address_line_3        XLE_FIRSTPARTY_INFORMATION_V.address_line_3%type ;
  gv_repent_town_or_city          XLE_FIRSTPARTY_INFORMATION_V.town_or_city%type ;
  gv_repent_postal_code           XLE_FIRSTPARTY_INFORMATION_V.postal_code%type ;
  gv_repent_phone_number          varchar2(600);
  gv_tax_office_location          xle_legalauth_v.city%type ;
  gv_tax_office_number            xle_legalauth_v.address2%type ;
  gv_tax_office_code              xle_legalauth_v.address3%type ;
  gn_tot_customers                number;
  gv_chart_of_accounts_id         number(15);
  gv_ledger_id                    number(15);
  gv_balancing_segment_value      jg_zz_vat_rep_entities.balancing_segment_value%type ;
  gv_prev_fiscal_code             VARCHAR2(20) ;

  function  BeforeReport              return boolean  ;
  function  get_bsv(ccid number)      return varchar2 ;
  function  cf_currency_code          return varchar2 ;
  function  cf_country                return varchar2 ;
  function  cf_tax_reg_num            return varchar2 ;
  function  cf_legal_entity_id        return number   ;
  function  cf_repent_id_number       return varchar2 ;
  function  cf_repent_trn             return varchar2 ;
  function  cf_period_start_date      return date     ;
  function  cf_period_end_date        return date     ;
  function  cf_repent_name            return varchar2 ;
  function  cf_repent_address_line_1  return varchar2 ;
  function  cf_repent_address_line_2  return varchar2 ;
  function  cf_repent_address_line_3  return varchar2 ;
  function  cf_repent_town_or_city    return varchar2 ;
  function  cf_repent_postal_code     return varchar2 ;
  function  cf_repent_phone_number    return varchar2 ;
  function  cf_tax_office_location    return varchar2 ;
  function  cf_tax_office_number      return varchar2 ;
  function  cf_tax_office_code        return varchar2 ;
  function  cf_prev_fiscal_code       return varchar2 ;
  function cf_total_amount(taxable_amount in number,
                           tax_amount in number,
                           exempt_amount in number,
                           nontaxable_amount in number) return number  ;
END JG_ZZ_RTCE_DT_PKG ;

 

/
