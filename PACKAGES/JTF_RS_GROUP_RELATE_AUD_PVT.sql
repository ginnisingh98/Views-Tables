--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_RELATE_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_RELATE_AUD_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsafs.pls 120.0 2005/05/11 08:19:05 appldev ship $ */
-- API Name	: JTF_RS_GROUP_RELATE_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RS_GROUP_RELATE_AUD
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 20 JAN 2000    S Choudhury   Created
-- Notes:
--


   /*FOR INSERT  */
   PROCEDURE   INSERT_GROUP_RELATE(
    P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_COMMIT	            IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_GROUP_RELATE_ID       IN  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID %TYPE,
    P_GROUP_ID              IN  JTF_RS_GRP_RELATIONS.GROUP_ID %TYPE,
    P_RELATED_GROUP_ID      IN  JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
    P_RELATION_TYPE          IN  JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
    P_START_DATE_ACTIVE     IN  JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
    P_END_DATE_ACTIVE       IN  JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
    P_OBJECT_VERSION_NUMBER IN  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2 );


   /*FOR UPDATE */
   PROCEDURE   UPDATE_GROUP_RELATE(
  P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_COMMIT	            IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_GROUP_RELATE_ID       IN  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID %TYPE,
    P_GROUP_ID              IN  JTF_RS_GRP_RELATIONS.GROUP_ID %TYPE,
    P_RELATED_GROUP_ID      IN  JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
    P_RELATION_TYPE          IN  JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
    P_START_DATE_ACTIVE     IN  JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
    P_END_DATE_ACTIVE       IN  JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
    P_OBJECT_VERSION_NUMBER IN  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2);


   --FOR DELETE

   PROCEDURE   DELETE_GROUP_RELATE(
    P_API_VERSION	IN  NUMBER,
    P_INIT_MSG_LIST	IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_COMMIT		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_GROUP_RELATE_ID    IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 );


END; -- Package Specification JTF_RS_GROUP_RELATE_AUD_PVT

 

/