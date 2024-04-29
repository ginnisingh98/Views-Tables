--------------------------------------------------------
--  DDL for Package HR_VIEW_ALERT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VIEW_ALERT_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: pervautl.pkh 115.1 2003/06/03 17:05:27 akmistry noship $ */
--
-- -------------------------------------------------------------------------
-- functions
-- -------------------------------------------------------------------------
--
FUNCTION get_psn_addrss(p_person_id IN NUMBER) RETURN VARCHAR2;
--
FUNCTION get_psn_emrg_contacts(p_person_id IN NUMBER) RETURN VARCHAR2;
--
END HR_VIEW_ALERT_UTILITIES;

 

/
