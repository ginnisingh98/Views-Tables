--------------------------------------------------------
--  DDL for Package Body CEFC_VIEW_CONST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CEFC_VIEW_CONST" AS
/* $Header: cefcvieb.pls 120.1 2002/11/12 21:21:35 bhchung ship $ */

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_header_id							|
|                                                                       |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/

PROCEDURE set_header_id (pn_header_id IN NUMBER) IS
BEGIN
  pg_header_id := pn_header_id;
END set_header_id;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_header_id							|
|                                                                       |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_header_id RETURN NUMBER IS
BEGIN
  return pg_header_id;
END get_header_id;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_start_period_name						|
|                                                                       |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
PROCEDURE set_start_period_name (pd_start_period_name IN VARCHAR2) IS
BEGIN
  pg_start_period_name := pd_start_period_name;
END set_start_period_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_start_period_name						|
|                                                                       |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_start_period_name RETURN VARCHAR2 IS
BEGIN
  return pg_start_period_name;
end get_start_period_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_period_set_name				                |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/

PROCEDURE set_period_set_name (pd_period_set_name IN VARCHAR2) IS
BEGIN
  pg_period_set_name := pd_period_set_name;
END set_period_set_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_period_set_name				                |
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_period_set_name RETURN VARCHAR2 IS
BEGIN
  return pg_period_set_name;
end get_period_set_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_rowid							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
PROCEDURE set_rowid (pd_rowid IN VARCHAR2) IS
BEGIN
  pg_rowid := pd_rowid;
END set_rowid;
/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_rowid							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_rowid RETURN VARCHAR2 IS
BEGIN
  return pg_rowid;
end get_rowid;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_start_date							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
PROCEDURE set_start_date (pn_start_date IN DATE) IS
BEGIN
  pg_start_date := pn_start_date;
END set_start_date;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_start_date							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_start_date RETURN DATE IS
BEGIN
  return pg_start_date;
end get_start_date;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_min_col							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
PROCEDURE set_min_col (pn_min_col IN NUMBER) IS
BEGIN
  pg_min_col := pn_min_col;
END set_min_col;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_min_col							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_min_col RETURN NUMBER IS
BEGIN
  return pg_min_col;
end get_min_col;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_max_col							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
PROCEDURE set_max_col (pn_max_col IN NUMBER) IS
BEGIN
  pg_max_col := pn_max_col;
END set_max_col;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_max_col							|
|									|
|									|
|  DESCRIPTION                                                          |
|									|
|                                                                       |
|  HISTORY                                                              |
|       01-AUG-96    bcarrol     Created                 		|
 -----------------------------------------------------------------------*/
FUNCTION get_max_col RETURN NUMBER IS
BEGIN
  return pg_max_col;
end get_max_col;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      get_max_col                                                      |
|                                                                       |
|                                                                       |
|  DESCRIPTION                                                          |
|                                                                       |
|                                                                       |
|  HISTORY                                                              |
|       10-NOV-97 	wychan	Created					|
 -----------------------------------------------------------------------*/
PROCEDURE set_constants(pn_header_id    	IN NUMBER,
                        pn_period_set_name      IN VARCHAR2,
                        pn_start_period         IN VARCHAR2,
                        pn_start_date           IN DATE,
			pn_min_col		IN NUMBER DEFAULT NULL,
			pn_max_col		IN NUMBER DEFAULT NULL) IS
  p_max_col             NUMBER;
  p_min_col             NUMBER;
  p_period_start_date   DATE;
  p_aging_type          VARCHAR2(10);
  p_period_type		VARCHAR2(15);
BEGIN
  pg_header_id := pn_header_id;
  pg_start_date := pn_start_date;
  pg_period_set_name := pn_period_set_name;
  pg_start_period_name := pn_start_period;

  IF(pn_min_col IS NOT NULL AND pn_max_col IS NOT NULL)THEN
    pg_min_col := pn_min_col;
    pg_max_col := pn_max_col;
  ELSE
    SELECT        aging_type
    INTO          p_aging_type
    FROM          ce_forecast_headers
    WHERE         forecast_header_id = pn_header_id;

    IF(p_aging_type = 'D')THEN
      p_max_col := 3442447 - to_number(to_char(pn_start_date,'J')) + 1;
      p_min_col := to_number(to_char(pn_start_date,'J')) - 2;

    ELSE
      SELECT      start_date, period_type
      INTO        p_period_start_date, p_period_type
      FROM        gl_periods
      WHERE       period_set_name = pn_period_set_name    AND
                  period_name = pn_start_period;

      SELECT      count(*)
      INTO        p_max_col
      FROM        gl_periods
      WHERE       period_set_name = pn_period_set_name       	AND
		  period_type = p_period_type			AND
                  start_date >= p_period_start_date;

      SELECT      count(*)
      INTO        p_min_col
      FROM        gl_periods
      WHERE       period_set_name = pn_period_set_name       	AND
		  period_type = p_period_type			AND
                  start_date < p_period_start_date;

    END IF;

    pg_min_col := -p_min_col+1;
    pg_max_col := p_max_col-1;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END set_constants;



END CEFC_VIEW_CONST;

/
