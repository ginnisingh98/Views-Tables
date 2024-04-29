--------------------------------------------------------
--  DDL for Package Body ICX_TEMPLATE_HEIRARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_TEMPLATE_HEIRARCHY" as
/* $Header: ICXTMPHB.pls 115.5 99/07/17 03:29:42 porting ship $ */



procedure main is

l_title       varchar2(80);
l_prompts     icx_util.g_prompts_table;

begin
if icx_sec.validateSession then
    icx_util.getPrompts(601,'ICX_RELATED_TEMPLATES_R',l_title,l_prompts);

    htp.htmlOpen;
    htp.headOpen;
        icx_util.copyright;
        htp.title(l_title);
    htp.headClose;

    htp.p('<FRAMESET rows="285,*">
	       <FRAME name="header" src="ICX_TEMPLATE_HEIRARCHY.template_head">
	       <FRAME name="tail" src="ICX_TEMPLATE_HEIRARCHY.template_tail">
	   </FRAMESET>');


    htp.p('<NOFRAMESET>');
	  FND_MESSAGE.SET_NAME('ICX','ICX_BROWSER');
          htp.p(FND_MESSAGE.Get);
    htp.p('</NOFRAMESET>');

    htp.htmlClose;
end if;  -- validateSession

end main;



procedure template_head(p_template in varchar2 default null,
 		        p_query_flag in varchar2 default 'F') is


cursor relations is
select lookup_code,
       meaning
from   fnd_lookups
where  lookup_type = 'ICX_RELATIONS'
and    enabled_flag = 'Y';

c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');
l_agent varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
l_language varchar2(30);
i number;
l_title       varchar2(80);
l_prompts     icx_util.g_prompts_table;
lov_title       varchar2(80);
lov_prompts     icx_util.g_prompts_table;
err_num number;
err_mesg varchar2(512);
temp_text varchar2(2000);
temp_relation_code varchar2(30);
temp_relation varchar2(80);

begin
if icx_sec.validateSession then
    icx_util.error_page_setup;
    l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    icx_util.getPrompts(601,'ICX_RELATED_TEMPLATES_R',l_title,l_prompts);
    icx_util.getPrompts(601,'ICX_LOV',lov_title,lov_prompts);

    htp.htmlOpen;
    htp.headOpen;
        icx_util.copyright;

        htp.title(l_title);

        js.scriptOpen;
            icx_util.LOVScript;
            icx_admin_sig.help_win_script('/OA_HTML/'||l_language||'/ICXHLMTH.htm');

	    js.null_alert;
	    js.equal_alert;

	    htp.p('function autoquery() {
		parent.tail.document.Tail.p_template.value = document.Template.ICX_TEMPLATE1.value
		parent.tail.document.Tail.submit()
	    }');


	    htp.p('function template_changed() {
		parent.tail.document.Tail.p_template.value = document.Template.ICX_TEMPLATE1.value
		parent.tail.document.Tail.submit()
	    }');

	    htp.p('function pre_template_LOV() {
	        LOV(''178'',''ICX_TEMPLATE1'',''601'',''ICX_RELATED_TEMPLATES_R'',''Template'',''header'','''','''')
	    }');

	    htp.p('function post_template_LOV(template_name) {
		parent.tail.document.Tail.p_template.value = template_name
		parent.tail.document.Tail.submit()
	    }');

	    FND_MESSAGE.SET_NAME('ICX','ICX_TMP_BEFORE');
	    htp.p('function pre_rel_template_LOV() {
		if (!null_alert(document.Template.ICX_TEMPLATE1.value,"'||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
	          LOV(''178'',''ICX_RELATED_TEMPLATE'',''601'',''ICX_RELATED_TEMPLATES_R'',''Template'',''header'','''','''')
		}
	    }');
	    -- remove manual where clause for now because html can not deal
 	    -- with the spaces in the template name
	    -- var l_where = "EXPRESS_NAME<>''" + document.Template.ICX_TEMPLATE1.value + "''"


	    FND_MESSAGE.SET_NAME('ICX','ICX_NOT_NULL');
	    htp.p('function template_submit() {
		if (!null_alert(document.Template.ICX_TEMPLATE1.value,"'||icx_util.replace_quotes(l_prompts(1))||' '||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
		  if (document.Template.ICX_RELATION.options[document.Template.ICX_RELATION.selectedIndex].value != "TOP") {');
	    FND_MESSAGE.SET_NAME('ICX','ICX_NOT_NULL');
	    htp.p('   if (!null_alert(document.Template.ICX_RELATED_TEMPLATE.value,"'||icx_util.replace_quotes(l_prompts(2))||' '||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {');
	    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_PARENT');
	    htp.p('      if (!equal_alert(document.Template.ICX_TEMPLATE1.value,document.Template.ICX_RELATED_TEMPLATE.value,"'||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
		        document.Template.submit()
		      }
		    }
		  } else {
		    document.Template.submit()
		  }
		}
	    }');

        js.scriptClose;
    htp.headClose;

    htp.bodyOpen(icx_admin_sig.background);
    icx_admin_sig.toolbar(language_code => l_language);

    htp.formOpen(l_agent||'/icx_template_heirarchy.template_insert','POST','','','NAME="Template"');

    htp.tableOpen;
    htp.tableRowOpen;
      htp.tableData('<H2>'||l_title||'</H2>');
    htp.tableRowClose;
    htp.tableClose;

    htp.tableOpen;
    htp.tableRowOpen;

    -- Blank table data
      htp.tableData('<BR>');
      htp.tableData('<BR>');

    -- Template text field
      htp.tableData(l_prompts(1),'RIGHT');
        htp.tableData(htf.formText('ICX_TEMPLATE1',30,81,p_template,'onchange="template_changed()"'));
          htp.tableData(htf.anchor('javascript:pre_template_LOV()',htf.img('/OA_MEDIA/'||l_language||'/FNDILOV.gif','CENTER',icx_util.replace_alt_quotes(lov_title),
'','BORDER=0 WIDTH=23 HEIGHT=21'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(lov_title)||''';return true"'));
    htp.tableRowClose;

    -- Relation poplist
    htp.tableRowOpen;
      htp.tableData(l_prompts(3),'RIGHT');
      htp.p('<TD>'||htf.formSelectOpen('ICX_RELATION'));
        open relations;
	loop
	    fetch relations into temp_relation_code, temp_relation;
	    exit when relations%NOTFOUND;
	    htp.formSelectOption(temp_relation,'','VALUE="'||temp_relation_code||'"');
	end loop;
        close relations;
      htp.p(htf.formSelectClose||'</TD>');

    -- Related Category text field
      htp.tableData(l_prompts(2),'RIGHT');
        htp.tableData(htf.formText('ICX_RELATED_TEMPLATE',30,81,''));
          htp.tableData(htf.anchor('javascript:pre_rel_template_LOV()',htf.img('/OA_MEDIA/'||l_language||'/FNDILOV.gif','CENTER',icx_util.replace_alt_quotes(lov_title),
'','BORDER=0 WIDTH=23 HEIGHT=21'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(lov_title)||''';return true"'));
    htp.tableRowClose;
    htp.tableClose;


    -- Write submit and clear buttons
    htp.tableOpen;
    htp.tableRowOpen;
      icx_util.DynamicButton(l_prompts(4),'FNDBSBMT.gif',l_prompts(4),'javascript:template_submit()',l_language,FALSE);
        if (instr(c_browser, 'MSIE') = 0) then
            icx_util.DynamicButton(l_prompts(5),'FNDBCLR.gif',l_prompts(5),'javascript:document.Template.reset()',l_language,FALSE);
        end if;
    htp.tableRowClose;
    htp.tableClose;


    -- Query relationships if screen is being repainted after a commit
    if p_query_flag = 'T' then
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
	htp.p('autoquery()');
        htp.p('</SCRIPT>');
    end if;


    htp.formClose;
    icx_sig.footer;
    htp.bodyClose;
    htp.htmlClose;

end if;  -- ValidateSession

exception
  when others then
    err_num := SQLCODE;
    temp_text := SQLERRM;
    select substr(temp_text,12,512) into err_mesg from dual;
         icx_util.add_error(err_mesg);
         icx_admin_sig.error_screen(l_title,l_language);

end;  -- template_head



procedure template_tail(p_template in varchar2 default null,
		        p_start_row in number default 1,
		        p_end_row in number default null) is

l_agent 		varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
l_responsibility_id 	number := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
l_user_id 		number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
l_title       		varchar2(80);
l_prompts     		icx_util.g_prompts_table;
err_num 		number;
err_mesg 		varchar2(512);
temp_text 		varchar2(2000);
l_language 		varchar2(30);
l_result_row_table 	icx_util.char240_table;
l_total_rows		number;
l_end_row		number;
l_query_size		number;
l_where 		varchar2(2000);
/* Change wrto Bug Fix to implement the Bind Vars **/
  l_where_binds      ak_query_pkg.bind_tab;
  v_index            NUMBER;

l_order_by              varchar2(2000);
l_count 		number;
j			number;
temp_relation_item 	number;
temp_template		varchar2(240);
temp_related_template	varchar2(240);

begin
if icx_sec.validateSession then

   v_index := 1;


     icx_util.error_page_setup;
    l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    icx_util.getPrompts(601,'ICX_RELATED_TEMPLATES_DISP_R',l_title,l_prompts);

    htp.htmlOpen;
    htp.headOpen;
        icx_util.copyright;
        js.scriptOpen;

	    -- Javascript function to handle CD buttons
            htp.p('function rows(start_num, end_num) {
                document.Tail.p_start_row.value = start_num
                document.Tail.p_end_row.value = end_num
                document.Tail.submit()
                }');

	    -- javascript function to confirm delete of relationship
 	    FND_MESSAGE.Set_name('ICX','ICX_DELETE');
            htp.p('function delete_relation(template, related_template, html_template, html_related_template) {
              if (confirm("'||icx_util.replace_onMouseOver_quotes(FND_MESSAGE.Get)||': " + template + " - " + related_template)) {
                  open('''||l_agent||'/ICX_TEMPLATE_HEIRARCHY.template_delete?icx_template1='' + html_template + ''&icx_related_template='' + html_related_template,''tail'')
              }
            }');

        js.scriptClose;
    htp.headClose;

    htp.bodyOpen(icx_admin_sig.background);

    htp.formOpen(l_agent||'/icx_template_heirarchy.template_tail','POST','','','NAME="Tail"');

    htp.formHidden('p_template',p_template);
    htp.formHidden('p_start_row',p_start_row);
    htp.formHidden('p_end_row',p_end_row);


    -- check if p_template is valid
    select count(*) into l_count
    from po_reqexpress_headers
    where express_name = p_template;


    -- if p_template is valid perform object navigator query
    if l_count = 1 then

        -- Construct where clause
	-- l_where := 'EXPRESS_NAME = '''||p_template||'''';
        -- replace single quotes, bug 677606, aahmad-6/2/98
--        l_where := 'EXPRESS_NAME = '''||replace(p_template, '''', '''''')||'''';
        l_where := 'EXPRESS_NAME = :express_name_bin';

  l_where_binds(v_index).name := 'express_name_bin';
  l_where_binds(v_index).value := p_template;
  v_index := v_index + 1;

        -- Construct orderby clause
        l_order_by := 'RELATIONSHIP_TYPE DESC, RELATED_EXPRESS_NAME ASC';

        -- Look up the number of rows to display
        select QUERY_SET into l_query_size
        from ICX_PARAMETERS;

        -- figure end row value to display
        if p_end_row is null then
            l_end_row := l_query_size;
        else
            l_end_row := p_end_row;
        end if;

	-- Call to Object Navigator to execute query and return data
        -- as well as object and region structures

        ak_query_pkg.exec_query (
 	     P_PARENT_REGION_APPL_ID => 601			,
	     P_PARENT_REGION_CODE    => 'ICX_RELATED_TEMPLATES_DISP_R',
	     P_WHERE_CLAUSE  	     => l_where			,
             P_ORDER_BY_CLAUSE       => l_order_by              ,
	     P_RESPONSIBILITY_ID     => l_responsibility_id	,
	     P_USER_ID	             => l_user_id		,
	     P_RETURN_PARENTS	     => 'T'			,
	     P_RETURN_CHILDREN	     => 'F'			,
             P_RANGE_LOW             => p_start_row,
             P_RANGE_HIGH            => l_end_row,
            p_WHERE_BINDS      => l_where_binds);



        -- get number of total rows returned by lov to be used to
        -- determine if we need to display the next/previous buttons
        l_total_rows := ak_query_pkg.g_regions_table(0).total_result_count;


        -- check end row value
        if l_end_row > l_total_rows then
            l_end_row := l_total_rows;
        end if;


	-- display data and CD buttons if necessary
	j := 0;
	for i in 1..ak_query_pkg.g_results_table.COUNT loop
	    j := j + 1;

            -- If this is the first iteration of the loop then
	    -- display next/previous set buttons if list of values returns
	    -- more than the standard query size and also display
 	    -- the table header
            if j = 1 then
                if (l_total_rows > l_query_size) and not
		   (p_start_row = 1 and l_end_row = l_total_rows) then
		        icx_on_utilities2.displaySetIcons (
				P_LANGUAGE_CODE    => l_language,
				P_PACKPROC	   => 'JS',
			      	P_START_ROW	   => p_start_row,
				P_STOP_ROW	   => l_end_row,
				P_ENCRYPTED_WHERE  => '1',
				P_QUERY_SET	   => l_query_size,
				P_ROW_COUNT	   => l_total_rows,
		 		P_JSPROC	   => 'rows');

		end if;  -- CD Buttons


	        -- display table header
		htp.tableOpen('BORDER=1');
		htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER')||'">');
		for k in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
 		    if ak_query_pkg.g_items_table(k).secured_column = 'F' and
		       ak_query_pkg.g_items_table(k).node_display_flag = 'Y' then
		         htp.tableData(htf.strong(ak_query_pkg.g_items_table(k).attribute_label_long),'LEFT');
                    end if;
		end loop;
		htp.tableRowClose;

            end if;  -- CD Buttons and table header


 	    -- load data for current row into temp pl/sql table
	    icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(i-1), l_result_row_table);


	    -- display one row of data
	    htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'">');
	    for k in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
		if ak_query_pkg.g_items_table(k).secured_column = 'F' and
		   ak_query_pkg.g_items_table(k).node_display_flag = 'Y' then

		     if (ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_TEMPLATE' or
			 ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_TEMPLATE_DESC') then
			 for x in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
			     if ak_query_pkg.g_items_table(x).attribute_code = 'ICX_RELATION' then
			         temp_relation_item := x;
			     end if;
			 end loop;
		         -- dont display related category if relationship is TOP
			 if l_result_row_table(ak_query_pkg.g_items_table(temp_relation_item).value_id) = 'TOP' then
			     htp.tableData('<BR>');
			 else
                             htp.p(icx_on_utilities.formatData(icx_on_utilities.formatText(l_result_row_table(ak_query_pkg.g_items_table(k).value_id),
ak_query_pkg.g_items_table(k).bold,ak_query_pkg.g_items_table(k).italic),ak_query_pkg.g_items_table(k).horizontal_alignment,ak_query_pkg.g_items_table(k).vertical_alignment));
			 end if;
		     else
                         htp.p(icx_on_utilities.formatData(icx_on_utilities.formatText(l_result_row_table(ak_query_pkg.g_items_table(k).value_id),
ak_query_pkg.g_items_table(k).bold,ak_query_pkg.g_items_table(k).italic),ak_query_pkg.g_items_table(k).horizontal_alignment,ak_query_pkg.g_items_table(k).vertical_alignment));
		     end if;
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_TEMPLATE1' then
		    temp_template := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_TEMPLATE' then
		    temp_related_template := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

	    end loop;

            htp.tableData(htf.anchor('javascript:delete_relation('''||icx_util.replace_quotes(temp_template)||''','''||icx_util.replace_quotes(temp_related_template)||''',
'''||replace(icx_util.replace_quotes(temp_template),' ','@~$')||''','''||replace(icx_util.replace_quotes(temp_related_template),' ','@~$')||''')',
htf.img('/OA_MEDIA/'||l_language||'/FNDIDELR.gif','CENTER',icx_util.replace_alt_quotes(l_prompts(6)),'',
'BORDER=0 WIDTH=16 HEIGHT=17'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(6))||''';return true"'));

	    htp.tableRowClose;

	end loop;  -- Display data

        htp.tableClose;


	-- print button set if appropriate
        if (l_total_rows > l_query_size) and not
	   (p_start_row = 1 and l_end_row = l_total_rows) then
		 icx_on_utilities2.displaySetIcons (
			P_LANGUAGE_CODE    => l_language,
			P_PACKPROC	   => 'JS',
			P_START_ROW	   => p_start_row,
			P_STOP_ROW	   => l_end_row,
			P_ENCRYPTED_WHERE  => '1',
			P_QUERY_SET	   => l_query_size,
			P_ROW_COUNT	   => l_total_rows,
		 	P_JSPROC	   => 'rows');

        end if;


	-- display message if no rows were returned by query
        if j = 0 then
            fnd_message.set_name('ICX','ICX_TMP_NO_RELATION');
            fnd_message.set_token('TEMPLATE',p_template);
            htp.p('<H3>'||fnd_message.get||'</H3>');
        end if;


    else -- p_template is not valid
	if p_template is not null then
	    -- display message that category name is not valid
	    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
	    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',p_template);
	    htp.p('<H3>'||FND_MESSAGE.Get||'<H3>');
	end if;

    end if;


    htp.formClose;
    htp.bodyClose;
    htp.htmlClose;

end if;  -- ValidateSession

exception
  when others then
    err_num := SQLCODE;
    temp_text := SQLERRM;
    select substr(temp_text,12,512) into err_mesg from dual;
         fnd_message.set_name('ICX','ICX_ERROR');
         icx_util.add_error(err_mesg);
         icx_admin_sig.error_screen(l_title,l_language);

end template_tail;



procedure template_insert(icx_template1 in varchar2 default null,
		          icx_relation in varchar2 default null,
		          icx_related_template in varchar2 default null) is

l_return_status  varchar2(1) := 'S';
l_msg_count	 number;
l_msg_data	 varchar2(240);
l_user_id 	 number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);


begin
if icx_sec.validateSession then
    icx_util.error_page_setup;

    -- insert top relation for this category if needed
    if icx_relation = 'TOP' then

        ICX_Related_Templates_PUB.Insert_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_TRUE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_template		=> icx_template1		,
          p_related_template	=> icx_template1		,
          p_relationship_type	=> 'TOP'			,
          p_created_by		=> l_user_id
        );

    end if;


    -- insert child relation for this category if needed
    if l_return_status = 'S' and icx_related_template is not null then
        ICX_Related_Templates_PUB.Insert_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_FALSE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_template		=> icx_template1			,
          p_related_template	=> icx_related_template		,
          p_relationship_type	=> 'CHILD'			,
          p_created_by		=> l_user_id
        );

    end if;


    -- if API call did not succeed, then print errors with standard error page
    if l_return_status <> 'S' then

	icx_admin_sig.error_screen(null,null,l_msg_count,l_msg_data);

    else

        -- repaint header
        icx_template_heirarchy.template_head(icx_template1,'T');

    end if;


end if;  -- ValidateSession

end template_insert;



procedure template_delete(icx_template1 in varchar2 default null,
		          icx_related_template in varchar2 default null) is

l_return_status  varchar2(1) := 'S';
l_msg_count	 number;
l_msg_data	 varchar2(240);
l_user_id 	 number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
l_icx_template1  varchar2(240) := replace(icx_template1,'@~$',' ');
l_icx_related_template varchar2(240) := replace(icx_related_template,'@~$',' ');


begin
if icx_sec.validateSession then
    icx_util.error_page_setup;


    -- delete relation

        ICX_Related_Templates_PUB.Delete_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_TRUE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_template		=> l_icx_template1		,
          p_related_template	=> l_icx_related_template
        );


    -- if API call did not succeed, then print errors with standard error page
    if l_return_status <> 'S' then

	icx_admin_sig.error_screen(null,null,l_msg_count,l_msg_data);

    else

        -- repaint relationships
        icx_template_heirarchy.template_tail(l_icx_template1);

    end if;


end if;  -- ValidateSession

end template_delete;




end icx_template_heirarchy;

/
