--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_ORGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_ORGS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsuos.pls 120.0 2005/05/11 08:22:50 appldev noship $ */
/*#
 * API to create, update and delete Resource Group to HR Org mapping
 * This API contains the procedures to insert, update and delete Resource Group
 * to HR Org mapping record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Group to HR Organization Mapping API
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP_HR_ORG_MAPPING
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing Resource Group to HR Org mapping, like
   create, update and delete from other modules.
   Its main procedures are as following:
   Create Resource Group to HR Org mapping
   Update Resource Group to HR Org mapping
   Delete Resource Group to HR Org mapping
   Calls to these procedures will invoke procedures from jtf_rs_group_orgs_pvt
   to do business validations and to do actual inserts, updates and deletes into
   tables.
   ******************************************************************************************/


  /* Procedure to create the Resource Group to HR Org mapping
	based on input values passed by calling routines. */
/*#
 * Create Resource Group to HR Org mapping API
 * This procedure allows the user to create a Resource Group to HR Org mapping record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_organization_id HR Organization Identifier
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Resource Group to HR Org mapping API
*/
  PROCEDURE  create_group_org
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID              IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID       IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_ATTRIBUTE1            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE1%TYPE DEFAULT NULL,
   P_ATTRIBUTE2            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE2%TYPE DEFAULT NULL,
   P_ATTRIBUTE3            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE3%TYPE DEFAULT NULL,
   P_ATTRIBUTE4            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE4%TYPE DEFAULT NULL,
   P_ATTRIBUTE5            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE5%TYPE DEFAULT NULL,
   P_ATTRIBUTE6            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE6%TYPE DEFAULT NULL,
   P_ATTRIBUTE7            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE7%TYPE DEFAULT NULL,
   P_ATTRIBUTE8            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE8%TYPE DEFAULT NULL,
   P_ATTRIBUTE9            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE9%TYPE DEFAULT NULL,
   P_ATTRIBUTE10           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE10%TYPE DEFAULT NULL,
   P_ATTRIBUTE11           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE11%TYPE DEFAULT NULL,
   P_ATTRIBUTE12           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE12%TYPE DEFAULT NULL,
   P_ATTRIBUTE13           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE13%TYPE DEFAULT NULL,
   P_ATTRIBUTE14           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE14%TYPE DEFAULT NULL,
   P_ATTRIBUTE15           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE15%TYPE DEFAULT NULL,
   P_ATTRIBUTE_CATEGORY    IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
   X_RETURN_STATUS         OUT NOCOPY  	VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY  	NUMBER,
   X_MSG_DATA              OUT NOCOPY  	VARCHAR2
  ) ;


  /* Procedure to update the Resource Group to HR Org mapping Attributes
	based on input values passed by calling routines. */

/*#
 * Update Resource Group to HR Org mapping Attributes API
 * This procedure allows the user to update a Resource Group to HR Org mapping Attributes of a record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_organization_id HR Organization Identifier
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param p_object_version_number The object version number of the group-org mapping derived from the jtf_rs_group_organizations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Group to HR Org mapping attributes API
*/
  PROCEDURE  update_group_org
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID              IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID       IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_ATTRIBUTE1            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE1%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE2%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE3%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE4%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE5%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE6%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE7%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE8%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE9%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE10%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE11%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE12%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE13%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE14%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE15%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY    IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE_CATEGORY%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS         OUT NOCOPY  		VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY  		NUMBER,
   X_MSG_DATA              OUT NOCOPY  		VARCHAR2
  );

  /* Procedure to delete resource group - HR Org mapping  */

/*#
 * Delete Resource Group to HR Org mapping API
 * This procedure allows the user to delete a Resource Group to HR Org mapping record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_organization_id HR Organization Identifier
 * @param p_object_version_number The object version number of the group-org mapping derived from the jtf_rs_group_organizations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Resource Group to HR Org mapping API
*/

  PROCEDURE  delete_group_org
  (P_API_VERSION            IN  NUMBER,
   P_INIT_MSG_LIST          IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
   P_COMMIT                 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID               IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID        IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_OBJECT_VERSION_NUMBER  IN  JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT              OUT NOCOPY  NUMBER,
   X_MSG_DATA               OUT NOCOPY  VARCHAR2
  );

END JTF_RS_GROUP_ORGS_PUB;

 

/
