--------------------------------------------------------
--  DDL for Package HR_AUTH_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTH_INT" AUTHID CURRENT_USER as
/* $Header: hrathint.pkh 115.6 2002/05/29 05:43:55 pkm ship       $ */


FUNCTION get_url
	(
	p_provider IN VARCHAR2,
  p_user_id IN NUMBER,
	p_person_id IN NUMBER,
	p_page IN VARCHAR2,
  p_primary_obj IN VARCHAR2
  )
	RETURN VARCHAR2;

FUNCTION get_url
	(
	p_provider IN VARCHAR2,
  p_user_id IN VARCHAR2,
	p_person_id IN VARCHAR2,
	p_page IN VARCHAR2,
  p_primary_obj IN VARCHAR2
  )
	RETURN VARCHAR2;

FUNCTION get_password
	(
	p_person_id IN NUMBER
  )
	RETURN VARCHAR2;

FUNCTION get_page
  (
  p_plip_id IN NUMBER,
  p_pl_id IN NUMBER,
  p_ler_id IN NUMBER
  )
  RETURN VARCHAR2;

FUNCTION get_anchor_tag_ss
  (
  p_pl_id in number,
  p_person_id in number,
  p_plan_name in varchar2,
  p_ler_id in number,
  p_plip_id in number default null,
  p_plan_url in varchar2 default null,
  p_primary_obj_context in varchar2 default null
  )
  RETURN varchar2;

FUNCTION get_url_ss
  (
  p_pl_id in number,
  p_person_id in number,
  p_plan_name in varchar2,
  p_ler_id in number,
  p_plip_id in number default null,
  p_plan_url in varchar2 default null,
  p_primary_obj_context in varchar2 default null
  )
  RETURN varchar2;


END hr_auth_int;

 

/
