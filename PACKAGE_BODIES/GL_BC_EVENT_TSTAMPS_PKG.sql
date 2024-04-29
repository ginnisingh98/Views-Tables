--------------------------------------------------------
--  DDL for Package Body GL_BC_EVENT_TSTAMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_EVENT_TSTAMPS_PKG" AS
/* $Header: glibcetb.pls 120.2 2005/05/05 00:59:13 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE insert_event_timestamp(
			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2,
			x_last_updated_by	NUMBER,
                        x_last_update_login     NUMBER) IS

  BEGIN

    INSERT INTO GL_BC_EVENT_TIMESTAMPS
          (chart_of_accounts_id, event_code, date_timestamp,
           last_update_date, last_updated_by,
           creation_date, created_by,
           last_update_login)
    SELECT x_chart_of_accounts_id, x_event_code, sysdate,
           sysdate, x_last_updated_by,
           sysdate, x_last_updated_by,
           x_last_update_login
    FROM fnd_dual
    WHERE rownum = 1
    AND NOT EXISTS
          (SELECT 'row already exists'
           FROM gl_bc_event_timestamps
           WHERE chart_of_accounts_id = x_chart_of_accounts_id
           AND   event_code = x_event_code);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE',
        'gl_bc_event_tstamps_pkg.insert_event_timestamp');
      RAISE;
  END insert_event_timestamp;

  PROCEDURE set_event_timestamp(
  			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2,
			x_last_updated_by	NUMBER,
                        x_last_update_login     NUMBER) IS

  BEGIN

    UPDATE gl_bc_event_timestamps
    SET  date_timestamp    = sysdate,
         last_update_date  = sysdate,
         last_updated_by   = x_last_updated_by,
         last_update_login = x_last_update_login
    WHERE chart_of_accounts_id = x_chart_of_accounts_id
    AND   event_code = x_event_code;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE',
        'gl_bc_event_tstamps_pkg.set_event_timestamp');
      RAISE;
  END set_event_timestamp;

  PROCEDURE lock_event_timestamp(
  			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2) IS
    CURSOR lock_stamp is
      SELECT 'Locked stamp'
      FROM   GL_BC_EVENT_TIMESTAMPS
      WHERE  chart_of_accounts_id = x_chart_of_accounts_id
      AND    event_code = x_event_code
      FOR UPDATE OF date_timestamp;
    dummy VARCHAR2(100);
  BEGIN

    OPEN lock_stamp;
    FETCH lock_stamp INTO dummy;

    IF NOT lock_stamp%FOUND THEN
      CLOSE lock_stamp;
      fnd_message.set_name('SQLGL', 'GL_BC_CANNOT_LOCK_STAMP');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE',
        'gl_bc_event_tstamps_pkg.lock_timestamp');
      RAISE;
  END lock_event_timestamp;

END gl_bc_event_tstamps_pkg;

/
