--------------------------------------------------------
--  DDL for Package Body WF_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_SETUP" as
/* $Header: wfevsetb.pls 115.17 2004/06/02 17:41:54 dlam ship $ */

function GetLocalSystemGUID
  return raw
is
  lguid varchar2(32);
begin
  select substr(TEXT, 1, 32) into lguid
    from WF_RESOURCES
   where NAME = 'WF_SYSTEM_GUID'
     and LANGUAGE = userenv('LANG');

  return hextoraw(lguid);
exception
  when no_data_found then
    wf_core.raise('WFE_NO_SYSTEM');
  when OTHERS then
    wf_core.context('WF_SETUP', 'GetLocalSystemGUID');
    raise;
end GetLocalSystemGUID;

function GetLocalSystem
  return varchar2
is
  lsys  varchar2(30);
begin
  select S.NAME into lsys
    from WF_SYSTEMS S, WF_RESOURCES R
   where R.NAME = 'WF_SYSTEM_GUID'
     and R.LANGUAGE = userenv('LANG')
     and S.GUID = hextoraw(R.TEXT);

  return (lsys);
exception
  when OTHERS then
    wf_core.context('WF_SETUP', 'GetLocalSystem');
    raise;
end GetLocalSystem;

procedure Check_InitParameters
is
  cursor pcurs is
    select NAME, VALUE
      from v$parameter
     where NAME in ('aq_tm_processes', 'job_queue_processes',
                    'job_queue_interval')
     order by NAME;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;
  vTab wfe_html_util.tmpTabType;

begin
  -- set the recommended values
  i := 1;
  vTab(i) := '1';  -- for aq_tm_processes
  i := i+1;
  vTab(i) := '5';  -- for job_queue_interval
  i := i+1;
  vTab(i) := '2';  -- for job_queue_processes

  i := 0;
  for pr in pcurs loop
    i := i+1;
    dTab(i).col01 := pr.name;
    dTab(i).col02 := pr.value;
    if (i <= 3) then
      dTab(i).col03 := vTab(i);
    end if;

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := FALSE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).attr     := 'id="t_name"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('VALUE');
  hTab(i).attr     := 'ALIGN=RIGHT id="t_value"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('VALUE_RECOMMENDED');
  hTab(i).attr     := 'ALIGN=RIGHT id="t_value_rec"';

  htp.p('<p><b>'||wf_core.translate('WFE_INITPARAMS')||'</b>');
  -- ### Database Init.ora Parameters

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

exception
  when OTHERS then
    wf_core.context('WF_SETUP', 'Check_InitParameters');
    wfe_html_util.Error;
end Check_InitParameters;

procedure Check_Dblinks(
  localsguid  raw
)
is
  -- all db link
  cursor dblcurs is
    select distinct substr(ADDRESS, instr(ADDRESS, '@')+1) NAME
      from WF_AGENTS
     where PROTOCOL = 'SQLNET'
       and DIRECTION = 'IN'
       and SYSTEM_GUID <> localsguid;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

begin
  -- populate the data table
  i := 0;
  for dblr in dblcurs loop
    i := i+1;
    dTab(i).guid := null;
    dTab(i).col01:= dblr.name;

    -- find out if such dblr.name exists
    begin
      select 'EXIST' into dTab(i).col02
        from sys.dual
       where upper(dblr.name) in (
           select DB_LINK from USER_DB_LINKS
           union all
           select DB_LINK from ALL_DB_LINKS
            where OWNER = 'PUBLIC');
    exception
      when NO_DATA_FOUND then
        dTab(i).col02 := 'NOT_EXIST';

      when OTHERS then
        raise;
    end;
    dTab(i).col02 := wf_core.translate(dTab(i).col02);

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := FALSE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).attr     := 'id="t_name"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('STATUS');
  hTab(i).attr     := 'id="t_status"';

  htp.p('<p><b>'||wf_core.translate('WFE_DBLINKS')||'</b>');
  -- ### Database Links

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Check_Dblinks');
    wfe_html_util.Error;
end Check_Dblinks;


procedure Check_Queues(
  localsguid  raw
)
is
  cursor lquecurs is
    select A.GUID, A.NAME, A.DIRECTION, A.QUEUE_NAME
      from WF_AGENTS A
     where A.SYSTEM_GUID = localsguid
       and A.PROTOCOL = 'SQLNET';

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  include_create  boolean := FALSE;
  creatable       boolean;
  l_qid           number;
begin
null;
  -- populate the data table
  i := 0;
  for lquer in lquecurs loop
    i := i+1;
    dTab(i).guid := lquer.guid;
    dTab(i).col01:= lquer.name;
    if (lquer.direction is null) then
      dTab(i).col02:= '&nbsp';
    else
      dTab(i).col02:= wf_core.translate(lquer.direction);
    end if;
    dTab(i).col03:= nvl(lquer.queue_name, '&nbsp');

    -- check existence
    creatable := FALSE;
    begin
      select DQ.QID
        into l_qid
        from ALL_QUEUES DQ
       where lquer.queue_name = DQ.OWNER||'.'||DQ.NAME
         and QUEUE_TYPE = 'NORMAL_QUEUE';

      dTab(i).col04 := 'YES';
    exception
      when NO_DATA_FOUND then
        dTab(i).col04 := 'NO';
        creatable := TRUE;

      when OTHERS then
        raise;
    end;
    dTab(i).col04 := wf_core.translate(dTab(i).col04);

    -- if queue not exist, do not count message
    if (creatable) then

      dTab(i).col05 := '-';
      dTab(i).col06 := '-';

    -- find out the message count
    else
      begin
        select to_char(v.ready), to_char(v.waiting)
          into dTab(i).col05, dTab(i).col06
          from gv$aq v
         where v.qid = l_qid;

      exception
        when NO_DATA_FOUND then
          dTab(i).col05 := '-';
          dTab(i).col06 := '-';
      end;
    end if;

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := FALSE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('AGENT');
  hTab(i).attr     := 'id="t_agent"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('DIRECTION');
  hTab(i).attr     := 'id="t_direction"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('QUEUE_NAME');
  hTab(i).attr     := 'id="t_queue"';
  i := i + 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('QUEUE_CREATED');
  hTab(i).attr     := 'id="t_queue_created"';
  i := i + 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('MESSAGE_READY');
  hTab(i).attr     := 'ALIGN=RIGHT id="t_message_ready"';
  i := i + 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('MESSAGE_WAIT');
  hTab(i).attr     := 'ALIGN=RIGHT id="t_message_wait"';

  htp.p('<p><b>'||wf_core.translate('WFE_LOCAL_QUEUES')||'</b>');
  -- ### Local Agents

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Check_Queues');
    wfe_html_util.Error;
end Check_Queues;


procedure Check_Listeners(
  localsguid  raw
)is
  -- find all local queues that have direction of IN, ANY or undefined
  cursor lqcurs is
    select A.GUID, A.NAME
      from WF_AGENTS A
     where A.SYSTEM_GUID = localsguid
       and A.PROTOCOL = 'SQLNET'
       and A.STATUS = 'ENABLED'
       and (A.DIRECTION is null or A.DIRECTION in ('IN', 'ANY'));

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  creatable       boolean;
  jobnum          number;

begin
  null;
  -- populate the data table
  i := 0;
  for lqr in lqcurs loop
    i := i + 1;
    dTab(i).guid := lqr.guid;
    dTab(i).col01:= lqr.name;

    -- check existence
    creatable := FALSE;
    begin
      -- lqr.name came from WF_AGENTS.NAME
      -- BINDVAR_SCAN_IGNORE[6]
      select 'YES'
        into dTab(i).col02
        from WF_ALL_JOBS
       where upper(substr(WHAT, 1, 60))
             like 'WF_EVENT.LISTEN('''||lqr.name||''')%'
         and rownum < 2;
    exception
      when NO_DATA_FOUND then
        dTab(i).col02 := 'NO';
        creatable := TRUE;

      when OTHERS then
        raise;
    end;
    dTab(i).col02 := wf_core.translate(dTab(i).col02);

    -- append creation function
    if (creatable) then
      dTab(i).col03 := dTab(i).col03||
        '<a href='||wfa_html.base_url||'/wf_setup.edit_listener?aguid='||
        rawtohex(lqr.guid)||'>'||
        wf_core.translate('CREATE')||
        '</a>';
    else
      dTab(i).col03 := dTab(i).col03||
        '<a href='||wfa_html.base_url||'/wf_setup.list_listener?aguid='||
        rawtohex(lqr.guid)||'>'||
        wf_core.translate('EDIT')||
        '</a>';
    end if;

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := FALSE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('AGENT');
  hTab(i).attr     := 'id="t_agent"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SCHEDULED');
  hTab(i).attr     := 'id="t_scheduled"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('ACTION');
  hTab(i).attr     := 'id="t_action"';

  htp.p('<p><b>'||wf_core.translate('WFE_LISTENERS')||'</b>');
  -- ### Listeners for local queues.

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Check_Listeners');
    wfe_html_util.Error;
end Check_Listeners;


procedure Check_Propagations(
  localsguid  raw
)is

  -- propagation for local system
  cursor ppgcurs is
    select OA.GUID OGUID,
           OA.NAME,
           OA.QUEUE_NAME OQUEUE,
           upper(substr(TA.ADDRESS, instr(TA.ADDRESS, '@')+1)) TOSYSTEM
      from WF_AGENTS OA, WF_AGENTS TA
     where OA.SYSTEM_GUID = localsguid
       and OA.PROTOCOL = 'SQLNET'
       and OA.DIRECTION = 'OUT'
       and TA.SYSTEM_GUID <> localsguid
       and TA.PROTOCOL = 'SQLNET'
       and TA.DIRECTION = 'IN'
       and TA.ADDRESS IS NOT NULL
       and TA.NAME <> 'WF_ERROR'
       and TA.SYSTEM_GUID in (select GUID from WF_SYSTEMS)
    union
    -- propgation to a local queue
    select A.GUID OGUID,
           A.NAME,
           A.QUEUE_NAME OQUEUE,
           NULL TOSYSTEM
      from WF_AGENTS A
     where A.SYSTEM_GUID = localsguid
       and A.PROTOCOL = 'SQLNET'
       and A.DIRECTION = 'OUT'
       order by TOSYSTEM;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  creatable       boolean;

begin
  -- populate the data table
  i := 0;
  for ppgr in ppgcurs loop
    i := i + 1;
    dTab(i).guid := ppgr.oguid;
    dTab(i).col01:= ppgr.name;
    dTab(i).col02:= nvl(ppgr.tosystem,wf_core.translate('LOCAL')); -- in reality it is a db link
    --dTab(i).col02:= nvl(ppgr.tosystem, '&nbsp'); -- in reality it is a db link

    -- check out queue
    begin
      select NAME
        into dTab(i).col03
        from WF_AGENTS
       where GUID = ppgr.oguid
         and (PROTOCOL <> 'SQLNET'
           or (DIRECTION is not null and DIRECTION = 'IN'));

       wf_core.token('NAME', dTab(i).col03);
       dTab(i).col03 := wf_core.translate('WFE_NOT_OUTAGENT');
    exception
      when NO_DATA_FOUND then
        null;
    end;

    -- check system (dblink) exist
    -- ### maybe in the future.  Assume it exists for now.

    -- check existence
    creatable := FALSE;
    if (dTab(i).col03 is null) then
      begin
        select null
          into dTab(i).col03
          from sys.dual
         where exists (
           select NULL
             from DBA_QUEUE_SCHEDULES QS
            where QS.DESTINATION = nvl(ppgr.tosystem, 'AQ$_LOCAL')
              and QS.SCHEMA||'.'||QS.QNAME = ppgr.oqueue);
      exception
        when NO_DATA_FOUND then
          creatable := TRUE;
      end;

      --if ppgr.tosystem = wf_core.translate('LOCAL') then
      --  ppgr.tosystem := null;
      --end if;

      if (creatable) then
        dTab(i).col03 :=
          '<a href='||wfa_html.base_url||
          '/wf_setup.edit_propagation?oqueue='||ppgr.oqueue
          ||'&tosystem='||ppgr.tosystem
          ||'&edit=N'
          ||'>'||
          wf_core.translate('CREATE')||
          '</a>';
      else
        dTab(i).col03 :=
          '<a href='||wfa_html.base_url||
          '/wf_setup.edit_propagation?oqueue='||ppgr.oqueue
          ||'&tosystem='||ppgr.tosystem
          ||'&edit=Y'
          ||'>'||
          wf_core.translate('EDIT')||
          '</a>';
      end if;
    end if;

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := FALSE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('OUT_AGENT');
  hTab(i).attr     := 'id="t_out_agent"';
  i := i + 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('WFE_DBLINK');
  hTab(i).attr     := 'id="t_dblink"';
  i := i + 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SCHEDULE');
  hTab(i).attr     := 'id="t_schedule"';

  htp.p('<p><b>'||wf_core.translate('WFE_PROPAGATIONS')||'</b>');
  -- ### Propagations for local out agents.

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Check_Propagations');
    wfe_html_util.Error;
end Check_Propagations;

procedure Check_All
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  l_systems number;

  lguid raw(16);
  lsys  varchar2(30);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- Check if Accessible
  wf_event_html.isAccessible('SYSTEM');

  lguid := Wf_Setup.GetLocalSystemGUID;
  lsys  := Wf_Setup.GetLocalSystem;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after edit, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_CHECK_ALL_TITLE')||'('||lsys||')');
  wfa_html.create_help_function('wf/links/evt.htm?'||'EVTSETUP');
  fnd_document_management.get_open_dm_display_window;
  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            NULL,
            wf_core.translate('WFE_CHECK_ALL_TITLE')||'('||lsys||')',
            TRUE);

  htp.br;  -- add some space between header and table

  Wf_Setup.Check_InitParameters;
  htp.br;

  Wf_Setup.Check_Dblinks(lguid);
  htp.br;

  Wf_Setup.Check_Queues(lguid);
  htp.br;

  Wf_Setup.Check_Listeners(lguid);
  htp.br;

  Wf_Setup.Check_Propagations(lguid);
  htp.br;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Check_All');
    wfe_html_util.Error;
end Check_All;

-- ###
-- Create_Queue is not used for now
--
procedure Create_Queue(
  aguid  in raw
)is
  lguid  raw(16);
  sguid  raw(16);
  qname  varchar2(30);
  qtable varchar2(30);

  l_msg  varchar2(4000);

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- check system is local
  lguid := Wf_Setup.GetLocalSystemGUID;

  begin
    select SYSTEM_GUID, substr(QUEUE_NAME,1,30)
      into sguid, qname
      from WF_AGENTS
     where GUID = aguid;
  exception
    when OTHERS then
      wf_core.raise('WFE_AGENT_NOTEXIST');
  end;

  qtable := substr(qname,1,24)||'_TABLE';

  if (lguid <> sguid) then
    wf_core.token('ENTITY', 'QUEUE');
    wf_core.raise('WFE_SYSTEM_NOTLOCAL');
  end if;

  -- create queue table
  dbms_aqadm.create_queue_table
  (
   queue_table          => qtable,
   queue_payload_type   => wf_core.translate('WF_SCHEMA')||'.WF_EVENT_T',
   sort_list            => 'ENQ_TIME',
   comment              => 'Workflow event system default queue',
   compatible           => '8.1',
   multiple_consumers   => TRUE
  );

  -- create queue
  dbms_aqadm.create_queue
  (
   queue_name           => qname,
   queue_table          => qtable
  );

  -- start queue
  dbms_aqadm.start_queue
  (
   queue_name           => qname
  );

  commit;

  -- go back to check_all
  Wfe_Html_Util.gotoURL(p_url=>wfa_html.base_url||'/Wf_Setup.Check_All');

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Create_Queue', rawtohex(aguid),
                    qname, qtable);
    wfe_html_util.Error;
end Create_Queue;

--
-- List_Listener
--   List the content of DBMS_JOB for a local agent
--
procedure List_Listener(
  aguid  in raw
) is
  -- nm came from WF_AGENTS.NAME
  -- BINDVAR_SCAN_IGNORE[4]
  cursor jobc(nm varchar2) is
    select JOB, WHAT, upper(INTERVAL) interval
      from WF_ALL_JOBS
     where upper(WHAT) like 'WF_EVENT.LISTEN('''||nm||''');';

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  aname  varchar2(30);
  lguid  raw(16);

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  l_url  varchar2(2000);

  l_aguid raw(16);
  cookie owa_cookie.cookie;
  --  bad_cookie exception;     -- Syntax error in cookie

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- get it from the cookie if aguid is not set
  if (aguid is null) then
    cookie := owa_cookie.get('WF_AGENT_GUID');
    if (cookie.num_vals <> 1) then
      wf_core.raise('WFE_NO_COOKIE');
    end if;
    l_aguid := hextoraw(cookie.vals(1));
  else
    l_aguid := aguid;

    -- Send parameter values back to cookie.
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send('WF_AGENT_GUID', l_aguid);
    owa_util.http_header_close;
  end if;

  -- get local system
  lguid := Wf_Setup.GetLocalSystemGUID;

  -- check agent is local
  begin
    select NAME
      into aname
      from WF_AGENTS
     where GUID = l_aguid
       and SYSTEM_GUID = lguid;
  exception
    when OTHERS then
      wf_core.raise('WFE_AGENT_NOTEXIST');
  end;

  i := 0;
  for jobr in jobc(aname) loop
    i := i+1;
    dTab(i).guid  := hextoraw(to_char(jobr.JOB));
    dTab(i).col01 := jobr.WHAT;
    dTab(i).col02 := jobr.INTERVAL;

    dTab(i).selectable := FALSE;
    dTab(i).deletable  := TRUE;
    dTab(i).hasdetail  := FALSE;
  end loop;

  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Setup.DeleteJob?h_url='||
                      wfa_html.base_url||'/Wf_Setup.List_Listener&h_job=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := null;
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Setup.Edit_Listener?aguid='||rawtohex(l_aguid)
    ||'&url='
    ||wfa_html.base_url||'/Wf_Setup.List_Listener&jobnum=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- no detail title
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EDIT');
  hTab(i).attr     := 'id="t_edit"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('WHAT');
  hTab(i).attr     := 'id="t_what"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('INTERVAL');
  hTab(i).attr     := 'id="t_interval"';

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- List does not get updated after edit, so we add the
  -- following tag to force the reload of page.
  -- Note that we do not expire the first page where the cookie is set.
  -- Setting cookie will refresh the page upon next visit.
  if (aguid is null) then
    htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');
  end if;

  htp.title(wf_core.translate('WFE_LIST_LISTENERS_TITLE'));
  wfa_html.create_help_function('wf/links/def.htm?'||'DEFLSNR');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            NULL,
            wf_core.translate('WFE_LIST_LISTENERS_TITLE'),
            TRUE);

  htp.br;  -- add some space between header and table

  Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab);

  htp.tableopen (calign=>'CENTER summary=""');
  htp.tableRowOpen;
  htp.p('<TD id="">');

  -- construct the url for adding listener
  l_url := wfa_html.base_url||'/Wf_Setup.Edit_Listener?aguid='
           ||rawtohex(l_aguid)
           ||'&url='||wfa_html.base_url||'/Wf_Setup.List_Listener';

  wfa_html.create_reg_button (l_url,
                              wf_core.translate('ADD'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('ADD'));
  htp.p('</TD>');

  -- Cancel button
  htp.p('<TD id="">');
  wfa_html.create_reg_button ('javascript:window.history.back()',
                                wf_core.translate('CANCEL'),
                                wfa_html.image_loc,
                                'FNDJLFCN.gif',
                                wf_core.translate('CANCEL'));
  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    wf_core.context('WF_SETUP', 'List_Listener', rawtohex(l_aguid));
    wfe_html_util.Error;
end List_Listener;

--
-- Edit_Listener
--   Edit/Create a listener for agent provided
--   if jobnum is not null, it is editing an existing job.
--   if url is provided, return to the url specified, otherwise, to check_all.
--
procedure Edit_Listener(
  aguid  in raw,
  jobnum in pls_integer ,
  url    in varchar2
)is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  aname  varchar2(30);
  lguid  raw(16);

  l_curpos pls_integer;
  l_nxtpos pls_integer;

  l_url  varchar2(2000);
  l_interval varchar2(2000);

  cursor jobc(x_jobnum pls_integer) is
    select NEXT_DATE, upper(INTERVAL) interval
      from WF_ALL_JOBS
     where job = x_jobnum;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- get local system
  lguid := Wf_Setup.GetLocalSystemGUID;

  -- check agent is local
  begin
    select NAME
      into aname
      from WF_AGENTS
     where GUID = aguid
       and SYSTEM_GUID = lguid;
  exception
    when OTHERS then
      wf_core.raise('WFE_AGENT_NOTEXIST');
  end;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  htp.title(wf_core.translate('WFE_EDIT_LISTENER_TITLE'));
  wfa_html.create_help_function('wf/links/t_d.htm?'||'T_DEFLSNR');

  fnd_document_management.get_open_dm_display_window;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, wf_core.translate('WFE_EDIT_LISTENER_TITLE'),
                 TRUE);

  -- Form
  l_url := 'Wf_Setup.SubmitListener';
  htp.formOpen(curl=>owa_util.get_owa_service_path||l_url,
               cmethod=>'Post',
               cattributes=>'TARGET="_top" NAME="WF_LSNR_EDIT"');

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary="' ||
                WF_CORE.Translate('WFE_EDIT_LISTENER_TITLE') || '"');

  -- Agent Name (non-editable)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('AGENT'),
                calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<b>'||aname||'</b>', calign=>'left',
                cattributes=>'id=""');
  if (jobnum < 0) then
    htp.formHidden('h_job', null);
  else
    htp.formHidden('h_job', to_char(jobnum));
  end if;
  htp.formHidden('h_name', aname);
  htp.tableRowClose;

  -- Run Date (default sysdate when left blank)
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_rundate">' ||
                        wf_core.translate('RUN_DATE') ||
                        '</LABEL>', calign=>'right', cattributes=>'id=""');

  htp.tableData(cvalue=>htf.formText('h_rundate',19,
                                      cattributes=>'id="i_rundate"')||' ('||
                wf_engine.date_format||')', calign=>'left',
                cattributes=>'id=""');
  htp.tableRowClose;

  -- Interval (default 0 day 0 hour 15 min 0 sec)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('RUN_EVERY'),
                calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_day',3 )
                        ||' '||wf_core.translate('DAYS') || '</LABEL>'
                , calign=>'left', cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'&nbsp', calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_hour',3)
                        ||' '||wf_core.translate('HOURS') || '</LABEL>'
                , calign=>'left', cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'&nbsp', calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_minute',3)
                        ||' '||wf_core.translate('MINUTES') || '</LABEL>'
                , calign=>'left', cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'&nbsp', calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_sec',3)
                        ||' '||wf_core.translate('SECONDS') || '</LABEL>'
                , calign=>'left', cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;

  -- go back to the specified URL
  -- if url is null, go back to check_all
  if (url is null) then
    htp.formHidden('h_url',wfa_html.base_url||'/Wf_Setup.Check_All');
  else
    htp.formHidden('h_url',url);
  end if;

  htp.formClose;

  -- figure out the interval if we are editing
  htp.p('<SCRIPT>');
  for jobr in jobc(jobnum) loop
    htp.p('  document.WF_LSNR_EDIT.h_rundate.value="'
          ||to_char(jobr.next_date, wf_engine.date_format)||'"');

    if (instr(jobr.interval,'JOBNEXTRUNDATE(') <> 0) then
      l_curpos := instr(jobr.interval,',')+1;
      l_nxtpos := instr(jobr.interval,')');
      l_interval := substr(jobr.interval,l_curpos,l_nxtpos-l_curpos);
    end if;
  end loop;

  -- l_interval looks like 'DD,HH,MI,SS'
  if (l_interval is not null) then
    l_curpos := 1;
    l_nxtpos := instr(l_interval,',');
    htp.p('  document.WF_LSNR_EDIT.h_day.value="'||
          substr(l_interval,l_curpos,l_nxtpos-l_curpos)||'"');
    l_curpos := l_nxtpos+1;
    l_nxtpos := instr(l_interval,',',1,2);
    htp.p('  document.WF_LSNR_EDIT.h_hour.value="'||
          substr(l_interval,l_curpos,l_nxtpos-l_curpos)||'"');
    l_curpos := l_nxtpos+1;
    l_nxtpos := instr(l_interval,',',1,3);
    htp.p('  document.WF_LSNR_EDIT.h_minute.value="'||
          substr(l_interval,l_curpos,l_nxtpos-l_curpos)||'"');
    l_curpos := l_nxtpos+1;
    htp.p('  document.WF_LSNR_EDIT.h_sec.value="'||
          substr(l_interval,l_curpos)||'"');
  end if;

  htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  -- Submit button
  htp.p('<TD id="">');
  wfa_html.create_reg_button ('javascript:document.WF_LSNR_EDIT.submit()',
                              wf_core.translate ('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('SUBMIT'));
  htp.p('</TD>');

  -- Cancel button
  htp.p('<TD id="">');
  wfa_html.create_reg_button ('javascript:window.history.back()',
                                wf_core.translate('CANCEL'),
                                wfa_html.image_loc,
                                'FNDJLFCN.gif',
                                wf_core.translate('CANCEL'));
  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

  commit;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Edit_Listener', rawtohex(aguid));
    wfe_html_util.Error;
end Edit_Listener;

procedure Edit_Propagation(
  oqueue   in varchar2,
  tosystem in varchar2,
  edit     in varchar2 ,
  url      in varchar2
)is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  qname  varchar2(30);
  sname  varchar2(80);
  l_url  varchar2(2000);
  l_nexttime varchar2(2000);

  cursor ppgnc(x_qname varchar2, x_system varchar2) is
    select PROPAGATION_WINDOW, upper(NEXT_TIME) NEXT_TIME, LATENCY
      from DBA_QUEUE_SCHEDULES
     where DESTINATION = nvl(x_system, 'AQ$_LOCAL')
       and SCHEMA||'.'||QNAME = x_qname;

  l_pos pls_integer;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  htp.title(wf_core.translate('WFE_EDIT_PROPAGATION_TITLE'));
  wfa_html.create_help_function('wf/links/t_e.htm?'||'T_EPPGN');

  fnd_document_management.get_open_dm_display_window;


  -- verify function
  -- having the (1 * value) to force the values to be compared as numbers
  htp.p('<SCRIPT LANGUAGE="JavaScript">');
  htp.p('<!-- Hide from old browsers');
  htp.p('function verify(msg) {
           if (document.WF_PPGN_EDIT.h_interval.value == "" ||
               document.WF_PPGN_EDIT.h_duration.value == "" ||
               ((1 * document.WF_PPGN_EDIT.h_interval.value) >
                (1 * document.WF_PPGN_EDIT.h_duration.value))
              ) {
             document.WF_PPGN_EDIT.submit();
           } else {
             window.alert(msg);
           }
        }');
  htp.p('<!-- done hiding from old browsers -->');
  htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');


  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, wf_core.translate('WFE_EDIT_PROPAGATION_TITLE'),
                 TRUE);

  -- Form
  l_url := 'Wf_Setup.SubmitPropagation';
  htp.formOpen(curl=>owa_util.get_owa_service_path||l_url,
               cmethod=>'Post',
               cattributes=>'TARGET="_top" NAME="WF_PPGN_EDIT"');

  htp.tableOpen(calign=>'CENTER',
               cattributes=>'border=0 summary="' ||
                            WF_CORE.Translate('WFE_EDIT_PROPAGATION_TITLE') ||
                            '"');

  -- Queue Name (non-editable)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('QUEUE'), calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>'<b>'||oqueue||'</b>', calign=>'left',
                cattributes=>'id=""');
  htp.formHidden('h_qname', oqueue);
  htp.tableRowClose;

  -- To Database Link Name (non-editable)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('WFE_DBLINK'), calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>'<b>'||nvl(tosystem,wf_core.translate('LOCAL_SYSTEM'))
                        ||'</b>', calign=>'left', cattributes=>'id=""');
  htp.formHidden('h_system', tosystem);
  htp.tableRowClose;

  -- Duration (default null)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('DURATION'), calign=>'right', cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_duration',4)||'&nbsp '
                        ||wf_core.translate('SECONDS') || '</LABEL>',
                calign=>'left');
  htp.tableRowClose;

  -- Interval (default null)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('RUN_EVERY'), calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_interval',4)||'&nbsp '
                        ||wf_core.translate('SECONDS') || '</LABEL>',
                calign=>'left', cattributes=>'id=""');
  htp.tableRowClose;

  -- Latency (default 60sec)
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('LATENCY'), calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>'<LABEL>' || htf.formText('h_latency',4)||'&nbsp '
                        ||wf_core.translate('SECONDS') || '</LABEL>',
                calign=>'left');
  htp.tableRowClose;

  htp.tableClose;

  htp.formHidden('h_edit',edit);

  -- go back to the specified URL
  -- if url is null, go back to check_all
  if (url is null) then
    htp.formHidden('h_url',wfa_html.base_url||'/Wf_Setup.Check_All');
  else
    htp.formHidden('h_url',url);
  end if;

  -- action: DELETE/NULL
  htp.formHidden('h_action');

  htp.formClose;

  -- figure out the interval if we are editing
  if (edit = 'Y') then
    htp.p('<SCRIPT>');
    for ppgnr in ppgnc(oqueue, tosystem) loop
      htp.p('  document.WF_PPGN_EDIT.h_duration.value="'
            ||to_char(ppgnr.propagation_window)||'"');

      -- assume we are parsing these standard formats
      --   SYSDATE + (interval/86400) - (duration/86400)
      --   SYSDATE + (interval/86400)
      --   SYSDATE - (duration/86400)

      l_pos := instr(ppgnr.next_time, 'SYSDATE');
      if (l_pos <> 0) then
        l_pos := instr(ppgnr.next_time, '+');
        if (l_pos <> 0) then
          l_nexttime := substr(ppgnr.next_time, instr(ppgnr.next_time, '(')+1);
          l_pos := instr(l_nexttime, '/');
          htp.p('  document.WF_PPGN_EDIT.h_interval.value="'
                ||substr(l_nexttime,1,l_pos-1)||'"');
        end if;
      end if;

      htp.p('  document.WF_PPGN_EDIT.h_latency.value="'
            ||to_char(ppgnr.latency)||'"');
    end loop;

    htp.p('</SCRIPT>');
    htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  end if;

  htp.tableopen (calign=>'CENTER', cattributes=>'WIDTH=100% summary=""');
  htp.tableRowOpen;

  -- Delete button
  htp.p('<TD WIDTH=50% id="">');
  if (edit = 'Y') then
    htp.tableOpen(calign=>'CENTER', cattributes=>'summary=""');
    htp.tableRowOpen;
    htp.p('<TD id="">');
    wfa_html.create_reg_button (
         'javascript:document.WF_PPGN_EDIT.h_action.value=''DELETE'';'||
         'document.WF_PPGN_EDIT.submit()',
         wf_core.translate ('DELETE'),
         wfa_html.image_loc,
         null,
         wf_core.translate ('DELETE'));
    htp.p('</TD>');
    htp.tableRowClose;
    htp.tableClose;
  else
    htp.p('&nbsp');
  end if;
  htp.p('</TD>');

  -- Submit button
  htp.p('<TD id="">');

  htp.tableOpen;
  htp.tableRowOpen;
  htp.p('<TD id="">');
  wfa_html.create_reg_button (
    'javascript:verify('||''''||wf_core.translate('WFE_INTERVAL_ERROR')
                        ||''')',
    wf_core.translate ('SUBMIT'),
    wfa_html.image_loc,
    null,
    wf_core.translate ('SUBMIT'));
  htp.p('</TD>');
  htp.p('<TD id="">');
  -- Cancel button
  wfa_html.create_reg_button ('javascript:window.history.back()',
                                wf_core.translate('CANCEL'),
                                wfa_html.image_loc,
                                'FNDJLFCN.gif',
                                wf_core.translate('CANCEL'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;
  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

  commit;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'Edit_Propagation', oqueue, tosystem, url);
    wfe_html_util.Error;
end Edit_Propagation;


--
-- SubmitListener
--   Put in the change to the DBMS_JOB for Wf_Event.Listen().
--
procedure SubmitListener(
  h_job      in varchar2,
  h_name     in varchar2,
  h_rundate  in varchar2,
  h_day      in varchar2,
  h_hour     in varchar2,
  h_minute   in varchar2,
  h_sec      in varchar2,
  h_url      in varchar2
) is
  l_rundate  date;
  l_job      pls_integer;
  l_day      pls_integer;
  l_hour     pls_integer;
  l_minute   pls_integer;
  l_sec      pls_integer;
  l_name     varchar2(30);
begin
  -- resolve the job number
  begin
    l_job := to_number(h_job);
  exception
    when INVALID_NUMBER then
      l_job := to_number(NULL);
  end;

  -- resolve the current rundate
  begin
    l_rundate := to_date(h_rundate, wf_engine.date_format);
  exception
    when VALUE_ERROR then
      l_rundate := to_date(null);
  end;

  -- resolve the interval specified
  begin
    l_day := nvl(to_number(h_day), 0);
  exception
    when INVALID_NUMBER then
      l_day := 0;
  end;
  begin
    l_hour := nvl(to_number(h_hour), 0);
  exception
    when INVALID_NUMBER then
      l_hour := 0;
  end;
  begin
    l_minute := nvl(to_number(h_minute), 0);
  exception
    when INVALID_NUMBER then
      l_minute := 0;
  end;
  begin
    l_sec := nvl(to_number(h_sec), 0);
  exception
    when INVALID_NUMBER then
      l_sec := 0;
  end;

  if (l_job is null) then

     -- Bug 3372981 Validating agent name.  If valid submit the job
     -- otherwise raise error.
     begin
        select name
        into l_name
        from wf_agents
        where name = upper(h_name);

        DBMS_JOB.Submit(
          job=>l_job,
          what=>'Wf_Event.Listen('''||h_name||''');',
          next_date=>nvl(l_rundate, sysdate),
          interval=>to_date(null)
        );
     exception when no_data_found then
      -- Invalid Agent so raising error.
         wf_core.raise('WFE_AGENT_NOTEXIST');
     end;
  else
    DBMS_JOB.Next_Date(
      job=>l_job,
      next_date=>nvl(l_rundate, sysdate)
    );
  end if;

  -- next rundate should be future date
  if (l_rundate is not null) then
    if (Wf_Setup.JobNextRunDate(l_job,l_day,l_hour,l_minute,l_sec)
        <= sysdate) then
      wf_core.raise('WFE_LATER_INTERVAL');
    end if;
  end if;

  DBMS_JOB.Interval(
    job=>l_job,
    interval=>'Wf_Setup.JobNextRunDate('||to_char(l_job)||','||
              to_char(l_day)||','||
              to_char(l_hour)||','||
              to_char(l_minute)||','||
              to_char(l_sec)||')'
  );

  -- force it to run the first time
  if (l_rundate is null) then
    DBMS_JOB.Run(
      job=>l_job
    );
  end if;

  commit;

  -- go back to the specified URL
  Wfe_Html_Util.gotoURL(h_url);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'SubmitListener', h_name, h_rundate,
                    '('||h_day||','||h_hour||','||h_minute||','||h_sec||')');
    wfe_html_util.Error;
end SubmitListener;


--
-- SubmitPropagation
--   Put in the change to the DBMS_AQADM.Schedule_Propagation.
--
procedure SubmitPropagation(
  h_qname    in varchar2,
  h_system   in varchar2,
  h_duration in varchar2,
  h_interval in varchar2,
  h_latency  in varchar2,
  h_url      in varchar2,
  h_action   in varchar2,
  h_edit     in varchar2
)is
  l_duration pls_integer;
  l_interval pls_integer;
  l_latency  pls_integer;
  l_nextrun  varchar2(2000);
begin
  -- remove the old schedule and return
  if (h_action = 'DELETE') then
    Wf_Setup.DeletePropagation(h_qname, h_system);

    -- go back to the specified URL
    Wfe_Html_Util.gotoURL(h_url);
    return;
  end if;

  -- resolve duration
  begin
    l_duration := to_number(h_duration);
  exception
    when INVALID_NUMBER then
      l_duration := to_number(NULL);
  end;

  -- resolve interval
  begin
    l_interval := to_number(h_interval);
  exception
    when INVALID_NUMBER then
      l_interval := to_number(NULL);
  end;

  -- resolve latency
  begin
    l_latency := nvl(to_number(h_latency), 60);
  exception
    when INVALID_NUMBER then
      l_latency := to_number(60);
  end;

  -- remove the old schedule first
  if (h_edit = 'Y') then
    Wf_Setup.DeletePropagation(h_qname, h_system);
  end if;

  -- calculate the nextrun function
  if (l_interval is not null) then
    l_nextrun := 'SYSDATE + ('||to_char(l_interval)||'/86400)';

    -- include duration in the function only when there is an interval
    if (l_duration is not null) then
      l_nextrun := l_nextrun||' - ('||to_char(l_duration)||'/86400)';
    end if;
  end if;

  -- schedule propagation
  DBMS_AQADM.Schedule_Propagation(
    queue_name=>h_qname,
    destination=>h_system,
    duration=>l_duration,
    next_time=>l_nextrun,
    latency=>l_latency
  );

  -- go back to the specified URL
  Wfe_Html_Util.gotoURL(h_url);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'SubmitPropagation', h_qname, h_system,
                    h_duration, h_interval, h_latency);
    wfe_html_util.Error;
end SubmitPropagation;


--
-- DeleteJob
--
procedure DeleteJob(
  h_job pls_integer,
  h_url varchar2
) is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  DBMS_JOB.Remove(h_job);

  -- go back to the specified URL
  Wfe_Html_Util.gotoURL(h_url);
exception
  when OTHERS then
    wf_core.context('WF_SETUP', 'DeleteJob', h_job, h_url);
    raise;
end DeleteJob;

--
-- DeletePropagation
--
procedure DeletePropagation(
  h_qname    in varchar2,
  h_system   in varchar2
)is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  dbms_aqadm.UnSchedule_Propagation(
    queue_name=>h_qname,
    destination=>h_system
  );
exception
  when OTHERS then
    wf_core.context('WF_SETUP', 'DeletePropagation', h_qname, h_system);
    raise;
end DeletePropagation;

--
-- JobNextRunDate (Private)
--   Return the next run date for DBMS_JOB
--
function JobNextRunDate(
  jobnum in pls_integer,
  mday   in number ,
  mhour  in number ,
  mmin   in number ,
  msec   in number
) return date
is
  nDate  date;
begin
  begin
    select NEXT_DATE into nDate
      from WF_ALL_JOBS
     where job = jobnum;
  exception
    when NO_DATA_FOUND then
      return to_date(NULL);
  end;

  -- when nothing is specify, no next run date
  if (mDay = 0 and mDay = 0 and mHour = 0 and mMin = 0 and mSec = 0) then
    return(to_date(NULL));
  end if;

  return(nDate + mDay + (mHour/24) + (mMin/1440) + (mSec/86400));
end JobNextRunDate;
--
-- SubmitPropagation
--   For eBusiness Suite: Scheduling Propagation from Concurrent Manager
--
procedure SubmitPropagation(
  errbuf       out nocopy varchar2,
  retcode      out nocopy varchar2,
  h_qname    in varchar2,
  h_system   in varchar2,
  h_duration in varchar2,
  h_latency  in varchar2
)is
  l_duration pls_integer;
  l_interval pls_integer;
  l_latency  pls_integer;
begin
  -- Resolve Duration
  begin
    l_duration := to_number(h_duration);
  exception
    when INVALID_NUMBER then
      l_duration := to_number(NULL);
  end;

  -- resolve latency
  begin
    l_latency := nvl(to_number(h_latency), 60);
  exception
    when INVALID_NUMBER then
      l_latency := to_number(60);
  end;

  -- In case an existing propagation schedule exists
  Wf_Setup.DeletePropagation(h_qname, h_system);

  -- schedule propagation
  DBMS_AQADM.Schedule_Propagation(
    queue_name=>h_qname,
    destination=>h_system,
    duration=>l_duration,
    latency=>l_latency
  );

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_SETUP', 'SubmitPropagation', h_qname, h_system,
                    h_duration,h_latency);
    raise;
end SubmitPropagation;
end WF_SETUP;

/
