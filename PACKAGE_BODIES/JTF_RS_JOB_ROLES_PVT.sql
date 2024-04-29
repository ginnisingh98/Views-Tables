--------------------------------------------------------
--  DDL for Package Body JTF_RS_JOB_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_JOB_ROLES_PVT" AS
  /* $Header: jtfrsvnb.pls 120.0 2005/05/11 08:23:09 appldev ship $ */

  /*****************************************************************************************
   This private package body defines the procedures for managing resource job roles,
   like create and delete resource job roles.
   Its main procedures are as following:
   Create Resource Job Roles
   Delete Resource Job Roles
   These procedures does the business validations and then Calls the corresponding
   table handlers to do actual inserts and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_JOB_ROLES_PVT';


  /* Procedure to create the resource job roles
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_job_roles
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_JOB_ID               IN   JTF_RS_JOB_ROLES.JOB_ID%TYPE,
   P_ROLE_ID              IN   JTF_RS_JOB_ROLES.ROLE_ID%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_JOB_ROLES.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_JOB_ROLES.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_JOB_ROLES.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_JOB_ROLES.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_JOB_ROLES.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_JOB_ROLES.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_JOB_ROLES.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_JOB_ROLES.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_JOB_ROLES.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_JOB_ROLES.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_JOB_ROLES.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_JOB_ROLES.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_JOB_ROLES.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_JOB_ROLES.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_JOB_ROLES.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_JOB_ROLES.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_JOB_ROLE_ID          OUT NOCOPY  JTF_RS_JOB_ROLES.JOB_ROLE_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_JOB_ROLES';
    l_rowid                        ROWID;
    l_job_id                       jtf_rs_job_roles.job_id%TYPE := p_job_id;
    l_role_id                      jtf_rs_job_roles.role_id%type := p_role_id;
    l_job_role_id                  jtf_rs_job_roles.job_role_id%TYPE;
    l_check_char                   VARCHAR2(1);
    l_check_count                  NUMBER;


    CURSOR c_jtf_rs_job_roles( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_job_roles
	 WHERE ROWID = l_rowid;


  BEGIN


    SAVEPOINT create_resource_job_role_pvt;

    x_return_status := fnd_api.g_ret_sts_success;


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate that the job is not already existing with the role. */

    l_check_count := 0;

    SELECT count(*)
    INTO l_check_count
    FROM jtf_rs_job_roles
    WHERE job_id = l_job_id
	 AND role_id = l_role_id;

    IF l_check_count > 0 THEN

	 x_return_status := fnd_api.g_ret_sts_error;

	 fnd_message.set_name('JTF', 'JTF_RS_JOB_EXISTS');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Get the next value of the Job_Role_id from the sequence. */

    SELECT jtf_rs_job_roles_s.nextval
    INTO l_job_role_id
    FROM dual;


    /* Insert the row into the table by calling the table handler. */

    jtf_rs_job_roles_pkg.insert_row(
      x_rowid => l_rowid,
      x_job_role_id => l_job_role_id,
      x_job_id => l_job_id,
      x_role_id => l_role_id,
      x_attribute1 => p_attribute1,
      x_attribute2 => p_attribute2,
      x_attribute3 => p_attribute3,
      x_attribute4 => p_attribute4,
      x_attribute5 => p_attribute5,
      x_attribute6 => p_attribute6,
      x_attribute7 => p_attribute7,
      x_attribute8 => p_attribute8,
      x_attribute9 => p_attribute9,
      x_attribute10 => p_attribute10,
      x_attribute11 => p_attribute11,
      x_attribute12 => p_attribute12,
      x_attribute13 => p_attribute13,
      x_attribute14 => p_attribute14,
      x_attribute15 => p_attribute15,
      x_attribute_category => p_attribute_category,
      x_creation_date => SYSDATE,
      x_created_by => jtf_resource_utl.created_by,
      x_last_update_date => SYSDATE,
      x_last_updated_by => jtf_resource_utl.updated_by,
      x_last_update_login => jtf_resource_utl.login_id
    );


    OPEN c_jtf_rs_job_roles(l_rowid);

    FETCH c_jtf_rs_job_roles INTO l_check_char;


    IF c_jtf_rs_job_roles%NOTFOUND THEN

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

      IF c_jtf_rs_job_roles%ISOPEN THEN

        CLOSE c_jtf_rs_job_roles;

      END IF;

	 RAISE fnd_api.g_exc_unexpected_error;

    ELSE

	 x_job_role_id := l_job_role_id;

    END IF;


    /* Close the cursor */

    IF c_jtf_rs_job_roles%ISOPEN THEN

      CLOSE c_jtf_rs_job_roles;

    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO create_resource_job_role_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

      ROLLBACK TO create_resource_job_role_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_job_roles;



  /* Procedure to delete the resource job roles. */

  PROCEDURE  delete_resource_job_roles
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_JOB_ROLE_ID          IN   JTF_RS_JOB_ROLES.JOB_ROLE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_JOB_ROLES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  )

  IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_JOB_ROLES';
    l_job_role_id                  jtf_rs_job_roles.job_role_id%TYPE := p_job_role_id;
    l_check_char                   VARCHAR2(1);


  BEGIN


    SAVEPOINT delete_resource_job_role_pvt;

    x_return_status := fnd_api.g_ret_sts_success;


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_job_roles_pkg.lock_row(
        x_job_role_id => l_job_role_id,
	   x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;

    END;


    /* Call the private procedure for logical delete */

    BEGIN

      /* Delete the row into the table by calling the table handler. */

      jtf_rs_job_roles_pkg.delete_row(
        x_job_role_id => l_job_role_id
      );

    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;

    END;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO delete_resource_job_role_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

      ROLLBACK TO delete_resource_job_role_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_resource_job_roles;


END jtf_rs_job_roles_pvt;

/
