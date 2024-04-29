--------------------------------------------------------
--  DDL for Package BOM_ROLLUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ROLLUP_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMRLUPS.pls 120.1 2007/02/26 12:35:14 vhymavat ship $ */
/*# Rollup will happen on the objects within a BOM.Every object would have a
 * Attribute Map, with every attribute identifying the compute function. If the
 * Compute function for the attribute is not specified, the value of the attribute
 * is taken as-is.
 * Attribute Map is created from the Object attributes' metadata and is not required
 * for the calling application to be aware of or even to modify it directly within this
 * sub-process.
 * Every object also has a list of rollup actions that it supports.
 * Every supported action has a rollup function. When object in a Product structure
 * is modified it may warrant a rollup action. A calling application can indicate which
 * rollup actions should be performed on the Object.<BR>
 * The rollup actions are always performed in a reverse topological order. i.e Attribute
 * computation or propogation would start at the leaf nodes and end with parent.
 * Rollup actions can be registered along with the rollup function to perform corresponding
 * to the action. A rollup function is called for every level in the reverse tolological order
 * and has access to all the child item objects in that subtree.
 * Rollup function can determine if the rolled up attribute affects the current level or only the
 * top level. for eg.  Top GTIN computation. Top GTIN computation only impact the top level and has
 * no impact on the intermediate levels of a hierarchy.<BR>
 * Two methods are available for rollup functions to call, Set_Parent_Attribute and Set_Top_Item_Attribute
 * depending on the impact, Rollup function can call one or the other. Although no restriction
 * is placed in calling both the methods, we do not believe this would be functionally required.
 * Following explains the reverse topology processing of the Rollup and the point(s) at which
 * Rollup function and Attribute Compute functions are invoked.
 *<code><pre>
 *                                      Item-X  (0)
 *                      |-----------------|-----------------|
 *                     Item-x1          Item-x2            Item-X3   (1)
 *               |------|-----|    |------|-----|          |---|---|
 *              x1c1  x1c2  x1c3   x2c1  x2c2  x2c3       x3c1    Item-X5     (2)
 *                                                             |------|------|
 *                                                            x5c1           x5c2  (3)
 *
 *</pre></code>
 * Considering the above hierarchy and rollup starting with x5c1, would result into a map of
 * x5c1-->Item-X5-->Item-X3-->Item-X
 * The numbers in paranthesis indicate level.
 *
 * <li>Start</li>
 * <li>Rollup Process would begin at level-3</li>
 * <li>Attribute computation function would be called for components at level-3</li>
 * <li>Rollup Function would be invoked for the parent, level-2</li>
 * <li>Updates are issued for the modified attributes of the parent. Modifications to the Top Item's attributes
 *   are cached until reaching level-0</li>
 * <li>Repeat for all subsequent levels</li>
 * <li>Issue updates for modified attributes of the Top Item</li>
 * <li>End</li>
 *The Records used in this API are listed below.<BR>
 *
 * --------------------------
 * Attribute Metadata Entry
 * --------------------------
 *<code><pre>
 * Type Attr_MetaData_Entry IS RECORD
 * (  Attribute_Id     NUMBER
 *  , Object_Name      VARCHAR2(30)
 *  , Attribute_Name   VARCHAR2(30)
 *  , Attribute_Type               VARCHAR2(81)
 *  , Attribute_Table_Name         VARCHAR2(30)
 *  , Compute_Function             VARCHAR2(240)
 *  , Affects_Top_Item_Only        BOOLEAN := false
 * )
 *</pre></code>
 *
 * ------------------
 *    Parameters
 * ------------------
 * <pre>
 * Attribute_Id                 -- Attribute Identifier.
 * Object_Name                  -- Name of the Object.Exampl is EGO_ITEM
 * Attribute_Name               -- Attribute Name.Some of the permitted values are
 * NET_WEIGHT_UOM,GROSS_WEIGHT_UOM,UNIT_WEIGHT,GROSS_WEIGHT,COMPONENT_QUANTITY,IS_TRADE_ITEM_INFO_PRIVATE,BRAND_OWNER_NAME etc
 * Attribute_Type               -- Type of the Attribute.Values allowed are VARCHAR2,NUMBER
 * Attribute_Table_Name         -- Table in which the attribute column exist.Eg MTL_SYSTEM_ITEMS_B,EGO_ITEM_GTN_ATTRS_B etc
 * Compute_Function             -- Compute Function.Eg.Compute_Net_Weight,Compute_Gross_Weight.
 * Affects_Top_Item_Only        -- Boolean Flag indicating whether the rollup will affect only top item.
 *</pre>
 *
 * ------------------------------
 *   Attribute  Map Entry Type
 * ------------------------------
 *<code><pre>
 * TYPE Attr_Map_Entry_Type IS RECORD
 * (  Object_Name      VARCHAR2(30)
 *  , Attribute_Group    VARCHAR2(80)
 *  , Attribute_Name   VARCHAR2(30)
 *  , Attribute_Value    VARCHAR2(2000)
 *  , Computed_Value               VARCHAR2(2000)
 *  , Compute_Function             VARCHAR2(240)
 *  , Attribute_Type   VARCHAR2(81)
 * )
 *</pre></code>
 *
 * ---------------
 *   Parameters
 * ---------------
 *<pre>
 * Most of the attributes have same meaning as explained above.
 * Attribute_Value               -- Value of the Attribute to be rolled up
 * Computed_Value                -- Result value after Rollup computation
 * </pre>
 * -------------------------------
 *   Rollup Action Entry Type
 * -------------------------------
 * <code><pre>
 * TYPE Rollup_Action_Entry_Type IS RECORD
 * (  Object_Name       VARCHAR2(81)
 *  , Rollup_Action     VARCHAR2(240)
 *  , Rollup_Function   VARCHAR2(240)
 *  , DML_Function      VARCHAR2(240)
 *  , DML_Delayed_Write VARCHAR2(1)
 *  )
 * </pre></code>
 *
 * ----------------
 *   Parameters
 * ----------------
 * <pre>
 * Object_Name                 -- Name of the Object.Exampl is EGO_ITEM
 * Rollup_Action               -- A Consatnt indicating the Rollup Action.Eg G_COMPUTE_GROSS_WEIGHT,G_COMPUTE_NET_WEIGHT
 * Rollup_Function             -- Rollup function defined on the object
 * DML_Function                -- Values possible are Set_Private_Flag,Set_Brand_Info,Set_Top_GTIN_Flag,Set_Multirow_Attributes
 * DML_Delayed_Write           -- Flag indicating whether write needs to be delayed.Possible values are Y and N
 * </pre>
 * @rep:scope public
 * @rep:product BOM
 * @rep:displayname Rollup Engine
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/



  Type Attr_MetaData_Entry IS RECORD
  (  Attribute_Id     NUMBER
   , Object_Name      VARCHAR2(30)
   , Attribute_Name   VARCHAR2(30)
   , Attribute_Type               VARCHAR2(81)
   , Attribute_Table_Name         VARCHAR2(30)
   , Compute_Function             VARCHAR2(240)
   , Affects_Top_Item_Only        BOOLEAN := false
  );
  --
  -- Attribute / Function Map
  -- Maintains a map of the Attributes for an Object
  -- If the attribute is a computed attribute, its also identifies a
  -- compute function. The compute function will have a access to the
  -- object and the attribute already in the Map
  --
  TYPE Attr_Map_Entry_Type IS RECORD
  (  Object_Name      VARCHAR2(30)
   , Attribute_Group    VARCHAR2(80)
   , Attribute_Name   VARCHAR2(30)
   , Attribute_Value    VARCHAR2(2000)
   , Computed_Value               VARCHAR2(2000)
   , Compute_Function             VARCHAR2(240)
   , Attribute_Type   VARCHAR2(81)
  );

  TYPE Attribute_Map IS TABLE OF Attr_Map_Entry_Type
    INDEX BY BINARY_INTEGER;

  TYPE Component_Seq_Entry IS RECORD
  (  Component_Sequence_id  NUMBER
   , Component_Item_Id      NUMBER
   , Transaction_Type       VARCHAR2(10)
-- bug 4055202: got rid of map from within this record
--  (incompatible with 8i)
--   , Component_Attrs    Attribute_Map
  );

  TYPE Component_Seq_Tbl IS TABLE OF Component_Seq_Entry
    INDEX BY BINARY_INTEGER;

  TYPE Modified_Attrs_Map IS TABLE OF Component_Seq_Entry
    INDEX BY BINARY_INTEGER;

  TYPE Component_Seq_Attr_Entry IS RECORD
  (  Component_Sequence_id  NUMBER
-- for 8i: can't embed table or record with composite fields into this
   , Object_Name      VARCHAR2(30)
   , Attribute_Group    VARCHAR2(80)
   , Attribute_Name   VARCHAR2(30)
   , Attribute_Value    VARCHAR2(2000)
   , Computed_Value               VARCHAR2(2000)
   , Compute_Function             VARCHAR2(240)
   , Attribute_Type   VARCHAR2(81)
    );

  TYPE Component_Seq_Attrs_Tbl IS TABLE OF Component_Seq_Attr_Entry
    INDEX BY BINARY_INTEGER;

  --
  -- Rollup Function map will be used for identifying all the rollup actions
  -- an object supports. Every action identifies the rollup function that
  -- should be invoked. A rollup function presumeably sets one or more related
  -- attributes. Hence, when user invokes a Rollup Action, it is not required
  -- for actual attributes to be specified but just the set of Rollup Actions to be
  -- performed.
  -- The Rollup Function will have access to the Object instance and all the
  -- the attributes in its Attribute Map.
  --
  TYPE Rollup_Action_Entry_Type IS RECORD
  (  Object_Name       VARCHAR2(81)
   , Rollup_Action     VARCHAR2(240)
   , Rollup_Function   VARCHAR2(240)
   , DML_Function      VARCHAR2(240)
   , DML_Delayed_Write VARCHAR2(1)
   -- 'Y' if DML_Function should be called with p_perform_dml = N first
   --     then again at the end of the rollup with p_perform_dml = Y
   -- Note that currently only 'N' is supported (immediate write)
  );

  TYPE Rollup_Action_Map IS TABLE OF Rollup_Action_Entry_Type
    INDEX BY BINARY_INTEGER;


  TYPE Item_Org_Rec IS RECORD
  ( Inventory_Item_Id NUMBER
  , Organization_Id NUMBER
  );

  TYPE Item_Org_Tbl IS TABLE OF Item_Org_Rec
    INDEX BY BINARY_INTEGER;

  G_EMPTY_ATTR_MAP_ENTRY    Bom_Rollup_Pub.Attr_Map_Entry_Type;
  G_EMPTY_ITEM_MAP    Bom_Rollup_Pub.Attribute_Map;

  G_EMPTY_ACTION_MAP_ENTRY  Bom_Rollup_Pub.Rollup_Action_Entry_Type;
  G_EMPTY_ACTION_MAP    Bom_Rollup_Pub.Rollup_Action_Map;

  G_Attribute_Map                 Bom_Rollup_Pub.Attribute_Map;
  G_Instance_Map                  Bom_Rollup_Pub.Attribute_Map;
  G_Rollup_Action_Map   Bom_Rollup_Pub.Rollup_Action_Map;

  G_COMPUTE_GROSS_WEIGHT  CONSTANT  VARCHAR2(240) := 'COMPUTE GROSS WEIGHT';
  G_COMPUTE_NET_WEIGHT    CONSTANT  VARCHAR2(240) := 'COMPUTE NET WEIGHT';
  G_PROPOGATE_PRIVATE_FLAG  CONSTANT  VARCHAR2(240) := 'PROPOGATE PRIVATE FLAG';
  G_PROPOGATE_BRAND_INFO  CONSTANT  VARCHAR2(240) := 'PROPOGATE BRAND INFOMATION';
  G_COMPUTE_TOP_GTIN_FLAG CONSTANT  VARCHAR2(240) := 'COMPUTE AND PROPOGATE TOP GTIN FLAG';
  G_COMPUTE_MULTI_ROW_ATTRS    CONSTANT  VARCHAR2(240) := 'COMPUTE MULTI ROW ATTRS';
  G_PROPAGATE_SH_TEMPS         CONSTANT  VARCHAR2(240) := 'PROPAGATE SH TEMPS';

  --
  --  Error Handler Constants
  --
  G_LOG_FILE        VARCHAR2(240);
  G_LOG_FILE_DIR        VARCHAR2(1000);
  G_DEBUG_FLAG      VARCHAR2(1) := 'N';
  G_BO_IDENTIFIER   VARCHAR2(8) := 'BOM_RLUP';



  --
  -- the following maps are defined in the spec for re-useability and are for
  -- internal use only. They are therefore prefixed as l_ instead of G_
  -- Defined to overcome the 8i limitation of collections in dynamic sql
  --
  l_Component_Seq_Tbl   Bom_Rollup_Pub.Component_Seq_Tbl;
  l_Component_Attrs   Bom_Rollup_Pub.Attribute_Map;
  l_Header_Attrs_Map  Bom_Rollup_Pub.Attribute_Map;
  l_Top_Item_Attrs_Map  Bom_Rollup_Pub.Attribute_Map;
  l_Component_Seq_Attrs_Tbl Bom_Rollup_Pub.Component_Seq_Attrs_Tbl;

--
--  the following global variables are being used for multi-row attribute
--  updates.
  g_pk_column_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
  g_class_code_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  g_data_level_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  g_attr_diffs                    EGO_USER_ATTR_DIFF_TABLE;
  g_transaction_type              VARCHAR2(10);
  g_attr_group_id                 NUMBER;

/************************************************************************
* Procedure: WRITE_DEBUG_LOG
* Purpose  : This method will write debug information to the
*            to the log file based on MRP_DEBUG Flag
* Parameters:
*      p_bo_identifier      IN
*      p_message            IN
**************************************************************************/
/*#
* This method log the debug info into the log file
* @param p_bo_identifier Business Object Identifier
* @param p_message Error/Debug Message
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Write Logs for Rollup Actions
*/
  PROCEDURE WRITE_DEBUG_LOG
  (  p_bo_identifier    IN  varchar2
   , p_message          IN  varchar2
   );

/************************************************************************
* Procedure: WRITE_ERROR_LOG
* Purpose  : This method will write Errors to
*            error handler
* Parameters:
*      p_bo_identifier      IN
*      p_message            IN
**************************************************************************/
/*#
* This method will initialization of error handler if necessary
* and log the error to the error handler tables.
* @param p_bo_identifier Business Object Identifier
* @param p_message Error/Debug Message
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Write Logs for Rollup Actions
*/
  PROCEDURE WRITE_ERROR_LOG
  (  p_bo_identifier    IN  varchar2
   , p_message          IN  varchar2
   );



/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : This method will perform rollup or propogation of attributes
*            The attribute value propogated or computed up the bom is based
*            on the value returned by the compute_function.
*      Compute function will be passed Attribute Map and the list of
*      child components.
* Parameters:p_item_id      IN
*      p_organization_id    IN
*      p_alternate_bom_code IN
*      p_action_map         IN
*      p_validate           IN
*      p_ignore_errors      IN
*      x_error_message    OUT
**************************************************************************/
/*#
* This method will perform rollup or propogation of attributes
* The attribute value propogated or computed up the bom is based
* on the value returned by the compute_function.
* Compute function will be passed Attribute Map and the list of
* child components.
* @param p_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @param p_alternate_bom_code Alternate BOM Designator
* @param p_action_map Action Map of the Rollup Actions
* @param p_validate Flag specifying whether to validate (default 'Y')
* @param p_halt_on_error Flag specifying if errors should halt rollup (default 'N')
* @rep:paraminfo {@rep:innertype Bom_Rollup_Pub.Rollup_Action_Map}
* @param x_error_message OUT Error Message.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Perform Attribute Rollup on a BOM/Product Structure
*/
  PROCEDURE Perform_Rollup
  (  p_item_id            IN  NUMBER
   , p_organization_id    IN  NUMBER
   , p_alternate_bom_code IN  VARCHAR2
   , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map DEFAULT G_EMPTY_ACTION_MAP
   , p_validate           IN  VARCHAR2 DEFAULT 'Y'
   , p_halt_on_error      IN  VARCHAR2 DEFAULT 'N'
   , x_error_message      OUT NOCOPY VARCHAR2
   );


/*#
* This method will perform rollup or propogation of attributes
* The attribute value propogated or computed up the bom is based
* on the value returned by the compute_function of the attribute.
* Compute function will be passed Attribute Map and the list of
* child components. If there is no compute function for the attribute
* the current value of the attribute will be rolled up.
* Given a Structure Type, only the "Preferred" structure within that
* structure type will be used for rolling up the attributes.
* @param p_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @param p_parent_item_id Parent Inventory Item Identifier
* @param p_structure_type_id Structure Type Identifier
* @param p_action_map Action Map of the Rollup Actions
* @param p_validate Flag specifying whether to validate (default 'Y')
* @param p_halt_on_error Flag specifying if errors should halt rollup (default 'N')
* @rep:paraminfo {@rep:innertype Bom_Rollup_Pub.Rollup_Action_Map}
* @param x_error_message OUT Error Message.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Perform Attribute Rollup on a BOM/Product Structure
*/
        PROCEDURE Perform_Rollup
        (  p_item_id            IN  NUMBER
         , p_organization_id    IN  NUMBER
         , p_parent_item_id     IN  NUMBER DEFAULT NULL
         , p_structure_type_id  IN  NUMBER
         , p_action_map         IN  Bom_Rollup_Pub.Rollup_Action_Map DEFAULT G_EMPTY_ACTION_MAP
         , p_validate           IN  VARCHAR2 DEFAULT 'Y'
         , p_halt_on_error      IN  VARCHAR2 DEFAULT 'N'
         , x_error_message      OUT NOCOPY VARCHAR2
        );


/*#
* This method will perform rollup or propogation of attributes
* The attribute value propogated or computed up the bom is based
* on the value returned by the compute_function of the attribute.
* Compute function will be passed Attribute Map and the list of
* child components. If there is no compute function for the attribute
* the current value of the attribute will be rolled up.
* Given a Structure Type, only the "Preferred" structure within that
* structure type will be used for rolling up the attributes.
* @param p_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @param p_parent_item_id Parent Inventory Item Identifier
* @param p_structure_type_name Structure Type internal name
* @param p_action_map Action Map of the Rollup Actions
* @param p_validate Flag specifying whether to validate (default 'Y')
* @param p_halt_on_error Flag specifying if errors should halt rollup (default 'N')
* @rep:paraminfo {@rep:innertype Bom_Rollup_Pub.Rollup_Action_Map}
* @param x_error_message OUT Error Message.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Perform Attribute Rollup on a BOM/Product Structure
*/
        PROCEDURE Perform_Rollup
        (  p_item_id             IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_parent_item_id      IN  NUMBER DEFAULT NULL
         , p_structure_type_name IN  VARCHAR2
         , p_action_map          IN  Bom_Rollup_Pub.Rollup_Action_Map DEFAULT G_EMPTY_ACTION_MAP
         , p_validate            IN  VARCHAR2 DEFAULT 'Y'
         , p_halt_on_error       IN  VARCHAR2 DEFAULT 'N'
         , x_error_message       OUT NOCOPY VARCHAR2
        );

/************************************************************************
* Procedure: Perform_Rollup
* Purpose  : This method will perform rollup or propogation of attributes
*            for multi-row attributes.
*            The attribute value propogated or computed up the bom is based
*            on value returned by the compute_function.
* Parameters:
*      p_item_id      IN
*      p_organization_id    IN
*      p_structure_type_name IN
*      p_pk_column_name_value_pairs IN
*      p_class_code_name_value_pairs   IN
*      p_data_level_name_value_pairs   IN
*      p_attr_diffs                    IN
*      p_transaction_type              IN
*      p_attr_group_id                 IN
*      p_action_map   IN
*      x_error_message    OUT
**************************************************************************/
/*#
* This method will perform rollup or propogation of attributes
* for multi-row attributes, for which the attribute changes are passed
* The attribute value propogated or computed up the bom is based
* on value returned by the compute_function.
* Compute function will be passed Attribute Map and the list of
* child components.
* @param p_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @param p_structure_type_name Structure Type Name
* @param p_pk_column_name_value_pairs PK Column Name value pair
* @param p_class_code_name_value_pairs Classification Code Name and Value
* @param p_data_level_name_value_pairs Data Level Name and Value
* @param p_attr_diffs  Encapsulates Attribute Changes
* @param p_transaction_type  Transaction Type (ADD, SYNC, DEL etc.)
* @param p_attr_group_id       Attribute Group Id
* @param p_action_map Action Map of the Rollup Actions
* @rep:paraminfo {@rep:innertype Bom_Rollup_Pub.Rollup_Action_Map}
* @param x_error_message OUT Error Message.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Perform Attribute Rollup on a BOM/Product Structure
*/
PROCEDURE Perform_Rollup
        (  p_item_id            IN  NUMBER
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
        );

  /*********************************************************************
  * Function: Get_Rollup_Function
  * Purpose : Given an Object and the Rollup Action to be performed, this
  *           function will return the Roll function that will be executed.
  *
  ************************************************************************/
  Function Get_Rollup_Function
  ( p_object_name   IN  VARCHAR2
  , p_rollup_action IN  VARCHAR2
  ) RETURN VARCHAR2;

/*********************************************************************
* Procedure : Add_Rollup_Action
* Purpose   : This procedure helps build the Action Map. Once the action
*             map is ready, calling application can call perfom_rollup
*       with the Rollup Action Map.
*       The object/action is checked against the supported set of
*       Actions, hence, an incorrect combination will throw a
*       'BOM_OBJECT_ACTION_INVALID' exception.
************************************************************************/
/*#
* Used for building the Action Map. Once the action map is ready,
* calling application can call perfom_rollup with the Rollup Action Map.
* The object/action is checked against the supported set of
* Actions, hence, an incorrect combination will throw a
* 'BOM_OBJECT_ACTION_INVALID' exception. A function to handle DML
* operations is also needed along with a flag which specifies whether
* the function supports delayed writes, in which the DML operation
* is buffered until the end of that particular rollup stage, at which
* point all buffered DML operations are executed (enhances performance
* since each rollup actions would otherwise have to issue DML operations
* individually, rather than bulk updating
* @param p_object_name Object Of the Rollup Action
* @param p_rollup_action Rollup Action
* @param p_dml_function DML Function
* @param p_dml_delayed_write Flag specifying whether DML Function supports Delayed Writes
* @param x_rollup_action_map Action Map of the Rollup Actions
* @rep:paraminfo {@rep:innertype Bom_Rollup_Pub.Rollup_Action_Map}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Build Rollup Action Map
*/
  Procedure Add_Rollup_Function
  ( p_Object_Name       IN VARCHAR2
  , p_Rollup_Action     IN VARCHAR2
  , p_DML_Function      IN VARCHAR2
  , p_DML_Delayed_Write IN VARCHAR2
  , x_Rollup_Action_Map IN OUT NOCOPY Bom_Rollup_Pub.Rollup_Action_Map
  );

/*********************************************************************
* Procedure : Get_Item_Rollup_Map
* Purpose   : Returns the supported list of Actions for an Object
*
************************************************************************/
FUNCTION Get_Item_Rollup_Map
  ( p_Object_Name   IN  VARCHAR2 )
        RETURN Bom_Rollup_Pub.Rollup_Action_Map;

/*#
* It is used to create a map of the parent object's attributes in a
* reverse topology traversal.
*
* @param p_attribute_name Object Attribute Name
* @param p_attribute_value Attribute Value
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Set Parent attribute in a reverse topology traversal
*/
  PROCEDURE Set_Parent_Attribute
  (  p_attribute_name IN  VARCHAR2
   , p_attribute_value  IN  VARCHAR2
  );

/*#
* It is used to create a map of the top object's attributes in a
* tree.
*
* @param p_attribute_name Object Attribute Name
* @param p_attribute_value Attribute Value
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Set Top object's attribute
*/
  PROCEDURE Set_Top_Item_Attribute
        (  p_attribute_name     IN  VARCHAR2
         , p_attribute_value    IN  VARCHAR2
        );

/*#
* Returns the identifier of the Top Object
*
* @return Top Item Identifier
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Top Item identifier
*/
  FUNCTION Get_Top_Item_Id RETURN NUMBER;

/*#
* Return Top object's organization.
*
* @return Top Item Organization Identifier
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Top Items Oranization identifier
*/
  FUNCTION Get_Top_Organization_Id RETURN NUMBER;

/*#
* Returns current item object's identifier. In a reverse topology
* traversal, this is the parent item of the level in process.
* @return Current/Parent Item Identifier
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get current item object's identifier
*/
  FUNCTION Get_Current_Item_Id RETURN NUMBER;

/*#
* Returns current Item object's organization identifier. In a reverse topology
* traversal, this is the parent item of the level in process.
*
* @return Current/Parent Item's Organization Identifier
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get current item object's organization identifier
*/
  FUNCTION Get_Current_Organization_Id RETURN NUMBER;


/*#
* Returns component's attribute's value. This function is to be used alongwith
* the calls to Rollup. When a rollup function is in-process, a computation function
* can request for a component's attribute using this call.
*
* @param p_attribute_name Object Attribute Name
* @param p_component_sequence_id Component Identifier
* @return Component's attribute value
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Attribute Value
*/
  FUNCTION Get_Attribute_Value
        (  p_component_sequence_id      IN  NUMBER
         , p_attribute_name             IN  VARCHAR2
        ) RETURN VARCHAR2;

        /*#
        * Returns component's attribute's value. This function is to be used alongwith
        * the calls to Rollup. When a rollup function is in-process, a computation function
        * can request for a component's attribute using this call.
        *
        * @param p_attribute_name Top Object's Attribute Name
        * @return Component's attribute value
        * @rep:scope public
        * @rep:lifecycle active
        * @rep:displayname Get Top Item Object's Attribute Value
        */
        FUNCTION Get_Top_Item_Attribute_Value
        (  p_attribute_name             IN  VARCHAR2
        ) RETURN VARCHAR2;

/*#
* Returns 'Y' if and only if item is uccnet enabled
*
* @param p_inventory_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @return Whether Item is UCCNet enabled
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Is UCCNet Enabled
*/
  FUNCTION Is_UCCNet_Enabled(p_inventory_item_id IN NUMBER
                            ,p_organization_id   IN NUMBER
                            ) RETURN VARCHAR2;

/*#
* Returns Trade Item Unit Descriptor
*
* @param p_inventory_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @return Trade Item Unit Descriptor
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Trade Item Unit Descriptor
*/
  FUNCTION Get_Trade_Item_Unit_Descriptor
    ( p_inventory_item_id IN NUMBER
    , p_organization_id   IN NUMBER
    ) RETURN VARCHAR2;

/*#
* Returns 'Y' if and only if item is pack item.
*
* @param p_inventory_item_id Inventory Item Identifier
* @param p_organization_id Organization Identifier
* @return Whether Item is pack item
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Is Pack Enabled
*/
  FUNCTION Is_Pack_Item
    (p_inventory_item_id IN NUMBER
    ,p_organization_id   IN NUMBER
    ) RETURN VARCHAR2;

END Bom_Rollup_Pub;

/
