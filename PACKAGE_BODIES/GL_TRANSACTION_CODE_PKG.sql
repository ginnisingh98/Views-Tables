--------------------------------------------------------
--  DDL for Package Body GL_TRANSACTION_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANSACTION_CODE_PKG" AS
/* $Header: gliussgb.pls 120.2 2005/05/05 01:29:18 kvora ship $ */


PROCEDURE check_unique_trans_code(
	X_rowid				varchar2,
  	X_chart_of_accounts_id	 	number,
	X_ussgl_transaction_code	varchar2) IS
X_flag	number:=0;

BEGIN

  SELECT 1 into X_flag
  FROM GL_USSGL_TRANSACTION_CODES GLTR
  WHERE  ((X_rowid is NULL) OR (X_rowid <> GLTR.rowid))
  AND GLTR.USSGL_TRANSACTION_CODE = X_ussgl_transaction_code
  AND GLTR.CHART_OF_ACCOUNTS_ID = X_chart_of_accounts_id;

  IF (X_flag = 1) THEN
    fnd_message.set_name('SQLGL','GL_DUP_TRANS_CODE');
    app_exception.raise_exception;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   return;

END check_unique_trans_code;

PROCEDURE check_unique_acct_pair(
	X_rowid				varchar2,
  	X_chart_of_accounts_id	 	number,
	X_ussgl_transaction_code	varchar2,
	X_dr_account_segment_value	varchar2,
	X_cr_account_segment_value	varchar2) IS
X_flag	number:= 0;

BEGIN
  SELECT 1 INTO X_flag
  FROM GL_USSGL_ACCOUNT_PAIRS GLAP
  WHERE ((X_rowid is NULL) OR (X_rowid <> GLAP.rowid))
  AND GLAP.CHART_OF_ACCOUNTS_ID    = X_chart_of_accounts_id
  AND GLAP.USSGL_TRANSACTION_CODE    = X_ussgl_transaction_code
  AND GLAP.DR_ACCOUNT_SEGMENT_VALUE  = X_DR_ACCOUNT_SEGMENT_VALUE
  AND GLAP.CR_ACCOUNT_SEGMENT_VALUE = X_CR_ACCOUNT_SEGMENT_VALUE;

  IF (X_flag = 1) THEN
    fnd_message.set_name('SQLGL','GL_DUP_ACCT_PAIR');
    app_exception.raise_exception;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   return;

END check_unique_acct_pair;

END GL_TRANSACTION_CODE_PKG;

/
