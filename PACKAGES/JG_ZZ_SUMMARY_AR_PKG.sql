--------------------------------------------------------
--  DDL for Package JG_ZZ_SUMMARY_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_SUMMARY_AR_PKG" AUTHID CURRENT_USER
-- $Header: jgzzsummaryars.pls 120.4.12010000.2 2009/12/10 09:41:52 rahulkum ship $
AS
  p_callingreport         VARCHAR2(30);
  p_vat_rep_entity_id     NUMBER;
  p_period                VARCHAR2(20);
  p_vat_trx_type          VARCHAR2(30);
  p_ex_vat_trx_type       VARCHAR2(30);
  p_tax_code              VARCHAR2(30);
  p_tax_status_id         NUMBER;
  p_tax_jurisdiction_code VARCHAR2(30);
  p_tax_rate_id           NUMBER;
  p_trx_status            VARCHAR2(20); --Added by Ramananda
  g_unapplied             CONSTANT VARCHAR2(10)   := 'Unapplied';
  g_applied               CONSTANT VARCHAR2(10)   := 'Applied';
  p_legal_entity_id	  number;
  p_ledger_id		  number;
  p_chart_of_acc_id       number;
  p_company		  number;
  p_tax_regime_code       varchar2(30);
  p_tax                   varchar2(30);
  p_tax_status_code       varchar2(30);
  p_gl_period_start_date  date;
  p_gl_period_end_date    date;
  p_reporting_level       varchar2(30);
  p_debug_switch	   varchar2(2);
  g_precision       	  number; --ER:IL VAT 2010
  g_vat_agg_limit   	  number;--ER:IL VAT 2010

  FUNCTION beforeReport RETURN BOOLEAN;

  --Added the following function by Ramananda
  FUNCTION is_tax_status( p_tax_status      IN VARCHAR2
                         ,p_context         IN VARCHAR2
                         ,p_tax_rate        IN NUMBER   DEFAULT NULL)
  RETURN BOOLEAN ;
  FUNCTION get_bsv(p_ccid NUMBER,p_coid NUMBER,p_ledger_id NUMBER) RETURN NUMBER;

END JG_ZZ_SUMMARY_AR_PKG;

/
