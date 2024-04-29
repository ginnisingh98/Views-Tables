--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_MEMBER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_MEMBER_CUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrscms.pls 120.0 2005/05/11 08:19:41 appldev ship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Customers can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Customer Procedure for pre processing in case of
	create resource group members */

  PROCEDURE  create_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	create resource group members */

  PROCEDURE  create_group_members_post
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );

  /* Customer Procedure for pre processing in case of
	update resource group members */

  PROCEDURE  update_group_members_pre
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	update resource group members */

  PROCEDURE  update_group_members_post
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );

  /* Customer Procedure for pre processing in case of
	delete resource group members */

  PROCEDURE  delete_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	delete resource group members */

  PROCEDURE  delete_group_members_post
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer/Vertical Industry Function before Message Generation */

  FUNCTION ok_to_generate_msg
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;


END jtf_rs_group_member_cuhk;

 

/
