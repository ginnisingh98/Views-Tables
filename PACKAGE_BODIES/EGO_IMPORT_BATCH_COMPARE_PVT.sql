--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_BATCH_COMPARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_BATCH_COMPARE_PVT" AS
/* $Header: EGOVCMPB.pls 120.32 2007/08/21 06:59:27 nshariff ship $ */

 G_NUMBER_FORMAT      VARCHAR2(1) := 'N';
 G_CHAR_FORMAT        VARCHAR2(1) := 'C';
 G_DATE_FORMAT        VARCHAR2(1) := 'D';
 G_TIME_FORMAT        VARCHAR2(1) := 'X';
 G_DATE_TIME_FORMAT   VARCHAR2(1) := 'Y';
 G_ITEM_LEVEL                       VARCHAR2(20) := 'ITEM_LEVEL';
 G_ORG_LEVEL                        VARCHAR2(20) := 'ITEM_ORG';
 G_ITEM_SUPPLIER_LEVEL              VARCHAR2(20) := 'ITEM_SUP';
 G_ITEM_SUPPLIER_SITE_LEVEL         VARCHAR2(20) := 'ITEM_SUP_SITE';
 G_ITEM_SUPPLIER_SITE_ORG_LEVEL     VARCHAR2(20) := 'ITEM_SUP_SITE_ORG';
 G_ITEM_REVISION_LEVEL              VARCHAR2(20) := 'ITEM_REVISION_LEVEL';
 G_ITEM_LEVEL_ID                       NUMBER := 43101;
 G_ORG_LEVEL_ID                        NUMBER := 43102;
 G_ITEM_SUPPLIER_LEVEL_ID              NUMBER := 43103;
 G_ITEM_SUPPLIER_SITE_LEVEL_ID         NUMBER := 43104;
 G_ITEM_SUPSITEORG_LEVEL_ID            NUMBER := 43105;


 PROCEDURE Debug_Message(message IN VARCHAR2) IS
 BEGIN
   NULL;
   --nisar_debug_proc(message);
 END Debug_Message;


  /**
  * Nisar - Bug 5139813.
  * Returns current production revision for an item.
  * Returns - VARCHAR2.
  */
  FUNCTION GET_CURRENT_PDH_REVISION(p_inventory_item_id NUMBER
                                   ,p_organization_id NUMBER)
  RETURN VARCHAR2 IS
    l_rev VARCHAR2(5);
  BEGIN
    EXECUTE IMMEDIATE 'SELECT IR.REVISION FROM MTL_ITEM_REVISIONS_B IR
                   WHERE IR.INVENTORY_ITEM_ID = :1
                   AND IR.ORGANIZATION_ID = :2
                   AND IR.REVISION_ID IN
                       (SELECT MAX(IR2.REVISION_ID)
                           KEEP (DENSE_RANK LAST ORDER BY IR2.EFFECTIVITY_DATE )
                         FROM MTL_ITEM_REVISIONS_B IR2
                         WHERE IR2.ORGANIZATION_ID       = IR.ORGANIZATION_ID
                           AND IR2.INVENTORY_ITEM_ID = IR.INVENTORY_ITEM_ID
                           AND IR2.EFFECTIVITY_DATE <= SYSDATE
                           AND IR2.IMPLEMENTATION_DATE IS NOT NULL
                       )' INTO l_rev USING p_inventory_item_id, p_organization_id;
    RETURN l_rev;
  END GET_CURRENT_PDH_REVISION;


  /**
  * Nisar - Bug. 5139813.
  * RETURNS BOOLEAN - To find out if certain revision exists for a given
  * item passing its inventory_item_id and organization_id
  */
  FUNCTION REV_EXISTS_IN_PDH ( p_revision VARCHAR2,
                               p_inventory_item_id NUMBER,
                               p_organization_id NUMBER
                             )
  RETURN VARCHAR2 IS
    l_temp VARCHAR2(5);
  BEGIN
    EXECUTE IMMEDIATE 'SELECT REVISION
                       FROM MTL_ITEM_REVISIONS
                       WHERE INVENTORY_ITEM_ID = :1
                         AND ORGANIZATION_ID = :2
                         AND REVISION = :3' INTO l_temp USING p_inventory_item_id, p_organization_id, p_revision;
    RETURN 'Y'; -- Return true
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N'; -- return false
  END REV_EXISTS_IN_PDH;

 /**
 To get the Source System value for the internal value given
 */
  FUNCTION  Get_SS_Data_For_Val_set (
                        p_value_set_id           IN   NUMBER
                       ,p_validation_code        IN   VARCHAR2
                       ,p_str_val                IN   VARCHAR2   DEFAULT NULL
                       ,p_date_val               IN   DATE       DEFAULT NULL
                       ,p_num_val                IN   NUMBER     DEFAULT NULL
	          ) RETURN VARCHAR2
  IS
    l_sql                       VARCHAR2(32767);
    l_disp_value                VARCHAR2(150);
    l_attr_group_metadata_obj   EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_obj         EGO_ATTR_METADATA_OBJ;
  BEGIN
    l_attr_metadata_obj := EGO_ATTR_METADATA_OBJ(
                                     NULL-- ATTR_ID
                                    ,NULL -- ATTR_GROUP_ID
                                    ,NULL -- ATTR_GROUP_NAME
                                    ,NULL -- ATTR_NAME
                                    ,NULL -- ATTR_DISP_NAME
                                    ,NULL -- DATA_TYPE_CODE
                                    ,NULL -- DATA_TYPE_MEANING
                                    ,NULL -- SEQUENCE
                                    ,NULL -- UNIQUE_KEY_FLAG
                                    ,NULL -- DEFAULT_VALUE
                                    ,NULL -- INFO_1
                                    ,NULL -- MAXIMUM_SIZE
                                    ,NULL -- REQUIRED_FLAG
                                    ,NULL -- DATABASE_COLUMN
                                    ,NULL -- VALUE_SET_ID
                                    ,NULL -- VALIDATION_CODE
                                    ,NULL -- MINIMUM_VALUE
                                    ,NULL -- MAXIMUM_VALUE
                                    ,NULL -- UNIT_OF_MEASURE_CLASS
                                    ,NULL -- UNIT_OF_MEASURE_BASE
                                    ,NULL -- DISP_TO_INT_VAL_QUERY
                                    ,NULL -- INT_TO_DISP_VAL_QUERY
                                    ,NULL -- VS_BIND_VALUES_CODE
                                    ,NULL -- VIEW_IN_HIERARCHY_CODE
                                    ,NULL -- EDIT_IN_HIERARCHY_CODE
                              );
    l_attr_group_metadata_obj :=   EGO_ATTR_GROUP_METADATA_OBJ(
                                     NULL   -- ATTR_GROUP_ID
                                    ,NULL   -- APPLICATION_ID
                                    ,NULL   -- ATTR_GROUP_TYPE
                                    ,NULL   --  ATTR_GROUP_NAME
                                    ,NULL   -- ATTR_GROUP_DISP_NAME
                                    ,NULL   -- AGV_NAME
                                    ,NULL   -- MULTI_ROW_CODE
                                    ,NULL   -- VIEW_PRIVILEGE
                                    ,NULL   -- EDIT_PRIVILEGE
                                    ,NULL   -- EXT_TABLE_B_NAME
                                    ,NULL   -- EXT_TABLE_TL_NAME
                                    ,NULL   -- EXT_TABLE_VL_NAME
                                    ,NULL   -- SORT_ATTR_VALUES_FLAG
                                    ,NULL   -- UNIQUE_KEY_ATTRS_COUNT
                                    ,NULL   -- TRANS_ATTRS_COUNT
                                    ,NULL   -- attr_metadata_table
                                    ,NULL   -- ATTR_GROUP_ID_FLAG
                                    ,NULL   -- HIERARCHY_NODE_QUERY
                                    ,NULL   -- HIERARCHY_PROPAGATION_API
                                    ,NULL   -- HIERARCHY_PROPAGATE_FLAG
                                    ,NULL   -- ENABLED_DATA_LEVELS
                                    ,NULL   -- VARIANT
                                    );
    EGO_USER_ATTRS_COMMON_PVT.Build_Sql_Queries_For_Value(
                  p_value_set_id             =>  p_value_set_id
                 ,p_validation_code          =>  p_validation_code
                 ,px_attr_group_metadata_obj =>  l_attr_group_metadata_obj-- EGO_ATTR_GROUP_METADATA_OBJ
                 ,px_attr_metadata_obj       =>  l_attr_metadata_obj ); -- EGO_ATTR_METADATA_OBJ
    l_sql    :=  l_attr_metadata_obj.INT_TO_DISP_VAL_QUERY ;
    IF l_sql IS NOT NULL THEN
	    l_sql := l_sql || ' :1' ;
      IF( INSTR(l_sql, '$') > 0 ) THEN
        IF p_num_val IS NOT NULL THEN
          l_disp_value := TO_CHAR(p_num_val);
        ELSIF p_str_val IS NOT NULL THEN
          l_disp_value  := p_str_val;
        ELSIF p_date_val IS NOT NULL THEN
          l_disp_value := TO_CHAR(p_date_val, 'MM/DD/YYYY HH24:MI:SS');
        END IF; --IF p_num_val IS NOT NULL THEN
      ELSIF p_num_val IS NOT NULL THEN
	      BEGIN
          EXECUTE IMMEDIATE l_sql INTO l_disp_value USING p_num_val;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_disp_value := TO_CHAR(p_num_val);
        END;
	    ELSIF p_str_val IS NOT NULL THEN
        BEGIN
	        EXECUTE IMMEDIATE l_sql  INTO l_disp_value USING p_str_val;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_disp_value  := p_str_val;
        END;
	    ELSIF p_date_val IS NOT NULL THEN
        BEGIN
          EXECUTE IMMEDIATE l_sql INTO l_disp_value USING p_date_val;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_disp_value := TO_CHAR(p_date_val, 'MM/DD/YYYY HH24:MI:SS');
        END;
	    END IF; --IF( INSTR(l_sql, '$') > 0 ) THEN
    ELSE
      IF p_num_val IS NOT NULL THEN
        l_disp_value := TO_CHAR(p_num_val);
      ELSIF  p_str_val IS NOT NULL THEN
        l_disp_value  := p_str_val;
      ELSIF p_date_val IS NOT NULL THEN
        l_disp_value := TO_CHAR(p_date_val, 'MM/DD/YYYY HH24:MI:SS');
      END IF; --IF p_num_val IS NOT NULL THEN
    END IF; -- IF l_sql IS NOT NULL THEN

    -- if we get NULL as the display value THEN send back the input value as output
    IF l_disp_value IS NULL THEN
      IF p_num_val IS NOT NULL THEN
        l_disp_value := TO_CHAR(p_num_val);
      ELSIF p_str_val IS NOT NULL THEN
        l_disp_value  := p_str_val;
      ELSIF p_date_val IS NOT NULL THEN
        l_disp_value := TO_CHAR(p_date_val, 'MM/DD/YYYY HH24:MI:SS');
      END IF;
    END IF;

    RETURN l_disp_value;
  END Get_SS_Data_For_Val_set;

 /******************************************************************************
   Populate data in sql table type to return the data.
  *****************************************************************************/
  PROCEDURE populate_compare_tbl ( p_compare_table IN OUT  NOCOPY SYSTEM.EGO_COMPARE_VIEW_TABLE ,
                                   p_index         IN NUMBER ,
                                   p_sel_item      IN NUMBER ,
                                   p_value         IN VARCHAR2 ,
                                   p_item1         IN NUMBER ,
                                   p_item2         IN NUMBER ,
                                   p_item3         IN NUMBER ,
                                   p_item4         IN NUMBER  )
  IS
  BEGIN
    IF p_sel_item = p_item1 THEN
      p_compare_table(p_index).item1 := p_value ;
    ELSIF p_sel_item = p_item2 THEN
      p_compare_table(p_index).item2 := p_value ;
    ELSIF p_sel_item = p_item3 THEN
      p_compare_table(p_index).item3 := p_value ;
    ELSIF p_sel_item = p_item4 THEN
      p_compare_table(p_index).item4 := p_value ;
    END IF;
  END populate_compare_tbl;


 /***************************************************************************
  By Nisar - Get the function (or Privilege) name ... Privilege of
  a user to access attributes of an Attribute Group
  *****************************************************************************/
  FUNCTION get_privilege_name ( p_priv_id IN NUMBER) RETURN VARCHAR2
  IS
    l_name VARCHAR2(100);
  BEGIN
    SELECT FUNCTION_NAME INTO l_name
    FROM FND_FORM_FUNCTIONS
    WHERE FUNCTION_ID = p_priv_id;
    RETURN l_name;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_privilege_name;



 /***************************************************************************
    To get the data(primary, opearational,
    , and developer defined
    attrs, for the source system item and matched item ids passed.
  *****************************************************************************/

  FUNCTION GET_COMPARED_DATA (p_ss_code           NUMBER,
                              p_ss_record         VARCHAR2 ,
                              p_batch_id          NUMBER,
                              p_mode              NUMBER,
                              p_item1             NUMBER,
                              p_item2             NUMBER,
                              p_item3             NUMBER,
                              p_item4             NUMBER,
                              p_org_Id            NUMBER,
                              p_pdh_revision      VARCHAR2,
                              p_supplier_id       NUMBER DEFAULT NULL,  -- R12C: New Parameter: Supplier Id
                              p_supplier_site_id  NUMBER DEFAULT NULL,  -- R12C: New Parameter: Supplier Site Id
                              p_bundle_id         NUMBER DEFAULT NULL   -- R12C: New Parameter passed only in case of GDSN Enable batches.
                              )
                              RETURN  SYSTEM.EGO_COMPARE_VIEW_TABLE
  IS
    --------------------------------------------------------------
    -- CURSOR FOR GETTING META DATA OF ITEM OPERATIONAL ATTRIBUTES
    --------------------------------------------------------------
    CURSOR cr_attr_info IS
      SELECT
        AG.ATTR_GROUP_NAME,
        AG.ATTR_GROUP_DISP_NAME,
        AG.VIEW_PRIVILEGE_ID,
        A.ATTR_ID,
        A.DATABASE_COLUMN,
        A.ATTR_DISPLAY_NAME ,
        A.VALIDATION_CODE,
        A.ATTR_NAME,
        A.VALUE_SET_ID,
        A.DATA_TYPE_CODE,
        A.UOM_CLASS
      FROM
        EGO_ATTR_GROUPS_DL_V AG ,
        EGO_ATTRS_V A
      WHERE A.ATTR_GROUP_TYPE = AG.ATTR_GROUP_TYPE
        AND A.ATTR_GROUP_TYPE = 'EGO_MASTER_ITEMS'
        AND A.ATTR_GROUP_NAME = AG.ATTR_GROUP_NAME
        AND A.APPLICATION_ID  = AG.APPLICATION_ID
        AND A.APPLICATION_ID  = 431
        AND AG.ATTR_GROUP_NAME <> 'Main'
      ORDER BY AG.ATTR_GROUP_NAME;

    -----------------------------------------------------
    -- CURSOR FOR GETTING ATTRIBUTE GROUP ID AND NAME OF
    -- ITEM OPERATIONAL ATTRIBUTE GROUPS
    -----------------------------------------------------
    CURSOR cr_op_attr_grps IS
      SELECT
        AG.ATTR_GROUP_ID,
        AG.ATTR_GROUP_NAME
      FROM EGO_ATTR_GROUPS_DL_V AG
      WHERE AG.ATTR_GROUP_TYPE IN ('EGO_MASTER_ITEMS')
        AND AG.ATTR_GROUP_NAME <> 'Main'
        AND AG.APPLICATION_ID  = 431   ;

    ----------------------------------------------------------------------
    -- CURSOR FOR GETTING THE NAME AND MEANING FOR ITEM PRIMARY ATTRIBUTES
    ----------------------------------------------------------------------
    CURSOR cr_primary_attr IS
      SELECT
        LOOKUP_CODE,
        MEANING
      FROM FND_LOOKUPS
      WHERE LOOKUP_TYPE ='EGO_ITEM_PRIMARY_ATTRIBUTE_GRP'
        AND LOOKUP_CODE NOT IN ('APPROVAL_STATUS','ITEM_NUMBER', 'NEW_ITEM_REQUEST')  --  'LONG_DESCRIPTION',
        AND ENABLED_FLAG = 'Y'
        AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
        AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE);

    ------------------------------------------------------------
    -- CURSOR TO GET THE USER DEFINED ATTRIBUTE GROUPS
    -- PRESENT IN THE INTERFACE TABLE FOR A SOURCE SYSTEM ITEM
    ------------------------------------------------------------
    CURSOR cr_attr_groups(c_revision IN VARCHAR2, c_bundle_id IN NUMBER) IS
      SELECT DISTINCT
        I.ATTR_GROUP_INT_NAME,
        I.REVISION,
        AG.DATA_LEVEL_INTERNAL_NAME,             -- R12C: Added
        AG.DATA_LEVEL_ID,               -- R12C: Added
        AG.ATTR_GROUP_DISP_NAME,
        AG.ATTR_GROUP_ID,
        AG.VIEW_PRIVILEGE_ID
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTR_GROUPS_DL_V AG
      WHERE NVL(AG.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND I.SOURCE_SYSTEM_ID =  p_ss_code
        AND I.SOURCE_SYSTEM_REFERENCE =  p_ss_record
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) < 1
        AND (REVISION IS NULL OR REVISION = c_revision)
        AND I.organization_id = p_org_id
        AND I.ATTR_GROUP_INT_NAME = AG.ATTR_GROUP_NAME
        AND (  I.DATA_LEVEL_ID = AG.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AG.DATA_LEVEL_INTERNAL_NAME )
        AND AG.APPLICATION_ID = 431
        AND AG.MULTI_ROW_CODE = 'N'
        AND ( I.BUNDLE_ID IS NULL OR I.BUNDLE_ID = c_bundle_id );

    ----------------------------------------------------------------------
    -- CURSOR TO GET USER DEFINED ATTRIBUTES FROM THE INTERFACE TABLE
    -- FOR GIVEN ATTRIBUTE GROUP
    ----------------------------------------------------------------------
    CURSOR cr_usr_intf (p_attr_group_int_name VARCHAR2, p_data_level_id NUMBER, c_bundle_id IN NUMBER ) IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.REVISION,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AGV.ATTR_GROUP_DISP_NAME,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AGV.DATA_LEVEL_ID,              -- R12C: Added
        AGV.DATA_LEVEL_INTERNAL_NAME,            -- R12C: Added
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE,
        AV.UOM_CLASS
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.ATTR_GROUP_INT_NAME = p_attr_group_int_name
        AND I.DATA_LEVEL_ID = p_data_level_id
        AND NVL(AGV.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND I.SOURCE_SYSTEM_ID = p_ss_code
        AND I.SOURCE_SYSTEM_REFERENCE = p_ss_record
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) < 1
        AND I.REVISION IS NULL
        AND I.ORGANIZATION_ID = p_org_id
        AND (  I.DATA_LEVEL_ID = AGV.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AGV.DATA_LEVEL_INTERNAL_NAME )
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID
        AND ( I.BUNDLE_ID IS NULL OR I.BUNDLE_ID = c_bundle_id );

    ------------------------------------------------------
    -- TO GET THE ATTRIBUTES FOR GIVEN ATTRIBUTE GROUP  --
    --    USER DEFINED ATTRIBUTES WITH RIVISION         --
    ------------------------------------------------------
    CURSOR cr_rev_usr_intf (p_attr_group_int_name VARCHAR2, c_revision VARCHAR2, c_bundle_id IN NUMBER ) IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.REVISION,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AV.UOM_CLASS,
        AGV.ATTR_GROUP_DISP_NAME,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AGV.DATA_LEVEL_ID,              -- R12C: Added
        AGV.DATA_LEVEL_INTERNAL_NAME,            -- R12C: Added
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.ATTR_GROUP_INT_NAME = p_attr_group_int_name
        AND NVL(AGV.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND I.SOURCE_SYSTEM_ID = p_ss_code
        AND I.SOURCE_SYSTEM_REFERENCE = p_ss_record
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) < 1
        AND I.REVISION = c_revision
        AND I.organization_id = p_org_id
        AND (  I.DATA_LEVEL_ID = AGV.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AGV.DATA_LEVEL_INTERNAL_NAME )
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID
        AND ( I.BUNDLE_ID IS NULL OR I.BUNDLE_ID = c_bundle_id );

    -------------------------------------------------------
    -- CURSOR TO GET THE GDSN ATTRIBUTES IN INTERFACE TABLE
    -------------------------------------------------------
    CURSOR cr_dd_intf( c_bundle_id IN NUMBER ) IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AGV.ATTR_GROUP_DISP_NAME,
        AGV.VIEW_PRIVILEGE_ID,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE,
        AV.UOM_CLASS
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND AGV.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS'
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.SOURCE_SYSTEM_ID = p_ss_code
        AND I.SOURCE_SYSTEM_REFERENCE = p_ss_record
        AND I.DATA_SET_ID = p_batch_id
        AND I.organization_id = p_org_id
        AND NVL(I.PROCESS_STATUS, -1) < 1
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID
        AND ( I.BUNDLE_ID IS NULL OR I.BUNDLE_ID = c_bundle_id )
      ORDER BY AGV.ATTR_GROUP_ID;

    --------------------------------------------------
    -- SAME CURSORS AS ABOVE MODIFIED FOR PDH ITEMS --
    --------------------------------------------------

    ------------------------------------------------------------
    -- CURSOR TO GET THE USER DEFINED ATTRIBUTE GROUPS
    -- PRESENT IN THE INTERFACE TABLE FOR A PDH ITEM
    ------------------------------------------------------------
    CURSOR cr_attr_groups_pdh(c_revision IN VARCHAR2) IS
      SELECT DISTINCT
        I.ATTR_GROUP_INT_NAME,
        I.REVISION,
        AG.DATA_LEVEL_INTERNAL_NAME,             -- R12C: Added
        AG.DATA_LEVEL_ID,               -- R12C: Added
        AG.ATTR_GROUP_DISP_NAME,
        AG.ATTR_GROUP_ID,
        AG.VIEW_PRIVILEGE_ID
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTR_GROUPS_DL_V AG
      WHERE NVL(AG.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND ((I.INVENTORY_ITEM_ID IS NOT NULL AND I.INVENTORY_ITEM_ID = p_item1)
             OR
             (I.ITEM_NUMBER IS NOT NULL AND I.ITEM_NUMBER = p_ss_record)
            )
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) <= 1
        AND (REVISION IS NULL OR REVISION = c_revision)
        AND I.ORGANIZATION_ID = p_org_id
        AND I.ATTR_GROUP_INT_NAME = AG.ATTR_GROUP_name
        AND (  I.DATA_LEVEL_ID = AG.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AG.DATA_LEVEL_INTERNAL_NAME )
        AND AG.APPLICATION_ID = 431
        AND AG.MULTI_ROW_CODE = 'N';

    ----------------------------------------------------------------------
    -- CURSOR TO GET USER DEFINED ATTRIBUTES FROM THE INTERFACE TABLE
    -- FOR GIVEN ATTRIBUTE GROUP FOR A PDH ITEM
    ----------------------------------------------------------------------
    CURSOR cr_usr_intf_pdh (c_attr_group_int_name VARCHAR2, p_data_level_id NUMBER) IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.REVISION,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AGV.ATTR_GROUP_DISP_NAME,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AGV.DATA_LEVEL_ID,              -- R12C: Added
        AGV.DATA_LEVEL_INTERNAL_NAME,            -- R12C: Added
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE,
        AV.UOM_CLASS
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND ((I.INVENTORY_ITEM_ID IS NOT NULL AND I.INVENTORY_ITEM_ID = p_item1)
             OR
             (I.ITEM_NUMBER IS NOT NULL AND I.ITEM_NUMBER = p_ss_record)
            )
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.ATTR_GROUP_INT_NAME = c_attr_group_int_name
        AND I.DATA_LEVEL_ID = p_data_level_id
        AND NVL(AGV.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) <= 1
        AND I.REVISION IS NULL
        AND I.ORGANIZATION_ID = p_org_id
        AND (  I.DATA_LEVEL_ID = AGV.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AGV.DATA_LEVEL_INTERNAL_NAME )
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID;


    ------------------------------------------------------
    -- TO GET THE ATTRIBUTES FOR GIVEN ATTRIBUTE GROUP  --
    --    USER DEFINED ATTRIBUTES WITH RIVISION         --
    ------------------------------------------------------
    CURSOR cr_rev_usr_intf_pdh (c_attr_group_int_name VARCHAR2, c_revision VARCHAR2) IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.REVISION,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AGV.ATTR_GROUP_DISP_NAME,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AGV.DATA_LEVEL_ID,              -- R12C: Added
        AGV.DATA_LEVEL_INTERNAL_NAME,            -- R12C: Added
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE,
        AV.UOM_CLASS
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.ATTR_GROUP_INT_NAME = c_attr_group_int_name
        AND NVL(AGV.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = 'EGO_ITEMMGMT_GROUP'
        AND I.DATA_SET_ID = p_batch_id
        AND NVL(I.PROCESS_STATUS, -1) <= 1
        AND I.REVISION = c_revision
        AND ((I.INVENTORY_ITEM_ID IS NOT NULL AND I.INVENTORY_ITEM_ID = p_item1)
             OR
             (I.ITEM_NUMBER IS NOT NULL AND I.ITEM_NUMBER = p_ss_record)
            )
        AND I.ORGANIZATION_ID = p_org_id
        AND (  I.DATA_LEVEL_ID = AGV.DATA_LEVEL_ID
            OR I.DATA_LEVEL_NAME = AGV.DATA_LEVEL_INTERNAL_NAME )
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID;

    -------------------------------------------------------
    -- CURSOR TO GET THE GTIN ATTRIBUTES IN INTERFACE TABLE
    -------------------------------------------------------
    CURSOR cr_dd_intf_pdh IS
      SELECT
        AV.ATTR_ID,
        AGV.ATTR_GROUP_ID,
        I.ATTR_VALUE_STR,
        I.ATTR_VALUE_NUM,
        I.ATTR_VALUE_DATE,
        I.ATTR_DISP_VALUE,
        I.REVISION_ID,
        I.ATTR_VALUE_UOM,
        I.ATTR_UOM_DISP_VALUE,
        AV.ATTR_DISPLAY_NAME,
        AGV.ATTR_GROUP_DISP_NAME,
        AGV.VIEW_PRIVILEGE_ID,
        I.ATTR_INT_NAME ,
        I.ATTR_GROUP_INT_NAME,
        AV.DATABASE_COLUMN,
        AV.VALUE_SET_ID,
        AV.VALIDATION_CODE,
        AV.DATA_TYPE_CODE,
        AV.UOM_CLASS
      FROM
        EGO_ITM_USR_ATTR_INTRFC I,
        EGO_ATTRS_V AV,
        EGO_ATTR_GROUPS_DL_V AGV
      WHERE AV.ATTR_GROUP_NAME = AGV.ATTR_GROUP_NAME
        AND AGV.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS'
        AND AV.ATTR_NAME = I.ATTR_INT_NAME
        AND AV.ATTR_GROUP_NAME = I.ATTR_GROUP_INT_NAME
        AND I.DATA_SET_ID = p_batch_id
        AND ((I.INVENTORY_ITEM_ID IS NOT NULL AND I.INVENTORY_ITEM_ID = p_item1)
             OR
             (I.ITEM_NUMBER IS NOT NULL AND I.ITEM_NUMBER = p_ss_record)
            )
        AND I.organization_id = p_org_id
        AND NVL(I.PROCESS_STATUS, -1) <= 1
        AND AV.APPLICATION_ID = 431
        AND AGV.APPLICATION_ID = AV.APPLICATION_ID
      ORDER BY AGV.ATTR_GROUP_ID;

    CURSOR cr_match_item_rev IS
      SELECT
        INVENTORY_ITEM_ID,
        REVISION_ID,
        SOURCE_SYSTEM_REFERENCE
      FROM EGO_ITEM_MATCHES
      WHERE INVENTORY_ITEM_ID IN (p_item1, p_item2, p_item3, p_item4)
        AND SOURCE_SYSTEM_ID = p_ss_code
        AND SOURCE_SYSTEM_REFERENCE = p_ss_record
        AND BATCH_ID = p_batch_id
        AND ORGANIZATION_id = p_org_id;

    l_compare_tbl            SYSTEM.EGO_COMPARE_VIEW_TABLE ;
    err_compare_tbl          SYSTEM.EGO_COMPARE_VIEW_TABLE ;
    l_compare_REc            SYSTEM.EGO_COMPARE_VIEW_REC;
    err_compare_rec          SYSTEM.EGO_COMPARE_VIEW_REC;
    l_str_value              VARCHAR2(4000);     --EGO_MTL_SY_ITEMS_EXT_B.C_EXT_ATTR40%TYPE;
    l_sel_clause             VARCHAR2(32000);           --keeping the max limit
    l_int_val                VARCHAR2(4000);     --EGO_MTL_SY_ITEMS_EXT_B.C_EXT_ATTR40%TYPE;
    l_val_set_clause         VARCHAR2(12000);           --keeping it that long for safety
    l_sql_query              VARCHAR2(32000);           --keeping the max limit
    l_val                    VARCHAR2(4000);

    l_attr_id                NUMBER;
    l_n_tbl                  NUMBER;
    l_num_value              NUMBER;
    l_ignore                 NUMBER;
    l_cnt                    NUMBER;
    l_count                  NUMBER;
    l_idx                    NUMBER;
    l_start                  NUMBER;

    --varibles for Dynamic Cursors
    cr_ud_attr               INTEGER;
    cr_dd_attr               INTEGER;
    cr_msi_attr              INTEGER;
    cr_msi_intf              INTEGER;

    l_date_value             DATE;
    l_sql_msi                VARCHAR2(32000); --keeping the max limit
    l_default_sel            NUMBER;
    l_item_ID                NUMBER;
    l_temp                   VARCHAR2(50);
    l_col_idx                NUMBER;
    i                        NUMBER;
    l_fmt                    VARCHAR2(1);
    l_disp_val               VARCHAR2(4000);
    l_msii_sql               VARCHAR2(20000);
    l_lkup_str               VARCHAR2(400);
    l_temp_query             VARCHAR2(400);
    l_catalog_id             NUMBER;
    l_hier_catalog_id        NUMBER;
    l_lifecycle_id           NUMBER;
    l_phase_id               NUMBER;
    l_primay_ag_disp_name    FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_primary_ag_int_name    FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_revision               MTL_ITEM_REVISIONS.REVISION%TYPE;
    l_rev_attr_count         NUMBER;
    l_attr_group_display_name VARCHAR2(200);

    -- Variables for Security issues
    l_attGrp_old	VARCHAR2(80);
    l_attGrp_new	VARCHAR2(80);
    l_priv_name		VARCHAR2(480);
    l_priv_item1	VARCHAR2(1);
    l_priv_item2	VARCHAR2(1);
    l_priv_item3	VARCHAR2(1);
    l_priv_item4	VARCHAR2(1);
    l_party_id		VARCHAR2(100);
    l_user_id		NUMBER;
    l_pdh_revision 	VARCHAR(5);
    --Bug#5043002
    TYPE TypeNum IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
    l_inv_rev_id_tbl TypeNum ;
    k NUMBER ;
    l_item_lable                VARCHAR2(50);
    l_itemOrg_lable             VARCHAR2(50);
    l_itemSup_lable             VARCHAR2(50);
    l_itemSupSite_lable         VARCHAR2(50);
    l_itemSupSiteOrg_lable      VARCHAR2(50);
    l_itemRev_lable        VARCHAR2(50);

    --Bug#5043002


    TYPE ATTR_META IS RECORD
          ( ATTR_DISPLAY_NAME    VARCHAR2(240) := ''
           ,ATTR_GROUP_NAME      VARCHAR2(240)
           ,ATTR_ID              NUMBER
           ,VIEW_PRIVILEGE_NAME  VARCHAR2(480)
           ,UOM_CLASS		         VARCHAR2(10)
           ,ATTR_NAME            VARCHAR2(240)
           ,VALUE_SET_ID         NUMBER
           ,VALIDATION_CODE      VARCHAR2(1)
           ,DATA_TYPE_CODE       VARCHAR2(1)
           ,ATTR_GROUP_DISP_NAME VARCHAR2(240)
           ,DATABASE_COLUMN      VARCHAR2(240)
           ,FLAG                 VARCHAR2(1) );
    TYPE ATTR_M_DATA_TBL IS TABLE OF ATTR_META ;
    TYPE   T        IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    TYPE   x        IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE   A        IS TABLE OF VARCHAR2(1000) INDEX BY VARCHAR2(50);
    TYPE   C        IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(50);
    TYPE   UOM_CLASS_NAMES           IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
    TYPE   VALUE_SET_ID_TABLE        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    G_META                  X;
    UOM			        UOM_CLASS_NAMES;
    UOM_USER_CODE   UOM_CLASS_NAMES; --saves UOM code entered by user
    UOM_DISP_VAL    UOM_CLASS_NAMES; --saves UOM display value entered by user.
    VSID        VALUE_SET_ID_TABLE;

    l_attr_data      ATTR_META;
    l_attr_data_tbl  ATTR_M_DATA_TBL;      -- Saves meta data for all attributes
    l_attr_meta_tbl  ATTR_M_DATA_TBL;      -- Saves meta data for attributes for which SS data Exists
    l_p_atr_sql      A ;
    l_ch_policy_tbl  C;
    l_ch_policy      VARCHAR2(100);
    l_is_policy      VARCHAR2(1);
    l_party_id_num   NUMBER;
    l_ss_id          NUMBER;
    is_pdh_batch     BOOLEAN;
    -- This is required to find out index of each row in case we add these
    -- extra rows.
    l_supplier_rows_count   NUMBER; -- Keep Count of number of supplier rows added.
                                    -- If supplierId is passed l_supplier_rows_count :=1
                                    -- if supplierSiteUd is passed l_supplier_rows_count := 2


  BEGIN
    Debug_Message('Starting GET_COMPARED_DATA at - '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    Debug_Message('Parameters are p_ss_code, p_ss_record, p_batch_id, p_mode, p_item1, p_item2, p_item3, p_item4, p_org_Id=');
    Debug_Message(TO_CHAR(p_ss_code)||', '||p_ss_record||', '||TO_CHAR(p_batch_id)||', '||TO_CHAR(p_mode)||
                  ', '||TO_CHAR(p_item1)||', '||TO_CHAR(p_item2)||', '||TO_CHAR(p_item3)||', '||TO_CHAR(p_item4)||', '||TO_CHAR(p_org_Id));
    -- GETTING THE PARTY_ID FOR THE USER --
    l_user_id := FND_GLOBAL.USER_ID;
    BEGIN
      SELECT party_id INTO l_party_id_num
      FROM ego_user_v
      WHERE user_id = l_user_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      err_compare_tbl := SYSTEM.EGO_COMPARE_VIEW_TABLE();
      err_compare_rec := SYSTEM.EGO_COMPARE_VIEW_REC('', '', '','', '', '','', '', '','', '','','','','');
      --err_compare_rec.ATTR_GROUP_DISP_NAME := 'Encountered error, No search conducted';
      err_compare_rec.ATTR_GROUP_DISP_NAME := FND_MESSAGE.GET_STRING('EGO', 'EGO_PERSON_INVALID');
      err_compare_tbl.EXTEND();
      err_compare_tbl(1) := err_compare_rec;
      Debug_Message('Error - '||err_compare_rec.ATTR_GROUP_DISP_NAME);
      Debug_Message('Done GET_COMPARED_DATA with error');
      RETURN err_compare_tbl;
    END;

    l_party_id := 'HZ_PARTY:' || TO_CHAR(l_party_id_num);

    Debug_Message('Party_id = '||l_party_id);

    -- Query for getting the source_system_id to which this item do belong to
    SELECT source_system_id INTO l_ss_id
    FROM ego_import_batches_b
    WHERE batch_id = p_batch_id;

    IF l_ss_id = EGO_IMPORT_PVT.get_pdh_source_system_id THEN
      is_pdh_batch := TRUE;
    ELSE
      is_pdh_batch := FALSE;
    END IF; -- IF p_ss_code = EGO_IMPORT_PVT.get_pdh_source_system_id THEN

    l_is_policy := 'N';
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ERP_MAIN_ATTR_GRP');
    l_primay_ag_disp_name := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ERP_MAIN_ATTR_GRP');
    l_primary_ag_int_name  := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM');
    l_item_lable := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_ORGANIZATION');
    l_itemOrg_lable := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_SUPPLIER');
    l_itemSup_lable := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_SUPPLIR_SITE');
    l_itemSupSite_lable := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_SUPPLIR_SITE_STORE');
    l_itemSupSiteOrg_lable := FND_MESSAGE.GET();
    FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_REVISION');
    l_itemRev_lable := FND_MESSAGE.GET();

    l_compare_tbl := SYSTEM.EGO_COMPARE_VIEW_TABLE();
    l_compare_rec := SYSTEM.EGO_COMPARE_VIEW_REC('', '', '','','','','','','','','','','','','');

    Debug_Message('Processing Item attributes (Primary and Operational) for Source System');
    -- If called form confirmed tab - p_mode = 1
    -- when p_mode is 1, THEN we need to compute the change policy
    -- so finding out the change policy on each item operational attribute group
    IF P_MODE = 1 AND p_item1 IS NOT NULL THEN
      Debug_Message('Mode is 1, so computing the change policy');
      -- getting the item_catalog_group, lifecycle_id and phase_id
      SELECT LIFECYCLE_ID, ITEM_CATALOG_GROUP_ID, CURRENT_PHASE_ID
        INTO l_lifecycle_id, l_catalog_id, l_phase_id
      FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = p_item1
        AND ORGANIZATION_ID = p_org_id;

      IF l_lifecycle_id IS NOT NULL AND l_catalog_id IS NOT NULL THEN
        BEGIN
          SELECT ic.item_catalog_group_id
            INTO l_hier_catalog_id
          FROM mtl_item_catalog_groups_b ic
          WHERE  EXISTS
            (SELECT olc.object_classification_code CatalogId
             FROM  ego_obj_type_lifecycles olc
             WHERE olc.object_id = (select object_id from fnd_objects where obj_name = 'EGO_ITEM')
               AND olc.lifecycle_id = l_lifecycle_id
               AND olc.object_classification_code = ic.item_catalog_group_id
            )
            AND ROWNUM = 1
          CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
          START WITH item_catalog_group_id = l_catalog_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_hier_catalog_id := l_catalog_id;
        END;
      END IF; --IF l_lifecycle_id IS NOT NULL AND l_catalog_id IS NOT NULL THEN

      IF l_hier_catalog_id IS NOT NULL THEN
        l_catalog_id := l_hier_catalog_id;
      END IF; --IF l_hier_catalog_id IS NOT NULL THEN

      Debug_Message('Lifecycle_id, Item_Catalog_Group_Id, Current_Phase_id='||TO_CHAR(l_lifecycle_id)||', '||TO_CHAR(l_catalog_id)||', '||TO_CHAR(l_phase_id));
      IF (l_phase_id IS NOT NULL) THEN
        -- if lifecycle phase is not NULL THEN the Change Policy can exists
        l_is_policy := 'Y';
        -- finding the policy for each operational attribute
        FOR rec in cr_op_attr_grps LOOP
          Debug_Message('Getting change Policy for operational attribute Attr_Group_Id, Attr_Group_Name='||TO_CHAR(rec.ATTR_GROUP_ID)||', '||rec.ATTR_GROUP_NAME);
          ENG_CHANGE_POLICY_PKG.GetChangePolicy
                          (   p_policy_object_name     => 'CATALOG_LIFECYCLE_PHASE'
                           ,  p_policy_code            => 'CHANGE_POLICY'
                           ,  p_policy_pk1_value       =>  l_catalog_id
                           ,  p_policy_pk2_value       =>  l_lifecycle_id
                           ,  p_policy_pk3_value       =>  l_phase_id
                           ,  p_policy_pk4_value       =>  NULL
                           ,  p_policy_pk5_value       =>  NULL
                           ,  p_attribute_object_name  => 'EGO_CATALOG_GROUP'
                           ,  p_attribute_code         => 'ATTRIBUTE_GROUP'
                           ,  p_attribute_value        =>  rec.ATTR_GROUP_ID
                           ,  x_policy_value           =>  l_ch_policy
                           );

          Debug_Message('Change Policy is '||l_ch_policy);
          IF INSTR(l_ch_policy,'NOT') > 0 THEN
            l_ch_policy_tbl(rec.ATTR_GROUP_NAME) :=  'N';
          ELSIF INSTR(l_ch_policy,'ALLOWED') > 0 THEN
            l_ch_policy_tbl(rec.ATTR_GROUP_NAME) :=  'Y';
          ELSIF INSTR(l_ch_policy,'CHANGE') > 0 THEN
            l_ch_policy_tbl(rec.ATTR_GROUP_NAME) :=  'C';
          END IF; -- IF INSTR(l_ch_policy,'NOT') > 0 THEN
        END LOOP; -- FOR rec in cr_op_attr_grps LOOP
      END IF; --IF (l_phase_id IS NOT NULL) THEN
      Debug_Message('Computing Change Policy for operational attribute groups - Done');
    END IF; -- IF P_MODE = 1 AND p_item1 IS NOT NULL THEN

    -- for some item attributes, the display value does not comes from value set
    -- but comes from some specific SQLs. So storing these SQLs in local array
    l_lkup_str :=' SELECT  F.MEANING '||
                 ' FROM FND_LOOKUP_VALUES F'||
                 ' WHERE F.LANGUAGE = USERENV(''LANG'')'||
                 ' AND F.LOOKUP_TYPE = ';

    l_p_atr_sql('ITEM_TYPE')                 := l_lkup_str ||  ' ''ITEM_TYPE''' ||
                                                ' AND F.LOOKUP_CODE = ';
    l_p_atr_sql('ALLOWED_UNITS_LOOKUP_CODE') := l_lkup_str || '''MTL_CONVERSION_TYPE'' ' ||
                                                ' AND F.LOOKUP_CODE = ';
    l_p_atr_sql('ONT_PRICING_QTY_SOURCE')    := l_lkup_str || '''INV_PRICING_UOM_TYPE'' ' ||
                                                ' AND F.LOOKUP_CODE = ';
    l_p_atr_sql('SECONDARY_DEFAULT_IND')     := l_lkup_str || '''INV_DEFAULTING_UOM_TYPE'' ' ||
                                                ' AND F.LOOKUP_CODE = ';
    l_p_atr_sql('TRACKING_QUANTITY_IND')     := l_lkup_str || '''INV_TRACKING_UOM_TYPE'' ' ||
                                                ' AND F.LOOKUP_CODE = ';

    l_p_atr_sql('PRIMARY_UOM_CODE')          := ' SELECT UOMTL.UNIT_OF_MEASURE_TL '||
                                                ' FROM MTL_UNITS_OF_MEASURE_TL UOMTL' ||
                                                ' WHERE UOMTL.LANGUAGE = USERENV(''LANG'') ' ||
                                                ' AND UOMTL.UOM_CODE = ';
    l_p_atr_sql('SECONDARY_UOM_CODE')        :=   l_p_atr_sql('PRIMARY_UOM_CODE');

    l_p_atr_sql('UOM_CODE')                  :=  l_p_atr_sql('PRIMARY_UOM_CODE') || ':1';

    l_p_atr_sql('UOM_CLASS')			           :=  ' SELECT UOMTL.UNIT_OF_MEASURE_TL '||
                                                 ' FROM MTL_UNITS_OF_MEASURE_TL UOMTL' ||
                                                 ' WHERE UOMTL.LANGUAGE = USERENV(''LANG'') ' ||
                                                 '   AND UOMTL.BASE_UOM_FLAG = ''Y''' ||
                                   					     '   AND UOMTL.UOM_CLASS = :1 ';

    l_p_atr_sql('ITEM_CATALOG_GROUP_ID')     := ' SELECT ICGKFV.CONCATENATED_SEGMENTS ' ||
                                                ' FROM MTL_ITEM_CATALOG_GROUPS_B_KFV ICGKFV ' ||
                                                ' WHERE ICGKFV.ITEM_CATALOG_GROUP_ID = ' ;
    l_p_atr_sql('CURRENT_PHASE_ID')          := ' SELECT LCP.NAME '||
                                                ' FROM PA_EGO_LIFECYCLES_PHASES_V LCP '||
                                                ' WHERE LCP.OBJECT_TYPE = ''PA_TASKS'' '||
                                                '   AND LCP.PROJ_ELEMENT_ID = ';
    l_p_atr_sql('LIFECYCLE_ID')              := ' SELECT LC.NAME ' ||
                                                ' FROM PA_EGO_LIFECYCLES_PHASES_V LC ' ||
                                                ' WHERE LC.OBJECT_TYPE = ''PA_STRUCTURES'''||
                                                '   AND LC.PROJ_ELEMENT_ID = ' ;

    l_p_atr_sql('LONG_DESCRIPTION')          := ' SELECT ITL.LONG_DESCRIPTION '||
                                                ' FROM MTL_SYSTEM_ITEMS_TL ITL '||
                                                ' WHERE ITL.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID '||
                                                '   AND ITL.ORGANIZATION_ID = I.ORGANIZATION_ID '||
                                                '   AND ITL.LANGUAGE = USERENV(''LANG'') ';
    l_p_atr_sql('DESCRIPTION')               := ' SELECT ITL.DESCRIPTION '||
                                                ' FROM MTL_SYSTEM_ITEMS_TL ITL '||
                                                ' WHERE ITL.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID '||
                                                '   AND ITL.ORGANIZATION_ID = I.ORGANIZATION_ID '||
                                                '   AND ITL.LANGUAGE = USERENV(''LANG'')  ';
    l_p_atr_sql('ITEM_NUMBER')                := ' I.CONCATENATED_SEGMENTS ';
    l_p_atr_sql('TRADE_ITEM_DESCRIPTOR')      := ' SELECT DISPLAY_NAME ' ||
                                                 ' FROM EGO_VALUE_SET_VALUES_V ' ||
                                                 ' WHERE VALUE_SET_NAME = ''TradeItemDescVS'' ' ||
                                                 '   AND INTERNAL_NAME = ';

    l_p_atr_sql('STYLE_ITEM_FLAG')            := l_lkup_str || ' ''EGO_YES_NO'' ' ||
                                                 ' AND F.LOOKUP_CODE = ';

    l_p_atr_sql('STYLE_ITEM_NUMBER')          :=  '( SELECT CONCATENATED_SEGMENTS ' ||
                                                  '  FROM MTL_SYSTEM_ITEMS_KFV MSIKFV ' ||
                                                  '  WHERE MSIKFV.INVENTORY_ITEM_ID = I.STYLE_ITEM_ID ' ||
                                                  '    AND MSIKFV.ORGANIZATION_ID = I.ORGANIZATION_ID '||
                                                  ') ';

    l_p_atr_sql('GDSN_OUTBOUND_ENABLED_FLAG') := l_lkup_str || ' ''EGO_YES_NO'' ' ||
                                                 ' AND F.LOOKUP_CODE = ';

    l_p_atr_sql('INVENTORY_ITEM_STATUS_CODE'):= ' SELECT INVENTORY_ITEM_STATUS_CODE_TL ' ||
                                                ' FROM mtl_item_status  ' ||
                                                ' WHERE INVENTORY_ITEM_STATUS_CODE = ' ;
    l_default_sel := 0;
    l_attr_data_tbl :=  ATTR_M_DATA_TBL();
    l_attr_meta_tbl :=  ATTR_M_DATA_TBL();
    l_msii_sql := 'SELECT INVENTORY_ITEM_ID  ';
    l_default_sel := 1;

    -------------------------------------------------------------------------------
    -- Getting meda data for primary attributes
    -- Saving the meta data about each attribute in meta data table l_attr_data_tbl
    -- Based on this metadata, also preparing the query l_msii_sql for getting data
    -- from interface and production table
    -------------------------------------------------------------------------------
    Debug_Message('Started getting metadata for Primary Attributes');
    FOR l_pr_attr_rec IN cr_primary_attr LOOP
      l_attr_data_tbl.extend();
      l_attr_data.ATTR_DISPLAY_NAME := l_pr_attr_rec.MEANING;
      --Debug_Message('Primary Attribute - ' || l_attr_data.ATTR_DISPLAY_NAME);
      -- Saving value set ids for primary attributes in meta data table
      IF l_pr_attr_rec.LOOKUP_CODE IN ('DUAL_UOM_DEVIATION_HIGH', 'DUAL_UOM_DEVIATION_LOW', 'CREATION_DATE', 'CREATED_BY') THEN
        l_attr_data.VALUE_SET_ID := 0;     -- VALUE SET DOES NOT EXISTS
      ELSE
        l_attr_data.VALUE_SET_ID := -1;     -- NO VALUE SET, but display value comes from special SQLs
      END IF; -- IF l_pr_attr_rec.LOOKUP_CODE IN ('DUAL

      -- Saving data type code in meta data table
      IF l_pr_attr_rec.LOOKUP_CODE IN ('ITEM_TYPE', 'DESCRIPTION', 'LONG_DESCRIPTION', 'APPROVAL_STATUS',
	                                     'INVENTORY_ITEM_STATUS_CODE', 'ONT_PRICING_QTY_SOURCE',
					                             'PRIMARY_UOM_CODE', 'SECONDARY_DEFAULT_IND', 'SECONDARY_UOM_CODE',
                            					 'TRACKING_QUANTITY_IND', 'ALLOWED_UNITS_LOOKUP_CODE',
                                       'ITEM_CATALOG_GROUP_ID', 'CURRENT_PHASE_ID', 'LIFECYCLE_ID' ,
                                       'TRADE_ITEM_DESCRIPTOR', 'STYLE_ITEM_FLAG', 'STYLE_ITEM_NUMBER' ,
                                       'GDSN_OUTBOUND_ENABLED_FLAG' ) THEN
        l_attr_data.DATA_TYPE_CODE := G_CHAR_FORMAT;
      ELSIF l_pr_attr_rec.LOOKUP_CODE IN ('CREATION_DATE') THEN
        l_attr_data.DATA_TYPE_CODE := G_DATE_FORMAT;
      ELSE
        l_attr_data.DATA_TYPE_CODE := G_NUMBER_FORMAT;
      END IF; -- IF l_pr_attr_rec.LOOKUP_CODE IN

      l_attr_data.ATTR_GROUP_DISP_NAME := l_primay_ag_disp_name;
      l_attr_data.ATTR_GROUP_NAME := l_primary_ag_int_name;
      l_attr_data.DATABASE_COLUMN := l_pr_attr_rec.LOOKUP_CODE;
      l_attr_data.FLAG :=   'N';
	    l_attr_data.VIEW_PRIVILEGE_NAME	:= 'NOTAPPLICABLE';
      l_attr_data_tbl(l_attr_data_tbl.LAST) := l_attr_data;
      l_msii_sql := l_msii_sql || ', ' || l_pr_attr_rec.LOOKUP_CODE ;
    END LOOP; -- FOR l_pr_attr_rec IN cr_primary_attr LOOP
    Debug_Message('Done getting metadata for Primary Attributes');

    ------------------------------------------------------------------------------
    -- Get meta data for operational attributes.
    -- Saving the meta data about each attribute in meta data table l_attr_data_tbl
    -- Based on this metadata, also preparing the query l_msii_sql for getting data
    -- from interface and production table
    -------------------------------------------------------------------------------
    Debug_Message('Started getting metadata for Operational Attributes');
    FOR l_attr_name_rec IN cr_attr_info LOOP
      l_attr_data_tbl.extend();
      l_attr_data.ATTR_DISPLAY_NAME := l_attr_name_rec.ATTR_DISPLAY_NAME;
      l_attr_data.VALUE_SET_ID := NVL(l_attr_name_rec.VALUE_SET_ID, 0);
      l_attr_data.VALIDATION_CODE := l_attr_name_rec.VALIDATION_CODE ;
      l_attr_data.DATA_TYPE_CODE := l_attr_name_rec.DATA_TYPE_CODE;
      l_attr_data.ATTR_GROUP_DISP_NAME := l_attr_name_rec.ATTR_GROUP_DISP_NAME;
      l_attr_data.ATTR_GROUP_NAME := l_attr_name_rec.ATTR_GROUP_NAME;
      l_attr_data.DATABASE_COLUMN := l_attr_name_rec.DATABASE_COLUMN;
      l_attr_data.FLAG := 'N';
	    l_attr_data.VIEW_PRIVILEGE_NAME	:= 'NOTAPPLICABLE';
      l_attr_data.UOM_CLASS	:= l_attr_name_rec.UOM_CLASS;
      l_attr_data.ATTR_NAME := l_attr_name_rec.ATTR_NAME;
      l_attr_data.ATTR_ID := l_attr_name_rec.ATTR_ID;
      l_attr_data_tbl(l_attr_data_tbl.LAST) := l_attr_data;
      l_msii_sql := l_msii_sql || ', ' || l_attr_name_rec.DATABASE_COLUMN ;
    END LOOP; -- FOR l_attr_name_rec IN cr_attr_info LOOP
    Debug_Message('Done getting metadata for Operationl Attributes');

    -- Preaparing dynamic sql cursor from query l_msii_sql
    -- to get data from interface table
    Debug_Message('Preparing SQL to get data from interface table for item primary and operational attributes.');
    cr_msi_intf := DBMS_SQL.OPEN_CURSOR;

    -- if the batch is PDH batch
    -- we need to match inventory_item_id or item number in interface table
    -- with the p_item1 or p_ss_record
    IF is_pdh_batch THEN
      -- PDH item
      Debug_Message('Prepared query for Primary and Operational Attributes for PDH item');
      l_msii_sql := l_msii_sql || ' FROM MTL_SYSTEM_ITEMS_INTERFACE I '
                               || ' WHERE ORGANIZATION_ID = :1'
                               || '   AND SET_PROCESS_ID = :2 '
                               || '   AND ((I.INVENTORY_ITEM_ID IS NOT NULL AND I.INVENTORY_ITEM_ID = :3) '
                               || '      OR '
                               || '        (I.ITEM_NUMBER IS NOT NULL AND I.ITEM_NUMBER = :4)) '
                  			       || '   AND NVL(PROCESS_FLAG, -1) <= 1 ' ;


    ELSE
      --  NON PDH item
      Debug_Message('Prepared query for Primary and Operational Attributes for NON-PDH item');
      l_msii_sql := l_msii_sql || ' FROM MTL_SYSTEM_ITEMS_INTERFACE I '
                               || ' WHERE ORGANIZATION_ID = :1'
                               || '   AND SOURCE_SYSTEM_ID = :2 '
                               || '   AND SOURCE_SYSTEM_REFERENCE = :3'
                               || '   AND SET_PROCESS_ID = :4 '
	                             || '   AND NVL(PROCESS_FLAG, -1) < 1 ' ;
      -- Adding bundleId only in case bundleId is passed.
      IF p_bundle_id IS NOT NULL THEN
        l_msii_sql := l_msii_sql || ' AND BUNDLE_ID = :5 ';
      END IF;
    END IF; --IF is_pdh_batch THEN

    Debug_Message('SQL is - ');
    FOR l in 1..(CEIL(LENGTH(l_msii_sql)/1000)) LOOP
      Debug_Message(SUBSTR(l_msii_sql, ((l-1)*1000) + 1, 1000));
    END LOOP; --FOR l in 1..(CEIL(LENGTH(l_msii_sql)/1000)) LOOP

    Debug_Message('Parsing the SQL');
    DBMS_SQL.PARSE(cr_msi_intf, l_msii_sql, DBMS_SQL.native);
    Debug_Message('Done Parsing the SQL');

    -- Defining columns for l_msii_sql
    -- First column will be number as l_msii_sql has inventory_item_id as first selected column always.
    -- depending on the metadata of primary and operational attributes, we define here the type of column
    Debug_Message('Defining columns of SQL');
    DBMS_SQL.DEFINE_COLUMN(cr_msi_intf ,1 ,l_num_value);
    l_count := l_attr_data_tbl.LAST;
    Debug_Message('Total columns = '||TO_CHAR(l_count));
    FOR i IN 1..l_count LOOP
      l_fmt := l_attr_data_tbl(i).DATA_TYPE_CODE ;
      IF l_fmt = G_NUMBER_FORMAT THEN
        DBMS_SQL.DEFINE_COLUMN(cr_msi_intf, i + l_default_sel, l_num_value);
      ELSIF l_fmt = G_CHAR_FORMAT THEN
        DBMS_SQL.DEFINE_COLUMN(cr_msi_intf, i + l_default_sel, l_str_value, 4000);
      ELSIF l_fmt = G_TIME_FORMAT OR l_fmt = G_DATE_TIME_FORMAT THEN
        DBMS_SQL.DEFINE_COLUMN(cr_msi_intf, i + l_default_sel, l_date_value);
      END IF; --IF l_fmt = G_NUMBER_FORMAT THEN
    END LOOP; --FOR i IN 1..l_count LOOP
    Debug_Message('Done defining columns of SQL');

    Debug_Message('Binding variables');
    -- Binding Variables to query.
    IF is_pdh_batch THEN
      -- For PDH item.
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':1', p_org_Id);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':2', p_batch_id);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':3', p_item1);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':4', p_ss_record);
    ELSE
      -- Non PDH Item.
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':1', p_org_Id);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':2', p_ss_code);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':3', p_ss_record);
      DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':4', p_batch_id);
      IF p_bundle_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(cr_msi_intf, ':5', p_bundle_id);
      END IF;
    END IF; --IF is_pdh_batch THEN
    Debug_Message('Done Binding variables');

    l_ignore := DBMS_SQL.EXECUTE(cr_msi_intf);
    Debug_Message('Query Execution Complete');

    ------------------------------------------------------------------------------------
    -- While finding Privileges of the user upon items, do find privilege one time    --
    -- for all attributes in an attribute group. Since the attributes are all ordered --
    -- by attribute group, We compare the earlier attribute group with present one    --
    -- and if they are same there is no need to recalculate the privileges --- for    --
    -- which l_attrGrp_old and l_attrGrp_new are used                                 --
    ------------------------------------------------------------------------------------

    l_attGrp_old := '';

    -----------------------------------------------------------------
    -- Fetch Source System Data and keep entering in l_compare_tbl --
    -- Since it is required to enter data for other items we do    --
    -- keep required meta data for the attributes for which source --
    -- system data is not NULL.                                    --
    -----------------------------------------------------------------
    Debug_Message('Fetching the Rows');
    WHILE DBMS_SQL.FETCH_ROWS(cr_msi_intf) > 0  LOOP
      -- for each column defined previously, get the value of column in l_disp_val

      -- Inserting rows for Supplier and SupplierSite in case we are showing
      -- any supplier and supplier site information
      l_supplier_rows_count := 0;

      IF  p_supplier_id IS NOT NULL THEN
        l_supplier_rows_count := l_supplier_rows_count + 1;
        l_compare_tbl.extend();
        FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_SUPPLIER');
        l_compare_rec.ATTR_GROUP_DISP_NAME := FND_MESSAGE.GET();
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SUPPLIER_NAME');
        l_compare_rec.ATTR_DISP_NAME        := FND_MESSAGE.GET();
        -- Get the supplier Information
        l_temp_query := 'SELECT VENDOR_NAME FROM PO_VENDORS WHERE VENDOR_ID = :1 ';
        EXECUTE IMMEDIATE l_temp_query into l_temp using p_supplier_id;
        l_compare_rec.SOURCE_SYS_VAL        := l_temp;
        l_compare_rec.ITEM1                 := l_temp;
        l_compare_rec.ITEM2                 := l_temp;
        l_compare_rec.ITEM3                 := l_temp;
        l_compare_rec.ITEM4                 := l_temp;
        l_compare_rec.PRIV_ITEM1            := 'T';
        l_compare_rec.PRIV_ITEM2            := 'T';
        l_compare_rec.PRIV_ITEM3            := 'T';
        l_compare_rec.PRIV_ITEM4            := 'T';
        l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
      END IF;

      IF p_supplier_site_id IS NOT NULL THEN
        l_supplier_rows_count := l_supplier_rows_count + 1;
        l_compare_tbl.extend();
        FND_MESSAGE.SET_NAME('EGO', 'EGO_ITEM_SUPPLIR_SITE');
        l_compare_rec.ATTR_GROUP_DISP_NAME := FND_MESSAGE.GET();
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SUPPLIER_SITE');
        l_compare_rec.ATTR_DISP_NAME        := FND_MESSAGE.GET();
        -- Get the supplier Information
        l_temp_query := 'SELECT VENDOR_SITE_CODE FROM    PO_VENDOR_SITES_ALL WHERE  VENDOR_SITE_ID = :1 ';
        EXECUTE IMMEDIATE l_temp_query into l_temp using p_supplier_site_id;
        l_compare_rec.SOURCE_SYS_VAL        := l_temp;
        l_compare_rec.ITEM1                 := l_temp;
        l_compare_rec.ITEM2                 := l_temp;
        l_compare_rec.ITEM3                 := l_temp;
        l_compare_rec.ITEM4                 := l_temp;
        l_compare_rec.PRIV_ITEM1            := 'T';
        l_compare_rec.PRIV_ITEM2            := 'T';
        l_compare_rec.PRIV_ITEM3            := 'T';
        l_compare_rec.PRIV_ITEM4            := 'T';
        l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
      END IF;

      FOR i IN 1..l_count LOOP
        l_fmt := l_attr_data_tbl(i).DATA_TYPE_CODE ;
        IF l_fmt = G_NUMBER_FORMAT THEN
          DBMS_SQL.COLUMN_VALUE(cr_msi_intf, i+l_default_sel, l_num_value);
          l_disp_val := TO_CHAR(l_num_value);
        ELSIF l_fmt = G_CHAR_FORMAT THEN
          DBMS_SQL.COLUMN_VALUE(cr_msi_intf, i +l_default_sel, l_str_value);
          l_disp_val := l_str_value;
        ELSIF l_fmt = G_TIME_FORMAT OR l_fmt = G_DATE_TIME_FORMAT THEN
          DBMS_SQL.COLUMN_VALUE(cr_msi_intf, i+l_default_sel, l_date_value);
          l_disp_val := TO_CHAR(l_date_value, 'MM/DD/YYYY HH24:MI:SS');
        END IF; -- IF l_fmt = G_NUMBER_FORMAT THEN

        IF l_disp_val IS NOT NULL THEN
          --Debug_Message('Source System Data for Attribute - Value are ' || l_attr_data_tbl(i).ATTR_DISPLAY_NAME ||' - '|| l_disp_val);
          -- Set the flag=Y in the meta data table indicating the source system data is present
          -- for this attribute.
          l_attr_data_tbl(i).FLAG := 'Y';
          l_compare_tbl.extend();
          -- Since there exists data for this attribute for Source System
          -- Save the meta data so that we can use this when retrieving data from production table.
          l_attr_meta_tbl.extend();
          l_attr_meta_tbl(l_attr_meta_tbl.LAST) := l_attr_data_tbl(i);
          l_compare_rec.ATTR_GROUP_DISP_NAME := l_attr_data_tbl(i).ATTR_GROUP_DISP_NAME ;
          l_compare_rec.ATTR_DISP_NAME := l_attr_data_tbl(i).ATTR_DISPLAY_NAME ;

          -- for each attribute group there can be a privilege attached
          -- so, finding if user has privilege for this attribute group
          -- Setting properly the privilege (either T or F) in compare table
	        l_attGrp_new := l_attr_data_tbl(i).ATTR_GROUP_DISP_NAME;
	        l_priv_name := l_attr_data_tbl(i).VIEW_PRIVILEGE_NAME;
	        IF(l_priv_name IS NULL OR l_priv_name = 'NOTAPPLICABLE') THEN
	          l_priv_item1 := 'T';
	          l_priv_item2 := 'T';
	          l_priv_item3 := 'T';
	          l_priv_item4 := 'T';
	        ELSIF(l_attGrp_old <> l_attGrp_new) THEN
	          l_priv_item1 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item1,
							              p_org_Id, NULL, NULL, NULL, l_party_id);
	          l_priv_item2 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item2,
						              	p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item3 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item3,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item4 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item4,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
          END IF; --IF(l_priv_name IS NULL OR l_priv_name = 'NOTAPPLICABLE') THEN

          l_attGrp_old := l_attGrp_new;
          l_compare_rec.PRIV_ITEM1 := l_priv_item1;
          l_compare_rec.PRIV_ITEM2 := l_priv_item2;
          l_compare_rec.PRIV_ITEM3 := l_priv_item3;
          l_compare_rec.PRIV_ITEM4 := l_priv_item4;

          Debug_Message('Value Set for this attribute is ' || TO_CHAR(l_attr_data_tbl(i).VALUE_SET_ID));
          -- if a value set is attached to an attribute, THEN getting its display value and storing
          -- that value in compare_table. Because we need to display the display values
          -- value_set_id = 0 means value set is not associated
          -- value_set_id = -1 means value set is not associated, but there is some other SQL to get the
          -- display value. We have already stored such SQLs in l_p_atr_sql
          -- value set is not associated for columns 'DESCRIPTION','ITEM_NUMBER', 'LONG_DESCRIPTION'
          IF l_attr_data_tbl(i).VALUE_SET_ID = -1
            AND l_attr_data_tbl(i).DATABASE_COLUMN NOT IN ('DESCRIPTION', 'ITEM_NUMBER', 'LONG_DESCRIPTION', 'APPROVAL_STATUS', 'CREATION_DATE' ,
                                                           'STYLE_ITEM_NUMBER' )
          THEN
            -- Value set not associated but there is some other SQL to get the
            -- display value. We have already stored such SQLs in l_p_atr_sql
            l_temp_query := l_p_atr_sql(l_attr_data_tbl(i).DATABASE_COLUMN) || ' :1';
            EXECUTE IMMEDIATE l_temp_query into l_temp using l_disp_val;
            l_compare_rec.source_sys_val := l_temp;
            Debug_Message('Value in the View table for this Attribute - '|| l_temp);
          ELSIF l_attr_data_tbl(i).VALUE_SET_ID = -1
            OR l_attr_data_tbl(i).VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE --G_NUMBER_FORMAT
            OR l_attr_data_tbl(i).DATABASE_COLUMN IN ( 'DESCRIPTION','ITEM_NUMBER', 'LONG_DESCRIPTION', 'APPROVAL_STATUS', 'CREATION_DATE',
                                                       'STYLE_ITEM_FLAG' , 'STYLE_ITEM_NUMBER', 'GDSN_OUTBOUND_ENABLED_FLAG',
                                                       'TRADE_ITEM_DESCRIPTOR' )
          THEN
            -- Value set not associated Or NO Validation required.
            l_compare_rec.source_sys_val := l_disp_val;
            Debug_Message('Value in the View table for this Attribute - '||l_disp_val);
          ELSIF l_attr_data_tbl(i).VALUE_SET_ID <> 0 THEN
            --Value set is associated.
            l_temp := Get_SS_Data_For_Val_set
                            ( p_value_set_id     =>  l_attr_data_tbl(i).VALUE_SET_ID
                             ,p_validation_code  =>  l_attr_data_tbl(i).VALIDATION_CODE
                             ,p_str_val          =>  l_disp_val);
            IF l_temp IS NOT NULL THEN
              l_compare_rec.source_sys_val := l_temp;
            ELSE
              l_compare_rec.source_sys_val := l_disp_val;
            END IF; --IF l_temp IS NOT NULL THEN
            Debug_Message('Value in the View table for this Attribute - '|| l_compare_rec.SOURCE_SYS_VAL);
          ELSE
            l_compare_rec.source_sys_val := l_disp_val;
            Debug_Message('Value in the View table for this Attribute - '|| l_disp_val);
          END IF; --IF l_attr_data_tbl(i).VALUE_SET_ID = -1

          -- If UOM class is associated with this attribute THEN appending base Unit Of Measure to the value
          IF(l_attr_data_tbl(i).UOM_CLASS IS NOT NULL) THEN
	          l_temp_query := l_p_atr_sql('UOM_CLASS');
	          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING l_attr_data_tbl(i).UOM_CLASS;
		        l_compare_rec.source_sys_val := l_disp_val || ' ' || l_temp;
	        END IF; --IF(l_attr_data_tbl(i).UOM_CLASS is not NULL) THEN

          IF l_is_policy = 'Y' AND  --Change policy needs to be populated
            (l_attr_data_tbl(i).ATTR_GROUP_NAME <> l_primary_ag_int_name)
          THEN
            l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(l_attr_data_tbl(i).ATTR_GROUP_NAME);
          END IF; --IF l_is_policy = 'Y' AND

          l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
        END IF; --IF l_disp_val IS NOT NULL THEN
      END LOOP; --FOR i IN 1..l_count LOOP
      Debug_Message('Completed Entering records for Source System');
    END LOOP; --WHILE DBMS_SQL.FETCH_ROWS(cr_msi_intf) > 0  LOOP
    DBMS_SQL.close_cursor(cr_msi_intf);

    Debug_Message('Done processing Item attributes (Primary and Operational) for Source System');
    Debug_Message('Processing Item attributes (Primary and Operational) for Production Items');
    -- Building query to get values from production table MTL_SYSTEM_ITEMS
    l_default_sel := 0; -- To keep track of total number of attributes in Compare Table

    -- If atleast one attribute for Source System item is populated
    -- in l_compare_tbl, Proceed to fill table for other items
    Debug_Message('Number of attributes populated for Source System item in Compare Table - ' || TO_CHAR(l_compare_tbl.LAST));
    IF (l_compare_tbl.LAST > 0) THEN
      Debug_Message('Preparing SQL for Primary and Operational attributes of Production Items ');
      l_sql_msi := 'SELECT I.INVENTORY_ITEM_ID AS INVENTORY_ITEM_ID ' ;
      l_default_sel := l_default_sel + 1;
      l_col_idx := 1;
      FOR i in 1..l_count LOOP
        Debug_Message('Primary Attr : ' || l_attr_data_tbl(i).DATABASE_COLUMN );
        -- If source system contains some value for this attribute the FLAG would be Y
        IF l_attr_data_tbl(i).FLAG = 'Y' THEN
          G_META(l_col_idx + l_default_sel) := l_attr_data_tbl(i).DATA_TYPE_CODE;
          IF l_attr_data_tbl(i).VALUE_SET_ID = -1 THEN
            --Primary attribute
            l_sql_msi := l_sql_msi || ' , ( '||l_p_atr_sql(l_attr_data_tbl(i).DATABASE_COLUMN);
            IF l_attr_data_tbl(i).DATABASE_COLUMN NOT IN ('DESCRIPTION','ITEM_NUMBER', 'LONG_DESCRIPTION' ,
                                                          'STYLE_ITEM_NUMBER' ) THEN
              l_sql_msi := l_sql_msi ||'I.'||l_attr_data_tbl(i).DATABASE_COLUMN ;
            END IF; -- IF l_attr_data_tbl(i).DATABASE_COLUMN NOT IN ('DESCRIPTION
            l_sql_msi := l_sql_msi ||')AS '|| l_attr_data_tbl(i).DATABASE_COLUMN;
          ELSE
            l_sql_msi :=  l_sql_msi || ' , '||  ' I.'||l_attr_data_tbl(i).DATABASE_COLUMN;
          END IF; --IF l_attr_data_tbl(i).VALUE_SET_ID = -1 THEN

	        -- Saving Unit Of Measure UOM Class associated with this attribute in UOM table
          IF (l_attr_data_tbl(i).UOM_CLASS IS NOT NULL) THEN
	          UOM(l_col_idx+ l_default_sel) := l_attr_data_tbl(i).UOM_CLASS;
	        ELSE
	          UOM(l_col_idx+ l_default_sel) := NULL;
	        END IF; --IF (l_attr_data_tbl(i).UOM_CLASS IS NOT NULL) THEN
          l_col_idx := l_col_idx + 1;
        END IF; --IF l_attr_data_tbl(i).FLAG = 'Y' THEN
      END LOOP; --FOR i in 1..l_count LOOP

      -- if the batch is PDH batch
      -- we need to bind only one inventory_item_id
      IF is_pdh_batch THEN
        -- PDH Case
        l_sql_msi := l_sql_msi || ' FROM MTL_SYSTEM_ITEMS_B_KFV I '
                               || ' WHERE INVENTORY_ITEM_ID = :1 '
                               || '   AND ORGANIZATION_ID = :2';
      ELSE
        -- Non PDH Case
        l_sql_msi := l_sql_msi || ' FROM MTL_SYSTEM_ITEMS_B_KFV I '
                               || ' WHERE INVENTORY_ITEM_ID IN( :1,:2,:3,:4 ) '
                               || '   AND ORGANIZATION_ID = :5';
      END IF; --IF is_pdh_batch THEN

      Debug_Message('Done preparing SQL for Primary and Operational attributes of Production Items ');

      Debug_Message('SQL is - ');
      FOR l in 1..(CEIL(LENGTH(l_sql_msi)/1000)) LOOP
        Debug_Message(SUBSTR(l_sql_msi, ((l-1)*1000) + 1, 1000));
      END LOOP; --FOR l in 1..(CEIL(LENGTH(l_sql_msi)/1000)) LOOP

      -- Opening a Dynamic Cursor for handling Query l_sql_msi
      cr_msi_attr := dbms_sql.open_cursor;
      Debug_Message('Parsing the SQL');
      DBMS_SQL.PARSE(cr_msi_attr, l_sql_msi, DBMS_SQL.native);
      Debug_Message('Done parsing the SQL');

      Debug_Message('Binding variables');
      -- Binding the variables
	    IF is_pdh_batch THEN
	      DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':1',p_item1);
        DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':2',p_org_id);
      ELSE
	      DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':1',p_item1);
        DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':2',p_item2);
        DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':3',p_item3);
        DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':4',p_item4);
        DBMS_SQL.BIND_VARIABLE(cr_msi_attr,':5',p_org_id);
      END IF; --IF is_pdh_batch THEN
      Debug_Message('Done binding variables');

      -- First columnn is inventory item id.
      Debug_Message('Defining columns for SQL');
      DBMS_SQL.DEFINE_COLUMN(cr_msi_attr, 1, l_num_value);
      -- Defining Columns for Dynamic Cursor
      Debug_Message('Total columns = '||TO_CHAR(l_col_idx + 1));
      FOR i in 2..l_col_idx LOOP
        IF G_META(i) = G_CHAR_FORMAT THEN
          DBMS_SQL.DEFINE_COLUMN(cr_msi_attr, i, l_str_value, 4000);
        ELSIF G_META(i) = G_NUMBER_FORMAT THEN
          DBMS_SQL.DEFINE_COLUMN(cr_msi_attr, i, l_num_value);
        ELSIF G_META(i) in(G_DATE_FORMAT, G_TIME_FORMAT, G_DATE_TIME_FORMAT) THEN
          DBMS_SQL.DEFINE_COLUMN(cr_msi_attr, i, l_date_value);
        END IF; --IF G_META(i) = G_CHAR_FORMAT THEN
      END LOOP; --FOR i in 2..l_col_idx LOOP

      l_ignore := DBMS_SQL.EXECUTE(cr_msi_attr);
      Debug_Message('Done Execution of the Query');

      Debug_Message('Fetching rows');
      WHILE DBMS_SQL.FETCH_ROWS(cr_msi_attr) > 0 LOOP
        -- first column is inventory_item_id
        Debug_Message('Getting value for inventory_item_id');
        DBMS_SQL.COLUMN_VALUE(cr_msi_attr, 1, l_item_id);
        Debug_Message('Selected Row and started entering into Compare View table for item : ' || TO_CHAR(l_item_id));

        FOR i IN 2..l_col_idx LOOP
          -- for each column get the value into appropriate variable depending upon the format of column
          IF G_META(i) = G_CHAR_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_msi_attr, i, l_str_value);
            l_val := l_str_value;
          ELSIF G_META(i) = G_NUMBER_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_msi_attr, i, l_num_value);
            l_val := TO_CHAR(l_num_value);
          ELSIF G_META(i) = G_DATE_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_msi_attr, i, l_date_value);
            l_val := TO_CHAR(l_date_value, 'MM/DD/YYYY HH24:MI:SS');
          END IF; -- IF G_META(i) = G_CHAR_FORMAT THEN

          -- To populate into the Compare View Table
          IF l_attr_meta_tbl(i-1).VALUE_SET_ID <> -1
              AND l_attr_meta_tbl(i-1).VALUE_SET_ID <> 0
              AND l_attr_meta_tbl(i-1).VALIDATION_CODE <> EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE
          THEN
            Debug_Message('Value Set is associated, so getting display value for internal value: ' || l_val);
            IF(G_META(i) = G_DATE_FORMAT) THEN
              l_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                        431, l_val, NULL, NULL, l_attr_meta_tbl(i-1).ATTR_NAME, 'EGO_MASTER_ITEMS'
                        ,l_attr_meta_tbl(i-1).ATTR_GROUP_NAME, l_attr_meta_tbl(i-1).ATTR_ID
                        ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                        , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            ELSIF (G_META(i) = G_CHAR_FORMAT) THEN
              l_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                        431, NULL, l_val, NULL, l_attr_meta_tbl(i-1).ATTR_NAME, 'EGO_MASTER_ITEMS'
                        ,l_attr_meta_tbl(i-1).ATTR_GROUP_NAME, l_attr_meta_tbl(i-1).ATTR_ID
                        ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                        ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            ELSIF (G_META(i) = G_NUMBER_FORMAT) THEN
              l_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                        431, NULL, NULL, l_val, l_attr_meta_tbl(i-1).ATTR_NAME, 'EGO_MASTER_ITEMS'
                        ,l_attr_meta_tbl(i-1).ATTR_GROUP_NAME, l_attr_meta_tbl(i-1).ATTR_ID
                        ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                        ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            END IF; --IF(G_META(i) = G_DATE_FORMAT) THEN
            Debug_Message('Display value is: ' || l_val);
          END IF; --IF l_attr_meta_tbl(i-1).VALUE_SET_ID <> -1

          -- if UOM class is attached to attribute THEN append the base UOM to the value
	        IF ( UOM(i) IS NOT NULL ) THEN
            -- UOM is associated to this Attribute.
	          l_temp_query := l_p_atr_sql('UOM_CLASS');
	          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING UOM(i);
	          l_val := l_val || ' ' || l_temp;
	        END IF; -- IF ( UOM(i) IS NOT NULL ) THEN

          populate_compare_tbl(p_compare_table => l_compare_tbl ,
                               p_index         => i-1+l_supplier_rows_count,
                               p_sel_item      => l_item_id ,
                               p_value         => l_val ,
                               p_item1         => p_item1 ,
                               p_item2         => p_item2 ,
                               p_item3         => p_item3 ,
                               p_item4         => p_item4);
        END LOOP; --FOR i IN 2..l_col_idx LOOP
      END LOOP; --WHILE DBMS_SQL.FETCH_ROWS(cr_msi_attr) > 0 LOOP
      DBMS_SQL.close_cursor(cr_msi_attr);
      Debug_Message('Completed inserting information for primary and operational attributes for all items');
    END IF; --IF (l_compare_tbl.LAST > 0) THEN
    Debug_Message('Done processing Item attributes (Primary and Operational) for Production Items');

    Debug_Message('Processing User Defined attributes.');
    Debug_Message('Finding out the max revision And Pdh Revi : ' || p_pdh_revision );
    -- To find out if there are any attributes have Revisions associated with them
    IF is_pdh_batch THEN
      -- If the item is of PDH Type
    /*  l_revision := EGO_IMPORT_PVT.GET_LATEST_EIUAI_REV_PDH(
                         p_batch_id                  => p_batch_id
                        ,p_inventory_item_id         => p_item1
                        ,p_item_number               => p_ss_record
                        ,p_organization_id           => p_org_id);*/
      -- l_revision is revision of the source system item.
      -- p_pdh_revision is the revision of the PDH item.
      l_revision := p_pdh_revision;

      -- If l_revision is null or l_revision revision do not present in PDH
      -- l_pdh_revision = production revision. else l_pdh_revision = l_revision.
      IF (p_item1 IS NOT NULL AND
              (  p_pdh_revision IS NULL
                 OR
                   'N' = REV_EXISTS_IN_PDH ( p_revision => p_pdh_revision
                                            ,p_inventory_item_id => p_item1
                                            ,p_organization_id => p_org_id
                             )
              )
         )
      THEN
        l_pdh_revision := GET_CURRENT_PDH_REVISION( p_item1, p_org_id);
      ELSE
        l_pdh_revision := p_pdh_revision;
      END IF;
    ELSE
      -- For NON PDH Type
      l_revision := EGO_IMPORT_PVT.GET_LATEST_EIUAI_REV_SS(
                         p_batch_id                  => p_batch_id
                        ,p_source_system_id          => p_ss_code
                        ,p_source_system_reference   => p_ss_record
                        ,p_organization_id           => p_org_id);
    END IF; --IF is_pdh_batch THEN

    Debug_Message('Max revision is '||l_revision);

    -- Process accessing User Defined attributes one attribute grp at a time
    l_val_set_clause := NULL;

    IF is_pdh_batch THEN
      -- Handling User Defined Attributes for PDH batch
      Debug_Message('Batch is PDH batch ');
      FOR rec_attr IN cr_attr_groups_pdh(l_revision) LOOP
        -- R12C: Show Item_Supplier attributes only if 'Supplier Id' is passed. (Supplier is selected)
        -- R12C: Show Item Supplier site attributes and item supplier site org attributes only if
        --            'Supplier Site Id' is passed.
        -- NOTE: SupplierSiteId do not exist without SupplierId.
        -- Added the following if condition for item intersection support in R12C.
        IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID AND p_supplier_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID AND p_supplier_site_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID AND p_supplier_site_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID IN ( G_ITEM_LEVEL_ID, G_ORG_LEVEL_ID )
        THEN
          Debug_Message('Processing attribute group - '||rec_attr.ATTR_GROUP_INT_NAME);
          -- if change policy may be present THEN get the Change policy for each attr grp
          IF (l_is_policy = 'Y') THEN
            Debug_Message('Getting change policy for attribute group - '||rec_attr.ATTR_GROUP_INT_NAME);
            ENG_CHANGE_POLICY_PKG.GetChangePolicy
                            (   p_policy_object_name     => 'CATALOG_LIFECYCLE_PHASE'
                            ,  p_policy_code            => 'CHANGE_POLICY'
                            ,  p_policy_pk1_value       =>  l_catalog_id
                            ,  p_policy_pk2_value       =>  l_lifecycle_id
                            ,  p_policy_pk3_value       =>  l_phase_id
                            ,  p_policy_pk4_value       =>  NULL
                            ,  p_policy_pk5_value       =>  NULL
                            ,  p_attribute_object_name  => 'EGO_CATALOG_GROUP'
                            ,  p_attribute_code         => 'ATTRIBUTE_GROUP'
                            ,  p_attribute_value        =>  rec_attr.ATTR_GROUP_ID
                            ,  x_policy_value           =>  l_ch_policy
                            );
            Debug_Message('Change Policy for attribute group : '||rec_attr.ATTR_GROUP_INT_NAME || ' is : ' || l_ch_policy );
            IF INSTR(l_ch_policy,'NOT') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) := 'N';
            ELSIF INSTR(l_ch_policy,'ALLOWED') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) := 'Y';
            ELSIF INSTR(l_ch_policy,'CHANGE') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) := 'C';
            END IF; -- IF INSTR(l_ch_policy,'NOT') > 0 THEN
          END IF; --IF (l_is_policy = 'Y') THEN

          l_sel_clause := NULL;
          l_sql_query := NULL;
          l_temp_query := NULL;
          l_idx := 1;
          l_start := NVL(l_compare_tbl.LAST, 0)  ;
          cr_ud_attr := dbms_sql.open_cursor;

          --R12C: Finding attr Group display name with prefix to identify
          -- the Attribute group data level.
          IF rec_attr.DATA_LEVEL_ID = G_ITEM_LEVEL_ID THEN
            l_attr_group_display_name := l_item_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_INTERNAL_NAME = G_ITEM_REVISION_LEVEL THEN
            l_attr_group_display_name := l_itemRev_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ORG_LEVEL_ID THEN
           l_attr_group_display_name := l_itemOrg_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSup_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSupSite_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSupSiteOrg_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          END IF;

	        -- Since Each AG is handled at each time. Find once privileges over all items
          -- of a particular Attribute Group
          Debug_Message('Finding and Populating privilege');
	        l_priv_name := get_privilege_name(rec_attr.VIEW_PRIVILEGE_ID);
	        IF(l_priv_name IS NULL) THEN
	          l_priv_item1 := 'T';
	          l_priv_item2 := 'T';
	          l_priv_item3 := 'T';
	          l_priv_item4 := 'T';
	        ELSE
            l_priv_item1 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item1,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item2 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item2,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item3 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item3,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item4 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item4,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
          END IF; --IF(l_priv_name IS NULL) THEN
          Debug_Message('Done finding and Populating privilege');

          -- If is no revision level records for this attribute group
          IF rec_attr.REVISION IS NULL THEN
            -- For Each attribute Group selected. Get all the attributes in it and
            -- Populate the l_compare_table for these attributes
            -- The cusor cr_usr_intf_pdh returns
            -- Also Perparing Query clause <l_sel_clause> to query for same attributes over other Items.
            l_sql_query := ' FROM EGO_MTL_SY_ITEMS_EXT_VL I, EGO_ATTR_GROUPS_DL_V AG '||
                          ' WHERE AG.APPLICATION_ID = 431  '||
                          '   AND NVL(AG.ATTR_GROUP_TYPE, ''EGO_ITEMMGMT_GROUP'') = ''EGO_ITEMMGMT_GROUP'' '||
                          '   AND AG.ATTR_GROUP_ID = I.ATTR_GROUP_ID'||
                          '   AND I.DATA_LEVEL_ID = :98' ||   -- Added for R12C: Data_level_id
                          '   AND AG.ATTR_GROUP_NAME =  :99'; --Bug#5043002 '' || rec_attr.ATTR_GROUP_INT_NAME ||'''';

            -- R12C: BEGIN
            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96';
            END IF;

            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK2_VALUE = :97';
            END IF;

            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96 AND I.PK2_VALUE = :97';
            END IF;
            -- R12C: END

            Debug_Message('Revision is NULL');
            Debug_Message('Populating all the attribute values for this attribute group for source system');
            FOR rec_ud_attrs IN cr_usr_intf_pdh( rec_attr.ATTR_GROUP_INT_NAME, rec_attr.DATA_LEVEL_ID ) LOOP
              Debug_Message('Processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
              l_idx := l_idx + 1;
              l_compare_tbl.extend();
              l_compare_rec.ATTR_GROUP_DISP_NAME := l_attr_group_display_name;
              l_compare_rec.ATTR_DISP_NAME := rec_ud_attrs.ATTR_DISPLAY_NAME;
              l_compare_rec.ATTRIBUTE_CODE := rec_ud_attrs.ATTR_ID;
              l_compare_rec.ATTR_INT_NAME := rec_ud_attrs.ATTR_INT_NAME;
              l_compare_rec.ATTR_GROUP_INT_NAME := rec_ud_attrs.ATTR_GROUP_INT_NAME;

              -- Setting properly the privilege in compare table. privileges are calculated
              -- for each AG earlier
              l_compare_rec.PRIV_ITEM1 := l_priv_item1;
              l_compare_rec.PRIV_ITEM2 := l_priv_item2;
              l_compare_rec.PRIV_ITEM3 := l_priv_item3;
              l_compare_rec.PRIV_ITEM4 := l_priv_item4;

              -- Saving UOM Class and value set Associated with this attribute
	            UOM(l_idx) := rec_ud_attrs.UOM_CLASS;
              UOM_USER_CODE(l_idx) := rec_ud_attrs.ATTR_VALUE_UOM;
              UOM_DISP_VAL(l_idx) := rec_ud_attrs.ATTR_UOM_DISP_VALUE;

              IF rec_ud_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
                VSId(l_idx) := 0;
              ELSE
                VSId(l_idx) := rec_ud_attrs.VALUE_SET_ID;
              END IF;

              -- getting and setting source system value
              -- If Value set is not associated
              IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is NOT attached');
		            IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'C%' OR rec_ud_attrs.DATABASE_COLUMN LIKE 'T%' THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_STR;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'D%' THEN
                  G_META(l_idx) := G_DATE_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_DATE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'N%' THEN
                  G_META(l_idx) := G_NUMBER_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_NUM;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

                -- Adding column to sql string to get production values
          		  l_sel_clause := l_sel_clause || ' , ' || rec_ud_attrs.DATABASE_COLUMN;
              ELSE
                Debug_Message('Value set is attached');
                -- If Value set is Associated
                l_sel_clause  := l_sel_clause || ' , '|| rec_ud_attrs.DATABASE_COLUMN;
                G_META(l_idx) := SUBSTR(rec_ud_attrs.DATABASE_COLUMN, 1, 1);
                IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                  l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                    ( p_value_set_id    =>  rec_ud_attrs.VALUE_SET_ID
                                                    ,p_validation_code =>  rec_ud_attrs.VALIDATION_CODE
                                                    ,p_str_val         =>  rec_ud_attrs.ATTR_VALUE_STR
                                                    ,p_date_val        =>  rec_ud_attrs.ATTR_VALUE_DATE
                                                    ,p_num_val         =>  rec_ud_attrs.ATTR_VALUE_NUM );
                ELSE
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                Debug_Message('Display value is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN

              -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
                Debug_Message('UOM Display Value is attached');
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_ud_attrs.ATTR_UOM_DISP_VALUE;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
                Debug_Message('UOM code is attached is attached');
                l_temp_query := l_p_atr_sql('UOM_CODE');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.ATTR_VALUE_UOM;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.UOM_CLASS IS NOT NULL THEN
                Debug_Message('UOM Class is attached');
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.UOM_CLASS;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN

              IF l_is_policy = 'Y'  THEN
                l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME);
              END IF; --IF l_is_policy = 'Y'  THEN
              l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
              Debug_Message('Done processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
            END LOOP; --FOR rec_ud_attrs IN cr_usr_intf_pdh(rec_attr.ATTR_GROUP_INT_NAME) LOOP

            l_sql_query := 'SELECT I.INVENTORY_ITEM_ID ' || l_sel_clause || l_sql_query ||
                          '  AND I.INVENTORY_ITEM_ID = :1'||
                          '  AND I.ORGANIZATION_ID = :2';
          ELSE --IF rec_attr.REVISION IS NULL THEN
            -- If there are attributes with Revisions ... Get Attributes in for given Attribute Group.
            l_sql_query := ' FROM EGO_MTL_SY_ITEMS_EXT_VL I, EGO_ATTR_GROUPS_DL_V AG,  MTL_ITEM_REVISIONS_B REV'||
                          ' WHERE AG.APPLICATION_ID = 431  '||
                          '   AND NVL(AG.ATTR_GROUP_TYPE, ''EGO_ITEMMGMT_GROUP'') = ''EGO_ITEMMGMT_GROUP'' '||
                          '   AND AG.ATTR_GROUP_ID = I.ATTR_GROUP_ID'||
			                    '   AND I.INVENTORY_ITEM_ID = REV.INVENTORY_ITEM_ID ' ||
                  			  '   AND I.ORGANIZATION_ID = REV.ORGANIZATION_ID ' ||
			                    '   AND I.REVISION_ID = REV.REVISION_ID ' ||
			                    '   AND REV.REVISION = ''' || l_pdh_revision || '''' ||
			                    '   AND I.DATA_LEVEL_ID = :98' ||
                          '   AND AG.ATTR_GROUP_NAME =  :99' ; --Bug#5043002 '' || rec_attr.ATTR_GROUP_INT_NAME ||'''';

            -- R12C: BEGIN
            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96';
            END IF;

            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK2_VALUE = :97';
            END IF;

            IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
              l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96 AND I.PK2_VALUE = :97';
            END IF;
            -- R12C: END

	          Debug_Message('Revision is NOT NULL, revision is: '||rec_attr.REVISION);
            Debug_Message('Populating all the attribute values for this attribute group for source system');
            FOR rec_ud_attrs IN cr_rev_usr_intf_pdh(rec_attr.ATTR_GROUP_INT_NAME, l_revision) LOOP
              Debug_Message('Processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
              l_idx := l_idx + 1;
              l_compare_tbl.extend();
              l_compare_rec.ATTR_GROUP_DISP_NAME :=  l_attr_group_display_name;
              l_compare_rec.ATTR_DISP_NAME       :=  rec_ud_attrs.ATTR_DISPLAY_NAME;
              l_compare_rec.ATTRIBUTE_CODE       :=  rec_ud_attrs.ATTR_ID;
              l_compare_rec.ATTR_INT_NAME        :=  rec_ud_attrs.ATTR_INT_NAME ;
              l_compare_rec.ATTR_GROUP_INT_NAME  :=  rec_ud_attrs.ATTR_GROUP_INT_NAME;

              -- Setting properly the privilege in compare table. privileges are calculated
              -- for each AG earlier
              l_compare_rec.PRIV_ITEM1 := l_priv_item1;
              l_compare_rec.PRIV_ITEM2 := l_priv_item2;
              l_compare_rec.PRIV_ITEM3 := l_priv_item3;
              l_compare_rec.PRIV_ITEM4 := l_priv_item4;

              -- Saving UOM Class and value set Associated with this attribute
              IF rec_ud_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
                VSId(l_idx) := 0;
              ELSE
                VSId(l_idx) := rec_ud_attrs.VALUE_SET_ID;
              END IF;
	            UOM(l_idx) := rec_ud_attrs.UOM_CLASS;
              UOM_USER_CODE(l_idx) := rec_ud_attrs.ATTR_VALUE_UOM;
              UOM_DISP_VAL(l_idx) := rec_ud_attrs.ATTR_UOM_DISP_VALUE;

              -- getting and setting source system value
              -- If Value set is not associated
              IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is NOT attached');
        		    IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'C%' OR rec_ud_attrs.DATABASE_COLUMN LIKE 'T%' THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_STR;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'D%' THEN
                  G_META(l_idx) := G_DATE_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_DATE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'N%' THEN
                  G_META(l_idx) := G_NUMBER_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_NUM;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

                l_sel_clause := l_sel_clause || ' , ' || rec_ud_attrs.DATABASE_COLUMN;
              ELSE --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is attached');
                l_sel_clause  := l_sel_clause || ' , '|| rec_ud_attrs.DATABASE_COLUMN;
                G_META(l_idx) := SUBSTR(rec_ud_attrs.DATABASE_COLUMN, 1, 1);
                --G_CHAR_FORMAT;
                IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                  l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                        ( p_value_set_id    =>  rec_ud_attrs.VALUE_SET_ID
                                                        ,p_validation_code =>  rec_ud_attrs.VALIDATION_CODE
                                                        ,p_str_val         =>  rec_ud_attrs.ATTR_VALUE_STR
                                                        ,p_date_val        =>  rec_ud_attrs.ATTR_VALUE_DATE
                                                        ,p_num_val         =>  rec_ud_attrs.ATTR_VALUE_NUM );
                ELSE
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                Debug_Message('Display value is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN

              -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
                Debug_Message('UOM Display Value is attached');
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_ud_attrs.ATTR_UOM_DISP_VALUE;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
                Debug_Message('UOM code is attached is attached');
                l_temp_query := l_p_atr_sql('UOM_CODE');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.ATTR_VALUE_UOM;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.UOM_CLASS IS NOT NULL THEN
                Debug_Message('UOM Class is attached');
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.UOM_CLASS;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN

              IF l_is_policy = 'Y' THEN
                l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME);
              END IF; --IF l_is_policy = 'Y' THEN

              l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
            END LOOP; --FOR rec_ud_attrs IN cr_rev_usr_intf_pdh(rec_attr.ATTR_GROUP_INT_NAME, l_revision) LOOP
            l_sql_query := 'SELECT I.INVENTORY_ITEM_ID ' || l_sel_clause || l_sql_query;
	          l_sql_query := l_sql_query ||' AND I.INVENTORY_ITEM_ID = :1 AND I.ORGANIZATION_ID = :2' ;
          END IF; --IF rec_attr.REVISION IS NULL THEN

          Debug_Message('Done populating attribute values for this attribute group for source system');
          Debug_Message('Getting values from production table');

          Debug_Message('SQL is - ');
          FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP
            Debug_Message(SUBSTR(l_sql_query, ((l-1)*1000) + 1, 1000));
          END LOOP; --FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP

          -- Define Dynamic SQL for querying for other Items.
          Debug_Message('Parsing SQL');
          DBMS_SQL.PARSE(cr_ud_attr, l_sql_query, DBMS_SQL.native);
          Debug_Message('Done Parsing SQL');

          Debug_Message('Defining columns for SQL');
          DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, 1, l_num_value);
          -- Defining columns in Dynamic Cursor
          Debug_Message('Total columns: '||TO_CHAR(l_idx + 1));
          FOR i IN 2..l_idx LOOP
            IF G_META(i) = G_CHAR_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_str_value,4000);
            ELSIF G_META(i) = G_NUMBER_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_num_value);
            ELSIF G_META(i) = G_DATE_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_date_value);
            END IF; --IF G_META(i) = G_CHAR_FORMAT THEN
          END LOOP; --FOR i IN 2..l_idx LOOP

          Debug_Message('Binding variables');
          DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':1', p_item1);
          DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':2', p_org_id);
	  --Bug#5043002
          --R12C: BEGIN
          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':96', p_supplier_id);
          END IF;

          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':97', p_supplier_site_id);
          END IF;

          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':96', p_supplier_id);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':97', p_supplier_site_id);
          END IF;
          DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':98', rec_attr.DATA_LEVEL_ID);
          --R12C: END

          DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':99', rec_attr.ATTR_GROUP_INT_NAME);

          -- Execution of the Query (Cursor) for UD attrs for Items
          l_ignore := DBMS_SQL.EXECUTE(cr_ud_attr);
          Debug_Message('Executed SQL, fetching rows');
          WHILE DBMS_SQL.FETCH_ROWS(cr_ud_attr) > 0 LOOP
            l_cnt := l_start + 1;
            l_item_id := NULL;
            DBMS_SQL.COLUMN_VALUE(cr_ud_attr, 1, l_item_id);
            FOR i IN 2..l_idx LOOP
              l_str_value := NULL;
              l_num_value := NULL;
              l_date_value := NULL;
              IF G_META(i) = G_CHAR_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_str_value);
                l_int_val := l_str_value;
              ELSIF G_META(i) = G_DATE_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_date_value);
                l_int_val := TO_CHAR(l_date_value, 'MM/DD/YYYY HH24:MI:SS');
              ELSIF G_META(i) = G_NUMBER_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_num_value);
                l_int_val := TO_CHAR(l_num_value);
              END IF; --IF G_META(i) = G_CHAR_FORMAT THEN

              -- if a value set is associated, then get the display value
              IF VSID(i) IS NOT NULL AND VSID(i) <> 0 THEN
                IF G_META(i) = G_DATE_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, l_int_val, NULL, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                ELSIF G_META(i) = G_CHAR_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, NULL, l_int_val, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                ELSIF G_META(i) = G_NUMBER_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, NULL, NULL, l_int_val, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                END IF;
              END IF; --IF VSID(i) IS NOT NULL

              --if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF UOM(i) IS NOT NULL THEN
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING UOM(i);
                l_int_val := l_int_val || ' ' || l_temp;
              END IF; --IF UOM_DISP_VAL(i) IS NOT NULL THEN

              populate_compare_tbl(
                                  p_compare_table =>   l_compare_tbl
                                ,p_index         =>   l_cnt
                                ,p_sel_item      =>   l_item_id
                                ,p_value         =>   l_int_val
                                ,p_item1         =>   p_item1
                                ,p_item2         =>   p_item2
                                ,p_item3         =>   p_item3
                                ,p_item4         =>   p_item4);
              l_cnt := l_cnt + 1;
            END LOOP; --FOR i IN 2..l_idx LOOP
          END LOOP; -- WHILE DBMS_SQL.FETCH_ROWS(cr_ud_attr) > 0 LOOP
          DBMS_SQL.close_cursor(cr_ud_attr);
          Debug_Message('Done Getting values from production table');
        END IF; -- IF DATA_LEVEL CHECK AGIANST p_supplier_id, p_supplier_site_id
      END LOOP; --FOR rec_attr IN cr_attr_groups_pdh(l_revision) LOOP
      Debug_Message('Done getting User Defined Attributes for Items ');
    ELSE --IF is_pdh_batch THEN
      ------------------------------------------------------------------------------------
      -- Following is the code for NON PDH type and total of the code in this else case --
      -- is similar to the one in above if claue                                        --
      ------------------------------------------------------------------------------------
      Debug_Message('Batch is NON-PDH batch ');
      FOR rec_attr IN cr_attr_groups(l_revision, p_bundle_id ) LOOP
        -- R12C: Show Item_Supplier attributes only if 'Supplier Id' is passed. (Supplier is selected)
        -- R12C: Show Item Supplier site attributes and item supplier site org attributes only if
        --            'Supplier Site Id' is passed.
        -- NOTE: SupplierSiteId do not exist without SupplierId.
        -- Added the following if condition for item intersection support in R12C.
        IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID AND p_supplier_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID AND p_supplier_site_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID AND p_supplier_site_id IS NOT NULL
           OR rec_attr.DATA_LEVEL_ID IN ( G_ITEM_LEVEL_ID, G_ORG_LEVEL_ID )
           OR rec_attr.DATA_LEVEL_INTERNAL_NAME IN ( G_ITEM_REVISION_LEVEL )
        THEN
          Debug_Message('Processing attribute group - '||rec_attr.ATTR_GROUP_INT_NAME);
          Debug_Message('With Data Level: ' || rec_attr.DATA_LEVEL_ID);
          -- if change policy may be present THEN get the Change policy for each attr grp
          IF (l_is_policy = 'Y') THEN
            Debug_Message('Getting change policy for attribute group - '||rec_attr.ATTR_GROUP_INT_NAME);
            ENG_CHANGE_POLICY_PKG.GetChangePolicy
                            (   p_policy_object_name     => 'CATALOG_LIFECYCLE_PHASE'
                            ,  p_policy_code            => 'CHANGE_POLICY'
                            ,  p_policy_pk1_value       =>  l_catalog_id
                            ,  p_policy_pk2_value       =>  l_lifecycle_id
                            ,  p_policy_pk3_value       =>  l_phase_id
                            ,  p_policy_pk4_value       =>  NULL
                            ,  p_policy_pk5_value       =>  NULL
                            ,  p_attribute_object_name  => 'EGO_CATALOG_GROUP'
                            ,  p_attribute_code         => 'ATTRIBUTE_GROUP'
                            ,  p_attribute_value        =>  rec_attr.ATTR_GROUP_ID
                            ,  x_policy_value           =>  l_ch_policy
                            );
            Debug_Message('Change Policy for attribute group : '||rec_attr.ATTR_GROUP_INT_NAME || ' is : ' || l_ch_policy );
            IF INSTR(l_ch_policy,'NOT') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) :=  'N';
            ELSIF INSTR(l_ch_policy,'ALLOWED') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) :=  'Y';
            ELSIF INSTR(l_ch_policy,'CHANGE') > 0 THEN
              l_ch_policy_tbl(rec_attr.ATTR_GROUP_INT_NAME) :=  'C';
            END IF; --IF INSTR(l_ch_policy,'NOT') > 0 THEN
          END IF; --IF (l_is_policy = 'Y') THEN

          l_sel_clause := NULL;
          l_sql_query := NULL;
          l_temp_query := NULL;
          l_idx := 1;
          l_start := NVL(l_compare_tbl.LAST,0);
          cr_ud_attr := dbms_sql.open_cursor;
          l_sql_query :=' FROM EGO_MTL_SY_ITEMS_EXT_VL I, EGO_ATTR_GROUPS_DL_V AG '||
                        ' WHERE AG.APPLICATION_ID = 431  '||
                        '   AND NVL(AG.ATTR_GROUP_TYPE, ''EGO_ITEMMGMT_GROUP'') = ''EGO_ITEMMGMT_GROUP'' '||
                        '   AND AG.ATTR_GROUP_ID = I.ATTR_GROUP_ID'||
                        '   AND I.DATA_LEVEL_ID = :98' ||   -- Added for R12C: Data_level_id
                        '   AND AG.ATTR_GROUP_NAME = :99' ; --Bug#5043002'' || rec_attr.ATTR_GROUP_INT_NAME ||'''';
          -- Since Each AG is handled at each time. Find once privileges over all items.

          -- R12C: BEGIN
          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
            l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96';
          END IF;

           IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
            l_sql_query := l_sql_query || '   AND I.PK2_VALUE = :97';
          END IF;

          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
            l_sql_query := l_sql_query || '   AND I.PK1_VALUE = :96 AND I.PK2_VALUE = :97';
          END IF;
          -- R12C: END

          --R12C: Finding attr Group display name with prefix to identify
          -- the Attribute group data level.
          IF rec_attr.DATA_LEVEL_ID = G_ITEM_LEVEL_ID THEN
            l_attr_group_display_name := l_item_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_INTERNAL_NAME = G_ITEM_REVISION_LEVEL THEN
            l_attr_group_display_name := l_itemRev_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ORG_LEVEL_ID THEN
           l_attr_group_display_name := l_itemOrg_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSup_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSupSite_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          ELSIF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
            l_attr_group_display_name := l_itemSupSiteOrg_lable || ':' || rec_attr.ATTR_GROUP_DISP_NAME;
          END IF;

          Debug_Message('Finding and Populating privilege');
          l_priv_name := get_privilege_name(rec_attr.VIEW_PRIVILEGE_ID);
          IF(l_priv_name IS NULL) THEN
            l_priv_item1 := 'T';
            l_priv_item2 := 'T';
            l_priv_item3 := 'T';
            l_priv_item4 := 'T';
          ELSE
            l_priv_item1 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item1,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item2 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item2,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item3 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item3,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
            l_priv_item4 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item4,
                            p_org_Id, NULL, NULL, NULL, l_party_id);
          END IF;
          Debug_Message('Done finding and Populating privilege');
          --Deleting all the values of temporary table that might have values for last loop.
          l_inv_rev_id_tbl.DELETE ;
          -- If is no revision level records for this attribute group
          IF rec_attr.REVISION IS NULL THEN
            -- For Each attribute Group selected. Get all the attributes in it and
            -- Populate the l_compare_table for these attributes
            -- The cusor cr_usr_intf_pdh returns
            -- Also Perparing Query clause <l_sel_clause> to query for same attributes over other Items.

            Debug_Message('Revision is NULL');
            Debug_Message('Populating all the attribute values for this attribute group for source system');
            FOR rec_ud_attrs IN cr_usr_intf( rec_attr.ATTR_GROUP_INT_NAME, rec_attr.DATA_LEVEL_ID, p_bundle_id ) LOOP
              Debug_Message('Processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
              l_idx := l_idx + 1;
              l_compare_tbl.extend();
              l_compare_rec.ATTR_GROUP_DISP_NAME :=  l_attr_group_display_name;
              l_compare_rec.ATTR_DISP_NAME       :=  rec_ud_attrs.ATTR_DISPLAY_NAME;
              l_compare_rec.ATTRIBUTE_CODE       :=  rec_ud_attrs.ATTR_ID;
              l_compare_rec.ATTR_INT_NAME        :=  rec_ud_attrs.ATTR_INT_NAME ;
              l_compare_rec.ATTR_GROUP_INT_NAME  :=  rec_ud_attrs.ATTR_GROUP_INT_NAME;

              -- Setting properly the privilege in compare table. privileges are calculated
	            -- for each AG earlier
	            l_compare_rec.PRIV_ITEM1 := l_priv_item1;
	            l_compare_rec.PRIV_ITEM2 := l_priv_item2;
              l_compare_rec.PRIV_ITEM3 := l_priv_item3;
	            l_compare_rec.PRIV_ITEM4 := l_priv_item4;

              -- Saving UOM Class and value set Associated with this attribute
	            UOM(l_idx) := rec_ud_attrs.UOM_CLASS;
              UOM_USER_CODE(l_idx) := rec_ud_attrs.ATTR_VALUE_UOM;
              UOM_DISP_VAL(l_idx) := rec_ud_attrs.ATTR_UOM_DISP_VALUE;
              IF rec_ud_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
                VSId(l_idx) := 0;
              ELSE
                VSId(l_idx) := rec_ud_attrs.VALUE_SET_ID;
              END IF;

              -- getting and setting source system value
              -- If Value set is not associated
              IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is NOT attached');
		            IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'C%' OR rec_ud_attrs.DATABASE_COLUMN LIKE 'T%' THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_STR;
                ELSIF rec_ud_attrs.DATABASE_COLUMN  LIKE 'D%' THEN
                  G_META(l_idx) := G_DATE_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_DATE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN  LIKE 'N%' THEN
                  G_META(l_idx) := G_NUMBER_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_NUM;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

                -- Adding column to sql string to get production values
		            l_sel_clause := l_sel_clause || ' , ' || rec_ud_attrs.DATABASE_COLUMN;
              ELSE --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is attached');
                -- If Value set is Associated
                l_sel_clause := l_sel_clause || ' , '|| rec_ud_attrs.DATABASE_COLUMN;
                G_META(l_idx) := SUBSTR(rec_ud_attrs.DATABASE_COLUMN, 1, 1);
                IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                  l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                        ( p_value_set_id    =>  rec_ud_attrs.VALUE_SET_ID
                                                        ,p_validation_code =>  rec_ud_attrs.VALIDATION_CODE
                                                        ,p_str_val         =>  rec_ud_attrs.ATTR_VALUE_STR
                                                        ,p_date_val        =>  rec_ud_attrs.ATTR_VALUE_DATE
                                                        ,p_num_val         =>  rec_ud_attrs.ATTR_VALUE_NUM );
                ELSE
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                Debug_Message('Display value is: '||l_compare_rec.SOURCE_SYS_VAL);
	            END IF; --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN


              -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
                Debug_Message('UOM Display Value is attached');
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_ud_attrs.ATTR_UOM_DISP_VALUE;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
                Debug_Message('UOM code is attached is attached');
                l_temp_query := l_p_atr_sql('UOM_CODE');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.ATTR_VALUE_UOM;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.UOM_CLASS IS NOT NULL THEN
                Debug_Message('UOM Class is attached');
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.UOM_CLASS;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN


              IF l_is_policy = 'Y'  THEN
                l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_ud_attrs.ATTR_GROUP_INT_NAME);
              END IF; --IF l_is_policy = 'Y'  THEN

              l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
              Debug_Message('Done processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
            END LOOP; --FOR rec_ud_attrs IN cr_usr_intf(rec_attr.ATTR_GROUP_INT_NAME) LOOP

            Debug_Message('With out Revision - End inserting Attr for Source System for Attr Grp : '||rec_attr.ATTR_GROUP_INT_NAME);
            l_sql_query := 'SELECT INVENTORY_ITEM_ID ' || l_sel_clause || l_sql_query ||
                          '   AND I.INVENTORY_ITEM_ID in (:1,:2,:3,:4)'||
                          '  AND I.ORGANIZATION_ID = :5'   ;

          ELSE --IF rec_attr.REVISION IS NULL THEN
            -- If there are attributes with Revisions ... Get Attributes in for given Attribute Group.
            Debug_Message('Revision is NOT NULL, revision is: '||rec_attr.REVISION);
            Debug_Message('Populating all the attribute values for this attribute group for source system');
            FOR  rec_ud_attrs IN cr_rev_usr_intf( rec_attr.ATTR_GROUP_INT_NAME, l_revision, p_bundle_id ) LOOP
              Debug_Message('Processing the attribute: '||rec_ud_attrs.ATTR_INT_NAME);
              l_idx := l_idx + 1;
              l_compare_tbl.extend();
              l_compare_rec.ATTR_GROUP_DISP_NAME := l_attr_group_display_name;
              l_compare_rec.ATTR_DISP_NAME       := rec_ud_attrs.ATTR_DISPLAY_NAME;
              l_compare_rec.ATTRIBUTE_CODE       :=  rec_ud_attrs.ATTR_ID;
              l_compare_rec.ATTR_INT_NAME        :=  rec_ud_attrs.ATTR_INT_NAME ;
              l_compare_rec.ATTR_GROUP_INT_NAME  :=  rec_ud_attrs.ATTR_GROUP_INT_NAME;

	            -- setting properly the privilege in compare table. privileges are calculated
	            -- for each AG earlier
	            l_compare_rec.PRIV_ITEM1 := l_priv_item1;
    	        l_compare_rec.PRIV_ITEM2 := l_priv_item2;
              l_compare_rec.PRIV_ITEM3 := l_priv_item3;
	            l_compare_rec.PRIV_ITEM4 := l_priv_item4;
	            -- Nisar End

              -- Saving UOM Class and value set Associated with this attribute
              IF rec_ud_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
                VSId(l_idx) := 0;
              ELSE
                VSId(l_idx) := rec_ud_attrs.VALUE_SET_ID;
              END IF;
	            UOM(l_idx) := rec_ud_attrs.UOM_CLASS;
              UOM_USER_CODE(l_idx) := rec_ud_attrs.ATTR_VALUE_UOM;
              UOM_DISP_VAL(l_idx) := rec_ud_attrs.ATTR_UOM_DISP_VALUE;

              -- getting and setting source system value
              -- If Value set is not associated
              IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is NOT attached');
                IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN LIKE 'C%' OR rec_ud_attrs.DATABASE_COLUMN LIKE 'T%' THEN
                  G_META(l_idx) := G_CHAR_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_STR;
                ELSIF rec_ud_attrs.DATABASE_COLUMN  LIKE 'D%' THEN
                  G_META(l_idx) := G_DATE_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_DATE;
                ELSIF rec_ud_attrs.DATABASE_COLUMN  LIKE 'N%' THEN
                  G_META(l_idx) := G_NUMBER_FORMAT;
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_VALUE_NUM;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

                l_sel_clause := l_sel_clause || ' , ' || rec_ud_attrs.DATABASE_COLUMN;
              ELSE --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN
                Debug_Message('Value set is attached');
                l_sel_clause := l_sel_clause || ' , '||  rec_ud_attrs.DATABASE_COLUMN;
                G_META(l_idx) := SUBSTR(rec_ud_attrs.DATABASE_COLUMN, 1, 1);
                IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                  l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                        ( p_value_set_id    =>  rec_ud_attrs.VALUE_SET_ID
                                                        ,p_validation_code =>  rec_ud_attrs.VALIDATION_CODE
                                                        ,p_str_val         =>  rec_ud_attrs.ATTR_VALUE_STR
                                                        ,p_date_val        =>  rec_ud_attrs.ATTR_VALUE_DATE
                                                        ,p_num_val         =>  rec_ud_attrs.ATTR_VALUE_NUM );
                ELSE
                  l_compare_rec.SOURCE_SYS_VAL := rec_ud_attrs.ATTR_DISP_VALUE;
                END IF; --IF rec_ud_attrs.ATTR_DISP_VALUE IS NULL THEN
                Debug_Message('Display value is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.VALUE_SET_ID IS NULL OR rec_ud_attrs.VALUE_SET_ID = 0 THEN

              -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
                Debug_Message('UOM Display Value is attached');
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_ud_attrs.ATTR_UOM_DISP_VALUE;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
                Debug_Message('UOM code is attached is attached');
                l_temp_query := l_p_atr_sql('UOM_CODE');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.ATTR_VALUE_UOM;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              ELSIF rec_ud_attrs.UOM_CLASS IS NOT NULL THEN
                Debug_Message('UOM Class is attached');
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_ud_attrs.UOM_CLASS;
                l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
                Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
              END IF; --IF rec_ud_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN

              IF l_is_policy = 'Y'  THEN
                l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_ud_attrs.ATTR_GROUP_INT_NAME);
              END IF; --IF l_is_policy = 'Y'  THEN

              l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
            END LOOP; --FOR  rec_ud_attrs IN cr_rev_usr_intf(rec_attr.ATTR_GROUP_INT_NAME, l_revision) LOOP

            -- preparing query to get user defined attribute values from production table
            l_sql_query := 'SELECT INVENTORY_ITEM_ID ' || l_sel_clause || l_sql_query;
            l_temp_query := NULL;
            -- Bug#5043002
					  k := 50 ;
            FOR match_rec IN cr_match_item_rev LOOP
              l_temp_query  := l_temp_query  || ' (I.INVENTORY_ITEM_ID = :'||k ; -- Bug#5043002|| match_rec.INVENTORY_ITEM_ID;
						  l_inv_rev_id_tbl(k) := match_rec.INVENTORY_ITEM_ID ; -- Bug#5043002
              IF match_rec.REVISION_ID IS NOT NULL THEN
						    k:=k+1 ;
                l_temp_query  := l_temp_query || ' AND  I.REVISION_id =  :'||k ; -- Bug#5043002|| match_rec.REVISION_ID;
  						  l_inv_rev_id_tbl(k) := match_rec.REVISION_ID ; -- Bug#5043002
              END IF;
              l_temp_query  := l_temp_query  || ' ) ';
              l_temp_query  := l_temp_query || ' OR ';
						  k:= k+1 ;
              EXIT WHEN cr_match_item_rev%ROWCOUNT = 4;
            END LOOP; --FOR match_rec IN cr_match_item_rev LOOP
	    -- bug#5043002

            IF l_temp_query IS NOT NULL THEN
              -- The last 'OR' has to be deleted from the l_temp_query for the query to be valid
              -- the following code does that
              l_temp_query := substr(l_temp_query,1,length(l_temp_query)-3);
              l_temp_query := ' AND  ('|| l_temp_query  ||' ) ' ;
            END IF; --IF l_temp_query IS NOT NULL THEN
            l_sql_query := l_sql_query || l_temp_query  || 'AND I.ORGANIZATION_ID = :1' ;
          END IF; --IF rec_attr.REVISION IS NULL THEN

          Debug_Message('Done populating attribute values for this attribute group for source system');
          Debug_Message('Getting values from production table');

          Debug_Message('SQL is - ');
          FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP
            Debug_Message(SUBSTR(l_sql_query, ((l-1)*1000) + 1, 1000));
          END LOOP; --FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP

          Debug_Message('Entering User Defined Attributes for Items ');
          -- Define Dynamic SQL for querying for other Items.
          Debug_Message('Parsing SQL');
          DBMS_SQL.PARSE(cr_ud_attr, l_sql_query, DBMS_SQL.native);
          Debug_Message('Done parsing SQL');

          Debug_Message('Defining columns for SQL');
          DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, 1 , l_num_value); --inventory_item_id
          Debug_Message('Total columns: '||TO_CHAR(l_idx + 1));
          FOR i IN 2..l_idx LOOP
            IF G_META(i) = G_CHAR_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_str_value, 4000);
            ELSIF G_META(i) = G_NUMBER_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_num_value);
            ELSIF G_META(i) = G_DATE_FORMAT THEN
              DBMS_SQL.DEFINE_COLUMN(cr_ud_attr, i, l_date_value);
            END IF; --IF G_META(i) = G_CHAR_FORMAT THEN
          END LOOP; --FOR i IN 2..l_idx LOOP

          Debug_Message('Binding variables');
          IF rec_attr.REVISION IS NULL THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':1', p_item1);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':2', p_item2);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':3', p_item3);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':4', p_item4);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':5', p_org_id);
          ELSE
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':1', p_org_id);
          END IF; --IF rec_attr.REVISION IS NULL THEN

          --R12C: BEGIN
          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':96', p_supplier_id);
          END IF;

          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPPLIER_SITE_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':97', p_supplier_site_id);
          END IF;

          IF rec_attr.DATA_LEVEL_ID = G_ITEM_SUPSITEORG_LEVEL_ID THEN
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':96', p_supplier_id);
            DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':97', p_supplier_site_id);
          END IF;
     	    DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':98', rec_attr.DATA_LEVEL_ID);
          --R12C: END

          --Bug#5043002
     	    DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':99', rec_attr.ATTR_GROUP_INT_NAME);

          -- Bug#5043002
          IF nvl(l_inv_rev_id_tbl.LAST,0)>0 THEN
            FOR j in l_inv_rev_id_tbl.FIRST..l_inv_rev_id_tbl.LAST LOOP
                    DBMS_SQL.BIND_VARIABLE(cr_ud_attr, ':'||j, l_inv_rev_id_tbl(j));
            END LOOP ;
          END IF ;
          -- Bug#5043002
          Debug_Message('Done binding variables');

          l_ignore := DBMS_SQL.EXECUTE(cr_ud_attr);
          Debug_Message('Executed SQL, fetching rows');
          WHILE DBMS_SQL.FETCH_ROWS(cr_ud_attr) > 0 LOOP
            l_cnt := l_start + 1 ;
            l_item_id := NULL;
            DBMS_SQL.COLUMN_VALUE(cr_ud_attr, 1, l_item_id);
            FOR i IN 2..l_idx LOOP
              l_str_value := NULL;
              l_num_value := NULL;
              l_date_value := NULL;
              IF G_META(i) = G_CHAR_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_str_value);
                l_int_val := l_str_value;
              ELSIF G_META(i) = G_DATE_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_date_value);
                l_int_val := TO_CHAR(l_date_value, 'MM/DD/YYYY HH24:MI:SS');
              ELSIF G_META(i) = G_NUMBER_FORMAT THEN
                DBMS_SQL.COLUMN_VALUE(cr_ud_attr, i, l_num_value);
                l_int_val := TO_CHAR(l_num_value);
              END IF; --IF G_META(i) = G_CHAR_FORMAT THEN

              -- if a value set is associated, then get the display value
              IF VSID(i) IS NOT NULL AND VSID(i) <> 0 THEN
                IF G_META(i) = G_DATE_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, l_int_val, NULL, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                ELSIF G_META(i) = G_CHAR_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, NULL, l_int_val, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                ELSIF G_META(i) = G_NUMBER_FORMAT THEN
                  l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                                431, NULL, NULL, l_int_val, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEMMGMT_GROUP'
                                ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                                ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                                ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                END IF; --IF G_META(i) = G_DATE_FORMAT THEN
              END IF; --IF VSID(i) IS NOT NULL AND VSID(i) <> 0 THEN

              --if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
              IF UOM(i) IS NOT NULL THEN
                l_temp_query := l_p_atr_sql('UOM_CLASS');
                EXECUTE IMMEDIATE l_temp_query INTO l_temp USING UOM(i);
                l_int_val := l_int_val || ' ' || l_temp;
              END IF; --IF UOM_DISP_VAL(i) IS NOT NULL THEN

              populate_compare_tbl( p_compare_table =>   l_compare_tbl
                                  ,p_index         =>   l_cnt
                                  ,p_sel_item      =>   l_item_id
                                  ,p_value         =>   l_int_val
                                  ,p_item1         =>   p_item1
                                  ,p_item2         =>   p_item2
                                  ,p_item3         =>   p_item3
                                  ,p_item4         =>   p_item4);
              l_cnt := l_cnt + 1;
            END LOOP; --FOR i IN 2..l_idx LOOP
          END LOOP; --WHILE DBMS_SQL.FETCH_ROWS(cr_ud_attr) > 0 LOOP

          DBMS_SQL.CLOSE_CURSOR(cr_ud_attr);
          Debug_Message('Done Getting values from production table');
        END IF; -- IF DATA_LEVEL check against p_supplier_site_id and p_supplier_id
      END LOOP; --FOR rec_attr IN cr_attr_groups(l_revision) LOOP
      Debug_Message('Done getting User Defined Attributes for Items ');
    END IF; --IF is_pdh_batch THEN
    Debug_Message('Done processing User Defined attributes.');

    Debug_Message('Processing GDSN attributes.');
    -- processing GTIN attributes - single row only
    l_sel_clause := NULL;
    l_val_set_clause := NULL;
    l_sql_query := NULL;
    l_idx := 1;
    l_start := NVL(l_compare_tbl.LAST, 0);

    IF is_pdh_batch THEN
      Debug_Message('Batch is PDH batch ');
      -- Getting GTIN Attributes and inserting into l_compare_table
      -- Also preparing query for GTIN attribute values for production Items
      Debug_Message('Getting GTIN attributes for Source System');
      FOR rec_dd_attrs IN cr_dd_intf_pdh LOOP
        Debug_Message('Processing attribute - '||rec_dd_attrs.ATTR_INT_NAME);
        l_idx := l_idx + 1;
        l_compare_tbl.extend();
        l_compare_rec.ATTR_GROUP_DISP_NAME := rec_dd_attrs.ATTR_GROUP_DISP_NAME;
        l_compare_rec.ATTR_DISP_NAME := rec_dd_attrs.ATTR_DISPLAY_NAME;
        l_compare_rec.ATTRIBUTE_CODE := rec_dd_attrs.ATTR_ID;
        l_compare_rec.ATTR_INT_NAME := rec_dd_attrs.ATTR_INT_NAME;
        l_compare_rec.ATTR_GROUP_INT_NAME := rec_dd_attrs.ATTR_GROUP_INT_NAME;

        -- getting and setting the privilege in compare table
        l_attGrp_new := rec_dd_attrs.ATTR_GROUP_DISP_NAME;
	      l_priv_name := get_privilege_name(rec_dd_attrs.VIEW_PRIVILEGE_ID);

        IF (l_priv_name IS NULL) THEN
	        l_priv_item1 := 'T';
          l_priv_item2 := 'T';
          l_priv_item3 := 'T';
          l_priv_item4 := 'T';
        ELSIF(l_attGrp_old <> l_attGrp_new) THEN
          l_priv_item1 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item1,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item2 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item2,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item3 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item3,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item4 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item4,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
        END IF; --IF (l_priv_name IS NULL) THEN

        -- Finding the Change Policy for an Attribute Group
        -- The condition (l_attGrp_old <> l_attGrp_new) is to calculate Change Policy only once for
        -- each Attribute Group.
        IF l_attGrp_old <> l_attGrp_new AND l_is_policy = 'Y' THEN
          ENG_CHANGE_POLICY_PKG.GetChangePolicy
                (   p_policy_object_name     => 'CATALOG_LIFECYCLE_PHASE'
                 ,  p_policy_code            => 'CHANGE_POLICY'
                 ,  p_policy_pk1_value       =>  l_catalog_id
                 ,  p_policy_pk2_value       =>  l_lifecycle_id
                 ,  p_policy_pk3_value       =>  l_phase_id
                 ,  p_policy_pk4_value       =>  NULL
                 ,  p_policy_pk5_value       =>  NULL
                 ,  p_attribute_object_name  => 'EGO_CATALOG_GROUP'
                 ,  p_attribute_code         => 'ATTRIBUTE_GROUP'
                 ,  p_attribute_value        =>  rec_dd_attrs.ATTR_GROUP_ID
                 ,  x_policy_value           =>  l_ch_policy
                 );

          Debug_Message('Change Policy for attribute group : '||rec_dd_attrs.ATTR_GROUP_INT_NAME || ' is : ' || l_ch_policy );
          IF INSTR(l_ch_policy,'NOT') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'N';
          ELSIF INSTR(l_ch_policy,'ALLOWED') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'Y';
          ELSIF INSTR(l_ch_policy,'CHANGE') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'C';
          END IF; --IF INSTR(l_ch_policy,'NOT') > 0 THEN
        END IF; --IF (l_attGrp_old <> l_attGrp_new) THEN
        l_attGrp_old := l_attGrp_new;

     	  l_compare_rec.PRIV_ITEM1 := l_priv_item1;
	      l_compare_rec.PRIV_ITEM2 := l_priv_item2;
        l_compare_rec.PRIV_ITEM3 := l_priv_item3;
        l_compare_rec.PRIV_ITEM4 := l_priv_item4;

        -- Saving UOM Class and value set Associated with this attribute
        UOM(l_idx) := rec_dd_attrs.UOM_CLASS;
        UOM_USER_CODE(l_idx) := rec_dd_attrs.ATTR_VALUE_UOM;
        UOM_DISP_VAL(l_idx) := rec_dd_attrs.ATTR_UOM_DISP_VALUE;
        IF rec_dd_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
          VSId(l_idx) := 0;
        ELSE
          VSId(l_idx) := rec_dd_attrs.VALUE_SET_ID;
        END IF;

        -- getting and setting source system value
        -- If Value set is not associated
        IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN
          Debug_Message('Value set is NOT attached');
          IF rec_dd_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
            G_META(l_idx) := G_CHAR_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_DISP_VALUE;
          ELSIF rec_dd_attrs.DATA_TYPE_CODE IN (G_CHAR_FORMAT , 'A') THEN
            G_META(l_idx) := G_CHAR_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_VALUE_STR;
          ELSIF rec_dd_attrs.DATA_TYPE_CODE IN (G_TIME_FORMAT,G_DATE_TIME_FORMAT) THEN
            G_META(l_idx) := G_DATE_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := TO_CHAR(rec_dd_attrs.ATTR_VALUE_DATE, 'MM/DD/YYYY HH24:MI:SS');
          ELSIF rec_dd_attrs.DATA_TYPE_CODE = G_NUMBER_FORMAT THEN
            G_META(l_idx) := G_NUMBER_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := TO_CHAR(rec_dd_attrs.ATTR_VALUE_NUM);
          END IF; --IF rec_dd_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

          -- Adding column to sql string to get production values
          l_sel_clause  := l_sel_clause || ' , '|| rec_dd_attrs.DATABASE_COLUMN;
        ELSE --IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN
          Debug_Message('Value set is attached');
          l_sel_clause  := l_sel_clause || ' , '|| rec_dd_attrs.DATABASE_COLUMN;
          G_META(l_idx) := rec_dd_attrs.DATA_TYPE_CODE;       --G_CHAR_FORMAT;
          IF rec_dd_attrs.ATTR_DISP_VALUE IS NULL THEN
            l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                  ( p_value_set_id    =>  rec_dd_attrs.VALUE_SET_ID
                                                   ,p_validation_code =>  rec_dd_attrs.VALIDATION_CODE
                                                   ,p_str_val         =>  rec_dd_attrs.ATTR_VALUE_STR
                                                   ,p_date_val        =>  rec_dd_attrs.ATTR_VALUE_DATE
                                                   ,p_num_val         =>  rec_dd_attrs.ATTR_VALUE_NUM );
          ELSE
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_DISP_VALUE;
          END IF; --IF rec_dd_attrs.ATTR_DISP_VALUE IS NULL THEN
          Debug_Message('Display value is: '||l_compare_rec.SOURCE_SYS_VAL);
        END IF; --IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN

        -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
        IF rec_dd_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
          Debug_Message('UOM Display Value is attached');
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_dd_attrs.ATTR_UOM_DISP_VALUE;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        ELSIF rec_dd_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
          Debug_Message('UOM code is attached is attached');
          l_temp_query := l_p_atr_sql('UOM_CODE');
          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_dd_attrs.ATTR_VALUE_UOM;
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        ELSIF rec_dd_attrs.UOM_CLASS IS NOT NULL THEN
          Debug_Message('UOM Class is attached');
          l_temp_query := l_p_atr_sql('UOM_CLASS');
          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_dd_attrs.UOM_CLASS;
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        END IF; --IF rec_dd_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN

        IF l_is_policy = 'Y' THEN
          l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME);
        END IF; --IF l_is_policy = 'Y'  THEN

        l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;

      END LOOP; --FOR rec_dd_attrs IN cr_dd_intf_pdh LOOP
      Debug_Message('Done getting GDSN attributes for Source System');
    ELSE --IF is_pdh_batch THEN
      Debug_Message('Batch is NON-PDH batch');
      Debug_Message('Getting GDSN attributes for Source System');
      FOR rec_dd_attrs IN cr_dd_intf( p_bundle_id ) LOOP
        Debug_Message('Processing attribute - '||rec_dd_attrs.ATTR_INT_NAME);
        l_idx := l_idx + 1;
        l_compare_tbl.extend();
        l_compare_rec.ATTR_GROUP_DISP_NAME :=  rec_dd_attrs.ATTR_GROUP_DISP_NAME;
        l_compare_rec.ATTR_DISP_NAME       :=  rec_dd_attrs.ATTR_DISPLAY_NAME;
        l_compare_rec.ATTRIBUTE_CODE       :=  rec_dd_attrs.ATTR_ID;
        l_compare_rec.ATTR_INT_NAME        :=  rec_dd_attrs.ATTR_INT_NAME ;
        l_compare_rec.ATTR_GROUP_INT_NAME  :=  rec_dd_attrs.ATTR_GROUP_INT_NAME;

        -- getting and setting the privilege in compare table
        l_attGrp_new := rec_dd_attrs.ATTR_GROUP_DISP_NAME;
	      l_priv_name := get_privilege_name(rec_dd_attrs.VIEW_PRIVILEGE_ID);
        IF (l_priv_name IS NULL) THEN
          l_priv_item1 := 'T';
          l_priv_item2 := 'T';
          l_priv_item3 := 'T';
          l_priv_item4 := 'T';
        ELSIF(l_attGrp_old <> l_attGrp_new) THEN
          l_priv_item1 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item1,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item2 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item2,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item3 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item3,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
          l_priv_item4 := EGO_DATA_SECURITY.CHECK_FUNCTION( 1.0, l_priv_name, 'EGO_ITEM', p_item4,
                    p_org_Id, NULL, NULL, NULL, l_party_id);
        END IF; -- IF (l_priv_name IS NULL) THEN

        -- Finding the Change Policy for an Attribute Group
        -- The condition (l_attGrp_old <> l_attGrp_new) is to calculate Change Policy only once for
        -- each Attribute Group.
        IF l_attGrp_old <> l_attGrp_new AND l_is_policy = 'Y' THEN
          ENG_CHANGE_POLICY_PKG.GetChangePolicy
                (   p_policy_object_name     => 'CATALOG_LIFECYCLE_PHASE'
                 ,  p_policy_code            => 'CHANGE_POLICY'
                 ,  p_policy_pk1_value       =>  l_catalog_id
                 ,  p_policy_pk2_value       =>  l_lifecycle_id
                 ,  p_policy_pk3_value       =>  l_phase_id
                 ,  p_policy_pk4_value       =>  NULL
                 ,  p_policy_pk5_value       =>  NULL
                 ,  p_attribute_object_name  => 'EGO_CATALOG_GROUP'
                 ,  p_attribute_code         => 'ATTRIBUTE_GROUP'
                 ,  p_attribute_value        =>  rec_dd_attrs.ATTR_GROUP_ID
                 ,  x_policy_value           =>  l_ch_policy
                 );

          Debug_Message('Change Policy for attribute group : '||rec_dd_attrs.ATTR_GROUP_INT_NAME || ' is : ' || l_ch_policy );
          IF INSTR(l_ch_policy,'NOT') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'N';
          ELSIF INSTR(l_ch_policy,'ALLOWED') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'Y';
          ELSIF INSTR(l_ch_policy,'CHANGE') > 0 THEN
            l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME) :=  'C';
          END IF; --IF INSTR(l_ch_policy,'NOT') > 0 THEN
        END IF; --IF (l_attGrp_old <> l_attGrp_new) THEN
        l_attGrp_old := l_attGrp_new;

        l_compare_rec.PRIV_ITEM1 := l_priv_item1;
        l_compare_rec.PRIV_ITEM2 := l_priv_item2;
        l_compare_rec.PRIV_ITEM3 := l_priv_item3;
        l_compare_rec.PRIV_ITEM4 := l_priv_item4;

        -- Saving UOM Class and value set Associated with this attribute
        UOM(l_idx) := rec_dd_attrs.UOM_CLASS;
        UOM_USER_CODE(l_idx) := rec_dd_attrs.ATTR_VALUE_UOM;
        UOM_DISP_VAL(l_idx) := rec_dd_attrs.ATTR_UOM_DISP_VALUE;
        IF rec_dd_attrs.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE THEN
          VSId(l_idx) := 0;
        ELSE
          VSId(l_idx) := rec_dd_attrs.VALUE_SET_ID;
        END IF;

        -- getting and setting source system value
        -- If Value set is not associated
        IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN
          Debug_Message('Value set is NOT attached');
	        IF rec_dd_attrs.ATTR_DISP_VALUE IS NOT NULL THEN
            G_META(l_idx) := G_CHAR_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_DISP_VALUE;
          ELSIF rec_dd_attrs.DATA_TYPE_CODE IN (G_CHAR_FORMAT, 'A') THEN
            G_META(l_idx) := G_CHAR_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_VALUE_STR;
          ELSIF rec_dd_attrs.DATA_TYPE_CODE IN (G_TIME_FORMAT, G_DATE_TIME_FORMAT) THEN
            G_META(l_idx) := G_DATE_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := TO_CHAR(rec_dd_attrs.ATTR_VALUE_DATE, 'MM/DD/YYYY HH24:MI:SS');
          ELSIF rec_dd_attrs.DATA_TYPE_CODE = G_NUMBER_FORMAT THEN
            G_META(l_idx) := G_NUMBER_FORMAT;
            l_compare_rec.SOURCE_SYS_VAL := TO_CHAR(rec_dd_attrs.ATTR_VALUE_NUM);
          END IF; --IF rec_dd_attrs.ATTR_DISP_VALUE IS NOT NULL THEN

          -- Adding column to sql string to get production values
          l_sel_clause  := l_sel_clause || ' , '|| rec_dd_attrs.DATABASE_COLUMN;
	      ELSE --IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN
          Debug_Message('Value set is attached');
          l_sel_clause := l_sel_clause || ' , '||  rec_dd_attrs.DATABASE_COLUMN;
          G_META(l_idx) := rec_dd_attrs.DATA_TYPE_CODE; --G_CHAR_FORMAT;
          IF rec_dd_attrs.ATTR_DISP_VALUE IS NULL THEN
            l_compare_rec.SOURCE_SYS_VAL := Get_SS_Data_For_Val_set
                                                  ( p_value_set_id    =>  rec_dd_attrs.VALUE_SET_ID
                                                   ,p_validation_code =>  rec_dd_attrs.VALIDATION_CODE
                                                   ,p_str_val         =>  rec_dd_attrs.ATTR_VALUE_STR
                                                   ,p_date_val        =>  rec_dd_attrs.ATTR_VALUE_DATE
                                                   ,p_num_val         =>  rec_dd_attrs.ATTR_VALUE_NUM );
          ELSE
            l_compare_rec.SOURCE_SYS_VAL := rec_dd_attrs.ATTR_DISP_VALUE;
          END IF; --IF rec_dd_attrs.ATTR_DISP_VALUE IS NULL THEN
        END IF; --IF rec_dd_attrs.VALUE_SET_ID = 0 OR rec_dd_attrs.VALUE_SET_ID IS NULL THEN

        -- if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
        IF rec_dd_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN
          Debug_Message('UOM Display Value is attached');
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || rec_dd_attrs.ATTR_UOM_DISP_VALUE;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        ELSIF rec_dd_attrs.ATTR_VALUE_UOM IS NOT NULL THEN
          Debug_Message('UOM code is attached is attached');
          l_temp_query := l_p_atr_sql('UOM_CODE');
          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_dd_attrs.ATTR_VALUE_UOM;
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        ELSIF rec_dd_attrs.UOM_CLASS IS NOT NULL THEN
          Debug_Message('UOM Class is attached');
          l_temp_query := l_p_atr_sql('UOM_CLASS');
          EXECUTE IMMEDIATE l_temp_query INTO l_temp USING rec_dd_attrs.UOM_CLASS;
          l_compare_rec.SOURCE_SYS_VAL := l_compare_rec.SOURCE_SYS_VAL || ' ' || l_temp;
          Debug_Message('Value after appending UOM is: '||l_compare_rec.SOURCE_SYS_VAL);
        END IF; --IF rec_dd_attrs.ATTR_UOM_DISP_VALUE IS NOT NULL THEN

        IF l_is_policy = 'Y' THEN
          l_compare_rec.CHANGE_POLICY := l_ch_policy_tbl(rec_dd_attrs.ATTR_GROUP_INT_NAME);
        END IF; --IF l_is_policy = 'Y'  THEN

        l_compare_tbl(l_compare_tbl.LAST) := l_compare_rec;
      END LOOP; --FOR rec_dd_attrs IN cr_dd_intf LOOP
      Debug_Message('Done getting GDSN attributes for Source System');
    END IF; --IF is_pdh_batch THEN

    Debug_Message('Preparing SQL for getting attribute values for production items.');
    -- If Selection clause if NULL THEN there are no GTIN Attrs to be selected
    IF l_sel_clause IS NOT NULL THEN
      IF is_pdh_batch THEN
	      l_sql_query := 'SELECT INVENTORY_ITEM_ID '|| l_sel_clause ||
                       ' FROM EGO_ITEM_GTN_ATTRS_VL I ' ||
                       ' WHERE I.INVENTORY_ITEM_ID = :1 ' ||
                       '   AND I.ORGANIZATION_ID = :2 ' ;
	    ELSE
	      l_sql_query := 'SELECT INVENTORY_ITEM_ID '|| l_sel_clause ||
                       ' FROM EGO_ITEM_GTN_ATTRS_VL I ' ||
                       ' WHERE I.INVENTORY_ITEM_ID IN (:1,:2,:3,:4)' ||
                       '   AND I.ORGANIZATION_ID = :5 ' ;
      END IF; --IF is_pdh_batch THEN

      Debug_Message('SQL is - ');
      FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP
        Debug_Message(SUBSTR(l_sql_query, ((l-1)*1000) + 1, 1000));
      END LOOP; --FOR l in 1..(CEIL(LENGTH(l_sql_query)/1000)) LOOP

      -- Defining a Dynamic Cursor -
      cr_dd_attr := DBMS_SQL.OPEN_CURSOR;
      Debug_Message('Parsing SQL');
      DBMS_SQL.PARSE(cr_dd_attr, l_sql_query, DBMS_SQL.native);
      Debug_Message('Done Parsing SQL');
      Debug_Message('Defining columns');
      DBMS_SQL.DEFINE_COLUMN(cr_dd_attr, 1 , l_num_value); --inventory _item _id
      Debug_Message('Total columns: '||TO_CHAR(l_idx + 1));
      FOR i IN 2..l_idx LOOP
        IF G_META(i) = G_CHAR_FORMAT THEN
          DBMS_SQL.DEFINE_COLUMN(cr_dd_attr, i, l_str_value, 4000);
        ELSIF G_META(i) = G_NUMBER_FORMAT THEN
          DBMS_SQL.DEFINE_COLUMN(cr_dd_attr, i, l_num_value);
        ELSIF G_META(i) = G_DATE_FORMAT THEN
          DBMS_SQL.DEFINE_COLUMN(cr_dd_attr, i, l_date_value);
        END IF; --IF G_META(i) = G_CHAR_FORMAT THEN
      END LOOP; --FOR i IN 2..l_idx LOOP

      Debug_Message('Binding variables');
      IF is_pdh_batch THEN
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':1', p_item1);
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':2', p_org_id);
	    ELSE
	      DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':1', p_item1);
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':2', p_item2);
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':3', p_item3);
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':4', p_item4);
        DBMS_SQL.BIND_VARIABLE(cr_dd_attr, ':5', p_org_id);
	    END IF; --IF is_pdh_batch THEN
      Debug_Message('Done binding variables');

      l_ignore := DBMS_SQL.EXECUTE(cr_dd_attr);
      Debug_Message('Executed SQL, fetching rows');
      WHILE DBMS_SQL.FETCH_ROWS(cr_dd_attr) > 0 LOOP
        l_cnt := l_start + 1;
        FOR i IN 2..l_idx LOOP
          l_str_value := NULL;
          l_num_value := NULL;
          l_date_value := NULL;
          IF G_META(i) = G_CHAR_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_dd_attr, i, l_str_value);
            l_val := l_str_value;
          ELSIF G_META(i) = G_DATE_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_dd_attr, i, l_date_value);
            l_val := TO_CHAR(l_date_value, 'MM/DD/YYYY HH24:MI:SS');
          ELSIF G_META(i) = G_NUMBER_FORMAT THEN
            DBMS_SQL.COLUMN_VALUE(cr_dd_attr, i, l_num_value);
            l_val := TO_CHAR(l_num_value);
          END IF; --IF G_META(i) = G_CHAR_FORMAT THEN

          -- if a value set is associated, then get the display value
          IF VSID(i) IS NOT NULL AND VSID(i) <> 0 THEN
            IF G_META(i) = G_DATE_FORMAT THEN
              l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                            431, l_int_val, NULL, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEM_GTIN_ATTRS'
                            ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                            ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                            ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            ELSIF G_META(i) = G_CHAR_FORMAT THEN
              l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                            431, NULL, l_int_val, NULL, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEM_GTIN_ATTRS'
                            ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                            ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                            ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            ELSIF G_META(i) = G_NUMBER_FORMAT THEN
              l_int_val := EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet (
                            431, NULL, NULL, l_int_val, l_compare_tbl(l_cnt).ATTR_INT_NAME, 'EGO_ITEM_GTIN_ATTRS'
                            ,l_compare_tbl(l_cnt).ATTR_GROUP_INT_NAME, l_compare_tbl(l_cnt).ATTRIBUTE_CODE
                            ,'EGO_ITEM' ,'ORGANIZATION_ID', p_org_id, 'INVENTORY_ITEM_ID', l_item_id, NULL
                            ,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            END IF; --IF G_META(i) = G_DATE_FORMAT THEN
          END IF; --IF VSID(i) IS NOT NULL AND VSID(i) <> 0 THEN

          --if UOM class is attached to the attribute, THEN appending the base UOM to attribute value.
          IF UOM(i) IS NOT NULL THEN
            l_temp_query := l_p_atr_sql('UOM_CLASS');
            EXECUTE IMMEDIATE l_temp_query INTO l_temp USING UOM(i);
            l_val := l_val || ' ' || l_temp;
          END IF; --IF UOM_DISP_VAL(i) IS NOT NULL THEN

          populate_compare_tbl(    p_compare_table => l_compare_tbl ,
                                   p_index         => l_cnt,
                                   p_sel_item      => l_item_id ,
                                   p_value         => l_val ,
                                   p_item1         => p_item1 ,
                                   p_item2         => p_item2 ,
                                   p_item3         => p_item3 ,
                                   p_item4         => p_item4);
          l_cnt := l_cnt + 1;
        END LOOP; --FOR i IN 2..l_idx LOOP
      END LOOP; --WHILE DBMS_SQL.FETCH_ROWS(cr_dd_attr) > 0 LOOP
      DBMS_SQL.CLOSE_CURSOR(cr_dd_attr);
      Debug_Message('Done getting attribute values for production items.');
    END IF; --IF l_sel_clause IS NOT NULL THEN
    Debug_Message('Done Processing GDSN attributes.');
    Debug_Message('Done GET_COMPARED_DATA Successfully at - '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    RETURN l_compare_tbl;
  EXCEPTION
    WHEN OTHERS THEN
      err_compare_tbl := SYSTEM.EGO_COMPARE_VIEW_TABLE();
      err_compare_rec := SYSTEM.EGO_COMPARE_VIEW_REC('', '', '','', '', '','', '', '','', '','','','','');
      --err_compare_rec.ATTR_GROUP_DISP_NAME := 'Encountered error, No search conducted';
      err_compare_rec.ATTR_GROUP_DISP_NAME := SQLERRM;
      err_compare_tbl.EXTEND();
      err_compare_tbl(1) := err_compare_rec;
      Debug_Message('Error - '||SQLERRM);
      Debug_Message('Done GET_COMPARED_DATA with error at - '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
      RETURN err_compare_tbl;
  END GET_COMPARED_DATA;
END EGO_IMPORT_BATCH_COMPARE_PVT;

/
