--------------------------------------------------------
--  DDL for Package Body ORACLEPLUGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLEPLUGS" as
/* $Header: ICXSEPB.pls 120.1 2005/10/07 14:21:10 gjimenez noship $ */

TYPE object IS RECORD (
        location           varchar2(30),
        display_sequence   pls_integer,
        type               varchar2(30),
        resp_appl_id       pls_integer,
        security_group_id  pls_integer,
        responsibility_id  pls_integer,
        parent_menu_id     pls_integer,
        entry_sequence     pls_integer,
        menu_id            pls_integer,
        function_id        pls_integer,
        function_type      varchar2(30),
        level              pls_integer,
        prompt             varchar2(240),
        description        varchar2(240));

TYPE objectTable IS TABLE OF object index by binary_integer;

type l_v80_table is table of varchar2(80) index by binary_integer;

g_nulllist       objectTable;
g_list           objectTable;
g_executablelist objectTable;

procedure timer(message varchar2 default NULL) is
l_hsecs pls_integer;
begin
    select HSECS into l_hsecs from V$TIMER;
    htp.p('DEBUG ('||l_hsecs||') '||message);htp.nl;
end;

--  ***********************************************
--      Procedure listMenuEntries
--  ***********************************************
procedure listMenuEntries(p_object in object) is

l_index         pls_integer;
l_object        object;
l_count		pls_integer;

cursor  menuentries is
select  prompt,
        description,
        sub_menu_id,
	entry_sequence
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	sub_menu_id is not null
order by entry_sequence;

cursor  functionentries is
select  b.prompt,
        b.description,
        b.function_id,
        b.entry_sequence,
	a.type
from    fnd_form_functions a,
	fnd_menu_entries_vl b
where   b.menu_id = p_object.parent_menu_id
and	a.function_id = b.function_id
and     a.type = p_object.function_type
order by entry_sequence;

begin

select  count(*)
into    l_count
from    fnd_menu_entries
where   menu_id = p_object.parent_menu_id
and     sub_menu_id is not null;

if l_count > 0
then
    for m in menuentries loop
        l_object.resp_appl_id := p_object.resp_appl_id;
        l_object.security_group_id := p_object.security_group_id;
        l_object.responsibility_id := p_object.responsibility_id;
        l_object.parent_menu_id := m.sub_menu_id;
        l_object.function_type := p_object.function_type;
        l_object.level := p_object.level+1;
        l_object.prompt := p_object.prompt;
        l_object.description := p_object.description;
        listMenuEntries(p_object =>l_object);
    end loop; -- menuentries
end if;

for f in functionentries loop
    l_index := g_list.COUNT;
    g_list(l_index).type := 'FUNCTION';
    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
    g_list(l_index).security_group_id := p_object.security_group_id;
    g_list(l_index).responsibility_id := p_object.responsibility_id;
    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
    g_list(l_index).entry_sequence := f.entry_sequence;
    g_list(l_index).function_id := f.function_id;
    g_list(l_index).function_type := f.type;
    g_list(l_index).level := p_object.level;
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
    end if;
end loop; -- menuentries

exception
    when others then
        htp.p(SQLERRM);

end;

procedure listResponsibility(p_object in object) is

l_object		object;

begin

l_object.resp_appl_id := p_object.resp_appl_id;
l_object.security_group_id := p_object.security_group_id;
l_object.responsibility_id := p_object.responsibility_id;
l_object.parent_menu_id := p_object.parent_menu_id;
l_object.function_type := p_object.function_type;
l_object.level := p_object.level+1;
l_object.prompt := p_object.prompt;
l_object.description := p_object.description;
listMenuEntries(p_object =>l_object);

exception
    when others then
        htp.p(SQLERRM);

end;

procedure plugRename(Z in varchar2) is

l_title varchar2(80);
l_prompts icx_util.g_prompts_table;

begin

if(icx_sec.validateSession)
then
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITE_RENAME', l_title, l_prompts);

    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');
    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'" onload="Javascrpit:window.focus()">');

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('function loadName() {
        var temp=parent.opener.parent.document.'||Z||'.C.selectedIndex;

        document.renamePlug.NAME.value = parent.opener.parent.document.'||Z||'.C.options[temp].text;
        }');

    htp.p('function saveRename() {
        var temp=parent.opener.parent.document.'||Z||'.C.selectedIndex;


        if (document.renamePlug.NAME.value == "")
           alert("'||l_prompts(1)||'");
        else {
        parent.opener.parent.document.'||Z||'.C.options[temp].text = document.renamePlug.NAME.value;');
        if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0
        then
            htp.p('parent.opener.parent.history.go(0);');
        end if;
        htp.p('window.close();
        };
        }');

    htp.p('</SCRIPT>');

    htp.formOpen('javascript:saveRename()','POST','','','NAME="renamePlug"');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(l_prompts(1), 'RIGHT');
    htp.tableData(htf.formText(cname => 'NAME',
                               csize => '35',
                               cmaxlength => '50'), 'LEFT');
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
        htp.p(SQLERRM);

end;

procedure Colors(p_text in varchar2) is

type varchar2table is table of varchar2(30) index by binary_integer;

l_color_schemes varchar2table;
l_color_scheme varchar2(30);

begin

l_color_schemes(0) := 'BL';
l_color_schemes(1) := 'BR';
l_color_schemes(2) := 'GR';
l_color_schemes(3) := 'GY';
l_color_schemes(4) := 'YL';
l_color_schemes(5) := 'IN';

select COLOR_SCHEME
into   l_color_scheme
from   ICX_PAGE_COLOR_SCHEME
where  USER_ID = icx_sec.g_user_id;

htp.p('<table width="70%"><tr>');

htp.p('<td align=right>'||p_text||'</td>');

for i in l_color_schemes.FIRST..l_color_schemes.LAST loop
  if l_color_schemes(i) = l_color_scheme
  then
    htp.p('<td width=20 align=right><input type=radio name="N" CHECKED value="'||l_color_schemes(i)||'" ></td>');
  else
    htp.p('<td width=20 align=right><input type=radio name="N" value="'||l_color_schemes(i)||'" ></td>');
  end if;
  htp.p('<td align=left><img src="/OA_MEDIA/FND'||l_color_schemes(i)||'CLR.gif"></td>');
end loop;

htp.p('</tr></table>');

end;

procedure Refresh(p_page_id in number,
                  p_refresh in varchar2) is

l_lookup_codes icx_util.g_lookup_code_table;
l_lookup_meanings icx_util.g_lookup_meaning_table;
l_selected number;

begin

icx_util.getLookups('ICX_REFRESH', l_lookup_codes, l_lookup_meanings);

select nvl(REFRESH_RATE,0)
into   l_selected
from   ICX_PAGES
where  USER_ID = icx_sec.g_user_id
and    PAGE_ID = p_page_id;

htp.p('<table><tr><td>'||p_refresh||'</td><td>');
htp.formSelectOpen('O');
for i in 1..l_lookup_codes.COUNT-2 loop
  if l_selected = l_lookup_codes(i)
  then
    htp.formSelectOption(l_lookup_meanings(i),'CHECKED','VALUE="'||l_lookup_codes(i)||'"');
  else
    htp.formSelectOption(l_lookup_meanings(i),'','VALUE="'||l_lookup_codes(i)||'"');
  end if;
end loop;
htp.formSelectClose;
htp.p('</td></tr></table>');

end;

procedure Customize(p_session_id pls_integer default null,
                    p_page_id    pls_integer default null) is

TYPE entry IS RECORD (
        resp_appl_id        number,
        security_group_id   number,
        responsibility_id   number,
        responsibility_name varchar2(100),
        menu_id             number,
        entry_sequence      number,
        prompt              varchar2(240),
        description         varchar2(240),
        function_id         number,
        type                varchar2(30));

TYPE entryTable IS TABLE OF entry index by binary_integer;

l_session_id pls_integer;
l_page_id    pls_integer;
l_language_code varchar2(30);
l_counter               pls_integer;
l_object		object;
l_left_names            l_v80_table;
l_left_ids              l_v80_table;
l_right_names           l_v80_table;
l_right_ids             l_v80_table;
l_title varchar2(80);
l_prompts icx_util.g_prompts_table;
l_message varchar2(2000);
l_initialize varchar2(80);
r_initialize varchar2(80);
l_history varchar2(240);
l_resp_counter number;
l_prompt_length number;
l_index number;
l_entries entryTable;
l_entries_null entryTable;

cursor  left_menu_entries is
select  b.responsibility_application_id,
        b.security_group_id,
        a.responsibility_id,
        a.responsibility_name,
	a.menu_id,
        c.entry_sequence,
        c.prompt,
        c.description,
        d.function_id,
        d.type
from    fnd_form_functions d,
        fnd_menu_entries_vl c,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   b.user_id = icx_sec.g_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_application_id = a.application_id
and     b.responsibility_id = a.responsibility_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     a.menu_id = c.menu_id
and     c.function_id = d.function_id
and     d.type in ('WWL','WWLG')
and     d.function_name <> 'ICX_NAVIGATE_PLUG'
order by prompt;

cursor  right_menu_entries is
select  b.responsibility_application_id,
        b.security_group_id,
        a.responsibility_id,
        a.responsibility_name,
        a.menu_id,
        c.entry_sequence,
        c.prompt,
        c.description,
        d.function_id,
        d.type
from    fnd_form_functions d,
        fnd_menu_entries_vl c,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   b.user_id = icx_sec.g_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_application_id = a.application_id
and     b.responsibility_id = a.responsibility_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     a.menu_id = c.menu_id
and     c.function_id = d.function_id
and     d.type in ('WWR','WWRG')
order by prompt;

cursor left is
select b.DISPLAY_SEQUENCE,b.PLUG_ID,b.RESPONSIBILITY_ID,
       b.RESPONSIBILITY_APPLICATION_ID,b.SECURITY_GROUP_ID,
       b.MENU_ID,b.ENTRY_SEQUENCE,nvl(b.DISPLAY_NAME,c.PROMPT) prompt,
       c.DESCRIPTION
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
       b.MENU_ID,b.ENTRY_SEQUENCE,nvl(b.DISPLAY_NAME,a.USER_FUNCTION_NAME) prompt,
       a.DESCRIPTION
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
       c.DESCRIPTION
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

if p_session_id is null
then
    l_session_id := icx_sec.getsessioncookie;
else
    l_session_id := p_session_id;
end if;

if icx_sec.validateSessionPrivate(l_session_id)
then

    if p_page_id is null
    then
        select PAGE_ID
        into   l_page_id
        from   ICX_PAGES
        where  USER_ID = icx_sec.g_user_id;
    else
        l_page_id := p_page_id;
    end if;

    l_initialize := '1234567890123456789012345678901234567890';
    r_initialize := '1234567890123456789012345678901234567890';

    if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
    then
        l_history := '';
    else
        l_history := 'history.go(0);';
    end if;

    icx_util.getprompts(601, 'ICX_OBIS_CUSTOMIZATION', l_title, l_prompts);

    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');
    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    fnd_message.set_name('ICX','ICX_OBIS_SELECT_OPTION');
    l_message := icx_util.replace_quotes(fnd_message.get);

    htp.p('function selectFrom() {
        alert("'||l_message||'")
        }');

    htp.p('function addLeftTo() {
        var temp=document.Left.B.selectedIndex;

        if (temp < 0)
          selectFrom();
        else {
          if (document.Left.B[temp].value != "") {
            var end=document.Left.C.length;
            if (end > 0)
              if (document.Left.C.options[end-1].value == "")
                end = end - 1;
            var totext=document.Left.B[temp].text;;
            var tovalue=document.Left.B[temp].value + "@!$#";
	    document.Left.C.options[end] = new Option(totext,tovalue);
            document.Left.C.selectedIndex = end;
            '||l_history||'
            }
          }
        }');

    htp.p('function addRightTo() {
        var temp=document.Right.B.selectedIndex;

        if (temp < 0)
          selectFrom();
        else {
          if (document.Right.B[temp].value != "") {
            var end=document.Right.C.length;
            if (end > 0)
              if (document.Right.C.options[end-1].value == "")
                end = end - 1;
            var totext=document.Right.B[temp].text;;
            var tovalue=document.Right.B[temp].value + "@!$#";
            document.Right.C.options[end] = new Option(totext,tovalue);
            document.Right.C.selectedIndex = end;
            '||l_history||'
            }
          }
        }');


    fnd_message.set_name('ICX','ICX_OBIS_SELECT_SELECTION');
    l_message := icx_util.replace_quotes(fnd_message.get);

    htp.p('function selectTo() {
        alert("'||l_message||'")
        }');

    htp.p('function upLeftTo() {
        var temp=document.Left.C.selectedIndex;
        var end=document.Left.C.length;
        if (document.Left.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
	  selectTo();
        else
	  if (temp != 0) {
          document.Left.C.options[end] = new Option(document.Left.C.options[temp].text,document.Left.C.options[temp].value);
          document.Left.C.options[temp] = new Option(document.Left.C.options[temp-1].text,document.Left.C.options[temp-1].value);
          document.Left.C.options[temp-1] = new Option(document.Left.C.options[end].text,document.Left.C.options[end].value);
          document.Left.C.options[end] = null;
          document.Left.C.selectedIndex = temp-1;
          };
        }');

    htp.p('function upRightTo() {
        var temp=document.Right.C.selectedIndex;
        var end=document.Right.C.length;
        if (document.Right.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
          selectTo();
        else
          if (temp != 0) {
          document.Right.C.options[end] = new Option(document.Right.C.options[temp].text,document.Right.C.options[temp].value);
          document.Right.C.options[temp] = new Option(document.Right.C.options[temp-1].text,document.Right.C.options[temp-1].value);
          document.Right.C.options[temp-1] = new Option(document.Right.C.options[end].text,document.Right.C.options[end].value);
          document.Right.C.options[end] = null;
          document.Right.C.selectedIndex = temp-1;
          };
        }');

    htp.p('function downLeftTo() {
        var temp=document.Left.C.selectedIndex;
        var end=document.Left.C.length;
        if (document.Left.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
          selectTo();
        else
          if (temp != end-1) {
          document.Left.C.options[end] = new Option(document.Left.C.options[temp].text,document.Left.C.options[temp].value);
          document.Left.C.options[temp] = new Option(document.Left.C.options[temp+1].text,document.Left.C.options[temp+1].value);
          document.Left.C.options[temp+1] = new Option(document.Left.C.options[end].text,document.Left.C.options[end].value);
          document.Left.C.options[end] = null;
          document.Left.C.selectedIndex = temp+1;
          };
        }');

    htp.p('function downRightTo() {
        var temp=document.Right.C.selectedIndex;
        var end=document.Right.C.length;
        if (document.Right.C.options[end-1].value == "")
            end = end - 1;

        if (temp < 0)
          selectTo();
        else
          if (temp != end-1) {
          document.Right.C.options[end] = new Option(document.Right.C.options[temp].text,document.Right.C.options[temp].value);
          document.Right.C.options[temp] = new Option(document.Right.C.options[temp+1].text,document.Right.C.options[temp+1].value);
          document.Right.C.options[temp+1] = new Option(document.Right.C.options[end].text,document.Right.C.options[end].value);
          document.Right.C.options[end] = null;
          document.Right.C.selectedIndex = temp+1;
          };
        }');

    l_message := icx_util.replace_quotes(l_prompts(11))||': ';

    htp.p('function open_new_browser(url,x,y){
        var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;
        var new_browser = window.open(url, "new_browser", attributes);
        if (new_browser != null) {
            if (new_browser.opener == null)
                new_browser.opener = self;
            window.name = ''OracleCustomizationroot'';
            new_browser.location.href = url;
            }
        }');

    htp.p('function renameLeftTo() {
        var temp=document.Left.C.selectedIndex;

        if (temp < 0)
          selectTo();
        else
          open_new_browser(''OraclePlugs.plugRename?Z=Left'',400,110);
        }');

    fnd_message.set_name('ICX','ICX_CANNOT_DELETE_PLUG');
    l_message := icx_util.replace_quotes(fnd_message.get);

    htp.p('function deleteLeftTo() {
        var temp=document.Left.C.selectedIndex;

        if (temp < 0)
          selectTo();
        else {
         var nav=document.Left.C.options[temp].value;
         nav = nav.split("@!$#");
         if (nav[2] != "-1") {
          document.Left.C.options[temp] = null;
          '||l_history||'
         }
         else
          alert("'||l_message||'");
        };
        }');

    htp.p('function renameRightTo() {
        var temp=document.Right.C.selectedIndex;

        if (temp < 0)
          selectTo();
        else
          open_new_browser(''OraclePlugs.plugRename?Z=Right'',400,110);
        }');


    htp.p('function deleteRightTo() {
        var temp=document.Right.C.selectedIndex;

        if (temp < 0)
          selectTo();
        else {
            document.Right.C.options[temp] = null;
            '||l_history||'
            };
        }');

    htp.p('function saveCustomization() {
        var endLeft=document.Left.C.length;
        var endRight=document.Right.C.length;
        var refresh=document.Right.O.selectedIndex;

        for (var i=0; i<endLeft; i++)
            document.updateCustomization.X.value = document.updateCustomization.X.value + "+" + document.Left.C.options[i].value + "@!$#" + document.Left.C.options[i].text;

	document.updateCustomization.X.value = document.updateCustomization.X.value + "+";

        for (var i=0; i<endRight; i++)
            document.updateCustomization.Y.value = document.updateCustomization.Y.value + "+" + document.Right.C.options[i].value + "@!$#" + document.Right.C.options[i].text;

        document.updateCustomization.Y.value = document.updateCustomization.Y.value + "+";

        for (var i=0; i<document.Right.N.length; i++)
            if (document.Right.N[i].checked)
               document.updateCustomization.N.value = document.Right.N[i].value;

        document.updateCustomization.O.value = document.Right.O.options[refresh].value;

        document.updateCustomization.submit();
        }');

        icx_admin_sig.help_win_script('ICXPHP', null, 'FND');

    htp.p('</SCRIPT>');

    icx_plug_utilities.toolbar(p_text => l_title,
                               p_language_code => icx_sec.g_language_code,
                               p_disp_help => 'Y',
                               p_disp_mainmenu => 'N',
                               p_disp_menu => 'N');

    htp.formOpen('OraclePlugs.updateCustomization','POST','','','NAME="updateCustomization"');
    htp.formHidden('X');
    htp.formHidden('Y');
    htp.formHidden('Z',icx_call.encrypt2(l_page_id,l_session_id));
    htp.formHidden('N');
    htp.formHidden('O');
    htp.formClose;

    fnd_message.set_name('ICX','ICX_CUSTOMIZE_HOME_PAGE');
    l_message := fnd_message.get;

    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr><td width=5%></td><td width=90%><I>'||l_message||'</I></td><td width=5%></td></tr>');
    htp.p('</table>');

  htp.formOpen('','POST','','','NAME="Left"');
  htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');  -- Main
  htp.tableRowOpen;
  htp.p('<td align=center valign=top>');
    htp.p('<table width="10%" border=0 cellspacing=0 cellpadding=0 valign=top>'); -- Left
    htp.p('<tr><td colspan=2 align=center>');
    htp.p('<B>'||l_prompts(13)||'</B>');
    htp.p('</td></tr>');
    htp.p('<tr><td>');
    htp.p(l_prompts(2));
    htp.p('</td><td>');
    htp.p(l_prompts(3));
    htp.p('</td></tr>');
    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>');  -- Options
    htp.p('<select name="B" size=10>');
    l_index := 0;
    l_entries := l_entries_null;
    for l in left_menu_entries loop
        l_entries(l_index).prompt := nvl(l.prompt,l.description);
        l_entries(l_index).description := l.description;
        l_entries(l_index).responsibility_name := l.responsibility_name;
        l_entries(l_index).resp_appl_id := l.responsibility_application_id;
        l_entries(l_index).security_group_id := l.security_group_id;
        l_entries(l_index).responsibility_id := l.responsibility_id;
        l_entries(l_index).menu_id:= l.menu_id;
        l_entries(l_index).entry_sequence := l.entry_sequence;
        l_entries(l_index).function_id := l.function_id;
        l_entries(l_index).type := l.type;
        l_index := l_index + 1;
    end loop;
    if l_entries.COUNT > 0 then
    for i in l_entries.FIRST..l_entries.LAST loop
      if (i > l_entries.FIRST and l_entries(i).prompt = l_entries(i-1).prompt)
      then
        if l_entries(i).type <> 'WWLG'
        then
          htp.formSelectOption(cvalue => l_entries(i).prompt||' ('||l_entries(i).responsibility_name||')',
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        end if;
      elsif (i < l_entries.LAST and l_entries(i).prompt = l_entries(i+1).prompt)
      then
        if l_entries(i).type = 'WWLG'
        then
          htp.formSelectOption(cvalue => l_entries(i).prompt,
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        else
          htp.formSelectOption(cvalue => l_entries(i).prompt||' ('||l_entries(i).responsibility_name||')',
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        end if;
      else
        htp.formSelectOption(cvalue => l_entries(i).prompt,
                             cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
        l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
      end if;
    end loop;
    end if;
    htp.formSelectClose;
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td>'); -- Add
    htp.p('<A HREF="javascript:addLeftTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(4))||''';return true">
           <image src="/OA_MEDIA/FNDRTARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(4))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Add
    htp.p('</td></tr></table>'); -- Options
    htp.p('</td><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>'); -- Selection
    htp.p('<select name="C" size=10>');
    for l in left loop
        htp.formSelectOption(cvalue => nvl(l.prompt,l.description),
                             cattributes => 'VALUE = "'||l.responsibility_application_id||'@!$#'||l.security_group_id||'@!$#'||l.responsibility_id||'@!$#'||l.menu_id||'@!$#'||l.entry_sequence||'@!$#'||l.prompt||'@!$#'||l.plug_id||'"');
    end loop;
    htp.formSelectClose;
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td align="left" valign="bottom">'); -- Up and Down
    htp.p('<A HREF="javascript:upLeftTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(5))||''';return true">
           <image src="/OA_MEDIA/FNDUPARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(5))||'" BORDER="0"></A>');
    htp.p('</td></tr><tr><td align="left" valign="top">');
    htp.p('<A HREF="javascript:downLeftTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(6))||''';return true">
           <image src="/OA_MEDIA/FNDDNARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(6))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Up and Down
    htp.p('</td></tr></table>'); -- Selection
    htp.p('</td></tr>');
    htp.p('<tr><td></td><td>');
    htp.p('<table><tr><td>');  -- Buttons
    icx_plug_utilities.buttonBoth(l_prompts(10),'javascript:renameLeftTo()');
    htp.p('</td><td>');
    icx_plug_utilities.buttonBoth(l_prompts(11),'javascript:deleteLeftTo()');
    htp.p('</td></tr></table>');  -- Buttons
    htp.p('</td></tr>');
    htp.p('</table>');  -- Left
    htp.formClose;

  htp.p('</td><td width=1 bgcolor=#000000><IMG src="/OA_MEDIA/FNDINVDT.gif" width=1></td><td></td><td align=center valign=top>');

    htp.formOpen('','POST','','','NAME="Right"');
    htp.p('<table width="10%" border=0 cellspacing=0 cellpadding=0 valign=top>'); -- right
    htp.p('<tr><td colspan=2 align=center>');
    htp.p('<B>'||l_prompts(14)||'</B>');
    htp.p('</td></tr>');

    htp.p('<tr><td>');
    htp.p(l_prompts(2));
    htp.p('</td><td>');
    htp.p(l_prompts(3));
    htp.p('</td></tr>');
    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>');  -- Options
    htp.p('<select name="B" size=10>');
    l_index := 0;
    l_entries := l_entries_null;
    for r in right_menu_entries loop
        l_entries(l_index).prompt := nvl(r.prompt,r.description);
        l_entries(l_index).description := r.description;
        l_entries(l_index).responsibility_name := r.responsibility_name;
        l_entries(l_index).resp_appl_id := r.responsibility_application_id;
        l_entries(l_index).security_group_id := r.security_group_id;
        l_entries(l_index).responsibility_id := r.responsibility_id;
        l_entries(l_index).menu_id:= r.menu_id;
        l_entries(l_index).entry_sequence := r.entry_sequence;
        l_entries(l_index).function_id := r.function_id;
        l_entries(l_index).type := r.type;
        l_index := l_index + 1;
    end loop;
    if l_entries.COUNT > 0 then
    for i in l_entries.FIRST..l_entries.LAST loop
      if (i > l_entries.FIRST and l_entries(i).prompt = l_entries(i-1).prompt)
      then
        if l_entries(i).type <> 'WWRG'
        then
          htp.formSelectOption(cvalue => l_entries(i).prompt||' ('||l_entries(i).responsibility_name||')',
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        end if;
      elsif (i < l_entries.LAST and l_entries(i).prompt = l_entries(i+1).prompt)
      then
        if l_entries(i).type = 'WWRG'
        then
          htp.formSelectOption(cvalue => l_entries(i).prompt,
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        else
          htp.formSelectOption(cvalue => l_entries(i).prompt||' ('||l_entries(i).responsibility_name||')',
                               cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
        end if;
      else
        htp.formSelectOption(cvalue => l_entries(i).prompt,
                             cattributes => 'VALUE = "'||l_entries(i).resp_appl_id||'@!$#'||l_entries(i).security_group_id||'@!$#'||
          l_entries(i).responsibility_id||'@!$#'||l_entries(i).menu_id||'@!$#'||l_entries(i).entry_sequence||'@!$#'||l_entries(i).prompt||'"');
      end if;
    end loop;
    end if;
    htp.formSelectClose;
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td>'); -- Add
    htp.p('<A HREF="javascript:addRightTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(4))||''';return true">
           <image src="/OA_MEDIA/FNDRTARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(4))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Add
    htp.p('</td></tr></table>'); -- Options
    htp.p('</td><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>'); -- Selection
    htp.p('<select name="C" size=10>');
    for r in right loop
        htp.formSelectOption(cvalue => nvl(r.prompt,r.description),
                             cattributes => 'VALUE = "'||r.responsibility_application_id||'@!$#'||r.security_group_id||'@!$#'||r.responsibility_id||'@!$#'||r.menu_id||'@!$#'||r.entry_sequence||'@!$#'||r.prompt||'@!$#'||r.plug_id||'"');
    end loop;
    htp.formSelectClose;
    htp.p('</td><td align="left">');
    htp.p('<table><tr><td align="left" valign="bottom">'); -- Up and Down
    htp.p('<A HREF="javascript:upRightTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(5))||''';return true">
           <image src="/OA_MEDIA/FNDUPARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(5))||'" BORDER="0"></A>');
    htp.p('</td></tr><tr><td align="left" valign="top">');
    htp.p('<A HREF="javascript:downRightTo()" onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(6))||''';return true">
           <image src="/OA_MEDIA/FNDDNARW.gif" alt="'||icx_util.replace_alt_quotes(l_prompts(6))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- Up and Down
    htp.p('</td></tr></table>'); -- Selection
    htp.p('</td></tr>');
    htp.p('<tr><td></td><td>');
    htp.p('<table><tr><td>');  -- Buttons
    icx_plug_utilities.buttonBoth(l_prompts(10),'javascript:renameRightTo()');
    htp.p('</td><td>');
    icx_plug_utilities.buttonBoth(l_prompts(11),'javascript:deleteRightTo()');
    htp.p('</td></tr></table>');  -- Buttons
    htp.p('</td><td></td></tr>');
    htp.p('</table>');  -- right


  htp.p('</td></tr>');

  htp.p('<tr>
  <td height=1 bgcolor=#000000><IMG src="/OA_MEDIA/FNDINVDT.gif" height=1></td>
  <td height=1 bgcolor=#000000><IMG src="/OA_MEDIA/FNDINVDT.gif" height=1></td>
  <td height=1 width=10 bgcolor=#000000><IMG src="/OA_MEDIA/FNDINVDT.gif" height=1 width=10></td>
  <td height=1 bgcolor=#000000><IMG src="/OA_MEDIA/FNDINVDT.gif" height=1></td>
  </tr>');

  htp.p('<tr><td colspan="4"><BR></td></tr>');

  htp.p('<tr><td align=center colspan=4>');

    Colors(l_prompts(15));

  htp.p('</td></tr>');

  htp.p('<tr><td colspan="4"><BR></td></tr>');

  htp.p('<tr><td align=center colspan=4>');

    Refresh(l_page_id,l_prompts(12));

  htp.p('</td></tr>');

  htp.p('<tr><td colspan="4"><BR></td></tr>');

  htp.p('<tr><td colspan=4>');

    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');
    icx_plug_utilities.buttonLeft(l_prompts(7),'javascript:saveCustomization()','FNDJLFOK.gif');
    htp.p('</td><td align="right" width="50%">');
    icx_plug_utilities.buttonRight(l_prompts(8),'javascript:history.go(-1)','FNDJLFCN.gif');
    htp.p('</td></tr></table>');

  htp.p('</td></tr>');
  htp.tableClose;
  htp.formClose;

    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
        htp.p(SQLERRM);

end;

procedure updateCustomization(X in varchar2,
                              Y in varchar2,
                              Z in pls_integer,
                              N in varchar2 default NULL,
                              O in pls_integer default 0) is

type integerTable is table of number index by binary_integer;

type varchar2Table is table of varchar2(240) index by binary_integer;

l_session_id            pls_integer;
l_user_id		pls_integer;
l_page_id               pls_integer;
l_plug_id               integerTable;
l_resp_appl_id          integerTable;
l_security_group_id     integerTable;
l_responsibility_id	integerTable;
l_menu_id               integerTable;
l_entry_sequence	integerTable;
l_display_name_old      varchar2Table;
l_display_name          varchar2Table;
r_plug_id               integerTable;
r_resp_appl_id          integerTable;
r_security_group_id     integerTable;
r_responsibility_id     integerTable;
r_menu_id               integerTable;
r_entry_sequence        integerTable;
r_display_name_old      varchar2Table;
r_display_name          varchar2Table;
l_line			varchar2(240);
l_line_length		pls_integer;
l_point1		pls_integer;
l_point2		pls_integer;
l_point3		pls_integer;
l_point4		pls_integer;
l_point5		pls_integer;
l_point6		pls_integer;
l_point7		pls_integer;
l_point_1_2		pls_integer;
l_point_2_3		pls_integer;
l_point_3_4		pls_integer;
l_point_4_5		pls_integer;
l_point_5_6		pls_integer;
l_point_6_7		pls_integer;
l_length		pls_integer;
l_index			pls_integer;
l_count                 pls_integer;
l_nextcount		pls_integer;
l_lastcount		pls_integer;
l_occurence		pls_integer;
l_function_id		pls_integer;
l_function_type         varchar2(30);
l_prompt		varchar2(80);
l_url			varchar2(240);
l_plsql_call		varchar2(2000);
l_call                  pls_integer;
l_dummy                 pls_integer;
l_toolbar               varchar2(30);
l_banner                varchar2(30);
l_heading               varchar2(30);
l_background            varchar2(30);

cursor plugs is
select *
from   ICX_PAGE_PLUGS
where  PAGE_ID = l_page_id;

begin

if icx_sec.validateSession
then
    l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
    l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
    l_page_id := icx_call.decrypt2(Z);

    l_length := length(X);
    l_index := 0;
    l_occurence := 1;
    l_lastcount := 1;
    while l_lastcount <= l_length loop
	l_nextcount := instr(X,'+',1,l_occurence);
        if l_lastcount <> l_nextcount
	then
	  l_line_length := l_nextcount-l_lastcount;
          l_line := substr(X,l_lastcount,l_line_length);
	  l_point1 := instr(l_line,'@!$#',1,1);
	  l_point2 := instr(l_line,'@!$#',1,2);
	  l_point3 := instr(l_line,'@!$#',1,3);
	  l_point4 := instr(l_line,'@!$#',1,4);
	  l_point5 := instr(l_line,'@!$#',1,5);
	  l_point6 := instr(l_line,'@!$#',1,6);
	  l_point7 := instr(l_line,'@!$#',1,7);
	  l_point_1_2 := l_point2 - l_point1 - 4;
	  l_point_2_3 := l_point3 - l_point2 - 4;
	  l_point_3_4 := l_point4 - l_point3 - 4;
	  l_point_4_5 := l_point5 - l_point4 - 4;
	  l_point_5_6 := l_point6 - l_point5 - 4;
	  l_point_6_7 := l_point7 - l_point6 - 4;

          l_resp_appl_id(l_index) := substr(l_line,1,l_point1-1);
          l_security_group_id(l_index) := substr(l_line,l_point1+4,l_point_1_2);
          l_responsibility_id(l_index) := substr(l_line,l_point2+4,l_point_2_3);
          l_menu_id(l_index) := substr(l_line,l_point3+4,l_point_3_4);
          l_entry_sequence(l_index) := substr(l_line,l_point4+4,l_point_4_5);
          l_display_name_old(l_index) := substr(l_line,l_point5+4,l_point_5_6);
          l_plug_id(l_index) := substr(l_line,l_point6+4,l_point_6_7);
          l_display_name(l_index) := substr(l_line,l_point7+4,length(l_line));

          if l_responsibility_id(l_index) is not null
          then
           if l_plug_id(l_index) is null
           then
            select ICX_PAGE_PLUGS_S.nextval
            into   l_plug_id(l_index)
            from   sys.dual;

            if l_display_name(l_index) = l_display_name_old(l_index)
            then
                l_display_name(l_index) := '';
            end if;

            insert into ICX_PAGE_PLUGS
            (PLUG_ID,
             PAGE_ID,
             DISPLAY_SEQUENCE,
             RESPONSIBILITY_APPLICATION_ID,
             SECURITY_GROUP_ID,
             RESPONSIBILITY_ID,
             MENU_ID,
             ENTRY_SEQUENCE,
             DISPLAY_NAME,
             CREATION_DATE,CREATED_BY,
             LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
            values
            (l_plug_id(l_index),
             l_page_id,
             l_index,
             l_resp_appl_id(l_index),
             l_security_group_id(l_index),
             l_responsibility_id(l_index),
             l_menu_id(l_index),
             l_entry_sequence(l_index),
             l_display_name(l_index),
             sysdate,1,
             sysdate,1,1);
           else
            if l_display_name(l_index) = l_display_name_old(l_index)
            then
              update ICX_PAGE_PLUGS
              set DISPLAY_SEQUENCE = l_index,
                  RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id(l_index),
                  SECURITY_GROUP_ID = l_security_group_id(l_index),
                  RESPONSIBILITY_ID = l_responsibility_id(l_index),
                  MENU_ID = l_menu_id(l_index),
                  ENTRY_SEQUENCE = l_entry_sequence(l_index)
              where PAGE_ID = l_page_id
              and   PLUG_ID = l_plug_id(l_index);
            else
              update ICX_PAGE_PLUGS
              set DISPLAY_SEQUENCE = l_index,
                  RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id(l_index),
                  SECURITY_GROUP_ID = l_security_group_id(l_index),
                  RESPONSIBILITY_ID = l_responsibility_id(l_index),
                  MENU_ID = l_menu_id(l_index),
                  ENTRY_SEQUENCE = l_entry_sequence(l_index),
                  DISPLAY_NAME = l_display_name(l_index)
              where PAGE_ID = l_page_id
              and   PLUG_ID = l_plug_id(l_index);
            end if;
           end if;
          end if;

          l_index := l_index + 1;
        end if;

        l_lastcount := l_nextcount + 1;
        l_occurence := l_occurence + 1;
    end loop;

    l_length := length(Y);
    l_index := 0;
    l_occurence := 1;
    l_lastcount := 1;
    while l_lastcount <= l_length loop
        l_nextcount := instr(Y,'+',1,l_occurence);
        if l_lastcount <> l_nextcount
        then
          l_line_length := l_nextcount-l_lastcount;
          l_line := substr(Y,l_lastcount,l_line_length);
          l_point1 := instr(l_line,'@!$#',1,1);
          l_point2 := instr(l_line,'@!$#',1,2);
          l_point3 := instr(l_line,'@!$#',1,3);
          l_point4 := instr(l_line,'@!$#',1,4);
          l_point5 := instr(l_line,'@!$#',1,5);
          l_point6 := instr(l_line,'@!$#',1,6);
          l_point7 := instr(l_line,'@!$#',1,7);
          l_point_1_2 := l_point2 - l_point1 - 4;
          l_point_2_3 := l_point3 - l_point2 - 4;
          l_point_3_4 := l_point4 - l_point3 - 4;
          l_point_4_5 := l_point5 - l_point4 - 4;
          l_point_5_6 := l_point6 - l_point5 - 4;
          l_point_6_7 := l_point7 - l_point6 - 4;

          r_resp_appl_id(l_index) := substr(l_line,1,l_point1-1);
          r_security_group_id(l_index) := substr(l_line,l_point1+4,l_point_1_2);
          r_responsibility_id(l_index) := substr(l_line,l_point2+4,l_point_2_3);
          r_menu_id(l_index) := substr(l_line,l_point3+4,l_point_3_4);
          r_entry_sequence(l_index) := substr(l_line,l_point4+4,l_point_4_5);
          r_display_name_old(l_index) := substr(l_line,l_point5+4,l_point_5_6);
          r_plug_id(l_index) := substr(l_line,l_point6+4,l_point_6_7);
          r_display_name(l_index) := substr(l_line,l_point7+4,length(l_line));

          if r_responsibility_id(l_index) is not null
          then
           if r_plug_id(l_index) is null
           then
            select ICX_PAGE_PLUGS_S.nextval
            into   r_plug_id(l_index)
            from   sys.dual;

            if r_display_name(l_index) = r_display_name_old(l_index)
            then
                r_display_name(l_index) := '';
            end if;

            insert into ICX_PAGE_PLUGS
            (PLUG_ID,
             PAGE_ID,
             DISPLAY_SEQUENCE,
             RESPONSIBILITY_APPLICATION_ID,
             SECURITY_GROUP_ID,
             RESPONSIBILITY_ID,
             MENU_ID,
             ENTRY_SEQUENCE,
             DISPLAY_NAME,
             CREATION_DATE,CREATED_BY,
             LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
            values
            (r_plug_id(l_index),
             l_page_id,
             l_index,
             r_resp_appl_id(l_index),
             r_security_group_id(l_index),
             r_responsibility_id(l_index),
             r_menu_id(l_index),
             r_entry_sequence(l_index),
             r_display_name(l_index),
             sysdate,1,
             sysdate,1,1);
           else
            if r_display_name(l_index) = r_display_name_old(l_index)
            then
              update ICX_PAGE_PLUGS
              set DISPLAY_SEQUENCE = l_index,
                  RESPONSIBILITY_APPLICATION_ID = r_resp_appl_id(l_index),
                  SECURITY_GROUP_ID = r_security_group_id(l_index),
                  RESPONSIBILITY_ID = r_responsibility_id(l_index),
                  MENU_ID = r_menu_id(l_index),
                  ENTRY_SEQUENCE = r_entry_sequence(l_index)
              where PAGE_ID = l_page_id
              and   PLUG_ID = r_plug_id(l_index);
            else
              update ICX_PAGE_PLUGS
              set DISPLAY_SEQUENCE = l_index,
                  RESPONSIBILITY_APPLICATION_ID = r_resp_appl_id(l_index),
                  SECURITY_GROUP_ID = r_security_group_id(l_index),
                  RESPONSIBILITY_ID = r_responsibility_id(l_index),
                  MENU_ID = r_menu_id(l_index),
                  ENTRY_SEQUENCE = r_entry_sequence(l_index),
                  DISPLAY_NAME = r_display_name(l_index)
              where PAGE_ID = l_page_id
              and   PLUG_ID = r_plug_id(l_index);
            end if;
           end if;
          end if;

          l_index := l_index + 1;
        end if;

        l_lastcount := l_nextcount + 1;
        l_occurence := l_occurence + 1;
    end loop;

    for p in plugs loop
      l_count := 0;
      if l_plug_id.COUNT > 0
      then
        for i in l_plug_id.FIRST..l_plug_id.LAST loop
          if p.plug_id = l_plug_id(i)
          then
            l_count := 1;
          end if;
        end loop;
      end if;
      if r_plug_id.COUNT > 0
      then
        for i in r_plug_id.FIRST..r_plug_id.LAST loop
          if p.plug_id = r_plug_id(i)
          then
            l_count := 1;
          end if;
        end loop;
      end if;

      if l_count = 0
      then

        begin
          select WEB_HTML_CALL
          into   l_plsql_call
          from   FND_FORM_FUNCTIONS a,
                 FND_MENU_ENTRIES b
          where  b.MENU_ID = p.MENU_ID
          and    b.ENTRY_SEQUENCE = p.ENTRY_SEQUENCE
          and    a.FUNCTION_ID = b.FUNCTION_ID;
        exception
          when others then
            l_plsql_call := '';
        end;

        if l_plsql_call is not null
        then
         begin
          l_plsql_call := l_plsql_call||'(p_session_id => '||l_session_id||', p_plug_id => '||p.plug_id||', p_delete => ''Y'')';
          l_call := dbms_sql.open_cursor;
          dbms_sql.parse(l_call,'begin '||l_plsql_call||'; end;',dbms_sql.native);
          l_dummy := dbms_sql.execute(l_call);
          dbms_sql.close_cursor(l_call);
         exception
          when others then
            l_count := l_count;
         end;
        end if;

        delete ICX_PAGE_PLUGS
        where  PAGE_ID = l_page_id
        and    PLUG_ID = p.plug_id;

      end if;
    end loop;

    if N = 'BL'
    then
      l_toolbar    := '#0000CC';
      l_heading    := '#99CCFF';
      l_banner     := '#99CCFF';
      l_background := '#FFFFFF';
    elsif N = 'BR'
    then
      l_toolbar    := '#993300';
      l_heading    := '#FFCC99';
      l_banner     := '#CC6600';
      l_background := '#FFCC99';
    elsif N = 'GR'
    then
      l_toolbar    := '#006666';
      l_heading    := '#99CCCC';
      l_banner     := '#99CCCC';
      l_background := '#FFFBF0';
    elsif N = 'GY'
    then
      l_toolbar    := '#663399';
      l_heading    := '#CC99FF';
      l_banner     := '#CC99FF';
      l_background := '#CCCCCC';
    elsif N = 'YL'
    then
      l_toolbar    := '#666666';
      l_heading    := '#FFFFCC';
      l_banner     := '#CCCCCC';
      l_background := '#FFFFCC';
    elsif N = 'IN'
    then
      l_toolbar    := '#333366';
      l_heading    := '#CCCCCC';
      l_banner     := '#9999CC';
      l_background := '#CCCCCC';
    else
      l_toolbar    := '#0000CC';
      l_heading    := '#99CCFF';
      l_banner     := '#99CCFF';
      l_background := '#FFFFFF';
    end if;

    update ICX_PAGE_COLOR_SCHEME
    set TOOLBAR_COLOR = l_toolbar,
        HEADING_COLOR = l_heading,
        BANNER_COLOR = l_banner,
        BACKGROUND_COLOR = l_background,
        COLOR_SCHEME = N
    where USER_ID = l_user_id;

    update ICX_PAGES
    set REFRESH_RATE = O
    where USER_ID = l_user_id
    and   PAGE_ID = l_page_id;

    icx_plug_utilities.gotoMainMenu;

end if; -- validateSession

exception
    when others then
        htp.p(SQLERRM);

end;

end OraclePlugs;

/
