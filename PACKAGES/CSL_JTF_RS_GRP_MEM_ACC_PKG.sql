--------------------------------------------------------
--  DDL for Package CSL_JTF_RS_GRP_MEM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_RS_GRP_MEM_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csljgacs.pls 115.6 2002/11/08 14:02:30 asiegers ship $ */

/*** Function that checks if group member should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
( p_group_member_id NUMBER
)
RETURN BOOLEAN;

/*** Called after Group member Insert ***/
PROCEDURE  POST_INSERT_RS_GROUP_MEMBER
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );

/* Called after Group member delete */
PROCEDURE PRE_DELETE_RS_GROUP_MEMBER
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );

/* Full synch for a mobile user */
PROCEDURE Insert_All_ACC_Records
  ( p_resource_id IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );

/* Remove all ACC records of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );

END CSL_JTF_RS_GRP_MEM_ACC_PKG;

 

/
