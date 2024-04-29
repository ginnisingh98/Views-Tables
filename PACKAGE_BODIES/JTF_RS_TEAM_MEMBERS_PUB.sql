--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_MEMBERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_MEMBERS_PUB" AS
  /* $Header: jtfrspeb.pls 120.0 2005/05/11 08:21:06 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource team members, like
   create, update and delete resource team members.
   Its main procedures are as following:
   Create Resource Team Members
   Update Resource Team Members
   Delete Resource Team Members
   This package validates the input parameters to these procedures and then
   Calls corresponding  procedures from jtf_rs_team_members_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TEAM_MEMBERS_PUB';


  /* Procedure to create the resource team members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_TEAM_RESOURCE_NUMBER IN   NUMBER,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_MEMBER_ID       OUT NOCOPY  JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM_MEMBERS';
    l_team_id                      jtf_rs_team_members.team_id%TYPE := p_team_id;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE := p_team_number;
    l_team_resource_id             jtf_rs_team_members.team_resource_id%TYPE := p_team_resource_id;
    l_team_resource_number         NUMBER := p_team_resource_number;
    l_resource_type                jtf_rs_team_members.resource_type%TYPE := upper(p_resource_type);
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;

    l_team_id_out                  jtf_rs_team_members.team_id%TYPE;
    l_team_resource_id_out             jtf_rs_team_members.team_resource_id%TYPE;

  BEGIN


    SAVEPOINT create_resource_member_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Member Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate the Resource Team. */

    BEGIN

      jtf_resource_utl.validate_resource_team(
        p_team_id => l_team_id,
        p_team_number => l_team_number,
        x_return_status => x_return_status,
        x_team_id => l_team_id_out
      );

-- added for NOCOPY
      l_team_id :=  l_team_id_out;


      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Team Validation */



    /* Validate the Resource Type */

    IF l_resource_type NOT IN ('GROUP', 'INDIVIDUAL') THEN

--	 dbms_output.put_line('Resource Type can only be Group or Resource');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_TYPE');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Validate the Team Resource */

    IF l_resource_type = 'INDIVIDUAL' then

      jtf_resource_utl.validate_resource_number(
        p_resource_id => l_team_resource_id,
        p_resource_number => l_team_resource_number,
        x_return_status => x_return_status,
        x_resource_id => l_team_resource_id_out
      );
 -- added for NOCOPY
      l_team_resource_id := l_team_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF; /* End of Resource Validation */


    IF l_resource_type = 'GROUP' then

      jtf_resource_utl.validate_resource_group(
        p_group_id => l_team_resource_id,
        p_group_number => l_team_resource_number,
        x_return_status => x_return_status,
        x_group_id => l_team_resource_id_out
      );

 -- added for NOCOPY
      l_team_resource_id := l_team_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF; /* End of Resource Validation */


    jtf_rs_team_members_pvt.create_resource_team_members
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_ID => l_team_id,
     P_TEAM_RESOURCE_ID => l_team_resource_id,
     P_RESOURCE_TYPE => l_resource_type,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     X_TEAM_MEMBER_ID => x_team_member_id
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

      ROLLBACK TO create_resource_member_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Team Member Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_resource_member_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_team_members;




  /* Procedure to delete the resource team members. */

  PROCEDURE  delete_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_TEAM_RESOURCE_NUMBER IN   NUMBER,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_TEAM_MEMBERS';
    l_team_id                      jtf_rs_team_members.team_id%TYPE := p_team_id;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE := p_team_number;
    l_team_resource_id             jtf_rs_team_members.team_resource_id%TYPE := p_team_resource_id;
    l_team_resource_number         NUMBER := p_team_resource_number;
    l_resource_type                jtf_rs_team_members.resource_type%TYPE := upper(p_resource_type);
    l_team_member_id               jtf_rs_team_members.team_member_id%TYPE;
 --added for NOCOPY
    l_team_id_out                  jtf_rs_team_members.team_id%TYPE;
    l_team_resource_id_out             jtf_rs_team_members.team_resource_id%TYPE;


  BEGIN


    SAVEPOINT delete_resource_member_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Delete Resource Member Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;



    /* Validate the Resource Team. */

    BEGIN

      jtf_resource_utl.validate_resource_team(
        p_team_id => l_team_id,
        p_team_number => l_team_number,
        x_return_status => x_return_status,
        x_team_id => l_team_id_out
      );
 --  added for NOCOPY
     l_team_id := l_team_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Team Validation */



    /* Validate the Resource Type */

    IF l_resource_type NOT IN ('GROUP', 'INDIVIDUAL') THEN

--	 dbms_output.put_line('Resource Type can only be Group or Resource');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_TYPE');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    /* Validate the Team Resource */

    IF l_resource_type = 'INDIVIDUAL' then

      jtf_resource_utl.validate_resource_number(
        p_resource_id => l_team_resource_id,
        p_resource_number => l_team_resource_number,
        x_return_status => x_return_status,
        x_resource_id => l_team_resource_id_out
      );
-- added for NOCOPY
      l_team_resource_id := l_team_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF; /* End of Resource Validation */


    IF l_resource_type = 'GROUP' then

      jtf_resource_utl.validate_resource_group(
        p_group_id => l_team_resource_id,
        p_group_number => l_team_resource_number,
        x_return_status => x_return_status,
        x_group_id => l_team_resource_id_out
      );

-- added for NOCOPY
      l_team_resource_id := l_team_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF; /* End of Resource Validation */



    /* Call the private procedure for delete */

    jtf_rs_team_members_pvt.delete_resource_team_members
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_ID => l_team_id,
     P_TEAM_RESOURCE_ID => l_team_resource_id,
     P_RESOURCE_TYPE => l_resource_type,
     P_OBJECT_VERSION_NUM => p_object_version_num,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
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

      ROLLBACK TO delete_resource_member_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Team Member Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO delete_resource_member_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_resource_team_members;



END jtf_rs_team_members_pub;

/
