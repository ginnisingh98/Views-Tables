--------------------------------------------------------
--  DDL for Package JTF_RS_TEAM_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAM_USAGES_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvjs.pls 120.0 2005/05/11 08:23:05 appldev ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource team usages.
   Its main procedures are as following:
   Create Resource Team Usage
   Delete Resource Team Usage
   Calls to these procedures will invoke calls to table handlers which
   do actual inserts and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  create_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_USAGE_ID        OUT NOCOPY JTF_RS_TEAM_USAGES.TEAM_USAGE_ID%TYPE
  );



  /* Procedure to delete the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  delete_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_USAGES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  );


END jtf_rs_team_usages_pvt;

 

/
