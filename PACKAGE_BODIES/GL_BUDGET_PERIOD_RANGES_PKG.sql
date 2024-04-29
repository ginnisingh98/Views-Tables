--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_PERIOD_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_PERIOD_RANGES_PKG" AS
/* $Header: glibprab.pls 120.3 2005/05/05 01:03:09 kvora ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE get_open_flag     (x_budget_version_id      NUMBER,
			       x_period_year		NUMBER,
			       x_open_flag   IN OUT NOCOPY	VARCHAR2) IS

    CURSOR get_open_flag IS
      SELECT open_flag
      FROM   gl_budget_period_ranges
      WHERE  budget_version_id = x_budget_version_id
      AND    period_year       = x_period_year;
  BEGIN
    OPEN get_open_flag;
    FETCH get_open_flag INTO x_open_flag;
    CLOSE get_open_flag;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_budget_period_ranges.get_open_flag');
      RAISE;
END get_open_flag;


END gl_budget_period_ranges_pkg;

/
