--------------------------------------------------------
--  DDL for Package Body HR_VIEW_ALERT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VIEW_ALERT_UTILITIES" AS
/* $Header: pervautl.pkb 115.1 2003/06/03 17:05:36 akmistry noship $ */
--
-- -----------------------------------------------------------------------------
-- Gets a single string containing the address
-- -----------------------------------------------------------------------------
--
FUNCTION get_psn_addrss(p_person_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  --
  RETURN HR_BPL_ALERT_ADDRESS.get_psn_addrss(p_person_id);
  --
END get_psn_addrss;
--
-- -----------------------------------------------------------------------------
-- Gets a single string containing the emergency contacts
-- -----------------------------------------------------------------------------
--
FUNCTION get_psn_emrg_contacts(p_person_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  --
  RETURN HR_BPL_ALERT_ADDRESS.get_psn_emrg_contacts(p_person_id);
  --
END get_psn_emrg_contacts;
--
-- -----------------------------------------------------------------------------
--
END HR_VIEW_ALERT_UTILITIES;

/
