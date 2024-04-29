--------------------------------------------------------
--  DDL for Package Body ICX_ON_CABO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ON_CABO" as
/* $Header: ICXONCB.pls 120.0 2005/10/07 12:15:54 gjimenez noship $ */

procedure toolbar(p_title varchar2,
                  p_export boolean) is

l_title   varchar2(80);
l_prompts icx_util.g_prompts_table;

l_toolbar icx_cabo.toolbar;

begin

icx_util.getprompts(601, 'ICX_OBIS_TOOLBAR', l_title, l_prompts);

l_toolbar.title := p_title;
if icx_sec.g_function_type = 'WWK'
then
  l_toolbar.menu_url := 'javascript:window.close();';
else
  l_toolbar.menu_url := owa_util.get_cgi_env('SCRIPT_NAME')||'/OracleNavigate.Responsibility';
end if;
l_toolbar.menu_mouseover := l_prompts(7);
l_toolbar.print_frame := 'main';
l_toolbar.print_mouseover := '';
l_toolbar.help_url := 'javascript:top.main.help_window()';
l_toolbar.help_mouseover := l_prompts(5);
if p_export
then
  l_toolbar.custom_option1_url := 'javascript:top.main.document.exportON.submit()';
  l_toolbar.custom_option1_mouseover := l_prompts(6);
  l_toolbar.custom_option1_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_mouseover_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_disabled_gif := 'OA_MEDIA/FNDEXP.gif';
end if;
--add return to home icon
--mputman 1625243
  l_toolbar.custom_option2_url := icx_plug_utilities.getPLSQLagent||'OracleMyPage.Home';
  l_toolbar.custom_option2_mouseover := wf_core.translate('RETURN_TO_HOME');
  l_toolbar.custom_option2_gif := '/OA_MEDIA/FNDHOME.gif';
  l_toolbar.custom_option2_mouseover_gif := '/OA_MEDIA/FNDHOME.gif';

icx_cabo.displaytoolbar(l_toolbar);

end;

procedure findPage(p_flow_appl_id in number,
                   p_flow_code in varchar2,
                   p_page_appl_id in number,
                   p_page_code in varchar2,
                   p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_lines_now in number,
                   p_lines_next in number,
                   p_hidden_name in varchar2,
                   p_hidden_value in varchar2,
                   p_help_url in varchar2) is

l_region_appl_id number;
l_region_code   varchar2(30);

l_search_page_title  varchar2(240);
l_page_title  varchar2(240);
l_page_description varchar2(2000);

l_X varchar2(2000);
l_helpmsg varchar2(240);
l_helptitle varchar2(240);
l_tabs icx_cabo.tabTable;
l_toolbar icx_cabo.toolbar;

begin

icx_cabo.g_base_href := FND_WEB_CONFIG.WEB_SERVER;
icx_cabo.g_plsql_agent := icx_cabo.plsqlagent;

if p_page_code is not null
then
  select  PRIMARY_REGION_APPL_ID,PRIMARY_REGION_CODE,
          NAME,DESCRIPTION
  into    l_region_appl_id,l_region_code,
          l_page_title,l_page_description
  from    AK_FLOW_PAGES_VL
  where   PAGE_CODE = p_page_code
  and     PAGE_APPLICATION_ID = p_page_appl_id
  and     FLOW_CODE = p_flow_code
  and     FLOW_APPLICATION_ID = p_flow_appl_id;
else
  select  REGION_APPLICATION_ID,REGION_CODE,
          NAME,DESCRIPTION
  into    l_region_appl_id,l_region_code,
          l_page_title,l_page_description
  from    AK_REGIONS_VL
  where   REGION_CODE = p_region_code
  and     REGION_APPLICATION_ID = p_region_appl_id;
end if;

l_search_page_title := icx_util.getPrompt(601,'ICX_WEB_ON_QUERY',178,'ICX_SEARCH')||'- '||l_page_title;

l_toolbar.title := l_search_page_title;
l_toolbar.menu_url := 'insert_help_url_here';
l_toolbar.menu_mouseover := '';
l_toolbar.print_frame := 'main';
l_toolbar.print_mouseover := '';
l_toolbar.help_url := 'insert_help_url_here';
l_toolbar.help_mouseover := '';

l_helptitle := '';
l_helpmsg := l_page_description;

l_X := icx_call.encrypt2(p_flow_appl_id||'*'||p_flow_code||'*'||p_page_appl_id||'*'||p_page_code||'*'||l_region_appl_id||'*'||l_region_code||'*'||
       p_lines_now||'*'||p_lines_next||'*'||p_hidden_name||'*'||p_hidden_value||'*'||p_help_url||'****]');

l_tabs(0).name := 'search';
l_tabs(0).text := l_search_page_title;
l_tabs(0).hint := l_page_title;
l_tabs(0).visible := 'true';
l_tabs(0).enabled := 'true';
l_tabs(0).url := icx_cabo.g_base_href||icx_cabo.g_plsql_agent||'OracleON.FindForm?X='||l_X;

l_tabs(1).name := 'results';
l_tabs(1).text := l_page_title;
l_tabs(1).hint := l_page_title;
l_tabs(1).visible := 'true';
l_tabs(1).enabled := 'true';
l_tabs(1).url := 'javascript:top.main.submitFunction();';

icx_cabo.container(p_toolbar => l_toolbar,
               p_helpmsg => l_helpmsg,
               p_helptitle => l_helptitle,
               p_tabs => l_tabs,
               p_action => TRUE);

end;

procedure findForm(p_flow_appl_id in number,
                   p_flow_code in varchar2,
                   p_page_appl_id in number,
                   p_page_code in varchar2,
                   p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_lines_now in number,
                   p_lines_next in number,
                   p_hidden_name in varchar2,
                   p_hidden_value in varchar2,
                   p_help_url in varchar2) is

l_language_code	varchar2(30)	:= icx_sec.getID(icx_sec.pv_language_code);
l_responsibility_id number	:= icx_sec.getID(icx_sec.pv_responsibility_id);

l_message	varchar2(2000);
l_search_page_title    varchar2(240);
l_page_title    varchar2(240);
l_page_description varchar2(2000);
l_region_title  varchar2(80);
l_region_description varchar2(2000);

c_title         varchar2(80);
c_prompts       icx_util.g_prompts_table;
l_lookup_codes	icx_util.g_lookup_code_table;
l_lookup_meanings icx_util.g_lookup_meaning_table;

c_count         number;
l_data_type	varchar2(1);
l_data_type1	varchar2(1);
l_column_name	varchar2(30);
l_flex_definition icx_on_utilities.v80_table;
l_segment_column varchar2(30);
c_attributes    v2000_table;
c_condition     v2000_table;
c_url           varchar2(2000);

l_actions icx_cabo.actionTable;
l_toolbar icx_cabo.toolbar;
l_matchcase_view  varchar2(10); --1550760
l_flow_default_operand     varchar2(10); --1613153
l_icx_custom_call varchar2(80); --1570530 mputman
l_submit VARCHAR2(240);

--begin additions for bulk fetch change from 1574527 mputman
      --collections for bulk fetch
TYPE T_COLUMN_NAME IS TABLE OF AK_OBJECT_ATTRIBUTES.COLUMN_NAME%TYPE;
TYPE T_DATA_TYPE IS TABLE OF AK_ATTRIBUTES.DATA_TYPE%TYPE;
TYPE T_ATTRIBUTE_LABEL_LONG IS TABLE OF AK_REGION_ITEMS_VL.ATTRIBUTE_LABEL_LONG%TYPE;
TYPE T_ICX_CUSTOM_CALL IS TABLE OF AK_REGION_ITEMS.ICX_CUSTOM_CALL%TYPE;

      --record defining plsql table to replace cursor in loop
TYPE t_attr_rec IS RECORD
  (
    COLUMN_NAME           	AK_OBJECT_ATTRIBUTES.COLUMN_NAME%TYPE,
    DATA_TYPE              AK_ATTRIBUTES.DATA_TYPE%TYPE,
    ATTRIBUTE_LABEL_LONG   AK_REGION_ITEMS_VL.ATTRIBUTE_LABEL_LONG%TYPE,
    ICX_CUSTOM_CALL        AK_REGION_ITEMS.ICX_CUSTOM_CALL%TYPE
  );
      --definition of table replacing cursor in loop
  TYPE t_attr_tab is table of t_attr_rec
     index by binary_integer;
    --actual vars to use in logic
P_COLUMN_NAME T_COLUMN_NAME;
P_DATA_TYPE T_DATA_TYPE;
P_ATTRIBUTE_LABEL_LONG T_ATTRIBUTE_LABEL_LONG;
P_ICX_CUSTOM_CALL T_ICX_CUSTOM_CALL;
P_ATTR_TAB t_attr_tab;
-- end additions from bulk fetch 1574527 mputman

cursor FindAttributes is
        select  d.COLUMN_NAME,b.DATA_TYPE,a.ATTRIBUTE_LABEL_LONG,e.ICX_CUSTOM_CALL
        from    AK_ATTRIBUTES b,
                AK_REGIONS c,
                AK_OBJECT_ATTRIBUTES d,
		AK_REGION_ITEMS e,
		AK_REGION_ITEMS_VL a
        where   a.REGION_APPLICATION_ID = p_region_appl_id
        and     a.REGION_CODE = p_region_code
        and     a.NODE_QUERY_FLAG = 'Y'
        and     a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and     a.REGION_CODE = c.REGION_CODE
        and     c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and     a.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and     a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
	and	a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
	and	a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
	and	a.REGION_APPLICATION_ID = e.REGION_APPLICATION_ID
	and	a.REGION_CODE = e.REGION_CODE
	and     a.ATTRIBUTE_APPLICATION_ID = e.ATTRIBUTE_APPLICATION_ID
	and     a.ATTRIBUTE_CODE = e.ATTRIBUTE_CODE
	and	not exists     (select  'X'
				from 	AK_EXCLUDED_ITEMS
				where	RESPONSIBILITY_ID = l_responsibility_id
				and	ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
				and	ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID)
        order by a.DISPLAY_SEQUENCE;

begin


l_matchcase_view := fnd_profile.value('ICX_MATCHCASE_VIEW');

if l_matchcase_view is null
then
l_matchcase_view := 'Unchecked';
end if;

icx_cabo.g_base_href := FND_WEB_CONFIG.WEB_SERVER;
icx_cabo.g_plsql_agent := icx_cabo.plsqlagent;

/* Get condition title, prompts and conditions */

icx_util.getPrompts(601,'ICX_WEB_ON_QUERY',c_title,c_prompts);


c_url := 'OracleON.FindForm?X='||icx_call.encrypt2(p_flow_appl_id||'*'||p_flow_code||'*'||p_page_appl_id||'*'||p_page_code||'*'||p_region_appl_id||'*'||p_region_code||'*'||
         p_lines_next||'*'||p_lines_now||'*'||p_hidden_name||'*'||p_hidden_value||'*'||p_help_url||'****]');

-- Create queryable attribute select list for standard Flows

icx_util.getLookups('ICX_CONDITIONS',l_lookup_codes,l_lookup_meanings);

c_count := 0;
c_attributes(0) := htf.formSelectOption(' ');
c_attributes(1) := '';
for i in 0..1 loop
   --begin bulk fetch changes 1574527 mputman
   OPEN FindAttributes;
   FETCH FindAttributes BULK COLLECT INTO
      P_COLUMN_NAME,
      P_DATA_TYPE,
      P_ATTRIBUTE_LABEL_LONG,
      P_ICX_CUSTOM_CALL;
   CLOSE FindAttributes;

   -- assemble the individual collectors into a collection of collectors
   FOR q IN 1..P_COLUMN_NAME.LAST LOOP
      P_ATTR_TAB(q).COLUMN_NAME:=P_COLUMN_NAME(q);
      P_ATTR_TAB(q).DATA_TYPE:=P_DATA_TYPE(q);
      P_ATTR_TAB(q).ATTRIBUTE_LABEL_LONG:=P_ATTRIBUTE_LABEL_LONG(q);
      P_ATTR_TAB(q).ICX_CUSTOM_CALL:=P_ICX_CUSTOM_CALL(q);
   END LOOP;
  --end block of changes for bulk fetch 1574527 mputman.

   --replaced f.'s with P_ATTR_TAB(f)'s and modified
   --for to use the plsql table instead of cursor
   --to take advantage of bulk fetch (1574527) mputman.

for f in 1..P_ATTR_TAB.LAST loop
    c_count := c_count + 1;
    if P_ATTR_TAB(f).DATA_TYPE = 'DATETIME'
    then
	l_data_type := 'T';
    else
	l_data_type := substr(P_ATTR_TAB(f).DATA_TYPE,1,1);
    end if;
    if c_count = 1
    then
	l_data_type1 := l_data_type;
    end if;
    if substr(nvl(P_ATTR_TAB(f).icx_custom_call,'XXXX'),1,4) = 'FLEX'
    then
	icx_on_utilities.unpack_parameters(P_ATTR_TAB(f).icx_custom_call,l_flex_definition);
	if fnd_flex_apis.get_segment_column
                (x_application_id => l_flex_definition(2),
                 x_id_flex_code => l_flex_definition(3),
                 x_id_flex_num => l_flex_definition(4),
                 x_seg_attr_type => l_flex_definition(5),
                 x_app_column_name => l_segment_column)
        then
                l_column_name := l_segment_column;
        else
                l_column_name := P_ATTR_TAB(f).COLUMN_NAME;
        end if;
    else
	l_column_name := P_ATTR_TAB(f).COLUMN_NAME;
    end if;
    if i = c_count
    then
        c_attributes(i) := '<OPTION VALUE='||l_data_type||l_column_name||' SELECTED>'||P_ATTR_TAB(f).ATTRIBUTE_LABEL_LONG;
    else
        c_attributes(i) := c_attributes(i)||'<OPTION VALUE='||l_data_type||l_column_name||'>'||P_ATTR_TAB(f).ATTRIBUTE_LABEL_LONG;
    end if;
end loop;
c_attributes(i) := c_attributes(i)||htf.formSelectClose;
end loop;

c_condition(0) := htf.formSelectOption(' ');
c_condition(1) := '';

l_flow_default_operand := fnd_profile.value('ICX_FLOW_OPERANDS');
if l_flow_default_operand is null
then
l_flow_default_operand := 'CCONTAIN';
end if;

for x in 0..1 loop
for i in 1..to_number(l_lookup_codes(0)) loop
    if x = 1 and l_data_type1 = 'V' and l_lookup_codes(i) = l_flow_default_operand
    then
	c_condition(x) := c_condition(x)||'<OPTION SELECTED VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
    elsif x = 1 and l_data_type1 <> 'V' and l_lookup_codes(i) = 'AIS'
    then
	c_condition(x) := c_condition(x)||'<OPTION SELECTED VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
    else
	c_condition(x) := c_condition(x)||'<OPTION VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
    end if;
end loop;
c_condition(x) := c_condition(x)||htf.formSelectClose;
end loop;

htp.p('<html>
<BASE HREF="'||icx_cabo.g_base_href||'">
<link rel=stylesheet type="text/css" href="OA_HTML/webtools/images/cabo_styles.css">
<header>');

htp.p('<SCRIPT LANGUAGE="JavaScript">');

htp.p('function help_window(){
             help_win = window.open("'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||'OracleON.IC?X='||icx_call.encrypt2(p_flow_appl_id||'*'||p_flow_code||'*'||p_page_appl_id||'*'||p_page_code||'*'||'ICX_HLP_INQUIRIES'||'**]')||'",
             "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500")};');
--add section to block blind queries --mputman
--mputman changed block blind code 1747066
select  icx_custom_call
into    l_icx_custom_call
from    ak_regions
where   REGION_APPLICATION_ID = p_region_appl_id
and     REGION_CODE = p_region_code;

l_submit:=icx_cabo.g_plsql_agent||'OracleON.IC'; --mputman added 1747066

        if instr(l_icx_custom_call,'LONG') > 0
           then
  fnd_message.set_name('ICX','ICX_OPEN_QUERY2');
  l_message := icx_util.replace_quotes(fnd_message.get);

if p_lines_now = 1
then
    htp.p('function submitFunction() {
		if (document.findForm.i_1.value == "") {
		    alert("'||l_message||'");
		    } else {
          document.findForm.action="'||l_submit||'";
          document.findForm.submit();
		    }
                };');
else

    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == ""
                    '||'&'||'&'||' document.findForm.i_2.value == ""
                    '||'&'||'&'||' document.findForm.i_3.value == ""
                    '||'&'||'&'||' document.findForm.i_4.value == ""
                    '||'&'||'&'||' document.findForm.i_5.value == "") {
                    alert("'||l_message||'");
                    } else {
                   document.findForm.action="'||l_submit||'";
                   document.findForm.submit();
                    }
                };');
end if;

if p_lines_now = 1
then
    htp.p('function resetFunction() {
		document.findForm.reset();
		document.findForm.i_1.value = "";
		};');

    htp.p('function advancedSearch() {
                top.main.location = "'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||c_url||'";
                };');

else
    htp.p('function resetFunction() {
		document.findForm.reset();
                document.findForm.i_1.value = "";
                document.findForm.i_2.value = "";
                document.findForm.i_3.value = "";
                document.findForm.i_4.value = "";
                document.findForm.i_5.value = "";
                };');

    htp.p('function simpleSearch() {
                top.main.location = "'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||c_url||'";
                };');

end if;


        ELSE -- end block blind
fnd_message.set_name('ICX','ICX_OPEN_QUERY');
l_message := icx_util.replace_quotes(fnd_message.get);

if p_lines_now = 1
then
    htp.p('function submitFunction() {
		if (document.findForm.i_1.value == "") {
		    if (confirm("'||l_message||'")) {
          document.findForm.action="'||l_submit||'";
			document.findForm.submit();
                        } else {
                            top.tc.currentTab = 1;
                            top.tabs.location.reload();
                        };
		    } else {
                   document.findForm.action="'||l_submit||'";
                   document.findForm.submit();
		    }
                };'); --1876708 mputman added to confirm: document.findForm.action="'||l_submit||'";

else
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == ""
                    '||'&'||'&'||' document.findForm.i_2.value == ""
                    '||'&'||'&'||' document.findForm.i_3.value == ""
                    '||'&'||'&'||' document.findForm.i_4.value == ""
                    '||'&'||'&'||' document.findForm.i_5.value == "") {
                    if (confirm("'||l_message||'")) {
                   document.findForm.action="'||l_submit||'";
                   document.findForm.submit();
                        }
                    } else {
                   document.findForm.action="'||l_submit||'";
                   document.findForm.submit();
                    }
                };');
end if;

if p_lines_now = 1
then
    htp.p('function resetFunction() {
		document.findForm.reset();
		document.findForm.i_1.value = "";
		};');

    htp.p('function advancedSearch() {
                top.main.location = "'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||c_url||'";
                };');
else
    htp.p('function resetFunction() {
		document.findForm.reset();
                document.findForm.i_1.value = "";
                document.findForm.i_2.value = "";
                document.findForm.i_3.value = "";
                document.findForm.i_4.value = "";
                document.findForm.i_5.value = "";
                };');

   htp.p('function simpleSearch() {
                top.main.location = "'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||c_url||'";
                };');
end if;
        END IF;-- block blinds

htp.p('</SCRIPT>');
htp.p('</header>');
htp.p('<body class=panel>');

icx_plug_utilities.sessionjavascript;

htp.formOpen('javascript:submitFunction()','POST','','','NAME="findForm"');

select  NAME,DESCRIPTION
into    l_page_title,l_page_description
from    AK_FLOW_PAGES_VL
where   PAGE_CODE = p_page_code
and     PAGE_APPLICATION_ID = p_page_appl_id
and     FLOW_CODE = p_flow_code
and     FLOW_APPLICATION_ID = p_flow_appl_id;

l_search_page_title := icx_util.getPrompt(601,'ICX_WEB_ON_QUERY',178,'ICX_SEARCH')||'- '||l_page_title;

/*
select  NAME,DESCRIPTION
into    l_region_title,l_region_description
from    AK_REGIONS_VL
where   REGION_CODE = p_region_code
and     REGION_APPLICATION_ID = p_region_appl_id;
*/

if l_data_type1 = 'V'
then
    fnd_message.set_name('ICX','ICX_FIND_VARCHAR2');
    l_message := fnd_message.get;
else
    fnd_message.set_name('ICX','ICX_FIND_NUMBER');
    l_message := fnd_message.get;
end if;

/*
htp.tableOpen('BORDER=0');
htp.tableRowOpen;
htp.tableData(cvalue => htf.img(curl => '/OA_MEDIA/FNDIFIND.gif', calt => c_prompts(1)));

if p_page_code is not null
then
    htp.tableData(cvalue => '<B><FONT SIZE=+2>'||c_prompts(1)||': '||l_page_title||' </FONT></B>'||l_page_description, cattributes => 'VALIGN="MIDDLE"');
else
    htp.tableData(cvalue => '<B><FONT SIZE=+2>'||c_prompts(1)||': '||l_region_title||'</FONT></B>', cattributes => 'VALIGN="MIDDLE"');
end if;

htp.tableRowClose;
if p_page_code is not null and l_region_description is not null
then
    htp.tableRowOpen;
    htp.tableData('<BR>');
    htp.tableData(l_region_description);
    htp.tableRowClose;
end if;
htp.tableClose;
*/

toolbar(p_title => l_search_page_title,
        p_export => FALSE);


-- htp.nl;
htp.p(l_message);
htp.nl;
htp.nl;

if p_lines_now > 1
then
    fnd_message.set_name('ICX','ICX_FIND_AND_OR_TEXT');
    htp.p(fnd_message.get);htp.nl;

    fnd_message.set_name('ICX','ICX_FIND_AND');
    htp.p(htf.formRadio('o','AND','CHECKED')||fnd_message.get);htp.nl;

    fnd_message.set_name('ICX','ICX_FIND_OR');
    htp.p(htf.formRadio('o','OR')||fnd_message.get);htp.nl;
end if;

htp.p('<!-- Application ID '||p_region_appl_id||' Region '||p_region_code||' -->');

for i in 1..p_lines_now loop

htp.tableOpen('BORDER=0');
    htp.tableRowOpen;
        if i = 1
        then
                htp.tableData(htf.formSelectOpen('a_'||i)||c_attributes(1));
        	htp.tableData(htf.formSelectOpen('c_'||i)||c_condition(1));
        else
                htp.tableData(htf.formSelectOpen('a_'||i)||c_attributes(0));
        	htp.tableData(htf.formSelectOpen('c_'||i)||c_condition(0));
        end if;
        htp.tableData(htf.formText('i_'||i,20));
    htp.tableRowClose;
htp.tableClose;

end loop;

htp.nl;
if l_matchcase_view = 'Unchecked'
then
	htp.p(htf.formCheckbox('m')||c_prompts(6));
	htp.nl;
end if;

if l_matchcase_view = 'Checked'
then
	htp.p(htf.formCheckbox('m','','CHECKED')||c_prompts(6));
	htp.nl;
end if;

if l_matchcase_view = 'Hidden'
then
	fnd_message.set_name('ICX','ICX_MATCHCASE_VIEW');
	l_message := fnd_message.get;
        htp.p(l_message);
 	htp.p(htf.formHidden('m','CHECKED'));
 htp.nl;
end if;

if p_hidden_name is not null
then
        htp.formHidden(p_hidden_name,p_hidden_value);
end if;

htp.p('<SCRIPT LANGUAGE="JavaScript">');
htp.p('top.tc.modifytab(2,"text:'||l_page_title||'")
       top.tabs.location.reload();');
htp.p('</SCRIPT>');

l_actions(0).name := 'Submit';
l_actions(0).text := c_prompts(1);
l_actions(0).actiontype := 'function';
l_actions(0).action := 'top.main.submitFunction()';  -- put your own commands here
l_actions(0).targetframe := 'main';
l_actions(0).enabled := 'b_enabled';
l_actions(0).gap := 'b_narrow_gap';

l_actions(1).name := 'Reset';
l_actions(1).text := c_prompts(2);
l_actions(1).actiontype := 'function';
l_actions(1).action := 'top.main.resetFunction()';  -- put your own commands here
l_actions(1).targetframe := 'main';
l_actions(1).enabled := 'b_enabled';
l_actions(1).gap := 'b_narrow_gap';

l_actions(2).name := 'Nav';
l_actions(2).actiontype := 'function';
if p_lines_now = 5
then
  l_actions(2).text := c_prompts(4);
  l_actions(2).action := 'top.main.simpleSearch()';
else
  l_actions(2).text := c_prompts(3);
  l_actions(2).action := 'top.main.advancedSearch()';
end if;
l_actions(2).targetframe := 'main';
l_actions(2).enabled := 'b_enabled';
l_actions(2).gap := 'b_narrow_gap';

icx_cabo.buttons(p_actions =>l_actions);

htp.p('</FORM>');
htp.p('</body>');

exception
	when others then
		htp.p(SQLERRM);
end;

procedure displayPage is

l_timer		number;

l_flow_appl_id  number(15);
l_flow_code     varchar2(30);
l_page_appl_id	number(15);
l_page_code	varchar2(30);

l_region_count	number;
l_region_temp	number;
l_region_seq_temp number;
l_region	number_table;
l_region_seq	number_table;
l_prompt	varchar2(50);
l_S		varchar2(2000);
l_language_code varchar2(30)	:= icx_sec.getID(icx_sec.pv_language_code);
l_cookie        owa_cookie.cookie;
l_page_title    varchar2(240);
l_page_description varchar2(2000);
l_region_description varchar2(2000);
l_message	varchar2(2000);
l_status	varchar2(240);
l_continue	boolean;

l_actions icx_cabo.actionTable;
l_toolbar icx_cabo.toolbar;

begin

icx_cabo.g_base_href := FND_WEB_CONFIG.WEB_SERVER;
icx_cabo.g_plsql_agent := icx_cabo.plsqlagent;

-- select HSECS into l_timer from v$timer;htp.p('begin displayPage @ '||l_timer);htp.nl;

l_flow_appl_id := ak_query_pkg.g_regions_table(ak_query_pkg.g_regions_table.FIRST).flow_application_id;
l_flow_code := ak_query_pkg.g_regions_table(ak_query_pkg.g_regions_table.FIRST).flow_code;
l_page_appl_id := ak_query_pkg.g_regions_table(ak_query_pkg.g_regions_table.FIRST).page_application_id;
l_page_code := ak_query_pkg.g_regions_table(ak_query_pkg.g_regions_table.FIRST).page_code;

select  NAME,DESCRIPTION
into    l_page_title,l_page_description
from    AK_FLOW_PAGES_VL
where   PAGE_CODE = l_page_code
and	PAGE_APPLICATION_ID = l_page_appl_id
and	FLOW_CODE = l_flow_code
and	FLOW_APPLICATION_ID = l_flow_appl_id;

l_cookie := owa_cookie.get('onquery');

htp.htmlOpen;
htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');
htp.p('<link rel=stylesheet type="text/css" href="OA_HTML/webtools/images/cabo_styles.css">');
htp.headOpen;

icx_util.copyright;

htp.p('<SCRIPT LANGUAGE="JavaScript">');
htp.p('function goto_button(X) {self.location="'||icx_cabo.g_base_href||'" + X; };');

htp.p('function help_window(){
             help_win = window.open("'||icx_cabo.g_base_href||icx_cabo.g_plsql_agent||'OracleON.IC?X='||icx_call.encrypt2(l_flow_appl_id||'*'||l_flow_code||'*'||l_page_appl_id||'*'||l_page_code||'*'||'ICX_HLP_INQUIRIES'||'**]')||'",
             "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500")};');

htp.p('</SCRIPT>');

htp.title(l_page_title);
htp.headClose;

   l_S := icx_on_utilities.g_on_parameters(1)||'*'||icx_on_utilities.g_on_parameters(2)||'*'||icx_on_utilities.g_on_parameters(3)||'*'||icx_on_utilities.g_on_parameters(4)||'*'||icx_on_utilities.g_on_parameters(5)
	||'*'||icx_on_utilities.g_on_parameters(6)||'*'||icx_on_utilities.g_on_parameters(7)||'*'||icx_on_utilities.g_on_parameters(8)||'*'||icx_on_utilities.g_on_parameters(9)||'*'||icx_on_utilities.g_on_parameters(10)
	||'*'||icx_on_utilities.g_on_parameters(11)||'*'||icx_on_utilities.g_on_parameters(12)||'*'||icx_on_utilities.g_on_parameters(13)||'*'||icx_on_utilities.g_on_parameters(14)||'*'||icx_on_utilities.g_on_parameters(15)
	||'*'||icx_on_utilities.g_on_parameters(16)||'*'||icx_on_utilities.g_on_parameters(17)||'*'||icx_on_utilities.g_on_parameters(18)||'*'||icx_on_utilities.g_on_parameters(19)||'*'||icx_on_utilities.g_on_parameters(20)
	||'*'||icx_on_utilities.g_on_parameters(21)||'*'||icx_on_utilities.g_on_parameters(22)||'**]';

htp.p('<body class=panel>');
-- htp.p('<FONT SIZE=+2>'||l_page_title||' </FONT>'||l_page_description);
-- htp.nl;
icx_plug_utilities.sessionjavascript;

htp.p('<FORM NAME="exportON" ACTION="'||icx_cabo.g_plsql_agent||'OracleON.csv" METHOD="POST">');
htp.formHidden('S',icx_call.encrypt2(l_S));
htp.p('</FORM>');

if ak_query_pkg.g_results_table.COUNT = 0
then
	htp.p('<!-- Flow '||ak_query_pkg.g_regions_table(0).flow_code||' Page '||ak_query_pkg.g_regions_table(0).page_code||' Region '||ak_query_pkg.g_regions_table(0).region_code||' -->');
        fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
        fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(0).name);
        l_message := fnd_message.get;

        htp.strong(l_message);htp.nl;

else
  l_continue := TRUE;

-- bubble sort for bug 625660
  l_region_count := ak_query_pkg.g_regions_table.COUNT-1;

  if l_region_count > 0
  then

    for x in 0..l_region_count loop
      l_region(x)     := x;
      l_region_seq(x) := ak_query_pkg.g_regions_table(x).display_sequence;
    end loop;

    for x in 0..l_region_count-1 loop
      for y in 0..l_region_count-1-x loop
        if l_region_seq(y) > l_region_seq(y+1)
        then
       	  l_region_seq_temp := l_region_seq(y);
	  l_region_temp := l_region(y);
	  l_region_seq(y) := l_region_seq(y+1);
	  l_region(y) := l_region(y+1);
          l_region_seq(y+1) := l_region_seq_temp;
          l_region(y+1) := l_region_temp;
        end if;
      end loop;
    end loop;

    for x in 0..l_region_count loop
      ak_query_pkg.g_regions_table(l_region(x)).display_sequence := x;
    end loop;

  else
    ak_query_pkg.g_regions_table(0).display_sequence := 0;
  end if;

-- second region loop added for bug 591931
  for c in 0..l_region_count loop
    for r in 0..l_region_count loop

    if r = ak_query_pkg.g_regions_table(c).display_sequence
    then

      if l_continue
      then

      select	DESCRIPTION
      into	l_region_description
      from	AK_REGIONS_VL
      where	REGION_APPLICATION_ID = ak_query_pkg.g_regions_table(r).region_application_id
      and	REGION_CODE = ak_query_pkg.g_regions_table(r).region_code;

      if l_region_description is not null
      then
        htp.p(l_region_description);
      end if;

      htp.p('<!-- Flow '||ak_query_pkg.g_regions_table(r).flow_code||' Page '||ak_query_pkg.g_regions_table(r).page_code||' Region '||ak_query_pkg.g_regions_table(r).region_code||' -->');

      if ak_query_pkg.g_regions_table(r).total_result_count = 0
      then
        fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
        fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(r).name);
        l_message := fnd_message.get;

        htp.strong(l_message);htp.nl;

	elsif ak_query_pkg.g_regions_table(r).region_style = 'FORM'
	  and ak_query_pkg.g_regions_table(r).total_result_count > 1
	then
	    fnd_message.set_name('ICX','ICX_LIMIT_ROWS_ONE');
       	    l_message := fnd_message.get;

       	    htp.strong(l_message);
	    l_continue := FALSE;
       	else
       	    icx_on_utilities2.displayRegion(ak_query_pkg.g_regions_table(r).region_rec_id);
      end if; -- total_result_count = 0
      end if; -- l_continue
      end if; -- display_sequence

    end loop; -- regions r
  end loop; -- regions c

end if;  -- COUNT = 0

toolbar(p_title => l_page_title,
        p_export => TRUE);

if (nvl(icx_on_utilities.g_on_parameters(21),'X') <> 'W')
and (icx_on_utilities.g_on_parameters(1) <> 'X')
then

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('top.tc.currentTab = 2;
           top.tc.modifytab(2,"text:'||l_page_title||'")
           top.tabs.location.reload();');

    htp.p('</SCRIPT>');

    icx_cabo.buttons(p_actions =>l_actions);
end if;

htp.htmlClose;

-- select HSECS into l_timer from v$timer;htp.p('end displayPage @ '||l_timer);htp.nl;

end;

procedure wherePage is

l_toolbar               icx_cabo.toolbar;
l_helpmsg               varchar2(240);
l_page_title            varchar2(240);
l_page_description      varchar2(2000);
l_helptitle             varchar2(240);
l_X varchar2(2000);

begin

  select  NAME,DESCRIPTION
  into    l_page_title,l_page_description
  from    AK_FLOW_PAGES_VL
  where   PAGE_CODE = icx_on_utilities.g_on_parameters(5)
  and     PAGE_APPLICATION_ID = icx_on_utilities.g_on_parameters(4)
  and     FLOW_CODE = icx_on_utilities.g_on_parameters(3)
  and     FLOW_APPLICATION_ID = icx_on_utilities.g_on_parameters(2);

  l_toolbar.title := l_page_title;
  l_toolbar.menu_url := 'insert_help_url_here';
  l_toolbar.menu_mouseover := '';
  l_toolbar.print_frame := 'main';
  l_toolbar.print_mouseover := '';
  l_toolbar.help_url := 'insert_help_url_here';
  l_toolbar.help_mouseover := '';
  l_toolbar.custom_option1_url := 'insert_help_url_here';
  l_toolbar.custom_option1_mouseover := '';
  l_toolbar.custom_option1_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_mouseover_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_disabled_gif := 'OA_MEDIA/FNDEXP.gif';


  l_X := icx_call.encrypt2('DQ'||'*'||
                           icx_on_utilities.g_on_parameters(2)||'*'||
                           icx_on_utilities.g_on_parameters(3)||'*'||
                           icx_on_utilities.g_on_parameters(4)||'*'||
                           icx_on_utilities.g_on_parameters(5)||'*'||
                           icx_on_utilities.g_on_parameters(6)||'*'||
                           icx_on_utilities.g_on_parameters(7)||'*'||
                           icx_on_utilities.g_on_parameters(8)||'*'||
                           icx_on_utilities.g_on_parameters(9)||'***]',
                           icx_sec.g_session_id);

  icx_cabo.container(p_toolbar => l_toolbar,
                     p_helpmsg => l_page_description,
                     p_helptitle => '',
                     p_url => icx_cabo.g_base_href||icx_cabo.g_plsql_agent||'oracleON.DisplayWhere?X='||l_X);

ak_query_pkg.g_regions_table(0).flow_application_id := 0;

end;

procedure WFPage is

l_toolbar               icx_cabo.toolbar;
l_helpmsg               varchar2(240);
l_flow_appl_id          number;
l_flow_code             varchar2(30);
l_page_appl_id          number;
l_page_code             varchar2(30);
l_page_title            varchar2(240);
l_page_description      varchar2(2000);
l_helptitle             varchar2(240);
l_X varchar2(2000);

begin

  select  FLOW_APPLICATION_ID,FLOW_CODE,
          TO_PAGE_APPL_ID,TO_PAGE_CODE
  into    l_flow_appl_id,l_flow_code,
          l_page_appl_id,l_page_code
  from    AK_FLOW_REGION_RELATIONS
  where   ROWID = icx_on_utilities.g_on_parameters(10);

  select  NAME,DESCRIPTION
  into    l_page_title,l_page_description
  from    AK_FLOW_PAGES_VL
  where   PAGE_CODE = l_page_code
  and     PAGE_APPLICATION_ID = l_page_appl_id
  and     FLOW_CODE = l_flow_code
  and     FLOW_APPLICATION_ID = l_flow_appl_id;

  l_toolbar.title := l_page_title;
  l_toolbar.menu_url := 'insert_help_url_here';
  l_toolbar.menu_mouseover := '';
  l_toolbar.print_frame := 'main';
  l_toolbar.print_mouseover := '';
  l_toolbar.help_url := 'insert_help_url_here';
  l_toolbar.help_mouseover := '';
  l_toolbar.custom_option1_url := 'insert_help_url_here';
  l_toolbar.custom_option1_mouseover := '';
  l_toolbar.custom_option1_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_mouseover_gif := 'OA_MEDIA/FNDEXP.gif';
  l_toolbar.custom_option1_disabled_gif := 'OA_MEDIA/FNDEXP.gif';

  l_X := icx_call.encrypt2('X'||'*'||
                           icx_on_utilities.g_on_parameters(2)||'*'||
                           icx_on_utilities.g_on_parameters(3)||'*'||
                           icx_on_utilities.g_on_parameters(4)||'*'||
                           icx_on_utilities.g_on_parameters(5)||'*'||
                           icx_on_utilities.g_on_parameters(6)||'*'||
                           icx_on_utilities.g_on_parameters(7)||'*'||
                           icx_on_utilities.g_on_parameters(8)||'*'||
                           icx_on_utilities.g_on_parameters(9)||'*'||
                           icx_on_utilities.g_on_parameters(10)||'*'||
                           icx_on_utilities.g_on_parameters(11)||'*'||
                           icx_on_utilities.g_on_parameters(12)||'*'||
                           icx_on_utilities.g_on_parameters(13)||'*'||
                           icx_on_utilities.g_on_parameters(14)||'*'||
                           icx_on_utilities.g_on_parameters(15)||'*'||
                           icx_on_utilities.g_on_parameters(16)||'*'||
                           icx_on_utilities.g_on_parameters(17)||'*'||
                           icx_on_utilities.g_on_parameters(18)||'*'||
                           icx_on_utilities.g_on_parameters(19)||'*'||
                           icx_on_utilities.g_on_parameters(20)||'*'||
                           icx_on_utilities.g_on_parameters(21)||
                           '***]',
                           icx_sec.g_session_id);

  icx_cabo.container(p_toolbar => l_toolbar,
                     p_helpmsg => l_page_description,
                     p_helptitle => '',
                     p_url => icx_cabo.g_base_href||icx_cabo.g_plsql_agent||'ora
cleON.IC?Y='||l_X);

ak_query_pkg.g_regions_table(0).flow_application_id := 0;

end;

end icx_on_cabo;

/
