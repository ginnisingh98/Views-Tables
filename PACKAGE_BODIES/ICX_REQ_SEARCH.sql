--------------------------------------------------------
--  DDL for Package Body ICX_REQ_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_SEARCH" as
/* $Header: ICXSRCHB.pls 115.7 99/07/17 03:25:05 porting sh $ */


------------------------------------------------------------------------
procedure find_form_head_region(p_lines_now number) is
------------------------------------------------------------------------

l_message  varchar2(1000);

begin

fnd_message.set_name('ICX','ICX_OPEN_QUERY');
l_message := icx_util.replace_quotes(fnd_message.get);

if p_lines_now = 1
then
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == "") {
                    if (confirm("'||l_message||'")) {
                        document.findForm.submit();
                        }
                    } else {
                        document.findForm.submit();
                    }
                }');
else
    htp.p('function submitFunction() {
                if (document.findForm.i_1.value == ""
                    '||'&'||'&'||' document.findForm.i_2.value == ""
                    '||'&'||'&'||' document.findForm.i_3.value == ""
                    '||'&'||'&'||' document.findForm.i_4.value == ""
                    '||'&'||'&'||' document.findForm.i_5.value == "") {
                    if (confirm("'||l_message||'")) {
                        document.findForm.submit();
                        }
                    } else {
                        document.findForm.submit();
                    }
                };');
end if;

htp.p('function resetFunction() {
document.findForm.reset();
document.findForm.i_1.value = "";');
if p_lines_now > 1
then
htp.p('document.findForm.i_2.value = "";
document.findForm.i_3.value = "";
document.findForm.i_4.value = "";
document.findForm.i_5.value = "";');
end if;
htp.p('};');


end;

------------------------------------------------------------------------
function chk_exclude_on(v_attribute_code IN varchar2)
         return varchar2 is
------------------------------------------------------------------------
   cursor RespExclAttrs(resp_id number,appl_id number,attr_code varchar2) is
          select attribute_code
          from ak_excluded_items
          where responsibility_id = resp_id
          and resp_application_id = appl_id
          and attribute_code = attr_code;

   v_resp_id number;
   v_attr_code varchar2(80);

begin

    v_resp_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
    if v_resp_id is not NULL then

       open RespExclAttrs(v_resp_id,178,v_attribute_code);
       fetch RespExclAttrs into v_attr_code;
       if RespExclAttrs%NOTFOUND then
	   close RespExclAttrs;
           return 'N';
       else
           close RespExclAttrs;
           return 'Y';
       end if;
    else
       return 'N';
    end if;
end;

-------------------------------------------------------------------
procedure findIcons(    p_submit in varchar2,
                        p_clear in varchar2,
                        p_one in varchar2,
                        p_more in varchar2,
                        p_lines_next in number,
                        p_lines_now in number,
                        p_url in varchar2,
                        p_language_code in varchar2) is
-------------------------------------------------------------------
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
if (instr(l_browser,'MSIE')=0)
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
if p_lines_next is not null
then
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
                               P_HyperTextCall => p_url,
                               P_LanguageCode => p_language_code,
                               P_JavaScriptFlag => FALSE);
    end if;
htp.p('</TD>');
end if;

exception
        when others then
                htp.p(SQLERRM);
end;

-------------------------------------------------------------------
procedure findForm(p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_goto_url in varchar2 default null,
                   p_goto_target in varchar2 default null,
                   p_lines_now in number default 1,
                   p_lines_url in varchar2 default null,
                   p_lines_target in varchar2 default null,
                   p_lines_next in number default 5,
                   p_hidden_name in varchar2 default null,
                   p_hidden_value in varchar2 default null,
                   p_help_url in varchar2 default null,
                   p_new_url in varchar2 default null,
                   p_LOV_mode in varchar2 default 'N',
                   p_default_title in varchar2 default 'Y',
                   p_values in number default null) is
-------------------------------------------------------------------
l_language_code varchar2(30)    := icx_sec.getID(icx_sec.pv_language_code);
l_responsibility_id number      := icx_sec.getID(icx_sec.pv_responsibility_id);

l_message       varchar2(240);
l_page_title    varchar2(30);

c_title         varchar2(50);
c_prompts       icx_util.g_prompts_table;
l_lookup_codes  icx_util.g_lookup_code_table;
l_lookup_meanings icx_util.g_lookup_meaning_table;

c_count         number;
l_data_type     varchar2(1);
c_attributes    icx_on_utilities.v2000_table;
c_condition     icx_on_utilities.v2000_table;
c_input		icx_on_utilities.v80_table;
l_categories    varchar2(2000);
c_url           varchar2(2000);
c_buttons       varchar2(2000);

cursor FindAttributes is
        select  d.COLUMN_NAME,b.DATA_TYPE,a.ATTRIBUTE_LABEL_LONG
        from    AK_ATTRIBUTES b,
                AK_REGIONS c,
                AK_OBJECT_ATTRIBUTES d,
                AK_REGION_ITEMS_VL a
        where   a.REGION_APPLICATION_ID = p_region_appl_id
        and     a.REGION_CODE = p_region_code
        and     a.NODE_QUERY_FLAG = 'Y'
        and     a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and     a.REGION_CODE = c.REGION_CODE
        and     c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and     a.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and     a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        and     a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        and     a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        and     not exists     (select  'X'
                                from    AK_EXCLUDED_ITEMS
                                where   RESPONSIBILITY_ID = l_responsibility_id
                                and     ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
                                and     ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID)
        order by a.DISPLAY_SEQUENCE;

   cursor cat_set is
   select category_set_id,
          validate_flag
   from   mtl_default_sets_view
   WHERE  functional_area_id = 2;

where_clause       varchar2(2000);
v_category_set_id  number;
v_validate_flag    varchar2(1);
l_category_id      number;
l_category_name    number;
l_values           icx_util.char240_table;
l_parameters       icx_on_utilities.v240_table;
l_starts_with	   number;

begin

/* XXXXXXXXXXXXXXXXGet condition title, prompts and conditions */
icx_util.getPrompts(178,'ICX_WEB_ON_QUERY',c_title,c_prompts);

if p_values is not null then
    icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_values), l_parameters);
    for i in l_parameters.COUNT..20 loop
        l_parameters(i) := '';
    end loop;
else
    for i in 1..20 loop
        l_parameters(i) := '';
    end loop;
end if;

c_url := p_lines_url||icx_call.encrypt2(p_region_appl_id||'*'||p_region_code||'*'||p_goto_url||'*'||p_goto_target||'*'||p_lines_next||'*'||
p_lines_url||'*'||p_lines_target||'*'||p_lines_now||'*'||p_hidden_name||'*'||p_hidden_value||'*'||p_help_url||'*'||p_new_url||'*'||p_LOV_mode||'*'||p_default_title||'**] NAME="'||p_lines_target||'"');

icx_util.getLookups('ICX_CONDITIONS',l_lookup_codes,l_lookup_meanings);

/* Create queryable attribute select list */

for i in 1..p_lines_now loop
if i = 1
then
    c_attributes(i) := '';
else
    c_attributes(i) := htf.formSelectOption(' ');
end if;
for f in FindAttributes loop
    if f.DATA_TYPE = 'DATETIME'
    then
        l_data_type := 'T';
    else
        l_data_type := substr(f.DATA_TYPE,1,1);
    end if;
    if l_parameters(1 + ((i-1) * 3)) = l_data_type||f.COLUMN_NAME
    then
        c_attributes(i) := c_attributes(i)||'<OPTION SELECTED VALUE='||l_data_type||f.COLUMN_NAME||'>'||f.ATTRIBUTE_LABEL_LONG;
    else
        c_attributes(i) := c_attributes(i)||'<OPTION VALUE='||l_data_type||f.COLUMN_NAME||'>'||f.ATTRIBUTE_LABEL_LONG;
    end if;
end loop;
c_attributes(i) := c_attributes(i)||htf.formSelectClose;
end loop;

for x in 1..p_lines_now loop
if x = 1
then
    c_condition(x) := '';
else
    c_condition(x) := htf.formSelectOption(' ');
end if;
for i in 1..to_number(l_lookup_codes(0)) loop
    if l_lookup_codes(i) = 'DSTART'
    then
	l_starts_with := x;
    end if;
    if l_parameters(2 + ((x-1) * 3)) = l_lookup_codes(i)
    then
      c_condition(x) := c_condition(x)||'<OPTION SELECTED VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
    else
      if  x = 1
      and l_lookup_codes(i) = 'DSTART'
      and l_parameters(2 + ((i-1) * 3)) is null
      then
        c_condition(x) := c_condition(x)||'<OPTION SELECTED VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
      else
        c_condition(x) := c_condition(x)||'<OPTION VALUE='||l_lookup_codes(i)||'>'||l_lookup_meanings(i);
      end if;
    end if;
end loop;
c_condition(x) := c_condition(x)||htf.formSelectClose;
end loop;

for i in 1..p_lines_now loop
    if l_parameters(3 + ((i-1) * 3)) is not null
    then
	c_input(i) := l_parameters(3 + ((i-1) * 3));
    else
	c_input(i) := '';
    end if;
end loop;

if p_goto_url is null
then
        htp.formOpen('OracleON.IC','POST','','','NAME="findForm"');
else
        htp.formOpen(p_goto_url,'POST',p_goto_target,'','NAME="findForm"');
end if;

if p_default_title = 'Y'
then

select  NAME
into    l_page_title
from    AK_REGIONS_VL
where   REGION_CODE = p_region_code
and     REGION_APPLICATION_ID = p_region_appl_id;

fnd_message.set_name('ICX','ICX_FIND_TEXT');
fnd_message.set_token('REGION_TOKEN',l_page_title);
l_message := fnd_message.get;

htp.tableOpen('BORDER=0');
htp.tableRowOpen;

htp.tableData(cvalue => '<B><FONT size=+2>'||l_message||'</FONT></B>', cattributes => 'VALIGN="MIDDLE"');

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
htp.tableClose;
htp.nl;

end if; -- p_default_title = 'Y'

if 175 = 178 then

      ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 178,
                             P_PARENT_REGION_CODE    => 'ICX_REQ_CATEGORIES',
                             P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                             P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                             P_WHERE_CLAUSE          => ' FUNCTIONAL_AREA_ID = 2',

                             P_RETURN_PARENTS        => 'T',
                             P_RETURN_CHILDREN       => 'F');

       if ak_query_pkg.g_results_table.count > 0 then
        for i in 0 .. ak_query_pkg.g_items_table.LAST loop
         if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CATEGORY_ID'
         then
             l_category_id := ak_query_pkg.g_items_table(i).value_id;
         end if;
         if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CATEGORY_NAME'
         then
             l_category_name := ak_query_pkg.g_items_table(i).value_id;
         end if;
         if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_RELATED_CATEGORY'
         then
             l_category_name := ak_query_pkg.g_items_table(i).value_id;
         end if;
        end loop;

        htp.p('Item Category is');
        l_categories := htf.formSelectOpen('p_cat');
        if l_parameters(16) is null then
          l_categories := l_categories||'<OPTION SELECTED VALUE="">All';
        else
	  l_categories := l_categories||'<OPTION VALUE="">All';
        end if;
        for i in 0 .. ak_query_pkg.g_results_table.last loop
          icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(i),l_values);
	  if l_parameters(16) = l_values(l_category_id) then
            l_categories := l_categories||'<OPTION SELECTED VALUE='||l_values(l_category_id)||'>'||l_values(l_category_name);
	  else
            l_categories := l_categories||'<OPTION VALUE='||l_values(l_category_id)||'>'||l_values(l_category_name);
	  end if;
	end loop;
        l_categories := l_categories||htf.formSelectClose;
        htp.p(l_categories);
       end if; -- no rows
end if; -- 175

for i in 1..p_lines_now loop

htp.tableOpen('BORDER=0');
    htp.tableRowOpen;
        htp.tableData(htf.formSelectOpen('a_'||i)||c_attributes(i));
	htp.tableData(htf.formSelectOpen('c_'||i)||c_condition(i));
        htp.tableData(htf.formText('i_'||i,20,80,c_input(i)));
    htp.tableRowClose;
htp.tableClose;

end loop;

if p_hidden_name is not null
then
        htp.formHidden(p_hidden_name,p_hidden_value);
end if;

if p_LOV_mode = 'N'
then
        htp.nl;
        htp.tableOpen('BORDER=0');
        htp.tableRowOpen;
        findIcons(c_prompts(1),c_prompts(2),c_prompts(4),c_prompts(3),p_lines_next,p_lines_now,c_url,l_language_code);
        htp.tableRowClose;
        htp.tableClose;
end if;

htp.p('</FORM>');

exception
        when others then
                htp.p(SQLERRM);
end;

-------------------------------------------------------------------
procedure itemsearch( n_org number) is
-------------------------------------------------------------------


v_dcdName            varchar2(1000);
v_lang               varchar2(5);

begin

   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


   -- We need to split into 2 frames

   js.scriptOpen;
   htp.p('function openButWin(start_row, end_row, total_row, where, context) {

         var result = "' || v_dcdName ||
                      '/ICX_REQ_SEARCH.itemsearch_buttons?p_start_row=" +                      start_row + "&p_end_row=" + end_row + "&p_total_rows=" +
                      total_row + "&p_where=" + where + "&p_context=" + context;
            open(result, ''k_buttons'');
}
  ');

   js.scriptClose;

   htp.p('<FRAMESET ROWS="*,40" BORDER=0>');
   htp.p('<FRAME SRC="' || v_dcdName ||
         '/ICX_REQ_SEARCH.itemsearch_display' ||
/*?searchX=' ||
        searchX || '&paramX=' || paramX ||  */
         '" NAME="data" FRAMEBORDER=NO MARGINWIDTH=10 MARGINHEIGHT=0 NORESIZE>');

   htp.p('<FRAME NAME="k_buttons" SRC="/OA_HTML/' ||
         v_lang || '/ICXBLUE.htm" FRAMEBORDER=NO MARGINWIDTH=0 MARGINHEIGHT=0 NORESIZE SCROLLING="NO">');
   htp.p('</FRAMESET>');

exception
 when others then
  htp.p(SQLERRM);

end;

-------------------------------------------------------------------
  procedure itemsearch_buttons(p_start_row in number default 1,
                               p_end_row in number default null,
                               p_total_rows in number,
                               p_where in number,
			       p_context in varchar2 default 'Y') is
-------------------------------------------------------------------

v_lang              varchar2(30);
c_query_size        number;

begin

   SELECT QUERY_SET INTO c_query_size FROM ICX_PARAMETERS;

   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     htp.p('<BODY BGCOLOR="#CCCCFF">');

     htp.p('<TABLE BORDER=0>');
     htp.p('<TD>');

   if (p_context = 'N') then
   icx_on_utilities2.displaySetIcons(p_language_code   => v_lang,
                                     p_packproc        => 'ICX_REQ_SEARCH.displayItem',
                                     p_start_row       => p_start_row,
                                     p_stop_row        => p_end_row,
                                     p_encrypted_where => p_where,
                                     p_query_set       => c_query_size,
                                     p_target          => 'parent.frames[0]',
                                     p_row_count       => p_total_rows,
				     p_hidden	       => 'N');
   else
	icx_on_utilities2.displaySetIcons(p_language_code   => v_lang,
                                     p_packproc        => 'ICX_REQ_SEARCH.displayItem',
                                     p_start_row       => p_start_row,
                                     p_stop_row        => p_end_row,
                                     p_encrypted_where => p_where,
                                     p_query_set       => c_query_size,
                                     p_target          => 'parent.frames[0]',
                                     p_row_count       => p_total_rows);
   end if;

--      htp.p('Debug 0');
     htp.p('</TD>');
     htp.p('<TD width=1000></TD><TD>');
     FND_MESSAGE.SET_NAME('ICX','ICX_ADD_TO_ORDER');
     icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                            P_ImageFileName   => 'FNDBNEW.gif',
                            P_OnMouseOverText => FND_MESSAGE.GET,
                            P_HyperTextCall   => 'javascript:parent.frames[0].submit()',
                            P_LanguageCode    => v_lang,
                            P_JavaScriptFlag  => FALSE);

     htp.p('</TD></TABLE>');
     htp.p('</BODY>');

exception
        when others then
                htp.p(SQLERRM);


end;


-------------------------------------------------------------------
procedure itemsearch_display( searchX in varchar2 default null,
			             paramX  in varchar2 default null ) is
-------------------------------------------------------------------

v_lines_url   varchar2(256);
l_search   icx_on_utilities.v240_table;
l_param   icx_on_utilities.v240_table;
v_lines_now   number;
v_lines_next  number;
l_paramX     number;
l_language	varchar2(30);

begin
-- dbms_session.set_sql_trace(TRUE);


 --Check if session is valid
 if (icx_sec.validatesession('ICX_REQS')) then
     l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

     l_paramX := paramX;
     v_lines_url  := 'ICX_REQ_SEARCH.itemsearch_display?searchX=';
     if paramX is not null then
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(paramX), l_param);
        if l_param(4) is null
	and l_param(7) is null
	and l_param(10) is null
	and l_param(13) is null then
	   v_lines_now  := 1;
	   v_lines_next := 5;
	else
	   v_lines_now  := 5;
	   v_lines_next := 1;
	end if;
     else
         v_lines_now  := 1;
         v_lines_next := 5;
     end if;
     if searchX is not null then
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(searchX), l_search);
	v_lines_now  := l_search(5);   -- p_lines_next
        v_lines_next := l_search(8);   -- p_lines_now
        l_paramX     := l_search(10);  -- p_hidden_value
     end if;
     htp.htmlOpen;
       htp.headOpen;
         icx_util.copyright;
       js.scriptOpen;
       find_form_head_region(v_lines_now);
       js.scriptClose;
        htp.headClose;
        htp.bodyOpen('', 'BGCOLOR="#CCCCFF" onLoad="parent.parent.winOpen(''nav'', ''item_search'');  open(''/OA_HTML/' || l_language || '/ICXBLUE.htm'', ''k_buttons'')"' );

        fnd_message.set_name('ICX','ICX_REQS_FIND');
        htp.p(htf.bold(FND_MESSAGE.GET));
       icx_on_utilities.findForm(p_region_appl_id  => 601,
                p_region_code     => 'ICX_PO_SUPPL_SEARCH_ITEMS_R',
                p_goto_url        => 'ICX_REQ_SEARCH.displayItem',
                p_goto_target     => 'data',
                p_lines_now       => v_lines_now,
                p_lines_url       => v_lines_url,
                p_lines_target    => 'data',
                p_lines_next      => v_lines_next,
		p_hidden_name     => 'p_values',
		p_hidden_value    => paramX,
		p_default_title   => 'N');
--		p_values	  => l_paramX );
       htp.bodyClose;
     htp.htmlClose;
 end if;

 -- dbms_session.set_sql_trace(FALSE);


exception
when OTHERS then
  htp.p('searchX = ' || searchX || '<BR>');
  htp.p('paramX = ' || paramX || '<BR>');
  htp.p(SQLERRM);
end;


-------------------------------------------------------------------
procedure total_page(l_cart_id number,
		     l_dest_org_id number,
                     l_rows_added number default 0,
 		     l_rows_updated number default 0,
                     a_1 in varchar2 default null,
                      c_1 in varchar2 default null,
                      i_1 in varchar2 default null,
                      a_2 in varchar2 default null,
                      c_2 in varchar2 default null,
                      i_2 in varchar2 default null,
                      a_3 in varchar2 default null,
                      c_3 in varchar2 default null,
                      i_3 in varchar2 default null,
                      a_4 in varchar2 default null,
                      c_4 in varchar2 default null,
                      i_4 in varchar2 default null,
                      a_5 in varchar2 default null,
                      c_5 in varchar2 default null,
                      i_5 in varchar2 default null,
                     p_start_row IN NUMBER default 1,
                     p_end_row IN NUMBER default null,
                     p_where IN varchar2,
		     p_hidden IN varchar2 default null,
                     end_row in number default null,
		     p_query_set in number default null,
		     p_row_count in number default null) is
-------------------------------------------------------------------
  l_message varchar2(2000);
  l_messg varchar2(2000);
  l_href1 varchar2(2000);
  l_href2 varchar2(2000);
  next_start_row number;
  next_end_row number;
  v_dcdName varchar2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');

  l_return_to_next_message varchar2(200);

  l_total_price number;
  l_currency        varchar2(30);
  l_fmt_mask        varchar2(30);
  l_money_precision  number;

  cursor get_current_total(v_cart_id number) is
     select sum(quantity * unit_price) total_price
     from icx_shopping_cart_lines
     where cart_id = v_cart_id;

begin
    l_total_price := 0;
    if l_cart_id is not NULL then
      open get_current_total(l_cart_id);
      fetch get_current_total into l_total_price;
      close get_current_total;
    end if;

    FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_NEW');
    FND_MESSAGE.SET_TOKEN('ITEM_QUANTITY',l_rows_added);
    l_message := FND_MESSAGE.GET;
    if l_rows_updated > 0 then
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_UPDATE');
      FND_MESSAGE.SET_TOKEN('ITEM_QUANTITY',l_rows_updated);
      if l_rows_added > 0 then
         l_message := l_message || '<BR>' || FND_MESSAGE.GET;
      else
         l_message := FND_MESSAGE.GET;
      end if;
    end if;

   if l_total_price > 0 then
      ICX_REQ_NAVIGATION.get_currency(l_dest_org_id,l_currency,l_money_precision,l_fmt_mask);
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_TOTAL');
      FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',l_currency);
      FND_MESSAGE.SET_TOKEN('REQUISITION_TOTAL',to_char(l_total_price,fnd_currency.get_format_mask(l_currency,30)));
      l_message := l_message || '<BR><BR>' || FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_CURRENT');
      l_href1 := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_NEXT');
      l_href2 := FND_MESSAGE.GET;
      l_messg := '<TABLE BORDER=0><TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcdName || '/ICX_REQ_SEARCH.displayItem?a_1=' || a_1 ||
            '&c_1=' || c_1 || '&i_1=' || i_1 ||
            '&a_2=' || a_2 || '&c_2=' || c_2 ||'&i_2=' || i_2 ||
            '&a_3=' || a_3 || '&c_3=' || c_3 ||'&i_3=' || i_3 ||
            '&a_4=' || a_4 || '&c_4=' || c_4 ||'&i_4=' || i_4 ||
            '&a_5=' || a_5 || '&c_5=' || c_5 ||'&i_5=' || i_5 ||
            '&p_start_row=' || p_start_row || '&p_end_row=' || p_end_row || '&p_where=' || p_where || '&p_hidden=' || p_hidden || '">' ||  l_href1 || '</A></B></TD></TR>';

      /* find next set start row and next set end row */
      if end_row < p_row_count
         and p_query_set is not NULL then

         next_start_row := end_row+1;
         if end_row+p_query_set > p_row_count then
             next_end_row := p_row_count;
         else
             next_end_row := end_row+p_query_set;
         end if;

         l_messg := l_messg || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcdName || '/ICX_REQ_SEARCH.displayItem?a_1=' || a_1 ||
            '&c_1=' || c_1 || '&i_1=' || i_1 ||
            '&a_2=' || a_2 || '&c_2=' || c_2 ||'&i_2=' || i_2 ||
            '&a_3=' || a_3 || '&c_3=' || c_3 ||'&i_3=' || i_3 ||
            '&a_4=' || a_4 || '&c_4=' || c_4 ||'&i_4=' || i_4 ||
            '&a_5=' || a_5 || '&c_5=' || c_5 ||'&i_5=' || i_5 ||
'&p_start_row=' || next_start_row || '&p_end_row=' || next_end_row || '&p_where=' || p_where || '&p_hidden=' || p_hidden || '">' || l_href2 || '</A></B></TD></TR>';

      end if;

      -- MESSAGE NEEDS TO BE SWITCHED TO REVIEW MY ORDER
      FND_MESSAGE.SET_NAME('ICX','ICX_REVIEW_ORDER');
      l_return_to_next_message := FND_MESSAGE.GET;
      l_messg := l_messg || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="javascript:parent.parent.parent.switchFrames(''my_order'')" >' || l_return_to_next_message || '</A></B></TD></TR>';


      l_messg := l_messg || '</TABLE>';
      l_message := l_message || l_messg;
   end if;

   ICX_REQ_SEARCH.itemsearch_display;

   htp.bodyOpen('', 'BGCOLOR="#CCCCFF" onLoad="parent.parent.winOpen(''nav'', ''item_search'')" target="data"' );
   htp.br;
   htp.p('<H3>'|| l_message ||'</H3>');
   htp.bodyclose;
end;

--------------------------------------------------------------
procedure submit_items (cartId IN NUMBER,
		      p_emergency in number default null,
                      a_1 in varchar2 default null,
                      c_1 in varchar2 default null,
                      i_1 in varchar2 default null,
                      a_2 in varchar2 default null,
                      c_2 in varchar2 default null,
                      i_2 in varchar2 default null,
                      a_3 in varchar2 default null,
                      c_3 in varchar2 default null,
                      i_3 in varchar2 default null,
                      a_4 in varchar2 default null,
                      c_4 in varchar2 default null,
                      i_4 in varchar2 default null,
                      a_5 in varchar2 default null,
                      c_5 in varchar2 default null,
                      i_5 in varchar2 default null,
                      p_start_row IN NUMBER default 1,
		      p_end_row IN NUMBER default null,
		      p_where IN varchar2,
		      p_hidden IN varchar2 default null,
		      end_row IN number default null,
		      p_query_set IN number default null,
		      p_row_count IN number default null,
                      Quantity IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty,
                      Line_Id IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty) is
--------------------------------------------------------------

  l_line_id number;
  l_num_rows number;
  l_cart_line_id number;
  l_shopper_id number;
  l_org_id number;
  params icx_on_utilities.v80_table;
  l_qty number;
  l_error_id NUMBER;
  l_err_num NUMBER;
  l_error_message VARCHAR2(2000);
  l_err_mesg VARCHAR2(240);
  l_need_by_date date;
  l_deliver_to_location_id number;
  l_deliver_to_location varchar2(240);
  l_dest_org_id number;
  l_rows_added number;
  l_rows_updated number;
  l_cart_id number;
  l_emergency varchar2(10);
  l_cart_line_number number;
  l_dummy number;
  l_pad number;

  cursor check_cart_line_exists(v_cart_id number,v_line_id varchar2,v_org_id number) is
     select cart_line_id
     from icx_shopping_cart_lines
     where cart_id = v_cart_id
     and line_id = v_line_id
     and nvl(org_id, -9999) = nvl(v_org_id,-9999);

  cursor get_cart_header_info(v_cart_id number) is
     select need_by_date,
            deliver_to_requestor_id,
            deliver_to_location_id,
            destination_organization_id,
	    deliver_to_location,
            org_id
     from icx_shopping_carts
     where cart_id = v_cart_id;
--     and nvl(org_id,-9999) = nvl(v_org_id,-9999);


  cursor get_max_line_number(v_cart_id number) is
     select max(cart_line_number)
     from icx_shopping_cart_lines
     where cart_id = v_cart_id;

  l_emp_id number;
  l_account_id NUMBER := NULL;
  l_account_num VARCHAR2(2000) := NULL;
  l_segments fnd_flex_ext.SegmentArray;

begin

if icx_sec.validatesession then

  l_num_rows := Quantity.COUNT;
  l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  --  l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
--  if p_where is not NULL then
--     icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where),params);
--     l_org_id := params(2);
--  end if;
  l_cart_id := icx_call.decrypt2(cartId);
  l_emergency := icx_call.decrypt2(p_emergency);
  l_rows_added := 0;
  l_rows_updated := 0;

  if l_cart_id is not NULL then
     open get_cart_header_info(l_cart_id);
     fetch get_cart_header_info into l_need_by_date, l_emp_id,
         l_deliver_to_location_id,l_dest_org_id,l_deliver_to_location,l_org_id;
     close get_cart_header_info;

  end if;

  for i in Quantity.FIRST .. Quantity.LAST loop

    l_pad := instr(Quantity(i),'.',1,2);
    if (l_pad > 2) then
       l_qty := substr(Quantity(i),1,l_pad - 1);
    elsif (l_pad > 0) then
       l_qty := 0;
    else
       l_qty := Quantity(i);
    end if;

    if Quantity(i) is NOT NULL and l_qty  > 0 then

      l_cart_line_id := NULL;
      open check_cart_line_exists(l_cart_id,Line_Id(i),l_org_id);
      fetch check_cart_line_exists into l_cart_line_id;
      close check_cart_line_exists;

      if l_cart_line_id is NULL then

        l_line_id := Line_Id(i);

        /* semaphore for getting max line number */
        select 1 into l_dummy
        from icx_shopping_carts
        where cart_id = l_cart_id
        for update;

        l_cart_line_number := NULL;
        open get_max_line_number(l_cart_id);
        fetch get_max_line_number into l_cart_line_number;
        close get_max_line_number;

        if l_cart_line_number is NULL then
           l_cart_line_number := 1;
        else
           l_cart_line_number := l_cart_line_number + 1;
        end if;

        update icx_shopping_carts
        set last_update_date = sysdate
        where cart_id = l_cart_id;

        commit;
        /* release semaphore */
--changed by alex for attachment
--        select icx_shopping_cart_lines_s.nextval into l_cart_line_id from dual;
--new code:
        select PO_REQUISITION_LINES_S.nextval into l_cart_line_id from dual;

        insert into icx_shopping_cart_lines(cart_line_id,cart_id,cart_line_number,creation_date,created_by,quantity,line_id,item_id,item_revision,unit_of_measure,
        unit_price,category_id,line_type_id,item_description,destination_organization_id,deliver_to_location_id,deliver_to_location,
        suggested_buyer_id,suggested_vendor_name,suggested_vendor_site,
        need_by_date,suggested_vendor_contact,
        suggested_vendor_item_num,item_number,last_update_date,last_updated_by,org_id,custom_defaulted, autosource_doc_header_id, autosource_doc_line_num)
        select l_cart_line_id,l_cart_id,l_cart_line_number,sysdate,l_shopper_id,l_qty,Line_Id(i),a.item_id,a.item_revision,a.line_uom,
        a.price,a.category_id,a.line_type_id,a.item_description,l_dest_org_id,
        /* l_deliver_to_location_id,l_deliver_to_location,a.vendor_id,a.vendor_name,a.vendor_site_code,  **/
        l_deliver_to_location_id,l_deliver_to_location,a.agent_id,a.vendor_name,a.vendor_site_code,
        l_need_by_date,a.vendor_contact_name,
        a.vendor_product_num,a.item_number,sysdate,l_shopper_id,l_org_id,'N',
        a.po_header_id, a.line_num
        from icx_po_suppl_catalog_items_v a
        where a.po_line_id = l_line_id;

         -- Get the default accounts and update distributions
         icx_req_acct2.get_default_account(l_cart_id,l_cart_line_id,
                       l_emp_id,l_org_id,l_account_id,l_account_num);

        commit;


        l_rows_added := l_rows_added + 1;

      else

         l_qty := to_number(Quantity(i));

         update icx_shopping_cart_lines
         set quantity = quantity + l_qty
         where cart_id = l_cart_id
         and cart_line_id = l_cart_line_id
         and nvl(org_id, -9999) = nvl(l_org_id,-9999);

        commit;

         l_rows_updated := l_rows_updated + 1;

      end if;

    end if;

  end loop;

  /* call user custom default lines */
  if l_emergency is not NULL and l_emergency = 'YES' then
    icx_req_custom.reqs_default_lines(l_emergency,l_cart_id);
  else
    icx_req_custom.reqs_default_lines('NO',l_cart_id);
  end if;

  total_page(l_cart_id,l_dest_org_id,l_rows_added,l_rows_updated,a_1,c_1,
             i_1,a_2,c_2,i_2,a_3,c_3,i_3,a_4,c_4,i_4,a_5,c_5,i_5,
             p_start_row,p_end_row,p_where,p_hidden, end_row, p_query_set,p_row_count);
/*
  displayItem(a_1,c_1,i_1,a_2,c_2,i_2,a_3,c_3,i_3,a_4,c_4,i_4,a_5,c_5,i_5,
              p_start_row,p_end_row,p_where,l_rows_added);
*/

end if;

exception
when others then
   l_err_num := SQLCODE;
   l_error_message := SQLERRM;

   select substr(l_error_message,12,512) into l_err_mesg from dual;
   icx_util.add_error(l_err_mesg);
   icx_util.error_page_print;


end;

-----------------------------------------------------------
procedure displayItem(a_1 in varchar2 default null,
                      c_1 in varchar2 default null,
                      i_1 in varchar2 default null,
                      a_2 in varchar2 default null,
                      c_2 in varchar2 default null,
                      i_2 in varchar2 default null,
                      a_3 in varchar2 default null,
                      c_3 in varchar2 default null,
                      i_3 in varchar2 default null,
                      a_4 in varchar2 default null,
                      c_4 in varchar2 default null,
                      i_4 in varchar2 default null,
                      a_5 in varchar2 default null,
                      c_5 in varchar2 default null,
                      i_5 in varchar2 default null,
                      p_start_row in number default 1,
                      p_end_row in number default null,
 		      p_where in varchar2 default null,
		      p_cat in varchar2 default null,
		      p_values in number default null,
                      m in  varchar2 default null ,
                      o in  varchar2 default null,
		      p_hidden in varchar2 default null) is
-----------------------------------------------------------
c_language 		    varchar2(30);
c_title 		    varchar2(80) := '';
c_prompts 		    icx_util.g_prompts_table;
where_clause 	    varchar2(2000);
total_rows 		    number;
end_row 		    number;
temp_table 		    icx_admin_sig.pp_table;
empty_table 	    icx_admin_sig.pp_table;
c_query_size 	    number;
i 			    number 	      := 0;
j 			    number 	      := 0;
display_text          varchar2(5000);
shopper_id 		    number;
v_location_id 	    number;
v_location_code 	    varchar2(20);
v_org_id 		    number;
v_org_code 		    varchar2(3);
employee_id 	    number;
shopper_name 	    varchar(240);
v_line_id	          varchar2(65);
v_line_id_ind         number;
v_item_url            varchar2(150);
v_supplier_url        varchar2(150);
v_return_status       varchar2(20);
v_num_table           icx_sec.g_num_tbl_type;
counter               number := 0;
v_quantity_length     number :=10;
v_temp	          varchar2(240);
v_qty_flag	          boolean := false;
y_table               icx_util.char240_table;
parameters_pass       varchar2(20);
a_1_code              varchar2(80);
a_2_code              varchar2(80);
a_3_code              varchar2(80);
a_4_code              varchar2(80);
a_5_code              varchar2(80);
c_1_code              varchar2(80);
c_2_code              varchar2(80);
c_3_code              varchar2(80);
c_4_code              varchar2(80);
c_5_code              varchar2(80);
i_1_code              varchar2(80);
i_2_code              varchar2(80);
i_3_code              varchar2(80);
i_4_code              varchar2(80);
i_5_code              varchar2(80);
l_cat                 number;
Y                     varchar2(2000);
params                icx_on_utilities.v80_table;
c_currency            varchar2(15);
c_money_precision     number;
c_money_fmt_mask      varchar2(32);

v_supplier_url_ind    number;
v_supplier_item_url_ind number;
v_item_url_ind        number;
v_supplier_item_url   varchar2(150);
v_dcdName             varchar2(1000);
g_reg_ind	      number;
l_pos                 number := 0;
l_spin_pos            number := 0;

v_lines_now number;
v_lines_next number;
v_lines_url varchar2(100);

v_use_context_search CHAR(1) := 'N';

l_where_clause          varchar2(2000);
where_clause_binds      ak_query_pkg.bind_tab;
v_index                 NUMBER;

begin
-- dbms_session.set_sql_trace(TRUE);

 if icx_sec.validateSession('ICX_REQS') then

    c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
    v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    employee_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);

    --Get the org id from shopper_id
    icx_req_navigation.shopper_info(employee_id, shopper_name, v_location_id, v_location_code, v_org_id, v_org_code);

   ICX_REQ_NAVIGATION.get_currency(v_org_id, c_currency, c_money_precision, c_money_fmt_mask);

    icx_util.getPrompts(601,'ICX_PO_SUPPL_SEARCH_ITEMS_R',c_title,c_prompts);
    icx_util.error_page_setup;
    if p_where is not null then
       Y:=icx_call.decrypt2(p_where);
       icx_on_utilities.unpack_parameters(Y,params);
       a_1_code := params(1);
       c_1_code := params(2);
       i_1_code := params(3);
       a_2_code := params(4);
       c_2_code := params(5);
       i_2_code := params(6);
       a_3_code := params(7);
       c_3_code := params(8);
       i_3_code := params(9);
       a_4_code := params(10);
       c_4_code := params(11);
       i_4_code := params(12);
       a_5_code := params(13);
       c_5_code := params(14);
       i_5_code := params(15);
       l_cat := params(16);
       where_clause := icx_on_utilities.whereSegment(a_1_code,c_1_code,i_1_code,
                                                     a_2_code,c_2_code,i_2_code,
                                                     a_3_code,c_3_code,i_3_code,
                                                     a_4_code,c_4_code,i_4_code,
                                                     a_5_code,c_5_code,i_5_code,
                                                     m,o);
       parameters_pass :=  icx_call.encrypt2(a_1_code||'*'||c_1_code||'*'||i_1_code||'*'||
                                             a_2_code||'*'||c_2_code||'*'||i_2_code||'*'||
                                             a_3_code||'*'||c_3_code||'*'||i_3_code||'*'||
                                             a_4_code||'*'||c_4_code||'*'||i_4_code||'*'||
                                             a_5_code||'*'||c_5_code||'*'||i_5_code||'*'||l_cat||'**]');

    else
       where_clause := icx_on_utilities.whereSegment(a_1,c_1,i_1,a_2,c_2,i_2,a_3,c_3,i_3,a_4,c_4,i_4,a_5,c_5,i_5,m,o);
       l_cat := p_cat;
       parameters_pass :=  icx_call.encrypt2(a_1||'*'||c_1||'*'||i_1||'*'||
                                             a_2||'*'||c_2||'*'||i_2||'*'||
                                             a_3||'*'||c_3||'*'||i_3||'*'||
                                             a_4||'*'||c_4||'*'||i_4||'*'||
                                             a_5||'*'||c_5||'*'||i_5||'*'||l_cat||'**]');

     end if;

       v_lines_url  := 'ICX_REQ_SEARCH.itemsearch_display?searchX=';

    if a_2 is null
        and a_3 is null
        and a_4 is null
        and a_5 is null then
           v_lines_now  := 1;
           v_lines_next := 5;
        else
           v_lines_now  := 5;
           v_lines_next := 1;
        end if;


   htp.htmlOpen;
       htp.headOpen;
         icx_util.copyright;
       js.scriptOpen;
       find_form_head_region(v_lines_now);

    icx_on_utilities.unpack_whereSegment(where_clause,l_where_clause,where_clause_binds);

    if (l_where_clause is not null ) then
        -- l_where_clause := l_where_clause || ' AND ';
        if (o is null and p_hidden is null) then
		v_use_context_search  := 'Y';
	end if;
    end if;
    if l_cat is not null then
--        where_clause := where_clause || 'CATEGORY_ID = '|| l_cat ||' AND ';
        l_where_clause := l_where_clause || ' AND CATEGORY_ID = :cat_id';
        v_index := where_clause_binds.COUNT;
        where_clause_binds(v_index).name := 'cat_id';
        where_clause_binds(v_index).value := l_cat;
    end if;
/* commented out the code to take care of bug 724529 ***/
--    where_clause := where_clause || 'ORGANIZATION_ID = ' || v_org_id;
--    l_where_clause := l_where_clause || ' AND ORGANIZATION_ID = :org_id';
--    v_index := where_clause_binds.COUNT;
--    where_clause_binds(v_index).name := 'org_id';
--    where_clause_binds(v_index).value := v_org_id;

    --get number of rows to display
    select QUERY_SET into c_query_size from ICX_PARAMETERS;
    --set up end rows to display, since end rows
    if p_end_row is null then
       end_row := c_query_size;
    else
       end_row := p_end_row;
    end if;

    /* added an extra if condition to use old region if the where clause
       is null(v_use_context_search = 'N'). This will prevent context from
       returning huge number of rows when a blind query is entered */
   IF (v_use_context_search = 'N' ) THEN

    ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                               P_PARENT_REGION_CODE    => 'ICX_PO_SUPPL_CATALOG_ITEMS_R',
                               P_WHERE_CLAUSE          => l_where_clause,
                               P_WHERE_BINDS           => where_clause_binds,
                               P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                               P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                               P_RETURN_PARENTS        => 'T',
                               P_RETURN_CHILDREN       => 'F',
                               P_RANGE_LOW   	       => p_start_row,
                               P_RANGE_HIGH            => end_row );
   ELSE
    -- where condition is used; use the context region

    ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                               P_PARENT_REGION_CODE    => 'ICX_PO_SUPPL_SEARCH_ITEMS_R',
                               P_WHERE_CLAUSE          => l_where_clause,
                               P_WHERE_BINDS           => where_clause_binds,
                               P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                               P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                               P_RETURN_PARENTS        => 'T',
                               P_RETURN_CHILDREN       => 'F',
                               P_RANGE_LOW   	       => p_start_row,
                               P_RANGE_HIGH            => end_row );

   END IF; /* if (where_caluse is null) */

    --get number of rows to display
    g_reg_ind := ak_query_pkg.g_regions_table.FIRST;
    total_rows := ak_query_pkg.g_regions_table(g_reg_ind).total_result_count;
    if end_row > total_rows then
       end_row := total_rows;
    end if;
htp.p( 'tr=' || total_rows);

    if ak_query_pkg.g_results_table.COUNT = 0 then
       js.scriptClose;
       htp.bodyOpen('', 'BGCOLOR="#CCCCFF" onLoad="parent.parent.winOpen(''nav'', ''item_search''); open(''/OA_HTML/'
	|| c_language || '/ICXBLUE.htm'', ''k_buttons'')" target="data"' );

	fnd_message.set_name('ICX','ICX_REQS_FIND');
	htp.p(htf.bold(FND_MESSAGE.GET));
--       htp.p('Debug findForm');
       icx_on_utilities.findForm(p_region_appl_id  => 601,
                p_region_code     => 'ICX_PO_SUPPL_SEARCH_ITEMS_R',
                p_goto_url        => 'ICX_REQ_SEARCH.displayItem',
                p_goto_target     => 'data',
                p_lines_now       => v_lines_now,
                p_lines_url       => v_lines_url,
                p_lines_target    => 'data',
                p_lines_next      => v_lines_next,
                p_hidden_name     => 'p_values',
                p_hidden_value    => parameters_pass,
		p_default_title   => 'N');
--                p_values          => parameters_pass);
         htp.br;
         fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
         fnd_message.set_token('NAME_OF_REGION_TOKEN',c_title);
         htp.p('<H3>'||fnd_message.get||'</H3>');
--parent.frames[1].src = ''/OA_HTML/'
--	|| c_language || '/ICXBLUE.htm''	 htp.bodyclose;
       return;
    end if;

          icx_admin_sig.help_win_script;
        htp.p('function submit() {
               open("/OA_HTML/' || c_language ||
                    '/ICXBLUE.htm", "k_buttons");
               document.catalog_items.cartId.value = parent.parent.cartId;
	       document.catalog_items.p_emergency.value = parent.parent.emergency;
               document.catalog_items.submit();
        }');

    htp.p ('function get_parent_values(cartid,emerg) {
             cartid.value=parent.parent.cartId;
             emerg.value=parent.parent.emergency;
           }');


        htp.p('function item_rows(start_num, end_num, param_id) {
                  document.DISPLAY_ITEM.start_row.value = start_num
                  document.DISPLAY_ITEM.c_end_row.value = end_num
                  document.DISPLAY_ITEM.parameters_id.value = param_id
                  document.DISPLAY_ITEM.submit()
               }
        ');

          temp_table := empty_table;
	    --  counter := 0;
	      counter := 1;


        js.scriptClose;
      htp.headClose;

      htp.bodyOpen('', 'BGCOLOR="#CCCCFF" onLoad="parent.parent.winOpen(''nav'', ''item_search'');parent.openButWin(' || p_start_row || ',' ||
                        end_row || ',' || total_rows || ',' || parameters_pass || ',''' || v_use_context_search || ''')"');

	fnd_message.set_name('ICX','ICX_REQS_FIND');
        htp.p(htf.bold(FND_MESSAGE.GET));

       icx_on_utilities.findForm(p_region_appl_id  => 601,
                p_region_code     => 'ICX_PO_SUPPL_SEARCH_ITEMS_R',
                p_goto_url        => 'ICX_REQ_SEARCH.displayItem',
                p_goto_target     => 'data',
                p_lines_now       => v_lines_now,
                p_lines_url       => v_lines_url,
                p_lines_target    => 'data',
                p_lines_next      => v_lines_next,
                p_hidden_name     => 'p_values',
                p_hidden_value    => parameters_pass,
		p_default_title   => 'N');
--                p_values          => parameters_pass);
      htp.br;
      v_qty_flag := true;

       -- counter := 0;
       counter := 1;

      htp.p('<FORM ACTION="' || v_dcdName || '/ICX_REQ_SEARCH.submit_items" METHOD="POST" NAME="catalog_items">');

      htp.formHidden('cartId','');
      htp.formHidden('p_emergency','');
    js.scriptOpen;
      htp.p('get_parent_values(document.catalog_items.cartId,document.catalog_items.p_emergency)');
     js.scriptClose;

     htp.formHidden('a_1',a_1,          'cols="60" rows="10"');
     htp.formHidden('c_1',c_1,          'cols="60" rows="10"');
     htp.formHidden('i_1',i_1,          'cols="60" rows="10"');
     htp.formHidden('a_2',a_2,          'cols="60" rows="10"');
     htp.formHidden('c_2',c_2,          'cols="60" rows="10"');
     htp.formHidden('i_2',i_2,          'cols="60" rows="10"');
     htp.formHidden('a_3',a_3,          'cols="60" rows="10"');
     htp.formHidden('c_3',c_3,          'cols="60" rows="10"');
     htp.formHidden('i_3',i_3,          'cols="60" rows="10"');
     htp.formHidden('a_4',a_4,          'cols="60" rows="10"');
     htp.formHidden('c_4',c_4,          'cols="60" rows="10"');
     htp.formHidden('i_4',i_4,          'cols="60" rows="10"');
     htp.formHidden('a_5',a_5,          'cols="60" rows="10"');
     htp.formHidden('c_5',c_5,          'cols="60" rows="10"');
     htp.formHidden('i_5',i_5,          'cols="60" rows="10"');
     htp.formHidden('p_start_row',p_start_row,'cols="60" rows = "10"');
     htp.formHidden('p_end_row',p_end_row,'cols="60" rows ="10"');
     htp.formHidden('p_where',p_where,'cols="60" rows = "10"');
     htp.formHidden('end_row',end_row,'cols="60" rows ="10"');
     htp.formHidden('p_query_set',c_query_size,'cols="60" rows = "10"');
     htp.formHidden('p_row_count',total_rows,'cols="60" rows="10"');

     if (v_use_context_search = 'N') then
	     htp.formHidden('p_hidden', 'N', 'cols="60" rows="10"');
     else
	     htp.formHidden('p_hidden', null, 'cols="60" rows="10"');
     end if;

     l_pos := l_pos + 24;

      htp.tableOpen('BORDER');
      htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER_TABS')||'">');

      --Print the column headings
      for i in ak_query_pkg.g_items_table.FIRST .. ak_query_pkg.g_items_table.LAST loop

          if (ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
             ak_query_pkg.g_items_table(i).secured_column <> 'T' and
             ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN') or
             ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then

             if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then
		    --print quantity heading WITH COLSPAN=2
                htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'CENTER','','','','2');
	       elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' then
                   htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long || ' (' || c_currency || ')',
                                'CENTER','','','','width=80');
	       else
                htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'CENTER');
             end if;
          end if;

        -- find line id, urls value id
        if ak_query_pkg.g_items_table(i).value_id is not null then

           --need line_id to call javascript function down() and up()
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_LINE_ID') then
              v_line_id_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           -- find item_url and supplier_item_url
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_ITEM_URL') then
              v_item_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUPPLIER_URL') then
              v_supplier_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUPPLIER_ITEM_URL') then
              v_supplier_item_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
        end if;

      end loop;

      htp.tableData('');
      htp.tableRowClose;

--      for j in p_start_row-1 .. end_row-1 loop
       for j in ak_query_pkg.g_results_table.FIRST .. ak_query_pkg.g_results_table.LAST loop

          temp_table(0) := '<TR BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'">';
	    icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(j), y_table);

          for i in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop

 		  --print quantity input text box and up button if v_qty_flag is set
              if v_qty_flag and ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then
       	     display_text := '<TD ROWSPAN=2><CENTER> <INPUT TYPE=''text'' NAME=''Quantity'' '
    || '  SIZE=' || to_char(V_QUANTITY_LENGTH) || ' onChange=''if(!parent.parent.checkNumber(this)){this.focus();this.value="";}''></CENTER></TD>';

--@@show the quantity in the box filled in in the previous record set

             l_spin_pos := l_pos;
             display_text := display_text
   	       || '<TD WIDTH=18 valign=bottom> <a href="javascript:parent.parent.up(document.catalog_items.elements['
	       || l_spin_pos
	       || '])" onMouseOver="window.status=''Add Quantity'';return true"><IMG SRC=/OA_MEDIA/'
	       || c_language
	       || '/FNDISPNU.gif border=0></a></TD>';
	     l_pos := l_pos + 1;

	           temp_table(0) := temp_table(0) ||  display_text;
              end if;

             if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_LINE_ID' then
                   display_text := '<INPUT TYPE="HIDDEN" NAME="Line_Id" VALUE ='|| y_table(ak_query_pkg.g_items_table(i).value_id) || '>';

                   l_pos := l_pos + 1;
                   temp_table(0) := temp_table(0) || display_text;
             end if;


              if ak_query_pkg.g_items_table(i).value_id is not null
		     and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
   	             and ak_query_pkg.g_items_table(i).secured_column <> 'T'
		     and ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' then

/* Ref Bug #640289 : Changed By Suri. The Standard Requisitions/Emergency Requisitions Unit Price  field should allow more than two decimal places. ***/

                     IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' THEN
--                        display_text := to_char(to_number(y_table(ak_query_pkg.g_items_table(i).value_id)), c_money_fmt_mask);
                          display_text := to_char(to_number(y_table(ak_query_pkg.g_items_table(i).value_id)));
/* End Change Bug #640289 By Suri ***/
		    else
                        display_text := y_table(ak_query_pkg.g_items_table(i).value_id);
                end if;

                --Display item_description as a link and a tabledata
               if display_text is not NULL then
                if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_ITEM_DESCRIPTION') then
                   v_item_url := y_table(v_item_url_ind);
                      display_text := ICX_REQ_NAVIGATION.addURL(v_item_url, display_text);
                end if;
                 --Display source_name as a link
                 if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' then
                    v_supplier_url := y_table(v_supplier_url_ind);
                       display_text := ICX_REQ_NAVIGATION.addURL(v_supplier_url, display_text);
                 end if;
                 --Display supplier item number as a link
                 if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_ITEM_NUM' then
                    v_supplier_item_url := y_table(v_supplier_item_url_ind);
                      display_text := ICX_REQ_NAVIGATION.addURL(v_supplier_item_url, display_text);
                  end if;
                 end if;

                 if display_text is null then
                    display_text := htf.br;
                 end if;
                 if display_text = '-' then
                    display_text := htf.br;
                 end if;

                 if ak_query_pkg.g_items_table(i).bold = 'Y' then
           	        display_text := htf.bold(display_text);
                 end if;
                 --Italics
                 if ak_query_pkg.g_items_table(i).italic = 'Y' then
     	              display_text := htf.italic(display_text);
           	     end if;
                 temp_table(0) := temp_table(0) ||
                                      htf.tableData( cvalue   => display_text,
                                                     calign   => ak_query_pkg.g_items_table(i).horizontal_alignment,
                                                     crowspan => '2',
                                                     cattributes => ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment
                                                   );
              end if;
          end loop;  -- for i

          --close the table row
          temp_table(0) := temp_table(0) || htf.tableRowClose;
	    if v_qty_flag then
	       --print the down button
    	       display_text := htf.tableRowOpen( cattributes => 'BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'"');

               display_text := display_text
		 || '<TD WIDTH=18 valign=top><a href="javascript:parent.parent.down(document.catalog_items.elements['
		 || l_spin_pos
		 || '])" onMouseOver="window.status=''Reduce Quantity'';return true"><IMG SRC=/OA_MEDIA/' || c_language
		 || '/FNDISPND.gif BORDER=0></a>';
                display_text := display_text || '</TD>';

	       display_text := display_text || htf.tableRowClose;
             temp_table(0) := temp_table(0) ||  display_text;
  	    end if;
            htp.p(temp_table(0));
	    counter := counter + 1;
      end loop;      -- for j in p_start_row-1 .. end_row-1 loop


     htp.tableClose;
     htp.p('</FORM>');

      htp.formOpen('ICX_REQ_SEARCH.displayItem','POST','','','NAME="DISPLAY_ITEM"');
      htp.formHidden('start_row',p_start_row);
      htp.formHidden('c_end_row',p_end_row);
      htp.formHidden('parameters_id',parameters_pass);
	htp.formClose;

      icx_admin_sig.footer;

 end if;

-- dbms_session.set_sql_trace(FALSE);
exception
        when others then
   htp.p('In display item');

                htp.p(SQLERRM);

end displayItem;


end ICX_REQ_SEARCH;

/
