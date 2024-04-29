--------------------------------------------------------
--  DDL for Package Body ICX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_UTIL" as
/* $Header: ICXUTILB.pls 120.0 2005/10/07 12:21:06 gjimenez noship $ */

--  The following is used as storage unit for creating the standard error page
--  for all of web apps. It uses a PL/SQL table to store all the error columns.
--  It then wil return a formated error page to the user.
--  The TYPE definition for the PL/SQL table
TYPE char2000table IS TABLE OF VARCHAR2(2000)
        INDEX BY BINARY_INTEGER;
-- An empty table to use during the reset of the table
empty_char2000table char2000table;
-- Define the table and a counter for it
error_table char2000table;
TOTAL_ERRORS BINARY_INTEGER := 0;



-- Global variables for the LOV
-- These variable are global to prevent the overhead of passing large
-- table, and the fact that strings can not be passed via html
-- LOV Region variables
g_LOV_region_id number;
g_LOV_region varchar2(30);



-- first call from login page to create frameset with configurable
-- homepage in the top, main frame and a bottom, hidden frame where
-- utilities can be preloaded.

/* No longer used
procedure oracle(i_1 in varchar2,
                 i_2 in varchar2,
                 agent in varchar2,
                 dbHost in varchar2) is
begin

htp.p('<FRAMESET rows="*,1" BORDER="0">
               <FRAME name="main" src="/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?i_1='||i_1||'&i_2='||i_2||'&agent='||agent||'&dbHost='||dbHost||'" NORESIZE>
               <FRAME name="tail" src="'||agent||'icx_util.preload" NORESIZE SCROLLING="NO">
           </FRAMESET>');


end;
*/

/* No longer used
-- loads the lov applet and possibly other utilities in a hidden frame
-- on login to the configurable home page.

procedure preload is

begin
  htp.p('<form>');
  htp.p('<input type="hidden" name="PRELOAD" value="">');

  wf_lov.lovapplet(doc_name=>'PRELOAD',
                   column_names=>NULL,
                   query_params=>null,
                   query_plsql=>'icx_util.preload_query',
                   longlist=>'Y',
                   width=>'1',
                   height=>'1');

  htp.p('</form>');

end;

-- returns dummy values to a lov during preload of the applet
procedure preload_query(p_titles_only in varchar2,
                        p_find_criteria in varchar2) is
begin
  htp.p('TEST LOV');
  htp.p('1');  -- columns
  htp.p('1');  -- rows
  htp.p('X');  -- header
  htp.p('100');  -- header size
  if p_titles_only <> 'Y' then
    htp.p('X');
  end if;
end;
*/

-- Used to write the LOV javascript function into html pages
-- that utilize web lov functionality

procedure LOVScript is

c_amp varchar2(1) := '&';
c_agent varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');
l_user_id varchar2(100);
l_lov_type varchar2(100) := 'HTML';
l_profile_defined boolean;

begin
if icx_sec.validateSession then

  l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);

  fnd_profile.get_specific(name_z     => 'ICX_LOV_TYPE',
                           user_id_z  => l_user_id,
                           val_z      => l_lov_type,
                           defined_z  => l_profile_defined);

  if not l_profile_defined then
    l_lov_type := 'HTML';
  end if;

  if l_lov_type = 'JAVA' then
    -- Java LOV

    -- call wf_lov package for most of the modal lov window javascript
    wf_lov.OpenLovWinHtml('N');

--    htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

    htp.p('// additional code for OSSWA modal lov');
    htp.p('function LOV(c_attribute_app_id, c_attribute_code, c_region_app_id, c_region_code, c_form_name, c_frame_name, c_where_clause,c_js_where_clause) {
        FNDLOVwindow.win = window.open("'||c_agent||'/icx_util.LOV?c_attribute_app_id=" + c_attribute_app_id + "'||c_amp||'c_attribute_code=" + c_attribute_code + "'||c_amp||'c_region_app_id=" + c_region_app_id + "'
	||c_amp||'c_region_code=" + c_region_code + "'||c_amp||'c_form_name=" + c_form_name + "'||c_amp||'c_frame_name=" + c_frame_name  + "'||c_amp||'c_where_clause=" + c_where_clause + "'
	||c_amp||'c_js_where_clause=" + c_js_where_clause,"LOV","resizable=yes,menubar=yes,scrollbars=yes,toolbar=no,width=780,height=300");');

    htp.p('FNDLOVwindow.win.focus()');
    htp.p('FNDLOVwindow.open =true');

    if (instr(c_browser, 'MSIE') = 0) then
       htp.p('FNDLOVwindow.win.opener = self;');
    end if;

    htp.p('}
     // end OSSWA modal lov code');

  else
    -- html LOV
    htp.p('function LOV(c_attribute_app_id, c_attribute_code, c_region_app_id, c_region_code, c_form_name, c_frame_name, c_where_clause,c_js_where_clause) {
        lov_win = window.open("'||c_agent||'/icx_util.LOV?c_attribute_app_id=" + c_attribute_app_id + "'||c_amp||'c_attribute_code=" + c_attribute_code + "'||c_amp||'c_region_app_id=" + c_region_app_id + "'
	||c_amp||'c_region_code=" + c_region_code + "'||c_amp||'c_form_name=" + c_form_name + "'||c_amp||'c_frame_name=" + c_frame_name  + "'||c_amp||'c_where_clause=" + c_where_clause + "'
	||c_amp||'c_js_where_clause=" + c_js_where_clause,"LOV","resizable=yes,menubar=yes,scrollbars=yes,width=780,height=300");');
    if (instr(c_browser, 'MSIE') = 0) then
       htp.p(' lov_win.opener = self;');
    end if;
    htp.p('}');
  end if;

end if;
end;



-- Used to write the LOV button onto html pages
-- that utilize web lov functionality

function LOVButton (c_attribute_app_id in number,
                    c_attribute_code in varchar2,
                    c_region_app_id in number,
                    c_region_code in varchar2,
                    c_form_name in varchar2,
                    c_frame_name in varchar2,
                    c_where_clause in varchar2,
		    c_image_align in varchar2)
                    return varchar2  is

temp varchar2(2000);
--c_language varchar2(30);
c_title 	varchar2(80);
c_prompts	g_prompts_table;
l_where_clause varchar2(2000);

begin
    /* remove the following commented line if the oa media stuff works fine*/
    -- c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    getPrompts(601,'ICX_LOV',c_title,c_prompts);
    l_where_clause := icx_call.encrypt2(c_where_clause);
    temp := htf.anchor('javascript:LOV('''||c_attribute_app_id||''','''||c_attribute_code||''','''||c_region_app_id||''','''||c_region_code||''','''||c_form_name||''','''||c_frame_name||''','''||l_where_clause||''','''')',
	htf.img('/OA_MEDIA/FNDILOV.gif',c_image_align,icx_util.replace_alt_quotes(c_title),'','BORDER=0 WIDTH=23 HEIGHT=21'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_title)||''';return true"');
    return temp;
end;


-- Base procedure that calls LOVHeader and LOVValues in seperate frames
-- to produce the web lov functionality

procedure LOV (c_attribute_app_id in number,
               c_attribute_code in varchar2,
               c_region_app_id in number,
               c_region_code in varchar2,
               c_form_name in varchar2,
               c_frame_name in varchar2,
	       c_where_clause in varchar2,
	       c_js_where_clause in varchar2) IS


type lov_out_table is table of number
        index by binary_integer;

cursor lov_out_attributes (lov_reg in varchar2, lov_reg_id in number, lov_f_key_name in varchar2) is
        select decode(ari1.ATTRIBUTE_CODE,null,'NULL',ari1.ATTRIBUTE_CODE),
                ari2.DISPLAY_SEQUENCE
        from    AK_REGION_ITEMS_VL ari1, AK_REGION_ITEMS_VL ari2
	where   ari1.REGION_APPLICATION_ID(+) = c_region_app_id
	and 	ari1.REGION_CODE(+) = c_region_code
	and 	ari1.LOV_REGION_APPLICATION_ID(+) = lov_reg_id
 	and	ari1.LOV_REGION_CODE(+) = lov_reg
	and 	ari1.LOV_FOREIGN_KEY_NAME(+) = lov_f_key_name
        and     (ari1.REGION_DEFAULTING_API_PKG is null
                 or ari1.REGION_DEFAULTING_API_PKG <> 'JS')
        and 	ari2.REGION_APPLICATION_ID = lov_reg_id
 	and	ari2.REGION_CODE = lov_reg
        and     ari2.ATTRIBUTE_CODE = ari1.LOV_ATTRIBUTE_CODE(+)
	order by ari2.DISPLAY_SEQUENCE;

cursor js_out_attributes (lov_reg in varchar2, lov_reg_id in number, lov_f_key_name in varchar2) is
	select  ari1.REGION_DEFAULTING_API_PROC, ari2.DISPLAY_SEQUENCE
        from    AK_REGION_ITEMS_VL ari1, AK_REGION_ITEMS_VL ari2
	where   ari1.REGION_APPLICATION_ID = c_region_app_id
	and 	ari1.REGION_CODE = c_region_code
	and 	ari1.LOV_REGION_APPLICATION_ID = lov_reg_id
 	and	ari1.LOV_REGION_CODE	= lov_reg
	and 	ari1.LOV_FOREIGN_KEY_NAME = lov_f_key_name
	and     ari1.REGION_DEFAULTING_API_PROC is not null
        and 	ari2.REGION_APPLICATION_ID = lov_reg_id
 	and	ari2.REGION_CODE	= lov_reg
        and     ari2.ATTRIBUTE_CODE = ari1.LOV_ATTRIBUTE_CODE
	order by ari1.DISPLAY_SEQUENCE;


c_agent varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
c_amp varchar2(1) := '&';
i 			number;
j                       number;
err_num 	        number;
err_mesg 	        varchar2(512);
temp_text	        varchar2(2000);
temp_message 	        varchar2(2000);
LOV_title               varchar2(80);
temp_LOV_region_id      number;
temp_LOV_region         varchar2(30);
temp_LOV_foreign_key_name varchar2(30);
l_where_clause          varchar2(2000);
base_region_attr 	varchar2(30);
LOV_region_attr 	varchar2(30);
disp_sequence           number;
l_js_proc_name 		varchar2(30);
l_callback_name         varchar2(256);
l_callback_columns 	varchar2(2000);
l_num_region_items      number;
l_col_num               number;
l_col_found             boolean;
out_columns 	        varchar2(2000);
l_doc_name  		varchar2(2000);
l_lov_out_table         lov_out_table;
l_init_find             varchar2(2000);
l_lov_type 		varchar2(100) := 'HTML';
l_user_id               varchar2(100);
l_profile_defined       boolean;

begin
if icx_sec.validateSession then

  select attribute_label_long into LOV_title
  from ak_region_items_vl
  where region_application_id = c_region_app_id
  and region_code = c_region_code
  and attribute_application_id = c_attribute_app_id
  and attribute_code = c_attribute_code;

  -- Look up the LOV region being called
  select LOV_FOREIGN_KEY_NAME, LOV_REGION_APPLICATION_ID, LOV_REGION_CODE
  into  temp_LOV_foreign_key_name, temp_LOV_region_id, temp_LOV_region
  from  AK_REGION_ITEMS
  where REGION_APPLICATION_ID = c_region_app_id
  and   REGION_CODE = c_region_code
  and   ATTRIBUTE_APPLICATION_ID = c_attribute_app_id
  and   ATTRIBUTE_CODE = c_attribute_code;

  g_LOV_region_id := temp_LOV_region_id;
  g_LOV_region := temp_LOV_region;


  -- Combine two where clauses
  if c_where_clause is not null then
    if c_js_where_clause is not null then
      l_where_clause := icx_call.encrypt2(icx_call.decrypt2(c_where_clause)||' and '||replace(c_js_where_clause,'^@~^',' '));
    else
      l_where_clause := c_where_clause;
    end if;
  else
    if c_js_where_clause is not null then
      l_where_clause := icx_call.encrypt2(replace(c_js_where_clause,'^@~^',' '));
    end if;
  end if;

  l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);

  fnd_profile.get_specific(name_z     => 'ICX_LOV_TYPE',
                           user_id_z  => l_user_id,
                           val_z      => l_lov_type,
                           defined_z  => l_profile_defined);

  if not l_profile_defined then
    l_lov_type := 'HTML';
  end if;

  if l_lov_type = 'JAVA' then
    -- java LOV

    -- construct doc and initial-field names
    if c_frame_name is not null then
      l_doc_name := 'parent.opener.parent.'||c_frame_name||'.document.'||c_form_name;
      l_init_find := 'parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||c_attribute_code||'.value';
    else
      l_doc_name := 'parent.opener.parent.document.'||c_form_name;
      l_init_find := 'parent.opener.parent.document.'||c_form_name||'.'||c_attribute_code||'.value';
    end if;


    -- get out column names
    i := 0;
    open lov_out_attributes(temp_LOV_region, temp_LOV_region_id, temp_LOV_foreign_key_name);
    loop
      fetch lov_out_attributes into base_region_attr, disp_sequence;
      exit when lov_out_attributes%NOTFOUND;
      l_lov_out_table(i) := disp_sequence;
      if (i = 0) then
        out_columns := base_region_attr;
      else
        out_columns := out_columns||','||base_region_attr;
      end if;
      i := i + 1;
    end loop;
    close lov_out_attributes;


    -- get out javascript procedure name and columns
    i := 0;
    open js_out_attributes(temp_LOV_region, temp_LOV_region_id, temp_LOV_foreign_key_name);
    loop
      fetch js_out_attributes into l_js_proc_name, disp_sequence;
      exit when js_out_attributes%NOTFOUND;
      l_col_found := false;
      for j in l_lov_out_table.FIRST..l_lov_out_table.LAST loop
        if l_lov_out_table(j) = disp_sequence then
          l_col_num := j;
          l_col_found := true;
          exit;
        end if;
      end loop;
      if (i=0) then
        if c_frame_name is not null then
          l_callback_name := 'parent.opener.parent.'||c_frame_name||'.'||l_js_proc_name;
        else
          l_callback_name := 'parent.opener.parent.'||l_js_proc_name;
        end if;
        if (l_col_found) then
          l_callback_columns := l_col_num;
        end if;
      else
        if (l_col_found) then
          l_callback_columns := l_callback_columns||','||l_col_num;
        end if;
      end if;
      i := i + 1;
    end loop;
    close js_out_attributes;


    -- call wf procedure to create lov page with applet
    wf_lov.lovapplet(doc_name         => l_doc_name,
                     column_names     => out_columns,
                     query_params     => 'p_LOV_region_id='||temp_LOV_region_id||'&p_LOV_region='||temp_LOV_region||'&p_where_clause='||l_where_clause,
                     query_plsql      => 'icx_util.icx_ak_lov',
                     callback         => l_callback_name,
                     callback_params  => l_callback_columns,
                     longlist         => 'Y',
                     initial_find     => l_init_find,
                     width            => '550',
                     height           => '200',
                     window_title     => LOV_title);

  else
    -- html LOV

    htp.htmlOpen;

    htp.headOpen;
        icx_util.copyright;
        htp.title(LOV_title);
    htp.headClose;
    htp.p('<FRAMESET rows="70,*">
               <FRAME name="LOVHeader" src="ICX_UTIL.LOVHeader?c_attribute_code='||c_attribute_code||c_amp||'p_LOV_foreign_key_name='||temp_LOV_foreign_key_name
		||c_amp||'p_LOV_region_id='||temp_LOV_region_id||c_amp||'p_LOV_region='||temp_LOV_region||c_amp||'c_form_name='||c_form_name||c_amp||'c_frame_name='||c_frame_name||'" >
               <FRAME name="LOVValues" src="ICX_UTIL.LOVValues?p_LOV_foreign_key_name='||temp_LOV_foreign_key_name||c_amp||'p_LOV_region_id='||temp_LOV_region_id||c_amp||'p_LOV_region='||temp_LOV_region||
		c_amp||'p_attribute_app_id='||c_attribute_app_id||c_amp||'p_attribute_code='||c_attribute_code||c_amp||'p_region_app_id='||c_region_app_id||c_amp||'p_region_code='||c_region_code||
		c_amp||'c_form_name='||c_form_name||c_amp||'c_frame_name='||c_frame_name||c_amp||'c_where_clause='||l_where_clause||'">
           </FRAMESET>');


    htp.p('<NOFRAMESET>');
          htp.p('A browser supporting Frames and JavaScript is required.');
    htp.p('</NOFRAMESET>');

    htp.htmlClose;

  end if;

end if;  -- validateSession

exception
  when no_data_found then
         fnd_message.set_name('ICX','ICX_LOV_IS_NOT_DEFINED');
         icx_util.add_error(fnd_message.get);
         icx_util.error_page_print;

  when others then
    err_num := SQLCODE;
    temp_text := SQLERRM;
    select substr(temp_text,12,512) into err_mesg from dual;
         temp_message := err_mesg;
         icx_util.add_error(temp_message);
         icx_util.error_page_print;

end;

procedure ICX_AK_LOV(p_titles_only in varchar2,
                     p_find_criteria in varchar2,
                     p_LOV_region_id in varchar2,
                     p_LOV_region in varchar2,
                     p_where_clause in varchar2) is

cursor lov_query_columns  is
        select	d.COLUMN_NAME
        from    AK_ATTRIBUTES a,
		AK_REGION_ITEMS_VL b,
		AK_REGIONS c,
		AK_OBJECT_ATTRIBUTES d
        where	b.REGION_APPLICATION_ID = p_LOV_region_id
        and	b.REGION_CODE = p_LOV_region
        and	b.NODE_QUERY_FLAG = 'Y'
        and	b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and	b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
	and	b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
	and	b.REGION_CODE = c.REGION_CODE
	and	c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
	and	d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
	and 	d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
        order by b.DISPLAY_SEQUENCE;


LOV_title       	varchar2(80);
l_find_column           varchar2(200);
l_where_clause          varchar2(2000);
l_find_where_clause     varchar2(2000);
l_order_by_clause       varchar2(2000);
l_responsibility_id 	number;
l_user_id 		number;
i                       number;
j                       number;
l_total_width           number;
l_result_row_table 	icx_util.char240_table;
l_sess_id 		number := icx_sec.getID(icx_sec.PV_SESSION_ID);

begin
  if icx_sec.validateSession then

    l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
    l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

    -- get LOV window title
    LOV_title := icx_util.getPrompt(601,'ICX_LOV',178,'ICX_LIST_OF_VALUES');
    htp.p(LOV_title);


    -- combine where clause from form and find criteria
    open lov_query_columns;
        fetch lov_query_columns into l_find_column;
    close lov_query_columns;

    if p_find_criteria is not null then
      l_find_where_clause := 'UPPER('||l_find_column||') like '''||
        UPPER(p_find_criteria)||'%'' and ('||
        l_find_column||' like '''||LOWER(SUBSTR(p_find_criteria,1,2))||'%'' or '||
        l_find_column||' like '''||LOWER(SUBSTR(p_find_criteria, 1, 1))||UPPER(SUBSTR(p_find_criteria, 2, 1))||'%'' or '||
        l_find_column||' like '''||INITCAP(SUBSTR(p_find_criteria, 1, 2))||'%'' or '||
        l_find_column||' like '''||UPPER(SUBSTR(p_find_criteria, 1, 2))||'%'')';


      if p_where_clause is not null then
        l_where_clause := l_find_where_clause||' and '||icx_call.decrypt2(p_where_clause);
      else
        l_where_clause := l_find_where_clause;
      end if;
    else
      if p_where_clause is not null then
        l_where_clause := icx_call.decrypt2(p_where_clause);
      end if;
--htp.p(l_where_clause||'-'||l_sess_id);
    end if;

    -- create order by clause
    l_order_by_clause := '1';

    -- Call to Object Navigator to execute query and return data
    -- as well as object and region structures
    ak_query_pkg.exec_query (
 	     P_PARENT_REGION_APPL_ID => p_LOV_region_id		,
	     P_PARENT_REGION_CODE    => p_LOV_region		,
	     P_WHERE_CLAUSE  	     => l_where_clause		,
	     P_ORDER_BY_CLAUSE	     => l_order_by_clause	,
	     P_RESPONSIBILITY_ID     => l_responsibility_id	,
	     P_USER_ID	             => l_user_id		,
	     P_RETURN_PARENTS	     => 'T'			,
	     P_RETURN_CHILDREN	     => 'F');


    -- write out the number of columns returned by the ak query
    htp.p(ak_query_pkg.g_items_table.COUNT);

    -- write out the number of rows returned by the ak query
    htp.p(ak_query_pkg.g_results_table.COUNT);


    -- write out the column header information
    l_total_width := 0;
    if ak_query_pkg.g_items_table.COUNT > 0 then
      for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
        if ak_query_pkg.g_items_table(i).secured_column = 'F' and
           ak_query_pkg.g_items_table(i).node_display_flag = 'Y' then
             l_total_width := l_total_width + ak_query_pkg.g_items_table(i).display_value_length;
        end if;
      end loop;


      for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
        if ak_query_pkg.g_items_table(i).secured_column = 'F' then
          htp.p(ak_query_pkg.g_items_table(i).attribute_label_long);
          if ak_query_pkg.g_items_table(i).node_display_flag = 'Y' then
            htp.p(round((ak_query_pkg.g_items_table(i).display_value_length/l_total_width) * 100));
          else
            htp.p('0');
          end if;
        end if;
      end loop;
    end if;


    -- write out the row data
    if p_titles_only <> 'Y' then
      if ak_query_pkg.g_results_table.COUNT > 0 then
        for i in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
          -- load data for current row into temp pl/sql table
	  transfer_Row_To_Column(ak_query_pkg.g_results_table(i), l_result_row_table);
          for j in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
            htp.p(l_result_row_table(ak_query_pkg.g_items_table(j).value_id));
	  end loop;
        end loop;
      end if;
    end if;

  end if;

end;

/* No longer used
procedure ICX_PRE_LOV(p_titles_only in varchar2,
                      p_find_criteria in varchar2) is

begin
  htp.p('PRELOAD LOV');
  htp.p('1');  -- columns
  htp.p('1');  -- rows
  htp.p('X');  -- header
  htp.p('100');  -- header size
end;
*/

/*
** creates the next/previons set buttons for the lov
** also displays the current count location within the list
*/

procedure lovrecordbuttons(p_language_code in varchar2,
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
			  p_target in varchar2,
                          p_list_count in boolean,
                          P_OBJECT_DISP_NAME in varchar2) is
l_target        varchar2(240);
l_title 	varchar2(80);
l_prompts       icx_util.g_prompts_table;
l_message	varchar2(2000);
l_parameter	varchar2(2000);
l_start_row	number;
l_stop_row	number;
begin

  icx_util.getPrompts(601,'ICX_WEB_ON',l_title,l_prompts);

  /*
  ** If the request is just meant to show the row count then
  ** do so here
  */
  IF (p_list_count = TRUE) THEN

     htp.tableOpen(cborder => 'BORDER=0', cattributes => 'WIDTH="100%"');
     htp.tableRowOpen;
     fnd_message.set_name('ICX','ICX_RECORDS_RANGE');
     fnd_message.set_token('FROM_ROW_TOKEN',p_start_row);
     fnd_message.set_token('TO_ROW_TOKEN',p_stop_row);
     fnd_message.set_token('TOTAL_ROW_TOKEN','<font color="ff0000">'||
        p_row_count||'</font>');
     l_message := fnd_message.get;
     htp.p('<font size=2>'||l_message||'<font>');
     htp.tableRowClose;
     htp.tableClose;

  /*
  ** Otherwise check to see if you should create the previous / next set
  ** buttons
  */
  ELSE

     htp.tableOpen(calign=>'CENTER', cborder => 'BORDER=0');
     htp.tableRowOpen;

     /*
     ** Check to see if you should create the PREVIOUS button
     */
     IF  (p_start_row > 1) THEN

        htp.p('<TD>');

        /*
        ** Make sure that your not going to go back past the first
        ** record.  Otherwise subtract the query set from the start
        */
        IF (p_start_row - p_query_set < 1) THEN

            l_start_row := 1;

        ELSE

            l_start_row := p_start_row - p_query_set;

        END IF;


        /*
        ** Make sure that your not going to go back past the last
        ** record
        */
        IF (l_start_row + p_query_set > p_row_count) THEN

            l_stop_row := p_row_count;

        ELSE

            l_stop_row := l_start_row + p_query_set - 1;

        END IF;

        htp.p('<A HREF="javascript:'||p_jsproc||'('||''''||
               to_char(l_start_row)||
               ''''||','||''''||
              to_char(l_stop_row)||''''||')">');

	htp.p('<IMG SRC="/OA_MEDIA/FNDIPRVB.gif" border=0></A>');

        fnd_message.set_name('ICX','ICX_PREVIOUS');

        htp.p('<font class=button>'||fnd_message.get||'</font>');

        htp.p('</TD>');

     END IF;

     /*
     ** Check to see if you should create the NEXT button
     */
     IF (p_stop_row < p_row_count) THEN

        htp.p('<TD>');

        IF (p_start_row + p_query_set > p_row_count) THEN

            l_start_row := p_row_count;

        ELSE

            l_start_row := p_start_row + p_query_set;

        END IF;

        IF (p_stop_row + p_query_set >  p_row_count) THEN

            l_stop_row := p_row_count;

        ELSE

            l_stop_row := p_stop_row + p_query_set;

        END IF;


        htp.p('<A HREF="javascript:'||p_jsproc||'('||''''||
               to_char(l_start_row)||''''||','||''''||to_char(l_stop_row)||
              ''''||')">');

        fnd_message.set_name('ICX','ICX_NEXT');

        htp.p('<font class=button>'||fnd_message.get||'</font>');

	htp.p('<IMG SRC="/OA_MEDIA/FNDINXTB.gif" border=0></A>');

        htp.p('</TD>');

     END IF;

     htp.tableRowClose;
     htp.tableclose;

   end if;

end lovrecordbuttons;



procedure LOVHeader (c_attribute_code in varchar2,
		     p_LOV_foreign_key_name in varchar2,
                     p_LOV_region_id in number,
                     p_LOV_region in varchar2,
                     c_form_name in varchar2,
                     c_frame_name in varchar2,
	 	     c_lines in number,
		     x in number,
		     a_1 in varchar2,
 		     c_1 in varchar2,
		     i_1 in varchar2,
		     a_2 in varchar2,
		     c_2 in varchar2,
	    	     i_2 in varchar2,
		     a_3 in varchar2,
		     c_3 in varchar2,
	    	     i_3 in varchar2,
		     a_4 in varchar2,
		     c_4 in varchar2,
	    	     i_4 in varchar2,
		     a_5 in varchar2,
		     c_5 in varchar2,
	    	     i_5 in varchar2) is


cursor lov_query_columns  is

        select	d.COLUMN_NAME,b.ATTRIBUTE_LABEL_LONG,
                substr(a.DATA_TYPE,1,1)
        from    AK_ATTRIBUTES a,
		AK_REGION_ITEMS_VL b,
		AK_REGIONS c,
		AK_OBJECT_ATTRIBUTES d
        where	b.REGION_APPLICATION_ID = p_LOV_region_id
        and	b.REGION_CODE = p_LOV_region
        and	b.NODE_QUERY_FLAG = 'Y'
        and	b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and	b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
	and	b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
	and	b.REGION_CODE = c.REGION_CODE
	and	c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
	and	d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
	and 	d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
        order by b.DISPLAY_SEQUENCE;

c_browser 	varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');
c_agent 		varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
c_amp 			varchar2(1) := '&';
temp_text 		varchar2(2000);
i 			number;
c_language 		varchar2(30);
l_lookup_codes		g_lookup_code_table;
l_lookup_meanings	g_lookup_meaning_table;
LOV_title       	varchar2(80);
LOV_prompts     	g_prompts_table;
temp_column 		varchar2(30);
temp_attribute 		varchar2(50);
temp_type 		varchar2(1);
num_attributes          number;
err_num 		number;
err_mesg 		varchar2(512);
temp_message 		varchar2(2000);
l_query_attr_cnt        number;
l_attributes2 		varchar2(2000);
l_conditions2 		varchar2(2000);
l_display_line 		varchar2(2000);
l_icx_custom_call       varchar2(30);
l_message               varchar2(2000);
l_matchcase_lov         varchar2(10);

begin

l_matchcase_lov := fnd_profile.value('ICX_MATCHCASE_LOV');

if l_matchcase_lov is null
then
l_matchcase_lov := 'Checked';
end if;

if icx_sec.validateSession then
    c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    getPrompts(601,'ICX_LOV',LOV_title,LOV_prompts);


    htp.headOpen;
        icx_util.copyright;

--        htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/PORSTYLE.css" TYPE="text/css">');

        htp.title(LOV_title);
        js.scriptOpen;

        htp.p('var search = "Y"');

	htp.p('function queryText() {');
	    if c_frame_name is null then
	        htp.p('if (parent.opener.parent.document.'||c_form_name||'.'||c_attribute_code||'.value != "") {
	  	    document.LOVHeader.i_1.value = parent.opener.parent.document.'||c_form_name||'.'||c_attribute_code||'.value');
            else
                htp.p('if (parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||c_attribute_code||'.value != "") {
		    document.LOVHeader.i_1.value = parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||c_attribute_code||'.value');
	    end if;
	htp.p('}
	    }');

	htp.p('function Header_submit(line) {
	    open('''||c_agent||'/ICX_UTIL.LOVHeader?c_attribute_code='||c_attribute_code||c_amp||'p_LOV_foreign_key_name='||p_LOV_foreign_key_name||c_amp||'p_LOV_region_id='||p_LOV_region_id
		||c_amp||'p_LOV_region='||p_LOV_region||c_amp||'c_form_name='||c_form_name||c_amp||'c_frame_name='||c_frame_name||c_amp||'c_lines='' + line + '''||c_amp||'x=2'',''LOVHeader'')
	    }');

        select  icx_custom_call
        into    l_icx_custom_call
        from    ak_regions
        where   REGION_APPLICATION_ID = p_LOV_region_id
        and     REGION_CODE = p_LOV_region;

        if instr(l_icx_custom_call,'LONG') > 0
        then
        fnd_message.set_name('ICX','ICX_OPEN_QUERY2');
        l_message := icx_util.replace_quotes(fnd_message.get);

        htp.p('function LOV_check(attributes) {
          if (search == "Y") {
            if (document.LOVHeader.i_1.value == "") {
                alert("'||l_message||'");
                document.LOVHeader.i_1.focus();
            } else {
                case_check(attributes);
            }
          }
        }');
        else
        fnd_message.set_name('ICX','ICX_OPEN_QUERY');
        l_message := icx_util.replace_quotes(fnd_message.get);

        htp.p('function LOV_check(attributes) {
          if (search == "Y") {
                 if (document.LOVHeader.i_1.value == "") {
                     if (confirm("'||l_message||'")) {
                         LOV_submit(attributes);
                     } else {
                       document.LOVHeader.i_1.focus();
                     }
                 } else {
                     case_check(attributes);
                 }
           }
         }');
        end if;

----------------------------------------------- 1550749
if l_matchcase_lov = 'Hidden'
then
           htp.p('function case_check(attributes) {
       LOV_submit(attributes);
      }');
else
        -- javascript to pop alert box if case-sensitive is
        fnd_message.set_name('ICX','ICX_CASE_QUERY');
        l_message := icx_util.replace_quotes(fnd_message.get);
        htp.p('function case_check(attributes) {
            if (!(document.LOVHeader.case_sensitive.checked)) {
                    if (confirm("'||l_message||'")) {
                       LOV_submit(attributes);
                    } else {
                      document.LOVHeader.i_1.focus();
                    }
                 } else {
                    LOV_submit(attributes);
                 }
               }');
end if;
---------------------------------------------------------------- 1557049
        htp.p('function LOV_submit(attributes) {
            if (attributes > 1) {
              parent.LOVValues.document.LOVValues.x.value = 1
              parent.LOVValues.document.LOVValues.start_row.value = 1
              parent.LOVValues.document.LOVValues.p_end_row.value = ""
              parent.LOVValues.document.LOVValues.a_1.value = document.LOVHeader.a_1.options[document.LOVHeader.a_1.selectedIndex].value
              parent.LOVValues.document.LOVValues.c_1.value = document.LOVHeader.c_1.options[document.LOVHeader.c_1.selectedIndex].value
              parent.LOVValues.document.LOVValues.i_1.value = document.LOVHeader.i_1.value
              } else {
              parent.LOVValues.document.LOVValues.x.value = 1
              parent.LOVValues.document.LOVValues.start_row.value = 1
              parent.LOVValues.document.LOVValues.p_end_row.value = ""
              parent.LOVValues.document.LOVValues.a_1.value = document.LOVHeader.a_1.value
              parent.LOVValues.document.LOVValues.c_1.value = document.LOVHeader.c_1.options[document.LOVHeader.c_1.selectedIndex].value
              parent.LOVValues.document.LOVValues.i_1.value = document.LOVHeader.i_1.value}');

if l_matchcase_lov = 'Hidden'
then
       htp.p('parent.LOVValues.document.LOVValues.case_sensitive.value = "on"');
else

        htp.p('if (document.LOVHeader.case_sensitive.checked) {
            parent.LOVValues.document.LOVValues.case_sensitive.value = document.LOVHeader.case_sensitive.value
            } else {
            parent.LOVValues.document.LOVValues.case_sensitive.value = null
            }');
end if;   --- 1557049
	if c_lines <> 1 then
        htp.p('parent.LOVValues.document.LOVValues.a_2.value = document.LOVHeader.a_2.options[document.LOVHeader.a_2.selectedIndex].value
            parent.LOVValues.document.LOVValues.c_2.value = document.LOVHeader.c_2.options[document.LOVHeader.c_2.selectedIndex].value
            parent.LOVValues.document.LOVValues.i_2.value = document.LOVHeader.i_2.value
            parent.LOVValues.document.LOVValues.a_3.value = document.LOVHeader.a_3.options[document.LOVHeader.a_3.selectedIndex].value
            parent.LOVValues.document.LOVValues.c_3.value = document.LOVHeader.c_3.options[document.LOVHeader.c_3.selectedIndex].value
            parent.LOVValues.document.LOVValues.i_3.value = document.LOVHeader.i_3.value
            parent.LOVValues.document.LOVValues.a_4.value = document.LOVHeader.a_4.options[document.LOVHeader.a_4.selectedIndex].value
            parent.LOVValues.document.LOVValues.c_4.value = document.LOVHeader.c_4.options[document.LOVHeader.c_4.selectedIndex].value
            parent.LOVValues.document.LOVValues.i_4.value = document.LOVHeader.i_4.value
            parent.LOVValues.document.LOVValues.a_5.value = document.LOVHeader.a_5.options[document.LOVHeader.a_5.selectedIndex].value
            parent.LOVValues.document.LOVValues.c_5.value = document.LOVHeader.c_5.options[document.LOVHeader.c_5.selectedIndex].value
            parent.LOVValues.document.LOVValues.i_5.value = document.LOVHeader.i_5.value');
	else
        htp.p('parent.LOVValues.document.LOVValues.a_2.value = ""
            parent.LOVValues.document.LOVValues.c_2.value = ""
            parent.LOVValues.document.LOVValues.i_2.value = ""
            parent.LOVValues.document.LOVValues.a_3.value = ""
            parent.LOVValues.document.LOVValues.c_3.value = ""
            parent.LOVValues.document.LOVValues.i_3.value = ""
            parent.LOVValues.document.LOVValues.a_4.value = ""
            parent.LOVValues.document.LOVValues.c_4.value = ""
            parent.LOVValues.document.LOVValues.i_4.value = ""
            parent.LOVValues.document.LOVValues.a_5.value = ""
            parent.LOVValues.document.LOVValues.c_5.value = ""
            parent.LOVValues.document.LOVValues.i_5.value = ""');
	end if;
        htp.p('parent.LOVValues.document.LOVValues.submit()
            search="X" }');

        htp.p('function clearField() {
            document.LOVHeader.reset()
            search = "Y"
            }');

        js.scriptClose;
    htp.headClose;

    htp.p('<BODY bgcolor="#cccccc">');

    select count(*)
    into   l_query_attr_cnt
    from   AK_ATTRIBUTES a,
    	   AK_REGION_ITEMS_VL b,
    	   AK_REGIONS c,
    	   AK_OBJECT_ATTRIBUTES d
    where  b.REGION_APPLICATION_ID = p_LOV_region_id
    and	   b.REGION_CODE = p_LOV_region
    and	   b.NODE_QUERY_FLAG = 'Y'
    and	   b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
    and	   b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
    and	   b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
    and	   b.REGION_CODE = c.REGION_CODE
    and	   c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
    and	   d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
    and	   d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
    and 	d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
    and	   d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE;

    htp.formOpen('javascript:LOV_check('||to_char(l_query_attr_cnt)||')',
        'POST','','','NAME="LOVHeader"');

    htp.p('<CENTER>');
--    htp.tableOpen('BORDER=0','','','','WIDTH=100%');  --bug 2318801
    htp.p('<table cellpadding=4 cellspacing=0 border=0>');
    htp.tableRowOpen;

    htp.formHidden('c_attribute_code',c_attribute_code);
    htp.formHidden('p_LOV_foreign_key_name',p_LOV_foreign_key_name);
    htp.formHidden('p_LOV_region_id',p_LOV_region_id);
    htp.formHidden('p_LOV_region',p_LOV_region );
    htp.formHidden('c_frame_name',c_frame_name);
    htp.formHidden('c_form_name',c_form_name);
    htp.formHidden('c_lines',c_lines);
    htp.formHidden('x',x);

    -- Build select list of query attributes.
    temp_text := '';
    l_attributes2 := htf.formSelectOption('','','VALUE=""');
    open lov_query_columns;
    num_attributes := 0;
    loop
        fetch lov_query_columns into temp_column, temp_attribute, temp_type;
        exit when lov_query_columns%NOTFOUND;
        num_attributes := num_attributes + 1;
	if num_attributes = 1 then
            temp_text := htf.formSelectOption(temp_attribute,'SELECTED','VALUE="'||temp_type||temp_column||'"');
            l_attributes2 := l_attributes2||htf.formSelectOption(temp_attribute,'','VALUE="'||temp_type||temp_column||'"');
	else
            temp_text := temp_text||htf.formSelectOption(temp_attribute,'','VALUE="'||temp_type||temp_column||'"');
            l_attributes2 := l_attributes2||htf.formSelectOption(temp_attribute,'','VALUE="'||temp_type||temp_column||'"');
	end if;
    end loop;
    close lov_query_columns;
    temp_text := temp_text||htf.formSelectClose;
    l_attributes2 := l_attributes2||htf.formSelectClose;

    -- if only one attribute, print as text (not pop list)
    if num_attributes = 1 then

--bug 2318801
      htp.formHidden('a_1',temp_type||temp_column);
      htp.p('<TD ALIGN="CENTER" WIDTH="25%">');
      htp.p('<table cellpadding=0 cellspacing=0 border=0>');
      htp.p('<tr>');
      htp.tableData(htf.nobr(temp_attribute));
      htp.tableClose;

    else
      htp.tableData(htf.formSelectOpen('a_1')||temp_text);
    end if;
    -- end of attributes select list


    -- build select list of conditions
    temp_text := '';
    l_conditions2 := htf.formSelectOption('','SELECTED','VALUE=""');
    getLookups('ICX_CONDITIONS',l_lookup_codes, l_lookup_meanings);
    for i in 1..to_number(l_lookup_codes(0)) loop
        if l_lookup_codes(i) = 'DSTART' then
            temp_text := temp_text||htf.formSelectOption(l_lookup_meanings(i),'SELECTED','VALUE="'||l_lookup_codes(i)||'"');
            l_conditions2 := l_conditions2||htf.formSelectOption(l_lookup_meanings(i),'','VALUE="'||l_lookup_codes(i)||'"');
        elsif instr(l_icx_custom_call,'NOCONTAIN') > 0
        and l_lookup_codes(i) = 'CCONTAIN'
        then
            temp_text := temp_text;
	else
            temp_text := temp_text||htf.formSelectOption(l_lookup_meanings(i),'','VALUE="'||l_lookup_codes(i)||'"');
            l_conditions2 := l_conditions2||htf.formSelectOption(l_lookup_meanings(i),'','VALUE="'||l_lookup_codes(i)||'"');
        end if;
    end loop;
    temp_text := temp_text||htf.formSelectClose;
    l_conditions2 := l_conditions2||htf.formSelectClose;
    htp.tableData(htf.formSelectOpen('c_1')||temp_text);
    -- end of conditions select list


    -- print text field
    htp.tableData(htf.formText('i_1',20,20));
    if x = 1 then
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('queryText()');
        htp.p('</SCRIPT>');
    end if;

    htp.p('<!-- This is a button table containing 3 buttons. The first row defines the edges and tops-->');
    htp.p('<TD ALIGN="LEFT" WIDTH="100%">');
    htp.p('<table cellpadding=0 cellspacing=0 border=0>');
    htp.p('<tr>');
    htp.p('<!-- left hand button, round left side and square right side-->');
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>');
-- bug 1235659
--    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
htp.p('<td bgcolor=#cccccc></td>'); --add
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');
    htp.p('<!-- standard spacer between square button images-->        ');
    htp.p('<td width=2 rowspan=5></td>');

    if num_attributes > 1 then

       htp.p('<!-- middle button with squared ends on both left and right-->        ');
       htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
-- bug 1235659
--       htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
htp.p('<td bgcolor=#cccccc></td>');
       htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');
       htp.p('<!-- standard spacer between square button images-->         ');
       htp.p('<td width=2 rowspan=5></td>');

    end if;

    htp.p('<!-- right hand button, square left side and round right side-->        ');
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
-- bug 1235659
--   htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('<td bgcolor=#cccccc></td>');
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');
    htp.p('</tr>');
    htp.p('<tr>');
    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');

    htp.p('</tr>');
    htp.p('<tr>');
    htp.p('<!-- Text and links for each button are listed here-->');
    htp.p('<td bgcolor=#cccccc height=20 nowrap><a href="javascript:LOV_check('||num_attributes||')"><font class=button>'||LOV_prompts(1));
    htp.p('</FONT></TD>');
    htp.p('<TD bgcolor=#cccccc height=20 nowrap><A href="javascript:clearField()"><FONT class=button>'||LOV_prompts(2));
    htp.p('</FONT></TD>');

    if num_attributes > 1 then
      if c_lines = 1 then
        htp.p('<TD bgcolor=#cccccc height=20 nowrap><A href="javascript:Header_submit(5)"><FONT class=button>'||LOV_prompts(8));
      else
        htp.p('<TD bgcolor=#cccccc height=20 nowrap><A href="javascript:Header_submit(1)"><FONT class=button>'||LOV_prompts(9));
      end if;
    end if;

    htp.p('</FONT></A></TD>');
    htp.p('</TR>');

    htp.p('<TR>');
    htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
    htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
    htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
    htp.p('</TR>');
    htp.p('<TR>');
-- bug 1235659
--    htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
--    htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
--    htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
htp.p('<TD bgcolor=#cccccc></TD>');
htp.p('<TD bgcolor=#cccccc></TD>');
htp.p('<TD bgcolor=#cccccc></TD>');

    htp.p('</TR>');
    htp.p('</TABLE>');
    htp.p('</TD>');
    htp.p('</TR>');

    -- Create extra query lines if necessary
    if c_lines <> 1 then
        for i in 2..to_number(c_lines) loop
            l_display_line := '<TR><TD>'||htf.formSelectOpen('a_'||i)||
                              l_attributes2||htf.formSelectClose||'</TD>'||
                              '<TD>'||htf.formSelectOpen('c_'||i)||
		              l_conditions2||htf.formSelectClose||'</TD>'||
                              '<TD>'||htf.formText('i_'||i,20)||'</TD></TR>';
	    htp.p(l_display_line);
        end loop;
    end if;

    htp.tableRowClose;

    -- add case-sensitive check box
if l_matchcase_lov = 'Checked'  -- 1550749
then
    htp.tableRowOpen;
      htp.tableData(htf.formCheckBox('case_sensitive','','CHECKED')||LOV_prompts(12));
    htp.tableRowClose;
    htp.tableClose;
end if;

if l_matchcase_lov = 'Hidden'
then

 fnd_message.set_name('ICX','ICX_MATCHCASE_LOV');
 l_message := fnd_message.get;

     htp.tableRowOpen;
     htp.tableData(htf.italic(l_message),NULL,NULL,NULL,NULL,3,NULL);
     htp.tableData(htf.formHidden('case_sensitive', 'on'));
     htp.tableRowClose;
     htp.tableClose;
end if;

if l_matchcase_lov = 'Unchecked'
then
       htp.tableRowOpen;
      htp.tableData(htf.formCheckBox('case_sensitive')||LOV_prompts(12));
    htp.tableRowClose;
    htp.tableClose;
end if;

--- end of 1550749


    htp.p('</CENTER>');
    htp.formClose;
    htp.bodyClose;

end if;  -- ValidateSession

exception
  when others then
    err_num := SQLCODE;
    temp_text := SQLERRM;
    select substr(temp_text,12,512) into err_mesg from dual;
         temp_message := err_mesg;
         icx_util.add_error(temp_message);
         icx_util.error_page_print;

end;  -- LOVHeader




procedure LOVValues (p_LOV_foreign_key_name in varchar2,
		     p_LOV_region_id in number,
                     p_LOV_region in varchar2,
		     p_attribute_app_id in number,
                     p_attribute_code in varchar2,
                     p_region_app_id in number,
                     p_region_code in varchar2,
                     c_form_name in varchar2,
                     c_frame_name in varchar2,
                     c_where_clause in varchar2,
                     x in number,
 	             start_row in number,
		     p_end_row in number,
		     a_1 in varchar2,
		     c_1 in varchar2,
	    	     i_1 in varchar2,
		     a_2 in varchar2,
		     c_2 in varchar2,
	    	     i_2 in varchar2,
		     a_3 in varchar2,
		     c_3 in varchar2,
	    	     i_3 in varchar2,
		     a_4 in varchar2,
		     c_4 in varchar2,
	    	     i_4 in varchar2,
		     a_5 in varchar2,
		     c_5 in varchar2,
	    	     i_5 in varchar2,
                     case_sensitive in varchar2) is

cursor lov_out_attributes is
	select  ATTRIBUTE_CODE, LOV_ATTRIBUTE_CODE
        from    AK_REGION_ITEMS_VL
	where   REGION_APPLICATION_ID = p_region_app_id
	and 	REGION_CODE = p_region_code
	and 	LOV_REGION_APPLICATION_ID = p_LOV_region_id
 	and	LOV_REGION_CODE	= p_LOV_region
	and 	LOV_FOREIGN_KEY_NAME = p_LOV_foreign_key_name
	order by DISPLAY_SEQUENCE;

cursor js_out_attributes is
	select  ATTRIBUTE_CODE, LOV_ATTRIBUTE_CODE, REGION_DEFAULTING_API_PROC
        from    AK_REGION_ITEMS_VL
	where   REGION_APPLICATION_ID = p_region_app_id
	and 	REGION_CODE = p_region_code
	and 	LOV_REGION_APPLICATION_ID = p_LOV_region_id
 	and	LOV_REGION_CODE	= p_LOV_region
	and 	LOV_FOREIGN_KEY_NAME = p_LOV_foreign_key_name
	and     REGION_DEFAULTING_API_PROC is not null
	order by DISPLAY_SEQUENCE;

cursor lov_query_columns  is
        select	d.COLUMN_NAME
        from    AK_ATTRIBUTES a,
		AK_REGION_ITEMS_VL b,
		AK_REGIONS c,
		AK_OBJECT_ATTRIBUTES d
        where	b.REGION_APPLICATION_ID = p_LOV_region_id
        and	b.REGION_CODE = p_LOV_region
        and	b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and	b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
	and	b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
	and	b.REGION_CODE = c.REGION_CODE
	and	c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
	and	d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
	and 	d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
	and	d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
        order by b.DISPLAY_SEQUENCE;

c_agent 		varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
c_language 		varchar2(30);
LOV_title       	varchar2(80);
LOV_prompts     	g_prompts_table;
err_num 		number;
err_mesg 		varchar2(512);
temp_message 		varchar2(2000);
temp_text		varchar2(2000);
where_clause 		varchar2(2000);
where_bind_vals   VARCHAR2(2000);--mputman
order_clause 		varchar2(2000);
l_responsibility_id 	number;
l_user_id 		number;
i 			number;
j 			number;
k 			number;
l 			number;
base_region_attr 	varchar2(30);
LOV_region_attr 	varchar2(30);
js_proc_name 		varchar2(30);
temp_a_1 		varchar2(51);
temp_column 		varchar2(30);
clicked_columns 	varchar2(2000);
end_row 		number;
total_rows 		number;
l_query_size 		number;
l_max_rows              number;
l_result_row_table 	icx_util.char240_table;
l_clicked_vars 		varchar2(2000);
l_attribute_name 	varchar2(240);
l_js_proc_text 		varchar2(2000);
l_where_clause          varchar2(2000);
l_query_binds           ak_query_pkg.bind_tab;
l_error                 boolean;
l_where_temp       VARCHAR2(2000); -- mputman added
c_where_bind_vals  VARCHAR2(2000); -- mputman added
l_query_binds_index NUMBER;

begin
if icx_sec.validateSession then

    l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
    l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

    c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    getPrompts(601,'ICX_LOV',LOV_title,LOV_prompts);

    l_error := FALSE;

    -- x = 1 or 2 indicates that Object Navigator should be called to
    -- perform query and display data
    if x = 1 or x = 2 then

        -- Perform Object Navigator query

        -- Call whereSegment to construct where clause
        if case_sensitive = 'on' then
          where_clause := icx_on_utilities.whereSegment
 		 		(a_1  =>  a_1,
 				 c_1  =>  c_1,
			         i_1  =>  i_1,
				 a_2  =>  a_2,
 				 c_2  =>  c_2,
			         i_2  =>  i_2,
				 a_3  =>  a_3,
 				 c_3  =>  c_3,
			         i_3  =>  i_3,
				 a_4  =>  a_4,
 				 c_4  =>  c_4,
			         i_4  =>  i_4,
				 a_5  =>  a_5,
 				 c_5  =>  c_5,
			         i_5  =>  i_5,
                                 m    =>  case_sensitive);
        else
          where_clause := icx_on_utilities.whereSegment
 		 		(a_1  =>  a_1,
 				 c_1  =>  c_1,
			         i_1  =>  i_1,
				 a_2  =>  a_2,
 				 c_2  =>  c_2,
			         i_2  =>  i_2,
				 a_3  =>  a_3,
 				 c_3  =>  c_3,
			         i_3  =>  i_3,
				 a_4  =>  a_4,
 				 c_4  =>  c_4,
			         i_4  =>  i_4,
				 a_5  =>  a_5,
 				 c_5  =>  c_5,
			         i_5  =>  i_5);
        end if;



        -- unpack where clause to use bind variables
        icx_on_utilities.unpack_whereSegment(where_clause,l_where_clause,l_query_binds);

        l_where_temp:= icx_call.decrypt2(c_where_clause); --mputman added

        IF  substrb(l_where_temp,1,2)='@@'THEN
           c_where_bind_vals :=  substrb(l_where_temp,(instrb(l_where_temp,'@@',1,2)+2),length(l_where_temp));
           l_where_temp := substrb(l_where_temp,3,(instrb(l_where_temp,'@@',1,2)-3));
        END IF;

        -- Add where clause LOV parameter to generated where clause
        if c_where_clause is not null then
	       if l_where_clause is null then
             l_where_clause := l_where_temp;
          ELSE --l_where_clause is NOT null
             l_where_clause := l_where_clause||' and '||l_where_temp;
          end if;  -- l_where_clause
    /*
    c_where_bind_vals is an encrypted '*' delimited string terminated by '**]' that
    contains the values associated to the binds in c_where_clause (encrypted using
    icx_call.encrypt2()).  If c_where_bind_vals is null then we assume that c_where_clause
    does not contain any bind variables/values. If it is not null, we exepect the
    decrypted value to provide the bind values for the bind variables to be named
    ':ICXBIND_W(n)' starting with '0' and incrementing by one for each bind variable.
    */
        end if; --c_where_clause

        IF c_where_bind_vals IS NOT NULL THEN
           l_query_binds_index:=l_query_binds.COUNT;
          icx_on_utilities.unpack_whereSegment(c_where_bind_vals,l_query_binds,l_query_binds_index);
        END IF;



	-- Create order clause
	open lov_query_columns;
	i := 0;
	loop
	    fetch lov_query_columns into temp_column;
	    exit when lov_query_columns%NOTFOUND;
	    i := i + 1;
	    if substr(a_1,2,31) = temp_column then
	        order_clause := i;
		exit;
	    end if;
	end loop;
	close lov_query_columns;

        -- Look up the number of rows to display
        select QUERY_SET, MAX_ROWS
        into l_query_size, l_max_rows
        from ICX_PARAMETERS;

        -- figure end row value to display */
        if p_end_row is null then
            end_row := l_query_size;
        else
            end_row := p_end_row;
        end if;

	-- Call to Object Navigator to execute query and return data
        -- as well as object and region structures
        ak_query_pkg.exec_query (
 	     P_PARENT_REGION_APPL_ID => p_LOV_region_id		,
	     P_PARENT_REGION_CODE    => p_LOV_region		,
	     P_WHERE_CLAUSE  	     => l_where_clause		,
             P_WHERE_BINDS           => l_query_binds           ,
	     P_ORDER_BY_CLAUSE	     => order_clause		,
	     P_RESPONSIBILITY_ID     => l_responsibility_id	,
	     P_USER_ID	             => l_user_id		,
	     P_RETURN_PARENTS	     => 'T'			,
	     P_RETURN_CHILDREN	     => 'F'			,
             P_RANGE_LOW             => start_row               ,
             P_RANGE_HIGH            => end_row                 ,
             P_MAX_ROWS		     => l_max_rows);

      if ak_query_pkg.g_regions_table(0).total_result_count = l_max_rows then
        l_error := TRUE;
      end if;

    end if;  -- Do Object Navigator query


    htp.htmlOpen;
    htp.headOpen;
--    htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/PORSTYLE.css" TYPE="text/css">');

        js.scriptOpen;

	-- If this is the initial LOV call, we need to write the autoquery
	-- Javascript function to perform autoquery if necessary
	if x = 0 then

	    -- Need to fetch the value of the base LOV attribute
	    -- column name from the LOV object to be used in the autoquery
	    select substr(a.DATA_TYPE,1,1)||d.COLUMN_NAME
	    into temp_a_1
            from    AK_ATTRIBUTES a,
		    AK_REGION_ITEMS_VL b,
		    AK_REGIONS c,
		    AK_OBJECT_ATTRIBUTES d
            where   b.REGION_APPLICATION_ID = p_LOV_region_id
            and	    b.REGION_CODE = p_LOV_region
            and	    b.NODE_QUERY_FLAG = 'Y'
            and	    b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
            and	    b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
	    and	    b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
	    and	    b.REGION_CODE = c.REGION_CODE
	    and	    c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
	    and	    d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
	    and	    d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
	    and     d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
	    and	    d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
	    and     b.DISPLAY_SEQUENCE = (
		    select min(e.DISPLAY_SEQUENCE)
		    from   AK_REGION_ITEMS_VL e
		    where  e.REGION_APPLICATION_ID = p_LOV_region_id
		    and    e.REGION_CODE = p_LOV_region);

	    -- Write autoquery function
	    htp.p('function autoquery() {');
	    if c_frame_name is null then
	        htp.p('if (parent.opener.parent.document.'||c_form_name||'.'||p_attribute_code||'.value != "") {
	  	    document.LOVValues.i_1.value = parent.opener.parent.document.'||c_form_name||'.'||p_attribute_code||'.value');
            else
                htp.p('if (parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||p_attribute_code||'.value != "") {
		    document.LOVValues.i_1.value = parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||p_attribute_code||'.value');
	    end if;
            fnd_message.set_name('ICX','ICX_LOV_HINT');
	    htp.p('document.LOVValues.a_1.value = "'||temp_a_1||'"
                   document.LOVValues.submit()
	          } else {
                    document.write("<CENTER>")
                    document.write("<H3>'||icx_util.replace_quotes(fnd_message.get)||'</H3>")
                    document.write("</CENTER>")
	          }
	        }');

	end if;


	-- If this is not the initial LOV call, we need to write the clicked
        -- and LOV_rows javascript functions into the header of the page
	if x <> 0 then

	    -- build list of parameters for clicked javascript function
	    -- first the direct out values
            open lov_out_attributes;
            i := 0;
            loop
                fetch lov_out_attributes into base_region_attr, LOV_region_attr;
                exit when lov_out_attributes%NOTFOUND;
                i := i + 1;
                if (i = 1) then
                    clicked_columns := 'l_'||LOV_region_attr;
                else
                    clicked_columns := clicked_columns||',l_'||LOV_region_attr;
                end if;
            end loop;
            close lov_out_attributes;

	    -- and then the javascript procedure out values
            open js_out_attributes;
            loop
                fetch js_out_attributes into base_region_attr, LOV_region_attr, js_proc_name;
                exit when js_out_attributes%NOTFOUND;
                i := i + 1;
                if (i = 1) then
                    clicked_columns := 'ljs_'||LOV_region_attr;
                else
                    clicked_columns := clicked_columns||',ljs_'||LOV_region_attr;
                end if;
            end loop;
            close js_out_attributes;


	    -- write clicked javascript function in the html header
	    -- first the direct out values
            htp.p('function clicked('||clicked_columns||') {');
            open lov_out_attributes;
            loop
                fetch lov_out_attributes into base_region_attr, LOV_region_attr;
                exit when lov_out_attributes%NOTFOUND;
                if c_frame_name is not null then
                    htp.p('parent.opener.parent.'||c_frame_name||'.document.'||c_form_name||'.'||base_region_attr||'.value = l_'||LOV_region_attr);
                else
                    htp.p('parent.opener.parent.document.'||c_form_name||'.'||base_region_attr||'.value = l_'||LOV_region_attr);
                end if;
            end loop;
            close lov_out_attributes;

	    -- and then the javascript procedure out values
	    i := 0;
            open js_out_attributes;
            loop
                fetch js_out_attributes into base_region_attr, LOV_region_attr, js_proc_name;
                exit when js_out_attributes%NOTFOUND;
                i := i + 1;
                if (i = 1) then
 		    if c_frame_name is not null then
		        l_js_proc_text := 'parent.opener.parent.'||c_frame_name||'.'||js_proc_name||'(ljs_'||LOV_region_attr;
		    else
			l_js_proc_text := 'parent.opener.parent.'||js_proc_name||'(ljs_'||LOV_region_attr;
		    end if;
		else
		    l_js_proc_text := l_js_proc_text||',ljs_'||LOV_region_attr;
		end if;
	    end loop;
	    if i > 0 then
		l_js_proc_text := l_js_proc_text||')';
	    end if;
            close js_out_attributes;
	    htp.p(l_js_proc_text);

            htp.p('parent.self.close()
                }');


	    -- Javascript function to handle CD buttons
            htp.p('function LOV_rows(start_num, end_num) {
                document.LOVValues.start_row.value = start_num
                document.LOVValues.p_end_row.value = end_num
                document.LOVValues.x.value = 2
                document.LOVValues.submit()
                }');


	end if;

        js.scriptClose;
    htp.headClose;

    htp.p('<BODY bgcolor="#cccccc" onload="parent.LOVHeader.search = ''Y''">');

    htp.formOpen(c_agent||'/icx_util.LOVValues','POST','','','NAME="LOVValues"');

    htp.formHidden('p_LOV_foreign_key_name',p_LOV_foreign_key_name);
    htp.formHidden('p_LOV_region_id',p_LOV_region_id);
    htp.formHidden('p_LOV_region',p_LOV_region );
    htp.formHidden('p_attribute_app_id',p_attribute_app_id);
    htp.formHidden('p_attribute_code',p_attribute_code);
    htp.formHidden('p_region_app_id',p_region_app_id);
    htp.formHidden('p_region_code',p_region_code);
    htp.formHidden('c_frame_name',c_frame_name);
    htp.formHidden('c_form_name',c_form_name);
    htp.formHidden('c_where_clause',c_where_clause);
    htp.formHidden('x','1');
    htp.formHidden('start_row',start_row);
    htp.formHidden('p_end_row',p_end_row);
    htp.formHidden('a_1',a_1);
    htp.formHidden('c_1',c_1);
    htp.formHidden('i_1',i_1);
    htp.formHidden('a_2',a_2);
    htp.formHidden('c_2',c_2);
    htp.formHidden('i_2',i_2);
    htp.formHidden('a_3',a_3);
    htp.formHidden('c_3',c_3);
    htp.formHidden('i_3',i_3);
    htp.formHidden('a_4',a_4);
    htp.formHidden('c_4',c_4);
    htp.formHidden('i_4',i_4);
    htp.formHidden('a_5',a_5);
    htp.formHidden('c_5',c_5);
    htp.formHidden('i_5',i_5);
    htp.formHidden('case_sensitive',case_sensitive);
    --htp.formHidden('c_where_bind_vals',c_where_bind_vals);

    -- check if error messages were generated by the ak query
    if not l_error then

      if x = 0 then

        -- x = 0 indicates the initial call to the LOV
        -- Autoquery or Display hint about selection criteria
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
	htp.p('autoquery()');
        htp.p('</SCRIPT>');

      end if;


      -- Display results
      if x = 1 or x = 2 then

        -- Look up the number of rows to display
        select QUERY_SET into l_query_size
        from ICX_PARAMETERS;


        -- get number of total rows returned by lov to be used to
        -- determine if we need to display the next/previous buttons
        total_rows := ak_query_pkg.g_regions_table(0).total_result_count;

        if end_row > total_rows then
            end_row := total_rows;
        end if;


	-- display LOV data and CD buttons if necessary
	j := 0;
	for i in 1..ak_query_pkg.g_results_table.COUNT loop
	    j := j + 1;

            -- If this is the first iteration of the loop then
	    -- display next/previous set buttons if list of values returns
	    -- more than the standard query size and also display
 	    -- the table header
            if j = 1 then
               lovrecordbuttons (
	          P_LANGUAGE_CODE    => c_language,
		  P_PACKPROC	     => 'JS',
		  P_START_ROW	     => start_row,
		  P_STOP_ROW	     => end_row,
		  P_ENCRYPTED_WHERE  => '1',
		  P_QUERY_SET	     => l_query_size,
		  P_ROW_COUNT	     => total_rows,
                  p_top              => TRUE,
		  P_JSPROC	     => 'LOV_rows',
                  p_hidden           => '',
                  p_update           => FALSE,
                  p_target           => '',
                  P_LIST_COUNT       => TRUE,
                  P_OBJECT_DISP_NAME => ak_query_pkg.g_items_table(1).attribute_label_long);

	        -- display table header of LOV
                htp.p('<table width=98% bgcolor=#999999 cellpadding=2 cellspacing=0 border=0>');
                htp.p('<tr><td>');
                htp.p('<table width=100% cellpadding=2 cellspacing=1 border=0>');
		htp.p('<TR BGColor="336699">');
		for k in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
 		    if ak_query_pkg.g_items_table(k).secured_column = 'F' and
		       ak_query_pkg.g_items_table(k).node_display_flag = 'Y' then

/*
		         htp.p('<TD align=center valign=bottom bgcolor="336699">'||
                               '<FONT class=promptwhite>'||
                               ak_query_pkg.g_items_table(k).attribute_label_long||
                               '</TH>');
*/
		         htp.p('<TD align=center valign=bottom bgcolor="336699">'||
                               '<FONT color=#FFFFFF>'||
                               ak_query_pkg.g_items_table(k).attribute_label_long||
                               '</TH>');


                    end if;
		end loop;
		htp.tableRowClose;

            end if;  -- CD Buttons and table header

-- start bug 1853315
htp.tableRowOpen;
htp.p('<font Color=#000000>');
htp.tableRowClose;
-- end bug 1853315


 	    -- load data for current row into temp pl/sql table
	    transfer_Row_To_Column(ak_query_pkg.g_results_table(i-1), l_result_row_table);


	    -- build variables to send to clicked javascript function
	    -- regular out variables
	    open lov_out_attributes;
	    k := 0;
	    loop
	 	fetch lov_out_attributes into base_region_attr, LOV_region_attr;
		exit when lov_out_attributes%NOTFOUND;
		k := k + 1;
		for l in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
		    if LOV_region_attr = ak_query_pkg.g_items_table(l).attribute_code then
 		        if (k = 1) then
 			    l_clicked_vars := ''''||replace_onMouseOver_quotes(l_result_row_table(ak_query_pkg.g_items_table(l).value_id))||'''';
			else
			    l_clicked_vars := l_clicked_vars||','''||replace_onMouseOver_quotes(l_result_row_table(ak_query_pkg.g_items_table(l).value_id))||'''';
			end if;
		    end if;
		end loop;
	    end loop;
	    close lov_out_attributes;

	    -- and the javascript procedure out values
            open js_out_attributes;
            loop
                fetch js_out_attributes into base_region_attr, LOV_region_attr, js_proc_name;
                exit when js_out_attributes%NOTFOUND;
                k := k + 1;
		for l in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
		    if LOV_region_attr = ak_query_pkg.g_items_table(l).attribute_code then
                        if (k = 1) then
                            l_clicked_vars := ''''||replace_onMouseOver_quotes(l_result_row_table(ak_query_pkg.g_items_table(l).value_id))||'''';
                        else
                            l_clicked_vars := l_clicked_vars||','''||replace_onMouseOver_quotes(l_result_row_table(ak_query_pkg.g_items_table(l).value_id))||'''';
		        end if;
                    end if;
                end loop;
            end loop;
            close js_out_attributes;


	    -- display one row of data
            if (round(j/2) = j/2) then
   	       htp.p('<TR BGColor="ffffff">');
            else
   	       htp.p('<TR BGColor="99ccff">');
            end if;

	    l := 0;
	    for k in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
		if ak_query_pkg.g_items_table(k).secured_column = 'F' and
		   ak_query_pkg.g_items_table(k).node_display_flag = 'Y' then
 		     l := l + 1;
		     if l = 1 then
                       htp.p(icx_on_utilities.formatData(htf.anchor('javascript:clicked('||l_clicked_vars||')',
			icx_on_utilities.formatText(l_result_row_table(ak_query_pkg.g_items_table(k).value_id),
			ak_query_pkg.g_items_table(k).bold,ak_query_pkg.g_items_table(k).italic)),ak_query_pkg.g_items_table(k).horizontal_alignment,ak_query_pkg.g_items_table(k).vertical_alignment));
                     else
                       htp.p(icx_on_utilities.formatData(icx_on_utilities.formatText(l_result_row_table(ak_query_pkg.g_items_table(k).value_id),
			ak_query_pkg.g_items_table(k).bold,ak_query_pkg.g_items_table(k).italic),ak_query_pkg.g_items_table(k).horizontal_alignment,ak_query_pkg.g_items_table(k).vertical_alignment));
		     end if;
		end if;
	    end loop;

	    htp.tableRowClose;

	end loop;  -- LOV data

        htp.tableClose;
        htp.p('</TD>');
        htp.p('</TR>');
        htp.p('</TABLE>');


	-- print button set if appropriate
        if (total_rows > l_query_size) and not
	   (start_row = 1 and end_row = total_rows) then

                 /*
                 ** Show next and previous buttons
                 */
		 lovrecordbuttons(
			P_LANGUAGE_CODE    => c_language,
			P_PACKPROC	   => 'JS',
			P_START_ROW	   => start_row,
			P_STOP_ROW	   => end_row,
			P_ENCRYPTED_WHERE  => '1',
			P_QUERY_SET	   => l_query_size,
			P_ROW_COUNT	   => total_rows,
                        p_top              => TRUE,
		 	P_JSPROC	   => 'LOV_rows',
                        p_hidden           => '',
                        p_update           => FALSE,
                        p_target           => '',
                        P_LIST_COUNT       => FALSE,
                        P_OBJECT_DISP_NAME => ak_query_pkg.g_items_table(1).attribute_label_long);

        end if;


	-- display message if no rows were returned by query
        if j = 0 then
	    select attribute_label_long into l_attribute_name
	        from ak_region_items_vl
                where region_application_id = p_region_app_id
                and region_code = p_region_code
                and attribute_application_id = p_attribute_app_id
                and attribute_code = p_attribute_code;
            fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
            fnd_message.set_token('NAME_OF_REGION_TOKEN',l_attribute_name);
            htp.p('<H3>'||fnd_message.get||'</H3>');
        end if;

      end if;  -- Display results

    else     -- ak_query generated an error
      fnd_message.set_name('ICX','ICX_MAX_ROWS');
      htp.p('<CENTER>');
      htp.p('<H3>'||icx_util.replace_quotes(fnd_message.get)||'</H3>');
      htp.p('</CENTER>');
    end if;  -- check if error messages were generated by the ak query

    htp.formClose;
    htp.bodyClose;
    htp.htmlClose;

end if;  -- validateSession

exception
  when others then
    err_num := SQLCODE;
    temp_text := SQLERRM;
    select substr(temp_text,12,512) into err_mesg from dual;
         temp_message := err_mesg;
         icx_util.add_error(temp_message);
         icx_util.error_page_print;

end; -- LOVValues




procedure copyright is
begin
    htp.p('<!-- Copyright ' || '&' || '#169; 2002 Oracle Corporation, All rights reserved. -->');
end copyright;

procedure getPrompts( p_region_application_id in number,
                      p_region_code in varchar2,
                      p_title out NOCOPY varchar2,
                      p_prompts out NOCOPY g_prompts_table) is

l_count			number;

cursor items is   -- removed select for ari.attribute_code since we didnt use it. mputman 1574527
	select arit.attribute_label_long
	from   ak_region_items_tl arit,
	       ak_region_items ari
	where
	    arit.region_application_id = ari.region_application_id
	   and arit.region_code = ari.region_code
	   and arit.attribute_application_id = ari.attribute_application_id
	   and arit.attribute_code = ari.attribute_code
	   and arit.language = userenv('LANG')
	   and ari.region_application_id = p_region_application_id
	   and ari.region_code = p_region_code
	order by display_sequence;

cursor items_base is
        select  a.ATTRIBUTE_LABEL_LONG,a.ATTRIBUTE_CODE
        from    AK_REGION_ITEMS_TL a,
		AK_REGION_ITEMS b,
		FND_LANGUAGES c
        where   b.REGION_APPLICATION_ID = p_region_application_id
        and     b.REGION_CODE = p_region_code
	and	b.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
	and	b.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
	and	a.LANGUAGE = c.LANGUAGE_CODE
	and	c.INSTALLED_FLAG = 'B'
        order by b.DISPLAY_SEQUENCE;

begin

select	NAME
into	p_title
from	AK_REGIONS_VL
where	REGION_APPLICATION_ID = p_region_application_id
and	REGION_CODE = p_region_code;

/*
l_count := 0;
for i in items loop
	l_count := l_count + 1;
	p_prompts(l_count) := i.ATTRIBUTE_LABEL_LONG;
end loop;
*/--changed to support bulk fetch 1574527 mputman
OPEN items;
FETCH items BULK COLLECT INTO p_prompts;
CLOSE items;


l_count:= p_prompts.last;

p_prompts(0) := l_count;
p_prompts(l_count + 1) := '';

exception
        when NO_DATA_FOUND then
	    begin
		select  NAME
		into    p_title
		from    AK_REGIONS_TL a,
			FND_LANGUAGES b
		where   REGION_APPLICATION_ID = p_region_application_id
		and     REGION_CODE = p_region_code
		and	a.LANGUAGE = b.LANGUAGE_CODE
		and	b.INSTALLED_FLAG = 'B' ;

		l_count := 0;
		for i in items_base loop
			l_count := l_count + 1;
			p_prompts(l_count) := i.ATTRIBUTE_LABEL_LONG;
		end loop;
		p_prompts(0) := l_count;
		p_prompts(l_count + 1) := '';
	    exception
		when NO_DATA_FOUND then
			p_title := '';
			p_prompts(0) := 0;
	    end;
end;

function getPrompt( p_region_application_id in number,
                    p_region_code in varchar2,
                    p_attribute_application_id in number,
                    p_attribute_code in varchar2)
                    return varchar2 is
l_prompt varchar2(80);
begin

select  ATTRIBUTE_LABEL_LONG
into	l_prompt
from    AK_REGION_ITEMS_VL
where   REGION_APPLICATION_ID = p_region_application_id
and     REGION_CODE = p_region_code
and	ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and	ATTRIBUTE_CODE = p_attribute_code;

return l_prompt;

exception
        when NO_DATA_FOUND then
            begin
		select  ATTRIBUTE_LABEL_LONG
		into    l_prompt
		from    AK_REGION_ITEMS_TL a,
                        FND_LANGUAGES b
		where   REGION_APPLICATION_ID = p_region_application_id
		and     REGION_CODE = p_region_code
		and     ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
		and     ATTRIBUTE_CODE = p_attribute_code
                and     a.LANGUAGE = b.LANGUAGE_CODE
                and     b.INSTALLED_FLAG = 'B' ;

                return l_prompt;
            exception
                when NO_DATA_FOUND then
                        l_prompt := '';
			return l_prompt;
            end;
end;

procedure getLookups( p_lookup_type in varchar2,
                      p_lookup_codes out NOCOPY g_lookup_code_table,
                      p_lookup_meanings out NOCOPY g_lookup_meaning_table) is

cursor lookups is
	select	LOOKUP_CODE,MEANING
	from	FND_LOOKUPS
	where	LOOKUP_TYPE = p_lookup_type
	and	ENABLED_FLAG = 'Y'
	and	sysdate >= nvl(START_DATE_ACTIVE,sysdate)
	and	sysdate <= nvl(END_DATE_ACTIVE,sysdate)
	order by LOOKUP_CODE;

l_count			number;

begin

l_count := 0;
for l in lookups loop
	l_count := l_count + 1;
	p_lookup_codes(l_count) := l.LOOKUP_CODE;
	p_lookup_meanings(l_count) := l.MEANING;
end loop;
p_lookup_codes(0) := l_count;
p_lookup_codes(l_count + 1) := '';

end;

procedure getLookup( p_lookup_type in varchar2,
	             p_lookup_code in varchar2,
                     p_meaning out NOCOPY varchar2) is

l_count                 number;

cursor lookups is
        select  MEANING
        from    FND_LOOKUPS
        where   LOOKUP_TYPE = p_lookup_type
	and	LOOKUP_CODE = p_lookup_code;

begin

l_count := 0;
for l in lookups loop
        l_count := l_count + 1;
        p_meaning := l.MEANING;
end loop;

end;

----------------------------------------------------------------------------
  procedure error_page_setup is
----------------------------------------------------------------------------

begin
  error_table := empty_char2000table;
  TOTAL_ERRORS := 0;
end error_page_setup;

----------------------------------------------------------------------------
  procedure add_error(V_ERROR_IN varchar2) is
----------------------------------------------------------------------------

begin
  TOTAL_ERRORS := TOTAL_ERRORS + 1;
  error_table(TOTAL_ERRORS) := V_ERROR_IN;
end add_error;


----------------------------------------------------------------------------
  function error_count
        return number is
----------------------------------------------------------------------------

begin
  return(TOTAL_ERRORS);
end error_count;

----------------------------------------------------------------------------
  procedure error_page_print is
----------------------------------------------------------------------------

  j BINARY_INTEGER;
begin

htp.htmlOpen;
htp.bodyOpen(icx_admin_sig.background);
    FND_MESSAGE.SET_NAME('ICX', 'ICX_ERROR');
    htp.p('<H2>'||FND_MESSAGE.GET || '</H2>');
    htp.p('<ul>');
    for j in 1..TOTAL_ERRORS loop
        htp.p('<li>'||error_table(j));
    end loop;
    htp.p('</ul>');
htp.bodyClose;
htp.htmlClose;

end error_page_print;

----------------------------------------------------------------------------
  procedure no_html_error_page_print is
----------------------------------------------------------------------------

  j BINARY_INTEGER;
begin
    FND_MESSAGE.SET_NAME('ICX', 'ICX_ERROR');
    htp.p(FND_MESSAGE.GET);
    htp.p('---------------------------------------------------------');
    for j in 1..TOTAL_ERRORS loop
        htp.p(error_table(j));
    end loop;
end;

----------------------------------------------------------------------------
  function get_color(v_name in varchar2)
	return varchar2 is
----------------------------------------------------------------------------

  cursor getColor(v_color varchar2) is
	select COLOR_VALUE
	from   ICX_COLORS
	where  NAME = v_color;

  v_value varchar2(30);

begin
  open getColor(v_name);
  fetch getColor into v_value;
  close getColor;

  return(v_value);

end get_color;



procedure parse_string (
	in_str		in	varchar2,
	delimiter	in	varchar2,
	str_part1	out NOCOPY varchar2,
	str_part2	out NOCOPY varchar2) is
    first_str	varchar2(100);
    pos		number;
begin
    pos := instrb(in_str, delimiter);
    if pos = 0 then
	str_part1 := in_str;
	str_part2 := null;
    end if;
    str_part1 := substrb(in_str, 1, pos-1);
    first_str := substrb(in_str, pos+1);
    str_part2 := ltrim(first_str, ' ');
end parse_string;



function  item_flex_seg (
	ri		in 	rowid)
return varchar2 is
    ret_val varchar2(2000) := NULL;
begin
    if (ri is null) then
	return (null);
    else
	/*
	select msi.concatenated_segments
	into ret_val
	from mtl_system_items_kfv msi
	where rowid = ri;
	*/
        return(ret_val);
    end if;
end item_flex_seg;

function  category_flex_seg (
	cat_id		in 	number)
return varchar2 is
    ret_val varchar2(2000) := NULL;
begin
    if (cat_id is null) then
	return (null);
    else
        /*
	select mc.concatenated_segments
	into ret_val
	from mtl_categories_kfv mc
	where category_id = cat_id;
        */
        return(ret_val);
    end if;
end category_flex_seg;


-- The transfer_Row_To_Column utility takes one record returned by an
-- Object Navigator query and changes the record into a pl/sql table
procedure transfer_Row_To_Column(result_record  in  ak_query_pkg.result_rec,
                                 result_table   out NOCOPY icx_util.char240_table) is

begin

                 result_table(1)   := substr(result_record.value1,1,240);
                 result_table(2)   := substr(result_record.value2,1,240);
                 result_table(3)   := substr(result_record.value3,1,240);
                 result_table(4)   := substr(result_record.value4,1,240);
                 result_table(5)   := substr(result_record.value5,1,240);
                 result_table(6)   := substr(result_record.value6,1,240);
                 result_table(7)   := substr(result_record.value7,1,240);
                 result_table(8)   := substr(result_record.value8,1,240);
                 result_table(9)   := substr(result_record.value9,1,240);
                 result_table(10)  := substr(result_record.value10,1,240);
                 result_table(11)  := substr(result_record.value11,1,240);
                 result_table(12)  := substr(result_record.value12,1,240);
                 result_table(13)  := substr(result_record.value13,1,240);
                 result_table(14)  := substr(result_record.value14,1,240);
                 result_table(15)  := substr(result_record.value15,1,240);
                 result_table(16)  := substr(result_record.value16,1,240);
                 result_table(17)  := substr(result_record.value17,1,240);
                 result_table(18)  := substr(result_record.value18,1,240);
                 result_table(19)  := substr(result_record.value19,1,240);
                 result_table(20)  := substr(result_record.value20,1,240);
                 result_table(21)  := substr(result_record.value21,1,240);
                 result_table(22)  := substr(result_record.value22,1,240);
                 result_table(23)  := substr(result_record.value23,1,240);
                 result_table(24)  := substr(result_record.value24,1,240);
                 result_table(25)  := substr(result_record.value25,1,240);
                 result_table(26)  := substr(result_record.value26,1,240);
                 result_table(27)  := substr(result_record.value27,1,240);
                 result_table(28)  := substr(result_record.value28,1,240);
                 result_table(29)  := substr(result_record.value29,1,240);
                 result_table(30)  := substr(result_record.value30,1,240);
                 result_table(31)  := substr(result_record.value31,1,240);
                 result_table(32)  := substr(result_record.value32,1,240);
                 result_table(33)  := substr(result_record.value33,1,240);
                 result_table(34)  := substr(result_record.value34,1,240);
                 result_table(35)  := substr(result_record.value35,1,240);
                 result_table(36)  := substr(result_record.value36,1,240);
                 result_table(37)  := substr(result_record.value37,1,240);
                 result_table(38)  := substr(result_record.value38,1,240);
                 result_table(39)  := substr(result_record.value39,1,240);
                 result_table(40)  := substr(result_record.value40,1,240);
                 result_table(41)  := substr(result_record.value41,1,240);
                 result_table(42)  := substr(result_record.value42,1,240);
                 result_table(43)  := substr(result_record.value43,1,240);
                 result_table(44)  := substr(result_record.value44,1,240);
                 result_table(45)  := substr(result_record.value45,1,240);
                 result_table(46)  := substr(result_record.value46,1,240);
                 result_table(47)  := substr(result_record.value47,1,240);
                 result_table(48)  := substr(result_record.value48,1,240);
                 result_table(49)  := substr(result_record.value49,1,240);
                 result_table(50)  := substr(result_record.value50,1,240);
                 result_table(51)  := substr(result_record.value51,1,240);
                 result_table(52)  := substr(result_record.value52,1,240);
                 result_table(53)  := substr(result_record.value53,1,240);
                 result_table(54)  := substr(result_record.value54,1,240);
                 result_table(55)  := substr(result_record.value55,1,240);
                 result_table(56)  := substr(result_record.value56,1,240);
                 result_table(57)  := substr(result_record.value57,1,240);
                 result_table(58)  := substr(result_record.value58,1,240);
                 result_table(59)  := substr(result_record.value59,1,240);
                 result_table(60)  := substr(result_record.value60,1,240);
                 result_table(61)  := substr(result_record.value61,1,240);
                 result_table(62)  := substr(result_record.value62,1,240);
                 result_table(63)  := substr(result_record.value63,1,240);
                 result_table(64)  := substr(result_record.value64,1,240);
                 result_table(65)  := substr(result_record.value65,1,240);
                 result_table(66)  := substr(result_record.value66,1,240);
                 result_table(67)  := substr(result_record.value67,1,240);
                 result_table(68)  := substr(result_record.value68,1,240);
                 result_table(69)  := substr(result_record.value69,1,240);
                 result_table(70)  := substr(result_record.value70,1,240);
                 result_table(71)  := substr(result_record.value71,1,240);
                 result_table(72)  := substr(result_record.value72,1,240);
                 result_table(73)  := substr(result_record.value73,1,240);
                 result_table(74)  := substr(result_record.value74,1,240);
                 result_table(75)  := substr(result_record.value75,1,240);
                 result_table(76)  := substr(result_record.value76,1,240);
                 result_table(77)  := substr(result_record.value77,1,240);
                 result_table(78)  := substr(result_record.value78,1,240);
                 result_table(79)  := substr(result_record.value79,1,240);
                 result_table(80)  := substr(result_record.value80,1,240);
                 result_table(81)  := substr(result_record.value81,1,240);
                 result_table(82)  := substr(result_record.value82,1,240);
                 result_table(83)  := substr(result_record.value83,1,240);
                 result_table(84)  := substr(result_record.value84,1,240);
                 result_table(85)  := substr(result_record.value85,1,240);
                 result_table(86)  := substr(result_record.value86,1,240);
                 result_table(87)  := substr(result_record.value87,1,240);
                 result_table(88)  := substr(result_record.value88,1,240);
                 result_table(89)  := substr(result_record.value89,1,240);
                 result_table(90)  := substr(result_record.value90,1,240);
                 result_table(91)  := substr(result_record.value91,1,240);
                 result_table(92)  := substr(result_record.value92,1,240);
                 result_table(93)  := substr(result_record.value93,1,240);
                 result_table(94)  := substr(result_record.value94,1,240);
                 result_table(95)  := substr(result_record.value95,1,240);
                 result_table(96)  := substr(result_record.value96,1,240);
                 result_table(97)  := substr(result_record.value97,1,240);
                 result_table(98)  := substr(result_record.value98,1,240);
                 result_table(99)  := substr(result_record.value99,1,240);
                 result_table(100) := substr(result_record.value100,1,240);

end transfer_Row_To_Column;

procedure transfer_Row_To_Column(result_record  in  ak_query_pkg.result_rec,
                                 result_table   out NOCOPY icx_util.char4000_table) is

begin
                  result_table(1)   := result_record.value1;
                  result_table(2)   := result_record.value2;
                  result_table(3)   := result_record.value3;
                  result_table(4)   := result_record.value4;
                  result_table(5)   := result_record.value5;
                  result_table(6)   := result_record.value6;
                  result_table(7)   := result_record.value7;
                  result_table(8)   := result_record.value8;
                  result_table(9)   := result_record.value9;
                  result_table(10)  := result_record.value10;
                  result_table(11)  := result_record.value11;
                  result_table(12)  := result_record.value12;
                  result_table(13)  := result_record.value13;
                  result_table(14)  := result_record.value14;
                  result_table(15)  := result_record.value15;
                  result_table(16)  := result_record.value16;
                  result_table(17)  := result_record.value17;
                  result_table(18)  := result_record.value18;
                  result_table(19)  := result_record.value19;
                  result_table(20)  := result_record.value20;
                  result_table(21)  := result_record.value21;
                  result_table(22)  := result_record.value22;
                  result_table(23)  := result_record.value23;
                  result_table(24)  := result_record.value24;
                  result_table(25)  := result_record.value25;
                  result_table(26)  := result_record.value26;
                  result_table(27)  := result_record.value27;
                  result_table(28)  := result_record.value28;
                  result_table(29)  := result_record.value29;
                  result_table(30)  := result_record.value30;
                  result_table(31)  := result_record.value31;
                  result_table(32)  := result_record.value32;
                  result_table(33)  := result_record.value33;
                  result_table(34)  := result_record.value34;
                  result_table(35)  := result_record.value35;
                  result_table(36)  := result_record.value36;
                  result_table(37)  := result_record.value37;
                  result_table(38)  := result_record.value38;
                  result_table(39)  := result_record.value39;
                  result_table(40)  := result_record.value40;
                  result_table(41)  := result_record.value41;
                  result_table(42)  := result_record.value42;
                  result_table(43)  := result_record.value43;
                  result_table(44)  := result_record.value44;
                  result_table(45)  := result_record.value45;
                  result_table(46)  := result_record.value46;
                  result_table(47)  := result_record.value47;
                  result_table(48)  := result_record.value48;
                  result_table(49)  := result_record.value49;
                  result_table(50)  := result_record.value50;
                  result_table(51)  := result_record.value51;
                  result_table(52)  := result_record.value52;
                  result_table(53)  := result_record.value53;
                  result_table(54)  := result_record.value54;
                  result_table(55)  := result_record.value55;
                  result_table(56)  := result_record.value56;
                  result_table(57)  := result_record.value57;
                  result_table(58)  := result_record.value58;
                  result_table(59)  := result_record.value59;
                  result_table(60)  := result_record.value60;
                  result_table(61)  := result_record.value61;
                  result_table(62)  := result_record.value62;
                  result_table(63)  := result_record.value63;
                  result_table(64)  := result_record.value64;
                  result_table(65)  := result_record.value65;
                  result_table(66)  := result_record.value66;
                  result_table(67)  := result_record.value67;
                  result_table(68)  := result_record.value68;
                  result_table(69)  := result_record.value69;
                  result_table(70)  := result_record.value70;
                  result_table(71)  := result_record.value71;
                  result_table(72)  := result_record.value72;
                  result_table(73)  := result_record.value73;
                  result_table(74)  := result_record.value74;
                  result_table(75)  := result_record.value75;
                  result_table(76)  := result_record.value76;
                  result_table(77)  := result_record.value77;
                  result_table(78)  := result_record.value78;
                  result_table(79)  := result_record.value79;
                  result_table(80)  := result_record.value80;
                  result_table(81)  := result_record.value81;
                  result_table(82)  := result_record.value82;
                  result_table(83)  := result_record.value83;
                  result_table(84)  := result_record.value84;
                  result_table(85)  := result_record.value85;
                  result_table(86)  := result_record.value86;
                  result_table(87)  := result_record.value87;
                  result_table(88)  := result_record.value88;
                  result_table(89)  := result_record.value89;
                  result_table(90)  := result_record.value90;
                  result_table(91)  := result_record.value91;
                  result_table(92)  := result_record.value92;
                  result_table(93)  := result_record.value93;
                  result_table(94)  := result_record.value94;
                  result_table(95)  := result_record.value95;
                  result_table(96)  := result_record.value96;
                  result_table(97)  := result_record.value97;
                  result_table(98)  := result_record.value98;
                  result_table(99)  := result_record.value99;
                  result_table(100) := result_record.value100;

end transfer_Row_To_Column;

---------------------------------------------------------------------
-- DESCRIPTION:
--    DynamicButton generates JavaScript and HTML code that renders
-- a button image using an HTML table, multiple smaller images, and
-- text.  Button text is passed as an argument to the procedure
-- and an illusion is achieved of the text being superimposed on the
-- button.
--
-- PRECONDITION:
--    Should be used by client browsers supporting cell background
-- colors (eg <TD BGCOLOR="#CCCCCC">), such as Netscape 3.0 and
-- MSIE 3.0, but not required.  Center of button will be same as body
-- background if BGCOLOR not supported.  Recommend testing browser
-- version before calling.
--
-- USAGE:
--    Called with the following arguments.
--      P_ButtonText      - Button label text.  (Optional)
--      P_ImageFileName   - Filename of the icon displayed with the text
--      P_OnMouseOverText - Text appearing in status bar when mouse
--                          scrolls over HyperText links
--      P_HyperTextCall   - Call appearing in HREF tag
--      P_LanguageCode    - Language of client (get with getID)
--      P_JavaScriptFlag  - HTML tags are embedded in
--                          document.write and double quotes are
--                          replaced with backslash quote when TRUE,
--                          otherwise raw HTML is returned to client (FALSE).
--	P_DisabledFlag	  - prints label in disabled color when TRUE
--
--
-- EXAMPLE:
--        DynamicButton('First',
--                      'FNDBFRST.gif',
--                      'First Receipt',
--                      'javascript:parent.FirstReceipt(this.form)',
--                      v_lang,
--                      TRUE);
--
---------------------------------------------------------------------
PROCEDURE DynamicButton(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_JavaScriptFlag  boolean,
			P_DisabledFlag	  boolean) IS

  l_ImagePath varchar2(240) := '/OA_MEDIA/';
  l_DisabledColor varchar2(7) := '#999999';
  c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');
  l_ImageFileName varchar2(240);

  PROCEDURE spool (P_text varchar2) IS
  BEGIN
    --
    -- Embed HTML tags within document.write and replace quotes with
    -- backslash quotes if P_JavaScriptFlag = TRUE
    --
    if (P_JavaScriptFlag) then
      htp.p('document.write("'||replace(P_text,'"','\"')||'");');
    else
      htp.p(P_text);
    end if;
  END;

BEGIN
  if instr(P_ImageFileName,'.gif') > 0
  then
    l_ImageFileName := P_ImageFileName;
  else
    l_ImageFileName := P_ImageFileName||'.gif';
  end if;

  spool('<table border=0 cellpadding=0 cellspacing=0 valign=TOP align=left>');

  if (P_ButtonText is not null) then
    spool('<tr><td height=28 width=29 rowspan=5>');
  else
    spool('<tr><td height=28 width=5>');
  end if;

  spool('<!--href is button action, and gif is button graphic-->');
  if P_HyperTextCall is not null then
      spool('<a href="'||P_HyperTextCall||'"');
      spool('onMouseOver="window.status='''||
          replace_onMouseOver_quotes(P_OnMouseOverText)||''' ; return true">');
    spool('<img src="'||l_ImagePath||l_ImageFileName||
        '" align=CENTER height=28 width=29 border=0 alt="'||
	replace_alt_quotes(P_OnMouseOverText)||'"></a></td>');
  else
    spool('<img src="'||l_ImagePath||l_ImageFileName||
        '" align=CENTER height=28 width=29 border=0 alt="'||
        replace_alt_quotes(P_OnMouseOverText)||'"></td>');
  end if;

  if (P_ButtonText is not null) then
    spool('<td height=1 bgcolor=#CCCCCC><img height=1 width=1 src="'||l_ImagePath||'FNDDBPXC.gif" alt="'||replace_alt_quotes(P_OnMouseOverText)||'"></td>');
  end if;

  if (P_ButtonText is not null) then
    spool('<td height=28 width=29 rowspan=5>');
  else
    spool('<td height=28 width=5>');
  end if;

  if P_HyperTextCall is not null then
      spool('<a href="'||P_HyperTextCall||'" ');
      spool('onMouseOver="window.status='''||
          replace_onMouseOver_quotes(P_OnMouseOverText)||''' ; return true">');
    spool('<img src="'||l_ImagePath||
        'FNDDBEND.gif" border=0 height=28 width=7 align=CENTER alt="'||replace_alt_quotes(P_OnMouseOverText)||
         '" ></a></td></tr>');
  else
    spool('<img src="'||l_ImagePath|| 'FNDDBEND.gif" border=0 height=28 width=7 align=CENTER alt="'||replace_alt_quotes(P_OnMouseOverText)||
         '" ></td></tr>');
  end if;

  if (P_ButtonText is not null) then
    spool('<tr><td height=1 bgcolor=#FFFFFF>');
    spool('<img width=1 height=1 src="'|| l_ImagePath||
	  'FNDDBPXW.gif" alt="'||
          replace_alt_quotes(P_OnMouseOverText)||'"></td></tr>');
    spool('<tr align=CENTER valign=MIDDLE><td height=24 valign=MIDDLE bgcolor=#cccccc nowrap>');
    spool('<!--href is button action, and cell text appears on the button-->');
    if P_HyperTextCall is not null then
        spool('<a href="'||P_HyperTextCall||'" valign=MIDDLE ');
        spool('onMouseOver="window.status='''||
            replace_onMouseOver_quotes(P_OnMouseOverText)||''' ; return true">');
    end if;

    if (P_DisabledFlag) then
        spool('<font color=' || l_DisabledColor || '>'||P_ButtonText||
          '</font>');
        if P_HyperTextCall is not null then
	    spool('</a></td></tr>');
 	else
	    spool('</td></tr>');
	end if;
    else
        spool('<font color=#000000>'||P_ButtonText||
          '</font>');
        if P_HyperTextCall is not null then
	    spool('</a></td></tr>');
 	else
	    spool('</td></tr>');
	end if;
    end if;
    spool('<tr><td height=1 bgcolor=#999999>');
    spool('<img width=1 height=1 src="'||
          l_ImagePath||'FNDDBPX9.gif" alt="'||
          replace_alt_quotes(P_OnMouseOverText)||'"></td></tr>');
    spool('<tr><td height=1 bgcolor=#000000>');
    spool('<img width=1 height=1 src="'||
          l_ImagePath||'FNDDBPXB.gif" alt="'||
          replace_alt_quotes(P_OnMouseOverText)||'"></td></tr>');
  end if;

  spool('</table>');
END;

PROCEDURE paintDynamicButton(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_DisabledFlag    boolean) is
l_DisabledFlag varchar2(30);
l_ImageFileName varchar2(240);

begin
if instr(P_ImageFileName,'.gif') > 0
then
  l_ImageFileName := P_ImageFileName;
else
  l_ImageFileName := P_ImageFileName||'.gif';
end if;

if P_DisabledFlag then
    l_DisabledFlag := 'TRUE';
else
    l_DisabledFlag := 'FALSE';
end if;

htp.p('<SCRIPT LANGUAGE="JavaScript">');
htp.p('<!-- Hide from old browsers');
-- dynamicButton(p_text,p_alt,p_over,p_language,p_image,p_url,p_flag);
htp.p('dynamicButton("'||replace_alt_quotes(P_ButtonText)||'","'||replace_alt_quotes(P_OnMouseOverText)||'","'
	||replace(replace_onMouseOver_quotes(P_OnMouseOverText),'\''','\\''')||'","'||P_LanguageCode||'","'||l_ImageFileName||'","'||P_HyperTextCall||'","'||l_DisabledFlag||'")');
htp.p('// -->');
htp.p('</SCRIPT>');

end;

PROCEDURE DynamicButtonIn(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_JavaScriptFlag  boolean,
                        P_DisabledFlag    boolean) IS

  l_ImagePath varchar2(240) := '/OA_MEDIA/';
  l_DisabledColor varchar2(7) := '#999999';
  l_ImageFileName varchar2(240);

  PROCEDURE spool (P_text varchar2) IS
  BEGIN
    --
    -- Embed HTML tags within document.write and replace quotes with
    -- backslash quotes if P_JavaScriptFlag = TRUE

   --
    if (P_JavaScriptFlag) then
      htp.p('document.write("'||replace(P_text,'"','\"')||'");');
    else
      htp.p(P_text);
    end if;
  END;

BEGIN
  if instr(P_ImageFileName,'.gif') > 0
  then
    l_ImageFileName := P_ImageFileName;
  else
    l_ImageFileName := P_ImageFileName||'.gif';
  end if;

  spool('<table border=0 cellpadding=0 cellspacing=0 align=left>');

  if (P_ButtonText is not null) then
    spool('<tr><td height=28 width=29 rowspan=5>');
  else
    spool('<tr><td height=28 width=5>');
  end if;

  spool('<!--href is button action, and gif is button graphic-->');
  if P_HyperTextCall is not null then
    spool('<a href="'||P_HyperTextCall||'" ');
    spool('onMouseOver="window.status='||'&'||'quot;'||
        P_OnMouseOverText||'&'||'quot; ; return true">');
    spool('<img src="'||l_ImagePath||l_ImageFileName||
        '" height=28 width=29 border=0></a></td>');
  else
    spool('<img src="'||l_ImagePath||l_ImageFileName||
        '" height=28 width=29 border=0></td>');
  end if;


  if (P_ButtonText is not null) then
    spool('<td height=1 bgcolor=#000000><img height=1 width=1 src="'||
          l_ImagePath||'FNDDBPXB.gif"></td>');
  end if;

  if (P_ButtonText is not null) then
    spool('<td height=28 width=29 rowspan=5>');
  else
    spool('<td height=28 width=5>');
  end if;

  if P_HyperTextCall is not null then
    spool('<a href="'||P_HyperTextCall||'" ');
    spool('onMouseOver="window.status='||'&'||'quot;'||
        P_OnMouseOverText||'&'||'quot; ; return true">');
    spool('<img src="'||l_ImagePath||
        'FNDDBENI.gif" border=0 height=28 width=7></a></td></tr>');
  else
    spool('<img src="'||l_ImagePath||
        'FNDDBENI.gif" border=0 height=28 width=7></td></tr>');
  end if;

  if (P_ButtonText is not null) then
    spool('<tr><td height=1 bgcolor=#999999>');
    spool('<img width=1 height=1 src="'||
          l_ImagePath||'FNDDBPX9.gif"></td></tr>');
    spool('<tr><td height=24 align=center valign=center'||
          ' bgcolor=#cccccc nowrap>');
    spool('<!--href is button action, and cell text appears on the button-->');
    if P_HyperTextCall is not null then
      spool('<a href="'||P_HyperTextCall||'" ');
      spool('onMouseOver="window.status='||'&'||'quot;'||
          P_OnMouseOverText||'&'||'quot; ; return true">');
    end if;

    if (P_DisabledFlag) then
        spool('<font color=' || l_DisabledColor || '>'||P_ButtonText||
        '</font>');
        if P_HyperTextCall is not null then
            spool('</a></td></tr>');
        else
            spool('</td></tr>');
        end if;
    else
        spool('<font color=#000000>'||P_ButtonText||
          '</font>');
        if P_HyperTextCall is not null then
            spool('</a></td></tr>');
        else
            spool('</td></tr>');
        end if;
    end if;
    spool('<tr><td height=1 bgcolor=#FFFFFF>');
    spool('<img width=1 height=1 src="'||
          l_ImagePath||'FNDDBPXW.gif"></td></tr>');
    spool('<tr><td height=1 bgcolor=#E1E1E1>');
    spool('<img width=1 height=1 src="'||
          l_ImagePath||'FNDDBPXE.gif"></td></tr>');
  end if;
  spool('</table>');
END dynamicbuttonin;



function replace_jsdw_quotes(p_string in varchar2) return varchar2 is

temp_string varchar2(2000);

begin

-- replace single quotes
temp_string := replace(p_string,'''','\''');

-- replace double quotes
-- temp_string := replace(temp_string,'"','&quot;');
temp_string := replace(temp_string,'"','\"');

return temp_string;

end replace_jsdw_quotes;



function replace_quotes(p_string in varchar2) return varchar2 is

temp_string varchar2(2000);

begin

-- replace single quotes
temp_string := replace(p_string,'''','\''');

-- replace double quotes
-- temp_string := replace(temp_string,'"','&quot;');
temp_string := replace(temp_string,'"','\"');

-- check for double escapes
temp_string := replace(temp_string,'\\','\');

return temp_string;

end replace_quotes;




function replace_onMouseOver_quotes(p_string in varchar2) return varchar2 is

temp_string varchar2(2000);
c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

begin

-- replace single quotes
temp_string := replace(p_string,'''','\''');

/*
-- replace double quotes
if (instr(c_browser, 'MSIE') <> 0) then
    temp_string := replace(temp_string,'"','\''');
else
    temp_string := replace(temp_string,'"','&quot;');
end if;
*/
temp_string := replace(temp_string,'"','&quot;');

-- check for double escapes
temp_string := replace(temp_string,'\\','\');

return temp_string;

end replace_onMouseOver_quotes;

function replace_alt_quotes(p_string in varchar2) return varchar2 is

temp_string varchar2(2000);

begin

-- replace double quotes
temp_string := replace(p_string,'"','&quot;');

-- check for double escapes
temp_string := replace(temp_string,'\\','\');

return temp_string;

end replace_alt_quotes;

end icx_util;

/
