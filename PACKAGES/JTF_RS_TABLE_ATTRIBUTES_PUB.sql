--------------------------------------------------------
--  DDL for Package JTF_RS_TABLE_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TABLE_ATTRIBUTES_PUB" AUTHID CURRENT_USER AS
 /* $Header: jtfrspws.pls 120.0 2005/05/11 08:21:28 appldev ship $ */
/*#
 * Package containing procedures to maintain resource attributes for
 * giving access rights to non-admin user
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Resource Attributes Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 */

  /*****************************************************************************************
   This is a public API that user API will invoke.
   It provides procedures for managing seed data of jtf_rs_table_attributes_b/tl tables
   create, update and delete rows
   Its main procedures are as following:
   Create table attribute
   Update  table attribute
   Delete  table attribute
   Calls to these procedures will call procedures of jtf_rs_table_attributes_pvt
   to do inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the table attribute
	based on input values passed by calling routines. */

/*#
 * Procedure to create resource attribute
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ATTRIBUTE_NAME Attribute Name for the resource attribute
 * @param P_ATTRIBUTE_ACCESS_LEVEL Attribute access level (No Update/Full Update/Update With Approval/Update With Notification)
 * @param P_ATTRIBUTE1 Descriptive flexfield Attribute 1
 * @param P_ATTRIBUTE2 Descriptive flexfield Attribute 2
 * @param P_ATTRIBUTE3 Descriptive flexfield Attribute 3
 * @param P_ATTRIBUTE4 Descriptive flexfield Attribute 4
 * @param P_ATTRIBUTE5 Descriptive flexfield Attribute 5
 * @param P_ATTRIBUTE6 Descriptive flexfield Attribute 6
 * @param P_ATTRIBUTE7 Descriptive flexfield Attribute 7
 * @param P_ATTRIBUTE8 Descriptive flexfield Attribute 8
 * @param P_ATTRIBUTE9 Descriptive flexfield Attribute 9
 * @param P_ATTRIBUTE10 Descriptive flexfield Attribute 10
 * @param P_ATTRIBUTE11	Descriptive flexfield Attribute 11
 * @param P_ATTRIBUTE12	Descriptive flexfield Attribute 12
 * @param P_ATTRIBUTE13	Descriptive flexfield Attribute 13
 * @param P_ATTRIBUTE14	Descriptive flexfield Attribute 14
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 14
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param P_USER_ATTRIBUTE_NAME Name of the attribute for display to user
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_ATTRIBUTE_ID Output parameter containing internal unique id of the created resource attribute
 * @rep:scope private
 * @rep:displayname Create Resource Attribute
 */
  PROCEDURE  create_table_attribute
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ATTRIBUTE_NAME       IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE,
   P_ATTRIBUTE_ACCESS_LEVEL IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   P_USER_ATTRIBUTE_NAME  IN   JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_ATTRIBUTE_ID       OUT NOCOPY JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE
  );


  /* Procedure to update table attribute
	based on input values passed by calling routines. */

/*#
 * Procedure to update resource attribute
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ATTRIBUTE_ID Internal unique id for the resource attribute
 * @param P_ATTRIBUTE_NAME Attribute Name for the resource attribute
 * @param P_ATTRIBUTE_ACCESS_LEVEL Attribute access level (No Update/Full Update/Update With Approval/Update With Notification)
 * @param P_OBJECT_VERSION_NUM Object version number for the record to update
 * @param P_ATTRIBUTE1 Descriptive flexfield Attribute 1
 * @param P_ATTRIBUTE2 Descriptive flexfield Attribute 2
 * @param P_ATTRIBUTE3 Descriptive flexfield Attribute 3
 * @param P_ATTRIBUTE4 Descriptive flexfield Attribute 4
 * @param P_ATTRIBUTE5 Descriptive flexfield Attribute 5
 * @param P_ATTRIBUTE6 Descriptive flexfield Attribute 6
 * @param P_ATTRIBUTE7 Descriptive flexfield Attribute 7
 * @param P_ATTRIBUTE8 Descriptive flexfield Attribute 8
 * @param P_ATTRIBUTE9 Descriptive flexfield Attribute 9
 * @param P_ATTRIBUTE10 Descriptive flexfield Attribute 10
 * @param P_ATTRIBUTE11	Descriptive flexfield Attribute 11
 * @param P_ATTRIBUTE12	Descriptive flexfield Attribute 12
 * @param P_ATTRIBUTE13	Descriptive flexfield Attribute 13
 * @param P_ATTRIBUTE14	Descriptive flexfield Attribute 14
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 14
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param P_USER_ATTRIBUTE_NAME Name of the attribute for display to user
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Update Resource Attribute
 */
  PROCEDURE  update_table_attribute
  (P_API_VERSION         IN     NUMBER,
   P_INIT_MSG_LIST       IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT              IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ATTRIBUTE_ID         IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_ATTRIBUTE_NAME       IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_ACCESS_LEVEL IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_USER_ATTRIBUTE_NAME  IN   JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM  IN OUT NOCOPY JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );


  /* Procedure to delete the table attribute */

/*#
 * Procedure to delete resource attribute
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ATTRIBUTE_ID Internal unique id for the resource attribute
 * @param P_OBJECT_VERSION_NUM Object version number for the record to update
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Delete Resource Attribute
 */
  PROCEDURE  delete_table_attribute
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ATTRIBUTE_ID         IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  );

END jtf_rs_table_attributes_pub;

 

/
