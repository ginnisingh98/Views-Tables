--------------------------------------------------------
--  DDL for Package Body GL_CONS_WRK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_WRK_PKG" AS
/* $Header: glcowrkb.pls 120.5 2005/05/05 02:02:49 kvora ship $ */
        PROCEDURE set_data (X_period     	VARCHAR2,
			    X_access_set_id     NUMBER) IS
	BEGIN
		GL_CONS_WRK_PKG.period := X_period;
		GL_CONS_WRK_PKG.access_set_id := X_access_set_id;
        END set_data;

	FUNCTION	get_period	RETURN VARCHAR2 IS
        BEGIN
                RETURN GL_CONS_WRK_PKG.period;
        END get_period;

	FUNCTION	get_access_set_id	RETURN NUMBER IS
        BEGIN
                RETURN GL_CONS_WRK_PKG.access_set_id;
        END get_access_set_id;


	FUNCTION	submit_request	(
		X_average_translation_flag	VARCHAR2,
		X_ledger_id			NUMBER,
		X_currency_code			VARCHAR2,
		X_period			VARCHAR2,
		X_balance_type			VARCHAR2,
		X_balancing_segment_value	VARCHAR2,
		X_source_budget_version_id	NUMBER,
		X_target_budget_version_id	NUMBER,
		X_access_set_id			NUMBER,
		X_chart_of_accounts_id		NUMBER,
		X_avg_rate_type			VARCHAR2,
		X_eop_rate_type			VARCHAR2,
		X_ledger_short_name		VARCHAR2) RETURN NUMBER IS
	   ret_code	NUMBER;
        BEGIN
	   IF (X_average_translation_flag = 'N') THEN
	       ret_code :=  FND_REQUEST.SUBMIT_REQUEST(
    		'SQLGL',
    		'GLTTRN',
    		'',
    		'',
    		FALSE,
		X_ledger_short_name,
		to_char(X_access_set_id),
		to_char(X_chart_of_accounts_id),
    		to_char(X_ledger_id),
    		X_currency_code,
    		X_period,
    		X_balance_type,
    		X_balancing_segment_value,
    		to_char(X_source_budget_version_id),
    		to_char(X_target_budget_version_id),
		X_avg_rate_type,
		X_eop_rate_type,
		'N',
    		chr(0),'','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','');
	   ELSE
  	       ret_code := FND_REQUEST.SUBMIT_REQUEST(
    		'SQLGL',
    		'GLTATR',
    		'',
    		'',
    		FALSE,
    		to_char(X_ledger_id),
    		X_currency_code,
    		X_period,
    		X_balancing_segment_value,
    		chr(0),'','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','');
	   END IF;
	   COMMIT;
	   RETURN (ret_code);
     	END submit_request;

	FUNCTION	get_translation_status	(
		X_ledger_id			NUMBER,
	        X_period_name			VARCHAR2,
		X_currency_code			VARCHAR2,
		X_actual_flag			VARCHAR2) RETURN VARCHAR2 IS
	ret_val VARCHAR2(2);
        BEGIN
		SELECT DECODE (MAX (STATUS),
			'C', 'C',
			'U', 'U', 'N')
		INTO ret_val
		FROM GL_TRANSLATION_STATUSES
		WHERE ledger_id = X_ledger_id
		AND   period_name = X_period_name
		AND   target_currency = X_currency_code
		AND   actual_flag = X_actual_flag;

		RETURN ret_val;
	END get_translation_status;

END GL_CONS_WRK_PKG;

/
