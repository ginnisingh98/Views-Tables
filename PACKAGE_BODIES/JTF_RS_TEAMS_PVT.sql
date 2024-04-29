--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAMS_PVT" AS
  /* $Header: jtfrsvtb.pls 120.0 2005/05/11 08:23:17 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource teams.
   Its main procedures are as following:
   Create Resource Team Members
   Update Resource Team Members
   These procedures do the business validations and then call the appropriate
   table handlers to do the actual inserts and updates.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TEAMS_PVT';


  /* Procedure to create the resource team and the members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_TEAMS_VL.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_TEAMS_VL.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_TEAMS_VL.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_TEAMS_VL.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_TEAMS_VL.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_TEAMS_VL.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_TEAMS_VL.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_TEAMS_VL.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_TEAMS_VL.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_TEAMS_VL.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_TEAMS_VL.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_TEAMS_VL.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_TEAMS_VL.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_TEAMS_VL.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_TEAMS_VL.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TEAMS_VL.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_ID              OUT NOCOPY  JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   X_TEAM_NUMBER          OUT NOCOPY JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM';
    l_rowid                        ROWID;
    l_team_name                    jtf_rs_teams_vl.team_name%TYPE := p_team_name;
    l_team_desc                    jtf_rs_teams_vl.team_desc%TYPE := p_team_desc;
    l_exclusive_flag               jtf_rs_teams_vl.exclusive_flag%TYPE := p_exclusive_flag;
    l_email_address                jtf_rs_teams_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_teams_vl.start_date_active%TYPE := trunc(p_start_date_active);
    l_end_date_active              jtf_rs_teams_vl.end_date_active%TYPE := trunc(p_end_date_active);
    l_team_id                      jtf_rs_teams_vl.team_id%TYPE;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;
    l_check_char                   VARCHAR2(1);
    l_bind_data_id                 NUMBER;


    CURSOR c_jtf_rs_teams( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_teams_b
	 WHERE ROWID = l_rowid;


  BEGIN


    SAVEPOINT create_resource_team_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Team Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_team_cuhk.create_resource_team_pre(
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_team_vuhk.create_resource_team_pre(
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_team_iuhk.create_resource_team_pre(
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Get the next value of the team_id from the sequence. */

    SELECT jtf_rs_teams_s.nextval
    INTO l_team_id
    FROM dual;


    /* Get the next value of the Team_number from the sequence. */

    SELECT jtf_rs_team_number_s.nextval
    INTO l_team_number
    FROM dual;


    /* Insert the row into the table by calling the table handler. */

    jtf_rs_teams_pkg.insert_row(
      x_rowid => l_rowid,
      x_team_id => l_team_id,
      x_team_number => l_team_number,
      x_exclusive_flag => l_exclusive_flag,
      x_email_address => l_email_address,
      x_start_date_active => l_start_date_active,
      x_end_date_active => l_end_date_active,
      x_team_name => l_team_name,
      x_team_desc => l_team_desc,
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

    OPEN c_jtf_rs_teams(l_rowid);

    FETCH c_jtf_rs_teams INTO l_check_char;


    IF c_jtf_rs_teams%NOTFOUND THEN

--	 dbms_output.put_line('Error in Table Handler');

      IF c_jtf_rs_teams%ISOPEN THEN

        CLOSE c_jtf_rs_teams;

      END IF;

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_unexpected_error;

    ELSE

--	 dbms_output.put_line('Team Successfully Created');

	 x_team_id := l_team_id;

	 x_team_number := l_team_number;

    END IF;


    /* Close the cursors */

    IF c_jtf_rs_teams%ISOPEN THEN

      CLOSE c_jtf_rs_teams;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_team_cuhk.create_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_team_vuhk.create_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_team_iuhk.create_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'CREATE_RESOURCE_TEAM',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_team_cuhk.ok_to_generate_msg(
	       p_team_id => l_team_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_id', l_team_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_TEAM',
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

    -- create the wf roles with new resource team
    -- Don't care for its success status
    BEGIN
      jtf_rs_wf_integration_pub.create_resource_team
        (P_API_VERSION      => 1.0,
         P_TEAM_ID      =>  l_team_id,
         P_TEAM_NAME   => l_team_name,
         P_EMAIL_ADDRESS   => l_email_address,
         P_START_DATE_ACTIVE => l_start_date_active,
         P_END_DATE_ACTIVE  => l_end_date_active,
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

      ROLLBACK TO create_resource_team_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Team Pvt ========= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_resource_team_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_team;



  /* Procedure to update the resource team based on input values
	passed by calling routines. */

  PROCEDURE  update_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_TEAMS_VL.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_TEAMS_VL.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_TEAMS_VL.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_TEAMS_VL.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_TEAMS_VL.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_TEAMS_VL.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_TEAMS_VL.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_TEAMS_VL.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_TEAMS_VL.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_TEAMS_VL.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_TEAMS_VL.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_TEAMS_VL.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_TEAMS_VL.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_TEAMS_VL.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_TEAMS_VL.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TEAMS_VL.ATTRIBUTE_CATEGORY%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_TEAMS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_TEAM';
    l_team_id                      jtf_rs_teams_vl.team_id%TYPE := p_team_id;
    l_team_name                    jtf_rs_teams_vl.team_name%TYPE := p_team_name;
    l_team_desc                    jtf_rs_teams_vl.team_desc%TYPE := p_team_desc;
    l_exclusive_flag               jtf_rs_teams_vl.exclusive_flag%TYPE := p_exclusive_flag;
    l_email_address                jtf_rs_teams_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_teams_vl.start_date_active%TYPE := trunc(p_start_date_active);
    l_end_date_active              jtf_rs_teams_vl.end_date_active%TYPE := trunc(p_end_date_active);
    l_object_version_num           jtf_rs_teams_vl.object_version_number%type := p_object_version_num;

    l_max_end_date                 DATE;
    l_min_start_date               DATE;
    l_check_char                   VARCHAR2(1);
    l_bind_data_id                 NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;

    CURSOR c_team_update(
	 l_team_id       IN  NUMBER )
    IS
	 SELECT
	   team_number,
	   DECODE(p_team_name, fnd_api.g_miss_char, team_name, p_team_name) team_name,
	   DECODE(p_team_desc, fnd_api.g_miss_char, team_desc, p_team_desc) team_desc,
	   DECODE(p_exclusive_flag, fnd_api.g_miss_char, exclusive_flag, NULL, 'N', p_exclusive_flag) exclusive_flag,
	   DECODE(p_email_address, fnd_api.g_miss_char, email_address, p_email_address) email_address,
	   DECODE(p_start_date_active, fnd_api.g_miss_date, start_date_active, trunc(p_start_date_active)) start_date_active,
	   DECODE(p_end_date_active, fnd_api.g_miss_date, end_date_active, trunc(p_end_date_active)) end_date_active,
	   DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) attribute1,
	   DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) attribute2,
	   DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) attribute3,
	   DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) attribute4,
	   DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) attribute5,
	   DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) attribute6,
	   DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) attribute7,
	   DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) attribute8,
	   DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) attribute9,
	   DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) attribute10,
	   DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) attribute11,
	   DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) attribute12,
	   DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) attribute13,
	   DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) attribute14,
	   DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) attribute15,
	   DECODE(p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category) attribute_category
      FROM jtf_rs_teams_vl
	 WHERE team_id = l_team_id;

    team_rec      c_team_update%ROWTYPE;


    CURSOR c_related_role_dates_first(
	 l_team_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_TEAM'
	   AND role_resource_id = l_team_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is not null;


    CURSOR c_related_role_dates_sec(
	 l_team_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_TEAM'
	   AND role_resource_id = l_team_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is null;


    CURSOR c_team_mbr_role_dates_first(
	 l_team_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_team_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.team_id = l_team_id
	   AND jrrr.end_date_active is not null;


    CURSOR c_team_mbr_role_dates_sec(
	 l_team_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_team_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.team_id = l_team_id
	   AND jrrr.end_date_active is null;


    CURSOR c_exclusive_team_check(
	 l_team_id    IN  NUMBER )
    IS
	 SELECT 'Y'
      FROM jtf_rs_teams_vl T1,
        jtf_rs_teams_vl T2,
	   jtf_rs_team_members TM1,
	   jtf_rs_team_members TM2,
	   jtf_rs_team_usages TU1,
	   jtf_rs_team_usages TU2,
	   jtf_rs_role_relations RR1,
	   jtf_rs_role_relations RR2
      WHERE T1.team_id = TM1.team_id
	   AND T2.team_id = TM2.team_id
	   AND nvl(TM1.delete_flag, 'N') <> 'Y'
	   AND nvl(TM2.delete_flag, 'N') <> 'Y'
	   AND TM1.team_resource_id = TM2.team_resource_id
	   AND TM1.resource_type = TM2.resource_type
	   AND TM1.team_member_id = RR1.role_resource_id
	   AND TM2.team_member_id = RR2.role_resource_id
	   AND RR1.role_resource_type = 'RS_TEAM_MEMBER'
	   AND RR2.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(RR1.delete_flag, 'N') <> 'Y'
	   AND nvl(RR2.delete_flag, 'N') <> 'Y'
	   AND NOT (((RR2.end_date_active < RR1.start_date_active OR
			    RR2.start_date_active > RR1.end_date_active) AND
		         RR1.end_date_active IS NOT NULL)
		       OR (RR2.end_date_active < RR1.start_date_active AND
			      RR1.end_date_active IS NULL))
        AND T2.exclusive_flag = 'Y'
	   AND TU1.team_id = T1.team_id
	   AND TU2.team_id = T2.team_id
	   AND TU1.usage = TU2.usage
	   AND T1.team_id <> T2.team_id
	   AND T1.team_id = l_team_id;



  BEGIN


    SAVEPOINT update_resource_team_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Update Resource Team Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_team_cuhk.update_resource_team_pre(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_team_vuhk.update_resource_team_pre(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_team_iuhk.update_resource_team_pre(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;


    OPEN c_team_update(l_team_id);

    FETCH c_team_update INTO team_rec;


    IF c_team_update%NOTFOUND THEN

      IF c_team_update%ISOPEN THEN

        CLOSE c_team_update;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM');
	 fnd_message.set_token('P_TEAM_ID', l_team_id);
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Validate that the Team Name is specified */

    IF team_rec.team_name IS NULL THEN

--	 dbms_output.put_line('Team Name cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_TEAM_NAME_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    l_start_date_active := team_rec.start_date_active;
    l_end_date_active := team_rec.end_date_active;


    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Validate that the team dates cover the role related dates for the
	  team */

    /* First part of the validation where the role relate end date active
	  is not null */

    OPEN c_related_role_dates_first(l_team_id);

    FETCH c_related_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_START_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_END_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_first%ISOPEN THEN

      CLOSE c_related_role_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active
	  is null */

    OPEN c_related_role_dates_sec(l_team_id);

    FETCH c_related_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_START_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_END_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_sec%ISOPEN THEN

      CLOSE c_related_role_dates_sec;

    END IF;



    /* Validate that the team dates cover the team member role related dates for the
	  team */

    /* First part of the validation where the team member role relate end date active
	  is not null */

    OPEN c_team_mbr_role_dates_first(l_team_id);

    FETCH c_team_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_START_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_END_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active
	  is null */

    OPEN c_team_mbr_role_dates_sec(l_team_id);

    FETCH c_team_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_START_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_END_DATE');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_sec;

    END IF;



    /* If Team Exclusive Flag is checked then only those resources can be
       assigned to the team, who are not assigned to any other Exclusive team
       having the same USAGE value in that same time period. Validate that the
       passed values support the above condition for all the team members. */

    OPEN c_exclusive_team_check(l_team_id);

    FETCH c_exclusive_team_check INTO l_check_char;


    IF c_exclusive_team_check%FOUND THEN

--	 dbms_output.put_line('Team record cannot be updated as one of the member
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



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_teams_pkg.lock_row(
        x_team_id => l_team_id,
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


   /* update the wf roles with changes resource team
       this should be done before the chnages happens to
       the database since we need the old values */
    -- Don't care for its success status
    BEGIN
      jtf_rs_wf_integration_pub.update_resource_team
        (P_API_VERSION      => 1.0,
         P_TEAM_ID      =>  l_team_id,
         P_TEAM_NAME   => l_team_name,
         P_EMAIL_ADDRESS   => l_email_address,
         P_START_DATE_ACTIVE => l_start_date_active,
         P_END_DATE_ACTIVE  => l_end_date_active,
         X_RETURN_STATUS   => l_return_status,
         X_MSG_COUNT      => l_msg_count,
         X_MSG_DATA      => l_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;


    BEGIN


      /* Increment the object version number */

	 l_object_version_num := p_object_version_num + 1;


      /* Update the row into the table by calling the table handler. */

      jtf_rs_teams_pkg.update_row(
        x_team_id => l_team_id,
        x_team_number => team_rec.team_number,
        x_exclusive_flag => team_rec.exclusive_flag,
        x_email_address => team_rec.email_address,
        x_start_date_active => l_start_date_active,
        x_end_date_active => l_end_date_active,
        x_team_name => team_rec.team_name,
        x_team_desc => team_rec.team_desc,
	   x_object_version_number => l_object_version_num,
        x_attribute1 => team_rec.attribute1,
        x_attribute2 => team_rec.attribute2,
        x_attribute3 => team_rec.attribute3,
        x_attribute4 => team_rec.attribute4,
        x_attribute5 => team_rec.attribute5,
        x_attribute6 => team_rec.attribute6,
        x_attribute7 => team_rec.attribute7,
        x_attribute8 => team_rec.attribute8,
        x_attribute9 => team_rec.attribute9,
        x_attribute10 => team_rec.attribute10,
        x_attribute11 => team_rec.attribute11,
        x_attribute12 => team_rec.attribute12,
        x_attribute13 => team_rec.attribute13,
        x_attribute14 => team_rec.attribute14,
        x_attribute15 => team_rec.attribute15,
        x_attribute_category => team_rec.attribute_category,
        x_last_update_date => SYSDATE,
        x_last_updated_by => jtf_resource_utl.updated_by,
        x_last_update_login => jtf_resource_utl.login_id
      );


      /* Return the new value of the object version number */

      p_object_version_num := l_object_version_num;


    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

        IF c_team_update%ISOPEN THEN

          CLOSE c_team_update;

        END IF;

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_unexpected_error;

    END;

--    dbms_output.put_line('Team Successfully Updated');


    /* Close the cursors */

    IF c_team_update%ISOPEN THEN

      CLOSE c_team_update;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_team_cuhk.update_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_team_vuhk.update_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_team_iuhk.update_resource_team_post(
        p_team_id => l_team_id,
        p_team_name => l_team_name,
        p_team_desc => l_team_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
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
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_TEAMS_PVT',
	 'UPDATE_RESOURCE_TEAM',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_team_cuhk.ok_to_generate_msg(
	       p_team_id => l_team_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'team_id', l_team_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'TEAM',
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

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO update_resource_team_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Team Pvt ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO update_resource_team_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END update_resource_team;


END jtf_rs_teams_pvt;

/
