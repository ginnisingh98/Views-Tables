--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_USAGES_PVT" AS
  /* $Header: jtfrsvjb.pls 120.0 2005/05/11 08:23:04 appldev ship $ */

  /*****************************************************************************************
   This private package body defines the procedures for managing resource team usages,
   like create and delete resource team usages.
   Its main procedures are as following:
   Create Resource Team Usage
   Delete Resource Team Usage
   These procedures does the business validations and then Calls the corresponding
   table handlers to do actual inserts and deletes into tables.
   ******************************************************************************************/


  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TEAM_USAGES_PVT';


  /* Procedure to create the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  create_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
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
   X_TEAM_USAGE_ID        OUT NOCOPY JTF_RS_TEAM_USAGES.TEAM_USAGE_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_TEAM_USAGE';
    l_team_id                      jtf_rs_team_usages.team_id%TYPE := p_team_id;
    l_usage                        jtf_rs_team_usages.usage%TYPE := upper(p_usage);

    l_rowid                        ROWID;
    l_team_usage_id                jtf_rs_team_usages.team_usage_id%TYPE;
    l_check_char                   VARCHAR2(1);
    l_check_count                  NUMBER;
    l_bind_data_id                 NUMBER;


    CURSOR c_exclusive_team_check(
	 l_team_id     IN  NUMBER,
	 l_usage       IN  VARCHAR)
    IS
	 SELECT 'Y'
      FROM jtf_rs_teams_vl G1,
        jtf_rs_teams_vl G2,
	   jtf_rs_team_members GM1,
	   jtf_rs_team_members GM2,
	   jtf_rs_team_usages GU2,
	   jtf_rs_role_relations RR1,
	   jtf_rs_role_relations RR2
      WHERE G1.team_id = GM1.team_id
	   AND G2.team_id = GM2.team_id
	   AND nvl(GM1.delete_flag, 'N') <> 'Y'
	   AND nvl(GM2.delete_flag, 'N') <> 'Y'
	   AND GM1.team_resource_id = GM2.team_resource_id
	   AND GM1.resource_type = 'RS_TEAM_MEMBER'
	   AND GM2.resource_type = 'RS_TEAM_MEMBER'
	   AND GM1.team_member_id = RR1.role_resource_id
	   AND GM2.team_member_id = RR2.role_resource_id
	   AND RR1.role_resource_type = 'RS_TEAM_MEMBER'
	   AND RR2.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(RR1.delete_flag, 'N') <> 'Y'
	   AND nvl(RR2.delete_flag, 'N') <> 'Y'
	   AND NOT (((RR2.end_date_active < RR1.start_date_active OR
			    RR2.start_date_active > RR1.end_date_active) AND
		         RR1.end_date_active IS NOT NULL)
		       OR (RR2.end_date_active < RR1.start_date_active AND
			      RR1.end_date_active IS NULL))
        AND G2.exclusive_flag = 'Y'
	   AND GU2.team_id = G2.team_id
	   AND GU2.usage = l_usage
	   AND G1.team_id <> G2.team_id
	   AND G1.team_id = l_team_id;


    CURSOR c_jtf_rs_team_usages( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_team_usages
	 WHERE ROWID = l_rowid;


  BEGIN


    SAVEPOINT create_rs_team_usage_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line('Started Create Resource Team Usage Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'C')
    THEN

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'C')
    THEN

      jtf_rs_team_usage_cuhk.create_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'V')
    THEN

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'V')
    THEN

      jtf_rs_team_usage_vuhk.create_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'B',
	 'I')
    THEN

      jtf_rs_team_usage_cuhk.create_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Validate that the usage is not already assigned */

    l_check_count := 0;

    SELECT count(*)
    INTO l_check_count
    FROM jtf_rs_team_usages
    WHERE team_id = l_team_id
	 AND usage = l_usage;

    IF l_check_count > 0 THEN

--	 dbms_output.put_line('Usage already assigned to the Team');

	 x_return_status := fnd_api.g_ret_sts_error;

	 fnd_message.set_name('JTF', 'JTF_RS_USAGE_EXISTS_TEAM');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* If Team Exclusive Flag is checked then only those resources can be
       assigned to the team, who are not assigned to any other Exclusive team
       having the same USAGE value in that same time period. Validate that the
       new team usage support the above condition for all the team members. */

    OPEN c_exclusive_team_check(l_team_id, l_usage);

    FETCH c_exclusive_team_check INTO l_check_char;


    IF c_exclusive_team_check%FOUND THEN

--	 dbms_output.put_line('Team usage cannot be created as one of the member
--	   dates overlap with another record for the same resource assigned to
--	   another exclusive team with the same usage in the same time period');

      IF c_exclusive_team_check%ISOPEN THEN

        CLOSE c_exclusive_team_check;

      END IF;

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 fnd_message.set_name('JTF', 'JTF_RS_EXCLUSIVE_TEAM_ERR');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Close the cursors */

    IF c_exclusive_team_check%ISOPEN THEN

      CLOSE c_exclusive_team_check;

    END IF;



    /* Get the next value of the Team_usage_id from the sequence. */

    SELECT jtf_rs_team_usages_s.nextval
    INTO l_team_usage_id
    FROM dual;


    /* Insert the row into the table by calling the table handler. */

    jtf_rs_team_usages_pkg.insert_row(
      x_rowid => l_rowid,
      x_team_usage_id => l_team_usage_id,
      x_team_id => l_team_id,
      x_usage => l_usage,
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

    OPEN c_jtf_rs_team_usages(l_rowid);

    FETCH c_jtf_rs_team_usages INTO l_check_char;


    IF c_jtf_rs_team_usages%NOTFOUND THEN

--	 dbms_output.put_line('Error in Table Handler');

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

      IF c_jtf_rs_team_usages%ISOPEN THEN

        CLOSE c_jtf_rs_team_usages;

      END IF;

	 RAISE fnd_api.g_exc_unexpected_error;

    ELSE

--	 dbms_output.put_line('Team Usage Successfully Created');

	 x_team_usage_id := l_team_usage_id;

    END IF;


    /* Close the cursors */

    IF c_jtf_rs_team_usages%ISOPEN THEN

      CLOSE c_jtf_rs_team_usages;

    END IF;



    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */
    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'C')
    THEN

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'C')
    THEN

      jtf_rs_team_usage_cuhk.create_team_usage_post(
        p_team_usage_id => l_team_usage_id,
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'V')
    THEN

      jtf_rs_team_usage_vuhk.create_team_usage_post(
        p_team_usage_id => l_team_usage_id,
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'A',
	 'I')
    THEN

      jtf_rs_team_usage_iuhk.create_team_usage_post(
        p_team_usage_id => l_team_usage_id,
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'CREATE_TEAM_USAGE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_team_usage_cuhk.ok_to_generate_msg(
	       p_team_usage_id => l_team_usage_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_usage_id', l_team_usage_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_TUSG',
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


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO create_rs_team_usage_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Team Usage Pvt ========= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_rs_team_usage_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_team_usage;



  /* Procedure to delete the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  delete_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_USAGES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_TEAM_USAGE';
    l_team_id                      jtf_rs_team_usages.team_id%TYPE := p_team_id;
    l_usage                        jtf_rs_team_usages.usage%TYPE := upper(p_usage);

    l_check_char                   VARCHAR2(1);
    l_team_usage_id                jtf_rs_team_usages.team_usage_id%TYPE;
    l_bind_data_id                 NUMBER;


    CURSOR c_team_usage_id(
	 l_team_id        IN  NUMBER,
	 l_usage          IN  VARCHAR2 )
    IS
      SELECT team_usage_id
      FROM jtf_rs_team_usages
      WHERE team_id = l_team_id
	   AND usage = l_usage;


  BEGIN


    SAVEPOINT delete_team_usage_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Delete Team Usage Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */
    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'C')
    THEN

      jtf_rs_team_usage_cuhk.delete_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'V')
    THEN

      jtf_rs_team_usage_vuhk.delete_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'B',
	 'I')
    THEN

      jtf_rs_team_usage_iuhk.delete_team_usage_pre(
        p_team_id => l_team_id,
        p_usage => l_usage,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Validate that the specified usage exists for the specified team */

    OPEN c_team_usage_id(l_team_id, l_usage);

    FETCH c_team_usage_id INTO l_team_usage_id;


    IF c_team_usage_id%NOTFOUND THEN

--	 dbms_output.put_line('Usage is not setup for the Team');

      IF c_team_usage_id%ISOPEN THEN

        CLOSE c_team_usage_id;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM_USAGE');
      fnd_message.set_token('P_USAGE', l_usage);
      fnd_message.set_token('P_TEAM_ID', l_team_id);
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Close the cursor */

    IF c_team_usage_id%ISOPEN THEN

      CLOSE c_team_usage_id;

    END IF;



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_team_usages_pkg.lock_row(
        x_team_usage_id => l_team_usage_id,
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



    /* Call the private procedure for physical delete */

    BEGIN

      /* Delete the row into the table by calling the table handler. */

      jtf_rs_team_usages_pkg.delete_row(
        x_team_usage_id => l_team_usage_id
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'C')
    THEN

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'C')
    THEN

      jtf_rs_team_usage_cuhk.delete_team_usage_post(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'V')
    THEN

      jtf_rs_team_usage_vuhk.delete_team_usage_post(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'A',
	 'I')
    THEN

      jtf_rs_team_usage_iuhk.delete_team_usage_post(
        p_team_id => l_team_id,
        p_usage => l_usage,
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
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAM_USAGES_PVT',
	 'DELETE_TEAM_USAGE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_team_usage_cuhk.ok_to_generate_msg(
	       p_team_usage_id => l_team_usage_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_usage_id', l_team_usage_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'TUSG',
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

      ROLLBACK TO delete_team_usage_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Team Usage Pvt ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO delete_team_usage_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_team_usage;


END jtf_rs_team_usages_pvt;

/
