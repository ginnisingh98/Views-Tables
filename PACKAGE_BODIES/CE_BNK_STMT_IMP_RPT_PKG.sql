--------------------------------------------------------
--  DDL for Package Body CE_BNK_STMT_IMP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BNK_STMT_IMP_RPT_PKG" 
-- $Header: CEBNKSTMTIMPB.pls 120.0.12000000.2 2007/06/21 02:13:20 csutaria noship $
--*****************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*****************************************************************************
--
--
-- PROGRAM NAME
--  CEBNKSTMTIMPB.pls
--
-- DESCRIPTION
--   This script creates the package body of CE_BNK_STMT_IMP_RPT_PKG.
--   This package is used by the 'Bank Statement Import Validation - Israel' report.
--
-- USAGE
--
--   To execute			   This can be applied by running this script at SQL*Plus.
--
--  PROGRAM LIST                   DESCRIPTION
--
--  get_account_num                It is a private function which is used to fetch the
--                                 bank account number corresponding to a bank account ID
--
--  beforeReportTrigger            It is a public function which is run just after the
--                                 queries are parsed and before queries are executed.
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   DataTemplate Extract in 'Bank Statement Import Validation - Israel' report.
--
-- LAST UPDATE DATE   20-DEC-2006
--
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ----------------- ------------------------------------
-- Draft1A 20-DEC-2006 Harsh Poddar   Draft Version
--***************************************************************************

AS

   FUNCTION get_account_num(P_BANK_ACCOUNT_ID IN VARCHAR2) RETURN VARCHAR2 IS
  lc_bank_account_num	VARCHAR2(50);

  BEGIN

  SELECT	cbav.bank_account_num
  INTO		lc_bank_account_num
  FROM		ce_bank_accounts_v cbav
  WHERE		cbav.bank_account_id = P_BANK_ACCOUNT_ID;

  RETURN lc_bank_account_num;

  END get_account_num;

  FUNCTION beforeReportTrigger RETURN BOOLEAN IS

  BEGIN

    SELECT	cbbv.bank_branch_name
    INTO	gc_bank_branch_name
    FROM	ce_bank_branches_v cbbv
    WHERE	cbbv.branch_party_id = P_BANK_BRANCH_ID;

    gc_status_current := fnd_message.get_string('CE','CE_BNK_STMT_IMP_CUR');
    gc_status_latest := fnd_message.get_string('CE','CE_BNK_STMT_IMP_LAT');

IF (P_BANK_ACCOUNT_ID IS NOT NULL AND P_STATEMENT_NUM IS NOT NULL) THEN
/* Specific values have been chosen for all parameters */

	gc_bank_account_num := get_account_num(P_BANK_ACCOUNT_ID);

 	lc_uploaded_select_columns := ' :gc_bank_account_num BANK_ACCOUNT_NUM,
                                    :P_STATEMENT_NUM BANK_STMT_NUM';

	lc_uploaded_where_conditions := 'uploaded.bank_branch_name = :gc_bank_branch_name
                                    AND uploaded.bank_account_num = :gc_bank_account_num
	    				            AND uploaded.statement_number = :P_STATEMENT_NUM';

 	lc_uploaded_group_by := ' :gc_bank_account_num, uploaded.statement_date';

ELSIF (P_BANK_ACCOUNT_ID IS NOT NULL) THEN
/* Specific values have been chosen for bank branch name and bank account number parameters only */

	gc_bank_account_num := get_account_num(P_BANK_ACCOUNT_ID);

	lc_uploaded_select_columns := ' :gc_bank_account_num BANK_ACCOUNT_NUM, uploaded.statement_number BANK_STMT_NUM';

 	lc_uploaded_where_conditions := 'uploaded.bank_branch_name = :gc_bank_branch_name
                                    AND uploaded.bank_account_num = :gc_bank_account_num';

   	lc_uploaded_group_by := ':gc_bank_account_num, uploaded.statement_number, uploaded.statement_date';

ELSIF (P_STATEMENT_NUM IS NOT NULL) THEN
/* Specific values have been chosen for bank branch name and bank statement number parameters only */

	lc_uploaded_select_columns := ' uploaded.bank_account_num BANK_ACCOUNT_NUM
	                                , :P_STATEMENT_NUM BANK_STMT_NUM';

 	lc_uploaded_where_conditions := 'uploaded.bank_branch_name = :gc_bank_branch_name
                                    AND uploaded.statement_number = :P_STATEMENT_NUM';

  	lc_uploaded_group_by := 'uploaded.bank_account_num, uploaded.statement_date';

ELSE /* Specific value has been chosen for bank branch name parameter only */

	lc_uploaded_select_columns := ' uploaded.bank_account_num BANK_ACCOUNT_NUM
	                                , uploaded.statement_number BANK_STMT_NUM';

	lc_uploaded_where_conditions := 'uploaded.bank_branch_name = :gc_bank_branch_name';

	lc_uploaded_group_by := ' uploaded.bank_account_num, uploaded.statement_number, uploaded.statement_date ';

END IF;

IF P_BANK_ACCOUNT_ID IS NOT NULL THEN

  	lc_latest_bank_acc_num := ':gc_bank_account_num';

	lc_latest_bank_acc_from := ' ';

 	lc_latest_bank_acc_where := ' AND latest.bank_account_id = :P_BANK_ACCOUNT_ID ';
ELSE
 	/*lc_latest_bank_acc_num := 'cba.bank_account_num';

 	lc_latest_bank_acc_from := ', ce_bank_accounts cba ';

 	lc_latest_bank_acc_where := ' AND cba.bank_account_id = latest.bank_account_id ';*/
	lc_latest_bank_acc_num := 'cba.bank_account_num';

 	lc_latest_bank_acc_from := ', ce_bank_accounts cba ';

 	lc_latest_bank_acc_where := ' AND cba.bank_account_id = latest.bank_account_id
	                              AND cba.bank_branch_id = :P_BANK_BRANCH_ID';

END IF;

  RETURN (TRUE);

  END beforeReportTrigger;

END CE_BNK_STMT_IMP_RPT_PKG;

/
