--------------------------------------------------------
--  DDL for Package HRI_OPL_RECRUITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_RECRUITMENT" AUTHID CURRENT_USER AS
/* $Header: hriprec.pkh 115.1 2002/12/20 17:16:44 jtitmas noship $ */

FUNCTION get_stage_status(p_assignment_id IN NUMBER,
                          p_person_id     IN NUMBER,
                          p_term_reason   IN VARCHAR2,
                          p_end_date      IN DATE,
                          p_system_status IN VARCHAR2)
                RETURN VARCHAR2;

FUNCTION get_stage_reason(p_assignment_id IN NUMBER,
                          p_person_id     IN NUMBER,
                          p_term_reason   IN VARCHAR2,
                          p_end_date      IN DATE,
                          p_system_status IN VARCHAR2)
                RETURN VARCHAR2;

FUNCTION get_stage_date(p_assignment_id IN NUMBER,
                        p_person_id     IN NUMBER,
                        p_term_reason   IN VARCHAR2,
                        p_end_date      IN DATE,
                        p_system_status IN VARCHAR2)
                RETURN DATE;

FUNCTION get_hire_assignment(p_assignment_id IN NUMBER,
                             p_person_id     IN NUMBER,
                             p_term_reason   IN VARCHAR2,
                             p_end_date      IN DATE)
                RETURN NUMBER;

FUNCTION is_pursued_apl(p_person_id        IN NUMBER,
                        p_vacancy_id       IN NUMBER,
                        p_effective_date   IN DATE)
                RETURN NUMBER;

FUNCTION calc_avg_days_to_hire(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER;

FUNCTION calc_avg_days_to_fill(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER;

FUNCTION calc_avg_fill_to_hire(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER;

FUNCTION calc_no_apls(p_vacancy_id IN NUMBER,
                      p_date_from  IN DATE)
                RETURN NUMBER;

END hri_opl_recruitment;

 

/
