--------------------------------------------------------
--  DDL for Package Body ORACLEMYPAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLEMYPAGE" as
/* $Header: ICXSEMB.pls 120.0 2005/10/07 12:18:50 gjimenez noship $ */

procedure timer(message VARCHAR2) is --defaulted to NULL, removed for GSCC
l_hsecs pls_integer;
begin
  select HSECS into l_hsecs from V$TIMER;
  htp.p('DEBUG ('||l_hsecs||') '||message);htp.nl;
htp.p('Debug');
end;

function openHTML return varchar2 is

l_HTML_tag varchar2(240);
begin

  if icx_sec.g_language_code in ('F')
  then
    l_HTML_tag := '<HTML DIR="RTL">';
    OracleMyPage.g_start := 'RIGHT';
    OracleMyPage.g_end := 'LEFT';
  else
    l_HTML_tag := '<HTML DIR="LTR">';
    OracleMyPage.g_start := 'LEFT';
    OracleMyPage.g_end := 'RIGHT';
  end if;

  return l_HTML_tag;
end;

function METAtag return varchar2 is

begin
  return '<META HTTP-EQUIV="Content-Type" CONTENT="text/html">';
end;

function CSStag return varchar2 is

begin
  return '<LINK REL="STYLESHEET" HREF="/OA_HTML/US/ICXSTYLE.css" TYPE="text/css">';
end;

procedure Regions is

l_start                 number;
l_timer                 number;
l_hsecs                 number;

l_page_id               pls_integer;
l_refresh_rate          pls_integer;

l_known_as              varchar2(240);
l_user_name             varchar2(100);
l_customize_page        varchar2(340);
l_date                  varchar2(100);
l_title                 varchar2(340);

l_stmt_str              varchar2(2000);

cursor left is
select b.DISPLAY_SEQUENCE,b.PLUG_ID,b.RESPONSIBILITY_ID,
       b.RESPONSIBILITY_APPLICATION_ID,b.SECURITY_GROUP_ID,
       b.MENU_ID,b.ENTRY_SEQUENCE,nvl(b.DISPLAY_NAME,c.PROMPT) prompt,
       c.DESCRIPTION,a.WEB_HTML_CALL
from   fnd_responsibility e,
       FND_USER_RESP_GROUPS d,
       FND_FORM_FUNCTIONS a,
       FND_MENU_ENTRIES_VL c,
       ICX_PAGE_PLUGS b
where  b.PAGE_ID = l_page_id
and   b.MENU_ID = c.MENU_ID
and    b.ENTRY_SEQUENCE = c.ENTRY_SEQUENCE
and    c.FUNCTION_ID = a.FUNCTION_ID
and    a.type in ('WWL','WWLG')
and    b.RESPONSIBILITY_ID = d.RESPONSIBILITY_ID
and    d.user_id = icx_sec.g_user_id
and    d.start_date <= sysdate
and    (d.end_date is null or d.end_date > sysdate)
and    b.RESPONSIBILITY_ID = e.RESPONSIBILITY_ID
and    e.start_date <= sysdate
and    (e.end_date is null or e.end_date > sysdate)
union all
select b.DISPLAY_SEQUENCE,b.PLUG_ID,b.RESPONSIBILITY_ID,
       b.RESPONSIBILITY_APPLICATION_ID,b.SECURITY_GROUP_ID,
       b.MENU_ID,b.ENTRY_SEQUENCE,
       nvl(b.DISPLAY_NAME,a.USER_FUNCTION_NAME) prompt,
       a.DESCRIPTION,a.WEB_HTML_CALL
from   FND_FORM_FUNCTIONS_VL a,
       ICX_PAGE_PLUGS b
where  b.PAGE_ID = l_page_id
and    b.MENU_ID = -1
and    b.ENTRY_SEQUENCE = a.FUNCTION_ID
and    a.type in ('WWL','WWLG')
order by 1;

cursor right is
select b.DISPLAY_SEQUENCE,b.PLUG_ID,b.RESPONSIBILITY_ID,
       b.RESPONSIBILITY_APPLICATION_ID,b.SECURITY_GROUP_ID,
       b.MENU_ID,b.ENTRY_SEQUENCE,nvl(b.DISPLAY_NAME,c.PROMPT) prompt,
       c.DESCRIPTION,a.WEB_HTML_CALL
from   fnd_responsibility e,
       FND_USER_RESP_GROUPS d,
       FND_FORM_FUNCTIONS a,
       FND_MENU_ENTRIES_VL c,
       ICX_PAGE_PLUGS b
where  b.PAGE_ID = l_page_id
and    b.MENU_ID = c.MENU_ID
and    b.ENTRY_SEQUENCE = c.ENTRY_SEQUENCE
and    c.FUNCTION_ID = a.FUNCTION_ID
and    a.type in ('WWR','WWRG')
and    b.RESPONSIBILITY_ID = d.RESPONSIBILITY_ID
and    d.user_id = icx_sec.g_user_id
and    d.start_date <= sysdate
and    (d.end_date is null or d.end_date > sysdate)
and    b.RESPONSIBILITY_ID = e.RESPONSIBILITY_ID
and    e.start_date <= sysdate
and    (e.end_date is null or e.end_date > sysdate)
order by b.DISPLAY_SEQUENCE;

begin

select HSECS into l_start from V$TIMER;
l_hsecs := l_start;

if (icx_sec.validateSession)
then
    begin
        select PAGE_ID,REFRESH_RATE
        into   l_page_id,l_refresh_rate
        from   ICX_PAGES
        where  USER_ID = icx_sec.g_user_id;
    exception
          when NO_DATA_FOUND then
            htp.p('Add page creation code here');
    end;

    fnd_message.set_name('ICX','ICX_LOGIN_CUSTOMIZE');
    l_customize_page := fnd_message.get;
    l_date := to_char(sysdate,icx_sec.g_date_format);

    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    if l_refresh_rate > 0
    then
      htp.p('<META HTTP-EQUIV="Refresh" CONTENT="'||l_refresh_rate||'">');
    end if;
    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('window.name = "root"');
    htp.p('var function_window = new Object();');
    htp.p('var counter=0;');-- add support for unique window names 1812147
    htp.p('var hostname="'||replace((replace(FND_WEB_CONFIG.DATABASE_ID,'-','_')),'.','_')||'";');
    htp.p('function_window.open = false;');


    --mputman added 1743710
    htp.p('function icx_nav_window2(mode, url, resp_app, resp_key, secgrp_key, name){
             counter=counter+1;
             hostname=hostname;
             resp_app=escape(unescape(resp_app));
             resp_key=escape(unescape(resp_key));
             secgrp_key=escape(unescape(secgrp_key));
             url=url+"RESP_APP="+resp_app+"&RESP_KEY="+resp_key+"&SECGRP_KEY="+secgrp_key;
             if (mode == "WWK" || mode == "FORM") {
               attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
               function_window.win = window.open(url, "function_window"+counter+hostname, attributes);
               if (function_window.win != null)
                 if (function_window.win.opener == null)
                   function_window.win.opener = self;
                   function_window.win.focus();
             }
             else {
               self.location = url;
               };


      };');


    htp.p('function icx_nav_window(mode, url, name){
          if (mode == "WWK" || mode == "FORM") {
            attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
            function_window.win = window.open(url, "function_window", attributes);
            if (function_window.win != null)
              if (function_window.win.opener == null)
                function_window.win.opener = self;
            function_window.win.focus();
            }
          else {
            self.location = url;
            };
        };');

    htp.p('function topwindowfocus() {
            if (document.functionwindowfocus.X.value == "TRUE") {
               function_window.win.focus();
            }
          };');

    htp.p('</SCRIPT>');

    htp.p('</head>');
    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onfocus="topwindowfocus()">');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=101%>');
    htp.p('<tr ><td><IMG SRC="/OA_MEDIA/FNDINVDT.gif" width="25" alt=""></td>');
    htp.p('<td align="'||OracleMyPage.g_start||'">'||l_date||'</td>');
    htp.p('<td align="'||OracleMyPage.g_end||'" NOWRAP>'||htf.anchor(curl => 'OraclePlugs.Customize?',
                             ctext => l_customize_page)||'</td>');
    htp.p('<td><IMG SRC="/OA_MEDIA/FNDINVDT.gif" width="25" alt=""></td></tr></table>');

    htp.formOpen(curl => 'XXX',
               cattributes => 'NAME="functionwindowfocus"');
    htp.formHidden('X','FALSE');
    htp.formClose;

select HSECS into l_timer from V$TIMER;
l_timer := (l_timer-l_hsecs)/100;
htp.p('<H1>Startup took '||l_timer||' seconds</H1>');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=101%>');
    htp.p('<tr><td valign="TOP">');
    htp.p('<table>');

    for l in left loop
      htp.p('<tr><td>');

select HSECS into l_hsecs from V$TIMER;

      l_stmt_str := 'begin '||l.web_html_call||
                    '(p_session_id => '||icx_sec.g_session_id||
                    ',p_plug_id => '||l.plug_id||
                    ',p_display_name => '''||replace(l.prompt,'''','''''')||''');'||
                    ' end;';
      execute immediate l_stmt_str;

select HSECS into l_timer from V$TIMER;
l_timer := (l_timer-l_hsecs)/100;
htp.p('<H1>Region took '||l_timer||' seconds</H1>');

    htp.p('</td></tr>');
    end loop;

    htp.p('</table>');
    htp.p('</td><TD VALIGN=TOP BGCOLOR="'||icx_plug_utilities.toolbarcolor||'"><IMG SRC="/OA_MEDIA/FNDINVDT.gif" width="3" alt=""></TD><td valign="TOP">');
    htp.p('<table>');

    for r in right loop
      htp.p('<tr><td>');

select HSECS into l_hsecs from V$TIMER;

      l_stmt_str := 'begin '||r.web_html_call||
                    '(p_session_id => '||icx_sec.g_session_id||
                    ',p_plug_id => '||r.plug_id||
                    ',p_display_name => '''||replace(r.prompt,'''','''''')||''');'||
                    ' end;';
      execute immediate l_stmt_str;

select HSECS into l_timer from V$TIMER;
l_timer := (l_timer-l_hsecs)/100;
htp.p('<H1>Region took '||l_timer||' seconds</H1>');

      htp.p('</td></tr>');
    end loop;

    htp.p('</table>');
    htp.p('</td></tr>');
    htp.p('</table>');

select HSECS into l_timer from V$TIMER;
l_timer := (l_timer-l_start)/100;
htp.p('<H1>Whole page took '||l_timer||' seconds</H1>');

    htp.p('</body>');
    htp.p('</html>');
end if; -- vaildateSession

end;

procedure updateCurrentPageID(
	p_session_id	in	varchar2,
	p_page_id	in	varchar2
) is
l_session_id	number;
l_page_id	number;
begin
	l_session_id := to_number(p_session_id);
	l_page_id := to_number(p_page_id);

	update icx_sessions
	set page_id = p_page_id
	where session_id = p_session_id;
	commit;
exception
  when no_data_found then
	htp.p('session_id = '||p_session_id ||' '||SQLERRM);
  when others then
    htp.p(SQLERRM);

end updateCurrentPageID;


function getRegionURL(
	user_id		in	number,
	session_id	in	number,
	page_id		in	number
) return varchar2 is
cursor plugInfo (p_page_id number, p_user_id number) is
        select  fff.FUNCTION_NAME, fff.TYPE, fff.WEB_HOST_NAME,
                fff.WEB_HTML_CALL, fff.FUNCTION_ID, ipp.PLUG_ID,
                nvl(ipp.DISPLAY_NAME,fme.PROMPT) display, ipp.DISPLAY_SEQUENCE
        from    fnd_responsibility fr, FND_USER_RESP_GROUPS furg,
                fnd_form_functions fff, fnd_menu_entries_vl fme,
                icx_page_plugs ipp
        where   ipp.PAGE_ID = p_page_id and fme.MENU_ID = ipp.MENU_ID
        and     fme.ENTRY_SEQUENCE = ipp.ENTRY_SEQUENCE
        and     fff.FUNCTION_ID = fme.FUNCTION_ID
        and     ipp.RESPONSIBILITY_ID = furg.RESPONSIBILITY_ID
        and     ipp.RESPONSIBILITY_APPLICATION_ID = furg.RESPONSIBILITY_APPLICATION_ID
        and     furg.user_id = p_user_id and furg.start_date <= sysdate
        and     (furg.end_date is null or furg.end_date > sysdate)
        and     ipp.RESPONSIBILITY_ID = fr.RESPONSIBILITY_ID
        and     fr.start_date <= sysdate
        and     (fr.end_date is null or fr.end_date > sysdate)
        union
        select  fff.FUNCTION_NAME, fff.TYPE, fff.WEB_HOST_NAME,
                fff.WEB_HTML_CALL, fff.FUNCTION_ID, ipp.PLUG_ID,
                nvl(ipp.DISPLAY_NAME,fff.USER_FUNCTION_NAME),
                ipp.DISPLAY_SEQUENCE
        from    fnd_form_functions_vl fff, icx_page_plugs ipp
        where   ipp.MENU_ID = -1 and ipp.ENTRY_SEQUENCE = fff.FUNCTION_ID
        and     ipp.PAGE_ID = p_page_id
	order by 8;

l_page_id       number;
l_plug_tab      plugTable;
i               number := 0;
l_host          varchar2(80) := null;
l_html_call     varchar2(240) := null;
l_plug_id       number;
l_display       varchar2(240) := null;
l_temp		varchar2(240);
l_url		varchar2(2000);
j		number := 0;
l_plugType	varchar2(30);
l_orientation   varchar2(4) := null;

begin

l_page_id := page_id;
for getPlug in plugInfo(l_page_id,user_id) loop
        l_host := getPlug.WEB_HOST_NAME;
        l_html_call := getPlug.WEB_HTML_CALL;
        l_plug_id := getPlug.PLUG_ID;
        l_display := getPlug.display;
	l_plugType := getPlug.TYPE;
        if l_host is null then
                l_host := owa_util.get_cgi_env('SERVER_NAME');
        end if;
        if l_html_call is null then
                l_html_call := 'x';
        end if;
        if l_display is null then
                l_display := 'x';
	else
		l_temp := '';
		for j in 1 .. length(l_display) loop
			if ( substr(l_display,j,1) = ' ' ) then
				l_temp := l_temp||'%20';
			else
				l_temp := l_temp||substr(l_display,j,1);
			end if;
		end loop;
		l_display := l_temp;
        end if;

	if ( l_orientation is null ) then
		if ( l_plugType = 'WWL' or l_plugType = 'WWLG' ) then
			l_orientation := 'Lxx';
		else
			l_orientation := 'xCR';
		end if;
	end if;
	--
	-- %7E = ~, it's a delimiter here
	--
        l_plug_tab(i):=getPlug.FUNCTION_NAME||'%7E'||l_orientation||'%7E'||
                        l_host||'%7E'||l_html_call||
                        '%7E'||to_char(getPlug.FUNCTION_ID)||'%7E'||
                        to_char(l_plug_id)||'%7E'||l_display;
        i := i + 1;
end loop;
l_url:= '/OA_JAVA_SERV/oracle.apps.icx.myPage.constructPage';
i := 0;
for i in 0 .. (l_plug_tab.count - 1) loop
        if i = 0 then
                l_url := l_url||'?arg0='||l_plug_tab(i);
        else
                l_url := l_url||'&'||'arg'||to_char(i)||'='||l_plug_tab(i);
        end if;
end loop;
l_url := l_url||'&'||'session_id='||to_char(session_id)||'&'||
		'agent='||icx_plug_utilities.getPLSQLagent||'&'||
		'page_id='||to_char(l_page_id);
return l_url;

end getRegionURL;


function getNewRegionURL(
	main_region_id	in	number,
	page_id		in	number,
	user_id		in	number,
	session_id	in	number
) return varchar2 is

l_page_id       number;
l_plug_tab      plugTable;
i               number := 0;
l_plug_id       number;
l_temp		varchar2(240);
l_url		varchar2(2000);
j		number := 0;
l_plugType	varchar2(30);
l_dbhost	varchar2(80);
l_agent		varchar2(80);
l_server_name	varchar2(1000);
l_server_port	varchar2(100);
l_dcd_name	varchar2(1000);

begin

/* Only support 115P
    l_dbhost := FND_WEB_CONFIG.DATABASE_ID;

    --insert into icx_testing values ('g_rendering_mode ' || icx_sec.g_mode_code);
    --insert into icx_testing values ('session id in getnewregionurl ' || to_char(session_id));

    if icx_sec.g_mode_code = '115J' then

	l_agent := icx_plug_utilities.getPLSQLagent;
	-- OAS approach
--      l_url:= '/OA_JAVA_SERV/oracle.apps.icx.myPage.renderPage';
        -- Below is for Servlet approach
        l_url := fnd_profile.value('APPS_SERVLET_AGENT')||'oracle.apps.icx.myPage.renderPage';
	l_server_name := owa_util.get_cgi_env('SERVER_NAME');
	l_server_port := owa_util.get_cgi_env('SERVER_PORT');

      l_url:= l_url||'?db_host='||l_dbhost||'&'||'main_region_id='||to_char(main_region_id)||
		    '&'||'page_id='||to_char(page_id)||'&'||'user_id='||to_char(user_id)||
		    '&'||'session_id='||to_char(session_id)||'&'||'agent='||l_agent||
		    '&'||'server_name='||l_server_name||'&'||'port='||l_server_port;


    elsif icx_sec.g_mode_code in  ('115P', 'SLAVE') then
      l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;
      l_url := l_agent || 'OracleConfigure.render?p_page_id='||page_id||
				       '&'||'p_region_id='||main_region_id||
				       '&'||'p_mode=0';
    end if;
*/

      l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;
      l_url := l_agent || 'OracleConfigure.render?p_page_id='||page_id||
                                       '&'||'p_region_id='||main_region_id||
                                       '&'||'p_mode=0';

    return l_url;

end getNewRegionURL;

--************************************************************
--                  Home   (global layer)
--************************************************************
procedure Home(rmode       in     number,
               i_1         in     VARCHAR2,
               i_2         in     VARCHAR2,
               home_url    in     VARCHAR2,
               i_direct    IN     VARCHAR2,
               c_sec_grp_id IN    VARCHAR2) IS --mputman hosted update

l_user_id     number;
l_apps_sso    varchar2(30);
l_profile_defined boolean;
l_message     varchar2(80);
l_session_id  pls_integer;
l_mode_code   varchar2(30);
l_sgid        NUMBER;
e_no_sgid     exception;
l_resp_appl_id number;
l_responsibility_id number;
l_security_group_id number;
l_function_id number;
l_url         varchar2(2000);
c_error_msg		varchar2(2000);
c_login_msg		varchar2(2000);
b_hosted BOOLEAN DEFAULT NULL;
l_hosted_profile VARCHAR2(50);
l_expired varchar2(30);

begin
--htp.p('home global');--mputman debug

 -- 2802333 nlbarlow APPS_SSO
 BEGIN
   SELECT user_id
   INTO   l_user_id
   FROM   fnd_user
   WHERE  user_name = upper(i_1);
 EXCEPTION
   WHEN no_data_found  THEN
     l_user_id := NULL;
 END;

 IF l_user_id IS NOT NULL THEN
   fnd_profile.get_specific
               (name_z       => 'APPS_SSO',
                user_id_z    => l_user_id,
                val_z        => l_apps_sso,
                defined_z    => l_profile_defined);
 ELSE
   l_apps_sso := fnd_profile.value('APPS_SSO');
 END IF;

 if l_apps_sso <> 'SSWA'
 then

   l_url := fnd_sso_manager.getLoginUrl;

   owa_util.mime_header('text/html', FALSE);
   owa_util.redirect_url(l_url);
   owa_util.http_header_close;

 else

/* Only support 115P
   if rmode = JAVA_MODE then
      l_mode_code := '115J';
   elsif rmode = PLSQL_MODE then
      l_mode_code := '115P';
   end if;
*/
   l_mode_code := '115P';

   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);

   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
   END IF;

      IF b_hosted THEN

      BEGIN
      SELECT security_group_id
      INTO l_sgid
      FROM fnd_security_groups
      WHERE security_group_key=c_sec_grp_id;
      EXCEPTION
         WHEN no_data_found THEN
         raise e_no_sgid;

      END;

      END IF;
      icx_sec.g_security_group_id := l_sgid;


   if i_1 is not null then
      l_message := icx_sec.validatePassword(c_user_name     => i_1,
				   	    c_user_password => i_2,
					    n_session_id    => l_session_id,
                                            c_validate_only => 'Y',
					    c_mode_code     => l_mode_code);
       icx_sec.g_session_id:=l_session_id;--MPUTMAN ADDED 2456610
       if home_url is not null
       then
         l_url := home_url;
         update ICX_SESSIONS
         set    HOME_URL = l_url
         where  SESSION_ID = l_session_id;
       end if;
   else
      l_session_id := icx_sec.getsessioncookie;
   end if;

   if (l_session_id > 0
   and icx_sec.validateSessionPrivate(c_session_id => l_session_id,
                                      c_validate_only => 'Y'))
   then

      -- 1588724 nlbarlow added flags
      icx_sec.g_validateSession_flag := false;

      -- 2758891 nlbarlow APPLICATIONS_HOME_PAGE
      if fnd_profile.value('APPLICATIONS_HOME_PAGE') = 'FWK'
      then
        select FUNCTION_ID
        into   l_function_id
        from   FND_FORM_FUNCTIONS
        where  FUNCTION_NAME = 'OAHOMEPAGE';

        l_url := icx_portlet.createExecLink
                (p_application_id => nvl(icx_sec.g_resp_appl_id,'-1'),
                 p_responsibility_id => nvl(icx_sec.g_responsibility_id,'-1'),
                 p_security_group_id => nvl(icx_sec.g_security_group_id,'0'),
                 p_function_id => l_function_id,
                 p_url_only => 'Y');

        htp.p('<SCRIPT>');
        htp.p('top.location="'||l_url||'"');
        htp.p('</SCRIPT>');
      ELSIF i_direct IS NOT NULL THEN
         htp.p('<SCRIPT>');
         htp.p('top.location="'||i_direct||'"');
         htp.p('</SCRIPT>');
      ELSE
         htp.p('<SCRIPT>');
         htp.p('top.location="OracleMyPage.home?home_url='||wfa_html.conv_special_url_chars(home_url)||'"');
         htp.p('</SCRIPT>');
      END IF; -- FWK

      icx_sec.g_validateSession_flag := true;

   else -- session fails

     begin
         select 'Y'
           into  l_expired
           from  FND_USER
          where  USER_NAME = UPPER(i_1)
            and    (PASSWORD_DATE is NULL or
                   (PASSWORD_LIFESPAN_ACCESSES is not NULL and
                     nvl(PASSWORD_ACCESSES_LEFT, 0) < 1) or
                   (PASSWORD_LIFESPAN_DAYS is not NULL and
                   SYSDATE >= PASSWORD_DATE + PASSWORD_LIFESPAN_DAYS));
     exception
             when no_data_found then
                l_expired := 'N';
     end;

     if l_expired = 'N'
     then
       raise e_no_sgid;  -- 2967196
     elsif fnd_web_sec.validate_login(i_1, i_2) = 'N'
     then
       raise e_no_sgid;  -- 2973597
     end if;

   end if; -- validateSessionPrivate

 end if; -- APPS_SSO

exception

   WHEN e_no_sgid THEN
    --display loginpage with invalid login error
      fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      OracleApps.displayLogin
        (c_message => c_error_msg||' '||c_login_msg,
         p_home_url => home_url);
    --
    NULL;
   when others then
        icx_sec.g_validateSession_flag := true;
        htp.p(SQLERRM);

end;

--************************************************************
--                  Home   (local layer)
--************************************************************
procedure Home(i_1           in     VARCHAR2,
               i_2           in     VARCHAR2,
               home_url      in     VARCHAR2,
               validate_flag in     VARCHAR2) is

   --added for 1352780
   --gets information on Web responsibilities
   cursor responsibilities_W is
select  a.responsibility_id,
        a.responsibility_name,
        a.description,
        a.version,
        a.responsibility_key,
        b.responsibility_application_id,
        fsg.SECURITY_GROUP_NAME,
        fsg.SECURITY_GROUP_ID,
        fsg.security_group_key,
        fa.application_short_name
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b,
        FND_APPLICATION fa
where   b.user_id = icx_sec.g_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.application_id = fa.application_id
and     a.version in ('W')
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
order by version desc,responsibility_name;

   --added for 1352780
   -- gets info on Forms responsibilities
   cursor responsibilities_4 is
select  a.responsibility_id,
        a.responsibility_name,
        a.description,
        a.version,
        a.responsibility_key,
        b.responsibility_application_id,
        fsg.SECURITY_GROUP_NAME,
        fsg.SECURITY_GROUP_ID,
        fsg.security_group_key,
        fa.application_short_name
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b,
        FND_APPLICATION fa
where   b.user_id = icx_sec.g_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.application_id = fa.application_id
and     a.version in ('4')
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
      order by version desc,responsibility_name;


   cursor getPages (p_user_id number) is
	select ip.page_id, ipt.page_name, ip.main_region_id, ip.page_code, ip.page_type
	  from icx_pages ip,
               icx_pages_tl ipt
	 where ip.user_id = p_user_id
           and ipt.language = userenv('LANG')
	   and ip.page_id = ipt.page_id
           and ip.page_type in ('USER', 'MAIN')
	order by ip.page_type desc, ip.sequence_number;

l_start                 number;
l_timer                 number;
l_hsecs                 number;

l_function_id           number;
l_home_url              varchar2(240);
l_message               varchar2(80);
l_session_id		pls_integer;
l_page_type             varchar2(5);
l_known_as		varchar2(240);
l_title			varchar2(240);
l_helpmsg		varchar2(240);
l_helptitle		varchar2(240);
l_tabs			icx_cabo.tabTable;
l_toolbar		icx_cabo.toolbar;
l_tabicons		icx_cabo.tabiconTable;
l_url			varchar2(2000);
l_page_count		number;
l_page_id		number;
l_page_index		number;
l_page_name		varchar2(80);--mputman reset from 30 to 80
l_main_region_id	number;
l_agent			varchar2(240);
l_host			varchar2(80);
l_port			varchar2(30);
l_tab_hint		varchar2(2000);
l_active_tab_index	number;
l_active_page_id	number;
--below added for 1352780
l_function_code NUMBER; --mputman
l_function_count NUMBER; --mputman
l_function_type VARCHAR2(30); --mputman
l_resps_count NUMBER; --mputman
l_resp_type VARCHAR2(10);--mputman
p_page_id NUMBER; --mputman
l_region_count NUMBER; --mputman
p_display_name VARCHAR2(80); --mputman
l_target VARCHAR2(30); --mputman
p_target_url VARCHAR2(640); --mputman
p_toggle VARCHAR2(10); --mputman
l_user_id NUMBER; -- mputman
l_prompts		icx_util.g_prompts_table; --mputman
l_menu_prompt  VARCHAR2(240); --mputman
l_menu_count   NUMBER; --mputman
l_menu_id NUMBER; --mputman
p_new_window VARCHAR2(2000); --mputman
-- end additions for 1352780
no_nls_exception EXCEPTION; -- mputman 1378862
temp_page_id NUMBER; --mputman
l_homepage_type         varchar2(10);


BEGIN

-- nlbarlow null out ids on return to home
l_session_id := icx_sec.getsessioncookie;

icx_sec.updateSessionContext(p_application_id => '',
                             p_responsibility_id => '',
                             p_security_group_id => '',
                             p_session_id => l_session_id);

if (icx_sec.validatesession) THEN --1503616 mputman
 -- 2758891 nlbarlow APPLICATIONS_HOME_PAGE
 if (icx_sec.g_mode_code = '115X') then -- Oracle Portal, nlbarlow

   fnd_profile.get(name => 'APPS_PORTAL',
                    val => l_url);

   if l_url IS NULL Then
      htp.p ('Please contact System Administrator. ');
      htp.p ('Profile - APPS_PORTAL is null') ;
   end If ;

   owa_util.mime_header('text/html', FALSE);
   owa_util.redirect_url(l_url);
   owa_util.http_header_close;

 elsif fnd_profile.value('APPLICATIONS_HOME_PAGE') = 'FWK'
 then
    select FUNCTION_ID
    into   l_function_id
    from   FND_FORM_FUNCTIONS
    where  FUNCTION_NAME = 'OAHOMEPAGE';

    l_url := icx_portlet.createExecLink
                (p_application_id => nvl(icx_sec.g_resp_appl_id,'-1'),
                 p_responsibility_id => nvl(icx_sec.g_responsibility_id,'-1'),
                 p_security_group_id => nvl(icx_sec.g_security_group_id,'0'),
                 p_function_id => l_function_id,
                 p_url_only => 'Y');

    owa_util.mime_header('text/html', FALSE);
    owa_util.redirect_url(l_url);
    owa_util.http_header_close;

 else -- PHP
   -- begin 1352780 block

   p_toggle:=''; --used to decide which cabo container call to use
   l_function_code:=0;
   l_target:='_top';
   icx_util.getprompts(601, 'ICX_OBIS_NAVIGATE', l_title, l_prompts);

   p_display_name:=l_prompts(1);
   l_user_id:=icx_sec.g_user_id;

   select count(*) into l_page_count
       from icx_pages
       where user_id = l_user_id;

   IF (l_page_count=1)THEN

      SELECT page_id
        INTO l_page_id
        FROM icx_pages
        WHERE user_id = l_user_id;

      select  count(*)
         INTO l_region_count
         FROM icx_page_plugs
         WHERE page_id=l_page_id;


  END IF;

  -- how many valid resps?
  -- 1584711 nlbarlow remove order by
  select  count(*) INTO l_resps_count
  from    FND_SECURITY_GROUPS_VL fsg,
          FND_RESPONSIBILITY_VL a,
          FND_USER_RESP_GROUPS b
  where   b.user_id = l_user_id
  and     b.start_date <= sysdate
  and     (b.end_date is null or b.end_date > sysdate)
  and     b.RESPONSIBILITY_id = a.responsibility_id
  and     b.RESPONSIBILITY_application_id = a.application_id
  and     a.start_date <= sysdate
  and     (a.end_date is null or a.end_date > sysdate)
  and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;

  l_homepage_type :=  fnd_profile.value('APPLICATIONS_HOME_PAGE');

 IF (l_page_count=1) AND (l_resps_count=1) AND (l_region_count=1) AND (l_homepage_type = 'PHP')


     THEN
        p_toggle:='Y'; -- will use different call to cabo container
        if (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then

       l_agent := FND_WEB_CONFIG.WEB_SERVER||
                  substr(icx_plug_utilities.getPLSQLagent,2);

    else
       l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

    end if;
    select  a.version INTO l_resp_type
from    FND_SECURITY_GROUPS_VL fsg,
        FND_RESPONSIBILITY_VL a,
        FND_USER_RESP_GROUPS b
where   b.user_id = l_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
order by responsibility_name;

    IF l_resp_type='4' THEN  -- 4 is for forms

       FOR r IN responsibilities_4 LOOP



       p_target_url:=l_agent||'OracleNavigate.menuBypass?p_token='||icx_call.encrypt(r.application_short_name||'*'
                                                                  ||r.responsibility_key||'*'
                                                                  ||r.security_group_key||'*'
                                                                  ||l_agent||'**]');
       --p_target_url:=p_target_url||'*'||r.security_group_key||'*'||l_agent||'**]';

          -- p_target_url is the URL passed to cabo
          -- in this case, it is passing to bypass to launch forms apps
          -- with the only available responsibility.
       END LOOP;  --r_4

    ELSE

        for r in responsibilities_W loop   -- w is for web
           select count(*)
           INTO l_function_count
           from
            fnd_responsibility_vl a,
            fnd_menu_entries_vl b,
            fnd_form_functions_vl c
            where a.responsibility_id=r.responsibility_id
            and a.menu_id=b.menu_id
            and b.function_id=c.function_id
            AND b.prompt IS NOT NULL
            and c.type in ('WWW','WWK','SERVLET','JSP','FORM','INTEROPJSP')
            and    nvl(c.FUNCTION_ID,-1) not in   -- menu exclusion support 1911095 mputman
                (select ACTION_ID
                   from   FND_RESP_FUNCTIONS
                   where  RESPONSIBILITY_ID = r.responsibility_id
                   and    APPLICATION_ID    = r.responsibility_application_id);

-- 2712250 nlbarlow
           SELECT count(*)
             INTO l_menu_count
             FROM fnd_menu_entries_vl c
             WHERE prompt IS NOT NULL
             and menu_id=(SELECT menu_id
                            FROM fnd_responsibility_vl
                            WHERE responsibility_id = r.responsibility_id
                            AND   APPLICATION_ID    = r.responsibility_application_id)
             AND     nvl(c.FUNCTION_ID,-1) not in   -- menu exclusion support 1911095 mputman
                (select ACTION_ID
                   from   FND_RESP_FUNCTIONS
                   where  RESPONSIBILITY_ID = r.responsibility_id
                   and    APPLICATION_ID    = r.responsibility_application_id)
             AND nvl(c.SUB_MENU_ID,-1) not IN -- add support for submenu exclusions 2029055
             (select ACTION_ID
              from   FND_RESP_FUNCTIONS
                   where  RESPONSIBILITY_ID = r.responsibility_id
                   and    APPLICATION_ID    = r.responsibility_application_id);



           IF ((l_function_count=1) AND (l_menu_count=1)) THEN


              SELECT c.function_id, nvl(b.prompt,c.user_function_name) prompt,c.TYPE,a.menu_id
              INTO l_function_code, l_menu_prompt, l_function_type, l_menu_id
           from
            fnd_responsibility_vl a,
            fnd_menu_entries_vl b,
            fnd_form_functions_vl c
            where a.responsibility_id=r.responsibility_id
            and a.menu_id=b.menu_id
            and b.function_id=c.function_id
            and b.prompt is not null -- 3275654 nlbarlow
            and c.type in ('WWW','WWK','SERVLET','JSP','FORM','INTEROPJSP')
            and nvl(c.FUNCTION_ID,-1) not in -- 3275654 nlbarlow
                  (select ACTION_ID
                   from   FND_RESP_FUNCTIONS
                   where  RESPONSIBILITY_ID = r.responsibility_id
                   and    APPLICATION_ID    = r.responsibility_application_id);

              p_target_url:=l_agent||'OracleNavigate.menuBypass?p_token='||icx_call.encrypt(r.responsibility_application_id
                                                                         ||'*'||r.responsibility_id||'*'
                                                                         ||l_function_code||'*'
                                                                         ||r.security_group_id||'*'
                                                                         ||l_agent||'**]')||'&p_mode=W';
          ELSE

              p_target_url:=l_agent||'OracleNavigate.Responsibility?P='||icx_call.encrypt2(r.responsibility_id,icx_sec.g_session_id)||'&'
                                                                       ||'D='||wfa_html.conv_special_url_chars(p_display_name)||'&'
                                                                       ||'S='||r.security_group_id||'&'
                                                                       ||'tab_context_flag=OFF'||'&'
                                                                       ||'M=9999';
           END IF;
             -- p_target_url is the URL passed to cabo
             -- in this case, it is either calling menubypass to launch the only function available
             -- of it is callin responsibility to paint all of the functions available.

        end loop; -- r_w
        END IF;-- resp_type
        END IF; --pagecount
--end 1352780 block




   select HSECS into l_start from V$TIMER;
   l_hsecs := l_start;

   if validate_flag = 'Y' then
      if (icx_sec.validatesession) then
          l_session_id := icx_sec.g_session_id;
      end if;
   else
      l_session_id := icx_sec.g_session_id;
   end if;

   if (l_session_id > 0) then

       --insert into icx_testing values ('session id  in Home ' || to_char(l_session_id));
       --insert into icx_testing values ('g_mode_code in Home *' || icx_sec.g_mode_code);

       l_agent := icx_plug_utilities.getPLSQLagent;

       if home_url is not null then
          l_home_url := home_url;
	  update ICX_SESSIONS
	     set HOME_URL = l_home_url
	   where SESSION_ID = l_session_id;
          commit;
       end if;


       select substr(nvl(DESCRIPTION,USER_NAME),1,70)
         into l_known_as
         from FND_USER
        where USER_ID = icx_sec.g_user_id;

       -- get active page_id
       select page_id into l_active_page_id
         from icx_sessions
        where session_id = l_session_id;

       fnd_message.set_name('ICX','ICX_LOGIN_WELCOME');
       fnd_message.set_token('USER',l_known_as);
       l_toolbar.title := icx_util.replace_quotes(fnd_message.get); --added call to replace quotes 2637147
       l_toolbar.help_url := 'javascript:top.main.help_window()';
       fnd_message.set_name('ICX','ICX_HELP');
       l_toolbar.help_mouseover := FND_MESSAGE.GET;
       -- icon hint for Tab Adminstration
       l_tab_hint := wf_core.translate('ICX_TAB_ADMIN');
       l_toolbar.custom_option1_url := l_agent||'icx_define_pages.editpagelist';
       l_toolbar.custom_option1_mouseover := l_tab_hint;
       l_toolbar.custom_option1_gif := 'OA_MEDIA/FNDMANOP.gif';
       l_toolbar.custom_option1_mouseover_gif := 'OA_MEDIA/FNDMANOP.gif';

       l_helpmsg := '';
       l_helptitle := '';

       select count(*) into l_page_count
       from icx_pages
       where user_id = icx_sec.g_user_id
       and page_type = 'MAIN';

       if ( l_page_count = 0 ) then
	   -- user has no MAIN page, create a page for user
	       l_page_id := OracleConfigure.createPage(
		     p_page_type => 'MAIN',
		     p_page_name => wf_core.translate('MAIN_MENU'),
                     p_validate_flag => 'N');
          --add exception raise to prevent messy screen 1378862
          IF (l_page_id = 0) THEN
             RAISE no_nls_exception;
          END IF;
       end if;
       l_page_index := 0;
       for thisPage in getPages(icx_sec.g_user_id) loop
	     l_page_id := thisPage.page_id;
	     l_page_name := thisPage.page_name;
	     l_main_region_id := thisPage.main_region_id;
             --htp.p(l_page_id);
             if thisPage.page_type <> 'MAIN' then
                temp_page_id:=l_page_id;
		l_tabicons(l_page_index).name := 'edit'||l_page_id;-- mputman added l_page_id for bug1340651
		l_tabicons(l_page_index).iconname := 'OA_HTML/webtools/images/tab_edit_icon.gif';
		l_tabicons(l_page_index).iconposition := 'right';
		l_tabicons(l_page_index).hint := wf_core.translate('MODIFY_HOME');
		l_tabicons(l_page_index).actiontype := 'url';
		l_tabicons(l_page_index).url := l_agent||'OracleConfigure.customize?p_page_id='||l_page_id;--mputman added parameter for bug1340651
		l_tabicons(l_page_index).targetframe := '_top';

                l_tabs(l_page_index).iconobj := 'edit'||l_page_id;-- mputman added l_page_id for bug1340651
             ELSE

      l_page_name := substrb(wf_core.translate('MAIN_MENU'),1,80); --mputman added 1405228
		l_tabicons(l_page_index).name := 'noedit';
		l_tabicons(l_page_index).iconname := null;
		l_tabicons(l_page_index).iconposition := null;
		l_tabicons(l_page_index).hint := null;
		l_tabicons(l_page_index).actiontype := null;
		l_tabicons(l_page_index).url := null;
		l_tabicons(l_page_index).targetframe := null;

                l_tabs(l_page_index).iconobj := 'noedit';
             end if;


	     l_tabs(l_page_index).name := thisPage.page_code;
	     l_tabs(l_page_index).text := l_page_name;
	     l_tabs(l_page_index).hint := l_page_name;
	     l_tabs(l_page_index).visible := 'true';
	     l_tabs(l_page_index).enabled := 'true';
	     --l_url := getRegionURL(icx_sec.g_user_id, l_session_id, l_page_id);
	     l_url := getNewRegionURL(l_main_region_id, l_page_id, icx_sec.g_user_id, l_session_id);
	     l_tabs(l_page_index).url := l_url;


	     l_page_index := l_page_index + 1;
	     if l_active_page_id is null then
		     l_active_tab_index := 1;
	     else
		     if l_active_page_id = l_page_id then
			     l_active_tab_index := l_page_index;
                             l_page_type := thisPage.page_type;
		     end if;
	     end if;
       end loop;

       l_toolbar.custom_option3_url := l_agent || 'icx_admin_sig.Startover';
       l_toolbar.custom_option3_mouseover :=
                        icx_util.getprompt(601,'ICX_OBIS_TOOLBAR',178,'ICX_EXIT');
       l_toolbar.custom_option3_gif := 'OA_MEDIA/FNDEXIT.gif';
       l_toolbar.custom_option3_mouseover_gif := 'OA_MEDIA/FNDEXIT.gif';
       l_toolbar.custom_option3_disabled_gif := 'OA_MEDIA/FNDEXIT.gif';



       IF (p_toggle='Y') THEN     --added 1352780 mputman
          -- pass URL constructed above (p_target_url) to the cabo container
          -- to bypass normal menu painting if options are limited.
          icx_cabo.container(p_toolbar    => l_toolbar,
			  p_helpmsg    => l_helpmsg,
			  p_helptitle  => l_helptitle,
			  p_tabicons   => l_tabicons,
			  p_currenttab => l_active_tab_index,
			  p_tabs       => l_tabs,
           p_url        => p_target_url);

       ELSE
          icx_cabo.container(p_toolbar    => l_toolbar,
 p_helpmsg    => l_helpmsg,
 p_helptitle  => l_helptitle,
 p_tabicons   => l_tabicons,
 p_currenttab => l_active_tab_index,
 p_tabs       => l_tabs);
         END IF;


   end if;  --l_session_id
 end if; -- PHP vs Portal
END IF; --icx_sec.validatesession mputman 1503616

EXCEPTION
   -- added 1378862 mputman
   WHEN no_nls_exception THEN
      htp.p('ERROR - Translation data has not been installed yet, please apply NLS patch.');htp.nl;
  when others then
    htp.p(SQLERRM);

end;

-- **************************************************************
--               DrawTabContent
-- **************************************************************
procedure DrawTabContent is

l_message               varchar2(80);
l_session_id		pls_integer;
l_page_type             varchar2(5);
l_known_as		varchar2(240);
l_title			varchar2(240);
l_helpmsg		varchar2(240);
l_helptitle		varchar2(240);
l_tabs			icx_cabo.tabTable;
l_toolbar		icx_cabo.toolbar;
l_tabicons		icx_cabo.tabiconTable;
l_url			varchar2(2000);
l_page_count		number;
l_page_id		number;
l_page_index		number;
l_page_name		varchar2(240);   --Bug 2076740
l_main_region_id	number;
l_agent			varchar2(240);
l_host			varchar2(80);
l_port			varchar2(30);
l_tab_hint		varchar2(2000);
l_active_tab_index	number;
l_active_page_id	number;

     cursor getPages (p_user_id number) is
	select ip.page_id, ipt.page_name, ip.main_region_id, ip.page_code, ip.page_type
	  from icx_pages ip,
               icx_pages_tl ipt
	 where ip.user_id = p_user_id
           and ipt.language = userenv('LANG')
	   and ip.page_id = ipt.page_id
           and ip.page_type in ('USER', 'MAIN')
	order by ip.page_type desc, ip.sequence_number;

begin


   if (icx_sec.validatesession) then

       --insert into icx_testing values ('session id  in Home ' || to_char(l_session_id));
       --insert into icx_testing values ('g_mode_code in Home *' || icx_sec.g_mode_code);

       l_agent := icx_plug_utilities.getPLSQLagent;

       select substr(nvl(DESCRIPTION,USER_NAME),1,70)
         into l_known_as
         from FND_USER
        where USER_ID = icx_sec.g_user_id;

       -- get active page_id
       select page_id into l_active_page_id
         from icx_sessions
        where session_id = icx_sec.g_session_id;

       fnd_message.set_name('ICX','ICX_LOGIN_WELCOME');
       fnd_message.set_token('USER',l_known_as);
       l_toolbar.title := icx_util.replace_quotes(fnd_message.get); --added call to replace quotes 2637147
       l_toolbar.help_url := 'javascript:top.main.help_window()';
       fnd_message.set_name('ICX','ICX_HELP');
       l_toolbar.help_mouseover := FND_MESSAGE.GET;
       -- icon hint for Tab Adminstration

       l_tab_hint := wf_core.translate('ICX_TAB_ADMIN');

       l_toolbar.custom_option1_url := l_agent||'icx_define_pages.editpagelist';
       l_toolbar.custom_option1_mouseover := l_tab_hint;
       l_toolbar.custom_option1_gif := 'OA_MEDIA/FNDMANOP.gif';
       l_toolbar.custom_option1_disabled_gif := 'OA_MEDIA/FNDMANOP.gif';
       l_toolbar.custom_option1_mouseover_gif := 'OA_MEDIA/FNDMANOP.gif';

       l_helpmsg := '';
       l_helptitle := '';

       l_page_index := 0;
       for thisPage in getPages(icx_sec.g_user_id) loop
	     l_page_id := thisPage.page_id;
	     l_page_name := thisPage.page_name;
	     l_main_region_id := thisPage.main_region_id;


             if thisPage.page_type <> 'MAIN' then
		l_tabicons(l_page_index).name := 'edit'||l_page_id;-- mputman added l_page_id for bug1340651
		l_tabicons(l_page_index).iconname := 'OA_HTML/webtools/images/tab_edit_icon.gif';
		l_tabicons(l_page_index).iconposition := 'right';
		l_tabicons(l_page_index).hint := wf_core.translate('MODIFY_HOME');
		l_tabicons(l_page_index).actiontype := 'url';
		l_tabicons(l_page_index).url := l_agent||'OracleConfigure.customize?p_page_id='||l_page_id;--mputman for bug1340651
		l_tabicons(l_page_index).targetframe := '_top';

                l_tabs(l_page_index).iconobj := 'edit'||l_page_id;-- mputman added l_page_id for bug1340651
             else
                l_page_name := substrb(wf_core.translate('MAIN_MENU'),1,240);--added for bug 1516684
		l_tabicons(l_page_index).name := 'noedit';
		l_tabicons(l_page_index).iconname := null;
		l_tabicons(l_page_index).iconposition := null;
		l_tabicons(l_page_index).hint := null;
		l_tabicons(l_page_index).actiontype := null;
		l_tabicons(l_page_index).url := null;
		l_tabicons(l_page_index).targetframe := null;

                l_tabs(l_page_index).iconobj := 'noedit';
             end if;

	     l_tabs(l_page_index).name := thisPage.page_code;
	     l_tabs(l_page_index).text := l_page_name;
	     l_tabs(l_page_index).hint := l_page_name;
	     l_tabs(l_page_index).visible := 'true';
	     l_tabs(l_page_index).enabled := 'true';

             l_url := getNewRegionURL(l_main_region_id, l_page_id, icx_sec.g_user_id, l_session_id);

	     l_tabs(l_page_index).url := l_url;

	     l_page_index := l_page_index + 1;
	     if l_active_page_id is null then
		     l_active_tab_index := 1;
	     else
		     if l_active_page_id = l_page_id then
			     l_active_tab_index := l_page_index;
                             l_page_type := thisPage.page_type;
		     end if;
	     end if;
       end loop;

       l_toolbar.custom_option3_url := l_agent || 'icx_admin_sig.Startover';
       l_toolbar.custom_option3_mouseover := icx_util.getprompt(601,'ICX_OBIS_TOOLBAR',178,'ICX_EXIT');
       l_toolbar.custom_option3_gif := 'OA_MEDIA/FNDEXIT.gif';
       l_toolbar.custom_option3_mouseover_gif := 'OA_MEDIA/FNDEXIT.gif';
       l_toolbar.custom_option3_disabled_gif := 'OA_MEDIA/FNDEXIT.gif';
       icx_cabo.container(p_toolbar    => l_toolbar,
			  p_helpmsg    => l_helpmsg,
			  p_helptitle  => l_helptitle,
			  p_tabicons   => l_tabicons,
			  p_currenttab => l_active_tab_index,
			  p_tabs       => l_tabs,
                          p_url        =>  l_agent || 'OracleNavigate.Responsibility?tab_context_flag=OFF?P='|| icx_call.encrypt2(icx_sec.g_responsibility_id));

   end if;  --icx_sec.validatesession

end;


end OracleMyPage;

/
