--------------------------------------------------------
--  DDL for Package Body CE_SYSTEM_PARAMETERS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_SYSTEM_PARAMETERS1_PKG" as
/* $Header: cesysp1b.pls 120.8 2008/01/23 13:21:45 kbabu ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.8 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

/* ---------------------------------------------------------------------
|  CALL BY                                                             |
|       CEXCABMR.fmb AXCABMR.set_sys_par
|       ceabrdrb.pls,
|       ceabrmab.pls
|
|  The LEGAL_ENTITY_ID must be provided
 --------------------------------------------------------------------- */

  PROCEDURE SELECT_COLUMNS
	          (X_ROWID                        	IN OUT NOCOPY VARCHAR2,
                   X_SET_OF_BOOKS_ID             	IN OUT NOCOPY NUMBER,
                   X_CASHBOOK_BEGIN_DATE            	IN OUT NOCOPY DATE,
                   X_SHOW_CLEARED_FLAG              	IN OUT NOCOPY VARCHAR2,
                   X_SHOW_VOID_PAYMENT_FLAG         	IN OUT NOCOPY VARCHAR2,
		   X_LINE_AUTOCREATION_FLAG		IN OUT NOCOPY VARCHAR2,
		   X_INTERFACE_PURGE_FLAG		IN OUT NOCOPY VARCHAR2,
		   X_INTERFACE_ARCHIVE_FLAG		IN OUT NOCOPY VARCHAR2,
                   X_LINES_PER_COMMIT               	IN OUT NOCOPY NUMBER,
                   X_FUNCTIONAL_CURRENCY            	IN OUT NOCOPY VARCHAR2,
	 	   X_SOB_SHORT_NAME			IN OUT NOCOPY VARCHAR2,
	 	   X_ACCOUNT_PERIOD_TYPE		IN OUT NOCOPY VARCHAR2,
	 	   X_USER_EXCHANGE_RATE_TYPE		IN OUT NOCOPY VARCHAR2,
		   X_CHART_OF_ACCOUNTS_ID		IN OUT NOCOPY NUMBER,
                   X_CASHFLOW_EXCHANGE_RATE_TYPE    	IN OUT NOCOPY VARCHAR2,
                   X_AUTHORIZATION_BAT	            	IN OUT NOCOPY VARCHAR2,
                   X_BSC_EXCHANGE_DATE_TYPE         	IN OUT NOCOPY VARCHAR2,
                   X_BAT_EXCHANGE_DATE_TYPE         	IN OUT NOCOPY VARCHAR2,
		   X_LEGAL_ENTITY_ID		   	IN OUT NOCOPY NUMBER
		) IS
  BEGIN
    IF ( X_legal_entity_id is not null) then
      SELECT s.rowid,
	   s.set_of_books_id,
           s.cashbook_begin_date,
           s.show_cleared_flag,
           NVL(s.show_void_payment_flag, 'N'),
           NVL(s.lines_per_commit,1),
	   g.currency_code,
	   s.line_autocreation_flag,
	   NVL(s.interface_purge_flag,'N'),
	   NVL(s.interface_archive_flag,'N'),
	   g.short_name,
	   g.accounted_period_type,
	   ct.user_conversion_type,
	   g.chart_of_accounts_id,
	   s.CASHFLOW_EXCHANGE_RATE_TYPE,
	   s.AUTHORIZATION_BAT,
	   s.BSC_EXCHANGE_DATE_TYPE,
 	   s.BAT_EXCHANGE_DATE_TYPE,
	   s.legal_entity_id
      INTO X_Rowid,
	 X_Set_Of_Books_Id,
         X_Cashbook_Begin_Date,
         X_Show_Cleared_Flag,
         X_Show_Void_Payment_Flag,
         X_Lines_Per_Commit,
         X_Functional_Currency,
	 X_line_autocreation_flag,
	 X_interface_purge_flag,
	 X_interface_archive_flag,
	 X_sob_short_name,
	 X_account_period_type,
	 X_user_exchange_rate_type,
	 X_chart_of_accounts_id,
	 X_CASHFLOW_EXCHANGE_RATE_TYPE,
	 X_AUTHORIZATION_BAT,
	 X_BSC_EXCHANGE_DATE_TYPE,
	 X_BAT_EXCHANGE_DATE_TYPE,
         X_legal_entity_id
      FROM CE_SYSTEM_PARAMETERS s,
	 GL_SETS_OF_BOOKS g,
	 GL_DAILY_CONVERSION_TYPES ct
      WHERE s.legal_entity_id =  X_legal_entity_id
      and s.set_of_books_id = g.set_of_books_id
      AND	  ct.conversion_type = 'User';


    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.SELECT_COLUMNS NO_DATA_FOUND');
	null;
  WHEN TOO_MANY_ROWS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.SELECT_COLUMNS TOO_MANY_ROWS');
	null;
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.SELECT_COLUMNS');
    RAISE;
  END SELECT_COLUMNS;

/* ---------------------------------------------------------------------
|  CALL BY                                                             |
|       ceabrimb.pls, ceabrmab.pls
|
|  The X_BANK_ACCOUNT_ID must be provided
|
 --------------------------------------------------------------------- */

   PROCEDURE BA_SELECT_COLUMNS
	          (X_ROWID                      	IN OUT NOCOPY VARCHAR2,
	           X_AP_AMOUNT_TOLERANCE		IN OUT NOCOPY NUMBER,
	           X_AP_PERCENT_TOLERANCE		IN OUT NOCOPY NUMBER,
	           X_AR_AMOUNT_TOLERANCE		IN OUT NOCOPY NUMBER,
	           X_AR_PERCENT_TOLERANCE		IN OUT NOCOPY NUMBER,
	           X_CE_AMOUNT_TOLERANCE		IN OUT NOCOPY NUMBER,
	           X_CE_PERCENT_TOLERANCE		IN OUT NOCOPY NUMBER,
           	   X_STMT_LN_FLOAT_HANDLING_FLAG 	IN OUT NOCOPY VARCHAR2,
             	   X_AUTORECON_AP_MATCHING_ORDER 	IN OUT NOCOPY VARCHAR2,
	           X_AUTORECON_AR_MATCHING_ORDER 	IN OUT NOCOPY VARCHAR2,
	           X_RECON_FX_BANK_XRATE_TYPE 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_FX_BANK_XDATE_TYPE	 	IN OUT NOCOPY VARCHAR2,
	           X_RECON_ENABLE_OI_FLAG 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_OI_FLOAT_STATUS 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_OI_CLEARED_STATUS 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_OI_MATCHING_CODE 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_OI_AMOUNT_TOLERANCE          IN OUT NOCOPY NUMBER,
	           X_RECON_OI_PERCENT_TOLERANCE         IN OUT NOCOPY NUMBER,
	           X_MANUAL_RECON_AMOUNT_TOL     	IN OUT NOCOPY NUMBER,
	           X_MANUAL_RECON_PERCENT_TOL     	IN OUT NOCOPY NUMBER,
	           X_RECON_AP_FX_DIFF_HANDLING 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_AR_FX_DIFF_HANDLING 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_CE_FX_DIFF_HANDLING 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_AP_TOL_DIFF_ACCT 		IN OUT NOCOPY VARCHAR2,
	           X_RECON_CE_TOL_DIFF_ACCT		IN OUT NOCOPY VARCHAR2,
	           X_LEGAL_ENTITY_ID			IN OUT NOCOPY NUMBER,
	           X_BANK_ACCOUNT_ID			IN OUT NOCOPY NUMBER,
		   X_AUTORECON_AP_MATCHING_ORDER2 	IN OUT NOCOPY VARCHAR2 -- FOR SEPA ER 6700007
		) IS
  BEGIN
    IF ( X_legal_entity_id is not null) then
      SELECT BA.rowid,
           BA.AP_AMOUNT_TOLERANCE		,
           BA.AP_PERCENT_TOLERANCE		,
           BA.AR_AMOUNT_TOLERANCE		,
           BA.AR_PERCENT_TOLERANCE		,
           BA.CE_AMOUNT_TOLERANCE		,
           BA.CE_PERCENT_TOLERANCE		,
      	   BA.STMT_LINE_FLOAT_HANDLING_FLAG 	,
      	   BA.AUTORECON_AP_MATCHING_ORDER 	,
           BA.AUTORECON_AR_MATCHING_ORDER 	,
 	   BA.RECON_FOREIGN_BANK_XRATE_TYPE,
	   BA.RECON_FOR_BANK_XRATE_DATE_TYPE ,
           BA.RECON_ENABLE_OI_FLAG 		,
           BA.RECON_OI_FLOAT_STATUS 		,
           BA.RECON_OI_CLEARED_STATUS 		,
           BA.RECON_OI_MATCHING_CODE 		,
           BA.RECON_OI_AMOUNT_TOLERANCE          ,
           BA.RECON_OI_PERCENT_TOLERANCE         ,
           BA.MANUAL_RECON_AMOUNT_TOLERANCE     	,
           BA.MANUAL_RECON_PERCENT_TOLERANCE     	,
	   BA.RECON_AP_FOREIGN_DIFF_HANDLING,
	   BA.RECON_AR_FOREIGN_DIFF_HANDLING,
	   BA.RECON_CE_FOREIGN_DIFF_HANDLING,
           BA.RECON_AP_TOLERANCE_DIFF_ACCT 		,
           BA.RECON_CE_TOLERANCE_DIFF_ACCT		,
           BA.ACCOUNT_OWNER_ORG_ID,
           BA.BANK_ACCOUNT_ID                   ,
	   BA.AUTORECON_AP_MATCHING_ORDER2 -- FOR SEPA ER 6700007

      INTO X_Rowid,
           X_AP_AMOUNT_TOLERANCE		,
           X_AP_PERCENT_TOLERANCE		,
           X_AR_AMOUNT_TOLERANCE		,
           X_AR_PERCENT_TOLERANCE		,
           X_CE_AMOUNT_TOLERANCE		,
           X_CE_PERCENT_TOLERANCE		,
           X_STMT_LN_FLOAT_HANDLING_FLAG 	,
           X_AUTORECON_AP_MATCHING_ORDER 	,
           X_AUTORECON_AR_MATCHING_ORDER 	,
	   X_RECON_FX_BANK_XRATE_TYPE 		,
	   X_RECON_FX_BANK_XDATE_TYPE	 	,
           X_RECON_ENABLE_OI_FLAG 		,
           X_RECON_OI_FLOAT_STATUS 		,
           X_RECON_OI_CLEARED_STATUS 		,
           X_RECON_OI_MATCHING_CODE 		,
           X_RECON_OI_AMOUNT_TOLERANCE          ,
           X_RECON_OI_PERCENT_TOLERANCE         ,
           X_MANUAL_RECON_AMOUNT_TOL     	,
           X_MANUAL_RECON_PERCENT_TOL     	,
           X_RECON_AP_FX_DIFF_HANDLING 		,
           X_RECON_AR_FX_DIFF_HANDLING 		,
           X_RECON_CE_FX_DIFF_HANDLING 		,
           X_RECON_AP_TOL_DIFF_ACCT 		,
           X_RECON_CE_TOL_DIFF_ACCT		,
           X_LEGAL_ENTITY_ID			,
           X_BANK_ACCOUNT_ID			,
	   X_AUTORECON_AP_MATCHING_ORDER2       -- FOR SEPA ER 6700007
      FROM CE_BANK_ACCOUNTS	BA
      WHERE BA.BANK_ACCOUNT_ID = X_BANK_ACCOUNT_ID;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BA_SELECT_COLUMNS NO_DATA_FOUND');
	null;
  WHEN TOO_MANY_ROWS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BA_SELECT_COLUMNS TOO_MANY_ROWS');
	null;
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BA_SELECT_COLUMNS');
    RAISE;
  END Ba_Select_Columns;

/* ---------------------------------------------------------------------
|  CALL BY                                                             |
|
|
|
 --------------------------------------------------------------------- */
  PROCEDURE BAU_SELECT_COLUMNS
		        (X_ROWID                      	IN OUT NOCOPY VARCHAR2,
			 X_RECEIVABLE_TRX_ID		IN OUT NOCOPY NUMBER,
		         X_ORG_ID			IN OUT NOCOPY NUMBER,
		         X_BANK_ACCOUNT_ID		IN OUT NOCOPY NUMBER,
		         X_BANK_ACCT_USE_ID		IN OUT NOCOPY NUMBER)
IS
  BEGIN
    IF ((X_BANK_ACCT_USE_ID is not null) or
	  (X_BANK_ACCOUNT_ID is not null and X_ORG_ID is not null )) then
null;
      SELECT BAU.rowid,
	     BAU.NEW_AR_RCPTS_RECEIVABLE_TRX_ID ,
	     BAU.ORG_ID,
	     BAU.BANK_ACCOUNT_ID,
	     BAU.BANK_ACCT_USE_ID
	INTO X_ROWID ,
	     X_RECEIVABLE_TRX_ID,
             X_ORG_ID,
             X_BANK_ACCOUNT_ID,
             X_BANK_ACCT_USE_ID
  	FROM CE_BANK_ACCT_USES_ALL  BAU
	WHERE
	     BAU.BANK_ACCT_USE_ID = NVL(X_BANK_ACCT_USE_ID, BAU.BANK_ACCT_USE_ID)
	 and  BAU.ORG_ID = NVL(X_ORG_ID, BAU.ORG_ID)
	AND  BAU.BANK_ACCOUNT_ID = NVL(X_BANK_ACCOUNT_ID, BAU.BANK_ACCOUNT_ID);
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BAU_SELECT_COLUMNS NO_DATA_FOUND');
	null;
  WHEN TOO_MANY_ROWS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BAU_SELECT_COLUMNS TOO_MANY_ROWS');
	null;
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_SYSTEM_PARAMETERS1_PKG.BAU_SELECT_COLUMNS');
    RAISE;
  END BAU_SELECT_COLUMNS;

END CE_SYSTEM_PARAMETERS1_PKG;

/
