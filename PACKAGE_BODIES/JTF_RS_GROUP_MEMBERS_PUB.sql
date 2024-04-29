--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBERS_PUB" AS
  /* $Header: jtfrspmb.pls 120.0 2005/05/11 08:21:16 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource group members, like
   create, update and delete resource group members.
   Its main procedures are as following:
   Create Resource Group Members
   Delete Resource Group Members
   This package validates the input parameters to these procedures and then
   Calls corresponding  procedures from jtf_rs_group_members_pvt
   to do business validations and to do actual inserts and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_GROUP_MEMBERS_PUB';


  /* Procedure to create the resource group members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_MEMBER_ID      OUT NOCOPY  JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE
  ) IS


    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP_MEMBERS';
    l_group_id                     jtf_rs_group_members.group_id%TYPE := p_group_id;
    l_group_number                 jtf_rs_groups_vl.group_number%TYPE := p_group_number;
    l_resource_id                  jtf_rs_group_members.resource_id%type := p_resource_id;
    l_resource_number              jtf_rs_resource_extns.resource_number%type := p_resource_number;
    l_group_member_id              jtf_rs_group_members.group_member_id%TYPE;

    l_group_id_out                     jtf_rs_group_members.group_id%TYPE;
    l_resource_id_out                  jtf_rs_group_members.resource_id%type;

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


    /* Validate the Resource Group. */

    BEGIN

      jtf_resource_utl.validate_resource_group(
        p_group_id => l_group_id,
        p_group_number => l_group_number,
        x_return_status => x_return_status,
        x_group_id => l_group_id_out
      );
-- added for NOCOPY
      l_group_id := l_group_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Group Validation */



    /* Validate the Resource */

    BEGIN

      jtf_resource_utl.validate_resource_number(
        p_resource_id => l_resource_id,
        p_resource_number => l_resource_number,
        x_return_status => x_return_status,
        x_resource_id => l_resource_id_out
      );

-- added for NOCOPY
      l_resource_id := l_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Validation */



    jtf_rs_group_members_pvt.create_resource_group_members
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     P_RESOURCE_ID => l_resource_id,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     X_GROUP_MEMBER_ID => x_group_member_id
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

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Group Member Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO create_resource_member_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END create_resource_group_members;


  /* Procedure to update the resource group members
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS


    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP_MEMBERS';
    l_group_id                     jtf_rs_group_members.group_id%TYPE := p_group_id;
    l_group_number                 jtf_rs_groups_vl.group_number%TYPE := p_group_number;
    l_resource_id                  jtf_rs_group_members.resource_id%type := p_resource_id;
    l_resource_number              jtf_rs_resource_extns.resource_number%type := p_resource_number;
    l_group_member_id              jtf_rs_group_members.group_member_id%TYPE := p_group_member_id;

    l_group_id_out                     jtf_rs_group_members.group_id%TYPE;
    l_resource_id_out                  jtf_rs_group_members.resource_id%type;

  BEGIN


    SAVEPOINT update_resource_member_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Update Resource Member Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate the Resource Group. */

    BEGIN

      jtf_resource_utl.validate_resource_group(
        p_group_id => l_group_id,
        p_group_number => l_group_number,
        x_return_status => x_return_status,
        x_group_id => l_group_id_out
      );
-- added for NOCOPY
      l_group_id := l_group_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Group Validation */



    /* Validate the Resource */

    BEGIN

      jtf_resource_utl.validate_resource_number(
        p_resource_id => l_resource_id,
        p_resource_number => l_resource_number,
        x_return_status => x_return_status,
        x_resource_id => l_resource_id_out
      );
-- added for NOCOPY
      l_resource_id := l_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Validation */



    jtf_rs_group_members_pvt.update_resource_group_members
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_MEMBER_ID => l_group_member_id,
     P_GROUP_ID => l_group_id,
     P_RESOURCE_ID => l_resource_id,
     P_OBJECT_VERSION_NUMBER => p_object_version_number,
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

      ROLLBACK TO update_resource_member_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    WHEN OTHERS THEN

--      DBMS_OUTPUT.put_line (' ========================================== ');

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Group Member Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO update_resource_member_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END update_resource_group_members;



  /* Procedure to delete the resource group members. */

  PROCEDURE  delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_GROUP_MEMBERS';
    l_group_id                     jtf_rs_group_members.group_id%TYPE := p_group_id;
    l_group_number                 jtf_rs_groups_vl.group_number%TYPE := p_group_number;
    l_resource_id                  jtf_rs_group_members.resource_id%type := p_resource_id;
    l_resource_number              jtf_rs_resource_extns.resource_number%type := p_resource_number;
    l_group_member_id              jtf_rs_group_members.group_member_id%TYPE;
    l_group_id_out                 jtf_rs_group_members.group_id%TYPE;
    l_resource_id_out              jtf_rs_group_members.resource_id%type;


    CURSOR c_resource_id IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = p_resource_id;

    CURSOR c_resource_number IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_number = p_resource_number;

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


    /* Validate the Resource Group. */

    BEGIN

      jtf_resource_utl.validate_resource_group(
        p_group_id => l_group_id,
        p_group_number => l_group_number,
        x_return_status => x_return_status,
        x_group_id => l_group_id_out
      );
-- added for NOCOPY
      l_group_id := l_group_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END; /* End of Resource Group Validation */



    /* Validate the Resource Number. */

    BEGIN

    IF p_resource_id IS NULL AND p_resource_number is NULL THEN


      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    IF p_resource_id IS NOT NULL THEN
      OPEN c_resource_id;

      FETCH c_resource_id INTO l_resource_id;

      IF c_resource_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', p_resource_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      CLOSE c_resource_id;

    ELSIF p_resource_number IS NOT NULL THEN

      OPEN c_resource_number;

      FETCH c_resource_number INTO l_resource_id;

      IF c_resource_number%NOTFOUND THEN


        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_NUMBER');
        fnd_message.set_token('P_RESOURCE_NUMBER', p_resource_number);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

      CLOSE c_resource_number;

      END IF; /* End of Resource Number Validation */

     END;

    /* Call the private procedure for delete */

    jtf_rs_group_members_pvt.delete_resource_group_members
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     P_RESOURCE_ID => l_resource_id,
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

--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Group Member Pub ============= ');

--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO delete_resource_member_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_resource_group_members;



END jtf_rs_group_members_pub;

/
