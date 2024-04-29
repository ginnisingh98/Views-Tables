--------------------------------------------------------
--  DDL for Package HR_BUDGET_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BUDGET_CALENDAR" AUTHID CURRENT_USER as
/* $Header: pybudcal.pkh 115.0 99/07/17 05:46:36 porting ship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hr_budget_calendar
  Purpose
    Maintains budgetary calendars ie. creates and removes time periods
    representing years of calendar.
  Notes
    Used by the PAYWSDCL (Define Budgetary Calendar) form.
  History
    11-Mar-94  J.S.Hobbs   40.0         Date created.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   midpoint_offset                                                       --
 -- Purpose                                                                 --
 --   Returns the midpoint offset used by a semi-monthly calendar.          --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   Used in the PAYWSDCL (Define Budgetary Calendar) form on post query   --
 --   to display the midpoint offset used in semi-monthly calendars.        --
 -----------------------------------------------------------------------------
--
 function midpoint_offset
 (
  p_period_set_name        varchar2,
  p_start_date             date
 ) return number;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   num_of_cal_yrs                                                        --
 -- Purpose                                                                 --
 --   Counts the number of calendar years that have already been created    --
 --   for a calendar.                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Used in the PAYWSDCL (Define Budgetary Calendar) form on post query   --
 --   to display the current number of calendar years created.              --
 -----------------------------------------------------------------------------
--
 function num_of_cal_yrs
 (
  p_period_set_name varchar2
 ) return number;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   gen_budget_calendar                                                   --
 -- Purpose                                                                 --
 --   Generates a number of years of time periods for a calendar.           --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure generate
 (
  p_period_set_name varchar2,
  p_midpoint_offset number,
  p_number_of_years number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   remove                                                                --
 -- Purpose                                                                 --
 --   Removes a number of years of time periods for a calendar.             --
 -- Arguments                                                               --
 --   p_number_of_years should be the number of calendar years that exist   --
 --   after the code has completed.                                         --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure remove
 (
  p_period_set_name   varchar2,
  p_number_of_years   number,
  p_at_least_one_year boolean
 );
--
end HR_BUDGET_CALENDAR;

 

/
