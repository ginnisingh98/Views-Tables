--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_COMPARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_COMPARE_PKG" AS
/* $Header: EGOPICMB.pls 120.6 2007/08/06 07:05:49 pfarkade ship $ */


-- =================================================================
-- Global constants that need to be used.
-- =================================================================
  -- The user language (to display the error messages in appropriate language)
  G_SESSION_LANG           VARCHAR2(99) :=  USERENV('LANG');

-- =================================================================
-- Global variables
-- =================================================================

  G_USER_ID         NUMBER  :=  -1;
  G_LOGIN_ID        NUMBER  :=  -1;
  G_PROG_APPID      NUMBER  :=  -1;
  G_PROG_ID         NUMBER  :=  -1;
  G_REQUEST_ID      NUMBER  :=  -1;


  --These columns need translation from Code to a Meaning.
  G_ITEM_TYPE             VARCHAR2(30) := 'ITEM_TYPE';
  G_PRIMARY_UOM           VARCHAR2(30) := 'PRIMARY_UOM_CODE';
  G_CATALOG_GROUP_ID      VARCHAR2(30) := 'ITEM_CATALOG_GROUP_ID';
  G_LIFECYCLE_ID          VARCHAR2(30) := 'LIFECYCLE_ID';
  G_LIFECYCLE_PHASE_ID    VARCHAR2(30) := 'CURRENT_PHASE_ID';
  G_ITEM_DETAIL_LINK      VARCHAR2(30) := 'ITEM_DETAIL_LINK';
  G_APPROVAL_STATUS       VARCHAR2(30) := 'APPROVAL_STATUS'; --For Bug 3424153 by absinha
  G_CONVERSIONS           VARCHAR2(30) := 'ALLOWED_UNITS_LOOKUP_CODE'; --For Bug 3424153 by absinha
  G_STYLE_FLAG            VARCHAR2(30) := 'STYLE_ITEM_FLAG' ; -- Bug 6156769
  G_STYLE_ITEM            VARCHAR2(30) := 'STYLE_ITEM_ID' ; -- Bug 6156769
  G_TRADE_ITEM_DESCRIPTOR VARCHAR2(30) := 'TRADE_ITEM_DESCRIPTOR' ; -- Bug 6156769

  --This is used to log errors into IDC_DEBUG table. (incr programatically)
  G_LINE_NUM  PLS_INTEGER := 2000;

  TYPE g_item_num_table         IS TABLE OF MTL_SYSTEM_ITEMS_VL.CONCATENATED_SEGMENTS%TYPE        INDEX BY BINARY_INTEGER;

  /*----------------------------------------------------------------------
    IMPORTANT NOTES:

  1. The functions Get_Item_Type_Disp_Val and Get_Primary_UOM_Disp_Val
     need to be before the calling function : Get_Item_Attr_Val
     as they are not exposed in the SPEC, and will give an error otherwise.
      Eg:
      PLS-00306: wrong number or types of arguments in call to
         'GET_ITEM_TYPE_DISP_VAL'

  2.
  ----------------------------------------------------------------------*/

-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================
  PROCEDURE log_debug (p_message   VARCHAR2) IS
    -- Start OF comments
    -- API name  : debug function
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : log the error in IDC_DEBUG table
    --
    -- Parameters:
    --     IN    : message to be logged
  BEGIN
     --INSERT INTO idc_debug values (G_LINE_NUM, TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') || ' --> '||p_message);
     G_LINE_NUM := G_LINE_NUM + 1;

  END log_debug;


    --To get the Item Type 'meaning'
    FUNCTION Get_Item_Type_Disp_Val
      (
       p_item_type     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       FND_LOOKUP_VALUES_VL.MEANING%TYPE;

      CURSOR c_item_type_meaning(p_lookup_code VARCHAR) IS
        SELECT meaning
        FROM   fnd_lookup_values_vl
      WHERE  lookup_type = 'ITEM_TYPE'
      AND    lookup_code = p_lookup_code;

    BEGIN

      OPEN c_item_type_meaning(p_item_type);
      FETCH c_item_type_meaning INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_item_type_meaning%NOTFOUND) THEN
     l_display_val := p_item_type;
      END IF;
      CLOSE c_item_type_meaning;

      RETURN l_display_val;

    END Get_Item_Type_Disp_Val;

    --To get Approval Status Meaning
    -- For Bug 3424153 by absinha
     FUNCTION Get_Approval_Status_Val
      (
       p_approval_status     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       FND_LOOKUP_VALUES_VL.MEANING%TYPE;

      CURSOR c_approval_status_meaning(p_approval_status_val VARCHAR) IS
        SELECT meaning
        FROM   fnd_lookup_values
      WHERE  language = userenv('LANG')
       AND    lookup_type = 'INV_ITEM_APPROVAL_STATUS'
       AND    lookup_code = p_approval_status_val;

    BEGIN

      OPEN c_approval_status_meaning(p_approval_status);
      FETCH c_approval_status_meaning INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_approval_status_meaning%NOTFOUND) THEN
     l_display_val := p_approval_status;
      END IF;
      CLOSE c_approval_status_meaning;

      RETURN l_display_val;

    END Get_Approval_Status_Val;

    --To get the Conversion Meaning
    --For Bug 3424153 by absinha
    FUNCTION Get_Conversions_Val
      (
       p_conversion_meaning     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       FND_LOOKUP_VALUES_VL.MEANING%TYPE;

      CURSOR c_conversion_meaning(p_conversion_val VARCHAR) IS
        SELECT meaning
        FROM   fnd_lookup_values_vl
      WHERE  lookup_type = 'MTL_CONVERSION_TYPE'
      AND    lookup_code = p_conversion_val;

    BEGIN

      OPEN c_conversion_meaning(p_conversion_meaning);
      FETCH c_conversion_meaning INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_conversion_meaning%NOTFOUND) THEN
     l_display_val := p_conversion_meaning;
      END IF;
      CLOSE c_conversion_meaning;

      RETURN l_display_val;

    END Get_Conversions_Val;

    --To get the Primary Unit of Measure 'meaning'
    FUNCTION Get_Primary_UOM_Disp_Val
      (
       p_primary_uom_code     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       MTL_UNITS_OF_MEASURE_TL.DESCRIPTION%TYPE;

      CURSOR c_uom_desc(p_uom_code VARCHAR) IS
        SELECT description
        FROM   mtl_units_of_measure_tl
      WHERE  language = userenv('LANG')
      AND    uom_code = p_uom_code;

    BEGIN

      OPEN c_uom_desc(p_primary_uom_code);
      FETCH c_uom_desc INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_uom_desc%NOTFOUND) THEN
     l_display_val := p_primary_uom_code;
      END IF;
      CLOSE c_uom_desc;

      RETURN l_display_val;

    END Get_Primary_UOM_Disp_Val;

    --To get the Catalog Group Name
    FUNCTION Get_Catalog_Group_Disp_Val
      (
       p_Catalog_Group_id     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val      EGO_CATALOG_GROUPS_V.CATALOG_GROUP%TYPE;

      CURSOR c_catalog_group_name(p_catalog_group_id VARCHAR2) IS
    SELECT catalog_group
    FROM ego_catalog_groups_v
    WHERE catalog_group_id = p_catalog_group_id;

    BEGIN

      OPEN c_catalog_group_name(p_catalog_group_id);
      FETCH c_catalog_group_name INTO l_display_val;

      --If name is not retrieved, set the ID as the display value.
      IF (c_catalog_group_name%NOTFOUND) THEN
     l_display_val := p_catalog_group_id;
      END IF;
      CLOSE c_catalog_group_name;

      RETURN l_display_val;

    END Get_Catalog_Group_Disp_Val;

    --To get the Lifecycle Name
    FUNCTION Get_Lifecycle_Disp_Val
      (
       p_lifecycle_id     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       PA_EGO_LIFECYCLES_V.NAME%TYPE;

      CURSOR c_lifecycle_name(p_lifecycle_id VARCHAR2) IS
        SELECT name  lifecycle_name
        FROM   pa_ego_lifecycles_v
--        FROM   pa_proj_elements
        WHERE  proj_element_id = p_lifecycle_id;

    BEGIN

      OPEN c_lifecycle_name(p_lifecycle_id);
      FETCH c_lifecycle_name INTO l_display_val;

      --If name is not retrieved, set the ID as the display value.
      IF (c_lifecycle_name%NOTFOUND) THEN
     l_display_val := p_lifecycle_id;
      END IF;
      CLOSE c_lifecycle_name;

      RETURN l_display_val;

    END Get_Lifecycle_Disp_Val;


    --To get the Lifecycle Phase Name
    FUNCTION Get_Lifecycle_Phase_Disp_Val
      (
       p_lifecycle_phase_id     IN   VARCHAR2
       )
    RETURN VARCHAR2 IS

      l_display_val       PA_EGO_PHASES_V.NAME%TYPE;

      CURSOR c_lifecycle_phase_name(p_lifecycle_phase_id VARCHAR2) IS
        SELECT name  lifecycle_phase_name
        FROM   pa_ego_phases_v
--        FROM   pa_proj_elements
        WHERE  proj_element_id = p_lifecycle_phase_id;

    BEGIN

      OPEN c_lifecycle_phase_name(p_lifecycle_phase_id);
      FETCH c_lifecycle_phase_name INTO l_display_val;

      --If name is not retrieved, set the ID as the display value.
      IF (c_lifecycle_phase_name%NOTFOUND) THEN
     l_display_val := p_lifecycle_phase_id;
      END IF;
      CLOSE c_lifecycle_phase_name;

      RETURN l_display_val;

    END Get_Lifecycle_Phase_Disp_Val;

    --Start Bug  6156769

   FUNCTION Get_Style_Flag_Val
   (
       p_style_flag     IN   VARCHAR2
   )
   RETURN VARCHAR2 IS

      l_display_val       FND_LOOKUP_VALUES_VL.MEANING%TYPE;

      CURSOR c_style_flag_meaning(p_style_flag VARCHAR) IS
        SELECT meaning
        FROM   fnd_lookup_values
        WHERE  language = userenv('LANG')
        AND    lookup_type = 'EGO_YES_NO'
        AND    lookup_code = p_style_flag;

    BEGIN

      OPEN c_style_flag_meaning(p_style_flag);
      FETCH c_style_flag_meaning INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_style_flag_meaning%NOTFOUND) THEN
       l_display_val := p_style_flag;
      END IF;
      CLOSE c_style_flag_meaning;

      RETURN l_display_val;

    END Get_Style_Flag_Val;


    FUNCTION Get_Style_Item_Disp_Val
    (
       p_style_item_id     IN   NUMBER,
       p_organization_id   IN   NUMBER
    )
    RETURN VARCHAR2 IS

      l_display_val       MTL_SYSTEM_ITEMS_VL.CONCATENATED_SEGMENTS%TYPE;

      CURSOR c_style_item_name(p_style_item_id NUMBER, p_organization_id NUMBER) IS
        SELECT CONCATENATED_SEGMENTS
        FROM   MTL_SYSTEM_ITEMS_VL
        WHERE  inventory_item_id = p_style_item_id
        AND organization_id = p_organization_id;

    BEGIN

      OPEN c_style_item_name(p_style_item_id , p_organization_id);
      FETCH c_style_item_name INTO l_display_val;
      CLOSE  c_style_item_name ;

      RETURN l_display_val;

    END Get_Style_Item_Disp_Val;

    FUNCTION Get_Trade_Item_Desc_Disp_Val
    (
       p_trade_item_desc     IN   VARCHAR2
     )
     RETURN VARCHAR2 IS

      l_display_val       EGO_VALUE_SET_VALUES_V.DISPLAY_NAME%TYPE;

      CURSOR c_trade_item_desc(p_trade_item_desc VARCHAR) IS
      SELECT DISPLAY_NAME
      FROM EGO_VALUE_SET_VALUES_V
      WHERE ENABLED_CODE = 'Y'
      AND ((START_DATE IS NULL) OR (START_DATE IS NOT NULL AND START_DATE <= SYSDATE))
      AND ((END_DATE IS NULL) OR (END_DATE IS NOT NULL AND END_DATE >= SYSDATE))
      AND INTERNAL_NAME =  p_trade_item_desc;

     BEGIN

      OPEN c_trade_item_desc(p_trade_item_desc);
      FETCH c_trade_item_desc INTO l_display_val;

      --If 'meaning' is not retrieved, set the code as the display value.
      IF (c_trade_item_desc%NOTFOUND) THEN
       l_display_val := p_trade_item_desc;
      END IF;
      CLOSE c_trade_item_desc;

      RETURN l_display_val;

     END Get_Trade_Item_Desc_Disp_Val;

    --End Bug  6156769

    --Get the Item Attributes Values
    FUNCTION Get_Item_Attr_Val (
      p_inventory_item_id     IN   VARCHAR2
     ,p_organization_id       IN   VARCHAR2
     ,p_attr_name             IN   VARCHAR2
                ) RETURN VARCHAR2 IS

    l_dyn_cur INTEGER := DBMS_SQL.OPEN_CURSOR;

    --Assumption: All the 'Main' attributes to be displayed are not more than
    --1000 chars. Long Description is of 4000 char length, but actual value
    --populated is lesser length than that.
    l_item_attr_val       VARCHAR2(1000);

    --Some Item Attribute values are CODEs that need to be translated into
    --Meanings, which will be displayed to the user.
    --FND_LOOKUP_VALUES.MEANING is VARCHAR(80).
    --There might be other types of Code to Meaning translation other than
    --through FND_LOOKUP_VALUES, so having a little more length.
    l_display_val         VARCHAR2(200);

    l_exec_val PLS_INTEGER;

    l_db_column VARCHAR2(100);

    l_dyn_sql  VARCHAR2(1000);

    l_msg_txt  VARCHAR2(200);
    BEGIN

       --To save making an unncessary DB trip
       IF (p_inventory_item_id = '-1' OR p_organization_id = '-1') THEN

      l_item_attr_val := 'NULL';
      --For BUG 3321433
      DBMS_SQL.CLOSE_CURSOR(l_dyn_cur);

       ELSE

      l_db_column := Substr(p_attr_name, Instr(p_attr_name,'.')+1);

      --For Item Detail link, processing is different.
      IF (l_db_column NOT IN (G_ITEM_DETAIL_LINK)) THEN

     --Made this into bind variable SQL for 'SQL Compliance Project':11.5.9+ (5/1/2003)
         l_dyn_sql := '';
         l_dyn_sql := l_dyn_sql || ' SELECT '|| l_db_column;
     l_dyn_sql := l_dyn_sql || ' FROM MTL_SYSTEM_ITEMS_VL ';
     l_dyn_sql := l_dyn_sql || ' WHERE INVENTORY_ITEM_ID = :INVENTORY_ITEM_ID ';
     l_dyn_sql := l_dyn_sql || ' AND ORGANIZATION_ID = :ORGANIZATION_ID ';

        --log_debug('l_dyn_sql - '||l_dyn_sql);

        DBMS_SQL.PARSE(l_dyn_cur, l_dyn_sql, DBMS_SQL.NATIVE);

        DBMS_SQL.DEFINE_COLUMN (l_dyn_cur, 1, l_item_attr_val, 1000);

        DBMS_SQL.BIND_VARIABLE(l_dyn_cur,':INVENTORY_ITEM_ID', p_inventory_item_id);
        DBMS_SQL.BIND_VARIABLE(l_dyn_cur,':ORGANIZATION_ID', p_organization_id);

        l_exec_val := DBMS_SQL.EXECUTE_AND_FETCH(l_dyn_cur);

        DBMS_SQL.COLUMN_VALUE(l_dyn_cur, 1, l_item_attr_val);

        DBMS_SQL.CLOSE_CURSOR(l_dyn_cur);
        --log_debug('OK '||l_exec_val);
        --log_debug('l_item_attr_val : '||l_item_attr_val);

        --For specific columns, code to meaning translations are needed.
        IF (l_item_attr_val IS NOT NULL) THEN
           IF (l_db_column = G_ITEM_TYPE ) THEN
          l_item_attr_val := Get_Item_Type_Disp_Val(l_item_attr_val);
        ELSIF (l_db_column = G_PRIMARY_UOM ) THEN
                  l_item_attr_val := Get_Primary_UOM_Disp_Val(l_item_attr_val);
        ELSIF (l_db_column = G_CATALOG_GROUP_ID ) THEN
                  l_item_attr_val := Get_Catalog_Group_Disp_Val(l_item_attr_val);
        ELSIF (l_db_column = G_LIFECYCLE_ID ) THEN
           l_item_attr_val := Get_Lifecycle_Disp_Val(l_item_attr_val);
        ELSIF (l_db_column = G_LIFECYCLE_PHASE_ID ) THEN
           l_item_attr_val := Get_Lifecycle_Phase_Disp_Val(l_item_attr_val);
        ELSIF (l_db_column = G_APPROVAL_STATUS ) THEN --For Bug 3424153 by absinha
           l_item_attr_val := Get_Approval_Status_Val(l_item_attr_val);
        ELSIF (l_db_column = G_CONVERSIONS ) THEN --For Bug 3424153 by absinha
	         l_item_attr_val := Get_Conversions_Val(l_item_attr_val);
        ELSIF (l_db_column = G_STYLE_FLAG ) THEN --Bug 6156769
	         l_item_attr_val := Get_Style_Flag_Val(l_item_attr_val);
        ELSIF (l_db_column = G_STYLE_ITEM ) THEN --Bug 6156769
	         l_item_attr_val := Get_Style_Item_Disp_Val(l_item_attr_val,p_organization_id);
        ELSIF (l_db_column = G_TRADE_ITEM_DESCRIPTOR ) THEN --Bug 6156769
	         l_item_attr_val := Get_Trade_Item_Desc_Disp_Val(l_item_attr_val);
	      END IF;
	ELSIF (l_db_column = G_APPROVAL_STATUS ) THEN --For Bug 3424153 by absinha
           l_item_attr_val := Get_Approval_Status_Val('A');
        END IF;

      ELSE --IF (l_db_column NOT IN (G_ITEM_DETAIL_LINK)) THEN

         IF (l_db_column = G_ITEM_DETAIL_LINK) THEN

               FND_MESSAGE.SET_NAME('EGO','EGO_ITEM_DETAIL_LINK');
               FND_MESSAGE.SET_TOKEN('INV_ITEM_ID', p_inventory_item_id);
               FND_MESSAGE.SET_TOKEN('ORG_ID',p_organization_id);
           --l_item_attr_val := '<a href="/OA.jsp?OAFunc=EGO_ITEM_OVERVIEW\&inventoryItemId=6992&organizationId=204"><img src="/OA_MEDIA/cabo/cache/gb-FNDPREFS.gif" alt="" border="0"></a>';
           l_item_attr_val := FND_MESSAGE.GET;

         END IF;
      END IF;

       END IF;

     RETURN l_item_attr_val;
     --For Bug 3321433
     EXCEPTION when others then
       DBMS_SQL.CLOSE_CURSOR(l_dyn_cur);
     RETURN l_item_attr_val;
    END Get_Item_Attr_Val;

    --------------------------------------------------------------------------
    -- DESCRIPTION
    --   Get User Attribute value.
    --------------------------------------------------------------------------
    FUNCTION Get_User_Attr_Val (
        p_appl_id                       IN   NUMBER
       ,p_attr_grp_type                 IN   VARCHAR2
       ,p_attr_grp_name                 IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_inventory_item_id             IN   VARCHAR2
       ,p_organization_id               IN   VARCHAR2
       ,p_data_level_name               IN   VARCHAR2
       ,p_failed_priv_check_str         IN   VARCHAR2 DEFAULT NULL
    )
    RETURN VARCHAR2 IS

      l_AG_view_privilege  FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;--4105308
      l_user_party_id       VARCHAR2(30);
      l_can_see_value       VARCHAR2(1) := 'T';
      l_user_attr_val       VARCHAR2(1000);
      l_ag_defaulting       VARCHAR2(30);   -- Defaulting behavior of attribute
                                                                      -- group.
      l_item_to_query       NUMBER;            -- Inventory item ID of the item
                                 -- which contains the value we want to return.

    BEGIN

      log_debug('Get_User_Attr_Val():');
      log_debug('Get_User_Attr_Val(): Get_User_Attr_Val (');
      log_debug('Get_User_Attr_Val():   p_appl_id                       => ' || p_appl_id);
      log_debug('Get_User_Attr_Val():   p_attr_grp_type                 => ' || p_attr_grp_type);
      log_debug('Get_User_Attr_Val():   p_attr_grp_name                 => ' || p_attr_grp_name);
      log_debug('Get_User_Attr_Val():   p_attr_name                     => ' || p_attr_name);
      log_debug('Get_User_Attr_Val():   p_inventory_item_id             => ' || p_inventory_item_id);
      log_debug('Get_User_Attr_Val():   p_organization_id               => ' || p_organization_id);
      log_debug('Get_User_Attr_Val():   p_data_level_name               => ' || p_data_level_name);
      log_debug('Get_User_Attr_Val():   p_failed_priv_check_str         => ' || p_failed_priv_check_str);
      log_debug('Get_User_Attr_Val(): )');

      IF (p_inventory_item_id = '-1' OR p_organization_id = '-1') THEN

        l_user_attr_val := 'NULL';

      ELSE

        ------------------------------------------------------------
        -- First, see whether the Attr Group has a View privilege --
        ------------------------------------------------------------
        l_AG_view_privilege := EGO_EXT_FWK_PUB.Get_Privilege_For_Attr_Group (
                                 p_application_id                => p_appl_id
                                ,p_attr_group_type               => p_attr_grp_type
                                ,p_attr_group_name               => p_attr_grp_name
                                ,p_which_priv_to_return          => 'VIEW'
                               );

        -------------------------------------------------------------
        -- If there is such a privilege, make sure the user has it --
        -------------------------------------------------------------
        IF (l_AG_view_privilege IS NOT NULL) THEN

          l_can_see_value := 'F';

          BEGIN

            SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
              INTO l_user_party_id
              FROM EGO_PEOPLE_V
             WHERE USER_NAME = FND_GLOBAL.USER_NAME;

            l_can_see_value := EGO_DATA_SECURITY.Check_Function(
                                 p_api_version                   => 1.0
                                ,p_function                      => l_AG_view_privilege
                                ,p_object_name                   => 'EGO_ITEM'
                                ,p_instance_pk1_value            => p_inventory_item_id
                                ,p_instance_pk2_value            => p_organization_id
                                ,p_user_name                     => l_user_party_id
                               );

             IF (l_can_see_value IS NULL) THEN
               l_can_see_value := 'F';
             END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_can_see_value := 'F';
          END;

          ------------------------------------------------------------
          -- If the user doesn't have privileges to see this value, --
          -- we return the passed-in "fall-back" string instead     --
          ------------------------------------------------------------
          IF (NOT FND_API.TO_BOOLEAN(l_can_see_value)) THEN

            l_user_attr_val := NVL(p_failed_priv_check_str, 'NULL');

          END IF;
        END IF;

        -------------------------------------------
        -- Determine which item we need to query --
        -------------------------------------------

        -- First, determine the attribute group defaulting behavior
        SELECT  defaulting
        INTO    l_ag_defaulting
        FROM    ego_attr_group_dl
        WHERE   attr_group_id =
               (SELECT  attr_group_id
                FROM    ego_attr_groups_v
                WHERE   application_id  = p_appl_id
                    AND attr_group_type = p_attr_grp_type
                    AND attr_group_name = p_attr_grp_name
                )
            AND data_level_id =
               (SELECT  data_level_id
                FROM    ego_data_level_b
                WHERE   data_level_name = p_data_level_name
                    AND attr_group_type = p_attr_grp_type
                    AND application_id  = p_appl_id
                );

        -- In light of the defaulting behavior, determine under which item the
        -- attribute value is stored.
        IF l_ag_defaulting = G_INHERITED_AG THEN
          -- If this is a SKU item, we need to query its style item
          SELECT  COALESCE(style_item_id, inventory_item_id) item_id
          INTO    l_item_to_query
          FROM    mtl_system_items_b
          WHERE   inventory_item_id = p_inventory_item_id AND
                  organization_ID   = p_organization_id;

        ELSE
          -- We always query the item by the caller
          l_item_to_query := p_inventory_item_id;
        END IF;

        log_debug('Get_User_Attr_Val(): item with ID ' || l_item_to_query || ' will be queried.');


        IF (FND_API.TO_BOOLEAN(l_can_see_value)) THEN

          -------------------------------------------
          -- Finally, query the item for the value --
          -------------------------------------------
          l_user_attr_val := EGO_USER_ATTRS_DATA_PVT.Get_User_Attr_Val (
                               p_appl_id                       => p_appl_id
                              ,p_attr_grp_type                 => p_attr_grp_type
                              ,p_attr_grp_name                 => p_attr_grp_name
                              ,p_attr_name                     => p_attr_name
                              ,p_object_name                   => 'EGO_ITEM'
                              ,p_pk_col1                       => 'INVENTORY_ITEM_ID'
                              ,p_pk_col2                       => 'ORGANIZATION_ID'
                              ,p_pk_value1                     => l_item_to_query
                              ,p_pk_value2                     => p_organization_id
                              ,p_data_level                    => p_data_level_name
                             );

        END IF;
      END IF;

      --log_debug('User Ext Attribute Value '||l_user_attr_val);

      RETURN l_user_attr_val;

    END Get_User_Attr_Val;

END EGO_ITEM_COMPARE_PKG;

/
