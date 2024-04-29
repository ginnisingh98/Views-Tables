--------------------------------------------------------
--  DDL for Package FV_FACTS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS1_PKG" AUTHID CURRENT_USER AS
/* $Header: FVFCFIPS.pls 120.2 2005/10/05 14:18:20 spothuri noship $ */

PROCEDURE MAIN(p_err_buff OUT NOCOPY VARCHAR2,
	       p_err_code OUT NOCOPY NUMBER,
               p_sob_id         NUMBER,
               p_coa_id         NUMBER,
               p_run_type       VARCHAR2,
               p_period_name    VARCHAR2,
               p_fiscal_year    NUMBER,
               p_run_journal    VARCHAR2,
               p_run_reports    VARCHAR2,
               p_trading_partner_att IN VARCHAR2 DEFAULT NULL
             );

PROCEDURE TRIAL_BALANCE_MAIN
             (p_errbuf         OUT NOCOPY Varchar2,
              p_retcode        OUT NOCOPY Number,
              p_sob                Gl_ledgers_public_v.ledger_id%TYPE,
              p_coa                Gl_Code_Combinations.chart_of_accounts_id%TYPE,
              p_fund_range_low     Fv_Fund_Parameters.fund_value%TYPE,
              p_fund_range_high    Fv_Fund_Parameters.fund_value%TYPE,
              p_currency_code      Varchar2,
              p_period_name        Varchar2,
              p_report_id          Number,
              p_attribute_set      Varchar2,
              p_output_format      Varchar2);

PROCEDURE SET_UP_FACTS_ATTRIBUTES(p_err_buf OUT NOCOPY VARCHAR2,
                                  p_err_code OUT NOCOPY NUMBER,
                                  p_set_of_books_id IN NUMBER,
                                  p_period_year IN NUMBER);

PROCEDURE GET_FEDERAL_ACCOUNTS (p_err_buff OUT NOCOPY VARCHAR2,
                                p_err_code OUT NOCOPY NUMBER,
                                p_sob_id   IN NUMBER,
                                p_run_year IN NUMBER);

--------------------------------------------------------------------------------
END FV_FACTS1_PKG;

 

/
