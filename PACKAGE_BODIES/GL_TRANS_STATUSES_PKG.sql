--------------------------------------------------------
--  DDL for Package Body GL_TRANS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANS_STATUSES_PKG" AS
/*  $Header: glitrstb.pls 120.3 2005/05/05 01:28:56 kvora ship $  */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE set_translation_status( x_chart_of_accounts_id NUMBER,
				 x_ccid	             NUMBER,
				 x_ledger_id         NUMBER,
                                 x_currency          VARCHAR2,
                                 x_period_year       NUMBER,
                                 x_period_num        NUMBER,
				 x_period_name	     VARCHAR2,
                                 x_last_updated_by   NUMBER,
				 x_usage_code        VARCHAR2) IS
    bsv		VARCHAR2(25);

  BEGIN
    IF (fnd_flex_keyval.validate_ccid('SQLGL',
				      'GL#',
				      x_chart_of_accounts_id,
				      x_ccid,
				      'GL_BALANCING') = TRUE) THEN
    	bsv := fnd_flex_keyval.concatenated_values;
    ELSE
	fnd_message.set_name('SQLGL', fnd_flex_keyval.encoded_error_message);
	app_exception.raise_exception;
    END IF;

    UPDATE GL_TRANSLATION_STATUSES TS
       SET TS.status  		= 'U',
           TS.LAST_UPDATE_DATE  = sysdate,
           TS.LAST_UPDATED_BY   = x_last_updated_by
     WHERE TS.LEDGER_ID                = x_ledger_id
       AND TS.BAL_SEG_VALUE            = bsv
       AND TS.TARGET_CURRENCY          = x_currency
       AND TS.AVERAGE_TRANSLATION_FLAG = decode(x_usage_code, 'A', 'Y', 'N')
       AND TS.ACTUAL_FLAG              = 'A'
       AND TS.period_name IN
	   ( SELECT PS.period_name
	     FROM   GL_PERIOD_STATUSES PS
	     WHERE  PS.application_id       = 101
	     AND    PS.ledger_id      = x_ledger_id
	     AND    PS.effective_period_num >=
                    (x_period_year * 10000 + x_period_num));

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_TRANS_STATUS_PKG.set_translation_status');
      RAISE;

  END set_translation_status;

END GL_TRANS_STATUSES_PKG;

/
