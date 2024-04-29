--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_RELATE_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_RELATE_AUD_PVT" AS
  /* $Header: jtfrsafb.pls 120.0 2005/05/11 08:19:05 appldev ship $ */
-- API Name	: JTF_RS_GROUP_RELATE_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RS_group_RELATE_AUD
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 20 JAN 2000    S Choudhury   Created
-- Notes:
--

--DECLARE GLOBAL VARIABLE

   g_pkg_name varchar2(30)	 := 'JTF_RS_GROUP_RELATE_AUD_PVT ';
    /* FOR INSERT */

    PROCEDURE   INSERT_GROUP_RELATE(
    P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT	            IN	VARCHAR2,
    P_GROUP_RELATE_ID       IN  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID %TYPE,
    P_GROUP_ID              IN  JTF_RS_GRP_RELATIONS.GROUP_ID %TYPE,
    P_RELATED_GROUP_ID      IN  JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
    P_RELATION_TYPE        IN  JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
    P_START_DATE_ACTIVE     IN  JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
    P_END_DATE_ACTIVE       IN  JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
    P_OBJECT_VERSION_NUMBER IN  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2 )
    IS

    l_group_relate_aud_id jtf_rs_grp_relate_aud.group_relate_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GROUP_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number;
    l_login_id  Number;

    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT GROUP_RELATE_AUDIT;

       x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


   select jtf_rs_grp_relate_aud_s.nextval
     into l_group_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GRP_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_group_RELATE_AUDIT_ID => l_group_relate_aud_id,
                        X_group_RELATE_ID  => p_group_relate_id,
                        X_NEW_GROUP_ID     => p_group_id,
                        X_OLD_GROUP_ID  => null,
                        X_NEW_RELATED_GROUP_ID => p_related_group_id,
                        X_OLD_RELATED_GROUP_ID => null,
                        x_NEW_RELATION_TYPE  => p_relation_type,
                        x_OLD_RELATION_TYPE  => null,
                        X_NEW_START_DATE_ACTIVE => p_start_date_active,
                        X_OLD_START_DATE_ACTIVE => null,
                        X_NEW_END_DATE_ACTIVE => p_end_date_active,
                        X_OLD_END_DATE_ACTIVE => null,
                        X_NEW_OBJECT_VERSION_NUMBER => p_object_version_number,
                        X_OLD_OBJECT_VERSION_NUMBER => null,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id,
                        X_LAST_UPDATE_DATE => l_date,
                        X_LAST_UPDATED_BY => l_user_id,
                        X_LAST_UPDATE_LOGIN => l_login_id
                        );

  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END INSERT_GROUP_RELATE;



   /*FOR UPDATE */
   PROCEDURE   UPDATE_group_RELATE(
    P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT	            IN	VARCHAR2,
    P_GROUP_RELATE_ID       IN  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID %TYPE,
    P_GROUP_ID              IN  JTF_RS_GRP_RELATIONS.GROUP_ID %TYPE,
    P_RELATED_GROUP_ID      IN  JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
    P_RELATION_TYPE          IN  JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
    P_START_DATE_ACTIVE     IN  JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
    P_END_DATE_ACTIVE       IN  JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
    P_OBJECT_VERSION_NUMBER IN  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2 )
    IS
    CURSOR rr_old_cur(l_group_relate_id JTF_RS_grp_RELATIONS.group_RELATE_ID%TYPE)
        IS
    SELECT  group_id,
            related_group_id,
            relation_type,
            start_date_active,
            end_date_active,
            object_version_number
      FROM  jtf_rs_grp_relations
     WHERE  group_relate_id = l_group_relate_id;


     --declare variables
--old value
    l_group_relate_id         jtf_rs_grp_relations.group_relate_id %type := null;
    l_group_id                jtf_rs_grp_relations.group_id %type := null;
    l_related_group_id        jtf_rs_grp_relations.related_group_id%type := null;
    l_relation_type            jtf_rs_grp_relations.relation_type%type;
    l_start_date_active       jtf_rs_grp_relations.start_date_active%type := null;
    l_end_date_active         jtf_rs_grp_relations.end_date_active%type  := null;
    l_object_version_number   jtf_rs_grp_relations.object_version_number%type  := null;




--new values
    l_group_relate_id_n         jtf_rs_grp_relations.group_relate_id %type := null;
    l_group_id_n                jtf_rs_grp_relations.group_id %type := null;
    l_related_group_id_n        jtf_rs_grp_relations.related_group_id%type := null;
    l_relation_type_n            jtf_rs_grp_relations.relation_type%type;
    l_start_date_active_n       jtf_rs_grp_relations.start_date_active%type := null;
    l_end_date_active_n         jtf_rs_grp_relations.end_date_active%type  := null;
    l_object_version_number_n   jtf_rs_grp_relations.object_version_number%type  := null;




rr_old_rec    rr_old_cur%rowtype;
l_group_relate_aud_id jtf_rs_grp_relate_aud.group_relate_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_GROUP_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT group_RELATE_AUDIT;

    x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


    open rr_old_cur(p_group_relate_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if p_group_id  <> nvl(rr_old_rec.group_id,0)
    then
       l_group_id :=  rr_old_rec.group_Id;
       l_group_id_n :=  p_group_id;
    end if;
     if p_related_group_id <> nvl(rr_old_rec.related_group_id, -1)
    then
       l_related_group_id :=  rr_old_rec.related_group_id;
       l_related_group_id_n :=  p_related_group_id;
    end if;
    if p_relation_type  <> rr_old_rec.relation_type
    then
       l_relation_type  :=  rr_old_rec.relation_type ;
       l_relation_type_n:=  p_relation_type;
    end if;
    if p_start_date_active  <> rr_old_rec.start_date_active
    then
       l_start_date_active :=  rr_old_rec.start_date_active;
       l_start_date_active_n :=  p_start_date_active;
    end if;
    if (p_end_date_active <> rr_old_rec.end_date_active) OR
/*	  (p_end_date_active is null AND rr_old_rec.end_date_active <> FND_API.G_MISS_DATE) OR
	  (p_end_date_active is not null AND rr_old_rec.end_date_active = FND_API.G_MISS_DATE) */
/* Modified the above date validation to fix bug # 2760129 */
	  (p_end_date_active is null AND rr_old_rec.end_date_active is NOT NULL) OR
	  (p_end_date_active is not null AND rr_old_rec.end_date_active is NULL)

    then
       l_end_date_active  :=  rr_old_rec.end_date_active ;
       l_end_date_active_n  :=  p_end_date_active ;
    end if;
    if p_object_version_number <> nvl(rr_old_rec.object_version_number,0)
    then
       l_object_version_number :=  rr_old_rec.object_version_number;
       l_object_version_number_n :=  p_object_version_number;
    end if;


    select jtf_rs_grp_relate_aud_s.nextval
     into l_group_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GRP_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_group_RELATE_AUDIT_ID => l_group_relate_aud_id,
                        X_group_RELATE_ID  => p_group_relate_id,
                        X_NEW_group_ID => l_group_id_n,
                        X_OLD_group_ID => l_group_id,
                        X_NEW_RELATED_GROUP_ID => l_related_group_id_n,
                        X_OLD_RELATED_GROUP_ID =>  l_related_group_id,
                        x_NEW_RELATION_TYPE  => l_relation_type_n,
                        x_OLD_RELATION_TYPE  => l_relation_type,
                        X_NEW_START_DATE_ACTIVE => l_start_date_active_n,
                        X_OLD_START_DATE_ACTIVE => l_start_date_active,
                        X_NEW_END_DATE_ACTIVE => l_end_date_active_n,
                        X_OLD_END_DATE_ACTIVE => l_end_date_active,
                        X_NEW_OBJECT_VERSION_NUMBER => l_object_version_number_n,
                        X_OLD_OBJECT_VERSION_NUMBER => l_object_version_number,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id,
                        X_LAST_UPDATE_DATE => l_date,
                        X_LAST_UPDATED_BY => l_user_id,
                        X_LAST_UPDATE_LOGIN => l_login_id
                        );




  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END UPDATE_group_RELATE;


   --FOR DELETE

   PROCEDURE   DELETE_group_RELATE(
    P_API_VERSION			IN	NUMBER,
	P_INIT_MSG_LIST		IN	VARCHAR2,
	P_COMMIT			IN	VARCHAR2,
    P_GROUP_RELATE_ID    IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
    IS
     CURSOR rr_old_cur(l_group_relate_id JTF_RS_GRP_RELATIONS.group_RELATE_ID%TYPE)
        IS
    SELECT  group_id,
            related_group_id,
            relation_type,
            start_date_active,
            end_date_active,
            object_version_number
      FROM  jtf_rs_grp_relations
     WHERE  group_relate_id = l_group_relate_id;


--declare variables
--old value
    l_group_relate_id         jtf_rs_grp_relations.group_relate_id %type := null;
    l_group_id                jtf_rs_grp_relations.group_id %type := null;
    l_related_group_id        jtf_rs_grp_relations.related_group_id%type := null;
    l_relation_type            jtf_rs_grp_relations.relation_type%type;
    l_start_date_active       jtf_rs_grp_relations.start_date_active%type := null;
    l_end_date_active         jtf_rs_grp_relations.end_date_active%type  := null;
    l_object_version_number   jtf_rs_grp_relations.object_version_number%type  := null;


    rr_old_rec    rr_old_cur%rowtype;
    l_group_relate_aud_id jtf_rs_grp_relate_aud.group_relate_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_GROUP_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number;
    l_login_id  Number;




    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT group_RELATE_AUDIT;

    x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


     open rr_old_cur(p_group_relate_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    l_group_id :=  rr_old_rec.group_id;
    l_related_group_id :=  rr_old_rec.related_group_id;
    l_relation_type    :=  rr_old_rec.relation_type;
    l_start_date_active :=  rr_old_rec.start_date_active;
    l_end_date_active  :=  rr_old_rec.end_date_active ;
    l_object_version_number :=  rr_old_rec.object_version_number;




   select jtf_rs_grp_relate_aud_s.nextval
     into l_group_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GRP_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_group_RELATE_AUDIT_ID => l_group_relate_aud_id,
                        X_group_RELATE_ID  => p_group_relate_id,
                        X_NEW_group_ID =>null,
                        X_OLD_group_ID => l_group_id,
                        X_NEW_RELATED_GROUP_ID => null,
                        X_OLD_RELATED_GROUP_ID => l_related_group_id,
                        x_NEW_RELATION_TYPE  => null,
                        x_OLD_RELATION_TYPE  => l_relation_type,
                        X_NEW_START_DATE_ACTIVE =>null,
                        X_OLD_START_DATE_ACTIVE => l_start_date_active,
                        X_NEW_END_DATE_ACTIVE => null,
                        X_OLD_END_DATE_ACTIVE => l_end_date_active,
                        X_NEW_OBJECT_VERSION_NUMBER => null,
                        X_OLD_OBJECT_VERSION_NUMBER => l_object_version_number,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id,
                        X_LAST_UPDATE_DATE => l_date,
                        X_LAST_UPDATED_BY => l_user_id,
                        X_LAST_UPDATE_LOGIN => l_login_id
                        );





  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END DELETE_group_RELATE;

END; -- Package Body JTF_RS_group_RELATE_AUD_PVT

/
