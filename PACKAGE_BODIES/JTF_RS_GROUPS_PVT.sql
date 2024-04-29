--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUPS_PVT" AS
  /* $Header: jtfrsvgb.pls 120.0.12010000.3 2009/08/05 08:01:37 rgokavar ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resource groups.
   Its main procedures are as following:
   Create Resource Group Members
   Update Resource Group Members
   These procedures do the business validations and then call the appropriate
   table handlers to do the actual inserts and updates.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_GROUPS_PVT';


  /* Procedure to create the resource group and the members
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUPS_VL.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_GROUPS_VL.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_GROUPS_VL.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_GROUPS_VL.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_GROUPS_VL.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_GROUPS_VL.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_GROUPS_VL.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_GROUPS_VL.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_GROUPS_VL.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_GROUPS_VL.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_GROUPS_VL.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_GROUPS_VL.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_GROUPS_VL.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_GROUPS_VL.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_GROUPS_VL.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUPS_VL.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_ID             OUT NOCOPY  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   X_GROUP_NUMBER         OUT NOCOPY  JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_TIME_ZONE            IN   JTF_RS_GROUPS_VL.TIME_ZONE%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP';
    l_rowid                        ROWID;
    l_group_name                   jtf_rs_groups_vl.group_name%TYPE := p_group_name;
    l_group_desc                   jtf_rs_groups_vl.group_desc%TYPE := p_group_desc;
    l_exclusive_flag               jtf_rs_groups_vl.exclusive_flag%TYPE := p_exclusive_flag;
    l_email_address                jtf_rs_groups_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_groups_vl.start_date_active%TYPE := trunc(p_start_date_active);
    l_end_date_active              jtf_rs_groups_vl.end_date_active%TYPE := trunc(p_end_date_active);
    l_accounting_code              jtf_rs_groups_vl.accounting_code%TYPE := p_accounting_code;
    l_group_id                     jtf_rs_groups_vl.group_id%TYPE;
    l_group_number                 jtf_rs_groups_vl.group_number%TYPE;
    l_check_char                   VARCHAR2(1);
    l_check_dup_id                 VARCHAR2(1);
    l_bind_data_id                 NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;
    l_time_zone                    jtf_rs_groups_vl.time_zone%TYPE := p_time_zone;

    CURSOR c_jtf_rs_groups( l_rowid IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_groups_b
	 WHERE ROWID = l_rowid;

    CURSOR c_dup_group_id (l_group_id IN jtf_rs_groups_vl.group_id%type) IS
        SELECT 'X'
        FROM jtf_rs_groups_vl
        WHERE group_id = l_group_id;

  BEGIN

    SAVEPOINT create_resource_group_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Group Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_group_cuhk.create_resource_group_pre(
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

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
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_group_vuhk.create_resource_group_pre(
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_group_iuhk.create_resource_group_pre(
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');


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


    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

      /* validate Exclusive flag value */
      /*
      Bug#8708207
      Below block to validate Exclusive Flag
      value before creating Resource Group.
      */

      IF l_exclusive_flag <> 'Y' AND l_exclusive_flag <> 'N' THEN
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

   /* This portion of the code was modified to accomodate the calls to Migration API */
   /* Check if the Global Variable Flag for Group ID is Y or N */

--     dbms_output.put_line ('Before checkin the Global flag in PVT API');

      IF G_RS_GRP_ID_PVT_FLAG = 'Y' THEN

        /* Get the next value of the Group ID from the sequence. */

           LOOP
              SELECT jtf_rs_groups_s.nextval
              INTO l_group_id
              FROM dual;
              --dbms_output.put_line ('After Select - Group ID ' || l_group_id);

              OPEN c_dup_group_id (l_group_id);
              FETCH c_dup_group_id INTO l_check_dup_id;
              EXIT WHEN c_dup_group_id%NOTFOUND;
              CLOSE c_dup_group_id;
           END LOOP;
           CLOSE c_dup_group_id;

     ELSE
        l_group_id           := JTF_RS_GROUPS_PUB.G_GROUP_ID;

    END IF;

    /* Get the next value of the Group number from the sequence. */

        SELECT jtf_rs_group_number_s.nextval
        INTO l_group_number
        FROM dual;

    /* Make a call to the group Audit API */

    jtf_rs_groups_aud_pvt.insert_group
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     P_GROUP_NUMBER => l_group_number,
     P_GROUP_NAME => l_group_name,
     P_GROUP_DESC => l_group_desc,
     P_EXCLUSIVE_FLAG => l_exclusive_flag,
     P_EMAIL_ADDRESS => l_email_address,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
     P_ACCOUNTING_CODE => l_accounting_code,
     P_OBJECT_VERSION_NUMBER => 1,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     P_TIME_ZONE => l_time_zone
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

    jtf_rs_groups_pkg.insert_row(
      x_rowid => l_rowid,
      x_group_id => l_group_id,
      x_group_number => l_group_number,
      x_exclusive_flag => l_exclusive_flag,
      x_email_address => l_email_address,
      x_start_date_active => l_start_date_active,
      x_end_date_active => l_end_date_active,
      x_group_name => l_group_name,
      x_group_desc => l_group_desc,
      x_accounting_code => l_accounting_code,
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
      x_last_update_login => jtf_resource_utl.login_id,
      x_time_zone => l_time_zone
    );


--    dbms_output.put_line('Inserted Row');

    OPEN c_jtf_rs_groups(l_rowid);

    FETCH c_jtf_rs_groups INTO l_check_char;


    IF c_jtf_rs_groups%NOTFOUND THEN

--	 dbms_output.put_line('Error in Table Handler');

      IF c_jtf_rs_groups%ISOPEN THEN

        CLOSE c_jtf_rs_groups;

      END IF;


	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;

         RAISE fnd_api.g_exc_error;


    ELSE

--	 dbms_output.put_line('Group Successfully Created');

	 x_group_id := l_group_id;

	 x_group_number := l_group_number;

    END IF;


    /* Close the cursors */

    IF c_jtf_rs_groups%ISOPEN THEN

      CLOSE c_jtf_rs_groups;

    END IF;


    /* Make a call to the Group Denorm API */

    jtf_rs_group_denorm_pvt.create_res_groups
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to Group Denorm procedure');

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;



    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_group_cuhk.create_resource_group_post(
	   p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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


    /* Post Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_group_vuhk.create_resource_group_post(
	   p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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


    /* Post Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_group_iuhk.create_resource_group_post(
	   p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;


    /* Standard call for Message Generation */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'CREATE_RESOURCE_GROUP',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_group_cuhk.ok_to_generate_msg(
	       p_group_id => l_group_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_id', l_group_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'JTF_GRP',
		p_action_code => 'I',
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

    -- create the wf roles with new resource group
    -- Don't care for its success status
    BEGIN
      jtf_rs_wf_integration_pub.create_resource_group
	(P_API_VERSION      => 1.0,
	 P_GROUP_ID      =>  l_group_id,
	 P_GROUP_NAME   => l_group_name,
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


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_group_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_group_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_group_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_resource_group;

 PROCEDURE  create_resource_group_migrate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUPS_VL.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_GROUPS_VL.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_GROUPS_VL.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_GROUPS_VL.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_GROUPS_VL.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_GROUPS_VL.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_GROUPS_VL.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_GROUPS_VL.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_GROUPS_VL.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_GROUPS_VL.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_GROUPS_VL.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_GROUPS_VL.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_GROUPS_VL.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_GROUPS_VL.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_GROUPS_VL.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUPS_VL.ATTRIBUTE_CATEGORY%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_ID             OUT NOCOPY  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   X_GROUP_NUMBER         OUT NOCOPY  JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_TIME_ZONE            IN   JTF_RS_GROUPS_VL.TIME_ZONE%TYPE
  ) IS

   BEGIN

     G_RS_GRP_ID_PVT_FLAG   := 'N';

     jtf_rs_groups_pvt.create_resource_group (
     	P_API_VERSION         => P_API_VERSION,
   	P_INIT_MSG_LIST       => P_INIT_MSG_LIST,
   	P_COMMIT              => P_COMMIT,
   	P_GROUP_NAME          => P_GROUP_NAME,
   	P_GROUP_DESC          => P_GROUP_DESC,
   	P_EXCLUSIVE_FLAG      => P_EXCLUSIVE_FLAG,
   	P_EMAIL_ADDRESS       => P_EMAIL_ADDRESS,
   	P_START_DATE_ACTIVE   => P_START_DATE_ACTIVE,
   	P_END_DATE_ACTIVE     => P_END_DATE_ACTIVE,
   	P_ACCOUNTING_CODE     => P_ACCOUNTING_CODE,
   	P_ATTRIBUTE1          => P_ATTRIBUTE1,
   	P_ATTRIBUTE2          => P_ATTRIBUTE2,
   	P_ATTRIBUTE3          => P_ATTRIBUTE3,
   	P_ATTRIBUTE4          => P_ATTRIBUTE4,
   	P_ATTRIBUTE5          => P_ATTRIBUTE5,
   	P_ATTRIBUTE6          => P_ATTRIBUTE6,
   	P_ATTRIBUTE7          => P_ATTRIBUTE7,
   	P_ATTRIBUTE8          => P_ATTRIBUTE8,
   	P_ATTRIBUTE9          => P_ATTRIBUTE9,
   	P_ATTRIBUTE10         => P_ATTRIBUTE10,
   	P_ATTRIBUTE11         => P_ATTRIBUTE11,
   	P_ATTRIBUTE12         => P_ATTRIBUTE12,
   	P_ATTRIBUTE13         => P_ATTRIBUTE13,
   	P_ATTRIBUTE14         => P_ATTRIBUTE14,
   	P_ATTRIBUTE15         => P_ATTRIBUTE15,
   	P_ATTRIBUTE_CATEGORY  => P_ATTRIBUTE_CATEGORY,
   	X_RETURN_STATUS       => X_RETURN_STATUS,
   	X_MSG_COUNT           => X_MSG_COUNT,
   	X_MSG_DATA            => X_MSG_DATA,
   	X_GROUP_ID            => X_GROUP_ID,
   	X_GROUP_NUMBER        => X_GROUP_NUMBER,
      P_TIME_ZONE           => P_TIME_ZONE
    );

  END create_resource_group_migrate;

  /* Procedure to update the resource group based on input values
	passed by calling routines. */

  PROCEDURE  update_resource_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
   P_GROUP_NAME           IN   JTF_RS_GROUPS_VL.GROUP_NAME%TYPE,
   P_GROUP_DESC           IN   JTF_RS_GROUPS_VL.GROUP_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_GROUPS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_GROUPS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GROUPS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GROUPS_VL.END_DATE_ACTIVE%TYPE,
   P_ACCOUNTING_CODE      IN   JTF_RS_GROUPS_VL.ACCOUNTING_CODE%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_GROUPS_VL.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_GROUPS_VL.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_GROUPS_VL.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_GROUPS_VL.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_GROUPS_VL.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_GROUPS_VL.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_GROUPS_VL.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_GROUPS_VL.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_GROUPS_VL.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_GROUPS_VL.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_GROUPS_VL.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_GROUPS_VL.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_GROUPS_VL.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_GROUPS_VL.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_GROUPS_VL.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_GROUPS_VL.ATTRIBUTE_CATEGORY%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   P_TIME_ZONE            IN   JTF_RS_GROUPS_VL.TIME_ZONE%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP';
    l_group_id                     jtf_rs_groups_vl.group_id%TYPE := p_group_id;
    l_group_name                   jtf_rs_groups_vl.group_name%TYPE := p_group_name;
    l_group_desc                   jtf_rs_groups_vl.group_desc%TYPE := p_group_desc;
    l_exclusive_flag               jtf_rs_groups_vl.exclusive_flag%TYPE := p_exclusive_flag;
    l_email_address                jtf_rs_groups_vl.email_address%TYPE := p_email_address;
    l_start_date_active            jtf_rs_groups_vl.start_date_active%TYPE := trunc(p_start_date_active);
    l_end_date_active              jtf_rs_groups_vl.end_date_active%TYPE := trunc(p_end_date_active);
    l_accounting_code              jtf_rs_groups_vl.accounting_code%TYPE := p_accounting_code;
    l_object_version_num           jtf_rs_groups_vl.object_version_number%type := p_object_version_num;
    l_time_zone                    jtf_rs_groups_vl.time_zone%TYPE := p_time_zone;

    l_max_end_date                 DATE;
    l_min_start_date               DATE;
    l_check_char                   VARCHAR2(1);
    l_bind_data_id                 NUMBER;


    CURSOR c_group_update(
	 l_group_id       IN  NUMBER )
    IS
	 SELECT
	   group_number,
	   DECODE(p_group_name, fnd_api.g_miss_char, group_name, p_group_name) group_name,
	   DECODE(p_group_desc, fnd_api.g_miss_char, group_desc, p_group_desc) group_desc,
	   DECODE(p_exclusive_flag, fnd_api.g_miss_char, exclusive_flag, NULL, 'N', p_exclusive_flag) exclusive_flag,
	   DECODE(p_email_address, fnd_api.g_miss_char, email_address, p_email_address) email_address,
	   DECODE(p_start_date_active, fnd_api.g_miss_date, start_date_active, trunc(p_start_date_active)) start_date_active,
	   DECODE(p_end_date_active, fnd_api.g_miss_date, end_date_active, trunc(p_end_date_active)) end_date_active,
	   DECODE(p_accounting_code, fnd_api.g_miss_char, accounting_code, p_accounting_code) accounting_code,
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
	   DECODE(p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category) attribute_category,
         DECODE(p_time_zone,fnd_api.g_miss_num,time_zone,p_time_zone) time_zone
      FROM jtf_rs_groups_vl
	 WHERE group_id = l_group_id;

    group_rec      c_group_update%ROWTYPE;


    CURSOR c_related_role_dates_first(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_GROUP'
	   AND role_resource_id = l_group_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is not null;


    CURSOR c_related_role_dates_sec(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_GROUP'
	   AND role_resource_id = l_group_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is null;


    CURSOR c_grp_mbr_role_dates_first(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
                max(jrrr.end_date_active)
           FROM jtf_rs_group_members jrgm,
	        jtf_rs_role_relations jrrr
          WHERE jrgm.group_member_id = jrrr.role_resource_id
	    AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
	    AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	    AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	    AND jrgm.group_id = l_group_id
	    AND jrrr.end_date_active is not null;


    CURSOR c_grp_mbr_role_dates_sec(
	 l_group_id    IN  NUMBER )
    IS
     SELECT min(jrrr.start_date_active)
       FROM jtf_rs_group_members jrgm,
            jtf_rs_role_relations jrrr
      WHERE jrgm.group_member_id = jrrr.role_resource_id
        AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
        AND nvl(jrrr.delete_flag, 'N') <> 'Y'
        AND nvl(jrgm.delete_flag, 'N') <> 'Y'
        AND jrgm.group_id = l_group_id
        AND jrrr.end_date_active is null;


    CURSOR c_related_group_dates_first(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_grp_relations
	 WHERE ( group_id = l_group_id
	   OR related_group_id = l_group_id )
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is not null;


    CURSOR c_related_group_dates_sec(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_grp_relations
	 WHERE ( group_id = l_group_id
	   OR related_group_id = l_group_id )
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is null;


    CURSOR c_team_mbr_role_dates_first(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_group_id
	   AND jrtm.resource_type = 'RS_GROUP'
	   AND jrrr.end_date_active is not null;


    CURSOR c_team_mbr_role_dates_sec(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_group_id
	   AND jrtm.resource_type = 'RS_GROUP'
	   AND jrrr.end_date_active is null;


    CURSOR c_exclusive_group_check(
	 l_group_id    IN  NUMBER )
    IS
	 SELECT 'Y'
      FROM jtf_rs_groups_vl G1,
        jtf_rs_groups_vl G2,
	   jtf_rs_group_members GM1,
	   jtf_rs_group_members GM2,
	   jtf_rs_group_usages GU1,
	   jtf_rs_group_usages GU2,
	   jtf_rs_role_relations RR1,
	   jtf_rs_role_relations RR2
      WHERE G1.group_id = GM1.group_id
	   AND G2.group_id = GM2.group_id
	   AND nvl(GM1.delete_flag, 'N') <> 'Y'
	   AND nvl(GM2.delete_flag, 'N') <> 'Y'
	   AND GM1.resource_id = GM2.resource_id
	   AND GM1.group_member_id = RR1.role_resource_id
	   AND GM2.group_member_id = RR2.role_resource_id
	   AND RR1.role_resource_type = 'RS_GROUP_MEMBER'
	   AND RR2.role_resource_type = 'RS_GROUP_MEMBER'
	   AND nvl(RR1.delete_flag, 'N') <> 'Y'
	   AND nvl(RR2.delete_flag, 'N') <> 'Y'
	   /*AND NOT (((RR2.end_date_active < RR1.start_date_active OR
			    RR2.start_date_active > RR1.end_date_active) AND
		         RR1.end_date_active IS NOT NULL)
		       OR (RR2.end_date_active < RR1.start_date_active AND
			      RR1.end_date_active IS NULL)) */
         AND not (((nvl(RR1.end_date_active,RR2.start_date_active + 1) < RR2.start_date_active OR
                   RR1.start_date_active > RR2.end_date_active) AND
                   RR2.end_date_active IS NOT NULL)
                 OR ( nvl(RR1.end_date_active,RR2.start_date_active + 1) < RR2.start_date_active AND
                     RR2.end_date_active IS NULL ))
        AND G2.exclusive_flag = 'Y'
	   AND GU1.group_id = G1.group_id
	   AND GU2.group_id = G2.group_id
	   AND GU1.usage = GU2.usage
	   AND G1.group_id <> G2.group_id
	   AND G1.group_id = l_group_id;


    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;

  BEGIN


    SAVEPOINT update_resource_group_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Update Resource Group Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;

    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_group_cuhk.update_resource_group_pre(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_group_vuhk.update_resource_group_pre(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_group_iuhk.update_resource_group_pre(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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



    OPEN c_group_update(l_group_id);

    FETCH c_group_update INTO group_rec;


    IF c_group_update%NOTFOUND THEN

      IF c_group_update%ISOPEN THEN

        CLOSE c_group_update;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_GROUP');
	 fnd_message.set_token('P_GROUP_ID', l_group_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


      /* validate Exclusive flag value */
      /*
      Bug#8708207
      Below block to validate Exclusive Flag
      value before creating Resource Group.
      */

      IF group_rec.exclusive_flag <> 'Y' AND group_rec.exclusive_flag <> 'N' AND group_rec.exclusive_flag <> fnd_api.g_miss_char THEN
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    /* Validate that the Group Name is specified */

    IF group_rec.group_name IS NULL THEN

--	 dbms_output.put_line('Group Name cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_GROUP_NAME_NULL');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


    l_start_date_active := group_rec.start_date_active;
    l_end_date_active := group_rec.end_date_active;


    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    END IF;



    /* Validate that the group dates cover the role related dates for the
	  group */

    /* First part of the validation where the role relate end date active
	  is not null */

    OPEN c_related_role_dates_first(l_group_id);

    FETCH c_related_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_first%ISOPEN THEN

      CLOSE c_related_role_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active
	  is null */

    OPEN c_related_role_dates_sec(l_group_id);

    FETCH c_related_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_sec%ISOPEN THEN

      CLOSE c_related_role_dates_sec;

    END IF;



    /* Validate that the group dates cover the group member role related dates for the
	  group */

    /* First part of the validation where the group member role relate end date active
	  is not null */

    OPEN c_grp_mbr_role_dates_first(l_group_id);

    FETCH c_grp_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_MBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_MBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_grp_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active
	  is null */

    OPEN c_grp_mbr_role_dates_sec(l_group_id);

    FETCH c_grp_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_MBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_MBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_grp_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_sec;

    END IF;



    /* Validate that the group dates cover the group relation dates for the
	  group */

    /* First part of the validation where the group relate end date active
	  is not null */

    OPEN c_related_group_dates_first(l_group_id);

    FETCH c_related_group_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_REL_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_REL_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_group_dates_first%ISOPEN THEN

      CLOSE c_related_group_dates_first;

    END IF;



    /* Second part of the validation where the group relate end date active
	  is null */

    OPEN c_related_group_dates_sec(l_group_id);

    FETCH c_related_group_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_REL_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_GRP_REL_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_group_dates_sec%ISOPEN THEN

      CLOSE c_related_group_dates_sec;

    END IF;



    /* Validate that the group dates cover the team member role related dates for the
	  group, where the team member is a group */

    /* First part of the validation where the team member role relate end date active
	  is not null */

    OPEN c_team_mbr_role_dates_first(l_group_id);

    FETCH c_team_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      IF ( l_max_end_date > l_end_date_active AND l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active
	  is null */

    OPEN c_team_mbr_role_dates_sec(l_group_id);

    FETCH c_team_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      IF l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_TEAM_MBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_sec;

    END IF;

    /* Validate the Time Zone */

    IF p_time_zone <> fnd_api.g_miss_num AND p_time_zone IS NOT NULL THEN

        jtf_resource_utl.validate_time_zone(
          p_time_zone_id => p_time_zone,
          x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
		  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		       RAISE FND_API.G_EXC_ERROR;
		  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		  END IF;
        END IF;
    END IF;


    /* If Group Exclusive Flag is checked then only those resources can be
       assigned to the group, who are not assigned to any other Exclusive group
       having the same USAGE value in that same time period. Validate that the
       passed values support the above condition for all the group members. */

    IF (group_rec.exclusive_flag = 'Y')
    THEN
       OPEN c_exclusive_group_check(l_group_id);

       FETCH c_exclusive_group_check INTO l_check_char;


       IF c_exclusive_group_check%FOUND THEN

--	 dbms_output.put_line('Group record cannot be updated as one of the member
--	   dates overlap with another record for the same resource assigned to
--	   another exclusive group with the same usage in the same time period');

         IF c_exclusive_group_check%ISOPEN THEN

           CLOSE c_exclusive_group_check;

         END IF;

	 fnd_message.set_name('JTF', 'JTF_RS_EXCLUSIVE_GROUP');
	 fnd_msg_pub.add;

         RAISE fnd_api.g_exc_error;

       END IF;
    END IF;

    /* Close the cursors */

    IF c_exclusive_group_check%ISOPEN THEN

      CLOSE c_exclusive_group_check;

    END IF;



    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_groups_pkg.lock_row(
        x_group_id => l_group_id,
	   x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN

--	   dbms_output.put_line('Error in Locking the Row');


	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;


    END;


    /* Make a call to the group Audit API */

    jtf_rs_groups_aud_pvt.update_group
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     P_GROUP_NUMBER => group_rec.group_number,
     P_GROUP_NAME => group_rec.group_name,
     P_GROUP_DESC => group_rec.group_desc,
     P_EXCLUSIVE_FLAG => group_rec.exclusive_flag,
     P_EMAIL_ADDRESS => group_rec.email_address,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
     P_ACCOUNTING_CODE => group_rec.accounting_code,
     P_OBJECT_VERSION_NUMBER => p_object_version_num + 1,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     P_TIME_ZONE => group_rec.time_zone
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

    /* update the wf roles with changes resource group
       this should be done before the chnages happens to
       the database since we need the old values */
    -- Don't care for its success status
    BEGIN
      jtf_rs_wf_integration_pub.update_resource_group
	(P_API_VERSION      => 1.0,
	 P_GROUP_ID      =>  l_group_id,
	 P_GROUP_NAME   => l_group_name,
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

      jtf_rs_groups_pkg.update_row(
        x_group_id => l_group_id,
        x_group_number => group_rec.group_number,
        x_exclusive_flag => group_rec.exclusive_flag,
        x_email_address => group_rec.email_address,
        x_start_date_active => l_start_date_active,
        x_end_date_active => l_end_date_active,
        x_group_name => group_rec.group_name,
        x_group_desc => group_rec.group_desc,
        x_accounting_code => group_rec.accounting_code,
	   x_object_version_number => l_object_version_num,
        x_attribute1 => group_rec.attribute1,
        x_attribute2 => group_rec.attribute2,
        x_attribute3 => group_rec.attribute3,
        x_attribute4 => group_rec.attribute4,
        x_attribute5 => group_rec.attribute5,
        x_attribute6 => group_rec.attribute6,
        x_attribute7 => group_rec.attribute7,
        x_attribute8 => group_rec.attribute8,
        x_attribute9 => group_rec.attribute9,
        x_attribute10 => group_rec.attribute10,
        x_attribute11 => group_rec.attribute11,
        x_attribute12 => group_rec.attribute12,
        x_attribute13 => group_rec.attribute13,
        x_attribute14 => group_rec.attribute14,
        x_attribute15 => group_rec.attribute15,
        x_attribute_category => group_rec.attribute_category,
        x_last_update_date => SYSDATE,
        x_last_updated_by => jtf_resource_utl.updated_by,
        x_last_update_login => jtf_resource_utl.login_id,
        x_time_zone => group_rec.time_zone
      );


      /* Return the new value of the object version number */

      p_object_version_num := l_object_version_num;


    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

        IF c_group_update%ISOPEN THEN

          CLOSE c_group_update;

        END IF;


	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;

    END;

--    dbms_output.put_line('Group Successfully Updated');


    /* Close the cursors */

    IF c_group_update%ISOPEN THEN

      CLOSE c_group_update;

    END IF;


    /* Make a call to the Group Denorm API */

    jtf_rs_group_denorm_pvt.update_res_groups
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_GROUP_ID => l_group_id,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_group_cuhk.update_resource_group_post(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_group_vuhk.update_resource_group_post(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_group_iuhk.update_resource_group_post(
        p_group_id => l_group_id,
        p_group_name => l_group_name,
        p_group_desc => l_group_desc,
        p_exclusive_flag => l_exclusive_flag,
        p_email_address => l_email_address,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_accounting_code => l_accounting_code,
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
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_GROUPS_PVT',
	 'UPDATE_RESOURCE_GROUP',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_group_cuhk.ok_to_generate_msg(
	       p_group_id => l_group_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_id', l_group_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'GRP',
		p_action_code => 'U',
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
      ROLLBACK TO update_resource_group_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_group_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_group_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END update_resource_group;


END jtf_rs_groups_pvt;

/
