--------------------------------------------------------
--  DDL for Package Body ICX_REQ_SPECIAL_ORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_SPECIAL_ORD" AS
/* $Header: ICXRQSPB.pls 115.3 99/07/17 03:23:29 porting sh $ */

------------------------------------------------------------
PROCEDURE special_order(n_org VARCHAR2,
                        v_special_order_rec IN special_order_record
                            DEFAULT v_empty_special_order_rec,
                        v_error_flag IN VARCHAR2 DEFAULT NULL,
                        v_error_text IN VARCHAR2 DEFAULT NULL,
                        v_rows_inserted IN VARCHAR2 DEFAULT NULL,
                        v_order_total_message IN VARCHAR2 DEFAULT NULL) IS
------------------------------------------------------------
v_dcdName            varchar2(1000);

begin

  -- Get the execution environment
  v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');


  -- We need to split into 2 frames
   htp.p('<FRAMESET ROWS="*,40" BORDER=0>');
   htp.p('<FRAME SRC="' || v_dcdName ||
         '/ICX_REQ_special_ord.special_order_display?n_org=' ||
         n_org ||
         '" NAME="data" FRAMEBORDER=NO MARGINWIDTH=0 MARGINHEIGHT=0 NORESIZE>');

   htp.p('<FRAME NAME="k_buttons" SRC="' || v_dcdName ||
         '/ICX_REQ_special_ord.special_order_buttons" MARGINWIDTH=0 MARGINHEIGHT=0 FRAMEBORDER=NO NORESIZE SCROLLING="NO">');
   htp.p('</FRAMESET>');

exception
        when others then
                htp.p(SQLERRM);
end;


------------------------------------------------------------
PROCEDURE special_order_buttons is
------------------------------------------------------------

v_lang           varchar2(5);

begin
    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


     htp.p('<BODY BGCOLOR="#FFCCFF">');

     htp.p('<TABLE BORDER=0>');
     htp.p('<TD>');
     htp.p('<TD width=1000></TD><TD>');
     FND_MESSAGE.SET_NAME('ICX','ICX_ADD_TO_ORDER');
     icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                            P_ImageFileName   => 'FNDBNEW.gif',
                            P_OnMouseOverText => FND_MESSAGE.GET,
                            P_HyperTextCall   => 'javascript:parent.frames[0].imClicked()',
                            P_LanguageCode    => v_lang,
                            P_JavaScriptFlag  => FALSE);

     htp.p('</TD></TABLE>');
     htp.p('</BODY>');
end;


------------------------------------------------------------
PROCEDURE special_order_display(n_org VARCHAR2,
                        v_special_order_rec IN special_order_record
                            DEFAULT v_empty_special_order_rec,
                        v_error_flag IN VARCHAR2 DEFAULT NULL,
                        v_error_text IN VARCHAR2 DEFAULT NULL,
                        v_rows_inserted IN VARCHAR2 DEFAULT NULL,
                        v_order_total_message IN VARCHAR2 DEFAULT NULL) IS
------------------------------------------------------------
  /* No defaults set at this point
  CURSOR defaults IS
  SELECT plt.category_id,
         nvl(mck.DESCRIPTION, mck.concatenated_segments) category_name,
	 plt.unit_of_measure,
	 psp.line_type_id
  FROM   po_line_types        plt,
	 po_system_parameters psp,
         mtl_categories_kfv   mck
  WHERE  plt.line_type_id = psp.line_type_id
  AND    plt.category_id = mck.category_id (+);
  */

  CURSOR c_uom IS
  SELECT unit_of_measure, uom_code
  FROM mtl_units_of_measure
  WHERE NVL( disable_date, SYSDATE+1) > SYSDATE
  ORDER BY unit_of_measure;

  CURSOR cat_set IS
  SELECT category_set_id,
         validate_flag
  FROM   mtl_default_sets_view
  WHERE  functional_area_id = 2;

   where_clause         VARCHAR2(2000) := NULL;
   v_default_cat_id     number;
   v_default_cat_name   varchar2(50);
   v_default_uom        varchar2(25);
   v_default_line_type  number;
   v_org                number;
   v_lang               varchar2(30);
   c_title              varchar2(80);
   c_prompts            icx_util.g_prompts_table;

   v_value            varchar2(240);
   v_attribute        varchar2(240);
   v_table_attribute  varchar2(240);

   -- (MC) removed local variables v_results_table and v_regions_table to
   -- save space.  Using global variables in ak_query_pkg instead.

   v_items_table      ak_query_pkg.items_table_type;


   v_vendor_on_flag   varchar2(1);
   v_dcdName    VARCHAR2(1000);
   -- v_select_text VARCHAR2 (20000) := NULL;
   -- Fix for bug 526274
   v_select_text       LONG := NULL;
   v_category_pop_list varchar2(1) := 'N';
   v_uom_pop_list      varchar2(1) := 'N';
   v_category_set_id   NUMBER := NULL;
   v_validate_flag     VARCHAR2(1) := NULL;
   v_category_id       VARCHAR2(240) := NULL;
   v_category_name     VARCHAR2(240) := NULL;
   l_print_message     VARCHAR2(240) := NULL;


BEGIN

 -- Check if session is valid
 IF (icx_sec.validatesession('ICX_REQS')) THEN
  -- Decrypt parameters
  v_org := icx_call.decrypt2(n_org);

  -- Get prompts
  -- icx_util.getPrompts(178,'ICX_ONE_TIME',c_title,c_prompts);
  icx_util.getPrompts(601,'ICX_ONE_TIME',c_title,c_prompts);

  -- Get language
  v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  -- Get the execution environment
  v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

  -- Special Order Related Object Navigator
  -- Just get the structure, NO DATA i.e. P_RETURN_PARENTS  => 'F'

  -- (MC) Use exec_query instead of execute_query to improve performance
  ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                             P_PARENT_REGION_CODE    => 'ICX_REQ_SPECIAL_ORDER',
                             P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                             P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                             P_RETURN_PARENTS        => 'F',
			  P_RETURN_CHILDREN       => 'F');


-- Make a copy of v_items_table b/c it will be overwritten by the second
-- exec_query;
  v_items_table := ak_query_pkg.g_items_table;

  htp.htmlOpen;
  htp.headOpen;
  icx_util.copyright;
  htp.title(c_title);

  js.scriptOpen;

  htp.p('function check_number(field) {
    if (!parent.parent.checkNumber(field)) {
	field.focus();
	field.value = "";
    }
  }
  function set_category_null() {
  // set the hidden field category to null
    document.one_time.ICX_CATEGORY_ID.value = "";
  }
 ');

  -- Get the message prompt for 'Fields Required'
  FND_MESSAGE.SET_NAME('ICX', 'ICX_REQUIRED');

  icx_util.LOVScript;

  htp.p('function imClicked() {

     var check_desc = false;
     var check_quan = false;
     var check_price = false;
     var check_uom = false;
     var check_category = false;

     if (document.one_time.ICX_ITEM_DESCRIPTION.value <> "")
        check_desc = true;
     if (document.one_time.ICX_QTY_V.value <> "")
         if (parseFloat(document.one_time.ICX_QTY_V.value) >= 0 )
             check_quan = true;
     if (document.one_time.ICX_UNIT_PRICE.value <> "")
        check_price = true;
     if (document.one_time.ICX_UNIT_OF_MEASUREMENT.value <> "")
        check_uom = true;
     if (document.one_time.ICX_CATEGORY_NAME.value <> "")
        check_category = true;

     if ((check_desc) && (check_quan) && (check_price) && (check_uom) && (check_category)) {
         document.one_time.cartId.value = parent.parent.cartId;
        //  document.one_time.cartId.value = 9999;
         document.one_time.submit();
     } else {
	   alert("' || icx_util.replace_quotes(FND_MESSAGE.GET) || '");
     }
   }
  ');


  chk_vendor_on(v_items_table,v_vendor_on_flag);

  -- FND_MESSAGE.SET_NAME('ICX', 'ICX_REQUIRED');
  js.scriptClose;

  htp.bodyOpen('','BGCOLOR="#FFCCFF" onLoad="parent.parent.winOpen(''nav'', ''special_order'')"');

  /* Table approach is used here to create a blank space at the beginning
     of the text. Otherwise the text will run into the left end of the
     browser. All the prompt will have tables associated with it.
  */

  /* Print the help text on the top */
  FND_MESSAGE.SET_NAME('ICX', 'ICX_SELECT_CATG_ENT');
  htp.tableOpen;
  htp.tableRowOpen('BORDER = 0');
  htp.tableData(cvalue => '&nbsp');
  htp.p('<TD ALIGN=LEFT VALIGN=CENTER > ' || FND_MESSAGE.GET || '</TD>');
  htp.tableRowClose;
  htp.tableClose;

  /* Print error message text if there are errors in the order */
  IF v_error_flag = 'Y' THEN
    htp.tableOpen;
    htp.tableRowOpen('BORDER = 0');
    htp.tableData(cvalue => '&nbsp');
    htp.p('<TD ALIGN=LEFT VALIGN=CENTER >' || htf.bold(v_error_text)|| '</TD>');
    htp.tableRowClose;
    htp.tableClose;
  END IF;

  /* Print items added and order total amount */
  IF (to_number(v_rows_inserted) > 0 ) THEN
     FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_NEW');
     FND_MESSAGE.SET_TOKEN('ITEM_QUANTITY', v_rows_inserted);
     l_print_message := FND_MESSAGE.GET;

     htp.tableOpen('BORDER = 0');
     htp.tableRowOpen;
     htp.tableData(cvalue => '&nbsp');
     htp.p('<TD ALIGN=LEFT VALIGN=CENTER > ' || htf.bold(l_print_message) || '</TD>');
     htp.tableRowClose;
     htp.tableRowOpen;
     htp.tableData(cvalue => '&nbsp');
     htp.p('<TD ALIGN=LEFT VALIGN=CENTER > ' || htf.bold(v_order_total_message) || '</TD>');
     htp.tableRowClose;
     htp.tableClose;
  END IF;

  htp.p('<FORM ACTION="'|| v_dcdName || '/ICX_REQ_SPECIAL_ORD.add_item_to_cart " METHOD="POST" NAME="one_time" onSubmit="return(false)">');

  htp.formHidden('n_org', n_org);
  htp.formHidden('cartId', '');

  htp.tableOpen('BORDER=0');

  IF v_items_table.count > 0 THEN
  FOR i IN v_items_table.FIRST  ..  v_items_table.LAST LOOP

    v_value := '';
    v_attribute := '';
    v_table_attribute := ' COLSPAN=2 ';
    v_select_text := '';

    /* If error display the page with the values entered */

    IF v_error_flag = 'Y' THEN
     IF v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' THEN
        v_value := v_special_order_rec.category_name;
     ELSIF v_items_table(i).attribute_code = 'ICX_ITEM_DESCRIPTION' THEN
        v_value := v_special_order_rec.item_description;
     ELSIF v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT' THEN
        v_value := v_special_order_rec.unit_of_measurement;
     ELSIF v_items_table(i).attribute_code = 'ICX_QTY_V' THEN
        v_value := v_special_order_rec.qty_v;
     ELSIF v_items_table(i).attribute_code = 'ICX_UNIT_PRICE' THEN
        v_value := v_special_order_rec.unit_price;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_TYPE_ID' THEN
        v_value := v_special_order_rec.line_type_id;
     ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_ITEM_NUM'
       THEN
        v_value := v_special_order_rec.suggested_vendor_item_num;
     ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' THEN
        v_value := v_special_order_rec.suggested_vendor_name;
     ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' THEN
        v_value := v_special_order_rec.suggested_vendor_phone;
     ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE' THEN
        v_value := v_special_order_rec.suggested_vendor_site;
     ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' THEN
        v_value := v_special_order_rec.suggested_vendor_contact;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_1' THEN
        v_value := v_special_order_rec.line_attribute_1;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_2' THEN
        v_value := v_special_order_rec.line_attribute_2;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_3' THEN
        v_value := v_special_order_rec.line_attribute_3;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_4' THEN
        v_value := v_special_order_rec.line_attribute_4;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_5' THEN
        v_value := v_special_order_rec.line_attribute_5;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_6' THEN
        v_value := v_special_order_rec.line_attribute_6;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_7' THEN
        v_value := v_special_order_rec.line_attribute_7;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_8' THEN
        v_value := v_special_order_rec.line_attribute_8;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_9' THEN
        v_value := v_special_order_rec.line_attribute_9;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_10' THEN
        v_value := v_special_order_rec.line_attribute_10;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_11' THEN
        v_value := v_special_order_rec.line_attribute_11;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_12' THEN
        v_value := v_special_order_rec.line_attribute_12;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_13' THEN
        v_value := v_special_order_rec.line_attribute_13;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_14' THEN
        v_value := v_special_order_rec.line_attribute_14;
     ELSIF v_items_table(i).attribute_code = 'ICX_LINE_ATTRIBUTE_15' THEN
        v_value := v_special_order_rec.line_attribute_15;
     END IF;
    END IF; /* v_error_flag = 'Y' */

    IF (v_items_table(i).node_display_flag = 'Y' AND
        v_items_table(i).secured_column <> 'T') OR
        v_items_table(i).attribute_code = 'ICX_CATEGORY_ID' OR
        v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' OR
        v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT' OR
        v_items_table(i).attribute_code = 'ICX_ITEM_DESCRIPTION' OR
        v_items_table(i).attribute_code = 'ICX_UNIT_PRICE' OR
        v_items_table(i).attribute_code = 'ICX_QTY_V'  OR
        v_items_table(i).attribute_code = 'ICX_LINE_TYPE_ID' OR
        (v_vendor_on_flag = 'Y' AND
         (v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' or
            v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
            v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE' or
            v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT')
        ) THEN

        htp.tableRowOpen;

        --Special handling to load up default values.
        IF v_items_table(i).attribute_code = 'ICX_CATEGORY_ID' THEN
           v_value := v_default_cat_id;
        ELSIF v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' THEN
          --  v_value := v_default_cat_name;
           v_table_attribute := ' COLSPAN=1 ';
           v_attribute := 'onChange="set_category_null()"';
        ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' THEN
           v_table_attribute := ' COLSPAN=1 ';
        --ELSIF v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT' THEN
           -- v_value := v_default_uom;
           v_table_attribute := ' COLSPAN=1 ';
        ELSIF v_items_table(i).attribute_code = 'ICX_UNIT_PRICE' THEN
           v_attribute := 'onChange="check_number(this)"';
       -- ELSIF v_items_table(i).attribute_code = 'ICX_LINE_TYPE_ID' THEN
          -- v_value := v_default_line_type;
        ELSIF v_items_table(i).attribute_code = 'ICX_QTY_V' THEN
           v_attribute := 'onChange="check_number(this)"';
        ELSIF v_items_table(i).lov_attribute_code IS NOT NULL AND
             v_items_table(i).lov_region_code IS NOT NULL AND
             v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_PHONE' AND
             v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_CONTACT' AND
             v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_SITE' AND
             v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_NAME' THEN
                           v_table_attribute := ' COLSPAN=1 ';
         END IF;


         IF (v_items_table(i).attribute_code <> 'ICX_ITEM_DESCRIPTION' AND
             v_items_table(i).attribute_code <> 'ICX_QTY_V' AND
             v_items_table(i).attribute_code <> 'ICX_UNIT_OF_MEASUREMENT' AND
             v_items_table(i).attribute_code <> 'ICX_UNIT_PRICE' AND
             v_items_table(i).attribute_code <> 'ICX_CATEGORY_NAME' AND
             ((v_items_table(i).item_style = 'HIDDEN' AND
               v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_NAME')               OR
             (v_items_table(i).item_style = 'HIDDEN' AND
              v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' AND
              v_vendor_on_flag <> 'Y')))  OR
              v_items_table(i).attribute_code = 'ICX_CATEGORY_ID' OR
              v_items_table(i).attribute_code = 'ICX_LINE_TYPE_ID' THEN
                -- htp.p('<TD></TD>');
                htp.p('<INPUT TYPE=''hidden'' NAME=''' || v_items_table(i).attribute_code || ''' SIZE=' || v_items_table(i).display_value_length || ' VALUE = "' || v_value || '" >' );

          ELSIF v_items_table(i).update_flag = 'Y' OR
                v_items_table(i).attribute_code = 'ICX_ITEM_DESCRIPTION' or
                v_items_table(i).attribute_code = 'ICX_QTY_V' or
                v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT' or
                v_items_table(i).attribute_code = 'ICX_UNIT_PRICE' or
                v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' or
                (v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME'
                 AND v_vendor_on_flag = 'Y') THEN

              htp.p('<TD ALIGN=RIGHT VALIGN=CENTER WIDTH=200> ' || v_items_table(i).attribute_label_long || '</TD>');

              /* IF Category or Unit of measure is a pop list, display
                 SELECT list box */
              IF v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' AND
                 UPPER(v_items_table(i).item_style) = 'POPLIST' THEN

                   -- No Hierarchy setup; show regular categories

                   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 178,
                                           P_PARENT_REGION_CODE    => 'ICX_REQ_CATEGORIES',
                                           P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                                           P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                           P_WHERE_CLAUSE          => ' FUNCTIONAL_AREA_ID = 2',

                                           P_RETURN_PARENTS        => 'T',
                                           P_RETURN_CHILDREN       => 'F');

                   IF ak_query_pkg.g_results_table.count > 0 THEN
                     FOR i IN ak_query_pkg.g_results_table.FIRST .. ak_query_pkg.g_results_table.LAST LOOP
                       -- Category Id
                       v_category_id := ak_query_pkg.g_results_table(i).value3;
                       -- Category Name
                       v_category_name :=ak_query_pkg.g_results_table(i).value1;
                       v_select_text := v_select_text  || '<OPTION VALUE = ' || v_category_id || '>' || v_category_name;
                     END LOOP; /* for i */
                   END IF; /* ak_query_pkg... .count > 0 */
                 htp.tableData((htf.formSelectOpen(v_items_table(i).attribute_code) || v_select_text || htf.formSelectClose), 'LEFT');
                 v_category_pop_list := 'Y';

             ELSIF (v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT'
                   AND UPPER(v_items_table(i).item_style) = 'POPLIST') THEN
                 FOR uom_rec IN c_uom LOOP

                   /* if there is error, set the selected unit of measure in the
                      select list */
                   IF (v_error_flag = 'Y') AND
                      (uom_rec.unit_of_measure = v_special_order_rec.unit_of_measurement) THEN
                       v_select_text := v_select_text  || '<OPTION VALUE = "' || uom_rec.unit_of_measure|| '"  SELECTED>' || uom_rec.unit_of_measure;
                   ELSE
                       v_select_text := v_select_text  || '<OPTION VALUE = "' || uom_rec.unit_of_measure|| '" >' || uom_rec.unit_of_measure;
                   END IF;

                 END LOOP;
                 htp.tableData((htf.formSelectOpen(v_items_table(i).attribute_code) || v_select_text || htf.formSelectClose), 'LEFT');
                 v_uom_pop_list := 'Y';

             ELSE
              htp.p('<TD ALIGN=' || v_items_table(i).horizontal_alignment || ' VALIGN=' || v_items_table(i).vertical_alignment || v_table_attribute || '>');
              htp.p('<INPUT TYPE=''text'' NAME=''' || v_items_table(i).attribute_code || ''' SIZE=' || v_items_table(i).display_value_length ||
' MAXLENGTH=' || v_items_table(i).attribute_value_length || ' VALUE = "' || v_value || '" ' || v_attribute || '>' );
              htp.p('</TD>');
              END IF;
           END IF;

           IF (v_items_table(i).attribute_code = 'ICX_CATEGORY_NAME' AND
               UPPER(v_items_table(i).item_style) = 'TEXT') THEN
              htp.tableData(icx_util.LOVButton(178,'ICX_CATEGORY_NAME', 601, 'ICX_REQ_SPECIAL_ORDER', 'one_time', 'data','FUNCTIONAL_AREA_ID = 2'), CATTRIBUTES => 'ALIGN="LEFT" width=200');
           ELSIF (v_items_table(i).attribute_code = 'ICX_UNIT_OF_MEASUREMENT'
                  AND UPPER(v_items_table(i).item_style) = 'TEXT') THEN
              htp.tableData(icx_util.LOVButton(178,'ICX_UNIT_OF_MEASUREMENT', 601, 'ICX_REQ_SPECIAL_ORDER', 'one_time', 'data'), CATTRIBUTES => 'ALIGN="LEFT" width=200');
           ELSIF v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME'
                 AND  v_vendor_on_flag = 'Y' THEN
              htp.tableData(icx_util.LOVButton(178,'ICX_SUGGESTED_VENDOR_NAME', 601, 'ICX_REQ_SPECIAL_ORDER', 'one_time', 'data'), CATTRIBUTES => 'ALIGN="LEFT" width=200');
           ELSIF v_items_table(i).lov_attribute_code is not NULL AND
                 v_items_table(i).lov_region_code is not NULL  AND
                 v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_PHONE' AND
                 v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_CONTACT' AND
                 v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_SITE' AND
                 v_items_table(i).attribute_code <> 'ICX_SUGGESTED_VENDOR_NAME' AND
                 v_items_table(i).node_display_flag = 'Y' AND
                 v_items_table(i).update_flag = 'Y' AND
                 v_items_table(i).item_style <> 'HIDDEN' AND
                 v_items_table(i).item_style <> 'POPLIST' THEN
               htp.tableData(icx_util.LOVButton(178,v_items_table(i).attribute_code, 601, 'ICX_REQ_SPECIAL_ORDER','one_time','data'), CATTRIBUTES => 'ALIGN="LEFT" width=200');

           END IF;
           htp.tableRowClose;
         END IF;

  END LOOP;
  END IF; /* table count > 0 */


  htp.tableRowOpen;
  htp.tableRowClose;

  htp.formHidden('v_category_pop_list', v_category_pop_list);
  htp.formHidden('v_uom_pop_list', v_uom_pop_list);
/*
  htp.tableRowOpen;
  htp.tableData;
  htp.p('<TD>');
  FND_MESSAGE.SET_NAME('BOM','ADD');
  icx_util.DynamicButton(P_ButtonText     => c_prompts(9),
                        P_ImageFileName   => 'FNDBNEW.gif',
		        P_OnMouseOverText => FND_MESSAGE.GET,
                        P_HyperTextCall   => 'javascript:imClicked()',
                        P_LanguageCode    => v_lang,
                        P_JavaScriptFlag  => FALSE);


  htp.p('</TD>');
  htp.tableRowClose;
*/
  htp.tableClose;

  htp.p('</FORM>');

  htp.bodyClose;
  htp.htmlClose;

 END IF; /* if validate session */
EXCEPTION

 WHEN OTHERS THEN
   htp.p('Error in Special Order ' || substr(SQLERRM, 1, 512));
   -- icx_util.add_error(substr(SQLERRM, 12, 512));
   -- icx_util.error_page_print;


END ;


PROCEDURE add_item_to_cart (n_org  IN VARCHAR2,
                            cartId in VARCHAR2,
                            icx_category_id IN VARCHAR2 DEFAULT NULL,
                            icx_category_name IN VARCHAR2 DEFAULT NULL,
                            icx_item_description IN VARCHAR2 DEFAULT NULL,
                            icx_qty_v IN VARCHAR2 DEFAULT NULL,
                            icx_unit_of_measurement IN VARCHAR2 DEFAULT NULL,
                            icx_unit_price IN VARCHAR2 DEFAULT NULL,
                            icx_suggested_vendor_item_num IN VARCHAR2 DEFAULT NULL,
                            icx_suggested_vendor_name IN VARCHAR2 DEFAULT NULL,
                            icx_suggested_vendor_site IN VARCHAR2 DEFAULT NULL,
                            icx_suggested_vendor_contact IN VARCHAR2 DEFAULT NULL,
                            icx_suggested_vendor_phone IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_1 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_2 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_3 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_4 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_5 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_6 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_7 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_8 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_9 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_10 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_11 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_12 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_13 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_14 IN VARCHAR2 DEFAULT NULL,
                            icx_line_attribute_15 IN VARCHAR2 DEFAULT NULL,
                            icx_line_type_id IN VARCHAR2 DEFAULT NULL,
                            v_category_pop_list IN VARCHAR2 DEFAULT NULL,
                            v_uom_pop_list IN VARCHAR2 DEFAULT NULL)

IS

 order_has_error BOOLEAN := FALSE;
 v_error_text VARCHAR2(1000) := NULL;
 v_special_order_rec special_order_record;
 v_error_flag VARCHAR2(2) := NULL;
 v_rows_inserted VARCHAR2(3) := NULL;
 v_qty_inserted VARCHAR2(3) := NULL;
 l_order_total_message    varchar2(300) := NULL;
 l_pad number := NULL;
 l_qty number:= NULL;
 l_price number:= NULL;

 CURSOR getCatId(catname VARCHAR2) IS
 SELECT category_id
 FROM mtl_categories_kfv
 WHERE concatenated_segments = catname;

 CURSOR get_uom(v_uom VARCHAR2) IS
 SELECT unit_of_measure
 FROM mtl_units_of_measure
 WHERE unit_of_measure = v_uom;

BEGIN

IF (icx_sec.validatesession('ICX_REQS')) THEN

 icx_util.error_page_setup;

 /* Uncomment for debugging -- Debug code
 htp.p('Cart Id: ' || cartId);
 htp.p('Decrypted cart id : ' || icx_call.decrypt2(cartId)); htp.br;
 htp.p('Category Id: ' || icx_category_id);
 htp.p('Catergory Name : ' || icx_category_name);
 htp.p('Unit of measurement : ' || icx_unit_of_measurement);
 htp.p('Suggested vendor name: ' || icx_suggested_vendor_name );
 htp.p('Suggested vendor site: ' || icx_suggested_vendor_site );
 htp.p('Suggested vendor contact: ' || icx_suggested_vendor_contact );
 htp.p('Suggested vendor phone: ' || icx_suggested_vendor_phone );
 htp.p('v_category_pop_list : ' || v_category_pop_list );
 htp.p('v_uom_pop_list : ' || v_uom_pop_list );
 htp.br;
 */


 IF (icx_category_id IS NULL) AND (v_category_pop_list <> 'Y') THEN
    -- validate category
    OPEN  getCatId(ICX_CATEGORY_NAME);
    FETCH getCatId INTO v_special_order_rec.category_id;
    IF getCatId%NOTFOUND THEN
        v_error_flag := 'Y';
        FND_MESSAGE.SET_NAME('MRP','EC_CAT');
        v_error_text := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
        FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',v_error_text);
        v_error_text := FND_MESSAGE.GET || '<BR>';
    END IF;
    CLOSE getCatId;
 ELSIF (icx_category_id IS NULL) AND (v_category_pop_list = 'Y') THEN
    /* if category is pop list, the category id is returned in the name */
    v_special_order_rec.category_id := icx_category_name;
 END IF; /* category_id is NULL */

 IF  v_uom_pop_list <> 'Y' THEN
    -- Validate Unit of measurement
    OPEN get_uom(ICX_UNIT_OF_MEASUREMENT);
    FETCH get_uom into v_special_order_rec.unit_of_measurement;
    IF get_uom%NOTFOUND THEN
       v_error_flag := 'Y';
       FND_MESSAGE.SET_NAME('CS','CS_ALL_INVALID_UOM_CODE');
       FND_MESSAGE.SET_TOKEN('UOM_CODE',ICX_UNIT_OF_MEASUREMENT);
       v_error_text := v_error_text || FND_MESSAGE.GET || '<BR>';
    END IF;
    CLOSE get_uom;
 ELSE
   v_special_order_rec.unit_of_measurement := icx_unit_of_measurement;
 END IF; /* Unit of measurement is not null */

 /* Quantity cannot be zero. */

  l_pad := instr(icx_qty_v,'.',1,2);
  if (l_pad > 2) then
     l_qty := substr(icx_qty_v,1,l_pad - 1);
  elsif (l_pad > 0) then
     l_qty := 0;
  else
     l_qty := icx_qty_v;
  end if;

  l_pad := instr(icx_unit_price,'.',1,2);
  if (l_pad > 2) then
     l_price := substr(icx_unit_price,1,l_pad - 1);
  elsif (l_pad > 0) then
     l_price := 0;
  else
     l_price := icx_unit_price;
  end if;

 IF (l_qty = 0)  THEN
       v_error_flag := 'Y';
       FND_MESSAGE.SET_NAME('ICX','ICX_QTY_IS_ZERO');
       v_error_text := v_error_text || FND_MESSAGE.GET;
 END IF;


 /* Build the special_order_record */

 v_special_order_rec.cart_id := cartId;
 -- v_special_order_rec.category_id := icx_category_id;
 v_special_order_rec.category_name := icx_category_name;
 v_special_order_rec.item_description := icx_item_description;
 v_special_order_rec.qty_v := l_qty;
 -- v_special_order_rec.unit_of_measurement := icx_unit_of_measurement;
 v_special_order_rec.unit_price := l_price;
 -- v_special_order_rec.unit_price := icx_unit_price;
 v_special_order_rec.suggested_vendor_item_num := icx_suggested_vendor_item_num;
 v_special_order_rec.suggested_vendor_name := icx_suggested_vendor_name;
 v_special_order_rec.suggested_vendor_site := icx_suggested_vendor_site;
 v_special_order_rec.suggested_vendor_contact := icx_suggested_vendor_contact;
 v_special_order_rec.suggested_vendor_phone := icx_suggested_vendor_phone;
 v_special_order_rec.line_attribute_1 := icx_line_attribute_1;
 v_special_order_rec.line_attribute_2 := icx_line_attribute_2;
 v_special_order_rec.line_attribute_3 := icx_line_attribute_3;
 v_special_order_rec.line_attribute_4 := icx_line_attribute_4;
 v_special_order_rec.line_attribute_5 := icx_line_attribute_5;
 v_special_order_rec.line_attribute_6 := icx_line_attribute_6;
 v_special_order_rec.line_attribute_7 := icx_line_attribute_7;
 v_special_order_rec.line_attribute_8 := icx_line_attribute_8;
 v_special_order_rec.line_attribute_9 := icx_line_attribute_9;
 v_special_order_rec.line_attribute_10 := icx_line_attribute_10;
 v_special_order_rec.line_attribute_11 := icx_line_attribute_11;
 v_special_order_rec.line_attribute_12 := icx_line_attribute_12;
 v_special_order_rec.line_attribute_13 := icx_line_attribute_13;
 v_special_order_rec.line_attribute_14 := icx_line_attribute_14;
 v_special_order_rec.line_attribute_15 := icx_line_attribute_15;
 v_special_order_rec.line_type_id := icx_line_type_id;

 IF v_error_flag = 'Y' THEN
  v_special_order_rec.category_id := icx_category_id;
  v_special_order_rec.unit_of_measurement := icx_unit_of_measurement;
  special_order_display(n_org, v_special_order_rec, v_error_flag, v_error_text);
 ELSE
   insert_order_to_cart_line (v_special_order_rec, l_order_total_message);
   -- v_qty_inserted := icx_qty_v; /* Number of items added */
   v_rows_inserted := '1'; /* Number of lines added; one in this case */
   special_order_display(n_org, v_rows_inserted => v_rows_inserted,
                 v_order_total_message => l_order_total_message);
 END IF;
END IF; /* Validate session */

EXCEPTION

 WHEN OTHERS THEN
   -- htp.p('Error in add to item ' || substr(SQLERRM, 1, 512));
   v_error_flag := 'Y';
   v_error_text := v_error_text || substr(SQLERRM, 12, 512);
   v_special_order_rec.category_id := icx_category_id;
   v_special_order_rec.unit_of_measurement := icx_unit_of_measurement;
   special_order_display(n_org, v_special_order_rec, v_error_flag, v_error_text);
   -- icx_util.add_error(substr(SQLERRM, 12, 512));
   -- icx_util.error_page_print;

END add_item_to_cart;

PROCEDURE  insert_order_to_cart_line (v_special_order_rec  IN
                                       special_order_record,
                                      l_order_total_message OUT VARCHAR2) IS

 v_cart_header_rec  icx_shopping_carts%ROWTYPE;
 v_line_type_id  NUMBER := NULL;
 v_cart_id NUMBER := NULL;
 l_cart_line_id NUMBER := NULL;

 l_currency       varchar2(15);
 l_precision      NUMBER(1);
 l_fmt_mask       varchar2(32);
 l_order_total NUMBER := NULL;
 v_order_total    varchar2(30) := NULL;
 v_cart_line_number NUMBER := NULL;

 v_error_text VARCHAR2(1000) := NULL;
 v_error_flag VARCHAR2(2) := NULL;

 /* The following variables added for default accounting */
 l_emp_id number;
 l_account_id NUMBER := NULL;
 l_account_num VARCHAR2(2000) := NULL;
 l_segments fnd_flex_ext.SegmentArray;

 CURSOR cart_header_details(v_cart_id VARCHAR2) IS
 SELECT * FROM icx_shopping_carts
 WHERE CART_ID = to_number(v_cart_id)
 FOR UPDATE;

BEGIN

  icx_util.error_page_setup;

  SELECT line_type_id  INTO v_line_type_id
  FROM po_system_parameters
  WHERE rownum < 2;

  v_cart_id := icx_call.decrypt2(v_special_order_rec.cart_id);
  OPEN cart_header_details(v_cart_id);
  FETCH cart_header_details INTO v_cart_header_rec;
  CLOSE cart_header_details;

--changed by alex for attachment
--  SELECT icx_shopping_cart_lines_s.nextval INTO l_cart_line_id
--  FROM DUAL;
--new code:
  SELECT PO_REQUISITION_LINES_S.nextval INTO l_cart_line_id
  FROM DUAL;


  /* Select the max of the cart_line_number for ordering */
  SELECT max(cart_line_number) + 1 into v_cart_line_number
  FROM icx_shopping_cart_lines
  WHERE cart_id = v_cart_id;

  IF v_cart_line_number IS NULL THEN
   /* This is the first one  */
   v_cart_line_number := 1;
  END IF;

  INSERT INTO icx_shopping_cart_lines
             (
              CART_LINE_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              CART_ID,
              ITEM_DESCRIPTION,
              QUANTITY,
              UNIT_PRICE,
              CATEGORY_ID,
              UNIT_OF_MEASURE,
              LINE_TYPE_ID,
              DESTINATION_ORGANIZATION_ID,
              DELIVER_TO_LOCATION_ID,
              SUGGESTED_VENDOR_NAME,
              SUGGESTED_VENDOR_SITE,
              LINE_ATTRIBUTE1,
              LINE_ATTRIBUTE2,
              LINE_ATTRIBUTE3,
              LINE_ATTRIBUTE4,
              LINE_ATTRIBUTE5,
              LINE_ATTRIBUTE6,
              LINE_ATTRIBUTE7,
              LINE_ATTRIBUTE8,
              LINE_ATTRIBUTE9,
              LINE_ATTRIBUTE10,
              LINE_ATTRIBUTE11,
              LINE_ATTRIBUTE12,
              LINE_ATTRIBUTE13,
              LINE_ATTRIBUTE14,
              LINE_ATTRIBUTE15,
              NEED_BY_DATE,
              SUGGESTED_VENDOR_CONTACT,
              SUGGESTED_VENDOR_PHONE,
              SUGGESTED_VENDOR_ITEM_NUM,
              SUPPLIER_ITEM_NUM,
              ORG_ID,
              DELIVER_TO_LOCATION,
              CUSTOM_DEFAULTED,
              CART_LINE_NUMBER
             )
     VALUES  (
              l_cart_line_id,
              sysdate,
              v_cart_header_rec.created_by,
              sysdate,
              v_cart_header_rec.created_by,
              v_cart_id,
              v_special_order_rec.item_description,
              to_number(v_special_order_rec.qty_v),
              to_number(v_special_order_rec.unit_price),
              to_number(v_special_order_rec.category_id),
              v_special_order_rec.unit_of_measurement,
              v_line_type_id,
              v_cart_header_rec.destination_organization_id,
              v_cart_header_rec.deliver_to_location_id,
              v_special_order_rec.suggested_vendor_name,
              v_special_order_rec.suggested_vendor_site,
              v_special_order_rec.line_attribute_1,
              v_special_order_rec.line_attribute_2,
              v_special_order_rec.line_attribute_3,
              v_special_order_rec.line_attribute_4,
              v_special_order_rec.line_attribute_5,
              v_special_order_rec.line_attribute_6,
              v_special_order_rec.line_attribute_7,
              v_special_order_rec.line_attribute_8,
              v_special_order_rec.line_attribute_9,
              v_special_order_rec.line_attribute_10,
              v_special_order_rec.line_attribute_11,
              v_special_order_rec.line_attribute_12,
              v_special_order_rec.line_attribute_13,
              v_special_order_rec.line_attribute_14,
              v_special_order_rec.line_attribute_15,
              v_cart_header_rec.need_by_date,
              v_special_order_rec.suggested_vendor_contact,
              v_special_order_rec.suggested_vendor_phone,
              v_special_order_rec.suggested_vendor_item_num,
              v_special_order_rec.suggested_vendor_item_num,
              v_cart_header_rec.org_id,
              v_cart_header_rec.deliver_to_location,
              'N',
              v_cart_line_number
            );

  -- Get the default accounts and update distributions
  icx_req_acct2.get_default_account(v_cart_id,
                        l_cart_line_id,
                        v_cart_header_rec.deliver_to_requestor_id,
                        v_cart_header_rec.org_id,
                        l_account_id,
                        l_account_num);

  /* Call custom default and validation for the line */
    icx_req_custom.reqs_default_lines('NO',v_cart_id);

  COMMIT;

  /* get the order total; do this after custom defaults as it clould
     modify the price or quantity */
  SELECT SUM(quantity * unit_price) INTO l_order_total
  FROM  icx_shopping_cart_lines
  WHERE cart_id = v_cart_id;

  icx_req_navigation.get_currency(v_cart_header_rec.destination_organization_id,
                                  l_currency, l_precision, l_fmt_mask);

   /* Build the new order total message */
   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_TOTAL');
   FND_MESSAGE.SET_TOKEN('CURRENCY_CODE', l_currency);
   v_order_total := to_char(to_number(l_order_total), fnd_currency.get_format_mask(l_currency, 30));
   FND_MESSAGE.SET_TOKEN('REQUISITION_TOTAL', v_order_total);
   l_order_total_message := FND_MESSAGE.GET;

EXCEPTION

 WHEN OTHERS THEN
   -- htp.p('Error in insert line' || substr(SQLERRM, 1, 512));
   icx_util.add_error(substr(SQLERRM, 12, 512));
   icx_util.error_page_print;

END insert_order_to_cart_line;


-- to remove later the following procedure
------------------------------------------------------------------------
procedure chk_vendor_on(v_items_table IN ak_query_pkg.items_table_type,
                        v_on OUT varchar2) is
------------------------------------------------------------------------

  v_vendor_on_flag varchar2(1);
begin

       v_on := 'N';
       v_vendor_on_flag := 'N';
       for i in v_items_table.first .. v_items_table.last loop
         if (v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' or
          v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
          v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
          v_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE') AND
          v_items_table(i).node_display_flag = 'Y'  AND
          v_items_table(i).update_flag = 'Y' AND
          v_items_table(i).secured_column <> 'T' AND
          v_items_table(i).item_style <> 'HIDDEN' then

           v_vendor_on_flag := 'Y';
           exit;
         end if;
       end loop;

       v_on := v_vendor_on_flag;
end chk_vendor_on;
END icx_req_special_ord;

/
