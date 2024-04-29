--------------------------------------------------------
--  DDL for Package HR_WPM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPM_UTIL" AUTHID CURRENT_USER AS
/* $Header: hrwpmutl.pkh 120.1.12010000.26 2021/01/25 09:03:14 mgidutur ship $*/

   FUNCTION is_appraisal_started (p_plan_id IN per_perf_mgmt_plans.plan_id%TYPE)
     RETURN  varchar2;

FUNCTION is_los_enabled (p_obj_id IN per_objectives.objective_id%TYPE, p_align_id IN per_objectives.aligned_with_objective_id%TYPE)
   RETURN  varchar2;

   FUNCTION is_down_hierarchy_enabled (p_obj_id IN per_objectives.objective_id%TYPE)
   RETURN  varchar2;

   FUNCTION is_up_hierarchy_enabled (p_align_id IN per_objectives.objective_id%TYPE)
   RETURN  varchar2;
 FUNCTION enable_share_for_topsupervisor(p_planid in per_perf_mgmt_plans.plan_id%TYPE,
       p_personid in per_personal_scorecards.person_id%TYPE,
       p_lookupcode in hr_lookups.lookup_code%TYPE
       )
       RETURN varchar2;
FUNCTION is_high_potential(p_potential IN VARCHAR2)
RETURN NUMBER;
FUNCTION getnboxnumber
    (personid         IN varchar2
    ,p_effective_date IN date) RETURN varchar2;
FUNCTION is_plan_exist(p_person_id IN NUMBER)
RETURN NUMBER;

--Added for 25062755  talent matrix integration enhancement - start
 FUNCTION get_value_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, p_type IN VARCHAR2, def_templt_name IN VARCHAR2)
      RETURN NUMBER;
FUNCTION get_retention_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, def_templt_name IN VARCHAR2)
      RETURN NUMBER;
 FUNCTION get_performance_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, def_templt_name IN VARCHAR2)
      RETURN NUMBER;
--Bug 25822750 - start
 FUNCTION get_performance_for_9box (p_perf IN VARCHAR2, def_templt_name IN VARCHAR2)
      RETURN NUMBER;
--Bug 25822750 - end
FUNCTION get_iol_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, default_template IN VARCHAR2)
      RETURN NUMBER;
FUNCTION get_potential_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, default_template IN VARCHAR2)
      RETURN NUMBER;
 FUNCTION get_retention_for_9box (
      p_person_id     IN   NUMBER,
      p_retention     IN   VARCHAR2,
      p_performance   IN   NUMBER,
			default_template IN VARCHAR2
   )
      RETURN NUMBER;
FUNCTION get_iol_for_9box (
      p_person_id     IN   NUMBER,
      p_iol     IN   VARCHAR2,
      p_retention   IN   VARCHAR2,
			default_template IN VARCHAR2
   )
      RETURN NUMBER;
FUNCTION get_potential_for_9box (
      p_person_id     IN   NUMBER,
      p_potential     IN   VARCHAR2,
      p_performance   IN   NUMBER,
			default_template IN VARCHAR2
   )
 RETURN NUMBER;

--Added for 25062755  talent matrix integration enhancement - end
--
 FUNCTION get_potential_for_9box(p_person_id IN NUMBER,
                                 p_effective_date IN DATE) RETURN NUMBER;
-- new function added for bug 9849172
 FUNCTION get_potential_for_9box (p_person_id IN NUMBER, p_potential IN VARCHAR2, p_performance IN NUMBER)
   RETURN NUMBER;

--new functions added for Bug 13731815
FUNCTION get_iol_for_9box (
      p_person_id     IN   NUMBER,
      p_iol     IN   VARCHAR2,
      p_retention   IN   VARCHAR2
   )
      RETURN NUMBER;

FUNCTION get_retention_for_9box (
      p_person_id     IN   NUMBER,
      p_retention     IN   VARCHAR2,
      p_performance   IN   NUMBER
   )
      RETURN NUMBER;

FUNCTION get_performance_for_9box (p_perf IN VARCHAR2)
      RETURN NUMBER;

-- End of added new functions.

 FUNCTION get_performance_for_9box(p_person_id IN NUMBER,
                                   p_effective_date IN DATE) RETURN NUMBER;
 FUNCTION get_retention_for_9box(p_person_id IN NUMBER,
                                 p_effective_date IN DATE) RETURN NUMBER;
 FUNCTION get_value_for_9box(p_person_id IN NUMBER,
                             p_effective_date IN DATE,
			     p_type IN VARCHAR2) RETURN NUMBER;

 FUNCTION get_iol_for_9box(p_person_id IN NUMBER,
                                 p_effective_date IN DATE) RETURN NUMBER;
--
 PROCEDURE get_9box_details_for_person(p_person_id       IN NUMBER,
                                       p_effective_date  IN DATE,
                                       p_get_performance IN VARCHAR2 DEFAULT
'Y',
                                       p_get_potential   IN VARCHAR2 DEFAULT
'Y',
                                       p_get_retention   IN VARCHAR2 DEFAULT
'Y',
                                       p_performance OUT NOCOPY NUMBER,
                                       p_potential   OUT NOCOPY NUMBER,
                                       p_retention   OUT NOCOPY NUMBER);

FUNCTION get_latest_appraisal_rating(p_person_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_latest_appraisal_date(p_person_id IN NUMBER) RETURN DATE;
FUNCTION get_latest_appraisal_status(p_person_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_latest_appraisal_id(p_person_id IN NUMBER) RETURN NUMBER;
FUNCTION is_hipo_key_inplan_worker (p_person_id IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION get_overall_readiness (
   p_legislation_code    IN   VARCHAR2,
   p_business_group_id   IN   NUMBER,
   p_mode                IN   VARCHAR2
)
   RETURN NUMBER;
--Enhancemnent Talent Matrix , Bug 25403381
FUNCTION getTemplateLabelName(tempName IN VARCHAR2 , label IN VARCHAR2)
	RETURN VARCHAR2;

--Bug 25403381 Ends
-- Bug 25672362
 FUNCTION get_template_columns(p_template_name IN varchar2)
	RETURN varchar2;

FUNCTION get_readiness_by_plan (
   p_plan_id   IN   NUMBER
)
   RETURN NUMBER;

FUNCTION is_sp_data_upgraded RETURN VARCHAR2;

FUNCTION is_obj_setting_open(p_plan_id NUMBER, p_manager_person_id NUMBER)
RETURN VARCHAR2;

FUNCTION get_default_matrix_name
(p_template_code IN varchar2)
RETURN varchar2;

-- Bug 26173767
PROCEDURE validate_sql
	  (p_sql IN varchar2);

END HR_WPM_UTIL; -- Package spec


/
