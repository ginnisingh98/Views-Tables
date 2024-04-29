--------------------------------------------------------
--  DDL for Package HR_SUIT_MATCH_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUIT_MATCH_UTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrsmgutl.pkh 120.0.12010000.1 2008/07/28 03:48:21 appldev ship $ */

  PROCEDURE populate_comp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
  );

  PROCEDURE populate_per_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
  );

  PROCEDURE populate_workopp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
  );

  PROCEDURE insert_workopp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
  );

  FUNCTION get_ess_desired_match (
     p_person_id in number
    ,p_req in varchar2
  )
  RETURN VARCHAR2;

  FUNCTION get_ess_desired_match (
     p_person_id in number
    ,p_enterprise_id in number default -1
    ,p_organization_id in number default -1
    ,p_job_id in number default -1
    ,p_position_id in number default -1
    ,p_vacancy_id in number default -1
    ,p_req in varchar2
    ,p_person_temp in number default 0
  )
  RETURN VARCHAR2;
  PRAGMA   RESTRICT_REFERENCES(get_ess_desired_match,WNDS,RNDS);

  FUNCTION is_ess_des_meets (
     p_person_id in number
    ,p_meets in varchar2
  )
  RETURN VARCHAR2;

  FUNCTION is_ess_des_meets (
     p_person_id in number
    ,p_enterprise_id in number default -1
    ,p_organization_id in number default -1
    ,p_job_id in number default -1
    ,p_position_id in number default -1
    ,p_vacancy_id in number default -1
    ,p_meets in varchar2
    ,p_person_temp in number default 0
)
RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(is_ess_des_meets,WNDS,RNDS);

FUNCTION get_bg_name(
    p_bg_id in number
  )
RETURN VARCHAR2;

FUNCTION get_application_date(
    p_person_id in number
  )
RETURN DATE;

FUNCTION get_emp_start_date(
    p_period_of_service_id in number
  )
RETURN DATE;

FUNCTION get_cwk_start_date(
    p_person_id in number
  )
RETURN DATE;


END HR_SUIT_MATCH_UTIL_SS;

/
