--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAMS_PUB" AS
  /* $Header: jtfrsptb.pls 120.0 2005/05/11 08:21:23 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource teams.
   Its main procedures are as following:
   Create Resource Team
   Update Resource Team
   This package validates the input parameters to these procedures and then
   Calls corresponding  procedures from jtf_rs_teams_pvt to do business
   validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TEAMS_PUB';


  /* Procedure to create the resource team and the members
	based on input values passed by calling routines. */


  PROCEDURE  create_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE   DEFAULT  NULL,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE   DEFAULT  'N',
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE   DEFAULT  NULL,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_ID              OUT NOCOPY  JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   X_TEAM_NUMBER          OUT NOCOPY  JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM';
    l_team_name                    jtf_rs_teams_vl.team_name%TYPE := p_team_name;
    l_team_desc                    jtf_rs_teams_vl.team_desc%TYPE := p_team_desc;
    l_exclusive_flag               jtf_rs_teams_vl.exclusive_flag%TYPE := nvl(p_exclusive_flag, 'N');
    l_email_address                jtf_rs_teams_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_teams_vl.start_date_active%TYPE := p_start_date_active;
    l_end_date_active              jtf_rs_teams_vl.end_date_active%TYPE := p_end_date_active;
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;
    current_record                 INTEGER;


  BEGIN


    SAVEPOINT create_resource_team_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Team Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate that the Team Name is specified */

    IF l_team_name IS NULL THEN

--	 dbms_output.put_line('Team Name cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_TEAM_NAME_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Validate that the Start Date Active is specified */

    IF l_start_date_active IS NULL THEN

--	 dbms_output.put_line('Start Date Active cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_START_DATE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Call the private procedure with the validated parameters. */

    jtf_rs_teams_pvt.create_resource_team
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_NAME => l_team_name,
     P_TEAM_DESC => l_team_desc,
     P_EXCLUSIVE_FLAG => l_exclusive_flag,
     P_EMAIL_ADDRESS => l_email_address,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     X_TEAM_ID => x_team_id,
     X_TEAM_NUMBER => x_team_number
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to private procedure');

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO create_resource_team_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Team Pub ========= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_resource_team_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_team;



  /* Procedure to update the resource team based on input values
	passed by calling routines. */

  PROCEDURE  update_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE   DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE   DEFAULT FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_TEAMS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_TEAM';
    l_team_id                      jtf_rs_teams_vl.team_id%TYPE := p_team_id;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE := p_team_number;
    l_team_name                    jtf_rs_teams_vl.team_name%TYPE := p_team_name;
    l_team_desc                    jtf_rs_teams_vl.team_desc%TYPE := p_team_desc;
    l_exclusive_flag               jtf_rs_teams_vl.exclusive_flag%TYPE := p_exclusive_flag;
    l_email_address                jtf_rs_teams_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_teams_vl.start_date_active%TYPE := p_start_date_active;
    l_end_date_active              jtf_rs_teams_vl.end_date_active%TYPE := p_end_date_active;
    l_object_version_num           jtf_rs_teams_vl.object_version_number%TYPE := p_object_version_num;
-- added for NOCOPY
    l_team_id_out                  jtf_rs_teams_vl.team_id%TYPE;

  BEGIN


    SAVEPOINT update_resource_team_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Update Resource Team Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate the Resource Team. */

    jtf_resource_utl.validate_resource_team(
      p_team_id => l_team_id,
      p_team_number => l_team_number,
      x_return_status => x_return_status,
      x_team_id => l_team_id_out
    );
-- added for NOCOPY
     l_team_id := l_team_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Call the private procedure with the validated parameters. */

    jtf_rs_teams_pvt.update_resource_team
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_ID => l_team_id,
     P_TEAM_NAME => l_team_name,
     P_TEAM_DESC => l_team_desc,
     P_EXCLUSIVE_FLAG => l_exclusive_flag,
     P_EMAIL_ADDRESS => l_email_address,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
	P_OBJECT_VERSION_NUM => l_object_version_num,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to private procedure');

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    /* Return the new value of the object version number */

    p_object_version_num := l_object_version_num;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  ======= ======== ');

      ROLLBACK TO update_resource_team_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Team Pub ========= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO update_resource_team_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END update_resource_team;


END jtf_rs_teams_pub;

/
