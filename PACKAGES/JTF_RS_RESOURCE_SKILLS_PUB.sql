--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_SKILLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_SKILLS_PUB" AUTHID CURRENT_USER AS
 /* $Header: jtfrsuks.pls 120.0 2005/05/11 08:22:47 appldev ship $ */
/*#
 * Package containing procedures to maintain resource skills
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Skills Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE_SKILL
 */

  /*****************************************************************************************
   This is a public API that will invoke private api.
   It provides procedures for managing data of JTF_RS_RESOURCE_SKILLS table
   create, update and delete rows
   Its main procedures are as following:
   Create  resource skills
   Update  resource skills
   Delete  resource skills
   Calls to these procedures will invoke procedures of JTF_RS_RESOURCE_SKILLS_PVT
   to do business validations and to do actual inserts, updates and deletes into tables.

   Modification history

   Date		Name		Description
   02-DEC-02   asachan	 	Added two overloaded procedures create_resource_skills and
				update_resource_skills for providing product skill
				cascading capability.(bug#2002193)
   ******************************************************************************************/


  /* Procedure to create the resource skill
	based on input values passed by calling routines. */

/*#
 * Procedure to create a resource skill
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_RESOURCE_ID internal unique id for the resource
 * @param P_SKILL_LEVEL_ID internal unique id for the skill level
 * @param P_CATEGORY_ID internal unique id for item(product) category
 * @param P_SUBCATEGORY subcategory for the product category
 * @param P_PRODUCT_ID internal unique id for product
 * @param P_PRODUCT_ORG_ID Organization id for the product
 * @param P_PLATFORM_ID internal unique id for platform
 * @param P_PLATFORM_ORG_ID Organization id for the platform
 * @param P_PROBLEM_CODE Problem code
 * @param P_COMPONENT_ID Internal unique id for product component
 * @param P_SUBCOMPONENT_ID Internal unique id for product sub-component
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
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 15
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_RESOURCE_SKILL_ID Output parameter containing internal unique id of the created resoure skill
 * @rep:scope internal
 * @rep:displayname Create Resource Skill
 */
  PROCEDURE  create_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE   DEFAULT  NULL,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE    DEFAULT  NULL,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE    DEFAULT  NULL,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE   DEFAULT  NULL,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE   DEFAULT  NULL,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE  DEFAULT  NULL,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE  DEFAULT  NULL,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE DEFAULT  NULL,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_RESOURCE_SKILL_ID    OUT NOCOPY  JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE
  );


  /* Procedure to update resource skill
	based on input values passed by calling routines. */
/*#
 * Procedure to update a resource skill
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_RESOURCE_SKILL_ID internal unique id for resource skill to update
 * @param P_RESOURCE_ID internal unique id for the resource
 * @param P_SKILL_LEVEL_ID internal unique id for the skill level
 * @param P_CATEGORY_ID internal unique id for item(product) category
 * @param P_SUBCATEGORY subcategory for the product category
 * @param P_PRODUCT_ID internal unique id for product
 * @param P_PRODUCT_ORG_ID Organization id for the product
 * @param P_PLATFORM_ID internal unique id for platform
 * @param P_PLATFORM_ORG_ID Organization id for the platform
 * @param P_PROBLEM_CODE Problem code
 * @param P_COMPONENT_ID Internal unique id for product component
 * @param P_SUBCOMPONENT_ID Internal unique id for product sub-component
 * @param P_OBJECT_VERSION_NUM Object version number for this resource skill record
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
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 15
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Skill
 */
  PROCEDURE  update_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_SKILL_ID    IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE     DEFAULT  FND_API.G_MISS_NUM,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE    DEFAULT  FND_API.G_MISS_NUM,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE    DEFAULT  FND_API.G_MISS_NUM,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE DEFAULT  FND_API.G_MISS_NUM,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );


  /* Procedure to delete the resource skill */

/*#
 * Procedure to delete a resource skill
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_RESOURCE_SKILL_ID internal unique id for resource skill to update
 * @param P_OBJECT_VERSION_NUM Object version number for this resource skill record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Skill With Cascade
 */
  PROCEDURE  delete_resource_skills
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_SKILL_ID    IN     JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  );


 /* Procedure to create skill rating with cascading.
   introduced as part of bug#2002193 */
/*#
 * Procedure to create a resource skill and cascade it into products or
 * components as per the P_CASCADE_OPTION parameter
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_RESOURCE_ID internal unique id for the resource
 * @param P_SKILL_LEVEL_ID internal unique id for the skill level
 * @param P_CATEGORY_ID internal unique id for item(product) category
 * @param P_SUBCATEGORY subcategory for the product category
 * @param P_PRODUCT_ID internal unique id for product
 * @param P_PRODUCT_ORG_ID Organization id for the product
 * @param P_PLATFORM_ID internal unique id for platform
 * @param P_PLATFORM_ORG_ID Organization id for the platform
 * @param P_PROBLEM_CODE Problem code
 * @param P_COMPONENT_ID Internal unique id for product component
 * @param P_SUBCOMPONENT_ID Internal unique id for product sub-component
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
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 15
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param X_RETURN_STATUS Output parameter for return status
 * @param P_CASCADE_OPTION Option to indicate if cascade ? if yes, then into products or components
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_RESOURCE_SKILL_ID Output parameter containing internal unique id of the created resoure skill
 * @rep:scope internal
 * @rep:displayname Create Resource Skill With Cascade
 */
  PROCEDURE  create_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE   DEFAULT  NULL,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE   DEFAULT  NULL,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE    DEFAULT  NULL,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE    DEFAULT  NULL,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE   DEFAULT  NULL,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE   DEFAULT  NULL,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE  DEFAULT  NULL,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE  DEFAULT  NULL,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE DEFAULT  NULL,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   P_CASCADE_OPTION       IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_RESOURCE_SKILL_ID    OUT NOCOPY  JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE
  );


 /* Procedure to update skill rating with cascading.
   introduced as part of bug#2002193 */
/*#
 * Procedure to update a resource skill  and cascade it into products or
 * components as per the P_CASCADE_OPTION parameter
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_RESOURCE_SKILL_ID internal unique id for resource skill to update
 * @param P_RESOURCE_ID internal unique id for the resource
 * @param P_SKILL_LEVEL_ID internal unique id for the skill level
 * @param P_CATEGORY_ID internal unique id for item(product) category
 * @param P_SUBCATEGORY subcategory for the product category
 * @param P_PRODUCT_ID internal unique id for product
 * @param P_PRODUCT_ORG_ID Organization id for the product
 * @param P_PLATFORM_ID internal unique id for platform
 * @param P_PLATFORM_ORG_ID Organization id for the platform
 * @param P_PROBLEM_CODE Problem code
 * @param P_COMPONENT_ID Internal unique id for product component
 * @param P_SUBCOMPONENT_ID Internal unique id for product sub-component
 * @param P_OBJECT_VERSION_NUM Object version number for this resource skill record
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
 * @param P_ATTRIBUTE15	Descriptive flexfield Attribute 15
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield attribute category
 * @param P_CASCADE_OPTION Option to indicate if cascade ? if yes, then into products or components
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Skill With Cascade
 */
  PROCEDURE  update_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_SKILL_ID    IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE     DEFAULT  FND_API.G_MISS_NUM,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE    DEFAULT  FND_API.G_MISS_NUM,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE    DEFAULT  FND_API.G_MISS_NUM,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE  DEFAULT  FND_API.G_MISS_NUM,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE DEFAULT  FND_API.G_MISS_NUM,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_CASCADE_OPTION       IN   NUMBER,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );

END JTF_RS_RESOURCE_SKILLS_PUB;

 

/
