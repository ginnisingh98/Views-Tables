--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_DENORM_PVT" AS
  /* $Header: jtfrsvdb.pls 120.1 2005/06/13 21:15:33 baianand ship $ */
-- API Name	: JTF_RS_GROUP_DENORM_PVT
-- Type		: Private
-- Purpose	: Inserts/Update the JTF_RS_GROUP_DENORM_PVT table based on changes in jtf_rs_group_relations
-- Modification History
-- DATE		 NAME	       PURPOSE
--              S Choudhury   Created
-- Notes:
--
  g_pkg_name varchar2(30)	 := 'JTF_RS_GROUP_DENORM_PVT';

-------  USED ONLY BY "NO CONNECT BY" SECTION - BEGIN
 TYPE REL_RECORD_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE,
    level                NUMBER);


  TYPE rel_table IS TABLE OF REL_RECORD_TYPE INDEX BY BINARY_INTEGER;
  g_parent_tab rel_table;
  g_child_tab rel_table;


  FUNCTION getDirectParent(p_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                           p_level JTF_RS_GROUPS_DENORM.DENORM_LEVEL%type,
                           p_parent_group_id JTF_RS_GROUPS_DENORM.parent_group_id%type,
	                   p_start_date JTF_RS_GROUPS_DENORM.start_date_active%TYPE,
                           p_end_date JTF_RS_GROUPS_DENORM.end_date_active%TYPE) RETURN NUMBER
  IS
    CURSOR prnt_cur IS
      SELECT A.RELATED_GROUP_ID FROM JTF_RS_GRP_RELATIONS A
      WHERE A.GROUP_ID = P_GROUP_ID
         AND NVL(A.DELETE_FLAG, 'N') <> 'Y'
         AND A.START_DATE_ACTIVE <= P_START_DATE
         AND NVL(P_END_DATE, P_START_DATE) <= NVL(A.END_DATE_ACTIVE,
             NVL(P_END_DATE, P_START_DATE))
         ORDER BY A.START_DATE_ACTIVE; -- just in case there are multiple
                        -- records(dirty data).. to have predictable result
    prnt_rec prnt_cur%rowtype;
  BEGIN
    if (p_level < 2) then
      return p_parent_group_id;
    end if;
    open prnt_cur;
    fetch prnt_cur into prnt_rec;
    if (prnt_cur%found) then
      close prnt_cur;
      return prnt_rec.related_group_id;
    end if;
    close prnt_cur;
    return NULL;
  EXCEPTION
   WHEN OTHERS
    THEN
      if prnt_cur%isopen then
        close prnt_cur;
      end if;
      raise;
  END;
-------  USED ONLY BY "NO CONNECT BY" SECTION - END
-------  FORWARD DECLARATION OF PROCEDURES In "NO CONNECT BY" SECTION - BEGIN
/* These are the procedures which are clones of correponding
   procedures with no "_NO_CON". These procedures have the same
   processing logic as their respective no "_NO_CON" procedures
   except that they use POPULATE_PARENT_TABLE and
   POPULATE_CHILD_TABLE procedures to get same result as connect
   by loop in the no "_NO_CON" procedures.
   These procedures were created due to escalations and
   urgent one off requirement for Bug # 2140655, 2428389 and 2716624,
   which were due to connect by error, for which there was no plausible
   solution possible, other than simulating connect by thru PL/SQL.
   These procedures are called by respective no "_NO_CON" procedures
   when there is connect by loop exception.
   Due to the major repeation of processing logic code changes
   must be repelated in both "_NO_CON" and no "_NO_CON" procedures.
   Hari, Nimit, Nishant. */
 PROCEDURE   INSERT_GROUPS_NO_CON(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );

   PROCEDURE  UPDATE_GROUPS_NO_CON(
               P_API_VERSION    IN   NUMBER,
               P_INIT_MSG_LIST	IN   VARCHAR2,
               P_COMMIT		IN   VARCHAR2,
               p_group_id       IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
               X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
               X_MSG_COUNT      OUT NOCOPY  NUMBER,
               X_MSG_DATA       OUT NOCOPY  VARCHAR2 );

   PROCEDURE   DELETE_GRP_RELATIONS_NO_CON(
                P_API_VERSION       IN  NUMBER,
                P_INIT_MSG_LIST     IN  VARCHAR2,
                P_COMMIT            IN  VARCHAR2,
                p_group_relate_id    IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_group_id           IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_related_group_id   IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA       OUT NOCOPY VARCHAR2);

 PROCEDURE   INSERT_GROUPS_PARENT_NO_CON(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 );

-------  FORWARD DECLARATION OF PROCEDURES In "NO CONNECT BY" SECTION - END

------ CONNECT BY PRIOR - SECTION - Starts
------ The original procedures that are using connect by prior
------ These procedures are modified to call their corresponding
------ "_NO_CON" procedures in the next section (NO CONNECT BY - SECTION)
------ in case of connect by loop error/exception.


     PROCEDURE   CREATE_RES_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
     IS

      CURSOR c_dup(x_group_id JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
		  x_parent_group_id	JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT  den.group_id
            FROM  jtf_rs_groups_denorm den
           WHERE  den.group_id = x_group_id
	     AND  den.parent_group_id = x_parent_group_id;

/*
             AND  den.start_date_active = l_start_date
             AND  den.end_date_active   = l_end_date; */

  CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
		 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE group_id = x_group_id;

--Declare the variables
--
    dup	c_dup%ROWTYPE;

   l_api_name CONSTANT VARCHAR2(30) := 'CREATE_RES_GROUPS';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;

    l_actual_parent_id NUMBER := null;

 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


--fetch the start date and the end date for the group
  OPEN c_date(p_group_id);
 FETCH c_date INTO l_start_date, l_end_date;
 CLOSE c_date;


  -- insert a record for the group id that has been passed
  OPEN c_dup(p_group_id, p_group_id);
  FETCH c_dup into dup;
  IF (c_dup%NOTFOUND)
  THEN

   --insert the record for the group with itself as the parent group

    SELECT jtf_rs_groups_denorm_s.nextval
      INTO l_DENORM_GRP_ID
      FROM dual;

    l_actual_parent_id :=  getDirectParent(p_group_id,
                                           0,
                                           p_group_id,
                                           trunc(l_start_date),
                                           trunc(l_end_date));
    jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => p_group_id,
			X_PARENT_GROUP_ID => p_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date),
                        X_END_DATE_ACTIVE => trunc(l_end_date),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => 0) ;


   END IF;
   CLOSE c_dup;


   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  CREATE_RES_GROUPS;



PROCEDURE  UPDATE_RES_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RES_GROUPS';

    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;
    l_return_status VARCHAR2(30) := fnd_api.g_ret_sts_success;
    L_MSG_DATA VARCHAR2(200);
    L_MSG_COUNT number;


   CURSOR denorm_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
       IS
    SELECT denorm_grp_id
     FROM  jtf_rs_groups_denorm
   WHERE   group_id = l_group_id
    AND    parent_group_id = l_group_id;

 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


  -- delete the rescord and create it again in denorm
  OPEN denorm_cur(p_group_id);
  FETCH denorm_cur into l_denorm_grp_id;

   IF (denorm_cur%FOUND)
   THEN
       jtf_rs_groups_denorm_pkg.delete_row(X_DENORM_GRP_ID =>   l_DENORM_GRP_ID);

       JTF_RS_GROUP_DENORM_PVT.CREATE_RES_GROUPS(
              P_API_VERSION     => 1.0,
              P_INIT_MSG_LIST   => null,
              P_COMMIT          => null,
              p_group_id        => p_group_id,
              X_RETURN_STATUS   => l_return_status,
              X_MSG_COUNT       => l_msg_count,
              X_MSG_DATA        => l_msg_data);

    END IF;
    CLOSE denorm_cur;


   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  UPDATE_RES_GROUPS;



--FOR INSERT in grp relate


 PROCEDURE   INSERT_GROUPS(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
  IS

       CURSOR c_parents(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
       IS
          SELECT rel.group_id,
		 rel.related_group_id,
                 rel.start_date_active,
		 rel.end_date_active,
                 rel.delete_flag,
                 level
            FROM jtf_rs_grp_relations rel
           WHERE relation_type = 'PARENT_GROUP'
         CONNECT BY rel.group_id = prior rel.related_group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y'
            AND rel.related_group_id <> x_group_id
           START WITH rel.group_id = x_group_id
             AND NVL(rel.delete_flag, 'N') <> 'Y';

     r_parents c_parents%rowtype;

      CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
		 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE group_id = x_group_id;

     CURSOR c_dup(x_group_id JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
		  x_parent_group_id	JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                  l_start_date_active   date,
                  l_end_date_active     date)
      IS
          SELECT  den.group_id
            FROM  jtf_rs_groups_denorm den
           WHERE  den.group_id = x_group_id
	     AND  den.parent_group_id = x_parent_group_id
             --AND  start_date_active = l_start_date_active
             AND  ((l_start_date_active  between den.start_date_active and
                                           nvl(den.end_date_active,l_start_date_active+1))
              OR (l_end_date_active between den.start_date_active
                                          and nvl(den.end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= den.start_date_active)
                          AND (l_end_date_active >= den.end_date_active
                                          OR l_end_date_active IS NULL)));

   CURSOR c_child(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                  l_start_date  date,
                 l_end_date date)
       IS
          SELECT rel.group_id,
		 rel.related_group_id,
                 rel.start_date_active,
		 rel.end_date_active,
                 level
            FROM jtf_rs_grp_relations rel
           WHERE relation_type = 'PARENT_GROUP'
         CONNECT BY  rel.related_group_id = prior rel.group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y'
            AND rel.group_id <> x_group_id
           START WITH rel.related_group_id = x_group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y';
--             AND rel.start_date_active between l_start_date and nvl(l_end_date, rel.start_date_active +1);


  r_child c_child%rowtype;

   ---------------------------------------------------------
   -- This is added on 12/24/2002 to fix connect by loop error for customer
   -- bug. In case of connect by loop exception, a new procedure will be called
   -- This way, the existing proccedure is not disturbed. But any code change in
   -- this procedure will need a modification in new parallel code.

   l_connect_by_loop_error EXCEPTION;--exception to handle connect by loop error
   PRAGMA EXCEPTION_INIT(l_connect_by_loop_error, -1436 );

  cb_p_api_version    number           := p_api_version;
  cb_p_init_msg_list  varchar2(10)     := P_INIT_MSG_LIST;
  cb_p_commit         varchar2(10)     := P_COMMIT;
  cb_p_group_id       JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_group_id;
   ---------------------------------------------------------

  TYPE CHILD_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE,
    level                NUMBER);


  TYPE child_table IS TABLE OF CHILD_type INDEX BY BINARY_INTEGER;
  l_child_tab child_table;

  i BINARY_INTEGER := 0;
  j BINARY_INTEGER := 0;

--Declare the variables
--
    dup	c_dup%ROWTYPE;
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GROUPS';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count   number;
    l_msg_data    varchar2(2000);

    l_start_date_active Date;
    l_end_date_active Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;


    l_prev_level number := 0;
    l_prev_par_level number := 0;

   TYPE LEVEL_INFO IS RECORD
  ( level           NUMBER,
    start_date      date,
    end_date        date);

  TYPE level_table IS TABLE OF level_info INDEX BY BINARY_INTEGER;

  level_child_table level_table;
  level_par_table level_table;

  l_actual_parent_id NUMBER := null;

  procedure populate_table(p_level      in number,
                           p_start_date in date,
                           p_end_date   in date,
                           l_flag       in varchar2)
  is
   l BINARY_INTEGER;
  begin
    if(l_flag = 'C')
    THEN
        l := 0;
        l := level_child_table.count;
        l := l + 1;
        level_child_table(l).level := p_level;
        level_child_table(l).start_date := p_start_date;
        level_child_table(l).end_date := p_end_date;
    ELSE

        l := 0;
        l := level_par_table.count;
        l := l + 1;
        level_par_table(l).level := p_level;
        level_par_table(l).start_date := p_start_date;
        level_par_table(l).end_date := p_end_date;


    END IF;

  end populate_table;

   procedure delete_table(p_level in number,
                           l_flag       in varchar2)
  is
    k BINARY_INTEGER;
    j BINARY_INTEGER;

  begin
    IF (l_flag = 'C')
    THEN
        IF level_child_table.COUNT > 0 THEN
            k := level_child_table.FIRST;
         LOOP
            IF level_child_table(k).level >= p_level THEN
                  j := k;
                IF k = level_child_table.LAST THEN
                  level_child_table.DELETE(j);
                  EXIT;
                ELSE
                  k:= level_child_table.NEXT(k);
                  level_child_table.DELETE(j);
                 END IF;
             ELSE
                 exit when k = level_child_table.LAST;
                 k:= level_child_table.NEXT(k);
             END IF;
         END LOOP;

      END IF;
   ELSE
     IF level_par_table.COUNT > 0 THEN
            k := level_par_table.FIRST;
         LOOP
            IF level_par_table(k).level >= p_level THEN
                  j := k;
            IF k = level_par_table.LAST THEN
                  level_par_table.DELETE(j);
             EXIT;
           ELSE
             k:= level_par_table.NEXT(k);
             level_par_table.DELETE(j);
           END IF;
         ELSE
           exit when k = level_par_table.LAST;
           k:= level_par_table.NEXT(k);
         END IF;
        END LOOP;

       END IF;
    END IF;

  end  delete_table;

  procedure get_table_date(p_level in number,
                           p_start_date out NOCOPY date,
                           p_end_date out NOCOPY date,
                           l_flag       in varchar2)
  is

      k BINARY_INTEGER := 0;

  begin
   IF(l_flag = 'C')
   THEN
     for k in 1..level_child_table.COUNT
     loop
        if level_child_table(k).level = p_level
        then
          p_start_date := level_child_table(k).start_date;
          p_end_date := level_child_table(k).end_date;
          exit;
        end if;
     end loop;

   ELSE
     for k in 1..level_par_table.COUNT
     loop

        if level_par_table(k).level = p_level
        then
          p_start_date := level_par_table(k).start_date;
          p_end_date := level_par_table(k).end_date;
          exit;
        end if;
     end loop;
   END IF;
  end get_table_date;


 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


--fetch the start date and the end date for the group
 OPEN c_date(p_group_id);
 FETCH c_date INTO l_start_date, l_end_date;
 CLOSE c_date;



  --get all the child groups for this group
  open c_child(p_group_id, l_start_date, l_end_date);

  fetch c_child INTO r_child;
  WHILE(c_child%found)
  loop
       i := i + 1;
       l_child_tab(i).p_group_id            := r_child.group_id;
       l_child_tab(i).p_related_group_id    := r_child.related_group_id;
       l_child_tab(i).p_start_date_active   := r_child.start_date_active;
       l_child_tab(i).p_end_date_active     := r_child.end_date_active;
       l_child_tab(i).level                 := r_child.level;

       FETCH c_child   INTO r_child;
   END LOOP; --end of par_mgr_cur
   CLOSE c_child;
   IF(l_child_tab.COUNT > 0)
   THEN
     --changed l_start_date to l_start_date_active
     l_start_date_active := l_child_tab(1).p_start_date_active;
     l_end_date_active   := l_child_tab(1).p_end_date_active;
   END IF;
   --insert a record with this  group for the child group also
   i := 0;


   FOR I IN 1 .. l_child_tab.COUNT
   LOOP
           IF(l_child_tab(i).level = 1)
           THEN
               l_start_date_active := l_child_tab(i).p_start_date_active;
               l_end_date_active   := l_child_tab(i).p_end_date_active;
               delete_table(l_child_tab(i).level, 'C');
           ELSIF(l_prev_level >= l_child_tab(i).level)
           THEN
             get_table_date(l_child_tab(i).level - 1, l_start_date_active, l_end_date_active,'C');
             delete_table(l_child_tab(i).level, 'C');
           END IF; -- end of level check


            --assign start date and end date for which this relation is valid


            IF(l_start_date_active < l_child_tab(i).p_start_date_active)
            THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
            ELSIF(l_start_date_active is null)
            THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
            ELSE
                 l_start_date_active := l_start_date_active;
            END IF;

            IF(l_end_date_active > l_child_tab(i).p_end_date_active)
            THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
            ELSIF(l_child_tab(i).p_end_date_active IS NULL)
            THEN
                 l_end_date_active := l_end_date_active;
            ELSIF(l_end_date_active IS NULL)
            THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
            END IF;


           IF (l_child_tab(i).p_related_group_id = P_GROUP_ID)
           THEN
              l_immediate_parent_flag := 'Y';
           ELSE
              l_immediate_parent_flag := 'N';
           END IF;
           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           THEN
               OPEN c_dup(l_child_tab(i).p_group_id, p_group_id, l_start_date_active, l_end_date_active);
               FETCH c_dup into dup;
               IF (c_dup%NOTFOUND)
               THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;


                   l_actual_parent_id :=   getDirectParent(l_child_tab(i).p_group_id,
                                           l_child_tab(i).level,
                                           p_group_id,
                                           trunc(l_start_date_active),
                                           trunc(l_end_date_active));

                   jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => l_child_tab(i).p_group_id,
			X_PARENT_GROUP_ID => p_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID =>  l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_active),
                        X_END_DATE_ACTIVE => trunc(l_end_date_active),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL             => l_child_tab(i).level);

                        JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => l_child_tab(i).p_group_id ,
                                P_PARENT_GROUP_ID  => p_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_active   ,
                                P_END_DATE_ACTIVE    => l_end_date_active   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL         => l_child_tab(i).level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;

               END IF;  -- end of duplicate check
               CLOSE c_dup;
            END IF; -- end of start date < end date check

            --populating the plsql table
            l_prev_level := l_child_tab(i).level;
            populate_table(l_prev_level, l_start_date_active, l_end_date_active, 'C');


   END LOOP;

   -- delete all rows from pl/sql table for level
--   delete_table(1, 'C');


 OPEN c_parents(p_group_id);
 FETCH c_parents INTO r_parents;

 l_prev_par_level := 0;
 --FOR r_parents IN c_parents(p_group_id)
 WHILE(c_parents%FOUND)
 LOOP
--dbms_output.put_line('444');
    IF(r_parents.delete_flag <> 'Y')
    THEN
       l_start_date := r_parents.start_date_active;
       l_end_date := r_parents.end_date_active;
       IF (r_parents.related_group_id IS NOT NULL)
       THEN
           IF(l_prev_par_level >= r_parents.level)
           THEN
             get_table_date(r_parents.level - 1, l_start_date_1, l_end_date_1, 'P');
             delete_table(r_parents.level, 'P');
           END IF; -- end of level check

           --if parent group id is null then this group has no upward hierarchy structure, hence no records
           --are to be inserted in the denormalized table
           IF r_parents.GROUP_ID = P_GROUP_ID
           THEN
              l_immediate_parent_flag := 'Y';
	      l_start_date_1 := r_parents.start_date_active;
    	      l_end_date_1 := r_parents.end_date_active;

           ELSE
              l_immediate_parent_flag := 'N';
              if((l_start_date_1 < l_start_date)
                 OR (l_start_date_1 is null))
              then
                   l_start_date_1 := l_start_date;
              end if;
              if(l_end_date < l_end_date_1)
              then
                   l_end_date_1 := l_end_date;
              elsif(l_end_date_1 is null)
              then
                   l_end_date_1 := l_end_date;
              end if;
           END IF;
           IF(l_start_date_1 <= nvl(l_end_date_1, l_start_date_1))
           THEN
              OPEN c_dup(p_group_id, r_parents.related_group_id, l_start_date_1, l_end_date_1);

              FETCH c_dup into dup;
              IF (c_dup%NOTFOUND)
              THEN

                SELECT jtf_rs_groups_denorm_s.nextval
                INTO l_denorm_grp_id
                FROM dual;

                l_actual_parent_id := getDirectParent(p_group_id,
                                          r_parents.level,
                                          r_parents.related_group_id,
                                          trunc(l_start_date_1),
                                          trunc(l_end_date_1));

                jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => p_group_id,
			X_PARENT_GROUP_ID => r_parents.related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_1),
                        X_END_DATE_ACTIVE => trunc(l_end_date_1),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => r_parents.level);



                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => p_group_id ,
                                P_PARENT_GROUP_ID  => r_parents.related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_1   ,
                                P_END_DATE_ACTIVE    => l_end_date_1   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL         => r_parents.level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;
            END IF;
            CLOSE c_dup;


        --insert a record with this parent group for the child group also
            l_prev_level := 0;
            i := 0;
            --initialize dates
            FOR i IN 1 .. l_child_tab.COUNT
            LOOP
              IF(l_child_tab(i).level = 1)
              THEN
                 l_start_date_active := l_start_date_1;
                 l_end_date_active := l_end_date_1;
                 delete_table(l_child_tab(i).level, 'C');
              ELSIF(l_prev_level >= l_child_tab(i).level)
              THEN
                   get_table_date(l_child_tab(i).level - 1, l_start_date_active, l_end_date_active,'C');
                   delete_table(l_child_tab(i).level, 'C');
              END IF; -- end of level check
             --dbms_output.put_line('group..'||to_char(l_child_tab(i).p_group_id));
             --dbms_output.put_line(to_char(l_start_date_active, 'dd-mon-yyyy')||'..'|| to_char(l_end_date_active, 'dd-mon-yyyy'));
             --dbms_output.put_line(to_char(l_child_tab(i).p_start_date_active, 'dd-mon-yyyy') ||'..'||to_char(l_child_tab(i).p_end_date_active, 'dd-mon-yyyy'));

            --assign start date and end date for which this relation is valid
              IF(l_start_date_active < l_child_tab(i).p_start_date_active)
              THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
              ELSIF(l_start_date_active is null)
              THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
              ELSE
                 l_start_date_active := l_start_date_active;
              END IF;

              IF(l_end_date_active > l_child_tab(i).p_end_date_active)
              THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
              ELSIF(l_child_tab(i).p_end_date_active IS NULL)
              THEN
                 l_end_date_active := l_end_date_active;
              ELSIF(l_end_date_active IS NULL)
              THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
              END IF;

              l_immediate_parent_flag := 'N';
            IF(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
            THEN
                OPEN c_dup(l_child_tab(i).p_group_id, r_parents.related_group_id, l_start_date_active, l_end_date_active);
                FETCH c_dup into dup;
                IF (c_dup%NOTFOUND)
                THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;

                   l_actual_parent_id := getDirectParent(l_child_tab(i).p_group_id,
                                          l_child_tab(i).level + r_parents.level,
                                          r_parents.related_group_id,
                                          trunc(l_start_date_active),
                                          trunc(l_end_date_active));
                   jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => l_child_tab(i).p_group_id,
			X_PARENT_GROUP_ID => r_parents.related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_active),
                        X_END_DATE_ACTIVE => trunc(l_end_date_active),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => l_child_tab(i).level + r_parents.level);

                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         =>  l_child_tab(i).p_group_id ,
                                P_PARENT_GROUP_ID  => r_parents.related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_active   ,
                                P_END_DATE_ACTIVE    => l_end_date_active   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL        => l_child_tab(i).level + r_parents.level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;

                END IF;  -- end of duplicate check
               CLOSE c_dup;

             END IF; -- end of start_date_active check

           --populating the plsql table
              l_prev_level := l_child_tab(i).level;
              populate_table(l_prev_level, l_start_date_active, l_end_date_active, 'C');

           END LOOP;  -- end of child tab insert
           -- delete all rows from pl/sql table for level
             delete_table(1, 'C');

          END IF; -- end of parent start date check
          --populating the plsql table
           l_prev_par_level := r_parents.level;
           populate_table(l_prev_par_level, l_start_date_1, l_end_date_1, 'P');
       END IF; --end of group id check

      END IF; -- end of delete flag check



      FETCH c_parents INTO r_parents;
     END LOOP;
     CLOSE c_parents;


   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN l_connect_by_loop_error
    THEN
      ROLLBACK TO group_denormalize;
      BEGIN
	INSERT_GROUPS_NO_CON(
		P_API_VERSION     => cb_p_api_version,
		P_INIT_MSG_LIST   => cb_p_init_msg_list,
		P_COMMIT          => cb_p_commit,
		p_group_id        => cb_p_group_id,
		X_RETURN_STATUS   => x_return_status,
		X_MSG_COUNT       => x_msg_count,
		X_MSG_DATA        => x_msg_data );
      EXCEPTION
	WHEN OTHERS
	THEN
	  fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	  fnd_message.set_token('P_SQLCODE',SQLCODE);
	  fnd_message.set_token('P_SQLERRM',SQLERRM);
	  fnd_message.set_token('P_API_NAME',l_api_name);
	  FND_MSG_PUB.add;
	  x_return_status := fnd_api.g_ret_sts_unexp_error;
	  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      END;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize;

      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --ND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  INSERT_GROUPS;


--Start of procedure Body
--FOR UPDATE

   PROCEDURE  UPDATE_GROUPS(
               P_API_VERSION    IN   NUMBER,
               P_INIT_MSG_LIST	IN   VARCHAR2,
               P_COMMIT		IN   VARCHAR2,
               p_group_id       IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
               X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
               X_MSG_COUNT      OUT NOCOPY  NUMBER,
               X_MSG_DATA       OUT NOCOPY  VARCHAR2 )
   IS

	CURSOR c_child(x_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
	IS
           SELECT rel.group_id,
		 rel.related_group_id,
                 rel.start_date_active,
		 rel.end_date_active
            FROM jtf_rs_grp_relations rel
           WHERE relation_type = 'PARENT_GROUP'
         CONNECT BY rel.related_group_id = prior rel.group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y'
            AND rel.group_id <> x_group_id
           START WITH rel.group_id = x_group_id
             AND NVL(rel.delete_flag, 'N') <> 'Y';



      CURSOR c_group_denorm(l_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
          IS
       SELECT denorm_grp_id,
              group_id,
              parent_group_id
        FROM JTF_RS_GROUPS_DENORM
	 WHERE group_id = l_group_id
     AND   PARENT_GROUP_ID <> L_GROUP_ID;


   ---------------------------------------------------------
   -- This is added on 12/24/2002 to fix connect by loop error for customer
   -- bug. In case of connect by loop exception, a new procedure will be called
   -- This way, the existing proccedure is not disturbed. But any code change in
   -- this procedure will need a modification in new parallel code.
   l_connect_by_loop_error EXCEPTION;--exception to handle connect by loop error
   PRAGMA EXCEPTION_INIT(l_connect_by_loop_error, -1436 );

  cb_p_api_version    number           := p_api_version;
  cb_p_init_msg_list  varchar2(10)     := P_INIT_MSG_LIST;
  cb_p_commit         varchar2(10)     := P_COMMIT;
  cb_p_group_id       JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_group_id;
   ---------------------------------------------------------

	--Declare the variables
	--

	l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_GROUPS';
	l_api_version	CONSTANT	   NUMBER	 :=1.0;

   l_date     DATE;
   l_user_id  NUMBER := 1;
   l_login_id NUMBER := 1;
    l_return_status      VARCHAR2(200) := fnd_api.g_ret_sts_success;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
    BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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


	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

        l_date     := sysdate;
        l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
        l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);
	--delete the previous hierarchy for the group
	for r_group_denorm IN c_group_denorm(p_group_id)
	loop
            JTF_RS_REP_MGR_DENORM_PVT.DELETE_REP_MGR  (
              P_API_VERSION     => 1.0,
              P_GROUP_ID        => r_group_denorm.group_id,
              P_PARENT_GROUP_ID => r_group_denorm.parent_group_id,
              X_RETURN_STATUS   => l_return_status,
              X_MSG_COUNT       => l_msg_count,
              X_MSG_DATA        => l_msg_data);



             IF(l_return_status <>  fnd_api.g_ret_sts_success)
             THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        RAISE fnd_api.g_exc_error;
             END IF;
	    jtf_rs_groups_denorm_pkg.delete_row(r_group_denorm.DENORM_GRP_ID);
	end loop;



	--delete the hiearchy of all the child records of the group
	FOR r_child IN c_child(p_group_id)
  	LOOP

	    for r_group_denorm IN c_group_denorm(r_child.group_id)
	    loop
               JTF_RS_REP_MGR_DENORM_PVT.DELETE_REP_MGR  (
                 P_API_VERSION     => 1.0,
                 P_GROUP_ID        => r_group_denorm.group_id,
                 P_PARENT_GROUP_ID => r_group_denorm.parent_group_id,
                 X_RETURN_STATUS   => l_return_status,
                 X_MSG_COUNT       => l_msg_count,
                 X_MSG_DATA        => l_msg_data);

                IF(l_return_status <>  fnd_api.g_ret_sts_success)
                THEN
                      x_return_status := fnd_api.g_ret_sts_error;
                      RAISE fnd_api.g_exc_error;
                END IF;

	        jtf_rs_groups_denorm_pkg.delete_row(r_group_denorm.DENORM_GRP_ID);
	    end loop;
        END LOOP;


        --rebuild the hiearchy of all the child records of the group
	FOR r_child IN c_child(p_group_id)
  	LOOP
	     JTF_RS_GROUP_DENORM_PVT.Insert_Groups(1.0,NULL, NULL,r_child.group_id, x_return_status, x_msg_count, x_msg_data);
	END LOOP;

        --rebuild the group hiearchy again
	JTF_RS_GROUP_DENORM_PVT.Insert_Groups(1.0,NULL, NULL,p_group_id, x_return_status, x_msg_count, x_msg_data);

   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN l_connect_by_loop_error
    THEN
      ROLLBACK TO group_denormalize;
      BEGIN
	UPDATE_GROUPS_NO_CON(
		P_API_VERSION     => cb_p_api_version,
		P_INIT_MSG_LIST   => cb_p_init_msg_list,
		P_COMMIT          => cb_p_commit,
		p_group_id        => cb_p_group_id,
		X_RETURN_STATUS   => x_return_status,
		X_MSG_COUNT       => x_msg_count,
		X_MSG_DATA        => x_msg_data );
      EXCEPTION
	WHEN OTHERS
	THEN
	  fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	  fnd_message.set_token('P_SQLCODE',SQLCODE);
	  fnd_message.set_token('P_SQLERRM',SQLERRM);
	  fnd_message.set_token('P_API_NAME',l_api_name);
	  FND_MSG_PUB.add;
	  x_return_status := fnd_api.g_ret_sts_unexp_error;
	  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      END;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END UPDATE_GROUPS;



   PROCEDURE   DELETE_GRP_RELATIONS(
                P_API_VERSION       IN  NUMBER,
                P_INIT_MSG_LIST     IN  VARCHAR2,
                P_COMMIT            IN  VARCHAR2,
                p_group_relate_id    IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_group_id           IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_related_group_id   IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA       OUT NOCOPY VARCHAR2)
  is

cursor  c_child(l_group_id number)
    is
 select group_id,
        related_group_id,
        start_date_active,
        end_date_active
  from  jtf_rs_grp_relations
 where  relation_type = 'PARENT_GROUP'
 connect by related_group_id = prior group_id
   and nvl(delete_flag, 'N') <> 'Y'
--   and group_id <> l_group_id
 start with related_group_id = l_group_id
   and nvl(delete_flag, 'N') <> 'Y';

  r_child c_child%rowtype;

  TYPE CHILD_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE);


  TYPE child_table IS TABLE OF CHILD_type INDEX BY BINARY_INTEGER;
  l_child_tab child_table;

  i BINARY_INTEGER := 0;

   CURSOR check_parent_cur(l_group_id   number,
                         l_related_group_id number)
       IS
    SELECT rel.group_id,
	   rel.related_group_id,
           rel.start_date_active,
	   rel.end_date_active
    FROM jtf_rs_grp_relations rel
  WHERE relation_type = 'PARENT_GROUP'
   AND  related_group_id = l_related_group_id
 CONNECT BY rel.group_id = prior rel.related_group_id
    AND NVL(rel.delete_flag, 'N') <> 'Y'
    --AND rel.related_group_id <> p_related_group_id
  START WITH rel.group_id = l_group_id
  AND NVL(rel.delete_flag, 'N') <> 'Y';

  check_parent_rec check_parent_cur%rowtype;

   CURSOR c_parent(l_group_id   number)
       IS
    SELECT rel.group_id,
	   rel.related_group_id,
           rel.start_date_active,
	   rel.end_date_active
    FROM jtf_rs_grp_relations rel
  WHERE relation_type = 'PARENT_GROUP'
 CONNECT BY rel.group_id = prior rel.related_group_id
    AND NVL(rel.delete_flag, 'N') <> 'Y'
    --AND rel.related_group_id <> p_related_group_id
  START WITH rel.group_id = p_related_group_id
  AND NVL(rel.delete_flag, 'N') <> 'Y';


  r_parent c_parent%rowtype;

  TYPE parent_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE);


  TYPE parent_table IS TABLE OF parent_type INDEX BY BINARY_INTEGER;
  l_parent_tab parent_table;

  j BINARY_INTEGER := 0;

  TYPE role_relate_TYPE IS RECORD
  ( role_relate_id      NUMBER,
    group_id            NUMBER);

  TYPE child_rol_rel_table IS TABLE OF role_relate_TYPE INDEX BY BINARY_INTEGER;
  l_child_rol_rel_tab child_rol_rel_table;

  k BINARY_INTEGER := 0;

  TYPE par_rol_rel_table IS TABLE OF role_relate_TYPE INDEX BY BINARY_INTEGER;
  l_par_rol_rel_tab par_rol_rel_table;

  l BINARY_INTEGER := 0;


  cursor rr_cur(l_no number)
     is
   select rel.role_relate_id,
          mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel
    where mem.group_id  = l_no
     and  nvl(mem.delete_flag , 'N') <> 'Y'
     and  mem.group_member_id = rel.role_resource_id
     and  rel.role_resource_type = 'RS_GROUP_MEMBER'
     and  nvl(rel.delete_flag, 'N') <> 'Y';

 role_rel_rec rr_cur%rowtype;

  cursor rr_mgr_cur(l_group_id number)
     is
   select rel.role_relate_id,
          mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel,
          jtf_rs_roles_b rol
    where mem.group_id  = l_group_id
     and  nvl(mem.delete_flag , 'N') <> 'Y'
     and  mem.group_member_id = rel.role_resource_id
     and  rel.role_resource_type = 'RS_GROUP_MEMBER'
     and  nvl(rel.delete_flag, 'N') <> 'Y'
     and  rel.role_id  =  rol.role_id
     and  (
            nvl(rol.manager_flag, 'N') = 'Y'
            or
            nvl(rol.admin_flag, 'N') = 'Y'
          );

  role_rel_mgr_rec rr_mgr_cur%rowtype;

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_GRP_RELATIONS';
    l_api_version	CONSTANT	   NUMBER	 :=1.0;
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;

  l_return_status      VARCHAR2(200) := fnd_api.g_ret_sts_success;
  l_msg_count          NUMBER;
  l_found             BOOLEAN := FALSE;

   ---------------------------------------------------------
   -- This is added on 12/24/2002 to fix connect by loop error for customer
   -- bug. In case of connect by loop exception, a new procedure will be called
   -- This way, the existing proccedure is not disturbed. But any code change in
   -- this procedure will need a modification in new parallel code.
   l_connect_by_loop_error EXCEPTION;--exception to handle connect by loop error
   PRAGMA EXCEPTION_INIT(l_connect_by_loop_error, -1436 );

  cb_p_api_version    number           := p_api_version;
  cb_p_init_msg_list  varchar2(10)     := P_INIT_MSG_LIST;
  cb_p_commit         varchar2(10)     := P_COMMIT;
  cb_p_group_id       JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_group_id;
  cb_p_group_relate_id JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_group_relate_id;
  cb_p_related_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_related_group_id;
   ---------------------------------------------------------

begin

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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


   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
      --to add the grooup_id as child as this will not be included in cursor
       k := 0;
       i := i + 1;
       l_child_tab(i).p_group_id := p_group_id;
       l_child_tab(i).p_related_group_id := p_related_group_id;

       -- get the role relate ids for this group
       open rr_cur(p_group_id);
       fetch rr_cur into role_rel_rec;
       while (rr_cur%found)
       loop
           k := K + 1;
           l_child_rol_rel_tab(k).role_relate_id := role_rel_rec.role_relate_id;
           l_child_rol_rel_tab(k).group_id := role_rel_rec.group_id;

           fetch rr_cur into role_rel_rec;
       end loop; -- end of role relate cur
       close rr_cur;
   --get all the child groups for this group
    open c_child(p_group_id);
    fetch c_child INTO r_child;

    while(c_child%found)
    loop

       i := i + 1;
       l_child_tab(i).p_group_id := r_child.group_id;
       l_child_tab(i).p_related_group_id := r_child.related_group_id;
       l_child_tab(i).p_start_date_active    := r_child.start_date_active;
       l_child_tab(i).p_end_date_active    := r_child.end_date_active;

       -- get the role relate ids for this group
       open rr_cur(r_child.group_id);
       fetch rr_cur into role_rel_rec;
       while (rr_cur%found)
       loop
           k := K + 1;
           l_child_rol_rel_tab(k).role_relate_id := role_rel_rec.role_relate_id;
           l_child_rol_rel_tab(k).group_id := role_rel_rec.group_id;

           fetch rr_cur into role_rel_rec;
       end loop; -- end of role relate cur
      close rr_cur;

       FETCH c_child   INTO r_child;
     END LOOP; --end of child_grp_cur
     CLOSE c_child;

   -- insert the parent group in the table as the parent cursor does not fetch this record
    l := 0;
    j := j + 1;

       l_parent_tab(j).p_group_id := p_group_id;
       l_parent_tab(j).p_related_group_id := p_related_group_id;

        -- get the role relate ids for this group
       open rr_mgr_cur(p_related_group_id);
       fetch rr_mgr_cur into role_rel_mgr_rec;
       while (rr_mgr_cur%found)
       loop
           l :=l + 1;
           l_par_rol_rel_tab(l).role_relate_id := role_rel_mgr_rec.role_relate_id;
           l_par_rol_rel_tab(l).group_id := role_rel_mgr_rec.group_id;

           fetch rr_mgr_cur into role_rel_mgr_rec;
       end loop;
       close rr_mgr_cur;

    open c_parent(p_group_id);
    fetch c_parent INTO r_parent;
    while(c_parent%found)
    loop
       j := j + 1;
       l_parent_tab(j).p_group_id := r_parent.group_id;
       l_parent_tab(j).p_related_group_id := r_parent.related_group_id;
       l_parent_tab(j).p_start_date_active    := r_parent.start_date_active;
       l_parent_tab(j).p_end_date_active    := r_parent.end_date_active;

         -- get the role relate ids for this group
       open rr_mgr_cur(r_parent.related_group_id);
       fetch rr_mgr_cur into role_rel_mgr_rec;
       while (rr_mgr_cur%found)
       loop
           l :=l + 1;
           l_par_rol_rel_tab(l).role_relate_id := role_rel_mgr_rec.role_relate_id;
           l_par_rol_rel_tab(l).group_id := role_rel_mgr_rec.group_id;

           fetch rr_mgr_cur into role_rel_mgr_rec;
       end loop; -- end of role relate cur
       close rr_mgr_cur;

       FETCH c_parent   INTO r_parent;


     END LOOP; --end of par_grp_cur
     CLOSE c_parent;

   --DELETE GROUP DENORM
    FOR j IN 1 .. l_parent_tab.COUNT
    LOOP
        FOR i IN 1 .. l_child_tab.COUNT
        LOOP
           --delete group denorm
            begin
		delete jtf_rs_groups_denorm
                 where group_id = l_child_tab(i).p_group_id
                  and  parent_group_id = l_parent_tab(j).p_related_group_id;
                exception
                    when others  then
                       fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

             end;

         end loop; -- end of child
    end loop; -- end of parent


      --DELETE REP MANAGER
    FOR l IN 1 .. l_par_rol_rel_tab.COUNT
    LOOP
        FOR k IN 1 .. l_child_rol_rel_tab.COUNT
        LOOP
           --delete rep mgr
            begin
		delete jtf_rs_rep_managers
                 where par_role_relate_id  = l_par_rol_rel_tab(l).role_relate_id
                  and  child_role_relate_id  = l_child_rol_rel_tab(k).role_relate_id;

                exception
                    when others  then
                        fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;
             end;

         end loop; -- end of child
    end loop; -- end of parent



   --now recreate hierarchy in case same parent existed for child through some diff branch

    FOR i IN 1 .. l_child_tab.COUNT
    LOOP
       l_found := FALSE;

       FOR j IN 1 .. l_parent_tab.COUNT
       LOOP
           open check_parent_cur(l_child_tab(i).p_group_id,
                                 l_parent_tab(j).p_related_group_id);
           fetch check_parent_cur into check_parent_rec;
           if (check_parent_cur%found)
           then
                 l_found := TRUE;
                 jtf_rs_group_denorm_pvt.insert_groups_parent(
                         p_api_version    =>    1.0,
                         p_commit          => 'T',
                         p_group_id => l_child_tab(i).p_group_id,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

                  IF(x_return_status <>  fnd_api.g_ret_sts_success)
                  THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_error;
                  END IF;

	   else
             close check_parent_cur;
           end if;
           if l_found
           then
              --since the entire parent hierarchy for the group has been built no point checking for further parents
              exit;
           end if;
       END LOOP; -- end of parent tab loop
       if(check_parent_cur%isopen)
       then
            close check_parent_cur;
       end if;

      /*  this has been moved to jtf_rs_groups_denorm.insert_groups_parent
       if(l_found)
       then
          --rebuild the parent rep managers for the parent role relate ids only
           FOR k IN 1 .. l_child_rol_rel_tab.COUNT
           LOOP
                  if(l_child_rol_rel_tab(k).group_id = l_child_tab(i).p_group_id)
                  then
                      jtf_rs_rep_mgr_denorm_pvt.insert_rep_mgr_parent(
                         p_api_version    =>    1.0,
                         p_commit          => 'T',
                         p_role_relate_id => l_child_rol_rel_tab(k).role_relate_id,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

                  end if; -- end of if group id same check
          END LOOP; -- end of loop for child role relate tab
     end if;-- end if l_found true check
     */
   END LOOP; -- end of child tab loop
   EXCEPTION
    WHEN l_connect_by_loop_error
    THEN
      ROLLBACK TO group_denormalize;
      BEGIN
	DELETE_GRP_RELATIONS_NO_CON(
		P_API_VERSION     => cb_p_api_version,
		P_INIT_MSG_LIST   => cb_p_init_msg_list,
		P_COMMIT          => cb_p_commit,
		p_group_id        => cb_p_group_id,
		p_group_relate_id => cb_p_group_relate_id,
		p_related_group_id => cb_p_related_group_id,
		X_RETURN_STATUS   => x_return_status,
		X_MSG_COUNT       => x_msg_count,
		X_MSG_DATA        => x_msg_data );
      EXCEPTION
	WHEN OTHERS
	THEN
	  fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	  fnd_message.set_token('P_SQLCODE',SQLCODE);
	  fnd_message.set_token('P_SQLERRM',SQLERRM);
	  fnd_message.set_token('P_API_NAME',l_api_name);
	  FND_MSG_PUB.add;
	  x_return_status := fnd_api.g_ret_sts_unexp_error;
	  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      END;
    WHEN fnd_api.g_exc_unexpected_error
    THEN

      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

end delete_grp_relations;

 PROCEDURE   INSERT_GROUPS_PARENT(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
  IS
       CURSOR c_parents(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
       IS
          SELECT rel.group_id,
		 rel.related_group_id,
                 rel.start_date_active,
		 rel.end_date_active,
                 rel.delete_flag,
                 level
            FROM jtf_rs_grp_relations rel
           WHERE relation_type = 'PARENT_GROUP'
         CONNECT BY rel.group_id = prior rel.related_group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y'
            AND rel.related_group_id <> x_group_id
           START WITH rel.group_id = x_group_id
             AND NVL(rel.delete_flag, 'N') <> 'Y';

     r_parents c_parents%rowtype;

      CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
		 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE group_id = x_group_id;

     CURSOR c_dup(x_group_id JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
		  x_parent_group_id	JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                  l_start_date_active   date,
                  l_end_date_active     date)
      IS
          SELECT  den.group_id
            FROM  jtf_rs_groups_denorm den
           WHERE  den.group_id = x_group_id
	     AND  den.parent_group_id = x_parent_group_id
             --AND  start_date_active = l_start_date_active
             AND  ((l_start_date_active  between den.start_date_active and
                                           nvl(den.end_date_active,l_start_date_active+1))
              OR (l_end_date_active between den.start_date_active
                                          and nvl(den.end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= den.start_date_active)
                          AND (l_end_date_active >= den.end_date_active
                                          OR l_end_date_active IS NULL)));

   ---------------------------------------------------------
   -- This is added on 12/24/2002 to fix connect by loop error for customer
   -- bug. In case of connect by loop exception, a new procedure will be called
   -- This way, the existing proccedure is not disturbed. But any code change in
   -- this procedure will need a modification in new parallel code.
   l_connect_by_loop_error EXCEPTION;--exception to handle connect by loop error
   PRAGMA EXCEPTION_INIT(l_connect_by_loop_error, -1436 );

  cb_p_api_version    number           := p_api_version;
  cb_p_init_msg_list  varchar2(10)     := P_INIT_MSG_LIST;
  cb_p_commit         varchar2(10)     := P_COMMIT;
  cb_p_group_id       JTF_RS_GROUPS_B.GROUP_ID%TYPE := p_group_id;
   ---------------------------------------------------------


--Declare the variables
--
    dup	c_dup%ROWTYPE;
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GROUPS_PARENT';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count   number;
    l_msg_data    varchar2(2000);

    l_start_date_active Date;
    l_end_date_active Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;

  l_actual_parent_id NUMBER := null;

  l_prev_level number := 0;

   TYPE LEVEL_INFO IS RECORD
  ( level           NUMBER,
    start_date      date,
    end_date        date);

  TYPE level_table IS TABLE OF level_info INDEX BY BINARY_INTEGER;

  level_value_table level_table;

  i BINARY_INTEGER := 0;

  procedure populate_table(p_level      in number,
                           p_start_date in date,
                           p_end_date   in date)
  is
   i BINARY_INTEGER;
  begin
    i := 0;
    i := level_value_table.count;
    i := i + 1;
    level_value_table(i).level := p_level;
    level_value_table(i).start_date := p_start_date;
    level_value_table(i).end_date := p_end_date;

  end populate_table;

  procedure delete_table(p_level in number)
  is
    k BINARY_INTEGER;
      j BINARY_INTEGER;

  begin
    IF level_value_table.COUNT > 0 THEN
      k := level_value_table.FIRST;
      LOOP
        IF level_value_table(k).level >= p_level THEN
           j := k;
           IF k = level_value_table.LAST THEN
             level_value_table.DELETE(j);
             EXIT;
           ELSE
             k:= level_value_table.NEXT(k);
             level_value_table.DELETE(j);
           END IF;
        ELSE
           exit when k = level_value_table.LAST;
           k:= level_value_table.NEXT(k);
        END IF;
      END LOOP;

    END IF;

  end  delete_table;

  procedure get_table_date(p_level in number,
                           p_start_date out NOCOPY date,
                           p_end_date out NOCOPY date)
  is

  k BINARY_INTEGER := 0;

  begin
     for k in 1..level_value_table.COUNT
     loop

        if level_value_table(k).level = p_level
        then
          p_start_date := level_value_table(k).start_date;
          p_end_date := level_value_table(k).end_date;
          exit;
        end if;
   end loop;
  end get_table_date;


 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


--fetch the start date and the end date for the group
 OPEN c_date(p_group_id);
 FETCH c_date INTO l_start_date, l_end_date;
 CLOSE c_date;

 OPEN c_parents(p_group_id);
 FETCH c_parents INTO r_parents;

 --FOR r_parents IN c_parents(p_group_id)
 WHILE(c_parents%FOUND)
 LOOP

    IF(r_parents.delete_flag <> 'Y')
    THEN
       l_start_date := r_parents.start_date_active;
       l_end_date := r_parents.end_date_active;
       IF (r_parents.related_group_id IS NOT NULL)
       THEN
           --if parent group id is null then this group has no upward hierarchy structure, hence no records
           --are to be inserted in the denormalized table
           IF(l_prev_level >= r_parents.level)
           THEN
             get_table_date(r_parents.level - 1, l_start_date_1, l_end_date_1);
             delete_table(r_parents.level);
           END IF; -- end of level check



           IF r_parents.GROUP_ID = P_GROUP_ID
           THEN
              l_immediate_parent_flag := 'Y';
	      l_start_date_1 := r_parents.start_date_active;
    	      l_end_date_1 := r_parents.end_date_active;

           ELSE
              l_immediate_parent_flag := 'N';
               if((l_start_date_1 < l_start_date)
                 OR (l_start_date_1 is null))
              then
                   l_start_date_1 := l_start_date;
              end if;
              if(l_end_date < l_end_date_1)
              then
                   l_end_date_1 := l_end_date;
              elsif(l_end_date_1 is null)
              then
                   l_end_date_1 := l_end_date;
              end if;

           END IF;

           if(l_start_date_1 <= nvl(l_end_date_1, l_start_date_1))
           then
               OPEN c_dup(p_group_id, r_parents.related_group_id, l_start_date_1, l_end_date_1);

               FETCH c_dup into dup;
               IF (c_dup%NOTFOUND)
               THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;

                     l_actual_parent_id := getDirectParent(p_group_id,
                                           r_parents.level,
                                           r_parents.related_group_id,
                                           trunc(l_start_date_1),
                                           trunc(l_end_date_1));

		      jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => p_group_id,
			X_PARENT_GROUP_ID => r_parents.related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_1),
                        X_END_DATE_ACTIVE => trunc(l_end_date_1),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => r_parents.level );


                       --call rep manager insert
                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => p_group_id ,
                                P_PARENT_GROUP_ID  => r_parents.related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_1   ,
                                P_END_DATE_ACTIVE    => l_end_date_1   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL       =>  r_parents.level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                      IF(l_return_status <>  fnd_api.g_ret_sts_success)
                      THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        RAISE fnd_api.g_exc_error;
                      END IF;
               END IF;
               CLOSE c_dup;
           END IF; -- end of st dt check

       END IF; --end of group id check
       --populating the plsql table
       l_prev_level := r_parents.level;
       populate_table(l_prev_level, l_start_date_1, l_end_date_1);

      END IF; -- end of delete flag check
      FETCH c_parents INTO r_parents;
     END LOOP;
     CLOSE c_parents;



   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN l_connect_by_loop_error
    THEN
      ROLLBACK TO group_denormalize;
      BEGIN
	INSERT_GROUPS_PARENT_NO_CON(
		P_API_VERSION     => cb_p_api_version,
		P_INIT_MSG_LIST   => cb_p_init_msg_list,
		P_COMMIT          => cb_p_commit,
		p_group_id        => cb_p_group_id,
		X_RETURN_STATUS   => x_return_status,
		X_MSG_COUNT       => x_msg_count,
		X_MSG_DATA        => x_msg_data );
      EXCEPTION
	WHEN OTHERS
	THEN
	  fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	  fnd_message.set_token('P_SQLCODE',SQLCODE);
	  fnd_message.set_token('P_SQLERRM',SQLERRM);
	  fnd_message.set_token('P_API_NAME',l_api_name);
	  FND_MSG_PUB.add;
	  x_return_status := fnd_api.g_ret_sts_unexp_error;
	  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      END;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize;

      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --ND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  INSERT_GROUPS_PARENT;

--Start of procedure Body
--FOR DELETE
--no being used after 23rd april changes

   PROCEDURE  DELETE_GROUPS(
                P_API_VERSION     IN  NUMBER,
                P_INIT_MSG_LIST	  IN  VARCHAR2,
                P_COMMIT          IN  VARCHAR2,
                p_group_id        IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2)
   IS
     CURSOR c_group_denorm(l_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
          IS
       SELECT denorm_grp_id,
              parent_group_id
        FROM  JTF_RS_GROUPS_DENORM
        WHERE group_id = l_group_id
        AND   parent_group_id <> l_group_id;  --added this

    CURSOR c_child_denorm(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                          l_parent_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE  )
          IS
       SELECT denorm_grp_id
        FROM  JTF_RS_GROUPS_DENORM
        WHERE group_id = l_group_id
          AND parent_group_id = l_parent_group_id;


  CURSOR c_child(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
       IS
          SELECT rel.group_id,
		 rel.related_group_id,
                 rel.start_date_active,
		 rel.end_date_active
            FROM jtf_rs_grp_relations rel
           WHERE relation_type = 'PARENT_GROUP'
         CONNECT BY  rel.related_group_id = prior rel.group_id
            AND NVL(rel.delete_flag, 'N') <> 'Y'
            AND rel.group_id <> x_group_id
           START WITH rel.related_group_id = x_group_id
             and nvl(rel.delete_flag,'N') <> 'Y';

             --AND rel.start_date_active between l_start_date and nvl(l_end_date, rel.start_date_active +1);


  r_child c_child%rowtype;

  TYPE CHILD_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE);


  TYPE child_table IS TABLE OF CHILD_type INDEX BY BINARY_INTEGER;
  l_child_tab child_table;

  i BINARY_INTEGER := 0;

--Declare the variables
--

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_GROUPS';
    l_api_version	CONSTANT	   NUMBER	 :=1.0;
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;

  l_return_status      VARCHAR2(200) := fnd_api.g_ret_sts_success;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
    BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize;

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


	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

    --get all the child groups for this group
    open c_child(p_group_id);
    fetch c_child INTO r_child;
    while(c_child%found)
    loop

       i := i + 1;
       l_child_tab(i).p_group_id := r_child.group_id;
       l_child_tab(i).p_related_group_id := r_child.related_group_id;
       l_child_tab(i).p_start_date_active    := r_child.start_date_active;
       l_child_tab(i).p_end_date_active    := r_child.end_date_active;

       FETCH c_child   INTO r_child;
     END LOOP; --end of par_mgr_cur
     CLOSE c_child;




	--delete the previous hierarchy for the group
	for r_group_denorm IN c_group_denorm(p_group_id)
 	loop

             --call to DELETt records in jtf_rs_rep_managers
             JTF_RS_REP_MGR_DENORM_PVT.DELETE_GROUP_DENORM
                      ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_DENORM_GRP_ID  => r_group_denorm.denorm_grp_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);
             IF(l_return_status <>  fnd_api.g_ret_sts_success)
             THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_error;
             END IF;
             IF(r_group_denorm.parent_group_id <> p_group_id)
             THEN

                --delete hierarchy for child groups
                i := 0;
                FOR I IN 1 .. l_child_tab.COUNT
                LOOP
             --fetch the child denorm records
                if (l_child_tab(I).p_group_id <> r_group_denorm.parent_group_id)
                then
                 for r_child_denorm IN c_child_denorm(l_child_tab(i).p_group_id,
                                                  r_group_denorm.parent_group_id)
 	             loop

               --call to DELETE records in jtf_rs_rep_managers
                    JTF_RS_REP_MGR_DENORM_PVT.DELETE_GROUP_DENORM
                      ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_DENORM_GRP_ID  => r_child_denorm.denorm_grp_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);
             IF(l_return_status <>  fnd_api.g_ret_sts_success)
             THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_error;
             END IF;



                    --removing this and calling this in  JTF_RS_REP_MGR_DENORM_PVT.DELETE_GROUP_DENORM
                    --jtf_rs_groups_denorm_pkg.delete_row(r_child_denorm.denorm_grp_id);
                  end loop;
                 end if;
               END LOOP;
              END IF;
                --removing this and calling this in  JTF_RS_REP_MGR_DENORM_PVT.DELETE_GROUP_DENORM
               --jtf_rs_groups_denorm_pkg.delete_row(r_group_denorm.denorm_grp_id);


    	end loop;


    --rebuild the group hiearchy again
    JTF_RS_GROUP_DENORM_PVT.CREATE_RES_Groups(1.0,NULL, NULL,p_group_id, x_return_status, x_msg_count, x_msg_data);

    JTF_RS_GROUP_DENORM_PVT.Insert_Groups(1.0,NULL, NULL, p_group_id, x_return_status, x_msg_count, x_msg_data);

    --rebuild the hierarchy for reporting managers

   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN

      ROLLBACK TO group_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END DELETE_GROUPS;
------ CONNECT BY PRIOR - SECTION - Ends



------ NO CONNECT BY - SECTION - Starts
------ The new procedures that are using Populate_Parent_Table and
------- Populate_Child_Table procedures to get results similar to
------- Connect By Clause used in prior section.
  /* This procedure traverse recursively thru the parent
     hierarchy of a group and populates g_parent_tab table with
     records which are within the date range. This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_PARENT_TABLE(P_GROUP_ID IN NUMBER,
                                  P_GREATEST_START_DATE IN DATE,
                                  P_LEAST_END_DATE IN DATE,
                                  p_level IN NUMBER)
  IS
    CURSOR c_parents
    IS
      SELECT rel.group_id,
	     rel.related_group_id,
	     trunc(greatest(rel.start_date_active,
                      nvl(p_greatest_start_date, rel.start_date_active))) greatest_start_date,
             /* Logic : end_date_active, p_least_end_date
                          NULL         , NULL   = NULL
                          NULL         , Value  = Value
                          Value        , NULL   = Value
                          Value1       , Value2 = least(value1, value2) */
	     trunc(least(nvl(rel.end_date_active, p_least_end_date),
                   nvl(p_least_end_date, rel.end_date_active))) least_end_date
	FROM jtf_rs_grp_relations rel
       WHERE relation_type = 'PARENT_GROUP'
	 AND rel.group_id = p_group_id
	 AND NVL(rel.delete_flag, 'N') <> 'Y'
         AND least(nvl(end_date_active, to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR')),
                   nvl(p_least_end_date, to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR'))) >=
             trunc(greatest(start_date_active,
                      nvl(p_greatest_start_date, start_date_active)));
     i INTEGER := 0;
  BEGIN
     FOR r_parent IN c_parents LOOP
       i := g_parent_tab.COUNT+1;
       g_parent_tab(i).p_group_id            := r_parent.group_id;
       g_parent_tab(i).p_related_group_id    := r_parent.related_group_id;
       g_parent_tab(i).p_start_date_active   := r_parent.greatest_start_date;
       g_parent_tab(i).p_end_date_active     := r_parent.least_end_date;
       g_parent_tab(i).level                 := p_level;
       populate_parent_table(g_parent_tab(i).p_related_group_id,
                             g_parent_tab(i).p_start_date_active,
                             g_parent_tab(i).p_end_date_active,
                             p_level+1);
     END LOOP;
  END;

  /* This procedure traverse recursively thru the parent
     hierarchy of a group and populates g_parent_tab table with
     records which are within the date range. This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_PARENT_TABLE(P_GROUP_ID IN NUMBER)
  IS
  BEGIN
     g_parent_tab.delete;
     populate_parent_table(p_group_id, null, null, 1);
  END;

  /* This procedure traverse recursively thru the child
     hierarchy of a group and populates g_child_tab table with
     records which are within the date range.  This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_CHILD_TABLE(P_GROUP_ID IN NUMBER,
                                 P_GREATEST_START_DATE IN DATE,
                                 P_LEAST_END_DATE IN DATE,
                                 P_LEVEL IN NUMBER)
  IS
    CURSOR c_children
    IS
      SELECT rel.group_id,
	     rel.related_group_id,
	     trunc(greatest(rel.start_date_active,
                      nvl(p_greatest_start_date, rel.start_date_active))) greatest_start_date,
             /* Logic : end_date_active, p_least_end_date
                          NULL         , NULL   = NULL
                          NULL         , Value  = Value
                          Value        , NULL   = Value
                          Value1       , Value2 = least(value1, value2) */
	     trunc(least(nvl(rel.end_date_active, p_least_end_date),
                   nvl(p_least_end_date, rel.end_date_active))) least_end_date
	FROM jtf_rs_grp_relations rel
       WHERE relation_type = 'PARENT_GROUP'
	 AND rel.related_group_id = p_group_id
	 AND NVL(rel.delete_flag, 'N') <> 'Y'
         AND least(nvl(end_date_active, to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR')),
                   nvl(p_least_end_date, to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR'))) >=

             trunc(greatest(start_date_active,
                      nvl(p_greatest_start_date, start_date_active)));
     i INTEGER := 0;
  BEGIN
     FOR r_child IN c_children LOOP
       i := g_child_tab.COUNT+1;
       g_child_tab(i).p_group_id            := r_child.group_id;
       g_child_tab(i).p_related_group_id    := r_child.related_group_id;
       g_child_tab(i).p_start_date_active   := r_child.greatest_start_date;
       g_child_tab(i).p_end_date_active     := r_child.least_end_date;
       g_child_tab(i).level                 := p_level;
       populate_child_table(g_child_tab(i).p_group_id,
                            g_child_tab(i).p_start_date_active,
                            g_child_tab(i).p_end_date_active,
                            p_level+1);
     END LOOP;
  END;

  /* This procedure traverse recursively thru the child
     hierarchy of a group and populates g_child_tab table with
     records which are within the date range.  This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_CHILD_TABLE(P_GROUP_ID IN NUMBER)
  IS
  BEGIN
     g_child_tab.delete;
     populate_child_table(p_group_id, null, null, 1);
  END;


/* These are the procedures which are clones of correponding
   procedures with no "_NO_CON". These procedures have the same
   processing logic as their respective no "_NO_CON" procedures
   except that they use POPULATE_PARENT_TABLE and
   POPULATE_CHILD_TABLE procedures to get same result as connect
   by loop in the no "_NO_CON" procedures.
   These procedures were created due to escalations and
   urgent one off requirement for Bug # 2140655, 2428389 and 2716624,
   which were due to connect by error, for which there was no plausible
   solution possible, other than simulating connect by thru PL/SQL.
   These procedures are called by respective no "_NO_CON" procedures
   when there is connect by loop exception.
   Due to the major repeation of processing logic code changes
   must be repelated in both "_NO_CON" and no "_NO_CON" procedures.
   Hari, Nimit, Nishant. */
 PROCEDURE   INSERT_GROUPS_NO_CON(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
  IS
      CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
		 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE group_id = x_group_id;

     CURSOR c_dup(x_group_id JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
		  x_parent_group_id	JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                  l_start_date_active   date,
                  l_end_date_active     date)
      IS
          SELECT  den.group_id
            FROM  jtf_rs_groups_denorm den
           WHERE  den.group_id = x_group_id
	     AND  den.parent_group_id = x_parent_group_id
             --AND  start_date_active = l_start_date_active
             AND  ((l_start_date_active  between den.start_date_active and
                                           nvl(den.end_date_active,l_start_date_active+1))
              OR (l_end_date_active between den.start_date_active
                                          and nvl(den.end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= den.start_date_active)
                          AND (l_end_date_active >= den.end_date_active
                                          OR l_end_date_active IS NULL)));

  i BINARY_INTEGER := 0;
  j BINARY_INTEGER := 0;
  l_child_tab rel_table;
  l_parent_tab rel_table;

--Declare the variables
--
    dup	c_dup%ROWTYPE;
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GROUPS_NO_CON';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count   number;
    l_msg_data    varchar2(2000);

    l_start_date_active Date;
    l_end_date_active Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;


    l_prev_level number := 0;
    l_prev_par_level number := 0;

   TYPE LEVEL_INFO IS RECORD
  ( level           NUMBER,
    start_date      date,
    end_date        date);

  TYPE level_table IS TABLE OF level_info INDEX BY BINARY_INTEGER;

  level_child_table level_table;
  level_par_table level_table;
  l_actual_parent_id NUMBER := null;



  procedure populate_table(p_level      in number,
                           p_start_date in date,
                           p_end_date   in date,
                           l_flag       in varchar2)
  is
   l BINARY_INTEGER;
  begin
    if(l_flag = 'C')
    THEN
        l := 0;
        l := level_child_table.count;
        l := l + 1;
        level_child_table(l).level := p_level;
        level_child_table(l).start_date := p_start_date;
        level_child_table(l).end_date := p_end_date;
    ELSE

        l := 0;
        l := level_par_table.count;
        l := l + 1;
        level_par_table(l).level := p_level;
        level_par_table(l).start_date := p_start_date;
        level_par_table(l).end_date := p_end_date;


    END IF;

  end populate_table;

   procedure delete_table(p_level in number,
                           l_flag       in varchar2)
  is
    k BINARY_INTEGER;
    j BINARY_INTEGER;

  begin
    IF (l_flag = 'C')
    THEN
        IF level_child_table.COUNT > 0 THEN
            k := level_child_table.FIRST;
         LOOP
            IF level_child_table(k).level >= p_level THEN
                  j := k;
                IF k = level_child_table.LAST THEN
                  level_child_table.DELETE(j);
                  EXIT;
                ELSE
                  k:= level_child_table.NEXT(k);
                  level_child_table.DELETE(j);
                 END IF;
             ELSE
                 exit when k = level_child_table.LAST;
                 k:= level_child_table.NEXT(k);
             END IF;
         END LOOP;

      END IF;
   ELSE
     IF level_par_table.COUNT > 0 THEN
            k := level_par_table.FIRST;
         LOOP
            IF level_par_table(k).level >= p_level THEN
                  j := k;
            IF k = level_par_table.LAST THEN
                  level_par_table.DELETE(j);
             EXIT;
           ELSE
             k:= level_par_table.NEXT(k);
             level_par_table.DELETE(j);
           END IF;
         ELSE
           exit when k = level_par_table.LAST;
           k:= level_par_table.NEXT(k);
         END IF;
        END LOOP;

       END IF;
    END IF;

  end  delete_table;

  procedure get_table_date(p_level in number,
                           p_start_date out NOCOPY date,
                           p_end_date out NOCOPY date,
                           l_flag       in varchar2)
  is

      k BINARY_INTEGER := 0;

  begin
   IF(l_flag = 'C')
   THEN
     for k in 1..level_child_table.COUNT
     loop
        if level_child_table(k).level = p_level
        then
          p_start_date := level_child_table(k).start_date;
          p_end_date := level_child_table(k).end_date;
          exit;
        end if;
     end loop;

   ELSE
     for k in 1..level_par_table.COUNT
     loop

        if level_par_table(k).level = p_level
        then
          p_start_date := level_par_table(k).start_date;
          p_end_date := level_par_table(k).end_date;
          exit;
        end if;
     end loop;
   END IF;
  end get_table_date;


 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize_no_con;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


--fetch the start date and the end date for the group
 OPEN c_date(p_group_id);
 FETCH c_date INTO l_start_date, l_end_date;
 CLOSE c_date;



  --get all the child groups for this group
   g_child_tab.delete;
   POPULATE_CHILD_TABLE(p_group_id, l_start_date, l_end_date, 1);
   l_child_tab := g_child_tab;

   IF(l_child_tab.COUNT > 0)
   THEN
     --changed l_start_date to l_start_date_active
     l_start_date_active := l_child_tab(1).p_start_date_active;
     l_end_date_active   := l_child_tab(1).p_end_date_active;
   END IF;
   --insert a record with this  group for the child group also
   i := 0;


   FOR I IN 1 .. l_child_tab.COUNT
   LOOP
           IF(l_child_tab(i).level = 1)
           THEN
               l_start_date_active := l_child_tab(i).p_start_date_active;
               l_end_date_active   := l_child_tab(i).p_end_date_active;
               delete_table(l_child_tab(i).level, 'C');
           ELSIF(l_prev_level >= l_child_tab(i).level)
           THEN
             get_table_date(l_child_tab(i).level - 1, l_start_date_active, l_end_date_active,'C');
             delete_table(l_child_tab(i).level, 'C');
           END IF; -- end of level check


            --assign start date and end date for which this relation is valid


            IF(l_start_date_active < l_child_tab(i).p_start_date_active)
            THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
            ELSIF(l_start_date_active is null)
            THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
            ELSE
                 l_start_date_active := l_start_date_active;
            END IF;

            IF(l_end_date_active > l_child_tab(i).p_end_date_active)
            THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
            ELSIF(l_child_tab(i).p_end_date_active IS NULL)
            THEN
                 l_end_date_active := l_end_date_active;
            ELSIF(l_end_date_active IS NULL)
            THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
            END IF;


           IF (l_child_tab(i).p_related_group_id = P_GROUP_ID)
           THEN
              l_immediate_parent_flag := 'Y';
           ELSE
              l_immediate_parent_flag := 'N';
           END IF;
           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           THEN
               OPEN c_dup(l_child_tab(i).p_group_id, p_group_id, l_start_date_active, l_end_date_active);
               FETCH c_dup into dup;
               IF (c_dup%NOTFOUND)
               THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;


                   l_actual_parent_id := getDirectParent(l_child_tab(i).p_group_id,
                                           l_child_tab(i).level,
                                           p_group_id,
                                           trunc(l_start_date_active),
                                           trunc(l_end_date_active));

                   jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => l_child_tab(i).p_group_id,
			X_PARENT_GROUP_ID => p_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_active),
                        X_END_DATE_ACTIVE => trunc(l_end_date_active),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL             => l_child_tab(i).level);

                        JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => l_child_tab(i).p_group_id ,
                                P_PARENT_GROUP_ID  => p_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_active   ,
                                P_END_DATE_ACTIVE    => l_end_date_active   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL         => l_child_tab(i).level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;

               END IF;  -- end of duplicate check
               CLOSE c_dup;
            END IF; -- end of start date < end date check

            --populating the plsql table
            l_prev_level := l_child_tab(i).level;
            populate_table(l_prev_level, l_start_date_active, l_end_date_active, 'C');


   END LOOP;

   -- delete all rows from pl/sql table for level
--   delete_table(1, 'C');



  l_prev_par_level := 0;
  POPULATE_PARENT_TABLE(p_group_id);
  l_parent_tab := g_parent_tab;


 FOR J IN 1 .. l_parent_tab.COUNT
 LOOP
--dbms_output.put_line('444');
       l_start_date := l_parent_tab(j).p_start_date_active;
       l_end_date := l_parent_tab(j).p_end_date_active;
       IF (l_parent_tab(j).p_related_group_id IS NOT NULL)
       THEN
           IF(l_prev_par_level >= l_parent_tab(j).level)
           THEN
             get_table_date(l_parent_tab(j).level - 1, l_start_date_1, l_end_date_1, 'P');
             delete_table(l_parent_tab(j).level, 'P');
           END IF; -- end of level check

           --if parent group id is null then this group has no upward hierarchy structure, hence no records
           --are to be inserted in the denormalized table
           IF l_parent_tab(j).p_GROUP_ID = P_GROUP_ID
           THEN
              l_immediate_parent_flag := 'Y';
	      l_start_date_1 := l_parent_tab(j).p_start_date_active;
    	      l_end_date_1 := l_parent_tab(j).p_end_date_active;

           ELSE
              l_immediate_parent_flag := 'N';
              if((l_start_date_1 < l_start_date)
                 OR (l_start_date_1 is null))
              then
                   l_start_date_1 := l_start_date;
              end if;
              if(l_end_date < l_end_date_1)
              then
                   l_end_date_1 := l_end_date;
              elsif(l_end_date_1 is null)
              then
                   l_end_date_1 := l_end_date;
              end if;
           END IF;
           IF(l_start_date_1 <= nvl(l_end_date_1, l_start_date_1))
           THEN
              OPEN c_dup(p_group_id, l_parent_tab(j).p_related_group_id, l_start_date_1, l_end_date_1);

              FETCH c_dup into dup;
              IF (c_dup%NOTFOUND)
              THEN

                SELECT jtf_rs_groups_denorm_s.nextval
                INTO l_denorm_grp_id
                FROM dual;

                l_actual_parent_id := getDirectParent(p_group_id,
                                          l_parent_tab(j).level,
                                          l_parent_tab(j).p_related_group_id,
                                          trunc(l_start_date_1),
                                          trunc(l_end_date_1));
                jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => p_group_id,
			X_PARENT_GROUP_ID => l_parent_tab(j).p_related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_1),
                        X_END_DATE_ACTIVE => trunc(l_end_date_1),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => l_parent_tab(j).level);



                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => p_group_id ,
                                P_PARENT_GROUP_ID  => l_parent_tab(j).p_related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_1   ,
                                P_END_DATE_ACTIVE    => l_end_date_1   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL         => l_parent_tab(j).level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;
            END IF;
            CLOSE c_dup;


        --insert a record with this parent group for the child group also
            l_prev_level := 0;
            i := 0;
            --initialize dates
            FOR i IN 1 .. l_child_tab.COUNT
            LOOP
              IF(l_child_tab(i).level = 1)
              THEN
                 l_start_date_active := l_start_date_1;
                 l_end_date_active := l_end_date_1;
                 delete_table(l_child_tab(i).level, 'C');
              ELSIF(l_prev_level >= l_child_tab(i).level)
              THEN
                   get_table_date(l_child_tab(i).level - 1, l_start_date_active, l_end_date_active,'C');
                   delete_table(l_child_tab(i).level, 'C');
              END IF; -- end of level check
             --dbms_output.put_line('group..'||to_char(l_child_tab(i).p_group_id));
             --dbms_output.put_line(to_char(l_start_date_active, 'dd-mon-yyyy')||'..'|| to_char(l_end_date_active, 'dd-mon-yyyy'));
             --dbms_output.put_line(to_char(l_child_tab(i).p_start_date_active, 'dd-mon-yyyy') ||'..'||to_char(l_child_tab(i).p_end_date_active, 'dd-mon-yyyy'));

            --assign start date and end date for which this relation is valid
              IF(l_start_date_active < l_child_tab(i).p_start_date_active)
              THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
              ELSIF(l_start_date_active is null)
              THEN
                 l_start_date_active := l_child_tab(i).p_start_date_active;
              ELSE
                 l_start_date_active := l_start_date_active;
              END IF;

              IF(l_end_date_active > l_child_tab(i).p_end_date_active)
              THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
              ELSIF(l_child_tab(i).p_end_date_active IS NULL)
              THEN
                 l_end_date_active := l_end_date_active;
              ELSIF(l_end_date_active IS NULL)
              THEN
                 l_end_date_active := l_child_tab(i).p_end_date_active;
              END IF;

              l_immediate_parent_flag := 'N';
            IF(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
            THEN
                OPEN c_dup(l_child_tab(i).p_group_id, l_parent_tab(j).p_related_group_id, l_start_date_active, l_end_date_active);
                FETCH c_dup into dup;
                IF (c_dup%NOTFOUND)
                THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;

                   l_actual_parent_id := getDirectParent(l_child_tab(i).p_group_id,
                                          l_child_tab(i).level + l_parent_tab(j).level,
                                          l_parent_tab(j).p_related_group_id,
                                          trunc(l_start_date_active),
                                          trunc(l_end_date_active));
                   jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => l_child_tab(i).p_group_id,
			X_PARENT_GROUP_ID => l_parent_tab(j).p_related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_active),
                        X_END_DATE_ACTIVE => trunc(l_end_date_active),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => l_child_tab(i).level + l_parent_tab(j).level);

                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         =>  l_child_tab(i).p_group_id ,
                                P_PARENT_GROUP_ID  => l_parent_tab(j).p_related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_active   ,
                                P_END_DATE_ACTIVE    => l_end_date_active   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL        => l_child_tab(i).level + l_parent_tab(j).level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                        IF(l_return_status <>  fnd_api.g_ret_sts_success)
                        THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                        END IF;

                END IF;  -- end of duplicate check
               CLOSE c_dup;

             END IF; -- end of start_date_active check

           --populating the plsql table
              l_prev_level := l_child_tab(i).level;
              populate_table(l_prev_level, l_start_date_active, l_end_date_active, 'C');

           END LOOP;  -- end of child tab insert
           -- delete all rows from pl/sql table for level
             delete_table(1, 'C');

          END IF; -- end of parent start date check
          --populating the plsql table
           l_prev_par_level := l_parent_tab(j).level;
           populate_table(l_prev_par_level, l_start_date_1, l_end_date_1, 'P');
       END IF; --end of group id check

     END LOOP;

   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize_no_con;

      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --ND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize_no_con;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize_no_con;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  INSERT_GROUPS_NO_CON;


--Start of procedure Body
--FOR UPDATE

/* These are the procedures which are clones of correponding
   procedures with no "_NO_CON". These procedures have the same
   processing logic as their respective no "_NO_CON" procedures
   except that they use POPULATE_PARENT_TABLE and
   POPULATE_CHILD_TABLE procedures to get same result as connect
   by loop in the no "_NO_CON" procedures.
   These procedures were created due to escalations and
   urgent one off requirement for Bug # 2140655, 2428389 and 2716624,
   which were due to connect by error, for which there was no plausible
   solution possible, other than simulating connect by thru PL/SQL.
   These procedures are called by respective no "_NO_CON" procedures
   when there is connect by loop exception.
   Due to the major repeation of processing logic code changes
   must be repelated in both "_NO_CON" and no "_NO_CON" procedures.
   Hari, Nimit, Nishant. */
   PROCEDURE  UPDATE_GROUPS_NO_CON(
               P_API_VERSION    IN   NUMBER,
               P_INIT_MSG_LIST	IN   VARCHAR2,
               P_COMMIT		IN   VARCHAR2,
               p_group_id       IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
               X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
               X_MSG_COUNT      OUT NOCOPY  NUMBER,
               X_MSG_DATA       OUT NOCOPY  VARCHAR2 )
   IS


      CURSOR c_group_denorm(l_group_id  JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
          IS
       SELECT denorm_grp_id,
              group_id,
              parent_group_id
        FROM JTF_RS_GROUPS_DENORM
	 WHERE group_id = l_group_id
     AND   PARENT_GROUP_ID <> L_GROUP_ID;


	--Declare the variables
	--

	l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_GROUPS_NO_CON';
	l_api_version	CONSTANT	   NUMBER	 :=1.0;

   l_date     DATE;
   l_user_id  NUMBER := 1;
   l_login_id NUMBER := 1;
    l_return_status      VARCHAR2(200) := fnd_api.g_ret_sts_success;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
     i BINARY_INTEGER := 0;
     l_child_tab rel_table;
     l_parent_tab rel_table;
    BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize_no_con;

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


        l_date     := sysdate;
        l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
        l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);
	--delete the previous hierarchy for the group
	for r_group_denorm IN c_group_denorm(p_group_id)
	loop
            JTF_RS_REP_MGR_DENORM_PVT.DELETE_REP_MGR  (
              P_API_VERSION     => 1.0,
              P_GROUP_ID        => r_group_denorm.group_id,
              P_PARENT_GROUP_ID => r_group_denorm.parent_group_id,
              X_RETURN_STATUS   => l_return_status,
              X_MSG_COUNT       => l_msg_count,
              X_MSG_DATA        => l_msg_data);



             IF(l_return_status <>  fnd_api.g_ret_sts_success)
             THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        RAISE fnd_api.g_exc_error;
             END IF;
	    jtf_rs_groups_denorm_pkg.delete_row(r_group_denorm.DENORM_GRP_ID);
	end loop;



	--delete the hiearchy of all the child records of the group
        POPULATE_CHILD_TABLE(p_group_id);
        l_child_tab := g_child_tab;

        FOR I IN 1 .. l_child_tab.COUNT
        LOOP
	    for r_group_denorm IN c_group_denorm(l_child_tab(i).p_group_id)
	    loop
               JTF_RS_REP_MGR_DENORM_PVT.DELETE_REP_MGR  (
                 P_API_VERSION     => 1.0,
                 P_GROUP_ID        => r_group_denorm.group_id,
                 P_PARENT_GROUP_ID => r_group_denorm.parent_group_id,
                 X_RETURN_STATUS   => l_return_status,
                 X_MSG_COUNT       => l_msg_count,
                 X_MSG_DATA        => l_msg_data);

                IF(l_return_status <>  fnd_api.g_ret_sts_success)
                THEN
                      x_return_status := fnd_api.g_ret_sts_error;
                      RAISE fnd_api.g_exc_error;
                END IF;

	        jtf_rs_groups_denorm_pkg.delete_row(r_group_denorm.DENORM_GRP_ID);
	    end loop;
        END LOOP;


        --rebuild the hiearchy of all the child records of the group
	FOR I IN 1 .. l_child_tab.COUNT
  	LOOP
	     JTF_RS_GROUP_DENORM_PVT.Insert_Groups_No_Con(1.0,NULL, NULL,l_child_tab(i).p_group_id, x_return_status, x_msg_count, x_msg_data);
	END LOOP;

        --rebuild the group hiearchy again
	JTF_RS_GROUP_DENORM_PVT.insert_groups_no_con(1.0,NULL, NULL,p_group_id, x_return_status, x_msg_count, x_msg_data);

   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize_no_con;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize_no_con;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize_no_con;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END UPDATE_GROUPS_NO_CON;



/* These are the procedures which are clones of correponding
   procedures with no "_NO_CON". These procedures have the same
   processing logic as their respective no "_NO_CON" procedures
   except that they use POPULATE_PARENT_TABLE and
   POPULATE_CHILD_TABLE procedures to get same result as connect
   by loop in the no "_NO_CON" procedures.
   These procedures were created due to escalations and
   urgent one off requirement for Bug # 2140655, 2428389 and 2716624,
   which were due to connect by error, for which there was no plausible
   solution possible, other than simulating connect by thru PL/SQL.
   These procedures are called by respective no "_NO_CON" procedures
   when there is connect by loop exception.
   Due to the major repeation of processing logic code changes
   must be repelated in both "_NO_CON" and no "_NO_CON" procedures.
   Hari, Nimit, Nishant. */
   PROCEDURE   DELETE_GRP_RELATIONS_NO_CON(
                P_API_VERSION       IN  NUMBER,
                P_INIT_MSG_LIST     IN  VARCHAR2,
                P_COMMIT            IN  VARCHAR2,
                p_group_relate_id    IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_group_id           IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                p_related_group_id   IN  JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA       OUT NOCOPY VARCHAR2)
  is

  i BINARY_INTEGER := 0;

   l_child_tab rel_table;
   l_parent_tab rel_table;

   CURSOR check_parent_cur(l_group_id   number,
                         l_related_group_id number)
       IS
    SELECT rel.group_id,
	   rel.related_group_id,
           rel.start_date_active,
	   rel.end_date_active
    FROM jtf_rs_grp_relations rel
  WHERE relation_type = 'PARENT_GROUP'
   AND  related_group_id = l_related_group_id
 CONNECT BY rel.group_id = prior rel.related_group_id
    AND NVL(rel.delete_flag, 'N') <> 'Y'
    AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
    --AND rel.related_group_id <> p_related_group_id
  START WITH rel.group_id = l_group_id
  AND NVL(rel.delete_flag, 'N') <> 'Y';

  check_parent_rec check_parent_cur%rowtype;

  j BINARY_INTEGER := 0;

  TYPE role_relate_TYPE IS RECORD
  ( role_relate_id      NUMBER,
    group_id            NUMBER);

  TYPE child_rol_rel_table IS TABLE OF role_relate_TYPE INDEX BY BINARY_INTEGER;
  l_child_rol_rel_tab child_rol_rel_table;

  k BINARY_INTEGER := 0;

  TYPE par_rol_rel_table IS TABLE OF role_relate_TYPE INDEX BY BINARY_INTEGER;
  l_par_rol_rel_tab par_rol_rel_table;

  l BINARY_INTEGER := 0;


  cursor rr_cur(l_no number)
     is
   select rel.role_relate_id,
          mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel
    where mem.group_id  = l_no
     and  nvl(mem.delete_flag , 'N') <> 'Y'
     and  mem.group_member_id = rel.role_resource_id
     and  rel.role_resource_type = 'RS_GROUP_MEMBER'
     and  nvl(rel.delete_flag, 'N') <> 'Y';

 role_rel_rec rr_cur%rowtype;

  cursor rr_mgr_cur(l_group_id number)
     is
   select rel.role_relate_id,
          mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel,
          jtf_rs_roles_b rol
    where mem.group_id  = l_group_id
     and  nvl(mem.delete_flag , 'N') <> 'Y'
     and  mem.group_member_id = rel.role_resource_id
     and  rel.role_resource_type = 'RS_GROUP_MEMBER'
     and  nvl(rel.delete_flag, 'N') <> 'Y'
     and  rel.role_id  =  rol.role_id
     and  (
            nvl(rol.manager_flag, 'N') = 'Y'
            or
            nvl(rol.admin_flag, 'N') = 'Y'
          );

  role_rel_mgr_rec rr_mgr_cur%rowtype;

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_GRP_RELATIONS_NO_CON';
    l_api_version	CONSTANT	   NUMBER	 :=1.0;
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;

  l_return_status      VARCHAR2(200) := fnd_api.g_ret_sts_success;
  l_msg_count          NUMBER;
  l_found             BOOLEAN := FALSE;

begin

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize_no_con;

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


   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
      --to add the grooup_id as child as this will not be included in cursor
       k := 0;
       -- get the role relate ids for this group
       open rr_cur(p_group_id);
       fetch rr_cur into role_rel_rec;
       while (rr_cur%found)
       loop
           k := K + 1;
           l_child_rol_rel_tab(k).role_relate_id := role_rel_rec.role_relate_id;
           l_child_rol_rel_tab(k).group_id := role_rel_rec.group_id;

           fetch rr_cur into role_rel_rec;
       end loop; -- end of role relate cur
       close rr_cur;
   --get all the child groups for this group
       g_child_tab.delete;
       i := 1;
       g_child_tab(i).p_group_id := p_group_id;
       g_child_tab(i).p_related_group_id := p_related_group_id;
       POPULATE_CHILD_TABLE(p_group_id, null, null, 1);
       l_child_tab := g_child_tab;

    FOR I IN 1 .. l_child_tab.count LOOP
       -- get the role relate ids for this group
       open rr_cur(l_child_tab(i).p_group_id);
       fetch rr_cur into role_rel_rec;
       while (rr_cur%found)
       loop
           k := K + 1;
           l_child_rol_rel_tab(k).role_relate_id := role_rel_rec.role_relate_id;
           l_child_rol_rel_tab(k).group_id := role_rel_rec.group_id;

           fetch rr_cur into role_rel_rec;
       end loop; -- end of role relate cur
      close rr_cur;

     END LOOP;

   -- insert the parent group in the table as the parent cursor does not fetch this record
    l := 0;
        -- get the role relate ids for this group
       open rr_mgr_cur(p_related_group_id);
       fetch rr_mgr_cur into role_rel_mgr_rec;
       while (rr_mgr_cur%found)
       loop
           l :=l + 1;
           l_par_rol_rel_tab(l).role_relate_id := role_rel_mgr_rec.role_relate_id;
           l_par_rol_rel_tab(l).group_id := role_rel_mgr_rec.group_id;

           fetch rr_mgr_cur into role_rel_mgr_rec;
       end loop;
       close rr_mgr_cur;

     l_parent_tab.delete;
     j := 0;
     j := j + 1;
     g_parent_tab(j).p_group_id := p_group_id;
     g_parent_tab(j).p_related_group_id := p_related_group_id;
     populate_parent_table(p_group_id, null, null, 1);
    l_parent_tab := g_parent_tab;

    FOR I IN 1 .. l_parent_tab.COUNT
    LOOP
       -- get the role relate ids for this group
       open rr_mgr_cur(l_parent_tab(i).p_related_group_id);
       fetch rr_mgr_cur into role_rel_mgr_rec;
       while (rr_mgr_cur%found)
       loop
           l :=l + 1;
           l_par_rol_rel_tab(l).role_relate_id := role_rel_mgr_rec.role_relate_id;
           l_par_rol_rel_tab(l).group_id := role_rel_mgr_rec.group_id;

           fetch rr_mgr_cur into role_rel_mgr_rec;
       end loop; -- end of role relate cur
       close rr_mgr_cur;



     END LOOP;

   --DELETE GROUP DENORM
    FOR j IN 1 .. l_parent_tab.COUNT
    LOOP
        FOR i IN 1 .. l_child_tab.COUNT
        LOOP
           --delete group denorm
            begin
		delete jtf_rs_groups_denorm
                 where group_id = l_child_tab(i).p_group_id
                  and  parent_group_id = l_parent_tab(j).p_related_group_id;
                exception
                    when others  then
                       fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

             end;

         end loop; -- end of child
    end loop; -- end of parent


      --DELETE REP MANAGER
    FOR l IN 1 .. l_par_rol_rel_tab.COUNT
    LOOP
        FOR k IN 1 .. l_child_rol_rel_tab.COUNT
        LOOP
           --delete rep mgr
            begin
		delete jtf_rs_rep_managers
                 where par_role_relate_id  = l_par_rol_rel_tab(l).role_relate_id
                  and  child_role_relate_id  = l_child_rol_rel_tab(k).role_relate_id;

                exception
                    when others  then
                        fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;
             end;

         end loop; -- end of child
    end loop; -- end of parent



   --now recreate hierarchy in case same parent existed for child through some diff branch

    FOR i IN 1 .. l_child_tab.COUNT
    LOOP
       l_found := FALSE;

       FOR j IN 1 .. l_parent_tab.COUNT
       LOOP
           BEGIN
	     open check_parent_cur(l_child_tab(i).p_group_id,
				   l_parent_tab(j).p_related_group_id);
	     fetch check_parent_cur into check_parent_rec;
	     if (check_parent_cur%found)
	     then
		   l_found := TRUE;
		   jtf_rs_group_denorm_pvt.insert_groups_parent_no_con(
			   p_api_version    =>    1.0,
			   p_init_msg_list => NULL,
			   p_commit          => 'T',
			   p_group_id => l_child_tab(i).p_group_id,
			   x_return_status => x_return_status,
			   x_msg_count => x_msg_count,
			   x_msg_data => x_msg_data);

		    IF(x_return_status <>  fnd_api.g_ret_sts_success)
		    THEN
		      x_return_status := fnd_api.g_ret_sts_error;
		      RAISE fnd_api.g_exc_error;
		    END IF;

	     else
	       close check_parent_cur;
	     end if;
           EXCEPTION
             WHEN OTHERS THEN
                NULL;
           END;
           if l_found
           then
              --since the entire parent hierarchy for the group has been built no point checking for further parents
              exit;
           end if;
       END LOOP; -- end of parent tab loop
       if(check_parent_cur%isopen)
       then
            close check_parent_cur;
       end if;

   END LOOP; -- end of child tab loop
   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN

      ROLLBACK TO group_denormalize_no_con;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize_no_con;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize_no_con;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

end delete_grp_relations_no_con;

/* These are the procedures which are clones of correponding
   procedures with no "_NO_CON". These procedures have the same
   processing logic as their respective no "_NO_CON" procedures
   except that they use POPULATE_PARENT_TABLE and
   POPULATE_CHILD_TABLE procedures to get same result as connect
   by loop in the no "_NO_CON" procedures.
   These procedures were created due to escalations and
   urgent one off requirement for Bug # 2140655, 2428389 and 2716624,
   which were due to connect by error, for which there was no plausible
   solution possible, other than simulating connect by thru PL/SQL.
   These procedures are called by respective no "_NO_CON" procedures
   when there is connect by loop exception.
   Due to the major repeation of processing logic code changes
   must be repelated in both "_NO_CON" and no "_NO_CON" procedures.
   Hari, Nimit, Nishant. */
 PROCEDURE   INSERT_GROUPS_PARENT_NO_CON(
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              p_group_id        IN  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2 )
  IS
      CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
		 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE group_id = x_group_id;

     CURSOR c_dup(x_group_id JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
		  x_parent_group_id	JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
                  l_start_date_active   date,
                  l_end_date_active     date)
      IS
          SELECT  den.group_id
            FROM  jtf_rs_groups_denorm den
           WHERE  den.group_id = x_group_id
	     AND  den.parent_group_id = x_parent_group_id
             --AND  start_date_active = l_start_date_active
             AND  ((l_start_date_active  between den.start_date_active and
                                           nvl(den.end_date_active,l_start_date_active+1))
              OR (l_end_date_active between den.start_date_active
                                          and nvl(den.end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= den.start_date_active)
                          AND (l_end_date_active >= den.end_date_active
                                          OR l_end_date_active IS NULL)));


--Declare the variables
--
    dup	c_dup%ROWTYPE;
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GROUPS_PARENT_NO_CON';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_immediate_parent_flag VARCHAR2(1) := 'N';
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count   number;
    l_msg_data    varchar2(2000);

    l_start_date_active Date;
    l_end_date_active Date;

    l_start_date_1 Date;
    l_end_date_1 Date;
    l_DENORM_GRP_ID	JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE;
    x_row_id    varchar2(24) := null;

    l_child_tab rel_table;
    l_parent_tab rel_table;

  l_prev_level number := 0;

   TYPE LEVEL_INFO IS RECORD
  ( level           NUMBER,
    start_date      date,
    end_date        date);

  TYPE level_table IS TABLE OF level_info INDEX BY BINARY_INTEGER;

  level_value_table level_table;
  l_actual_parent_id NUMBER := null;

  i BINARY_INTEGER := 0;

  procedure populate_table(p_level      in number,
                           p_start_date in date,
                           p_end_date   in date)
  is
   i BINARY_INTEGER;
  begin
    i := 0;
    i := level_value_table.count;
    i := i + 1;
    level_value_table(i).level := p_level;
    level_value_table(i).start_date := p_start_date;
    level_value_table(i).end_date := p_end_date;

  end populate_table;

  procedure delete_table(p_level in number)
  is
    k BINARY_INTEGER;
      j BINARY_INTEGER;

  begin
    IF level_value_table.COUNT > 0 THEN
      k := level_value_table.FIRST;
      LOOP
        IF level_value_table(k).level >= p_level THEN
           j := k;
           IF k = level_value_table.LAST THEN
             level_value_table.DELETE(j);
             EXIT;
           ELSE
             k:= level_value_table.NEXT(k);
             level_value_table.DELETE(j);
           END IF;
        ELSE
           exit when k = level_value_table.LAST;
           k:= level_value_table.NEXT(k);
        END IF;
      END LOOP;

    END IF;

  end  delete_table;

  procedure get_table_date(p_level in number,
                           p_start_date out NOCOPY date,
                           p_end_date out NOCOPY date)
  is

  k BINARY_INTEGER := 0;

  begin
     for k in 1..level_value_table.COUNT
     loop

        if level_value_table(k).level = p_level
        then
          p_start_date := level_value_table(k).start_date;
          p_end_date := level_value_table(k).end_date;
          exit;
        end if;
   end loop;
  end get_table_date;

 BEGIN

 	--Standard Start of API SAVEPOINT
	SAVEPOINT group_denormalize_no_con;

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

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   -- if no group id is passed in then raise error
   IF p_group_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_IS_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
     RETURN;
   END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


--fetch the start date and the end date for the group
 OPEN c_date(p_group_id);
 FETCH c_date INTO l_start_date, l_end_date;
 CLOSE c_date;

  POPULATE_PARENT_TABLE(p_group_id);
  l_parent_tab := g_parent_tab;

 FOR I IN 1 .. l_parent_tab.COUNT
 LOOP

       l_start_date := l_parent_tab(i).p_start_date_active;
       l_end_date := l_parent_tab(i).p_end_date_active;
       IF (l_parent_tab(i).p_related_group_id IS NOT NULL)
       THEN
           --if parent group id is null then this group has no upward hierarchy structure, hence no records
           --are to be inserted in the denormalized table
           IF(l_prev_level >= l_parent_tab(i).level)
           THEN
             get_table_date(l_parent_tab(i).level - 1, l_start_date_1, l_end_date_1);
             delete_table(l_parent_tab(i).level);
           END IF; -- end of level check



           IF l_parent_tab(i).p_GROUP_ID = P_GROUP_ID
           THEN
              l_immediate_parent_flag := 'Y';
	      l_start_date_1 := l_parent_tab(i).p_start_date_active;
    	      l_end_date_1 := l_parent_tab(i).p_end_date_active;

           ELSE
              l_immediate_parent_flag := 'N';
               if((l_start_date_1 < l_start_date)
                 OR (l_start_date_1 is null))
              then
                   l_start_date_1 := l_start_date;
              end if;
              if(l_end_date < l_end_date_1)
              then
                   l_end_date_1 := l_end_date;
              elsif(l_end_date_1 is null)
              then
                   l_end_date_1 := l_end_date;
              end if;

           END IF;

           if(l_start_date_1 <= nvl(l_end_date_1, l_start_date_1))
           then
               OPEN c_dup(p_group_id, l_parent_tab(i).p_related_group_id, l_start_date_1, l_end_date_1);

               FETCH c_dup into dup;
               IF (c_dup%NOTFOUND)
               THEN

                   SELECT jtf_rs_groups_denorm_s.nextval
                   INTO l_denorm_grp_id
                   FROM dual;

                   l_actual_parent_id := getDirectParent(p_group_id,
                                          l_parent_tab(i).level,
                                          l_parent_tab(i).p_related_group_id,
                                          trunc(l_start_date_1),
                                          trunc(l_end_date_1));

                   jtf_rs_groups_denorm_pkg.insert_row(
                        X_ROWID   =>   x_row_id,
			X_DENORM_GRP_ID =>   l_DENORM_GRP_ID,
                        X_GROUP_ID     => p_group_id,
			X_PARENT_GROUP_ID => l_parent_tab(i).p_related_group_id,
                        X_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                        X_ACTUAL_PARENT_ID => l_actual_parent_id,
			X_START_DATE_ACTIVE => trunc(l_start_date_1),
                        X_END_DATE_ACTIVE => trunc(l_end_date_1),
                        X_ATTRIBUTE2  => null,
			X_ATTRIBUTE3  => null,
                 	X_ATTRIBUTE4    => null,
			X_ATTRIBUTE5  => null,
			X_ATTRIBUTE6 => null,
			X_ATTRIBUTE7  => null,
			X_ATTRIBUTE8 => null,
			X_ATTRIBUTE9 => null,
			X_ATTRIBUTE10 => null,
			X_ATTRIBUTE11  => null,
			X_ATTRIBUTE12  => null,
			X_ATTRIBUTE13 => null,
			X_ATTRIBUTE14 => null,
			X_ATTRIBUTE15  => null,
			X_ATTRIBUTE_CATEGORY => null,
                        X_ATTRIBUTE1  => null,
			X_CREATION_DATE  => l_date,
			X_CREATED_BY   => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY  => l_user_id,
			X_LAST_UPDATE_LOGIN  => l_login_id,
                        X_DENORM_LEVEL              => l_parent_tab(i).level );


                       --call rep manager insert
                       JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_DENORM(
                                P_API_VERSION     => 1.0,
                                P_GROUP_DENORM_ID  => l_denorm_grp_id,
                                P_GROUP_ID         => p_group_id ,
                                P_PARENT_GROUP_ID  => l_parent_tab(i).p_related_group_id  ,
                                P_START_DATE_ACTIVE  => l_start_date_1   ,
                                P_END_DATE_ACTIVE    => l_end_date_1   ,
                                P_IMMEDIATE_PARENT_FLAG => l_immediate_parent_flag,
                                P_DENORM_LEVEL       =>  l_parent_tab(i).level,
                                X_RETURN_STATUS   => l_return_status,
                                X_MSG_COUNT       => l_msg_count,
                                X_MSG_DATA       => l_msg_data ) ;

                      IF(l_return_status <>  fnd_api.g_ret_sts_success)
                      THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        RAISE fnd_api.g_exc_error;
                      END IF;
               END IF;
               CLOSE c_dup;
           END IF; -- end of st dt check

       END IF; --end of group id check
       --populating the plsql table
       l_prev_level := l_parent_tab(i).level;
       populate_table(l_prev_level, l_start_date_1, l_end_date_1);

     END LOOP;



   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_denormalize_no_con;

      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --ND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_denormalize_no_con;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_denormalize_no_con;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END  INSERT_GROUPS_PARENT_NO_CON;
------ NO CONNECT BY - SECTION - Ends

END JTF_RS_GROUP_DENORM_PVT;

/
