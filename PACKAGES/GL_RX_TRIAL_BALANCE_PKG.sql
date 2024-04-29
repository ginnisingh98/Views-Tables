--------------------------------------------------------
--  DDL for Package GL_RX_TRIAL_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RX_TRIAL_BALANCE_PKG" AUTHID CURRENT_USER as
/* $Header: glurxtbs.pls 120.5 2005/05/05 01:43:10 kvora ship $ */

PROCEDURE create_rows (
  errbuf                 out NOCOPY 	VARCHAR2,
  retcode                out NOCOPY 	VARCHAR2,
  p_ledger_name          in 	VARCHAR2 ,
  p_period_name          in 	VARCHAR2 ,
  p_account_from         in 	VARCHAR2 default null,
  p_account_to           in 	VARCHAR2 default null,
  p_balancing_value      in 	VARCHAR2 default null,
  p_currency_code        in 	VARCHAR2 default null,
  p_translated_flag      in 	VARCHAR2 default 'N',
  p_summary_flag         in 	VARCHAR2 default 'N',
  p_summary_digits       in 	NUMBER   default 1,
  p_statutory_rfj_flag   in 	VARCHAR2 default 'N');

end gl_rx_trial_balance_pkg;

 

/
