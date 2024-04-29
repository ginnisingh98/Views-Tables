--------------------------------------------------------
--  DDL for Package Body ICX_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ITEM" AS
/* $Header: ICXSTDIB.pls 115.2 99/07/17 03:27:08 porting ship $ */

----------------------------------------------------
PROCEDURE xls (p_where IN VARCHAR2 )
IS

 v_dcd_name            VARCHAR2(200) := NULL;
 v_help_url            VARCHAR2(2000) := NULL;
 v_language_code       VARCHAR2(30) := NULL;

 l_where_clause  VARCHAR2(2000) := NULL;
 l_region_code   VARCHAR2(50):= NULL;
 l_total_rows    NUMBER := 0;
 y_table         icx_util.char240_table;

 l_field_sep     VARCHAR2(10) := icx_store_batch_utils.g_field_sep;
 l_line_sep      VARCHAR2(10) := icx_store_batch_utils.g_line_sep;

 l_line          LONG := NULL;

 l_date_format   VARCHAR2(50) :=  NULL;

BEGIN

  IF icx_sec.validateSession THEN

    -- Initialize the error page
    icx_util.error_page_setup;

    l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

    v_dcd_name := owa_util.get_cgi_env('SCRIPT_NAME');
    v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    v_help_url := '/OA_DOC/' || v_language_code || '/awc' || '/icxitems.htm';

    l_where_clause := icx_call.decrypt2(p_where);
    l_region_code  := 'ICX_ITEM_DETLS_LOAD_R';

    ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                           P_PARENT_REGION_CODE    => l_region_code,
                           P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                           P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           P_WHERE_CLAUSE          => l_where_clause,
                           P_RETURN_PARENTS        => 'T',
                           P_RETURN_CHILDREN       => 'F');

   l_total_rows := ak_query_pkg.g_results_table.count;

   IF l_total_rows = 0 THEN
      -- Print the no data found message.
      -- Do not spwan the spread sheet
      -- This will not happen
      htp.htmlOpen;
      htp.headOpen;
      icx_util.copyright;
      js.scriptOpen;
      icx_admin_sig.help_win_script(v_help_url, v_language_code);
      js.scriptClose;
      htp.title(ak_query_pkg.g_regions_table(0).name);
      htp.headClose;

      icx_admin_sig.toolbar(language_code => v_language_code,
                            disp_find => 'icx_store_item_templates.find_items');
      fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
      fnd_message.set_token('NAME_OF_REGION_TOKEN',
               ak_query_pkg.g_regions_table(0).name);
      htp.br;
      htp.tableOpen('BORDER=0');
      htp.tableRowOpen;
      htp.tableData(cvalue => '<B><FONT size=+1>'||fnd_message.get||'</FONT></B>
',cattributes => 'VALIGN="MIDDLE"');
      htp.tableClose;
      htp.br;
      icx_admin_sig.footer;
   ELSE
      -- Set the mime type to spread sheet for automatic spawning
      owa_util.mime_header('application/msexcel');

      -- Print the first three instruction lines
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_XL_LINE1');
      htp.p(FND_MESSAGE.GET);
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_XL_LINE2');
      FND_MESSAGE.SET_TOKEN('ICX_DATE_FORMAT', l_date_format);
      htp.p(FND_MESSAGE.GET);
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_XL_LINE3');
      htp.p(FND_MESSAGE.GET);
      htp.p;

      FOR i IN ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST LOOP
        IF (ak_query_pkg.g_items_table(i).secured_column = 'F'
           AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y' )
             OR (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_INVENTORY_ITEM_ID') THEN

           l_line := l_line || ak_query_pkg.g_items_table(i).attribute_label_long || l_field_sep;

        END IF; -- IF ak_query_pkg....

      END LOOP;

      -- Print the line string
      htp.p(l_line);

      -- FOR r IN p_start_row -1..v_end_row - 1 LOOP
      FOR r IN ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST LOOP
       icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),y_table);

       l_line := NULL;
       FOR i IN ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST LOOP
       IF (ak_query_pkg.g_items_table(i).secured_column = 'F'
         AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y')
         OR ( ak_query_pkg.g_items_table(i).attribute_code = 'ICX_INVENTORY_ITEM_ID') THEN

          l_line := l_line || y_table(ak_query_pkg.g_items_table(i).value_id)
                      || l_field_sep;
       END IF; --  IF ... secured_column = 'F'...

       END LOOP; -- FOR i ...

       htp.p(l_line);

      END LOOP; -- FOR r ...

   END IF; -- IF l_totlal_rows = 0

  END IF; -- IF validateSession

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in xls: ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;
END xls;

END icx_item;

/
