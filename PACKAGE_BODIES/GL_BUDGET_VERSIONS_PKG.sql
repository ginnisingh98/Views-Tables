--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_VERSIONS_PKG" AS
/* $Header: glibdveb.pls 120.3 2005/05/05 01:02:21 kvora ship $ */

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_budget_versions associated with
  --   the given budget.
  -- History
  --   01-NOV-94  D J Ogg  Created.
  -- Arguments
  --   recinfo 		A row from gl_budget_versions
  -- Example
  --   gl_budget_versions_pkg.select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_budget_versions%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_budget_versions
    WHERE   budget_version_id = recinfo.budget_version_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_versions.select_row');
      RAISE;
  END select_row;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE insert_record(
  			x_budget_version_id	NUMBER,
			x_budget_name           VARCHAR2,
			x_status		VARCHAR2,
			x_master_budget_ver_id  NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER) IS
  BEGIN

    INSERT INTO GL_BUDGET_VERSIONS
      (budget_version_id, budget_type, budget_name, version_num,
       description, status, date_opened, date_active, date_archived,
       creation_date, created_by, last_update_date, last_updated_by,
       last_update_login, control_budget_version_id)
    VALUES
      (x_budget_version_id, 'standard', x_budget_name, 1,
       'first version', x_status, sysdate, null, null,
       sysdate, x_last_updated_by, sysdate, x_last_updated_by,
       x_last_update_login, x_master_budget_ver_id);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_versions_pkg.insert_record');
      RAISE;
  END insert_record;


  PROCEDURE update_record(
  			x_budget_version_id	NUMBER,
			x_budget_name           VARCHAR2,
			x_status		VARCHAR2,
			x_master_budget_ver_id  NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER) IS
  BEGIN

    UPDATE gl_budget_versions
    SET   status      			= x_status,
          budget_name 			= x_budget_name,
          control_budget_version_id 	= x_master_budget_ver_id,
 	  last_update_date 		= sysdate,
	  last_updated_by		= x_last_updated_by,
	  last_update_login		= x_last_update_login
    WHERE budget_version_id = x_budget_version_id;

  exception
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_versions_pkg.update_record');
      RAISE;
  END update_record;

  PROCEDURE select_columns(
              x_budget_version_id			NUMBER,
	      x_budget_name			IN OUT NOCOPY  VARCHAR2 ) IS

    recinfo gl_budget_versions%ROWTYPE;

  BEGIN
    recinfo.budget_version_id := x_budget_version_id;
    select_row( recinfo );
    x_budget_name := recinfo.budget_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_encumbrance_types.select_columns');
      RAISE;
  END select_columns;


END gl_budget_versions_pkg;

/
