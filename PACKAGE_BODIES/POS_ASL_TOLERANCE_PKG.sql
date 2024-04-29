--------------------------------------------------------
--  DDL for Package Body POS_ASL_TOLERANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASL_TOLERANCE_PKG" AS
/* $Header: POSASLTB.pls 115.3 99/10/15 17:16:55 porting shi $ */

/* Internal Procedures */

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

END set_session_info;

PROCEDURE button(src1 IN varchar2,
                 txt1 IN varchar2) IS
BEGIN

  htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
           <td width=15 rowspan=5></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a target="tolerance"
href="' || src1 || '"><font class=button>'|| txt1 || '</font></a></td>
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

FUNCTION item_lov(l_index in number) RETURN VARCHAR2 IS
BEGIN

  IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
                   ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL)
      THEN
      return  '<A HREF="javascript:call_LOV('''||
                         item_code(l_index) || ''')"' ||
                        '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 ' ||
                        'HEIGHT=21 border=no align=absmiddle></A>';
  ELSE
     return '';
  END IF;

END item_lov;

FUNCTION item_lov_multi(l_index in number, l_row in number) RETURN VARCHAR2 IS
BEGIN

  IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
                   ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL)
      THEN
      return  '<A HREF="javascript:call_LOV('''||
                         item_code(l_index) || '''' || ',' || '''' || to_char(l_row-1) ||
                         '''' || ',' || '''' || l_script_name ||
                         ''')"' ||
                        '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 ' ||
                        'HEIGHT=21 border=no align=absmiddle></A>';
  ELSE
     return '';
  END IF;

END item_lov_multi;

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


PROCEDURE show_tolerance(p_option         IN NUMBER,
        	p_where_clause            IN VARCHAR2 DEFAULT NULL,
                p_msg                     IN VARCHAR2 DEFAULT NULL,
                p_asl_id		  IN VARCHAR2 DEFAULT NULL,
                pos_asl_id                IN t_text_table DEFAULT g_dummy,
		pos_using_organization_id IN t_text_table DEFAULT g_dummy,
		pos_days_in_advance       IN t_text_table DEFAULT g_dummy,
                pos_tolerance             IN t_text_table DEFAULT g_dummy,
                pos_tol_rows              IN VARCHAR2 DEFAULT NULL,
                pos_more_rows             IN VARCHAR2 DEFAULT '5',
                pos_error_row            IN VARCHAR2 DEFAULT '0') IS

  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_current_row      NUMBER;
  l_where_clause     VARCHAR2(2000) := '' ;
  l_value            VARCHAR2(100);

  l_rows	     NUMBER;
  l_current_rows     NUMBER;
  l_cap              VARCHAR2(100);

BEGIN

  l_cap := fnd_message.get_string('ICX', 'ICX_POS_TOLERANCE');
  init_page;

  js.scriptOpen;
  icx_util.LOVscript;
  js.scriptClose;

  htp.p('  <script src="/OA_HTML/POSASLTJ.js" language="JavaScript">');
  htp.p('  </script>');
  htp.headClose;

  if p_msg is not null then
    htp.p('<BODY bgcolor=#cccccc onLoad="javascript:show_error(''' || p_msg  || ''')">');
  else
    htp.p('<BODY bgcolor=#cccccc>');
  end if;

  htp.p('<form name="POS_TOL_UPDATE" ACTION="' || l_script_name ||
        '/POS_ASL_TOLERANCE_PKG.submit_tolerance" target="tolerance" method="GET">');

  htp.p('<input name="POS_TOL_ACTION" type="HIDDEN" value="ADDROWS">');
  htp.p('<input name="P_ASL_ID" type="HIDDEN" value="' || p_asl_id || '">');
  htp.p('<input name="POS_ERROR_ROW" type="HIDDEN" value="0">');

  if p_option = -1 then
    htp.p('<input name="POS_TOL_ROWS" type="HIDDEN" value="-1">');
    htp.p('</FORM>');
    htp.bodyClose;
    htp.htmlClose;
    return;
  end if;

  if p_where_clause is not null then
    l_where_clause := p_where_clause;
  end if;

  ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ASL_TOLERANCE_R',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  l_responsibility_id,
                          p_user_id                 =>  l_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

  l_attribute_index := ak_query_pkg.g_items_table.FIRST;

  htp.p('<table width=100% bgcolor=#cccccc cellpadding=2 cellspacing=0 border=2>');
  htp.p('<tr><td>');

  htp.p('<table align=center bgcolor=#cccccc cellpadding=2 cellspacing=1 border=0>');
  htp.p('<CAPTION>' || l_cap || '</CAPTION>');

  /* ---- Print the table heading --- */

  htp.p('<tr>');

  WHILE (l_attribute_index IS NOT NULL) LOOP

    IF (item_style(l_attribute_index) = 'HIDDEN') THEN

       htp.p('<!-- ' ||  item_code(l_attribute_index)  ||
             ' - '   ||  item_style(l_attribute_index) || ' -->' );

    ELSIF item_displayed(l_attribute_index)  THEN

          htp.p('<td bgcolor=#336699' ||
                 item_halign(l_attribute_index) ||
                 item_valign(l_attribute_index) ||
                '>' ||
                item_reqd(l_attribute_index)
                );


          htp.p('<font class=promptwhite>' || item_name(l_attribute_index) || '</font>');

          htp.p('</td>');

    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

  END LOOP;

  htp.p('</tr>');

  /* ----- end print table heading ----*/

  if ((p_option = 1) or (p_option = 2)) then
    /* Add rows */

    /* ----- print contents -----------*/
    l_current_row := 0;
    if (pos_tol_rows is not null) then
      FOR l_counter IN 1..to_number(pos_tol_rows) LOOP

        l_current_row := l_current_row + 1;

        if (l_current_row = to_number(pos_error_row))THEN
          htp.p('<tr BGCOLOR=''#cc033'' >');
        elsif ((l_current_row mod 2) = 0) THEN
          htp.p('<tr BGCOLOR=''#ffffff'' >');
        else
          htp.p('<tr BGCOLOR=''#99ccff'' >');
        end if;

        l_attribute_index := ak_query_pkg.g_items_table.FIRST;

        l_current_col := 0;

        WHILE (l_attribute_index IS NOT NULL) LOOP

          l_current_col := l_current_col + 1;
          if (item_code(l_attribute_index) = 'POS_ASL_ID') then
           if (l_counter <= pos_asl_id.count) then
             l_value := pos_asl_id(l_counter);
           end if;
          elsif (item_code(l_attribute_index) = 'POS_USING_ORGANIZATION_ID') then
           if (l_counter <= pos_using_organization_id.count) then
             l_value := pos_using_organization_id(l_counter);
           end if;
          elsif (item_code(l_attribute_index) = 'POS_DAYS_IN_ADVANCE') then
           l_value := pos_days_in_advance(l_counter);
          elsif (item_code(l_attribute_index) = 'POS_TOLERANCE') then
           l_value := pos_tolerance(l_counter);
          end if;


          IF (item_style(l_attribute_index) = 'HIDDEN') THEN
            if (item_code(l_attribute_index) = 'POS_USING_ORGANIZATION_ID') then
              if (l_counter <= pos_using_organization_id.count) then
                htp.p('<input name="' || item_code(l_attribute_index) ||
                      '" type="HIDDEN" VALUE="' || l_value ||
                      '">');
              end if;
            elsif (item_code(l_attribute_index) = 'POS_ASL_ID') then
              if (l_counter <= pos_asl_id.count) then
               htp.p('<input name="' || item_code(l_attribute_index) ||
                    '" type="HIDDEN" VALUE="' || l_value ||
                    '">');
              end if;
            else
              htp.p('<input name="' || item_code(l_attribute_index) ||
                    '" type="HIDDEN" VALUE="' || l_value ||
                    '">');
            end if;
          ELSE
            IF item_displayed(l_attribute_index)  THEN
              IF (item_style(l_attribute_index) = 'TEXT') THEN
                IF item_updateable(l_attribute_index) THEN
                  htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                      '<font class=datablack>' ||
                      '<input type=text ' || item_size(l_attribute_index) ||
                        ' name="' || item_code(l_attribute_index)  || '"' ||
                      ' value="' || l_value  ||
                      '" ></font>' ||
		      item_lov_multi(l_attribute_index,l_current_row) ||
                      '</td>');

                ELSE

                 htp.p('<td ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>');

                 htp.p('<font class=tabledata>' ||
                       l_value ||
                     '</font>');

                 htp.p('</td>');

                END IF;

              END IF;
            END IF;
          END IF;

          l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

        END LOOP;

        htp.p('</tr>');

      END LOOP;

    end if;/* pos_tol_rows is not null */

    if (p_option = 1) then

    -- print extra rows

    l_rows := to_number(pos_more_rows);
    WHILE (l_rows > 0) LOOP

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

	IF item_displayed(l_attribute_index)  THEN
             IF (item_style(l_attribute_index) = 'TEXT') THEN
                IF item_updateable(l_attribute_index) THEN

                  htp.p('<td nowrap ' ||
                          item_halign(l_attribute_index) ||
                          item_valign(l_attribute_index) ||
                        '>' ||
                        '<font class=datablack>' ||
                        '<input type=text ' || item_size(l_attribute_index) ||
                        ' name="' || item_code(l_attribute_index)  || '"' ||
                        ' value=""' ||
                         '></font>' || item_lov_multi(l_attribute_index,l_current_row) ||
                         '</td>');

                END IF;

            END IF;
        END IF;

        l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

      END LOOP;

      htp.p('</tr>');

      l_rows := l_rows - 1;

    END LOOP;

    end if;  /* p_option = 1 */

    htp.p('</table>');

    htp.p('<input name="POS_TOL_ROWS" type="HIDDEN" value="' ||
	  l_current_row || '">');

  else

    /* ----- print contents -----------*/
    l_current_row := 0;

    IF ak_query_pkg.g_results_table.count > 0 THEN

      l_result_index := ak_query_pkg.g_results_table.FIRST;

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

             htp.p('<input name="' || item_code(l_attribute_index) ||
                   '" type="HIDDEN" VALUE="' ||
                   get_result_value(l_result_index, l_current_col) || '">');

          ELSE
           IF item_displayed(l_attribute_index)  THEN
             IF (item_style(l_attribute_index) = 'TEXT') THEN
                IF item_updateable(l_attribute_index) THEN

                  htp.p('<td nowrap ' ||
                          item_halign(l_attribute_index) ||
                          item_valign(l_attribute_index) ||
                        '>' ||
                        '<font class=datablack>' ||
                        '<input type=text ' || item_size(l_attribute_index) ||
                          ' name="' || item_code(l_attribute_index)  || '"' ||
                        ' value="' || nvl(get_result_value(l_result_index, l_current_col),'')  ||
                         '" ></font>' || item_lov_multi(l_attribute_index,l_current_row) ||
                         '</td>');

                ELSE

                 htp.p('<td ' ||
                          item_halign(l_attribute_index) ||
                          item_valign(l_attribute_index) ||
                        '>');

                 htp.p('<font class=tabledata>' ||
                         nvl(get_result_value(l_result_index, l_current_col), '&nbsp') ||
                       '</font>');

                 htp.p('</td>');

                END IF;

            END IF;
           END IF;
          END IF;

          l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

        END LOOP;

        htp.p('</tr>');

        l_result_index := ak_query_pkg.g_results_table.NEXT(l_result_index);

      END LOOP;

    END IF;

    htp.p('<input name="POS_TOL_ROWS" type="HIDDEN" value="' ||
          l_current_row || '">');

    htp.p('</table>');

  end if;

  /* Print Add Button */
  htp.p('<br>');
  htp.p('<table align=center cellpadding=2 cellspacing=1 border=0>');

  htp.p('<tr><td>');

  button('javascript:addrows()',
	 fnd_message.get_string('ICX', 'ICX_POS_ADD_ROW'));

  htp.p('</td><td>');

  htp.p( '<font class=datablack>' ||
	 '<input type="text"  size=1' ||
	 ' name="POS_MORE_ROWS" value="' || to_number(pos_more_rows) || '"></font> &nbsp');

  htp.p('</td></tr>');

  htp.p('</table>');

  htp.p('</td></tr></table>');
  htp.p('</form>');

  close_page;

END show_tolerance;



/* Main Procedures */

PROCEDURE tolerance_frame(pos_asl_id         IN VARCHAR2 DEFAULT NULL
) IS

  l_where_clause     VARCHAR2(2000) := NULL;

BEGIN

  IF (pos_asl_id IS NULL) THEN
    show_tolerance(-1);
    return;
  END IF;

  l_where_clause := 'asl_id = ' || pos_asl_id ;

  show_tolerance(0, l_where_clause, null, pos_asl_id);

EXCEPTION

  when others then
    show_tolerance(-1, null, 'Exception Raised in tolerance_Frame');
null;

END tolerance_frame;


PROCEDURE submit_tolerance(pos_asl_id         IN t_text_table DEFAULT g_dummy,
                  pos_using_organization_id   IN t_text_table DEFAULT g_dummy,
                  pos_days_in_advance         IN t_text_table DEFAULT g_dummy,
                  pos_tolerance               IN t_text_table DEFAULT g_dummy,
                  p_asl_id	              IN VARCHAR2 DEFAULT NULL,
                  pos_tol_action              IN VARCHAR2 DEFAULT NULL,
                  pos_tol_rows                IN VARCHAR2 DEFAULT NULL,
                  pos_more_rows               IN VARCHAR2 DEFAULT NULL,
                  pos_error_row               IN VARCHAR2 DEFAULT NULL )  IS

 l_counter 	NUMBER;
 l_where_clause VARCHAR2(2000) := NULL;

BEGIN

  if (pos_tol_action = 'ADDROWS') then
  -- Add more rows ---
    show_tolerance(1, '1=0', null, p_asl_id, pos_asl_id,
	          pos_using_organization_id, pos_days_in_advance,
                  pos_tolerance, pos_tol_rows, pos_more_rows);

  elsif (pos_tol_action = 'ERROR') then
    show_tolerance(2, null, null, p_asl_id, pos_asl_id,
	          pos_using_organization_id, pos_days_in_advance,
                  pos_tolerance, pos_tol_rows, pos_more_rows, pos_error_row);

  elsif (pos_tol_action = 'CLEAR') then

    show_tolerance(-1);

  elsif (pos_tol_action = 'SUBMIT') then

    delete from po_supplier_item_tolerance
    where asl_id = to_number(p_asl_id)
    and using_organization_id = -1;

    FOR l_counter IN 1..to_number(pos_tol_rows) LOOP
      if (pos_days_in_advance(l_counter) is not null and
          pos_tolerance(l_counter) is not null) then
        insert into po_supplier_item_tolerance
          (
           ASL_ID,
           USING_ORGANIZATION_ID,
           NUMBER_OF_DAYS,
           TOLERANCE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY
           )
        values (
           to_number(p_asl_id),
           -1,
           nvl(to_number(pos_days_in_advance(l_counter)), 0),
           nvl(to_number(pos_tolerance(l_counter)), 0),
           sysdate,
           l_user_id,
           l_user_id,
           sysdate,
           l_user_id );

      end if;

    END LOOP;

    COMMIT;

    l_where_clause := 'asl_id = ' || p_asl_id ;
    show_tolerance(0, l_where_clause, null, p_asl_id);

  end if;

END submit_tolerance;


/* Initialize the session info only once per session */
BEGIN

  IF NOT set_session_info THEN
    RETURN;
  END IF;

END POS_ASL_TOLERANCE_PKG;

/
