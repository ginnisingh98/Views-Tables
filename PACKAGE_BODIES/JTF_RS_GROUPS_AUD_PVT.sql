--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUPS_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUPS_AUD_PVT" AS
  /* $Header: jtfrsagb.pls 120.0.12010000.3 2009/05/12 05:09:23 rgokavar ship $ */
-- API Name	: JTF_RS_GROUPS_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RS_GROUPS_AUD_VL
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 17 Jan 2000   S Choudhury   Created
-- Notes:
--
   g_pkg_name varchar2(30)	 := 'JTF_RS_GROUPS_AUD_PVT';

   /*FOR INSERT  */
    PROCEDURE   INSERT_GROUP(
    P_API_VERSION	    IN	NUMBER,
    P_INIT_MSG_LIST         IN	VARCHAR2,
    P_COMMIT		    IN	VARCHAR2,
    P_GROUP_ID              IN  NUMBER,
    P_GROUP_NUMBER          IN  VARCHAR2,
    P_EMAIL_ADDRESS         IN  VARCHAR2,
    P_START_DATE_ACTIVE     IN  DATE,
    P_END_DATE_ACTIVE       IN  DATE,
    P_ACCOUNTING_CODE       IN  VARCHAR2,
    P_EXCLUSIVE_FLAG        IN  VARCHAR2,
    P_GROUP_NAME            IN  VARCHAR2,
    P_GROUP_DESC            IN  VARCHAR2,
    P_OBJECT_VERSION_NUMBER  IN  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    P_TIME_ZONE             IN  NUMBER)
  IS

  l_group_audit_id jtf_rs_groups_aud_b.group_audit_id%type;
  l_row_id         varchar2(24) := null;

--other variables
    l_api_name    CONSTANT  VARCHAR2(30) := 'INSERT_GROUP';
    l_api_version CONSTANT  NUMBER	 :=1.0;
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


   select jtf_rs_groups_audit_s.nextval
     into l_group_audit_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GROUPS_AUD_PKG.INSERT_ROW (
                        X_ROWID                      => l_row_id,
                        x_group_audit_id             => l_group_audit_id,
                        x_group_id                   => p_group_id,
                        x_new_group_number           => p_group_number,
                        x_old_group_number           => null,
                        x_new_email_address          => p_email_address,
                        x_old_email_address          => null,
                        x_new_exclusive_flag         => p_exclusive_flag,
                        x_old_exclusive_flag         => null,
                        x_new_start_date_active      => p_start_date_active,
                        x_old_start_date_active      => null ,
                        x_new_end_date_active        => p_end_date_active,
                        x_old_end_date_active        => null,
                        x_new_accounting_code        => p_accounting_code,
                        x_old_accounting_code        => null,
                        x_new_object_version_number  => p_object_version_number ,
                        x_old_object_version_number  => null,
                        x_new_group_name             => p_group_name,
                        x_old_group_name             => null,
                        x_new_group_desc             => p_group_desc,
                        x_old_group_desc             => null,
                        x_creation_date              => l_date,
                        x_created_by                 => l_user_id ,
                        x_last_update_date           => l_date,
                        x_last_updated_by            => l_user_id,
                        x_last_update_login          => l_login_id,
                        x_new_time_zone              => p_time_zone,
                        x_old_time_zone              => null
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
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
     ROLLBACK TO group_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END INSERT_GROUP;

   /* FOR UPDATE */

   PROCEDURE   UPDATE_GROUP(
    P_API_VERSION	    IN	NUMBER,
    P_INIT_MSG_LIST         IN	VARCHAR2,
    P_COMMIT		    IN	VARCHAR2,
    P_GROUP_ID              IN  NUMBER,
    P_GROUP_NUMBER          IN  VARCHAR2,
    P_EMAIL_ADDRESS         IN  VARCHAR2,
    P_START_DATE_ACTIVE     IN  DATE,
    P_END_DATE_ACTIVE       IN  DATE,
    P_ACCOUNTING_CODE       IN  VARCHAR2,
    P_EXCLUSIVE_FLAG        IN  VARCHAR2,
    P_GROUP_NAME            IN  VARCHAR2,
    P_GROUP_DESC            IN  VARCHAR2,
    P_OBJECT_VERSION_NUMBER  IN  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    P_TIME_ZONE             IN  NUMBER )
    IS
    CURSOR rr_old_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
        IS
    SELECT  b.group_number   ,
            b.exclusive_flag    ,
            b.start_date_active  ,
            b.end_date_active   ,
            b.accounting_code    ,
            b.object_version_number,
            b.email_address,
            b.group_name,
            b.group_desc,
            b.time_zone
      FROM  jtf_rs_groups_vl B
     WHERE  b.group_id = l_group_id;



     --declare variables
--old value
l_group_number  	  JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE;
l_exclusive_flag    	  JTF_RS_GROUPS_B.EXCLUSIVE_FLAG%TYPE;
l_start_date_active  	  JTF_RS_GROUPS_B.START_DATE_ACTIVE%TYPE;
l_end_date_active   	  JTF_RS_GROUPS_B.END_DATE_ACTIVE%TYPE;
l_accounting_code   	  JTF_RS_GROUPS_B.ACCOUNTING_CODE%TYPE;
l_object_version_number	  JTF_RS_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE;
l_email_address           JTF_RS_GROUPS_B.EMAIL_ADDRESS%TYPE;
l_group_name 	        JTF_RS_GROUPS_VL.GROUP_NAME%TYPE := null ;
l_group_desc  	        JTF_RS_GROUPS_VL.GROUP_DESC%TYPE := null ;
l_time_zone               JTF_RS_GROUPS_B.TIME_ZONE%TYPE;





--old values
l_group_number_n  	      JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE;
l_exclusive_flag_n    	      JTF_RS_GROUPS_B.EXCLUSIVE_FLAG%TYPE;
l_start_date_active_n  	      JTF_RS_GROUPS_B.START_DATE_ACTIVE%TYPE;
l_end_date_active_n   	      JTF_RS_GROUPS_B.END_DATE_ACTIVE%TYPE;
l_accounting_code_n   	      JTF_RS_GROUPS_B.ACCOUNTING_CODE%TYPE;
l_object_version_number_n     JTF_RS_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE;
l_email_address_n             JTF_RS_GROUPS_B.EMAIL_ADDRESS%TYPE;
l_group_name_n 	            JTF_RS_GROUPS_VL.GROUP_NAME%TYPE := null ;
l_group_desc_n  	            JTF_RS_GROUPS_VL.GROUP_DESC%TYPE := null ;
l_time_zone_n                 JTF_RS_GROUPS_B.TIME_ZONE%TYPE;

rr_old_rec    rr_old_cur%rowtype;

l_group_audit_id jtf_rs_groups_aud_b.group_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_GROUP';
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


    open rr_old_cur(p_group_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if p_group_number  <> nvl(rr_old_rec.group_number, 'x')
    then
       l_group_number :=  rr_old_rec.group_number;
       l_group_number_n :=  p_group_number;
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
    if p_accounting_code  <> nvl(rr_old_rec.accounting_code , 'x')
    then
       l_accounting_code  :=  rr_old_rec.accounting_code ;
       l_accounting_code_n:=  p_accounting_code ;
    end if;
    if p_group_name  <> nvl(rr_old_rec.group_name, 'x')
    then
       l_group_name  :=  rr_old_rec.group_name ;
       l_group_name_n  :=  p_group_name;
    end if;
    if p_group_desc  <> nvl(rr_old_rec.group_desc, 'x')
    then
       l_group_desc :=  rr_old_rec.group_desc ;
       l_group_desc_n  :=  p_group_desc ;
    end if;
    if p_accounting_code  <> rr_old_rec.accounting_code
    then
       l_accounting_code :=  rr_old_rec.group_desc ;
       l_accounting_code_n  :=  p_accounting_code ;
    end if;
    if p_object_version_number  <> rr_old_rec.object_version_number
    then
       l_object_version_number :=  rr_old_rec.object_version_number ;
       l_object_version_number_n  :=  p_object_version_number ;
    end if;
    if nvl(p_email_address,'r')  <> nvl(rr_old_rec.email_address, 'r')
    then
       l_email_address :=  rr_old_rec.email_address ;
       l_email_address_n  :=  p_email_address;
    end if;
    if p_time_zone  <> nvl(rr_old_rec.time_zone, -99)
    then
       l_time_zone :=  rr_old_rec.time_zone;
       l_time_zone_n :=  p_time_zone;
    end if;

   select jtf_rs_groups_audit_s.nextval
     into l_group_audit_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GROUPS_AUD_PKG.INSERT_ROW (
                        X_ROWID                       => l_row_id,
                        x_group_audit_id              => l_group_audit_id,
                        x_group_id                    => p_group_id,
                        x_new_group_number            => l_group_number_n,
                        x_old_group_number            => l_group_number,
                        x_new_email_address           => l_email_address_n,
                        x_old_email_address           => l_email_address,
                        x_new_exclusive_flag          => l_exclusive_flag_n,
                        x_old_exclusive_flag          => l_exclusive_flag,
                        X_NEW_START_DATE_ACTIVE       => l_start_date_active_n,
                        X_OLD_START_DATE_ACTIVE       => l_start_date_active,
                        X_NEW_END_DATE_ACTIVE         => l_end_date_active_n,
                        X_OLD_END_DATE_ACTIVE         => l_end_date_active,
                        x_new_accounting_code         => l_accounting_code_n,
                        x_old_accounting_code         => l_accounting_code,
                        x_new_object_version_number   => l_object_version_number_n,
                        x_old_object_version_number   => l_object_version_number,
                        x_new_group_name              => l_group_name_n,
                        x_old_group_name              => l_group_name,
                        x_new_group_desc              => l_group_desc_n,
                        x_old_group_desc              => l_group_desc,
                        x_creation_date               => l_date,
                        x_created_by                  => l_user_id ,
                        x_last_update_date            => l_date,
                        x_last_updated_by             => l_user_id,
                        x_last_update_login           => l_login_id,
                        x_new_time_zone               => l_time_zone_n,
                        x_old_time_zone                   => l_time_zone
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
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
     ROLLBACK TO group_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    END  UPDATE_GROUP;


    PROCEDURE   DELETE_GROUP(
    P_API_VERSION	IN  NUMBER,
    P_INIT_MSG_LIST	IN  VARCHAR2,
    P_COMMIT		IN  VARCHAR2,
    P_GROUP_ID          IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
    IS
    CURSOR rr_old_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
        IS
     SELECT  b.group_number   ,
            b.exclusive_flag    ,
            b.start_date_active  ,
            b.end_date_active   ,
            b.accounting_code    ,
            b.object_version_number,
            b.email_address,
            b.group_name,
            b.group_desc,
            b.time_zone
      FROM  jtf_rs_groups_vl B
     WHERE  b.group_id = l_group_id;


     --declare variables
--old value
l_group_number  	  JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE;
l_exclusive_flag    	  JTF_RS_GROUPS_B.EXCLUSIVE_FLAG%TYPE;
l_start_date_active  	  JTF_RS_GROUPS_B.START_DATE_ACTIVE%TYPE;
l_end_date_active   	  JTF_RS_GROUPS_B.END_DATE_ACTIVE%TYPE;
l_accounting_code   	  JTF_RS_GROUPS_B.ACCOUNTING_CODE%TYPE;
l_object_version_number	  JTF_RS_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE;
l_email_address           JTF_RS_GROUPS_B.EMAIL_ADDRESS%TYPE;
l_group_name 	          JTF_RS_GROUPS_VL.GROUP_NAME%TYPE := null ;
l_group_desc  	          JTF_RS_GROUPS_VL.GROUP_DESC%TYPE := null ;
l_time_zone               JTF_RS_GROUPS_B.TIME_ZONE%TYPE;

rr_old_rec    rr_old_cur%rowtype;

l_group_audit_id jtf_rs_groups_aud_b.group_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name    CONSTANT VARCHAR2(30)   := 'DELETE_GROUP';
    l_api_version CONSTANT NUMBER      :=  1.0;
    l_date        Date                 := sysdate;
    l_user_id     Number := 1;
    l_login_id    Number := 1;


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


    open rr_old_cur(p_group_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    l_group_number :=  rr_old_rec.group_number;
    l_start_date_active :=  rr_old_rec.start_date_active;
    l_end_date_active  :=  rr_old_rec.end_date_active ;
    l_accounting_code  :=  rr_old_rec.accounting_code ;
    l_group_name       :=  rr_old_rec.group_name ;
    l_group_desc       :=  rr_old_rec.group_desc ;
    l_exclusive_flag   :=  rr_old_rec.group_desc ;
    l_object_version_number  :=  rr_old_rec.object_version_number;
    l_email_address          :=  rr_old_rec.email_address;
    l_time_zone        :=  rr_old_rec.time_zone ;


   select jtf_rs_groups_audit_s.nextval
     into l_group_audit_id
     from dual;

    /* CALL TABLE HANDLER */
   JTF_RS_GROUPS_AUD_PKG.INSERT_ROW (
                        X_ROWID                       => l_row_id,
                        x_group_audit_id              => l_group_audit_id,
                        x_group_id                    => p_group_id,
                        x_new_group_number            => null,
                        x_old_group_number            => l_group_number,
                        x_new_email_address           => null,
                        x_old_email_address           => l_email_address,
                        x_new_exclusive_flag          => null,
                        x_old_exclusive_flag          => l_exclusive_flag,
                        X_NEW_START_DATE_ACTIVE       => null,
                        X_OLD_START_DATE_ACTIVE       => l_start_date_active,
                        X_NEW_END_DATE_ACTIVE         => null,
                        X_OLD_END_DATE_ACTIVE         => l_end_date_active,
                        x_new_accounting_code         => null,
                        x_old_accounting_code         => l_accounting_code,
                        x_new_object_version_number   => null,
                        x_old_object_version_number   => l_object_version_number,
                        x_new_group_name              => null,
                        x_old_group_name              => l_group_name,
                        x_new_group_desc              => null,
                        x_old_group_desc              => l_group_desc,
                        x_creation_date               => l_date,
                        x_created_by                  => l_user_id ,
                        x_last_update_date            => l_date,
                        x_last_updated_by             => l_user_id,
                        x_last_update_login           => l_login_id,
                        x_new_time_zone               => null,
                        x_old_time_zone               => l_time_zone
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
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
     ROLLBACK TO group_audit;
      fnd_message.set_name ('JTF', 'JTF_RS_GROUP_AUDIT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END DELETE_GROUP;
END; -- Package Body JTF_RS_GROUPS_AUD_PVT

/
