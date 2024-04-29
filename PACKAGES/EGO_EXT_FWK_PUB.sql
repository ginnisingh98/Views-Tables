--------------------------------------------------------
--  DDL for Package EGO_EXT_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_EXT_FWK_PUB" AUTHID DEFINER AS
/* $Header: EGOPEFMS.pls 120.13.12010000.8 2009/12/17 03:21:28 geguo ship $ */

                       ----------------------
                       -- Global Constants --
                       ----------------------

  G_TRANS_TEXT_DATA_TYPE     CONSTANT VARCHAR2(1) := 'A';
  G_CHAR_DATA_TYPE           CONSTANT VARCHAR2(1) := 'C';
  G_NUMBER_DATA_TYPE         CONSTANT VARCHAR2(1) := 'N';
  G_DATE_DATA_TYPE           CONSTANT VARCHAR2(1) := 'X';
  G_DATE_TIME_DATA_TYPE      CONSTANT VARCHAR2(1) := 'Y';

  G_TRANS_IND_VALIDATION_CODE   CONSTANT VARCHAR2(1) := 'X';
  G_INDEPENDENT_VALIDATION_CODE CONSTANT VARCHAR2(1) := 'I';
  G_NONE_VALIDATION_CODE        CONSTANT VARCHAR2(1) := 'N';
  G_TABLE_VALIDATION_CODE       CONSTANT VARCHAR2(1) := 'F';

  G_ATTACH_DISP_TYPE         CONSTANT VARCHAR2(1) := 'A';
  G_CHECKBOX_DISP_TYPE       CONSTANT VARCHAR2(1) := 'C';
  G_DYN_URL_DISP_TYPE        CONSTANT VARCHAR2(1) := 'D';
  G_HIDDEN_DISP_TYPE         CONSTANT VARCHAR2(1) := 'H';
  G_RADIO_DISP_TYPE          CONSTANT VARCHAR2(1) := 'R';
  G_STATIC_URL_DISP_TYPE     CONSTANT VARCHAR2(1) := 'S';
  G_TEXT_FIELD_DISP_TYPE     CONSTANT VARCHAR2(1) := 'T';

  G_LOV_LONGLIST_FLAG        CONSTANT VARCHAR2(1) := 'N';
  G_POPLIST_LONGLIST_FLAG    CONSTANT VARCHAR2(1) := 'X';

  G_MISS_CHAR                CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_NUM                 CONSTANT NUMBER      := FND_API.G_MISS_NUM;


                     ------------------
                     -- Custom Types --
                     ------------------

TYPE EGO_ATTR_USG_METADATA IS RECORD(
  application_id  NUMBER
 ,attr_grp_type VARCHAR2(40)
 ,attr_grp_name VARCHAR2(30)
 ,attr_name VARCHAR2(30)
 ,data_level VARCHAR2(30)
 ,is_multi_row VARCHAR2(1)
 ,data_type VARCHAR2(1)
);

TYPE EGO_VALUE_SET_VALUE_IDS IS VARRAY(100)
  OF EGO_VS_VALUES_DISP_ORDER.value_set_value_id%TYPE;

TYPE EGO_VS_VALUES_DISP_ORDER_TBL IS TABLE
  OF EGO_VS_VALUES_DISP_ORDER%ROWTYPE;

                     ------------------------
                     -- Miscellaneous APIs --
                     ------------------------

-- signature to use if caller has ATTR_GROUP_ID
FUNCTION Get_Privilege_For_Attr_Group (
        p_attr_group_id                 IN   NUMBER
       ,p_which_priv_to_return          IN   VARCHAR2
)
RETURN VARCHAR2;

-- signature to use if caller doesn't have ATTR_GROUP_ID
FUNCTION Get_Privilege_For_Attr_Group (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_which_priv_to_return          IN   VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Is_Column_Indexed (
        p_column_name                   IN   VARCHAR2
       ,p_table_name                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2;

FUNCTION Get_Attr_Group_Id_From_PKs (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
)
RETURN NUMBER;

FUNCTION Does_Attr_Have_Data (
        p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_name                     IN   VARCHAR2   DEFAULT NULL
       ,p_attr_id                       IN   NUMBER     DEFAULT NULL
)
RETURN VARCHAR2;

FUNCTION Get_Application_Owner (
        p_appl_id                    IN   NUMBER
)
RETURN VARCHAR2 ;

FUNCTION Get_Oracle_UserName
RETURN VARCHAR2 ;

FUNCTION Check_Supported_Attr_Usages (
        p_support_api                   IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_grp_type                 IN   VARCHAR2
       ,p_attr_grp_name                 IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_is_multi_row                  IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
)
RETURN VARCHAR2;




/*
NOTE: WE DON'T USE THESE ANYMORE, BUT WE'LL KEEP THEM JUST IN CASE

-- signature to use if caller has ATTR_GROUP_ID
PROCEDURE Get_Available_AttrDBCol (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,x_database_column               OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ATTR_GROUP_ID
PROCEDURE Get_Available_AttrDBCol (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,x_database_column               OUT NOCOPY VARCHAR2
);

-- signature to use if caller has ATTR_GROUP_ID
PROCEDURE Get_Available_AttrDBCols (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,x_database_columns              OUT NOCOPY EGO_VARCHAR_TBL_TYPE
);

-- signature to use if caller doesn't have ATTR_GROUP_ID
PROCEDURE Get_Available_AttrDBCols (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,x_database_columns              OUT NOCOPY EGO_VARCHAR_TBL_TYPE
);
*/
------------------------------------------------------------------------------------------
-- Function: To return the  pending transalatable table name  for a given attribute group type
--  an the application id
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_attr_group_type:  attribute_group_type
--  p_attr_group_type      application_id
--        OUT
--  l_table_name     : translatable table for attribute_changes
------------------------------------------------------------------------------------------
FUNCTION Get_Attr_Changes_TL_Table (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------
-- Function: To return the  pending base table name  for a given attribute group type
--  an the application id
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_attr_group_type:  attribute_group_type
--  p_attr_group_type      application_id
--        OUT
--  l_table_name     : base table for attribute_changes
------------------------------------------------------------------------------------------

FUNCTION Get_Attr_Changes_B_Table (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Table_Name (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_TL_Table_Name (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Object_Id_From_Name (
        p_object_name                   IN   VARCHAR2
)
RETURN NUMBER;

FUNCTION Get_Object_Id_For_AG_Type (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
) RETURN NUMBER;

FUNCTION Get_Class_Meaning (
        p_object_name                   IN   VARCHAR2
       ,p_class_code                    IN   VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Class_Meaning (
        p_object_id                     IN   NUMBER
       ,p_class_code                    IN   VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Get_Pk_Columns (
        p_api_version                   IN   NUMBER
       ,p_obj_name                      IN   VARCHAR2
       ,x_pkcolumn1_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn1_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn2_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn2_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn3_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn3_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn4_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn4_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn5_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn5_type                OUT NOCOPY VARCHAR2
);

--
-- This API is used to get the attribute changes table
-- for a given attribute group type.
--
PROCEDURE Get_Attr_Changes_Table (
   p_attr_group_type  IN  VARCHAR2
  ,x_base_table      OUT NOCOPY VARCHAR2
  ,x_tl_table        OUT NOCOPY VARCHAR2
  );


                    --------------------------
                    -- Attribute Group APIs --
                    --------------------------

-- Wrapper for JSPs that aren't set up to take ATTR_GROUP_ID --
PROCEDURE Create_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- Wrapper for JSPs that aren't set up to take ATTR_GROUP_ID --
PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_ag_app_id              IN   NUMBER
       ,p_source_ag_type                IN   VARCHAR2
       ,p_source_ag_name                IN   VARCHAR2
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- Wrapper for OA to pass source ATTR_GROUP_ID instead of Application Id, AG Type and AG Name--
PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_attr_group_id          IN   NUMBER
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_ag_app_id              IN   NUMBER
       ,p_source_ag_type                IN   VARCHAR2
       ,p_source_ag_name                IN   VARCHAR2
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has ATTR_GROUP_ID
PROCEDURE Update_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ATTR_GROUP_ID
PROCEDURE Update_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has ATTR_GROUP_ID
PROCEDURE Delete_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ATTR_GROUP_ID
PROCEDURE Delete_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Compile_Attr_Group_Views (
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_attr_group_id_list            IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
);

PROCEDURE Validate_Unique_Key_Attrs (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_id_list                       IN   VARCHAR2
       ,x_is_valid_key                  OUT NOCOPY VARCHAR2
);

                       ---------------------
                       -- Data Level APIs --
                       ---------------------

PROCEDURE  Sync_Data_Level (
          p_api_version           IN  NUMBER
         ,p_init_msg_list         IN  VARCHAR2
         ,p_commit                IN  VARCHAR2
         ,p_transaction_type      IN  VARCHAR2
         ,p_application_id        IN  NUMBER
         ,p_attr_group_type       IN  VARCHAR2
         ,p_data_level_name       IN  VARCHAR2
         ,p_user_data_level_name  IN  VARCHAR2
         ,p_pk1_column_name       IN  VARCHAR2
         ,p_pk1_column_type       IN  VARCHAR2
         ,p_pk2_column_name       IN  VARCHAR2
         ,p_pk2_column_type       IN  VARCHAR2
         ,p_pk3_column_name       IN  VARCHAR2
         ,p_pk3_column_type       IN  VARCHAR2
         ,p_pk4_column_name       IN  VARCHAR2
         ,p_pk4_column_type       IN  VARCHAR2
         ,p_pk5_column_name       IN  VARCHAR2
         ,p_pk5_column_type       IN  VARCHAR2
         ,p_enable_defaulting     IN  VARCHAR2
         ,p_enable_view_priv      IN  VARCHAR2
         ,p_enable_edit_priv      IN  VARCHAR2
         ,p_enable_pre_event      IN  VARCHAR2
         ,p_enable_post_event     IN  VARCHAR2
         ,p_last_updated_by       IN  VARCHAR2
         ,p_last_update_date      IN  DATE
         ,p_is_nls_mode           IN  VARCHAR2
         ,x_data_level_id         IN OUT NOCOPY NUMBER
         ,x_return_status         OUT NOCOPY VARCHAR2
         ,x_msg_count             OUT NOCOPY NUMBER
         ,x_msg_data              OUT NOCOPY VARCHAR2
         );

                  ---------------------------------
                  -- Data Level Association APIs --
                  ---------------------------------
PROCEDURE  Sync_dl_assoc (
        p_api_version          IN  NUMBER
       ,p_init_msg_list        IN  VARCHAR2
       ,p_commit               IN  VARCHAR2
       ,p_transaction_type     IN  VARCHAR2
       ,p_attr_group_id        IN  NUMBER
       ,p_application_id       IN  NUMBER
       ,p_attr_group_type      IN  VARCHAR2
       ,p_attr_group_name      IN  VARCHAR2
       ,p_data_level_id        IN  NUMBER
       ,p_data_level_name      IN  VARCHAR2
       ,p_defaulting           IN  VARCHAR2
       ,p_defaulting_name      IN  VARCHAR2
       ,p_view_priv_id         IN  NUMBER
       ,p_view_priv_name       IN  VARCHAR2
       ,p_user_view_priv_name  IN  VARCHAR2
       ,p_edit_priv_id         IN  NUMBER
       ,p_edit_priv_name       IN  VARCHAR2
       ,p_user_edit_priv_name  IN  VARCHAR2
       ,p_raise_pre_event      IN  VARCHAR2
       ,p_raise_post_event     IN  VARCHAR2
       ,p_last_updated_by      IN  VARCHAR2
       ,p_last_update_date     IN  DATE
       ,x_return_status        OUT NOCOPY VARCHAR2
       ,x_msg_count            OUT NOCOPY NUMBER
       ,x_msg_data             OUT NOCOPY VARCHAR2
       );

                       --------------------
                       -- Attribute APIs --
                       --------------------

PROCEDURE Create_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_is_column_indexed             IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_uom_class                     IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT 1 --JDEJESU: NULL for 11.5.10E
       ,p_attribute_code                IN   VARCHAR2   DEFAULT NULL
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_customization_level           IN   VARCHAR2   DEFAULT 'A'
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_read_only_flag                IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_is_column_indexed             IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_uom_class                     IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT 1 --JDEJESU: NULL for 11.5.10E
       ,p_attribute_code                IN   VARCHAR2   DEFAULT NULL
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_customization_level           IN   VARCHAR2   DEFAULT 'A'
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);
PROCEDURE Update_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER     DEFAULT G_MISS_NUM
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2   DEFAULT NULL
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT -1
       ,p_attribute_code                IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_customization_level           IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_uom_class                     IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_read_only_flag                 IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER     DEFAULT G_MISS_NUM
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2   DEFAULT NULL
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT -1
       ,p_attribute_code                IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_customization_level           IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_uom_class                     IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                       --------------------
                       -- Value Set APIs --
                       --------------------

-- signature to use if caller wants to specify OWNER
PROCEDURE Create_Value_Set (
        p_api_version                   IN   NUMBER
--       ,p_application_id                IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER     DEFAULT 0
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_value_set_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE REVERT_TO_AN_EARLIER_VERSION(
       p_api_version                   IN NUMBER
      ,p_value_set_id                  IN NUMBER
      ,p_version_number                IN NUMBER
      ,x_return_status                OUT NOCOPY VARCHAR2
      ,x_msg_count                    OUT NOCOPY number
      ,x_msg_data                     OUT NOCOPY VARCHAR2
);

--Signature for converting non-versioned value set to an versioned value set.
PROCEDURE CONVERT_TO_VERSIONED_VALUE_SET(
       p_api_version                   IN NUMBER
      ,p_value_set_id                  IN NUMBER
      ,p_description                   IN VARCHAR2
      ,x_return_status                OUT NOCOPY VARCHAR2
      ,x_msg_count                    OUT NOCOPY number
      ,x_msg_data                     OUT NOCOPY VARCHAR2
);


--API signature to delete the value from versioned value set.

PROCEDURE Delete_Value_Set_val(
       p_value_set_id                 IN NUMBER
      ,p_value_id                     IN NUMBER
      ,x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE get_version_number(
       p_api_version                  IN NUMBER
      ,p_value_set_id                 IN NUMBER
      ,p_start_effective_date         IN TIMESTAMP
      ,p_creation_date                IN TIMESTAMP
      ,p_version_number               OUT NOCOPY  NUMBER
      ,x_return_status                OUT NOCOPY VARCHAR2
);



 PROCEDURE RELEASE_VALUE_SET_VERSION(
       p_api_version                  IN NUMBER
      ,p_value_set_id                 IN NUMBER
      ,p_description                  IN VARCHAR2
      ,p_start_date                   IN TIMESTAMP
      ,p_version_seq_id               IN number
      , x_return_status               OUT NOCOPY VARCHAR2
      ,x_msg_count                    OUT NOCOPY VARCHAR2
      ,x_msg_data                      OUT NOCOPY varchar2
)   ;


/* changes For PIM For Telco Feature */
PROCEDURE Create_Value_Set (
        p_api_version                   IN   NUMBER
--       ,p_application_id                IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER     DEFAULT 0
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_value_set_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,p_versioning_enabled            IN VARCHAR2
);



PROCEDURE Create_Child_Value_Set (
        p_api_version                   IN   NUMBER     := 1.0
       ,p_value_set_name                IN   VARCHAR2   -- Child Value Set Name
       ,p_description                   IN   VARCHAR2
       ,p_parent_vs_id                  IN   NUMBER
       ,p_owner                         IN   NUMBER
       ,child_vs_value_ids              IN   EGO_VALUE_SET_VALUE_IDS := NULL
                                           -- collection of value set value IDS
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_child_vs_id                   OUT NOCOPY NUMBER -- child value set ID
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Child_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_child_vs_id                   IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Child_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
--       ,p_maximum_size                  IN   NUMBER
--       ,p_maximum_value                 IN   VARCHAR2
--       ,p_minimum_value                 IN   VARCHAR2
--       ,p_long_list_flag                IN   VARCHAR2
--       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,child_vs_value_ids              IN   EGO_VALUE_SET_VALUE_IDS
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller wants to specify OWNER
PROCEDURE Update_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   FND_FLEX_VALUE_SETS.LONGLIST_FLAG%TYPE
                                                                    -- VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
--       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       --changes for P4T
       ,x_versioned_vs                 OUT NOCOPY VARCHAR2

);

PROCEDURE Insert_Value_Set_Table_Inf (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_table_application_id          IN   NUMBER
       ,p_table_name                    IN   VARCHAR2
       ,p_value_column_name             IN   VARCHAR2
       ,p_value_column_type             IN   VARCHAR2
       ,p_value_column_size             IN   NUMBER
       ,p_meaning_column_name           IN   VARCHAR2
       ,p_meaning_column_type           IN   VARCHAR2
       ,p_meaning_column_size           IN   NUMBER
       ,p_id_column_name                IN   VARCHAR2
       ,p_id_column_type                IN   VARCHAR2
       ,p_id_column_size                IN   NUMBER
       ,p_where_order_by                IN   VARCHAR2
       ,p_additional_columns            IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Value_Set_Table_Inf (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_table_application_id          IN   NUMBER
       ,p_table_name                    IN   VARCHAR2
       ,p_value_column_name             IN   VARCHAR2
       ,p_value_column_type             IN   VARCHAR2
       ,p_value_column_size             IN   NUMBER
       ,p_meaning_column_name           IN   VARCHAR2
       ,p_meaning_column_type           IN   VARCHAR2
       ,p_meaning_column_size           IN   NUMBER
       ,p_id_column_name                IN   VARCHAR2
       ,p_id_column_type                IN   VARCHAR2
       ,p_id_column_size                IN   NUMBER
       ,p_where_order_by                IN   VARCHAR2
       ,p_additional_columns            IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

FUNCTION has_flex_binding (cp_value_set_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION  is_vs_editable (cp_value_set_id  IN  NUMBER)
RETURN VARCHAR2;

                    --------------------------
                    -- Value Set Value APIs --
                    --------------------------

PROCEDURE Create_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,x_is_versioned                  OUT NOCOPY VARCHAR2
       ,x_valueSetId                    OUT NOCOPY VARCHAR2

);


PROCEDURE Create_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2

);


PROCEDURE Update_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,x_is_versioned                  OUT NOCOPY VARCHAR2
        ,x_valueSetId                    OUT NOCOPY VARCHAR2

);




PROCEDURE Translate_Value_Set_Val
       (p_api_version           IN   NUMBER
       ,p_value_set_name        IN   VARCHAR2
       ,p_internal_name         IN   VARCHAR2
       ,p_display_name          IN   VARCHAR2
       ,p_description           IN   VARCHAR2
       ,p_last_update_date      IN   VARCHAR2
       ,p_last_updated_by       IN   NUMBER
       ,p_init_msg_list         IN   VARCHAR2
       ,p_commit                IN   VARCHAR2
       ,x_return_status         OUT  NOCOPY  VARCHAR2
       ,x_msg_count             OUT  NOCOPY  NUMBER
       ,x_msg_data              OUT  NOCOPY  VARCHAR2
       );


PROCEDURE Process_VS_Value_Sequence
       (p_api_version                   IN   NUMBER
       ,p_transaction_type              IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER    DEFAULT NULL
       ,p_value_set_name                IN   VARCHAR2  DEFAULT NULL
       ,p_value_set_value_id            IN   NUMBER    DEFAULT NULL
       ,p_value_set_value               IN   VARCHAR2  DEFAULT NULL
       ,p_sequence                      IN   NUMBER
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       );


FUNCTION  is_vs_value_editable (cp_vs_value_id  IN  NUMBER)
RETURN VARCHAR2;

                  -----------------------------
                  -- Object Association APIs --
                  -----------------------------

-- signature to use if caller has OBJECT_ID and ATTR_GROUP_ID
PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has OBJECT_ID but not ATTR_GROUP_ID
PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have OBJECT_ID or ATTR_GROUP_ID
PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has ASSOCIATION_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ASSOCIATION_ID but has ATTR_GROUP_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ASSOCIATION_ID or ATTR_GROUP_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_force                         IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                 -------------------------------
                 -- Attribute Group Page APIs --
                 -------------------------------

PROCEDURE Create_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_page_id                       OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has PAGE_ID
PROCEDURE Update_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have PAGE_ID
-- the caller can set p_new_internal_name to null, in which case it will not be updated
PROCEDURE Update_Page (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_old_internal_name             IN   VARCHAR2
       ,p_new_internal_name             IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller has PAGE_ID
PROCEDURE Delete_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have PAGE_ID
PROCEDURE Delete_Page (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- A "group by" function for SQL queries
FUNCTION Group_Page_Regions (
        p_association_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,p_attr_group_description        IN   VARCHAR2
       ,p_enabled_code                  IN   VARCHAR2
)
RETURN VARCHAR2;

                      ---------------------
                      -- Page Entry APIs --
                      ---------------------

PROCEDURE Create_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_new_association_id            IN   NUMBER --2995435: Doesnt update association id
       ,p_old_association_id            IN   NUMBER --2995435: Doesnt update association id
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_classification_code           IN   VARCHAR2 -- Bug 3871440
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                       -------------------
                       -- Function APIs --
                       -------------------

PROCEDURE Create_Function (
        p_api_version                   IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_function_type                 IN   VARCHAR2
       ,p_function_info_1               IN   VARCHAR2
       ,p_function_info_2               IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_function_id                   OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Function (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_function_info_1               IN   VARCHAR2
       ,p_function_info_2               IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Function (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

               ------------------------------------
               -- Action and Action Display APIs --
               ------------------------------------

-- signature to use if caller has ATTR_GROUP_ID
PROCEDURE Create_Action (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER  DEFAULT NULL
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2  DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_id                     OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- signature to use if caller doesn't have ATTR_GROUP_ID
PROCEDURE Create_Action (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_grp_application_id       IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2  DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_id                     OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Action (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2 DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Action (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- call this API to create an Action that is executed by a user action
PROCEDURE Create_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,P_EXEC_CODE                     IN   VARCHAR2  := 'U'
       ,p_display_style                 IN   VARCHAR2
       ,p_prompt_application_id         IN   NUMBER
       ,p_prompt_message_name           IN   VARCHAR2
       ,p_visibility_flag               IN   VARCHAR2
       ,p_prompt_function_id            IN   NUMBER
       ,p_visibility_func_id            IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- call this API to create an Action that is executed by a trigger
PROCEDURE Create_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_trigger_code                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- call this API to update an Action that is executed by a user action
PROCEDURE Update_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,P_EXEC_CODE                     IN   VARCHAR2  := 'U'
       ,p_display_style                 IN   VARCHAR2
       ,p_prompt_application_id         IN   NUMBER
       ,p_prompt_message_name           IN   VARCHAR2
       ,p_visibility_flag               IN   VARCHAR2
       ,p_prompt_function_id            IN   NUMBER
       ,p_visibility_func_id            IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- call this API to update an Action that is executed by a trigger
PROCEDURE Update_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_trigger_code                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                  -----------------------------
                  -- Function Parameter APIs --
                  -----------------------------

PROCEDURE Create_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,p_param_type                    IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_function_param_id             OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_param_id             IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_param_id             IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                    -------------------------
                    -- Action Mapping APIs --
                    -------------------------

PROCEDURE Create_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_mapping_group_type            IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2
       ,p_mapping_group_pk2             IN   VARCHAR2
       ,p_mapping_group_pk3             IN   VARCHAR2
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


PROCEDURE Create_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);



PROCEDURE Update_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_mapping_group_type            IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2
       ,p_mapping_group_pk2             IN   VARCHAR2
       ,p_mapping_group_pk3             IN   VARCHAR2
       ,p_mapping_value                 IN   VARCHAR2
       ,p_new_func_param_id             IN   NUMBER     :=  NULL
       ,p_new_mapping_group_pk1         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_group_pk2         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_group_pk3         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_value             IN   VARCHAR2   :=  NULL
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


PROCEDURE Update_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2   :=  NULL
       ,p_mapping_group_pk2             IN   VARCHAR2   :=  NULL
       ,p_mapping_group_pk3             IN   VARCHAR2   :=  NULL
       ,p_new_func_param_id             IN   NUMBER     :=  NULL
       ,p_new_mapping_value             IN   VARCHAR2   :=  NULL
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


-- call this API to delete all mappings for a given action and function
PROCEDURE Delete_Func_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- call this API to delete an individual parameter mapping
PROCEDURE Delete_Func_Param_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                     -----------------------
                     -- Action Group APIs --
                     -----------------------

PROCEDURE Create_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_group_id               OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

                  -----------------------------
                  -- Action Group Entry APIs --
                  -----------------------------

PROCEDURE Create_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


PROCEDURE ADD_LANGUAGE (
       p_tl_table_name                 IN   VARCHAR2
);


FUNCTION Return_Association_Existance (
        p_application_id      IN   NUMBER
       ,p_attr_group_type     IN   VARCHAR2
       ,p_attr_group_name     IN   VARCHAR2
) return VARCHAR2;

PROCEDURE Update_AGV_Name(
  P_API_VERSION         IN   NUMBER
  ,P_APPLICATION_ID     IN   NUMBER
  ,P_ATTR_GROUP_TYPE    IN   VARCHAR2
  ,P_ATTR_GROUP_NAME    IN   VARCHAR2
  ,P_AGV_NAME           IN   VARCHAR2
  ,P_INIT_MSG_LIST      IN   VARCHAR2   :=  FND_API.G_FALSE
  ,P_COMMIT             IN   VARCHAR2   :=  FND_API.G_FALSE
  ,X_RETURN_STATUS      OUT NOCOPY VARCHAR2
  ,X_ERRORCODE          OUT NOCOPY NUMBER
  ,X_MSG_COUNT          OUT NOCOPY NUMBER
  ,X_MSG_DATA           OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Attribute_Control_Level (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_descriptive_flexfield_name    IN   VARCHAR2
       ,p_application_column_name       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


FUNCTION Convert_Class_Code_To_Name (
   p_object_name      IN VARCHAR2
  ,p_class_code       IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION Convert_Name_To_Class_Code (
   p_object_name      IN VARCHAR2
  ,p_class_name       IN VARCHAR2
) RETURN VARCHAR2;



PROCEDURE Sync_Up_Attr_Metadata (
                                   p_source_ag_name      IN     VARCHAR2,
                                   p_source_ag_type      IN     VARCHAR2,
                                   p_source_appl_id      IN     VARCHAR2,
                                   p_target_ag_name      IN     VARCHAR2,
                                   p_target_ag_type      IN     VARCHAR2,
                                   p_target_appl_id      IN     VARCHAR2,
                                   x_return_status       OUT  NOCOPY  VARCHAR2,
                                   x_errorcode           OUT  NOCOPY  VARCHAR2,
                                   x_msg_count           OUT  NOCOPY  NUMBER,
                                   x_msg_data            OUT  NOCOPY  VARCHAR2
                                );
--R12C
PROCEDURE Create_Action_Data_Level (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_data_level_id                  IN   NUMBER
       ,p_visibility_flag               IN   VARCHAR2 DEFAULT 'Y'
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);
PROCEDURE Delete_Action_Data_Level (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

FUNCTION Concat_Data_Level_DisplayNames (p_attr_grp_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Association_Id_From_PKs (
        p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
) RETURN NUMBER;

 /*
 * This Procedure is for invocation of User-Defined Functions from pl/sql side.
 * Currently ONLY type of PL/SQL user-defined function is supported.
 * @param p_ActionId, Indicates the Action Id to which the User-defined Function associated.
 * @param p_pk_col_value_pairs, Contains the Primary Key column names and
 *    values that identify the specific source object instance whose data is to be processed.
 * @param p_dtlevel_col_value_pairs, If the attribute group type has data
 *    levels defined and the source object instance contains any attribute
 *    groups that are associated at a data level other than the highest level
 *    defined for the attribute group type (e.g., if the attribute group type
 *    is 'EGO_ITEMMGMT_GROUP' and the EGO_ITEM has at least one attribute
 *    group associated at the ITEM_REVISION_LEVEL), then this will contain
 *    data level column names and values up to and including those for the
 *    lowest data level at which any attribute group is associated.
 * @param x_attributes_row_table, Contains row-level data and metadata about
 *    each attribute group whose data is being returned.
 * @param x_attributes_data_table, Contains data and metadata about each attribute
 *    whose data is being returned.
 * @param p_external_attrs_value_pairs, Since we can map any Attributes to
 *    User-defined Function parameters, this param store
 *    the External Attributes(different to AG in p_attributes_row_table) names and values pair.
 * @param x_return_status Returns one of three values indicating the
 *    most serious error encountered during processing:
 *    FND_API.G_RET_STS_SUCCESS if no errors occurred,
 *    FND_API.G_RET_STS_ERROR if at least one error occurred, and
 *    FND_API.G_RET_STS_UNEXP_ERROR if at least one unexpected error occurred.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 *    message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 *    message stack upon completion of processing, then this parameter
 *    contains that message.
 */
PROCEDURE Execute_Function(
                           p_Action_Id                     IN  Number
                          ,p_pk_col_value_pairs            IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
                          ,p_dtlevel_col_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
                          ,x_attributes_row_table          IN  OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
                          ,x_attributes_data_table         IN  OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
                          ,x_external_attrs_value_pairs    IN  OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_TABLE
                          ,x_return_status                 OUT NOCOPY VARCHAR2
                          ,x_errorcode                     OUT NOCOPY NUMBER
                          ,x_msg_count                     OUT NOCOPY NUMBER
                          ,x_msg_data                      OUT NOCOPY VARCHAR2
                           );

END EGO_EXT_FWK_PUB;

/
