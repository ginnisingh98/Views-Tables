--------------------------------------------------------
--  DDL for Package Body POS_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN" AS
/* $Header: POSASNEB.pls 115.16 2001/10/19 16:19:10 pkm ship      $ */

FUNCTION set_session_info RETURN BOOLEAN is
BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN FALSE;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  RETURN TRUE;

END set_session_info;

PROCEDURE button(src1 IN varchar2,
                 txt1 IN varchar2,
                 src2 IN varchar2,
                 txt2 IN varchar2) IS
BEGIN

  htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif ></td>
           <td width=15 rowspan=5></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src1 || '"><font class=button>'|| txt1 || '</font></a></td>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src2 || '"><font class=button>'|| txt2 || '</font></a></td>
          </tr>
          <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
          <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
         </table>
       ');

END button;

FUNCTION po_num(seg1 in varchar2) RETURN VARCHAR2 IS
  p_rowid    VARCHAR2(2000);
  l_param    VARCHAR2(2000);
  Y          VARCHAR2(2000);
  header_id  NUMBER;
BEGIN

  fnd_client_info.set_org_context(l_org_id);

  select  rowidtochar(ROWID)
  into    p_rowid
  from    AK_FLOW_REGION_RELATIONS
  where   FROM_REGION_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_REGION_APPL_ID = 178
  and     FROM_PAGE_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_PAGE_APPL_ID = 178
  and     TO_PAGE_CODE = 'ICX_PO_HEADERS_DTL_D'
  and     TO_PAGE_APPL_ID = 178
  and     FLOW_CODE = 'ICX_INQUIRIES'
  and     FLOW_APPLICATION_ID = 178;

  select po_header_id
  into header_id
  from po_headers
  where TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT') and
        segment1 = decode(instrb(seg1,'-'), 0, seg1, substr(seg1, 1, (instrb(seg1,'-')-1)));

  l_param :=  icx_on_utilities.buildOracleONstring(p_rowid => p_rowid,
                                                   p_primary_key => 'ICX_PO_SUPPLIER_ORDERS_PK',
                                                   p1 => to_char(header_id));

  Y := icx_call.encrypt2(l_param,l_session_id);

  return l_script_name || '/OracleOn.IC?Y=' || Y;

END po_num;

FUNCTION item_reqd(l_index in number) RETURN VARCHAR2 IS
BEGIN
   if ak_query_pkg.g_items_table(l_index).required_flag = 'Y' then
      return  '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>';
   else
      return '';
   end if;
END item_reqd;

FUNCTION item_halign(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ' align=' ||
           ak_query_pkg.g_items_table(l_index).horizontal_alignment;

END item_halign;

FUNCTION item_valign(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ' valign=' ||
          ak_query_pkg.g_items_table(l_index).vertical_alignment;

END item_valign;

FUNCTION item_name(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ak_query_pkg.g_items_table(l_index).attribute_label_long;

END item_name;

FUNCTION item_code(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ak_query_pkg.g_items_table(l_index).attribute_code;

END item_code;

FUNCTION item_style(l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ak_query_pkg.g_items_table(l_index).item_style;

END item_style;

FUNCTION item_displayed(l_index in number) RETURN BOOLEAN IS
BEGIN

  RETURN (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y');

END item_displayed;

FUNCTION item_updateable(l_index in number) RETURN BOOLEAN IS
BEGIN

 RETURN (ak_query_pkg.g_items_table(l_index).update_flag = 'Y');

END item_updateable;

FUNCTION item_size (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' size='  || to_char(ak_query_pkg.g_items_table(l_index).display_value_length);

END item_size;

FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' maxlength=' || to_char(ak_query_pkg.g_items_table(l_index).attribute_value_length);

END item_maxlength;

FUNCTION item_lov(l_index in number) RETURN VARCHAR2 IS
BEGIN

  IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
                   ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL)
      THEN
      return  '<A HREF="javascript:call_lov('''||
                         item_code(l_index) || ''')"' ||
                        '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 ' ||
                        'HEIGHT=21 border=no align=absmiddle></A>';
  ELSE
     return '';
  END IF;

END item_lov;

FUNCTION item_lov_multi(l_index in number, l_row in number, l_wip_row in number) RETURN VARCHAR2 IS
BEGIN

  IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
                   ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL)
      THEN
      return  '<A HREF="javascript:call_LOV('''||
                         item_code(l_index) || '''' || ',' || '''' || to_char(l_row-1) ||
                         '''' || ',' || '''' || l_script_name || '''' || ',' ||
                         '''' || to_char(l_wip_row-1) ||
                         ''')"' ||
                        '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 ' ||
                        'HEIGHT=21 border=no align=absmiddle></A>';
  ELSE
     return '';
  END IF;

END item_lov_multi;

FUNCTION item_wrap(l_index in number) RETURN VARCHAR2 IS
BEGIN

   IF item_code(l_index) = 'POS_ITEM_DESCRIPTION' THEN
      RETURN ' nowrap ';
   ELSE
      RETURN '';
   END IF;

END item_wrap;

PROCEDURE hidden_label(l_index in number) IS
BEGIN

   htp.p('<!-- ' || item_code(l_index)  ||
             ' - '   || item_style(l_index) || ' -->');

END hidden_label;

PROCEDURE hidden_field(l_index in number,
                       l_res_index in number,
                       l_col in number) IS
BEGIN

   htp.p('<input name="' || item_code(l_index) ||
         '" type="HIDDEN" VALUE="' || get_result_value(l_res_index, l_col) ||
         '">');

END hidden_field;

PROCEDURE single_row_label(l_index in number) IS
BEGIN

   htp.p('<td bgcolor=#cccccc' ||
         item_halign(l_index) ||
         item_valign(l_index) ||
         '>' || item_reqd(l_index) ||
         '<font class=promptblack>' || item_name(l_index) ||
         '</font>' ||
         '</td>');

END single_row_label;

PROCEDURE multi_row_label (l_index in number) IS
BEGIN

   htp.p('<td bgcolor=#336699' ||
         item_halign(l_index) ||
          item_valign(l_index) ||
          '>' ||
          item_reqd(l_index)
          );

   IF item_code(l_index) = 'POS_SELECT' THEN
      htp.p('<a href="javascript:check_all()" >');
   END IF;

   htp.p('<font class=promptwhite>' || item_name(l_index) || '</font>');

   IF item_code(l_index) = 'POS_SELECT' THEN
      htp.p('</a>');
   END IF;

   htp.p('</td>');

END multi_row_label;

PROCEDURE non_updateable(l_index in number,
                         l_res_index in number,
                         l_col in number) IS
BEGIN

   htp.p('<td ' || item_wrap(l_index) ||
         item_halign(l_index) ||
         item_valign(l_index) ||
         '>');

   IF item_code(l_index) = 'POS_PO_NUM' THEN

      htp.p('<a target="PONUM" href="' || po_num(get_result_value(l_res_index, l_col)) ||
            '">' ||
            '<font class=tabledata>' ||
            nvl(get_result_value(l_res_index, l_col), '&nbsp') ||
            '</font></a>');
   ELSE

      htp.p('<font class=tabledata>' ||
            nvl(get_result_value(l_res_index, l_col), '&nbsp') ||
            '</font>');
   END IF;

   htp.p('</td>');

END non_updateable;

PROCEDURE updateable(l_index in number,
                     l_res_index in number,
                     l_col in number,
                     l_row in number default null,
                     l_wip_row in number default null) IS
x_value varchar2(2000);
BEGIN

   x_value := ltrim(get_result_value(l_res_index, l_col));

   IF ship_date_error AND item_code(l_index) = 'POS_SHIP_DATE' THEN
      x_value := x_ship_date;
   END IF;

   IF receipt_date_error AND item_code(l_index) = 'POS_EXPECTED_RECEIPT_DATE' THEN
      x_value := x_receipt_date;
   END IF;

   htp.p('<td nowrap' ||
         item_halign(l_index) ||
         item_valign(l_index) ||
         '>' ||
         '<font class=datablack>'||
         '<input type=text ' || item_size(l_index) || item_maxlength(l_index) ||
         ' name="'  || item_code(l_index) || '"' ||
         ' value="' ||
         x_value ||
         '" ></font>');

  IF l_row is null THEN
    htp.p('</td><td width=23>');
    htp.p(item_lov(l_index));
    htp.p('</td>');
  ELSE
    htp.p(item_lov_multi(l_index,l_row,l_wip_row));
  END IF;

  htp.p('</td>');

END updateable;

PROCEDURE image(l_index in number,
                href in varchar2) IS
BEGIN

   htp.p('<td nowrap ' ||
         item_halign(l_index) ||
         item_valign(l_index) ||
         '>' ||
         '<a href=' || href ||
         ' target="_self"><IMG NAME="' ||
         item_code(l_index) ||
         '" src=/OA_MEDIA/FNDIITMD.gif border=no></a></td>');

END image;

PROCEDURE buyer_notify IS
 l_ItemType   VARCHAR2(100) := 'POSASNNT';
 l_ItemKey    VARCHAR2(100);
 i            NUMBER        := 0;
BEGIN

   FOR c_rec in c_buyer LOOP

     i := i + 1;
     l_ItemKey := 'POS_CREATE_ASN' || to_char(l_header_id) || '-' || to_char(i);

     wf_engine.createProcess(ItemType  => l_ItemType,
                             ItemKey   => l_ItemKey,
                             Process   => 'BUYER_NOTIFICATION');

     wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                 itemkey  => l_ItemKey,
                                 aname    => 'BUYER_USER_ID',
                                 avalue   => c_rec.buyer_id);

     wf_engine.SetItemAttrText(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SHIPMENT_NUM',
                               avalue   => c_rec.shipment_num);

     wf_engine.SetItemAttrDate(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SHIP_DATE',
                               avalue   => c_rec.ship_date);

     wf_engine.SetItemAttrDate(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'EXPECTED_RECEIPT_DATE',
                               avalue   => c_rec.expected_receipt_date);

     wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                 itemkey  => l_ItemKey,
                                 aname    => 'SUPPLIER_ID',
                                 avalue   => c_rec.supplier_id);

     wf_engine.SetItemAttrText(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SUPPLIER',
                               avalue   => c_rec.supplier);

     wf_engine.StartProcess(ItemType   => l_ItemType,
                            ItemKey    => l_ItemKey );
   END LOOP;

END buyer_notify;

PROCEDURE init_page IS

BEGIN

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

END init_page;

PROCEDURE init_body IS
BEGIN

  htp.headClose;
  htp.bodyOpen(null,'bgcolor=#cccccc link=blue vlink=blue alink=#ff0000');

END init_body;

PROCEDURE close_page IS
BEGIN

  htp.bodyClose;
  htp.htmlClose;

END close_page;

PROCEDURE show_edit_page IS
BEGIN

  init_page;

  htp.headClose;

  htp.p('  <script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
  htp.p('  </script>');


  htp.p('<frameset rows = "30%, 12%, 53%, 5%"  border=0>');

  htp.p('<frame src="' || l_script_name ||
        '/pos_asn.show_edit_header"' ||
        '   name=header'     ||
        '   marginwidth=0'   ||
        '   marginheight=0'  ||
        '   scrolling=auto>');

  htp.p('<frame src="' || l_script_name ||
        '/pos_asn.show_shipment_help"' ||
        '   name=shiphelp'     ||
        '   marginwidth=0'   ||
        '   marginheight=0'  ||
        '   scrolling=no>');

  htp.p('<frame src="' || l_script_name ||
        '/pos_asn.show_edit_shipments"' ||
        '   name=shipments'  ||
        '   marginwidth=5'   ||
        '   marginheight=0'  ||
        '   scrolling=auto>');

  htp.p('<frame src="' || l_script_name ||
        '/pos_asn.show_delete_frame"' ||
        '   name=delete'  ||
        '   marginwidth=5'   ||
        '   marginheight=0'  ||
        '   scrolling=no>');

  htp.p('</frameset>');

  htp.htmlClose;

END show_edit_page;

PROCEDURE show_edit_header IS
BEGIN

  init_page;

  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;

  htp.p('  <script src="/OA_HTML/POSASNED.js" language="JavaScript">');
  htp.p('  </script>');

  htp.p('<body bgcolor=#cccccc onLoad="javascript:LoadPage(' ||
        '''' || sub_state || '''' || ',' ||
        '''' || error_message  || '''' || ',' ||
        '''' || but1  || '''' || ',' ||
        '''' || but2  || '''' || ',' ||
        '''' || but3  || '''' ||
        ')"' || 'link=blue vlink=blue alink=#ff0000>');

  htp.p('<form name="POS_ASN_HEADER" action="' || l_script_name ||
        '/pos_asn.update_header" target="header" method="GET">');

  print_edit_header;

  htp.p('</form>');

  close_page;

END show_edit_header;

PROCEDURE show_shipment_help IS
  v_messageText1      VARCHAR2(2000);
  v_messageText2      VARCHAR2(2000);
  v_messageText3      VARCHAR2(2000);
BEGIN

   v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_SHIPMENT_HT1');
   v_messageText2 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_SHIPMENT_HT2');
   v_messageText3 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_SHIPMENT_HT3');

   init_page;
   init_body;

   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');
   htp.p('<!-- This row contains the help text -->');

   htp.p('<tr>
          <td height=1 bgcolor=black><img src=/OA_MEDIA/FNDPX1.gif></td>
         </tr>');

   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         v_messageText1 ||
         '</font></td>');
   htp.p('</tr>');

   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         v_messageText2 ||
         '</font></td>');
   htp.p('</tr>');

   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         v_messageText3 ||
         '</font></td>');
   htp.p('</tr>');

   htp.p('</table>');

   close_page;

END show_shipment_help;

PROCEDURE show_edit_shipments IS
BEGIN

  init_page;

  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;

  htp.p('  <script src="/OA_HTML/POSASNED.js" language="JavaScript">');
  htp.p('  </script>');

  htp.headClose;
  htp.p('<body bgcolor=#cccccc onLoad="javascript:LoadPage(' ||
        '''' || sub_state  || '''' || ',' ||
        '''' || error_message  || '''' || ',' ||
        '''' || but1  || '''' || ',' ||
        '''' || but2  || '''' || ',' ||
        '''' || but3  || '''' ||
        ')"' || 'link=blue vlink=blue alink=#ff0000>');

-- Create a dummy form to allow for multi row lovs (--,--)

  htp.p('<form name="POS_ASN">' ||
        '<input name="POS_UNIT_OF_MEASURE" type="HIDDEN" VALUE="">' ||
        '<input name="POS_UOM_CLASS" type="HIDDEN" VALUE="">' ||
        '<input name="POS_PO_DISTRIBUTION_ID" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ASN_WIP_JOB" type="HIDDEN" VALUE="">' ||
        '<input name="POS_WIP_ENTITY_ID" type="HIDDEN" VALUE="">' ||
        '<input name="POS_WIP_OPERATION_SEQ_NUM" type="HIDDEN" VALUE="">' ||
        '<input name="POS_WIP_LINE_ID" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ITEM_ID" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ITEM_DESCRIPTION" type="HIDDEN" VALUE="">' ||
        '</form>');

  htp.p('<form name="POS_ASN_SHIPMENTS" ACTION="' || l_script_name ||
        '/pos_asn.update_shipments" target="shipments" method="GET">');

  print_edit_shipments;

  htp.p('</form>');

  close_page;

END show_edit_shipments;

PROCEDURE show_delete_frame IS
 v_messageText1 VARCHAR2(2000);
 v_messageText2 VARCHAR2(2000);
BEGIN

  v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_COPY_BUT');
  v_messageText2 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_DELETE_BUT');

  init_page;
  init_body;

  button('javascript:parent.shipments.delt()', v_messageText2,
         'javascript:parent.shipments.explode()', v_messageText1);

  close_page;

END show_delete_frame;

PROCEDURE err_htp(msg IN VARCHAR2) IS
BEGIN
  IF (nvl(length(error_message), 0) + length(msg)) < MAX_ERROR_LEN then
     error_message := error_message || msg;
  END IF;
END err_htp;

PROCEDURE show_error_page IS
title VARCHAR2(2000);
BEGIN

  title := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_MESS_WIN_T2');

  err_htp(htf.htmlOpen);
  err_htp('<TITLE>' || title || '</TITLE>');
  err_htp(htf.headOpen);
  err_htp('<LINK REL=STYLESHEET HREF=/OA_HTML/US/POSSTYLE.css>');

  err_htp(htf.headClose);
  err_htp('<body bgcolor=#cccccc >');

  IF header_error THEN
     print_simple_head_err_page;
  ELSE
     print_error_page;
  END if;

END show_error_page;

PROCEDURE show_ok_page IS
v_messageText1      VARCHAR2(2000);
title               VARCHAR2(2000);
BEGIN

  v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_CREATED');
  title := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_MESS_WIN_T1');

  err_htp(htf.htmlOpen);
  err_htp('<TITLE>' || title || '</TITLE>');
  err_htp(htf.headOpen);
  err_htp('<LINK REL=STYLESHEET HREF=/OA_HTML/US/POSSTYLE.css>');

  err_htp(htf.headClose);
  err_htp('<body bgcolor=#cccccc >');

  err_htp('<B><font class=datablack>' || v_messageText1 || '</font></B>');

END show_ok_page;

PROCEDURE print_edit_header IS

  v_messageText1     VARCHAR2(2000);
  v_messageText2     VARCHAR2(2000);
  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_col		     NUMBER;
  l_current_row      NUMBER;
  l_where_clause     VARCHAR2(2000) := 'SESSION_ID = ' || to_char(l_session_id);

BEGIN

   fnd_client_info.set_org_context(l_org_id);
   fnd_global.apps_initialize(l_user_id, l_responsibility_id, 178);

   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

   v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_HEADER_HT1');
   v_messageText2 := fnd_message.get_string('ICX', 'ICX_POS_REQUIRED_FIELD');

   htp.p('<!-- This row contains the help text -->');
   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         v_messageText1 ||
         '<IMG SRC="/OA_MEDIA/FNDIREQD.gif" border=no align=top>' ||
         v_messageText2 ||
         '</font></td>');
   htp.p('</tr>');
   htp.p('</table>');


   ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ASN_HEADERS',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  l_responsibility_id,
                          p_user_id                 =>  l_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

   l_attribute_index := ak_query_pkg.g_items_table.FIRST;
   l_result_index    := ak_query_pkg.g_results_table.FIRST;

   htp.p('<table width=100% cellpadding=2 cellspacing=0 border=0>');

   htp.p('<tr bgcolor=#cccccc>');

   l_current_col := 0;
   l_col := 0;

   WHILE (l_attribute_index IS NOT NULL) LOOP

     l_current_col := l_current_col + 1;

    IF (item_style(l_attribute_index) = 'HIDDEN') THEN

       hidden_label(l_attribute_index);
       hidden_field(l_attribute_index,l_result_index, l_current_col);

    ELSIF item_displayed(l_attribute_index)  THEN
        IF (item_style(l_attribute_index) = 'TEXT') THEN
          IF item_updateable(l_attribute_index) THEN

             single_row_label(l_attribute_index);
             updateable(l_attribute_index, l_result_index, l_current_col);

          ELSE

             single_row_label(l_attribute_index);
             non_updateable(l_attribute_index, l_result_index, l_current_col);

          END IF;

          l_col := l_col + 1;

        ELSIF (item_style(l_attribute_index) = 'IMAGE') THEN
             IF (item_code(l_attribute_index) = 'POS_ASBN') AND
                (FND_FUNCTION.TEST('ICX_DISABLE_ASBN'))  THEN

                l_col := l_col + 1;

                single_row_label(l_attribute_index);
    		image(l_attribute_index,'"javascript:top.ASBNClicked()"');
                htp.p('<td width=23></td>');

            END IF;
            l_current_col := l_current_col -1;
         END IF;
      END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

    if ((l_col mod 3) = 0) THEN
         htp.p('</tr>');
         htp.p('<tr bgcolor=#cccccc>');
    end if;

   END LOOP;

   htp.p('</tr>');
   htp.p('</table>');

END print_edit_header;

PROCEDURE print_edit_shipments IS
  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_current_row      NUMBER;
  l_wip_row          NUMBER;
  l_where_clause     VARCHAR2(2000) := 'SESSION_ID = ' || to_char(l_session_id);

BEGIN

  fnd_client_info.set_org_context(l_org_id);

  ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ASN_SHIPMENTS',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  l_responsibility_id,
                          p_user_id                 =>  l_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

  l_attribute_index := ak_query_pkg.g_items_table.FIRST;


  htp.p('<table width=96% bgcolor=#999999 cellpadding=2 cellspacing=0 border=0>');
  htp.p('<tr><td>');

  htp.p('<table align=center bgcolor=#999999 cellpadding=2 cellspacing=1 border=0>');

  htp.p('<input name="POS_SUBMIT" type="HIDDEN" value="SUBMIT">');

/* ---- Print the table heading --- */

  htp.p('<tr>');

  WHILE (l_attribute_index IS NOT NULL) LOOP

    IF (item_style(l_attribute_index) = 'HIDDEN') THEN

       hidden_label(l_attribute_index);

    ELSIF item_displayed(l_attribute_index)  THEN

       multi_row_label(l_attribute_index);

    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

  END LOOP;

  htp.p('</tr>');

/* ----- end print table heading ----*/


/* ----- print contents -----------*/

  IF ak_query_pkg.g_results_table.count > 0 THEN

    l_result_index := ak_query_pkg.g_results_table.FIRST;

    l_current_row := 0;
    l_wip_row := 0;

    WHILE (l_result_index IS NOT NULL) LOOP

      l_current_row := l_current_row + 1;

      if ((l_current_row mod 2) = 0) THEN
         htp.p('<tr BGCOLOR=''#ffffff'' >');
      else
        htp.p('<tr BGCOLOR=''#99ccff'' >');
      end if;

      l_attribute_index := ak_query_pkg.g_items_table.FIRST;

      l_current_col := 0;

      WHILE (l_attribute_index IS NOT NULL) LOOP

        l_current_col := l_current_col + 1;

        IF (item_style(l_attribute_index) = 'HIDDEN') THEN

           hidden_field(l_attribute_index,l_result_index, l_current_col);

        ELSE
         IF item_displayed(l_attribute_index)  THEN
           IF (item_style(l_attribute_index) = 'TEXT') THEN
              IF item_updateable(l_attribute_index) THEN

                IF item_code(l_attribute_index) = 'POS_ASN_WIP_JOB' AND
                   substrb(get_result_value(l_result_index, l_current_col), 1, 1) <> ' ' THEN

		  non_updateable(l_attribute_index, l_result_index, l_current_col);

                ELSE

                  IF item_code(l_attribute_index) = 'POS_ASN_WIP_JOB' THEN
                     l_wip_row := l_wip_row + 1;
                  END IF;

                  updateable(l_attribute_index,l_result_index,
                             l_current_col, l_current_row, l_wip_row);
                END IF;

              ELSE

                 non_updateable(l_attribute_index, l_result_index, l_current_col);

              END IF;
           ELSIF (item_style(l_attribute_index) = 'CHECKBOX') THEN
               l_current_col := l_current_col -1;
               htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                      '<B><font class=datablack>' ||
                      '<input type="checkbox"  name="' ||
                        item_code(l_attribute_index) || '"' ||
                      ' value="' || to_char(l_current_row) ||
                      '" ></font></B>' ||
                      '</td>');

           ELSIF (item_style(l_attribute_index) = 'IMAGE') THEN

                l_current_col := l_current_col -1;
    		image(l_attribute_index,'"javascript:details(' ||
                       to_char(l_current_row-1) || ')"');

          END IF;
         END IF;
        END IF;

          l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

        END LOOP;

        htp.p('</tr>');

        l_result_index := ak_query_pkg.g_results_table.NEXT(l_result_index);

    END LOOP;

  END IF;

  htp.p('</table>');
  htp.p('</td></tr></table>');

END print_edit_shipments;

PROCEDURE print_simple_head_err_page IS
v_messageText1 VARCHAR2(2000);
BEGIN

 but3 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_OK_BUT');

 IF ship_date_error OR receipt_date_error THEN
    v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_DATE_FORMAT') ||
                      l_date_format;
 END IF;

 err_htp('<font class=datablack BGCOLOR=#ffffff>' || v_messageText1 || '</font>');

END print_simple_head_err_page;

PROCEDURE print_error_page IS
l_count NUMBER;
v_messageText1 VARCHAR2(2000);
v_messageText2 VARCHAR2(2000);
BEGIN

  v_messageText1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_HEADER_E1');
  v_messageText2 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_LINES_E1');

  l_count := 0;

  FOR c_rec in c_header_err LOOP

    if l_count = 0 then
      err_htp('<B><font class=datablack>' || v_messageText1 || '</font></B>');
      err_htp('<table align=center bgcolor=#999999 cellpadding=2 cellspacing=1 border=0>');
    end if;

    l_count := l_count + 1;
    if ((l_count mod 2) = 0) THEN
       err_htp('<tr BGCOLOR=#ffffff>');
    else
      err_htp('<tr BGCOLOR=#99ccff>');
    end if;

    err_htp('<td>');
    err_htp(c_rec.error_message);
    err_htp('</td></tr>');

  END LOOP;

  err_htp('</table>');

  l_count := 0;

  FOR c_rec in c_shipment_err LOOP

    if l_count = 0 then
      err_htp('<B><font class=datablack>' || v_messageText2 || '</font></B>');
      err_htp('<table align=center bgcolor=#999999 cellpadding=2 cellspacing=1 border=0>');
    end if;

    l_count := l_count + 1;
    if ((l_count mod 2) = 0) THEN
       err_htp('<tr BGCOLOR=#ffffff>');
    else
      err_htp('<tr BGCOLOR=#99ccff>');
    end if;

    err_htp('<td>');
    err_htp(c_rec.error_seq);
    err_htp('</td>');
    err_htp('<td>');
    err_htp(c_rec.error_message);
    err_htp('</td>');
    err_htp('</tr>');

  END LOOP;

  err_htp('</table>');

END print_error_page;

PROCEDURE create_rcv_header IS
BEGIN

     SELECT RCV_INTERFACE_GROUPS_S.NEXTVAL INTO l_request_id from dual;

     SELECT RCV_HEADERS_INTERFACE_S.NEXTVAL INTO l_header_id from dual;

     insert into rcv_headers_interface
       (HEADER_INTERFACE_ID		,
 	GROUP_ID			,
 	PROCESSING_STATUS_CODE 	 	,
        PROCESSING_REQUEST_ID           ,
 	RECEIPT_SOURCE_CODE		,
 	TRANSACTION_TYPE		,
 	LAST_UPDATE_DATE		,
 	LAST_UPDATED_BY			,
 	LAST_UPDATE_LOGIN		,
 	CREATION_DATE			,
 	CREATED_BY			,
 	LOCATION_ID			,
 	SHIP_TO_ORGANIZATION_ID		,
 	VENDOR_ID			,
 	VENDOR_SITE_ID			,
 	SHIPPED_DATE			,
 	ASN_TYPE			,
 	SHIPMENT_NUM			,
 	EXPECTED_RECEIPT_DATE		,
 	PACKING_SLIP			,
 	WAYBILL_AIRBILL_NUM		,
 	BILL_OF_LADING			,
 	FREIGHT_CARRIER_CODE		,
 	FREIGHT_TERMS			,
 	NUM_OF_CONTAINERS		,
 	COMMENTS			,
 	CARRIER_METHOD			,
 	CARRIER_EQUIPMENT		,
 	FREIGHT_BILL_NUMBER		,
 	GROSS_WEIGHT			,
 	GROSS_WEIGHT_UOM_CODE		,
 	NET_WEIGHT			,
 	NET_WEIGHT_UOM_CODE		,
 	TAR_WEIGHT			,
 	TAR_WEIGHT_UOM_CODE		,
 	PACKAGING_CODE			,
 	SPECIAL_HANDLING_CODE		,
 	INVOICE_NUM			,
 	INVOICE_DATE			,
 	TOTAL_INVOICE_AMOUNT		,
 	FREIGHT_AMOUNT			,
 	TAX_NAME			,
 	TAX_AMOUNT			,
 	CURRENCY_CODE			,
 	CONVERSION_RATE_TYPE		,
 	CONVERSION_RATE			,
 	CONVERSION_RATE_DATE            ,
        VALIDATION_FLAG
       )
      select
        l_header_id			,
 	l_request_id			,
 	'RUNNING'			,
        l_request_id			,
 	'VENDOR'			,
 	'NEW'				,
 	LAST_UPDATE_DATE		,
 	LAST_UPDATED_BY			,
 	LAST_UPDATE_LOGIN		,
 	CREATION_DATE			,
 	CREATED_BY			,
 	SHIP_TO_LOCATION_ID		,
 	SHIP_TO_ORGANIZATION_ID		,
 	VENDOR_ID			,
 	VENDOR_SITE_ID			,
 	SHIP_DATE			,
 	decode(INVOICE_NUM, null, 'ASN', 'ASBN'),
 	SHIPMENT_NUM			,
 	EXPECTED_RECEIPT_DATE		,
 	PACKING_SLIP			,
 	WAYBILL_AIRBILL_NUM		,
 	BILL_OF_LADING			,
 	FREIGHT_CARRIER_CODE		,
 	FREIGHT_TERMS			,
 	NUM_OF_CONTAINERS		,
 	COMMENTS			,
 	CARRIER_METHOD			,
 	CARRIER_EQUIPMENT		,
 	FREIGHT_BILL_NUMBER		,
 	GROSS_WEIGHT			,
 	GROSS_WEIGHT_UOM_CODE		,
 	NET_WEIGHT			,
 	NET_WEIGHT_UOM_CODE		,
 	TAR_WEIGHT			,
 	TAR_WEIGHT_UOM_CODE		,
 	PACKAGING_CODE			,
 	SPECIAL_HANDLING_CODE		,
 	INVOICE_NUM			,
 	INVOICE_DATE			,
 	TOTAL_INVOICE_AMOUNT		,
 	FREIGHT_AMOUNT			,
 	null 				, /* TAX_NAME */
 	null 				, /* TAX_AMOUNT */
 	CURRENCY_CODE			,
 	CURRENCY_CONVERSION_TYPE	,
 	CURRENCY_CONVERSION_RATE	,
 	CURRENCY_CONVERSION_DATE	,
        'Y'
       from pos_asn_shop_cart_headers
       where session_id = l_session_id;

END create_rcv_header;

PROCEDURE create_rcv_transaction IS
x_deliver_to_location_id NUMBER;
BEGIN

   FOR c_rec in c_lines LOOP

        select RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL into l_line_id from dual;

        insert into rcv_transactions_interface
         ( INTERFACE_TRANSACTION_ID	,
           HEADER_INTERFACE_ID		,
           GROUP_ID			,
           TRANSACTION_TYPE		,
           TRANSACTION_DATE		,
           PROCESSING_STATUS_CODE	,
           PROCESSING_MODE_CODE		,
           TRANSACTION_STATUS_CODE	,
           AUTO_TRANSACT_CODE		,
           RECEIPT_SOURCE_CODE		,
           SOURCE_DOCUMENT_CODE		,
           PO_HEADER_ID			,
           PO_LINE_ID			,
           PO_LINE_LOCATION_ID		,
           QUANTITY			,
           UNIT_OF_MEASURE		,
           UOM_CODE			,
           LAST_UPDATE_DATE		,
           LAST_UPDATED_BY		,
           LAST_UPDATE_LOGIN		,
           CREATION_DATE		,
           CREATED_BY			,
           ITEM_ID			,
           EXPECTED_RECEIPT_DATE	,
           COMMENTS			,
           WAYBILL_AIRBILL_NUM		,
           BARCODE_LABEL		,
           BILL_OF_LADING		,
           CONTAINER_NUM		,
           COUNTRY_OF_ORIGIN_CODE	,
           VENDOR_CUM_SHIPPED_QTY	,
           FREIGHT_CARRIER_CODE		,
           VENDOR_LOT_NUM		,
           TRUCK_NUM			,
           NUM_OF_CONTAINERS		,
           PACKING_SLIP			,
           REASON_ID			,
           ACTUAL_COST			,
           TRANSFER_COST		,
           TRANSPORTATION_COST		,
           RMA_REFERENCE		,
           VALIDATION_FLAG		,
           WIP_ENTITY_ID		,
           WIP_LINE_ID			,
           WIP_OPERATION_SEQ_NUM	,
           PO_DISTRIBUTION_ID           ,
           QUANTITY_INVOICED
         )
        values
         ( l_line_id			,
           c_rec.HEADER_ID		,
           c_rec.GROUP_ID		,
           c_rec.TRANSACTION_TYPE	,
           c_rec.TRANSACTION_DATE	,
           c_rec.PROCESSING_STATUS_CODE	,
           c_rec.PROCESSING_MODE_CODE	,
           c_rec.TRANSACTION_STATUS_CODE,
           c_rec.AUTO_TRANSACT_CODE	,
           c_rec.RECEIPT_SOURCE_CODE	,
           c_rec.SOURCE_DOCUMENT_CODE	,
           c_rec.PO_HEADER_ID		,
           c_rec.PO_LINE_ID		,
           c_rec.PO_LINE_LOCATION_ID	,
           c_rec.QUANTITY		,
           c_rec.UNIT_OF_MEASURE	,
           c_rec.UOM_CODE		,
           c_rec.LAST_UPDATE_DATE	,
           c_rec.LAST_UPDATED_BY	,
           c_rec.LAST_UPDATE_LOGIN	,
           c_rec.CREATION_DATE		,
           c_rec.CREATED_BY		,
           c_rec.ITEM_ID		,
           c_rec.EXPECTED_RECEIPT_DATE	,
           c_rec.COMMENTS		,
           c_rec.WAYBILL_AIRBILL_NUM	,
           c_rec.BARCODE_LABEL		,
           c_rec.BILL_OF_LADING		,
           c_rec.CONTAINER_NUM		,
           c_rec.COUNTRY_OF_ORIGIN_CODE	,
           c_rec.VENDOR_CUM_SHIPPED_QTY	,
           c_rec.FREIGHT_CARRIER_CODE	,
           c_rec.VENDOR_LOT_NUM		,
           c_rec.TRUCK_NUM		,
           c_rec.NUM_OF_CONTAINERS	,
           c_rec.PACKING_SLIP		,
           c_rec.REASON_ID		,
           c_rec.ACTUAL_COST		,
           c_rec.TRANSFER_COST		,
           c_rec.TRANSPORTATION_COST	,
           c_rec.RMA_REFERENCE		,
           c_rec.VALIDATION_FLAG	,
	   c_rec.WIP_ENTITY_ID		,
           c_rec.WIP_LINE_ID		,
           c_rec.WIP_OPERATION_SEQ_NUM	,
           c_rec.PO_DISTRIBUTION_ID     ,
           c_rec.QUANTITY_INVOICED
        );

     IF c_rec.WIP_ENTITY_ID is not null THEN

        select deliver_to_location_id
        into   x_deliver_to_location_id
        from   po_distributions_all
        where  po_distribution_id =  c_rec.PO_DISTRIBUTION_ID;

        update rcv_transactions_interface
        set    deliver_to_location_id = x_deliver_to_location_id
        where  INTERFACE_TRANSACTION_ID = l_line_id;

        IF x_deliver_to_location_id is null THEN

           update rcv_transactions_interface
           set    deliver_to_location_id =
                 (select ship_to_location_id
                  from po_line_locations_all
                  where line_location_id = c_rec.PO_LINE_LOCATION_ID)
           where  INTERFACE_TRANSACTION_ID = l_line_id;

        END IF;

     END IF;

     update pos_asn_shop_cart_details asnd
      set asnd.INTERFACE_TRANSACTION_ID = l_line_id,
          asnd.HEADER_INTERFACE_ID = c_rec.HEADER_ID
     where asnd.session_id        = l_session_id and
           asnd.asn_line_id       = c_rec.asn_line_id and
           asnd.asn_line_split_id = c_rec.asn_line_split_id;

     -- Bug 1345768. Document_line_num is required by the pre-processor but is
     -- not available from pos_asn_shop_cart_details.
     update rcv_transactions_interface
     set DOCUMENT_LINE_NUM =
	 (select LINE_NUM
	 from po_lines_all
	 where po_line_id = c_rec.PO_LINE_ID)
       where INTERFACE_TRANSACTION_ID = l_line_id;


     update rcv_transactions_interface
     set DOCUMENT_SHIPMENT_LINE_NUM =
	 (select SHIPMENT_NUM
	 from po_line_locations_all
	 where line_location_id = c_rec.PO_LINE_LOCATION_ID)
       where INTERFACE_TRANSACTION_ID = l_line_id;

     update rcv_transactions_interface
     set po_release_id =
	 (select po_release_id
	 from po_line_locations_all
	 where line_location_id = c_rec.PO_LINE_LOCATION_ID)
     where INTERFACE_TRANSACTION_ID = l_line_id;

     -- Dest subinventory is required by the pre-processor but is
     -- not available from pos_asn_shop_cart_details.
     update rcv_transactions_interface
     set SUBINVENTORY =
	 (select destination_subinventory
	 from po_distributions_all
	 where  po_distribution_id =  c_rec.PO_DISTRIBUTION_ID)
     where INTERFACE_TRANSACTION_ID = l_line_id;
  END LOOP;

END create_rcv_transaction;

PROCEDURE call_wip_api IS
BEGIN

  FOR c_rec in c_wip LOOP
  /* the wip workflow needs to be called only for wip jobs */
   IF c_rec.p_wip_entity_id is null THEN
    null;
   ELSE
    wip_osp_shp_i_wf.StartWFProcToAnotherSupplier
       ( c_rec.p_po_distribution_id  		,
         c_rec.p_shipped_qty         		,
         c_rec.p_shipped_uom         		,
         c_rec.p_shipped_date        		,
         c_rec.p_expected_receipt_date 		,
         c_rec.p_packing_slip        		,
         c_rec.p_airbill_waybill     		,
         c_rec.p_bill_of_lading      		,
         c_rec.p_packaging_code      		,
         c_rec.p_num_of_container    		,
         c_rec.p_gross_weight        		,
         c_rec.p_gross_weight_uom    		,
         c_rec.p_net_weight          		,
         c_rec.p_net_weight_uom      		,
         c_rec.p_tar_weight          		,
         c_rec.p_tar_weight_uom      		,
         null, 						/* c_rec.p_hazard_class */
         null, 						/* c_rec.p_hazard_code  */
         null, 						/* c_rec.p_hazard_desc  */
         c_rec.p_special_handling_code 		,
         c_rec.p_freight_carrier     		,
         c_rec.p_freight_carrier_terms 		,
         c_rec.p_carrier_equip       		,
         c_rec.p_carrier_method      		,
         c_rec.p_freight_bill_num    		,
         null, 						/*c_rec.p_receipt_num     */
         null  						/* c_rec.p_ussgl_txn_code */
       );
   END IF;
  END LOOP;

END call_wip_api;

FUNCTION VALID_ASN RETURN BOOLEAN IS
   error_count number;
BEGIN

  fnd_client_info.set_org_context(l_org_id);

  rcv_shipment_object_sv.create_object(l_request_id);

  select count(*) into error_count from
    po_interface_errors where Interface_Header_ID = l_header_id;

  IF error_count > 0 then
     RETURN FALSE;
  END IF;

  RETURN TRUE;

END valid_asn;

PROCEDURE submit IS
BEGIN

     but1 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_NEW_BUT');
     but2 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_EXIT_BUT');
     but3 := fnd_message.get_string('ICX', 'ICX_POS_ASN_EDIT_OK_BUT');

     create_rcv_header;
     create_rcv_transaction;

     IF valid_asn THEN

        call_wip_api;

        buyer_notify;

        delete from pos_asn_shop_cart_headers where session_id = l_session_id;
        delete from pos_asn_shop_cart_details where session_id = l_session_id;

-- The pre-processor has already created the header record, also we do not want the
-- pre-processor to be run again, so delete the header in the interface. If there is
-- no header record in the interface table, the pre-processor is not run. The status
-- need to be PENDING for trx procss to run.
       /*
        * dreddy - instead of deleting from the header set the processing status_code
        * to success so that the pre-processor does not run again. This is because the
        * the data in this table is needed by the receiving transaction processor.
        */
       --  delete from rcv_headers_interface where header_interface_id = l_header_id;
        update rcv_headers_interface set
               validation_flag = 'N',
               processing_status_code = 'SUCCESS'
        where header_interface_id = l_header_id;

        update rcv_transactions_interface set
               PROCESSING_STATUS_CODE = 'PENDING',
               TRANSACTION_STATUS_CODE = 'PENDING'
        where header_interface_id = l_header_id;

        COMMIT;

        show_ok_page;
        sub_state := 'OK';

     ELSE

       show_error_page;
       sub_state := 'ERROR';

       ROLLBACK;

     END IF;

END submit;

PROCEDURE update_shipments(pos_quantity_shipped      IN t_text_table DEFAULT g_dummy,
                           pos_select                IN t_text_table DEFAULT g_dummy,
                           pos_unit_of_measure       IN t_text_table DEFAULT g_dummy,
                           pos_comments              IN t_text_table DEFAULT g_dummy,
                           pos_asn_line_id           IN t_text_table DEFAULT g_dummy,
                           pos_asn_line_split_id     IN t_text_table DEFAULT g_dummy,
                           pos_po_line_location_id   IN t_text_table DEFAULT g_dummy,
                           pos_po_distribution_id    IN t_text_table DEFAULT g_dummy,
                           pos_asn_wip_job           IN t_text_table DEFAULT g_dummy,
                           pos_wip_entity_id         IN t_text_table DEFAULT g_dummy,
                           pos_wip_line_id           IN t_text_table DEFAULT g_dummy,
                           pos_wip_operation_seq_num IN t_text_table DEFAULT g_dummy,
                           pos_item_id               IN t_text_table DEFAULT g_dummy,
                           pos_uom_class	     IN t_text_table DEFAULT g_dummy,
                           pos_po_header_id          IN t_text_table DEFAULT g_dummy,
                           pos_submit                IN VARCHAR2 DEFAULT NULL) IS
d_count number;
BEGIN

-- Update all the info ---

  FOR l_counter IN 1..pos_asn_line_id.count LOOP

   update pos_asn_shop_cart_details  set
      quantity_shipped       = fnd_number.canonical_to_number(nvl(rtrim(ltrim(pos_quantity_shipped(l_counter))), 0)),
      unit_of_measure        = pos_unit_of_measure(l_counter),
      comments               = pos_comments(l_counter),
      wip_job_info           = pos_osp_job.get_wip_info(pos_po_distribution_id(l_counter)),
      po_distribution_id     = pos_po_distribution_id(l_counter),
      wip_entity_id          = pos_wip_entity_id(l_counter),
      wip_operation_seq_num  = pos_wip_operation_seq_num(l_counter),
      wip_line_id            = pos_wip_line_id(l_counter),
      item_id                = nvl(pos_item_id(l_counter), item_id)
   where session_id  = l_session_id and
         asn_line_id = pos_asn_line_id(l_counter) and
         asn_line_split_id = pos_asn_line_split_id(l_counter);

  END LOOP;

-- Delete if any --

  IF pos_submit = 'DELETE'  AND pos_select.count > 0 THEN

      FOR l_counter IN 1..pos_select.count LOOP

        delete from pos_asn_shop_cart_details
         where session_id = l_session_id and
               asn_line_id = pos_asn_line_id(to_number(pos_select(l_counter))) and
               asn_line_split_id = pos_asn_line_split_id(to_number(pos_select(l_counter)));

      END LOOP;

      select count(*)
      into d_count
      from pos_asn_shop_cart_details
      where session_id = l_session_id;

      IF d_count = 0 THEN
         delete from pos_asn_shop_cart_headers where session_id = l_session_id;
      END IF;

  END IF;

-- Split the one --

  IF pos_submit = 'EXPLODE' AND pos_select.count > 0 THEN

    FOR l_counter IN 1..pos_select.count LOOP

       update  pos_asn_shop_cart_details set
             asn_line_split_id = asn_line_split_id + 1
       where session_id = l_session_id and
             asn_line_id = pos_asn_line_id(to_number(pos_select(l_counter))) and
             asn_line_split_id >  pos_asn_line_split_id(to_number(pos_select(l_counter)));


       insert into pos_asn_shop_cart_details
        (session_id,
         asn_line_id,
         asn_line_split_id,
         po_header_id,
         po_line_id,
         po_line_location_id,
         ship_to_organization_id,
         last_update_date,
         last_updated_by,
         unit_of_measure,
         item_id )
        select
         session_id,
         asn_line_id,
         asn_line_split_id + 1,
         po_header_id,
         po_line_id,
         po_line_location_id,
         ship_to_organization_id,
         last_update_date,
         last_updated_by,
         unit_of_measure,
         item_id
        from pos_asn_shop_cart_details
        where session_id = l_session_id and
              asn_line_id = pos_asn_line_id(to_number(pos_select(l_counter))) and
              asn_line_split_id = pos_asn_line_split_id(to_number(pos_select(l_counter)));

    END LOOP;

  END IF;

  COMMIT;

  IF pos_submit = 'SUBMIT' THEN

     submit;

  END IF;

  IF pos_submit = 'NEXT' THEN

--   Show review page
     pos_asn_review_pkg.review_page;

  ELSIF substr(pos_submit, 1, 4) = 'BACK' THEN

--   Show search page
     pos_asn_search_pkg.search_page(p_query     => 'N',
                                    p_start_row => to_number(substr(pos_submit, 5,
                                                             length(pos_submit)-4))
                                    );
  ELSE

--   Repaint
    show_edit_shipments;

  END IF;

END update_shipments;

PROCEDURE update_header  ( pos_asn_shipment_num       IN VARCHAR2 DEFAULT null,
                           pos_bill_of_lading         IN VARCHAR2 DEFAULT null,
                           pos_waybill_airbill_num    IN VARCHAR2 DEFAULT null,
                           pos_ship_date              IN VARCHAR2 DEFAULT null,
                           pos_expected_receipt_date  IN VARCHAR2 DEFAULT null,
                           pos_num_of_containers      IN VARCHAR2 DEFAULT null,
                           pos_comments               IN VARCHAR2 DEFAULT null,
                           pos_packing_slip           IN VARCHAR2 DEFAULT null,
                           pos_freight_carrier	      IN VARCHAR2 DEFAULT null,
                           pos_freight_carrier_code   IN VARCHAR2 DEFAULT null,
                           pos_freight_term           IN VARCHAR2 DEFAULT null,
                           pos_freight_term_code      IN VARCHAR2 DEFAULT null,
                           pos_freight_bill_num       IN VARCHAR2 DEFAULT null,
                           pos_carrier_method         IN VARCHAR2 DEFAULT null,
                           pos_carrier_equipment      IN VARCHAR2 DEFAULT null,
			   pos_gross_weight           IN VARCHAR2 DEFAULT null,
			   pos_gross_weight_uom       IN VARCHAR2 DEFAULT null,
			   pos_gross_weight_uom_code  IN VARCHAR2 DEFAULT null,
			   pos_net_weight             IN VARCHAR2 DEFAULT null,
			   pos_net_weight_uom         IN VARCHAR2 DEFAULT null,
			   pos_net_weight_uom_code    IN VARCHAR2 DEFAULT null,
			   pos_tar_weight             IN VARCHAR2 DEFAULT null,
			   pos_tar_weight_uom         IN VARCHAR2 DEFAULT null,
			   pos_tar_weight_uom_code    IN VARCHAR2 DEFAULT null,
			   pos_packaging_code         IN VARCHAR2 DEFAULT null,
			   pos_special_handling_code  IN VARCHAR2 DEFAULT null,
                           pos_ship_to_organization_id IN VARCHAR2 DEFAULT null ) IS
l_ship_date varchar2(200);
l_receipt_date varchar2(200);
BEGIN

   sub_state := 'SUBMIT';

-- Need to validate ship date, so as not to fire pre-processor if there is error,
-- prevent submit of shipments forms
   begin
        x_ship_date    := pos_ship_date;
        l_ship_date    := to_date(pos_ship_date, l_date_format);
      EXCEPTION
        WHEN OTHERS THEN
         sub_state := 'ERROR';
         header_error := true;
         ship_date_error := true;
   end;

-- Need to validate expected receipt date,so as not to fire pre-processor
-- if there is error, prevent submit of shipments forms
   begin
        x_receipt_date := pos_expected_receipt_date;
        l_receipt_date := to_date(pos_expected_receipt_date, l_date_format);
      EXCEPTION
        WHEN OTHERS THEN
         sub_state := 'ERROR';
         header_error := true;
         receipt_date_error := true;
   end;

   update pos_asn_shop_cart_headers  set
      asn_type                 = 'NEW',
      shipment_num             = pos_asn_shipment_num,
      bill_of_lading           = pos_bill_of_lading,
      waybill_airbill_num      = pos_waybill_airbill_num,
      ship_date                = l_ship_date,
      expected_receipt_date    = l_receipt_date,
      num_of_containers        = fnd_number.canonical_to_number(rtrim(ltrim(pos_num_of_containers))),
      comments                 = pos_comments,
      packing_slip             = pos_packing_slip,
      freight_carrier_code     = pos_freight_carrier_code,
      freight_terms            = pos_freight_term_code,
      freight_bill_number      = pos_freight_bill_num,
      carrier_method           = pos_carrier_method,
      carrier_equipment        = pos_carrier_equipment,
      gross_weight             = fnd_number.canonical_to_number(rtrim(ltrim(pos_gross_weight))),
      gross_weight_uom_code    = pos_gross_weight_uom_code,
      net_weight               = fnd_number.canonical_to_number(rtrim(ltrim(pos_net_weight))),
      net_weight_uom_code      = pos_net_weight_uom_code,
      tar_weight               = fnd_number.canonical_to_number(rtrim(ltrim(pos_tar_weight))),
      tar_weight_uom_code      = pos_tar_weight_uom_code,
      packaging_code           = pos_packaging_code,
      special_handling_code    = pos_special_handling_code
   where session_id = l_session_id;

  COMMIT;

  IF sub_state = 'ERROR' then
    show_error_page;
  END IF;
  show_edit_header;

END update_header;

function get_result_value(p_index in number, p_col in number) return varchar2 is
    sql_statement  VARCHAR2(300);
    l_cursor       INTEGER;
    l_execute      INTEGER;
    l_result       VARCHAR2(2000);
BEGIN

  IF ak_query_pkg.g_results_table.count > 0 THEN

      sql_statement := 'begin ' ||
                       ':l_result := ak_query_pkg.g_results_table(:p_index).value' ||
                                             to_char(p_col) || '; ' ||
                       ' end;';

      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, sql_statement, dbms_sql.v7);
      dbms_sql.bind_variable(l_cursor, 'l_result', l_result, 2000);
      dbms_sql.bind_variable(l_cursor, 'p_index', p_index);

      l_execute := dbms_sql.execute(l_cursor);
      dbms_sql.variable_value(l_cursor, 'l_result', l_result);
      dbms_sql.close_cursor(l_cursor);
      return l_result;

  ELSE

      return null;

  END IF;

END get_result_value;


/* Initialize the session info only once per session */
BEGIN

  IF NOT set_session_info THEN
    RETURN;
  END IF;

END pos_asn;

/
