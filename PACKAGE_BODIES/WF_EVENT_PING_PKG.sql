--------------------------------------------------------
--  DDL for Package Body WF_EVENT_PING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_PING_PKG" as
/* $Header: WFEVPNGB.pls 120.1.12010000.3 2009/04/22 00:02:47 alepe ship $ */
------------------------------------------------------------------------------

-- Send PING and ACK to only WF addresses. For PINGing other addresses, this test
-- needs to be customized
CURSOR c_external_in_agents(p_agent in varchar2, p_system in varchar2) IS
SELECT  wfa.name AGENT,
	wfs.name SYSTEM
FROM	wf_systems wfs,
	wf_agents wfa
WHERE   wfa.name not in ('WF_ERROR', 'WF_DEFERRED')
and     wfa.name = nvl(p_agent, wfa.name)
and	wfa.status = 'ENABLED'
and	wfa.direction = 'IN'
and	wfa.system_guid = wfs.guid
and     upper(wfa.queue_handler) = 'WF_EVENT_QH'
and     wfa.name like 'WF%'
and     wfa.status = 'ENABLED'
and     wfs.name = nvl(p_system, wfs.name);

/*
 * Parameter pAgentName is expected in '<AGENT_NAME>@<SYSTEM>' format
 */
procedure ValidateOutAgent(pAgentName in out nocopy varchar2) is
  errorMsg varchar2(300);
  queName  varchar2(100);
  l_atsign number;
  l_agent_name wf_agents.name%type;
  l_sys_name   wf_systems.name%type;
begin

  -- OUTAGENT should not be null, will default to WF_OUT if so
  if (pAgentName is not null) then
    l_atsign := instr(pAgentName, '@');
    if (l_atsign is null) then
       -- Agent name provided by user is in incorrect format
       errorMsg := 'Out Agent name provided is in incorrect format. '||
                   'It should be in format AGENT_NAME@SYSTEM_NAME';
       raise_application_error(-20000,errorMsg);
    end if;
    l_agent_name := substr(pAgentName, 1, l_atsign-1);
    l_sys_name := substr(pAgentName, l_atsign+1);
  else
    l_agent_name := 'WF_OUT';
    l_sys_name := wf_event.local_system_name;
  end if;

  -- agent should exist, be enabled, be an OUT agent, and its queue handler be
  -- 'WF_EVENT_QH'
  begin
    SELECT a.name into queName
    FROM   wf_agents a,
           wf_systems s
    WHERE  a.direction = 'OUT'
    AND    a.status = 'ENABLED'
    AND    a.queue_handler = 'WF_EVENT_QH'
    AND    a.system_guid = s.guid
    AND    s.name = l_sys_name
    AND    a.name = l_agent_name;

    pAgentName := l_agent_name||'@'||l_sys_name;
  exception
  when NO_DATA_FOUND then
    -- initialize error
    errorMsg := 'Cannot progress workflow, because either: the agent '||
            pAgentName ||' is disabled, '||
            'it is not an OUT agent, or its queue handler is not WF_EVENT_QH '||
            '(for WF_EVENT_T payload type).';

    raise_application_error(-20000,errorMsg);
  when others then
    null;
    end;

end;

/*
** launch_processes - Loops through all external agents
*/
procedure LAUNCH_PROCESSES (
  ITEMTYPE	in	varchar2,
  ITEMKEY	in	varchar2,
  ACTID		in	number,
  FUNCMODE	in	varchar2,
  RESULTOUT	out nocopy varchar2
) is
------------------------------------------------------------------------------

l_eventname	varchar2(100);
l_eventkey	varchar2(240);
l_itemkey	varchar2(100);
l_event_t	wf_event_t;
l_msg		varchar2(32000);
l_clob		clob;
l_outAgent      varchar2(100);
l_toAgent       varchar2(100);
l_atsign        number;
l_to_agent_name wf_agents.name%type;
l_to_sys_name   wf_systems.name%type;
errorMsg        varchar2(300);
begin

if (funcmode = 'RUN') then

  l_outAgent := wf_engine.GetItemAttrText(itemtype => itemtype,
                        itemkey  => itemkey, aname => 'OUTAGENT');
  -- If Out Agent is provided, validate it
  ValidateOutAgent(l_outAgent);

  l_toAgent := wf_engine.GetItemAttrText(itemtype => itemtype,
                        itemkey  => itemkey, aname => 'TOAGENT');

  -- If To Agent is provided, validate it
  if (l_toAgent is not null) then
    l_atsign := instr(l_toAgent, '@');
    if (l_atsign is null) then
       -- Agent name provided by user is in incorrect format
       errorMsg := 'To Agent name provided is in incorrect format. '||
                   'It should be in format AGENT_NAME@SYSTEM_NAME';
       raise_application_error(-20000,errorMsg);
    end if;
    l_to_agent_name := substr(l_toAgent, 1, l_atsign-1);
    l_to_sys_name := substr(l_toAgent, l_atsign+1);
  end if;

  l_eventname := wf_engine.GetActivityAttrText(
                        itemtype => itemtype,
                        itemkey  => itemkey,
                        actid    => actid,
                        aname    => 'EVNTNAME');

  -- Get all To Agents to PING
  for x in c_external_in_agents(l_to_agent_name, l_to_sys_name) loop
    --
    -- For every agent launch detail process
    --
    l_eventkey := x.agent||'@'||x.system||'@'||itemkey;
    l_itemkey := l_eventkey;

    wf_engine.CreateProcess(
			itemtype => itemtype,
			itemkey  => l_itemkey,
			process  => 'WFDTLPNG');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                        itemkey  => l_itemkey, aname => 'OUTAGENT'
                      , avalue => l_outAgent);

    wf_engine.SetItemAttrText(
			itemtype => itemtype,
			itemkey  => l_itemkey,
			aname    => 'EVNTNAME',
			avalue   => l_eventname);

    wf_engine.SetItemAttrText(
                        itemtype => itemtype,
                        itemkey  => l_itemkey,
                        aname    => 'EVNTKEY',
                        avalue   => l_eventkey);

    wf_engine.SetItemAttrText(
                        itemtype => itemtype,
                        itemkey  => l_itemkey,
                        aname    => 'TOAGENT',
                        avalue   => x.agent||'@'||x.system);

    -- Initialise the wf_event_t
    wf_event_t.initialize(l_event_t);
    l_event_t.setcorrelationid(l_itemkey);
    l_msg := '<PING>Test Ping</PING>';
    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
    dbms_lob.write(l_clob, length(l_msg), 1 , l_msg);
    l_event_t.SetEventData(l_clob);

    wf_engine.SetItemAttrEvent(
			itemtype => itemtype,
                        itemkey  => l_itemkey,
			name	 => 'EVNTMSG',
			event   => l_event_t);

    wf_engine.SetItemParent(
			itemtype => itemtype,
			itemkey  => l_itemkey,
			parent_itemtype => itemtype,
			parent_itemkey  => itemkey,
			parent_context  => null);

    wf_engine.StartProcess(
			itemtype => itemtype,
			itemkey  => l_itemkey);

  end loop;

  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

  return;

elsif (funcmode = 'CANCEL') then

  null;

end if;

exception
  when others then
  WF_CORE.CONTEXT('WF_EVENT_PING_PKG', 'LAUNCH_PROCESSES', ITEMTYPE, ITEMKEY, to_char(ACTID), FUNCMODE);
  raise;
end LAUNCH_PROCESSES;
------------------------------------------------------------------------------
function ACKNOWLEDGE (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out nocopy wf_event_t
) return varchar2 is
------------------------------------------------------------------------------
l_fromagent	  wf_agent_t;
l_result	  varchar2(100);
l_returnagent	  wf_agents.name%type;
l_returnsys       wf_systems.name%type;
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.Begin',
                      ' Started');
  end if;

  l_returnsys := p_event.from_agent.system;

  -- Setting FROM AGENT for ACK message. Default to WF_OUT agent to
  -- send ACK message via
  l_fromagent := wf_agent_t ('WF_OUT', wf_event.local_system_name);
  p_event.SetFromAgent(l_fromagent);

  -- Setting TO AGENT for ACK message. ACK message back to originating system,
  -- we will pick first matching IN agent on the originating system, registered
  -- here in this system

  open c_external_in_agents(null, l_returnsys);
  fetch c_external_in_agents into l_returnagent, l_returnsys;
  close c_external_in_agents;

  p_event.to_agent.name := l_returnagent;
  p_event.to_agent.system := l_returnsys;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.ToAgent',
                      'To Agent:'||p_event.to_agent.name);
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.ToSystem',
                      'To System:'||p_event.to_agent.system);
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.FromAgent',
                      'From Agent:'||p_event.from_agent.name);
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.FromSystem',
                      'From System:'||p_event.from_agent.system);
  end if;

  p_event.SetEventName('oracle.apps.wf.event.test.ack');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.Send',
                      'Sending Event');
  end if;

  wf_event.send(
	p_event => p_event);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsqlWF_EVENT_PING_PKG.ACKNOWLEDGE.Sent',
                      ' Sent');
  end if;

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  return(l_result);

exception
  when others then
  WF_CORE.CONTEXT('WF_EVENT_PING_PKG','ACKNOWLEDGE',p_event.event_name,p_event.event_key, p_event.correlation_id);
  wf_event.setErrorInfo(p_event,'ERROR');
  return('ERROR');
end;

end WF_EVENT_PING_PKG;

/
