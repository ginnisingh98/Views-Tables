--------------------------------------------------------
--  DDL for Package HR_HELPDESK_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HELPDESK_UTIL_SS" AUTHID CURRENT_USER As
/* $Header: hrhdutilss.pkh 120.2.12010000.6 2009/04/17 12:11:08 tkghosh ship $ */
--
--
FUNCTION get_person_id
   ( emp_id IN per_all_people_f.employee_number%type,
     bg_id IN per_all_people_f.business_group_id%type,
     cwk_id IN per_all_people_f.npw_number%type)
RETURN  varchar2;

FUNCTION get_assgn_id
  ( pers_id IN per_all_people_f.person_id%type)
RETURN  varchar2;

FUNCTION get_person_status
  ( person_id IN per_all_people_f.person_id%type)
RETURN  varchar2;

FUNCTION get_assign_status
  ( assig_id IN per_all_assignments_f.assignment_id%type)
RETURN  varchar2;

FUNCTION validate_function
  (func_name fnd_form_functions.function_name%type,
   bus_grp_id per_all_people_f.business_group_id%type)
RETURN varchar2;

FUNCTION get_function_type
  (func_name IN VARCHAR2)
RETURN varchar2;

FUNCTION get_resp_name
  (func_name fnd_form_functions.function_name%type,
   bus_grp_id per_all_people_f.business_group_id%type)
RETURN VARCHAR2;

FUNCTION get_secgrp_key
  (bus_grp_id IN PER_BUSINESS_GROUPS.business_group_id%type)
RETURN VARCHAR2;

FUNCTION get_person_type_status
  (p_person_id IN per_all_people_f.person_id%type,
   eff_date IN varchar2,
   p_fn_name  IN varchar2)
RETURN VARCHAR2;

END;

/
