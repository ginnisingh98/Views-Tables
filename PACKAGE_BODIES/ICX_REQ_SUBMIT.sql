--------------------------------------------------------
--  DDL for Package Body ICX_REQ_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_SUBMIT" as
/* $Header: ICXRQSMB.pls 115.5 99/07/17 03:23:22 porting sh $ */

-------------------------------------------------------------
procedure storeerror(v_cart_id IN NUMBER, v_message IN VARCHAR2,v_distribution_num IN NUMBER default NULL,v_cart_line_id IN NUMBER default NULL) is
-------------------------------------------------------------
  l_error_id NUMBER;
  l_err_num NUMBER;
  l_error_message VARCHAR2(2000);
  l_err_mesg VARCHAR2(240);

  l_shopper_id NUMBER;

begin

  l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  select icx_req_cart_errors_s.nextval into l_error_id from dual;

 /* append new message to the error table for redisplay */
  insert into icx_req_cart_errors
  (error_id,cart_id,distribution_num,cart_line_id,last_updated_by,last_update_date,last_update_login,creation_date,created_by,error_text)
  values(l_error_id,v_cart_id,v_distribution_num,v_cart_line_id,null,sysdate,l_shopper_id,sysdate,l_shopper_id,v_message);


exception
when others then
   l_err_num := SQLCODE;
   l_error_message := SQLERRM;

   select substr(l_error_message,12,512) into l_err_mesg from dual;
   icx_util.add_error(l_err_mesg);
end;


------------------------------------------------------------
procedure become_top(n_cart_id varchar2,
		     v_emergency varchar2,
		     user_action varchar2) is
------------------------------------------------------------

begin
	htp.p('<BODY onLoad="open(''ICX_REQ_SUBMIT.show_end?n_cart_id=' ||
	      n_cart_id || '&v_emergency=' || v_emergency ||
	      '&user_action=' || user_action || ''', ''_top'')">');
end;


------------------------------------------------------------
procedure display_read_only_my_order( cart_id number,p_emergency varchar2 ) is
------------------------------------------------------------

vvalue             varchar2(240);
v_regions_table    ak_query_pkg.regions_table_type;
v_items_table      ak_query_pkg.items_table_type;
v_results_table    ak_query_pkg.results_table_type;

shopper_id         number;

v_where_clause     varchar2(240);
y_table            icx_util.char240_table;
l_value		   varchar2(240);
i                  number := 0;
j                  number := 0;
column_number      number := 0;
v_order_total      number := 0;
v_unit_price       number := 0;
v_quantity         number := 0;
v_header_region    varchar2(100);
v_lines_region     varchar2(100);
v_lang	           varchar2(5);

col_no             number := 1;
v_ext_price_is_on  boolean := FALSE;

v_total_h_align    varchar2(100);
v_total_v_align    varchar2(100);

v_location_id          number;
v_location_code        varchar2(20);
v_item_number          varchar2(80) := null;
v_item_id              number := null;
v_dest_org_id          number := null;
v_org	               number;
v_requestor_id         number := null;
v_requestor_name       varchar2(240) := null;
v_currency             varchar2(30);
v_precision            number;
v_money_fmt_mask       varchar2(32);

/* Change wrto Bug Fix to implement the Bind Vars **/
  where_clause_binds      ak_query_pkg.bind_tab;
  where_clause_binds_empty     ak_query_pkg.bind_tab;
  v_index                 NUMBER;


   cursor getLoccd(locid number) is
          select hrl.location_code
          from hr_locations hrl,
               org_organization_definitions ood,
               financials_system_parameters fsp
          where hrl.location_id = locid
          and ood.organization_id = nvl(hrl.inventory_organization_id,
				        fsp.inventory_organization_id)
          and sysdate < nvl(hrl.inactive_date,sysdate + 1);

   cursor requestor_name(v_employee_id number) is
          select full_name
          from   HR_EMPLOYEES_CURRENT_V
          where  employee_id = v_employee_id;

   cursor item_names(id number, org number) is
        select concatenated_segments
        from   mtl_system_items_kfv
        where  INVENTORY_ITEM_ID = id
        and    ORGANIZATION_ID = org;

   cursor getCurrency is
   select gsob.CURRENCY_CODE,
          fc.PRECISION
   from   gl_sets_of_books gsob,
          FND_CURRENCIES fc,
          org_organization_definitions ood
   where  ood.ORGANIZATION_ID = v_org
   and    fc.CURRENCY_CODE = gsob.CURRENCY_CODE
   and    ood.SET_OF_BOOKS_ID = gsob.SET_OF_BOOKS_ID;

   v_cart_id number;

l_cart_line_id_value number;
v_vendor_LOV_flag varchar2(1);
v_location_LOV_flag varchar2(1);

begin

     -- clean up errors
     v_cart_id := cart_id;
     v_index := 1;

     delete icx_req_cart_errors
     where cart_id = v_cart_id;

     -- get shopper id
     shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
     -- get lang
     v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

     if p_emergency = 'YES' then
           v_header_region := 'ICX_SHOPPING_CART_HEADER_EMG_R';
           v_lines_region  := 'ICX_SHOPPING_CART_LINES_EMG_R';
     else
           v_header_region := 'ICX_SHOPPING_CART_HEADER_R';
           v_lines_region := 'ICX_SHOPPING_CART_LINES_R';
     end if;


     -- Where clause
--     v_where_clause := 'SHOPPER_ID = ' || shopper_id || 'AND CART_ID = ' || cart_id;
     v_where_clause := 'SHOPPER_ID = :shopper_id_bin AND CART_ID = :cart_id_bin';
/* added code to take care of Bind vars Bug **/
  where_clause_binds(v_index).name := 'shopper_id_bin';
  where_clause_binds(v_index).value := shopper_id;
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'cart_id_bin';
  where_clause_binds(v_index).value := cart_id;
  v_index := v_index + 1;



     htp.hr;

     -- Cart Header Related Object Navigator
     -- ^^^^^^^^^^
     --
     ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_header_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F',
                                P_WHERE_BINDS           => where_clause_binds);

     -- Draw cart header.
     htp.tableOpen( 'border=0' );

     icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(ak_query_pkg.g_results_table.first), y_table) ;

     /* get org ahead of time */
     for k in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop
         if ak_query_pkg.g_items_table(k).attribute_code = 'ICX_DEST_ORG_ID' then
            v_org := y_table(ak_query_pkg.g_items_table(k).value_id);
            exit;
         end if;
     end loop;

     v_currency := NULL;
     if v_org is not NULL then

        ICX_REQ_NAVIGATION.get_currency(v_org, v_currency, v_precision, v_money_fmt_mask);
        v_money_fmt_mask := FND_CURRENCY.GET_FORMAT_MASK(v_currency,30);
     end if;


     for i in ak_query_pkg.g_items_table.first  ..  ak_query_pkg.g_items_table.last loop


       if ( ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' and
            ak_query_pkg.g_items_table(i).node_display_flag = 'Y' ) OR
           (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID'  OR
            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR_ID' OR
	    ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DEST_ORG_ID') then

              if ak_query_pkg.g_items_table(i).value_id is not null  then   -- It is an object attribute

                if(ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DEST_ORG_ID') then
                      v_org := y_table(ak_query_pkg.g_items_table(i).value_id);
                elsif(ak_query_pkg.g_items_table(i).attribute_code =
                    'ICX_DELIVER_TO_LOCATION_ID') then
                      -- get the location id to find the location code
                      v_location_id := y_table(ak_query_pkg.g_items_table(i).value_id);
                elsif (ak_query_pkg.g_items_table(i).attribute_code =
                    'ICX_DELIVER_TO_REQUESTOR_ID') then
                      v_requestor_id := y_table(ak_query_pkg.g_items_table(i).value_id);
                else
                     htp.tableRowOpen;
                     htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long, calign => 'RIGHT', cattributes=>'VALIGN=CENTER');
    	             htp.tableData(cvalue => '&nbsp');
                     htp.p('<TD border=1 bgcolor=#FFFFFF>');
                     htp.p('<B>');
                     if ak_query_pkg.g_items_table(i).italic = 'Y' then
                        htp.p('<I>');
                     end if;
                     htp.p(y_table(ak_query_pkg.g_items_table(i).value_id));
                     if ak_query_pkg.g_items_table(i).italic = 'Y' then
                        htp.p('</I>');
                     end if;
                     htp.p('</B>');

                     htp.tableRowClose;
                end if;

              else
                -- this is a regular attribute

                if(ak_query_pkg.g_items_table(i).attribute_code =
                    'ICX_DELIVER_TO_LOCATION') then
                      open getLoccd(v_location_id);
                      fetch getLoccd into v_location_code;
                      close getLoccd;
                      htp.tableRowOpen;
                      htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long, calign => 'RIGHT', cattributes=>'VALIGN=CENTER');
    	              htp.tableData(cvalue => '&nbsp');
                      htp.p('<TD border=1 bgcolor=#FFFFFF>');
                      if ak_query_pkg.g_items_table(i).bold = 'Y' then
                         htp.p('<B>');
                      end if;
                      if ak_query_pkg.g_items_table(i).italic = 'Y' then
                         htp.p('<I>');
                      end if;
                      htp.p(v_location_code);
                      if ak_query_pkg.g_items_table(i).italic = 'Y' then
                         htp.p('</I>');
                      end if;
                      if ak_query_pkg.g_items_table(i).bold = 'Y' then
                         htp.p('</B>');
                      end if;
                      htp.tableRowClose;
                elsif(ak_query_pkg.g_items_table(i).attribute_code =
                    'ICX_DELIVER_TO_REQUESTOR') then
                      open requestor_name(v_requestor_id);
                      fetch requestor_name into v_requestor_name;
                      close requestor_name;
                      htp.tableRowOpen;
                      htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long, calign => 'RIGHT', cattributes=>'VALIGN=CENTER');
    	              htp.tableData(cvalue => '&nbsp');
                      htp.p('<TD border=1 bgcolor=#FFFFFF>');
                      if ak_query_pkg.g_items_table(i).bold = 'Y' then
                         htp.p('<B>');
                      end if;
                      if ak_query_pkg.g_items_table(i).italic = 'Y' then
                         htp.p('<I>');
                      end if;
                      htp.p(v_requestor_name);
                      if ak_query_pkg.g_items_table(i).italic = 'Y' then
                         htp.p('</I>');
                      end if;
                      if ak_query_pkg.g_items_table(i).bold = 'Y' then
                         htp.p('</B>');
                      end if;
                      htp.tableRowClose;
                end if;

              end if;

       end if;

     end loop;

  htp.tableClose;
  htp.p('<BR>');

     -- Cart Lines Related Object Navigator
     -- ^^^^^^^^^^
     --
     ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_lines_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F',
                                P_WHERE_BINDS            => where_clause_binds);

     -- Preprocess and mask the required flags for mandatory fields

--     ICX_REQ_ORDER.ak_mandatory_setup(l_cart_line_id_value,v_vendor_LOV_flag,v_location_LOV_flag);

     -- Draw cart lines.

     htp.tableOpen('BORDER=5', cattributes=> 'bgcolor="#F8F8F8"');

     -- PrintHead
     htp.p('<TR BGCOLOR="#' || icx_util.get_color('TABLE_HEADER') || '">');

     col_no := 0;
     for i in 0 .. ak_query_pkg.g_items_table.LAST loop
        if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        and ak_query_pkg.g_items_table(i).secured_column = 'F'
        then
	    if ak_query_pkg.g_items_table(i).item_style = 'HIDDEN'
	    or ak_query_pkg.g_items_table(i).item_style = 'IMAGE'
	    then
		null;
	    else
                if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' or
	          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
                  htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long || ' (' || v_currency || ')', calign => 'CENTER');
                else
	          htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long, calign => 'CENTER');
                end if;

		col_no := col_no + 1;
		if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE'
		then
		    v_ext_price_is_on := TRUE;
		    column_number := col_no;
		end if;
	    end if;
	end if;
     end loop;
     htp.p('</TR><TR></TR><TR></TR><TR></TR>');
     -- end PrintHead;

     -- PrintItems
     v_order_total := 0;
     if ak_query_pkg.g_regions_table(0).total_result_count > 0  then
     for j in 0 .. ak_query_pkg.g_results_table.last  loop
        icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(j), y_table);

        htp.tableRowOpen;
        for i in 0 .. ak_query_pkg.g_items_table.LAST loop
        if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        and ak_query_pkg.g_items_table(i).secured_column = 'F'
        then
            if ak_query_pkg.g_items_table(i).item_style = 'HIDDEN'
	    or ak_query_pkg.g_items_table(i).item_style = 'IMAGE'
            then
                null;
            else
                if ak_query_pkg.g_items_table(i).value_id is null
                then
                    l_value := '';
                else
                    l_value := y_table(ak_query_pkg.g_items_table(i).value_id);

                    /* compute price total */
                    if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE'
		    then
                        v_order_total := v_order_total + to_number(nvl(l_value,0));
			l_value := to_char(to_number(l_value),v_money_fmt_mask);
		    end if;
                end if;

                htp.tableData(cvalue => icx_on_utilities.formatText(l_value,ak_query_pkg.g_items_table(i).bold,ak_query_pkg.g_items_table(i).italic),
		calign => ak_query_pkg.g_items_table(i).horizontal_alignment, cattributes => 'VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'"');

            end if;
         end if;
         end loop;

         htp.tableRowClose;

    end loop;
    end if;

     -- End PrintItems

    if v_ext_price_is_on then
      -- PrintTotal
       --
       -- Try to place total under extended price
       --

       htp.p('<TR></TR><TR></TR><TR></TR>');

       htp.p('<TR>');
       for i in 1 .. (column_number - 2) loop
             htp.p('<TD></TD>');
       end loop;

       FND_MESSAGE.SET_NAME('MRP','EC_TOTAL');
       htp.p('<TD ALIGN=RIGHT BGCOLOR="#' || icx_util.get_color('TABLE_HEADER')  ||'" >' || FND_MESSAGE.GET || ' (' || v_currency || ') </TD>');
       htp.p('<TD ALIGN="RIGHT">' ||  to_char(to_number(v_order_total),v_money_fmt_mask) || '</TD>' );

      htp.p('</TR>');

     -- End PrintTotal
    end if;

     htp.tableClose;

     -- new order button
     htp.tableOpen('border=0');
      htp.tableRowOpen;
           FND_MESSAGE.SET_NAME('ICX','ICX_REQ_AFTER_SUBMIT');
           htp.p('<TD ALIGN=LEFT>' || FND_MESSAGE.GET || '</TD>');
           htp.p('<TD>');
           htp.p('</TR><TR>');
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('FND','YES');
           icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                                  P_ImageFileName   => 'FNDBNEW.gif',
                                  P_OnMouseOverText => FND_MESSAGE.GET,
                                  P_HyperTextCall   => 'ICX_REQ_NAVIGATION.ic_parent?cart_id=' || icx_call.encrypt2('0') || '&emergency=' || icx_call.encrypt2(p_emergency),
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('FND','NO');
           icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                                  P_ImageFileName   => 'FNDBCNCL.gif',
                                  P_OnMouseOverText => FND_MESSAGE.GET,
                                  P_HyperTextCall   => 'OracleApps.DMM',
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           htp.tableRowClose;
           htp.tableClose;

end display_read_only_my_order;


--**********************************************************
-- END PROCEDURES RELATED TO READ ONLY CART/MY ORDER DISPLAY
--**********************************************************

------------------------------------------------------------
procedure show_end(n_cart_id varchar2,
                   v_emergency varchar2,
                   user_action varchar2) is
------------------------------------------------------------
  v_lang  varchar2(10);

  v_cart_id number;
  v_req_num VARCHAR2(30);


  cursor get_req_num(l_cart_id number) is
	select REQ_NUMBER_SEGMENT1
	from icx_shopping_carts
	where CART_ID = l_cart_id;
begin
  if (icx_sec.validatesession()) then

     -- get lang
     v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     v_cart_id := icx_call.decrypt2(n_cart_id);

   htp.htmlOpen;
   htp.headOpen;
   icx_admin_sig.toolbar(language_code => v_lang);
   icx_util.copyright;
   js.scriptOpen;

      htp.p('function help_window() {
           help_win = window.open(''/OA_DOC/' || v_lang || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250");
            help_win = window.open(''/OA_DOC/' || v_lang || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250")}
');
   js.scriptClose;


   htp.headClose;
   htp.bodyOpen('/OA_MEDIA/' || v_lang || '/ICXBCKGR.jpg');

   if (user_action = 'PO') then
	open get_req_num(v_cart_id);
	fetch get_req_num into v_req_num;
	close get_req_num;
        FND_MESSAGE.SET_NAME('ICX','ICX_REQ_SUBMITTED');
        FND_MESSAGE.SET_TOKEN('REQ_TOKEN',v_req_num);
        htp.p('<b><font size=+1><p></p>' || FND_MESSAGE.GET || '</font><p>');

        display_read_only_my_order(v_cart_id,v_emergency);

        -- call procedure to display read only cart
   elsif (user_action = 'SAVE') then
        FND_MESSAGE.SET_NAME('ICX','ICX_REQ_SAVED_FOR_LATER');
        htp.p('<b><font size=+1><p></p>' || FND_MESSAGE.GET || '</font><p>');

        -- call procedure to display read only  cart
        display_read_only_my_order(v_cart_id,v_emergency);

         htp.comment(user_action);
   elsif (user_action = 'CANCEL') then
        FND_MESSAGE.SET_NAME('ICX','ICX_REQ_PREV_CANCEL');
        htp.p('<b><font size=+1><p></p>' || FND_MESSAGE.GET || '</font><p>');

              htp.tableOpen('border=0');
              htp.tableRowOpen;
              FND_MESSAGE.SET_NAME('ICX','ICX_REQ_AFTER_SUBMIT');
              htp.p('<TD ALIGN=LEFT>' || FND_MESSAGE.GET || '</TD>');
              htp.p('<TD>');
              htp.p('</TR><TR>');
              htp.p('<TD>');
              FND_MESSAGE.SET_NAME('FND','YES');
              icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                                     P_ImageFileName   => 'FNDBNEW.gif',
                                     P_OnMouseOverText => FND_MESSAGE.GET,
                                     P_HyperTextCall   => 'ICX_REQ_NAVIGATION.ic_parent?cart_id=' || icx_call.encrypt2('0') || '&emergency=' || icx_call.encrypt2(v_emergency),
                                     P_LanguageCode    => v_lang,
                                     P_JavaScriptFlag  => FALSE);
              htp.p('</TD>');
              htp.p('<TD>');
              FND_MESSAGE.SET_NAME('FND','NO');
              icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                                     P_ImageFileName   => 'FNDBCNCL.gif',
                                     P_OnMouseOverText => FND_MESSAGE.GET,
                                     P_HyperTextCall   => 'OracleApps.DMM',
                                     P_LanguageCode    => v_lang,
                                     P_JavaScriptFlag  => FALSE);
              htp.p('</TD>');

              htp.tableRowClose;
              htp.tableClose;

   else

   FND_MESSAGE.SET_NAME('ICX', 'ICX_CART_EXIST');
   htp.p('<BODY> ' || FND_MESSAGE.GET);
   htp.p('</BODY>');



   end if;

  htp.bodyClose;
  htp.htmlClose;
 end if;

EXCEPTION
when others then
  htp.p(SQLERRM);


end;


-------------------------------------------------------------
  procedure finalSubmit(user_action  varchar2,
			icx_cart_id              varchar2,
       emergency    IN varchar2 default NULL,
       icx_approver_id          varchar2 default FND_API.G_MISS_CHAR,
       icx_approver_name        varchar2 default FND_API.G_MISS_CHAR,
       icx_deliver_to_location_id varchar2 default FND_API.G_MISS_CHAR,
       icx_deliver_to_requestor_id varchar2 default FND_API.G_MISS_CHAR,
       icx_dest_org_id          varchar2 default FND_API.G_MISS_CHAR,
       icx_shopper_id           varchar2 default FND_API.G_MISS_CHAR,
       icx_deliver_to_location  varchar2 default FND_API.G_MISS_CHAR,
       icx_deliver_to_requestor varchar2 default FND_API.G_MISS_CHAR,
       icx_need_by_date         varchar2 default FND_API.G_MISS_CHAR,
       icx_note_to_approver     varchar2 default FND_API.G_MISS_CHAR,
       icx_note_to_buyer        varchar2 default FND_API.G_MISS_CHAR,
       icx_header_description   varchar2 default FND_API.G_MISS_CHAR,
       icx_req_org_id		varchar2 default FND_API.G_MISS_CHAR,
       icx_req_loc_id		varchar2 default FND_API.G_MISS_CHAR,
       icx_req_loc_cd		varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute1    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute2    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute3    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute4    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute5    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute6    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute7    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute8    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute9    varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute10   varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute11   varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute12   varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute13   varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute14   varchar2 default FND_API.G_MISS_CHAR,
       icx_header_attribute15   varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg1      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg2      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg3      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg4      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg5      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg6      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg7      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg8      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg9      varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg10     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg11     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg12     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg13     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg14     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg15     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg16     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg17     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg18     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg19     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg20     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg21     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg22     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg23     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg24     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg25     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg26     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg27     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg28     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg29     varchar2 default FND_API.G_MISS_CHAR,
       icx_charge_acct_seg30     varchar2 default FND_API.G_MISS_CHAR,
       icx_cart_line_ida       IN defaultParamType default empty_table,
       icx_category_ida       IN defaultParamType default empty_table,
       icx_category_namea     IN defaultParamType default empty_table,
       icx_item_ida           IN defaultParamType default empty_table,
       icx_item_reva     IN defaultParamType default empty_table,
       icx_need_by_datea      IN defaultParamType default empty_table,
       icx_item_descriptiona  IN defaultParamType default empty_table,
       icx_expend_item_datea  IN defaultParamType default empty_table,
       icx_expend_orga         IN defaultParamType default empty_table,
       icx_qty_va             IN defaultParamType default empty_table,
       icx_suggested_buyer_ida IN defaultParamType default empty_table,
       icx_project_ida         IN defaultParamType default empty_table,
       icx_suggested_vendor_contacta IN defaultParamType default empty_table,
       icx_suggested_vendor_item_numa  IN defaultParamType default empty_table,
       icx_suggested_vendor_namea  IN defaultParamType default empty_table,
       icx_suggested_vendor_phonea IN defaultParamType default empty_table,
       icx_suggested_vendor_sitea  IN defaultParamType default empty_table,
       icx_task_ida            IN defaultParamType default empty_table,
       icx_unit_of_measurementa IN defaultParamType default empty_table,
       icx_unit_pricea         IN defaultParamType default empty_table,
       icx_deliver_to_location_id_la IN defaultParamType default empty_table,
       icx_dest_org_id_la      IN defaultParamType default empty_table,
       icx_deliver_to_location_la IN defaultParamType default empty_table,
       icx_line_attribute_1a   IN defaultParamType default empty_table,
       icx_line_attribute_2a   IN defaultParamType default empty_table,
       icx_line_attribute_3a   IN defaultParamType default empty_table,
       icx_line_attribute_4a   IN defaultParamType default empty_table,
       icx_line_attribute_5a   IN defaultParamType default empty_table,
       icx_line_attribute_6a   IN defaultParamType default empty_table,
       icx_line_attribute_7a   IN defaultParamType default empty_table,
       icx_line_attribute_8a   IN defaultParamType default empty_table,
       icx_line_attribute_9a   IN defaultParamType default empty_table,
       icx_line_attribute_10a  IN defaultParamType default empty_table,
       icx_line_attribute_11a  IN defaultParamType default empty_table,
       icx_line_attribute_12a  IN defaultParamType default empty_table,
       icx_line_attribute_13a  IN defaultParamType default empty_table,
       icx_line_attribute_14a  IN defaultParamType default empty_table,
       icx_line_attribute_15a  IN defaultParamType default empty_table,
       icx_charge_acct_seg1a IN defaultParamType default empty_table,
       icx_charge_acct_seg2a IN defaultParamType default empty_table,
       icx_charge_acct_seg3a IN defaultParamType default empty_table,
       icx_charge_acct_seg4a IN defaultParamType default empty_table,
       icx_charge_acct_seg5a IN defaultParamType default empty_table,
       icx_charge_acct_seg6a IN defaultParamType default empty_table,
       icx_charge_acct_seg7a IN defaultParamType default empty_table,
       icx_charge_acct_seg8a IN defaultParamType default empty_table,
       icx_charge_acct_seg9a IN defaultParamType default empty_table,
       icx_charge_acct_seg10a IN defaultParamType default empty_table,
       icx_charge_acct_seg11a IN defaultParamType default empty_table,
       icx_charge_acct_seg12a IN defaultParamType default empty_table,
       icx_charge_acct_seg13a IN defaultParamType default empty_table,
       icx_charge_acct_seg14a IN defaultParamType default empty_table,
       icx_charge_acct_seg15a IN defaultParamType default empty_table,
       icx_charge_acct_seg16a IN defaultParamType default empty_table,
       icx_charge_acct_seg17a IN defaultParamType default empty_table,
       icx_charge_acct_seg18a IN defaultParamType default empty_table,
       icx_charge_acct_seg19a IN defaultParamType default empty_table,
       icx_charge_acct_seg20a IN defaultParamType default empty_table,
       icx_charge_acct_seg21a IN defaultParamType default empty_table,
       icx_charge_acct_seg22a IN defaultParamType default empty_table,
       icx_charge_acct_seg23a IN defaultParamType default empty_table,
       icx_charge_acct_seg24a IN defaultParamType default empty_table,
       icx_charge_acct_seg25a IN defaultParamType default empty_table,
       icx_charge_acct_seg26a IN defaultParamType default empty_table,
       icx_charge_acct_seg27a IN defaultParamType default empty_table,
       icx_charge_acct_seg28a IN defaultParamType default empty_table,
       icx_charge_acct_seg29a IN defaultParamType default empty_table,
       icx_charge_acct_seg30a IN defaultParamType default empty_table,
       entity_name	IN  varchar2 default NULL,
       pk1		IN  varchar2 default NULL,
       pk2		IN  varchar2 default NULL,
       pk3		IN  varchar2 default NULL,
       from_url		IN  varchar2 default NULL,
       query_only	IN  varchar2 default 'N'
		 ) is
-------------------------------------------------------------


     n_pad	number;
     v_lang        varchar2(5);
     l_cart_submitted_flag varchar2(1);

     plsql_bug defaultParamType;

     -- Cart Header variables
     --
     v_cart_id     number;
     v_shopper_id  number;
     v_exist number;
     v_structure number;
     v_saved_flag number;

     cart_exists exception;

     v_emergency  varchar2(10);


     l_error_message VARCHAR2(2000);
     l_err_num NUMBER;
     l_err_mesg VARCHAR2(240);
     l_err_loadinterface varchar2(1);
     p_vendor_name varchar2(1000);
     p_vendor_phone varchar2(80);
     p_vendor_site varchar2(240);
     p_vendor_contact varchar2(240);
     p_deliver_to_location_id number;
     p_deliver_to_location varchar2(300);
     p_deliver_to_org_id number;
     v_expend_date date;
     v_errored boolean;

     v_account_num varchar2(2000);
     v_account_id number;
     n_org_id number;
     v_session_id number;
     v_date_format varchar2(22);
     n_emp_id number;
     v_emp_id number;
     v_incr number;
     supp_count number;
     v_error_message varchar2(1000);
     v_preparer_org_id number;
     requesterID number;
     p_requester varchar2(300);

     v_attribute1 number;
     v_need_date date;
     v_return_code varchar2(200);
     v_expense_account number;
     v_variance_acct_id number;
     v_budget_acct_id number;
     v_accrual_acct_id number;


     cursor get_loc_org_id(loc varchar2) is
        SELECT hrl.location_id,
               nvl(hrl.inventory_organization_id,
                   fsp.inventory_organization_id) organization_id
        from hr_locations hrl,
             financials_system_parameters fsp
        where sysdate < nvl(hrl.inactive_date, sysdate + 1)
        and hrl.location_code = loc;

     cursor requester_check(v_req_name varchar2,v_org_id number) is
        SELECT employee_id
        FROM HR_EMPLOYEES_CURRENT_V
        WHERE full_name = v_req_name
        and organization_id = v_org_id;

    cursor get_preparer_org(v_preparer_id number) is
      SELECT organization_id
      FROM HR_EMPLOYEES_CURRENT_V
      where employee_id = v_preparer_id;

    cursor get_line_count(v_cart_id number) is
 	SELECT count(1)
	FROM   icx_shopping_cart_lines
	WHERE  cart_id = v_cart_id;

    i BINARY_INTEGER;

    cursor acctBuild(v_cart_id number,v_cart_line_id number, v_emp_id number,
		     v_oo_id number) is
        select  hecv.default_code_combination_id employee_default_account_id,
                msi.expense_account
	from    hr_employees_current_v hecv,
		mtl_system_items msi,
		icx_shopping_carts isc,
		icx_shopping_cart_lines iscl
	where   msi.INVENTORY_ITEM_ID (+) = iscl.ITEM_ID
 	and     nvl(msi.ORGANIZATION_ID,
		    nvl(isc.DESTINATION_ORGANIZATION_ID,
			iscl.DESTINATION_ORGANIZATION_ID)) =
		nvl(isc.DESTINATION_ORGANIZATION_ID,
		    iscl.DESTINATION_ORGANIZATION_ID)
        and     hecv.EMPLOYEE_ID = v_emp_id
	and     nvl(isc.org_id, -9999) = nvl(v_oo_id, -9999)
	and     nvl(iscl.org_id, -9999) = nvl(v_oo_id, -9999);


      cursor get_acct is
      select CHART_OF_ACCOUNTS_ID
      from gl_sets_of_books,
	   financials_system_parameters fsp
      where gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

      cursor invalid_locations(l_cart_id number, v_oo_id number) is
	select cart_line_number, DELIVER_TO_LOCATION
	from   icx_shopping_cart_lines
	where  DELIVER_TO_LOCATION_ID is null
	and    cart_id = v_cart_id
	and    nvl(org_id, -9999) = nvl(v_oo_id, -9999);

    cursor employee_check(approver varchar2) is
        SELECT employee_id
        FROM HR_EMPLOYEES_CURRENT_V
        where full_name = approver;

    cursor line_ids(v_cart_id number) is
	select cart_line_id from icx_shopping_cart_lines
	where (quantity is null
	       OR quantity = 0);

    v_action varchar2(100);

    cursor check_cart_submitted(l_cart_id number, l_shopper number) is
	select saved_flag
	from icx_shopping_Carts
	where cart_id = l_cart_id
	and shopper_id = l_shopper;

    cursor get_head_date(l_cart_id number) is
	select need_by_date from icx_shopping_Carts
	where cart_id = l_cart_id;

    v_dcdName varchar2(100);

/**  DAMN PL/SQL BUGS  **/

    c_cart_line_id number;
    a_cart_line_id defaultParamType;
    c_category_id number;
    a_category_id defaultParamType;
   	c_category_name number;
   	a_category_name defaultParamType;
	c_item_id number;
	a_item_id defaultParamType;
	c_item_revision number;
	a_item_revision defaultParamType;
	c_line_need_date number;
	a_line_need_date defaultParamType;
	c_item_description number;
	a_item_description defaultParamType;
	c_expend_item_date number;
	a_expend_item_date defaultParamType;
	c_expend_org number;
	a_expend_org defaultParamType;
	c_qty_va number;
	a_qty_va defaultParamType;
	c_suggested_buyer_id number;
	a_suggested_buyer_id defaultParamType;
	c_project_id number;
	a_project_id defaultParamType;
	c_suggested_vendor_contacta number;
	a_suggested_vendor_contacta defaultParamType;
	c_suggested_vendor_item_numa number;
	a_suggested_vendor_item_numa defaultParamType;
	c_suggested_vendor_namea number;
	a_suggested_vendor_namea defaultParamType;
	c_suggested_vendor_phonea number;
	a_suggested_vendor_phonea defaultParamType;
	c_suggested_vendor_sitea number;
	a_suggested_vendor_sitea defaultParamType;
	c_task_id number;
	a_task_id defaultParamType;
	c_unit_of_measurement number;
	a_unit_of_measurement defaultParamType;
	c_unit_price number;
	a_unit_price defaultParamType;
	c_deliver_to_location_id_l number;
	a_deliver_to_location_id_l defaultParamType;
	c_dest_org_id_l number;
	a_dest_org_id_l defaultParamType;
	c_deliver_to_location_l number;
	a_deliver_to_location_l defaultParamType;
	c_line_attribute_1a number;
	a_line_attribute_1a defaultParamType;
	c_line_attribute_2a number;
	a_line_attribute_2a defaultParamType;
	c_line_attribute_3a number;
	a_line_attribute_3a defaultParamType;
	c_line_attribute_4a number;
	a_line_attribute_4a defaultParamType;
	c_line_attribute_5a number;
	a_line_attribute_5a defaultParamType;
	c_line_attribute_6a number;
	a_line_attribute_6a defaultParamType;
	c_line_attribute_7a number;
	a_line_attribute_7a defaultParamType;
	c_line_attribute_8a number;
	a_line_attribute_8a defaultParamType;
	c_line_attribute_9a number;
	a_line_attribute_9a defaultParamType;
	c_line_attribute_10a number;
	a_line_attribute_10a defaultParamType;
	c_line_attribute_11a number;
	a_line_attribute_11a defaultParamType;
	c_line_attribute_12a number;
	a_line_attribute_12a defaultParamType;
	c_line_attribute_13a number;
	a_line_attribute_13a defaultParamType;
	c_line_attribute_14a number;
	a_line_attribute_14a defaultParamType;
	c_line_attribute_15a number;
	a_line_attribute_15a defaultParamType;
	c_charge_acct_seg1a number;
	a_charge_acct_seg1a defaultParamType;
	c_charge_acct_seg2a number;
	a_charge_acct_seg2a defaultParamType;
	c_charge_acct_seg3a number;
	a_charge_acct_seg3a defaultParamType;
	c_charge_acct_seg4a number;
	a_charge_acct_seg4a defaultParamType;
	c_charge_acct_seg5a number;
	a_charge_acct_seg5a defaultParamType;
	c_charge_acct_seg6a number;
	a_charge_acct_seg6a defaultParamType;
	c_charge_acct_seg7a number;
	a_charge_acct_seg7a defaultParamType;
	c_charge_acct_seg8a number;
	a_charge_acct_seg8a defaultParamType;
	c_charge_acct_seg9a number;
	a_charge_acct_seg9a defaultParamType;
	c_charge_acct_seg10a number;
	a_charge_acct_seg10a defaultParamType;
	c_charge_acct_seg11a number;
	a_charge_acct_seg11a defaultParamType;
	c_charge_acct_seg12a number;
	a_charge_acct_seg12a defaultParamType;
	c_charge_acct_seg13a number;
	a_charge_acct_seg13a defaultParamType;
	c_charge_acct_seg14a number;
	a_charge_acct_seg14a defaultParamType;
	c_charge_acct_seg15a number;
	a_charge_acct_seg15a defaultParamType;
	c_charge_acct_seg16a number;
	a_charge_acct_seg16a defaultParamType;
	c_charge_acct_seg17a number;
	a_charge_acct_seg17a defaultParamType;
	c_charge_acct_seg18a number;
	a_charge_acct_seg18a defaultParamType;
	a_charge_acct_seg19a defaultParamType;
	c_charge_acct_seg19a number;
        a_charge_acct_seg20a defaultParamType;
        c_charge_acct_seg20a number;
        a_charge_acct_seg21a defaultParamType;
        c_charge_acct_seg21a number;
        a_charge_acct_seg22a defaultParamType;
        c_charge_acct_seg22a number;
        a_charge_acct_seg23a defaultParamType;
        c_charge_acct_seg23a number;
        a_charge_acct_seg24a defaultParamType;
        c_charge_acct_seg24a number;
        a_charge_acct_seg25a defaultParamType;
        c_charge_acct_seg25a number;
        a_charge_acct_seg26a defaultParamType;
        c_charge_acct_seg26a number;
        a_charge_acct_seg27a defaultParamType;
        c_charge_acct_seg27a number;
        a_charge_acct_seg28a defaultParamType;
        c_charge_acct_seg28a number;
        a_charge_acct_seg29a defaultParamType;
        c_charge_acct_seg29a number;
	c_charge_acct_seg30a number;
	a_charge_acct_seg30a defaultParamType;


   cursor cart_lines(v_cart_id number) is
	select cart_line_id from
	icx_shopping_cart_lines
	where cart_id = v_cart_id;

   d_shopper_name  varchar2(100);
   d_location_id   number;
   d_location_code varchar2(100);
   d_org_id        number;
   d_org_code      varchar2(100);

   n_number        number;

   l_po_number varchar2(1000);

   cursor get_reserved_po_number(cartId number,shopperId number) is
       select reserved_po_num
       from icx_shopping_carts
       where cart_id = cartId
       and shopper_id = shopperId;


   CURSOR C3 IS SELECT to_char(current_max_unique_identifier + 1)
                  FROM   po_unique_identifier_control
                  WHERE  table_name = 'PO_HEADERS'
                  FOR UPDATE OF current_max_unique_identifier;

begin


  if (icx_sec.validatesession()) then



     -- initialize the error page
     icx_util.error_page_setup;

     --get language code
     v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


     -- get shopper id and lang code
     v_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

      v_cart_id := icx_call.decrypt2(icx_cart_id);


     -- clear out all possible cart errors
     delete icx_req_cart_errors
     where cart_id = v_cart_id;

      n_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
      v_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
      n_emp_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);
      v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

     -- get shopper info for defaults
     ICX_REQ_NAVIGATION.shopper_info(n_emp_id,
				     d_shopper_name, d_location_id,
				     d_location_code, d_org_id, d_org_code);


  -- Check if cart is legal
	open check_cart_submitted(v_cart_id, v_shopper_id);
	fetch check_cart_submitted into v_saved_flag;
	if check_cart_submitted%NOTFOUND then
	   raise cart_exists;
	end if;
	if v_saved_flag = 2 then
	   raise cart_exists;
	end if;


  if (user_action <> 'CANCEL') then


 /***********************************************************************/
 /*****		DO THE HEADER RECORD				********/
 /***********************************************************************/
      -- check if date is valid
     if (icx_need_by_date <> FND_API.G_MISS_CHAR) then
     begin
        v_need_date := to_date(icx_need_by_date, v_date_format);
        if v_need_date <= (sysdate - 1) then
          v_incr := icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY);
          FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_NEED_BY_DATE');
          v_error_message := FND_MESSAGE.GET;
          icx_util.add_error(v_error_message);
          storeerror(v_cart_id, v_error_message);
          v_need_date := sysdate + v_incr;
        end if;
     exception
     when others then
        --add error
	v_incr := icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY);
        FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_DATE');
	v_error_message := FND_MESSAGE.GET;
        icx_util.add_error(v_error_message);
        storeerror(v_cart_id, v_error_message);
        v_need_date := sysdate + v_incr;
     end;
     else
	FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_DATE');
        v_error_message := FND_MESSAGE.GET;
        icx_util.add_error(v_error_message);
        storeerror(v_cart_id, v_error_message);
	v_incr := icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY);
	v_need_date := sysdate + v_incr;
     end if;


     -- check if emergency reqs, reserve po number if not already has one
     -- do not waste PO number if not needed, so check first if already
     -- has one in table, then do the reserve po number
     l_po_number := NULL;

     if emergency = 'YES' then
        open get_reserved_po_number(v_cart_id,v_shopper_id);
        fetch get_reserved_po_number into l_po_number;
        close get_reserved_po_number;

        -- only get a reserve po number if user did not click on
        -- Apply Changes button
        if l_po_number is NULL  and
           user_action <> 'MODIFY' and user_action <> 'ATTACHMENT' then
           open C3;
           fetch C3 into l_po_number;
           UPDATE po_unique_identifier_control
           SET    current_max_unique_identifier =
                  current_max_unique_identifier + 1
           WHERE  CURRENT of C3;
           CLOSE C3;
           commit;
        end if;
     end if;

     update ICX_SHOPPING_CARTS
     set APPROVER_ID = decode(icx_approver_id, FND_API.G_MISS_CHAR, APPROVER_ID,
					     icx_approver_id),
     APPROVER_NAME = decode(icx_approver_name,
			    FND_API.G_MISS_CHAR, APPROVER_NAME,
			    icx_approver_name),
     DELIVER_TO_LOCATION_ID =
    	decode(icx_deliver_to_location_id,
			FND_API.G_MISS_CHAR, DELIVER_TO_LOCATION_ID,
			icx_deliver_to_location_id),
     DELIVER_TO_LOCATION = decode(icx_deliver_to_location,
			FND_API.G_MISS_CHAR, DELIVER_TO_LOCATION,
			icx_deliver_to_location),
     DELIVER_TO_REQUESTOR_ID =
	decode(icx_deliver_to_requestor_id,
			FND_API.G_MISS_CHAR, DELIVER_TO_REQUESTOR_ID,
			icx_deliver_to_requestor_id),
     DELIVER_TO_REQUESTOR =
	decode(icx_deliver_to_requestor,
	       FND_API.G_MISS_CHAR, DELIVER_TO_REQUESTOR,
	       icx_deliver_to_requestor),
     DESTINATION_ORGANIZATION_ID =
	decode(icx_dest_org_id, FND_API.G_MISS_CHAR, DESTINATION_ORGANIZATION_ID,
			icx_dest_org_id),
     NEED_BY_DATE = decode(icx_need_by_date, FND_API.G_MISS_CHAR, NEED_BY_DATE,
			v_need_date),
     NOTE_TO_APPROVER = decode(icx_note_to_approver,
			FND_API.G_MISS_CHAR, NOTE_TO_APPROVER, icx_note_to_approver),
     NOTE_TO_BUYER = decode(icx_note_to_buyer, FND_API.G_MISS_CHAR, NOTE_TO_BUYER,
			icx_note_to_buyer),
     HEADER_DESCRIPTION = decode(icx_header_description,
			FND_API.G_MISS_CHAR, HEADER_DESCRIPTION,
			icx_header_description),
     HEADER_ATTRIBUTE1 = decode(icx_header_attribute1,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE1,
			icx_header_attribute1),
     HEADER_ATTRIBUTE2 = decode(icx_header_attribute2,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE2,
			icx_header_attribute2),
     HEADER_ATTRIBUTE3 = decode(icx_header_attribute3,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE3,
			icx_header_attribute3),
     HEADER_ATTRIBUTE4 = decode(icx_header_attribute4,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE4,
			icx_header_attribute4),
     HEADER_ATTRIBUTE5 = decode(icx_header_attribute5,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE5,
			icx_header_attribute5),
     HEADER_ATTRIBUTE6 = decode(icx_header_attribute6,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE6,
			icx_header_attribute6),
     HEADER_ATTRIBUTE7 = decode(icx_header_attribute7,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE7,
			icx_header_attribute7),
     HEADER_ATTRIBUTE8 = decode(icx_header_attribute8,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE8,
			icx_header_attribute8),
     HEADER_ATTRIBUTE9 = decode(icx_header_attribute9,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE9,
			icx_header_attribute9),
     HEADER_ATTRIBUTE10 = decode(icx_header_attribute10,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE10,
			icx_header_attribute10),
     HEADER_ATTRIBUTE11 = decode(icx_header_attribute11,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE11,
			icx_header_attribute11),
     HEADER_ATTRIBUTE12 = decode(icx_header_attribute12,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE12,
			icx_header_attribute12),
     HEADER_ATTRIBUTE13 = decode(icx_header_attribute13,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE13,
			icx_header_attribute13),
     HEADER_ATTRIBUTE14 = decode(icx_header_attribute14,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE14,
			icx_header_attribute14),
     HEADER_ATTRIBUTE15 = decode(icx_header_attribute15,
			FND_API.G_MISS_CHAR, HEADER_ATTRIBUTE15,
			icx_header_attribute15),
     RESERVED_PO_NUM =  l_po_number,
     LAST_UPDATE_DATE = sysdate
     where  CART_ID = v_cart_id
     and    SHOPPER_ID = v_shopper_id;


     update icx_cart_distributions
     SET LAST_UPDATE_DATE = sysdate,
     CHARGE_ACCOUNT_SEGMENT1 = decode(icx_charge_acct_seg1,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT1,
			icx_charge_acct_seg1),
     CHARGE_ACCOUNT_SEGMENT2 = decode(icx_charge_acct_seg2,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT2,
			icx_charge_acct_seg2),
     CHARGE_ACCOUNT_SEGMENT3 = decode(icx_charge_acct_seg3,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT3,
			icx_charge_acct_seg3),
     CHARGE_ACCOUNT_SEGMENT4 = decode(icx_charge_acct_seg4,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT4,
			icx_charge_acct_seg4),
     CHARGE_ACCOUNT_SEGMENT5 = decode(icx_charge_acct_seg5,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT5,
			icx_charge_acct_seg5),
     CHARGE_ACCOUNT_SEGMENT6 = decode(icx_charge_acct_seg6,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT6,
			icx_charge_acct_seg6),
     CHARGE_ACCOUNT_SEGMENT7 = decode(icx_charge_acct_seg7,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT7,
			icx_charge_acct_seg7),
     CHARGE_ACCOUNT_SEGMENT8 = decode(icx_charge_acct_seg8,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT8,
			icx_charge_acct_seg8),
     CHARGE_ACCOUNT_SEGMENT9 = decode(icx_charge_acct_seg9,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT9,
			icx_charge_acct_seg9),
     CHARGE_ACCOUNT_SEGMENT10 = decode(icx_charge_acct_seg10,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT10,
			icx_charge_acct_seg10),
     CHARGE_ACCOUNT_SEGMENT11 = decode(icx_charge_acct_seg11,
			FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT11,
			icx_charge_acct_seg11),
     CHARGE_ACCOUNT_SEGMENT12 = decode(icx_charge_acct_seg12,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT12,
                        icx_charge_acct_seg12),
     CHARGE_ACCOUNT_SEGMENT13 = decode(icx_charge_acct_seg13,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT13,
                        icx_charge_acct_seg13),
     CHARGE_ACCOUNT_SEGMENT14 = decode(icx_charge_acct_seg14,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT14,
                        icx_charge_acct_seg14),
     CHARGE_ACCOUNT_SEGMENT15 = decode(icx_charge_acct_seg15,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT15,
                        icx_charge_acct_seg15),
     CHARGE_ACCOUNT_SEGMENT16 = decode(icx_charge_acct_seg16,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT16,
                        icx_charge_acct_seg16),
     CHARGE_ACCOUNT_SEGMENT17 = decode(icx_charge_acct_seg17,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT17,
                        icx_charge_acct_seg17),
     CHARGE_ACCOUNT_SEGMENT18 = decode(icx_charge_acct_seg18,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT18,
                        icx_charge_acct_seg18),
     CHARGE_ACCOUNT_SEGMENT19 = decode(icx_charge_acct_seg19,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT19,
                        icx_charge_acct_seg19),
     CHARGE_ACCOUNT_SEGMENT20 = decode(icx_charge_acct_seg20,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT20,
			icx_charge_acct_seg20),
     CHARGE_ACCOUNT_SEGMENT21 = decode(icx_charge_acct_seg21,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT21,
                        icx_charge_acct_seg21),
     CHARGE_ACCOUNT_SEGMENT22 = decode(icx_charge_acct_seg22,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT22,
                        icx_charge_acct_seg22),
     CHARGE_ACCOUNT_SEGMENT23 = decode(icx_charge_acct_seg23,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT23,
                        icx_charge_acct_seg23),
     CHARGE_ACCOUNT_SEGMENT24 = decode(icx_charge_acct_seg24,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT24,
                        icx_charge_acct_seg24),
     CHARGE_ACCOUNT_SEGMENT25 = decode(icx_charge_acct_seg25,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT25,
                        icx_charge_acct_seg25),
     CHARGE_ACCOUNT_SEGMENT26 = decode(icx_charge_acct_seg26,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT26,
                        icx_charge_acct_seg26),
     CHARGE_ACCOUNT_SEGMENT27 = decode(icx_charge_acct_seg27,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT27,
                        icx_charge_acct_seg27),
     CHARGE_ACCOUNT_SEGMENT28 = decode(icx_charge_acct_seg28,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT28,
                        icx_charge_acct_seg28),
     CHARGE_ACCOUNT_SEGMENT29 = decode(icx_charge_acct_seg29,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT29,
                        icx_charge_acct_seg29),
     CHARGE_ACCOUNT_SEGMENT30 = decode(icx_charge_acct_seg30,
                        FND_API.G_MISS_CHAR, CHARGE_ACCOUNT_SEGMENT30,
                        icx_charge_acct_seg30)
     where
	cart_id = v_cart_id;



    /*********************************************************************/
    /*********                  Validate Head                   **********/
    /*********************************************************************/

     -- user custum validation
     icx_req_custom.reqs_validate_head(emergency, v_cart_id);



     -- Location Location Location
     if (icx_deliver_to_location <> FND_API.G_MISS_CHAR) then
        --deliver to location on at the Header level, make sure its correct
        if (icx_deliver_to_location_id is null) then
           -- the user typed the value into the field, we have to validate
           open get_loc_org_id(icx_deliver_to_location);
           fetch get_loc_org_id into p_deliver_to_location_id,
                                     p_deliver_to_org_id;
           if get_loc_org_id%NOTFOUND then
              -- woops they didn't type it in correctly
              v_error_message :=
                        icx_util.getPrompt(601, 'ICX_SHOPPING_CART_HEADER_R',
                                           178, 'ICX_DELIVER_TO_LOCATION');
              FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
              FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_message ||
                                    ' : ' || icx_deliver_to_location);
              v_error_message := FND_MESSAGE.GET;
              icx_util.add_error(v_error_message);
              storeerror(v_cart_id, v_error_message);
              p_deliver_to_location_id := d_location_id;
              p_deliver_to_org_id := d_org_id;
              p_deliver_to_location := d_location_code;
	   else
	      p_deliver_to_location := icx_deliver_to_location;
           end if;
           close get_loc_org_id;
--	   update icx_shopping_Carts
--		set DELIVER_TO_LOCATION_ID = null,
--		DESTINATION_ORGANIZATION_ID = d_org_id
--	   where  CART_ID = v_cart_id
--           and    SHOPPER_ID = v_shopper_id;

--dc should user p_deliver_to_location_id etc instead
           update icx_shopping_carts
		set DELIVER_TO_LOCATION_ID = p_deliver_to_location_id,
 		    DELIVER_TO_LOCATIOn = p_deliver_to_location,
		    DESTINATION_ORGANIZATION_ID = p_deliver_to_org_id
           where CART_ID = v_cart_id
	   and SHOPPER_ID = v_shopper_id;

        end if;
    elsif (icx_deliver_to_location is null) then
        v_error_message :=
        icx_util.getPrompt(601, 'ICX_SHOPPING_CART_HEADER_R',
                           178, 'ICX_DELIVER_TO_LOCATION');
        FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
        FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_message ||
                              ' : ' || icx_deliver_to_location);
        v_error_message := FND_MESSAGE.GET;
        icx_util.add_error(v_error_message);
        storeerror(v_cart_id, v_error_message);
	update icx_shopping_Carts
	set DELIVER_TO_LOCATION_ID = null,
	    DESTINATION_ORGANIZATION_ID = d_org_id,
	    DELIVER_TO_LOCATION = null
	where CART_ID = v_cart_id
        and    SHOPPER_ID = v_shopper_id;
    end if;

    --validate requster
    if (icx_deliver_to_requestor <> FND_API.G_MISS_CHAR) then
       -- requster must be on in the region
       if (icx_deliver_to_requestor_id is null) then
	  -- user type in value for requester
	  if (icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ORG')
		then
	     open get_preparer_org(n_emp_id);
             fetch get_preparer_org into v_preparer_org_id;
             close get_preparer_org;


	     open requester_check(icx_deliver_to_requestor, v_preparer_org_id);
	     fetch requester_check into requesterID;
	     if requester_check%NOTFOUND then
	        FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_REQUESTER');
	        v_error_message := FND_MESSAGE.GET;
	        icx_util.add_error(v_error_message);
	        storeerror(v_cart_id, v_error_message);
	        requesterID := null;
	        p_requester := null;
	      else
	        p_requester := icx_deliver_to_requestor;
	      end if;
          else
	      -- must overide att the ALL case
	      open employee_check(icx_deliver_to_requestor);
	      fetch employee_check into requesterID;
	      if employee_check%FOUND then
	         p_requester := icx_deliver_to_requestor;
	      else
	         FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_REQUESTER');
                 v_error_message := FND_MESSAGE.GET;
                 icx_util.add_error(v_error_message);
                 storeerror(v_cart_id, v_error_message);
                 requesterID := -1;
                 p_requester := null;
	      end if;
          end if;
	  update icx_shopping_carts
	  set DELIVER_TO_REQUESTOR_ID = requesterID,
	  DELIVER_TO_REQUESTOR = p_requester
	  where CART_ID = v_cart_id
	  and   SHOPPER_ID = v_shopper_id;
      end if;
   elsif (icx_deliver_to_requestor is null) then
         FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_REQUESTER');
         v_error_message := FND_MESSAGE.GET;
         icx_util.add_error(v_error_message);
         storeerror(v_cart_id, v_error_message);
	 update icx_shopping_Carts
	 set DELIVER_TO_REQUESTOR_ID = null,
	 DELIVER_TO_REQUESTOR = null
	 where CART_ID = v_cart_id
         and   SHOPPER_ID = v_shopper_id;
   end if;

   --validate approver
   if (icx_approver_name <> FND_API.G_MISS_CHAR) then
      -- approver must be in the region
      if (icx_approver_id is null) then
	   -- user typed in an approver
	   open employee_check(icx_approver_name);
	   fetch employee_check into requesterID;
           if (employee_check%NOTFOUND) then
--changed by alex
/*	      v_error_message :=
                        icx_util.getPrompt(601, 'ICX_SHOPPING_CART_HEADER_R',
                                           178, 'ICX_APPROVER_NAME');
              FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
              FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_message);
              v_error_message := FND_MESSAGE.GET;
              icx_util.add_error(v_error_message);
              storeerror(v_cart_id,v_error_message);
*/
	      p_requester := null;
	      requesterID:= null;
	   else
	      p_requester := icx_approver_name;
           end if;
	 update icx_shopping_carts
	 set APPROVER_ID = requesterID,
 	 APPROVER_NAME	= p_requester
	 where cart_id = v_cart_id
	 and   shopper_id = v_shopper_id;
     end if;
   elsif (icx_approver_name is null) then
--changed by alex
/*	v_error_message :=
           icx_util.getPrompt(601, 'ICX_SHOPPING_CART_HEADER_R',
                                           178, 'ICX_APPROVER_NAME');
           FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
           FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_message);
           v_error_message := FND_MESSAGE.GET;
           icx_util.add_error(v_error_message);
           storeerror(v_cart_id,v_error_message);
*/
	   update icx_shopping_carts
	   set APPROVER_ID = null,
	       APPROVER_NAME = null
	   where cart_id = v_cart_id
           and   shopper_id = v_shopper_id;
   end if;


 /***********************************************************************/
 /*****         Now the LINES					 ********/
 /***********************************************************************/


  -- get the counts of each table
  if icx_cart_line_ida.COUNT > 0 then

	c_cart_line_id := icx_cart_line_ida.COUNT;

        -- We have the count, so we make a empty table of that many
	for i in 1..c_cart_line_id loop
	    plsql_bug(i) := null;
	end loop;
	c_category_id := icx_category_ida.COUNT;
	if c_category_id = 0 then a_category_id := plsql_bug;
	else a_category_id := icx_category_ida;
	end if;
	c_category_name := icx_category_namea.COUNT;
	if c_category_name = 0 then a_category_name := plsql_bug;
	else a_category_name := icx_category_namea;
	end if;
	c_item_id := icx_item_ida.COUNT;
	if c_item_id = 0 then a_item_id := plsql_bug;
	else a_item_id := icx_item_ida;
	end if;
	c_item_revision := icx_item_reva.COUNT;
	if c_item_revision = 0 then a_item_revision := plsql_bug;
	else a_item_revision := icx_item_reva;
	end if;
	c_line_need_date := icx_need_by_datea.COUNT;
	if c_line_need_date = 0 then a_line_need_date := plsql_bug;
	else a_line_need_date := icx_need_by_datea;
	end if;
	c_item_description := icx_item_descriptiona.COUNT;
	if c_item_description = 0 then a_item_description := plsql_bug;
	else a_item_description := icx_item_descriptiona;
	end if;
	c_expend_item_date := icx_expend_item_datea.COUNT;
	if c_expend_item_date = 0 then a_expend_item_date := plsql_bug;
	else a_expend_item_date := icx_expend_item_datea;
	end if;
	c_expend_org := icx_expend_orga.COUNT;
	if c_expend_org = 0 then a_expend_org := plsql_bug;
	else a_expend_org := icx_expend_orga;
	end if;
	c_qty_va := icx_qty_va.COUNT;
	if c_qty_va = 0 then a_qty_va := plsql_bug;
	else a_qty_va := icx_qty_va;
	end if;
	c_suggested_buyer_id := icx_suggested_buyer_ida.COUNT;
	if c_suggested_buyer_id = 0 then a_suggested_buyer_id := plsql_bug;
	else a_suggested_buyer_id := icx_suggested_buyer_ida;
	end if;
	c_project_id := icx_project_ida.COUNT;
	if c_project_id = 0 then a_project_id := plsql_bug;
	else a_project_id := icx_project_ida;
	end if;
	c_suggested_vendor_contacta := icx_suggested_vendor_contacta.COUNT;
	if c_suggested_vendor_contacta = 0 then a_suggested_vendor_contacta := plsql_bug;
	else a_suggested_vendor_contacta := icx_suggested_vendor_contacta;
	end if;
	c_suggested_vendor_item_numa := icx_suggested_vendor_item_numa.COUNT;
	if c_suggested_vendor_item_numa = 0 then a_suggested_vendor_item_numa := plsql_bug;
	else a_suggested_vendor_item_numa := icx_suggested_vendor_item_numa;
	end if;
	c_suggested_vendor_namea := icx_suggested_vendor_namea.COUNT;
	if c_suggested_vendor_namea = 0 then a_suggested_vendor_namea := plsql_bug;
	else a_suggested_vendor_namea := icx_suggested_vendor_namea;
	end if;
	c_suggested_vendor_phonea := icx_suggested_vendor_phonea.COUNT;
	if c_suggested_vendor_phonea = 0 then a_suggested_vendor_phonea := plsql_bug;
	else a_suggested_vendor_phonea := icx_suggested_vendor_phonea;
	end if;
	c_suggested_vendor_sitea := icx_suggested_vendor_sitea.COUNT;
	if c_suggested_vendor_sitea = 0 then a_suggested_vendor_sitea := plsql_bug;
	else a_suggested_vendor_sitea := icx_suggested_vendor_sitea;
	end if;
	c_task_id := icx_task_ida.COUNT;
	if c_task_id = 0 then a_task_id := plsql_bug;
	else a_task_id := icx_task_ida;
	end if;
	c_unit_of_measurement := icx_unit_of_measurementa.COUNT;
	if c_unit_of_measurement = 0 then a_unit_of_measurement := plsql_bug;
	else a_unit_of_measurement := icx_unit_of_measurementa;
	end if;
	c_unit_price := icx_unit_pricea.COUNT;
	if c_unit_price = 0 then a_unit_price := plsql_bug;
	else a_unit_price := icx_unit_pricea;
	end if;
	c_deliver_to_location_id_l := icx_deliver_to_location_id_la.COUNT;
	if c_deliver_to_location_id_l = 0 then a_deliver_to_location_id_l := plsql_bug;
	else a_deliver_to_location_id_l := icx_deliver_to_location_id_la;
	end if;
	c_dest_org_id_l := icx_dest_org_id_la.COUNT;
	if c_dest_org_id_l = 0 then a_dest_org_id_l := plsql_bug;
	else a_dest_org_id_l := icx_dest_org_id_la;
	end if;
	c_deliver_to_location_l := icx_deliver_to_location_la.COUNT;
	if c_deliver_to_location_l = 0 then a_deliver_to_location_l := plsql_bug;
	else a_deliver_to_location_l := icx_deliver_to_location_la;
	end if;
	c_line_attribute_1a := icx_line_attribute_1a.COUNT;
	if c_line_attribute_1a = 0 then a_line_attribute_1a := plsql_bug;
	else a_line_attribute_1a := icx_line_attribute_1a;
	end if;
	c_line_attribute_2a := icx_line_attribute_2a.COUNT;
	if c_line_attribute_2a = 0 then a_line_attribute_2a := plsql_bug;
	else a_line_attribute_2a := icx_line_attribute_2a;
	end if;
	c_line_attribute_3a := icx_line_attribute_3a.COUNT;
	if c_line_attribute_3a = 0 then a_line_attribute_3a := plsql_bug;
	else a_line_attribute_3a := icx_line_attribute_3a;
	end if;
	c_line_attribute_4a := icx_line_attribute_4a.COUNT;
	if c_line_attribute_4a = 0 then a_line_attribute_4a := plsql_bug;
	else a_line_attribute_4a := icx_line_attribute_4a;
	end if;
	c_line_attribute_5a := icx_line_attribute_5a.COUNT;
	if c_line_attribute_5a = 0 then a_line_attribute_5a := plsql_bug;
	else a_line_attribute_5a := icx_line_attribute_5a;
	end if;
	c_line_attribute_6a := icx_line_attribute_6a.COUNT;
	if c_line_attribute_6a = 0 then a_line_attribute_6a := plsql_bug;
	else a_line_attribute_6a := icx_line_attribute_6a;
	end if;
	c_line_attribute_7a := icx_line_attribute_7a.COUNT;
	if c_line_attribute_7a = 0 then a_line_attribute_7a := plsql_bug;
	else a_line_attribute_7a := icx_line_attribute_7a;
	end if;
	c_line_attribute_8a := icx_line_attribute_8a.COUNT;
	if c_line_attribute_8a = 0 then a_line_attribute_8a := plsql_bug;
	else a_line_attribute_8a := icx_line_attribute_8a;
	end if;
	c_line_attribute_9a := icx_line_attribute_9a.COUNT;
	if c_line_attribute_9a = 0 then a_line_attribute_9a := plsql_bug;
	else a_line_attribute_9a := icx_line_attribute_9a;
	end if;
	c_line_attribute_10a := icx_line_attribute_10a.COUNT;
	if c_line_attribute_10a = 0 then a_line_attribute_10a := plsql_bug;
	else a_line_attribute_10a := icx_line_attribute_10a;
	end if;
	c_line_attribute_11a := icx_line_attribute_11a.COUNT;
	if c_line_attribute_11a = 0 then a_line_attribute_11a := plsql_bug;
	else a_line_attribute_11a := icx_line_attribute_11a;
	end if;
	c_line_attribute_12a := icx_line_attribute_12a.COUNT;
	if c_line_attribute_12a = 0 then a_line_attribute_12a := plsql_bug;
	else a_line_attribute_12a := icx_line_attribute_12a;
	end if;
	c_line_attribute_13a := icx_line_attribute_13a.COUNT;
	if c_line_attribute_13a = 0 then a_line_attribute_13a := plsql_bug;
	else a_line_attribute_13a := icx_line_attribute_13a;
	end if;
	c_line_attribute_14a := icx_line_attribute_14a.COUNT;
	if c_line_attribute_14a = 0 then a_line_attribute_14a := plsql_bug;
	else a_line_attribute_14a := icx_line_attribute_14a;
	end if;
	c_line_attribute_15a := icx_line_attribute_15a.COUNT;
	if c_line_attribute_15a = 0 then a_line_attribute_15a := plsql_bug;
	else a_line_attribute_15a := icx_line_attribute_15a;
	end if;
	c_charge_acct_seg1a := icx_charge_acct_seg1a.COUNT;
	if c_charge_acct_seg1a = 0 then a_charge_acct_seg1a := plsql_bug;
	else a_charge_acct_seg1a := icx_charge_acct_seg1a;
	end if;
	c_charge_acct_seg2a := icx_charge_acct_seg2a.COUNT;
	if c_charge_acct_seg2a = 0 then a_charge_acct_seg2a := plsql_bug;
	else a_charge_acct_seg2a := icx_charge_acct_seg2a;
	end if;
	c_charge_acct_seg3a := icx_charge_acct_seg3a.COUNT;
	if c_charge_acct_seg3a = 0 then a_charge_acct_seg3a := plsql_bug;
	else a_charge_acct_seg3a := icx_charge_acct_seg3a;
	end if;
	c_charge_acct_seg4a := icx_charge_acct_seg4a.COUNT;
	if c_charge_acct_seg4a = 0 then a_charge_acct_seg4a := plsql_bug;
	else a_charge_acct_seg4a := icx_charge_acct_seg4a;
	end if;
	c_charge_acct_seg5a := icx_charge_acct_seg5a.COUNT;
	if c_charge_acct_seg5a = 0 then a_charge_acct_seg5a := plsql_bug;
	else a_charge_acct_seg5a := icx_charge_acct_seg5a;
	end if;
	c_charge_acct_seg6a := icx_charge_acct_seg6a.COUNT;
	if c_charge_acct_seg6a = 0 then a_charge_acct_seg6a := plsql_bug;
	else a_charge_acct_seg6a := icx_charge_acct_seg6a;
	end if;
	c_charge_acct_seg7a := icx_charge_acct_seg7a.COUNT;
	if c_charge_acct_seg7a = 0 then a_charge_acct_seg7a := plsql_bug;
	else a_charge_acct_seg7a := icx_charge_acct_seg7a;
	end if;
	c_charge_acct_seg8a := icx_charge_acct_seg8a.COUNT;
	if c_charge_acct_seg8a = 0 then a_charge_acct_seg8a := plsql_bug;
	else a_charge_acct_seg8a := icx_charge_acct_seg8a;
	end if;
	c_charge_acct_seg9a := icx_charge_acct_seg9a.COUNT;
	if c_charge_acct_seg9a = 0 then a_charge_acct_seg9a := plsql_bug;
	else a_charge_acct_seg9a := icx_charge_acct_seg9a;
	end if;
	c_charge_acct_seg10a := icx_charge_acct_seg10a.COUNT;
	if c_charge_acct_seg10a = 0 then a_charge_acct_seg10a := plsql_bug;
	else a_charge_acct_seg10a := icx_charge_acct_seg10a;
	end if;
	c_charge_acct_seg11a := icx_charge_acct_seg11a.COUNT;
	if c_charge_acct_seg11a = 0 then a_charge_acct_seg11a := plsql_bug;
	else a_charge_acct_seg11a := icx_charge_acct_seg11a;
	end if;
	c_charge_acct_seg12a := icx_charge_acct_seg12a.COUNT;
	if c_charge_acct_seg12a = 0 then a_charge_acct_seg12a := plsql_bug;
	else a_charge_acct_seg12a := icx_charge_acct_seg12a;
	end if;
	c_charge_acct_seg13a := icx_charge_acct_seg13a.COUNT;
	if c_charge_acct_seg13a = 0 then a_charge_acct_seg13a := plsql_bug;
	else a_charge_acct_seg13a := icx_charge_acct_seg13a;
	end if;
	c_charge_acct_seg14a := icx_charge_acct_seg14a.COUNT;
	if c_charge_acct_seg14a = 0 then a_charge_acct_seg14a := plsql_bug;
	else a_charge_acct_seg14a := icx_charge_acct_seg14a;
	end if;
	c_charge_acct_seg15a := icx_charge_acct_seg15a.COUNT;
	if c_charge_acct_seg15a = 0 then a_charge_acct_seg15a := plsql_bug;
	else a_charge_acct_seg15a := icx_charge_acct_seg15a;
	end if;
	c_charge_acct_seg16a := icx_charge_acct_seg16a.COUNT;
	if c_charge_acct_seg16a = 0 then a_charge_acct_seg16a := plsql_bug;
	else a_charge_acct_seg16a := icx_charge_acct_seg16a;
	end if;
	c_charge_acct_seg17a := icx_charge_acct_seg17a.COUNT;
	if c_charge_acct_seg17a = 0 then a_charge_acct_seg17a := plsql_bug;
	else a_charge_acct_seg17a := icx_charge_acct_seg17a;
	end if;
	c_charge_acct_seg18a := icx_charge_acct_seg18a.COUNT;
	if c_charge_acct_seg18a = 0 then a_charge_acct_seg18a := plsql_bug;
	else a_charge_acct_seg18a := icx_charge_acct_seg18a;
	end if;
	c_charge_acct_seg19a := icx_charge_acct_seg19a.COUNT;
	if c_charge_acct_seg19a = 0 then a_charge_acct_seg19a := plsql_bug;
	else a_charge_acct_seg19a := icx_charge_acct_seg19a;
	end if;
        c_charge_acct_seg20a := icx_charge_acct_seg20a.COUNT;
	if c_charge_acct_seg20a = 0 then a_charge_acct_seg20a := plsql_bug;
	else a_charge_acct_seg20a := icx_charge_acct_seg20a;
	end if;
        c_charge_acct_seg21a := icx_charge_acct_seg21a.COUNT;
	if c_charge_acct_seg21a = 0 then a_charge_acct_seg21a := plsql_bug;
	else a_charge_acct_seg21a := icx_charge_acct_seg21a;
	end if;
        c_charge_acct_seg22a := icx_charge_acct_seg22a.COUNT;
	if c_charge_acct_seg22a = 0 then a_charge_acct_seg22a := plsql_bug;
	else a_charge_acct_seg22a := icx_charge_acct_seg22a;
	end if;
        c_charge_acct_seg23a := icx_charge_acct_seg23a.COUNT;
	if c_charge_acct_seg23a = 0 then a_charge_acct_seg23a := plsql_bug;
	else a_charge_acct_seg23a := icx_charge_acct_seg23a;
	end if;
        c_charge_acct_seg24a := icx_charge_acct_seg24a.COUNT;
	if c_charge_acct_seg24a = 0 then a_charge_acct_seg24a := plsql_bug;
	else a_charge_acct_seg24a := icx_charge_acct_seg24a;
	end if;
        c_charge_acct_seg25a := icx_charge_acct_seg25a.COUNT;
	if c_charge_acct_seg25a = 0 then a_charge_acct_seg25a := plsql_bug;
	else a_charge_acct_seg25a := icx_charge_acct_seg25a;
	end if;
        c_charge_acct_seg26a := icx_charge_acct_seg26a.COUNT;
	if c_charge_acct_seg26a = 0 then a_charge_acct_seg26a := plsql_bug;
	else a_charge_acct_seg26a := icx_charge_acct_seg26a;
	end if;
        c_charge_acct_seg27a := icx_charge_acct_seg27a.COUNT;
	if c_charge_acct_seg27a = 0 then a_charge_acct_seg27a := plsql_bug;
	else a_charge_acct_seg27a := icx_charge_acct_seg27a;
	end if;
        c_charge_acct_seg28a := icx_charge_acct_seg28a.COUNT;
	if c_charge_acct_seg28a = 0 then a_charge_acct_seg28a := plsql_bug;
	else a_charge_acct_seg28a := icx_charge_acct_seg28a;
	end if;
        c_charge_acct_seg29a := icx_charge_acct_seg29a.COUNT;
	if c_charge_acct_seg29a = 0 then a_charge_acct_seg29a := plsql_bug;
	else a_charge_acct_seg29a := icx_charge_acct_seg29a;
	end if;
	c_charge_acct_seg30a := icx_charge_acct_seg30a.COUNT;
	if c_charge_acct_seg30a = 0 then a_charge_acct_seg30a := plsql_bug;
	else a_charge_acct_seg30a := icx_charge_acct_seg30a;
	end if;
   i := icx_cart_line_ida.FIRST;

   WHILE i is not null LOOP

     if (icx_need_by_datea.COUNT >0) then
           begin
             v_need_date := to_date(icx_need_by_datea(i), v_date_format);
             if v_need_date <= (sysdate - 1) then
                v_incr := icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY);
                FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_NEED_BY_DATE');
                v_error_message := FND_MESSAGE.GET;
		FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
                FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',to_char(i));
                v_error_message := FND_MESSAGE.GET || ': ' || v_error_message;
                icx_util.add_error(v_error_message);
                storeerror(v_cart_id, v_error_message);
                v_need_date := sysdate + v_incr;
              end if;
           exception
           when others then
             --add error
             v_incr := icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY);
             FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_DATE');
	     v_error_message := FND_MESSAGE.GET;
             FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
             FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',to_char(i));
             v_error_message := FND_MESSAGE.GET || ': ' || v_error_message;
             icx_util.add_error(v_error_message);
	     storeerror(v_cart_id, v_error_message);
             v_need_date := sysdate + v_incr;
           end;
	   if v_need_date is null then
	      FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_DATE');
              v_error_message := FND_MESSAGE.GET;
              FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
              FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',to_char(i));
              v_error_message := FND_MESSAGE.GET || ': ' || v_error_message;
              icx_util.add_error(v_error_message);
              storeerror(v_cart_id, v_error_message);
	      open get_head_date(v_cart_id);
	      fetch get_head_date into v_need_date;
	      close get_head_date;
	   end if;
    end if;

    n_pad := instr(a_qty_va(i), '.', 1, 2);
    if (n_pad > 2) then
	n_number := substr(a_qty_va(i), 1, n_pad-1);
    elsif (n_pad > 0) then
	n_number := 0;
    else
	n_number := a_qty_va(i);
    end if;

    if (icx_expend_item_datea.COUNT > 0) then
	begin
	   v_expend_date := to_date(icx_expend_item_datea(i), v_date_format);
	exception
	when others then
	  -- add error
	  FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_DATE');
	  v_error_message := FND_MESSAGE.GET;
          icx_util.add_error(v_error_message);
          storeerror(v_cart_id, v_error_message);
	  v_expend_date := sysdate;
	end;
    end if;



	update icx_shopping_cart_lines
	set LAST_UPDATE_DATE = sysdate,
	LAST_UPDATED_BY = v_shopper_id,
	CATEGORY_ID = decode(c_category_id, 0, CATEGORY_ID,
			     a_category_id(i)),
	ITEM_REVISION = decode(c_item_revision, 0, ITEM_REVISION,
			       a_item_revision(i)),
	NEED_BY_DATE = decode(c_line_need_date, 0, NEED_BY_DATE,
		  	      v_need_date),
	ITEM_DESCRIPTION = decode(c_item_description,
				  0 , ITEM_DESCRIPTION,
				  a_item_description(i)),
	EXPENDITURE_ITEM_DATE = decode(c_expend_item_date,
				0, EXPENDITURE_ITEM_DATE, v_expend_date),
	EXPENDITURE_ORGANIZATION_ID = decode(c_expend_org, 0,
				EXPENDITURE_ORGANIZATION_ID, a_expend_org(i)),
	QUANTITY = decode(c_qty_va, 0, QUANTITY, n_number),
	SUGGESTED_BUYER_ID = decode(c_suggested_buyer_id,
			0, SUGGESTED_BUYER_ID, a_suggested_buyer_id(i)),
        PROJECT_ID = decode(c_project_id, 0, PROJECT_ID,
				a_project_id(i)),
 	SUGGESTED_VENDOR_CONTACT = decode(c_suggested_vendor_contacta,
				0, SUGGESTED_VENDOR_CONTACT,
				a_suggested_vendor_contacta(i)),
	SUGGESTED_VENDOR_ITEM_NUM = decode(c_suggested_vendor_item_numa,
				0, SUGGESTED_VENDOR_ITEM_NUM,
				a_suggested_vendor_item_numa(i)),
	SUGGESTED_VENDOR_NAME = decode(c_suggested_vendor_namea,
				0, SUGGESTED_VENDOR_NAME,
				a_suggested_vendor_namea(i)),
	SUGGESTED_VENDOR_PHONE = decode(c_suggested_vendor_phonea,
				0, SUGGESTED_VENDOR_PHONE,
				a_suggested_vendor_phonea(i)),
	SUGGESTED_VENDOR_SITE = decode(c_suggested_vendor_sitea,
				0, SUGGESTED_VENDOR_SITE,
				a_suggested_vendor_sitea(i)),
	TASK_ID = decode(c_task_id, 0, TASK_ID, a_task_id(i)),
	UNIT_OF_MEASURE = decode(c_unit_of_measurement,
				 0, UNIT_OF_MEASURE,
				 a_unit_of_measurement(i)),
	UNIT_PRICE = decode(c_unit_price, 0, UNIT_PRICE,
			    a_unit_price(i)),
	DELIVER_TO_LOCATION_ID = decode(c_deliver_to_location_id_l,
				0, DELIVER_TO_LOCATION_ID,
				a_deliver_to_location_id_l(i)),
	DESTINATION_ORGANIZATION_ID = decode(c_dest_org_id_l,
				0, DESTINATION_ORGANIZATION_ID,
				a_dest_org_id_l(i)),
	DELIVER_TO_LOCATION = decode(c_deliver_to_location_l,
				0, DELIVER_TO_LOCATION,
				a_deliver_to_location_l(i)),
	LINE_ATTRIBUTE1 = decode(c_line_attribute_1a,
				0, LINE_ATTRIBUTE1,
				a_line_attribute_1a(i)),
	LINE_ATTRIBUTE2 = decode(c_line_attribute_2a,
				0, LINE_ATTRIBUTE2,
				a_line_attribute_2a(i)),
	LINE_ATTRIBUTE3 = decode(c_line_attribute_3a,
				0, LINE_ATTRIBUTE3,
				a_line_attribute_3a(i)),
	LINE_ATTRIBUTE4 = decode(c_line_attribute_4a,
				0, LINE_ATTRIBUTE4,
				a_line_attribute_4a(i)),
	LINE_ATTRIBUTE5 = decode(c_line_attribute_5a,
				0, LINE_ATTRIBUTE5,
				a_line_attribute_5a(i)),
	LINE_ATTRIBUTE6 = decode(c_line_attribute_6a,
				0, LINE_ATTRIBUTE6,
				a_line_attribute_6a(i)),
	LINE_ATTRIBUTE7 = decode(c_line_attribute_7a,
				0, LINE_ATTRIBUTE7,
				a_line_attribute_7a(i)),
	LINE_ATTRIBUTE8 = decode(c_line_attribute_8a,
				0, LINE_ATTRIBUTE8,
				a_line_attribute_8a(i)),
	LINE_ATTRIBUTE9 = decode(c_line_attribute_9a,
				0, LINE_ATTRIBUTE9,
				a_line_attribute_9a(i)),
	LINE_ATTRIBUTE10 = decode(c_line_attribute_10a,
				0, LINE_ATTRIBUTE10,
				a_line_attribute_10a(i)),
	LINE_ATTRIBUTE11 = decode(c_line_attribute_11a,
				0, LINE_ATTRIBUTE11,
				a_line_attribute_11a(i)),
	LINE_ATTRIBUTE12 = decode(c_line_attribute_12a,
				0, LINE_ATTRIBUTE12,
				a_line_attribute_12a(i)),
	LINE_ATTRIBUTE13 = decode(c_line_attribute_13a,
				0, LINE_ATTRIBUTE13,
				a_line_attribute_13a(i)),
	LINE_ATTRIBUTE14 = decode(c_line_attribute_14a,
				0, LINE_ATTRIBUTE14,
				a_line_attribute_14a(i)),
	LINE_ATTRIBUTE15 = decode(c_line_attribute_15a,
				0, LINE_ATTRIBUTE15,
				a_line_attribute_15a(i))
--bug 690784 command out the following line and add two lines
--	where CART_LINE_ID = icx_cart_line_ida(i);
	where CART_ID = v_cart_id
	and CART_LINE_ID = icx_cart_line_ida(i);
--end modification

	update icx_cart_line_distributions
	set LAST_UPDATE_DATE = sysdate,
	CHARGE_ACCOUNT_SEGMENT1 = decode(c_charge_acct_seg1a,
				0, CHARGE_ACCOUNT_SEGMENT1,
				a_charge_acct_seg1a(i)),
	CHARGE_ACCOUNT_SEGMENT2 = decode(c_charge_acct_seg2a,
				0, CHARGE_ACCOUNT_SEGMENT2,
				a_charge_acct_seg2a(i)),
	CHARGE_ACCOUNT_SEGMENT3 = decode(c_charge_acct_seg3a,
				0, CHARGE_ACCOUNT_SEGMENT3,
				a_charge_acct_seg3a(i)),
	CHARGE_ACCOUNT_SEGMENT4 = decode(c_charge_acct_seg4a,
				0, CHARGE_ACCOUNT_SEGMENT4,
				a_charge_acct_seg4a(i)),
	CHARGE_ACCOUNT_SEGMENT5 = decode(c_charge_acct_seg5a,
				0, CHARGE_ACCOUNT_SEGMENT5,
				a_charge_acct_seg5a(i)),
	CHARGE_ACCOUNT_SEGMENT6 = decode(c_charge_acct_seg6a,
				0, CHARGE_ACCOUNT_SEGMENT6,
				a_charge_acct_seg6a(i)),
	CHARGE_ACCOUNT_SEGMENT7 = decode(c_charge_acct_seg7a,
				0, CHARGE_ACCOUNT_SEGMENT7,
				a_charge_acct_seg7a(i)),
	CHARGE_ACCOUNT_SEGMENT8 = decode(c_charge_acct_seg8a,
				0, CHARGE_ACCOUNT_SEGMENT8,
				a_charge_acct_seg8a(i)),
	CHARGE_ACCOUNT_SEGMENT9 = decode(c_charge_acct_seg9a,
				0, CHARGE_ACCOUNT_SEGMENT9,
				a_charge_acct_seg9a(i)),
	CHARGE_ACCOUNT_SEGMENT10 = decode(c_charge_acct_seg10a,
				0, CHARGE_ACCOUNT_SEGMENT10,
				a_charge_acct_seg10a(i)),
	CHARGE_ACCOUNT_SEGMENT11 = decode(c_charge_acct_seg11a,
				0, CHARGE_ACCOUNT_SEGMENT11,
				a_charge_acct_seg11a(i)),
	CHARGE_ACCOUNT_SEGMENT12 = decode(c_charge_acct_seg12a,
				0, CHARGE_ACCOUNT_SEGMENT12,
				a_charge_acct_seg12a(i)),
	CHARGE_ACCOUNT_SEGMENT13 = decode(c_charge_acct_seg13a,
				0, CHARGE_ACCOUNT_SEGMENT13,
				a_charge_acct_seg13a(i)),
	CHARGE_ACCOUNT_SEGMENT14 = decode(c_charge_acct_seg14a,
				0, CHARGE_ACCOUNT_SEGMENT14,
				a_charge_acct_seg14a(i)),
	CHARGE_ACCOUNT_SEGMENT15 = decode(c_charge_acct_seg15a,
				0, CHARGE_ACCOUNT_SEGMENT15,
				a_charge_acct_seg15a(i)),
	CHARGE_ACCOUNT_SEGMENT16 = decode(c_charge_acct_seg16a,
                                0, CHARGE_ACCOUNT_SEGMENT16,
                                a_charge_acct_seg16a(i)),
        CHARGE_ACCOUNT_SEGMENT17 = decode(c_charge_acct_seg17a,
                                0, CHARGE_ACCOUNT_SEGMENT17,
                                a_charge_acct_seg17a(i)),
        CHARGE_ACCOUNT_SEGMENT18 = decode(c_charge_acct_seg18a,
                                0, CHARGE_ACCOUNT_SEGMENT18,
                                a_charge_acct_seg18a(i)),
        CHARGE_ACCOUNT_SEGMENT19 = decode(c_charge_acct_seg19a,
                                0, CHARGE_ACCOUNT_SEGMENT19,
                                a_charge_acct_seg19a(i)),
        CHARGE_ACCOUNT_SEGMENT20 = decode(c_charge_acct_seg20a,
                                0, CHARGE_ACCOUNT_SEGMENT20,
                                a_charge_acct_seg20a(i)),
        CHARGE_ACCOUNT_SEGMENT21 = decode(c_charge_acct_seg21a,
                                0, CHARGE_ACCOUNT_SEGMENT21,
                                a_charge_acct_seg21a(i)),
        CHARGE_ACCOUNT_SEGMENT22 = decode(c_charge_acct_seg22a,
                                0, CHARGE_ACCOUNT_SEGMENT22,
                                a_charge_acct_seg22a(i)),
        CHARGE_ACCOUNT_SEGMENT23 = decode(c_charge_acct_seg23a,
                                0, CHARGE_ACCOUNT_SEGMENT23,
                                a_charge_acct_seg23a(i)),
        CHARGE_ACCOUNT_SEGMENT24 = decode(c_charge_acct_seg24a,
                                0, CHARGE_ACCOUNT_SEGMENT24,
                                a_charge_acct_seg24a(i)),
        CHARGE_ACCOUNT_SEGMENT25 = decode(c_charge_acct_seg25a,
                                0, CHARGE_ACCOUNT_SEGMENT25,
                                a_charge_acct_seg25a(i)),
        CHARGE_ACCOUNT_SEGMENT26 = decode(c_charge_acct_seg26a,
                                0, CHARGE_ACCOUNT_SEGMENT26,
                                a_charge_acct_seg26a(i)),
        CHARGE_ACCOUNT_SEGMENT27 = decode(c_charge_acct_seg27a,
                                0, CHARGE_ACCOUNT_SEGMENT27,
                                a_charge_acct_seg27a(i)),
        CHARGE_ACCOUNT_SEGMENT28 = decode(c_charge_acct_seg28a,
                                0, CHARGE_ACCOUNT_SEGMENT28,
                                a_charge_acct_seg28a(i)),
        CHARGE_ACCOUNT_SEGMENT29 = decode(c_charge_acct_seg29a,
                                0, CHARGE_ACCOUNT_SEGMENT29,
                                a_charge_acct_seg29a(i)),
        CHARGE_ACCOUNT_SEGMENT30 = decode(c_charge_acct_seg30a,
                                0, CHARGE_ACCOUNT_SEGMENT30,
                                a_charge_acct_seg30a(i))
	where CART_LINE_ID = icx_cart_line_ida(i);


   -- dc default location id from header with id if location code is on
   -- default location id,code from header if location code is off at line
   -- LOcation Location Location

        if (c_DELIVER_TO_LOCATION_L > 0) then
   	  --Location was on
	  update icx_shopping_cart_lines
	       set (DELIVER_TO_LOCATION_ID, DESTINATION_ORGANIZATION_ID) =
		   (select hrl.location_id,
               		   nvl(hrl.inventory_organization_id,
                   	       fsp.inventory_organization_id)
		    from hr_locations hrl,
	                 financials_system_parameters fsp
                    where sysdate < nvl(hrl.inactive_date, sysdate + 1)
                    and hrl.location_code =
			icx_shopping_cart_lines.DELIVER_TO_LOCATION)
	   where DELIVER_TO_LOCATION_ID is null
	   and   CART_ID = v_cart_id;

       else
  	  -- if location on at parent copy org from the parent
	  if (icx_deliver_to_location <> FND_API.G_MISS_CHAR) then
	      update icx_shopping_cart_lines
		  set (DELIVER_TO_LOCATION_ID, DESTINATION_ORGANIZATION_ID,
			DELIVER_TO_LOCATION) =
		      (select DELIVER_TO_LOCATION_ID,
			      DESTINATION_ORGANIZATION_ID,
			      DELIVER_TO_LOCATION
		       from   icx_shopping_Carts
		       where  cart_id = v_cart_id)
	      where cart_id = v_cart_id;
	  end if;
       end if;

      -- If supplier can be entered and the field is blank, set to the first line

        if (c_suggested_vendor_namea > 0) then
   	   update icx_shopping_cart_lines
	   set (SUGGESTED_VENDOR_CONTACT, SUGGESTED_VENDOR_PHONE,
 	     SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_SITE) =
	    (select SUGGESTED_VENDOR_CONTACT, SUGGESTED_VENDOR_PHONE,
		    SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_SITE
	     from icx_shopping_cart_lines
	     where cart_id = v_cart_id
	     and cart_line_number = (select min(cart_line_number)
                                     from icx_shopping_cart_lines
                                     where cart_id = v_cart_id
                                     and suggested_vendor_name is not NULL))

   	   where cart_id = v_cart_id
	   and SUGGESTED_VENDOR_NAME is null;
        end if;

        -- validate distribution account on R11
        icx_req_acct2.validate_charge_account(v_cart_id,
				              icx_cart_line_ida(i));


	-- now get the account
/*
	icx_req_custom.cart_custom_build_req_account(icx_cart_line_ida(i),
						     v_account_num,
						     v_account_id,
						     v_return_code);

         if ((v_account_num is null) and (v_account_id is null)) then
	    -- get the default account
	    open acctBuild(v_cart_id,icx_cart_line_ida(i), n_emp_id, n_org_id);
	    fetch acctBuild into v_account_id, v_expense_account;
	    close acctBuild;
	    if v_account_id is null then
		v_account_id := v_expense_account;
	    end if;
	end if;
	if ((v_account_num is null) and (v_account_id is null)) then
            --add error
             FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
             FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', a_item_description(i));
	     v_error_message := FND_MESSAGE.GET;
             icx_util.add_error(v_error_message);
	     storeerror(v_cart_id, v_error_message);
	else
	  if (v_account_id is not null) then
               select count(*) into v_exist
               from gl_sets_of_books gsb,
		    financials_system_parameters fsp,
                    gl_code_combinations gl
               where gsb.SET_OF_BOOKS_ID = fsp.set_of_books_id
               and   gsb.CHART_OF_ACCOUNTS_ID = gl.CHART_OF_ACCOUNTS_ID
               and   gl.CODE_COMBINATION_ID = v_account_id;
               if (v_exist = 0) then
                  --add error
                  FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
                  FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', a_item_description(i));
		  v_error_message := FND_MESSAGE.GET;
                  icx_util.add_error(v_error_message);
                  storeerror(v_cart_id, v_error_message);
                  -- set saved_flag to 4 (error exists)
              end if;
            else

                open get_acct;
                fetch get_acct into v_structure;
                close get_acct;
                v_account_id := fnd_flex_ext.get_ccid('SQLGL', 'GL#',
                                     v_structure,
                                     to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
                                     v_account_num);
                if (v_account_id is null) or (v_account_id = 0) then
                  --add error
                  FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
                  FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', a_item_description(i));
		  v_error_message := FND_MESSAGE.GET;
                  icx_util.add_error(v_error_message);
                  storeerror(v_cart_id, v_error_message);
                  v_account_id := null;
                end if;
           end if;
         end if;

	 icx_req_custom.cart_custom_build_req_account2(icx_cart_line_ida(i),
						       v_variance_acct_id,
						       v_budget_acct_id,
						       v_accrual_acct_id,
						       v_return_code);

         update icx_cart_line_distributions
         set CHARGE_ACCOUNT_ID = v_account_id,
	 ACCRUAL_ACCOUNT_ID = v_accrual_acct_id,
	 VARIANCE_ACCOUNT_ID = v_variance_acct_id,
	 BUDGET_ACCOUNT_ID = v_budget_acct_id
         where CART_LINE_ID = icx_cart_line_ida(i);
*/


	i := icx_cart_line_ida.NEXT(i);
   end LOOP;


    /*********************************************************************/
    /*********                  Validate LINES                  **********/
    /*********************************************************************/


   icx_req_custom.reqs_validate_line(emergency, v_cart_id);

   --empty lines
   for prec in line_ids(v_cart_id) loop
	delete icx_cart_line_distributions
	where cart_line_id = prec.cart_line_id;
   end loop;
   delete icx_shopping_cart_lines
   where (quantity is null
           or    quantity = 0)
   and cart_id = v_cart_id;

   -- Validate LOcation Location Location
   if (c_DELIVER_TO_LOCATION_L > 0) then

	--that just updated valid locations

	v_errored := FALSE;

	for prec in invalid_locations(v_cart_id, n_org_id) loop
	 v_error_message :=
                        icx_util.getPrompt(601, 'ICX_SHOPPING_CART_HEADER_R',
                                           178, 'ICX_DELIVER_TO_LOCATION');

         FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
         FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_message || ': ' ||
				prec.DELIVER_TO_LOCATION);
         v_error_message := FND_MESSAGE.GET;

         FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
         FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',to_char(prec.cart_line_number));
         v_error_message := FND_MESSAGE.GET || ': ' || v_error_message;
         icx_util.add_error(v_error_message);
         storeerror(v_cart_id,v_error_message);
	end loop;
	update icx_shopping_cart_lines
	set (DELIVER_TO_LOCATION_ID,
	     DESTINATION_ORGANIZATION_ID) =
	    (select null,
		    DESTINATION_ORGANIZATION_ID
	     from icx_shopping_carts
	     where cart_id = v_cart_id)
	where cart_id = v_cart_id
	and   DELIVER_TO_LOCATION_ID is null;
   end if;

   if (emergency = 'YES') then
      -- in an emergency, you can only have one supplier
      SELECT count(distinct(SUGGESTED_VENDOR_NAME)) into supp_count
      FROM   icx_shopping_cart_lines
      where  cart_id = v_cart_id;

      if (supp_count > 1) then
	 FND_MESSAGE.SET_NAME('ICX','ICX_EMERGENCY_PO_VENDOR');
         v_error_message := FND_MESSAGE.GET;
         icx_util.add_error(v_error_message);
         storeerror(v_cart_id,v_error_message);
      elsif (supp_count = 0) then
         v_error_message := icx_util.getPrompt(601,'ICX_SHOPPING_CART_LINES_EMG_R',178,'ICX_SUGGESTED_VENDOR_NAME');
         FND_MESSAGE.SET_NAME('ICX','ICX_REQUIRED_FIELD');
         FND_MESSAGE.SET_TOKEN('FIELD_NAME_TOKEN',v_error_message);
         v_error_message := FND_MESSAGE.GET;

--htp.p(v_error_message);
--return;

	icx_util.add_error(v_error_message);
         storeerror(v_cart_id,v_error_message);
      end if;
   end if;


   -- Check to see how many lines there are
   open get_line_count(v_cart_id);
   fetch get_line_count into supp_count;
   close get_line_count;

   end if;  /* if icx_cart_line_ida.COUNT > 0 */


   if (icx_util.error_count = 0) then
     l_err_loadinterface := 'N';
     if user_action = 'SAVE'  then
        update icx_shopping_Carts
        set saved_flag = 1
        where cart_id = v_cart_id
        and nvl(org_id,-9999) = nvl(n_org_id,-9999);
     elsif ((user_action = 'PLACE ORDER') and (supp_count > 0)) then
        -- Load the req interface table....
        -- in here
	update icx_shopping_Carts
	set saved_flag = 0
	where cart_id = v_cart_id
        and nvl(org_id, -9999) = nvl(n_org_id, -9999);
        begin
          icx_load_req_interface.load_shopcart_to_interface(v_cart_id);
          exception
           WHEN OTHERS THEN
             l_err_num := SQLCODE;
             l_error_message := SQLERRM;
             select substr(l_error_message,12,512) into l_err_mesg from dual;
             icx_util.add_error(l_err_mesg);
             storeerror(v_cart_id,l_err_mesg);
             l_err_loadinterface := 'Y';

        end;

        if l_err_loadinterface = 'N' then
          update icx_shopping_carts
          set saved_flag = '2'
          where saved_flag = '0'
          and cart_id = v_cart_id
          and   nvl(org_id, -9999)  = nvl(n_org_id, -9999);
        end if;
     end if;
    else
          -- set saved_flag to 4 (error exists)
          update icx_shopping_carts
          set saved_flag = '4'
          where cart_id = v_cart_id
          and nvl(org_id, -9999) = nvl(n_org_id, -9999);

    end if;

 else
 	-- delete the cart
	delete icx_shopping_carts
	where  cart_id = v_cart_id
        and   shopper_id = v_shopper_id;

	delete icx_cart_line_distributions
	where cart_id = v_cart_id;

 	delete icx_shopping_cart_lines
	where cart_id = v_cart_id;

	delete icx_cart_distributions
	where cart_id = v_cart_id;


 end if;


  if (user_action = 'PLACE ORDER') then
	v_action := 'PO';
  else
  	v_action := user_action;
  end if;

--changed by alex

  if (icx_util.error_count = 0) and (user_action <> 'MODIFY') and
     (user_action <> 'GET_PO_MODIFY') and (user_action <> 'ATTACHMENT') and
     ((v_action <> 'PO') or (supp_count > 0)) then
     become_top(icx_cart_id, emergency, v_action);
  elsif (icx_util.error_count = 0) and (user_action = 'ATTACHMENT') then

	--This call does not repaint the whole page under IE 3.0.  alex
/*
	fnd_webattch.Summary(function_name=>icx_call.encrypt2('ICX_REQS'),
			     entity_name=>icx_call.encrypt2(entity_name),
			     pk1_value=>icx_call.encrypt2(pk1),
			     pk2_value=>icx_call.encrypt2(pk2),
   			  	pk3_value=>icx_call.encrypt2(pk3),
				pk4_value=>icx_call.encrypt2( NULL),
				pk5_value=>icx_call.encrypt2(NULL),
				from_url=>icx_call.encrypt2(from_url),
				query_only=>icx_call.encrypt2(query_only));
*/

	htp.p('<BODY onLoad="open(''fnd_webattch.Summary?function_name=' ||
				icx_call.encrypt2('ICX_REQS')||
				'&entity_name=' ||  icx_call.encrypt2(entity_name) ||
				'&pk1_value=' || icx_call.encrypt2(pk1) ||
				'&pk2_value=' || icx_call.encrypt2(pk2) ||
				'&pk3_value=' || icx_call.encrypt2(pk3) ||
		 		'&pk4_value=' || icx_call.encrypt2( NULL) ||
				'&pk5_value=' || icx_call.encrypt2( NULL) ||
				'&from_url=' || icx_call.encrypt2(from_url) ||
				'&query_only=' || icx_call.encrypt2(query_only) ||
				''', ''_top'')">');

  else
     ICX_REQ_ORDER.my_order(N_ORG => icx_call.encrypt2(d_org_id),
			    N_EMERGENCY => icx_call.encrypt2(emergency),
			    N_CART_ID => icx_cart_id);
  end if;



 end if;


exception
when cart_exists then
     become_top(icx_cart_id, emergency, 'CE');
when OTHERS then
   l_err_num := SQLCODE;
   l_error_message := SQLERRM;
   select substr(l_error_message,12,512) into l_err_mesg from dual;
   icx_util.add_error(l_err_mesg);
   storeerror(v_cart_id,l_err_mesg);
   icx_util.error_page_print;
   return;
end;

end ICX_REQ_SUBMIT;

/
