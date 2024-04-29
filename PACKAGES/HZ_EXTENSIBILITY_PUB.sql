--------------------------------------------------------
--  DDL for Package HZ_EXTENSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTENSIBILITY_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHEXTSS.pls 120.1 2006/10/05 19:00:41 nsinghai noship $ */
/*#
 * Contains the public APIs to create and update extensions.
 * Extensions involve extended, custom attributes for specific entities, for example
 * organization and person profiles.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Extensions
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Extensions APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

   G_FILE_NAME               CONSTANT  VARCHAR2(12) :=  'ARHEXTSS.pls';

   G_RET_STS_SUCCESS         CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
   G_RET_STS_ERROR           CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
   G_RET_STS_UNEXP_ERROR     CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

   G_MISS_NUM                CONSTANT  NUMBER       :=  9.99E125;
   G_MISS_CHAR               CONSTANT  VARCHAR2(1)  :=  CHR(0);
   G_MISS_DATE               CONSTANT  DATE         :=  TO_DATE('1','j');
   G_FALSE                   CONSTANT  VARCHAR2(1)  :=  FND_API.G_FALSE; -- 'F'
   G_TRUE                    CONSTANT  VARCHAR2(1)  :=  FND_API.G_TRUE;  -- 'T'

/*#
 * Creates or updates information in extensions tables for organization profiles.
 * The HZ_ORG_PROFILES_EXT_B and HZ_ORG_PROFILES_EXT_TL tables hold extended, custom
 * attributes about organizations. Use this API to maintain records in these tables
 * for a given organization.
 * @rep:scope public
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:lifecycle active
 * @rep:displayname Create or Update Organization Profile Extension
 * @rep:doccd 120hztig.pdf Extensions APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE Process_Organization_Record (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
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
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

/*#
 * Creates or updates information in extensions tables for person profiles.
 * The HZ_PER_PROFILES_EXT_B and HZ_PER_PROFILES_EXT_TL tables hold extended, custom attributes
 * about persons. Use this API to maintain records in these tables for a given person.
 * @rep:scope public
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:lifecycle active
 * @rep:displayname Create or Update Person Profile Extension
 * @rep:doccd 120hztig.pdf Extensions APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE Process_Person_Record (
        p_api_version                   IN   NUMBER
       ,p_person_profile_id             IN   NUMBER
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
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

/*#
 * Creates or updates information in extensions tables for locations.
 * The HZ_LOCATIONS_EXT_B and HZ_LOCATIONS_EXT_TL tables hold extended, custom attributes about
 * locations. Use this API to maintain records in these tables for a given location.
 * @rep:scope public
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:displayname Create or Update Location Extension
 * @rep:doccd 120hztig.pdf Extensions APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE Process_Location_Record (
        p_api_version                   IN   NUMBER
       ,p_location_id                   IN   NUMBER
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
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

 /*#
  * Creates or updates information in extensions tables for party sites.
  * The HZ_PARTY_SITES_EXT_B and HZ_PARTY_SITES_EXT_TL tables hold extended, custom attributes
  * about party sites. Use this API to maintain records in these tables for a given party site.
  * @rep:scope public
  * @rep:category BUSINESS_ENTITY HZ_ADDRESS
  * @rep:lifecycle active
  * @rep:displayname Create or Update Party Site Extension
  * @rep:doccd 120hztig.pdf Extensions APIs, Oracle Trading Community Architecture Technical Implementation Guide
  */

  PROCEDURE Process_PartySite_Record (
        p_api_version                   IN   NUMBER
       ,p_party_site_id                 IN   NUMBER
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
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
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
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

END HZ_EXTENSIBILITY_PUB;

 

/
