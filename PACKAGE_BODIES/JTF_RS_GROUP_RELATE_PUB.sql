--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_RELATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_RELATE_PUB" AS
  /* $Header: jtfrspfb.pls 120.0 2005/05/11 08:21:07 appldev ship $ */


  /*****************************************************************************************
   This package body defines the procedures for managing resource group relations.
   Its main procedures are as following:
   Create Resource Group Relate
   Update Resource Group Relate
   Delete Resource Group Relate
   This package validates the input parameters to these procedures and then
   Calls corresponding  procedures from jtf_rs_group_relate_pvt to do business
   validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_GROUP_RELATE_PUB';


  /* Procedure to create the resource group relation
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE,
   P_RELATED_GROUP_ID     IN   JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
   P_RELATED_GROUP_NUMBER IN   JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE,
   P_RELATION_TYPE        IN   JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_RELATE_ID      OUT NOCOPY  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE
  ) IS
  l_api_name CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP_RELATE';
  l_api_version CONSTANT NUMBER	 :=1.0;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);
  l_group_relate_id    JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);
  l_date               Date;
  l_user_id            Number;
  l_login_id           Number;

  l_group_id           JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE;
  l_related_group_id           JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE;

  CURSOR grp_cur(l_group_id     JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                 l_group_number JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE)
       IS
   SELECT group_id
     FROM jtf_rs_groups_b
    WHERE group_id = l_group_id
       OR group_number = l_group_number;

  grp_rec  grp_cur%rowtype;


  CURSOR chk_rel_cur(l_relation_type JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE)
      IS
  SELECT 'X'
    FROM fnd_lookups
   WHERE lookup_type = 'JTF_RS_RELATION_TYPE'
     AND UPPER(lookup_code) =  UPPER(l_relation_type);

  chk_rel_rec chk_rel_cur%rowtype;


  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_RELATE_SP;

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

   --check for group id/number and get valid group id
   OPEN grp_cur(p_group_id,
                p_group_number);
   FETCH grp_cur INTO grp_rec;
   IF(grp_cur%NOTFOUND)
   THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_NOTFOUND_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_unexpected_error;
   ELSE
      l_group_id := grp_rec.group_id;
   END IF;
   CLOSE grp_cur;

   --check for related group id/number and get valid group id
   OPEN grp_cur(p_related_group_id,
                p_related_group_number);
   FETCH grp_cur INTO grp_rec;
   IF(grp_cur%NOTFOUND)
   THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_RS_REL_GRP_NOTFOUND_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_unexpected_error;
   ELSE
      l_related_group_id := grp_rec.group_id;
   END IF;
   CLOSE grp_cur;

   --check for relation type
   OPEN chk_rel_cur(p_relation_type);
   FETCH chk_rel_cur INTO chk_rel_rec;
   IF(chk_rel_cur%NOTFOUND)
   THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_RS_REL_TYP_NOTFOUND_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   CLOSE chk_rel_cur;

  --call private api for insert
  jtf_rs_group_relate_pvt.create_resource_group_relate(
            P_API_VERSION   => 1.0,
            P_INIT_MSG_LIST => p_init_msg_list,
            P_COMMIT        => null,
            P_GROUP_ID      => l_group_id,
            P_RELATED_GROUP_ID  => l_related_group_id,
            P_RELATION_TYPE     => p_relation_type,
            P_START_DATE_ACTIVE  => p_start_date_active,
            P_END_DATE_ACTIVE   => p_end_date_active,
            X_RETURN_STATUS  => l_return_status,
            X_MSG_COUNT      => l_msg_count,
            X_MSG_DATA      => l_msg_data ,
            X_GROUP_RELATE_ID => l_group_relate_id);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
  END IF;

 X_GROUP_RELATE_ID := l_group_relate_id;




   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END create_resource_group_relate;


  /* Procedure to update the resource group relation
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS
 l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP_RELATE';
  l_api_version CONSTANT NUMBER	 :=1.0;

  L_OBJECT_VERSION_NUMBER    JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;
  l_group_relate_id    JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE := P_GROUP_RELATE_ID;
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

  CURSOR val_grp_rel_cur(l_group_relate_id JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE)
      IS
   SELECT 'X'
    FROM  jtf_rs_grp_relations
   where group_relate_id = l_group_relate_id;

  dummy VARCHAR2(30);



  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_RELATE_SP;

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
-------------------
   OPEN val_grp_rel_cur(p_group_relate_id);
   FETCH val_grp_rel_cur INTO dummy;
   IF(val_grp_rel_cur%NOTFOUND)
   THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_REL_NOTFOUND_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   CLOSE val_grp_rel_cur;


  --call private api for updation
 jtf_rs_group_relate_pvt.update_resource_group_relate(
            P_API_VERSION   => 1.0,
            P_INIT_MSG_LIST => p_init_msg_list,
            P_COMMIT        => null,
            P_GROUP_RELATE_ID     => l_group_relate_id,
            P_START_DATE_ACTIVE  => p_start_date_active,
            P_END_DATE_ACTIVE   => p_end_date_active,
            P_OBJECT_VERSION_NUM => l_object_version_number,
            X_RETURN_STATUS  => l_return_status,
            X_MSG_COUNT      => l_msg_count,
            X_MSG_DATA      => l_msg_data );

  p_object_version_num := l_object_version_number;

 IF(l_return_status <> fnd_api.g_ret_sts_success)
 THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;

 END IF;


   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END update_resource_group_relate;



  /* Procedure to delete the resource group relation. */

  PROCEDURE  delete_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

 l_api_name CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_GROUP_RELATE';
 l_api_version CONSTANT NUMBER	 :=1.0;

  L_OBJECT_VERSION_NUMBER    JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;
  l_group_relate_id    JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE;

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

  CURSOR val_grp_rel_cur(l_group_relate_id JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE)
      IS
   SELECT 'X'
    FROM  jtf_rs_grp_relations
   where group_relate_id = l_group_relate_id;

  dummy VARCHAR2(30);



  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_RELATE_SP;

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
-------------------
   OPEN val_grp_rel_cur(p_group_relate_id);
   FETCH val_grp_rel_cur INTO dummy;
   IF(val_grp_rel_cur%NOTFOUND)
   THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_REL_NOTFOUND_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   CLOSE val_grp_rel_cur;


  --call private api for updation
 jtf_rs_group_relate_pvt.delete_resource_group_relate(
            P_API_VERSION   => 1.0,
            P_INIT_MSG_LIST => p_init_msg_list,
            P_COMMIT        => null,
            P_GROUP_RELATE_ID     => p_group_relate_id,
            P_OBJECT_VERSION_NUM => l_object_version_number,
            X_RETURN_STATUS  => l_return_status,
            X_MSG_COUNT      => l_msg_count,
            X_MSG_DATA      => l_msg_data );

 IF(l_return_status <> fnd_api.g_ret_sts_success)
 THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;

 END IF;


   --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO GROUP_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  END delete_resource_group_relate;



END jtf_rs_group_relate_pub;

/
