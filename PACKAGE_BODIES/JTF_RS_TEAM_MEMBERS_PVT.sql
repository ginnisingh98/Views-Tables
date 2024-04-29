--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_MEMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_MEMBERS_PVT" AS
  /* $Header: jtfrsveb.pls 120.0 2005/05/11 08:22:56 appldev ship $ */

  /*****************************************************************************************
   This private package body defines the procedures for managing resource team members,
   like create and delete resource team members.
   Its main procedures are as following:
   Create Resource Team Members
   Delete Resource Team Members
   These procedures does the business validations and then Calls the corresponding
   table handlers to do actual inserts and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_TEAM_MEMBERS_PVT';


  /* Procedure to create the resource team members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_MEMBER_ID       OUT NOCOPY  JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM_MEMBERS';
    l_rowid                        ROWID;
    l_team_id                      jtf_rs_team_members.team_id%TYPE;
    l_team_resource_id             jtf_rs_team_members.team_resource_id%TYPE;
    l_resource_type                jtf_rs_team_members.resource_type%TYPE;
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;
    l_person_id                    jtf_rs_team_members.person_id%TYPE;

    l_check_char                   VARCHAR2(1);
    l_check_count                  NUMBER;
    l_bind_data_id                 NUMBER;
    l_resource_id                  NUMBER;
    l_group_id                     NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;


    CURSOR c_jtf_rs_team_members( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_team_members
	 WHERE ROWID = l_rowid;


    CURSOR c_employee_person_id( l_team_resource_id   IN  NUMBER ) IS
      SELECT source_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_team_resource_id
	   AND category = 'EMPLOYEE';


  BEGIN

    l_team_id               := p_team_id;
    l_team_resource_id      := p_team_resource_id;
    l_resource_type         := upper(p_resource_type);

    SAVEPOINT create_resource_member_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Member Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;



    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'C')
    THEN

      jtf_rs_team_member_cuhk.create_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'V')
    THEN

      jtf_rs_team_member_vuhk.create_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'I')
    THEN

      jtf_rs_team_member_iuhk.create_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Validate that the team resource is not an existing member of the team. */

    l_check_count := 0;

    SELECT count(*)
    INTO l_check_count
    FROM jtf_rs_team_members
    WHERE team_id = l_team_id
	 AND team_resource_id = l_team_resource_id
	 AND resource_type = l_resource_type
	 AND nvl(delete_flag,'N') <> 'Y';

    IF l_check_count > 0 THEN

--	 dbms_output.put_line('Resource already exists in the team');

	 x_return_status := fnd_api.g_ret_sts_error;

	 fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_EXISTS_TEAM');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* If the resource type is INDIVIDUAL' then get the Employee Person Id
	  from the Resource Extension table. */

    IF l_resource_type = 'INDIVIDUAL' THEN

      OPEN c_employee_person_id(l_team_resource_id);

      FETCH c_employee_person_id INTO l_person_id;


      IF c_employee_person_id%NOTFOUND THEN

        l_person_id := NULL;

      END IF;

    END IF;


    /* Get the next value of the Team_member_id from the sequence. */

    SELECT jtf_rs_team_members_s.nextval
    INTO l_team_member_id
    FROM dual;


    /* Insert the row into the table by calling the table handler. */

    jtf_rs_team_members_pkg.insert_row(
      x_rowid => l_rowid,
      x_team_member_id => l_team_member_id,
      x_team_id => l_team_id,
      x_team_resource_id => l_team_resource_id,
	 x_resource_type => l_resource_type,
      x_person_id => l_person_id,
	 x_delete_flag => 'N',
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


--    dbms_output.put_line('Inserted Row');

    OPEN c_jtf_rs_team_members(l_rowid);

    FETCH c_jtf_rs_team_members INTO l_check_char;


    IF c_jtf_rs_team_members%NOTFOUND THEN

--	 dbms_output.put_line('Error in Table Handler');

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

      IF c_jtf_rs_team_members%ISOPEN THEN

        CLOSE c_jtf_rs_team_members;

      END IF;

	 RAISE fnd_api.g_exc_unexpected_error;

    ELSE

--	 dbms_output.put_line('Team Member Successfully Created');

	 x_team_member_id := l_team_member_id;

    END IF;


    /* Close the cursors */

    IF c_employee_person_id%ISOPEN THEN

      CLOSE c_employee_person_id;

    END IF;

    IF c_jtf_rs_team_members%ISOPEN THEN

      CLOSE c_jtf_rs_team_members;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'C')
    THEN

      jtf_rs_team_member_cuhk.create_team_members_post(
        p_team_member_id => l_team_member_id,
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'V')
    THEN

      jtf_rs_team_member_vuhk.create_team_members_post(
        p_team_member_id => l_team_member_id,
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'I')
    THEN

      jtf_rs_team_member_iuhk.create_team_members_post(
        p_team_member_id => l_team_member_id,
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'CREATE_RESOURCE_TEAM_MEMBERS',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_team_member_cuhk.ok_to_generate_msg(
	       p_team_member_id => l_team_member_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_member_id', l_team_member_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_TMBR',
		p_action_code => 'I',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');

          x_return_status := fnd_api.g_ret_sts_unexp_error;

	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

          RAISE fnd_api.g_exc_unexpected_error;

        END IF;

      END IF;

    END IF;
    END IF;

    -- create wf_user_role record for the new team member
    -- Don't care for its success status
    BEGIN
      IF l_resource_type = 'INDIVIDUAL' THEN
        l_resource_id := l_team_resource_id;
        l_group_id := NULL;
      ELSE
        l_resource_id := NULL;
        l_group_id := l_team_resource_id;
      END IF;

      jtf_rs_wf_integration_pub.create_resource_team_members
        (P_API_VERSION      => 1.0,
         P_RESOURCE_ID      =>  l_resource_id,
         P_GROUP_ID      =>  l_group_id,
         P_TEAM_ID   => l_team_id,
         X_RETURN_STATUS   => l_return_status,
         X_MSG_COUNT      => l_msg_count,
         X_MSG_DATA      => l_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO create_resource_member_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Team_member Pvt ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_resource_member_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_team_members;


  /* Procedure to update the resource team members
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_PERSON_ID		  IN   JTF_RS_TEAM_MEMBERS.PERSON_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   P_DELETE_FLAG          IN   JTF_RS_TEAM_MEMBERS.DELETE_FLAG%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TEAM_MEMBERS.ATTRIBUTE_CATEGORY%TYPE,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_TEAM_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_TEAM_MEMBERS';
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;
    l_team_id                      jtf_rs_team_members.team_id%TYPE;
    l_team_resource_id             jtf_rs_team_members.team_resource_id%TYPE;
    l_resource_type                jtf_rs_team_members.resource_type%TYPE;
    l_person_id                    jtf_rs_team_members.person_id%TYPE;
    l_delete_flag		   jtf_rs_team_members.delete_flag%TYPE;
    l_object_version_number        jtf_rs_team_members.object_version_number%TYPE;
    l_attribute1		jtf_rs_team_members.attribute1%TYPE;
    l_attribute2		jtf_rs_team_members.attribute2%TYPE;
    l_attribute3		jtf_rs_team_members.attribute3%TYPE;
    l_attribute4		jtf_rs_team_members.attribute4%TYPE;
    l_attribute5		jtf_rs_team_members.attribute5%TYPE;
    l_attribute6		jtf_rs_team_members.attribute6%TYPE;
    l_attribute7		jtf_rs_team_members.attribute7%TYPE;
    l_attribute8		jtf_rs_team_members.attribute8%TYPE;
    l_attribute9		jtf_rs_team_members.attribute9%TYPE;
    l_attribute10		jtf_rs_team_members.attribute10%TYPE;
    l_attribute11		jtf_rs_team_members.attribute11%TYPE;
    l_attribute12		jtf_rs_team_members.attribute12%TYPE;
    l_attribute13		jtf_rs_team_members.attribute13%TYPE;
    l_attribute14		jtf_rs_team_members.attribute14%TYPE;
    l_attribute15		jtf_rs_team_members.attribute15%TYPE;
    l_attribute_catgory		jtf_rs_team_members.attribute_category%TYPE;

    l_check_char                   VARCHAR2(1);
    l_check_count                  NUMBER;
    l_bind_data_id                 NUMBER;

    CURSOR c_rs_team_members_update(l_team_member_id IN NUMBER) IS
    SELECT DECODE(p_team_id, fnd_api.g_miss_num, team_id, p_team_id) l_team_id,
	DECODE(p_team_resource_id, fnd_api.g_miss_num, team_resource_id, p_team_resource_id) l_team_resource_id,
	DECODE(p_person_id, fnd_api.g_miss_num, person_id, p_person_id) l_person_id,
	DECODE(p_resource_type, fnd_api.g_miss_char, resource_type, p_resource_type) l_resource_type,
	DECODE(p_delete_flag, fnd_api.g_miss_char, delete_flag, p_delete_flag) l_delete_flag,
	DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) l_attribute1,
	DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) l_attribute2,
	DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) l_attribute3,
	DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) l_attribute4,
	DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) l_attribute5,
	DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) l_attribute6,
	DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) l_attribute7,
	DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) l_attribute8,
	DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) l_attribute9,
	DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) l_attribute10,
	DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) l_attribute11,
	DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) l_attribute12,
	DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) l_attribute13,
	DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) l_attribute14,
	DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) l_attribute15,
	DECODE(p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category) l_attribute_category
    FROM jtf_rs_team_members
    WHERE team_member_id = l_team_member_id ;

    rs_team_member_rec		c_rs_team_members_update%ROWTYPE ;

  BEGIN

    l_team_member_id             := p_team_member_id;
    l_team_id                    := p_team_id;
    l_team_resource_id           := p_team_resource_id;
    l_resource_type              := upper(p_resource_type);
    l_person_id                  := p_person_id;
    l_delete_flag                := p_delete_flag ;
    l_object_version_number      := p_object_version_number ;
    l_attribute1                 := p_attribute1 ;
    l_attribute2                 := p_attribute2 ;
    l_attribute3                 := p_attribute3 ;
    l_attribute4                 := p_attribute4 ;
    l_attribute5                 := p_attribute5 ;
    l_attribute6                 := p_attribute6 ;
    l_attribute7                 := p_attribute7 ;
    l_attribute8                 := p_attribute8 ;
    l_attribute9                 := p_attribute9 ;
    l_attribute10                := p_attribute10 ;
    l_attribute11                := p_attribute11 ;
    l_attribute12                := p_attribute12 ;
    l_attribute13                := p_attribute13 ;
    l_attribute14                := p_attribute14 ;
    l_attribute15                := p_attribute15 ;
    l_attribute_catgory          := p_attribute_category ;

    SAVEPOINT update_resource_member_pvt;
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      	RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      	fnd_msg_pub.initialize;
    END IF;

    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'C')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'B',
		 'C')
	    THEN
	      jtf_rs_team_member_cuhk.update_team_members_pre(
		p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);

	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');
			x_return_status := fnd_api.g_ret_sts_unexp_error;
		   	fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
		   	fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'V')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'B',
		 'V')
	    THEN
	      jtf_rs_team_member_vuhk.update_team_members_pre(
		p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);

	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');
			x_return_status := fnd_api.g_ret_sts_unexp_error;
		   	fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
		   	fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'I')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'B',
		 'I')
	    THEN
	      jtf_rs_team_member_iuhk.update_team_members_pre(
		p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);
	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
			x_return_status := fnd_api.g_ret_sts_unexp_error;
		   	fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
		   	fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Validate the team member for update. */

    OPEN c_rs_team_members_update(l_team_member_id) ;
    FETCH c_rs_team_members_update
    INTO  rs_team_member_rec ;
    IF c_rs_team_members_update%NOTFOUND THEN
	CLOSE c_rs_team_members_update ;
	fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM_MBR_ID');
	fnd_message.set_token('P_TEAM_MBR_ID', p_team_member_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
    END IF ;

    /* Call the Lock Row Table Handler before updating the record */
    BEGIN
	    jtf_rs_team_members_pkg.lock_row(
		x_team_member_id => l_team_member_id,
		x_object_version_number => l_object_version_number) ;
    EXCEPTION
	 WHEN OTHERS THEN
	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;
    END;

    /* Update the Object Version Number by Incrementing It */
    l_object_version_number := l_object_version_number + 1 ;

    /* Update the row into the table by calling the table handler. */
    BEGIN
	    jtf_rs_team_members_pkg.update_row(
	      x_team_member_id => l_team_member_id,
	      x_team_id => rs_team_member_rec.l_team_id,
	      x_team_resource_id => rs_team_member_rec.l_team_resource_id,
	      x_resource_type => rs_team_member_rec.l_resource_type,
	      x_person_id => rs_team_member_rec.l_person_id,
	      x_delete_flag => rs_team_member_rec.l_delete_flag,
	      x_object_version_number =>l_object_version_number,
	      x_attribute1 => rs_team_member_rec.l_attribute1,
	      x_attribute2 => rs_team_member_rec.l_attribute2,
	      x_attribute3 => rs_team_member_rec.l_attribute3,
	      x_attribute4 => rs_team_member_rec.l_attribute4,
	      x_attribute5 => rs_team_member_rec.l_attribute5,
	      x_attribute6 => rs_team_member_rec.l_attribute6,
	      x_attribute7 => rs_team_member_rec.l_attribute7,
	      x_attribute8 => rs_team_member_rec.l_attribute8,
	      x_attribute9 => rs_team_member_rec.l_attribute9,
	      x_attribute10 => rs_team_member_rec.l_attribute10,
	      x_attribute11 => rs_team_member_rec.l_attribute11,
	      x_attribute12 => rs_team_member_rec.l_attribute12,
	      x_attribute13 => rs_team_member_rec.l_attribute13,
	      x_attribute14 => rs_team_member_rec.l_attribute14,
	      x_attribute15 => rs_team_member_rec.l_attribute15,
	      x_attribute_category => rs_team_member_rec.l_attribute_category,
	      x_last_update_date => SYSDATE,
	      x_last_updated_by => jtf_resource_utl.updated_by,
	      x_last_update_login => jtf_resource_utl.login_id
	    );

	    p_object_version_number := l_object_version_number ;
	    --  dbms_output.put_line('Updated Row');

	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
			CLOSE c_rs_team_members_update ;
			x_return_status := fnd_api.g_ret_sts_unexp_error ;
			fnd_message.set_name('JTF','JTF_RS_TABLE_HANDLER_ERROR') ;
			fnd_msg_pub.add ;
			RAISE fnd_api.g_exc_unexpected_error ;
    END ;

    IF c_rs_team_members_update%ISOPEN THEN
       CLOSE c_rs_team_members_update;
    END IF;

    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'C')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'A',
		 'C')
	    THEN
	      jtf_rs_team_member_cuhk.update_team_members_post(
		  p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);

	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'V')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'A',
		 'V')
	    THEN
	      jtf_rs_team_member_vuhk.update_team_members_post(
		p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);

	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'I')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'A',
		 'I')
	    THEN
	      jtf_rs_team_member_iuhk.update_team_members_post(
		p_team_member_id => l_team_member_id,
		   x_return_status => x_return_status);

	      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	    END IF;
    END IF;

    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'UPDATE_RESOURCE_TEAM_MEMBERS',
	 'M',
	 'M')
    THEN
	    IF jtf_usr_hks.ok_to_execute(
		 'JTF_RS_TEAM_MEMBERS_PVT',
		 'UPDATE_RESOURCE_TEAM_MEMBERS',
		 'M',
		 'M')
	    THEN
	      IF (jtf_rs_team_member_cuhk.ok_to_generate_msg(
		       p_team_member_id => l_team_member_id,
		       x_return_status => x_return_status) )
	      THEN

		/* Get the bind data id for the Business Object Instance */

		l_bind_data_id := jtf_usr_hks.get_bind_data_id;


		/* Set bind values for the bind variables in the Business Object SQL */

		jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_member_id', l_team_member_id, 'S', 'N');

		/* Call the message generation API */

		jtf_usr_hks.generate_message(
			p_prod_code => 'JTF',
			p_bus_obj_code => 'RS_TMBR',
			p_action_code => 'U',
			p_bind_data_id => l_bind_data_id,
			x_return_code => x_return_status);


		IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	--	     dbms_output.put_line('Returned Error status from the Message Generation API');
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	      END IF;
	    END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_member_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_member_pvt;
      fnd_message.set_token('P_SQLCODE',SQLCODE) ;
      fnd_message.set_token('P_SQLERRM',SQLERRM) ;
      fnd_message.set_token('P_API_NAME',l_api_name) ;
      fnd_msg_pub.add ;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END update_resource_team_members;

  /* Procedure to delete the resource team members. */

  PROCEDURE  delete_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_TEAM_MEMBERS';
    l_team_id                      jtf_rs_team_members.team_id%TYPE;
    l_team_resource_id             jtf_rs_team_members.team_resource_id%TYPE;
    l_resource_type                jtf_rs_team_members.resource_type%TYPE;
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;
    l_role_relate_count            NUMBER;
    l_bind_data_id                 NUMBER;
    l_resource_id                  NUMBER;
    l_group_id                     NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;

    CURSOR c_team_member_id(
	 l_team_id             IN  NUMBER,
	 l_team_resource_id    IN  NUMBER,
	 l_resource_type       IN  VARCHAR2)
    IS
      SELECT team_member_id
      FROM jtf_rs_team_members
      WHERE team_id = l_team_id
	   AND team_resource_id = l_team_resource_id
	   AND resource_type = l_resource_type
	   AND nvl(delete_flag,'N') <> 'Y';


    CURSOR c_related_role_count(
	 l_team_member_id    IN  NUMBER)
    IS
	 SELECT count(*)
	 FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_TEAM_MEMBER'
	   AND role_resource_id = l_team_member_id
	   AND ( end_date_active is null OR end_date_active >= sysdate )
	   AND nvl(delete_flag,'N') <> 'Y';



  BEGIN

    l_team_id                 := p_team_id;
    l_team_resource_id        := p_team_resource_id;
    l_resource_type           := upper(p_resource_type);

    SAVEPOINT delete_resource_member_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Delete Resource Member Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'C')
    THEN

      jtf_rs_team_member_cuhk.delete_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'V')
    THEN

      jtf_rs_team_member_vuhk.delete_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'B',
	 'I')
    THEN

      jtf_rs_team_member_iuhk.delete_team_members_pre(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Validate that the specified resource exists as a member of the
	  specified team */

    OPEN c_team_member_id(l_team_id, l_team_resource_id, l_resource_type);

    FETCH c_team_member_id INTO l_team_member_id;


    IF c_team_member_id%NOTFOUND THEN

--	 dbms_output.put_line('Resource is not setup as a member of the Team');

      IF c_team_member_id%ISOPEN THEN

        CLOSE c_team_member_id;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM_MEMBER');
      fnd_message.set_token('P_TEAM_RESOURCE_ID', l_team_resource_id);
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Close the cursor */

    IF c_team_member_id%ISOPEN THEN

      CLOSE c_team_member_id;

    END IF;


    /* Validate that there are no associated roles with the team member
	  which are presently active or will be active in future */

    OPEN c_related_role_count(l_team_member_id);

    FETCH c_related_role_count INTO l_role_relate_count;


    IF c_related_role_count%NOTFOUND THEN

--	 dbms_output.put_line('Error in getting the count of the related role records');

      IF c_related_role_count%ISOPEN THEN

        CLOSE c_related_role_count;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_ERROR_ROLE_COUNT');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    ELSE

      IF l_role_relate_count > 0 THEN

--	   dbms_output.put_line('Active Role Related Records found');

        IF c_related_role_count%ISOPEN THEN

          CLOSE c_related_role_count;

        END IF;

        fnd_message.set_name('JTF', 'JTF_RS_ACTIVE_TEAM_ROLE_EXIST');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_team_members_pkg.lock_row(
        x_team_member_id => l_team_member_id,
	   x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN

--	   dbms_output.put_line('Error in Locking the Row');

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;

    END;



    /* Call the private procedure for logical delete */

    BEGIN

      -- delete wf_user_role record for the new team member
      -- Don't care for its success status
      BEGIN
	IF l_resource_type = 'INDIVIDUAL' THEN
	  l_resource_id := l_team_resource_id;
	  l_group_id := NULL;
	ELSE
	  l_resource_id := NULL;
	  l_group_id := l_team_resource_id;
	END IF;

        jtf_rs_wf_integration_pub.delete_resource_team_members
          (P_API_VERSION      => 1.0,
           P_RESOURCE_ID      =>  l_resource_id,
           P_GROUP_ID      =>  l_group_id,
           P_TEAM_ID   => l_team_id,
           X_RETURN_STATUS   => l_return_status,
           X_MSG_COUNT      => l_msg_count,
           X_MSG_DATA      => l_msg_data);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      /* Delete the row into the table by calling the table handler. */

      jtf_rs_team_members_pkg.logical_delete_row(
        x_team_member_id => l_team_member_id
      );

    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;

    END;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'C')
    THEN

      jtf_rs_team_member_cuhk.delete_team_members_post(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'V')
    THEN

      jtf_rs_team_member_vuhk.delete_team_members_post(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'A',
	 'I')
    THEN

      jtf_rs_team_member_iuhk.delete_team_members_post(
        p_team_id => l_team_id,
        p_team_resource_id => l_team_resource_id,
        p_resource_type => l_resource_type,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_MEMBERS_PVT',
	 'DELETE_RESOURCE_TEAM_MEMBERS',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_team_member_cuhk.ok_to_generate_msg(
	       p_team_member_id => l_team_member_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_member_id', l_team_member_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'TMBR',
		p_action_code => 'D',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');

          x_return_status := fnd_api.g_ret_sts_unexp_error;

	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

          RAISE fnd_api.g_exc_unexpected_error;

        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO delete_resource_member_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Team Member Pvt ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO delete_resource_member_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_resource_team_members;



END jtf_rs_team_members_pvt;

/
