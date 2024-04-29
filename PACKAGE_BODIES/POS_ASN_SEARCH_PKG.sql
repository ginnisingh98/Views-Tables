--------------------------------------------------------
--  DDL for Package Body POS_ASN_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN_SEARCH_PKG" AS
/* $Header: POSASNSB.pls 115.8 2001/03/30 17:37:02 pkm ship     $ */

TYPE t_attribute_record IS RECORD (
  attribute_name  VARCHAR2(30),
  attribute_value VARCHAR2(1000)
);

TYPE t_attribute_table IS TABLE OF t_attribute_record INDEX BY BINARY_INTEGER;

g_attribute_table t_attribute_table;

FUNCTION GetSupplierID(p_user_id IN NUMBER) RETURN NUMBER;
FUNCTION GetSupplierSiteID(p_user_id IN NUMBER) RETURN NUMBER;
PROCEDURE ShowBasic(  pos_vendor_site_id         IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_advance_flag             IN VARCHAR2 DEFAULT 'N');
PROCEDURE ShowAdvanced;
PROCEDURE ShowResult(p_start_row    IN NUMBER,
                     p_msg          IN VARCHAR2 DEFAULT NULL);

PROCEDURE PrintResultHeadings;
PROCEDURE PrintAvailableShipment(p_result_index NUMBER,
                                 p_current_row  NUMBER);
PROCEDURE PrintSelectedShipment(p_result_index NUMBER,
                                p_current_row  NUMBER);

procedure button(src IN varchar2,
                 txt IN varchar2);

function get_result_value(p_index in number, p_col in number) return varchar2;


PROCEDURE SetAttributeTable(pos_vendor_site_id   IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL);

FUNCTION GetAttributeValue(p_attribute_name  IN VARCHAR2,
                           p_start_index     IN NUMBER) RETURN VARCHAR2;

function GetRequiredFlag(p_attribute_code IN VARCHAR2) return varchar2;

PROCEDURE UpdateResultSet(p_where_clause IN VARCHAR2 DEFAULT NULL,
                          p_session_id   IN NUMBER);


-- Body

PROCEDURE search_page(p_query                      IN VARCHAR2 DEFAULT 'N',
                      p_msg                        IN VARCHAR2 DEFAULT NULL,
                      p_start_row                  IN NUMBER   DEFAULT 0)
IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);


  if p_start_row = 0 then

    delete pos_asn_search_result where session_id = l_session_id;
    commit;

  end if;

  htp.htmlOpen;
  htp.headOpen;
  icx_util.copyright;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;
  htp.p('<script src="/OA_HTML/POSASNSR.js" language="JavaScript"></script>');
  htp.headClose;

htp.p('

<FRAMESET ROWS="195, 32, *, 38" BORDER=0>

   <FRAME SRC="' || l_script_name || '/POS_ASN_SEARCH_PKG.CRITERIA_FRAME"
    NAME="criteria" MARGINWIDTH="0" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO>

   <FRAME SRC="' || l_script_name || '/POS_ASN_SEARCH_PKG.COUNTER_FRAME"
    NAME="counter" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

   <FRAME SRC="' || l_script_name || '/POS_ASN_SEARCH_PKG.RESULT_FRAME?p_query=' ||
    p_query || '`&p_msg=' || p_msg || '`&p_start_row=' || p_start_row || '"
    NAME="result" MARGINWIDTH="5" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO>

   <FRAME SRC="' || l_script_name || '/POS_ASN_SEARCH_PKG.ADD_FRAME"
    NAME="add" MARGINWIDTH="5" MARGINHEIGHT="10" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

</FRAMESET>

');

  htp.htmlClose;

END search_page;

PROCEDURE criteria_frame(pos_vendor_site_id      IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_advance_flag             IN VARCHAR2 DEFAULT 'N'
) IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id NUMBER;

  l_empty_cart  VARCHAR2(1);

  l_supplier_site_id NUMBER;
  l_supplier_site    VARCHAR2(15);
  l_ship_to_loc_id   NUMBER;
  l_ship_to_location VARCHAR2(20);

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;
  htp.p('<script src="/OA_HTML/POSASNSR.js" language="JavaScript"></script>');
  htp.headClose;

  -- Check if the shopping cart is empty

  select decode(count(1), 0, 'Y', 'N')
    into l_empty_cart
    from POS_ASN_SHOP_CART_DETAILS
   where session_id = l_session_id;

  if l_empty_cart = 'N' then

    -- If the shopping cart is not empty, default the fixed information
    -- (supplier site and ship to location) to the criteria fields.

    select ct.vendor_site_id,
           vs.vendor_site_code,
           ct.ship_to_location_id,
           hrl.location_code
      into l_supplier_site_id,
           l_supplier_site,
           l_ship_to_loc_id,
           l_ship_to_location
      from POS_ASN_SHOP_CART_HEADERS   ct,
           PO_VENDOR_SITES             vs,
           HR_LOCATIONS	       hrl
     where ct.session_id = l_session_id
       and ct.vendor_site_id = vs.vendor_site_id
       and ct.SHIP_TO_LOCATION_ID = hrl.LOCATION_ID;

  else

    -- Default the supplier site info if the user is secured by supplier site.

    begin
      select ak.NUMBER_VALUE,
             vs.VENDOR_SITE_CODE
        into l_supplier_site_id,
             l_supplier_site
        from AK_WEB_USER_SEC_ATTR_VALUES ak,
             PO_VENDOR_SITES             vs
       where ATTRIBUTE_CODE = 'ICX_SUPPLIER_SITE_ID'
         and ak.NUMBER_VALUE = vs.VENDOR_SITE_ID
         and WEB_USER_ID = l_user_id
         and exists (select 1
                       from ak_resp_security_attributes
                      where attribute_code = 'ICX_SUPPLIER_SITE_ID'
                        and responsibility_id = l_responsibility_id);

    exception
      when others then
        l_supplier_site_id := NULL;
        l_supplier_site := NULL;
    end;

  end if;

  SetAttributeTable(l_supplier_site_id,
                    l_supplier_site,
                    l_ship_to_loc_id,
                    l_ship_to_location,
                    pos_supplier_item_number,
                    pos_item_description,
                    pos_po_number,
                    pos_item_number,
                    pos_date_start,
                    pos_date_end);

  htp.p('<body bgcolor=#cccccc onLoad="javascript:setCriteria(''' || l_empty_cart|| ''', ''' || p_advance_flag || ''')">');

  htp.p('<table width=100% bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');

  htp.p('<TR><TD VALIGN=MIDDLE ALIGN=LEFT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=helptext>&`nbsp;' ||
        fnd_message.get_string('ICX','ICX_POS_ASN_ENTER_CRITERIA') ||
        '`&nbsp;`&nbsp;`&nbsp;<img src=/OA_MEDIA/FNDIREQD.gif align=top>' ||
        fnd_message.get_string('ICX','ICX_POS_REQUIRED_FIELD') || '</FONT></TD></TR>');

  htp.p('</TABLE>');

  htp.p('<FORM NAME="POS_ASN_SEARCH_R" ACTION="' || l_script_name ||
        '/POS_ASN_SEARCH_PKG.RESULT_FRAME" TARGET="result" METHOD="GET">');

  htp.p('<table bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');

  htp.p('<tr bgcolor=#cccccc>');

  ShowBasic(pos_vendor_site_id,
            pos_vendor_site_name,
            pos_ship_to_location_id,
            pos_ship_to_location,
            pos_supplier_item_number,
            pos_item_description,
            pos_po_number,
            pos_item_number,
            pos_date_start,
            pos_date_end,
            p_advance_flag);

  if p_advance_flag = 'Y' then
    ShowAdvanced;
  end if;

  htp.p('</TABLE>');
  htp.p('</FORM>');

  htp.bodyClose;
  htp.htmlClose;

END criteria_frame;

PROCEDURE counter_frame(p_first IN NUMBER DEFAULT 0,
                        p_last  IN NUMBER DEFAULT 0,
                        p_total IN NUMBER DEFAULT 0,
                        p_msg   IN VARCHAR2 DEFAULT NULL) IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_msg         VARCHAR2(200);

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  htp.headClose;

  htp.p('<body bgcolor=#cccccc>');

  htp.p('<table width=100% bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');

  htp.p('<tr bgcolor=#cccccc><td colspan=2 height=5><img src=/OA_MEDIA/FNDPXG5.gif></td></tr>');
  htp.p('<tr><td colspan=4 height=1 bgcolor=black><img src=/OA_MEDIA/FNDPX1.gif></td></tr>');
  htp.p('<tr bgcolor=#cccccc><td colspan=2 height=3><img src=/OA_MEDIA/FNDPXG5.gif></td></tr>');

  if p_total > 0 then

    htp.p('<tr bgcolor=#cccccc>');

    htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=helptext>`&nbsp;' ||
          fnd_message.get_string('ICX','ICX_POS_ASN_SELECT_RESULT') || '</FONT></TD>');

    l_msg := fnd_message.get_string('ICX','ICX_POS_ASN_RESULT_COUNTER');

    l_msg := replace(l_msg, '`&TOTAL', to_char(p_total));
    l_msg := replace(l_msg, '`&FROM', to_char(p_first));
    l_msg := replace(l_msg, '`&TO', to_char(p_last));

    htp.p('<TD VALIGN=MIDDLE ALIGN=RIGHT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=promptblack>' ||
          l_msg || '`&nbsp</FONT></TD></TR>');

  else

    htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=datablack>`&nbsp;' ||
          p_msg || '</FONT></TD>');

  end if;

  htp.p('</TABLE>');

  htp.bodyClose;

  htp.htmlClose;

END;

PROCEDURE result_frame(pos_vendor_site_id        IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_query                    IN VARCHAR2 DEFAULT 'Y',
                      p_msg                      IN VARCHAR2 DEFAULT NULL,
                      p_start_row                IN NUMBER   DEFAULT 1
) IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_attribute_index  NUMBER;
  l_result_index     NUMBER;

  l_where_clause     VARCHAR2(2000) := '1 = 1 ';

  l_start_date DATE;
  l_end_date   DATE;

  l_rows_returned NUMBER := 0;

  l_progress   VARCHAR2(1000) := '000';

  l_supplier_attr      NUMBER := NULL;
  l_supplier_site_attr NUMBER := NULL;

  l_required_flag      VARCHAR2(1);
  l_label              VARCHAR2(50);

  l_format_mask        icx_sessions.DATE_FORMAT_MASK%TYPE;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  fnd_client_info.set_org_context(l_org_id);

  IF p_query = 'N' THEN
    ShowResult(p_start_row, p_msg);
    return;
  END IF;

  -- Search Criteria of Supplier Site

  l_required_flag := GetRequiredFlag('POS_VENDOR_SITE_NAME');

  IF pos_vendor_site_name IS NULL and l_required_flag = 'Y' THEN
    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_ASN_MISSING_FIELD'));
    return;
  ELSIF pos_vendor_site_id IS NOT NULL THEN
    l_where_clause := l_where_clause || ' and supplier_site_id = ' || pos_vendor_site_id;
  ELSIF pos_vendor_site_name IS NOT NULL THEN
    l_where_clause := l_where_clause || ' and supplier_site_code = ''' || pos_vendor_site_name || '''';
  END IF;

  -- Search Criteria for Location

  l_required_flag := GetRequiredFlag('POS_SHIP_TO_LOCATION');

  IF pos_ship_to_location IS NULL and l_required_flag = 'Y' THEN
    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_ASN_MISSING_FIELD'));
    return;
  ELSIF pos_ship_to_location_id IS NOT NULL THEN
    l_where_clause := l_where_clause || ' and ship_to_location_id = ' || pos_ship_to_location_id;
  ELSIF pos_ship_to_location IS NOT NULL THEN
    l_where_clause := l_where_clause || ' and ship_to_location_code = ''' || pos_ship_to_location || '''';
  END IF;

  -- Search Criteria for other fields

  l_required_flag := GetRequiredFlag('POS_SUPPLIER_ITEM_NUMBER');

  IF pos_supplier_item_number IS NULL and l_required_flag = 'Y' THEN
    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_ASN_MISSING_FIELD'));
    return;
  ELSIF pos_supplier_item_number is not null then
    l_where_clause := l_where_clause || ' and supplier_item_number like ''' || pos_supplier_item_number || '''';
  end if;

  l_required_flag := GetRequiredFlag('POS_ITEM_DESCRIPTION');

  IF pos_item_description IS NULL and l_required_flag = 'Y' THEN
    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_ASN_MISSING_FIELD'));
    return;
  ELSIF pos_item_description is not null then
    l_where_clause := l_where_clause || ' and item_description like ''' || pos_item_description || '''';
  end if;

  l_required_flag := GetRequiredFlag('POS_PO_NUMBER');

 -- Bug# 1696725. Changed the po_number to po_num_search
 -- while building l_where_clause  to improve performance.

  IF pos_po_number IS NULL and l_required_flag = 'Y' THEN
    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_ASN_MISSING_FIELD'));
    return;
  ELSIF pos_po_number is not null then
    l_where_clause := l_where_clause || ' and po_num_search like ''' || pos_po_number || '''';
  end if;

  -- Search Criteria for advance field

  IF pos_item_number is not null then
    l_where_clause := l_where_clause || ' and item_number like ''' || pos_item_number || '''';
  end if;

  IF pos_date_start is not null or pos_date_end is not null then

    -- Bug 1196968

    select date_format_mask
      into l_format_mask
      from icx_sessions
     where session_id = l_session_id;

    fnd_date.initialize(l_format_mask);

    if pos_date_start is null then

      l_start_date := sysdate;

    else

      l_start_date := fnd_date.chardate_to_date(pos_date_start);

    end if;

    if pos_date_end is null then

      l_end_date := sysdate;

    else

      l_end_date := fnd_date.chardate_to_date(pos_date_end);

    end if;

    l_where_clause := l_where_clause || ' and due_date between ''' ||
                      fnd_date.date_to_chardate(l_start_date) ||
                      ''' and ''' ||
                      fnd_date.date_to_chardate(l_end_date) || '''';

  end if;

  UpdateResultSet(l_where_clause, l_session_id);

  ShowResult(p_start_row);

EXCEPTION

  when others then

    delete pos_asn_search_result where session_id = l_session_id;
    commit;

    ShowResult(p_start_row, fnd_message.get_string('ICX','ICX_POS_NO_RECORDS'));

END result_frame;

procedure add_frame IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_attribute_index  NUMBER;
  l_result_index     NUMBER;

  l_where_clause     VARCHAR2(2000);

  l_num_shipments    NUMBER;
  l_num_results      NUMBER;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  l_where_clause := 'SESSION_ID = ' || to_char(l_session_id);

  fnd_client_info.set_org_context(l_org_id);

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;
  htp.p('<script src="/OA_HTML/POSASNSR.js" language="JavaScript"></script>');
  htp.headClose;

  htp.p('<body bgcolor=#cccccc>');

  select count(1)
    into l_num_shipments
    from pos_asn_shop_cart_details
   where session_id = l_session_id;

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_RESULT_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  l_num_results := ak_query_pkg.g_results_table.count;

  htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');
  htp.p('<TR><TD>');

  if l_num_results > 0 then

     button('javascript:parent.result.document.POS_ASN_RESULT_R.submit()',
            fnd_message.get_string('ICX','ICX_POS_ASN_ADD'));

  end if;

  htp.p('</TD><TD align=right><FONT class=promptblack>');

  if l_num_shipments > 0 then
    htp.p('Total PO shipments added: ' || to_char(l_num_shipments));
  end if;

  htp.p('</FONT></TD>');
  htp.p('</TABLE>');

  -- debug
  htp.p('<!-- ' || to_char(l_session_id) || '-->');

  htp.bodyClose;

  htp.htmlClose;

END add_frame;

PROCEDURE add_shipments_to_cart(pos_po_shipment_id   IN t_text_table DEFAULT g_dummy,
                                pos_select           IN t_text_table DEFAULT g_dummy,
                                pos_start_row        IN VARCHAR2     DEFAULT '1',
                                pos_submit           IN VARCHAR2     DEFAULT 'STAY') IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_header_count NUMBER;
  l_asn_line_id  NUMBER;


  l_ship_to_org_id  NUMBER;
  l_ship_to_loc_id  NUMBER;
  l_vendor_id       NUMBER;
  l_vendor_site_id  NUMBER;

  l_po_header_id             NUMBER;
  l_po_line_id               NUMBER;
  l_po_shipment_id     NUMBER;

  l_unit_meas_lookup_code    VARCHAR2(25);

  l_num_row                  NUMBER := 0;

  l_first_org_id   NUMBER := -1;
  l_first_loc_id   NUMBER := -1;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  fnd_client_info.set_org_context(l_org_id);

  -- Check whether multiple ship to org are selected.
  -- error out if yes.

  begin
    select ship_to_organization_id,
           ship_to_location_id
      into l_first_org_id,
           l_first_loc_id
      from pos_asn_shop_cart_headers
     where session_id = l_session_id;
  exception
    when others then
      null;
  end;

  FOR l_counter IN 1..pos_select.count LOOP

    l_po_shipment_id := to_number(pos_po_shipment_id(to_number(pos_select(l_counter))));

    select SHIP_TO_ORGANIZATION_ID,
           ship_to_location_id
      into l_ship_to_org_id,
           l_ship_to_loc_id
      from po_line_locations
     where line_location_id = l_po_shipment_id;

    if l_first_org_id = -1 then
      l_first_org_id := l_ship_to_org_id;
    end if;

    if l_first_loc_id = -1 then
      l_first_loc_id := l_ship_to_loc_id;
    end if;

    if l_first_org_id <> l_ship_to_org_id then
      if pos_submit = 'NEXT' then
        pos_asn_search_pkg.search_page('N', 'ICX_POS_ASN_DIFF_ORG', pos_start_row);
      else
        ShowResult(to_number(pos_start_row), 'ICX_POS_ASN_DIFF_ORG');
      end if;
      return;
    end if;

    if l_first_loc_id <> l_ship_to_loc_id then
      if pos_submit = 'NEXT' then
        pos_asn_search_pkg.search_page('N', 'ICX_POS_ASN_DIFF_LOC', pos_start_row);
      else
        ShowResult(to_number(pos_start_row), 'ICX_POS_ASN_DIFF_LOC');
      end if;
      return;
    end if;


  END LOOP;

  -- Check if existing ASN header for this session exists.
  -- if no, create a new ASN header.

  select count(1)
    into l_header_count
    from pos_asn_shop_cart_headers
   where session_id = l_session_id;

  if l_header_count = 0 and pos_select.count > 0 then

    l_po_shipment_id := to_number(pos_po_shipment_id(to_number(pos_select(1))));

    select poll.ship_to_organization_id,
           poll.ship_to_location_id,
           poh.vendor_id,
           poh.vendor_site_id
      into l_ship_to_org_id,
           l_ship_to_loc_id,
           l_vendor_id,
           l_vendor_site_id
      from po_line_locations poll,
           po_headers        poh
     where poh.po_header_id = poll.po_header_id
       and poll.line_location_id = l_po_shipment_id;

    insert into pos_asn_shop_cart_headers
      (
       SESSION_ID,
       SHIP_TO_ORGANIZATION_ID,
       SHIP_TO_LOCATION_ID,
       VENDOR_ID,
       VENDOR_SITE_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       CREATION_DATE,
       CREATED_BY
      )
    values
      (
       l_session_id,
       l_ship_to_org_id,
       l_ship_to_loc_id,
       l_vendor_id,
       l_vendor_site_id,
       sysdate,
       fnd_global.user_id,
       fnd_global.user_id,
       sysdate,
       fnd_global.user_id
      );

  end if;

  FOR l_counter IN 1..pos_select.count LOOP

    select nvl(max(asn_line_id), 0) + 1
      into l_asn_line_id
      from pos_asn_shop_cart_details
     where session_id = l_session_id;

    l_po_shipment_id := to_number(pos_po_shipment_id(to_number(pos_select(l_counter))));

    select poll.po_header_id,
           poll.po_line_id,
           poll.ship_to_organization_id,
           pol.unit_meas_lookup_code
      into l_po_header_id,
           l_po_line_id,
           l_ship_to_org_id,
           l_unit_meas_lookup_code
      from po_line_locations poll,
           po_lines          pol
     where poll.line_location_id = l_po_shipment_id
       and poll.po_line_id = pol.po_line_id;

    insert into pos_asn_shop_cart_details
      (
       SESSION_ID,
       ASN_LINE_ID,
       PO_LINE_LOCATION_ID,
       PO_HEADER_ID,
       PO_LINE_ID,
       SHIP_TO_ORGANIZATION_ID,
       UNIT_OF_MEASURE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       CREATION_DATE,
       CREATED_BY
      )
    values
      (
       l_session_id,
       l_asn_line_id,
       l_po_shipment_id,
       l_po_header_id,
       l_po_line_id,
       l_ship_to_org_id,
       l_unit_meas_lookup_code,
       sysdate,
       fnd_global.user_id,
       fnd_global.user_id,
       sysdate,
       fnd_global.user_id
      );

    l_num_row := l_num_row + 1;

  END LOOP;

  commit;

  -- If pos_submit = 'NEXT', means go to next page.

  if pos_submit = 'NEXT' then
    pos_asn.show_edit_page;
  else
    ShowResult(to_number(pos_start_row));
  end if;

end;

PROCEDURE SwitchResultPage(p_start_row    IN VARCHAR2 DEFAULT '1') IS
BEGIN
  ShowResult(to_number(p_start_row));
END SwitchResultPage;

PROCEDURE UpdateResultSet(p_where_clause IN VARCHAR2 DEFAULT NULL,
                          p_session_id   IN NUMBER) IS

  v_stmt      VARCHAR2(2000);
  v_cursor_id NUMBER;
  result      NUMBER;

BEGIN

  delete pos_asn_search_result where session_id = p_session_id;

  v_cursor_id := DBMS_SQL.open_cursor;

  v_stmt :=
    'insert into pos_asn_search_result select ' || to_char(p_session_id) || ',
         PO_HEADER_ID,
         PO_NUMBER,
         PO_RELEASE_ID,
         PO_LINE_ID,
         LINE_NUMBER,
         PO_SHIPMENT_ID,
         SHIPMENT_NUMBER,
         SHIP_TO_LOCATION_ID,
         SHIP_TO_LOCATION_CODE,
         SUPPLIER_ITEM_NUMBER,
         ITEM_DESCRIPTION,
         QUANTITY_ORDERED,
         UNIT_OF_MEASURE_CODE,
         DUE_DATE,
         SUPPLIER_ID,
         SUPPLIER_NAME,
         SUPPLIER_SITE_ID,
         SUPPLIER_SITE_CODE,
         SHIP_TO_ORGANIZATION_ID,
         SHIP_TO_ORGANIZATION_CODE,
         SHIP_TO_ORGANIZATION_NAME,
         ITEM_ID,
         ITEM_NUMBER,
         ITEM_REVISION,
         CATEGORY_ID,
         CATEGORY
      from POS_ASN_PO_SHIPMENTS_V
     where ' || p_where_clause;

  DBMS_SQL.parse(v_cursor_id, v_stmt, dbms_sql.native);

  result := DBMS_SQL.execute(v_cursor_id);

  DBMS_SQL.close_cursor(v_cursor_id);

  commit;

END UpdateResultSet;


--- Private function

FUNCTION GetSupplierID(p_user_id IN NUMBER) RETURN NUMBER IS

  l_supplier_id NUMBER;

BEGIN

  select NUMBER_VALUE
    into l_supplier_id
    from AK_WEB_USER_SEC_ATTR_VALUES
   where ATTRIBUTE_CODE = 'ICX_SUPPLIER_ORG_ID'
     and WEB_USER_ID = p_user_id;

/*
  select vs.vendor_id
    into l_supplier_id
    from po_vendor_sites     vs,
         po_vendor_contacts  vc,
         fnd_user            fu
   where fu.user_id = p_user_id
     and fu.supplier_id = vc.vendor_contact_id
     and vc.vendor_site_id = vs.vendor_site_id;
*/
  return(l_supplier_id);

EXCEPTION
  when others then
    return(0);

END;

FUNCTION GetSupplierSiteID(p_user_id IN NUMBER) RETURN NUMBER IS

  l_supplier_site_id NUMBER;

BEGIN

  select NUMBER_VALUE
    into l_supplier_site_id
    from AK_WEB_USER_SEC_ATTR_VALUES
   where ATTRIBUTE_CODE = 'ICX_SUPPLIER_SITE_ID'
     and WEB_USER_ID = p_user_id;

  return(l_supplier_site_id);

EXCEPTION
  when others then
    return(0);

END;

PROCEDURE ShowBasic(pos_vendor_site_id           IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_advance_flag             IN VARCHAR2 DEFAULT 'N'
) IS

  l_index NUMBER;
  l_count NUMBER;
  l_row   NUMBER;

  l_star  VARCHAR2(100);
  l_fix   VARCHAR2(100);

BEGIN

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_SEARCH_R',
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'F',
                          p_return_children=>'F');

  l_count := 0;
  l_index := ak_query_pkg.g_items_table.FIRST;
  l_row := 0;

  WHILE (l_index IS NOT NULL) LOOP

    l_count := l_count + 1;

    IF (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_index).secured_column = 'F') THEN

      IF (ak_query_pkg.g_items_table(l_index).item_style = 'HIDDEN') THEN

        htp.p('<INPUT NAME="'||
              ak_query_pkg.g_items_table(l_index).attribute_code||
              '" TYPE="hidden" VALUE="' ||
              GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                p_start_index=>l_count) || '">');

      ELSIF (ak_query_pkg.g_items_table(l_index).item_style = 'TEXT') THEN

        l_row := l_row + 1;

        if ak_query_pkg.g_items_table(l_index).required_flag = 'Y' then

          l_star :=  '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>';

        else

          l_star := '';

        end if;

        if ak_query_pkg.g_items_table(l_index).attribute_code in ('POS_VENDOR_SITE_NAME',
                                                                  'POS_SHIP_TO_LOCATION') then

          l_fix  := ' onfocus="javascript:checkBlur(this)" ';

        else

          l_fix  := '';

        end if;

        htp.p('<TR>');
        htp.p('<TD VALIGN=MIDDLE ALIGN=RIGHT WIDTH=175 BGCOLOR=#CCCCCC>'|| l_star ||
              '<FONT CLASS=promptblack>'||
              ak_query_pkg.g_items_table(l_index).attribute_label_long||
              '</FONT>`&nbsp;</TD>');
        htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=350 BGCOLOR=#CCCCCC>'||
              '<FONT CLASS=datablack>');
        htp.p('<INPUT NAME="'||ak_query_pkg.g_items_table(l_index).attribute_code ||'" TYPE="text"' ||
              ' VALUE="'||
              GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                p_start_index=>l_count) ||
              '" SIZE='||ak_query_pkg.g_items_table(l_index).display_value_length ||
              ' MAXLENGTH='||ak_query_pkg.g_items_table(l_index).attribute_value_length ||
              ' onChange="javascript:reset_hidden(''' || ak_query_pkg.g_items_table(l_index).attribute_code || ''')" ' ||
              l_fix ||'></FONT>');

        IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
            ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL) THEN

            htp.p('<A HREF="javascript:call_LOV('''||
                  ak_query_pkg.g_items_table(l_index).attribute_code || ''')"' ||
                  '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 HEIGHT=21 border=no align=absmiddle></A></TD>');
        END IF;

        htp.p('</TD>');

        IF l_row = 1 THEN

          -- Search Button

          htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100 BGCOLOR=#CCCCCC>');

          button('javascript:searchShipments()', fnd_message.get_string('ICX', 'ICX_POS_SEARCH'));

          htp.p('</TD>');

          -- Clear Button

          htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100 BGCOLOR=#CCCCCC>');

          button('javascript:clearFields()', fnd_message.get_string('ICX', 'ICX_POS_CLEAR'));

          htp.p('</TD>');

        ELSIF l_row = 3 THEN

          htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT colspan=2 BGCOLOR=#CCCCCC>');

          htp.p('<a href="javascript:SwitchSearch()">');

          if (p_advance_flag = 'Y') then

            htp.p(fnd_message.get_string('ICX','ICX_POS_SIM_SEARCH'));
            htp.p('</font></a>`&nbsp;<img src=/OA_MEDIA/FNDWADVS.gif border=no>');
          else

            htp.p(fnd_message.get_string('ICX','ICX_POS_ADV_SEARCH'));
            htp.p('</font></a>`&nbsp;<img src=/OA_MEDIA/FNDWADVS.gif border=no>');
          end if;

          htp.p('</TD>');

        ELSE

          htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT colspan=2 BGCOLOR=#CCCCCC>');
          htp.p('`&nbsp');
          htp.p('</TD>');

        END IF;

        htp.p('</TR>');

      ELSE

        htp.p('<!-- '||ak_query_pkg.g_items_table(l_index).attribute_code||
              ' - '||ak_query_pkg.g_items_table(l_index).item_style||' -->');
      END IF;

    END IF;

    l_index := ak_query_pkg.g_items_table.NEXT(l_index);

  END LOOP;

END ShowBasic;


PROCEDURE ShowAdvanced IS

  l_index NUMBER;
  l_count NUMBER;

  l_star  VARCHAR2(100);
  l_fix   VARCHAR2(100);

BEGIN

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_ADV_SEARCH_R',
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'F',
                          p_return_children=>'F');

  l_count := 0;
  l_index := ak_query_pkg.g_items_table.FIRST;

  WHILE (l_index IS NOT NULL) LOOP

    l_count := l_count + 1;

IF (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_index).secured_column = 'F') THEN

      IF (ak_query_pkg.g_items_table(l_index).item_style = 'HIDDEN') THEN

        htp.p('<INPUT NAME="'||
              ak_query_pkg.g_items_table(l_index).attribute_code||
              '" TYPE="hidden" VALUE="' ||
              GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                p_start_index=>l_count) || '">');

      ELSIF (ak_query_pkg.g_items_table(l_index).item_style = 'TEXT') THEN

        if ak_query_pkg.g_items_table(l_index).required_flag = 'Y' then

          l_star :=  '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>';

        else

          l_star := '';

        end if;

        if ak_query_pkg.g_items_table(l_index).attribute_code in ('POS_VENDOR_SITE_NAME',
                                                                  'POS_SHIP_TO_LOCATION') then

          l_fix  := ' onfocus="javascript:checkBlur(this)" ';

        else

          l_fix  := '';

        end if;

        htp.p('<TR>');
        htp.p('<TD VALIGN=MIDDLE ALIGN=RIGHT WIDTH=175 BGCOLOR=#CCCCCC>'|| l_star ||
              '<FONT CLASS=promptblack>'||
              ak_query_pkg.g_items_table(l_index).attribute_label_long||
              '</FONT>`&nbsp;</TD>');
        htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=350 BGCOLOR=#CCCCCC>'||
              '<FONT CLASS=datablack>');
        htp.p('<INPUT NAME="'||ak_query_pkg.g_items_table(l_index).attribute_code ||'" TYPE="text"' ||
              ' VALUE="'||
              GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                p_start_index=>l_count) ||
              '" SIZE='||ak_query_pkg.g_items_table(l_index).display_value_length ||
              ' MAXLENGTH='||ak_query_pkg.g_items_table(l_index).attribute_value_length ||
              ' onChange="javascript:reset_hidden(''' || ak_query_pkg.g_items_table(l_index).attribute_code || ''')" ' ||
              l_fix ||'></FONT>');

        IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
            ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL) THEN

            htp.p('<A HREF="javascript:call_LOV('''||
                  ak_query_pkg.g_items_table(l_index).attribute_code || ''')"' ||
                  '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 HEIGHT=21 border=no align=absmiddle></A></TD>');
        END IF;

        IF ak_query_pkg.g_items_table(l_index).attribute_code = 'POS_DATE_START' THEN

          l_index := ak_query_pkg.g_items_table.NEXT(l_index);

          l_count := l_count + 1;

          htp.p('<FONT CLASS=promptblack>' || ak_query_pkg.g_items_table(l_index).attribute_label_long ||
                '</FONT>`&nbsp;<FONT CLASS=datablack>');

          htp.p('<INPUT NAME="'||ak_query_pkg.g_items_table(l_index).attribute_code ||'" TYPE="text"' ||
                ' VALUE="'||
                GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                  p_start_index=>l_count) ||
                '" SIZE='||ak_query_pkg.g_items_table(l_index).display_value_length ||
                ' MAXLENGTH='||ak_query_pkg.g_items_table(l_index).attribute_value_length ||
                ' onChange="javascript:reset_hidden(''' || ak_query_pkg.g_items_table(l_index).attribute_code || ''')" ' ||
                l_fix ||'></FONT>');

        END IF;

        htp.p('</TD>');

        htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT colspan=2 BGCOLOR=#CCCCCC>');
        htp.p('`&nbsp');
        htp.p('</TD>');

        htp.p('</TR>');

      ELSE

        htp.p('<!-- '||ak_query_pkg.g_items_table(l_index).attribute_code||
              ' - '||ak_query_pkg.g_items_table(l_index).item_style||' -->');

        END IF;

    END IF;

    l_index := ak_query_pkg.g_items_table.NEXT(l_index);

  END LOOP;

END ShowAdvanced;

PROCEDURE ShowResult(p_start_row    IN NUMBER,
                     p_msg          IN VARCHAR2 DEFAULT NULL) IS

  l_result_index     NUMBER;

  l_current_col      NUMBER := 0;
  l_current_row      NUMBER := 0;
  l_total_rows       NUMBER := 0;

  l_session_id       NUMBER := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_script_name      VARCHAR2(240) := owa_util.get_cgi_env('SCRIPT_NAME');
  l_language         VARCHAR2(5) := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  l_where_clause     VARCHAR2(2000) := 'SESSION_ID = ' || to_char(l_session_id);

  l_empty_cart       VARCHAR2(1);
  l_in_cart          NUMBER;
  l_shipment_id      NUMBER;

  l_msg              VARCHAR2(200);

  l_pagesize         NUMBER;

BEGIN

  -- Get the page size from icx_parameters

  select nvl(query_set, 25)
    into l_pagesize
    from icx_parameters;

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;
  htp.p('<script src="/OA_HTML/POSASNSR.js" language="JavaScript"></script>');
  htp.headClose;

  if p_start_row = 0 then

    htp.p('<BODY bgcolor=#cccccc>');
    htp.p('<FORM NAME="POS_ASN_RESULT_R" ACTION="' || l_script_name || '/POS_ASN_SEARCH_PKG.ADD_SHIPMENTS_TO_CART" TARGET="result" METHOD=GET">');

    htp.p('<INPUT NAME="pos_start_row" TYPE="HIDDEN" VALUE="0">');
    htp.p('<INPUT NAME="pos_submit" TYPE="HIDDEN" VALUE="STAY">');
    htp.p('</FORM>');

    htp.p('<FORM NAME="RESULT_INFO">');
    htp.p('<INPUT NAME="p_start" TYPE="HIDDEN" VALUE="">');
    htp.p('<INPUT NAME="p_stop" TYPE="HIDDEN" VALUE="">');
    htp.p('<INPUT NAME="p_total" TYPE="HIDDEN" VALUE="">');
    htp.p('<INPUT NAME="select_all" TYPE="HIDDEN" VALUE="Y">');
    htp.p('</FORM>');

    htp.bodyClose;
    htp.htmlClose;
    return;

  end if;

  select decode(count(1), 0, 'Y', 'N')
    into l_empty_cart
    from POS_ASN_SHOP_CART_DETAILS
   where session_id = l_session_id;

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_RESULT_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  l_total_rows := ak_query_pkg.g_results_table.count;

  l_msg := p_msg;

  if l_msg is null and l_total_rows = 0 then

    l_msg := fnd_message.get_string('ICX','ICX_POS_NO_RECORDS');

  end if;

  htp.p('<BODY bgcolor=#cccccc onLoad="javascript:LoadResult(''' || l_msg  || ''', ''' || l_empty_cart || ''')">');

  htp.p('<FORM NAME="POS_ASN_RESULT_R" ACTION="' || l_script_name || '/POS_ASN_SEARCH_PKG.ADD_SHIPMENTS_TO_CART" TARGET="result" METHOD=GET">');

  htp.p('<INPUT NAME="pos_start_row" TYPE="HIDDEN" VALUE="' || p_start_row || '">');
  htp.p('<INPUT NAME="pos_submit" TYPE="HIDDEN" VALUE="STAY">');

  htp.p('<table align=center width=96% bgcolor=#999999 cellpadding=2 cellspacing=0 border=0>');
  htp.p('<tr><td>');

  htp.p('<TABLE align=center cellpadding=2 cellspacing=1 border=0>');

  IF l_total_rows > 0 THEN

    PrintResultHeadings;

    l_result_index := ak_query_pkg.g_results_table.FIRST;

    l_current_row := 0;

    WHILE (l_result_index IS NOT NULL) LOOP

      l_current_row := l_current_row + 1;

      if (l_current_row >= p_start_row AND l_current_row < p_start_row + l_pagesize) OR
         p_start_row is null then

        if (((l_current_row - p_start_row + 1)mod 2) = 0) THEN
          htp.p('<TR BGCOLOR=''#ffffff'' >');
        else
          htp.p('<TR BGCOLOR=''#99ccff'' >');
        end if;

        l_shipment_id := to_number(get_result_value(l_result_index, 1));

        select count(1)
          into l_in_cart
          from pos_asn_shop_cart_details
         where session_id = l_session_id
           and po_line_location_id = l_shipment_id;

        if l_in_cart = 0 then
            PrintAvailableShipment(l_result_index, l_current_row - p_start_row + 1);
        else
            PrintSelectedShipment(l_result_index, l_current_row - p_start_row + 1);
        end if;

        htp.p('</TR>');

      END IF;

      EXIT WHEN l_current_row >= p_start_row + l_pagesize - 1;

      l_result_index := ak_query_pkg.g_results_table.NEXT(l_result_index);

    END LOOP;

  END IF;

  htp.p('</TABLE>');

  htp.p('</td></tr></table>');

  htp.p('</FORM>');

  htp.p('<FORM NAME="RESULT_INFO">');

  htp.p('<INPUT NAME="p_start" TYPE="HIDDEN" VALUE="' ||
          to_char(p_start_row) || '">');

  htp.p('<INPUT NAME="p_stop" TYPE="HIDDEN" VALUE="' || to_char(l_current_row) || '">');

  htp.p('<INPUT NAME="p_total" TYPE="HIDDEN" VALUE="' || to_char(l_total_rows) || '">');

  htp.p('<INPUT NAME="select_all" TYPE="HIDDEN" VALUE="Y">');

  htp.p('</FORM>');

  htp.p('<table align=right width=200 bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');

  htp.p('<TR>');

  if p_start_row - 1 >= l_pagesize then

    htp.p('<TR><TD VALIGN=MIDDLE ALIGN=RIGHT BGCOLOR=#CCCCCC NOWRAP>' ||
          '<a href="javascript:parent.result.SwitchPage(''' ||
          to_char(0 - l_pagesize) || ''')">' ||
          fnd_message.get_string('ICX','ICX_POS_BTN_PREVIOUS') || ' ' ||
          to_char(l_pagesize) ||
          '</a></TD>');

  end if;

  if l_total_rows - l_current_row > 0 then

    htp.p('<TD VALIGN=MIDDLE ALIGN=RIGHT BGCOLOR=#CCCCCC NOWRAP>' ||
          '<a href="javascript:parent.result.SwitchPage(''' ||
          to_char(l_pagesize) || ''')">' ||
          fnd_message.get_string('ICX','ICX_POS_BTN_NEXT') || ' ' ||
          to_char(l_pagesize) || '</a></TD>');

  end if;

  htp.p('</TR>');

  htp.p('</TABLE>');

  htp.bodyClose;
  htp.htmlClose;

END ShowResult;

PROCEDURE PrintResultHeadings IS

  l_attribute_index  NUMBER := ak_query_pkg.g_items_table.FIRST;

BEGIN

  htp.p('<TR>');

  WHILE (l_attribute_index IS NOT NULL) LOOP

    IF (ak_query_pkg.g_items_table(l_attribute_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_attribute_index).secured_column = 'F') THEN

      IF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'TEXT') THEN

        htp.p('</TD><TD bgcolor=#336699 align=' || ak_query_pkg.g_items_table(l_attribute_index).horizontal_alignment ||
              ' valign=bottom><font class=promptwhite>' ||
              ak_query_pkg.g_items_table(l_attribute_index).attribute_label_long || '</font></TD>');

      ELSIF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'CHECKBOX') THEN

        htp.p('</TD><TD bgcolor=#336699 align=' || ak_query_pkg.g_items_table(l_attribute_index).horizontal_alignment ||
              ' valign=bottom><a href="javascript:check_all()"><font class=promptwhite>' ||
              ak_query_pkg.g_items_table(l_attribute_index).attribute_label_long || '</A></font></TD>');

      END IF;

    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

  END LOOP;

  htp.p('</TR>');

END PrintResultHeadings;

PROCEDURE PrintAvailableShipment(p_result_index NUMBER,
                                 p_current_row  NUMBER) IS

  l_attribute_index   NUMBER := ak_query_pkg.g_items_table.FIRST;
  l_current_col       NUMBER := 0;

BEGIN

  WHILE (l_attribute_index IS NOT NULL) LOOP

    if (ak_query_pkg.g_items_table(l_attribute_index).node_query_flag = 'Y') then

      l_current_col := l_current_col + 1;

    end if;

    IF (ak_query_pkg.g_items_table(l_attribute_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_attribute_index).secured_column = 'F') THEN

      IF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'CHECKBOX') THEN

          htp.p('</TD><TD align=center><input name="' || ak_query_pkg.g_items_table(l_attribute_index).attribute_code || '" type="checkbox" value="' || to_char(p_current_row) || '">');

      ELSIF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'HIDDEN') THEN

null;

          htp.p('<INPUT NAME="' || ak_query_pkg.g_items_table(l_attribute_index).attribute_code ||
                '" TYPE="HIDDEN" VALUE="' || get_result_value(p_result_index, l_current_col) || '">');

      ELSIF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'TEXT') THEN

          if ak_query_pkg.g_items_table(l_attribute_index).attribute_code = 'POS_ITEM_DESCRIPTION' then

              htp.p('</TD><TD width=1000><font class=tabledata>' ||
                    nvl(get_result_value(p_result_index, l_current_col), '`&nbsp') || '</font>');

         else

              htp.p('</TD><TD><font class=tabledata>' ||
                    nvl(get_result_value(p_result_index, l_current_col), '`&nbsp') || '</font>');

         end if;

      END IF;

    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

  END LOOP;

END PrintAvailableShipment;

PROCEDURE PrintSelectedShipment(p_result_index NUMBER,
                                p_current_row  NUMBER) IS

  l_attribute_index   NUMBER := ak_query_pkg.g_items_table.FIRST;
  l_current_col       NUMBER := 0;

BEGIN

  WHILE (l_attribute_index IS NOT NULL) LOOP

    if (ak_query_pkg.g_items_table(l_attribute_index).node_query_flag = 'Y') then

      l_current_col := l_current_col + 1;

    end if;

    IF (ak_query_pkg.g_items_table(l_attribute_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_attribute_index).secured_column = 'F') THEN

      IF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'CHECKBOX') THEN

          htp.p('</TD><TD align=center valign=middle><img src=/OA_MEDIA/POSCHECK.gif align=center valign=middle>');

      ELSIF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'HIDDEN') THEN

          htp.p('<INPUT NAME="' || ak_query_pkg.g_items_table(l_attribute_index).attribute_code ||
                '" TYPE="HIDDEN" VALUE="' || get_result_value(p_result_index, l_current_col) || '">');

      ELSIF (ak_query_pkg.g_items_table(l_attribute_index).item_style = 'TEXT') THEN

         if ak_query_pkg.g_items_table(l_attribute_index).attribute_code = 'POS_ITEM_DESCRIPTION' then

              htp.p('</TD><TD width=1000><font class=tabledata>' ||
                    nvl(get_result_value(p_result_index, l_current_col), '`&nbsp') || '</font>');

         else

              htp.p('</TD><TD><font class=tabledata>' ||
                    nvl(get_result_value(p_result_index, l_current_col), '`&nbsp') || '</font>');

         end if;

      END IF;

    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

  END LOOP;

  htp.p('</TD>');

END PrintSelectedShipment;

procedure button(src IN varchar2,
                 txt IN varchar2) IS

BEGIN

htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src || '"><font class=button>'|| txt || '</font></a></td>
          </tr>
          <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
          <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
         </table>
');

END button;

function get_result_value(p_index in number, p_col in number) return varchar2 is
    sql_statement  VARCHAR2(300);
    l_cursor       NUMBER;
    l_execute      NUMBER;
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

PROCEDURE SetAttributeTable(pos_vendor_site_id   IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL
) IS

BEGIN
  IF (g_attribute_table.COUNT > 0) THEN
    g_attribute_table.DELETE;
  END IF;
  g_attribute_table(1).attribute_name := 'POS_VENDOR_SITE_ID';
  g_attribute_table(1).attribute_value := pos_vendor_site_id;
  g_attribute_table(2).attribute_name := 'POS_VENDOR_SITE_NAME';
  g_attribute_table(2).attribute_value := pos_vendor_site_name;
  g_attribute_table(3).attribute_name := 'POS_SHIP_TO_LOCATION_ID';
  g_attribute_table(3).attribute_value := pos_ship_to_location_id;
  g_attribute_table(4).attribute_name := 'POS_SHIP_TO_LOCATION';
  g_attribute_table(4).attribute_value := pos_ship_to_location;
  g_attribute_table(5).attribute_name := 'POS_SUPPLIER_ITEM_NUMBER';
  g_attribute_table(5).attribute_value := pos_supplier_item_number;
  g_attribute_table(6).attribute_name := 'POS_ITEM_DESCRIPTION';
  g_attribute_table(6).attribute_value := pos_item_description;
  g_attribute_table(7).attribute_name := 'POS_PO_NUMBER';
  g_attribute_table(7).attribute_value := pos_po_number;
  g_attribute_table(8).attribute_name := 'POS_ITEM_NUMBER';
  g_attribute_table(8).attribute_value := pos_item_number;
  g_attribute_table(9).attribute_name := 'POS_DATE_START';
  g_attribute_table(9).attribute_value := pos_date_start;
  g_attribute_table(10).attribute_name := 'POS_DATE_END';
  g_attribute_table(10).attribute_value := pos_date_end;

END SetAttributeTable;

FUNCTION GetAttributeValue(p_attribute_name  IN VARCHAR2,
                           p_start_index     IN NUMBER) RETURN VARCHAR2 IS
  l_start_index NUMBER;
  l_index NUMBER;
  l_wrapped BOOLEAN;
BEGIN
  IF (p_attribute_name IS NULL OR g_attribute_table.COUNT <= 0) THEN
    RETURN NULL;
  END IF;
  l_start_index := NVL(p_start_index, g_attribute_table.FIRST);
  IF (g_attribute_table.EXISTS(p_start_index) AND
      g_attribute_table(p_start_index).attribute_name = p_attribute_name) THEN
    RETURN g_attribute_table(p_start_index).attribute_value;
  END IF;
  l_index := g_attribute_table.NEXT(p_start_index);
  l_wrapped := FALSE;
  WHILE (l_index IS NOT NULL AND NOT (l_wrapped AND l_index >= p_start_index)) LOOP
    IF (g_attribute_table(l_index).attribute_name = p_attribute_name) THEN
      RETURN g_attribute_table(p_start_index).attribute_value;
    END IF;

    l_index := g_attribute_table.NEXT(l_index);
    IF (l_index IS NULL) THEN
      l_index := g_attribute_table.FIRST;
      l_wrapped := TRUE;
    END IF;
  END LOOP;

  RETURN NULL;

END GetAttributeValue;

function GetRequiredFlag(p_attribute_code IN VARCHAR2) return varchar2 is

  l_required_flag varchar2(1);

begin

  select REQUIRED_FLAG
    into l_required_flag
    from ak_region_items
   where REGION_CODE = 'POS_ASN_SEARCH_R'
     and ATTRIBUTE_CODE = p_attribute_code;

  return(l_required_flag);

exception

  when others then
    return('N');

end;

END pos_asn_search_pkg;

/
