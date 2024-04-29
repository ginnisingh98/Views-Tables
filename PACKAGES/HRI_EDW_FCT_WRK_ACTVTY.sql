--------------------------------------------------------
--  DDL for Package HRI_EDW_FCT_WRK_ACTVTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_FCT_WRK_ACTVTY" AUTHID CURRENT_USER AS
/* $Header: hriefwac.pkh 120.0 2005/05/29 07:10:28 appldev noship $ */

FUNCTION check_reason( p_change_reason  IN VARCHAR2,
                       p_instance       IN VARCHAR2 )
              RETURN VARCHAR2;

FUNCTION get_hire_days( p_person_id         IN NUMBER,
                        p_effective_date    IN DATE )
               RETURN DATE;

FUNCTION get_days_to_last_org_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER;

FUNCTION get_days_to_last_job_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER;

FUNCTION get_days_to_last_pos_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER;

FUNCTION get_days_to_last_grd_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER;

FUNCTION get_days_to_last_geog_x( p_assignment_id     IN NUMBER,
                                  p_person_id         IN NUMBER,
                                  p_change_date       IN DATE )
            RETURN NUMBER;

END hri_edw_fct_wrk_actvty;

 

/
