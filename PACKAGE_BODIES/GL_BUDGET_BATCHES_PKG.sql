--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_BATCHES_PKG" AS
/* $Header: glibdbtb.pls 120.6 2005/05/05 01:00:59 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE insert_budget(
  			x_budget_version_id	NUMBER,
			x_ledger_id             NUMBER,
			x_last_updated_by	NUMBER) IS

  BEGIN

    INSERT INTO GL_BUDGET_BATCHES
      (budget_version_id, recurring_batch_id,
       status, last_update_date, last_updated_by)
    SELECT
      x_budget_version_id, recurring_batch_id,
      'U', sysdate, x_last_updated_by
    FROM  gl_recurring_batches
    WHERE budget_flag = 'Y'
    AND   ledger_id = x_ledger_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_batches_pkg.insert_budget');
      RAISE;
  END insert_budget;



  PROCEDURE insert_recurring(
                        x_recurring_batch_id    NUMBER,
                        x_last_updated_by       NUMBER) IS

  BEGIN

    INSERT INTO GL_BUDGET_BATCHES
      (budget_version_id, recurring_batch_id,
       status, last_update_date, last_updated_by)
    SELECT
      budget_version_id, x_recurring_batch_id,
      'U', sysdate, x_last_updated_by
    FROM  gl_budget_versions;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_batches_pkg.insert_recurring');
      RAISE;
  END insert_recurring;



  PROCEDURE delete_recurring(
                        x_recurring_batch_id    NUMBER ) IS

  BEGIN

    DELETE
    FROM   gl_budget_batches
    WHERE  recurring_batch_id = x_recurring_batch_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_batches_pkg.delete_recurring');
      RAISE;
  END delete_recurring;



  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_budget_batches%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_budget_batches
    WHERE   budget_version_id = recinfo.budget_version_id
    AND     recurring_batch_id = recinfo.recurring_batch_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_batches_pkg.select_row');
      RAISE;
  END select_row;



  PROCEDURE select_columns(
    x_budget_version_id                 NUMBER,
    x_recurring_batch_id                NUMBER,
    x_last_executed_date                IN OUT NOCOPY  DATE,
    x_last_executed_start_period        IN OUT NOCOPY  VARCHAR2,
    x_last_executed_end_period          IN OUT NOCOPY  VARCHAR2,
    x_status                            IN OUT NOCOPY  VARCHAR2 )  IS

    recinfo gl_budget_batches%ROWTYPE;

  BEGIN
    recinfo.budget_version_id := x_budget_version_id;
    recinfo.recurring_batch_id := x_recurring_batch_id;
    select_row( recinfo );

    x_last_executed_date := recinfo.last_executed_date;
    x_last_executed_start_period := recinfo.last_executed_start_period;
    x_last_executed_end_period := recinfo.last_executed_end_period;
    x_status := recinfo.status;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_batches_pkg.select_columns');
      RAISE;
  END select_columns;




END gl_budget_batches_pkg;

/
