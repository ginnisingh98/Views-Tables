--------------------------------------------------------
--  DDL for Package Body ICX_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT" as
/* $Header: ICXCATHB.pls 115.3 99/07/17 03:15:41 porting ship $ */



procedure main is

l_title       varchar2(80);
l_prompts     icx_util.g_prompts_table;

begin
if icx_sec.validateSession then
    icx_util.getPrompts(601,'ICX_RELATED_CATEGORIES_R',l_title,l_prompts);

    htp.htmlOpen;
    htp.headOpen;
        icx_util.copyright;
        htp.title(l_title);
    htp.headClose;

    htp.p('<FRAMESET rows="285,*">
	       <FRAME name="header" src="ICX_CAT.cat_head">
	       <FRAME name="tail" src="ICX_CAT.cat_tail">
	   </FRAMESET>');


    htp.p('<NOFRAMESET>');
	  FND_MESSAGE.SET_NAME('ICX','ICX_BROWSER');
          htp.p(FND_MESSAGE.Get);
    htp.p('</NOFRAMESET>');
htp.p('in Main');
    htp.htmlClose;
end if;  -- validateSession

end main;




procedure cat_head(p_category_set_id in varchar2 default null,
   		   p_category_id in varchar2 default null,
		   p_category in varchar2 default null,
		   p_query_flag in varchar2 default 'F') is

cursor category_sets is
select category_set_id,
       category_set_name
from   icx_category_set_lov;

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
temp_cat_set_id number;
temp_cat_set varchar2(30);
temp_relation_code varchar2(30);
temp_relation varchar2(80);

begin
if icx_sec.validateSession then
    icx_util.error_page_setup;
    l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    icx_util.getPrompts(601,'ICX_RELATED_CATEGORIES_R',l_title,l_prompts);
    icx_util.getPrompts(178,'ICX_LOV',lov_title,lov_prompts);

    htp.htmlOpen;
    htp.headOpen;
        icx_util.copyright;

        htp.title(l_title);

        js.scriptOpen;
            icx_admin_sig.help_win_script('/OA_HTML/'||l_language||'/ICXHLMCH.htm');
            icx_util.LOVScript;
	    js.null_alert;
	    js.equal_alert;

	    htp.p('function autoquery() {
		parent.tail.document.Tail.p_category_set_id.value = document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
		parent.tail.document.Tail.p_category_id.value = document.Category.ICX_CATEGORY_ID.value
		parent.tail.document.Tail.p_category_name.value = document.Category.ICX_CATEGORY.value
		parent.tail.document.Tail.submit()
	    }');

	    htp.p('function set_changed() {
		document.Category.ICX_CATEGORY_ID.value = ""
		document.Category.ICX_CATEGORY.value = ""
		document.Category.ICX_RELATED_CATEGORY_ID.value = ""
		document.Category.ICX_RELATED_CATEGORY.value = ""
                parent.tail.document.Tail.p_category_set_id.value = document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
                parent.tail.document.Tail.p_category_id.value = ""
                parent.tail.document.Tail.p_category_name.value = ""
                parent.tail.document.Tail.submit()
	    }');

	    htp.p('function cat_changed() {
		document.Category.ICX_CATEGORY_ID.value = ""
		parent.tail.document.Tail.p_category_set_id.value = document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
		parent.tail.document.Tail.p_category_id.value = ""
		parent.tail.document.Tail.p_category_name.value = document.Category.ICX_CATEGORY.value
		parent.tail.document.Tail.submit()
	    }');

	    htp.p('function pre_cat_LOV() {
		var l_where = "CATEGORY_SET_ID=" + document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
	        LOV(''178'',''ICX_CATEGORY'',''601'',''ICX_RELATED_CATEGORIES_R'',''Category'',''header'','''',l_where)
	    }');

	    htp.p('function post_cat_LOV(cat_id, cat_name) {
		parent.tail.document.Tail.p_category_set_id.value = document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
		parent.tail.document.Tail.p_category_id.value = cat_id
		parent.tail.document.Tail.p_category_name.value = cat_name
		parent.tail.document.Tail.submit()
	    }');

	    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_BEFORE');
	    htp.p('function pre_rel_cat_LOV() {
		if (!null_alert(document.Category.ICX_CATEGORY.value,"'||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
                  var l_where = "CATEGORY_SET_ID=" + document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value
	          LOV(''178'',''ICX_RELATED_CATEGORY'',''601'',''ICX_RELATED_CATEGORIES_R'',''Category'',''header'','''',l_where)
		}
	    }');
            -- remove manual where clause for now because html can not deal
            -- with the spaces in the category name
	    -- var l_where = "CATEGORY_SET_ID=" + document.Category.ICX_CATEGORY_SET_ID.options[document.Category.ICX_CATEGORY_SET_ID.selectedIndex].value + "^@~^and^@~^CONCATENATED_SEGMENTS<>''" + document.Category.ICX_CATEGORY.value + "''"


	    FND_MESSAGE.SET_NAME('ICX','ICX_NOT_NULL');
	    htp.p('function cat_submit() {
		if (!null_alert(document.Category.ICX_CATEGORY.value,"'||icx_util.replace_quotes(l_prompts(4))||' '||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
		  if (document.Category.ICX_RELATION.options[document.Category.ICX_RELATION.selectedIndex].value != "TOP") {');
	    FND_MESSAGE.SET_NAME('ICX','ICX_NOT_NULL');
	    htp.p('   if (!null_alert(document.Category.ICX_RELATED_CATEGORY.value,"'||icx_util.replace_quotes(l_prompts(7))||' '||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {');
	    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_PARENT');
	    htp.p('      if (!equal_alert(document.Category.ICX_CATEGORY.value,document.Category.ICX_RELATED_CATEGORY.value,"'||icx_util.replace_quotes(FND_MESSAGE.Get)||'")) {
		        document.Category.submit()
		      }
		    }
		  } else {
		    document.Category.submit()
		  }
		}
	    }');

        js.scriptClose;
    htp.headClose;
    htp.bodyOpen(icx_admin_sig.background);
    icx_admin_sig.toolbar(language_code => l_language);

    htp.formOpen(l_agent||'/icx_cat.cat_insert','POST','','','NAME="Category"');

    htp.tableOpen;
    htp.tableRowOpen;
      htp.tableData('<H2>'||l_title||'</H2>');
    htp.tableRowClose;
    htp.tableClose;

    htp.tableOpen;

    -- Category Set poplist
    htp.tableRowOpen;
      htp.tableData(l_prompts(2),'RIGHT');
      htp.p('<TD>'||htf.formSelectOpen('ICX_CATEGORY_SET_ID','','','onchange="set_changed()"'));
        open category_sets;
	loop
	    fetch category_sets into temp_cat_set_id, temp_cat_set;
	    exit when category_sets%NOTFOUND;
	    if temp_cat_set_id = p_category_set_id then
	        htp.formSelectOption(temp_cat_set,'SELECTED','VALUE="'||temp_cat_set_id||'"');
	    else
	        htp.formSelectOption(temp_cat_set,'','VALUE="'||temp_cat_set_id||'"');
	    end if;
	end loop;
        close category_sets;
      htp.p(htf.formSelectClose||'</TD>');

    -- Category text field
    htp.formHidden('ICX_CATEGORY_ID',p_category_id);
      htp.tableData(l_prompts(4),'RIGHT');
        htp.tableData(htf.formText('ICX_CATEGORY',30,81,p_category,'onchange="cat_changed()"'));
          htp.tableData(htf.anchor('javascript:pre_cat_LOV()',htf.img('/OA_MEDIA/'||l_language||'/FNDILOV.gif','CENTER',icx_util.replace_alt_quotes(lov_title),'','BORDER=0 WIDTH=23 HEIGHT=21'),'','onMouseOver="window.status='''||
icx_util.replace_onMouseOver_quotes(lov_title)||''';return true"'));
    htp.tableRowClose;

    -- Relation poplist
    htp.tableRowOpen;
      htp.tableData(l_prompts(5),'RIGHT');
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
    htp.formHidden('ICX_RELATED_CATEGORY_ID');
      htp.tableData(l_prompts(7),'RIGHT');
        htp.tableData(htf.formText('ICX_RELATED_CATEGORY',30,81,'','onchange="document.Category.ICX_RELATED_CATEGORY_ID.value = ''''"'));
          htp.tableData(htf.anchor('javascript:pre_rel_cat_LOV()',htf.img('/OA_MEDIA/'||l_language||
'/FNDILOV.gif','CENTER',icx_util.replace_alt_quotes(lov_title),'','BORDER=0 WIDTH=23 HEIGHT=21'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(lov_title)||''';return true"'));
    htp.tableRowClose;
    htp.tableClose;


    -- Write submit and clear buttons
    htp.tableOpen;
    htp.tableRowOpen;
      icx_util.DynamicButton(l_prompts(8),'FNDBSBMT.gif',l_prompts(8),'javascript:cat_submit()',l_language,FALSE);
        if (instr(c_browser, 'MSIE') = 0) then
            icx_util.DynamicButton(l_prompts(9),'FNDBCLR.gif',l_prompts(9),'javascript:document.Category.reset()',l_language,FALSE);
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

end;  -- cat_head




procedure cat_tail(p_category_set_id in varchar2 default null,
		   p_category_id in varchar2 default null,
		   p_category_name in varchar2 default null,
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
l_order_by              varchar2(2000);
l_count 		number;
j			number;
temp_cat_set_id		number;
temp_cat_id		number;
temp_related_cat_id	number;
temp_cat		varchar2(240);
temp_related_cat	varchar2(240);
temp_relation_item	number;

begin
if icx_sec.validateSession then
    icx_util.error_page_setup;
    l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    icx_util.getPrompts(601,'ICX_RELATED_CATEGORIES_DISP_R',l_title,l_prompts);

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
            htp.p('function delete_relation(cat, related_cat, cat_set_id, cat_id, related_cat_id) {
              if (confirm("'||icx_util.replace_quotes(FND_MESSAGE.Get)||': " + cat + " - " + related_cat)) {
                  open('''||l_agent||'/ICX_CAT.cat_delete?icx_category_set_id='' + cat_set_id + ''&icx_category_id='' + cat_id + ''&icx_related_category_id='' + related_cat_id,''tail'')
              }
            }');

        js.scriptClose;
    htp.headClose;

    htp.bodyOpen(icx_admin_sig.background);

    htp.formOpen(l_agent||'/icx_cat.cat_tail','POST','','','NAME="Tail"');

    htp.formHidden('p_category_set_id',p_category_set_id);
    htp.formHidden('p_category_id',p_category_id);
    htp.formHidden('p_category_name',p_category_name);
    htp.formHidden('p_start_row',p_start_row);
    htp.formHidden('p_end_row',p_end_row);


    -- if p_category_id is null then check that p_category_name is valid
    if p_category_id is null then

	select count(*) into l_count
   	from   mtl_categories_kfv mck,
               mtl_category_sets mcs
	where  (mcs.validate_flag = 'Y' and
	        mck.category_id in (
          	    select mcsv.category_id
                    from   mtl_category_set_valid_cats mcsv
            	    where  mcsv.category_set_id = p_category_set_id) and
		mck.concatenated_segments = p_category_name)
	or     (mcs.validate_flag <> 'Y' and
	        mcs.structure_id = mck.structure_id and
	        mck.concatenated_segments = p_category_name);

    else

	l_count := 1;

    end if;


    -- if p_category_id is not null or p_category_name is valid then
    -- perform object navigator query, otherwise display error message

    if l_count <> 0 then

        -- Construct where clause
        if p_category_id is not null then
	    l_where := 'CATEGORY_SET_ID = '||p_category_set_id||' and CATEGORY_ID = '||p_category_id;
        else
	    l_where := 'CATEGORY_SET_ID = '||p_category_set_id||' and CATEGORY_NAME = '''||p_category_name||'''';
        end if;

        -- Construct orderby clause
        l_order_by := 'RELATIONSHIP_TYPE DESC, RELATED_CATEGORY_NAME ASC';

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
	     P_PARENT_REGION_CODE    => 'ICX_RELATED_CATEGORIES_DISP_R',
             P_ORDER_BY_CLAUSE       => l_order_by              ,
	     P_WHERE_CLAUSE  	     => l_where			,
	     P_RESPONSIBILITY_ID     => l_responsibility_id	,
	     P_USER_ID	             => l_user_id		,
	     P_RETURN_PARENTS	     => 'T'			,
	     P_RETURN_CHILDREN	     => 'F'			,
             P_RANGE_LOW             => p_start_row,
             P_RANGE_HIGH            => l_end_row);



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

		     if (ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_CATEGORY' or
			 ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_CATEGORY_DESC') then
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

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_CATEGORY' then
		    temp_cat := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_CATEGORY' then
		    temp_related_cat := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_CATEGORY_SET_ID' then
		    temp_cat_set_id := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_CATEGORY_ID' then
		    temp_cat_id := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

		if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_RELATED_CATEGORY_ID' then
		    temp_related_cat_id := l_result_row_table(ak_query_pkg.g_items_table(k).value_id);
		end if;

	    end loop;
            htp.tableData(htf.anchor('javascript:delete_relation('''||icx_util.replace_quotes(temp_cat)||''','''||icx_util.replace_quotes(temp_related_cat)||''','''||temp_cat_set_id||''','''||temp_cat_id||''','''||temp_related_cat_id||
''')',htf.img('/OA_MEDIA/'||l_language||'/FNDIDELR.gif','CENTER',icx_util.replace_alt_quotes(l_prompts(6)),'','BORDER=0 WIDTH=16 HEIGHT=17'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_prompts(6))||
''';return true"'));

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
            fnd_message.set_name('ICX','ICX_CAT_NO_RELATION');
            fnd_message.set_token('CATEGORY',p_category_name);
            htp.p('<H3>'||fnd_message.get||'</H3>');
        end if;

    else

        if p_category_id is not null or p_category_name is not null then
	    -- display message that category name is not valid
	    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
	    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',p_category_name);
	    htp.p('<H3>'||FND_MESSAGE.Get||'<H3>');
	end if;

    end if;  -- l_count = 1


    htp.formClose;
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

end cat_tail;



procedure cat_insert(icx_category_set_id in varchar2 default null,
		     icx_category_id in varchar2 default null,
		     icx_category in varchar2 default null,
		     icx_relation in varchar2 default null,
		     icx_related_category_id in varchar2 default null,
		     icx_related_category in varchar2 default null) is

l_return_status  varchar2(1) := 'S';
l_msg_count	 number;
l_msg_data	 varchar2(240);
l_user_id 	 number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);


begin
if icx_sec.validateSession then
    icx_util.error_page_setup;

    -- insert top relation for this category if needed
    if icx_relation = 'TOP' then

        ICX_Related_Categories_PUB.Insert_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_TRUE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_category_set_id	=> icx_category_set_id		,
          p_category_id		=> icx_category_id		,
          p_category		=> icx_category			,
          p_related_category_id	=> icx_category_id		,
          p_related_category	=> icx_category			,
          p_relationship_type	=> 'TOP'			,
          p_created_by		=> l_user_id
        );

    end if;


    -- insert child relation for this category if needed
    if l_return_status = 'S' and icx_related_category is not null then
        ICX_Related_Categories_PUB.Insert_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_FALSE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_category_set_id	=> icx_category_set_id		,
          p_category_id		=> icx_category_id		,
          p_category		=> icx_category			,
          p_related_category_id	=> icx_related_category_id	,
          p_related_category	=> icx_related_category		,
          p_relationship_type	=> 'CHILD'			,
          p_created_by		=> l_user_id
        );

    end if;


    -- if API call did not succeed, then print errors with standard error page
    if l_return_status <> 'S' then

	icx_admin_sig.error_screen(null,null,l_msg_count,l_msg_data);

    else

        -- repaint header
        icx_cat.cat_head(icx_category_set_id, icx_category_id, icx_category, 'T');

    end if;


end if;  -- ValidateSession

end cat_insert;




procedure cat_delete(icx_category_set_id in varchar2 default null,
		     icx_category_id in varchar2 default null,
		     icx_related_category_id in varchar2 default null) is

cursor category_name is
    select CONCATENATED_SEGMENTS
    from icx_category_lov
    where category_id = icx_category_id;

l_return_status  varchar2(1) := 'S';
l_msg_count	 number;
l_msg_data	 varchar2(240);
l_user_id 	 number := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
l_category	 varchar2(245);


begin
if icx_sec.validateSession then
    icx_util.error_page_setup;


    -- delete relation

        ICX_Related_Categories_PUB.Delete_Relation
        ( p_api_version_number 	=> 1.0				,
          p_init_msg_list	=> FND_API.G_TRUE		,
          p_simulate		=> FND_API.G_FALSE 		,
          p_commit		=> FND_API.G_TRUE		,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL	,
          p_return_status	=> l_return_status		,
          p_msg_count		=> l_msg_count			,
          p_msg_data		=> l_msg_data			,
          p_category_set_id	=> icx_category_set_id		,
          p_category_id		=> icx_category_id		,
          p_related_category_id	=> icx_related_category_id
        );


    -- if API call did not succeed, then print errors with standard error page
    if l_return_status <> 'S' then

	icx_admin_sig.error_screen(null,null,l_msg_count,l_msg_data);

    else

        -- repaint relationships
	open category_name;
	  fetch category_name into l_category;
	close category_name;
        icx_cat.cat_tail(icx_category_set_id, icx_category_id,l_category);

    end if;


end if;  -- ValidateSession

end cat_delete;




end icx_cat;

/
