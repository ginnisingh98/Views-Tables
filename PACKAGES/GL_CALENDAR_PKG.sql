--------------------------------------------------------
--  DDL for Package GL_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CALENDAR_PKG" AUTHID CURRENT_USER as
/* $Header: glustcls.pls 120.1 2005/05/05 01:44:05 kvora noship $ */

--
-- Package
--   GL_CALENDAR_PKG
-- Purpose
--   Various utilities for working with GL calendars.  These
--   utilities are available for use by other teams within
--   Oracle Applications.  They are not available for customization
--   purposes.
-- History
--   23-DEC-2004  D J Ogg          Created.
--

  -- Valid values for return_code
  success      CONSTANT VARCHAR2(30) := 'SUCCESS';
  bad_start    CONSTANT VARCHAR2(30) := 'BAD_START';
  bad_end      CONSTANT VARCHAR2(30) := 'BAD_END';
  unmapped_day CONSTANT VARCHAR2(30) := 'UNMAPPED_DAY';

  --
  -- Procedure
  --   Get_Num_Periods_In_Date_Range
  -- Purpose
  --   Takes a calendar, period type, start date, and end date.
  --   Determines the number of non-adjustment periods in the
  --   given calendar with the given period type that contain
  --   dates within the given range.  Returns the resulting value
  --   in num_periods and the status in return_code.
  --
  --   If the check_missing parameter is true,
  --   this routine will check all of the dates within the
  --   range to determine if they are associated with a
  --   nonadjustment period.  If any are not associated with a
  --   nonadjustment period, a return_code of UNMAPPED_DAY will be
  --   returned and the unmapped day will be returned in
  --   unmapped_date.
  --
  --   Possible values for return_code:
  --     SUCCESS      - routine was successfully executed.
  --     BAD_START    - the start date is not associated with any
  --                    nonadjustment period
  --     BAD_END      - the end date is not associated with any
  --                    nonadjustment period
  --     UNMAPPED_DAY - there is one or more dates within the date
  --                    range that is not associated with any
  --                    adjustment period.
  -- History
  --   23-DEC-2004  D. J. Ogg    Created
  -- Arguments
  --   calendar_name	Calendar to check
  --   period_type	Type of period within the calendar to check
  --   start_date	First date in the range
  --   end_date         Last date in the range
  --   check_missing    Indicates whether or not to check that all
  --                    dates within the range are associated with a
  --                    nonadjustment period.
  --   num_periods      Number of periods that contain dates in the range
  --   return_code      Return status
  --   unmapped_date    In the case of a return_code of BAD_START,
  --                    BAD_END, or UNMAPPED_DAY, contains the day or
  --                    one of the days that are unmapped.
  -- Example
  --   gl_calendar_pkg.get_num_periods_in_date_range(
  --      'Accounting'
  --      'Month',
  --      '15-Jan-2004',
  --      '31-Mar-2004',
  --      TRUE,
  --      number_of_periods,
  --      return_code,
  --      bad_day);
  -- Notes
  --
  PROCEDURE get_num_periods_in_date_range(
                         calendar_name 			VARCHAR2,
                         period_type 			VARCHAR2,
                         start_date			DATE,
                         end_date			DATE,
			 check_missing			BOOLEAN,
			 num_periods	   OUT NOCOPY   NUMBER,
			 return_code       OUT NOCOPY   VARCHAR2,
			 unmapped_date     OUT NOCOPY   DATE);

END GL_CALENDAR_PKG;

 

/
