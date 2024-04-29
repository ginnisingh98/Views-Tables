--------------------------------------------------------
--  DDL for Package Body FND_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GLOBAL" as
  /* $Header: AFSCGBLB.pls 120.32.12010000.39 2013/02/28 20:48:15 rarmaly ship $ */

  procedure dump_context;

  /* Static variables defined for Connection Tagging */

    FRM constant varchar2(3) := 'frm';
    FWK constant varchar2(3) := 'fwk';
    JTT constant varchar2(3) := 'jtt';
    CP constant varchar2(2) := 'cp';
    WF constant varchar2(2) := 'wf';
    BES constant varchar2(3) := 'bes';
    REPORT constant varchar2(3) := 'rpt';
    ALERT constant varchar2(3) := 'alr';
    ISG constant varchar2(3) := 'isg';
    GSM constant varchar2(3) := 'gsm';
    HELP constant varchar2(7) := 'hlp';
    BINARY_PROGRAM constant varchar2(3) := 'bin';
    EBS constant varchar2(1) := 'e';

  /*
  * bug13831550
  * Local GLOBAL variables for TAG-DB procedures and functions
  *
  */
  gbl_session_module number := 0;
  gbl_session_action number := 0;
  gbl_read_sinfo     number := -1;  /* global read session Information */

  -- although the index is 2000, sys_context only support 30 character names
  -- so the names will be truncated in the sys_context if they exceed 30.
  type t_flags is table of boolean index by varchar2(2000);

  type t_wa is table of varchar2(2000) index by binary_integer;
  type t_waf is table of boolean index by binary_integer;

  -- the context hash. these are all the real initialized name/values we track.
  z_context fnd_const.t_hashtable;
  z_context_names t_wa;
  z_context_values t_wa;

  -- the backup context hash. see restore.
  z_backup fnd_const.t_hashtable;
  z_backup_names t_wa;
  z_backup_values t_wa;

  -- initialization hash.
  -- these are the name/values pairs passed in from the caller.
  z_init t_flags;
  z_init_names t_wa;
  z_init_values t_waf;

  -- flags to indicate that the value changed so the profile needs reset.
  z_init_profiles t_flags;
  z_profile_names t_wa;
  z_profile_values t_waf;

  -- for avoiding puts to profiles until after profile initialization.
  z_allow_profile_puts boolean := false;

  -- flags to indicate that the value is to be set in sys_context.
  z_syscontext t_flags;
  z_syscontext_names t_wa;
  z_syscontext_values t_waf;

  -- a map for fnd_product_initialization
  -- @todo deprecated?
  z_conditions_map fnd_const.t_hashtable;
  z_conditions_names t_wa;
  z_conditions_values t_wa;

  --
  z_security_groups_enabled boolean := false;

  -- flag to indicate package instantiation
  z_first_initialization boolean := true;

  --
  z_context_change_flag boolean := null;

  --
  site_context_change boolean := false;

  -- cached value indicating if any of the security context
  -- related properties have changed.
  z_security_context_change_flag boolean := null;

  -- can force database initialization of the entire contex
  z_force_init boolean := false;

  AUDIT_TRAIL_PROFILE constant varchar2(19) := 'AUDITTRAIL:ACTIVATE';

  -- Turns on debugging.
  -- This can be enabled for initialization by turning on core logging.
  is_debugging boolean := false;

  -- Wildcard name for determining when to dump the stack when the
  -- name's value is changed.
  debug_trace_name fnd_profile_option_values.profile_option_value%type;

  -- Logging to fnd_core_log circumvents other logging.
  -- That is, if this is enabled, the other two methods
  -- will not be reached.
  debug_to_core boolean := false;

  -- Debugs using dbms_output.put_line. Circumvents logging
  -- using debug_to_table.
  debug_to_console boolean := false;

  -- NOTE: This will attempt to create a database table
  -- named fnd_global_debug_table. Don't enable this
  -- unless it's okay to create that table. The contents
  -- may be security sensitive.
  debug_to_table boolean := false;

  -- used to order records when using debug_to_table mode
  debug_counter integer := 0;

  -- used to determine whether an org context change was made by MO_GLOBAL
  -- using fnd_profile.initialize(name, value)
  -- Bug 7685798
  MOAC_context_change_attempt boolean := false;

  -- used to determine whether FND_INIT_SQL is being executed.
  -- Bug 8335361
  in_fnd_init_sql boolean := false;


  -- bug 12875860 - needed to add a way to remove a value in  the PUT cache
  --
  -- Constant string used to indicate a delete request in PUT cache.
  FND_DELETE_VALUE VARCHAR2(30) := '**FND_DELETE_VALUE**';

  --
  -- Enables logging to core logging for fnd_global if core logging is enabled.
  -- It should be called from the primary public routines. For example,
  -- initialize, and the set_nl* routines.
  procedure check_logging
  is
    dest varchar2(30);
  begin

    debug_to_core := fnd_core_log.enabled <> 'N';

    dest := upper(sys_context(FND_CONST.FND,'FND_GLOBAL_DEBUG_LOGGING'));
    debug_to_console := dest like '%CONSOLE%';
    debug_to_table := dest like '%TABLE%';

    -- enables debug output if a destination is enabled.
    is_debugging := debug_to_core or debug_to_console or debug_to_table;

    if is_debugging then
      if debug_trace_name is null then
        begin
          select fpov.profile_option_value
            into debug_trace_name
            from fnd_profile_option_values fpov, fnd_profile_options fpo
           where fpo.profile_option_name = 'AFGLOBAL_TRACE_NAME'
             and fpo.profile_option_id = fpov.profile_option_id
             and fpov.level_id = 10001
             and fpo.application_id = fpov.application_id;
        exception
          when no_data_found then
            -- Don't track anything and stop the query from reexecuting.
            debug_trace_name := '-NO TRACING-';
        end;
      end if;
    else
      -- so that next time debugging is enabled, it'll requery this.
      debug_trace_name := null;
    end if;

  end check_logging;

  -- General purpose debugger. Will direct debugging based on
  -- the debug_to_* flags above.
  -- DO NOT use any fnd_global routines within this routine.
  -- DO NOT call anything outside fnd_global except fnd_core_log.put.
  procedure debugger(text varchar2)
  is
     pragma autonomous_transaction;
  begin

    if not is_debugging then return; end if;

    if debug_to_core then
      fnd_core_log.put('FG.D:'||userenv('sessionid')||':'||text||newline);
      return;
    end if;

    if debug_to_console then
      dbms_output.put_line(substr(text,1,250));
    end if;

    if debug_to_table then

      debug_counter := debug_counter + 1;

      if debug_counter = 1 then
        -- this is a bit of a waste to do at the start of every new
        -- session but it's probably not much worse than having to
        -- verify the existence each time either.
        begin
          execute immediate
                  'create table fnd_global_debug_table (
                          text varchar2(2000)
                          ,counter integer
                          ,when date
                          ,who integer)';
        exception
          when others then null;
        end;
      end if;

      begin
        execute immediate
                'insert into fnd_global_debug_table
                 values (:text,:debug_counter,sysdate,userenv(''sessionid''))'
                using text,debug_counter;
        commit;
      exception
        when others then
          -- stop doing this if insert errored.
          debug_to_table := false;
      end;

    end if;

  exception
    when others then
      null;
  end debugger;

  --
  -- local_chr
  --   Return specified character in current codeset
  -- IN
  --   ascii_chr - chr number in US7ASCII
  --
  function local_chr(ascii_chr in number) return varchar2 is
  begin
    return fnd_const.local_chr(ascii_chr);
  end local_chr;


  function newline return varchar2 is begin return fnd_const.newline; end;
  function tab return varchar2 is begin return fnd_const.tab; end;

  --
  -- log (Internal)
  --
  -- Set error message for unexpected sql errors
  --
  procedure log(routine in varchar2,
                errcode in number,
                errmsg in varchar2) is
  begin
    if is_debugging then
      debugger('ROUTINE:'||routine);
      debugger('ERRNO:'||errcode);
      debugger('REASON:'||errmsg);
    end if;
    fnd_message.set_name(FND_CONST.FND, 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
  end;

  --
  -- error (Internal)
  --
  -- Set error message and raise exception for unexpected sql errors
  --
  procedure throw(routine in varchar2,
                  errcode in number,
                  errmsg in varchar2) is
  begin
    log(routine,errcode,errmsg);
    app_exception.raise_exception;
  end;


  -- get a value from z_init but only if it is different than
  -- the value in z_context.
  function is_new(name varchar2) return boolean
  as
  begin
    if not z_init.exists(name) then
      return false;
    end if;
    return z_init(name);
  end is_new;

  -- set a value as new.
  procedure set_new(name varchar2)
  as
  begin
    z_init(name) := true;
  end set_new;

  -- get a value from z_context
  function get(name varchar2) return varchar2
  is
  begin
    if not z_context.exists(name) then
      return null;
    end if;
    return z_context(name);
  end get;

  -- get an integer value from z_context
  -- returns 'def' if null.
  -- will throw value_error if not a number.
  function get_i(name varchar2, def number) return number
  as
  begin
    return nvl(to_number(get(name)),def);
  end get_i;

  -- get an integer value from z_context
  -- returns FND_CONST.UNDEFINED_I if null.
  -- will throw value_error if not a number.
  function get_i(name varchar2) return number
  as
  begin
    return get_i(name,FND_CONST.UNDEFINED_I);
  end get_i;

  -- determines if a value is defined, not -1 nor null.
  function is_defined(name varchar2) return boolean
  as
  begin
    return nvl(get(name),FND_CONST.UNDEFINED_S) <> FND_CONST.UNDEFINED_S;
  end is_defined;

  -- determines if a value is undefined, -1 or null.
  function is_undefined(name varchar2) return boolean
  as
  begin
    return not is_defined(name);
  end is_undefined;

  -- set the profile value if it has changed.
  procedure initialize_profile_value(name varchar2, value varchar2)
  as
  begin
    if z_allow_profile_puts and is_new(name) then
      if is_debugging then
        debugger('.  fnd_profile.put('||name||','||value||')');
      end if;
      fnd_profile.put(name,value);
    end if;
  end initialize_profile_value;

  -- set the profile value based on the cached value, if it has changed.
  procedure initialize_profile_value(name varchar2)
  as
  begin
    initialize_profile_value(name,get(name));
  end initialize_profile_value;

  -- initializes all profile values by calling initialize_profile_value
  -- for each profile in z_init_profiles.
  procedure initialize_profile_values
  as
    c integer;
    p varchar2(2000);
  begin

    c := z_init_profiles.count;
    p := z_init_profiles.first;
    for i in 1..c loop
      -- only allow profile puts for names in z_init_profiles that are 'true'.
      if z_init_profiles(p) then
        initialize_profile_value(p,get(p));
      end if;
      p := z_init_profiles.next(p);
    end loop;

  end initialize_profile_values;

  -- returns true if the value passed is different than the cached value.
  function has_changed(name varchar2, value varchar2) return boolean
  as
    currval varchar2(2000) := get(name);
  begin

    --debugger('name '||name||' ['||currval||','||value||']');

    -- only set the value if the new and old values are different
    return z_force_init
      or value <> currval
      or (currval is null and value is not null)
      or (currval is not null and value is null);

  end has_changed;

  -- This exists so that routines that are restrict_references(WNDS)
  -- don't break. It should only be called from the few routines
  -- that are already using it. In all other cases, use put instead of this.
  -- set a value in z_context but does not affect profiles nor sys_context
  -- as does the standard put routine.
  -- returns true if the value was set, false otherwise.
  function put_nosys(name varchar2, value varchar2) return boolean
  as
  begin

    -- only set the value if the new and old values are different
    if has_changed(name,value) then

      z_context(name) := value;
      set_new(name);

      if is_debugging then
        debugger('=* '||name||'='||value);
        if name like debug_trace_name then
          debugger(dbms_utility.format_call_stack);
        end if;
      end if;

      return true;

    end if;

    if is_debugging then
      debugger('=  '||name||'='||value);
    end if;

    return false;

  end put_nosys;

  -- set a value in z_context
  -- returns true if the value was set, false otherwise.
  function put(name varchar2,
               value varchar2,
               put_profile boolean default true) return boolean
  as
  begin

    if put_nosys(name,value) then

      -- only put profile values that exist in z_init_profiles.
      -- it is irrelevant if its value in z_init_profiles is true or false.
      if put_profile and z_init_profiles.exists(name) then
        initialize_profile_value(name,value);
      end if;

      -- only set syscontext values that exist in z_syscontext and are 'true'.
      if z_syscontext.exists(name) and z_syscontext(name) then

        if is_debugging then
          debugger('.  fnd_context.init');
        end if;

        fnd_context.init(FND_CONST.FND, name, value);
      end if;

      return true;

    end if;

    return false;

  exception
    when others then
      throw('fnd_global.put('||name||','||value||')',
            sqlcode, dbms_utility.format_error_stack);
  end put;

  -- same as put_nosys but disposes of the return value
  procedure put_nosys(name varchar2, value varchar2)
  as
    dummy boolean;
  begin
    dummy := put_nosys(name,value);
  end put_nosys;

  -- same as put but disposes of the return value
  procedure put(name varchar2,
                value varchar2,
                put_profile boolean default true)
  as
    dummy boolean;
  begin
    dummy := put(name,value,put_profile);
  end put;

  -- remove the value from z_context, setting it to null
  procedure clear(name varchar2)
  as
  begin
    if z_context.exists(name) and z_context(name) is not null then
      put(name,null);
    end if;
  end clear;

  -- set a value in z_context
  procedure put_i(name varchar2, value number)
  as
  begin
    put(name,to_char(value));
  end put_i;

  -- set the default integer value in z_context
  procedure put_i(name varchar2)
  as
  begin
    put(name,FND_CONST.UNDEFINED_S);
  end put_i;

  -- set a value to -1.
  procedure set_undefined(name varchar2)
  as
  begin
    --debugger('undefining '||name);
    put(name,FND_CONST.UNDEFINED_S);
  end set_undefined;

  -- set a value on z_context from a profile value
  -- if name isn't already defined
  procedure put_from_profile(name varchar2)
  as
    value varchar2(2000);
  begin
    value := get(name);
    if value is null or is_undefined(name) then
      value := fnd_profile.value(name);
      if is_debugging then
        debugger('.  fnd_profile.value('||name||')='||value);
      end if;
      put(name,value,false);
    end if;
  end put_from_profile;

  -- Clear all the derived values that are cached as a result of lazy
  -- initialization.
  -- These are values that are never actually passed, but are derived from
  -- other context values and cached for efficiency.  If the values from
  -- which they were derived have changed, they need to be cleared to
  -- to force re-derivation.
  procedure clear_derived_values
  as
  begin

    if nls_context_change then

      if resp_context_change
        or appl_context_change
      then
        clear(FND_CONST.APPLICATION_NAME);
        clear(FND_CONST.RESP_NAME);
      end if;

    end if;

  end clear_derived_values;

  --
  -- flag to indicate if user_id, resp_id and/or resp_appl_id changed.
  --
  function user_resp_changed return boolean
  is
  begin
    return user_context_change
           or resp_context_change
           or appl_context_change;
  end;

  --
  -- flag to indicate if a security context change occurred.
  -- this means user_resp_changed or sec_context_change
  --
  function security_context_changed return boolean
  is
  begin
    if z_security_context_change_flag is null then
      z_security_context_change_flag
        := user_resp_changed
           or sec_context_change;
    end if;
    return z_security_context_change_flag;
  end;

  --
  -- flag to indicate if a context change occurred.
  -- this means any of the follow are true:
  --   security_context_changed
  --   resp_context_change
  --   appl_context_change
  --   server_context_change
  --   org_context_change
  --   nls_context_change;
  --
  function context_changed return boolean
  is
  begin
    if z_context_change_flag is null then
      -- For R12, due to MOAC, the org context can change within a session and
      -- is being handled separately from the other contexts.
      if fnd_release.major_version >= 12 then
        z_context_change_flag
          := security_context_changed
             or server_context_change
             or nls_context_change;
      else
        z_context_change_flag
          := security_context_changed
             or server_context_change
             or org_context_change
             or nls_context_change;
      end if;
    end if;
    return z_context_change_flag;
  end;

  -- AOL-FORCE_INIT -
  function force_init return boolean is
  begin
    return get('AOL:FORCE_INIT') is not null;
  end force_init;

  --
  -- AUDIT_ACTIVE - Return TRUE/FALSE (whether audit is turned on or off)
  -- Added June, 1999, bug 879630 Jan Smith
  --
  function audit_active return boolean is
    buffer varchar2(30); -- actual length should be 1, padding for security.
  begin

    -- If this is the first time that the function has been invoked then
    -- retrieve the value for the profile option.
    buffer := substrb(get(AUDIT_TRAIL_PROFILE),1,1);
    if buffer is null then
      buffer := fnd_profile.value(AUDIT_TRAIL_PROFILE);
      put_nosys(AUDIT_TRAIL_PROFILE,buffer);
    end if;

    return buffer = 'Y';
  end audit_active;

  -- APPLICATION_NAME -
  function application_name return varchar2 is
    buffer fnd_application_vl.application_name%type;
    v_raid integer := resp_appl_id;
  begin
    if v_raid is null then
      return null;
    end if;

    -- no caching of APPLICATION_NAME
    -- to avoid changing pragma in spec
    --buffer := get(FND_CONST.APPLICATION_NAME);
    --if buffer is null then

      -- Re-query every time in case of language change --
      select a.application_name
        into buffer
        from fnd_application_vl a
       where a.application_id = v_raid;

      -- no caching of APPLICATION_NAME
      -- to avoid changing pragma in spec
      --put_nosys(FND_CONST.APPLICATION_NAME,buffer);
    --end if;

    return buffer;
  exception
    when no_data_found then
      return null;
  end application_name;

  -- APPLICATION_SHORT_NAME -
  function application_short_name return varchar2 is
  begin
    return get(FND_CONST.APPLICATION_SHORT_NAME);
  end application_short_name;

  -- BASE_LANGUAGE -
  function base_language return varchar2 is
    buffer fnd_languages.language_code%type := get(FND_CONST.BASE_LANGUAGE);
  begin
    if buffer is null then

      select language_code
        into buffer
        from fnd_languages
       where installed_flag = 'B';

      put_nosys(FND_CONST.BASE_LANGUAGE,buffer);
    end if;
    return buffer;
  exception
    when no_data_found then
      return null;
  end base_language;

  -- CONC_LOGIN_ID -
  function conc_login_id return number is
  begin
    return get_i(FND_CONST.CONC_LOGIN_ID);
  end conc_login_id;

  -- CONC_PRIORITY_REQUEST -
  function conc_priority_request return number is
  begin
    return get_i(FND_CONST.CONC_PRIORITY_REQUEST,null);
  end conc_priority_request;

  -- CONC_PROGRAM_ID -
  function conc_program_id return number is
  begin
    return get_i(FND_CONST.CONC_PROGRAM_ID);
  end conc_program_id;

  -- CONC_PROCESS_ID -
  function conc_process_id return number is
  begin
    return get_i(FND_CONST.CONC_PROCESS_ID);
  end conc_process_id;

  -- CONC_QUEUE_ID -
  function conc_queue_id return number is
  begin
    return get_i(FND_CONST.CONC_QUEUE_ID);
  end conc_queue_id;

  -- CONC_REQUEST_ID -
  function conc_request_id return number is
  begin
    return get_i(FND_CONST.CONC_REQUEST_ID);
  end conc_request_id;

  -- CURRENT_LANGUAGE -
  function current_language return varchar2 is
  begin
    return userenv('LANG');
  end current_language;

  -- CUSTOMER_ID -
  function customer_id return number is
  begin
    return get_i(FND_CONST.CUSTOMER_ID);
  end customer_id;

  -- EMPLOYEE_ID -
  function employee_id return number is
  begin
    return get_i(FND_CONST.EMPLOYEE_ID);
  end employee_id;

  -- FORM_ID -
  function form_id return number is
  begin
    return get_i(FND_CONST.FORM_ID);
  end form_id;

  -- FORM_APPL_ID -
  function form_appl_id return number is
  begin
    return get_i(FND_CONST.FORM_APPL_ID);
  end form_appl_id;

  -- LANGUAGE_COUNT -
  function language_count return number is
    buffer number := get_i(FND_CONST.LANGUAGE_COUNT,null);
  begin
    if buffer is null then

      select count(1)
        into buffer
        from fnd_languages
       where installed_flag in ('I', 'B');

      put_nosys(FND_CONST.LANGUAGE_COUNT,to_char(buffer));
    end if;
    return buffer;
  exception
    when no_data_found then
      return 0;
  end language_count;

  -- LOGIN_ID -
  function login_id return number is
  begin
    return get_i(FND_CONST.LOGIN_ID);
  end login_id;

  -- ORG_ID -
  function org_id return number is
  begin
    return get_i(FND_CONST.ORG_ID);
  end org_id;

  -- Fetches and caches ORG_NAME based on current ORG_ID
  function org_name return varchar2 is
    v_org_name varchar2(2000) := get(FND_CONST.ORG_NAME);
    v_org_id integer;
  begin
    if v_org_name is null then
      v_org_id := org_id;
      if v_org_id > -1 then
        select name into v_org_name
        from hr_operating_units
        where organization_id = v_org_id;

        put(FND_CONST.ORG_NAME,v_org_name);
      end if;
    end if;

    return(v_org_name);
  exception
    when others then
      clear(FND_CONST.ORG_NAME);
      return null;
  end org_name;

  -- PARTY_ID -
  function party_id return number is
  begin
    return get_i(FND_CONST.PARTY_ID);
  end party_id;

  -- PER_BUSINESS_GROUP_ID -
  function per_business_group_id return number is
  begin
    return get_i(FND_CONST.PER_BUSINESS_GROUP_ID);
  end per_business_group_id;

  -- PER_SECURITY_PROFILE_ID -
  function per_security_profile_id return number is
  begin
    return get_i(FND_CONST.PER_SECURITY_PROFILE_ID);
  end per_security_profile_id;

  -- PROG_APPL_ID -
  function prog_appl_id return number is
  begin
    return get_i(FND_CONST.PROG_APPL_ID);
  end prog_appl_id;

  -- QUEUE_APPL_ID -
  function queue_appl_id return number is
  begin
    return get_i(FND_CONST.QUEUE_APPL_ID);
  end queue_appl_id;

  -- RESP_APPL_ID - Return responsibility application id
  function resp_appl_id return number is
  begin
    return get_i(FND_CONST.RESP_APPL_ID);
  end resp_appl_id;

  -- RESP_ID - Return responsibility id
  function resp_id return number is
  begin
    return get_i(FND_CONST.RESP_ID);
  end resp_id;

  -- RESP_NAME -
  function resp_name return varchar2 is
    buffer fnd_responsibility_vl.responsibility_name%type;
    v_rid integer := resp_id;
    v_raid integer := resp_appl_id;
  begin
    if v_rid is null or v_raid is null then
      return null;
    end if;

    -- no caching of RESP_NAME
    -- to avoid changing pragma in spec
    --buffer := get(FND_CONST.RESP_NAME);
    --if buffer is null then

      -- Re-query every time in case of language change --
      select r.responsibility_name
        into buffer
        from fnd_responsibility_vl r
       where r.responsibility_id = v_rid
         and r.application_id = v_raid;

      -- no caching of RESP_NAME
      -- to avoid changing pragma in spec
      --put_nosys(FND_CONST.RESP_NAME,buffer);
    --end if;

    return buffer;
  exception
    when no_data_found then
      -- no caching of RESP_NAME
      -- to avoid changing pragma in spec
      --clear(FND_CONST.RESP_NAME);
      return null;
  end resp_name;

  -- RESP_KEY -
  -- returns responsibility_key of current context
  function resp_key return varchar2 is
    buffer varchar2(30);
    v_rid  integer := resp_id;
    v_raid integer := resp_appl_id;
  begin
    if v_rid is null or v_raid is null then
      return null;
    end if;

    select r.responsibility_key
    into buffer
    from fnd_responsibility_vl r
    where r.responsibility_id = v_rid
    and r.application_id      = v_raid;

    return buffer;
  exception
    when no_data_found then
      return null;
  end resp_key;

  -- RT_TEST_ID -
  function rt_test_id return number is
  begin
    return get_i(FND_CONST.RT_TEST_ID);
  end rt_test_id;

  -- Bug 12875860 - remove function security_groups_enabled - NOT used

  -- SECURITY_GROUP_ID - Return security group id
  function security_group_id return number is
  begin
    return get_i(FND_CONST.SECURITY_GROUP_ID,0);
  end security_group_id;

  -- SECURITY_GROUP_ID_POLICY - Return security group id
  function security_group_id_policy(d1 varchar2, d2 varchar2) return varchar2 is
  begin
    if is_undefined(FND_CONST.SECURITY_GROUP_ID) then
      return null;
    end if;
    return '(security_group_id = SYS_CONTEXT(''FND'',''SECURITY_GROUP_ID''))';
  end security_group_id_policy;

  -- SERVER_ID -
  function server_id return number is
  begin
    return get_i(FND_CONST.SERVER_ID);
  end server_id;

  -- SESSION_ID - Return responsibility id
  function session_id return number is
  begin
    return get_i(FND_CONST.SESSION_ID);
  end session_id;

  -- SITE_ID -
  function site_id return number is
  begin
    return get_i(FND_CONST.SITE_ID);
  end site_id;

  -- SUPPLIER_ID -
  function supplier_id return number is
  begin
    return get_i(FND_CONST.SUPPLIER_ID);
  end supplier_id;

  -- USER_ID - Return user id
  function user_id return number is
  begin
    return get_i(FND_CONST.USER_ID);
  end user_id;

  -- USER_NAME -
  function user_name return varchar2 is
  begin
    return get(FND_CONST.USER_NAME);
  end user_name;


  -- NLS functions
  function nls_language return varchar2 is
  begin
    return get(FND_CONST.NLS_LANGUAGE);
  end nls_language;

  function nls_numeric_characters return varchar2 is
  begin
    return get(FND_CONST.NLS_NUMERIC_CHARACTERS);
  end nls_numeric_characters;

  function nls_date_format return varchar2 is
  begin
    return get(FND_CONST.NLS_DATE_FORMAT);
  end;

  function nls_date_language return varchar2 is
  begin
    return get(FND_CONST.NLS_DATE_LANGUAGE);
  end nls_date_language;

  function nls_territory return varchar2 is
  begin
    return get(FND_CONST.NLS_TERRITORY);
  end nls_territory;

  function nls_sort return varchar2 is
  begin
    return get(FND_CONST.NLS_SORT);
  end nls_sort;

  --   Get Security Group Id from which to retrieve lookup type.
  --   This will either be the current security group, or default to the
  --   STANDARD security group (id=0) if lookup type not defined
  --   in current security group.
  -- IN
  --   lookup_type
  --   view_application_id
  -- RETURNS
  --   Security_group_id of lookup type to use (current or STANDARD).
  -- NOTE
  --   This function is used by FND_LOOKUPS and related views to
  --   improve performance.
  function lookup_security_group(lookup_type in varchar2,
                                 view_application_id in number)
  return number
  is
    retval number;
  begin
    --
    -- execute this query only when security groups are enabled (1/2/01) jvc
    --
    if z_security_groups_enabled then

      select max(lt.security_group_id)
        into retval
        from fnd_lookup_types lt
       where lt.view_application_id = lookup_security_group.view_application_id
         and lt.lookup_type         = lookup_security_group.lookup_type
         and lt.security_group_id in (0,
                        to_number(decode(substrb(userenv('CLIENT_INFO'),55,1),
                                        ' ', '0',
                                        null, '0',
                                        substrb(userenv('CLIENT_INFO'),55,10))));
      return retval;
    else
      return 0;
    end if;
  exception
    when no_data_found then
      return null;
  end lookup_security_group;

  -- returns the number of times initialize has been called in this session
  function get_session_context
  return number
  is
  begin
    return(session_context);
  end get_session_context;

  -- returns true if the session_context is the same as context_id,
  -- otherwise returns false.
  function compare_session_context(context_id in number)
  return boolean
  is
  begin
    if (session_context <> context_id) then
      return false;
    else
      return true;
    end if;
  end compare_session_context;

  -- returns true if no_pool is null or equal to session_context,
  -- otherwise returns false.
  function assert_no_pool return boolean is
  begin
    if no_pool is null then
      no_pool := session_context;
      return true;
    else
      if no_pool <> session_context then
        return false;
      else
        return true;
      end if;
    end if;
  end assert_no_pool;

  --
  procedure save_hash(p_hash in out nocopy fnd_const.t_hashtable,
                      p_names in out nocopy t_wa,
                      p_values in out nocopy t_wa) is
    c integer;
    p varchar2(2000);
  begin
    c := p_hash.count;
    p := p_hash.first;
    for i in 1..c loop
      p_names(i) := p;
      p_values(i) := p_hash(p);
      p := p_hash.next(p);
    end loop;
    p_hash.delete;

  end save_hash;

  --
  procedure restore_hash(p_hash in out nocopy fnd_const.t_hashtable,
                         p_names in out nocopy t_wa,
                         p_values in out nocopy t_wa) is
    c integer;
    p varchar2(2000);
  begin
    c := p_names.count;
    p := p_names.first;
    for i in 1..c loop
      if not p_hash.exists(p_names(i)) then
        p_hash(p_names(i)) := p_values(i);
      end if;
      p := p_names.next(p);
    end loop;
    p_names.delete;
    p_values.delete;

  end restore_hash;

  --
  procedure save_flags(p_hash in out nocopy t_flags,
                       p_names in out nocopy t_wa,
                       p_values in out nocopy t_waf) is
    c integer;
    p varchar2(2000);
  begin
    c := p_hash.count;
    p := p_hash.first;
    for i in 1..c loop
      p_names(i) := p;
      p_values(i) := p_hash(p);
      p := p_hash.next(p);
    end loop;
    p_hash.delete;

  end save_flags;

  --
  procedure restore_flags(p_hash in out nocopy t_flags,
                          p_names in out nocopy t_wa,
                          p_values in out nocopy t_waf) is
    c integer;
    p varchar2(2000);
  begin
    c := p_names.count;
    p := p_names.first;
    for i in 1..c loop
      if not p_hash.exists(p_names(i)) then
        p_hash(p_names(i)) := p_values(i);
      end if;
      p := p_names.next(p);
    end loop;
    p_names.delete;
    p_values.delete;

  end restore_flags;

  --
  -- Prior to an NLS change, all string-keyed associative arrays must be
  -- deleted. This stores the values in integer indexed arrays so the
  -- associative array can be repopulated after the NLS change.
  --
  procedure pre_nls_change is begin
    save_hash(z_context,z_context_names,z_context_values);
    save_hash(z_backup,z_backup_names,z_backup_values);
    save_hash(z_conditions_map,z_conditions_names,z_conditions_values);
    save_flags(z_init,z_init_names,z_init_values);
    save_flags(z_init_profiles,z_profile_names,z_profile_values);
    save_flags(z_syscontext,z_syscontext_names,z_syscontext_values);
  end pre_nls_change;

  --
  -- This is called in set_nls *after* any nls context changes have occurred
  -- and the nls_context_change flag has been set, if there were any changes.
  -- Also, this API doesn't execute during fnd_global.initialize's call
  -- to set_nls so it'll only run during direct calls to set_nls.
  --
  procedure post_nls_change is begin
    restore_hash(z_context,z_context_names,z_context_values);
    restore_hash(z_backup,z_backup_names,z_backup_values);
    restore_hash(z_conditions_map,z_conditions_names,z_conditions_values);
    restore_flags(z_init,z_init_names,z_init_values);
    restore_flags(z_init_profiles,z_profile_names,z_profile_values);
    restore_flags(z_syscontext,z_syscontext_names,z_syscontext_values);

    -- Bug 9226640: the cached org_name value should be cleared if the NLS
    -- context changes, so that when org_name is called, the value is refreshed
    -- with the prevailing NLS session context.
    --
    clear(FND_CONST.ORG_NAME);

  end post_nls_change;

  --
  -- Bug 5032374
  -- Determine whether to override NLS_DATE_LANGUAGE.
  -- This routine depends on NLS_DATE_FORMAT being set. Either by defaulting
  -- based on its parent territory or on the user's specification.
  function override_nls_date_language(p_nls_date_language varchar2 default null)
  return varchar2 is
    -- Bug 6718678 and 5032384
    -- use nls_language instead of nls_date_language
    v_nls_date_language v$nls_parameters.value%type
      := nvl(p_nls_date_language,nls_language);
    nul_dl boolean := false;
    new_dl boolean := false;
    new_df boolean := false;
    chg_dl boolean := false;
    mon_lk boolean := false;
    mm_lk  boolean := false;
    v_nls_charset_name varchar2(30) := nls_charset_name(nls_charset_id('CHAR_CS'));
  begin

    nul_dl := p_nls_date_language is null;
    new_dl := is_new(FND_CONST.NLS_DATE_LANGUAGE);
    new_df := is_new(FND_CONST.NLS_DATE_FORMAT);
    chg_dl := has_changed(FND_CONST.NLS_DATE_LANGUAGE,p_nls_date_language);
    mon_lk := nls_date_format like '%MON%';
    mm_lk  := nls_date_format like '%MM%';

    if is_debugging then
      debugger(dbms_utility.format_call_stack);
      debugger('?  p_nls_date_language is null              :'
               ||fnd_const.bool(nul_dl));
      debugger('?  is_new(FND_CONST.NLS_DATE_LANGUAGE)      :'
               ||fnd_const.bool(new_dl));
      debugger('?  is_new(FND_CONST.NLS_DATE_FORMAT)        :'
               ||fnd_const.bool(new_df));
      debugger('?  has_changed(FND_CONST.NLS_DATE_LANGUAGE) :'
               ||fnd_const.bool(chg_dl));
      debugger('?= nls_date_format like ''%MON%''           :'
               ||fnd_const.bool(mon_lk));
      debugger('?= nls_date_format like ''%MM%''           :'
               ||fnd_const.bool(mm_lk));
      debugger('?= nul_dl and new_dl                        :'
               ||fnd_const.bool(nul_dl and new_dl));
      debugger('?= not nul_dl and chg_dl                    :'
               ||fnd_const.bool(not nul_dl and chg_dl));
      debugger('?= new_df or new_dl                         :'
               ||fnd_const.bool(new_df or new_dl));
    end if;


    -- All conditions depend on whether there's a 'MON' in
    -- the NLS_DATE_FORMAT. If not, don't need to override.

    -- If there's a new NLS_DATE_FORMAT or NLS_DATE_LANGUAGE,
    -- try the override.

    -- If the parameter is null and there's a new NLS_DATE_LANGUAGE,
    -- try the override. This occurs when called from query_nls,
    -- typically during first initialization or when a public set_nls*
    -- routine calls reset_nls.

    -- If the parameter isn't null and is different than the current
    -- NLS_DATE_LANGUAGE, try the override. This occurs when
    -- the caller has supplied their own NLS_DATE_LANGUAGE.

    if mon_lk or mm_lk
      and ((nul_dl and new_dl)
           or (not nul_dl and chg_dl)
           or (new_df or new_dl))
    then

      declare
        -- Bug 6718678 and 5032384
        -- use nls_language instead of nls_date_language
        t_nls_date_language v$nls_parameters.value%type
          := nvl(p_nls_date_language,nls_language);
      begin
        /*
        select nls_date_language
          into v_nls_date_language
          from (select utf8_date_language nls_date_language
                  from fnd_languages
                 where nls_charset_name(nls_charset_id('CHAR_CS'))
                       in ('UTF8', 'AL32UTF8')
                   and installed_flag <>'D'
                   and nls_language = t_nls_date_language
                 union
                select local_date_language nls_date_language
                  from fnd_languages
                 where nls_charset_name(nls_charset_id('CHAR_CS'))
                       not in ('UTF8', 'AL32UTF8')
                   and installed_flag <>'D'
                   and nls_language = t_nls_date_language);
        */

        /* Bug 10057138: The following query was formulated by
           Enrique Miranda and was approved by Jinsoo Eo of the ATG
           Performance Team.

           The query above was raised by GSI as the cause of a high number
           of sessions waiting on library cache, which consequently lead to
           a high CPU and database crash.
         */
        select decode(v_nls_charset_name,
               'UTF8', fl.utf8_date_language,
               'AL32UTF8', fl.utf8_date_language,
               fl.local_date_language
               ) data_rtn
        into  v_nls_date_language
        from fnd_languages fl
        where fl.nls_language = t_nls_date_language
        and fl.installed_flag <>'D' ;

        if debug_to_core then
          debugger('^ Changing NLS_DATE_LANGUAGE');
          debugger('^  from: '||t_nls_date_language);
          debugger('^    to: '||v_nls_date_language);
        end if;

      exception
        when no_data_found then
          if debug_to_core then
            debugger('^ No data for FND_LANGUAGE: '||t_nls_date_language);
          end if;
      end;

    else
      if debug_to_core then
        debugger('^ No reason to change NLS_DATE_FORMAT: '||nls_date_format);
      end if;
    end if;

    -- Bug 8252659: shashimo
    -- There are two sets of common month names in the Arab World:
    -- Jordanian and Egyptian
    -- If the user preference language is Arabic and user preference
    -- territory is any of Jordan, Lebanon, Syrian Arab Republic, or Iraq,
    -- the Jordanian flavor of month name should be used.
    -- For other territories, Egyptian flavor of month name should be used.
    -- This does not apply to 11i.
    --
    -- Bug 10359373: Backport fix of 8252659 to 11i for bug 9685123 by
    -- removing the release version check
    --
    if v_nls_date_language = 'ARABIC' and
      nls_territory not in ('JORDAN', 'LEBANON', 'SYRIA', 'IRAQ') then
      if debug_to_core then
        debugger('^ Changing NLS_DATE_LANGUAGE from ARABIC to EGYPTIAN');
      end if;
      v_nls_date_language := 'EGYPTIAN';
    end if;

    return v_nls_date_language;

  end override_nls_date_language;

  -- See this routine's associated function.
  procedure override_nls_date_language
  is
    tmp v$nls_parameters.value%type;
  begin
    tmp := override_nls_date_language;
  end override_nls_date_language;

  --
  -- query NLS values
  --
  procedure query_nls is
  begin
    -- query to ensure the cache is accurate.
    -- not using FND_CONST in query to avoid SQL context switch.
    for nls in (select *
                  from v$nls_parameters
                 where parameter in (
                          'NLS_LANGUAGE',
                          'NLS_DATE_LANGUAGE',
                          'NLS_SORT',
                          'NLS_TERRITORY',
                          'NLS_DATE_FORMAT',
                          'NLS_NUMERIC_CHARACTERS',
                          'NLS_CHARACTERSET'
                      )) loop
        nls_context_change := put(nls.parameter,nls.value) or nls_context_change;
    end loop;

    if z_first_initialization then
      override_nls_date_language;
    end if;

  end query_nls;

  --
  -- Reset NLS initialization variables
  --
  procedure reset_nls is
  begin

    if z_first_initialization then
      query_nls;
      z_first_initialization := false;
    end if;

    z_init(FND_CONST.NLS_LANGUAGE) := false;
      z_init(FND_CONST.NLS_DATE_LANGUAGE) := false;
      z_init(FND_CONST.NLS_SORT) := false;
    z_init(FND_CONST.NLS_TERRITORY) := false;
      z_init(FND_CONST.NLS_DATE_FORMAT) := false;
      z_init(FND_CONST.NLS_NUMERIC_CHARACTERS) := false;
    z_init(FND_CONST.NLS_CHARACTERSET) := false;

  end reset_nls;

  --
  -- SET_NLS
  --
  -- This is the main NLS routine. All others call into this routine to set
  -- NLS values by calling dbms_session.set_nls (i.e. alter session) to set
  -- the following values in DB.
  --
  -- Notes:
  --       - Side effects of setting certain values
  --            - NLS_LANGUAGE
  --                 affects
  --                    NLS_DATE_LANGUAGE
  --                    NLS_SORT
  --            - NLS_TERRITORY
  --                 affects
  --                    NLS_DATE_FORMAT
  --                    NLS_NUMERIC_CHARACTERS
  --            - NLS_SORT affects no others
  --            - NLS_DATE_FORMAT affects no others
  --            - NLS_DATE_LANGUAGE affects no others
  --            - NLS_NUMERIC_CHARACTERS affects no others

  procedure set_nls(p_nls_language in varchar2 default null,
                    p_nls_date_language in varchar2 default null,
                    p_nls_sort in varchar2 default null,
                    p_nls_territory in varchar2 default null,
                    p_nls_date_format in varchar2 default null,
                    p_nls_numeric_characters in varchar2 default null
                    ) is

    -- The indenting below is intentional based on dependent NLS values.
    -- This is done throughout to indicate the ordering. That is, when
    -- the indentation isn't present, the order of the names does not
    -- follow this ordering. It was very confusing to me why the parameters
    -- to older NLS routines didn't follow a logical order. It doesn't even
    -- look like they were ordered based on most highly used.

    v_nls_language v$nls_parameters.value%type
        := upper(p_nls_language);
      v_nls_date_language v$nls_parameters.value%type
        := upper(p_nls_date_language);
      v_nls_sort v$nls_parameters.value%type
        := upper(p_nls_sort);

    v_nls_territory v$nls_parameters.value%type
        := upper(p_nls_territory);
      v_nls_date_format v$nls_parameters.value%type
        := upper(p_nls_date_format);
      v_nls_numeric_characters v$nls_parameters.value%type
        := p_nls_numeric_characters;

    v_nls_characterset v$nls_parameters.value%type
        := get(FND_CONST.NLS_CHARACTERSET);

    --
    -- calls dbms_session.set_nls
    function set_parameter(p_parameter varchar2, p_value in varchar2)
    return boolean is
    begin

      -- simply don't do anything if passed null.
      if p_value is null then
        return false;
      end if;

      if has_changed(p_parameter,p_value) then
        dbms_session.set_nls(p_parameter, '"'|| p_value ||'"');
        put(p_parameter,p_value);
        return true;
      end if;

      return false;

    exception
      when others then
        throw('fnd_global.set_nls.set_parameter('''||
              p_parameter||''','''||
              p_value||''')',
              sqlcode, dbms_utility.format_error_stack);
    end set_parameter;

    --
    -- calls dbms_session.set_nls
    procedure set_parameter(p_parameter varchar2, p_value in varchar2)
    is
      result boolean;
    begin
      result := set_parameter(p_parameter,p_value);
    end set_parameter;

  begin

    nls_context_change := false;

    if z_first_initialization then

      query_nls;
      z_first_initialization := false;

    else

      -- Although there is a performance improvement in 10.2.0.2 eliminating
      -- the need to check whether NLS value have changed before setting them,
      -- See bug 5080655 for the explanation, this file is still under
      -- dual-checkin with 11.5 which doesn't include the improvement.

      --    - NLS_LANGUAGE
      --         affects
      --            NLS_DATE_LANGUAGE
      --            NLS_SORT
      --    - NLS_TERRITORY
      --         affects
      --            NLS_DATE_FORMAT
      --            NLS_NUMERIC_CHARACTERS

      pre_nls_change;

      -- If NLS_LANGUAGE changed, clear the cached, derived values.
      -- This ensures that the passed, derived values are set if different than
      -- the default, derived value for this language.
      if set_parameter(FND_CONST.NLS_LANGUAGE, v_nls_language) then
        z_context(FND_CONST.NLS_DATE_LANGUAGE) := null;
        z_context(FND_CONST.NLS_SORT) := null;
      end if;

      -- if NLS_TERRITORY changed, clear the cached, derived values
      -- This ensures that the passed, derived values are set if different than
      -- the default, derived value for this territory.
      if set_parameter(FND_CONST.NLS_TERRITORY, v_nls_territory) then
        z_context(FND_CONST.NLS_DATE_FORMAT) := null;
        z_context(FND_CONST.NLS_NUMERIC_CHARACTERS) := null;
      end if;

      -- Requery derived values to avoid calling dbms_session.set_nls
      -- in case the derived value is the same as the passed parameter value.
      -- In other words, it ensures that the following set_parameter calls
      -- don't do anything if the value in the database is the same as the
      -- passed parameter due to the value passed already being the default
      -- for the specified language or territory.
      -- This is where bug 5080655 and the improvement to dbms_session.set_nls
      -- affects us since we have to retain the nls values in the cache since
      -- we have code the depends on knowing when nls context changes.
      if (v_nls_language is not null
         and (v_nls_date_language is null
              or v_nls_sort is null))
      or (v_nls_territory is not null
          and (v_nls_date_format is null
               or v_nls_numeric_characters is null)) then
        query_nls;
      end if;

      -- NOTE: NLS_DATE_FORMAT must come before NLS_DATE_LANGUAGE.
      -- Due to bug 5032374, we need to check the value of NLS_DATE_FORMAT
      -- to determine if NLS_DATE_LANGUAGE needs to be overridden.
      set_parameter(FND_CONST.NLS_DATE_FORMAT, v_nls_date_format);
      set_parameter(FND_CONST.NLS_NUMERIC_CHARACTERS, v_nls_numeric_characters);

      set_parameter(FND_CONST.NLS_SORT, v_nls_sort);
      -- Bug 6718678 and 5032384
      -- Instead of passing v_nls_date_language to override nls_date_language,
      -- pass the nls_language
      set_parameter(FND_CONST.NLS_DATE_LANGUAGE,
                    override_nls_date_language(v_nls_language));

      post_nls_change;

    end if;

  exception
    when others then
      throw('fnd_global.set_nls',
            sqlcode, dbms_utility.format_error_stack);
  end set_nls;

  -- legacy routine that simply calls through to set_nls.
  --
  procedure set_nls_context(p_nls_language in varchar2 default null,
                            p_nls_date_format in varchar2 default null,
                            p_nls_date_language in varchar2 default null,
                            p_nls_numeric_characters in varchar2 default null,
                            p_nls_sort in varchar2 default null,
                            p_nls_territory in varchar2 default null) is
  begin

    check_logging;

    if is_debugging then
      debugger('begin set_nls_context');
      debugger(dbms_utility.format_call_stack);
      dump_context;
    end if;

    reset_nls;

    -- NOTE: the parameter order is different to this call
    -- than the parent routine's parameters. set_nls is a new
    -- routine and the parameter order is based on value dependency
    -- rather than the apparent ad hoc order of the old routines.
    set_nls(p_nls_language,
              p_nls_date_language,
              p_nls_sort,
            p_nls_territory,
              p_nls_date_format,
              p_nls_numeric_characters);

    if is_debugging then
      dump_context;
      debugger('end set_nls_context');
    end if;

  end set_nls_context;

  -- simply calls through to set_nls then returns all the nls
  -- values in the respective out parameters.
  procedure set_nls(p_nls_language in varchar2 default null,
                    p_nls_date_format in varchar2 default null,
                    p_nls_date_language in varchar2 default null,
                    p_nls_numeric_characters in varchar2 default null,
                    p_nls_sort in varchar2 default null,
                    p_nls_territory in varchar2 default null,
                    p_db_nls_language out nocopy varchar2,
                    p_db_nls_date_format out nocopy varchar2,
                    p_db_nls_date_language out nocopy varchar2,
                    p_db_nls_numeric_characters out nocopy varchar2,
                    p_db_nls_sort out nocopy varchar2,
                    p_db_nls_territory out nocopy varchar2,
                    p_db_nls_charset out nocopy varchar2) is
  begin

    check_logging;

    if is_debugging then
      debugger('begin set_nls');
      debugger(dbms_utility.format_call_stack);
      dump_context;
    end if;

    reset_nls;

    -- NOTE: the parameter order is different to this call
    -- than the parent routine's parameters. set_nls is a new
    -- routine and the parameter order is based on value dependency
    -- rather than the apparent ad hoc order of the old routines.
    set_nls(p_nls_language,
              p_nls_date_language,
              p_nls_sort,
            p_nls_territory,
              p_nls_date_format,
              p_nls_numeric_characters);

    p_db_nls_language := nls_language;
    p_db_nls_date_format := nls_date_format;
    p_db_nls_date_language := nls_date_language;
    p_db_nls_numeric_characters := nls_numeric_characters;
    p_db_nls_sort := nls_sort;
    p_db_nls_territory := nls_territory;
    p_db_nls_charset := get(FND_CONST.NLS_CHARACTERSET);

    if is_debugging then
      dump_context;
      debugger('end set_nls');
    end if;

  exception
    when others then
      log('fnd_global.set_nls.13', sqlcode, dbms_utility.format_error_stack);
  end set_nls;

  --
  -- builds the conditions passed to fnd_product_initialization.
  -- deprecated
  --
  function build_conditions return varchar2
  is
    c integer;
    p varchar2(2000);
    conditions varchar2(80) := null;
    procedure build(name varchar2) is
    begin
      if is_new(name) or (name = 'NLS' and nls_context_change) then
        if conditions is not null then
          conditions := conditions || '_';
        end if;
        conditions := conditions || ''''||z_conditions_map(name)||'''';
      end if;
    end;
  begin

    c := z_conditions_map.count;
    p := z_conditions_map.first;
    for i in 1..c loop
      build(p);
      p := z_conditions_map.next(p);
    end loop;

    return conditions;

  end build_conditions;

  --
  -- backup z_context. see restore.
  --
  procedure backup_context
  is
    c integer;
    p varchar2(2000);
  begin

    c := z_context.count;
    p := z_context.first;
    for i in 1..c loop
      z_backup(p) := z_context(p);
      p := z_context.next(p);
    end loop;

  end backup_context;

  --
  --
  -- org context initialization routine.
  -- This routine was broken out of initialize to isolate changes related only
  -- to the org context. initialize will call this when it performs normal
  -- initialization. initialize(name, value) will call this when the org
  -- context is being changed for R12.
  --
  procedure initialize_org_context
  as
  begin
    --
    -- handle ORG context change
    --
    if is_new(FND_CONST.ORG_ID) then

      -- if passed an org context and it is invalid (null ORG_NAME), clear the
      -- org context. this will only ever occur when explicitly called with
      -- ORG_ID via initialize(varchar2,varchar2).
      if org_name = null then
        clear(FND_CONST.ORG_ID);
      end if;

    else

      --
      -- set ORG context if we didn't just set it and resp or appl context
      -- changed
      if resp_context_change or appl_context_change then

        declare
          defined boolean;
          v_org_id_s varchar2(30);
        begin

          -- For R12, MO supports Multiple Organization Access Control (MOAC)
          -- which allows access to multiple operating units during a session.
          -- FND still requires an org_id context to set for FND_PROFILE via
          -- FND_GLOBAL.ORG_ID. Per guidance from MO Team, there are 3
          -- profiles to determine the ORG_ID to set at initialization:
          -- MO: Security Profile
          -- MO: Default Operating Unit
          -- MO: Operating Unit
          if fnd_release.major_version >= 12 then
            declare
              v_sec_prof_s varchar2(240);
            begin
              -- Bug 7109984
              -- Check the value of MO: Security Profile using get_specific
              -- since a context has not been set yet.
              fnd_profile.get_specific('XLA_MO_SECURITY_PROFILE_LEVEL',
                                        user_id,
                                        resp_id,
                                        resp_appl_id,
                                        v_sec_prof_s,
                                        defined);

              -- Bug 7109984
              -- If MO: Security Profile is not NULL then check for the
              -- MO: Default Operating Unit using get_specific since a context
              -- has not been set yet.
              if defined and v_sec_prof_s is not NULL then
                fnd_profile.get_specific('DEFAULT_ORG_ID',
                                        user_id,
                                        resp_id,
                                        resp_appl_id,
                                        v_org_id_s,
                                        defined);

                -- Bug 7109984
                -- If MO: Default Operating Unit returns a value, set it as
                -- the initial ORG_ID, the organization context.
                -- Note: this would make the return value of
                -- FND_GLOBAL.ORG_ID not always equal to the return value of
                -- FND_PROFILE.value('ORG_ID') since FND_GLOBAL.ORG_ID refers
                -- to the org context while FND_PROFILE.value('ORG_ID')
                -- refers to the value of the profile option MO: Operating
                -- Unit which are not the same.
                --
                -- Bug 10177414
                -- The IF-THEN Block:
                --    if defined and (org_id <> v_org_id_s) then
                --       ...
                --    else
                --       put_i(FND_CONST.ORG_ID,'-1');
                --    end if;
                -- introduced an issue where IF defined and org_id=v_org_id_s,
                -- then the organization context was reset to -1. Thus, the
                -- IF-THEN block needed to be broken down further to
                -- distinguish that case.
                if defined and v_org_id_s is not NULL then
                   if (org_id <> v_org_id_s) then
                      put_i(FND_CONST.ORG_ID,v_org_id_s);
                   end if;
                else
                  -- if DEFAULT_ORG_ID is null, set -1 as the organization
                  -- context.
                  put_i(FND_CONST.ORG_ID,'-1');
                end if;
              else
                -- If MO: Security Profile is not set, then get the value of
                -- ORG_ID profile option. This get specific call has to be
                -- made to get the org_id because the context is not yet set.
                fnd_profile.get_specific('ORG_ID',
                                         user_id,
                                         resp_id,
                                         resp_appl_id,
                                         v_org_id_s,
                                         defined);
                -- Bug 10177414
                -- The IF-THEN Block:
                --    if defined and (org_id <> v_org_id_s) then
                --       ...
                --    else
                --       put_i(FND_CONST.ORG_ID,'-1');
                --    end if;
                -- introduced an issue where IF defined and org_id=v_org_id_s,
                -- then the organization context was reset to -1. Thus, the
                -- IF-THEN block needed to be broken down further to
                -- distinguish that case.
                if defined and v_org_id_s is not NULL then
                  if (org_id <> v_org_id_s) then
                     put_i(FND_CONST.ORG_ID,v_org_id_s);
                  end if;
                else
                 -- if ORG_ID is null, set -1 as the organization context.
                 --
                 put_i(FND_CONST.ORG_ID,'-1');
                end if;
              end if;
            end;
          else
            -- This is for 11i.
            -- This get specific call has to be made to get the org_id because
            -- the context is not yet set.
            fnd_profile.get_specific('ORG_ID',
                                      user_id,
                                      resp_id,
                                      resp_appl_id,
                                      v_org_id_s,
                                      defined);

            -- Bug 10177414
            -- The IF-THEN Block:
            --    if defined and (org_id <> v_org_id_s) then
            --       ...
            --    else
            --       put_i(FND_CONST.ORG_ID,'-1');
            --    end if;
            -- introduced an issue where IF defined and org_id = v_org_id_s,
            -- then the organization context was reset to -1. Thus, the IF-THEN
            -- block needed to be broken down further to distinguish that
            -- case.
            if defined and v_org_id_s is not NULL then
               if (org_id <> v_org_id_s) then
                  put_i(FND_CONST.ORG_ID,v_org_id_s);
               end if;
            else
              -- if ORG_ID is null, set -1 as the organization context.
              put_i(FND_CONST.ORG_ID,'-1');
            end if;
          end if;

        end;

      end if;

    end if;

    org_context_change := is_new(FND_CONST.ORG_ID);

    if org_context_change then

      -- for consistency with prior versions, have to fetch org_name here
      -- so it can be set on sys_context
      clear(FND_CONST.ORG_NAME);

      declare
        v_org_name varchar2(2000);
      begin
        v_org_name := org_name;
      end;
      -- This synchronizes the org context with the client_info space such
      -- that FND_GLOBAL.ORG_ID = substrb(userenv('CLIENT_INFO'),1,10).
      fnd_client_info.set_org_context(org_id);
      -- Reset the transient profile option CURRENT_ORG_CONTEXT if the org
      -- context changes. Re-initialize the org context for FND_PROFILE.
      if fnd_release.major_version >= 12 then
        fnd_profile.put('CURRENT_ORG_CONTEXT', org_id);
        fnd_profile.initialize_org_context;
      end if;
    end if;

    -- Get_specific checks the cache but does not save to it.
    -- Due to a write-no-package-state pragma restriction in get_specific, it
    -- cannot be changed to cache any profile options as that would result in
    -- a pragma violation. So we are pre fetching these values to force them to
    -- be cached before any get_specific calls are made.
    -- This, according to ATGPERF, results in a performance improvement since it
    -- will eliminate trips to the DB.
    declare
      torg_id number;
      tsec_prof number;
      tdef_org_id number;

    begin
      -- For 11i, this call will cache ORG_ID and serve as the org context,
      -- as well. However, in R12, ORG_ID is not necessarily required if the
      -- 'MO: Security Profile' is not null and 'MO: Default Organization Unit'
      -- returns a value. It will only be useful if there is an actual profile
      -- option value fetch for the ORG_ID profile option.
      --
      -- if release >= 12
      if fnd_release.major_version >= 12 then
         -- get XLA_MO_SECURITY_PROFILE_LEVEL value
         fnd_profile.get('XLA_MO_SECURITY_PROFILE_LEVEL',tsec_prof);
         -- if XLA_MO_SECURITY_PROFILE_LEVEL is not null
         if tsec_prof is not null then
            -- get DEFAULT_ORG_ID value
            fnd_profile.get('DEFAULT_ORG_ID',tdef_org_id);
         else
            -- if XLA_MO_SECURITY_PROFILE_LEVEL is null
            -- get ORG_ID value
            fnd_profile.get(FND_CONST.ORG_ID,torg_id);
         end if;
      else
         -- If release is less than R12 then need to fall back on ORG_ID for
         -- the org context.
         fnd_profile.get(FND_CONST.ORG_ID,torg_id);
      end if;

    end;

  end initialize_org_context;

  --
  --
  -- main initialization routine.
  -- initialize from z_init setting z_context.
  -- order of initialization is probably importan
  --
  --
  procedure initialize
  as
    n varchar2(2000);
    v varchar2(2000);
    prd_init_pkg_called boolean := false;
    l_tab_user_name   fnd_user.user_name%TYPE;   --- added for bug 13654980
    l_user_id  fnd_user.user_id%TYPE := user_id;  --- added for bug 13654980
  begin

    check_logging;

    if is_debugging then
      debugger('begin initialize');
      debugger(dbms_utility.format_call_stack);
      dump_context;
    end if;

    -- Store away the argument values passed in case needed later for a
    -- a restore.
    if get('PERMISSION_CODE') is not null then
       backup_context;
       clear('PERMISSION_CODE');
    end if;

    -- Increment our context page id by 1.
    session_context := session_context + 1;

    if is_debugging then
      debugger('.  session_context: '||session_context);
    end if;

    z_context_change_flag := null;
    z_security_context_change_flag := null;

    user_context_change := is_new(FND_CONST.USER_ID);
    resp_context_change := is_new(FND_CONST.RESP_ID);
    appl_context_change := is_new(FND_CONST.RESP_APPL_ID);
    sec_context_change := is_new(FND_CONST.SECURITY_GROUP_ID);
    server_context_change := is_new(FND_CONST.SERVER_ID);
    site_context_change := is_new(FND_CONST.SITE_ID);

    --
    -- NLS initialization
    --
    set_nls(get(FND_CONST.NLS_LANGUAGE),
           get(FND_CONST.NLS_DATE_LANGUAGE),
           get(FND_CONST.NLS_SORT),
           get(FND_CONST.NLS_TERRITORY),
           get(FND_CONST.NLS_DATE_FORMAT),
           get(FND_CONST.NLS_NUMERIC_CHARACTERS));

    --
    -- SECURITY_GROUP_ID initialization
    --
    if sec_context_change then
      fnd_client_info.set_security_group_context(security_group_id);
    end if;

    --
    -- If necessary, check if this resp_id is accessible from the user_id
    --
    n := FND_CONST.PROG_APPL_ID;
    if is_new(n) and get(n) = '-999' then

      set_undefined(FND_CONST.PROG_APPL_ID);

      -- if any of the values are undefined, there will be no
      -- valid responsibility so clear resp_id/resp_appl_id
      if is_undefined(FND_CONST.USER_ID)
        or is_undefined(FND_CONST.SECURITY_GROUP_ID)
        or is_undefined(FND_CONST.RESP_ID)
        or is_undefined(FND_CONST.RESP_APPL_ID) then

        set_undefined(FND_CONST.RESP_ID);
        set_undefined(FND_CONST.RESP_APPL_ID);

      else

        declare
          v_uid integer := user_id;
          v_rid integer := resp_id;
          v_raid integer := resp_appl_id;
          v_sgid integer := security_group_id;
          v_count integer;
        begin

          select count(*)
            into v_count
            from fnd_user_resp_groups u
           where sysdate between u.start_date and nvl(u.end_date, sysdate)
             and u.security_group_id in (0, v_sgid)
             and u.user_id = v_uid
             and u.responsibility_id = v_rid
             and u.responsibility_application_id = v_raid;

          -- If there is a row, then all is well so just continue.
          -- Otherwise, no rows means this resp doesn't have access,
          -- so set resp_id/resp_appl_id as undefined.
          if 0 = v_count then
            set_undefined(FND_CONST.RESP_ID);
            set_undefined(FND_CONST.RESP_APPL_ID);
          end if;

        end;
      end if;
    end if;

    --
    -- Get session_id for return.
    -- This is done here to save a round trip.  The value is passed
    -- back to the client and used to set a client-side profile.
    -- Pl/sql should get this value directly.
    --
    put_i(FND_CONST.SESSION_ID,userenv('SESSIONID'));

    --
    -- query user information if user_id changed
    --
    if user_context_change then

      -- Would be nice to query these on-demand but the pragmas are all RNDS.

      -- Select name globals that were not directly passed.
      -- (Only untranslated ones are set here - translated names
      --  are re-selected every time in case of language change.)
      --
      declare
        v_user fnd_user%rowtype;
      begin
        v_user.user_id := user_id;

        select u.user_name,
               nvl(u.employee_id, FND_CONST.UNDEFINED_I) employee_id,
               nvl(u.customer_id, FND_CONST.UNDEFINED_I) customer_id,
               nvl(u.supplier_id, FND_CONST.UNDEFINED_I) supplier_id,
               nvl(u.person_party_id, FND_CONST.UNDEFINED_I) person_party_id
          into v_user.user_name,
               v_user.employee_id,
               v_user.customer_id,
               v_user.supplier_id,
               v_user.person_party_id
          from fnd_user u
         where u.user_id = v_user.user_id;

        put(FND_CONST.USER_NAME,v_user.user_name);
        put(FND_CONST.EMPLOYEE_ID,v_user.employee_id);
        put(FND_CONST.CUSTOMER_ID,v_user.customer_id);
        put(FND_CONST.SUPPLIER_ID,v_user.supplier_id);
        put(FND_CONST.PARTY_ID,v_user.person_party_id);

      exception
        when no_data_found then
          clear(FND_CONST.USER_NAME);
          clear(FND_CONST.EMPLOYEE_ID);
          clear(FND_CONST.CUSTOMER_ID);
          clear(FND_CONST.SUPPLIER_ID);
          clear(FND_CONST.PARTY_ID);

          -- I'd like to clear user_id too since it failed, it isn't valid,
          -- but that's not consistent with the old code.
          -- clear(FND_CONST.USER_ID);

      end;
         --  The setting of database client identifier session has been moved
         --  to tag_db_session call as part of Connection Tagging project. Whenever, this
         --  api will be called, the client identifier attribute will be set.
    else
        --- Else has been added for bug 13654980 - user_name not getting updated
        --- in the cache after it has been succesfully changed in fnd_user table.
        begin
        select       fu.user_name
        into         l_tab_user_name
        from         fnd_user fu
        where        fu.user_id = l_user_id;
        exception when others then
           l_tab_user_name := null;
        end;

        if l_tab_user_name is not null and l_tab_user_name <> user_name then
               put(FND_CONST.USER_NAME,l_tab_user_name);
        end if;
        --- code changes for bug 13654980 end.
    end if;

    -- Would be nice to query these on-demand but the pragmas are all RNDS.

    -- query fnd_application data if resp_appl_id changed
    --
    if appl_context_change then

      clear(FND_CONST.APPLICATION_SHORT_NAME);

      -- avoid executing the query if RESP_APPL_ID is -1
      -- and just clear the APPLICATION_SHORT_NAME instead
      if is_defined(FND_CONST.RESP_APPL_ID) then

        declare
          v_asn fnd_application.application_short_name%type;
          v_raid fnd_application.application_id%type := resp_appl_id;
        begin

          select a.application_short_name
            into v_asn
            from fnd_application a
           where a.application_id = v_raid;

          put(FND_CONST.APPLICATION_SHORT_NAME,v_asn);

        exception
          when no_data_found then
            null;
        end;

      end if;

    end if;

    --
    -- handle ORG context change
    --
    -- Bug 8335361: Broke off org context-specific initialization routines for
    -- MOAC so that it can be called without re-initializing everything else.
    initialize_org_context;

    --
    -- Core Logging
    --
    if debug_to_core then
      fnd_core_log.write('FG.I',
                         user_id,
                         resp_id,
                         resp_appl_id,
                         org_id,
                         server_id);
    end if;

    --
    -- LOGGING and PROFILES initialization
    --
    if context_changed then

      if is_debugging then
        debugger('before fnd_profile.initialize');
        dump_context;
      end if;

      --
      -- Initialize profile cache
      --
      fnd_profile.initialize(user_id,
                             resp_id,
                             resp_appl_id,
                             site_id);

    end if;

    -- this just enables values to be put the profiles now.
    z_allow_profile_puts := true;

    --
    -- Profile value initializations
    --
    initialize_profile_values;

    if user_resp_changed then

      -- This will start up debug logging.
      -- This call must occur after profiles have been initialized and
      -- when there is a user and resp.
      fnd_log_repository.init(NULL,user_id);

    end if;

    --
    -- get the ENABLE_SECURITY_GROUPS profile option value (1/2/01) jvc
    --
    -- bug 12875860 - mskees - HR is sensitive to any base security context change
    -- user, resp, app or sec_group, Mr. Buzaki has pointed out to me in other
    -- bugs that customers can and will change profile definitions so where we can
    -- we should accommodate this behavior so we should get this value accordingly.
    --
    if security_context_changed then
      z_security_groups_enabled := 'Y' = fnd_profile.value('ENABLE_SECURITY_GROUPS');
    end if;

/*  NOTE: the logic below seems incorrect ... just because Security groups is
NOT enabled we should NOT be reseting SECURITY_GROUP_ID or sec_context_change
both of these were set correctly in the code above and further based on those
settings we have set the client info record.  It is my opinion that this code
should be removed, BUT there is always the "well it has been this way forever"
attitude and is it safe to change it now?  So the odds are that SECURITY_GROUP_ID
is always '0' when HR is not used so that is why this has always worked, in older
releases we actually used security groups so it is possible this would hurt some
customers who still have customer code set up in an alternate security group.
i propose we remove this code in the next major testing cycle for the beginning of
12.2.1 - so it will get tested by the division to see if there are any unknown side
effects.
This code was added by Nix in version 115.99 as part of fix for bug 5404199 and
only as part of an attempt to make sure that the values are NOT NULL or '-1', so
we need to make sure that the value is properly inited when we set the sec group id.
*/
    if not z_security_groups_enabled then
      -- bug 12875860 adding this debug to confirm hypothesis above.
      if is_debugging then
        debugger('.  Security groups NOT enabled. SGID='||security_group_id);
      end if;
      put_i(FND_CONST.SECURITY_GROUP_ID,0);
      z_init(FND_CONST.SECURITY_GROUP_ID) := false;
      sec_context_change := false;
    else
      if is_debugging then
        debugger('.  Security groups enabled. SGID='||security_group_id);
      end if;
    end if;

    -- Profiles must be properly initialized before fnd_number.initialize.
    --
    -- Bug 2489275 - Since ICX_DATE_FORMAT_MASK is not tied to NLS_DATE_FORMAT,
    -- and the following relies on FND_GLOBAL.set_nls() being called when
    -- people want to initialize FND_DATE and FND_NUMBER packages, FND_DATE has
    -- been removed from this conditional and we leave FND_NUMBER which should
    -- be NLS related.
    --
    if nls_context_change then
      fnd_number.initialize();
    end if;

    -- Get_specific checks the cache but does not save to it.
    -- Due to a write-no-package-state pragma restriction in get_specific, it
    -- cannot be changed to cache any profile options as that would result in
    -- a pragma violation. So we are pre fetching these values to force them to
    -- be cached before any get_specific calls are made.
    -- This, according to ATGPERF, results in a performance improvement since it
    -- will eliminate trips to the DB.
    declare
      mrc_reporting_sob_id number;
      icx_language v$nls_parameters.value%type;
    begin

      if fnd_release.major_version < 12 then
        -- MRC is no longer used beyond 11i.
        fnd_profile.get('MRC_REPORTING_SOB_ID',mrc_reporting_sob_id);
        put('MRC_REPORTING_SOB_ID',mrc_reporting_sob_id);
      end if;

      fnd_profile.get(FND_CONST.ICX_LANGUAGE,icx_language);
      put(FND_CONST.ICX_LANGUAGE,icx_language);

    end;

    --
    -- Call routine to load MultiOrg and Multi-Currency info into
    -- the RDBMS session-level global variable that we read when we
    -- call USERENV('CLIENT_INFO')
    --
    if security_context_changed then
      fnd_client_info.setup_client_info(resp_appl_id,
                                        resp_id,
                                        user_id,
                                        security_group_id,
                                        org_id);
    end if;

    -- @todo is this too broad? should it just be if security_context_changed?
    if context_changed then

      -- Bug 2489275, FND_DATE.initialize will only be called with the
      -- ICX_DATE_FORMAT_MASK profile value if the profile value is NOT NULL
      -- and either this is the first time into FND_GLOBAL.initialize or there
      -- has been a real context change.
      declare
        user_calendar varchar2(20);
        plsql_block varchar2(240) := 'begin fnd_date.initialize_with_calendar(:1, null, :2); end;';
        -- This is declared as 240 simply because that is the maximum length of
        -- a profile value
        icx_date_format varchar(240) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
      begin
        -- this should never happen, but just in case ICX_DATE_FORMAT is null,
        -- we'll let fnd_date default to whatever it does.
        if icx_date_format is not null then
          -- Bug 9536949: non-Gregorian calendar support was introduced for the
          -- R12.FND.B (12.1) release.
          if fnd_release.major_version >= 12 and
            fnd_release.minor_version > 0 then
            -- Fetch the value of the FND_FORMS_USER_CALENDAR. This profile was
            -- introduced in R12.FND.B. This profile should only be fetched if
            -- instance is 12.1 or higher. This saves a profile fetch for EBS
            -- instances < 12.1.
            user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'),'GREGORIAN');
            execute immediate plsql_block using icx_date_format, user_calendar;
          else
            fnd_date.initialize(icx_date_format);
          end if;
        end if;
      end;

    end if;

    --
    -- Set the Resource Consumer Group based on the profile
    --
    declare
      pro_rcg varchar2(30);
      old_rcg varchar2(30);
    begin
      begin
        fnd_profile.get('FND_RESOURCE_CONSUMER_GROUP', pro_rcg);
        if (pro_rcg is not null) then -- bug 4466432
          dbms_session.switch_current_consumer_group(pro_rcg,old_rcg,FALSE);
        end if;
      end;
    exception
      when others then
        null;
    end;


   -- FND_PRODUCT_INITIALIZATION is no longer supported in FND_Global for R12++ see:
   -- http://files.oraclecorp.com/content/AllPublic/SharedFolders/ATG%20Requirements-Public/R12/Requirements%20Definition%20Document/Performance/session_initialization_callbacks.doc
   -- Also see bug 5263334 for follow on discussions about use of DiscoInit and
   -- the fnd_product_initialization table.
   --
   -- The ONLY exception to this for R12++ is HR (prod=PER)
   -- and PER-dependent applications which require HR Security init function
   -- from the HR_SIGNON PKG that is used to setup HR Security group profiles which are
   -- bundled very tightly with FND Global and Profiles ... mskees.
    declare
      doInit     boolean;
      conditions varchar2(80) := build_conditions;
    begin
      -- 15959817  R12 check added back with checks for HR ...
      if fnd_release.major_version >= 12 then
        -- 12875860 expand the conditions to include all security context changes
        -- 16196565 remove specific check for PER application
        -- to allow init sequence for PER-dependent applications
        if application_short_name is not null and z_security_groups_enabled then
          doInit := true;
          -- 16196565 mask all R12 init conditions as SEC which triggers
          -- only the PER init function for PER and PER dependencies
          conditions := '''SEC''';
        else
          doInit := false;
        end if;
      else
       -- 11i Only do the initialization callbacks for a valid application.
        if application_short_name is not null and conditions is not null then
          doInit := true;
        else
          doInit := false;
        end if;
      end if;

      if doInit then
        put('fnd_prod_init.conditions',conditions);
        if is_debugging then
          debugger('.  fnd_product_initialization_pkg:'||application_short_name);
          debugger('.  conditions:'||conditions);
        end if;
        fnd_product_initialization_pkg
          .execInitFunction(application_short_name,conditions);
        -- Set Prod INIT flag, this indicates whether the fnd init code was executed
        -- and will be used later to determine how local values and HR PUT values
        -- are set.  If the init code was NOT executed and the PUT cache was
        -- cleared this will help know to reset the HR PUT values
        prd_init_pkg_called := true;
      end if;
    exception
      when others then
        put('fnd_prod_init.error',sqlerrm);
    end;


    --
    -- Custom initialization profile
    -- FND_INIT_SQL data should be moved to FND_PRODUCT_INITIALIZATION table.
    --
    declare
      curs integer;
      sqlbuf varchar2(2000);
      tmpbuf varchar2(2000) := get(FND_CONST.FND_INIT_SQL);
      rows integer;
    begin

      -- Bug 8335361: With MO_GLOBAL now calling FND_GLOBAL.INITIALIZE and
      -- FND_INIT_SQL allowing MO_GLOBAL APIs to be used, there is a possibility
      -- that a recursive call might occur. So, need to check whether the code
      -- is already in this code block.
      if not in_fnd_init_sql then

        -- Set flag to indicate that code flow is currently in this code block.
        in_fnd_init_sql := TRUE;

        if is_debugging then
          debugger('in_fnd_init_sql is NOW TRUE');
        end if;

        -- Check if FND_INIT_SQL has a value
        fnd_profile.get(FND_CONST.FND_INIT_SQL, sqlbuf);

        if sqlbuf is not null then
          -- If FND_CONST.FND_INIT_SQL is null or if the profile option value
          -- is different from FND_CONST.FND_INIT_SQL
          if (tmpbuf is null or sqlbuf <> tmpbuf) then
            if is_debugging then
              debugger('.  fnd_init_sql:'||sqlbuf);
            end if;
            -- Change FND_CONST.FND_INIT_SQL to new profile option value
            put(FND_CONST.FND_INIT_SQL,sqlbuf);
          end if;

          -- FND_INIT_SQL needs to execute for each initialization
          curs := dbms_sql.open_cursor;
          dbms_sql.parse(curs, sqlbuf, dbms_sql.v7);
          rows := dbms_sql.execute(curs);
          dbms_sql.close_cursor(curs);
        end if;

        -- Set flag to indicate that the code is exiting this code block.
        in_fnd_init_sql := FALSE;
        if is_debugging then
          debugger('in_fnd_init_sql is now FALSE');
        end if;
      else
        if is_debugging then
          debugger('in_fnd_init_sql is still TRUE');
        end if;
      end if; -- in_fnd_init_sql
    exception
      when others then
        -- Just in case...
        if (dbms_sql.is_open(curs)) then
          dbms_sql.close_cursor(curs);
        end if;
        in_fnd_init_sql := FALSE;
        throw('fnd_global.initialize[fnd_init_sql]',
              sqlcode, dbms_utility.format_error_stack);
    end;

    -- Bug 12875860 - mskees - HR security group profile control
    --
    -- "ENABLE_SECURITY_GROUPS = 'N' -> use actual FND table values stored by
    -- standard FND profile forms and code, use normal FND profile hierarchy
    -- behavior returning value at site level unless set at one of the lower
    -- security/hierarchy levels RESP_ID, APP_ID or USER.
    --
    -- "ENABLE_SECURITY_GROUPS = 'Y' -> call HR_SIGNON.INITIALIZE_HR_SECURITY
    -- via fnd_product_initialization_pkg for any change in user_id,
    -- application_id, responsibility_id or security_group_id.  This will
    -- set/reset the Profile PUT cache values for these PER profiles, we will
    -- then set FND_GLOBAL local variables for both PER_SECURITY_PROFILE_ID and
    -- PER_BUSINESS_GROUP_ID."
    --
    -- But if INITIALIZE is called twice with the same or similar parameters
    -- we will reset the profile cache but since there has been no context
    -- change we will not call the product initialization code again, so we
    -- must make sure that these two values are re-cached from the Global CONST
    -- values.

    if z_security_groups_enabled then
    -- "ENABLE_SECURITY_GROUPS = 'Y' ->  HR controlled values

      if ( prd_init_pkg_called and security_context_changed ) then
      -- HR_SIGNON.INITIALIZE_HR_SECURITY was called they updated profile PUT's
      -- so we should load Local CONST values

        -- get value from PUT cache
        v := fnd_profile.value(FND_CONST.PER_BUSINESS_GROUP_ID);
        -- load local value
        put(FND_CONST.PER_BUSINESS_GROUP_ID,v,false);

        -- get value from PUT cache
        v := fnd_profile.value(FND_CONST.PER_SECURITY_PROFILE_ID);
        -- load local value
        put(FND_CONST.PER_SECURITY_PROFILE_ID,v,false);

        if is_debugging then
          debugger('HR context change');
          debugger('HR PER_BUSINESS_GROUP_ID: '||get(FND_CONST.PER_BUSINESS_GROUP_ID));
          debugger('HR PER_SECURITY_PROFILE_ID: '||get(FND_CONST.PER_SECURITY_PROFILE_ID));
        end if;

      else
      -- HR_SIGNON not called but we are in security group mode
      -- this could be a duplicated call to init with same values
      -- this could be a change in NLS, ORG or Server

        if FND_PROFILE.PUT_CACHE_CLEARED then
        -- profile PUT cache was cleared so we need to reset HR values from
        -- previous call to HR_SIGNON as stored in CONST local values
          fnd_profile.put(FND_CONST.PER_BUSINESS_GROUP_ID, get(FND_CONST.PER_BUSINESS_GROUP_ID));
          fnd_profile.put(FND_CONST.PER_SECURITY_PROFILE_ID, get(FND_CONST.PER_SECURITY_PROFILE_ID));

            if is_debugging then
              debugger('HR_SIGNON not called but PUT cleared');
              debugger('HR PER_BUSINESS_GROUP_ID: '||get(FND_CONST.PER_BUSINESS_GROUP_ID));
              debugger('HR PER_SECURITY_PROFILE_ID: '||get(FND_CONST.PER_SECURITY_PROFILE_ID));
            end if;

        end if;
        -- else profile PUT cache was not cleared so previous HR values and our
        -- local CONST values are still in place

      end if;
    else
    -- "ENABLE_SECURITY_GROUPS = 'N' -> use FND table values
    -- we clear PUT cache here to make sure these values come from DB on fetch
    -- historicly we have not, yet it worked,  i assume since according to HR
    -- once enabled it is permanent in the instance for HR ... but the
    -- ENABLE_SECURITY_GROUPS is also settable at app level so for other
    -- prods it may/should not be enabled but then they are not likely using
    -- PER profiles so we have never seen a bug.

      -- first clear PUT cache
      fnd_profile.put(FND_CONST.PER_BUSINESS_GROUP_ID, FND_DELETE_VALUE);
      fnd_profile.put(FND_CONST.PER_SECURITY_PROFILE_ID, FND_DELETE_VALUE);

      -- get real profile value
      v := fnd_profile.value(FND_CONST.PER_BUSINESS_GROUP_ID);
      -- load local value
      put(FND_CONST.PER_BUSINESS_GROUP_ID,v,false);

      -- get real profile value
      v := fnd_profile.value(FND_CONST.PER_SECURITY_PROFILE_ID);
      -- load local value
      put(FND_CONST.PER_SECURITY_PROFILE_ID,v,false);

      -- put debug out just for FYI
      if is_debugging then
        debugger('NOT HR security group');
        debugger('HR PER_BUSINESS_GROUP_ID: '||get(FND_CONST.PER_BUSINESS_GROUP_ID));
        debugger('HR PER_SECURITY_PROFILE_ID: '||get(FND_CONST.PER_SECURITY_PROFILE_ID));
      end if;

    end if;


    -- fetch all the logging profiles so that logging can
    -- be properly initialized
    put_from_profile(FND_CONST.AFLOG_ENABLED);
    put_from_profile(FND_CONST.AFLOG_MODULE);
    put_from_profile(FND_CONST.AFLOG_LEVEL);
    put_from_profile(FND_CONST.AFLOG_FILENAME);

    -- clear all the derived values that are cached as a
    -- result of lazy initialization.
    clear_derived_values;

    if is_debugging then
      dump_context;
      debugger('end initialize');
    end if;

    -- don't allow any puts to profiles until this flag is true,
    -- which will be the next time through initialize, at the appropriate point.
    z_allow_profile_puts := false;

  end initialize;

  --
  -- p_hashtable is a name/value pairs to initialize.
  procedure initialize(p_mode in varchar2,
                       p_nv in out nocopy fnd_const.t_hashtable)
  as
    c integer;
    p varchar2(2000);
  begin

    if p_mode = FND_CONST.MODE_IN or p_mode = FND_CONST.MODE_INOUT then

      z_init.delete;

      c := p_nv.count;
      p := p_nv.first;
      for i in 1..c loop
        put(upper(p),p_nv(p));
        p := p_nv.next(p);
      end loop;

      z_force_init := force_init;
      initialize;

    end if;

    if p_mode = FND_CONST.MODE_OUT or p_mode = FND_CONST.MODE_INOUT then

      c := z_context.count;
      p := z_context.first;
      for i in 1..c loop
        p_nv(p) := z_context(p);
        p := z_context.next(p);
      end loop;

    end if;

  end initialize;

  --
  -- p_nv is a name/value pairs to initialize.
  procedure initialize(p_nv in out nocopy fnd_const.t_hashtable)
  as
  begin
    initialize(FND_CONST.MODE_INOUT,p_nv);
  end initialize;

  --
  -- initialize a single attribute
  --
  procedure initialize(name varchar2, value varchar2)
  as
  begin

    z_init.delete;

    -- If initialize was called for an org_context change and the applications
    -- release is R12, then the code will just change the org context if the
    -- current org_context is not equal to the org_context passed in.
    if upper(name) = 'ORG_ID' and fnd_release.major_version >= 12 then
      if (FND_GLOBAL.ORG_ID <> to_number(value)) then
        if is_debugging then
          -- This will indicate the caller of this API when an attempt to
          -- change the org context is made.
          debugger(dbms_utility.format_call_stack);
          -- This indicates what the org context is being changed to, and what
          -- it is currently set to.
          debugger('Org Context change:New ORG_ID='||value||' FND_GLOBAL.ORG_ID='
            ||FND_GLOBAL.ORG_ID);
        end if;
        put(upper(name),value);
        initialize_org_context;
      else
        if is_debugging then
          debugger('Org Context unchanged: FND_GLOBAL.ORG_ID=ORG_ID');
        end if;
      end if;
    else
      -- Initialize normally
      put(upper(name),value);
      initialize;
    end if;

  end initialize;

  --
  -- SET_SECURITY_GROUP_ID_CONTEXT
  -- Set the FND.SECURITY_GROUP_ID for SYS_CONTEXT as used by SECURITY_GROUP_ID_POLICY
  -- INTERNAL AOL USE ONLY
  --
  procedure set_security_group_id_context(security_group_id in number) is
  begin
    initialize(FND_CONST.SECURITY_GROUP_ID, to_char(security_group_id));
  exception
    when others then
      log('fnd_global.set_security_group_id_context',
          sqlcode, dbms_utility.format_error_stack);
  end;

  --
  --
  --
  --
  procedure apps_initialize(user_id in number,
                            resp_id in number,
                            resp_appl_id in number,
                            security_group_id in number default 0,
                            server_id in number default -1)
  is
    session_id number := null;
  begin

   initialize(session_id, user_id, resp_id, resp_appl_id,
              security_group_id, -1, -1, -1, -1, -1, -1,
              null,null,null,null,null,null,server_id);

  end apps_initialize;

  --
  -- INITIALIZE
  -- Set new values for security globals when new login or responsibility
  -- INTERNAL AOL USE ONLY
  --
  procedure initialize(session_id in out nocopy number,
                       user_id               in number,
                       resp_id               in number,
                       resp_appl_id          in number,
                       security_group_id     in number,
                       site_id               in number,
                       login_id              in number,
                       conc_login_id         in number,
                       prog_appl_id          in number,
                       conc_program_id       in number,
                       conc_request_id       in number,
                       conc_priority_request in number,
                       form_id               in number default null,
                       form_appl_id          in number default null,
                       conc_process_id       in number default null,
                       conc_queue_id         in number default null,
                       queue_appl_id         in number default null,
                       server_id             in number default -1)
  is
    v_nv fnd_const.t_hashtable;

    -- set a value in v_nv (list of new name/value pairs)
    procedure put_nv(name varchar2, value varchar2)
    as
    begin
      if value is not null then
        v_nv(name) := value;
      end if;
    end put_nv;

  begin

    put_nv(FND_CONST.USER_ID,to_char(user_id));
    put_nv(FND_CONST.RESP_ID,to_char(resp_id));
    put_nv(FND_CONST.RESP_APPL_ID,to_char(resp_appl_id));
    put_nv(FND_CONST.SECURITY_GROUP_ID,to_char(nvl(security_group_id,0)));
    put_nv(FND_CONST.SITE_ID,to_char(site_id));
    put_nv(FND_CONST.LOGIN_ID,to_char(login_id));
    put_nv(FND_CONST.CONC_LOGIN_ID,to_char(conc_login_id));
    put_nv(FND_CONST.PROG_APPL_ID,to_char(prog_appl_id));
    put_nv(FND_CONST.CONC_PROGRAM_ID,to_char(conc_program_id));
    put_nv(FND_CONST.CONC_REQUEST_ID,to_char(conc_request_id));
    put_nv(FND_CONST.CONC_PRIORITY_REQUEST,to_char(conc_priority_request));
    put_nv(FND_CONST.FORM_ID,to_char(nvl(form_id,FND_CONST.UNDEFINED_I)));
    put_nv(FND_CONST.FORM_APPL_ID,to_char(nvl(form_appl_id,FND_CONST.UNDEFINED_I)));
    put_nv(FND_CONST.CONC_PROCESS_ID,to_char(nvl(conc_process_id,FND_CONST.UNDEFINED_I)));
    put_nv(FND_CONST.CONC_QUEUE_ID,to_char(nvl(conc_queue_id,FND_CONST.UNDEFINED_I)));
    put_nv(FND_CONST.QUEUE_APPL_ID,to_char(nvl(queue_appl_id,FND_CONST.UNDEFINED_I)));
    put_nv(FND_CONST.SERVER_ID,to_char(server_id));

    -- mode_in since the only out variable can be obtained from a function
    initialize(FND_CONST.MODE_IN,v_nv);

    session_id := fnd_global.session_id;

  end initialize;

  --
  -- UNINITIALIZE, setting to null, all context values.
  --
  procedure uninitialize is
    c integer;
    p varchar2(2000);
  begin

    c := z_context.count;
    p := z_context.first;
    for i in 1..c loop
      set_undefined(p);
      p := z_context.next(p);
    end loop;

   z_first_initialization := true;
   initialize;

  end uninitialize;

  --
  -- INITIALIZE RT
  -- Set rt test id
  -- INTERNAL AOL USE ONLY
  --
  procedure rt_initialize(rt_test_id in number) is
  begin
      --
      -- Set globals from parameters
      --
      put(FND_CONST.RT_TEST_ID,rt_test_id);

  end RT_INITIALIZE;

  --
  --   Only a few Oracle FND developers will ever call this routine.
  --   Because it is so rare that anyone would ever call this
  --   routine, we aren't going to document it so as not to
  --   confuse people.  All you need to know is that calling this
  --   routine incorrectly can easily cause showstopper problems
  --   even for code outside your product.  So just don't call it
  --   unless you have been told to do so by an Oracle FND
  --   development manager.
  --
  --   in argument:
  --      permission_code- if you have permission to call this
  --                       you will have been given a unique code
  --                       that only you are allowed to pass to
  --                       confirm that your call is permitted.
  --
  --   see the internal oracle document for more details:
  --   http://www-apps.us.oracle.com/atg/plans/r115x/contextintegrity.txt
  --
  procedure bless_next_init(permission_code in varchar2) is
  begin
    if    ((permission_code >= 'FND_PERMIT_0000')
       and (permission_code <= 'FND_PERMIT_0500'))
    then
      put('PERMISSION_CODE',substrb(permission_code, 1, 30));
    end if;
  end;

  --
  -- Restores the context to the last "approved" value saved away,
  -- and gives a warning if the value was not already the approved value.
  --
  procedure restore is
  begin

    if (fnd_profile.value('FND_DEVELOPER_MODE') = 'Y') then
      raise_application_error(-20009,
        'Developer error: FND_GLOBAL initialization potential side effects. '||
        'Remove the call that initialized the context to resp_id: '||
        resp_id||' resp_appl_id: '||resp_appl_id||' user_id: '||
        user_id || '. '||
        'This message indicates that the context value set with the last ' ||
        'FND_GLOBAL init call could unintentionally affect code running ' ||
        'later on in the session. '||
        'This message indicates a problem in a previous call to FND_GLOBAL '||
        'initialization routines.  It does not indicate any problem with the '||
        'FND_GLOBAL package itself. '||
        'Unset the FND_DEVELOPER_MODE profile if you are seeing this '||
        'message in a production environment.');
    end if;

    initialize(z_backup);

    if(fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
       'oracle.apps.plsql.fnd_global.restore.changed ',
       'Developer error: FND_GLOBAL initialization potential side effects.  '||
       'Remove the call that initialized the context to resp_id: '||
       resp_id||' resp_appl_id: '||resp_appl_id||' user_id: '||
       user_id || '. '||
       'This message indicates that the context value set with the last ' ||
       'FND_GLOBAL init call could unintentionally affect code running ' ||
       'later on in the session. '||
       'This message indicates a problem in a previous call to FND_GLOBAL '||
       'initialization routines.  It does not indicate any problem with the '||
       'FND_GLOBAL package itself. '||
       'Unset the FND_DEVELOPER_MODE profile if you are seeing this '||
       'message in a production environment.');
    end if;

  end;

  --
  -- Debugging Routines
  --
  --
  --
  --

  -- DUMP_CONTEXT
  --
  -- example output formats with comments interlaced:
  --    # this means NAME1's value has changed to VALUE
  -- *  NAME1=(5)VALUE
  --    # this means NAME2's value is unchanged
  -- .  NAME2=(9)NEW VALUE
  --    # this means NAME3's value has changed to V and is different than profiles
  -- *p NAME3=(1)V:(5)VALUE

  procedure dump_context is
    -- oops. sorry, these are very poor names.
    c integer;
    p varchar2(2000);
    b varchar2(3);
    f varchar2(300);
    g varchar2(300);
  begin
    -- force some derived value gets.
    p := application_name;
    p := base_language;
    p := current_language;
    p := org_name;
    c := language_count;

    -- dump the context
    debugger('z_contex');
    debugger('---------');
    c := z_context.count;
    p := z_context.first;
    for i in 1..c loop

      -- context values that have changed will start with '*',
      -- otherwise they start with '.'.
      if is_new(p) then b := '*'; else b := '.'; end if;

      -- the general 'name=(length)value' text
      g := p||'=('||length(z_context(p))||')'||substr(z_context(p),1,100);

      -- check if the name has a corresponding profile value
      f := fnd_profile.value(p);

      -- if there is a profile value but it's different than the context,
      -- add a 'p' to the change/no-change symbol and concatenate the
      -- profile as ':(length)value'
      if nvl(f,z_context(p)) <> z_context(p) then
        b := b||'p';
        g := g||':('||length(f)||')'||substr(f,1,100);
      else
        -- profile is null or the same as context value
        b := b||' ';
      end if;

      debugger(b||' '||g);

      p := z_context.next(p);
    end loop;
    debugger('---------'||fnd_const.newline);

  end;

/* The function validates the value for module_type.
   It returns true, if module_type is null or invalid
   else returns false;
*/
function is_invalid_module_type(module_type varchar2)
return boolean is
begin
  if(module_type is null or
         module_type not in (FRM,FWK,JTT,CP,WF,BES,REPORT,ALERT,ISG,GSM,HELP,BINARY_PROGRAM)) then
    return true;
  else
    return false;
  end if;
end;

/* This returns the length of MODULE and ACTION column of v$session.
   This ensures the support on any release of DB
*/
function getColumnLength(cname varchar2)
return number is
  len number := 0;
begin
  select data_length
  into len
  from all_tab_columns
  where owner = 'SYS' and table_name = 'V_$SESSION' and column_name = cname;
  return len;
exception
  when others then
    return len;
end;

/*
* bug13831550 - performance issue, solved by calling the function
*               getColumnLength only once per plsql-session.
*/
Procedure setSessionColumnLength is
begin
  if ( gbl_read_sinfo = -1 ) then
       gbl_session_module := getColumnLength('MODULE');
       gbl_session_action := getColumnLength('ACTION');
       gbl_read_sinfo := 0;
  end if;
end setSessionColumnLength;


/*  Overloaded procedure of tag_db_session. This is a PRIVATE API currently.
*   This api will be used by module_types which does not set any context using
*   fnd_global.apps_initialize. Sets the module and action field of v$session.
*
*   module_type : type of program being called (always in lowercase)
*   appname : application name
*   module_name : The module name that performs the action
*   resp_app : responsibility application name
*   resp_key : responsibility application key
*   username : name of the user performing the action
*/
procedure tag_db_session(
      module_type IN VARCHAR2,
      appname     IN VARCHAR2,
      module_name IN VARCHAR2,
      p_resp_appl IN VARCHAR2,
      p_resp_key  IN VARCHAR2,
      username  IN VARCHAR2)
is
   module        V$SESSION.MODULE%TYPE;
   action        V$SESSION.ACTION%TYPE;
   l_module_type VARCHAR2(10) := lower(module_type); -- always in lowercase
   isConnEnabled varchar2(10);
   l_module_len integer;
   l_module_col_len integer;
   l_action_len integer;
   l_action_col_len integer;
   l_module_name varchar2(1000);
   l_module_name_prefix varchar2(100);
begin
   isConnEnabled := fnd_profile.value('FND_CONNECTION_TAGGING');
   if(isConnEnabled is null or isConnEnabled = 'DISABLED') then
     return;
   end if;
   if(is_invalid_module_type(module_type)) then
     return;
   end if;
   /* bug13831550 */
   setSessionColumnLength;
   l_module_col_len := gbl_session_module;
   l_action_col_len := gbl_session_action;
   if( l_module_col_len = 0 or l_action_col_len = 0) then
      return;
   end if;
   -- Constructing MODULE information for tagging v$SESSION.MODULE
   -- If module_type = help, then no need to determine module_name
   if(HELP = l_module_type) then
      l_module_name := NULL;
      l_module_name_prefix := EBS ||':'|| 'fnd' ||':'|| l_module_type;
   else
      l_module_name := module_name;
      l_module_name_prefix := EBS ||':'|| appname ||':'|| l_module_type || ':';
   end if;

   l_module_len := length(l_module_name_prefix || l_module_name);

   if l_module_len > l_module_col_len then
      if (l_module_name is NOT NULL) then
         if (instr(lower(l_module_name), 'oracle.apps') <> 0) then
            -- MODULE_NAME has information in pkg structure. So do left truncation on passed in module_name.
         -- retrieves l_module_col_len characters from end;
            l_module_name := substr(l_module_name,-(length(l_module_name)-(l_module_len-l_module_col_len)),length(l_module_name)-(l_module_len-l_module_col_len));
            module := l_module_name_prefix || l_module_name;
         else
            -- MODULE_NAME doesn't has information in pkg structure. So do right truncation.
            module := substr(l_module_name_prefix || l_module_name, 1, l_module_col_len);
         end if;
      end if;
   else
      module := l_module_name_prefix || l_module_name;
   end if;

   -- Constructing ACTION information for tagging v$SESSION.ACTION
   if(HELP = l_module_type) then
      action := NULL;
   elsif(BINARY_PROGRAM = l_module_type) then
         -- then action is set to SYSADMIN by default.
         action := 'SYSADMIN';
   else
         l_action_len := length(p_resp_appl || '/' || p_resp_key);
         if l_action_len > l_action_col_len then
            action := substr(p_resp_appl || '/' || p_resp_key, 1, l_action_col_len);
    else
       action := p_resp_appl || '/' || p_resp_key;
         end if;
   end if;

   dbms_session.set_identifier(username);
   -- Set the module and action field of v$session
   dbms_application_info.set_module(module,action);
exception
   when others then
      return;
end tag_db_session;


/*  Sets the module and action field of v$session. This API is used when a
*   context has been established via fnd_global.apps_initialize().
*   module_type : type of program/function/action being called (always in lowercase)
*   module_name : The module or code class name that performs the action.
*/
procedure tag_db_session(
      module_type in varchar2,
      module_name in varchar2)
is
  l_app_short_name varchar2(50) := application_short_name;
  l_user_name varchar2(100) := user_name;
  l_resp_key varchar2(30) := resp_key;

begin

   -- call overloaded tag_db_session
   -- application_short_name, resp_key, and user_name are fnd_global functions
   tag_db_session( module_type=>module_type,
                   appname=>l_app_short_name,
                   module_name=>module_name,
                   p_resp_appl=>l_app_short_name,
                   p_resp_key=>l_resp_key,
                   username=>l_user_name);
end tag_db_session;


/*  Overloaded function for tag_db_session.
*   This api sets client_identifier and action to SYSADMIN
*   module_type : type of program/function/action being called (always in lowercase)
*   module_name : The module or code class name that performs the action.
*   application_name : application short name to which the program_name belongs to.
*/
procedure tag_db_session(
      module_type      IN VARCHAR2,
      module_name      IN VARCHAR2,
      application_name IN VARCHAR2)
is
  l_user_name varchar2(100) := 'SYSADMIN';
begin
   -- call overloaded tag_db_session
    tag_db_session( module_type=>module_type,
                    appname=>application_name,
                    module_name=>module_name,
                    p_resp_appl=>null,
                    p_resp_key=>null,
                    username=>l_user_name);
end tag_db_session;

begin

  -- all these constants can't reference the FND_CONST package
  -- because of pragam issues with the spec for this package.

  -- true means to initialize these values after calling
  -- fnd_profile.initialize.
  -- false is reserved for the PER* in which we don't want
  -- to do initialization along with the others.
  z_init_profiles('CONC_LOGIN_ID')           := true;
  z_init_profiles('CONC_PRIORITY_REQUEST')   := true;
  z_init_profiles('CONC_PROGRAM_ID')         := true;
  z_init_profiles('CONC_REQUEST_ID')         := true;
  z_init_profiles('LOGIN_ID')                := true;
  z_init_profiles('PER_BUSINESS_GROUP_ID')   := false;
  z_init_profiles('PER_SECURITY_PROFILE_ID') := false;
  z_init_profiles('PROG_APPL_ID')            := true;
  z_init_profiles('RT_TEST_ID')              := true;

  z_conditions_map('NLS')                    := 'NLS';
  z_conditions_map('ORG_ID')                 := 'ORG';
  z_conditions_map('RESP_APPL_ID')           := 'APPL';
  z_conditions_map('RESP_ID')                := 'RESP';
  z_conditions_map('SECURITY_GROUP_ID')      := 'SEC';
  z_conditions_map('SERVER_ID')              := 'SERVER';
  z_conditions_map('USER_ID')                := 'USER';

  z_syscontext('APPLICATION_SHORT_NAME')     := true;
  z_syscontext('CONC_LOGIN_ID')              := true;
  z_syscontext('CONC_PRIORITY_REQUEST')      := true;
  z_syscontext('CONC_PROCESS_ID')            := true;
  z_syscontext('CONC_PROGRAM_ID')            := true;
  z_syscontext('CONC_QUEUE_ID')              := true;
  z_syscontext('CONC_REQUEST_ID')            := true;
  z_syscontext('CUSTOMER_ID')                := true;
  z_syscontext('EMPLOYEE_ID')                := true;
  z_syscontext('FORM_APPL_ID')               := true;
  z_syscontext('FORM_ID')                    := true;
  z_syscontext('LOGIN_ID')                   := true;
  z_syscontext('ORG_ID')                     := true;
  z_syscontext('ORG_NAME')                   := true;
  z_syscontext('PARTY_ID')                   := true;
  z_syscontext('PER_BUSINESS_GROUP_ID')      := true;
  z_syscontext('PER_SECURITY_PROFILE_ID')    := true;
  z_syscontext('PROG_APPL_ID')               := true;
  z_syscontext('QUEUE_APPL_ID')              := true;
  z_syscontext('RESP_APPL_ID')               := true;
  z_syscontext('RESP_ID')                    := true;
  z_syscontext('SECURITY_GROUP_ID')          := true;
  z_syscontext('SERVER_ID')                  := true;
  z_syscontext('SESSION_ID')                 := true;
  z_syscontext('SITE_ID')                    := true;
  z_syscontext('SUPPLIER_ID')                := true;
  z_syscontext('USER_ID')                    := true;
  z_syscontext('USER_NAME')                  := true;

end fnd_global;

/

  GRANT EXECUTE ON "APPS"."FND_GLOBAL" TO "EM_OAM_MONITOR_ROLE";
