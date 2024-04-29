--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOW_PKG" AS
/* $Header: pewkflow.pkb 115.4 2004/01/30 07:16:32 bsubrama ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
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
	p_default_found			IN OUT nocopy varchar2) is
--
	l_enabled			varchar2(1);
--
cursor default_workflow is
	select	w.workflow_id,
		u.form_name,
		u.block_name,
		nu.nav_node_usage_id
	from	hr_workflows w,
		hr_navigation_node_usages nu,
		hr_navigation_nodes n,
		hr_navigation_units u
	where	w.workflow_id	= nu.workflow_id
	and	nu.top_node	= 'Y'
	and	nu.nav_node_id	= n.nav_node_id
	and	n.nav_unit_id	= u.nav_unit_id
	and	u.default_workflow_id + 0	= w.workflow_id  -- Bug 3390412
	and	u.form_name	= P_CURRENT_FORM;
--
cursor new_workflow is
	select	w.workflow_id,
		u.form_name,
		u.block_name,
		nu.nav_node_usage_id
	from	hr_workflows w,
		hr_navigation_node_usages nu,
		hr_navigation_nodes n,
		hr_navigation_units u
	where	w.workflow_name	= P_PARAM_WORKFLOW_NAME
	and	w.workflow_id	= nu.workflow_id
	and	nu.top_node	= 'Y'
	and	nu.nav_node_id	= n.nav_node_id
	and	n.nav_unit_id	= u.nav_unit_id;
--
cursor customization is
	select	r.customized_restriction_id,
		r.application_id,
		r.query_form_title,
		r.standard_form_title,
		r.enabled_flag
	from	hr_navigation_nodes n,
		hr_navigation_node_usages us,
		pay_custom_restrictions_vl r
	where	us.workflow_id		= P_WORKFLOW_ID
	and	us.nav_node_usage_id 	= P_NAV_NODE_USAGE_ID
	and	us.nav_node_id		= n.nav_node_id
	and	n.customized_restriction_id = r.customized_restriction_id;
--
begin
--
-- Called from PRE-FORM of all workflow forms. Gets node details - i.e. the
-- customization if there is one and the workflow details.
-- Note all workflow forms will have the WORKFLOW_NAME parameter. It will
-- contain the actual workflow name when passed from a menu but when passed
-- from form to form, it will begin with '**'. This is so that we can work out
-- if we are entering a new workflow or not.
--
	--
	if p_param_workflow_name is null then
		--
		-- Not in workflow as no workflow name was specified. Try to
		-- get default workflow for this unit. If none exists then
		-- simply no buttons will be displayed for navigation.
		-- When searching for default:
		-- Obviously in top node here. Only one default_workflow_id
		-- should exist per form in the units table. Furthermore, only
		-- one node in the default workflow (corresponding to only one
		-- unit) will be the top node. Therefore only 1 row returned.
		--
		open default_workflow;
		fetch default_workflow
			into	p_workflow_id,
				p_dest_form,
				p_dest_block,
				p_nav_node_usage_id;
		--
		if default_workflow%found then
			--
			p_top_workflow_node	:= 'Y';
			p_default_found		:= 'Y';
		else
			p_top_workflow_node	:= 'N';
			p_default_found		:= 'N';

			p_workflow_id           := null ;
			p_nav_node_usage_id     := null ;
		end if;
		--
		close default_workflow;
		--
	elsif p_param_workflow_name like '**%' then
		--
		-- Not top workflow form but in workflow.
		-- Get workflow name and this form and block name (that which
		-- workflow knows about).
		--
		p_top_workflow_node     	:= 'N';
		p_dest_form			:= p_current_form;
		p_dest_block			:= p_current_block;
		p_nav_node_usage_id 		:= p_passed_nav_node_usage_id;
	else
		--
		-- Entering new workflow; get workflow name from parameter
		-- and also top node form/block name for use in navigation SQL.
		--
		open new_workflow;
		fetch new_workflow
			into	p_workflow_id,
				p_dest_form,
				p_dest_block,
				p_nav_node_usage_id;
		if new_workflow%notfound then
			close new_workflow;
			fnd_message.set_name('PAY',
				'HR_7068_WFLOW_NAME_NOT_FOUND');
			fnd_message.raise_error;
	   	end if;
		--
		close new_workflow;
		p_top_workflow_node	:= 'Y';
	end if;
--
-- Now get customization details. If this node does not have an enabled
-- customization then this SQL will simply fail (gracefully).
--

   if ( p_workflow_id is not null ) then

	open customization;
	fetch customization
		into	p_cust_rest_id,
			p_cust_appl_id,
			p_cust_query_title,
			p_cust_std_title,
			l_enabled;
	--
	-- If not enabled then give warning message otherwise write
	-- customization details.
	--
	if customization%found and l_enabled <> 'Y' then
		close customization ;
		fnd_message.set_name('PAY', 'HR_CUST_NOT_ENABLED');
		fnd_message.raise_error;
	end if;

	close customization ;

    end if;
--
end initiate_workflow;
----------------------------------------------------------------------------
END HR_WORKFLOW_PKG;

/
