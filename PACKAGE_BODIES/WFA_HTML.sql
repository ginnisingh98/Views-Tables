--------------------------------------------------------
--  DDL for Package Body WFA_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFA_HTML" as
/* $Header: wfhtmb.pls 120.5.12010000.7 2009/12/09 18:47:45 vshanmug ship $ */

-- Bug# 2236250 exception to handle invalid number
invalid_number exception;
pragma EXCEPTION_INIT(invalid_number, -6502);


g_priority  varchar2(2000);
g_newline   varchar2(1)    := wf_core.newLine;
g_wfInstall varchar2(15)   := wf_core.translate('WF_INSTALL');
g_webAgent  varchar2(2000) := wf_core.translate('WF_WEB_AGENT');

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as

begin
     null;
end Error;


--
--
-- Login
--   Generate login page.
-- IN
--   message - optional login message
-- NOTE
--   This page is only used to enable access when no external security
--   is installed.  Normally users are authenticated by the chosen
--   security system (IC, WebServer native, etc) and can then access
--   the Workflow Notification pages (Worklist, Detail) directly.
--
procedure Login(
  message in varchar2,
  i_direct in varchar2)
as

c_language    VARCHAR2(80);

begin

  -- Get the global language preference since we don't know who the
  -- user is yet...
  c_language := NVL(wf_pref.get_pref ('-WF_DEFAULT-', 'LANGUAGE'), 'AMERICAN');
  c_language := ''''||c_language||'''';
  dbms_session.set_nls('NLS_LANGUAGE'   , c_language);

  -- Set the language to the default language for the system

  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFA_LOGIN_REQUEST'));
   wfa_html.create_help_function('wf/links/log.htm?LOGIN');
  htp.headClose;
  wfa_sec.Header(background_only=>FALSE, inc_lov_applet=>FALSE);

  htp.p('<FORM NAME="WFA_LOGIN" ACTION="wfa_html.Viewer" TARGET="_top" METHOD="POST">');

-- bug 1838410
   if (i_direct is not null) then
       htp.formHidden('i_direct', i_direct);
   end if;


  if (message is not null) then
    htp.header(4, wf_core.translate(message));
    htp.br;
  end if;

  htp.br;
  htp.tableOpen(calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;
  htp.tableData('<LABEL FOR="i_user_id">' ||
                wf_core.translate('USER_ID') ||
                '</LABEL>', 'Right',
                cattributes=>'id=""');
  htp.tableData(htf.formText('User_ID', 25, cattributes=>'id="i_user_id"'),
                'Left', cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData('<LABEL FOR="i_password">' ||
                wf_core.translate('PASSWORD') ||
                '</LABEL>', 'Right',
                cattributes=>'id=""');
  htp.tableData(htf.formPassword('Password', 25,
                                 cattributes=>'id="i_password"'), 'Left',
                cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableClose;
  htp.centerClose;
  htp.br;

  htp.formClose;

  htp.tableopen (calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD id="">');

  wfa_html.create_reg_button ('javascript:document.WFA_LOGIN.submit()',
                              wf_core.translate ('LOGIN'),
                              wfa_html.image_loc,
                              'FNDJLFOK.gif',
                              wf_core.translate ('LOGIN'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;
exception
  when others then
    rollback;
    wf_core.context('Wfa_Html', 'Login');
    wfa_html.Error;
end Login;

--
-- Viewer
--   Validate user from Login page, then show worklist.
-- IN
--   user_id  - user name
--   password - user password
-- NOTE
--   This page is only used to enable access when no external security
--   is installed.  Normally users are authenticated by the chosen
--   security system (IC, WebServer native, etc) and can then access
--   the Workflow Notification pages (Worklist, Detail) directly.
--
procedure Viewer(
  user_id  in varchar2,
  password in varchar2,
  i_direct in varchar2)
as
  s0          varchar2(320);   -- dummy
  username    varchar2(320);
  realname    varchar2(360);

begin
  -- Validate the user
  if (user_id is null) then
     -- No username entered
     wfa_html.Login('WFA_ENTER_ID');
     return;
  end if;
  username := upper(user_id);

  begin
    wfa_sec.CreateSession(username, password);
  exception
    when others then
      if (wf_core.error_name='WFSEC_USER_PASSWORD') then
        -- Bad username or password
        wf_core.clear;
        wfa_html.Login('WFA_ILLEGAL_IDP');
        return;
      end if;
      -- Raise any other error message
      raise;
  end;

if (i_direct is null) then

  -- Go to home page
  Wfa_Html.Home;

else
  -- Fix for bug 1838410
  -- Instead of navigating to the home page, we will go directly to the URL
  -- specified in i_direct and the user will now be authenticated.  We are
  -- calling the function within a frame.
  -- Example: E-mail notifications with send_accesskey=N.

  htp.p('<HTML>');
  htp.p('<HEAD>');
  htp.p('<TITLE>');
  htp.p('</TITLE>');
  htp.p('</HEAD>');
  htp.p('<FRAMESET ROWS="100%, *">');
  htp.p('<FRAME NAME="DirectLogin" MARGINHEIGHT=10 MARGINWIDTH=10 NORESIZE' ||
    ' src="'||owa_util.get_owa_service_path || i_direct || '">');
  htp.p('</FRAMESET>');
  htp.p('</HTML>');

  end if;

exception
  when others then
    rollback;
    wf_core.context('Wfa_Html', 'Viewer', user_id, password);
    wfa_html.Error;
end Viewer;


--
-- Find
--   Filter page to find notifications of user
--
procedure Find
is
begin
           null;
end Find;

--
-- GetPriorityBounds
--   Get the upper bound and lower bound of certain priority
-- IN
--   priority - Value of priority
--              Valid values are HIGH, NORMAL, LOW and *
-- IN OUT
--   low      - lower bound of numeric priority value
--   up       - upper bound of numeric priority value
-- RETURNS
--   TRUE     - successfully return the boundaries
--   FALSE    - failed to translate
--
function GetPriorityBounds(
  priority in     varchar2,
  low      in out nocopy pls_integer,
  up       in out nocopy pls_integer)
return boolean
as
--  minint   pls_integer := 0;
--  maxint   pls_integer := 2147483647;  /* 2^31 - 1 */

--
-- Priority Range should be 1 - 99
-- For supporting some possible out of range value in the past,
-- we set the range a bit higher
--
  minint   pls_integer := 0;
  maxint   pls_integer := 1000000;
begin
  if    (priority = '*') then
    low  := minint;
    up   := maxint;
  elsif (priority = 'HIGH') then
    low  := minint;
    up   :=  33;
  elsif (priority = 'NORMAL') then
    low  :=  34;
    up   :=  66;
  elsif (priority = 'LOW') then
    low  :=  67;
    up   := maxint;
  else
    low  :=  -1;
    up   :=  -1;
    return FALSE;
  end if;
  return TRUE;
end GetPriorityBounds;

--
-- GetPriorityIcon
--   Get the icon of certain numeric priority
-- IN
--   priority - Value of priority
--              Valid values are minint - maxint
--              defined in GetPriorityBounds
--
-- RETURNS
--   Icon  - location of an icon
--
function GetPriorityIcon(
  priority in     pls_integer)
return varchar2
as
begin
  if    (priority < 34) /* HIGH   */ then
    WFA_HTML.g_priority := WF_CORE.Translate('WFJSP_HIGH_PRIORITY');
    return(wfa_html.image_loc||'high.gif');
  elsif (priority > 66) /* LOW    */ then
    WFA_HTML.g_priority := WF_CORE.Translate('WFJSP_LOW_PRIORITY');
    return(wfa_html.image_loc||'low.gif');
  else                  /* NORMAL */
    return null;
  end if;
end GetPriorityIcon;

--
-- WorkList
--   Construct the worklist (summary page) for user.
-- IN
--   orderkey - Key to order by (default PRIORITY)
--              Valid values are PRIORITY, MESSAGE_TYPE, SUBJECT, BEGIN_DATE,
--              DUE_DATE, END_DATE, STATUS.
--   status - Status to query (default OPEN)
--            Valid values are OPEN, CLOSED, CANCELED, ERROR, *.
--   user - User to query notifications for.  If null query user currently
--          logged in.
--          Note: Only a user in role WF_ADMIN_ROLE can query a user other
--          than the current user.
--   fromlogin - flag to indicate if coming from apps login screen,
--             - if non-zero, force an exception
--            - so that cookie value is not being used
--
procedure WorkList(
  nid      in number,
  orderkey in varchar2,
  status in varchar2,
  owner in varchar2 ,
  display_owner in varchar2,
  user in varchar2,
  display_user in varchar2,
  fromuser in varchar2,
  display_fromuser in varchar2,
  ittype in varchar2,
  msubject in varchar2,
  beg_sent in varchar2,
  end_sent in varchar2,
  beg_due in varchar2,
  end_due in varchar2,
  priority in varchar2,
  delegatedto in varchar2,
  display_delegatedto in varchar2,
  delegated_by_me in number,
  resetcookie in number,
  clearbanner in varchar2,
  fromfindscreen in number,
  fromlogin in number)
as
begin
  null;
end Worklist;

--
-- Authenticate (PRIVATE)
--   Verify user is allowed access to this notification
-- IN
--   nid - notification id
--   nkey - notification access key (if disconnected)
-- RETURNS
--   Current user name
--
function Authenticate(
  nid in number,
  nkey in varchar2)
return varchar2
is
  usercolon pls_integer;
  rolecolon pls_integer;
  origcolon pls_integer;
  username varchar2(320);
  recipient varchar2(320);
  orig_recipient varchar2(320);
  dummy pls_integer;
  admin_role varchar2(320);
  slash pls_integer;
  wfsession varchar2(240);

  uos   varchar2(320);
  uosid number;
  ros   varchar2(320);
  rosid number;
  oos   varchar2(320);
  oosid number;
begin
  if (nkey is null) then
    -- No nkey passed, means must be connected.  Get current user.
    Wfa_Sec.GetSession(username);

    -- Get recipient and original recipient of this notification
    begin
      select RECIPIENT_ROLE, ORIGINAL_RECIPIENT
      into recipient, orig_recipient
      from WF_NOTIFICATIONS WN
      where WN.NOTIFICATION_ID = nid;
    exception
      when no_data_found then
        Wf_Core.Token('NID', nid);
        Wf_Core.Raise('WFNTF_NID');
    end;

    -- Verify this notification was sent to this user
    -- Note that username could be the in the recipient role
    -- or in the original recipient role.
    begin
      usercolon := instr(username, ':');
      rolecolon := instr(recipient, ':');
      origcolon := instr(orig_recipient, ':');

      if (usercolon = 0) then
        -- very costly sql statement, return the first row we find.
        select ORIG_SYSTEM, ORIG_SYSTEM_ID
          into uos, uosid
          from WF_USERS
         where NAME = username
           and ORIG_SYSTEM not in ('HZ_PARTY','CUST_CONT')
           and rownum < 2;
      else
         uos   := substr(username, 1, usercolon-1);
         uosid := to_number(substr(username, usercolon+1));
      end if;

      if (rolecolon = 0) then
        -- when recipient = username, user is participate in the role of
        -- the same name, they will have the same orig system and orig
        -- system id.
        if (recipient = username) then
          ros   := uos;
          rosid := uosid;
        else
          Wf_Directory.GetRoleOrigSysInfo(recipient,ros,rosid);
        end if;
      else
        ros   := substr(recipient, 1, rolecolon-1);
        rosid := to_number(substr(recipient, rolecolon+1));
      end if;

      if (origcolon = 0) then
        -- similarly, don't bother to requery the orig_system and
        -- orig_system_id if original recipient matches recipient or username.
        if (orig_recipient = recipient) then
          oos   := ros;
          oosid := rosid;
        elsif (orig_recipient = username) then
          oos   := uos;
          oosid := uosid;
        else
          Wf_Directory.GetRoleOrigSysInfo(orig_recipient,oos,oosid);
        end if;
      else
        oos   := substr(orig_recipient, 1, origcolon-1);
        oosid := to_number(substr(orig_recipient, origcolon+1));
      end if;

      -- rewritten the sql from an or join to union all.
      -- reduced the query time from >25 sec to <0.5 sec.
      select 1
        into dummy
        from sys.dual
       where exists (
         select null
           from WF_USER_ROLES
          where USER_ORIG_SYSTEM = uos
            and USER_ORIG_SYSTEM_ID = uosid
            and USER_NAME = username
            and ROLE_ORIG_SYSTEM = ros
            and ROLE_ORIG_SYSTEM_ID = rosid
            and ROLE_NAME = recipient
        union all
         select null
           from WF_USER_ROLES
          where USER_ORIG_SYSTEM = uos
            and USER_ORIG_SYSTEM_ID = uosid
            and USER_NAME = username
            and ROLE_ORIG_SYSTEM = oos
            and ROLE_ORIG_SYSTEM_ID = oosid
            and ROLE_NAME = orig_recipient
        );

    exception
      when no_data_found then
        -- Check if current user has WF_ADMIN_ROLE privileges.
        -- If so, allow access anyway.
        admin_role := wf_core.translate('WF_ADMIN_ROLE');
        if (admin_role <> '*' and
            not Wf_Directory.IsPerformer(username, admin_role)) then
          Wf_Core.Token('USER', username);
          Wf_Core.Token('NID', to_char(nid));
          Wf_Core.Raise('WFNTF_ACCESS_USER');
        end if;
    end;
  else
    -- Nkey passed, means this must be disconnected (mailed html).
    -- Check the passed access key against the notification key.

    -- Construct wfsession-style access key as <nid>/<accesskey>.
    -- First strip <nid> from nkey if present (only for backward
    -- compatibility, current version only passes <accesskey>),
    -- then construct full key with current nid.
    -- Note: Key is reconstructed here instead of passing full
    -- <nid>/<accesskey> directly to check that the key being passed
    -- is really for this notification.
    slash := instr(nkey, '/');
    if (slash <> 0) then
      wfsession := to_char(nid)||'/'||substr(nkey, slash+1);
    else
      wfsession := to_char(nid)||'/'||nkey;
    end if;

    username := Wf_Notification.AccessCheck(wfsession);
    if (username is null) then
      wf_core.raise('WFNTF_ACCESS_KEY');
    end if;
  end if;

  return(username);

exception
  when others then
    wf_core.context('Wfa_Html', 'Authenticate', to_char(nid), nkey);
    raise;
end Authenticate;

--
-- DetailFrame
--   generate Detail notification screen
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
--   agent - web agent (OBSOLETE - for back compatibility only)
--   showforms - show form attributes
--
procedure DetailFrame(
  nid in varchar2,
  nkey in varchar2,
  agent in varchar2,
  showforms in varchar2)
as
begin
  -- bug 7314545
  null;
end DetailFrame;

--
-- ResponseFrame
--   generate response frame contents
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
--   agent - web agent (OBSOLETE - for back compatibility only)
--   showforms - show form attributes
--
procedure ResponseFrame(
  nid in varchar2,
  nkey in varchar2,
  agent in varchar2,
  showforms in varchar2)
as
begin
  -- bug 7314545
  null;
end ResponseFrame;

--
-- ForwardFrame
--   generate forward frame contents
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
--
procedure ForwardFrame(
  nid in varchar2,
  nkey in varchar2)
as
begin
  -- bug 7314545
  null;
end ForwardFrame;

--
-- AttributeInfo
--   Generate page with details about a response attribute
-- IN
--   nid - notification id
--   name - attribute name
--
procedure AttributeInfo(
  nid in varchar2,
  name in varchar2)
is
begin
  -- bug 7314545
  null;
end AttributeInfo;

--
-- RespFrameSize (RPIVATE)
--   Calculate size of response frame using heuristic
-- IN
--   nid - notification id
-- RETURNS
--   Size of response frame in pixels
--
function RespFrameSize(
  nid in number)
return number
is
  respcnt       pls_integer;
  longcnt       pls_integer;
  urlcnt        pls_integer;
  respsize      pls_integer;

begin
  -- Approximate size of response frame using heuristic:
  -- The rule of thumb being :
  -- 1. Each non-result response counts as 40 pixels
  --    + url and multiline fields count twice
  --    + 1 for result button line
  -- 2. Frame must be in range 100 - 250 pixels
  -- 3. If there is a url respond attributet then go for the max size

  -- Count of multiline response fields
  select count(1)
  into urlcnt
  from WF_MESSAGE_ATTRIBUTES MA,
       WF_NOTIFICATIONS N
  where N.NOTIFICATION_ID = nid
  and MA.MESSAGE_NAME = N.MESSAGE_NAME
  and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
  and MA.SUBTYPE = 'RESPOND'
  and MA.TYPE = 'URL';

  if (urlcnt = 1) then
    respsize := 250;
  else

    -- Count of all response fields
    select count(1)
    into respcnt
    from WF_NOTIFICATION_ATTRIBUTES NA,
         WF_MESSAGE_ATTRIBUTES MA,
         WF_NOTIFICATIONS N
    where N.NOTIFICATION_ID = nid
    and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
    and MA.MESSAGE_NAME = N.MESSAGE_NAME
    and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
    and MA.NAME = NA.NAME
    and MA.SUBTYPE = 'RESPOND'
    and MA.TYPE <> 'FORM'
    and MA.NAME <> 'RESULT';

    -- Count of multiline response fields
    select count(1)
    into longcnt
    from WF_NOTIFICATION_ATTRIBUTES NA,
         WF_MESSAGE_ATTRIBUTES MA,
         WF_NOTIFICATIONS N
    where N.NOTIFICATION_ID = nid
    and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
    and MA.MESSAGE_NAME = N.MESSAGE_NAME
    and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
    and MA.NAME = NA.NAME
    and MA.SUBTYPE = 'RESPOND'
    and MA.TYPE = 'VARCHAR2'
    and decode(MA.TYPE, 'VARCHAR2', nvl(to_number(MA.FORMAT), 2000), 0) > 80;


    respsize := (respcnt + longcnt + 1) * 40;
    if (respsize < 100) then
      respsize := 100;
    elsif (respsize > 250) then
      respsize := 250;
    end if;
  end if;

  return(respsize);

exception
  when others then
    wf_core.context('Wfa_Html', 'RespFrameSize', to_char(nid));
    raise;
end RespFrameSize;

--
-- Detail (PROCEDURE)
--   generate detail screen
-- IN
--   nid - notification id
-- NOTE
--   Detail is overloaded.
--   This version is used by the Web notifications page.
--
procedure Detail(
  nid in varchar2)
is
begin
  -- bug 7314545
  null;
end Detail;

--
-- Detail (FUNCTION)
--   return standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detail is overloaded.
--   This produces the version used by the mailer.
function Detail(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2)
return varchar2
as
  username  varchar2(320);
  status    varchar2(8);
  realname  varchar2(360);
  s0        varchar2(240);
  result    varchar2(32000);
  respsize  pls_integer;
  key       varchar2(255);
  n_sig_policy varchar2(100);
begin

  Wf_Mail.GetSignaturePolicy(nid, n_sig_policy);

  if (wf_mail.send_accesskey and n_sig_policy not in ('PSIG_ONLY')) then
     key := nkey;

  -- Authenticate the user has access
  username := Wfa_Html.Authenticate(nid, nkey);

  -- Get notification recipient and status
  Wf_Notification.GetInfo(nid, username, s0, s0, s0, s0, status);
  Wf_Directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  -- Set title
  result := htf.htmlOpen ||g_newLine;
  result := result || htf.headOpen||g_newLine;
  if (status = 'OPEN') then
    result := result ||
        htf.title(wf_core.translate('WFA_DTITLE')||' '||realname)||
                  g_newLine;
  else
    result := result ||
        htf.title(wf_core.translate('WFA_CDTITLE')||' '||realname)||
                  g_newLine;
  end if;

--tr: dont execute the help function
--it calls htp procs which causes session to hang
--  wfa_html.create_help_function('wf/links/det.htm?DETNOT');

  result := result || htf.headClose||g_newLine;

  -- Calculate size of response frame
  respsize := RespFrameSize(nid);

  -- Open frameset.
  -- NOTE: Do NOT set the focus here, because it is not supported on
  -- all platforms, and it is unknown at this point what browser will
  -- be used to display the html returned to the mailer.
  result := result||'<FRAMESET ROWS="*,'||to_char(respsize)||'" TITLE="' ||
          WF_CORE.Translate('WFA_DTITLE_TBAR') || '" LONGDESC="' ||
          agent ||
         'wfa_html.LongDesc?p_token=WFA_DTITLE_TBAR">'||
            g_newLine;
  result := result ||
      '<FRAME NAME="top" MARGINHEIGHT=10 MARGINWIDTH=10 ' ||
      'src="'||agent||'/wfa_html.DetailFrame?nid='||to_char(nid)||
      '&'||'nkey='||key||'" TITLE="' ||
          WF_CORE.Translate('WFA_DTITLE_TBAR') || '" LONGDESC="' ||
          agent ||
         'wfa_html.LongDesc?p_token=WFA_DTITLE_TBAR">'||g_newLine;
  result := result ||
    '<FRAME NAME="bottom" MARGINHEIGHT=10 MARGINWIDTH=10 ' ||
    'src="'||agent||'/wfa_html.ResponseFrame?nid='||to_char(nid)||
    '&'||'nkey='||key||'" TITLE="' ||
          WF_CORE.Translate('WFA_DTITLE_TBAR') || '" LONGDESC="' ||
          agent ||
         'wfa_html.LongDesc?p_token=WFA_DTITLE_TBAR">'||g_newLine;
  result := result || '</FRAMESET>'||g_newLine;
  result := result || htf.htmlClose;

  else
  -- Send_accesskey is set to N so we will generate a DirectLogin call.
  -- We do not need to authenticate the user, since the user will have
  -- to authenticate to view the notification.  After authentication,
  -- DirectLogin will redirect to the Detail (Web-interface) procedure so
  -- we will then confirm that the user logged in can also view the
  -- notification.
  key := NULL;

  result := htf.htmlOpen ||g_newLine;
  result := result || htf.headOpen||g_newLine;
  result := result ||
        htf.title(wf_core.translate('WFA_LOGIN_REQUEST'))||
                  g_newLine;
  result := result || htf.headClose||g_newLine;

  result := result||'<FRAMESET ROWS="100%, *">'||g_newLine;

  result := result ||
    '<FRAME NAME="DirectLogin" MARGINHEIGHT=10 MARGINWIDTH=10 NORESIZE' ||
    ' src="'||agent || '/' || wfa_sec.DirectLogin(nid) || '">'||g_newLine;
  result := result || '</FRAMESET>'||g_newLine;
  result := result || htf.htmlClose;
end if;

  return(result);
exception
  when others then
    wf_core.context('Wfa_Html', 'Detail', to_char(nid), nkey, agent);
    raise;
end Detail;

--
-- Detail2 (FUNCTION)
--   return standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detail is overloaded.
--   This produces the version used by the mailer.
function Detail2(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2)
return varchar2
as
  username  varchar2(320);
  status    varchar2(8);
  realname  varchar2(360);
  s0        varchar2(240);
  result    varchar2(32000);
  n_sig_policy varchar2(100);
  url       varchar2(4000);
  l_function_id number;
begin

  Wf_Mail.GetSignaturePolicy(nid, n_sig_policy);

  -- Authenticate the user has access
  username := Wfa_Html.Authenticate(nid, nkey);

  -- Get notification recipient and status
  Wf_Notification.GetInfo(nid, username, s0, s0, s0, s0, status);
  Wf_Directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  -- Set title
  result := htf.htmlOpen ||g_newLine;
  result := result || htf.headOpen||g_newLine;
  if (status = 'OPEN') then
    result := result ||
        htf.title(wf_core.translate('WFA_DTITLE')||' '||realname)||
                  g_newLine;
  else
    result := result ||
        htf.title(wf_core.translate('WFA_CDTITLE')||' '||realname)||
                  g_newLine;
  end if;

  result := result || htf.headClose||g_newLine;

  -- Open frameset.
  -- NOTE: Do NOT set the focus here, because it is not supported on
  -- all platforms, and it is unknown at this point what browser will
  -- be used to display the html returned to the mailer.
  if g_wfInstall='EMBEDDED' then
    result := result || htf.bodyOpen || g_newLine;
    result := result || '<SCRIPT LANGUAGE="JavaScript">' || g_newLine;
    result := result || '<!--' || g_newLine;

    url := wf_mail.Get_Ntf_Function_URL(nid => nid,
                                        n_key => nkey,
                                        n_sig_policy => n_sig_policy,
                                        n_override_agent => agent);

    result := result || 'self.location = '''||url||''';' || g_newLine;
    result := result || '//-->' || g_newLine || '</SCRIPT>' || g_newLine;
    result := result || htf.bodyClose || g_newLine || htf.htmlClose;
  else
    -- While the call is within standalone, continue to
    -- operate as before.
    if (agent is null) then
       result := wfa_html.detail(nid, nkey, g_webAgent);
    else
       result := wfa_html.detail(nid, nkey, agent);
    end if;
  end if;

  return(result);
exception
  when others then
    wf_core.context('Wfa_Html', 'Detail', to_char(nid), nkey, agent);
    raise;
end Detail2;


-- DetailLink
--   display standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detaillink called function Detail above.
--   This produces the version used by the mailer.
procedure DetailLink(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2)
is
begin
  -- bug 7314545
  null;
exception
  when others then
    wf_core.context('Wfa_Html', 'DetailLink', to_char(nid), nkey, agent);
    raise;
end DetailLink;


-- SubmitForward
--   Submit notification forward
-- IN
--   h_nid - notification id
--   forwardee - new recipient field
--   display_forwardee - display name for the new recipient
--   comments - forwarding comments field
--   fmode - reassign mode can be:
--           transfer - transferring responsibility
--           delegate - delegate responsibility
--   submit - submit forward button
--   cancel - cancel forward button
--   nkey - access key for mailed html
procedure SubmitForward(
  h_nid               in varchar2,
  forwardee           in varchar2,
  display_forwardee   in varchar2,
  comments            in varchar2,
  fmode               in varchar2,
  submit              in varchar2,
  cancel              in varchar2,
  nkey                in varchar2)
is
begin
  -- bug 7314545
  null;
end SubmitForward;

-- SubmitResponse
--   Submit notification response
-- IN
--   h_nid - notification id
--   h_fnames - array of field names
--   h_fvalues - array of field values
--   h_fdocnames - array of documentnames - a throwaway value from form
--   h_counter - number of fields passed in fnames and fvalues
--   submit - submit response button
--   forward - forward button
--   nkey - access key for mailed html
procedure SubmitResponse(
  h_nid        in varchar2,
  h_fnames     in Name_Array,
  h_fvalues    in Value_Array,
  h_fdocnames  in Value_Array,
  h_counter    in varchar2,
  submit       in varchar2,
  forward      in varchar2,
  nkey         in varchar2)
as
begin
  -- bug 7314545
  null;
end SubmitResponse;

-- GotoURL
--   GotoURL let you open an url in a specify place.  This is very useful
--   when you need to go from a child frame to the full browser window,
--   for instnace.
--   So far, this is the only way to break away from a child frame.
-- IN
--   url - Fully qualified universal resouce location
--   location - Where you want to open it.  Samples of values are
--              _blank  - unnamed window
--              _self   - the current frame
--              _parent - the parent frame of the current one
--              _top    - the full Web browser window
--              "myWin" - name of the new window
--
procedure GotoURL(
  url in varchar2,
  location in varchar2,
  attributes in varchar2
)
is
begin
  -- bug 7314545
  null;
end GotoURL;

-- SubmitSelectedResponse
--   Submit selected notification response
-- IN
--   nids - notification ids
--   close - submit response button
--   forward - forward button
--   showto - display the TO column
--   nkey - access key for mailed html
procedure SubmitSelectedResponse(
  nids         in Name_Array,
  close        in varchar2,
  forward      in varchar2,
  showto       in varchar2,
  nkey         in varchar2)
as
begin
  null;
end SubmitSelectedResponse;


-- ForwardNids
--   Forward for each notification ids
--   Forward can be Delegating or Transferring
--   Delegating is for notification only.
--   Transferring is reassign the whole responsibility to other
-- IN
--   h_nids -    hidden notification ids
--   forwardee - forwardee role specified
--   comments -  comments included
--   fmode -     reassign mode can be:
--               transfer -  transferring responsibility
--               delegate -  delegate responsibility
--   cancel -    cancel button
procedure ForwardNids(
  h_nids               in Name_Array,
  forwardee            in varchar2,
  display_forwardee    in varchar2,
  comments             in varchar2,
  fmode                in varchar2,
  submit               in varchar2,
  cancel               in varchar2,
  nkey                 in varchar2)
as
  username   varchar2(320);
  x          pls_integer;
  nid        pls_integer;
  l_forwardee varchar2(320);

begin
  -- There is always a dummy nid passed in.  We will handle it here.
  -- Make sure subsequent index start at 2 not 1.
  if (to_number(h_nids.count) = 1) then
    wf_core.raise('WFNTF_NO_SELECT');
  end if;

  -- Fully resolve forwardee name
  l_forwardee := forwardee;
  wfa_html.validate_display_name (display_forwardee, l_forwardee);

  -- Otherwise, for each notification, delegate or transfer
  for x in 2..h_nids.count loop
    -- Authenticate user
    nid := to_number(h_nids(x));
    username := Wfa_Html.Authenticate(nid, nkey);

    -- Delegating to forwardee with comments
    if (fmode = 'DELEGATE') then
      if (comments is not null) then
-- ### implement this in next release
--      Wf_Notification.Forward(nid, upper(l_forwardee), comments, username);
        Wf_Notification.Forward(nid, upper(l_forwardee), comments);
      else
-- ### implement this in next release
--      Wf_Notification.Forward(nid, upper(l_forwardee), '', username);
        Wf_Notification.Forward(nid, upper(l_forwardee));
      end if;
    elsif (fmode = 'TRANSFER') then
      -- Transferring to fowardee with comments

      if (comments is not null) then
-- ### implement this in next release
--      Wf_Notification.Transfer(nid, upper(l_forwardee), comments, username);
        Wf_Notification.Transfer(nid, upper(l_forwardee), comments);
      else
-- ### implement this in next release
--      Wf_Notification.Transfer(nid, upper(l_forwardee), '', username);
        Wf_Notification.Transfer(nid, upper(l_forwardee));
      end if;
    end if;
  end loop;

  -- Back to the worklist
  <<worklist>>
  Wfa_Html.WorkList;
  return;
  exception
    when others then
      rollback;
      wfa_html.Error;
      return;
end ForwardNids;

/*===========================================================================
  PROCEDURE NAME:       create_help_function

  DESCRIPTION:
                        Create the java script function to support the Help
                        Icon from the header

   Note:  The help file parameter must include the subdirectory under
          /OA_DOC/lang/ and the actual file name which will either be
          wf or wfnew.
      ie  p_help_file = 'wf/notif16.htm'
          p_help_file = 'wfnew/wfnew48.htm'
============================================================================*/
procedure create_help_function (

 p_help_file IN VARCHAR2

) IS

install_type VARCHAR2(80);
l_help_target VARCHAR2(240) := NULL;
l_lang       VARCHAR2(2000);
help_prefix  VARCHAR2(2000);

BEGIN

  BEGIN

  /*
  ** Get the language environment variable
  ** for this user.
  */
  SELECT USERENV('LANG')
  INTO l_lang
  FROM DUAL;

  EXCEPTION
  WHEN OTHERS THEN
     l_lang := 'US';
  END;

  /*
  ** Check the installation type.  If it is workflow standalone
  ** then use the file prefix method of getting to the help
  ** content.  Otherwise use the fnd function method to get and
  ** display the help content.
  */
  install_type := wf_core.translate('WF_INSTALL');

  if (install_type = 'STANDALONE') THEN

     help_prefix := '/OA_DOC/';

     htp.p('<!-- Copyright ' || '&' || '#169; 1997 Oracle Corporation, All rights reserved. -->');
     htp.p('<SCRIPT LANGUAGE="JavaScript">
     <!-- hide the script''s contents from feeble browsers');

     htp.p('function help_window(){
        help_win = window.open('||''''||help_prefix||
                'US/' || p_help_file ||''''||
            ', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500");
        help_win = window.open('||''''||help_prefix||
               'US/' || p_help_file ||''''||
            ', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500")
}
');

     htp.p('<!-- done hiding from old browsers --></SCRIPT>');

     htp.p('<NOSCRIPT>');
     htp.p(WF_CORE.Translate('WFA_NOSCRIPT'));
     htp.p('</NOSCRIPT>');

  else

     /*
     ** If you're going against apps then strip out everything
     ** except the target name
     */
     IF (INSTR(p_help_file, '?') > 0) THEN

         l_help_target := substrb(p_help_file, INSTR(p_help_file, '?') + 1);

     ELSE

         l_help_target := p_help_file;

     END IF;

     wfa_sec.create_help_syntax (l_help_target, l_lang);

  end if;

exception
  when others then
    Wf_Core.Context('wfa_html', 'create_help_function',
       p_help_file);
    wfa_html.Error;

END create_help_function;

/*===========================================================================
  FUNCTION NAME:        conv_special_url_chars

  DESCRIPTION:
                        Convert all of the ASCII special characters that are
                        disallowed as a part of a URL.  The encoding requires
                        that we convert the special characters to HEX for
                        any characters in a URL string that is built
                        manually outside a form get/post.
                        This API now also converts multibyte characters
                        into their HEX equivalent.

  NOTE:                 This api allows double-encoding.

============================================================================*/
FUNCTION conv_special_url_chars (p_url_token IN VARCHAR2) RETURN VARCHAR2
IS
 c_unreserved constant varchar2(72) :=
   '-_.!*''()~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
 c_reserved    constant varchar2(72) := '%">^{}<[]`|/#?&=$:;+';
 l_tmp         varchar2(32767) := '';
 l_onechar     varchar2(4);
 l_byte_len    integer;
 i             integer;
 l_str         varchar2(48);

BEGIN
 if p_url_token is NULL then
    return NULL;
 end if;
 for i in 1 .. length(p_url_token) loop
   l_onechar := substr(p_url_token,i,1);
   --Extracting out each character to be replaced.
   if instr(c_unreserved, l_onechar) > 0 then
     --Check if  it is part of the ASCII unreserved
     --excluded from encoding just append to the URL
     --string
     l_tmp := l_tmp || l_onechar;

   elsif l_onechar = ' ' then
     --Space encoded as '%20'
     l_tmp := l_tmp || '%20';

   elsif instr(c_reserved,l_onechar) >0 then
     --If it is any of the reserved characters in ascii
     --replace with equivalent HEX
     l_onechar := REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(l_onechar,
                  '%','%25'),
                  ' ','%20'),
                  '"','%22'),
                  '>','%3E'),
                  '^','%5E'),
                  '{','%7B'),
                  '}','%7D'),
                  '<','%3C'),
                  '[','%5B'),
                  ']','%5D'),
                  '`','%60'),
                  '|','%7C'),
                  '/','%2F'),
                  '#','%23'),
                  '?','%3F'),
                  '&','%26'),
                  '=','%3D'),
                  '$','%24'),
                  ':','%3A'),
                  ';','%3B'),
                  '+','%2B'),
                  '''','%27');
     l_tmp := l_tmp || l_onechar;
   else
     --For multibyte
     -- 1. Obtain length for each character
     -- 2. ascii(l_char)decimal representation in the database
     --    character set
     -- 3. Change it to the format model :
     --    to_char(ascii(l_onechar),'FM0X')
     -- 4. Add to the already encoded string.
     --    characters
     l_byte_len := lengthb(l_onechar);
     if l_byte_len = 1 then
       l_tmp := l_tmp || '%' ||
        substr(to_char(ascii(l_onechar),'FM0X'),1,2);
     elsif l_byte_len = 2 then
       l_str := to_char(ascii(l_onechar),'FM0XXX');
       l_tmp := l_tmp
            || '%' || substr(l_str,1,2)
            || '%' || substr(l_str,3,2);
     elsif l_byte_len = 3 then
       l_str := to_char(ascii(l_onechar),'FM0XXXXX');
       l_tmp := l_tmp
                || '%' || substr(l_str,1,2)
                || '%' || substr(l_str,3,2)
                || '%' || substr(l_str,5,2);
     elsif l_byte_len = 4 then
       l_str := to_char(ascii(l_onechar),'FM0XXXXXXX');
       l_tmp := l_tmp
                || '%' || substr(l_str,1,2)
                || '%' || substr(l_str,3,2)
                || '%' || substr(l_str,5,2)
                || '%' || substr(l_str,7,2);
     else            -- maximum precision
       wf_core.raise('WFENG_PRECESSION_EXCEED');
     end if;
   end if;
 end loop;
 return l_tmp;
exception
  when others then
    Wf_Core.Context('wfa_html', 'conv_special_url_chars',
       p_url_token);
    wfa_html.Error;
END conv_special_url_chars;

/*===========================================================================
  FUNCTION NAME:        encode_url (PRIVATE)

  DESCRIPTION:
                        Convert all of the ASCII special characters that are
                        disallowed as a part of a URL.  The encoding requires
                        that we convert the special characters to HEX for
                        any characters in a URL string that is built
                        manually outside a form get/post.
                        This API now also converts multibyte characters
                        into their HEX equivalent.

                        URL encoding was documented in RFC 1738.
                        We have put some "unsafe" characters in the encode
                        list for purpose of encoding them.
                        We took "~" out from this list, because some downstream
                        consumer (ICX) was looking for "~".

  NOTE:                 This private api does not allow double-encoding.
============================================================================*/
FUNCTION encode_url (p_url_token IN VARCHAR2) RETURN VARCHAR2
IS
 c_noencode    constant varchar2(72) :=
   '-_.!*''()~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
 c_encode      constant varchar2(72) := '">^{}<[]`|/#?&=$:;+';
 c_hex         constant varchar2(72) := 'ABCDEFabcdef0123456789';
 l_tmp         varchar2(32767);
 l_onechar     varchar2(4);
 l_byte_len    integer;
 i             integer;
 l_str         varchar2(48);

BEGIN
 if p_url_token is NULL then
    return NULL;
 end if;
 for i in 1 .. length(p_url_token) loop
   l_onechar := substr(p_url_token,i,1);
   --Extracting out each character to be replaced.
   if instr(c_noencode, l_onechar) > 0 then
     --If it is part of the ASCII excluded from encoding,
     --just append to the URL string
     l_tmp := l_tmp || l_onechar;

   elsif l_onechar = ' ' then
     --Space encoded as '%20'
     l_tmp := l_tmp || '%20';

   elsif l_onechar = '%' then
     --Do not reencode if it has already been encoded
     --Check next two characters to see if they belong to hex number
     if (instr(c_hex, substr(p_url_token,i+1,1)) > 0 and
         instr(c_hex, substr(p_url_token,i+2,1)) > 0) then
       l_tmp := l_tmp || '%';
     else
       l_tmp := l_tmp || '%25';
     end if;

   elsif instr(c_encode,l_onechar) >0 then
     --If it is any of the to be encoded characters in ascii
     --replace with equivalent HEX
     l_onechar := REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(
                  REPLACE(l_onechar,
                  '"','%22'),
                  '>','%3E'),
                  '^','%5E'),
                  '{','%7B'),
                  '}','%7D'),
                  '<','%3C'),
                  '[','%5B'),
                  ']','%5D'),
                  '`','%60'),
                  '|','%7C'),
                  '/','%2F'),
                  '#','%23'),
                  '?','%3F'),
                  '&','%26'),
                  '=','%3D'),
                  '$','%24'),
                  ':','%3A'),
                  ';','%3B'),
                  '+','%2B'),
                  '''','%27');
     l_tmp := l_tmp || l_onechar;
   else
     --For multibyte
     -- 1. Obtain length for each character
     -- 2. ascii(l_char)decimal representation in the database
     --    character set
     -- 3. Change it to the format model :
     --    to_char(ascii(l_onechar),'FM0X')
     -- 4. Add to the already encoded string.
     --    characters
     l_byte_len := lengthb(l_onechar);
     if l_byte_len = 1 then
       l_tmp := l_tmp || '%' ||
        substr(to_char(ascii(l_onechar),'FM0X'),1,2);
     elsif l_byte_len = 2 then
       l_str := to_char(ascii(l_onechar),'FM0XXX');
       l_tmp := l_tmp
            || '%' || substr(l_str,1,2)
            || '%' || substr(l_str,3,2);
     elsif l_byte_len = 3 then
       l_str := to_char(ascii(l_onechar),'FM0XXXXX');
       l_tmp := l_tmp
                || '%' || substr(l_str,1,2)
                || '%' || substr(l_str,3,2)
                || '%' || substr(l_str,5,2);
     elsif l_byte_len = 4 then
       l_str := to_char(ascii(l_onechar),'FM0XXXXXXX');
       l_tmp := l_tmp
                || '%' || substr(l_str,1,2)
                || '%' || substr(l_str,3,2)
                || '%' || substr(l_str,5,2)
                || '%' || substr(l_str,7,2);
     else            -- maximum precision
       wf_core.raise('WFENG_PRECESSION_EXCEED');
     end if;
   end if;
 end loop;
 return l_tmp;
exception
  when others then
    Wf_Core.Context('wfa_html', 'encode_url',
       p_url_token);
    wfa_html.Error;
END encode_url;

--
-- User_LOV
--   Create the data for the User List of Values
--   NOTE: This is not used by APPS.  Otherwise, we will have performance
--         problem with this query against wf_roles.
--
procedure User_LOV (p_titles_only     IN VARCHAR2,
                    p_find_criteria IN VARCHAR2)

IS
BEGIN
  -- bug 7314545
  null;
end User_Lov;

procedure logout is
begin
  -- bug 7314545
  null;
end logout;

procedure Home(message in varchar2)
is
begin
  -- bug 7314545
  null;
end home;

procedure Header
is
begin
  -- bug 7314545
  null;
end;


procedure home_float
is
begin
  -- bug 7314545
  null;
end home_float;

-- Homemenu
-- Prints the menu for the home page.
-- May also be called direct to print a regular page.

procedure Homemenu(message in varchar2,
               origin  in varchar2)
is
begin
  -- bug 7314545
  null;
end Homemenu;

procedure create_reg_button (
when_pressed_url  IN VARCHAR2,
onmouseover       IN VARCHAR2,
icon_top          IN VARCHAR2,
icon_name         IN VARCHAR2,
show_text         IN VARCHAR2)
IS
BEGIN
  -- bug 7314545
  null;
end create_reg_button;

-- show_plsql_doc
--   Show the content of a plsql document in a browser window
--   Called from the related documents function

procedure show_plsql_doc (
  nid in number,
  aname in varchar2,
  nkey in varchar2)
is

username varchar2(320);

clob_loc   clob;
blob_loc   blob;
clob_id    number;
clob_chunk number := 0;
doctext    varchar2(32000);
end_of_text boolean :=FALSE;
attr_name varchar2(30);

slash           pls_integer;
wfsession       varchar2(240);

doctype varchar2(1000);
lobsize number;
amount number;

l_enpos    pls_integer;
l_copos    pls_integer;

l_encoding varchar2(100);
l_filename  varchar2(255);
l_extension varchar2(50);
l_mime_type varchar2(255);

begin

  -- Verify if user is admin or can access this notification
  username := wfa_html.authenticate(nid,nkey);

  username := upper(username);

  -- note that GetAttrDoc will not translate for PLSQLCLOB
  doctext := wf_notification.getattrdoc(nid, aname,wf_notification.doc_html);

  -- if the attribute wasn't translated then try to translate for plsqlclobs.
  if doctext = '&'||aname then
    dbms_lob.createTemporary(clob_loc, false, dbms_lob.call);
    Wf_Notification.GetAttrCLOB(nid, aname, wf_notification.doc_html,
                                clob_loc, doctype, attr_name);
    if (doctype is not null) then
      Wf_Mail_Util.ParseContentType(doctype, l_mime_type, l_filename, l_extension, l_encoding);
    end if;
    -- We have the document. Now determine the output method. HTML documents can be output as
    -- they are. Binary documents can only be downloaded
    if l_mime_type in (wf_notification.doc_text, wf_notification.doc_html) then
       -- HTML or text document.
       htp.htmlOpen;
       htp.headOpen;
       htp.p('<BASE TARGET="_top">');
       htp.title(wf_core.translate('WFITD_ATTR_TYPE_DOCUMENT'));
       wfa_html.create_help_function('wfnew/wfnew52.htm#nrr');
       htp.headClose;
       wfa_sec.Header(FALSE, '',wf_core.translate('WFITD_ATTR_TYPE_DOCUMENT'),
                      TRUE);
       htp.br;

       lobsize := dbms_lob.getlength(clob_loc);
       amount := 32000;
       wf_notification.clob_chunk := 0;
       while not (end_of_text) loop
          wf_notification.readattrclob(nid, aname, doctext, end_of_text);
          htp.prn(doctext);
       end loop;
       wfa_sec.Footer;
       htp.htmlClose;
    elsif attr_name is not null then
       -- BINARY Document
       if (l_encoding is not null) then
          -- Decode base64 encoded content
          if (upper(trim(l_encoding)) = 'BASE64') then
             dbms_lob.createTemporary(blob_loc, FALSE, dbms_lob.call);

             wf_mail_util.decodeBLOB(clob_loc, blob_loc);
             -- owa_util.mime_header(doctype, FALSE);
             -- Write appropriate headers before downloading the document
             if (l_filename is null or l_filename = '') then
               l_filename := aname || '.' || l_extension;
             end if;
             htp.p('Content-type: '||l_mime_type);
             htp.p('Content-Disposition: attachment; filename="'||l_filename||'"');
             htp.p('Content-length: ' || dbms_lob.getlength(blob_loc));
             htp.p('');
             -- owa_util.http_header_close;

             wpg_docload.download_file(blob_loc);
             dbms_lob.freeTemporary(blob_loc);
          end if;
       else
          -- This provides limited binary document support. It assumes that the document in
          -- stored as raw in varchar.
          owa_util.mime_header(l_mime_type, TRUE);
          lobsize := dbms_lob.getlength(clob_loc);
          amount := 32000;
          wf_notification.clob_chunk := 0;
          while not (end_of_text) loop
             wf_notification.readattrclob(nid, aname, doctext, end_of_text);
             htp.p(doctext);
          end loop;
       end if;
    else
       -- attr_name is null try for a PLSQLBLOB document
       dbms_lob.createTemporary(blob_loc, false, dbms_lob.call);
       Wf_Notification.GetAttrBLOB(nid, aname, wf_notification.doc_html,
                                   blob_loc, doctype, attr_name);
       if (doctype is not null) then
         Wf_Mail_Util.ParseContentType(doctype, l_mime_type, l_filename, l_extension, l_encoding);
       end if;
       if (l_filename is null or l_filename = '') then
         l_filename := aname || '.' || l_extension;
       end if;
       -- owa_util.mime_header(doctype, FALSE);
       htp.p('Content-type: '||l_mime_type);
       htp.p('Content-Disposition: attachment; filename="'||l_filename||'"');
       htp.p('Content-length: ' || dbms_lob.getlength(blob_loc));
       htp.p('');
       -- owa_util.http_header_close;

       wpg_docload.download_file(blob_loc);
       dbms_lob.freeTemporary(blob_loc);
    end if;

  else
     -- Set page title
     htp.htmlOpen;
     htp.headOpen;
     htp.title(wf_core.translate('WFITD_ATTR_TYPE_DOCUMENT'));
     wfa_html.create_help_function('wfnew/wfnew52.htm#nrr');
     htp.headClose;
     wfa_sec.Header(FALSE, '',wf_core.translate('WFITD_ATTR_TYPE_DOCUMENT'),
                    TRUE);
     htp.br;

     htp.p (doctext);

     wfa_sec.Footer;
     htp.htmlClose;
  end if;

exception
  when others then
    wf_core.context('Wfa_Html','show_plsql_doc',wf_core.substitutespecialchars(nid),
                   wf_core.substitutespecialchars(aname));
    wfa_html.Error;
end show_plsql_doc;

-- base_url
-- Get the base url for the current browser where you have launched the
-- login for Workflow
function base_url  (get_from_resources BOOLEAN)
return varchar2 IS

l_base_url   VARCHAR2(2000) := NULL;

BEGIN

    BEGIN

    IF (get_from_resources = FALSE) THEN

       -- Need to strip off trailing / to match wf_web_agent format
       l_base_url  := SUBSTR(RTRIM(owa_util.get_owa_service_path), 1,
                          LENGTH(RTRIM(owa_util.get_owa_service_path)) - 1);

    ELSE

       l_base_url := wf_core.translate ('WF_WEB_AGENT');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN

       l_base_url := wf_core.translate ('WF_WEB_AGENT');

    END;

    return (l_base_url);

exception
  when others then
    wf_core.context('Wfa_Html','base_url');
    wfa_html.Error;
end base_url;

--
-- wf_user_val
--   Create the lov content for our user lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure  wf_user_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number)


IS

CURSOR c_user_lov (c_find_criteria IN VARCHAR2) IS
SELECT
 name,
 display_name
FROM   wf_role_lov_vl
where  status <> 'INACTIVE'
and   (UPPER(display_name) LIKE UPPER(c_find_criteria)||'%')
order by display_name;

-- Added additional where condition "status <> 'INACTIVE' so only ACTIVE
-- roles display

-- CURSOR c_user_display_value (c_name IN VARCHAR2) IS
-- select name, display_name
-- from   wf_roles
-- where  name = c_name;

ii           NUMBER := 0;
nn           NUMBER := 0;
l_total_rows NUMBER := 0;
l_id         NUMBER;
l_name       VARCHAR2 (320);  -- enlarged from 30 to match db definition
l_display_name VARCHAR2 (360); -- enlarged from 80 to match db definition
l_result     NUMBER := 1;  -- This is the return value for each mode

colon        NUMBER;

role_info_tbl wf_directory.wf_local_roles_tbl_type;

BEGIN

if (p_mode = 'LOV') then

   /*
   ** Need to get a count on the number of rows that will meet the
   ** criteria before actually executing the fetch to show the user
   ** how many matches are available.
   */
   select count(*)
   into   l_total_rows
   FROM   wf_role_lov_vl
   where  status <> 'INACTIVE'
   and   (UPPER(display_name) LIKE UPPER(p_display_value)||'%');

   wf_lov.g_define_rec.total_rows := l_total_rows;

   wf_lov.g_define_rec.add_attr1_title := wf_core.translate ('WFITD_INTERNAL_NAME');

   open c_user_lov (p_display_value);

   LOOP

     FETCH c_user_lov INTO l_name, l_display_name;

     EXIT WHEN c_user_lov%NOTFOUND OR nn >= p_max_rows;

     ii := ii + 1;

     IF (ii >= p_start_row) THEN

        nn := nn + 1;

        wf_lov.g_value_tbl(nn).hidden_key      := l_name;
        wf_lov.g_value_tbl(nn).display_value   := l_display_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_name;

     END IF;

   END LOOP;

   l_result := 1;

elsif (p_mode = 'GET_DISPLAY_VAL') THEN

   Wf_Directory.GetRoleInfo2(p_hidden_value,role_info_tbl);
   l_name         := role_info_tbl(1).name;
   l_display_name := role_info_tbl(1).display_name;
   p_display_value:= l_name;

   l_result := 1;

elsif (p_mode = 'VALIDATE') THEN

   /*
   ** If mode = VALIDATE then see how many rows match the criteria
   ** If its 0 then thats not good.  Raise an error and tell them to use LOV
   ** If its 1 then thats great.
   ** If its more than 1 then check to see if they used the LOV to select
   ** the value
   */
   open c_user_lov (p_display_value);

   LOOP

     FETCH c_user_lov INTO l_name, l_display_name;

     EXIT WHEN c_user_lov%NOTFOUND OR ii = 2;

     ii := ii + 1;

     p_hidden_value := l_name;

   END LOOP;

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

     -- copy logic from wf_directory.getroleinfo2
     colon := instr(p_display_value,':');
     if (colon = 0) then
       select count(*)
         into ii
         from WF_ROLES
        where NAME = p_display_value
          and ORIG_SYSTEM not in ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                                  'HZ_GROUP','CUST_CONT');
     else
       select count(*)
         into ii
         from WF_ROLES
        where NAME = p_display_value
          and ORIG_SYSTEM    = substr(p_display_value, 1, colon-1)
          and ORIG_SYSTEM_ID = substr(p_display_value, colon+1);
     end if;

   END IF;

   l_result := ii;

end if;

p_result := l_result;

exception
  when others then
    rollback;
    wf_core.context('Wfa_Html', 'wf_user_val');
    raise;
end wf_user_val;


function replace_onMouseOver_quotes(p_string in varchar2) return varchar2 is

temp_string varchar2(2000);
c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

begin

-- replace single quotes
temp_string := replace(p_string,'''','\''');

-- replace double quotes
if (instr(c_browser, 'MSIE') <> 0) then
    temp_string := replace(temp_string,'"','\''');
else
    temp_string := replace(temp_string,'"','`&quot;');
end if;

-- check for double escapes
temp_string := replace(temp_string,'\\','\');

return temp_string;

end replace_onMouseOver_quotes;

procedure validate_display_name (
p_display_name in varchar2,
p_user_name    in out nocopy varchar2) IS

l_colon         NUMBER := 0;
l_names_count   NUMBER := 0;
l_name          VARCHAR2(320);
l_upper_name    VARCHAR2(360);
l_orig_system_id NUMBER;
l_get_role      BOOLEAN := TRUE;

role_info_tbl wf_directory.wf_local_roles_tbl_type;

BEGIN

   /*
   ** Make sure to blank out the internal name if the user originally
   ** used the LOV to select the name and then blanked out the display
   ** name then make sure here to blank out the insternal name and return
   */
   if (p_display_name is null) then

      p_user_name := NULL;
      return;

   end if;

   /*
   ** Bug# 2236250 validating the display name to contain a valid number
   ** after the colon to be used as a internal name for the role
   */
   l_colon := instr(p_display_name, ':');
   if (l_colon > 0) then
      begin
         l_orig_system_id := to_number(substr(p_display_name, l_colon+1));
      exception
         when invalid_number then
             l_get_role := FALSE;
         when others then
             raise;
      end;
      l_colon := 0;
   end if;

   /*
   ** First look first for internal name to see if you find a match.  If
   ** there are duplicate internal names that match the criteria then
   ** there is a problem with directory services but what can you do.  Go
   ** ahead and pick the first name so you return something
   **
   ** Bug# 2236250 calling Wf_Directory.GetRoleInfo2 only if the value
   ** after ':' is numeric.
   */
   if (l_get_role) then
      l_upper_name := upper(p_display_name);
      Wf_Directory.GetRoleInfo2(l_upper_name,role_info_tbl);
      l_name := role_info_tbl(1).name;
   end if;

   /*
   ** If you found a match on internal name then set the p_user_name
   ** accordingly.
   */
   if (l_name IS NOT NULL) then

      p_user_name := l_name;

   /*
   ** If there was no match on internal name then check for a display
   ** name
   */
   else

      /*
      ** Check out how many names match the display name
      */
      select count(1)
      into   l_names_count
      from   wf_role_lov_vl
      where  display_name = p_display_name;

      /*
      ** If there are no matches for the display name then raise an error
      */
      if (l_names_count = 0) then

         -- Not displayed or internal role name, error
         wf_core.token('ROLE', p_display_name);
         wf_core.raise('WFNTF_ROLE');

      /*
      ** If there is just one match then get the internal name
      ** and assign it.
      */
      elsif (l_names_count = 1) then

         select name
         into   l_name
         from   wf_role_lov_vl
         where  display_name = p_display_name;

         p_user_name  := l_name;

      /*
      ** If there is more than one match then see if the user
      ** used the lov to select the name in which case the combination
      ** of the display name and the user name should be unique
      */
      else

        -- copy logic from wf_directory.getroleinfo2
        l_colon := instr(p_user_name,':');

        if (l_colon = 0) then
          select count(1)
            into l_names_count
            from WF_ROLES
           where NAME = p_user_name
             and ORIG_SYSTEM not in ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                                     'HZ_GROUP','CUST_CONT')
             and DISPLAY_NAME = p_display_name;
        else
        /*
        ** Bug# 2236250 validate if the value after ':' is number
        ** before using it in the query
        */
          begin
             l_orig_system_id := to_number(substr(p_user_name, l_colon+1));
          exception
             when invalid_number then
                wf_core.raise('WFNTF_ORIGSYSTEMID');
             when others then
                raise;
          end;
          select count(1)
            into l_names_count
            from WF_ROLES
           where NAME = p_user_name
             and ORIG_SYSTEM    = substr(p_user_name, 1, l_colon-1)
             and ORIG_SYSTEM_ID = l_orig_system_id
             and DISPLAY_NAME = p_display_name;
        end if;

        if (l_names_count <> 1) then
          wf_core.token('ROLE', p_display_name);
          wf_core.raise('WFNTF_UNIQUE_ROLE');
        end if;

      end if;

   end if;

exception
  when others then
    wf_core.context('Wfa_Html', 'validate_display_name', p_display_name,
      p_user_name);
    raise;
end validate_display_name;

-- LongDesc
--  Displays an html page with the token message.  This is called from
--  frames for the LONGDESC attribute.
procedure LongDesc (p_token       in varchar2)
as
BEGIN
    htp.htmlOpen;
    htp.headOpen;
    htp.title(wf_core.translate('LONG_DESC'));
    htp.headClose;

      begin
        wfa_sec.Header(background_only=>TRUE);
      exception
        when others then
          htp.bodyOpen;
      end;

    htp.p(WF_CORE.Translate(UPPER(p_token)));

    wfa_sec.Footer;
    htp.htmlClose;

END LongDesc;

end WFA_HTML;

/
