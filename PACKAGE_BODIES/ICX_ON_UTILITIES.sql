--------------------------------------------------------
--  DDL for Package Body ICX_ON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ON_UTILITIES" as
/* $Header: ICXONUB.pls 120.1 2005/10/07 13:45:07 gjimenez noship $ */

procedure findPage(p_flow_appl_id in number,
                   p_flow_code in varchar2,
                   p_page_appl_id in number,
                   p_page_code in varchar2,
                   p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_goto_url in varchar2,
                   p_lines_now in number,
		   p_lines_url in varchar2,
                   p_lines_next in number,
                   p_hidden_name in varchar2,
                   p_hidden_value in varchar2,
                   p_help_url in varchar2,
		   p_new_url in varchar2) is

l_language_code varchar2(30);
l_page_title    varchar2(240);
l_region_appl_id number;
l_region_code   varchar2(30);
l_message varchar2(2000);

begin

l_language_code := icx_sec.getID(icx_sec.pv_language_code);

if p_page_code is not null
then
	select  NAME,PRIMARY_REGION_APPL_ID,PRIMARY_REGION_CODE
	into    l_page_title,l_region_appl_id,l_region_code
	from    AK_FLOW_PAGES_VL
	where   PAGE_CODE = p_page_code
	and     PAGE_APPLICATION_ID = p_page_appl_id
	and     FLOW_CODE = p_flow_code
	and     FLOW_APPLICATION_ID = p_flow_appl_id;
else

	select  NAME
	into    l_page_title
	from    AK_REGIONS_VL
	where   REGION_CODE = p_region_code
	and     REGION_APPLICATION_ID = p_region_appl_id;

	l_region_appl_id := p_region_appl_id;
	l_region_code := p_region_code;

end if;

htp.htmlOpen;
htp.headOpen;

icx_util.copyright;

htp.p('<SCRIPT LANGUAGE="JavaScript">');
htp.p('<!-- Hide from old browsers');

icx_admin_sig.help_win_script(p_help_url,l_language_code);

if p_lines_now is null or p_lines_now = 1
then
    htp.p('document.cookie = "onquery=" + self.location.href + ";"');
end if;

htp.p('// -->');
htp.p('</SCRIPT>');

htp.title(l_page_title);
htp.headClose;

icx_admin_sig.toolbar(language_code => l_language_code);

findForm(p_flow_appl_id => p_flow_appl_id,
         p_flow_code => p_flow_code,
         p_page_appl_id => p_page_appl_id,
         p_page_code => p_page_code,
	 p_region_appl_id => l_region_appl_id,
         p_region_code => l_region_code,
         p_goto_url => p_goto_url,
         p_goto_target => '',
         p_lines_now => p_lines_now,
         p_lines_url => p_lines_url,
         p_lines_target => '',
         p_lines_next => p_lines_next,
         p_hidden_name => p_hidden_name,
         p_hidden_value => p_hidden_value,
         p_help_url => p_help_url,
         p_new_url => p_new_url);

icx_sig.footer;
htp.htmlClose;

end;

procedure findIcons(	p_submit in varchar2,
			p_clear in varchar2,
			p_one in varchar2,
			p_more in varchar2,
			p_lines_next in number,
			p_lines_now in number,
			p_url in varchar2,
			p_language_code in varchar2,
			p_clear_button in varchar2,
			p_advanced_button in varchar2) is

l_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

begin

htp.p('<TD>');
icx_util.DynamicButton(P_ButtonText => p_submit,
                       P_ImageFileName => 'FNDBSBMT',
                       P_OnMouseOverText => p_submit,
                       P_HyperTextCall => 'javascript:submitFunction()',
                       P_LanguageCode => p_language_code,
                       P_JavaScriptFlag => FALSE);
htp.p('</TD>');
if (instr(l_browser,'MSIE 3')=0) and nvl(p_clear_button,'Y') = 'Y'
then
htp.p('<TD>');
icx_util.DynamicButton(P_ButtonText => p_clear,
                       P_ImageFileName => 'FNDBCLR',
                       P_OnMouseOverText => p_clear,
                       P_HyperTextCall => 'javascript:resetFunction()',
                       P_LanguageCode => p_language_code,
                       P_JavaScriptFlag => FALSE);
htp.p('</TD>');
end if;
if p_lines_next is not null and nvl(p_advanced_button,'Y') = 'Y'
then
    htp.p('<TD WIDTH=50></TD>');
    htp.p('<TD>');
    if p_lines_next > p_lines_now
    then
        icx_util.DynamicButton(P_ButtonText => p_more,
                               P_ImageFileName => 'FNDBMORC',
                               P_OnMouseOverText => p_more,
                               P_HyperTextCall => p_url,
                               P_LanguageCode => p_language_code,
                               P_JavaScriptFlag => FALSE);
    else
        icx_util.DynamicButton(P_ButtonText => p_one,
                               P_ImageFileName => 'FNDBONEC',
                               P_OnMouseOverText => p_one,
                               P_HyperTextCall => 'javascript:history.back();',
                               P_LanguageCode => p_language_code,
                               P_JavaScriptFlag => FALSE);
    end if;
htp.p('</TD>');
end if;

end;

procedure findForm(p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_goto_url in varchar2,
		   p_goto_target in varchar2,
                   p_lines_now in number,
                   p_lines_url in varchar2,
		   p_lines_target in varchar2,
                   p_lines_next in number,
                   p_hidden_name in varchar2,
                   p_hidden_value in varchar2,
                   p_help_url in varchar2,
		   p_new_url in varchar2,
		   p_LOV_mode in varchar2,
		   p_default_title in varchar2,
                   p_flow_appl_id in number,
                   p_flow_code in varchar2,
                   p_page_appl_id in number,
                   p_page_code in varchar2,
                   p_clear_button in varchar2,
                   p_advanced_button in varchar2) is

l_language_code	varchar2(30)	:= icx_sec.getID(icx_sec.pv_language_code);
l_responsibility_id number	:= icx_sec.getID(icx_sec.pv_responsibility_id);

l_message	varchar2(240);
l_page_title    varchar2(80);
l_page_description varchar2(2000);
l_region_title  varchar2(80);
l_region_description varchar2(2000);
l_icx_custom_call varchar2(80); --1570530 mputman

c_title         varchar2(80);
c_prompts       icx_util.g_prompts_table;
l_lookup_codes	icx_util.g_lookup_code_table;
l_lookup_meanings icx_util.g_lookup_meaning_table;

c_count         number;
l_region_code   varchar2(30);
l_data_type	varchar2(1);
l_data_type1	varchar2(1);
l_column_name	varchar2(30);
l_flex_definition icx_on_utilities.v80_table;
l_segment_column varchar2(30);
l_context_column varchar2(40);
c_attributes    v2000_table;
c_condition     v2000_table;
c_url           varchar2(2000);
c_buttons	varchar2(2000);

cursor FindAttributes is
        select  d.COLUMN_NAME,b.DATA_TYPE,a.ATTRIBUTE_LABEL_LONG,e.ICX_CUSTOM_CALL
        from    AK_ATTRIBUTES b,
                AK_REGIONS c,
                AK_OBJECT_ATTRIBUTES d,
		AK_REGION_ITEMS e,
		AK_REGION_ITEMS_VL a
        where   a.REGION_APPLICATION_ID = p_region_appl_id
        and     a.REGION_CODE = l_region_code
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

/* Get condition title, prompts and conditions */

icx_util.getPrompts(601,'ICX_WEB_ON_QUERY',c_title,c_prompts);

if p_lines_now > 1
and p_region_code = 'ICX_WEBSTORE_SEARCH_ITEMS_R'
then
        l_region_code := 'ICX_WEBSTORE_ITEMS';
elsif p_lines_now > 1
and p_region_code = 'ICX_PO_SUPPL_SEARCH_ITEMS_R'
then
        l_region_code := 'ICX_PO_SUPPL_CATALOG_ITEMS_R';
else
        l_region_code := p_region_code;
end if;

if p_lines_url is null
then
    c_url := 'OracleON.Find?X='||icx_call.encrypt2(p_region_appl_id||'*'||l_region_code||'*'||p_goto_url||'*'||p_lines_next||'*'||p_lines_url||'*'||p_lines_now
	||'*'||p_hidden_name||'*'||p_hidden_value||'*'||p_help_url||'*'||p_new_url||'*'||p_LOV_mode||'*'||p_default_title
	||'*'||p_flow_appl_id||'*'||p_flow_code||'*'||p_page_appl_id||'*'||p_page_code||'**]');
else
    c_url := p_lines_url||icx_call.encrypt2(p_region_appl_id||'*'||l_region_code||'*'||p_goto_url||'*'||p_goto_target||'*'||p_lines_next||'*'||p_lines_url||'*'||p_lines_target||'*'||p_lines_now
	||'*'||p_hidden_name||'*'||p_hidden_value||'*'||p_help_url||'*'||p_new_url||'*'||p_LOV_mode||'*'||p_default_title
	||'*'||p_flow_appl_id||'*'||p_flow_code||'*'||p_page_appl_id||'*'||p_page_code||'**] NAME="'||p_lines_target||'"');
end if;

-- Create description query for Reqs and Store Items search

if p_lines_now = 1
and l_region_code = 'ICX_WEBSTORE_SEARCH_ITEMS_R'
then
	l_context_column := 'XICX_WEBSTORE_ITEM_DESC';
elsif p_lines_now = 1
and l_region_code = 'ICX_PO_SUPPL_SEARCH_ITEMS_R'
then
	l_context_column := 'XICX_WEBREQS_ITEM_DESC';
else

-- Create queryable attribute select list for standard Flows

icx_util.getLookups('ICX_CONDITIONS',l_lookup_codes,l_lookup_meanings);

c_count := 0;
c_attributes(0) := htf.formSelectOption(' ');
c_attributes(1) := '';
for i in 0..1 loop
for f in FindAttributes loop
    c_count := c_count + 1;
    if f.DATA_TYPE = 'DATETIME'
    then
	l_data_type := 'T';
    else
	l_data_type := substr(f.DATA_TYPE,1,1);
    end if;
    if c_count = 1
    then
	l_data_type1 := l_data_type;
    end if;
    if substr(nvl(f.icx_custom_call,'XXXX'),1,4) = 'FLEX'
    then
	icx_on_utilities.unpack_parameters(f.icx_custom_call,l_flex_definition);
	if fnd_flex_apis.get_segment_column
                (x_application_id => l_flex_definition(2),
                 x_id_flex_code => l_flex_definition(3),
                 x_id_flex_num => l_flex_definition(4),
                 x_seg_attr_type => l_flex_definition(5),
                 x_app_column_name => l_segment_column)
        then
                l_column_name := l_segment_column;
        else
                l_column_name := f.COLUMN_NAME;
        end if;
    else
	l_column_name := f.COLUMN_NAME;
    end if;
    if i = c_count
    then
        c_attributes(i) := '<OPTION VALUE='||l_data_type||l_column_name||' SELECTED>'||f.ATTRIBUTE_LABEL_LONG;
    else
        c_attributes(i) := c_attributes(i)||'<OPTION VALUE='||l_data_type||l_column_name||'>'||f.ATTRIBUTE_LABEL_LONG;
    end if;
end loop;
c_attributes(i) := c_attributes(i)||htf.formSelectClose;
end loop;

c_condition(0) := htf.formSelectOption(' ');
c_condition(1) := '';
for x in 0..1 loop
for i in 1..to_number(l_lookup_codes(0)) loop
    if x = 1 and l_data_type1 = 'V' and l_lookup_codes(i) = 'CCONTAIN'
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

end if; -- Store and Reqs item sreach

htp.p('<SCRIPT LANGUAGE="JavaScript">');
htp.p('<!-- Hide from old browsers');

select  icx_custom_call
into    l_icx_custom_call
from    ak_regions
where   REGION_APPLICATION_ID = p_region_appl_id
and     REGION_CODE = l_region_code;

        if instr(l_icx_custom_call,'LONG') > 0
then
  fnd_message.set_name('ICX','ICX_OPEN_QUERY2');
  l_message := icx_util.replace_quotes(fnd_message.get);

  if p_lines_now = 1
  then
    --added findform0 and supporting lines for 1570530 mputman.
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == "") {
                    alert("'||l_message||'");
                    document.findForm.i_1.focus();
                    } else {
                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;
                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
          END IF;
                        htp.p('
                        document.findForm0.submit();
                    }
                }');
  else -- advanced
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == ""
                    '||'&'||'&'||' document.findForm.i_2.value == ""
                    '||'&'||'&'||' document.findForm.i_3.value == ""
                    '||'&'||'&'||' document.findForm.i_4.value == ""
                    '||'&'||'&'||' document.findForm.i_5.value == "") {
                    alert("'||l_message||'");
                    document.findForm.i_1.focus();
                    } else {

                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;

                        var temp=document.findForm.a_2.selectedIndex;
                        document.findForm0.a_2.value=document.findForm.a_2[temp].value;
                        var temp=document.findForm.c_2.selectedIndex;
                        document.findForm0.c_2.value=document.findForm.c_2[temp].value;
                        document.findForm0.i_2.value = document.findForm.i_2.value;

                        var temp=document.findForm.a_3.selectedIndex;
                        document.findForm0.a_3.value=document.findForm.a_3[temp].value;
                        var temp=document.findForm.c_3.selectedIndex;
                        document.findForm0.c_3.value=document.findForm.c_3[temp].value;
                        document.findForm0.i_3.value = document.findForm.i_3.value;

                        var temp=document.findForm.a_4.selectedIndex;
                        document.findForm0.a_4.value=document.findForm.a_4[temp].value;
                        var temp=document.findForm.c_4.selectedIndex;
                        document.findForm0.c_4.value=document.findForm.c_4[temp].value;
                        document.findForm0.i_4.value = document.findForm.i_4.value;

                        var temp=document.findForm.a_5.selectedIndex;
                        document.findForm0.a_5.value=document.findForm.a_5[temp].value;
                        var temp=document.findForm.c_5.selectedIndex;
                        document.findForm0.c_5.value=document.findForm.c_5[temp].value;
                        document.findForm0.i_5.value = document.findForm.i_5.value;

                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
          END IF;
                        htp.p('document.findForm0.o.value = document.findForm.o.value;
                               document.findForm0.submit();
                    }
                }');
  end if; -- lines
else -- not block blind
fnd_message.set_name('ICX','ICX_OPEN_QUERY');
l_message := icx_util.replace_quotes(fnd_message.get);

if p_lines_now = 1
then

   htp.p('function submitFunction() {
		if (document.findForm.i_1.value == "") {
		    if (confirm("'||l_message||'")) {
                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;
                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
          END IF;
                        htp.p('
			               document.findForm0.submit();
                        }
		    } else {
                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;
                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
          END IF;
                        htp.p('
			document.findForm0.submit();
		    }
                }');
  else -- advanced
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == ""
                    '||'&'||'&'||' document.findForm.i_2.value == ""
                    '||'&'||'&'||' document.findForm.i_3.value == ""
                    '||'&'||'&'||' document.findForm.i_4.value == ""
                    '||'&'||'&'||' document.findForm.i_5.value == "") {
                    if (confirm("'||l_message||'")) {
                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;

                        var temp=document.findForm.a_2.selectedIndex;
                        document.findForm0.a_2.value=document.findForm.a_2[temp].value;
                        var temp=document.findForm.c_2.selectedIndex;
                        document.findForm0.c_2.value=document.findForm.c_2[temp].value;
                        document.findForm0.i_2.value = document.findForm.i_2.value;

                        var temp=document.findForm.a_3.selectedIndex;
                        document.findForm0.a_3.value=document.findForm.a_3[temp].value;
                        var temp=document.findForm.c_3.selectedIndex;
                        document.findForm0.c_3.value=document.findForm.c_3[temp].value;
                        document.findForm0.i_3.value = document.findForm.i_3.value;

                        var temp=document.findForm.a_4.selectedIndex;
                        document.findForm0.a_4.value=document.findForm.a_4[temp].value;
                        var temp=document.findForm.c_4.selectedIndex;
                        document.findForm0.c_4.value=document.findForm.c_4[temp].value;
                        document.findForm0.i_4.value = document.findForm.i_4.value;

                        var temp=document.findForm.a_5.selectedIndex;
                        document.findForm0.a_5.value=document.findForm.a_5[temp].value;
                        var temp=document.findForm.c_5.selectedIndex;
                        document.findForm0.c_5.value=document.findForm.c_5[temp].value;
                        document.findForm0.i_5.value = document.findForm.i_5.value;

                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
          END IF;
                        htp.p('document.findForm0.o.value = document.findForm.o.value;
                               document.findForm0.submit();

                        }
                    } else {
                        var temp=document.findForm.a_1.selectedIndex;
                        document.findForm0.a_1.value=document.findForm.a_1[temp].value;
                        var temp=document.findForm.c_1.selectedIndex;
                        document.findForm0.c_1.value=document.findForm.c_1[temp].value;
                        document.findForm0.i_1.value = document.findForm.i_1.value;

                        var temp=document.findForm.a_2.selectedIndex;
                        document.findForm0.a_2.value=document.findForm.a_2[temp].value;
                        var temp=document.findForm.c_2.selectedIndex;
                        document.findForm0.c_2.value=document.findForm.c_2[temp].value;
                        document.findForm0.i_2.value = document.findForm.i_2.value;

                        var temp=document.findForm.a_3.selectedIndex;
                        document.findForm0.a_3.value=document.findForm.a_3[temp].value;
                        var temp=document.findForm.c_3.selectedIndex;
                        document.findForm0.c_3.value=document.findForm.c_3[temp].value;
                        document.findForm0.i_3.value = document.findForm.i_3.value;

                        var temp=document.findForm.a_4.selectedIndex;
                        document.findForm0.a_4.value=document.findForm.a_4[temp].value;
                        var temp=document.findForm.c_4.selectedIndex;
                        document.findForm0.c_4.value=document.findForm.c_4[temp].value;
                        document.findForm0.i_4.value = document.findForm.i_4.value;

                        var temp=document.findForm.a_5.selectedIndex;
                        document.findForm0.a_5.value=document.findForm.a_5[temp].value;
                        var temp=document.findForm.c_5.selectedIndex;
                        document.findForm0.c_5.value=document.findForm.c_5[temp].value;
                        document.findForm0.i_5.value = document.findForm.i_5.value;

                        document.findForm0.m.value = document.findForm.m.value;');
          if p_hidden_name is not null
          THEN
                        htp.p('document.findForm0.'||p_hidden_name||'.value = document.findForm.'||p_hidden_name||'.value;');
end if;
          htp.p('document.findForm0.o.value = document.findForm.o.value;

          document.findForm0.submit();
                           }
                    }');
  end if; -- lines
end if;  -- LONG

if p_lines_now = 1
then
    htp.p('function resetFunction() {
		document.findForm.reset();
		document.findForm.i_1.value = "";
		}');
else
    htp.p('function resetFunction() {
		document.findForm.reset();
                document.findForm.i_1.value = "";
                document.findForm.i_2.value = "";
                document.findForm.i_3.value = "";
                document.findForm.i_4.value = "";
                document.findForm.i_5.value = "";
                }');
end if;

htp.p('// -->');
htp.p('</SCRIPT>');

htp.p('<!-- Application ID '||p_region_appl_id||' Region '||l_region_code||' -->');

--add addtl hidden form to handle submit mputman
htp.formOpen('OracleON.IC','POST','','','NAME="findForm0"');
htp.formHidden('a_1','""');
htp.formHidden('c_1','""');
htp.formHidden('i_1','""');
htp.formHidden('a_2','""');
htp.formHidden('c_2','""');
htp.formHidden('i_2','""');
htp.formHidden('a_3','""');
htp.formHidden('c_3','""');
htp.formHidden('i_3','""');
htp.formHidden('a_4','""');
htp.formHidden('c_4','""');
htp.formHidden('i_4','""');
htp.formHidden('a_5','""');
htp.formHidden('c_5','""');
htp.formHidden('i_5','""');
htp.formHidden('m','""');
if p_hidden_name is not null
THEN
htp.formHidden(p_hidden_name,'""');
END IF;
htp.formHidden('o','""');

htp.formClose;

if p_goto_url is null
then
	htp.formOpen('javascript:submitFunction()','POST','','','NAME="findForm"');
else
	htp.formOpen(p_goto_url,'POST',p_goto_target,'','NAME="findForm"');
end if;

if p_default_title = 'Y'
then

if p_page_code is not null
then
        select  NAME,DESCRIPTION
        into    l_page_title,l_page_description
        from    AK_FLOW_PAGES_VL
        where   PAGE_CODE = p_page_code
        and     PAGE_APPLICATION_ID = p_page_appl_id
        and     FLOW_CODE = p_flow_code
        and     FLOW_APPLICATION_ID = p_flow_appl_id;

end if;

select  NAME,DESCRIPTION
into    l_region_title,l_region_description
from    AK_REGIONS_VL
where   REGION_CODE = l_region_code
and     REGION_APPLICATION_ID = p_region_appl_id;

if l_data_type1 = 'V'
then
    fnd_message.set_name('ICX','ICX_FIND_VARCHAR2');
    l_message := fnd_message.get;
else
    fnd_message.set_name('ICX','ICX_FIND_NUMBER');
    l_message := fnd_message.get;
end if;

htp.tableOpen('BORDER=0');
htp.tableRowOpen;
htp.tableData(cvalue => htf.img(curl => '/OA_MEDIA/FNDIFIND.gif', calt => c_prompts(1)));

if p_page_code is not null
then
    htp.tableData(cvalue => '<B><FONT SIZE=+2>'||c_prompts(1)||': '||l_page_title||' </FONT></B>'||l_page_description, cattributes => 'VALIGN="MIDDLE"');
else
    htp.tableData(cvalue => '<B><FONT SIZE=+2>'||c_prompts(1)||': '||l_region_title||'</FONT></B>', cattributes => 'VALIGN="MIDDLE"');
end if;

if p_new_url is not null
then
        htp.p('<TD>');
        icx_util.DynamicButton(P_ButtonText => c_prompts(5),
                               P_ImageFileName => 'FNDBNEW',
                               P_OnMouseOverText => c_prompts(5),
                               P_HyperTextCall => p_new_url,
                               P_LanguageCode => l_language_code,
                               P_JavaScriptFlag => FALSE);
        htp.p('</TD>');
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
htp.nl;
htp.p(l_message);
htp.nl;
htp.nl;

end if; -- p_default_title = 'Y'

if p_lines_now = 1
and (l_region_code = 'ICX_WEBSTORE_SEARCH_ITEMS_R'
or l_region_code = 'ICX_PO_SUPPL_SEARCH_ITEMS_R')
then
    htp.tableOpen(cborder => 'BORDER=0',
		  cattributes => 'CELLPADDING=0 CELLSPACING=0');
    htp.tableRowOpen;
        htp.tableData(htf.formHidden('a_1',l_context_column));
	htp.tableData(htf.formHidden('c_1','CCONTAIN'));
	htp.tableData(htf.formText('i_1',20), 'LEFT');
	htp.tableData('<BR>');
	htp.tableData('<BR>');
	htp.tableData('<BR>');
	if p_LOV_mode = 'Y'
        then
            findIcons(p_submit  => c_prompts(1),
                      p_clear   => c_prompts(2),
                      p_one     => c_prompts(4),
                      p_more    => c_prompts(3),
                      p_lines_next => p_lines_next,
                      p_lines_now  => p_lines_now,
                      p_url     => c_url,
                      p_language_code => l_language_code,
                      p_clear_button => p_clear_button,
                      p_advanced_button => p_advanced_button);
        end if;
    htp.tableRowClose;
    htp.tableClose;
else

if p_lines_now > 1
then
    fnd_message.set_name('ICX','ICX_FIND_AND_OR_TEXT');
    htp.p(fnd_message.get);htp.nl;

    fnd_message.set_name('ICX','ICX_FIND_AND');
    htp.p(htf.formRadio('o','AND','CHECKED')||fnd_message.get);htp.nl;

    fnd_message.set_name('ICX','ICX_FIND_OR');
    htp.p(htf.formRadio('o','OR')||fnd_message.get);htp.nl;
end if;

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
	if i = 1 and p_LOV_mode = 'Y'
	then
	    findIcons(p_submit	=> c_prompts(1),
		      p_clear	=> c_prompts(2),
		      p_one	=> c_prompts(4),
		      p_more	=> c_prompts(3),
		      p_lines_next => p_lines_next,
		      p_lines_now  => p_lines_now,
		      p_url	=> c_url,
		      p_language_code => l_language_code,
		      p_clear_button => p_clear_button,
                      p_advanced_button => p_advanced_button);
	end if;
    htp.tableRowClose;
htp.tableClose;

end loop;

htp.nl;
  htp.p(htf.formCheckbox('m')||c_prompts(6));
  htp.nl;

end if; -- Store and Reqs

if p_hidden_name is not null
then
        htp.formHidden(p_hidden_name,p_hidden_value);
end if;

if p_LOV_mode = 'N'
then
	htp.nl;
	htp.tableOpen('BORDER=0');
	htp.tableRowOpen;
        findIcons(p_submit  => c_prompts(1),
                  p_clear   => c_prompts(2),
                  p_one     => c_prompts(4),
                  p_more    => c_prompts(3),
                  p_lines_next => p_lines_next,
                  p_lines_now  => p_lines_now,
                  p_url     => c_url,
                  p_language_code => l_language_code,
		  p_clear_button => p_clear_button,
		  p_advanced_button => p_advanced_button);
	htp.tableRowClose;
	htp.tableClose;
end if;

htp.p('</FORM>');

exception
	when others then
		htp.p(SQLERRM);
end;

procedure getRegions(p_where in varchar2) is
l_timer number;

c_type			varchar2(30);
c_rowid			rowid;
l_start			number;
l_end			number;
l_query_set		number;
l_start_region		varchar2(30);
c_encrypted_where	number;
c_unique_key_name	varchar2(30);
c_keys			v80_table;

c_continue boolean;
c_table_count number;

c_inputs1  varchar2(240);
c_inputs2  varchar2(240);
c_inputs3  varchar2(240);
c_inputs4  varchar2(240);
c_inputs5  varchar2(240);
c_inputs6  varchar2(240);
c_inputs7  varchar2(240);
c_inputs8  varchar2(240);
c_inputs9  varchar2(240);
c_inputs10  varchar2(240);
c_outputs1 varchar2(240);
c_outputs2 varchar2(240);
c_outputs3 varchar2(240);
c_outputs4 varchar2(240);
c_outputs5 varchar2(240);
c_outputs6 varchar2(240);
c_outputs7 varchar2(240);
c_outputs8 varchar2(240);
c_outputs9 varchar2(240);
c_outputs10 varchar2(240);
c_call  integer;
c_dummy integer;
l_row_count	number;

l_flow_appl_id  number(15);
l_flow_code     varchar2(30);
c_from_page_appl_id      number(15);
c_from_page_code        varchar2(30);
c_from_region_appl_id number(15);
c_from_region_code   varchar2(30);
c_to_page_appl_id       number(15);
c_to_page_code  varchar2(30);
c_to_region_appl_id number(15);
c_to_region_code   varchar2(30);

l_responsibility_id number(15);
l_user_id number(15);
l_return_children varchar2(1);

l_range_low number;
l_range_high number;
l_where_clause varchar2(2000);
l_query_binds ak_query_pkg.bind_tab;
l_max_rows number;
e_max_rows exception;
l_err_mesg varchar2(240);

cursor regions is
        select  REGION_APPLICATION_ID,REGION_CODE,ICX_CUSTOM_CALL
        from    AK_FLOW_PAGE_REGIONS
        where   FLOW_CODE = l_flow_code
        and     FLOW_APPLICATION_ID = l_flow_appl_id
        and     PAGE_CODE = c_to_page_code
        and     PAGE_APPLICATION_ID = c_to_page_appl_id
        order by DISPLAY_SEQUENCE;

begin

-- select HSECS into l_timer from v$timer;htp.p('begin getRegions @ '||l_timer);htp.nl;

/*
for i in 1..22 loop
        htp.p(i||' = '||nvl(icx_on_utilities.g_on_parameters(i),'NULL'));
        htp.nl;
end loop;
*/

c_type		:= icx_on_utilities.g_on_parameters(1);

c_continue := TRUE;
c_table_count := 1;

if c_type = 'DQ'
then

	l_flow_appl_id	:= icx_on_utilities.g_on_parameters(2);
	l_flow_code	:= icx_on_utilities.g_on_parameters(3);
	c_to_page_appl_id := icx_on_utilities.g_on_parameters(4);
	c_to_page_code	:= icx_on_utilities.g_on_parameters(5);
	l_start		:= nvl(icx_on_utilities.g_on_parameters(6),1);
	l_end		:= icx_on_utilities.g_on_parameters(7);
	l_start_region	:= icx_on_utilities.g_on_parameters(8);
	c_encrypted_where := icx_on_utilities.g_on_parameters(9);

elsif c_type = 'W'
then

	l_flow_appl_id	:= icx_on_utilities.g_on_parameters(2);
	l_flow_code	:= icx_on_utilities.g_on_parameters(3);
	c_to_page_appl_id := icx_on_utilities.g_on_parameters(4);
	c_to_page_code	:= icx_on_utilities.g_on_parameters(5);
        l_start         := nvl(icx_on_utilities.g_on_parameters(6),1);
        l_end           := icx_on_utilities.g_on_parameters(7);
        l_start_region  := icx_on_utilities.g_on_parameters(8);
        c_encrypted_where := icx_on_utilities.g_on_parameters(9);

else

	l_start		:= nvl(icx_on_utilities.g_on_parameters(6),1);
	l_end           := icx_on_utilities.g_on_parameters(7);
	l_start_region	:= icx_on_utilities.g_on_parameters(8);
	c_rowid		:= icx_on_utilities.g_on_parameters(10);
	c_unique_key_name := icx_on_utilities.g_on_parameters(11);
	c_keys(1)	:= icx_on_utilities.g_on_parameters(12);
	c_keys(2)	:= icx_on_utilities.g_on_parameters(13);
	c_keys(3)	:= icx_on_utilities.g_on_parameters(14);
	c_keys(4)	:= icx_on_utilities.g_on_parameters(15);
	c_keys(5)	:= icx_on_utilities.g_on_parameters(16);
	c_keys(6)	:= icx_on_utilities.g_on_parameters(17);
	c_keys(7)	:= icx_on_utilities.g_on_parameters(18);
	c_keys(8)	:= icx_on_utilities.g_on_parameters(19);
	c_keys(9)	:= icx_on_utilities.g_on_parameters(20);
	c_keys(10)	:= icx_on_utilities.g_on_parameters(21);

        select  FLOW_APPLICATION_ID,FLOW_CODE,
                TO_PAGE_APPL_ID,TO_PAGE_CODE
        into    l_flow_appl_id,l_flow_code,
                c_to_page_appl_id,c_to_page_code
        from    AK_FLOW_REGION_RELATIONS
        where   ROWID = c_rowid;

end if;

for r in regions loop

if r.ICX_CUSTOM_CALL is not null and c_continue = TRUE
then

-- ************* Start Custom Call *************************

c_inputs1 := c_keys(1);
c_inputs2 := c_keys(2);
c_inputs3 := c_keys(3);
c_inputs4 := c_keys(4);
c_inputs5 := c_keys(5);
c_inputs6 := c_keys(6);
c_inputs7 := c_keys(7);
c_inputs8 := c_keys(8);
c_inputs9 := c_keys(9);
c_inputs10 := c_keys(10);

c_outputs1 := '123456789012345678901234567890';
c_outputs2 := c_outputs1;
c_outputs3 := c_outputs1;
c_outputs4 := c_outputs1;
c_outputs5 := c_outputs1;
c_outputs6 := c_outputs1;
c_outputs7 := c_outputs1;
c_outputs8 := c_outputs1;
c_outputs9 := c_outputs1;
c_outputs10 := c_outputs1;

c_call := dbms_sql.open_cursor;

dbms_sql.parse(c_call,'begin '||r.ICX_CUSTOM_CALL||'(:c_inputs1,:c_inputs2,:c_inputs3,:c_inputs4,:c_inputs5,:c_inputs6,:c_inputs7,:c_inputs8,:c_inputs9,:c_inputs10,
	:c_outputs1,:c_outputs2,:c_outputs3,:c_outputs4,:c_outputs5,:c_outputs6,:c_outputs7,:c_outputs8,:c_outputs9,:c_outputs10); end;',dbms_sql.native);

dbms_sql.bind_variable(c_call,'c_inputs1',c_inputs1);
dbms_sql.bind_variable(c_call,'c_inputs2',c_inputs2);
dbms_sql.bind_variable(c_call,'c_inputs3',c_inputs3);
dbms_sql.bind_variable(c_call,'c_inputs4',c_inputs4);
dbms_sql.bind_variable(c_call,'c_inputs5',c_inputs5);
dbms_sql.bind_variable(c_call,'c_inputs6',c_inputs6);
dbms_sql.bind_variable(c_call,'c_inputs7',c_inputs7);
dbms_sql.bind_variable(c_call,'c_inputs8',c_inputs8);
dbms_sql.bind_variable(c_call,'c_inputs9',c_inputs9);
dbms_sql.bind_variable(c_call,'c_inputs10',c_inputs10);
dbms_sql.bind_variable(c_call,'c_outputs1',c_outputs1);
dbms_sql.bind_variable(c_call,'c_outputs2',c_outputs2);
dbms_sql.bind_variable(c_call,'c_outputs3',c_outputs3);
dbms_sql.bind_variable(c_call,'c_outputs4',c_outputs4);
dbms_sql.bind_variable(c_call,'c_outputs5',c_outputs5);
dbms_sql.bind_variable(c_call,'c_outputs6',c_outputs6);
dbms_sql.bind_variable(c_call,'c_outputs7',c_outputs7);
dbms_sql.bind_variable(c_call,'c_outputs8',c_outputs8);
dbms_sql.bind_variable(c_call,'c_outputs9',c_outputs9);
dbms_sql.bind_variable(c_call,'c_outputs10',c_outputs10);

c_dummy := dbms_sql.execute(c_call);

dbms_sql.variable_value(c_call,'c_outputs1',c_outputs1);
dbms_sql.variable_value(c_call,'c_outputs2',c_outputs2);
dbms_sql.variable_value(c_call,'c_outputs3',c_outputs3);
dbms_sql.variable_value(c_call,'c_outputs4',c_outputs4);
dbms_sql.variable_value(c_call,'c_outputs5',c_outputs5);
dbms_sql.variable_value(c_call,'c_outputs6',c_outputs6);
dbms_sql.variable_value(c_call,'c_outputs7',c_outputs7);
dbms_sql.variable_value(c_call,'c_outputs8',c_outputs8);
dbms_sql.variable_value(c_call,'c_outputs9',c_outputs9);
dbms_sql.variable_value(c_call,'c_outputs10',c_outputs10);

dbms_sql.close_cursor(c_call);

c_from_region_appl_id := r.REGION_APPLICATION_ID;
c_from_region_code := r.REGION_CODE;

select	count(*)
into	l_row_count
from    AK_FLOW_REGION_RELATIONS a,
        AK_FOREIGN_KEYS b
where   a.FROM_REGION_CODE = c_from_region_code
and     a.FROM_REGION_APPL_ID = c_from_region_appl_id
and     a.FROM_PAGE_CODE = c_to_page_code
and     a.FROM_PAGE_APPL_ID = c_to_page_appl_id
and     a.FLOW_CODE = l_flow_code
and     a.FLOW_APPLICATION_ID = l_flow_appl_id
and     a.FOREIGN_KEY_NAME = b.FOREIGN_KEY_NAME;

if l_row_count = 1
then

select  a.ROWID,b.UNIQUE_KEY_NAME,
	a.TO_PAGE_APPL_ID,a.TO_PAGE_CODE
into    c_rowid,c_unique_key_name,
	c_to_page_appl_id,c_to_page_code
from    AK_FLOW_REGION_RELATIONS a,
        AK_FOREIGN_KEYS b
where   a.FROM_REGION_CODE = c_from_region_code
and     a.FROM_REGION_APPL_ID = c_from_region_appl_id
and     a.FROM_PAGE_CODE = c_to_page_code
and     a.FROM_PAGE_APPL_ID = c_to_page_appl_id
and     a.FLOW_CODE = l_flow_code
and     a.FLOW_APPLICATION_ID = l_flow_appl_id
and     a.FOREIGN_KEY_NAME = b.FOREIGN_KEY_NAME;

c_type := 'X';

c_keys(1) := c_outputs1;
c_keys(2) := c_outputs2;
c_keys(3) := c_outputs3;
c_keys(4) := c_outputs4;
c_keys(5) := c_outputs5;
c_keys(6) := c_outputs6;
c_keys(7) := c_outputs7;
c_keys(8) := c_outputs8;
c_keys(9) := c_outputs9;
c_keys(10) := c_outputs10;

else

c_type := 'Z';
c_continue := FALSE;
ak_query_pkg.g_regions_table(0).flow_application_id := -1;

end if;

-- ************* End Custom Call *************************
end if;

        if c_table_count = 1 and (c_type = 'DQ' or c_type = 'W')
        then

	c_to_region_appl_id := r.REGION_APPLICATION_ID;
	c_to_region_code := r.REGION_CODE;

	l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
	l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
	if c_type = 'W'
	then
	    l_return_children := 'T';
	else
	    l_return_children := 'F';
	end if;

select  QUERY_SET, MAX_ROWS
into    l_query_set, l_max_rows
from    ICX_PARAMETERS;

if l_end is null
then
	l_end := l_start+l_query_set-1;
end if;

-- select HSECS into l_timer from v$timer;htp.p('start exec_query LOV @ '||l_timer);htp.nl;

-- dbms_session.set_sql_trace(TRUE);

unpack_whereSegment(p_where,l_where_clause,l_query_binds);

/* DEBUG TRACE
htp.p('p_where = '||p_where);htp.nl;
htp.p('DEBUG MESSAGE ak_query_pkg.exec_query('''||l_flow_appl_id||''','''||l_flow_code||''','''||c_to_page_appl_id||''','''||c_to_page_code||''','||c_to_region_appl_id||','''||c_to_region_code
        ||''','''||''','''||''','''||''','''||''','''||''','''||''','''||''','''||''','''||''','''||''','''||''','''||
        c_to_page_appl_id||''','''||c_to_page_code||''','''||l_where_clause||''','''||''','||l_responsibility_id||','||l_user_id||',T,'||l_return_children||',F,F,'||l_range_low||','||l_range_high||')');htp.nl;
if l_query_binds.COUNT > 0 then
for i in l_query_binds.FIRST..l_query_binds.LAST loop
  htp.p(l_query_binds(i).name||' '||l_query_binds(i).value);htp.nl;
end loop;
end if;
*/

ak_query_pkg.exec_query(
P_FLOW_APPL_ID => l_flow_appl_id,
P_FLOW_CODE => l_flow_code,
P_PARENT_PAGE_APPL_ID => c_to_page_appl_id,
P_PARENT_PAGE_CODE => c_to_page_code,
P_PARENT_REGION_APPL_ID => c_to_region_appl_id,
P_PARENT_REGION_CODE => c_to_region_code,
P_CHILD_PAGE_APPL_ID => c_to_page_appl_id,
P_CHILD_PAGE_CODE => c_to_page_code,
P_WHERE_CLAUSE => l_where_clause,
P_WHERE_BINDS => l_query_binds,
P_RESPONSIBILITY_ID => l_responsibility_id,
P_USER_ID => l_user_id,
P_RETURN_PARENTS => 'T',
P_RETURN_CHILDREN => l_return_children,
P_RETURN_NODE_DISPLAY_ONLY => 'T',
P_RANGE_LOW => l_start,
P_RANGE_HIGH => l_end,
P_MAX_ROWS => l_max_rows);

if ak_query_pkg.g_regions_table(0).total_result_count = l_max_rows
then
    raise e_max_rows;
end if;

-- icx_on_utilities2.printPLSQLtables;

-- dbms_session.set_sql_trace(FALSE);

-- select HSECS into l_timer from v$timer;htp.p('end exec_query LOV @ '||l_timer);htp.nl;

	c_table_count := 2;
	end if;

	if c_table_count = 1 and (c_type = 'D' or c_type = 'X')
	then

       	select  FROM_PAGE_APPL_ID,FROM_PAGE_CODE,
               	FROM_REGION_APPL_ID,FROM_REGION_CODE
       	into    c_from_page_appl_id,c_from_page_code,
               	c_from_region_appl_id,c_from_region_code
       	from    AK_FLOW_REGION_RELATIONS
       	where   ROWID = c_rowid;

	l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
	l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

/* DEBUG
set serverout on size 200000;
ALTER SESSION SET SQL_TRACE TRUE;
execute
htp.p('DEBUG MESSAGE ak_query_pkg.exec_query('||l_flow_appl_id||','''||l_flow_code||''','||c_from_page_appl_id||','''||c_from_page_code||''','||c_from_region_appl_id||','''||c_from_region_code
	||''','''||c_unique_key_name||''','''||c_keys(1)||''','''||c_keys(2)||''','''||c_keys(3)||''','''||c_keys(4)||''','''||c_keys(5)||''','''||c_keys(6)||''','''||c_keys(7)||''','''||c_keys(8)||''','''||c_keys(9)||''','''||c_keys(10)
	||''','''||c_to_page_appl_id||''','''||c_to_page_code||''','''||''','''||''','||l_responsibility_id||','||l_user_id||',F,T,F,F)');
ALTER SESSION SET SQL_TRACE FALSE;
*/

-- select HSECS into l_timer from v$timer;htp.p('start exec_query PK @ '||l_timer);htp.nl;

-- dbms_session.set_sql_trace(TRUE);

ak_query_pkg.exec_query(
P_FLOW_APPL_ID => l_flow_appl_id,
P_FLOW_CODE => l_flow_code,
P_PARENT_PAGE_APPL_ID => c_from_page_appl_id,
P_PARENT_PAGE_CODE => c_from_page_code,
P_PARENT_REGION_APPL_ID => c_from_region_appl_id,
P_PARENT_REGION_CODE => c_from_region_code,
P_PARENT_PRIMARY_KEY_NAME => c_unique_key_name,
P_PARENT_KEY_VALUE1 => c_keys(1),
P_PARENT_KEY_VALUE2 => c_keys(2),
P_PARENT_KEY_VALUE3 => c_keys(3),
P_PARENT_KEY_VALUE4 => c_keys(4),
P_PARENT_KEY_VALUE5 => c_keys(5),
P_PARENT_KEY_VALUE6 => c_keys(6),
P_PARENT_KEY_VALUE7 => c_keys(7),
P_PARENT_KEY_VALUE8 => c_keys(8),
P_PARENT_KEY_VALUE9 => c_keys(9),
P_PARENT_KEY_VALUE10 => c_keys(10),
P_CHILD_PAGE_APPL_ID => c_to_page_appl_id,
P_CHILD_PAGE_CODE => c_to_page_code,
P_RESPONSIBILITY_ID => l_responsibility_id,
P_USER_ID => l_user_id,
P_RETURN_PARENTS => 'F',
P_RETURN_CHILDREN => 'T',
P_RETURN_NODE_DISPLAY_ONLY => 'T');

-- icx_on_utilities2.printPLSQLtables;

-- dbms_session.set_sql_trace(FALSE);

-- select HSECS into l_timer from v$timer;htp.p('start exec_query PK @ '||l_timer);htp.nl;

	c_table_count := 2;
	end if;

end loop;

exception
    when e_max_rows then
        fnd_message.set_name('ICX','ICX_MAX_ROWS');
        l_err_mesg := fnd_message.get;
        icx_util.add_error(l_err_mesg);
        icx_admin_sig.error_screen(l_err_mesg);
        c_type := 'Z';
        c_continue := FALSE;
        ak_query_pkg.g_regions_table(0).flow_application_id := -1;
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

begin

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

if icx_on_utilities.g_on_parameters(22) = 'Y'
then
    htp.htmlOpen;
    htp.headOpen;
    icx_util.copyright;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('<!-- Hide from old browsers');
    htp.p('function goto_button(X) {self.location=X; };');

    icx_admin_sig.help_win_script('OracleON.IC?X='||icx_call.encrypt2(l_flow_appl_id||'*'||l_flow_code||'*'||l_page_appl_id||'*'||l_page_code||'*'||'ICX_HLP_INQUIRIES'||'**]'),l_language_code);

    htp.p('// -->');
    htp.p('</SCRIPT>');

    htp.title(l_page_title);
    htp.headClose;
else
    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('<!-- Hide from old browsers');
    htp.p('function goto_button(X) {self.location=X; };');
    htp.p('// -->');
    htp.p('</SCRIPT>');
end if;

   l_S := icx_on_utilities.g_on_parameters(1)||'*'||icx_on_utilities.g_on_parameters(2)||'*'||icx_on_utilities.g_on_parameters(3)||'*'||icx_on_utilities.g_on_parameters(4)||'*'||icx_on_utilities.g_on_parameters(5)
	||'*'||icx_on_utilities.g_on_parameters(6)||'*'||icx_on_utilities.g_on_parameters(7)||'*'||icx_on_utilities.g_on_parameters(8)||'*'||icx_on_utilities.g_on_parameters(9)||'*'||icx_on_utilities.g_on_parameters(10)
	||'*'||icx_on_utilities.g_on_parameters(11)||'*'||icx_on_utilities.g_on_parameters(12)||'*'||icx_on_utilities.g_on_parameters(13)||'*'||icx_on_utilities.g_on_parameters(14)||'*'||icx_on_utilities.g_on_parameters(15)
	||'*'||icx_on_utilities.g_on_parameters(16)||'*'||icx_on_utilities.g_on_parameters(17)||'*'||icx_on_utilities.g_on_parameters(18)||'*'||icx_on_utilities.g_on_parameters(19)||'*'||icx_on_utilities.g_on_parameters(20)
	||'*'||icx_on_utilities.g_on_parameters(21)||'*'||icx_on_utilities.g_on_parameters(22)||'**]';

if icx_on_utilities.g_on_parameters(22) = 'Y'
then
  if (l_cookie.num_vals > 0) then
    icx_admin_sig.toolbar(language_code => l_language_code,
			  disp_export => l_S,
			  disp_find => l_cookie.vals(l_cookie.num_vals));
  else
    icx_admin_sig.toolbar(language_code => l_language_code);
  end if;
end if;

htp.p('<FONT SIZE=+2>'||l_page_title||' </FONT>'||l_page_description);
htp.nl;

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

if icx_on_utilities.g_on_parameters(22) = 'Y'
then
    icx_sig.footer;
    htp.htmlClose;
end if;

-- select HSECS into l_timer from v$timer;htp.p('end displayPage @ '||l_timer);htp.nl;

end;

function formatText(c_text in varchar2,
                    c_bold in varchar2,
                    c_italic in varchar2) return varchar2 is

c_return_text varchar2(5000);

begin

if c_text is null
then
	c_return_text := c_ampersand||'nbsp';
else
	c_return_text := c_text;

	if c_bold = 'Y'
	then
		c_return_text := '<B>'||c_return_text||'</B>';
	end if;

        if c_italic = 'Y'
        then
                c_return_text := '<I>'||c_return_text||'</I>';
        end if;
end if;

return c_return_text;

end;

function formatData(c_text in varchar2,
                    c_halign in varchar2,
                    c_valign in varchar2) return varchar2 is

c_return_text varchar2(2000);

begin

if c_text is null
then
        c_return_text := '<TD>'||c_ampersand||'nbsp'||'</TD>';
else
        c_return_text := '<TD ALIGN='||c_halign||' VALIGN='||c_valign||'>'||c_text||'</TD>';
end if;

return c_return_text;

end;


function whereSegment(a_1     in      varchar2,
                      c_1     in      varchar2,
                      i_1     in      varchar2,
                      a_2     in      varchar2,
                      c_2     in      varchar2,
                      i_2     in      varchar2,
                      a_3     in      varchar2,
                      c_3     in      varchar2,
                      i_3     in      varchar2,
                      a_4     in      varchar2,
                      c_4     in      varchar2,
                      i_4     in      varchar2,
                      a_5     in      varchar2,
                      c_5     in      varchar2,
                      i_5     in      varchar2,
		      m       in      varchar2,
		      o       in      varchar2)
		      return varchar2 is

c_attributes    v80_table;
c_conditions    v80_table;
c_inputs        v80_table;

begin

c_attributes(1) := a_1;
c_attributes(2) := a_2;
c_attributes(3) := a_3;
c_attributes(4) := a_4;
c_attributes(5) := a_5;
c_attributes(6) := '';
c_conditions(1) := c_1;
c_conditions(2) := c_2;
c_conditions(3) := c_3;
c_conditions(4) := c_4;
c_conditions(5) := c_5;
c_conditions(6) := '';
c_inputs(1) := i_1;
c_inputs(2) := i_2;
c_inputs(3) := i_3;
c_inputs(4) := i_4;
c_inputs(5) := i_5;
c_inputs(6) := '';

return whereSegment(c_attributes,c_conditions,c_inputs,m,o);

end;

function whereSegment(c_attributes in v80_table,
		      c_conditions in v80_table,
		      c_inputs     in v80_table,
		      p_match	   in varchar2,
		      p_and_or     in varchar2)
		      return varchar2 is

c_where varchar2(2000);
c_data_type varchar2(1);
c_column_name varchar2(30);
l_condition varchar2(30);
l_input	varchar2(240);
l_lower varchar2(10);
l_upper varchar2(10);
c_and varchar2(1);
c_number_input number;
l_query_id number;
l_context_count number;
l_context_input varchar2(80);
l_index number;
l_values v240_table;

begin

c_and := 'N';
c_where := '';
l_index := 0;
for i in 1..5 loop
    if c_attributes(i) is not null and c_conditions(i) is not null
    then
        c_data_type := substr(c_attributes(i),1,1);
        c_column_name := substr(c_attributes(i),2,31);
	l_condition := substr(c_conditions(i),2,31);
        l_input := c_inputs(i);

	if c_data_type = 'X' and l_input is not null
	then
	    l_context_input := translate(l_input,' ,|&;?$">:','~~~~~~~~~~');
	    l_context_input := replace(l_input,' - ',' ~ ');

	    l_context_count := instr(l_input,'~');

-- bug 610969, handle decimal points

	    if l_context_count = 0
	    then
		if instr(l_input,'.') = 0
		then
		    if instr(l_input,'-') = 0
		    then
		        l_input := '%'||l_input||'%';
		    else
			l_input := '{'||l_input||'}';
                    end if;
		else
		    l_input := l_input||'%';
		end if;
	    else
		l_input := replace(l_input,' ','&');
	    end if;

	    select  ICX_CONTEXT_RESULTS_TEMP_S.nextval
            into    l_query_id
            from    sys.dual;

/* -- replace with intermedia !!!
	    ctx_query.contains
                (POLICY_NAME => c_column_name,
                 TEXT_QUERY => l_input,
                 RESTAB => 'ICX_CONTEXT_RESULTS_TEMP',
		 SHARELEVEL => 1,
                 QUERY_ID => l_query_id);
*/

	    c_where := c_where||' CONID = '||l_query_id;
            c_and := 'Y';
-- GK: Make sure this darn code doesnt get executed by adding 1=2
-- mputman 1747066 undo GK change
	elsif c_data_type = 'V' and p_match is null and l_input is not null
	then
	    l_input := upper(l_input);
	    l_upper := substr(l_input,1,1);
	    l_lower := lower(l_upper);

	    if c_and = 'Y' and p_and_or = 'OR'
	    then
		 c_where := c_where||' or ';
	    elsif c_and = 'Y' and p_and_or = 'AND'
            then
		 c_where := c_where||' and ';
	    end if;

            if l_condition = 'IS'
            then
		c_where := c_where||' upper('||c_column_name||') = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
            elsif l_condition = 'NOT'
            then
		c_where := c_where||' upper('||c_column_name||') <> :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
            elsif l_condition = 'CONTAIN'
            then
		c_where := c_where||' upper('||c_column_name||') like :ICXBIND'||l_index;
                l_values(l_index) := '%'||l_input||'%';
                l_index := l_index + 1;
            elsif l_condition = 'START'
            then
                c_where := c_where||' upper('||c_column_name||') like :ICXBIND'||l_index||' and ('||c_column_name||' like :ICXBIND'||to_char(l_index+1)||' or '||c_column_name||' like :ICXBIND'||to_char(l_index+2)||')';
                l_values(l_index) := l_input||'%';
                l_values(l_index+1) := l_lower||'%';
                l_values(l_index+2) := l_upper||'%';
                l_index := l_index + 3;
	    elsif l_condition = 'GREATER'
               or l_condition = 'AFTER'
            then
                c_where := c_where||' upper('||c_column_name||') > :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
            elsif l_condition = 'END'
            then
                c_where := c_where||' upper('||c_column_name||') like :ICXBIND'||l_index;
                l_values(l_index) := '%'||l_input;
                l_index := l_index + 1;
            elsif l_condition = 'LESS'
               or l_condition = 'BEFORE'
            then
                c_where := c_where||' upper('||c_column_name||') < :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
	    else
		c_where := c_where||' upper('||c_column_name||') = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
	    end if; -- l_condition
	    c_and := 'Y';
	else
           if l_condition = 'IS' and l_input is null
            then
                if c_and = 'Y' then c_where := c_where||' and '; end if;
                c_where := c_where||' '||c_column_name||' is null';
                c_and := 'Y';
            elsif l_condition = 'IS'
            then
                if c_and = 'Y' then c_where := c_where||' and '; end if;
                if c_data_type = 'V'
                then
		    c_where := c_where||' '||c_column_name||' = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
		elsif c_data_type = 'D'
		then
		    l_input := upper(l_input);
		    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') = to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                elsif c_data_type = 'N'
                then
                    c_where := c_where||' '||c_column_name||' = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
		elsif c_data_type = 'T'
		then
		    l_input := upper(l_input);
		    c_where := c_where||' '||c_column_name||' = to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                else
                    c_where := c_where||' '||c_column_name||' = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                end if;
                c_and := 'Y';
            elsif l_condition = 'NOT' and l_input is null
            then
                if c_and = 'Y' then c_where := c_where||' and '; end if;
                c_where := c_where||' '||c_column_name||' is not null';
                c_and := 'Y';
            elsif l_condition = 'NOT'
            then
                if c_and = 'Y' then c_where := c_where||' and '; end if;
                if c_data_type = 'V'
                then
		    c_where := c_where||' '||c_column_name||' <> :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                elsif c_data_type = 'D'
                then
		    l_input := upper(l_input);
		    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') <> to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                elsif c_data_type = 'N'
                then
                    c_where := c_where||' '||c_column_name||' <> :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                elsif c_data_type = 'T'
                then
		    l_input := upper(l_input);
                    c_where := c_where||' '||c_column_name||' <> to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                else
                    c_where := c_where||' '||c_column_name||' <> :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                end if;
                c_and := 'Y';
            elsif l_condition = 'CONTAIN'
            then
		if l_input is null
		then
		    null;
                elsif c_data_type = 'D'
                then
		    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' to_char('||c_column_name||') like :ICXBIND'||l_index;
                    l_values(l_index) := '%'||l_input||'%';
                    l_index := l_index + 1;
                    c_and := 'Y';
                else
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
		    c_where := c_where||' '||c_column_name||' like :ICXBIND'||l_index;
                    l_values(l_index) := '%'||l_input||'%';
                    l_index := l_index + 1;
		    c_and := 'Y';
                end if;
            elsif l_condition = 'START'
            then
		if l_input is null
		then
		    null;
                elsif c_data_type = 'V'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
		    c_where := c_where||' '||c_column_name||' like :ICXBIND'||l_index;
                    l_values(l_index) := l_input||'%';
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'D'
                then
		    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
		    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') >= to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'N'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' >= :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'T'
                then
		    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' >= to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                else
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' like :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                end if;
            elsif l_condition = 'GREATER'
               or l_condition = 'AFTER'
            then
                if l_input is null
                then
                    null;
                elsif c_data_type = 'V'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' > :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'D'
                then
                    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') > to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'N'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' > :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'T'
                then
                    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' > to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                else
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' > :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                end if;
            elsif l_condition = 'END'
            then
		if l_input is null
		then
		    null;
                elsif c_data_type = 'V'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
		    c_where := c_where||' '||c_column_name||' like :ICXBIND'||l_index;
                    l_values(l_index) := '%'||l_input;
                    l_index := l_index + 1;
		    c_and := 'Y';
                elsif c_data_type = 'D'
                then
		    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
		    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') <= to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'N'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' <= :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'T'
                then
		    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' <= to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                else
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' like :ICXBIND'||l_index;
                    l_values(l_index) := '%'||l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                end if;
            elsif l_condition = 'LESS'
               or l_condition = 'BEFORE'
            then
                if l_input is null
                then
                    null;
                elsif c_data_type = 'V'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' < :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'D'
                then
                    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    checkDate(l_input);
                    c_where := c_where||' trunc('||c_column_name||') < to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'N'
                then
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' < :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                elsif c_data_type = 'T'
                then
                    l_input := upper(l_input);
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' < to_date(:ICXBIND'||l_index||','|| icx_sec.g_date_format || ')';
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                else
                    if c_and = 'Y' then c_where := c_where||' and '; end if;
                    c_where := c_where||' '||c_column_name||' < :ICXBIND'||l_index;
                    l_values(l_index) := l_input;
                    l_index := l_index + 1;
                    c_and := 'Y';
                end if;
            else
                if c_and = 'Y' then c_where := c_where||' and '; end if;
                c_where := c_where||' '||c_column_name||' = :ICXBIND'||l_index;
                l_values(l_index) := l_input;
                l_index := l_index + 1;
                c_and := 'Y';
            end if;  -- l_condition
	end if; -- p_match
    end if; -- not null
end loop;

if l_values.COUNT > 0
then
  for i in l_values.FIRST..l_values.LAST loop
    l_values(i) := replace(l_values(i),'*','@#$@');
    c_where := c_where||'*'||l_values(i);
-- htp.p('DEBUG 1 = '||l_values(i));htp.nl;
  end loop;
end if;
c_where := c_where||'**]';
-- htp.p('DEBUG 2 = '||c_where);htp.nl;

return c_where;

end;

procedure unpack_whereSegment(p_whereSegment in varchar2,
                              p_where_clause out NOCOPY varchar2,
                              p_query_binds out NOCOPY ak_query_pkg.bind_tab) is
l_parameters v2000_table;
l_index number;
begin

l_index := 0;
unpack_parameters(p_whereSegment,l_parameters);
p_where_clause := l_parameters(1);
if l_parameters.COUNT > 1
then
  for i in 2..l_parameters.LAST loop
    if l_parameters(i) is not null
    then
      p_query_binds(l_index).name := 'ICXBIND'||l_index;
      p_query_binds(l_index).value := replace(l_parameters(i),'@#$@','*');
      l_index := l_index + 1;


    end if;
  end loop;
end if;
end;

procedure unpack_whereSegment (p_whereSegment in varchar2,
                               p_query_binds IN out NOCOPY ak_query_pkg.bind_tab,
                               p_query_binds_index IN NUMBER) is
   -- This version of unpack_whereSegment is used with an additional bound where
   -- clause being passed to ICX from the product teams.
l_parameters v2000_table;
l_index number;
l_bind_index NUMBER;
begin

   l_index := 0; -- running index of next bind name
   l_bind_index:=p_query_binds_index; -- running index of next in line for plsql table

--turn the delimited string into a plsql table.
unpack_parameters(p_whereSegment,l_parameters);

  for i in 1..l_parameters.LAST loop
    if l_parameters(i) is not null
    then

      p_query_binds(l_bind_index).name := 'ICXBIND_W'||l_index;
      p_query_binds(l_bind_index).value := replace(l_parameters(i),'@#$@','*');
      l_index := l_index + 1;
      l_bind_index:=l_bind_index +1;
    end if;
  end loop;
end;



procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v80_table) is
        c_param         number(15);
        c_count         number(15);
        c_char          varchar2(4);
        c_word          varchar2(240);
	l_length	number(15);
begin

l_length := length(Y) + 1;
c_param := 1;
c_count := 0;
c_char := '';
c_word := '';

while nvl(c_char,'x') <> ']' and c_count < l_length loop
        if nvl(c_char,'x') <> '*'
        then
                c_word := c_word||c_char;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
        else
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
                c_word := replace(c_word,'~at~','*');
                c_word := replace(c_word,'~end~',']');
                c_parameters(c_param) := c_word;
                c_word := '';
                c_param := c_param + 1;
        end if;
end loop;

end;

procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v240_table) is
        c_param         number(15);
        c_count         number(15);
        c_char          varchar2(4);
        c_word          varchar2(240);
	l_length        number(15);
begin

l_length := length(Y) + 1;
c_param := 1;
c_count := 0;
c_char := '';
c_word := '';

while nvl(c_char,'x') <> ']' and c_count < l_length loop
        if nvl(c_char,'x') <> '*'
        then
                c_word := c_word||c_char;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
        else
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
                c_word := replace(c_word,'~at~','*');
                c_word := replace(c_word,'~end~',']');
                c_parameters(c_param) := c_word;
                c_word := '';
                c_param := c_param + 1;
        end if;
end loop;

end;

procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v2000_table) is
        c_param         number(15);
        c_count         number(15);
        c_char          varchar2(4);
        c_word          varchar2(2000);
        l_length        number(15);
begin

l_length := length(Y) + 1;
c_param := 1;
c_count := 0;
c_char := '';
c_word := '';

while nvl(c_char,'x') <> ']' and c_count < l_length loop
        if nvl(c_char,'x') <> '*'
        then
                c_word := c_word||c_char;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
        else
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
                c_word := replace(c_word,'~at~','*');
                c_word := replace(c_word,'~end~',']');
                c_parameters(c_param) := c_word;
                c_word := '';
                c_param := c_param + 1;
        end if;
end loop;

end;

procedure checkDate(p_date in varchar2) is

l_dummy_date date;
l_dummy_varchar2 varchar2(100);
l_dummy_db_date VARCHAR2(100);--mputman 1618876
C_date_format VARCHAR2(100); --mputman 1618876

begin

   -- begin changes for 1618876 --mputman
   -- changed to be more flexible and to work better in stateful envs.

   --select	to_char(to_date(p_date))
   --into	l_dummy_varchar2
   --from	sys.dual;
   l_dummy_db_date:=icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT');

   IF (nvl(icx_sec.g_date_format,'X') <> nvl(icx_sec.g_date_format_c,'Y')) or
      (nvl(icx_sec.g_date_format_c,'Y') <> l_dummy_db_date) THEN

      c_date_format  := ''''||icx_sec.g_date_format||'''';
      dbms_session.set_nls('NLS_DATE_FORMAT', c_date_format);
      icx_sec.g_date_format_c := icx_sec.g_date_format;

   END IF;

select  to_date(p_date,icx_sec.g_date_format)
into    l_dummy_date
from    sys.dual;
-- end changes for 1618876

if p_date <> l_dummy_varchar2
then
	select to_date(p_date,'XX-XXX-XXXX')
	into l_dummy_date
	from sys.dual;
end if;

end;

function buildOracleONstring(p_rowid    in varchar2,
                        p_primary_key   in varchar2,
                        p1              in varchar2,
                        p2              in varchar2,
                        p3              in varchar2,
                        p4              in varchar2,
                        p5              in varchar2,
                        p6              in varchar2,
                        p7              in varchar2,
                        p8              in varchar2,
                        p9              in varchar2,
                        p10             in varchar2)
                        return varchar2 is
l_parameter varchar2(2000);

begin

l_parameter := 'D*****1****'||p_rowid||'*'||p_primary_key||'*'
		||p1||'*'
		||p2||'*'
		||p3||'*'
		||p4||'*'
		||p5||'*'
		||p6||'*'
		||p7||'*'
		||p8||'*'
		||p9||'*'
		||p10||'**]';

return l_parameter;

end;

function buildOracleONstring2(p_flow_application_id in varchar2,
                        p_flow_code                 in varchar2,
                        p_page_application_id       in varchar2,
                        p_page_code                 in varchar2,
                        p_where_segment             in varchar2)
                        return varchar2 is
l_parameter varchar2(2000);

begin

l_parameter := 'W*'
                ||p_flow_application_id||'*'
                ||p_flow_code||'*'
                ||p_page_application_id||'*'
                ||p_page_code||'*'
                ||p_where_segment||'**]';

return l_parameter;

end;

procedure printRegions(p_rowid    in varchar2,
                        p_primary_key   in varchar2,
                        p1              in varchar2,
                        p2              in varchar2,
                        p3              in varchar2,
                        p4              in varchar2,
                        p5              in varchar2,
                        p6              in varchar2,
                        p7              in varchar2,
                        p8              in varchar2,
                        p9              in varchar2,
                        p10             in varchar2) is
l_dummy_table	icx_on_utilities.v80_table;
begin

icx_on_utilities.g_on_parameters(1) := 'X';
icx_on_utilities.g_on_parameters(2) := '';
icx_on_utilities.g_on_parameters(3) := '';
icx_on_utilities.g_on_parameters(4) := '';
icx_on_utilities.g_on_parameters(5) := '';
icx_on_utilities.g_on_parameters(6) := '1';
icx_on_utilities.g_on_parameters(7) := '';
icx_on_utilities.g_on_parameters(8) := '';
icx_on_utilities.g_on_parameters(9) := '';
icx_on_utilities.g_on_parameters(10) := p_rowid;
icx_on_utilities.g_on_parameters(11) := p_primary_key;
icx_on_utilities.g_on_parameters(12) := p1;
icx_on_utilities.g_on_parameters(13) := p2;
icx_on_utilities.g_on_parameters(14) := p3;
icx_on_utilities.g_on_parameters(15) := p4;
icx_on_utilities.g_on_parameters(16) := p5;
icx_on_utilities.g_on_parameters(17) := p6;
icx_on_utilities.g_on_parameters(18) := p7;
icx_on_utilities.g_on_parameters(19) := p8;
icx_on_utilities.g_on_parameters(20) := p9;
icx_on_utilities.g_on_parameters(21) := p10;
icx_on_utilities.g_on_parameters(22) := 'N';

icx_on.get_page(l_dummy_table,l_dummy_table,l_dummy_table,'','');

end;

procedure printRegions2(p_flow_application_id in varchar2,
                        p_flow_code                 in varchar2,
                        p_page_application_id       in varchar2,
                        p_page_code                 in varchar2,
                        p_where_segment             in varchar2) is
l_dummy_table   icx_on_utilities.v80_table;
begin

icx_on_utilities.g_on_parameters(1) := 'W';
icx_on_utilities.g_on_parameters(2) := p_flow_application_id;
icx_on_utilities.g_on_parameters(3) := p_flow_code;
icx_on_utilities.g_on_parameters(4) := p_page_application_id;
icx_on_utilities.g_on_parameters(5) := p_page_code;
icx_on_utilities.g_on_parameters(6) := p_where_segment;
icx_on_utilities.g_on_parameters(7) := '';
icx_on_utilities.g_on_parameters(8) := '';
icx_on_utilities.g_on_parameters(9) := '';
icx_on_utilities.g_on_parameters(10) := '';
icx_on_utilities.g_on_parameters(11) := '';
icx_on_utilities.g_on_parameters(12) := '';
icx_on_utilities.g_on_parameters(13) := '';
icx_on_utilities.g_on_parameters(14) := '';
icx_on_utilities.g_on_parameters(15) := '';
icx_on_utilities.g_on_parameters(16) := '';
icx_on_utilities.g_on_parameters(17) := '';
icx_on_utilities.g_on_parameters(18) := '';
icx_on_utilities.g_on_parameters(19) := '';
icx_on_utilities.g_on_parameters(20) := '';
icx_on_utilities.g_on_parameters(21) := '';
icx_on_utilities.g_on_parameters(22) := 'N';

icx_on.get_page(l_dummy_table,l_dummy_table,l_dummy_table,'','');

end;


end icx_on_utilities;

/
