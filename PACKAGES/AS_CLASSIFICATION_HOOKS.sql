--------------------------------------------------------
--  DDL for Package AS_CLASSIFICATION_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_CLASSIFICATION_HOOKS" AUTHID CURRENT_USER as
/* $Header: asxccihs.pls 115.4 2002/11/06 00:39:54 appldev ship $ */


procedure update_class_category_post(p_class_category in varchar2,
			   p_category_meaning in varchar2,
			   p_allow_leaf_node_only_flag in varchar2);


procedure register_Lookup_code_post(p_lookup_type in varchar2,
			     p_lookup_code in varchar2,
			     p_meaning in varchar2,
			     p_description in varchar2,
			     p_enabled_flag in varchar2,
			     p_start_date_active in date,
			     p_end_date_active in date);

procedure update_Lookup_code_post(p_lookup_type in varchar2,
			     p_lookup_code in varchar2,
			     p_meaning in varchar2,
			     p_description in varchar2,
			     p_enabled_flag in varchar2,
			     p_start_date_active in date,
			     p_end_date_active in date);

procedure create_class_code_rel_post(p_class_category in varchar2,
				  p_class_code in varchar2,
				  p_sub_class_code in varchar2,
				  p_start_date_active in date,
				  p_end_date_active in date
				);


procedure update_class_code_rel_post(p_class_category in varchar2,
				  p_class_code in varchar2,
				  p_sub_class_code in varchar2,
				  p_end_date_active in date);

function get_concat_meaning(p_type in varchar2, p_curr_code in varchar2,p_language in varchar2) return varchar2;

function get_concat_code(p_class_category in varchar2,p_curr_code in varchar2) return varchar2;
END AS_CLASSIFICATION_HOOKS;

 

/
