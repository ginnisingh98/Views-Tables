--------------------------------------------------------
--  DDL for Package HR_VIEW_ALERT_RECIPIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VIEW_ALERT_RECIPIENT" AUTHID CURRENT_USER AS
/* $Header: pervarpt.pkh 115.1 2003/05/14 15:14:04 jrstewar noship $ */
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN VARCHAR2)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_eml_addrss(p_person_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_eml_addrss(p_person_id     IN VARCHAR2)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id IN VARCHAR2)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_prsn_nm(p_person_id IN VARCHAR2)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_nm(p_person_id IN VARCHAR2)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_lng(p_person_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Get_psn_sup_psn_lng(p_person_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Check_person_in_scope(p_person_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION Check_sup_person_in_scope(p_person_id     IN NUMBER)
          RETURN VARCHAR2;
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
FUNCTION Check_asg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
FUNCTION Check_pasg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER;
--
END HR_VIEW_ALERT_RECIPIENT;

 

/
