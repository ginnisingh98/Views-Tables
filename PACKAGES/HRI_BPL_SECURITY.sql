--------------------------------------------------------
--  DDL for Package HRI_BPL_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_SECURITY" AUTHID CURRENT_USER AS
/* $Header: hribpscr.pkh 120.1 2006/11/16 10:58:58 anmajumd noship $ */
--
-- Global Variables
--
g_resp_id       NUMBER(15);
g_resp_key      VARCHAR2(30);
--
/* simply returns the profile option 'HRI_DBI_CHO_NMD_USR' value */
FUNCTION get_named_user_profile_value RETURN NUMBER;

/* wrapper function, checks the value for the new CHO
   profile option and returns that if its set
   otherwise returns fnd_global.employee_id          */
FUNCTION get_apps_signin_person_id RETURN NUMBER;
--
-- Function to return the manager id in OBIEE depending upon the responsibility
-- used to log in
--
FUNCTION get_mgr_id(p_employee_id IN NUMBER, p_resp_id IN NUMBER, p_resp_appl_id IN NUMBER) RETURN NUMBER;
--
-- Function to return the organization id in OBIEE depending upon the responsibility
-- used to log in
--
FUNCTION get_org_id(p_employee_id IN NUMBER, p_resp_id IN NUMBER, p_resp_appl_id IN NUMBER) RETURN NUMBER;
--
-- Overloaded version of get_mgr_id. It takes no parameter as input and uses
-- FND packages to set the parameters
--
FUNCTION get_mgr_id RETURN NUMBER;
--
--
-- Overloaded version of get_org_id. It takes no parameter as input and uses
-- FND packages to set the parameters
--
FUNCTION get_org_id RETURN NUMBER;

END HRI_BPL_SECURITY;

/
