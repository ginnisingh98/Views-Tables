--------------------------------------------------------
--  DDL for Package Body WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT" as
/* $Header: WFEVENTB.pls 120.12.12010000.7 2010/05/03 01:28:35 vshanmug ship $ */
--------------------------------------------------------------------------
/*
** PRIVATE global variables
*/

g_packName varchar2(30) :='wf.plsql.wf_event.';

/*
** Cache Variables
** pv_last_agent_name - the value of agent name
** pv_last_queue_name - the value of queue name, no schema information
** pv_last_schema_name - the value of schema name
** pv_last_recipients - the value of last recipients
*/
pv_last_agent_name  varchar2(30);
pv_last_queue_name  varchar2(80);
pv_last_schema_name varchar2(30);
pv_last_recipients  varchar2(30);
pv_last_dequeue_enabled varchar2(7);
procedure GetAgentDetails(agent_name in	varchar2);

java_sub varchar2(240) := 'java://';

NO_SAVEPOINT exception;				/* Bug 1840819 */
pragma EXCEPTION_INIT(NO_SAVEPOINT,-1086);

DISPATCH_ERROR exception;

  -- 7625944
  g_navResetThreshold number; -- threshold to reset navigation to FIRST_MESSAGE
                              -- (applicable to non-TRANSACTIONAL queue agent):
      -- when reached:
      -- null value => navigation variable not initialized, will assume default
      --               navigation (value=0)
      -- 0 (zero) value => default navigation, ie, navigate rest of queue messages
      -- value > 0 => limited navigation, ie, navigate messages until number of
      --              processed messages = g_navResetThreshold, then reset
      --              message counter and use FIRST_MESSAGE
  g_currentNavigation BINARY_INTEGER; -- cached value of queue navigation
  g_processedMessagesCount number :=0; -- count of number of dequeued messages
  g_groupDequeuing boolean := false; -- flag to mark that dequeueing is by group
                                     -- (TRANSACTIONAL), only to be used if
                                     -- message grouping is enabled for the agent

--Cursor to get the group members of one agent group.
--We assume that group members are of the same system as agent group.
CURSOR   agent_group_members(agent_name varchar2,system_name varchar2) is
  select agt2.name as agt_name,
         agt2.queue_handler as queue_handler
  from   wf_agent_groups agp ,
         wf_agents agt1 ,
         wf_agents agt2 ,
         wf_systems sys
  where  agt1.name      =  agent_name
  and    agt1.type      = 'GROUP'
  and    agt1.status    = 'ENABLED'
  and    agt1.system_guid = sys.guid
  and    sys.name        = system_name
  and    agp.group_guid =  agt1.guid
  and    agp.member_guid = agt2.guid
  and    agt2.system_guid = sys.guid
  and    agt2.status      = 'ENABLED';
--------------------------------------------------------------------------
/*
** setMessage (PRIVATE) - Generate the Message for this event
**                                if necessary
*/
PROCEDURE setMessage(p_event in out nocopy wf_event_t)
is
  msg   clob;
  func  varchar2(240);
  cmd   varchar2(1000);
  ename varchar2(240) := p_event.getEventName();
  ekey  varchar2(240) := p_event.getEventKey();
  eplist wf_parameter_list_t := p_event.getParameterList();
  executed boolean;
  -- Note that ORA-06550 is a generic PL/SQL compilation error
  -- Here it is most likely caused by "Wrong Number of Arguments".
  plsql_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(plsql_error, -06550);

  -- bes caching implementation
  l_event_obj wf_event_obj;
begin
  /*
  ** mjc We are now going to call this from the dispatcher
  **     if the subscription rule data is MESSAGE
  */
  --if (wf_event.test(ename) = 'MESSAGE') then

    l_event_obj := wf_bes_cache.GetEventByName(ename);

    if (l_event_obj is null) then
      wf_core.context('Wf_Event', 'setMessage', ename, ekey);
      wf_core.raise('WFE_EVENT_NOTEXIST');
    end if;

    func := l_event_obj.GENERATE_FUNCTION;

    if (func is not null) then

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string2(wf_log_pkg.level_statement,
                          'wf.plsql.wf_event.SetMessage.genfunc_callout',
                          'Start executing generate function - '||func, true);
      end if;

      WF_BES_DYN_FUNCS.Generate(func,
                                ename,
                                ekey,
                                eplist,
                                msg,
                                executed);
      if (not executed) then
         /** The Generate Function has been extended to support the passing
             of the parameter list as well. To make sure we are compatible
             with 2.6.0, we catch any error if there are too many parameters
             and try again with the old API signature (eventname, eventkey)
         **/
         -- func came from WF_EVENTS.GENERATE_FUNCTION
         -- BINDVAR_SCAN_IGNORE
         cmd := 'begin :v1 := '||func||'(:v2, :v3, :v4); end;';
         begin
           execute immediate cmd using in out msg, in ename, in ekey, in eplist;
         exception
           when plsql_error then
             -- BINDVAR_SCAN_IGNORE
             cmd := 'begin :v1 := '||func||'(:v2, :v3); end;';
             execute immediate cmd using in out msg, in ename, in ekey;
         end;
      end if;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string2(wf_log_pkg.level_statement,
                          'wf.plsql.wf_event.SetMessage.genfunc_callout',
                          'End executing generate function - '||func, false);
      end if;

    else
      cmd := '<default><event_name>'||ename||'</event_name><event_key>'||
              p_event.getEventKey()||'</event_key></default>';
      dbms_lob.createtemporary(msg, FALSE, DBMS_LOB.CALL);
      dbms_lob.write(msg, length(cmd), 1, cmd);
    end if;

    p_event.event_data := msg ;
    -- p_event.setEventData(msg);
  --end if;
exception
  when others then
    if (Wf_Core.Error_Name = 'WFE_EVENT_NOTEXIST') then
      raise;
    else
      wf_core.context('Wf_Event', 'setMessage', ename, ekey, func);
      WF_CORE.Token('ENAME', p_event.event_name);
      wf_core.token('FUNCTION_NAME', func);
      WF_CORE.Token('SQLCODE', to_char(sqlcode));
      WF_CORE.Token('SQLERRM', sqlerrm);
      WF_CORE.Raise('WFE_DISPATCH_GEN_ERR');
    end if;
end;
-----------------------------------------------------------------------
/*
** setErrorInfo - <described in WFEVENTS.pls>
*/
PROCEDURE setErrorInfo(p_event  in out nocopy wf_event_t,
                       p_type   in     varchar2)
is
  err_name  varchar2(30);
  err_msg   varchar2(2000);
  err_stack varchar2(2000);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.setErrorInfo.begin',
                      'Setting Error Info');
  end if;

  -- First look for a standard WF_CORE exception.
  wf_core.get_error(err_name, err_msg, err_stack, 2000);

  if (err_name is null) then
    -- If no WF_CORE exception, look for an Oracle error.
    err_name := to_char(sqlcode);
    err_msg := sqlerrm;
  end if;

  -- set error information into the event --
  p_event.setErrorMessage(err_msg);
  p_event.setErrorStack(err_stack);
  p_event.addParameterToList('ERROR_NAME', err_name);
  p_event.addParameterToList('ERROR_TYPE', p_type);
exception
  when others then
    wf_core.context('Wf_Event', 'setErrorInfo', p_event.getEventName());
    raise;
end;
-----------------------------------------------------------------------
/*
** saveErrorToQueue (PRIVATE) - Save the event to the WF_ERROR queue.
*/
PROCEDURE saveErrorToQueue(p_event in out nocopy wf_event_t)
is
  erragt    wf_agent_t;
  cmd       varchar2(1000);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.saveErrorToQueue.Begin',
                      'saving event to WF_ERROR on '|| wf_event.local_system_name);
  end if;

  erragt := wf_agent_t('WF_ERROR', wf_event.local_system_name);

  --
  -- mjc - lets just call the API directly
  --
  wf_error_qh.enqueue(p_event, erragt);

  --cmd := 'begin WF_ERROR_QH.enqueue(:v1, :v2); end;';
  --execute immediate cmd using in p_event,
  --                            in erragt;
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.saveErrorToQueue.End',
                      'error info saved');
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'saveErrorToQueue', p_event.getEventName());
    wf_core.token('FUNCTION_NAME', 'WF_ERROR_QH.enqueue()');
    --wf_core.raise('WF_EXT_FUNCTION');
   raise;
end;
--------------------------------------------------------------------------
-----------------------------------------------------------------------
/*
** saveErrorToJavaQueue (PRIVATE) - Save the event to the WF_JAVA_ERROR queue.
*/
PROCEDURE saveErrorToJavaQueue(p_event in out nocopy wf_event_t)
is
  erragt    wf_agent_t;
  cmd       varchar2(1000);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.saveErrorToJavaQueue.Begin',
                      'saving event to WF_JAVA_ERROR on '|| wf_event.local_system_name);
  end if;

  erragt := wf_agent_t('WF_JAVA_ERROR', wf_event.local_system_name);

  --
  -- mjc - lets just call the API directly
  --
  WF_EVENT_OJMSTEXT_QH.enqueue(p_event, erragt);

  --cmd := 'begin WF_ERROR_QH.enqueue(:v1, :v2); end;';
  --execute immediate cmd using in p_event,
  --                            in erragt;
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.saveErrorToJavaQueue.End',
                      'error info saved');
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'saveErrorToQueue', p_event.getEventName());
    wf_core.token('FUNCTION_NAME', 'WF_EVENT_OJMSTEXT_QH.enqueue()');
    --wf_core.raise('WF_EXT_FUNCTION');
   raise;
end;
--------------------------------------------------------------------------
/*
** isDeferToJava (PRIVATE)
*  returns true : if current subscription is Java or the event has a
*                 Java generate function or there exists a subsequent
*                 Java subscription when max threshold is reached
*  returns false: otherwise
*/
FUNCTION isDeferToJava(max_threshold_reached    in boolean,
                       p_event_name             in varchar2,
                       p_source_type            in varchar2,
                       p_rule_func              in varchar2,
                       p_rule_data              in varchar2,
                       p_phase                  in pls_integer)
return boolean
is
  -- bes caching implementation
  l_event_obj  wf_event_obj;
  l_subs_list  wf_event_subs_tab;
  l_java_defer boolean;
  l_java_gen   boolean;
  l_phase      number;
  l_rule_func  varchar2(240);
  l_rule_data  varchar2(8);
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.isDeferToJava.begin',
                      'Checking for Java subscription/generate');
  end if;

  if (p_rule_func is not null AND
      UPPER(substr(p_rule_func, 0, length(java_sub))) = UPPER(java_sub)) then
    -- this is a Java subscription. Return true
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.isDeferToJava.Subscription',
                        'found a Java subscription');
    end if;
    return true;
  end if;

  -- event should be in cache by now
  l_event_obj := wf_bes_cache.GetEventByName(p_event_name);

  if (l_event_obj is null) then
    return false;
  end if;

  -- set flag to true if java generate function is not null
  if (l_event_obj.JAVA_GENERATE_FUNC is not null) then
    l_java_gen := true;
  else
    l_java_gen := false;
  end if;

  -- Now Checking Generate Functions
  if (not max_threshold_reached)  then

    if (l_java_gen AND p_rule_data is not null AND
        p_rule_data = 'MESSAGE' and p_source_type = 'LOCAL') then
      -- this is a Java generate function.
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.isDeferToJava.Subscription',
                        'found a Java generate function');
      end if;
      return true;
    else
      return false;
    end if;
  else

    -- we have event and subscription list from the cache
    -- o if a subsequent subscription has a java rule func
    -- o if the event has a java generate function and a subsequent
    --   subscription has MESSAGE rule data

    l_java_defer := false;
    l_subs_list := wf_bes_cache.GetSubscriptions(p_event_name, p_source_type, null);

    if (l_subs_list is not null) then
      for i in 1..l_subs_list.COUNT loop
        l_phase := l_subs_list(i).PHASE;
        l_rule_func := l_subs_list(i).RULE_FUNCTION;
        l_rule_data := l_subs_list(i).RULE_DATA;

	if ((l_phase is null OR l_phase > p_phase) AND
             ((l_rule_data = 'MESSAGE' AND l_java_gen) OR
	      (UPPER(substr(l_rule_func, 0, length(java_sub))) = UPPER(java_sub)))) then
          l_java_defer := true;
          exit;
        end if;

      end loop;
    end if;

    if(l_java_defer) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.isDeferToJava.Subscription',
                        'found subsequent Java sub or java generate');
      end if;
      return true;
    else
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.isDeferToJava.Subscription',
                        'No Java sub found or Java Generate Found');
      end if;
      return false;
    end if;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.isDeferToJava.end',
                      'Checked for Java subscription/generate');
  end if;

  return false;
exception
  when others then
    wf_core.context('Wf_Event', 'isDeferToJava', p_event_name);
    raise;
end isDeferToJava;

--------------------------------------------------------------------------
/*
** isSaveToJavaError (PRIVATE)
*  returns true : if current subscription is Java and source type is ERROR
*                 save to Java Error
*  returns false: otherwise
*/
FUNCTION isSaveToJavaError(p_event_name             in varchar2,
                           p_rule_func              in varchar2)
return boolean is

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.isSaveToJavaError.begin',
                      'Checking Java Error subscription for ' || p_event_name);
  end if;

  if (p_rule_func is not null AND
      UPPER(substr(p_rule_func, 0, length(java_sub))) = UPPER(java_sub)) then
    -- this is a Java subscription. Return true
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.isSaveToJavaError.Subscription',
                        'found a Java subscription');
    end if;
    return true;
  end if;
  return false;
end isSaveToJavaError;
/*
** GetSkippedSub - utility function to get the subscription has skip onerror
**                  type
*/
function GetSkippedSub(p_event in wf_event_t)
         return RAW is
    l_skip_sub_str VARCHAR2(300);
begin
    l_skip_sub_str := p_event.GETVALUEFORPARAMETER('SKIP_ERROR_SUB');
    if (l_skip_sub_str is not null) then
        return hextoraw(l_skip_sub_str);
    end if;
    return null;
end GetSkippedSub;

------------------------------------------------------------------------
/*
** dispatch_internal (PRIVATE)
*/
FUNCTION dispatch_internal(p_source_type        in  varchar2,
                           p_rule_data          in  varchar2,
                           p_rule_func          in  varchar2,
                           p_sub_guid           in  raw,
                           p_source_agent_guid  in  raw,
                           p_phase              in  number,
                           p_priority           in  number,
                           p_event              in out nocopy wf_event_t,
                           p_on_error           in  varchar2)
return varchar2
is
  res                   varchar2(20);
  cmd                   varchar2(1000);
  stat                  varchar2(10);
  myfunc                varchar2(240);
  saved                 boolean := FALSE;
  eguid                 raw(16);
  defagent              wf_agent_t;
  subphase              number;
  genmsg                boolean := FALSE;
  max_threshold_reached boolean := FALSE;
  defer_to_java       boolean := FALSE;
  save_to_java_error    boolean := FALSE;
  l_skip_sub            raw(16);
  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  empty_lob_locator    exception;
  pragma exception_init (empty_lob_locator, -22275);
  msg                   clob;
  -- Bug2786192
  l_rule_func           VARCHAR2(240);
  executed              boolean;
begin
    -- Verify if the subscription is eligible for execution.
    if ((wf_event.local_system_status = 'ENABLED'
	OR wf_event.local_system_status = p_source_type)
    	OR (wf_event.local_system_status <> 'DISABLED'
		AND p_source_type = 'ERROR'))
        AND (p_phase >= wf_event.phase_minthreshold) then

      --Bug 2519183
      --If we are in the deferred processing of an
      --event we will set back the minthreshold so that its
      --possible to raise active events within this subscription.
      --This is after all processed subscriptions have been
      --discarded hence its fine to set the phase_minthreshold
      --to zero.

        if ((wf_event.phase_minthreshold > 0) AND
            (p_event.from_agent is NOT NULL)) then
             --Bug 3451981
             --In the case of EXTERNAL events the from_agent will
             --not be WF_DEFERRED , in this case no further event
             --executions are possible with any lower phases
             --(though logically there is No DEFERRED within DEFERRED
             --and correspondingly here phase of > 100 or not works the
             --same way so u can always workaround with higher phases
             --but not good on design)
             --So we can possibly check if it is 'EXTERNAL'
             --and as we know from the check of min_threshold
             --that we are deferprocessing lets re-set it.
             if ((p_event.from_agent.getName = 'WF_DEFERRED') OR (p_source_type = 'EXTERNAL')) then
              wf_event.phase_minthreshold := 0;
             end if ;
        end if;

      --
      -- mjc  Check if reached the phase threshold and should defer
      --      If we have encountered a deferred subscription, we will
      --      get the hell out of Dodge City (aka exiting the loop)
      --      We should not defer any messages being processed from
      --      the deferred queue.
      --
      -- YOHUANG Bug 4227307
      -- Error Subscription should never be deferred.
      if (wf_event.phase_maxthreshold is not null) AND
         (p_phase >= wf_event.phase_maxthreshold) AND
         (p_source_type <> 'ERROR')
      then
        if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.Subscription',
                            'max threshold reached');
        end if;
        max_threshold_reached := true;
      end if;

       -- check if event needs to be deferred to WF_JAVA_DEFERRED queue
      if (p_source_type <> 'ERROR') then
        defer_to_java := isDeferToJava(max_threshold_reached,
                                       p_event.getEventName(),
                                       p_source_type, p_rule_func,
                                       p_rule_data,p_phase);
      else
        save_to_java_error := isSaveToJavaError(p_event.getEventName(),
                                                p_rule_func);
      end if;

      if(defer_to_java OR max_threshold_reached ) then
        if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.Subscription',
                            'detected as deferred');
        end if;
        --
        -- mjc Set action priority now, if we defer, this can be used
        --     as the priority of the dequeue off the deferred queue
        --
        p_event.priority := p_priority;

        -- Set the Deferred Subscription into the event
        -- We will use this to figure out which phase we will start
        -- off with during deferred processing
        p_event.error_subscription := p_sub_guid;

	-- set #CURRENT_PHASE  <<sstomar : bug 5870400 >>
	-- When Last Subscription GUID exist in Event payload but that Subscription
	-- is not Active/Enabled now. So in such case, Agent Processor doesn't know
	-- what phase value it should set for Dispatcher to start subscription processing
	-- (i.e. from which subscription).
	-- So in such case, Value of #CURRENT_PHASE will be used as starting phase.
	p_event.AddParameterToList('#CURRENT_PHASE', p_phase);

        if(defer_to_java) then
          if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.Subscription',
                            'deferring to WF_JAVA_DEFERRED');
          end if;
          wf_event.DeferEventToJava(p_source_type, p_event);
        else
          if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.Subscription',
                             'deferring to WF_DEFERRED');
          end if;
          wf_event.deferevent(p_source_type, p_event);
        end if;
        res := 'DEFER';

      elsif (save_to_java_error) then
        if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.Subscription',
                            'save to java error queue');
        end if;
        p_event.error_subscription := p_sub_guid;
        wf_event.saveErrorToJavaQueue(p_event);
        res := 'DEFER';
      else
        -- Generate Method is irrelavant to subscription.
        -- Exception happened in Generate Method should be thrown
        -- up.
        --
        -- mjc Check if we are required to Generate Message
        --     Use dbms_lob.istemporary to see if any clob
        --
        begin
          if (NOT genmsg) AND
          (p_rule_data = 'MESSAGE') AND
          (p_source_type = 'LOCAL') then
            if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
               wf_log_pkg.string(wf_log_pkg.level_statement,
                                'wf.plsql.WF_EVENT.dispatch_internal.Rule_Data',
                                'Rule Data is MESSAGE and Source is LOCAL');
            end if;
            -- if dbms_lob.istemporary(p_event.GetEventData()) = 0 then
            -- Bug Fix for 4286207
            begin
              if (p_event.GetEventData() is null) or
                 (p_event.GetEventData() is not null and dbms_lob.getlength(p_event.GetEventData()) = 0) then
                if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                   wf_log_pkg.string(wf_log_pkg.level_statement,
                                    'wf.plsql.WF_EVENT.dispatch_internal.generate',
                                    'Need to Generate Message');
                end if;
                wf_event.setMessage(p_event);
                genmsg := TRUE;
              end if;
            exception
              when empty_lob_locator then
                -- The lob locator is invalid, probably pointing to a empty_clob();
                if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                   wf_log_pkg.string(wf_log_pkg.level_statement,
                                    'wf.plsql.WF_EVENT.dispatch_internal.generate',
                                    'Invalid Lob Locator Passed, Generate the Message');
                end if;
                wf_event.setMessage(p_event);
                genmsg := TRUE;
            end;
          end if;
        exception
          when others then
            rollback to wf_dispatch_savepoint;
            p_event.setErrorSubscription(p_sub_guid);
            wf_event.wf_exception_source := 'RULE';
            raise;
        end;

        --If we came here now we can start processing the
        --subscription
        --Set the savepoint here for the SKIP mode and not for error
        --subscriptions
        if (p_on_error = 'SKIP' and p_source_type <> 'ERROR') then
          -- trig_savepoint shall not happen otherwise
          -- the event level savepoint can't be created.
          savepoint wf_dispatch_internal;
        end if;

        -- If we are in the process of only executing the skipped
        -- subscription, we should remove this parameter because
        -- otherwise there will be indefinite loop in case of
        -- nested raise.
        l_skip_sub := GetSkippedSub(p_event);

        if (l_skip_sub is not null AND
            p_source_type = 'LOCAL') then
          p_event.AddParameterToList('SKIP_ERROR_SUB', null);
        end if;

        --
        -- If there's a rule function defined, run it.  Otherwise
        -- just execute the default dispatch functionality
        --
        begin

          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string2(wf_log_pkg.level_statement,
                              'wf.plsql.wf_event.dispatch_internal.rulefunc_callout',
                              'Start executing rule function - '||p_rule_func, true);
          end if;

          if (p_rule_func is not null) then
            WF_BES_DYN_FUNCS.RuleFunction(p_rule_func,
                                          p_sub_guid,
                                          p_event,
                                          res,
                                          executed);
            if (not executed) then
                -- p_rule_func came from WF_EVENT_SUBSCRIPTIONS.Rule_Function or
                -- WF_EVENT_SUBSCRIPTIONS.Java_Rule_Func
                myfunc := p_rule_func;
                -- BINDVAR_SCAN_IGNORE
                cmd := 'begin :v1 := '||myfunc||'(:v2, :v3); end;';
                execute immediate cmd using in out res,
                                            in     p_sub_guid,
                                            in out p_event;
            end if;
          end if;

          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string2(wf_log_pkg.level_statement,
                              'wf.plsql.wf_event.dispatch_internal.rulefunc_callout',
                              'End executing rule function - '||p_rule_func, false);
          end if;

        exception
          when others then
            if (p_on_error = 'SKIP') then
              -- Unexpected Exception is treated the same as ERROR
              -- if the subscription is marked as SKIP
              res := 'ERROR';
            else
              rollback to wf_dispatch_savepoint;
              p_event.setErrorSubscription(p_sub_guid);
              p_event.addParameterToList('ERROR_TYPE', 'UNEXPECTED');
              wf_event.wf_exception_source := 'RULE';
              WF_CORE.Token('ENAME', p_event.event_name);
              WF_CORE.Token('EKEY', p_event.event_key);
              WF_CORE.Token('RULE',  myfunc);
              WF_CORE.Token('SQLCODE', to_char(sqlcode));
              WF_CORE.Token('SQLERRM', sqlerrm);
              WF_CORE.Raise('WFE_DISPATCH_RULE_ERR');
            end if;

        end;

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           -- BINDVAR_SCAN_IGNORE[3]
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.dispatch_internal.rule_function',
                            'Executed Rule Function '||myfunc||' and returned '||res);
        end if;

      end if; -- End of "defer_to_java OR max_threshold_reached"
    else
      -- Bug 4227307
      -- Handle the subscriptions that are not eligible for execution.
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.wf_event.dispatch_internal.subs_ignore',
                          'Subscription not executed. Sub Phase='||p_phase||
                          ', Min threshold='||wf_event.phase_minthreshold);
      end if;
      return 'SUCCESS';
    end if;

    if (res = 'DEFER' OR res = 'SUCCESS') then
      return res;
    end if;

    p_event.addParameterToList('ERROR_TYPE', res);
    p_event.setErrorSubscription(p_sub_guid);

    if (p_source_type = 'ERROR') then
      -- If subscription returns error when listener listens on error agent.
      -- Bug 4207885: Set the exception source to Rule when
      -- Raising exceptions.
      wf_event.wf_exception_source := 'RULE';
      wf_core.token('ENAME', p_event.event_name);
      wf_core.token('EKEY', p_event.event_key);
      wf_core.token('SQLERRM', null);
      wf_core.token('SQLCODE', null);
      wf_core.raise('WFE_DISPATCH_RULE_ERR');
    end if;

    if (res = 'ERROR') then

        if (WF_EVENT.g_message_grouping = 'TRANSACTIONAL') then
          raise dispatch_error;
        end if;

        begin
          if (p_on_error = 'SKIP' and p_source_type <> 'ERROR') then
            rollback to wf_dispatch_internal;
            p_event.AddParameterToList('SKIP_ERROR_SUB', rawtohex(p_sub_guid));
            res := 'SKIP_ERROR';
          else
           rollback to wf_dispatch_savepoint;
          end if;
        exception
           when NO_SAVEPOINT then
           -- Bug 1840819
           -- Catch the no savepoint exception incase commit has happened.
           -- In this case, the subsequent subscriptions can't be executed
           -- because is savepoint no longer valid.
           wf_core.token('EVENT',p_event.getEventName());
           p_event.setErrorMessage(wf_core.substitute('WFERR',
                                                   'WFE_COMMIT_IN_DISPATCH'));
           res := 'TRANSACTION_COMMITED';
        end;
    end if;


    wf_event.saveErrorToQueue(p_event);
    p_event.AddParameterToList('SKIP_ERROR_SUB', null);
    return (res);

exception
  when others then
    wf_core.context('Wf_Event', 'dispatch_internal');
    raise;
end;
---------------------------------------------------------------------------
/*
** newAgent - <described in WFEVENTS.pls>
*/
FUNCTION newAgent(p_agent_guid in raw) return wf_agent_t
is
  agt_name varchar2(30);
  sys_name varchar2(30);

  -- wf bes cache implementation
  l_agent_obj wf_agent_obj;
begin
  if (p_agent_guid is null) then
    return null;
  end if;

  l_agent_obj := wf_bes_cache.GetAgentByGUID(p_agent_guid);

  if (l_agent_obj is not null) then
    return wf_agent_t(l_agent_obj.NAME, l_agent_obj.SYSTEM_NAME);
  else
    wf_core.raise('WFE_AGENT_NOTEXIST');
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'newAgent', p_agent_guid);
    raise;
end;
---------------------------------------------------------------------------
/*
** test - <Described in WFEVENTS.pls>
*/
FUNCTION test(p_event_name in varchar2) return varchar2
is
  event_guid raw(16);
  result     varchar2(10) := 'NONE';

  -- bes caching implementation
  l_event_obj wf_event_obj;
  l_subs_list wf_event_subs_tab;

begin

  l_event_obj := wf_bes_cache.GetEventByName(p_event_name);

  -- if event is not found or no subscriptions to the event, return NONE
  result := 'NONE';
  if (l_event_obj is not null) then
    l_subs_list := wf_bes_cache.GetSubscriptions(p_event_name, 'LOCAL', null);

    if (l_subs_list is not null) then
      result := 'KEY';
      for i in 1..l_subs_list.COUNT loop
        if (l_subs_list(i).RULE_DATA = 'MESSAGE') then
          result := 'MESSAGE';
          exit;
        end if;
      end loop;
    end if;
  end if;
  return result;

exception
  when others then
    wf_core.context('Wf_Event', 'Test', p_event_name);
    raise;
end;
---------------------------------------------------------------------------
/*
** send - <Described in WFEVENTS.pls>
*/
PROCEDURE send(p_event in out nocopy wf_event_t) is
  outguid    WF_AGENTS.GUID%TYPE;
  toagtname  WF_AGENTS.NAME%TYPE;
  toagtsys   WF_SYSTEMS.NAME%TYPE;
  outagtname WF_AGENTS.NAME%TYPE;
  outagtsys  WF_SYSTEMS.NAME%TYPE;
  l_to_type  WF_AGENTS.TYPE%TYPE;
  -- l_mem_agt_name WF_AGENTS.NAME%TYPE;
  l_to_queue_handler WF_AGENTS.QUEUE_HANDLER%TYPE;

  -- wf bes cache implementation
  l_to_agt_obj  wf_agent_obj;
  l_out_agt_obj wf_agent_obj;
begin
  --
  -- if from_agent is null, pick one from the local system that uses
  -- the same queue handler (i.e.: same event type)
  --
  -- Note: someday, when we support agent groups, we'd loop through
  --       the group members and derive a list of proper out agents.
  --
  if (p_event.GetToAgent() is null AND p_event.GetFromAgent() is null) then
    -- Either source or destination must be defined.
    -- Raise Error.
    wf_core.context('Wf_Event', 'Send', p_event.getEventName());
    wf_core.raise('Either source or destination must be defined.'); -- wfsql.msg
  end if;

  if p_event.GetToAgent() is not null then
    toagtname := p_event.getToAgent().getName();
    toagtsys  := p_event.getToAgent().getSystem();
  end if;

  if p_event.GetFromAgent() is not null then
    outagtname := p_event.getFromAgent().getName();
    outagtsys  := p_event.getFromAgent().getSystem();
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.Send.info',
                      'To Agt: '||toagtname||' To Agt Sys:'||toagtsys||
                      'Out Agt: '||outagtname||' Out Agt Sys:'||outagtsys);
  end if;

  -- enqueue() requires that FromAgent not null.
  -- pick one from the local system that uses the same queue handler (i.e.: same event type)
  -- as toAgent uses.
  -- If the toAgent is an agent group, we assume that agent group
  -- only contain one type of agents.
  if (p_event.getFromAgent() is null OR
      p_event.getFromAgent().getName() is null OR
      p_event.getFromAgent().getSystem() is null) then

    l_to_agt_obj := wf_bes_cache.GetAgentByName(toagtname, toagtsys);
    if (l_to_agt_obj is not null and l_to_agt_obj.STATUS = 'ENABLED') then
      l_to_type := l_to_agt_obj.TYPE;
      l_to_queue_handler := l_to_agt_obj.QUEUE_HANDLER;
    else
      raise no_data_found;
    end if;

    IF (l_to_type = 'GROUP') THEN
        l_to_queue_handler := NULL;
        for r_group_members in agent_group_members(toagtname, toagtsys) loop
          l_to_queue_handler := r_group_members.queue_handler;
          exit;
        end loop;
        if (l_to_queue_handler = null) then
          raise no_data_found;
        end if;
    END IF;

    l_out_agt_obj := wf_bes_cache.GetAgentByQH(l_to_queue_handler, 'OUT');

    if (l_out_agt_obj is not null and l_out_agt_obj.STATUS = 'ENABLED') then
      outguid := l_out_agt_obj.GUID;
      outagtname := l_out_agt_obj.NAME;
    else
      raise no_data_found;
    end if;

    p_event.setFromAgent(wf_event.newAgent(outguid));
  end if;

  if (p_event.getSendDate() is NULL) then
    p_event.setSendDate(sysdate);
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.send.enqueue',
                      'Sending from '||outagtname||' to '||toagtname);
  end if;

  wf_event.enqueue(p_event);
exception
  when no_data_found then
    wf_core.context('Wf_Event', 'Send', p_event.getEventName());
    wf_core.token('AGENT', toagtname);
    wf_core.raise('WFE_AGENT_NOMATCH');
  when others then
    wf_core.context('Wf_Event', 'Send', p_event.getEventName());
    raise;
end;
---------------------------------------------------------------------------
/*
** Given out agent and to agent info,
** Figure out the recipient address.
** PRIVATE: Only called by Set_Recipient_List.
** Assumption: There will be no group under group, so the to agent
**             passed here must have type AGENT.
*/
FUNCTION Get_Recipient(p_out_agent_name in varchar2,
                       p_out_system_name in varchar2,
                       p_to_agent_name  in varchar2,
                       p_to_system_name in varchar2,
                       p_out_queue_handler in varchar2)
         return sys.aq$_agent is
    l_to_address         WF_AGENTS.ADDRESS%TYPE;
    l_to_protocol        WF_AGENTS.PROTOCOL%TYPE;
    l_to_queue_name      WF_AGENTS.QUEUE_NAME%TYPE;
    l_to_protocol_number NUMBER := 0; -- Hard code as SQLNET

    -- wf bes cache implementation
    l_to_agt_obj wf_agent_obj;
BEGIN

    -- MJC: We need to make sure the recipient address is in the correct
    -- format otherwise dequeue will not work.
    --
    -- Rule 1: Local consumer dequeues from same queue as enqueued
    --   --> Address must be null
    -- Rule 2: Propagating to local queue
    --   --> Address must be <schema>.<queue_name>
    -- Rule 3: Propagating to local database
    --   --> Address must be <schema>.<queue_name>@dblink

    -- YOHUANG: Different Sql queries for different case to
    --          improve performance.

    l_to_agt_obj := wf_bes_cache.GetAgentByName(p_to_agent_name, p_to_system_name);
    if (l_to_agt_obj is not null and l_to_agt_obj.STATUS = 'ENABLED') then
      l_to_protocol := l_to_agt_obj.PROTOCOL;
      l_to_queue_name := l_to_agt_obj.QUEUE_NAME;
    else
      return null;
    end if;

    if (p_to_agent_name = p_out_agent_name and
         p_to_system_name = p_out_system_name) then
      l_to_address := null;
    elsif (p_to_agent_name <> p_out_agent_name and
             p_to_system_name = p_out_system_name) then
      l_to_address := l_to_queue_name;
    -- Bug 7671184 - If message is intended for a remote system use
    -- the address of To Agent as To Address for msg propagation
    elsif (p_to_system_name <> p_out_system_name) then
      l_to_address := l_to_agt_obj.ADDRESS;
    end if;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT.Get_Recipient',
                          'Recipient is name: ' || p_to_agent_name ||
                          ' address: ' || l_to_address || ' protocol: ' ||l_to_protocol);
    end if;

    --  Here is where we will add additional protocol mappings as AQ
    --  supports new protocols.  This bit will form a hardcoded mapping
    --  from protocol names as used in the event manager and the
    --  protocol numbers used by AQ.

    if((l_to_protocol is null) or (l_to_protocol not in ('SQLNET'))) then
       wf_core.context('WF_EVENT', 'Get_Recipient', 'Bad Protocol',
          l_to_protocol, l_to_queue_name);
    end if;

    return sys.aq$_agent(p_to_agent_name,
                         l_to_address,
                         l_to_protocol_number);
exception
    WHEN no_data_found THEN
        -- It means that to agent and out agent are not of same type
        RETURN null;
end Get_Recipient;

/*
** If the ToAgent of event is not null(send), set the recipient list
** address.
** Only be called if the event.getToAgent() is not null.
*/
PROCEDURE Set_Recipient_List(p_event               in wf_event_t,
                             p_out_agent_name     in varchar2,
                             p_out_system_name    in varchar2,
                             x_message_properties in out nocopy dbms_aq.message_properties_t) IS
    l_to_type            WF_AGENTS.TYPE%TYPE;
    l_to_agent_name      WF_AGENTS.NAME%TYPE;
    l_to_system_name     WF_SYSTEMS.NAME%TYPE;
    l_out_queue_handler  WF_AGENTS.QUEUE_HANDLER%TYPE;
    l_recipient_agent    sys.aq$_agent;
    --Bug 2676549
    i    number := 0;

    -- bes cache implementation
    l_to_agt_obj   wf_agent_obj;
    l_out_agt_obj  wf_agent_obj;
BEGIN

    -- Ignore if to agent is not set or the out agent is DEFERRED.
    if ((p_event.getToAgent() is null) or (p_out_agent_name = 'WF_DEFERRED')) then
      return;
    end if;

    -- if there is a to queue, we need to set the recipient list address
    l_to_agent_name := p_event.getToAgent().getName();
    l_to_system_name := p_event.getToAgent().getSystem();

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT.setRecieptList',
                          'Setting Recipient List: ' || l_to_agent_name);
    end if;

    l_to_agt_obj := wf_bes_cache.GetAgentByName(l_to_agent_name, l_to_system_name);
    if (l_to_agt_obj is not null and l_to_agt_obj.STATUS = 'ENABLED') then
      l_to_type := l_to_agt_obj.TYPE;
    else
      raise no_data_found;
    end if;

    l_out_agt_obj := wf_bes_cache.GetAgentByName(p_out_agent_name, p_out_system_name);
    if (l_out_agt_obj is not null and l_out_agt_obj.STATUS = 'ENABLED') then
      l_out_queue_handler := l_out_agt_obj.QUEUE_HANDLER;
    else
      raise no_data_found;
    end if;

    if (l_to_type = 'GROUP') then
        --Get the agent / agent group from the cursor
        for to_agent in agent_group_members(l_to_agent_name,l_to_system_name) loop
            l_recipient_agent := Get_Recipient(p_out_agent_name,
                                               p_out_system_name,
                                               to_agent.agt_name,
                                               l_to_system_name,
                                               l_out_queue_handler);
            if (l_recipient_agent IS NOT NULL) then
                i:= i + 1;
                x_message_properties.recipient_list(i) := l_recipient_agent;
            end if;
        end loop;
        if (i = 0) then
            -- There is no qualified agents under this agent group
            raise no_data_found;
        end if;
   else
      l_recipient_agent := Get_Recipient(p_out_agent_name,
                                         p_out_system_name,
                                         l_to_agent_name,
                                         l_to_system_name,
                                         l_out_queue_handler);
      if (l_recipient_agent IS NOT NULL) then
        x_message_properties.recipient_list(1) := l_recipient_agent;
      else
        -- No qualified agent
        raise no_data_found;
      end if;
   end if ;

END Set_Recipient_List;



/*
** raise - <Described in WFEVENTS.pls>
*/
PROCEDURE raise(p_event_name in varchar2,
                p_event_key  in varchar2,
                p_event_data in clob,
                p_parameters in wf_parameter_list_t,
		p_send_date  in date) is


l_parameters  wf_parameter_list_t;

begin
  --If parameter list is null then raise the event
  --with a dummy parameter list as raise3 requires
  --the parameterlist to be input.Else use the input
  --parameter list.
  if (p_parameters is NOT NULL) then
     l_parameters := p_parameters;
  else
     l_parameters := wf_parameter_list_t();
  end if;
  --Raise the event
  wf_event.raise3(p_event_name,
                  p_event_key,
                  p_event_data,
                  l_parameters,
                  p_send_date);
exception
  when others then
    raise;
end;
---------------------------------------------------------------------------
/*
** listen - <Described in WFEVENTS.pls>
*/
PROCEDURE listen(p_agent_name  in varchar2,
                 p_wait        in binary_integer,
                 p_correlation in varchar2,
                 p_deq_condition in varchar2) is

  l_msg_count NUMBER := 0;
  l_err_count NUMBER := 0;
begin

  listen(p_agent_name,
         p_wait,
         p_correlation,
         p_deq_condition,
         l_msg_count,
         l_err_count);

end;
/*
** listen - <Described in WFEVENTS.pls>
*/
PROCEDURE listen(p_agent_name  in varchar2,
                 p_wait        in binary_integer,
                 p_correlation in varchar2,
                 p_deq_condition in varchar2,
                 p_message_count in out nocopy number,
                 p_max_error_count in out nocopy number) is

  from_agt_name  varchar2(30);
  from_agt_sys   varchar2(30);
  st   varchar2(10) := 'LOCAL';
  dir  varchar2(10);
  qh   varchar2(240);
  stat varchar2(10);
  agt  raw(16);
  sagt raw(16);
  evt  wf_event_t;
  evt_name	VARCHAR2(240);
  evt_errmsg	VARCHAR2(4000);
  -- Local Variable, reset everytime the method is called.
  l_lsn_msg_count NUMBER := 0;
  l_error_count   NUMBER := 0;

  l_queue_name       varchar2(80);
  q_name             VARCHAR2(80);
  l_enqueue_enabled  VARCHAR2(30);
  l_dequeue_enabled  VARCHAR2(30);
  l_queueTable       VARCHAR2(30);

  -- bes caching implementation
  l_agent_obj  wf_agent_obj;

begin

  -- return an error if listen is invoked on WF_JAVA_DEFERRED or
  -- WF_JAVA_ERROR agents
  if (p_agent_name = 'WF_JAVA_DEFERRED') OR
     (p_agent_name = 'WF_JAVA_ERROR') then
    return;
  end if;

  -- Validate the msg count and error count parameters
  if (p_message_count is null or p_message_count < 0) then
    p_message_count := 0;
  end if;

  if (p_max_error_count is null or p_max_error_count < 0) then
    p_max_error_count := 0;
  end if;

  if ((p_correlation is not NULL) and (p_deq_condition is not NULL)) then
    WF_CORE.Context('WF_EVENT', 'Listen', p_agent_name, p_correlation,
                     p_deq_condition);
    WF_CORE.Raise('WFE_CORRID_VS_CONDITION');

  end if;

  -- lookup agent info --
  --<rwunderl:2749563> Tuned and separated sql statement for better performance
  --<rwunderl:2792298> restricting Listen() to local system.
  if (WF_EVENT.g_local_system_guid is NULL) then
    g_local_system_guid := hextoraw(WF_CORE.Translate('WF_SYSTEM_GUID'));
  end if;

  -- get the agent information for the local system
  l_agent_obj := wf_bes_cache.GetAgentByName(p_agent_name, null);
  if (l_agent_obj is not null) then
    agt := l_agent_obj.GUID;
    dir := upper(l_agent_obj.DIRECTION);
  else
    raise no_data_found;
  end if;

  -- Bug 2307433, 3271311, Use StartAgent as single Source of truth
  -- StartAgent becomes the single source to start a particular agent
  -- and can be called without worrying about fixed name queues.
  StartAgent(p_agent_name);

  -- set default parameters for queue navigation if not previously set
  if (g_navResetThreshold is null) then
    wf_event.setNavigationParams(p_agent_name, 0);
  end if;

    if (WF_EVENT.g_message_grouping = 'TRANSACTIONAL') then
      if ((p_correlation is NULL) and (p_deq_condition is NULL)) then
        --This is a transactional queue, we will go ahead and call
        --the proper api.
        WF_EVENT.Listen_GRP(p_agent_name, p_wait);
        return;

       else
         --This is a transactional queue, but since there was a correlation id
         --passed, we cannot call Listen_GRP, so we will raise an error to the
         --caller to resolve.
         wf_core.context('Wf_Event', 'Listen', p_agent_name);
         wf_core.token('AGENT', p_agent_name);
         wf_core.token('API', 'WF_EVENT.Listen_GRP');
         wf_core.raise('WFE_TRXN_QUEUE');

        end if;
    end if;

  -- set source type --
  if (p_agent_name = 'WF_ERROR') then
    st := 'ERROR';
  elsif (dir = 'IN') then
    st := 'EXTERNAL';
  end if;

  -- check system status
  -- stat := wf_core.translate('WF_SYSTEM_STATUS');
  -- Set the account name - only need this for WF_DEFERRED
  wf_event.SetAccountName;

  if (wf_event.local_system_status = 'DISABLED') then
    return;
  end if;

  if (wf_event.local_system_status in ('LOCAL','EXTERNAL')) then
    if (st = wf_event.local_system_status
	OR st = 'ERROR'
	OR p_agent_name = 'WF_DEFERRED') then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT.listen.Check1',
                          'Source type is equal to system status '||
                          'or ERROR or Deferred Processing');
      end if;
    else
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_EVENT.listen.Check2',
                           'Source type not valid for current system status');
      end if;
      return;
    end if;
  end if;

  -- bug 7828862 Cache apps context before dispatching events
  wfa_sec.Cache_Ctx();

  -- We need to explicitly make sure that if someones Queue Handler
  -- blows up we rollback the transaction, just in case they don't
  begin
    savepoint bes_before_dequeue_qh;
    wf_event.dequeue(agt, evt, qh, p_wait, p_correlation, p_deq_condition);

  exception
    when others then
      wf_event.wf_exception_source := 'QH';
      rollback to bes_before_dequeue_qh;
      raise;
   end;

  -- Add support MAX_LSN_MSG_COUNT and MAX_ERROR_COUNT
  -- to mimic JAVA GSC Framework implementation
  -- Listen will return back to caller if either MAX NUMBER
  -- of messages are read or max number of errors happened.
  while (evt is not null) loop

    l_lsn_msg_count := l_lsn_msg_count + 1;
    if (st <> 'ERROR') then
       if (evt.getFromAgent() is null) then
         sagt := NULL;
       else
         from_agt_name := evt.getFromAgent().getName();
         from_agt_sys  := evt.getFromAgent().getSystem();

         if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                             'wf.plsql.WF_EVENT.listen',
                             'Event '||evt.getEventName()||
                             ', hailing from '||from_agt_name||'@'||from_agt_sys||
                             ' was dequeued from '||p_agent_name);
         end if;
         -- get the from agent guid
         GetSourceAgentGUID(agent_name   => from_agt_name,
                            agent_system => from_agt_sys,
                            agent_guid   => sagt);
       end if;
    else
      sagt := NULL;

      -- Bug 2032654
      -- 1. Determine if the event name is null
      -- 2. If the event name is NULL, it should be defaulted to UNEXPECTED_ERROR.
      -- 3. The text Event Name is NULL is appended to the error message.
      evt_name := evt.getEventName;

      IF evt_name IS NULL THEN
	 evt.setEventName('UNEXPECTED_ERROR');
	 evt.setEventKey('UNEXPERR');
	 evt_errmsg := evt.getErrorMessage || wf_core.newline ||
					wf_core.translate('WF_EVTNAME_NULL');
	 evt.setErrorMessage(wf_core.translate('WF_EVTNAME_NULL'));
      END IF;
    end if;

    -- Check if we are doing deferred processing
    -- Bug 2210085 - starting a new block to capture exceptions thrown
    -- by GetDeferEventCtx
    begin
      if p_agent_name = 'WF_DEFERRED' then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.listen.Deferred',
                            'Processing Deferred Event');
        end if;

        wf_event.GetDeferEventCtx(st,from_agt_name,from_agt_sys,evt);
        -- dispatcher should process all subscriptions
        wf_event.phase_maxthreshold := null;
      end if;

      begin
        -- Dispatcher will throw exception in the following unexpected errors
        -- Defer Event Failed
        -- Generate Message Failed
        -- Rule Function Failed
        -- Unable to Save to Error Queue
        -- Unable to rollback to savepoint.
        -- Listen will swallow all of these exceptions unless the unexpected
        -- exception happened when processing error queue
        wf_event.dispatch(st, sagt, evt);

        -- We only count consecutive unexpected errors
        l_error_count := 0;
        commit;

        -- 7828862 Restore apps context from cached values
        wfa_sec.Restore_Ctx();
      exception
        when others then
          -- 7828862 Restore apps context from cached values
          wfa_sec.Restore_Ctx();

          if (wf_event.wf_exception_source = 'RULE') then
            if (st = 'ERROR') then
              if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
                 wf_log_pkg.string(wf_log_pkg.level_error,
                                  'wf.plsql.WF_EVENT.listen.dispatch_error',
                                  'Rule Function with Source Error Exception');
              end if;
              raise;
            else
              if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
                  wf_log_pkg.string(wf_log_pkg.level_error,
                                   'wf.plsql.WF_EVENT.listen.dispatch_error',
                                   'Rule Function Error');
              end if;
              wf_event.setErrorInfo(evt, 'ERROR');
              wf_event.saveErrorToQueue(evt);
              commit;
              l_error_count := l_error_count + 1;
            end if;
          else
            if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
               wf_log_pkg.string(wf_log_pkg.level_error,
                                'wf.plsql.WF_EVENT.listen.dispatch_error',
                                'Non Rule Function Error');
            end if;
            -- Bug 4207885: Set the exception source to be WF.
            wf_event.wf_exception_source := 'WF';
            commit;
            raise;
          end if;
      end;
    -- Bug 2210085
    exception
      when others then
        -- 7828862 Restore apps context from cached values
        wfa_sec.Restore_Ctx();

        -- Bug 2608037
        -- If the execution of rule function had failed and if the
        -- agent is the error queue then there is no point in enqueueing
        -- the event again into the error queue.
        -- In this case we just rollback the dequeue and raise the
        -- exception to the user.
        if (( wf_event.wf_exception_source = 'RULE') and (st = 'ERROR')) then
          if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_error,
                              'wf.plsql.WF_EVENT.listen.dispatch_error',
                              'Error executing Rule Function with Source Type Error');
          end if;
          rollback to bes_before_dequeue_qh;

          -- Error WFE_DISPATCH_RULE_ERR already has sufficient info on the error.
          -- Just raise it
          if (wf_core.error_name = 'WFE_DISPATCH_RULE_ERR') then
            raise;
          else
            wf_core.token('ENAME', evt.event_name);
            wf_core.token('EKEY', evt.event_key);
            wf_core.token('SQLERRM', sqlerrm);
            wf_core.token('SQLCODE', sqlcode);
            wf_core.raise('WFE_UNHANDLED_ERROR');
          end if;
        elsif (wf_event.wf_exception_source = 'WF') then
          -- Bug 4207885: Add the handler of exception with source WF
          if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_error,
                              'wf.plsql.WF_EVENT.listen.dispatch_error',
                              'Unexpected Function Error');
          end if;
          wf_core.token('ENAME', evt.event_name);
          wf_core.token('EKEY', evt.event_key);
          wf_core.token('SQLERRM', sqlerrm);
          wf_core.token('SQLCODE', sqlcode);
          wf_core.raise('WFE_UNHANDLED_ERROR');
        else
          if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_error,
                              'wf.plsql.WF_EVENT.listen.error',
                              'GetDeferEventCtx Error');
          end if;
          wf_event.setErrorInfo(evt,'ERROR');
          wf_event.saveErrorToQueue(evt);
          commit;
          l_error_count := l_error_count + 1;
        end if;
    end;

    -- check system status
    stat := wf_core.translate('WF_SYSTEM_STATUS');
    if ((stat <> 'ENABLED') AND (st <> stat)) then
      exit;
    end if;

    evt := null;
    wf_event.InitPhaseMinThreshold;
    wf_event.SetDispatchMode('SYNC');

    if (p_message_count > 0 AND l_lsn_msg_count >= p_message_count ) then
       if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
	  wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT.listen.maxMsgCount',
                            'Read the specified maximum number of messages');
       end if;
       exit;
    end if;

    if (p_max_error_count > 0 AND l_error_count >= p_max_error_count ) then
       if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	  wf_log_pkg.string(wf_log_pkg.level_error,
                            'wf.plsql.WF_EVENT.listen.maxErrCount',
                            'Encountered the specified maximum number of errors');
       end if;
       exit;
    end if;

    -- We need to explicitly make sure that if someones Queue Handler
    -- blows up we rollback the transaction, just in case they don't
    begin
      savepoint bes_before_dequeue_qh;
      wf_event.dequeue(agt, evt, qh, p_wait, p_correlation, p_deq_condition);
    exception
      when others then
        wf_event.wf_exception_source := 'QH';
        rollback to bes_before_dequeue_qh;
        raise;
    end;
  end loop;

  -- return back the actual read message count
  p_message_count := l_lsn_msg_count ;
  -- return back the actual error message count
  -- Normally l_lsn_msg_count >= l_error_count;
  p_max_error_count := l_error_count;

exception
  when no_data_found then
    -- 7828862 Restore apps context from cached values
    wfa_sec.Restore_Ctx();
    if (wf_event.wf_exception_source = 'WF'
	OR wf_event.wf_exception_source = 'QH') then
      raise;
    else
      wf_core.context('Wf_Event', 'Listen', p_agent_name);
      wf_core.raise('WFE_AGENT_NOTEXIST');
    end if;
  when others then
    wf_core.context('Wf_Event', 'Listen', p_agent_name);
    -- 7828862 Restore apps context from cached values
    wfa_sec.Restore_Ctx();
    raise;
end Listen;
---------------------------------------------------------------------------
/*
** listen_concurrent - <Described in WFEVENTS.pls>
*/
--Bug 2505487
--Included the AQ wait parameter for the listen_concurrent

PROCEDURE listen_concurrent(errbuf        out nocopy varchar2,
                            retcode       out nocopy  varchar2,
                            p_agent_name  in  varchar2,
                            p_correlation in  varchar2,
                            p_deq_condition in varchar2,
                            p_wait    in binary_integer) is
  errname  varchar2(30);
  errmsg   varchar2(2000);
  errstack varchar2(4000);
  l_p_wait binary_integer;
  l_correlation varchar2(128);

begin
  --Bug 2505487
  --Any -ve number for the parameter p_wait in the forms
  --is accepted as wait forever.
  if (p_wait < 0) then
    l_p_wait  := dbms_aq.forever ;
  else
    l_p_wait  := p_wait;
  end if;

--<rwunderl:2751674>
  if (UPPER(p_correlation) = 'NULL') then
    l_correlation := NULL;

  else
    l_correlation := p_correlation;

  end if;
--</rwunderl:2751674>

  --Bug 2649327
  --The deq condition is not used at present for dequeuing
  -- Hence setting it to NULL.
  wf_event.listen(p_agent_name  => p_agent_name,
                  p_wait        => l_p_wait,
                  p_correlation => l_correlation,
                  p_deq_condition=>NULL);

  -- Return 0 for successful completion --
  errbuf  := '';
  retcode := '0';
exception
  when others then
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error --
    retcode := '2';
end;

---------------------------------------------------------------------------
/*
** listen_grp - <Described in WFEVENTS.pls>
*/
PROCEDURE listen_grp(p_agent_name in varchar2,
                     p_wait       in binary_integer) is

  from_agt_name         varchar2(30);
  from_agt_sys          varchar2(30);
  st                    varchar2(10) := 'EXTERNAL';
  qh                    varchar2(240);
  stat                  varchar2(10);
  agt                   raw(16);
  sagt                  raw(16);
  evt                   wf_event_t;
  err_evt               wf_event_t;
  evt_errmsg	        VARCHAR2(4000);
  l_queueTable          VARCHAR2(30); --<rwunderl:2749563/>
  end_of_transaction    exception;
  pragma exception_init (end_of_transaction, -25235);

  -- bes caching implementation
  l_agent_obj  wf_agent_obj;
begin

  -- Confirm that p_agent_name includes a transactional queue.
--<rwunderl:2749563> Tuned and separated sql statement for better performance
--<rwunderl:2792298> restricting Listen() to local system.
  if (WF_EVENT.g_local_system_guid is NULL) then
    g_local_system_guid := hextoraw(WF_CORE.Translate('WF_SYSTEM_GUID'));
  end if;

  GetAgentDetails(p_agent_name);

  -- get agent details for local system
  l_agent_obj := wf_bes_cache.GetAgentByName(p_agent_name, null);
  if (l_agent_obj is null) then
    wf_core.context('Wf_Event', 'Listen_GRP', p_agent_name);
    wf_core.raise('WFE_AGENT_NOTEXIST');
  end if;
  qh := l_agent_obj.queue_handler;
  agt := l_agent_obj.guid;


  if (WF_EVENT.g_message_grouping <> 'TRANSACTIONAL') then
    --This is not a transactional queue.
    WF_CORE.Context('Wf_Event', 'Listen_GRP', p_agent_name);
    WF_CORE.Token('AGENT', p_agent_name);
    WF_CORE.Token('API', 'WF_EVENT.Listen');
    WF_CORE.Raise('WFE_NONTRXN_QUEUE');
  end if;

  --Verifying that the system is not disabled.
  if (wf_event.local_system_status = 'DISABLED') then
    return;
  end if;

    /*
    ** We need to explicitly make sure that if someones Queue Handler
    ** blows up we rollback the transaction, just in case they don't
    */
  loop --Outer loop to process all transactions.
    WF_CORE.Clear; --Clear any tokens that were set from the previous
                   --transaction dequeue.

    begin --We will begin processing a transaction (message group).
      savepoint trxn_start;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT.Listen_GRP.processing',
                          'Begin processing transaction');
      end if;

      begin

        -- Dequeue the first message in the transaction
        savepoint bes_before_dequeue_qh;
        wf_event.dequeue(agt, evt, qh,p_wait);

      exception
        when end_of_transaction then
          if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_EVENT.Listen_GRP.complete',
                              'End of the transaction');
          end if;

          -- reset navigation
          wf_event.resetNavigationParams;
          commit;

        when others then
          wf_event.wf_exception_source := 'QH';
          rollback to bes_before_dequeue_qh;
          raise;

      end;

      while (evt is not null) loop

           if (evt.getFromAgent() is null) then
             sagt := NULL;
           else
             from_agt_name := evt.getFromAgent().getName();
             from_agt_sys  := evt.getFromAgent().getSystem();

             if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                wf_log_pkg.string(wf_log_pkg.level_statement,
                                 'wf.plsql.WF_EVENT.Listen_GRP.event_dequeued',
                                 'Event '||evt.getEventName()||', hailing from '||from_agt_name||'@'||
                                  from_agt_sys|| ' was dequeued from '|| p_agent_name);
             end if;

             -- get the from agent guid
             GetSourceAgentGUID(agent_name   => from_agt_name,
                                agent_system => from_agt_sys,
                                agent_guid   => sagt);
           end if;

          /* Bug 2032654
	     1. Determine if the event name is null
	     2. If the event name is NULL, it should be defaulted to
	        UNEXPECTED_ERROR.
	     3. The text Event Name is NULL is appended to the error
                message. */


          if (evt.getEventName) is NULL then
	        evt.setEventName('UNEXPECTED_ERROR');
	        evt.setEventKey('UNEXPERR');
	        evt_errmsg := evt.getErrorMessage || wf_core.newline ||
	  	                wf_core.translate('WF_EVTNAME_NULL');
	        evt.setErrorMessage(wf_core.translate('WF_EVTNAME_NULL'));
          END IF;


          -- Begin Dispatching the event message.

          begin
            wf_event.dispatch(st, sagt, evt);

          exception
            when others then
              if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
                 wf_log_pkg.string(wf_log_pkg.level_error,
                                  'wf.plsql.WF_EVENT.Listen_GRP.dispatch_error',
                                  'Dispatch Error when dispatching Event '||evt.getEventName);
              end if;
              raise dispatch_error;

          end;

      -- check system status --
      stat := wf_core.translate('WF_SYSTEM_STATUS');
      if ((stat <> 'ENABLED') AND (st <> stat)) then
        exit;
      end if;

      evt := null;
      wf_event.InitPhaseMinThreshold;
      wf_event.SetDispatchMode('SYNC');

      begin
        savepoint bes_before_dequeue_qh;
        wf_event.dequeue(agt, evt, qh,p_wait);

      exception
        when end_of_transaction then
          if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_EVENT.Listen_GRP.complete',
                              'End of the transaction');
          end if;

          -- reset navigation
          wf_event.resetNavigationParams;
          commit;

        when others then
          wf_event.wf_exception_source := 'QH';
          rollback to bes_before_dequeue_qh;
          raise;

      end;

    end loop;



  exception
    when dispatch_error then
      --Dequeue the rest of the transaction
      begin
        loop
          wf_event.dequeue(agt, err_evt, qh,p_wait);

        end loop;

      exception
        when end_of_transaction then
          if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_EVENT.Listen_GRP.complete',
                              'End of the transaction after dispatch error');
          end if;

          -- reset navigation
          wf_event.resetNavigationParams;

      end;

      --Rollback the whole transaction, which will update the retry count
      --on each message.
      rollback to trxn_start;

      --We will save the current message to the Error Queue.
      if ((evt.getValueForParameter('ERROR_NAME')) is NULL) then
        wf_event.setErrorInfo(evt, 'ERROR');

      end if;

      evt.addParameterToList('DEQUEUE_MODE', 'TRANSACTIONAL');
      wf_event.saveErrorToQueue(evt);


    when others then
      raise;

    end;

    -- if QH is using setNavigationParams/getQueueNavigation, condition is
    -- g_processedMessagesCount = 0 and g_currentNavigation either
    -- FIRST_MESSAGE or NEXT_TRANSACTION,
    -- otherwise, condition is wf_event.navigation = dbms_aq.first_message
    if (g_navResetThreshold is not null and g_processedMessagesCount = 0
        and (g_currentNavigation in (dbms_aq.FIRST_MESSAGE, dbms_aq.NEXT_TRANSACTION)))
       OR
       (g_navResetThreshold is null and wf_event.navigation = dbms_aq.first_message)
    then

      exit; --Outer Loop.
            --The queue handler must have reached the last message and
            --reset the navigation back to the beginning.

    end if;

  end loop; --Outer loop to process all transactions in the queue.
exception
  when no_data_found then
    if (wf_event.wf_exception_source = 'WF'
	OR wf_event.wf_exception_source = 'QH') then
      raise;
    else
      wf_core.context('Wf_Event', 'Listen_GRP', p_agent_name);
      wf_core.raise('WFE_AGENT_NOTEXIST');
    end if;
  when others then
    wf_core.context('Wf_Event', 'Listen_GRP', p_agent_name);
    raise;
end;

---------------------------------------------------------------------------
/*
** listen__grp_concurrent - <Described in WFEVENTS.pls>
*/
PROCEDURE listen_grp_concurrent(errbuf       out nocopy varchar2,
                                retcode      out nocopy varchar2,
                                p_agent_name in  varchar2) is
  errname  varchar2(30);
  errmsg   varchar2(2000);
  errstack varchar2(4000);
begin
  wf_event.listen_grp(p_agent_name);

  -- Return 0 for successful completion --
  errbuf  := '';
  retcode := '0';
exception
  when others then
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error --
    retcode := '2';
end;

---------------------------------------------------------------------------
/*
** dispatch - <Described in WFEVENTS.pls>
*/
PROCEDURE dispatch(p_source_type        in     varchar2,
                   p_source_agent_guid  in     raw,
                   p_event              in out nocopy wf_event_t)
is
  res      varchar2(20);
  cmd      varchar2(1000);
  stat     varchar2(10);
  myfunc   varchar2(240);
  ename    varchar2(240);
  saved    boolean := FALSE;
  subs_found boolean :=FALSE;
  eguid    raw(16);
  l_skip_sub raw(16);
  event_count NUMBER;
  l_rule_func varchar2(300);
  l_source_type wf_event_subscriptions.source_type%type;
  l_phase wf_event_subscriptions.phase%type;
  l_rule_data wf_event_subscriptions.rule_data%type;
  l_priority wf_event_subscriptions.priority%type;
  l_on_error wf_event_subscriptions.on_error_code%type;
  --Bug 2437354
  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);

  -- bes caching implementation
  l_event_name varchar2(240);
  l_event_obj  wf_event_obj;
  l_subs_list  wf_event_subs_tab;
  l_sub        wf_event_subs_obj;
begin
  l_event_name := p_event.Event_Name;

  -- Deleting any previous Event parameter indexes.
  WF_EVENT.evt_param_index.DELETE;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.dispatch.Begin',
                      'Dispatching event '||l_event_name);
  end if;

  l_event_obj := wf_bes_cache.GetEventByName(l_event_name);
  if (l_event_obj is null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.dispatch.no_event',
                        'Event is either disabled or product not licensed '||
                        'or event not registered');
    end if;
  end if;

  wf_event.wf_exception_source := 'NONE';

  --
  -- mjc If Source Type is LOCAL and Phase Threshold is less than zero,
  --     the raise is to be deferred. Then we immediately return to
  --     calling subprogram
  --
  -- The wf_event.deferevent is called within a new block
  -- Make sure only defer event when event exists.
  begin
    if (p_source_type = 'LOCAL' AND
         (wf_event.phase_maxthreshold < 0 OR p_event.send_date > sysdate) AND
           l_event_obj is not null) then

      if(isDeferToJava(true, l_event_name, p_source_type,
                        null, null, null)) then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_EVENT.dispatch.Defer',
                           'Detected as deferred raise. Deferring to ' ||
                           'WF_JAVA_DEFERRED');
        end if;
        wf_event.DeferEventToJava(p_source_type, p_event);
      else
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_EVENT.dispatch.Defer',
                           'Detected as deferred raise. Deferring to ' ||
                           'WF_DEFERRED');
        end if;
        wf_event.deferevent(p_source_type, p_event);
      end if;
      return;
    end if;
   exception
    when others then
      wf_event.setErrorInfo(p_event, 'ERROR');
      wf_event.saveErrorToQueue(p_event);
      wf_core.context('Wf_Event', 'Dispatch', l_event_name);
      raise;
  end;

  --
  -- mjc We have 4 things we need to check for when we are dipatching:
  -- 1. Are there any subscriptions for the actual event.
  -- 2. Are there any subscriptions to an event group the event belongs to.
  -- 3. Are there any subscriptions to the any event.
  -- 4. If no subscriptions found in 1,2,3 then check for the unexpected event.
  --

  -- YOHUANG
  -- TODO
  -- Since we know whether this event exist or not, if the event doesn't exist
  -- We should execute those expense query such as active_subs, we should instead
  -- directly execute active_event_subs for ANY event.
  /*
  ** Events, Event Groups, Any Event
  */
  --The savepoint is set if the event has not been deferred
  begin
    savepoint wf_dispatch_savepoint;
  exception
    when trig_savepoint then
      --If the event has not been deferred, defer the event now.
      begin
        wf_event.deferevent(p_source_type,p_event);
        return;
      exception
        --Incase deferreing of event fails, save the error to queue.
        --Should we save the error to queue since it is WF error?
        when others then
          wf_event.setErrorInfo(p_event, 'ERROR');
          wf_event.saveErrorToQueue(p_event);
          wf_core.context('Wf_Event', 'Dispatch', l_event_name);
          raise;
      end;
  end;

  -- Subscriptions dispatch block
  begin
    -- Only the skipped subscription should be executed when
    -- WFERROR DEFAULT_EVENT_ERROR re-raise the event again.
    l_skip_sub := GetSkippedSub(p_event);

    if (l_skip_sub is not null AND p_source_type = 'LOCAL') then

      l_sub := wf_bes_cache.GetSubscriptionByGUID(l_event_name, l_skip_sub);
      if (l_sub is not null) then
        res := wf_event.dispatch_internal(p_source_type => l_sub.SOURCE_TYPE,
                                          p_rule_data   => l_sub.RULE_DATA,
                                          p_rule_func   => trim(l_sub.RULE_FUNCTION),
                                          p_sub_guid    => l_skip_sub,
                                          p_source_agent_guid => l_sub.SOURCE_AGENT_GUID,
                                          p_phase       => l_sub.PHASE,
                                          p_priority    => l_sub.PRIORITY,
                                          p_event       => p_event,
                                          p_on_error    => l_sub.ON_ERROR_CODE);
      end if;
      -- Since this is the only sub to be executed, no matter
      -- what result it reports, we stop here.
      return;
    end if;

    -- get and dispatch subscriptions to the even only if the event is
    -- valid, product is licensed etc. else directly dispatch Any event
    if (l_event_obj is not null) then
      -- all subscriptions to the event and Any event in the order of phase
      l_subs_list := wf_bes_cache.GetSubscriptions(p_event_name   => l_event_name,
                                                   p_source_type  => dispatch.p_source_type,
                                                   p_source_agent => dispatch.p_source_agent_guid);
      -- dispatching all matching subscriptions for the event
      if (l_subs_list is not null) then

        for i in 1..l_subs_list.COUNT loop
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                             'wf.plsql.WF_EVENT.dispatch.Subscriptions',
                             'Dispatching '||l_subs_list(i).SOURCE_TYPE||' subscription '||
                             'with Phase '||l_subs_list(i).PHASE);
          end if;

          eguid := l_subs_list(i).GUID;
          subs_found := TRUE;

          res := wf_event.dispatch_internal(p_source_type => l_subs_list(i).SOURCE_TYPE,
                                            p_rule_data   => l_subs_list(i).RULE_DATA,
                                            p_rule_func   => trim(l_subs_list(i).RULE_FUNCTION),
                                            p_sub_guid    => l_subs_list(i).GUID,
                                            p_source_agent_guid => p_source_agent_guid,
                                            p_phase       => l_subs_list(i).PHASE,
                                            p_priority    => l_subs_list(i).PRIORITY,
                                            p_event       => p_event,
                                            p_on_error    => l_subs_list(i).ON_ERROR_CODE);

          if res in ('ERROR', 'DEFER', 'TRANSACTION_COMMITED') then
            exit;
          end if;
        end loop;
      end if;

    -- Event object is null, dispatch only Any event subscriptions
    else

      -- dispatch subscriptions to Any event. this call does not execute the
      -- cursor with union all
      l_subs_list := wf_bes_cache.GetSubscriptions(p_event_name   => 'oracle.apps.wf.event.any',
                                                   p_source_type  => dispatch.p_source_type,
                                                   p_source_agent => dispatch.p_source_agent_guid);
      -- dispatching all matching subscriptions for Any event
      if (l_subs_list is not null) then

        for i in 1..l_subs_list.COUNT loop
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                             'wf.plsql.WF_EVENT.dispatch.Any',
                             'Dispatching '||l_subs_list(i).SOURCE_TYPE||' subscription '||
                             'with Phase '||l_subs_list(i).PHASE);
          end if;

          eguid := l_subs_list(i).GUID;
          subs_found := TRUE;

          res := wf_event.dispatch_internal(p_source_type => l_subs_list(i).SOURCE_TYPE,
                                            p_rule_data   => l_subs_list(i).RULE_DATA,
                                            p_rule_func   => trim(l_subs_list(i).RULE_FUNCTION),
                                            p_sub_guid    => l_subs_list(i).GUID,
                                            p_source_agent_guid => p_source_agent_guid,
                                            p_phase       => l_subs_list(i).PHASE,
                                            p_priority    => l_subs_list(i).PRIORITY,
                                            p_event       => p_event,
                                            p_on_error    => l_subs_list(i).ON_ERROR_CODE);

          if res in ('ERROR', 'DEFER', 'TRANSACTION_COMMITED') then
            exit;
          end if;
        end loop;
      end if;
    end if;

    -- If no subscriptions dispatched, dispatch subscriptions for Unexpected event.
    -- Unexpected event is dispatched only for non-workflow events
    if ((not subs_found) and (l_event_name not like 'oracle.apps.wf%')) then

      l_subs_list := wf_bes_cache.GetSubscriptions(p_event_name   => 'oracle.apps.wf.event.unexpected',
                                                   p_source_type  => dispatch.p_source_type,
                                                   p_source_agent => dispatch.p_source_agent_guid);
      if (l_subs_list is not null) then

        for i in 1..l_subs_list.COUNT loop
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement,
                             'wf.plsql.WF_EVENT.dispatch.Unexpected',
                             'Dispatching '||l_subs_list(i).SOURCE_TYPE||' subscription '||
                             'with Phase '||l_subs_list(i).PHASE);
          end if;

          eguid := l_subs_list(i).GUID;
          res := wf_event.dispatch_internal(p_source_type => l_subs_list(i).SOURCE_TYPE,
                                            p_rule_data   => l_subs_list(i).RULE_DATA,
                                            p_rule_func   => trim(l_subs_list(i).RULE_FUNCTION),
                                            p_sub_guid    => l_subs_list(i).GUID,
                                            p_source_agent_guid => p_source_agent_guid,
                                            p_phase       => l_subs_list(i).PHASE,
                                            p_priority    => l_subs_list(i).PRIORITY,
                                            p_event       => p_event,
                                            p_on_error    => l_subs_list(i).ON_ERROR_CODE);

          if res in ('ERROR', 'DEFER', 'TRANSACTION_COMMITED') then
            exit;
          end if;
        end loop;
      end if;
    end if;
  exception
    when others then
      -- Unexpected Error happened in dispatch_internal
      if (WF_EVENT.g_message_grouping = 'TRANSACTIONAL') then
        WF_CORE.Context('Wf_Event', 'Dispatch', l_event_name);
      else
        rollback to wf_dispatch_savepoint;
        p_event.setErrorSubscription(eguid);
  	if (wf_event.wf_exception_source <> 'RULE') then
     	  wf_event.wf_exception_source := 'WF';
      	  wf_event.setErrorInfo(p_event, 'UNEXPECTED');
      	  -- Unexpected Exception should be thrown up instead of
      	  -- being enqueued to error queue.
      	  -- wf_event.saveErrorToQueue(p_event);
      	  wf_core.context('Wf_Event', 'Dispatch', l_event_name);
    	end if;
      end if;
      raise;
  end;
end dispatch;


---------------------------------------------------------------------------
/*
** enqueue - <Described in WFEVENTS.pls>
*/
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t)
is
  cmd     varchar2(1000);
  qh      varchar2(240);
  agtname varchar2(30);
  sysname varchar2(30);

  -- bes caching implementation
  l_agent_obj  wf_agent_obj;
  p_executed   boolean;
begin
  /*
  ** mjc If an override agent is defined, we should
  **     use that agents queue handler
  */
  if p_out_agent_override is null then
    agtname := p_event.From_Agent.Name;
    sysname := p_event.From_Agent.System;
  else
    agtname := p_out_agent_override.GetName();
    sysname := p_out_agent_override.GetSystem();
  end if;

  l_agent_obj := wf_bes_cache.GetAgentByName(agtname, sysname);
  if (l_agent_obj is not null) then
    qh := l_agent_obj.QUEUE_HANDLER;
  end if;

  -- Call the static calls implementation first
  p_executed := false;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string2(wf_log_pkg.level_statement,
                      'wf.plsql.wf_event.enqueue.qhandler_callout',
                      'Start executing queue handler - '||qh, true);
  end if;

  WF_AGT_DYN_FUNCS.StaticEnqueue(qh, p_event, p_out_agent_override, p_executed);

  if (not p_executed) then
    -- qh is from WF_AGENTS.QUEUE_HANDLER
    -- BINDVAR_SCAN_IGNORE
    cmd := 'begin '||qh||'.enqueue(:v1, :v2); end;';
    execute immediate cmd using in p_event,
                                in p_out_agent_override;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string2(wf_log_pkg.level_statement,
                      'wf.plsql.wf_event.enqueue.qhandler_callout',
                      'End executing queue handler - '||qh, false);
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'Enqueue', p_event.getEventName(), qh);
    wf_core.token('FUNCTION_NAME', qh||'.enqueue()');
    --wf_core.raise('WF_EXT_FUNCTION');
    raise;
end;
---------------------------------------------------------------------------
/*
** dequeue - <Described in WFEVENTS.pls>
*/
PROCEDURE dequeue(p_agent_guid    in     raw,
                  p_event            out nocopy  wf_event_t,
                  p_queue_handler in out nocopy varchar2,
                  p_wait          in     binary_integer,
                  p_correlation   in     varchar2,
                  p_deq_condition in     varchar2)
is
  qh  varchar2(240);
  cmd varchar2(1000);
  evt_errmsg varchar2(2000);

  -- bes caching implementation
  l_agent_obj  wf_agent_obj;
  p_executed   boolean;
begin
  if (p_queue_handler is null) then
    -- get queue details from cache for given agent GUID
    l_agent_obj := wf_bes_cache.GetAgentByGUID(p_agent_guid);
    if (l_agent_obj is not null) then
      qh := l_agent_obj.QUEUE_HANDLER;
    end if;
  else
    -- ### add verification in the future
    qh := p_queue_handler;
  end if;

  -- Set globals so the queue handlers can reference them.
  WF_EVENT.g_correlation := p_correlation;
  WF_EVENT.g_deq_condition := p_deq_condition;

  -- Call the static calls implementation first
  p_executed := false;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string2(wf_log_pkg.level_statement,
                      'wf.plsql.wf_event.dequeue.qhandler_callout',
                      'Start executing queue handler - '||qh, true);
  end if;

  WF_AGT_DYN_FUNCS.StaticDequeue(qh, p_agent_guid, p_event, p_wait, p_executed);

  if (not p_executed) then
    -- p_queue_handler is normally null, or control by us
    -- BINDVAR_SCAN_IGNORE
    cmd := 'begin '||qh||'.dequeue(:v1, :v2); end;';
    execute immediate cmd using in  p_agent_guid,
                                out p_event;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string2(wf_log_pkg.level_statement,
                      'wf.plsql.wf_event.dequeue.qhandler_callout',
                      'End executing queue handler - '||qh, false);
  end if;

  p_queue_handler := qh;
exception
  when others then
    wf_core.context('Wf_Event', 'Dequeue', p_agent_guid);
    wf_core.token('FUNCTION_NAME', qh||'.dequeue()');
    --wf_core.raise('WF_EXT_FUNCTION');
    raise;
end;
---------------------------------------------------------------------------
/*
** AddParameterToList - <described in WFEVENTS.pls>
*/
-- YOHUANG 3571176
-- Share the same logic as WF_EVENT_T.AddParameterToList
-- If there is any change of logic in this method, the change
-- should be propagated over to WF_EVENT_T.
PROCEDURE AddParameterToList(p_name  in varchar2,
                             p_value in varchar2,
                             p_parameterlist in out nocopy wf_parameter_list_t)
is
  j       number;
  found   boolean := FALSE;
begin
  if (p_ParameterList is null) then
  --
  -- Initialize Parameter List and set value
  --
      p_ParameterList := wf_parameter_list_t(null);
      p_ParameterList(1) := wf_parameter_t(p_Name, p_Value);
  else
  --
  -- parameter list exists, add parameter to list
  --
    j := 1;
    while (NOT found AND j <= p_parameterlist.COUNT ) LOOP
      -- YOHUANG 3566991, make sure myList(j) is not null
      -- to avoid 36025 ora error
      IF (p_parameterlist(j) IS NOT NULL) THEN
        if (p_parameterlist(j).getName() = p_name) then
           found := TRUE;
           p_parameterlist(j).setValue(p_Value);
        END if;
      END IF;
      j := j+1;
    end loop;

    -- otherwise, add new parameter to list --

    if (NOT found) then
      p_ParameterList.EXTEND;
      j := p_ParameterList.COUNT;
      p_ParameterList(j) := wf_parameter_t(p_name, p_Value);
    end if;
  end if;
end AddParameterToList;
---------------------------------------------------------------------------
/*
** AddParameterToListPos - <described in WFEVENTS.pls>
*/
PROCEDURE AddParameterToListPos(p_name  in varchar2,
                             p_value in varchar2,
                             p_position out nocopy integer,
                             p_parameterlist in out nocopy wf_parameter_list_t)
is
  j       integer;

begin
  if (p_ParameterList is null) then
  --
  -- Initialize Parameter List and set value
  --
      p_ParameterList := wf_parameter_list_t(null);
      p_position := 1;
      p_ParameterList(1) := wf_parameter_t(p_Name, p_Value);
  else
  --
  -- parameter list exists, add parameter to list
  --
    p_ParameterList.EXTEND;
    j := p_ParameterList.COUNT;
    p_position := j;
    p_ParameterList(j) := wf_parameter_t(p_Name, p_Value);
  end if;

end AddParameterToListPos;
---------------------------------------------------------------------------
/*
** GetValueForParameter - <described in WFEVENTS.pls>
*/
FUNCTION getValueForParameter(p_Name in varchar2,
			      p_ParameterList in wf_parameter_list_t )
return varchar2 is
  myList  wf_parameter_list_t;
  pos     number := 1;
begin
  myList := p_ParameterList;
  if (myList is null) then
    return NULL;
  end if;

  pos := myList.LAST;
  --while(pos <= myList.COUNT) loop
  while(pos is not null) loop
    if (myList(pos).getName() = p_Name) then

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT.getValueForParam.get',
                          'Name:'||p_Name||' Value:'||myList(pos).getValue());
      end if;

      return myList(pos).getValue();
    end if;
    --pos := pos + 1;
    pos := myList.PRIOR(pos);
  end loop;
  return NULL;
end getValueForParameter;
---------------------------------------------------------------------------
/*
** GetValueForParameterPos - Gets value for position from wf_parameter_list_t
*/
FUNCTION getValueForParameterPos(p_position in integer,
                              p_parameterlist in wf_parameter_list_t)
return varchar2 is
  myList  wf_parameter_list_t;
begin
  myList := p_ParameterList;
  if (myList is null) then
    return NULL;
  end if;

  return myList(p_position).getValue();

end getValueForParameterPos;
---------------------------------------------------------------------------
/*
** SetDispatchMode - <described in WFEVENTS.pls>
*/
PROCEDURE SetDispatchMode (p_mode  in varchar2)
is
begin
  if p_mode = 'ASYNC' then
    wf_event.phase_maxthreshold := -1;
  else
    wf_event.phase_maxthreshold := 100;
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'SetDispatchMode', p_mode);
    raise;
end SetDispatchMode;
---------------------------------------------------------------------------
/*
** InitPhaseMinThreshold <described in WFEVENTS.pls>
*/
PROCEDURE InitPhaseMinThreshold
is
begin
  wf_event.phase_minthreshold := 0;
end InitPhaseMinThreshold;
---------------------------------------------------------------------------
/*
** DeferEvent - <described in WFEVENTS.pls>
*/
PROCEDURE DeferEvent(p_source_type        in     varchar2,
                     p_event              in out nocopy wf_event_t)
is
  defagent  wf_agent_t;

begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.DeferEvent.Begin',
                      'Deferring Event: '||p_event.getEventName());
  end if;
  --
  -- Get the Local System Name and set the deferred agent
  --

  defagent := wf_agent_t('WF_DEFERRED',wf_event.local_system_name);

  --
  -- If the defer is for a local event, set the
  -- Deferred Agent/System into the message for
  -- reference when we process the event
  --
  if p_source_type = 'LOCAL' then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.DeferEvent.Local',
                        'Detected as Local, setting From Agent:'||
                        'WF_DEFERRED@'||wf_event.local_system_name);
    end if;
    p_event.From_Agent := defagent;
  end if;

  --
  -- Enqueue onto the deferred agent
  --
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.DeferEvent.done',
                      'Enqueuing on Deferred Queue');
  end if;

  wf_event.enqueue(p_event,defagent);

exception
  when others then
    wf_core.context('Wf_Event', 'DeferEvent', p_event.getEventName(),
			p_event.getEventKey());
    raise;
end DeferEvent;
---------------------------------------------------------------------------
/*
** DeferEventToJava - <described in WFEVENTS.pls>
*/
PROCEDURE DeferEventToJava(p_source_type        in     varchar2,
                           p_event              in out nocopy wf_event_t)
is
  defagent  wf_agent_t;

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.DeferEventToJava.Begin',
                      'Deferring Event: '|| p_event.getEventName());
  end if;
  --
  -- Get the Local System Name and set the deferred agent
  --
  defagent := wf_agent_t('WF_JAVA_DEFERRED', wf_event.local_system_name);

  --
  -- If the defer is for a local event, set the
  -- Deferred Agent/System into the message for
  -- reference when we process the event
  --
  if p_source_type = 'LOCAL' then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT.DeferEventToJava.Local',
                        'Detected as Local, setting From Agent:'||
                        'WF_JAVA_DEFERRED@'|| wf_event.local_system_name);

    end if;
    p_event.From_Agent := defagent;
  end if;

  --
  -- Enqueue onto the deferred agent
  --

  --
  -- NOTE: Since we know that we need to defer to WF_JAVA_DEFERRED, we will
  --       directly invoke enqueue on the PL/SQL queue handler
  --
  wf_event_ojmstext_qh.enqueue(p_event, defagent);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.DeferEventToJava.done',
                      'Enqueuing on Java Deferred Queue');
  end if;

exception
  when others then
    wf_core.context('Wf_Event', 'DeferEventToJava', p_event.getEventName(),
                     p_event.getEventKey());
    raise;
end DeferEventToJava;
---------------------------------------------------------------------------
/*
** GetDeferEventCtx - <described in WFEVENTS.pls>
*/
PROCEDURE GetDeferEventCtx (p_source_type     in out nocopy     varchar2,
		            p_agent_name      in         varchar2,
                            p_system_name     in         varchar2,
                            p_event           in         wf_event_t)
is
  subguid  raw(16);
  lphasestart number;
  lsrc     varchar2(10);

  -- bes caching implementation
  l_sub        wf_event_subs_obj;
  l_event_name varchar2(240);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.DeferEventCtx.Begin',
                      'Getting Defer Event Ctx');
  end if;
  --
  -- Determine the Start Phase, and sourec type
  --
  subguid := p_event.Error_Subscription;
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.DeferEventCtx.sub_guid',
                      'Sub Guid is '||subguid);
  end if;

  l_event_name := p_event.GetEventName();
  if subguid is not null then
    l_sub := wf_bes_cache.GetSubscriptionByGUID(l_event_name, subguid);

    if (l_sub is not null) then
      lsrc := l_sub.SOURCE_TYPE;
      lphasestart := l_sub.PHASE;
    else
      -- << sstomar : bug 5870400>>
      lphasestart :=  p_event.GetValueForParameter('#CURRENT_PHASE');

      if(lphasestart is null) then
	raise no_data_found;
      END if;

    end if;

    wf_event.phase_minthreshold := lphasestart;
  else
    wf_event.phase_minthreshold := 0; -- for deferred raise
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT.DeferEventCtx.phase',
                      'Start Phase is '||to_char(wf_event.phase_minthreshold));
  end if;

  if lsrc is null then
    --
    -- Derive the Source Type
    --
    if ((p_agent_name = 'WF_DEFERRED') AND (p_system_name = wf_event.local_system_name)) then
      p_source_type := 'LOCAL';
    elsif ((p_system_name is null) OR (p_system_name <> wf_event.local_system_name))then
      p_source_type := 'EXTERNAL';
    elsif ((p_agent_name <> 'WF_DEFERRED') AND (p_system_name = wf_event.local_system_name)) then
      p_source_type := 'EXTERNAL';
    end if;
  else
    p_source_type := lsrc;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.DeferEventCtx.End',
                      'Source Type is '||p_source_type);
  end if;

exception
  /* Bug 2210085 */
  when no_data_found then
    /*
    wf_core.context('Wf_Event', 'GetDeferEventCtx','Sub guid is ' || subguid);
    wf_core.token('SGUID', subguid);
    wf_core.raise('WFE_SUB_DELETED');
    */
    raise;

  when others then
    wf_core.context('Wf_Event', 'GetDeferEventCtx', p_event.getEventName(),
			p_event.getEventKey());
    raise;
end GetDeferEventCtx;
---------------------------------------------------------------------------
/*
** SetAccountName - <described in WFEVENTS.pls>
*/
PROCEDURE SetAccountName
is
begin
-- get the account name - only need this for WF_DEFERRED
  select sys_context('USERENV', 'CURRENT_SCHEMA')
  into wf_event.account_name
  from sys.dual;
exception
  when others then
    wf_core.context('Wf_Event', 'SetAccountName');
    raise;
end SetAccountName;
---------------------------------------------------------------------------
--
-- Bug# 2211719 - New API raise2 for calls that donot understand
--                Oracle data types`
/*
** raise2 - <Described in WFEVENTS.pls>
*/

PROCEDURE raise2(p_event_name      in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob,
                p_parameter_name1  in varchar2,
                p_parameter_value1 in varchar2,
                p_parameter_name2  in varchar2,
                p_parameter_value2 in varchar2,
                p_parameter_name3  in varchar2,
                p_parameter_value3 in varchar2,
                p_parameter_name4  in varchar2,
                p_parameter_value4 in varchar2,
                p_parameter_name5  in varchar2,
                p_parameter_value5 in varchar2,
                p_parameter_name6  in varchar2,
                p_parameter_value6 in varchar2,
                p_parameter_name7  in varchar2,
                p_parameter_value7 in varchar2,
                p_parameter_name8  in varchar2,
                p_parameter_value8 in varchar2,
                p_parameter_name9  in varchar2,
                p_parameter_value9 in varchar2,
                p_parameter_name10  in varchar2,
                p_parameter_value10 in varchar2,
                p_parameter_name11  in varchar2,
                p_parameter_value11 in varchar2,
                p_parameter_name12  in varchar2,
                p_parameter_value12 in varchar2,
                p_parameter_name13  in varchar2,
                p_parameter_value13 in varchar2,
                p_parameter_name14  in varchar2,
                p_parameter_value14 in varchar2,
                p_parameter_name15  in varchar2,
                p_parameter_value15 in varchar2,
                p_parameter_name16  in varchar2,
                p_parameter_value16 in varchar2,
                p_parameter_name17  in varchar2,
                p_parameter_value17 in varchar2,
                p_parameter_name18  in varchar2,
                p_parameter_value18 in varchar2,
                p_parameter_name19  in varchar2,
                p_parameter_value19 in varchar2,
                p_parameter_name20  in varchar2,
                p_parameter_value20 in varchar2,
                p_send_date  in date) is
l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
i number := 1;
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.raise2.Begin',
                      'Event Name:'||p_event_name||' Event Key:'||p_event_key);
  end if;

  if (p_parameter_name1 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name1, p_parameter_value1);
     i := i + 1;
  end if;

  if (p_parameter_name2 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name2, p_parameter_value2);
     i := i + 1;
  end if;

  if (p_parameter_name3 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name3, p_parameter_value3);
     i := i + 1;
  end if;

  if (p_parameter_name4 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name4, p_parameter_value4);
     i := i + 1;
  end if;

  if (p_parameter_name5 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name5, p_parameter_value5);
     i := i + 1;
  end if;

  if (p_parameter_name6 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name6, p_parameter_value6);
     i := i + 1;
  end if;

  if (p_parameter_name7 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name7, p_parameter_value7);
     i := i + 1;
  end if;

  if (p_parameter_name8 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name8, p_parameter_value8);
     i := i + 1;
  end if;

  if (p_parameter_name9 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name9, p_parameter_value9);
     i := i + 1;
  end if;

  if (p_parameter_name10 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name10, p_parameter_value10);
     i := i + 1;
  end if;

  if (p_parameter_name11 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name11, p_parameter_value11);
     i := i + 1;
  end if;

  if (p_parameter_name12 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name12, p_parameter_value12);
     i := i + 1;
  end if;

  if (p_parameter_name13 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name13, p_parameter_value13);
     i := i + 1;
  end if;

  if (p_parameter_name14 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name14, p_parameter_value14);
     i := i + 1;
  end if;

  if (p_parameter_name15 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name15, p_parameter_value15);
     i := i + 1;
  end if;

  if (p_parameter_name16 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name16, p_parameter_value16);
     i := i + 1;
  end if;

  if (p_parameter_name17 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name17, p_parameter_value17);
     i := i + 1;
  end if;

  if (p_parameter_name18 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name18, p_parameter_value18);
     i := i + 1;
  end if;

  if (p_parameter_name19 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name19, p_parameter_value19);
     i := i + 1;
  end if;

  if (p_parameter_name20 is not NULL) then
     l_parameter_list.extend;
     l_parameter_list(i) := CreateParameter(p_parameter_name20, p_parameter_value20);
  end if;

  wf_event.raise(p_event_name, p_event_key, p_event_data, l_parameter_list, p_send_date);

exception
  when others then
    raise;
end raise2;
---------------------------------------------------------------------------
/*
** CreateParameter - <Described in WFEVENTS.pls>
*/
FUNCTION CreateParameter( p_name      in  varchar2,
                          p_value     in  varchar2)
return wf_parameter_t
is
l_parameter wf_parameter_t := wf_parameter_t(null, null);
begin
    l_parameter.SetName(p_name);
    l_parameter.SetValue(p_value);
    return l_parameter;
exception
    when others then
       raise;
end CreateParameter;

--------------------------------------------------------------------
--Bug 2375902
--New API raise3 which has the parameters of the event
--as in out parameters and hence can be used by the calling program.
--------------------------------------------------------------------
PROCEDURE raise3(p_event_name      in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob,
                p_parameter_list   in out nocopy wf_parameter_list_t,
                p_send_date        in date)
is
  o_value varchar2(200);
event wf_event_t;
begin

  -- Bug 9370391: tag DB session for BES module
  wf_core.tag_db_session(wf_core.conn_tag_bes, p_event_name);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.raise3.Begin',
                      'Event Name:'||p_event_name||' Event Key:'||p_event_key ||
                      'Maximum nested raise count:'|| wf_event.max_nested_raises||
                      'Nested raise count: '|| wf_event.nested_raise_count);
  end if;

  wf_event.nested_raise_count := wf_event.nested_raise_count + 1;
  if (wf_event.nested_raise_count > wf_event.max_nested_raises) then
    --Bug 2620834
    --The nested count is reset to the initial value that was set before the
    --recursion error occurs.
    --In future if we allow the user to set the nested-raises -count
    --we could think of restting it to that value instead of zero.
    wf_event.nested_raise_count := 0;

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_error,
                        'wf.plsql.WF_EVENT.raise3.recursion_error',
                        'Recursion error raised. Nested raise count exceeded threshold');
    end if;

    wf_core.context('Wf_Event', 'raise', p_event_name, p_event_key);
    wf_core.raise('WFE_RECURSION');
  end if;

  --Create the event that is to be raised
  wf_event_t.initialize(event);
  event.Send_Date      := nvl(p_send_date,sysdate);
  event.Event_Name     := p_event_name;
  event.Event_Key      := p_event_key;
  event.Parameter_List := p_parameter_list;
  if (p_event_data is not null) then
    event.event_data   := p_event_data ;
  end if;

  wf_event.dispatch('LOCAL', null, event);

  --Output the parameterlist which may have been
  --modified
  p_parameter_list := event.getParameterList();

  if (wf_event.nested_raise_count >0) then
    wf_event.nested_raise_count := wf_event.nested_raise_count - 1;
  end if;

  event := null;

exception
  when others then
    raise;
end raise3;

--------------------------------------------------------------------------------
-- Sets the correlation for dequeuing.
--
-- NOTE: This has been done because we did not want to change the signature of
--       dequeue in the queue handlers
--
-- p_correlation - the correlation
--------------------------------------------------------------------------------
PROCEDURE Set_Correlation(p_correlation in varchar2)
IS
BEGIN
  WF_EVENT.g_correlation := p_correlation;
  WF_EVENT.navigation := dbms_aq.first_message;

END Set_Correlation;

---------------------------------------------------------------------------
/*
** SetMaxNestedRaise  - Populates Global Variable : max_nested_raises
**                      with the value specified in the input parameter.
*/
PROCEDURE SetMaxNestedRaise (maxcount in  number)
is
begin
  wf_event.max_nested_raises := maxcount;
end;
---------------------------------------------------------------------------
/*
** SetNestedRaiseCount  - Populates Global Variable : nested_raises_count
**                        with the value specified in the input parameter.
** PRIVATE PROCEDURE
*/
PROCEDURE SetNestedRaiseCount (nestedcount in number)
is
begin
  wf_event.nested_raise_count := nestedcount;
  --This private variable P_NESTED_RAISE_COUNT is updated
  --in sync with the setting of nested_raise_count global variable
  --It is used when the recursion error occurs inorder to reset the
  --value of wf_event.nested_raise_count.
  --P_NESTED_RAISE_COUNT        := wf_event.nested_raise_count;
end;
---------------------------------------------------------------------------
/*
** GetMaxNestedRaise  - Get the value of the Global Variable max_nested_raises
*/

FUNCTION GetMaxNestedRaise
return number
is
begin
  return wf_event.max_nested_raises;
end;

---------------------------------------------------------------------------
/*
** GetNestedRaiseCount  - Get the value of the Global Variable
**                        nested_raises_count
*/

FUNCTION GetNestedRaiseCount
return number
is
begin
  return wf_event.nested_raise_count;
end;

---------------------------------------------------------------------------

FUNCTION Get_MsgId
return varchar2
is
begin
  return wf_event.g_msgid;
end;

---------------------------------------------------------------------------
/*
** GetLocalSystemInfo - <described in WFEVENTS.pls>
*/
PROCEDURE GetLocalSystemInfo(system_guid   out nocopy raw,
                             system_name   out nocopy varchar2,
                             system_status out nocopy varchar2)
is
begin
  system_guid := wf_event.local_system_guid;
  system_name := wf_event.local_system_name;
  system_status := wf_event.local_system_status;
exception
  when others then
    wf_core.context('Wf_Event', 'GetLocalSystemName');
end GetLocalSystemInfo;
---------------------------------------------------------------------------
/*
** GetSourceAgentGUID - <described in WFEVENTS.pls>
*/
PROCEDURE GetSourceAgentGUID(agent_name   in         varchar2,
                             agent_system in         varchar2,
                             agent_guid   out nocopy raw)
is
  -- bes caching implementation
  l_agent_obj  wf_agent_obj;
begin

  l_agent_obj := wf_bes_cache.GetAgentByName(agent_name, agent_system);

  if (l_agent_obj is not null) then
    agent_guid := l_agent_obj.GUID;
  else
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_error,
                        'wf.plsql.WF_EVENT.GetSourceAgentGUID.Error',
			'Specified source agent row does '||
			'not exist in database.  Setting to NULL.');
    end if;
    agent_guid := null;
  end if;
exception
  when others then
    wf_core.context('Wf_Event', 'GetSourceAgentGUID', agent_name);
    raise;
end GetSourceAgentGUID;
---------------------------------------------------------------------------
/*
 ** GetAgentDetails (PRIVATE) - Gets the agents details such as the queue name
 **                              schema name and recepients
 */
procedure GetAgentDetails(agent_name 	in	varchar2)
is

  l_queue_name     varchar2(80);
  l_pos            number := 0;
  l_name           varchar2(30);
  l_owner          varchar2(30);
  l_queue_table    varchar2(30);

  -- bes caching implementation
  l_agent_obj     wf_agent_obj;
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.GetAgentDetails.Begin',
                      'Get Agent Details');
  end if;

   if(agent_name is not null and agent_name <> wf_event.pv_last_agent_name) then
    -- for a given agent name Query wf_agents to get the agent info

    l_agent_obj := wf_bes_cache.GetAgentByName(agent_name, null);
    if (l_agent_obj is not null) then
      l_queue_name := l_agent_obj.QUEUE_NAME;
    end if;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_EVENT.GetAgentDetails',
                       'l_queue_name = ' || l_queue_name);
    end if;

    -- since since queue_name is a nullable col. l_queue_name could be null
    -- let the caller program handle the case of null queue_name
    if(l_queue_name is not null) then
      -- derive the queue name and the schema

      l_pos := instr(l_queue_name,'.');
      l_name := substr(l_queue_name, l_pos + 1);

      if (l_pos > 0) then
        l_owner := substr(l_queue_name, 1, l_pos - 1);
      else
        -- if queue_name does not contain schema we will look in WF_SCHEMA
        l_owner := wf_event.schema_name;
      end if;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                         'wf.plsql.WF_EVENT.GetAgentDetails',
                         'l_name = ' || l_name ||
                         ' l_owner = ' || l_owner);
      end if;

      -- retrieve recipients (MULTIPLE or SINGLE) for AQ
      -- 3659756 When get agent details, check if the enqueue and dequeue are enabled.
      select aq.queue_type, aq.QUEUE_TABLE, trim(dequeue_enabled)
      into WF_EVENT.g_queueType, l_queue_table, WF_EVENT.pv_last_dequeue_enabled
      from   all_queues aq
      where  aq.owner = l_owner
      and    aq.name = l_name;

      select aqt.recipients, aqt.message_grouping
      into   WF_EVENT.pv_last_recipients, WF_EVENT.g_message_grouping
      from   all_queue_tables aqt
      where  aqt.queue_table = l_queue_table
      and    aqt.owner = l_owner;

      -- update package variables
      wf_event.pv_last_agent_name := agent_name;
      -- YOHUANG, l_queue_name shouldn't have owner information
      wf_event.pv_last_queue_name := l_name; --l_queue_name;
      wf_event.pv_last_schema_name := l_owner;
    else
      raise no_data_found;
    end if;
  end if;
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.GetAgentDetails.END',
                      'Get Agent Details');
  end if;
exception
  when no_data_found then
    -- let the caller handle it
     raise;
  when others then
    -- let the caller handle it
     raise;
end GetAgentDetails;
---------------------------------------------------------------------------
/*
 ** StartAgent - <described in WFEVENTS.pls>
 ** Though We cache the agent details, we still check if the agent and
 ** fixed name queues are started or not every time when listen() or
 ** listen_to_agent is called, just be conservative
 ** Bug 3659756
 **   Assume the fixed name queues are always started (if not, the component listener
 **   will error out and sys admin will fix it)
 **   Only start the agent that is being listened.
 **   Only start the agent once per session if agent name is not changed in the same session.
 */
procedure StartAgent(agent_name	  in	varchar2)
is
  -- l_enqueue_enabled   VARCHAR2(30);
  -- l_dequeue_enabled   VARCHAR2(30);

   --Bug 2307433
   --Cursor for obtaining the names of the
   --deferred and error queue.
   --Bug 3271311, add the WF_JAVA queues for start.
   --Bug 3659756, no longer start fixed name queues.
   /**
   CURSOR    q_disabled (schema varchar2) is
     SELECT  name
     FROM    all_queues
     WHERE   name in ('WF_DEFERRED', 'WF_ERROR', 'WF_JAVA_DEFERRED','WF_JAVA_ERROR')
     AND     owner =schema
     AND   ((trim(enqueue_enabled) = 'NO') OR (trim(dequeue_enabled) = 'NO'));
   */

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.StartAgent.Begin',
                      'Starting Agents');
  end if;
  --Bug 2307433
   --Enable the deferred and error queues for
   --enqueue and dequeue incase they are disabled
   --In any cases, the WF_DEFERRED, WF_ERROR, WF_JAVA_ERROR and WF_JAVA_DEFERRED
   --must be started.
   --schema := wf_core.translate('WF_SCHEMA');
   --Bug 3659756, no longer start fixed name queues.
   /*
   for q_name in q_disabled (wf_event.schema_name) loop
     DBMS_AQADM.START_QUEUE(wf_event.schema_name||'.'||q_name.name);
   end loop;
   */
   -- The agent details must be retrieved even for seeded queue.
  GetAgentDetails(agent_name);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_EVENT.StartAgent',
                       'dequeue_enabled = ' || WF_EVENT.pv_last_dequeue_enabled);
  end if;

  if (WF_EVENT.pv_last_dequeue_enabled = 'NO') then
  -- If the user has disabled the queue for enqueue don't override it.
  -- So we only enable the dequeue if dequeue is not enabled and we don't change
  -- the current setting of enqueue.

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_EVENT.StartAgent',
                           'starting queue = ' || wf_event.pv_last_schema_name
                            || '.' || wf_event.pv_last_agent_name);
    end if;

    DBMS_AQADM.START_QUEUE(wf_event.pv_last_schema_name || '.' || wf_event.pv_last_queue_name, FALSE);

    WF_EVENT.pv_last_dequeue_enabled := 'YES';
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT.StartAgent.End',
                      'Starting Agents');
  end if;
exception
  when no_data_found then
    wf_core.context('Wf_Event', 'StartAgent', agent_name);
    wf_core.raise('WFE_AGENT_NOTEXIST');
  when others then
    wf_core.context('Wf_Event', 'StartAgent', agent_name);
    raise;
end StartAgent;
---------------------------------------------------------------------------
/*
** Peek_Agent  - <Described in WFEVENTS.pls>
*/
FUNCTION Peek_Agent  (p_agent_name IN VARCHAR2)
         RETURN VARCHAR2
AS
  -- NOTE: This must be done in PL/SQL because in 8i DBMS_AQ.LISTEN is not
  -- supported in Java

  l_agent          sys.aq$_agent;
  l_agent_list     dbms_aq.aq$_agent_list_t;

  LISTEN_EXCEPTION exception;

  pragma exception_init(LISTEN_EXCEPTION, -25254);
BEGIN

  if p_agent_name is null then
    return 'N';
  end if;

  -- Perf bug 2987857
  -- If p_agent_name is same as pkg var, then details are not required
  -- to be retrieved again
  -- YOHUANG, move the cache validation logic into getAgentDetails

    -- Retrieve queue name for the agent
    -- Only local agents should be checked for - bug 2902048
    -- GetAgentDetails becomes the single source to start a particular agent
    -- and can be called without worrying about fixed name queues
    GetAgentDetails(p_agent_name);

  -- bug 2897326, agent_list is initialized differently for
  -- multi or single consumer queue

  IF wf_event.pv_last_recipients = 'MULTIPLE' THEN
    l_agent_list(1) := sys.aq$_agent(wf_event.pv_last_agent_name,
                                    wf_event.pv_last_schema_name || '.' || wf_event.pv_last_queue_name, null);
  ELSE
    l_agent_list(1) := sys.aq$_agent(null,
                                     wf_event.pv_last_schema_name || '.' || wf_event.pv_last_queue_name, null);
  END IF;

  -- "Listen" for messages on this queue
  BEGIN
    DBMS_AQ.Listen(agent_list => l_agent_list,
                   wait       => 0,
                   agent      => l_agent);
  EXCEPTION
  WHEN LISTEN_EXCEPTION THEN
      RETURN 'N';
  END;

  RETURN 'Y';
END Peek_Agent ;

-- GetParamListFromString
--   Takes a space delimited NAME=VALUE pairs of Subscription Parameters
--   string and returns a WF_PARAMETER_LIST_T
-- IN
--   p_parameters A string with space delimited name=value pairs
function GetParamListFromString(p_parameters in varchar2)
return wf_parameter_list_t
is
  l_parameters varchar2(5000);
  l_start      pls_integer := 0;
  l_end        pls_integer := 0;
  l_endposition number;
  l_namevalue  varchar2(4000);
  l_value      varchar2(4000);
  l_name       varchar2(4000);
  l_equalpos   number;
  l_param_list wf_parameter_list_t;
begin
  l_parameters := p_parameters;

  if (l_parameters is not null) then
    l_parameters := replace(l_parameters, wf_core.newline,' ');
    l_parameters := replace(l_parameters, wf_core.tab,' ');
    l_parameters := replace(l_parameters, wf_core.cr,'');
    l_parameters := l_parameters||' ';

    l_start:= 1;
    l_end := length(l_parameters);

    while (l_start < l_end) loop
      l_endposition := instr(l_parameters, ' ', l_start, 1);
      l_namevalue := rtrim(ltrim(substr(l_parameters, l_start, l_endposition-l_start)));

      l_equalpos := instr(l_namevalue, '=', 1, 1);
      l_name := substr(l_namevalue,1,l_equalpos-1);
      l_value := substr(l_namevalue,l_equalpos+1,length(l_namevalue));

      wf_event.AddParameterToList(l_name, l_value, l_param_list);
      l_start := l_endposition+1;
    end loop;
  end if;
  return l_param_list;
exception
  when others then
    wf_core.Context('WF_EVENT', 'GetParamListFromString');
    raise;
end GetParamListFromString;

  /* PRIVATE
   *
   * gets the agent's message_grouping, returns TRUE if TRANSACTIONAL, FALSE
   * otherwise.
   */
  function isValidToGroupMessages(p_agentName in varchar2) return boolean
  is
    l_msgGrouping varchar2(30);
  begin
    if (p_agentName is not null) then

      if(p_agentName <> wf_event.pv_last_agent_name) then
        GetAgentDetails(p_agentName);
      end if;

      return (WF_EVENT.g_message_grouping = 'TRANSACTIONAL');
    else
      return false;
    end if;
  exception
  when OTHERS then
    return false;
  end;

  -- for logging purposes
  function getNavigationParams return varchar2 is
    l_ret varchar2(1000):= 'navigation(';
  begin
    if (g_currentNavigation is null) then
      l_ret:= l_ret|| 'null), ';
    elsif g_currentNavigation= dbms_aq.NEXT_MESSAGE then
      l_ret:= l_ret|| 'NEXT_MESSAGE), ';
    elsif g_currentNavigation= dbms_aq.FIRST_MESSAGE then
      l_ret:= l_ret|| 'FIRST_MESSAGE), ';
    elsif g_currentNavigation= dbms_aq.NEXT_TRANSACTION then
      l_ret:= l_ret|| 'NEXT_TRANSACTION), ';
    else
      l_ret:= l_ret|| g_currentNavigation||'), ';
    end if;

    l_ret := l_ret|| ' threshold(';
    if (g_navResetThreshold is null) then
      l_ret:= l_ret|| 'null), ';
    else
      l_ret:= l_ret|| g_navResetThreshold||'), ';
    end if;

    l_ret := l_ret|| ' messageCount(';
    if (g_processedMessagesCount is null) then
      l_ret:= l_ret|| 'null), ';
    else
      l_ret:= l_ret|| g_processedMessagesCount||'), ';
    end if;

    l_ret := l_ret|| ' message grouping(';
    if (g_groupDequeuing) then
      l_ret:= l_ret|| 'TRUE)';
    else
      l_ret:= l_ret|| 'FALSE)';
    end if;

    return l_ret;
  end getNavigationParams;

  -- PUBLIC - see description in package spec
  procedure setNavigationParams(p_agentName in varchar2
                                   , p_navigationThreshold in number)
  is
    l_api varchar2(100) := g_packName||'setNavigationParams';
  begin
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_procedure, l_api,
               'BEGIN agent('||p_agentName||'), navigationThreshold(' ||
                     p_navigationThreshold||')');
    end if;

    -- if not parameters are passed, we assume it is a call from exception block,
    -- so we keep previous values IF ANY, except for g_processedMessagesCount
    if (p_agentName is not null) then
      -- 0 or positive are valid only
      if (p_navigationThreshold>0) then
        g_navResetThreshold := p_navigationThreshold;
      else
        g_navResetThreshold:=0; -- default behavior, no max threshold
      end if;

      g_groupDequeuing := isValidToGroupMessages(p_agentName);
      g_currentNavigation :=null;
    end if;

    g_processedMessagesCount :=0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_procedure, l_api,
                                                'END '||getNavigationParams);
    end if;
  end;

  -- PUBLIC - see description in package spec
  function getQueueNavigation return BINARY_INTEGER is
    l_ret BINARY_INTEGER;
    l_api varchar2(100) := g_packName||'getQueueNavigation';
  begin
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_procedure, l_api,
             'BEGIN '||getNavigationParams);
    end if;
    if (g_navResetThreshold is null)  then -- agent navigation not initialized
      -- since we don't know what is the component parameter, we assume default
      -- behavior
      g_navResetThreshold :=0;
    end if;

    -- TRANSACTIONAL dequeuing, no threshold logic
    if ( g_groupDequeuing ) then

      -- first call (g_processedMessagesCount = 0).
      -- If navigation params are not initialized, return FIRST_MESSAGE
      -- else return NEXT_MESSAGE
      if ( g_processedMessagesCount = 0 ) then
        if (g_currentNavigation is null) then
          l_ret := dbms_aq.FIRST_MESSAGE;
        else
          l_ret := dbms_aq.NEXT_TRANSACTION;
        end if;
      else
        l_ret := dbms_aq.NEXT_MESSAGE;
      end if;
    else -- no TRANSACTIONAL navigation, threshold logic applies

      -- If first call (g_processedMessagesCount = 0), or if threshold is
      -- reached, return FIRST_MESSAGE,
      -- else return NEXT_MESSAGE
      if ( g_processedMessagesCount = 0 ) or
         (g_navResetThreshold >0 and
                             g_ProcessedMessagesCount >= g_navResetThreshold)
      then
        g_processedMessagesCount := 0; -- reset counter, if threshold is reached
        l_ret := dbms_aq.FIRST_MESSAGE;
      else
        l_ret := dbms_aq.NEXT_MESSAGE;
      end if;
    end if;

    g_processedMessagesCount := g_processedMessagesCount + 1;
    g_currentNavigation := l_ret;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_procedure, l_api
                                          ,'END return='||getNavigationParams);
    end if;

    return l_ret;
  end;

  procedure resetNavigationParams
  is
  begin
    -- pass no parameters, just reset message counter
    setNavigationParams;
  end;

---------------------------------------------------------------------------
/*
** SetSystemGlobals - Populates System Global Variables
*/
begin
  wf_event.local_system_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

  wf_event.local_system_status := wf_core.translate('WF_SYSTEM_STATUS');

  select name into wf_event.local_system_name
  from wf_systems
  where guid = wf_event.local_system_guid;
---------------------------------------------------------------------------
  wf_event.schema_name := wf_core.translate('WF_SCHEMA');

  wf_event.pv_last_agent_name   := ' ';
  wf_event.pv_last_queue_name   := ' ';
  wf_event.pv_last_schema_name  := ' ';
  wf_event.pv_last_recipients   := ' ';
  wf_event.pv_last_dequeue_enabled := ' ';


end WF_EVENT;

/
