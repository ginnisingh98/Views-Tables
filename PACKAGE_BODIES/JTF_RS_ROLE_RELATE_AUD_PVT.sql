--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLE_RELATE_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLE_RELATE_AUD_PVT" AS
  /* $Header: jtfrsalb.pls 120.0 2005/05/11 08:19:07 appldev ship $ */
-- API Name	: JTF_RS_ROLE_RELATE_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RS_ROLE_RELATE_AUD
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 20 JAN 2000    S Choudhury   Created
-- Notes:
--

--DECLARE GLOBAL VARIABLE

  	g_pkg_name varchar2(30)	 := 'JTF_RS_ROLE_RELATE_AUD_PVT ';
    /* FOR INSERT */

    PROCEDURE   INSERT_ROLE_RELATE(
    P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT	            IN	VARCHAR2,
    P_ROLE_RELATE_ID        IN  NUMBER,
    P_ROLE_RESOURCE_TYPE    IN  VARCHAR2,
    P_ROLE_RESOURCE_ID      IN  NUMBER,
    P_ROLE_ID               IN  NUMBER,
    P_START_DATE_ACTIVE     IN  DATE,
    P_END_DATE_ACTIVE       IN  DATE,
    P_OBJECT_VERSION_NUMBER IN  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2 )
    IS

    l_role_relate_aud_id jtf_rs_role_relate_aud.role_relate_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_ROLE_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number;
    l_login_id  Number;

    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT ROLE_RELATE_AUDIT;

    x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


   select jtf_rs_role_relate_aud_s.nextval
     into l_role_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_ROLE_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_ROLE_RELATE_AUDIT_ID => l_role_relate_aud_id,
                        X_ROLE_RELATE_ID  => p_role_relate_id,
                        X_NEW_ROLE_RESOURCE_TYPE => p_role_resource_type,
                        X_OLD_ROLE_RESOURCE_TYPE => null,
                        X_NEW_ROLE_RESOURCE_ID => p_role_resource_id,
                        X_OLD_ROLE_RESOURCE_ID => null,
                        X_NEW_ROLE_ID => p_role_id,
                        X_OLD_ROLE_ID => null,
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
      ROLLBACK TO role_relate_audit;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
       WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO  role_relate_audit;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO  role_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',L_API_NAME);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END INSERT_ROLE_RELATE;



   /*FOR UPDATE */
   PROCEDURE   UPDATE_ROLE_RELATE(
    P_API_VERSION           IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT	            IN	VARCHAR2,
    P_ROLE_RELATE_ID        IN  NUMBER,
    P_ROLE_RESOURCE_TYPE    IN  VARCHAR2,
    P_ROLE_RESOURCE_ID      IN  NUMBER,
    P_ROLE_ID               IN  NUMBER,
    P_START_DATE_ACTIVE     IN  DATE,
    P_END_DATE_ACTIVE       IN  DATE,
    P_OBJECT_VERSION_NUMBER IN  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2)
    IS
    CURSOR rr_old_cur(l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
        IS
    SELECT  role_resource_id,
            role_resource_type,
            role_id,
            start_date_active,
            end_date_active,
            object_version_number
      FROM  jtf_rs_role_relations
     WHERE  role_relate_id = l_role_relate_id;


     --declare variables
--old value
l_role_resource_id      JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE := null ;
l_role_resource_type    JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE := NULL;
l_role_id               JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE := null ;
l_start_date_active     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE := null ;
l_end_date_active       JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE := null ;
l_object_version_number JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE := NULL;



--new values
l_ROLE_resource_id_n      JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE := null ;
l_role_resource_type_n    JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE := NULL;
l_role_id_n               JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE := null ;
l_start_date_active_n     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE := null ;
l_end_date_active_n       JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE := null ;
l_object_version_number_n JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE := NULL;



rr_old_rec    rr_old_cur%rowtype;
l_role_relate_aud_id jtf_rs_role_relate_aud.role_relate_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_ROLE_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT ROLE_RELATE_AUDIT;

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


    open rr_old_cur(p_role_relate_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if p_role_resource_id  <> nvl(rr_old_rec.role_resource_id,0)
    then
       l_role_resource_id :=  rr_old_rec.role_resource_id;
       l_role_resource_id_n :=  p_role_resource_id;
    end if;
     if p_role_resource_type  <> nvl(rr_old_rec.role_resource_type,'x')
    then
       l_role_resource_type :=  rr_old_rec.role_resource_type;
       l_role_resource_type_n :=  p_role_resource_type;
    end if;
    if p_role_id  <> nvl(rr_old_rec.role_id, 0)
    then
       l_role_id :=  rr_old_rec.role_id;
       l_role_id_n:=  p_role_id;
    end if;
    if p_start_date_active  <> rr_old_rec.start_date_active
    then
       l_start_date_active :=  rr_old_rec.start_date_active;
       l_start_date_active_n :=  p_start_date_active;
    end if;
    if /* (p_end_date_active <> rr_old_rec.end_date_active) OR
	  (p_end_date_active is null AND rr_old_rec.end_date_active <> FND_API.G_MISS_DATE) OR
	  (p_end_date_active is not null AND rr_old_rec.end_date_active = FND_API.G_MISS_DATE) */
     nvl(p_end_date_active, fnd_api.g_miss_date) <> nvl(rr_old_rec.end_date_active, fnd_api.g_miss_date)
    then
       l_end_date_active  :=  rr_old_rec.end_date_active ;
       l_end_date_active_n  :=  p_end_date_active ;
    end if;
    if p_object_version_number <> nvl(rr_old_rec.object_version_number,0)
    then
       l_object_version_number :=  rr_old_rec.object_version_number;
       l_object_version_number_n :=  p_object_version_number;
    end if;


    select jtf_rs_role_relate_aud_s.nextval
     into l_role_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_ROLE_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_ROLE_RELATE_AUDIT_ID => l_role_relate_aud_id,
                        X_ROLE_RELATE_ID  => p_role_relate_id,
                        X_NEW_ROLE_RESOURCE_TYPE => l_role_resource_type_n,
                        X_OLD_ROLE_RESOURCE_TYPE => l_role_resource_type,
                        X_NEW_ROLE_RESOURCE_ID => l_role_resource_id_n,
                        X_OLD_ROLE_RESOURCE_ID => l_role_resource_id,
                        X_NEW_ROLE_ID => l_role_id_n,
                        X_OLD_ROLE_ID => l_role_id,
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
      ROLLBACK TO role_relate_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO role_relate_audit;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO role_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END UPDATE_ROLE_RELATE;


   --FOR DELETE

   PROCEDURE   DELETE_ROLE_RELATE(
    P_API_VERSION			IN	NUMBER,
	P_INIT_MSG_LIST		IN	VARCHAR2,
	P_COMMIT			IN	VARCHAR2,
    P_ROLE_RELATE_ID    IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
    IS
      CURSOR rr_old_cur(l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
        IS
     SELECT  role_resource_id,
            role_resource_type,
            role_id,
            start_date_active,
            end_date_active,
            object_version_number
      FROM  jtf_rs_role_relations
     WHERE  role_relate_id = l_role_relate_id;


--declare variables
--old value
   l_role_resource_id      JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE := null ;
   l_role_resource_type    JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE := NULL;
   l_role_id               JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE := null ;
   l_start_date_active     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE := null ;
   l_end_date_active       JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE := null ;
   l_object_version_number JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE := NULL;

    rr_old_rec    rr_old_cur%rowtype;
    l_role_relate_aud_id jtf_rs_role_relate_aud.role_relate_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_ROLE_RELATE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number;
    l_login_id  Number;




    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT ROLE_RELATE_AUDIT;

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


     open rr_old_cur(p_role_relate_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    l_role_resource_id :=  rr_old_rec.role_resource_id;
    l_role_resource_type :=  rr_old_rec.role_resource_type;
    l_role_id :=  rr_old_rec.role_id;
    l_start_date_active :=  rr_old_rec.start_date_active;
    l_end_date_active  :=  rr_old_rec.end_date_active ;
    l_object_version_number :=  rr_old_rec.object_version_number;




   select jtf_rs_role_relate_aud_s.nextval
     into l_role_relate_aud_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_ROLE_RELATE_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        X_ROLE_RELATE_AUDIT_ID => l_role_relate_aud_id,
                        X_ROLE_RELATE_ID  => p_role_relate_id,
                        X_NEW_ROLE_RESOURCE_TYPE => null,
                        X_OLD_ROLE_RESOURCE_TYPE => l_role_resource_type,
                        X_NEW_ROLE_RESOURCE_ID => null,
                        X_OLD_ROLE_RESOURCE_ID => l_role_resource_id,
                        X_NEW_ROLE_ID => null,
                        X_OLD_ROLE_ID => l_role_id,
                        X_NEW_START_DATE_ACTIVE => null,
                        X_OLD_START_DATE_ACTIVE => l_start_date_active,
                        X_NEW_END_DATE_ACTIVE => null,
                        X_OLD_END_DATE_ACTIVE => l_end_date_active,
                        X_NEW_OBJECT_VERSION_NUMBER =>null,
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
      ROLLBACK TO role_relate_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO role_relate_audit;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO role_relate_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



    END DELETE_ROLE_RELATE;

END; -- Package Body JTF_RS_ROLE_RELATE_AUD_PVT

/
