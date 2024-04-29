--------------------------------------------------------
--  DDL for Package Body FND_OAM_BF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_BF_UTIL" as
/* $Header: AFOAMFLB.pls 120.3 2005/08/13 00:49:01 ppradhan noship $ */

   --
   -- Debug flag - Set this to FALSE before checking in
   --
   g_debug constant boolean := FALSE;

   --
   -- Debug Only
   --
   PROCEDURE debug(pStr Varchar2)
   IS

   BEGIN
	--dbms_output.put_line(pStr);
	null;
   END;

   FUNCTION get_user_id RETURN number
   IS
	v_userid number;
	v_conc_req_id number;
   BEGIN
	-- check if its concurrent request
	select fnd_global.conc_request_id into v_conc_req_id from dual;
	if v_conc_req_id > 0 then
	  select fcr.requested_by into v_userid
	    from fnd_concurrent_requests fcr
	    where fcr.request_id = v_conc_req_id;
	else
	  select fnd_global.user_id into v_userid from dual;
	  if (v_userid < 0 or v_userid is null) then
		v_userid := 0; -- default
          end if;
	end if;

	return v_userid;
   EXCEPTION
	when others then
	  v_userid := 0;
	  return v_userid;
   END get_user_id;

   PROCEDURE load_wit_info(
	p_item_type varchar2,
	p_count_errored_items number,
	p_count_active_items number)
   IS
	v_x number;
	v_userid number := 0;
   BEGIN
	v_userid := get_user_id;
	select 1 into v_x
	  from fnd_oam_bf_wit_info
	  where item_type = p_item_type;

	-- update
	update fnd_oam_bf_wit_info
		set count_errored_items = p_count_errored_items,
		    count_active_items = p_count_active_items,
		    last_updated_by = v_userid,
		    last_update_date = sysdate,
		    last_update_login = 0
		where item_type = p_item_type;
   EXCEPTION
	when no_data_found then
		insert into fnd_oam_bf_wit_info (
			item_type,
			count_errored_items,
			count_active_items,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		values (
			p_item_type,
			p_count_errored_items,
			p_count_active_items,
			v_userid,
			sysdate,
			v_userid,
			sysdate,
			0);
	when others then
		raise;
  END load_wit_info;

  PROCEDURE load_comp_info(
	p_component_type varchar2,
	p_component_appl_id number,
	p_component_id number,
	p_count_alerts number,
	p_count_errored_requests number,
	p_setup_status number,
	p_test_status number,
	p_diagnostic_test_status number,
	p_count_running_requests number,
	p_count_form_sessions number,
	p_count_ssf_sessions number)
   IS
	v_x number;
	v_userid number := 0;
   BEGIN
	v_userid := get_user_id;
	select 1 into v_x
	  from fnd_oam_bf_comp_info
	  where component_type = p_component_type
	  and component_appl_id = p_component_appl_id
	  and component_id = p_component_id;

	-- update
	update fnd_oam_bf_comp_info
		set count_alerts = p_count_alerts,
		    count_errored_requests = p_count_errored_requests,
		    setup_status = p_setup_status,
		    test_status = p_test_status,
		    diagnostic_test_status = p_diagnostic_test_status,
		    count_running_requests = p_count_running_requests,
		    count_form_sessions = p_count_form_sessions,
		    count_ssf_sessions = p_count_ssf_sessions,
		    last_updated_by = v_userid,
		    last_update_date = sysdate,
		    last_update_login = 0
		where component_type = p_component_type
	  	    and component_appl_id = p_component_appl_id
	  	    and component_id = p_component_id;
   EXCEPTION
	when no_data_found then
		insert into fnd_oam_bf_comp_info (
			component_type,
			component_appl_id,
			component_id,
			count_alerts,
			count_errored_requests,
			setup_status,
			test_status,
			diagnostic_test_status,
			count_running_requests,
			count_form_sessions,
			count_ssf_sessions,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		values (
			p_component_type,
			p_component_appl_id,
			p_component_id,
			p_count_alerts,
			p_count_errored_requests,
			p_setup_status,
			p_test_status,
			p_diagnostic_test_status,
			p_count_running_requests,
			p_count_form_sessions,
			p_count_ssf_sessions,
			v_userid,
			sysdate,
			v_userid,
			sysdate,
			0);
	when others then
		raise;
   END load_comp_info;

  PROCEDURE load_rollup_info(
	p_biz_flow_key varchar2,
	p_count_alerts number,
	p_count_errored_requests number,
	p_count_errored_work_items number,
	p_setup_status number,
	p_test_status number,
	p_diagnostic_test_status number,
	p_count_running_requests number,
	p_count_form_sessions number,
	p_count_ssf_sessions number,
	p_count_active_work_items number)
   IS
	v_x number;
	v_userid number := 0;
   BEGIN
	v_userid := get_user_id;
	select 1 into v_x
	  from fnd_oam_bf_rollup_info
	  where biz_flow_key = p_biz_flow_key;

	-- update
	update fnd_oam_bf_rollup_info
		set count_alerts = p_count_alerts,
		    count_errored_requests = p_count_errored_requests,
		    count_errored_work_items = p_count_errored_work_items,
		    setup_status = p_setup_status,
		    test_status = p_test_status,
		    diagnostic_test_status = p_diagnostic_test_status,
		    count_running_requests = p_count_running_requests,
		    count_form_sessions = p_count_form_sessions,
		    count_ssf_sessions = p_count_ssf_sessions,
		    count_active_work_items = p_count_active_work_items,
		    last_updated_by = v_userid,
		    last_update_date = sysdate,
		    last_update_login = 0
		where biz_flow_key = p_biz_flow_key;
   EXCEPTION
	when no_data_found then
		insert into fnd_oam_bf_rollup_info (
			biz_flow_key,
			count_alerts,
			count_errored_requests,
			count_errored_work_items,
			setup_status,
			test_status,
			diagnostic_test_status,
			count_running_requests,
			count_form_sessions,
			count_ssf_sessions,
			count_active_work_items,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		values (
			p_biz_flow_key,
			p_count_alerts,
			p_count_errored_requests,
			p_count_errored_work_items,
			p_setup_status,
			p_test_status,
			p_diagnostic_test_status,
			p_count_running_requests,
			p_count_form_sessions,
			p_count_ssf_sessions,
			p_count_active_work_items,
			v_userid,
			sysdate,
			v_userid,
			sysdate,
			0);
	when others then
		raise;
   END load_rollup_info;

  --
  -- Name
  --   compute_metrics
  --
  -- Purpose
  --   computes metrics related to business flows such as
  --    - count of open system alerts
  --    - count of errored concurrent requests
  --    - count of errored work items
  --    - count of active work items
  --    - count of running concurrent requests
  --    - count of active form sessions
  --    - count of active ssf sessions (last hour)
  --
  --   The resulting values will get populated into fnd_oam_bf_comp_info,
  --   fnd_oam_bf_wit_info tables.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE compute_metrics
  IS
	cursor c_comps is
	  select distinct component_type, component_appl_id, component_id
		from fnd_oam_bf_comp
	  union
	  select distinct component_type, component_appl_id, component_id
		from fnd_oam_bf_comp_cust;
	cursor c_wits is
	  select distinct item_type
		from fnd_oam_bf_wit
	  union
	  select distinct item_type
		from fnd_oam_bf_wit_cust ;
  BEGIN
	-- for each associated components count the
	-- number of open and new system
	-- alerts and errored concurrent requests
	for comp in c_comps loop
	  declare
	    v_alerts number;
	    v_err_requests number;
	    v_running_requests number;
	    v_form_sessions number;
	    v_ssf_sessions number;
	  begin
	    -- count the open or new system alerts for this component
	    select count(distinct(flue.unique_exception_id))
	      into v_alerts
	      from fnd_log_unique_exceptions flue,
	        fnd_log_messages flm,
		fnd_log_exceptions fle,
		fnd_log_transaction_context fltc
	      where fltc.transaction_context_id = flm.transaction_context_id
		and flm.log_sequence = fle.log_sequence
		and fle.unique_exception_id = flue.unique_exception_id
		and fltc.component_type = comp.component_type
		and fltc.component_id = comp.component_id
		and nvl(fltc.component_appl_id, -1) = comp.component_appl_id
		and flue.status in ('O','N');

	    -- count the errored requests for this component, within
            -- last 24 hours
	    if comp.component_type = 'CONCURRENT_PROGRAM' then
	      select count(*) into v_err_requests
		from fnd_concurrent_requests
		where phase_code='C'
		and status_code='E'
		and concurrent_program_id = comp.component_id
		and program_application_id = comp.component_appl_id
		and actual_completion_date > sysdate - 1;

	      select count(*) into v_running_requests
		from fnd_concurrent_requests
		where phase_code = 'R'
		and concurrent_program_id = comp.component_id
		and program_application_id = comp.component_appl_id;
	    end if;

            -- compute FORM specific metrics
	    if comp.component_type = 'FORM' then
	      select count(*) into v_form_sessions
		from fnd_form_sessions_v
		where form_id = comp.component_id
		and form_appl_id = comp.component_appl_id;
	    end if;

	    -- compute FUNCTION specific metrics
	    if comp.component_type = 'FUNCTION' then
	      -- ssf sessions within the last hour for the given function
	      select count(*) into v_ssf_sessions
		from icx_sessions
		where function_id = comp.component_id
		and last_connect > sysdate - 1/24;
	    end if;

	    load_comp_info(
		p_component_type => comp.component_type,
		p_component_appl_id => comp.component_appl_id,
		p_component_id => comp.component_id,
		p_count_alerts => v_alerts,
		p_count_errored_requests => v_err_requests,
		p_setup_status => null,
		p_test_status => null,
		p_diagnostic_test_status => null,
		p_count_running_requests => v_running_requests,
		p_count_form_sessions => v_form_sessions,
		p_count_ssf_sessions => v_ssf_sessions);
	  end;
	end loop;

	-- for each associated  work item type, count the
	-- number of errored work items
	for wit_x in c_wits loop
	  declare
	    v_err_wi number;
	    v_active_wi number;
	  begin
	    select count(distinct(item_key))
		into v_err_wi
		from wf_item_activity_statuses wias,
		     wf_item_types wit
		where wias.activity_status = 'ERROR'
		     and wias.item_type = wit.name
		     and wias.item_type = wit_x.item_type;

	   select count(distinct(item_key))
		into v_active_wi
		from wf_items i
		where i.end_date is null
		and i.item_type = wit_x.item_type;

	    load_wit_info(
		p_item_type => wit_x.item_type,
		p_count_errored_items => v_err_wi,
		p_count_active_items => v_active_wi);
	  end;
	end loop;
  END compute_metrics;

  --
  -- Computes the rolled values for the given metrics and loads it into the
  -- fnd_oam_bf_rollup_info table. Rollup values are based only on
  -- associations for which the monitored_flag='Y'
  --
  --   1) p_count_alerts - Total count of open/new alerts for this flow
  --   2) p_count_err_requests - Total count of errored concurrent requests
  --      	for this flow.
  --   3) p_count_err_wi - Total count of errored work items
  --
  PROCEDURE load_rollup(
	p_flow_key varchar2,
	p_count_alerts OUT NOCOPY number,
	p_count_err_requests OUT NOCOPY number,
	p_count_err_wi OUT NOCOPY number,
	p_count_running_requests OUT NOCOPY number,
	p_count_form_sessions OUT NOCOPY number,
	p_count_ssf_sessions OUT NOCOPY number,
	p_count_active_wi OUT NOCOPY number)
  IS
	v_flow_key fnd_oam_bf.biz_flow_key%type := p_flow_key;
	v_count_alerts number := 0;
	v_count_err_requests number := 0;
	v_count_err_wi number := 0;
	v_count_running_requests number := 0;
	v_count_form_sessions number := 0;
	v_count_ssf_sessions number := 0;
	v_count_active_wi number := 0;

     -- For all monitored flows under this flow
     cursor c_monitored_flows is
	select ba.biz_flow_child_key biz_flow_key from fnd_oam_bf_assoc ba
	  where ba.biz_flow_parent_key = p_flow_key
	and ((ba.monitored_flag='Y' and 1 not in (
	select count(*)
	  from fnd_oam_bf_assoc_cust cust
	  where cust.biz_flow_child_key = ba.biz_flow_child_key
	    and cust.biz_flow_parent_key = ba.biz_flow_parent_key
	    and cust.monitored_flag = 'N'))
	or (ba.monitored_flag='N' and 1 in (
	select count(*)
	  from fnd_oam_bf_assoc_cust cust
	  where cust.biz_flow_child_key = ba.biz_flow_child_key
	    and cust.biz_flow_parent_key = ba.biz_flow_parent_key
	    and cust.monitored_flag='Y'))
	)
	union
	select ba.biz_flow_child_key biz_flow_key from fnd_oam_bf_assoc_cust ba
	  where ba.biz_flow_parent_key = p_flow_key
	  and ba.monitored_flag = 'Y'
	  and ba.biz_flow_child_key not in
		(select x.biz_flow_child_key from fnd_oam_bf_assoc x
		   where x.biz_flow_parent_key = p_flow_key);

     -- For all monitored components under this flow
     cursor c_monitored_components is
	select c.component_type, c.component_appl_id, c.component_id
	   from fnd_oam_bf_comp c
	   where c.biz_flow_key = p_flow_key
	and ((c.monitored_flag='Y' and 1 not in (
	select count(*)
	  from fnd_oam_bf_comp_cust cust
	  where cust.component_type = c.component_type
	    and cust.component_appl_id = c.component_appl_id
	    and cust.component_id = c.component_id
	    and cust.biz_flow_key = c.biz_flow_key
	    and cust.monitored_flag='N'))
	or (c.monitored_flag = 'N' and 1 in (
	select count(*)
	  from fnd_oam_bf_comp_cust cust
	  where cust.component_type = c.component_type
	    and cust.component_appl_id = c.component_appl_id
	    and cust.component_id = c.component_id
	    and cust.biz_flow_key = c.biz_flow_key
	    and cust.monitored_flag='Y'))
	)
    	union
	select c.component_type, c.component_appl_id, c.component_id
	  from fnd_oam_bf_comp_cust c
	  where c.biz_flow_key = p_flow_key
	  and c.monitored_flag = 'Y'
	  and c.component_type || ':' ||
	      c.component_appl_id || ':' ||
	      c.component_id not in
		(select x.component_type || ':' ||
		        x.component_appl_id || ':' ||
		 	x.component_id
		 from fnd_oam_bf_comp x
		 where x.biz_flow_key = p_flow_key);

     -- For all monitored work item types directly associated with this flow
     cursor c_monitored_wit is
	select w.item_type from fnd_oam_bf_wit w
	  where w.biz_flow_key = p_flow_key
	and ((w.monitored_flag = 'Y' and 1 not in (
	select count(*) from fnd_oam_bf_wit_cust cust
	 where cust.item_type = w.item_type
	  and cust.biz_flow_key = w.biz_flow_key
	  and cust.monitored_flag = 'N'))
	or (w.monitored_flag = 'N' and 1 in (
	select count(*) from fnd_oam_bf_wit_cust cust
	 where cust.item_type = w.item_type
	  and cust.biz_flow_key = w.biz_flow_key
	  and cust.monitored_flag = 'Y'))
	)
	union
	select w.item_type from fnd_oam_bf_wit_cust w
	where w.biz_flow_key = p_flow_key
	and w.monitored_flag = 'Y'
	and w.item_type not in
		(select x.item_type from fnd_oam_bf_wit x
		  where x.biz_flow_key = p_flow_key);

  BEGIN
	if (g_debug) then
	  debug('CURRENT: ' || v_flow_key);
	end if;
	-- get counts for components directly associated with this flow
	for c in c_monitored_components loop
	  declare
	    v_temp_alerts number;
	    v_temp_err_req number;
	    v_temp_running_req number;
	    v_temp_form_sessions number;
	    v_temp_ssf_sessions number;
          begin
	    select nvl(count_alerts,0), nvl(count_errored_requests,0),
		 nvl(count_running_requests,0), nvl(count_form_sessions,0),
		 nvl(count_ssf_sessions,0)
		into v_temp_alerts, v_temp_err_req, v_temp_running_req,
		     v_temp_form_sessions, v_temp_ssf_sessions
		from fnd_oam_bf_comp_info
		where component_type = c.component_type
		and component_appl_id = c.component_appl_id
		and component_id = c.component_id;
	    v_count_alerts := v_count_alerts + v_temp_alerts;
	    v_count_err_requests := v_count_err_requests + v_temp_err_req;
	    v_count_running_requests := v_count_running_requests + v_temp_running_req;
	    v_count_form_sessions := v_count_form_sessions + v_temp_form_sessions;
	    v_count_ssf_sessions := v_count_ssf_sessions + v_temp_ssf_sessions;
	    if (g_debug) then
	      debug(c.component_type || ': ' ||
		v_temp_alerts || ' ' || v_temp_err_req || ' ' ||
		v_temp_running_req || ' ' || v_temp_form_sessions || ' ' ||
		v_temp_ssf_sessions);
	    end if;
	  end;
	end loop;

	-- get counts for work item types directly associated with this flow
	for w in c_monitored_wit loop
	  declare
	    v_temp_err_wi number := 0;
	    v_temp_active_wi number := 0;
          begin
	    select nvl(count_errored_items,0), nvl(count_active_items,0)
		into v_temp_err_wi, v_temp_active_wi
		from fnd_oam_bf_wit_info
		where item_type = w.item_type;
	    v_count_err_wi := v_count_err_wi + v_temp_err_wi;
	    v_count_active_wi := v_count_active_wi + v_temp_active_wi;
	  end;
	end loop;

	-- now add the counts for all the children
	for fl in c_monitored_flows loop
	  declare
	    v_abs_cust_mflag varchar2(1);
	  begin
	    begin
	     -- check the absolute monitored flag for seeded flow
	     select
		   nvl(fbc.monitored_flag,fb.monitored_flag)
	      into v_abs_cust_mflag
	      from fnd_oam_bf fb, fnd_oam_bf_cust fbc
	      where fb.biz_flow_key = fbc.biz_flow_key (+)
		and fb.biz_flow_key=fl.biz_flow_key;
	    exception
	      when no_data_found then
	       -- check the absolute monitored flag for user created flow
	       select fbc.monitored_flag
	        into v_abs_cust_mflag
	        from fnd_oam_bf_cust fbc
	        where fbc.biz_flow_key=fl.biz_flow_key;
	    end;

	    if (v_abs_cust_mflag = 'Y') then
		-- we need to monitor this child so recurse
		declare
		  x_count_alerts  number;
		  x_count_err_requests number;
		  x_count_err_wi number;
		  x_count_running_requests number;
		  x_count_form_sessions number;
		  x_count_ssf_sessions number;
		  x_count_active_wi number;
		begin
		  load_rollup(
			p_flow_key => fl.biz_flow_key,
			p_count_alerts => x_count_alerts,
			p_count_err_requests => x_count_err_requests,
			p_count_err_wi => x_count_err_wi,
			p_count_running_requests => x_count_running_requests,
			p_count_form_sessions => x_count_form_sessions,
			p_count_ssf_sessions => x_count_ssf_sessions,
			p_count_active_wi => x_count_active_wi);

		  load_rollup_info(
			p_biz_flow_key => fl.biz_flow_key,
			p_count_alerts => x_count_alerts,
			p_count_errored_requests => x_count_err_requests,
			p_count_errored_work_items => x_count_err_wi,
			p_setup_status => null,
			p_test_status => null,
			p_diagnostic_test_status => null,
			p_count_running_requests => x_count_running_requests,
			p_count_form_sessions => x_count_form_sessions,
			p_count_ssf_sessions => x_count_ssf_sessions,
			p_count_active_work_items => x_count_active_wi);

                  if (g_debug) then
		    debug(fl.biz_flow_key || ':' ||
			x_count_alerts || ' ' || x_count_err_requests || ' ' ||
			x_count_err_wi || ' ' || x_count_running_requests ||
			' ' || x_count_form_sessions || ' ' ||
			x_count_ssf_sessions || ' ' || x_count_active_wi);
		  end if;
		  v_count_alerts := v_count_alerts + x_count_alerts;
		  v_count_err_requests := v_count_err_requests + x_count_err_requests;
		  v_count_err_wi := v_count_err_wi + x_count_err_wi;
		  v_count_running_requests := v_count_running_requests + x_count_running_requests;
		  v_count_form_sessions := v_count_form_sessions + x_count_form_sessions;
		  v_count_ssf_sessions := v_count_ssf_sessions + x_count_ssf_sessions;
		  v_count_active_wi := v_count_active_wi + x_count_active_wi;
		end;
	    end if;
	  end;
	end loop;

	-- finally update the out parameters and load the info into
	-- fnd_oam_bf_rollup_info
	p_count_alerts := v_count_alerts;
	p_count_err_requests := v_count_err_requests;
	p_count_err_wi := v_count_err_wi;
        p_count_running_requests := v_count_running_requests;
	p_count_form_sessions := v_count_form_sessions;
	p_count_ssf_sessions := v_count_ssf_sessions;
	p_count_active_wi := v_count_active_wi;



  END load_rollup;


  --
  -- Name
  --   rollup_metrics
  --
  -- Purpose
  --   Rolls up metrics related to business flows such as
  --    - count of open system alerts
  --    - count of errored concurrent requests
  --    - count of errored work items
  --
  --   The resulting values will get populated into fnd_oam_bf_rollup_info
  --   tables.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE rollup_metrics
  IS
	cursor c_monitored_key_flows is
	  select
	      fb.biz_flow_key biz_flow_key
	      from fnd_oam_bf fb, fnd_oam_bf_cust fbc
	      where fb.biz_flow_key = fbc.biz_flow_key (+)
		and fb.is_top_level = 'Y'
		and nvl(fbc.monitored_flag,fb.monitored_flag) = 'Y'
	  union
	  select fbc.biz_flow_key biz_flow_key
	      from fnd_oam_bf_cust fbc
	      where fbc.monitored_flag = 'Y'
		and fbc.is_top_level = 'Y'
		and fbc.biz_flow_key not in (
		   select fb.biz_flow_key from fnd_oam_bf fb
			where fb.is_top_level = 'Y');

	v_count_alerts number;
	v_count_err_requests number;
	v_count_err_wi number;
	v_count_running_requests number;
	v_count_form_sessions number;
	v_count_ssf_sessions number;
	v_count_active_wi number;
  BEGIN
	for fl in c_monitored_key_flows loop
		load_rollup(
			p_flow_key => fl.biz_flow_key,
			p_count_alerts => v_count_alerts,
			p_count_err_requests => v_count_err_requests,
			p_count_err_wi => v_count_err_wi,
			p_count_running_requests => v_count_running_requests,
			p_count_form_sessions => v_count_form_sessions,
			p_count_ssf_sessions => v_count_ssf_sessions,
			p_count_active_wi => v_count_active_wi);
		load_rollup_info(
			p_biz_flow_key => fl.biz_flow_key,
			p_count_alerts => v_count_alerts,
			p_count_errored_requests => v_count_err_requests,
			p_count_errored_work_items => v_count_err_wi,
			p_setup_status => null,
			p_test_status => null,
			p_diagnostic_test_status => null,
			p_count_running_requests => v_count_running_requests,
			p_count_form_sessions => v_count_form_sessions,
			p_count_ssf_sessions => v_count_ssf_sessions,
			p_count_active_work_items => v_count_active_wi);
	end loop;
  END rollup_metrics;

  --
  -- Name
  --   refresh_metrics
  --
  -- Purpose
  --   computes and rolls up metrics related to business flows such as
  --    - count of open system alerts
  --    - count of errored concurrent requests
  --    - count of errored work items
  --
  --   The resulting values will get populated into fnd_oam_bf_comp_info,
  --   fnd_oam_bf_wit_info and fnd_oam_bf_rollup_info tables.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_metrics
  IS

  BEGIN
	fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Start compute_metrics');
	compute_metrics;
	fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> End compute_metrics');
	fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> Start rollup_metrics');
	rollup_metrics;
	fnd_file.put_line(fnd_file.log, to_char(sysdate,'HH24:MI:SS')||'> End rollup_metrics');
  END refresh_metrics;

  --
  -- Updates the monitored flag for the given flow
  -- Updates fnd_oam_bf_cust if record exists for given flow key
  -- Otherwise, copies entry from fnd_oam_bf to
  -- fnd_oam_bf_cust and updates the monitored_flag in
  -- fnd_oam_bf_cust.
  --
  --
  PROCEDURE update_bf_monitored_flag (
	p_flow_key varchar2,
	p_new_flag varchar2)
  IS
    v_userid number;
    v_cust_flag number := 0;
    v_base_monitored_flag varchar2(1);
  BEGIN
    v_userid := get_user_id;
    begin
      select 1 into v_cust_flag from fnd_oam_bf_cust
        where biz_flow_key = p_flow_key;
    exception
      when no_data_found then
        v_cust_flag := 0;
    end;

    if (v_cust_flag = 0) then
--      select monitored_flag into v_base_monitored_flag
--	 from fnd_oam_bf
--	 where biz_flow_key = p_flow_key;
--
--      if (v_base_monitored_flag <> p_new_flag) then
--        -- copy over record to cust table
--        insert into fnd_oam_bf_cust(
--	  biz_flow_key, monitored_flag, is_top_level,
--	  created_by, creation_date, last_updated_by, last_update_date,
--	  last_update_login)
--	   select biz_flow_key, monitored_flag, is_top_level,
--	     created_by, creation_date, last_updated_by, last_update_date,
--	     last_update_login
--	     from fnd_oam_bf
--	     where biz_flow_key = p_flow_key;
--	insert into fnd_oam_bf_cust_tl(
--	  biz_flow_key, language, flow_display_name, description,
--	  created_by, creation_date, last_updated_by, last_update_date,
--	  last_update_login, source_lang)
--	   select biz_flow_key, language, flow_display_name, description,
--	     created_by, creation_date, last_updated_by, last_update_date,
--	     last_update_login, source_lang
--	     from fnd_oam_bf_tl
--	     where biz_flow_key = p_flow_key;
--      end if;
	-- now update fnd_oam_bf
    	update fnd_oam_bf set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_flow_key;
    else
	-- now update fnd_oam_bf_cust
    	update fnd_oam_bf_cust set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_flow_key;
    end if;

  EXCEPTION
	when others then
		raise;
  END update_bf_monitored_flag;

  --
  -- Updates the monitored flag for the given sub flow in context of the
  -- given parent flow.
  -- Updates fnd_oam_bf_assoc_cust if record exists for given parent
  -- and child. Otherwise, copies entry from fnd_oam_bf_assoc to
  -- fnd_oam_bf_assoc_cust and updates the monitored_flag in
  -- fnd_oam_bf_assoc_cust.
  --
  --
  PROCEDURE update_bf_monitored_flag (
	p_parent_flow_key varchar2,
	p_child_flow_key varchar2,
	p_new_flag varchar2)
  IS
    v_userid number;
    v_cust_flag number := 0;
    v_base_monitored_flag varchar2(1);
  BEGIN
    v_userid := get_user_id;
    begin
      select 1 into v_cust_flag from fnd_oam_bf_assoc_cust
        where biz_flow_parent_key = p_parent_flow_key
	and biz_flow_child_key = p_child_flow_key;
    exception
      when no_data_found then
        v_cust_flag := 0;
    end;

    if (v_cust_flag = 0) then
--      select monitored_flag into v_base_monitored_flag
--	 from fnd_oam_bf_assoc
--	 where biz_flow_parent_key = p_parent_flow_key
--	 and biz_flow_child_key = p_child_flow_key;
--
--      if (v_base_monitored_flag <> p_new_flag) then
--        -- copy over record to cust table
--        insert into fnd_oam_bf_assoc_cust(
--	  biz_flow_parent_key, biz_flow_child_key, monitored_flag,
--	  created_by, creation_date, last_updated_by, last_update_date,
--	  last_update_login)
--	   select biz_flow_parent_key, biz_flow_child_key, monitored_flag,
--	     created_by, creation_date, last_updated_by, last_update_date,
--	     last_update_login
--	     from fnd_oam_bf_assoc
--	     where biz_flow_parent_key = p_parent_flow_key
--	     and biz_flow_child_key = p_child_flow_key;
--      end if;
	-- now update fnd_oam_bf_assoc
    	update fnd_oam_bf_assoc set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_parent_key = p_parent_flow_key
		and biz_flow_child_key = p_child_flow_key;
    else
	-- now update fnd_oam_bf_assoc_cust
    	update fnd_oam_bf_assoc_cust set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_parent_key = p_parent_flow_key
		and biz_flow_child_key = p_child_flow_key;
    end if;
  EXCEPTION
	when others then
		raise;
  END update_bf_monitored_flag;


  --
  -- Updates the monitored flag for the given component in context of the
  -- given parent flow.
  -- Updates fnd_oam_bf_comp_cust if record exists for given parent
  -- and child. Otherwise, copies entry from fnd_oam_bf_comp to
  -- fnd_oam_bf_comp_cust and updates the monitored_flag in
  -- fnd_oam_bf_comp_cust.
  --
  --
  PROCEDURE update_comp_monitored_flag (
	p_parent_flow_key varchar2,
	p_component_type varchar2,
        p_component_appl_id number,
	p_component_id number,
	p_new_flag varchar2)
  IS
    v_userid number;
    v_cust_flag number := 0;
    v_base_monitored_flag varchar2(1);
  BEGIN
    v_userid := get_user_id;
    begin
      select 1 into v_cust_flag from fnd_oam_bf_comp_cust
        where biz_flow_key = p_parent_flow_key
	and component_type = p_component_type
	and component_appl_id = p_component_appl_id
	and component_id = p_component_id;
    exception
      when no_data_found then
        v_cust_flag := 0;
    end;

    if (v_cust_flag = 0) then
--      select monitored_flag into v_base_monitored_flag
--	 from fnd_oam_bf_comp
--	 where biz_flow_key = p_parent_flow_key
--	 and component_type = p_component_type
--	 and component_appl_id = p_component_appl_id
--	 and component_id = p_component_id;
--
--      if (v_base_monitored_flag <> p_new_flag) then
--       -- copy over record to cust table
--        insert into fnd_oam_bf_comp_cust(
--	  biz_flow_key, component_type, component_appl_id, component_id,
--	  monitored_flag,
--	  created_by, creation_date, last_updated_by, last_update_date,
--	  last_update_login)
--	   select biz_flow_key,component_type,component_appl_id, component_id,
--	     monitored_flag,
--	     created_by, creation_date, last_updated_by, last_update_date,
--	     last_update_login
--	     from fnd_oam_bf_comp
--	     where biz_flow_key = p_parent_flow_key
--	     and component_type = p_component_type
--	     and component_appl_id = p_component_appl_id
--	     and component_id = p_component_id;
--      end if;
	-- now update regular table
    	update fnd_oam_bf_comp set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_parent_flow_key
		and component_type = p_component_type
		and component_appl_id = p_component_appl_id
		and component_id = p_component_id;
    else
  	-- now update cust table
    	update fnd_oam_bf_comp_cust set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_parent_flow_key
		and component_type = p_component_type
		and component_appl_id = p_component_appl_id
		and component_id = p_component_id;
    end if;


  EXCEPTION
	when others then
		raise;
  END update_comp_monitored_flag;

  --
  -- Updates the monitored flag for the given item type in context of the
  -- given parent flow.
  --
  --
  --
  PROCEDURE update_wit_monitored_flag (
	p_parent_flow_key varchar2,
	p_item_type varchar2,
	p_new_flag varchar2)
  IS
    v_userid number;
    v_cust_flag number := 0;
    v_base_monitored_flag varchar2(1);
  BEGIN
    v_userid := get_user_id;
    begin
      select 1 into v_cust_flag from fnd_oam_bf_wit_cust
        where biz_flow_key = p_parent_flow_key
	and item_type = p_item_type;
    exception
      when no_data_found then
        v_cust_flag := 0;
    end;

    if (v_cust_flag = 0) then
--      select monitored_flag into v_base_monitored_flag
--	 from fnd_oam_bf_wit
--	 where biz_flow_key = p_parent_flow_key
--	 and item_type = p_item_type;
--
--      if (v_base_monitored_flag <> p_new_flag) then
--        -- copy over record to cust table
--        insert into fnd_oam_bf_wit_cust(
--	  biz_flow_key, item_type, monitored_flag,
--	  created_by, creation_date, last_updated_by, last_update_date,
--	  last_update_login)
--	   select biz_flow_key, item_type, monitored_flag,
--	     created_by, creation_date, last_updated_by, last_update_date,
--	     last_update_login
--	     from fnd_oam_bf_wit
--	     where biz_flow_key = p_parent_flow_key
--	     and item_type = p_item_type;
--      end if;
        -- now update fnd_oam_bf_assoc
    	update fnd_oam_bf_wit set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_parent_flow_key
		and item_type = p_item_type;
    else
	-- now update fnd_oam_bf_assoc_cust
    	update fnd_oam_bf_wit_cust set
		monitored_flag = p_new_flag,
		last_update_date = sysdate,
		last_updated_by = v_userid
		where biz_flow_key = p_parent_flow_key
		and item_type = p_item_type;
    end if;


  EXCEPTION
	when others then
		raise;
  END update_wit_monitored_flag;

end FND_OAM_BF_UTIL;

/
