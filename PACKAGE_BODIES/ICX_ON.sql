--------------------------------------------------------
--  DDL for Package Body ICX_ON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ON" as
/* $Header: ICXONMB.pls 120.0 2005/10/07 12:16:13 gjimenez noship $ */

procedure get_page(p_attributes in icx_on_utilities.v80_table,
                   p_conditions in icx_on_utilities.v80_table,
                   p_inputs     in icx_on_utilities.v80_table,
		   p_match	in varchar2,
		   p_and_or	in varchar2) is
l_timer number;

l_type varchar2(30);
l_flow_appl_id  number(15);
l_flow_code     varchar2(30);
l_page_appl_id  number(15);
l_page_code     varchar2(30);
l_start number;
l_start_region varchar2(30);
l_count           number;
l_encrypted_where number;

l_where varchar2(2000);
l_Y             varchar2(2000);
l_help_url      varchar2(2000);
l_message       varchar2(2000);
l_err_mesg	varchar2(240);
l_err_num	number;
l_web_user_date_format varchar2(240);

begin

-- select HSECS into l_timer from v$timer;htp.p('begin get_page @ '||l_timer);htp.nl;

l_type := icx_on_utilities.g_on_parameters(1);

if l_type = 'Q1' or l_type = 'Q5'
then
	l_flow_appl_id  := icx_on_utilities.g_on_parameters(2);
	l_flow_code     := icx_on_utilities.g_on_parameters(3);
	l_page_appl_id  := icx_on_utilities.g_on_parameters(4);
	l_page_code     := icx_on_utilities.g_on_parameters(5);

	l_Y := icx_call.encrypt2('DQ'||'*'||l_flow_appl_id||'*'||l_flow_code||'*'||l_page_appl_id||'*'||l_page_code||'*****]');

	l_help_url := 'OracleON.IC?X='||icx_call.encrypt2(l_flow_appl_id||'*'||l_flow_code||'*'||l_page_appl_id||'*'||l_page_code||'*'||'ICX_HLP_QUERY'||'**]');

        if ( substr(icx_sec.g_mode_code,1,3) = '115' or
         icx_sec.g_mode_code = 'SLAVE')
        then
          if l_type = 'Q1'
          then
            icx_on_cabo.findPage(
              p_flow_appl_id => l_flow_appl_id,
              p_flow_code => l_flow_code,
              p_page_appl_id => l_page_appl_id,
              p_page_code => l_page_code,
              p_region_appl_id => '',
              p_region_code => '',
              p_lines_now => 1,
              p_lines_next => 5,
              p_hidden_name => 'Y',
              p_hidden_value => l_Y,
              p_help_url => l_help_url);
          else
            icx_on_cabo.findPage(l_flow_appl_id,l_flow_code,l_page_appl_id,l_page_code,'','',5,1,'Y',l_Y,l_help_url);
          end if;
        else
          if l_type = 'Q1'
          then
            icx_on_utilities.findPage(l_flow_appl_id,l_flow_code,l_page_appl_id,l_page_code,'','','',1,'',5,'Y',l_Y,l_help_url);
          else
            icx_on_utilities.findPage(l_flow_appl_id,l_flow_code,l_page_appl_id,l_page_code,'','','',5,'',1,'Y',l_Y,l_help_url);
          end if;
        end if;
else
        if l_type = 'DQ'
        then
		l_encrypted_where := icx_on_utilities.g_on_parameters(9);

		if l_encrypted_where is null
		then
                	l_where := icx_on_utilities.whereSegment(p_attributes,p_conditions,p_inputs,p_match,p_and_or);
			l_encrypted_where := icx_call.encrypt2(l_where);
		else
			l_where := icx_call.decrypt2(l_encrypted_where);
		end if;

-- htp.p('DEBUG where => '||l_where);htp.nl;

		icx_on_utilities.g_on_parameters(9) := l_encrypted_where;

		icx_on_utilities.getRegions(l_where);
	elsif l_type = 'W'
	then
		l_start := 1;

		select  REGION_CODE
		into    l_start_region
		from    AK_FLOW_PAGE_REGIONS
		where   PAGE_CODE = icx_on_utilities.g_on_parameters(5)
		and     PAGE_APPLICATION_ID = icx_on_utilities.g_on_parameters(4)
		and     FLOW_CODE = icx_on_utilities.g_on_parameters(3)
		and     FLOW_APPLICATION_ID = icx_on_utilities.g_on_parameters(2)
		and     PARENT_REGION_CODE is null;

		-- The parameters(6) is a funny used to pass in a direct where
		l_where := replace(icx_on_utilities.g_on_parameters(6),'~','=')||'**]';
		l_encrypted_where := icx_call.encrypt2(l_where);

-- 2093780 nlbarlow, multiple region first page
                select  count(*)
                into    l_count
                from    AK_FLOW_PAGE_REGIONS
                where   PAGE_CODE = icx_on_utilities.g_on_parameters(5)
                and     PAGE_APPLICATION_ID = icx_on_utilities.g_on_parameters(4)
                and     FLOW_CODE = icx_on_utilities.g_on_parameters(3)
                and     FLOW_APPLICATION_ID = icx_on_utilities.g_on_parameters(2);

                if l_count > 1
                then
                  icx_on_utilities.g_on_parameters(1) := 'W';
                else
                  icx_on_utilities.g_on_parameters(1) := 'DQ';
                end if;

		icx_on_utilities.g_on_parameters(6) := l_start;
		icx_on_utilities.g_on_parameters(7) := '';
		icx_on_utilities.g_on_parameters(8) := l_start_region;
		icx_on_utilities.g_on_parameters(9) := l_encrypted_where;

                icx_on_cabo.wherePage;
        elsif l_type = 'D'
        then
                icx_on_cabo.WFPage;
	else
		icx_on_utilities.getRegions;
	end if;

        if ak_query_pkg.g_regions_table(0).flow_application_id > 0
        then
          if ( substr(icx_sec.g_mode_code,1,3) = '115' or
         icx_sec.g_mode_code = 'SLAVE')
          then
            icx_on_cabo.displayPage;
          else
            icx_on_utilities.displayPage;
          end if;
        end if;

end if;

-- select HSECS into l_timer from v$timer;htp.p('end get_page @ '||l_timer);htp.nl;

exception
    when VALUE_ERROR or INVALID_NUMBER then
	fnd_message.set_name('ICX','ICX_USE_NUMBER');
        l_message := fnd_message.get;
	icx_util.add_error(l_message) ;
	icx_admin_sig.error_screen(l_message);
    when others then
        l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_err_mesg from dual;
        if (abs(l_err_num) between 1800 and 1899)
        then
            fnd_message.set_name('ICX','ICX_USE_DATE_FORMAT');
            l_web_user_date_format := icx_sec.getID(icx_sec.pv_date_format);
            fnd_message.set_token('FORMAT_MASK_TOKEN',nvl(l_web_user_date_format,'DD-MON-YYYY'));
            l_message := l_err_mesg||'<br>'||fnd_message.get;
            icx_util.add_error(l_message) ;
            icx_admin_sig.error_screen(l_err_mesg);
        else
            icx_util.add_error(l_err_mesg);
            icx_admin_sig.error_screen(l_err_mesg);
        end if;
end;

procedure create_file(S in number,
		      c_delimiter in varchar2) is

l_type                  varchar2(30);
l_flow_appl_id  number(15);
l_flow_code     varchar2(30);
l_page_appl_id       number(15);
l_page_code  varchar2(30);
l_start                 number;
l_end			number;
l_start_region          varchar2(30);
c_rowid                 rowid;
l_encrypted_where       number;
c_unique_key_name       varchar2(30);
c_parameters		icx_on_utilities.v240_table;
c_keys                  icx_on_utilities.v80_table;

l_region_appl_id number(15);
l_region_code   varchar2(30);
l_where			varchar2(2000);

c_from_page_appl_id      number(15);
c_from_page_code        varchar2(30);
c_from_region_appl_id number(15);
c_from_region_code   varchar2(30);
c_to_page_appl_id number(15);
c_to_page_code   varchar2(30);

l_responsibility_id 	number;
l_user_id		number;

c_labels                varchar2(4000);
l_values_table		icx_util.char4000_table;
l_value			varchar2(4000);
c_data                  varchar2(4000);

l_count1 number;
l_count2 number;
l_message varchar2(2000);

l_where_clause varchar2(2000);
l_query_binds ak_query_pkg.bind_tab;

-- Bug 3460155
c_labels1                varchar2(4000);
c_data1                  varchar2(4000);
l_dbcharset              v$nls_parameters.value%TYPE;


begin

icx_on_utilities.unpack_parameters(icx_call.decrypt2(S),c_parameters);

l_type := c_parameters(1);

if l_type = 'DQ' or l_type = 'W'
then

l_flow_appl_id := c_parameters(2);
l_flow_code := c_parameters(3);
l_page_appl_id := c_parameters(4);
l_page_code := c_parameters(5);
l_start := c_parameters(6);
l_end := c_parameters(7);
l_start_region := c_parameters(8);
l_encrypted_where := c_parameters(9);

select  REGION_APPLICATION_ID,REGION_CODE
into	l_region_appl_id,l_region_code
from    AK_FLOW_PAGE_REGIONS
where   FLOW_CODE = l_flow_code
and     FLOW_APPLICATION_ID = l_flow_appl_id
and     PAGE_CODE = l_page_code
and     PAGE_APPLICATION_ID = l_page_appl_id;

l_where := icx_call.decrypt2(l_encrypted_where);

l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

icx_on_utilities.unpack_whereSegment(l_where,l_where_clause,l_query_binds);

ak_query_pkg.exec_query(
P_FLOW_APPL_ID => l_flow_appl_id,
P_FLOW_CODE => l_flow_code,
P_PARENT_PAGE_APPL_ID => l_page_appl_id,
P_PARENT_PAGE_CODE => l_page_code,
P_PARENT_REGION_APPL_ID => l_region_appl_id,
P_PARENT_REGION_CODE => l_region_code,
P_WHERE_CLAUSE => l_where_clause,
P_WHERE_BINDS => l_query_binds,
P_RESPONSIBILITY_ID => l_responsibility_id,
P_USER_ID => l_user_id,
P_RETURN_PARENTS => 'T',
P_RETURN_CHILDREN => 'F',
P_RETURN_NODE_DISPLAY_ONLY => 'T');

else

l_start := c_parameters(6);
l_end := c_parameters(7);
l_start_region := c_parameters(8);
c_rowid := c_parameters(10);
c_unique_key_name := c_parameters(11);
c_keys(1) := c_parameters(12);
c_keys(2) := c_parameters(13);
c_keys(3) := c_parameters(14);
c_keys(4) := c_parameters(15);
c_keys(5) := c_parameters(16);
c_keys(6) := c_parameters(17);
c_keys(7) := c_parameters(18);
c_keys(8) := c_parameters(19);
c_keys(9) := c_parameters(20);
c_keys(10) := c_parameters(21);

select  FLOW_APPLICATION_ID,FLOW_CODE,
	FROM_PAGE_APPL_ID,FROM_PAGE_CODE,
        FROM_REGION_APPL_ID,FROM_REGION_CODE,
        TO_PAGE_APPL_ID,TO_PAGE_CODE
into    l_flow_appl_id,l_flow_code,
	c_from_page_appl_id,c_from_page_code,
        c_from_region_appl_id,c_from_region_code,
        c_to_page_appl_id,c_to_page_code
from    AK_FLOW_REGION_RELATIONS
where   ROWID = c_rowid;

l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

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

end if;

owa_util.mime_header('application/x-excel', TRUE);

-- icx_on_utilities2.printPLSQLtables;

if ak_query_pkg.g_results_table.COUNT = 0
then
        fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
        fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(0).name);
        l_message := fnd_message.get;

        htp.p(l_message);
else

for r in ak_query_pkg.g_regions_table.FIRST..ak_query_pkg.g_regions_table.LAST loop

if ak_query_pkg.g_regions_table(r).total_result_count > 0
then

if ak_query_pkg.g_regions_table(r).region_style = 'FORM'
then

l_count1 := 0;

for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

if ak_query_pkg.g_items_table(i).region_rec_id = ak_query_pkg.g_regions_table(r).region_rec_id
and     ak_query_pkg.g_items_table(i).secured_column = 'F'
and     ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
and     ak_query_pkg.g_items_table(i).item_style = 'TEXT'
then

for v in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop

if ak_query_pkg.g_results_table(v).region_rec_id = ak_query_pkg.g_results_table(r).region_rec_id
then

if l_count1 = ak_query_pkg.g_regions_table(r).number_of_format_columns
then
	htp.p;
	l_count1 := 0;
end if;

icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(v),l_values_table);

        if ak_query_pkg.g_items_table(i).value_id is null
        then
                l_value := '';
        else
                l_value := replace(l_values_table(ak_query_pkg.g_items_table(i).value_id),','
,'');
        end if;
	if ak_query_pkg.g_items_table(i).attribute_label_long is null and l_value is null
	then
	    l_value := l_value;
	else
	    htp.prn(ak_query_pkg.g_items_table(i).attribute_label_long||c_delimiter||l_value||c_delimiter);
	    l_count1 := l_count1 + 1;
	end if;

end if; -- region result

end loop; -- results

end if; -- display item

end loop; -- items

htp.p('');
htp.p('');

else

c_labels := '';
for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

if ak_query_pkg.g_items_table(i).region_rec_id = ak_query_pkg.g_regions_table(r).region_rec_id
and	ak_query_pkg.g_items_table(i).secured_column = 'F'
and	ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
and	ak_query_pkg.g_items_table(i).item_style = 'TEXT'
then
	c_labels := c_labels||ak_query_pkg.g_items_table(i).attribute_label_long||c_delimiter;

end if;

end loop; -- items


--Start Bug3460155

   l_dbcharset:=icx_sec.getNLS_PARAMETER('NLS_CHARACTERSET');

   c_labels1 := convert(c_labels,fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'),l_dbcharset);

htp.p(c_labels1);

  c_data1 := convert(c_data,fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'),l_dbcharset);

  htp.p(c_data1);

--- End Bug3460155


for v in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop

if ak_query_pkg.g_results_table(v).region_rec_id = ak_query_pkg.g_regions_table(r).region_rec_id
then

icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(v),l_values_table);

c_data := '';
for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

if ak_query_pkg.g_items_table(i).region_rec_id = ak_query_pkg.g_regions_table(r).region_rec_id
and     ak_query_pkg.g_items_table(i).secured_column = 'F'
and     ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
and	ak_query_pkg.g_items_table(i).item_style = 'TEXT'
then
	if ak_query_pkg.g_items_table(i).value_id is null
	then
		l_value := '';
	else
		l_value := replace(l_values_table(ak_query_pkg.g_items_table(i).value_id),',','');
	end if;
	c_data := c_data||l_value||c_delimiter;
end if;

end loop; -- items

-- Start Bug3460155

--htp.p(c_data);

  c_data1 := convert(c_data,fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'),l_dbcharset);

  htp.p(c_data1);

--- End Bug3460155


end if;

end loop; -- results

end if; -- region style

else
        fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
        fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(r).name);
        l_message := fnd_message.get;
        htp.p(l_message);

end if; -- no row in region

end loop; -- regions

end if; -- no results

end;

end icx_on;

/
