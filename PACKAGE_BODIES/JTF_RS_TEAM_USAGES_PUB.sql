--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_USAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_USAGES_PUB" AS
  /* $Header: jtfrspjb.pls 120.0 2005/05/11 08:21:12 appldev ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource team usages.
   Its main procedures are as following:
   Create Resource Team Usage
   Delete Resource Team Usage
   Calls to these procedures will invoke procedures from jtf_rs_team_usages_pvt
   to do business validations and to do actual inserts and updates into tables.
   ******************************************************************************************/


  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TEAM_USAGES_PUB';


  /* Procedure to create the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  create_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_USAGE_ID        OUT NOCOPY  JTF_RS_TEAM_USAGES.TEAM_USAGE_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_TEAM_USAGE';
    l_team_id                      jtf_rs_team_usages.team_id%TYPE := p_team_id;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE := p_team_number;
    l_usage                        jtf_rs_team_usages.usage%TYPE := p_usage;

    l_team_id_out                  jtf_rs_team_usages.team_id%TYPE;


  BEGIN


    SAVEPOINT create_rs_team_usage_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line('Started Create Resource Team Usage Pub ');


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
    l_team_id :=  l_team_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Validate the Resource Usage. */

    jtf_resource_utl.validate_usage
    (p_usage => l_usage,
     x_return_status => x_return_status
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Call the private procedure with the validated parameters. */

    jtf_rs_team_usages_pvt.create_team_usage
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_ID => l_team_id,
	P_USAGE => l_usage,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     X_TEAM_USAGE_ID => x_team_usage_id
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

      ROLLBACK TO create_rs_team_usage_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Team Usage Pub ========= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_rs_team_usage_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_team_usage;



  /* Procedure to delete the resource team usage
	based on input values passed by calling routines. */

  PROCEDURE  delete_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_USAGES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_TEAM_USAGE';
    l_team_id                      jtf_rs_team_usages.team_id%TYPE := p_team_id;
    l_team_number                  jtf_rs_teams_vl.team_number%TYPE := p_team_number;
    l_usage                        jtf_rs_team_usages.usage%TYPE := p_usage;

    l_team_id_out                  jtf_rs_team_usages.team_id%TYPE;


  BEGIN


    SAVEPOINT delete_team_usage_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Delete Team Usage Pub ');


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
      l_team_id := l_team_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Team Validation */



    /* Validate the Resource Usage. */

    jtf_resource_utl.validate_usage
    (p_usage => l_usage,
     x_return_status => x_return_status
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;



    /* Call the private procedure for delete */

    jtf_rs_team_usages_pvt.delete_team_usage
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_TEAM_ID => l_team_id,
     P_USAGE => l_usage,
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

      ROLLBACK TO delete_team_usage_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Team Usage Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO delete_team_usage_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_team_usage;


END jtf_rs_team_usages_pub;

/
