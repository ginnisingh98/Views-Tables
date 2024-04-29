--------------------------------------------------------
--  DDL for Package INV_EGO_REVISION_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EGO_REVISION_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: INVEGRVS.pls 120.8.12010000.2 2009/04/15 11:48:12 rmpartha ship $ */

--  ============================================================================
--  API Name:           Check_LifeCycle
--
--        IN:           Catalog Group Id
--                      Lifecycle Id
--
--   Returns:           TRUE  if the lifecycle is valid for the catalog group
--                      FALSE if the lifecycle is NOT valid for the catalog group
--  ============================================================================
FUNCTION Check_LifeCycle (p_catalog_group_id IN NUMBER,
                          p_lifecycle_id     IN NUMBER)
RETURN BOOLEAN;
--  ============================================================================
--  API Name:           Check_LifeCycle_Phase
--
--        IN:           Lifecycle Id
--                      Lifecycle Phase Id
--
--   Returns:           TRUE  if the lifecycle phase is valid for the lifecycle
--                      FALSE if the lifecycle is NOT valid for the lifecycle
--  ============================================================================
FUNCTION Check_LifeCycle_Phase ( p_lifecycle_id       IN NUMBER,
                                 p_lifecycle_phase_id IN NUMBER)
RETURN BOOLEAN;


--  ============================================================================
--  API Name:           Get_Initial_LifeCycle_Phase
--
--        IN:           Lifecycle Id
--
--   Returns:           Initial Phase Id if found for the given lifecycle
--                      0 if NO phases found for the given lifecycle
--  ============================================================================
FUNCTION Get_Initial_Lifecycle_Phase ( p_lifecycle_id  IN NUMBER)
RETURN NUMBER;

--  ============================================================================
--  API Name    : validate_items_lifecycle
--  Description : This function validates items lifecycle-phase-status.
--                Will return 0 if valid lifecycle-phase-status are attached.
--                Included here to avoid one more stuffed package.
--  ============================================================================

FUNCTION validate_items_lifecycle(
	 P_Org_Id       IN            NUMBER
	,P_All_Org      IN            NUMBER  DEFAULT  2
	,P_Prog_AppId   IN            NUMBER  DEFAULT -1
	,P_Prog_Id      IN            NUMBER  DEFAULT -1
	,P_Request_Id   IN            NUMBER  DEFAULT -1
	,P_User_Id      IN            NUMBER  DEFAULT -1
	,P_Login_Id     IN            NUMBER  DEFAULT -1
	,P_Set_id       IN            NUMBER  DEFAULT -999
   ,P_Process_Flag IN            NUMBER  DEFAULT 4
	,X_Err_Text     IN OUT NOCOPY  VARCHAR2)
RETURN INTEGER;

--Start : Check for data security and user priv.
FUNCTION check_data_security(
          P_Function            IN VARCHAR2
	 ,P_Object_Name         IN VARCHAR2
	 ,P_Instance_PK1_Value  IN VARCHAR2
	 ,P_Instance_PK2_Value  IN VARCHAR2 DEFAULT NULL
	 ,P_Instance_PK3_Value  IN VARCHAR2 DEFAULT NULL
	 ,P_Instance_PK4_Value  IN VARCHAR2 DEFAULT NULL
	 ,P_Instance_PK5_Value  IN VARCHAR2 DEFAULT NULL
         ,P_User_Id             IN NUMBER)
RETURN VARCHAR2;

/* Bug: 5238510
   Added process flag parameter with a default value of 2
   If the caller wants to pick rows other than thie process
   flag value they can pass that value explicitly. The behavior
   remains the same otherwise.
*/
FUNCTION validate_item_user_privileges(
         P_Org_Id       IN            NUMBER
        ,P_All_Org      IN            NUMBER  DEFAULT  2
        ,P_Prog_AppId   IN            NUMBER  DEFAULT -1
        ,P_Prog_Id      IN            NUMBER  DEFAULT -1
        ,P_Request_Id   IN            NUMBER  DEFAULT -1
        ,P_User_Id      IN            NUMBER  DEFAULT -1
        ,P_Login_Id     IN            NUMBER  DEFAULT -1
        ,P_Set_id       IN            NUMBER  DEFAULT -999
        ,X_Err_Text     IN OUT        NOCOPY  VARCHAR2
        ,P_Process_flag IN            NUMBER  DEFAULT 2)
RETURN INTEGER;
--End : Check for data security and user priv.

--  ============================================================================
--  API Name    : Insert_Grants_And_UserAttr
--  Description : This procedure will be called from IOI (INVPPROB.pls)
--                Will insert records in FND_GRANTS and EGO USER_ATTR  table
--                Bug: 3033702 Moved this code from INVPPROB.pls
--  ============================================================================

PROCEDURE Insert_Grants_And_UserAttr(P_Set_id  IN  NUMBER  DEFAULT -999);

--  ============================================================================
--  API Name    : phase_change_policy
--  Description : This procedure will be called from IOI (INVPVALB.pls)
--                Stuffed version will return 'ALLOWED' through l_Policy_Code.
--                EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change will be called.
--  ============================================================================

PROCEDURE phase_change_policy(P_ORGANIZATION_ID    IN         NUMBER
			     ,P_INVENTORY_ITEM_ID  IN         NUMBER
		             ,P_CURR_PHASE_ID      IN         NUMBER
		             ,P_FUTURE_PHASE_ID    IN         NUMBER
		             ,P_PHASE_CHANGE_CODE  IN         VARCHAR2
		             ,P_LIFECYCLE_ID       IN         NUMBER
		             ,X_POLICY_CODE        OUT NOCOPY VARCHAR2
		             ,X_RETURN_STATUS      OUT NOCOPY VARCHAR2
		             ,X_ERRORCODE          OUT NOCOPY NUMBER
		             ,X_MSG_COUNT          OUT NOCOPY NUMBER
		             ,X_MSG_DATA           OUT NOCOPY VARCHAR2);
--Start : 2803833

FUNCTION get_default_template(p_catalog_group_id IN NUMBER) RETURN NUMBER;

--End     2803833

----------------------------------------------------------------
--API Name    : Sync_Template_Attribute
--Description : To sync up operational attribute values in mtl_item_templ_attributes
--              with ego_templ_attributes
--parameters:
--  p_attribute_name is the full attribute name in mtl_item_templ_attributes
----------------------------------------------------------------

PROCEDURE Sync_Template_Attribute(
     p_template_id      IN NUMBER,
     p_attribute_name   IN VARCHAR2 DEFAULT NULL);

------------------------------------------------------------------------------------------
--API Name    : Update_Attribute_Control_Level
--Description : To update the control level of an attribute in EGO_FND_DF_COL_USGS_EXT
--Parameteres required : 1) p_control_level is a valid control level
--             as represented in lookup 'EGO_PC_CONTROL_LEVEL' in fnd_lookups
--            2) p_application_column_name is not null and is a valid column name
------------------------------------------------------------------------------------------
PROCEDURE Update_Attribute_Control_Level (
        p_application_column_name       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER
);

------------------------------------------------------------------------------------------
--API Name    : Pending_Eco_Check_Sync_Ids
--Description : Pending ECO check and sync lifecycles
------------------------------------------------------------------------------------------
--Start : 3637854
PROCEDURE Pending_Eco_Check_Sync_Ids(
	 P_Prog_AppId  IN            NUMBER  DEFAULT -1
	,P_Prog_Id     IN            NUMBER  DEFAULT -1
	,P_Request_Id  IN            NUMBER  DEFAULT -1
	,P_User_Id     IN            NUMBER  DEFAULT -1
	,P_Login_Id    IN            NUMBER  DEFAULT -1
	,P_Set_id      IN            NUMBER  DEFAULT -999);
--End : 3637854

------------------------------------------------------------------------------------------
--API Name    : Upgrade_cat_User_Attrs_Data
--Description : Bug: 3527633    Added for EGO
--             There are certain extensible attribute groups that are associated with the
--             default category set of the product reporting functional area. When the
--             default category set is changed we need to call an EGO API that will
--             automatically associate these attribute groups with the new category set.
--Parameteres required : 1) p_functional_area_id is a unctional area
------------------------------------------------------------------------------------------
PROCEDURE Upgrade_cat_User_Attrs_Data ( p_functional_area_id  IN  NUMBER  );

------------------------------------------------------------------------------------------
--API Name    : Check_No_MFG_Associations
--Description : Bug: 3735702    Added for EGO
--             There are certain associations to the manufacturers which are used by EGO
--             So, when deleting the Manufacturer, we need to check for the associations
--             and flash an error if any associations exist
--Parameteres required : 1) p_manufacturer_id  2)p_api_version
--Return parameteres   : 1) x_return_status = 'Y' if no associations exist
--                                            'N' in all other cases
--                       2) x_message_text  = valid only if x_return_status = 'N'
------------------------------------------------------------------------------------------
PROCEDURE Check_No_MFG_Associations
  (p_api_version          IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_manufacturer_name    IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_message_name        OUT  NOCOPY VARCHAR2
  ,x_message_text        OUT  NOCOPY VARCHAR2
  );

------------------------------------------------------------------------------------------
--API Name    : Check_Template_Cat_Assocs
--Description : Bug# 3326991    Added for Delete template Operation.
--This procedure is used in the deletion of Item templates in the form
--INVIDTMP.fmb (MTL_ITEM_TEMPLATES.check_delete_row)

-- An Item Template cannot be deleted if any associations to catalog categories exist

--Parameteres required : 1) p_template_id
--Return parametere    : 1) x_return_status = 1 if no associations exist
--                                            0 in all other cases
------------------------------------------------------------------------------------------
PROCEDURE CHECK_TEMPLATE_CAT_ASSOCS
  (p_template_id         IN  NUMBER
  ,x_return_status       OUT NOCOPY NUMBER
  );

-- Added for 11.5.10+ UCCnet functionality
------------------------------------------------------------------------------------------
--API Name    : Process_UCCnet_Attributes
--Description : Calls the method to update the REGISTRATION_UPDATE_DATE
--              and TP_NEUTRAL_UPDATE_DATE for each Item/GTIN, when the respective
--              attributes are changed
------------------------------------------------------------------------------------------
PROCEDURE Process_UCCnet_Attributes(
   P_Prog_AppId  IN            NUMBER  DEFAULT -1
  ,P_Prog_Id     IN            NUMBER  DEFAULT -1
  ,P_Request_Id  IN            NUMBER  DEFAULT -1
  ,P_User_Id     IN            NUMBER  DEFAULT -1
  ,P_Login_Id    IN            NUMBER  DEFAULT -1
  ,P_Set_id      IN            NUMBER  DEFAULT -999);

/*------------------------------------------------------------------------------------------
--API Name    : Create_New_Item_Request
--Description : Bug# 3777954
--This procedure is used to create new item request for an item with 'CREATE' option.
-- Only for EGO IOI and excel from PLM this needs to be called.

--Parameteres required : 1) p_set_process_id => request id that needs to be processed
------------------------------------------------------------------------------------------*/
PROCEDURE Create_New_Item_Request
  ( p_set_process_id NUMBER);

FUNCTION  Get_Process_Control RETURN VARCHAR2;

/*------------------------------------------------------------------------------------------
--API Name    : Set_Process_Control
--Description : Bug# 3777954
--This procedure is used to set the G_PROCESS_CONTROL to control teh process flow for PLM.
-- Only for EGO IOI and excel from PLM this needs to be called.

--Parameteres required : 1) p_process_control => "NO_NIR" means NIR will not be created.
                                              => "RAISE_NO_EVENT" post event will not be fired
------------------------------------------------------------------------------------------*/
PROCEDURE Set_Process_Control(p_process_control VARCHAR2);

--  ============================================================================
--  API Name    : Populate_Seq_Gen_Item_Nums
--  Description : This procedure will be called from IOI
--                (after org and catalog category details are resolved)
--                to populate the item numbers for all the sequence generated items.
--  ============================================================================
/* Added to fix Bug#8434681: Sets the variable that tells if code flow is coming from Open API  */
   FUNCTION  Get_Process_Control_HTML_API RETURN VARCHAR2;

/* Added to fix Bug#8434681:  Returns the value of the variable that tells if code flow is coming from Open API */
   PROCEDURE Set_Process_Control_HTML_API(p_process_control VARCHAR2);


PROCEDURE Populate_Seq_Gen_Item_Nums
          (p_set_id           IN         NUMBER
          ,p_org_id           IN         NUMBER
          ,p_all_org          IN         NUMBER
          ,p_rec_status       IN         NUMBER
          ,x_return_status    OUT NOCOPY VARCHAR2
          ,x_msg_count        OUT NOCOPY NUMBER
          ,x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE Insert_Revision_UserAttr(P_Set_id  IN  NUMBER  DEFAULT -999);

--Added for bug 5435229
PROCEDURE apply_default_uda_values(P_Set_id  IN  NUMBER  DEFAULT -999, p_commit  IN NUMBER DEFAULT 1); /* Added p_commit to fix Bug#7422423*/

--  ============================================================================
--  API Name    : Check_Org_Access
--  Description : This procedure will be called from IOI to check if org_access_view
--                has this org
--  ============================================================================
FUNCTION Check_Org_Access (p_org_id    IN NUMBER)
RETURN VARCHAR2;

END INV_EGO_REVISION_VALIDATE;


/
