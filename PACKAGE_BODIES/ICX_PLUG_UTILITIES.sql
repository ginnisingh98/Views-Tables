--------------------------------------------------------
--  DDL for Package Body ICX_PLUG_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PLUG_UTILITIES" as
/* $Header: ICXPGUB.pls 120.1 2005/10/07 13:45:50 gjimenez noship $ */

function bgcolor return varchar2 is

l_color   varchar2(30);

begin

/*  icx_page_color_scheme has been obsoleted since 11.5.0
  begin
    select BACKGROUND_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '##CCCCCC';
  end;
*/

l_color := '#CCCCCC';

return l_color;

end;

function plugbgcolor return varchar2 is

l_color   varchar2(30);

begin

/* icx_page_color_scheme has been obsoleted since 11.5.0
  begin
    select BACKGROUND_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '##FFFFFF';
  end;
*/

l_color := '#FFFFFF';

return l_color;

end;

function plugheadingcolor return varchar2 is

l_color   varchar2(30);

begin

  begin
    select HEADING_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '#99CCFF';
  end;

return l_color;

end;

function headingcolor return varchar2 is

l_color   varchar2(30);

begin

  begin
    select HEADING_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '#99CCFF';
  end;

--  l_color := '#99CCFF';

return l_color;

end;

function plugbannercolor return varchar2 is

l_color   varchar2(30);

begin

  begin
    select BANNER_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '#99CCFF';
  end;

return l_color;

end;

function plugcolorscheme return varchar2 is

l_color   varchar2(30);

begin

   begin
     select COLOR_SCHEME
     into   l_color
     from ICX_PAGE_COLOR_SCHEME
     where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := 'BL';
  end;

return l_color;

end;


function bannercolor return varchar2 is

l_color   varchar2(30);

begin

  begin
    select BANNER_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '#99CCFF';
  end;

--  l_color := '#99CCFF';

return l_color;

end;

function toolbarcolor return varchar2 is

l_color   varchar2(30);

begin

  begin
    select TOOLBAR_COLOR
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := '#0000CC';
  end;

--  l_color := '#0000cc';

return l_color;

end;

function colorscheme return varchar2 is

l_color   varchar2(30);

begin

  begin
    select COLOR_SCHEME
    into   l_color
    from   ICX_PAGE_COLOR_SCHEME
    where  USER_ID = icx_sec.g_user_id;
  exception
    when others then
      l_color := 'BL';
  end;

--  l_color := 'BL';

return l_color;

end;

function getPLSQLagent return varchar2 is

  dad_url    varchar2(2000);
  index1 number;
  index2 number;
  index3 number;
  l_agent  varchar2(80);

begin

  dad_url := FND_WEB_CONFIG.PLSQL_AGENT;

  if (dad_url is null) then
     return NULL;
  end if;

  dad_url := FND_WEB_CONFIG.TRAIL_SLASH(dad_url);
  index1 := INSTRB(dad_url, '//', 1) + 2;
  index2 := INSTRB(dad_url, '/', index1);
  index3 := LENGTHB(dad_url)+1;

  l_agent := substrb(dad_url,index2,index3-index2);

  if (substr(icx_sec.g_mode_code,1,3) = '115' or
      icx_sec.g_mode_code = 'SLAVE')
  then
    l_agent := ltrim(l_agent,'/');
  end if;


return l_agent;

end;


function getReportPLSQLagent return varchar2 is

l_agent  varchar2(80);
l_profile varchar2(80);
l_agent_start number;
l_agent_end number;
begin
     l_profile := fnd_profile.value('APPS_WEB_AGENT');
     l_agent_start := instr(l_profile,'/',8);
     l_agent_end := instr(l_profile,'/',8,3);
     if l_agent_end <> 0 then
       l_agent := substr(l_profile,l_agent_start, l_agent_end);
     else
       l_agent := substr(l_profile,l_agent_start)||'/';
     end if;

return l_agent;

end;


function getReportURL return varchar2 is

l_agent  varchar2(80);
l_profile varchar2(80);
l_agent_end number;
begin
     l_profile := fnd_profile.value('APPS_WEB_AGENT');
     l_agent_end := instr(l_profile,'/',8);
     l_agent := substr(l_profile,1, l_agent_end);

return l_agent;

end;

function getPlugTitle(p_plug_id in varchar2) return varchar2 is

l_plug_title     varchar2(240);
l_menu_id        number;
l_entry_sequence number;

begin

select DISPLAY_NAME,MENU_ID,ENTRY_SEQUENCE
into   l_plug_title,l_menu_id,l_entry_sequence
from   ICX_PAGE_PLUGS
where  PLUG_ID = p_plug_id;

if l_plug_title is null
then
    select nvl(PROMPT,DESCRIPTION)
    into   l_plug_title
    from   FND_MENU_ENTRIES_VL
    where  MENU_ID = l_menu_id
    and    ENTRY_SEQUENCE = l_entry_sequence;
end if;

return l_plug_title;

end;

procedure gotoMainMenu is

l_host_instance varchar2(80);
l_agent  varchar2(80);
l_menu   varchar2(240);

begin

  if ( substr(icx_sec.g_mode_code,1,3) = '115' or
        icx_sec.g_mode_code = 'SLAVE')
  then
    l_menu :=  owa_util.get_cgi_env('SCRIPT_NAME')||'/oraclemypage.home';
  else
    l_host_instance := FND_WEB_CONFIG.DATABASE_ID;

    l_agent := icx_plug_utilities.getPLSQLagent;

    l_menu := '/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?dbHost='||l_host_instance||'&'||'agent='||l_agent;
  end if;

  owa_util.redirect_url(l_menu);
end;

function MainMenulink return varchar2 is

l_link varchar2(30);

begin

l_link := 'Javascript:MainMenu()';

return l_link;

end;

procedure banner(p_text in varchar2 default NULL,
                 p_edit_URL in varchar2 default NULL,
                 p_icon in varchar2 default NULL,
                 p_text2 in varchar2 default NULL,
                 p_text3 in varchar2 default NULL,
                 p_text4 in varchar2 default NULL) is

l_Customize varchar2(80);
l_color varchar2(30);
l_text_color varchar2(30);
l_text_face varchar2(30);
l_color_scheme varchar2(30);

begin

l_Customize := icx_util.getPrompt(601,'ICX_OBIS_NAVIGATE',178,'ICX_CUSTOMIZE');
if ( substr(icx_sec.g_mode_code,1,3) = '115' or
     icx_sec.g_mode_code = 'SLAVE')
then
  l_color := '#6699CC'; --'#000066';
  l_text_color := '#ffffff';
  l_text_face := 'Arial';
else
  l_color := icx_plug_utilities.bannercolor;
  l_text_color := '#000000';
  l_text_face := 'Arial';
end if;
l_color_scheme := icx_plug_utilities.colorscheme;

htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%><TR>');
htp.p('<td bgcolor="'||l_color||'" width=5%>');
if p_icon is null
then
    htp.p('&'||'nbsp;');
else
    htp.p('<img src=/OA_MEDIA/' || p_icon || '>');
end if;
htp.p('</td>');

htp.p('<td bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="'||l_text_color||'" face="'||l_text_face||'" size=2><b>'||p_text||' </td>');

if p_text2 is not null
then
    htp.p('<td bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="'||l_text_color||'" face="'||l_text_face||'" size=2><b>'||p_text2||'</td>');
end if;

if p_text3 is not null
then
    htp.p('<td bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="'||l_text_color||'" face="'||l_text_face||'Arial" size=2><b>'||p_text3||'</td>');
end if;

if p_text4 is not null
then
    htp.p('<td bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="'||l_text_color||'" face="'||l_text_face||'Arial" size=2><b>'||p_text4||'</td>');
end if;

if p_edit_URL is null
then
    htp.p('<td bgcolor="'||l_color||'" width="100%"><BR></td>');
else
    htp.p('<td bgcolor="'||l_color||'" align="right" width="100%" NOWRAP><font face="Arial" size=-2>'||
          htf.anchor(curl => p_edit_URL,
                     ctext => l_Customize,
                     cattributes => 'TARGET="_top" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_Customize)||''';return true"')||'</td>');
end if;
if  substr(icx_sec.g_mode_code,1,3) <> '115'
then
  htp.p('<td align="left"><img src=/OA_MEDIA/FND'||l_color_scheme||'SUB.gif height=18 width=8></td>');
end if;
htp.p('</tr></table>');

end;

procedure plugbanner(p_text in varchar2 default NULL,
                 p_edit_URL in varchar2 default NULL,
                 p_icon in varchar2 default NULL,
                 p_text2 in varchar2 default NULL,
                 p_text3 in varchar2 default NULL,
                 p_text4 in varchar2 default NULL) is

l_Customize varchar2(80);
l_color varchar2(30);

begin

l_Customize := icx_util.getPrompt(601,'ICX_OBIS_NAVIGATE',178,'ICX_CUSTOMIZE');
if ( substr(icx_sec.g_mode_code,1,3) = '115' OR
     icx_sec.g_mode_code = 'SLAVE')
then
  l_color := '#6699CC'; --'#000066';
else
  l_color := icx_plug_utilities.bannercolor;
end if;

htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%><TR>');
if p_icon is null
then
    htp.p('<td bgcolor="'||l_color||'">'||'&'||'nbsp;</td>');
else
    htp.p('<td bgcolor="'||l_color||'"><img src=/OA_MEDIA/'||p_icon||'></td>');
    htp.p('<td bgcolor="'||l_color||'"><img src=/OA_MEDIA/FNDINVDT.gif height=18 width=9></td>');
end if;

htp.p('<td bordercolor="#6699CC" bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="#ffffff" face="Arial" size=1><b> '|| p_text || '</b></td>');

if p_text2 is not null
then
    htp.p('<td bordercolor="#6699CC" bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="#ffffff" face="Arial" size=1><b>'||p_text2||'</td>');
end if;

if p_text3 is not null
then
    htp.p('<td bordercolor="#6699CC" bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="#ffffff"  face="Arial" size=1><b>'||p_text3||'</td>');
end if;

if p_text4 is not null
then
    htp.p('<td bordercolor="#bgcolor="'||l_color||'" width=100% align="left" NOWRAP><font color="#ffffff" face="Arial" size=1><b>'||p_text4||'</td>');
end if;

if p_edit_URL is null
then
    htp.p('<td bordercolor="#6699CC" bgcolor="'||l_color||'" width="101%"><BR></td>');
else

    htp.p('<td bordercolor="#6699CC" bgcolor="'||l_color||'" NOWRAP>'||
          htf.anchor(curl => p_edit_URL,
                     ctext => '<font color="#ffffff" face="Arial" size=1>' ||
                                            l_Customize || '</FONT>',
                     cattributes => 'TARGET="_top" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_Customize)||''';return true"')||'</td>');

end if;

--htp.p('<td align="left"><img src=/OA_MEDIA/FND' || plugcolorscheme ||
--	'SUB.gif height=18 width=8></td>');

htp.p('</tr></table>');

end;

procedure sessionjavascript(p_javascript_tags in boolean default TRUE,
                            p_function in boolean default TRUE) is

begin

if p_javascript_tags then
  htp.p('<SCRIPT LANGUAGE="JavaScript">');
end if;

if p_function
then
  if icx_sec.g_function_type = 'WWK'
  then
    htp.p('function windowunload() {
              parent.opener.parent.main.document.functionwindowfocus.X.value = "FALSE";
            };');
    htp.p('parent.opener.parent.main.document.functionwindowfocus.X.value = "TRUE";');
    htp.p('window.onfocus = self.focus;');
    htp.p('window.onunload = new Function("windowunload()");');
  else
    htp.p('');
  end if;
end if;

if p_javascript_tags then
  htp.p('</SCRIPT>');
end if;

end;

-- Cabo Toolbar
procedure cabotoolbar (p_text in varchar2 default NULL,
                       p_language_code in varchar2 default null,
                       p_disp_find     in varchar2 default null,
                       p_disp_mainmenu in varchar2 default 'Y',
                       p_disp_wizard   in varchar2 default 'N',
                       p_disp_help     in varchar2 default 'N',
                       p_disp_export   in varchar2 default null,
                       p_disp_exit     in varchar2 default 'N',
                       p_disp_menu     in varchar2 default 'Y') is

l_language_code varchar2(30);
l_title varchar2(80);
l_prompts icx_util.g_prompts_table;
l_href varchar2(2000);
l_host_instance varchar2(80);
l_agent  varchar2(80);

begin

if p_language_code is null
then
  l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
else
  l_language_code := p_language_code;
end if;

icx_util.getprompts(601, 'ICX_OBIS_TOOLBAR', l_title, l_prompts);

if p_disp_menu = 'N'
then
 sessionjavascript(p_function => FALSE);
else
 sessionjavascript(p_function => TRUE);
end if;

htp.p('<!--Outer table containing toolbar and logo cells-->
<table width=100% Cellpadding=0 Cellspacing=0 border=0>
<tr>
<td align=left>
<TABLE cellpadding="0" cellspacing="0" border="0">
<TR>
<TD rowspan="3"><IMG src="/OA_HTML/webtools/images/toolbar_left.gif"></TD>
<TD bgcolor="#FFFFFF" height="1"><IMG src="/OA_HTML/webtools/images/pixel_color6.gif"></TD>
<TD rowspan="3"><IMG src="/OA_HTML/webtools/images/toolbar_right.gif"></TD>
</TR>
<TR bgcolor="#CCCCCC"><TD><TABLE cellpadding="0" cellspacing="0" border="0">');

if (p_disp_menu = 'Y') then
  if icx_sec.g_function_type = 'WWK' then
    l_href := 'javascript:window.close();';
  else

    --l_href := 'javascript:top.location.href = ''OracleMyPage.DrawTabContent'||''';';

    l_href := 'javascript:top.location.href = ''OracleNavigate.Responsibility?P='||icx_sec.g_responsibility_id||''';';
  end if;

-- toolbar_icon_menu_active.gif and toolbar_icon_menu.gif
htp.p('<TD nowrap height="30" align="middle">
<A href="'||l_href||'" target="_top" onmouseover="document.menu.src=''/OA_MEDIA/FNDMENU.gif''; return true" onmouseout="document.menu.src=''/OA_MEDIA/FNDMENU.gif''; return true">
<IMG name="menu" src="/OA_MEDIA/FNDMENU.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(7))||'"></A></TD>');
end if;

if (p_disp_mainmenu = 'Y') then
  l_host_instance := FND_WEB_CONFIG.DATABASE_ID;
  l_agent := icx_plug_utilities.getPLSQLagent;

  if icx_sec.g_function_type = 'WWK' then
    l_href := 'javascript:parent.opener.location.href = '''||owa_util.get_cgi_env('SCRIPT_NAME')||'/oraclemypage.home'';window.close();';
  else
    l_href := 'javascript:top.location.href = '''||owa_util.get_cgi_env('SCRIPT_NAME')||'/oraclemypage.home'';';
  end if;

htp.p('<TD nowrap height="30" align="middle">
<A href="'||l_href||'" target="_top" onmouseover="document.home.src=''/OA_MEDIA/FNDHOME.gif''; return true" onmouseout="document.home.src=''/OA_MEDIA/FNDHOME.gif''; return true">
<IMG name="home" src="/OA_MEDIA/FNDHOME.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(3))||'"></A></TD>');
end if;

if p_text is not null
then
-- separator
htp.p('<TD nowrap height="30" align="middle"> <IMG src="/OA_HTML/webtools/images/toolbar_divider.gif" align="absmiddle"> </TD>');

-- p_text
htp.p('<TD height="30" nowrap align="middle"><FONT style="Arial, Helvetica, Geneva, sans-serif" color="#336699" size="+2"><B><I>'||'&'||'nbsp;'||p_text||'&'||'nbsp;</I></B></FONT></TD>');

-- separator
htp.p('<TD nowrap height="30" align="middle"> <IMG src="/OA_HTML/webtools/images/toolbar_divider.gif" align="absmiddle"> </TD>');
end if;

if (p_disp_exit = 'Y') then

htp.p('<TD nowrap height="30" align="middle">
<A href="icx_admin_sig.Startover" target="_top" onmouseover="document.exit.src=''/OA_MEDIA/FNDEXIT.gif''; return true" onmouseout="document.exit.src=''/OA_MEDIA/FNDEXIT.gif''; return true">
<IMG name="exit" src="/OA_MEDIA/FNDEXIT.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(4))||'"></A></TD>');
end if;

if (p_disp_help = 'Y') then

htp.p('<TD nowrap height="30" align="middle">
<A href="javascript:help_window()" target="_top" onmouseover="document.help.src=''/OA_MEDIA/FNDIHELP.gif''; return true" onmouseout="document.help.src=''/OA_MEDIA/FNDIHELP.gif''; return true">
<IMG name="help" src="/OA_MEDIA/FNDIHELP.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(5))||'"></A></TD>');
end if;

if (p_disp_wizard = 'Y' or p_disp_export is not null or p_disp_find is not null)
then
  htp.p('<TD class="toolbar" nowrap height="30" align="middle"> <IMG src="/OA_HTML/webtools/images/toolbar_divider.gif" align="absmiddle"> </TD>');
end if;

if (p_disp_wizard = 'Y') then

htp.p('<TD nowrap height="30" align="middle">
<A href="javascript:doWizard()" target="_top" onmouseover="document.wizard.src=''/OA_MEDIA/FNDWIZ.gif''; return true" onmouseout="document.wizard.src=''/OA_MEDIA/FNDWIZ.gif''; return true">
<IMG name="wizard" src="/OA_MEDIA/FNDWIZ.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(1))||'"></A></TD>');
end if;

if (p_disp_export is not null) then

htp.p('<TD nowrap height="30" align="middle">');
htp.p('<FORM ACTION="OracleON.csv" METHOD="POST" NAME="exportON">');
htp.formHidden('S',icx_call.encrypt2(p_disp_export));
htp.p('</FORM>');
htp.p('<A href="javascript:document.exportON.submit()" target="_top" onmouseover="document.export.src=''/OA_MEDIA/FNDEXP.gif''; return true" onmouseout="document.export.src=''/OA_MEDIA/FNDEXP.gif''; return true">
<IMG name="export" src="/OA_MEDIA/FNDEXP.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(6))||'"></A></TD>');
end if;

if (p_disp_find is not null) then

htp.p('<TD nowrap height="30" align="middle">
<A href="'||p_disp_find||'" target="_top" onmouseover="document.find.src=''/OA_MEDIA/FNDFIND.gif''; return true" onmouseout="document.find.src=''/OA_MEDIA/FNDFIND.gif''; return true">
<IMG name="find" src="/OA_MEDIA/FNDFIND.gif" align=absmiddle border=0 alt="'||icx_util.replace_alt_quotes(l_prompts(2))||'"></A></TD>');
end if;

htp.p('</TABLE></TD></TR>
<TR>
<TD bgcolor="#666666" height="1"><IMG src="/OA_HTML/webtools/images/pixel_gray2.gif"></TD>
</TR>
</TABLE>
</TD>
<TD rowspan=5 width=100% align=right><IMG src=/OA_MEDIA/FNDLOGOS.gif></TD>
</TR>
</TABLE>');

end;

-- p_disp_mainmenu is home
procedure toolbar (p_text in varchar2 default NULL,
                   p_language_code in varchar2 default null,
                   p_disp_find     in varchar2 default null,
                   p_disp_mainmenu in varchar2 default 'Y',
                   p_disp_wizard   in varchar2 default 'N',
                   p_disp_help     in varchar2 default 'N',
                   p_disp_export   in varchar2 default null,
                   p_disp_exit     in varchar2 default 'N',
                   p_disp_menu     in varchar2 default 'Y') is

url     varchar2(240) := null;
l_session_mode varchar2(30);
l_session_id   pls_integer;
c_title varchar2(80);
c_prompts icx_util.g_prompts_table;
l_text varchar2(240);
v_language_code varchar2(30);
l_toolbar_color varchar2(30);
l_heading_color varchar2(30);
l_color_scheme varchar2(30);
l_host_instance varchar2(80);
l_agent  varchar2(80);
l_menu   varchar2(240);
l_menu_id number;

begin

  if ( substr(icx_sec.g_mode_code,1,3) = '115' OR
       icx_sec.g_mode_code = 'SLAVE')
  then

    begin
    select menu_id
      into l_menu_id
      from icx_sessions
     where session_id = icx_sec.g_session_id;
    exception
      when no_data_found then
           l_menu_id := null;
    end;

    /* If menu id is null then the function is not called from the Navigate plug.
       Instead the function is being called directly from the Home Page.
       In such case we should not display the "return to main menu" icon because
       there is no main menu to return to.  Only the return to Home icon should
       be displayed. */

    if (l_menu_id is null) then
       icx_plug_utilities.cabotoolbar(p_text => p_text,
                       p_language_code => p_language_code,
                       p_disp_find     => p_disp_find,
                       p_disp_mainmenu => p_disp_mainmenu,
                       p_disp_wizard   => p_disp_wizard,
                       p_disp_help     => p_disp_help,
                       p_disp_export   => p_disp_export,
                       p_disp_exit     => p_disp_exit,
                       p_disp_menu     => 'N');
    else
      icx_plug_utilities.cabotoolbar(p_text => p_text,
                       p_language_code => p_language_code,
                       p_disp_find     => p_disp_find,
                       p_disp_mainmenu => p_disp_mainmenu,
                       p_disp_wizard   => p_disp_wizard,
                       p_disp_help     => p_disp_help,
                       p_disp_export   => p_disp_export,
                       p_disp_exit     => p_disp_exit,
                       p_disp_menu     => p_disp_menu);
    end if;
  else
    if p_text is null then
        l_text := '<BR>';
    else
        l_text := p_text;
    end if;

    if p_language_code is null then
        v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    else
        v_language_code := p_language_code;
    end if;

    l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
    l_session_mode := icx_sec.getID(icx_sec.PV_SESSION_MODE);
    if l_session_mode is null
    then
        l_session_mode := 'OBIS';
    end if;

    l_toolbar_color := icx_plug_utilities.toolbarcolor;
    l_heading_color := icx_plug_utilities.headingcolor;
    l_color_scheme := icx_plug_utilities.colorscheme;

    l_host_instance := FND_WEB_CONFIG.DATABASE_ID;

    l_agent := icx_plug_utilities.getPLSQLagent;

    l_menu := '/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?dbHost='||l_host_instance||'&'||'agent='||l_agent;

    htp.p('<!- ToolBar ->');

    if p_disp_menu = 'N'
    then
      sessionjavascript(p_function => FALSE);
    else
      sessionjavascript(p_function => TRUE);
    end if;

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=101%>');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=101%>');
    htp.p('<tr><td rowspan=4><img src="/OA_MEDIA/FND'||l_color_scheme||'BLT.gif" width=35 height=46></td>');
    htp.p('<td bgcolor="'||l_toolbar_color||'" rowspan=4><img src="/OA_MEDIA/FNDLOGOS.gif"></td>');
    htp.p('<td rowspan=4 bgcolor="'||l_toolbar_color||'"><font size=+3>'||'&'||'nbsp;</td>');
    htp.p('<td bgcolor="'||l_toolbar_color||'" nowrap><font face="Arial"><font size=+2 color='||l_heading_color||'><B>'||l_text||'</B></td>');

    icx_util.getprompts(601, 'ICX_OBIS_TOOLBAR', c_title, c_prompts);

    htp.p('<td rowspan=4 width=10000 bgcolor="'||l_toolbar_color||'" align=right>');
/*
** inner table for icons
*/
    htp.p('<table border=0 cellspacing=0 cellpadding=0>');
    htp.tableRowOpen(calign => 'CENTER');

    if (p_disp_wizard = 'Y') then
        htp.tableData(htf.anchor('javascript:doWizard()',
                htf.img('/OA_MEDIA/FNDWIZ.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(1)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(1))||
                        ''';return true"'));
    end if;

    if (p_disp_export is not null) then
        htp.p('<TD WIDTH=10></TD>');
        htp.p('<FORM ACTION="OracleON.csv" METHOD="POST" NAME="exportON">');
        htp.formHidden('S',icx_call.encrypt2(p_disp_export));
        htp.p('</FORM>');
        htp.tableData(htf.anchor('javascript:document.exportON.submit()',
                htf.img('/OA_MEDIA/FNDEXP.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(6)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(6))||
                        ''';return true"'));
    end if;

    if (p_disp_find is not null) then
        htp.p('<TD WIDTH=10></TD>');
        htp.tableData(htf.anchor(p_disp_find,
                htf.img('/OA_MEDIA/FNDFIND.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(2)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(2))||
                        ''';return true"'));
    end if;

    htp.p('<TD WIDTH=50></TD>');

    if (p_disp_menu = 'Y' and l_session_mode <> 'SLAVE') then
      if icx_sec.g_function_type = 'WWK' then
        l_menu := 'javascript:window.close();';
      else
        l_menu := 'javascript:top.location.href = ''OracleNavigate.Responsibility?P='||icx_sec.g_responsibility_id||''';';
      end if;
        htp.tableData(htf.anchor(l_menu,
                htf.img('/OA_MEDIA/FNDMENU.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(7)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(7))
                        ||''';return true" TARGET="_top"'));
    end if;

    if (p_disp_mainmenu = 'Y' and l_session_mode <> 'SLAVE') then
      if icx_sec.g_function_type = 'WWK' then
        l_menu := 'javascript:parent.opener.location.href = ''/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?dbHost='||l_host_instance||'&'||'agent='||l_agent||''';window.close();';
      else
        l_menu := 'javascript:top.location.href = ''/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?dbHost='||l_host_instance||'&'||'agent='||l_agent||''';';
      end if;
        htp.tableData(htf.anchor(l_menu,
                htf.img('/OA_MEDIA/FNDHOME.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(3)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(3))
                        ||''';return true" TARGET="_top"'));
    end if;


    if (p_disp_exit = 'Y' and l_session_mode <> 'SLAVE') then
        htp.p('<TD WIDTH=10></TD>');
        htp.tableData(htf.anchor('icx_admin_sig.Startover',
                htf.img('/OA_MEDIA/FNDEXIT.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(4)),'','
                        BORDER=0 width=30 height=30'),'','
                        onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(4)) ||
                        ''';return true"'));
    end if;

    if (p_disp_help = 'Y') then
        htp.p('<TD WIDTH=10></TD>');
        htp.tableData(htf.anchor('javascript:help_window()',
                htf.img('/OA_MEDIA/FNDHELP.gif',
                        'CENTER',
                        icx_util.replace_alt_quotes(c_prompts(5)),'',
                        'BORDER=0 width=30 height=30'),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(5))||
                        ''';return true"'));
    end if;

    htp.tableRowClose;
    htp.tableClose;
    htp.p('</TD>');
/**
** close outer row and table
*/

   htp.p('<td rowspan=4><img src="/OA_MEDIA/FND'||l_color_scheme||'BRT.gif" width=35 height=46></td>');
   if p_text is null
   then
     htp.p('<tr><td bgcolor="'||l_toolbar_color||'" height=1><img src="/OA_MEDIA/FNDINVDT.gif" width=1 height=1></td></tr>');
     htp.p('<tr><td bgcolor="'||l_toolbar_color||'" height=2><img src="/OA_MEDIA/FNDINVDT.gif" width=1 height=2></td></tr>');
     htp.p('<tr><td bgcolor="'||l_toolbar_color||'" height=4><img src="/OA_MEDIA/FNDINVDT.gif" width=1 height=4></td></tr>');
   else
     htp.p('<tr><td bgcolor="'||l_heading_color||'" height=1><img src="/OA_MEDIA/FNDINVDT.gif" width=1 height=1></td></tr>');
     htp.p('<tr><td bgcolor=#000000 height=2><img src="/OA_MEDIA/FNDBLKDT.gif" width=1 height=2></td></tr>');
     htp.p('<tr><td bgcolor="'||l_toolbar_color||'" height=4><img src="/OA_MEDIA/FND'||l_color_scheme||'BDT.gif" width=1 height=4></td></tr>');
   end if;
   htp.p('</table><p>');
  end if; -- 115

end toolbar;

procedure buttonLeft(p_text in varchar2,
                     p_url  in varchar2,
                     p_icon in varchar2 default NULL) is

l_media varchar2(80);
l_onMouseOver varchar2(240);

begin

l_media := '/OA_MEDIA/';
l_onMouseOver := 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(p_text)||''';return true"';

htp.p('<TABLE border=0 cellpadding=0 cellspacing=0 align=right>
<TR><TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRL.gif" height=22 width=15 border=0></A></TD>
<TD height=1 bgcolor=#FFFFFF colspan=2><IMG src="'||l_media||'FNDINVDT.gif" height=1 width=1></TD>
<TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFSR.gif" height=22 width=11 border=0></A></TD></TR>');

if p_icon is not null
then
    htp.p('<TR><TD height=20 bgcolor=#cccccc><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||p_icon||'" border=0></A></TD>');
    htp.p('<TD height=20 align=center valign=center bgcolor=#cccccc nowrap><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>');
else
    htp.p('<TD height=20 align=center valign=center bgcolor=#cccccc nowrap colspan=2><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>');
end if;

htp.p('<TR><TD height=1 bgcolor=000000 colspan=2><IMG src="'||l_media||'FNDINVDT.gif" width=1 height=1></TD></TR>
</TABLE>');

end;

procedure buttonRight(p_text in varchar2,
                      p_url  in varchar2,
                      p_icon in varchar2 default NULL) is

l_media varchar2(80);
l_onMouseOver varchar2(240);

begin

l_media := '/OA_MEDIA/';
l_onMouseOver := 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(p_text)||''';return true"';

htp.p('<TABLE border=0 cellpadding=0 cellspacing=0 align=left>
<TR><TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFSL.gif" height=22 width=11 border=0></A></TD>
<TD height=1 bgcolor=#FFFFFF colspan=2><IMG src="'||l_media||'FNDINVDT.gif" height=1 width=1></TD>
<TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRR.gif" height=22 width=15 border=0></A></TD></TR>');

if p_icon is not null
then
    htp.p('<TR><TD height=20 bgcolor=#cccccc><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||p_icon||'" border=0></A></TD>');
    htp.p('<TD height=20 align=center valign=center bgcolor=#cccccc nowrap><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>');
else
    htp.p('<TD height=20 align=center valign=center bgcolor=#cccccc nowrap colspan=2><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>');
end if;

htp.p('<TR><TD height=1 bgcolor=000000 colspan=2><IMG src="'||l_media||'FNDINVDT.gif" width=1 height=1></TD></TR>
</TABLE>');

end;

procedure buttonBoth(p_text in varchar2,
                     p_url  in varchar2,
                     p_icon in varchar2 default NULL) is

l_media varchar2(80);
l_onMouseOver varchar2(240);

begin

l_media := '/OA_MEDIA/';
l_onMouseOver := 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(p_text)||''';return true"';

htp.p('<TABLE border=0 cellpadding=0 cellspacing=0 align=left>');
if p_icon is not null
then

htp.p('<TR><TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRL.gif" height=22 width=15 border=0 ></A></TD>
<TD height=1 bgcolor=#FFFFFF colspan=2><IMG src="'||l_media||'FNDINVDT.gif" height=1 width=1></TD>
<TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRR.gif" height=22 width=15 border=0></A></TD></TR>
<TR><TD height=20 bgcolor=#cccccc><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||p_icon||'" border=0></A></TD>
<TD height=20 align=center valign=center bgcolor=#cccccc nowrap><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>
<TR><TD height=1 bgcolor=000000 colspan=2><IMG src="'||l_media||'FNDINVDT.gif" width=1 height=1></TD></TR>');

else

htp.p('<TR><TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRL.gif" height=22 width=15 border=0></A></TD>
<TD height=1 bgcolor=#FFFFFF><IMG src="'||l_media||'FNDINVDT.gif" height=1 width=1></TD>
<TD height=22 rowspan=3><A href="'||p_url||'" '||l_onMouseOver||'><IMG src="'||l_media||'FNDJLFRR.gif" height=22 width=15 border=0></A></TD></TR>
<TD height=20 align=center valign=center bgcolor=#cccccc nowrap><A href="'||p_url||'" style="text-decoration:none" '||l_onMouseOver||'><FONT size=2 face="Arial,Helvetica,Geneva"  color=000000>'||p_text||'</FONT></A></TD></TR>
<TR><TD height=1 bgcolor=000000><IMG src="'||l_media||'FNDINVDT.gif" width=1 height=1></TD></TR>');

end if;
htp.p('</TABLE>');

end;

end icx_plug_utilities;

/
