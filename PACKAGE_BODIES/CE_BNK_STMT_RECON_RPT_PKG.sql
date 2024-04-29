--------------------------------------------------------
--  DDL for Package Body CE_BNK_STMT_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BNK_STMT_RECON_RPT_PKG" 
-- $Header: CEBNKSTMTRECONB.pls 120.0.12000000.2 2007/06/09 01:43:32 csutaria noship $
--*****************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*****************************************************************************
--
--
-- PROGRAM NAME
--  CEBNKSTMTRECONB.pls
--
-- DESCRIPTION
--   This script creates the package body of CE_BNK_STMT_RECON_RPT_PKG.
--   This package is used by the 'Israel - Bank Statement Reconciliation' report.
--
-- USAGE
--
--   To execute			   This can be applied by running this script at SQL*Plus.
--
--  PROGRAM LIST                   DESCRIPTION
--
--  beforeReportTrigger            It is a public function which is run just after the
--                                 queries are parsed and before queries are executed.
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   DataTemplate Extract in 'Israel - Bank Statement Reconciliation' report.
--
-- LAST UPDATE DATE   10-FEB-2007
--
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ----------------- ------------------------------------
-- Draft1A 10-FEB-2007 Harsh Poddar   Draft Version
--***************************************************************************

AS

  FUNCTION beforeReportTrigger RETURN BOOLEAN IS

  BEGIN

    cep_standard.init_security;
    ce_auto_bank_match.set_all;
  --Added the Quotes for the Values retrieved
    gc_trx_type_payment := ''''||fnd_message.get_string('CE','CE_BNK_STMT_RECON_PAYMENT')||'''';
    gc_trx_type_receipt := ''''||fnd_message.get_string('CE','CE_BNK_STMT_RECON_RECEIPT')||'''';
    gc_origin_accounted := ''''||fnd_message.get_string('CE','CE_BNK_STMT_RECON_ACCOUNTED')||'''';
    gc_origin_bank_stmt := ''''||fnd_message.get_string('CE','CE_BNK_STMT_RECON_BANK_STMT')||'''';

	SELECT	cibav.bank_account_name, cibav.currency_code
	INTO	gc_bank_account_name, gc_currency_code
	FROM	ce_internal_bank_accounts_v cibav
	WHERE	cibav.bank_account_id = P_BANK_ACCOUNT_ID;

	SELECT	csp.set_of_books_id
	INTO	gn_sob_id
	FROM	ce_system_parameters csp,
		ce_bank_accts_gt_v cbagv
	WHERE	csp.legal_entity_id = cbagv.account_owner_org_id
	AND	cbagv.bank_account_id = P_BANK_ACCOUNT_ID;

	SELECT  glp.start_date
	INTO	gc_from_date
	FROM	gl_period_statuses glp
	WHERE	glp.application_id = 101
	AND	glp.period_name = P_ACC_PERIOD_FROM
	AND	glp.set_of_books_id = gn_sob_id;

	SELECT  glp.end_date
	INTO	gc_to_date
	FROM	gl_period_statuses glp
	WHERE	glp.application_id = 101
	AND	glp.period_name = P_ACC_PERIOD_TO
	AND	glp.set_of_books_id = gn_sob_id;

  RETURN (TRUE);

  END beforeReportTrigger;

END CE_BNK_STMT_RECON_RPT_PKG;

/
