--------------------------------------------------------
--  DDL for Package Body WF_EVENT_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_FUNCTIONS_PKG" as
/* $Header: WFEVFNCB.pls 120.6.12010000.2 2009/02/18 05:44:56 skandepu ship $ */

------------------------------------------------------------------------------
/*
** PRIVATE global variable
*/
local_system_guid raw(16) := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
------------------------------------------------------------------------------
/*
** GENERATE	- Wrapper around event system packages generate procedure
**		  to make compliant with generic generate message api
*/
function GENERATE (
  P_EVENT_NAME     in    varchar2,
  P_EVENT_KEY      in    varchar2
) return clob is

msg   		clob;
dtd   		varchar2(32000);
l_parameters	t_parameters;

begin

  l_parameters := t_parameters(1,2);

  dbms_lob.createtemporary(msg, FALSE, DBMS_LOB.CALL);

  if p_event_name = 'oracle.apps.wf.event.system.create' then
    dtd := wf_systems_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.system.delete' then
    dtd := wf_systems_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.system.update' then
    dtd := wf_systems_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.agent.create' then
    dtd := wf_agents_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.agent.delete' then
    dtd := wf_agents_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.agent.update' then
    dtd := wf_agents_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.agentgroup.create' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
				2,'/');
    dtd := wf_agent_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.agentgroup.delete' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_agent_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.agentgroup.update' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_agent_groups_pkg.generate1(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.event.create' then
    dtd := wf_events_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.event.delete' then
    dtd := wf_events_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.event.update' then
    dtd := wf_events_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.group.create' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
				2,'/');
    dtd := wf_event_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.group.delete' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_event_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.group.update' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_event_groups_pkg.generate2(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.event.subscription.create' then
    dtd := wf_event_subscriptions_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.subscription.delete' then
    dtd := wf_event_subscriptions_pkg.generate(p_event_key);
  elsif p_event_name = 'oracle.apps.wf.event.subscription.update' then
    dtd := wf_event_subscriptions_pkg.generate(p_event_key);
  /** Start of Bug 2398759 to support Agent Groups **/
  elsif p_event_name = 'oracle.apps.wf.agent.group.create' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_agent_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.agent.group.delete' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_agent_groups_pkg.generate(l_parameters(1), l_parameters(2));
  elsif p_event_name = 'oracle.apps.wf.agent.group.update' then
    l_parameters := wf_event_functions_pkg.parameters(p_event_key,
                                2,'/');
    dtd := wf_agent_groups_pkg.generate(l_parameters(1), l_parameters(2));
  /** End of Bug 2398759 **/
  elsif p_event_name = 'oracle.apps.wf.event.all.sync' then
    wf_event_synchronize_pkg.CreateSyncClob(p_eventdata=>msg);
    --dbms_lob.append(msg, wf_event_synchronize_pkg.CreateSyncClob);
  else
    null;
  end if;

  IF dtd IS NOT NULL THEN
    dbms_lob.write(msg, length(dtd), 1, dtd);
  END IF;

  return (msg);

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'GENERATE', p_event_name,
                                                    p_event_key,
                                                    substr(dtd,1,100));
    raise;
end;
------------------------------------------------------------------------------
/*
** GENERATE	- calls the GENERATE function, ignoring the WF_PARAMETER_LIST_T
*/
function GENERATE (
  P_EVENT_NAME     in    varchar2,
  P_EVENT_KEY      in    varchar2,
  P_PARAMETER_LIST in    wf_parameter_list_t
) return clob is
begin
  return generate(p_event_name,
                  p_event_key);
end;
------------------------------------------------------------------------------
function RECEIVE (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out nocopy wf_event_t
) return varchar2 is
/*
** RECEIVE	- Wrapper around event system packages receive procedure
**		  to make compliant with generic receive api
*/

x_message 	varchar2(32000);
l_eventname	varchar2(240) := p_event.getEventName();
l_eventkey	varchar2(240) := p_event.getEventKey();
l_eventdata	clob	      := p_event.getEventData();
l_length 	integer;
l_start		number := 1;
l_end		number := 1;
l_result	varchar2(10);
l_parameters	t_parameters;

begin

  l_parameters := t_parameters(1,2);

  if (l_eventname <> 'oracle.apps.wf.event.all.sync'
      and l_eventname <> 'oracle.apps.wf.event.system.signup') then

    l_length := dbms_lob.getlength(l_eventdata);

    dbms_lob.read(l_eventdata, l_length,1,x_message);

    if l_eventname = 'oracle.apps.wf.event.system.create' then
      wf_systems_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.system.delete' then
      wf_systems_pkg.delete_row(l_eventkey);
    elsif l_eventname = 'oracle.apps.wf.event.system.update' then
      wf_systems_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.agent.create' then
      wf_agents_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.agent.delete' then
      wf_agents_pkg.delete_row(l_eventkey);
    elsif l_eventname = 'oracle.apps.wf.event.agent.update' then
      wf_agents_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.agent.group.create' then
      wf_agent_groups_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.agent.group.delete' then
      l_parameters := wf_event_functions_pkg.parameters(l_eventkey,
                                2,'/');
      wf_agent_groups_pkg.delete_row(l_parameters(1), l_parameters(2));
    elsif l_eventname = 'oracle.apps.wf.agent.group.update' then
      wf_agent_groups_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.event.create' then
      wf_events_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.event.delete' then
      wf_events_pkg.delete_row(l_eventkey);
    elsif l_eventname = 'oracle.apps.wf.event.event.update' then
      wf_events_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.group.create' then
      wf_event_groups_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.group.delete' then
      l_parameters := wf_event_functions_pkg.parameters(l_eventkey,
                                2,'/');
      wf_event_groups_pkg.delete_row(l_parameters(1), l_parameters(2));
    elsif l_eventname = 'oracle.apps.wf.event.group.update' then
      wf_event_groups_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.subscription.create' then
      wf_event_subscriptions_pkg.receive(x_message);
    elsif l_eventname = 'oracle.apps.wf.event.subscription.delete' then
      wf_event_subscriptions_pkg.delete_row(l_eventkey);
    elsif l_eventname = 'oracle.apps.wf.event.subscription.update' then
      wf_event_subscriptions_pkg.receive(x_message);
    else
      return('ERROR');
    end if;
  elsif l_eventname = 'oracle.apps.wf.event.all.sync' then
      wf_event_synchronize_pkg.uploadsyncclob(l_eventdata);
  elsif l_eventname = 'oracle.apps.wf.event.system.signup' then
      wf_event_synchronize_pkg.uploadsyncclob(l_eventdata);
  end if;

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  return(l_result);

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'RECEIVE', p_event.event_name,
                                                    p_subscription_guid);
    wf_event.setErrorInfo(p_event,'ERROR');
    return('ERROR');
end;
------------------------------------------------------------------------------
procedure SEND (
 P_EVENTNAME	in	varchar2,
 P_EVENTKEY	in	varchar2,
 P_EVENTDATA	in	clob,
 P_TOAGENT	in	varchar2,
 P_TOSYSTEM	in	varchar2,
 P_PRIORITY	in	number,
 P_SENDDATE	in	date
) is
/*
** SEND   -  Packages up parameters in wf_event_t and then calls
**	     wf_event.send()
*/

l_agent_t	wf_agent_t;
l_event_t       wf_event_t;

begin

  wf_event_t.initialize(l_event_t);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.Begin',
                      'Parameters:'||p_EventName||'*'||	p_EventKey||'*'||p_ToAgent||'*'||p_ToSystem);
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.Agent',
                      'Populating Agent...');
  end if;

  -- Populate the Agent
  l_agent_t := wf_agent_t (p_ToAgent, p_ToSystem);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.Address',
                      'Populating Address...');
  end if;

  -- Populate the Address
  l_event_t.Address(  pOutAgent => null,
                        pToAgent  => l_agent_t,
                        pPriority => 0,
                        pSendDate => sysdate);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.Content',
                      'Populating Content');
  end if;

  -- Populate the Content
  l_event_t.Content(  pName => p_EventName,
                        pKey  => p_EventKey,
                        pData => p_EventData);
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.Hardwire',
                      'Hardwired Send');
  end if;

  -- Release the hounds, hardwired send
  wf_event.send(l_event_t);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.SEND.End',
                      'Completed Send');
  end if;

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'SEND', p_EventName,
                                                    p_EventKey,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
function PARAMETERS (
 P_STRING	in	varchar2,
 P_NUMVALUES	in	number,
 P_SEPARATOR	in	varchar2)
return t_parameters is
/*
** PARAMETERS	- splices up a string and returns nested table
*/
l_parameters	t_parameters;
l_counter	integer;
l_endposition	integer;
l_startposition	integer;
l_amounttoread integer;

begin

 l_parameters    := t_parameters(1);
 l_counter       := 0;
 l_endposition   := 0;
 l_startposition := 0;
 l_amounttoread  := 0;

  LOOP
    l_counter := l_counter + 1;

    EXIT when l_counter > p_numvalues;

    l_startposition := l_endposition + 1;
    l_endposition := instr(p_string, p_separator, 1, l_counter);

    IF l_endposition = 0 THEN
	l_endposition := length(p_string) + 1;
    END IF;

    l_amounttoread := l_endposition - l_startposition;

    l_parameters.extend(1);
    l_parameters(l_counter) := substr(p_string, l_startposition, l_amounttoread);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_FUNCTIONS_PKG.PARAMETERS.get_pos',
                        'String:'||p_string||' Start:'||l_startposition||
                        ' End:'||l_endposition);
    end if;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_FUNCTIONS_PKG.PARAMETERS.get_param',
                        'Parameter('||l_counter||') is '||l_parameters(l_counter));
    end if;

  END LOOP;

  return(l_parameters);

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'Parameters', substr(p_string,1,100),
                                                    p_numvalues,p_separator,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
function ADDCORRELATION (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy wf_event_t
) return varchar2 is
/*
** ADDCORRELATION - This function adds a correlation id to the event object
*/

l_itemkey	varchar2(240);
l_result	varchar2(10);
l_parameters	varchar2(32000);
l_function	varchar2(240);
l_sqlstmt	varchar2(240);

CURSOR	c_parameters IS
SELECT	parameters
FROM    wf_event_subscriptions
WHERE   guid = p_subscription_guid;

begin

  OPEN c_parameters;
  FETCH c_parameters INTO l_parameters;
  IF c_parameters%FOUND THEN
  --
  -- This is where we will do some logic to determine if there is a parameter
  -- set which tells us which sequence to nextval to get the itemkey
  --
	l_function := wf_event_functions_pkg.SubscriptionParameters(l_parameters,
			'ITEMKEY');

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_procedure,
                        'wf.plsql.WF_EVENT_FUNCTIONS_PKG.ADDCORRELATION.Begin',
                        'Item Key function is '||l_function);
    end if;

	IF l_function IS NOT NULL THEN
		l_sqlstmt := 'begin :v1 := '||l_function||'; end;';
		EXECUTE IMMEDIATE l_sqlstmt USING in out l_itemkey;
	END IF;
  END IF;

  --
  -- If nothing found then just pass back date
  --
  IF l_itemkey IS NULL THEN
	l_itemkey := to_char(sysdate, 'YYYYMMDDHH24MISS');
  END IF;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_FUNCTIONS_PKG.ADDCORRELATION.Set',
                      'Item Key is '||l_itemkey);
  end if;

  p_event.SetCorrelationId(l_itemkey);

  return ('SUCCESS');

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'ADDCORRELATION', p_event.event_name,
                                                    p_event.event_key,
                                                    'ERROR'); raise;
    return('ERROR');
end;
------------------------------------------------------------------------------
function SUBSCRIPTIONPARAMETERS (
 P_STRING       in out nocopy varchar2,
 P_KEY          in      varchar2,
 P_GUID         in      raw default NULL
) return varchar2 is
/*
** SUBSCRIPTIONPARAMETERS - Reads through NAME=VALUE pairs looking for NAME
**                          to return VALUE
*/

l_string        varchar2(32000);
l_key           varchar2(32000);
l_start         integer := 0;
l_end           integer := 0;
l_value         varchar2(32000);

/* Bug 2015055 */
--cursor to fetch subscription parameters

CURSOR  c_parameters (c_guid raw) IS
SELECT  parameters
FROM    wf_event_subscriptions
WHERE   guid = c_guid;

begin

/* Bug 2015055 */
-- if p_guid is not null, event subscription parameters
-- is retrieved and based on the key the value is fetched
-- and returned.

  if p_guid is not NULL then
    OPEN c_parameters (p_guid);
    FETCH c_parameters INTO p_string;
    if c_parameters%NOTFOUND then
      p_string := NULL;
    end if;
  end if;

/* Bug 2167813 */
  l_string := ' ' || p_string || ' ';
  l_key := ' ' || p_key || '=';
  l_start := instr(l_string,l_key);
  if l_start = 0 then
     return NULL;
  end if;
  l_start := l_start + length(l_key);

  l_end := instr(l_string,' ',l_start);
  l_value := substr(l_string,l_start,l_end-l_start);

  return (l_value);

exception
  when others then
    wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'SUBSCRIPTIONPARAMETERS',
                                                    'ERROR'); raise;

end;

------------------------------------------------------------------------------
function SubParamInEvent(p_guid in raw,
                         p_event in out NOCOPY wf_event_t,
                         p_match in varchar2) return boolean

  is

    eqPOS    pls_integer;

    l_subParams     varchar2(32000);
    l_subParam      varchar2(4000);
    l_NumSubParams  pls_integer;
    l_NumEvtParams  pls_integer;
    l_EvtParamsIND  pls_integer;
    l_SubParamsIND  pls_integer;
    l_parameters    t_parameters;

    l_evtParam     varchar2(4000);
    found_match    boolean;


    unitialized_collection exception;
    PRAGMA exception_init(unitialized_collection, -06531);

  begin

    if (p_event is NULL) then
      return false;
    end if;

    l_parameters := t_parameters(NULL);
    eqPOS := 1;
    l_NumSubParams := 0;
    l_NumEvtParams := 0;

    select parameters into l_subParams
    from   wf_event_subscriptions
    where  guid = p_guid;

    -- Get a count on the subscription parameters.
    while (eqPOS  <> 0) loop

      eqPOS := instr(l_subParams, '=', eqPOS);

      if (eqPOS <> 0) then
        l_NumSubParams := l_NumSubParams + 1;

        eqPOS := eqPOS + 1;

      end if;

    end loop;


    -- First a broad check to see if the event and subscription both have or do
    -- not have any parameters.

    if (l_NumSubParams < 1) then
    -- If the subscription does not have any parameters, then we do not need to
    -- check the event, we will return TRUE.
      return TRUE;

    end if;

    -- If we made it here, the subscription does have parameters, we will now
    -- check the event.
    begin
      l_NumEvtParams := p_event.parameter_list.COUNT;

    exception
      when unitialized_collection then
        l_NumEvtParams := 0;

      when others then
        raise;

    end;

    if ((l_NumEvtParams < 1) and (l_NumSubParams > 0)) then
    -- If the event does not have any parameters, but the subscription does, we
    -- do not need to proceed further, we can go ahead and return FALSE.
      return FALSE;

    end if;

    -- If we made it here, both the event and subscription have parameters, so
    -- we need to start checking them.

    --Bug 3845922
    -- Clear cache that we uses to remove duplicate and other optimization
    -- within the loops below.
    WF_EVENT.sub_param_index.DELETE;
    WF_EVENT.evt_param_index.DELETE;

    l_parameters := Parameters(l_SubParams, l_NumSubParams, ' ');


    while (l_NumSubParams > 0) loop <<subscrLoop>> -- We will loop through the
                                                    -- subscription parameters.

      -- We will hash the subscription parameter and cache it

      l_SubParam := l_parameters(l_NumSubParams);
      l_subParamsIND := WF_CORE.HashKey(l_SubParam);
      l_NumSubParams := l_NumSubParams - 1;

      -- Here we check to see if we have already seen this subscription
      -- parameter.  If so, skip to the next.  If not, cache it and check
      -- the event parameters for a match.  This will eliminate processing
      -- duplicate subscription parameters.

      if (NOT (WF_EVENT.sub_param_index.EXISTS(l_subParamsIND)) or
          WF_EVENT.sub_param_index(l_subParamsIND) <> l_subParam) then

         -- Cache the subscription parameter since it is not in the cache.
         wf_event.sub_param_index(l_subParamsIND) := l_subParam;

         -- reset count of event parameters and found_match for next sub
         l_NumEvtParams := p_event.parameter_list.COUNT;
         found_match := FALSE;


         -- Sub loop through the event parameters
         while (l_NumEvtParams > 0) loop <<evtLoop>>

           -- Get the name value pair of the event parameter
           l_evtParam := p_event.parameter_list(l_NumEvtParams).getName||
                        '=' ||p_event.parameter_list(l_NumEvtParams).getValue;

           -- Hash value for the event name value pair
           l_evtParamsIND := WF_CORE.HashKey(l_evtParam);

           l_NumEvtParams := l_NumEvtParams-1;

           -- Check to see if the event parameter has already been cached.
           -- If not, check for a match. This will eliminate already
           -- matched event parameters.

           if (NOT (WF_EVENT.evt_param_index.EXISTS(l_evtParamsIND)) or
               WF_EVENT.evt_param_index(l_evtParamsIND) <> l_evtParam) then

              if (l_evtParamsIND = l_subParamsIND and
                      l_subParam = l_evtParam) then  -- Found match

                 if (p_match = 'ANY') then
                     return TRUE;
                 else
                     found_match := TRUE;

                 -- Cache event parameter
                    WF_EVENT.evt_param_index(l_evtParamsIND) := l_evtParam;

                 -- ALL must match so continue to next subParam
                    exit;
                 end if;

              end if;

            end if;

         end loop evtLoop;

         if ((p_match='ALL') and not(found_match)) then
             return FALSE;
         end if;

      end if;

    end loop subscrLoop;


      -- We've looped through all the subscription parameters and since
      -- we haven't failed to find a match then return true for ALL.
      -- For ANY if we haven't returned TRUE then a match hasn't been found.
      if (p_match = 'ANY') then
         return false;
      else
         return true;
      end if;

  exception
    when others then
      wf_core.context('WF_EVENT_FUNCTIONS_PKG', 'SubParamInEvent',
                                                      p_event.event_name);
    raise;

  end;



------------------------------------------------------------------------------
Procedure UpdateLicenseStatus (p_OwnerTag in varchar2, p_Status in varchar2)
is
    l_LicenseFlag varchar2(1):='N';
    l_appl_id number;
begin
    if p_Status in ('I','S') then
        l_LicenseFlag := 'Y';
    else
        begin
           select application_id
               into l_appl_id
           from  fnd_application
           where application_short_name = p_OwnerTag;

           If l_appl_id >= 20000 then
              l_LicenseFlag := 'Y';
           end if;
        exception
           when no_data_found then
                 null;
        end;
    end if;
-- Update all events and subscriptions with owner tag to product code
        update wf_events
        set licensed_flag = l_LicenseFlag
        where owner_tag = p_OwnerTag;

        update wf_event_subscriptions
        set licensed_flag = l_LicenseFlag
        where owner_tag = p_OwnerTag;

end UpdateLicenseStatus;


end WF_EVENT_FUNCTIONS_PKG;

/
