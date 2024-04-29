--------------------------------------------------------
--  DDL for Package Body ORACLENAVIGATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLENAVIGATE" as
/* $Header: ICXSENB.pls 120.2 2007/11/21 19:24:40 amgonzal ship $ */

TYPE object IS RECORD (
        location           varchar2(30),
        display_sequence   pls_integer,
        type               varchar2(30),
        resp_appl_id       pls_integer,
        responsibility_id  pls_integer,
        security_group_id  pls_integer,
        parent_menu_id     pls_integer,
        entry_sequence     pls_integer,
        menu_id            pls_integer,
        function_id        pls_integer,
        function_type      varchar2(30),
        menu_explode       varchar2(30),
        function_explode   varchar2(30),
        level              pls_integer,
        prompt             varchar2(240),
        description        varchar2(240),
        web_html_call      varchar2(240));

TYPE objectTable IS TABLE OF object index by binary_integer;

g_nulllist       objectTable;
g_list           objectTable;
g_executablelist objectTable;

procedure timer(message VARCHAR2) is     --defaulted to NULL, removed for GSCC
l_hsecs pls_integer;
begin
    select HSECS into l_hsecs from V$TIMER;
    htp.p('DEBUG ('||l_hsecs||') '||message);htp.nl;
end;

function security_group(p_responsibility_id number,
                        p_application_id number) return boolean is
l_security_group_count pls_integer;
l_security_group varchar2(30);
l_profile_defined BOOLEAN;

begin

/*
    select count(*)
    into   l_security_group_count
    from   fnd_security_groups
    where  security_group_id >= 0;
*/
    --l_security_group := fnd_profile.value('ENABLE_SECURITY_GROUPS');

    fnd_profile.get_specific(
                name_z                  => 'ENABLE_SECURITY_GROUPS',
                responsibility_id_z     => p_responsibility_id,
		application_id_z	=> p_application_id,
                val_z                   => l_security_group,
                defined_z               => l_profile_defined);

    if l_security_group = 'Y'
    then
      return TRUE;
    else
      return FALSE;
    end if;

end;

--  ***********************************************
--      Procedure listMenuEntries
--  ***********************************************
procedure listMenuEntries(p_object in object,
			  p_entries in BOOLEAN,                      --defaulted to true, removed for GSCC
			  p_executable in BOOLEAN) is  --defaulted to false, removed for GSCC

l_index         pls_integer;
l_object        object;
l_count		pls_integer;
c_error_msg     varchar2(240);

cursor  menuentries is
select  prompt,
        description,
        sub_menu_id,
	entry_sequence
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	sub_menu_id is not null
and     function_id is null
and     prompt is not null
  AND nvl(SUB_MENU_ID,-1) not IN -- add support for submenu exclusions 2029055
             (select ACTION_ID
              from   FND_RESP_FUNCTIONS
              where  RESPONSIBILITY_ID = p_object.responsibility_id
              and    APPLICATION_ID    = p_object.resp_appl_id)
order by entry_sequence;

cursor  functionentries is  --mputman removed nvl() 1911095
SELECT  b.prompt prompt,    --mputman removed nvl() 1911095
        nvl(b.description,b.prompt) description,
        b.function_id,
        b.entry_sequence,
	a.type,
        a.web_html_call
from    fnd_form_functions_vl a,
	fnd_menu_entries_vl b
where   b.menu_id = p_object.parent_menu_id
AND b.prompt IS NOT NULL -- mputman added 1815466
--AND b.grant_flag='Y'
--removed grant_flag bug 3575253
and	a.function_id = b.function_id
and     a.type in ('WWW','WWK','SERVLET','JSP','FORM','INTEROPJSP')
and    nvl(a.FUNCTION_ID,-1) not in   -- menu exclusion support 1911095 mputman
             (select ACTION_ID
              from   FND_RESP_FUNCTIONS
              where  RESPONSIBILITY_ID = p_object.responsibility_id
              and    APPLICATION_ID    = p_object.resp_appl_id)
order by entry_sequence;


begin

-- Bug 3575253 - Added the below to use fnd_function_id.test_id

   if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
       FND_FUNCTION.FAST_COMPILE;
    end if;



    fnd_global.apps_initialize(icx_sec.g_user_id,
                               p_object.responsibility_id,
                               p_object.resp_appl_id,
                               p_object.security_group_id);

-- Bug 3575253

if not p_executable
and (p_object.function_explode = 'Y' or (p_entries and p_object.level = 1))
then

  select  count(*)
  into    l_count
  from    fnd_form_functions a,
          fnd_menu_entries b
  where   b.menu_id = p_object.parent_menu_id
  and     a.function_id = b.function_id
  and     a.type in ('WWW','WWK','SERVLET','JSP','FORM','INTEROPJSP')
--AND b.grant_flag='Y'
--removed grant_flag bug 3575253

and    nvl(a.FUNCTION_ID,-1) not in   -- menu exclusion support 1911095 mputman
             (select ACTION_ID
              from   FND_RESP_FUNCTIONS
              where  RESPONSIBILITY_ID = p_object.responsibility_id
              and    APPLICATION_ID    = p_object.resp_appl_id);

  if l_count > 0
  then
   if p_object.level = 1
   then
    l_index := g_list.COUNT;
    g_list(l_index).type := 'MENU';
    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
    g_list(l_index).responsibility_id := p_object.responsibility_id;
    g_list(l_index).security_group_id := p_object.security_group_id;
    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
    g_list(l_index).entry_sequence := 0;
    g_list(l_index).level := p_object.level;
    g_list(l_index).prompt := p_object.prompt;
    g_list(l_index).description := p_object.description;
   end if;

   for f in functionentries loop
        l_index := g_list.COUNT;
	g_list(l_index).type := 'FUNCTION';
        g_list(l_index).resp_appl_id := p_object.resp_appl_id;
        g_list(l_index).responsibility_id := p_object.responsibility_id;
        g_list(l_index).security_group_id := p_object.security_group_id;
        g_list(l_index).parent_menu_id := p_object.parent_menu_id;
        g_list(l_index).entry_sequence := f.entry_sequence;
	g_list(l_index).function_id := f.function_id;
        g_list(l_index).function_type := f.type;
        g_list(l_index).web_html_call := f.web_html_call;
        g_list(l_index).level := p_object.level;


--Bug 3575253 used fnd_function_test_id

    if (f.prompt is not null) and (fnd_function.test_id(f.function_id))
        then
            g_list(l_index).prompt := f.prompt;
    if (f.description is not null) and (fnd_function.test_id(f.function_id))
               then
                g_list(l_index).description := f.description;

        else if (fnd_function.test_id(f.function_id))
               then

                g_list(l_index).description := f.prompt;

         else if (fnd_function.test_id(f.function_id))

           then

              g_list(l_index).prompt := f.description;

              g_list(l_index).description := f.description;
           end if;
end if;


 end if;

/*
        if f.prompt is not null
        then
            g_list(l_index).prompt := f.prompt;
            if f.description is not null
            then
                g_list(l_index).description := f.description;
            else
                g_list(l_index).description := f.prompt;
            end if;
        else
            g_list(l_index).prompt := f.description;
            g_list(l_index).description := f.description;
*/

        end if;
    end loop; -- menuentries
  end if;
end if;

select  count(*)
into    l_count
from    fnd_menu_entries
where   menu_id = p_object.parent_menu_id
and     sub_menu_id is not null;

if l_count > 0
then
  for m in menuentries loop
    l_index := g_list.COUNT;
    g_list(l_index).type := 'MENU';
    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
    g_list(l_index).responsibility_id := p_object.responsibility_id;
    g_list(l_index).security_group_id := p_object.security_group_id;
    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
    g_list(l_index).entry_sequence := m.entry_sequence;
    g_list(l_index).level := p_object.level;
    g_list(l_index).prompt := m.prompt;
    g_list(l_index).description := m.description;
    if p_object.menu_explode = 'Y'
    then
        l_object.resp_appl_id := p_object.resp_appl_id;
        l_object.responsibility_id := p_object.responsibility_id;
        l_object.security_group_id := p_object.security_group_id;
        l_object.parent_menu_id := m.sub_menu_id;
        l_object.menu_explode := p_object.menu_explode;
        l_object.function_explode := p_object.function_explode;
        l_object.level := p_object.level+1;
        l_object.prompt := p_object.prompt;
        l_object.description := p_object.description;
        listMenuEntries(p_object =>l_object,
                        p_entries => p_entries,
                        p_executable => p_executable);
    end if;
  end loop; -- menuentries
end if;

exception
    when others then
--        htp.p(SQLERRM);
   fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
   c_error_msg := fnd_message.get;
   htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure listMenu(p_object in object,
		   p_entries in BOOLEAN) is
l_prompt		varchar2(240);
l_description           varchar2(240);
l_sub_menu_id               pls_integer;
l_index                 pls_integer;
l_object		object;
c_error_msg             varchar2(240);

begin

select  prompt,
        description,
        sub_menu_id
into	l_prompt,
	l_description,
	l_sub_menu_id
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	entry_sequence = p_object.entry_sequence
order by entry_sequence;

l_index := g_list.COUNT;
g_list(l_index).location := p_object.location;
g_list(l_index).display_sequence := p_object.display_sequence;
g_list(l_index).type := 'MENU';
g_list(l_index).responsibility_id := p_object.responsibility_id;
g_list(l_index).parent_menu_id := p_object.parent_menu_id;
g_list(l_index).entry_sequence := p_object.entry_sequence;
g_list(l_index).menu_explode := p_object.menu_explode;
g_list(l_index).function_explode := p_object.function_explode;
g_list(l_index).level := p_object.level;

if l_prompt is not null
then
    g_list(l_index).prompt := l_prompt;
    if l_description is not null
    then
        g_list(l_index).description := l_description;
    else
        g_list(l_index).description := l_prompt;
    end if;
else
    g_list(l_index).prompt := l_description;
    g_list(l_index).description := l_description;
end if;

l_object.responsibility_id := p_object.responsibility_id;
l_object.parent_menu_id := l_sub_menu_id;
l_object.menu_explode := p_object.menu_explode;
l_object.function_explode := p_object.function_explode;
l_object.level := p_object.level+1;
listMenuEntries(p_object => l_object,
		          p_entries => p_entries,
                p_executable => FALSE); -- pass in defaults (GSCC)

exception
    when others then
--        htp.p(SQLERRM);
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      c_error_msg := fnd_message.get;
      htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);



end;

--  ***********************************************
--      Procedure listResponsibility
--  ***********************************************
procedure listResponsibility(p_object in object,
			     p_entries  in BOOLEAN,             --defaulted to true, removed for GSCC
		             p_executable in BOOLEAN) is  --defaulted to fales, removed for GSCC

l_responsibility_name	varchar2(100);
l_description		varchar2(240);
l_menu_id		pls_integer;
l_index         	pls_integer;
l_object		object;
c_error_msg             varchar2(240);

begin

-- 1584809 nlbarlow, add application_id
select  responsibility_name,
        description,
        menu_id
into    l_responsibility_name,
        l_description,
        l_menu_id
from    fnd_responsibility_vl
where   application_id = p_object.resp_appl_id
and     responsibility_id = p_object.responsibility_id
and     version in ('4','W')
and     start_date <= sysdate
and     (end_date is null or end_date > sysdate);

l_index := g_list.COUNT;
g_list(l_index).location := p_object.location;
g_list(l_index).display_sequence := p_object.display_sequence;
g_list(l_index).type := 'RESPONSIBILITY';
g_list(l_index).resp_appl_id := p_object.resp_appl_id;
g_list(l_index).responsibility_id := p_object.responsibility_id;
g_list(l_index).security_group_id := p_object.security_group_id;
g_list(l_index).prompt := l_responsibility_name;
g_list(l_index).description := l_description;
g_list(l_index).menu_explode := p_object.menu_explode;
g_list(l_index).function_explode := p_object.function_explode;
g_list(l_index).level := p_object.level;

if p_object.menu_explode = 'Y'
or (p_entries and p_object.level = 0)
then
    l_object.resp_appl_id := p_object.resp_appl_id;
    l_object.responsibility_id := p_object.responsibility_id;
    l_object.security_group_id := p_object.security_group_id;
    l_object.parent_menu_id := l_menu_id;
    l_object.menu_explode := p_object.menu_explode;
    l_object.function_explode := p_object.function_explode;
    l_object.level := p_object.level+1;
    l_object.prompt := p_object.prompt;
    l_object.description := p_object.description;
    listMenuEntries(p_object =>l_object,
		    p_entries => p_entries,
		    p_executable => p_executable);-- pass in defaults (GSCC)
end if;

exception
    when others then
--        htp.p(SQLERRM);
       fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_error_msg := fnd_message.get;
       htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure displayUnderConstruction is

l_title varchar2(80);
l_name varchar2(80);

begin

    htp.p('<html>');
    htp.p('<head>');

    htp.p('<title>'||l_title||'</title>');

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('var function_window = new Object();');
    htp.p('function_window.open = false;');

    htp.p('function icx_nav_window(mode, url, name){
          if (mode == "WWK" || mode =="FORM") {
            attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
            function_window.win = window.open(url, "function_window", attributes);
            if (function_window.win != null)
              if (function_window.win.opener == null)
                function_window.win.opener = self;
            function_window.win.focus();
            }
          else {
            top.location = url;
            };
        };');

    htp.p('function topwindowfocus() {
            if (document.functionwindowfocus.X.value == "TRUE") {
               function_window.win.focus();
            }
          };');

    icx_admin_sig.help_win_script('ICXPHP', null, 'FND');

    htp.p('</SCRIPT>');

    htp.p('</head>');
--    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onfocus="topwindowfocus()">');
    htp.p('<body bgcolor= #FFFFFF onfocus="topwindowfocus()">');

    htp.formOpen(curl => 'XXX',
               cattributes => 'NAME="functionwindowfocus"');
    htp.formHidden('X','FALSE');
    htp.formClose;

    icx_plug_utilities.toolbar(p_text => l_title,
                               p_language_code => icx_sec.g_language_code,
                               p_disp_help => 'Y',
                               p_disp_exit => 'Y',
                               p_disp_menu => 'N');

    htp.p('<!- Outer table ->');
    htp.p('<table  border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr>');
    htp.p('<!- Left Column ->');
    htp.p('<td valign=top align=left width="1%"> This feature is not available yet.');
    htp.p('</td></tr>');
    htp.p('</table>'); -- outer table
    htp.p('</html>');

end;


-- ************************************************************
--           Responsibility
-- ************************************************************

procedure Responsibility(P                in pls_integer,
                         D                in varchar2,
                         S                in pls_integer,
                         M                in pls_integer,
                         tab_context_flag in varchar2) is
   --P = responsibility
   --D = plug name
   --S = security group
   --M = menu id - defaults to 9999


l_resp_appl_id			number;
l_responsibility_id		number;
l_responsibility_name		varchar2(240);
l_responsibility_description	varchar2(240);
l_security_group_id	        number;
l_security_group_name		varchar2(80);
l_object			object;
l_message			varchar2(2000);
l_title				varchar2(80);
l_name				varchar2(80);
l_toolbar_color			varchar2(30);
l_url				varchar2(4000);
l_target			varchar2(30);
l_agent				varchar2(80);
l_page_id			number;
l_session_id			number;
l_menu_id                       number;
l_prompts		icx_util.g_prompts_table;
l_title2				varchar2(80);
l_function_id      NUMBER;
l_menu_type        VARCHAR2(50);

c_error_msg             varchar2(240);

--Modified this cursor to join to menus 2314636  --mputman
cursor responsibilities is
select distinct b.RESPONSIBILITY_APPLICATION_ID,
        a.RESPONSIBILITY_ID,
        b.SECURITY_GROUP_ID,
        a.RESPONSIBILITY_NAME,
        a.DESCRIPTION,
        fsg.SECURITY_GROUP_NAME,
        m.TYPE,
        m.menu_id
from    FND_SECURITY_GROUPS_VL fsg,
        FND_RESPONSIBILITY_VL a,
        FND_USER_RESP_GROUPS b,
        fnd_menus m
where   b.user_id = icx_sec.g_user_id
AND     a.menu_id = m.menu_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version IN ('W')
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
AND b.SECURITY_GROUP_ID IN (-1, fsg.SECURITY_GROUP_ID)
AND fsg.SECURITY_GROUP_ID >= 0
AND nvl(FND_PROFILE.VALUE('NODE_TRUST_LEVEL'),1) <=
nvl(FND_PROFILE.VALUE_SPECIFIC('APPL_SERVER_TRUST_LEVEL',b.USER_ID,a.RESPONSIBILITY_ID,b.RESPONSIBILITY_APPLICATION_ID),1)
ORDER BY a.RESPONSIBILITY_NAME, fsg.SECURITY_GROUP_NAME;

begin

if icx_sec.validateSession
then

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

elsif fnd_profile.value('APPLICATIONS_HOME_PAGE') = 'PHP_FWK'
then
    select FUNCTION_ID
    into   l_function_id
    from   FND_FORM_FUNCTIONS
    where  FUNCTION_NAME = 'FND_NAVIGATE_PAGE';

    l_url := icx_portlet.createExecLink
                (p_application_id => nvl(icx_sec.g_resp_appl_id,'-1'),
                 p_responsibility_id => nvl(icx_sec.g_responsibility_id,'-1'),
                 p_security_group_id => nvl(icx_sec.g_security_group_id,'0'),
                 p_function_id => l_function_id,
                 p_url_only => 'Y');

    owa_util.mime_header('text/html', FALSE);
    owa_util.redirect_url(l_url);
    owa_util.http_header_close;

elsif (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE') and
    tab_context_flag = 'ON') then

    OracleMyPage.DrawTabContent;

else -- PHP

    l_title := icx_util.getPrompt(601,'ICX_OBIS_NAVIGATE',178,'ICX_MAIN_MENU');
    l_toolbar_color := icx_plug_utilities.toolbarcolor;

    /*
    ** The agent must have the web server in front of it to ensure
    ** it works in ie javascript.  The problem is if your running the
    ** old style OBIS mode, you'll get an extra slash from
    ** icx_plug_utilities.getPLSQLagent.  Will remove here.
    */
    if (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then

       l_agent := FND_WEB_CONFIG.WEB_SERVER||
                  substr(icx_plug_utilities.getPLSQLagent,2);

    else

       l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

    end if;


    if P is null
    then

      l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
      if NVL(l_responsibility_id, -1) = -1
      then
        open responsibilities;
        fetch responsibilities into l_resp_appl_id,
                                    l_responsibility_id,
                                    l_security_group_id,
                                    l_responsibility_name,
                                    l_responsibility_description,
                                    l_security_group_name,
                                    l_menu_type,
                                    l_menu_id;
        close responsibilities;
         l_menu_id := NULL;
         l_menu_type := NULL;
      end if;
    else
        l_responsibility_id := icx_call.decrypt2(P);
    end if;

    /* ensure that menu is set to a not null value so that Main Menu icon
       is painted only for functions called from the Navigate plug. */
    if M is null then
       l_menu_id := 9999;
    else
       l_menu_id := M;
    end if;

    if (D is null) then
       -- check to see if need to get page for new style or old style page.
       if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then

          l_session_id := icx_sec.getsessioncookie;

          select page_id into l_page_id
            from icx_sessions
           where session_id = l_session_id;

          -- see if display name is associated with navigate plug with a value of -1
          begin
              select display_name
		into l_name
		from icx_page_plugs a,
		     icx_pages b
	       where b.user_id = icx_sec.g_user_id
		 and b.page_id = a.page_id
		 and a.page_id = l_page_id
		 and a.responsibility_id = -1
		 and a.menu_id = -1;
          exception
               when no_data_found then
                    l_name := null;
          end;

          if (l_name is null) then
             -- display_name is associated with a non -1 navigate plug
             -- also since there could be more than one such plug on a page
             -- use select distinct so only one row is returned.  This may
             -- return the incorrect name but we can't help that because
             -- currently there is no way for us to know what navigate plug
             -- to return to.

             begin
   	       select distinct NVL(ipp.DISPLAY_NAME, fme.prompt)
	         into l_name
	         from icx_page_plugs ipp,
		      fnd_menu_entries_vl fme,
		      fnd_form_functions fff
	        where ipp.page_id = l_page_id
		  and ipp.menu_id = fme.menu_id
		  and ipp.entry_sequence = fme.entry_sequence
		  and fff.function_id = fme.function_id
		  and fff.function_name = 'ICX_NAVIGATE_PLUG';
             exception
                when no_data_found then
                   l_name := null;
             end;

          end if;

       else -- need to return to the old style page

          begin
	     select DISPLAY_NAME
	       into l_name
	       from ICX_PAGE_PLUGS a,
		    ICX_PAGES b
	      where b.USER_ID = icx_sec.g_user_id
		and b.PAGE_ID = a.PAGE_ID
		and a.RESPONSIBILITY_ID = -1
		and a.MENU_ID = -1
		and b.page_id in (select MIN(page_id)
				    from ICX_PAGES
				   where user_id = icx_sec.g_user_id
				     and PAGE_TYPE = 'USER');
          exception
             when no_data_found then
                  l_name := null;
          end;

          if (l_name is null) then
             -- display_name is associated with a non -1 navigate plug
             -- also since there could be more than one such plug on a page
             -- use select distinct so only one row is returned.  This may
             -- return the incorrect name but we can't help that because
             -- currently there is no way for us to know what navigate plug
             -- to return to.

             begin
		select distinct NVL(ipp.DISPLAY_NAME, fme.prompt)
		  into l_name
		  from icx_page_plugs ipp,
		       fnd_menu_entries_vl fme,
		       fnd_form_functions fff
		 where ipp.menu_id = fme.menu_id
		   and ipp.entry_sequence = fme.entry_sequence
		   and fff.function_id = fme.function_id
		   and fff.function_name = 'ICX_NAVIGATE_PLUG'
		   and ipp.page_id in (select MIN(page_id)
					 from ICX_PAGES
					where user_id = icx_sec.g_user_id
					  and PAGE_TYPE = 'USER');
              exception
                  when no_data_found then
                       l_name := null;
              end;

          end if;

       end if; -- need to return to the old style page
    else
BEGIN
   SELECT display_name
      INTO l_name
      FROM icx_page_plugs
      WHERE plug_id= D;
EXCEPTION
   WHEN OTHERS THEN

      l_name :=D;
END;
       --l_name := D;
    end if;

IF l_name IS NULL THEN
  icx_util.getprompts(601, 'ICX_OBIS_NAVIGATE', l_title2, l_prompts);
  l_name:=l_prompts(1);
END IF;

    if S is null
    then
      l_security_group_id := icx_sec.g_security_group_id;
    else
      l_security_group_id := S;
    end if;

    if l_security_group_id is null
    then
      l_security_group_id := 0;
    end if;

    select b.RESPONSIBILITY_APPLICATION_ID,
           b.SECURITY_GROUP_ID,
           a.RESPONSIBILITY_NAME,
           a.DESCRIPTION,
           fsg.SECURITY_GROUP_NAME
    into   l_resp_appl_id,
           l_security_group_id,
           l_responsibility_name,
           l_responsibility_description,
           l_security_group_name
    from   FND_SECURITY_GROUPS_VL fsg,
           FND_RESPONSIBILITY_VL a,
           FND_USER_RESP_GROUPS b
    where  b.USER_ID = icx_sec.g_user_id
    and    a.APPLICATION_ID = b.RESPONSIBILITY_APPLICATION_ID
    and    a.RESPONSIBILITY_ID = b.RESPONSIBILITY_ID
    and    a.RESPONSIBILITY_ID = l_responsibility_id
    and    b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
    and    fsg.SECURITY_GROUP_ID = l_security_group_id;

    g_list := g_nulllist;

    l_object.type := 'RESPONSIBILITY';
    l_object.resp_appl_id := l_resp_appl_id;
    l_object.responsibility_id := l_responsibility_id;
    l_object.security_group_id := l_security_group_id;
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;

    if security_group(l_responsibility_id, l_resp_appl_id)
    then
      l_object.prompt := l_responsibility_name||', '||l_security_group_name;
    else
      l_object.prompt := l_responsibility_name;
    end if;
    l_object.description := l_responsibility_description;

    listResponsibility(p_object => l_object,
		          p_entries => TRUE,
                p_executable => FALSE); -- pass in defaults (GSCC)

    htp.p('<html>');
    if icx_cabo.g_base_href is null
    then
      htp.p('<BASE HREF="'||FND_WEB_CONFIG.WEB_SERVER||'">');
    else
--      htp.p('<SCRIPT LANGUAGE="JavaScript">
--              base.href="'||icx_cabo.g_base_href||'"
--             </SCRIPT>');
      htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');
    end if;
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('var function_window = new Object();');
    htp.p('var counter=0;'); -- add support for unique window names 1812147
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
             if (mode == "WWK" || mode =="FORM") {
               attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
               function_window.win = window.open(url, "function_window"+counter_hostname, attributes);
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
          if (mode == "WWK" || mode =="FORM") {
            attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
            function_window.win = window.open(url, "function_window", attributes);
            if (function_window.win != null)
              if (function_window.win.opener == null)
                function_window.win.opener = self;
            function_window.win.focus();
            }
          else {
            top.location = url;
            };
        };');

   htp.p('function topwindowfocus() {
            if (document.functionwindowfocus.X.value == "TRUE") {
               function_window.win.focus();
            }
          };');

    icx_admin_sig.help_win_script('ICXPHP', null, 'FND');

    htp.p('</SCRIPT>');

    htp.p('</head>');

    if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
        htp.p('<body bgcolor="#CCCCCC" onfocus="topwindowfocus()">');
    else
        htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onfocus="topwindowfocus()">');
    end if;

--  Needed for RF.jsp
--  htp.p(FND_RUN_FUNCTION.GET_FORMS_LAUNCHER_SETUP);

    htp.formOpen(curl => 'XXX',
               cattributes => 'NAME="functionwindowfocus"');
    htp.formHidden('X','FALSE');
    htp.formClose;

    if ( substr(icx_sec.g_mode_code,1,3) = '115' or
         icx_sec.g_mode_code = 'SLAVE')
    then
      l_target := '_self';
    else
      l_target := '_top';

    icx_plug_utilities.toolbar(p_text => l_title,
                               p_language_code => icx_sec.g_language_code,
                               p_disp_help => 'Y',
                               p_disp_exit => 'Y',
                               p_disp_menu => 'N');
    end if;

    htp.p('<!- Outer table ->');
    htp.p('<table  border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr><td><img src="/OA_MEDIA/FNDINVDT.gif" width=8 height=12></td>');

    htp.p('<!- Left Column ->');

    htp.p('<td valign=top align=left width="1%">');
    htp.p('<table  border=0 cellspacing=0 cellpadding=0><tr><td>');
    icx_plug_utilities.banner(l_name);
    htp.p('</td></tr>');
    htp.p('<tr><td><font size=-2><BR></font></td></tr>');
    htp.p('<tr><td>');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 valign=top align=left>');
    for r in responsibilities loop

    if security_group  (r.responsibility_id, r.responsibility_application_id)
    then
      l_responsibility_name := r.responsibility_name||', '||r.security_group_name;
    else
      l_responsibility_name := r.responsibility_name;
    end if;

    if l_responsibility_id = r.responsibility_id and
       l_security_group_id = r.security_group_id
    then

    htp.p('<tr>');
    htp.p('<td>');
    htp.p('<image src="/OA_MEDIA/FNDREDPT.gif" alt="'||icx_util.replace_alt_quotes(r.description)||'">');
    htp.p('</td>');
    htp.p('<td valign=middle NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||l_responsibility_name||'</td></tr>');
    htp.p('</tr>');

    else

    htp.p('<tr>');
    htp.p('<td></td>');
    htp.p('<td NOWRAP><font face="Arial" size=2><b>');
    --Put IF logic here for bug 2314636 --mputman
    IF r.TYPE = 'HOMEPAGE' THEN
         BEGIN
           SELECT function_id
             INTO l_function_id
             FROM fnd_menu_entries_vl
             WHERE menu_id=r.menu_id
             AND FUNCTION_ID is not null
             AND ROWNUM=1
             ORDER BY entry_sequence;
         END;

      l_url := icx_portlet.createExecLink
               (p_application_id => r.responsibility_application_id,
                p_responsibility_id => r.responsibility_id,
                p_security_group_id => r.security_group_id,
                p_function_id => l_function_id,
                p_link_name => l_responsibility_name,
                p_url_only => 'N');

     htp.p(l_url);

    ELSE
      htp.anchor(curl => l_agent||'OracleNavigate.Responsibility?P='||icx_call.encrypt2(r.responsibility_id)||'&'||'D='||wfa_html.conv_special_url_chars(D)||'&'||'S='||r.security_group_id||'&'||'tab_context_flag=OFF',
                 ctext => l_responsibility_name,
                 cattributes => 'TARGET="'||l_target||'" onMouseOver="window.status='''||icx_util.replace_quotes(r.description)||''';return true"');
    END IF;
    htp.p('</td>');
    htp.p('</tr>');

    end if; -- P = r.responsibility_id

    end loop;

    htp.p('<tr><td colspan=3><img src="/OA_MEDIA/FNDINVDT.gif" width=8 height=12></td></tr>');
    htp.p('</table>');

    htp.p('</td></tr></table>');

    htp.p('<!- Vertical Divider ->');
    htp.p('<td width="1"><img src="/OA_MEDIA/FNDINVDT.gif" width=8 height=12></td>');
    htp.p('<td width="1"><img src="/OA_MEDIA/FNDINVDT.gif" width=8 height=12></td>');
    htp.p('<td bgcolor="'||l_toolbar_color||'" width="1" cellpadding=0 cellspacing=0><img src="/OA_MEDIA/FNDINVDT.gif" width=1></td>');


    htp.p('<!- Right Column ->');
    htp.p('<td valign=top align=left width="99%">');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width="100%">');

    for i in 1..g_list.LAST loop -- functions

    if g_list(i).prompt is not null -- null prompt
    then
    if g_list(i).type = 'MENU' -- menu type
    then
     if g_list(i+1).type <> 'MENU'
     then
      htp.p('<tr>');
      htp.p('<td>');
      icx_plug_utilities.banner(g_list(i).prompt);
      htp.p('</td>');
      htp.p('</tr><tr><td><font size=-2><BR></font></td>');
      htp.p('</tr>');
     end if;


    else
      htp.p('<tr>');
      htp.p('<td align=left>');
      htp.p('&'||'nbsp<image src="/OA_MEDIA/FNDWATHS.gif" alt="'||icx_util.replace_alt_quotes(g_list(i).description)||'">');
      htp.p('<font face="Arial" size=2><b>');
      if substr(g_list(i).web_html_call,1,10) = 'javascript' -- javascript
      then
        l_url := replace(g_list(i).web_html_call,'"','''');
        l_url := replace(l_url,'[RESPONSIBILITY_ID]',g_list(i).responsibility_id);
        l_url := replace(l_url,'[PLSQL_AGENT]',icx_plug_utilities.getPLSQLagent);
        l_url := '<A HREF="'||l_url||'" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(g_list(i).description)||''';return true">'||g_list(i).prompt||'</b></font></A>';

        htp.p(l_url);

      else
        -- 2903730 nlbarlow
        if g_list(i).FUNCTION_TYPE = 'WWK'
        then
          l_url := icx_portlet.createExecLink
               (p_application_id => g_list(i).resp_appl_id,
                p_responsibility_id => g_list(i).responsibility_id,
                p_security_group_id => g_list(i).security_group_id,
                p_function_id => g_list(i).function_id,
                p_link_name => g_list(i).prompt,
                p_url_only => 'Y');

          l_url := 'javascript:top.main.icx_nav_window('''||g_list(i).FUNCTION_TYPE||''','''||l_url||''', '''||icx_util.replace_quotes(g_list(i).PROMPT)||''')';

          htp.anchor(curl => l_url,
               ctext => g_list(i).prompt,
               cattributes => 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(g_list(i).description)||''';return true"');

        else if g_list(i).FUNCTION_TYPE = 'WWW'  -- bug 3764537
		then

                  l_url := icx_portlet.createExecLink
                       (p_application_id => g_list(i).resp_appl_id,
                        p_responsibility_id => g_list(i).responsibility_id,
                        p_security_group_id => g_list(i).security_group_id,
                        p_function_id => g_list(i).function_id,
                        p_link_name => g_list(i).prompt,
                        p_url_only => 'N');
                  htp.p(l_url);

		-- end bug 3764537

		else
		  l_url := icx_portlet.createExecLink
		       (p_application_id => g_list(i).resp_appl_id,
			p_responsibility_id => g_list(i).responsibility_id,
			p_security_group_id => g_list(i).security_group_id,
			p_function_id => g_list(i).function_id,
			p_link_name => g_list(i).prompt,
			p_url_only => 'N',
			p_parameters=> 'OAFMID=' || to_char(g_list(i).parent_menu_id) || '&OAPB=_OAFMID' ); -- bug 3456465

		  htp.p(l_url);
		end if;
        end if;
/*
        if ( substr(icx_sec.g_mode_code,1,3) = '115' OR
             icx_sec.g_mode_code = 'SLAVE')
        then
           IF ((g_list(i).FUNCTION_TYPE = 'WWK') OR (g_list(i).FUNCTION_TYPE = 'FORM')) THEN
               l_url := 'javascript:top.main.icx_nav_window('''||g_list(i).FUNCTION_TYPE||''','''||l_url||''', '''||icx_util.replace_quotes(g_list(i).PROMPT)||''')';
           END IF;
        else
           IF ((g_list(i).FUNCTION_TYPE = 'WWK') OR (g_list(i).FUNCTION_TYPE = 'FORM')) THEN
              l_url := 'javascript:icx_nav_window('''||g_list(i).FUNCTION_TYPE||''','''||l_url||''', '''||icx_util.replace_quotes(g_list(i).PROMPT)||''')';
           END IF;
        end if;
*/
      end if;

/*
      IF ((g_list(i).FUNCTION_TYPE = 'WWK') OR (g_list(i).FUNCTION_TYPE = 'FORM')) THEN
      htp.anchor(curl => l_url,
               ctext => g_list(i).prompt,
               cattributes => 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(g_list(i).description)||''';return true"');
      ELSE
      htp.anchor2(curl => l_url,
               ctext => g_list(i).prompt,
               cattributes => 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(g_list(i).description)||''';return true"',
               ctarget => '_top');
      END IF;
*/


      htp.p('</td>');
      htp.p('</tr>');
      if i+1 = g_list.COUNT
      then
        htp.p('<tr><td><BR></td></tr>');

      else
        if g_list(i+1).type = 'MENU'
        then
          htp.p('<tr><td><BR></td></tr>');

        end if;
      end if;
    end if; -- menu type
    end if; -- null prompt
    end loop; -- functions


    htp.p('</table>');

    if l_url is null
     then

    fnd_message.set_name('FND','FND_APPSNAV_NO_AVAIL_APPS');
    c_error_msg := fnd_message.get;

    htp.p('<font size=-2></font>');
    htp.p('</b>');
    htp.p('<font face="Arial" size=2><b>'||c_error_msg);

else

    htp.p('</tr>');

    htp.p('</table>');

    --htp.p('<script>'||substr(l_url,12)||'</script>');--mputman debug
end if;  --icx_sec.validatesession

end if;  -- icx_sec.g_mode_code in ('115J', '115P');

--added end if;
end if;



exception
    when others then
--        htp.p(SQLERRM);
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      c_error_msg := fnd_message.get;
      htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);

end;


procedure Navigate(p_session_id pls_integer,
                   p_plug_id    pls_integer,
                   p_display_name  varchar2,
                   p_delete     VARCHAR2) is

l_object		object;
l_url			varchar2(4000);
l_title			varchar2(80);
l_php_mode		varchar2(30);
l_prompts		icx_util.g_prompts_table;
l_agent			varchar2(80);
l_responsibility_name   varchar2(240);
l_encrypted_session_id	varchar2(240);
l_target		varchar2(30);
l_function_id           NUMBER;
c_error_msg             varchar2(240);

cursor responsibilities_W is
select distinct a.responsibility_id,
        a.responsibility_name,
        a.description,
        a.responsibility_key,
        b.responsibility_application_id,
        fsg.SECURITY_GROUP_NAME,
        fsg.SECURITY_GROUP_ID,
        fsg.security_group_key,
        fa.application_short_name,
        m.menu_id,
        m.type,
        a.version
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b,
        FND_APPLICATION fa,
        FND_MENUS m
where   b.user_id = icx_sec.g_user_id
AND     m.menu_id = a.menu_id
and     version in ('4','W')
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.application_id = fa.application_id
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
AND b.SECURITY_GROUP_ID IN (-1, fsg.SECURITY_GROUP_ID)
AND fsg.SECURITY_GROUP_ID >= 0
AND nvl(FND_PROFILE.VALUE('NODE_TRUST_LEVEL'),1) <=
nvl(FND_PROFILE.VALUE_SPECIFIC('APPL_SERVER_TRUST_LEVEL',b.USER_ID,a.RESPONSIBILITY_ID,b.RESPONSIBILITY_APPLICATION_ID),1)
ORDER BY a.RESPONSIBILITY_NAME, fsg.SECURITY_GROUP_NAME;

begin

if p_delete = 'Y'
then
  l_agent := l_agent;
elsif icx_sec.validatePlugSession(p_plug_id,p_session_id)
then
    /*
    ** The agent must have the web server in front of it to ensure
    ** it works in ie javascript.  The problem is if your running the
    ** old style OBIS mode, you'll get an extra slash from
    ** icx_plug_utilities.getPLSQLagent.  Will remove here.
    */

    if (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then

       l_agent := FND_WEB_CONFIG.WEB_SERVER||
                  substr(icx_plug_utilities.getPLSQLagent,2);

    else

       l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

    end if;

    icx_util.getprompts(601, 'ICX_OBIS_NAVIGATE', l_title, l_prompts);

    l_php_mode := fnd_profile.value('APPLICATIONS_HOME_PAGE');

    if l_prompts.COUNT = 7 -- remove once seeddate available
    then
      l_prompts(6) := '';
      l_prompts(7) := '';
    end if;

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');
    htp.p('<tr><td>');
    icx_plug_utilities.plugbanner(nvl(p_display_name,l_prompts(1)),'','FNDNAVIG.gif');
    htp.p('</td></tr>');

    htp.p('<tr><td><font size=-2><BR></font></td></tr>');

    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');

    if ( substr(icx_sec.g_mode_code,1,3) = '115' OR
         icx_sec.g_mode_code = 'SLAVE')
    then
      l_target := '_self';
    else
      l_target := '_top';
    end if;

    for r in responsibilities_W loop

       if security_group(r.responsibility_id, r.responsibility_application_id)
       then
	 l_responsibility_name := r.responsibility_name||', '||r.security_group_name;
       else
	 l_responsibility_name := r.responsibility_name;
       end if;

       htp.p('<tr>');
       htp.p('<td align="left" valign="top" NOWRAP>');
       htp.p('<font face="Arial" size=2>');
    --Put IF logic here for bug 2314636 --mputman
       IF r.type='HOMEPAGE' THEN
         BEGIN
           SELECT function_id
             INTO l_function_id
             FROM fnd_menu_entries_vl
             WHERE menu_id=r.menu_id
             AND FUNCTION_ID is not null
             AND ROWNUM=1
             ORDER BY entry_sequence;
         END;

         if l_php_mode = 'PHP_FWK'
         then
           l_url := icx_portlet.createExecLink
               (p_application_id => r.responsibility_application_id,
                p_responsibility_id => r.responsibility_id,
                p_security_group_id => r.security_group_id,
                p_function_id => l_function_id,
                p_link_name => l_responsibility_name,
                p_url_only => 'N');

           htp.p('<image src="/OA_MEDIA/tree_document.gif" alt="'||icx_util.replace_alt_quotes(r.description)||'">');
           htp.p(l_url);
         else
           htp.p('<image src="/OA_MEDIA/FNDWATHS.gif" height=18 width=18 alt="'||icx_util.replace_alt_quotes(r.description)||'">');

           htp.anchor(curl => l_agent||'OracleSSWA.Execute?E='||icx_call.encrypt(r.responsibility_application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'*'||l_function_id||'**]'),
                      ctext => l_responsibility_name,cattributes => 'TARGET="_top" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(r.description)||''';return true"');
         end if;

       ELSE

         if l_php_mode = 'PHP_FWK'
         then
           select FUNCTION_ID
           into   l_function_id
           from   FND_FORM_FUNCTIONS
           where  FUNCTION_NAME = 'FND_NAVIGATE_PAGE';

           l_url := icx_portlet.createExecLink
               (p_application_id => r.responsibility_application_id,
                p_responsibility_id => r.responsibility_id,
                p_security_group_id => r.security_group_id,
                p_function_id => l_function_id,
                p_parameters => 'navRespId='||r.responsibility_id||'&'||'navRespAppId='||r.responsibility_application_id||'&'||'navSecGrpId='||r.security_group_id,
                p_link_name => l_responsibility_name,
                p_url_only => 'N');

           htp.p('<image src="/OA_MEDIA/tree_folder.gif" alt="'||icx_util.replace_alt_quotes(r.description)||'">');

           htp.p(l_url);

         elsif r.version = '4'
         then
           htp.p('<image src="/OA_MEDIA/FNDWATHS.gif" height=18 width=18 alt="'||icx_util.replace_alt_quotes(r.description)||'">');

           l_url := 'javascript:top.main.icx_nav_window2(''WWK'', '''||l_agent|| 'fnd_icx_launch.runforms?ICX_TICKET=&''';

           l_url := l_url||','''||wfa_html.conv_special_url_chars(r.application_short_name)
                         ||''','''||wfa_html.conv_special_url_chars(r.responsibility_key)
                         ||''','''||wfa_html.conv_special_url_chars(r.security_group_key)
                         ||''','''||icx_util.replace_quotes(l_responsibility_name)||''')';

           htp.anchor(curl => l_url,
               ctext => l_responsibility_name,
               cattributes => 'TARGET="_top" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(r.description)||''';return true"');

         else
           htp.p('<image src="/OA_MEDIA/FNDWATHS.gif" height=18 width=18 alt="'||icx_util.replace_alt_quotes(r.description)||'">');

           htp.anchor(curl => l_agent||'OracleNavigate.Responsibility?P='||icx_call.encrypt2(r.responsibility_id)||'&'||'D='||wfa_html.conv_special_url_chars(p_plug_id)||'&'||'S='||r.security_group_id||'&'||'tab_context_flag=OFF'||'&'||'M=
9999',
                      ctext => l_responsibility_name,
                      cattributes => 'TARGET="'||l_target||'" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(r.description)||''';return true"');
         end if;

       END IF;
       htp.p('</td></tr>');

    end loop;

    htp.p('</td></tr></table>');
    htp.p('</TABLE>');

end if;

exception
    when others then
--        htp.p(SQLERRM);
       fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_error_msg := fnd_message.get;
       htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure Favorites(p_session_id pls_integer,
                   p_plug_id    pls_integer,
                   p_display_name  varchar2,
                   p_delete     varchar2) is

l_object object;
l_url          varchar2(2000); --changed from 240 to 2000 bug#1333631, mputman
l_title        varchar2(100);
l_prompts      icx_util.g_prompts_table;
l_agent        varchar2(80);
c_error_msg    varchar2(240);

cursor Favorites is
    select RESPONSIBILITY_APPLICATION_ID,
           RESPONSIBILITY_ID,
           a.SECURITY_GROUP_ID,
           PROMPT,
           DESCRIPTION,
           a.FUNCTION_ID,
           FUNCTION_TYPE,
           URL,
           WEB_HTML_CALL
    from   FND_FORM_FUNCTIONS_VL b,
           ICX_CUSTOM_MENU_ENTRIES a
    where  USER_ID = icx_sec.g_user_id
    and    PLUG_ID = p_plug_id
    and    b.FUNCTION_ID(+) = a.FUNCTION_ID
    and    ( RESPONSIBILITY_ID in
           (select responsibility_id from
              icx_custom_menu_entries
            where USER_ID=icx_sec.g_user_id
            intersect
            select RESPONSIBILITY_ID from fnd_user_resp_groups where
              USER_ID=icx_sec.g_user_id
            and
              start_date <= sysdate
            and
              (end_date is null or end_date > sysdate)
            ) or responsibility_id=0)
            order by DISPLAY_SEQUENCE;
begin

if p_delete = 'Y'
then
  begin
    delete ICX_CUSTOM_MENU_ENTRIES
    where  USER_ID = icx_sec.g_user_id
    and    PLUG_ID = p_plug_id;
  exception
    when others then
      l_agent := l_agent;
  end;

elsif icx_sec.validatePlugSession(p_plug_id,p_session_id)
then
    /*
    ** The agent must have the web server in front of it to ensure
    ** it works in ie javascript.  The problem is if your running the
    ** old style OBIS mode, you'll get an extra slash from
    ** icx_plug_utilities.getPLSQLagent.  Will remove here.
    */
    if (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then

       l_agent := FND_WEB_CONFIG.WEB_SERVER||
                  substr(icx_plug_utilities.getPLSQLagent,2);

    else

       l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

    end if;

    icx_util.getprompts(601, 'ICX_OBIS_NAVIGATE', l_title, l_prompts);

    htp.p('<!-- Favorites Plug -->');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');
    htp.p('<tr><td>');
    icx_plug_utilities.plugbanner(nvl(p_display_name,l_prompts(1)),l_agent||'OracleNavigate.customizeFavorites?X='||icx_call.encrypt2(p_plug_id,p_session_id), 'FNDNAVIG.gif');
    htp.p('</td></tr>');

    htp.p('<tr><td><font size=-2><BR></font></td></tr>');

    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');

    for f in Favorites loop

    htp.p('<tr>');
    if f.URL is null
    then
        if substr(f.WEB_HTML_CALL,1,10) = 'javascript'
        then
          l_url := replace(f.WEB_HTML_CALL,'"','''');
          l_url := replace(l_url,'[RESPONSIBILITY_ID]',f.responsibility_id);
          l_url := replace(l_url,'[PLSQL_AGENT]',l_agent);
          l_url := '<A HREF="'||l_url||'" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(f.description)||''';return true">'||f.prompt||'</A>';
        else
          l_url := icx_portlet.createExecLink
               (p_application_id => f.responsibility_application_id,
                p_responsibility_id => f.responsibility_id,
                p_security_group_id => f.security_group_id,
                p_function_id => f.function_id,
                p_link_name => f.prompt,
                p_url_only => 'N');

        end if;

-- Bug 3240178    htp.p('<td align="left" valign="top" NOWRAP>');

        htp.p('<td align="left" valign="top" NOWRAP><image src="/OA_MEDIA/FNDWATHS.gif" height=18 width=18 alt="'||icx_util.replace_alt_quotes(f.prompt)||'">');

        htp.p('<font face="Arial" size=2>');
        htp.p(l_url);
    else
        if instr(upper(f.URL),'HTTP') > 0
        then
            l_url := f.URL;
        elsif instr(f.URL, 'file://') > 0
        then
            l_url := f.URL;
        else
            l_url := 'http://'||f.URL; -- This http: OK, nlbarlow
        end if;

        htp.p('<td align="left" valign="top" NOWRAP>');
        htp.p('<image src="/OA_MEDIA/FNDWATHS.gif" height=18 width=18 alt="'||f.prompt||'">');
        htp.p('<font face="Arial" size=2>');
        if ( substr(icx_sec.g_mode_code,1,3) = '115' OR
             icx_sec.g_mode_code = 'SLAVE')
        then
          htp.anchor(curl => 'javascript:top.main.icx_nav_window(''WWK'','''||l_url||''','''||f.PROMPT||''')',
               ctext => f.PROMPT,
               cattributes => ' onMouseOver="window.status='''||l_url||''';return true"');

        else
          htp.anchor(curl => 'javascript:icx_nav_window(''WWW'','''||l_url||''','''||f.PROMPT||''')',
               ctext => f.PROMPT,
               cattributes => ' onMouseOver="window.status='''||l_url||''';return true"');
        end if;
    end if;

    htp.p('</b></td></tr>');

    end loop;

    htp.p('</td></tr></table>');
    htp.p('</TABLE>');

end if;
exception
    when others then
--        htp.p(SQLERRM);
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      c_error_msg := fnd_message.get;
      htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);

end;

procedure FavoriteCreate is

l_title         varchar2(80);
l_prompts       icx_util.g_prompts_table;
c_error_msg     varchar2(240);

begin

if(icx_sec.validateSession)
then
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITE_CREATE', l_title, l_prompts);

    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');

    if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
        htp.p('<body bgcolor= #FFFFFF onload="Javascrpit:window.focus()">');
    else
        htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onload="Javascrpit:window.focus()">');
    end if;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('function saveCreate() {

        if (document.createFavorite.LOCATION.value == "")
          alert("'||l_prompts(1)||'");
        else
          if (document.createFavorite.NAME.value == "")
            alert("'||l_prompts(2)||'");
          else {
            var end=parent.opener.parent.document.Favorites.C.length-1;
            var totext=document.createFavorite.NAME.value;
            var tovalue="0*0*0*X" + document.createFavorite.LOCATION.value + "*WWW";

            if (end > 0)
            if (parent.opener.parent.document.Favorites.C.options[end-1].value == "")
              end = end - 1;

            parent.opener.parent.document.Favorites.C.options[end].text = totext;
            parent.opener.parent.document.Favorites.C.options[end].value = tovalue;');
        if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0
        then
            htp.p('parent.opener.parent.history.go(0);');
        end if;
        htp.p('window.close();
            };
        }');

    htp.p('</SCRIPT>');

    htp.formOpen('javascript:saveCreate()','POST','','','NAME="createFavorite"')
;
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(l_prompts(1), 'RIGHT');
    htp.tableData(htf.formText(cname => 'LOCATION',
                               csize => '35',
                               cmaxlength => '2000'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.tableData(l_prompts(2), 'RIGHT');
    htp.tableData(htf.formText(cname => 'NAME',
                               csize => '35',
                               cmaxlength => '240'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.p('<td align=center colspan=2>');
    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');
    icx_plug_utilities.buttonLeft(l_prompts(3),'javascript:saveCreate()','FNDJLFOK.gif');
    htp.p('</td><td align="right" width="50%">');
    icx_plug_utilities.buttonRight(l_prompts(4),'javascript:window.close()','FNDJLFCN.gif');
    htp.p('</td></tr></table>');
    htp.p('</td>');
    htp.tableRowClose;
    htp.tableClose;
    htp.formClose;

    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
--        htp.p(SQLERRM);
       fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_error_msg := fnd_message.get;
       htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure FavoriteRename(item_name VARCHAR2) is
-- added item name to pass get location 976843 mputman
l_title         varchar2(80);
l_prompts       icx_util.g_prompts_table;
l_location      VARCHAR2(2000);
c_error_msg     varchar2(240);

begin

if(icx_sec.validateSession)
then
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITE_RENAME', l_title, l_prompts);


    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');
    if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
        htp.p('<body bgcolor= #FFFFFF onload="Javascrpit:window.focus()">');
    else
        htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onload="Javascrpit:window.focus()">');
    end if;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    l_location:=(substr(item_name,8,length(item_name)-11)); -- used to get location URL without codes 976843 mputman
    htp.p('var temp=parent.opener.parent.document.Favorites.C.selectedIndex;
           var l_location=parent.opener.parent.document.Favorites.C.options[temp].value;
           var fav_type=l_location.substring(0,7);
           var l_location=l_location.substring(7,(l_location.length-4));
         ');

    htp.p('function loadName() {
            document.renameFavorite.NAME.value = parent.opener.parent.document.Favorites.C.options[temp].text;
            document.renameFavorite.LOCATION.value = l_location
        }'); --added code to show location in text box 976843 mputman

    htp.p('function saveRename() {
        var temp=parent.opener.parent.document.Favorites.C.selectedIndex;

        if (document.renameFavorite.LOCATION.value == "")
           alert("'||l_prompts(5)||'");
        else
          if (document.renameFavorite.NAME.value == "")
           alert("'||l_prompts(1)||'");
        else {
          parent.opener.parent.document.Favorites.C.options[temp].text = document.renameFavorite.NAME.value;');-- added code to show alert if location is null 976843 mputman
    IF (item_name='0*0*0*X') THEN  -- prevents updating location for non custom locations 976843 mputman
       htp.p('parent.opener.parent.document.Favorites.C.options[temp].value="0*0*0*X" + document.renameFavorite.LOCATION.value + "*WWW";'); --wrapps location in codes 976843 mputman
    END IF;
        if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0
        then
            htp.p('parent.opener.parent.history.go(0);');
        end if;
        htp.p('window.close();
        };
        }');

    htp.p('</SCRIPT>');

    htp.formOpen('javascript:saveRename()','POST','','','NAME="renameFavorite"');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(l_prompts(1), 'RIGHT');
    htp.tableData(htf.formText(cname => 'NAME',
                               csize => '35',
                               cmaxlength => '50'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    IF (substr(item_name,1,7)='0*0*0*X') THEN   -- only show this if it is a custom URL 976843 mputman
    htp.tableData(l_prompts(5), 'RIGHT');
    htp.tableData(htf.formText(cname => 'LOCATION',
                               csize => '35',
                               cmaxlength => '2000'), 'LEFT');
    ELSE     -- if not a custom URL... still need this for the save function to work 976843 mputman
       htp.tableData(' ', 'RIGHT'); -- add text box but save NULL value 976843 mputman
       htp.tableData(htf.formHidden(cname => 'LOCATION'),'LEFT'); -- hidden text box 976843 mputman

    END IF;
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.p('<td align=center colspan=2>');
    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');
    icx_plug_utilities.buttonLeft(l_prompts(2),'javascript:saveRename()','FNDJLFOK.gif');
    htp.p('</td><td align="right" width="50%">');
    icx_plug_utilities.buttonRight(l_prompts(3),'javascript:window.close()','FNDJLFCN.gif');
    htp.p('</td></tr></table>');
    htp.p('</td>');
    htp.tableRowClose;
    htp.tableClose;
    htp.formClose;

    htp.p('<SCRIPT LANGUAGE="JavaScript">loadName();</SCRIPT>');

    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
--        htp.p(SQLERRM);
       fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_error_msg := fnd_message.get;
       htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure customizeFavorites(X in pls_integer) is

l_plug_id               pls_integer;
l_counter               pls_integer;
l_count                 pls_integer;
l_object		object;
l_title                 varchar2(80);
l_favorite              varchar2(2000); --changed from 80 to 2000 bug#1333631, mputman
l_prompts               icx_util.g_prompts_table;
l_message               varchar2(2000);
l_responsibilities      icx_sec.g_char_tbl_type;
l_resp_appl_ids    icx_sec.g_num_tbl_type;
l_responsibility_ids    icx_sec.g_num_tbl_type;
l_security_group_ids    icx_sec.g_num_tbl_type;
l_initialize            varchar2(80);
r_initialize            varchar2(80);
l_nbsp                  varchar2(240);
l_history varchar2(240);
l_resp_counter number;
l_prompt_length number;
c_error_msg             varchar2(240);

cursor responsibilities is
select distinct a.responsibility_id,
	a.responsibility_name,
        a.application_id,
        b.security_group_id,
        fsg.SECURITY_GROUP_NAME
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   b.user_id = icx_sec.g_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version IN ('W')
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
AND b.SECURITY_GROUP_ID IN (-1, fsg.SECURITY_GROUP_ID)
AND fsg.SECURITY_GROUP_ID >= 0
AND nvl(FND_PROFILE.VALUE('NODE_TRUST_LEVEL'),1) <=
nvl(FND_PROFILE.VALUE_SPECIFIC('APPL_SERVER_TRUST_LEVEL',b.USER_ID,a.RESPONSIBILITY_ID,b.RESPONSIBILITY_APPLICATION_ID),1)
ORDER BY a.RESPONSIBILITY_NAME, fsg.SECURITY_GROUP_NAME;

cursor Favorites is
select PROMPT,
       RESPONSIBILITY_APPLICATION_ID,
       RESPONSIBILITY_ID,
       SECURITY_GROUP_ID,
       FUNCTION_ID,
       FUNCTION_TYPE,
       URL
from   ICX_CUSTOM_MENU_ENTRIES
where  USER_ID = icx_sec.g_user_id
and    PLUG_ID = l_plug_id
order by DISPLAY_SEQUENCE;

begin

if(icx_sec.validateSession)
then
    l_plug_id := icx_call.decrypt2(X);
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITES', l_title, l_prompts);
    l_title := icx_plug_utilities.getPlugTitle(l_plug_id);
    l_nbsp := '&'||'nbsp;';
    l_initialize := '1234567890123456789012345678901234567890';
    r_initialize := '1234567890123456789012345678901234567890';

--bug 2644185
--    if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
--    then

        l_history := '';

--    else
--        l_history := 'history.go(0);';
--    end if;
--bug 2644185

    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');

    if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
        htp.p('<body bgcolor= "#CCCCCC">');
    else
        htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');
    end if;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('function loadFrom() {
        var temp=document.Favorites.A.selectedIndex;
        var resp=document.Favorites.A[temp].value;
	for (var i=0; i<document.Favorites.B.length; i++)
	    document.Favorites.B.options[i] = new Option("","");');

    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;
    l_resp_counter := 0;
    l_prompt_length := 0;
    for r in responsibilities loop
        l_counter := 0;
        g_list := g_nulllist;
        l_object.responsibility_id := r.responsibility_id;
        l_object.resp_appl_id := r.application_id;
        l_object.security_group_id := r.security_group_id;
        listResponsibility(p_object => l_object,
		                     p_entries => TRUE,
                           p_executable => FALSE);-- pass in defaults (GSCC)
        if g_list.COUNT > 1
        then
          if security_group(r.responsibility_id, r.application_id)
          then
            l_responsibilities(l_resp_counter) := r.responsibility_name||', '||r.security_group_name;
          else
            l_responsibilities(l_resp_counter) := r.responsibility_name;
          end if;
          l_resp_appl_ids(l_resp_counter) := r.application_id;
          l_responsibility_ids(l_resp_counter) := r.responsibility_id;
          l_security_group_ids(l_resp_counter) := r.security_group_id;
          l_resp_counter := l_resp_counter + 1;
          htp.p('if (resp == "'||r.application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'") {');
          for i in 1..g_list.LAST loop
            if g_list(i).type = 'FUNCTION'
	    then
                htp.p('document.Favorites.B.options['||l_counter||'] = new Option("'||g_list(i).prompt||'","'||g_list(i).function_id||'*'||g_list(i).function_type||'");');
		l_counter := l_counter + 1;
                if l_resp_counter = 1
                and length(g_list(i).prompt) > l_prompt_length
                then
                    l_prompt_length := length(g_list(i).prompt);
                end if;
	    end if;
          end loop;
          htp.p('}');
        end if; -- g_list.COUNT > 0
    end loop;
    htp.p('}');
    l_initialize := substr(l_initialize,1,l_prompt_length);

    fnd_message.set_name('ICX','ICX_OBIS_SELECT_OPTION');
    l_message := icx_util.replace_quotes(fnd_message.get);

    htp.p('function selectFrom() {
        alert("'||l_message||'")
        }');

    htp.p('function addTo() {
        var temp=document.Favorites.B.selectedIndex;

        if (temp < 0)
          selectFrom();
        else {
	  var end=document.Favorites.C.length;
          if (end > 0)
            if (document.Favorites.C.options[end-1].value == "")
              end = end - 1;
          var resp=document.Favorites.A.selectedIndex;
          var totext=document.Favorites.B[temp].text;
          var tovalue=document.Favorites.A[resp].value + "*" + document.Favorites.B[temp].value;
	  document.Favorites.C.options[end] = new Option(totext,tovalue);
          document.Favorites.C.selectedIndex = end;
          '||l_history||'
          }
        }');

    fnd_message.set_name('ICX','ICX_OBIS_SELECT_SELECTION');
    l_message := icx_util.replace_quotes(fnd_message.get);

    htp.p('function selectTo() {
        alert("'||l_message||'")
        }');

    htp.p('function upTo() {
        var temp=document.Favorites.C.selectedIndex;
        var end=document.Favorites.C.length;
        if (document.Favorites.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
	  selectTo();
        else
	  if (temp != 0) {
          document.Favorites.C.options[end] = new Option(document.Favorites.C.options[temp].text,document.Favorites.C.options[temp].value);
          document.Favorites.C.options[temp] = new Option(document.Favorites.C.options[temp-1].text, document.Favorites.C.options[temp-1].value);
          document.Favorites.C.options[temp-1] = new Option(document.Favorites.C.options[end].text,document.Favorites.C.options[end].value);
          document.Favorites.C.options[end] = null;
          document.Favorites.C.selectedIndex = temp-1;
          };
        }');

    htp.p('function downTo() {
        var temp=document.Favorites.C.selectedIndex;
        var end=document.Favorites.C.length;
        if (document.Favorites.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
          selectTo();
        else
          if (temp != end-1) {
          document.Favorites.C.options[end] = new Option(document.Favorites.C.options[temp].text,document.Favorites.C.options[temp].value);
          document.Favorites.C.options[temp] = new Option(document.Favorites.C.options[temp+1].text, document.Favorites.C.options[temp+1].value);
          document.Favorites.C.options[temp+1] = new Option(document.Favorites.C.options[end].text,document.Favorites.C.options[end].value);
          document.Favorites.C.options[end] = null;
          document.Favorites.C.selectedIndex = temp+1;
          };
        }');

    l_message := icx_util.replace_quotes(l_prompts(11))||': ';

    htp.p('function deleteTo() {
        var temp=document.Favorites.C.selectedIndex;

        if (temp < 0)
          selectTo();
        else {
            document.Favorites.C.options[temp] = null;
          };
        '||l_history||'
        }');

    htp.p('function open_new_browser(url,x,y){
        var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;
        var new_browser = window.open(url, "new_browser", attributes);
        if (new_browser != null) {
            if (new_browser.opener == null)
                new_browser.opener = self;
            new_browser.location.href = url;
            }
        }');

    htp.p('function renameTo() {
        var temp=document.Favorites.C.selectedIndex;
        var temp2=document.Favorites.C.options[document.Favorites.C.selectedIndex].value;
        temp2=temp2.substring(0,7);

          if (temp < 0)
          selectTo();
        else
open_new_browser(''OracleNavigate.FavoriteRename?item_name=''+temp2,400,110);
        }'); -- add parameter to send item name to rename box 976843 mputman


    htp.p('function createTo() {
        var end=document.Favorites.C.length;
	document.Favorites.C.options[end] = new Option("","");
        open_new_browser(''OracleNavigate.FavoriteCreate'',400,145);
        }');

    htp.p('function saveFavorites() {
        var end=document.Favorites.C.length;

        for (var i=0; i<end; i++)
          if (document.Favorites.C.options[i].value != "")
            document.updateFavorites.X.value = document.updateFavorites.X.value + "+" + document.Favorites.C.options[i].value + "*" + document.Favorites.C.options[i].text;

	document.updateFavorites.X.value = document.updateFavorites.X.value + "+";
	document.updateFavorites.submit();
        }');

        icx_admin_sig.help_win_script('ICXCFGPG', null, 'BIS');

    htp.p('</SCRIPT>');

    icx_plug_utilities.toolbar(p_text => l_title,
                               p_language_code => icx_sec.g_language_code,
                               p_disp_help => 'Y',
                               p_disp_mainmenu => 'N',
                               p_disp_menu => 'N');

    htp.formOpen('OracleNavigate.updateFavorites','POST','','','NAME="updateFavorites"');
    htp.formHidden('X');
    htp.formHidden('Y',X);
    htp.formClose;

    fnd_message.set_name('ICX','ICX_CUSTOMIZE_FAVORITES');
    l_message := fnd_message.get;

    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr><td width=5%></td><td width=90%><I>'||l_message||'</I></td><td width=5%></td></tr>');
    htp.p('</table>');

    htp.formOpen('javascript:saveFavorites()','POST','','','NAME="Favorites"');
    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>'); -- main
    htp.p('<tr><td align=center>');
--Bug 2687577
--  htp.p('<table width="10%" border=0 cellspacing=0 cellpadding=0>'); -- Cell
--
    htp.p('<tr><td colspan=2>');
    htp.p(l_prompts(1));
    htp.p('</td></tr>');
    htp.p('<tr><td colspan=2>');
    htp.p('<select name="A" onchange="loadFrom();'||l_history||'">');
    if l_responsibilities.COUNT > 0
    then
    for r in l_responsibilities.FIRST..l_responsibilities.LAST loop
    htp.formSelectOption(cvalue => l_responsibilities(r),
                         cattributes => 'VALUE = "'||l_resp_appl_ids(r)||'*'||l_responsibility_ids(r)||'*'||l_security_group_ids(r)||'"');
    end loop;
    else
    htp.formSelectOption(cvalue => '',
                         cattributes => 'VALUE = ""');
    end if;
    htp.formSelectClose;
    htp.p('</td></tr>');
    htp.p('<tr><td>');
    htp.p(l_prompts(2));
    htp.p('</td><td>');
    htp.p(l_prompts(3));
    htp.p('</td><td>');
    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>');  -- Full Menu cell
    htp.p('<select name="B" size=10>');
    htp.formSelectOption(l_initialize);
    htp.formSelectClose;
    htp.p('<SCRIPT LANGUAGE="JavaScript">loadFrom()</SCRIPT>');
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td>'); -- Add
    htp.p('<A HREF="javascript:addTo();" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(4))||''';return true"><image src="/OA_MEDIA/FNDRTARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(4))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Add
    htp.p('</td></tr></table>'); -- Full Menu cell
    htp.p('</td><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>'); -- Favorite cell
    htp.p('<select name="C" size=10>');

--bug 2644185
      htp.formSelectOption('____________________________________________');

    for f in favorites loop
        if f.URL is null
        then
            l_favorite := f.responsibility_application_id||'*'||f.responsibility_id||'*'||f.security_group_id||'*'||f.function_id||'*'||f.function_type;
        else
            l_favorite := '0*0*0*X'||f.URL||'*WWW';
        end if;
        htp.formSelectOption(cvalue => f.prompt,
                             cattributes => 'VALUE = '||l_favorite);
    end loop;
    htp.formSelectClose;
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td align="left" valign="bottom">'); -- Up and Down
    htp.p('<A HREF="javascript:upTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(5))||''';return true"><image src="/OA_MEDIA/FNDUPARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(5))||'" BORDER="0"></A>');
    htp.p('</td></tr><tr><td align="left" valign="top">');
    htp.p('<A HREF="javascript:downTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(6))||''';return true"><image src="/OA_MEDIA/FNDDNARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(6))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Up and Down
    htp.p('</td></tr></table>'); -- Favorite cell
    htp.p('</td></tr>');
    htp.p('<tr><td></td><td>');
    htp.p('<table><tr>'); -- Buttons
    htp.p('<td>');
    icx_plug_utilities.buttonBoth(l_prompts(9),'javascript:createTo()');
    htp.p('</td><td>');
    icx_plug_utilities.buttonBoth(l_prompts(13),'javascript:renameTo()'); -- changed from prompt(10) for 976843
    htp.p('</td><td>');
    icx_plug_utilities.buttonBoth(l_prompts(11),'javascript:deleteTo()');
    htp.p('</tr></table>'); -- Buttons
    htp.p('</td></tr>');

    htp.p('<tr><td colspan="2"><BR></td></tr>');

    htp.p('<tr><td colspan="2">');
    htp.p('<table width=100%><tr><td width=50% align="right">'); -- OK
    icx_plug_utilities.buttonLeft(l_prompts(7),'javascript:saveFavorites()','FNDJLFOK.gif');
    htp.p('</td><td width=50% align="left">');
    icx_plug_utilities.buttonRight(l_prompts(8),'javascript:history.go(-1)','FNDJLFCN.gif');
    htp.p('</td></tr></table>'); -- OK
    htp.p('</td></tr>');
    htp.p('</table>'); -- Cell
    htp.p('</td></tr>');
    htp.p('</table>'); -- Main

    htp.formClose;
    htp.p('<SCRIPT LANGUAGE="JavaScript">document.Favorites.A.focus();</SCRIPT>');
    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
---        htp.p(SQLERRM);
       fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_error_msg := fnd_message.get;
       htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);


end;

procedure updateFavorites(X in varchar2,
                          Y in pls_integer) is

l_plug_id               pls_integer;
l_line			varchar2(2000);
l_line_length		pls_integer;
l_point1		pls_integer;
l_point2		pls_integer;
l_point3		pls_integer;
l_point4                pls_integer;
l_point5                pls_integer;
l_point_1_2		pls_integer;
l_point_2_3		pls_integer;
l_point_3_4             pls_integer;
l_point_4_5             pls_integer;
l_length		pls_integer;
l_index			pls_integer;
l_nextcount		pls_integer;
l_lastcount		pls_integer;
l_occurence		pls_integer;
l_resp_appl_id          pls_integer;
l_security_group_id     pls_integer;
l_responsibility_id	pls_integer;
l_function_id		pls_integer;
l_function_type         varchar2(30);
l_prompt		varchar2(240);
l_url			varchar2(2000);
c_error_msg             varchar2(240);

begin

if icx_sec.validateSession
then
    l_plug_id := icx_call.decrypt2(Y);
    l_length := length(X);
    l_index := 0;
    l_occurence := 1;
    l_lastcount := 1;

    delete ICX_CUSTOM_MENU_ENTRIES
    where  USER_ID = icx_sec.g_user_id
    and    PLUG_ID = l_plug_id;

    while l_lastcount <= l_length loop
	l_nextcount := instr(X,'+',1,l_occurence);
        if l_lastcount <> l_nextcount
	then
	l_line_length := l_nextcount-l_lastcount;
        l_line := substr(X,l_lastcount,l_line_length);
	l_point1 := instr(l_line,'*',1,1);
	l_point2 := instr(l_line,'*',1,2);
        l_point3 := instr(l_line,'*',1,3);
        l_point4 := instr(l_line,'*',1,4);
        l_point5 := instr(l_line,'*',1,5);
	l_point_1_2 := l_point2 - l_point1 - 1;
	l_point_2_3 := l_point3 - l_point2 - 1;
	l_point_3_4 := l_point4 - l_point3 - 1;
	l_point_4_5 := l_point5 - l_point4 - 1;

        l_resp_appl_id := substr(l_line,1,l_point1-1);
        l_responsibility_id := substr(l_line,l_point1+1,l_point_1_2);
        l_security_group_id := substr(l_line,l_point2+1,l_point_2_3);
        l_url := substr(l_line,l_point3+1,l_point_3_4);
        if substr(l_url,1,1) = 'X'
        then
	    l_url := substr(l_url,2,length(l_url)-1);
	else
	    l_function_id := to_number(l_url);
	    l_url := '';
	end if;
        l_function_type := substr(l_line,l_point4+1,l_point_4_5);
        l_prompt := substr(l_line,l_point5+1,length(l_line));

        insert into ICX_CUSTOM_MENU_ENTRIES
	(USER_ID,
         PLUG_ID,
         DISPLAY_SEQUENCE,
         PROMPT,
         RESPONSIBILITY_APPLICATION_ID,
         RESPONSIBILITY_ID,
         SECURITY_GROUP_ID,
         FUNCTION_ID,
         FUNCTION_TYPE,
         URL)
	values
	(icx_sec.g_user_id,
         l_plug_id,
         l_index,
         l_prompt,
         l_resp_appl_id,
         l_responsibility_id,
         l_security_group_id,
         l_function_id,
         l_function_type,
         l_url);

         l_index := l_index + 1;
        end if;

	l_lastcount := l_nextcount + 1;
	l_occurence := l_occurence + 1;
    end loop;

    icx_plug_utilities.gotoMainMenu;

end if; -- validateSession

exception
    when others then
--        htp.p(SQLERRM);
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      c_error_msg := fnd_message.get;
      htp.p('<valign=left NOWRAP><font color="#CC0000" face="Arial" size=2><b>'||c_error_msg||dbms_utility.format_error_stack);



end;

PROCEDURE menuBypass(p_token IN VARCHAR2,
                     p_mode IN VARCHAR2)
   IS
   -- added for 1352780
   -- this signature is used to
   -- make calls to launch
   -- the only function available
   -- to the only responsibility available
   l_parameters    icx_on_utilities.v80_table;
   p_app_id NUMBER;
   p_resp_id NUMBER;
   p_function_id NUMBER;
   p_sec_grp_id NUMBER;
   p_agent VARCHAR2(2000);
   l_web_call VARCHAR2(2000);
   l_url VARCHAR2(2000);

BEGIN
   IF icx_sec.ValidateSession THEN

      icx_on_utilities.unpack_parameters(icx_call.decrypt(p_token),l_parameters);

      p_app_id := nvl(l_parameters(1),178);
      p_resp_id := l_parameters(2);
      p_function_id := l_parameters(3);
      p_sec_grp_id := l_parameters(4);
      p_agent := l_parameters(5);


      SELECT web_html_call
         INTO l_web_call
         FROM fnd_form_functions_vl
         WHERE function_id=p_function_id;
      --if added for 1352780
      if substrb(l_web_call,1,10) = 'javascript'
      then
        l_url := replace(l_web_call,'"','''');
        l_url := replace(l_url,'[RESPONSIBILITY_ID]',p_resp_id);
        l_url := replace(l_url,'[PLSQL_AGENT]',icx_plug_utilities.getPLSQLagent);
        l_url :=(substrb(l_url, (instrb(l_url,'''',1,1)+1),(instrb((substrb(l_url,(instrb(l_url,'''',1,1)+1))),'''',1,1)-1)));
        l_url:='"'||l_url||'"';
      ELSE
        l_url := icx_portlet.createExecLink
               (p_application_id => p_app_id,
                p_responsibility_id => p_resp_id,
                p_security_group_id => p_sec_grp_id,
                p_function_id => p_function_id,
                p_url_only => 'Y');
        l_url:='"'||l_url||'"';
      END IF;
         --htp.p(l_url);
         -- 3097745 nlbarlow
         htp.p('<script>top.location='||l_url||';</script>');

      END IF;

   end; --menubypass

   PROCEDURE menuBypass(p_token IN VARCHAR2)  IS

      -- added for 1352780
   -- this signature is used to
   -- make calls to launch
   -- the only (forms) responsibility
   -- available.. will launch apps

   l_parameters    icx_on_utilities.v80_table;
   p_app_short_name VARCHAR2(200);
   p_resp_key VARCHAR2(240);
   p_sec_grp_key VARCHAR2(100);
   p_agent VARCHAR2(2000);
   l_url VARCHAR2(2000);
   l_encrypted_session_id VARCHAR2(240);

BEGIN

   IF icx_sec.ValidateSession THEN

      icx_on_utilities.unpack_parameters(icx_call.decrypt(p_token),l_parameters);
      p_app_short_name := l_parameters(1);
      p_resp_key := l_parameters(2);
      p_sec_grp_key := l_parameters(3);
      p_agent := l_parameters(4);

--   l_encrypted_session_id := icx_call.encrypt3(icx_sec.getsessioncookie); removed mputman

-- bug 1728149 - removed l_encrypted_session_id from icx_ticket
 --  l_url:=p_agent||'fnd_icx_launch.runforms?ICX_TICKET='||'&';
 --  l_url:=l_url||'RESP_APP='||wfa_html.conv_special_url_chars(p_app_short_name)||'&'||'RESP_KEY='||wfa_html.conv_special_url_chars(p_resp_key)||'&'; -- mputman added wfa call 1690141
 --  l_url:=l_url||'SECGRP_KEY='||wfa_html.conv_special_url_chars(p_sec_grp_key); -- mputman added wfa call 1690141
 --  l_url:='"'||l_url||'"';
     l_url:='"dummy"';
         htp.p('


               <script>
               function menuBypass(url){
               var p_agent="'||p_agent||'";
               var p_app_short_name="'||p_app_short_name||'";
               p_app_short_name=escape(p_app_short_name);
               var p_resp_key="'||p_resp_key||'";
               p_resp_key=escape(p_resp_key);
               var p_sec_grp_key="'||p_sec_grp_key||'";
               p_sec_grp_key=escape(p_sec_grp_key);
               var l_url=p_agent+"fnd_icx_launch.runforms?ICX_TICKET=&RESP_APP="+p_app_short_name+"&RESP_KEY="+p_resp_key+"&SECGRP_KEY="+p_sec_grp_key;
               top.location=l_url;

               }
               </script>

               <frameset cols="100%,*" frameborder=no border=0>

               <frame
                src=javascript:parent.menuBypass('||l_url||')
                name=hiddenFrame1
                marginwidth=0
                marginheight=0
                scrolling=no>


               </frameset>

               ');



      END IF;

   end; --menubypass

end OracleNavigate;

/
