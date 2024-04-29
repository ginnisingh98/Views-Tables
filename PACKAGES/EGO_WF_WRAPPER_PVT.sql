--------------------------------------------------------
--  DDL for Package EGO_WF_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_WF_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVWFWS.pls 120.6.12010000.2 2009/06/18 10:25:53 iyin ship $ */



--=======================================================================--
--=*********************************************************************=--
--=*===================================================================*=--
--=*=                                                                 =*=--
--=*=  NOTE: This is a PRIVATE package; it is for internal use only,  =*=--
--=*=  and it is not supported for customer use.                      =*=--
--=*=                                                                 =*=--
--=*===================================================================*=--
--=*********************************************************************=--
--=======================================================================--

  G_AML_CHANGE_EVENT            CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postAMLChange';
  G_ITEM_APPROVED_EVENT         CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postItemApproved';
  G_REV_CHANGE_EVENT            CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postRevisionChange';
  G_ITEM_UPDATE_EVENT           CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postItemUpdate';
  G_ITEM_CREATE_EVENT           CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postItemCreate';
  G_ITEM_CAT_ASSIGN_EVENT       CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postCatalogAssignmentChange';
--R12 Business Events
  G_PRE_ATTR_CHANGE_EVENT       CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.preAttributeChange';
  G_GTIN_ATTR_CHANGE_EVENT      CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postGTINAttributeChange';
  G_Xref_CHANGE_EVENT           CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postXrefChange';
  G_CUST_ITEM_XREF_CHANGE_EVENT CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postCustItemXrefChange';
  G_REL_ITEM_CHANGE_EVENT       CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postRelatedItemChange';
  G_DOC_ATTCH_CHANGE_EVENT      CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postDocAttachmentChange';
  G_ITEM_ROLE_CHANGE_EVENT      CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postItemRoleChange';
  G_VALID_CHANGE_EVENT          CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postValidCategoryChange';
  G_ITEM_BULKLOAD_EVENT         CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postItemBulkload';
  G_CAT_CATEGORY_CHANGE_EVENT   CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.item.postCatalogCategoryChange';
--R12 Business Events
  G_POST_PROCESS_MESSAGE_EVENT  CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.orchestration.postProcessMessage';

                          ----------------
                          -- Procedures --
                          ----------------

PROCEDURE Raise_WF_Business_Event (
        p_event_name                    IN   VARCHAR2
       ,p_event_key                     IN   VARCHAR2
       ,p_pre_event_flag                IN   VARCHAR2         DEFAULT NULL --Not null when used to raise pre event
       ,p_request_id                    IN   VARCHAR2         DEFAULT NULL
       ,p_dml_type                      IN   VARCHAR2         DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2         DEFAULT NULL
       ,p_extension_id                  IN   NUMBER           DEFAULT NULL
       ,p_primary_key_1_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_1_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_2_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_2_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_3_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_3_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_4_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_4_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_5_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_5_value           IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_id                 IN   NUMBER           DEFAULT NULL
       ,p_data_level_1_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_1_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_2_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_2_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_3_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_3_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_4_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_4_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_5_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_5_value            IN   VARCHAR2         DEFAULT NULL
       ,p_user_row_identifier           IN   VARCHAR2         DEFAULT NULL
       ,p_attr_name_val_tbl             IN   EGO_ATTR_TABLE   DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2         DEFAULT NULL
       ,p_entity_index                  IN   NUMBER           DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2         DEFAULT NULL
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2         DEFAULT NULL
);

PROCEDURE Raise_AML_Event(
         p_event_name          IN   VARCHAR2
        ,p_dml_type            IN   VARCHAR2
        ,p_Inventory_Item_Id   IN   NUMBER
        ,p_Organization_Id     IN   NUMBER
        ,p_Manufacturer_Id     IN   NUMBER
        ,p_Mfg_Part_Num        IN   VARCHAR2
        ,x_msg_data            OUT  NOCOPY VARCHAR2
        ,x_return_status       OUT  NOCOPY VARCHAR2
        );

--Start : 4105841 : Business Event Enhancement
/*Bug 6407303 Added the new parameter*/
PROCEDURE Raise_Item_Create_Update_Event(
         p_event_name          IN   VARCHAR2
        ,p_request_id          IN   NUMBER    DEFAULT NULL
        ,p_Organization_Id     IN   NUMBER    DEFAULT NULL
        ,p_organization_code   IN   VARCHAR2  DEFAULT NULL
        ,p_Inventory_Item_Id   IN   NUMBER    DEFAULT NULL
        ,p_item_number         IN   VARCHAR2  DEFAULT NULL
        ,p_item_description    IN   VARCHAR2  DEFAULT NULL
	,p_is_master_attr_modified IN   VARCHAR2  DEFAULT 'N'
        ,x_msg_data            OUT  NOCOPY VARCHAR2
        ,x_return_status       OUT  NOCOPY VARCHAR2
        );

PROCEDURE Raise_Item_Event(
          p_event_name           IN   VARCHAR2
         ,p_dml_type             IN   VARCHAR2    DEFAULT NULL
         ,p_request_id           IN   VARCHAR2    DEFAULT NULL
         ,p_Inventory_Item_Id    IN   NUMBER      DEFAULT NULL
         ,p_Organization_Id      IN   NUMBER      DEFAULT NULL
         ,p_Revision_id          IN   NUMBER      DEFAULT NULL
         ,p_category_id          IN   VARCHAR2    DEFAULT NULL
         ,p_catalog_id           IN   VARCHAR2    DEFAULT NULL
         ,p_old_category_id      IN   NUMBER      DEFAULT NULL --add 8310065 with base bug 8351807
         ,p_cross_reference_type IN   VARCHAR2    DEFAULT NULL --r12
         ,p_cross_reference      IN   VARCHAR2    DEFAULT NULL --r12
         ,p_customer_item_id     IN   NUMBER      DEFAULT NULL --r12
         ,p_related_item_id      IN   NUMBER      DEFAULT NULL --r12
         ,p_relationship_type_id IN   NUMBER      DEFAULT NULL --r12
         ,p_role_id              IN   NUMBER      DEFAULT NULL --r12
         ,p_party_type           IN   VARCHAR2    DEFAULT NULL --r12
         ,p_party_id             IN   NUMBER      DEFAULT NULL --r12
         ,p_start_date           IN   DATE        DEFAULT NULL --r12
         ,x_msg_data            OUT   NOCOPY VARCHAR2
         ,x_return_status       OUT   NOCOPY VARCHAR2
         );
--End : 4105841 : Business Event Enhancement

--R12 Business Event Enhancement
PROCEDURE Raise_Categories_Event(
          p_event_name           IN   VARCHAR2
         ,p_dml_type             IN   VARCHAR2 DEFAULT NULL
         ,p_category_set_id      IN   NUMBER   DEFAULT NULL
         ,p_category_id          IN   NUMBER   DEFAULT NULL
         ,p_category_name        IN   VARCHAR2 DEFAULT NULL
         ,x_msg_data            OUT   NOCOPY   VARCHAR2
         ,x_return_status       OUT   NOCOPY   VARCHAR2
         );

--R12C Raise Post Process Message Event for Orchestration
PROCEDURE Raise_Post_Process_Msg_Event(
          p_event_name            IN   VARCHAR2
         ,p_entity_name           IN   VARCHAR2
         ,p_pk1_value             IN   VARCHAR2
         ,p_pk2_value             IN   VARCHAR2
         ,p_pk3_value             IN   VARCHAR2
         ,p_pk4_value             IN   VARCHAR2
         ,p_pk5_value             IN   VARCHAR2
         ,p_processing_type       IN   VARCHAR2
         ,p_language_code         IN   VARCHAR2
         ,p_last_update_date      IN   VARCHAR2 /* Date Format: DD-MON-YYYY HH24:MI:SS */
         ,x_msg_data              OUT  NOCOPY VARCHAR2
         ,x_return_status         OUT  NOCOPY VARCHAR2
         );

--R12C Setters for Entity Level Business events
PROCEDURE Set_Item_Bulkload_Bus_Event(p_true_false IN VARCHAR2);
PROCEDURE Set_Rev_Change_Bus_Event(p_true_false IN VARCHAR2);
PROCEDURE Set_Category_Assign_Bus_Event(p_true_false IN VARCHAR2);
PROCEDURE Set_PostAttr_Change_Event(p_true_false IN VARCHAR2);
PROCEDURE Set_PostAml_Change_Event(p_true_false IN VARCHAR2);
PROCEDURE Set_Item_People_Event(p_true_false IN VARCHAR2);

--R12C Getters for Entity Level Business events
FUNCTION Get_Item_Bulkload_Bus_Event RETURN VARCHAR2;
FUNCTION Get_Rev_Change_Bus_Event RETURN VARCHAR2;
FUNCTION Get_Category_Assign_Bus_Event RETURN VARCHAR2;
FUNCTION Get_PostAttr_Change_Event RETURN VARCHAR2;
FUNCTION Get_PostAml_Change_Event RETURN VARCHAR2;
FUNCTION Get_Item_People_Event RETURN VARCHAR2;


END EGO_WF_WRAPPER_PVT;


/
