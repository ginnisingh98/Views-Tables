--------------------------------------------------------
--  DDL for Package Body EGO_STYLE_SKU_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_STYLE_SKU_ITEM_PVT" AS
/* $Header: EGOSITMB.pls 120.20.12010000.2 2009/06/26 08:45:58 sisankar ship $ */

  G_LOG_TIMESTAMP_FORMAT CONSTANT VARCHAR2( 30 ) := 'dd-mon-yyyy hh:mi:ss.ff';

  g_ego_item_object_id NUMBER;
  g_ego_item_data_level_id NUMBER;

  CURSOR Is_STYLE_SKU_EXIST(l_catalog_group_id NUMBER,
                            l_flag VARCHAR2)
  IS
    SELECT 1
    FROM   mtl_system_items_b
    WHERE  rownum = 1 AND
    style_item_flag = l_flag AND
    item_catalog_group_id IN
                            (SELECT item_catalog_group_id
                             FROM mtl_item_catalog_groups_b
                             CONNECT BY PRIOR item_catalog_group_id = parent_catalog_group_id
                             START WITH item_catalog_group_id = l_catalog_group_id);

  /*
   * This method writes into concurrent program log
   */
  PROCEDURE Debug_Conc_Log( p_message IN VARCHAR2
                          , p_add_timestamp IN BOOLEAN DEFAULT TRUE )
  IS
     l_inv_debug_level  NUMBER := INVPUTLI.get_debug_level;
  BEGIN
    IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info(  ( CASE
                        WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                        ELSE ''
                        END  )
                   ||   p_message );
    END IF;
  END Debug_Conc_Log;

  FUNCTION IsStyle_Item_Exist_For_ICC ( p_item_catalog_group_id IN NUMBER ) RETURN VARCHAR2
  IS
    l_Style_Item_Exist BOOLEAN := FALSE;
    l_Style_Item_Count NUMBER;
  BEGIN

  /*   SELECT COUNT(1)
     INTO l_Style_Item_Count
     FROM MTL_SYSTEM_ITEMS_B
    WHERE STYLE_ITEM_FLAG   = 'Y'
      AND ITEM_CATALOG_GROUP_ID IN
    (  SELECT ITEM_CATALOG_GROUP_ID
      FROM MTL_ITEM_CATALOG_GROUPS_B
   CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
     START WITH ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id
     );
    IF ( l_Style_Item_Count > 0 ) THEN
      l_Style_Item_Exist   := TRUE;
    END IF;
    IF( l_Style_Item_Exist ) THEN
        RETURN FND_API.G_TRUE;
    ELSE
       RETURN FND_API.G_FALSE;
    END IF;  */

    OPEN IS_STYLE_SKU_EXIST(p_item_catalog_group_id, 'Y');
    FETCH IS_STYLE_SKU_EXIST INTO l_Style_Item_Count;
    l_Style_Item_Exist := Is_STYLE_SKU_Exist%FOUND;
    CLOSE IS_STYLE_SKU_EXIST;

    IF( l_Style_Item_Exist ) THEN
      RETURN FND_API.G_TRUE;
    ELSE
      RETURN FND_API.G_FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE IS_STYLE_SKU_EXIST;
      RETURN FND_API.G_FALSE;
  END IsStyle_Item_Exist_For_ICC;

  FUNCTION IsSKU_Item_Exist_For_ICC ( p_item_catalog_group_id IN NUMBER ) RETURN VARCHAR2
  IS
    l_SKU_Item_Exist BOOLEAN := FALSE;
    l_SKU_Item_Count NUMBER;
  BEGIN

   /*SELECT COUNT(1)
     INTO l_SKU_Item_Count
     FROM MTL_SYSTEM_ITEMS_B
    WHERE STYLE_ITEM_FLAG   = 'N'
      AND ITEM_CATALOG_GROUP_ID IN
    (  SELECT ITEM_CATALOG_GROUP_ID
      FROM MTL_ITEM_CATALOG_GROUPS_B
   CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
     START WITH ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id
     );
    IF ( l_SKU_Item_Count       > 0 ) THEN
      l_SKU_Item_Exist         := TRUE;
    END IF;
    IF( l_SKU_Item_Exist ) THEN
        RETURN FND_API.G_TRUE;
    ELSE
       RETURN FND_API.G_FALSE;
    END IF; */

    OPEN IS_STYLE_SKU_EXIST(p_item_catalog_group_id, 'N');
    FETCH IS_STYLE_SKU_EXIST INTO l_SKU_Item_Count;
    l_SKU_Item_Exist  := IS_STYLE_SKU_EXIST%FOUND;
    CLOSE IS_STYLE_SKU_EXIST;

    IF( l_SKU_Item_Exist ) THEN
      RETURN FND_API.G_TRUE;
    ELSE
      RETURN FND_API.G_FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE Is_STYLE_SKU_Exist;
      RETURN FND_API.G_FALSE;
  END IsSKU_Item_Exist_For_ICC;

  PROCEDURE Process_Items
  (
     p_set_process_id                 IN   NUMBER
    ,p_Process_Flag                   IN   NUMBER
    ,p_commit                         IN   VARCHAR2   DEFAULT  G_FALSE
    ,p_Transaction_Type               IN   VARCHAR2   DEFAULT  NULL
    ,p_Template_Id                    IN   NUMBER     DEFAULT  NULL
    ,p_copy_inventory_item_Id         IN   NUMBER     DEFAULT  NULL
    ,p_copy_revision_Id               IN   NUMBER     DEFAULT  NULL
    ,p_inventory_item_id              IN   NUMBER     DEFAULT  NULL
    ,p_organization_id                IN   NUMBER     DEFAULT  NULL
    ,p_description                    IN   VARCHAR2   DEFAULT  NULL
    ,p_long_description               IN   VARCHAR2   DEFAULT  NULL
    ,p_primary_uom_code               IN   VARCHAR2   DEFAULT  NULL
    ,p_primary_unit_of_measure        IN   VARCHAR2   DEFAULT  NULL
    ,p_item_type                      IN   VARCHAR2   DEFAULT  NULL
    ,p_inventory_item_status_code     IN   VARCHAR2   DEFAULT  NULL
    ,p_allowed_units_lookup_code      IN   NUMBER     DEFAULT  NULL
    ,p_item_catalog_group_id          IN   NUMBER     DEFAULT  NULL
    ,p_bom_enabled_flag               IN   VARCHAR2   DEFAULT  NULL
    ,p_eng_item_flag                  IN   VARCHAR2   DEFAULT  NULL
    ,p_weight_uom_code                IN   VARCHAR2   DEFAULT  NULL
    ,p_unit_weight                    IN   NUMBER     DEFAULT  NULL
    ,p_Item_Number                    IN   VARCHAR2   DEFAULT  NULL
    ,p_Style_Item_Flag                IN   VARCHAR2   DEFAULT  NULL
    ,p_Style_Item_Id                  IN   NUMBER     DEFAULT  NULL
    ,p_Style_Item_Number              IN   VARCHAR2   DEFAULT  NULL
    ,p_Gdsn_Outbound_Enabled_Flag     IN   VARCHAR2   DEFAULT  NULL
    ,p_Trade_Item_Descriptor          IN   VARCHAR2   DEFAULT  NULL
  )
  IS
    l_copy_from_organization_id NUMBER;
  BEGIN
    IF (p_copy_inventory_item_Id IS NOT NULL) THEN
      l_copy_from_organization_id := p_organization_id;
    END IF;
    INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
    ( SET_PROCESS_ID,
      PROCESS_FLAG,
      TRANSACTION_TYPE,
      TEMPLATE_ID,
			COPY_ITEM_ID,
      COPY_REVISION_ID,
			INVENTORY_ITEM_ID,
			ORGANIZATION_ID,
      DESCRIPTION,
			LONG_DESCRIPTION,
			PRIMARY_UOM_CODE,
			PRIMARY_UNIT_OF_MEASURE,
			ITEM_TYPE,
      INVENTORY_ITEM_STATUS_CODE,
      ALLOWED_UNITS_LOOKUP_CODE,
      ITEM_CATALOG_GROUP_ID,
			BOM_ENABLED_FLAG,
			ENG_ITEM_FLAG,
      WEIGHT_UOM_CODE,
			UNIT_WEIGHT,
      ITEM_NUMBER,
			STYLE_ITEM_FLAG,
			STYLE_ITEM_ID,
			STYLE_ITEM_NUMBER,
			GDSN_OUTBOUND_ENABLED_FLAG,
			TRADE_ITEM_DESCRIPTOR,
     COPY_ORGANIZATION_ID
    )
    VALUES
    ( p_set_process_id,
	    p_Process_Flag,
	    p_Transaction_Type,
	    p_Template_Id,
	    p_copy_inventory_item_Id ,
	    p_copy_revision_Id,
	    p_inventory_item_id ,
	    p_organization_id,
	    p_description,
	    p_long_description ,
	    p_primary_uom_code,
	    p_primary_unit_of_measure,
	    p_item_type,
	    p_inventory_item_status_code,
	    p_allowed_units_lookup_code,
	    p_item_catalog_group_id,
	    p_bom_enabled_flag,
	    p_eng_item_flag ,
	    p_weight_uom_code ,
	    p_unit_weight ,
	    p_Item_Number,
      p_Style_Item_Flag,
      p_Style_Item_Id,
   	  p_Style_item_number,
      p_Gdsn_Outbound_Enabled_Flag,
      p_Trade_Item_Descriptor,
      l_copy_from_organization_id
    );
  END Process_Items;

  PROCEDURE Process_Items ( p_commit             IN VARCHAR2 DEFAULT G_FALSE
                           ,p_Item_Intf_Data_Tab IN OUT NOCOPY EGO_ITEM_INTF_DATA_TAB
                           ,x_return_status      OUT NOCOPY VARCHAR2
                           ,x_msg_data           OUT NOCOPY VARCHAR2
                           ,x_msg_count          OUT NOCOPY NUMBER )
  IS
    l_set_process_id             NUMBER ;
    l_process_flag               NUMBER ;
    l_transaction_type           VARCHAR2(10) ;
    l_template_id                NUMBER ;
    l_copy_inventory_item_id     NUMBER ;
    l_copy_revision_id           NUMBER ;
    l_inventory_item_id          NUMBER ;
    l_organization_id            NUMBER ;
    l_description                VARCHAR2(240) ;
    l_long_description           VARCHAR2(4000) ;
    l_primary_uom_code           VARCHAR2(3) ;
    l_primary_unit_of_measure    VARCHAR2(25) ;
    l_item_type                  VARCHAR2(30) ;
    l_inventory_item_status_code VARCHAR2(10) ;
    l_allowed_units_lookup_code  NUMBER ;
    l_tracking_quantity_ind      VARCHAR2(30) ;
    l_ont_pricing_qty_source     VARCHAR2(30) ;
    l_secondary_default_ind      VARCHAR2(30) ;
    l_dual_uom_deviation_high    NUMBER ;
    l_dual_uom_deviation_low     NUMBER ;
    l_secondary_uom_code         VARCHAR2(3) ;
    l_lifecycle_id               NUMBER ;
    l_current_phase_id           NUMBER ;
    l_item_catalog_group_id      NUMBER ;
    l_bom_enabled_flag           VARCHAR2(1) ;
    l_eng_item_flag              VARCHAR2(1) ;
    l_weight_uom_code            VARCHAR2(3) ;
    l_unit_weight                NUMBER ;
    l_item_number                VARCHAR2(700) ;
    l_style_item_flag            VARCHAR2(1) ;
    l_style_item_id              NUMBER ;
    l_style_item_number          VARCHAR2(700) ;
    l_gdsn_outbound_enabled_flag VARCHAR2(1) ;
    l_trade_item_descriptor      VARCHAR2(35) ;
    l_transaction_id             NUMBER;
    l_source_system_reference    VARCHAR2(255);
    l_copy_from_organization_id  NUMBER;
    l_org_assignment             VARCHAR2(1);

    CURSOR ITEM_DATA_RECS
    IS
      SELECT A.SET_PROCESS_ID SET_PROCESS_ID ,
        A.PROCESS_FLAG PROCESS_FLAG ,
        A.TRANSACTION_TYPE TRANSACTION_TYPE ,
        A.TEMPLATE_ID TEMPLATE_ID ,
        A.COPY_INVENTORY_ITEM_ID COPY_INVENTORY_ITEM_ID ,
        A.COPY_REVISION_ID COPY_REVISION_ID ,
        A.INVENTORY_ITEM_ID INVENTORY_ITEM_ID ,
        A.ORGANIZATION_ID ORGANIZATION_ID ,
        A.DESCRIPTION DESCRIPTION ,
        A.LONG_DESCRIPTION LONG_DESCRIPTION ,
        A.PRIMARY_UOM_CODE PRIMARY_UOM_CODE ,
        A.PRIMARY_UNIT_OF_MEASURE PRIMARY_UNIT_OF_MEASURE ,
        A.ITEM_TYPE ITEM_TYPE ,
        A.INVENTORY_ITEM_STATUS_CODE INVENTORY_ITEM_STATUS_CODE ,
        A.ALLOWED_UNITS_LOOKUP_CODE ALLOWED_UNITS_LOOKUP_CODE ,
        A.TRACKING_QUANTITY_IND TRACKING_QUANTITY_IND ,
        A.ONT_PRICING_QTY_SOURCE ONT_PRICING_QTY_SOURCE ,
        A.SECONDARY_DEFAULT_IND SECONDARY_DEFAULT_IND ,
        A.DUAL_UOM_DEVIATION_HIGH DUAL_UOM_DEVIATION_HIGH ,
        A.DUAL_UOM_DEVIATION_LOW DUAL_UOM_DEVIATION_LOW ,
        A.SECONDARY_UOM_CODE SECONDARY_UOM_CODE ,
        A.LIFECYCLE_ID LIFECYCLE_ID ,
        A.CURRENT_PHASE_ID CURRENT_PHASE_ID ,
        A.ITEM_CATALOG_GROUP_ID ITEM_CATALOG_GROUP_ID ,
        A.BOM_ENABLED_FLAG BOM_ENABLED_FLAG ,
        A.ENG_ITEM_FLAG ENG_ITEM_FLAG ,
        A.WEIGHT_UOM_CODE WEIGHT_UOM_CODE ,
        A.UNIT_WEIGHT UNIT_WEIGHT ,
        A.ITEM_NUMBER ITEM_NUMBER ,
        A.STYLE_ITEM_FLAG STYLE_ITEM_FLAG ,
        A.STYLE_ITEM_ID STYLE_ITEM_ID ,
        A.GDSN_OUTBOUND_ENABLED_FLAG GDSN_OUTBOUND_ENABLED_FLAG ,
        A.TRADE_ITEM_DESCRIPTOR TRADE_ITEM_DESCRIPTOR ,
        A.TRANSACTION_ID TRANSACTION_ID,
        A.SOURCE_SYSTEM_REFERENCE SOURCE_SYSTEM_REFERENCE
      FROM THE (SELECT CAST( p_Item_Intf_Data_Tab AS EGO_ITEM_INTF_DATA_TAB) FROM DUAL)
        A;
  BEGIN
    FOR item_data_rec IN ITEM_DATA_RECS
    LOOP
      l_set_process_id             := item_data_rec.SET_PROCESS_ID ;
      l_process_flag               := item_data_rec.PROCESS_FLAG ;
      l_transaction_type           := item_data_rec.TRANSACTION_TYPE ;
      l_template_id                := item_data_rec.TEMPLATE_ID ;
      l_copy_inventory_item_id     := item_data_rec.COPY_INVENTORY_ITEM_ID ;
      l_copy_revision_id           := item_data_rec.COPY_REVISION_ID ;
      l_inventory_item_id          := item_data_rec.INVENTORY_ITEM_ID ;
      l_organization_id            := item_data_rec.ORGANIZATION_ID ;
      l_description                := item_data_rec.DESCRIPTION ;
      l_long_description           := item_data_rec.LONG_DESCRIPTION ;
      l_primary_uom_code           := item_data_rec.PRIMARY_UOM_CODE ;
      l_primary_unit_of_measure    := item_data_rec.PRIMARY_UNIT_OF_MEASURE ;
      l_item_type                  := item_data_rec.ITEM_TYPE ;
      l_inventory_item_status_code := item_data_rec.INVENTORY_ITEM_STATUS_CODE ;
      l_allowed_units_lookup_code  := item_data_rec.ALLOWED_UNITS_LOOKUP_CODE ;
      l_tracking_quantity_ind      := item_data_rec.TRACKING_QUANTITY_IND ;
      l_ont_pricing_qty_source     := item_data_rec.ONT_PRICING_QTY_SOURCE ;
      l_secondary_default_ind      := item_data_rec.SECONDARY_DEFAULT_IND ;
      l_dual_uom_deviation_high    := item_data_rec.DUAL_UOM_DEVIATION_HIGH ;
      l_dual_uom_deviation_low     := item_data_rec.DUAL_UOM_DEVIATION_LOW ;
      l_secondary_uom_code         := item_data_rec.SECONDARY_UOM_CODE ;
      l_lifecycle_id               := item_data_rec.LIFECYCLE_ID ;
      l_current_phase_id           := item_data_rec.CURRENT_PHASE_ID ;
      l_item_catalog_group_id      := item_data_rec.ITEM_CATALOG_GROUP_ID ;
      l_bom_enabled_flag           := item_data_rec.BOM_ENABLED_FLAG ;
      l_eng_item_flag              := item_data_rec.ENG_ITEM_FLAG ;
      l_weight_uom_code            := item_data_rec.WEIGHT_UOM_CODE ;
      l_unit_weight                := item_data_rec.UNIT_WEIGHT ;
      l_item_number                := item_data_rec.ITEM_NUMBER ;
      l_style_item_flag            := item_data_rec.STYLE_ITEM_FLAG ;
      l_style_item_id              := item_data_rec.STYLE_ITEM_ID ;
      l_gdsn_outbound_enabled_flag := item_data_rec.GDSN_OUTBOUND_ENABLED_FLAG ;
      l_trade_item_descriptor      := item_data_rec.TRADE_ITEM_DESCRIPTOR ;
      l_transaction_id             := item_data_rec.TRANSACTION_ID ;
      l_source_system_reference    := item_data_rec.SOURCE_SYSTEM_REFERENCE ;

      IF l_copy_inventory_item_id IS NOT NULL THEN
        l_copy_from_organization_id := l_organization_id;
      END IF;

      BEGIN
        SELECT 'Y' INTO l_org_assignment
        FROM MTL_PARAMETERS
        WHERE ORGANIZATION_ID = l_organization_id
          AND ORGANIZATION_ID <> MASTER_ORGANIZATION_ID;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_org_assignment := 'N';
        l_inventory_item_id := NULL;
      END;

      INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
      ( SET_PROCESS_ID ,
        PROCESS_FLAG ,
        TRANSACTION_TYPE ,
        TEMPLATE_ID ,
        COPY_ITEM_ID ,
        COPY_REVISION_ID ,
        INVENTORY_ITEM_ID ,
        ORGANIZATION_ID ,
        DESCRIPTION ,
        LONG_DESCRIPTION ,
        PRIMARY_UOM_CODE ,
        PRIMARY_UNIT_OF_MEASURE ,
        ITEM_TYPE ,
        INVENTORY_ITEM_STATUS_CODE ,
        ALLOWED_UNITS_LOOKUP_CODE ,
        TRACKING_QUANTITY_IND ,
        ONT_PRICING_QTY_SOURCE ,
        SECONDARY_DEFAULT_IND ,
        DUAL_UOM_DEVIATION_HIGH ,
        DUAL_UOM_DEVIATION_LOW ,
        SECONDARY_UOM_CODE ,
        LIFECYCLE_ID ,
        CURRENT_PHASE_ID ,
        ITEM_CATALOG_GROUP_ID ,
        BOM_ENABLED_FLAG ,
        ENG_ITEM_FLAG ,
        WEIGHT_UOM_CODE ,
        UNIT_WEIGHT ,
        ITEM_NUMBER ,
        STYLE_ITEM_FLAG ,
        STYLE_ITEM_ID ,
        GDSN_OUTBOUND_ENABLED_FLAG ,
        TRADE_ITEM_DESCRIPTOR,
        TRANSACTION_ID,
        SOURCE_SYSTEM_REFERENCE,
        SOURCE_SYSTEM_ID,
        COPY_ORGANIZATION_ID
      )
      VALUES
      ( l_set_process_id ,
        l_process_flag ,
        l_transaction_type ,
        l_template_id ,
        l_copy_inventory_item_id ,
        l_copy_revision_id ,
        l_inventory_item_id ,
        l_organization_id ,
        l_description ,
        l_long_description ,
        l_primary_uom_code ,
        l_primary_unit_of_measure ,
        l_item_type ,
        l_inventory_item_status_code ,
        l_allowed_units_lookup_code ,
        l_tracking_quantity_ind ,
        l_ont_pricing_qty_source ,
        l_secondary_default_ind ,
        l_dual_uom_deviation_high ,
        l_dual_uom_deviation_low ,
        l_secondary_uom_code ,
        l_lifecycle_id ,
        l_current_phase_id ,
        l_item_catalog_group_id ,
        l_bom_enabled_flag ,
        l_eng_item_flag ,
        l_weight_uom_code ,
        l_unit_weight ,
        l_item_number ,
        l_style_item_flag ,
        l_style_item_id ,
        l_gdsn_outbound_enabled_flag ,
        l_trade_item_descriptor,
        l_transaction_id,
        l_source_system_reference,
        EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID,
        l_copy_from_organization_id
      );
    END LOOP;
  END Process_Items;

  /*
   * This API validates that the variant attribute combination for the SKU
   * is unique. It also inserts the record if combination does not exists
   * This API sets x_sku_exists as TRUE if combination already exists
   * This API sets x_sku_exists as FALSE if combination is not found
   * This API sets x_var_attrs_missing as TRUE if some variant attribute
   *  values are missing.
   *
   * This API returns 0 if no unexpected errors are there, else
   * returns the SQLCODE
   *
   * This API assumes that INVENTORY_ITEM_ID will be present in the intf table
   */
  FUNCTION Validate_SKU_Variant_Usage( p_intf_row_id          IN ROWID
                                      , x_sku_exists          OUT NOCOPY BOOLEAN
                                      , x_var_attrs_missing   OUT NOCOPY BOOLEAN
                                      , x_err_text            OUT NOCOPY VARCHAR2
                                     )
  RETURN INTEGER IS
    CURSOR c_attr_values(c_batch_id NUMBER, c_item_id NUMBER,  c_org_id NUMBER, c_item_number VARCHAR2,c_category_id NUMBER)
    IS
      SELECT
        AG_EXT.ATTR_GROUP_ID,
        FL_COL.END_USER_COLUMN_NAME,
        ATTR_EXT.ATTR_ID,
        (CASE ATTR_EXT.DATA_TYPE
           WHEN 'C' THEN INTF.ATTR_VALUE_STR
           WHEN 'A' THEN INTF.ATTR_VALUE_STR
           WHEN 'N' THEN To_Char(INTF.ATTR_VALUE_NUM)
           WHEN 'X' THEN To_Char(INTF.ATTR_VALUE_DATE)
           WHEN 'Y' THEN To_Char(INTF.ATTR_VALUE_DATE)
         END) ATTR_VALUE
      FROM
        EGO_FND_DSC_FLX_CTX_EXT AG_EXT,
        EGO_FND_DF_COL_USGS_EXT ATTR_EXT,
        FND_DESCR_FLEX_COLUMN_USAGES FL_COL,
        EGO_ITM_USR_ATTR_INTRFC INTF
      WHERE AG_EXT.APPLICATION_ID = ATTR_EXT.APPLICATION_ID
        AND AG_EXT.DESCRIPTIVE_FLEXFIELD_NAME = ATTR_EXT.DESCRIPTIVE_FLEXFIELD_NAME /* AG_TYPE*/
        AND AG_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE /* AG_NAME*/
        AND ATTR_EXT.APPLICATION_ID = FL_COL.APPLICATION_ID
        AND ATTR_EXT.DESCRIPTIVE_FLEXFIELD_NAME = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME /* AG_TYPE*/
        AND ATTR_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE /* AG_NAME*/
        AND ATTR_EXT.APPLICATION_COLUMN_NAME = FL_COL.APPLICATION_COLUMN_NAME /* DATABASE_COLUMN */
        AND AG_EXT.VARIANT = 'Y'
        AND INTF.ATTR_GROUP_INT_NAME(+) = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
        AND INTF.ATTR_GROUP_TYPE(+) = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
        AND INTF.ATTR_INT_NAME (+) = FL_COL.END_USER_COLUMN_NAME
        AND INTF.DATA_SET_ID (+) = c_batch_id
        AND INTF.PROCESS_STATUS (+) = 2
        AND INTF.INVENTORY_ITEM_ID (+) = c_item_id /* OR INTF.ITEM_NUMBER (+)= c_item_number*/
        AND INTF.ORGANIZATION_ID (+) = c_org_id
        AND AG_EXT.ATTR_GROUP_ID IN (SELECT A.ATTR_GROUP_ID
                                     FROM EGO_OBJ_AG_ASSOCS_B a
                                     WHERE A.CLASSIFICATION_CODE IN (SELECT To_Char(micg.ITEM_CATALOG_GROUP_ID)
                                                                     FROM MTL_ITEM_CATALOG_GROUPS_B micg
                                                                     CONNECT BY PRIOR micg.PARENT_CATALOG_GROUP_ID = micg.ITEM_CATALOG_GROUP_ID
                                                                     START WITH micg.ITEM_CATALOG_GROUP_ID = c_category_id
                                                                    )
                                    )
      ORDER BY ATTR_EXT.ATTR_ID;

    l_sku_item_id    MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE;
    l_style_item_id  MTL_SYSTEM_ITEMS_INTERFACE.STYLE_ITEM_ID%TYPE;
    l_org_id         MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE;
    l_item_number    MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE;
    l_category_id    MTL_SYSTEM_ITEMS_INTERFACE.ITEM_CATALOG_GROUP_ID%TYPE;
    l_batch_id       MTL_SYSTEM_ITEMS_INTERFACE.SET_PROCESS_ID%TYPE;
    l_concat_value   VARCHAR2(32000);
    l_user_id        NUMBER := FND_GLOBAL.USER_ID;
    l_login_id       NUMBER := FND_GLOBAL.LOGIN_ID;
    l_delimeter      EGO_DEFAULT_OPTIONS.OPTION_VALUE%TYPE;
    l_attr_missing   BOOLEAN;
    l_attr_value     EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;
    l_old_attr_id    NUMBER;
  BEGIN
    Debug_Conc_Log('Starting EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage');

    l_delimeter := NVL(EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_SKU_CONCAT_VA_DELIM'), '.');
    SELECT SET_PROCESS_ID, INVENTORY_ITEM_ID, ITEM_NUMBER, ORGANIZATION_ID, ITEM_CATALOG_GROUP_ID, STYLE_ITEM_ID
    INTO l_batch_id, l_sku_item_id, l_item_number, l_org_id, l_category_id, l_style_item_id
    FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE ROWID = p_intf_row_id;

    Debug_Conc_Log('Batch_id, item_id, item_number, org_id, icc_id, style_item_id='||
                    l_batch_id||', '||l_sku_item_id||', '||l_item_number||', '||l_org_id||', '||
                    l_category_id||', '||l_style_item_id);
    l_attr_missing := FALSE;
    FOR i IN c_attr_values(l_batch_id, l_sku_item_id, l_org_id, l_item_number, l_category_id) LOOP
      IF NVL(l_old_attr_id, -1) = i.ATTR_ID THEN
        l_attr_missing := TRUE;
        EXIT;
      ELSE
        l_old_attr_id := i.ATTR_ID;
      END IF;

      IF i.ATTR_VALUE IS NULL THEN
        l_attr_missing := TRUE;
        EXIT;
      ELSE
        l_attr_value := i.ATTR_VALUE;
        IF INSTR(l_attr_value, l_delimeter) > 0 THEN
          l_attr_value := REPLACE(l_attr_value, l_delimeter, '\'||l_delimeter);
        END IF;
        l_concat_value := l_concat_value || l_delimeter || l_attr_value;
      END IF; --IF i.ATTR_VALUE IS NULL THEN
    END LOOP;
    l_concat_value := SUBSTR(l_concat_value, 2);

    Debug_Conc_Log('l_concat_value='||l_concat_value);

    IF l_attr_missing THEN
      Debug_Conc_Log('Some Variant attributes are missing');
      Debug_Conc_Log('Done EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage with Error');
      x_sku_exists := false;
      x_var_attrs_missing := true;
      x_err_text := 'Some Variant attributes are missing';
      RETURN 0;
    END IF;

    BEGIN
      INSERT INTO EGO_SKU_VARIANT_ATTR_USAGES
        (
          ORGANIZATION_ID,
          STYLE_ITEM_ID,
          CONCATENATED_VA_SEGMENTS,
          SKU_ITEM_ID,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY
        )
        VALUES
        (
          l_org_id,
          l_style_item_id,
          l_concat_value,
          l_sku_item_id,
          l_login_id,
          SYSDATE,
          l_user_id,
          SYSDATE,
          l_user_id
        );

      Debug_Conc_Log('Inserted Successfully');
      Debug_Conc_Log('Done EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage with Success');
      x_sku_exists := false;
      x_var_attrs_missing := false;
      x_err_text := NULL;
      RETURN 0;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      Debug_Conc_Log('SKU Already exists');
      Debug_Conc_Log('Done EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage with Error');
      x_sku_exists := true;
      x_var_attrs_missing := false;
      x_err_text := 'SKU Already exists';
      RETURN 0;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      x_sku_exists := true;
      x_var_attrs_missing := true;
      x_err_text := 'Unexpected Error in Validate_SKU_Variant_Usage - ' || SQLERRM;
      Debug_Conc_Log(x_err_text);
      Debug_Conc_Log('Done EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage with Unexpected error');
      RETURN SQLCODE;
  END Validate_SKU_Variant_Usage;

  FUNCTION Default_Style_Variant_Attrs(p_inventory_item_id     IN NUMBER,
				                                   p_item_catalog_group_id IN NUMBER,
                                       x_err_text      OUT NOCOPY VARCHAR2)
  RETURN INTEGER
  IS

    l_user_id        NUMBER := FND_GLOBAL.USER_ID;
    l_login_id       NUMBER := FND_GLOBAL.LOGIN_ID;
    l_sysdate        DATE := sysdate;

  BEGIN
      INSERT INTO ego_style_variant_attr_vs
        ( inventory_item_id,
	       value_set_id,
	       attribute_id,
	       last_update_login,
	       creation_date,
	       created_by
        )
      SELECT p_inventory_item_id,
	            fl_col.flex_value_set_id,
             attr_ext.attr_id,
	            l_login_id,
             l_sysdate,
	            l_user_id
        FROM EGO_FND_DSC_FLX_CTX_EXT AG_EXT,
             EGO_FND_DF_COL_USGS_EXT ATTR_EXT,
             FND_DESCR_FLEX_COLUMN_USAGES FL_COL
       WHERE AG_EXT.APPLICATION_ID = ATTR_EXT.APPLICATION_ID
         AND AG_EXT.DESCRIPTIVE_FLEXFIELD_NAME = ATTR_EXT.DESCRIPTIVE_FLEXFIELD_NAME /* AG_TYPE*/
         AND AG_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE /* AG_NAME*/
         AND ATTR_EXT.APPLICATION_ID = FL_COL.APPLICATION_ID
         AND ATTR_EXT.DESCRIPTIVE_FLEXFIELD_NAME = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME /* AG_TYPE*/
         AND ATTR_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE /* AG_NAME*/
         AND ATTR_EXT.APPLICATION_COLUMN_NAME = FL_COL.APPLICATION_COLUMN_NAME /* DATABASE_COLUMN */
         AND AG_EXT.VARIANT = 'Y'
         AND AG_EXT.ATTR_GROUP_ID IN (SELECT A.ATTR_GROUP_ID
                                      FROM EGO_OBJ_AG_ASSOCS_B a
                                      WHERE A.OBJECT_ID = g_ego_item_object_id
                                      AND A.DATA_LEVEL_ID = g_ego_item_data_level_id
                                      AND A.CLASSIFICATION_CODE IN (SELECT To_Char(micg.ITEM_CATALOG_GROUP_ID)
                                                                    FROM MTL_ITEM_CATALOG_GROUPS_B micg
                                                                    CONNECT BY PRIOR micg.PARENT_CATALOG_GROUP_ID = micg.ITEM_CATALOG_GROUP_ID
                                                                    START WITH micg.ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id));

       RETURN(0);
  EXCEPTION
    WHEN others THEN
      x_err_text := SUBSTR(SQLERRM, 1, 240);
      RETURN(SQLCODE);
  END Default_Style_Variant_Attrs;


  /*
   * This method returns FND_API.G_TRUE or FND_API.G_FALSE
   * This method computes whether it is ok to have the new parent ICC
   * wrt style functionality i.e. we should not allow a ICC that has
   * different variant attributes than that are currently associated
   * with the ICC, if ICC already has some styles created.
   */
  FUNCTION Is_Parent_ICC_Valid_For_Style(p_item_catalog_group_id    NUMBER,
                                         p_parent_catalog_group_id  NUMBER)
  RETURN VARCHAR2 IS
    --l_itm_obj_id          NUMBER;
    --l_item_data_level_id  NUMBER;
    l_index               NUMBER;
    l_style_item_count    NUMBER;

    TYPE t_variants IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    l_existing_variants   t_variants;
    l_new_variants        t_variants;

    CURSOR c_existing_variants IS
      SELECT assoc.ATTR_GROUP_ID
      FROM
        EGO_OBJ_AG_ASSOCS_B assoc,
        EGO_FND_DSC_FLX_CTX_EXT ag_ext
      WHERE assoc.ATTR_GROUP_ID          = AG_EXT.ATTR_GROUP_ID
        AND NVL(ag_ext.VARIANT, 'N')     = 'Y'
        AND NVL(assoc.ENABLED_FLAG, 'Y') = 'Y'
        AND assoc.DATA_LEVEL_ID          = g_ego_item_data_level_id
        AND assoc.OBJECT_ID              = g_ego_item_object_id
        AND assoc.CLASSIFICATION_CODE IN (SELECT TO_CHAR(ITEM_CATALOG_GROUP_ID)
                                          FROM MTL_ITEM_CATALOG_GROUPS_B
                                          CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
                                          START WITH ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id
                                         );

    CURSOR c_new_variants IS
      SELECT assoc.ATTR_GROUP_ID
      FROM
        EGO_OBJ_AG_ASSOCS_B assoc,
        EGO_FND_DSC_FLX_CTX_EXT ag_ext
      WHERE assoc.ATTR_GROUP_ID          = AG_EXT.ATTR_GROUP_ID
        AND NVL(ag_ext.VARIANT, 'N')     = 'Y'
        AND NVL(assoc.ENABLED_FLAG, 'Y') = 'Y'
        AND assoc.DATA_LEVEL_ID          = g_ego_item_data_level_id
        AND assoc.OBJECT_ID              = g_ego_item_object_id
        AND assoc.CLASSIFICATION_CODE IN (SELECT TO_CHAR(ITEM_CATALOG_GROUP_ID)
                                          FROM MTL_ITEM_CATALOG_GROUPS_B
                                          CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
                                          START WITH ITEM_CATALOG_GROUP_ID = p_parent_catalog_group_id
                                          UNION ALL
                                          SELECT TO_CHAR(p_item_catalog_group_id) FROM DUAL
                                         );

    CURSOR IS_ICC_EXIST_FOR_STYLE(l_catalog_group_id NUMBER, l_flag VARCHAR2) IS
      SELECT 1
      FROM MTL_SYSTEM_ITEMS_B
      WHERE ROWNUM=1
      AND STYLE_ITEM_FLAG = l_flag
      AND ITEM_CATALOG_GROUP_ID = l_catalog_group_id;

  BEGIN

    /*SELECT OBJECT_ID INTO l_itm_obj_id
    FROM FND_OBJECTS
    WHERE OBJ_NAME = 'EGO_ITEM';

    SELECT DATA_LEVEL_ID INTO l_item_data_level_id
    FROM EGO_DATA_LEVEL_B
    WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
      AND APPLICATION_ID  = 431
      AND DATA_LEVEL_NAME = 'ITEM_LEVEL'; */

    FOR i IN c_existing_variants LOOP
      l_existing_variants(i.ATTR_GROUP_ID) := 'Y';
    END LOOP;

    IF l_existing_variants.COUNT > 0 THEN
      /*SELECT COUNT(1)
      INTO l_style_item_count
      FROM MTL_SYSTEM_ITEMS_B
      WHERE STYLE_ITEM_FLAG = 'Y'
        AND ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id; */

       OPEN Is_Icc_Exist_For_Style(p_item_catalog_group_id, 'Y');
       FETCH Is_Icc_Exist_For_Style INTO l_style_item_count;
       IF Is_Icc_Exist_For_Style%FOUND THEN
         l_style_item_count := 1;
       ELSE
         l_style_item_count := 0;
       END IF;
       CLOSE Is_Icc_Exist_For_Style;
    ELSE
      l_style_item_count := 0;
    END IF;

    IF l_style_item_count = 0 THEN
      RETURN FND_API.G_TRUE;
    END IF;

    FOR i IN c_new_variants LOOP
      l_new_variants(i.ATTR_GROUP_ID) := 'Y';
    END LOOP;

    IF l_new_variants.COUNT = 0 THEN
      RETURN FND_API.G_TRUE;
    END IF;

    IF l_existing_variants.COUNT <> l_new_variants.COUNT THEN
      RETURN FND_API.G_FALSE;
    END IF;

    IF l_existing_variants.FIRST IS NOT NULL THEN
      l_index := l_existing_variants.FIRST;
      WHILE l_index IS NOT NULL LOOP
        IF l_new_variants.EXISTS(l_index) THEN
          l_new_variants.DELETE(l_index);
          l_existing_variants.DELETE(l_index);
        END IF;
        l_index := l_existing_variants.NEXT(l_index);
      END LOOP;
    END IF;

    IF l_existing_variants.COUNT <> l_new_variants.COUNT THEN
      RETURN FND_API.G_FALSE;
    ELSE
      RETURN FND_API.G_TRUE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE IS_ICC_EXIST_FOR_STYLE;
      RETURN FND_API.G_FALSE;

  END Is_Parent_ICC_Valid_For_Style;


  PROCEDURE Insert_Fake_Row_For_Item( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                     ,p_batch_id               IN NUMBER
                                     ,p_inventory_item_id      IN NUMBER
                                     ,p_organization_id        IN NUMBER
                                     ,p_item_number            IN VARCHAR2
                                     ,p_style_item_flag        IN VARCHAR2
                                     ,p_style_item_id          IN NUMBER
                                     ,p_item_catalog_group_id  IN NUMBER
                                     ,x_return_status          OUT NOCOPY VARCHAR2
                                     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
      ( SET_PROCESS_ID,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
        ITEM_CATALOG_GROUP_ID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        ITEM_NUMBER,
        STYLE_ITEM_FLAG,
        STYLE_ITEM_ID,
        TRANSACTION_ID,
        SOURCE_SYSTEM_ID,
        CONFIRM_STATUS
      )
    VALUES
      ( p_batch_id,
        1,
        'SYNC',
        p_item_catalog_group_id,
        p_inventory_item_id,
        p_organization_id,
        p_item_number,
        p_style_item_flag,
        p_style_item_id,
        MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL,
        EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID,
        'FK'
      );

    IF p_commit = G_TRUE THEN
      COMMIT;
    END IF;
    x_return_status := 'S';
    x_msg_data := NULL;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_data := SQLERRM;
  END Insert_Fake_Row_For_Item;



  PROCEDURE Propagate_Role_To_SKUs ( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                    ,p_batch_id               IN NUMBER
                                    ,p_style_item_id          IN NUMBER
                                    ,p_organization_id        IN NUMBER
                                    ,p_role_name              IN VARCHAR2
                                    ,p_grantee_type           IN VARCHAR2
                                    ,p_grantee_party_id       IN NUMBER
                                    ,p_end_date               IN DATE
                                    ,x_return_status          OUT NOCOPY VARCHAR2
                                    ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS
    l_menu_id                  NUMBER;
    l_menu_disp_name           FND_MENUS_VL.USER_MENU_NAME%TYPE;
    l_org_code                 MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
    --l_object_id                NUMBER;
    l_ss_id                    NUMBER := EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID;
  BEGIN
    BEGIN
      SELECT MENU_ID, USER_MENU_NAME INTO l_menu_id, l_menu_disp_name
      FROM FND_MENUS_VL
      WHERE MENU_NAME = p_role_name;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_menu_id := NULL;
      l_menu_disp_name := '-X-';
    END;

    BEGIN
      SELECT ORGANIZATION_CODE INTO l_org_code
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = p_organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_org_code := '-X-';
    END;

    /*SELECT OBJECT_ID INTO l_object_id
    FROM FND_OBJECTS
    WHERE OBJ_NAME = 'EGO_ITEM';*/

    INSERT INTO EGO_ITEM_PEOPLE_INTF
    ( DATA_SET_ID,
      PROCESS_STATUS,
      TRANSACTION_TYPE,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      GRANTEE_PARTY_ID,
      INTERNAL_ROLE_NAME,
      GRANTEE_TYPE,
      START_DATE,
      END_DATE,
      ORGANIZATION_CODE,
      DISPLAY_ROLE_NAME,
      SOURCE_SYSTEM_ID,
      CREATED_BY
    )
    SELECT
      p_batch_id,
      1,
      'CREATE',
      msib.INVENTORY_ITEM_ID,
      p_organization_id,
      p_grantee_party_id,
      p_role_name,
      p_grantee_type,
      SYSDATE,
      p_end_date,
      l_org_code,
      l_menu_disp_name,
      l_ss_id,
      -99
    FROM MTL_SYSTEM_ITEMS_B msib, MTL_PARAMETERS mp
    WHERE msib.STYLE_ITEM_ID = p_style_item_id
      AND msib.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
      AND mp.ORGANIZATION_ID = p_organization_id
      AND NOT EXISTS (SELECT NULL FROM FND_GRANTS fg
                      WHERE fg.INSTANCE_TYPE           = 'INSTANCE'
                        AND fg.INSTANCE_PK1_VALUE      = TO_CHAR(msib.INVENTORY_ITEM_ID)
                        AND fg.INSTANCE_PK2_VALUE      = TO_CHAR(p_organization_id)
                        AND fg.OBJECT_ID               = g_ego_item_object_id
                        AND NVL(fg.END_DATE, SYSDATE)  >= SYSDATE
                        AND fg.MENU_ID                 = l_menu_id
                        AND fg.GRANTEE_TYPE            = p_grantee_type
                        AND fg.GRANTEE_KEY             = 'HZ_PARTY:'||p_grantee_party_id
                     );
    --6504765 : Style to sku item people is not defaulted for item author role
    --Added the grantee type and grantee key criteria's.
    IF p_commit = G_TRUE THEN
      COMMIT;
    END IF;
    x_return_status := 'S';
    x_msg_data := NULL;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_data := SQLERRM;
  END Propagate_Role_To_SKUs;

  /*
   * This method inserts Category assignment records for SKUs in the mtl categories interface table.
   */
  PROCEDURE Propagate_Category_To_SKUs ( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                        ,p_batch_id               IN NUMBER
                                        ,p_style_item_id          IN NUMBER
                                        ,p_organization_id        IN NUMBER
                                        ,p_category_set_id        IN NUMBER
                                        ,p_category_id            IN NUMBER
                                        ,x_return_status          OUT NOCOPY VARCHAR2
                                        ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS
    l_ss_id                    NUMBER := EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID;
  BEGIN
    INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE
    ( SET_PROCESS_ID,
      PROCESS_FLAG,
      TRANSACTION_TYPE,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      CATEGORY_SET_ID,
      CATEGORY_ID,
      SOURCE_SYSTEM_ID,
      CREATED_BY
    )
    SELECT
      p_batch_id,
      1,
      'CREATE',
      msib.INVENTORY_ITEM_ID,
      p_organization_id,
      p_category_set_id,
      p_category_id,
      l_ss_id,
      -99
    FROM MTL_SYSTEM_ITEMS_B msib, MTL_PARAMETERS mp
    WHERE msib.STYLE_ITEM_ID   = p_style_item_id
      AND msib.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
      AND mp.ORGANIZATION_ID   = p_organization_id
      AND NOT EXISTS (SELECT NULL FROM MTL_ITEM_CATEGORIES mic
                      WHERE mic.INVENTORY_ITEM_ID = msib.INVENTORY_ITEM_ID
                        AND mic.ORGANIZATION_ID   = p_organization_id
                        AND mic.CATEGORY_SET_ID   = p_category_set_id
                        AND mic.CATEGORY_ID       = p_category_id
                     );

    IF p_commit = G_TRUE THEN
      COMMIT;
    END IF;
    x_return_status := 'S';
    x_msg_data := NULL;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_data := SQLERRM;
  END Propagate_Category_To_SKUs;

BEGIN
  SELECT object_id
  INTO g_ego_item_object_id
  FROM fnd_objects
  WHERE obj_name = 'EGO_ITEM';

  SELECT data_level_id
  INTO g_ego_item_data_level_id
  FROM ego_data_level_b
  WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
  AND APPLICATION_ID  = 431
  AND DATA_LEVEL_NAME = 'ITEM_LEVEL';

END EGO_STYLE_SKU_ITEM_PVT;

/
