--------------------------------------------------------
--  DDL for Package Body FND_OAM_DASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DASHBOARD_UTIL" AS
  /* $Header: AFOAMDUB.pls 115.3 2004/04/16 10:49:53 swpattab noship $ */

  -- Name
  --   get_trans_name_values
  --
  -- Purpose
  --   Gets the translated list of name values that will be used in the
  --   system alert raised by the dashboard collection program.
  --
  -- Input Arguments
  --   p_message_type - Value should be either 'MET' for message based on
  --     threshold values
  --     or 'STATUS' for metrics based on status values
  --   p_name_val_codes:
  --     If p_message_type is 'MET' then this should be a comma delimited
  --      list of metric_short_names:threshold_operator:threshold_value
  --      values. For example:
  --	   'ACTIVE_USERS:G:300,DB_SESSIONS:G:300'
  --     If p_message_type is 'STATUS' then this should be a comma delimited
  --      list of application_id:concurrent_queue_id:status_code or
  --      metric_short_name:statis_code values
  --
  --      For example:
  --       '0:3042:2,0:10434:2,PHP_GEN:2'
  --
  -- Output Arguments
  --
  -- Returns
  --     If p_message_type is 'MET' then returns the list of
  --     translated metric display name, operator and threshold values
  --
  --     If p_message_type is 'STATUS' then returns the list of
  --     translated service instance display name and status values.
  --
  --     For example:
  --      MET: 'Active Users Greater than 300;Database Sessions Greater than 404;'
  --      STATUS: 'Workflow Mailer: Down; Standard Manager: Down; PHP: Down'
  -- Notes:
  --   INTERNAL_USE_ONLY - This function is for use by the dashboard
  --   collection program only.
  --
  FUNCTION get_trans_name_values (
	p_message_type varchar2,
	p_name_val_codes varchar2) RETURN varchar2
  IS
	v_remainder varchar2(4000) := p_name_val_codes;
	v_entity varchar2(1024);
	v_retu varchar2(2000) := null;
  BEGIN
	if (p_message_type is null or p_name_val_codes is null or
	    length(p_name_val_codes) <= 0) then
		return NULL;
	end if;
        if (p_message_type <> 'MET' and p_message_type <> 'STATUS') then
		return 'UNKNOWN_MSG_TYPE: ' || p_message_type;
	end if;
	--dbms_output.put_line('INITIAL v_remainder: ' || v_remainder);
        --dbms_output.put_line('last comma: '|| instr(p_name_val_codes, ',', -1));
	--dbms_output.put_line('length: '|| length(p_name_val_codes));

	if (instr(p_name_val_codes, ',', -1) < length(p_name_val_codes)) then
  	  --dbms_output.put_line('No comma at the end');
	  v_remainder := v_remainder || ',';
	  --dbms_output.put_line('Added comma at the end');
	end if;

	while (length(v_remainder) > 0) loop
	  --dbms_output.put_line('v_remainder: ' || v_remainder);
	  v_entity := substr(v_remainder,1,instr(v_remainder,',') -1);

	  --dbms_output.put_line('v_entity: ' || v_entity);

	  declare
	    v_first_delim number;
	    v_second_delim number;

	    v_first_portion varchar2(256);
	    v_second_portion varchar2(256);
	    v_third_portion varchar2(256);

	    v_name varchar2(256);
	    v_threshold_oper varchar2(256);
	    v_value varchar2(256);

	    v_name_value_pair varchar2(1024);
	  begin

	      v_first_delim := instr(v_entity,':',1,1);
	      v_second_delim := instr(v_entity,':',-1,1);

	      v_first_portion := substr(v_entity,1,v_first_delim-1);
	      if (v_first_delim = v_second_delim) then
	      	-- we only have two portions
		v_second_portion := substr(v_entity,v_first_delim +1);
		v_third_portion := null;
	      else
		-- we have three portions
		v_second_portion := substr(v_entity,v_first_delim+1,v_second_delim-v_first_delim-1);
		v_third_portion := substr(v_entity,v_second_delim+1);
	      end if;

              --dbms_output.put_line('POR 1: ' || v_first_portion);
	      --dbms_output.put_line('POR 2: ' || v_second_portion);
              --dbms_output.put_line('POR 3: ' || v_third_portion);
	   if (p_message_type = 'MET') then
		select metric_display_name into v_name
		  from fnd_oam_metval_vl
		  where metric_short_name=v_first_portion;
		select meaning into v_threshold_oper
		    from fnd_lookups
		    where lookup_type = 'OAM_DASHBOARD_THRESHOLD_OPER'
		    and lookup_code = v_second_portion;
		v_value := v_third_portion;

		-- we wont keep the value in the message since this may
		-- raise a new alert every time value changes
		v_name_value_pair := v_name||' '||v_threshold_oper||' '||v_value||';';
	   elsif (p_message_type = 'STATUS') then

	      if (v_third_portion is null) then
		  -- only two portions so this is dashboard status metric
		  select metric_display_name into v_name
		    from fnd_oam_metval_vl
		    where metric_short_name=v_first_portion;
		  select meaning into v_value
		    from fnd_lookups
		    where lookup_type = 'OAM_DASHBOARD_METRIC_STATUS'
		    and lookup_code = v_second_portion;
	      else
		  -- three portions so this is a service instance
		  select user_concurrent_queue_name into v_name
		    from fnd_concurrent_queues_vl
		    where to_char(application_id) = v_first_portion
		    and to_char(concurrent_queue_id) = v_second_portion;
		  select meaning into v_value
		    from fnd_lookups
		    where lookup_type = 'OAM_DASHBOARD_METRIC_STATUS'
		    and lookup_code = v_third_portion;
	      end if;

	      fnd_message.clear;
	      fnd_message.set_name('FND','OAM_DASHBOARD_NAME_VALUE');
	      fnd_message.set_token('NAME',v_name);
	      fnd_message.set_token('VALUE',v_value);
	      v_name_value_pair := fnd_message.get;
	    end if;



	    v_retu := substr(v_retu || ' ' || v_name_value_pair,1,2000);

	  end;
	  v_remainder := substr(v_remainder, instr(v_remainder,',') +1);
	end loop;

	--dbms_output.put_line('OUTPUT: ' || v_retu);
	return v_retu;
  EXCEPTION
	when others then
	  v_retu := '*EXCEPTION* ' || SQLERRM;
	  return v_retu;
  END get_trans_name_values;


  -- Name
  --   load_svci_info
  --
  -- Purpose
  --   Loads services instances related alerting, collection information
  --   into fnd_oam_svci_info. For the given service instance if a row
  --   already exists it updates the row; otherwise it inserts a new row.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Returns
  --
  -- Notes:
  --
  PROCEDURE load_svci_info(
	p_application_id number,
	p_concurrent_queue_name varchar2,
	p_alert_enabled_flag varchar2,
	p_collection_enabled_flag varchar2,
	p_threshold_value varchar2,
	p_owner varchar2)
   IS
	v_x number;
	v_userid number := 0;
   BEGIN
	begin
	  select user_id into v_userid
	    from fnd_user where upper(user_name) = upper(p_owner);
	exception
	  when no_data_found then
	    v_userid := 0;
	end;

	select 1 into v_x
	  from fnd_oam_svci_info
	  where application_id = p_application_id
	  and concurrent_queue_name = p_concurrent_queue_name;

	-- update
	update fnd_oam_svci_info
		set alert_enabled_flag = p_alert_enabled_flag,
		    collection_enabled_flag = p_collection_enabled_flag,
		    threshold_value = p_threshold_value,
		    last_updated_by = v_userid,
		    last_update_date = sysdate,
		    last_update_login = 0
		where application_id = p_application_id
		  and concurrent_queue_name = p_concurrent_queue_name;
   EXCEPTION
	when no_data_found then
		insert into fnd_oam_svci_info (
			application_id,
			concurrent_queue_name,
			alert_enabled_flag,
			collection_enabled_flag,
			threshold_value,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		values (
			p_application_id,
			p_concurrent_queue_name,
			p_alert_enabled_flag,
			p_collection_enabled_flag,
			p_threshold_value,
			v_userid,
			sysdate,
			v_userid,
			sysdate,
			0);
	when others then
		raise;
  END load_svci_info;

  -- Name
  --   save_web_ping_timeout
  --
  -- Purpose
  --   Saves the value for the new web ping timeout by simply updating
  --   the profile option "OAM_DASHBOARD_WEB_PING_TIMEOUT"
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Returns
  --
  -- Notes:
  --
  FUNCTION save_web_ping_timeout(p_new_val VARCHAR2) return number
  IS
	v_ret boolean;
	v_ret_val number;
  BEGIN
	v_ret := fnd_profile.save(
		x_name => 'OAM_DASHBOARD_WEB_PING_TIMEOUT',
		x_value => p_new_val,
		x_level_name => 'SITE');

	if (v_ret = true) then
		v_ret_val := 0;
		fnd_profile.put(
		  name => 'OAM_DASHBOARD_WEB_PING_TIMEOUT',
		  val => p_new_val);
	else
		v_ret_val := 1;
	end if;
	return v_ret_val;
  EXCEPTION
	when others then
		raise;
  END save_web_ping_timeout;

  -- Name
  --   format_time
  --
  -- Purpose
  --   Formats the given number of seconds into 'HH:MM:SS' format.
  --   e.g. 66 is converted to 00:01:06
  --
  -- Input Arguments
  --   p_seconds - Time in seconds
  --
  -- Output Arguments
  --
  -- Returns
  --  Formated String in 'HH:MM:SS' format
  --
  -- Notes:
  --
  FUNCTION format_time(p_seconds number) return varchar2
  IS
	v_retu varchar2(50) := '00:00:00';
        v_hh number;
	v_mm number;
	v_ss number;

	--v_hh_tmp number;
	--v_mm_tmp number;
	--v_ss_tmp number;

	v_seconds number;
  BEGIN
	select round(nvl(p_seconds, 0)) into v_seconds from dual;

	v_hh := floor(v_seconds/60/60);
	v_mm := floor((v_seconds - (v_hh*3600))/60);
        v_ss := floor((v_seconds - (v_hh*3600) - (v_mm*60)));
	if (v_hh = 0 and v_mm = 0 and v_ss = 0) then
		v_ss := 1;
	end if;
	v_retu := to_char(v_hh) || ':' ||
		  to_char(v_mm) || ':' ||
		  to_char(v_ss);
	return v_retu;
  EXCEPTION
	when others then
		v_retu := substr(SQLERRM,1,49);
		return v_retu;
  END format_time;

  -- Name
  --   get_meaning
  --
  -- Purpose
  --   Gets the meaning for the given lookup_type and comma seperated
  --   look_up codes from the fnd_lookups table
  --
  -- Input Arguments
  --   p_lookup_type - Look up type (String)
  --   p_lookup_codes - Comma separated lookup codes with no space in between
  --      them. for eg: '2,1,3,4' etc.
  --
  -- Output Arguments
  --
  -- Returns
  --  Comma separated meanings corresponding to each code.
  --
  -- Notes:
  --
  FUNCTION get_meaning (p_lookup_type varchar2,
	p_lookup_codes varchar2) RETURN varchar2
  IS
	v_remainder varchar2(1000) := p_lookup_codes;
	v_entity varchar2(1024);
	v_retu varchar2(2000) := null;
	v_status varchar2(100);
  BEGIN
	if (p_lookup_codes is null or
	    length(p_lookup_codes) <= 0) then
		return NULL;
	end if;

	-- code for putting a comma at the end of the line
	-- if not already present
	if (instr(p_lookup_codes, ',', -1, 1) < length(p_lookup_codes)) then
	  v_remainder := v_remainder || ',';
	end if;

	while (length(v_remainder) > 0) loop
	  --dbms_output.put_line('v_remainder: ' || v_remainder);
	  v_entity := substr(v_remainder,1,instr(v_remainder,',',1,1) -1);

	  select meaning into v_status
	    from fnd_lookups
	    where lookup_type = p_lookup_type
	    and lookup_code = v_entity;



	  v_remainder := substr(v_remainder, instr(v_remainder,',') +1);

          v_retu := v_retu || v_status;

	  if (length(v_remainder) > 0) then
	     v_retu := v_retu || ', ';
	  end if;

	end loop;

	--dbms_output.put_line('OUTPUT: ' || v_retu);
	return v_retu;
  EXCEPTION
	when others then
	  v_retu := '*EXCEPTION* ' || SQLERRM;
	  return v_retu;
  END get_meaning;

END fnd_oam_dashboard_util;

/
