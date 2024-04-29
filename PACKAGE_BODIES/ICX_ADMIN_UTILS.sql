--------------------------------------------------------
--  DDL for Package Body ICX_ADMIN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ADMIN_UTILS" as
-- $Header: ICXADUTB.pls 120.1 2005/10/07 13:17:08 gjimenez noship $

procedure displayList(a_1 in varchar2 default null,
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
                      p_hidden in varchar2 default null,
                      p_start_row in number default 1,
                      p_end_row in number default null,
                      p_where in varchar2 default null) is

l_hidden		varchar2(2000);
l_parameters		icx_on_utilities.v240_table;
l_key_value_ids		icx_on_utilities.number_table;
l_key_attributes        icx_on_utilities.v30_table;
l_link_value_id		number;
l_link_attribute	varchar2(30);
l_function_code 	varchar2(30);
l_region_application_id	number;
l_region_code		varchar2(30);
l_find_proc		varchar2(240);
l_list_proc		varchar2(240);
l_new_proc		varchar2(240);
l_update_proc		varchar2(240);
l_delete_proc		varchar2(240);
l_help_file		varchar2(240);

l_web_user_id		number;
l_language_code		varchar2(30);
l_new_prompt		varchar2(50);
l_help_url		varchar2(2000);
l_where_clause varchar2(2000);
l_total_rows number;
l_end_row number;
l_query_size number;
l_encrypted_where number;

l_multirow_color varchar2(30);
l_resp_id number;
l_user_id number;
l_values_table          icx_util.char240_table;

l_count			number;
l_X			varchar2(240);
l_procedure_call	varchar2(2000);
l_call			integer;
l_dummy			integer;

l_err_num number;
l_message varchar2(2000);
l_err_mesg varchar2(240);

begin

l_hidden := icx_call.decrypt2(p_hidden);
icx_on_utilities.unpack_parameters(l_hidden,l_parameters);

for i in l_parameters.count..21 loop
	l_parameters(i) := '';
end loop;

/*
for i in 1..l_parameters.count loop
        htp.p(i||' = '||l_parameters(i));htp.nl;
end loop;
*/

l_function_code := l_parameters(1);
l_region_application_id := l_parameters(2);
l_region_code := l_parameters(3);
l_find_proc := l_parameters(4);
l_new_proc := l_parameters(5);
l_update_proc := l_parameters(6);
l_list_proc := 'icx_admin_utils.displayList';
l_delete_proc := l_parameters(7);
l_help_file := l_parameters(8);
l_link_attribute := l_parameters(9);
l_key_attributes(1) := l_parameters(10);
l_key_attributes(2) := l_parameters(11);
l_key_attributes(3) := l_parameters(12);
l_key_attributes(4) := l_parameters(13);
l_key_attributes(5) := l_parameters(14);
l_key_attributes(6) := l_parameters(15);
l_key_attributes(7) := l_parameters(16);
l_key_attributes(8) := l_parameters(17);
l_key_attributes(9) := l_parameters(18);
l_key_attributes(10) := l_parameters(19);

if icx_sec.validateSession(l_function_code)
then

	l_web_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
	l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
	l_new_prompt := icx_util.getPrompt(601,'ICX_REGP_DISPLAY',178,'ICX_NEW');
        l_help_url := '/OA_HTML/'||l_language_code||'/'||l_help_file;

        if p_where is not null
        then
            l_where_clause := icx_call.decrypt2(p_where);
        else
            l_where_clause := icx_on_utilities.whereSegment(a_1,c_1,i_1,a_2,c_2,i_2,a_3,c_3,i_3,a_4,c_4,i_4,a_5,c_5,i_5);
        end if;

        l_encrypted_where := icx_call.encrypt2(l_where_clause);

        l_resp_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
        l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

        select  QUERY_SET
        into    l_query_size
        from    ICX_PARAMETERS;

        if p_end_row is null then
            l_end_row := l_query_size;
        else
            l_end_row := p_end_row;
        end if;

        ak_query_pkg.exec_query(
                        p_parent_region_appl_id => l_region_application_id,
                        p_parent_region_code => l_region_code,
                        p_where_clause => l_where_clause,
                        p_responsibility_id => l_resp_id,
                        p_user_id => l_user_id,
                        p_return_parents => 'T',
                        p_return_children => 'F',
                        p_range_low => p_start_row,
                        p_range_high => l_end_row);


-- icx_on_utilities2.printPLSQLtables;

        /* get number of total rows returned by lov to be used to determine if
        we need to display the next/previous buttons */

        l_total_rows := ak_query_pkg.g_regions_table(0).total_result_count;

        if l_total_rows = 0 then

	    htp.htmlOpen;
	    htp.headOpen;
	    icx_util.copyright;
	    js.scriptOpen;
	    icx_admin_sig.help_win_script(l_help_url, l_language_code);
	    js.scriptClose;
	    htp.title(ak_query_pkg.g_regions_table(0).name);
	    htp.headClose;

	    icx_admin_sig.toolbar(language_code => l_language_code,
                              disp_find => l_find_proc);

            fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
            fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(0).name);
	    htp.br;
            htp.tableOpen('BORDER=0');
            htp.tableRowOpen;
 	    htp.tableData(cvalue => '<B><FONT size=+1>'||fnd_message.get||'</FONT></B>',cattributes => 'VALIGN="MIDDLE"');

	    htp.p('<TD>');
            icx_util.DynamicButton(P_ButtonText => l_new_prompt,
                       P_ImageFileName      => 'FNDBNEW',
                       P_OnMouseOverText    => l_new_prompt,
                       P_HyperTextCall      => l_new_proc,
                       P_LanguageCode       => l_language_code,
                       P_JavaScriptFlag     => FALSE);
            htp.p('</TD>');
            htp.tableClose;
	    htp.br;
            icx_admin_sig.footer;

        elsif l_total_rows = 1 then

	    l_count := 0;
	    while l_key_attributes(l_count+1) is not null loop
	        for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
                    if ak_query_pkg.g_items_table(i).attribute_code = l_key_attributes(l_count+1)
                    then
                        l_key_value_ids(l_count+1) := ak_query_pkg.g_items_table(i).value_id;
                    end if;
                end loop;
                l_count := l_count + 1;
	    end loop;
	    icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(0),l_values_table);

	    for i in 1..l_count loop
		l_X := l_X||l_values_table(l_key_value_ids(i))||'*';
	    end loop;
	    l_X := l_X||'*]';

	    l_procedure_call := l_update_proc||'('||icx_call.encrypt2(l_X)||')';

	    l_call := dbms_sql.open_cursor;
	    dbms_sql.parse(l_call,'begin '||l_procedure_call||'; end;',dbms_sql.native);
	    l_dummy := dbms_sql.execute(l_call);
	    dbms_sql.close_cursor(l_call);

	else
            htp.htmlOpen;
            htp.headOpen;
            icx_util.copyright;
            js.scriptOpen;
            icx_admin_sig.help_win_script(l_help_url, l_language_code);

            fnd_message.set_name('ICX', 'ICX_DELETE');
            htp.p('function delete_function(delete_name, X) {
                if (confirm("'||icx_util.replace_quotes(fnd_message.get)||' "+delete_name+"?"))      {
                     parent.location="'||l_delete_proc||'?X=" + X
                }
            }');

            js.scriptClose;
            htp.title(ak_query_pkg.g_regions_table(0).name);
            htp.headClose;

            icx_admin_sig.toolbar(language_code => l_language_code,
                                  disp_find => l_find_proc);

            if l_end_row > l_total_rows then
                l_end_row := l_total_rows;
            end if;

            htp.formOpen('');

            htp.tableOpen('BORDER=0');
            htp.tableRowOpen;
            htp.tableData(cvalue => '<B><FONT size=+2>'||ak_query_pkg.g_regions_table(0).name||'</FONT></B>',cattributes => 'VALIGN="MIDDLE"');

            htp.p('<TD>');
            icx_util.DynamicButton(P_ButtonText => l_new_prompt,
                                   P_ImageFileName => 'FNDBNEW',
                                   P_OnMouseOverText => l_new_prompt,
                                   P_HyperTextCall => l_new_proc,
                                   P_LanguageCode => l_language_code,
                                   P_JavaScriptFlag => FALSE);
            htp.p('</TD>');
            htp.tableRowClose;
            htp.tableClose;
            htp.br;

            icx_on_utilities2.displaySetIcons(l_language_code,l_list_proc,p_start_row,l_end_row,l_encrypted_where,l_query_size,l_total_rows,TRUE,'',p_hidden);

            l_count := 0;
            while l_key_attributes(l_count+1) is not null loop
                for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
                    if ak_query_pkg.g_items_table(i).attribute_code = l_key_attributes(l_count+1)
                    then
                        l_key_value_ids(l_count+1) := ak_query_pkg.g_items_table(i).value_id;
                    end if;
                end loop;
                l_count := l_count + 1;
            end loop;

	    htp.tableOpen('BORDER=4');
	    htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER')||'">');
	    for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
		if ak_query_pkg.g_items_table(i).secured_column = 'F'
		and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
		then
	            htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long);
		    if l_link_attribute = ak_query_pkg.g_items_table(i).attribute_code
		    then
			l_link_value_id := ak_query_pkg.g_items_table(i).value_id;
		    end if;
		end if;
	    end loop;
	    htp.tableData('');
	    htp.tableRowClose;

	    l_multirow_color := icx_util.get_color('TABLE_DATA_MULTIROW');

	    for r in 0..ak_query_pkg.g_results_table.COUNT-1 loop

	    icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values_table);

	    l_X := '';
            for i in 1..l_count loop
                l_X := l_X||l_values_table(l_key_value_ids(i))||'*';
            end loop;

	    htp.tableRowOpen;
	    for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

	    if ak_query_pkg.g_items_table(i).secured_column = 'F'
	    and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
	    then
                if ak_query_pkg.g_items_table(i).attribute_code = l_link_attribute
                then
		    htp.tableData(htf.anchor(l_update_proc||'?X='||icx_call.encrypt2(l_X||'*]'),l_values_table(l_link_value_id),'','onMouseOver="return true"'));
                elsif ak_query_pkg.g_items_table(i).value_id is null
		then
		    htp.tableData('');
		elsif ak_query_pkg.g_items_table(i).item_style = 'CHECKBOX'
		and (l_values_table(ak_query_pkg.g_items_table(i).value_id) = 'T'
		or l_values_table(ak_query_pkg.g_items_table(i).value_id) = 'Y')
		then
		    htp.tableData('<img src="/OA_MEDIA/'||l_language_code||'/FNDICHEK.gif" ALT="T" border=0 width=17 height=16>','CENTER');
		elsif ak_query_pkg.g_items_table(i).item_style = 'CHECKBOX'
		then
		    htp.tableData('');
		else
		    htp.tableData(l_values_table(ak_query_pkg.g_items_table(i).value_id));
		end if;
	    end if;

	    end loop; -- items
	    l_X := 'DISPLAY'||'*'||l_X||p_hidden||'*'||p_start_row||'*'||l_end_row||'*'||l_encrypted_where||'**]';
            htp.tableData(htf.anchor('javascript:delete_function('''||icx_util.replace_onMouseOver_quotes(l_values_table(l_link_value_id))||''','''||icx_call.encrypt2(l_X)||''')',
		htf.img('/OA_MEDIA/'||l_language_code||'/FNDIDELR.gif','CENTER','','','border=no width=17 height=16'),'','onMouseOver="return true"'));
            htp.tableRowClose;
	    end loop; -- Results

	    htp.tableClose;

            icx_on_utilities2.displaySetIcons(l_language_code,l_list_proc,p_start_row,l_end_row,l_encrypted_where,l_query_size,l_total_rows,TRUE,'',p_hidden);

            htp.formClose;
            icx_admin_sig.footer;

	end if;

end if;

exception
    when others then
        l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_err_mesg from dual;

        icx_util.add_error(l_err_mesg);
        icx_admin_sig.error_screen(l_err_mesg);

end;

procedure LISTScript is
begin
    htp.p('function add_to_right() {
            document.LISTform.left_right_flag.value = "Y"
            document.LISTform.submit();
    }');
    htp.p('function remove_to_left() {
            document.LISTform.left_right_flag.value = "N"
            document.LISTform.submit();
    }');

end LISTScript;


procedure selectList(   p_left_region_appl_id   in number,
                        p_left_region_code      in varchar2,
                        p_left_where            in varchar2     default null,
                        p_right_region_appl_id  in number,
                        p_right_region_code     in varchar2,
                        p_right_where           in varchar2     default null,
                        p_hidden_name           in varchar2     default null,
                        p_hidden_value          in varchar2     default null,
                        p_modify_url            in varchar2,
                        p_primary_key_size      in number) is

l_responsibility_id number := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
l_user_id number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

left_regions_table              ak_query_pkg.regions_table_type;
left_items_table                ak_query_pkg.items_table_type;
left_results_table              ak_query_pkg.results_table_type;

right_regions_table              ak_query_pkg.regions_table_type;
right_items_table                ak_query_pkg.items_table_type;
right_results_table              ak_query_pkg.results_table_type;

begin

    -- query the rows for both selection lists --
    ak_query_pkg.exec_query(
        p_parent_region_appl_id => p_left_region_appl_id,
        p_parent_region_code    => p_left_region_code,
        p_where_clause          => p_left_where,
        p_responsibility_id     => l_responsibility_id,
        p_user_id               => l_user_id,
        p_return_parents        => 'T',
        p_return_children       => 'F');

	left_regions_table := ak_query_pkg.g_regions_table;
	left_items_table := ak_query_pkg.g_items_table;
	left_results_table := ak_query_pkg.g_results_table;

        ak_query_pkg.exec_query(
        p_parent_region_appl_id => p_right_region_appl_id,
        p_parent_region_code    => p_right_region_code,
        p_where_clause          => p_right_where,
        p_responsibility_id     => l_responsibility_id,
        p_user_id               => l_user_id,
        p_return_parents        => 'T',
        p_return_children       => 'F');

        right_regions_table := ak_query_pkg.g_regions_table;
        right_items_table := ak_query_pkg.g_items_table;
        right_results_table := ak_query_pkg.g_results_table;

    htp.formOpen(p_modify_url, 'POST', '','','NAME ="LISTform"');

    -- customized hidden field --
    htp.formHidden(p_hidden_name, p_hidden_value);

    -- pass on the where_clause --
    htp.formHidden('inherit_where', p_left_where);

    -- dummy left_list, and right_list fields to avoid errors on submitting --
    htp.formHidden('left_list', 'None');
    htp.formHidden('right_list', 'None');

    -- flag to indicate if the submit is an add or removal --
    htp.formHidden('left_right_flag', '');

    htp.tableOpen('BORDER=0','','','','cellpadding=8 cellspacing=0');
    htp.tableRowOpen;
        htp.p('<td align=center valign=top>');

        htp.formSelectOpen('left_list','',10,'MULTIPLE');

        if p_primary_key_size = 2
        then
            -- when primary key consists of 2 columns --
            for i in 0..left_results_table.count-1 loop

                htp.p('<option value = "'||left_results_table(i).value2||'-'||left_results_table(i).value3||'">'||left_results_table(i).value1);
            end loop;
        else
            -- when primary key consistes of only 1 column --
            for i in 0..left_results_table.count-1 loop

                htp.p('<option value = "'||left_results_table(i).value2||'">'||left_results_table(i).value1);
            end loop;
        end if;


        htp.formSelectClose;
        htp.p('</td>');
        htp.p('<td align=center><INPUT type="button" value="Add >>" onClick="add_to_right()">');
        htp.br;

        htp.br;
        htp.p('<INPUT type="button" value="<< Remove" onClick="remove_to_left()"></td>');
        htp.p('<td align=center valign=top>');
        htp.formSelectOpen('right_list','',10,'MULTIPLE');


        -- construct the list item value according to   --
        -- the primary key size                         --

        if p_primary_key_size = 2
        then
            -- when primary key consists of 2 columns --
            for i in 0..right_results_table.count-1 loop
                htp.p('<option value = "'||right_results_table(i).value2||'-'||right_results_table(i).value3||'">'||right_results_table(i).value1);
            end loop;
        else
            -- when primary key consistes of only 1 column --
            for i in 0..right_results_table.count-1 loop

                htp.p('<option value = "'||right_results_table(i).value2||'">'||right_results_table(i).value1);
            end loop;
        end if;

        htp.formSelectClose;

        htp.p('</td>');
    htp.tableRowClose;
    htp.tableClose;

    htp.formClose;

end selectList;

end icx_admin_utils;

/
