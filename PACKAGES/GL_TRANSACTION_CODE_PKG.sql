--------------------------------------------------------
--  DDL for Package GL_TRANSACTION_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANSACTION_CODE_PKG" AUTHID CURRENT_USER AS
/* $Header: gliussgs.pls 120.2 2005/05/05 01:29:25 kvora ship $ */


PROCEDURE check_unique_trans_code(
	X_rowid				varchar2,
  	X_chart_of_accounts_id	 	number,
	X_ussgl_transaction_code	varchar2);

PROCEDURE check_unique_acct_pair(
	X_rowid				varchar2,
  	X_chart_of_accounts_id	 	number,
	X_ussgl_transaction_code	varchar2,
	X_dr_account_segment_value	varchar2,
	X_cr_account_segment_value	varchar2);


END GL_TRANSACTION_CODE_PKG;

 

/
