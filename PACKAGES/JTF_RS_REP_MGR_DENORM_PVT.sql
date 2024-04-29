--------------------------------------------------------
--  DDL for Package JTF_RS_REP_MGR_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_REP_MGR_DENORM_PVT" AUTHID CURRENT_USER AS
 /* $Header: jtfrsvps.pls 120.0 2005/05/11 08:23:13 appldev ship $ */

-- API Name	: JTF_RS_REP_MGR_DENORM_PVT
-- Type		: Private
-- Purpose	: Inserts/Update the JTF_RS_REPORTING_MANAGERS table based on changes in jtf_rs_role_relations,
--                jtf_rs_grp_relations
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 7 Oct 1999    S Choudhury   Created
-- Notes:
--

   /*FOR INSERT IN JTF_RS_ROLE_RELATIONS */
   --SHOULD BE CALLED AFTER THE ROLE RELATE ROW HAS BEEN INSERTED
   PROCEDURE   INSERT_REP_MANAGER(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_COMMIT          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 );

   /*FOR INSERT IN JTF_RS_ROLE_RELATIONS */
   --SHOULD BE CALLED from the api jtf_rs_groups_denorm.delete_resource_group_relate
   -- not being used anymore
   PROCEDURE   INSERT_REP_MGR_PARENT(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_COMMIT          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 );


  --SHOULD BE CALLED AFTER THE ROLE RELATE ROW HAS BEEN INSERTED --only for migration
   PROCEDURE   INSERT_REP_MANAGER_MIGR(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_COMMIT          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 );



 --FOR UPDATE on jtf_rs_ROLE_RELATE
 --SHOULD BE CALLED AFTER THE TABLE HAS BEEN UPDATED
   PROCEDURE   UPDATE_REP_MANAGER(
             P_API_VERSION       IN  NUMBER,
             P_INIT_MSG_LIST     IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_COMMIT            IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_ROLE_RELATE_ID    IN  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
             X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
             X_MSG_COUNT         OUT NOCOPY NUMBER,
             X_MSG_DATA          OUT NOCOPY VARCHAR2 );

   -- FOR DELETE ON JTF_RS_ROLE_RELATE
   PROCEDURE   DELETE_MEMBERS(
   P_API_VERSION     IN  NUMBER,
             P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
             X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
             X_MSG_COUNT       OUT NOCOPY NUMBER,
             X_MSG_DATA        OUT NOCOPY VARCHAR2  );

  /*FOR INSERT IN JTF_RS_GRP_RELATIONS */
  --AFTER THE GROUP RELATION ROW HAS BEEN INSERTED
  -- may not be used after 23-apr-2001
  PROCEDURE   INSERT_GRP_RELATIONS(
                    P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_COMMIT          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_GROUP_RELATE_ID IN     JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 );

  --when a insert is done in groups denorm
  PROCEDURE   INSERT_GRP_DENORM(
                   P_API_VERSION          IN     NUMBER,
                   P_INIT_MSG_LIST         IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_COMMIT                IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                   P_GROUP_DENORM_ID       IN     NUMBER,
                   P_GROUP_ID              IN     NUMBER,
                   P_PARENT_GROUP_ID       IN     NUMBER,
                   P_START_DATE_ACTIVE     IN     DATE,
                   P_END_DATE_ACTIVE       IN     DATE,
                   P_IMMEDIATE_PARENT_FLAG IN     VARCHAR2,
                   P_DENORM_LEVEL          IN     NUMBER DEFAULT NULL,
                   X_RETURN_STATUS         OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT             OUT NOCOPY    NUMBER,
                   X_MSG_DATA              OUT NOCOPY    VARCHAR2 );

  -- FOR DELETE ON JTF_RS_GROUPS_DENORM
  -- SHOULD BE CALLED BEFORE THE DENORM RECORD IS ACTUALLY DELETED FROM THE TABLE
 -- being used after 23 apr 2004
   PROCEDURE   DELETE_GROUP_DENORM(
             P_API_VERSION     IN  NUMBER,
             P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
             P_DENORM_GRP_ID   IN  JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE,
             X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
             X_MSG_COUNT       OUT NOCOPY NUMBER,
             X_MSG_DATA        OUT NOCOPY VARCHAR2  );

  --to be called from jtf_rs_groups_denorm_pvt.update_groups
  PROCEDURE  DELETE_REP_MGR  (
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_GROUP_ID        IN  JTF_RS_GROUPS_DENORM.GROUP_ID%TYPE,
              P_PARENT_GROUP_ID IN  JTF_RS_GROUPS_DENORM.PARENT_GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2);

END JTF_RS_REP_MGR_DENORM_PVT;

 

/
