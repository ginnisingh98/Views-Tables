--------------------------------------------------------
--  DDL for Package Body HR_VIEW_ALERT_RECIPIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VIEW_ALERT_RECIPIENT" AS
/* $Header: pervarpt.pkb 115.1 2003/05/14 15:14:33 jrstewar noship $ */
--
-- -----------------------------------------------------------------------------
--
-- Version of Get_psn_eml_addrss to accept NUMBER id
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_all_psn_prsn_nm(p_person_id);
  --
END Get_all_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Version of Get_psn_eml_addrss overloaded to accept VARCHAR2
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN VARCHAR2)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_all_psn_prsn_nm(TO_NUMBER(p_person_id));
  --
END Get_all_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
FUNCTION Get_psn_eml_addrss(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_eml_addrss(p_person_id);
  --
END Get_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Overloaded version of Get_psn_eml_addrss to accept VARCHAR id
--
FUNCTION Get_psn_eml_addrss(p_person_id  IN VARCHAR2)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_eml_addrss(TO_NUMBER(p_person_id));
  --
END Get_psn_eml_addrss;
--
--
-- -----------------------------------------------------------------------------
--
-- Overloaded version of Get_psn_eml_addrss to accept VARCHAR id
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id IN VARCHAR2)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_sup_psn_eml_addrss(
                                                  TO_NUMBER(p_person_id));
  --
END Get_psn_sup_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Version of Get_psn_eml_addrss to accept NUMBER id
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_sup_psn_eml_addrss(p_person_id);
  --
END Get_psn_sup_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Version of Get_psn_eml_addrss to accept NUMBER id
--
FUNCTION Get_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_prsn_nm(p_person_id);
  --
END Get_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Version of Get_psn_eml_addrss overloaded to accept VARCHAR2
--
FUNCTION Get_psn_prsn_nm(p_person_id IN VARCHAR2)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_prsn_nm(TO_NUMBER(p_person_id));
  --
END Get_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given person_id
--
FUNCTION Get_psn_sup_psn_nm(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_sup_psn_nm(p_person_id);
  --
END Get_psn_sup_psn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Overloaded version of Get_psn_sup_psn_nm that accepts VARCHAR2
--
FUNCTION Get_psn_sup_psn_nm(p_person_id     IN VARCHAR2)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_sup_psn_nm(TO_NUMBER(p_person_id));
  --
END Get_psn_sup_psn_nm;
--




--
-- -----------------------------------------------------------------------------
--
-- Get's a language for a given person_id
--
FUNCTION Get_psn_lng(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_lng(p_person_id);
  --
END Get_psn_lng;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given person_id
--
FUNCTION Get_psn_sup_psn_lng(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_psn_sup_psn_lng(p_person_id);
  --
END Get_psn_sup_psn_lng;
--
--
-- -----------------------------------------------------------------------------
--
-- Checks to see if a person has an email address
--
FUNCTION Check_person_in_scope(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Check_person_in_scope(p_person_id);
  --
END Check_person_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Checks to see if a primary assignment supervisor person has an email address
-- for a given person_id. If it does return the person_id otherwise return NULL.
--
FUNCTION Check_sup_person_in_scope(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Check_sup_person_in_scope(p_person_id);
  --
END Check_sup_person_in_scope;
--

--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a supervisor of a given assignment_id
--
FUNCTION Get_asg_sup_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN   hr_bpl_alert_recipient.Get_asg_sup_eml_addrss(p_assignment_id);
  --
END Get_asg_sup_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a assignment supervisor name for a given assignment_id
--
FUNCTION Get_asg_sup_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_asg_sup_nm(p_assignment_id);
  --
END Get_asg_sup_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the assignment supervisor's language for a given assignment_id
--
FUNCTION Get_asg_sup_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_asg_sup_lng(p_assignment_id);
  --
END Get_asg_sup_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's
-- assignment supervisor, if we have return assignment_id otherwise NULL
--
FUNCTION Check_asg_sup_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Check_asg_sup_in_scope(p_assignment_id);
  --
END Check_asg_sup_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for the primary assignment supervisor of a given
--  assignment_id
--
FUNCTION Get_pasg_sup_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_pasg_sup_eml_addrss(p_assignment_id);
  --
END Get_pasg_sup_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given assignment_id
--
FUNCTION Get_pasg_sup_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_pasg_sup_nm(p_assignment_id);
  --
END Get_pasg_sup_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given assignment_id
--
FUNCTION Get_pasg_sup_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_pasg_sup_lng(p_assignment_id);
  --
END Get_pasg_sup_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's primary
-- assignment supervisor, if we have assignment_id otherwise NULL
--
FUNCTION Check_pasg_sup_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Check_pasg_sup_in_scope(p_assignment_id);
  --
END Check_pasg_sup_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for the person who owns an assignment for a given
-- assignment_id
--
FUNCTION Get_asg_psn_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_asg_psn_eml_addrss(p_assignment_id);
  --
END Get_asg_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get'sthe person who owns an assignment's name for a given assignment_id
--
FUNCTION Get_asg_psn_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_asg_psn_nm(p_assignment_id);
  --
END Get_asg_psn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the person who owns an assignment's language for a given assignment_id
--
FUNCTION Get_asg_psn_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Get_asg_psn_lng(p_assignment_id);
  --
END Get_asg_psn_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for the person who owns an
-- assignment, if we have return assignment_id otherwise return NULL
--
FUNCTION Check_asg_psn_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.Check_asg_psn_in_scope(p_assignment_id);
  --
END Check_asg_psn_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Find out if the assignment has a current primary assignment supervisor
--
FUNCTION Check_pasg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.check_pasg_sup_available(p_assignment_id);
  --
END Check_pasg_sup_available;
--
-- -----------------------------------------------------------------------------
--
-- Find out if the assignment has a current supervisor
--
FUNCTION Check_asg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_recipient.check_asg_sup_available(p_assignment_id);
  --
END Check_asg_sup_available;
--
END HR_VIEW_ALERT_RECIPIENT;

/
