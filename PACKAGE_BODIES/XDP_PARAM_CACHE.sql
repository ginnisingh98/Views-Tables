--------------------------------------------------------
--  DDL for Package Body XDP_PARAM_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PARAM_CACHE" AS
/* $Header: XDPPACHB.pls 120.1 2005/06/16 02:15:16 appldev  $ */


 Procedure CheckInited;
 Procedure setup_workitem_config(p_wi_instance_id in number);
 Procedure setup_fa_config(p_fa_instance_id in number);

 Procedure load_workitem_params;
 Procedure load_workitem_params(p_wi_param_list in varchar2);
 Procedure load_fa_params;

 Function get_param_index(p_param_type in varchar2,
			  p_param_name in varchar2) return number;

 Procedure get_wi_param_config(p_param_name in varchar2,
			    p_param_exists OUT NOCOPY varchar2,
			    p_log_flag OUT NOCOPY varchar2,
			    p_eval_mode OUT NOCOPY varchar2,
			    p_eval_proc OUT NOCOPY varchar2,
			    p_default_value OUT NOCOPY varchar2);

 Procedure get_fa_param_config(p_param_name in varchar2,
			    p_param_exists OUT NOCOPY varchar2,
			    p_log_flag OUT NOCOPY varchar2,
			    p_eval_proc OUT NOCOPY varchar2,
			    p_default_value OUT NOCOPY varchar2);

 Procedure Print;

-- Clear the Cache
 Procedure clear_cache
 is
 begin
	pv_workitem_instance_id := null;
	pv_workitem_id := null;
	pv_workitem_name := null;
	pv_workitem_type := null;

	pv_wi_eval_proc_name := null;

	pv_wi_item_type := null;
	pv_wi_process_name := null;
	pv_wi_key_prefix := null;

	pv_wi_param_list.delete;

	pv_fa_instance_id := null;
	pv_fa_id := null;
	pv_fa_name := null;

	pv_fe_routing_proc := null;

	pv_fa_param_list.delete;
 end clear_cache;


-- Init the Cache with Workitem Configuration alone
-- The Workitem Configurtion is gathered and the
-- Workitem Parameter configuration is loaded based
-- on the p_load_param_config flag
 Procedure init_cache(p_wi_instance_id number,
		      p_load_param_config in boolean default TRUE)
 is
 begin
	pv_workitem_instance_id := p_wi_instance_id;
	setup_workitem_config(p_wi_instance_id);
	if p_load_param_config then
		load_workitem_params;
	end if;
 end init_cache;

-- Init the Cache with Workitem Configuration alone
-- The Workitem Configurtion is gathered and the
-- Workitem Parameter configuration is loaded based
-- on the list of parameters specified
 Procedure init_cache(p_wi_instance_id number,
		      p_wi_param_list in varchar2,
		      p_load_param_config in boolean default TRUE)
 is
 begin
	pv_workitem_instance_id := p_wi_instance_id;
        setup_workitem_config(p_wi_instance_id);
        if p_load_param_config then
                load_workitem_params(p_wi_param_list);
        end if;
 end init_cache;

-- Init the Cache with Workitem and FA Configuration
-- Workitem Parameters and FA paramters configuration is loaded based
-- on the p_load_param_config flag
 Procedure init_cache(p_wi_instance_id number,
		      p_fa_instance_id number,
		      p_load_param_config in boolean default TRUE)
is
begin
	pv_workitem_instance_id := p_wi_instance_id;
	pv_fa_instance_id := p_fa_instance_id;

        setup_workitem_config(p_wi_instance_id);
        if p_load_param_config then
                load_workitem_params;
        end if;

        setup_fa_config(p_fa_instance_id);
        if p_load_param_config then
                load_fa_params;
        end if;

end init_cache;


--
-- Add a Work Item paramter to the Cache
Procedure Add_wi_param_to_cache(p_param_name in varchar2,
			p_param_value in varchar2,
			p_param_ref_value in varchar2 default null,
			p_log_flag in varchar2 default null,
			p_evaluation_mode in varchar2 default null,
			p_evaluation_proc in varchar2 default null,
			p_default_value in varchar2 default null,
			p_update_db in varchar2 default 'Y')

 is
  l_index number;
  l_eval_mode varchar2(80);
  l_log_flag varchar2(80);
  l_eval_proc varchar2(80);
  l_def_val varchar2(80);
  l_exists_flag varchar2(1);

 begin
	CheckInited;

	-- Check if the paramter is already in the Cache.
	-- If so the cache is updated
	-- Else the Parameter Configuratio is added
	l_index := get_param_index(g_WIParam, p_param_name);
	if l_index > 0 then
		-- Parameter already found. Update required
-- dbms_output.put_line(' -- Need to Update the cache:(WI) ' || p_param_name);
			pv_wi_param_list(l_index).parameter_value := p_param_value;
			if p_param_ref_value is not null then
				pv_wi_param_list(l_index).parameter_ref_value := p_param_ref_value;
			end if;
			if p_default_value is not null then
				pv_wi_param_list(l_index).default_value := p_default_value;
			end if;
	else
		-- Parameter not found. Need to add paramter configuration to
		-- the cache.
		-- Get the config and add it to the cache
-- dbms_output.put_line(' -- Need to add to cache: ' || p_param_name);
		get_wi_param_config(p_param_name => Add_wi_param_to_cache.p_param_name,
				 p_param_exists => l_exists_flag,
				 p_log_flag => l_log_flag,
				 p_eval_mode => l_eval_mode,
				 p_eval_proc => l_eval_proc,
				 p_default_value => l_def_val);

		if l_exists_flag = 'N' then
			l_log_flag := Add_wi_param_to_cache.p_log_flag;
			l_eval_mode := Add_wi_param_to_cache.p_evaluation_mode;
			l_eval_proc := Add_wi_param_to_cache.p_evaluation_proc;
			l_def_val := Add_wi_param_to_cache.p_default_value;
		end if;

			if pv_wi_param_list.count > 0 then
				l_index := pv_wi_param_list.last;
			else
				l_index := 0;
			end if;

			pv_wi_param_list(l_index+1).parameter_name := Add_wi_param_to_cache.p_param_name;
			pv_wi_param_list(l_index+1).parameter_value := Add_wi_param_to_cache.p_param_value;
			pv_wi_param_list(l_index+1).parameter_ref_value := Add_wi_param_to_cache.p_param_ref_value;
			pv_wi_param_list(l_index+1).log_flag := l_log_flag;
			pv_wi_param_list(l_index+1).evaluation_mode := l_eval_mode;
			pv_wi_param_list(l_index+1).evaluation_proc := l_eval_proc;
			pv_wi_param_list(l_index+1).default_value := l_def_val;

	end if;

-- This is for future.. The caching could be enhanced to update the DB
--	if p_update_db = 'Y' then
--		null;
--		xdp_engine.set_workitem_param_value
--				(p_wi_instance_id => pv_workitem_instance_id,
--				 p_parameter_name => Add_wi_param_to_cache.p_param_name,
--				 p_parameter_value => Add_wi_param_to_cache.p_param_value,
--				 p_parameter_reference_value => Add_wi_param_to_cache.p_param_ref_value);
--	end if;

 end Add_wi_param_to_cache;


--
-- Add a FA paramter to the Cache
Procedure Add_fa_param_to_cache(p_param_name in varchar2,
			p_param_value in varchar2,
			p_log_flag in varchar2 default null,
			p_evaluation_proc in varchar2 default null,
			p_default_value in varchar2 default null,
			p_update_db in varchar2 default 'Y')

 is
  l_index number;
  l_log_flag varchar2(80);
  l_eval_proc varchar2(80);
  l_def_val varchar2(80);
  l_exists_flag varchar2(1);

 begin
	CheckInited;

	-- Check if the paramter is already in the Cache.
	-- If so the cache is updated
	-- Else the Parameter Configuratio is added
	l_index := get_param_index(g_FAParam, p_param_name);
	if l_index > 0 then
		-- Paramter already exists in the Cache. Needs an update
		-- dbms_output.put_line(' -- Need to Update the cache: (FA) ' || p_param_name);
			pv_fa_param_list(l_index).parameter_value := p_param_value;
			if p_default_value is not null then
				pv_fa_param_list(l_index).default_value := p_default_value;
			end if;
	else
		-- Paramter does not exists in the Cache.
		-- Needs to fetch and add the paramter config to the cache
		-- dbms_output.put_line(' -- Need to add to cache:(FA) ' || p_param_name);
		get_fa_param_config(
				 p_param_name => Add_fa_param_to_cache.p_param_name,
				 p_param_exists => l_exists_flag,
				 p_log_flag => l_log_flag,
				 p_eval_proc => l_eval_proc,
				 p_default_value => l_def_val);

		if l_exists_flag = 'N' then
			l_log_flag := Add_fa_param_to_cache.p_log_flag;
			l_eval_proc := Add_fa_param_to_cache.p_evaluation_proc;
			l_def_val := Add_fa_param_to_cache.p_default_value;
		end if;

			if pv_fa_param_list.count > 0 then
				l_index := pv_fa_param_list.last;
			else
				l_index := 0;
			end if;

			pv_fa_param_list(l_index+1).parameter_name := Add_fa_param_to_cache.p_param_name;
			pv_fa_param_list(l_index+1).parameter_value := Add_fa_param_to_cache.p_param_value;
			pv_fa_param_list(l_index+1).log_flag := l_log_flag;
			pv_fa_param_list(l_index+1).evaluation_proc := l_eval_proc;
			pv_fa_param_list(l_index+1).default_value := l_def_val;

	end if;

-- This is for future.. The caching could be enhanced to update the DB
--	if p_update_db = 'Y' then
--		xdp_engine.set_fa_param_value
--				(p_fa_instance_id => pv_fa_instance_id,
--				 p_parameter_name => Add_fa_param_to_cache.p_param_name,
--				 p_parameter_value => Add_fa_param_to_cache.p_param_value);
--	end if;

 end Add_fa_param_to_cache;

--
-- Get the WI Paramter config information from the Cache
 Procedure Get_WI_param_from_cache(p_param_name in varchar2,
			  p_exists_in_cache OUT NOCOPY varchar2,
			  p_param_value OUT NOCOPY varchar2,
			  p_param_ref_value OUT NOCOPY varchar2,
			  p_log_flag OUT NOCOPY varchar2,
			  p_evaluation_mode OUT NOCOPY varchar2,
			  p_evaluation_proc OUT NOCOPY varchar2,
			  p_default_value OUT NOCOPY varchar2)
 is
	i number;
 begin
	CheckInited;

	p_exists_in_cache := 'N';

	-- Start from the First entry in the cache
	i := pv_wi_param_list.FIRST;
	while i is not null loop
		if pv_wi_param_list(i).parameter_name = Get_WI_param_from_cache.p_param_name then
			-- Found!!
			p_param_value := pv_wi_param_list(i).parameter_value;
			p_param_ref_value := pv_wi_param_list(i).parameter_ref_value;
			p_log_flag := pv_wi_param_list(i).log_flag;
			p_evaluation_mode := pv_wi_param_list(i).evaluation_mode;
			p_evaluation_proc := pv_wi_param_list(i).evaluation_proc;
			p_default_value := pv_wi_param_list(i).default_value;

			p_exists_in_cache := 'Y';
			exit;
		end if;

   		i := pv_wi_param_list.NEXT(i);  -- get subscript of next element
	end loop;

 end Get_WI_param_from_cache;

--
-- Get the WI Paramter config information from the Cache
 Procedure Get_FA_param_from_cache(p_param_name in varchar2,
			  p_exists_in_cache OUT NOCOPY varchar2,
			  p_param_value OUT NOCOPY varchar2,
			  p_log_flag OUT NOCOPY varchar2,
			  p_evaluation_proc OUT NOCOPY varchar2,
			  p_default_value OUT NOCOPY varchar2)
is

	i number;
 begin
	CheckInited;

	p_exists_in_cache := 'N';

	-- Start from the First entry in the cache
	i := pv_fa_param_list.FIRST;
	while i is not null loop
		if pv_fa_param_list(i).parameter_name = Get_fa_param_from_cache.p_param_name then
			-- Found it!!
			p_param_value := pv_fa_param_list(i).parameter_value;
			p_log_flag := pv_fa_param_list(i).log_flag;
			p_evaluation_proc := pv_fa_param_list(i).evaluation_proc;
			p_default_value := pv_fa_param_list(i).default_value;

			p_exists_in_cache := 'Y';
			exit;
		end if;

   		i := pv_fa_param_list.NEXT(i);  -- get subscript of next element
	end loop;

 end Get_FA_param_from_cache;

--
-- Remove an element from the Cache
 Procedure remove_from_cache(p_param_type in varchar2,
			     p_param_name in varchar2)
 is
  l_index number;
 begin
	CheckInited;

	-- Check if the Paramter exists in the cache and
	-- get the index to be deleted
	l_index := get_param_index(p_param_type, p_param_name);

	if l_index > 0 then
		-- Paramter exists.. Based on the parameter type
		-- delete the entry from the cache
		if p_param_type = g_WIParam then
			-- dbms_output.put_line('removing.. ' || l_index);
			pv_wi_param_list.delete(l_index);
		elsif  p_param_type = g_FAparam then
			pv_fa_param_list.delete(l_index);
		end if;
	end if;
 end;


--
-- Get the paramter location in the cache.
-- If the paramter is not found return 0
 Function get_param_index(p_param_type in varchar2,
                          p_param_name in varchar2) return number
 is
	l_index number := 0;
	i number := 0;
 begin

	-- Hit the Work Item Cache
	if p_param_type = g_WIParam then
		i := pv_wi_param_list.FIRST;
		while i is not null loop
			if pv_wi_param_list(i).parameter_name = p_param_name then
				-- Found it!!
				l_index := i;
				exit;
			end if;

			-- get subscript of next element
   			i := pv_wi_param_list.NEXT(i);
		end loop;
	elsif p_param_type = g_FAParam then
		-- Hit the FA Cache
		i := pv_fa_param_list.FIRST;
		while i is not null loop
			if pv_fa_param_list(i).parameter_name = p_param_name then
				-- Found it!!
				l_index := i;
				exit;
			end if;

			-- get subscript of next element
   			i := pv_fa_param_list.NEXT(i);
		end loop;

	end if;

	return (l_index);

 end get_param_index;

--
-- For a given Workitem_instance_id get the workitem
-- Configuration information
-- Work Item Name, Work Item ID, Version, Type, Mapping Procedure
-- User Defined Workflow Item Type, Process name and User Key
 Procedure setup_workitem_config(p_wi_instance_id in number)
 is

 begin
	for v_GetWIConfig in c_GetWiConfig(p_wi_instance_id) loop

		pv_workitem_id := v_GetWIConfig.workitem_id;
		pv_workitem_name := v_GetWIConfig.workitem_name;
		pv_workitem_type := v_GetWIConfig.wi_type_code;
		pv_wi_item_type := v_GetWIConfig.user_wf_item_type;
		pv_wi_process_name := v_GetWIConfig.user_wf_process_name;

		if v_GetWIConfig.fa_exec_map_proc is not null then
			pv_wi_eval_proc_name := v_GetWIConfig.fa_exec_map_proc;
		end if;

		if v_GetWIConfig.wf_exec_proc is not null then
			pv_wi_eval_proc_name := v_GetWIConfig.wf_exec_proc;
		end if;

        	pv_wi_key_prefix := v_GetWIConfig.user_wf_process_name;

	end loop;

	-- Print;
 end setup_workitem_config;


--
-- For a given fa_instance_id get the FA Configuration information
-- FA Name, FA ID,Routing Procedure
 Procedure setup_fa_config(p_fa_instance_id in number)
 is
 begin
	for v_GetFAConfig in c_GetFAConfig(p_fa_instance_id) loop

		pv_fa_id := v_GetFAConfig.fulfillment_action_id;
		pv_fa_name := v_GetFAConfig.fulfillment_action;
		pv_fe_routing_proc := v_GetFAConfig.fe_routing_proc;
	end loop;

	-- Print;
 end setup_fa_config;

--
-- Get the configuration for  particular workitem paramter
 Procedure get_wi_param_config(p_param_name in varchar2,
			    p_param_exists OUT NOCOPY varchar2,
			    p_log_flag OUT NOCOPY varchar2,
			    p_eval_mode OUT NOCOPY varchar2,
			    p_eval_proc OUT NOCOPY varchar2,
			    p_default_value OUT NOCOPY varchar2)
 is
 begin
   p_param_exists := 'N';

	for v_GetWiParamConfig in c_GetWiParamConfig (p_param_name) loop
		p_log_flag := v_GetWiParamConfig.log_in_audit_trail_flag;
		p_eval_mode := v_GetWiParamConfig.evaluation_mode;
		p_eval_proc := v_GetWiParamConfig.evaluation_procedure;
		p_default_value := v_GetWiParamConfig.default_value;

		p_param_exists := 'Y';
	end loop;

 end get_wi_param_config;

--
-- Get the configuration for  particular FA paramter
 Procedure get_fa_param_config(p_param_name in varchar2,
			    p_param_exists OUT NOCOPY varchar2,
			    p_log_flag OUT NOCOPY varchar2,
			    p_eval_proc OUT NOCOPY varchar2,
			    p_default_value OUT NOCOPY varchar2)
 is
 begin
   p_param_exists := 'N';

	for v_GetFAParamConfig in c_GetFAParamConfig (p_param_name) loop
		p_log_flag := v_GetFAParamConfig.log_in_audit_trail_flag;
		p_eval_proc := v_GetFAParamConfig.evaluation_procedure;
		p_default_value := v_GetFAParamConfig.default_value;

		p_param_exists := 'Y';
	end loop;

 end get_fa_param_config;


 Procedure CheckInited
 is
 begin
	if pv_workitem_instance_id is null or pv_fa_instance_id is null then
		raise_application_error(-20012,'Cache Not Initialized');
	end if;

 end CheckInited;

 Procedure load_workitem_params
 is
 begin
	for v_GetWiParams in c_GetWiParams  loop
 		Add_wi_param_to_cache(	p_param_name => v_GetWiParams.parameter_name,
				p_param_value => NULL,
				p_param_ref_value => NULL,
				p_log_flag => v_GetWiParams.log_in_audit_trail_flag,
				p_evaluation_mode => v_GetWiParams.evaluation_mode,
				p_evaluation_proc => v_GetWiParams.evaluation_procedure,
				p_default_value => v_GetWiParams.default_value,
				p_update_db => 'N');

	end loop;

 end load_workitem_params;

 Procedure load_workitem_params(p_wi_param_list in varchar2)
 is
 begin
	if p_wi_param_list is null then
		load_workitem_params;
	else
		for v_GetWiParams in c_GetWiParams  loop
		  if INSTR( upper(p_wi_param_list),
			    upper(v_GetWiParams.parameter_name), 1, 1 ) > 0 then
 			Add_wi_param_to_cache(	p_param_name => v_GetWiParams.parameter_name,
					p_param_value => NULL,
					p_param_ref_value => NULL,
					p_log_flag => v_GetWiParams.log_in_audit_trail_flag,
					p_evaluation_mode => v_GetWiParams.evaluation_mode,
					p_evaluation_proc => v_GetWiParams.evaluation_procedure,
					p_default_value => v_GetWiParams.default_value,
					p_update_db => 'N');
		  end if;

		end loop;
	end if;

 end load_workitem_params;

 Procedure load_fa_params
 is
 begin
	for v_GetFAParams in c_GetFAParams  loop
 		Add_fa_param_to_cache(	p_param_name => v_GetFAParams.parameter_name,
				p_param_value => NULL,
				p_log_flag => v_GetFAParams.log_in_audit_trail_flag,
				p_evaluation_proc => v_GetFAParams.evaluation_procedure,
				p_default_value => v_GetFAParams.default_value,
				p_update_db => 'N');

	end loop;

 end load_fa_params;


Procedure Print
is

begin
	null;
	-- dbms_output.put_line('WI Inst: ' || pv_workitem_instance_id || ':');
	-- dbms_output.put_line('WI ID: ' || pv_workitem_id || ':');

	-- dbms_output.put_line('Name: ' || pv_workitem_name || ':');
	-- dbms_output.put_line('Type: ' || pv_workitem_type || ':');

	-- dbms_output.put_line('Eval: ' || pv_wi_eval_proc_name|| ':');

	-- dbms_output.put_line('WF Type: ' || pv_wi_item_type || ':');
	-- dbms_output.put_line('WF Process: ' || pv_wi_process_name || ':');
	-- dbms_output.put_line('WF Key: ' || pv_wi_key_prefix || ':');


	-- dbms_output.put_line('FA Inst: ' || pv_fa_instance_id || ':');
	-- dbms_output.put_line('FA ID: ' || pv_fa_id || ':');

	-- dbms_output.put_line('Name: ' || pv_fa_name || ':');
	-- dbms_output.put_line('Routing Proc: ' || pv_fe_routing_proc || ':');

end Print;


end XDP_PARAM_CACHE;

/
