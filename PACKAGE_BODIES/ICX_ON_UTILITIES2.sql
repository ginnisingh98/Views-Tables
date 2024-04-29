--------------------------------------------------------
--  DDL for Package Body ICX_ON_UTILITIES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ON_UTILITIES2" as
/* $Header: ICXONVB.pls 120.0 2005/10/07 12:16:53 gjimenez noship $ */

procedure displaySetIcons(p_language_code in varchar2,
                          p_packproc in varchar2,
                          p_start_row in number,
                          p_stop_row in number,
                          p_encrypted_where in number,
                          p_query_set in number,
                          p_row_count in number,
                          p_top in boolean,
			  p_jsproc in varchar2,
			  p_hidden in varchar2,
			  p_update in boolean,
			  p_target in varchar2) is
l_target        varchar2(240);
l_title 	varchar2(80);
l_prompts       icx_util.g_prompts_table;
l_message	varchar2(2000);
l_parameter	varchar2(2000);
l_start_row	number;
l_stop_row	number;
begin

icx_util.getPrompts(601,'ICX_WEB_ON',l_title,l_prompts);

if p_target is null
then
    l_target := 'self';
else
    l_target := p_target;
end if;

if p_top
then
if p_update
then
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('<!-- Hide from old browsers');
        fnd_message.set_name('ICX','ICX_PROCEED_WITHOUT_SAVE');
        l_message := icx_util.replace_quotes(fnd_message.get);
        htp.p('function set_icon(X) {
            if (confirm("'||l_message||'")) {
                '||l_target||'.location="'||icx_cabo.g_base_href||'" + X;
                    }
            }');

        htp.p('// -->');
        htp.p('</SCRIPT>');
else
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('<!-- Hide from old browsers');
        htp.p('function set_icon(X) {
                '||l_target||'.location="'||icx_cabo.g_base_href||'" + X;
            }');
        htp.p('// -->');
        htp.p('</SCRIPT>');
end if;
end if;

htp.tableOpen(cborder => 'BORDER=0', cattributes => 'WIDTH="100%"');
htp.tableRowOpen;

   if p_start_row <= 1
   then
        if p_stop_row < p_row_count
        then
            htp.p('<TD>');
            htp.img(curl => '/OA_MEDIA/FNDIFRSD.gif', cattributes => 'width=22 height=22');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.img(curl => '/OA_MEDIA/FNDIPRED.gif', cattributes => 'width=22 height=22');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.p('</TD>');
	end if;
   else
        fnd_message.set_name('ICX','ICX_TABLE_SET');
        fnd_message.set_token('FROM_ROW_TOKEN','1');
        fnd_message.set_token('TO_ROW_TOKEN',p_query_set);
        l_message := fnd_message.get;

        htp.p('<TD>');
        if p_jsproc is null then
	    l_parameter := '?p_start_row='||1||'&'||'p_end_row='||p_query_set||'&'||'p_where='||p_encrypted_where;
	    if p_hidden is not null
	    then
		l_parameter := l_parameter||'&'||'p_hidden='||p_hidden;
	    end if;
            htp.anchor('javascript:set_icon('''||p_packproc||l_parameter||''')',
		htf.img(curl => '/OA_MEDIA/FNDIFRST.gif', calt => icx_util.replace_alt_quotes(l_prompts(1)),
		 cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
        else
            htp.anchor('javascript:'||p_jsproc||'(''1'','''||p_query_set||''')',
		htf.img(curl => '/OA_MEDIA/FNDIFRST.gif', calt =>icx_util.replace_alt_quotes(l_prompts(1)),
		 cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	end if;
        htp.p('</TD>');
        htp.p('<TD>');
        htp.p('</TD>');

        fnd_message.set_name('ICX','ICX_TABLE_SET');
        if p_start_row-p_query_set < 1
        then
                l_start_row := 1;
        else
                l_start_row := p_start_row-p_query_set;
        end if;
	fnd_message.set_token('FROM_ROW_TOKEN',l_start_row);
        fnd_message.set_token('TO_ROW_TOKEN',p_start_row-1);
        l_message := fnd_message.get;


        htp.p('<TD>');
        if p_jsproc is null then
	    l_parameter := '?p_start_row='||to_char(l_start_row)||'&'||'p_end_row='||to_char(p_start_row-1)||'&'||'p_where='||p_encrypted_where;
            if p_hidden is not null
            then
                l_parameter := l_parameter||'&'||'p_hidden='||p_hidden;
            end if;
            htp.anchor('javascript:set_icon('''||p_packproc||l_parameter||''')',
		htf.img(curl => '/OA_MEDIA/FNDIPREV.gif', calt => icx_util.replace_alt_quotes(l_prompts(2)),
		cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	else
            htp.anchor('javascript:'||p_jsproc||'('''||to_char(l_start_row)||''','''||to_char(p_start_row-1)||''')',
		htf.img(curl => '/OA_MEDIA/FNDIPREV.gif', calt => icx_util.replace_alt_quotes(l_prompts(2)),
		cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	end if;
        htp.p('</TD>');
        htp.p('<TD>');
        htp.p('</TD>');

end if;
        fnd_message.set_name('ICX','ICX_RECORDS_RANGE');
        fnd_message.set_token('FROM_ROW_TOKEN',p_start_row);
        fnd_message.set_token('TO_ROW_TOKEN',p_stop_row);
        fnd_message.set_token('TOTAL_ROW_TOKEN',p_row_count);
        l_message := fnd_message.get;

        htp.p('<TD NOWRAP>'||l_message||'</TD>');

   if p_stop_row >= p_row_count
   then
	if p_start_row > 1
        then
            htp.p('<TD>');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.img(curl => '/OA_MEDIA/FNDINEXD.gif', cattributes => 'width=22 height=22');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.p('</TD>');
            htp.p('<TD>');
            htp.img(curl => '/OA_MEDIA/FNDILASD.gif', cattributes => 'width=22 height=22');
            htp.p('</TD>');
	end if;
   else
        fnd_message.set_name('ICX','ICX_TABLE_SET');
        fnd_message.set_token('FROM_ROW_TOKEN',p_stop_row+1);
        if p_stop_row+p_query_set > p_row_count
        then
		l_stop_row := p_row_count;
        else
		l_stop_row := p_stop_row+p_query_set;
        end if;
        fnd_message.set_token('TO_ROW_TOKEN',l_stop_row);
        l_message := fnd_message.get;

        htp.p('<TD>');
        if p_jsproc is null then
            l_parameter := '?p_start_row='||to_char(p_stop_row+1)||'&'||'p_end_row='||to_char(l_stop_row)||'&'||'p_where='||p_encrypted_where;
            if p_hidden is not null
            then
                l_parameter := l_parameter||'&'||'p_hidden='||p_hidden;
            end if;
            htp.anchor('javascript:set_icon('''||p_packproc||l_parameter||''')',		htf.img(curl => '/OA_MEDIA/FNDINEXT.gif', calt => icx_util.replace_alt_quotes(l_prompts(3)),
		cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	else
            htp.anchor('javascript:'||p_jsproc||'('''||to_char(p_stop_row+1)||''','''||to_char(l_stop_row)||''')',
		htf.img(curl => '/OA_MEDIA/FNDINEXT.gif', calt => icx_util.replace_alt_quotes(l_prompts(3)),
		cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	end if;
        htp.p('</TD>');
        htp.p('<TD>');
        htp.p('</TD>');

        fnd_message.set_name('ICX','ICX_TABLE_SET');
        fnd_message.set_token('FROM_ROW_TOKEN',p_row_count-p_query_set+1);
        fnd_message.set_token('TO_ROW_TOKEN',p_row_count);
        l_message := fnd_message.get;

        htp.p('<TD>');
        if p_jsproc is null then
            l_parameter := '?p_start_row='||to_char(p_row_count-p_query_set+1)||'&'||'p_end_row='||to_char(p_row_count)||'&'||'p_where='||p_encrypted_where;
            if p_hidden is not null
            then
                l_parameter := l_parameter||'&'||'p_hidden='||p_hidden;
            end if;
            htp.anchor('javascript:set_icon('''||p_packproc||l_parameter||''')',
		htf.img(curl => '/OA_MEDIA/FNDILAST.gif', calt => icx_util.replace_alt_quotes(l_prompts(4)),
		cattributes => 'width=22 height=22 BORDER=0'),'','onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	else
            htp.anchor('javascript:'||p_jsproc||'('''||to_char(p_row_count-p_query_set+1)||''','''||to_char(p_row_count)||''')',
		htf.img(curl => '/OA_MEDIA/FNDILAST.gif', calt => icx_util.replace_alt_quotes(l_prompts(4)),
		cattributes => 'width=22 height=22 BORDER=0'),'',' onMouseOver="window.status='''||icx_util.replace_OnMouseOver_quotes(l_message)||''';return true"');
	end if;
        htp.p('</TD>');
   end if;
        htp.p('<TD ALIGN="RIGHT" WIDTH="100%"></TD>');

   if (p_start_row = 1 and p_stop_row = p_row_count)
   then
        l_title := '';
   else
        fnd_message.set_name('ICX','ICX_RECORDS_ALL');
        fnd_message.set_token('TOTAL_ROW_TOKEN',p_row_count);
        l_message := fnd_message.get;

        htp.p('<TD ALIGN="RIGHT" WIDTH="100%">');
        if p_jsproc is null then
            l_parameter := '?p_start_row='||1||'&'||'p_end_row='||to_char(p_row_count)||'&'||'p_where='||p_encrypted_where;
            if p_hidden is not null
            then
                l_parameter := l_parameter||'&'||'p_hidden='||p_hidden;
            end if;
            icx_util.DynamicButton(P_ButtonText => l_message,
                                   P_ImageFileName => 'FNDBALL',
                                   P_OnMouseOverText => l_message,
                                   P_HyperTextCall => 'javascript:set_icon('''||p_packproc||l_parameter||''')',
                                   P_LanguageCode => p_language_code,
                                   P_JavaScriptFlag => FALSE);
	else
            icx_util.DynamicButton(P_ButtonText => l_message,
                                   P_ImageFileName => 'FNDBALL',
                                   P_OnMouseOverText => l_message,
                                   P_HyperTextCall => 'javascript:'||p_jsproc||'(''1'','''||to_char(p_row_count)||''')',
                                   P_LanguageCode => p_language_code,
                                   P_JavaScriptFlag => FALSE);
	end if;
        htp.p('</TD>');
   end if;

htp.tableRowClose;
htp.tableClose;

end;

procedure printText(	p_item_rec	in ak_query_pkg.item_rec,
                        p_data_type     in varchar2,
                        p_value         in varchar2,
			p_rowid         in rowid,
			p_goto          in varchar2,
			p_session_id    in number,
			p_region_style	in varchar2,
			p_data_background_color in varchar2,
                        p_rowspan       in number) is


l_Y		varchar2(2000);
l_input_check   varchar2(2000);
l_display_value varchar2(5000);
l_data_background_color varchar2(30);

begin

if p_region_style = 'FORM'
then
    l_display_value := icx_on_utilities.formatText(p_value,'Y',p_item_rec.italic);
    l_data_background_color := ' bgcolor="#'||p_data_background_color||'"';
else
    l_display_value := icx_on_utilities.formatText(p_value,p_item_rec.bold,p_item_rec.italic);
    l_data_background_color := '';
end if;

-- nlbarlow disable ON form support
if p_item_rec.update_flag = 'X'
then
    l_input_check := '';
    if p_item_rec.required_flag  = 'Y'
    then
        l_input_check := l_input_check||'null_alert(this.value,'''||p_item_rec.attribute_label_long||''');';
    end if;

    if p_data_type = 'NUMBER'
    then
        l_input_check := l_input_check||'check_number(this);';
    end if;
    htp.tableData(cvalue => htf.formText(cname => 't', csize => p_item_rec.display_value_length, cvalue => p_value, cattributes => 'onChange="'||l_input_check||'"'), crowspan => p_rowspan);
elsif p_rowid is not null and p_value is not null
then
    l_Y := 'X*****1****'||p_rowid||'*'||p_goto;
    htp.tableData(cvalue => '<A HREF="'||icx_cabo.g_plsql_agent||'OracleON.IC?Y='||icx_call.encrypt2(l_Y,p_session_id)||'" TARGET="_self">'
	||l_display_value, calign => p_item_rec.horizontal_alignment, cattributes => 'VALIGN="'||p_item_rec.vertical_alignment||'"'||l_data_background_color, crowspan => p_rowspan);
else
    htp.tableData(cvalue => l_display_value, calign => p_item_rec.horizontal_alignment, cattributes => 'VALIGN="'||p_item_rec.vertical_alignment||'"'||l_data_background_color, crowspan => p_rowspan);
end if;

end;

procedure printSpinboxup(	p_update_flag   in varchar2,
				p_required_flag	in varchar2,
				p_label		in varchar2,
				p_data_type	in varchar2,
                        	p_value         in varchar2,
				p_value_length  in number,
                        	p_bold          in varchar2,
                        	p_italic        in varchar2,
                        	p_halign        in varchar2,
                        	p_valign        in varchar2,
				p_element	in varchar2,
				p_language_code in varchar2,
                        	p_rowspan       in number) is

l_input_check	varchar2(2000);

begin

l_input_check := '';
if p_required_flag = 'Y'
then
    l_input_check := l_input_check||'null_alert(this.value,'''||p_label||''');';
end if;

-- nlbarlow disable ON form support
if p_update_flag = 'X'
then
    if p_data_type = 'NUMBER'
    then
        l_input_check := l_input_check||'check_number(this);';
        htp.tableData(cvalue => htf.formText(cname => 't', csize => p_value_length, cvalue => p_value, cattributes => 'onChange="'||l_input_check||'"'), crowspan => p_rowspan);
        htp.tableData(cvalue => '<A HREF="javascript:spin_up('||p_element||')" onMouseOver="return true"><IMG SRC="/OA_MEDIA/FNDISPNU.gif" ALIGN="CENTER" BORDER=NO WIDTH=18 HEIGHT=20>');
    else
        htp.tableData(cvalue => htf.formText(cname => 't', csize => p_value_length, cvalue => p_value, cattributes => 'onChange="'||l_input_check||'"'), crowspan => p_rowspan);
    end if;
else
    htp.tableData(cvalue => icx_on_utilities.formatText(p_value,p_bold,p_italic), calign => p_halign, cattributes => 'VALIGN="'||p_valign||'"', crowspan => p_rowspan);
end if;

end;

procedure printSpinboxdown(     p_update_flag   in varchar2,
                                p_data_type     in varchar2,
                                p_element       in varchar2,
                                p_language_code in varchar2) is
begin

-- nlbarlow disable ON form support
if p_update_flag = 'X'
then
    if p_data_type = 'NUMBER'
    then
	htp.tableData(cvalue => '<A HREF="javascript:spin_down('||p_element||')" onMouseOver="return true"><IMG SRC="/OA_MEDIA/FNDISPND.gif" ALIGN="CENTER" BORDER=NO WIDTH=18 HEIGHT=20>');
    end if;
end if;

end;

procedure printButton(	p_item_rec      in ak_query_pkg.item_rec,
			p_rowid         in rowid,
			p_goto          in varchar2,
			p_session_id    in number,
			p_rowspan       in number,
			p_region_style	in varchar2) is

l_Y     varchar2(2000);

begin

if p_rowid is null
then
    htp.tableData('No link defined');
elsif p_region_style = 'FORM'
then
    l_Y := 'X*****1****'||p_rowid||'*'||p_goto;
    htp.tableData(cvalue => '<INPUT type="button" value="'||icx_util.replace_alt_quotes(p_item_rec.attribute_label_long)
	||'" onClick="goto_button('''||icx_cabo.g_plsql_agent||'OracleON.IC?Y='||icx_call.encrypt2(l_Y,p_session_id)||''')">', calign => p_item_rec.horizontal_alignment, cattributes => 'VALIGN="'||p_item_rec.vertical_alignment||'"',
	crowspan => p_rowspan, ccolspan => '3');
else
    l_Y := 'X*****1****'||p_rowid||'*'||p_goto;
    htp.tableData(cvalue => '<INPUT type="button" value="'||icx_util.replace_alt_quotes(p_item_rec.attribute_label_long)
	||'" onClick="goto_button('''||icx_cabo.g_plsql_agent||'OracleON.IC?Y='||icx_call.encrypt2(l_Y,p_session_id)||''')">', calign => p_item_rec.horizontal_alignment, cattributes => 'VALIGN="'||p_item_rec.vertical_alignment||'"', crowspan => p_rowspan);
end if;

end;

procedure printCheckbox(p_update_flag	in varchar2,
			p_value_id	in number,
			p_value		in varchar2,
			p_halign	in varchar2,
			p_valign	in varchar2,
			p_language_code	in varchar2,
			p_rowspan	in number,
			p_label		in varchar2) is

begin

-- nlbarlow disable ON form support
if p_update_flag = 'X'
then
    if p_value_id is null
    then
        htp.tableData(cvalue => htf.formCheckbox('c','F')||p_label, crowspan => p_rowspan);
    else
	if p_value = 'T' or p_value = 'Y'
	then
            htp.tableData(cvalue => htf.formCheckbox('c',p_value,'CHECKED')||p_label, crowspan => p_rowspan);
	else
            htp.tableData(cvalue => htf.formCheckbox('c',p_value)||p_label, crowspan => p_rowspan);
	end if;
    end if;
else
    if p_value_id is null
    then
        htp.tableData(cvalue => '', crowspan => p_rowspan);
    else
        if p_value = 'T' or p_value = 'Y'
        then
            htp.tableData(cvalue => '<img src="/OA_MEDIA/FNDICHEK.gif" ALT="'||p_value||'" border=0 width=17 height=16>', calign => p_halign, cattributes => 'VALIGN="'||p_valign||'"', crowspan => p_rowspan);
        else
            htp.tableData(cvalue => '', crowspan => p_rowspan);
        end if;
    end if;
end if;

end;

procedure printImage(   p_item_rec      in ak_query_pkg.item_rec,
                        p_value         in varchar2,
                        p_rowid         in rowid,
                        p_goto          in varchar2,
                        p_session_id    in number,
			p_language_code in varchar2,
                        p_rowspan       in number) is


l_Y             varchar2(2000);
l_input_check   varchar2(2000);

begin

if p_item_rec.region_validation_api_pkg is not null
then
    htp.tableData(cvalue => '<A HREF="'||icx_cabo.g_plsql_agent||p_item_rec.region_validation_api_pkg||'.'||p_item_rec.region_validation_api_proc||'">
	||<IMG SRC="/OA_MEDIA/'||p_item_rec.icx_custom_call||'" ALT="'||p_item_rec.attribute_label_long||'" ALIGN="CENTER" BORDER=NO TARGET="_top">');

elsif p_rowid is not null
then
    htp.tableData(cvalue => '<A HREF="'||icx_cabo.g_plsql_agent||'OracleON.IC?Y='||icx_call.encrypt2(l_Y,p_session_id)||'">
	||<IMG SRC="/OA_MEDIA/'||p_item_rec.icx_custom_call||'" ALT="'||p_item_rec.attribute_label_long||'" ALIGN="CENTER" BORDER=NO>');

else
    htp.tableData('<IMG SRC="/OA_MEDIA/'||p_item_rec.icx_custom_call||'" ALT="'||p_item_rec.attribute_label_long||'" ALIGN="CENTER" BORDER=NO>');

end if;

end;

procedure printPoplist( p_region_application_id in number,
			p_region_code in varchar2,
			p_update_flag   in varchar2,
			p_value_id      in number,
			p_value         in varchar2,
                        p_bold          in varchar2,
                        p_italic        in varchar2,
                        p_halign        in varchar2,
                        p_valign        in varchar2,
			p_rowspan in number) is

l_poplist	varchar2(2000);

l_responsibility_id number;
l_user_id number;

begin

if p_region_code is not null
then
    -- nlbarlow disable ON form support
    if p_update_flag = 'X'
    then

        l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
        l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

        ak_query_pkg.exec_query('','','','',p_region_application_id,p_region_code,'','','','','','','','','','','','','','','',l_responsibility_id,l_user_id,'T','F','F','F');

-- icx_on_utilities2.printPLSQLtables;

        if p_value_id is null
        then

            l_poplist := htf.formSelectOpen('s');
            for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
                l_poplist := l_poplist||('<OPTION VALUE="'||ak_query_pkg.g_results_table(r).value2||'">'||ak_query_pkg.g_results_table(r).value1);
            end loop;
            l_poplist := l_poplist||htf.formSelectClose;

            htp.tableData(cvalue => l_poplist, crowspan => p_rowspan);

	else

            l_poplist := htf.formSelectOpen('s');
            for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
		if ak_query_pkg.g_results_table(r).value2 = p_value
                then
                    l_poplist := l_poplist||('<OPTION SELECTED VALUE="'||ak_query_pkg.g_results_table(r).value2||'">'||ak_query_pkg.g_results_table(r).value1);
                else
                    l_poplist := l_poplist||('<OPTION VALUE="'||ak_query_pkg.g_results_table(r).value2||'">'||ak_query_pkg.g_results_table(r).value1);
		end if;
            end loop;
            l_poplist := l_poplist||htf.formSelectClose;

	end if;

        htp.tableData(cvalue => l_poplist, crowspan => p_rowspan);

    else

        htp.tableData(cvalue => icx_on_utilities.formatText(p_value,p_bold,p_italic), calign => p_halign, cattributes => 'VALIGN="'||p_valign||'"', crowspan => p_rowspan);

    end if;
else

    htp.tableData(cvalue => icx_on_utilities.formatText(p_value,p_bold,p_italic), calign => p_halign, cattributes => 'VALIGN="'||p_valign||'"', crowspan => p_rowspan);

end if;

end;

procedure displayRegion(p_region_rec_id in number) is

l_flow_appl_id		number;
l_flow_code		varchar2(30);
l_page_appl_id		number;
l_page_code		varchar2(30);
l_region_appl_id	number;
l_region_code		varchar2(30);
l_start			number;
l_end			number;
l_start_region		varchar2(30);

l_region_name		varchar2(80);
l_region_style		varchar2(30);
l_num_columns		number;
l_total_result_count	number;

l_region_items_start	number;
l_region_items_end	number;
l_region_results_start	number;
l_region_results_end	number;
l_attribute_appl_id	number;
l_attribute_code	varchar2(30);

l_results_start		number;
l_results_end		number;

l_query_set     number;
l_query_set2    number;
l_start_row     number;
l_stop_row      number;
l_language_code varchar2(30);
l_session_id	number;
l_header_color varchar2(30);
l_header_text_color varchar2(30);
l_data_multirow_color varchar2(30);
l_data_singlerow_color varchar2(30);

l_display_sequences     icx_on_utilities.number_table;
l_update_counts		icx_on_utilities.number_table;
l_value_id              icx_on_utilities.number_table;
l_item_styles           icx_on_utilities.v30_table;
l_data_types		icx_on_utilities.v30_table;
l_rowids                icx_on_utilities.rowid_table;
l_url_display_sequence  icx_on_utilities.number_table;
-- l_uk_column_tab		ak_query_pkg.rel_key_tab;

l_continue	boolean;
l_update	boolean;
l_rowspan	number;
l_update_count	number;
l_update_total	number;
l_row_count     number;
l_display_count number;
l_counter	number;
l_values        icx_util.char4000_table;
l_goto          varchar2(2000);
l_table_row	varchar2(2000);
l_table_rows	icx_on_utilities.v2000_table;
l_X             varchar2(2000);
l_Y             varchar2(2000);
l_message	varchar2(2000);
l_submit_string	varchar2(2000);
l_input_check	varchar2(2000);
l_attribute_codes varchar2(2000);
p_result_values	varchar2(2000);
l_value		varchar2(4000);
l_procedure_call varchar2(2000);
l_call		integer;
l_dummy 	integer;

l_status	varchar2(240);
l_title		varchar2(80);
l_prompts       icx_util.g_prompts_table;

c_browser varchar2(400):=owa_util.get_cgi_env('HTTP_USER_AGENT');

cursor links is
        select  b.ROWID L_ROWID
        from    AK_FLOW_REGION_RELATIONS b,
                AK_FLOW_PAGE_REGION_ITEMS a
        where   a.ATTRIBUTE_CODE = l_attribute_code
        and     a.ATTRIBUTE_APPLICATION_ID = l_attribute_appl_id
        and     a.REGION_CODE = l_region_code
        and     a.REGION_APPLICATION_ID = l_region_appl_id
        and     a.PAGE_CODE = l_page_code
        and     a.PAGE_APPLICATION_ID = l_page_appl_id
        and     a.FLOW_CODE = l_flow_code
        and     a.FLOW_APPLICATION_ID = l_flow_appl_id
        and     a.REGION_CODE = b.FROM_REGION_CODE
        and     a.REGION_APPLICATION_ID = b.FROM_REGION_APPL_ID
        and     a.PAGE_CODE = b.FROM_PAGE_CODE
        and     a.PAGE_APPLICATION_ID = b.FROM_PAGE_APPL_ID
        and     a.FLOW_CODE = b.FLOW_CODE
        and     a.FLOW_APPLICATION_ID = b.FLOW_APPLICATION_ID
        and     a.TO_PAGE_CODE = b.TO_PAGE_CODE
        and     a.TO_PAGE_APPL_ID = b.TO_PAGE_APPL_ID;

cursor urls is
        select  a.DISPLAY_SEQUENCE
        from    AK_REGION_ITEMS a,
                AK_FLOW_PAGE_REGION_ITEMS b
        where   b.ATTRIBUTE_CODE = l_attribute_code
        and     b.ATTRIBUTE_APPLICATION_ID = l_attribute_appl_id
        and     b.TO_URL_ATTRIBUTE_CODE is not null
        and     b.TO_URL_ATTRIBUTE_APPL_ID is not null
        and     b.REGION_CODE = l_region_code
        and     b.REGION_APPLICATION_ID = l_region_appl_id
        and     b.PAGE_CODE = l_page_code
        and     b.PAGE_APPLICATION_ID = l_page_appl_id
        and     b.FLOW_CODE = l_flow_code
        and     b.FLOW_APPLICATION_ID = l_flow_appl_id
        and     b.REGION_CODE = a.REGION_CODE
        and     b.REGION_APPLICATION_ID = a.REGION_APPLICATION_ID
        and     b.TO_URL_ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
        and     b.TO_URL_ATTRIBUTE_APPL_ID = a.ATTRIBUTE_APPLICATION_ID;
begin

l_flow_appl_id	:= ak_query_pkg.g_regions_table(p_region_rec_id).flow_application_id;
l_flow_code	:= ak_query_pkg.g_regions_table(p_region_rec_id).flow_code;
l_page_appl_id	:= ak_query_pkg.g_regions_table(p_region_rec_id).page_application_id;
l_page_code	:= ak_query_pkg.g_regions_table(p_region_rec_id).page_code;
l_region_appl_id := ak_query_pkg.g_regions_table(p_region_rec_id).region_application_id;
l_region_code	:= ak_query_pkg.g_regions_table(p_region_rec_id).region_code;
l_region_name	:= ak_query_pkg.g_regions_table(p_region_rec_id).name;
l_region_style	:= ak_query_pkg.g_regions_table(p_region_rec_id).region_style;
l_num_columns	:= nvl(ak_query_pkg.g_regions_table(p_region_rec_id).number_of_format_columns,2);
l_total_result_count := ak_query_pkg.g_regions_table(p_region_rec_id).total_result_count;

l_region_items_start := -1;
l_region_items_end := 0;

for i in 0..(ak_query_pkg.g_items_table.COUNT - 1) loop
        if ak_query_pkg.g_items_table(i).region_rec_id = p_region_rec_id
        then
                if l_region_items_start < 0
                then
                        l_region_items_start := i;
                end if;
                l_region_items_end := i;
        end if;
end loop; -- ak_query_pkg.g_items_table

l_region_results_start := -1;
l_region_results_end := 0;

for i in 0..(ak_query_pkg.g_results_table.COUNT - 1) loop
        if ak_query_pkg.g_results_table(i).region_rec_id = p_region_rec_id
        then
                if l_region_results_start < 0
                then
                        l_region_results_start := i;
                end if;
		l_region_results_end := i;
        end if;
end loop; -- p_result_table

if l_region_items_start >= 0 and l_region_results_start >= 0
then

l_start		:= icx_on_utilities.g_on_parameters(6);
l_end		:= icx_on_utilities.g_on_parameters(7);
l_start_region	:= icx_on_utilities.g_on_parameters(8);
l_language_code	:= icx_sec.getID(icx_sec.pv_language_code);
l_session_id	:= icx_sec.getID(icx_sec.pv_session_id);

for i in l_region_items_start..l_region_items_end loop
        l_display_sequences(ak_query_pkg.g_items_table(i).display_sequence) := i;
end loop;

l_update := FALSE;
l_rowspan := 1;
l_update_count := 0;
l_X := '';

for i in l_region_items_start..l_region_items_end loop
        -- nlbarlow disable ON form support
	if ak_query_pkg.g_items_table(i).update_flag = 'X'
	then
		l_update := TRUE;
		l_update_count := l_update_count + 1;
		l_X := l_X||ak_query_pkg.g_items_table(i).attribute_code||'*';
	end if;
	if ak_query_pkg.g_items_table(i).attribute_label_length = 0
	then
	    ak_query_pkg.g_items_table(i).attribute_label_long := '<BR>';
	end if;
        l_value_id(i) := ak_query_pkg.g_items_table(i).value_id;
        l_item_styles(i) :=  ak_query_pkg.g_items_table(i).item_style;
	if l_item_styles(i) = 'HIDDEN'
	then
		l_update_count := l_update_count + 1;
		l_X := l_X||ak_query_pkg.g_items_table(i).attribute_code||'*';
	elsif l_item_styles(i) = 'SPINBOX'
	then
		l_rowspan := 2;
		l_update_counts(i) := l_update_count;
	end if;
        l_attribute_appl_id := ak_query_pkg.g_items_table(i).attribute_application_id;
        l_attribute_code := ak_query_pkg.g_items_table(i).attribute_code;
	l_attribute_codes := l_attribute_codes||ak_query_pkg.g_items_table(i).attribute_code||'*';
	select  DATA_TYPE
        into    l_data_types(i)
        from    AK_ATTRIBUTES
        where   ATTRIBUTE_APPLICATION_ID = l_attribute_appl_id
        and     ATTRIBUTE_CODE = l_attribute_code;

        l_ROWIDS(I) := '';
        l_url_display_sequence(i) := '';

        for l in links loop
                if l_item_styles(i) = 'BUTTON'
                then
                        l_rowids(i) := l.L_ROWID;
                else
                        l_rowids(i) := l.L_ROWID;
                end if;
        end loop; -- links

        for u in urls loop
                l_item_styles(i) := 'URL';
                l_url_display_sequence(i) := l_display_sequences(u.DISPLAY_SEQUENCE);
        end loop; -- urls

        if ak_query_pkg.g_items_table(i).region_defaulting_api_pkg is not null
        then
                l_item_styles(i) := 'DEFAULT_PKG';
        end if;

-- htp.p('DEBUG '||i||' '||ak_query_pkg.g_items_table(i).attribute_label_long||' '||l_attribute_code||' '||l_item_styles(i)||' '||l_url_display_sequence(i));htp.nl;

end loop; -- region_items

l_attribute_codes := l_attribute_codes||']';
l_update_total := l_update_count;

if l_update
then
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('<!-- Hide from old browsers');

        js.checkNumber;

        htp.p('function check_number(field) {
             if (!checkNumber(field)) {
                field.focus();
                field.value = "";
             }
           }');

        js.null_alert;

        htp.p('function spin_up(element_ind) {
           if (document.inputForm'||p_region_rec_id||'.elements[element_ind].value == "") {
                document.inputForm'||p_region_rec_id||'.elements[element_ind].value = 1
           }
           else {
                document.inputForm'||p_region_rec_id||'.elements[element_ind].value++
           }
        }');

        htp.p('function spin_down(element_ind) {
           if (document.inputForm'||p_region_rec_id||'.elements[element_ind].value != "") {
             if (document.inputForm'||p_region_rec_id||'.elements[element_ind].value >= 1) {
                document.inputForm'||p_region_rec_id||'.elements[element_ind].value--
             }
             else {
                document.inputForm'||p_region_rec_id||'.elements[element_ind].value = ""
             }
           }
        }');

if icx_on_utilities.g_on_parameters(1) = 'W'
then
    l_Y :=  icx_on_utilities.g_on_parameters(1)||'*'||icx_on_utilities.g_on_parameters(2)||'*'||icx_on_utilities.g_on_parameters(3)||'*'||icx_on_utilities.g_on_parameters(4)||'*'||icx_on_utilities.g_on_parameters(5)
	||'*'||icx_call.decrypt2(icx_on_utilities.g_on_parameters(9))||'**]';
else
    l_Y :=  icx_on_utilities.g_on_parameters(1)||'*'||icx_on_utilities.g_on_parameters(2)||'*'||icx_on_utilities.g_on_parameters(3)||'*'||icx_on_utilities.g_on_parameters(4)||'*'||icx_on_utilities.g_on_parameters(5)
	||'*'||icx_on_utilities.g_on_parameters(6)||'*'||icx_on_utilities.g_on_parameters(7)||'*'||icx_on_utilities.g_on_parameters(8)||'*'||icx_on_utilities.g_on_parameters(9)||'*'||icx_on_utilities.g_on_parameters(10)
	||'*'||icx_on_utilities.g_on_parameters(11)||'*'||icx_on_utilities.g_on_parameters(12)||'*'||icx_on_utilities.g_on_parameters(13)||'*'||icx_on_utilities.g_on_parameters(14)||'*'||icx_on_utilities.g_on_parameters(15)
	||'*'||icx_on_utilities.g_on_parameters(16)||'*'||icx_on_utilities.g_on_parameters(17)||'*'||icx_on_utilities.g_on_parameters(18)||'*'||icx_on_utilities.g_on_parameters(19)||'*'||icx_on_utilities.g_on_parameters(20)
	||'*'||icx_on_utilities.g_on_parameters(21)||'**]';
end if;

l_X := icx_call.encrypt2(l_X||']');
l_Y := icx_call.encrypt2(l_Y);

        htp.p('function submitFunction() {
               var Z = "";
               for (i=0; i < document.inputForm'||p_region_rec_id||'.elements.length; i++) {
                   if (document.inputForm'||p_region_rec_id||'.elements[i].name == "c")
                       Z = Z + document.inputForm'||p_region_rec_id||'.elements[i].checked + "*";
                   else
		       if (document.inputForm'||p_region_rec_id||'.elements[i].name == "s")
		           Z = Z + document.inputForm'||p_region_rec_id||'.elements[i].options[document.inputForm'||p_region_rec_id||'.elements[i].selectedIndex].value + "*";
		       else
                           Z = Z + document.inputForm'||p_region_rec_id||'.elements[i].value + "*";
                   };
		document.submitForm.Z.value = Z + "]";
		document.submitForm.submit();
                }');

        htp.p('function resetFunction() {
                    document.inputForm'||p_region_rec_id||'.reset();
                }');

        htp.p('// -->');
        htp.p('</SCRIPT>');

	htp.formOpen(curl => icx_cabo.g_plsql_agent||ak_query_pkg.g_regions_table(p_region_rec_id).region_validation_api_pkg||'.'||ak_query_pkg.g_regions_table(p_region_rec_id).region_validation_api_proc, cattributes => 'NAME="submitForm"');
	htp.formHidden('X',l_X);
	htp.formHidden('Y',l_Y);
	htp.formHidden('Z');
	htp.formClose;
end if;

htp.formOpen(curl => 'javascript:submitFunction()', cattributes => 'NAME="inputForm'||p_region_rec_id||'"');

if l_region_style = 'TABLE'
then

l_header_color := icx_util.get_color('TABLE_HEADER');
l_header_text_color := icx_util.get_color('TABLE_HEADER_TEXT');
l_data_multirow_color := icx_util.get_color('TABLE_DATA_MULTIROW');

select  QUERY_SET
into    l_query_set
from    ICX_PARAMETERS;

if l_end is null
then
    if l_query_set > l_region_results_end - l_region_results_start
    then
	l_query_set2 := l_region_results_end - l_region_results_start + 1;
    else
	l_query_set2 := l_query_set;
    end if;
else
    l_query_set2 := l_end - l_start + 1;
end if;

if l_start_region = l_region_code
then
        if l_start < 1 or l_start is null
        then
                l_start_row := 1;
        else
                l_start_row := l_start;
        end if;
else
        l_start_row := 1;
end if;
l_stop_row := l_start_row+l_query_set2-1;
if l_region_results_end - l_region_results_start <> l_stop_row - l_start_row
then
    -- nlbarlow 2334932, added conditon to prevent row over run
    if l_region_results_start + l_stop_row - 1 <= l_region_results_end
    then
	l_region_results_end   := l_region_results_start + l_stop_row - 1;
    end if;
    l_region_results_start := l_region_results_start + l_start_row - 1;
end if;

l_Y :=  icx_on_utilities.g_on_parameters(1)||'*'||icx_on_utilities.g_on_parameters(2)||'*'||icx_on_utilities.g_on_parameters(3)||'*'||icx_on_utilities.g_on_parameters(4)||'*'||icx_on_utilities.g_on_parameters(5)
	||'*'||icx_on_utilities.g_on_parameters(6)||'*'||icx_on_utilities.g_on_parameters(7)||'*'||l_region_code||'*'||'*'||icx_on_utilities.g_on_parameters(10)
	||'*'||icx_on_utilities.g_on_parameters(11)||'*'||icx_on_utilities.g_on_parameters(12)||'*'||icx_on_utilities.g_on_parameters(13)||'*'||icx_on_utilities.g_on_parameters(14)||'*'||icx_on_utilities.g_on_parameters(15)
	||'*'||icx_on_utilities.g_on_parameters(16)||'*'||icx_on_utilities.g_on_parameters(17)||'*'||icx_on_utilities.g_on_parameters(18)||'*'||icx_on_utilities.g_on_parameters(19)||'*'||icx_on_utilities.g_on_parameters(20)
	||'*'||icx_on_utilities.g_on_parameters(21)||'**]';

if l_total_result_count > 5
then

icx_on_utilities2.displaySetIcons(l_language_code,icx_cabo.g_plsql_agent||'OracleON.IC',l_start_row,l_stop_row,icx_on_utilities.g_on_parameters(9),l_query_set,l_total_result_count,TRUE,'',icx_call.encrypt2(l_Y),l_update);

end if;

htp.tableOpen(cborder => 'BORDER=2', cattributes => 'CELLPADDING=2');
htp.p('<TR BGColor="#'||l_header_color||'">');
    for i in l_region_items_start..l_region_items_end loop
        if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        and ak_query_pkg.g_items_table(i).secured_column = 'F'
        then
            if l_item_styles(i) = 'BUTTON'
            then
	        htp.tableData(cvalue => '<font color="#'||l_header_text_color||'"><BR>');
            elsif l_item_styles(i) = 'HIDDEN'
            then
                l_title := '';
            elsif l_item_styles(i) = 'SPINBOX' and l_data_types(i) = 'NUMBER'
	    then
	        htp.tableData(cvalue => '<font color="#'||l_header_text_color||'"><B>'||ak_query_pkg.g_items_table(i).attribute_label_long||'</B>', calign => 'CENTER', ccolspan => 2);
            else
                htp.tableData('<font color="#'||l_header_text_color||'"><B>'||ak_query_pkg.g_items_table(i).attribute_label_long||'</B>', calign => 'CENTER');
            end if;
        end if;
    end loop; -- region_items
htp.tableRowClose;
htp.tableRowOpen;
htp.tableRowClose;
htp.tableRowOpen;
htp.tableRowClose;

l_row_count := 0;

for r in l_region_results_start..l_region_results_end loop

        l_row_count := l_row_count + 1;

        icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values);

--	ak_query_pkg.get_uk_columns(ak_query_pkg.g_regions_table(p_region_rec_id).primary_key_name, l_uk_column_tab);
        l_goto := ak_query_pkg.g_regions_table(p_region_rec_id).primary_key_name
		||'*'||ak_query_pkg.g_results_table(r).key1
		||'*'||ak_query_pkg.g_results_table(r).key2
		||'*'||ak_query_pkg.g_results_table(r).key3
		||'*'||ak_query_pkg.g_results_table(r).key4
		||'*'||ak_query_pkg.g_results_table(r).key5
		||'*'||ak_query_pkg.g_results_table(r).key6
		||'*'||ak_query_pkg.g_results_table(r).key7
		||'*'||ak_query_pkg.g_results_table(r).key8
		||'*'||ak_query_pkg.g_results_table(r).key9
		||'*'||ak_query_pkg.g_results_table(r).key10||'**]';

        htp.p('<TR BGColor="#'||l_data_multirow_color||'">');

        for i in l_region_items_start..l_region_items_end loop

            if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
            and ak_query_pkg.g_items_table(i).secured_column = 'F'
            then
-- htp.p('DEBUG '||i||' '||l_value_id(i)||' '||l_secured_column(i)||' '||l_node_display_flag(i)||' '||ak_query_pkg.g_items_table(i).attribute_label_long||' '||l_item_styles(i)||' '||l_url_display_sequence(i));htp.nl;

	    if ak_query_pkg.g_items_table(i).value_id is null
            then
                l_value := ak_query_pkg.g_items_table(i).attribute_label_long;
            else
                l_value := l_values(ak_query_pkg.g_items_table(i).value_id);
            end if;

            if l_item_styles(i) = 'TEXT'
            then

                printText(	ak_query_pkg.g_items_table(i),
                                l_data_types(i),
                                l_value,
				l_rowids(i),
                                l_goto,
                                l_session_id,
				l_region_style,
				'',
                                l_rowspan);

	    elsif l_item_styles(i) = 'SPINBOX'
                then

		    printSpinboxup(	ak_query_pkg.g_items_table(i).update_flag,
					ak_query_pkg.g_items_table(i).required_flag,
					ak_query_pkg.g_items_table(i).attribute_label_long,
					l_data_types(i),
					l_value,
					ak_query_pkg.g_items_table(i).display_value_length,
                                	ak_query_pkg.g_items_table(i).bold,
                                	ak_query_pkg.g_items_table(i).italic,
                                	ak_query_pkg.g_items_table(i).horizontal_alignment,
                                	ak_query_pkg.g_items_table(i).vertical_alignment,
					to_char((l_row_count-1)*l_update_total+l_update_counts(i)-1),
					l_language_code,
					l_rowspan);

            elsif l_item_styles(i) = 'BUTTON'
            then
		printButton(	ak_query_pkg.g_items_table(i),
				l_rowids(i),
				l_goto,
				l_session_id,
				l_rowspan,
				l_region_style);

            elsif l_item_styles(i) = 'HIDDEN'
            then
		htp.formHidden('h',l_value);
            elsif l_item_styles(i) = 'CHECKBOX'
            then

		printCheckbox(	ak_query_pkg.g_items_table(i).update_flag,
				ak_query_pkg.g_items_table(i).value_id,
				l_value,
				ak_query_pkg.g_items_table(i).horizontal_alignment,
				ak_query_pkg.g_items_table(i).vertical_alignment,
				l_language_code,
				l_rowspan,
                                '');

            elsif l_item_styles(i) = 'IMAGE'
            then

		printImage(	ak_query_pkg.g_items_table(i),
				l_value,
				l_rowids(i),
				l_goto,
				l_session_id,
				l_language_code,
				l_rowspan);

            elsif l_item_styles(i) = 'POPLIST'
            then

	        printPoplist(	ak_query_pkg.g_items_table(i).lov_region_application_id,
				ak_query_pkg.g_items_table(i).lov_region_code,
				ak_query_pkg.g_items_table(i).update_flag,
				ak_query_pkg.g_items_table(i).value_id,
				l_value,
                                ak_query_pkg.g_items_table(i).bold,
                                ak_query_pkg.g_items_table(i).italic,
                                ak_query_pkg.g_items_table(i).horizontal_alignment,
                                ak_query_pkg.g_items_table(i).vertical_alignment,
				l_rowspan);

            elsif l_item_styles(i) = 'DEFAULT_PKG'
            then
		htp.p('<TD ALIGN="'||ak_query_pkg.g_items_table(i).horizontal_alignment||'" ROWSPAN="'||l_rowspan||'" VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'">');
		l_procedure_call := ak_query_pkg.g_items_table(i).region_defaulting_api_pkg||'.'||ak_query_pkg.g_items_table(i).region_defaulting_api_proc||'(:l_attribute_codes,:p_result_values)';
		p_result_values := '';

		for i in l_region_items_start..l_region_items_end loop
		    if ak_query_pkg.g_items_table(i).value_id is null
		    then
			p_result_values := p_result_values||'*';
		    else
                        l_value := replace(l_values(l_value_id(i)),'*','~at~');
                        l_value := replace(l_value,']','~end~');
                        p_result_values := p_result_values||l_value||'*';
		    end if;
		end loop;
		p_result_values := p_result_values||']';
		l_call := dbms_sql.open_cursor;
		dbms_sql.parse(l_call,'begin '||l_procedure_call||'; end;',dbms_sql.native);
		dbms_sql.bind_variable(l_call,'l_attribute_codes',l_attribute_codes);
		dbms_sql.bind_variable(l_call,'p_result_values',p_result_values);
		l_dummy := dbms_sql.execute(l_call);
		dbms_sql.close_cursor(l_call);
		htp.p('</TD>');
            elsif l_item_styles(i) = 'URL'
            then
                if l_values(l_value_id(l_url_display_sequence(i))) is null
                then
                    printText(      ak_query_pkg.g_items_table(i),
                                    l_data_types(i),
                                    l_value,
                                    l_rowids(i),
                                    l_goto,
                                    l_session_id,
                                    l_region_style,
				    '',
                                    l_rowspan);
                else
                        htp.tableData(cvalue => '<A HREF="'||replace(l_values(l_value_id(l_url_display_sequence(i))),'[PLSQL_AGENT]',FND_WEB_CONFIG.PLSQL_AGENT)||'" TARGET="_top">'
			||icx_on_utilities.formatText(l_values(l_value_id(i)),ak_query_pkg.g_items_table(i).bold,ak_query_pkg.g_items_table(i).italic)
			||'</A>', calign => ak_query_pkg.g_items_table(i).horizontal_alignment, cattributes => 'VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'"', crowspan => l_rowspan);
                end if;
            else
		printText(      ak_query_pkg.g_items_table(i),
                                l_data_types(i),
                                l_value,
                                l_rowids(i),
                                l_goto,
                                l_session_id,
				l_region_style,
				'',
                                l_rowspan);
            end if;
            end if;
        end loop; -- region_items
        htp.tableRowClose;

	if l_rowspan = 2
	then
	    htp.p('<TR BGColor="#'||l_data_multirow_color||'">');
	    for i in l_region_items_start..l_region_items_end loop
        	if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
            	and ak_query_pkg.g_items_table(i).secured_column = 'F'
            	then
		    if l_item_styles(i) = 'SPINBOX'
		    then
			printSpinboxdown(	ak_query_pkg.g_items_table(i).update_flag,
						l_data_types(i),
						to_char((l_row_count-1)*l_update_total+l_update_counts(i)-1),
						l_language_code);
		    end if;
		end if;
	    end loop; -- region_items
	    htp.tableRowClose;
	end if; -- l_rowspan = 2

end loop; -- ak_query_pkg.g_results_table

if l_total_result_count > 5 and l_query_set2 > 5 then
htp.tableRowOpen;
htp.tableRowClose;
htp.tableRowOpen;
htp.tableRowClose;
htp.p('<TR BGColor="#'||l_header_color||'">');
    for i in l_region_items_start..l_region_items_end loop
        if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        and ak_query_pkg.g_items_table(i).secured_column = 'F'
        then
            if l_item_styles(i) = 'BUTTON'
            then
                htp.tableData(cvalue => '<font color="#'||l_header_text_color||'"><BR>');
            elsif l_item_styles(i) = 'HIDDEN'
            then
                l_title := '';
            elsif l_item_styles(i) = 'SPINBOX' and l_data_types(i) = 'NUMBER'
            then
                htp.tableData(cvalue => '<font color="#'||l_header_text_color||'"><B>'||ak_query_pkg.g_items_table(i).attribute_label_long||'</B>', calign => 'CENTER', ccolspan => 2);
            else
                htp.tableData('<font color="#'||l_header_text_color||'"><B>'||ak_query_pkg.g_items_table(i).attribute_label_long||'</B>', calign => 'CENTER');
            end if;
        end if;
    end loop; -- region_items
htp.tableRowClose;
end if;

htp.tableClose;
htp.formClose;

if l_total_result_count > 5
then

icx_on_utilities2.displaySetIcons(l_language_code,icx_cabo.g_plsql_agent||'OracleON.IC',l_start_row,l_stop_row,icx_on_utilities.g_on_parameters(9),l_query_set,l_total_result_count,FALSE,'',icx_call.encrypt2(l_Y),l_update);

end if;

elsif l_region_style = 'FORM'
then

l_data_singlerow_color := icx_util.get_color('TABLE_DATA_SINGLEROW');
l_row_count := 0;
l_display_count := 0;
l_counter := 1;
l_start_row := 1;
l_stop_row  := 2;

htp.tableOpen('BORDER=0');

for r in l_region_results_start..l_region_results_end loop

    l_row_count := l_row_count + 1;

    if l_start_row <= l_row_count and l_row_count <= l_stop_row
    then

        icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values);

        l_goto := ak_query_pkg.g_regions_table(p_region_rec_id).primary_key_name
		||'*'||ak_query_pkg.g_results_table(r).key1||'*'||ak_query_pkg.g_results_table(r).key2||'*'||ak_query_pkg.g_results_table(r).key3||'*'||ak_query_pkg.g_results_table(r).key4||'*'||ak_query_pkg.g_results_table(r).key5
		||'*'||ak_query_pkg.g_results_table(r).key6||'*'||ak_query_pkg.g_results_table(r).key7||'*'||ak_query_pkg.g_results_table(r).key8||'*'||ak_query_pkg.g_results_table(r).key9||'*'||ak_query_pkg.g_results_table(r).key10||'**]';

for i in l_region_items_start..l_region_items_end loop

   if l_counter = 1
   and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
   and ak_query_pkg.g_items_table(i).secured_column = 'F'
   then
        htp.tableRowOpen;
   end if;

   if l_value_id(i) is null
   then
       l_value := ak_query_pkg.g_items_table(i).attribute_label_long;
   else
       l_value := l_values(l_value_id(i));
   end if;

   if ak_query_pkg.g_items_table(i).node_display_flag = 'N'
   or ak_query_pkg.g_items_table(i).secured_column = 'T'
   or (ak_query_pkg.g_items_table(i).attribute_label_long is null and l_value is null)
   then
        l_counter := l_counter;
   else
        if l_item_styles(i) = 'TEXT'
        then

            htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN='||ak_query_pkg.g_items_table(i).vertical_alignment);
            htp.tableData(' ');

            printText(      ak_query_pkg.g_items_table(i),
                            l_data_types(i),
                            l_value,
                            l_rowids(i),
                            l_goto,
                            l_session_id,
			    l_region_style,
			    l_data_singlerow_color,
                            l_rowspan);

        elsif l_item_styles(i) = 'SPINBOX'
        then

            htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
            htp.tableData(' ');

            printSpinboxup(     ak_query_pkg.g_items_table(i).update_flag,
                                ak_query_pkg.g_items_table(i).required_flag,
                                ak_query_pkg.g_items_table(i).attribute_label_long,
                                l_data_types(i),
                                l_value,
				ak_query_pkg.g_items_table(i).display_value_length,
                                'Y',
                                ak_query_pkg.g_items_table(i).italic,
                                ak_query_pkg.g_items_table(i).horizontal_alignment,
                                ak_query_pkg.g_items_table(i).vertical_alignment,
                                to_char((l_row_count-1)*l_update_total+l_update_counts(i)-1),
                                l_language_code,
                                l_rowspan);

       elsif l_item_styles(i) = 'BUTTON'
       then

           printButton(    ak_query_pkg.g_items_table(i),
			   l_rowids(i),
                           l_goto,
                           l_session_id,
                           l_rowspan,
			   l_region_style);

       elsif l_item_styles(i) = 'HIDDEN'
       then
           htp.formHidden('h',l_value);

       elsif l_item_styles(i) = 'CHECKBOX'
       then

           htp.tableData(' ');
           htp.tableData(' ');

           printCheckbox(  ak_query_pkg.g_items_table(i).update_flag,
                           ak_query_pkg.g_items_table(i).value_id,
                           l_value,
                           ak_query_pkg.g_items_table(i).horizontal_alignment,
                           ak_query_pkg.g_items_table(i).vertical_alignment,
                           l_language_code,
                           l_rowspan,
			   ak_query_pkg.g_items_table(i).attribute_label_long);

       elsif l_item_styles(i) = 'POPLIST'
       then

           htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
           htp.tableData(' ');

           printPoplist(   ak_query_pkg.g_items_table(i).lov_region_application_id,
                           ak_query_pkg.g_items_table(i).lov_region_code,
			   ak_query_pkg.g_items_table(i).update_flag,
                           ak_query_pkg.g_items_table(i).value_id,
                           l_value,
                           ak_query_pkg.g_items_table(i).bold,
                           ak_query_pkg.g_items_table(i).italic,
                           ak_query_pkg.g_items_table(i).horizontal_alignment,
                           ak_query_pkg.g_items_table(i).vertical_alignment,
                           l_rowspan);
            elsif l_item_styles(i) = 'DEFAULT_PKG'
            then
                htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
        htp.tableData(' ');
                htp.p('<TD ALIGN="'||ak_query_pkg.g_items_table(i).horizontal_alignment||'" ROWSPAN="'||l_rowspan||'" VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'">');
                l_procedure_call := ak_query_pkg.g_items_table(i).region_defaulting_api_pkg||'.'||ak_query_pkg.g_items_table(i).region_defaulting_api_proc||'(:l_attribute_codes,:p_result_values)';
                p_result_values := '';

                for i in l_region_items_start..l_region_items_end loop
                    if ak_query_pkg.g_items_table(i).value_id is null
                    then
                        p_result_values := p_result_values||'*';
                    else
                        l_value := replace(l_values(l_value_id(i)),'*','~at~');
                        l_value := replace(l_value,']','~end~');
                        p_result_values := p_result_values||l_value||'*';
                    end if;
                end loop;
                p_result_values := p_result_values||']';
                l_call := dbms_sql.open_cursor;
                dbms_sql.parse(l_call,'begin '||l_procedure_call||'; end;',dbms_sql.native);
                dbms_sql.bind_variable(l_call,'l_attribute_codes',l_attribute_codes);
                dbms_sql.bind_variable(l_call,'p_result_values',p_result_values);
                l_dummy := dbms_sql.execute(l_call);
                dbms_sql.close_cursor(l_call);
                htp.p('</TD>');
	elsif l_item_styles(i) = 'URL'
        then
            if l_values(l_value_id(l_url_display_sequence(i))) is null
            then
		htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
                htp.tableData(' ');
                printText(      ak_query_pkg.g_items_table(i),
                                l_data_types(i),
                                l_value,
                                l_rowids(i),
                                l_goto,
                                l_session_id,
                                l_region_style,
				l_data_singlerow_color,
                                l_rowspan);
            else
		htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
                htp.tableData(' ');
                htp.tableData(cvalue => '<A HREF="'||l_values(l_value_id(l_url_display_sequence(i)))||'">'
		||icx_on_utilities.formatText(l_values(l_value_id(i)),'Y',ak_query_pkg.g_items_table(i).italic)
		||'</A>', calign => ak_query_pkg.g_items_table(i).horizontal_alignment, cattributes => 'VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'"', crowspan => l_rowspan);
            end if;
	else
            htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'RIGHT','','','','','VALIGN=MIDDLE');
            htp.tableData(' ');
            printText(      ak_query_pkg.g_items_table(i),
                            l_data_types(i),
                            l_value,
                            l_rowids(i),
                            l_goto,
                            l_session_id,
                            l_region_style,
			    l_data_singlerow_color,
                            l_rowspan);

       end if; -- item_styles
   end if; -- node_display_flag

   if ak_query_pkg.g_items_table(i).node_display_flag = 'N'
   or ak_query_pkg.g_items_table(i).secured_column = 'T'
   then
        l_counter := l_counter;
   elsif l_counter = l_num_columns
   then
        htp.tableRowClose;
	if l_rowspan = 2
	then
	    htp.tableRowOpen;
	    for i in l_region_items_start..l_region_items_end loop
                if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                and ak_query_pkg.g_items_table(i).secured_column = 'F'
                then
                    if l_item_styles(i) = 'SPINBOX'
                    then
                        printSpinboxdown(       ak_query_pkg.g_items_table(i).update_flag,
                                                l_data_types(i),
                                                to_char((l_row_count-1)*l_update_total+l_update_counts(i)-1),
                                                l_language_code);
                    end if;
                end if;
            end loop; -- region_items
            htp.tableRowClose;
	end if;
        l_counter := 1;
        l_display_count := l_display_count + 1;
        l_table_rows(l_display_count) := l_table_row;
        l_table_row := '';
   else
        htp.tableData(' ');
        htp.tableData(' ');
        htp.tableData(' ');
        htp.tableData(' ');
        l_counter := l_counter + 1;
   end if;

end loop; -- region_items

    end if; -- rows

end loop; -- results

htp.tableClose;
htp.formClose;

end if; -- l_region_style

if l_update
then
	icx_util.getPrompts(601,'ICX_WEB_ON',l_title,l_prompts);
        htp.tableOpen(cborder => 'BORDER=0');
        htp.tableRowOpen;
htp.p('<TD>');
        icx_util.DynamicButton(P_ButtonText => l_prompts(6),
			       P_ImageFileName => 'FNDBSBMT',
                               P_OnMouseOverText => l_prompts(6),
                               P_HyperTextCall => 'javascript:submitFunction()',
                               P_LanguageCode => l_language_code,
                               P_JavaScriptFlag => FALSE);
htp.p('</TD>');
if (instr(c_browser,'MSIE 3')=0) then
htp.p('<TD>');
        icx_util.DynamicButton(P_ButtonText => l_prompts(7),
                               P_ImageFileName => 'FNDBCLR',
                               P_OnMouseOverText => l_prompts(7),
                               P_HyperTextCall => 'javascript:resetFunction()',
                               P_LanguageCode => l_language_code,
                               P_JavaScriptFlag => FALSE);
htp.p('</TD>');
end if; -- browser = 'MSIE 3'
        htp.tableRowClose;
        htp.tableClose;
end if; -- update

end if; -- no region items

end;

procedure printPLSQLtables is

begin

htp.p('===============================================================');htp.nl;
htp.p('REGIONS');htp.nl;
htp.p('===============================================================');htp.nl;
htp.p('Total Regions = '||to_char(ak_query_pkg.g_regions_table.COUNT));htp.nl;
FOR i IN ak_query_pkg.g_regions_table.FIRST..ak_query_pkg.g_regions_table.LAST LOOP
    htp.p('Regions Table Row ='||to_char(i));htp.nl;
    htp.p('-     region_rec_id             = '||to_char(ak_query_pkg.g_regions_table(i).region_rec_id));htp.nl;
    htp.p('-     parent_region_rec_id      = '||to_char(ak_query_pkg.g_regions_table(i).parent_region_rec_id));htp.nl;
    htp.p('-     total_result_count       = '||to_char(ak_query_pkg.g_regions_table(i).total_result_count));htp.nl;
    htp.p('-     flow_application_id       = '||to_char(ak_query_pkg.g_regions_table(i).flow_application_id));htp.nl;
    htp.p('-     flow_code                 = '||ak_query_pkg.g_regions_table(i).flow_code);htp.nl;
    htp.p('-     page_application_id       = '||to_char(ak_query_pkg.g_regions_table(i).page_application_id));htp.nl;
    htp.p('-     page_code                 = '||ak_query_pkg.g_regions_table(i).page_code);htp.nl;
    htp.p('-     region_application_id     = '||to_char(ak_query_pkg.g_regions_table(i).region_application_id));htp.nl;
    htp.p('-     region_code               = '||ak_query_pkg.g_regions_table(i).region_code);htp.nl;
    htp.p('-     primary_key_name          = '||ak_query_pkg.g_regions_table(i).primary_key_name);htp.nl;
    htp.p('-     name                      = '||ak_query_pkg.g_regions_table(i).name);htp.nl;
    htp.p('-     region_style              = '||ak_query_pkg.g_regions_table(i).region_style);htp.nl;
    htp.p('-     number_of_format_columns  = '||to_char(ak_query_pkg.g_regions_table(i).number_of_format_columns));htp.nl;
    htp.p('-     region_defaulting_api_pkg = '||ak_query_pkg.g_regions_table(i).region_defaulting_api_pkg);htp.nl;
    htp.p('-     region_defaulting_api_proc= '||ak_query_pkg.g_regions_table(i).region_defaulting_api_proc);htp.nl;
    htp.p('-     region_validation_api_pkg = '||ak_query_pkg.g_regions_table(i).region_validation_api_pkg);htp.nl;
    htp.p('-     region_validation_api_proc= '||ak_query_pkg.g_regions_table(i).region_validation_api_proc);htp.nl;
    htp.p('-     object_defaulting_api_pkg = '||ak_query_pkg.g_regions_table(i).object_defaulting_api_pkg);htp.nl;
    htp.p('-     object_defaulting_api_proc= '||ak_query_pkg.g_regions_table(i).object_defaulting_api_proc);htp.nl;
    htp.p('-     object_validation_api_pkg = '||ak_query_pkg.g_regions_table(i).object_validation_api_pkg);htp.nl;
    htp.p('-     object_validation_api_proc= '||ak_query_pkg.g_regions_table(i).object_validation_api_proc);htp.nl;
END LOOP;

htp.p('===============================================================');htp.nl;
htp.p('ITEMS');htp.nl;
htp.p('===============================================================');htp.nl;
htp.p('Total Items = '||to_char(ak_query_pkg.g_items_table.COUNT));htp.nl;
FOR i IN 0..(ak_query_pkg.g_items_table.COUNT - 1) LOOP
    htp.p('Item Table Row ='||to_char(i));htp.nl;
    htp.p('-     region_rec_id              = '||to_char(ak_query_pkg.g_items_table(i).region_rec_id));htp.nl;
    htp.p('-     value_id                   = '||to_char(ak_query_pkg.g_items_table(i).value_id));htp.nl;
    htp.p('-     attribute_application_id   = '||to_char(ak_query_pkg.g_items_table(i).attribute_application_id));htp.nl;
    htp.p('-     attribute_code             = '||ak_query_pkg.g_items_table(i).attribute_code);htp.nl;
    htp.p('-     attribute_label_long       = '||ak_query_pkg.g_items_table(i).attribute_label_long);htp.nl;
    htp.p('-     attribute_label_length     = '||to_char(ak_query_pkg.g_items_table(i).attribute_label_length));htp.nl;
    htp.p('-     display_value_length       = '||to_char(ak_query_pkg.g_items_table(i).display_value_length));htp.nl;
    htp.p('-     display_sequence           = '||to_char(ak_query_pkg.g_items_table(i).display_sequence));htp.nl;
    htp.p('-     item_style                 = '||ak_query_pkg.g_items_table(i).item_style);htp.nl;
    htp.p('-     bold                       = '||ak_query_pkg.g_items_table(i).bold);htp.nl;
    htp.p('-     italic                     = '||ak_query_pkg.g_items_table(i).italic);htp.nl;
    htp.p('-     vertical_alignment         = '||ak_query_pkg.g_items_table(i).vertical_alignment);htp.nl;
    htp.p('-     horizontal_alignment       = '||ak_query_pkg.g_items_table(i).horizontal_alignment);htp.nl;
    htp.p('-     object_attribute_flag      = '||ak_query_pkg.g_items_table(i).object_attribute_flag);htp.nl;
    htp.p('-     secured_column             = '||ak_query_pkg.g_items_table(i).secured_column);htp.nl;
    htp.p('-     node_query_flag            = '||ak_query_pkg.g_items_table(i).node_query_flag);htp.nl;
    htp.p('-     node_display_flag          = '||ak_query_pkg.g_items_table(i).node_display_flag);htp.nl;
    htp.p('-     update_flag                = '||ak_query_pkg.g_items_table(i).update_flag);htp.nl;
    htp.p('-     required_flag              = '||ak_query_pkg.g_items_table(i).required_flag);htp.nl;
    htp.p('-     icx_custom_call            = '||ak_query_pkg.g_items_table(i).icx_custom_call);htp.nl;
    htp.p('-     region_defaulting_api_pkg  = '||ak_query_pkg.g_items_table(i).region_defaulting_api_pkg);htp.nl;
    htp.p('-     region_defaulting_api_proc = '||ak_query_pkg.g_items_table(i).region_defaulting_api_proc);htp.nl;
    htp.p('-     region_validation_api_pkg  = '||ak_query_pkg.g_items_table(i).region_validation_api_pkg);htp.nl;
    htp.p('-     region_validation_api_proc = '||ak_query_pkg.g_items_table(i).region_validation_api_proc);htp.nl;
    htp.p('-     object_defaulting_api_pkg  = '||ak_query_pkg.g_items_table(i).object_defaulting_api_pkg);htp.nl;
    htp.p('-     object_defaulting_api_proc = '||ak_query_pkg.g_items_table(i).object_defaulting_api_proc);htp.nl;
    htp.p('-     object_validation_api_pkg  = '||ak_query_pkg.g_items_table(i).object_validation_api_pkg);htp.nl;
    htp.p('-     object_validation_api_proc = '||ak_query_pkg.g_items_table(i).object_validation_api_proc);htp.nl;
END LOOP;

htp.p('===============================================================');htp.nl;
htp.p('RESULTS');htp.nl;
htp.p('===============================================================');htp.nl;
htp.p('Total Results = '||to_char(ak_query_pkg.g_results_table.COUNT));htp.nl;

if ak_query_pkg.g_results_table.COUNT <> 0
then

FOR i IN ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST LOOP
    htp.p('Results Table Row ='||to_char(i));htp.nl;
    htp.p('-     region_rec_id   = '||to_char(ak_query_pkg.g_results_table(i).region_rec_id));htp.nl;
    htp.p('-     key1            = '||ak_query_pkg.g_results_table(i).key1);htp.nl;
    htp.p('-     key2            = '||ak_query_pkg.g_results_table(i).key2);htp.nl;
    htp.p('-     key3            = '||ak_query_pkg.g_results_table(i).key3);htp.nl;
    htp.p('-     key4            = '||ak_query_pkg.g_results_table(i).key4);htp.nl;
    htp.p('-     key5            = '||ak_query_pkg.g_results_table(i).key5);htp.nl;
    htp.p('-     value1          = '||ak_query_pkg.g_results_table(i).value1);htp.nl;
    htp.p('-     value2          = '||ak_query_pkg.g_results_table(i).value2);htp.nl;
    htp.p('-     value3          = '||ak_query_pkg.g_results_table(i).value3);htp.nl;
    htp.p('-     value4          = '||ak_query_pkg.g_results_table(i).value4);htp.nl;
    htp.p('-     value5          = '||ak_query_pkg.g_results_table(i).value5);htp.nl;
    htp.p('-     value6          = '||ak_query_pkg.g_results_table(i).value6);htp.nl;
    htp.p('-     value7          = '||ak_query_pkg.g_results_table(i).value7);htp.nl;
    htp.p('-     value8          = '||ak_query_pkg.g_results_table(i).value8);htp.nl;
    htp.p('-     value9          = '||ak_query_pkg.g_results_table(i).value9);htp.nl;
    htp.p('-     value10         = '||ak_query_pkg.g_results_table(i).value10);htp.nl;
END LOOP;

end if;

end;

end icx_on_utilities2;

/
