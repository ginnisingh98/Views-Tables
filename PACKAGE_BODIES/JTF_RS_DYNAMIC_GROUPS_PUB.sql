--------------------------------------------------------
--  DDL for Package Body JTF_RS_DYNAMIC_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_DYNAMIC_GROUPS_PUB" AS
  /* $Header: jtfrspyb.pls 120.0 2005/05/11 08:21:30 appldev ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing dynamic groups , like
   create, update and delete Dynamic Groups.
   Its main procedures are as following:
   Create Dynamic Groups
   Update Dynamic Groups
   Delete Dynamic Groups
   This package valoidates the input parameters to these procedures and then
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_DYNAMIC_GROUPS_PUB';


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
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_ID    	  OUT NOCOPY  JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   X_GROUP_NUMBER    	  OUT NOCOPY  JTF_RS_DYNAMIC_GROUPS_B.GROUP_NUMBER%TYPE
  ) IS
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


  l_group_id                jtf_rs_dynamic_groups_b.group_id%type;
  l_group_number            jtf_rs_dynamic_groups_b.group_number%type;

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

-- Commented the below code to validate usage since it is calling from pvt API
  --call usage validation

--  JTF_RESOURCE_UTL.VALIDATE_USAGE(l_usage,
--                                 l_return_status);
--
--  IF(l_return_status <> fnd_api.g_ret_sts_success)
--  THEN
--     x_return_status := fnd_api.g_ret_sts_unexp_error;
--     fnd_message.set_name ('JTF', 'JTF_RS_USAGE_ERR');
--     FND_MSG_PUB.add;
--     RAISE fnd_api.g_exc_unexpected_error;
--  END IF;



  --call private api for insert
   jtf_rs_dynamic_groups_pvt.create_dynamic_groups(
                  P_API_VERSION        => 1.0,
                  P_INIT_MSG_LIST      => p_init_msg_list,
                  P_COMMIT             => null,
                  P_GROUP_NAME 	       => l_group_name,
                  P_GROUP_DESC 	       => l_group_desc,
                  P_USAGE    	       => l_usage,
                  P_START_DATE_ACTIVE  => l_start_date_active,
                  P_END_DATE_ACTIVE    => l_end_date_active,
                  P_SQL_TEXT           => l_sql_text,
                  X_RETURN_STATUS      => l_return_status,
                  X_MSG_COUNT          => l_msg_count,
                  X_MSG_DATA           => l_msg_data,
                  X_GROUP_ID           => l_group_id,
                  X_GROUP_NUMBER       => l_group_number);

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
     fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_INS_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
  x_group_id := l_group_id;
  x_group_number := l_group_number;



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
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/
  END create_dynamic_groups;



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
   P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_DYNAMIC_GROUPS';
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
   l_object_version_number   jtf_rs_dynamic_groups_b.object_version_number%type;

   l_group_id                jtf_rs_dynamic_groups_b.group_id%type;
   l_group_number            jtf_rs_dynamic_groups_b.group_number%type;

   BEGIN

   l_group_name               := P_GROUP_NAME;
   l_group_desc               := P_GROUP_DESC;
   l_usage                    := P_USAGE;
   l_start_date_active        := P_START_DATE_ACTIVE;
   l_end_date_active          := P_END_DATE_ACTIVE;
   l_sql_text                 := P_SQL_TEXT;
   l_object_version_number    := P_OBJECT_VERSION_NUMBER;

   l_group_id                 := P_GROUP_ID;
   l_group_number             := P_GROUP_NUMBER;

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


  --call private api for insert
   jtf_rs_dynamic_groups_pvt.update_dynamic_groups(
                  P_API_VERSION        => 1.0,
                  P_INIT_MSG_LIST      => p_init_msg_list,
                  P_COMMIT             => null,
                  P_GROUP_ID           => l_group_id,
                  P_GROUP_NUMBER       => l_group_number,
                  P_GROUP_NAME 	       => l_group_name,
                  P_GROUP_DESC 	       => l_group_desc,
                  P_USAGE    	       => l_usage,
                  P_START_DATE_ACTIVE  => l_start_date_active,
                  P_END_DATE_ACTIVE    => l_end_date_active,
                  P_SQL_TEXT           => l_sql_text,
                  P_OBJECT_VERSION_NUMBER => p_object_version_number,
                  X_RETURN_STATUS      => l_return_status,
                  X_MSG_COUNT          => l_msg_count,
                  X_MSG_DATA           => l_msg_data
                 );

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
     fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_UPDATE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
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
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/
  END update_dynamic_groups;


  /* Procedure to delete the Dynamic Groups. */

  PROCEDURE  delete_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   P_OBJECT_VERSION_NUMBER	IN JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS
  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_DYNAMIC_GROUPS';
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

  l_group_id           jtf_rs_dynamic_groups_b.group_id%type;


   BEGIN

  l_group_id       := P_GROUP_ID;

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


  --call private api for delete
   jtf_rs_dynamic_groups_pvt.delete_dynamic_groups(
                  P_API_VERSION        => 1.0,
                  P_INIT_MSG_LIST      => p_init_msg_list,
                  P_COMMIT             => null,
                  P_GROUP_ID           => l_group_id,
                  P_OBJECT_VERSION_NUMBER => p_object_version_number,
                  X_RETURN_STATUS      => l_return_status,
                  X_MSG_COUNT          => l_msg_count,
                  X_MSG_DATA           => l_msg_data
                 );

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
     fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_DELETE_ERR');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
*/
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
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_DYNAMIC_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_DYN_GRP_PUB_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
*/
  END delete_dynamic_groups;


END jtf_rs_dynamic_groups_pub;

/
