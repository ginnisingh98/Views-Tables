--------------------------------------------------------
--  DDL for Package PQH_LENGTH_OF_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_LENGTH_OF_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: pqlosclc.pkh 120.0 2005/05/29 02:11:19 appldev noship $ */


-- ---------------------------------------------------------------------*
-- get_length_of_service
-- ---------------------------------------------------------------------*

FUNCTION get_length_of_service ( p_bg_id               IN    NUMBER,
                                 p_person_id           IN    NUMBER   default NULL,
                                 p_assignment_id       IN    NUMBER   default NULL,
                                 p_los_type            IN    VARCHAR2,
                                 p_return_units        IN    VARCHAR2 default 'D',
                                 p_determination_date  IN    DATE default NULL)
         RETURN NUMBER;
--
-- Length of service calculation for German PS
--
FUNCTION get_length_of_service( p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 		        	p_person_id	      IN   per_all_people_f.person_id%TYPE,
				p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE DEFAULT NULL,
				p_prev_job_id         IN   per_previous_jobs.previous_job_id%TYPE DEFAULT NULL,
				p_los_type            IN   VARCHAR2,
				p_assg_start_date     IN   DATE ,
				p_assg_end_date       IN   DATE
                              )
         RETURN VARCHAR2;

FUNCTION get_de_military_service_period(p_bg_id         IN   hr_all_organization_units.organization_id%TYPE,
                                        p_person_id     IN   per_all_people_f.person_id%TYPE,
                                        p_los_type      IN   hr_lookups.lookup_code%TYPE,
                                        p_start_date    IN   DATE,
                                        p_end_date      IN   DATE)
RETURN VARCHAR2;

FUNCTION get_de_correction_factor(p_person_id       IN per_all_people_f.person_id%TYPE,
                                  p_los_type        IN hr_lookups.lookup_code%TYPE,
                                  p_effective_date  IN DATE)
RETURN VARCHAR2;

FUNCTION get_length_previous_employment(p_person_id     IN per_all_people_f.person_id%TYPE,
                                 p_bg_id          IN per_all_organization_units.organization_id%TYPE,
                                 p_los_type   IN hr_lookups.lookup_code%TYPE,
                                 p_previous_job_id IN per_previous_jobs.previous_job_id%TYPE)
RETURN NUMBER;
FUNCTION get_correction_factor ( p_person_id   IN per_all_people_f.person_id%TYPE,
                                 p_los_type    IN hr_lookups.lookup_code%TYPE,
                                 p_effective_date  IN DATE)
RETURN NUMBER;


FUNCTION get_corps_name (p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE,
                                 p_bg_id          IN per_all_organization_units.organization_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_corps_name (p_corps_id IN pqh_corps_definitions.corps_definition_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_grade_name (p_grade_id IN per_grades.grade_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_los_for_display  (  p_bg_id               IN    NUMBER,
                                 p_person_id           IN    NUMBER default NULL,
                                 p_assignment_id       IN    NUMBER default NULL,
                                 p_los_type            IN    VARCHAR2,
                                 p_determination_date  IN    DATE default SYSDATE) RETURN VARCHAR2;
FUNCTION get_working_time_ratio( p_bg_normal_day IN NUMBER,
                                 p_bg_hours  IN NUMBER,
                                 p_bg_frequency  IN VARCHAR2,
                                 p_asg_hours  IN NUMBER,
                                 p_asg_frequency IN VARCHAR2)
RETURN NUMBER;
FUNCTION get_employee_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE)
RETURN VARCHAR2;
FUNCTION get_absent_period (p_bg_id      IN per_all_organization_units.organization_id%TYPE,
                            p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                            p_los_type   IN hr_lookups.lookup_code%TYPE,
                            p_start_date IN DATE,
                            p_end_date   IN DATE
                            )
RETURN NUMBER;
FUNCTION get_parttime_entitlement(p_person_id      IN per_all_assignments_f.person_id%TYPE,
                                  p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE,
                                  p_bg_id          IN per_all_organization_units.organization_id%TYPE,
                                  p_los_type       IN hr_lookups.lookup_code%TYPE,
                                  p_start_date     IN DATE,
                                  p_end_date       IN DATE)

RETURN NUMBER ;

FUNCTION get_date_diff_for_display (
      p_start_date   IN   DATE,
      p_end_date     IN   DATE DEFAULT SYSDATE
   )
      RETURN VARCHAR2;

END PQH_LENGTH_OF_SERVICE_PKG;


 

/
