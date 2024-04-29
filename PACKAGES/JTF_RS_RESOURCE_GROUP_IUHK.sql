--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_GROUP_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_GROUP_IUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsngs.pls 120.0 2005/05/11 08:20:47 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create resource group */

  PROCEDURE  create_resource_group_pre
  (P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Internal Industry Procedure for post processing in case of
	create resource group */

  PROCEDURE  create_resource_group_post
  (P_GROUP_ID             IN   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Internal Industry Procedure for pre processing in case of
	update resource group */

  PROCEDURE  update_resource_group_pre
  (P_GROUP_ID             IN   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Internal Industry Procedure for post processing in case of
	update resource group */

  PROCEDURE  update_resource_group_post
  (P_GROUP_ID             IN   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


END jtf_rs_resource_group_iuhk;

 

/
