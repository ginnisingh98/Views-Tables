--------------------------------------------------------
--  DDL for Package POA_TIME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_TIME_API" AUTHID CURRENT_USER AS
/* $Header: POAQTRSS.pls 115.3 2002/01/24 17:59:47 pkm ship      $  */

-- -------------------------------------------------------------------
-- Name: get_today
-- Desc: Returns today's date with time element.  If the profile
--       POA_FIXED_DATE is set, then it returns the fixed date.  Otherwise
--       it returnes sysdate
-- Output: Todays date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
FUNCTION get_today RETURN DATE;

-- -------------------------------------------------------------------
-- Name: get_cqtr_start
-- Desc: Returns quarter start date for current year current
--       quarter (cycq) in the enterprise calendar.  Current quarter
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_cqtr_start return DATE;

-- -------------------------------------------------------------------
-- Name: get_cqtr_end
-- Desc: Returns quarter end date for current year current
--       quarter (cycq) in the enterprise calendar.  Current quarter
--       calculated based on sysdate. Info is cached after initial access
-- Output: Enterprise calendar current quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_cqtr_end  return DATE;

-- -------------------------------------------------------------------
-- Name: get_lycq_start
-- Desc: Returns quarter start date for last year current quarter
--       (lycq) in the enterprise calendar.  Info is cached after
--       initial access
-- Output: Enterprise calendar last year same quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_lycq_start return DATE;

-- -------------------------------------------------------------------
-- Name: get_lycq_end
-- Desc: Returns quarter end date for last year current quarter
--       (lycq) in the enterprise calendar.  Info is cached after
--       initial access
-- Output: Enterprise calendar last year same quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_lycq_end  return DATE;

-- -------------------------------------------------------------------
-- Name: get_lycq_today
-- Desc: Returns today's equavalent day in the same quarter from last
--       year in the enterprise calendar.  The equavlent day is
--       established by counting backwards the same # of days from
--       the end of the quarter.  Info is cached after initial access
-- Output: Enterprise calendar last year same quarter today (variation 1)
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_lycq_today return DATE;

-- -------------------------------------------------------------------
-- Name: get_cy_start
-- Desc: Returns year start date for current year in the enterprise calendar.
-- Current year calculated based on sysdate.
-- Info is cached after initial access
-- Output: Enterprise calendar current year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_cy_start return DATE;

-- -------------------------------------------------------------------
-- Name: get_cy_end
-- Desc: Returns year end date for current year in the enterprise calendar.
-- Current year calculated based on sysdate.
-- Info is cached after initial access
-- Output: Enterprise calendar current year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_cy_end return DATE;

-- -------------------------------------------------------------------
-- Name: get_ly_start
-- Desc: Returns year start date for last  year in the enterprise calendar.
-- Current year calculated based on sysdate.
-- Info is cached after initial access
-- Output: Enterprise calendar last year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_ly_start return DATE;

-- -------------------------------------------------------------------
-- Name: get_ly_end
-- Desc: Returns year end date for last  year in the enterprise calendar.
-- Current year calculated based on sysdate.
-- Info is cached after initial access
-- Output: Enterprise calendar last year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_ly_end return DATE;

PRAGMA RESTRICT_REFERENCES (get_today, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cqtr_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cqtr_end, WNDS);
PRAGMA RESTRICT_REFERENCES (get_lycq_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_lycq_end, WNDS);
PRAGMA RESTRICT_REFERENCES (get_lycq_today, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cy_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_cy_end, WNDS);
PRAGMA RESTRICT_REFERENCES (get_ly_start, WNDS);
PRAGMA RESTRICT_REFERENCES (get_ly_end, WNDS);

end;

 

/
