--------------------------------------------------------
--  DDL for Package Body POS_ASN_REVIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN_REVIEW_PKG" AS
/* $Header: POSASNRB.pls 115.1 99/10/14 16:18:39 porting shi $ */

g_header_results_table         ak_query_pkg.results_table_type;
g_header_items_table           ak_query_pkg.items_table_type;

g_inv_hdr_results_table         ak_query_pkg.results_table_type;
g_inv_hdr_items_table           ak_query_pkg.items_table_type;

g_lines_results_table         ak_query_pkg.results_table_type;
g_lines_items_table           ak_query_pkg.items_table_type;

g_seq_results_table           ak_query_pkg.results_table_type;
g_seq_items_table             ak_query_pkg.items_table_type;

g_ship_results_table          ak_query_pkg.results_table_type;
g_ship_items_table            ak_query_pkg.items_table_type;

g_inv_dtl_results_table         ak_query_pkg.results_table_type;
g_inv_dtl_items_table           ak_query_pkg.items_table_type;

PROCEDURE header_section;
PROCEDURE lines_section;

PROCEDURE PrintResult(p_result_index       IN NUMBER,
                      p_results_table      IN ak_query_pkg.results_table_type,
                      p_items_table        IN ak_query_pkg.items_table_type);

PROCEDURE DupResultTable(p_source     in     ak_query_pkg.results_table_type,
                         p_dest       in out ak_query_pkg.results_table_type);

PROCEDURE DupItemTable(p_source       in     ak_query_pkg.items_table_type,
                       p_dest         in out ak_query_pkg.items_table_type);

function get_result_value(p_table     in ak_query_pkg.results_table_type,
                          p_index     in number,
                          p_col       in number) return varchar2;

function valid_invoice_num(p_session_id in number) return boolean;

-- Body

PROCEDURE review_page(p_submit IN VARCHAR2 DEFAULT 'N') IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id NUMBER;

  l_where_clause     VARCHAR2(2000);
  l_total_rows       NUMBER := 0;
  l_result_index     NUMBER;

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

  fnd_global.apps_initialize(l_user_id, l_responsibility_id, 178);

  htp.htmlOpen;

  htp.headOpen;
  icx_util.copyright;
  htp.linkRel('STYLESHEET', '/OA_HTML/' || l_language || '/POSSTYLE.css');
  htp.p('<script src="/OA_HTML/POSASNED.js" language="JavaScript"></script>');
  htp.headClose;

  if p_submit = 'Y' then

    pos_asn.submit;

    htp.p('<body onLoad="javascript:LoadPage(' ||
          '''' || pos_asn.sub_state  || '''' || ',' ||
          '''' || pos_asn.error_message  || '''' || ',' ||
          '''' || pos_asn.but1  || '''' || ',' ||
          '''' || pos_asn.but2  || '''' || ',' ||
          '''' || pos_asn.but3  || '''' ||
          ')">');
  else

    htp.p('<body>');

  end if;

  htp.p('<FORM NAME="POS_ASN_REVIEW" ACTION="'||l_script_name||'/POS_ASN_REVIEW_PKG.review_page" METHOD="GET">');

  htp.p('<INPUT NAME="p_submit" TYPE="HIDDEN" VALUE="Y">');

  htp.p('<table align=center width=98% cellpadding=2 cellspacing=0 border=0>');

  header_section;

  htp.p('<TR><TD colspan=3>&nbsp;<TD></TR>');

  lines_section;

  htp.p('</FORM>');

  htp.p('</TABLE>');

  htp.bodyClose;
  htp.htmlClose;

END review_page;


PROCEDURE header_section IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_where_clause     VARCHAR2(2000);
  l_total_rows        NUMBER := 0;

BEGIN

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  l_where_clause := 'SESSION_ID = ' || to_char(l_session_id);

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_REVIEW_HEADERS_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  DupResultTable(ak_query_pkg.g_results_table, g_header_results_table);
  DupItemTable(ak_query_pkg.g_items_table, g_header_items_table);

  IF FND_FUNCTION.TEST('ICX_DISABLE_ASBN') and valid_invoice_num(l_session_id) THEN

    ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                            p_parent_region_code=>'POS_ASN_REVIEW_INV_HDR_R',
                            p_where_clause=>l_where_clause,
                            p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                            p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                            p_return_parents=>'T',
                            p_return_children=>'F');

    DupResultTable(ak_query_pkg.g_results_table, g_inv_hdr_results_table);
    DupItemTable(ak_query_pkg.g_items_table, g_inv_hdr_items_table);

  END IF;

  l_total_rows := g_header_results_table.count;

  IF l_total_rows = 1 THEN

    PrintResult(g_header_results_table.FIRST, g_header_results_table, g_header_items_table);

    IF FND_FUNCTION.TEST('ICX_DISABLE_ASBN') and valid_invoice_num(l_session_id) THEN

      htp.p('<TR><TD colspan=3>&nbsp;<TD></TR>');

      PrintResult(g_inv_hdr_results_table.FIRST, g_inv_hdr_results_table,  g_inv_hdr_items_table);

    END IF;

  END IF;

END header_section;

PROCEDURE lines_section IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;

  l_where_clause     VARCHAR2(2000);
  l_total_rows       NUMBER := 0;
  l_result_index     NUMBER;

BEGIN

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  l_where_clause := 'SESSION_ID = ' || to_char(l_session_id);

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_REVIEW_DETAILS_SEQ_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  DupResultTable(ak_query_pkg.g_results_table, g_seq_results_table);
  DupItemTable(ak_query_pkg.g_items_table, g_seq_items_table);

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_REVIEW_PO_DETAILS_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  DupResultTable(ak_query_pkg.g_results_table, g_lines_results_table);
  DupItemTable(ak_query_pkg.g_items_table, g_lines_items_table);

  ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                          p_parent_region_code=>'POS_ASN_REVIEW_SHIP_DETAILS_R',
                          p_where_clause=>l_where_clause,
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'T',
                          p_return_children=>'F');

  DupResultTable(ak_query_pkg.g_results_table, g_ship_results_table);
  DupItemTable(ak_query_pkg.g_items_table, g_ship_items_table);

  IF FND_FUNCTION.TEST('ICX_DISABLE_ASBN') and valid_invoice_num(l_session_id) THEN

    ak_query_pkg.exec_query(p_parent_region_appl_id=>178,
                            p_parent_region_code=>'POS_ASN_REVIEW_INV_DETAILS_R',
                            p_where_clause=>l_where_clause,
                            p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                            p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                            p_return_parents=>'T',
                            p_return_children=>'F');

    DupResultTable(ak_query_pkg.g_results_table, g_inv_dtl_results_table);
    DupItemTable(ak_query_pkg.g_items_table, g_inv_dtl_items_table);

  END IF;

  l_total_rows := g_lines_results_table.count;

  l_result_index := g_lines_results_table.FIRST;

  WHILE (l_result_index IS NOT NULL) LOOP

    htp.p('<TR><TD colspan=3><FONT class=headingblack>');

    htp.p(g_seq_items_table(g_seq_items_table.FIRST).attribute_label_long || ' ' ||
          get_result_value(g_seq_results_table, l_result_index, 1));

    htp.p('</FONT></TD></TR><TR><TD colspan=3>');

    htp.p('<table align=center width=100%  cellpadding=0 cellspacing=0 border=0>');

    htp.p('<tr><td height=5><img src=/OA_MEDIA/FNDPXG5.gif></td></tr>');
    htp.p('<tr><td height=1 bgcolor=black><img src=/OA_MEDIA/FNDPX1.gif></td></tr>');
    htp.p('<tr><td height=3><img src=/OA_MEDIA/FNDPXG5.gif></td></tr>');

    htp.p('</table></TD></TR>');

    PrintResult(l_result_index, g_lines_results_table, g_lines_items_table);

    htp.p('<TR><TD colspan=3>&nbsp;</TD></TR>');
    htp.p('<TR><TD colspan=3><FONT class=headingblack>');

    htp.p(fnd_message.get_string('ICX','ICX_POS_SHIPMENT_DETAILS'));

    htp.p('</FONT><TD><TR>');

    PrintResult(l_result_index, g_ship_results_table, g_ship_items_table);

    IF FND_FUNCTION.TEST('ICX_DISABLE_ASBN') and valid_invoice_num(l_session_id) THEN

      htp.p('<TR><TD colspan=3>&nbsp;</TD></TR>');
      htp.p('<TR><TD colspan=3><FONT class=headingblack>');

      htp.p(fnd_message.get_string('ICX','ICX_POS_INVOICE_DETAILS'));

      htp.p('</FONT><TD><TR>');

      PrintResult(l_result_index, g_inv_dtl_results_table, g_inv_dtl_items_table);

    END IF;

    l_result_index := g_lines_results_table.NEXT(l_result_index);

    htp.p('<TR><TD colspan=3>&nbsp;<TD></TR>');

  END LOOP;

END lines_section;

PROCEDURE PrintResult(p_result_index        IN NUMBER,
                      p_results_table       IN ak_query_pkg.results_table_type,
                      p_items_table         IN ak_query_pkg.items_table_type) IS

  l_attribute_index   NUMBER := p_items_table.FIRST;
  l_current_col       NUMBER := 0;

  l_counter           NUMBER := 0;
  l_width             VARCHAR2(50);

BEGIN

  WHILE (l_attribute_index IS NOT NULL) LOOP

    if (p_items_table(l_attribute_index).node_query_flag = 'Y') then

      l_current_col := l_current_col + 1;

    end if;

    IF (p_items_table(l_attribute_index).node_display_flag = 'Y') AND
       (p_items_table(l_attribute_index).secured_column = 'F') THEN


      IF (p_items_table(l_attribute_index).item_style = 'TEXT') THEN

        if (l_counter mod 3) = 0 then

          htp.p('<TR>');

        elsif (p_items_table(l_attribute_index).display_value_length > 20) then

          htp.p('<TR>');
          l_counter := 2;

        end if;

        if (p_items_table(l_attribute_index).display_value_length > 20) then

          l_width := '100% colspan=3';

        else

          l_width := '33%';

        end if;

        htp.p('<TD width=' || l_width  || '><font class=datablack>' ||
              p_items_table(l_attribute_index).attribute_label_long || ':&nbsp;&nbsp;' ||
              '</font><font class=tabledata>' ||
              nvl(get_result_value(p_results_table, p_result_index, l_current_col), fnd_message.get_string('ICX','ICX_POS_NA')) || '</font></TD>');

        if (l_counter mod 3) = 2 then
          htp.p('</TR>');
        end if;

        l_counter := l_counter + 1;

      END IF;

    END IF;

    l_attribute_index := p_items_table.NEXT(l_attribute_index);

  END LOOP;


END PrintResult;

PROCEDURE DupResultTable(p_source       in     ak_query_pkg.results_table_type,
                         p_dest         in out ak_query_pkg.results_table_type) IS

  v_index NUMBER;

BEGIN

  v_index := p_source.FIRST;

  if v_index is not null then

    LOOP

      p_dest(v_index) := p_source(v_index);

      EXIT WHEN v_index = p_source.LAST;

      v_index := p_source.NEXT(v_index);

    END LOOP;

  end if;

END DupResultTable;

PROCEDURE DupItemTable(p_source       in     ak_query_pkg.items_table_type,
                       p_dest         in out ak_query_pkg.items_table_type) IS

  v_index NUMBER;

BEGIN

  v_index := p_source.FIRST;

  if v_index is not null then

    LOOP

      p_dest(v_index) := p_source(v_index);

      EXIT WHEN v_index = p_source.LAST;

      v_index := p_source.NEXT(v_index);

    END LOOP;

  end if;

END DupItemTable;

function get_result_value(p_table       in ak_query_pkg.results_table_type,
                          p_index       in number,
                          p_col         in number) return varchar2 is

    sql_statement  VARCHAR2(300);
    l_cursor       NUMBER;
    l_execute      NUMBER;
    l_result       VARCHAR2(2000);

BEGIN

  IF p_table.count > 0 THEN

      pos_asn_review_pkg.g_temp_table := p_table;

      sql_statement := 'begin ' ||
                       ':l_result := pos_asn_review_pkg.g_temp_table(:p_index).value' ||
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

function valid_invoice_num(p_session_id in number) return boolean is

  l_num   varchar2(30);

begin

  select invoice_num
    into l_num
    from pos_asn_shop_cart_headers
   where session_id = p_session_id;

  if l_num is not null then
    return true;
  else
    return false;
  end if;

exception
  when others then
    return false;

end valid_invoice_num;

END pos_asn_review_pkg;

/
