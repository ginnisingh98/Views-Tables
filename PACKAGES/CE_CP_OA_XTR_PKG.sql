--------------------------------------------------------
--  DDL for Package CE_CP_OA_XTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_CP_OA_XTR_PKG" AUTHID CURRENT_USER AS
/* $Header: cecputls.pls 120.2 2006/01/31 09:51:13 svali ship $ */

PROCEDURE XTR_GEN_EXPOSURES(
		X_bank_account_id 	IN	VARCHAR2,
		X_account_number	IN	VARCHAR2,
		X_amount		IN	VARCHAR2,
		X_base_amount		IN	VARCHAR2,
		X_currency_code		IN	VARCHAR2,
		X_rate			IN	VARCHAR2,
		X_exposure_type		IN	VARCHAR2,
		X_portfolio_code	IN	VARCHAR2,
		X_trx_date		IN	DATE,
		X_comments		IN	VARCHAR2,
		X_user_id		IN	VARCHAR2);

FUNCTION INCLUDE_INDIC(
		X_WS_ID		IN	NUMBER,
		X_SRC_TYPE	IN	VARCHAR2)	RETURN	VARCHAR2;

PROCEDURE SUBMIT_GEN_PRIOR_DAY(
 		X_WS_ID		IN	NUMBER,
		X_AS_OF_DATE	IN	VARCHAR2);

PROCEDURE UPDATE_PROJECTED_BALANCES(
		p_bank_account_id NUMBER,
		p_balance_date DATE,
		p_balance_amount NUMBER);
END CE_CP_OA_XTR_PKG;

 

/
