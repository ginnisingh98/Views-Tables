--------------------------------------------------------
--  DDL for Package EGO_TRANSACTION_ATTRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_TRANSACTION_ATTRS_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVITAS.pls 120.0.12010000.7 2010/06/11 12:38:35 kjonnala ship $ */

--  ============================================================================
--  Name        : Check_TA_IS_INVALID
--  Description : This function will be used to validate if any transaction
--                atrribute exist with same internal name/display name or sequence
--                while creating/updating a transaction attribute.
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute
--
--                p_attr_id          IN      VARCHAR2
--                attr_id of a transaction attribute to be created.
--
--                p_attr_name          IN      VARCHAR2
--                Internal Name of transaction attribute to be created.
--
--                p_attr_disp_name     IN      VARCHAR2
--                Display Name of transaction attribute to be created.
--
--                p_attr_sequence      IN      NUMBER
--                Sequence value for transaction attribute to be created,
--                corresponding to ICC p_item_cat_group_id.
--  ============================================================================

FUNCTION Check_TA_IS_INVALID (
        p_item_cat_group_id  IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_name          IN VARCHAR2  DEFAULT NULL ,
        p_attr_disp_name     IN VARCHAR2  DEFAULT NULL ,
        p_attr_sequence      IN NUMBER    DEFAULT NULL
)
RETURN BOOLEAN;


--  ============================================================================
--  Name        : IS_METADATA_CHANGE
--  Description : This function will be used to validate if any transaction
--                atrribute exist with same internal name/display name or sequence
--                while creating/updating a transaction attribute.
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute
--
--                p_attr_id          IN      VARCHAR2
--                attr_id of a transaction attribute to be created.
--
--                p_attr_name          IN      VARCHAR2
--                Internal Name of transaction attribute to be created.
--
--                p_attr_disp_name     IN      VARCHAR2
--                Display Name of transaction attribute to be created.
--
--                p_attr_sequence      IN      NUMBER
--                Sequence value for transaction attribute to be created,
--                corresponding to ICC p_item_cat_group_id.
--  ============================================================================
PROCEDURE IS_METADATA_CHANGE (
        p_tran_attrs_tbl  IN          EGO_TRAN_ATTR_TBL,
        p_ta_metadata_tbl OUT NOCOPY  EGO_TRAN_ATTR_TBL,
        x_return_status   OUT NOCOPY  VARCHAR2,
        x_msg_count       OUT NOCOPY  NUMBER,
        x_msg_data        OUT NOCOPY  VARCHAR2);


--  ============================================================================
--  Name        : Check_Ta_Int_Name_Exist
--  Description : This function will be used to validate if any transaction
--                atrribute exist with same internal name while creating/ updating
--                a transaction attribute.
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute
--
--                p_attr_name          IN      VARCHAR2
--                Internal Name of transaction attribute to be created.
--  ============================================================================
/*
FUNCTION Check_Ta_Int_Name_Exist (
        p_item_cat_group_id  IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_name IN VARCHAR2
)
RETURN BOOLEAN; */

--  ============================================================================
--  Name        : Check_Ta_Disp_Name_Exist
--  Description : This function will be used to validate if any transaction
--                atrribute exist with same display name while creating/ updating
--                a transaction attribute.
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute
--
--                p_attr_disp_name     IN      VARCHAR2
--                Display Name of transaction attribute to be created.
--  ============================================================================
/*
FUNCTION Check_Ta_Disp_Name_Exist (
        p_item_cat_group_id  IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_disp_name IN VARCHAR2
)
RETURN BOOLEAN;

*/
--  ============================================================================
--  Name        : Check_Ta_Sequence_Exist
--  Description : This function will be used to validate if any transaction
--                atrribute exist with same sequence while creating/ updating
--                a transaction attribute.
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute
--
--                p_attr_sequence      IN      NUMBER
--                Sequence value for transaction attribute to be created,
--                corresponding to ICC p_item_cat_group_id.
--  ============================================================================
/*
FUNCTION Check_Ta_Sequence_Exist (
        p_item_cat_group_id  IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_sequence      IN NUMBER
)
RETURN BOOLEAN;
*/
--  ============================================================================
--  Name        : Check_Ta_Default_Value_Null
--  Description : This function will be used to validate if default value is NULL
--                for a transaction attribute whose requiredflag and readonlyflag
--                both are checked
--  Parameters:
--        IN    :
--                p_item_cat_group_id  IN      NUMBER
--                Item catalog group id value for that transaction attribute.
--  ============================================================================
/*
FUNCTION Check_Ta_Default_Value_Null (
        p_item_cat_group_id  IN NUMBER
)
RETURN BOOLEAN;

*/
--  ============================================================================
--  Name        : Create_Transaction_Attribute
--  Description : This procedure will be used to create a transaction
--                atrribute.
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_tran_attrs_tbl     IN      EGO_TRAN_ATTR_TBL
--                Nested table instance having information of metadata of a
--                transaction attribute.
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Create_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2) ;


--  ============================================================================
--  Name        : Update_Transaction_Attribute
--  Description : This procedure will be used to update a transaction
--                atrribute.
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_tran_attrs_tbl     IN      EGO_TRAN_ATTR_TBL
--                Nested table instance having information of metadata of a
--                transaction attribute.
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================


PROCEDURE Update_Transaction_Attribute (
        p_api_version      IN         NUMBER,
        p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2) ;

--  ============================================================================
--  Name        : Delete_Transaction_Attribute
--  Description : This procedure will be used to update a transaction
--                atrribute.
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_association_id     IN      NUMBER
--                Association Id corresponding to a attribute group of a
--                transaction attribute.
--
--                p_attr_id            IN      NUMBER
--                Attribute Id corresponding to a transaction attribute.
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Delete_Transaction_Attribute (
        p_api_version      IN         NUMBER,
        p_association_id   IN         NUMBER,
        p_attr_id          IN         NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2) ;


/**Override procedure */
--  ============================================================================
--  Name        : Delete_Transaction_Attribute
--  Description : This procedure will be used to update a transaction
--                atrribute.
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_tran_attrs_tbl     IN      EGO_TRAN_ATTR_TBL
--                Nested table instance having information of metadata of a
--                transaction attribute.
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Delete_Transaction_Attribute (
        p_api_version      IN         NUMBER,
        p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2) ;

--  ============================================================================
--  Name        : Release_Transaction_Attribute
--  Description : This procedure will be used to release transaction
--                atrribute for a ICC version.
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                /*p_tran_attrs_tbl     IN      EGO_TRAN_ATTR_TBL
--                Nested table instance having information of metadata of a
--                transaction attribute.*/
--
--                p_icc_id             IN      NUMBER
--                Passed in ICC id.
--
--                p_version_number     IN      NUMBER
--                Version Id corresponding to passed in ICC id.
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================


PROCEDURE Release_Transaction_Attribute (
        p_api_version      IN         NUMBER,
        p_icc_id           IN         NUMBER,
        p_version_number   IN         NUMBER,
        --p_tran_attrs_tbl IN         EGO_TRAN_ATTR_TBL,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2) ;


--  ============================================================================
--  Name        : Copy_Transaction_Attribute
--  Description : This procedure will create copy of a transaction attribute with
--                new released icc_version_number.
--        IN    :
--                p_icc_id             IN      NUMBER
--                Passed in ICC id.
--
--                p_version_number     IN      NUMBER
--                Version Id corresponding to passed in ICC id.
--
--        OUT   :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Copy_Transaction_Attribute (
        p_item_cat_group_id   IN         NUMBER,
        p_version_number      IN         NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2);

--  ============================================================================
--  Name        : Copy_Transaction_Attribute
--  Description : This procedure will create copy of a transaction attribute for
--                passed in source and destination parameter.
--        IN    :
--                p_source_icc_id      IN      NUMBER
--                Passed in ICC id from where TA need to copy.
--
--                p_source_ver_no      IN      NUMBER
--                Version Id corresponding to passed in ICC id to be copy.
--
--                p_sorce_item_id      IN      NUMBER
--                passed in inventory_item_id.
--
--                p_source_rev_id      IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                p_source_org_id      IN      NUMBER
--                org Id of inventory_item_id.
--
--                p_dest_icc_id      IN      NUMBER
--                Destination ICC id for which TA need to be copy.
--
--                p_dest_ver_no      IN      NUMBER
--                Destination Id corresponding to passed in destination ICC id.
--
--                p_dest_item_id      IN      NUMBER
--                passed in inventory_item_id.
--
--                p_dest_rev_id      IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                p_dest_org_id      IN      NUMBER
--                org Id of inventory_item_id.
--
--
--        OUT   :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Copy_Transaction_Attribute (
        p_source_icc_id       IN         NUMBER,
        p_source_ver_no       IN         NUMBER,
        p_sorce_item_id       IN         NUMBER,
        p_source_rev_id       IN         NUMBER,
        p_source_org_id       IN         NUMBER,
        p_dest_icc_id         IN         NUMBER,
        p_dest_ver_no         IN         NUMBER,
        p_dest_item_id        IN         NUMBER,
        p_dest_rev_id         IN         NUMBER,
        p_dest_org_id         IN         NUMBER,
        p_init_msg_list       IN         BOOLEAN DEFAULT TRUE,     --- Bug 9791391, made default true to maintain existing TA code
        x_return_status       OUT NOCOPY VARCHAR2,            --- , generally default is FALSE
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2);

--  ============================================================================
--  Name        : Revert_Transaction_Attribute
--  Description : This procedure will revert to a earlier version.
--        IN    :
--                p_source_icc_id      IN      NUMBER
--                Passed in ICC id from where TA need to copy.
--
--                p_source_ver_no      IN      NUMBER
--                Version Id corresponding to passed in ICC id to be copy.
--
--                p_sorce_item_id      IN      NUMBER
--                passed in inventory_item_id.
--
--                p_source_rev_id      IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                p_source_org_id      IN      NUMBER
--                org Id of inventory_item_id.
--
--                p_dest_icc_id      IN      NUMBER
--                Destination ICC id for which TA need to be copy.
--
--                p_dest_ver_no      IN      NUMBER
--                Destination Id corresponding to passed in destination ICC id.
--
--                p_dest_item_id      IN      NUMBER
--                passed in inventory_item_id.
--
--                p_dest_rev_id      IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                p_dest_org_id      IN      NUMBER
--                org Id of inventory_item_id.
--
--
--        OUT   :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================
PROCEDURE Revert_Transaction_Attribute (
        p_source_icc_id       IN         NUMBER,
        p_source_ver_no       IN         NUMBER,
        p_init_msg_list       IN         BOOLEAN DEFAULT TRUE,    --- Bug 9791391, made default true to maintain existing TA code,
        x_return_status       OUT NOCOPY VARCHAR2,            --- generally default is FALSE
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2);
--=================================================================================

--  Name        : Get_Trans_Attr_Metadata
--  Description : This procedure will be used to retreive transaction attribute metadata based on given parameter
--  Parameters:
--        IN    :
--               p_item_catalog_category_id
--       p_icc_version
--       p_attribute_id
--       p_inventory_item_id
--       p_organization_id
--       p_revision_id
--
--        OUT    :
--                x_ta_metadata_tbl      OUT NOCOPY VARCHAR2
--                Out parameter contain the record of transaction attribute metadata.
--        return null if given input is not valid

PROCEDURE Get_Trans_Attr_Metadata(
        x_ta_metadata_tbl          OUT NOCOPY  EGO_TRAN_ATTR_TBL,
    p_item_catalog_category_id IN number,
    p_icc_version          IN number,
    p_attribute_id         IN NUMBER,
    p_inventory_item_id    IN NUMBER ,
    p_organization_id      IN NUMBER,
    p_revision_id          IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2 ,
    x_is_inherited             OUT  NOCOPY varchar2,
    x_is_modified              OUT  NOCOPY varchar2
                                            )   ;


--  ============================================================================
--  Name        : Create_Transaction_Attribute
--  Description : This procedure will be used to create a transaction
--                atrribute.
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_tran_attrs_tbl     IN      EGO_TRAN_ATTR_TBL
--                Nested table instance having information of metadata of a
--                transaction attribute.
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_msg_data           OUT NOCOPY VARCHAR2
--
--  ============================================================================

PROCEDURE Create_Inherited_Trans_Attr(
        p_api_version      IN         NUMBER,
        p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2) ;

--  ============================================================================
--  Name        : Check_VS_Data_Type
--  Description : This function will check if data type of value set is valid
--                or not and will return true or false based on validation.
--
--        IN    :
--                p_value_set_id             IN      NUMBER
--                Passed in Value Set Id associate to TA.
--
--                p_data_type     IN      NUMBER
--                Data type of value set.
--
--        OUT   :
--                Boolean value returning true or false.
--  ============================================================================
FUNCTION Check_VS_Data_Type (
        p_value_set_id  IN NUMBER,
        p_data_type     IN VARCHAR2
)
RETURN BOOLEAN;

--  ============================================================================
--  Name        : GET_ATTR_DISP_NAME
--
--  Description : This function will be used to get transaction atrribute display
--                name down the hierarchy at Item/ICC and will return first not null
--                attribute display name.
--  Parameters:
--        IN    :
--                P_ITEM_CAT_GROUP_ID  IN      NUMBER
--                Item catalog group id value.
--
--                P_ICC_VERSION_NUMBER IN      NUMBER
--                Version Id corresponding to passed in ICC id.
--
--                P_INVENTORY_ITEM_ID  IN      NUMBER
--                passed in inventory_item_id.
--
--                P_ORGANIZATION_ID    IN      NUMBER
--                org Id of inventory_item_id.
--
--                P_REVISION_ID        IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                P_CREATION_DATE      IN      VARCHAR2
--                creation date of effective version of ICC or that of Item.
--
--                P_START_DATE         IN      VARCHAR2
--                Start Effective date of effective version of ICC or that of Item.
--
--                P_ATTR_ID            IN      VARCHAR2
--                attr_id of a transaction attribute to get corresponding
--                attribute display name.
--        OUT   :
--                Varchar value returning Display Name of transaction attribute.
--
--  ============================================================================

FUNCTION GET_ATTR_DISP_NAME (
                            P_ITEM_CAT_GROUP_ID  IN          NUMBER,
                            P_ICC_VERSION_NUMBER IN          NUMBER,
                            P_INVENTORY_ITEM_ID  IN          NUMBER DEFAULT NULL,
                            P_ORGANIZATION_ID    IN          NUMBER DEFAULT NULL,
                            P_REVISION_ID        IN          NUMBER DEFAULT NULL,
                            P_CREATION_DATE      IN          DATE   DEFAULT NULL,
                            P_START_DATE         IN          DATE   DEFAULT NULL,
                            P_ATTR_ID            IN          NUMBER
                            )
RETURN VARCHAR2;

--  ============================================================================
--  Name        : GET_VS_ID
--
--  Description : This function will be used to get value set Id  down the hierarchy
--                at Item/ICC and will return first not null that is associated to
--                transaction atrribute.
--  Parameters:
--        IN    :
--                P_ITEM_CAT_GROUP_ID  IN      NUMBER
--                Item catalog group id value.
--
--                P_ICC_VERSION_NUMBER IN      NUMBER
--                Version Id corresponding to passed in ICC id.
--
--                P_INVENTORY_ITEM_ID  IN      NUMBER
--                passed in inventory_item_id.
--
--                P_ORGANIZATION_ID    IN      NUMBER
--                org Id of inventory_item_id.
--
--                P_REVISION_ID        IN      NUMBER
--                revision Id for passed in inventory_item_id.
--
--                P_CREATION_DATE      IN      VARCHAR2
--                creation date of effective version of ICC or that of Item.
--
--                P_START_DATE         IN      VARCHAR2
--                Start Effective date of effective version of ICC or that of Item.
--
--                P_ATTR_ID            IN      VARCHAR2
--                attr_id of a transaction attribute to get corresponding
--                attribute display name.
--        OUT   :
--                Number value returning value set id corresponding to transaction attribute.
--
--  ============================================================================
FUNCTION GET_VS_ID (
                            P_ITEM_CAT_GROUP_ID  IN          NUMBER,
                            P_ICC_VERSION_NUMBER IN          NUMBER,
                            P_INVENTORY_ITEM_ID  IN          NUMBER DEFAULT NULL,
                            P_ORGANIZATION_ID    IN          NUMBER DEFAULT NULL,
                            P_REVISION_ID        IN          NUMBER DEFAULT NULL,
                            P_CREATION_DATE      IN          DATE   DEFAULT NULL,
                            P_START_DATE         IN          DATE   DEFAULT NULL,
                            P_ATTR_ID            IN          NUMBER
                            )
RETURN NUMBER;

PROCEDURE has_invalid_char (
                              p_internal_name  IN VARCHAR2,
                              x_has_invalid_chars OUT  NOCOPY VARCHAR2
);

END EGO_TRANSACTION_ATTRS_PVT ;

/
