--------------------------------------------------------
--  DDL for Package Body GL_ENTITY_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ENTITY_BUDGETS_PKG" AS
/* $Header: glibdebb.pls 120.3 2005/05/05 01:01:31 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE insert_budget(
  			x_budget_version_id	NUMBER,
			x_ledger_id      	NUMBER,
			x_last_updated_by	NUMBER,
                        x_last_update_login     NUMBER) IS

  BEGIN

    INSERT INTO GL_ENTITY_BUDGETS
      (budget_entity_id, budget_version_id, frozen_flag,
       created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
    SELECT be.budget_entity_id, x_budget_version_id, 'N',
           x_last_updated_by, sysdate,
 	   x_last_updated_by, sysdate, x_last_update_login
    FROM  gl_budget_entities be
    WHERE ledger_id = x_ledger_id
    AND   status_code <> 'D';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_entity_budgets_pkg.insert_budget');
      RAISE;
  END insert_budget;

  PROCEDURE insert_entity(
  			x_budget_entity_id	NUMBER,
			x_ledger_id      	NUMBER,
			x_last_updated_by	NUMBER,
                        x_last_update_login     NUMBER) IS

  BEGIN

    INSERT INTO GL_ENTITY_BUDGETS
      (budget_entity_id, budget_version_id, frozen_flag,
       created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
    SELECT x_budget_entity_id, bv.budget_version_id, 'N',
           x_last_updated_by, sysdate,
 	   x_last_updated_by, sysdate, x_last_update_login
    FROM  gl_budgets b, gl_budget_versions bv
    WHERE b.ledger_id = x_ledger_id
    AND   bv.budget_name = b.budget_name
    AND   bv.budget_type = b.budget_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_entity_budgets_pkg.insert_entity');
      RAISE;
  END insert_entity;

END gl_entity_budgets_pkg;

/
