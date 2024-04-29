--------------------------------------------------------
--  DDL for Package Body ICX_REQ_COPY_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_COPY_REQ" AS
/* $Header: ICXRQCPB.pls 115.3 99/07/17 03:23:02 porting shi $ */

------------------------------------------------------
PROCEDURE welcome_page IS

    v_lang               varchar2(5);
    c_title              varchar2(80);
    c_prompts            icx_util.g_prompts_table;
    v_dcdName            varchar2(1000);
    v_message_caption    varchar2(200);
    v_message_text       varchar2(1000);
    v_0_encrypt		 varchar2(100);

BEGIN

  -- Check if session is valid
  IF (icx_sec.validatesession('ICX_REQS_COPY_REQ')) THEN

   -- get dcd name
   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

   -- set lang code
   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

   -- encrypt 0
   v_0_encrypt := icx_call.encrypt2('0');

  -- Create the Intro Page


  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_INTRO_TITLE');
  c_title := FND_MESSAGE.GET;

  htp.htmlOpen;
  htp.title(c_title);
  htp.bodyOpen;

  htp.headOpen;

  icx_util.copyright;

  js.scriptOpen;

  htp.p('function help_window(){
        help_win = window.open(''/OA_DOC/' || v_lang || '/awe' ||  '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250");
        help_win = window.open(''/OA_DOC/' || v_lang || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250")
}
');

  js.scriptClose;
  htp.headClose;

  -- TOOLBAR
  icx_admin_sig.toolbar(language_code => v_lang);

  htp.p('<table border=0 cellpadding=0><tr>');
  htp.p('<td width=2000 bgcolor=#0000ff height=4><img src=/OA_MEDIA/'||
        v_lang || '/FNDDBPX6.gif height=1 width=1></td></tr></table>');

  htp.p('<table cellspacing=8 cellpadding=0 border=0>');
  htp.p('<tr><td colspan=3>');

  -- The top intro line of the page
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_INTRO_TXT');
  htp.p(FND_MESSAGE.GET || '<p>');
  htp.p('</font></td></tr><tr><td colspan=3>');

  -- The First line of the intro
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_COPY_ITEMS_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_COPY_ITEMS_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><a href=' || v_dcdName ||
        '/ICX_REQ_COPY_REQ.find_reqs' ||
	'>' || '<img src=/OA_MEDIA/' || v_lang ||
        '/FNDICPY.gif border=no height=75 width=75 align=absmiddle></a></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIBLBR.gif width=500 height=4></td></tr><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#0000ff>' ||
        '<b>1</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color=#0000ff>' ||
        v_message_caption || '</b></font><br>' || v_message_text ||
        '</td></td></tr></table>');

  -- Second line
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_CHK_ORDER_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_CHK_ORDER_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('</td></tr><tr>');
  htp.p('<td rowspan=2><font size=7>&nbsp</td>');
  htp.p('<td colspan=2>');
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><img src=/OA_MEDIA/' || v_lang ||
        '/FNDICKO.gif height=75 width=75 align = absmiddle></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIRDBR.gif width=500 height=4></td><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#cc0000>' ||
        '<b>2</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color="#CC0000">' ||
        v_message_caption || '</b></font><br>' || v_message_text || '</td>' ||
        '</tr></table>');

  -- Third line
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PLACE_ORDER_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PLACE_ORDER_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('</td></tr><tr>');
  htp.p('<td rowspan=2><font size=7>&nbsp</td>');
  htp.p('<td colspan=1>');
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIPLO.gif height=75 width=75 align = absmiddle></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIGRBR.gif width=500 height=4></td><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#006666>' ||
        '<b>3</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color="#006666">' ||
        v_message_caption || '</b></font><br>' || v_message_text ||
        '<br></td>' || '</tr></table>');

  htp.p('</td></tr></table>');

  htp.p('<center>');
  htp.anchor(v_dcdName || '/ICX_REQ_COPY_REQ.find_reqs',
	     htf.img('/OA_MEDIA/' || v_lang ||
	     '/FNDICPYS.gif', cattributes => 'BORDER = NO align=absmiddle' ));
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PROCEED_TO_COPY');
  htp.p('<FONT SIZE=+1>');
  htp.anchor(v_dcdName || '/ICX_REQ_COPY_REQ.find_reqs', FND_MESSAGE.GET);
  htp.p('</FONT>');
  htp.p('</center>');

  htp.bodyClose;
  htp.htmlClose;

 END IF; /* validate session */

END welcome_page;

-------------------------------------------------
PROCEDURE find_reqs IS

  v_help_url      VARCHAR2(2000) := NULL;
  v_language_code VARCHAR2(30) := NULL;

BEGIN
  IF icx_sec.validateSession('ICX_REQS_COPY_REQ') THEN

    v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    v_help_url := '/OA_DOC/' || v_language_code ||'/awe' ||  '/icxhlprq.htm';

    -- Call the Findpage function to paint the find page. (AK flow)

    icx_on_utilities.FindPage(p_flow_appl_id => '',
                              p_flow_code => '',
                              p_page_appl_id => '',
                              p_page_code => '',
                              p_region_appl_id => 178,
                              p_region_code => 'ICX_PO_REQ_HEAD_SUM_R',
                              p_goto_url => 'icx_req_copy_req.display_reqs',
                              p_lines_now => 1,
                              p_lines_url => '',
                              p_lines_next => 5,
                              p_hidden_name => '',
                              p_hidden_value => '',
                              p_help_url => v_help_url,
                              p_new_url => '');



  END IF; /* validate session */

END find_reqs;


----------------------------------------------------
PROCEDURE display_reqs (a_1 IN VARCHAR2 DEFAULT NULL,
                        c_1 IN VARCHAR2 DEFAULT NULL,
                        i_1 IN VARCHAR2 DEFAULT NULL,
                        a_2 IN VARCHAR2 DEFAULT NULL,
                        c_2 IN VARCHAR2 DEFAULT NULL,
                        i_2 IN VARCHAR2 DEFAULT NULL,
                        a_3 IN VARCHAR2 DEFAULT NULL,
                        c_3 IN VARCHAR2 DEFAULT NULL,
                        i_3 IN VARCHAR2 DEFAULT NULL,
                        a_4 IN VARCHAR2 DEFAULT NULL,
                        c_4 IN VARCHAR2 DEFAULT NULL,
                        i_4 IN VARCHAR2 DEFAULT NULL,
                        a_5 IN VARCHAR2 DEFAULT NULL,
                        c_5 IN VARCHAR2 DEFAULT NULL,
                        i_5 IN VARCHAR2 DEFAULT NULL,
                        m   IN VARCHAR2 DEFAULT NULL,
			o   IN VARCHAR2 DEFAULT 'AND',
                        p_start_row IN NUMBER DEFAULT 1,
                        p_end_row IN NUMBER DEFAULT NULL,
                        p_where IN NUMBER DEFAULT NULL) IS

 v_req_header_id    NUMBER := NULL;
 v_dcd_name         VARCHAR2(200) := NULL;
 v_where_clause     VARCHAR2(2000) := NULL;
 v_total_rows       NUMBER := 0;
 v_query_size       NUMBER := 0;
 v_help_url         VARCHAR2(2000) := NULL;
 v_language_code    VARCHAR2(30) := NULL;
 v_session_id       NUMBER := NULL;
 v_end_row          NUMBER := 0;
 v_encrypted_where  NUMBER := NULL;
 v_param            VARCHAR2(240) := NULL;
 y_table            icx_util.char240_table;
 v_row_id           VARCHAR2(25) := NULL;

 l_message               VARCHAR2(2000) := NULL;
 l_err_num               NUMBER := 0;
 l_err_mesg              VARCHAR2(240) := NULL;
 l_web_user_date_format  VARCHAR2(240) := NULL;

/* New vars to use the Bind vars logic **/
 l_where_binds  ak_query_pkg.bind_tab;
 l_where_clause varchar2(2000);


BEGIN

 IF icx_sec.validateSession('ICX_REQS_COPY_REQ') THEN

   v_dcd_name := owa_util.get_cgi_env('SCRIPT_NAME');
   v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   v_help_url := '/OA_DOC/' || v_language_code || '/awe' || '/icxhlprq.htm';
   v_session_id := to_number(icx_sec.getID(icx_sec.PV_SESSION_ID));

   select  rowidtochar(ROWID)
   into    v_row_id
   from    AK_FLOW_REGION_RELATIONS
   where   FROM_REGION_CODE = 'ICX_PO_REQ_HEAD_SUM_R'
   and     FROM_REGION_APPL_ID = 178
   and     FROM_PAGE_CODE = 'ICX_REQS_HEADER'
   and     FROM_PAGE_APPL_ID = 178
   and     TO_PAGE_CODE = 'ICX_REQS_DETAILS'
   and     TO_PAGE_APPL_ID = 178
   and     FLOW_CODE = 'ICX_COPY_REQS'
   and     FLOW_APPLICATION_ID = 178;

   if p_where IS NOT NULL THEN
     v_where_clause := icx_call.decrypt2(p_where);
   ELSE
     -- generate the where clause
     v_where_clause := icx_on_utilities.whereSegment(a_1, c_1, i_1,
                                                     a_2, c_2, i_2,
                                                     a_3, c_3, i_3,
                                                     a_4, c_4, i_4,
                                                     a_5, c_5, i_5,
                                                     m,o);



   END IF; /* IF p_where */



   v_encrypted_where := icx_call.encrypt2(v_where_clause);

   -- get number of rows to display
   SELECT  query_set
   INTO    v_query_size
   FROM    icx_parameters;

   -- Find the end rows for display
   IF p_end_row IS NULL THEN
      v_end_row := v_query_size;
   ELSE
      v_end_row := p_end_row;
   END IF;

    /* added to take care of Bind vars Bug **/

    icx_on_utilities.unpack_whereSegment(v_where_clause, l_where_clause, l_where_binds);

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 178,
                           P_PARENT_REGION_CODE    => 'ICX_PO_REQ_HEAD_SUM_R',
                           P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                           P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           P_WHERE_CLAUSE          => l_where_clause,
                           P_RETURN_PARENTS        => 'T',
                           P_RETURN_CHILDREN       => 'F',
                           P_WHERE_BINDS           => l_where_binds );

   -- test - dump the plsql tables for debug purpose only!
   -- icx_on_utilities2.printPLSQLtables;

   -- get the total number of rows
   v_total_rows := ak_query_pkg.g_results_table.count;

   IF v_end_row > v_total_rows THEN
     v_end_row := v_total_rows;
   END IF;

   IF v_total_rows = 0 THEN
      htp.htmlOpen;
      htp.headOpen;
      icx_util.copyright;
      js.scriptOpen;
      icx_admin_sig.help_win_script(v_help_url, v_language_code);
      js.scriptClose;
      htp.title(ak_query_pkg.g_regions_table(0).name);
      htp.headClose;

      icx_admin_sig.toolbar(language_code => v_language_code,
                            disp_find => 'icx_req_copy_req.find_reqs');

      fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
      fnd_message.set_token('NAME_OF_REGION_TOKEN',ak_query_pkg.g_regions_table(0).name);
      htp.br;
      htp.tableOpen('BORDER=0');
      htp.tableRowOpen;
      htp.tableData(cvalue => '<B><FONT size=+1>'||fnd_message.get||'</FONT></B>',cattributes => 'VALIGN="MIDDLE"');
      htp.tableClose;
      htp.br;
      icx_admin_sig.footer;

   ELSE
      htp.htmlOpen;
      htp.headOpen;
      icx_util.copyright;

      js.scriptOpen;
      icx_admin_sig.help_win_script(v_help_url, v_language_code);
      js.scriptClose;

      htp.title(ak_query_pkg.g_regions_table(0).name);
      htp.headClose;

      icx_admin_sig.toolbar(language_code => v_language_code,
                            disp_find => 'icx_req_copy_req.find_reqs');


      htp.p('<FORM ACTION="' || v_dcd_name || '/icx_req_copy_req.copy_req"  NAME="DISPLAY_COPY_REQS" METHOD="POST">');


      -- Display Heading
      htp.tableOpen('BORDER=0');
      htp.tableRowOpen;
      htp.tableData(cvalue => '<B><FONT size=+2>'
		    || ak_query_pkg.g_regions_table(0).name
		    || '</FONT></B>',cattributes => 'VALIGN="MIDDLE"');
      htp.tableRowClose;
      htp.tableClose;
      htp.br;

      IF(v_total_rows > 5)
	THEN
	 icx_on_utilities2.displaySetIcons(v_language_code,
					   'icx_req_copy_req.display_reqs',
					   p_start_row,
					   v_end_row,
					   v_encrypted_where,
					   v_query_size,
					   v_total_rows);
	 htp.br;
      END IF; /* (v_total_rows > 5) */

      -- Print table header
      htp.tableOpen('BORDER=2','','','', 'CELLPADDING=2');
      htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER')||'">');

      FOR i IN ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST LOOP
        IF ak_query_pkg.g_items_table(i).secured_column = 'F'
           AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y' THEN

           htp.p('<TH><FONT COLOR=''#' || icx_util.get_color('TABLE_HEADER_TEXT') ||'''>' || ak_query_pkg.g_items_table(i).attribute_label_long);
           htp.p('</FONT></TH>');

        END IF; /* if ak_query_pkg.... */

      END LOOP;
      htp.tableRowClose;
      htp.tableData(''); -- ?

      -- FOR r IN ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST LOOP
      FOR r IN p_start_row -1..v_end_row - 1 LOOP
       icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),y_table);

       htp.tableRowOpen;

       FOR i IN ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST LOOP
       IF (ak_query_pkg.g_items_table(i).secured_column = 'F'
         AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y')
         OR (ak_query_pkg.g_items_table(i).item_style = 'HIDDEN'
             AND ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_HEADER_ID') THEN
           IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_HEADER_ID' THEN
             v_req_header_id := y_table(ak_query_pkg.g_items_table(i).value_id);

             -- Build the parameter to jump into AK flow from here
             v_param := 'D*****1****' || v_row_id || '*ICX_PO_REQ_HEADER_PK*' || v_req_header_id || '**]';
           ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_REQ_NUM' THEN
              htp.tableData(htf.anchor('oracleON.IC?Y='|| icx_call.encrypt2(v_param), y_table(ak_query_pkg.g_items_table(i).value_id),'','onMouseOver="return true"'));

           ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_COPY' THEN

              htp.tableData(htf.anchor('icx_req_copy_req.copy_req?v_req_header_id='|| icx_call.encrypt2(v_req_header_id), htf.img('/OA_MEDIA/' || v_language_code || '/FNDISPLT.gif', 'CENTER', '', '', 'BORDER=NO WIDTH=20 HEIGHT=20')));

           ELSE
             IF (y_table(ak_query_pkg.g_items_table(i).value_id)) IS NULL THEN
               htp.tableData('&nbsp');
             ELSE
               htp.tableData(y_table(ak_query_pkg.g_items_table(i).value_id));
             END IF;
           END IF; /* ... ICX_REQ_NUM */
       END IF; /* secured_column = 'F'... */

       END LOOP;

       htp.tableRowClose;

      END LOOP;

      htp.tableClose;

      htp.br;

      IF(v_total_rows > 5)
	THEN
	 icx_on_utilities2.displaySetIcons(v_language_code,
					   'icx_req_copy_req.display_reqs',
					   p_start_row,
					   v_end_row,
					   v_encrypted_where,
					   v_query_size,
					   v_total_rows);
      END IF; /* (v_total_rows > 5) */

	 htp.formClose;
      icx_admin_sig.footer;

   END IF; /* v_total_rows = 0 */

 END IF; /* validate session */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in display reqs ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;

    l_err_num := SQLCODE;
    l_message := SQLERRM;
    select substr(l_message,12,512) into l_err_mesg from dual;
    if (abs(l_err_num) between 1800 and 1899)
    then
        fnd_message.set_name('ICX','ICX_USE_DATE_FORMAT');
        l_web_user_date_format := icx_sec.getID(icx_sec.pv_date_format);
        fnd_message.set_token('FORMAT_MASK_TOKEN',nvl(l_web_user_date_format,'DD-MON-YYYY'));
        l_message := l_err_mesg||'<br>'||fnd_message.get;
        icx_util.add_error(l_message) ;
        icx_admin_sig.error_screen(l_err_mesg);
    else
	icx_util.add_error(l_err_mesg);
	icx_admin_sig.error_screen(l_err_mesg);
    end if;

END display_reqs;

------------------------------------------------------
PROCEDURE copy_req (v_req_header_id IN NUMBER) IS

l_req_header_id       NUMBER := NULL;
v_org_id              NUMBER := NULL;
v_shopper_id          NUMBER := NULL;
v_int_contact_name    VARCHAR2(250) := NULL;
v_int_contact_id      NUMBER := NULL;
v_destination_org_id  NUMBER := NULL;
v_org_code            VARCHAR2(30) := NULL;
v_deliver_to_loc_id   NUMBER := NULL;
v_deliver_to_location VARCHAR2(500) := NULL;
v_dest_type_code      VARCHAR2(30) := NULL;
v_note_to_buyer       VARCHAR2(240) := NULL;
v_need_by_date        DATE := NULL;
v_requisition_num     NUMBER := NULL;
v_cart_id             NUMBER := NULL;
v_distribution_id     NUMBER := NULL;
v_cart_line_id        NUMBER := NULL;
v_cart_line_number    NUMBER := NULL;
v_dist_num            NUMBER := NULL;

v_dcd_name            VARCHAR2(1000) := NULL;
v_language            VARCHAR2(30) := NULL;

--add by alex
pk1 		      VARCHAR2(30);
pk2		      VARCHAR2(30);
--

  CURSOR getDate(increment NUMBER) IS
      SELECT SYSDATE + increment
      FROM SYS.DUAL;

  cursor reqlines(reqheader number) IS
     SELECT requisition_line_id
     FROM po_requisition_lines
     WHERE requisition_header_id = reqheader
     ORDER BY line_num;

  cursor reqdistributions(l_cart_id number, l_cart_line_id number) IS
     SELECT distribution_id, charge_account_id
     FROM icx_cart_line_distributions
     WHERE cart_id = l_cart_id
     AND   cart_line_id = l_cart_line_id;


BEGIN
  IF (icx_sec.validatesession('ICX_REQS_COPY_REQ')) THEN

    -- Get dcd path
    v_dcd_name := owa_util.get_cgi_env('SCRIPT_NAME');
    -- Get language code
    v_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    l_req_header_id := icx_call.decrypt2(v_req_header_id);

    -- Get organization id
    v_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
    -- get shopper id
    v_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
    -- get employee_id ( Internal Contect ID )
    v_int_contact_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);

    -- Get deliver to location etc.,
    ICX_REQ_NAVIGATION.shopper_info(v_int_contact_id, v_int_contact_name,
                                    v_deliver_to_loc_id, v_deliver_to_location,
                                    v_destination_org_id, v_org_code);

    OPEN  getDate (nvl(icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY), 0));
    FETCH getDate into v_need_by_date;
    CLOSE getDate;

    SELECT note_to_agent
    INTO v_note_to_buyer
    FROM po_requisition_lines
    WHERE requisition_header_id = l_req_header_id
    AND rownum = 1;


    -- Get  a new Requisition number
    SELECT to_char(current_max_unique_identifier + 1)
    INTO   v_requisition_num
    FROM   po_unique_identifier_control
    WHERE  table_name = 'PO_REQUISITION_HEADERS'
    FOR UPDATE OF current_max_unique_identifier;

    UPDATE po_unique_identifier_control
    SET    current_max_unique_identifier = current_max_unique_identifier + 1
    WHERE  table_name = 'PO_REQUISITION_HEADERS';

    COMMIT; /* avoid locking problem (?!) */

--changed by alex for attachment
--    SELECT icx_shopping_carts_s.NEXTVAL
--    INTO v_cart_id
--    FROM SYS.DUAL;
--new code:
    SELECT PO_REQUISITION_HEADERS_S.NEXTVAL
    INTO v_cart_id
    FROM SYS.DUAL;

-- The reserve_po_num column is now updated to NULL from the earlier
-- value of attribute7.
    INSERT INTO icx_shopping_carts (
        cart_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        shopper_id,
        deliver_to_requestor_id,
        need_by_date,
        destination_type_code,
        destination_organization_id,
        deliver_to_location_id,
        note_to_approver,
        note_to_buyer,
        saved_flag,
        req_number_segment1,
        approver_id,
        approver_name,
        header_description,
        header_attribute_category,
        reserved_po_num,
        header_attribute1,
        header_attribute2,
        header_attribute3,
        header_attribute4,
        header_attribute5,
        header_attribute6,
        header_attribute7,
        header_attribute8,
        header_attribute9,
        header_attribute10,
        header_attribute11,
        header_attribute12,
        header_attribute13,
        header_attribute14,
        header_attribute15,
        deliver_to_location,
	deliver_to_requestor,
        org_id
        )
    SELECT
        v_cart_id,
        sysdate,
        v_shopper_id,
        sysdate,
        v_shopper_id,
        v_shopper_id,
        v_int_contact_id,
        v_need_by_date,
        'EXPENSE',
        v_destination_org_id,
        v_deliver_to_loc_id,
        note_to_authorizer,
        v_note_to_buyer,
        1,
        v_requisition_num,
        NULL,
        NULL,
        description,
        attribute_category,
        NULL,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        v_deliver_to_location,
        v_int_contact_name,
        v_org_id
    FROM po_requisition_headers
    WHERE requisition_header_id = l_req_header_id;

--add by alex
--copy attachment for the header
    fnd_attached_documents2_pkg.copy_attachments('REQ_HEADERS',
						 l_req_header_id,
						 '',
						 '',
						 '',
						 '',
						 'REQ_HEADERS',
						 v_cart_id,
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '');

    -- Create cart distributions
    SELECT icx_cart_distributions_s.nextval
    INTO v_distribution_id
    FROM SYS.DUAL;

    INSERT INTO icx_cart_distributions (
        cart_id,
        distribution_id,
        last_updated_by,
        last_update_date,
        last_update_login,
        creation_date,
        created_by,
        org_id)
    VALUES (
        v_cart_id,
        v_distribution_id,
        v_shopper_id,
        sysdate,
        v_shopper_id,
        sysdate,
        v_shopper_id,
        v_org_id);


    v_cart_line_number := 0;

    FOR prec IN reqlines(l_req_header_id) LOOP

      v_cart_line_number := v_cart_line_number + 1;

--changed by alex for attachment
--      SELECT icx_shopping_cart_lines_s.NEXTVAL
--      INTO v_cart_line_id
--      FROM DUAL;
--new code:
      SELECT PO_REQUISITION_LINES_S.NEXTVAL
      INTO v_cart_line_id
      FROM DUAL;


      INSERT INTO icx_shopping_cart_lines (
        cart_line_id,
	cart_line_number,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        cart_id,
        item_id,
        item_revision,
        unit_of_measure,
        quantity,
        unit_price,
        suggested_vendor_item_num,
        category_id,
        line_type_id,
        item_description,
        suggested_vendor_name,
        suggested_vendor_site,
        destination_organization_id,
        deliver_to_location_id,
        autosource_doc_header_id,
        autosource_doc_line_num,
        line_id,
        line_attribute_category,
        line_attribute1,
        line_attribute2,
        line_attribute3,
        line_attribute4,
        line_attribute5,
        line_attribute6,
        line_attribute7,
        line_attribute8,
        line_attribute9,
        line_attribute10,
        line_attribute11,
        line_attribute12,
        line_attribute13,
        line_attribute14,
        line_attribute15,
        need_by_date,
        custom_defaulted,
        deliver_to_location,
        org_id
        ) select
        v_cart_line_id,
        v_cart_line_number,
        sysdate,
        v_shopper_id,
        sysdate,
        v_shopper_id,
        v_cart_id,
        rl.item_id,
        rl.item_revision,
        rl.unit_meas_lookup_code,
        rl.quantity,
        rl.unit_price,
        rl.suggested_vendor_product_code,
        rl.category_id,
        rl.line_type_id,
        rl.item_description,
        rl.suggested_vendor_name,
        rl.suggested_vendor_location,
        v_destination_org_id,
        v_deliver_to_loc_id,
        rl.blanket_po_header_id,
        rl.blanket_po_line_num,
        -999,
        rl.attribute_category,
        rl.attribute1,
        rl.attribute2,
        rl.attribute3,
        rl.attribute4,
        rl.attribute5,
        rl.attribute6,
        rl.attribute7,
        rl.attribute8,
        rl.attribute9,
        rl.attribute10,
        rl.attribute11,
        rl.attribute12,
        rl.attribute13,
        rl.attribute14,
        rl.attribute15,
        v_need_by_date,
        'N',
        v_deliver_to_location,
        v_org_id
     FROM po_requisition_lines rl
     WHERE rl.requisition_header_id = l_req_header_id
     AND   rl.requisition_line_id = prec.requisition_line_id;

--add by alex
--copy attachment for the header
    fnd_attached_documents2_pkg.copy_attachments('REQ_LINES',
						 prec.requisition_line_id,
						 '',
						 '',
						 '',
						 '',
						 'REQ_LINES',
						 v_cart_line_id,
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '');


     -- Create multiple line distributions
     INSERT INTO icx_cart_line_distributions
     (cart_line_id,
      cart_id,
      distribution_id,
      last_updated_by,
      last_update_date,
      last_update_login,
      creation_date,
      created_by,
      charge_account_id,
      accrual_account_id,
      variance_account_id,
      budget_account_id,
      org_id,
      allocation_type,
      allocation_value,
      allocation_quantity)
      SELECT v_cart_line_id,
      v_cart_id,
      icx_cart_line_distributions_s.nextval,
      v_shopper_id,
      sysdate,
      v_shopper_id,
      sysdate,
      v_shopper_id,
      rd.code_combination_id,
      rd.accrual_account_id,
      rd.variance_account_id,
      rd.budget_account_id,
      v_org_id,
      nvl(rd.allocation_type, 'PERCENT'),
      nvl(rd.allocation_value, round(rd.req_line_quantity / rl.quantity * 100, 5)),
      rd.req_line_quantity
      FROM po_req_distributions rd,
           po_requisition_lines rl
      WHERE rd.requisition_line_id = prec.requisition_line_id
      AND rl.requisition_header_id = l_req_header_id
      AND rl.requisition_line_id = rd.requisition_line_id;


      -- Update the distribution num column in distributions table.
      -- This is required as the view  of ICX_SHOPPING_CART_LINES_V has
      -- join condition as DISTRIBUTION_NUM = 1.
      -- The reqs from sources other than web reqs may not have populated
      -- the distribuion number.

      v_dist_num := 1;

      FOR distribution IN reqdistributions(v_cart_id, v_cart_line_id) LOOP

        UPDATE icx_cart_line_distributions
        SET distribution_num = v_dist_num
        WHERE cart_id = v_cart_id
        AND   cart_line_id = v_cart_line_id
        AND   distribution_id = distribution.distribution_id;

        -- Update the invidual segments from the account id.
        -- This need to done because the invidual segments are not
        -- available from po_req_distributions table.
        icx_req_acct2.update_account_by_id( v_cart_id => v_cart_id,
                                            v_cart_line_id => v_cart_line_id,
                                            v_oo_id => v_org_id,
                                            v_distribution_id => distribution.distribution_id,
                                            v_line_number => v_dist_num);

        v_dist_num := v_dist_num + 1;

      END LOOP; /* FOR distribution */

    END LOOP; /* FOR prec ... */

    UPDATE icx_shopping_cart_lines b
    SET item_number = ( SELECT a.concatenated_segments
                        FROM mtl_system_items_kfv a
                        WHERE a.inventory_item_id = b.item_id
                        AND a.organization_id = b.destination_organization_id
                        AND b.cart_id = v_cart_id
                        AND b.item_id IS NOT NULL)
    WHERE cart_id = v_cart_id;


    /* Call custom defaults */
    icx_req_custom.reqs_default_lines('NO', v_cart_id);

    COMMIT; /* release locks */

    /* display the req in my order page */
    icx_req_navigation.ic_parent(icx_call.encrypt2(to_char(v_cart_id)));

  END IF; /* validate session */


EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in copy req ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END copy_req;

END icx_req_copy_req;

/
