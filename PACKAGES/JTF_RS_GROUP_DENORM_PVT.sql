--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_DENORM_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvds.pls 120.0 2005/05/11 08:22:55 appldev ship $ */
-- API Name	: JTF_RS_GROUP_DENORM_PVT
-- Type		: Private
-- Purpose	: Inserts/Update the JTF_RS_GROUP_DENORM_PVT table based on changes in jtf_rs_grp_relations
-- Modification History
-- DATE		 NAME	       PURPOSE
--              S Choudhury   Created
-- Notes:
--
  -- This is an internal use function which is used by JTF_RS_GROUP_DENORM_PVT
  -- and sql/jtfrsbgd.sql(concurrent program to populate groups denorm)
  -- and not a public function. It gives direct parent ID(ACTUAL_PARENT_ID)
  -- for a given groups_drnorm table record, originally requested for
  -- DBI perf. enhancement # 2759986
  FUNCTION getDirectParent(p_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                           p_level JTF_RS_GROUPS_DENORM.DENORM_LEVEL%type,
                           p_parent_group_id JTF_RS_GROUPS_DENORM.parent_group_id%type,
	                   p_start_date JTF_RS_GROUPS_DENORM.start_date_active%TYPE,
                           p_end_date JTF_RS_GROUPS_DENORM.end_date_active%TYPE) RETURN NUMBER;

   --to be called when a group is created
   PROCEDURE  CREATE_RES_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );


   --to be called when a group record is updated
   PROCEDURE  UPDATE_RES_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );



  /*FOR INSERT IN GRP_RELATIONS */


  PROCEDURE  INSERT_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );


  /*FOR INSERT OF PARENTS ONLY FOR A GROUP and is being called from
          JTF_RS_GROUP_DENORM_PVT.DELETE_GRP_RELATIONS */

  PROCEDURE  INSERT_GROUPS_PARENT(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              P_COMMIT          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );



   --FOR UPDATE in grp relations

   PROCEDURE   UPDATE_GROUPS(
               P_API_VERSION    IN   NUMBER,
               P_INIT_MSG_LIST	IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
               P_COMMIT		IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
               p_group_id       IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
               X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
               X_MSG_COUNT      OUT NOCOPY  NUMBER,
               X_MSG_DATA       OUT NOCOPY  VARCHAR2 );



    --FOR delete in grp relations ... perf tuned

    PROCEDURE   DELETE_GRP_RELATIONS(
                P_API_VERSION       IN  NUMBER,
                P_INIT_MSG_LIST	    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
	        P_COMMIT            IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_group_relate_id    IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_group_id           IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_related_group_id   IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2);


  --FOR DELETE   this is not being used after apr 24, 2001

    PROCEDURE   DELETE_GROUPS(
                P_API_VERSION     IN  NUMBER,
                P_INIT_MSG_LIST	  IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
	        P_COMMIT           IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_group_id        IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2);

END JTF_RS_GROUP_DENORM_PVT;

 

/
