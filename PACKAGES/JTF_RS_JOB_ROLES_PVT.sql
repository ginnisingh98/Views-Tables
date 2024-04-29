--------------------------------------------------------
--  DDL for Package JTF_RS_JOB_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_JOB_ROLES_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvns.pls 120.0 2005/05/11 08:23:10 appldev ship $ */

  /*****************************************************************************************
   This is a private API that caller will invoke.
   It provides procedures for managing resource job roles, like
   create and delete resource job roles.
   Its main procedures are as following:
   Create Resource Job Roles
   Delete Resource Job Roles
   Calls to these procedures will invoke calls to table handlers which
   do actual inserts and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource job roles
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_job_roles
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_JOB_ID               IN   JTF_RS_JOB_ROLES.JOB_ID%TYPE,
   P_ROLE_ID              IN   JTF_RS_JOB_ROLES.ROLE_ID%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_JOB_ROLES.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2           IN   JTF_RS_JOB_ROLES.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3           IN   JTF_RS_JOB_ROLES.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4           IN   JTF_RS_JOB_ROLES.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5           IN   JTF_RS_JOB_ROLES.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6           IN   JTF_RS_JOB_ROLES.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7           IN   JTF_RS_JOB_ROLES.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8           IN   JTF_RS_JOB_ROLES.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9           IN   JTF_RS_JOB_ROLES.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10          IN   JTF_RS_JOB_ROLES.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11          IN   JTF_RS_JOB_ROLES.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12          IN   JTF_RS_JOB_ROLES.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13          IN   JTF_RS_JOB_ROLES.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14          IN   JTF_RS_JOB_ROLES.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15          IN   JTF_RS_JOB_ROLES.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_JOB_ROLES.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_JOB_ROLE_ID          OUT NOCOPY JTF_RS_JOB_ROLES.JOB_ROLE_ID%TYPE
  );



  /* Procedure to delete the resource job roles. */

  PROCEDURE  delete_resource_job_roles
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_JOB_ROLE_ID          IN   JTF_RS_JOB_ROLES.JOB_ROLE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_JOB_ROLES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  );


END jtf_rs_job_roles_pvt;

 

/
