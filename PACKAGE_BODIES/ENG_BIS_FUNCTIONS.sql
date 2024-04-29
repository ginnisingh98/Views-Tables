--------------------------------------------------------
--  DDL for Package Body ENG_BIS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_BIS_FUNCTIONS" AS
/* $Header: engbisfb.pls 115.1 2002/02/06 19:36:31 skagarwa ship $ */

/*
 * GetWorkdaysBetween
 *
 *   This function calculates the number of mfg
 *   workdays between a start date and an end
 *   date for a particular organization.
 */
FUNCTION GetWorkdaysBetween(p_organization_id  NUMBER,
			    p_start_date       DATE,
	 		    p_end_date	       DATE) RETURN number IS

   l_days		NUMBER;
   l_calendar_code      VARCHAR2(10);
   l_exception_set_id	NUMBER;


   CURSOR GetCalendarInfo IS
      SELECT calendar_code, calendar_exception_set_id
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;

BEGIN
   FOR c1 IN GetCalendarInfo LOOP
      l_calendar_code := c1.calendar_code;
      l_exception_set_id := c1.calendar_exception_set_id;
   END LOOP;

   SELECT count(*)
     INTO l_days
     FROM bom_calendar_dates
    WHERE calendar_code = l_calendar_code
      AND exception_set_id = l_exception_set_id
      AND calendar_date between p_start_date and p_end_date
      AND seq_num is not null;

   RETURN l_days;

END GetWorkdaysBetween;

END ENG_BIS_FUNCTIONS;

/
