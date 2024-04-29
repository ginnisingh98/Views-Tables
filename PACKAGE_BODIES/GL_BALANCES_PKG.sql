--------------------------------------------------------
--  DDL for Package Body GL_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BALANCES_PKG" AS
/*  $Header: gliblncb.pls 120.4 2005/05/05 01:02:55 kvora ship $  */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE set_translated_flag( x_ledger_id            NUMBER,
                                 x_ccid                 NUMBER,
                                 x_currency             VARCHAR2,
                                 x_period_year          NUMBER,
                                 x_period_num           NUMBER,
                                 x_last_updated_by      NUMBER,
				 x_chart_of_accounts_id NUMBER,
				 x_period_name          VARCHAR2,
				 x_usage_code           VARCHAR2) IS
  BEGIN

    UPDATE GL_BALANCES bal
       SET bal.TRANSLATED_FLAG = 'N',
           bal.LAST_UPDATE_DATE = SYSDATE,
           bal.LAST_UPDATED_BY = x_last_updated_by
     WHERE bal.TRANSLATED_FLAG = 'Y'
       AND bal.LEDGER_ID = x_ledger_id
       AND bal.ACTUAL_FLAG = 'A'
       AND bal.TEMPLATE_ID IS NULL
       AND bal.CODE_COMBINATION_ID = x_ccid
       AND bal.CURRENCY_CODE = x_currency
       AND (bal.PERIOD_YEAR * 1000 + bal.PERIOD_NUM) >=
           (x_period_year * 1000 + x_period_num);

   GL_TRANS_STATUSES_PKG.set_translation_status(
				 x_chart_of_accounts_id ,
				 x_ccid	                ,
				 x_ledger_id            ,
                                 x_currency             ,
                                 x_period_year          ,
                                 x_period_num           ,
				 x_period_name	        ,
                                 x_last_updated_by      ,
				 x_usage_code);
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_BALANCES_PKG.set_translated_flag');
      RAISE;

  END set_translated_flag;

  PROCEDURE gl_get_period_range_activity
			  ( P_PERIOD_FROM         IN VARCHAR2
 	    		   ,P_PERIOD_TO           IN VARCHAR2
 			   ,P_CODE_COMBINATION_ID IN NUMBER
 			   ,P_LEDGER_ID           IN NUMBER
                           ,P_PERIOD_NET_DR       OUT NOCOPY NUMBER
                           ,P_PERIOD_NET_CR       OUT NOCOPY NUMBER) IS
  BEGIN

     select  SUM(NVL(PERIOD_NET_DR,0)),  SUM(NVL(PERIOD_NET_CR,0))
       into  P_PERIOD_NET_DR, P_PERIOD_NET_CR
       from  GL_BALANCES GLB, GL_LEDGERS GLA,
	     GL_PERIOD_STATUSES GLPS,
	     GL_PERIOD_STATUSES GLPSS, GL_PERIOD_STATUSES GLPSE
      where  GLA.LEDGER_ID           = P_LEDGER_ID
	and  GLB.LEDGER_ID           = P_LEDGER_ID
        and  GLB.CURRENCY_CODE	     = GLA.CURRENCY_CODE
        and  GLB.ACTUAL_FLAG         = 'A'
        and  GLB.CODE_COMBINATION_ID = P_CODE_COMBINATION_ID
        and  GLB.PERIOD_NAME         = GLPS.PERIOD_NAME
        and  GLPS.LEDGER_ID          = P_LEDGER_ID
        and  GLPS.APPLICATION_ID     = 101
	and  GLPSS.LEDGER_ID         = P_LEDGER_ID
        and  GLPSS.APPLICATION_ID    = 101
	and  GLPSS.PERIOD_NAME       = P_PERIOD_FROM
	and  GLPSE.LEDGER_ID         = P_LEDGER_ID
        and  GLPSE.APPLICATION_ID    = 101
	and  GLPSE.PERIOD_NAME       = P_PERIOD_TO
        and  GLPS.PERIOD_YEAR * 10000 + GLPS.PERIOD_NUM
	     between (GLPSS.PERIOD_YEAR * 10000 + GLPSS.PERIOD_NUM)
		 and (GLPSE.PERIOD_YEAR * 10000 + GLPSE.PERIOD_NUM);

  END gl_get_period_range_activity;

END GL_BALANCES_PKG;

/
