--------------------------------------------------------
--  DDL for Package Body ICX_REQ_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_CATEGORIES" as
/* $Header: ICXRQCAB.pls 115.4 99/07/17 03:22:45 porting sh $ */

--*********************************************************
-- GLOBAL VAR
--*******************************************************


--**********************************************************
-- LOCAL PROCEDURES NOT DECLARED IN SPEC
--**********************************************************

------------------------------------------------------------
procedure createDummyPage(p_where number, nodeId varchar2, nodeIndex varchar2, v_string long,v_first_time_flag varchar2) is
------------------------------------------------------------
begin
   -- open html
   htp.htmlOpen;
   htp.headOpen;
   htp.headClose;

   if (v_first_time_flag = 'Y') then
       htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.openTemplate(''' || icx_util.replace_quotes(nodeId) || ''',document.GetChildren.nodeId,document.GetChildren.nodeIndex)"');
   else
      htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.addChildren(''' || icx_util.replace_quotes(nodeId) || ''',document.GetChildren.nodeId,document.GetChildren.nodeIndex)"');
   end if;

       htp.formOpen(curl        =>'ICX_REQ_CATEGORIES.GetCategoryChildren',
                    cmethod     => 'POST',
                    cattributes => 'name=''GetChildren'''
                   );

       htp.formHidden('nodeId',  cvalue => v_string);
       htp.formHidden('p_where', cvalue => p_where);
       htp.formHidden('nodeIndex', cvalue => nodeIndex);

       htp.formClose;
   htp.bodyClose;
   htp.htmlClose;

end createDummyPage;

--**********************************************************
-- LOCAL PROCEDURES NOT DECLARED IN SPEC
--**********************************************************


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

------------------------------------------------------------
procedure GetCategoryTop(v_org_id number) is
------------------------------------------------------------


   cursor cat_set is
   select category_set_id,
          validate_flag
   from   mtl_default_sets_view
   WHERE  functional_area_id = 2;


y_table            icx_util.char240_table;
where_clause       varchar2(2000);

v_node_id          varchar2(240);
v_name             varchar2(240);
v_no_of_children   number;
v_children_loaded  varchar2(100);
p_where            varchar2(240);
counter            number;
i                  number;
v_dcdName          varchar2(240) := owa_util.get_cgi_env('SCRIPT_NAME');
v_category_set_id  number;
v_validate_flag    varchar2(1);

begin

-- dbms_session.set_sql_trace(TRUE);

   -- Need to find the category_set_id for purchasing
   open cat_set;
     fetch cat_set into v_category_set_id, v_validate_flag;
   close cat_set;

   where_clause := 'relationship_type = ''TOP'' AND CATEGORY_SET_ID =' || v_category_set_id;
   -- Query childrens.
   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_RELATED_CATEGORIES_DISPLAY',
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                              P_WHERE_CLAUSE 		=> where_clause,
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F');

   counter := 1;

   if ak_query_pkg.g_results_table.count > 0 then
      htp.p('TOP_CATEGORIES = new MakeArray(' || ak_query_pkg.g_results_table.count || ');');
      for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop

         v_node_id := ak_query_pkg.g_results_table(i).value2;  -- Category id
         v_name    := ak_query_pkg.g_results_table(i).value4;  -- Category name

         p_where := icx_call.encrypt2(v_node_id || '*' || v_org_id || '*' || v_name || '**]');


         select count(-1) into v_no_of_children
         from   icx_related_categories_val_v
         where  CATEGORY_ID = v_node_id
         and    CATEGORY_SET_ID = v_category_set_id  /* new*/
         and    RELATIONSHIP_TYPE <> 'TOP';
         if v_no_of_children > 0 then
                v_children_loaded := 'false';
         else
                v_children_loaded := 'true';
         end if;

         htp.p('TOP_CATEGORIES[' || counter || ']= new node(' || v_node_id || ',"' ||
                                v_name || '",' || v_children_loaded || ',"' ||
                                v_dcdName || '/ICX_REQ_CATEGORIES.catalog_items?p_where=' || p_where  -- Node Link
                                || '","' || p_where || '");');
         counter := counter + 1;

      end loop; -- end i

   else -- No hierchy setup use regular categories

      ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 178,
                             P_PARENT_REGION_CODE    => 'ICX_REQ_CATEGORIES',
                             P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                             P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                             P_WHERE_CLAUSE          => ' FUNCTIONAL_AREA_ID = 2',

                             P_RETURN_PARENTS        => 'T',
                             P_RETURN_CHILDREN       => 'F');

      if ak_query_pkg.g_results_table.count > 0 then
         htp.p('TOP_CATEGORIES = new MakeArray(' || ak_query_pkg.g_results_table.count || ');');
         for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop


            v_node_id := ak_query_pkg.g_results_table(i).value3;  -- Category id
            v_name    := ak_query_pkg.g_results_table(i).value1;  -- Category name

            p_where := icx_call.encrypt2(v_node_id || '*' || v_org_id || '*' || v_name || '**]');


            v_children_loaded := 'true';
            htp.p('TOP_CATEGORIES[' || counter || ']= new node(' || v_node_id || ',"' ||
                                  v_name || '",' || v_children_loaded || ',"' ||
                                  v_dcdName || '/ICX_REQ_CATEGORIES.catalog_items?p_where=' || p_where  -- Node Link
                                || '","' || p_where || '");');
            counter := counter + 1;

         end loop;
      else  -- No Categories
         htp.p('TOP_CATEGORIES = new MakeArray(0);');
      end if;

   end if; -- No hierchy setup

-- dbms_session.set_sql_trace(FALSE);

end GetCategoryTop;


------------------------------------------------------------
procedure categories(start_row in number default 1,
                     c_end_row in number default null,
                     p_where   in number) is
------------------------------------------------------------
v_lang           varchar2(5);
v_dcdName        varchar2(1000);
v_frame_location varchar2(1024);
n_temp           number;

begin

-- dbms_session.set_sql_trace(TRUE);

    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    --get dcd name
    v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    htp.htmlOpen;
       htp.headOpen;
       htp.headClose;
       htp.framesetOpen('','250,*','BORDER=5');
           htp.framesetOpen('*,0','','BORDER=0');
                  htp.frame('/OA_HTML/' || v_lang || '/ICXCATH.htm', 'left_frame', '0','0', cscrolling=>'auto', cnoresize => '' );
                  --htp.frame(csrc  =>  v_dcdName || '/ICX_REQ_CATEGORIES.GetCategoryChildren?n_org=' || n_org, --URL
                  htp.frame(csrc  =>  v_dcdName || '/ICX_REQ_CATEGORIES.GetCategoryChildren?p_where=' || p_where,  -- URL
                            cname =>  'dummy', 	   --Window Name
                            cmarginwidth   => '0', --    Value in pixels
                            cmarginheight  => '0', --    Value in pixels
                            cscrolling => 'NO',
--		            cnoresize => '',
			    cattributes => 'FRAMEBORDER=NO');
--                            cscrolling     => 'NO',--    yes | no | auto
--                            cnoresize      => 'NORESIZE' );
           htp.framesetClose;

           v_frame_location := v_dcdName || '/ICX_REQ_CATEGORIES.catalog_items?';

           if c_end_row is not null then
               v_frame_location := v_frame_location || 'p_start_row=' || start_row  ||'&p_end_row=' || c_end_row || '&p_where=' || p_where;
           else
               v_frame_location := v_frame_location || 'p_where=' || p_where;
           end if;
           htp.frame( v_frame_location, 'right_frame', '0','0',  cscrolling=>'auto');

       htp.framesetClose;
    htp.htmlClose;

-- dbms_session.set_sql_trace(FALSE);
end categories;

------------------------------------------------------------
procedure GetCategoryChildren (p_where in number,
                               nodeId  in varchar2  default null,
			       nodeIndex in varchar2 default null) is
------------------------------------------------------------

y_table            icx_util.char240_table;
where_clause       varchar2(2000);

v_p_where          number;
-- childrenString     varchar2(2000);
-- Fix for bug 517695
childrenString     long;

v_node_id          varchar2(240);
v_name             varchar2(240);
v_no_of_children   number;
v_org              number;
params             icx_on_utilities.v80_table;

v_dcdName          varchar2(240) := owa_util.get_cgi_env('SCRIPT_NAME');
v_first_time_flag  varchar2(1);

  cursor cat_set is
  select category_set_id,
        validate_flag
  from   mtl_default_sets_view
  WHERE  functional_area_id = 2;

  cursor getAnyTop(v_category_set_id number) is
  select category_id
  from icx_related_categories_val_v
  where relationship_type = 'TOP'
  and category_set_id = v_category_set_id;


v_validate_flag varchar2(1);
v_cat_set_id number;
v_anytop_id varchar2(240);

begin

-- dbms_session.set_sql_trace(TRUE);

-- Check if session is valid
if (icx_sec.validatesession('ICX_REQS')) then

  --decrypt2 p_where
  if p_where is not null then
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where), params);
        --cat_id := params(1);
        v_org := params(2);
  end if;


   /* Moved from else condition below 1/28/97 */
    -- Need to find the category_set_id for purchasing
    open cat_set;
    fetch cat_set into v_cat_set_id, v_validate_flag;
    close cat_set;

  if nodeId is not null  and
     v_cat_set_id is not NULL then
     -- where_clause := 'category_id = ' || nodeId || ' AND ';
     where_clause := 'category_id = ' || nodeId || ' AND category_set_id = ' || v_cat_set_id || ' AND ';
  else


    open getAnyTop(v_cat_set_id);
    fetch getAnyTop into v_anytop_id;
    close getAnyTop;

    if v_anytop_id is not NULL  and
       v_cat_set_id is not NULL then

    where_clause := 'category_id = ' || v_anytop_id || ' AND category_set_id = '|| v_cat_set_id || ' AND ';

    end if;

  end if;

   where_clause := where_clause || ' relationship_type = ''CHILD''';
   -- Query childrens.
   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_RELATED_CATEGORIES_DISPLAY',
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                              P_WHERE_CLAUSE 		=> where_clause,
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F');

   if ak_query_pkg.g_results_table.count > 0 then
   for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop

         v_node_id := ak_query_pkg.g_results_table(i).value3;  -- Related Category id
         v_name    := ak_query_pkg.g_results_table(i).value4;  -- Related Category name

	 v_p_where := icx_call.encrypt2(v_node_id || '*' || v_org || '*' || v_name || '**]');

         select count(-1) into v_no_of_children
         from   icx_related_categories_val_v
         where    CATEGORY_ID = v_node_id
         and      CATEGORY_SET_ID = v_cat_set_id
         and    RELATIONSHIP_TYPE <> 'TOP';

         childrenString := childrenString || v_node_id || '~~' || v_name || '~~'
                                          || v_no_of_children || '~~'
                                          ||  v_dcdName || '/ICX_REQ_CATEGORIES.catalog_items?p_where=' || v_p_where  -- Node Link
                                          ||  '~~' || v_p_where || '~~' ;


   end loop; -- end i
   end if;


   if nodeId is not NULL then
      v_first_time_flag := 'N';
      createDummyPage(v_p_where, nodeId, nodeIndex,childrenString, v_first_time_flag);
   else
     if v_node_id is not NULL then
        v_first_time_flag := 'N';
        createDummyPage(v_p_where,nodeId,nodeIndex,childrenString,v_first_time_flag);
     else
        v_first_time_flag := 'Y';
        createDummyPage(v_p_where, v_anytop_id, nodeIndex, childrenString,v_first_time_flag);
     end if;
   end if;


end if;

-- dbms_session.set_sql_trace(FALSE);

end GetCategoryChildren;

procedure total_page(l_cart_id number,
		     l_dest_org_id number,
                     l_rows_added number default 0,
                     l_rows_updated number default 0,
		     p_cat_name varchar2 default NULL,
                     p_start_row IN number default 1,
                     p_end_row IN number default NULL,
                     p_where IN varchar2,
		     end_row IN number default null,
		     p_query_set IN number default null,
		     p_row_count IN number default null) is

 l_message varchar2(2000);
 l_messg varchar2(2000);
 L_RETURN_TO_NEXT_MESSAGE varchar2(2000);
 l_total_price number;
 l_currency        varchar2(30);
 l_fmt_mask        varchar2(30);
 l_money_precision  number;
 l_href1 varchar2(2000);
 l_href2 varchar2(2000);
 next_start_row number;
 next_end_row number;
 v_dcdName varchar2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');

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
   l_message :=  FND_MESSAGE.GET;
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

      l_message := l_message || '<BR><BR><BR>';
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_CATEGORY');
      l_messg := FND_MESSAGE.GET || ' ' || p_cat_name;
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_SOURCE');
      FND_MESSAGE.SET_TOKEN('SOURCE_NAME',l_messg);
      l_message := l_message || FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_CURRENT');
      l_href1 := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_NEXT');
      l_href2 := FND_MESSAGE.GET;
      l_messg := '<TABLE BORDER=0><TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcdName ||
'/ICX_REQ_CATEGORIES.catalog_items?p_start_row=' || p_start_row || '&p_end_row=' || p_end_row || '&p_where=' || p_where || '">' ||  l_href1 || '</A></B></TD></TR>';

      /* find next set start row and next set end row */
      if end_row < p_row_count
         and p_query_set is not NULL then

         next_start_row := end_row+1;
         if end_row+p_query_set > p_row_count then
             next_end_row := p_row_count;
         else
             next_end_row := end_row+p_query_set;
         end if;


         l_messg := l_messg || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcdName ||
'/ICX_REQ_CATEGORIES.catalog_items?p_start_row=' || next_start_row || '&p_end_row=' || next_end_row || '&p_where=' || p_where || '">' || l_href2 || '</A></B></TD></TR>';

      end if;

      -- MESSAGE NEEDS TO BE SWITCHED TO REVIEW MY ORDER
      FND_MESSAGE.SET_NAME('ICX','ICX_REVIEW_ORDER');
      l_return_to_next_message := FND_MESSAGE.GET;
      l_messg := l_messg || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="javascript:parent.parent.parent.switchFrames(''my_order'')">' || l_return_to_next_message || '</A></B></TD></TR>';


      l_messg := l_messg || '</TABLE>';
      l_message := l_message || l_messg;
   end if;

      htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.winOpen(''nav'', ''catalog'')"');
         htp.p('<H3>'|| l_message ||'</H3>');
      htp.bodyClose;
end;



procedure submit_items (cartId IN number,
		      p_emergency IN number default NULL,
                      p_start_row IN number default 1,
		      p_end_row IN number default NULL,
		      p_where IN varchar2,
		      p_cat_name IN varchar2 default NULL,
		      end_row IN number default NULL,
		      p_query_set IN number default NULL,
                      p_row_count IN number default NULL,
                      Quantity IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty,
                      Line_Id IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty) is

  l_line_id number;
  l_num_rows number;
  l_cart_line_id number;
  l_shopper_id number;
  l_org_id number;
  params   icx_on_utilities.v80_table;
  l_qty number;
  l_error_id NUMBER;
  l_err_num NUMBER;
  l_error_message VARCHAR2(2000);
  l_err_mesg VARCHAR2(240);
  l_cart_id number;
  l_emergency varchar2(10);
  l_cart_line_number number;
  l_pad number;
  l_cat_name varchar2(1000);

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
            deliver_to_location,
	    destination_organization_id,
            org_id
     from icx_shopping_carts
     where cart_id = v_cart_id;
--     and nvl(org_id,-9999) = nvl(v_org_id,-9999);

  cursor get_max_line_number(v_cart_id number) is
     select max(cart_line_number)
     from icx_shopping_cart_lines
     where cart_id = v_cart_id;

  l_need_by_date date;
  l_deliver_to_location_id number;
  l_dest_org_id number;
  l_rows_added number;
  l_rows_updated number;
  l_deliver_to_location varchar2(240);
  l_total_price number;
  l_dummy number;

  l_emp_id number;
  l_account_id NUMBER := NULL;
  l_account_num VARCHAR2(2000) := NULL;
  l_segments fnd_flex_ext.SegmentArray;

begin

  if icx_sec.validatesession then

  l_rows_added := 0;
  l_rows_updated := 0;
  l_num_rows := Quantity.COUNT;
  l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  -- l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
  if p_where is not NULL then
       icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where),params);
       l_org_id := params(2);
  end if;

  l_cart_id := icx_call.decrypt2(cartId);
  l_emergency := icx_call.decrypt2(p_emergency);

  if l_cart_id is not NULL then
     open get_cart_header_info(l_cart_id);
     fetch get_cart_header_info into l_need_by_date, l_emp_id,
          l_deliver_to_location_id,l_deliver_to_location,l_dest_org_id,l_org_id;
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

    if l_qty  is not NULL and l_qty > 0 then

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
        /* close semaphore */

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
/* comment out this line for bug 696626
        l_deliver_to_location_id,l_deliver_to_location,a.vendor_id,a.vendor_name,a.vendor_site_code,
 and replace with the following line*/
        l_deliver_to_location_id,l_deliver_to_location,a.agent_id,a.vendor_name,a.vendor_site_code,
        l_need_by_date,a.vendor_contact_name,
        a.vendor_product_num,a.item_number,sysdate,l_shopper_id,l_org_id,'N',
        a.po_header_id, a.line_num
        from icx_po_suppl_catalog_items_v a
        where a.po_line_id = l_line_id;

/*
        insert into icx_cart_line_distributions(cart_id,cart_line_id,distribution_id,
              last_updated_by,last_update_date,last_update_login,
	      creation_date,created_by,org_id)
        values (l_cart_id,l_cart_line_id,icx_cart_line_distributions_s.nextval,l_shopper_id,
		sysdate,l_shopper_id,sysdate,l_shopper_id,l_org_id);
*/
          -- Get the default accounts and update distributions
          icx_req_acct2.get_default_account(l_cart_id,l_cart_line_id,
                        l_emp_id,l_org_id,l_account_id,l_account_num);

        commit;

        l_rows_added := l_rows_added + 1;

       else


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

  /* call customer default line routines */
  if l_emergency is not NULL and l_emergency = 'YES' then
     icx_req_custom.reqs_default_lines(l_emergency,l_cart_id);
  else
     icx_req_custom.reqs_default_lines('NO',
				    l_cart_id);
  end if;

  total_page(l_cart_id,l_dest_org_id,l_rows_added,l_rows_updated,p_cat_name,
             p_start_row,p_end_row,p_where,end_row,p_query_set,p_row_count);
/*   catalog_items(p_start_row,p_end_row,p_where); */

  end if;

exception
when INVALID_NUMBER or
     VALUE_ERROR then
   l_err_num := SQLCODE;
   l_error_message := SQLERRM;
   select substr(l_error_message,12,512) into l_err_mesg from dual;
   icx_util.add_error(l_err_mesg);
   icx_util.error_page_print;

when OTHERS then
   l_err_num := SQLCODE;
   l_error_message := SQLERRM;

   select substr(l_error_message,12,512) into l_err_mesg from dual;
   icx_util.add_error(l_err_mesg);
   icx_util.error_page_print;

end;



------------------------------------------------------------
procedure catalog_items( p_start_row in number default 1,
                         p_end_row in number default null,
				 p_where in varchar2) is
------------------------------------------------------------
v_dcdName            varchar2(1000);
v_lang               varchar2(5);

begin

   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


   -- We need to split into 2 frames

   js.scriptOpen;
   htp.p('function openButWin(start_row, end_row, total_row, where) {

         var result = "' || v_dcdName ||
                      '/ICX_REQ_CATEGORIES.catalog_items_buttons?p_start_row=" +
                      start_row + "&p_end_row=" + end_row + "&p_total_rows=" +
                      total_row + "&p_where=" + where;
            open(result, ''k_buttons'');
}
  ');

   js.scriptClose;

   htp.p('<FRAMESET ROWS="*,40" BORDER=0>');
   htp.p('<FRAME SRC="' || v_dcdName ||
         '/ICX_REQ_CATEGORIES.catalog_items_display?p_start_row=' ||
         p_start_row || '&p_end_row=' || p_end_row || '&p_where=' ||
         p_where || '" NAME="data" FRAMEBORDER=NO MARGINWIDTH=0 MARGINHEIGHT=0 NORESIZE>');

   htp.p('<FRAME NAME="k_buttons" SRC="/OA_HTML/' ||
         v_lang || '/ICXGREEN.htm" FRAMEBORDER=NO MARGINWIDTH=0 MARGINHEIGHT=0 NORESIZE SCROLLING="NO">');
   htp.p('</FRAMESET>');

end;

------------------------------------------------------------
procedure catalog_items_buttons(p_start_row in number default 1,
                                 p_end_row in number default null,
                                 p_total_rows in number,
                                 p_where in varchar2) is
------------------------------------------------------------

v_lang              varchar2(30);
c_query_size        number;

begin

   SELECT QUERY_SET INTO c_query_size FROM ICX_PARAMETERS;

   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     htp.p('<BODY BGCOLOR="#CCFFCC">');

     htp.p('<TABLE BORDER=0>');
     htp.p('<TD>');
   icx_on_utilities2.displaySetIcons(p_language_code   => v_lang,
                                     p_packproc        => 'ICX_REQ_CATEGORIES.catalog_items',
                                     p_start_row       => p_start_row,
                                     p_stop_row        => p_end_row,
                                     p_encrypted_where => p_where,
                                     p_query_set       => c_query_size,
				     p_target          => 'parent',
                                     p_row_count       => p_total_rows);
     htp.p('</TD>');
     htp.p('<TD width=1000></TD><TD>');
     FND_MESSAGE.SET_NAME('ICX','ICX_ADD_TO_ORDER');
     icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                            P_ImageFileName   => 'FNDBNEW.gif',
                            P_OnMouseOverText => FND_MESSAGE.GET,
                            P_HyperTextCall   => 'javascript:parent.frames[0].su
bmit()',
                            P_LanguageCode    => v_lang,
                            P_JavaScriptFlag  => FALSE);

     htp.p('</TD></TABLE>');
     htp.p('</BODY>');
end;



------------------------------------------------------------
procedure catalog_items_display(p_start_row in number default 1,
                                p_end_row in number default null,
                                p_where in varchar2) is
------------------------------------------------------------

sess_web_user       number(15);
c_title             varchar2(80) := '';
c_prompts           icx_util.g_prompts_table;
v_lang              varchar2(30);
where_clause        varchar2(2000);
total_rows          number;
temp_start          number;
temp_end            number;
end_row             number;
display_text        varchar2(5000);
temp_table          icx_admin_sig.pp_table;
c_query_size        number;
v_supplier_url	  varchar2(150);
v_supplier_item_url varchar2(150);
v_item_url          varchar2(150);
v_line_id	        varchar2(65);
i                   number := 0;
j                   number := 0;
k	              binary_integer :=0;
n	              binary_integer :=0;
m	              binary_integer :=0;
v_qty_flag	        boolean := false;

y_table             icx_util.char240_table;

v_cat_id            number;
v_org               number;
counter             number := 0;
v_temp	        varchar2(240);
V_QUANTITY_LENGTH   NUMBER :=10;
v_dcdName           varchar2(1000);

params              icx_on_utilities.v80_table;
c_currency          varchar2(15);
c_money_precision   number;
c_money_fmt_mask    varchar2(32);

v_cat_name          varchar2(1000);
v_line_id_ind       number;
v_supplier_url_ind  number;
v_item_url_ind      number;
v_supplier_item_url_ind number;
g_reg_ind          number;
l_dest_org_id      number;
l_location_id      number;
l_location         varchar2(240);
l_pos              number := 0;
l_spin_pos         number := 0;

begin

-- dbms_session.set_sql_trace(TRUE);

if icx_sec.validateSession('ICX_REQS') then

   sess_web_user := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

   -- icx_util.getPrompts(178,'ICX_CATALOG_ITEMS',c_title,c_prompts);
   icx_util.getPrompts(601,'ICX_PO_SUPPL_CATALOG_ITEMS_R',c_title,c_prompts);
   icx_util.error_page_setup;


 --decrypt2 p_where
    if p_where is not null then
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where), params);
        v_cat_id := params(1);
        v_org := params(2);
        v_cat_name := params(3);
    end if;


 --If no catalog is selected then display a blank right frmae
   if (v_cat_id = '-1') then
      htp.htmlOpen;
        htp.headOpen;
          icx_util.copyright;
          htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.parent.winOpen(''nav'', ''catalog'')"');
          htp.bodyClose;
        htp.headClose;
      htp.htmlClose;
      return;
   end if;


  ICX_REQ_NAVIGATION.get_currency(v_org, c_currency, c_money_precision, c_money_fmt_mask);

 --query against ICX_PO_SUPPL_CATALOG_ITEMS_R, Only display items in this template
--   where_clause := 'organization_id = ' || v_org || ' and category_id = ' || '''' || v_cat_id || '''';
/* Modified by Suri to take care of Bug#724529 **/
   where_clause := 'category_id = ' || '''' || v_cat_id || '''';
/* End changes **/

 --order_by_clause can be done through ON
 --order_by_clause := 'sequence_num, item_number, item_description';

  --get number of rows to display
   select QUERY_SET into c_query_size from ICX_PARAMETERS;

  --set up end rows to display
   if p_end_row is null then
      end_row := c_query_size;
   else
      end_row := p_end_row;
   end if;

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_PO_SUPPL_CATALOG_ITEMS_R',
  			            p_where_clause 		=> where_clause,
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F',
			      P_RANGE_LOW             => p_start_row,
			      P_RANGE_HIGH	      => end_row);

   --get number of rows to display
    g_reg_ind := ak_query_pkg.g_regions_table.FIRST;
    total_rows := ak_query_pkg.g_regions_table(g_reg_ind).total_result_count;
    if end_row > total_rows then
       end_row := total_rows;
    end if;

   if ak_query_pkg.g_results_table.COUNT = 0 then
      htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.parent.winOpen(''nav'', ''catalog'')"');
         fnd_message.set_name('EC','ICX_NO_RECORDS_FOUND');
         fnd_message.set_token('NAME_OF_REGION_TOKEN',c_title);
         htp.p('<H3>'||fnd_message.get||'</H3>');
      htp.bodyClose;
	return;
   end if;


 --Navigation buttons

 	--print javascript functions
   	htp.htmlOpen;
     	htp.headOpen;
      icx_util.copyright;
      js.scriptOpen;

      htp.p('function submit() {
             document.catalog_items.cartId.value = parent.parent.parent.cartId;
             document.catalog_items.p_emergency.value = parent.parent.parent.emergency;
	     document.catalog_items.submit();
      }');

      htp.p ('function get_parent_values(cartId,emergency) {
              cartId.value=parent.parent.parent.cartId;
              emergency.value=parent.parent.parent.emergency;
           }');



	counter := 0;

      js.scriptClose;
      htp.title(c_title);
      htp.headClose;

   htp.bodyOpen('','BGCOLOR="#CCFFCC" onLoad="parent.parent.parent.winOpen(''nav'', ''catalog''); parent.parent.parent.lastCatalog.start_row='|| p_start_row ||
                        ';parent.parent.parent.lastCatalog.end_row='|| end_row ||
			';parent.openButWin('|| p_start_row || ',' ||
                        end_row || ',' || total_rows || ',' || p_where || ');"');
   htp.br;

     htp.p('<FORM ACTION="' || v_dcdName || '/ICX_REQ_CATEGORIES.submit_items" METHOD="POST" NAME="catalog_items" TARGET="_parent" onSubmit="return(false)">');

     htp.formHidden('cartId','');
     htp.formHidden('p_emergency','');
     js.scriptOpen;
      htp.p('get_parent_values(document.catalog_items.cartId,document.catalog_items.p_emergency)');
     js.scriptClose;

     htp.formHidden('p_start_row',p_start_row,'cols="60" rows = "10"');
     htp.formHidden('p_end_row',p_end_row,'cols="60" rows ="10"');
     htp.formHidden('p_where',p_where,'cols="60" rows = "10"');
     htp.formHidden('p_cat_name',v_cat_name,'cols="60" rows = "10"');
     htp.formHidden('end_row',end_row,'cols="60" rows ="10"');
     htp.formHidden('p_query_set',c_query_size,'cols="60" rows = "10"');
     htp.formHidden('p_row_count',total_rows,'cols="60" rows="10"');

     l_pos := l_pos + 9;

     htp.tableOpen('border=5','','','','bgcolor=#' || icx_util.get_color('TABLE_DATA_MULTIROW') );
     htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER_TABS')||'">');
     --print the table column headings
     for i in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop

         if (ak_query_pkg.g_items_table(i).value_id is not null
		and ak_query_pkg.g_items_table(i).item_style <> 'hidden'
		and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                and ak_query_pkg.g_items_table(i).secured_column <> 'T') or
             ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then

            if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then
	   	   --print quantity heading WITH COLSPAN=2
               htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'CENTER','','','','2');
            elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' then
               htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long || ' (' || c_currency || ')', 'CENTER','','','','width=80');
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
     htp.tableRowClose;

    --get one row of the result and find the catalog name
--   	icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(ak_query_pkg.g_results_table.first), y_table) ;

     v_qty_flag := true;

     htp.br; htp.br;

     counter := 0;
--     for j in p_start_row-1 .. end_row-1 loop
       for j in ak_query_pkg.g_results_table.FIRST .. ak_query_pkg.g_results_table.LAST loop
         temp_table(0) := '<TR BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW') || '">';

	   icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(j), y_table) ;

         for i in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop

 		 --print quantity input text box and up button if v_qty_flag is set
             if v_qty_flag and ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' then
                v_line_id := y_table(v_line_id_ind);

       	    display_text := '<TD ROWSPAN=2><CENTER> <INPUT TYPE=''text'' NAME=''Quantity'' '
--dchu                 			onFocus="top.update_quantity(document.forms[' || counter || '].Quantity, ''' || v_line_id || ''')"
--dchu                 			onChange="item' || counter || '(this,''' || v_line_id || ''')" '
	      || ' SIZE='
	      || to_char(V_QUANTITY_LENGTH)
	      || ' onChange=''if(!parent.parent.parent.checkNumber(this)){this.focus();this.value="";}''></CENTER></TD>';

                --show the quantity in the box filled in in the previous record set
                    l_spin_pos := l_pos;
     		    display_text := display_text
		      || '<TD width=18 valign=bottom> <a href="javascript:parent.parent.parent.up(document.catalog_items.elements['
		      || l_spin_pos
		      || '])" onMouseOver="window.status=''Add Quantity'';return true"><IMG SRC=/OA_MEDIA/'
		      || v_lang
		      || '/FNDISPNU.gif border=0></a></TD>';
                    l_pos := l_pos + 1;

		    --add the tabledata in temp_table() WITH ROWSPAN=2
	          temp_table(0) := temp_table(0) ||  display_text;
             end if;

             if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_LINE_ID' then
                   display_text := '<INPUT TYPE="HIDDEN" NAME="Line_Id" VALUE =' || y_table(ak_query_pkg.g_items_table(i).value_id) || '>';

                   l_pos := l_pos + 1;
                   temp_table(0) := temp_table(0) || display_text;
             end if;

		-- special treatment for certain columns
             if ak_query_pkg.g_items_table(i).value_id is not null --not including ICX_QTY
		    and ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                    and ak_query_pkg.g_items_table(i).secured_column <> 'T'
		    and ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' then --only for display of item tabledata

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
                if display_text = 'null' then
                   display_text := htf.br;
                end if;
                if display_text = '-1' then
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
         end loop;  -- for i in 1 .. ak_query_pkg.g_items_table.first loop

	   --close the table row
         temp_table(0) := temp_table(0) || htf.tableRowClose;
	   if v_qty_flag then
	      --print the down button
            display_text := htf.tableRowOpen( cattributes => 'BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'"');
		display_text := display_text || '<TD WIDTH=18 valign=top><a href="javascript:parent.parent.parent.down(document.catalog_items.elements[' || l_spin_pos ||
   		                '])" onMouseOver="window.status=''Reduce Quantity'';return true"><IMG SRC=/OA_MEDIA/' || v_lang
                            || '/FNDISPND.gif  BORDER=0></a>';
		display_text := display_text || '</TD>';
		display_text := display_text || htf.tableRowClose;
            temp_table(0) := temp_table(0) ||  display_text;
  	   end if;
           htp.p(temp_table(0));
	   counter := counter + 1;
     end loop;      -- for j in 1 .. ak_query_pkg.g_results_table.COUNT loop
     htp.tableClose;

     htp.p('</FORM>');

      htp.bodyClose;
      htp.htmlClose;

end if;
-- dbms_session.set_sql_trace(FALSE);

end catalog_items_display;

--**********************************************************
-- END PROCEDURES RELATED TO CATEGORIES
--**********************************************************



end ICX_REQ_CATEGORIES;

/
