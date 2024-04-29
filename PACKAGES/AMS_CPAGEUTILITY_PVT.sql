--------------------------------------------------------
--  DDL for Package AMS_CPAGEUTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CPAGEUTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpgs.pls 115.24 2002/06/09 17:55:24 pkm ship        $ */

-- Define Constants used by the package.
G_AMS_DIR_NODE_ID                      CONSTANT NUMBER       := 3 ; -- Changed on Mar 06 as the new directory node for CPAGE.
G_CPAGE_ASSOC_TYPE_CODE                CONSTANT VARCHAR2(30) := 'CONTENT_FOR_OMO_CPAGE' ;
G_OWNER_RESOURCE_TYPE                  CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE' ;
G_RICH_CONTENT                         CONSTANT VARCHAR2(30) := 'AMS_RICH_CONTENT' ;
G_HAS_MERGE_FIELDS                     CONSTANT VARCHAR2(30) := 'HAS_MERGE_FIELDS' ;
G_HAS_PAGE_MERGE_FIELDS                CONSTANT VARCHAR2(30) := 'HAS_PAGE_MERGE_FIELDS' ;
G_FUNCTIONAL_TYPE                      CONSTANT VARCHAR2(30) := 'FUNCTIONAL_TYPE' ;
G_DATA_SOURCE                          CONSTANT VARCHAR2(30) := 'DATA_SOURCE' ;
G_MERGE_FIELD                          CONSTANT VARCHAR2(30) := 'MERGE_FIELD' ;
G_SELECT_SQL_QUERY                     CONSTANT VARCHAR2(30) := 'SELECT_SQL_QUERY' ; --used in AMS_QUESTIONS
G_SELECT_SQL_STATEMENT                 CONSTANT VARCHAR2(30) := 'SELECT_SQL_STATEMENT' ; --used in AMS_RICH_CONTENT
G_BIND_VAR                             CONSTANT VARCHAR2(30) := 'BIND_VAR' ;
G_DEFAULT_FUNCTIONAL_TYPE              CONSTANT VARCHAR2(30) := 'NORMAL' ;
G_CP_IMAGE                             CONSTANT VARCHAR2(30) := 'AMS_CP_IMAGE' ;
G_QUESTIONS                            CONSTANT VARCHAR2(30) := 'AMS_QUESTIONS' ;
G_SUBMIT_SECTION                       CONSTANT VARCHAR2(30) := 'AMS_SUBMIT_SECTION' ;
G_DEF_UI_FOR_SUBMIT                    CONSTANT VARCHAR2(30) := 'BUTTON' ;
G_DEF_ALIGN_FOR_SUBMIT                 CONSTANT VARCHAR2(30) := 'CENTER' ;
G_IBC_IMAGE                            CONSTANT VARCHAR2(30) := 'IBC_IMAGE' ;
G_IBC_STYLESHEET                       CONSTANT VARCHAR2(30) := 'IBC_STYLESHEET' ;
G_CITEM_APPROVED_STATUS_CODE           CONSTANT VARCHAR2(30) := IBC_UTILITIES_PUB.G_STV_APPROVED ;
G_CITEM_WIP_STATUS_CODE                CONSTANT VARCHAR2(30) := IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS ;
G_DEFAULT_DISPLAY_TEMPLATE             CONSTANT VARCHAR2(40) := 'DEFAULT_DISPLAY_TEMPLATE' ;
G_DELIVERY_CHANNEL                     CONSTANT VARCHAR2(30) := 'DELIVERY_CHANNEL' ;
G_OUTPUT_TYPE                          CONSTANT VARCHAR2(30) := 'OUTPUT_TYPE' ;
G_UI_CONTROL_TYPE                      CONSTANT VARCHAR2(30) := 'UI_CONTROL_TYPE' ;
G_OCM_IMAGE_ID                         CONSTANT VARCHAR2(30) := 'OCM_IMAGE_ID' ;
G_BUTTON_LABEL                         CONSTANT VARCHAR2(30) := 'BUTTON_LABEL' ;
G_ALIGNMENT                            CONSTANT VARCHAR2(30) := 'ALIGNMENT' ;
-- Bind Variables
G_BIND_VAR_AMSP                        CONSTANT VARCHAR2(30) := 'amsp';
G_BIND_VAR_AMSSC                       CONSTANT VARCHAR2(30) := 'amssc';
G_BIND_VAR_AMSRELP                     CONSTANT VARCHAR2(30) := 'amsrelp';
G_BIND_VAR_AMSORGP                     CONSTANT VARCHAR2(30) := 'amsorgp';
G_BIND_VAR_AMSADDRESSP                 CONSTANT VARCHAR2(30) := 'amsaddressp';
G_BIND_VAR_AMSCTP                      CONSTANT VARCHAR2(30) := 'amsctp';
G_BIND_VAR_AMSORGCT                    CONSTANT VARCHAR2(30) := 'amsorgct';
-- Data Sources
G_PEROSN_LIST_DATA_SRC                 CONSTANT VARCHAR2(30) := 'PERSON_LIST';
G_PERSON_PHONE1_DATA_SRC               CONSTANT VARCHAR2(30) := 'PERSON_PHONE1';
G_PERSON_PHONE2_DATA_SRC               CONSTANT VARCHAR2(30) := 'PERSON_PHONE2';
G_PERSON_PHONE3_DATA_SRC               CONSTANT VARCHAR2(30) := 'PERSON_PHONE3';
G_EMAIL_DATA_SRC                       CONSTANT VARCHAR2(30) := 'EMAIL';
G_FAX_DATA_SRC                         CONSTANT VARCHAR2(30) := 'FAX';
G_ORG_LIST_DATA_SRC                    CONSTANT VARCHAR2(30) := 'ORGANIZATION_LIST';
G_ORG_CONTACT_LIST_DATA_SRC            CONSTANT VARCHAR2(30) := 'ORGANIZATION_CONTACT_LIST';
G_PIN_CODE_DATA_SRC                    CONSTANT VARCHAR2(30) := 'OMO_PIN_CODE';
G_LEAD_QUAL_DATA_SRC                   CONSTANT VARCHAR2(30) := 'OMO_LEAD_QUALIFIER';
/*
Making changes in generate_sql_statement. April 30, 2002.
According to Avijit, for Runtime of Questions Section the bind variable name
has to be changed based on the Data Source column and field.
This change is fine, but it will not work for user defined data sources at all.
For address, amsp is good for address-es.
For email, fax, phone-s , please put amsctp
For company name, please put amsorgp - org party id,
For job title, amsrelp - relationshipparty id is good.
--
This is what the above translates to :
for PERSON_LIST as list_source_type, amsp should be used.
for PERSON_PHONE1 to PERSON_PHONE3 and EMAIL and FAX, amscpt (contant points) should be used.
When the same page is used in B2C Context, Avijit's runtime uses Person Party Id.
When the same page is used in B2B Context, Avijit's runtime uses Relationship Party Id.
We are not covering the Business Phones and other details as yet.
for ORGANIZATION_LIST as list_source_type, amsorgp should be used. This is Organization Party ID.
for ORGANIZATION_CONTACT_LIST as list_source_type, amsrelp should be used. This is Relationship Party ID.
*/
G_QUESTIONNAIRE                        CONSTANT VARCHAR2(30) := 'QUESTIONNAIRE';
G_SEPARATOR                            CONSTANT VARCHAR2(30) := 'SEPARATOR';
G_TOC                                  CONSTANT VARCHAR2(30) := 'AMS_TOC';

/*
Test script:
declare
--Make sure that ibc_association_types_b and tl table have valid data.
delvId number(15) := 10061;
cTypeCode varchar2(30) := 'TEST_COMPOUND_1';
defDispTempId number(15) := null;
assocTypeCode varchar2(30) := 'CONTENT_FOR_OMO_CPAGE';
commitFlag varchar2(1) := 'F';
apiVer number(10) := 1.0;
valLevel number(15) := 100;
cItemId number(15);
cItemVerId number(15);
status varchar2(1);
msgCnt number(10);
msgData varchar2(2000);
begin
AMS_CPageUtility_PVT.create_citem_for_delv(
   p_content_type_code      => cTypeCode
   ,p_def_disp_template_id  => defDispTempId
   ,p_delv_id               => delvId
   ,p_assoc_type_code       => assocTypeCode
   ,p_commit                => commitFlag
   ,p_api_version           => apiVer
   ,p_api_validation_level  => valLevel
   ,x_citem_id              => cItemId
   ,x_citem_ver_id          => cItemVerId
   ,x_return_status         => status
   ,x_msg_count             => msgCnt
   ,x_msg_data              => msgData
);
dbms_output.put_line('status = ' || status);
dbms_output.put_line('citemid = ' || cItemId);
dbms_output.put_line('citemverid = ' || cItemVerId);
end;
*/
-----------------------------------------------------------------------
-- PROCEDURE
--    create_citem_for_delv
--
-- PURPOSE
--    Create a Content Item for Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         default_display_template_id
--         deliverable_id
--         association_type_code (to be recorded in ibc_associations table)
--    2. This procedure returns the Content Item ID of the newly created
--       Content Item associated with the given deliverable.
--
-----------------------------------------------------------------------
PROCEDURE create_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_def_disp_template_id  IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    approve_citem_for_delv
--
-- PURPOSE
--    Approve the Content Item associated with the Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         deliverable_id
--         content_item_id
--         association_type_code (this is recorded in ibc_associations table)
--    2. This procedure returns the success or failure status
--
-----------------------------------------------------------------------
PROCEDURE approve_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_citem_id              IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    update_citem_for_delv
--
-- PURPOSE
--    Update the Content Item associated with the Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         default_display_template_id
--         deliverable_id
--         content_item_id
--         association_type_code (this is recorded in ibc_associations table)
--    2. This procedure returns the success or failure status
--
-----------------------------------------------------------------------
PROCEDURE update_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_def_disp_template_id  IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_citem_id              IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    manage_rich_content
--
-- PURPOSE
--    Manage a Rich Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be RICH_CONTENT.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Attachment File ID that has the Rich Content Data.
--       Attachment File Name.
--       Start Date
--       End Date
--       Owner Resource ID
--       Owner Resource Type
--       Value for HAS_MERGE_FIELDS
--       Value for HAS_PAGE_MERGE_FIELDS
--    2. The optional input is as follows:
--       Content Item Id : If given Update is done.
--       Content Item Version Id : If given Update is done.
--       Description.
--       Attribute Type Code for the Section.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       VARCHAR2 Array of Data Source Programmatic Access Codes.
--       VARCHAR2 Array of Merge Field names.
--       Note that these names contain the Programmatic Access Code for the
--       Data Source as well as the Column Name, separated by a period.
--          If this Array has data, the SELECT_SQL_QUERY type of Content Items
--          will be created for each of Data Sources that appear in the list.
--          The MERGE_FIELD Content Items will be created for each of the item
--          in the Array.
--          Compound relations will be created between the MERGE_FIELD items and
--          SELECT_SQL_QUERY items and between SELECT_SQL_QUERY items and the
--          newly created RICH_CONTENT item.
--    3. This procedure performs the following steps:
--          1. Create a Basic Content Item for Rich Content with insert_basic_citem
--          2. Add the Meta Data with set_citem_meta.
--          3. Set the Attachment for this Content Item.
--          4. Set the Attribute Bundle for this Content Item.
--             Arrive at the value for FUNCTIONAL_TYPE.
--             This will consist of the following attributes:
--                HAS_MERGE_FIELDS
--                HAS_PAGE_MERGE_FIELDS
--                FUNCTIONAL_TYPE
--          5. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created RICH_CONTENT item.
--          6. If the Merge Fields List is not empty, do the following:
--             Collect all the Merge Fields from one data source together.
--             For each such data source, do the following:
--                Create MERGE_FIELD Content Item for each Merge Field for this Data Source with an APPROVED status. Use BULK_INSERT.
--                   Pick up the Field Type from Data Source schema.
--                Generate SQL Query for the resolution of these Merge Fields in APPROVED status. Use BULK_INSERT.
--                Create the SELECT_SQL_QUERY content item.
--                Create Compound Relations between the SELECT_SQL_QUERY and the MERGE_FIELD content items.
--             Create Compound Relations between the SELECT_SQL_QUERY items and the RICH_CONTENT content item.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    14-FEB-2002   gdeodhar     Created.
--    11-MAR-2002   gdeodhar     Added Update to the same method.
--
-----------------------------------------------------------------------
PROCEDURE manage_rich_content(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_has_merge_fields      IN  VARCHAR2,
   p_has_page_merge_fields IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_data_source_list      IN  JTF_VARCHAR2_TABLE_300,
   p_merge_fields_list     IN  JTF_VARCHAR2_TABLE_300,
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   px_citem_id             IN OUT NUMBER,
   px_citem_ver_id         IN OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2,
   p_dml_flag              IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true
);


-----------------------------------------------------------------------
-- PROCEDURE
--    manage_toc_section
--
-- PURPOSE
--    Manage a TOC Section Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be AMS_TOC.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Start Date
--       End Date
--       Owner Resource ID
--       Owner Resource Type
--    2. The optional input is as follows:
--       Content Item Id : If given Update is done.
--       Content Item Version Id : If given Update is done.
--       Description.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       VARCHAR2 caption.
--       VARCHAR2 list style.
--       VARCHAR2 Array of Attribute Type Codes.
--       VARCHAR2 Array of Attribute Values.
--       Attachment File ID that has TOC XML Data for runtime.
--       Attachment File Name.
--    3. This procedure performs the following steps:
--          1. Create a Basic Content Item for Rich Content with insert_basic_citem
--          2. Add the Meta Data with set_citem_meta.
--          3. Set the Attachment for this Content Item.
--          4. Set the Attribute Bundle for this Content Item.
--          5. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created TOC item.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    10-APR-2002   asaha     Created.
--
-----------------------------------------------------------------------
PROCEDURE manage_toc_section(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attr_types            IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values           IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_attribute_type_code   IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   px_citem_id             IN OUT NUMBER,
   px_citem_ver_id         IN OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2,
   p_dml_flag              IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true
);

-----------------------------------------------------------------------
-- PROCEDURE
--    update_questions_section
--
-- PURPOSE
--    Update Questions Section Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Deliverable ID.
--       Content Item ID for the section.
--       Content Item Version ID for the section.
--       Content Type Code for the Section. This must be QUESTIONS.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Attachment File ID that has the XML Data.
--       Attachment File Name.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Arrive at SELECT SQL Statements for each Data Source used in the section.
--          2. Arrive at the FUNCTIONAL_TYPE value.
--          3. Set the Attachment for this Content Item.
--          4. Set the Attribute Bundle for this Content Item.
--             This will consist of the following attributes:
--                SELECT_SQL_STATEMENT (s) : These could be many.
--                FUNCTIONAL_TYPE
--          5. Delete the Data Source Usages records if already available.
--          6. Insert the Data Source Usages records for the Data Sources used.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    24-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_questions_section(
   p_delv_id               IN  NUMBER,
   p_section_citem_id      IN  NUMBER,
   p_section_citem_ver_id  IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    get_rich_content_data
--
-- PURPOSE
--    Get the data from Rich Content Item.
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--    2. This procedure returns the following data back to the caller.
--         citem_version_id for the content item.
--         attachment_file_id
--         attachment_file_name
--         citem_name
--         attribute_types (array)
--         attribute_values (array)
--
-----------------------------------------------------------------------
PROCEDURE get_rich_content_data(
   p_citem_id              IN  NUMBER,
   p_api_version           IN  NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_attach_file_id        OUT NUMBER,
   x_attach_file_name      OUT VARCHAR2,
   x_citem_name            OUT VARCHAR2,
   x_attribute_types       OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_values      OUT JTF_VARCHAR2_TABLE_4000,
   x_object_version_number OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    get_content_item_data
--
-- PURPOSE
--    Get the Content Item Details. Wrapper on IBC_CITEM_ADMIN_GRP.get_citem
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--         content_item_version_id
--    2. This procedure calls the get_citem from IBC_CITEM_ADMIN_GRP package.
--       It only sends the useful data back to the caller.
--
-----------------------------------------------------------------------
PROCEDURE get_content_item_data(
   p_citem_id              IN  NUMBER,
   p_citem_ver_id          IN  NUMBER,
   p_api_version           IN  NUMBER,
   x_status                OUT VARCHAR2,
   x_attach_file_id        OUT NUMBER,
   x_attach_file_name      OUT VARCHAR2,
   x_citem_name            OUT VARCHAR2,
   x_description           OUT VARCHAR2,
   x_attribute_type_codes  OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_type_names  OUT JTF_VARCHAR2_TABLE_300,
   x_attributes            OUT JTF_VARCHAR2_TABLE_4000,
   x_cpnt_citem_ids        OUT JTF_NUMBER_TABLE,
   x_cpnt_ctype_codes      OUT JTF_VARCHAR2_TABLE_100,
   x_cpnt_attrib_types     OUT JTF_VARCHAR2_TABLE_100,
   x_cpnt_citem_names      OUT JTF_VARCHAR2_TABLE_300,
   x_cpnt_sort_orders      OUT JTF_NUMBER_TABLE,
   x_object_version_number OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    get_content_item_attrs
--
-- PURPOSE
--    Wrapper on IBC_CITEM_ADMIN_GRP.get_attribute_bundle
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--         content_type_code
--         content_item_version_id
--    2. This procedure calls the get_attribute_bundle from IBC_CITEM_ADMIN_GRP package.
--       It only sends the useful data back to the caller.
--
-----------------------------------------------------------------------
PROCEDURE get_content_item_attrs(
   p_citem_id              IN  NUMBER,
   p_ctype_code            IN  VARCHAR2,
   p_citem_ver_id          IN  NUMBER,
   p_attrib_file_id        IN  NUMBER                    DEFAULT NULL,
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   x_attribute_type_codes  OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_type_names  OUT JTF_VARCHAR2_TABLE_300,
   x_attributes            OUT JTF_VARCHAR2_TABLE_4000,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    create_cp_image
--
-- PURPOSE
--    Create the CP_IMAGE Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be CP_IMAGE.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Deliverable ID.
--       Two Arrays : one with all the attribute type codes for CP_IMAGE.
--                    second with the corresponding values for CP_IMAGE.
--    2. The optional input is as follows:
--       Description.
--       Attribute Type Code for the Parent's Section.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       Attachment File Id of the newly uploaded binary file.
--       Attachment File Name for the same.
--       Two Arrays : one with the attribute type codes for IMAGE.
--                    second with the corresponding values for IMAGE.
--          If the above four are available, this procedure will create a Content Item
--          of type IMAGE (the OCM's IMAGE) first and use the content_item_id of
--          this content item for CP_IMAGE.
--       If the above two are unavailable, the content_item_id of the IMAGE content item
--       referred to by this CP_IMAGE must be provided.
--    3. This procedure performs the following steps:
--          1. Create the IMAGE content item if necessary. It will call the bulk-insert
--             procedure for this task. The IMAGE content item is marked as APPROVED
--             upon creation.
--          2. Create the CP_IMAGE content item using the bulk-insert call. This item
--             however is not marked as APPROVED.
--          NOTE that the FUNCTIONAL_TYPE for CP_IMAGE items is NORMAL.
--          3. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created CP_IMAGE item.
--    4. This procedure returns the fact that it is successful.
--       It also returns the citem_id and citem_ver_id for the newly created CP_IMAGE item.
--
-- HISTORY
--    17-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE create_cp_image(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_resource_type         IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2                  DEFAULT FND_API.g_true, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attr_types_cp_image   IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_cp_image  IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_attr_types_image      IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_image     IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_parent_attr_type_code IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_cp_image_citem_id     OUT NUMBER,
   x_cp_image_citem_ver_id OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    update_cp_image
--
-- PURPOSE
--    Update the CP_IMAGE Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be CP_IMAGE.
--       Content Item Id for the CP_IMAGE item.
--       Content Item Name. This is same as the Section Name.
--       Content Item Version Id for the CP_IMAGE item.
--       Deliverable ID.
--       Two Arrays : one with all the attribute type codes for CP_IMAGE.
--                    second with the corresponding values for CP_IMAGE.
--    2. The optional input is as follows:
--       Description.
--       Attachment File Id of the newly uploaded binary file.
--       Attachment File Name for the same.
--       Two Arrays : one with the attribute type codes for IMAGE.
--                    second with the corresponding values for IMAGE.
--          If the above four are available, this procedure will create a Content Item
--          of type IMAGE (the OCM's IMAGE) first and use the content_item_id of
--          this content item for CP_IMAGE.
--       If the above two are unavailable, the content_item_id of the IMAGE content item
--       referred to by this CP_IMAGE must be provided.
--    3. This procedure performs the following steps:
--          1. Create the IMAGE content item if necessary. It will call the bulk-insert
--             procedure for this task. The IMAGE content item is marked as APPROVED
--             upon creation.
--          2. Update the CP_IMAGE content item using the following calls:
--             set_citem_att_bundle (with all the attributes with the changed values).
--          NOTE that the FUNCTIONAL_TYPE for CP_IMAGE items is NORMAL.
--          NOTE that we will not call the following for now:
--             set_citem_meta will not be called as none of the meta items are exposed
--             in the UI for CP_IMAGE.
--             update_citem_basic will not be called as we do not expose Description
--             in the UI and we do not allow the change of the Name.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    19-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_cp_image(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_cp_image_citem_id     IN  NUMBER,
   p_cp_image_citem_ver_id IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_resource_type         IN  VARCHAR2,
   p_attr_types_cp_image   IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_cp_image  IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_description           IN  VARCHAR2,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_attr_types_image      IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_image     IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_commit                IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    update_content_item
--
-- PURPOSE
--    Update a Content Item with a generic content type.
--    The Content Type must be provided.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Item.
--       Content Item Id for Item.
--       Content Item Version Id for the Item.
--       Two Arrays : one with data for changed attribute codes.
--                    second with the corresponding values.
--    2. The optional input is as follows:
--       Content Item Name for the Item.
--       Description.
--       Attachment File Id for the attachment.
--       Attachment File Name for the same.
--    3. This procedure performs the following steps:
--          1. Lock the Content Item.
--          2. Get the existing Attribute data for the content item.
--          3. Set the values of the changed Attributes with the incoming data.
--          4. Set the Attachment File Id if it has been provided as input.
--          NOTE that we will not call the following for now:
--             set_citem_meta will not be called as none of the meta items are exposed
--             in the UI for any of the content items.
--             update_citem_basic will not be called as we do not expose Description
--             in the UI and we do not allow the change of the Name.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    24-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_content_item(
   p_citem_id                 IN  NUMBER,
   p_citem_version_id         IN  NUMBER,
   p_content_type_code        IN  VARCHAR2,
   p_content_item_name        IN  VARCHAR2,
   p_description              IN  VARCHAR2,
   p_delv_id                  IN  NUMBER,
   p_attr_types_for_update    IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_for_update   IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_attach_file_id           IN  NUMBER                    DEFAULT NULL,
   p_attach_file_name         IN  VARCHAR2                  DEFAULT NULL,
   p_commit                   IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version              IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level     IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2,
   p_replace_attr_bundle      IN  VARCHAR2                  DEFAULT FND_API.g_false
);

-----------------------------------------------------------------------
-- PROCEDURE
--    create_display_template
--
-- PURPOSE
--    Create a Content Item of type STYLESHEET.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for which the Stylesheet or Display Template is for.
--       Display Template or Stylesheet Name.
--       Attachment File ID that has the actual Stylesheet or Display Template.
--       Attachment File Name. (This will the one of the uploaded file).
--       Value for DELIVERY_CHANNEL
--       Value for OUTPUT_TYPE
--    2. The optional input is as follows:
--       Stylesheet Description.
--    3. This procedure performs the following steps:
--          1. Create a Content Item of type STYLESHEET using Bulk Insert as an APPROVED item.
--             Set the attribute bundle for the item, with DELIVERY_OPTION and OUTPUT_TYPE.
--          2. Create an entry in IBC_STYLESHEETS table.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Display Template ID.
--
-- HISTORY
--    04-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_display_template(
   p_content_type_code        IN  VARCHAR2,
   p_stylesheet_name          IN  VARCHAR2,
   p_stylesheet_descr         IN  VARCHAR2      DEFAULT NULL,
   p_delivery_channel         IN  VARCHAR2,
   p_output_type              IN  VARCHAR2,
   p_attach_file_id           IN  NUMBER,
   p_attach_file_name         IN  VARCHAR2,
   p_resource_id              IN  NUMBER,
   p_resource_type            IN  VARCHAR2,
   p_commit                   IN  VARCHAR2      DEFAULT FND_API.g_false,
   p_api_version              IN  NUMBER        DEFAULT 1.0,
   p_api_validation_level     IN  NUMBER        DEFAULT FND_API.g_valid_level_full,
   x_citem_id                 OUT NUMBER,
   x_citem_ver_id             OUT NUMBER,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    create_basic_questions_item.
--
-- PURPOSE
--    Create basic content item of type QUESTIONS.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be QUESTIONS.
--       Name of the Questions Section.
--       Owner Resource Id.
--       Resource Type.
--       Content Item Id for the Parent Content Item associated with the parent deliverable.
--       Content Item Version Id for the Parent Content Item.
--       Content Type Code for the Parent Content Item.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Create a basic Content Item of type QUESTIONS using Bulk Insert.
--          2. Create compound relation with the parent.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Content Item Id.
--
-- HISTORY
--    09-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_basic_questions_item(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_start_date            IN  DATE                   DEFAULT SYSDATE,
   p_end_date              IN  DATE                   DEFAULT NULL,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);



-----------------------------------------------------------------------
-- PROCEDURE
--    generate_select_sql.
--
-- PURPOSE
--    Generate select SQL statement, given a data source and list of fields.
--
-- NOTES
--    1. The required input is as follows:
--       Data Source code.
--       VARCHAR2 Array with a list of Data Fields in the form of DATA_SRC_TYPE_CODE:FIELD_COLUMN_NAME.
--    2. The optional input is as follows:
--       NUMBER Array with a list of Data Source Field IDs.
--    3. This procedure performs the following steps:
--          1. Referes to the Data Sources schema to get the details of Data Source fields.
--          2. Generate a Select SQL Statement based on the Data Source and the fields.
--    4. This procedure returns the generated SQL statement and the list of bind variable names.
--
-- HISTORY
--    09-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE generate_select_sql(
   p_data_source_code         IN  VARCHAR2,
   p_data_source_fields_list  IN  JTF_VARCHAR2_TABLE_300       DEFAULT NULL,
   p_data_source_field_ids    IN  JTF_NUMBER_TABLE             DEFAULT NULL,
   x_select_sql_statement     OUT VARCHAR2,
   x_bind_vars                OUT JTF_VARCHAR2_TABLE_300,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    create_submit_section
--
-- PURPOSE
--    Create content item of type SUBMIT_SECTION.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be SUBMIT_SECTION.
--       Name of the Submit Section.
--       Owner Resource Id.
--       Resource Type.
--       Content Item Id for the Parent Content Item associated with the parent deliverable.
--       Content Item Version Id for the Parent Content Item.
--       Content Type Code for the Parent Content Item.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Create a Content Item of type SUBMIT_SECTION using Bulk Insert.
--          2. Create compound relation with the parent.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Content Item Id.
--
-- HISTORY
--    10-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_submit_section(
   p_delv_id               IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_ui_control_type       IN  VARCHAR2               DEFAULT G_DEF_UI_FOR_SUBMIT,
   p_button_label          IN  VARCHAR2,
   p_ocm_image_id          IN  NUMBER                 DEFAULT NULL,
   p_alignment             IN  VARCHAR2               DEFAULT G_DEF_ALIGN_FOR_SUBMIT,
   p_commit                IN  VARCHAR2               DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                 DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                 DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    update_submit_section
--
-- PURPOSE
--    Update content item of type SUBMIT_SECTION.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be SUBMIT_SECTION.
--       Name of the Submit Section.
--       Content Item Id for the section.
--       Content Item Version Id for the section.
--    2. The optional input is as follows:
--       Description.
--       Other data that needs changes.
--    3. This procedure performs the following steps:
--          1. Update a Content Item of type SUBMIT_SECTION.
--    4. This procedure returns the fact that it is successful
--
-- HISTORY
--    11-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE update_submit_section(
   p_delv_id               IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_citem_id              IN  NUMBER,
   p_citem_ver_id          IN  NUMBER,
   p_ui_control_type       IN  VARCHAR2,
   p_button_label          IN  VARCHAR2,
   p_ocm_image_id          IN  NUMBER,
   p_alignment             IN  VARCHAR2,
   p_commit                IN  VARCHAR2               DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                 DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                 DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    erase_blob
--
-- PURPOSE
--    erases blob.
-- HISTORY
--    14-MAY-2002   asaha     Created.
--
-----------------------------------------------------------------------
PROCEDURE erase_blob(
   p_file_id     IN NUMBER,
   x_blob        OUT BLOB,
   p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.g_true,
   x_return_status OUT VARCHAR2,
   x_msg_count     OUT NUMBER,
   x_msg_data      OUT VARCHAR2
);

END AMS_CPageUtility_PVT;

 

/
