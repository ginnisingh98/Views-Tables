--------------------------------------------------------
--  DDL for Package Body GL_DAILY_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DAILY_BALANCES_PKG" AS
/*  $Header: glidbalb.pls 120.3 2005/05/05 01:06:31 kvora ship $  */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE set_translated_flag( x_ledger_id         NUMBER,
                                 x_ccid              NUMBER,
                                 x_currency          VARCHAR2,
                                 x_period_year       NUMBER,
                                 x_period_num        NUMBER,
                                 x_last_updated_by   NUMBER,
				 x_chart_of_accounts_id NUMBER,
				 x_period_name       VARCHAR2,
				 x_usage_code        VARCHAR2) IS
  BEGIN

    UPDATE GL_DAILY_BALANCES bal
       SET bal.CURRENCY_TYPE = 'O',
           bal.LAST_UPDATE_DATE = SYSDATE,
           bal.LAST_UPDATED_BY = x_last_updated_by
     WHERE bal.CURRENCY_TYPE = 'T'
       AND bal.LEDGER_ID = x_ledger_id
       AND bal.ACTUAL_FLAG = 'A'
       AND bal.TEMPLATE_ID IS NULL
       AND bal.CODE_COMBINATION_ID = x_ccid
       AND bal.CURRENCY_CODE = x_currency
       AND (bal.PERIOD_YEAR * 1000 + bal.PERIOD_NUM) >=
           (x_period_year * 1000 + x_period_num);

    GL_TRANS_TRACKING_PKG.set_outdated_period(x_chart_of_accounts_id,
		      x_ccid,
		      x_ledger_id,
		      x_currency,
		      x_period_year,
		      x_period_num,
		      x_period_name,
		      x_last_updated_by,
		      x_usage_code);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN NO_DATA_FOUND THEN
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_DAILY_BALANCES_PKG.set_translated_flag');
      RAISE;

  END set_translated_flag;



END GL_DAILY_BALANCES_PKG;

/
