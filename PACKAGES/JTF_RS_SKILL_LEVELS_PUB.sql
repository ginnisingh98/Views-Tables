--------------------------------------------------------
--  DDL for Package JTF_RS_SKILL_LEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SKILL_LEVELS_PUB" AUTHID CURRENT_USER AS
 /* $Header: jtfrsuss.pls 120.0 2005/05/11 08:22:51 appldev ship $ */
/*#
 * Package containing procedures to maintain skill levels
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Skill Level Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE_SKILL_LEVEL
 */


  /*****************************************************************************************
   This is a public API that user API will invoke.
   It provides PROCEDUREs for managing seed data of jtf_rs_skill_levels_vl view
   create, update and delete rows
   Its main PROCEDUREs are as following:
   Create skills
   Update skills
   Delete skills
   Calls to these PROCEDUREs will call PROCEDUREs of jtf_rs_skill_levels_pvt
   to do inserts, updates and deletes into tables.
   ******************************************************************************************/


/* PROCEDURE to create the skill levels
   based on input values passed by calling routines. */

/*#
 * Procedure to create a skill level
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_SKILL_LEVEL Skill level indicator (an integer)
 * @param P_LEVEL_NAME Name of the skill level
 * @param P_LEVEL_DESC Description of the skill level
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
 * @param X_SKILL_LEVEL_ID Output parameter containing internal unique id of the created skill level
 * @rep:scope internal
 * @rep:displayname Create Skill Level
 */
PROCEDURE  create_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SKILL_LEVEL       IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL%TYPE,
   P_LEVEL_NAME          IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_NAME%TYPE,
   P_LEVEL_DESC           IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_DESC%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE1		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_SKILL_LEVEL_ID      OUT NOCOPY JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE
  );

 /* PROCEDURE to update skill levels
	based on input values passed by calling routines. */

/*#
 * Procedure to create a skill level
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_SKILL_LEVEL_ID Internal unique id of the skill level to update
 * @param P_SKILL_LEVEL Skill level indicator (an integer)
 * @param P_LEVEL_NAME Name of the skill level
 * @param P_LEVEL_DESC Description of the skill level
 * @param P_OBJECT_VERSION_NUM Object version number of the record to be updated
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
 * @rep:displayname Update Skill Level
 */
PROCEDURE  update_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SKILL_LEVEL_ID      IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE,
   P_SKILL_LEVEL          IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_LEVEL_NAME       IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_NAME%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_LEVEL_DESC          IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_DESC%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_SKILL_LEVELS_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,

   P_ATTRIBUTE2		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );

/* PROCEDURE to delete the skill levels */

/*#
 * Procedure to delete a skill level
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_SKILL_LEVEL_ID Internal unique id of the skill level to update
 * @param P_OBJECT_VERSION_NUM Object version number of the record to be updated
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Skill Level
 */
PROCEDURE  delete_skills
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SKILL_LEVEL_ID             IN     JTF_RS_SKILL_LEVELS_B.skill_level_id%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_SKILL_LEVELS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  );

END JTF_RS_SKILL_LEVELS_PUB;

 

/
