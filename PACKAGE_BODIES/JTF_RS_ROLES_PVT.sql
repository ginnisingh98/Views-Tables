--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLES_PVT" AS
  /* $Header: jtfrsvob.pls 120.0 2005/05/11 08:23:11 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource roles, like
   create, update and delete resource Roles.
   Its main procedures are as following:
   Create Resource Roles
   Update Resource Roles
   Delete Resource Roles
   This package valoidates the input parameters to these procedures and then
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

   --Package variables.

      G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_ROLES_PVT';

   --Procedure to create the resource roles based on input values passed by calling routines

   PROCEDURE  create_rs_resource_roles (
      P_API_VERSION          IN   NUMBER,
      P_INIT_MSG_LIST        IN   VARCHAR2,
      P_COMMIT               IN   VARCHAR2,
      P_ROLE_TYPE_CODE       IN   JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE            IN   JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME            IN   JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC            IN   JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG          IN   JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG	     IN   JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG          IN   JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG           IN   JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG            IN   JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG         IN   JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      P_ATTRIBUTE1           IN   JTF_RS_ROLES_B.ATTRIBUTE1%TYPE,
      P_ATTRIBUTE2           IN   JTF_RS_ROLES_B.ATTRIBUTE2%TYPE,
      P_ATTRIBUTE3           IN   JTF_RS_ROLES_B.ATTRIBUTE3%TYPE,
      P_ATTRIBUTE4           IN   JTF_RS_ROLES_B.ATTRIBUTE4%TYPE,
      P_ATTRIBUTE5           IN   JTF_RS_ROLES_B.ATTRIBUTE5%TYPE,
      P_ATTRIBUTE6           IN   JTF_RS_ROLES_B.ATTRIBUTE6%TYPE,
      P_ATTRIBUTE7           IN   JTF_RS_ROLES_B.ATTRIBUTE7%TYPE,
      P_ATTRIBUTE8           IN   JTF_RS_ROLES_B.ATTRIBUTE8%TYPE,
      P_ATTRIBUTE9           IN   JTF_RS_ROLES_B.ATTRIBUTE9%TYPE,
      P_ATTRIBUTE10          IN   JTF_RS_ROLES_B.ATTRIBUTE10%TYPE,
      P_ATTRIBUTE11          IN   JTF_RS_ROLES_B.ATTRIBUTE11%TYPE,
      P_ATTRIBUTE12          IN   JTF_RS_ROLES_B.ATTRIBUTE12%TYPE,
      P_ATTRIBUTE13          IN   JTF_RS_ROLES_B.ATTRIBUTE13%TYPE,
      P_ATTRIBUTE14          IN   JTF_RS_ROLES_B.ATTRIBUTE14%TYPE,
      P_ATTRIBUTE15          IN   JTF_RS_ROLES_B.ATTRIBUTE15%TYPE,
      P_ATTRIBUTE_CATEGORY   IN   JTF_RS_ROLES_B.ATTRIBUTE_CATEGORY%TYPE,
      X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT            OUT NOCOPY  NUMBER,
      X_MSG_DATA             OUT NOCOPY  VARCHAR2,
      X_ROLE_ID 	     OUT NOCOPY JTF_RS_ROLES_B.ROLE_ID%TYPE
   )
   IS

   l_api_version                CONSTANT NUMBER 			:= 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) 			:= 'CREATE_RS_RESOURCE_ROLES';
   l_role_type_code		jtf_rs_roles_vl.role_type_code%type	:= p_role_type_code;
   l_role_code			jtf_rs_roles_vl.role_code%type		:= p_role_code;
   l_role_name                  jtf_rs_roles_vl.role_name%type          := p_role_name;
   l_role_desc			jtf_rs_roles_vl.role_desc%type		:= p_role_desc;
   l_seeded_flag                jtf_rs_roles_vl.seeded_flag%type        := p_seeded_flag;
   l_active_flag		jtf_rs_roles_vl.active_flag%type	:= p_active_flag;
   l_member_flag                jtf_rs_roles_vl.member_flag%type	:= p_member_flag;
   l_admin_flag                 jtf_rs_roles_vl.admin_flag%type		:= p_admin_flag;
   l_lead_flag                  jtf_rs_roles_vl.lead_flag%type		:= p_lead_flag;
   l_manager_flag               jtf_rs_roles_vl.manager_flag%type	:= p_manager_flag;
   l_attribute1              	jtf_rs_roles_vl.attribute1%type         := p_attribute1;
   l_attribute2              	jtf_rs_roles_vl.attribute2%type         := p_attribute2;
   l_attribute3              	jtf_rs_roles_vl.attribute3%type         := p_attribute3;
   l_attribute4              	jtf_rs_roles_vl.attribute4%type         := p_attribute4;
   l_attribute5              	jtf_rs_roles_vl.attribute5%type         := p_attribute5;
   l_attribute6              	jtf_rs_roles_vl.attribute6%type         := p_attribute6;
   l_attribute7              	jtf_rs_roles_vl.attribute7%type         := p_attribute7;
   l_attribute8              	jtf_rs_roles_vl.attribute8%type         := p_attribute8;
   l_attribute9              	jtf_rs_roles_vl.attribute9%type         := p_attribute9;
   l_attribute10             	jtf_rs_roles_vl.attribute10%type        := p_attribute10;
   l_attribute11             	jtf_rs_roles_vl.attribute11%type        := p_attribute11;
   l_attribute12             	jtf_rs_roles_vl.attribute12%type        := p_attribute12;
   l_attribute13             	jtf_rs_roles_vl.attribute13%type        := p_attribute13;
   l_attribute14             	jtf_rs_roles_vl.attribute14%type        := p_attribute14;
   l_attribute15             	jtf_rs_roles_vl.attribute15%type        := p_attribute15;
   l_attribute_category      	jtf_rs_roles_vl.attribute_category%type := p_attribute_category;
   l_rowid                      ROWID;
   l_role_id                    jtf_rs_roles_vl.role_id%type;
   i 				number;
   l_check_char			varchar2(1);
   l_bind_data_id		number;

   l_return_status             VARCHAR2(2000);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);

   CURSOR c_jtf_rs_roles( l_role_id IN jtf_rs_roles_vl.role_id%type ) IS
      SELECT 'Y'
      FROM jtf_rs_roles_vl
      WHERE role_id = l_role_id;

   CURSOR c_role_code (l_role_code IN jtf_rs_roles_vl.role_code%type) IS
      SELECT role_code
      FROM jtf_rs_roles_vl
      WHERE role_code = l_role_code;

   CURSOR c_role_type_code ( l_role_type_code IN jtf_rs_roles_vl.role_type_code%type) IS
      SELECT lookup_code from fnd_lookups
      WHERE LOOKUP_TYPE = 'JTF_RS_ROLE_TYPE'
      AND lookup_code = l_role_type_code
      AND enabled_flag = 'Y'
      AND trunc(sysdate) <= trunc(nvl(end_date_active,sysdate));

   Dummy_char varchar2(1);

   CURSOR c_role_name_check(c_role_name IN jtf_rs_roles_vl.role_name%type, c_role_type_code IN jtf_rs_roles_vl.role_type_code%type) IS
   SELECT 'x'
   FROM   jtf_rs_roles_vl
   WHERE  upper(ROLE_NAME) = c_role_name
   AND    ROLE_TYPE_CODE = c_role_type_code;

   BEGIN

      SAVEPOINT create_rs_resource_roles_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Create RS Resource Roles Pvt ');

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'B',
          'C')
       THEN
          jtf_rs_roles_cuhk.create_rs_resource_roles_pre(
             P_ROLE_TYPE_CODE		=> l_role_type_code,
             P_ROLE_CODE		=> l_role_code,
             P_ROLE_NAME		=> l_role_name,
             P_ROLE_DESC		=> l_role_desc,
             P_ACTIVE_FLAG		=> l_active_flag,
             P_SEEDED_FLAG		=> l_seeded_flag,
             P_MEMBER_FLAG		=> l_member_flag,
             P_ADMIN_FLAG		=> l_admin_flag,
             P_LEAD_FLAG		=> l_lead_flag,
             P_MANAGER_FLAG		=> l_manager_flag,
             X_RETURN_STATUS		=> x_return_status,
             X_MSG_COUNT		=> x_msg_count,
             X_MSG_DATA			=> x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

    --Pre Call to the Vertical Type User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'B',
          'V')
       THEN
          jtf_rs_roles_vuhk.create_rs_resource_roles_pre(
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

    --Pre Call to the Internal Type User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'B',
          'I')
       THEN
          jtf_rs_roles_iuhk.create_rs_resource_roles_pre(
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

   --Put in all the Validations here

   --Validate that the Role Code is not null and unique

      IF l_role_code is NULL THEN
         --dbms_output.put_line ('Role Code Is Null');
         fnd_message.set_name('JTF', 'JTF_RS_ROLE_CODE_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_role_code is not NULL THEN
         OPEN c_role_code (l_role_code);
         FETCH c_role_code INTO l_role_code;
         IF c_role_code%FOUND THEN
	    --dbms_output.put_line ('Duplicate Role Code');
            fnd_message.set_name('JTF', 'JTF_RS_ROLE_CODE_EXISTS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate Role Type Code

      IF l_role_type_code is NULL THEN
         --dbms_output.put_line ('Role Type Code Is Null');
         fnd_message.set_name('JTF', 'JTF_RS_ROLE_TYPE_CODE_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_role_type_code is not NULL THEN
         OPEN c_role_type_code (l_role_type_code);
         FETCH c_role_type_code INTO l_role_type_code;
         IF c_role_type_code%NOTFOUND THEN
            --dbms_output.put_line('Role type code is invalid');
            CLOSE c_role_type_code;
            fnd_message.set_name('JTF', 'JTF_RS_INVALID_ROLE_TYPE_CODE');
            fnd_message.set_token('P_ROLE_TYPE_CODE', p_role_type_code);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate that Role Name is Not Null

     IF l_role_name IS NULL THEN
         --dbms_output.put_line ('Role Name is Null');
         fnd_message.set_name ('JTF','JTF_RS_ROLE_NAME_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
     ELSE
        OPEN c_role_name_check(upper(l_role_name),l_role_type_code);
        FETCH c_role_name_check INTO Dummy_char;
        IF (c_role_name_check%FOUND) THEN
--           fnd_message.set_name('JTF', 'This Role name is already exists for the same Role type. Please choose a role name unique within this role type');
           fnd_message.set_name('JTF', 'JTF_RS_ROLE_NAME_EXISTS');
           fnd_msg_pub.add;
           CLOSE c_role_name_check;
           x_return_status := fnd_api.g_ret_sts_error;
           RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE c_role_name_check;
     END IF;

   --Validate the flags

   --Validate the seeded flag
      IF l_seeded_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag	=> l_seeded_flag,
            x_return_status	=> x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate the member flag
      IF l_member_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => l_member_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate the admin flag
      IF l_admin_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => l_admin_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate the lead flag
      IF l_lead_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => l_lead_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate the manager flag
      IF l_manager_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => l_manager_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate the active flag
      IF l_active_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => l_active_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Get the next value of the Role Id from the sequence
      SELECT jtf_rs_roles_s.nextval
      INTO l_role_id
      FROM dual;

   --Call the Table Handler to Insert Values into jtf_rs_roles Tables

      jtf_rs_roles_pkg.insert_row (
         X_ROWID		=> l_rowid,
         X_ROLE_ID		=> l_role_id,
         X_ATTRIBUTE3		=> l_attribute3,
         X_ATTRIBUTE4		=> l_attribute4,
         X_ATTRIBUTE5		=> l_attribute5,
         X_ATTRIBUTE6		=> l_attribute6,
         X_ATTRIBUTE7		=> l_attribute7,
         X_ATTRIBUTE8		=> l_attribute8,
         X_ATTRIBUTE9		=> l_attribute9,
         X_ATTRIBUTE10		=> l_attribute10,
         X_ATTRIBUTE11		=> l_attribute11,
         X_ATTRIBUTE12		=> l_attribute12,
         X_ATTRIBUTE13		=> l_attribute13,
         X_ATTRIBUTE14		=> l_attribute14,
         X_ATTRIBUTE15		=> l_attribute15,
         X_ATTRIBUTE_CATEGORY	=> l_attribute_category,
         X_ROLE_CODE		=> l_role_code,
         X_ROLE_TYPE_CODE	=> l_role_type_code,
         X_SEEDED_FLAG		=> l_seeded_flag,
         X_MEMBER_FLAG		=> l_member_flag,
         X_ADMIN_FLAG		=> l_admin_flag,
         X_LEAD_FLAG		=> l_lead_flag,
         X_MANAGER_FLAG		=> l_manager_flag,
         X_ACTIVE_FLAG		=> l_active_flag,
         X_ATTRIBUTE1		=> l_attribute1,
         X_ATTRIBUTE2		=> l_attribute2,
         X_ROLE_NAME		=> l_role_name,
         X_ROLE_DESC		=> l_role_desc,
         X_CREATION_DATE	=> sysdate,
         X_CREATED_BY		=> jtf_resource_utl.created_by,
         X_LAST_UPDATE_DATE	=> sysdate,
         X_LAST_UPDATED_BY	=> jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN	=> jtf_resource_utl.login_id
      );

      --dbms_output.put_line('Inserted Row');
      OPEN c_jtf_rs_roles (l_role_id);
      FETCH c_jtf_rs_roles INTO l_check_char;
      IF c_jtf_rs_roles%NOTFOUND THEN
         --dbms_output.put_line('Error in Table Handler');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
         fnd_msg_pub.add;
      CLOSE c_jtf_rs_roles;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         --dbms_output.put_line('Resource Role Successfully Created');
         x_role_id := l_role_id;
         x_return_status := fnd_api.g_ret_sts_success;
      END IF;

    --Post Call to the Customer User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'A',
          'C')
       THEN
          jtf_rs_roles_cuhk.create_rs_resource_roles_post(
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             P_ROLE_ID		   => l_role_id,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

    --Post Call to the Vertical Type User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'A',
          'V')
       THEN
          jtf_rs_roles_vuhk.create_rs_resource_roles_post(
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             P_ROLE_ID             => l_role_id,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

    --Post Call to the Internal Type User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'CREATE_RS_RESOURCE_ROLES',
          'A',
          'I')
       THEN
          jtf_rs_roles_iuhk.create_rs_resource_roles_post(
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             P_ROLE_ID             => l_role_id,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'CREATE_RS_RESOURCE_ROLES',
         'M',
         'M')
      THEN
         IF (jtf_rs_roles_cuhk.ok_to_generate_msg(
            p_role_id 		=> l_role_id,
            x_return_status 	=> x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_id', l_role_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code => 'JTF',
               p_bus_obj_code => 'RS_ROLE',
               p_action_code => 'I',
               p_bind_data_id => l_bind_data_id,
               x_return_code => x_return_status);

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      /* Calling publish API to raise create resource role event. */
      /* added by baianand on 04/02/2003 */

      begin
         jtf_rs_wf_events_pub.create_resource_role
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_role_id                   => l_role_id
              ,p_role_type_code            => l_role_type_code
              ,p_role_code                 => l_role_code
              ,p_role_name                 => l_role_name
              ,p_role_desc                 => l_role_desc
              ,p_active_flag               => l_active_flag
              ,p_member_flag               => l_member_flag
              ,p_admin_flag                => l_admin_flag
              ,p_lead_flag                 => l_lead_flag
              ,p_manager_flag              => l_manager_flag
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

      EXCEPTION when others then
         null;
      end;

     /* End of publish API call */


   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO create_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Role Pvt =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO create_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END create_rs_resource_roles;

   --Procedure to update the resource roles based on input values passed by calling routines

   PROCEDURE  update_rs_resource_roles (
      P_API_VERSION             IN      NUMBER,
      P_INIT_MSG_LIST           IN      VARCHAR2,
      P_COMMIT                  IN      VARCHAR2,
      P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
      P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
      P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
      P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
      P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
      P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
      P_ATTRIBUTE1              IN      JTF_RS_ROLES_B.ATTRIBUTE1%TYPE,
      P_ATTRIBUTE2              IN      JTF_RS_ROLES_B.ATTRIBUTE2%TYPE,
      P_ATTRIBUTE3              IN      JTF_RS_ROLES_B.ATTRIBUTE3%TYPE,
      P_ATTRIBUTE4              IN      JTF_RS_ROLES_B.ATTRIBUTE4%TYPE,
      P_ATTRIBUTE5              IN      JTF_RS_ROLES_B.ATTRIBUTE5%TYPE,
      P_ATTRIBUTE6              IN      JTF_RS_ROLES_B.ATTRIBUTE6%TYPE,
      P_ATTRIBUTE7              IN      JTF_RS_ROLES_B.ATTRIBUTE7%TYPE,
      P_ATTRIBUTE8              IN      JTF_RS_ROLES_B.ATTRIBUTE8%TYPE,
      P_ATTRIBUTE9              IN      JTF_RS_ROLES_B.ATTRIBUTE9%TYPE,
      P_ATTRIBUTE10             IN      JTF_RS_ROLES_B.ATTRIBUTE10%TYPE,
      P_ATTRIBUTE11             IN      JTF_RS_ROLES_B.ATTRIBUTE11%TYPE,
      P_ATTRIBUTE12             IN      JTF_RS_ROLES_B.ATTRIBUTE12%TYPE,
      P_ATTRIBUTE13             IN      JTF_RS_ROLES_B.ATTRIBUTE13%TYPE,
      P_ATTRIBUTE14             IN      JTF_RS_ROLES_B.ATTRIBUTE14%TYPE,
      P_ATTRIBUTE15             IN      JTF_RS_ROLES_B.ATTRIBUTE15%TYPE,
      P_ATTRIBUTE_CATEGORY      IN      JTF_RS_ROLES_B.ATTRIBUTE_CATEGORY%TYPE,
      P_OBJECT_VERSION_NUMBER   IN OUT NOCOPY  JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
      X_RETURN_STATUS           OUT NOCOPY  	VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  	NUMBER,
      X_MSG_DATA                OUT NOCOPY 	VARCHAR2
   )
   IS
      l_api_version         	CONSTANT NUMBER := 1.0;
      l_api_name            	CONSTANT VARCHAR2(30) := 'UPDATE_RS_RESOURCE_ROLES';
      l_role_id         	jtf_rs_roles_vl.role_id%type    	:= p_role_id;
      l_role_code       	jtf_rs_roles_vl.role_code%type		:= p_role_code;
      l_role_name               jtf_rs_roles_vl.role_name%type          := p_role_name;
      l_role_desc               jtf_rs_roles_vl.role_desc%type          := p_role_desc;
      l_role_type_code         	jtf_rs_roles_vl.role_type_code%type  	:= p_role_type_code;
      l_seeded_flag		jtf_rs_roles_vl.seeded_flag%type	:= p_seeded_flag;
      l_active_flag             jtf_rs_roles_vl.active_flag%type	:= p_active_flag;
      l_member_flag             jtf_rs_roles_vl.member_flag%type	:= p_member_flag;
      l_admin_flag              jtf_rs_roles_vl.admin_flag%type		:= p_admin_flag;
      l_lead_flag               jtf_rs_roles_vl.lead_flag%type		:= p_lead_flag;
      l_manager_flag            jtf_rs_roles_vl.manager_flag%type	:= p_manager_flag;
      l_object_version_number   jtf_rs_roles_vl.object_version_number%type :=p_object_version_number;
      l_attribute1              jtf_rs_roles_vl.attribute1%type		:= p_attribute1;
      l_attribute2              jtf_rs_roles_vl.attribute2%type		:= p_attribute2;
      l_attribute3              jtf_rs_roles_vl.attribute3%type		:= p_attribute3;
      l_attribute4              jtf_rs_roles_vl.attribute4%type		:= p_attribute4;
      l_attribute5              jtf_rs_roles_vl.attribute5%type		:= p_attribute5;
      l_attribute6              jtf_rs_roles_vl.attribute6%type		:= p_attribute6;
      l_attribute7              jtf_rs_roles_vl.attribute7%type		:= p_attribute7;
      l_attribute8              jtf_rs_roles_vl.attribute8%type		:= p_attribute8;
      l_attribute9              jtf_rs_roles_vl.attribute9%type		:= p_attribute9;
      l_attribute10             jtf_rs_roles_vl.attribute10%type	:= p_attribute10;
      l_attribute11             jtf_rs_roles_vl.attribute11%type	:= p_attribute11;
      l_attribute12             jtf_rs_roles_vl.attribute12%type	:= p_attribute12;
      l_attribute13             jtf_rs_roles_vl.attribute13%type	:= p_attribute13;
      l_attribute14             jtf_rs_roles_vl.attribute14%type	:= p_attribute14;
      l_attribute15             jtf_rs_roles_vl.attribute15%type	:= p_attribute15;
      l_attribute_category      jtf_rs_roles_vl.attribute_category%type	:= p_attribute_category;
      L_BIND_DATA_ID            NUMBER;


   CURSOR c_role_code (l_role_code IN jtf_rs_roles_vl.role_code%type) IS
      SELECT role_code
      FROM jtf_rs_roles_vl
      WHERE role_code = l_role_code;

   CURSOR c_role_type_code ( l_role_type_code IN jtf_rs_roles_vl.role_type_code%type) IS
      SELECT lookup_code from fnd_lookups
      WHERE LOOKUP_TYPE = 'JTF_RS_ROLE_TYPE'
      AND lookup_code = l_role_type_code
      AND enabled_flag = 'Y'
      AND trunc(sysdate) <= trunc(nvl(end_date_active,sysdate));

   Dummy_char varchar2(1);

   CURSOR c_role_name_check(c_role_name IN jtf_rs_roles_vl.role_name%type, c_role_type_code IN jtf_rs_roles_vl.role_type_code%type) IS
   SELECT 'x'
   FROM   jtf_rs_roles_vl
   WHERE  upper(role_name) = c_role_name
   AND    role_type_code = c_role_type_code
   AND    role_id <> p_role_id;

   CURSOR c_rs_role_update( l_role_id IN  NUMBER ) IS
      SELECT
         Role_Code role_code,
         DECODE(p_role_code, fnd_api.g_miss_char, role_code, p_role_code) l_role_code,
         DECODE(p_role_type_code, fnd_api.g_miss_char, role_type_code, p_role_type_code) l_role_type_code,
         DECODE(p_role_name, fnd_api.g_miss_char, role_name, p_role_name) l_role_name,
         DECODE(p_seeded_flag, fnd_api.g_miss_char, seeded_flag, p_seeded_flag) l_seeded_flag,
         DECODE(p_member_flag, fnd_api.g_miss_char, member_flag, p_member_flag) l_member_flag,
         DECODE(p_admin_flag, fnd_api.g_miss_char, admin_flag, p_admin_flag) l_admin_flag,
         DECODE(p_lead_flag, fnd_api.g_miss_char, lead_flag, p_lead_flag) l_lead_flag,
         DECODE(p_manager_flag, fnd_api.g_miss_char, manager_flag, p_manager_flag) l_manager_flag,
         DECODE(p_active_flag, fnd_api.g_miss_char, active_flag, p_active_flag) l_active_flag,
         DECODE(p_role_desc, fnd_api.g_miss_char, role_desc, p_role_desc) l_role_desc,
         DECODE(p_attribute1,fnd_api.g_miss_char, attribute1, p_attribute1) l_attribute1,
         DECODE(p_attribute2,fnd_api.g_miss_char, attribute2, p_attribute2) l_attribute2,
         DECODE(p_attribute3,fnd_api.g_miss_char, attribute3, p_attribute3) l_attribute3,
         DECODE(p_attribute4,fnd_api.g_miss_char, attribute4, p_attribute4) l_attribute4,
         DECODE(p_attribute5,fnd_api.g_miss_char, attribute5, p_attribute5) l_attribute5,
         DECODE(p_attribute6,fnd_api.g_miss_char, attribute6, p_attribute6) l_attribute6,
         DECODE(p_attribute7,fnd_api.g_miss_char, attribute7, p_attribute7) l_attribute7,
         DECODE(p_attribute8,fnd_api.g_miss_char, attribute8, p_attribute8) l_attribute8,
         DECODE(p_attribute9,fnd_api.g_miss_char, attribute9, p_attribute9) l_attribute9,
         DECODE(p_attribute10,fnd_api.g_miss_char, attribute10, p_attribute10) l_attribute10,
         DECODE(p_attribute11,fnd_api.g_miss_char, attribute11, p_attribute11) l_attribute11,
         DECODE(p_attribute12,fnd_api.g_miss_char, attribute12, p_attribute12) l_attribute12,
         DECODE(p_attribute13,fnd_api.g_miss_char, attribute13, p_attribute13) l_attribute13,
         DECODE(p_attribute14,fnd_api.g_miss_char, attribute14, p_attribute14) l_attribute14,
         DECODE(p_attribute15,fnd_api.g_miss_char, attribute15, p_attribute15) l_attribute15,
         DECODE(p_attribute_category,fnd_api.g_miss_char, attribute1, p_attribute_category) l_attribute_category
      FROM jtf_rs_roles_vl
      WHERE role_id = l_role_id;

      rs_role_rec      c_rs_role_update%ROWTYPE;

      l_return_status             VARCHAR2(2000);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      l_resource_role_rec         jtf_rs_roles_pvt.resource_role_rec_type;

   BEGIN

      SAVEPOINT update_rs_resource_roles_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Update Resource Roles Pvt ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Pre Call to the Customer User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'UPDATE_RS_RESOURCE_ROLES',
          'B',
          'C')
       THEN
          jtf_rs_roles_cuhk.update_rs_resource_roles_pre(
             P_ROLE_ID      	   => l_role_id,
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

   --Pre Call to Vertical User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'UPDATE_RS_RESOURCE_ROLES',
         'B',
         'V')
      THEN
         jtf_rs_roles_vuhk.update_rs_resource_roles_pre(
            P_ROLE_ID		  => l_role_id,
            P_ROLE_TYPE_CODE      => l_role_type_code,
            P_ROLE_CODE           => l_role_code,
            P_ROLE_NAME           => l_role_name,
            P_ROLE_DESC           => l_role_desc,
            P_ACTIVE_FLAG         => l_active_flag,
            P_SEEDED_FLAG         => l_seeded_flag,
            P_MEMBER_FLAG         => l_member_flag,
            P_ADMIN_FLAG          => l_admin_flag,
            P_LEAD_FLAG           => l_lead_flag,
            P_MANAGER_FLAG        => l_manager_flag,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
        );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

  --Pre Call to Internal User Hook
       IF jtf_usr_hks.ok_to_execute(
          'JTF_RS_ROLES_PVT',
          'UPDATE_RS_RESOURCE_ROLES',
          'B',
          'I')
       THEN
          jtf_rs_roles_iuhk.update_rs_resource_roles_pre(
             P_ROLE_ID             => l_role_id,
             P_ROLE_TYPE_CODE      => l_role_type_code,
             P_ROLE_CODE           => l_role_code,
             P_ROLE_NAME           => l_role_name,
             P_ROLE_DESC           => l_role_desc,
             P_ACTIVE_FLAG         => l_active_flag,
             P_SEEDED_FLAG         => l_seeded_flag,
             P_MEMBER_FLAG         => l_member_flag,
             P_ADMIN_FLAG          => l_admin_flag,
             P_LEAD_FLAG           => l_lead_flag,
             P_MANAGER_FLAG        => l_manager_flag,
             X_RETURN_STATUS       => x_return_status,
             X_MSG_COUNT           => x_msg_count,
             X_MSG_DATA            => x_msg_data
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

   --Put Validations here

   --Validate the Role for Update
      OPEN c_rs_role_update(l_role_id);
      FETCH c_rs_role_update INTO rs_role_rec;
      IF c_rs_role_update%NOTFOUND THEN
         CLOSE c_rs_role_update;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_ROLE_ID');
         fnd_message.set_token('P_ROLE_ID', p_role_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate the Resource Role

   --BEGIN

      --jtf_resource_utl.validate_resource_role(
      --   p_role_id              => l_role_id,
      --   p_role_code            => l_role_code,
      --   x_return_status        => x_return_status,
      --   x_role_id              => l_role_id
      --);

      --IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      --   x_return_status := fnd_api.g_ret_sts_unexp_error;
      --   RAISE fnd_api.g_exc_unexpected_error;
      --END IF;

   --END;

   --End of Resource Role Validation

   --Validate if the Seeded Flag is Checked
--       SELECT seeded_flag INTO l_seeded_flag
--       FROM jtf_rs_roles_vl
--       WHERE role_id = l_role_id;

--       IF l_seeded_flag = 'Y' THEN
--          --dbms_output.put_line ('Seeded Data Cannot be Updated');
--          fnd_message.set_name ('JTF', 'JTF_RS_SEEDED_FLAG_CHECKED');
--          fnd_msg_pub.add;
--          x_return_status := fnd_api.g_ret_sts_unexp_error;
--          RAISE fnd_api.g_exc_unexpected_error;
--       END IF;

   --Validate that the Role Code is not null and unique

      IF l_role_code <> FND_API.G_MISS_CHAR THEN
         IF l_role_code is NULL THEN
            --dbms_output.put_line ('Role Code Is Null');
            fnd_message.set_name('JTF', 'JTF_RS_ROLE_CODE_NULL');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF (l_role_code is not NULL AND l_role_code <> rs_role_rec.role_code) THEN
            OPEN c_role_code (l_role_code);
            FETCH c_role_code INTO l_role_code;
            IF c_role_code%FOUND THEN
               --dbms_output.put_line ('Duplicate Role Code');
               fnd_message.set_name('JTF', 'JTF_RS_ROLE_CODE_EXISTS');
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

   --Validate Role Type Code

      IF l_role_type_code <> FND_API.G_MISS_CHAR THEN
         IF l_role_type_code is NULL THEN
            --dbms_output.put_line ('Role Type Code Is Null');
            fnd_message.set_name('JTF', 'JTF_RS_ROLE_TYPE_CODE_NULL');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_role_type_code is not NULL THEN
            OPEN c_role_type_code (l_role_type_code);
            FETCH c_role_type_code INTO l_role_type_code;
            IF c_role_type_code%NOTFOUND THEN
               --dbms_output.put_line('Role type code is invalid');
               CLOSE c_role_type_code;
               fnd_message.set_name('JTF', 'JTF_RS_INVALID_ROLE_TYPE_CODE');
               fnd_message.set_token('P_ROLE_TYPE_CODE', l_role_type_code);
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

   --Validate that Role Name is Not Null

      IF l_role_name <> FND_API.G_MISS_CHAR THEN
         IF l_role_name IS NULL THEN
            --dbms_output.put_line ('Role Name is Null');
            fnd_message.set_name ('JTF','JTF_RS_ROLE_NAME_NULL');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSE
            OPEN c_role_name_check(upper(l_role_name),rs_role_rec.l_role_type_code);
            FETCH c_role_name_check INTO Dummy_char;
            IF (c_role_name_check%FOUND) THEN
               fnd_message.set_name('JTF', 'JTF_RS_ROLE_NAME_EXISTS');
               fnd_msg_pub.add;
               CLOSE c_role_name_check;
               x_return_status := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE c_role_name_check;
         END IF;
      END IF;

   --End of Role Name Validation

   --Validate Flags

   --Validate the seeded flag
   IF l_seeded_flag <> FND_API.G_MISS_CHAR THEN
      IF rs_role_rec.l_seeded_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_seeded_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Validate the member flag
   IF l_member_flag <> FND_API.G_MISS_CHAR THEN
      IF rs_role_rec.l_member_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_member_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Validate the admin flag
   IF l_admin_flag <> FND_API.G_MISS_CHAR THEN
      IF  rs_role_rec.l_admin_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_admin_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Validate the lead flag
   IF l_lead_flag <> FND_API.G_MISS_CHAR THEN
      IF  rs_role_rec.l_lead_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_lead_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Validate the manager flag
   IF l_manager_flag <> FND_API.G_MISS_CHAR THEN
      IF  rs_role_rec.l_manager_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_manager_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Validate the active flag
   IF l_active_flag <> FND_API.G_MISS_CHAR THEN
      IF  rs_role_rec.l_active_flag IS NOT NULL THEN
         jtf_resource_utl.validate_rs_role_flags (
            p_rs_role_flag      => rs_role_rec.l_active_flag,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   --Call the Lock Row Table Handler before updating the record
      jtf_rs_roles_pkg.lock_row (
         X_ROLE_ID                      => l_role_id,
         X_OBJECT_VERSION_NUMBER        => l_object_version_number
      );

    /* Calling publish API to raise update resource role event. */
    /* added by baianand on 04/02/2003 */

    begin

       l_resource_role_rec.role_id            := l_role_id;
       l_resource_role_rec.role_code          := rs_role_rec.l_role_code;
       l_resource_role_rec.role_type_code     := rs_role_rec.l_role_type_code;
       l_resource_role_rec.role_name          := rs_role_rec.l_role_name;
       l_resource_role_rec.role_desc          := rs_role_rec.l_role_desc;
       l_resource_role_rec.active_flag        := rs_role_rec.l_active_flag;
       l_resource_role_rec.member_flag        := rs_role_rec.l_member_flag;
       l_resource_role_rec.admin_flag         := rs_role_rec.l_admin_flag;
       l_resource_role_rec.lead_flag          := rs_role_rec.l_lead_flag;
       l_resource_role_rec.manager_flag       := rs_role_rec.l_manager_flag;

       jtf_rs_wf_events_pub.update_resource_role
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_role_rec         => l_resource_role_rec
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

    /* End of publish API call */


   --Update the Object Version Number by Incrementing It
      l_object_version_number    := l_object_version_number+1;

   --Call the Table Handler to Update the Values in jtf_rs_role tables
   BEGIN
      jtf_rs_roles_pkg.update_row (
         X_ROLE_ID              => l_role_id,
         X_ATTRIBUTE3           => rs_role_rec.l_attribute3,
         X_ATTRIBUTE4           => rs_role_rec.l_attribute4,
         X_ATTRIBUTE5           => rs_role_rec.l_attribute5,
         X_ATTRIBUTE6           => rs_role_rec.l_attribute6,
         X_ATTRIBUTE7           => rs_role_rec.l_attribute7,
         X_ATTRIBUTE8           => rs_role_rec.l_attribute8,
         X_ATTRIBUTE9           => rs_role_rec.l_attribute9,
         X_ATTRIBUTE10          => rs_role_rec.l_attribute10,
         X_ATTRIBUTE11          => rs_role_rec.l_attribute11,
         X_ATTRIBUTE12          => rs_role_rec.l_attribute12,
         X_ATTRIBUTE13          => rs_role_rec.l_attribute13,
         X_ATTRIBUTE14          => rs_role_rec.l_attribute14,
         X_ATTRIBUTE15          => rs_role_rec.l_attribute15,
         X_ATTRIBUTE_CATEGORY   => rs_role_rec.l_attribute_category,
         X_ROLE_CODE            => rs_role_rec.l_role_code,
         X_ROLE_TYPE_CODE       => rs_role_rec.l_role_type_code,
         X_SEEDED_FLAG          => rs_role_rec.l_seeded_flag,
         X_MEMBER_FLAG          => rs_role_rec.l_member_flag,
         X_ADMIN_FLAG           => rs_role_rec.l_admin_flag,
         X_LEAD_FLAG            => rs_role_rec.l_lead_flag,
         X_MANAGER_FLAG         => rs_role_rec.l_manager_flag,
         X_ACTIVE_FLAG          => rs_role_rec.l_active_flag,
         X_ATTRIBUTE1           => rs_role_rec.l_attribute1,
         X_ATTRIBUTE2           => rs_role_rec.l_attribute2,
         X_ROLE_NAME            => rs_role_rec.l_role_name,
         X_ROLE_DESC            => rs_role_rec.l_role_desc,
         X_OBJECT_VERSION_NUMBER=> l_object_version_number,
         X_LAST_UPDATE_DATE     => sysdate,
         X_LAST_UPDATED_BY	=> jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN	=> jtf_resource_utl.login_id
      );

      p_object_version_number := l_object_version_number;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         CLOSE c_rs_role_update;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
   END;
      --dbms_output.put_line('Role Successfully Updated');

  --Post Call to Customer User Hook
     IF jtf_usr_hks.ok_to_execute(
        'JTF_RS_ROLES_PVT',
        'UPDATE_RS_RESOURCE_ROLES',
        'A',
        'C')
     THEN
        jtf_rs_roles_cuhk.update_rs_resource_roles_post(
           P_ROLE_ID		 => l_role_id,
           P_ROLE_TYPE_CODE      => l_role_type_code,
           P_ROLE_CODE           => l_role_code,
           P_ROLE_NAME           => l_role_name,
           P_ROLE_DESC           => l_role_desc,
           P_ACTIVE_FLAG         => l_active_flag,
           P_SEEDED_FLAG         => l_seeded_flag,
           P_MEMBER_FLAG         => l_member_flag,
           P_ADMIN_FLAG          => l_admin_flag,
           P_LEAD_FLAG           => l_lead_flag,
           P_MANAGER_FLAG        => l_manager_flag,
           X_RETURN_STATUS       => x_return_status,
           X_MSG_COUNT           => x_msg_count,
           X_MSG_DATA            => x_msg_data
        );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
     END IF;

   --Post Call to Vertical User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'UPDATE_RS_RESOURCE_ROLES',
         'A',
         'V')
      THEN
         jtf_rs_roles_vuhk.update_rs_resource_roles_post(
            P_ROLE_ID		  => l_role_id,
            P_ROLE_TYPE_CODE      => l_role_type_code,
            P_ROLE_CODE           => l_role_code,
            P_ROLE_NAME           => l_role_name,
            P_ROLE_DESC           => l_role_desc,
            P_ACTIVE_FLAG         => l_active_flag,
            P_SEEDED_FLAG         => l_seeded_flag,
            P_MEMBER_FLAG         => l_member_flag,
            P_ADMIN_FLAG          => l_admin_flag,
            P_LEAD_FLAG           => l_lead_flag,
            P_MANAGER_FLAG        => l_manager_flag,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Post Call to Vertical User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'UPDATE_RS_RESOURCE_ROLES',
         'A',
         'I')
      THEN
         jtf_rs_roles_iuhk.update_rs_resource_roles_post(
            P_ROLE_ID             => l_role_id,
            P_ROLE_TYPE_CODE      => l_role_type_code,
            P_ROLE_CODE           => l_role_code,
            P_ROLE_NAME           => l_role_name,
            P_ROLE_DESC           => l_role_desc,
            P_ACTIVE_FLAG         => l_active_flag,
            P_SEEDED_FLAG         => l_seeded_flag,
            P_MEMBER_FLAG         => l_member_flag,
            P_ADMIN_FLAG          => l_admin_flag,
            P_LEAD_FLAG           => l_lead_flag,
            P_MANAGER_FLAG        => l_manager_flag,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'UPDATE_RS_RESOURCE_ROLES',
         'M',
         'M')
      THEN
         IF (jtf_rs_roles_cuhk.ok_to_generate_msg(
            p_role_id           => l_role_id,
            x_return_status     => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
           jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_id', l_role_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code => 'JTF',
               p_bus_obj_code => 'RS_ROLE',
               p_action_code => 'U',
               p_bind_data_id => l_bind_data_id,
               x_return_code => x_return_status);

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO update_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Role Pub =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO update_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END update_rs_resource_roles;


  /* Procedure to delete the resource roles. */

  PROCEDURE  delete_rs_resource_roles
  (P_API_VERSION          	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2,
   P_COMMIT               	IN   VARCHAR2,
   P_ROLE_ID              	IN   JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_CODE            	IN   JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_OBJECT_VERSION_NUMBER      IN   JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        	OUT NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY NUMBER,
   X_MSG_DATA             	OUT NOCOPY VARCHAR2
  ) IS

    l_api_version         	CONSTANT NUMBER := 1.0;
    l_api_name            	CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_ROLES';
    l_role_id			jtf_rs_roles_vl.role_id%type	:= p_role_id;
    l_role_code			jtf_rs_roles_vl.role_code%type	:= p_role_code;
    L_BIND_DATA_ID              NUMBER;
    l_object_version_number	jtf_rs_roles_vl.object_version_number%type := p_object_version_number;
-- added for NOCOPY handle in JTF_RESOURCE_UTL
    l_role_id_out			jtf_rs_roles_vl.role_id%type;

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

     FUNCTION role_used(p_role_id IN NUMBER) return boolean IS
       l_exists varchar2(1) := 'N';
       CURSOR c_role IS
       SELECT 'Y' from jtf_rs_role_relations
       WHERE  role_id = p_role_id
       AND    NVL(DELETE_FLAG,'N') <> 'Y';
     BEGIN
       OPEN c_role;
       FETCH c_role INTO l_exists;
       CLOSE c_role;
       IF l_exists = 'Y' THEN
         return true;
       END IF;
       return false;
     END role_used;

     FUNCTION get_role_name(p_role_id IN NUMBER) return VARCHAR2 IS
       role_name jtf_Rs_roles_tl.role_name%type;
       cursor c_role_name is
       SELECT role_name from jtf_rs_roles_vl
       WHERE role_id = p_role_id;
     BEGIN
       OPEN c_role_name;
       FETCH c_role_name into role_name;
       CLOSE c_role_name;
       return role_name;
     END;

   BEGIN
      SAVEPOINT delete_rs_resource_roles_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Delete Resource Roles Pub ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF role_used(p_role_id) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_ROLE_USED');
         fnd_message.set_token('ROLE_NAME', get_role_name(p_role_id));
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --Pre Call to Customer User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'B',
         'C')
      THEN
         jtf_rs_roles_cuhk.delete_rs_resource_roles_pre(
            P_ROLE_ID		  => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Pre Call to Vertical User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'B',
         'V')
      THEN
         jtf_rs_roles_vuhk.delete_rs_resource_roles_pre(
            P_ROLE_ID             => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Pre Call to Internal User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'B',
         'I')
      THEN
         jtf_rs_roles_iuhk.delete_rs_resource_roles_pre(
            P_ROLE_ID             => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Put all Validations here

   --Validate the Resource Role

   BEGIN

      jtf_resource_utl.validate_resource_role(
         p_role_id              => l_role_id,
         p_role_code            => l_role_code,
         x_return_status        => x_return_status,
         x_role_id              => l_role_id_out
      );
-- added for NOCOPY
      l_role_id := l_role_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END;

   --Call the Lock Row Table Handler before deleting the Record

      jtf_rs_roles_pkg.lock_row (
         X_ROLE_ID			=> l_role_id,
         X_OBJECT_VERSION_NUMBER	=> l_object_version_number
      );

   --Call the Table Handler to Delete the Row from the jtf_rs_roles Table

      jtf_rs_roles_pkg.delete_row (
         X_ROLE_ID              => l_role_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to private procedure');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Post Call to Customer User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'A',
         'C')
      THEN
         jtf_rs_roles_cuhk.delete_rs_resource_roles_post(
            P_ROLE_ID             => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Post Call to Vertical User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'A',
         'V')
      THEN
         jtf_rs_roles_vuhk.delete_rs_resource_roles_post(
            P_ROLE_ID             => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Post Call to Internal User Hook
      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'A',
         'I')
      THEN
         jtf_rs_roles_iuhk.delete_rs_resource_roles_post(
            P_ROLE_ID             => l_role_id,
            P_ROLE_CODE           => l_role_code,
            X_RETURN_STATUS       => x_return_status,
            X_MSG_COUNT           => x_msg_count,
            X_MSG_DATA            => x_msg_data
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_ROLES_PVT',
         'DELETE_RS_RESOURCE_ROLES',
         'M',
         'M')
      THEN
         IF (jtf_rs_roles_cuhk.ok_to_generate_msg(
            p_role_id           => l_role_id,
            x_return_status     => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
           jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_id', l_role_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code => 'JTF',
               p_bus_obj_code => 'RS_ROLE',
               p_action_code => 'D',
               p_bind_data_id => l_bind_data_id,
               x_return_code => x_return_status);

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    /* Calling publish API to raise delete resource role event. */
    /* added by baianand on 04/02/2003 */

      begin
         jtf_rs_wf_events_pub.delete_resource_role
                 (p_api_version               => 1.0
                 ,p_init_msg_list             => fnd_api.g_false
                 ,p_commit                    => fnd_api.g_false
                 ,p_role_id                   => l_role_id
                 ,x_return_status             => l_return_status
                 ,x_msg_count                 => l_msg_count
                 ,x_msg_data                  => l_msg_data);

      EXCEPTION when others then
         null;
      end;

    /* End of publish API call */

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO delete_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Role Pub =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO delete_rs_resource_roles_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END delete_rs_resource_roles;

END jtf_rs_roles_pvt;

/
