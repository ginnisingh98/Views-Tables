--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBER_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBER_IUHK" AS
  /* $Header: jtfrsnmb.pls 120.0 2005/05/11 08:20:51 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create resource group members */

  PROCEDURE  create_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	create resource group members */

  PROCEDURE  create_group_members_post
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for pre processing in case of
	update resource group members */

  PROCEDURE  update_group_members_pre
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN

    null;

  END;




  /* Internal Industry Procedure for post processing in case of
	update resource group members */

  PROCEDURE  update_group_members_post
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN

    null;

  END;


  /* Internal Industry Procedure for pre processing in case of
	delete resource group members */

  PROCEDURE  delete_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	delete resource group members */

  PROCEDURE  delete_group_members_post
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    null;

  END;

END jtf_rs_group_member_iuhk;

/
