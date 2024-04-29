--------------------------------------------------------
--  DDL for Package Body EGO_GTIN_ATTRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_GTIN_ATTRS_PVT" AS
/* $Header: EGOVGATB.pls 120.27 2007/08/16 14:21:37 dsakalle ship $ */

  TYPE l_attr_disp_name_tbl_type IS TABLE OF VARCHAR2(1000) INDEX BY VARCHAR2(1000);
  l_single_row_attrs_disp_names   l_attr_disp_name_tbl_type;
  l_multi_row_attrs_disp_names    l_attr_disp_name_tbl_type;
  l_op_attrs_disp_names           l_attr_disp_name_tbl_type;
  G_MISS_NUM         NUMBER       :=  EGO_ITEM_PUB.G_INTF_NULL_NUM;
  G_MISS_CHAR        VARCHAR2(1)  :=  EGO_ITEM_PUB.G_INTF_NULL_CHAR;
  G_MISS_DATE        DATE         :=  EGO_ITEM_PUB.G_INTF_NULL_DATE;
  g_row_identifier   NUMBER;
  EGO_APPL_ID        CONSTANT     NUMBER := 431;
  G_CALLED_FROM_INTF VARCHAR2(1);
  G_DATA_SET_ID      NUMBER;
  G_ENTITY_ID        NUMBER;
  G_ENTITY_INDEX     NUMBER;
  G_ENTITY_CODE      VARCHAR2(100);

-- CHG#
  PROCEDURE Debug_Msg(p_message VARCHAR2) IS
  BEGIN
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_module => 'EGO_GTIN_ATTRS_PVT',
                                    p_message => p_message);
  END Debug_Msg;

  /*
   ** This function returns TRUE if check digit is invalid
   */
  FUNCTION Is_Check_Digit_Invalid (p_code VARCHAR2) RETURN BOOLEAN IS
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_digits            num_tbl_type;
    l_check_digit       BINARY_INTEGER;
    l_sum_of_right      BINARY_INTEGER;
    l_sum_of_left       BINARY_INTEGER;
    l_sum_of_all        NUMBER;
    k                   BINARY_INTEGER;
    l_reminder          BINARY_INTEGER;
    l_calc_check_digit  BINARY_INTEGER;
  BEGIN
    FOR i IN 1..(LENGTH(p_code)-1) LOOP
      l_digits(i) := SUBSTR(p_code, i, 1);
    END LOOP;
    l_check_digit := SUBSTR(p_code, LENGTH(p_code), 1);

    k := LENGTH(p_code) - 1;
    l_sum_of_right := 0;
    WHILE k > 0 LOOP
      l_sum_of_right := l_sum_of_right + l_digits(k);
      k := k - 2;
    END LOOP;

    k := LENGTH(p_code) - 2;
    l_sum_of_left := 0;
    WHILE k > 0 LOOP
      l_sum_of_left := l_sum_of_left + l_digits(k);
      k := k - 2;
    END LOOP;

    l_sum_of_all := (l_sum_of_right*3) + l_sum_of_left;

    l_reminder := MOD(l_sum_of_all, 10);
    IF l_reminder = 0 THEN
      l_reminder := 10;
    END IF;

    l_calc_check_digit := 10 - l_reminder;

    IF l_check_digit <> l_calc_check_digit THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END Is_Check_Digit_Invalid;

  /*
   ** This function returns the display values for the attributes
   */
  FUNCTION Get_Attribute_Display_Name (p_attr_group_type VARCHAR2, p_database_column VARCHAR2) RETURN VARCHAR2 IS
    CURSOR c_attr_disp_names(l_attr_group_type VARCHAR2) IS
      SELECT APPLICATION_COLUMN_NAME as DATABASE_COLUMN, FORM_LEFT_PROMPT as DISPLAY_VALUE
      FROM FND_DESCR_FLEX_COL_USAGE_TL
      WHERE DESCRIPTIVE_FLEXFIELD_NAME = l_attr_group_type
        AND APPLICATION_ID = 431
        AND LANGUAGE = USERENV('LANG');
  BEGIN
    IF l_single_row_attrs_disp_names.FIRST IS NULL AND p_attr_group_type = 'EGO_ITEM_GTIN_ATTRS' THEN
      FOR i IN c_attr_disp_names('EGO_ITEM_GTIN_ATTRS') LOOP
        l_single_row_attrs_disp_names(i.DATABASE_COLUMN) := i.DISPLAY_VALUE;
      END LOOP;
    END IF;

    IF l_multi_row_attrs_disp_names.FIRST IS NULL AND p_attr_group_type = 'EGO_ITEM_GTIN_MULTI_ATTRS' THEN
      FOR i IN c_attr_disp_names('EGO_ITEM_GTIN_MULTI_ATTRS') LOOP
        l_multi_row_attrs_disp_names(i.DATABASE_COLUMN) := i.DISPLAY_VALUE;
      END LOOP;
    END IF;

    IF l_op_attrs_disp_names.FIRST IS NULL AND p_attr_group_type = 'EGO_MASTER_ITEMS' THEN
      FOR i IN c_attr_disp_names('EGO_MASTER_ITEMS') LOOP
        l_op_attrs_disp_names(i.DATABASE_COLUMN) := i.DISPLAY_VALUE;
      END LOOP;
    END IF;

    IF p_attr_group_type = 'EGO_ITEM_GTIN_ATTRS' THEN
      RETURN l_single_row_attrs_disp_names(p_database_column);
    ELSIF p_attr_group_type = 'EGO_ITEM_GTIN_MULTI_ATTRS' THEN
      RETURN l_multi_row_attrs_disp_names(p_database_column);
    ELSIF p_attr_group_type = 'EGO_MASTER_ITEMS' THEN
      RETURN l_op_attrs_disp_names(p_database_column);
    ELSE
      RETURN NULL;
    END IF;
  END Get_Attribute_Display_Name;

  /*
   ** This procedure populates the interface table rows for UCCnet attributes
   *  into pl/sql table
   */
  PROCEDURE Get_Gdsn_Intf_Rows( p_data_set_id IN  NUMBER
                               ,p_target_proc_status   IN  NUMBER
                               ,p_inventory_item_id    IN  NUMBER
                               ,p_organization_id      IN  NUMBER
                               ,p_ignore_delete        IN  VARCHAR2 DEFAULT 'N'
                               ,x_singe_row_attrs_rec  OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
                               ,x_multi_row_attrs_tbl  OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
                               ,x_return_status        OUT NOCOPY VARCHAR2
                               ,x_msg_count            OUT NOCOPY NUMBER
                               ,x_msg_data             OUT NOCOPY VARCHAR2
                              )
  IS
    CURSOR c_intf_single_row_attrs(c_inventory_item_id IN NUMBER, c_organization_id IN NUMBER) IS
      SELECT
        MAX(DECODE(ATTR_GROUP_INT_NAME, 'Date_Information', DECODE(ATTR_INT_NAME, 'Start_Availability_Date_Time', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS START_AVAILABILITY_DATE_TIME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Date_Information', DECODE(ATTR_INT_NAME, 'Consumer_Avail_Date_Time', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS CONSUMER_AVAIL_DATE_TIME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Date_Information', DECODE(ATTR_INT_NAME, 'End_Availability_Date_Time', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS END_AVAILABILITY_DATE_TIME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Date_Information', DECODE(ATTR_INT_NAME, 'Effective_Date', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS EFFECTIVE_DATE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_Identification', DECODE(ATTR_INT_NAME, 'ISBN_Number', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS ISBN_NUMBER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_Identification', DECODE(ATTR_INT_NAME, 'ISSN_Number', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS ISSN_NUMBER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_MARKING', DECODE(ATTR_INT_NAME, 'IS_INGREDIENT_IRRADIATED', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_INGREDIENT_IRRADIATED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_MARKING', DECODE(ATTR_INT_NAME, 'IS_TRADE_ITEM_GENETICALLY_MOD', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_GENETICALLY_MOD
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_MARKING', DECODE(ATTR_INT_NAME, 'IS_TRADE_ITEM_IRRADIATED', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_IRRADIATED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_MARKING', DECODE(ATTR_INT_NAME, 'IS_RAW_MATERIAL_IRRADIATED', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_RAW_MATERIAL_IRRADIATED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_Measurements', DECODE(ATTR_INT_NAME, 'DEGREE_OF_ORIGINAL_WORT', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DEGREE_OF_ORIGINAL_WORT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_Measurements', DECODE(ATTR_INT_NAME, 'FAT_PERCENT_IN_DRY_MATTER', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS FAT_PERCENT_IN_DRY_MATTER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'FMCG_Measurements', DECODE(ATTR_INT_NAME, 'PERCENT_OF_ALCOHOL_BY_VOL', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS PERCENT_OF_ALCOHOL_BY_VOL
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Unit_Indicator', DECODE(ATTR_INT_NAME, 'Is_Trade_Item_A_Consumer_Unit', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_A_CONSUMER_UNIT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Unit_Indicator', DECODE(ATTR_INT_NAME, 'Is_Trade_Item_A_Base_Unit', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_A_BASE_UNIT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Unit_Indicator', DECODE(ATTR_INT_NAME, 'Is_Trade_Item_Info_Private', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_INFO_PRIVATE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Unit_Indicator', DECODE(ATTR_INT_NAME, 'Is_Trade_Item_A_Variable_Unit', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_A_VARIABLE_UNIT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Handling_Information', DECODE(ATTR_INT_NAME, 'Stacking_Weight_Maximum', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS STACKING_WEIGHT_MAXIMUM
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Handling_Information', DECODE(ATTR_INT_NAME, 'Stacking_Factor', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS STACKING_FACTOR
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Material_Safety_Data', DECODE(ATTR_INT_NAME, 'Material_Safety_Data_Sheet_No', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS MATERIAL_SAFETY_DATA_SHEET_NO
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Order_Information', DECODE(ATTR_INT_NAME, 'Ordering_Lead_Time', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS ORDERING_LEAD_TIME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Order_Information', DECODE(ATTR_INT_NAME, 'Order_Quantity_Min', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS ORDER_QUANTITY_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Order_Information', DECODE(ATTR_INT_NAME, 'Order_Sizing_Factor', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS ORDER_SIZING_FACTOR
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Order_Information', DECODE(ATTR_INT_NAME, 'Order_Quantity_Max', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS ORDER_QUANTITY_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Order_Information', DECODE(ATTR_INT_NAME, 'Order_Quantity_Multiple', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS ORDER_QUANTITY_MULTIPLE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Packaging_Marking', DECODE(ATTR_INT_NAME, 'Is_Pack_Marked_With_Exp_Date', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_PACK_MARKED_WITH_EXP_DATE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Packaging_Marking', DECODE(ATTR_INT_NAME, 'Is_Package_Marked_As_Rec', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_PACKAGE_MARKED_AS_REC
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Packaging_Marking', DECODE(ATTR_INT_NAME, 'Is_Package_Marked_Ret', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_PACKAGE_MARKED_RET
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Packaging_Marking', DECODE(ATTR_INT_NAME, 'Is_Pack_Marked_With_Ingred', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_PACK_MARKED_WITH_INGRED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Packaging_Marking', DECODE(ATTR_INT_NAME, 'Is_Pack_Marked_With_Green_Dot', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_PACK_MARKED_WITH_GREEN_DOT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Price_Date_Information', DECODE(ATTR_INT_NAME, 'Effective_End_Date', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS EFFECTIVE_END_DATE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Price_Date_Information', DECODE(ATTR_INT_NAME, 'Suggested_Retail_Price', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS SUGGESTED_RETAIL_PRICE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Price_Date_Information', DECODE(ATTR_INT_NAME, 'Catalog_Price', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS CATALOG_PRICE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Price_Date_Information', DECODE(ATTR_INT_NAME, 'Effective_Start_Date', NVL(ATTR_VALUE_DATE, G_MISS_DATE), null), null)) AS EFFECTIVE_START_DATE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Price_Information', DECODE(ATTR_INT_NAME, 'Retail_Price_On_Trade_Item', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS RETAIL_PRICE_ON_TRADE_ITEM
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Del_To_Dist_Cntr_Temp_Min', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DEL_TO_DIST_CNTR_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uccnet_Storage_Temp_Min', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS STORAGE_HANDLING_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Storage_Handling_Temp_Max', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_STORAGE_HANDLING_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uccnet_Storage_Temp_Max', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS STORAGE_HANDLING_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Storage_Handling_Temp_Min', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_STORAGE_HANDLING_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Delivery_To_Mrkt_Temp_Max', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_DELIVERY_TO_MRKT_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Del_To_Dist_Cntr_Temp_Max', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DEL_TO_DIST_CNTR_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Delivery_To_Mrkt_Temp_Min', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DELIVERY_TO_MRKT_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Delivery_To_Mrkt_Temp_Min', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_DELIVERY_TO_MRKT_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Delivery_To_Mrkt_Temp_Max', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DELIVERY_TO_MRKT_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Del_To_Dist_Cntr_Temp_Max', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_DEL_TO_DIST_CNTR_TEMP_MAX
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Temperature_Information', DECODE(ATTR_INT_NAME, 'Uom_Del_To_Dist_Cntr_Temp_Min', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_DEL_TO_DIST_CNTR_TEMP_MIN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Brand_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS BRAND_NAME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Invoice_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS INVOICE_NAME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Sub_Brand', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS SUB_BRAND
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Eanucc_Code', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS EANUCC_CODE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'EANUCC_Type', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS EANUCC_TYPE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'DESCRIPTION_SHORT', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DESCRIPTION_SHORT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Trade_Item_Coupon', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS TRADE_ITEM_COUPON
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Trade_Item_Form_Description', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS TRADE_ITEM_FORM_DESCRIPTION
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Functional_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS FUNCTIONAL_NAME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Is_Barcode_Symbology_Derivable', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_BARCODE_SYMBOLOGY_DERIVABLE
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Retail_Brand_Owner_Gln', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS BRAND_OWNER_GLN
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Retail_Brand_Owner_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS BRAND_OWNER_NAME
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Hierarchy', DECODE(ATTR_INT_NAME, 'Quantity_Of_Comp_Lay_Item', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS QUANTITY_OF_COMP_LAY_ITEM
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Hierarchy', DECODE(ATTR_INT_NAME, 'Quantity_Of_Inner_Pack', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS QUANTITY_OF_INNER_PACK
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Hierarchy', DECODE(ATTR_INT_NAME, 'Quantity_Of_Item_Inner_Pack', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS QUANTITY_OF_ITEM_INNER_PACK
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Hierarchy', DECODE(ATTR_INT_NAME, 'Quanity_Of_Item_In_Layer', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS QUANITY_OF_ITEM_IN_LAYER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Marking', DECODE(ATTR_INT_NAME, 'Has_Batch_Number', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS HAS_BATCH_NUMBER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Marking', DECODE(ATTR_INT_NAME, 'Is_Trade_Item_Marked_Rec_Flag', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_MAR_REC_FLAG
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Marking', DECODE(ATTR_INT_NAME, 'Is_Non_Sold_Trade_Ret_Flag', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_NON_SOLD_TRADE_RET_FLAG
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Net_Content', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS NET_CONTENT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Gross_Weight', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS GROSS_WEIGHT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Uom_Net_Content', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_NET_CONTENT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Diameter', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DIAMETER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Ingredient_Strength', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS INGREDIENT_STRENGTH
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Generic_Ingredient_Strgth', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS GENERIC_INGREDIENT_STRGTH
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Generic_Ingredient', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS GENERIC_INGREDIENT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Peg_Vertical', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS PEG_VERTICAL
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Peg_Horizontal', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS PEG_HORIZONTAL
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Drained_Weight', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS DRAINED_WEIGHT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Measurements', DECODE(ATTR_INT_NAME, 'Is_Net_Content_Dec_Flag', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_NET_CONTENT_DEC_FLAG
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'DEPT_OF_TRNSPRT_DANG_GOODS_NUM', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DEPT_OF_TRNSPRT_DANG_GOODS_NUM
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'MODEL_NUMBER', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS MODEL_NUMBER
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'IS_TRADE_ITEM_RECALLED', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_TRADE_ITEM_RECALLED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'TRADE_ITEM_FINISH_DESCRIPTION', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS TRADE_ITEM_FINISH_DESCRIPTION
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'WARRANTY_DESCRIPTION', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS WARRANTY_DESCRIPTION
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'SECURITY_TAG_LOCATION', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS SECURITY_TAG_LOCATION
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'PIECES_PER_TRADE_ITEM', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS PIECES_PER_TRADE_ITEM
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'NESTING_INCREMENT', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS NESTING_INCREMENT
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'URL_FOR_WARRANTY', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS URL_FOR_WARRANTY
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'IS_OUT_OF_BOX_PROVIDED', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS IS_OUT_OF_BOX_PROVIDED
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Hardlines', DECODE(ATTR_INT_NAME, 'RETURN_GOODS_POLICY', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS RETURN_GOODS_POLICY
       ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Uccnet_Size_Description', DECODE(ATTR_INT_NAME, 'Size_Description', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DESCRIPTIVE_SIZE
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS'
        AND DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = p_target_proc_status
        AND INVENTORY_ITEM_ID = c_inventory_item_id
        AND ORGANIZATION_ID = c_organization_id;

    CURSOR c_intf_multi_row_attrs(c_inventory_item_id IN NUMBER, c_organization_id IN NUMBER) IS
      SELECT
         ROW_IDENTIFIER
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Bar_Code', DECODE(ATTR_INT_NAME, 'Bar_Code_Type', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS BAR_CODE_TYPE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Country_Of_Origin', DECODE(ATTR_INT_NAME, 'Country_OF_Origin', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS COUNTRY_OF_ORIGIN
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Delivery_Method_Indicator', DECODE(ATTR_INT_NAME, 'Delivery_Method_Indicator', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DELIVERY_METHOD_INDICATOR
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Color_Description', DECODE(ATTR_INT_NAME, 'Color_Code_Value', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS COLOR_CODE_VALUE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Gtin_Color_Description', DECODE(ATTR_INT_NAME, 'Color_Code_List_Agency', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS COLOR_CODE_LIST_AGENCY
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Handling_Information', DECODE(ATTR_INT_NAME, 'Handling_Instructions_Code', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS HANDLING_INSTRUCTIONS_CODE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Class_Of_Dangerous_Code', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS CLASS_OF_DANGEROUS_CODE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Margin_Number', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_MARGIN_NUMBER
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Hazardous_Code', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_HAZARDOUS_CODE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Reg_Code', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_REG_CODE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'United_Nations_Dang_Goods_No', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS UNITED_NATIONS_DANG_GOODS_NO
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Uom_Flash_Point_Temp', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS UOM_FLASH_POINT_TEMP
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Flash_Point_Temp', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS FLASH_POINT_TEMP
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Technical_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_TECHNICAL_NAME
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Shipping_Name', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_SHIPPING_NAME
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Hazardous_Information', DECODE(ATTR_INT_NAME, 'Dangerous_Goods_Pack_Group', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS DANGEROUS_GOODS_PACK_GROUP
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Manufacturing_Info', DECODE(ATTR_INT_NAME, 'Manufacturer_Gln', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS MANUFACTURER_GLN
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Manufacturing_Info', DECODE(ATTR_INT_NAME, 'Name_Of_Manufacturer', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS MANUFACTURER_ID
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Size_Description', DECODE(ATTR_INT_NAME, 'SIZE_CODE_LIST_AGENCY', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS SIZE_CODE_LIST_AGENCY
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'Size_Description', DECODE(ATTR_INT_NAME, 'SIZE_CODE_VALUE', NVL(ATTR_VALUE_STR, G_MISS_CHAR), null), null)) AS SIZE_CODE_VALUE
        ,MAX(DECODE(ATTR_GROUP_INT_NAME, 'TRADE_ITEM_HARMN_SYS_IDENT', DECODE(ATTR_INT_NAME, 'HARMONIZED_TARIFF_SYS_ID_CODE', NVL(ATTR_VALUE_NUM, G_MISS_NUM), null), null)) AS HARMONIZED_TARIFF_SYS_ID_CODE
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS'
        AND DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = p_target_proc_status
        AND INVENTORY_ITEM_ID = c_inventory_item_id
        AND ORGANIZATION_ID = c_organization_id
        AND ((UPPER(TRANSACTION_TYPE) <> 'DELETE' AND p_ignore_delete = 'Y') OR (NVL(p_ignore_delete, 'N') = 'N'))
      GROUP BY ROW_IDENTIFIER;

    CURSOR c_uom_code IS
      SELECT a.APPLICATION_COLUMN_NAME, u.UOM_CODE
      FROM EGO_FND_DF_COL_USGS_EXT a, MTL_UNITS_OF_MEASURE_TL u
      WHERE a.UOM_CLASS = u.UOM_CLASS(+)
        AND u.BASE_UOM_FLAG(+) = 'Y'
        AND u.LANGUAGE(+) = USERENV('LANG')
        AND a.APPLICATION_ID = 431
        AND a.DESCRIPTIVE_FLEXFIELD_NAME IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND a.APPLICATION_COLUMN_NAME IN (
                       'GROSS_WEIGHT'
                      ,'PEG_VERTICAL'
                      ,'PEG_HORIZONTAL'
                      ,'DRAINED_WEIGHT'
                      ,'DIAMETER'
                      ,'ORDERING_LEAD_TIME'
                      ,'GENERIC_INGREDIENT_STRGTH'
                      ,'STACKING_WEIGHT_MAXIMUM'
                      ,'PIECES_PER_TRADE_ITEM'
                      ,'NESTING_INCREMENT'
                      );

    TYPE l_uom_codes_type IS TABLE OF VARCHAR2(1000) INDEX BY VARCHAR2(1000);
    l_uom_tbl            l_uom_codes_type;
    l_single_row_attrs   EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ;
    l_multi_row_attrs    EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ;
    k                    BINARY_INTEGER;
    l_conversion_error   EXCEPTION;
    PRAGMA EXCEPTION_INIT(l_conversion_error, -6502);
    l_attr_name          VARCHAR2(1000);

    -- these are all NUMBER columns in EGO_ITEM_GTN_ATTRS_VL. The record EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ
    -- contains the type of these columns as NUMBER
    -- so these variables are used to find out any precesion problem in these attributes
    l_gross_weight                     EGO_ITEM_GTN_ATTRS_VL.GROSS_WEIGHT%TYPE;
    l_stacking_factor                  EGO_ITEM_GTN_ATTRS_VL.STACKING_FACTOR%TYPE;
    l_stacking_weight_maximum          EGO_ITEM_GTN_ATTRS_VL.STACKING_WEIGHT_MAXIMUM%TYPE;
    l_ordering_lead_time               EGO_ITEM_GTN_ATTRS_VL.ORDERING_LEAD_TIME%TYPE;
    l_order_quantity_max               EGO_ITEM_GTN_ATTRS_VL.ORDER_QUANTITY_MAX%TYPE;
    l_order_quantity_min               EGO_ITEM_GTN_ATTRS_VL.ORDER_QUANTITY_MIN%TYPE;
    l_order_quantity_multiple          EGO_ITEM_GTN_ATTRS_VL.ORDER_QUANTITY_MULTIPLE%TYPE;
    l_order_sizing_factor              EGO_ITEM_GTN_ATTRS_VL.ORDER_SIZING_FACTOR%TYPE;
    l_catalog_price                    EGO_ITEM_GTN_ATTRS_VL.CATALOG_PRICE%TYPE;
    l_suggested_retail_price           EGO_ITEM_GTN_ATTRS_VL.SUGGESTED_RETAIL_PRICE%TYPE;
    l_diameter                         EGO_ITEM_GTN_ATTRS_VL.DIAMETER%TYPE;
    l_drained_weight                   EGO_ITEM_GTN_ATTRS_VL.DRAINED_WEIGHT%TYPE;
    l_generic_ingredient_strgth        EGO_ITEM_GTN_ATTRS_VL.GENERIC_INGREDIENT_STRGTH%TYPE;
    l_net_content                      EGO_ITEM_GTN_ATTRS_VL.NET_CONTENT%TYPE;
    l_peg_horizontal                   EGO_ITEM_GTN_ATTRS_VL.PEG_HORIZONTAL%TYPE;
    l_peg_vertical                     EGO_ITEM_GTN_ATTRS_VL.PEG_VERTICAL%TYPE;
    l_del_to_dist_cntr_temp_max        EGO_ITEM_GTN_ATTRS_VL.DEL_TO_DIST_CNTR_TEMP_MAX%TYPE;
    l_del_to_dist_cntr_temp_min        EGO_ITEM_GTN_ATTRS_VL.DEL_TO_DIST_CNTR_TEMP_MIN%TYPE;
    l_delivery_to_mrkt_temp_max        EGO_ITEM_GTN_ATTRS_VL.DELIVERY_TO_MRKT_TEMP_MAX%TYPE;
    l_delivery_to_mrkt_temp_min        EGO_ITEM_GTN_ATTRS_VL.DELIVERY_TO_MRKT_TEMP_MIN%TYPE;
    l_retail_price_on_trade_item       EGO_ITEM_GTN_ATTRS_VL.RETAIL_PRICE_ON_TRADE_ITEM%TYPE;
    l_quantity_of_comp_lay_item        EGO_ITEM_GTN_ATTRS_VL.QUANTITY_OF_COMP_LAY_ITEM%TYPE;
    l_quanity_of_item_in_layer         EGO_ITEM_GTN_ATTRS_VL.QUANITY_OF_ITEM_IN_LAYER%TYPE;
    l_quantity_of_item_inner_pack      EGO_ITEM_GTN_ATTRS_VL.QUANTITY_OF_ITEM_INNER_PACK%TYPE;
    l_quantity_of_inner_pack           EGO_ITEM_GTN_ATTRS_VL.QUANTITY_OF_INNER_PACK%TYPE;
    l_storage_handling_temp_max        EGO_ITEM_GTN_ATTRS_VL.STORAGE_HANDLING_TEMP_MAX%TYPE;
    l_storage_handling_temp_min        EGO_ITEM_GTN_ATTRS_VL.STORAGE_HANDLING_TEMP_MIN%TYPE;
    l_trade_item_coupon                EGO_ITEM_GTN_ATTRS_VL.TRADE_ITEM_COUPON%TYPE;
    l_fat_percent_in_dry_matter        EGO_ITEM_GTN_ATTRS_VL.FAT_PERCENT_IN_DRY_MATTER%TYPE;
    l_percent_of_alcohol_by_vol        EGO_ITEM_GTN_ATTRS_VL.PERCENT_OF_ALCOHOL_BY_VOL%TYPE;
    l_nesting_increment                EGO_ITEM_GTN_ATTRS_VL.NESTING_INCREMENT%TYPE;
    l_pieces_per_trade_item            EGO_ITEM_GTN_ATTRS_VL.PIECES_PER_TRADE_ITEM%TYPE;


    -- these are all NUMBER columns in EGO_ITM_GTN_MUL_ATTRS_VL. The record EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ
    -- contains the type of these columns as NUMBER
    -- so these variables are used to find out any precesion problem in these attributes
    l_manufacturer_id                  EGO_ITM_GTN_MUL_ATTRS_VL.MANUFACTURER_ID%TYPE;
    l_united_nations_dang_goods_no     EGO_ITM_GTN_MUL_ATTRS_VL.UNITED_NATIONS_DANG_GOODS_NO%TYPE;
    l_flash_point_temp                 EGO_ITM_GTN_MUL_ATTRS_VL.FLASH_POINT_TEMP%TYPE;
    l_harmonized_tariff_sys_id_cd      EGO_ITM_GTN_MUL_ATTRS_VL.HARMONIZED_TARIFF_SYS_ID_CODE%TYPE;
  BEGIN
    Debug_Msg('Started Get_Gdsn_Intf_Rows');
    Debug_Msg('Initializing the fnd error stack');
    -- initializing the fnd error stack
    FND_MSG_PUB.Initialize;

    FOR i IN c_uom_code LOOP
      l_uom_tbl(i.APPLICATION_COLUMN_NAME) := i.UOM_CODE;
    END LOOP;
    Debug_Msg('Populated Unit of Measures');

    FOR j IN c_intf_single_row_attrs(p_inventory_item_id, p_organization_id) LOOP
      l_single_row_attrs.LANGUAGE_CODE := USERENV('LANG');
      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE := j.IS_TRADE_ITEM_INFO_PRIVATE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_A_CONSUMER_UNIT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.GROSS_WEIGHT := j.GROSS_WEIGHT;
        IF j.GROSS_WEIGHT <> G_MISS_NUM THEN
          l_gross_weight := j.GROSS_WEIGHT;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GROSS_WEIGHT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.GROSS_WEIGHT);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_GROSS_WEIGHT := l_uom_tbl('GROSS_WEIGHT');

      BEGIN
        l_single_row_attrs.EFFECTIVE_DATE := j.EFFECTIVE_DATE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.EFFECTIVE_DATE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.END_AVAILABILITY_DATE_TIME := j.END_AVAILABILITY_DATE_TIME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'END_AVAILABILITY_DATE_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.END_AVAILABILITY_DATE_TIME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.START_AVAILABILITY_DATE_TIME := j.START_AVAILABILITY_DATE_TIME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'START_AVAILABILITY_DATE_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.START_AVAILABILITY_DATE_TIME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.BRAND_NAME := j.BRAND_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.BRAND_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT := j.IS_TRADE_ITEM_A_BASE_UNIT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_A_BASE_UNIT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_A_BASE_UNIT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT := j.IS_TRADE_ITEM_A_VARIABLE_UNIT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_A_VARIABLE_UNIT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_A_VARIABLE_UNIT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE := j.IS_PACK_MARKED_WITH_EXP_DATE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_EXP_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_PACK_MARKED_WITH_EXP_DATE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT := j.IS_PACK_MARKED_WITH_GREEN_DOT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_GREEN_DOT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_PACK_MARKED_WITH_GREEN_DOT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED := j.IS_PACK_MARKED_WITH_INGRED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_INGRED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_PACK_MARKED_WITH_INGRED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC := j.IS_PACKAGE_MARKED_AS_REC;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACKAGE_MARKED_AS_REC');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_PACKAGE_MARKED_AS_REC);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_PACKAGE_MARKED_RET := j.IS_PACKAGE_MARKED_RET;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACKAGE_MARKED_RET');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_PACKAGE_MARKED_RET);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.STACKING_FACTOR := j.STACKING_FACTOR;
        IF j.STACKING_FACTOR <> G_MISS_NUM THEN
          l_stacking_factor := j.STACKING_FACTOR;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STACKING_FACTOR');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.STACKING_FACTOR);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.STACKING_WEIGHT_MAXIMUM := j.STACKING_WEIGHT_MAXIMUM;
        IF j.STACKING_WEIGHT_MAXIMUM <> G_MISS_NUM THEN
          l_stacking_weight_maximum := j.STACKING_WEIGHT_MAXIMUM;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STACKING_WEIGHT_MAXIMUM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.STACKING_WEIGHT_MAXIMUM);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM := l_uom_tbl('STACKING_WEIGHT_MAXIMUM');

      BEGIN
        l_single_row_attrs.ORDERING_LEAD_TIME := j.ORDERING_LEAD_TIME;
        IF j.ORDERING_LEAD_TIME <> G_MISS_NUM THEN
          l_ordering_lead_time := j.ORDERING_LEAD_TIME;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDERING_LEAD_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ORDERING_LEAD_TIME);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_ORDERING_LEAD_TIME := l_uom_tbl('ORDERING_LEAD_TIME');

      BEGIN
        l_single_row_attrs.ORDER_QUANTITY_MAX := j.ORDER_QUANTITY_MAX;
        IF j.ORDER_QUANTITY_MAX <> G_MISS_NUM THEN
          l_order_quantity_max := j.ORDER_QUANTITY_MAX;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_QUANTITY_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ORDER_QUANTITY_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.ORDER_QUANTITY_MIN := j.ORDER_QUANTITY_MIN;
        IF j.ORDER_QUANTITY_MIN <> G_MISS_NUM THEN
          l_order_quantity_min := j.ORDER_QUANTITY_MIN;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_QUANTITY_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ORDER_QUANTITY_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.ORDER_QUANTITY_MULTIPLE := j.ORDER_QUANTITY_MULTIPLE;
        IF j.ORDER_QUANTITY_MULTIPLE <> G_MISS_NUM THEN
          l_order_quantity_multiple := j.ORDER_QUANTITY_MULTIPLE;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_QUANTITY_MULTIPLE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ORDER_QUANTITY_MULTIPLE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.ORDER_SIZING_FACTOR := j.ORDER_SIZING_FACTOR;
        IF j.ORDER_SIZING_FACTOR <> G_MISS_NUM THEN
          l_order_sizing_factor := j.ORDER_SIZING_FACTOR;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_SIZING_FACTOR');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ORDER_SIZING_FACTOR);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.EFFECTIVE_START_DATE := j.EFFECTIVE_START_DATE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_START_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.EFFECTIVE_START_DATE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.CATALOG_PRICE := j.CATALOG_PRICE;
        IF j.CATALOG_PRICE <> G_MISS_NUM THEN
          l_catalog_price := j.CATALOG_PRICE;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'CATALOG_PRICE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.CATALOG_PRICE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.EFFECTIVE_END_DATE := j.EFFECTIVE_END_DATE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_END_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.EFFECTIVE_END_DATE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.SUGGESTED_RETAIL_PRICE := j.SUGGESTED_RETAIL_PRICE;
        IF j.SUGGESTED_RETAIL_PRICE <> G_MISS_NUM THEN
          l_suggested_retail_price := j.SUGGESTED_RETAIL_PRICE;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'SUGGESTED_RETAIL_PRICE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.SUGGESTED_RETAIL_PRICE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO := j.MATERIAL_SAFETY_DATA_SHEET_NO;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'MATERIAL_SAFETY_DATA_SHEET_NO');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.MATERIAL_SAFETY_DATA_SHEET_NO);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.HAS_BATCH_NUMBER := j.HAS_BATCH_NUMBER;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'HAS_BATCH_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.HAS_BATCH_NUMBER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG := j.IS_NON_SOLD_TRADE_RET_FLAG;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_NON_SOLD_TRADE_RET_FLAG');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_NON_SOLD_TRADE_RET_FLAG);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG := j.IS_TRADE_ITEM_MAR_REC_FLAG;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_MAR_REC_FLAG');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_MAR_REC_FLAG);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DIAMETER := j.DIAMETER;
        IF j.DIAMETER <> G_MISS_NUM THEN
          l_diameter := j.DIAMETER;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DIAMETER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DIAMETER);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_DIAMETER := l_uom_tbl('DIAMETER');

      BEGIN
        l_single_row_attrs.DRAINED_WEIGHT := j.DRAINED_WEIGHT;
        IF j.DRAINED_WEIGHT <> G_MISS_NUM THEN
          l_drained_weight := j.DRAINED_WEIGHT;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DRAINED_WEIGHT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DRAINED_WEIGHT);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_DRAINED_WEIGHT := l_uom_tbl('DRAINED_WEIGHT');

      BEGIN
        l_single_row_attrs.GENERIC_INGREDIENT := j.GENERIC_INGREDIENT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GENERIC_INGREDIENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.GENERIC_INGREDIENT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.GENERIC_INGREDIENT_STRGTH := j.GENERIC_INGREDIENT_STRGTH;
        IF j.GENERIC_INGREDIENT_STRGTH <> G_MISS_NUM THEN
          l_generic_ingredient_strgth := j.GENERIC_INGREDIENT_STRGTH;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GENERIC_INGREDIENT_STRGTH');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.GENERIC_INGREDIENT_STRGTH);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH := l_uom_tbl('GENERIC_INGREDIENT_STRGTH');

      BEGIN
        l_single_row_attrs.INGREDIENT_STRENGTH := j.INGREDIENT_STRENGTH;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'INGREDIENT_STRENGTH');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.INGREDIENT_STRENGTH);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG := j.IS_NET_CONTENT_DEC_FLAG;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_NET_CONTENT_DEC_FLAG');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_NET_CONTENT_DEC_FLAG);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.NET_CONTENT := j.NET_CONTENT;
        IF j.NET_CONTENT <> G_MISS_NUM THEN
          l_net_content := j.NET_CONTENT;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'NET_CONTENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.NET_CONTENT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_NET_CONTENT := j.UOM_NET_CONTENT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_NET_CONTENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_NET_CONTENT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.PEG_HORIZONTAL := j.PEG_HORIZONTAL;
        IF j.PEG_HORIZONTAL <> G_MISS_NUM THEN
          l_peg_horizontal := j.PEG_HORIZONTAL;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_HORIZONTAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.PEG_HORIZONTAL);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_PEG_HORIZONTAL := l_uom_tbl('PEG_HORIZONTAL');

      BEGIN
        l_single_row_attrs.PEG_VERTICAL := j.PEG_VERTICAL;
        IF j.PEG_VERTICAL <> G_MISS_NUM THEN
          l_peg_vertical := j.PEG_VERTICAL;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_VERTICAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.PEG_VERTICAL);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_PEG_VERTICAL := l_uom_tbl('PEG_VERTICAL');

      BEGIN
        l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME := j.CONSUMER_AVAIL_DATE_TIME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'CONSUMER_AVAIL_DATE_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.CONSUMER_AVAIL_DATE_TIME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX := j.DEL_TO_DIST_CNTR_TEMP_MAX;
        IF j.DEL_TO_DIST_CNTR_TEMP_MAX <> G_MISS_NUM THEN
          l_del_to_dist_cntr_temp_max := j.DEL_TO_DIST_CNTR_TEMP_MAX;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DEL_TO_DIST_CNTR_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX := j.UOM_DEL_TO_DIST_CNTR_TEMP_MAX;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_DEL_TO_DIST_CNTR_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN := j.DEL_TO_DIST_CNTR_TEMP_MIN;
        IF j.DEL_TO_DIST_CNTR_TEMP_MIN <> G_MISS_NUM THEN
          l_del_to_dist_cntr_temp_min := j.DEL_TO_DIST_CNTR_TEMP_MIN;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DEL_TO_DIST_CNTR_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN := j.UOM_DEL_TO_DIST_CNTR_TEMP_MIN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_DEL_TO_DIST_CNTR_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_DEL_TO_DIST_CNTR_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX := j.DELIVERY_TO_MRKT_TEMP_MAX;
        IF j.DELIVERY_TO_MRKT_TEMP_MAX <> G_MISS_NUM THEN
          l_delivery_to_mrkt_temp_max := j.DELIVERY_TO_MRKT_TEMP_MAX;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DELIVERY_TO_MRKT_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX := j.UOM_DELIVERY_TO_MRKT_TEMP_MAX;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_DELIVERY_TO_MRKT_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN := j.DELIVERY_TO_MRKT_TEMP_MIN;
        IF j.DELIVERY_TO_MRKT_TEMP_MIN <> G_MISS_NUM THEN
          l_delivery_to_mrkt_temp_min := j.DELIVERY_TO_MRKT_TEMP_MIN;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DELIVERY_TO_MRKT_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN := j.UOM_DELIVERY_TO_MRKT_TEMP_MIN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_DELIVERY_TO_MRKT_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_DELIVERY_TO_MRKT_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.SUB_BRAND := j.SUB_BRAND;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'SUB_BRAND');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.SUB_BRAND);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.EANUCC_CODE := j.EANUCC_CODE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.EANUCC_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.EANUCC_TYPE := j.EANUCC_TYPE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_TYPE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.EANUCC_TYPE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM := j.RETAIL_PRICE_ON_TRADE_ITEM;
        IF j.RETAIL_PRICE_ON_TRADE_ITEM <> G_MISS_NUM THEN
          l_retail_price_on_trade_item := j.RETAIL_PRICE_ON_TRADE_ITEM;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'RETAIL_PRICE_ON_TRADE_ITEM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.RETAIL_PRICE_ON_TRADE_ITEM);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM := j.QUANTITY_OF_COMP_LAY_ITEM;
        IF j.QUANTITY_OF_COMP_LAY_ITEM <> G_MISS_NUM THEN
          l_quantity_of_comp_lay_item := j.QUANTITY_OF_COMP_LAY_ITEM;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'QUANTITY_OF_COMP_LAY_ITEM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.QUANTITY_OF_COMP_LAY_ITEM);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER := j.QUANITY_OF_ITEM_IN_LAYER;
        IF j.QUANITY_OF_ITEM_IN_LAYER <> G_MISS_NUM THEN
          l_quanity_of_item_in_layer := j.QUANITY_OF_ITEM_IN_LAYER;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'QUANITY_OF_ITEM_IN_LAYER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.QUANITY_OF_ITEM_IN_LAYER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK := j.QUANTITY_OF_ITEM_INNER_PACK;
        IF j.QUANTITY_OF_ITEM_INNER_PACK <> G_MISS_NUM THEN
          l_quantity_of_item_inner_pack := j.QUANTITY_OF_ITEM_INNER_PACK;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'QUANTITY_OF_ITEM_INNER_PACK');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.QUANTITY_OF_ITEM_INNER_PACK);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.QUANTITY_OF_INNER_PACK := j.QUANTITY_OF_INNER_PACK;
        IF j.QUANTITY_OF_INNER_PACK <> G_MISS_NUM THEN
          l_quantity_of_inner_pack := j.QUANTITY_OF_INNER_PACK;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'QUANTITY_OF_INNER_PACK');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.QUANTITY_OF_INNER_PACK);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.BRAND_OWNER_GLN := j.BRAND_OWNER_GLN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.BRAND_OWNER_GLN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.BRAND_OWNER_NAME := j.BRAND_OWNER_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.BRAND_OWNER_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX := j.STORAGE_HANDLING_TEMP_MAX;
        IF j.STORAGE_HANDLING_TEMP_MAX <> G_MISS_NUM THEN
          l_storage_handling_temp_max := j.STORAGE_HANDLING_TEMP_MAX;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.STORAGE_HANDLING_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX := j.UOM_STORAGE_HANDLING_TEMP_MAX;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_STORAGE_HANDLING_TEMP_MAX);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN := j.STORAGE_HANDLING_TEMP_MIN;
        IF j.STORAGE_HANDLING_TEMP_MIN <> G_MISS_NUM THEN
          l_storage_handling_temp_min := j.STORAGE_HANDLING_TEMP_MIN;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.STORAGE_HANDLING_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN := j.UOM_STORAGE_HANDLING_TEMP_MIN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_STORAGE_HANDLING_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_STORAGE_HANDLING_TEMP_MIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.TRADE_ITEM_COUPON := j.TRADE_ITEM_COUPON;
        IF j.TRADE_ITEM_COUPON <> G_MISS_NUM THEN
          l_trade_item_coupon := j.TRADE_ITEM_COUPON;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'TRADE_ITEM_COUPON');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.TRADE_ITEM_COUPON);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT := j.DEGREE_OF_ORIGINAL_WORT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEGREE_OF_ORIGINAL_WORT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DEGREE_OF_ORIGINAL_WORT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER := j.FAT_PERCENT_IN_DRY_MATTER;
        IF j.FAT_PERCENT_IN_DRY_MATTER <> G_MISS_NUM THEN
          l_fat_percent_in_dry_matter := j.FAT_PERCENT_IN_DRY_MATTER;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'FAT_PERCENT_IN_DRY_MATTER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.FAT_PERCENT_IN_DRY_MATTER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL := j.PERCENT_OF_ALCOHOL_BY_VOL;
        IF j.PERCENT_OF_ALCOHOL_BY_VOL <> G_MISS_NUM THEN
          l_percent_of_alcohol_by_vol := j.PERCENT_OF_ALCOHOL_BY_VOL;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PERCENT_OF_ALCOHOL_BY_VOL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.PERCENT_OF_ALCOHOL_BY_VOL);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.ISBN_NUMBER := j.ISBN_NUMBER;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ISBN_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ISBN_NUMBER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.ISSN_NUMBER := j.ISSN_NUMBER;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ISSN_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.ISSN_NUMBER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_INGREDIENT_IRRADIATED := j.IS_INGREDIENT_IRRADIATED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_INGREDIENT_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_INGREDIENT_IRRADIATED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED := j.IS_RAW_MATERIAL_IRRADIATED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_RAW_MATERIAL_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_RAW_MATERIAL_IRRADIATED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD := j.IS_TRADE_ITEM_GENETICALLY_MOD;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_GENETICALLY_MOD');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_GENETICALLY_MOD);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED := j.IS_TRADE_ITEM_IRRADIATED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_IRRADIATED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.SECURITY_TAG_LOCATION := j.SECURITY_TAG_LOCATION;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'SECURITY_TAG_LOCATION');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.SECURITY_TAG_LOCATION);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.URL_FOR_WARRANTY := j.URL_FOR_WARRANTY;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'URL_FOR_WARRANTY');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.URL_FOR_WARRANTY);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.NESTING_INCREMENT := j.NESTING_INCREMENT;
        IF j.NESTING_INCREMENT <> G_MISS_NUM THEN
          l_nesting_increment := j.NESTING_INCREMENT;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'NESTING_INCREMENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.NESTING_INCREMENT);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_NESTING_INCREMENT := l_uom_tbl('NESTING_INCREMENT');

      BEGIN
        l_single_row_attrs.IS_TRADE_ITEM_RECALLED := j.IS_TRADE_ITEM_RECALLED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_RECALLED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_TRADE_ITEM_RECALLED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.MODEL_NUMBER := j.MODEL_NUMBER;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'MODEL_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.MODEL_NUMBER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.PIECES_PER_TRADE_ITEM := j.PIECES_PER_TRADE_ITEM;
        IF j.PIECES_PER_TRADE_ITEM <> G_MISS_NUM THEN
          l_pieces_per_trade_item := j.PIECES_PER_TRADE_ITEM;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PIECES_PER_TRADE_ITEM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.PIECES_PER_TRADE_ITEM);
        FND_MSG_PUB.ADD;
      END;

      l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM := l_uom_tbl('PIECES_PER_TRADE_ITEM');

      BEGIN
        l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM := j.DEPT_OF_TRNSPRT_DANG_GOODS_NUM;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEPT_OF_TRNSPRT_DANG_GOODS_NUM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DEPT_OF_TRNSPRT_DANG_GOODS_NUM);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.RETURN_GOODS_POLICY := j.RETURN_GOODS_POLICY;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'RETURN_GOODS_POLICY');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.RETURN_GOODS_POLICY);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED := j.IS_OUT_OF_BOX_PROVIDED;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_OUT_OF_BOX_PROVIDED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_OUT_OF_BOX_PROVIDED);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.INVOICE_NAME := j.INVOICE_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'INVOICE_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.INVOICE_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DESCRIPTIVE_SIZE := j.DESCRIPTIVE_SIZE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DESCRIPTIVE_SIZE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DESCRIPTIVE_SIZE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.FUNCTIONAL_NAME := j.FUNCTIONAL_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'FUNCTIONAL_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.FUNCTIONAL_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION := j.TRADE_ITEM_FORM_DESCRIPTION;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'TRADE_ITEM_FORM_DESCRIPTION');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.TRADE_ITEM_FORM_DESCRIPTION);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.WARRANTY_DESCRIPTION := j.WARRANTY_DESCRIPTION;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'WARRANTY_DESCRIPTION');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.WARRANTY_DESCRIPTION);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION := j.TRADE_ITEM_FINISH_DESCRIPTION;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'TRADE_ITEM_FINISH_DESCRIPTION');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.TRADE_ITEM_FINISH_DESCRIPTION);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.DESCRIPTION_SHORT := j.DESCRIPTION_SHORT;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DESCRIPTION_SHORT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DESCRIPTION_SHORT);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE := j.IS_BARCODE_SYMBOLOGY_DERIVABLE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_BARCODE_SYMBOLOGY_DERIVABLE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.IS_BARCODE_SYMBOLOGY_DERIVABLE);
        FND_MSG_PUB.ADD;
      END;
    END LOOP; -- end loop single row attributes

    Debug_Msg('Finished Populating local array for Single Row Attributes');
    k := 1;
    FOR j IN c_intf_multi_row_attrs(p_inventory_item_id, p_organization_id) LOOP
      l_multi_row_attrs(k).LANGUAGE_CODE := USERENV('LANG');

      BEGIN
        l_multi_row_attrs(k).MANUFACTURER_GLN := j.MANUFACTURER_GLN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.MANUFACTURER_GLN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).MANUFACTURER_ID := j.MANUFACTURER_ID;
        IF j.MANUFACTURER_ID <> G_MISS_NUM THEN
          l_manufacturer_id := j.MANUFACTURER_ID;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_ID');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.MANUFACTURER_ID);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).BAR_CODE_TYPE := j.BAR_CODE_TYPE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'BAR_CODE_TYPE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.BAR_CODE_TYPE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).COLOR_CODE_LIST_AGENCY := j.COLOR_CODE_LIST_AGENCY;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_LIST_AGENCY');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.COLOR_CODE_LIST_AGENCY);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).COLOR_CODE_VALUE := j.COLOR_CODE_VALUE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_VALUE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.COLOR_CODE_VALUE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).CLASS_OF_DANGEROUS_CODE := j.CLASS_OF_DANGEROUS_CODE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'CLASS_OF_DANGEROUS_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.CLASS_OF_DANGEROUS_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_MARGIN_NUMBER := j.DANGEROUS_GOODS_MARGIN_NUMBER;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_MARGIN_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_MARGIN_NUMBER);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_HAZARDOUS_CODE := j.DANGEROUS_GOODS_HAZARDOUS_CODE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_HAZARDOUS_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_HAZARDOUS_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_PACK_GROUP := j.DANGEROUS_GOODS_PACK_GROUP;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_PACK_GROUP');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_PACK_GROUP);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_REG_CODE := j.DANGEROUS_GOODS_REG_CODE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_REG_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_REG_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_SHIPPING_NAME := j.DANGEROUS_GOODS_SHIPPING_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_SHIPPING_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_SHIPPING_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).UNITED_NATIONS_DANG_GOODS_NO := j.UNITED_NATIONS_DANG_GOODS_NO;
        IF j.UNITED_NATIONS_DANG_GOODS_NO <> G_MISS_NUM THEN
          l_united_nations_dang_goods_no := j.UNITED_NATIONS_DANG_GOODS_NO;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'UNITED_NATIONS_DANG_GOODS_NO');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UNITED_NATIONS_DANG_GOODS_NO);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).FLASH_POINT_TEMP := j.FLASH_POINT_TEMP;
        IF j.FLASH_POINT_TEMP <> G_MISS_NUM THEN
          l_flash_point_temp := j.FLASH_POINT_TEMP;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'FLASH_POINT_TEMP');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.FLASH_POINT_TEMP);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).UOM_FLASH_POINT_TEMP := j.UOM_FLASH_POINT_TEMP;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'UOM_FLASH_POINT_TEMP');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.UOM_FLASH_POINT_TEMP);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).COUNTRY_OF_ORIGIN := j.COUNTRY_OF_ORIGIN;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COUNTRY_OF_ORIGIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.COUNTRY_OF_ORIGIN);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).HARMONIZED_TARIFF_SYS_ID_CODE := j.HARMONIZED_TARIFF_SYS_ID_CODE;
        IF j.HARMONIZED_TARIFF_SYS_ID_CODE <> G_MISS_NUM THEN
          l_harmonized_tariff_sys_id_cd := j.HARMONIZED_TARIFF_SYS_ID_CODE;
        END IF;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'HARMONIZED_TARIFF_SYS_ID_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.HARMONIZED_TARIFF_SYS_ID_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).SIZE_CODE_LIST_AGENCY := j.SIZE_CODE_LIST_AGENCY;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_LIST_AGENCY');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.SIZE_CODE_LIST_AGENCY);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).SIZE_CODE_VALUE := j.SIZE_CODE_VALUE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_VALUE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.SIZE_CODE_VALUE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).HANDLING_INSTRUCTIONS_CODE := j.HANDLING_INSTRUCTIONS_CODE;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'HANDLING_INSTRUCTIONS_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.HANDLING_INSTRUCTIONS_CODE);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DANGEROUS_GOODS_TECHNICAL_NAME := j.DANGEROUS_GOODS_TECHNICAL_NAME;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_TECHNICAL_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DANGEROUS_GOODS_TECHNICAL_NAME);
        FND_MSG_PUB.ADD;
      END;

      BEGIN
        l_multi_row_attrs(k).DELIVERY_METHOD_INDICATOR := j.DELIVERY_METHOD_INDICATOR;
      EXCEPTION WHEN l_conversion_error THEN
        l_attr_name := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DELIVERY_METHOD_INDICATOR');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_LENGTH_INVALID');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr_name);
        FND_MESSAGE.Set_Token('ATTR_VALUE', j.DELIVERY_METHOD_INDICATOR);
        FND_MSG_PUB.ADD;
      END;

      k := k + 1;
    END LOOP; -- end loop multi row attributes

    Debug_Msg('Finished Populating local array for Multi Row Attributes');
    x_singe_row_attrs_rec  := l_single_row_attrs ;
    x_multi_row_attrs_tbl := l_multi_row_attrs ;

    FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    IF x_msg_count > 0 THEN
      x_return_status := 'E';
    ELSE
      x_return_status := 'S';
    END IF;
    Debug_Msg('Finished Get_Gdsn_Intf_Rows for Item,Org='||p_inventory_item_id||','||p_organization_id);
    Debug_Msg('Return Status = '||x_return_status);
  EXCEPTION WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    Debug_Msg('Unexpected Error in Get_Gdsn_Intf_Rows - '||x_msg_data);
  END Get_Gdsn_Intf_Rows;

  /*
   ** This procedure validates the interface table rows for UCCnet attributes
   */
  PROCEDURE Validate_Intf_Rows ( p_data_set_id IN  NUMBER
                                ,p_entity_id NUMBER
                                ,p_entity_code VARCHAR2
                                ,p_add_errors_to_fnd_stack VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2
                               )
  IS
    CURSOR c_intf_rows IS
      SELECT
        INVENTORY_ITEM_ID
       ,ORGANIZATION_ID
       ,ITEM_CATALOG_GROUP_ID
       ,SOURCE_SYSTEM_ID
       ,SOURCE_SYSTEM_REFERENCE
       ,MAX(TRANSACTION_ID)    AS TRANSACTION_ID
       ,MAX(CREATED_BY)        AS CREATED_BY
       ,MAX(CREATION_DATE)     AS CREATION_DATE
       ,MAX(LAST_UPDATED_BY)   AS LAST_UPDATED_BY
       ,MAX(LAST_UPDATE_DATE)  AS LAST_UPDATE_DATE
       ,MAX(LAST_UPDATE_LOGIN) AS LAST_UPDATE_LOGIN
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE (( ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS') )
             OR
             ( ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND ATTR_GROUP_INT_NAME LIKE 'EGOINT#_GDSN%' ESCAPE '#' )
            )
        AND DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = 2
      GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID, ITEM_CATALOG_GROUP_ID, SOURCE_SYSTEM_ID, SOURCE_SYSTEM_REFERENCE;

    l_return_status          VARCHAR2(10);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_msg_text               VARCHAR2(4000);
    l_single_row_attrs       EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ;
    l_multi_row_attrs        EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ;
  BEGIN
    Debug_Msg('Starting Validate_Intf_Rows');
    FOR i IN c_intf_rows LOOP
      Debug_Msg('Calling Get_Gdsn_Intf_Rows for Item, Org='||i.INVENTORY_ITEM_ID||','||i.ORGANIZATION_ID);
      Get_Gdsn_Intf_Rows(  p_data_set_id          => p_data_set_id
                          ,p_target_proc_status   => 2
                          ,p_inventory_item_id    => i.INVENTORY_ITEM_ID
                          ,p_organization_id      => i.ORGANIZATION_ID
                          ,p_ignore_delete        => 'Y'
                          ,x_singe_row_attrs_rec  => l_single_row_attrs
                          ,x_multi_row_attrs_tbl  => l_multi_row_attrs
                          ,x_return_status        => l_return_status
                          ,x_msg_count            => l_msg_count
                          ,x_msg_data             => l_msg_data
                        );

      x_return_status := l_return_status;

      IF l_return_status <> 'S' THEN
        Debug_Msg('Done with errors - Calling Get_Gdsn_Intf_Rows for Item, Org='||i.INVENTORY_ITEM_ID||','||i.ORGANIZATION_ID);
        UPDATE EGO_ITM_USR_ATTR_INTRFC
        SET PROCESS_STATUS = 3
        WHERE DATA_SET_ID = p_data_set_id
          AND (( ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS') )
               OR
               ( ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND ATTR_GROUP_INT_NAME LIKE 'EGOINT#_GDSN%' ESCAPE '#' )
              )
          AND INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID
          AND ORGANIZATION_ID = i.ORGANIZATION_ID
          AND PROCESS_STATUS = 2;

        Debug_Msg('Marked Item as error in Interface table');
        IF l_msg_count > 0 AND l_return_status <> 'U' THEN
          FOR cnt IN 1..l_msg_count LOOP
            Debug_Msg('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
            l_msg_text := FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F');
            ERROR_HANDLER.Add_Error_Message
              (
                p_message_text              => l_msg_text
               ,p_application_id            => 'EGO'
               ,p_message_type              => FND_API.G_RET_STS_ERROR
               ,p_row_identifier            => i.TRANSACTION_ID
               ,p_entity_id                 => p_entity_id
               ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
               ,p_entity_code               => p_entity_code
               ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
              );
          END LOOP;
        ELSIF l_msg_count > 0 AND l_return_status = 'U' THEN
          Debug_Msg('Unexpected Error msg - '|| l_msg_data);
          l_msg_text := l_msg_data;
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text              => l_msg_text
             ,p_application_id            => 'EGO'
             ,p_message_type              => FND_API.G_RET_STS_ERROR
             ,p_row_identifier            => i.TRANSACTION_ID
             ,p_entity_id                 => p_entity_id
             ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
             ,p_entity_code               => p_entity_code
             ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
            );
        END IF; -- IF l_msg_count
      ELSE
        Debug_Msg('Calling Validation API');
        l_return_status := NULL;
        x_return_status := l_return_status;
        l_msg_count := 0;
        l_msg_data := NULL;
        G_CALLED_FROM_INTF := 'Y';
        G_DATA_SET_ID := p_data_set_id;

        Validate_Attributes(
               i.INVENTORY_ITEM_ID -- p_inventory_item_id
              ,i.ORGANIZATION_ID   -- p_organization_id
              ,l_single_row_attrs  -- p_single_row_attrs_rec
              ,l_multi_row_attrs   -- p_multi_row_attrs_tbl
              ,NULL                -- p_extra_attrs_rec
              ,l_return_status     -- x_return_status
              ,l_msg_count         -- x_msg_count
              ,l_msg_data          -- x_msg_data
              );

        x_return_status := l_return_status;
        Debug_Msg('Finished Validation l_return_status, l_msg_count='||l_return_status||','||l_msg_count);

        IF l_return_status <> 'S' THEN
          UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET PROCESS_STATUS = 3
          WHERE DATA_SET_ID = p_data_set_id
            AND (( ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS') )
                 OR
                 ( ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND ATTR_GROUP_INT_NAME LIKE 'EGOINT#_GDSN%' ESCAPE '#' )
                )
            AND INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID
            AND ORGANIZATION_ID = i.ORGANIZATION_ID
            AND PROCESS_STATUS = 2;

          Debug_Msg('Marked Item as error in Interface table');

          IF l_msg_count > 0 AND l_return_status <> 'U' THEN
            FOR cnt IN 1..l_msg_count LOOP
              Debug_Msg('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
              l_msg_text := FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F');
              ERROR_HANDLER.Add_Error_Message
                (
                  p_message_text              => l_msg_text
                 ,p_application_id            => 'EGO'
                 ,p_message_type              => FND_API.G_RET_STS_ERROR
                 ,p_row_identifier            => i.TRANSACTION_ID
                 ,p_entity_id                 => p_entity_id
                 ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
                 ,p_entity_code               => p_entity_code
                 ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
                );
            END LOOP;
          ELSIF l_msg_count > 0 AND l_return_status = 'U' THEN
            Debug_Msg('Unexpected Error msg - '|| l_msg_data);
            l_msg_text := l_msg_data;
            ERROR_HANDLER.Add_Error_Message
              (
                p_message_text              => l_msg_text
               ,p_application_id            => 'EGO'
               ,p_message_type              => FND_API.G_RET_STS_ERROR
               ,p_row_identifier            => i.TRANSACTION_ID
               ,p_entity_id                 => p_entity_id
               ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
               ,p_entity_code               => p_entity_code
               ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
              );
          END IF; -- IF l_msg_count
        END IF; -- IF l_return_status <> 'S
      END IF; -- END IF l_return_status <> 'S' THEN
    END LOOP; -- end loop intf_rows
    Debug_Msg('Finished Validate_Intf_Rows');
  END Validate_Intf_Rows;



  /*
   ** This procedure validates the data passed in for UCCnet attributes
   */
  PROCEDURE Validate_Attributes (
              p_inventory_item_id    IN  NUMBER
             ,p_organization_id      IN  NUMBER
             ,p_singe_row_attrs_rec  IN  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
             ,p_multi_row_attrs_tbl  IN  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
             ,p_extra_attrs_rec      IN  EGO_ITEM_PUB.UCCnet_Extra_Attrs_Rec_Typ
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             )
  IS
    CURSOR c_prod_single_row_values IS
      SELECT
         msib.TRADE_ITEM_DESCRIPTOR
        ,gtn.BRAND_OWNER_GLN
        ,gtn.BRAND_OWNER_NAME
        ,gtn.EANUCC_CODE
        ,gtn.EANUCC_TYPE
        ,gtn.CATALOG_PRICE
        ,gtn.EFFECTIVE_START_DATE
        ,gtn.EFFECTIVE_END_DATE
        ,gtn.SUGGESTED_RETAIL_PRICE
        ,gtn.START_AVAILABILITY_DATE_TIME
        ,gtn.END_AVAILABILITY_DATE_TIME
        ,gtn.ORDER_QUANTITY_MAX
        ,gtn.ORDER_QUANTITY_MIN
        -- non-edtable at non-leaf
        ,gtn.ISSN_NUMBER
        ,gtn.ISBN_NUMBER
        ,gtn.PERCENT_OF_ALCOHOL_BY_VOL
        ,gtn.FAT_PERCENT_IN_DRY_MATTER
        ,gtn.GENERIC_INGREDIENT_STRGTH
        ,gtn.INGREDIENT_STRENGTH
        ,gtn.DEL_TO_DIST_CNTR_TEMP_MIN
        ,gtn.UOM_DEL_TO_DIST_CNTR_TEMP_MIN
        ,gtn.DEL_TO_DIST_CNTR_TEMP_MAX
        ,gtn.UOM_DEL_TO_DIST_CNTR_TEMP_MAX
        ,gtn.DELIVERY_TO_MRKT_TEMP_MIN
        ,gtn.UOM_DELIVERY_TO_MRKT_TEMP_MIN
        ,gtn.DELIVERY_TO_MRKT_TEMP_MAX
        ,gtn.UOM_DELIVERY_TO_MRKT_TEMP_MAX
        ,gtn.STORAGE_HANDLING_TEMP_MIN
        ,gtn.UOM_STORAGE_HANDLING_TEMP_MIN
        ,gtn.STORAGE_HANDLING_TEMP_MAX
        ,gtn.UOM_STORAGE_HANDLING_TEMP_MAX
        ,gtn.IS_PACK_MARKED_WITH_GREEN_DOT
        ,gtn.IS_PACK_MARKED_WITH_INGRED
        ,gtn.IS_INGREDIENT_IRRADIATED
        ,gtn.IS_RAW_MATERIAL_IRRADIATED
        ,gtn.IS_TRADE_ITEM_GENETICALLY_MOD
        ,gtn.IS_TRADE_ITEM_IRRADIATED
        ,gtn.SUB_BRAND
        ,gtn.TRADE_ITEM_COUPON
        ,gtn.TRADE_ITEM_FORM_DESCRIPTION
        ,gtn.HAS_BATCH_NUMBER
        ,gtn.IS_NON_SOLD_TRADE_RET_FLAG
        ,gtn.IS_TRADE_ITEM_MAR_REC_FLAG
        ,gtn.IS_PACK_MARKED_WITH_EXP_DATE
        ,gtn.FUNCTIONAL_NAME
        ,gtn.DIAMETER
        ,gtn.DRAINED_WEIGHT
        ,gtn.PEG_HORIZONTAL
        ,gtn.PEG_VERTICAL
        ,gtn.GENERIC_INGREDIENT
        ,gtn.UOM_NET_CONTENT
      FROM EGO_ITEM_GTN_ATTRS_VL gtn, MTL_SYSTEM_ITEMS_B msib
      WHERE gtn.INVENTORY_ITEM_ID(+) = msib.INVENTORY_ITEM_ID
        AND gtn.ORGANIZATION_ID(+) = msib.ORGANIZATION_ID
        AND msib.INVENTORY_ITEM_ID = p_inventory_item_id
        AND msib.ORGANIZATION_ID = p_organization_id;

    CURSOR c_prod_multi_row_values IS
      SELECT
         COLOR_CODE_LIST_AGENCY
        ,COLOR_CODE_VALUE
        ,MANUFACTURER_GLN
        ,MANUFACTURER_ID
        ,SIZE_CODE_LIST_AGENCY
        ,SIZE_CODE_VALUE
        ,CLASS_OF_DANGEROUS_CODE
        ,DANGEROUS_GOODS_MARGIN_NUMBER
        ,DANGEROUS_GOODS_HAZARDOUS_CODE
        ,DANGEROUS_GOODS_PACK_GROUP
        ,DANGEROUS_GOODS_REG_CODE
        ,DANGEROUS_GOODS_SHIPPING_NAME
        ,UNITED_NATIONS_DANG_GOODS_NO
        ,FLASH_POINT_TEMP
        ,DANGEROUS_GOODS_TECHNICAL_NAME
        ,COUNTRY_OF_ORIGIN
        ,HANDLING_INSTRUCTIONS_CODE
      FROM EGO_ITM_GTN_MUL_ATTRS_VL
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;

    l_prod_single_row_attrs       c_prod_single_row_values%ROWTYPE;

    l_trade_item_desc             MTL_SYSTEM_ITEMS_B.TRADE_ITEM_DESCRIPTOR%TYPE;
    l_gdsn_outbound_flag          MTL_SYSTEM_ITEMS_B.GDSN_OUTBOUND_ENABLED_FLAG%TYPE;
    l_is_used_in_packaging_hrchy  VARCHAR2(10);
    l_err_msg                     VARCHAR2(1000);
    l_err_code                    NUMBER;
    l_bgln_valid                  BOOLEAN;
    l_brand_owner_gln             NUMBER;
    l_eanucc_code_num             NUMBER;
    l_eanucc_type                 VARCHAR2(100);
    l_eanucc_code                 VARCHAR2(100);
    l_eanucc_valid                BOOLEAN;
    l_eanucc_code_length          NUMBER;
    l_eanucc_code_req_length      NUMBER;
    l_item_id                     NUMBER;
    l_item_number                 VARCHAR2(1000);
    l_attr1_disp                  VARCHAR2(1000);
    l_attr2_disp                  VARCHAR2(1000);
    l_gtid_disp                   VARCHAR2(1000);
    l_mgln_valid                  BOOLEAN;
    l_index                       BINARY_INTEGER;
    l_index1                      BINARY_INTEGER;
    l_is_primary_uom_base         VARCHAR2(2);
    l_unit_weight                 NUMBER;
    l_continue                    BOOLEAN;
    l_check_non_upd_attrs         BOOLEAN;
    l_validate_prod_rows          BOOLEAN;
    l_min_date_value              DATE;
    l_max_date_value              DATE;
    l_min_num_value               NUMBER;
    l_max_num_value               NUMBER;
    l_min_char_value              VARCHAR2(4000);
    l_max_char_value              VARCHAR2(4000);


    EANUCC_CODE_UG          CONSTANT VARCHAR2(2) := 'UG';
    EANUCC_CODE_UH          CONSTANT VARCHAR2(2) := 'UH';
    EANUCC_CODE_EN          CONSTANT VARCHAR2(2) := 'EN';
    EANUCC_CODE_UK          CONSTANT VARCHAR2(2) := 'UK';
    EANUCC_CODE_UP          CONSTANT VARCHAR2(2) := 'UP';
    EANUCC_CODE_UI          CONSTANT VARCHAR2(2) := 'UI';
    EANUCC_CODE_UD          CONSTANT VARCHAR2(2) := 'UD';
    EANUCC_CODE_UE          CONSTANT VARCHAR2(2) := 'UE';
    EANUCC_CODE_UA          CONSTANT VARCHAR2(2) := 'UA';
    EANUCC_CODE_UN          CONSTANT VARCHAR2(2) := 'UN';
    EANUCC_CODE_U2          CONSTANT VARCHAR2(2) := 'U2';

    EANUCC_CODE_UG_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_UH_LENGTH   CONSTANT NUMBER := 14;
    EANUCC_CODE_EN_LENGTH   CONSTANT NUMBER := 13;
    EANUCC_CODE_UK_LENGTH   CONSTANT NUMBER := 14;
    EANUCC_CODE_UP_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_UI_LENGTH   CONSTANT NUMBER := 11;
    EANUCC_CODE_UD_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_UE_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_UA_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_UN_LENGTH   CONSTANT NUMBER := 12;
    EANUCC_CODE_U2_LENGTH   CONSTANT NUMBER := 13;

    -- variables to hold production values
    l_dngr_goods_margin_number       EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_MARGIN_NUMBER%TYPE;
    l_dngr_goods_hazardous_code      EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_HAZARDOUS_CODE%TYPE;
    l_dngr_goods_pack_group          EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_PACK_GROUP%TYPE;
    l_dngr_goods_reg_code            EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_REG_CODE%TYPE;
    l_dngr_goods_shipping_name       EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_SHIPPING_NAME%TYPE;
    l_united_nations_dang_goods_no   EGO_ITM_GTN_MUL_ATTRS_VL.UNITED_NATIONS_DANG_GOODS_NO%TYPE;
    l_flash_point_temp               EGO_ITM_GTN_MUL_ATTRS_VL.FLASH_POINT_TEMP%TYPE;
    l_uom_flash_point_temp           EGO_ITM_GTN_MUL_ATTRS_VL.UOM_FLASH_POINT_TEMP%TYPE;
    l_dngr_goods_technical_name      EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_TECHNICAL_NAME%TYPE;
    l_manufacturer_id                EGO_ITM_GTN_MUL_ATTRS_VL.MANUFACTURER_ID%TYPE;
    l_manufacturer_gln               EGO_ITM_GTN_MUL_ATTRS_VL.MANUFACTURER_GLN%TYPE;
  BEGIN
    l_continue := true;
    Debug_Msg('Starting GDSN Attributes Validations for Item,Org='||p_inventory_item_id||','||p_organization_id);
    Debug_Msg('Initializing the fnd error stack');
    -- initializing the fnd error stack
    FND_MSG_PUB.Initialize;

    Debug_Msg('Checking if Item is GDSN Enabled item');

    BEGIN
      SELECT GDSN_OUTBOUND_ENABLED_FLAG INTO l_gdsn_outbound_flag
      FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      IF NVL(G_CALLED_FROM_INTF, 'N') = 'Y' THEN
        BEGIN
          SELECT GDSN_OUTBOUND_ENABLED_FLAG INTO l_gdsn_outbound_flag
          FROM MTL_SYSTEM_ITEMS_INTERFACE msii
          WHERE SET_PROCESS_ID    = G_DATA_SET_ID
            AND PROCESS_FLAG      = 1
            AND INVENTORY_ITEM_ID = p_inventory_item_id
            AND ORGANIZATION_ID   = p_organization_id
            AND ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_gdsn_outbound_flag := 'N';
        END;
      ELSE
        l_gdsn_outbound_flag := 'N';
      END IF;
    END;

    IF NVL(l_gdsn_outbound_flag, 'N') = 'N' THEN
      Debug_Msg('Item is not a GDSN Enabled item, so returning');
      FND_MESSAGE.Set_Name('EGO', 'EGO_NOT_UCCNET_ITEM');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
      x_return_status := 'E';
      RETURN;
    END IF;

    Debug_Msg('Item is GDSN Enabled item');

    -- fetching the single row attribute values from production table into local collection
    OPEN c_prod_single_row_values;
    FETCH c_prod_single_row_values INTO l_prod_single_row_attrs;
    CLOSE c_prod_single_row_values;

    IF NVL(G_CALLED_FROM_INTF, 'N') = 'Y' THEN
      BEGIN
        SELECT TRADE_ITEM_DESCRIPTOR INTO l_trade_item_desc
        FROM MTL_SYSTEM_ITEMS_INTERFACE msii
        WHERE SET_PROCESS_ID    = G_DATA_SET_ID
          AND PROCESS_FLAG      = 1
          AND INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID   = p_organization_id
          AND ROWNUM = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_trade_item_desc := NULL;
      END;
    ELSE
      l_trade_item_desc := NULL;
    END IF;

    l_trade_item_desc := NVL(l_trade_item_desc, l_prod_single_row_attrs.TRADE_ITEM_DESCRIPTOR);
    Debug_Msg('Trade Item Descriptor is '||l_trade_item_desc);
    Debug_Msg('Starting Validations');
    -- validation starts here
    -- 1. if trade item descriptor is not present then error
    Debug_Msg('1. if trade item descriptor is not present then error');
    l_gtid_disp := Get_Attribute_Display_Name('EGO_MASTER_ITEMS', 'TRADE_ITEM_DESCRIPTOR');
    IF l_trade_item_desc IS NULL
    THEN
      FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_MISSING');
      FND_MESSAGE.Set_Token('ATTR_NAME', l_gtid_disp);
      FND_MSG_PUB.ADD;
      l_continue := FALSE;
    END IF;

    -- 2. If trade item descriptor is not BASE_UNIT_OR_EACH then check for attributes (which are non editable)
    --    that they should be null
    Debug_Msg('2. If trade item descriptor is not BASE_UNIT_OR_EACH then check for attributes (which are non editable) that they should be null');
    Debug_Msg('GTID is - '||l_trade_item_desc);

    IF l_continue AND l_trade_item_desc <> 'BASE_UNIT_OR_EACH'
    THEN
      IF NVL(p_singe_row_attrs_rec.ISSN_NUMBER, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.ISSN_NUMBER, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.ISSN_NUMBER IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ISSN_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.ISBN_NUMBER, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.ISBN_NUMBER, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.ISBN_NUMBER IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ISBN_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.PERCENT_OF_ALCOHOL_BY_VOL, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.PERCENT_OF_ALCOHOL_BY_VOL, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PERCENT_OF_ALCOHOL_BY_VOL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.STORAGE_HANDLING_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.STORAGE_HANDLING_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.FAT_PERCENT_IN_DRY_MATTER, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.FAT_PERCENT_IN_DRY_MATTER, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'FAT_PERCENT_IN_DRY_MATTER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'UOM_DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_GREEN_DOT, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_GREEN_DOT, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_GREEN_DOT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_INGRED, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_INGRED, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_PACK_MARKED_WITH_INGRED IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_INGRED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_INGREDIENT_IRRADIATED, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_INGREDIENT_IRRADIATED, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_INGREDIENT_IRRADIATED IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_INGREDIENT_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_RAW_MATERIAL_IRRADIATED, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_RAW_MATERIAL_IRRADIATED, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_RAW_MATERIAL_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_GENETICALLY_MOD, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_GENETICALLY_MOD, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_GENETICALLY_MOD');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_IRRADIATED, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_IRRADIATED, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_TRADE_ITEM_IRRADIATED IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_IRRADIATED');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.SUB_BRAND, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.SUB_BRAND, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.SUB_BRAND IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'SUB_BRAND');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.TRADE_ITEM_COUPON, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.TRADE_ITEM_COUPON, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.TRADE_ITEM_COUPON IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'TRADE_ITEM_COUPON');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.TRADE_ITEM_FORM_DESCRIPTION, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.TRADE_ITEM_FORM_DESCRIPTION, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'TRADE_ITEM_FORM_DESCRIPTION');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.HAS_BATCH_NUMBER, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.HAS_BATCH_NUMBER, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.HAS_BATCH_NUMBER IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'HAS_BATCH_NUMBER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_NON_SOLD_TRADE_RET_FLAG, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_NON_SOLD_TRADE_RET_FLAG, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_NON_SOLD_TRADE_RET_FLAG');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_MAR_REC_FLAG, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_TRADE_ITEM_MAR_REC_FLAG, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_TRADE_ITEM_MAR_REC_FLAG');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_EXP_DATE, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.IS_PACK_MARKED_WITH_EXP_DATE, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'IS_PACK_MARKED_WITH_EXP_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.FUNCTIONAL_NAME, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.FUNCTIONAL_NAME, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.FUNCTIONAL_NAME IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'FUNCTIONAL_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.BRAND_OWNER_GLN IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.BRAND_OWNER_NAME, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.BRAND_OWNER_NAME, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.BRAND_OWNER_NAME IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DIAMETER, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DIAMETER, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DIAMETER IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DIAMETER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.DRAINED_WEIGHT, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.DRAINED_WEIGHT, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.DRAINED_WEIGHT IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DRAINED_WEIGHT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.PEG_HORIZONTAL, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.PEG_HORIZONTAL, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.PEG_HORIZONTAL IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_HORIZONTAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.PEG_VERTICAL, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.PEG_VERTICAL, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.PEG_VERTICAL IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_VERTICAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.GENERIC_INGREDIENT, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.GENERIC_INGREDIENT, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.GENERIC_INGREDIENT IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GENERIC_INGREDIENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.GENERIC_INGREDIENT_STRGTH, G_MISS_NUM) <> G_MISS_NUM
          OR (NVL(p_singe_row_attrs_rec.GENERIC_INGREDIENT_STRGTH, -1) <> G_MISS_NUM AND
              l_prod_single_row_attrs.GENERIC_INGREDIENT_STRGTH IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GENERIC_INGREDIENT_STRGTH');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      IF NVL(p_singe_row_attrs_rec.INGREDIENT_STRENGTH, G_MISS_CHAR) <> G_MISS_CHAR
          OR (NVL(p_singe_row_attrs_rec.INGREDIENT_STRENGTH, G_MISS_CHAR||'@') <> G_MISS_CHAR AND
              l_prod_single_row_attrs.INGREDIENT_STRENGTH IS NOT NULL AND l_validate_prod_rows)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'INGREDIENT_STRENGTH');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
        FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF;

      -- validating for multi row attributes
      -- validating the passed parameters
      IF p_multi_row_attrs_tbl.FIRST IS NOT NULL THEN
        l_index := p_multi_row_attrs_tbl.FIRST;
        WHILE l_index IS NOT NULL LOOP
          IF p_multi_row_attrs_tbl(l_index).TRANSACTION_TYPE <> 'DELETE' THEN
            IF NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_VALUE, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_VALUE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_LIST_AGENCY, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_LIST_AGENCY');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).COUNTRY_OF_ORIGIN, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COUNTRY_OF_ORIGIN');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_ID, G_MISS_NUM) <> G_MISS_NUM THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_ID');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).HANDLING_INSTRUCTIONS_CODE, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'HANDLING_INSTRUCTIONS_CODE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_LIST_AGENCY, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_LIST_AGENCY');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_VALUE, G_MISS_CHAR) <> G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_VALUE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_ATTR_NOT_EDITABLE');
              FND_MESSAGE.Set_Token('GTID', l_gtid_disp);
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;
          END IF; -- if i.transaction_type <> 'DELETE'
          l_index := p_multi_row_attrs_tbl.NEXT(l_index);
        END LOOP; -- end loop while
      END IF; -- if p_multi_row_attrs_tbl.FIRST is not null
    END IF; -- 2. end

    IF l_continue THEN
      -- 3. BrandOwnerGLN must be a number
      Debug_Msg('3. BrandOwnerGLN must be a number');
      l_bgln_valid := TRUE;
      IF NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, G_MISS_CHAR) <> G_MISS_CHAR THEN
        BEGIN
          l_brand_owner_gln := TO_NUMBER(p_singe_row_attrs_rec.BRAND_OWNER_GLN);
        EXCEPTION WHEN VALUE_ERROR THEN
          l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
          FND_MESSAGE.Set_Name('EGO', 'EGO_BGLN_NOT_NUMBER');
          FND_MESSAGE.Set_Token('BGLN', l_attr1_disp);
          FND_MSG_PUB.ADD;
          l_bgln_valid := FALSE;
        END;
      END IF; -- 3.

      -- 4. Length of BrandOwnerGLN must be 13
      Debug_Msg('4. Length of BrandOwnerGLN must be 13');
      IF NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
          AND LENGTH(p_singe_row_attrs_rec.BRAND_OWNER_GLN) <> 13 THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_BGLN_INCORRECT_LENGTH');
        FND_MESSAGE.Set_Token('BGLN', l_attr1_disp);
        FND_MSG_PUB.ADD;
        l_bgln_valid := FALSE;
      END IF; -- 4.

      -- 5. BrandOwnerGLN must have a valid check digit
      Debug_Msg('5. BrandOwnerGLN must have a valid check digit');
      IF l_bgln_valid AND NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN , G_MISS_CHAR) <> G_MISS_CHAR
          AND Is_Check_Digit_Invalid(p_singe_row_attrs_rec.BRAND_OWNER_GLN) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_BGLN_CHECKDIGIT_INVALID');
        FND_MESSAGE.Set_Token('BGLN', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 5.

      -- 6. BrandOwnerGLN and BrandOwnerName must co-exist
      Debug_Msg('6. BrandOwnerGLN and BrandOwnerName must co-exist');
      IF (NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, l_prod_single_row_attrs.BRAND_OWNER_GLN) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
           AND (NVL(p_singe_row_attrs_rec.BRAND_OWNER_NAME, l_prod_single_row_attrs.BRAND_OWNER_NAME) IS NULL
                OR p_singe_row_attrs_rec.BRAND_OWNER_NAME = G_MISS_CHAR) )
         OR
         (NVL(p_singe_row_attrs_rec.BRAND_OWNER_NAME, l_prod_single_row_attrs.BRAND_OWNER_NAME) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.BRAND_OWNER_NAME, G_MISS_CHAR) <> G_MISS_CHAR
           AND (NVL(p_singe_row_attrs_rec.BRAND_OWNER_GLN, l_prod_single_row_attrs.BRAND_OWNER_GLN) IS NULL
                OR p_singe_row_attrs_rec.BRAND_OWNER_GLN = G_MISS_CHAR) ) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_GLN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'BRAND_OWNER_NAME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTRS_MUST_COEXIST');
        FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
        FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 6.

      -- 7. EanuccCode and EanuccType must co-exist
      Debug_Msg('7. EanuccCode and EanuccType must co-exist');
      IF (NVL(p_singe_row_attrs_rec.EANUCC_CODE, l_prod_single_row_attrs.EANUCC_CODE) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.EANUCC_CODE, G_MISS_CHAR) <> G_MISS_CHAR
           AND (NVL(p_singe_row_attrs_rec.EANUCC_TYPE, l_prod_single_row_attrs.EANUCC_TYPE) IS NULL
                OR p_singe_row_attrs_rec.EANUCC_TYPE = G_MISS_CHAR) )
         OR
         (NVL(p_singe_row_attrs_rec.EANUCC_TYPE, l_prod_single_row_attrs.EANUCC_TYPE) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.EANUCC_TYPE, G_MISS_CHAR) <> G_MISS_CHAR
           AND (NVL(p_singe_row_attrs_rec.EANUCC_CODE, l_prod_single_row_attrs.EANUCC_CODE) IS NULL
                OR p_singe_row_attrs_rec.EANUCC_CODE = G_MISS_CHAR) ) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_TYPE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_ATTRS_MUST_COEXIST');
        FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
        FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 7.

      -- 8. EanuccCode must be number
      Debug_Msg('8. EanuccCode must be number');
      l_eanucc_valid := TRUE;
      IF NVL(p_singe_row_attrs_rec.EANUCC_CODE, G_MISS_CHAR) <> G_MISS_CHAR THEN
        BEGIN
          l_eanucc_code_num := TO_NUMBER(p_singe_row_attrs_rec.EANUCC_CODE);
        EXCEPTION WHEN VALUE_ERROR THEN
          l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
          FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_CODE_INVALID_NUMBER');
          FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
          FND_MSG_PUB.ADD;
          l_eanucc_valid := FALSE;
        END;
      END IF; -- 8.

      -- 9. Length of EanuccCode must be equal to that specified by EanuccType
      Debug_Msg('9. Length of EanuccCode must be equal to that specified by EanuccType');
      l_eanucc_code := NVL(p_singe_row_attrs_rec.EANUCC_CODE, l_prod_single_row_attrs.EANUCC_CODE);
      l_eanucc_type := NVL(p_singe_row_attrs_rec.EANUCC_TYPE, l_prod_single_row_attrs.EANUCC_TYPE);
      IF l_eanucc_code = G_MISS_CHAR THEN
        l_eanucc_code := NULL;
      END IF;
      IF l_eanucc_type = G_MISS_CHAR THEN
        l_eanucc_type := NULL;
      END IF;

      IF l_eanucc_code IS NOT NULL AND l_eanucc_type IS NOT NULL THEN
        l_eanucc_code_length := LENGTH(l_eanucc_code);
        IF (EANUCC_CODE_UG = l_eanucc_type AND EANUCC_CODE_UG_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UH = l_eanucc_type AND EANUCC_CODE_UH_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_EN = l_eanucc_type AND EANUCC_CODE_EN_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UK = l_eanucc_type AND EANUCC_CODE_UK_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UP = l_eanucc_type AND EANUCC_CODE_UP_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UI = l_eanucc_type AND EANUCC_CODE_UI_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UD = l_eanucc_type AND EANUCC_CODE_UD_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UE = l_eanucc_type AND EANUCC_CODE_UE_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UA = l_eanucc_type AND EANUCC_CODE_UA_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_UN = l_eanucc_type AND EANUCC_CODE_UN_LENGTH <> l_eanucc_code_length) OR
             (EANUCC_CODE_U2 = l_eanucc_type AND EANUCC_CODE_U2_LENGTH <> l_eanucc_code_length) THEN
          l_eanucc_code_req_length := 0;
          IF EANUCC_CODE_UG = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UG_LENGTH;
          ELSIF EANUCC_CODE_UH = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UH_LENGTH;
          ELSIF EANUCC_CODE_EN = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_EN_LENGTH;
          ELSIF EANUCC_CODE_UK = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UK_LENGTH;
          ELSIF EANUCC_CODE_UP = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UP_LENGTH;
          ELSIF EANUCC_CODE_UI = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UI_LENGTH;
          ELSIF EANUCC_CODE_UD = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UD_LENGTH;
          ELSIF EANUCC_CODE_UE = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UE_LENGTH;
          ELSIF EANUCC_CODE_UA = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UA_LENGTH;
          ELSIF EANUCC_CODE_UN = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_UN_LENGTH;
          ELSIF EANUCC_CODE_U2 = l_eanucc_type THEN
            l_eanucc_code_req_length := EANUCC_CODE_U2_LENGTH;
          END IF;

          l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
          l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_TYPE');
          FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_CODE_INVALID_LENGTH');
          FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
          FND_MESSAGE.Set_Token('LENGTH', l_eanucc_code_req_length);
          FND_MESSAGE.Set_Token('EANUCC_TYPE', l_attr2_disp);
          FND_MSG_PUB.ADD;
          l_eanucc_valid := FALSE;
        END IF;
      END IF; -- 9.

      -- 10. EanuccCode can not start with 098 or 099
      Debug_Msg('10. EanuccCode can not start with 098 or 099');
      IF SUBSTR(p_singe_row_attrs_rec.EANUCC_CODE, 1, 3) IN ('098', '099') THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_1TO3DIGIT_INVALID');
        FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
        FND_MSG_PUB.ADD;
        l_eanucc_valid := FALSE;
      END IF; -- 10.

      -- 11. EanuccCode must have a valid check digit
      Debug_Msg('11. EanuccCode must have a valid check digit');
      IF l_eanucc_valid AND NVL(p_singe_row_attrs_rec.EANUCC_CODE, G_MISS_CHAR) <> G_MISS_CHAR
           AND Is_Check_Digit_Invalid(p_singe_row_attrs_rec.EANUCC_CODE) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_CHECKDIGIT_INVALID');
        FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
        FND_MSG_PUB.ADD;
        l_eanucc_valid := FALSE;
      END IF; -- 11.

      -- 12. EanuccCode and EanuccType must be unique
      Debug_Msg('12. EanuccCode and EanuccType must be unique');
      IF l_eanucc_valid AND l_eanucc_code IS NOT NULL AND l_eanucc_type IS NOT NULL THEN
        BEGIN
          SELECT MSIK.INVENTORY_ITEM_ID, CONCATENATED_SEGMENTS INTO l_item_id, l_item_number
          FROM MTL_SYSTEM_ITEMS_KFV MSIK, EGO_ITEM_GTN_ATTRS_B EGA
          WHERE EGA.INVENTORY_ITEM_ID = MSIK.INVENTORY_ITEM_ID
            AND EGA.ORGANIZATION_ID = MSIK.ORGANIZATION_ID
            AND EGA.EANUCC_CODE = l_eanucc_code
            AND EGA.EANUCC_TYPE = l_eanucc_type
            AND ROWNUM = 1;

          IF (l_item_id <> p_inventory_item_id) THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
            l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_TYPE');
            FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_NOT_UNIQUE');
            FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
            FND_MESSAGE.Set_Token('EANUCC_TYPE', l_attr2_disp);
            FND_MESSAGE.Set_Token('ITEM', l_item_number);
            FND_MSG_PUB.ADD;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          IF NVL(G_CALLED_FROM_INTF, 'N') = 'Y' THEN
            BEGIN
              SELECT INVENTORY_ITEM_ID, ITEM_NUMBER INTO l_item_id, l_item_number
              FROM
              (
                SELECT
                  INVENTORY_ITEM_ID,
                  ITEM_NUMBER,
                  MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'Eanucc_Code', ATTR_VALUE_STR, null), null)) AS EANUCC_CODE,
                  MAX(DECODE(ATTR_GROUP_INT_NAME, 'Trade_Item_Description', DECODE(ATTR_INT_NAME, 'EANUCC_Type', ATTR_VALUE_STR, null), null)) AS EANUCC_TYPE
                FROM EGO_ITM_USR_ATTR_INTRFC
                WHERE ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS'
                  AND DATA_SET_ID = G_DATA_SET_ID
                  AND PROCESS_STATUS = 2
                  AND INVENTORY_ITEM_ID <> p_inventory_item_id
                GROUP BY INVENTORY_ITEM_ID, ITEM_NUMBER
              )
              WHERE EANUCC_CODE = l_eanucc_code
                AND EANUCC_TYPE = l_eanucc_type
                AND ROWNUM = 1;

              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_CODE');
              l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EANUCC_TYPE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_EANUCC_NOT_UNIQUE');
              FND_MESSAGE.Set_Token('EANUCC_CODE', l_attr1_disp);
              FND_MESSAGE.Set_Token('EANUCC_TYPE', l_attr2_disp);
              FND_MESSAGE.Set_Token('ITEM', l_item_number);
              FND_MSG_PUB.ADD;
            EXCEPTION WHEN NO_DATA_FOUND THEN
              NULL;
            END;
          END IF; --IF NVL(G_CALLED_FROM_INTF, 'N') = 'Y' THEN
        END;
      END IF; -- 12.

      -- 13. If Catalog Price is specified, Effective Start Date has to be specified
      Debug_Msg('13. If Catalog Price is specified, Effective Start Date has to be specified');
      IF (NVL(p_singe_row_attrs_rec.CATALOG_PRICE, l_prod_single_row_attrs.CATALOG_PRICE) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.CATALOG_PRICE, G_MISS_NUM) <> G_MISS_NUM
           AND (NVL(p_singe_row_attrs_rec.EFFECTIVE_START_DATE, l_prod_single_row_attrs.EFFECTIVE_START_DATE) IS NULL
                OR p_singe_row_attrs_rec.EFFECTIVE_START_DATE = G_MISS_DATE) ) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_START_DATE');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'CATALOG_PRICE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_EFFSTARTDT_REQD');
        FND_MESSAGE.Set_Token('EFF_ST_DT', l_attr1_disp);
        FND_MESSAGE.Set_Token('RETAIL_CATALOG', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 13.

      -- 14. If Suggested Retail Price is specified, Effective Start Date has to be specified
      Debug_Msg('14. If Suggested Retail Price is specified, Effective Start Date has to be specified');
      IF (NVL(p_singe_row_attrs_rec.SUGGESTED_RETAIL_PRICE, l_prod_single_row_attrs.SUGGESTED_RETAIL_PRICE) IS NOT NULL
           AND NVL(p_singe_row_attrs_rec.SUGGESTED_RETAIL_PRICE, G_MISS_NUM) <> G_MISS_NUM
           AND (NVL(p_singe_row_attrs_rec.EFFECTIVE_START_DATE, l_prod_single_row_attrs.EFFECTIVE_START_DATE) IS NULL
                OR p_singe_row_attrs_rec.EFFECTIVE_START_DATE = G_MISS_DATE) ) THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_START_DATE');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'SUGGESTED_RETAIL_PRICE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_EFFSTARTDT_REQD');
        FND_MESSAGE.Set_Token('EFF_ST_DT', l_attr1_disp);
        FND_MESSAGE.Set_Token('RETAIL_CATALOG', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 14.

      -- validating multi row attributes
      IF p_multi_row_attrs_tbl.FIRST IS NOT NULL THEN
        l_index := p_multi_row_attrs_tbl.FIRST;
        WHILE l_index IS NOT NULL LOOP
          -- 15. If any of the Hazardous attributes are populated then all are required
          Debug_Msg('15. If any of the Hazardous attributes are populated then all are required');
          l_dngr_goods_margin_number := NULL;
          l_dngr_goods_hazardous_code := NULL;
          l_dngr_goods_pack_group := NULL;
          l_dngr_goods_reg_code := NULL;
          l_dngr_goods_shipping_name := NULL;
          l_united_nations_dang_goods_no := NULL;
          l_flash_point_temp := NULL;
          l_uom_flash_point_temp := NULL;
          l_dngr_goods_technical_name := NULL;
          IF p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CODE <> G_MISS_CHAR AND
             p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CODE IS NOT NULL
          THEN
            BEGIN
              SELECT
                DANGEROUS_GOODS_MARGIN_NUMBER,
                DANGEROUS_GOODS_HAZARDOUS_CODE,
                DANGEROUS_GOODS_PACK_GROUP,
                DANGEROUS_GOODS_REG_CODE,
                DANGEROUS_GOODS_SHIPPING_NAME,
                UNITED_NATIONS_DANG_GOODS_NO,
                FLASH_POINT_TEMP,
                UOM_FLASH_POINT_TEMP,
                DANGEROUS_GOODS_TECHNICAL_NAME
              INTO
                l_dngr_goods_margin_number,
                l_dngr_goods_hazardous_code,
                l_dngr_goods_pack_group,
                l_dngr_goods_reg_code,
                l_dngr_goods_shipping_name,
                l_united_nations_dang_goods_no,
                l_flash_point_temp,
                l_uom_flash_point_temp,
                l_dngr_goods_technical_name
              FROM EGO_ITM_GTN_MUL_ATTRS_VL eigmav, EGO_ATTR_GROUPS_V eagv
              WHERE eigmav.INVENTORY_ITEM_ID = p_inventory_item_id
                AND eigmav.ORGANIZATION_ID = p_organization_id
                AND eigmav.ATTR_GROUP_ID = eagv.ATTR_GROUP_ID
                AND eagv.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS'
                AND eagv.APPLICATION_ID = EGO_APPL_ID
                AND eagv.ATTR_GROUP_NAME = 'Hazardous_Information'
                AND eigmav.CLASS_OF_DANGEROUS_CODE = p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CODE;
            EXCEPTION WHEN NO_DATA_FOUND THEN
              NULL;
            END;
          END IF; --IF p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CO

          IF (NVL(p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CODE, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_MARGIN_NUMBER, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_PACK_GROUP, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_REG_CODE, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_SHIPPING_NAME, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).UNITED_NATIONS_DANG_GOODS_NO, G_MISS_NUM) <> G_MISS_NUM OR
              NVL(p_multi_row_attrs_tbl(l_index).FLASH_POINT_TEMP, G_MISS_NUM) <> G_MISS_NUM OR
              NVL(p_multi_row_attrs_tbl(l_index).UOM_FLASH_POINT_TEMP, G_MISS_CHAR) <> G_MISS_CHAR OR
              NVL(p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_TECHNICAL_NAME, G_MISS_CHAR) <> G_MISS_CHAR
             )
          THEN
            IF NVL(p_multi_row_attrs_tbl(l_index).CLASS_OF_DANGEROUS_CODE, G_MISS_CHAR) = G_MISS_CHAR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'CLASS_OF_DANGEROUS_CODE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_MARGIN_NUMBER = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_MARGIN_NUMBER IS NULL
                 AND l_dngr_goods_margin_number IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_MARGIN_NUMBER');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE IS NULL
                 AND l_dngr_goods_hazardous_code IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_HAZARDOUS_CODE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_PACK_GROUP = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_PACK_GROUP IS NULL
                 AND l_dngr_goods_pack_group IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_PACK_GROUP');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_REG_CODE = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_REG_CODE IS NULL
                 AND l_dngr_goods_reg_code IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_REG_CODE');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_SHIPPING_NAME = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_SHIPPING_NAME IS NULL
                 AND l_dngr_goods_shipping_name IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_SHIPPING_NAME');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).UNITED_NATIONS_DANG_GOODS_NO = G_MISS_NUM OR
                (p_multi_row_attrs_tbl(l_index).UNITED_NATIONS_DANG_GOODS_NO IS NULL
                 AND l_united_nations_dang_goods_no IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'UNITED_NATIONS_DANG_GOODS_NO');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).FLASH_POINT_TEMP = G_MISS_NUM OR
                (p_multi_row_attrs_tbl(l_index).FLASH_POINT_TEMP IS NULL
                 AND l_flash_point_temp IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'FLASH_POINT_TEMP');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).UOM_FLASH_POINT_TEMP = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).UOM_FLASH_POINT_TEMP IS NULL
                 AND l_uom_flash_point_temp IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'UOM_FLASH_POINT_TEMP');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;

            IF (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_TECHNICAL_NAME = G_MISS_CHAR OR
                (p_multi_row_attrs_tbl(l_index).DANGEROUS_GOODS_TECHNICAL_NAME IS NULL
                 AND l_dngr_goods_technical_name IS NULL)
               )
            THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'DANGEROUS_GOODS_TECHNICAL_NAME');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MISSING_HAZ_ATTR');
              FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
              FND_MSG_PUB.ADD;
            END IF;
          END IF; -- 15.

          -- 16. ColorCodeListAgency and ColorCodeValue must co-exist
          Debug_Msg('16. ColorCodeListAgency and ColorCodeValue must co-exist');
          IF (p_multi_row_attrs_tbl(l_index).COLOR_CODE_LIST_AGENCY IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_LIST_AGENCY, G_MISS_CHAR) <> G_MISS_CHAR
               AND NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_VALUE, G_MISS_CHAR) = G_MISS_CHAR)
             OR
             (p_multi_row_attrs_tbl(l_index).COLOR_CODE_VALUE IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_VALUE, G_MISS_CHAR) <> G_MISS_CHAR
               AND NVL(p_multi_row_attrs_tbl(l_index).COLOR_CODE_LIST_AGENCY, G_MISS_CHAR) = G_MISS_CHAR) THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_LIST_AGENCY');
            l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'COLOR_CODE_VALUE');
            FND_MESSAGE.Set_Name('EGO', 'EGO_ATTRS_MUST_COEXIST');
            FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
            FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
            FND_MSG_PUB.ADD;
          END IF; -- 16.

          -- 17. Size Code value and Size Code List Agency must coexist
          Debug_Msg('17. Size Code value and Size Code List Agency must coexist');
          IF (p_multi_row_attrs_tbl(l_index).SIZE_CODE_LIST_AGENCY IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_LIST_AGENCY, G_MISS_CHAR) <> G_MISS_CHAR
               AND NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_VALUE, G_MISS_CHAR) = G_MISS_CHAR)
             OR
             (p_multi_row_attrs_tbl(l_index).SIZE_CODE_VALUE IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_VALUE, G_MISS_CHAR) <> G_MISS_CHAR
               AND NVL(p_multi_row_attrs_tbl(l_index).SIZE_CODE_LIST_AGENCY, G_MISS_CHAR) = G_MISS_CHAR) THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_LIST_AGENCY');
            l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'SIZE_CODE_VALUE');
            FND_MESSAGE.Set_Name('EGO', 'EGO_ATTRS_MUST_COEXIST');
            FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
            FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
            FND_MSG_PUB.ADD;
          END IF; -- 17.

          -- 18. ManufacturerGLN and ManufacturerName must coexist
          Debug_Msg('18. ManufacturerGLN and ManufacturerName must coexist');
          l_manufacturer_id := NULL;
          IF p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN IS NOT NULL THEN
            BEGIN
              SELECT MANUFACTURER_ID INTO l_manufacturer_id
              FROM EGO_ITM_GTN_MUL_ATTRS_VL eigmav, EGO_ATTR_GROUPS_V eagv
              WHERE eigmav.INVENTORY_ITEM_ID = p_inventory_item_id
                AND eigmav.ORGANIZATION_ID = p_organization_id
                AND eigmav.ATTR_GROUP_ID = eagv.ATTR_GROUP_ID
                AND eagv.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS'
                AND eagv.APPLICATION_ID = EGO_APPL_ID
                AND eagv.ATTR_GROUP_NAME = 'Manufacturing_Info'
                AND eigmav.MANUFACTURER_GLN = p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN;
            EXCEPTION WHEN NO_DATA_FOUND THEN
              NULL;
            END;
          END IF; --IF p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN IS NOT NULL THEN

          IF (p_multi_row_attrs_tbl(l_index).MANUFACTURER_ID IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_ID, G_MISS_NUM) <> G_MISS_NUM
               AND NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) = G_MISS_CHAR
             )
             OR
             (p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN IS NOT NULL
               AND NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
               AND (p_multi_row_attrs_tbl(l_index).MANUFACTURER_ID = G_MISS_NUM OR
                    (p_multi_row_attrs_tbl(l_index).MANUFACTURER_ID IS NULL AND l_manufacturer_id IS NULL)
                   )
             )
          THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
            l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_ID');
            FND_MESSAGE.Set_Name('EGO', 'EGO_ATTRS_MUST_COEXIST');
            FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
            FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
            FND_MSG_PUB.ADD;
          END IF; -- 18.

          -- 19. ManufacturerGLN must be a number
          Debug_Msg('19. ManufacturerGLN must be a number');
          l_mgln_valid := TRUE;
          IF NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) <> G_MISS_CHAR THEN
            BEGIN
              l_manufacturer_gln := TO_NUMBER(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN);
            EXCEPTION WHEN VALUE_ERROR THEN
              l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
              FND_MESSAGE.Set_Name('EGO', 'EGO_MGLN_NOT_NUMBER');
              FND_MESSAGE.Set_Token('MGLN_VALUE', p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN);
              FND_MESSAGE.Set_Token('MGLN', l_attr1_disp);
              FND_MSG_PUB.ADD;
              l_mgln_valid := FALSE;
            END;
          END IF; -- 19.

          -- 20. Length of ManufacturerGLN must be 13
          Debug_Msg('20. Length of ManufacturerGLN must be 13');
          IF NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
              AND LENGTH(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN) <> 13 THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
            FND_MESSAGE.Set_Name('EGO', 'EGO_MGLN_INCORRECT_LENGTH');
            FND_MESSAGE.Set_Token('MGLN_VALUE', p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN);
            FND_MESSAGE.Set_Token('MGLN', l_attr1_disp);
            FND_MSG_PUB.ADD;
            l_mgln_valid := FALSE;
          END IF; -- 20.

          -- 21. ManufacturerGLN must have a valid check digit
          Debug_Msg('21. ManufacturerGLN must have a valid check digit');
          IF l_mgln_valid AND NVL(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN, G_MISS_CHAR) <> G_MISS_CHAR
                AND Is_Check_Digit_Invalid(p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN) THEN
            l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_MULTI_ATTRS', 'MANUFACTURER_GLN');
            FND_MESSAGE.Set_Name('EGO', 'EGO_MGLN_CHECKDIGIT_INVALID');
            FND_MESSAGE.Set_Token('MGLN_VALUE', p_multi_row_attrs_tbl(l_index).MANUFACTURER_GLN);
            FND_MESSAGE.Set_Token('MGLN', l_attr1_disp);
            FND_MSG_PUB.ADD;
          END IF; -- 21.
          l_index := p_multi_row_attrs_tbl.NEXT(l_index);
        END LOOP; -- multi row validations
      END IF;

      -- 22. Uom is required for NET_CONTENT
      Debug_Msg('22. Uom is required for NET_CONTENT');
      IF NVL(p_singe_row_attrs_rec.NET_CONTENT, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_NET_CONTENT = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_NET_CONTENT IS NULL AND p_singe_row_attrs_rec.UOM_NET_CONTENT IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'NET_CONTENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 22.

      -- 23. Uom is required for GROSS_WEIGHT
      Debug_Msg('23. Uom is required for GROSS_WEIGHT');
      IF NVL(p_singe_row_attrs_rec.GROSS_WEIGHT, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_GROSS_WEIGHT, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GROSS_WEIGHT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 23.

      -- 24. Uom is required for PEG_VERTICAL
      Debug_Msg('24. Uom is required for PEG_VERTICAL');
      IF NVL(p_singe_row_attrs_rec.PEG_VERTICAL, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_PEG_VERTICAL, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_VERTICAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 24.

      -- 25. Uom is required for PEG_HORIZONTAL
      Debug_Msg('25. Uom is required for PEG_HORIZONTAL');
      IF NVL(p_singe_row_attrs_rec.PEG_HORIZONTAL, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_PEG_HORIZONTAL, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PEG_HORIZONTAL');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 25.

      -- 26. Uom is required for DRAINED_WEIGHT
      Debug_Msg('26. Uom is required for DRAINED_WEIGHT');
      IF NVL(p_singe_row_attrs_rec.DRAINED_WEIGHT, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_DRAINED_WEIGHT, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DRAINED_WEIGHT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 26.

      -- 27. Uom is required for DIAMETER
      Debug_Msg('27. Uom is required for DIAMETER');
      IF NVL(p_singe_row_attrs_rec.DIAMETER, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_DIAMETER, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DIAMETER');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 27.

      -- 28. Uom is required for ORDERING_LEAD_TIME
      Debug_Msg('28. Uom is required for ORDERING_LEAD_TIME');
      IF NVL(p_singe_row_attrs_rec.ORDERING_LEAD_TIME, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_ORDERING_LEAD_TIME, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDERING_LEAD_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 28.

      -- 29. Uom is required for GENERIC_INGREDIENT_STRGTH
      Debug_Msg('29. Uom is required for GENERIC_INGREDIENT_STRGTH');
      IF NVL(p_singe_row_attrs_rec.GENERIC_INGREDIENT_STRGTH, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_GENERIC_INGREDIENT_STRGTH, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'GENERIC_INGREDIENT_STRGTH');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 29.

      -- 30. Uom is required for STACKING_WEIGHT_MAXIMUM
      Debug_Msg('30. Uom is required for STACKING_WEIGHT_MAXIMUM');
      IF NVL(p_singe_row_attrs_rec.STACKING_WEIGHT_MAXIMUM, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_STACKING_WEIGHT_MAXIMUM, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STACKING_WEIGHT_MAXIMUM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 30.

      -- 31. Uom is required for PIECES_PER_TRADE_ITEM
      Debug_Msg('31. Uom is required for PIECES_PER_TRADE_ITEM');
      IF NVL(p_singe_row_attrs_rec.PIECES_PER_TRADE_ITEM, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_PIECES_PER_TRADE_ITEM, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'PIECES_PER_TRADE_ITEM');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 31.

      -- 32. Uom is required for NESTING_INCREMENT
      Debug_Msg('32. Uom is required for NESTING_INCREMENT');
      IF NVL(p_singe_row_attrs_rec.NESTING_INCREMENT, G_MISS_NUM) <> G_MISS_NUM
          AND NVL(p_singe_row_attrs_rec.UOM_NESTING_INCREMENT, G_MISS_CHAR) = G_MISS_CHAR THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'NESTING_INCREMENT');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 32.

      -- 33. Uom is required for DEL_TO_DIST_CNTR_TEMP_MIN
      Debug_Msg('33. Uom is required for DEL_TO_DIST_CNTR_TEMP_MIN');
      IF NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NULL
                   AND p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 33.

      -- 34. Uom is required for DEL_TO_DIST_CNTR_TEMP_MAX
      Debug_Msg('34. Uom is required for DEL_TO_DIST_CNTR_TEMP_MAX');
      IF NVL(p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NULL
                   AND p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 34.

      -- 35. Uom is required for DELIVERY_TO_MRKT_TEMP_MIN
      Debug_Msg('35. Uom is required for DELIVERY_TO_MRKT_TEMP_MIN');
      IF NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NULL
                   AND p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 35.

      -- 36. Uom is required for DELIVERY_TO_MRKT_TEMP_MAX
      Debug_Msg('36. Uom is required for DELIVERY_TO_MRKT_TEMP_MAX');
      IF NVL(p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NULL
                   AND p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 36.

      -- 37. Uom is required for STORAGE_HANDLING_TEMP_MIN
      Debug_Msg('37. Uom is required for STORAGE_HANDLING_TEMP_MIN');
      IF NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN IS NULL
                   AND p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 37.

      -- 38. Uom is required for STORAGE_HANDLING_TEMP_MAX
      Debug_Msg('38. Uom is required for STORAGE_HANDLING_TEMP_MAX');
      IF NVL(p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX, G_MISS_NUM) <> G_MISS_NUM
          AND (p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX = G_MISS_CHAR
               OR (l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX IS NULL
                   AND p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX IS NULL)
              )
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_REQD');
        FND_MESSAGE.Set_Token('ATTR_NAME', l_attr1_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 38.

      -- 39. start_availability_date_time can not be greater than end_availability_date_time
      Debug_Msg('39. START_AVAILABILITY_DATE_TIME can not be greater than END_AVAILABILITY_DATE_TIME');
      IF p_singe_row_attrs_rec.START_AVAILABILITY_DATE_TIME IS NULL THEN
        l_min_date_value := l_prod_single_row_attrs.START_AVAILABILITY_DATE_TIME;
      ELSIF p_singe_row_attrs_rec.START_AVAILABILITY_DATE_TIME = G_MISS_DATE THEN
        l_min_date_value := NULL;
      ELSE
        l_min_date_value := p_singe_row_attrs_rec.START_AVAILABILITY_DATE_TIME;
      END IF;

      IF p_singe_row_attrs_rec.END_AVAILABILITY_DATE_TIME IS NULL THEN
        l_max_date_value := l_prod_single_row_attrs.END_AVAILABILITY_DATE_TIME;
      ELSIF p_singe_row_attrs_rec.END_AVAILABILITY_DATE_TIME = G_MISS_DATE THEN
        l_max_date_value := NULL;
      ELSE
        l_max_date_value := p_singe_row_attrs_rec.END_AVAILABILITY_DATE_TIME;
      END IF;

      IF (l_min_date_value IS NOT NULL AND l_max_date_value IS NOT NULL AND l_min_date_value > l_max_date_value) OR
         (l_min_date_value IS NULL AND l_max_date_value IS NOT NULL)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'START_AVAILABILITY_DATE_TIME');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'END_AVAILABILITY_DATE_TIME');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 39.

      -- 40. EFFECTIVE_START_DATE can not be greater than EFFECTIVE_END_DATE
      Debug_Msg('40. EFFECTIVE_START_DATE can not be greater than EFFECTIVE_END_DATE');
      IF p_singe_row_attrs_rec.EFFECTIVE_START_DATE IS NULL THEN
        l_min_date_value := l_prod_single_row_attrs.EFFECTIVE_START_DATE;
      ELSIF p_singe_row_attrs_rec.EFFECTIVE_START_DATE = G_MISS_DATE THEN
        l_min_date_value := NULL;
      ELSE
        l_min_date_value := p_singe_row_attrs_rec.EFFECTIVE_START_DATE;
      END IF;

      IF p_singe_row_attrs_rec.EFFECTIVE_END_DATE IS NULL THEN
        l_max_date_value := l_prod_single_row_attrs.EFFECTIVE_END_DATE;
      ELSIF p_singe_row_attrs_rec.EFFECTIVE_END_DATE = G_MISS_DATE THEN
        l_max_date_value := NULL;
      ELSE
        l_max_date_value := p_singe_row_attrs_rec.EFFECTIVE_END_DATE;
      END IF;

      IF (l_min_date_value IS NOT NULL AND l_max_date_value IS NOT NULL AND l_min_date_value > l_max_date_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_START_DATE');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'EFFECTIVE_END_DATE');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 40.

      -- 41. order_quantity_min can not be greater than order_quantity_max
      Debug_Msg('41. ORDER_QUANTITY_MIN can not be greater than ORDER_QUANTITY_MAX');
      IF p_singe_row_attrs_rec.ORDER_QUANTITY_MIN IS NULL THEN
        l_min_num_value := l_prod_single_row_attrs.ORDER_QUANTITY_MIN;
      ELSIF p_singe_row_attrs_rec.ORDER_QUANTITY_MIN = G_MISS_NUM THEN
        l_min_num_value := NULL;
      ELSE
        l_min_num_value := p_singe_row_attrs_rec.ORDER_QUANTITY_MIN;
      END IF;

      IF p_singe_row_attrs_rec.ORDER_QUANTITY_MAX IS NULL THEN
        l_max_num_value := l_prod_single_row_attrs.ORDER_QUANTITY_MAX;
      ELSIF p_singe_row_attrs_rec.ORDER_QUANTITY_MAX = G_MISS_NUM THEN
        l_max_num_value := NULL;
      ELSE
        l_max_num_value := p_singe_row_attrs_rec.ORDER_QUANTITY_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_num_value > l_max_num_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_QUANTITY_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'ORDER_QUANTITY_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 41.

      -- 42. DEL_TO_DIST_CNTR_TEMP_MIN can not be greater than DEL_TO_DIST_CNTR_TEMP_MAX
      Debug_Msg('42. DEL_TO_DIST_CNTR_TEMP_MIN can not be greater than DEL_TO_DIST_CNTR_TEMP_MAX');
      IF p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN IS NULL THEN
        l_min_num_value := l_prod_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN = G_MISS_NUM THEN
        l_min_num_value := NULL;
      ELSE
        l_min_num_value := p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX IS NULL THEN
        l_max_num_value := l_prod_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX = G_MISS_NUM THEN
        l_max_num_value := NULL;
      ELSE
        l_max_num_value := p_singe_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_num_value > l_max_num_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 42.

      -- 42.1. uom for DEL_TO_DIST_CNTR_TEMP_MIN must be same that of DEL_TO_DIST_CNTR_TEMP_MAX
      Debug_Msg('42.1. uom for DEL_TO_DIST_CNTR_TEMP_MIN must be same that of DEL_TO_DIST_CNTR_TEMP_MAX');
      IF p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NULL THEN
        l_min_char_value := l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN = G_MISS_CHAR THEN
        l_min_char_value := NULL;
      ELSE
        l_min_char_value := p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NULL THEN
        l_max_char_value := l_prod_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX = G_MISS_CHAR THEN
        l_max_char_value := NULL;
      ELSE
        l_max_char_value := p_singe_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_char_value <> l_max_char_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DEL_TO_DIST_CNTR_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_MUST_BE_SAME');
        FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
        FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 42.1.

      -- 43. DELIVERY_TO_MRKT_TEMP_MIN can not be greater than DELIVERY_TO_MRKT_TEMP_MAX
      Debug_Msg('43. DELIVERY_TO_MRKT_TEMP_MIN can not be greater than DELIVERY_TO_MRKT_TEMP_MAX');
      IF p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN IS NULL THEN
        l_min_num_value := l_prod_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN = G_MISS_NUM THEN
        l_min_num_value := NULL;
      ELSE
        l_min_num_value := p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX IS NULL THEN
        l_max_num_value := l_prod_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX = G_MISS_NUM THEN
        l_max_num_value := NULL;
      ELSE
        l_max_num_value := p_singe_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_num_value > l_max_num_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 43.

      -- 43.1. uom for DELIVERY_TO_MRKT_TEMP_MIN must be same that of DELIVERY_TO_MRKT_TEMP_MAX
      Debug_Msg('43.1. uom for DELIVERY_TO_MRKT_TEMP_MIN must be same that of DELIVERY_TO_MRKT_TEMP_MAX');
      IF p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NULL THEN
        l_min_char_value := l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN = G_MISS_CHAR THEN
        l_min_char_value := NULL;
      ELSE
        l_min_char_value := p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NULL THEN
        l_max_char_value := l_prod_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX = G_MISS_CHAR THEN
        l_max_char_value := NULL;
      ELSE
        l_max_char_value := p_singe_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_char_value <> l_max_char_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'DELIVERY_TO_MRKT_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_MUST_BE_SAME');
        FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
        FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 43.1.

      -- 44. STORAGE_HANDLING_TEMP_MIN can not be greater than STORAGE_HANDLING_TEMP_MAX
      Debug_Msg('44. STORAGE_HANDLING_TEMP_MIN can not be greater than STORAGE_HANDLING_TEMP_MAX');
      IF p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN IS NULL THEN
        l_min_num_value := l_prod_single_row_attrs.STORAGE_HANDLING_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN = G_MISS_NUM THEN
        l_min_num_value := NULL;
      ELSE
        l_min_num_value := p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX IS NULL THEN
        l_max_num_value := l_prod_single_row_attrs.STORAGE_HANDLING_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX = G_MISS_NUM THEN
        l_max_num_value := NULL;
      ELSE
        l_max_num_value := p_singe_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_num_value > l_max_num_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_MIN_GT_MAX');
        FND_MESSAGE.Set_Token('MIN_ATTR', l_attr1_disp);
        FND_MESSAGE.Set_Token('MAX_ATTR', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 44.

      -- 44.1. uom for STORAGE_HANDLING_TEMP_MIN must be same that of STORAGE_HANDLING_TEMP_MAX
      Debug_Msg('44.1. uom for STORAGE_HANDLING_TEMP_MIN must be same that of STORAGE_HANDLING_TEMP_MAX');
      IF p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN IS NULL THEN
        l_min_char_value := l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN;
      ELSIF p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN = G_MISS_CHAR THEN
        l_min_char_value := NULL;
      ELSE
        l_min_char_value := p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN;
      END IF;

      IF p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX IS NULL THEN
        l_max_char_value := l_prod_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX;
      ELSIF p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX = G_MISS_CHAR THEN
        l_max_char_value := NULL;
      ELSE
        l_max_char_value := p_singe_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX;
      END IF;

      IF (l_min_num_value IS NOT NULL AND l_max_num_value IS NOT NULL AND l_min_char_value <> l_max_char_value)
      THEN
        l_attr1_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MIN');
        l_attr2_disp := Get_Attribute_Display_Name('EGO_ITEM_GTIN_ATTRS', 'STORAGE_HANDLING_TEMP_MAX');
        FND_MESSAGE.Set_Name('EGO', 'EGO_UOM_MUST_BE_SAME');
        FND_MESSAGE.Set_Token('ATTR1', l_attr1_disp);
        FND_MESSAGE.Set_Token('ATTR2', l_attr2_disp);
        FND_MSG_PUB.ADD;
      END IF; -- 44.1.
    END IF; -- IF l_continue THEN

    FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    IF x_msg_count > 0 THEN
      x_return_status := 'E';
    ELSE
      x_return_status := 'S';
    END IF;
    Debug_Msg('Finished GDSN Attributes Validations for Item,Org='||p_inventory_item_id||','||p_organization_id);
    Debug_Msg('Return Status = '||x_return_status);
  EXCEPTION WHEN OTHERS THEN
    IF c_prod_single_row_values%ISOPEN THEN
      CLOSE c_prod_single_row_values;
    END IF;
    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    Debug_Msg('Unexpected Error in GDSN Attributes Validations - '||x_msg_data);
  END Validate_Attributes;

  /*
   *
   */
  PROCEDURE Do_Post_UCCnet_Attrs_Action ( p_data_set_id  IN  NUMBER
                                         ,p_entity_id   IN  NUMBER
                                         ,p_entity_code IN VARCHAR2
                                         ,p_add_errors_to_fnd_stack IN VARCHAR2) IS
    CURSOR c_intf_rows IS
      SELECT
        INVENTORY_ITEM_ID
       ,ORGANIZATION_ID
       ,ITEM_CATALOG_GROUP_ID
       ,MAX(TRANSACTION_ID) AS TRANSACTION_ID
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = 2
      GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID, ITEM_CATALOG_GROUP_ID;

    CURSOR c_intf_row_attrs(c_inventory_item_id IN NUMBER, c_organization_id IN NUMBER) IS
      SELECT
        eiuai.INVENTORY_ITEM_ID
       ,eiuai.ORGANIZATION_ID
       ,eav.ATTR_ID
       ,eiuai.ATTR_INT_NAME
       ,eiuai.ATTR_VALUE_STR
       ,eiuai.ATTR_VALUE_NUM
       ,eiuai.ATTR_VALUE_DATE
      FROM EGO_ITM_USR_ATTR_INTRFC eiuai, EGO_ATTRS_V eav
      WHERE eiuai.ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND eiuai.ATTR_GROUP_TYPE = eav.ATTR_GROUP_TYPE
        AND eiuai.ATTR_GROUP_INT_NAME = eav.ATTR_GROUP_NAME
        AND eiuai.ATTR_INT_NAME = eav.ATTR_NAME
        AND eav.APPLICATION_ID = EGO_APPL_ID
        AND eiuai.DATA_SET_ID = p_data_set_id
        AND eiuai.PROCESS_STATUS = 2
        AND eiuai.INVENTORY_ITEM_ID = c_inventory_item_id
        AND eiuai.ORGANIZATION_ID = c_organization_id;

    CURSOR c_intf_extn_rows IS
      SELECT
        INVENTORY_ITEM_ID
       ,ORGANIZATION_ID
       ,ATTR_GROUP_INT_NAME
       ,MAX(TRANSACTION_ID) AS TRANSACTION_ID
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND ATTR_GROUP_INT_NAME LIKE 'EGOINT#_GDSN%' ESCAPE '#'
        AND DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = 2
      GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID, ATTR_GROUP_INT_NAME;

    CURSOR c_intf_row_extn_attrs(c_inventory_item_id IN NUMBER, c_organization_id IN NUMBER, c_attr_group_name IN VARCHAR2) IS
      SELECT
        eiuai.INVENTORY_ITEM_ID
       ,eiuai.ORGANIZATION_ID
       ,eiuai.ATTR_INT_NAME
      FROM EGO_ITM_USR_ATTR_INTRFC eiuai
      WHERE eiuai.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND eiuai.ATTR_GROUP_INT_NAME = c_attr_group_name
        AND eiuai.DATA_SET_ID = p_data_set_id
        AND eiuai.PROCESS_STATUS = 2
        AND eiuai.INVENTORY_ITEM_ID = c_inventory_item_id
        AND eiuai.ORGANIZATION_ID = c_organization_id;

    l_attribute_names EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE(null);
    l_attr_diffs      EGO_USER_ATTR_DIFF_TABLE;
    l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
  BEGIN
    Debug_Msg('Starting Do_Post_UCCnet_Attrs_Action');
    FOR i IN c_intf_rows LOOP
      Debug_Msg('Starting Do_Post_UCCnet_Attrs_Action for Item,Org='||i.INVENTORY_ITEM_ID||','||i.ORGANIZATION_ID);
      l_attribute_names := EGO_VARCHAR_TBL_TYPE(null);
      l_attr_diffs := EGO_USER_ATTR_DIFF_TABLE();
      FOR j IN c_intf_row_attrs(i.INVENTORY_ITEM_ID, i.ORGANIZATION_ID) LOOP
        -- populating variable for passing to EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES
        l_attribute_names.EXTEND;
        l_attribute_names(l_attribute_names.COUNT) := j.ATTR_INT_NAME;
        -- populating variable for passing to EGO_GTIN_PVT.Item_Propagate_Attributes
        l_attr_diffs.EXTEND();
        l_attr_diffs(l_attr_diffs.LAST) := EGO_USER_ATTR_DIFF_OBJ
            ( attr_id             => j.ATTR_ID
            , attr_name           => j.ATTR_INT_NAME
            , old_attr_value_str  => null
            , old_attr_value_num  => null
            , old_attr_value_date => null
            , old_attr_uom        => null
            , new_attr_value_str  => NVL(j.ATTR_VALUE_STR, G_MISS_CHAR)
            , new_attr_value_num  => NVL(j.ATTR_VALUE_NUM, G_MISS_NUM)
            , new_attr_value_date => NVL(j.ATTR_VALUE_DATE, G_MISS_DATE)
            , new_attr_uom        => null
            , unique_key_flag     => null
            , extension_id        => null
            );
      END LOOP;

      IF l_attribute_names.COUNT > 0 THEN
        Debug_Msg('Calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES');
        EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES(
          i.INVENTORY_ITEM_ID,
          i.ORGANIZATION_ID,
          l_attribute_names,
          FND_API.G_FALSE,
          l_return_status,
          l_msg_count,
          l_msg_data);

        Debug_Msg('Finished Calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES with status='||l_return_status);
        IF l_return_status <> 'S' THEN
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text              => l_msg_data
             ,p_application_id            => 'EGO'
             ,p_message_type              => FND_API.G_RET_STS_ERROR
             ,p_row_identifier            => i.TRANSACTION_ID
             ,p_entity_id                 => p_entity_id
             ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
             ,p_entity_code               => p_entity_code
             ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
            );
        END IF; -- end IF l_return_st
      END IF; -- end IF l_attribute_names.COUN

      IF l_attr_diffs.COUNT > 0 THEN
        Debug_Msg('Calling EGO_GTIN_PVT.Item_Propagate_Attributes');
        l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', TO_CHAR(i.INVENTORY_ITEM_ID))
          , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', TO_CHAR(i.ORGANIZATION_ID))
          );

        l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(i.ITEM_CATALOG_GROUP_ID)));

        l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', NULL));

        l_msg_data := NULL;
        EGO_GTIN_PVT.Item_Propagate_Attributes
              ( p_pk_column_name_value_pairs => l_pk_column_name_value_pairs
              , p_class_code_name_value_pairs => l_class_code_name_value_pairs
              , p_data_level_name_value_pairs => l_data_level_name_value_pairs
              , p_attr_diffs => l_attr_diffs
              , p_transaction_type => 'UPDATE'
              , x_error_message => l_msg_data
              );
        Debug_Msg('Finished Calling EGO_GTIN_PVT.Item_Propagate_Attributes with '||l_msg_data);
        IF l_msg_data IS NOT NULL THEN
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text              => l_msg_data
             ,p_application_id            => 'EGO'
             ,p_message_type              => FND_API.G_RET_STS_ERROR
             ,p_row_identifier            => i.TRANSACTION_ID
             ,p_entity_id                 => p_entity_id
             ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
             ,p_entity_code               => p_entity_code
             ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
            );
        END IF; -- end IF l_msg_data
      END IF; --  end IF l_attr_diffs.
    END LOOP;

    -- processing GDSN extension attributes
    Debug_Msg('Processing GDSN Extension attributes ');
    FOR i IN c_intf_extn_rows LOOP
      Debug_Msg('Inventory_item_id, Organization_id, Attribute_Group_Name = '||i.INVENTORY_ITEM_ID||', '||i.ORGANIZATION_ID||', '||i.ATTR_GROUP_INT_NAME);
      l_attribute_names.DELETE;
      FOR j IN c_intf_row_extn_attrs(i.INVENTORY_ITEM_ID, i.ORGANIZATION_ID, i.ATTR_GROUP_INT_NAME) LOOP
        Debug_Msg('Adding Attribute - '||j.ATTR_INT_NAME);
        l_attribute_names.EXTEND;
        l_attribute_names(l_attribute_names.COUNT) := j.ATTR_INT_NAME;
      END LOOP; --FOR j IN c_intf_row_extn_attrs(i.INVENTORY_ITEM_ID, i.ORGANIZATION_ID, i.ATTR_GROUP_INT_NAME) LOOP

      -- calling PROCESS_EXTN_ATTRIBUTE_UPDATES
      IF l_attribute_names.COUNT > 0 THEN
        Debug_Msg('Calling EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES');
        EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES(
          i.INVENTORY_ITEM_ID,
          i.ORGANIZATION_ID,
          l_attribute_names,
          i.ATTR_GROUP_INT_NAME,
          FND_API.G_FALSE,
          l_return_status,
          l_msg_count,
          l_msg_data);

        Debug_Msg('Finished Calling EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES with status='||l_return_status);
        IF l_return_status <> 'S' THEN
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text              => l_msg_data
             ,p_application_id            => 'EGO'
             ,p_message_type              => FND_API.G_RET_STS_ERROR
             ,p_row_identifier            => i.TRANSACTION_ID
             ,p_entity_id                 => p_entity_id
             ,p_table_name                => 'EGO_ITM_USR_ATTR_INTRFC'
             ,p_entity_code               => p_entity_code
             ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
            );
        END IF; -- end IF l_return_st
      END IF; -- end IF l_attribute_names.COUN
    END LOOP; -- FOR i IN c_intf_extn_rows LOOP
    Debug_Msg('Done Processing GDSN Extension attributes ');
    Debug_Msg('Finished Do_Post_UCCnet_Attrs_Action');
  END Do_Post_UCCnet_Attrs_Action;

  /*
   */
  PROCEDURE Process_Multi_Row_AG(p_attr_group_name              VARCHAR2,
                                 p_pk_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY,
                                 p_class_code_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY,
                                 p_data_level_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY,
                                 p_extension_id                 NUMBER,
                                 p_transaction_type             VARCHAR2,
                                 p_attr_name_value_pairs        EGO_USER_ATTR_DATA_TABLE,
                                 x_return_status                OUT NOCOPY VARCHAR2,
                                 x_errorcode                    OUT NOCOPY NUMBER,
                                 x_msg_count                    OUT NOCOPY NUMBER,
                                 x_msg_data                     OUT NOCOPY VARCHAR2)
  IS
    l_mode  VARCHAR2(100);
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_errorcode          NUMBER;
  BEGIN
    Debug_Msg('Starting Process_Multi_Row_AG for AG - '||p_attr_group_name);
    IF p_extension_id IS NOT NULL AND NVL(p_transaction_type, 'X') <> 'DELETE' THEN
      l_mode := 'UPDATE';
    ELSIF p_transaction_type = 'DELETE' THEN
      l_mode := 'DELETE';
    ELSE
      l_mode := 'SYNC';
    END IF;
    Debug_Msg('Process_Multi_Row_AG extension_id - '||p_extension_id);
    Debug_Msg('Process_Multi_Row_AG p_transaction_type - '||p_transaction_type);

    EGO_USER_ATTRS_DATA_PVT.Process_Row (
            p_api_version                   => 1.0
           ,p_object_name                   => 'EGO_ITEM'
           ,p_application_id                => 431
           ,p_attr_group_type               => 'EGO_ITEM_GTIN_MULTI_ATTRS'
           ,p_attr_group_name               => p_attr_group_name
           ,p_validate_hierarchy            => FND_API.G_FALSE
           ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
           ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
           ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
           ,p_extension_id                  => p_extension_id
           ,p_attr_name_value_pairs         => p_attr_name_value_pairs
           ,p_entity_id                     => G_ENTITY_ID
           ,p_entity_index                  => G_ENTITY_INDEX
           ,p_entity_code                   => G_ENTITY_CODE
           ,p_mode                          => l_mode
           ,p_init_fnd_msg_list             => FND_API.G_TRUE
           ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
           ,p_commit                        => FND_API.G_FALSE
           ,x_return_status                 => l_return_status
           ,x_errorcode                     => l_errorcode
           ,x_msg_count                     => l_msg_count
           ,x_msg_data                      => l_msg_data
         );
    Debug_Msg('Finished Process_Multi_Row_AG with status - '||l_return_status);

    IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      FOR cnt IN 1..l_msg_count LOOP
        Debug_Msg('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
      END LOOP;
      Debug_Msg('Error msg - '|| l_msg_data);
    ELSE
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
    END IF;
  END Process_Multi_Row_AG;

  /*
   ** This procedure creates/updates the UCCnet attributes for an item
   */
  PROCEDURE Process_UCCnet_Attrs_For_Item (
          p_api_version                   IN   NUMBER
         ,p_inventory_item_id             IN   NUMBER
         ,p_organization_id               IN   NUMBER
         ,p_single_row_attrs_rec          IN   EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ
         ,p_multi_row_attrs_table         IN   EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ
         ,p_check_policy                  IN   VARCHAR2   DEFAULT FND_API.G_TRUE
         ,p_entity_id                     IN   NUMBER     DEFAULT NULL
         ,p_entity_index                  IN   NUMBER     DEFAULT NULL
         ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
         ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
         ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
         ,x_return_status                 OUT NOCOPY VARCHAR2
         ,x_errorcode                     OUT NOCOPY NUMBER
         ,x_msg_count                     OUT NOCOPY NUMBER
         ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    CURSOR c_uom_code IS
      SELECT a.APPLICATION_COLUMN_NAME, u.UOM_CODE
      FROM EGO_FND_DF_COL_USGS_EXT a, MTL_UNITS_OF_MEASURE_TL u
      WHERE a.UOM_CLASS = u.UOM_CLASS(+)
        AND u.BASE_UOM_FLAG(+) = 'Y'
        AND u.LANGUAGE(+) = USERENV('LANG')
        AND a.APPLICATION_ID = 431
        AND a.DESCRIPTIVE_FLEXFIELD_NAME IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND a.APPLICATION_COLUMN_NAME IN (
                       'GROSS_WEIGHT'
                      ,'PEG_VERTICAL'
                      ,'PEG_HORIZONTAL'
                      ,'DRAINED_WEIGHT'
                      ,'DIAMETER'
                      ,'ORDERING_LEAD_TIME'
                      ,'GENERIC_INGREDIENT_STRGTH'
                      ,'STACKING_WEIGHT_MAXIMUM'
                      ,'PIECES_PER_TRADE_ITEM'
                      ,'NESTING_INCREMENT'
                      ,'DEL_TO_DIST_CNTR_TEMP_MIN'
                      ,'DEL_TO_DIST_CNTR_TEMP_MAX'
                      ,'DELIVERY_TO_MRKT_TEMP_MIN'
                      ,'DELIVERY_TO_MRKT_TEMP_MAX'
                      ,'STORAGE_HANDLING_TEMP_MIN'
                      ,'STORAGE_HANDLING_TEMP_MAX'
                      ,'FLASH_POINT_TEMP'
                      );

    CURSOR c_attr_metadata IS
      SELECT ATTR_GROUP_TYPE, ATTR_GROUP_NAME, ATTR_NAME, DATABASE_COLUMN
      FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND APPLICATION_ID = EGO_APPL_ID;

    l_single_row_attrs   EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ;
    l_multi_row_attrs    EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_failed_row_id_list VARCHAR2(4000);
    l_errorcode          NUMBER;
    l_index              BINARY_INTEGER;

    l_msg_text           VARCHAR2(4000);
    l_attributes_row_table            EGO_USER_ATTR_ROW_TABLE;
    l_attributes_data_table           EGO_USER_ATTR_DATA_TABLE;
    l_new_row            BOOLEAN;
    l_row_identifier     NUMBER;
    l_attribute_names    EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE(null);
    l_trade_item_desc    MTL_SYSTEM_ITEMS_B.TRADE_ITEM_DESCRIPTOR%TYPE;
    l_pk_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_cc_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_dl_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_category_id        NUMBER;

    TYPE t_col_list_type IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    l_multi_row_cols     t_col_list_type;

    TYPE t_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE t_attr_row_type IS RECORD(
      ATTR_GROUP_NAME  VARCHAR2(100),
      ATTR_NAME        VARCHAR2(100));

    TYPE t_attr_meta_data_type IS TABLE OF t_attr_row_type INDEX BY VARCHAR2(100);

    l_single_row_attrs_metadata  t_attr_meta_data_type;
    l_multi_row_attrs_metadata   t_attr_meta_data_type;
    l_related_class_codes_list   VARCHAR2(150);

    /*
     * Private Function for Process_UCCnet_Attrs_For_Item
     */
    FUNCTION Create_Attrs_Row_Table(p_attr_group_type  VARCHAR2,
                                    p_attr_group_name  VARCHAR2,
                                    p_get_new_rowid    BOOLEAN,
                                    p_transaction_type VARCHAR2 DEFAULT NULL) RETURN NUMBER AS
      l_row_id NUMBER;
      l_index  BINARY_INTEGER;
      l_transaction_type VARCHAR2(100);
    BEGIN
      l_row_id := NULL;
      IF NVL(g_row_identifier, 0) = 0 THEN
        g_row_identifier := 100;
      END IF; --IF NVL(g_row_identifier, 0) = 0 THEN

      l_transaction_type := p_transaction_type;
      IF l_transaction_type IS NULL THEN
        l_transaction_type := 'SYNC';
      END IF; --IF p_transaction_type IS NULL THEN

      IF l_attributes_row_table.FIRST IS NOT NULL THEN
        l_index := l_attributes_row_table.FIRST;
        WHILE l_index IS NOT NULL LOOP
          IF l_attributes_row_table(l_index).ATTR_GROUP_TYPE = p_attr_group_type
              AND l_attributes_row_table(l_index).ATTR_GROUP_NAME = p_attr_group_name
              AND p_get_new_rowid = FALSE THEN
            l_row_id := l_attributes_row_table(l_index).ROW_IDENTIFIER;
          END IF; --IF l_attributes_row_table(l_i
          l_index := l_attributes_row_table.NEXT(l_index);
        END LOOP; -- end loop while

        IF l_row_id IS NULL THEN
          Debug_Msg('Creating Attrs Row Table for Attribute Group - '||p_attr_group_name||', with transaction type - '||l_transaction_type);
          l_attributes_row_table.EXTEND;
          l_attributes_row_table(l_attributes_row_table.COUNT) := EGO_USER_ATTR_ROW_OBJ(
                                                                        g_row_identifier   -- ROW_IDENTIFIER
                                                                      , NULL               -- ATTR_GROUP_ID
                                                                      , EGO_APPL_ID        -- ATTR_GROUP_APP_ID
                                                                      , p_attr_group_type  -- ATTR_GROUP_TYPE
                                                                      , p_attr_group_name  -- ATTR_GROUP_NAME
                                                                      , 'ITEM_LEVEL'       -- DATA_LEVEL (R12-C)
                                                                      , NULL               -- DATA_LEVEL_1
                                                                      , NULL               -- DATA_LEVEL_2
                                                                      , NULL               -- DATA_LEVEL_3
                                                                      , NULL               -- DATA_LEVEL_4 (R12-C)
                                                                      , NULL               -- DATA_LEVEL_5 (R12-C)
                                                                      , l_transaction_type -- TRANSACTION_TYPE
                                                                      );
          l_row_id := g_row_identifier;
          g_row_identifier := g_row_identifier + 1;
        END IF; --IF l_row_id IS NULL THEN
      ELSE
        Debug_Msg('Creating Attrs Row Table for Attribute Group.. - '||p_attr_group_name||', with transaction type - '||l_transaction_type);
        l_attributes_row_table.EXTEND;
        l_attributes_row_table(l_attributes_row_table.COUNT) := EGO_USER_ATTR_ROW_OBJ(
                                                                        g_row_identifier   -- ROW_IDENTIFIER
                                                                      , NULL               -- ATTR_GROUP_ID
                                                                      , EGO_APPL_ID        -- ATTR_GROUP_APP_ID
                                                                      , p_attr_group_type  -- ATTR_GROUP_TYPE
                                                                      , p_attr_group_name  -- ATTR_GROUP_NAME
                                                                      , 'ITEM_LEVEL'       -- DATA_LEVEL (R12-C)
                                                                      , NULL               -- DATA_LEVEL_1
                                                                      , NULL               -- DATA_LEVEL_2
                                                                      , NULL               -- DATA_LEVEL_3
                                                                      , NULL               -- DATA_LEVEL_4 (R12-C)
                                                                      , NULL               -- DATA_LEVEL_5 (R12-C)
                                                                      , l_transaction_type -- TRANSACTION_TYPE
                                                                      );
        l_row_id := g_row_identifier;
        g_row_identifier := g_row_identifier + 1;
      END IF; --IF l_attributes_row_table.FIRST IS
      RETURN l_row_id;
    END Create_Attrs_Row_Table;

  BEGIN
    IF FND_API.To_Boolean(p_init_error_handler) THEN
      ERROR_HANDLER.Initialize;
      ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);
      Debug_Msg('Initialized error handler');
    END IF;
    Debug_Msg('Starting Process_UCCnet_Attrs_For_Item for Item,Org='||p_inventory_item_id||','||p_organization_id);

    l_single_row_attrs := p_single_row_attrs_rec;
    l_multi_row_attrs := p_multi_row_attrs_table;
    G_ENTITY_ID := p_entity_id;
    G_ENTITY_INDEX := p_entity_index;
    G_ENTITY_CODE := p_entity_code;

    -- Bug: 5526085 added not null check
    IF l_multi_row_attrs.FIRST IS NOT NULL THEN
      Debug_Msg('Following are the multi-row attribute values ...');
      FOR i IN l_multi_row_attrs.FIRST..l_multi_row_attrs.LAST LOOP
        Debug_Msg('l_multi_row_attrs('||i||').EXTENSION_ID - '||l_multi_row_attrs(i).EXTENSION_ID);
        Debug_Msg('l_multi_row_attrs('||i||').TRANSACTION_TYPE - '||l_multi_row_attrs(i).TRANSACTION_TYPE);
        Debug_Msg('l_multi_row_attrs('||i||').MANUFACTURER_GLN - '||l_multi_row_attrs(i).MANUFACTURER_GLN);
        Debug_Msg('l_multi_row_attrs('||i||').MANUFACTURER_ID - '||l_multi_row_attrs(i).MANUFACTURER_ID);
        Debug_Msg('l_multi_row_attrs('||i||').BAR_CODE_TYPE - '||l_multi_row_attrs(i).BAR_CODE_TYPE);
        Debug_Msg('l_multi_row_attrs('||i||').COLOR_CODE_LIST_AGENCY - '||l_multi_row_attrs(i).COLOR_CODE_LIST_AGENCY);
        Debug_Msg('l_multi_row_attrs('||i||').COLOR_CODE_VALUE - '||l_multi_row_attrs(i).COLOR_CODE_VALUE);
        Debug_Msg('l_multi_row_attrs('||i||').CLASS_OF_DANGEROUS_CODE - '||l_multi_row_attrs(i).CLASS_OF_DANGEROUS_CODE);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_MARGIN_NUMBER - '||l_multi_row_attrs(i).DANGEROUS_GOODS_MARGIN_NUMBER);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_HAZARDOUS_CODE - '||l_multi_row_attrs(i).DANGEROUS_GOODS_HAZARDOUS_CODE);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_PACK_GROUP - '||l_multi_row_attrs(i).DANGEROUS_GOODS_PACK_GROUP);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_REG_CODE - '||l_multi_row_attrs(i).DANGEROUS_GOODS_REG_CODE);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_SHIPPING_NAME - '||l_multi_row_attrs(i).DANGEROUS_GOODS_SHIPPING_NAME);
        Debug_Msg('l_multi_row_attrs('||i||').UNITED_NATIONS_DANG_GOODS_NO - '||l_multi_row_attrs(i).UNITED_NATIONS_DANG_GOODS_NO);
        Debug_Msg('l_multi_row_attrs('||i||').FLASH_POINT_TEMP - '||l_multi_row_attrs(i).FLASH_POINT_TEMP);
        Debug_Msg('l_multi_row_attrs('||i||').UOM_FLASH_POINT_TEMP - '||l_multi_row_attrs(i).UOM_FLASH_POINT_TEMP);
        Debug_Msg('l_multi_row_attrs('||i||').COUNTRY_OF_ORIGIN - '||l_multi_row_attrs(i).COUNTRY_OF_ORIGIN);
        Debug_Msg('l_multi_row_attrs('||i||').HARMONIZED_TARIFF_SYS_ID_CODE - '||l_multi_row_attrs(i).HARMONIZED_TARIFF_SYS_ID_CODE);
        Debug_Msg('l_multi_row_attrs('||i||').SIZE_CODE_LIST_AGENCY - '||l_multi_row_attrs(i).SIZE_CODE_LIST_AGENCY);
        Debug_Msg('l_multi_row_attrs('||i||').SIZE_CODE_VALUE - '||l_multi_row_attrs(i).SIZE_CODE_VALUE);
        Debug_Msg('l_multi_row_attrs('||i||').HANDLING_INSTRUCTIONS_CODE - '||l_multi_row_attrs(i).HANDLING_INSTRUCTIONS_CODE);
        Debug_Msg('l_multi_row_attrs('||i||').DANGEROUS_GOODS_TECHNICAL_NAME - '||l_multi_row_attrs(i).DANGEROUS_GOODS_TECHNICAL_NAME);
        Debug_Msg('l_multi_row_attrs('||i||').DELIVERY_METHOD_INDICATOR - '||l_multi_row_attrs(i).DELIVERY_METHOD_INDICATOR);
      END LOOP;
    END IF;

    SELECT ITEM_CATALOG_GROUP_ID INTO l_category_id
    FROM MTL_SYSTEM_ITEMS_B
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id;

    l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY( EGO_COL_NAME_VALUE_PAIR_OBJ( 'INVENTORY_ITEM_ID' , TO_CHAR(p_inventory_item_id))
                                                                  ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'ORGANIZATION_ID' , TO_CHAR(p_organization_id) ) );

    -- Bug: 5523366
    EGO_ITEM_PVT.Get_Related_Class_Codes(
         p_classification_code      => l_category_id
       , x_related_class_codes_list => l_related_class_codes_list );

    l_cc_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                          EGO_COL_NAME_VALUE_PAIR_OBJ( 'ITEM_CATALOG_GROUP_ID' , TO_CHAR(l_category_id) )
                                        , EGO_COL_NAME_VALUE_PAIR_OBJ( 'RELATED_CLASS_CODE_LIST_1' , l_related_class_codes_list ));

    l_dl_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID' , NULL));

    Debug_Msg('Checking the Trade Item Descriptor');
    BEGIN
      SELECT TRADE_ITEM_DESCRIPTOR INTO l_trade_item_desc
      FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_trade_item_desc := NULL;
    END;
    Debug_Msg('Production Trade Item Descriptor is '||l_trade_item_desc);

    Debug_Msg('Populating Unit Of Measures');
    FOR i IN c_uom_code LOOP
      IF i.APPLICATION_COLUMN_NAME = 'GROSS_WEIGHT'
          AND l_single_row_attrs.UOM_GROSS_WEIGHT IS NULL AND l_single_row_attrs.GROSS_WEIGHT IS NOT NULL THEN
        l_single_row_attrs.UOM_GROSS_WEIGHT := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'PEG_VERTICAL'
          AND l_single_row_attrs.UOM_PEG_VERTICAL IS NULL AND l_single_row_attrs.PEG_VERTICAL IS NOT NULL THEN
        l_single_row_attrs.UOM_PEG_VERTICAL := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'PEG_HORIZONTAL'
          AND l_single_row_attrs.UOM_PEG_HORIZONTAL IS NULL AND l_single_row_attrs.PEG_HORIZONTAL IS NOT NULL THEN
        l_single_row_attrs.UOM_PEG_HORIZONTAL := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DRAINED_WEIGHT'
          AND l_single_row_attrs.UOM_DRAINED_WEIGHT IS NULL AND l_single_row_attrs.DRAINED_WEIGHT IS NOT NULL THEN
        l_single_row_attrs.UOM_DRAINED_WEIGHT := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DIAMETER'
          AND l_single_row_attrs.UOM_DIAMETER IS NULL AND l_single_row_attrs.DIAMETER IS NOT NULL THEN
        l_single_row_attrs.UOM_DIAMETER := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'ORDERING_LEAD_TIME'
          AND l_single_row_attrs.UOM_ORDERING_LEAD_TIME IS NULL AND l_single_row_attrs.ORDERING_LEAD_TIME IS NOT NULL THEN
        l_single_row_attrs.UOM_ORDERING_LEAD_TIME := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'GENERIC_INGREDIENT_STRGTH'
          AND l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH IS NULL AND l_single_row_attrs.GENERIC_INGREDIENT_STRGTH IS NOT NULL THEN
        l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'STACKING_WEIGHT_MAXIMUM'
          AND l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM IS NULL AND l_single_row_attrs.STACKING_WEIGHT_MAXIMUM IS NOT NULL THEN
        l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'PIECES_PER_TRADE_ITEM'
          AND l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM IS NULL AND l_single_row_attrs.PIECES_PER_TRADE_ITEM IS NOT NULL THEN
        l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'NESTING_INCREMENT'
          AND l_single_row_attrs.UOM_NESTING_INCREMENT IS NULL AND l_single_row_attrs.NESTING_INCREMENT IS NOT NULL THEN
        l_single_row_attrs.UOM_NESTING_INCREMENT := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DEL_TO_DIST_CNTR_TEMP_MIN'
          AND l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NULL AND l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN IS NOT NULL THEN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DEL_TO_DIST_CNTR_TEMP_MAX'
          AND l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NULL AND l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX IS NOT NULL THEN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DELIVERY_TO_MRKT_TEMP_MIN'
          AND l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NULL AND l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN IS NOT NULL THEN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'DELIVERY_TO_MRKT_TEMP_MAX'
          AND l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NULL AND l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX IS NOT NULL THEN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'STORAGE_HANDLING_TEMP_MIN'
          AND l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN IS NULL AND l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN IS NOT NULL THEN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'STORAGE_HANDLING_TEMP_MAX'
          AND l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX IS NULL AND l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX IS NOT NULL THEN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX := i.UOM_CODE;
      ELSIF i.APPLICATION_COLUMN_NAME = 'FLASH_POINT_TEMP' AND l_multi_row_attrs.FIRST IS NOT NULL THEN
        l_index := l_multi_row_attrs.FIRST;
        WHILE l_index IS NOT NULL LOOP
          IF l_multi_row_attrs(l_index).FLASH_POINT_TEMP IS NOT NULL AND l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP IS NULL THEN
            l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP := i.UOM_CODE;
          END IF;
          l_index := l_multi_row_attrs.NEXT(l_index);
        END LOOP;
      END IF;
    END LOOP;

    Debug_Msg('Calling Validate_Attributes');
    Validate_Attributes(
           p_inventory_item_id     -- p_inventory_item_id
          ,p_organization_id       -- p_organization_id
          ,l_single_row_attrs      -- p_single_row_attrs_rec
          ,l_multi_row_attrs       -- p_multi_row_attrs_tbl
          ,null                    -- p_extra_attrs_rec
          ,l_return_status         -- x_return_status
          ,l_msg_count             -- x_msg_count
          ,l_msg_data              -- x_msg_data
          );

    Debug_Msg('After Validate_Attributes, Return_Status='||l_return_status);
    IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      IF l_msg_count > 0 AND l_return_status <> 'U' THEN
        FOR cnt IN 1..l_msg_count LOOP
          Debug_Msg('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
          l_msg_text := FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F');
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text                  => l_msg_text
             ,p_application_id                => 'EGO'
             ,p_message_type                  => FND_API.G_RET_STS_ERROR
             ,p_row_identifier                => p_inventory_item_id
             ,p_entity_id                     => p_entity_id
             ,p_entity_index                  => p_entity_index
             ,p_entity_code                   => p_entity_code
            );
        END LOOP;
      ELSIF l_msg_count > 0 AND l_return_status = 'U' THEN
        Debug_Msg('Error msg - '|| l_msg_data);
        l_msg_text := l_msg_data;
        ERROR_HANDLER.Add_Error_Message
          (
            p_message_text                  => l_msg_text
           ,p_application_id                => 'EGO'
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_row_identifier                => p_inventory_item_id
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
          );
      END IF; -- IF l_msg_count

      IF (FND_API.To_Boolean(p_init_error_handler)) THEN
        ERROR_HANDLER.Log_Error
         (p_write_err_to_inttable    => 'Y'
         ,p_write_err_to_conclog     => 'N'
         ,p_write_err_to_debugfile   => ERROR_HANDLER.Get_Debug()
        );
      END IF;
      Debug_Msg('Returning from Process_UCCnet_Attrs_For_Item');
      RETURN;
    END IF; -- IF l_return_status <> 'S

    l_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
    l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();

    Debug_Msg('Populating Attributes metadata into local array');
    FOR i IN c_attr_metadata LOOP
      IF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS' THEN
        l_single_row_attrs_metadata(i.DATABASE_COLUMN).ATTR_GROUP_NAME := i.ATTR_GROUP_NAME;
        l_single_row_attrs_metadata(i.DATABASE_COLUMN).ATTR_NAME := i.ATTR_NAME;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS' THEN
        l_multi_row_attrs_metadata(i.DATABASE_COLUMN).ATTR_GROUP_NAME := i.ATTR_GROUP_NAME;
        l_multi_row_attrs_metadata(i.DATABASE_COLUMN).ATTR_NAME := i.ATTR_NAME;
      END IF;
    END LOOP;

    Debug_Msg('Populating single row attributes');
    -- Populating single row attributes
    IF l_single_row_attrs.BRAND_NAME IS NOT NULL THEN
      IF l_single_row_attrs.BRAND_NAME = G_MISS_CHAR THEN
        l_single_row_attrs.BRAND_NAME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for BRAND_NAME - '||l_single_row_attrs.BRAND_NAME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('BRAND_NAME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('BRAND_NAME').ATTR_NAME,
                                                                 l_single_row_attrs.BRAND_NAME,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('BRAND_NAME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.INVOICE_NAME IS NOT NULL THEN
      IF l_single_row_attrs.INVOICE_NAME = G_MISS_CHAR THEN
        l_single_row_attrs.INVOICE_NAME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for INVOICE_NAME - '||l_single_row_attrs.INVOICE_NAME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('INVOICE_NAME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('INVOICE_NAME').ATTR_NAME,
                                                                 l_single_row_attrs.INVOICE_NAME,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('INVOICE_NAME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.SUB_BRAND IS NOT NULL THEN
      IF l_single_row_attrs.SUB_BRAND = G_MISS_CHAR THEN
        l_single_row_attrs.SUB_BRAND := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for SUB_BRAND - '||l_single_row_attrs.SUB_BRAND);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('SUB_BRAND').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('SUB_BRAND').ATTR_NAME,
                                                                 l_single_row_attrs.SUB_BRAND,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('SUB_BRAND').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.EANUCC_CODE IS NOT NULL THEN
      IF l_single_row_attrs.EANUCC_CODE = G_MISS_CHAR THEN
        l_single_row_attrs.EANUCC_CODE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for EANUCC_CODE - '||l_single_row_attrs.EANUCC_CODE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('EANUCC_CODE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('EANUCC_CODE').ATTR_NAME,
                                                                 l_single_row_attrs.EANUCC_CODE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('EANUCC_CODE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.EANUCC_TYPE IS NOT NULL THEN
      IF l_single_row_attrs.EANUCC_TYPE = G_MISS_CHAR THEN
        l_single_row_attrs.EANUCC_TYPE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for EANUCC_TYPE - '||l_single_row_attrs.EANUCC_TYPE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('EANUCC_TYPE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('EANUCC_TYPE').ATTR_NAME,
                                                                 l_single_row_attrs.EANUCC_TYPE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('EANUCC_TYPE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DESCRIPTION_SHORT IS NOT NULL THEN
      IF l_single_row_attrs.DESCRIPTION_SHORT = G_MISS_CHAR THEN
        l_single_row_attrs.DESCRIPTION_SHORT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DESCRIPTION_SHORT - '||l_single_row_attrs.DESCRIPTION_SHORT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DESCRIPTION_SHORT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DESCRIPTION_SHORT').ATTR_NAME,
                                                                 l_single_row_attrs.DESCRIPTION_SHORT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DESCRIPTION_SHORT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.TRADE_ITEM_COUPON IS NOT NULL THEN
      IF l_single_row_attrs.TRADE_ITEM_COUPON = G_MISS_NUM THEN
        l_single_row_attrs.TRADE_ITEM_COUPON := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for TRADE_ITEM_COUPON - '||l_single_row_attrs.TRADE_ITEM_COUPON);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('TRADE_ITEM_COUPON').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('TRADE_ITEM_COUPON').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.TRADE_ITEM_COUPON,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('TRADE_ITEM_COUPON').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION IS NOT NULL THEN
      IF l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION = G_MISS_CHAR THEN
        l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for TRADE_ITEM_FORM_DESCRIPTION - '||l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('TRADE_ITEM_FORM_DESCRIPTION').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('TRADE_ITEM_FORM_DESCRIPTION').ATTR_NAME,
                                                                 l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('TRADE_ITEM_FORM_DESCRIPTION').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.FUNCTIONAL_NAME IS NOT NULL THEN
      IF l_single_row_attrs.FUNCTIONAL_NAME = G_MISS_CHAR THEN
        l_single_row_attrs.FUNCTIONAL_NAME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for FUNCTIONAL_NAME - '||l_single_row_attrs.FUNCTIONAL_NAME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('FUNCTIONAL_NAME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('FUNCTIONAL_NAME').ATTR_NAME,
                                                                 l_single_row_attrs.FUNCTIONAL_NAME,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('FUNCTIONAL_NAME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE IS NOT NULL THEN
      IF l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE = G_MISS_CHAR THEN
        l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_BARCODE_SYMBOLOGY_DERIVABLE - '||l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_BARCODE_SYMBOLOGY_DERIVABLE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_BARCODE_SYMBOLOGY_DERIVABLE').ATTR_NAME,
                                                                 l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_BARCODE_SYMBOLOGY_DERIVABLE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.BRAND_OWNER_GLN IS NOT NULL THEN
      IF l_single_row_attrs.BRAND_OWNER_GLN = G_MISS_CHAR THEN
        l_single_row_attrs.BRAND_OWNER_GLN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for BRAND_OWNER_GLN - '||l_single_row_attrs.BRAND_OWNER_GLN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('BRAND_OWNER_GLN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('BRAND_OWNER_GLN').ATTR_NAME,
                                                                 l_single_row_attrs.BRAND_OWNER_GLN,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('BRAND_OWNER_GLN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.BRAND_OWNER_NAME IS NOT NULL THEN
      IF l_single_row_attrs.BRAND_OWNER_NAME = G_MISS_CHAR THEN
        l_single_row_attrs.BRAND_OWNER_NAME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for BRAND_OWNER_NAME - '||l_single_row_attrs.BRAND_OWNER_NAME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('BRAND_OWNER_NAME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('BRAND_OWNER_NAME').ATTR_NAME,
                                                                 l_single_row_attrs.BRAND_OWNER_NAME,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('BRAND_OWNER_NAME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.NET_CONTENT IS NOT NULL THEN
      IF l_single_row_attrs.NET_CONTENT = G_MISS_NUM THEN
        l_single_row_attrs.NET_CONTENT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for NET_CONTENT - '||l_single_row_attrs.NET_CONTENT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('NET_CONTENT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('NET_CONTENT').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.NET_CONTENT,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('NET_CONTENT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.GROSS_WEIGHT IS NOT NULL THEN
      IF l_single_row_attrs.GROSS_WEIGHT = G_MISS_NUM THEN
        l_single_row_attrs.GROSS_WEIGHT := NULL;
      END IF;
      IF l_single_row_attrs.UOM_GROSS_WEIGHT = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_GROSS_WEIGHT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for GROSS_WEIGHT - '||l_single_row_attrs.GROSS_WEIGHT);
      Debug_Msg('Creating Attribute Data Object for UOM_GROSS_WEIGHT - '||l_single_row_attrs.UOM_GROSS_WEIGHT);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('GROSS_WEIGHT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('GROSS_WEIGHT').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.GROSS_WEIGHT,
                                                                 NULL, NULL, l_single_row_attrs.UOM_GROSS_WEIGHT, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('GROSS_WEIGHT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_NET_CONTENT IS NOT NULL THEN
      IF l_single_row_attrs.UOM_NET_CONTENT = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_NET_CONTENT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_NET_CONTENT - '||l_single_row_attrs.UOM_NET_CONTENT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_NET_CONTENT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_NET_CONTENT').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_NET_CONTENT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_NET_CONTENT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DIAMETER IS NOT NULL THEN
      IF l_single_row_attrs.DIAMETER = G_MISS_NUM THEN
        l_single_row_attrs.DIAMETER := NULL;
      END IF;
      IF l_single_row_attrs.UOM_DIAMETER = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DIAMETER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DIAMETER - '||l_single_row_attrs.DIAMETER);
      Debug_Msg('Creating Attribute Data Object for UOM_DIAMETER - '||l_single_row_attrs.UOM_DIAMETER);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DIAMETER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DIAMETER').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DIAMETER,
                                                                 NULL, NULL, l_single_row_attrs.UOM_DIAMETER, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DIAMETER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM IS NOT NULL THEN
      IF l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM = G_MISS_CHAR THEN
        l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DEPT_OF_TRNSPRT_DANG_GOODS_NUM - '||l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DEPT_OF_TRNSPRT_DANG_GOODS_NUM').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DEPT_OF_TRNSPRT_DANG_GOODS_NUM').ATTR_NAME,
                                                                 l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DEPT_OF_TRNSPRT_DANG_GOODS_NUM').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.RETURN_GOODS_POLICY IS NOT NULL THEN
      IF l_single_row_attrs.RETURN_GOODS_POLICY = G_MISS_CHAR THEN
        l_single_row_attrs.RETURN_GOODS_POLICY := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for RETURN_GOODS_POLICY - '||l_single_row_attrs.RETURN_GOODS_POLICY);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('RETURN_GOODS_POLICY').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('RETURN_GOODS_POLICY').ATTR_NAME,
                                                                 l_single_row_attrs.RETURN_GOODS_POLICY,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('RETURN_GOODS_POLICY').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.EFFECTIVE_END_DATE IS NOT NULL THEN
      IF l_single_row_attrs.EFFECTIVE_END_DATE = G_MISS_DATE THEN
        l_single_row_attrs.EFFECTIVE_END_DATE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for EFFECTIVE_END_DATE - '||l_single_row_attrs.EFFECTIVE_END_DATE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('EFFECTIVE_END_DATE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('EFFECTIVE_END_DATE').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.EFFECTIVE_END_DATE,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('EFFECTIVE_END_DATE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.SUGGESTED_RETAIL_PRICE IS NOT NULL THEN
      IF l_single_row_attrs.SUGGESTED_RETAIL_PRICE = G_MISS_NUM THEN
        l_single_row_attrs.SUGGESTED_RETAIL_PRICE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for SUGGESTED_RETAIL_PRICE - '||l_single_row_attrs.SUGGESTED_RETAIL_PRICE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('SUGGESTED_RETAIL_PRICE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('SUGGESTED_RETAIL_PRICE').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.SUGGESTED_RETAIL_PRICE,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('SUGGESTED_RETAIL_PRICE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_A_CONSUMER_UNIT - '||l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_A_CONSUMER_UNIT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_A_CONSUMER_UNIT').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_A_CONSUMER_UNIT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_A_BASE_UNIT - '||l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_A_BASE_UNIT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_A_BASE_UNIT').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_A_BASE_UNIT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_A_VARIABLE_UNIT - '||l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_A_VARIABLE_UNIT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_A_VARIABLE_UNIT').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_A_VARIABLE_UNIT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG IS NOT NULL THEN
      IF l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG = G_MISS_CHAR THEN
        l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_NET_CONTENT_DEC_FLAG - '||l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_NET_CONTENT_DEC_FLAG').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_NET_CONTENT_DEC_FLAG').ATTR_NAME,
                                                                 l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_NET_CONTENT_DEC_FLAG').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DRAINED_WEIGHT IS NOT NULL THEN
      IF l_single_row_attrs.DRAINED_WEIGHT = G_MISS_NUM THEN
        l_single_row_attrs.DRAINED_WEIGHT := NULL;
      END IF;
      IF l_single_row_attrs.UOM_DRAINED_WEIGHT = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DRAINED_WEIGHT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DRAINED_WEIGHT - '||l_single_row_attrs.DRAINED_WEIGHT);
      Debug_Msg('Creating Attribute Data Object for UOM_DRAINED_WEIGHT - '||l_single_row_attrs.UOM_DRAINED_WEIGHT);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DRAINED_WEIGHT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DRAINED_WEIGHT').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DRAINED_WEIGHT,
                                                                 NULL, NULL, l_single_row_attrs.UOM_DRAINED_WEIGHT, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DRAINED_WEIGHT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.PEG_HORIZONTAL IS NOT NULL THEN
      IF l_single_row_attrs.PEG_HORIZONTAL = G_MISS_NUM THEN
        l_single_row_attrs.PEG_HORIZONTAL := NULL;
      END IF;
      IF l_single_row_attrs.UOM_PEG_HORIZONTAL = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_PEG_HORIZONTAL := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for PEG_HORIZONTAL - '||l_single_row_attrs.PEG_HORIZONTAL);
      Debug_Msg('Creating Attribute Data Object for UOM_PEG_HORIZONTAL - '||l_single_row_attrs.UOM_PEG_HORIZONTAL);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('PEG_HORIZONTAL').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('PEG_HORIZONTAL').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.PEG_HORIZONTAL,
                                                                 NULL, NULL, l_single_row_attrs.UOM_PEG_HORIZONTAL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('PEG_HORIZONTAL').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.PEG_VERTICAL IS NOT NULL THEN
      IF l_single_row_attrs.PEG_VERTICAL = G_MISS_NUM THEN
        l_single_row_attrs.PEG_VERTICAL := NULL;
      END IF;
      IF l_single_row_attrs.UOM_PEG_VERTICAL = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_PEG_VERTICAL := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for PEG_VERTICAL - '||l_single_row_attrs.PEG_VERTICAL);
      Debug_Msg('Creating Attribute Data Object for UOM_PEG_VERTICAL - '||l_single_row_attrs.UOM_PEG_VERTICAL);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('PEG_VERTICAL').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('PEG_VERTICAL').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.PEG_VERTICAL,
                                                                 NULL, NULL, l_single_row_attrs.UOM_PEG_VERTICAL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('PEG_VERTICAL').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_INFO_PRIVATE - '||l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_INFO_PRIVATE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_INFO_PRIVATE').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_INFO_PRIVATE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM IS NOT NULL THEN
      IF l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM = G_MISS_NUM THEN
        l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for QUANTITY_OF_COMP_LAY_ITEM - '||l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('QUANTITY_OF_COMP_LAY_ITEM').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('QUANTITY_OF_COMP_LAY_ITEM').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('QUANTITY_OF_COMP_LAY_ITEM').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.GENERIC_INGREDIENT IS NOT NULL THEN
      IF l_single_row_attrs.GENERIC_INGREDIENT = G_MISS_CHAR THEN
        l_single_row_attrs.GENERIC_INGREDIENT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for GENERIC_INGREDIENT - '||l_single_row_attrs.GENERIC_INGREDIENT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('GENERIC_INGREDIENT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('GENERIC_INGREDIENT').ATTR_NAME,
                                                                 l_single_row_attrs.GENERIC_INGREDIENT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('GENERIC_INGREDIENT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.GENERIC_INGREDIENT_STRGTH IS NOT NULL THEN
      IF l_single_row_attrs.GENERIC_INGREDIENT_STRGTH = G_MISS_NUM THEN
        l_single_row_attrs.GENERIC_INGREDIENT_STRGTH := NULL;
      END IF;
      IF l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for GENERIC_INGREDIENT_STRGTH - '||l_single_row_attrs.GENERIC_INGREDIENT_STRGTH);
      Debug_Msg('Creating Attribute Data Object for UOM_GENERIC_INGREDIENT_STRGTH - '||l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('GENERIC_INGREDIENT_STRGTH').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('GENERIC_INGREDIENT_STRGTH').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.GENERIC_INGREDIENT_STRGTH,
                                                                 NULL, NULL, l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('GENERIC_INGREDIENT_STRGTH').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.INGREDIENT_STRENGTH IS NOT NULL THEN
      IF l_single_row_attrs.INGREDIENT_STRENGTH = G_MISS_CHAR THEN
        l_single_row_attrs.INGREDIENT_STRENGTH := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for INGREDIENT_STRENGTH - '||l_single_row_attrs.INGREDIENT_STRENGTH);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('INGREDIENT_STRENGTH').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('INGREDIENT_STRENGTH').ATTR_NAME,
                                                                 l_single_row_attrs.INGREDIENT_STRENGTH,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('INGREDIENT_STRENGTH').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.EFFECTIVE_START_DATE IS NOT NULL THEN
      IF l_single_row_attrs.EFFECTIVE_START_DATE = G_MISS_DATE THEN
        l_single_row_attrs.EFFECTIVE_START_DATE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for EFFECTIVE_START_DATE - '||l_single_row_attrs.EFFECTIVE_START_DATE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('EFFECTIVE_START_DATE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('EFFECTIVE_START_DATE').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.EFFECTIVE_START_DATE,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('EFFECTIVE_START_DATE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.CATALOG_PRICE IS NOT NULL THEN
      IF l_single_row_attrs.CATALOG_PRICE = G_MISS_NUM THEN
        l_single_row_attrs.CATALOG_PRICE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for CATALOG_PRICE - '||l_single_row_attrs.CATALOG_PRICE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('CATALOG_PRICE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('CATALOG_PRICE').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.CATALOG_PRICE,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('CATALOG_PRICE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.START_AVAILABILITY_DATE_TIME IS NOT NULL THEN
      IF l_single_row_attrs.START_AVAILABILITY_DATE_TIME = G_MISS_DATE THEN
        l_single_row_attrs.START_AVAILABILITY_DATE_TIME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for START_AVAILABILITY_DATE_TIME - '||l_single_row_attrs.START_AVAILABILITY_DATE_TIME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('START_AVAILABILITY_DATE_TIME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('START_AVAILABILITY_DATE_TIME').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.START_AVAILABILITY_DATE_TIME,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('START_AVAILABILITY_DATE_TIME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME IS NOT NULL THEN
      IF l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME = G_MISS_DATE THEN
        l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for CONSUMER_AVAIL_DATE_TIME - '||l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('CONSUMER_AVAIL_DATE_TIME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('CONSUMER_AVAIL_DATE_TIME').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('CONSUMER_AVAIL_DATE_TIME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ORDERING_LEAD_TIME IS NOT NULL THEN
      IF l_single_row_attrs.ORDERING_LEAD_TIME = G_MISS_NUM THEN
        l_single_row_attrs.ORDERING_LEAD_TIME := NULL;
      END IF;
      IF l_single_row_attrs.UOM_ORDERING_LEAD_TIME = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_ORDERING_LEAD_TIME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ORDERING_LEAD_TIME - '||l_single_row_attrs.ORDERING_LEAD_TIME);
      Debug_Msg('Creating Attribute Data Object for UOM_ORDERING_LEAD_TIME - '||l_single_row_attrs.UOM_ORDERING_LEAD_TIME);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ORDERING_LEAD_TIME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ORDERING_LEAD_TIME').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.ORDERING_LEAD_TIME,
                                                                 NULL, NULL, l_single_row_attrs.UOM_ORDERING_LEAD_TIME, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ORDERING_LEAD_TIME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ORDER_QUANTITY_MAX IS NOT NULL THEN
      IF l_single_row_attrs.ORDER_QUANTITY_MAX = G_MISS_NUM THEN
        l_single_row_attrs.ORDER_QUANTITY_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ORDER_QUANTITY_MAX - '||l_single_row_attrs.ORDER_QUANTITY_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ORDER_QUANTITY_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ORDER_QUANTITY_MAX').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.ORDER_QUANTITY_MAX,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ORDER_QUANTITY_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO IS NOT NULL THEN
      IF l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO = G_MISS_CHAR THEN
        l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for MATERIAL_SAFETY_DATA_SHEET_NO - '||l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('MATERIAL_SAFETY_DATA_SHEET_NO').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('MATERIAL_SAFETY_DATA_SHEET_NO').ATTR_NAME,
                                                                 l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('MATERIAL_SAFETY_DATA_SHEET_NO').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.EFFECTIVE_DATE IS NOT NULL THEN
      IF l_single_row_attrs.EFFECTIVE_DATE = G_MISS_DATE THEN
        l_single_row_attrs.EFFECTIVE_DATE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for EFFECTIVE_DATE - '||l_single_row_attrs.EFFECTIVE_DATE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('EFFECTIVE_DATE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('EFFECTIVE_DATE').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.EFFECTIVE_DATE,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('EFFECTIVE_DATE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.END_AVAILABILITY_DATE_TIME IS NOT NULL THEN
      IF l_single_row_attrs.END_AVAILABILITY_DATE_TIME = G_MISS_DATE THEN
        l_single_row_attrs.END_AVAILABILITY_DATE_TIME := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for END_AVAILABILITY_DATE_TIME - '||l_single_row_attrs.END_AVAILABILITY_DATE_TIME);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('END_AVAILABILITY_DATE_TIME').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('END_AVAILABILITY_DATE_TIME').ATTR_NAME,
                                                                 NULL, NULL,
                                                                 l_single_row_attrs.END_AVAILABILITY_DATE_TIME,
                                                                 NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('END_AVAILABILITY_DATE_TIME').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ORDER_QUANTITY_MIN IS NOT NULL THEN
      IF l_single_row_attrs.ORDER_QUANTITY_MIN = G_MISS_NUM THEN
        l_single_row_attrs.ORDER_QUANTITY_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ORDER_QUANTITY_MIN - '||l_single_row_attrs.ORDER_QUANTITY_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ORDER_QUANTITY_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ORDER_QUANTITY_MIN').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.ORDER_QUANTITY_MIN,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ORDER_QUANTITY_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ORDER_SIZING_FACTOR IS NOT NULL THEN
      IF l_single_row_attrs.ORDER_SIZING_FACTOR = G_MISS_NUM THEN
        l_single_row_attrs.ORDER_SIZING_FACTOR := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ORDER_SIZING_FACTOR - '||l_single_row_attrs.ORDER_SIZING_FACTOR);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ORDER_SIZING_FACTOR').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ORDER_SIZING_FACTOR').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.ORDER_SIZING_FACTOR,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ORDER_SIZING_FACTOR').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ORDER_QUANTITY_MULTIPLE IS NOT NULL THEN
      IF l_single_row_attrs.ORDER_QUANTITY_MULTIPLE = G_MISS_NUM THEN
        l_single_row_attrs.ORDER_QUANTITY_MULTIPLE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ORDER_QUANTITY_MULTIPLE - '||l_single_row_attrs.ORDER_QUANTITY_MULTIPLE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ORDER_QUANTITY_MULTIPLE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ORDER_QUANTITY_MULTIPLE').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.ORDER_QUANTITY_MULTIPLE,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ORDER_QUANTITY_MULTIPLE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DESCRIPTIVE_SIZE IS NOT NULL THEN
      IF l_single_row_attrs.DESCRIPTIVE_SIZE = G_MISS_CHAR THEN
        l_single_row_attrs.DESCRIPTIVE_SIZE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DESCRIPTIVE_SIZE - '||l_single_row_attrs.DESCRIPTIVE_SIZE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DESCRIPTIVE_SIZE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DESCRIPTIVE_SIZE').ATTR_NAME,
                                                                 l_single_row_attrs.DESCRIPTIVE_SIZE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DESCRIPTIVE_SIZE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT IS NOT NULL THEN
      IF l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT = G_MISS_CHAR THEN
        l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DEGREE_OF_ORIGINAL_WORT - '||l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DEGREE_OF_ORIGINAL_WORT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DEGREE_OF_ORIGINAL_WORT').ATTR_NAME,
                                                                 l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DEGREE_OF_ORIGINAL_WORT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.SECURITY_TAG_LOCATION IS NOT NULL THEN
      IF l_single_row_attrs.SECURITY_TAG_LOCATION = G_MISS_CHAR THEN
        l_single_row_attrs.SECURITY_TAG_LOCATION := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for SECURITY_TAG_LOCATION - '||l_single_row_attrs.SECURITY_TAG_LOCATION);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('SECURITY_TAG_LOCATION').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('SECURITY_TAG_LOCATION').ATTR_NAME,
                                                                 l_single_row_attrs.SECURITY_TAG_LOCATION,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('SECURITY_TAG_LOCATION').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.PIECES_PER_TRADE_ITEM IS NOT NULL THEN
      IF l_single_row_attrs.PIECES_PER_TRADE_ITEM = G_MISS_NUM THEN
        l_single_row_attrs.PIECES_PER_TRADE_ITEM := NULL;
      END IF;
      IF l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for PIECES_PER_TRADE_ITEM - '||l_single_row_attrs.PIECES_PER_TRADE_ITEM);
      Debug_Msg('Creating Attribute Data Object for UOM_PIECES_PER_TRADE_ITEM - '||l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('PIECES_PER_TRADE_ITEM').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('PIECES_PER_TRADE_ITEM').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.PIECES_PER_TRADE_ITEM,
                                                                 NULL, NULL, l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('PIECES_PER_TRADE_ITEM').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.NESTING_INCREMENT IS NOT NULL THEN
      IF l_single_row_attrs.NESTING_INCREMENT = G_MISS_NUM THEN
        l_single_row_attrs.NESTING_INCREMENT := NULL;
      END IF;
      IF l_single_row_attrs.UOM_NESTING_INCREMENT = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_NESTING_INCREMENT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for NESTING_INCREMENT - '||l_single_row_attrs.NESTING_INCREMENT);
      Debug_Msg('Creating Attribute Data Object for UOM_NESTING_INCREMENT - '||l_single_row_attrs.UOM_NESTING_INCREMENT);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('NESTING_INCREMENT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('NESTING_INCREMENT').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.NESTING_INCREMENT,
                                                                 NULL, NULL, l_single_row_attrs.UOM_NESTING_INCREMENT, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('NESTING_INCREMENT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED IS NOT NULL THEN
      IF l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_OUT_OF_BOX_PROVIDED - '||l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_OUT_OF_BOX_PROVIDED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_OUT_OF_BOX_PROVIDED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_OUT_OF_BOX_PROVIDED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.URL_FOR_WARRANTY IS NOT NULL THEN
      IF l_single_row_attrs.URL_FOR_WARRANTY = G_MISS_CHAR THEN
        l_single_row_attrs.URL_FOR_WARRANTY := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for URL_FOR_WARRANTY - '||l_single_row_attrs.URL_FOR_WARRANTY);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('URL_FOR_WARRANTY').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('URL_FOR_WARRANTY').ATTR_NAME,
                                                                 l_single_row_attrs.URL_FOR_WARRANTY,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('URL_FOR_WARRANTY').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.WARRANTY_DESCRIPTION IS NOT NULL THEN
      IF l_single_row_attrs.WARRANTY_DESCRIPTION = G_MISS_CHAR THEN
        l_single_row_attrs.WARRANTY_DESCRIPTION := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for WARRANTY_DESCRIPTION - '||l_single_row_attrs.WARRANTY_DESCRIPTION);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('WARRANTY_DESCRIPTION').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('WARRANTY_DESCRIPTION').ATTR_NAME,
                                                                 l_single_row_attrs.WARRANTY_DESCRIPTION,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('WARRANTY_DESCRIPTION').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION IS NOT NULL THEN
      IF l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION = G_MISS_CHAR THEN
        l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for TRADE_ITEM_FINISH_DESCRIPTION - '||l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('TRADE_ITEM_FINISH_DESCRIPTION').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('TRADE_ITEM_FINISH_DESCRIPTION').ATTR_NAME,
                                                                 l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('TRADE_ITEM_FINISH_DESCRIPTION').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.STACKING_WEIGHT_MAXIMUM IS NOT NULL THEN
      IF l_single_row_attrs.STACKING_WEIGHT_MAXIMUM = G_MISS_NUM THEN
        l_single_row_attrs.STACKING_WEIGHT_MAXIMUM := NULL;
      END IF;
      IF l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for STACKING_WEIGHT_MAXIMUM - '||l_single_row_attrs.STACKING_WEIGHT_MAXIMUM);
      Debug_Msg('Creating Attribute Data Object for UOM_STACKING_WEIGHT_MAXIMUM - '||l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM);

      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('STACKING_WEIGHT_MAXIMUM').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('STACKING_WEIGHT_MAXIMUM').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.STACKING_WEIGHT_MAXIMUM,
                                                                 NULL, NULL, l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('STACKING_WEIGHT_MAXIMUM').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE IS NOT NULL THEN
      IF l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE = G_MISS_CHAR THEN
        l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_PACK_MARKED_WITH_EXP_DATE - '||l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_EXP_DATE').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_EXP_DATE').ATTR_NAME,
                                                                 l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_EXP_DATE').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT IS NOT NULL THEN
      IF l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT = G_MISS_CHAR THEN
        l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_PACK_MARKED_WITH_GREEN_DOT - '||l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_GREEN_DOT').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_GREEN_DOT').ATTR_NAME,
                                                                 l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_GREEN_DOT').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED IS NOT NULL THEN
      IF l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_PACK_MARKED_WITH_INGRED - '||l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_INGRED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_INGRED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_PACK_MARKED_WITH_INGRED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC IS NOT NULL THEN
      IF l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC = G_MISS_CHAR THEN
        l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_PACKAGE_MARKED_AS_REC - '||l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_PACKAGE_MARKED_AS_REC').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_PACKAGE_MARKED_AS_REC').ATTR_NAME,
                                                                 l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_PACKAGE_MARKED_AS_REC').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_PACKAGE_MARKED_RET IS NOT NULL THEN
      IF l_single_row_attrs.IS_PACKAGE_MARKED_RET = G_MISS_CHAR THEN
        l_single_row_attrs.IS_PACKAGE_MARKED_RET := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_PACKAGE_MARKED_RET - '||l_single_row_attrs.IS_PACKAGE_MARKED_RET);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_PACKAGE_MARKED_RET').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_PACKAGE_MARKED_RET').ATTR_NAME,
                                                                 l_single_row_attrs.IS_PACKAGE_MARKED_RET,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_PACKAGE_MARKED_RET').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER IS NOT NULL THEN
      IF l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER = G_MISS_NUM THEN
        l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for FAT_PERCENT_IN_DRY_MATTER - '||l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('FAT_PERCENT_IN_DRY_MATTER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('FAT_PERCENT_IN_DRY_MATTER').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('FAT_PERCENT_IN_DRY_MATTER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN = G_MISS_NUM THEN
        l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DEL_TO_DIST_CNTR_TEMP_MIN - '||l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_DEL_TO_DIST_CNTR_TEMP_MIN - '||l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX = G_MISS_NUM THEN
        l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DEL_TO_DIST_CNTR_TEMP_MAX - '||l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_DEL_TO_DIST_CNTR_TEMP_MAX - '||l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_DEL_TO_DIST_CNTR_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN = G_MISS_NUM THEN
        l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DELIVERY_TO_MRKT_TEMP_MIN - '||l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MIN').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_DELIVERY_TO_MRKT_TEMP_MIN - '||l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MIN').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX = G_MISS_NUM THEN
        l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for DELIVERY_TO_MRKT_TEMP_MAX - '||l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MAX').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('DELIVERY_TO_MRKT_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_DELIVERY_TO_MRKT_TEMP_MAX - '||l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MAX').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_DELIVERY_TO_MRKT_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN = G_MISS_NUM THEN
        l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for STORAGE_HANDLING_TEMP_MIN - '||l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MIN').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN IS NOT NULL THEN
      IF l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_STORAGE_HANDLING_TEMP_MIN - '||l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MIN').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MIN').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MIN').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX = G_MISS_NUM THEN
        l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for STORAGE_HANDLING_TEMP_MAX - '||l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MAX').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('STORAGE_HANDLING_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX IS NOT NULL THEN
      IF l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX = G_MISS_CHAR THEN
        l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for UOM_STORAGE_HANDLING_TEMP_MAX - '||l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MAX').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MAX').ATTR_NAME,
                                                                 l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('UOM_STORAGE_HANDLING_TEMP_MAX').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM IS NOT NULL THEN
      IF l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM = G_MISS_NUM THEN
        l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for RETAIL_PRICE_ON_TRADE_ITEM - '||l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('RETAIL_PRICE_ON_TRADE_ITEM').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('RETAIL_PRICE_ON_TRADE_ITEM').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('RETAIL_PRICE_ON_TRADE_ITEM').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL IS NOT NULL THEN
      IF l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL = G_MISS_NUM THEN
        l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for PERCENT_OF_ALCOHOL_BY_VOL - '||l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('PERCENT_OF_ALCOHOL_BY_VOL').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('PERCENT_OF_ALCOHOL_BY_VOL').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('PERCENT_OF_ALCOHOL_BY_VOL').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ISBN_NUMBER IS NOT NULL THEN
      IF l_single_row_attrs.ISBN_NUMBER = G_MISS_CHAR THEN
        l_single_row_attrs.ISBN_NUMBER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ISBN_NUMBER - '||l_single_row_attrs.ISBN_NUMBER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ISBN_NUMBER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ISBN_NUMBER').ATTR_NAME,
                                                                 l_single_row_attrs.ISBN_NUMBER,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ISBN_NUMBER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.ISSN_NUMBER IS NOT NULL THEN
      IF l_single_row_attrs.ISSN_NUMBER = G_MISS_CHAR THEN
        l_single_row_attrs.ISSN_NUMBER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for ISSN_NUMBER - '||l_single_row_attrs.ISSN_NUMBER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('ISSN_NUMBER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('ISSN_NUMBER').ATTR_NAME,
                                                                 l_single_row_attrs.ISSN_NUMBER,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('ISSN_NUMBER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_INGREDIENT_IRRADIATED IS NOT NULL THEN
      IF l_single_row_attrs.IS_INGREDIENT_IRRADIATED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_INGREDIENT_IRRADIATED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_INGREDIENT_IRRADIATED - '||l_single_row_attrs.IS_INGREDIENT_IRRADIATED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_INGREDIENT_IRRADIATED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_INGREDIENT_IRRADIATED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_INGREDIENT_IRRADIATED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_INGREDIENT_IRRADIATED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED IS NOT NULL THEN
      IF l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_RAW_MATERIAL_IRRADIATED - '||l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_RAW_MATERIAL_IRRADIATED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_RAW_MATERIAL_IRRADIATED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_RAW_MATERIAL_IRRADIATED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_GENETICALLY_MOD - '||l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_GENETICALLY_MOD').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_GENETICALLY_MOD').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_GENETICALLY_MOD').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_IRRADIATED - '||l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_IRRADIATED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_IRRADIATED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_IRRADIATED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_RECALLED IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_RECALLED = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_RECALLED := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_RECALLED - '||l_single_row_attrs.IS_TRADE_ITEM_RECALLED);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_RECALLED').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_RECALLED').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_RECALLED,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_RECALLED').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.MODEL_NUMBER IS NOT NULL THEN
      IF l_single_row_attrs.MODEL_NUMBER = G_MISS_CHAR THEN
        l_single_row_attrs.MODEL_NUMBER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for MODEL_NUMBER - '||l_single_row_attrs.MODEL_NUMBER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('MODEL_NUMBER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('MODEL_NUMBER').ATTR_NAME,
                                                                 l_single_row_attrs.MODEL_NUMBER,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('MODEL_NUMBER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER IS NOT NULL THEN
      IF l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER = G_MISS_NUM THEN
        l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for QUANITY_OF_ITEM_IN_LAYER - '||l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('QUANITY_OF_ITEM_IN_LAYER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('QUANITY_OF_ITEM_IN_LAYER').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('QUANITY_OF_ITEM_IN_LAYER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK IS NOT NULL THEN
      IF l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK = G_MISS_NUM THEN
        l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for QUANTITY_OF_ITEM_INNER_PACK - '||l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('QUANTITY_OF_ITEM_INNER_PACK').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('QUANTITY_OF_ITEM_INNER_PACK').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('QUANTITY_OF_ITEM_INNER_PACK').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.QUANTITY_OF_INNER_PACK IS NOT NULL THEN
      IF l_single_row_attrs.QUANTITY_OF_INNER_PACK = G_MISS_NUM THEN
        l_single_row_attrs.QUANTITY_OF_INNER_PACK := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for QUANTITY_OF_INNER_PACK - '||l_single_row_attrs.QUANTITY_OF_INNER_PACK);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('QUANTITY_OF_INNER_PACK').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('QUANTITY_OF_INNER_PACK').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.QUANTITY_OF_INNER_PACK,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('QUANTITY_OF_INNER_PACK').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.HAS_BATCH_NUMBER IS NOT NULL THEN
      IF l_single_row_attrs.HAS_BATCH_NUMBER = G_MISS_CHAR THEN
        l_single_row_attrs.HAS_BATCH_NUMBER := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for HAS_BATCH_NUMBER - '||l_single_row_attrs.HAS_BATCH_NUMBER);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('HAS_BATCH_NUMBER').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('HAS_BATCH_NUMBER').ATTR_NAME,
                                                                 l_single_row_attrs.HAS_BATCH_NUMBER,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('HAS_BATCH_NUMBER').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG IS NOT NULL THEN
      IF l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG = G_MISS_CHAR THEN
        l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_NON_SOLD_TRADE_RET_FLAG - '||l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_NON_SOLD_TRADE_RET_FLAG').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_NON_SOLD_TRADE_RET_FLAG').ATTR_NAME,
                                                                 l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_NON_SOLD_TRADE_RET_FLAG').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG IS NOT NULL THEN
      IF l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG = G_MISS_CHAR THEN
        l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for IS_TRADE_ITEM_MAR_REC_FLAG - '||l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('IS_TRADE_ITEM_MAR_REC_FLAG').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('IS_TRADE_ITEM_MAR_REC_FLAG').ATTR_NAME,
                                                                 l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG,
                                                                 NULL, NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('IS_TRADE_ITEM_MAR_REC_FLAG').ATTR_NAME;
    END IF;

    IF l_single_row_attrs.STACKING_FACTOR IS NOT NULL THEN
      IF l_single_row_attrs.STACKING_FACTOR = G_MISS_NUM THEN
        l_single_row_attrs.STACKING_FACTOR := NULL;
      END IF;
      Debug_Msg('Creating Attribute Data Object for STACKING_FACTOR - '||l_single_row_attrs.STACKING_FACTOR);
      l_row_identifier := Create_Attrs_Row_Table('EGO_ITEM_GTIN_ATTRS',
                                                  l_single_row_attrs_metadata('STACKING_FACTOR').ATTR_GROUP_NAME,
                                                  FALSE);
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                 l_row_identifier,
                                                                 l_single_row_attrs_metadata('STACKING_FACTOR').ATTR_NAME,
                                                                 NULL,
                                                                 l_single_row_attrs.STACKING_FACTOR,
                                                                 NULL, NULL, NULL, NULL);
      l_attribute_names.EXTEND;
      l_attribute_names(l_attribute_names.COUNT) := l_single_row_attrs_metadata('STACKING_FACTOR').ATTR_NAME;
    END IF;

    Debug_Msg('Calling EGO_ITEM_PUB.Process_User_Attrs_For_Item');
    EGO_ITEM_PVT.Process_User_Attrs_For_Item(
        p_api_version                   => 1.0
       ,p_inventory_item_id             => p_inventory_item_id
       ,p_organization_id               => p_organization_id
       ,p_attributes_row_table          => l_attributes_row_table
       ,p_attributes_data_table         => l_attributes_data_table
       ,p_do_policy_check               => p_check_policy
       ,p_validate_hierarchy            => FND_API.G_FALSE
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_init_error_handler            => p_init_error_handler
       ,p_init_fnd_msg_list             => FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
       ,p_commit                        => FND_API.G_FALSE
       ,x_failed_row_id_list            => l_failed_row_id_list
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data);

    Debug_Msg('Finished EGO_ITEM_PVT.Process_User_Attrs_For_Item with status - '||l_return_status);

    IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      FOR cnt IN 1..l_msg_count LOOP
        Debug_Msg('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));
      END LOOP;
      Debug_Msg('Error msg - '|| l_msg_data);
    ELSIF l_return_status = 'S' THEN
      Debug_Msg('Singe Row Attributes (and deletion of multi-row attributes) processing is successful');
      Debug_Msg('Processing multi row attributes');
      IF l_multi_row_attrs.FIRST IS NOT NULL THEN
        Debug_Msg('Multi row attributes EXIST');
        l_index := l_multi_row_attrs.FIRST;
        WHILE l_index IS NOT NULL LOOP
          Debug_Msg('Processing row# - '||l_index);
          -- processing attribute group - Manufacturing_Info
          IF l_multi_row_attrs(l_index).MANUFACTURER_ID IS NOT NULL OR l_multi_row_attrs(l_index).MANUFACTURER_GLN IS NOT NULL
          THEN
            l_attributes_data_table.DELETE;
            IF l_multi_row_attrs(l_index).MANUFACTURER_ID IS NOT NULL
            THEN
              Debug_Msg('Creating Attribute Data Object for MANUFACTURER_ID - '||l_multi_row_attrs(l_index).MANUFACTURER_ID);
              IF l_multi_row_attrs(l_index).MANUFACTURER_ID = G_MISS_NUM THEN
                l_multi_row_attrs(l_index).MANUFACTURER_ID := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('MANUFACTURER_ID').ATTR_NAME,
                                                                         NULL,
                                                                         l_multi_row_attrs(l_index).MANUFACTURER_ID,
                                                                         NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('MANUFACTURER_ID').ATTR_NAME;
            END IF;

            IF l_multi_row_attrs(l_index).MANUFACTURER_GLN IS NOT NULL
            THEN
              Debug_Msg('Creating Attribute Data Object for MANUFACTURER_GLN - '||l_multi_row_attrs(l_index).MANUFACTURER_GLN);
              IF l_multi_row_attrs(l_index).MANUFACTURER_GLN = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).MANUFACTURER_GLN := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('MANUFACTURER_GLN').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).MANUFACTURER_GLN,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('MANUFACTURER_GLN').ATTR_NAME;
            END IF;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('MANUFACTURER_ID').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).MANUFACTURER_ID IS NOT NULL OR

          -- processing attribute group - Country_Of_Origin
          IF l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN IS NOT NULL THEN
            Debug_Msg('Creating Attribute Data Object for COUNTRY_OF_ORIGIN - '||l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN);
            IF l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN = G_MISS_CHAR THEN
              l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN := NULL;
            END IF;

            l_attributes_data_table.DELETE;
            l_attributes_data_table.EXTEND;
            l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                       1,
                                                                       l_multi_row_attrs_metadata('COUNTRY_OF_ORIGIN').ATTR_NAME,
                                                                       l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN,
                                                                       NULL, NULL, NULL, NULL, NULL);
            l_attribute_names.EXTEND;
            l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('COUNTRY_OF_ORIGIN').ATTR_NAME;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('COUNTRY_OF_ORIGIN').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).COUNTRY_OF_ORIGIN IS NOT NULL THEN

          -- processing attribute group - TRADE_ITEM_HARMN_SYS_IDENT
          IF l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE IS NOT NULL THEN
            Debug_Msg('Creating Attribute Data Object for HARMONIZED_TARIFF_SYS_ID_CODE - '||l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE);
            IF l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE = G_MISS_NUM THEN
              l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE := NULL;
            END IF;

            l_attributes_data_table.DELETE;
            l_attributes_data_table.EXTEND;
            l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                       1,
                                                                       l_multi_row_attrs_metadata('HARMONIZED_TARIFF_SYS_ID_CODE').ATTR_NAME,
                                                                       NULL,
                                                                       l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE,
                                                                       NULL, NULL, NULL, NULL);
            l_attribute_names.EXTEND;
            l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('HARMONIZED_TARIFF_SYS_ID_CODE').ATTR_NAME;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('HARMONIZED_TARIFF_SYS_ID_CODE').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).HARMONIZED_TARIFF_SYS_ID_CODE IS NOT NULL THEN

          -- processing attribute group - Size_Description
          IF l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY IS NOT NULL OR l_multi_row_attrs(l_index).SIZE_CODE_VALUE IS NOT NULL
          THEN
            l_attributes_data_table.DELETE;
            IF l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for SIZE_CODE_LIST_AGENCY - '||l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY);
              IF l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY := NULL;
              END IF;

              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('SIZE_CODE_LIST_AGENCY').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('SIZE_CODE_LIST_AGENCY').ATTR_NAME;
            END IF; -- IF l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).SIZE_CODE_VALUE IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for SIZE_CODE_VALUE - '||l_multi_row_attrs(l_index).SIZE_CODE_VALUE);
              IF l_multi_row_attrs(l_index).SIZE_CODE_VALUE = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).SIZE_CODE_VALUE := NULL;
              END IF;

              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('SIZE_CODE_VALUE').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).SIZE_CODE_VALUE,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('SIZE_CODE_VALUE').ATTR_NAME;
            END IF; -- IF l_multi_row_attrs(l_index).SIZE_CODE_VALUE IS NOT NULL THEN

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('SIZE_CODE_VALUE').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).SIZE_CODE_LIST_AGENCY IS NOT NULL OR l_

          -- processing attribute group - Delivery_Method_Indicator
          IF l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR IS NOT NULL THEN
            Debug_Msg('Creating Attribute Data Object for DELIVERY_METHOD_INDICATOR - '||l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR);
            IF l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR = G_MISS_CHAR THEN
              l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR := NULL;
            END IF;

            l_attributes_data_table.DELETE;
            l_attributes_data_table.EXTEND;
            l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                       1,
                                                                       l_multi_row_attrs_metadata('DELIVERY_METHOD_INDICATOR').ATTR_NAME,
                                                                       l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR,
                                                                       NULL, NULL, NULL, NULL, NULL);
            l_attribute_names.EXTEND;
            l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DELIVERY_METHOD_INDICATOR').ATTR_NAME;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('DELIVERY_METHOD_INDICATOR').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).DELIVERY_METHOD_INDICATOR IS NOT NULL THEN

          -- processing attribute group - Handling_Information
          IF l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE IS NOT NULL THEN
            Debug_Msg('Creating Attribute Data Object for HANDLING_INSTRUCTIONS_CODE - '||l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE);
            IF l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE = G_MISS_CHAR THEN
              l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE := NULL;
            END IF;

            l_attributes_data_table.DELETE;
            l_attributes_data_table.EXTEND;
            l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                       1,
                                                                       l_multi_row_attrs_metadata('HANDLING_INSTRUCTIONS_CODE').ATTR_NAME,
                                                                       l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE,
                                                                       NULL, NULL, NULL, NULL, NULL);
            l_attribute_names.EXTEND;
            l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('HANDLING_INSTRUCTIONS_CODE').ATTR_NAME;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('HANDLING_INSTRUCTIONS_CODE').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; -- IF l_multi_row_attrs(l_index).HANDLING_INSTRUCTIONS_CODE IS NOT NULL THEN

          -- processing attribute group - Hazardous_Information
          IF l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME IS NOT NULL OR
             l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME IS NOT NULL OR
             l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO IS NOT NULL OR
             l_multi_row_attrs(l_index).FLASH_POINT_TEMP IS NOT NULL OR
             l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP IS NOT NULL
          THEN
            l_attributes_data_table.DELETE;
            IF l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for CLASS_OF_DANGEROUS_CODE - '||l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE);
              IF l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE := NULL;
              END IF;

              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('CLASS_OF_DANGEROUS_CODE').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('CLASS_OF_DANGEROUS_CODE').ATTR_NAME;
            END IF; -- IF l_multi_row_attrs(l_index).CLASS_OF_DANGEROUS_CODE IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_MARGIN_NUMBER - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER := NULL;
              END IF;

              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_MARGIN_NUMBER').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_MARGIN_NUMBER').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_MARGIN_NUMBER IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_HAZARDOUS_CODE - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE := NULL;
              END IF;

              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_HAZARDOUS_CODE').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_HAZARDOUS_CODE').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_HAZARDOUS_CODE IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_PACK_GROUP - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_PACK_GROUP').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_PACK_GROUP').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_PACK_GROUP IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_REG_CODE - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_REG_CODE').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_REG_CODE').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_REG_CODE IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_SHIPPING_NAME - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_SHIPPING_NAME').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_SHIPPING_NAME').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_SHIPPING_NAME IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for DANGEROUS_GOODS_TECHNICAL_NAME - '||l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME);
              IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('DANGEROUS_GOODS_TECHNICAL_NAME').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('DANGEROUS_GOODS_TECHNICAL_NAME').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).DANGEROUS_GOODS_TECHNICAL_NAME IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for UNITED_NATIONS_DANG_GOODS_NO - '||l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO);
              IF l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO = G_MISS_NUM THEN
                l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('UNITED_NATIONS_DANG_GOODS_NO').ATTR_NAME,
                                                                         NULL,
                                                                         l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO,
                                                                         NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('UNITED_NATIONS_DANG_GOODS_NO').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).UNITED_NATIONS_DANG_GOODS_NO IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).FLASH_POINT_TEMP IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for FLASH_POINT_TEMP - '||l_multi_row_attrs(l_index).FLASH_POINT_TEMP);
              IF l_multi_row_attrs(l_index).FLASH_POINT_TEMP = G_MISS_NUM THEN
                l_multi_row_attrs(l_index).FLASH_POINT_TEMP := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('FLASH_POINT_TEMP').ATTR_NAME,
                                                                         NULL,
                                                                         l_multi_row_attrs(l_index).FLASH_POINT_TEMP,
                                                                         NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('FLASH_POINT_TEMP').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).FLASH_POINT_TEMP IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for UOM_FLASH_POINT_TEMP - '||l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP);
              IF l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('UOM_FLASH_POINT_TEMP').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('UOM_FLASH_POINT_TEMP').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).UOM_FLASH_POINT_TEMP IS NOT NULL THEN

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('DANGEROUS_GOODS_TECHNICAL_NAME').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF;

          -- processing attribute group - Bar_Code
          IF l_multi_row_attrs(l_index).BAR_CODE_TYPE IS NOT NULL THEN
            Debug_Msg('Creating Attribute Data Object for BAR_CODE_TYPE - '||l_multi_row_attrs(l_index).BAR_CODE_TYPE);
            IF l_multi_row_attrs(l_index).BAR_CODE_TYPE = G_MISS_CHAR THEN
              l_multi_row_attrs(l_index).BAR_CODE_TYPE := NULL;
            END IF;
            l_attributes_data_table.DELETE;
            l_attributes_data_table.EXTEND;
            l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                       1,
                                                                       l_multi_row_attrs_metadata('BAR_CODE_TYPE').ATTR_NAME,
                                                                       l_multi_row_attrs(l_index).BAR_CODE_TYPE,
                                                                       NULL, NULL, NULL, NULL, NULL);
            l_attribute_names.EXTEND;
            l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('BAR_CODE_TYPE').ATTR_NAME;

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('BAR_CODE_TYPE').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; --IF l_multi_row_attrs(l_index).BAR_CODE_TYPE IS NOT NULL THEN

          -- processing attribute group - Gtin_Color_Description
          IF l_multi_row_attrs(l_index).COLOR_CODE_VALUE IS NOT NULL OR
             l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY IS NOT NULL
          THEN
            l_attributes_data_table.DELETE;
            IF l_multi_row_attrs(l_index).COLOR_CODE_VALUE IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for COLOR_CODE_VALUE - '||l_multi_row_attrs(l_index).COLOR_CODE_VALUE);
              IF l_multi_row_attrs(l_index).COLOR_CODE_VALUE = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).COLOR_CODE_VALUE := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('COLOR_CODE_VALUE').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).COLOR_CODE_VALUE,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('COLOR_CODE_VALUE').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).COLOR_CODE_VALUE IS NOT NULL THEN

            IF l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY IS NOT NULL THEN
              Debug_Msg('Creating Attribute Data Object for COLOR_CODE_LIST_AGENCY - '||l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY);
              IF l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY = G_MISS_CHAR THEN
                l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY := NULL;
              END IF;
              l_attributes_data_table.EXTEND;
              l_attributes_data_table(l_attributes_data_table.COUNT) := EGO_USER_ATTR_DATA_OBJ(
                                                                         1,
                                                                         l_multi_row_attrs_metadata('COLOR_CODE_LIST_AGENCY').ATTR_NAME,
                                                                         l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY,
                                                                         NULL, NULL, NULL, NULL, NULL);
              l_attribute_names.EXTEND;
              l_attribute_names(l_attribute_names.COUNT) := l_multi_row_attrs_metadata('COLOR_CODE_LIST_AGENCY').ATTR_NAME;
            END IF; --IF l_multi_row_attrs(l_index).COLOR_CODE_LIST_AGENCY IS NOT NULL THEN

            -- processing this AG
            Process_Multi_Row_AG(p_attr_group_name              => l_multi_row_attrs_metadata('COLOR_CODE_LIST_AGENCY').ATTR_GROUP_NAME,
                                 p_pk_column_name_value_pairs   => l_pk_column_name_value_pairs,
                                 p_class_code_name_value_pairs  => l_cc_column_name_value_pairs,
                                 p_data_level_name_value_pairs  => l_dl_column_name_value_pairs,
                                 p_extension_id                 => l_multi_row_attrs(l_index).EXTENSION_ID,
                                 p_transaction_type             => l_multi_row_attrs(l_index).TRANSACTION_TYPE,
                                 p_attr_name_value_pairs        => l_attributes_data_table,
                                 x_return_status                => l_return_status,
                                 x_errorcode                    => l_errorcode,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);

            IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RETURN;
            END IF;
          END IF; --IF l_multi_row_attrs(l_index).COLOR_CODE_VALUE IS NOT NULL OR

          l_index := l_multi_row_attrs.NEXT(l_index);
        END LOOP; -- end while
      END IF; -- IF p_multi_row_attrs_table.FIRST IS NOT NULL THEN
      Debug_Msg('Done, Processing multi row attributes');

      IF l_attribute_names.COUNT > 0 THEN
        Debug_Msg('Calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES');
        EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES(
          p_inventory_item_id,
          p_organization_id,
          l_attribute_names,
          FND_API.G_FALSE,
          l_return_status,
          l_msg_count,
          l_msg_data);

        Debug_Msg('Finished Calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES with status='||l_return_status);
        IF l_return_status <> 'S' THEN
          Debug_Msg('Error msg - '|| l_msg_data);
          IF FND_API.To_Boolean(p_init_error_handler) THEN
            ERROR_HANDLER.Initialize;
            ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);
          END IF;
          ERROR_HANDLER.Add_Error_Message
            (
              p_message_text                  => l_msg_text
             ,p_application_id                => 'EGO'
             ,p_message_type                  => FND_API.G_RET_STS_ERROR
             ,p_row_identifier                => p_inventory_item_id
             ,p_entity_id                     => p_entity_id
             ,p_entity_index                  => p_entity_index
             ,p_entity_code                   => p_entity_code
            );
          IF (FND_API.To_Boolean(p_init_error_handler)) THEN
            ERROR_HANDLER.Log_Error
             (p_write_err_to_inttable    => 'Y'
             ,p_write_err_to_debugfile   => ERROR_HANDLER.Get_Debug()
            );
          END IF;
        END IF; -- end IF l_return_status <> 'S' THEN
      END IF; --IF l_attribute_names.COUNT > 0 THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
    END IF; -- IF l_return_status <> 'S

    IF FND_API.To_Boolean(p_commit) THEN
      Debug_Msg('p_commit is TRUE, so commiting');
      COMMIT;
    END IF;

    Debug_Msg('Finished Process_UCCnet_Attrs_For_Item');
  EXCEPTION WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    Debug_Msg('Unexpected Error in Process_UCCnet_Attrs_For_Item - '||x_msg_data);
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END Process_UCCnet_Attrs_For_Item;

END EGO_GTIN_ATTRS_PVT;

/
