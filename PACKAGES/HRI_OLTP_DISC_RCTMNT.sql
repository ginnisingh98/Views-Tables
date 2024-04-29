--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_RCTMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_RCTMNT" AUTHID CURRENT_USER AS
/* $Header: hriodrec.pkh 115.0 2002/08/22 09:22:06 jtitmas noship $ */

FUNCTION get_vacancy_hire_count(p_vacancy          IN VARCHAR2,
                                p_business_group   IN VARCHAR2,
                                p_requisition      IN VARCHAR2,
                                p_applicant_number IN VARCHAR2)
                         RETURN NUMBER;

FUNCTION get_vacancy_offer_count(p_vacancy        IN VARCHAR2,
                                 p_business_group IN VARCHAR2,
                                 p_requisition    IN VARCHAR2)
                  RETURN NUMBER;

FUNCTION get_rec_act_hire_count(p_rec_activity     IN VARCHAR2,
                                p_business_group   IN VARCHAR2,
                                p_applicant_number IN VARCHAR2)
                        RETURN NUMBER;

FUNCTION get_rec_act_offer_count(p_rec_activity   IN VARCHAR2,
                                 p_business_group IN VARCHAR2)
                       RETURN NUMBER;

FUNCTION get_rec_act_vac_hire_count(p_rec_activity     IN VARCHAR2,
                                    p_vacancy          IN VARCHAR2,
                                    p_business_group   IN VARCHAR2,
                                    p_applicant_number IN VARCHAR2)
                           RETURN NUMBER;

FUNCTION get_rec_act_vac_offer_count(p_rec_activity   IN VARCHAR2,
                                     p_vacancy        IN VARCHAR2,
                                     p_business_group IN VARCHAR2)
                               RETURN NUMBER;

FUNCTION get_hiring_cost_current_emp(p_rec_act_id  IN NUMBER,
                                     p_actual_cost IN NUMBER)
                              RETURN NUMBER;

FUNCTION check_active_vacancy(p_date_from     IN DATE,
                              p_date_to       IN DATE)
                       RETURN VARCHAR2;

END hri_oltp_disc_rctmnt;

 

/
