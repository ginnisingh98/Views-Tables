--------------------------------------------------------
--  DDL for Package HR_NL_CALC_TARGET_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_CALC_TARGET_GROUP" AUTHID CURRENT_USER AS
/* $Header: pernlctg.pkh 115.2 2002/05/17 05:58:18 pkm ship        $ */
--
function get_country_code(p_person_id per_all_people_f.person_id%type,
                          p_contact_type per_contact_relationships.contact_type%type,
                          p_session_date date) return VARCHAR2;
--
function run_formula (p_country_of_birth_fth per_all_people_f.country_of_birth%type,
		      p_country_of_birth_mth per_all_people_f.country_of_birth%type,
		      p_country_of_birth_emp per_all_people_f.country_of_birth%type,
		      p_business_group_id per_all_people_f.business_group_id%type,
                      p_session_date date) return VARCHAR2;
--
FUNCTION get_target_group(p_person_id per_all_people_f.person_id%type,
                           p_session_date date) return VARCHAR2;

END HR_NL_CALC_TARGET_GROUP;


 

/
