--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_BUSINESS_EVENT" as
/* $Header: AFCPBIAB.pls 120.0 2007/12/17 20:37:07 tkamiya noship $ */

------------------------------------------------------------------------
--   constants
------------------------------------------------------------------------
NTRUE		constant	number :=1;
NFALSE		constant	number :=0;


-----------------------------------------------------------------
--  parse_event_name_from_number                               --
--  returns event name when called with event_number           --
-----------------------------------------------------------------
function parse_event_name_from_number(
  p_event_code  in number)
  return varchar2
is
  v_event_name   varchar2(100);
begin

  select decode(p_event_code, 1, 'oracle.apps.fnd.concurrent.request.submitted',
                              2, 'oracle.apps.fnd.concurrent.request.on_hold',
                              3, 'oracle.apps.fnd.concurrent.request.resumed',
                              4, 'oracle.apps.fnd.concurrent.request.running',
                              5, 'oracle.apps.fnd.concurrent.program.completed',
                              6, 'oracle.apps.fnd.concurrent.request.postprocessing_started',
                              7, 'oracle.apps.fnd.concurrent.request.postprocessing_ended',
                              8, 'oracle.apps.fnd.concurrent.request.completed',
                              'NOT_FOUND')
       into v_event_name
       from dual;

  return v_event_name;

end parse_event_name_from_number;


-------------------------------------------------------------------------
-- raise_wf_bi_event_1
--   Internal function called from raise_cp_bi_event only
--   Sets up parameter list and raises business event
-------------------------------------------------------------------------
procedure raise_wf_bi_event_1(
  p_event_number                in number,
  p_event_name                  in varchar2,
  p_request_id                  in number,
  p_requested_by                in number,
  p_program_application_id      in number,
  p_concurrent_program_id       in number,
  p_status                      in varchar2,
  p_completion_text             in varchar2,
  p_time_stamp                  in date)
is
  v_params                      WF_PARAMETER_LIST_T;
  v_event_key                   varchar2(100);
  v_request_id                  varchar2(17);

begin
  v_request_id:=to_char(p_request_id,'FM999999999999999');
  ------------------------------------------------
  -- log an addparameter message                --
  ------------------------------------------------
  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,'fnd.plsql.fnd_concurrent_business_event.raise_cp_bi_event',
                'Concurrent Manager/Request for request id '||
                 v_request_id||
                 ' is PREPARING PARAMETERS for Business Event '||
                 p_event_name);
  end if;

  ------------------------------------------------
  -- Prepare a parameter list                   --
  ------------------------------------------------
  WF_EVENT.AddParameterToList('REQUEST_ID', to_char(p_request_id,'FM999999999999999'), v_params);
  WF_EVENT.AddParameterToList('REQUESTED_BY', to_char(p_requested_by,'FM999999999999999'), v_params);
  WF_EVENT.AddParameterToList('PROGRAM_APPLICATION_ID', to_char(p_program_application_id,'FM999999999999999'), v_params);
  WF_EVENT.AddParameterToList('CONCURRENT_PROGRAM_ID', to_char(p_concurrent_program_id,'FM999999999999999'), v_params);
  WF_EVENT.AddParameterToList('STATUS', p_status, v_params);
  WF_EVENT.AddParameterToList('COMPLETION_TEXT', p_completion_text, v_params);
  WF_EVENT.AddparameterToList('TIME_STAMP', to_char(p_time_stamp, 'MMDDYY HH24MISS'), v_params);

  --------------------------------------------------------------------------------------
  -- create a unique key by tailing request_id with Julian date and event number      --
  --------------------------------------------------------------------------------------
  v_event_key := v_request_id||':'||
                 to_char(sysdate, 'YYYYMMDDHH24MISS')||':'||
                 to_char(p_event_number, 'FM09');

  ------------------------------------------------
  -- log a pre-fire message                     --
  ------------------------------------------------
  if (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
       fnd_message.set_name('FND', 'BUSINESS_EVENT_ACTION');
       fnd_message.set_token('ACTION', 'PRE-FIRE');
       fnd_message.set_token('REQID', v_request_id);
       fnd_message.set_token('EVENT_NAME', p_event_name);
       fnd_log.message(fnd_log.level_event, 'fnd.plsql.fnd_concurrent_business_event.raise_cp_bi_event', TRUE);
  end if;

  ------------------------------------------------
  -- Raise an evnet     FIRE!                   --
  ------------------------------------------------
  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
       fnd_log.string(fnd_log.level_statement,'fnd.plsql.fnd_concurrent_business_event.raise_cp_bi_event',
                'called WF_EVENT.raise with '||
                 p_event_name||'  '||v_event_key||'  '||'v_params');
  end if;

  WF_EVENT.raise(p_event_name,
                 v_event_key,
                 NULL,
                 v_params,
                 NULL);

  ------------------------------------------------
  -- log a post-fire message                    --
  ------------------------------------------------
  if (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
       fnd_message.set_name('FND', 'BUSINESS_EVENT_ACTION');
       fnd_message.set_token('ACTION', 'POST-FIRE');
       fnd_message.set_token('REQID', v_request_id);
       fnd_message.set_token('EVENT_NAME', p_event_name);
       fnd_log.message(fnd_log.level_event, 'fnd.plsql.fnd_concurrent_business_event.raise_cp_bi_event', TRUE);
  end if;

end raise_wf_bi_event_1;


-------------------------------------------------------------------------
--   raise a business event
-------------------------------------------------------------------------
function raise_cp_bi_event(
  p_request_id         in number,
  p_event_number       in number,
  p_time_stamp 	       in date default null,
  p_status_code        in varchar2  default null)
  return number
is
  v_profile_bi_enable  		varchar2(2) := null;
  v_event_enabled 		varchar2(1) := null;
  v_event_map_info		varchar2(50) := null;
  v_tempcount			number := 0;
  v_tempstr			varchar2(1) := null;
  v_event_name			varchar2(100) := null;
  v_requested_by		number(15);
  v_program_application_id	number(15);
  v_concurrent_program_id	number(15);
  v_status_code			varchar2(30);
  v_time_stamp			date;
  v_completion_text		varchar2(240);


begin
  ---------------------------------------------------------
  -- if business event is not enabled, get out quickly   --
  -- Retrieve CONCURRENT: Business event enable profile  --
  -- if anything other than uppercase 'Y' then get out!  --
  ---------------------------------------------------------
  v_profile_bi_enable := fnd_profile.value('conc_bi_enable');
  if (v_profile_bi_enable <> 'Y') then
     return NFALSE;
  end if;

  ---------------------------------------------------------
  -- log a debug message to indicate parameters passed   --
  ---------------------------------------------------------
  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,'fnd.plsql.fnd_concurrent_business_event.raise_cp_bi_event',
               '--------DEBUG MESSAGE:  '||
               to_char(p_request_id,'FM999999999999999')||
               ' for '||
               to_char(p_event_number,'FM99'));
  end if;

  ---------------------------------------------------------
  -- Check for obvious errors                            --
  -- Exit false if necessary                             --
  ---------------------------------------------------------
  if (p_request_id IS null) then
     return NFALSE;
  end if;

  select count(*) into v_tempcount
  from fnd_concurrent_requests
  where request_id = p_request_id;

  if (v_tempcount <> 1) then
     return NFALSE;
  end if;

  if ((p_event_number < request_submitted) and
      (p_event_number > request_completed)) then
     return NFALSE;
  end if;

  ----------------------------------------------------------
  -- Find out if this event is enabled                    --
  ----------------------------------------------------------
  select program_application_id, concurrent_program_id
    into v_program_application_id, v_concurrent_program_id
    from fnd_concurrent_requests
   where request_id = p_request_id;

  select business_event_map into v_event_map_info
    from fnd_conc_prog_onsite_info
   where program_application_id = v_program_application_id
     and concurrent_program_id = v_concurrent_program_id;

  -- is 'Y' there at the right place for me?
  v_tempstr:=substr(v_event_map_info, p_event_number, 1);

  -----------------------------------------------------------------
  -- if profile is enabled (and it IS if you are here...)        --
  -- and the event is set to Y then                              --
  -- prep rest of the parameters and Fire!                       --
  -----------------------------------------------------------------
  if (v_tempstr='Y') then

      v_event_name := parse_event_name_from_number(p_event_number);

      select requested_by, program_application_id, concurrent_program_id, status_code, completion_text
        into v_requested_by, v_program_application_id, v_concurrent_program_id, v_status_code, v_completion_text
        from fnd_concurrent_requests
       where request_id = p_request_id;

      ---------------------------------------------------
      -- take care of nullable parameters              --
      ---------------------------------------------------
      if (p_time_stamp IS NULL) then         -- if time stamp was not passed in parameter,
           v_time_stamp := sysdate;            -- use current sysdate
      else
           v_time_stamp := p_time_stamp;
      end if;

      if (p_status_code is NOT NULL) then    -- passing status in parameter causes
           v_status_code := p_status_code;     -- completion status from table to be overridden
      end if;

      raise_wf_bi_event_1(p_event_number,
			v_event_name,
                        p_request_id,
                        v_requested_by,
                        v_program_application_id,
                        v_concurrent_program_id,
                        v_status_code,
			v_completion_text,
                        v_time_stamp);
    else
        return NFALSE;
    end if;
  return NTRUE;

---------------------------------------------------------------
-- exceptions handling                                       --
-- if any errors are encountered, simply return false and    --
-- don't propagage exceptions to the caller routine          --
---------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
     return NFALSE;

end raise_cp_bi_event;


--------------------------------------------------------------------
--  change_event                                                  --
--  update particular event for a particular program              --
--  this function performs COMMIT!                                --
--  for p_new_status see constants                                --
--------------------------------------------------------------------
function change_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number,
  p_new_status in varchar2)
  return number
is
  v_temp_count		number;
  v_current_state	varchar2(51);
  v_left_char		varchar2(51);
  v_right_char		varchar2(51);
  v_new_char		varchar2(51);

begin

  -- check for obvious errors
  select count(*)
   into v_temp_count
   from fnd_conc_prog_onsite_info
   where program_application_id = p_application_id
     and concurrent_program_id = p_concurrent_program_id;

  if (v_temp_count <> 1) then
     return(1);	-- error!
  end if;

  if ((p_event_number < 1) OR (p_event_number > 51)) then
     return(1); -- error!
  end if;

  -- read the current state of the events padded with Ns to make up 50 positions
  select RPAD(business_event_map, 50, 'N')
    into v_current_state
    from fnd_conc_prog_onsite_info
   where program_application_id = p_application_id
     and concurrent_program_id = p_concurrent_program_id;

  -- rpad doesn't work if data was null to begin with...
  if (v_current_state IS NULL) then
    v_current_state:='NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN';
  end if;

  -- splice in new stautus for a given position
  v_left_char := substr(v_current_state, 1, p_event_number - 1);
  v_right_char := substr(v_current_state, p_event_number + 1);

  v_new_char := concat(v_left_char, p_new_status);
  v_new_char := concat(v_new_char, v_right_char);

  -- update table with new status
  update fnd_conc_prog_onsite_info
    set business_event_map = v_new_char
  where program_application_id = p_application_id
    and  concurrent_program_id = p_concurrent_program_id;

  commit;

  return(0); -- success!

end change_event;


--------------------------------------------------------------
--  enable event                                            --
--  call change event to enable event                       --
--  this function performs COMMIT!                          --
--------------------------------------------------------------

function enable_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number)
  return number
is
  v_new_status	varchar2(1):='Y';
  v_result	number;

begin
   v_result:=change_event(p_application_id, p_concurrent_program_id, p_event_number, v_new_status);
   return v_result;

end enable_event;


--------------------------------------------------------------
--  disable event                                           --
--  call change event to enable event                       --
--  this function performs COMMIT!                          --
--------------------------------------------------------------

function disable_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number)
  return number
is
  v_new_status  varchar2(1):='N';
  v_result      number;

begin
   v_result:=change_event(p_application_id, p_concurrent_program_id, p_event_number, v_new_status);
   return v_result;

end disable_event;


end fnd_concurrent_business_event;

/
