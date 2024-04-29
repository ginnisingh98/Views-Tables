--------------------------------------------------------
--  DDL for Package FII_TIME_WH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_TIME_WH_API" AUTHID CURRENT_USER AS
/* $Header: FIIQTRSS.pls 120.0 2002/08/24 05:01:09 appldev noship $  */
VERSION    CONSTANT CHAR(80) := '$Header: FIIQTRSS.pls 120.0 2002/08/24 05:01:09 appldev noship $';

-- -------------------------------------------------------------------
-- Name: ent_cycq_start
-- Desc: Returns quarter start date for current year current
--       quarter (cycq) in the enterprise calendar.  Current quarter
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cycq_start return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cycq_end
-- Desc: Returns quarter end date for current year current
--       quarter (cycq) in the enterprise calendar.  Current quarter
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cycq_end   return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lycq_start
-- Desc: Returns quarter start date for last year current quarter
--       (lycq) in the enterprise calendar.  Info is cached after
--       initial access
-- Output: Enterprise calendar last year same quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lycq_start return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lycq_end
-- Desc: Returns quarter end date for last year current quarter
--       (lycq) in the enterprise calendar.  Info is cached after
--       initial access
-- Output: Enterprise calendar last year same quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lycq_end   return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cy_start
-- Desc: Returns year start date for current year
--       in the enterprise calendar.  Current year
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cy_start return DATE;

-- -------------------------------------------------------------------
-- Name: ent_cy_end
-- Desc: Returns year end date for current year
--       in the enterprise calendar.  Current year
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cy_end return DATE;

-- -------------------------------------------------------------------
-- Name: ent_ly_start
-- Desc: Returns year start date for last year
--       in the enterprise calendar.  Last year
--       calculated based on sysdate - 12 months. Info is cached after initial access
-- Output: Enterprise calendar last year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_ly_start return DATE;

-- -------------------------------------------------------------------
-- Name: ent_ly_end
-- Desc: Returns year end date for last year
--       in the enterprise calendar.  Last year
--       calculated based on sysdate - 12 months. Info is cached after initial access
-- Output: Enterprise calendar last year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_ly_end return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lycq_today1
-- Desc: Returns today's equavalent day in the same quarter from last
--       year in the enterprise calendar.  The equavlent day is
--       established by counting backwards the same # of days from
--       the end of the quarter.  Info is cached after initial access
-- Output: Enterprise calendar last year same quarter today (variation 1)
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lycq_today1 return DATE;

-- -------------------------------------------------------------------
-- Name: ent_lycq_today1
-- Desc: Returns today's equavalent day in the same quarter from last
--       year in the enterprise calendar.  The equavlent day is
--       established by counting same # of days into the quarter from
--       the start of the quarter.  Info is cached after initial access
-- Output: Enterprise calendar last year same quarter today (variation 2)
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lycq_today2 return DATE;


-- -------------------------------------------------------------------
-- Name: today
-- Desc: Returns today's date, time element truncated.  If the profile
--       FII_FIXED_DATE is set, then it returns the fixed date.  Otherwise
--       it returnes sysdate
-- Output: Todays date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
FUNCTION today RETURN DATE;


-- -------------------------------------------------------------------
-- Name: todaytime
-- Desc: Returns today's date with time element.  If the profile
--       FII_FIXED_DATE is set, then it returns the fixed date.  Otherwise
--       it returnes sysdate
-- Output: Todays date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
FUNCTION todaytime RETURN DATE;


-- -------------------------------------------------------------------
-- Name: get_fqtr_start
-- Desc: Returns the smallest quarter start date for the current quarter
--       across all the financial and enterprise calendars.
-- Output: Minium quarter start date
-- Error: If any sql errors occurs during
--        execution, an exception is raised.
-- --------------------------------------------------------------------
Function get_fqtr_start return DATE;


-- -------------------------------------------------------------------
-- Name: get_fqtr_end
-- Desc: Returns the largest quarter end date for the current quarter
--       across all the financial and enterprise calendars.
-- Output: Maximum quarter start date
-- Error: If any sql errors occurs during
--        execution, an exception is raised.
-- --------------------------------------------------------------------
FUNCTION get_fqtr_end RETURN DATE;

-- -------------------------------------------------------------------
-- Name: get_curr_eqtr_start
-- Desc: Functional obsolete, kept for backward compatibility. Please
--       use ent_cycq_start instead
-- --------------------------------------------------------------------
Function get_curr_eqtr_start return DATE;

-- -------------------------------------------------------------------
-- Name: get_curr_eqtr_end
-- Desc: Functional obsolete, kept for backward compatibility. Please
--       use ent_cycq_end instead
-- --------------------------------------------------------------------
Function get_curr_eqtr_end return DATE;

-- -------------------------------------------------------------------
-- Name: get_cycq_pk_key
-- Desc: Returns the quarter pk key of the current quarter with the the earliest
--       start date
-- --------------------------------------------------------------------
Function get_cycq_pk_key return NUMBER;

-- -------------------------------------------------------------------
-- Name: get_cycm_pk_key
-- Desc: Returns the month pk key of the current month with the the earliest
--       start date
-- --------------------------------------------------------------------
Function get_cycm_pk_key return NUMBER;

-- -------------------------------------------------------------------
-- Name: ent_today
-- Desc: Getting either the profile date or today's date
-- --------------------------------------------------------------------
Function ent_today return DATE;


PRAGMA RESTRICT_REFERENCES (ent_cycq_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cycq_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lycq_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lycq_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cy_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_cy_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_ly_start, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_ly_end, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lycq_today1, WNDS);
PRAGMA RESTRICT_REFERENCES (ent_lycq_today2, WNDS);
PRAGMA RESTRICT_REFERENCES (today, WNDS);
PRAGMA RESTRICT_REFERENCES (todaytime, WNDS);
PRAGMA RESTRICT_REFERENCES (get_fqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_fqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (get_curr_eqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_curr_eqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cycq_pk_key, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cycm_pk_key, WNDS);



/* Future functions
Function fis_cycq_start(cal_name_pk_key NUMBER) return DATE;
Function fis_cycq_end(cal_name_pk_key   NUMBER) return DATE;
Function fis_lycq_start(cal_name_pk_key NUMBER) return DATE;
Function fis_lycq_end(cal_name_pk_key   NUMBER) return DATE;
Function fis_lycq_today1(cal_name_pk_key NUMBER) return DATE;
Function fis_lycq_today2(cal_name_pk_key NUMBER) return DATE;
*/



end;

 

/
