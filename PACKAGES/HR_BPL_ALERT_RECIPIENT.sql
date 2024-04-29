--------------------------------------------------------
--  DDL for Package HR_BPL_ALERT_RECIPIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BPL_ALERT_RECIPIENT" AUTHID CURRENT_USER AS
/* $Header: perbarpt.pkh 115.2 2003/05/14 14:57:51 jrstewar noship $ */
--
-- -----------------------------------------------------------------------
--
-- Globals used in cache_asg_sup_psn_details
--
g_pasg_sup_assignment_id      NUMBER;
g_pasg_sup_person_email       VARCHAR2(240);
g_pasg_sup_person_email_set   NUMBER;
g_pasg_sup_person_available   NUMBER;
g_pasg_sup_sup_person_id      NUMBER;
g_pasg_sup_person_name        VARCHAR2(240);
g_pasg_sup_person_lang        VARCHAR2(10);
g_pasg_sup_business_group_id  NUMBER;
--
-- -----------------------------------------------------------------------
--
-- Globals used in cache_asg_sup_psn_details
--
g_asg_sup_assignment_id      NUMBER;
g_asg_sup_person_email       VARCHAR2(240);
g_asg_sup_person_email_set   NUMBER;
g_asg_sup_person_available   NUMBER;
g_asg_sup_sup_person_id      NUMBER;
g_asg_sup_person_name        VARCHAR2(240);
g_asg_sup_person_lang        VARCHAR2(10);
g_asg_sup_business_group_id  NUMBER;
--
-- -----------------------------------------------------------------------
--
-- Globals used in cache_asg_psn_details
--
g_assignment_id          NUMBER;
g_asg_person_email       VARCHAR2(240);
g_asg_person_email_set   NUMBER;
g_asg_sup_person_id      NUMBER;
g_asg_person_name        VARCHAR2(240);
g_asg_person_lang        VARCHAR2(10);
g_asg_business_group_id  NUMBER;
--
-- -----------------------------------------------------------------------
--
-- Globals used in Get_psn_eml_addrss
--
g_person_id           NUMBER;
g_person_email        VARCHAR2(240);
g_person_email_set    NUMBER;
g_person_name         VARCHAR2(240);
g_person_lang         VARCHAR2(10);
g_person_bg_id        NUMBER;
-- -----------------------------------------------------------------------
--
-- Globals used in cache_all_psn_details
--
g_all_person_id           NUMBER;
g_all_person_email        VARCHAR2(240);
g_all_person_email_set    NUMBER;
g_all_person_name         VARCHAR2(240);
g_all_person_lang         VARCHAR2(10);
g_all_person_bg_id        NUMBER;
--
-- -----------------------------------------------------------------------
--
-- Globals used in Get_psn_sup_psn_eml_addrss
--
g_psn_sup_person_id     NUMBER; -- The id of the psn who's supervisor
                                -- we are checking.
g_sup_person_id           NUMBER; -- The id of the Supervisor for the Person
g_sup_person_name         VARCHAR2(240);
g_sup_person_email        VARCHAR2(240);
g_sup_person_email_set    NUMBER;
g_sup_person_lang         VARCHAR2(10);
g_sup_business_group_id   NUMBER;
--
FUNCTION Get_psn_eml_addrss(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_nm(p_person_id IN NUMBER)

          RETURN VARCHAR2;
--
FUNCTION Get_psn_lng(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_lng(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_bg_lng(p_business_group_id IN NUMBER)
  RETURN VARCHAR2;
--
FUNCTION Check_person_in_scope(p_person_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION Check_sup_person_in_scope(p_person_id IN NUMBER)
          RETURN NUMBER;
--
--
FUNCTION Get_asg_sup_eml_addrss(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_asg_sup_nm(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_asg_sup_lng(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Check_asg_sup_in_scope(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION Get_pasg_sup_eml_addrss(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_pasg_sup_nm(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_pasg_sup_lng(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Check_pasg_sup_in_scope(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION Get_asg_psn_eml_addrss(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_asg_psn_nm(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_asg_psn_lng(p_assignment_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Check_asg_psn_in_scope(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION validate_email_address(p_email_address VARCHAR2)
  RETURN BOOLEAN;
--
FUNCTION c_validate_email_address(p_email_address VARCHAR2)
  RETURN VARCHAR2;
--
FUNCTION Check_asg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION Check_pasg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
END HR_BPL_ALERT_RECIPIENT;

 

/
