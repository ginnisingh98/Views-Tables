--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBERS_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBERS_AUD_PVT" AS
  /* $Header: jtfrsamb.pls 120.0 2005/05/11 08:19:09 appldev ship $ */
-- API Name	: JTF_RS_GROUP_MEMBERS_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RS_GROUPS_B_AUD
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 20 JAN 2000   S Choudhury   Created
-- Notes:
--

  	g_pkg_name varchar2(30)	 := 'JTF_RS_GROUP_MEMBERS_AUD_PVT';

   /*FOR INSERT  */
   PROCEDURE   INSERT_MEMBER(
    P_API_VERSION	    IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT		    IN	VARCHAR2,
    P_GROUP_MEMBER_ID       IN  NUMBER,
    P_GROUP_ID              IN  NUMBER,
    P_RESOURCE_ID           IN  NUMBER,
    P_PERSON_ID             IN  NUMBER,
    P_OBJECT_VERSION_NUMBER IN NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2)
  IS

l_group_member_audit_id jtf_rs_group_members_aud.group_member_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_MEMBER';
    l_api_version CONSTANT NUMBER	 := 1.0;
    l_date  Date ;
    l_user_id  Number;
    l_login_id  Number;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT GROUP_AUDIT;

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



   select jtf_rs_group_members_aud_s.nextval
     into l_group_member_audit_id
     from dual;


    /* CALL TABLE HANDLER */
   JTF_RS_GROUP_MEMBERS_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        x_group_member_audit_id   =>  l_group_member_audit_id,
                        x_group_member_id         =>  p_group_member_id,
                        x_new_group_id            =>  p_group_id,
                        x_old_group_id            =>  jtf_rs_group_members_pvt.g_moved_fr_group_id,
                        x_new_resource_id         =>  P_resource_id,
                        x_old_resource_id         =>  null,
                        x_new_person_id           =>  P_person_id,
                        x_old_person_id           =>  null,
                        x_new_object_version_number   => P_object_version_number,
                        X_OLD_object_version_number   => null,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id ,
                        X_LAST_UPDATE_DATE =>  l_date,
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
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END INSERT_MEMBER;

  /* FOR UPDATE */
  PROCEDURE   UPDATE_MEMBER(
    P_API_VERSION	    IN	NUMBER,
    P_INIT_MSG_LIST	    IN	VARCHAR2,
    P_COMMIT		    IN	VARCHAR2,
    P_GROUP_MEMBER_ID       IN  NUMBER,
    P_GROUP_ID              IN  NUMBER,
    P_RESOURCE_ID           IN  NUMBER,
    P_PERSON_ID             IN  NUMBER,
    P_OBJECT_VERSION_NUMBER IN NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2)
    IS
    CURSOR rr_old_cur(l_group_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
        IS
    SELECT  b.group_id   ,
            b.resource_id         ,
            b.person_id   ,
            b.object_version_number
     FROM  jtf_rs_group_members b
     WHERE  b.group_member_id = l_group_member_id;


--declare variables
--old value
l_group_id              JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE;
l_resource_id           JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE;
l_person_id         	 JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE;
l_object_version_number	JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE;



--old values
l_group_id_n              JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE;
l_resource_id_n           JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE;
l_person_id_n         	 JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE;
l_object_version_number_n	JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE;




rr_old_rec    rr_old_cur%rowtype;
l_group_member_audit_id jtf_rs_group_members_aud.group_member_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_MEMBER';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date ;
    l_user_id  Number ;
    l_login_id  Number ;


    BEGIN

        --Standard Start of API SAVEPOINT
	SAVEPOINT GROUP_AUDIT;

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


    open rr_old_cur(p_group_member_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if p_group_id  <> nvl(rr_old_rec.group_id, 0)
    then
       l_group_id :=  rr_old_rec.group_id;
       l_group_id_n :=  p_group_id;
    end if;
    if p_resource_id  <> nvl(rr_old_rec.resource_id,0)
    then
       l_resource_id :=  rr_old_rec.resource_id;
       l_resource_id_n:=  p_resource_id;
    end if;
     if p_person_id   <> nvl(rr_old_rec.person_id,0)
    then
       l_person_id   :=  rr_old_rec.person_id  ;
       l_person_id_n:=  p_person_id;
    end if;
    if p_object_version_number  <> rr_old_rec.object_version_number
    then
       l_object_version_number :=  rr_old_rec.object_version_number;
       l_object_version_number_n :=  p_object_version_number;
    end if;



   select jtf_rs_group_members_aud_s.nextval
     into l_group_member_audit_id
     from dual;


    /* CALL TABLE HANDLER */
   JTF_RS_GROUP_MEMBERS_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        x_group_member_audit_id   =>  l_group_member_audit_id,
                        x_group_member_id         =>  p_group_member_id,
                        x_new_group_id            =>  l_group_id_n,
                        x_old_group_id            =>  l_group_id,
                        x_new_resource_id         =>  l_resource_id_n,
                        x_old_resource_id         =>  l_resource_id,
                        x_new_person_id           =>  l_person_id_n,
                        x_old_person_id           =>  l_person_id,
                        X_new_object_version_number   => l_object_version_number_n,
                        X_old_object_version_number   => l_object_version_number,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id ,
                        X_LAST_UPDATE_DATE =>  l_date,
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
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    END UPDATE_MEMBER;


   --FOR DELETE

   PROCEDURE   DELETE_MEMBER(
    P_API_VERSION		IN	NUMBER,
	P_INIT_MSG_LIST		IN	VARCHAR2,
	P_COMMIT			IN	VARCHAR2,
    P_GROUP_MEMBER_ID   IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
    IS
    CURSOR rr_old_cur(l_group_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
        IS
    SELECT  b.group_id   ,
            b.resource_id         ,
            b.person_id   ,
            b.object_version_number
      FROM  jtf_rs_group_members b
     WHERE  b.group_member_id = l_group_member_id;


--declare variables
--old value
l_group_id              JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE;
l_resource_id           JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE;
l_person_id         	 JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE;
l_object_version_number  	JTF_RS_GROUP_MEMBERS.object_version_number%TYPE;




rr_old_rec    rr_old_cur%rowtype;
l_group_member_audit_id jtf_rs_group_members_aud.group_member_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_MEMBER';
	l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT GROUP_AUDIT;

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


    open rr_old_cur(p_group_member_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    l_group_id :=  rr_old_rec.group_id;
    l_resource_id :=  rr_old_rec.resource_id;
    l_person_id   :=  rr_old_rec.person_id  ;
    l_object_version_number:=  rr_old_rec.object_version_number;




   select jtf_rs_group_members_aud_s.nextval
     into l_group_member_audit_id
     from dual;


    /* CALL TABLE HANDLER */
   JTF_RS_GROUP_MEMBERS_AUD_PKG.INSERT_ROW (
                        X_ROWID => l_row_id,
                        x_group_member_audit_id   =>  l_group_member_audit_id,
                        x_group_member_id         =>  p_group_member_id,
                        x_new_group_id            =>  NULL,
                        x_old_group_id            =>  l_group_id,
                        x_new_resource_id         =>  NULL,
                        x_old_resource_id         =>  l_resource_id,
                        x_new_person_id           =>  NULL,
                        x_old_person_id           =>  l_person_id,
                        X_NEW_object_version_number   => NULL,
                        X_old_object_version_number   => l_object_version_number,
                        X_CREATION_DATE => l_date,
                        X_CREATED_BY => l_user_id ,
                        X_LAST_UPDATE_DATE =>  l_date,
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
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO group_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_MEM_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  delete_member;
END; -- Package Body JTF_RS_GROUP_MEMBERS_AUD_PVT

/
