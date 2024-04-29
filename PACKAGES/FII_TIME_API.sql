--------------------------------------------------------
--  DDL for Package FII_TIME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_TIME_API" AUTHID CURRENT_USER AS
/* $Header: FIICAT1S.pls 115.8 2003/06/13 23:32:30 pslau noship $  */

-- -------------------------------------------------------------------
-- Name: global_start_date
-- Desc: Returns the global start date of the
--       enterprise calendar.  Info is cached after initial access
-- Output: Global Start Date of the enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function global_start_date return DATE;

-- -------------------------------------------------------------------
-- Name: global_end_date
-- Desc: Returns the global end date of the
--       enterprise calendar.  Info is cached after initial access
-- Output: Global End Date of the enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function global_end_date return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lyr_beg
-- Desc: Returns the same day last year, count from year start date in the
--       enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lyr_beg(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lyr_end
-- Desc: Returns the same day last year, count from year end date in the
--       enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lyr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysqtr_beg
-- Desc: Returns the same day last year same quarter, count from quarter start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same quarter in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysqtr_beg(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysqtr_end
-- Desc: Returns the same day last year same quarter, count from quarter end
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same quarter in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysqtr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_pqtr_beg
-- Desc: Returns the same day prior quarter, count from quarter start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise quarter.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pqtr_beg(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_pqtr_end
-- Desc: Returns the same day prior quarter, count from quarter end date
--       in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise quarter.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pqtr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysper_beg
-- Desc: Returns the same day last year same period, count from period start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same period in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysper_beg(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysper_end
-- Desc: Returns the same day last year same period, count from period end
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same period in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysper_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_pper_beg
-- Desc: Returns the same day prior period, count from period start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise period.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pper_beg(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_sd_pper_end
-- Desc: Returns the same day prior period, count from period end date
--       in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise period.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pper_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: sd_lyswk
-- Desc: Returns the same day last year same week in the enterprise calendar.
--       Info is cached after initial access
-- Output: Same date(as the pass in date) same week in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function sd_lyswk(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: sd_pwk
-- Desc: Returns the same day prior week in the enterprise calendar.
--       Info is cached after initial access
-- Output: Same date(as the pass in date) in prior week.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function sd_pwk(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cyr_start
-- Desc: Returns current enterprise year start date.
--       Info is cached after initial access
-- Output: Current Enterprise year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cyr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cyr_end
-- Desc: Returns current enterprise year end date.
--       Info is cached after initial access
-- Output: Current Enterprise year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cyr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pyr_start
-- Desc: Returns previous enterprise year start date.
--       Info is cached after initial access
-- Output: Previous Enterprise year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pyr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pyr_end
-- Desc: Returns previous enterprise year end date.
--       Info is cached after initial access
-- Output: Previous Enterprise year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pyr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cqtr_start
-- Desc: Returns current enterprise quarter start date.
--       Info is cached after initial access
-- Output: Current Enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cqtr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cqtr_end
-- Desc: Returns current enterprise quarter end date.
--       Info is cached after initial access
-- Output: Current Enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cqtr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lysqtr_start
-- Desc: Returns start date of same enterprise quarter in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysqtr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lysqtr_end
-- Desc: Returns end date of same enterprise quarter in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysqtr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pqtr_start
-- Desc: Returns previous enterprise quarter start date.
--       Info is cached after initial access
-- Output: Previous enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pqtr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pqtr_end
-- Desc: Returns previous enterprise quarter end date.
--       Info is cached after initial access
-- Output: Previous enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pqtr_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cper_start
-- Desc: Returns current enterprise period start date.
--       Info is cached after initial access
-- Output: Current Enterprise period start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cper_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cper_end
-- Desc: Returns current enterprise period end date.
--       Info is cached after initial access
-- Output: Current Enterprise period end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cper_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lysper_start
-- Desc: Returns start date of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lysper_end
-- Desc: Returns end date of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pper_start
-- Desc: Returns previous enterprise period start date.
--       Info is cached after initial access
-- Output: Previous enterprise period start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pper_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ent_pper_end
-- Desc: Returns previous enterprise period end date.
--       Info is cached after initial access
-- Output: Previous enterprise period end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_pper_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: cwk_start
-- Desc: Returns current week start date.
--       Info is cached after initial access
-- Output: Current Week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function cwk_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: cwk_end
-- Desc: Returns current week end date.
--       Info is cached after initial access
-- Output: Current Week end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function cwk_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: lyswk_start
-- Desc: Returns start date of same week in previous year.
--       Info is cached after initial access
-- Output: Last year same week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function lyswk_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: lyswk_end
-- Desc: Returns end date of same week in previous year.
--       Info is cached after initial access
-- Output: Last year same week end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function lyswk_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: pwk_start
-- Desc: Returns previous week start date.
--       Info is cached after initial access
-- Output: Previous Week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function pwk_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: pwk_end
-- Desc: Returns previous week end date.
--       Info is cached after initial access
-- Output: Previous Week end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function pwk_end(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: rmth_start
-- Desc: Returns rolling month start date.
--       Info is cached after initial access
-- Output: Rolling Month start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rmth_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: rqtr_start
-- Desc: Returns rolling quarter start date.
--       Info is cached after initial access
-- Output: Rolling Quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rqtr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: ryr_start
-- Desc: Returns rolling year start date.
--       Info is cached after initial access
-- Output: Rolling Year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ryr_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: rwk_start
-- Desc: Returns rolling week start date.
--       Info is cached after initial access
-- Output: Rolling Week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rwk_start(as_of_date date) return DATE;

-- -------------------------------------------------------------------
-- Name: day_left_in_qtr
-- Desc: Returns number of days left in a quarter in a specific format.
--       Info is cached after initial access
-- Output: Number of days left in a quarter. e.g. given 08-Apr-2002, it returns
--         Q4 FY02 Day: -54
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function day_left_in_qtr(as_of_date date) return varchar2;

-- -------------------------------------------------------------------
-- Name: ent_lysper_id
-- Desc: Returns ID of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period id
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_id(id number) return NUMBER;

PRAGMA RESTRICT_REFERENCES (global_start_date, WNDS);
PRAGMA RESTRICT_REFERENCES (global_end_date, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lyr_beg, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lyr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lysqtr_beg, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lysqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_pqtr_beg, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_pqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lysper_beg, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_lysper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_pper_beg, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_sd_pper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (sd_lyswk, WNDS);
PRAGMA RESTRICT_REFERENCES (sd_pwk, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cyr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cyr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pyr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pyr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lysqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lysqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cper_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lysper_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lysper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pper_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_pper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (cwk_start, WNDS);
PRAGMA RESTRICT_REFERENCES (cwk_end, WNDS);
PRAGMA RESTRICT_REFERENCES (lyswk_start, WNDS);
PRAGMA RESTRICT_REFERENCES (lyswk_end, WNDS);
PRAGMA RESTRICT_REFERENCES (pwk_start, WNDS);
PRAGMA RESTRICT_REFERENCES (pwk_end, WNDS);
PRAGMA RESTRICT_REFERENCES (rmth_start, WNDS);
PRAGMA RESTRICT_REFERENCES (rqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ryr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (rwk_start, WNDS);
PRAGMA RESTRICT_REFERENCES (day_left_in_qtr, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lysper_id, WNDS);


-- -------------------------------------------------------------------
-- Name: check_missing_date
-- Desc: Check if there is any missing date in the time dimension
--       for the range (via two input parameters): (from_date, to_date).
--       It returns one boolean: has_missing_date
--       It also prints out message in the output file if there's gap;
--       in particular, the minimum and maximum of these missing dates.
--       This procedure requires the setup of files and directory
--       for fnd_file.
-- Output: true/false
-- Error: If any sql error occurs, will report it to the log file;
--        and an exception is raised.
-- --------------------------------------------------------------------
procedure check_missing_date (p_from_date        IN  date,
                              p_to_date          IN  date,
                              p_has_missing_date OUT NOCOPY boolean);


-- -------------------------------------------------------------------
-- Name: check_missing_date (overloaded version)
-- Desc: Check if there is any missing date in the time dimension
--       for the range (via two input parameters): (from_date, to_date).
--       It returns three output parameters: has_missing_date,
--       min_missing_date, max_missing_date.
--       No output will be generated.
-- Error: If any sql error occurs, will report it to the log file;
--        and an exception is raised.
-- --------------------------------------------------------------------
Procedure check_missing_date (p_from_date        IN  date,
                              p_to_date          IN  date,
                              p_has_missing_date OUT NOCOPY boolean,
                              p_min_missing_date OUT NOCOPY date,
                              p_max_missing_date OUT NOCOPY date);

-----------------------------------------------------------------------
----- Following 5 APIs are from PJI team

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lyr_end
 -- Desc: Returns the same day last year, count from year end date in the
 --       financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lyr_end(as_of_date date, p_calendar_id number) return DATE;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lysqtr_end
 -- Desc: Returns the same day last year same quarter, count from quarter end
 --       date in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) same quarter in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lysqtr_end(as_of_date date, p_calendar_id number) return DATE;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lysper_end
 -- Desc: Returns the same day last year same period, count from period end
 --       date in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) same period in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lysper_end(as_of_date date, p_calendar_id number) return DATE;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_pqtr_end
 -- Desc: Returns the same day prior quarter, count from quarter end date
 --       in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in prior financial quarter.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_pqtr_end(as_of_date date, p_calendar_id number) return DATE;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_pper_end
 -- Desc: Returns the same day prior period, count from period end date
 --       in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in prior financial period.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_pper_end(as_of_date date, p_calendar_id number) return DATE;

PRAGMA RESTRICT_REFERENCES (cal_sd_lyr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (cal_sd_lysqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (cal_sd_lysper_end, WNDS);
PRAGMA RESTRICT_REFERENCES (cal_sd_pqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (cal_sd_pper_end, WNDS);

------------------------------------------------------------------------

-- -------------------------------------------------------------------
-- Name: ent_rolling_start_date
-- Desc: Returns the start date of the first rolling period/quarter/year in
--       enterprise calendar.  Info is cached after initial access
-- Output: Start date of the first rolling period/quarter/year in enteprise calendar.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_rolling_start_date(as_of_date date, period_type varchar2) return DATE;

-- -------------------------------------------------------------------
-- Name: next_period_end_date
-- Desc: Returns the end date of the next week/period/quarter/year.
--       Info is cached after initial access
-- Output: End date of the next week/period/quarter/year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function next_period_end_date(as_of_date date, period_type varchar2) return DATE;

end;

 

/
