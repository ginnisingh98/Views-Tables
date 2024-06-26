--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_MEMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_MEMBERS_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvms.pls 120.0 2005/05/11 08:23:09 appldev ship $ */

  /*****************************************************************************************
   This is a private API that caller will invoke.
   It provides procedures for managing resource group members, like
   create and delete resource group members.
   Its main procedures are as following:
   Create Resource Group Members
   Delete Resource Group Members
   Calls to these procedures will invoke calls to table handlers which
   do actual inserts and deletes into tables.
   ******************************************************************************************/

  /* Global vraiable to indicate that the member is being moved from one group
     to another as well as the old group id. This will be used for the insert  in
     of group member audit api for an insert of a new member. In this case the old_group_id
    will be assigned this variable value which will be initialized when a member is moved */

  G_MOVED_FR_GROUP_ID       JTF_RS_GROUPS_B.GROUP_ID%TYPE DEFAULT NULL;


 /*Procedure to assign value to the global variable */
 PROCEDURE  assign_value_to_global
  (P_API_VERSION  IN NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
 );

  /* Procedure to create the resource group members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_MEMBER_ID      OUT NOCOPY JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE
  );

  /* Procedure to update the resource group members. */

  PROCEDURE  update_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_PERSON_ID            IN   JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_DELETE_FLAG          IN   JTF_RS_GROUP_MEMBERS.DELETE_FLAG%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE1%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE2%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE3%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE4%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE5%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE6%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE7%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE8%TYPE   DEFAULT   FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE9%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE10%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE11%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE12%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE13%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE14%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE15%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUMBER   IN OUT NOCOPY  JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


  /* Procedure to delete the resource group members. */

  PROCEDURE  delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  );

  /* Procedure to move member hook  */

  PROCEDURE  execute_sales_hook
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_OLD_GROUP_ID         IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_NEW_GROUP_ID         IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_OLD_START_DATE       IN   DATE,
   P_OLD_END_DATE         IN   DATE,
   P_NEW_START_DATE       IN   DATE,
   P_NEW_END_DATE         IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );
END jtf_rs_group_members_pvt;

 

/
