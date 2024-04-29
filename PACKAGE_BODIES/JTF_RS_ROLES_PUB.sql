--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLES_PUB" AS
  /* $Header: jtfrspob.pls 120.0 2005/05/11 08:21:18 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource Roles, like
   create, update and delete resource Roles.
   Its main procedures are as following:
   Create Resource Roles
   Update Resource Roles
   Delete Resource Roles
   This package valoidates the input parameters to these procedures and then
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

   --Package variables.

      G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_ROLES_PUB';

   --Procedure to create the resource roles based on input values passed by calling routines

   PROCEDURE  create_rs_resource_roles (
      P_API_VERSION     IN      NUMBER,
      P_INIT_MSG_LIST   IN      VARCHAR2                                DEFAULT  FND_API.G_FALSE,
      P_COMMIT          IN      VARCHAR2                                DEFAULT  FND_API.G_FALSE,
      P_ROLE_TYPE_CODE  IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE       IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME       IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC       IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE          DEFAULT  NULL,
      P_ACTIVE_FLAG     IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE         DEFAULT  'Y',
      P_SEEDED_FLAG     IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE         DEFAULT  'N',
      P_MEMBER_FLAG     IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE         DEFAULT 'N',
      P_ADMIN_FLAG      IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE          DEFAULT 'N',
      P_LEAD_FLAG       IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE           DEFAULT 'N',
      P_MANAGER_FLAG    IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE        DEFAULT 'N',
      X_RETURN_STATUS   OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT       OUT NOCOPY     NUMBER,
      X_MSG_DATA        OUT NOCOPY     VARCHAR2,
      X_ROLE_ID         OUT NOCOPY     JTF_RS_ROLES_B.ROLE_ID%TYPE
   )
   IS

   l_api_version                CONSTANT NUMBER := 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) 		:= 'CREATE_RS_RESOURCE_ROLES';
   l_role_type_code		jtf_rs_roles_vl.role_type_code%type	:= p_role_type_code;
   l_role_code			jtf_rs_roles_vl.role_code%type		:= p_role_code;
   l_role_name                  jtf_rs_roles_vl.role_name%type          := p_role_name;
   l_role_desc			jtf_rs_roles_vl.role_desc%type		:= p_role_desc;
   l_active_flag		jtf_rs_roles_vl.active_flag%type	:= p_active_flag;
   l_seeded_flag                jtf_rs_roles_vl.seeded_flag%type        := p_seeded_flag;
   l_member_flag                jtf_rs_roles_vl.member_flag%type        := p_member_flag;
   l_admin_flag                 jtf_rs_roles_vl.admin_flag%type		:= p_admin_flag;
   l_lead_flag                  jtf_rs_roles_vl.lead_flag%type		:= p_lead_flag;
   l_manager_flag               jtf_rs_roles_vl.manager_flag%type	:= p_manager_flag;

   BEGIN

      SAVEPOINT create_rs_resource_roles_pub;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Create RS Resource Roles Pub ');

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   --Put in all the Validations here

   --Call the Create Resource Role Private API

      jtf_rs_roles_pvt.create_rs_resource_roles (
         P_API_VERSION 		=> 1,
         P_INIT_MSG_LIST 	=> fnd_api.g_false,
         P_COMMIT 		=> fnd_api.g_false,
         P_ROLE_TYPE_CODE	=> l_role_type_code,
         P_ROLE_CODE		=> l_role_code,
         P_ROLE_NAME		=> l_role_name,
         P_ROLE_DESC		=> l_role_desc,
         P_ACTIVE_FLAG		=> l_active_flag,
         P_SEEDED_FLAG          => l_seeded_flag,
         P_MEMBER_FLAG		=> l_member_flag,
         P_ADMIN_FLAG		=> l_admin_flag,
         P_LEAD_FLAG		=> l_lead_flag,
         P_MANAGER_FLAG		=> l_manager_flag,
         X_RETURN_STATUS	=> x_return_status,
         X_MSG_COUNT		=> x_msg_count,
         X_MSG_DATA		=> x_msg_data,
         X_ROLE_ID		=> x_role_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to private procedure');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO create_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Role Pub ============= ');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO create_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END create_rs_resource_roles;

   --Procedure to update the resource Roles based on input values passed by calling routines

   PROCEDURE  update_rs_resource_roles (
      P_API_VERSION             IN      NUMBER,
      P_INIT_MSG_LIST           IN      VARCHAR2                                DEFAULT FND_API.G_FALSE,
      P_COMMIT                  IN      VARCHAR2                                DEFAULT FND_API.G_FALSE,
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE      DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE           DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE          DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE          DEFAULT FND_API.G_MISS_CHAR,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE         DEFAULT FND_API.G_MISS_CHAR,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE         DEFAULT FND_API.G_MISS_CHAR,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE         DEFAULT FND_API.G_MISS_CHAR,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE          DEFAULT FND_API.G_MISS_CHAR,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE           DEFAULT FND_API.G_MISS_CHAR,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE        DEFAULT FND_API.G_MISS_CHAR,
      P_OBJECT_VERSION_NUMBER   IN OUT NOCOPY  JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
      X_RETURN_STATUS           OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY     NUMBER,
      X_MSG_DATA                OUT NOCOPY     VARCHAR2
   )
   IS
      l_api_version         	CONSTANT NUMBER 			:= 1.0;
      l_api_name            	CONSTANT VARCHAR2(30) 			:= 'UPDATE_RS_RESOURCE_ROLES';
      l_role_id         	jtf_rs_roles_vl.role_id%type    	:= p_role_id;
      l_role_code       	jtf_rs_roles_vl.role_code%type  	:= p_role_code;
      l_role_type_code          jtf_rs_roles_vl.role_type_code%type	:= p_role_type_code;
      l_role_name             	jtf_rs_roles_vl.role_name%type          := p_role_name;
      l_role_desc             	jtf_rs_roles_vl.role_desc%type          := p_role_desc;
      l_active_flag           	jtf_rs_roles_vl.active_flag%type        := p_active_flag;
      l_seeded_flag           	jtf_rs_roles_vl.seeded_flag%type        := p_seeded_flag;
      l_member_flag           	jtf_rs_roles_vl.member_flag%type        := p_member_flag;
      l_admin_flag            	jtf_rs_roles_vl.admin_flag%type         := p_admin_flag;
      l_lead_flag             	jtf_rs_roles_vl.lead_flag%type          := p_lead_flag;
      l_manager_flag          	jtf_rs_roles_vl.manager_flag%type       := p_manager_flag;
      l_object_version_number	jtf_rs_roles_vl.object_version_number%type := p_object_version_number;

   BEGIN
      SAVEPOINT update_rs_resource_roles_pub;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Update Resource Roles Pub ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   --Put Validations here

   --Call the Update Resource Private API

      jtf_rs_roles_pvt.update_rs_resource_roles (
         P_API_VERSION          => 1,
         P_INIT_MSG_LIST        => fnd_api.g_false,
         P_COMMIT               => fnd_api.g_false,
         P_ROLE_ID		=> l_role_id,
         P_ROLE_CODE		=> l_role_code,
         P_ROLE_TYPE_CODE       => l_role_type_code,
         P_ROLE_NAME            => l_role_name,
         P_ROLE_DESC            => l_role_desc,
         P_ACTIVE_FLAG          => l_active_flag,
         P_SEEDED_FLAG          => l_seeded_flag,
         P_MEMBER_FLAG          => l_member_flag,
         P_ADMIN_FLAG           => l_admin_flag,
         P_LEAD_FLAG            => l_lead_flag,
         P_MANAGER_FLAG         => l_manager_flag,
         P_OBJECT_VERSION_NUMBER=> l_object_version_number,
         X_RETURN_STATUS	=> x_return_status,
         X_MSG_COUNT            => x_msg_count,
         X_MSG_DATA             => x_msg_data
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to private procedure');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO update_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Role Pub ============= ');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO update_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END update_rs_resource_roles;


  /* Procedure to delete the resource roles. */

  PROCEDURE  delete_rs_resource_roles
  (P_API_VERSION          	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ROLE_ID              	IN   JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_CODE            	IN   JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_OBJECT_VERSION_NUMBER      IN   JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        	OUT NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY NUMBER,
   X_MSG_DATA             	OUT NOCOPY VARCHAR2
  ) IS

    l_api_version         	CONSTANT NUMBER := 1.0;
    l_api_name            	CONSTANT VARCHAR2(30) := 'DELETE_RS_RESOURCE_ROLES';
    l_role_id			jtf_rs_roles_vl.role_id%type		:= p_role_id;
    l_role_code			jtf_rs_roles_vl.role_code%type		:= p_role_code;
    l_object_version_number	jtf_rs_roles_vl.object_version_number%type := p_object_version_number;

   BEGIN
      SAVEPOINT delete_rs_resource_roles_pub;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Delete Resource Roles Pub ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   --Put all Validations here

   --Call to the Delete Resource Role Private API

      jtf_rs_roles_pvt.delete_rs_resource_roles (
         P_API_VERSION          => 1,
         P_INIT_MSG_LIST        => fnd_api.g_false,
         P_COMMIT               => fnd_api.g_false,
         P_ROLE_ID              => l_role_id,
         P_ROLE_CODE            => l_role_code,
         P_OBJECT_VERSION_NUMBER=> l_object_version_number,
         X_RETURN_STATUS        => x_return_status,
         X_MSG_COUNT            => x_msg_count,
         X_MSG_DATA             => x_msg_data
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to private procedure');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO delete_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Role Pub ============= ');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO delete_rs_resource_roles_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END delete_rs_resource_roles;

END jtf_rs_roles_pub;

/
