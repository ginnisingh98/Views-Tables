--------------------------------------------------------
--  DDL for Package HR_WORKFLOW_INSTALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WORKFLOW_INSTALL_PKG" AUTHID CURRENT_USER as
/* $Header: petskflw.pkh 115.3 2003/06/16 09:19:48 pkakar ship $ */
procedure taskflow_report  (	  g_workflow_name_width		NUMBER	DEFAULT 30
				, g_from_form_name_width	NUMBER  DEFAULT 20
				, g_from_node_name_width	NUMBER  DEFAULT 20
				, g_to_form_name_width		NUMBER  DEFAULT 20
				, g_to_node_name_width		NUMBER  DEFAULT 20
				, g_sequence_width		NUMBER  DEFAULT 9
				, g_button_label_width		NUMBER  DEFAULT 20);
procedure get_workflow_id (p_workflow_name varchar2) ;
procedure get_nav_unit_id (p_form_name varchar2
				,p_block_name varchar2 default null) ;
procedure get_nav_node_id (p_name varchar2) ;
procedure get_node_usage_id ;
procedure new_workflow (p_name varchar2) ;
procedure new_nav_unit (
	p_application_abbrev	varchar2,
	p_form_name		varchar2,
	p_default_label		varchar2,
	p_max_no_of_buttons	number,
	p_block_name		varchar2) ;
procedure new_nav_node (p_name				varchar2,
			p_customized_restriction_id	number default null) ;
procedure new_nav_node_usage (p_top_node	varchar2) ;
procedure new_path (
	p_to_name		varchar2,
	p_nav_button_required	varchar2,
	p_sequence		number,
	p_override_label	varchar2) ;
procedure get_global_usage_id (p_global_name varchar2);
procedure new_global_usage (
	p_global_name	varchar2,
	p_in_or_out	varchar2,
	p_mandatory_flag	varchar2);
procedure new_context_rule (
	p_evaluation_type_code	varchar2,
	p_value			varchar2);
end;

 

/
