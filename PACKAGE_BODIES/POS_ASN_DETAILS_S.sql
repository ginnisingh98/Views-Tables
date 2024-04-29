--------------------------------------------------------
--  DDL for Package Body POS_ASN_DETAILS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN_DETAILS_S" AS
/* $Header: POSASNDB.pls 115.6 2000/10/12 16:40:48 pkm ship     $ */


/* set_session_info
 * ----------------
 * This is a generic function to get various icx security attributes.  These
 * are assigned into global variables and used throughout this package.
 */
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

  fnd_client_info.set_org_context(l_org_id);

  RETURN TRUE;
END;


/* item_halign
 * -----------
 * Generic utility to return the horizontal alignment of the attribute
 */
FUNCTION item_halign(l_index in number) RETURN VARCHAR2 IS
BEGIN
   RETURN ak_query_pkg.g_items_table(l_index).horizontal_alignment;
END;


/* item_valign
 * -----------
 * Generic utility to return the vertical alignment of the attribute
 */
FUNCTION item_valign(l_index in number) RETURN VARCHAR2 IS
BEGIN
   RETURN ak_query_pkg.g_items_table(l_index).vertical_alignment;
END;


/* item_name
 * ---------
 * Generic utility to retrieve the attribute label
 */
FUNCTION item_name(l_index in number) RETURN VARCHAR2 IS
BEGIN
   RETURN ak_query_pkg.g_items_table(l_index).attribute_label_long;
END;


/* item_code
 * ---------
 * Generic utility to retrieve the attribute code
 */
FUNCTION item_code(l_index in number) RETURN VARCHAR2 IS
BEGIN
   RETURN ak_query_pkg.g_items_table(l_index).attribute_code;
END;


/* item_style
 * ----------
 */
FUNCTION item_style(l_index in number) RETURN VARCHAR2 IS
BEGIN
  RETURN ak_query_pkg.g_items_table(l_index).item_style;
END;


/* item_displayed
 * --------------
 */
FUNCTION item_displayed(l_index in number) RETURN BOOLEAN IS
BEGIN
  RETURN (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y');
END;


/* item_updateable
 * ---------------
 */
FUNCTION item_updateable(l_index in number) RETURN BOOLEAN IS
BEGIN
 RETURN (ak_query_pkg.g_items_table(l_index).update_flag = 'Y');
END;


/* item_sequence
 * -------------
 */
FUNCTION item_sequence(l_index in number) RETURN NUMBER IS
BEGIN
 RETURN ak_query_pkg.g_items_table(l_index).display_sequence;
END;


/* item_maxlength
 * --------------
 */
FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' maxlength=' ||
         to_char(ak_query_pkg.g_items_table(l_index).attribute_value_length);

END item_maxlength;


/* item_size
 * ---------
 */
FUNCTION item_size (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' size='  || to_char(ak_query_pkg.g_items_table(l_index).display_value_length);

END item_size;


/* item_lov
 * --------
 */
FUNCTION item_lov(l_index in number) RETURN VARCHAR2 IS
BEGIN

  IF ((ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL) AND
      (ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL))
  THEN

    return '<A HREF="javascript:call_LOV('''||
             item_code(l_index) || ''')"' ||
             '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 ' ||
             'HEIGHT=21 border=no align=absmiddle></A>';
  ELSE
    return '';
  END IF;

END item_lov;

FUNCTION ASBN RETURN BOOLEAN IS
invoice_num varchar2(30);
BEGIN

 SELECT invoice_num
 INTO   invoice_num
 FROM   pos_asn_shop_cart_headers
 WHERE  session_id = l_session_id;

 IF invoice_num is null THEN
    return false;
 ELSE
    return true;
 END IF;

END ASBN;



/* show_details
 * ------------
 */
PROCEDURE show_details(p_asn_line_id VARCHAR2,
                       p_asn_line_split_id VARCHAR2,
                       p_quantity VARCHAR2 DEFAULT NULL,
                       p_unit_of_measure VARCHAR2 DEFAULT NULL) IS
BEGIN

  -- set global variables that i need for invoice details region.
  -- i need invoiced quantity and uom.
  g_quantity := p_quantity;
  g_unit_of_measure := p_unit_of_measure;

  htp.htmlOpen;
  htp.headOpen;

  htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

  js.scriptOpen;
  icx_util.LOVscript;

  htp.p('

  function closeWindow(p)
  {
    if (p != "")
    {
      top.close();
    }
  }

  ');


  htp.p('

  function call_LOV(c_attribute_code)
  {
    var c_js_where_clause = "";

    if (c_attribute_code == "POS_FREIGHT_CARRIER")
    {
       c_js_where_clause = "ORGANIZATION_ID=" +
             document.pos_asn_details.POS_SHIP_TO_ORGANIZATION_ID.value;
    }

    c_js_where_clause = escape(c_js_where_clause, 1);

    LOV("178", c_attribute_code, "178", "POS_ASN_DETAILS_SHIPMENTS_R",
        "pos_asn_details", "content", "", c_js_where_clause);
  }

  ');


  js.scriptClose;

  htp.headClose;

  htp.bodyOpen(null, 'onLoad="javascript:closeWindow(' || '''' ||
               g_flag  || '''' || ')"' ||
               ' bgcolor=#cccccc link=blue vlink=blue alink=#ff0000');


  htp.p('<form name="pos_asn_details" action="' || l_script_name ||
        '/pos_asn_details_s.update_details" target="content" method=GET">');


  set_asn_ids(p_asn_line_id, p_asn_line_split_id);

  htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

  htp.p('<tr bgcolor=#cccccc>');

  fnd_global.apps_initialize(l_user_id, l_responsibility_id, 178);

  paint_shipment_details(p_asn_line_id,
                         p_asn_line_split_id,
                         'POS_ASN_SHIPMENT_DETAILS_PO_R');

  paint_shipment_details(p_asn_line_id,
                         p_asn_line_split_id,
                         'POS_ASN_DETAILS_SHIPMENTS_R');


  -- use function security to disable or enable the invoice details
  -- region.  if fnd_function.test() returns true, then display
  -- the region.
  IF (fnd_function.test('ICX_DISABLE_ASBN')) and ASBN THEN
    paint_shipment_details(p_asn_line_id,
                           p_asn_line_split_id,
                           'POS_ASN_DETAILS_INVOICE_R');
  END IF;

  htp.p('</tr>');
  htp.p('</table>');
  htp.p('</form>');


  htp.bodyClose;
  htp.htmlClose;

END show_details;




/* set_asn_ids
 * -----------
 */
PROCEDURE set_asn_ids(p_asn_line_id VARCHAR2, p_asn_line_split_id VARCHAR2) IS
BEGIN

  htp.p('<input name="POS_ASN_LINE_ID"' ||
        ' type="HIDDEN" VALUE="' ||
        p_asn_line_id ||
        '">');
  htp.p('<input name="POS_ASN_LINE_SPLIT_ID"' ||
        ' type="HIDDEN" VALUE="' ||
        p_asn_line_split_id ||
        '">');

END set_asn_ids;


/* paint_region_title
 * ------------------
 */
PROCEDURE paint_region_title(p_product VARCHAR2,
                             p_title   VARCHAR2) IS
BEGIN

  htp.p('<tr><td height=20></td></tr>');
  htp.p('<tr>');
  htp.p('<td colspan=6 height=1><img src=/OA_MEDIA/FNDPXG5.gif></td>');
  htp.p('</tr>');
  htp.p('<tr>');

  htp.p('<td colspan=6 valign=bottom height=15 VALIGN=CENTER ALIGN=LEFT><B>' ||
        '<font class=datablack>' || '&nbsp;' ||
        fnd_message.get_string(p_product, p_title) ||
        '</font></B></td>');

  htp.p('</tr>');
  htp.p('<tr>');
  htp.p('<td colspan=6 height=1 bgcolor=black>' ||
        '<img src=/OA_MEDIA/FNDPX1.gif></td>');
  htp.p('</tr>');
  htp.p('<tr>');
  htp.p('<td height=10></td>');
  htp.p('</tr>');
  htp.p('<tr>');

END paint_region_title;



/* paint_single_record_prompt
 * --------------------------
 */
PROCEDURE paint_single_record_prompt(p_attribute_index NUMBER) IS
BEGIN

  htp.p('<td nowrap bgcolor=#cccccc' ||
        ' align='   || item_halign(p_attribute_index) ||
        ' valign='  || item_valign(p_attribute_index) ||
        '>' ||
        '<font class=promptblack>' ||
        item_name(p_attribute_index) ||
        '</font>' ||
        '&nbsp;' ||
        '</td>');

END paint_single_record_prompt;



/* paint_updateable_field
 * ----------------------
 */
PROCEDURE paint_updateable_field(p_attribute_index NUMBER,
                                 p_result_index    NUMBER,
                                 p_current_col     NUMBER) IS
BEGIN

  htp.p('<td nowrap' ||
        ' align=LEFT' ||
        ' valign=CENTER' ||
        '>' ||
        '<font class=datablack>'||
        '<input type=text ' ||
        item_size(p_attribute_index) ||
        item_maxlength(p_attribute_index) ||
        ' name="' || item_code(p_attribute_index) || '"' ||
        ' value="' || get_result_value(p_result_index, p_current_col) ||
        '" ></font>' ||
        item_lov(p_attribute_index) ||
        '</td>');

END paint_updateable_field;



/* paint_nonupdateable_field
 * -------------------------
 */
PROCEDURE paint_nonupdateable_field(p_attribute_index NUMBER,
                                    p_result_index NUMBER,
                                    p_current_col  NUMBER,
                                    p_colspan      NUMBER DEFAULT NULL) IS
  l_colspan VARCHAR2(12);
BEGIN

  IF p_colspan IS NULL THEN
    l_colspan := null;
  ELSE
    l_colspan := 'colspan=' || to_char(p_colspan);
  END IF;

  IF item_code(p_attribute_index) = 'POS_QUANTITY_INVOICED' THEN

    htp.p('<td ' || l_colspan ||
        ' align=LEFT' ||
        ' valign=CENTER' ||
        '>' ||
        '<b><font class=tabledata>' ||
        nvl(g_quantity, fnd_message.get_string('ICX', 'ICX_POS_NA')) ||
        '</font></b></td>');

  ELSIF item_code(p_attribute_index) = 'POS_UNIT_OF_MEASURE' THEN

    htp.p('<td ' || l_colspan ||
        ' align=LEFT' ||
        ' valign=CENTER' ||
        '>' ||
        '<b><font class=tabledata>' ||
        g_unit_of_measure ||
        '</font></b></td>');

  ELSIF item_code(p_attribute_index) = 'POS_EXTENDED_PRICE' THEN

    htp.p('<td ' || l_colspan ||
        ' align=LEFT' ||
        ' valign=CENTER' ||
        '>' ||
        '<b><font class=tabledata>' ||
        nvl(to_char(to_number(g_quantity) * to_number(get_result_value(p_result_index, p_current_col-1))), fnd_message.get_string('ICX', 'ICX_POS_NA')) ||
        '</font></b></td>');

  ELSE

    htp.p('<td ' || l_colspan ||
        ' align=LEFT' ||
        ' valign=CENTER' ||
        '>' ||
        '<b><font class=tabledata>' ||
        nvl(get_result_value(p_result_index, p_current_col),
            fnd_message.get_string('ICX', 'ICX_POS_NA')) ||
        '</font></b></td>');

  END IF;

END paint_nonupdateable_field;



/* paint_hidden_field
 * ------------------
 */
PROCEDURE paint_hidden_field(p_attribute_index NUMBER,
                             p_result_index    NUMBER,
                             p_current_col     NUMBER) IS
BEGIN

  htp.p('<!-- ' || item_code(p_attribute_index) ||
        ' - '   || item_style(p_attribute_index) || ' -->');

  htp.p('<input name="' || item_code(p_attribute_index) ||
        '" type="HIDDEN" VALUE="' ||
        get_result_value(p_result_index, p_current_col) ||
        '">');

END paint_hidden_field;




/* paint_shipment_details
 * ----------------------
 */
PROCEDURE paint_shipment_details(p_asn_line_id VARCHAR2,
                                 p_asn_line_split_id VARCHAR2,
                                 p_region VARCHAR2) IS

  l_attribute_index NUMBER;
  l_result_index    NUMBER;
  l_current_col     NUMBER;
  l_current_row     NUMBER;
  l_paint_col       NUMBER;
  l_region_header   VARCHAR2(240);
  l_where_clause    VARCHAR2(2000) := 'SESSION_ID = ' || to_char(l_session_id);

BEGIN

   l_where_clause := l_where_clause ||
                     '  AND ASN_LINE_ID = ' || p_asn_line_id ||
                     ' AND ASN_LINE_SPLIT_ID = ' || p_asn_line_split_id;


   ak_query_pkg.exec_query(p_parent_region_appl_id  =>  178,
                          p_parent_region_code      =>  p_region,
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  l_responsibility_id,
                          p_user_id                 =>  l_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

   l_attribute_index := ak_query_pkg.g_items_table.FIRST;
   l_result_index := ak_query_pkg.g_results_table.FIRST;

   l_current_col := 0;
   l_paint_col   := 0;

   IF p_region = 'POS_ASN_SHIPMENT_DETAILS_PO_R' THEN
     l_region_header := 'ICX_POS_ASN_DETAILS_PO';
   ELSIF p_region = 'POS_ASN_DETAILS_SHIPMENTS_R' THEN
     l_region_header := 'ICX_POS_ASN_SHIPMENT_DETAILS';
   ELSIF p_region = 'POS_ASN_DETAILS_INVOICE_R' THEN
     l_region_header := 'ICX_POS_ASN_INVOICE_DETAILS';
   END IF;

   paint_region_title('ICX', l_region_header);

   WHILE (l_attribute_index IS NOT NULL) LOOP

     l_current_col := l_current_col + 1;
     l_paint_col   := l_paint_col + 1;

     IF (item_style(l_attribute_index) = 'HIDDEN') THEN
       paint_hidden_field(l_attribute_index, l_result_index, l_current_col);
       l_paint_col := l_paint_col - 1;
     ELSIF item_displayed(l_attribute_index)  THEN
       IF (item_style(l_attribute_index) = 'TEXT') THEN
         IF item_updateable(l_attribute_index) THEN

           paint_single_record_prompt(l_attribute_index);
           paint_updateable_field(l_attribute_index,
                                   l_result_index,
                                   l_current_col);

         ELSE

           IF item_code(l_attribute_index) = 'POS_ITEM_DESCRIPTION' THEN
             htp.tableRowOpen;
             paint_single_record_prompt(l_attribute_index);
             paint_nonupdateable_field(l_attribute_index,
                                       l_result_index,
                                       l_current_col,
                                       6);
             htp.tableRowClose;
           ELSE
             paint_single_record_prompt(l_attribute_index);
             paint_nonupdateable_field(l_attribute_index,
                                       l_result_index,
                                       l_current_col);
           END IF;

         END IF;
       END IF;

     END IF;

     l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

     if ((l_paint_col mod 2) = 0) THEN
       htp.p('</tr>');
       htp.p('<tr bgcolor=#cccccc>');
     end if;

   END LOOP;


END paint_shipment_details;





/* update_details
 * --------------
 */
PROCEDURE update_details(pos_asn_line_id            IN VARCHAR2 DEFAULT NULL,
                         pos_asn_line_split_id      IN VARCHAR2 DEFAULT NULL,
                         pos_expected_receipt_date  IN VARCHAR2 DEFAULT NULL,
                         pos_packing_slip           IN VARCHAR2 DEFAULT NULL,
                         pos_waybill_airbill_num    IN VARCHAR2 DEFAULT NULL,
                         pos_bill_of_lading         IN VARCHAR2 DEFAULT NULL,
                         pos_barcode_label          IN VARCHAR2 DEFAULT NULL,
                         pos_country_of_origin      IN VARCHAR2 DEFAULT NULL,
                         pos_country_of_origin_code IN VARCHAR2 DEFAULT NULL,
                         pos_vendor_cum_shipped_qty IN VARCHAR2 DEFAULT NULL,
                         pos_num_of_containers      IN VARCHAR2 DEFAULT NULL,
                         pos_container_num          IN VARCHAR2 DEFAULT NULL,
                         pos_vendor_lot_num         IN VARCHAR2 DEFAULT NULL,
                         pos_freight_carrier        IN VARCHAR2 DEFAULT NULL,
                         pos_freight_carrier_code   IN VARCHAR2 DEFAULT NULL,
                         pos_truck_num              IN VARCHAR2 DEFAULT NULL,
                         pos_reason_id              IN VARCHAR2 DEFAULT NULL,
                         pos_reason_name            IN VARCHAR2 DEFAULT NULL,
                         pos_ship_to_organization_id IN VARCHAR2 DEFAULT NULL)

IS

  l_format_mask        icx_sessions.DATE_FORMAT_MASK%TYPE;

BEGIN

  -- Bug 1196968

  select date_format_mask
    into l_format_mask
    from icx_sessions
   where session_id = l_session_id;

  fnd_date.initialize(l_format_mask);

  UPDATE pos_asn_shop_cart_details SET

    expected_receipt_date  = fnd_date.chardate_to_date(pos_expected_receipt_date),
    packing_slip           = pos_packing_slip,
    waybill_airbill_num    = pos_waybill_airbill_num,
    bill_of_lading         = pos_bill_of_lading,
    barcode_label          = pos_barcode_label,
    country_of_origin_code = pos_country_of_origin_code,
    vendor_cum_shipped_qty = to_number(pos_vendor_cum_shipped_qty),
    num_of_containers      = to_number(pos_num_of_containers),
    container_num          = pos_container_num,
    vendor_lot_num         = pos_vendor_lot_num,
    freight_carrier_code   = pos_freight_carrier_code,
    truck_num              = pos_truck_num,
    reason_id              = to_number(pos_reason_id)

  WHERE asn_line_id = to_number(pos_asn_line_id) AND
        asn_line_split_id = to_number(pos_asn_line_split_id) AND
        session_id = l_session_id;

  COMMIT;


  -- reload the page, should only need to reload the frame
  g_flag := 'Y';
  show_details(pos_asn_line_id, pos_asn_line_split_id);

END update_details;



/* get_result_value
 * ----------------
 */
function get_result_value(p_index in number, p_col in number) return varchar2 is

BEGIN

  if p_col = 1 then
    return ak_query_pkg.g_results_table(p_index).value1;
  elsif p_col = 2 then
    return ak_query_pkg.g_results_table(p_index).value2;
  elsif p_col = 3 then
    return ak_query_pkg.g_results_table(p_index).value3;
  elsif p_col = 4 then
    return ak_query_pkg.g_results_table(p_index).value4;
  elsif p_col = 5 then
    return ak_query_pkg.g_results_table(p_index).value5;
  elsif p_col = 6 then
    return ak_query_pkg.g_results_table(p_index).value6;
  elsif p_col = 7 then
    return ak_query_pkg.g_results_table(p_index).value7;
  elsif p_col = 8 then
    return ak_query_pkg.g_results_table(p_index).value8;
  elsif p_col = 9 then
    return ak_query_pkg.g_results_table(p_index).value9;
  elsif p_col = 10 then
    return ak_query_pkg.g_results_table(p_index).value10;
  elsif p_col = 11 then
    return ak_query_pkg.g_results_table(p_index).value11;
  elsif p_col = 12 then
    return ak_query_pkg.g_results_table(p_index).value12;
  elsif p_col = 13 then
    return ak_query_pkg.g_results_table(p_index).value13;
  elsif p_col = 14 then
    return ak_query_pkg.g_results_table(p_index).value14;
  elsif p_col = 15 then
    return ak_query_pkg.g_results_table(p_index).value15;
  elsif p_col = 16 then
    return ak_query_pkg.g_results_table(p_index).value16;
  elsif p_col = 17 then
    return ak_query_pkg.g_results_table(p_index).value17;
  elsif p_col = 18 then
    return ak_query_pkg.g_results_table(p_index).value18;
  elsif p_col = 19 then
    return ak_query_pkg.g_results_table(p_index).value19;
  elsif p_col = 20 then
    return ak_query_pkg.g_results_table(p_index).value20;
  elsif p_col = 21 then
    return ak_query_pkg.g_results_table(p_index).value21;
  elsif p_col = 22 then
    return ak_query_pkg.g_results_table(p_index).value22;
  elsif p_col = 23 then
    return ak_query_pkg.g_results_table(p_index).value23;
  elsif p_col = 24 then
    return ak_query_pkg.g_results_table(p_index).value24;
  elsif p_col = 25 then
    return ak_query_pkg.g_results_table(p_index).value25;
  elsif p_col = 26 then
    return ak_query_pkg.g_results_table(p_index).value26;
  elsif p_col = 27 then
    return ak_query_pkg.g_results_table(p_index).value27;
  elsif p_col = 28 then
    return ak_query_pkg.g_results_table(p_index).value28;
  elsif p_col = 29 then
    return ak_query_pkg.g_results_table(p_index).value29;
  elsif p_col = 30 then
    return ak_query_pkg.g_results_table(p_index).value30;
  end if;

END get_result_value;


/* Initialize the session info only once per session */
BEGIN

  IF NOT set_session_info THEN
    RETURN;
  END IF;

END pos_asn_details_s;

/
