--------------------------------------------------------
--  DDL for Package Body POS_ASBN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASBN" AS
/* $Header: POSASBNB.pls 115.3.1156.1 2001/08/27 16:39:15 pkm ship  $ */

  /* Build_Buttons
   * ------------
   */

  PROCEDURE Build_Buttons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2)
  IS
  BEGIN

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.headOpen;
    htp.headClose;
    htp.bodyOpen(NULL, 'bgcolor=#336699');

    htp.p('
      <table width=100% bgcolor=#336699 cellpadding=0 cellspacing=0 border=0>
      <tr><td height=3><img src=/OA_MEDIA/FNDPX3.gif></td></tr>
      <TR>
      <TD align=right>');

    -- This is a button table containing 3 buttons.
    -- The first row defines the edges and tops
    htp.p('
      <table cellpadding=0 cellspacing=0 border=0>
      <tr>
      <!-- left hand button, round left side and square right side-->
      <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>
      <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
      <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');

    htp.p('<!-- standard spacer between square button images-->
           <td width=2 rowspan=5></td>');

    IF (p_button2Name is NOT NULL) THEN
      htp.p('
         <!-- middle button with squared ends on both left and right-->
         <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>
         <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
         <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>
         <!-- standard spacer between square button images-->
         <td width=2 rowspan=5></td>');
    ELSE
      htp.p('
         <!-- middle button with squared ends on both left and right-->
         <td rowspan=5></td>
         <td></td>
         <td rowspan=5></td>
         <!-- standard spacer between square button images-->
         <td width=2 rowspan=5></td>');
    END IF;

    htp.p('
      <!-- right hand button, square left side and round right side-->
      <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>
      <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
      <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>
      <td width=10 rowspan=5></td>
      </tr>
      <tr>');

    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    htp.p('</tr>');
    htp.p('<tr>');

    htp.p('<!-- Text and links for each button are listed here-->');
    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.getTop().' || p_button1Function || ';">');
    htp.p('<font class=button>');
    htp.p('<SCRIPT>');
    htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
          p_button1Name || '"])');
    htp.p('</SCRIPT></font></td>');


    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#cccccc height=20 nowrap>');
      htp.p('<a href="javascript:top.getTop().' || p_button2Function || ';">');
      htp.p('<font class=button>');
      htp.p('<SCRIPT>');
      htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
             p_button2Name || '"])');
      htp.p('</SCRIPT></font></td>');
    ELSE
      htp.p('<td></td>');
    END IF;

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.getTop().' || p_button3Function || ';">');
    htp.p('<font class=button>');
    htp.p('<SCRIPT>');
    htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
          p_button3Name || '"])');
    htp.p('</SCRIPT></font></td>');

    htp.p('
      </tr>
      <tr>');

    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('</tr>');

    htp.p('<tr>');
    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('</tr>');

    htp.p('</table>');

    htp.p('
      </td>
      </tr>
      <TR><td height=30><img src=/OA_MEDIA/FNDPX3.gif></td></TR>
      </table>
      </body>
      </html>
      ');

  END Build_Buttons;



FUNCTION item_halign(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ' align=' ||
           ak_query_pkg.g_items_table(l_index).horizontal_alignment;

END item_halign;


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

FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' maxlength=' ||
         to_char(ak_query_pkg.g_items_table(l_index).attribute_value_length);

END item_maxlength;


FUNCTION item_size (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' size='  || to_char(ak_query_pkg.g_items_table(l_index).display_value_length);

END item_size;

FUNCTION set_session_info RETURN BOOLEAN is
BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN FALSE;
  END IF;

  POS_ASBN.g_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  POS_ASBN.g_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  POS_ASBN.g_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  POS_ASBN.g_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  POS_ASBN.g_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  POS_ASBN.g_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  fnd_client_info.set_org_context(g_org_id);

  RETURN TRUE;

END set_session_info;


function get_result_value(p_index in number, p_col in number) return varchar2 is
    sql_statement   VARCHAR2(300);
    l_cursor       INTEGER;
    l_execute      INTEGER;
    l_result       VARCHAR2(2000);
BEGIN

  if ak_query_pkg.g_results_table.count = 0 then
	 return '';
  end if;
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

PROCEDURE ASBN_Details IS
BEGIN

	IF NOT set_session_info THEN
		RETURN;
	END IF;


     htp.htmlOpen;
     htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

     htp.headOpen;

     htp.p('<script src="/OA_HTML/POSWUTIL.js"></script>');

     htp.p('<SCRIPT>
           document.write("<title>" +
           top.getTop().FND_MESSAGES["ICX_POS_ASBN_DETAILS"] + "</title>")
           </SCRIPT>');

     js.scriptOpen;

     js.scriptClose;

     htp.headClose;

     htp.p('<frameset cols="3,*,3" border=0 framespacing=0>');

       -- blue border frame
       htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderLeft
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');


	htp.p('<frameset rows = "50, 10, *, 8, 45" border=1>');

         -- title bar and logo
         htp.p('<frame src="' || POS_ASBN.g_script_name || '/pos_upper_banner_sv.ModalWindowTitle?p_title=ICX_POS_ASBN_DETAILS"');
         htp.p('       name=titlebar');
         htp.p('       marginwidth=0');
         htp.p('       marginheight=0');
         htp.p('       scrolling=no>');

 	-- upper banner with the curved edge
	htp.p('<frame src="/OA_HTML/US/POSUPBAN.htm"' ||
        '   name=upperbanner'||
        '   marginwidth=0'   ||
        '   marginheight=0'  ||
        '   scrolling=no>');

	htp.p('<frame src="' || POS_ASBN.g_script_name ||
        '/POS_ASBN.EDIT_HEADER"' ||
        '   name=header'     ||
        '   marginwidth=0'   ||
        '   marginheight=0'  ||
        '   scrolling=auto>');

	 -- lower banner with curved edge
	htp.p('<frame src="' || POS_ASBN.g_script_name ||
        '/pos_lower_banner_sv.PaintLowerBanner"' ||
        '   name=lowerbanner'||
        '   marginwidth=0'   ||
        '   marginheight=0'  ||
        '   scrolling=no>');

         -- lower button frame

         htp.p('<frame src="' || POS_ASBN.g_script_name ||
               '/POS_ASBN.BUILD_BUTTONS?p_button1Name=ICX_POS_BTN_OK&p_button1Function=ASBNSubmit(top)&p_button2Name=&p_button2Function=cancelShipmentDetails&p_button3Name=ICX_POS_BTN_CANCEL&p_button3Function=ASBNCancel(top)"');
         htp.p('       name=controlregion');
         htp.p('       marginwidth=0');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');


     htp.p('</frameset>');

       -- blue border frame
       htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderRight
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');

     htp.p('</frameset>');

    htp.htmlClose;

END ASBN_Details;

PROCEDURE edit_header IS
BEGIN

  POS_ASBN.g_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  htp.htmlOpen;
  htp.headOpen;

  htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

  js.scriptOpen;

  htp.p('

  function closeWindow(p)
  {
    if (p != "")
    {
      top.close();
    }
  }

  ');


  js.scriptClose;

  htp.headClose;
  htp.bodyOpen(null, 'onLoad="javascript:closeWindow(' || '''' ||
               g_flag  || '''' || ')"' ||
               ' bgcolor=#cccccc link=blue vlink=blue alink=#ff0000');
--  htp.bodyOpen(null,'bgcolor=#cccccc link=blue vlink=blue alink=#ff0000');

  htp.p('<form name="POS_ASBN_HEADER" action="' || POS_ASBN.g_script_name ||
        '/POS_ASBN.UPDATE_HEADER" target="header" method=GET">');

  paint_edit_header;

  htp.p('</form>');

  htp.bodyClose;
  htp.htmlClose;

END edit_header;

PROCEDURE Paint_Edit_Header IS
  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_current_row      NUMBER;
  l_session_id NUMBER := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_where_clause     VARCHAR2(2000) := 'SESSION_ID = ' || to_char(l_session_id);
BEGIN

   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

   htp.p('<!-- This row contains the help text -->');
   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         ' ' ||
         '</font></td>');
   htp.p('</tr>');
   htp.p('</table>');

   ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ASBN_HEADERS_R',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  g_responsibility_id,
                          p_user_id                 =>  g_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

   l_attribute_index := ak_query_pkg.g_items_table.FIRST;
   l_result_index    := ak_query_pkg.g_results_table.FIRST;

   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

   htp.p('<tr bgcolor=#cccccc>');

   l_current_col := 0;

   WHILE (l_attribute_index IS NOT NULL) LOOP

     l_current_col := l_current_col + 1;

    IF (item_style(l_attribute_index) = 'HIDDEN') THEN

       htp.p('<!-- ' || item_code(l_attribute_index) ||
             ' - '   || item_style(l_attribute_index) || ' -->');

       htp.p('<input name="' || item_code(l_attribute_index) ||
             '" type="HIDDEN" VALUE="' ||
               get_result_value(l_result_index, l_current_col) ||
             '">');
    ELSIF item_displayed(l_attribute_index)  THEN
        IF (item_style(l_attribute_index) = 'TEXT') THEN
          IF item_updateable(l_attribute_index) THEN

              htp.p('<td bgcolor=#cccccc' ||
                     item_halign(l_attribute_index) ||
                     item_valign(l_attribute_index) ||
                    '>' ||
                    '<font class=promptblack>' ||
                     item_name(l_attribute_index) ||
                    '</font>' ||
                    '&nbsp;' ||
                    '</td>');

              htp.p('<td nowrap' ||
                    ' align=LEFT' ||
                    ' valign=CENTER' ||
                    '>' ||
                    '<font class=datablack>'||
                    '<input type=text ' ||
                    item_size(l_attribute_index) ||
                    item_maxlength(l_attribute_index) ||
                    ' name="' || item_code(l_attribute_index) || '"' ||
                    ' value="' ||
                    get_result_value(l_result_index, l_current_col) ||
                    '" ></font>' ||
                    item_lov(l_attribute_index) ||
                    '</td>');
/*
              htp.p('<td nowrap' ||
                    ' align=LEFT' ||
                    ' valign=CENTER' ||
                    '>' ||
                    '<B><font class=datablack>'||
                    '<input type=text size=10 name="' ||
                      item_code(l_attribute_index) || '"' ||
                    ' value="' ||
                     get_result_value(l_result_index, l_current_col) ||
                    '" ></font></B></td>');
*/
            ELSE

             htp.p('<td bgcolor=#cccccc ' ||
                    item_halign(l_attribute_index) ||
                    item_valign(l_attribute_index) ||
                   '>' ||
                   '<font class=promptblack>' ||
                    item_name(l_attribute_index) ||
                   '</font>' ||
                   '&nbsp;' ||
                   '</td>');

             htp.p('<td ' ||
                   ' align=LEFT' ||
                   ' valign=CENTER' ||
                   '>' ||
                   '<B><font class=tabledata>' ||
                   nvl(get_result_value(l_result_index, l_current_col), '&nbsp;') ||
                   '</font></B></td>');

            END IF;
        END IF;

      END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

--    if ((l_current_col mod 2) = 0) THEN
         htp.p('</tr>');
         htp.p('<tr bgcolor=#cccccc>');
--    end if;

   END LOOP;

   htp.p('</tr>');
   htp.p('</table>');

END Paint_Edit_Header;

PROCEDURE UPDATE_HEADER  ( pos_invoice_number     IN VARCHAR2 DEFAULT null,
                           pos_invoice_date       IN VARCHAR2 DEFAULT null,
			   pos_freight_amount	  IN VARCHAR2 DEFAULT null
		         )
IS
l_invoice_date DATE;
l_date_format  VARCHAR2(100);
BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  begin
   l_invoice_date    := to_date(pos_invoice_date, l_date_format);
      EXCEPTION
        WHEN OTHERS THEN
         null; /* need error reporting here */
  end;

  update pos_asn_shop_cart_headers  set
    invoice_num    = pos_invoice_number,
    invoice_date   = l_invoice_date,
    freight_amount = fnd_number.canonical_to_number(rtrim(ltrim(pos_freight_amount)))
  where session_id = icx_sec.getID(icx_sec.PV_SESSION_ID);

  COMMIT;

g_flag := 'Y';
  edit_header;

END update_header;

END POS_ASBN;

/
