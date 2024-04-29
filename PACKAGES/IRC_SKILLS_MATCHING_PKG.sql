--------------------------------------------------------
--  DDL for Package IRC_SKILLS_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SKILLS_MATCHING_PKG" AUTHID CURRENT_USER AS
/* $Header: irsklpkg.pkh 120.0 2005/07/26 15:18:39 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  SKILLS_MATCH  >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is the main function to return a percentage value that a given person
--  matches the lists of skills.  (If the get_percent_flag is true, if false then
--  processing stops as soon as it is known whether or not the person will pass
--  to some extent.)
--
-- Prerequisites:
--   This is a public function, but will mainly be called by local functions.
--
-- In Parameters:
--   String of comma-delimeted ID's representing skills and the corresponding levels.
--   A person id.
-- Post Success:
--   A return percentage. Should all essential skills not be matched a '-1'
--   figure will be returned
--
-- Post Failure:
--   If inputs are of inconsistent lengths than a suitable error will occur.
--
-- Developer Implementation Notes:
--   Add additional where clause to VO to restrict to parties where this function does not return -1.
--
-- {End Of Comments}

FUNCTION SKILLS_MATCH  ( p_esse_sk_list_str VARCHAR2,
                         p_esse_sk_mins_str VARCHAR2,
                         p_esse_sk_maxs_str VARCHAR2,
                         p_pref_sk_list_str VARCHAR2,
                         p_pref_sk_mins_str VARCHAR2,
                         p_pref_sk_maxs_str VARCHAR2,
                         p_person_id number,
                         p_get_percent_flag BOOLEAN)     RETURN VARCHAR2;



-- ----------------------------------------------------------------------------
-- |----------------------<  SKILLS_MATCH_PERCENT  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper to be called from java code.  This takes all the input parameters and
--  calls the main skills_match requesting an exact percentage.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   As main skills_match.
-- Post Success:
--   A return percentage. Should all essential skills not be matched a '-1'
--   figure will be returned
--
-- Post Failure:
--   If inputs are of inconsistent lengths than a suitable error will occur.
--
-- Developer Implementation Notes:
--   Usually used in select part of VO to get the exact match figure.
--
-- {End Of Comments}

FUNCTION SKILLS_MATCH_PERCENT  ( p_esse_sk_list_str VARCHAR2,
                         p_esse_sk_mins_str VARCHAR2,
                         p_esse_sk_maxs_str VARCHAR2,
                         p_pref_sk_list_str VARCHAR2,
                         p_pref_sk_mins_str VARCHAR2,
                         p_pref_sk_maxs_str VARCHAR2,
                         p_person_id number)     RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |------------------------<  SKILLS_MATCH_TEST  >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper to be called from java code.  This takes all the input parameters and
--  calls the main skills_match requesting processing only until a decision
-- on whether person has required skills has been reached.  An exact percentage is
-- not returned, just a boolean on whether the person has the skills.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   As main skills_match.  Except only essential comma-delimited lists are required.
-- Post Success:
--   A return boolean.
--
-- Post Failure:
--   If inputs are of inconsistent lengths than a suitable error will occur.
--
-- Developer Implementation Notes:
--   Usually used in where clause part of VO to limit to those parties who have passed
--
-- {End Of Comments}

FUNCTION SKILLS_MATCH_TEST  ( p_esse_sk_list_str VARCHAR2,
                         p_esse_sk_mins_str VARCHAR2,
                         p_esse_sk_maxs_str VARCHAR2,
                         p_person_id number)     RETURN BOOLEAN;



-- ----------------------------------------------------------------------------
-- |-----------------------<  VACANCY_MATCH_PERCENT  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is a function to return a percentage value, representing how well a given person
--  matches the lists of skills required for a given vacancy.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A person id, a vacancy id and an effective date
--   This will in turn call the above SKILLS_MATCH_PERCENT
-- Post Success:
--   A return percentage. Should all essential skills not be matched a '-1'
--   figure will be returned
--
-- Post Failure:
--   If inputs are of inconsistent lengths than a suitable error will occur.
--
-- Developer Implementation Notes:
--   Add additional where clause to VO to restrict to parties where this function does not return -1.
--
-- {End Of Comments}

FUNCTION VACANCY_MATCH_PERCENT  (
                                p_person_id  number,
                                p_vacancy_id  varchar2,
                                p_eff_date  date  default sysdate)     RETURN VARCHAR2;




-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_SKILLS_FOR_SCOPE  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions gets a list of skills required for a given scope(s).
--  Exact level details are also included.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   An ID representing any/all of the following: Org,Business Group, Job or Postion.
--   An effective date.
-- Post Success:
-- Format of return is
--"comp_id,mandatory,min-level_id,max-level_id>comp_id,mandatory,min-level_id,max-level_id>..."
-- i.e. one long string, commas between items, '>' between sets
--
-- Post Failure:
--   No explicit error catching occurs.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_SKILLS_FOR_SCOPE  (
                                p_org_id  number default 0,
                                p_bgp_id  number default 0,
                                p_job_id  number default 0,
                                p_pos_id  number default 0,
                                p_eff_date  date  default sysdate)     RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_SKILLS_FOR_VAC  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions gets a list of skills required for a given vacancy.
--  Exact rating level details are also included.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   An ID representing a vacancy.
--   An effective date.
-- Post Success:
-- Format of return is
-- "comp_id,mandatory,min-level_id,max-level_id>comp_id,mandatory,min-level_id,max-level_id>...  "
-- i.e. one long string, commas between items, '>' between sets
--
-- Post Failure:
--   No explicit error catching occurs.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_SKILLS_FOR_VAC  (
                                p_vacancy_id  varchar2 default 0,
                                p_eff_date  date   default sysdate)     RETURN VARCHAR2;

END IRC_SKILLS_MATCHING_PKG;

 

/
