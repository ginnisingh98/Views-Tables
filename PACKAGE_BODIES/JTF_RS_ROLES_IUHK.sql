--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLES_IUHK" AS
  /* $Header: jtfrsnob.pls 120.0 2005/05/11 08:20:53 appldev ship $ */

  /*****************************************************************************************
   This is the Internal User Hook API.
   The Internal Groups can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

   /* Internal Procedure for pre processing in case of create resource roles */

   PROCEDURE  create_rs_resource_roles_pre (
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      X_RETURN_STATUS		OUT NOCOPY 	VARCHAR2,
      X_MSG_COUNT          	OUT NOCOPY    NUMBER,
      X_MSG_DATA           	OUT NOCOPY    VARCHAR2
   ) IS

   BEGIN
      NULL;
   END create_rs_resource_roles_pre;


  /* Internal Procedure for post processing in case of create resource roles */

   PROCEDURE  create_rs_resource_roles_post (
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      X_RETURN_STATUS      	OUT NOCOPY    VARCHAR2,
      X_MSG_COUNT      		OUT NOCOPY    NUMBER,
      X_MSG_DATA         	OUT NOCOPY    VARCHAR2
   ) IS

   BEGIN
      NULL;
   END create_rs_resource_roles_post;

   /* Internal Procedure for pre processing in case of update resource roles */

   PROCEDURE  update_rs_resource_roles_pre (
      P_ROLE_ID          	IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      X_RETURN_STATUS      	OUT NOCOPY    VARCHAR2,
      X_MSG_COUNT          	OUT NOCOPY    NUMBER,
      X_MSG_DATA           	OUT NOCOPY    VARCHAR2
   ) IS

   BEGIN
      NULL;
   END update_rs_resource_roles_pre;

   /* Internal Procedure for post processing in case of update resource roles */

   PROCEDURE  update_rs_resource_roles_post (
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      X_RETURN_STATUS           OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY     NUMBER,
      X_MSG_DATA                OUT NOCOPY     VARCHAR2
   ) IS

   BEGIN
      NULL;
   END update_rs_resource_roles_post;

   /* Internal Procedure for pre processing in case of delete resource roles */

   PROCEDURE  delete_rs_resource_roles_pre (
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      X_RETURN_STATUS           OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY     NUMBER,
      X_MSG_DATA                OUT NOCOPY     VARCHAR2
   ) IS

   BEGIN
      NULL;
   END delete_rs_resource_roles_pre;

   /* Internal Procedure for post processing in case of delete resource roles */

   PROCEDURE  delete_rs_resource_roles_post (
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      X_RETURN_STATUS           OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY     NUMBER,
      X_MSG_DATA                OUT NOCOPY     VARCHAR2
   ) IS

   BEGIN
      NULL;
   END delete_rs_resource_roles_post;

END jtf_rs_roles_iuhk;

/