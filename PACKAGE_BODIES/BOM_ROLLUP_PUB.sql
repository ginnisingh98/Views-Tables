--------------------------------------------------------
--  DDL for Package Body BOM_ROLLUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ROLLUP_PUB" AS
/* $Header: BOMRLUPB.pls 120.7 2007/07/02 05:31:42 dikrishn ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRLUPB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Rollup_Pub
--
--  NOTES
--  Rollup will happen on the objects within a BOM. Every object would have a
--  Attribute Map, with every attribute identifying the compute function. If the
--  Compute function for the attribute is not specified, the value of the attribute
--  is taken as-is.
--  Attribute Map is created from the Object attributes' metadata and is not required
--  for the calling application to be aware of or even to modify it directly within this
--  sub-process.
--  Every object also has a list of rollup actions that it supports.
--  Every supported action has a rollup function. When a object in bom is being rolled up
--  the calling application can indicate which rollup actions should be performed
--  on the Object.
--  The rollup actions are always performed in a reverse topological order. Attribute
--  computation or propogation would start at the leaf nodes and end with parent.
--
--  HISTORY
--
-- 09-May-04    Rahul Chitko   Initial Creation
***************************************************************************/


  /* Package Globals */
  pG_Attribute_Map    Bom_Rollup_Pub.Attribute_Map;
  pG_Rollup_Action_Map    Bom_Rollup_Pub.Rollup_Action_Map;

  pG_Item_Org_Tbl     Bom_Rollup_Pub.Item_Org_Tbl;

/****************** Local procedures Section ******************/



  FUNCTION Get_Current_Item_Id RETURN NUMBER
  IS
  BEGIN
    IF pG_Item_Org_Tbl.Exists(2)
    THEN
      RETURN pG_Item_Org_Tbl(2).Inventory_Item_Id;
    ELSE
      RETURN null;
    END IF;

  END Get_Current_Item_Id;

  FUNCTION Get_Current_Organization_Id RETURN NUMBER
        IS
        BEGIN
                IF pG_Item_Org_Tbl.Exists(2)
                THEN
                        RETURN pG_Item_Org_Tbl(2).Organization_Id;
                ELSE
                        RETURN null;
                END IF;

        END Get_Current_Organization_Id;


  FUNCTION Get_Top_Item_Id RETURN NUMBER
        IS
        BEGIN
                IF pG_Item_Org_Tbl.Exists(1)
                THEN
                        RETURN pG_Item_Org_Tbl(1).Inventory_Item_Id;
                ELSE
                        RETURN null;
                END IF;

        END Get_Top_Item_Id;

  FUNCTION Get_Top_Organization_Id RETURN NUMBER
        IS
        BEGIN
                IF pG_Item_Org_Tbl.Exists(1)
                THEN
                        RETURN pG_Item_Org_Tbl(1).Organization_Id;
                ELSE
                        RETURN null;
                END IF;

        END Get_Top_Organization_Id;

  PROCEDURE Set_Top_Organization_Id
  (p_Organization_Id IN NUMBER)
  IS
  BEGIN
    pG_Item_Org_Tbl(1).Organization_Id := p_Organization_Id;

  END Set_Top_Organization_Id;

  PROCEDURE Set_Top_Item_Id
  (p_Inventory_Item_Id IN NUMBER)
  IS
  BEGIN
          pG_Item_Org_Tbl(1).Inventory_Item_Id := p_Inventory_Item_Id;
  END Set_Top_Item_Id;

  PROCEDURE Set_Current_Organization_Id
  (p_Organization_Id IN NUMBER)
  IS
  BEGIN
          pG_Item_Org_Tbl(2).Organization_Id := p_Organization_Id;
  END Set_Current_Organization_Id;

  PROCEDURE Set_Current_Item_Id
  (p_Inventory_Item_Id IN NUMBER)
  IS
  BEGIN
          pG_Item_Org_Tbl(2).Inventory_Item_Id := p_Inventory_Item_Id;
  END Set_Current_Item_Id;

/* Procedure to CLOSE the Error handling and Debug Logging
*/
  Procedure Close_ErrorDebug_Handler
  is
  BEGIN
    --Removed for 11.5.10-E
    --DELETE FROM BOM_EXPLOSIONS_ALL;
    DELETE FROM BOM_SMALL_IMPL_TEMP;

    Error_Handler.Close_Debug_Session;
  END;

/* Procedure to initialize the Error handling and Debug Logging
*/
  Procedure Initialize_ErrorDebug_Handler
  IS
    CURSOR c_get_utl_file_dir IS
    SELECT
      VALUE
    FROM
      V$PARAMETER
    WHERE
      NAME = 'utl_file_dir';
    l_log_return_status varchar2(1);
    l_errbuff varchar2(3000);
    l_err_text varchar2(3000);
  BEGIN

    G_DEBUG_FLAG := fnd_profile.value('MRP_DEBUG');


--    Error_Handler.Get_Message_Count
--    Initialize_ErrorDebug_Handler;

    Error_Handler.initialize();
    Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);
    IF (G_DEBUG_FLAG = 'Y') THEN
      OPEN c_get_utl_file_dir;
      FETCH c_get_utl_file_dir INTO G_LOG_FILE_DIR;
      IF c_get_utl_file_dir%FOUND THEN
        ------------------------------------------------------
        -- Trim to get only the first directory in the list --
        ------------------------------------------------------
        IF INSTR(G_LOG_FILE_DIR,',') <> 0 THEN
          G_LOG_FILE_DIR := SUBSTR(G_LOG_FILE_DIR, 1, INSTR(G_LOG_FILE_DIR, ',') - 1);
        END IF;

        G_LOG_FILE := G_BO_IDENTIFIER||'_'||TO_CHAR(SYSDATE, 'DDMONYYYY_HH24MISS')||'.err';
        Error_Handler.Set_Debug(G_DEBUG_FLAG);
        Error_Handler.Open_Debug_Session(
          p_debug_filename   => G_LOG_FILE
         ,p_output_dir       => G_LOG_FILE_DIR
         ,x_return_status    => l_log_return_status
         ,x_error_mesg       => l_errbuff
         );

        IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           WRITE_ERROR_LOG (
            p_bo_identifier   => G_BO_IDENTIFIER
          , p_message         => 'Unable to Open File');
        ELSE
           WRITE_ERROR_LOG (
            p_bo_identifier   => G_BO_IDENTIFIER
          , p_message         => 'Debug Log Location' || G_LOG_FILE_DIR || G_LOG_FILE);
        END IF;

      END IF;--IF c_get_utl_file_dir%FOUND THEN

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_err_text := SQLERRM;
      l_err_text := 'Error : '||TO_CHAR(SQLCODE)||'---'||l_err_text;
      WRITE_ERROR_LOG (
            p_bo_identifier   => G_BO_IDENTIFIER
          , p_message         => l_err_text);
  END Initialize_ErrorDebug_Handler;


  /* Helper for creating the Attribute Map */

  Procedure Add_Attribute_Map_Entry
      (  p_Attribute_Name   IN  VARCHAR2
       , p_Attribute_Value    IN  VARCHAR2
       , p_Attribute_Type   IN  VARCHAR2
       , p_Compute_Function   IN  VARCHAR2
       , p_Object_Name    IN  VARCHAR2
       , p_Attribute_Table_Name IN  VARCHAR2 := NULL
       )
  IS
    l_attr_Index NUMBER := G_Attribute_Map.COUNT+1;
  BEGIN
    G_Attribute_Map(l_attr_index).Attribute_Name  := p_Attribute_Name;
    G_Attribute_Map(l_attr_index).Attribute_Value := p_Attribute_Value;
    G_Attribute_Map(l_attr_index).Attribute_Type  := p_Attribute_Type;
    G_Attribute_Map(l_attr_index).Compute_Function  := p_Compute_Function;
    G_Attribute_Map(l_attr_index).Object_Name := p_Object_Name;
  END Add_Attribute_Map_Entry;


  /* Load the Local Attribute Map */
  Procedure Load_Attribute_Map
  IS
          l_Attribute_Name               VARCHAR2(30);
          l_Attribute_Value              VARCHAR2(2000);
          l_Attribute_Type               VARCHAR2(81);
          l_Compute_Function             VARCHAR2(240);
    l_Object_Name          VARCHAR2(30);
  BEGIN

    /*
    -- In release 1 we would not allow passing the attribute value.
    -- Hence the attribute is not exposed.

    -- In the next phase we would read this as the attribute meta-data
    -- and form the attribute map
    -- based on that rather than what it is built here.
    */
--UOM ROLLUP
    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'NET_WEIGHT_UOM'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'VARCHAR2'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'MTL_SYSTEM_ITEMS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'GROSS_WEIGHT_UOM'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'VARCHAR2'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'MTL_SYSTEM_ITEMS_B'
    );
--UOM ROLLUP
    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'UNIT_WEIGHT'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'NUMBER'
     , p_Compute_Function => 'Bom_Compute_Functions.Compute_Net_Weight'
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'MTL_SYSTEM_ITEMS_B'
    );


    Add_Attribute_Map_Entry
    (  p_Attribute_Name     => 'GROSS_WEIGHT'
     , p_Attribute_Value    => NULL
     , p_Attribute_Type     => 'NUMBER'
     , p_Compute_Function   => 'Bom_Compute_Functions.Compute_Gross_Weight'
     , p_Object_Name        => 'EGO_ITEM'
    , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name     => 'COMPONENT_QUANTITY'
     , p_Attribute_Value    => NULL
     , p_Attribute_Type     => 'NUMBER'
     , p_Compute_Function   => NULL
     , p_Object_Name        => 'EGO_ITEM'
    , p_Attribute_Table_Name => 'BOM_COMPONENTS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'IS_TRADE_ITEM_INFO_PRIVATE'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
    , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'BRAND_OWNER_NAME'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );
    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'BRAND_OWNER_GLN'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );
    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'FUNCTIONAL_NAME'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_TL'
    );
    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'IS_TRADE_ITEM_A_CONSUMER_UNIT'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'CUSTOMER_ORDER_ENABLED_FLAG'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'MTL_SYSTEM_ITEMS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'PARENT_IS_ITEM_CONS_UNIT'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'PARENT_CUST_ORD_ENABLED_FLAG'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'MTL_SYSTEM_ITEMS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'MANUFACTURER_ID'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITM_GTN_MUL_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'MANUFACTURER_GLN'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITM_GTN_MUL_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'TOP_GTIN'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name       => 'SUB_BRAND'
     , p_Attribute_Value      => NULL
     , p_Attribute_Type       => 'VARCHAR2'
     , p_Compute_Function     => NULL
     , p_Object_Name          => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'STORAGE_HANDLING_TEMP_MIN'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'NUMBER'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'UOM_STORAGE_HANDLING_TEMP_MIN'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'VARCHAR2'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'STORAGE_HANDLING_TEMP_MAX'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'NUMBER'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

    Add_Attribute_Map_Entry
    (  p_Attribute_Name => 'UOM_STORAGE_HANDLING_TEMP_MAX'
     , p_Attribute_Value  => NULL
     , p_Attribute_Type => 'VARCHAR2'
     , p_Compute_Function => NULL
     , p_Object_Name  => 'EGO_ITEM'
     , p_Attribute_Table_Name => 'EGO_ITEM_GTN_ATTRS_B'
    );

  END Load_Attribute_Map;

  Procedure Add_Action_Entry
      (  p_Rollup_Action  IN  VARCHAR2
       , p_Rollup_Function  IN  VARCHAR2
       , p_Object_Name  IN  VARCHAR2
       , p_DML_Function IN  VARCHAR2
       , p_DML_Delayed_Write IN VARCHAR2
       )
  IS
    l_action_map_index NUMBER := G_Rollup_Action_Map.COUNT + 1;
  BEGIN
    G_Rollup_Action_Map(l_action_map_index).Rollup_Action := p_Rollup_Action;
    G_Rollup_Action_Map(l_action_map_index).Rollup_Function := p_Rollup_Function;
    G_Rollup_Action_Map(l_action_map_index).Object_Name := p_Object_Name;
    G_Rollup_Action_Map(l_action_map_index).DML_Function := p_DML_Function;
    G_Rollup_Action_Map(l_action_map_index).DML_Delayed_Write := p_DML_Delayed_Write;
  END Add_Action_Entry;

  Procedure Load_Rollup_Action_Map
  IS
  BEGIN
    Add_Action_Entry
    ( p_Rollup_Action       => G_COMPUTE_NET_WEIGHT
    , p_Rollup_Function     => 'Bom_Compute_Functions.Rollup_Net_Weight'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_Net_Weight'
    , p_DML_Delayed_Write   => 'N'
     );
/*
    Add_Action_Entry
    ( p_Rollup_Action       => G_COMPUTE_GROSS_WEIGHT
    , p_Rollup_Function     => 'Bom_Compute_Functions.Rollup_Gross_Weight'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_User_Attributes'
    , p_DML_Delayed_Write   => 'N'
     );

    Add_Action_Entry
    ( p_Rollup_Action       => G_PROPOGATE_PRIVATE_FLAG
    , p_Rollup_Function     => 'Bom_Compute_Functions.Propogate_Private_Flag'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_Private_Flag'
    , p_DML_Delayed_Write   => 'N'
     );
*/
    Add_Action_Entry
    ( p_Rollup_Action       => G_PROPOGATE_BRAND_INFO
    , p_Rollup_Function     => 'Bom_Compute_Functions.Propogate_Brand_Info'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_Brand_Info'
    , p_DML_Delayed_Write   => 'N'
     );

    Add_Action_Entry
    ( p_Rollup_Action       => G_COMPUTE_TOP_GTIN_FLAG
    , p_Rollup_Function     => 'Bom_Compute_Functions.Propogate_TOP_GTIN_Flag'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_Top_GTIN_Flag'
    , p_DML_Delayed_Write   => 'N'
     );

    Add_Action_Entry
    ( p_Rollup_Action       => G_COMPUTE_MULTI_ROW_ATTRS
    , p_Rollup_Function     => 'Bom_Compute_Functions.Compute_Multi_Row_Attrs'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_Multirow_Attributes'
    , p_DML_Delayed_Write   => 'N'
     );

    Add_Action_Entry
    ( p_Rollup_Action       => G_PROPAGATE_SH_TEMPS
    , p_Rollup_Function     => 'Bom_Compute_Functions.Propagate_SH_Temps'
    , p_Object_Name         => 'EGO_ITEM'
    , p_DML_Function        => 'Bom_Compute_Functions.Set_SH_Temps'
    , p_DML_Delayed_Write   => 'N'
     );

  END Load_Rollup_Action_Map;


  PROCEDURE Load_Top_Items
      ( p_Item_Id    IN  NUMBER
      , p_organization_id  IN  NUMBER
      , p_alternate_bom_Code IN  VARCHAR2
      , p_structure_type_id  IN NUMBER DEFAULT NULL
      , x_Sequence     IN OUT NOCOPY NUMBER
      )
  IS
    l_err_msg varchar2(2000);
    l_err_code  varchar2(2000);
    l_used_in_struct varchar2(2000);
  BEGIN
    x_Sequence := to_number(to_char(sysdate,'SSSS'));
    Bom_Imploder_Pub.Imploder_Userexit
    ( sequence_id   => x_Sequence
    , eng_mfg_flag    => 2
    , org_id    => p_Organization_Id
    , impl_flag   => 2
    , display_option  => 2
    , levels_to_implode => 10
    , obj_name    => 'EGO_ITEM'
    , pk1_value   => p_Item_Id
    , pk2_value   => p_Organization_Id
    , impl_date   => to_char(sysdate,'YYYY/MM/DD HH24:MI:SS')
    , unit_number_from  => NULL
    , unit_number_to  => NULL
    , err_msg     => l_err_msg
    , err_code    => l_err_code
    , organization_option   => 1
    , struct_name => 'PIM_PBOM_S'
    , struct_type => 'Packaging Hierarchy'
    , revision => null
    , used_in_structure => l_used_in_struct
    );
   WRITE_DEBUG_LOG (
    p_bo_identifier   => G_BO_IDENTIFIER
  , p_message         => 'Uploaded Imploder with sequence Id ' || x_Sequence || ' error ' || l_err_msg );

  END Load_Top_Items;


  PROCEDURE Handle_Attribute_Updates
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , p_action_map        IN  Bom_Rollup_Pub.Rollup_Action_Map
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
--    l_indx NUMBER;
    l_act_indx NUMBER;
  BEGIN
    -- For each entry in the action map, call the dml function
    FOR action_index in 1..p_action_map.COUNT
    LOOP
        --
        -- Perform rollup for all the top level
        --
        FOR l_indx IN 1..G_Rollup_Action_Map.COUNT
        LOOP
          IF G_Rollup_Action_Map(l_indx).Rollup_Action =
          p_action_map(action_index).Rollup_Action
          THEN
          l_act_indx := l_indx;
          END IF;
        END LOOP;

      WRITE_DEBUG_LOG (
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => 'Calling DML Function '||G_Rollup_Action_Map(l_act_indx).DML_Function
        ||' with header_attrs_flag '||p_header_attrs_flag||' for item '||p_header_item_id||'-'||p_organization_id);

      EXECUTE IMMEDIATE ' ' ||
      ' BEGIN ' || G_Rollup_Action_Map(l_act_indx).DML_Function ||
      '( p_header_item_id => :header_item_id '||
      ', p_organization_id => :organization_id '||
      ', p_header_attrs_flag => :header_attrs_flag '||
      ', x_return_status => :return_status '||
      ', x_msg_count => :msg_count '||
      ', x_msg_data => :msg_data '||
      '); END;'
      USING IN p_header_item_id
           ,IN p_organization_id
           ,IN p_header_attrs_flag
           ,OUT x_return_status
           ,OUT x_msg_count
           ,OUT x_msg_data;

      WRITE_DEBUG_LOG (
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => 'Called DML Function '||x_return_status||':'||x_msg_count||' '||x_msg_data);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      WRITE_DEBUG_LOG(
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => 'EXCEPTION IN HAU: '||sqlerrm
      );

  END Handle_Attribute_Updates;


  /*
    The item id passed in here is the TOP Item id. This top item will be available
    to all the subsequent processes Get_Top_Item_Id and Get_Top_Organization_Id
    Current Item and current Organization is available Get_Current_Item_Id and
    Get_Current_Organization_Id.
  */
  PROCEDURE Handle_Rollup_Actions
  (  p_rollup_id    IN  NUMBER
   , p_action_map   IN  Bom_Rollup_Pub.Rollup_Action_Map
   , p_item_id    IN  NUMBER
   , p_organization_id  IN  NUMBER
   , p_parent_item_id     IN  NUMBER := NULL -- passed in if add/delete comp case
   , p_component_item_id  IN  NUMBER := NULL -- passed in if add/delete comp case
   , p_alternate_bom_code IN  VARCHAR2
   , p_validate           IN  VARCHAR2
   , p_halt_on_error      IN  VARCHAR2
   , x_return_status      OUT NOCOPY VARCHAR2
   , x_msg_count          OUT NOCOPY NUMBER
   , x_msg_data           OUT NOCOPY VARCHAR2
  )
  IS
      CURSOR l_LowLevelCode_csr is
        SELECT
          nvl(max(plan_level), -1) depth
        FROM
          bom_explosions_all
        WHERE
          group_id = p_rollup_id;

      l_depth number;
      l_Component_Attrs Bom_Rollup_Pub.Attribute_Map;

      CURSOR c_assy_csr(
        p_level  NUMBER
      , p_rollup_id  NUMBER
      )
      IS
       SELECT
        MTL.ROWID row_id,
        MTL.INVENTORY_ITEM_ID inventory_item_id,
        nvl(UNIT_WEIGHT,0) unit_weight,
        LLC.assembly_item_id parent_item_id
      FROM
        Mtl_System_Items_b MTL,
        bom_explosions_all LLC
      WHERE
            LLC.group_id   = p_rollup_id
        AND LLC.plan_level = p_level
        AND MTL.INVENTORY_ITEM_ID = LLC.pk1_value
        AND LLC.obj_name IS NULL   -- EGO_ITEM
        AND MTL.ORGANIZATION_ID = p_organization_id;

    CURSOR l_comps_csr ( p_org_id       NUMBER
           , p_item_id      NUMBER
           , p_unit_number    VARCHAR2
           , p_eff_date     DATE
           , p_alternate_bom_code VARCHAR2
            )
    IS
    SELECT MTL2.UNIT_WEIGHT unit_weight
         ,gtn_attrs.gross_weight gross_weight
--UOM ROLLUP
         , MTL2.WEIGHT_UOM_CODE NET_WT_UOM
         , gtn_attrs.UOM_GROSS_WEIGHT GROSS_WT_UOM
--UOM ROLLUP
         ,component_sequence_id
         ,com.component_quantity
         ,com.bill_sequence_id
         ,com.component_item_id
         ,gtn_attrs.is_trade_item_info_private
         ,gtn_attrs.brand_owner_name brand_owner_name
         ,gtn_attrs.brand_owner_gln brand_owner_gln
         ,gtn_attrs.sub_brand sub_brand
         ,gtn_attrs_tl.functional_name functional_name
         ,0 manufacturer_id
         ,' ' manufacturer_gln
         ,mtl2.customer_order_enabled_flag
         ,gtn_attrs.is_trade_item_a_consumer_unit
         ,mtl1.customer_order_enabled_flag parent_cust_ord_enabled_flag
         ,gtn_attrs_parent.is_trade_item_a_consumer_unit parent_is_item_cons_unit
         ,gtn_attrs.storage_handling_temp_min
         ,gtn_attrs.uom_storage_handling_temp_min
         ,gtn_attrs.storage_handling_temp_max
         ,gtn_attrs.uom_storage_handling_temp_max
         ,mtl2.trade_item_descriptor tiud
         ,gtn_attrs.inventory_item_id inv_id
         ,gtn_attrs_parent.inventory_item_id inv_id1
    FROM mtl_system_items MTL2,
         bom_inventory_components COM,
         mtl_system_items         MTL1,
         bom_bill_of_materials    BOM,
         ego_item_gtn_attrs_b     gtn_attrs,
         ego_item_gtn_attrs_tl    gtn_attrs_tl,
         ego_item_gtn_attrs_b     gtn_attrs_parent
    WHERE
          NVL(BOM.ALTERNATE_BOM_DESIGNATOR,'XXXXXXXXXXX') =
                     NVL(p_alternate_bom_code,'XXXXXXXXXXX')
      AND COM.BILL_SEQUENCE_ID = BOM.COMMON_BILL_SEQUENCE_ID
      AND BOM.ORGANIZATION_ID = p_organization_id
      AND BOM.ASSEMBLY_ITEM_ID = p_item_id
      AND MTL1.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
      AND MTL1.ORGANIZATION_ID = BOM.ORGANIZATION_ID
      AND MTL2.INVENTORY_ITEM_ID = COM.COMPONENT_ITEM_ID
      AND MTL2.ORGANIZATION_ID = BOM.ORGANIZATION_ID
      AND COM.IMPLEMENTATION_DATE IS NOT NULL
      AND NVL(COM.ECO_FOR_PRODUCTION,2) = 2
      AND COM.COMPONENT_QUANTITY > 0
      AND NOT  (mtl1.replenish_to_order_flag = 'Y'
                  AND mtl1.bom_item_type = 4
                  AND mtl1.base_item_id IS NOT NULL
                  AND MTL2.BOM_ITEM_TYPE IN (1,2)
               )
      AND ( COM.DISABLE_DATE IS NULL
            OR
             COM.DISABLE_DATE > p_eff_date
         )
      AND ( (    MTL1.EFFECTIVITY_CONTROL <> 1
            AND p_unit_number is NOT NULL
            AND COM.DISABLE_DATE IS NULL
            AND p_unit_number BETWEEN COM.FROM_END_ITEM_UNIT_NUMBER
            AND NVL(COM.TO_END_ITEM_UNIT_NUMBER, p_unit_number)
           )
         OR
          (
                MTL1.EFFECTIVITY_CONTROL = 1
            AND COM.EFFECTIVITY_DATE <=  p_eff_date
          )
         )
      AND mtl2.inventory_item_id = gtn_attrs.inventory_item_id (+)
      AND mtl2.organization_id   = gtn_attrs.organization_id (+)
      AND mtl1.inventory_item_id = gtn_attrs_parent.inventory_item_id (+) -- attributes of the parent
      AND mtl1.organization_id   = gtn_attrs_parent.organization_id (+)   -- attributes of the parent
      AND gtn_attrs_tl.inventory_item_id(+) = gtn_attrs.inventory_item_id
      AND gtn_attrs_tl.organization_id(+)= gtn_attrs.organization_id
      AND gtn_attrs_tl.extension_id(+)= gtn_attrs.extension_id
      AND gtn_attrs_tl.language(+) = USERENV('LANG')
      FOR UPDATE OF
          mtl2.unit_weight
          ,gtn_attrs.gross_weight
          --UOM ROLLUP
          , mtl2.WEIGHT_UOM_CODE
          ,gtn_attrs.UOM_GROSS_WEIGHT
          --UOM ROLLUP
          ,gtn_attrs.top_gtin
          ,gtn_attrs.brand_owner_name
          ,gtn_attrs.brand_owner_gln
          ,gtn_attrs_tl.functional_name
          ,gtn_attrs.storage_handling_temp_min
          ,gtn_attrs.uom_storage_handling_temp_min
          ,gtn_attrs.storage_handling_temp_max
          ,gtn_attrs.uom_storage_handling_temp_max
          NOWAIT;

    CURSOR row_exist_gtin_attrs IS
     SELECT inventory_item_id
     FROM ego_item_gtn_attrs_b
     WHERE   inventory_item_id = p_item_id
     AND organization_id = p_organization_id;

   CURSOR get_gdsn_enabled IS
    SELECT GDSN_OUTBOUND_ENABLED_FLAG
    FROM mtl_system_items_b
    WHERE inventory_item_id = p_item_id
    AND organization_id = p_organization_id;

    x_row_id VARCHAR2(1000);

    l_stmt varchar2(5);
    l_comp_sequence NUMBER;
    l_indx NUMBER;
    l_act_indx NUMBER;
    l_Hdr_Bill_Seq_Id NUMBER;
    l_first_run BOOLEAN;
    l_parent_item_tbl Item_Org_Tbl;

    l_inv_item_id NUMBER;
    l_ext_id  NUMBER;
    l_catalog_id NUMBER;
    l_login_id NUMBER;
    l_user_id NUMBER;
    l_gdsn_enabled VARCHAR2(5);

  BEGIN

    l_stmt := '1';


    --
    -- Set the top Organization and Item Id
    --
    Set_Top_Item_Id(p_Inventory_Item_Id   => p_item_id);
    Set_Top_Organization_Id(p_Organization_Id => p_Organization_Id);

    -- Rollup optimization:
    --  store ids of items in the lineage leading up to added/deleted component
    --  so that we can suppress dml updates of components outside this lineage
    IF p_parent_item_id IS NOT NULL THEN
      l_parent_item_tbl(p_component_item_id).inventory_item_id := p_component_item_id;
      l_parent_item_tbl(p_component_item_id).organization_id := p_organization_id;
      l_parent_item_tbl(p_parent_item_id).inventory_item_id := p_parent_item_id;
      l_parent_item_tbl(p_parent_item_id).organization_id := p_organization_id;
    END IF;

    For l_LevelCode_rec in l_LowLevelCode_csr loop
      l_depth := l_LevelCode_rec.depth;
    End loop;

      For l_level in reverse 0..l_depth
      LOOP
        WRITE_DEBUG_LOG (
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => l_depth || ' with depth and level ' || l_level);

          l_stmt := '2';
          --
          -- Begin the reverse topology traversal
          --
          l_Header_Attrs_Map.DELETE; -- clean and start
          l_component_seq_tbl.DELETE;
          l_component_seq_attrs_tbl.DELETE;
          FOR l_assy_rec in c_assy_csr(  p_level    => l_level,
                                         p_rollup_id  => p_rollup_id)
          LOOP  -- Assembly cursor
                  WRITE_DEBUG_LOG (
                  p_bo_identifier   => G_BO_IDENTIFIER
                , p_message         => 'Inside Assembly Cursor for '||l_assy_rec.inventory_item_id);

              l_stmt := '3';
              Set_Current_Item_Id(p_Inventory_Item_Id             => l_assy_rec.inventory_item_id);
              Set_Current_Organization_Id(p_Organization_Id       => p_Organization_Id);

              l_Header_Attrs_Map.DELETE; -- clean and start
              l_component_seq_tbl.DELETE;
              l_component_seq_attrs_tbl.DELETE;
              l_component_attrs.DELETE;   -- this is the attributes table of a component stored in attrs_map

              l_inv_item_id := NULL;

              l_user_id := FND_GLOBAL.USER_ID;
              l_login_id := FND_GLOBAL.LOGIN_ID;

              SELECT item_catalog_group_id
              INTO l_catalog_id
              FROM mtl_system_items_b
              WHERE inventory_item_id = p_item_id
              AND organization_id = p_organization_id;

              IF l_catalog_id IS NULL THEN
                l_catalog_id := -1;
              END IF;

              OPEN   row_exist_gtin_attrs;
              FETCH row_exist_gtin_attrs INTO l_inv_item_id;
              CLOSE row_exist_gtin_attrs;

              OPEN get_gdsn_enabled;
              FETCH get_gdsn_enabled INTO l_gdsn_enabled;
              CLOSE get_gdsn_enabled;


              IF l_inv_item_id IS NULL THEN
               IF nvl(l_gdsn_enabled,'N') = 'Y' THEN

              SELECT  EGO_EXTFWK_S.NEXTVAL INTO l_ext_id FROM dual;

              EGO_ITEM_GTN_ATTRS_PKG.INSERT_ROW (
                 x_ROWID =>  x_row_id
                ,x_EXTENSION_ID => l_ext_id
                ,x_REQUEST_ID => null
                ,x_DELIVERY_TO_MRKT_TEMP_MIN => null
                ,x_UOM_DELIVERY_TO_MRKT_TEMP_MI => null
                ,x_SUB_BRAND => null
                ,x_UOM_DEL_TO_DIST_CNTR_TEMP_MI => null
                ,x_DELIVERY_TO_MRKT_TEMP_MAX => null
                ,x_UOM_DELIVERY_TO_MRKT_TEMP_MA => null
                ,x_INVENTORY_ITEM_ID => p_item_id
                ,x_ORGANIZATION_ID => p_organization_id
                ,x_ITEM_CATALOG_GROUP_ID => l_catalog_id
                ,x_REVISION_ID => null
                ,x_IS_TRADE_ITEM_A_CONSUMER_UNI => null
                ,x_IS_TRADE_ITEM_INFO_PRIVATE => null
                ,x_GROSS_WEIGHT => null
                ,x_UOM_GROSS_WEIGHT => null
                ,x_EFFECTIVE_DATE => sysdate
                ,x_CANCELED_DATE => null
                ,x_DISCONTINUED_DATE => null
                ,x_END_AVAILABILITY_DATE_TIME => null
                ,x_START_AVAILABILITY_DATE_TIME => null
                ,x_BRAND_NAME => null
                ,x_IS_TRADE_ITEM_A_BASE_UNIT => null
                ,x_IS_TRADE_ITEM_A_VARIABLE_UNI => null
                ,x_IS_PACK_MARKED_WITH_EXP_DATE => null
                ,x_IS_PACK_MARKED_WITH_GREEN_DO => null
                ,x_IS_PACK_MARKED_WITH_INGRED => null
                ,x_IS_PACKAGE_MARKED_AS_REC => null
                ,x_IS_PACKAGE_MARKED_RET => null
                ,x_STACKING_FACTOR => null
                ,x_STACKING_WEIGHT_MAXIMUM => null
                ,x_UOM_STACKING_WEIGHT_MAXIMUM => null
                ,x_ORDERING_LEAD_TIME => null
                ,x_UOM_ORDERING_LEAD_TIME => null
                ,x_ORDER_QUANTITY_MAX => null
                ,x_ORDER_QUANTITY_MIN => null
                ,x_ORDER_QUANTITY_MULTIPLE => null
                ,x_ORDER_SIZING_FACTOR => null
                ,x_EFFECTIVE_START_DATE => null
                ,x_CATALOG_PRICE => null
                ,x_EFFECTIVE_END_DATE => null
                ,x_SUGGESTED_RETAIL_PRICE => null
                ,x_MATERIAL_SAFETY_DATA_SHEET_N => null
                ,x_HAS_BATCH_NUMBER => null
                ,x_IS_NON_SOLD_TRADE_RET_FLAG => null
                ,x_IS_TRADE_ITEM_MAR_REC_FLAG => null
                ,x_DIAMETER => null
                ,x_UOM_DIAMETER => null
                ,x_DRAINED_WEIGHT => null
                ,x_UOM_DRAINED_WEIGHT => null
                ,x_GENERIC_INGREDIENT => null
                ,x_GENERIC_INGREDIENT_STRGTH => null
                ,x_UOM_GENERIC_INGREDIENT_STRGT => null
                ,x_INGREDIENT_STRENGTH => null
                ,x_IS_NET_CONTENT_DEC_FLAG => null
                ,x_NET_CONTENT => null
                ,x_UOM_NET_CONTENT => null
                ,x_PEG_HORIZONTAL => null
                ,x_UOM_PEG_HORIZONTAL => null
                ,x_PEG_VERTICAL => null
                ,x_UOM_PEG_VERTICAL => null
                ,x_CONSUMER_AVAIL_DATE_TIME => null
                ,x_DEL_TO_DIST_CNTR_TEMP_MAX => null
                ,x_UOM_DEL_TO_DIST_CNTR_TEMP_MA => null
                ,x_DEL_TO_DIST_CNTR_TEMP_MIN => null
                ,x_TRADE_ITEM_DESCRIPTOR => null
                ,x_EANUCC_CODE => null
                ,x_EANUCC_TYPE => null
                ,x_RETAIL_PRICE_ON_TRADE_ITEM => null
                ,x_QUANTITY_OF_COMP_LAY_ITEM => null
                ,x_QUANITY_OF_ITEM_IN_LAYER => null
                ,x_QUANTITY_OF_ITEM_INNER_PACK => null
                ,x_TARGET_MARKET_DESC => null
                ,x_QUANTITY_OF_INNER_PACK => null
                ,x_BRAND_OWNER_GLN => null
                ,x_BRAND_OWNER_NAME => null
                ,x_STORAGE_HANDLING_TEMP_MAX => null
                ,x_UOM_STORAGE_HANDLING_TEMP_MA => null
                ,x_STORAGE_HANDLING_TEMP_MIN => null
                ,x_UOM_STORAGE_HANDLING_TEMP_MI => null
                ,x_TRADE_ITEM_COUPON => null
                ,x_DEGREE_OF_ORIGINAL_WORT => null
                ,x_FAT_PERCENT_IN_DRY_MATTER => null
                ,x_PERCENT_OF_ALCOHOL_BY_VOL => null
                ,x_ISBN_NUMBER => null
                ,x_ISSN_NUMBER => null
                ,x_IS_INGREDIENT_IRRADIATED => null
                ,x_IS_RAW_MATERIAL_IRRADIATED => null
                ,x_IS_TRADE_ITEM_GENETICALLY_MO => null
                ,x_IS_TRADE_ITEM_IRRADIATED => null
                ,x_PUBLICATION_STATUS => null
                ,x_TOP_GTIN => null
                ,x_SECURITY_TAG_LOCATION => null
                ,x_URL_FOR_WARRANTY => null
                ,x_NESTING_INCREMENT => null
                ,x_UOM_NESTING_INCREMENT => null
                ,x_IS_TRADE_ITEM_RECALLED => null
                ,x_MODEL_NUMBER => null
                ,x_PIECES_PER_TRADE_ITEM => null
                ,x_UOM_PIECES_PER_TRADE_ITEM => null
                ,x_DEPT_OF_TRNSPRT_DANG_GOODS_N => null
                ,x_RETURN_GOODS_POLICY => null
                ,x_IS_OUT_OF_BOX_PROVIDED => null
                ,x_REGISTRATION_UPDATE_DATE => null
                ,x_TP_NEUTRAL_UPDATE_DATE => null
                ,x_IS_BARCODE_SYMBOLOGY_DERIVAB => null
                ,x_INVOICE_NAME => null
                ,x_DESCRIPTIVE_SIZE => null
                ,x_FUNCTIONAL_NAME => null
                ,x_TRADE_ITEM_FORM_DESCRIPTION => null
                ,x_WARRANTY_DESCRIPTION => null
                ,x_TRADE_ITEM_FINISH_DESCRIPTIO => null
                ,x_DESCRIPTION_SHORT => null
                ,x_CREATION_DATE => sysdate
                ,x_CREATED_BY => l_user_id
                ,x_LAST_UPDATE_DATE => sysdate
                ,x_LAST_UPDATED_BY => l_user_id
                ,x_LAST_UPDATE_LOGIN => l_login_id);

             END IF; -- tiud
            END IF; -- inv_id

            For l_comps_rec in l_comps_csr (
                p_org_id          => p_organization_id,
                p_item_id         => l_assy_rec.inventory_item_id,
                p_unit_number     => null,
                p_eff_date        => sysdate,
                p_alternate_bom_code  => p_alternate_bom_code
              )
              LOOP
                  l_stmt := '4';

                  -- For all components first compute their
                  -- attribute values
                  l_component_seq_tbl(l_component_seq_tbl.COUNT + 1).component_sequence_id :=
                    l_comps_rec.component_sequence_id;
                  l_component_seq_tbl(l_component_seq_tbl.COUNT).component_item_id :=
                    l_comps_rec.component_item_id;
                  l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT + 1).component_sequence_id :=
                    l_comps_rec.component_sequence_id;

                  l_Component_Attrs := G_ATTRIBUTE_MAP;

                  FOR map_index in 1..G_Attribute_Map.COUNT
                  LOOP
                      --
                      -- Call the compute function of the
                      -- attributes that have been defined
                      -- else use the attribute_value
                      --
                      l_component_attrs(map_index).attribute_name := G_Attribute_Map(map_index).attribute_name;

                      --
                      -- since we are indexing by number, need to have the if
                      -- for attribute name
                      --
                      IF G_Attribute_Map(map_index).attribute_name = 'UNIT_WEIGHT'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.unit_weight;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'GROSS_WEIGHT'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.gross_weight;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'IS_TRADE_ITEM_INFO_PRIVATE'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.is_trade_item_info_private;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'CUSTOMER_ORDER_ENABLED_FLAG'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.customer_order_enabled_flag;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'COMPONENT_QUANTITY'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.component_quantity;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'BRAND_OWNER_NAME'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.brand_owner_name;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'BRAND_OWNER_GLN'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.brand_owner_gln;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'FUNCTIONAL_NAME'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.functional_name;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'SUB_BRAND'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.sub_brand;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'NET_WEIGHT_UOM'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.NET_WT_UOM;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'GROSS_WEIGHT_UOM'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.GROSS_WT_UOM;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'STORAGE_HANDLING_TEMP_MIN'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.storage_handling_temp_min;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'UOM_STORAGE_HANDLING_TEMP_MIN'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.uom_storage_handling_temp_min;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'STORAGE_HANDLING_TEMP_MAX'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.storage_handling_temp_max;
                      ELSIF G_Attribute_Map(map_index).attribute_name = 'UOM_STORAGE_HANDLING_TEMP_MAX'
                      THEN
                          l_component_attrs(map_index).attribute_value :=
                          l_comps_rec.uom_storage_handling_temp_max;
                      END IF;

                      l_comp_sequence := l_comps_rec.component_sequence_id;

                      IF G_Attribute_Map(map_index).compute_function is not null
                      THEN
                      /*

                      -- call the compute function
                      EXECUTE IMMEDIATE ' ' ||
                      ' BEGIN ' ||
                      G_Attribute_Map(map_index).compute_function ||
                      '(:attr,:component_sequence_id); END;'
                      USING IN OUT l_component_attrs(map_index).computed_value,
                      l_comp_sequence;
                      */
                          null;
                      ELSE
                          null;
                      --
                      -- no need to copy the original value into the computed value
                      -- since we'll use the original value if the computed field is
                      -- blank.
                      --
                      END IF;

                  END LOOP;  --1..G_ATTRIBUTE_MAP.Count

                  -- store back the component attribute map
                  -- this location is initialized at the start so just use COUNT.
                  l_component_seq_tbl(l_component_seq_tbl.COUNT).component_sequence_id :=
                    l_comps_rec.component_sequence_id;

                  -- copy into comp_map_map
                  l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).component_sequence_id :=
                    l_comps_rec.component_sequence_id;

                  l_first_run := TRUE;
                  FOR i IN l_Component_Attrs.FIRST .. l_Component_Attrs.LAST LOOP

                    IF NOT l_first_run THEN

                      l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT + 1).component_sequence_id :=
                        l_comps_rec.component_sequence_id;

                    END IF;

                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).object_name :=
                      l_Component_Attrs(i).object_name;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).attribute_group :=
                      l_Component_Attrs(i).attribute_group;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).attribute_name :=
                      l_Component_Attrs(i).attribute_name;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).attribute_value :=
                      l_Component_Attrs(i).attribute_value;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).computed_value :=
                      l_Component_Attrs(i).computed_value;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).compute_function :=
                      l_Component_Attrs(i).compute_function;
                    l_component_seq_attrs_tbl(l_component_seq_attrs_tbl.COUNT).attribute_type :=
                      l_Component_Attrs(i).attribute_type;

                    l_first_run := FALSE;

                  END LOOP;

              END LOOP; -- components

              l_stmt := '5';
              --
              -- Once all the attributes are computed then proceed with invoking the
              -- attribute rollup functions. The function would know what it should do
              -- with the attributes. The Rollup function will have access to the
              --
              l_Header_Attrs_Map.DELETE; -- clean and start

--Commented for leaf node
/*              IF l_component_attrs_map.COUNT <> 0
              THEN*/
                  FOR action_index in 1..p_action_map.COUNT
                  LOOP
                      --
                      -- Perform rollup for all the top level
                      --
                      FOR l_indx IN 1..G_Rollup_Action_Map.COUNT
                      LOOP
                        IF G_Rollup_Action_Map(l_indx).Rollup_Action =
                        p_action_map(action_index).Rollup_Action
                        THEN
                        l_act_indx := l_indx;
                        END IF;
                      END LOOP;


                      WRITE_DEBUG_LOG (
                        p_bo_identifier   => G_BO_IDENTIFIER
                      , p_message         => 'Calling Rollup Function '||G_Rollup_Action_Map(l_act_indx).Rollup_function);

                      EXECUTE IMMEDIATE ' ' ||
                      ' BEGIN ' || G_Rollup_Action_Map(l_act_indx).Rollup_function ||
                      '(:header_item_id, :organization_id, :validate, :halt_on_error, :return_status, :error_message); END;'
                      USING IN l_assy_rec.inventory_item_id
                           ,IN p_organization_id
                           ,IN p_validate
                           ,IN p_halt_on_error
                           ,OUT x_return_status
                           ,OUT x_msg_data;

                      IF p_halt_on_error = 'Y' AND
                         x_return_status IS NOT NULL AND
                         x_return_status <> 'S' THEN

                        WRITE_DEBUG_LOG (
                          p_bo_identifier   => G_BO_IDENTIFIER
                        , p_message         => 'Error in Rollup Function, halting rollup. ret='||x_return_status||' msgdata='||x_msg_data);

                        CLOSE l_LowLevelCode_csr;
                        CLOSE c_assy_csr;
                        CLOSE l_comps_csr;
                        RETURN;

                      END IF;

                  END LOOP;
              --END IF;

              --
              -- Now that the attributes are computed and the rollup for that level has happened
              -- write the data for that sub-tree node.
              --

              -- For the TOP Item also process the attributes only maintained at the top level.
              IF l_assy_rec.inventory_item_id = Bom_Rollup_Pub.Get_top_Item_Id
              THEN
                  Handle_Attribute_Updates(  p_Header_Item_Id => l_assy_rec.inventory_item_id
                  , p_organization_id   => p_organization_id
                  , p_header_attrs_flag => 'N'
                  , p_action_map        => p_action_map
                  , x_return_status     => x_return_status
                  , x_msg_count         => x_msg_count
                  , x_msg_data          => x_msg_data
                  );
              END IF;

              -- suppress updates of attributes for items outside p_parent_item_id's lineage
              IF p_parent_item_id IS NULL OR
                 l_parent_item_tbl.EXISTS(l_assy_rec.inventory_item_id) THEN

                -- add to table keeping track of p_component_item_id's lineage
                IF p_parent_item_id IS NOT NULL AND
                   l_assy_rec.parent_item_id IS NOT NULL AND
                   NOT l_parent_item_tbl.EXISTS(l_assy_rec.parent_item_id)
                THEN
                  l_parent_item_tbl(l_assy_rec.parent_item_id).inventory_item_id := l_assy_rec.parent_item_id;
                  l_parent_item_tbl(l_assy_rec.parent_item_id).organization_id := p_organization_id;
                END IF;

                Handle_Attribute_Updates(  p_Header_Item_Id => l_assy_rec.inventory_item_id
                , p_organization_id   => p_organization_id
                , p_header_attrs_flag => 'Y'
                , p_action_map        => p_action_map
                , x_return_status     => x_return_status
                , x_msg_count         => x_msg_count
                , x_msg_data          => x_msg_data
                );

              END IF; -- p_parent_item_id is null or l_parent_item_tbl contains item_id

          END LOOP; -- Assembly cursor

                  WRITE_DEBUG_LOG (
                  p_bo_identifier   => G_BO_IDENTIFIER
                , p_message         => 'After Assembly Cursor');

      END LOOP; -- Reverse Topology Traversal Ends

  END Handle_Rollup_Actions;

  PROCEDURE Perform_Rollup_Private
  (  p_item_id            IN  NUMBER
   , p_organization_id    IN  NUMBER
   , p_parent_item_id     IN  NUMBER
   , p_structure_type_id  IN  NUMBER
   , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map := G_EMPTY_ACTION_MAP
   , p_validate           IN  VARCHAR2
   , p_halt_on_error      IN  VARCHAR2
   , x_error_message      OUT NOCOPY VARCHAR2
  )
  IS


    CURSOR c_Top_Items(p_sequence_id        NUMBER)
    IS
    SELECT impl.parent_item_id
          , impl.organization_id
          , impl.parent_alternate_designator
          , structure_type_id
     FROM bom_implosions_v impl
     where
            impl.sequence_id = p_sequence_id
       and  impl.top_item_flag='Y'
       and ( current_level = 0
     OR EXISTS(SELECT 1
    FROM bom_structures_b bom
         WHERE bom.assembly_item_id  = impl.parent_item_id
           AND bom.organization_id   = impl.organization_id
           AND nvl(bom.alternate_bom_designator,'xxxxxxxxxxx') =
        nvl(impl.parent_alternate_designator,'xxxxxxxxxxx')
               AND bom.is_preferred      = 'Y'
                AND bom.structure_type_id = p_structure_type_id
                AND impl.structure_type_id = p_structure_type_id
         )
     );

    CURSOR c_Preferred_Structure(p_assembly_item_id in varchar2,
                                 p_org_id in varchar2,
                                  p_struct_type_id in varchar2)
    IS
    SELECT
      alternate_bom_designator
    FROM
      bom_structures_b
    WHERE
          assembly_item_id = p_assembly_item_id
      AND organization_id = p_org_id
      AND structure_type_id = p_struct_type_id
      AND is_Preferred = 'Y';

    l_rollup_id           NUMBER;
    l_Sequence            NUMBER;
    l_alternate_bom_code  varchar2(30) := FND_LOAD_UTIL.NULL_VALUE;
    l_parents_for_pk1  number;
    l_check_no_bill boolean := true;
    l_check_preferred boolean := true;
    l_rollup_item_id number;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
  BEGIN
    if (Bom_Rollup_Pub.g_attr_diffs is null) then
    --Initialize Error Hanlder
      Initialize_ErrorDebug_Handler;
    end if;

    WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'Perform_Rollup_Private called item '||p_item_id||'-'||p_organization_id||' parent item '||p_parent_item_id);
    -- Rollup optimization:
    --  changed to parent so that comp. addition does not trigger additional rollups
    l_rollup_item_id := NVL(p_parent_item_id, p_item_id);

    -- Ensure that this item is UCCNet enabled
    IF (Is_Pack_Item(p_item_id, p_organization_id) <> 'Y')
    THEN
      WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'Perform_Rollup_Private called on non-pack item '||p_item_id||'-'||p_organization_id||' ['||Is_Pack_Item(p_item_id, p_organization_id)||']');
      RETURN;
    END IF;

    WRITE_DEBUG_LOG(G_BO_IDENTIFIER, '*****************TESTING****************');
    IF G_Attribute_Map.COUNT = 0
    THEN
            Load_Attribute_Map;
    END IF;

    IF G_Rollup_Action_Map.COUNT = 0
    THEN
      Load_Rollup_Action_Map;
    END IF;

--For disabling we need to get the preferred alternate structure
    for pralt in c_Preferred_Structure(p_assembly_item_id => p_item_id
                                       ,p_org_id => p_organization_id
                                       ,p_struct_type_id => p_structure_type_id)

    LOOP
      l_alternate_bom_code := pralt.alternate_bom_designator;
    END LOOP;


    --
    -- Load the top items for rollup
    --
    Load_Top_Items( p_item_id            => l_rollup_item_id
                  , p_organization_id    => p_organization_id
                  , p_alternate_bom_code => l_alternate_bom_code
                  , x_Sequence           => l_Sequence
                  );

    WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'Structure Type Id is ' || p_structure_type_id);

     BEGIN
     IF (p_structure_type_id IS NOT NULL)
     THEN
        SELECT
            COUNT(COMPONENT_SEQUENCE_ID) INTO l_parents_for_pk1
        from
            BOM_SMALL_IMPL_TEMP
        WHERE
              LOWEST_ITEM_ID = l_rollup_item_id
          AND ORGANIZATION_ID = p_organization_id
          AND CURRENT_LEVEL > 0
          AND SEQUENCE_ID = l_Sequence; --changed to 0 as the sql won't work

        BEGIN
          IF (l_parents_for_pk1 = 0)
          THEN
            SELECT
              ALTERNATE_BOM_DESIGNATOR INTO  l_alternate_bom_code
            FROM
              BOM_STRUCTURES_B
            WHERE
                   ASSEMBLY_ITEM_ID = l_rollup_item_id
               AND ORGANIZATION_ID = p_organization_id
               AND STRUCTURE_TYPE_ID = p_structure_type_id
               AND IS_PREFERRED = 'Y';

            UPDATE
              BOM_SMALL_IMPL_TEMP
            SET
              TOP_ITEM_FLAG ='Y',
              ALTERNATE_DESIGNATOR = l_alternate_bom_code,
              STRUCTURE_TYPE_ID = p_structure_type_id
            WHERE
                  CURRENT_LEVEL = 0
              AND SEQUENCE_ID = l_Sequence
              AND LOWEST_ITEM_ID = l_rollup_item_id
              AND ORGANIZATION_ID = p_organization_id ;
          END IF;
          EXCEPTION
          WHEN OTHERS THEN
            l_alternate_bom_code := NULL;
            BEGIN
              UPDATE
                BOM_SMALL_IMPL_TEMP
              SET
                TOP_ITEM_FLAG ='Y'
              WHERE
                    CURRENT_LEVEL = 0
                AND SEQUENCE_ID = l_Sequence
                AND LOWEST_ITEM_ID = l_rollup_item_id
                AND ORGANIZATION_ID = p_organization_id ;
            END;
        END;
     END IF;
     END;

    FOR top_items in c_Top_Items(p_sequence_id      => l_Sequence)
    LOOP
      WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE C_TOP_ITEMS' || top_items.structure_type_id
|| ' sequence '||l_Sequence||' parent alt '||top_items.parent_alternate_designator
      );
      --if (top_items.structure_type_id is not null) then
        l_check_no_bill := false;
        --Removed for 11.5.10-E
        --delete from bom_explosions_all;
        l_rollup_id := to_number(to_char(sysdate,'SSSS'));


        l_Top_Item_Attrs_Map.DELETE;
        l_Header_Attrs_Map.DELETE;
        -- This map must be clean for every new top item.

        WRITE_DEBUG_LOG (
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => 'Calling Explosion');

        BOMPCCLT.Process_Items(
            p_org_id              => p_organization_id
          , p_item_id             => top_items.parent_item_id
          , p_roll_id             => l_rollup_id
          , p_unit_number         => null
          , p_eff_date            => sysdate
          , p_alternate_bom_code  => top_items.parent_alternate_designator
          , p_prgm_id             => -1
          , p_prgm_app_id         => -1
          , p_req_id              => -1
          , x_err_msg             => x_error_message
         );

        WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'B4 Validate Hierarchy Attrs');

        /* Added validation for UCCNET 3.0 Certification */
        BOM_GTIN_RULES.Validate_Hierarchy_ATTRS (
            p_group_id      => l_rollup_id
          , x_return_status => l_return_status
          , x_error_message => x_error_message);

      WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'After Validate Hierarchy Attrs Status' || l_return_status);

        IF l_return_status IS NOT NULL AND
           l_return_status <> 'S'
        THEN
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'ERROR in Validate Hierarchy Attrs! ['||l_return_status||']'||x_error_message);
          Close_ErrorDebug_Handler;
          RETURN;
        END IF;

        WRITE_DEBUG_LOG (
        p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => 'Finished Explosion with error message ' || x_error_message);

      --Run Rollup for only preferred Structures
      --Check isPrefered
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE is_preferred_check_cr assitem' || top_items.parent_item_id );
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE is_preferred_check_cr orgid' || p_organization_id );
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE is_preferred_check_cr structure' || p_structure_type_id );

        For is_preferred_check_cr in c_Preferred_Structure(p_assembly_item_id => top_items.parent_item_id
                                               ,p_org_id => p_organization_id
                                               ,p_struct_type_id => p_structure_type_id)

        LOOP
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE is_preferred_check_cr top_items. parent alt desig'  || top_items.parent_alternate_designator );
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'INSIDE is_preferred_check_cr pref alt desig ' || is_preferred_check_cr.alternate_bom_designator );

              if (nvl(top_items.parent_alternate_designator,'XXXXXXXX') = nvl(is_preferred_check_cr.alternate_bom_designator,'XXXXXXXX')) then
                l_check_preferred := true;
              else
                l_check_preferred := false;
              end if;
        END LOOP;

        if (l_check_preferred) then
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'Before Handle Rollup Actions');
          Handle_Rollup_Actions (
              p_rollup_id          => l_rollup_id
            , p_action_map         => p_action_map
            , p_item_id            => top_items.parent_item_id
            , p_organization_id    => p_organization_id
            , p_parent_item_id     => p_parent_item_id
            , p_component_item_id  => p_item_id
            , p_alternate_bom_code => top_items.parent_alternate_designator
            , p_validate           => p_validate
            , p_halt_on_error      => p_halt_on_error
            , x_return_status      => l_return_status
            , x_msg_count          => l_msg_count
            , x_msg_data           => x_error_message
          );
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'After Handle Rollup Actions');

          -- do not proceed with any other rollups if error is found
          IF p_halt_on_error = 'Y' AND
             l_return_status IS NOT NULL AND
             l_return_status <> 'S'
          THEN

            WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'ERROR in Handle Rollup Actions! ['||l_return_status||']'||x_error_message);
            Close_ErrorDebug_Handler;
            RETURN;

          END IF;
        end if;
      --end if;
    END LOOP;

    --Close Error Hanlder
    Close_ErrorDebug_Handler;



  END Perform_Rollup_Private;

  PROCEDURE Perform_Rollup_Private
  (  p_item_id            IN  NUMBER
   , p_organization_id    IN  NUMBER
   , p_alternate_bom_code IN  VARCHAR2
   , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map := G_EMPTY_ACTION_MAP
   , p_validate           IN  VARCHAR2
   , p_halt_on_error      IN  VARCHAR2
   , x_error_message      OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR c_Top_Items(p_sequence_id  NUMBER)
    IS
    SELECT parent_item_id
         , organization_id
      FROM bom_implosions_v
     WHERE sequence_id = p_sequence_id
       AND top_item_flag = 'Y';

    l_rollup_id   NUMBER;
    l_Sequence    NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count   NUMBER;
  BEGIN
    if (Bom_Rollup_Pub.g_attr_diffs is null) then
    --Initialize Error Hanlder
      Initialize_ErrorDebug_Handler;
    end if;

    IF G_Attribute_Map.COUNT = 0
    THEN
            Load_Attribute_Map;
    END IF;

    IF G_Rollup_Action_Map.COUNT = 0
    THEN
            Load_Rollup_Action_Map;
    END IF;
    --
    -- Load the top items for rollup
    --

    Load_Top_Items( p_item_id            => p_item_id
                  , p_organization_id    => p_organization_id
                  , p_alternate_bom_code => p_alternate_bom_code
                  , x_Sequence           => l_Sequence
                  );

    FOR top_items in c_Top_Items(p_sequence_id  => l_Sequence)
    LOOP
      --Removed for 11.5.10-E
      --delete from bom_explosions_all;
      l_rollup_id := to_number(to_char(sysdate,'SSSS'));


      l_Top_Item_Attrs_Map.DELETE;
      l_Header_Attrs_Map.DELETE;
      -- This map must be clean for every new top item.

   WRITE_DEBUG_LOG (
    p_bo_identifier   => G_BO_IDENTIFIER
  , p_message         => 'Processing Items for Explosion' );

      BOMPCCLT.Process_Items(
                p_org_id              => p_organization_id
      , p_item_id   => top_items.parent_item_id
              , p_roll_id             => l_rollup_id
              , p_unit_number         => null
              , p_eff_date            => sysdate
              , p_alternate_bom_code  => p_alternate_bom_code
              , p_prgm_id             => -1
              , p_prgm_app_id         => -1
              , p_req_id              => -1
              , x_err_msg             => x_error_message
       );
        WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'B4 - 1 Validate Hierarchy Attrs');

        BOM_GTIN_RULES.Validate_Hierarchy_ATTRS (
            p_group_id      => l_rollup_id
          , x_return_status => l_return_status
          , x_error_message => x_error_message);

        WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'After - 1 Validate Hierarchy Attrs Status' || l_return_status);

        IF l_return_status IS NOT NULL AND
           l_return_status <> 'S'
        THEN
          WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'ERROR in Validate Hierarchy Attrs! ['||l_return_status||']'||x_error_message);
          Close_ErrorDebug_Handler;
          RETURN;
        END IF;

   WRITE_DEBUG_LOG (
    p_bo_identifier   => G_BO_IDENTIFIER
  , p_message         => 'Handling ROllup Actions' );

      Handle_Rollup_Actions
      ( p_rollup_id          => l_rollup_id
      , p_action_map         => p_action_map
      , p_item_id            => top_items.parent_item_id
      , p_organization_id    => p_organization_id
      , p_alternate_bom_code => p_alternate_bom_code
      , p_validate           => p_validate
      , p_halt_on_error      => p_halt_on_error
      , x_return_status      => l_return_status
      , x_msg_count          => l_msg_count
      , x_msg_data           => x_error_message
      );

      -- do not proceed with any other rollups if error is found
      IF p_halt_on_error = 'Y' AND
         l_return_status IS NOT NULL AND
         l_return_status <> 'S'
      THEN

        WRITE_DEBUG_LOG(G_BO_IDENTIFIER, 'ERROR in Handle Rollup Actions! ['||l_return_status||']'||x_error_message);
        Close_ErrorDebug_Handler;
        RETURN;

      END IF;

      --
      -- Delete the processed rows and clean slate for the next
      -- rollup
      --
      --BOMPCCLT.Delete_Processed_Rows(l_rollup_id);

                END LOOP;

    --Close Error Hanlder
    Close_ErrorDebug_Handler;

  END Perform_Rollup_Private;

/****************** Local Procedures Section Ends ******************/

/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : This method will perform rollup or propogation of attributes
*            The attribute value propogated or computed up the bom is based
*            on the value returned by the compute_function.
*      Compute function will be passed Attribute Map and the list of
*      child components.
*
**************************************************************************/

  PROCEDURE Perform_Rollup
  (  p_item_id            IN  NUMBER
   , p_organization_id    IN  NUMBER
   , p_alternate_bom_code IN  VARCHAR2
   , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map DEFAULT G_EMPTY_ACTION_MAP
   , p_validate           IN  VARCHAR2 /*DEFAULT 'N'*/
   , p_halt_on_error      IN  VARCHAR2 /*DEFAULT 'N'*/
   , x_error_message      OUT NOCOPY VARCHAR2
  )
  IS
  BEGIN

    Perform_Rollup_Private
          (  p_item_id            => p_item_id
           , p_organization_id    => p_organization_id
           , p_alternate_bom_code => p_alternate_bom_code
           , p_action_map         => p_action_map
           , p_validate           => p_validate
           , p_halt_on_error      => p_halt_on_error
           , x_error_message      => x_error_message
    );
  END Perform_Rollup;

/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : Method accepts a Structure Type. The Rollup will happen for the
*      Preferred Structure within the given Structure.
*      This method will perform rollup or propogation of attributes
*            The attribute value propogated or computed up the bom is based
*            on the value returned by the compute_function.
*            Compute function will be passed Attribute Map and the list of
*            child components.
*
**************************************************************************/

  PROCEDURE Perform_Rollup
        (  p_item_id            IN  NUMBER
         , p_organization_id    IN  NUMBER
         , p_parent_item_id     IN  NUMBER := NULL
         , p_structure_type_id  IN  NUMBER
         , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map := G_EMPTY_ACTION_MAP
         , p_validate           IN  VARCHAR2 /*DEFAULT 'N'*/
         , p_halt_on_error      IN  VARCHAR2 /*DEFAULT 'N'*/
         , x_error_message      OUT NOCOPY VARCHAR2
        )
        IS
  BEGIN
    Perform_Rollup_Private
    ( p_item_id            => p_item_id
    , p_organization_id    => p_organization_id
    , p_parent_item_id     => p_parent_item_id
    , p_structure_type_id  => p_structure_type_id
    , p_action_map         => p_action_map
    , p_validate           => p_validate
    , p_halt_on_error      => p_halt_on_error
    , x_error_message      => x_error_message
    );

  END Perform_Rollup;

/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : Method accepts a Structure Type identifier. The Rollup will happen
*            for the Preferred Structure within the given Structure.
*            This method will perform rollup or propogation of attributes
*            The attribute value propogated or computed up the bom is based
*            on the value returned by the compute_function.
*            Compute function will be passed Attribute Map and the list of
*            child components.
*
**************************************************************************/
PROCEDURE Perform_Rollup
(  p_item_id             IN  NUMBER
 , p_organization_id     IN  NUMBER
 , p_parent_item_id      IN  NUMBER := NULL
 , p_structure_type_name IN  VARCHAR2
 , p_action_map          IN  Bom_Rollup_Pub.Rollup_Action_Map := G_EMPTY_ACTION_MAP
 , p_validate            IN  VARCHAR2 /*DEFAULT 'N'*/
 , p_halt_on_error       IN  VARCHAR2 /*DEFAULT 'N'*/
 , x_error_message       OUT NOCOPY VARCHAR2
)
  IS
    CURSOR c_structure_type_id IS
    SELECT structure_type_id
      FROM bom_structure_types_B
     WHERE structure_type_name = p_structure_type_name;
  BEGIN


    FOR struct_type IN c_structure_type_id
    LOOP
      Perform_Rollup_Private
                  (  p_item_id            => p_item_id
                   , p_organization_id    => p_organization_id
                   , p_parent_item_id     => p_parent_item_id
                   , p_structure_type_id  => struct_type.structure_type_id
                   , p_action_map         => p_action_map
                   , p_validate           => p_validate
                   , p_halt_on_error      => p_halt_on_error
                   , x_error_message      => x_error_message
                  );
    END LOOP;

  END Perform_Rollup;


/*********************************************************************
* Function: Get_Rollup_Function
* Purpose : Given an Object and the Rollup Action to be performed, this
*           function will return the Roll function that will be executed.
*
************************************************************************/
Function Get_Rollup_Function
( p_object_name   IN  VARCHAR2
, p_rollup_action IN  VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
  NULL;
  -- not implemented yet.
END Get_Rollup_Function;

/*********************************************************************
* Procedure : Add_Rollup_Function
* Purpose   : This procedure helps build the Action Map. Once the action
*             map is ready, calling application can call perfom_rollup
*       with the Rollup Action Map.
*       The object/action is checked against the supported set of
*       Actions, hence, an incorrect combination will throw a
*       'BOM_OBJECT_ACTION_INVALID' exception.
************************************************************************/
  Procedure Add_Rollup_Function
  ( p_Object_Name       IN VARCHAR2
  , p_Rollup_Action     IN VARCHAR2
  , p_DML_Function      IN VARCHAR2
  , p_DML_Delayed_Write IN VARCHAR2
  , x_Rollup_Action_Map IN OUT NOCOPY Bom_Rollup_Pub.Rollup_Action_Map
  )
  IS
    l_map_index NUMBER := x_Rollup_Action_Map.COUNT + 1;
  BEGIN
    FOR cindex IN 1..x_Rollup_Action_Map.COUNT
    LOOP
      IF(x_Rollup_Action_Map(cindex).Object_Name = p_Object_Name AND
         x_Rollup_Action_Map(cindex).Rollup_Action = p_Rollup_Action AND
         x_Rollup_Action_Map(cindex).DML_Function = p_DML_Function AND
         x_Rollup_Action_Map(cindex).DML_Delayed_Write = p_DML_Delayed_Write
        )
      THEN
        -- do nothing since the action was already registered for the
        -- current session.
        return;
      END IF;

    END LOOP;

    x_Rollup_Action_Map(l_map_index).Object_Name   := p_Object_Name;
    x_Rollup_Action_Map(l_map_index).Rollup_Action := p_Rollup_Action;
    x_Rollup_Action_Map(l_map_index).DML_Function := p_DML_Function;
    x_Rollup_Action_Map(l_map_index).DML_Delayed_Write := p_DML_Delayed_Write;

  END Add_Rollup_Function;

/*********************************************************************
* Procedure : Get_Item_Rollup_Map
* Purpose   : Returns the supported list of Actions for an Object
*
************************************************************************/
  Function Get_Item_Rollup_Map
  ( p_Object_Name   IN  VARCHAR2 )
        RETURN Bom_Rollup_Pub.Rollup_Action_Map
  IS
  BEGIN
    return G_EMPTY_ACTION_MAP;
    -- not implemented yet.

  END Get_Item_Rollup_Map;

/************************************************************************
* Procedure: Set_Parent_Attribute
* Purpose  : Sets the parent attribute. When a computation function
*            completes, if it is an attribute that is updated for the immediate
*            parent, then the computation function needs to set the attribute value
*            for the parent so that the rollup process can issue an call for
*            affected parent.
**************************************************************************/
  PROCEDURE Set_Parent_Attribute
  (  p_attribute_name     IN  VARCHAR2
   , p_attribute_value    IN  VARCHAR2
  )
  IS
    l_header_attr_cnt NUMBER := l_Header_Attrs_Map.COUNT;
  BEGIN
    --
    -- This is a helper method and is intended simply to take the attributed and append
    -- it to the map. this will not offer any intelligence of making sure if the attribute
    -- was already set. So, the calling process should ensure of this.
    -- we would later add this.
    --
    l_Header_Attrs_Map(l_Header_Attr_cnt).attribute_name :=
      p_attribute_name;

    l_Header_Attrs_Map(l_Header_Attr_cnt).attribute_value :=
      p_attribute_value;

  END Set_Parent_Attribute;

/************************************************************************
* Procedure: Set_Parent_Attribute
* Purpose  : Sets the top item's attribute. When a computation function
*            completes, for an attribute that is only computed for the top
*            most parent, the computation function will call this methid to
*            set the Top Item's attribute. The Rollup process will at the
*            end issue an appropriate call to update the affected Item.
**************************************************************************/
  PROCEDURE Set_Top_Item_Attribute
        (  p_attribute_name     IN  VARCHAR2
         , p_attribute_value    IN  VARCHAR2
        )
        IS
                l_header_attr_cnt NUMBER := l_Top_Item_Attrs_Map.COUNT + 1;
        BEGIN
                --
                -- This is a helper method and is intended simply to take the attributed and append
                -- it to the map. this will not offer any intelligence of making sure if the attribute
                -- was already set. So, the calling process should ensure of this.
                -- we would later add this.
                --
    FOR map_index IN 1..l_Top_Item_Attrs_Map.COUNT
    LOOP
      IF(l_Top_Item_Attrs_Map.exists(map_index) AND
         l_Top_Item_Attrs_Map(map_index).attribute_name = p_attribute_name)
      THEN
        l_header_attr_cnt := map_index;
      END IF;
    END LOOP;
                l_Top_Item_Attrs_Map(l_Header_Attr_cnt).attribute_name :=
                        p_attribute_name;
                l_Top_Item_Attrs_Map(l_Header_Attr_cnt).attribute_value :=
                        p_attribute_value;

        END Set_Top_Item_Attribute;


/************************************************************************
* Procedure: Get_Attribute_Value
* Purpose  : Returns the attribute value for an attribute. This method
*            works only off of the reverse tology tree and has access to
*            to immediate children for a parent being processed.
*            When a computation function needs attribute value for a
*            component, it will request so by passing the component identifier
*            and the attribute name.
**************************************************************************/
  FUNCTION Get_Attribute_Value
  (  p_component_sequence_id  IN  NUMBER
   , p_attribute_name   IN  VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    FOR cmp_index IN Bom_Rollup_Pub.l_component_seq_attrs_tbl.FIRST..Bom_Rollup_Pub.l_component_seq_attrs_tbl.LAST
    LOOP
      IF  Bom_Rollup_Pub.l_component_seq_attrs_tbl.EXISTS(cmp_index) AND
          Bom_Rollup_Pub.l_component_seq_attrs_tbl(cmp_index).component_sequence_id = p_component_sequence_id AND
          Bom_Rollup_Pub.l_component_seq_attrs_tbl(cmp_index).attribute_name = p_attribute_name
      THEN
        return Bom_Rollup_Pub.l_component_seq_attrs_tbl(cmp_index).attribute_value;
      END IF;
    END LOOP;

  END Get_Attribute_Value;


/************************************************************************
* Procedure: Get_Top_Item_Attribute_Value
* Purpose  : Returns the attribute value for an attribute. This method
*            works only off of the reverse tology tree and has access to
*            to immediate children for a parent being processed.
*            When a computation function needs attribute value for a
*            component, it will request so by passing the component identifier
*            and the attribute name.
**************************************************************************/
  FUNCTION Get_Top_Item_Attribute_Value
  (  p_attribute_name             IN  VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    IF Bom_Rollup_Pub.l_Top_Item_Attrs_Map.COUNT = 0
    THEN
      RETURN NULL;
    END IF;

                FOR cmp_index IN Bom_Rollup_Pub.l_Top_Item_Attrs_Map.FIRST..Bom_Rollup_Pub.l_Top_Item_Attrs_Map.LAST
                LOOP
                        IF  Bom_Rollup_Pub.l_Top_Item_Attrs_Map.EXISTS(cmp_index)  AND
                            Bom_Rollup_Pub.l_Top_Item_Attrs_Map(cmp_index).attribute_name = p_attribute_name
                        THEN
                              return Bom_Rollup_Pub.l_Top_Item_Attrs_Map(cmp_index).attribute_value;
                        END IF;
                END LOOP;

    -- else return NULL
    RETURN null;

  END Get_Top_Item_Attribute_Value;

/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : This method will perform rollup for multi-row attributes or
*            propogation of multi-row attributes
*            The attribute value propogated or computed up the bom is based
*            on the value returned by the compute_function.
*            The propogation happens for only the attributes being passed
*            in EGO_USER_ATTR_DIFF_TABLE
**************************************************************************/
  PROCEDURE Perform_Rollup
  (   p_item_id            IN  NUMBER
    , p_organization_id    IN  NUMBER
    , p_structure_type_name  IN  VARCHAR2
    , p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
    , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
    , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
    , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
    , p_transaction_type              IN VARCHAR2
    , p_attr_group_id                 IN NUMBER
    , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map DEFAULT G_EMPTY_ACTION_MAP
    , x_error_message      OUT NOCOPY VARCHAR2
  ) is
  begin

   Initialize_ErrorDebug_Handler;

   WRITE_DEBUG_LOG (
                    p_bo_identifier   => G_BO_IDENTIFIER
                , p_message         => 'INSIDE Multi-Row Item Call');

    IF (p_attr_diffs IS NOT NULL AND p_attr_diffs.COUNT > 0) THEN -- is the object null
      Bom_Rollup_Pub.g_pk_column_name_value_pairs   := p_pk_column_name_value_pairs;
      Bom_Rollup_Pub.g_class_code_name_value_pairs  := p_class_code_name_value_pairs;
      Bom_Rollup_Pub.g_data_level_name_value_pairs  := p_data_level_name_value_pairs;
      Bom_Rollup_Pub.g_attr_diffs                   := p_attr_diffs;
      Bom_Rollup_Pub.g_transaction_type             := p_transaction_type;
      Bom_Rollup_Pub.g_attr_group_id                := p_attr_group_id;
      WRITE_DEBUG_LOG (
                    p_bo_identifier   => G_BO_IDENTIFIER
                , p_message         => 'INSIDE Multi-Row Item Call with txn type' || p_transaction_type);
    END IF;

            Perform_Rollup
                    ( p_item_id            => p_item_id
                    , p_organization_id    => p_organization_id
                    , p_structure_type_name  => p_structure_type_name
                    , p_action_map         => p_action_map
                    , x_error_message      => x_error_message
                    );

  end Perform_Rollup;

  FUNCTION Is_UCCNet_Enabled(p_inventory_item_id IN NUMBER
                            ,p_organization_id   IN NUMBER
                            )
    RETURN VARCHAR2
    IS
      CURSOR c_check_if_uccnet(p_inventory_item_id NUMBER
                              ,p_organization_id NUMBER) IS
        SELECT 'X' assignment_present
          FROM mtl_default_category_sets a
             , mtl_item_categories b
         WHERE a.functional_area_id = 12
           AND a.category_set_id = b.category_set_id
           AND rownum = 1
           AND inventory_item_id = p_inventory_item_id
           AND organization_id = p_organization_id;

      l_assignment_present VARCHAR2(1);

    BEGIN
-- note: do not embed any DML calls (even in debug statements in this function
--   or else we'll see ORA-14551: cannot perform a DML operation inside a query
      OPEN c_check_if_uccnet(p_inventory_item_id, p_organization_id);

      FETCH c_check_if_uccnet INTO l_assignment_present;
      IF c_check_if_uccnet%FOUND THEN

        CLOSE c_check_if_uccnet;
        RETURN 'Y';

      ELSE

        CLOSE c_check_if_uccnet;
        RETURN 'N';

      END IF;

  END Is_UCCNet_Enabled;

  FUNCTION Get_Trade_Item_Unit_Descriptor
    ( p_inventory_item_id IN NUMBER
    , p_organization_id   IN NUMBER
    ) RETURN VARCHAR2
    IS
      CURSOR c_get_tiud(p_inventory_item_id NUMBER
                       ,p_organization_id NUMBER) IS
        SELECT trade_item_descriptor
          FROM ego_items_v
         WHERE inventory_item_id = p_inventory_item_id
           AND organization_id = p_organization_id;

      l_tiud VARCHAR2(35);

    BEGIN

      OPEN c_get_tiud(p_inventory_item_id, p_organization_id);

      FETCH c_get_tiud INTO l_tiud;

      IF c_get_tiud%FOUND THEN

        CLOSE c_get_tiud;
        RETURN l_tiud;

      ELSE

        CLOSE c_get_tiud;
        RETURN null;

      END IF;

  END Get_Trade_Item_Unit_Descriptor;

  FUNCTION Is_Pack_Item(p_inventory_item_id IN NUMBER
                        ,p_organization_id   IN NUMBER
                        )
    RETURN VARCHAR2
    IS

      l_pack_type VARCHAR2(80);

    BEGIN
      -- Get the pack type attribute from MSI.
      -- IF the pack type is not null then return 'Y' otherwise return 'N'
      --SELECT Pack_Type INTO l_pack_type
      SELECT TRADE_ITEM_DESCRIPTOR INTO l_pack_type
       FROM MTL_SYSTEM_ITEMS_B
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

      IF l_pack_type IS NOT NULL THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';

  END Is_Pack_Item;

/************************************************************************
* Procedure: WRITE_DEBUG_LOG
* Purpose  : This method will write debug information to the
*            to the log file based on MRP_DEBUG Flag
**************************************************************************/
PROCEDURE WRITE_DEBUG_LOG
(  p_bo_identifier    IN  varchar2
 , p_message          IN  varchar2
)
IS
l_err_text varchar2(3000);
BEGIN
  IF (G_DEBUG_FLAG = 'Y') THEN
    Error_HandLer.Write_Debug
            (  p_debug_message  => p_message );
  END IF;
exception
    WHEN OTHERS THEN
      l_err_text := SQLERRM;
      l_err_text := 'Error : '||TO_CHAR(SQLCODE)||'---'||l_err_text;
      WRITE_ERROR_LOG (
      p_bo_identifier   => G_BO_IDENTIFIER
      , p_message         => l_err_text);
END;


/************************************************************************
* Procedure: WRITE_ERROR_LOG
* Purpose  : This method will write Errors to
*            error handler
**************************************************************************/
PROCEDURE WRITE_ERROR_LOG
(  p_bo_identifier    IN  varchar2
 , p_message          IN  varchar2
)
IS
BEGIN
  Error_Handler.Add_Error_Message
  ( p_message_text      => p_message
  , p_message_type      => 'E'
  );
END;


END Bom_Rollup_Pub;

/
