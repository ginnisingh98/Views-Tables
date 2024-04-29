--------------------------------------------------------
--  DDL for Package Body ICX_REQ_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_ORDER" as
/* $Header: ICXREQMB.pls 115.6 99/07/17 03:22:01 porting ship $ */



--**********************************************************
-- LOCAL PROCEDURES NOT DECLARED IN SPEC
--**********************************************************


------------------------------------------------------------
procedure popWindow is
------------------------------------------------------------
begin
    htp.p('function popWindow(sourceURL) {
        win = window.open(sourceURL, "drillDown", "resizable=yes,scrollbars=yes,width=750,height=300");
        win = window.open(sourceURL, "drillDown", "resizable=yes,scrollbars=yes,width=750,height=300");
}
');

end popWindow;

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
--   return 'N';
end;



------------------------------------------------------------
procedure giveWarning is
------------------------------------------------------------
begin

 	FND_MESSAGE.SET_NAME('ICX', 'ICX_CART_RMV_ALL');
        htp.p('function giveWarning() {
        if (confirm(''' || icx_util.replace_quotes(FND_MESSAGE.GET) || ''')) {
           return true;
        } else {
           return false;
        }
}
');

end giveWarning;


------------------------------------------------------------
procedure sysadmin_error is
------------------------------------------------------------
    v_lang varchar2(5);

begin
    -- set lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

--    icx_admin_sig.openHeader;
--    icx_admin_sig.closeHeader;

   htp.htmlOpen;
   htp.headOpen;
   icx_admin_sig.toolbar(language_code => v_lang);
   icx_util.copyright;
   js.scriptOpen;

      htp.p('function help_window() {
           help_win = window.open(''/OA_DOC/' || v_lang  || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250");
            help_win = window.open(''/OA_DOC/' || v_lang || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250")}
');
   js.scriptClose;


    htp.headClose;
    htp.bodyOpen('/OA_MEDIA/' || v_lang || '/ICXBCKGR.jpg');

    FND_MESSAGE.SET_NAME('ICX', 'ICX_DATA_INCORRECT');
    icx_util.add_error(FND_MESSAGE.GET);
    icx_util.error_page_print;
    -- htp.p(FND_MESSAGE.GET);


    htp.bodyClose;

end sysadmin_error ;




------------------------------------------------
procedure drawCartErrors(l_cart_id number)  is
------------------------------------------------
  cursor get_errors(v_cart_id number) is
  select error_text
  from icx_req_cart_errors
  where cart_id = v_cart_id;

  l_message varchar2(1000);
  l_first_time varchar2(1);

begin
--dc	htp.p('//Draw errors at top of the cart.
--dc function drawCartErrors() {
--dc  if (top.cartErrors.length > 0 ) {
--dc      var result = "";
--dc     result += "<TABLE Border=5>";
--dc for(var i=1; i<= top.cartErrors.length; i++){
--dc          result += "<TR><TD>" + replaceQuotes(top.cartErrors[i]) + "</TD></TR>";
--dc      }
--dc      result += "</TABLE>";
--dc      document.write(result);
--dc  }
--dc }
--dc ');

    l_first_time := 'Y';
    for prec in get_errors(l_cart_id) loop
       if l_first_time = 'Y' then
          htp.p('<TABLE BORDER=5>');
          l_first_time := 'N';
       end if;

       htp.p('<TR><TD>' || prec.error_text || '</TD></TR>');
    end loop;
    if l_first_time = 'N' then
       htp.p('</TABLE>');
    end if;

end drawCartErrors;



------------------------------------------------
procedure updateCartHeaderObject is
------------------------------------------------
begin
	htp.p('//Update the requestor.
function Update_requestor(id, name,org_id,loc_id,loc_cd) {
     document.KEVIN.ICX_DEST_ORG_ID.value = document.KEVIN.ICX_REQ_ORG_ID.value;
     document.KEVIN.ICX_DELIVER_TO_LOCATION_ID.value = document.KEVIN.ICX_REQ_LOC_ID.value;
     document.KEVIN.ICX_DELIVER_TO_LOCATION.value = document.KEVIN.ICX_REQ_LOC_CD.value;

}');

end updateCartHeaderObject;


------------------------------------------------
procedure get_po(n_org varchar2,n_cart_id number) is
------------------------------------------------
   v_dcdName varchar2(2000);
begin

--      FND_MESSAGE.SET_NAME('ICX', 'ICX_ONE_PO_PER_REQUISITION');
/*
   var po_num = "" + parent.my_cart_header.ICX_RESERVED_PO_NUM;
   alert(po_num);
   if (po_num <> "") {
        alert("' || icx_util.replace_quotes(FND_MESSAGE.GET) || '");
        //alert("Can not reserve more than one PO # for a single requisition.");
        return;
   }

*/


    --get dcd name
      v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

	htp.p('//Reserve a po number.
function get_po(){
   open("' || v_dcdName || '/ICX_REQ_ORDER.get_emergency_po_num?n_org=' || n_org || '&n_cart_id= ' || n_cart_id || '", "navigation");

}

');
end get_po;



------------------------------------------------------------
procedure cart_line_actions(n_org varchar2) is
--
-- This procedure prints javascript functions
-- required for various actions on cart lines.
--
--   Actions                 JavaScript Function
--   -------                 -------------------
--
--   Change Quantity         quantity_changed
--
--   Change Price            price_changed
--
--   Remove a line           remove
--
--   Split a line into 2     splitLine
--
------------------------------------------------------------
   v_dcdName varchar2(1000);
   v_message varchar2(240);

begin

      --get dcd name
      v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');


      FND_MESSAGE.SET_NAME('RG', 'RG_DELETE_ROW');
      v_message := FND_MESSAGE.GET;

	htp.p('function remove(number) {
   if (confirm("' || icx_util.replace_quotes(v_message) || '") ) {
//dc      parent.removeItem(number);
      document.LINE.cartLineId.value = number;
      document.LINE.cartLineAction.value = "DELETE";
      document.LINE.submit();

//dc      top.switchFrames("my_order");
   }
}
');


	htp.p('function splitLine(number) {
//dc   parent.splitLine(number);
   document.LINE.cartLineId.value = number;
   document.LINE.cartLineAction.value = "COPY";
   document.LINE.submit();
//dc   top.switchFrames("my_order");
   }');

   -- Added for account distributions
	htp.p('function accountDist(number) {
   document.LINE.cartLineId.value = number;
   document.LINE.cartLineAction.value = "ACCOUNT";
   parent.parent.account_dist="Y";
   parent.parent.cartLineId=number;
   top.switchFrames("my_order");

    // document.LINE.submit();
   }');

end cart_line_actions;

procedure submit_line_actions is
  v_confirm_text varchar2(240);
  v_empty_cart_msg varchar2(1000);
begin

   FND_MESSAGE.SET_NAME('ICX','ICX_CONFIRM_COMPLETE');
   v_confirm_text := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('ICX','ICX_CART_EMPTY');
   v_empty_cart_msg := FND_MESSAGE.GET;

   htp.p('function save_order() {

//         if (parent.frames[0].document.LINE.itemCount.value == 0) {
//             alert("' || icx_util.replace_quotes(v_empty_cart_msg) || '");
//         } else {

//         if (confirm("' || icx_util.replace_quotes(v_confirm_text) || '")) {
            parent.frames[0].document.KEVIN.user_action.value = "SAVE";
            parent.frames[0].document.KEVIN.submit();
//          }
//         }
       }');


   FND_MESSAGE.SET_NAME('ICX','ICX_APPLY_CHANGES_CONFIRM');
   v_confirm_text := FND_MESSAGE.GET;

    htp.p('function modify_order() {

//         if (parent.frames[0].document.LINE.itemCount.value == 0) {
//             alert("' || icx_util.replace_quotes(v_empty_cart_msg) || '");
//         } else {

            parent.frames[0].document.KEVIN.user_action.value = "MODIFY";
            parent.frames[0].document.KEVIN.submit();
//         }
       }');

    htp.p('function get_po_modify_order() {
//         if (parent.frames[0].document.LINE.itemCount.value == 0) {
//	    alert ("' || icx_util.replace_quotes(v_empty_cart_msg) || '");
//         } else {
            parent.frames[0].document.KEVIN.user_action.value = "GET_PO_MODIFY";
            parent.frames[0].document.KEVIN.submit();
//         }
        }');


    FND_MESSAGE.SET_NAME('ICX','ICX_CONFIRM_ORDER');
    v_confirm_text := FND_MESSAGE.GET;
    htp.p('function submit_order() {

         if (parent.frames[0].document.LINE.itemCount.value == 0) {
             alert("' || icx_util.replace_quotes(v_empty_cart_msg) || '");
         } else {

         if (confirm("' || icx_util.replace_quotes(v_confirm_text) || '")) {
            parent.frames[0].document.KEVIN.user_action.value = "PLACE ORDER";
            parent.frames[0].document.KEVIN.submit();
          }
         }
       }');

    FND_MESSAGE.SET_NAME('ICX','ICX_CANCEL_CONFIRM');
    v_confirm_text := FND_MESSAGE.GET;
    htp.p('function delete_saved_cart() {

//         if (parent.frames[0].document.LINE.itemCount.value == 0) {
//             alert("' || icx_util.replace_quotes(v_empty_cart_msg) || '");
//         } else {

         if (confirm("' || icx_util.replace_quotes(v_confirm_text) || '")) {
            parent.frames[0].document.KEVIN.user_action.value = "CANCEL";
            parent.frames[0].document.KEVIN.submit();
         }
//        }
       }
');
end submit_line_actions;

------------------------------------------------------------
procedure PrintHead(l_total_price_column IN OUT number,l_pos IN OUT number,v_currency in varchar2) is
------------------------------------------------------------
i                   number := 0;
v_table_attribute   varchar2(32);
v_vendor_on_flag    varchar2(1);
v_req_overwrite_flag   varchar2(1);
l_col number;

begin

   l_col := 0;
   v_req_overwrite_flag := icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_LOC_FLAG);

   ICX_REQ_NAVIGATION.chk_vendor_on(v_vendor_on_flag);

-- old background
   htp.p('<TABLE BORDER=5 bgcolor=''#F8F8F8''>');
   htp.p('<TR bgcolor=''#D8D8D8''>');

  for i in ak_query_pkg.g_items_table.first  ..  ak_query_pkg.g_items_table.last loop

       if ( ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' and
            ((ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
	      ak_query_pkg.g_items_table(i).secured_column <> 'T') or
             ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY_V' or
             ((ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE'
		or ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT'
		or ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE') and
             v_vendor_on_flag = 'Y' and ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' and ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
             ak_query_pkg.g_items_table(i).secured_column <> 'T' ))) or
             (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' and
              v_vendor_on_flag = 'Y') then

                    v_table_attribute := '';
                    if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY_V' then
                           v_table_attribute := ' COLSPAN=2 ';
  			   l_col := l_col + 1;
                    elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME'  and v_vendor_on_flag = 'Y' then

                           v_table_attribute := ' COLSPAN=2 ';
			   l_col := l_col + 1;

                    elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION' and ak_query_pkg.g_items_table(i).update_flag = 'Y' and v_req_overwrite_flag = 'Y' then
                           v_table_attribute := ' COLSPAN=2 ';
			   l_col := l_col + 1;

                    elsif ak_query_pkg.g_items_table(i).lov_attribute_code is not NULL and
                          ak_query_pkg.g_items_table(i).lov_region_code is not NULL and
                          ak_query_pkg.g_items_table(i).update_flag = 'Y' then

                           if ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_PHONE' and
			      ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_SITE' and
 	  		      ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_CONTACT'  and
 			      ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION' then

                             v_table_attribute := ' COLSPAN=2 ';
			     l_col := l_col + 1;

                            end if;
                    end if;

                    if (ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DEST_ORG_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_REQUESTOR_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SHOPPER_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_CART_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_APPROVER_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_REQ_ORG_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_REQ_LOC_ID' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_REQ_LOC_CD') then

                       if ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_UNIT_PRICE' and ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_EXT_PRICE' then

                         htp.p( '<TD' || v_table_attribute || ' ALIGN="CENTER" >' || ak_query_pkg.g_items_table(i).attribute_label_long  || '</TD>' );

                       else

                         htp.p( '<TD' || v_table_attribute || ' ALIGN="CENTER" >' || ak_query_pkg.g_items_table(i).attribute_label_long || ' (' || v_currency || ') </TD>' );


                       end if;

                       l_col := l_col + 1;

                       if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
			   l_total_price_column := l_col;
                       end if;
                    end if;

       end if;


  end loop;

  htp.p('</TR><TR></TR><TR></TR><TR></TR>');
end PrintHead;


/* new PrintItem server side XXXXXXXXXXXXXXXXXXX*/
------------------------------------------------------------
procedure PrintItems(p_cart_line_id_value number,
                     v_money_fmt_mask varchar2,
		     l_pos in out number,
		     v_vendor_LOV_flag in out varchar2,
		     v_location_LOV_flag in out varchar2,
		     p_ext_price_total out number) is
------------------------------------------------------------
l_values        icx_util.char240_table;
l_value		varchar2(240);
l_language_code	varchar2(30);
l_multirow_color varchar2(30);
l_colspan      number;
c_prompts      ICX_UTIL.g_prompts_table;
c_title        varchar2(45);
l_org_id_pos   number;
l_loc_id_pos   number;
l_spin_pos     number;
l_ext_price_total number := 0;

--add by alex
pk		varchar2(240);
url		varchar2(500);
attachment_status varchar2(10);
v_dcdname varchar2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');
--

begin

l_language_code := icx_sec.getID(icx_sec.pv_language_code);
l_multirow_color := icx_util.get_color('TABLE_DATA_MULTIROW');
-- icx_util.getprompts(601, 'ICX_SHOPPING_CART_LINES_R', c_title, c_prompts);
icx_util.getprompts(601, 'ICX_LOV', c_title, c_prompts);

for r in 0..ak_query_pkg.g_results_table.LAST loop

    icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values);

    for i in 0..ak_query_pkg.g_items_table.LAST loop

        if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        and ak_query_pkg.g_items_table(i).secured_column = 'F'
	and ak_query_pkg.g_items_table(i).item_style = 'HIDDEN'
        then

            htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code || 'A', cvalue => replace(l_values(ak_query_pkg.g_items_table(i).value_id),'"','&quot;'));

            -- remember org id and loc id positions for LOV use
            if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DEST_ORG_ID_L' then
               l_org_id_pos := l_pos;
            end if;
            if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID_L' then
               l_loc_id_pos := l_pos;
            end if;

            l_pos := l_pos + 1;
        end if;

    end loop;

    htp.p('<TR BGColor="#'||l_multirow_color||'">');

    for i in 0..ak_query_pkg.g_items_table.LAST loop

	--add by alex
	pk := l_values(p_cart_line_id_value);
	--
	if ak_query_pkg.g_items_table(i).value_id is null
	  then
	   l_value := '';
	 else
	   l_value := l_values(ak_query_pkg.g_items_table(i).value_id);

	   /* compute price total */
	   if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
	      l_ext_price_total := l_ext_price_total + to_number(nvl(l_value,0));
	   end if;

	end if;

	IF (NOT (ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
	    and ak_query_pkg.g_items_table(i).secured_column = 'F'))
	  THEN
	   /*  if item is on of suggested_vendor_phone/contact/name and
	   it's not displayed, we still need to save a space for it to
	     store its value in case if user changes the suggested_vendor */
	   if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
	       ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
	       ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE') and
	     v_vendor_LOV_flag = 'Y' then
	      htp.p('<INPUT TYPE="HIDDEN" NAME="'
		    || ak_query_pkg.g_items_table(i).attribute_code
		    || 'A'
		    || '" VALUE= "'
		    || replace(l_value,'"','&quot;')
		    || '">');

	      l_pos := l_pos + 1;

	   end if;

	 ELSE /* if node_display_flag='Y' and secured_column = 'F' */
	    if ak_query_pkg.g_items_table(i).item_style = 'HIDDEN'
	    then
		null;
	    elsif ak_query_pkg.g_items_table(i).item_style = 'IMAGE'
	    then
		if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELETE'
		then
		   htp.tableData(cvalue => '<a href="javascript:remove('
				 || l_values(p_cart_line_id_value)
				    -- || ')"><IMG SRC=/OA_MEDIA/'
				 || ')" onMouseOver="window.status='''
				 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '''; return true"><IMG SRC=/OA_MEDIA/'
				 || l_language_code
				    -- || '/FNDIDELR.gif HEIGHT=18 WIDTH=18 BORDER=no></TD>',
				 || '/FNDIDELR.gif HEIGHT=18 WIDTH=18 BORDER=no ALT="'
				 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '"></TD>',
				 crowspan => 2,
				    -- add by Mary
				 calign => ak_query_pkg.g_items_table(i).horizontal_alignment);

		elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SPLIT'
		then
		   htp.tableData(cvalue => '<a href="javascript:splitLine('
				 || l_values(p_cart_line_id_value)
				    --     || ')"><IMG SRC=/OA_MEDIA/'
				 || ')" onMouseOver="window.status='''
				 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '''; return true"><IMG SRC=/OA_MEDIA/'
				 || l_language_code
				    --     || '/FNDISPLT.gif HEIGHT=18 WIDTH=18 BORDER=no></TD>',
				 || '/FNDISPLT.gif HEIGHT=18 WIDTH=18 BORDER=no ALT="'
				 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '"></TD>',
				 crowspan => 2,
				    -- add by Mary
				 calign => ak_query_pkg.g_items_table(i).horizontal_alignment);

		elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_ACCT_DIST'
		then
		   htp.tableData(cvalue => '<a
				 href="javascript:accountDist('
				 || l_values(p_cart_line_id_value)
				    -- || ')"><IMG SRC=/OA_MEDIA/'
				 || ')" onMouseOver="window.status='''
				 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '''; return true"><IMG SRC=/OA_MEDIA/'
				 || l_language_code
				    -- || '/FNDIMADS.gif HEIGHT=16 WIDTH=16 BORDER=no></TD>',
				 || '/FNDISPLT.gif HEIGHT=16 WIDTH=16 BORDER=no ALT="'
				 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
				 || '"></TD>',
				 crowspan => 2,
				    -- add by Mary
				 calign => ak_query_pkg.g_items_table(i).horizontal_alignment);--

		--add by alex
		elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PAPER_CLIP' then
			fnd_webattch.GetSummaryStatus('ICX_REQS', 'REQ_LINES',
						pk, NULL, NULL, NULL, NULL, attachment_status);
			if (attachment_status <> 'DISABLE' AND attachment_status = 'FULL') then
			   htp.tableData(cvalue => '<a
					 href="javascript:attachment(2, '''
					 || pk
					 || ''' ,'''' , '''
					 || v_dcdname
					 ||''')" onMouseOver="window.status='''
					 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 || '''; return true"><IMG SRC=/OA_MEDIA/'
					 || l_language_code
					 || '/FNDIATTE.gif HEIGHT=16 WIDTH=16 BORDER=no ALT="'
					 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 || '"></TD>',
					 crowspan => 2,
					   -- add by Mary
					 calign => ak_query_pkg.g_items_table(i).horizontal_alignment);
			elsif (attachment_status <> 'DISABLE') then
			   htp.tableData(cvalue => '<a
					 href="javascript:attachment(2, '''
					 || pk
					 || ''' ,'''' , '''
					 ||v_dcdname
					    -- ||''')"><IMG SRC=/OA_MEDIA/'
					 ||''')" onMouseOver="window.status='''
					 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 || '''; return true"><IMG SRC=/OA_MEDIA/'
					 || l_language_code
					 || '/FNDIATT.gif HEIGHT=16 WIDTH=16 BORDER=no ALT="'
					 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 || '"></TD>',
					 crowspan => 2,
					    -- add by Mary
					 calign => ak_query_pkg.g_items_table(i).horizontal_alignment);
			end if;
		--

		end if; -- attribute_code
	     else
		if ak_query_pkg.g_items_table(i).update_flag = 'Y'
		then

		    l_colspan := 1;

                   -- if location code, null out locaiton id and org id if user
                   -- type in code manually, so that submit will validate the
		   -- code and fill in the ids
                   if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_L' then

                   htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || 'A' || ' size=' || ak_query_pkg.g_items_table(i).display_value_length
		|| ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE = "'|| replace(l_value,'"','&quot;') ||'" onBlur='' document.KEVIN.elements['
		|| to_char(l_org_id_pos) || '].value ="";document.KEVIN.elements[' || to_char(l_loc_id_pos) || '].value="";''>', crowspan => 2);
                   else

                      if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
                         l_value := to_char(to_number(l_value),v_money_fmt_mask);
			 l_value := replace(l_value,',','');
		      end if;

                      if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY_V' or
                         ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' then
                          l_value := replace(l_value,',','');

                          htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || 'A' || ' size=' ||
			ak_query_pkg.g_items_table(i).display_value_length || ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE = "'
			|| replace(l_value,'"','&quot;') ||'" onChange=''if(!parent.parent.checkNumber(this)){this.focus();this.value="";}''>', crowspan => 2);

                      else

                          htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code
			|| 'A' || ' size=' || ak_query_pkg.g_items_table(i).display_value_length || ' maxlength='
			|| ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE = "'|| replace(l_value,'"','&quot;') ||'">', crowspan => 2);

                      end if;

                   end if;

                   if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY_V'
                   then
			l_spin_pos := l_pos;
                        htp.tableData(cvalue => '<A HREF="javascript:parent.parent.up(document.KEVIN.elements['
				      ||l_spin_pos
				      ||'])" onMouseOver="window.status=''Add Quantity'';return true"><IMG SRC="/OA_MEDIA/'
				      ||l_language_code
				      ||'/FNDISPNU.gif" BORDER=NO>',cattributes => 'width=18 valign=bottom');
                   end if;

                    if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' then

                      htp.tableData(cvalue => htf.anchor('javascript:PRE_LOV1(''178'',''ICX_SUGGESTED_VENDOR_NAME'',''601'',''ICX_SHOPPING_CART_LINES_R'',''LOVFIELDS'',''my_order1'','''','''','''
			||  to_char(l_pos) ||  ''',''' || to_char(l_pos + 1) || ''',''' || to_char(l_pos + 2) || ''',''' || to_char(l_pos + 3) || ''')',htf.img('/OA_MEDIA/'
			||l_language_code||'/FNDILOV.gif','LEFT',c_title,'','BORDER=0 WIDTH=22 HEIGHT=22'),'','onMouseOver="window.status='''
			|| icx_util.replace_onMouseOver_quotes(c_title) ||''';return true"'), crowspan => 2);

                    elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_L' then  -- must be location LOV

                      htp.tableData(cvalue => htf.anchor('javascript:PRE_LOV2(''178'',''ICX_DELIVER_TO_LOCATION_L'',''601'',''ICX_SHOPPING_CART_LINES_R'',''LOVFIELDS'',''my_order1'','''','''',''' ||
			to_char(l_org_id_pos) ||  ''',''' || to_char(l_loc_id_pos) || ''',''' || to_char(l_pos) || ''')',htf.img('/OA_MEDIA/'||l_language_code||
			'/FNDILOV.gif','LEFT',c_title,'','BORDER=0 WIDTH=22 HEIGHT=22'),'','onMouseOver="window.status='''|| icx_util.replace_onMouseOver_quotes(c_title) ||''';return true"'), crowspan => 2);

                    -- user has LOV
                    elsif ak_query_pkg.g_items_table(i).lov_attribute_code is not NULL and
			  ak_query_pkg.g_items_table(i).lov_region_code is not NULL and
                          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_CONTACT' and
                          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_SITE' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_PHONE' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION_ID_L' and
                        ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DEST_ORG_ID_L' then


                       htp.tableData(cvalue => htf.anchor('javascript:PRE_LOV0(''178'',''' || ak_query_pkg.g_items_table(i).attribute_code ||
			''',''601'',''ICX_SHOPPING_CART_LINES_R'',''LOVFIELDS'',''my_order1'','''','''',''' || to_char(l_pos) || ''')',htf.img('/OA_MEDIA/'||
			l_language_code||'/FNDILOV.gif','LEFT',c_title,'','BORDER=0 WIDTH=22 HEIGHT=22'),'','onMouseOver="window.status='''||
			 icx_util.replace_onMouseOver_quotes(c_title) || ''';return true"'), crowspan => 2);

                    end if;

                   l_pos := l_pos + 1;

		ELSE /* if update_flag <> 'Y' */
		   if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
		      l_value := to_char(to_number(l_value),v_money_fmt_mask);
		   end if;

		   if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
		       ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
		       ak_query_pkg.g_items_table(i).attribute_code =
		       'ICX_SUGGESTED_VENDOR_SITE')
		       AND v_vendor_LOV_flag = 'Y'
		      THEN
		        /* Even if update_flag <> 'Y', we still want it to be an
		        input text field so that it can be dynamically changed
		        when ICX_SUGGESTED_VENDOR_NAME is changed */
			 htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = '
			   || ak_query_pkg.g_items_table(i).attribute_code|| 'A'
		           || ' size='|| ak_query_pkg.g_items_table(i).display_value_length
			   || ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length
		           || ' VALUE = "'|| replace(l_value,'"','&quot;')
			   ||'" onFocus=''document.KEVIN.elements['
			   || to_char(l_pos-1) || '].focus(); ''>',
				       crowspan => 2);
			 l_pos := l_pos + 1;
		    ELSE /* if attribute_code <> 'ICX_SUGGESTED_VENDOR_*' */
		      htp.tableData(cvalue =>
				    icx_on_utilities.formatText(replace(l_value,'"','&quot;'),
								ak_query_pkg.g_items_table(i).bold,
								ak_query_pkg.g_items_table(i).italic),
				    calign => ak_query_pkg.g_items_table(i).horizontal_alignment,
				    cattributes =>'VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'"', crowspan => 2);
		   END IF; /* attribute_code */
                --    end if;
		end if; -- update_flag

	    end if; -- item_style

	end if; -- display

    end loop; -- g_items_table

    htp.p('</TR>');

    htp.p('<TR>');
        htp.tableData(cvalue => '<A HREF="javascript:parent.parent.down(document.KEVIN.elements['
		      ||l_spin_pos
		      ||'])" onMouseOver="window.status=''Reduce Quantity'';return true"><IMG SRC="/OA_MEDIA/'
		      ||l_language_code
		      ||'/FNDISPND.gif" BORDER=NO>',cattributes => 'width=18 valign=top');

    htp.p('</TR>');

end loop; -- g_results_table

    p_ext_price_total := l_ext_price_total;

end PrintItems;


------------------------------------------------------------
procedure PrintTotal(v_items_table ak_query_pkg.items_table_type) is
------------------------------------------------------------

i              number := 0;
column_number  number := 0;
v_table_valign varchar2(32);
v_table_halign varchar2(32);
v_ext_price_is_on  boolean := FALSE;


begin

  --
  -- Try to place total under extended price
  --
  for i in v_items_table.first  ..  v_items_table.last loop
       if ( v_items_table(i).item_style <> 'HIDDEN' and
            v_items_table(i).node_display_flag = 'Y' ) then

                 column_number := column_number + 1;

                 -- Add extra column for quantity because, quantity is colspan 2
                 -- Extra column is used by the spin boxes.
                 if v_items_table(i).attribute_code = 'ICX_QTY_V' then
                      column_number := column_number + 1;
                 end if;

                 if v_items_table(i).attribute_code = 'ICX_EXT_PRICE' then
                         if (v_items_table(i).node_display_flag = 'Y') then
                           v_ext_price_is_on := TRUE;
                         end if;
                         v_table_valign :=  ' VALIGN=' || v_items_table(i).vertical_alignment;
                         v_table_halign :=  ' ALIGN='  || v_items_table(i).horizontal_alignment;
                         exit;
                 end if;
       end if;
  end loop;

  -- Print total only if the EXT_PRICE is turned on
  if ( v_ext_price_is_on ) then
	htp.p('function PrintTotal() {
   var result = "<TR></TR><TR></TR><TR></TR><TR>";');

   for i in 1 .. (column_number - 2) loop
       htp.p('result += "<TD></TD>";');
   end loop;

   FND_MESSAGE.SET_NAME('MRP','EC_TOTAL');
   htp.p('
   result += "<FORM  ACTION='''' onSubmit=''return(false)''  METHOD=''POST''><TD bgcolor=''#D8D8D8''><DIV ALIGN=RIGHT> ' || icx_util.replace_quotes(FND_MESSAGE.GET) || ' (";
   result += parent.currencyCode + ")</DIV></TD>";
   result += "<TD' || v_table_valign || v_table_halign || '><INPUT TYPE=''text'' NAME=''total'' SIZE=8 VALUE=" +
	     parent.AddDecimal(parent.largeComputeLoop()) +
	     " onBlur=large_compute()></TD>";
   result += "</TR>";
   //parent.frames[1].document.write(result);
   document.write(result);
}
');
  else
    -- print a dummy total to get around the fucntion reference
    htp.p('function PrintTotal() {
           }');
  end if;

end PrintTotal;

procedure ak_mandatory_setup(l_cart_line_id_value IN OUT number,v_vendor_LOV_flag in out varchar2,v_location_LOV_flag in out varchar2)  is
   v_req_overwrite_flag varchar2(1);
   v_vendor_name_pos number := NULL;
   v_location_pos number := NULL;
begin

   v_vendor_LOV_flag := 'N';
   v_location_LOV_flag := 'N';
   v_req_overwrite_flag := icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_LOC_FLAG);
   if v_req_overwrite_flag = 'Y' then
      v_location_LOV_flag := 'Y';
   end if;

   -- cartline id is always return as the first item
   -- required to pass back for delete and split button
   l_cart_line_id_value := ak_query_pkg.g_items_table(0).value_id;

   for i in 0..ak_query_pkg.g_items_table.last loop

        -- turn all on if one is on for supplier LOV
        if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE') and
         ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
         ak_query_pkg.g_items_table(i).secured_column <> 'T' and
         ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' and
         ak_query_pkg.g_items_table(i).update_flag = 'Y' then

            v_vendor_LOV_flag := 'Y';
            exit;
        end if;
    end loop; -- g_items_table

--dc
--dc    for j in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

--dc       if (ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' or
--dc          ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
--dc          ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
--dc          ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE') and
--dc          v_vendor_LOV_flag = 'Y' then
--dc
--dc          ak_query_pkg.g_items_table(j).node_display_flag := 'Y';
--dc          if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' then
--dc             ak_query_pkg.g_items_table(j).item_style := 'POPLIST';
--dc
--dc          end if;

--dc       end if;


       -- required to pass back for delete and split button
--dc       if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_CART_LINE_ID' then
--dc          l_cart_line_id_value := ak_query_pkg.g_items_table(j).value_id;
--dc       end if; -- attribute_code

       -- required hidden ids fields
--dc       if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_CART_LINE_ID' then
--dc --     	ak_query_pkg.g_items_table(j).attribute_code = 'ICX_LINE_ID' or
--dc --        ak_query_pkg.g_items_table(j).attribute_code = 'ICX_CATEGORY_ID' or
--dc --        ak_query_pkg.g_items_table(j).attribute_code = 'ICX_DEST_ORG_ID' or
--dc --        ak_query_pkg.g_items_table(j).attribute_code = 'ICX_LINE_TYPE_ID' or
--dc --        ak_query_pkg.g_items_table(j).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID' then
--dc   	  ak_query_pkg.g_items_table(j).item_style := 'HIDDEN';
--dc          ak_query_pkg.g_items_table(j).node_display_flag := 'Y';

--dc       end if;

       -- required  and updatable fields
--dc       if ak_query_pkg.g_items_table(j).attribute_code =  'ICX_QTY_V' then
--dc          ak_query_pkg.g_items_table(j).node_display_flag := 'Y';
--dc          ak_query_pkg.g_items_table(j).update_flag := 'Y';
--dc          ak_query_pkg.g_items_table(j).item_style := 'TEXT';
--dc       end if;

       -- location LOV and flag setting
--dc       if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_DELIVER_TO_LOCATION' then
--dc          if v_req_overwrite_flag = 'Y' and ak_query_pkg.g_items_table(j).update_flag = 'Y' then
--dc             ak_query_pkg.g_items_table(j).item_style := 'POPLIST';
--dc             v_location_LOV_flag := 'Y';
--dc          else
--dc             ak_query_pkg.g_items_table(j).update_flag := 'N';
--dc          end if;
--dc       end if;

       -- image fields
--dc       if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_SPLIT' or
--dc	  ak_query_pkg.g_items_table(j).attribute_code = 'ICX_DELETE' then
 --dc         ak_query_pkg.g_items_table(j).item_style := 'IMAGE';
 --dc      end if;

--dc   end loop;


end;

/* new drawCartLines procedure for server side only */
------------------------------------------------------------
procedure drawCartLines( l_pos in out number,v_currency in varchar2,v_lines_region in varchar2,l_total_price_column in out number, v_money_fmt_mask in varchar2) is
------------------------------------------------------------
l_total_price   number := 0;
l_total_h_align varchar2(100);
l_total_v_align varchar2(100);
l_timer number;

l_cart_line_id_value number;
v_vendor_LOV_flag varchar2(1);
v_location_LOV_flag varchar2(1);

begin

-- YYYYYYYYYYY
--select HSECS into l_timer from v$timer;htp.p('BEGIN PreProcess = '||l_timer);htp.nl;
--
    ak_mandatory_setup(l_cart_line_id_value,v_vendor_LOV_flag,v_location_LOV_flag);  -- preprocess and mask the required flags for
                             -- mandatory fields

    PrintHead(l_total_price_column,l_pos,v_currency);


--select HSECS into l_timer from v$timer;htp.p('BEGIN PrintItems = '||l_timer);htp.nl;

    PrintItems(l_cart_line_id_value,v_money_fmt_mask,l_pos,v_vendor_LOV_flag,v_location_LOV_flag,l_total_price);

--select HSECS into l_timer from v$timer;htp.p('END PrintItems = '||l_timer);htp.nl;

      /* when total price colum is > 0 , then exten price is begin printed */
      if l_total_price_column > 2 then
         htp.p('<TR></TR><TR></TR><TR></TR>');
         htp.p('<TR>');
         for i in 1 .. (l_total_price_column - 2) loop
               htp.p('<TD></TD>');
         end loop;
         FND_MESSAGE.SET_NAME('MRP','EC_TOTAL');
         htp.p('<TD ALIGN=CENTER BGCOLOR="#D8D8D8' || icx_util.get_color('TABLE_HEADER') ||'" >' || FND_MESSAGE.GET || ' (' || v_currency || ') </TD>');
         htp.p('<TD ALIGN=RIGHT CALIGN=' || l_total_h_align || ' VALIGN=' || l_total_v_align || '>' ||  to_char(l_total_price,v_money_fmt_mask) || '</TD>' );

         htp.p('</TR>');
     elsif l_total_price_column > 0 then
         htp.p('<TR></TR><TR></TR><TR></TR>');
         htp.p('<TR>');
         FND_MESSAGE.SET_NAME('MRP','EC_TOTAL');
         htp.p('<TD ALIGN=CENTER BGCOLOR="#' || icx_util.get_color('TABLE_HEADER') ||'" >' || FND_MESSAGE.GET || ' (' || v_currency || ') </TD>');
         htp.p('<TD ALIGN=RIGHT CALIGN=' || l_total_h_align || ' VALIGN=' || l_total_v_align || '>' ||  to_char(l_total_price,v_money_fmt_mask) || '</TD>' );

         htp.p('</TR>');

     end if;

      htp.p('</TABLE>');

end drawCartLines;



--add by alex
------------------------------------------------------------
procedure addAttachmentScript is
------------------------------------------------------------

begin
	htp.p('

function attachment(en, pk1, pk2, dcd) {
	var temp = "";
	if (en == 1){
		document.KEVIN.entity_name.value = "REQ_HEADERS";
	} else {
		document.KEVIN.entity_name.value = "REQ_LINES";
	}

	document.KEVIN.pk1.value = pk1;

	temp = dcd + "/ICX_REQ_NAVIGATION.ic_parent?cart_id=" + document.LINE.cartId.value;
	temp = temp + "' || '&' || 'emergency=" + document.LINE.n_emergency.value;

	document.KEVIN.from_url.value = temp;
	document.KEVIN.query_only.value = "N";
        parent.frames[0].document.KEVIN.user_action.value = "ATTACHMENT";
	document.KEVIN.target = "_top";
        parent.frames[0].document.KEVIN.submit();
	}
	');

end;


------------------------------------------------------------
procedure updateCarts is
------------------------------------------------------------
begin
      htp.p('function resetItemCount(fld) {
           fld.value = 0;
      }');

      htp.p('function formSequence(seq) {
           this.sequence = seq }');

      htp.p('LOVSequence1 = new formSequence("0")');
      htp.p('LOVSequence2 = new formSequence("0")');
      htp.p('LOVSequence3 = new formSequence("0")');
      htp.p('LOVSequence4 = new formSequence("0")');
      htp.p('LOVSequence5 = new formSequence("0")');
      htp.p('LOVSequence6 = new formSequence("0")');
      htp.p('LOVSequence7 = new formSequence("0")');
      htp.p('LOVSequence0 = new formSequence("0")');

      htp.p('function PRE_LOV0(attr_id, attr_code, region_id, region_code, form_name, frame_name, where_clause, c_js_where_clause,sequence0) {
           LOVSequence0.sequence = sequence0

         LOV(attr_id, attr_code, region_id, region_code, form_name, frame_name , where_clause,c_js_where_clause)
        }');


      htp.p('function PRE_LOV1(attr_id, attr_code, region_id, region_code, form_name, frame_name, where_clause, c_js_where_clause,sequence1,sequence2,sequence3,sequence4) {
           LOVSequence1.sequence = sequence1
           LOVSequence2.sequence = sequence2
           LOVSequence3.sequence = sequence3
           LOVSequence4.sequence = sequence4

           LOV(attr_id, attr_code, region_id, region_code, form_name, frame_name, where_clause,c_js_where_clause)
        }');


      htp.p('function PRE_LOV2(attr_id, attr_code, region_id, region_code, form_name, frame_name, where_clause, c_js_where_clause,sequence5,sequence6,sequence7){
           LOVSequence5.sequence = sequence5
           LOVSequence6.sequence = sequence6
           LOVSequence7.sequence = sequence7

           LOV(attr_id, attr_code, region_id, region_code, form_name, frame_name, where_clause,c_js_where_clause)
        }');


        htp.p('function postLOV(value0,value01,value02) {
            var seq0 = LOVSequence0.sequence
            document.KEVIN.elements[seq0].value = value0
        }');

	htp.p('function updateCarts(value1,value2,value3,value4) {
	  var seq1 = LOVSequence1.sequence
  	  var seq2 = LOVSequence2.sequence
          var seq3 = LOVSequence3.sequence
 	  var seq4 = LOVSequence4.sequence
          document.KEVIN.elements[seq1].value = value1
          document.KEVIN.elements[seq2].value = value2
          document.KEVIN.elements[seq3].value = value3
          document.KEVIN.elements[seq4].value = value4

}
');


       htp.p('function Updatelineloc(value1,value2,value3) {
          var seq5 = LOVSequence5.sequence
          var seq6 = LOVSequence6.sequence
          var seq7 = LOVSequence7.sequence
          document.KEVIN.elements[seq5].value = value1
          document.KEVIN.elements[seq6].value = value2
          document.KEVIN.elements[seq7].value = value3

}
');

end updateCarts;

/* new way of drawing cart header from server */
------------------------------------------------------------
procedure drawCartHeader(n_org in varchar2,
		         n_cart_id in number,
                         v_org         number,
			 v_emergency   varchar2,
		 	 v_po_number   number,
			 l_pos       in out  number ) is
------------------------------------------------------------
i              number := 0;
where_clause   varchar2(240);
v_language     varchar2(30) := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
dbutton        varchar2(5000);
y_table        icx_util.char240_table;
l_requestor_id  number;
l_requestor_name varchar2(240);
l_location_id   number;
l_location_code varchar2(240);
l_org_id        number;
l_po_number     number;
display_text    varchar2(2000);

--add by alex
url		varchar2(500);
attachment_status varchar2(10);
--

  cursor requestor(requestor_id number) is
      select  hrev.full_name
      from     hr_employees_current_v hrev
      where   hrev.employee_id = requestor_id;

  cursor location(v_location_id number) is
      select  hrl.location_code
      from    hr_locations hrl,
              org_organization_definitions ood,
              financials_system_parameters fsp
      where   hrl.location_id = v_location_id
      and     ood.organization_id = nvl(hrl.inventory_organization_id,
                                     fsp.inventory_organization_id)
      and     sysdate < nvl(hrl.inactive_date, sysdate + 1);

 v_dcdName varchar2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');

begin

  icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(ak_query_pkg.g_results_table.first),y_table);

  for l in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop
      if ak_query_pkg.g_items_table(l).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID' then
           l_location_id := y_table(ak_query_pkg.g_items_table(l).value_id);
      elsif ak_query_pkg.g_items_table(l).attribute_code = 'ICX_DEST_ORG_ID' then
           l_org_id := y_table(ak_query_pkg.g_items_table(l).value_id);
      elsif ak_query_pkg.g_items_table(l).attribute_code = 'ICX_DELIVER_TO_REQUESTOR_ID' then
           l_requestor_id := y_table(ak_query_pkg.g_items_table(l).value_id);
 --          open requestor(l_requestor_id);
 --          fetch requestor into l_requestor_name;
 --          close requestor;
      elsif ak_query_pkg.g_items_table(l).attribute_code = 'ICX_DELIVER_TO_REQUESTOR' then
           l_requestor_name := y_table(ak_query_pkg.g_items_table(l).value_id);
      end if;
  end loop;

  htp.p('<TABLE BORDER=0>');

  htp.p('<INPUT TYPE="HIDDEN" NAME="user_action" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="emergency" VALUE = "' || v_emergency || '">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="entity_name" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="pk1" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="pk2" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="pk3" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="from_url" VALUE = "">');
  htp.p('<INPUT TYPE="HIDDEN" NAME="query_only" VALUE = "">');
  l_pos := l_pos + 8;

  for i in ak_query_pkg.g_items_table.first  ..  ak_query_pkg.g_items_table.last loop

       if   (ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
             ak_query_pkg.g_items_table(i).secured_column <> 'T') or
            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CART_ID' then
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SHOPPER_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DEST_ORG_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR' then
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_APPROVER_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_ORG_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_LOC_ID' or
--            ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_LOC_CD' then


            if (ak_query_pkg.g_items_table(i).value_id is not null and
               ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION' and ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_REQUESTOR') then

                --Special treatment object attributes
                if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CART_ID' or
--                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SHOPPER_ID' or
--                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DEST_ORG_ID' or
                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR' then
--                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION_ID' or
--                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_APPROVER_ID' or
--                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR_ID'  then

                   if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR' then
		      display_text := l_requestor_name;
		   else
                      display_text := y_table(ak_query_pkg.g_items_table(i).value_id);

                      if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CART_ID' then
                         display_text := icx_call.encrypt2(y_table(ak_query_pkg.g_items_table(i).value_id));
                      end if;

                   end if;

                   htp.p('<INPUT TYPE=''' || 'HIDDEN' || ''' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE='
			|| ak_query_pkg.g_items_table(i).display_value_length ||  ' VALUE="' ||  replace(display_text,'"','&quote;') || '">');

		   l_pos := l_pos + 1;
                elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_RESERVED_PO_NUM' then

			     /* if a brand new po number, not yet reserve */
			     /* print the button, if already reserved or a value */
                             /* is already stored in the database, display the  */
			     /* newly reserved po or the value from database */
			     l_po_number := v_po_number;
			     if l_po_number is NULL then
				if y_table(ak_query_pkg.g_items_table(i).value_id) is not NULL then
                                   l_po_number := y_table(ak_query_pkg.g_items_table(i).value_id);
                                end if;
			     end if;

                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');

                             htp.p('<TD WIDTH=10 COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || ' bgcolor=#FFFFFF>');
			     htp.p('<b>');
			     if (l_po_number is not null) then
                                htp.p(l_po_number);

			     else

                                htp.p('<br>');
			     end if;
			     htp.p('</b>');
			     htp.p('</TD>');
			     htp.p('<TD></TD>');


                             --htp.p('result += "<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>";');

                             htp.p('<TD COLSPAN=1 ALIGN=CENTER VALIGN=CENTER>');
                             if (l_po_number is NULL) then

  			     FND_MESSAGE.SET_NAME('ICX','ICX_RESERVE_PO_NUM');

                             icx_util.DynamicButton(P_ButtonText     => FND_MESSAGE.GET,
                                                    P_ImageFileName   => 'FNDBNEW.gif',
					            P_OnMouseOverText => FND_MESSAGE.GET,
--     					            P_HyperTextCall => v_dcdName || '/ICX_REQ_ORDER.get_emergency_po_num?n_org=' || n_org || '&n_cart_id=' || n_cart_id,
 						    P_HyperTextCall => 'javascript:parent.frames[1].get_po_modify_order()',

                                                    P_LanguageCode    => v_language,
                                                    P_JavaScriptFlag  => FALSE);



--dc   		             htp.p('} result = "";');

			     end if;
                             htp.p('</TD></TR>');
/* 837698 increment l_pos if reserve po num is visible in emergency reqs*/
                  l_pos := l_pos + 1;


                elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_APPROVER_NAME' then

                         if ( ak_query_pkg.g_items_table(i).update_flag = 'Y' and
                              ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN') then

                             where_clause :='';--' = ' || icx_sec.getID(icx_sec.PV_WEB_USER_ID);

                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                             htp.p('<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');



                             htp.p('<INPUT TYPE=''text'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length
			|| ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length
	|| ' VALUE="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') ||
                        '" onBlur='' document.KEVIN.ICX_APPROVER_ID.value ="";''>');


 			     l_pos := l_pos + 1;

--                             'parent.my_cart_header.ICX_APPROVER_NAME=this.value''>";');
                             htp.p('</TD>');
                             htp.p('<TD ALIGN="LEFT" width=200>');
                             htp.p(icx_util.LOVButton(c_attribute_app_id => 178,
                                                                     c_attribute_code => 'ICX_APPROVER_NAME',
                                                                     c_region_app_id  => 601,
                                                                     c_region_code    => 'ICX_SHOPPING_CART_HEADER_R',
                                                                     c_form_name      => 'KEVIN',
                                                                     c_frame_name     => 'my_order1',
                                                                     c_where_clause   => where_clause));
                             htp.p('</TD></TR>');
--dc                             htp.p('} else {');
--dc                             htp.p('result += "<TD></TD></TR>"; }');

                         elsif (ak_query_pkg.g_items_table(i).item_style = 'HIDDEN') then

                             htp.p('<INPUT TYPE=''HIDDEN'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length
			|| ' VALUE="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') || '">' );

			     l_pos := l_pos + 1;

                         elsif (ak_query_pkg.g_items_table(i).update_flag = 'N' ) then
                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                             htp.p('<TD COLSPAN=2 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');


--dc                          htp.p('if (parent.my_cart_header.' || ak_query_pkg.g_items_table(i).attribute_code || ' == "")');

                          if y_table(ak_query_pkg.g_items_table(i).value_id) is NULL then

                             htp.p('<TABLE><TR><TD WIDTH=200 border=0 bgcolor=#FFFFFF>');
                          else

                             htp.p('<TABLE><TR><TD border=0 bgcolor=#FFFFFF >');
                          end if;

                          --Bold
                          if ak_query_pkg.g_items_table(i).bold = 'Y' then
                             htp.p('<B>');
                          end if;
                          --Italics
                          if ak_query_pkg.g_items_table(i).italic = 'Y' then
                             htp.p('<I>');
                          end if;
                          htp.p(y_table(ak_query_pkg.g_items_table(i).value_id) || '<br>' );

                          --Bold
                          if ak_query_pkg.g_items_table(i).italic = 'Y' then
                             htp.p('</I>');
                          end if;
                          --Italics
                          if ak_query_pkg.g_items_table(i).bold = 'Y' then
                             htp.p('</B>');
                          end if;
                          htp.p('</TD><TD></TD><TD></TD></TR></TABLE>');
                          htp.p('</TD></TR>');

                         end if;

                else -- Special treatment object attributes

                     if ak_query_pkg.g_items_table(i).update_flag = 'Y' then
                         if ( ak_query_pkg.g_items_table(i).item_style = 'TEXT' ) then

                               htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');

 			       /* dynamic LOV */
                               if ak_query_pkg.g_items_table(i).lov_attribute_code is not NULL and ak_query_pkg.g_items_table(i).lov_region_code is not NULL then
                                  htp.p('<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');
                               else
                                  htp.p('<TD COLSPAN=2 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');
                               end if;

                               display_text := '<INPUT TYPE=''' || ak_query_pkg.g_items_table(i).item_style || ''' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' ||
				ak_query_pkg.g_items_table(i).display_value_length || ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length
				|| ' VALUE="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') || '"';

			       l_pos := l_pos + 1;

			       /* do not allow to change requisition number */
                               if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_NUMBER_SEG1' then
--dc			          htp.p('result += " onBlur=''this.value=parent.my_cart_header.ICX_REQ_NUMBER_SEG1''>";');

			         display_text := display_text || ' onBlur=''this.value= ' || y_table(ak_query_pkg.g_items_table(i).value_id) || '>';
                               else
				 display_text := display_text || '>';

                               end if;

                               htp.p(display_text);
                               htp.p('</TD>');

                               /* dynamic LOV */
                               if ak_query_pkg.g_items_table(i).lov_attribute_code is not NULL and ak_query_pkg.g_items_table(i).lov_region_code is not NULL then

                                  htp.p('<TD ALIGN="LEFT" width=200>');
                                  htp.p(icx_util.LOVButton(c_attribute_app_id => 178,
                                                                     c_attribute_code => ak_query_pkg.g_items_table(i).attribute_code,
                                                                     c_region_app_id  => 601,
                                                                     c_region_code    => 'ICX_SHOPPING_CART_HEADER_R',
                                                                     c_form_name      => 'KEVIN',
                                                                     c_frame_name     => 'my_order1'));
                                   htp.p('</TD>');
                                 end if;

                               htp.p('</TR>');

                         elsif (ak_query_pkg.g_items_table(i).item_style = 'HIDDEN' ) then
                               htp.p('<INPUT TYPE=''' || ak_query_pkg.g_items_table(i).item_style || ''' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE='
				|| ak_query_pkg.g_items_table(i).display_value_length || ' VALUE="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') || '">');

                               l_pos := l_pos + 1;
                         else
                               null;
                         end if;
                     else -- Update falg not set
                       if ( ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' ) then

                          htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                          htp.p('<TD COLSPAN=2 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');
                          --
                          -- Add a table to create a white background
--                          htp.p('if (parent.my_cart_header.' || ak_query_pkg.g_items_table(i).attribute_code || ' == "")');
                       if (y_table(ak_query_pkg.g_items_table(i).value_id) is NULL) then

                          htp.p('<TABLE><TR><TD WIDTH=200 border=0 bgcolor=#FFFFFF>');
                       else
                          htp.p('<TABLE><TR><TD border=0 bgcolor=#FFFFFF  >');
                       end if;
                       --Bold
                       if ak_query_pkg.g_items_table(i).bold = 'Y' then
                          htp.p('<B>');
                       end if;
                       --Italics
                       if ak_query_pkg.g_items_table(i).italic = 'Y' then
                          htp.p('<I>');
                       end if;
                       htp.p(y_table(ak_query_pkg.g_items_table(i).value_id) || '<br>' );

			--add by alex
--			if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CART_ID' then
				pk1 := icx_call.decrypt2(n_cart_id);
--
--			end if;
			--

                       --Bold
                       if ak_query_pkg.g_items_table(i).italic = 'Y' then
                          htp.p('</I>');
                       end if;
                       --Italics
                       if ak_query_pkg.g_items_table(i).bold = 'Y' then
                          htp.p('</B>');
                       end if;
                       htp.p('</TD><TD></TD><TD></TD></TR></TABLE>');
                       htp.p('</TD></TR>');
--changed by alex
                   else --it is a hidden field
			htp.p('<INPUT TYPE="HIDDEN" NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE='
				|| ak_query_pkg.g_items_table(i).display_value_length || ' VALUE="' || '">');
			l_pos := l_pos + 1;
		   end if;
		end if;
--
                end if; -- Special treatment object attributes

            else  -- It is an attribute, treat each of them individually.


                    if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_LOCATION'  then

		       if ak_query_pkg.g_items_table(i).node_display_flag = 'Y'  and
                       ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' then


                         if ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_LOC_FLAG) = 'Y' and
                              ak_query_pkg.g_items_table(i).update_flag = 'Y') or
                            ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ALL'  OR
                              icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ORG'
                            ) then


                              htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                              htp.p('<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');

                              display_text := '<INPUT TYPE=''text'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' maxlength='
				|| ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') || '"';

			      l_pos := l_pos + 1;

                if ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ALL'  OR
                     icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ORG') and
                   ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_LOC_FLAG) = 'N'  or
                     ak_query_pkg.g_items_table(i).update_flag = 'N')  then

                              display_text := display_text ||  ' onBlur=''this.value ="' || replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot') || '"''>';
                              htp.p(display_text || '</TD></TR>');
                     else

--dc                           htp.p('result += " onBlur=''parent.my_cart_header.ICX_DELIVER_TO_LOCATION=this.value;''>";');

                              display_text := display_text || ' onBlur=''document.KEVIN.ICX_DELIVER_TO_LOCATION_ID.value = "";document.KEVIN.ICX_DEST_ORG_ID.value= "";''>';
                              htp.p(display_text || '</TD>');


				htp.p('<TD ALIGN="LEFT" width=200>');
                                htp.p(icx_util.LOVButton(178,'ICX_DELIVER_TO_LOCATION', 601, 'ICX_SHOPPING_CART_HEADER_R', 'KEVIN', 'my_order1'));

                                htp.p('</TD></TR>');

                      end if;

                 else

                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                             htp.p('<TD WIDTH=40 COLSPAN=2 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');

--dc                          htp.p('if (parent.my_cart_header.' || ak_query_pkg.g_items_table(i).attribute_code || ' == "")');

                        if y_table(ak_query_pkg.g_items_table(i).value_id) is NULL then
                          htp.p('<TABLE><TR><TD WIDTH=200 border=0 bgcolor=#FFFFFF>');
--dc                          htp.p('else');
                         else
                             htp.p('<TABLE><TR><TD border=0 bgcolor=#FFFFFF  >');
			 end if;

                         --Bold
                         if ak_query_pkg.g_items_table(i).bold = 'Y' then
                            htp.p('<B>');
                         end if;
                         --Italics
                         if ak_query_pkg.g_items_table(i).italic = 'Y' then
                            htp.p('<I>');
                         end if;
                         htp.p(y_table(ak_query_pkg.g_items_table(i).value_id) || '<br>');

                         --Bold
                         if ak_query_pkg.g_items_table(i).bold = 'Y' then
                            htp.p('</B>');
                         end if;
                         --Italics
                         if ak_query_pkg.g_items_table(i).italic = 'Y' then
                            htp.p('</I>');
                         end if;
                         htp.p('</TD><TD></TD><TD></TD></TR></TABLE>');
                         htp.p('</TD></TR>');

                         end if;

                else

                      htp.p('<INPUT TYPE=''' || 'HIDDEN' || ''' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE='
			|| ak_query_pkg.g_items_table(i).display_value_length || ' VALUE="' ||  replace(y_table(ak_query_pkg.g_items_table(i).value_id),'"','&quot;') || '">');

                       l_pos := l_pos + 1;
                 end if;


                elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DELIVER_TO_REQUESTOR'  then

                         if ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ALL'  OR
                              icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ORG'
                            ) and
                              ak_query_pkg.g_items_table(i).update_flag = 'Y' and
                              ak_query_pkg.g_items_table(i).node_display_flag = 'Y' and
			      ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' then

                             where_clause := 'WEB_USER_ID = ' || icx_sec.getID(icx_sec.PV_WEB_USER_ID);

                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                             htp.p('<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');

                             display_text := '<INPUT TYPE=''text'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length
				|| ' maxlength=' || ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE="' || replace(l_requestor_name,'"','&quot;') || '"';

			     l_pos := l_pos + 1;

                            display_text := display_text || ' onBlur=''document.KEVIN.ICX_DELIVER_TO_REQUESTOR_ID.value="";''>';
                            htp.p(display_text);

                             htp.p('</TD>');
                             htp.p('<TD ALIGN="LEFT" width=200>');
                             htp.p(icx_util.LOVButton(c_attribute_app_id => 178,
                                                                     c_attribute_code => 'ICX_DELIVER_TO_REQUESTOR',
                                                                     c_region_app_id  => 601,
                                                                     c_region_code    => 'ICX_SHOPPING_CART_HEADER_R',
                                                                     c_form_name      => 'KEVIN',
                                                                     c_frame_name     => 'my_order1',
                                                                     c_where_clause   => where_clause));
                             htp.p('</TD></TR>');

                         elsif ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ALL'  OR
                              icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'ORG') and
                              (ak_query_pkg.g_items_table(i).node_display_flag ='Y' and
                              ak_query_pkg.g_items_table(i).item_style = 'HIDDEN') then

                              htp.p('<INPUT TYPE=''HIDDEN'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE='
				|| ak_query_pkg.g_items_table(i).display_value_length || ' VALUE="' || replace(l_requestor_name,'"','&quot') || '">');

                             l_pos := l_pos + 1;



                         elsif (ak_query_pkg.g_items_table(i).node_display_flag = 'Y') and ( icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_REQUESTOR) = 'NO' or
                                 ak_query_pkg.g_items_table(i).update_flag = 'N' ) then

                             htp.p('<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || ak_query_pkg.g_items_table(i).attribute_label_long || '</TD>');
                             htp.p('<TD COLSPAN=2 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>');



--dc                          htp.p('if (parent.my_cart_header.' || ak_query_pkg.g_items_table(i).attribute_code || ' == "")');

                         if l_requestor_name  is NULL then

                          htp.p('<TABLE><TR><TD WIDTH=200 border=0 bgcolor=#FFFFFF>');
--dc                          htp.p('else');
                         else
                          htp.p('<TABLE><TR><TD border=0 bgcolor=#FFFFFF >');
		         end if;
                         --Bold
                         if ak_query_pkg.g_items_table(i).bold = 'Y' then
                            htp.p('<B>');
                         end if;
                         --Italics
                         if ak_query_pkg.g_items_table(i).italic = 'Y' then
                            htp.p('<I>');
                         end if;
                         htp.p(l_requestor_name || '<br>' );
                         --Bold
                         if ak_query_pkg.g_items_table(i).bold = 'Y' then
                            htp.p('</B>');
                         end if;
                         --Italics
                         if ak_query_pkg.g_items_table(i).italic = 'Y' then
                            htp.p('</I>');
                         end if;
                         htp.p('</TD><TD></TD><TD></TD></TR></TABLE>');
                         htp.p('</TD></TR>');

                         end if;

                 elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PO_BUTTON' then
                             /*
                             htp.p('result += "<TR><TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || icx_util.replace_quotes(ak_query_pkg.g_items_table(i).attribute_label_long) || '</TD>";');

                             htp.p('result += "<TD COLSPAN=1 ALIGN=' || ak_query_pkg.g_items_table(i).horizontal_alignment || ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment || '>";');


                             --dbutton := icx_util.DynamicButton(P_ButtonText     => 'Get a PO Number',
                             --                       P_ImageFileName   => 'FNDBNEW.gif',
                             --                       P_OnMouseOverText => 'Reserve a PO Number',
                             --                       P_HyperTextCall   => 'javascript:get_po()',
                             --                       P_LanguageCode    => v_language,
                             --                       P_JavaScriptFlag  => FALSE);
                             --dbutton := replace(  dbutton, '"', '\"' );
                             --htp.p('result += "' || dbutton || '";');


                             htp.p('result += "<INPUT TYPE=''button'' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code
                                  || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length
                                  || ' VALUE=''' ||  icx_util.replace_quotes(ak_query_pkg.g_items_table(i).attribute_code) || ''' onClick=''get_po()''>";');

			      l_pos := l_pos + 1;
                             htp.p('result += "</TD></TR>";');
                             */ null;

            elsif (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_ORG_ID' or
           ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_LOC_ID' or
           ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_LOC_CD') and
           ak_query_pkg.g_items_table(i).node_display_flag = 'Y' then

           htp.p('<INPUT TYPE=''' || 'HIDDEN' || ''' NAME=''' || ak_query_pkg.g_items_table(i).attribute_code || ''' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE="">');

                   l_pos := l_pos + 1;


                 end if;

            end if;  -- Object Attribute / Attribute

       end if;
		-- add by alex
		if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PAPER_CLIP') then
			--l_pos := l_pos + 1;
			fnd_webattch.GetSummaryStatus('ICX_REQS', 'REQ_HEADERS',
						      pk1, NULL, NULL,
						      NULL, NULL,
						      attachment_status);


			htp.p('<tr align="right"><td>'
			      || ak_query_pkg.g_items_table(i).attribute_label_long || '</td>');

			if (attachment_status <> 'DISABLE'
			    AND attachment_status = 'FULL')
			  then
			   htp.tableData(cvalue => '<a href="javascript:attachment(1, '''
					 || pk1
					 || ''' ,'''', '''
					 ||v_dcdname
					 ||''')" onMouseOver="window.status='''
					 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 ||''';return true"><IMG SRC=/OA_MEDIA/'
					 || v_language
					 || '/FNDIATTE.gif HEIGHT=16 WIDTH=16 BORDER=no ALT="'
					 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 ||'"></TD>'
					 ,calign => 'LEFT');
			 elsif (attachment_status <> 'DISABLE') then
			   htp.tableData(cvalue => '<a href="javascript:attachment(1, '''
					 || pk1
					 || ''' ,'''', '''
					 ||v_dcdname
					 ||''')" onMouseOver="window.status='''
					 || icx_util.replace_onmouseover_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 ||'''; return true"><IMG SRC=/OA_MEDIA/'
					 || v_language
					 || '/FNDIATT.gif HEIGHT=16 WIDTH=16 BORDER=no ALT="'
					 || icx_util.replace_alt_quotes(ak_query_pkg.g_items_table(i).attribute_label_long)
					 ||'"></TD>'
					 , calign => 'LEFT');
			end if;
/*				icx_util.DynamicButton(ak_query_pkg.g_items_table(i).attribute_label_long,
					'FNDBPLAY', ak_query_pkg.g_items_table(i).attribute_label_long,
					'javascript:attachment( 1, ''' || pk1 || ''', '''','''|| v_dcdName || ''')',v_language, false); */
			htp.p('</tr>');
			htp.p('<tr></tr>');

		end if;


  end loop;

   htp.p('</TABLE>');

end drawCartHeader;

procedure submit_item(n_org in varchar2,
                      n_emergency in varchar2 default null,
                      v_po_number in varchar2 default null,
                      cartId in number,
                      cartLineId in number,
                      cartLineAction in varchar2,
                      itemCount in number) is
begin
  if cartLineAction = 'COPY' then
      copy_line(n_org,cartId,cartLineId);
  elsif cartLineAction = 'DELETE' then
      delete_line(n_org,cartId,cartLineId);
  elsif cartLineAction = 'ACCOUNT' then
       -- icx_req_acct_dist.display_acct_distributions(p_cart_id => cartId,
         --                     p_cart_line_id => cartLineId);
          my_order(n_org => n_org, n_cart_id => cartId,
                  n_cart_line_id => cartLineId, n_account_dist => 'Y');
      RETURN;
  end if;

  my_order1(n_org,n_emergency,cartId,v_po_number);


end;

procedure copy_line(n_org number,cartId number,cartLineId number) is
  l_cart_id number;
  l_org_id number;
  l_cart_line_number number;
  l_dummy number;
  l_cart_line_id number;
  l_dist_num number;

  cursor get_line_number(v_cart_id number,v_cart_line_id number) is
     select cart_line_number
     from icx_shopping_cart_lines
     where cart_id = v_cart_id
     and cart_line_id = v_cart_line_id;

  cursor get_dist_number(v_cart_id number,v_cart_line_id number,v_org_id number) is
     select *
     from icx_cart_line_distributions
     where cart_id = v_cart_id
     and cart_line_id = v_cart_line_id
     and nvl(org_id,-9999) = nvl(v_org_id,-9999);

begin
  if icx_sec.validatesession then

     l_cart_id := icx_call.decrypt2(cartId);
     l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);

     l_cart_line_number := NULL;
     open get_line_number(l_cart_id,cartLineId);
     fetch get_line_number into l_cart_line_number;
     close get_line_number;

     if l_cart_line_number is not NULL and l_cart_line_number > 0 then

  /* semaphore for getting max line number */
        select 1 into l_dummy
        from icx_shopping_carts
        where cart_id = l_cart_id
        for update;

     update icx_shopping_cart_lines
     set cart_line_number = cart_line_number + 1
     where cart_id = l_cart_id
     and cart_line_number > l_cart_line_number;

     l_cart_line_number := l_cart_line_number + 1;
--changed by alex for attachment
--     select icx_shopping_cart_lines_s.nextval into l_cart_line_id from dual;
--new code:
     select PO_REQUISITION_LINES_S.nextval into l_cart_line_id from dual;


    insert into icx_shopping_cart_lines
 (CART_LINE_ID, CART_LINE_NUMBER,LAST_UPDATE_DATE, LAST_UPDATED_BY,
 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
 CART_ID, ITEM_ID, ITEM_REVISION,
 UNIT_OF_MEASURE, QUANTITY, UNIT_PRICE,
 SUPPLIER_ITEM_NUM, CATEGORY_ID, LINE_TYPE_ID,
 LINE_ID, ITEM_DESCRIPTION,
 EXPENDITURE_TYPE,
 DESTINATION_ORGANIZATION_ID, DELIVER_TO_LOCATION,DELIVER_TO_LOCATION_ID, SUGGESTED_BUYER_ID,
 SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_SITE,LINE_ATTRIBUTE_CATEGORY,
 LINE_ATTRIBUTE1, LINE_ATTRIBUTE2,  LINE_ATTRIBUTE3,
 LINE_ATTRIBUTE4, LINE_ATTRIBUTE5,  LINE_ATTRIBUTE6,
 LINE_ATTRIBUTE7, LINE_ATTRIBUTE8,  LINE_ATTRIBUTE9,
 LINE_ATTRIBUTE10, LINE_ATTRIBUTE11, LINE_ATTRIBUTE12,
 LINE_ATTRIBUTE13, LINE_ATTRIBUTE14, LINE_ATTRIBUTE15,
 NEED_BY_DATE, AUTOSOURCE_DOC_HEADER_ID, AUTOSOURCE_DOC_LINE_NUM,
 PROJECT_ID,TASK_ID , EXPENDITURE_ITEM_DATE,
 SUGGESTED_VENDOR_CONTACT, SUGGESTED_VENDOR_PHONE, SUGGESTED_VENDOR_ITEM_NUM,
 EXPENDITURE_ORGANIZATION_ID,ORG_ID,EXPRESS_NAME,ITEM_NUMBER,CUSTOM_DEFAULTED)
 select l_cart_line_id,l_cart_line_number,
 LAST_UPDATE_DATE, LAST_UPDATED_BY,
 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
 CART_ID, ITEM_ID, ITEM_REVISION,
 UNIT_OF_MEASURE, QUANTITY, UNIT_PRICE,
 SUPPLIER_ITEM_NUM, CATEGORY_ID, LINE_TYPE_ID,
 LINE_ID, ITEM_DESCRIPTION,
 EXPENDITURE_TYPE,
 DESTINATION_ORGANIZATION_ID, DELIVER_TO_LOCATION,DELIVER_TO_LOCATION_ID, SUGGESTED_BUYER_ID,
 SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_SITE,LINE_ATTRIBUTE_CATEGORY,
 LINE_ATTRIBUTE1, LINE_ATTRIBUTE2,  LINE_ATTRIBUTE3,
 LINE_ATTRIBUTE4, LINE_ATTRIBUTE5,  LINE_ATTRIBUTE6,
 LINE_ATTRIBUTE7, LINE_ATTRIBUTE8,  LINE_ATTRIBUTE9,
 LINE_ATTRIBUTE10, LINE_ATTRIBUTE11, LINE_ATTRIBUTE12,
 LINE_ATTRIBUTE13, LINE_ATTRIBUTE14, LINE_ATTRIBUTE15,
 NEED_BY_DATE, AUTOSOURCE_DOC_HEADER_ID, AUTOSOURCE_DOC_LINE_NUM,
 PROJECT_ID,TASK_ID , EXPENDITURE_ITEM_DATE,
 SUGGESTED_VENDOR_CONTACT, SUGGESTED_VENDOR_PHONE, SUGGESTED_VENDOR_ITEM_NUM,
 EXPENDITURE_ORGANIZATION_ID,ORG_ID,EXPRESS_NAME,ITEM_NUMBER,CUSTOM_DEFAULTED
 from icx_shopping_cart_lines
 where cart_line_id = cartLineId
 and cart_id = l_cart_id;
--  and nvl(l_org_id,-9999) = nvl(org_id,-9999);


 for prec in get_dist_number(l_cart_id,cartLineId,l_org_id) loop

    INSERT INTO icx_cart_line_distributions
                       (cart_line_id,
		        distribution_id,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        creation_date,
                        created_by,
                        org_id,
                        cart_id,
			distribution_num,
		        charge_account_id,
			charge_account_num,
                        allocation_type,
		        allocation_value,
                        charge_account_segment1,
			charge_account_segment2,
	 		charge_account_segment3,
 			charge_account_segment4,
			charge_account_segment5,
			charge_account_segment6,
                        charge_account_segment7,
                        charge_account_segment8,
                        charge_account_segment9,
                        charge_account_segment10,
 			charge_account_segment11,
                        charge_account_segment12,
                        charge_account_segment13,
                        charge_account_segment14,
                        charge_account_segment15,
                        charge_account_segment16,
                        charge_account_segment17,
                        charge_account_segment18,
                        charge_account_segment19,
                        charge_account_segment20,
                        charge_account_segment21,
                        charge_account_segment22,
                        charge_account_segment23,
                        charge_account_segment24,
                        charge_account_segment25,
                        charge_account_segment26,
                        charge_account_segment27,
                        charge_account_segment28,
                        charge_account_segment29,
                        charge_account_segment30)
          VALUES (l_cart_line_id,
                 icx_cart_line_distributions_s.nextval,
                 prec.last_updated_by,
                 sysdate,
                 prec.last_updated_by,
                 sysdate,
                 prec.created_by,
                 prec.org_id,
                 l_cart_id,
                 prec.distribution_num,
	         prec.charge_account_id,
                 prec.charge_account_num,
                 prec.allocation_type,
	         prec.allocation_value,
                 prec.charge_account_segment1,
		 prec.charge_account_segment2,
		 prec.charge_account_segment3,
  		 prec.charge_account_segment4,
       		 prec.charge_account_segment5,
	  	 prec.charge_account_segment6,
                 prec.charge_account_segment7,
                 prec.charge_account_segment8,
                 prec.charge_account_segment9,
                 prec.charge_account_segment10,
                 prec.charge_account_segment11,
                 prec.charge_account_segment12,
                 prec.charge_account_segment13,
                 prec.charge_account_segment14,
                 prec.charge_account_segment15,
                 prec.charge_account_segment16,
                 prec.charge_account_segment17,
                 prec.charge_account_segment18,
                 prec.charge_account_segment19,
                 prec.charge_account_segment20,
                 prec.charge_account_segment21,
                 prec.charge_account_segment22,
                 prec.charge_account_segment23,
                 prec.charge_account_segment24,
                 prec.charge_account_segment25,
                 prec.charge_account_segment26,
                 prec.charge_account_segment27,
                 prec.charge_account_segment28,
                 prec.charge_account_segment29,
                 prec.charge_account_segment30);
    end loop;


    update icx_shopping_carts
    set last_update_date = sysdate
    where cart_id = l_cart_id;
    /* close semaphore */

    commit;

  end if;
 end if;
end;

procedure delete_line(n_org number,cartId number,cartLineId number) is
   l_org_id number;
   l_cart_id number;
   l_cart_line_number number;
   l_dummy number;

   cursor get_line_number(v_cart_id number,v_cart_line_id number) is
     select cart_line_number
     from icx_shopping_cart_lines
     where cart_id = v_cart_id
     and cart_line_id = v_cart_line_id;


begin
   if icx_sec.validatesession then

      l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
      l_cart_id := icx_call.decrypt2(cartId);


     l_cart_line_number := NULL;
     open get_line_number(l_cart_id,cartLineId);
     fetch get_line_number into l_cart_line_number;
     close get_line_number;

     if l_cart_line_number is not NULL and l_cart_line_number > 0 then

        /* semaphore for getting max line number */
        select 1 into l_dummy
        from icx_shopping_carts
        where cart_id = l_cart_id
        for update;

        delete from icx_shopping_cart_lines
        where cart_line_id = cartLineId
        and cart_id = l_cart_id;
--      and nvl(org_id,-9999) = nvl(l_org_id,-9999);

        delete from icx_cart_line_distributions
        where cart_line_id = cartLineId
        and cart_id = l_cart_id;

        update icx_shopping_cart_lines
        set cart_line_number = cart_line_number - 1
        where cart_id = l_cart_id
        and cart_line_number  > l_cart_line_number;

        update icx_shopping_carts
        set last_update_date = sysdate
        where cart_id = l_cart_id;
        /* close semaphore */

        commit;

     end if;
   end if;
end;


procedure printHiddenflds(shopper_id number,v_cart_id number,v_header_region varchar2,v_lines_region varchar2,l_pos in out number) is

  v_where_clause varchar2(2000);
  v_vendor_on_flag    varchar2(1);
  v_req_overwrite_flag   varchar2(1);
  l_col number;
  l_shopper_id number;
/* Change wrto Bug Fix to implement the Bind Vars **/
  where_clause_binds      ak_query_pkg.bind_tab;
  v_index                 NUMBER;

begin

   v_index := 1;

   /* now for Line level hidden fields */
--   v_where_clause := 'SHOPPER_ID = ' || shopper_id || 'AND CART_ID = ' || v_cart_id;
     v_where_clause := 'SHOPPER_ID = :shopper_id1_bin AND CART_ID = :cart_id1_bin';
/* added code to take care of Bind vars Bug **/
  where_clause_binds(v_index).name := 'shopper_id1_bin';
  where_clause_binds(v_index).value := shopper_id;
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'cart_id1_bin';
  where_clause_binds(v_index).value := v_cart_id;
  v_index := v_index + 1;


   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_lines_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'F',
                                P_RETURN_CHILDREN       => 'F',
                               P_WHERE_BINDS            => where_clause_binds);


   l_col := 0;

   -- code the required hidden fields for LOV use
   htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_DEST_ORG_ID_L" VALUE="">');
   htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_DELIVER_TO_LOCATION_ID_L" VALUE="">');
   htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_DELIVER_TO_LOCATION_L" VALUE="">');

   l_pos := l_pos + 3;

   v_req_overwrite_flag := icx_sec.getID(icx_sec.PV_USER_REQ_OVERRIDE_LOC_FLAG);
   ICX_REQ_NAVIGATION.chk_vendor_on(v_vendor_on_flag);

   for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST loop

           if  (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' and
              v_vendor_on_flag = 'Y') then

			   -- for LOV use
                           htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_SUGGESTED_VENDOR_NAME" VALUE="">');
                           htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_SUGGESTED_VENDOR_SITE" VALUE="">');
                           htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_SUGGESTED_VENDOR_CONTACT" VALUE="">');
                           htp.p('<INPUT TYPE="HIDDEN" NAME="ICX_SUGGESTED_VENDOR_PHONE" VALUE="">');

                           l_pos := l_pos + 4;
             end if;


   /* determine if LOV is user configurable */
       if ak_query_pkg.g_items_table(i).lov_attribute_code is not NULL and
          ak_query_pkg.g_items_table(i).lov_region_code is not NULL and
	  ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_NAME' and
          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_CONTACT' and
          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_SITE' and
          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_PHONE' and
	  ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION_L' and
          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DELIVER_TO_LOCATION_ID_L' and
          ak_query_pkg.g_items_table(i).attribute_code <> 'ICX_DEST_ORG_ID_L' then

          if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SHOPPER_ID' then
             l_shopper_id := icx_call.encrypt2(to_char(shopper_id));
             htp.p('<INPUT TYPE="HIDDEN" NAME="' || ak_query_pkg.g_items_table(i).attribute_code || '" VALUE="' || l_shopper_id || '">');
          else

             htp.p('<INPUT TYPE="HIDDEN" NAME="' || ak_query_pkg.g_items_table(i).attribute_code || '" VALUE = "">');
          end if;

          l_pos := l_pos + 1;

       end if;

   end loop;


end;


------------------------------------------------------------
procedure my_order(n_org        varchar2,
                   n_emergency  varchar2   default NULL,
                   n_cart_id    number     default NULL,
                   v_po_number  varchar2   default NULL,
                   n_cart_line_id number   default NULL,
                   n_account_dist varchar2 default NULL) is
------------------------------------------------------------
    v_dcdName    varchar2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');

begin
   IF (n_account_dist is NULL) THEN
--add by alex
	ICX_REQ_ORDER.pk1 := icx_call.decrypt2(n_cart_id);

    htp.htmlOpen;
    htp.headOpen;
    htp.headClose;

    htp.framesetOpen('*,44','','BORDER=0');
    htp.frame(v_dcdName ||
           '/ICX_REQ_ORDER.my_order1?n_org=' || n_org || '&n_emergency=' ||
           n_emergency || '&n_cart_id=' || n_cart_id || '&v_po_number=' || v_po_number,'my_order1','0','0','auto','', 'FRAMEBORDER=YES');

    htp.frame(v_dcdName ||
           '/ICX_REQ_ORDER.my_order2?n_org=' || n_org || '&n_emergency=' ||
           n_emergency || '&n_cart_id=' || n_cart_id || '&v_po_number=' || v_po_number,'my_order2','0','0','no','NORESIZE', 'FRAMEBORDER=YES');

     htp.framesetClose;
     htp.htmlClose;

--   ELSIF n_account_dist = 'Y' THEN
  ELSE

    htp.htmlOpen;
    htp.headOpen;
    htp.headClose;
    htp.framesetOpen('*,44','','BORDER=0');
    htp.frame(v_dcdName ||
           '/icx_req_acct_dist.display_acct_distributions?p_cart_id=' || n_cart_id || '&p_cart_line_id=' ||
           n_cart_line_id ,'my_order_account1','0','0','auto','', 'FRAMEBORDER=YES');

    htp.frame(v_dcdName ||
           '/icx_req_acct_dist.print_action_buttons' ,'my_order_account2','0','0','no','NORESIZE', 'FRAMEBORDER=YES');

     htp.framesetClose;
     htp.htmlClose;

   END IF;

end my_order;


------------------------------------------------------------
procedure my_order1(n_org        varchar2,
                   n_emergency  varchar2   default NULL,
		   n_cart_id    number     default NULL,
                   v_po_number  varchar2   default NULL) is
------------------------------------------------------------

v_regions_table    ak_query_pkg.regions_table_type;
v_items_table      ak_query_pkg.items_table_type;
v_results_table    ak_query_pkg.results_table_type;

v_emergency        varchar2(10);
v_org              number;
v_cart_id          number;
v_header_region    varchar2(100);
v_lines_region     varchar2(100);
shopper_id         number;
v_where_clause     varchar2(1000);
v_dcdName          varchar2(240) := owa_util.get_cgi_env('SCRIPT_NAME');
l_session_id       number;
v_order_button_text varchar2(80);
v_confirm_text varchar2(240);
v_lang             varchar2(20);
v_money_fmt_mask   varchar2(32);
v_currency         varchar2(30);
v_precision        number;
l_total_price_column number := 0;
l_pos 		   number;

/* Change wrto Bug Fix to implement the Bind Vars **/
  where_clause_binds      ak_query_pkg.bind_tab;
  where_clause_binds_empty     ak_query_pkg.bind_tab;
  v_index                 NUMBER;
begin



  if (icx_sec.validatesession()) then

   v_index   := 1;

   shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    --decrypt parameters
   v_org := icx_call.decrypt2(n_org);
   if n_emergency is not null then
         v_emergency := icx_call.decrypt2(n_emergency);
   end if;
   v_cart_id := icx_call.decrypt2(n_cart_id);

   ICX_REQ_NAVIGATION.get_currency(v_org, v_currency, v_precision, v_money_fmt_mask);
   v_money_fmt_mask := FND_CURRENCY.GET_FORMAT_MASK(v_currency,30);


   htp.htmlOpen;
   htp.headOpen;
   icx_util.copyright;
   js.scriptOpen;

   js.replaceDBQuote;
   icx_util.LOVScript;


--debug
l_session_id := to_number(icx_sec.getID(icx_sec.PV_SESSION_ID));
--insert into debug_timings values (1000, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'drawCartErrors started.');
--debug


--debug
--insert into debug_timings values (1001, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'updateCartHeaderObject started.');
--debug

   updateCartHeaderObject;
--   if v_emergency = 'YES' then
--      get_po(n_org,n_cart_id);
--   end if;

   updateCarts;

   if v_emergency = 'YES' then
           v_header_region := 'ICX_SHOPPING_CART_HEADER_EMG_R';
           v_lines_region  := 'ICX_SHOPPING_CART_LINES_EMG_R';
   else
           v_header_region := 'ICX_SHOPPING_CART_HEADER_R';
           v_lines_region := 'ICX_SHOPPING_CART_LINES_R';
   end if;

     -- Cart Lines Related Object Navigator
     ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_lines_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_RETURN_PARENTS        => 'F',
                                P_RETURN_CHILDREN       => 'F');

     cart_line_actions(n_org);

--debug
--insert into debug_timings values (1003, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'PrintHead loading started.');
--debug

   --add by alex
   addAttachmentScript;

   js.scriptClose;
   htp.headClose;

   htp.bodyOpen('','BGCOLOR="#CCFFFF" onLoad="parent.parent.winOpen(''nav'', ''my_order'')"');

   htp.p('<FORM ACTION="' || v_dcdName || '/ICX_REQ_ORDER.submit_item"  NAME="LINE" METHOD="POST">');
   htp.formHidden('n_org',n_org);
   htp.formHidden('n_emergency',n_emergency);
   htp.formHidden('v_po_number',v_po_number);
   htp.formHidden('cartId',n_cart_id);
   htp.formHidden('cartLineId','');
   htp.formHidden('cartLineAction','');
   htp.formHidden('itemCount',1);
   htp.p('</FORM>');

--add by alex
   htp.p('<FORM ACTION="' || v_dcdName || '/fnd_webattch.Summary"  NAME="HEADER_ATTCH" METHOD="POST" TARGET="_top">');
   htp.formHidden('function_name', 'ICX_REQS');
   htp.formHidden('entity_name', 'REQ_HEADERS');
   htp.formHidden('pk1_value', '');
   htp.formHidden('pk2_value', '');
   htp.formHidden('pk3_value','');
   htp.formHidden('pk4_value', '');
   htp.formHidden('pk5_value', '');
   htp.formHidden('from_url', '');
   htp.formHidden('query_only', 'N');
	htp.p('</FORM>');


   l_pos := 0;
   htp.p('<FORM ACTION="" NAME="LOVFIELDS" METHOD="POST">');
   printHiddenflds(shopper_id,v_cart_id,v_header_region,v_lines_region,l_pos);
   htp.p('</FORM>');

   htp.p('<FORM ACTION="' || v_dcdName || '/ICX_REQ_SUBMIT.finalSubmit"  NAME="KEVIN" METHOD="POST" TARGET="navigation">');

--debug
l_session_id := to_number(icx_sec.getID(icx_sec.PV_SESSION_ID));
--insert into debug_timings values (1006, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'in body drawCartErrors started.');
--debug

     drawCartErrors(v_cart_id);

--debug
--insert into debug_timings values (1007, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'In body drawCartHeader started.');
--debug

    -- Cart Header Related Object Navigator
--     v_where_clause := 'SHOPPER_ID = ' || shopper_id || 'AND CART_ID = ' || v_cart_id;
     v_where_clause := 'SHOPPER_ID = :shopper_id_bin AND CART_ID = :cart_id_bin';
  where_clause_binds(v_index).name := 'shopper_id_bin';
  where_clause_binds(v_index).value := shopper_id;
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'cart_id_bin';
  where_clause_binds(v_index).value := v_cart_id;
  v_index := v_index + 1;

--debug
--insert into debug_timings values (1004, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'AK query header started.');
--debug

     ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_header_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F',
                                P_WHERE_BINDS           => where_clause_binds );


--change by alex
   l_pos := 0;
   drawCartHeader(n_org,n_cart_id,v_org, v_emergency,v_po_number,l_pos);


   where_clause_binds := where_clause_binds_empty;

   v_index := 1;

   -- Cart Line Related Object Navigator
--   v_where_clause := 'SHOPPER_ID = ' || shopper_id || 'AND CART_ID = ' || v_cart_id;
     v_where_clause := 'SHOPPER_ID = :shopper_id1_bin AND CART_ID = :cart_id1_bin';
/* added code to take care of Bind vars Bug **/
  where_clause_binds(v_index).name := 'shopper_id1_bin';
  where_clause_binds(v_index).value := shopper_id;
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'cart_id1_bin';
  where_clause_binds(v_index).value := v_cart_id;
  v_index := v_index + 1;


--debug
--insert into debug_timings values (1008, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'AK query lines started.');
--debug

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_lines_region,
                                P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F',
                                P_WHERE_BINDS           => where_clause_binds );

--debug
--insert into debug_timings values (1009, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'AK query line end.');
--debug


   if ak_query_pkg.g_results_table.COUNT = 0 then

      js.scriptOpen;
      htp.p('resetItemCount(document.LINE.itemCount)');
      js.scriptClose;

      FND_MESSAGE.SET_NAME('ICX','ICX_CART_EMPTY');
      htp.p('<BR>' || FND_MESSAGE.GET || '<BR>');

   else


--debug
--insert into debug_timings values (1010, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'drawCartLines body started.');
--debug

      drawCartLines(l_pos,v_currency,v_lines_region,l_total_price_column,v_money_fmt_mask);

--debug
--insert into debug_timings values (1011, l_session_id,
--        to_char(sysdate, 'HH24:MI:SS'), 'drawCartLines end.');
--debug


   end if;

   htp.p('</TABLE></FORM>');

   htp.bodyClose;
   htp.htmlClose;

 end if;

end my_order1;



------------------------------------------------------------
procedure my_order2(n_org        varchar2,
                   n_emergency  varchar2   default NULL,
                   n_cart_id    number     default NULL,
                   v_po_number  varchar2   default NULL) is
------------------------------------------------------------

v_order_button_text varchar2(80);
v_confirm_text varchar2(240);
v_lang  varchar2(20);

begin

  if icx_sec.validatesession then
   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

   htp.htmlOpen;
   htp.headOpen;

   js.ScriptOpen;
   submit_line_actions;
   js.ScriptClose;

   htp.headClose;
   htp.bodyOpen('','BGCOLOR="#CCFFFF" onLoad="parent.parent.winOpen(''nav'',''my_order'');"');


   htp.p('<FORM>');
   htp.tableOpen('border=0');
   htp.tableRowOpen;
           FND_MESSAGE.SET_NAME('MRP','EC_ORDER');
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_PLACE_ORDER');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBSBMT.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:submit_order()',
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_SAVE');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBSAVE.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:save_order()',
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_RQS_DELETE_ORDER');
           v_order_button_text :=  FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBCNCL.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:delete_saved_cart()',
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

    htp.p('<TD WIDTH=1000></TD>');

       htp.p('<TD>');
	   FND_MESSAGE.SET_NAME('ICX','ICX_APPLY_CHANGES');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBAPLY.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:modify_order()',
                                  P_LanguageCode    => v_lang,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');


    htp.tableRowClose;
    htp.tableClose;
    htp.p('</FORM>');

    htp.bodyClose;
    htp.htmlClose;

  end if;

end;


------------------------------------------------
procedure reserve_po_num(reserved_po_num IN OUT varchar2,n_cart_id number,n_org number) is
------------------------------------------------

     CURSOR C3 IS SELECT to_char(current_max_unique_identifier + 1)
                  FROM   po_unique_identifier_control
                  WHERE  table_name = 'PO_HEADERS'
                  FOR UPDATE OF current_max_unique_identifier;

     l_po_num varchar2(1000);
     l_cart_id number;
     l_org_id number;

begin

  l_org_id := icx_call.decrypt2(n_org);
  l_cart_id := icx_call.decrypt2(n_cart_id);
--  if icx_sec.validatesession then
    if reserved_po_num is null OR reserved_po_num = '' then
         OPEN C3;
         FETCH C3 into reserved_po_num;
         UPDATE po_unique_identifier_control
         SET    current_max_unique_identifier =
                current_max_unique_identifier + 1
         WHERE  CURRENT of C3;
         CLOSE C3;


         l_po_num := reserved_po_num;
         if l_po_num is not NULL then
            update icx_shopping_carts
            set reserved_po_num =  l_po_num
	    where cart_id = l_cart_id;
         end if;
         commit;
    end if;
--  end if;

end reserve_po_num;

------------------------------------------------------------
procedure get_emergency_po_num(n_org varchar2,n_cart_id number) is
------------------------------------------------------------
v_po_number varchar2(100);

begin

   v_po_number := NULL;

   reserve_po_num(v_po_number,n_cart_id,n_org);

   my_order1(n_org, icx_call.encrypt2('YES'), n_cart_id, v_po_number);

end;

--**********************************************************
-- END PROCEDURES RELATED TO CART/MY ORDER
--**********************************************************



--**********************************************************
-- BEGIN OTHER PROCEDURES
--**********************************************************

------------------------------------------------------------
function addURL(URL          varchar2,
                display_text varchar2)
  return varchar2 is
------------------------------------------------------------
v_return   varchar2(2000);

begin
	if URL is null then
	   v_return := display_text;
	else
        v_return := htf.anchor('javascript:top.popWindow(''' || URL || ''')', display_text);
	end if;

      return v_return;

end addURL;


------------------------------------------------------------
procedure get_currency(v_org        in  number,
                       v_currency   out varchar2,
                       v_precision  out number,
                       v_fmt_mask   out varchar2) is
------------------------------------------------------------
   cursor getCurrency is
   select gsob.CURRENCY_CODE,
	  fc.PRECISION
   from   gl_sets_of_books gsob,
 	  FND_CURRENCIES fc,
	  org_organization_definitions ood
   where  ood.ORGANIZATION_ID = v_org
   and    fc.CURRENCY_CODE = gsob.CURRENCY_CODE
   and    ood.SET_OF_BOOKS_ID = gsob.SET_OF_BOOKS_ID;

i          number := 0;
v_return   varchar2(32);
 begin

   open getCurrency;
   fetch getCurrency into v_currency, v_precision;
   close getCurrency;


  v_return := '999999999D';
  for i in 1 .. v_precision loop
     v_return := v_return || '9';
  end loop;
  v_fmt_mask := v_return;

 end get_currency;


------------------------------------------------------------
procedure shopper_info(v_shopper_id    IN  number,
                       v_shopper_name  OUT VARCHAR2,
                       v_location_id   OUT number,
                       v_location_code OUT VARCHAR2,
                       v_org_id        OUT NUMBER,
                       v_org_code      OUT VARCHAR2) is
------------------------------------------------------------

   cursor shopper(v_shop_id number) is
      select  hrev.full_name,
              hrl.location_id,
              hrl.location_code,
              ood.organization_id,
              ood.organization_code
      from    hr_locations hrl,
              hr_employees_current_v hrev,
              org_organization_definitions ood,
              financials_system_parameters fsp
      where   hrev.employee_id = v_shop_id
      and     hrev.location_id = hrl.location_id
      and     ood.organization_id = nvl(hrl.inventory_organization_id,
                                     fsp.inventory_organization_id)
      and     sysdate < nvl(hrl.inactive_date, sysdate + 1);

begin

     open shopper(v_shopper_id);
     fetch shopper into v_shopper_name, v_location_id, v_location_code, v_org_id, v_org_code;
     close shopper;

end shopper_info;






end ICX_REQ_ORDER;

/
