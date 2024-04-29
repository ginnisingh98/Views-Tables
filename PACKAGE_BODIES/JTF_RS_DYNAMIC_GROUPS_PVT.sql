--------------------------------------------------------
--  DDL for Package Body JTF_RS_DYNAMIC_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_DYNAMIC_GROUPS_PVT" AS
  /* $Header: jtfrsvyb.pls 120.0 2005/05/11 08:23:22 appldev ship $ */

  /*****************************************************************************************
   This is a private API that caller will invoke.
   It provides procedures for managing Dynamic Groups, like
   create, update and delete Dynamic Groups from other modules.
   Its main procedures are as following:
   Create Dynamic Groups
   Update Dynamic Groups
   Delete Dynamic Groups
   ******************************************************************************************/

    G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_DYNAMIC_GROUPS_PVT';

  /* Procedure to create the Dynamic Groups
	based on input values passed by calling routines. */

  PROCEDURE  create_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_NAME 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_NAME%TYPE,
   P_GROUP_DESC 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_DESC%TYPE,
   P_USAGE    	  	  IN   JTF_RS_DYNAMIC_GROUPS_B.USAGE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_DYNAMIC_GROUPS_B.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_DYNAMIC_GROUPS_B.END_DATE_ACTIVE%TYPE,
   P_SQL_TEXT             IN   JTF_RS_DYNAMIC_GROUPS_B.SQL_TEXT%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_GRP_RELATIONS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_ID    	  OUT NOCOPY  JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   X_GROUP_NUMBER    	  OUT NOCOPY JTF_RS_DYNAMIC_GROUPS_B.GROUP_NUMBER%TYPE
  )
  IS

  l_api_name CONSTANT VARCHAR2(30) := 'CREATE_DYNAMIC_GROUPS';
  l_api_version CONSTANT NUMBER	 :=1.0;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);
  l_date               Date;
  l_user_id            Number;
  l_login_id           Number;


   l_group_name 	     jtf_rs_dynamic_groups_tl.group_name%type;
   l_group_desc 	     jtf_rs_dynamic_groups_tl.group_desc%type;
   l_usage    	  	     jtf_rs_dynamic_groups_b.usage%type;
   l_start_date_active       jtf_rs_dynamic_groups_b.start_date_active%type;
   l_end_date_active         jtf_rs_dynamic_groups_b.end_date_active%type;
   l_sql_text                jtf_rs_dynamic_groups_b.sql_text%type;


  l_cursorid  NUMBER;
  v_dummy  integer;

  l_group_id                jtf_rs_dynamic_groups_b.group_id%type;
  l_group_number            jtf_rs_dynamic_groups_b.group_number%type;

  l_bind_data_id            number;

  BEGIN

   l_group_name             := P_GROUP_NAME;
   l_group_desc             := P_GROUP_DESC;
   l_usage                  := P_USAGE;
   l_start_date_active      := P_START_DATE_ACTIVE;
   l_end_date_active        := P_END_DATE_ACTIVE;
   l_sql_text               := P_SQL_TEXT;

   --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_DYNAMIC_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
               JTF_RS_DYNAMIC_GROUPS_CUHK.CREATE_DYNAMIC_GROUPS_PRE(P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Verticle industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'V' ))
   then


         JTF_RS_DYNAMIC_GROUPS_VUHK.CREATE_DYNAMIC_GROUPS_PRE(P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

   /*  	Internal industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'B', 'I' ))
   then


         JTF_RS_DYNAMIC_GROUPS_IUHK.CREATE_DYNAMIC_GROUPS_PRE(P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;


  -- end of user hook call






   --call default date validation utl
  JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(l_start_date_active,
                                        l_end_date_active,
                                        l_return_status);
  IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
  END IF;
/*
  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
  --call usage validation

  JTF_RESOURCE_UTL.VALIDATE_USAGE(l_usage,
                                 l_return_status);

  IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
  END IF;
/*
  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_RS_USAGE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
   IF l_sql_text is NOT NULL
   THEN
      if (instr(ltrim(upper(l_sql_text)),'SELECT') = 1) then
      --VALIDATE SQL STATEMENT
         BEGIN
            l_cursorid := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursorid, l_sql_text, DBMS_SQL.V7);
         EXCEPTION
         WHEN OTHERS THEN
        --    x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_RS_SQL_TEXT_ERR');
            FND_MSG_PUB.add;
        --    RAISE fnd_api.g_exc_unexpected_error;
            RAISE fnd_api.g_exc_error;
         END;
       else
      --   x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_RS_SQL_NOT_A_SELECT');
         FND_MSG_PUB.add;
      --   RAISE fnd_api.g_exc_unexpected_error;
         RAISE fnd_api.g_exc_error;
       end if;
    END IF;

  --call table handler for insert
  SELECT TO_CHAR(jtf_rs_groups_s.nextval), jtf_rs_dynamic_groups_s.nextval
    INTO l_group_number, l_group_id
   FROM  dual;


  jtf_rs_dynamic_groups_pkg.insert_row(
                                      X_ROWID              => l_rowid,
                                      X_GROUP_ID           => l_group_id,
                                      X_GROUP_NUMBER       => l_group_number,
                                      X_USAGE               => l_usage,
                                      X_START_DATE_ACTIVE   => l_start_date_active,
                                      X_END_DATE_ACTIVE      => l_end_date_active,
                                      X_SQL_TEXT             => l_sql_text,
                                      X_ATTRIBUTE1           => p_attribute1,
                                      X_ATTRIBUTE2           => p_attribute2,
                                      X_ATTRIBUTE3            => p_attribute3,
                                      X_ATTRIBUTE4            => p_attribute4,
                                      X_ATTRIBUTE5            => p_attribute5,
                                      X_ATTRIBUTE6            => p_attribute6,
                                      X_ATTRIBUTE7            => p_attribute7,
                                      X_ATTRIBUTE8            => p_attribute8,
                                      X_ATTRIBUTE9            => p_attribute9,
                                      X_ATTRIBUTE10           => p_attribute10,
                                      X_ATTRIBUTE11           => p_attribute11,
                                      X_ATTRIBUTE12           => p_attribute12,
                                      X_ATTRIBUTE13           => p_attribute13,
                                      X_ATTRIBUTE14           => p_attribute14,
                                      X_ATTRIBUTE15           => p_attribute15,
                                      X_ATTRIBUTE_CATEGORY    => p_attribute_category,
                                      X_GROUP_NAME           => l_group_name,
                                      X_GROUP_DESC           => l_group_desc,
                                      X_CREATION_DATE        => l_date,
                                      X_CREATED_BY           => l_user_id,
                                      X_LAST_UPDATE_DATE     => l_date,
                                      X_LAST_UPDATED_BY      => l_user_id,
                                      X_LAST_UPDATE_LOGIN    => l_login_id);

  x_group_id := l_group_id;
  x_group_number := l_group_number;


  -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'CREATE_DYNAMIC_GROUPS', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'CREATE_DYNAMIC_GROUPS', 'A', 'C' ))
   then
             JTF_RS_DYNAMIC_GROUPS_CUHK.CREATE_DYNAMIC_GROUPS_POST(P_GROUP_ID => l_group_id,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Vertical industry post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'A', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'A', 'V' ))
   then


          JTF_RS_DYNAMIC_GROUPS_VUHK.CREATE_DYNAMIC_GROUPS_POST(P_GROUP_ID => l_group_id,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	iNTERNAL post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'CREATE_DYNAMIC_GROUPS', 'A', 'I' ))
   then


          JTF_RS_DYNAMIC_GROUPS_IUHK.CREATE_DYNAMIC_GROUPS_POST(P_GROUP_ID => l_group_id,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

  -- end of user hook call
  IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'CREATE_DYNAMIC_GROUPS',
      'M',
      'M')
  THEN
  IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'CREATE_DYNAMIC_GROUPS',
      'M',
      'M')
    THEN

      IF (jtf_rs_dynamic_groups_cuhk.ok_to_generate_msg(
            p_group_id => l_group_id,
            x_return_status => l_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_id',
            l_group_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_DGP',
          p_action_code => 'I',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
           fnd_msg_pub.add;

           IF x_return_status = fnd_api.g_ret_sts_error THEN
              raise fnd_api.g_exc_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              raise fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;
/*
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;

          fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_unexpected_error;

        END IF;
*/
      END IF;

    END IF;
    END IF;



   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO group_dynamic_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
/*
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/

  END  create_dynamic_groups;


  /* Procedure to update the Dynamic Groups
	based on input values passed by calling routines. */

  PROCEDURE  update_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   P_GROUP_NUMBER    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_NUMBER%TYPE,
   P_GROUP_NAME 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_NAME%TYPE,
   P_GROUP_DESC 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_DESC%TYPE,
   P_USAGE    	  	  IN   JTF_RS_DYNAMIC_GROUPS_B.USAGE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_DYNAMIC_GROUPS_B.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_DYNAMIC_GROUPS_B.END_DATE_ACTIVE%TYPE,
   P_SQL_TEXT             IN   JTF_RS_DYNAMIC_GROUPS_B.SQL_TEXT%TYPE,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_ROLE_RELATIONS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_DYNAMIC_GROUPS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);
  l_date               Date;
  l_user_id            Number;
  l_login_id           Number;

  l_group_id              jtf_rs_dynamic_groups_b.group_id%type;
  l_group_number          jtf_rs_dynamic_groups_b.group_number%type ;
  l_group_name 	          jtf_rs_dynamic_groups_tl.group_name%type ;
  l_group_desc 	          jtf_rs_dynamic_groups_tl.group_desc%type ;
  l_usage    	  	  jtf_rs_dynamic_groups_b.usage%type ;
  l_start_date_active     jtf_rs_dynamic_groups_b.start_date_active%type;
  l_end_date_active       jtf_rs_dynamic_groups_b.end_date_active%type ;
  l_sql_text              jtf_rs_dynamic_groups_b.sql_text%type ;
  l_object_version_number jtf_rs_dynamic_groups_b.object_version_number%type;

  l_attribute1		     jtf_rs_dynamic_groups_b.attribute1%type;
  l_attribute2		     jtf_rs_dynamic_groups_b.attribute2%type;
  l_attribute3		     jtf_rs_dynamic_groups_b.attribute3%type;
  l_attribute4		     jtf_rs_dynamic_groups_b.attribute4%type;
  l_attribute5		     jtf_rs_dynamic_groups_b.attribute5%type;
  l_attribute6		     jtf_rs_dynamic_groups_b.attribute6%type;
  l_attribute7		     jtf_rs_dynamic_groups_b.attribute7%type;
  l_attribute8		     jtf_rs_dynamic_groups_b.attribute8%type;
  l_attribute9		     jtf_rs_dynamic_groups_b.attribute9%type;
  l_attribute10	             jtf_rs_dynamic_groups_b.attribute10%type;
  l_attribute11	             jtf_rs_dynamic_groups_b.attribute11%type;
  l_attribute12	             jtf_rs_dynamic_groups_b.attribute12%type;
  l_attribute13	             jtf_rs_dynamic_groups_b.attribute13%type;
  l_attribute14	             jtf_rs_dynamic_groups_b.attribute14%type;
  l_attribute15	             jtf_rs_dynamic_groups_b.attribute15%type;
  l_attribute_category	     jtf_rs_dynamic_groups_b.attribute_category%type;



  l_cursorid  NUMBER;
  v_dummy  integer;


  CURSOR dyn_grp_cur(l_group_id jtf_rs_dynamic_groups_b.group_id%type)
      IS
   SELECT group_number,
          usage        ,
          start_date_active,
          end_date_active ,
          sql_text,
          object_version_number,
          attribute1  ,
          attribute2  ,
          attribute3  ,
          attribute4  ,
          attribute5  ,
          attribute6  ,
          attribute7  ,
          attribute8  ,
          attribute9  ,
          attribute10 ,
          attribute11 ,
          attribute12 ,
          attribute13 ,
          attribute14 ,
          attribute15  ,
          attribute_category,
          group_name,
          group_desc
   FROM   jtf_rs_dynamic_groups_vl
  WHERE   group_id = l_group_id;

  dyn_grp_rec   dyn_grp_cur%rowtype;




  BEGIN

  l_group_id               := p_group_id;
  l_object_version_number  := p_object_version_number;

   --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_DYNAMIC_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

  -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
              JTF_RS_DYNAMIC_GROUPS_CUHK.UPDATE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

   if  ( JTF_resource_utl.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'V' ))
   then


           JTF_RS_DYNAMIC_GROUPS_VUHK.UPDATE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'B', 'I' ))
   then


           JTF_RS_DYNAMIC_GROUPS_IUHK.UPDATE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;


  -- end of user hook call




  OPEN dyn_grp_cur(l_group_id);
  FETCH dyn_grp_cur INTO dyn_grp_rec;
  CLOSE dyn_grp_cur;



  --assign values to the local variables
  IF(p_group_number = FND_API.G_MISS_CHAR)
  THEN
     l_group_number  := dyn_grp_rec.group_number;
  ELSE
      l_group_number:= p_group_number;
  END IF;


  IF(p_group_name = FND_API.G_MISS_CHAR)
  THEN
     l_group_name  := dyn_grp_rec.group_name;
  ELSE
      l_group_name := p_group_name;
  END IF;

  IF(p_group_desc = FND_API.G_MISS_CHAR)
  THEN
     l_group_desc  := dyn_grp_rec.group_desc;
  ELSE
      l_group_desc := p_group_desc;
  END IF;

  IF(p_usage = FND_API.G_MISS_CHAR)
  THEN
     l_usage   := dyn_grp_rec.usage ;
  ELSE
      l_usage  := p_usage ;
  END IF;
  IF(p_sql_text = FND_API.G_MISS_CHAR)
  THEN
     l_sql_text   := dyn_grp_rec.sql_text ;
  ELSE
      l_sql_text  := p_sql_text;
  END IF;



  IF(p_start_date_active = FND_API.G_MISS_DATE)
  THEN

     l_start_date_active := dyn_grp_rec.start_date_active;
  ELSE
      l_start_date_active := p_start_date_active;
  END IF;
  IF(p_end_date_active = FND_API.G_MISS_DATE)
  THEN
     l_end_date_active := dyn_grp_rec.end_date_active;
  ELSE
      l_end_date_active := p_end_date_active;
  END IF;
  IF(p_attribute1 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute1 := dyn_grp_rec.attribute1;
  ELSE
      l_attribute1 := p_attribute1;
  END IF;
  IF(p_attribute2= FND_API.G_MISS_CHAR)
  THEN
     l_attribute2 := dyn_grp_rec.attribute2;
  ELSE
      l_attribute2 := p_attribute2;
  END IF;
  IF(p_attribute3 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute3 := dyn_grp_rec.attribute3;
  ELSE
      l_attribute3 := p_attribute3;
  END IF;
  IF(p_attribute4 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute4 := dyn_grp_rec.attribute1;
  ELSE
      l_attribute4 := p_attribute4;
  END IF;
  IF(p_attribute5 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute5 := dyn_grp_rec.attribute5;
  ELSE
      l_attribute5 := p_attribute5;
  END IF;
  IF(p_attribute6 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute6 := dyn_grp_rec.attribute1;
  ELSE
      l_attribute6 := p_attribute6;
  END IF;
  IF(p_attribute7 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute7 := dyn_grp_rec.attribute7;
  ELSE
      l_attribute7 := p_attribute7;
  END IF;
  IF(p_attribute8 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute8 := dyn_grp_rec.attribute8;
  ELSE
      l_attribute8 := p_attribute8;
  END IF;
  IF(p_attribute9 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute9 := dyn_grp_rec.attribute9;
  ELSE
      l_attribute9 := p_attribute9;
  END IF;
  IF(p_attribute10 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute10 := dyn_grp_rec.attribute10;
  ELSE
      l_attribute10 := p_attribute10;
  END IF;
  IF(p_attribute11 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute11 := dyn_grp_rec.attribute11;
  ELSE
      l_attribute11 := p_attribute11;
  END IF;
  IF(p_attribute12 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute12 := dyn_grp_rec.attribute12;
  ELSE
      l_attribute12 := p_attribute12;
  END IF;
  IF(p_attribute13 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute13 := dyn_grp_rec.attribute13;
  ELSE
      l_attribute13 := p_attribute13;
  END IF;
 IF(p_attribute14 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute14 := dyn_grp_rec.attribute14;
  ELSE
      l_attribute14 := p_attribute14;
  END IF;
 IF(p_attribute15 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute15 := dyn_grp_rec.attribute15;
  ELSE
      l_attribute15 := p_attribute15;
  END IF;

 IF(p_attribute_category = FND_API.G_MISS_CHAR)
  THEN
     l_attribute_category := dyn_grp_rec.attribute_category;
  ELSE
      l_attribute_category := p_attribute_category;
  END IF;

  --validate dates
  JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(l_start_date_active,
                                        l_end_date_active,
                                        l_return_status);

  IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
  END IF;
/*
  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
  --call usage validation
  JTF_RESOURCE_UTL.VALIDATE_USAGE(l_usage,
                                 l_return_status);

  IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
  END IF;
/*
  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_RS_USAGE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/

   IF l_sql_text is NOT NULL
   THEN
      if (instr(ltrim(upper(l_sql_text)),'SELECT') = 1) then
         --VALIDATE SQL STATEMENT
         BEGIN
           l_cursorid := DBMS_SQL.OPEN_CURSOR;
           DBMS_SQL.PARSE(l_cursorid, l_sql_text, DBMS_SQL.V7);

         EXCEPTION
         WHEN OTHERS THEN
       --    x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name ('JTF', 'JTF_RS_SQL_TEXT_ERR');
           FND_MSG_PUB.add;
       --    RAISE fnd_api.g_exc_unexpected_error;
           RAISE fnd_api.g_exc_error;
         END;
      else
      --   x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_RS_SQL_NOT_A_SELECT');
         FND_MSG_PUB.add;
      --   RAISE fnd_api.g_exc_unexpected_error;
         RAISE fnd_api.g_exc_error;
      end if;
    END IF;


  --call lock row
     BEGIN

      jtf_rs_dynamic_groups_pkg.lock_row(
        x_group_id => l_group_id,
	x_object_version_number => p_object_version_number
      );

    EXCEPTION

	 WHEN OTHERS THEN
--         x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
--	 RAISE fnd_api.g_exc_unexpected_error;
         RAISE fnd_api.g_exc_error;

    END;
    l_object_version_number := l_object_version_number + 1;


  --call update table handler
    jtf_rs_dynamic_groups_pkg.update_row(
                                      X_GROUP_ID              => l_group_id,
                                      X_GROUP_NUMBER          => l_group_number,
                                      X_USAGE                 => l_usage,
                                      X_START_DATE_ACTIVE     => l_start_date_active,
                                      X_END_DATE_ACTIVE       => l_end_date_active,
                                      X_SQL_TEXT              => l_sql_text,
                                      X_OBJECT_VERSION_NUMBER => l_object_version_number,
                                      X_ATTRIBUTE1            => l_attribute1,
                                      X_ATTRIBUTE2            => l_attribute2,
                                      X_ATTRIBUTE3            => l_attribute3,
                                      X_ATTRIBUTE4            => l_attribute4,
                                      X_ATTRIBUTE5            => l_attribute5,
                                      X_ATTRIBUTE6            => l_attribute6,
                                      X_ATTRIBUTE7            => l_attribute7,
                                      X_ATTRIBUTE8            => l_attribute8,
                                      X_ATTRIBUTE9            => l_attribute9,
                                      X_ATTRIBUTE10           => l_attribute10,
                                      X_ATTRIBUTE11           => l_attribute11,
                                      X_ATTRIBUTE12           => l_attribute12,
                                      X_ATTRIBUTE13           => l_attribute13,
                                      X_ATTRIBUTE14           => l_attribute14,
                                      X_ATTRIBUTE15           => l_attribute15,
                                      X_ATTRIBUTE_CATEGORY    => l_attribute_category,
                                      X_GROUP_NAME           => l_group_name,
                                      X_GROUP_DESC           => l_group_desc,
                                      X_LAST_UPDATE_DATE     => l_date,
                                      X_LAST_UPDATED_BY      => l_user_id,
                                      X_LAST_UPDATE_LOGIN    => l_login_id);


  p_object_version_number := l_object_version_number;

  -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'UPDATE_DYNAMIC_GROUPS', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'UPDATE_DYNAMIC_GROUPS', 'A', 'C' ))
   then
               JTF_RS_DYNAMIC_GROUPS_CUHK.UPDATE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Verticle industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'A', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'A', 'V' ))
   then


         JTF_RS_DYNAMIC_GROUPS_VUHK.UPDATE_DYNAMIC_GROUPS_POST(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'UPDATE_DYNAMIC_GROUPS', 'A', 'I' ))
   then


         JTF_RS_DYNAMIC_GROUPS_IUHK.UPDATE_DYNAMIC_GROUPS_POST(P_GROUP_ID => p_group_id,
                                                               P_GROUP_NUMBER => p_group_number,
                                                               P_GROUP_NAME 	  => p_group_name,
                                                               P_GROUP_DESC 	=>  p_group_desc,
                                                               P_USAGE    => p_usage,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_SQL_TEXT  => p_sql_text,
                                                               P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

  -- end of user hook call

 IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'UPDATE_DYNAMIC_GROUPS',
      'M',
      'M')
 THEN
 IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'UPDATE_DYNAMIC_GROUPS',
      'M',
      'M')
    THEN

      IF (jtf_rs_dynamic_groups_cuhk.ok_to_generate_msg(
            p_group_id => l_group_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_id',
            l_group_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_DGP',
          p_action_code => 'U',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
           fnd_msg_pub.add;

           IF x_return_status = fnd_api.g_ret_sts_error THEN
              raise fnd_api.g_exc_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              raise fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;
/*
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;

          fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_unexpected_error;

        END IF;
*/
      END IF;

    END IF;
    END IF;



   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO group_dynamic_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
/*
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/

  END;



  /* Procedure to delete the Dynamic Groups. */

  PROCEDURE  delete_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   P_OBJECT_VERSION_NUMBER	IN JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_DYNAMIC_GROUPS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);
  l_date               Date;
  l_user_id            Number;
  l_login_id           Number;

  BEGIN
   --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_DYNAMIC_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'C' ))
   then
             JTF_RS_DYNAMIC_GROUPS_CUHK.DELETE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                                P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		  x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'V' ))
   then


          JTF_RS_DYNAMIC_GROUPS_VUHK.DELETE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                         P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                         p_data       =>    L_data,
                                                         p_count   =>   L_count,
                                                         P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

   /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'B', 'I' ))
   then


          JTF_RS_DYNAMIC_GROUPS_IUHK.DELETE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                         P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                         p_data       =>    L_data,
                                                         p_count   =>   L_count,
                                                         P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

  -- end of user hook call



   --call lock row
     BEGIN

      jtf_rs_dynamic_groups_pkg.lock_row(
        x_group_id => p_group_id,
	x_object_version_number => p_object_version_number
      );

    EXCEPTION

	 WHEN OTHERS THEN
--         x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
--	 RAISE fnd_api.g_exc_unexpected_error;
	 RAISE fnd_api.g_exc_error;

    END;

  --call table handler to delete the group
  jtf_rs_dynamic_groups_pkg.delete_row(p_group_id);


   -- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'DELETE_DYNAMIC_GROUPS', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_POST', 'DELETE_DYNAMIC_GROUPS', 'A', 'C' ))
   then

            JTF_RS_DYNAMIC_GROUPS_CUHK.DELETE_DYNAMIC_GROUPS_PRE(P_GROUP_ID => p_group_id,
                                                                P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		  x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

    /*  	Verticle industry post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'A', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'A', 'V' ))
   then


             JTF_RS_DYNAMIC_GROUPS_VUHK.DELETE_DYNAMIC_GROUPS_POST(P_GROUP_ID => p_group_id,
                                                          P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                          p_data       =>    L_data,
                                                          p_count   =>   L_count,
                                                          P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;

   /*  	Internal  post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_DYNAMIC_GROUPS_PVT', 'DELETE_DYNAMIC_GROUPS', 'A', 'I' ))
   then


             JTF_RS_DYNAMIC_GROUPS_IUHK.DELETE_DYNAMIC_GROUPS_POST(P_GROUP_ID => p_group_id,
                                                          P_OBJECT_VERSION_NUMBER => p_object_version_number,
                                                          p_data       =>    L_data,
                                                          p_count   =>   L_count,
                                                          P_return_code  =>  l_return_code);
             IF NOT (l_return_code = fnd_api.g_ret_sts_success) THEN
                fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                fnd_msg_pub.add;

                IF l_return_code = fnd_api.g_ret_sts_error THEN
                   raise fnd_api.g_exc_error;
                ELSIF l_return_code = fnd_api.g_ret_sts_unexp_error THEN
                   raise fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;
/*
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_unexpected_error;
	     end if;
*/
    end if;
    end if;


  -- end of user hook call

   IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'DELETE_DYNAMIC_GROUPS',
      'M',
      'M')
   THEN
   IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_DYNAMIC_GROUPS_PVT',
      'DELETE_DYNAMIC_GROUPS',
      'M',
      'M')
    THEN

      IF (jtf_rs_dynamic_groups_cuhk.ok_to_generate_msg(
            p_group_id => p_group_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_id',
            p_group_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_DGP',
          p_action_code => 'D',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
           fnd_msg_pub.add;

           IF x_return_status = fnd_api.g_ret_sts_error THEN
              raise fnd_api.g_exc_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              raise fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;
/*
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;

          fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_unexpected_error;

        END IF;
*/
      END IF;

    END IF;
    END IF;


   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO group_dynamic_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO group_dynamic_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
/*
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PVT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/
  END;
END jtf_rs_dynamic_groups_pvt;

/
