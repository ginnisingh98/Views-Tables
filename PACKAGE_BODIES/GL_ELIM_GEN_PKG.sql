--------------------------------------------------------
--  DDL for Package Body GL_ELIM_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ELIM_GEN_PKG" AS
/* $Header: glelgenb.pls 120.4 2005/05/05 02:03:41 kvora ship $ */

    -------------------------------------------------------------
    PROCEDURE set_data (        X_period_start  DATE,
                                X_period_end    DATE) IS
    BEGIN
	GL_ELIM_GEN_PKG.period_start_date := X_period_start;
	GL_ELIM_GEN_PKG.period_end_date := X_period_end;
    END set_data;

    -------------------------------------------------------------
    FUNCTION get_period_start_date
    RETURN DATE IS
    BEGIN
	return GL_ELIM_GEN_PKG.period_start_date;
    END get_period_start_date;

    -------------------------------------------------------------
    FUNCTION get_period_end_date
    RETURN DATE IS
    BEGIN
	return GL_ELIM_GEN_PKG.period_end_date;
    END get_period_end_date;

    -------------------------------------------------------------
    PROCEDURE insert_elim_history (
                X_request_id            NUMBER,
                X_elimination_set_id    NUMBER,
                X_ledger_id      	NUMBER,
                X_period_name           VARCHAR2
    ) IS
    elim_run_id   NUMBER;
    BEGIN
	LOCK TABLE GL_ELIMINATION_HISTORY IN SHARE UPDATE MODE;

        SELECT GL_ELIM_HISTORY_S.nextval
          INTO elim_run_id
          FROM dual;

	INSERT INTO gl_elimination_history
	(
                elimination_run_id,
		request_id,
		elimination_set_id,
		ledger_id,
		status_code,
		period_name,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login
	)
    	VALUES
	(
                elim_run_id,
		X_request_id,
		X_elimination_set_id,
		X_ledger_id,
		'GS',
		X_period_name,
		SYSDATE,
		to_number(fnd_profile.value('USER_ID')),
		SYSDATE,
		to_number(fnd_profile.value('USER_ID')),
		to_number(fnd_profile.value('LOGIN_ID'))
	);

	EXCEPTION
    	   WHEN app_exceptions.application_exception THEN
      		RAISE;
    	   WHEN OTHERS THEN
      		fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      		fnd_message.set_token('PROCEDURE',
        		'GL_ELIM_GEN_PKG.insert_elim_history');
      	   RAISE;
    END insert_elim_history;

    -------------------------------------------------------------

    PROCEDURE save_to_elim_hist IS
    BEGIN
	commit;
    END save_to_elim_hist;

    -------------------------------------------------------------
END GL_ELIM_GEN_PKG;

/
