--------------------------------------------------------
--  DDL for Package Body ICX_REQ_UPDATE_SAVED_CARTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_UPDATE_SAVED_CARTS" as
/* $Header: ICXRQUPB.pls 115.4 99/07/17 03:23:42 porting ship $ */

------------------------------------------------------
procedure cartSearch is
------------------------------------------------------
  c_language varchar2(30);
begin
  c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


-- Check if session is valid
 if (icx_sec.validatesession('ICX_UPDATE_SAVED_CARTS')) then


   icx_on_utilities.FindPage(p_region_appl_id => 601,
                             p_region_code    => 'ICX_SAVED_CARTS_R',
                             p_goto_url       => 'ICX_REQ_UPDATE_SAVED_CARTS.displaySavedCarts',
                             p_lines_now      => 1,
                             p_lines_next     => 5,
                             p_new_url        => 'ICX_REQ_NAVIGATION.ic_parent?cart_id=' || icx_call.encrypt2('0'),
                             p_help_url => '/OA_DOC/' || c_language || '/awe' || '/icxhlprq.htm'
                            );

 end if;
end;


------------------------------------------------------
procedure displaySavedCarts(a_1 in varchar2 default null,
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
                            p_where in varchar2 default null ) is
------------------------------------------------------

sess_web_user         number(15);
c_language            varchar2(30);
c_title               varchar2(80);
c_prompts             icx_util.g_prompts_table;
where_clause          varchar2(2000);
total_rows            number;
end_row               number;
c_query_size          number;
i                     number := 0;
r                     number := 0;
display_text          varchar2(240);
condensed_params      varchar2(20);
y_table               icx_util.char240_table;
l_encrypted_where     number;
g_reg_ind             number;
c_message             varchar2(2000);
err_num               number;
err_mesg              varchar2(240);
l_cart_id_value_id    number;
l_cart_name_value_id  number;
l_emergency_flag_value_id number;
l_emergency		varchar2(30);

/* New vars to use the Bind vars logic **/
 l_where_binds  ak_query_pkg.bind_tab;
 l_where_clause varchar2(2000);
 v_index        number;

begin

if icx_sec.validateSession('ICX_UPDATE_SAVED_CARTS') then

        sess_web_user := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
        c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

        icx_util.getPrompts(601,'ICX_SAVED_CARTS_R',c_title,c_prompts);
        icx_util.error_page_setup;

        htp.htmlOpen;
        htp.headOpen;
            icx_util.copyright;
            js.scriptOpen;
            htp.p('function help_window() {
            help_win = window.open(''/OA_DOC/' || c_language || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250");
            help_win = window.open(''/OA_DOC/' || c_language || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250")} ');

            htp.p('function saved_cart_rows(start_num, end_num, param_id) {
                document.DISPLAY_PACKPROC.p_start_row.value = start_num
                document.DISPLAY_PACKPROC.p_end_row.value = end_num
                document.DISPLAY_PACKPROC.parameters_id.value = param_id
                document.DISPLAY_PACKPROC.submit()
            }');


--            FND_MESSAGE.SET_TOKEN('OBJECT_TO_DELETE_TOKEN', '???');
--            FND_MESSAGE.SET_NAME('ICX', 'ICX_DELETE_OBJECT');
            htp.p('function delete_saved_cart(delete_name, condensed_params) {
                //if (confirm("' || FND_MESSAGE.GET || '") ) {
                //if (confirm("Are you sure you want to delete requisition # "+delete_name+"?"))      {
		    if (confirm(delete_name))      {
                     parent.location="ICX_REQ_UPDATE_SAVED_CARTS.deleteSavedCarts?condensed_params=" + condensed_params
                }
            }');
            js.scriptClose;
            htp.title(c_title);
        htp.headClose;

        /* get number of rows to display */
        select QUERY_SET into c_query_size
        from ICX_PARAMETERS;

        if p_where is not null then
            where_clause := icx_call.decrypt2(p_where);
            icx_on_utilities.unpack_whereSegment(where_clause,l_where_clause,l_where_binds);
        else
            where_clause := icx_on_utilities.whereSegment(a_1,c_1,i_1,a_2,c_2,i_2,a_3,c_3,i_3,a_4,c_4,i_4,a_5,c_5,i_5);

            icx_on_utilities.unpack_whereSegment(where_clause, l_where_clause, l_where_binds);
   --         if where_clause is not null then
              if l_where_clause is not null then

           /* added to take care of Bind vars Bug **/

   --               where_clause := where_clause || ' AND ';
                  l_where_clause := l_where_clause || ' AND ';
            end if;
    --        where_clause := where_clause || 'SHOPPER_ID=' || sess_web_user ||
    --                        ' AND ( SAVED_FLAG = ''1'' OR SAVED_FLAG= ''4'')';
           l_where_clause := l_where_clause || 'SHOPPER_ID= :ICXBIND0 AND ( SAVED_FLAG = ''1'' OR SAVED_FLAG= ''4'')';

           v_index := l_where_binds.COUNT;
           l_where_binds(v_index).name := 'ICXBIND0';
           l_where_binds(v_index).value := sess_web_user;

           where_clause := l_where_clause;

           if l_where_binds.count > 0 then

           for i in  l_where_binds.first .. l_where_binds.last LOOP
           where_clause := where_clause || '*' || l_where_binds(i).value;
           end loop;

           end if;

           where_clause := where_clause || '**]';

           l_encrypted_where := icx_call.encrypt2(where_clause);

           end if;


/* old code - 1/21/97 */
--        if (where_clause is not null ) then
--               where_clause := where_clause || ' AND ';
--        end if;
--        where_clause :=  where_clause || 'SHOPPER_ID=' || sess_web_user;

        -- Only display save (1) and errored carts (4).
--        where_clause :=  where_clause || ' AND ( SAVED_FLAG=''1'' OR SAVED_FLAG=''4'') ';
/* old code - 1/21/97 */


        htp.comment(where_clause);

     -- set up end rows to display
     if p_end_row is null then
        end_row := c_query_size;
     else
        end_row := p_end_row;
     end if;

     ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => 'ICX_SAVED_CARTS_R',
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
--                              P_WHERE_CLAUSE          => where_clause,
                                P_WHERE_CLAUSE          => l_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F',
			        P_RANGE_LOW             => p_start_row,
				P_RANGE_HIGH            => end_row,
                                P_WHERE_BINDS           => l_where_binds);


        /* get number of total rows returned by lov to be used to determine if
        we need to display the next/previous buttons */

        g_reg_ind := ak_query_pkg.g_regions_table.FIRST;
        total_rows := ak_query_pkg.g_regions_table(g_reg_ind).total_result_count;
        if end_row > total_rows then
            end_row := total_rows;
        end if;

        icx_admin_sig.toolbar(language_code => c_language,
                              disp_find => 'icx_req_update_saved_carts.cartSearch');
        htp.formOpen('ICX_REQ_UPDATE_SAVED_CARTS.displaySavedCarts','POST','','','NAME="DISPLAY_SAVED_CARTS"');


        i := 0;

        if ak_query_pkg.g_results_table.COUNT > 0  then
            htp.tableOpen('BORDER=0');
            htp.tableRowOpen;
                htp.tableData('<H2>'||c_title||'</H2>');
            htp.tableRowClose;
            htp.tableClose;
            if p_start_row <> 1 or end_row <> total_rows
            then
                icx_on_utilities2.displaySetIcons(c_language,'icx_req_update_saved_carts.displaySavedCarts',p_start_row,end_row,l_encrypted_where,c_query_size,total_rows);
            end if;
        end if;


        if ak_query_pkg.g_results_table.COUNT = 0 then
            fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
            fnd_message.set_token('NAME_OF_REGION_TOKEN',c_title);
            htp.p('<H3>'||fnd_message.get||'</H3>');
        else
            htp.tableOpen('BORDER=4');
            htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER')||'">');
            for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
                if ak_query_pkg.g_items_table(i).secured_column = 'F'
                and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                then
                    htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long);
                end if;

                if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CART_ID' then
                    l_cart_id_value_id := ak_query_pkg.g_items_table(i).value_id;
                end if;
		if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EMERGENCY_FLAG' then
		    l_emergency_flag_value_id := ak_query_pkg.g_items_table(i).value_id;
		end if;
                if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_NUMBER_SEG1' then
                    l_cart_name_value_id := ak_query_pkg.g_items_table(i).value_id;
                end if;

            end loop;
            htp.tableData('');
            htp.tableRowClose;
            for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
--            if r >= p_start_row-1 and r <= end_row-1
--            then
            icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),y_table);
            htp.tableRowOpen;
            for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop
            if ak_query_pkg.g_items_table(i).secured_column = 'F'
            and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
            then
                if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_NUMBER_SEG1' then

		    if (y_table(l_emergency_flag_value_id) = 'N') OR
		        (y_table(l_emergency_flag_value_id) IS NULL) then
			l_emergency := 'NO';
		    else
			l_emergency := 'YES';
		    end if;

                    htp.tableData(htf.anchor('icx_req_navigation.ic_parent?cart_id='|| icx_call.encrypt2(y_table(l_cart_id_value_id)) ||'&'||'emergency='||icx_call.encrypt2(l_emergency),
                                  y_table(ak_query_pkg.g_items_table(i).value_id),'','onMouseOver="return true"'));

                --Display status falg in plain ENGLISH
                elsif (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SAVED_FLAG') then
                              if ( y_table(ak_query_pkg.g_items_table(i).value_id) = '4' ) then

                                 -- display_text := 'Error';
                                 FND_MESSAGE.SET_NAME('FND','AFDICT_ERROR_TITLE');
		                 display_text := FND_MESSAGE.GET;

                              elsif ( y_table(ak_query_pkg.g_items_table(i).value_id) = '1' ) then

                                        FND_MESSAGE.SET_NAME('ICX','ICX_SAVED');
				        display_text := FND_MESSAGE.GET;
                              else

                                        FND_MESSAGE.SET_NAME('ICX','ICX_UNKNOWN');
					display_text := FND_MESSAGE.GET;
                              end if;
                              htp.tableData(display_text);

                --Display delete button
                elsif (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELETE') then
                              condensed_params := icx_call.encrypt2( y_table(l_cart_id_value_id) ||'*'|| p_start_row||'*'||end_row||'*'||l_encrypted_where||'**]');





                    FND_MESSAGE.SET_NAME('ICX', 'ICX_DELETE_OBJECT');
                    FND_MESSAGE.SET_TOKEN('OBJECT_TO_DELETE_TOKEN', y_table(l_cart_name_value_id));


                              htp.tableData(htf.anchor('javascript:delete_saved_cart('''||icx_util.replace_quotes(FND_MESSAGE.GET) ||''','''||condensed_params||''')',
htf.img('/OA_MEDIA/'||c_language||'/FNDIDELR.gif','CENTER','','','border=no width=17 height=16'),'','onMouseOver="return true"'));

                else
                      if ak_query_pkg.g_items_table(i).value_id is null then
                           htp.tableData('');
                      else
                           if (y_table(ak_query_pkg.g_items_table(i).value_id) is not null) then
                                     htp.tableData(y_table(ak_query_pkg.g_items_table(i).value_id));
                           else
                                     htp.tableData(htf.br);
                           end if;
                      end if;
                end if;
            end if;
            end loop; -- items

            htp.tableRowClose;
--            end if;   -- < p_start_row -1
            end loop; -- Results
            htp.tableClose;
        end if;

--        if p_start_row <> 1 or end_row <> total_rows
--        then
            icx_on_utilities2.displaySetIcons(c_language,'icx_req_update_saved_carts.displaySavedCarts',p_start_row,end_row,l_encrypted_where,c_query_size,total_rows,FALSE);
--        end if;
        htp.formClose;
        icx_admin_sig.footer;
        htp.htmlClose;

end if;  -- validate session

exception
    when others then
        err_num := SQLCODE;
        c_message := SQLERRM;
        select substr(c_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end displaySavedCarts;


------------------------------------------------------
procedure deleteSavedCarts(condensed_params in number default null) is
------------------------------------------------------
v_cart_id   number;
Y           varchar2(2000);
params      icx_on_utilities.v80_table;

Begin

   if icx_sec.validateSession('ICX_UPDATE_SAVED_CARTS') then

            Y := icx_call.decrypt2(condensed_params);
            icx_on_utilities.unpack_parameters(Y, params);

            v_cart_id := params(1);

            /* Delete all cart lines */
            delete from icx_shopping_cart_lines
            Where cart_id = v_cart_id;

            /* Delete cart header */
            delete from icx_shopping_carts
            where cart_id = v_cart_id;

	    delete icx_cart_line_distributions
	    where cart_id = v_cart_id;

	    delete icx_cart_distributions
	    where cart_id = v_cart_id;

            ICX_REQ_UPDATE_SAVED_CARTS.displaySavedCarts(p_start_row => params(2),
                                                         p_end_row => params(3),
                                                         p_where => params(4));
   end if;
End;


end ICX_REQ_UPDATE_SAVED_CARTS;

/
