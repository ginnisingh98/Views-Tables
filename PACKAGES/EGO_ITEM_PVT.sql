--------------------------------------------------------
--  DDL for Package EGO_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVITMS.pls 120.8.12010000.3 2010/07/15 07:17:29 nendrapu ship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOVITMS.pls';

G_RET_STS_SUCCESS   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

--  Define the package global constants to substitute FND_API global variables for missing values

G_MISS_NUM      CONSTANT    NUMBER       :=  9.99E125;
G_MISS_CHAR     CONSTANT    VARCHAR2(1)  :=  CHR(0);
G_MISS_DATE     CONSTANT    DATE         :=  TO_DATE('1','j');

-- =============================================================================
--                          Global variables and cursors
-- =============================================================================

--
--  Package global tables storing all item business object data
--  to be processed by the Item BO procedures.
--

G_Item_Tbl          EGO_Item_PUB.Item_Tbl_Type;
G_Item_indx         BINARY_INTEGER    :=  0;

--Added global pl/sql revision tbl
G_Revision_Tbl      EGO_Item_PUB.Item_Revision_Tbl_Type;

G_Item_Org_Assignment_Tbl   EGO_Item_PUB.Item_Org_Assignment_Tbl_Type;
G_Item_Org_indx         BINARY_INTEGER    :=  0;


-- =============================================================================
--                                  Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:       Process_Items
--
--  Description:
--    Process (CREATE/UPDATE) a set of items based on data in
--    the global pl/sql table.
-- -----------------------------------------------------------------------------

PROCEDURE Process_Items
(
   p_commit         IN      VARCHAR2      DEFAULT  FND_API.g_FALSE
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
);

/* **
-- -----------------------------------------------------------------------------
--  API Name:       Process_Item
--
--  Description:
--    Process (CREATE/UPDATE) one item based on data in
--    the global pl/sql record.
-- -----------------------------------------------------------------------------

PROCEDURE Process_Item
(
   p_commit         IN      VARCHAR2      DEFAULT  FND_API.g_FALSE
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
);
*/

-- -----------------------------------------------------------------------------
--  API Name:       Process_Item_Org_Assignments
--
--  Description:
--    Process a list of item assignments to organizations.
-- -----------------------------------------------------------------------------

PROCEDURE Process_Item_Org_Assignments
(
   p_commit             IN          VARCHAR2  DEFAULT  FND_API.g_FALSE
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
);

-- -----------------------------------------------------------------------------
--  API Name:       Seed_Item_Long_Desc_Attr_Group
--
--  Description:
--    Add a row to the User-Defined Attribute Group 'Detailed Descriptions'
--    so that the Item Long Description is shown on the Item Detail page.
--    This procedure will only add the row if one does not exist already.
-- -----------------------------------------------------------------------------

PROCEDURE Seed_Item_Long_Desc_Attr_Group (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_item_catalog_group_id         IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Seed_Item_Long_Desc_In_Bulk
--
--  Description:
--    Add a row to the User-Defined Attribute Group 'Detailed Descriptions'
--    for all newly created items in the set identified by p_set_process_id
-- -----------------------------------------------------------------------------

PROCEDURE Seed_Item_Long_Desc_In_Bulk (
        p_set_process_id                IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Process_User_Attrs_For_Item
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_do_policy_check               IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Get_User_Attrs_For_Item
--
--  Description:
--    Fetch passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Generate_Seq_For_Item_Catalog
--
--  Description:
--    Generates the Item Sequence For Number Generation
-- -----------------------------------------------------------------------------
PROCEDURE Generate_Seq_For_Item_Catalog (
       p_item_catalog_group_id         IN  NUMBER
       ,p_seq_start_num                IN  NUMBER
       ,p_seq_increment_by             IN  NUMBER
       ,x_return_status                OUT NOCOPY VARCHAR2
       ,x_errorcode                    OUT NOCOPY NUMBER
       ,x_msg_count                    OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--  API Name:       Drop_Sequence_For_Item_Catalog
--
--  Description:
--    Generates the Item Sequence For Number Generation
-- -----------------------------------------------------------------------------
PROCEDURE Drop_Sequence_For_Item_Catalog (
       p_item_catalog_seq_name         IN  VARCHAR2
       ,x_return_status                OUT NOCOPY VARCHAR2
       ,x_errorcode                    OUT NOCOPY NUMBER
       ,x_msg_count                    OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2
);


-- -----------------------------------------------------------------------------
--  API Name:       Process_item_role
--
--  Description:
--    API to manage roles on Items
--
--    Note: Please refer to EGO_ITEM_PUB.Process_item_role for details
--
-- -----------------------------------------------------------------------------
   PROCEDURE Process_item_role
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_transaction_type      IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_role_id               IN  NUMBER
      ,p_role_name             IN  VARCHAR2
      ,p_instance_type         IN  VARCHAR2
      ,p_instance_set_id       IN  NUMBER
      ,p_instance_set_name     IN  VARCHAR2
      ,p_party_type            IN  VARCHAR2
      ,p_party_id              IN  NUMBER
      ,p_party_name            IN  VARCHAR2
      ,p_start_date            IN  DATE
      ,p_end_date              IN  DATE
      ,x_grant_guid            IN  OUT NOCOPY RAW
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );

-- -----------------------------------------------------------------------------
--  API Name:       Process_item_phase_and_status
--
--  Description:
--    API to change the phase and status of item / revision
--
--    Note: Please refer to EGO_ITEM_PUB.Process_item_phase_and_status for details
--
-- -----------------------------------------------------------------------------
   PROCEDURE Process_item_phase_and_status
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_transaction_type      IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_revision_id           IN  NUMBER
      ,p_revision              IN  VARCHAR2
      ,p_implement_changes     IN  VARCHAR2
      ,p_status                IN  VARCHAR2
      ,p_effective_date        IN  DATE
      ,p_lifecycle_id          IN  NUMBER
      ,p_phase_id              IN  NUMBER
      ,p_new_effective_date    IN  DATE
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );

-- -----------------------------------------------------------------------------
--  API Name:       Implement_Item_Pending_Changes
--
--  Description:
--    API to implement the pending changes on the item / revision
--
--    Note: Please refer to EGO_ITEM_PUB.Implement_Item_Pending_Changes for details
--
-- -----------------------------------------------------------------------------
   PROCEDURE Implement_Item_Pending_Changes
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_revision_id           IN  NUMBER
      ,p_revision              IN  VARCHAR2
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );


-- -----------------------------------------------------------------------------
--  Fix for Bug# 4052565.
--
--  API Name:       has_role_on_item
--
--  Description:
--    API to check whether the user has a role on Item or Not
--    TRUE if the user has the specified role on the item
--    FALSE if the user does not have the specified role on the item
--
-- -----------------------------------------------------------------------------
  FUNCTION has_role_on_item (p_function_name     IN VARCHAR2
                            ,p_instance_type     IN VARCHAR2 DEFAULT 'UNIVERSAL'
                            ,p_inventory_item_id IN NUMBER
                            ,p_item_number       IN VARCHAR2
                            ,p_organization_id   IN VARCHAR2
                            ,p_organization_name IN VARCHAR2
                            ,p_user_id           IN NUMBER
                            ,p_party_id          IN NUMBER
                            ,p_set_message       IN VARCHAR2
                            ) RETURN BOOLEAN;


-- -----------------------------------------------------------------------------
--  Fix for Bug# 3945885.
--
--  API Name:       Get_Seq_Gen_Item_Nums
--
--  Description:
--    API to return a Sequence of Item Numbers, given the Item Catalog Group ID.
--    Number of Item Numbers to be generated, is the size of the Org ID table
--    passed to the API.
-- -----------------------------------------------------------------------------
 PROCEDURE Get_Seq_Gen_Item_Nums( p_item_catalog_group_id  IN  NUMBER
                                 ,p_org_id_tbl             IN  DBMS_SQL.VARCHAR2_TABLE
                                 ,x_item_num_tbl           IN OUT NOCOPY EGO_VARCHAR_TBL_TYPE
                                 );


-------------------------------------------------------------------------------------
--  API Name: Get_Default_Template_Id                                              --
--                                                                                 --
--  Description: This function takes a catalog group ID as a parameter and returns --
--    the template ID corresponding to the default template for the specified      --
--    catalog group.                                                               --
--                                                                                 --
--  Parameters: p_category_id      NUMBER  Catalog group ID whose default template --
--                                         is to be returned; if null, return      --
--                                         value is null.                          --
-------------------------------------------------------------------------------------
FUNCTION Get_Default_Template_Id (
             p_category_id          IN NUMBER
           ) RETURN NUMBER;


-- -----------------------------------------------------------------------------
--  API Name:       Validate_Required_Attrs
--
--  Description:
--    Given an Item whose Primary Keys are passed in, find those attributes
--    whose values are required but is null for the Item.
--    Returns EGO_USER_ATTR_TABLE containing list of required
--    attributes information.
-- -----------------------------------------------------------------------------
--
PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_revision_id                   IN   NUMBER DEFAULT NULL
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);





-------------------------------------------------------------------------------------
--  API Name: Generate_Gtin_Tp_Attrs_View                                          --
--                                                                                 --
--  Description: This API would create a wrapper trading partner view over the     --
--               passed in views. The wrapper view shows the final value of an     --
--               attribute for a item for a trading partner                        --
--                                                                                 --
--  Parameters: p_item_attr_agv_name  VARCHAR  Name of the Item attr group view    --
--  Parameters: p_tp_agv_name         VARCHAR  Name of the trading partner attr    --
--                                             group view                          --
--  Parameters: p_item_attr_agv_alias VARCHAR  Alias to be used for the item attr  --
--                                             group view.                         --
--  Parameters: p_tp_agv_alias        VARCHAR  Alias to be used for the trading    --
--                                             partner attr group view.            --
--  Parameters: p_final_agv_name      VARCHAR  Name to be used for the final       --
--                                             wrapper view.                       --
-------------------------------------------------------------------------------------



PROCEDURE GENERATE_GTIN_TP_ATTRS_VIEW  (
                                         p_item_attr_agv_name    IN  VARCHAR2
                                        ,p_tp_agv_name           IN  VARCHAR2
                                        ,p_item_attr_agv_alias   IN  VARCHAR2
                                        ,p_tp_agv_alias          IN  VARCHAR2
                                        ,p_final_agv_name        IN  VARCHAR2
                                        ,p_multi_row_ag          IN  VARCHAR2
                                        ,x_return_status         OUT NOCOPY VARCHAR2
                                        ,x_msg_data              OUT NOCOPY VARCHAR2
                                       );


-------------------------------------------------------------------------------------
--  API Name: Generate_GDSN_Ext_AG_TP_Views                                        --
--                                                                                 --
--  Description: This API would process the SBDH extension attr groups and create  --
--               final views for all the attr groups.                              --
--                                                                                 --
--  Parameters: p_attr_group_name     VARCHAR  Name of the Item attr group for     --
--                                             which view needs to be generated    --
--                                             if passed as null all the ag's      --
--                                             associated with SBDH extension are  --
--                                             processed.
-------------------------------------------------------------------------------------

PROCEDURE Generate_GDSN_Ext_AG_TP_Views  (
                                            p_attr_group_name IN VARCHAR2 DEFAULT NULL
                                           ,ERRBUF            OUT NOCOPY VARCHAR2
                                           ,RETCODE           OUT NOCOPY VARCHAR2
                                         );

-------------------------------------------------------------------------------------
--  API Name: process_attribute_defaulting                                        --
--                                                                                 --
--  Description: This API would process the SBDH extension attr groups and create  --
--               final views for all the attr groups.                              --
--                                                                                 --
--  Parameters: p_item_attr_def_tab     SYSTEM.EGO_ITEM_ATTR_DEFAULT_TABLE         --
--                                      PL/SQL Table which has the Item Details    --
-------------------------------------------------------------------------------------

PROCEDURE  process_attribute_defaulting(p_item_attr_def_tab IN OUT NOCOPY SYSTEM.EGO_ITEM_ATTR_DEFAULT_TABLE
                                       ,p_gdsn_enabled      IN  VARCHAR2 DEFAULT  'N'
                                       ,p_commit            IN  VARCHAR2
                                       ,x_return_status     OUT NOCOPY VARCHAR2
                                       ,x_msg_data          OUT NOCOPY VARCHAR2
                                       ,x_msg_count         OUT NOCOPY  NUMBER) ;


-- -----------------------------------------------------------------------------
--  API Name:       Get_Related_Class_Codes
--
--  Description:
--    Gets the related classification codes list for a given classification code
--    added in Spec by dsakalle for bug 5523366
-- -----------------------------------------------------------------------------
PROCEDURE Get_Related_Class_Codes (
        p_classification_code           IN   VARCHAR2
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,x_related_class_codes_list      OUT NOCOPY VARCHAR2);

END EGO_Item_PVT;

/
