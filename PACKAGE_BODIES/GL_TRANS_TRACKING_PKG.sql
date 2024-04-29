--------------------------------------------------------
--  DDL for Package Body GL_TRANS_TRACKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANS_TRACKING_PKG" AS
/*  $Header: glitrtkb.pls 120.3 2005/05/05 01:29:11 kvora ship $  */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE set_outdated_period( x_chart_of_accounts_id NUMBER,
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

    UPDATE GL_TRANSLATION_TRACKING trtrk
       SET trtrk.FIRST_OUTDATED_EFF_PERIOD_NUM =
		 x_period_year * 10000 + x_period_num,
	   trtrk.FIRST_OUTDATED_PERIOD_NAME = x_period_name,
           trtrk.LAST_UPDATE_DATE = SYSDATE,
           trtrk.LAST_UPDATED_BY = x_last_updated_by
     WHERE trtrk.LEDGER_ID = x_ledger_id
       AND trtrk.BAL_SEG_VALUE = bsv
       AND trtrk.TARGET_CURRENCY= x_currency
       AND trtrk.AVERAGE_TRANSLATION_FLAG = 'Y'
       AND trtrk.ACTUAL_FLAG = 'A'
       AND trtrk.FIRST_OUTDATED_EFF_PERIOD_NUM >
           (x_period_year * 10000 + x_period_num);

     GL_TRANS_STATUSES_PKG.set_translation_status( x_chart_of_accounts_id ,
				 x_ccid	             ,
				 x_ledger_id         ,
                                 x_currency          ,
                                 x_period_year       ,
                                 x_period_num        ,
				 x_period_name	     ,
                                 x_last_updated_by   ,
				 x_usage_code );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_TRANS_TRACKING_PKG.set_outdated_period');
      RAISE;

  END set_outdated_period;



END GL_TRANS_TRACKING_PKG;

/
