--------------------------------------------------------
--  DDL for Package HR_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: pewkflow.pkh 115.1 2003/07/07 13:30:23 tvankayl ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
procedure initiate_workflow(
	p_param_workflow_name		IN OUT nocopy varchar2,
	p_workflow_id			IN OUT nocopy number,
	p_current_form			varchar2,
	p_current_block			varchar2,
	p_passed_nav_node_usage_id	number,
	p_dest_form			IN OUT nocopy varchar2,
	p_dest_block			IN OUT nocopy varchar2,
	p_nav_node_usage_id		IN OUT nocopy number,
	p_top_workflow_node		IN OUT nocopy varchar2,
	p_cust_rest_id			IN OUT nocopy number,
	p_cust_appl_id			IN OUT nocopy number,
	p_cust_query_title		IN OUT nocopy varchar2,
	p_cust_std_title		IN OUT nocopy varchar2,
	p_default_found			IN OUT nocopy varchar2);
--
END HR_WORKFLOW_PKG ;

 

/
