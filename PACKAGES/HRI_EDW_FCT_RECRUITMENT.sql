--------------------------------------------------------
--  DDL for Package HRI_EDW_FCT_RECRUITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_FCT_RECRUITMENT" AUTHID CURRENT_USER AS
/* $Header: hriefwrt.pkh 120.0 2005/05/29 07:10:50 appldev noship $ */

FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_budget_type       IN VARCHAR2,
                  p_effective_date    IN DATE)
                  RETURN NUMBER;

PROCEDURE find_stages(p_assignment_id      IN NUMBER);

PROCEDURE find_employment_end(p_person_id  IN NUMBER,
                              p_date_start IN DATE);

FUNCTION find_hire_reason(p_assignment_id  IN NUMBER,
                          p_person_id      IN NUMBER,
                          p_hire_date      IN DATE)
                   RETURN VARCHAR2;

FUNCTION find_movement_pk(p_system_status    IN VARCHAR2,
                          p_gain_type        IN VARCHAR2,
                          p_success_flag     IN NUMBER)
                   RETURN VARCHAR2;

FUNCTION is_successful(p_assignment_id        IN NUMBER,
                       p_person_id            IN NUMBER,
                       p_date_end             IN DATE)
                 RETURN NUMBER;

PROCEDURE populate_recruitment_table;

END hri_edw_fct_recruitment;

 

/
