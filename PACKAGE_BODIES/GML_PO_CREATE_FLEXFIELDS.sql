--------------------------------------------------------
--  DDL for Package Body GML_PO_CREATE_FLEXFIELDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_CREATE_FLEXFIELDS" AS
/* $Header: GMLFLRGB.pls 115.4 99/10/26 11:36:04 porting ship $ */
/* +========================================================================+
 |                                                                        |
 | PROCEDURE                                                              |
 |   compute_duom_qty                                                       |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from the procedure to create segments.      |
 |                                                                        |
 |   This procedure computes the Dual Unit of Measure Quantity for        |
 |   Item Second Unit of Measure.                                         |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   09-DEC-97  Ravi Dasani           Created.                            |
 |                                                                        |
 +========================================================================+ */

FUNCTION compute_duom_qty
( v_item_no  IN   IC_ITEM_MST.ITEM_NO%TYPE,
  v_um1      IN   CHAR,
  v_order1   IN   NUMBER,
  v_um2      IN   CHAR)
  return NUMBER
IS

  CURSOR   gm_item_id_cur IS
    SELECT item_id
    FROM   ic_item_mst
    WHERE  item_no = v_item_no;

  v_order2        number;
  v_std_factor1   NUMBER;
  v_std_factor2   NUMBER;
  v_type1         VARCHAR2(4);
  v_type2         VARCHAR2(4);
  v_std_factor    NUMBER;
  v_type          VARCHAR2(4);
  v_type_factor02 NUMBER := 1;
  v_type_factor01 NUMBER := 1;

  v_um            VARCHAR2(4);

  err_num         NUMBER;
  err_msg         VARCHAR2(100);
    fhandle                 utl_file.file_type;

  gm_item_id         IC_ITEM_MST.ITEM_ID%TYPE;

BEGIN

   /* 11/6/1998 T. Ricci added*/

    OPEN gm_item_id_cur;
    FETCH gm_item_id_cur INTO gm_item_id;
    CLOSE gm_item_id_cur;

   v_order2 :=GMICUOM.uom_conversion
    (gm_item_id,0,
     v_order1,
     v_um1,
     v_um2,0);

   IF v_order2 < 0 THEN
      v_order2 := 0;
   END IF;

   return (v_order2);

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    return (0);

END compute_duom_qty;

 /*
 +========================================================================+
 |                                                                        |
 | PROCEDURE                                                              |
 |   create_val_sets                                                      |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from the script to set up flexfields.       |
 |                                                                        |
 |   This procedure creates new value sets which are used for the         |
 |   following descriptive flexfields:  Company Code, QC Grade, Base UOM, |
 |   and Secondary UOM.                                                   |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   23-SEP-97  Kristie Chen          Created.                            |
 |   17-NOV-98  Tony Ricci removed IN VARCHAR2 from valueset_exists       |
 |              and delete_valueset for R11 changes                       |
 +========================================================================+ */

PROCEDURE create_val_sets IS
BEGIN

  FND_FLEX_VAL_API.SET_SESSION_MODE('customer_data');

/* delete valuesets if they exist */

  IF fnd_flex_val_api.valueset_exists('CPG_CO_CODE') THEN
    fnd_flex_val_api.delete_valueset('CPG_CO_CODE');
  End IF;

  IF fnd_flex_val_api.valueset_exists('CPG_QC_GRADE') THEN
    fnd_flex_val_api.delete_valueset('CPG_QC_GRADE');
  End IF;

  IF fnd_flex_val_api.valueset_exists('CPG_BASE_UOM') THEN
    fnd_flex_val_api.delete_valueset('CPG_BASE_UOM');
  End IF;

  IF fnd_flex_val_api.valueset_exists('CPG_SEC_UOM') THEN
    fnd_flex_val_api.delete_valueset('CPG_SEC_UOM');
  End IF;

  IF fnd_flex_val_api.valueset_exists('CPG_PO_NO') THEN
    fnd_flex_val_api.delete_valueset('CPG_PO_NO');
  End IF;

  IF fnd_flex_val_api.valueset_exists('CPG_PO_QTY') THEN
    fnd_flex_val_api.delete_valueset('CPG_PO_QTY');
  End IF;

/* create value sets */

  fnd_flex_val_api.create_valueset_table(
        value_set_name => 'CPG_CO_CODE',
        description => 'Displays co code',
        security_available => 'N',
        enable_longlist => 'Y',
        format_type => 'Char',
        maximum_size => 30,
        numbers_only => 'N',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null,
        table_appl_short_name => 'PO',
        table_name => 'SY_ORGN_MST',
        allow_parent_values => 'N',
        value_column_name => 'orgn_code',
        value_column_type => 'Char',
        value_column_size => 30,
        meaning_column_name => 'orgn_name',
        meaning_column_type => 'Char',
        meaning_column_size => 40,
        id_column_name => NULL, /* Column Name has been nullified*/
        id_column_type => NULL,
        id_column_size => NULL,
        where_order_by => 'Where co_code in (select co_code from gl_plcy_mst where org_id=:$PROFILES$.ORG_ID) Order by ORGN_CODE');

  fnd_flex_val_api.create_valueset_table(
        value_set_name => 'CPG_PO_NO',
        description => 'Displays Purchase Order Numbers',
        security_available => 'N',
        enable_longlist => 'Y',
        format_type => 'Char',
        maximum_size => 30,
        numbers_only => 'N',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null,
        table_appl_short_name => 'PO',
        table_name => 'PO_HEADERS_ALL POH',
        allow_parent_values => 'N',
        value_column_name => 'segment1',
        value_column_type => 'Varchar2',
        value_column_size => 20,
        meaning_column_name => 'comments',
        meaning_column_type => 'Char',
        meaning_column_size => 40,
        id_column_name => NULL, /* Column Name has been nullified*/
        id_column_type => NULL,
        id_column_size => NULL,
        where_order_by => 'Where  POH.TYPE_LOOKUP_CODE in
                        (''STANDARD'', ''PLANNED'', ''BLANKET'')
                        AND POH.APPROVED_FLAG = ''Y''');

  fnd_flex_val_api.create_valueset_table(
        value_set_name => 'CPG_QC_GRADE',
        description => 'Displays qc grade',
        security_available => 'N',
        enable_longlist => 'Y',
        format_type => 'Char',
        maximum_size => 30,
        numbers_only => 'N',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null,
        table_appl_short_name => 'PO',
        table_name => 'GMS_GRAD_MST',
        allow_parent_values => 'N',
        value_column_name => 'qc_grade',
        value_column_type => 'Char',
        value_column_size => 30,
        meaning_column_name => 'QC_GRADE_DESC',
        meaning_column_type => 'Char',
        meaning_column_size => 40,
        id_column_name => NULL, /* Column Name has been nullified*/
        id_column_type => NULL,
        id_column_size => NULL,
        where_order_by => 'Order by QC_GRADE');

  fnd_flex_val_api.create_valueset_table(
        value_set_name => 'CPG_BASE_UOM',
        description => 'Displays base uom',
        security_available => 'N',
        enable_longlist => 'Y',
        format_type => 'Char',
        maximum_size => 30,
        numbers_only => 'N',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null,
        table_appl_short_name => 'PO',
        table_name => 'GMS_ITEM_MST',
        allow_parent_values => 'N',
        value_column_name => 'item_um',
        value_column_type => 'Char',
        value_column_size => 30,
        id_column_name => NULL, /* Column Name has been nullified*/
        id_column_type => NULL,
        id_column_size => NULL,
        where_order_by => 'where item_no=decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null)');

  fnd_flex_val_api.create_valueset_table(
        value_set_name => 'CPG_SEC_UOM',
        description => 'Displays secondary uom',
        security_available => 'N',
        enable_longlist => 'Y',
        format_type => 'Char',
        maximum_size => 30,
        numbers_only => 'N',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null,
        table_appl_short_name => 'PO',
        table_name => 'GMS_ITEM_MST',
        allow_parent_values => 'N',
        value_column_name => 'item_um2',
        value_column_type => 'Char',
        value_column_size => 30,
        id_column_name => NULL, /* Column Name has been nullified*/
        id_column_type => NULL,
        id_column_size => NULL,
        where_order_by => 'where item_no=decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null)');

  fnd_flex_val_api.create_valueset_none(
        value_set_name => 'CPG_PO_QTY',
        description => 'CPG Purchasing Base and Dual Qty',
        security_available => 'N',
        enable_longlist => 'N',
        format_type => 'Number',
        maximum_size => 10,
        precision => 2,
        numbers_only => 'Y',
        uppercase_only => 'N',
        right_justify_zero_fill => 'N',
        min_value => null,
        max_value => null);
END create_val_sets;

 /*
 +========================================================================+
 |                                                                        |
 | PROCEDURE                                                              |
 |   delete_segments                                                      |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from the script to set up flexfields.       |
 |                                                                        |
 |   This procedure deletes the new descriptive flexfield segments, in    |
 |   order to create new ones.                                            |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   23-SEP-97  Kristie Chen          Created.                            |
 |   17-NOV-98  Tony Ricci removed application parameter (was 1st) for    |
 |              R11 changes to fnd_flex_dsc_api.delete_segment            |
 +========================================================================+
*/

procedure delete_segments IS
BEGIN
fnd_flex_dsc_api.set_session_mode('customer_data');

fnd_flex_dsc_api.delete_segment('PO', 'PO_HEADERS', 'Global Data Elements', 'GEMMS Organization');

fnd_flex_dsc_api.delete_segment('PO', 'PO_LINES', 'Global Data Elements', 'QC Grade');

fnd_flex_dsc_api.delete_segment('PO', 'PO_LINES', 'Global Data Elements', 'Base UOM');

fnd_flex_dsc_api.delete_segment('PO', 'PO_LINES', 'Global Data Elements', 'Base Qty');

fnd_flex_dsc_api.delete_segment('PO', 'PO_LINES', 'Global Data Elements', 'Secondary UOM');

fnd_flex_dsc_api.delete_segment('PO', 'PO_LINES', 'Global Data Elements', 'Secondary Qty');

end delete_segments;


 /*
 +========================================================================+
 |                                                                        |
 | PROCEDURE                                                              |
 |   create_segments                                                      |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from the script to set up flexfields.       |
 |                                                                        |
 |   This procedure creates the new descriptive flexfield segments.       |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   23-SEP-97  Kristie Chen          Created.                            |
 |   17-NOV-98  Tony Ricci removed application parameter (was 1st) for    |
 |              R11 changes to fnd_flex_dsc_api.create_segment and        |
 |              fnd_flex_dsc_api.freeze                                   |
 +========================================================================+ */

procedure create_segments IS
BEGIN

fnd_flex_dsc_api.set_session_mode('customer_data');

fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_HEADERS',
   context_name => 'Global Data Elements',
   name => 'GEMMS Organization',
   column => 'ATTRIBUTE15',
   description => 'GEMMS Organization',
   sequence_number => 1,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_CO_CODE',
   default_type => 'Profile',
   default_value => 'GEMMS_DEFAULT_ORGN',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'GEMMS Organization',
   window_prompt => 'GEMMS Organization',
   range => NULL,
   srw_parameter => NULL);


fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES',
   context_name => 'Global Data Elements',
   name => 'QC Grade',
   column => 'ATTRIBUTE11',
   description => 'QC Grade',
   sequence_number => 1,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_QC_GRADE',
   default_type => 'SQL Statement',
   default_value => 'select qc_grade from gms_item_mst where item_no=decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null)',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'QC Grade',
   window_prompt => 'QC Grade',
   range => NULL,
   srw_parameter => NULL);



fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES',
   context_name => 'Global Data Elements',
   name => 'Base UOM',
   column => 'ATTRIBUTE12',
   description => 'Base UOM',
   sequence_number => 2,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_BASE_UOM',
   default_type => 'SQL Statement',
   default_value => 'select item_um from gms_item_mst where item_no=decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null)',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'Base UOM',
   window_prompt => 'Base UOM',
   range => NULL,
   srw_parameter => NULL);



fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES',
   context_name => 'Global Data Elements',
   name => 'Base Qty',
   column => 'ATTRIBUTE13',
   description => 'Base Qty',
   sequence_number => 3,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_PO_QTY',
   default_type => 'SQL Statement',
   default_value => 'select gml_po_create_flexfields.compute_duom_qty(decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null),
decode(:system.current_block, ''PO_LINES'', :po_lines.unit_meas_lookup_code,  null) ,
decode(:system.current_block, ''PO_LINES'', :po_lines.quantity,  null), :$FLEX$.CPG_BASE_UOM) from dual',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'Base Qty',
   window_prompt => 'Base Qty',
   range => NULL,
   srw_parameter => NULL);



fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES',
   context_name => 'Global Data Elements',
   name => 'Secondary UOM',
   column => 'ATTRIBUTE14',
   description => 'Secondary UOM',
   sequence_number => 4,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_SEC_UOM',
   default_type => 'SQL Statement',
   default_value => 'select item_um2 from gms_item_mst where item_no=decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null)',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'Secondary UOM',
   window_prompt => 'Secondary UOM',
   range => NULL,
   srw_parameter => NULL);



fnd_flex_dsc_api.create_segment(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES',
   context_name => 'Global Data Elements',
   name => 'Secondary Qty',
   column => 'ATTRIBUTE15',
   description => 'Secondary Qty',
   sequence_number => 5,
   enabled => 'Y',
   displayed => 'Y',
   value_set => 'CPG_PO_QTY',
   default_type => 'SQL Statement',
   default_value => 'select gml_po_create_flexfields.compute_duom_qty(decode(:system.current_block, ''PO_LINES'', :po_lines.item_number,  null),:po_lines.unit_meas_lookup_code,
decode(:system.current_block, ''PO_LINES'', :po_lines.quantity,  null), :$FLEX$.CPG_SEC_UOM) from dual',
   required => 'N',
   security_enabled => 'N',
   display_size => 8,
   description_size => 8,
   concatenated_description_size => 8,
   list_of_values_prompt => 'Secondary Qty',
   window_prompt => 'Secondary Qty',
   range => NULL,
   srw_parameter => NULL);


fnd_flex_dsc_api.freeze(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_HEADERS');


fnd_flex_dsc_api.freeze(
   appl_short_name => 'PO' ,
   flexfield_name => 'PO_LINES');

end create_segments;

/* +========================================================================+
 |                                                                        |
 | PROCEDURE                                                              |
 |   get_item_um2                                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from CUSTOM.pll to get the item_um2 in      |
 |   order to perform a unit of measure conversion                        |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   17-MAR-99  Tony Ricci            Created for Bug 817680              |
 |                                                                        |
 +========================================================================+ */

FUNCTION get_item_um2
( v_item_no  IN   IC_ITEM_MST.ITEM_NO%TYPE)
  return VARCHAR2
IS

  CURSOR   gm_item_um2_cur IS
    SELECT item_um2
    FROM   ic_item_mst
    WHERE  item_no = v_item_no;

  err_num         NUMBER;
  err_msg         VARCHAR2(100);

  gm_item_um2         IC_ITEM_MST.ITEM_UM2%TYPE;

BEGIN

    OPEN gm_item_um2_cur;
    FETCH gm_item_um2_cur INTO gm_item_um2;
    CLOSE gm_item_um2_cur;

   return (gm_item_um2);

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    return (0);

END get_item_um2;

END gml_po_create_flexfields;

/
