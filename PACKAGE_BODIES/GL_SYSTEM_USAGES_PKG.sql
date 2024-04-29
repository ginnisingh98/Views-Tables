--------------------------------------------------------
--  DDL for Package Body GL_SYSTEM_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SYSTEM_USAGES_PKG" AS
/* $Header: glistsub.pls 120.4 2005/05/05 01:24:19 kvora ship $ */

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_system_usages
  -- History
  --   11-DEC-1995  D J Ogg  Created.
  -- Arguments
  --   recinfo gl_system_usages
  -- Example
  --   select_row.recinfo;
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_system_usages%ROWTYPE ) IS
    CURSOR usages IS
      SELECT  *
      FROM    gl_system_usages;
  BEGIN

    OPEN usages;
    FETCH usages INTO recinfo;

    IF usages%FOUND THEN
      CLOSE usages;
    ELSE
      CLOSE usages;
      RAISE NO_DATA_FOUND;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_system_usages_pkg.select_row');
      RAISE;
  END select_row;

  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE select_columns(
              x_average_balances_flag		IN OUT NOCOPY  VARCHAR2,
              x_consolidation_ledger_flag       IN OUT NOCOPY  VARCHAR2) IS

    recinfo gl_system_usages%ROWTYPE;

  BEGIN
    select_row( recinfo );
    x_average_balances_flag := recinfo.average_balances_flag;
    x_consolidation_ledger_flag := recinfo.consolidation_ledger_flag;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_system_usages_pkg.select_columns');
      RAISE;
  END select_columns;

END gl_system_usages_pkg;

/
