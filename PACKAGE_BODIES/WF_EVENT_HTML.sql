--------------------------------------------------------
--  DDL for Package Body WF_EVENT_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_HTML" as
/* $Header: wfehtmb.pls 120.4 2005/11/08 00:43:44 nravindr ship $ */

--
-- isDeletable
--   Find out if a particular entity is deletable or not
-- IN
--   x_guid - global unique id for that entity
--   x_type - type of such entity 'EVENT|GROUP|SYSTEM|AGENT|SUBSCRIP'
-- RET
--   True if it is ok to delete.
--   False otherwise.
--
function isDeletable (
  x_guid in raw,
  x_type in varchar2
) return boolean
is
  member_count pls_integer := 0;
begin
  if (x_type = 'EVENT_S' or x_type = 'EVENT') then
    -- If the Event is of a Custom Level of Core or Limit you cannot delete it
    select count(1) into member_count
      from WF_EVENTS
    where GUID = x_guid
      and CUSTOMIZATION_LEVEL in ('C','L');

    -- do not bother to check further if the event is of type Core/Limit
    if (member_count > 0) then
      return(FALSE);
    end if;

    -- if there is any subscription, it has detail and is not deletable.
    select count(1) into member_count
      from WF_EVENT_SUBSCRIPTIONS
     where EVENT_FILTER_GUID = x_guid;

    -- do not bother to check further if there are subscriptions.
    if (member_count > 0) then
      return(FALSE);
    end if;

  elsif (x_type = 'SYSTEM_S' or x_type = 'SYSTEM') then
    -- SYSTEM_S is for checking subscription only.
    -- if there is any subscrption, it is not deletable.
    select count(1) into member_count
      from WF_EVENT_SUBSCRIPTIONS
     where SYSTEM_GUID = x_guid;

    -- SYSTEM_S also needs to check the new MASTER requirement
    -- to see if it is a master of some body else
    if (member_count = 0) then
      select count(1) into member_count
        from WF_SYSTEMS
       where MASTER_GUID = x_guid;
    end if;

    if (member_count > 0) then
      return(FALSE); -- do not bother to check further if there are members.
    end if;

  elsif (x_type = 'AGENT') then
    select count(1) into member_count
      from WF_EVENT_SUBSCRIPTIONS
     where SOURCE_AGENT_GUID = x_guid
        or OUT_AGENT_GUID = x_guid
        or TO_AGENT_GUID = x_guid;

  elsif (x_type = 'SUBSCRIPTION') then
    -- there is no dependency at this moment
    -- but later on, we may check the runtime table
    select count(1) into member_count
      from WF_EVENT_SUBSCRIPTIONS
    where GUID = x_guid
      and CUSTOMIZATION_LEVEL in ('C','L');

    -- do not bother to check further if the event is of type Core/Limit
    if (member_count > 0) then
      return(FALSE);
    end if;

    return TRUE;
  end if;

  -- also check the following if type is SYSTEM
  if (x_type = 'SYSTEM') then
    -- if there is any agent reference, it is not deletable.
    select count(1) into member_count
      from WF_AGENTS
     where SYSTEM_GUID = x_guid;
  end if;

  -- also check if it is the Local System
  if (x_type = 'SYSTEM') then
    -- Compare the GUID against the Local System GUID
    if x_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) then
      return false;
    end if;
  end if;

  -- Need to also check if the Event is part of an Event Group
  if (x_type = 'EVENT') then
    -- if it is part of a event group, it is not deletable
    select count(1) into member_count
      from wf_event_groups
     where member_guid = x_guid;
  end if;

  if (member_count > 0) then
    return FALSE;
  end if;

  return TRUE;

exception
  when OTHERS then
    wf_core.context('WF_EVENT_HTML', 'isDeletable', rawtohex(x_guid), x_type);
    raise;
end isDeletable;
--
-- isAccessible
--   Determines if Screen is accessible
-- IN
--   x_type: SYSTEM, AGENTS, EVENTS, SUBSCRIPTIONS
-- NOTE
--
procedure isAccessible (
  x_type in     varchar2)
is
  l_count number := 0;
begin
  -- check there is a record in the system table
  -- that matched the WF_SYSTEM_GUID
  -- this is always checked
  select count(*) into l_count
  from wf_systems
  where guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

  if l_count = 0 then
    wf_core.raise('WFE_NO_SYSTEM');
  end if;

  -- SYSTEM: in case we think of any additional checks
  if x_type = 'SYSTEM' then
    null;
  end if;

  -- AGENTS: check if any exist for Local System
  if x_type = 'AGENTS' then
    select count(*) into l_count
    from wf_agents
    where system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  end if;

  -- EVENTS: check if any events
  if x_type = 'EVENTS' then
    select count(*) into l_count
    from wf_events;
  end if;

  -- SUBSCRIPTIONS: check if any event subscriptions for LOCAL
  if x_type = 'SUBSCRIPTIONS' then
    select count(*) into l_count
    from wf_event_subscriptions
    where system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  end if;

  -- If the count is zero, we didn't find what we were looking for
  if l_count = 0 then
      wf_core.raise('WFE_NO_SEEDDATA_LOADED');
  end if;

exception
  when OTHERS then
    wf_core.context('WF_EVENT_HTML', 'isAccessible', x_type);
    raise;
end isAccessible;

-- ListEvents
--   List events
-- NOTE
--
procedure ListEvents (
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*',
  h_type in varchar2 default '*',
  resetcookie in varchar2 default 'F')
is
  cursor evcurs(xn varchar2, xdn varchar2, xt varchar2, xs varchar2) is
    select GUID, DISPLAY_NAME, NAME, TYPE, STATUS
      from WF_EVENTS_VL
     where (xt = '*' or TYPE = xt)
       and (xdn is null or lower(DISPLAY_NAME) like '%'||lower(xdn)||'%')
       and (xn is null or lower(NAME) like '%'||lower(xn)||'%')
       and (xs = '*' or STATUS = xs)
     order by NAME;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  c  pls_integer;
  c2 pls_integer;
  cookie owa_cookie.cookie;
  l_name    varchar2(240);
  l_display_name varchar2(80);
  l_type    varchar2(8);
  l_status  varchar2(8);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('EVENTS');

  l_name := h_name;
  l_display_name := h_display_name;
  l_type := h_type;
  l_status := h_status;

  -- try to get the values from cookie if nothing is set
  if (resetcookie='F' and l_name is null and l_display_name is null and
      l_type = '*' and l_status = '*') then
    cookie := owa_cookie.get('WF_EVENT_COOKIE');

    -- ignore if more than one value was set
    if (cookie.num_vals = 1) then
      c := instr(cookie.vals(1), ':');
      if (c <= 1) then
        l_name := null;
      else
        l_name := substr(cookie.vals(1), 1, c-1);
      end if;
      c2:= instr(cookie.vals(1), ':', 1, 2);
      if (c2-c <= 1) then
        l_display_name := null;
      else
        l_display_name := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      c := c2;
      c2:= instr(cookie.vals(1), ':', 1, 3);
      if (c2-c <= 1) then
        l_type := '*';
      else
        l_type := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      l_status := substr(cookie.vals(1), c2+1);
      if (l_status = '') then
        l_status := '*';
      end if;
    end if;

  -- set cookie
  else
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send('WF_EVENT_COOKIE',
                    l_name||':'||
                    l_display_name||':'||
                    l_type||':'||
                    l_status);
    owa_util.http_header_close;
  end if;

  -- populate the data table
  i := 0;
  for event in evcurs(l_name, l_display_name, l_type, l_status) loop
    i := i+1;
    dTab(i).guid := event.guid;
    dTab(i).col01:= event.name;
    dTab(i).col02:= event.display_name;
    dTab(i).col03:= wf_core.translate(event.type);
    dTab(i).col04:= wf_core.translate(event.status);

    dTab(i).selectable := FALSE;

    dTab(i).hasdetail := not Wf_Event_Html.isDeletable(event.guid, 'EVENT_S');

    -- when there is subscription, it is not deletable
    if (dTab(i).hasdetail) then
      dTab(i).deletable := FALSE;

    -- otherwise, we need to check further
    else
      dTab(i).deletable := Wf_Event_Html.isDeletable(event.guid, 'EVENT');
    end if;

  end loop;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after editevent, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_LIST_EVENTS_TITLE'));
  wfa_html.create_help_function('wf/links/def.htm?'||'DEFEVT');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindEvent',
            wf_core.translate('WFE_LIST_EVENTS_TITLE'),
            TRUE);

  htp.br;  -- add some space between header and table

  -- populate the header table
  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.DeleteEvent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.ListSubscriptions?use_guid_only=T&'||
                      'h_event_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.EditEvent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SUBSCRIPTIONS');
  hTab(i).attr     := 'id="'||wf_core.translate('SUBSCRIPTIONS')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EDIT');
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('DISPLAY_NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('TYPE');
  hTab(i).attr     := 'id="'||wf_core.translate('TYPE')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('STATUS');
  hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

  htp.tableopen (calign=>'CENTER ', cattributes=>'summary""');
  htp.tableRowOpen;
  htp.p('<TD ID="">');
  wfa_html.create_reg_button (wfa_html.base_url||'/Wf_Event_Html.EditEvent',
                              wf_core.translate('WFE_ADD_EVENT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFE_ADD_EVENT'));
  htp.p('</TD>');
  htp.p('<TD ID="">');
  wfa_html.create_reg_button (wfa_html.base_url||
                                '/Wf_Event_Html.EditEvent?h_type=GROUP',
                              wf_core.translate('WFE_ADD_GROUP'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFE_ADD_GROUP'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'ListEvents');
    wfe_html_util.Error;
end ListEvents;

--
-- ListSystems
--   List systems
-- NOTE
--
procedure ListSystems (
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  display_master in varchar2 default null,
  h_master_guid  in varchar2 default null,
  resetcookie in varchar2 default 'F'
)
is
  cursor syscurs(mguid raw, xn varchar2, xdn varchar2) is
    select GUID, DISPLAY_NAME, NAME, MASTER_GUID
      from WF_SYSTEMS
     where (xdn is null or lower(DISPLAY_NAME) like '%'||lower(xdn)||'%')
       and (xn  is null or lower(NAME) like '%'||lower(xn)||'%')
       and (mguid is null or MASTER_GUID = mguid)
     order by NAME;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  acnt number; -- counter for something

  l_mguid       raw(16);   -- master guid
  l_mname       varchar2(80); -- master name

  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFPREF_LOV'));
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_localsys    raw(16);

  c  pls_integer;
  c2 pls_integer;
  cookie owa_cookie.cookie;
  l_name         varchar2(30);
  l_display_name varchar2(80);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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

  l_mguid := hextoraw(h_master_guid);
  Wf_Event_Html.Validate_System_Name(display_master, l_mguid);

  -- find the local system guid
  begin
    select hextoraw(TEXT)
      into l_localsys
      from WF_RESOURCES
     where NAME = 'WF_SYSTEM_GUID'
       and LANGUAGE = userenv('LANG');
  exception
    when NO_DATA_FOUND then
      l_localsys := null;
  end;

  l_name := h_name;
  l_display_name := h_display_name;

  -- try to get the values from cookie if nothing is set
  if (resetcookie='F' and l_mguid is null and l_name is null and
      l_display_name is null) then
    cookie := owa_cookie.get('WF_SYSTEM_COOKIE');

    -- ignore if more than one value was set
    if (cookie.num_vals = 1) then
      c := instr(cookie.vals(1), ':');
      if (c <= 1) then
        l_mguid := hextoraw(null);
      else
        l_mguid := hextoraw(substr(cookie.vals(1), 1, c-1));
      end if;
      c2:= instr(cookie.vals(1), ':', 1, 2);
      if (c2-c <= 1) then
        l_name := null;
      else
        l_name := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      l_display_name := substr(cookie.vals(1), c2+1);
      if (l_display_name = '') then
        l_display_name := null;
      end if;

    end if;

  -- set cookie
  else
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send('WF_SYSTEM_COOKIE',
                    rawtohex(l_mguid)||':'||
                    l_name||':'||
                    l_display_name);
    owa_util.http_header_close;
  end if;

  -- populate the data table
  i := 0;
  for asystem in syscurs(l_mguid, l_name, l_display_name) loop
    i := i+1;
    dTab(i).guid := asystem.guid;
    dTab(i).col01:= asystem.name;

    -- this is a local system
    if (l_localsys = dTab(i).guid) then
      dTab(i).col01 := dTab(i).col01||'*';
    end if;

    dTab(i).col02:= asystem.display_name;

    -- find out the master display name
    if (asystem.master_guid is not null) then
      -- do the following select only if
      --  l_mguid is null, that is a general query
      -- or
      --  l_mname is null, that query is being run the first time
      --
      if (l_mguid is null or l_mname is null) then
        begin
          select NAME
            into l_mname
            from WF_SYSTEMS
           where GUID = asystem.master_guid;
        exception
          when NO_DATA_FOUND then
            wf_core.token('GUID', rawtohex(asystem.master_guid));
            l_mname := wf_core.translate('WFE_SYSTEM_NOGUID');
        end;
      end if;
      dTab(i).col03 := l_mname;

    -- put a space there, if no master
    else
      dTab(i).col03 := '&nbsp';
    end if;

    dTab(i).selectable := FALSE;

    select count(1) into acnt
      from WF_EVENT_SUBSCRIPTIONS
     where SYSTEM_GUID = asystem.guid;

    if (acnt = 0) then
      dTab(i).deletable := Wf_Event_Html.isDeletable(asystem.guid, 'SYSTEM');
      dTab(i).hasdetail := FALSE;
    else
      dTab(i).deletable := FALSE;  -- has reference from subscriptions
      dTab(i).hasdetail := TRUE;
    end if;
  end loop;
  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after editevent, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_LIST_SYSTEMS_TITLE'));
  wfa_html.create_help_function('wf/links/def.htm?'||'DEFEVSYS');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindSystem',
            wf_core.translate('WFE_LIST_SYSTEMS_TITLE'),
            TRUE);

  htp.br;  -- add some space between header and table

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.DeleteSystem?h_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.ListSubscriptions?use_guid_only=T&h_system_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.EditSystem?h_guid=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SUBSCRIPTIONS');
  hTab(i).attr     := 'id="'||wf_core.translate('SUBSCRIPTIONS')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EDIT');
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('DISPLAY_NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('MASTER');
  hTab(i).attr     := 'id="'||wf_core.translate('MASTER')||'"';

  -- render table

  Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab,
    tabattr=>'border=1 cellpadding=3 bgcolor=white width=100% summary="' ||
         wf_core.translate('WFE_LIST_SYSTEMS_TITLE') || '"');

  -- message to indicate local system
  htp.tableopen(calign=>'CENTER', cattributes=>'WIDTH=100%
  summary="' || wf_core.translate('WFE_INDICATE_LOCAL_SYS') || '"');
  htp.tableRowOpen;
  htp.p('<TD ID="'|| wf_core.translate('WFE_INDICATE_LOCAL_SYS') || '" align="LEFT">');
    htp.p('* - '||wf_core.translate('WFE_INDICATE_LOCAL_SYS'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;
  htp.p('<TD ID="">');
  wfa_html.create_reg_button (wfa_html.base_url||'/Wf_Event_Html.EditSystem',
                              wf_core.translate('WFE_ADD_SYSTEM'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFE_ADD_SYSTEM'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'ListSystems');
    wfe_html_util.Error;
end ListSystems;

--
-- ListAgents
--   List agents
-- NOTE
--
procedure ListAgents (
  h_name in varchar2 default null,
  h_protocol in varchar2 default null,
  h_address in varchar2 default null,
  display_system in varchar2 default null,
  h_system_guid in varchar2 default null,
  h_direction in varchar2 default '*',
  h_status in varchar2 default '*',
  use_guid_only in varchar2 default 'F',
  resetcookie in varchar2 default 'F'
)
is
  cursor agcurs(sguid raw, xn varchar2, xp varchar2, xa varchar2,
                xd varchar2, xs varchar2) is
    select A.GUID, A.NAME, A.PROTOCOL, A.ADDRESS,
           S.NAME SYSTEM_NAME,
           A.DIRECTION, A.STATUS
      from WF_AGENTS A, WF_SYSTEMS S
     where (xn is null or lower(A.NAME) like '%'||lower(xn)||'%')
       and (xp is null or A.PROTOCOL = xp)
       and (xa is null or A.ADDRESS = xa)
       and (sguid is null or S.GUID = sguid)
       and A.SYSTEM_GUID = S.GUID
       and (xd = '*' or A.DIRECTION = xd)
       and (xs = '*' or A.STATUS = xs)
     order by SYSTEM_NAME, A.NAME, A.ADDRESS, A.PROTOCOL;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_sguid raw(16);          -- system guid
  l_sname varchar2(80);     -- system name
  prev_sname varchar2(80);  -- previous system name

  c  pls_integer;
  c2 pls_integer;
  cookie owa_cookie.cookie;

  l_name       varchar2(30);
  l_protocol   varchar2(30);
  l_address    varchar2(240);
  l_direction  varchar2(8);
  l_status     varchar2(8);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  l_sguid := hextoraw(h_system_guid);
  if (use_guid_only = 'F') then
    Wf_Event_Html.Validate_System_Name(display_system, l_sguid);
  end if;

  l_name     := h_name;
  l_protocol := h_protocol;
  l_address  := h_address;
  l_direction:= h_direction;
  l_status   := h_status;

  -- try to get the values from cookie if nothing is set
  if (resetcookie='F' and l_sguid is null and l_name is null and
      l_protocol is null and l_direction = '*' and l_status = '*') then
    cookie := owa_cookie.get('WF_AGENT_COOKIE');

    -- ignore if more than one value was set
    if (cookie.num_vals = 1) then
      c := instr(cookie.vals(1), ':');
      if (c <= 1) then
        l_sguid := hextoraw(null);
      else
        l_sguid := hextoraw(substr(cookie.vals(1), 1, c-1));
      end if;
      c2:= instr(cookie.vals(1), ':', 1, 2);
      if (c2-c <= 1) then
        l_name := null;
      else
        l_name := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      c := c2;
      c2:= instr(cookie.vals(1), ':', 1, 3);
      if (c2-c <= 1) then
        l_protocol := null;
      else
        l_protocol := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      c := c2;
      c2:= instr(cookie.vals(1), ':', 1, 4);
      if (c2-c <= 1) then
        l_address := null;
      else
        l_address := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      c := c2;
      c2:= instr(cookie.vals(1), ':', 1, 5);
      if (c2-c <= 1) then
        l_direction := '*';
      else
        l_direction := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      l_status := substr(cookie.vals(1), c2+1);
      if (l_status = '') then
        l_status := '*';
      end if;

    end if;

  -- set cookie
  else
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send('WF_AGENT_COOKIE',
                    rawtohex(l_sguid)||':'||
                    l_name||':'||
                    l_protocol||':'||
                    l_address||':'||
                    l_direction||':'||
                    l_status);
    owa_util.http_header_close;
  end if;

  -- populate the data table
  prev_sname := null;
  i := 0;
  for agent in agcurs(l_sguid,l_name,l_protocol,l_address,
                      l_direction,l_status) loop
    if (prev_sname is null or prev_sname <> agent.system_name) then

      -- add a blank row
      if (prev_sname is not null) then
        i := i+1;
        dTab(i).guid := agent.guid;

        dTab(i).level := 1;
        dTab(i).trattr := 'VALIGN=TOP bgcolor=#CCCCCC';
        dTab(i).col01 := '&nbsp';
      end if;

      i := i+1;
      dTab(i).guid := agent.guid;

      dTab(i).level := 1;
      dTab(i).trattr := 'VALIGN=TOP bgcolor=#CCCCCC';
      dTab(i).col01 := '<B>'||wf_core.translate('SYSTEM')||': '||
                       agent.system_name||'</B>';
      dTab(i).tdattr := 'id="' || WF_CORE.Translate('SYSTEM') || '"';

      prev_sname := agent.system_name;

      -- print title here
      i := i+1;
      dTab(i).guid := agent.guid;
      dTab(i).level:= 0;
      dTab(i).showtitle := TRUE;

    end if;

    i := i+1;
    dTab(i).guid := agent.guid;

    dTab(i).level := 0;
    dTab(i).trattr := 'VALIGN=TOP bgcolor=white';

    dTab(i).col01:= agent.name;

    if (agent.address is null) then
        dTab(i).col02:= '&nbsp';
    else
        dTab(i).col02:= agent.address;
    end if;
    dTab(i).col03:= agent.protocol;
    dTab(i).col04:= wf_core.translate(agent.direction);
    dTab(i).col05:= wf_core.translate(agent.status);

    dTab(i).selectable := FALSE;

    dTab(i).deletable := Wf_Event_Html.isDeletable(agent.guid, 'AGENT');

    dTab(i).hasdetail := FALSE;

  end loop;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after editevent, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_LIST_AGENTS_TITLE'));
  wfa_html.create_help_function('wf/links/def.htm?'||'DEFEVAGT');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindAgent',
            wf_core.translate('WFE_LIST_AGENTS_TITLE'),
            TRUE);

  htp.br;  -- add some space between header and table

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.DeleteAgent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := null;  -- never has detail page
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.EditAgent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- no detail title
  hTab(i).level    := 0;
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EDIT');
  hTab(i).level    := 0;
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SYSTEM');
  hTab(i).level    := 1;
  hTab(i).span     := 5;
  hTab(i).trattr   := 'bgcolor=#006699';
  hTab(i).attr     := 'bgcolor=#CCCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('ADDRESS');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('ADDRESS')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('PROTOCOL');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('PROTOCOL')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('DIRECTION');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('DIRECTION')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('STATUS');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

  -- render table
  -- for an empty table, show only the level 0 title
  if (dTab.COUNT = 0) then
    Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab,
      tabattr=>'border=0 cellpadding=3 cellspacing=2 bgcolor=#CCCCCC
         width=100%
        summary="' || wf_core.translate('WFE_LIST_AGENTS_TITLE') || '"',
      show_1st_title=>TRUE, show_level=>0);

  -- show the full table
  else
    Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab,
      tabattr=>'border=0 cellpadding=3 cellspacing=2 bgcolor=#CCCCCC
         width=100%
        summary="' || wf_core.translate('WFE_LIST_AGENTS_TITLE') || '"',
      show_1st_title=>FALSE);
  end if;

  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;
  htp.p('<TD ID="">');
  wfa_html.create_reg_button (wfa_html.base_url||'/Wf_Event_Html.EditAgent',
                              wf_core.translate('WFE_ADD_AGENT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFE_ADD_AGENT'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'ListAgents');
    wfe_html_util.Error;
end ListAgents;

--
-- ListSubscriptions
--   List subscriptions
-- NOTE
--
procedure ListSubscriptions (
  display_event in varchar2 default null,
  h_event_guid in varchar2 default null,
  h_source_type in varchar2 default '*',
  display_system in varchar2 default null,
  h_system_guid in varchar2 default null,
  h_status in varchar2 default '*',
  use_guid_only in varchar2 default 'F',
  resetcookie in varchar2 default 'F'
)
is
  cursor sscurs(eguid raw, sguid raw, xt varchar2, xs varchar2) is
    select ES.GUID,
           ES.SYSTEM_GUID, ES.SOURCE_TYPE, ES.EVENT_FILTER_GUID,
           ES.STATUS,
           ES.OUT_AGENT_GUID, ES.TO_AGENT_GUID,
           ES.RULE_FUNCTION, ES.WF_PROCESS_TYPE, ES.WF_PROCESS_NAME,
           SY.NAME SYSTEM_NAME, E.NAME EVENT_NAME
      from WF_EVENT_SUBSCRIPTIONS ES, WF_EVENTS E, WF_SYSTEMS SY
     where (eguid is null or ES.EVENT_FILTER_GUID = eguid)
       and (xt = '*' or ES.SOURCE_TYPE = xt)
       and (sguid is null or ES.SYSTEM_GUID = sguid)
       and (xs = '*' or ES.STATUS = xs)
       and E.GUID  (+)= ES.EVENT_FILTER_GUID
       and SY.GUID (+)= ES.SYSTEM_GUID
     order by SYSTEM_NAME, EVENT_NAME, ES.PHASE;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  cTab wfe_html_util.tmpTabType;   -- temporary column table

  i pls_integer;
  j pls_integer;

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_eguid raw(16);       -- event guid
  l_ename varchar2(240); -- event name
  l_sguid raw(16);       -- system guid
  l_sname varchar2(80);  -- system name

  l_name    varchar2(240); -- internal name for event/system

  from_system boolean := FALSE;
  from_event  boolean := FALSE;

  l_url varchar2(3200);

  prev_sguid raw(16);  -- previous system guid
  prev_eguid raw(16);  -- previous event guid

  c  pls_integer;
  c2 pls_integer;
  cookie owa_cookie.cookie;
  l_source_type varchar2(8);
  l_status      varchar2(8);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('SUBSCRIPTIONS');

  l_eguid := hextoraw(h_event_guid);
  l_sguid := hextoraw(h_system_guid);
  if (use_guid_only = 'F') then
    Wf_Event_Html.Validate_Event_Name(display_event, l_eguid);
    Wf_Event_Html.Validate_System_Name(display_system, l_sguid);
  end if;

  l_source_type := h_source_type;
  l_status := h_status;

  -- try to get the values from cookie if nothing is set
  if (resetcookie='F' and l_eguid is null and l_sguid is null and
      l_source_type = '*' and l_status = '*') then
    cookie := owa_cookie.get('WF_SUBSCRIPTION_COOKIE');

    -- ignore if more than one value was set
    if (cookie.num_vals = 1) then
      c := instr(cookie.vals(1), ':');
      if (c <= 1) then
        l_eguid := hextoraw(null);
      else
        l_eguid := hextoraw(substr(cookie.vals(1), 1, c-1));
      end if;
      c2:= instr(cookie.vals(1), ':', 1, 2);
      if (c2-c <= 1) then
        l_sguid := hextoraw(null);
      else
        l_sguid := hextoraw(substr(cookie.vals(1), c+1, c2-c-1));
      end if;
      c := c2;
      c2:= instr(cookie.vals(1), ':', 1, 3);
      if (c2-c <= 1) then
        l_source_type := '*';
      else
        l_source_type := substr(cookie.vals(1), c+1, c2-c-1);
      end if;
      l_status := substr(cookie.vals(1), c2+1);
      if (l_status = '') then
        l_status := '*';
      end if;

    end if;

  -- set cookie to event and system guid
  else
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send('WF_SUBSCRIPTION_COOKIE',
                    rawtohex(l_eguid)||':'||
                    rawtohex(l_sguid)||':'||
                    l_source_type||':'||
                    l_status);
    owa_util.http_header_close;
  end if;

  -- determine if this is from system or from event
  if (l_sguid is not null) then
    -- from system
    begin
      select NAME
        into l_name
        from WF_SYSTEMS
       where GUID = l_sguid;
    exception
      when OTHERS then
        l_name := null;
    end;

    from_system := TRUE;

  end if;
  if (l_eguid is not null) then
    -- from event
    begin
      select NAME
        into l_name
        from WF_EVENTS
       where GUID = l_eguid;
    exception
      when OTHERS then
        l_name := null;
    end;

    from_event := TRUE;
  end if;

  -- populate the data table
  prev_sguid := null;
  prev_eguid := null;
  i := 0;
  for ssr in sscurs(l_eguid, l_sguid, l_source_type, l_status) loop
    if (prev_sguid is null or prev_sguid <> ssr.system_guid) then

      -- add a blank row
      if (prev_sguid is not null and prev_eguid is not null) then
        i := i+1;
        dTab(i).guid := ssr.guid;

        dTab(i).level := 2;
        dTab(i).trattr := 'VALIGN=TOP bgcolor=#CCCCCC';
        dTab(i).col01 := '&nbsp';
      end if;

      -- System Name (level 2)
      i := i+1;
      dTab(i).guid := ssr.guid;

      dTab(i).level := 2;
      dTab(i).trattr := 'VALIGN=TOP bgcolor=#CCCCCC';
      -- put a space there if no system is defined
      if (ssr.system_guid is null) then
        dTab(i).col01 := '<B>'||wf_core.translate('SYSTEM')||': &nbsp</B>';

      -- find the system name
      else
        if (ssr.system_name is null) then
          wf_core.token('GUID', rawtohex(ssr.system_guid));
          dTab(i).col01 := wf_core.translate('WFE_SYSTEM_NOGUID');
        else
          dTab(i).col01 := '<B>'||wf_core.translate('SYSTEM')||':'||
                           ssr.system_name||'</B>';
        end if;

        prev_sguid := ssr.system_guid;
      end if;

      prev_eguid := null;  -- reset this with a new system

    end if;

    if (prev_eguid is null or prev_eguid <> ssr.event_filter_guid) then

      -- add a blank row
      if (prev_eguid is not null) then
        i := i+1;
        dTab(i).guid := ssr.guid;

        dTab(i).level := 1;
        dTab(i).trattr := 'VALIGN=TOP bgcolor=#CCCCCC';
        dTab(i).col01 := '';  -- indentation
        dTab(i).col02 := '&nbsp';
      end if;

      -- Event Name (level 1)
      i := i+1;
      dTab(i).guid := ssr.guid;

      dTab(i).level := 1;

      -- indentation
      dTab(i).col01 := '';

      -- put a space there if no event filter is defined
      if (ssr.event_filter_guid is null) then
        dTab(i).col02 := '<B>'||wf_core.translate('EVENT')||': &nbsp</B>';

      -- find the event name
      else
        if (ssr.event_name is null) then
          wf_core.token('GUID', rawtohex(ssr.event_filter_guid));
          dTab(i).col02 := wf_core.translate('WFE_EVENT_NOGUID');
        else
          dTab(i).col02 := '<B>'||wf_core.translate('EVENT')||': '||
                           ssr.event_name||'</B>';
        end if;

        prev_eguid := ssr.event_filter_guid;
      end if;

      -- print title here
      i := i+1;
      dTab(i).guid := ssr.guid;
      dTab(i).level:= 0;
      dTab(i).showtitle := TRUE;

    end if;

    i := i+1;
    dTab(i).guid := ssr.guid;
    dTab(i).level := 0;
    dTab(i).trattr := 'VALIGN=TOP bgcolor=white';

    -- indentation
    dTab(i).col01 := '';

    -- source type
    if (ssr.source_type is null) then
      dTab(i).col02 := '&nbsp';
    else
      dTab(i).col02 := wf_core.translate(ssr.source_type);
    end if;

    -- put a space there if no "out agent" is defined
    if (ssr.out_agent_guid is null) then
      dTab(i).col03 := '&nbsp';

    -- find the agent name
    else
      -- find the system name
      begin
        select S.NAME
          into dTab(i).col03
          from WF_AGENTS A, WF_SYSTEMS S
         where A.GUID = ssr.out_agent_guid
           and A.SYSTEM_GUID = S.GUID;
      exception
        when OTHERS then
          dTab(i).col03 := null;
      end;

      begin
        if (dTab(i).col03 is null) then
          select NAME
            into dTab(i).col03
            from WF_AGENTS
           where GUID = ssr.out_agent_guid;
        else
          select A.NAME||'@'||dTab(i).col03
            into dTab(i).col03
            from WF_AGENTS A
           where A.GUID = ssr.out_agent_guid;

        end if;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(ssr.out_agent_guid));
          dTab(i).col03 := wf_core.translate('WFE_AGENT_NOGUID');
      end;
    end if;

    -- put a space there if no "to agent" is defined
    if (ssr.to_agent_guid is null) then
      dTab(i).col04 := '&nbsp';

    -- find the agent name
    else
      -- find the system name
      begin
        select S.NAME
          into dTab(i).col04
          from WF_AGENTS A, WF_SYSTEMS S
         where A.GUID = ssr.to_agent_guid
           and A.SYSTEM_GUID = S.GUID;
      exception
        when OTHERS then
          dTab(i).col04 := null;
      end;

      begin
        if (dTab(i).col04 is null) then
          select A.NAME
            into dTab(i).col04
            from WF_AGENTS A
           where A.GUID = ssr.to_agent_guid;
        else
          select A.NAME||'@'||dTab(i).col04
            into dTab(i).col04
            from WF_AGENTS A
           where A.GUID = ssr.to_agent_guid;
        end if;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(ssr.to_agent_guid));
          dTab(i).col04 := wf_core.translate('WFE_AGENT_NOGUID');
      end;
    end if;

    -- function
    if (ssr.rule_function is not null) then
      dTab(i).col05 := ssr.rule_function;
    else
      dTab(i).col05 := '&nbsp';
    end if;

    -- Workflow process
    if (ssr.wf_process_type is null and ssr.wf_process_name is null) then
      dTab(i).col06 := '&nbsp';
    else
      dTab(i).col06 := ssr.wf_process_type||'/'||ssr.wf_process_name;
    end if;

    dTab(i).col07 := wf_core.translate(ssr.status);

    dTab(i).selectable := FALSE;
--    dTab(i).deletable  := TRUE;
    dTab(i).deletable := Wf_Event_Html.isDeletable(ssr.guid, 'SUBSCRIPTION');
    dTab(i).hasdetail  := FALSE;

  end loop;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after editevent, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_LIST_SUBSC_TITLE'));
  wfa_html.create_help_function('wf/links/def.htm?'||'DEFEVSUB');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_confirm;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindSubscription',
            wf_core.translate('WFE_LIST_SUBSC_TITLE'),
            TRUE);

  htp.br;  -- add some space between header and table

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.DeleteSubscription?h_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := null;  -- never has detail page
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value    := 'Wf_Event_Html.EditSubscription?h_guid=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- no detail title
  hTab(i).level    := 0;
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EDIT');
  hTab(i).level    := 0;
--  if (not from_system) then
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SYSTEM');
  hTab(i).level    := 2;
  hTab(i).span     := 7;
  hTab(i).trattr   := 'bgcolor=#006699';
  hTab(i).attr     := 'bgcolor=#CCCCCC';
--  end if;
--  if (not from_event) then
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- indentation
  hTab(i).level    := 1;
  hTab(i).span     := 1;
  hTab(i).trattr   := 'bgcolor=#006699';
  hTab(i).attr     := 'bgcolor=#CCCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EVENT');
  hTab(i).level    := 1;
  hTab(i).span     := 6;
  hTab(i).attr     := 'id="'||wf_core.translate('EVENT')||'"';
--  end if;
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- indentation
  hTab(i).level    := 0;
  hTab(i).trattr   := 'bgcolor=#006699';
  hTab(i).attr     := 'bgcolor=#CCCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SOURCE_TYPE');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('SOURCE_TYPE')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('OUT_AGENT');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('OUT_AGENT')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('TO_AGENT');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('TO_AGENT')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('FUNCTION');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('FUNCTION')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('WORKFLOW');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('WORKFLOW')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('STATUS');
  hTab(i).level    := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

  -- render table
  if (dTab.COUNT = 0) then
    Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab,
      tabattr=>'border=0 cellpadding=3 cellspacing=2 bgcolor=#CCCCCC
         width=100% summary="' ||
          wf_core.translate('WFE_LIST_SUBSC_TITLE') || '"',
      show_1st_title=>TRUE, show_level=>0);

  -- show the full table
  else
    Wfe_Html_Util.Simple_Table(headerTab=>hTab, dataTab=>dTab,
      tabattr=>'border=0 cellpadding=3 cellspacing=2 bgcolor=#CCCCCC
        width=100% summary="' ||
        wf_core.translate('WFE_LIST_SUBSC_TITLE') || '"',
      show_1st_title=>FALSE);
  end if;

  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;
  htp.p('<TD ID="'|| wf_core.translate('WFE_ADD_SUBSCRIPTION') ||'">');

  -- construct the url for add subscription
  l_url := wfa_html.base_url||'/Wf_Event_Html.EditSubscription';
  if (from_system) then
    l_url := l_url||'?h_sguid='||rawtohex(l_sguid);
    if (from_event) then
      l_url := l_url||'&h_eguid='||rawtohex(l_eguid);  -- both system & event
    end if;
  elsif (from_event) then
    l_url := l_url||'?h_eguid='||rawtohex(l_eguid);
  end if;

  wfa_html.create_reg_button (l_url,
                              wf_core.translate('WFE_ADD_SUBSCRIPTION'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFE_ADD_SUBSCRIPTION'));
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'ListSubscriptions');
    wfe_html_util.Error;
end ListSubscriptions;

--
-- EditEvent
--   Create/Update an event
-- IN
--   h_guid - Global unique id for an event
-- NOTE
--
procedure EditEvent(
  h_guid in raw default null,
  h_type in varchar2 default 'EVENT'
)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list

  l_name        varchar2(240);
  l_type        varchar2(8);
  l_status      varchar2(8);
  l_gfunc       varchar2(240);
  l_ownname     varchar2(30);
  l_owntag      varchar2(30);
  l_dname       varchar2(80);
  l_desc        varchar2(2000);
  l_customization_level      varchar2(1);

  select_enable varchar2(8);
  select_disable varchar2(8);
  select_event  varchar2(8) := 'SELECTED';
  select_group  varchar2(8);
  select_custom_core varchar2(8);
  select_custom_limit varchar2(8);
  select_custom_extend varchar2(8);
  select_custom_user varchar2(8);

  eventcount pls_integer;
  edittype boolean := TRUE;

  -- deletable event cursor
  -- all events belong to the group
  cursor devcurs is
    select E.GUID, E.DISPLAY_NAME, E.NAME, E.STATUS
      from WF_EVENTS_VL E, WF_EVENT_GROUPS EG
     where EG.GROUP_GUID = h_guid
       and E.GUID = EG.MEMBER_GUID;


  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  aligntext  varchar2(240);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('EVENTS');


  -- populate the appropriate values in the form if editing an exist guid
  if (h_guid is not null) then
    begin
      select NAME, DISPLAY_NAME, DESCRIPTION, TYPE, STATUS,
             GENERATE_FUNCTION, OWNER_NAME, OWNER_TAG, NVL(CUSTOMIZATION_LEVEL, 'L')
        into l_name, l_dname, l_desc, l_type, l_status,
             l_gfunc, l_ownname, l_owntag, l_customization_level
        from WF_EVENTS_VL
       where GUID = h_guid;

      -- take care of the double quote problem
      -- There should be no any kind of quote for name and generate_function.
      -- Description is handle entirely differently, no need for substitution.
      -- Single quote is ok becuase html does not treat it special.
      l_dname := replace(l_dname, '"', '\"');
      l_ownname := replace(l_ownname, '"', '\"');
      l_owntag := replace(l_owntag, '"', '\"');

      if (l_status = 'ENABLED') then
        select_enable := 'SELECTED';
        select_disable := null;
      else
        select_enable := null;
        select_disable := 'SELECTED';
      end if;

-- Stuff for Customization Level
      if l_customization_level = 'C' then
	select_custom_core := 'SELECTED';
  	select_custom_limit := null;
  	select_custom_extend := null;
  	select_custom_user := null;
      elsif l_customization_level = 'L' then
	select_custom_core := null;
  	select_custom_limit := 'SELECTED';
  	select_custom_extend := null;
  	select_custom_user := null;
      elsif l_customization_level = 'U' then
	select_custom_core := null;
  	select_custom_limit := null;
  	select_custom_extend := null;
  	select_custom_user := 'SELECTED';
      end if;

      if (l_type = 'GROUP') then
        select_group := 'SELECTED';
        select_event := null;

        -- check if we can change a group type to an event type
        -- allow this only when a group does not has any child event.
        select count(1) into eventcount
          from WF_EVENT_GROUPS
         where GROUP_GUID = h_guid;

        if (eventcount > 0) then
          edittype := FALSE;
        end if;
      end if;

    exception
      when NO_DATA_FOUND then
        wf_core.raise('WFE_EVENT_NOTEXIST');
    end;

  else
    if (h_type <> 'EVENT') then
      l_type := 'GROUP';
    else
      l_type := 'EVENT';
    end if;
    l_customization_level := 'U';
  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;

  -- list does not get updated after editevent, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_EDIT_'||l_type||'_TITLE'));
  if (l_type <> 'EVENT') then
    wfa_html.create_help_function('wf/links/t_d.htm?T_DEFEVGPM');
  else
    wfa_html.create_help_function('wf/links/t_d.htm?T_DEFEVT');
  end if;

  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_check_all;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindEvent',
            wf_core.translate('WFE_EDIT_'||l_type||'_TITLE'),
            TRUE);

  -- Form
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                     'wf_event_html.SubmitEvent',
               cmethod=>'Get',
               cattributes=>'TARGET="_top" NAME="WF_EVENT_EDIT"');

  -- GUID
  -- do not display it if it is null
  if (h_guid is not null) then
    htp.p('<!-- GUID: '||rawtohex(h_guid)||' -->');
  end if;
  htp.formHidden('h_guid', rawtohex(h_guid));

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_name">' ||
                wf_core.translate('NAME') ||
                '</LABEL>', calign=>'Right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_name', csize=>40,
                                     cmaxlength=>240,
                                     cvalue=>l_name,
                                     cattributes=>'id="i_name"'),
                calign=>'Left',
                cattributes=>'id=""');

  htp.tableRowClose;

  -- Display Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_display_name">' ||
               wf_core.translate('DISPLAY_NAME') || '</LABEL>',
               calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_display_name', csize=>60,
                                     cmaxlength=>80,
                                     cattributes=>'id="i_display_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Description
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_description">' ||
              wf_core.translate('DESCRIPTION') || '</LABEL>', calign=>'Right',
              cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                            cname=>'h_description',
                            nrows=>2,
                            ncolumns=>60,
                            cwrap=>'SOFT',
                            cattributes=>'maxlength=2000 id="i_description"')
                        ||l_desc
                        ||htf.formTextareaClose,
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Type
  template := wf_core.translate(l_type);
  htp.formHidden('h_type', l_type);

  -- Status
  template := htf.formSelectOpen('h_status',cattributes=>'id="i_status"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('ENABLED'),
                                   select_enable,'VALUE="ENABLED"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('DISABLED'),
                                   select_disable,'VALUE="DISABLED"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_status">' ||
                    wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Generate Function
  -- no generate function for group
  if (l_type <> 'GROUP') then
    htp.tableRowOpen;
    htp.tableData(cvalue=>'<LABEL FOR="i_generate_function">' ||
                  wf_core.translate('GENERATE_FUNCTION') || '</LABEL>',
                  calign=>'Right',cattributes=>'id=""');
    htp.tableData(cvalue=>htf.formText(cname=>'h_generate_function', csize=>60,
                                       cmaxlength=>240, cvalue=>l_gfunc,
                                       cattributes=>'id="i_generate_function"'),
                  calign=>'Left',cattributes=>'id=""');
    htp.tableRowClose;
  else
    htp.formHidden('h_generate_function', null);
  end if;

  -- Owner Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_owner_name">' ||
                   wf_core.translate('OWNER_NAME') || '</LABEL>',
                   calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_owner_name', csize=>30,
                                     cmaxlength=>30,
                                     cattributes=>'id="i_owner_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Owner Tag
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_owner_tag">' ||
             wf_core.translate('OWNER_TAG') || '</LABEL>',
             calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_owner_tag', csize=>30,
                                     cmaxlength=>30,
                                     cattributes=>'id="i_owner_tag"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Customization Level
  if wf_events_pkg.g_Mode = 'FORCE' then
  template := htf.formSelectOpen('h_custom_level',cattributes=>'id="i_custom_level"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_C'),
                                   select_custom_core,'VALUE="C"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_L'),
                                   select_custom_limit,'VALUE="L"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_U'),
                                   select_custom_user,'VALUE="U"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_custom_level">' ||
                    wf_core.translate('WFE_CUSTOM_LEVEL') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  else
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('WFE_CUSTOM_LEVEL'),
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>wf_core.translate('WFE_CUSTOM_LEVEL_'||l_customization_level), calign=>'Left',cattributes=>'id=""');
    htp.formHidden('h_custom_level', l_customization_level);
  end if;

  -- URL to go back to
  if (h_guid is null and l_type = 'GROUP') then
    htp.formHidden('url', '');  -- signal the coming back to this screen
  else
    htp.formHidden('url', 'Wf_Event_Html.ListEvents');
  end if;

  htp.tableClose;
  htp.formClose;

  -- add values that may contain double quote back through javascript
  if (h_guid is not null) then
    htp.p('<SCRIPT>');
    htp.p('  document.WF_EVENT_EDIT.h_display_name.value="'||l_dname||'"');
    htp.p('  document.WF_EVENT_EDIT.h_owner_name.value="'||l_ownname||'"');
    htp.p('  document.WF_EVENT_EDIT.h_owner_tag.value="'||l_owntag||'"');
    htp.p('</SCRIPT>');
  end if;

  -- if is group, display events for deletion
  if (h_guid is not null and l_type = 'GROUP') then
    i := 0;
    for event in devcurs loop
      i := i+1;
      dTab(i).guid := event.guid;
      dTab(i).col01:= '<LABEL FOR="i_select'||i||'">' || event.name || '</LABEL>';
      dTab(i).col02:= event.display_name;
      dTab(i).col03:= event.status;

      dTab(i).selectable := TRUE;
      dTab(i).deletable := FALSE;  -- do not allow deletion

      -- it is deletable when there is no subscription; that is,
      -- there is no detail.
      dTab(i).hasdetail := not Wf_Event_Html.isDeletable(event.guid, 'EVENT');
    end loop;

    htp.p(wf_core.translate('WFE_EVENTS_IN_GROUP'));

    -- Submit Form for Add/Delete
    htp.formOpen(curl=>owa_util.get_owa_service_path||
                       'Wf_Event_Html.SubmitSelectedGEvents',
                   cmethod=>'Post',
                   cattributes=>'TARGET="_top" NAME="WF_GROUP_EDIT"');
    htp.formHidden('h_gguid', rawtohex(h_guid));

    -- Hide the fields for which option you selected. ADD or DELETE
    htp.formHidden(cname=>'action', cvalue=>'');

    -- Url to come back to later
    htp.formHidden(cname=>'url',
           cvalue=>'Wf_Event_Html.EditEvent?h_guid='||rawtohex(h_guid));

    -- Add dummy fields to start both array-type input fields.
    -- These dummy values are needed so that the array parameters to
    -- the submit procedure will not be null even if there are no real
    -- response fields.  This would cause a pl/sql error, because array
    -- parameters can't be defaulted.
    htp.formHidden('h_guids', '-1');

    -- popluate the header table
    i := 1;
    hTab(i).def_type := 'FUNCTION';
    hTab(i).value    := null; -- delete is not allowed here
    i := i+1;
    hTab(i).def_type := 'FUNCTION';
    hTab(i).value    := 'Wf_Event_Html.ListSubscriptions?use_guid_only=T&'||
                        'h_event_guid=';
    i := i+1;
    hTab(i).def_type := 'FUNCTION';
    hTab(i).value    := 'Wf_Event_Html.EditEvent?h_guid=';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('SUBSCRIPTIONS');
    hTab(i).attr     := 'id="'||wf_core.translate('SUBSCRIPTIONS')||'"';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('EDIT');
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('NAME');
    hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('DISPLAY_NAME');
    hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('STATUS');
    hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

    -- render table
    Wfe_Html_Util.Simple_Table(hTab, dTab);

    htp.formClose;

    htp.tableOpen(cattributes=>'WIDTH=100%
         summary="' || wf_core.translate('WFE_EVENTS_IN_GROUP') || '"');
    htp.tableRowOpen;
    htp.p('<TD ID="'|| wf_core.translate('WFE_EVENTS_IN_GROUP') || '">');

    htp.tableOpen (calign=>'RIGHT', cattributes=>'summary=""');
    htp.tableRowOpen;
    -- If table is not empty, we allow check/uncheck all/delete.
    if (dTab.COUNT > 0) then
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:checkAll(document.WF_GROUP_EDIT.h_guids)',
               wf_core.translate('SELECT_ALL'),
               wfa_html.image_loc,
               null,
               wf_core.translate('SELECT_ALL'));
      htp.p('</TD>');
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:uncheckAll(document.WF_GROUP_EDIT.h_guids)',
               wf_core.translate('UNSELECT_ALL'),
               wfa_html.image_loc,
               null,
               wf_core.translate('UNSELECT_ALL'));
      htp.p('</TD>');
      -- Delete Screen
      -- Allow user to delete selected events
      -- or add some more event through the find screen.
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:document.WF_GROUP_EDIT.action.value=''DELETE'';'||
               'document.WF_GROUP_EDIT.submit()',
               wf_core.translate('DELETE'),
               wfa_html.image_loc,
               null,
               wf_core.translate('DELETE'));
      htp.p('</TD>');
    end if;
    htp.p('<TD ID="">');
    wfa_html.create_reg_button (
             'javascript:document.WF_GROUP_EDIT.action.value=''FIND'';'||
             'document.WF_GROUP_EDIT.submit()',
             wf_core.translate('WFE_ADD_EVENT'),
             wfa_html.image_loc,
             null,
             wf_core.translate('WFE_ADD_EVENT'));
    htp.p('</TD>');

    htp.tableRowClose;
    htp.tableClose;

    htp.p('</TD>');
    htp.tableRowClose;

    htp.tableRowOpen;
    htp.p('<TD ID="">');

    -- Add submit button
    htp.tableopen (calign=>'RIGHT', cattributes=>'summary=""');
    htp.tableRowOpen;

    htp.p('<TD ID="">');
    wfa_html.create_reg_button ('javascript:document.WF_EVENT_EDIT.submit()',
                              wf_core.translate('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('SUBMIT'));
    htp.p('</TD>');
    htp.p('<TD ID="">');
    wfa_html.create_reg_button ('javascript:history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('CANCEL'));
    htp.p('</TD>');

    htp.tableRowClose;
    htp.tableClose;

    htp.p('</TD>');
    htp.tableRowClose;
    htp.tableClose;
  else

    aligntext := 'CENTER';

    -- Add submit button
    htp.tableopen (calign=>aligntext, cattributes=>'summary=""');
    htp.tableRowOpen;

    htp.p('<TD ID="">');

    wfa_html.create_reg_button ('javascript:document.WF_EVENT_EDIT.submit()',
                              wf_core.translate('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('SUBMIT'));

    htp.p('</TD>');
    htp.p('<TD ID="">');
    wfa_html.create_reg_button ('javascript:history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('CANCEL'));

    htp.p('</TD>');

    htp.tableRowClose;
    htp.tableClose;
  end if;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EditEvent', h_guid);
    wfe_html_util.Error;
end EditEvent;

--
-- EditGroup
--   Delete/Add events from/to group
-- IN
--   h_guid - Global unique id for an event
--   h_func - DELETE|ADD
-- NOTE
--
procedure EditGroup(
  h_guid in raw,
  h_func in varchar2 default 'DELETE',
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*',
  h_type in varchar2 default '*'
)
is
  -- addable event cursor
  -- all events meet the query criteria excluding the group itself
  cursor aevcurs is
    select GUID, DISPLAY_NAME, NAME, TYPE, STATUS
      from WF_EVENTS_VL
     where (h_type = '*' or TYPE = h_type)
       and (h_display_name is null or lower(DISPLAY_NAME) like
              '%'||lower(h_display_name)||'%')
       and (h_name is null or lower(NAME) like '%'||lower(h_name)||'%')
       and (h_status = '*' or STATUS = h_status)
       and GUID <> h_guid
     order by NAME;

  -- deletable event cursor
  -- all events belong to the group
  cursor devcurs is
    select E.GUID, E.DISPLAY_NAME, E.NAME, E.STATUS
      from WF_EVENTS_VL E, WF_EVENT_GROUPS EG
     where EG.GROUP_GUID = h_guid
       and E.GUID = EG.MEMBER_GUID;


  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_name        varchar2(240);
  l_dname       varchar2(80);

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('EVENTS');


  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- list does not get updated after edit, so we add the
  -- following tag to force the reload of page.
  htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');

  htp.title(wf_core.translate('WFE_EDIT_GROUP_TITLE'));
  wfa_html.create_help_function('wf/links/t_d.htm?T_DEFEVGPM');
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_check_all;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null,
            wf_core.translate('WFE_EDIT_GROUP_TITLE'),
            TRUE);

  -- Group to edit
  begin
    select NAME, DISPLAY_NAME
      into l_name, l_dname
      from WF_EVENTS_VL
     where GUID = h_guid;

    -- take care of the double quote problem
    -- l_dname := replace(l_dname, '"', '\"');

  exception
    when NO_DATA_FOUND then
        wf_core.raise('WFE_EVENT_NOTEXIST');
  end;

  htp.tableOpen(calign=>'CENTER',cattributes=>'WIDTH=100% summary=""');

  htp.tableRowOpen;
  wf_core.token('GROUP','<B>'||l_name||'</B>');
  htp.tableData(cvalue=>wf_core.translate('WFE_ADD_SELECTED_TO_GRP'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;

  -- populate the data table
  i := 0;

  if (h_func = 'DELETE') then
    for event in devcurs loop
      i := i+1;
      dTab(i).guid := event.guid;
      dTab(i).col01:= event.display_name;
      dTab(i).col02:= event.name;
      dTab(i).col03:= event.status;

      dTab(i).selectable := TRUE;
      dTab(i).deletable := FALSE;
      dTab(i).hasdetail := FALSE;
    end loop;

  else
    for event in aevcurs loop
      i := i+1;
      dTab(i).guid := event.guid;
      dTab(i).col01:= event.display_name;
      dTab(i).col02:= event.name;
      dTab(i).col03:= event.status;

      dTab(i).selectable := TRUE;
      dTab(i).deletable := FALSE;
      dTab(i).hasdetail := FALSE;
    end loop;
  end if;

  -- Submit Form for Add/Delete
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                     'Wf_Event_Html.SubmitSelectedGEvents',
                 cmethod=>'Get',
                 cattributes=>'TARGET="_top" NAME="WF_GROUP_EDIT"');
  htp.formHidden('h_gguid', rawtohex(h_guid));

  -- Hide the fields for which option you selected. ADD or DELETE
  htp.formHidden(cname=>'action', cvalue=>'');

  -- Url to come back to later
  htp.formHidden(cname=>'url',
                 cvalue=>'Wf_Event_Html.EditEvent?h_guid='||rawtohex(h_guid));

  -- Add dummy fields to start both array-type input fields.
  -- These dummy values are needed so that the array parameters to
  -- the submit procedure will not be null even if there are no real
  -- response fields.  This would cause a pl/sql error, because array
  -- parameters can't be defaulted.
  htp.formHidden('h_guids', '-1');

  -- popluate the header table
  i := 1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('DISPLAY_NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('NAME');
  hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('STATUS');
  hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

  -- render table
  Wfe_Html_Util.Simple_Table(hTab, dTab);

  htp.formClose;

  -- If we generate simple table, we create this check/uncheck all.
  if (i > 0) then
    htp.tableOpen (calign=>'CENTER',cattributes=>'WIDTH=100% summary=""');
    htp.tableRowOpen;
      htp.p('<TD ID="" align="LEFT">');
      htp.anchor('javascript:checkAll(document.WF_GROUP_EDIT.h_guids)',
                     wf_core.translate('SELECT_ALL'), null);
      htp.anchor('javascript:uncheckAll(document.WF_GROUP_EDIT.h_guids)',
                     wf_core.translate('UNSELECT_ALL'), null);
      htp.p('</TD>');
    htp.tableRowClose;
    htp.tableClose;
  end if;

  htp.tableOpen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;
  if (h_func = 'DELETE') then

    -- Delete Screen
    -- Allow user to delete selected events
    -- or add some more event through the find screen.
    htp.p('<TD ID="">');
    wfa_html.create_reg_button (
             'javascript:document.WF_GROUP_EDIT.action.value=''DELETE'';'||
             'document.WF_GROUP_EDIT.submit()',
             wf_core.translate('DELETE_SELECTED'),
             wfa_html.image_loc,
             null,
             wf_core.translate('DELETE_SELECTED'));
    htp.p('</TD>');
    htp.p('<TD "">');
    wfa_html.create_reg_button (
             'javascript:document.WF_GROUP_EDIT.action.value=''FIND'';'||
             'document.WF_GROUP_EDIT.submit()',
             wf_core.translate('ADD'),
             wfa_html.image_loc,
             null,
             wf_core.translate('ADD'));
    htp.p('</TD>');
  else

    -- Add screen
    -- Come back from the Find, now you can add selected events to the group.
    htp.p('<TD ID"">');
    wfa_html.create_reg_button (
             'javascript:document.WF_GROUP_EDIT.action.value=''ADD'';'||
             'document.WF_GROUP_EDIT.submit()',
             wf_core.translate('ADD_SELECTED'),
             wfa_html.image_loc,
             null,
             wf_core.translate('ADD_SELECTED'));
    htp.p('</TD>');
    htp.p('<TD ID="">');
    wfa_html.create_reg_button ('javascript:history.back()',
                                wf_core.translate ('CANCEL'),
                                wfa_html.image_loc,
                                null,
                                wf_core.translate ('CANCEL'));

    htp.p('</TD>');
  end if;
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;
exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EditGroup', rawtohex(h_guid));
    wfe_html_util.Error;
end EditGroup;

--
-- EditSystem
--   Create/Update an event
-- IN
--   h_guid - Global unique id for a system
-- NOTE
--
procedure EditSystem(
  h_guid in raw default null)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list

  l_name        varchar2(240);
  l_dname       varchar2(80);
  l_desc        varchar2(2000);
  l_mname       varchar2(80);
  l_mguid       raw(16);

  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFPREF_LOV'));
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;

  htp.title(wf_core.translate('WFE_EDIT_SYSTEM_TITLE'));
  wfa_html.create_help_function('wf/links/t_d.htm?T_DEFEVSYS');
  fnd_document_management.get_open_dm_display_window;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindEvent',
            wf_core.translate('WFE_EDIT_SYSTEM_TITLE'),
            TRUE);

  -- populate the appropriate values in the form if editing an exist guid
  if (h_guid is not null) then
    begin
      select NAME, DISPLAY_NAME, DESCRIPTION, MASTER_GUID
        into l_name, l_dname, l_desc, l_mguid
        from WF_SYSTEMS
       where GUID = h_guid;

    exception
      when NO_DATA_FOUND then
        wf_core.raise('WFE_SYSTEM_NOTEXIST');
    end;

    if (l_mguid is not null) then
      begin
        select NAME
          into l_mname
          from WF_SYSTEMS
         where GUID = l_mguid;
      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_mguid));
          l_mname := wf_core.translate('WFE_EVENT_NOGUID');
      end;
    end if;

    -- take care of the double quote problem
    -- There should be no any kind of quote for name and generate_function.
    -- Description is handle entirely differently, no need for substitution.
    -- Single quote is ok becuase html does not treat it special.
    l_dname := replace(l_dname, '"', '\"');
    l_mname := replace(l_mname, '"', '\"');


  end if;
  -- Form
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                     'wf_event_html.SubmitSystem',
               cmethod=>'Get',
               cattributes=>'TARGET="_top" NAME="WF_SYSTEM_EDIT"');

  -- GUID
  -- do not display it if it is null
  if (h_guid is not null) then
    htp.p('<!-- GUID: '||rawtohex(h_guid)||' -->');
  end if;
  htp.formHidden('h_guid', rawtohex(h_guid));

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_name">' ||
                    wf_core.translate('NAME') || '</LABEL>',
                    calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_name', csize=>40,
                                     cmaxlength=>240, cvalue=>l_name,
                cattributes=>'id="i_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Display Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_display_name">' ||
             wf_core.translate('DISPLAY_NAME') || '</LABEL>',
             calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_display_name', csize=>60,
                                     cmaxlength=>80,
                cattributes=>'id="i_display_name"'),
                calign=>'Left', cattributes=>'id=""');
  htp.tableRowClose;

  -- Description
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_description">' ||
           wf_core.translate('DESCRIPTION') || '</LABEL>',
           calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                            cname=>'h_description',
                            nrows=>2,
                            ncolumns=>60,
                            cwrap=>'SOFT',
                            cattributes=>'maxlength=2000
                            id="i_description"')
                        ||l_desc
                        ||htf.formTextareaClose,
                calign=>'Left',
                cattributes=>'id=""');
  htp.tableRowClose;

  -- Master GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_master">' ||
            wf_core.translate('MASTER') || '</LABEL>',
            calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_master_guid', l_mguid);
  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_master_guid'||
           '&p_display_name='||'SYSTEM'||
           '&p_validation_callback=wf_event_html.wf_system_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SYSTEM_EDIT.h_master_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SYSTEM_EDIT.display_master.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_SYSTEM_EDIT.display_master.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_master', csize=>32,
             cmaxlength=>240,
             cattributes=>'id="i_master"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- URL to go back to
  htp.formHidden('url', 'Wf_Event_Html.ListSystems');

  htp.tableClose;
  htp.formClose;

  -- add values that may contain double quote back through javascript
  if (h_guid is not null) then
    htp.p('<SCRIPT>');
    htp.p('  document.WF_SYSTEM_EDIT.h_display_name.value="'||l_dname||'"');
    htp.p('  document.WF_SYSTEM_EDIT.display_master.value="'||l_mname||'"');
    htp.p('</SCRIPT>');
  end if;

  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD "" id="">');

  wfa_html.create_reg_button ('javascript:document.WF_SYSTEM_EDIT.submit()',
                              wf_core.translate('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('SUBMIT'));

  htp.p('</TD>');
  htp.p('<TD ID="">');
  wfa_html.create_reg_button ('javascript:history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('CANCEL'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EditSystem', h_guid);
    wfe_html_util.Error;
end EditSystem;

--
-- EditAgent
--   Create/Update an agent
-- IN
--   h_guid - Global unique id for an agent
-- NOTE
--
procedure EditAgent(
  h_guid in raw default null)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list

  l_name        varchar2(80);
  l_dname       varchar2(80);
  l_desc        varchar2(2000);
  l_protocol    varchar2(8);
  l_address     varchar2(80);
  l_system      varchar2(80);  -- display_system
  l_sysguid     raw(16);
  l_qhandler    varchar2(240);
  l_qname       varchar2(80);
  l_direction   varchar2(8);
  l_status      varchar2(8);

  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFPREF_LOV'));
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_onmouseover varchar2(240) := wfa_html.replace_onMouseOver_quotes(wf_core.translate('FIND'));

  select_in     varchar2(8);
  select_out    varchar2(8);
  select_enable varchar2(8);
  select_disable varchar2(8);

  cursor protocurs is
    select LOOKUP_CODE, MEANING
      from WF_LOOKUPS
     where LOOKUP_TYPE = 'WF_AQ_PROTOCOLS'
     order by lookup_code desc;

  selected boolean := FALSE;  -- indicator if a lookup has been selected.
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;

  htp.title(wf_core.translate('WFE_EDIT_AGENT_TITLE'));
  wfa_html.create_help_function('wf/links/t_d.htm?T_DEFEVAGT');
  fnd_document_management.get_open_dm_display_window;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindAgent',
            wf_core.translate('WFE_EDIT_AGENT_TITLE'),
            TRUE);

  -- populate the appropriate values in the form if editing an exist guid
  if (h_guid is not null) then
    begin
      select A.NAME, A.DISPLAY_NAME, A.DESCRIPTION, A.PROTOCOL, A.ADDRESS,
             A.SYSTEM_GUID, A.QUEUE_HANDLER, A.QUEUE_NAME,
             A.DIRECTION, A.STATUS, S.NAME
        into l_name, l_dname, l_desc, l_protocol, l_address,
             l_sysguid, l_qhandler, l_qname,
             l_direction, l_status, l_system
        from WF_AGENTS A, WF_SYSTEMS S
       where A.GUID = h_guid
         and A.SYSTEM_GUID = S.GUID;

      -- take care of the double quote problem
      -- Description is handle entirely differently, no need for substitution.
      -- Single quote is ok becuase html does not treat it special.
      l_dname := replace(l_dname, '"', '\"');
      l_system := replace(l_system, '"', '\"');

      if (l_direction = 'IN') then
        select_in := 'SELECTED';
--    elsif (l_direction = 'OUT') then
      else
        select_out := 'SELECTED';
--      else
--        select_any := 'SELECTED';
      end if;

      if (l_status = 'ENABLED') then
        select_enable := 'SELECTED';
        select_disable := null;
      else
        select_enable := null;
        select_disable := 'SELECTED';
      end if;
    exception
      when NO_DATA_FOUND then
        wf_core.raise('WFE_AGENT_NOTEXIST');
    end;

  end if;

  -- Form
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                     'wf_event_html.SubmitAgent',
               cmethod=>'Get',
               cattributes=>'TARGET="_top" NAME="WF_AGENT_EDIT"');

  -- GUID
  -- do not display it if it is null
  if (h_guid is not null) then
    htp.p('<!-- GUID: '||rawtohex(h_guid)||' -->');
  end if;
  htp.formHidden('h_guid', rawtohex(h_guid));

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_name">' ||
            wf_core.translate('NAME') || '</LABEL>',
            calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_name', csize=>60,
                                     cmaxlength=>80, cvalue=>l_name,
                cattributes=>'id="i_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Display Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_display_name">' ||
             wf_core.translate('DISPLAY_NAME') || '</LABEL>',
             calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_display_name', csize=>60,
                                     cmaxlength=>80,
                cattributes=>'id="i_display_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Description
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_description">' ||
           wf_core.translate('DESCRIPTION') || '</LABEL>',
           calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                            cname=>'h_description',
                            nrows=>2,
                            ncolumns=>60,
                            cwrap=>'SOFT',
                            cattributes=>'maxlength=2000 id="i_description"')
                        ||l_desc
                        ||htf.formTextareaClose,
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Protocol
  template := htf.formSelectOpen('h_protocol',cattributes=>'id="i_protocol"')
           ||wf_core.newline;
  for prtr in protocurs loop
    if (h_guid is not null and l_protocol is not null) then
      if (prtr.lookup_code = l_protocol) then
        template := template||htf.formSelectOption(prtr.meaning, 'SELECTED',
                    'VALUE="'||prtr.lookup_code||'"')||wf_core.newline;
        selected := TRUE;
      else
        template := template||htf.formSelectOption(prtr.meaning, '',
                    'VALUE="'||prtr.lookup_code||'"')||wf_core.newline;
      end if;
    else
      if (not selected) then
        template := template||htf.formSelectOption(prtr.meaning, 'SELECTED',
                    'VALUE="'||prtr.lookup_code||'"')||wf_core.newline;
        selected := TRUE;
      else
        template := template||htf.formSelectOption(prtr.meaning, '',
                    'VALUE="'||prtr.lookup_code||'"')||wf_core.newline;
      end if;
    end if;
  end loop;
  -- if it is still not selected, this must be a custom code not yet in
  -- WF_AQ_PROTOCOLS, preserve it.
  if (not selected) then
    template := template||htf.formSelectOption(l_protocol, 'SELECTED',
                'VALUE="'||l_protocol||'"')||wf_core.newline;
    selected := TRUE;
  end if;
  template := template||htf.formSelectClose;

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_protocol">' ||
            wf_core.translate('PROTOCOL') || '</LABEL>',
            calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
--  htp.tableData(cvalue=>htf.formText(cname=>'h_protocol', csize=>8,
--                                     cmaxlength=>8, cvalue=>l_protocol),
--                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Address
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_address">' ||
         wf_core.translate('ADDRESS') || '</LABEL>',
         calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_address', csize=>80,
                                     cmaxlength=>240, cvalue=>l_address,
                cattributes=>'id="i_address"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- System
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_system">' ||
           wf_core.translate('SYSTEM') || '</LABEL>',
           calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_system_guid', null);
  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_system_guid'||
           '&p_display_name='||'SYSTEM'||
           '&p_validation_callback=wf_event_html.wf_system_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_AGENT_EDIT.h_system_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_AGENT_EDIT.display_system.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_AGENT_EDIT.display_system.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_system', csize=>32,
                cmaxlength=>240,cattributes=>'id="i_system"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- Queue Handler
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_queue_handler">' ||
          wf_core.translate('QUEUE_HANDLER') || '</LABEL>',
          calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_qhandler', csize=>60,
                                     cmaxlength=>240, cvalue=>l_qhandler,
                cattributes=>'id="i_queue_handler"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Queue Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_queue_name">' ||
        wf_core.translate('QUEUE_NAME') || '</LABEL>', calign=>'Right',
         cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_qname', csize=>60,
                                     cmaxlength=>80, cvalue=>l_qname,
                cattributes=>'id="i_queue_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Direction
  template := htf.formSelectOpen('h_direction', cattributes=>'id="i_direction"')||wf_core.newline||
/*
              htf.formSelectOption(wf_core.translate('ANY'),
                                   select_any,'VALUE="ANY"')
              ||wf_core.newline||
*/
              htf.formSelectOption(wf_core.translate('IN'),
                                   select_in,'VALUE="IN"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('OUT'),
                                   select_out,'VALUE="OUT"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_direction">' ||
                wf_core.translate('DIRECTION') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Status
  template := htf.formSelectOpen('h_status',cattributes=>'id="i_status"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('ENABLED'),
                                   select_enable,'VALUE="ENABLED"')||
              wf_core.newline||
              htf.formSelectOption(wf_core.translate('DISABLED'),
                                   select_disable,'VALUE="DISABLED"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_status">' ||
                wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- URL to go back to
  htp.formHidden('url', 'Wf_Event_Html.ListAgents');

  htp.tableClose;
  htp.formClose;

  -- add values that may contain double quote back through javascript
  if (h_guid is not null) then
    htp.p('<SCRIPT>');
    htp.p('  document.WF_AGENT_EDIT.h_display_name.value="'||l_dname||'"');
    htp.p('  document.WF_AGENT_EDIT.display_system.value="'||l_system||'"');
    htp.p('</SCRIPT>');
  end if;

  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_AGENT_EDIT.submit()',
                              wf_core.translate('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('SUBMIT'));

  htp.p('</TD>');
  htp.p('<TD ID="">');
  wfa_html.create_reg_button ('javascript:history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('CANCEL'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EditAgent', h_guid);
    wfe_html_util.Error;
end EditAgent;

--
-- EditSubscription
--   Create/Update a subscription
-- IN
--   h_guid - Global unique id for a subscription
-- NOTE
--
procedure EditSubscription(
  h_guid in raw default null,
  h_sguid in raw default null,
  h_eguid in raw default null)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list

  l_sysguid raw(16);
  l_srctype varchar2(8);
  l_srcagnguid raw(16);
  l_evtguid raw(16);
  l_phase number;
  l_status varchar2(8);
  l_ruled varchar2(8);
  l_outagnguid raw(16);
  l_toagnguid raw(16);
  l_priority number;
  l_rulef varchar2(240);
  l_wfptype varchar2(30);
  l_wfpname varchar2(30);
  l_param varchar2(4000);
  l_ownname varchar2(30);
  l_owntag varchar2(30);
  l_customization_level varchar2(1);
  l_desc  varchar2(240);

  l_system_name  varchar2(80);
  l_event_name   varchar2(240);
  l_srcagn_dname  varchar2(240);
  l_outagn_dname  varchar2(240);
  l_toagn_dname   varchar2(240);
  l_wfptype_dname varchar2(80);
  l_wfpname_dname varchar2(80);

  select_enable   varchar2(8);
  select_disable  varchar2(8);
  select_any      varchar2(8);
  select_local    varchar2(8);
  select_external varchar2(8);
  select_error    varchar2(8);
  select_key      varchar2(8);
  select_message  varchar2(8);
  select_function varchar2(8);
  select_agent    varchar2(8);
  select_workflow varchar2(8);
  select_low      varchar2(8);
  select_high     varchar2(8);
  select_normal   varchar2(8);

  select_custom_core varchar2(8);
  select_custom_limit varchar2(8);
  select_custom_extend varchar2(8);
  select_custom_user varchar2(8);

  -- priority values
  l_low           varchar2(6) := '99';
  l_normal        varchar2(6) := '50';
  l_high          varchar2(6) := '1';

  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFPREF_LOV'));
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_onmouseover varchar2(240) := wfa_html.replace_onMouseOver_quotes(wf_core.translate('FIND'));

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('SUBSCRIPTIONS');

  -- Set page title
  htp.headOpen;

  htp.title(wf_core.translate('WFE_EDIT_SUBSC_TITLE'));
  wfa_html.create_help_function('wf/links/t_d.htm?'||'T_DEFEVSUB');
  fnd_document_management.get_open_dm_display_window;

  -- JavaScript for checkagent
  /** No longer required - XML Gateway has single consumer queues
     which do not require a To Agent
  htp.p('<SCRIPT LANGUAGE="JavaScript">');
  htp.p('<!-- Hide from old browsers');
  htp.p('function checkagentsubmit() {
           if (document.WF_SUBSC_EDIT.display_out_agent.value !'||'= "" &&
               document.WF_SUBSC_EDIT.display_to_agent.value == "") {
             window.alert('''||wf_core.translate('WFE_CHECKAGENT_ERROR')||''');
           } else {
             document.WF_SUBSC_EDIT.submit();
           }
         }'
        );
  htp.p('<!-- done hiding from old browsers -->');
  htp.p('</SCRIPT>');
  **/

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE,
            owa_util.get_owa_service_path||'wf_event_html.FindSubscription',
            wf_core.translate('WFE_EDIT_SUBSC_TITLE'),
            TRUE);

  -- populate the appropriate values in the form if editing an exist guid
  if (h_guid is not null) then
    begin
      select SYSTEM_GUID,
             SOURCE_TYPE,
             SOURCE_AGENT_GUID,
             EVENT_FILTER_GUID,
             PHASE,
             STATUS,
             OWNER_NAME,
             OWNER_TAG,
             RULE_DATA,
             RULE_FUNCTION,
             OUT_AGENT_GUID,
             TO_AGENT_GUID,
             PRIORITY,
             WF_PROCESS_TYPE,
             WF_PROCESS_NAME,
             PARAMETERS,
	     CUSTOMIZATION_LEVEL,
             DESCRIPTION
        into l_sysguid,
             l_srctype,
             l_srcagnguid,
             l_evtguid,
             l_phase,
             l_status,
             l_ownname,
             l_owntag,
             l_ruled,
             l_rulef,
             l_outagnguid,
             l_toagnguid,
             l_priority,
             l_wfptype,
             l_wfpname,
             l_param,
             l_customization_level,
             l_desc
        from WF_EVENT_SUBSCRIPTIONS
       where GUID = h_guid;

      -- take care of the double quote problem
      -- Description is handle entirely differently, no need for substitution.
      -- Single quote is ok becuase html does not treat it special.
      l_ownname := replace(l_ownname, '"', '\"');
      l_owntag := replace(l_owntag, '"', '\"');

      -- Select From System
      if (l_srctype = 'EXTERNAL') then
        select_external := 'SELECTED';
      elsif (l_srctype = 'LOCAL') then
        select_local := 'SELECTED';
      else
        select_error := 'SELECTED';
      end if;

      -- Select Status
      if (l_status = 'ENABLED') then
        select_enable := 'SELECTED';
      else
        select_disable := 'SELECTED';
      end if;

      -- Select Rule Data
      if (l_ruled = 'MESSAGE') then
        select_message := 'SELECTED';
      else
        select_key := 'SELECTED';
      end if;

-- Stuff for Customization Level
      if l_customization_level = 'C' then
	select_custom_core := 'SELECTED';
  	select_custom_limit := null;
  	select_custom_extend := null;
  	select_custom_user := null;
      elsif l_customization_level = 'L' then
	select_custom_core := null;
  	select_custom_limit := 'SELECTED';
  	select_custom_extend := null;
  	select_custom_user := null;
      elsif l_customization_level = 'U' then
	select_custom_core := null;
  	select_custom_limit := null;
  	select_custom_extend := null;
  	select_custom_user := 'SELECTED';
      end if;

      -- Use the same priority criteria as in notification
      if (l_priority < 34) then
        select_high := 'SELECTED';
        l_high := to_char(l_priority);  -- to preserve the priority
      elsif (l_priority > 67) then
        select_low := 'SELECTED';
        l_low  := to_char(l_priority);
      else
        select_normal := 'SELECTED';
        l_normal := to_char(l_priority);
      end if;

    exception
      when NO_DATA_FOUND then
        wf_core.raise('WFE_SUBSC_NOTEXIST');
    end;

    -- Get System Name
    if (l_sysguid is not null) then
      begin
        select NAME
          into l_system_name
          from WF_SYSTEMS
         where GUID = l_sysguid;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_sysguid));
          l_system_name := wf_core.translate('WFE_SYSTEM_NOGUID');
      end;

      l_system_name := replace(l_system_name, '"', '\"');
    end if;

    -- Get Event Name
    if (l_evtguid is not null) then
      begin
        select NAME
          into l_event_name
          from WF_EVENTS_VL
         where GUID = l_evtguid;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_evtguid));
          l_event_name := wf_core.translate('WFE_EVENT_NOGUID');
      end;

    end if;

    -- Get Agent Name
    if (l_srcagnguid is not null) then
      begin
        select A.NAME||'@'||S.NAME
          into l_srcagn_dname
          from WF_AGENTS A, WF_SYSTEMS S
         where A.GUID = l_srcagnguid
           and A.SYSTEM_GUID (+)= S.GUID;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_srcagnguid));
          l_srcagn_dname := wf_core.translate('WFE_AGENT_NOGUID');
      end;

    end if;

    if (l_outagnguid is not null) then
      begin
        select A.NAME||'@'||S.NAME
          into l_outagn_dname
          from WF_AGENTS A, WF_SYSTEMS S
         where A.GUID = l_outagnguid
           and A.SYSTEM_GUID (+)= S.GUID;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_outagnguid));
          l_outagn_dname := wf_core.translate('WFE_AGENT_NOGUID');
      end;

    end if;

    if (l_toagnguid is not null) then
      begin
        select A.NAME||'@'||S.NAME
          into l_toagn_dname
          from WF_AGENTS A, WF_SYSTEMS S
         where A.GUID = l_toagnguid
           and A.SYSTEM_GUID (+)= S.GUID;

      exception
        when NO_DATA_FOUND then
          wf_core.token('GUID', rawtohex(l_toagnguid));
          l_toagn_dname := wf_core.translate('WFE_AGENT_NOGUID');
      end;

    end if;

    -- Get WF Process Type Name
    if (l_wfptype is not null) then
      begin
        select DISPLAY_NAME
          into l_wfptype_dname
          from WF_ITEM_TYPES_VL
         where NAME = l_wfptype;

      exception
        when NO_DATA_FOUND then
          l_wfptype_dname := NULL;
          -- it is ok if this process does not exist in the local system
      end;

      l_wfptype_dname := replace(l_wfptype_dname, '"', '\"');
    end if;

  -- new subscription, default some values
  else

    l_customization_level := 'U';
    select_local  := 'SELECTED';
    select_enable := 'SELECTED';
    select_normal := 'SELECTED';

    -- populate the system info
    if (h_sguid is not null) then
      begin
        select NAME
          into l_system_name
          from WF_SYSTEMS
         where GUID = h_sguid;

      exception
        when NO_DATA_FOUND then
          null;  -- do not do anything
      end;

      l_system_name := replace(l_system_name, '"', '\"');
    end if;

    -- populate the event filter info
    if (h_eguid is not null) then
      begin
        select NAME
          into l_event_name
          from WF_EVENTS_VL
         where GUID = h_eguid;

      exception
        when NO_DATA_FOUND then
          null;  -- do not do anything
      end;
    end if;
  end if;

  -- Hidden Form
  htp.p('<FORM NAME="WF_HIDDEN">');
  htp.formHidden('h_out', 'OUT');
  htp.formHidden('h_in', 'IN');
  htp.formClose;

  -- Form
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                     'wf_event_html.SubmitSubscription',
               cmethod=>'Get',
               cattributes=>'TARGET="_top" NAME="WF_SUBSC_EDIT"');

  -- GUID
  -- do not display
  if (h_guid is not null) then
    htp.p('<!-- GUID: '||rawtohex(h_guid)||' -->');
  end if;
  htp.formHidden('h_guid', rawtohex(h_guid));

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 width=100%
           summary=""');

  -- Subscriber
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<B>'||wf_core.translate('SUBSCRIBER')||'</B>',
                calign=>'Left',
                ccolspan=>'2',
                cattributes=>'id=""');
  htp.tableRowClose;

  -- System GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_system">' ||
        wf_core.translate('SYSTEM') || '</LABEL>',
        calign=>'Right',cattributes=>'id=""');
  htp.formHidden('h_system_guid', l_sysguid);
  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_system_guid'||
           '&p_display_name='||'SYSTEM'||
           '&p_validation_callback=wf_event_html.wf_system_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_system_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.display_system.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.display_system.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_system', csize=>32,
                cmaxlength=>240,cattributes=>'id="i_system"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- Trigger
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<B>'||wf_core.translate('TRIGGER')||'</B>',
                calign=>'Left',
                ccolspan=>'2',cattributes=>'id=""');
  htp.tableRowClose;

  -- Source Type
  template := htf.formSelectOpen('h_source_type',cattributes=>'id="i_source_type"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('LOCAL'),
                         select_local,'VALUE="LOCAL"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('EXTERNAL'),
                         select_external,'VALUE="EXTERNAL"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('ERROR'),
                         select_error,'VALUE="ERROR"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_source_type">' ||
                wf_core.translate('SOURCE_TYPE') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Event Filter GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_event">' ||
             wf_core.translate('EVENT_FILTER') || '</LABEL>',
             calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_event_guid', l_evtguid);

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_event_guid'||
           '&p_display_name='||'WFE_FIND_EVENT'||
           '&p_validation_callback=wf_event_html.wf_event_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_event_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.display_event.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.display_event.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_event', csize=>60,
                cmaxlength=>240,cattributes=>'id="i_event"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- Source Agent GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_source_agent">' ||
     wf_core.translate('SOURCE_AGENT') || '</LABEL>',
     calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_source_agent_guid', l_srcagnguid);

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_source_agent_guid'||
           '&p_display_name='||'WFE_FIND_AGENT'||
           '&p_validation_callback=wf_event_html.wf_agent_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_source_agent_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.display_source_agent.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.display_source_agent.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_source_agent', csize=>60,
                cmaxlength=>240,cattributes=>'id="i_source_agent"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- Execution Control
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<B>'||wf_core.translate('EXECUTION_CONTROL')||'</B>',
                calign=>'Left',
                ccolspan=>'2',cattributes=>'id=""');
  htp.tableRowClose;

  -- Phase
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_phase">' ||
       wf_core.translate('PHASE') || '</LABEL>',
       calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_phase', csize=>16,
                                     cmaxlength=>16, cvalue=>to_char(l_phase),
                cattributes=>'id="i_phase"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Status
  template := htf.formSelectOpen('h_status',cattributes=>'id="i_status"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('ENABLED'),
                         select_enable,'VALUE="ENABLED"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('DISABLED'),
                         select_disable,'VALUE="DISABLED"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_status">' ||
                wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Rule Data
  template := htf.formSelectOpen('h_rule_data',cattributes=>'id="i_rule_data"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('KEY'),
                         select_key,'VALUE="KEY"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('MESSAGE'),
                         select_message,'VALUE="MESSAGE"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_rule_data">' ||
                wf_core.translate('RULE_DATA') || '</LABEL>',
                calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Action
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<B>'||wf_core.translate('ACTION')||'</B>',
                calign=>'Left',
                ccolspan=>'2',cattributes=>'id=""');
  htp.tableRowClose;

  -- Rule Function
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_rule_function">' ||
                wf_core.translate('RULE_FUNCTION') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_rule_function', csize=>60,
                                     cmaxlength=>240, cvalue=>l_rulef,
                cattributes=>'id="i_rule_function"' ),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- WF Process Type
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_process_type">' ||
        wf_core.translate('WF_PROCESS_TYPE') || '</LABEL>',
        calign=>'Right',cattributes=>'id=""');
  htp.formHidden('h_wfptype_dname', l_wfptype_dname);

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_wfptype_dname'||
           '&p_display_name='||'ITEMTYPE'||
           '&p_validation_callback=wf_event_html.wf_itemtype_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_wfptype_dname.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.h_wfptype.value'||
           '&p_display_key='||'Y'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.h_wfptype.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tableData(cvalue=>htf.formText(cname=>'h_wfptype', csize=>30,
                                     cmaxlength=>30, cvalue=>l_wfptype,
                cattributes=>'id="i_process_type"')||
                '<A href='||l_url||'>'||
                '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- WF Process Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_process_name">' ||
        wf_core.translate('WF_PROCESS_NAME') || '</LABEL>',
        calign=>'Right',cattributes=>'id=""');
  htp.formHidden('h_wfptn');  -- holding the hidden field value

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_wfpname'||
           '&p_display_name='||'PROCESS'||
           '&p_validation_callback=wf_event_html.wf_processname_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_wfptn.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.h_wfpname.value'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.h_wfpname.value'||
           '&p_display_key='||'Y'||
           '&p_param1=top.opener.parent.document.WF_SUBSC_EDIT.h_wfptype.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tableData(cvalue=>htf.formText(cname=>'h_wfpname', csize=>30,
                                     cmaxlength=>30, cvalue=>l_wfpname,
                cattributes=>'id="i_process_name"')||
                '<A href='||l_url||'>'||
                '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
                calign=>'Left',cattributes=>'id=""');

  htp.tableRowClose;

  -- Out Agent GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_out_agent">' ||
        wf_core.translate('OUT_AGENT') || '</LABEL>',
        calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_out_agent_guid', l_outagnguid);

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_out_agent_guid'||
           '&p_display_name='||'AGENT'||
           '&p_validation_callback=wf_event_html.wf_agent_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_out_agent_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.display_out_agent.value'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.display_out_agent.value'||
           '&p_display_key='||'Y'||
           '&p_param1=top.opener.parent.document.WF_HIDDEN.h_out.value'||
           '&p_param2=top.opener.parent.document.WF_SUBSC_EDIT.display_system.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_out_agent', csize=>60,
                cmaxlength=>240,
                cattributes=>'id="i_out_agent"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- To Agent GUID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_to_agent">'
      ||wf_core.translate('TO_AGENT') || '</LABEL>',
      calign=>'right',cattributes=>'id=""');
  htp.formHidden('h_to_agent_guid', l_toagnguid);

  -- add LOV here:
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
           REPLACE('wf_lov.display_lov?p_lov_name='||'h_to_agent_guid'||
           '&p_display_name='||'AGENT'||
           '&p_validation_callback=wf_event_html.wf_agent_val'||
           '&p_dest_hidden_field=top.opener.parent.document.WF_SUBSC_EDIT.h_to_agent_guid.value'||
           '&p_current_value=top.opener.parent.document.WF_SUBSC_EDIT.display_to_agent.value'||
           '&p_dest_display_field=top.opener.parent.document.WF_SUBSC_EDIT.display_to_agent.value'||
           '&p_display_key='||'Y'||
           '&p_param1=top.opener.parent.document.WF_HIDDEN.h_in.value',
           ' ', '%20')||''''||',500,500)';

  -- print everything together so there is no gap.
  htp.tabledata(htf.formText(cname=>'display_to_agent', csize=>60,
                cmaxlength=>240,
              cattributes=>'id="i_to_agent"')||
             '<A href='||l_url||'>'||
             '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                  l_message||'" onmouseover="window.status='||''''||
                  l_message||''''||';return true"></A>',
              cattributes=>'id=""');

  htp.tableRowClose;

  -- Priority
  template := htf.formSelectOpen('h_priority',cattributes=>'id="i_priority"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('NORMAL'),
                         select_normal,'VALUE='||l_normal)
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('HIGH'),
                         select_high,'VALUE='||l_high)
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('LOW'),
                         select_low,'VALUE='||l_low)
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_priority">' ||
                wf_core.translate('PRIORITY') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Parameters
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_parameters">' ||
      wf_core.translate('PARAMETERS') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                            cname=>'h_parameters',
                            nrows=>2,
                            ncolumns=>60,
                            cwrap=>'SOFT',
                            cattributes=>'maxlength=4000
                            id="i_parameters"')
                        ||l_param
                        ||htf.formTextareaClose,
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Documentation
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<B>'||wf_core.translate('DOCUMENTATION')||'</B>',
                calign=>'Left',
                ccolspan=>'2',cattributes=>'id=""');
  htp.tableRowClose;

  -- Owner Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_owner_name">' ||
     wf_core.translate('OWNER_NAME') || '</LABEL>',
     calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_owner_name', csize=>30,
                                     cmaxlength=>30,
                cattributes=>'id="i_owner_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Owner Tag
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_owner_tag">' ||
      wf_core.translate('OWNER_TAG') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_owner_tag', csize=>30,
                                     cmaxlength=>30,
                cattributes=>'id="i_owner_tag"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Customization Level
  if wf_events_pkg.g_Mode = 'FORCE' then
  template := htf.formSelectOpen('h_custom_level',cattributes=>'id="i_custom_level"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_C'),
                                   select_custom_core,'VALUE="C"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_L'),
                                   select_custom_limit,'VALUE="L"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_U'),
                                   select_custom_user,'VALUE="U"')
              ||wf_core.newline||
              htf.formSelectClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_custom_level">' ||
                    wf_core.translate('WFE_CUSTOM_LEVEL') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;
 else
   if l_customization_level='L' then    -- Bug 2756800
     template := htf.formSelectOpen('h_custom_level',cattributes=>'id="i_custom_level"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_C'),
                                   select_custom_core,'VALUE="C"')
              ||wf_core.newline||
              htf.formSelectOption(wf_core.translate('WFE_CUSTOM_LEVEL_L'),
                                   select_custom_limit,'VALUE="L"')
              ||wf_core.newline||
              htf.formSelectClose;
     htp.tableRowOpen;
     htp.tableData(cvalue=>'<LABEL FOR="i_custom_level">' ||
                    wf_core.translate('WFE_CUSTOM_LEVEL') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
     htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
     htp.tableRowClose;
   else
     htp.tableRowOpen;
     htp.tableData(cvalue=>wf_core.translate('WFE_CUSTOM_LEVEL'),
                calign=>'Right',cattributes=>'id=""');
     htp.tableData(cvalue=>wf_core.translate('WFE_CUSTOM_LEVEL_'||l_customization_level),
		calign=>'Left',cattributes=>'id=""');
     htp.formHidden('h_custom_level', l_customization_level);
   end if;		-- Bug 2756800
  end if;

  -- Description
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_description">' ||
      wf_core.translate('DESCRIPTION') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                            cname=>'h_description',
                            nrows=>2,
                            ncolumns=>60,
                            cwrap=>'SOFT',
                            cattributes=>'maxlength=240 id="i_description"')
                        ||l_desc
                        ||htf.formTextareaClose,
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- URL to go back to
  htp.formHidden('url', 'Wf_Event_Html.ListSubscriptions');

  htp.tableClose;
  htp.formClose;

  -- add values that may contain double quote back through javascript
  -- ### although some of the values are now the internal name; hence,
  -- ### no more double quote for them, but we left this mechanism behind
  -- ### for now.
  --
  htp.p('<SCRIPT>');
  htp.p('  document.WF_SUBSC_EDIT.h_owner_name.value="'||l_ownname||'"');
  htp.p('  document.WF_SUBSC_EDIT.h_owner_tag.value="'||l_owntag||'"');
  htp.p('  document.WF_SUBSC_EDIT.display_event.value="'||l_event_name||'"');
  htp.p('  document.WF_SUBSC_EDIT.display_system.value="'||
        l_system_name||'"');
  htp.p('  document.WF_SUBSC_EDIT.display_source_agent.value="'||
        l_srcagn_dname||'"');
  htp.p('  document.WF_SUBSC_EDIT.display_out_agent.value="'||
        l_outagn_dname||'"');
  htp.p('  document.WF_SUBSC_EDIT.display_to_agent.value="'||
        l_toagn_dname||'"');
  htp.p('</SCRIPT>');

  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_SUBSC_EDIT.submit()',
                              wf_core.translate('SUBMIT'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('SUBMIT'));

  htp.p('</TD>');
  htp.p('<TD ID="">');
  wfa_html.create_reg_button ('javascript:history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('CANCEL'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EditSubscription');
    wfe_html_util.Error;
end EditSubscription;

--
-- SubmitEvent
--   Submit an event to database
-- IN
--   h_guid - Global unique id for an event
--   h_name - Event name
--   h_type - Event type: EVENT|GROUP
--   h_status - Event status: ENABLED|DISABLED
--   h_generate_function - Event function
--   h_owner_name
--   h_owner_tag
--   h_display_name
--   h_description
--   h_custom_level
-- NOTE
--
procedure SubmitEvent(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  h_type              in varchar2,
  h_status            in varchar2,
  h_generate_function in varchar2,
  h_owner_name        in varchar2,
  h_owner_tag         in varchar2,
  h_custom_level      in varchar2,
  url                 in varchar2)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_guid raw(16);
  row_id varchar2(30);
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  if (h_guid is not null) then
    l_guid := hextoraw(h_guid);

    -- update
    Wf_Events_Pkg.Update_Row(
      X_GUID=>l_guid,
      X_NAME=>h_name,
      X_TYPE=>h_type,
      X_STATUS=>h_status,
      X_GENERATE_FUNCTION=>h_generate_function,
      X_OWNER_NAME=>h_owner_name,
      X_OWNER_TAG=>h_owner_tag,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description,
      X_CUSTOMIZATION_LEVEL=>h_custom_level,
      X_LICENSED_FLAG=>'N'
    );

  else
    l_guid := sys_guid();

    -- insert
    Wf_Events_Pkg.Insert_Row(
      X_ROWID=>row_id,
      X_GUID=>l_guid,
      X_NAME=>h_name,
      X_TYPE=>h_type,
      X_STATUS=>h_status,
      X_GENERATE_FUNCTION=>h_generate_function,
      X_OWNER_NAME=>h_owner_name,
      X_OWNER_TAG=>h_owner_tag,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description,
      X_CUSTOMIZATION_LEVEL=>h_custom_level,
      X_LICENSED_FLAG=>'N'
    );

  end if;

  -- If url is not specified, we know that it is from the edit event screen
  -- for group, so return to that screen with the newly created event guid.
  if (url is null or url = '') then
    Wf_Event_Html.EditEvent(l_guid);

  -- Go to a specific url
  else
    Wfe_Html_Util.gotoURL(url);
  end if;

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'SubmitEvent', rawtohex(l_guid));
    wfe_html_util.Error;
end SubmitEvent;

--
-- SubmitSelectedGEvents
--   Process selected events from group for deletion or addition
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
--   action  - DELETE|ADD|FIND
-- NOTE
--
procedure SubmitSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array,
  action  in varchar2,
  url     in varchar2)
is
  l_guid raw(16);
begin
  if (h_guids.COUNT = 1 and (action = 'DELETE' or action = 'ADD')) then
    wf_core.raise('WFE_EVENT_NOVALUE');
  elsif (action = 'FIND') then
    -- action is FIND
    -- so find event for EditGroup
    -- ignore hguid_array
    Wf_Event_Html.FindEvent(h_gguid);
    return;
  elsif (action = 'DELETE') then
    l_guid := hextoraw(h_guids(2));
    Wf_Event_Html.DeleteSelectedGEvents(h_gguid, h_guids);
  elsif (action = 'ADD') then
    Wf_Event_Html.AddSelectedGEvents(h_gguid, h_guids);
  end if;

  Wfe_Html_Util.gotoURL(url);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'SubmitSelectedGEvents',
                    rawtohex(h_gguid), url);
    wfe_html_util.Error;
end SubmitSelectedGEvents;

--
-- SubmitSystem
--   Submit an system to database
-- IN
--   h_guid - Global unique id for system
--   h_name - System name
--   h_display_name
--   h_description
-- NOTE
--
procedure SubmitSystem(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  display_master      in varchar2,
  h_master_guid       in varchar2,
  url                 in varchar2)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_guid  raw(16);
  l_mguid raw(16);
  row_id  varchar2(30);
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  l_mguid := hextoraw(h_master_guid);
  Wf_Event_Html.Validate_System_Name(display_master, l_mguid);

  if (h_guid is not null) then
    l_guid := hextoraw(h_guid);

    -- update
    Wf_Systems_Pkg.Update_Row(
      X_GUID=>l_guid,
      X_NAME=>h_name,
      X_MASTER_GUID=>l_mguid,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description
    );

  else
    l_guid := sys_guid();

    -- insert
    Wf_Systems_Pkg.Insert_Row(
      X_ROWID=>row_id,
      X_GUID=>l_guid,
      X_NAME=>h_name,
      X_MASTER_GUID=>l_mguid,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description
    );

  end if;

  -- all done go to a predetermined screen like ListSystems
  Wfa_Html.GotoURL(url, '_top');

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'SubmitSystem', rawtohex(l_guid));
    wfe_html_util.Error;
end SubmitSystem;

--
-- SubmitAgent
--   Submit an agent to database
-- IN
--   h_guid - Global unique id for an agent
--   h_display_name
--   h_description
--   h_protocol
--   h_address
--   display_system
--   h_system_guid
--   h_direction
--   h_status - Agent status: ENABLED|DISABLED
-- NOTE
--
procedure SubmitAgent(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  h_protocol          in varchar2,
  h_address           in varchar2,
  display_system      in varchar2,
  h_system_guid       in varchar2,
  h_qhandler          in varchar2,
  h_qname             in varchar2,
  h_direction         in varchar2,
  h_status            in varchar2,
  url                 in varchar2)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_guid raw(16);
  l_system_guid raw(16);
  row_id varchar2(30);
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  l_system_guid := hextoraw(h_system_guid);
  Wf_Event_Html.Validate_System_Name(display_system, l_system_guid);

  if (h_guid is not null) then
    l_guid := hextoraw(h_guid);

    -- update
    Wf_Agents_Pkg.Update_Row (
      X_GUID=>l_guid,
      X_NAME=>upper(h_name),
      X_SYSTEM_GUID=>l_system_guid,
      X_PROTOCOL=>h_protocol,
      X_ADDRESS=>h_address,
      X_QUEUE_HANDLER=>upper(h_qhandler),
      X_QUEUE_NAME=>upper(h_qname),
      X_DIRECTION=>h_direction,
      X_STATUS=>h_status,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description
    );

  else
    l_guid := sys_guid();

    -- insert
    Wf_Agents_Pkg.Insert_Row (
      X_ROWID=>row_id,
      X_GUID=>l_guid,
      X_NAME=>upper(h_name),
      X_SYSTEM_GUID=>l_system_guid,
      X_PROTOCOL=>h_protocol,
      X_ADDRESS=>h_address,
      X_QUEUE_HANDLER=>upper(h_qhandler),
      X_QUEUE_NAME=>upper(h_qname),
      X_DIRECTION=>h_direction,
      X_STATUS=>h_status,
      X_DISPLAY_NAME=>h_display_name,
      X_DESCRIPTION=>h_description
    );
  end if;

  -- all done go to a predetermined screen like ListAgents
  Wfa_Html.GotoURL(url, '_top');

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'SubmitAgent', rawtohex(l_guid));
    wfe_html_util.Error;
end SubmitAgent;

--
-- SubmitSubscription
--   Submit a subscription to database
-- IN
--   h_guid - Global unique id for an agent
--   h_display_name
--   h_description
--   h_protocol
--   h_address
--   h_system_guid
--   h_direction
--   h_status - Agent status: ENABLED|DISABLED
-- NOTE
--
procedure SubmitSubscription(
  h_guid              in varchar2,
  h_description       in varchar2,
  display_system      in varchar2,
  h_system_guid       in varchar2,
  h_source_type       in varchar2,
  display_source_agent in varchar2,
  h_source_agent_guid in varchar2,
  display_event       in varchar2,
  h_event_guid        in varchar2,
  h_phase             in varchar2,
  h_status            in varchar2,
  h_owner_name        in varchar2,
  h_owner_tag         in varchar2,
  h_rule_data         in varchar2,
  h_rule_function     in varchar2,
  display_out_agent   in varchar2,
  h_out_agent_guid    in varchar2,
  display_to_agent    in varchar2,
  h_to_agent_guid     in varchar2,
  h_priority          in varchar2,
  h_wfptype           in varchar2,
  h_wfptype_dname     in varchar2,
  h_wfpname           in varchar2,
  h_wfptn             in varchar2,
  h_parameters        in varchar2,
  h_custom_level        in varchar2,
  url                 in varchar2)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_guid raw(16);
  row_id varchar2(30);

  l_sysguid    raw(16);
  l_evtguid    raw(16);
  l_fagnguid   raw(16);
  l_oagnguid   raw(16);
  l_tagnguid   raw(16);

  l_phase      number;
  l_priority   number;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- validate LOVs
  l_sysguid := hextoraw(h_system_guid);
  Wf_Event_Html.Validate_System_Name(display_system, l_sysguid);

  l_evtguid := hextoraw(h_event_guid);
  Wf_Event_Html.Validate_Event_Name(display_event, l_evtguid);

  l_fagnguid := hextoraw(h_source_agent_guid);
  Wf_Event_Html.Validate_Agent_Name(display_source_agent, l_fagnguid);

  l_oagnguid := hextoraw(h_out_agent_guid);
  Wf_Event_Html.Validate_Agent_Name(display_out_agent, l_oagnguid);

  l_tagnguid := hextoraw(h_to_agent_guid);
  Wf_Event_Html.Validate_Agent_Name(display_to_agent, l_tagnguid);

  l_phase := to_number(h_phase);
  l_priority := to_number(h_priority);

  if (h_guid is not null) then
    l_guid := hextoraw(h_guid);

    -- update
    Wf_Event_Subscriptions_Pkg.Update_Row (
      X_GUID=>l_guid,
      X_SYSTEM_GUID=>l_sysguid,
      X_SOURCE_TYPE=>h_source_type,
      X_SOURCE_AGENT_GUID=>l_fagnguid,
      X_EVENT_FILTER_GUID=>l_evtguid,
      X_PHASE=>l_phase,
      X_STATUS=>h_status,
      X_RULE_DATA=>h_rule_data,
      X_OUT_AGENT_GUID=>l_oagnguid,
      X_TO_AGENT_GUID=>l_tagnguid,
      X_PRIORITY=>l_priority,
      X_RULE_FUNCTION=>h_rule_function,
      X_WF_PROCESS_TYPE=>h_wfptype,
      X_WF_PROCESS_NAME=>h_wfpname,
      X_PARAMETERS=>h_parameters,
      X_OWNER_NAME=>h_owner_name,
      X_OWNER_TAG=>h_owner_tag,
      X_CUSTOMIZATION_LEVEL=>h_custom_level,
      X_DESCRIPTION=>h_description
    );
  else
    l_guid := sys_guid();

    -- insert
    Wf_Event_Subscriptions_Pkg.Insert_Row (
      X_ROWID=>row_id,
      X_GUID=>l_guid,
      X_SYSTEM_GUID=>l_sysguid,
      X_SOURCE_TYPE=>h_source_type,
      X_SOURCE_AGENT_GUID=>l_fagnguid,
      X_EVENT_FILTER_GUID=>l_evtguid,
      X_PHASE=>l_phase,
      X_STATUS=>h_status,
      X_RULE_DATA=>h_rule_data,
      X_OUT_AGENT_GUID=>l_oagnguid,
      X_TO_AGENT_GUID=>l_tagnguid,
      X_PRIORITY=>l_priority,
      X_RULE_FUNCTION=>h_rule_function,
      X_WF_PROCESS_TYPE=>h_wfptype,
      X_WF_PROCESS_NAME=>h_wfpname,
      X_PARAMETERS=>h_parameters,
      X_OWNER_NAME=>h_owner_name,
      X_OWNER_TAG=>h_owner_tag,
      X_CUSTOMIZATION_LEVEL=>h_custom_level,
      X_DESCRIPTION=>h_description
    );
  end if;

  -- all done go to a predetermined screen like ListSubscriptions
  Wfa_Html.GotoURL(url, '_top');

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'SubmitSubscription', rawtohex(l_guid));
    wfe_html_util.Error;
end SubmitSubscription;

--
-- FindEvent
--   Filter page to find event
--
procedure FindEvent (
  x_gguid in raw default null,
  h_guid in raw default null,
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*'
)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list
  l_url    varchar2(240);  -- url for form

  l_name   varchar2(240);

  -- addable event cursor
  -- all events meet the query criteria
  cursor aevcurs is
    select GUID, DISPLAY_NAME, NAME, TYPE, STATUS
      from WF_EVENTS_VL
     where TYPE = 'EVENT'
       and (h_display_name is null or lower(DISPLAY_NAME) like
              '%'||lower(h_display_name)||'%')
       and (h_name is null or lower(NAME) like '%'||lower(h_name)||'%')
       and (h_status = '*' or STATUS = h_status)
     order by NAME;

  hTab wfe_html_util.headerTabType;
  dTab wfe_html_util.dataTabType;
  i pls_integer;
  title     varchar2(2000);
  helptext  varchar2(2000);
  selected  boolean := FALSE;
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('EVENTS');

  -- Determine if this is for group addition or not
  if (x_gguid is not null) then
    l_url := 'Wf_Event_Html.FindEvent';

    begin
      select NAME into l_name
        from WF_EVENTS
       where GUID = x_gguid;
    exception
      when NO_DATA_FOUND then
        wf_core.raise('WFE_EVENT_NOTEXIST');
    end;

    -- also print a message about adding to group
    -- E.g. Narrow selection for adding to group
    -- htp.p(wf_core.translate('WFE_FIND_FOR_GROUP'));

    title := wf_core.translate('WFE_ADD_TO_GROUP')||': '||l_name;
    helptext := 'wf/links/t_d.htm?T_DEFEVGPM';
  else
    l_url := 'Wf_Event_Html.ListEvents';
    title := wf_core.translate('WFE_FIND_EVENT_TITLE');
    helptext := 'wf/links/t_f.htm?T_FDEVT';
  end if;

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;

  -- only expire page if there is potential of having a list

  if (x_gguid is not null and h_guid is not null) then
    -- list does not get updated after edit, so we add the
    -- following tag to force the reload of page.
    htp.p('<META HTTP-EQUIV=expires CONTENT="no-cache">');
  end if;

  htp.title(title);
  wfa_html.create_help_function(helptext);
  fnd_document_management.get_open_dm_display_window;

  Wfe_Html_Util.generate_check_all;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, title, TRUE);

  -- Form
  htp.formOpen(curl=>owa_util.get_owa_service_path||l_url,
               cmethod=>'Get',
               cattributes=>'TARGET="_top" NAME="WF_EVENT_FIND"');

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- hidden attribute for FindEvent
  if (x_gguid is not null) then
    htp.formHidden('x_gguid', x_gguid);
    htp.formHidden('h_guid', x_gguid);
  end if;

  -- Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_name">' ||
      wf_core.translate('NAME') || '</LABEL>',
      calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_name', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Display Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_display_name">' ||
       wf_core.translate('DISPLAY_NAME') || '</LABEL>',
       calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'h_display_name', csize=>60,
                                     cmaxlength=>80,
                cattributes=>'id="i_display_name"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Status
  template := htf.formSelectOpen('h_status',cattributes=>'id="i_status"')
     ||wf_core.newline;

  if (h_status = '*') then
    template := template||htf.formSelectOption(wf_core.translate('ANY'),
                              'SELECTED','VALUE="*"')||wf_core.newline;
    selected := TRUE;
  else
    template := template||htf.formSelectOption(wf_core.translate('ANY'),
                              null,'VALUE="*"')||wf_core.newline;
  end if;
  if (h_status = 'ENABLED') then
    template := template||htf.formSelectOption(wf_core.translate('ENABLED'),
                              'SELECTED','VALUE="ENABLED"')||wf_core.newline;
    selected := TRUE;
  else
    template := template||htf.formSelectOption(wf_core.translate('ENABLED'),
                              null,'VALUE="ENABLED"')||wf_core.newline;
  end if;
  if (selected) then
    template := template||htf.formSelectOption(wf_core.translate('DISABLED'),
                              null,'VALUE="DISABLED"');
  else
    template := template||htf.formSelectOption(wf_core.translate('DISABLED'),
                              'SELECTED','VALUE="DISABLED"');
    selected := TRUE;
  end if;
  template := template||wf_core.newline||htf.formSelectClose;

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_status">' ||
                wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Type
  -- This is a regular find, allow select of type.
  -- Type can only be EVENT for "Add to Group".
  if (x_gguid is null) then
    template := htf.formSelectOpen('h_type',cattributes=>'id="i_type"')
        ||wf_core.newline||
                htf.formSelectOption(wf_core.translate('ANY'),
                                     'SELECTED','VALUE="*"')
                ||wf_core.newline||
                htf.formSelectOption(wf_core.translate('EVENT'),
                                     null,'VALUE="EVENT"')
                ||wf_core.newline||
                htf.formSelectOption(wf_core.translate('GROUP'),
                                     null,'VALUE="GROUP"')
                ||wf_core.newline||
                htf.formSelectClose;
    htp.tableRowOpen;
    htp.tableData(cvalue=>'<LABEL FOR="i_type">' ||
                  wf_core.translate('TYPE') || '</LABEL>',
                  calign=>'Right',cattributes=>'id=""');
    htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
    htp.tableRowClose;
  end if;

  htp.tableClose;

  if (x_gguid is null) then
    htp.formHidden('resetcookie','T');
  end if;
  htp.formClose;

  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_EVENT_FIND.submit()',
                              wf_core.translate('GO'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('GO'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  -- if a find condition is entered, populate the search fields and
  -- run the query to generate the event list.
  if (h_guid is not null) then
    -- populate the search fields
    htp.p('<SCRIPT>');
    htp.p('  document.WF_EVENT_FIND.h_name.value="'||h_name||'"');
    htp.p('  document.WF_EVENT_FIND.h_display_name.value="'
          ||h_display_name||'"');
    htp.p('</SCRIPT>');

    -- populate the data table
    i := 0;
    for event in aevcurs loop
      i := i+1;
      dTab(i).guid := event.guid;
      dTab(i).col01:= event.display_name;
      dTab(i).col02:= event.name;
      dTab(i).col03:= event.status;

      dTab(i).selectable := TRUE;
      dTab(i).deletable := FALSE;
      dTab(i).hasdetail := FALSE;
    end loop;

    -- Submit Form for Add/Delete
    htp.formOpen(curl=>owa_util.get_owa_service_path||
                       'Wf_Event_Html.SubmitSelectedGEvents',
                   cmethod=>'Post',
                   cattributes=>'TARGET="_top" NAME="WF_GROUP_EDIT"');
    htp.formHidden('h_gguid', rawtohex(h_guid));

    -- Hide the fields for which option you selected. Must be ADD here.
    htp.formHidden(cname=>'action', cvalue=>'');

    -- Url to come back to later
    htp.formHidden(cname=>'url',
           cvalue=>'Wf_Event_Html.EditEvent?h_guid='||rawtohex(h_guid));

    -- Add dummy fields to start both array-type input fields.
    -- These dummy values are needed so that the array parameters to
    -- the submit procedure will not be null even if there are no real
    -- response fields.  This would cause a pl/sql error, because array
    -- parameters can't be defaulted.
    htp.formHidden('h_guids', '-1');

    -- popluate the header table
    i := 1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('DISPLAY_NAME');
    hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('NAME');
    hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';
    i := i+1;
    hTab(i).def_type := 'TITLE';
    hTab(i).value    := wf_core.translate('STATUS');
    hTab(i).attr     := 'id="'||wf_core.translate('STATUS')||'"';

    -- render table
    Wfe_Html_Util.Simple_Table(hTab, dTab);

    htp.formClose;

    -- Buttons Area
    htp.tableOpen (calign=>'RIGHT',cattributes=>'summary=""');
    htp.tableRowOpen;
    -- If table is not empty, we allow check/uncheck all/delete.
    if (dTab.COUNT > 0) then
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:checkAll(document.WF_GROUP_EDIT.h_guids)',
               wf_core.translate('SELECT_ALL'),
               wfa_html.image_loc,
               null,
               wf_core.translate('SELECT_ALL'));
      htp.p('</TD>');
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:uncheckAll(document.WF_GROUP_EDIT.h_guids)',
               wf_core.translate('UNSELECT_ALL'),
               wfa_html.image_loc,
               null,
               wf_core.translate('UNSELECT_ALL'));
      htp.p('</TD>');
      htp.p('<TD ID="">');
      wfa_html.create_reg_button (
               'javascript:document.WF_GROUP_EDIT.action.value=''ADD'';'||
               'document.WF_GROUP_EDIT.submit()',
               wf_core.translate('ADD'),
               wfa_html.image_loc,
               null,
               wf_core.translate('ADD'));
      htp.p('</TD>');
    end if;
    htp.p('<TD ID="">');
    wfa_html.create_reg_button ('javascript:history.back()',
                                wf_core.translate ('CANCEL'),
                                wfa_html.image_loc,
                                null,
                                wf_core.translate ('CANCEL'));
    htp.p('</TD>');
    htp.tableRowClose;
    htp.tableClose;

  end if; -- end generating the event list for adding to group

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'FindEvent', rawtohex(x_gguid));
    wfe_html_util.Error;
end FindEvent;

--
-- FindSystem
--   Filter page to find systems
--
procedure FindSystem
is
begin
   null;
end FindSystem;

--
-- FindAgent
--   Filter page to find agents
--
procedure FindAgent
is
begin
    null;
end FindAgent;

--
-- FindSubscription
--   Filter page to find subscriptions
--
procedure FindSubscription
is
begin
  null;
end FindSubscription;


--
-- DeleteEvent
--   Delete an event
-- IN
--   h_guid - Global unique id for an event
-- NOTE
--
procedure DeleteEvent(
  h_guid in raw default null)
is
  l_type varchar2(8);

  cursor evtc(xguid in raw) is
    select MEMBER_GUID
      from WF_EVENT_GROUPS
     where GROUP_GUID = xguid;

begin
  if (isDeletable(h_guid, 'EVENT')) then
    begin
      select TYPE into l_type
        from WF_EVENTS
       where GUID = h_guid
         and TYPE = 'EVENT';
    exception
      -- if it is a group, delete all the child events
      when NO_DATA_FOUND then
        for evtr in evtc(h_guid) loop
          Wf_Event_Groups_Pkg.Delete_Row(
            x_group_guid=>h_guid,
            x_member_guid=>evtr.MEMBER_GUID
          );
        end loop;
    end;

    Wf_Events_Pkg.Delete_Row(h_guid);
  end if;

  -- go back to ListEvents
  Wfe_Html_Util.gotoURL(wfa_html.base_url||'/Wf_Event_Html.ListEvents');

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'DeleteEvent', rawtohex(h_guid));
    wfe_html_util.Error;
end DeleteEvent;

--
-- DeleteSystem
--   Delete a system
-- IN
--   h_guid - Global unique id for a system
-- NOTE
--
procedure DeleteSystem(
  h_guid in raw default null)
is
begin
  if (isDeletable(h_guid, 'SYSTEM')) then
    Wf_Systems_Pkg.Delete_Row(h_guid);
  end if;

  -- go back to ListSystems
  htp.p('<SCRIPT>');
  htp.p(' window.location.replace("'||
        wfa_html.base_url||'/Wf_Event_Html.ListSystems")');
  htp.p('</SCRIPT>');

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'DeleteSystem', rawtohex(h_guid));
    wfe_html_util.Error;
end DeleteSystem;

--
-- DeleteAgent
--   Delete an agent
-- IN
--   h_guid - Global unique id for an agent
-- NOTE
--
procedure DeleteAgent(
  h_guid in raw default null)
is
begin
  if (isDeletable(h_guid, 'AGENT')) then
    Wf_Agents_Pkg.Delete_Row(h_guid);
  end if;

  -- go back to ListAgents
  htp.p('<SCRIPT>');
  htp.p(' window.location.replace("'||
        wfa_html.base_url||'/Wf_Event_Html.ListAgents")');
  htp.p('</SCRIPT>');

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'DeleteAgent', rawtohex(h_guid));
    wfe_html_util.Error;
end DeleteAgent;

-- DeleteSubscription
--   Delete a subscription
-- IN
--   h_guid - Global unique id for a subscription
-- NOTE
--
procedure DeleteSubscription(
  h_guid in raw default null)
is
begin
  if (isDeletable(h_guid, 'SUBSCRIPTION')) then
    Wf_Event_Subscriptions_Pkg.Delete_Row(h_guid);
  end if;

  -- go back to ListSubscriptions
  htp.p('<SCRIPT>');
  htp.p(' window.location.replace("'||
        wfa_html.base_url||'/Wf_Event_Html.ListSubscriptions")');
  htp.p('</SCRIPT>');

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'DeleteSubscription', rawtohex(h_guid));
    wfe_html_util.Error;
end DeleteSubscription;

--
-- wf_event_val
--   Create the lov content for our event lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_event_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number)
is

  cursor evcurs (c_find_criteria in varchar2) is
    select GUID, NAME, DISPLAY_NAME
      from WF_EVENTS_VL
     where (UPPER(display_name) LIKE UPPER(c_find_criteria)||'%'
       and    (display_name  LIKE LOWER(SUBSTR(c_find_criteria, 1, 2))||'%'
        or     display_name  LIKE LOWER(SUBSTR(c_find_criteria, 1, 1))||
                        UPPER(SUBSTR(c_find_criteria, 2, 1))||'%'
        or    display_name   LIKE INITCAP(SUBSTR(c_find_criteria, 1, 2))||'%'
        or    display_name   LIKE UPPER(SUBSTR(c_find_criteria, 1, 2))||'%'))
      or
           (UPPER(name) LIKE UPPER(c_find_criteria)||'%'
       and    (name  LIKE LOWER(SUBSTR(c_find_criteria, 1, 2))||'%'
        or     name  LIKE LOWER(SUBSTR(c_find_criteria, 1, 1))||
                               UPPER(SUBSTR(c_find_criteria, 2, 1))||'%'
        or    name   LIKE INITCAP(SUBSTR(c_find_criteria, 1, 2))||'%'
        or    name   LIKE UPPER(SUBSTR(c_find_criteria, 1, 2))||'%'))
       order by NAME;

  ii           pls_integer := 0;
  nn           pls_integer := 0;
  l_total_rows pls_integer := 0;
  l_id         pls_integer;
  l_guid       raw(16);
  l_name       varchar2 (240);
  l_display_name       varchar2 (240);
  l_result     number := 1;  -- This is the return value for each mode

begin
  if (p_mode = 'LOV') then

    /*
    ** Need to get a count on the number of rows that will meet the
    ** criteria before actually executing the fetch to show the user
    ** how many matches are available.
    */
    select count(*) into l_total_rows
      from WF_EVENTS_VL
     where (upper(DISPLAY_NAME) like upper(p_display_value)||'%'
       and    (DISPLAY_NAME  like lower(substr(p_display_value, 1, 2))||'%'
        or     DISPLAY_NAME  like lower(substr(p_display_value, 1, 1))||
                        upper(SUBSTR(p_display_value, 2, 1))||'%'
        or    DISPLAY_NAME   like initcap(substr(p_display_value, 1, 2))||'%'
        or    DISPLAY_NAME   like upper(substr(p_display_value, 1, 2))||'%'))
      or
           (upper(NAME) like upper(p_display_value)||'%'
       and    (NAME  like lower(substr(p_display_value, 1, 2))||'%'
        or     NAME  like lower(substr(p_display_value, 1, 1))||
                               upper(substr(p_display_value, 2, 1))||'%'
        or    NAME   like initcap(substr(p_display_value, 1, 2))||'%'
        or    NAME   like upper(substr(p_display_value, 1, 2))||'%'));

    wf_lov.g_define_rec.total_rows := l_total_rows;
    wf_lov.g_define_rec.add_attr1_title := wf_core.translate('DISPLAY_NAME');

    open evcurs (p_display_value);
    loop
      fetch evcurs into l_guid, l_name, l_display_name;
      exit when evcurs%NOTFOUND or nn >= p_max_rows;

      ii := ii + 1;

      if (ii >= p_start_row) then

        nn := nn + 1;
        wf_lov.g_value_tbl(nn).hidden_key      := l_guid;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;
      end if;
    end loop;
    l_result := 1;

  elsif (p_mode = 'GET_DISPLAY_VAL') THEN
    select GUID, NAME, DISPLAY_NAME
    into   l_guid, l_name, l_display_name
    from   WF_EVENTS_VL
    where  GUID  = p_hidden_value;

    p_display_value := l_name;

    l_result := 1;

  elsif (p_mode = 'VALIDATE') THEN
    /*
    ** If mode = VALIDATE then see how many rows match the criteria
    ** If its 0 then thats not good.  Raise an error and tell them to use LOV
    ** If its 1 then thats great.
    ** If its more than 1 then check to see if they used the LOV to select
    ** the value
    */
    open evcurs (p_display_value);

    loop

      fetch evcurs into l_guid, l_name, l_display_name;

      exit when evcurs%NOTFOUND OR ii = 2;

      ii := ii + 1;

      p_hidden_value := l_guid;

    end loop;

    /*
    ** If ii=0 then no rows were found and you have an error in the value
    **     entered so present a no rows found and use the lov icon to select
    **     value
    ** If ii=1 then one row is found then you've got the right value
    ** If ii=2 then more than one row was found so check to see if the display
    ** value taht was selected is not unique in the LOV (Person Name) and
    ** that the LOV was used so the Hidden value has been set to a unique
    ** value.  If it comes up with more than 1 in this case then present
    ** the please use lov icon to select value.
    */
    if (ii = 2) then

      select count(*)
      into   ii
      from   WF_EVENTS_VL
      where  NAME      = p_display_value;

    end if;

    l_result := ii;

  end if;
  p_result := l_result;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'Wf_Event_Val');
    raise;
end Wf_Event_Val;

--
-- wf_system_val
--   Create the lov content for our system lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_system_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number)
is

  cursor mycurs (c_find_criteria in varchar2) is
    select GUID, NAME, DISPLAY_NAME
      from WF_SYSTEMS
     where UPPER(display_name) LIKE UPPER(c_find_criteria)||'%'
      or
           UPPER(name) LIKE UPPER(c_find_criteria)||'%'
     order by NAME;

  ii           pls_integer := 0;
  nn           pls_integer := 0;
  l_total_rows pls_integer := 0;
  l_id         pls_integer;
  l_guid       raw(16);
  l_name       varchar2 (240);
  l_display_name       varchar2 (240);
  l_result     number := 1;  -- This is the return value for each mode

begin
  if (p_mode = 'LOV') then

    /*
    ** Need to get a count on the number of rows that will meet the
    ** criteria before actually executing the fetch to show the user
    ** how many matches are available.
    */
    select count(*) into l_total_rows
      from WF_SYSTEMS
     where upper(DISPLAY_NAME) like upper(p_display_value)||'%'
      or
           upper(NAME) like upper(p_display_value)||'%';

    wf_lov.g_define_rec.total_rows := l_total_rows;
    wf_lov.g_define_rec.add_attr1_title := wf_core.translate('DISPLAY_NAME');

    open mycurs (p_display_value);
    loop
      fetch mycurs into l_guid, l_name, l_display_name;
      exit when mycurs%NOTFOUND or nn >= p_max_rows;

      ii := ii + 1;

      if (ii >= p_start_row) then

        nn := nn + 1;
        wf_lov.g_value_tbl(nn).hidden_key      := l_guid;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;
      end if;
    end loop;
    l_result := 1;

  elsif (p_mode = 'GET_DISPLAY_VAL') THEN
    select GUID, NAME, DISPLAY_NAME
    into   l_guid, l_name, l_display_name
    from   WF_SYSTEMS
    where  GUID  = p_hidden_value;

    p_display_value := l_name;

    l_result := 1;

  elsif (p_mode = 'VALIDATE') THEN
    /*
    ** If mode = VALIDATE then see how many rows match the criteria
    ** If its 0 then thats not good.  Raise an error and tell them to use LOV
    ** If its 1 then thats great.
    ** If its more than 1 then check to see if they used the LOV to select
    ** the value
    */
    open mycurs (p_display_value);

    loop

      fetch mycurs into l_guid, l_name, l_display_name;

      exit when mycurs%NOTFOUND OR ii = 2;

      ii := ii + 1;

      p_hidden_value := l_guid;

    end loop;

    /*
    ** If ii=0 then no rows were found and you have an error in the value
    **     entered so present a no rows found and use the lov icon to select
    **     value
    ** If ii=1 then one row is found then you've got the right value
    ** If ii=2 then more than one row was found so check to see if the display
    ** value taht was selected is not unique in the LOV (Person Name) and
    ** that the LOV was used so the Hidden value has been set to a unique
    ** value.  If it comes up with more than 1 in this case then present
    ** the please use lov icon to select value.
    */
    if (ii = 2) then

      select count(*)
      into   ii
      from   WF_SYSTEMS
      where  NAME      = p_display_value;

    end if;

    l_result := ii;

  end if;
  p_result := l_result;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'Wf_System_Val');
    raise;
end Wf_System_Val;

--
-- wf_agent_val
--   Create the lov content for our agent lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_agent_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number,
p_param1         in varchar2 default null,
p_param2         in varchar2 default null)
is
  -- JWSMITH, BUG 1831892
  -- added and UPPER(a.name) <> 'WF_DEFERRED' in following select stmt
  cursor mycurs (c_find_criteria in varchar2, sguid in raw) is
    select A.GUID, A.DISPLAY_NAME, A.NAME||'@'||S.NAME
      from WF_AGENTS A, WF_SYSTEMS S
     where UPPER(a.name) LIKE UPPER(c_find_criteria)||'%'
       and UPPER(a.name) <> 'WF_DEFERRED'
       and A.SYSTEM_GUID = S.GUID
       and (p_param1 is null or direction = p_param1 or direction = 'ANY')
       and (sguid is null or system_guid = sguid)
     order by ADDRESS;

  ii           pls_integer := 0;
  nn           pls_integer := 0;
  l_total_rows pls_integer := 0;
  l_id         pls_integer;
  l_guid       raw(16);
  l_dname      varchar2 (80);
  l_disp       varchar2 (161); -- name@system
  l_result     number := 1;  -- This is the return value for each mode
  l_sguid      raw(16);

  colon        number;
  l_aname      varchar2(80);
  l_sname      varchar2(80);
begin
  colon := instr(p_display_value, '@');
  if (colon <> 0) then
    l_aname := substr(p_display_value, 1, colon-1);
    l_sname := substr(p_display_value, colon+1);
  else
    l_aname := p_display_value;
    l_sname := p_param2;
  end if;

  if (l_sname is not null) then
    select min(GUID) into l_sguid
      from WF_SYSTEMS
     where NAME = l_sname;
  else
    l_sguid := hextoraw(null);
  end if;

  if (p_mode = 'LOV') then

    /*
    ** Need to get a count on the number of rows that will meet the
    ** criteria before actually executing the fetch to show the user
    ** how many matches are available.
    */
    select count(*) into l_total_rows
      from WF_AGENTS A, WF_SYSTEMS S
     where upper(A.NAME) like upper(l_aname)||'%'
       and A.SYSTEM_GUID = S.GUID
       and (p_param1 is null or A.DIRECTION = p_param1)
       and (l_sguid is null or A.SYSTEM_GUID = l_sguid);

    wf_lov.g_define_rec.total_rows := l_total_rows;
    wf_lov.g_define_rec.add_attr1_title := wf_core.translate('DISPLAY_NAME');

    open mycurs (l_aname, l_sguid);
    loop
      fetch mycurs into l_guid, l_dname, l_disp;
      exit when mycurs%NOTFOUND or nn >= p_max_rows;

      ii := ii + 1;

      if (ii >= p_start_row) then

        nn := nn + 1;
        wf_lov.g_value_tbl(nn).hidden_key      := l_guid;
        wf_lov.g_value_tbl(nn).display_value   := l_disp;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_dname;
      end if;
    end loop;
    l_result := 1;

  elsif (p_mode = 'GET_DISPLAY_VAL') THEN
    select A.GUID, A.DISPLAY_NAME, A.NAME||'@'||S.NAME
    into   l_guid, l_dname, l_disp
    from   WF_AGENTS A, WF_SYSTEMS S
    where  A.GUID  = p_hidden_value
      and  A.SYSTEM_GUID (+)= S.GUID;

    p_display_value := l_disp;

    l_result := 1;

  elsif (p_mode = 'VALIDATE') THEN
    /*
    ** If mode = VALIDATE then see how many rows match the criteria
    ** If its 0 then thats not good.  Raise an error and tell them to use LOV
    ** If its 1 then thats great.
    ** If its more than 1 then check to see if they used the LOV to select
    ** the value
    */
    open mycurs (l_aname, l_sguid);

    loop

      fetch mycurs into l_guid, l_dname, l_disp;

      exit when mycurs%NOTFOUND OR ii = 2;

      ii := ii + 1;

      p_hidden_value := l_guid;

    end loop;

    /*
    ** If ii=0 then no rows were found and you have an error in the value
    **     entered so present a no rows found and use the lov icon to select
    **     value
    ** If ii=1 then one row is found then you've got the right value
    ** If ii=2 then more than one row was found so check to see if the display
    ** value taht was selected is not unique in the LOV (Person Name) and
    ** that the LOV was used so the Hidden value has been set to a unique
    ** value.  If it comes up with more than 1 in this case then present
    ** the please use lov icon to select value.
    */
    if (ii = 2) then

      select count(*)
      into   ii
      from   WF_AGENTS
      where  NAME      = l_aname;

    end if;

    l_result := ii;

  end if;
  p_result := l_result;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'Wf_Agent_Val');
    raise;
end Wf_Agent_Val;

--
-- wf_itemtype_val
--   Create the lov content for wf item type lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_itemtype_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number)
is

  cursor mycurs (c_find_criteria in varchar2) is
    select NAME, DISPLAY_NAME
      from WF_ITEM_TYPES_VL
     where (UPPER(DISPLAY_NAME) LIKE UPPER(c_find_criteria)||'%'
      or
           NAME LIKE UPPER(c_find_criteria)||'%')
       and NAME not in ('WFSTD','WFMAIL', 'SYSERROR')
     order by NAME;

  ii           pls_integer := 0;
  nn           pls_integer := 0;
  l_total_rows pls_integer := 0;
  l_id         pls_integer;
  l_name       varchar2 (8);
  l_display_name       varchar2 (240);
  l_result     number := 1;  -- This is the return value for each mode

begin
  if (p_mode = 'LOV') then

    /*
    ** Need to get a count on the number of rows that will meet the
    ** criteria before actually executing the fetch to show the user
    ** how many matches are available.
    */
    select count(*) into l_total_rows
      from WF_ITEM_TYPES_VL
     where (upper(DISPLAY_NAME) like upper(p_display_value)||'%'
      or
           NAME like upper(p_display_value)||'%')
       and NAME not in ('WFSTD', 'WFERROR', 'WFMAIL', 'SYSERROR');

    wf_lov.g_define_rec.total_rows := l_total_rows;
    wf_lov.g_define_rec.add_attr1_title := wf_core.translate('DISPLAY_NAME');

    open mycurs (p_display_value);
    loop
      fetch mycurs into l_name, l_display_name;
      exit when mycurs%NOTFOUND or nn >= p_max_rows;

      ii := ii + 1;

      if (ii >= p_start_row) then

        nn := nn + 1;
        wf_lov.g_value_tbl(nn).hidden_key      := l_display_name;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;
      end if;
    end loop;
    l_result := 1;

  elsif (p_mode = 'GET_DISPLAY_VAL') THEN
    select NAME, DISPLAY_NAME
    into   l_name, l_display_name
    from   WF_ITEM_TYPES_VL
    where  upper(DISPLAY_NAME) = upper(p_hidden_value);

    p_display_value := l_name;

    l_result := 1;

  elsif (p_mode = 'VALIDATE') THEN
    /*
    ** If mode = VALIDATE then see how many rows match the criteria
    ** If its 0 then thats not good.  Raise an error and tell them to use LOV
    ** If its 1 then thats great.
    ** If its more than 1 then check to see if they used the LOV to select
    ** the value
    */
    open mycurs (p_display_value);

    loop

      fetch mycurs into l_name, l_display_name;

      exit when mycurs%NOTFOUND OR ii = 2;

      ii := ii + 1;

      p_hidden_value := l_display_name;

    end loop;

    /*
    ** If ii=0 then no rows were found and you have an error in the value
    **     entered so present a no rows found and use the lov icon to select
    **     value
    ** If ii=1 then one row is found then you've got the right value
    ** If ii=2 then more than one row was found so check to see if the display
    ** value taht was selected is not unique in the LOV (Person Name) and
    ** that the LOV was used so the Hidden value has been set to a unique
    ** value.  If it comes up with more than 1 in this case then present
    ** the please use lov icon to select value.
    */
    if (ii = 2) then

      select count(*)
      into   ii
      from   WF_ITEM_TYPES_VL
      where  NAME      = p_display_value;

    end if;

    l_result := ii;

  end if;
  p_result := l_result;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'Wf_ItemType_Val');
    raise;
end Wf_ItemType_Val;

--
-- wf_processname_val
--   Create the lov content for wf process name lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_processname_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number,
p_param1         in varchar2 default null)
is

  cursor mycurs (c_find_criteria in varchar2) is
    select PROCESS_NAME, DISPLAY_NAME
      from WF_RUNNABLE_PROCESSES_V
     where PROCESS_NAME LIKE UPPER(c_find_criteria)||'%'
       and ITEM_TYPE = p_param1
     order by PROCESS_NAME;

  ii           pls_integer := 0;
  nn           pls_integer := 0;
  l_total_rows pls_integer := 0;
  l_id         pls_integer;
  l_name       varchar2 (61);
  l_display_name varchar2 (61);
  l_result     number := 1;  -- This is the return value for each mode

  colon        pls_integer;

begin

  if (p_mode = 'LOV') then

    /*
    ** Need to get a count on the number of rows that will meet the
    ** criteria before actually executing the fetch to show the user
    ** how many matches are available.
    */
    select count(*) into l_total_rows
      from WF_RUNNABLE_PROCESSES_V
     where PROCESS_NAME like upper(p_display_value)||'%'
       and ITEM_TYPE = p_param1;

    wf_lov.g_define_rec.total_rows := l_total_rows;
    wf_lov.g_define_rec.add_attr1_title := wf_core.translate('DISPLAY_NAME');

    open mycurs (p_display_value);
    loop
      fetch mycurs into l_name, l_display_name;
      exit when mycurs%NOTFOUND or nn >= p_max_rows;

      ii := ii + 1;

      if (ii >= p_start_row) then

        nn := nn + 1;
        wf_lov.g_value_tbl(nn).hidden_key      := p_hidden_value;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;
      end if;
    end loop;
    l_result := 1;

  elsif (p_mode = 'GET_DISPLAY_VAL') THEN
    select PROCESS_NAME, DISPLAY_NAME
    into   l_name, l_display_name
    from   WF_RUNNABLE_PROCESSES_V
    where  PROCESS_NAME = upper(p_display_value)
      and  ITEM_TYPE = p_param1;

    p_display_value := l_name;

    l_result := 1;

  elsif (p_mode = 'VALIDATE') THEN
    /*
    ** If mode = VALIDATE then see how many rows match the criteria
    ** If its 0 then thats not good.  Raise an error and tell them to use LOV
    ** If its 1 then thats great.
    ** If its more than 1 then check to see if they used the LOV to select
    ** the value
    */
    open mycurs (p_display_value);

    loop

      fetch mycurs into l_name, l_display_name;

      exit when mycurs%NOTFOUND OR ii = 2;

      ii := ii + 1;

      -- p_hidden_value := l_display_name;

    end loop;

    /*
    ** If ii=0 then no rows were found and you have an error in the value
    **     entered so present a no rows found and use the lov icon to select
    **     value
    ** If ii=1 then one row is found then you've got the right value
    ** If ii=2 then more than one row was found so check to see if the display
    ** value taht was selected is not unique in the LOV (Person Name) and
    ** that the LOV was used so the Hidden value has been set to a unique
    ** value.  If it comes up with more than 1 in this case then present
    ** the please use lov icon to select value.
    */
    if (ii = 2) then

      select count(*)
      into   ii
      from   WF_RUNNABLE_PROCESSES_V
      where  PROCESS_NAME = p_display_value
        and  ITEM_TYPE = p_param1;

    end if;

    l_result := ii;

  end if;
  p_result := l_result;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'Wf_ProcessName_Val');
    raise;
end Wf_ProcessName_Val;

--
-- Validate_Event_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure validate_event_name (
p_name in varchar2,
p_guid in out nocopy raw)
is
  l_names_count   number := 0;
  l_dnames_count  number := 0;
  l_guid          raw(16);
  l_upper_name    varchar2(240);
begin

  -- Make sure to blank out the guid if the user originally
  -- used the LOV to select the guid and then blanked out the display
  -- name then make sure here to blank out the guid and return
  if (p_name is null) then
    p_guid := NULL;
    return;
  end if;

  -- First match against GUID.  There shoul not be any duplicate, but
  -- if there is, go ahead and pick the min value so you may return
  -- something.
  l_upper_name := upper(p_name);

  select min(GUID)
    into l_guid
    from WF_EVENTS
   where GUID = l_upper_name;

  -- If you found a match, set p_guid accordingly.
  if (l_guid is not null) then
    p_guid := l_guid;

    return;

  -- check NAME next
  else
    -- Count how many match the NAME
    select count(1)
      into l_names_count
      from WF_EVENTS
     where NAME = p_name;

    -- If you find a match, set p_guid accordingly.
    if (l_names_count = 1) then
      select GUID
        into p_guid
        from WF_EVENTS
       where NAME = p_name;

      return;

    -- Count how many match the DISPLAY_NAME
    else
      select count(1)
        into l_dnames_count
        from WF_EVENTS_VL
       where DISPLAY_NAME = p_name;

      -- If you find a match, set p_guid accordingly.
      if (l_dnames_count = 1) then
        select GUID
          into p_guid
          from WF_EVENTS_VL
         where DISPLAY_NAME = p_name;

        return;

      end if;
    end if;

    -- No match
    if (l_names_count = 0 and l_dnames_count = 0) then

      wf_core.token('EVENT', p_name);
      wf_core.raise('WFE_EVENT_NOMATCH');
      -- ### '&EVENT' is not a valid event guid, name, or display name.

    -- Multiple matches
    else
      wf_core.token('NAME', p_name);
      wf_core.raise('WFE_NOTUNIQUE');
      -- ### '&NAME' is not unique.  Please use the List of Values option
      -- ### to select the entity.

    end if;
  end if;

exception
  when OTHERS then
    wf_core.context('Wf_Event_Html', 'Validate_Event_Name', p_name,
                    rawtohex(p_guid));
    raise;
end Validate_Event_Name;

--
-- Validate_System_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure validate_system_name (
p_name in varchar2,
p_guid in out nocopy raw)
is
  l_names_count   number := 0;
  l_dnames_count  number := 0;
  l_guid          raw(16);
  l_upper_name    varchar2(240);
begin

  -- Make sure to blank out the guid if the user originally
  -- used the LOV to select the guid and then blanked out the display
  -- name then make sure here to blank out the guid and return
  if (p_name is null) then
    p_guid := NULL;
    return;
  end if;

  -- First match against GUID.  There shoul not be any duplicate, but
  -- if there is, go ahead and pick the min value so you may return
  -- something.
  l_upper_name := upper(p_name);

  select min(GUID)
    into l_guid
    from WF_SYSTEMS
   where GUID = l_upper_name;

  -- If you found a match, set p_guid accordingly.
  if (l_guid is not null) then
    p_guid := l_guid;

    return;

  -- check NAME next
  else
    -- Count how many match the NAME
    select count(1)
      into l_names_count
      from WF_SYSTEMS
     where NAME = p_name;

    -- If you find a match, set p_guid accordingly.
    if (l_names_count = 1) then
      select GUID
        into p_guid
        from WF_SYSTEMS
       where NAME = p_name;

      return;

    -- Count how many match the DISPLAY_NAME
    else
      select count(1)
        into l_dnames_count
        from WF_SYSTEMS
       where DISPLAY_NAME = p_name;

      -- If you find a match, set p_guid accordingly.
      if (l_dnames_count = 1) then
        select GUID
          into p_guid
          from WF_SYSTEMS
         where DISPLAY_NAME = p_name;

        return;

      end if;
    end if;

    -- No match
    if (l_names_count = 0 and l_dnames_count = 0) then

      wf_core.token('SYSTEM', p_name);
      wf_core.raise('WFE_SYSTEM_NOMATCH');
      -- ### '&SYSTEM' is not a valid system guid, name, or display name.

    -- Multiple matches
    else
      wf_core.token('NAME', p_name);
      wf_core.raise('WFE_NOTUNIQUE');
      -- ### '&NAME' is not unique.  Please use the List of Values option
      -- ### to select the entity.

    end if;
  end if;

exception
  when OTHERS then
    wf_core.context('Wf_Event_Html', 'Validate_System_Name', p_name,
                    rawtohex(p_guid));
    raise;
end Validate_System_Name;

--
-- Validate_Agent_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure Validate_Agent_Name (
p_name in varchar2,
p_guid in out nocopy raw)
is
  l_names_count   number := 0;
  l_guid          raw(16);
  l_sguid         raw(16);
  l_upper_name    varchar2(240);
  l_system_name   varchar2(80);
  delimiter       number;
begin

  -- Make sure to blank out the guid if the user originally
  -- used the LOV to select the guid and then blanked out the display
  -- name then make sure here to blank out the guid and return
  if (p_name is null) then
    p_guid := NULL;
    return;
  end if;

  -- First match against NAME.  There shoul not be any duplicate, but
  -- if there is, go ahead and pick the min value so you may return
  -- something.
  delimiter := instr(p_name, '@');
  if (delimiter <> 0) then
    l_upper_name := upper(substr(p_name,1,delimiter-1));
    l_system_name := substr(p_name,delimiter+1);
    begin
      select GUID
        into l_sguid
        from WF_SYSTEMS
       where NAME = l_system_name;
    exception
      when OTHERS then
        l_sguid := null;
    end;
  else
    l_upper_name := upper(p_name);
    l_system_name := null;
    l_sguid := null;
  end if;

  select min(GUID)
    into l_guid
    from WF_AGENTS
   where NAME = l_upper_name
     and (l_sguid is null or SYSTEM_GUID = l_sguid);

  -- If you found a match, set p_guid accordingly.
  if (l_guid is not null) then
    p_guid := l_guid;

    return;

  -- check DISPLAY_NAME next
  else
    -- Count how many match the NAME
    select count(1)
      into l_names_count
      from WF_AGENTS
     where NAME = l_upper_name
       and (l_sguid is null or SYSTEM_GUID = l_sguid);

    -- If you find a match, set p_guid accordingly.
    if (l_names_count = 1) then
      select GUID
        into p_guid
        from WF_AGENTS
       where NAME = l_upper_name
         and (l_sguid is null or SYSTEM_GUID = l_sguid);

      return;

    -- No match
    elsif (l_names_count = 0) then

      wf_core.token('AGENT', p_name);
      wf_core.raise('WFE_AGENT_NOMATCH');
      -- ### '&AGENT' is not a valid agent guid, or display name.

    -- Multiple matches
    else
      wf_core.token('NAME', p_name);
      wf_core.raise('WFE_NOTUNIQUE');
      -- ### '&NAME' is not unique.  Please use the List of Values option
      -- ### to select the entity.
    end if;
  end if;

exception
  when OTHERS then
    wf_core.context('Wf_Event_Html', 'Validate_Agent_Name', p_name,
                    rawtohex(p_guid));
    raise;
end Validate_Agent_Name;

--
-- AddSelectedGEvents
--   Add selected events to group
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
-- NOTE
--
procedure AddSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array)
is
  cnt number;
  i   pls_integer;
  row_id  varchar2(30);
begin
  -- check group guid is indeed a group
  select count(1) into cnt
    from WF_EVENTS
   where GUID = h_gguid
     and TYPE = 'GROUP';

  if (cnt = 0) then
    wf_core.token('GUID', rawtohex(h_gguid));
    wf_core.raise('WFE_NOT_GGUID');
  end if;

  -- add
  begin
    for i in 2..h_guids.LAST loop
      Wf_Event_Groups_Pkg.Insert_Row(
        x_rowid=>row_id,
        x_group_guid=>h_gguid,
        x_member_guid=>hextoraw(h_guids(i))
      );
    end loop;
  exception
    when OTHERS then
      wf_core.token('GGUID', rawtohex(h_gguid));
      wf_core.token('MGUID', h_guids(i));
      wf_core.raise('WFE_ADD_FAIL');
  end;

exception
  when OTHERS then
    wf_core.context('WF_EVENT_HTML', 'AddSelectedGEvents', rawtohex(h_gguid));
    raise;
end AddSelectedGEvents;

--
-- DeleteSelectedGEvents
--   Delete selected events from group
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
-- NOTE
--
procedure DeleteSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array)
is
  i   pls_integer;
begin
  -- delete
  begin
    for i in 2..h_guids.LAST loop
      Wf_Event_Groups_Pkg.Delete_Row(
        x_group_guid=>h_gguid,
        x_member_guid=>hextoraw(h_guids(i))
      );
    end loop;
  exception
    when OTHERS then
      wf_core.token('GGUID', rawtohex(h_gguid));
      wf_core.token('MGUID', h_guids(i));
      wf_core.raise('WFE_DELETE_FAIL');
  end;

exception
  when OTHERS then
    wf_core.context('WF_EVENT_HTML','DeleteSelectedGEvents',rawtohex(h_gguid));
    raise;
end DeleteSelectedGEvents;
-- EnterEventDetails
--   Enter Event Name, Event Key, Event Data to raise business event
-- IN
--   p_event_name - event name or part thereof
procedure EnterEventDetails(
 P_EVENT_NAME   in      varchar2 default '%')
is
begin
    null;
end EnterEventDetails;
-- RaiseEvent
--   Called from EnterEventDetails, calls wf_event.raise
-- IN
--   p_event_name - event name
--   p_event_key  - event key
--   p_event_data - event data
procedure RaiseEvent(
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null,
  P_EVENT_DATA  in      varchar2 default null
) is

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_event_data  clob;
begin

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  if p_event_data is null then
    wf_event.raise(p_event_name, p_event_key);
  else
    dbms_lob.createtemporary(l_event_data, FALSE, DBMS_LOB.CALL);
    dbms_lob.write(l_event_data, length(p_event_data), 1 , p_event_data);
    wf_event.raise(p_event_name, p_event_key, l_event_data);
  end if;

  owa_util.redirect_url(curl=> wfa_html.base_url||'/wf_event_html.RaiseEventConfirm?p_event_name='||p_event_name||'&p_event_key='||p_event_key);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'RaiseEvent', p_event_name, p_event_key);
    wfe_html_util.Error;
    --raise;
end RaiseEvent;
-- RaiseEventConfirm
--   Screen which confirms to user that event was raised.
procedure RaiseEventConfirm(
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null)

is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list
begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFE_RAISE_EVENT_SUBMITTED'));
  wfa_html.create_help_function('wf/links/t_r.htm?T_RAISEVNT');
  wfa_sec.header(background_only=>FALSE,
                page_title=>wf_core.translate('WFE_RAISE_EVENT_SUBMITTED'));
  htp.headClose;

  htp.br;
  htp.br;
  htp.br;
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');
  htp.tableRowOpen;
  htp.p('<TD ID="">');
  htp.bold(wf_core.translate('WFE_RAISE_EVENT_SUBMITTED')||': '||p_event_name
                ||' / '||p_event_key);
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  htp.br;

  htp.tableopen (cattributes =>'align=CENTER border=0 summary=""');
  htp.tableRowOpen;
  htp.p('<TD ID="">');
  wfa_html.create_reg_button (wfa_html.base_url||
                                '/Wf_Event_Html.entereventdetails'||
                                '?p_event_name=%',
                              wf_core.translate('WFMON_OK'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('WFMON_OK'));

  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;
exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'RaiseEventConfirm');
    wfe_html_util.Error;
    --raise;
end RaiseEventConfirm;
-- GetSystemIdentifier
--   Returns xml document which contains Local System and In Agent details
procedure GetSystemIdentifier
is

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  l_system_guid raw(16);
  l_agent_guid  raw(16);

  l_begin_dtd   varchar2(240) := '<oracle.apps.wf.event.all.sync>';
  l_end_dtd     varchar2(240) := '</oracle.apps.wf.event.all.sync>';

  l_dtd         varchar2(32000);
  l_systems     number;

  cursor agent is
  select guid
  from   wf_agents
  where  system_guid = l_system_guid
  and    direction   = 'IN'
  and    status      = 'ENABLED';

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  -- Get Local System GUID
  l_system_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

  -- Build XML Document
  l_dtd := l_begin_dtd;

  l_dtd := l_dtd||wf_systems_pkg.generate(l_system_guid);

  open agent;
  loop
    fetch agent into l_agent_guid;
    exit when agent%notfound;
    if l_agent_guid is not null then
      l_dtd := substr(l_dtd||wf_agents_pkg.generate(l_agent_guid),1,32000);
    end if;
  end loop;
  close agent;

  l_dtd := substr(l_dtd||l_end_dtd,1,32000);

  owa_util.mime_header('text/xml', TRUE);

  owa_util.http_header_close;

  htp.p(l_dtd);

exception
  when OTHERS then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'GetSystemIdentifier');
    wfe_html_util.Error;
    --raise;
end GetSystemIdentifier;

-- Event Queue Display
--   Shows all event queues and message count that use WF_EVENT_QH queue
--   handler
-- MODIFICATION LOG:
--    06-JUN-2001 JWSMITH BUG 1819232 - Added alt attr for IMG tag for ADA
--
procedure EventQueueDisplay
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  admin_mode varchar2(1) := 'N';
  realname varchar2(360);   -- Display name of username
  s0 varchar2(2000);       -- Dummy
  l_error_msg varchar2(240);
  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(40);
  l_text               varchar2(240);
  l_onmouseover        varchar2(240);
  l_sqlstmt            varchar2(240);
  l_count              number;
  l_default_queue      varchar2(80);
  l_rc                 binary_integer;
  l_knowndatatype      boolean := FALSE;

  cursor queues_cursor is
    select  wfa.protocol,
            wfa.direction,
            wfa.display_name,
            substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1) QUEUE_NAME,
            wfa.queue_name SCHEMA_QUEUE_NAME,
            aq.queue_table QUEUE_TABLE,
            upper(wfa.queue_handler) QUEUE_HANDLER
    from    wf_agents wfa ,
            all_queues aq
    where   wfa.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
    --and     upper(wfa.queue_handler) = 'WF_EVENT_QH'
    and     aq.name = substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1)
    and     aq.owner = substr(wfa.queue_name,1,instr(wfa.queue_name,'.',1)-1)
    order by queue_name;

  rowcount number;

begin
  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Check if Accessible
  wf_event_html.isAccessible('AGENTS');

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFGENERIC_QUEUE_TITLE'));
  wfa_html.create_help_function('wf/links/t_r.htm?T_REVQUE');
  htp.headClose;
  wfa_sec.Header(FALSE, '',wf_core.translate('WFGENERIC_QUEUE_TITLE'), FALSE);
  htp.br;

  -- This page is deprecated since Agent Activity link in Workflow Manager also shows the
  -- same details
  htp.center(Wf_Core.Translate('WFE_QUEUEPAGE_DEPRECATED'));
  htp.htmlClose;
  return;

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"
     summary="' || wf_core.translate('WFGENERIC_QUEUE_TITLE') || '"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PROTOCOL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PROTOCOL') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('AGENT_NAME')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('AGENT_NAME') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('INBOUND_PROMPT')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('INBOUND_PROMPT') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_COUNT')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('QUEUE_COUNT') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('VIEW_DETAIL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('VIEW_DETAIL') || '"');

  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for queues in queues_cursor loop
    l_sqlstmt := 'SELECT COUNT(*) FROM '||queues.queue_table||
                ' WHERE Q_NAME = :b1';

    EXECUTE IMMEDIATE l_sqlstmt INTO l_count USING queues.queue_name;

    htp.tableRowOpen(null, 'TOP');

    htp.tableData(queues.protocol, 'center',
                  cattributes=>'headers="' ||
                     wf_core.translate('PROTOCOL') || '"');

    htp.tableData(nvl(queues.display_name,'&'||'nbsp'), 'left',
                  cattributes=>'headers="' ||
                     wf_core.translate('AGENT_NAME') || '"');

    htp.tableData(queues.direction, 'center',
                  cattributes=>'headers="' ||
                     wf_core.translate('INBOUND_PROMPT') || '"');

    htp.tableData(nvl(l_count,0), 'center',
                  cattributes=>'headers="' ||
                     wf_core.translate('QUEUE_COUNT') || '"');

    --
    -- Check if queue type matches default event queue WF_ERROR
    -- If it does, then we can allow drill down on wf_event_t
    --
    begin
      SELECT queue_name
      INTO   l_default_queue
      FROM   wf_agents
      WHERE  name = 'WF_ERROR'
      AND    system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

      dbms_aqadm.verify_queue_types(l_default_queue,
                                    queues.schema_queue_name,
                                    '',
                                    l_rc);
      IF l_rc = 1 then
         htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
      '/wf_event_html.FindQueueMessage?p_queue_name='||
                                  queues.queue_name||'&p_type=WF_EVENT_T',
                              ctext=>'<IMG SRC="'||wfa_html.image_loc
                                ||'affind.gif" alt="' ||
                      wf_core.translate('FIND') || '" BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE" id=""');
         l_knowndatatype := TRUE;
      END IF;

      IF l_knowndatatype = FALSE then
        SELECT queue_name
        INTO   l_default_queue
        FROM   wf_agents
        WHERE  name = 'ECX_INBOUND'
        AND    system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

        dbms_aqadm.verify_queue_types(l_default_queue,
                                    queues.schema_queue_name,
                                    '',
                                    l_rc);

        IF l_rc = 1 then
           htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
           '/wf_event_html.FindECXMSGQueueMessage?p_queue_name='||
                                  queues.queue_name||'&p_type=ECX_MSG',
                              ctext=>'<IMG SRC="'||wfa_html.image_loc
                                ||'affind.gif" alt="' ||
                      wf_core.translate('FIND') || '" BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE" id=""');
           l_knowndatatype := TRUE;
        END IF;
      END IF;

      IF l_knowndatatype = FALSE then
        SELECT queue_name
        INTO   l_default_queue
        FROM   wf_agents
        WHERE  name = 'ECX_TRANSACTION'
        AND    system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

        dbms_aqadm.verify_queue_types(l_default_queue,
                                    queues.schema_queue_name,
                                    '',
                                    l_rc);

        IF l_rc = 1 then
           htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
           '/wf_event_html.FindECX_INENGOBJQueueMessage?p_queue_name='||
                                  queues.queue_name||'&p_type=INENGOBJ',
                              ctext=>'<IMG SRC="'||wfa_html.image_loc
                                ||'affind.gif" alt="' ||
                      wf_core.translate('FIND') || '" BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE" id=""');
           l_knowndatatype := TRUE;
        END IF;
      END IF;

      IF l_knowndatatype = FALSE then
        htp.tableData(wf_core.translate('WFE_NOT_AVAILABLE'),'center',
                      cattributes=>'id=""');
      END IF;

    exception
      when others then
        htp.tableData(wf_core.translate('WFE_NOT_AVAILABLE'),'center',
                      cattributes=>'id=""');
    end;
    l_knowndatatype := FALSE;
  end loop;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'EventQueueDisplay');
    wfe_html_util.Error;
    --raise;
end EventQueueDisplay;
-- FindQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindQueueMessage (
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE	in	varchar2 default null
)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list
  l_url    varchar2(240);  -- url for form
  title     varchar2(2000);
  helptext  varchar2(2000);


  cursor queues_cursor is
  select
          substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1) QUEUE_NAME
  from    wf_agents wfa ,
          all_queues aq
  where   wfa.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
  and     aq.name = substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1)
  and     aq.name like nvl(p_queue_name,'%')
  and     aq.owner = substr(wfa.queue_name,1,instr(wfa.queue_name,'.',1)-1)
  order by queue_name;

  -- addable event cursor
  -- all events meet the query criteria
  cursor aevcurs is
    select GUID, DISPLAY_NAME, NAME, TYPE, STATUS
      from WF_EVENTS_VL
     where TYPE = 'EVENT'
     order by NAME;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  l_url := 'Wf_Event_Html.ListQueueMessages';
  title := wf_core.translate('WFE_FIND_QUEUE_MESSAGES_TITLE');
  helptext := 'wf/links/t_f.htm?T_FDQMSG';

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;
  htp.title(title);
  wfa_html.create_help_function(helptext);
  fnd_document_management.get_open_dm_display_window;
  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, title, TRUE);

  -- Form
  htp.formOpen(curl=>l_url,
               cmethod=>'Post',
                cattributes=>'NAME="WF_QUEUE_MESSAGE_FIND"');
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Queue Name (pulldown list of Queue Names)
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_queue_name">' ||
                wf_core.translate('QUEUE_NAME') || '</LABEL>',
                calign=>'right',
                cattributes=>'valign=middle id=""');
  htp.p('<TD ID="' || wf_core.translate('QUEUE_NAME') || '">');
  htp.formSelectOpen(cname=>'p_queue_name',cattributes=>'id="i_queue_name"');
  for i in queues_cursor loop
        htp.formSelectOption(cvalue=>i.queue_name
                        ,cattributes=>'value='||i.queue_name);
  end loop;
  htp.formSelectClose;
  htp.p('</TD>');
  htp.tableRowClose;

  -- Event Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_event_name">' ||
      wf_core.translate('EVENT_NAME') || '</LABEL>',
      calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_event_name', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_event_name"'),
                calign=>'Left', cattributes=>'id=""');
  htp.tableRowClose;

  -- Event Key
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_event_key">' ||
      wf_core.translate('EVENT_KEY') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_event_key', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_event_key"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Message Status
  template := htf.formSelectOpen('p_message_status',
     cattributes=>'id="i_message_status"')||wf_core.newline;

  template := template||htf.formSelectOption(wf_core.translate('ANY'),
                              null,'VALUE="ANY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('READY'),
                              'SELECTED','VALUE="READY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('WAIT'),
                              null,'VALUE="WAIT"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('PROCESSED'),
                              null,'VALUE="PROCESSED"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('EXPIRED'),
                              null,'VALUE="EXPIRED"');
  template := template||wf_core.newline||htf.formSelectClose;

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_message_status">' ||
       wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;
  htp.formClose;
  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_QUEUE_MESSAGE_FIND.submit()',
                              wf_core.translate('GO'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('GO'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'FindQueueMessage');
    wfe_html_util.Error;
end;
-- FindECXMSGQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindECXMSGQueueMessage(
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE        in      varchar2 default null
)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list
  l_url    varchar2(240);  -- url for form
  title     varchar2(2000);
  helptext  varchar2(2000);

  cursor queues_cursor is
  select
          substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1) QUEUE_NAME
  from    wf_agents wfa ,
          all_queues aq
  where   wfa.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
  and     aq.name = substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1)
  and     aq.name like nvl(p_queue_name,'%')
  and     aq.owner = substr(wfa.queue_name,1,instr(wfa.queue_name,'.',1)-1)
  order by queue_name;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  l_url := 'ecx_workflow_html.ListECXMSGQueueMessages';
  title := wf_core.translate('WFE_FIND_QUEUE_MESSAGES_TITLE');
  helptext := 'wf/links/t_f.htm?T_FDQMSG';

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;
  htp.title(title);
  wfa_html.create_help_function(helptext);
  fnd_document_management.get_open_dm_display_window;
  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, title, TRUE);

  -- Form
  htp.formOpen(curl=>l_url,
               cmethod=>'Post',
                cattributes=>'NAME="WF_QUEUE_MESSAGE_FIND"');
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Queue Name (pulldown list of Queue Names)
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_queue_name">' ||
                wf_core.translate('QUEUE_NAME') || '</LABEL>',
                calign=>'right',
                cattributes=>'valign=middle id=""');
  htp.p('<TD ID="' || wf_core.translate('QUEUE_NAME') || '">');
  htp.formSelectOpen(cname=>'p_queue_name',cattributes=>'id="i_queue_name"');
  for i in queues_cursor loop
        htp.formSelectOption(cvalue=>i.queue_name
                        ,cattributes=>'value='||i.queue_name);
  end loop;
  htp.formSelectClose;
  htp.p('</TD>');
  htp.tableRowClose;

  -- Transaction Type
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_transaction_type">' ||
      wf_core.translate('TRANSACTIONTYPE') || '</LABEL>',
      calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_transaction_type', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_transaction_type"'),
                calign=>'Left', cattributes=>'id=""');
  htp.tableRowClose;

  -- Document Number
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_document_number">' ||
      wf_core.translate('DOCUMENTNUMBER') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_document_number', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_document_number"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Party Site ID
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_party_site_id">' ||
      wf_core.translate('PARTYSITEID') || '</LABEL>',
      calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_party_site_id', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_party_site_id"'),
                calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  -- Message Status
  template := htf.formSelectOpen('p_message_status',
     cattributes=>'id="i_message_status"')||wf_core.newline;

  template := template||htf.formSelectOption(wf_core.translate('ANY'),
                              null,'VALUE="ANY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('READY'),
                              'SELECTED','VALUE="READY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('WAIT'),
                              null,'VALUE="WAIT"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('PROCESSED'),
                              null,'VALUE="PROCESSED"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('EXPIRED'),
                              null,'VALUE="EXPIRED"');
  template := template||wf_core.newline||htf.formSelectClose;

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_message_status">' ||
       wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;
  htp.formClose;
  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_QUEUE_MESSAGE_FIND.submit(
)',
                              wf_core.translate('GO'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('GO'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;
  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'FindECXMSGQueueMessage');
    wfe_html_util.Error;
end;
-- FindECXMSGQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindECX_INENGOBJQueueMessage(
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE        in      varchar2 default null
)
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  template varchar2(4000); -- Use for construct form select list
  l_url    varchar2(240);  -- url for form
  title     varchar2(2000);
  helptext  varchar2(2000);

  cursor queues_cursor is
  select
          substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1) QUEUE_NAME
  from    wf_agents wfa ,
          all_queues aq
  where   wfa.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
  and     aq.name = substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1)
  and     aq.name like nvl(p_queue_name,'%')
  and     aq.owner = substr(wfa.queue_name,1,instr(wfa.queue_name,'.',1)-1)
  order by queue_name;

begin
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

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
  wf_event_html.isAccessible('AGENTS');

  l_url := 'ecx_workflow_html.ListECX_INENGOBJQueueMessages';
  title := wf_core.translate('WFE_FIND_QUEUE_MESSAGES_TITLE');
  helptext := 'wf/links/t_f.htm?T_FDQMSG';

  -- Render page
  htp.htmlOpen;

  -- Set page title
  htp.headOpen;
  htp.title(title);
  wfa_html.create_help_function(helptext);
  fnd_document_management.get_open_dm_display_window;
  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, null, title, TRUE);

  -- Form
  htp.formOpen(curl=>l_url,
               cmethod=>'Post',
                cattributes=>'NAME="WF_QUEUE_MESSAGE_FIND"');
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 summary=""');

  -- Queue Name (pulldown list of Queue Names)
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_queue_name">' ||
                wf_core.translate('QUEUE_NAME') || '</LABEL>',
                calign=>'right',
                cattributes=>'valign=middle id=""');
  htp.p('<TD ID="' || wf_core.translate('QUEUE_NAME') || '">');
  htp.formSelectOpen(cname=>'p_queue_name',cattributes=>'id="i_queue_name"');
  for i in queues_cursor loop
        htp.formSelectOption(cvalue=>i.queue_name
                        ,cattributes=>'value='||i.queue_name);
  end loop;
  htp.formSelectClose;
  htp.p('</TD>');
  htp.tableRowClose;

  -- Message Id
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_message_id">' ||
      wf_core.translate('MESSAGEID') || '</LABEL>',
      calign=>'Right', cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'p_message_id', csize=>40,
                                     cmaxlength=>240,
                cattributes=>'id="i_message_id"'),
                calign=>'Left', cattributes=>'id=""');
  htp.tableRowClose;

  -- Message Status
  template := htf.formSelectOpen('p_message_status',
     cattributes=>'id="i_message_status"')||wf_core.newline;

  template := template||htf.formSelectOption(wf_core.translate('ANY'),
                              null,'VALUE="ANY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('READY'),
                              'SELECTED','VALUE="READY"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('WAIT'),
                              null,'VALUE="WAIT"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('PROCESSED'),
                              null,'VALUE="PROCESSED"')||wf_core.newline||
                htf.formSelectOption(wf_core.translate('EXPIRED'),
                              null,'VALUE="EXPIRED"');
  template := template||wf_core.newline||htf.formSelectClose;

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_message_status">' ||
       wf_core.translate('STATUS') || '</LABEL>',
                calign=>'Right',cattributes=>'id=""');
  htp.tableData(cvalue=>template, calign=>'Left',cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;
  htp.formClose;
  -- Add submit button
  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_QUEUE_MESSAGE_FIND.submit(
)',
                              wf_core.translate('GO'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate('GO'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;
  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('WF_EVENT_HTML', 'FindECX_INENGOBJQueueMessage');
    wfe_html_util.Error;
end;




-- ListQueueMessages
--   Queue Messages after Filter applied
-- IN
--  Queue Name
--  Event Name
--  Event Key
--  Message Status
-- MODIFICATION LOG:
--    06-JUN-2001 JWSMITH BUG 1819232 - Added alt attr for IMG tag for ADA
--                 -added label tags to form input fields
--
procedure ListQueueMessages (
  P_QUEUE_NAME  in      varchar2 default null,
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null,
  P_MESSAGE_STATUS in   varchar2 default 'ANY',
  P_MESSAGE_ID  in      varchar2 default null
) is
  username                 varchar2(320);   -- Username to query
  admin_role               varchar2(320); -- Role for admin mode
  realname                 varchar2(360);   -- Display name of username
  s0                       varchar2(2000);       -- Dummy
  admin_mode               varchar2(1) := 'N';
  l_media                  varchar2(240) := wfa_html.image_loc;
  l_icon                   varchar2(40) := 'FNDILOV.gif';
  l_text                   varchar2(240) := '';
  l_onmouseover            varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_url                    varchar2(4000);
  l_error_msg              varchar2(240);
  l_more_data              BOOLEAN := TRUE;
  l_queue_table             varchar2(30);
  l_parameters		   varchar2(32000);
  i			   binary_integer;
  l_exceptionQueue         VARCHAR2(40);

  /*
  ** Added to display Queue Table USER_DATA field
  */
  TYPE queue_contents_t IS REF CURSOR;
  l_qcontents              queue_contents_t;
  l_msgstate               number;
  l_charmsgstate           varchar2(240);
  l_msg_id                 RAW(16);
  l_fromagent              varchar2(30);
  l_fromsystem             varchar2(30);
  l_eventname              varchar2(240);
  l_eventkey               varchar2(240);
  l_string                 varchar2(240);
  l_message                wf_event_t;
  l_sqlstmt                varchar2(240);
  l_eventdata              clob;
  l_state                  number;
  l_qtable                 varchar2(240);
  l_likeeventname          varchar2(240);
  l_likeeventkey           varchar2(240);
  l_errmsg		   varchar2(4000);
  l_errstack		   varchar2(4000);
  l_parmlist_t             wf_parameter_list_t;

begin
  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Check if Accessible
  wf_event_html.isAccessible('AGENTS');

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFQUEUE_MESSAGE_TITLE'));
  wfa_html.create_help_function('wf/links/t_l.htm?T_LQUEM');
  htp.headClose;
  wfa_sec.Header(FALSE, owa_util.get_owa_service_path ||'wf_event_html.FindQueueMessage?p_queue_name='||p_queue_name||'&p_type=WF_EVENT_T', wf_core.translate('WFQUEUE_MESSAGE_TITLE'), TRUE);
  htp.br;

  IF (admin_mode = 'N') THEN
     htp.center(htf.bold(l_error_msg));
     return;
  END IF;

   -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"
      summary="' || wf_core.translate('WFQUEUE_MESSAGE_TITLE') || '"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');


  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('EVENTNAME')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('EVENTNAME') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('EVENTKEY')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('EVENTKEY') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('WF_CORRELATION')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('WF_CORRELATION') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PARAMETERS')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PARAMETERS') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('FROMAGENTSYSTEM')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('FROMAGENTSYSTEM') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('TOAGENTSYSTEM')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('TOAGENTSYSTEM') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('WF_SEND_DATE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('WF_SEND_DATE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('WFMON_ERROR_MESSAGE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('WFMON_ERROR_MESSAGE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('WFMON_ERROR_STACK')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('WFMON_ERROR_STACK') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGESTATE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGESTATE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('XMLEVENTDATA')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                  wf_core.translate('XMLEVENTDATA') || '"');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('TXTEVENTDATA')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('TXTEVENTDATA') || '"');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- As per review comment running the sql for
  -- wf_agent wqueues alone

  -- Determine the Queue Table based on the Queue Name
  -- First check if its registered in wf_agents then use the
  -- info from wf_agents
  -- begin
    select  aq.queue_table
    into    l_qtable
    from    wf_agents wfa ,
            all_queues aq
    where   aq.name        = p_queue_name
    and     substr(wfa.queue_name,instr(wfa.queue_name,'.',1)+1)  =  aq.name
    and     aq.owner = substr(wfa.queue_name,1,instr(wfa.queue_name,'.',1)-1);
  -- exception
  --  when no_data_found then
    --use the direct query on all_queues
    --with rownum = 1 to take the first hit
    --SELECT queue_table INTO l_qtable
    --FROM   all_queues
    --WHERE  name   = p_queue_name
    --AND    rownum = 1;
  -- end;

  l_exceptionQueue := 'AQ$_'||l_qtable||'_E';

  -- Convert the character message state to numbers
  IF p_message_status = 'READY' THEN
    l_state := 0;
  ELSIF p_message_status = 'WAIT' THEN
    l_state := 1;
  ELSIF p_message_status = 'PROCESSED' THEN
    l_state := 2;
  ELSIF p_message_status = 'EXPIRED' THEN
    l_state := 3;
  ELSIF p_message_status = 'ANY' THEN
    l_state := 100;
  END IF;

  -- Create Filters for Event Name and Event Key
  IF p_event_name IS NULL THEN
      l_likeeventname := '%';
  ELSE
      l_likeeventname := '%'||upper(p_event_name)||'%';
  END IF;

  IF p_event_key IS NULL THEN
      l_likeeventkey := '%';
  ELSE
      l_likeeventkey := '%'||upper(p_event_key)||'%';
  END IF;

  -- Show rows that match our criteria

  if l_state=100 then
    OPEN l_qcontents FOR
                'SELECT msgid, state, user_data FROM '||l_qtable||
                ' WHERE q_name in(:1,:2)'
                using p_queue_name, l_exceptionQueue;
  else
    OPEN l_qcontents FOR
                 'SELECT msgid, state, user_data FROM '||l_qtable||
                 ' WHERE STATE = :1 AND q_name in (:2,:3)'
                 using l_state,p_queue_name, l_exceptionQueue;
  end if;
  LOOP
    FETCH l_qcontents INTO l_msg_id,
                                l_msgstate,
                                l_message;

    EXIT WHEN l_qcontents%NOTFOUND;

    -- Convert Numeric Message State to characters
    IF l_msgstate = 0 THEN
      l_charmsgstate := (wf_core.translate('READY'));
    ELSIF l_msgstate = 1 THEN
      l_charmsgstate := (wf_core.translate('WAIT'));
    ELSIF l_msgstate = 2 THEN
      l_charmsgstate := (wf_core.translate('PROCESSED'));
    ELSIF l_msgstate = 3 THEN
      l_charmsgstate := (wf_core.translate('EXPIRED'));
    ELSE
      l_charmsgstate := (wf_core.translate('UNKNOWN'));
    END IF;

    l_eventname := l_message.GetEventName();
    l_eventkey  := l_message.GetEventKey();

    IF (upper(l_eventname) LIKE l_likeeventname
        OR l_eventname IS NULL)
    AND ( upper(l_eventkey) LIKE l_likeeventkey
         OR l_eventkey IS NULL ) THEN

      htp.tableRowOpen(null, 'TOP');

      htp.p('<!-- Msg Id '||l_msg_id||' -->');

      IF l_EventName IS NULL THEN
        l_EventName := '&nbsp';
      END IF;

      htp.tableData(l_EventName, 'left', cattributes=>'headers="' ||
              wf_core.translate('EVENTNAME') || '"');

      IF l_eventkey IS NULL THEN
        l_eventkey := '&nbsp';
      END IF;

      htp.tableData(l_EventKey, 'left', cattributes=>'headers="' ||
              wf_core.translate('EVENTKEY') || '"');

      if l_message.Correlation_Id is not null then
        htp.tableData(l_message.GetCorrelationId(),'left', cattributes=>'headers="' || wf_core.translate('WF_CORRELATION') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      -- Display the Parameter List
      l_parmlist_t := l_message.getParameterList();
      if (l_parmlist_t is not null) then
        i := l_parmlist_t.FIRST;
        while (i <= l_parmlist_t.LAST) loop
          l_parameters := l_parameters||l_parmlist_t(i).getName()||'='||
			l_parmlist_t(i).getValue()||' ';
          i := l_parmlist_t.NEXT(i);
        end loop;
        htp.tableData(l_parameters,'left',
              cattributes=>'headers="' ||
                wf_core.translate('PARAMETERS') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;


      if l_message.From_Agent is not null then
        htp.tableData(l_message.GetFromAgent().GetName()||'@'
        ||l_message.GetFromAgent().GetSystem(), 'left',
              cattributes=>'headers="' ||
                wf_core.translate('FROMAGENTSYSTEM') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.To_Agent is not null then
        htp.tableData(l_message.GetToAgent().GetName()||'@'
        ||l_message.GetToAgent().GetSystem(), 'left',
             cattributes=>'headers="' ||
                wf_core.translate('TOAGENTSYSTEM') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.Send_Date is not null then
        htp.tableData(to_char(l_message.GetSendDate(),'DD-MON-YYYY HH24:MI:SS'),'left', cattributes=>'headers="' ||
         wf_core.translate('WF_SEND_DATE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.error_message is not null then
        htp.tableData(l_message.GetErrorMessage(),
	'left', cattributes=>'headers="' ||
         wf_core.translate('WFMON_ERROR_MESSAGE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.error_stack is not null then
        htp.tableData(l_message.GetErrorStack(),
	'left', cattributes=>'headers="' ||
         wf_core.translate('WFMON_ERROR_STACK') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      htp.tableData(l_charmsgstate,'center', cattributes=>'headers="' ||
          wf_core.translate('MESSAGESTATE') || '"');

      l_eventdata := l_message.GetEventData();

      htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_event_html.EventDataContents?p_message_id='||l_msg_id
||'&p_queue_table='||l_qtable||'&p_mimetype=text/xml',
                 ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif"                                    alt="' || wf_core.translate('FIND') || '"
                              BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
                 headers="' || wf_core.translate('XMLEVENTDATA') || '"');
      htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_event_html.EventDataContents?p_message_id='||l_msg_id
||'&p_queue_table='||l_qtable||'&p_mimetype=text',
                 ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif"                                    alt="' || wf_core.translate('FIND') || '"
                              BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
                 headers="' || wf_core.translate('TXTEVENTDATA') || '"');
  END IF;
  l_parameters := null;

  END LOOP;
  CLOSE l_qcontents;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;

  htp.htmlClose;

exception
  when others then
    rollback;
    Wf_Core.Context('WF_EVENT_HTML', 'ListQueueMessages',
                    p_queue_name);
    wfe_html_util.Error;
    --raise;
end ListQueueMessages;
-- EventDataContents
--   Shows clob contents in XML format
-- IN
--  Message ID
--  Queue Table
procedure EventDataContents (
 P_MESSAGE_ID   in      varchar2,
 P_QUEUE_TABLE  in      varchar2,
 P_MIMETYPE     in	varchar2 default 'text/xml'
) is

  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode

  TYPE queue_contents_t IS REF CURSOR;
  l_qcontents             queue_contents_t;
  l_sqlstmt               varchar2(32000);
  l_message               wf_event_t;
  l_clob                  clob;
  l_splice_size           integer := 100;
  l_current_position      integer := 1;
  l_amount_to_read        integer :=0;
  l_clobsize              integer := 0;
  l_messagedata           varchar2(32000);
  l_counter               integer :=0;
  l_beginposition         integer :=1;
  l_endposition           integer :=0;
  l_amounttoread          integer :=0;
  l_begintagpos           integer :=0;
  l_endtagpos             integer :=0;
  l_doclength             integer :=0;
  l_char                  varchar2(4);
  l_owner                 varchar2(30);
  l_queue_table           varchar2(30);
  l_dummy                 number;
begin
  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_events_pkg.setMode;

   -- Check Admin Priviledge
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(username, admin_role)) then
    -- Have admin privledge, do nothing.
    null;
  else
    wf_core.raise('WF_NOTADMIN');
  end if;

  -- Validate the MIME type
  if (instr(p_mimetype, '<', 1) > 0 or instr(p_mimetype, '>', 1) > 0) then
     Wf_Core.Raise('WF_INVALID_MIME');
  end if;

  -- Validate the Queue Table
  if (instr(p_queue_table, '.', 1) > 0) then
     l_owner := substr(p_queue_table, 1, instr(p_queue_table, '.', 1)-1);
     l_queue_table := substr(p_queue_table, instr(p_queue_table, '.', 1)+1);
  else
     l_owner := Wf_Core.Translate('WF_SCHEMA');
     l_queue_table := p_queue_table;
  end if;

  begin
     SELECT 1
     INTO   l_dummy
     FROM   all_queue_tables
     WHERE  owner = l_owner
     AND    queue_table = l_queue_table
     AND    rownum = 1;
  exception
     when no_data_found then
        -- mostly no_data_found error
        Wf_Core.Token('OWNER', l_owner);
        Wf_Core.Token('QUEUE', l_queue_table);
        Wf_Core.Raise('WFE_QUEUE_NOTEXIST');
  end;

  -- Get the Clob
  l_sqlstmt := 'SELECT user_data FROM '||p_queue_table
                ||' WHERE MSGID = :b';

  OPEN l_qcontents FOR l_sqlstmt USING p_message_id;
  LOOP
    FETCH l_qcontents INTO l_message;

    l_clob := l_message.GetEventData();

    EXIT WHEN l_qcontents%NOTFOUND;

  END LOOP;

  --
  -- Set the Mime type to be text/xml
  --

  -- bug 2640742
  l_doclength   := dbms_lob.getlength(l_clob);

  IF (l_clob IS NOT NULL and l_doclength > 0) THEN
    --owa_util.mime_header('text/xml', TRUE);
    owa_util.mime_header(p_mimetype, TRUE);

    owa_util.http_header_close;

    -- Check for the presence of '<' in the beginning of clob. Leading white spaces
    -- in the XML document are ignored.
    l_counter := 1;
    loop
     l_char := dbms_lob.substr(l_clob, 1, l_counter);
     if (l_char = wf_core.tab or l_char = ' ') then
        l_counter := l_counter + 1;
     elsif (l_char = '<') then
        l_begintagpos := l_counter;
        exit;
     else
        l_begintagpos := 0;
        exit;
     end if;
    end loop;

    -- Check for the presence of '>' in the end of clob. Trailing white spaces in the
    -- the XML document are ignored
    l_counter := l_doclength;
    loop
     l_char := dbms_lob.substr(l_clob, 1, l_counter);
     if (l_char = wf_core.tab or l_char = ' ') then
        l_counter := l_counter - 1;
     elsif (l_char = '>') then
        l_endtagpos := l_counter;
        exit;
     else
        l_endtagpos := 0;
        exit;
     end if;
    end loop;

    l_counter:=0;

    --
    -- Write out the Clob
    --
    -- Check if clob contains a xml or text data.

    IF (l_begintagpos > 0  AND l_endtagpos > 0) THEN
     LOOP

        l_counter := l_counter + 1;

        l_endposition := dbms_lob.instr(l_clob,'>',1,l_counter);

        EXIT when l_endposition = 0;

        l_amounttoread := l_endposition - l_beginposition + 1;

        l_messagedata := dbms_lob.substr(l_clob, l_amounttoread,
                                l_beginposition);

        htp.p(l_messagedata);

        l_beginposition := l_endposition + 1;

     END LOOP;
    ELSE
     l_amounttoread:=16000;
     LOOP
        l_counter := l_counter + 1;

        begin
         dbms_lob.read(
                       l_clob,
                       l_amounttoread,
                       l_beginposition,
                       l_messagedata
                      );

        exception
        when NO_DATA_FOUND then
                exit;
        end;
        htp.p(l_messagedata);
        l_beginposition := (l_amounttoread*l_counter) + 1;
     END LOOP;
    END IF;
  ELSE
     htp.p(wf_Core.translate('NO_MESSAGE_FOUND'));
  END IF;
exception
  when others then
    rollback;
    Wf_Core.Context('WF_EVENT_HTML', 'EventDataContents',
                    p_queue_table,p_message_id);
    wfe_html_util.Error;
    --raise;
end EventDataContents;
procedure EventDataContents (
 P_EVENTATTRIBUTE  in      varchar2,
 P_ITEMTYPE        in      varchar2,
 P_ITEMKEY         in      varchar2,
 P_MIME_TYPE       in      varchar2 default 'text/xml') IS

  l_event_t               wf_event_t;
  l_eventdata             clob;
  l_splice_size           integer := 100;
  l_current_position      integer := 1;
  l_amount_to_read        integer :=0;
  l_clobsize              integer := 0;
  l_messagedata           varchar2(32000);
  l_counter               integer :=0;
  l_beginposition         integer :=1;
  l_endposition           integer :=0;
  l_amounttoread          integer :=0;
  l_begintagpos           integer :=0;
  l_endtagpos             integer :=0;
  l_doclength             integer :=0;

begin

  wf_event_t.Initialize(l_event_t);

  l_event_t := wf_engine.GetItemAttrEvent(
                                itemtype        => P_ItemType,
                                itemkey         => P_ItemKey,
                                name            => P_EventAttribute);

  l_eventdata := l_event_t.GetEventData();

  IF l_eventdata IS NOT NULL THEN
    owa_util.mime_header(p_mime_type, TRUE);

    owa_util.http_header_close;

    -- bug 2640742
    l_doclength   := dbms_lob.getlength(l_eventdata);

    -- Check for the presence of '>' in the begin of clob.
    Loop
     l_counter := l_counter + 1;
     l_begintagpos := dbms_lob.instr(l_eventdata,'<',1,l_counter);
     EXIT when l_begintagpos>0 or l_counter=l_doclength;
    END loop;
    l_counter:=0;

    -- Check for the presence of '<' in the end of clob.
    Loop
     l_counter := l_counter + 1;
     l_endtagpos   := dbms_lob.instr(l_eventdata,'>',1,l_doclength-l_counter);
     EXIT when l_endtagpos>0 or l_counter=l_doclength ;
    END loop;
    l_counter:=0;

    --
    -- Write out the Clob
    --
    -- Check if clob contains a xml or text data.

    IF l_begintagpos <> 0  AND l_endtagpos <> 0 THEN
     LOOP

        l_counter := l_counter + 1;

        l_endposition := dbms_lob.instr(l_eventdata,'>',1,l_counter);

        EXIT when l_endposition = 0;

        l_amounttoread := l_endposition - l_beginposition + 1;

        l_messagedata := dbms_lob.substr(l_eventdata, l_amounttoread,
                                l_beginposition);

        htp.p(l_messagedata);

        l_beginposition := l_endposition + 1;

     END LOOP;
    ELSE
     l_amounttoread:=16000;
     LOOP
        l_counter := l_counter + 1;

        begin
         dbms_lob.read(
                       l_eventdata,
                       l_amounttoread,
                       l_beginposition,
                       l_messagedata
                      );

        exception
        when NO_DATA_FOUND then
                exit;
        end;
        htp.p(l_messagedata);
        l_beginposition := (l_amounttoread*l_counter) + 1;
     END LOOP;
    END IF;
  ELSE
     htp.p(wf_Core.translate('NO_MESSAGE_FOUND'));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
    WF_CORE.Context('WF_STANDARD', 'EventDataContents',
                      P_EventAttribute, P_ItemType, P_ItemKey);
    wfe_html_util.Error;
    --RAISE;
end EventDataContents;


/** Returns Event Edit Subscription URL constructed in the RF.jsp format. For invalid function the
 * URL returned will be NULL
 */
PROCEDURE getFWKEvtSubscriptionUrl(guid in varchar2 default null,
			   l_lurl out nocopy varchar2) is

  l_function varchar2(4000);
  l_params varchar2(4000);
  functionId number;

begin

  l_function := 'WF_EDIT_SUBSCRIPTION';
  if(guid is not null) then
    functionId := fnd_function.get_function_id (l_function);
    l_params := 'Guid='||guid||'&'||'Mode=U';
    l_lurl := fnd_run_function.get_run_function_url( p_function_id => functionId,
                                p_resp_appl_id => -1,
                                p_resp_id => -1,
                                p_security_group_id => null,
                                p_parameters => l_params);
  end if;
end getFWKEvtSubscriptionUrl;


/**Gets old Event Subscription URL's of the form
   host:port/pls/<sid>/Wf_Event_Html.EditSubscription?<params>
   and converts it to a URL of the form RF.jsp so that the
   event subscription page is directly accessed
   without the using PL/SQL catridge.Returns following error code
   0 - Success
   1 - failure
  */
PROCEDURE updateToFWKEvtSubscriptionUrl(oldUrl in varchar2,
                    newUrl out nocopy varchar2,
  		    errorCode out nocopy pls_integer) is
 guid varchar2(4000);
 l_oldUrl varchar2(4000);
begin
   errorCode := 1;
   l_oldUrl := oldUrl;
   WF_MONITOR.parseUrlForParams('h_guid', l_oldUrl, guid);
   getFWKEvtSubscriptionUrl(guid,newUrl);
   if (newUrl is not null) then
      errorCode := 0; --success
   end if;
end updateToFWKEvtSubscriptionUrl;


/**Gets old Event Data URL's of the form
   host:port/pls/<sid>/Wf_Event_Html.EventDataContents?<params>
   and converts it to a URL of the form RF.jsp so that the
   event data page is directly accessed
   without the using PL/SQL catridge.Returns following error code
   0 - Success
   1 - failure
  */
PROCEDURE updateToFWKEvtDataUrl(oldUrl in varchar2,
                    newUrl out nocopy varchar2,
  		    errorCode out nocopy pls_integer) is
 eventAttribute varchar2(4000);
 itemType varchar2(4000);
 itemKey varchar2(4000);
 l_oldUrl varchar2(4000);
begin
   errorCode := 1;
   l_oldUrl := oldUrl;

   WF_MONITOR.parseUrlForParams('P_EventAttribute', l_oldUrl, eventAttribute);
   WF_MONITOR.parseUrlForParams('P_ItemType', l_oldUrl, itemType);
   WF_MONITOR.parseUrlForParams('P_ItemKey', l_oldUrl, itemKey);

   newUrl := WF_OAM_UTIL.getViewXMLURL(p_eventattribute => eventAttribute,
   				       p_itemtype => itemType,
   				       p_itemkey => itemkey);
   if (newUrl is not null) then
      errorCode := 0; --success
   end if;
end updateToFWKEvtDataUrl;


end WF_EVENT_HTML;


/
