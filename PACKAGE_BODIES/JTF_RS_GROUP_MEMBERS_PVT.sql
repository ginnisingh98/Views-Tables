--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBERS_PVT" AS
  /* $Header: jtfrsvmb.pls 120.0 2005/05/11 08:23:08 appldev ship $ */

  /*****************************************************************************************
   This private package body defines the procedures for managing resource group members,
   like create and delete resource group members.
   Its main procedures are as following:
   Create Resource Group Members
   Delete Resource Group Members
   These procedures does the business validations and then Calls the corresponding
   table handlers to do actual inserts and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_GROUP_MEMBERS_PVT';


 /*Procedure to assign value to the global variable */
 PROCEDURE  assign_value_to_global
  (P_API_VERSION  IN NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
 )
 IS
    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'ASSIGN_VALUE_TO_GLOBAL';

 BEGIN
    SAVEPOINT assign_value_sp;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

   --assign the value;
   jtf_rs_group_members_pvt.g_moved_fr_group_id := p_group_id;

   EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO assign_value_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END assign_value_to_global;

  /* Procedure to create the resource group members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_MEMBER_ID      OUT NOCOPY JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP_MEMBERS';
    l_rowid                        ROWID;
    l_group_id                     jtf_rs_group_members.group_id%TYPE := p_group_id;
    l_resource_id                  jtf_rs_group_members.resource_id%type := p_resource_id;
    l_group_member_id              jtf_rs_group_members.group_member_id%TYPE;
    l_person_id                    jtf_rs_group_members.person_id%TYPE;
    l_check_char                   VARCHAR2(1);
    l_check_count                  NUMBER;
    l_bind_data_id                 NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;

    CURSOR c_jtf_rs_group_members( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_group_members
	 WHERE ROWID = l_rowid;


    CURSOR c_employee_person_id( l_resource_id   IN  NUMBER ) IS
      SELECT source_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_resource_id
	   AND category = 'EMPLOYEE';

    CURSOR c_is_active(l_group_id IN NUMBER, l_resource_id IN NUMBER) IS
      SELECT 'x'
      FROM JTF_RS_GROUPS_B a, JTF_RS_RESOURCE_EXTNS b
      WHERE a.group_id = l_group_id
       AND b.resource_id = l_resource_id
       AND trunc(sysdate) between a.start_date_active and nvl(a.end_date_active, sysdate)
       AND trunc(sysdate) between b.start_date_active and nvl(b.end_date_active, sysdate);

    is_active_flag c_is_active%rowtype;

    CURSOR c_jtf_rs_active_grp_mbrs( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_active_grp_mbrs
	 WHERE ROWID = l_rowid;


  BEGIN


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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.create_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	 --	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');

	fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.create_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.create_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;



    /* Validate that the resource is not an existing member of the group. */

    l_check_count := 0;

    SELECT count(*)
    INTO l_check_count
    FROM jtf_rs_group_members
    WHERE group_id = l_group_id
	 AND resource_id = l_resource_id
	 AND nvl(delete_flag,'N') <> 'Y';

    IF l_check_count > 0 THEN

--	 dbms_output.put_line('Resource already exists in the group');

	 x_return_status := fnd_api.g_ret_sts_error;

	 fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_EXISTS');
	 fnd_msg_pub.add;

	 RAISE fnd_api.g_exc_error;

    END IF;



    /* Get the Employee Person Id from the Resource Extension table. */

    OPEN c_employee_person_id(l_resource_id);

    FETCH c_employee_person_id INTO l_person_id;


    IF c_employee_person_id%NOTFOUND THEN

	 l_person_id := NULL;

    END IF;


    /* Get the next value of the Group_member_id from the sequence. */

    SELECT jtf_rs_group_members_s.nextval
    INTO l_group_member_id
    FROM dual;


    /* Make a call to the group member Audit API */

    jtf_rs_group_members_aud_pvt.insert_member
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_MEMBER_ID => l_group_member_id,
     P_GROUP_ID => l_group_id,
     P_RESOURCE_ID => l_resource_id,
     P_PERSON_ID => l_person_id,
	P_OBJECT_VERSION_NUMBER => 1,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;


    /* Insert the row into the table by calling the table handler. */

    jtf_rs_group_members_pkg.insert_row(
      x_rowid => l_rowid,
      x_group_member_id => l_group_member_id,
      x_group_id => l_group_id,
      x_resource_id => l_resource_id,
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

    OPEN c_jtf_rs_group_members(l_rowid);

    FETCH c_jtf_rs_group_members INTO l_check_char;


    IF c_jtf_rs_group_members%NOTFOUND THEN

--	 dbms_output.put_line('Error in Table Handler');


	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

	 IF c_jtf_rs_group_members%ISOPEN THEN

	    CLOSE c_jtf_rs_group_members;

	 END IF;

	 RAISE fnd_api.g_exc_error;

    ELSE

       OPEN C_IS_ACTIVE(l_group_id, l_resource_id);
       FETCH C_IS_ACTIVE INTO is_active_flag;

       IF c_is_active%FOUND THEN
	  /* Insert the row into the active group members table by
	  calling the table handler. */

          jtf_rs_active_grp_mbrs_pkg.insert_row(x_rowid => l_rowid,
						x_group_member_id => l_group_member_id,
						x_group_id => l_group_id,
						x_resource_id => l_resource_id,
						x_person_id => l_person_id,
						x_creation_date => SYSDATE,
						x_created_by => jtf_resource_utl.created_by,
						x_last_update_date => SYSDATE,
						x_last_updated_by => jtf_resource_utl.updated_by,
						x_last_update_login => jtf_resource_utl.login_id
						);


	  OPEN c_jtf_rs_active_grp_mbrs(l_rowid);

	  FETCH c_jtf_rs_active_grp_mbrs INTO l_check_char;


	  IF c_jtf_rs_active_grp_mbrs%NOTFOUND THEN

	     fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	     fnd_msg_pub.add;

	     IF c_jtf_rs_active_grp_mbrs%ISOPEN THEN

		CLOSE c_jtf_rs_active_grp_mbrs;

	     END IF;

	     RAISE fnd_api.g_exc_error;
	  END IF;
	  IF c_jtf_rs_active_grp_mbrs%ISOPEN THEN

	     CLOSE c_jtf_rs_active_grp_mbrs;

	  END IF;
       END IF;

       IF c_jtf_rs_group_members%ISOPEN THEN

	  CLOSE c_jtf_rs_group_members;

       END IF;
       x_group_member_id := l_group_member_id;

    END IF;


    /* Close the cursors */

    IF c_employee_person_id%ISOPEN THEN

      CLOSE c_employee_person_id;

    END IF;


    IF c_jtf_rs_group_members%ISOPEN THEN

      CLOSE c_jtf_rs_group_members;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.create_group_members_post(
	   p_group_member_id => l_group_member_id,
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.create_group_members_post(
	   p_group_member_id => l_group_member_id,
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.create_group_members_post(
	   p_group_member_id => l_group_member_id,
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'CREATE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_group_member_cuhk.ok_to_generate_msg(
	       p_group_member_id => l_group_member_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_member_id', l_group_member_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_GMBR',
		p_action_code => 'I',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');

          x_return_status := fnd_api.g_ret_sts_unexp_error;

	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;


	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        END IF;

      END IF;

    END IF;
    END IF;


    -- create wf_user_role record for the new group member
    -- Don't care for its success status
    BEGIN
      jtf_rs_wf_integration_pub.create_resource_group_members
	(P_API_VERSION      => 1.0,
	 P_RESOURCE_ID      =>  l_resource_id,
	 P_GROUP_ID   => l_group_id,
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


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_member_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_member_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_member_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_resource_group_members;


  /* Procedure to update the resource group members. */

  PROCEDURE  update_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_PERSON_ID            IN   JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
   P_DELETE_FLAG          IN   JTF_RS_GROUP_MEMBERS.DELETE_FLAG%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUP_MEMBERS.ATTRIBUTE_CATEGORY%TYPE,
   P_OBJECT_VERSION_NUMBER   IN OUT NOCOPY  JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  )
 IS
      l_api_version         	CONSTANT NUMBER := 1.0;
      l_api_name            	CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP_MEMBERS';
      l_group_member_id        	jtf_rs_group_members.group_member_id%type    	:= p_group_member_id;
      l_object_version_number   jtf_rs_group_members.object_version_number%type :=p_object_version_number;
      l_attribute1              jtf_rs_group_members.attribute1%type		:= p_attribute1;
      l_attribute2              jtf_rs_group_members.attribute2%type		:= p_attribute2;
      l_attribute3              jtf_rs_group_members.attribute3%type		:= p_attribute3;
      l_attribute4              jtf_rs_group_members.attribute4%type		:= p_attribute4;
      l_attribute5              jtf_rs_group_members.attribute5%type		:= p_attribute5;
      l_attribute6              jtf_rs_group_members.attribute6%type		:= p_attribute6;
      l_attribute7              jtf_rs_group_members.attribute7%type		:= p_attribute7;
      l_attribute8              jtf_rs_group_members.attribute8%type		:= p_attribute8;
      l_attribute9              jtf_rs_group_members.attribute9%type		:= p_attribute9;
      l_attribute10             jtf_rs_group_members.attribute10%type	:= p_attribute10;
      l_attribute11             jtf_rs_group_members.attribute11%type	:= p_attribute11;
      l_attribute12             jtf_rs_group_members.attribute12%type	:= p_attribute12;
      l_attribute13             jtf_rs_group_members.attribute13%type	:= p_attribute13;
      l_attribute14             jtf_rs_group_members.attribute14%type	:= p_attribute14;
      l_attribute15             jtf_rs_group_members.attribute15%type	:= p_attribute15;
      l_attribute_category      jtf_rs_group_members.attribute_category%type	:= p_attribute_category;


    l_bind_data_id                 NUMBER;

      CURSOR c_rs_group_members_update(l_group_member_id IN NUMBER) is
      SELECT
         DECODE(p_group_id, fnd_api.g_miss_num, group_id, p_group_id) l_group_id,
         DECODE(p_resource_id, fnd_api.g_miss_num, resource_id, p_resource_id) l_resource_id,
         DECODE(p_person_id, fnd_api.g_miss_num, person_id, p_person_id) l_person_id,
         DECODE(p_delete_flag, fnd_api.g_miss_char, delete_flag, p_delete_flag) l_delete_flag,
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
      FROM jtf_rs_group_members
      WHERE group_member_id = l_group_member_id;

    rs_group_member_rec c_rs_group_members_update%ROWTYPE;
 BEGIN
      SAVEPOINT update_rs_group_members_pvt;
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.update_group_members_pre(
        p_group_member_id => l_group_member_id,
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.update_group_members_pre(
        p_group_member_id => l_group_member_id,
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.update_group_members_pre(
        p_group_member_id => l_group_member_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

        x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;

    END IF;
    END IF;

   --Validate the group member for Update
      OPEN c_rs_group_members_update(l_group_member_id);
      FETCH c_rs_group_members_update INTO rs_group_member_rec;
      IF c_rs_group_members_update%NOTFOUND THEN
         CLOSE c_rs_group_members_update;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_GRP_MBR_ID');
         fnd_message.set_token('P_GRP_MBR_ID', p_group_member_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


   --Call the Lock Row Table Handler before updating the record
      jtf_rs_group_members_pkg.lock_row (
         X_GROUP_MEMBER_ID                      => l_group_member_id,
         X_OBJECT_VERSION_NUMBER        => l_object_version_number
      );

    /* Make a call to the group member Audit API */

    jtf_rs_group_members_aud_pvt.update_member
    (
     P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_MEMBER_ID => l_group_member_id,
     P_GROUP_ID   => rs_group_member_rec.l_group_id,
     P_RESOURCE_ID => rs_group_member_rec.l_resource_id,
     P_PERSON_ID => rs_group_member_rec.l_person_id,
     P_OBJECT_VERSION_NUMBER => l_object_version_number,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

   --Update the Object Version Number by Incrementing It
      l_object_version_number    := l_object_version_number+1;

   --Call the Table Handler to Update the Values in jtf_rs_role tables
   BEGIN
      jtf_rs_group_members_pkg.update_row (
         X_GROUP_MEMBER_ID              => l_group_member_id,
         X_ATTRIBUTE1           => rs_group_member_rec.l_attribute1,
         X_ATTRIBUTE2           => rs_group_member_rec.l_attribute2,
         X_ATTRIBUTE3           => rs_group_member_rec.l_attribute3,
         X_ATTRIBUTE4           => rs_group_member_rec.l_attribute4,
         X_ATTRIBUTE5           => rs_group_member_rec.l_attribute5,
         X_ATTRIBUTE6           => rs_group_member_rec.l_attribute6,
         X_ATTRIBUTE7           => rs_group_member_rec.l_attribute7,
         X_ATTRIBUTE8           => rs_group_member_rec.l_attribute8,
         X_ATTRIBUTE9           => rs_group_member_rec.l_attribute9,
         X_ATTRIBUTE10          => rs_group_member_rec.l_attribute10,
         X_ATTRIBUTE11          => rs_group_member_rec.l_attribute11,
         X_ATTRIBUTE12          => rs_group_member_rec.l_attribute12,
         X_ATTRIBUTE13          => rs_group_member_rec.l_attribute13,
         X_ATTRIBUTE14          => rs_group_member_rec.l_attribute14,
         X_ATTRIBUTE15          => rs_group_member_rec.l_attribute15,
         X_ATTRIBUTE_CATEGORY   => rs_group_member_rec.l_attribute_category,
         X_GROUP_ID            => rs_group_member_rec.l_group_id,
         X_RESOURCE_ID       => rs_group_member_rec.l_resource_id,
         X_PERSON_ID          => rs_group_member_rec.l_person_id,
         X_DELETE_FLAG        => rs_group_member_rec.l_delete_flag,
         X_OBJECT_VERSION_NUMBER=> l_object_version_number,
         X_LAST_UPDATE_DATE     => sysdate,
         X_LAST_UPDATED_BY	=> jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN	=> jtf_resource_utl.login_id
      );

      p_object_version_number := l_object_version_number;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         CLOSE c_rs_group_members_update;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
   END;

    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.update_group_members_post(
        p_group_member_id => l_group_member_id,
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.update_group_members_post(
        p_group_member_id => l_group_member_id,
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.update_group_members_post(
        p_group_member_id => l_group_member_id,
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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'UPDATE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_group_member_cuhk.ok_to_generate_msg(
	       p_group_member_id => l_group_member_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_member_id', l_group_member_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'GMBR',
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
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO update_rs_group_members_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Role Pub =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO update_rs_group_members_pvt;
         fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
         fnd_message.set_token('P_SQLCODE',SQLCODE);
         fnd_message.set_token('P_SQLERRM',SQLERRM);
         fnd_message.set_token('P_API_NAME',l_api_name);
         FND_MSG_PUB.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END;


  /* Procedure to delete the resource group members. */

  PROCEDURE  delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  )

  IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_GROUP_MEMBERS';
    l_group_id                     jtf_rs_group_members.group_id%TYPE := p_group_id;
    l_resource_id                  jtf_rs_group_members.resource_id%type := p_resource_id;
    l_check_char                   VARCHAR2(1);
    l_group_member_id              jtf_rs_group_members.group_member_id%TYPE;
    l_role_relate_count            NUMBER;
    l_bind_data_id                 NUMBER;

    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;


    CURSOR c_group_member_id(
	 l_group_id       IN  NUMBER,
	 l_resource_id    IN  NUMBER )
    IS
      SELECT group_member_id
      FROM jtf_rs_group_members
      WHERE group_id = l_group_id
	   AND resource_id = l_resource_id
	   AND nvl(delete_flag,'N') <> 'Y';


    CURSOR c_related_role_count(
	 l_group_member_id    IN  NUMBER)
    IS
	 SELECT count(*)
	 FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_GROUP_MEMBER'
	   AND role_resource_id = l_group_member_id
	   AND nvl(delete_flag,'N') <> 'Y';

/*	   removed the below where condition from above statement
           by baianand to check any active or expired role exists or not

           AND ( end_date_active is null OR end_date_active >= sysdate )
*/


  BEGIN


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
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.delete_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.delete_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'B',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.delete_group_members_pre(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Validate that the specified resource exists as a member of the
	  specified group */

    OPEN c_group_member_id(l_group_id, l_resource_id);

    FETCH c_group_member_id INTO l_group_member_id;


    IF c_group_member_id%NOTFOUND THEN

--	 dbms_output.put_line('Resource is not setup as a member of the Group');

      IF c_group_member_id%ISOPEN THEN

        CLOSE c_group_member_id;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_GROUP_MEMBER');
      fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


    /* Close the cursor */

    IF c_group_member_id%ISOPEN THEN

      CLOSE c_group_member_id;

    END IF;



    /* Validate that there are no associated roles with the group member
	  which are presently active or will be active in future */

    OPEN c_related_role_count(l_group_member_id);

    FETCH c_related_role_count INTO l_role_relate_count;


    IF c_related_role_count%NOTFOUND THEN

--	 dbms_output.put_line('Error in getting the count of the related role records');

      IF c_related_role_count%ISOPEN THEN

        CLOSE c_related_role_count;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_ERROR_ROLE_COUNT');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    ELSE

      IF l_role_relate_count > 0 THEN

--	   dbms_output.put_line('Active Role Related Records found');

        IF c_related_role_count%ISOPEN THEN

          CLOSE c_related_role_count;

        END IF;

        fnd_message.set_name('JTF', 'JTF_RS_ACTIVE_ROLE_EXIST');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_unexp_error;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_group_members_pkg.lock_row(
        x_group_member_id => l_group_member_id,
	   x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN

--	   dbms_output.put_line('Error in Locking the Row');

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_error;

    END;


    /* Make a call to the group member Audit API */

    jtf_rs_group_members_aud_pvt.delete_member
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_MEMBER_ID => l_group_member_id,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;



    /* Call the private procedure for logical delete */

    BEGIN

      -- delete wf_user_role record for the new group member
      -- Don't care for its success status
      BEGIN
	jtf_rs_wf_integration_pub.delete_resource_group_members
	  (P_API_VERSION      => 1.0,
	   P_RESOURCE_ID      =>  l_resource_id,
	   P_GROUP_ID   => l_group_id,
	   X_RETURN_STATUS   => l_return_status,
	   X_MSG_COUNT      => l_msg_count,
	   X_MSG_DATA      => l_msg_data);
      EXCEPTION
	WHEN OTHERS THEN
	  NULL;
      END;

      /* Delete the row into the table by calling the table handler. */

      jtf_rs_group_members_pkg.logical_delete_row(
        x_group_member_id => l_group_member_id
      );

      -- Delete record in active group members table
      BEGIN
	jtf_rs_active_grp_mbrs_pkg.delete_row(
	  x_group_member_id => l_group_member_id
	);
      EXCEPTION
	 WHEN no_data_found THEN
	    NULL;
      END;

    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

	   RAISE fnd_api.g_exc_error;

    END;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'C')
    THEN

      jtf_rs_group_member_cuhk.delete_group_members_post(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'V')
    THEN

      jtf_rs_group_member_vuhk.delete_group_members_post(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'A',
	 'I')
    THEN

      jtf_rs_group_member_iuhk.delete_group_members_post(
        p_group_id => l_group_id,
        p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;


	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUP_MEMBERS_PVT',
	 'DELETE_RESOURCE_GROUP_MEMBERS',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_group_member_cuhk.ok_to_generate_msg(
	       p_group_member_id => l_group_member_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_member_id', l_group_member_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'GMBR',
		p_action_code => 'D',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');

	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;


	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_resource_member_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_resource_member_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_resource_member_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END delete_resource_group_members;


    /* Procedure to move member hook  */

  PROCEDURE  execute_sales_hook
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_OLD_GROUP_ID         IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_NEW_GROUP_ID         IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_OLD_START_DATE       IN   DATE,
   P_OLD_END_DATE         IN   DATE,
   P_NEW_START_DATE       IN   DATE,
   P_NEW_END_DATE         IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  )

  IS

  BEGIN

     null;

  END execute_sales_hook;


END jtf_rs_group_members_pvt;

/
