--------------------------------------------------------
--  DDL for Package WIP_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PREFERENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: wipprefs.pls 120.0 2005/06/24 16:41 jezheng noship $ */

--
-- This function returns attribute_code from wip_preference_values
-- for single value preferences based on resp_key, org_id, dept_id.
-- For multiple value preferences, it returns "ENTERED" or "INHERIT" based on setup.
--
function get_preference_value_code
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2;

--
-- This function returns attribute_value based on attribute_code.
--
function get_preference_value
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2;

--
-- Return the number of preference setups at specified level
--
function get_row_count
(p_pref_id number,
p_level_code number,
p_resp_key varchar2,
p_org_id number,
p_dept_id number)  return number;

--
-- The function calculates the result preference value
--
function get_result_value_code
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2;

--
-- The function calculates the result preference value
--
function get_result_value
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2;

--
-- The function returns the inherit flag for a preference at specified level
--
function get_inherit_flag_value
(p_level_id number,
 p_level_code number) return number;

--
-- The function calculates the preference level_id based on given resp_key,
-- org_id and dept_id
--
function get_preference_level_id
(p_preference_id number,
 p_resp_key varchar2,
 p_organization_id number,
 p_department_id number) return number;

function get_level (p_level_code number) return varchar2;
function get_responsibility (p_resp_key varchar2) return varchar2;
function get_organization (p_org_id number) return varchar2;
function get_department (p_dept_id number) return varchar2;

END WIP_PREFERENCES_PKG;

 

/
