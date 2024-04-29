--------------------------------------------------------
--  DDL for Package Body JTF_RS_REP_MGR_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_REP_MGR_DENORM_PVT" AS
 /* $Header: jtfrsvpb.pls 120.0.12010000.2 2009/02/17 06:36:08 rgokavar ship $ */
-- API Name	: JTF_RS_REP_MGR_DENORM_PVT
-- Type		: Private
-- Purpose	: Inserts/Update the JTF_RS_REPORTING_MANAGERS table based on changes in jtf_rs_role_relations,
--                jtf_rs_grp_relations
-- Modification History
-- DATE		     NAME	            PURPOSE
-- 7 Oct 1999    S Roy Choudhury   Created
-- 3 Jul 2001    S Roy Choudhury   Modified the cursor for selecting members in procedure INSERT_GRP_RELATIONS
--                                 to fix the dates. Also added the posting of reverse records for MGR_TO_MGR
--                                 hierarchy type.
-- 5 Feb 2009    Sudhir Gokavarapu Bug8261683 : Modified Deletion logic in procedure UPDATE_REP_MANAGER.
-- Notes:
--

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_REP_MGR_DENORM_PVT';

   /*FOR INSERT IN JTF_RS_ROLE_RELATIONS */
   PROCEDURE  INSERT_REP_MANAGER(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2,
                   P_COMMIT          IN     VARCHAR2,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 )
  IS
  CURSOR rep_mgr_seq_cur
      IS
   SELECT jtf_rs_rep_managers_s.nextval
     FROM dual;


   CURSOR  mem_dtls_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  rlt.role_relate_id = l_role_relate_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_resource_id   = mem.group_member_id
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id        = rsc.resource_id;


  mem_dtls_rec   mem_dtls_cur%rowtype;

  --CURSOR for other members in same group

   CURSOR  other_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                     l_start_date_active DATE,
                     l_end_date_active   DATE,
                     l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id = l_group_id
    AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_relate_id <> l_role_relate_id
    /* AND  ((rlt.start_date_active  between l_start_date_active and
                                           nvl(l_end_date_active,rlt.start_date_active+1))
        OR (rlt.end_date_active between l_start_date_active
                                          and nvl(l_end_date_active,rlt.end_date_active+1))
        OR ((rlt.start_date_active <= l_start_date_active)
                          AND (rlt.end_date_active >= l_end_date_active
                                          OR l_end_date_active IS NULL))) */
     AND  rlt.role_id            = rol.role_id
--added to eliminate managers
     AND  nvl(rol.manager_flag , 'N') <> 'Y'
     AND  (
           nvl(rol.admin_flag, 'N') = 'Y'
           OR
           nvl(rol.member_flag, 'N') = 'Y'
          )
     AND  mem.resource_id        = rsc.resource_id;


  other_rec   other_cur%rowtype;

  --cursor for duplicate check
  CURSOR dup_cur(l_person_id            JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_manager_person_id    JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_group_id	      JTF_RS_GROUPS_B.GROUP_ID%TYPE,
	       l_resource_id	      JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
               l_start_date_active    DATE,
               l_end_date_active      DATE)
         IS
          SELECT  person_id
            FROM  jtf_rs_rep_managers
            WHERE group_id = l_group_id
	      AND ( person_id = l_person_id
                        OR (l_person_id IS NULL AND person_id IS NULL))
              AND manager_person_id = l_manager_person_id
	      AND resource_id = l_resource_id
              AND start_date_active = l_start_date_active
              AND (end_date_active   = l_end_date_active
                 OR ( end_date_active IS NULL AND l_end_date_active IS NULL));

  CURSOR dup_cur2(l_par_role_relate_id         JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_child_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_group_id                   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                  l_start_date_active          date,
                  l_end_date_active             date)
     IS
     SELECT person_id
     FROM jtf_rs_rep_managers
    WHERE par_role_relate_id = l_par_role_relate_id
     AND  child_role_relate_id = l_child_role_relate_id
     AND  group_id   = l_group_id
      AND  ((l_start_date_active  between start_date_active and
                                           nvl(end_date_active,l_start_date_active+1))
              OR (l_end_date_active between start_date_active
                                          and nvl(end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= start_date_active)
                          AND (l_end_date_active >= end_date_active
                                          OR l_end_date_active IS NULL)));



  dup     NUMBER := 0;

  --cursor for same group manager
  CURSOR same_grp_mgr_admin_cur(l_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                                l_start_date_active  DATE,
                                l_end_date_active    DATE,
                                l_role_relate_id     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
  SELECT /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.admin_flag  ,
          rol.manager_flag,
          rlt.role_relate_id
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_B rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_relate_id      <> l_role_relate_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     --AND  rlt.role_relate_id <> l_role_relate_id
   /*  AND  ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)))  */
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rol.manager_flag , 'N')  = 'Y';

  same_grp_mgr_admin_rec same_grp_mgr_admin_cur%ROWTYPE;


  --cursor for parent groups
  CURSOR  par_grp_cur(l_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
      IS
  SELECT  parent_group_id,
          immediate_parent_flag,
          start_date_active,
          end_date_active,
          denorm_level
    FROM  jtf_rs_groups_denorm
   WHERE  group_id = l_group_id
     AND  parent_group_id <> l_group_id
/*     AND  ((l_start_date_active between start_date_active
                                and nvl(end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, start_date_active +1)
                      between start_date_active  and
                           nvl(end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and end_date_active is null)))*/
          ;

  par_grp_rec   par_grp_cur%ROWTYPE;


  --cursor to fetch admin for a group
  CURSOR admin_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_id            = rol.role_id
     AND  rol.admin_flag   = 'Y'
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));

  admin_rec admin_cur%rowtype;

--cursor to fetch managers for a group
   CURSOR mgr_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT  /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
    FROM  jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  rol.manager_flag   = 'Y' ;
/*     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null))); */


  mgr_rec mgr_cur%rowtype;

  --cursor for child groups
  CURSOR child_grp_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
   SELECT group_id,
          immediate_parent_flag,
          start_date_active,
          end_date_active,
          denorm_level
    FROM  jtf_rs_groups_denorm
   WHERE  parent_group_id = l_group_id
     AND  group_id <> l_group_id;
  /*      AND ((l_start_date_active between start_date_active
                                and nvl(end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, start_date_active +1)
                      between start_date_active  and
                           nvl(end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and end_date_active is null))); */

  child_grp_rec   child_grp_cur%rowtype;


  --cursor for child group members
  CURSOR child_mem_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.manager_flag,
          rol.admin_flag,
          rol.member_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_b rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  ( nvl(rol.manager_flag,'N')  = 'Y'
            OR
            nvl(rol.admin_flag, 'N')    = 'Y'
            OR
            nvl(rol.member_flag, 'N') = 'Y')
     --AND  rlt.start_date_active <= l_start_date_active
/*     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null))) */
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id     = rsc.resource_id;

 child_mem_rec child_mem_cur%rowtype;

  l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE := p_role_relate_id;
  l_hierarchy_type JTF_RS_REP_MANAGERS.HIERARCHY_TYPE%TYPE;
  l_reports_to_flag  JTF_RS_REP_MANAGERS.REPORTS_TO_FLAG%TYPE;
  l_denorm_mgr_id	JTF_RS_REP_MANAGERS.DENORM_MGR_ID%TYPE;
  x_row_id              VARCHAR2(100);

  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REP_MANAGER';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_fnd_date  Date := to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR');
  l_user_id  Number;
  l_login_id  Number;

  l_start_date_active DATE;
  l_end_date_active  DATE;


  l_count number := 0;

  BEGIN
   --Standard Start of API SAVEPOINT
     SAVEPOINT member_denormalize;

    x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
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

    -- if no group id or person id is passed in then return
   IF p_role_relate_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_RESOURCE_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
   END IF;


   --fetch the member details
   OPEN mem_dtls_cur(l_role_relate_id);
   FETCH mem_dtls_cur INTO mem_dtls_rec;
   IF((mem_dtls_cur%FOUND) AND
      (nvl(mem_dtls_rec.manager_flag ,'N')= 'Y'
            OR nvl(mem_dtls_rec.admin_flag, 'N') = 'Y'
            OR nvl(mem_dtls_rec.member_flag, 'N') = 'Y'))
   THEN
       --duplicate check for the member record
      OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	         mem_dtls_rec.role_relate_id,
                 mem_dtls_rec.group_id,
                 mem_dtls_rec.start_date_active,
                 mem_dtls_rec.end_date_active);

      FETCH dup_cur2 INTO DUP;
      IF (dup_cur2%NOTFOUND)
      THEN
         --set the hierarchy type for the record
         IF mem_dtls_rec.manager_flag = 'Y'
         THEN
             l_hierarchy_type := 'MGR_TO_MGR';
         ELSIF mem_dtls_rec.admin_flag = 'Y'
         THEN
             l_hierarchy_type := 'ADMIN_TO_ADMIN';
         ELSE
             l_hierarchy_type := 'REP_TO_REP';
         END IF;

       --call table handler to insert record in rep manager
         l_reports_to_flag := 'N';

         OPEN rep_mgr_seq_cur;
         FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
         CLOSE rep_mgr_seq_cur;
         jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    => mem_dtls_rec.resource_id,
               X_PERSON_ID => mem_dtls_rec.person_id,
               X_CATEGORY  => mem_dtls_rec.category,
               X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
	       X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
               X_GROUP_ID  => mem_dtls_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => trunc(mem_dtls_rec.start_date_active),
               X_END_DATE_ACTIVE => trunc(mem_dtls_rec.end_date_active),
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => l_role_relate_id,
               X_CHILD_ROLE_RELATE_ID => l_role_relate_id,
               X_DENORM_LEVEL                => 0);




              IF fnd_api.to_boolean (p_commit)
              THEN
                l_count := l_count + 1;
                if (l_count > 1000)
                then
                   COMMIT WORK;
                   l_count := 0;
                end if;
              END IF;

         END IF;  --close of dup check
         CLOSE dup_cur2;

     --fetch managers  in the same group
     -- fetch this only if member is not manager
     if(nvl(mem_dtls_rec.manager_flag , 'N')<> 'Y')
     THEN
       OPEN same_grp_mgr_admin_cur(mem_dtls_rec.group_id,
                                  mem_dtls_rec.start_date_active,
                                  mem_dtls_rec.end_date_active,
                                  mem_dtls_rec.role_relate_id);

       FETCH same_grp_mgr_admin_cur INTO same_grp_mgr_admin_rec;
       l_reports_to_flag := 'Y';

       WHILE(same_grp_mgr_admin_cur%FOUND)
       LOOP

           --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < same_grp_mgr_admin_rec.start_date_active)
            THEN
                 l_start_date_active := same_grp_mgr_admin_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

           l_end_date_active := least(nvl(to_date(to_char(mem_dtls_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date),
                  nvl(to_date(to_char(same_grp_mgr_admin_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date));
           if(l_end_date_active = l_fnd_date)
           then
              l_end_date_active := null;
           end if;
           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then
              OPEN dup_cur2(same_grp_mgr_admin_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         mem_dtls_rec.group_id,
                         l_start_date_active,
                         l_end_date_active);

              FETCH dup_cur2 INTO DUP;
              IF (dup_cur2%notfound)
              THEN


                --set the hierarchy type if of type manager
                   IF mem_dtls_rec.manager_flag = 'Y'
                   THEN
                       l_hierarchy_type := 'MGR_TO_MGR';
                   ELSIF mem_dtls_rec.admin_flag = 'Y'
                   THEN
                       l_hierarchy_type := 'MGR_TO_ADMIN';
                   ELSE
                       l_hierarchy_type := 'MGR_TO_REP';
                   END IF;

                   --INSERT INTO TABLE
                   OPEN rep_mgr_seq_cur;
                   FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                   CLOSE rep_mgr_seq_cur;
                   jtf_rs_rep_managers_pkg.insert_row(
                             X_ROWID => x_row_id,
                             X_DENORM_MGR_ID  => l_denorm_mgr_id,
                             X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                             X_PERSON_ID => mem_dtls_rec.person_id,
                             X_CATEGORY  => mem_dtls_rec.category,
                             X_MANAGER_PERSON_ID => same_grp_mgr_admin_rec.person_id,
	                     X_PARENT_RESOURCE_ID => same_grp_mgr_admin_rec.resource_id,
                             X_GROUP_ID  => mem_dtls_rec.group_id,
                             X_REPORTS_TO_FLAG   => l_reports_to_flag,
                             X_HIERARCHY_TYPE =>   l_hierarchy_type,
                             X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                             X_END_DATE_ACTIVE => trunc(l_end_date_active),
                             X_ATTRIBUTE2 => null,
                             X_ATTRIBUTE3 => null,
                             X_ATTRIBUTE4 => null,
                             X_ATTRIBUTE5 => null,
                             X_ATTRIBUTE6 => null,
                             X_ATTRIBUTE7 => null,
                             X_ATTRIBUTE8 => null,
                             X_ATTRIBUTE9 => null,
                             X_ATTRIBUTE10  => null,
                             X_ATTRIBUTE11  => null,
                             X_ATTRIBUTE12  => null,
                             X_ATTRIBUTE13  => null,
                             X_ATTRIBUTE14  => null,
                             X_ATTRIBUTE15  => null,
                             X_ATTRIBUTE_CATEGORY   => null,
                             X_ATTRIBUTE1       => null,
                             X_CREATION_DATE     => l_date,
                             X_CREATED_BY         => l_user_id,
                             X_LAST_UPDATE_DATE   => l_date,
                             X_LAST_UPDATED_BY    => l_user_id,
                             X_LAST_UPDATE_LOGIN  => l_login_id,
                             X_PAR_ROLE_RELATE_ID => same_grp_mgr_admin_rec.role_relate_id,
                             X_CHILD_ROLE_RELATE_ID => l_role_relate_id,
                             X_DENORM_LEVEL        => 0);

                   IF fnd_api.to_boolean (p_commit)
                   THEN
                     l_count := l_count + 1;
                     if (l_count > 1000)
                     then
                        COMMIT WORK;
                        l_count := 0;
                     end if;
                  END IF;

       end if; -- end of dup check
       close dup_cur2;
     END IF; -- end of st dt < end dt check
    FETCH same_grp_mgr_admin_cur INTO same_grp_mgr_admin_rec;
    END LOOP; -- end of same_grp_mgr_admin_cur
    close same_grp_mgr_admin_cur;
  END IF; -- end of manager flag check for member
  --IF MEMBER IS OF TYPE  MANAGER THEN INSERT RECORDS FOR THE OTHER MEMBERS OF THE GROUP
  IF(mem_dtls_rec.manager_flag = 'Y' )
  THEN
      OPEN other_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active,
                     mem_dtls_rec.role_relate_id);

      FETCH other_cur INTO other_rec;
      WHILE (other_cur%FOUND)
      LOOP

        --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < other_rec.start_date_active)
            THEN
                 l_start_date_active := other_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

           l_end_date_active := least(nvl(to_date(to_char(mem_dtls_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR'), l_fnd_date),
                  nvl(to_date(to_char(other_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR'), l_fnd_date));
           if(l_end_date_active = l_fnd_date)
           then
              l_end_date_active := null;
           end if;
           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then
          --duplicate check
                  OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	             other_rec.role_relate_id,
                     mem_dtls_rec.group_id,
                     l_start_date_active,
                     l_end_date_active);

                  FETCH dup_cur2 INTO DUP;
                  IF (dup_cur2%NOTFOUND)
                  THEN

                    l_reports_to_flag := 'Y';
                    --IF mem_dtls_rec.manager_flag = 'Y'
                    --THEN
                        IF other_rec.manager_flag = 'Y'
                        THEN
                            l_hierarchy_type := 'MGR_TO_MGR';
                        ELSIF other_rec.admin_flag = 'Y'
                        THEN
                            l_hierarchy_type := 'MGR_TO_ADMIN';
                        ELSE
                            l_hierarchy_type := 'MGR_TO_REP';
                        END IF;

                 --call table handler

                 --INSERT INTO TABLE
                    OPEN rep_mgr_seq_cur;
                    FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                    CLOSE rep_mgr_seq_cur;

                    jtf_rs_rep_managers_pkg.insert_row(
                       X_ROWID => x_row_id,
                       X_DENORM_MGR_ID  => l_denorm_mgr_id,
                       X_RESOURCE_ID    =>other_rec.resource_id,
                       X_PERSON_ID =>other_rec.person_id,
                       X_CATEGORY  => other_rec.category,
                       X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
	               X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                       X_GROUP_ID  => mem_dtls_rec.group_id,
                       X_REPORTS_TO_FLAG   => l_reports_to_flag,
                       X_HIERARCHY_TYPE =>   l_hierarchy_type,
                       X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                       X_END_DATE_ACTIVE => trunc(l_end_date_active),
                       X_ATTRIBUTE2 => null,
                       X_ATTRIBUTE3 => null,
                       X_ATTRIBUTE4 => null,
                       X_ATTRIBUTE5 => null,
                       X_ATTRIBUTE6 => null,
                       X_ATTRIBUTE7 => null,
                       X_ATTRIBUTE8 => null,
                       X_ATTRIBUTE9 => null,
                       X_ATTRIBUTE10  => null,
                       X_ATTRIBUTE11  => null,
                       X_ATTRIBUTE12  => null,
                       X_ATTRIBUTE13  => null,
                       X_ATTRIBUTE14  => null,
                       X_ATTRIBUTE15  => null,
                       X_ATTRIBUTE_CATEGORY   => null,
                       X_ATTRIBUTE1       => null,
                       X_CREATION_DATE     => l_date,
                       X_CREATED_BY         => l_user_id,
                       X_LAST_UPDATE_DATE   => l_date,
                       X_LAST_UPDATED_BY    => l_user_id,
                       X_LAST_UPDATE_LOGIN  => l_login_id,
                       X_PAR_ROLE_RELATE_ID => mem_dtls_rec.role_relate_id,
                       X_CHILD_ROLE_RELATE_ID =>other_rec.role_relate_id,
                       X_DENORM_LEVEL        => 0);

              IF fnd_api.to_boolean (p_commit)
              THEN
                l_count := l_count + 1;
                if (l_count > 1000)
                then
                   COMMIT WORK;
                   l_count := 0;
                end if;
              END IF;

    end if; --end of dup check
    close dup_cur2;
    end if; --end of st dt < end dt check

    FETCH other_cur INTO other_rec;
   END LOOP; -- END OF OTHER_CUR
   close other_cur;
 END IF;  -- end of manager flag check

   --fetch all the parent groups for the group
    OPEN par_grp_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);

    FETCH par_grp_cur INTO par_grp_rec;
    WHILE (par_grp_cur%FOUND)
    LOOP

       IF((par_grp_rec.immediate_parent_flag = 'Y')
           AND (nvl(mem_dtls_rec.manager_flag,'N')='Y' ))
       THEN
         l_reports_to_flag := 'Y';
       ELSE
         l_reports_to_flag := 'N';
       END IF;
       --fetch all managers
       OPEN mgr_cur(par_grp_rec.parent_group_id,
                    mem_dtls_rec.start_date_active,
                    mem_dtls_rec.end_date_active);
       FETCH mgr_cur INTO mgr_rec;
       WHILE (mgr_cur%FOUND)
       LOOP

           IF mem_dtls_rec.manager_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_MGR';
           ELSIF mem_dtls_rec.admin_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_ADMIN';
           ELSE
             l_hierarchy_type := 'MGR_TO_REP';
           END IF;




           l_start_date_active := greatest(trunc(mem_dtls_rec.start_date_active),
                                           trunc(mgr_rec.start_date_active),
                                           trunc(par_grp_rec.start_date_active));
           l_end_date_active := least(nvl(to_date(to_char(mem_dtls_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date),
                                      nvl(to_date(to_char(mgr_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date),
                                      nvl(to_date(to_char(par_grp_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date));
           if(l_end_date_active = l_fnd_date)
           then
              l_end_date_active := null;
           end if;

           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then
             --call table handler
               OPEN dup_cur2(mgr_rec.role_relate_id,
  	               mem_dtls_rec.role_relate_id,
                       mem_dtls_rec.group_id,
                       l_start_date_active,
                       l_end_date_active);

                FETCH dup_cur2 INTO DUP;
                IF (dup_cur2%notfound)
                THEN
                     --INSERT INTO TABLE
                     OPEN rep_mgr_seq_cur;
                     FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                     CLOSE rep_mgr_seq_cur;

                    jtf_rs_rep_managers_pkg.insert_row(
                     X_ROWID => x_row_id,
                     X_DENORM_MGR_ID  => l_denorm_mgr_id,
                     X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                     X_PERSON_ID => mem_dtls_rec.person_id,
                     X_CATEGORY  => mem_dtls_rec.category,
                     X_MANAGER_PERSON_ID => mgr_rec.person_id,
	    	     X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                     X_GROUP_ID  => mem_dtls_rec.group_id,
                     X_HIERARCHY_TYPE =>   l_hierarchy_type,
                     X_REPORTS_TO_FLAG   => l_reports_to_flag,
                     X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                     X_END_DATE_ACTIVE => trunc(l_end_date_active),
                     X_ATTRIBUTE2 => null,
                     X_ATTRIBUTE3 => null,
                     X_ATTRIBUTE4 => null,
                     X_ATTRIBUTE5 => null,
                     X_ATTRIBUTE6 => null,
                     X_ATTRIBUTE7 => null,
                     X_ATTRIBUTE8 => null,
                     X_ATTRIBUTE9 => null,
                     X_ATTRIBUTE10  => null,
                     X_ATTRIBUTE11  => null,
                     X_ATTRIBUTE12  => null,
                     X_ATTRIBUTE13  => null,
                     X_ATTRIBUTE14  => null,
                     X_ATTRIBUTE15  => null,
                     X_ATTRIBUTE_CATEGORY   => null,
                     X_ATTRIBUTE1       => null,
                     X_CREATION_DATE     => l_date,
                     X_CREATED_BY         => l_user_id,
                     X_LAST_UPDATE_DATE   => l_date,
                     X_LAST_UPDATED_BY    => l_user_id,
                     X_LAST_UPDATE_LOGIN  => l_login_id,
                     X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                     X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id,
                     X_DENORM_LEVEL        => par_grp_rec.denorm_level);

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                    l_count := l_count + 1;
                    if (l_count > 1000)
                    then
                       COMMIT WORK;
                       l_count := 0;
                    end if;
                  END IF;

           END IF; -- END OF DUP CHECK
           CLOSE dup_cur2;


          --for manager the oppsite record has to be inserted
            IF mem_dtls_rec.manager_flag = 'Y'
            THEN
           --insert for group_id = parent_group_id
           --call to table handler
             OPEN dup_cur2(mgr_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         par_grp_rec.parent_group_id,
                         l_start_date_active,
                         l_end_date_active);

             FETCH dup_cur2 INTO DUP;
             IF (dup_cur2%notfound)
             THEN
             --INSERT INTO TABLE
               OPEN rep_mgr_seq_cur;
               FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
               CLOSE rep_mgr_seq_cur;

              jtf_rs_rep_managers_pkg.insert_row(
                X_ROWID => x_row_id,
                X_DENORM_MGR_ID  => l_denorm_mgr_id,
                X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                X_PERSON_ID => mem_dtls_rec.person_id,
                X_CATEGORY  => mem_dtls_rec.category,
                X_MANAGER_PERSON_ID => mgr_rec.person_id,
                X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                X_GROUP_ID  => par_grp_rec.parent_group_id,
                X_REPORTS_TO_FLAG   => l_reports_to_flag,
                X_HIERARCHY_TYPE =>   l_hierarchy_type,
                X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                X_END_DATE_ACTIVE => trunc(l_end_date_active),
                X_ATTRIBUTE2 => null,
                X_ATTRIBUTE3 => null,
                X_ATTRIBUTE4 => null,
                X_ATTRIBUTE5 => null,
                X_ATTRIBUTE6 => null,
                X_ATTRIBUTE7 => null,
                X_ATTRIBUTE8 => null,
                X_ATTRIBUTE9 => null,
                X_ATTRIBUTE10  => null,
                X_ATTRIBUTE11  => null,
                X_ATTRIBUTE12  => null,
                X_ATTRIBUTE13  => null,
                X_ATTRIBUTE14  => null,
                X_ATTRIBUTE15  => null,
                X_ATTRIBUTE_CATEGORY   => null,
                X_ATTRIBUTE1       => null,
                X_CREATION_DATE     => l_date,
                X_CREATED_BY         => l_user_id,
                X_LAST_UPDATE_DATE   => l_date,
                X_LAST_UPDATED_BY    => l_user_id,
                X_LAST_UPDATE_LOGIN  => l_login_id,
                X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id,
                X_DENORM_LEVEL         => par_grp_rec.denorm_level);

              IF fnd_api.to_boolean (p_commit)
              THEN
                l_count := l_count + 1;
                if (l_count > 1000)
                then
                   COMMIT WORK;
                   l_count := 0;
                end if;
              END IF;

             end if; --end of dup check
             CLOSE dup_cur2;
            END IF; --end of mgr flag check for inserting opp rec
          END IF; -- end of st date check
          FETCH mgr_cur INTO mgr_rec;
       END LOOP;
       CLOSE mgr_cur;
     FETCH par_grp_cur INTO par_grp_rec;
    END LOOP;
    CLOSE par_grp_cur;
     --for managers  get child groups and insert records for each of the members
    IF((mem_dtls_rec.manager_flag = 'Y'))
    THEN
            --fetch all the parent groups for the group
           OPEN child_grp_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);

           FETCH child_grp_cur INTO child_grp_rec;
           WHILE (child_grp_cur%FOUND)
           LOOP


               --fetch all members
                OPEN child_mem_cur(child_grp_rec.group_id,
                    mem_dtls_rec.start_date_active,
                    mem_dtls_rec.end_date_active);
                FETCH child_mem_cur INTO child_mem_rec;
                WHILE (child_mem_cur%FOUND)
                LOOP

                  IF ((child_grp_rec.immediate_parent_flag = 'Y') AND
                      (child_mem_rec.manager_flag = 'Y'))
                  THEN
                    l_reports_to_flag := 'Y';
                  ELSE
                    l_reports_to_flag := 'N';
                  END IF;


                   IF mem_dtls_rec.manager_flag = 'Y'
                   THEN
                     IF(child_mem_rec.manager_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'MGR_TO_MGR';
                     ELSIF(child_mem_rec.ADMIN_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'MGR_TO_ADMIN';
                     ELSE
                       l_hierarchy_type := 'MGR_TO_REP';
                    END IF;
                   END IF;
                   l_start_date_active := greatest(trunc(mem_dtls_rec.start_date_active),
                                           trunc(child_mem_rec.start_date_active),
                                           trunc(child_grp_rec.start_date_active));
            l_end_date_active := least(nvl(to_date(to_char(mem_dtls_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date),
                                     nvl(to_date(to_char(child_mem_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date),
                                     nvl(to_date(to_char(child_grp_rec.end_date_active, 'DD-MM-RRRR'),'DD-MM-RRRR'), l_fnd_date));

                    if(l_end_date_active = l_fnd_date)
                    then
                       l_end_date_active := null;
                    end if;

                    if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
                    then
                       OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	                 child_mem_rec.role_relate_id,
                         child_grp_rec.group_id,
                         l_start_date_active,
                         l_end_date_active);

                       FETCH dup_cur2 INTO DUP;
                       IF (dup_cur2%notfound)
                       THEN

                      --INSERT INTO TABLE
                         OPEN rep_mgr_seq_cur;
                         FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                         CLOSE rep_mgr_seq_cur;

                         jtf_rs_rep_managers_pkg.insert_row(
                           X_ROWID => x_row_id,
                           X_DENORM_MGR_ID  => l_denorm_mgr_id,
                           X_RESOURCE_ID    =>child_mem_rec.resource_id,
                           X_PERSON_ID => child_mem_rec.person_id,
                           X_CATEGORY  => child_mem_rec.category,
                           X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
               	           X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                           X_GROUP_ID  => child_grp_rec.group_id,
                           X_REPORTS_TO_FLAG   => l_reports_to_flag,
                           X_HIERARCHY_TYPE =>   l_hierarchy_type,
                           X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                           X_END_DATE_ACTIVE => trunc(l_end_date_active),
                           X_ATTRIBUTE2 => null,
                           X_ATTRIBUTE3 => null,
                           X_ATTRIBUTE4 => null,
                           X_ATTRIBUTE5 => null,
                           X_ATTRIBUTE6 => null,
                           X_ATTRIBUTE7 => null,
                           X_ATTRIBUTE8 => null,
                           X_ATTRIBUTE9 => null,
                           X_ATTRIBUTE10  => null,
                           X_ATTRIBUTE11  => null,
                           X_ATTRIBUTE12  => null,
                           X_ATTRIBUTE13  => null,
                           X_ATTRIBUTE14  => null,
                           X_ATTRIBUTE15  => null,
                           X_ATTRIBUTE_CATEGORY   => null,
                           X_ATTRIBUTE1       => null,
                           X_CREATION_DATE     => l_date,
                           X_CREATED_BY         => l_user_id,
                           X_LAST_UPDATE_DATE   => l_date,
                           X_LAST_UPDATED_BY    => l_user_id,
                           X_LAST_UPDATE_LOGIN  => l_login_id,
                           X_PAR_ROLE_RELATE_ID => l_role_relate_id,
                           X_CHILD_ROLE_RELATE_ID =>child_mem_rec.role_relate_id,
                           X_DENORM_LEVEL         => child_grp_rec.denorm_level);

                          IF fnd_api.to_boolean (p_commit)
                          THEN
                            l_count := l_count + 1;
                            if (l_count > 1000)
                            then
                               COMMIT WORK;
                               l_count := 0;
                            end if;
                          END IF;


             END IF;  -- end of dup check
             CLOSE dup_cur2;

                 --for manager the opposite record has to be inserted
             IF child_mem_rec.manager_flag = 'Y'
               and mem_dtls_rec.manager_flag = 'Y'
             THEN
                 --insert for group_id = parent_group_id
                 --call to table handler
                    OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	                 child_mem_rec.role_relate_id,
                         mem_dtls_rec.group_id,
                         l_start_date_active,
                     l_end_date_active);
                    FETCH dup_cur2 INTO DUP;
                   IF (dup_cur2%notfound)
                   THEN

                      OPEN rep_mgr_seq_cur;
                      FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                      CLOSE rep_mgr_seq_cur;

                      jtf_rs_rep_managers_pkg.insert_row(
                                   X_ROWID => x_row_id,
                                   X_DENORM_MGR_ID  => l_denorm_mgr_id,
                                   X_RESOURCE_ID    =>child_mem_rec.resource_id,
                                   X_PERSON_ID => child_mem_rec.person_id,
                                   X_CATEGORY  => child_mem_rec.category,
                                   X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
				   X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                                   X_GROUP_ID  => mem_dtls_rec.group_id,
                                   X_REPORTS_TO_FLAG   => l_reports_to_flag,
                                   X_HIERARCHY_TYPE =>   l_hierarchy_type,
                                   X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                                   X_END_DATE_ACTIVE => trunc(l_end_date_active),
                                   X_ATTRIBUTE2 => null,
                                   X_ATTRIBUTE3 => null,
                                   X_ATTRIBUTE4 => null,
                                   X_ATTRIBUTE5 => null,
                                   X_ATTRIBUTE6 => null,
                                   X_ATTRIBUTE7 => null,
                                   X_ATTRIBUTE8 => null,
                                   X_ATTRIBUTE9 => null,
                                   X_ATTRIBUTE10  => null,
                                   X_ATTRIBUTE11  => null,
                                   X_ATTRIBUTE12  => null,
                                   X_ATTRIBUTE13  => null,
                                   X_ATTRIBUTE14  => null,
                                   X_ATTRIBUTE15  => null,
                                   X_ATTRIBUTE_CATEGORY   => null,
                                   X_ATTRIBUTE1       => null,
                                   X_CREATION_DATE     => l_date,
                                   X_CREATED_BY         => l_user_id,
                                   X_LAST_UPDATE_DATE   => l_date,
                                   X_LAST_UPDATED_BY    => l_user_id,
                                   X_LAST_UPDATE_LOGIN  => l_login_id,
                                   X_PAR_ROLE_RELATE_ID => l_role_relate_id,
                                   X_CHILD_ROLE_RELATE_ID =>child_mem_rec.role_relate_id,
                                   X_DENORM_LEVEL         => child_grp_rec.denorm_level);

                       IF fnd_api.to_boolean (p_commit)
                       THEN
                         l_count := l_count + 1;
                         if (l_count > 1000)
                         then
                            COMMIT WORK;
                            l_count := 0;
                         end if;
                       END IF;

                   END IF; --end of dup check
                   CLOSE dup_cur2;
             END IF; -- end of child mem mgr flag check
         END IF; --end of st dt check

          FETCH child_mem_cur INTO child_mem_rec;
          END LOOP;
          CLOSE child_mem_cur;

          FETCH child_grp_cur INTO child_grp_rec;
        END LOOP;
        CLOSE child_grp_cur;
     END IF; --end of child group members insert if mem mgr flag = Y

  END IF;--end of member details found if statement


  CLOSE mem_dtls_cur;

  --
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END INSERT_REP_MANAGER;


--for migration

   /*FOR INSERT IN JTF_RS_ROLE_RELATIONS */
   PROCEDURE  INSERT_REP_MANAGER_MIGR(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2,
                   P_COMMIT          IN     VARCHAR2,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 )
  IS
  CURSOR rep_mgr_seq_cur
      IS
   SELECT jtf_rs_rep_managers_s.nextval
     FROM dual;


   CURSOR  mem_dtls_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  rlt.role_relate_id = l_role_relate_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_resource_id   = mem.group_member_id
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id        = rsc.resource_id;


  mem_dtls_rec   mem_dtls_cur%rowtype;

  --CURSOR for other members in same group

   CURSOR  other_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                     l_start_date_active DATE,
                     l_end_date_active   DATE,
                     l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id = l_group_id
    AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_relate_id <> l_role_relate_id
     AND  ((rlt.start_date_active  between l_start_date_active and
                                           nvl(l_end_date_active,rlt.start_date_active+1))
        OR (rlt.end_date_active between l_start_date_active
                                          and nvl(l_end_date_active,rlt.end_date_active+1))
        OR ((rlt.start_date_active <= l_start_date_active)
                          AND (rlt.end_date_active >= l_end_date_active
                                          OR l_end_date_active IS NULL)))
     AND  rlt.role_id            = rol.role_id
     AND  mem.resource_id        = rsc.resource_id;


  other_rec   other_cur%rowtype;

  --cursor for duplicate check
  CURSOR dup_cur(l_person_id            JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_manager_person_id    JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_group_id	      JTF_RS_GROUPS_B.GROUP_ID%TYPE,
	       l_resource_id	      JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
               l_start_date_active    DATE,
               l_end_date_active      DATE)
         IS
          SELECT  person_id
            FROM  jtf_rs_rep_managers
            WHERE group_id = l_group_id
	      AND ( person_id = l_person_id
                        OR (l_person_id IS NULL AND person_id IS NULL))
              AND manager_person_id = l_manager_person_id
	      AND resource_id = l_resource_id
              AND start_date_active = l_start_date_active
              AND (end_date_active   = l_end_date_active
                 OR ( end_date_active IS NULL AND l_end_date_active IS NULL));

  CURSOR dup_cur2(l_par_role_relate_id         JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_child_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_group_id                   JTF_RS_GROUPS_B.GROUP_ID%TYPE)
     IS
     SELECT person_id
     FROM jtf_rs_rep_managers
    WHERE par_role_relate_id = l_par_role_relate_id
     AND  child_role_relate_id = l_child_role_relate_id
     AND  group_id   = l_group_id;



  dup     NUMBER := 0;

  --cursor for same group manager and admin
  CURSOR same_grp_mgr_admin_cur(l_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                                l_start_date_active  DATE,
                                l_end_date_active    DATE,
                                l_role_relate_id     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
  SELECT /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.admin_flag  ,
          rol.manager_flag,
          rlt.role_relate_id
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_B rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_relate_id      <> l_role_relate_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     --AND  rlt.role_relate_id <> l_role_relate_id
     AND  ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)))
     AND  rlt.role_id            = rol.role_id
     AND  (rol.manager_flag   = 'Y');

    -- removed this as admin is not reqd          OR rol.admin_flag = 'Y');

  same_grp_mgr_admin_rec same_grp_mgr_admin_cur%ROWTYPE;

  --cursor for parent groups
  CURSOR  par_grp_cur(l_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
      IS
  SELECT  parent_group_id,
          immediate_parent_flag
    FROM  jtf_rs_groups_denorm
   WHERE  group_id = l_group_id
     AND  parent_group_id <> l_group_id
     AND  ((l_start_date_active between start_date_active
                                and nvl(end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, start_date_active +1)
                      between start_date_active  and
                           nvl(end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and end_date_active is null)));

  par_grp_rec   par_grp_cur%ROWTYPE;


  --cursor to fetch admin for a group
  CURSOR admin_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_id            = rol.role_id
     AND  rol.admin_flag   = 'Y'
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));

  admin_rec admin_cur%rowtype;

--cursor to fetch managers for a group
   CURSOR mgr_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT  /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
    FROM  jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  rol.manager_flag   = 'Y'
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));


  mgr_rec mgr_cur%rowtype;

  --cursor for child groups
  CURSOR child_grp_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
   SELECT group_id,
          immediate_parent_flag
    FROM  jtf_rs_groups_denorm
   WHERE  parent_group_id = l_group_id
     AND  group_id <> l_group_id
      AND ((l_start_date_active between start_date_active
                                and nvl(end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, start_date_active +1)
                      between start_date_active  and
                           nvl(end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and end_date_active is null)));

  child_grp_rec   child_grp_cur%rowtype;


  --cursor for child group members
  CURSOR child_mem_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.manager_flag,
          rol.admin_flag,
          rol.member_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_b rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     --AND  rlt.start_date_active <= l_start_date_active
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)))
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id     = rsc.resource_id;

 child_mem_rec child_mem_cur%rowtype;

  l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE := p_role_relate_id;
  l_hierarchy_type JTF_RS_REP_MANAGERS.HIERARCHY_TYPE%TYPE;
  l_reports_to_flag  JTF_RS_REP_MANAGERS.REPORTS_TO_FLAG%TYPE;
  l_denorm_mgr_id	JTF_RS_REP_MANAGERS.DENORM_MGR_ID%TYPE;
  x_row_id              VARCHAR2(100);

  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REP_MANAGER';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  l_start_date_active DATE;
  l_end_date_active  DATE;
  l_count number := 0;
  BEGIN
   --Standard Start of API SAVEPOINT
     SAVEPOINT member_denormalize;

    x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
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

    -- if no group id or person id is passed in then return
   IF p_role_relate_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_RESOURCE_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
   END IF;


   --fetch the member details
   OPEN mem_dtls_cur(l_role_relate_id);
   FETCH mem_dtls_cur INTO mem_dtls_rec;
   IF(mem_dtls_cur%FOUND)
   THEN
       --duplicate check for the member record
      OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	         mem_dtls_rec.role_relate_id,
                 mem_dtls_rec.group_id);

      FETCH dup_cur2 INTO DUP;
      IF (dup_cur2%NOTFOUND)
      THEN
         --set the hierarchy type for the record
         IF mem_dtls_rec.manager_flag = 'Y'
         THEN
             l_hierarchy_type := 'MGR_TO_MGR';
         ELSIF mem_dtls_rec.admin_flag = 'Y'
         THEN
             l_hierarchy_type := 'ADMIN_TO_ADMIN';
         ELSE
             l_hierarchy_type := 'REP_TO_REP';
         END IF;

       --call table handler to insert record in rep manager
         l_reports_to_flag := 'N';

         OPEN rep_mgr_seq_cur;
         FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
         CLOSE rep_mgr_seq_cur;
         jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    => mem_dtls_rec.resource_id,
               X_PERSON_ID => mem_dtls_rec.person_id,
               X_CATEGORY  => mem_dtls_rec.category,
               X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
	       X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
               X_GROUP_ID  => mem_dtls_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => trunc(mem_dtls_rec.start_date_active),
               X_END_DATE_ACTIVE => trunc(mem_dtls_rec.end_date_active),
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => l_role_relate_id,
               X_CHILD_ROLE_RELATE_ID => l_role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

         END IF;  --close of dup check
         CLOSE dup_cur2;

     --get all the managers and admins for the member within the same group
     --fetch managers and admins in the same group
     OPEN same_grp_mgr_admin_cur(mem_dtls_rec.group_id,
                                  mem_dtls_rec.start_date_active,
                                  mem_dtls_rec.end_date_active,
                                  mem_dtls_rec.role_relate_id);

     FETCH same_grp_mgr_admin_cur INTO same_grp_mgr_admin_rec;
     l_reports_to_flag := 'Y';

     WHILE(same_grp_mgr_admin_cur%FOUND)
     LOOP

           --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < same_grp_mgr_admin_rec.start_date_active)
            THEN
                 l_start_date_active := same_grp_mgr_admin_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

            IF(mem_dtls_rec.end_date_active > same_grp_mgr_admin_rec.end_date_active)
            THEN
                 l_end_date_active := same_grp_mgr_admin_rec.end_date_active;
            ELSIF(same_grp_mgr_admin_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := mem_dtls_rec.end_date_active;
            ELSIF(mem_dtls_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := same_grp_mgr_admin_rec.end_date_active;
            END IF;


           OPEN dup_cur2(same_grp_mgr_admin_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         mem_dtls_rec.group_id);

           FETCH dup_cur2 INTO DUP;
           IF (dup_cur2%notfound)
           THEN


                --set the hierarchy type if of type manager
                IF same_grp_mgr_admin_rec.manager_flag = 'Y'
                THEN
                   IF mem_dtls_rec.manager_flag = 'Y'
                   THEN
                       l_hierarchy_type := 'MGR_TO_MGR';
                   ELSIF mem_dtls_rec.admin_flag = 'Y'
                   THEN
                       l_hierarchy_type := 'MGR_TO_ADMIN';
                   ELSE
                       l_hierarchy_type := 'MGR_TO_REP';
                   END IF;

                   --INSERT INTO TABLE
                   OPEN rep_mgr_seq_cur;
                   FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                   CLOSE rep_mgr_seq_cur;
                   jtf_rs_rep_managers_pkg.insert_row(
                             X_ROWID => x_row_id,
                             X_DENORM_MGR_ID  => l_denorm_mgr_id,
                             X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                             X_PERSON_ID => mem_dtls_rec.person_id,
                             X_CATEGORY  => mem_dtls_rec.category,
                             X_MANAGER_PERSON_ID => same_grp_mgr_admin_rec.person_id,
			     X_PARENT_RESOURCE_ID => same_grp_mgr_admin_rec.resource_id,
                             X_GROUP_ID  => mem_dtls_rec.group_id,
                             X_REPORTS_TO_FLAG   => l_reports_to_flag,
                             X_HIERARCHY_TYPE =>   l_hierarchy_type,
                             X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                             X_END_DATE_ACTIVE => trunc(l_end_date_active),
                             X_ATTRIBUTE2 => null,
                             X_ATTRIBUTE3 => null,
                             X_ATTRIBUTE4 => null,
                             X_ATTRIBUTE5 => null,
                             X_ATTRIBUTE6 => null,
                             X_ATTRIBUTE7 => null,
                             X_ATTRIBUTE8 => null,
                             X_ATTRIBUTE9 => null,
                             X_ATTRIBUTE10  => null,
                             X_ATTRIBUTE11  => null,
                             X_ATTRIBUTE12  => null,
                             X_ATTRIBUTE13  => null,
                             X_ATTRIBUTE14  => null,
                             X_ATTRIBUTE15  => null,
                             X_ATTRIBUTE_CATEGORY   => null,
                             X_ATTRIBUTE1       => null,
                             X_CREATION_DATE     => l_date,
                             X_CREATED_BY         => l_user_id,
                             X_LAST_UPDATE_DATE   => l_date,
                             X_LAST_UPDATED_BY    => l_user_id,
                             X_LAST_UPDATE_LOGIN  => l_login_id,
                             X_PAR_ROLE_RELATE_ID => same_grp_mgr_admin_rec.role_relate_id,
                             X_CHILD_ROLE_RELATE_ID => l_role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;


                 END IF;

                  --set the hierarchy type if of type admin
                 /*IF same_grp_mgr_admin_rec.admin_flag = 'Y'
                 THEN
                    IF mem_dtls_rec.manager_flag = 'Y'
                    THEN
                         l_hierarchy_type := 'ADMIN_TO_MGR';
                    ELSIF mem_dtls_rec.admin_flag = 'Y'
                    THEN
                         l_hierarchy_type := 'ADMIN_TO_ADMIN';
                    ELSE
                         l_hierarchy_type := 'ADMIN_TO_REP';
                    END IF;

                    -- CALL TABLE HANDLER TO insert record
                    OPEN rep_mgr_seq_cur;
                    FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                    CLOSE rep_mgr_seq_cur;

                    jtf_rs_rep_managers_pkg.insert_row(
                             X_ROWID => x_row_id,
                             X_DENORM_MGR_ID  => l_denorm_mgr_id,
                             X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                             X_PERSON_ID => mem_dtls_rec.person_id,
                             X_CATEGORY  => mem_dtls_rec.category,
                             X_MANAGER_PERSON_ID => same_grp_mgr_admin_rec.person_id,
			     X_PARENT_RESOURCE_ID => same_grp_mgr_admin_rec.resource_id,
                             X_GROUP_ID  => mem_dtls_rec.group_id,
                             X_REPORTS_TO_FLAG   => l_reports_to_flag,
                             X_HIERARCHY_TYPE =>   l_hierarchy_type,
                             X_START_DATE_ACTIVE    => l_start_date_active,
                             X_END_DATE_ACTIVE => l_end_date_active,
                             X_ATTRIBUTE2 => null,
                             X_ATTRIBUTE3 => null,
                             X_ATTRIBUTE4 => null,
                             X_ATTRIBUTE5 => null,
                             X_ATTRIBUTE6 => null,
                             X_ATTRIBUTE7 => null,
                             X_ATTRIBUTE8 => null,
                             X_ATTRIBUTE9 => null,
                             X_ATTRIBUTE10  => null,
                             X_ATTRIBUTE11  => null,
                             X_ATTRIBUTE12  => null,
                             X_ATTRIBUTE13  => null,
                             X_ATTRIBUTE14  => null,
                             X_ATTRIBUTE15  => null,
                             X_ATTRIBUTE_CATEGORY   => null,
                             X_ATTRIBUTE1       => null,
                             X_CREATION_DATE     => l_date,
                             X_CREATED_BY         => l_user_id,
                             X_LAST_UPDATE_DATE   => l_date,
                             X_LAST_UPDATED_BY    => l_user_id,
                             X_LAST_UPDATE_LOGIN  => l_login_id,
                             X_PAR_ROLE_RELATE_ID => same_grp_mgr_admin_rec.role_relate_id,
                            X_CHILD_ROLE_RELATE_ID => l_role_relate_id);
                END IF; */


         end if;
         close dup_cur2;
         FETCH same_grp_mgr_admin_cur INTO same_grp_mgr_admin_rec;
     END LOOP; -- end of same_grp_mgr_admin_cur

  --IF MEMBER IS OF TYPE ADMIN OR MANAGER THEN INSERT RECORDS FOR THE OTHER MEMBERS OF THE GROUP
   --IF(mem_dtls_rec.admin_flag = 'Y' OR mem_dtls_rec.manager_flag = 'Y')
   --changed this for migration
   IF(mem_dtls_rec.manager_flag = 'Y')
   THEN
      OPEN other_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active,
                     mem_dtls_rec.role_relate_id);

      FETCH other_cur INTO other_rec;
      WHILE (other_cur%FOUND)
      LOOP

        --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < other_rec.start_date_active)
            THEN
                 l_start_date_active := other_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

            IF(mem_dtls_rec.end_date_active > other_rec.end_date_active)
            THEN
                 l_end_date_active := other_rec.end_date_active;
            ELSIF(other_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := mem_dtls_rec.end_date_active;
            ELSIF(mem_dtls_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := other_rec.end_date_active;
            END IF;

          --duplicate check
           OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	             other_rec.role_relate_id,
                     mem_dtls_rec.group_id);

           FETCH dup_cur2 INTO DUP;
           IF (dup_cur2%NOTFOUND)
           THEN

             l_reports_to_flag := 'Y';
             IF mem_dtls_rec.manager_flag = 'Y'
             THEN
                 IF(other_rec.manager_flag = 'Y')
                 THEN
                          l_hierarchy_type := 'MGR_TO_MGR';
                 ELSIF(other_rec.admin_flag = 'Y')
                 THEN
                     l_hierarchy_type := 'MGR_TO_ADMIN';
                 ELSE
                     l_hierarchy_type := 'MGR_TO_REP';
                END IF;

             --call table handler

             --INSERT INTO TABLE
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

                jtf_rs_rep_managers_pkg.insert_row(
                   X_ROWID => x_row_id,
                   X_DENORM_MGR_ID  => l_denorm_mgr_id,
                   X_RESOURCE_ID    =>other_rec.resource_id,
                   X_PERSON_ID =>other_rec.person_id,
                   X_CATEGORY  => other_rec.category,
                   X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
		   X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                   X_GROUP_ID  => mem_dtls_rec.group_id,
                   X_REPORTS_TO_FLAG   => l_reports_to_flag,
                   X_HIERARCHY_TYPE =>   l_hierarchy_type,
                   X_START_DATE_ACTIVE    => l_start_date_active,
                   X_END_DATE_ACTIVE => l_end_date_active,
                   X_ATTRIBUTE2 => null,
                   X_ATTRIBUTE3 => null,
                   X_ATTRIBUTE4 => null,
                   X_ATTRIBUTE5 => null,
                   X_ATTRIBUTE6 => null,
                   X_ATTRIBUTE7 => null,
                   X_ATTRIBUTE8 => null,
                   X_ATTRIBUTE9 => null,
                   X_ATTRIBUTE10  => null,
                   X_ATTRIBUTE11  => null,
                   X_ATTRIBUTE12  => null,
                   X_ATTRIBUTE13  => null,
                   X_ATTRIBUTE14  => null,
                   X_ATTRIBUTE15  => null,
                   X_ATTRIBUTE_CATEGORY   => null,
                   X_ATTRIBUTE1       => null,
                   X_CREATION_DATE     => l_date,
                   X_CREATED_BY         => l_user_id,
                   X_LAST_UPDATE_DATE   => l_date,
                   X_LAST_UPDATED_BY    => l_user_id,
                   X_LAST_UPDATE_LOGIN  => l_login_id,
                   X_PAR_ROLE_RELATE_ID => mem_dtls_rec.role_relate_id,
                   X_CHILD_ROLE_RELATE_ID =>other_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;


             END IF; -- end of manager flag = y



             /*IF mem_dtls_rec.admin_flag = 'Y'
             THEN
                IF(other_rec.manager_flag = 'Y')
                THEN
                    l_hierarchy_type := 'ADMIN_TO_MGR';
                ELSIF(other_rec.admin_flag = 'Y')
                THEN
                    l_hierarchy_type := 'ADMIN_TO_ADMIN';
                ELSE
                   l_hierarchy_type := 'ADMIN_TO_REP';
                END IF;

               --call table handler

               --INSERT INTO TABLE
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

          jtf_rs_rep_managers_pkg.insert_row(
                   X_ROWID => x_row_id,
                   X_DENORM_MGR_ID  => l_denorm_mgr_id,
                   X_RESOURCE_ID    =>other_rec.resource_id,
                   X_PERSON_ID =>other_rec.person_id,
                   X_CATEGORY  => other_rec.category,
                   X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
		   X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                   X_GROUP_ID  => mem_dtls_rec.group_id,
                   X_REPORTS_TO_FLAG   => l_reports_to_flag,
                   X_HIERARCHY_TYPE =>   l_hierarchy_type,
                   X_START_DATE_ACTIVE    => l_start_date_active,
                   X_END_DATE_ACTIVE => l_end_date_active,
                   X_ATTRIBUTE2 => null,
                   X_ATTRIBUTE3 => null,
                   X_ATTRIBUTE4 => null,
                   X_ATTRIBUTE5 => null,
                   X_ATTRIBUTE6 => null,
                   X_ATTRIBUTE7 => null,
                   X_ATTRIBUTE8 => null,
                   X_ATTRIBUTE9 => null,
                   X_ATTRIBUTE10  => null,
                   X_ATTRIBUTE11  => null,
                   X_ATTRIBUTE12  => null,
                   X_ATTRIBUTE13  => null,
                   X_ATTRIBUTE14  => null,
                   X_ATTRIBUTE15  => null,
                   X_ATTRIBUTE_CATEGORY   => null,
                   X_ATTRIBUTE1       => null,
                   X_CREATION_DATE     => l_date,
                   X_CREATED_BY         => l_user_id,
                   X_LAST_UPDATE_DATE   => l_date,
                   X_LAST_UPDATED_BY    => l_user_id,
                   X_LAST_UPDATE_LOGIN  => l_login_id,
                   X_PAR_ROLE_RELATE_ID => mem_dtls_rec.role_relate_id,
                   X_CHILD_ROLE_RELATE_ID =>other_rec.role_relate_id);
             END IF; -- end of admin flag = y */
       end if;
       close dup_cur2;

       FETCH other_cur INTO other_rec;
     END LOOP; -- END OF OTHER_CUR
   END IF;

   --fetch all the parent groups for the group
    OPEN par_grp_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);

    FETCH par_grp_cur INTO par_grp_rec;
    WHILE (par_grp_cur%FOUND)
    LOOP

       IF((par_grp_rec.immediate_parent_flag = 'Y')
           AND (nvl(mem_dtls_rec.manager_flag,'N')='Y' ))
       THEN
         l_reports_to_flag := 'Y';
       ELSE
         l_reports_to_flag := 'N';
       END IF;
       --fetch all managers
       OPEN mgr_cur(par_grp_rec.parent_group_id,
                    mem_dtls_rec.start_date_active,
                    mem_dtls_rec.end_date_active);
       FETCH mgr_cur INTO mgr_rec;
       WHILE (mgr_cur%FOUND)
       LOOP

           IF mem_dtls_rec.manager_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_MGR';
           ELSIF mem_dtls_rec.admin_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_ADMIN';
           ELSE
             l_hierarchy_type := 'MGR_TO_REP';
           END IF;



             --assign start date and end date for which this relation is valid
           IF(mem_dtls_rec.start_date_active < mgr_rec.start_date_active)
           THEN
                    l_start_date_active := mgr_rec.start_date_active;
           ELSE
                     l_start_date_active := mem_dtls_rec.start_date_active;
           END IF;

           IF(mem_dtls_rec.end_date_active > mgr_rec.end_date_active)
           THEN
                    l_end_date_active := mgr_rec.end_date_active;
           ELSIF(mgr_rec.end_date_active IS NULL)
           THEN
                    l_end_date_active := mem_dtls_rec.end_date_active;
           ELSIF(mem_dtls_rec.end_date_active IS NULL)
           THEN
                    l_end_date_active := mgr_rec.end_date_active;
           END IF;


             --call table handler
           OPEN dup_cur2(mgr_rec.role_relate_id,
  	               mem_dtls_rec.role_relate_id,
                       mem_dtls_rec.group_id);

            FETCH dup_cur2 INTO DUP;
            IF (dup_cur2%notfound)
            THEN
             --INSERT INTO TABLE
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

            jtf_rs_rep_managers_pkg.insert_row(
                 X_ROWID => x_row_id,
                 X_DENORM_MGR_ID  => l_denorm_mgr_id,
                 X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                 X_PERSON_ID => mem_dtls_rec.person_id,
                 X_CATEGORY  => mem_dtls_rec.category,
                 X_MANAGER_PERSON_ID => mgr_rec.person_id,
		 X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                 X_GROUP_ID  => mem_dtls_rec.group_id,
                 X_HIERARCHY_TYPE =>   l_hierarchy_type,
                 X_REPORTS_TO_FLAG   => l_reports_to_flag,
                 X_START_DATE_ACTIVE    => l_start_date_active,
                 X_END_DATE_ACTIVE => l_end_date_active,
                 X_ATTRIBUTE2 => null,
                 X_ATTRIBUTE3 => null,
                 X_ATTRIBUTE4 => null,
                 X_ATTRIBUTE5 => null,
                 X_ATTRIBUTE6 => null,
                 X_ATTRIBUTE7 => null,
                 X_ATTRIBUTE8 => null,
                 X_ATTRIBUTE9 => null,
                 X_ATTRIBUTE10  => null,
                 X_ATTRIBUTE11  => null,
                 X_ATTRIBUTE12  => null,
                 X_ATTRIBUTE13  => null,
                 X_ATTRIBUTE14  => null,
                 X_ATTRIBUTE15  => null,
                 X_ATTRIBUTE_CATEGORY   => null,
                 X_ATTRIBUTE1       => null,
                 X_CREATION_DATE     => l_date,
                 X_CREATED_BY         => l_user_id,
                 X_LAST_UPDATE_DATE   => l_date,
                 X_LAST_UPDATED_BY    => l_user_id,
                 X_LAST_UPDATE_LOGIN  => l_login_id,
                 X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                 X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

           END IF; -- END OF DUP CHECK
           CLOSE dup_cur2;



          --for manager the oppsite record has to be inserted
            IF mem_dtls_rec.manager_flag = 'Y'
            THEN
           --insert for group_id = parent_group_id
           --call to table handler
             OPEN dup_cur2(mgr_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         par_grp_rec.parent_group_id);

             FETCH dup_cur2 INTO DUP;
             IF (dup_cur2%notfound)
             THEN
             --INSERT INTO TABLE
               OPEN rep_mgr_seq_cur;
               FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
               CLOSE rep_mgr_seq_cur;

              jtf_rs_rep_managers_pkg.insert_row(
                X_ROWID => x_row_id,
                X_DENORM_MGR_ID  => l_denorm_mgr_id,
                X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                X_PERSON_ID => mem_dtls_rec.person_id,
                X_CATEGORY  => mem_dtls_rec.category,
                X_MANAGER_PERSON_ID => mgr_rec.person_id,
		X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                X_GROUP_ID  => par_grp_rec.parent_group_id,
                X_REPORTS_TO_FLAG   => l_reports_to_flag,
                X_HIERARCHY_TYPE =>   l_hierarchy_type,
                X_START_DATE_ACTIVE    => l_start_date_active,
                X_END_DATE_ACTIVE => l_end_date_active,
                X_ATTRIBUTE2 => null,
                X_ATTRIBUTE3 => null,
                X_ATTRIBUTE4 => null,
                X_ATTRIBUTE5 => null,
                X_ATTRIBUTE6 => null,
                X_ATTRIBUTE7 => null,
                X_ATTRIBUTE8 => null,
                X_ATTRIBUTE9 => null,
                X_ATTRIBUTE10  => null,
                X_ATTRIBUTE11  => null,
                X_ATTRIBUTE12  => null,
                X_ATTRIBUTE13  => null,
                X_ATTRIBUTE14  => null,
                X_ATTRIBUTE15  => null,
                X_ATTRIBUTE_CATEGORY   => null,
                X_ATTRIBUTE1       => null,
                X_CREATION_DATE     => l_date,
                X_CREATED_BY         => l_user_id,
                X_LAST_UPDATE_DATE   => l_date,
                X_LAST_UPDATED_BY    => l_user_id,
                X_LAST_UPDATE_LOGIN  => l_login_id,
                X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

             end if;
             CLOSE dup_cur2;
          END IF;
          FETCH mgr_cur INTO mgr_rec;
       END LOOP;
       CLOSE mgr_cur;


       --for admin reports to flag is always N for parent groups
       l_reports_to_flag := 'N';


       --fetch all ADMINS --- commented out for migrate
       /*OPEN admin_cur(par_grp_rec.parent_group_id,
		     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);
       FETCH admin_cur INTO admin_rec;
       WHILE (admin_cur%FOUND)
       LOOP



          IF mem_dtls_rec.manager_flag = 'Y'
          THEN
             l_hierarchy_type := 'ADMIN_TO_MGR';
          ELSIF mem_dtls_rec.admin_flag = 'Y'
          THEN
             l_hierarchy_type := 'ADMIN_TO_ADMIN';
          ELSE
             l_hierarchy_type := 'ADMIN_TO_REP';
          END IF;
         --call table handler
           --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < admin_rec.start_date_active)
            THEN
                 l_start_date_active := admin_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

            IF(mem_dtls_rec.end_date_active > admin_rec.end_date_active)
            THEN
                 l_end_date_active := admin_rec.end_date_active;
            ELSIF(admin_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := mem_dtls_rec.end_date_active;
            ELSIF(mem_dtls_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := admin_rec.end_date_active;
            END IF;

           OPEN dup_cur2(admin_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         mem_dtls_rec.group_id);

           FETCH dup_cur2 INTO DUP;
           IF (dup_cur2%notfound)
           THEN

             --INSERT INTO TABLE
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

                jtf_rs_rep_managers_pkg.insert_row(
                   X_ROWID => x_row_id,
                   X_DENORM_MGR_ID  => l_denorm_mgr_id,
                   X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                   X_PERSON_ID => mem_dtls_rec.person_id,
                   X_CATEGORY  => mem_dtls_rec.category,
                   X_MANAGER_PERSON_ID => admin_rec.person_id,
		   X_PARENT_RESOURCE_ID => admin_rec.resource_id,
                   X_GROUP_ID  => mem_dtls_rec.group_id,
                   X_REPORTS_TO_FLAG   => l_reports_to_flag,
                   X_HIERARCHY_TYPE =>   l_hierarchy_type,
                   X_START_DATE_ACTIVE    => l_start_date_active,
                   X_END_DATE_ACTIVE => l_end_date_active,
                   X_ATTRIBUTE2 => null,
                   X_ATTRIBUTE3 => null,
                   X_ATTRIBUTE4 => null,
                   X_ATTRIBUTE5 => null,
                   X_ATTRIBUTE6 => null,
                   X_ATTRIBUTE7 => null,
                   X_ATTRIBUTE8 => null,
                   X_ATTRIBUTE9 => null,
                   X_ATTRIBUTE10  => null,
                   X_ATTRIBUTE11  => null,
                   X_ATTRIBUTE12  => null,
                   X_ATTRIBUTE13  => null,
                   X_ATTRIBUTE14  => null,
                   X_ATTRIBUTE15  => null,
                   X_ATTRIBUTE_CATEGORY   => null,
                   X_ATTRIBUTE1       => null,
                   X_CREATION_DATE     => l_date,
                   X_CREATED_BY         => l_user_id,
                   X_LAST_UPDATE_DATE   => l_date,
                   X_LAST_UPDATED_BY    => l_user_id,
                   X_LAST_UPDATE_LOGIN  => l_login_id,
                   X_PAR_ROLE_RELATE_ID => admin_rec.role_relate_id,
                   X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

             end if; -- end of dup check
             CLOSE dup_cur2;
         --for manager the oppsite record has to be inserted
         IF mem_dtls_rec.manager_flag = 'Y'
         THEN
           --insert for group_id = parent_group_id
           --call to table handler
              --INSERT INTO TABLE
           OPEN dup_cur2(admin_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         mem_dtls_rec.group_id);

           FETCH dup_cur2 INTO DUP;
           IF (dup_cur2%notfound)
           THEN
             OPEN rep_mgr_seq_cur;
             FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
             CLOSE rep_mgr_seq_cur;

             jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    => mem_dtls_rec.resource_id,
               X_PERSON_ID => mem_dtls_rec.person_id,
               X_CATEGORY  => mem_dtls_rec.category,
               X_MANAGER_PERSON_ID => admin_rec.person_id,
	       X_PARENT_RESOURCE_ID => admin_rec.resource_id,
               X_GROUP_ID  => mem_dtls_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => l_start_date_active,
               X_END_DATE_ACTIVE => l_end_date_active,
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => admin_rec.role_relate_id,
               X_CHILD_ROLE_RELATE_ID => mem_dtls_rec.role_relate_id);
           end if; -- end of duplicate check;
           CLOSE dup_cur2;
         END IF;
         FETCH admin_cur INTO admin_rec;

       END LOOP;
       CLOSE admin_cur; */

     FETCH par_grp_cur INTO par_grp_rec;
    END LOOP;
    CLOSE par_grp_cur;


     --for managers and admins get child groups and insert records for each of the members
    IF((mem_dtls_rec.manager_flag = 'Y') )
    -- OR (mem_dtls_rec.admin_flag = 'Y')) --for migration
    THEN
            --fetch all the parent groups for the group
           OPEN child_grp_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);

           FETCH child_grp_cur INTO child_grp_rec;
           WHILE (child_grp_cur%FOUND)
           LOOP


               --fetch all members
                OPEN child_mem_cur(child_grp_rec.group_id,
                    mem_dtls_rec.start_date_active,
                    mem_dtls_rec.end_date_active);
                FETCH child_mem_cur INTO child_mem_rec;
                WHILE (child_mem_cur%FOUND)
                LOOP

                  IF ((child_grp_rec.immediate_parent_flag = 'Y') AND
                      (child_mem_rec.manager_flag = 'Y'))
                  THEN
                    l_reports_to_flag := 'Y';
                  ELSE
                    l_reports_to_flag := 'N';
                  END IF;


                   IF mem_dtls_rec.manager_flag = 'Y'
                   THEN
                     IF(child_mem_rec.manager_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'MGR_TO_MGR';
                     ELSIF(child_mem_rec.ADMIN_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'MGR_TO_ADMIN';
                     ELSE
                       l_hierarchy_type := 'MGR_TO_REP';
                    END IF;
                   END IF;
                 /*  IF mem_dtls_rec.admin_flag = 'Y'
                   THEN
                     IF(child_mem_rec.manager_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'ADMIN_TO_MGR';
                     ELSIF(child_mem_rec.ADMIN_flag = 'Y')
                     THEN
                       l_hierarchy_type := 'ADMIN_TO_ADMIN';
                     ELSE
                       l_hierarchy_type := 'ADMIN_TO_REP';
                    END IF;
                   END IF; */
                   --call table handler
                    --assign start date and end date for which this relation is valid
            IF(mem_dtls_rec.start_date_active < child_mem_rec.start_date_active)
            THEN
                 l_start_date_active := child_mem_rec.start_date_active;
            ELSE
                 l_start_date_active := mem_dtls_rec.start_date_active;
            END IF;

            IF(mem_dtls_rec.end_date_active > child_mem_rec.end_date_active)
            THEN
                 l_end_date_active := child_mem_rec.end_date_active;
            ELSIF(child_mem_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := mem_dtls_rec.end_date_active;
            ELSIF(mem_dtls_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := child_mem_rec.end_date_active;
            END IF;

           OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	                 child_mem_rec.role_relate_id,
                         child_grp_rec.group_id);

           FETCH dup_cur2 INTO DUP;
           IF (dup_cur2%notfound)
           THEN

             --INSERT INTO TABLE
             OPEN rep_mgr_seq_cur;
             FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
             CLOSE rep_mgr_seq_cur;

             jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    =>child_mem_rec.resource_id,
               X_PERSON_ID => child_mem_rec.person_id,
               X_CATEGORY  => child_mem_rec.category,
               X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
	       X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
               X_GROUP_ID  => child_grp_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => l_start_date_active,
               X_END_DATE_ACTIVE => l_end_date_active,
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => l_role_relate_id,
               X_CHILD_ROLE_RELATE_ID =>child_mem_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;


             END IF;  -- end of dup check
             CLOSE dup_cur2;


                 --for manager the opposite record has to be inserted
                 IF child_mem_rec.manager_flag = 'Y'
                   and mem_dtls_rec.manager_flag = 'Y'
                 THEN
                 --insert for group_id = parent_group_id
                 --call to table handler
                    OPEN dup_cur2(mem_dtls_rec.role_relate_id,
	                 child_mem_rec.role_relate_id,
                         mem_dtls_rec.group_id);
                    FETCH dup_cur2 INTO DUP;
                   IF (dup_cur2%notfound)
                   THEN

                      OPEN rep_mgr_seq_cur;
                      FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                      CLOSE rep_mgr_seq_cur;

                      jtf_rs_rep_managers_pkg.insert_row(
                                   X_ROWID => x_row_id,
                                   X_DENORM_MGR_ID  => l_denorm_mgr_id,
                                   X_RESOURCE_ID    =>child_mem_rec.resource_id,
                                   X_PERSON_ID => child_mem_rec.person_id,
                                   X_CATEGORY  => child_mem_rec.category,
                                   X_MANAGER_PERSON_ID => mem_dtls_rec.person_id,
				   X_PARENT_RESOURCE_ID => mem_dtls_rec.resource_id,
                                   X_GROUP_ID  => mem_dtls_rec.group_id,
                                   X_REPORTS_TO_FLAG   => l_reports_to_flag,
                                   X_HIERARCHY_TYPE =>   l_hierarchy_type,
                                   X_START_DATE_ACTIVE    => l_start_date_active,
                                   X_END_DATE_ACTIVE => l_end_date_active,
                                   X_ATTRIBUTE2 => null,
                                   X_ATTRIBUTE3 => null,
                                   X_ATTRIBUTE4 => null,
                                   X_ATTRIBUTE5 => null,
                                   X_ATTRIBUTE6 => null,
                                   X_ATTRIBUTE7 => null,
                                   X_ATTRIBUTE8 => null,
                                   X_ATTRIBUTE9 => null,
                                   X_ATTRIBUTE10  => null,
                                   X_ATTRIBUTE11  => null,
                                   X_ATTRIBUTE12  => null,
                                   X_ATTRIBUTE13  => null,
                                   X_ATTRIBUTE14  => null,
                                   X_ATTRIBUTE15  => null,
                                   X_ATTRIBUTE_CATEGORY   => null,
                                   X_ATTRIBUTE1       => null,
                                   X_CREATION_DATE     => l_date,
                                   X_CREATED_BY         => l_user_id,
                                   X_LAST_UPDATE_DATE   => l_date,
                                   X_LAST_UPDATED_BY    => l_user_id,
                                   X_LAST_UPDATE_LOGIN  => l_login_id,
                                   X_PAR_ROLE_RELATE_ID => l_role_relate_id,
                                   X_CHILD_ROLE_RELATE_ID =>child_mem_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

                   END IF; --end of dup check
                   CLOSE dup_cur2;

                 END IF;

                 FETCH child_mem_cur INTO child_mem_rec;
              END LOOP;
              CLOSE child_mem_cur;

          FETCH child_grp_cur INTO child_grp_rec;
        END LOOP;
        CLOSE child_grp_cur;
     END IF; --end of child group members insert


  END IF;--end of member details found if statement


   CLOSE mem_dtls_cur;

  --
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END INSERT_REP_MANAGER_MIGR;






   --FOR UPDATE on jtf_rs_role_relations
   /*********************/
   --Bug8261683
   --Deletion logic changed from Row by row Delete to Bulk Delete(Single delete statement).
   --Commented corresponding Cursor denorm_cur and loop in the body for deletion.
   /*********************/
   PROCEDURE   UPDATE_REP_MANAGER(
            P_API_VERSION        IN  NUMBER,
             P_INIT_MSG_LIST     IN  VARCHAR2,
             P_COMMIT            IN  VARCHAR2,
             P_ROLE_RELATE_ID    IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
             X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
             X_MSG_COUNT         OUT NOCOPY NUMBER,
             X_MSG_DATA          OUT NOCOPY VARCHAR2    )
  IS
  /* CURSOR denorm_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
    SELECT distinct(den.denorm_mgr_id) denorm_mgr_id
      FROM  jtf_rs_rep_managers den
     WHERE par_role_relate_id = l_role_relate_id
        OR child_role_relate_id = l_role_relate_id;

  denorm_rec denorm_cur%rowtype;
*/
  l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE := p_role_relate_id;

  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_REP_MANAGER';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  L_RETURN_STATUS     VARCHAR2(100);
  L_MSG_COUNT         NUMBER;
  L_MSG_DATA          VARCHAR2(200);

  l_count number := 0;
  l_pass_commit varchar2(1) := fnd_api.g_false;
  BEGIN
   --Standard Start of API SAVEPOINT
	SAVEPOINT member_denormalize;

        x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  IF fnd_api.to_boolean (p_commit)
  THEN
     l_pass_commit := fnd_api.g_true;
  END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

--Bug8261683
/*     --get all the denorm id's for the role relate id and delete the rows from rep manager table
     OPEN denorm_cur(l_role_relate_id);
     FETCH denorm_cur INTO denorm_rec;
     WHILE(denorm_cur%FOUND)
     LOOP
         jtf_rs_rep_managers_pkg.delete_row(denorm_rec.denorm_mgr_id);


  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

         FETCH denorm_cur INTO denorm_rec;
     END LOOP; --end of denorm cur loop
*/
-- Single delete statement is added instead of Delete in loop.
     DELETE FROM jtf_rs_rep_managers
     WHERE par_role_relate_id   = p_role_relate_id
        OR child_role_relate_id = p_role_relate_id;

  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;
    --call the insert api for the role relate id
     JTF_RS_REP_MGR_DENORM_PVT.INSERT_REP_MANAGER(
                   P_API_VERSION     => 1.0,
                   P_INIT_MSG_LIST   => p_init_msg_list,
                   P_COMMIT          => l_pass_commit,
                   P_ROLE_RELATE_ID  => l_role_relate_id ,
                   X_RETURN_STATUS   => L_RETURN_STATUS,
                   X_MSG_COUNT       => L_MSG_COUNT,
                   X_MSG_DATA        => L_MSG_DATA);

  	IF ( l_return_status <> fnd_api.g_ret_sts_success )
        THEN
             x_return_status := l_return_status;
             raise fnd_api.g_exc_error ;
        END IF;

--
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END UPDATE_REP_MANAGER;


    -- FOR DELETE ON JTF_RS_ROLE_RELATE
   PROCEDURE   DELETE_MEMBERS(
    P_API_VERSION     IN  NUMBER,
             P_INIT_MSG_LIST   IN  VARCHAR2,
             P_COMMIT          IN  VARCHAR2,
             P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
             X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
             X_MSG_COUNT       OUT NOCOPY NUMBER,
             X_MSG_DATA        OUT NOCOPY VARCHAR2  )
  IS
   CURSOR denorm_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
    SELECT distinct(den.denorm_mgr_id) denorm_mgr_id
      FROM  jtf_rs_rep_managers den
     WHERE par_role_relate_id = l_role_relate_id
        OR child_role_relate_id = l_role_relate_id;

  denorm_rec denorm_cur%rowtype;

  l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE := p_role_relate_id;

  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_REP_MANAGER';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  L_RETURN_STATUS     VARCHAR2(100);
  L_MSG_COUNT         NUMBER;
  L_MSG_DATA          VARCHAR2(200);
l_pass_commit varchar2(1) := fnd_api.g_false;
l_commit number := 0;
l_count number := 0;
  BEGIN
   --Standard Start of API SAVEPOINT
	SAVEPOINT member_denormalize;

        x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  IF fnd_api.to_boolean (p_commit)
  THEN
     l_pass_commit := fnd_api.g_true;
END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

--
     --get all the denorm id's for the role relate id and delete the rows from rep manager table
   /*  OPEN denorm_cur(l_role_relate_id);
     FETCH denorm_cur INTO denorm_rec;
     WHILE(denorm_cur%FOUND)
     LOOP
         jtf_rs_rep_managers_pkg.delete_row(denorm_rec.denorm_mgr_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

         FETCH denorm_cur INTO denorm_rec;
     END LOOP; --end of denorm cur loop
*/

   delete jtf_rs_rep_managers where par_role_relate_id = p_role_relate_id;

  IF fnd_api.to_boolean (p_commit)
  THEN
       COMMIT WORK;
  END IF;

   delete jtf_rs_rep_managers where child_role_relate_id = p_role_relate_id;

  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END DELETE_MEMBERS;


  -- FOR DELETE ON JTF_RS_GROUPS_DENORM
   PROCEDURE   DELETE_GROUP_DENORM(
    P_API_VERSION     IN  NUMBER,
             P_INIT_MSG_LIST   IN  VARCHAR2,
             P_COMMIT          IN  VARCHAR2,
             P_DENORM_GRP_ID   IN  JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE,
             X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
             X_MSG_COUNT       OUT NOCOPY NUMBER,
             X_MSG_DATA        OUT NOCOPY VARCHAR2  )
  IS

  l_denorm_grp_id JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE := p_denorm_grp_id;

  CURSOR denorm_cur(l_denorm_group_id JTF_RS_GROUPS_DENORM.DENORM_GRP_ID%TYPE)
      IS
   SELECT parent_group_id ,
          group_id
     FROM jtf_rs_groups_denorm
    WHERE denorm_grp_id  = l_denorm_group_id;

 denorm_rec denorm_cur%rowtype;

  CURSOR par_role_relate_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
      IS
  SELECT role_relate_id
   FROM  JTF_RS_ROLE_RELATIONS rlt,
         jtf_rs_group_members mem
   WHERE mem.group_id  = l_group_id
     AND mem.group_member_id = rlt.role_resource_id
     AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y';

 par_role_relate_rec    par_role_relate_cur%rowtype;

  CURSOR child_role_relate_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
      IS
  SELECT role_relate_id
   FROM  JTF_RS_ROLE_RELATIONS rlt,
         jtf_rs_group_members mem
   WHERE mem.group_id  = l_group_id
     AND mem.group_member_id = rlt.role_resource_id
     AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  nvl(rlt.delete_flag,'N')      <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y';

 child_role_relate_rec    child_role_relate_cur%rowtype;


  CURSOR rep_denorm_cur(l_par_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                        l_child_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
  SELECT denorm_mgr_id
    FROM jtf_rs_rep_managers
   WHERE par_role_relate_id = l_par_role_relate_id
     AND child_role_relate_id = l_child_role_relate_id;

  rep_denorm_rec  rep_denorm_cur%rowtype;

  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_GROUP_DENORM';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  L_RETURN_STATUS     VARCHAR2(100);
  L_MSG_COUNT         NUMBER;
  L_MSG_DATA          VARCHAR2(200);

  l_commit number := 0;
  l_count number := 0;
  l_pass_commit varchar2(1) := fnd_api.g_false;
  BEGIN
   --Standard Start of API SAVEPOINT
    SAVEPOINT member_denormalize;

    x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
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

  IF fnd_api.to_boolean (p_commit)
  THEN
       l_pass_commit := fnd_api.g_true;
  END IF;

--
     --get all the denorm id's for the role relate id and delete the rows from rep manager table
     OPEN denorm_cur(l_denorm_grp_id);
     FETCH denorm_cur INTO denorm_rec;
     IF (denorm_cur%FOUND)
     THEN
         --added this to delete the denorm record before recreating it again
         jtf_rs_groups_denorm_pkg.delete_row(l_denorm_grp_id);
        --get all the role relate ids for the parent group
         OPEN par_role_relate_cur(denorm_rec.parent_group_id);
         FETCH par_role_relate_cur INTO par_role_relate_rec;
         WHILE(par_role_relate_cur%FOUND)
         LOOP

           --get all the role relate ids for the child group
            OPEN child_role_relate_cur(denorm_rec.group_id);
            FETCH child_role_relate_cur INTO child_role_relate_rec;
            WHILE(child_role_relate_cur%FOUND)
            LOOP
               delete jtf_rs_rep_managers
                where par_role_relate_id = par_role_relate_rec.role_relate_id
                  and   child_role_relate_id = child_role_relate_rec.role_relate_id;


               IF fnd_api.to_boolean (p_commit)
               THEN
                 l_count := l_count + 1;
                 if (l_count > 1000)
                 then
                    COMMIT WORK;
                    l_count := 0;
                 end if;
               END IF;

                --recreate the rep manager records for the child role relate id

               JTF_RS_REP_MGR_DENORM_PVT.INSERT_REP_MANAGER(
                   P_API_VERSION    => 1.0,
                   P_INIT_MSG_LIST   => p_init_msg_list,
                   P_COMMIT        => l_pass_commit,
                   P_ROLE_RELATE_ID  => child_role_relate_rec.role_relate_id,
                   X_RETURN_STATUS  => l_return_status,
                   X_MSG_COUNT     => l_msg_count,
                   X_MSG_DATA       => l_msg_data);
               FETCH child_role_relate_cur INTO child_role_relate_rec;
             END LOOP;
             CLOSE child_role_relate_cur;

              --recreate the rep manager records for the parent role relate id

                 JTF_RS_REP_MGR_DENORM_PVT.INSERT_REP_MANAGER(
                   P_API_VERSION    => 1.0,
                   P_INIT_MSG_LIST   => p_init_msg_list,
                   P_COMMIT        => l_pass_commit,
                   P_ROLE_RELATE_ID  => par_role_relate_rec.role_relate_id,
                   X_RETURN_STATUS  => l_return_status,
                   X_MSG_COUNT     => l_msg_count,
                   X_MSG_DATA       => l_msg_data);

             FETCH par_role_relate_cur INTO par_role_relate_rec;
         END LOOP; -- end of par_role_relate_cur
         close par_role_relate_cur;


     END IF; --end of denorm cur loop
     close denorm_cur;
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END DELETE_GROUP_DENORM;

 PROCEDURE  INSERT_REP_MGR_PARENT(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2,
                   P_COMMIT          IN     VARCHAR2,
                   P_ROLE_RELATE_ID  IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 )
  IS
  CURSOR rep_mgr_seq_cur
      IS
   SELECT jtf_rs_rep_managers_s.nextval
     FROM dual;


   CURSOR  mem_dtls_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
       IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  rlt.role_relate_id = l_role_relate_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_resource_id   = mem.group_member_id
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id        = rsc.resource_id;


  mem_dtls_rec   mem_dtls_cur%rowtype;


  --cursor for duplicate check
  CURSOR dup_cur(l_person_id            JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_manager_person_id    JTF_RS_GROUP_MEMBERS.PERSON_ID%TYPE,
	       l_group_id	      JTF_RS_GROUPS_B.GROUP_ID%TYPE,
	       l_resource_id	      JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
               l_start_date_active    DATE,
               l_end_date_active      DATE)
         IS
          SELECT  person_id
            FROM  jtf_rs_rep_managers
            WHERE group_id = l_group_id
	      AND ( person_id = l_person_id
                        OR (l_person_id IS NULL AND person_id IS NULL))
              AND manager_person_id = l_manager_person_id
	      AND resource_id = l_resource_id
              AND start_date_active = l_start_date_active
              AND (end_date_active   = l_end_date_active
                 OR ( end_date_active IS NULL AND l_end_date_active IS NULL));

  CURSOR dup_cur2(l_par_role_relate_id         JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_child_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_group_id                   JTF_RS_GROUPS_B.GROUP_ID%TYPE)
     IS
     SELECT person_id
     FROM jtf_rs_rep_managers
    WHERE par_role_relate_id = l_par_role_relate_id
     AND  child_role_relate_id = l_child_role_relate_id
     AND  group_id   = l_group_id;



  dup     NUMBER := 0;

   --cursor for parent groups
  CURSOR  par_grp_cur(l_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
      IS
  SELECT  parent_group_id,
          immediate_parent_flag
    FROM  jtf_rs_groups_denorm
   WHERE  group_id = l_group_id
     AND  parent_group_id <> l_group_id
     AND  ((l_start_date_active between start_date_active
                                and nvl(end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, start_date_active +1)
                      between start_date_active  and
                           nvl(end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and end_date_active is null)));

  par_grp_rec   par_grp_cur%ROWTYPE;


  --cursor to fetch admin for a group
  CURSOR admin_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_id            = rol.role_id
     AND  rol.admin_flag   = 'Y'
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));

  admin_rec admin_cur%rowtype;

--cursor to fetch managers for a group
   CURSOR mgr_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                      l_start_date_active  DATE,
                      l_end_date_active    DATE)
     IS
  SELECT  /*+ ordered use_nl(MEM,RLT,ROL) */
	  mem.resource_id,
          mem.person_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.role_relate_id
    FROM  jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_b rol
   WHERE  mem.group_id      = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  rol.manager_flag   = 'Y'
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));


  mgr_rec mgr_cur%rowtype;



  l_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE := p_role_relate_id;
  l_hierarchy_type JTF_RS_REP_MANAGERS.HIERARCHY_TYPE%TYPE;
  l_reports_to_flag  JTF_RS_REP_MANAGERS.REPORTS_TO_FLAG%TYPE;
  l_denorm_mgr_id	JTF_RS_REP_MANAGERS.DENORM_MGR_ID%TYPE;
  x_row_id              VARCHAR2(100);

  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REP_MGR_PARENT';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  l_start_date_active DATE;
  l_end_date_active  DATE;
l_commit number := 0;
l_count number := 0;
  BEGIN
   --Standard Start of API SAVEPOINT
     SAVEPOINT member_denormalize;

    x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
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

    -- if no group id or person id is passed in then return
   IF p_role_relate_id IS NULL
   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name ('JTF', 'JTF_RS_GROUP_RESOURCE_NULL');
     FND_MSG_PUB.add;
     RAISE fnd_api.g_exc_error;
   END IF;


   --fetch the member details
   OPEN mem_dtls_cur(l_role_relate_id);
   FETCH mem_dtls_cur INTO mem_dtls_rec;
   IF((mem_dtls_cur%FOUND)
      AND
      (nvl(mem_dtls_rec.manager_flag, 'N') = 'Y' OR
       nvl(mem_dtls_rec.admin_flag, 'N') = 'Y' OR
       nvl(mem_dtls_rec.member_flag, 'N') = 'Y' ))
   THEN

   --fetch all the parent groups for the group
    OPEN par_grp_cur(mem_dtls_rec.group_id,
                     mem_dtls_rec.start_date_active,
                     mem_dtls_rec.end_date_active);

    FETCH par_grp_cur INTO par_grp_rec;
    WHILE (par_grp_cur%FOUND)
    LOOP

       IF((par_grp_rec.immediate_parent_flag = 'Y')
           AND (nvl(mem_dtls_rec.manager_flag,'N')='Y' ))
       THEN
         l_reports_to_flag := 'Y';
       ELSE
         l_reports_to_flag := 'N';
       END IF;
       --fetch all managers
       OPEN mgr_cur(par_grp_rec.parent_group_id,
                    mem_dtls_rec.start_date_active,
                    mem_dtls_rec.end_date_active);
       FETCH mgr_cur INTO mgr_rec;
       WHILE (mgr_cur%FOUND)
       LOOP

           IF mem_dtls_rec.manager_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_MGR';
           ELSIF mem_dtls_rec.admin_flag = 'Y'
           THEN
             l_hierarchy_type := 'MGR_TO_ADMIN';
           ELSE
             l_hierarchy_type := 'MGR_TO_REP';
           END IF;



             --assign start date and end date for which this relation is valid
           IF(mem_dtls_rec.start_date_active < mgr_rec.start_date_active)
           THEN
                    l_start_date_active := mgr_rec.start_date_active;
           ELSE
                     l_start_date_active := mem_dtls_rec.start_date_active;
           END IF;

           IF(mem_dtls_rec.end_date_active > mgr_rec.end_date_active)
           THEN
                    l_end_date_active := mgr_rec.end_date_active;
           ELSIF(mgr_rec.end_date_active IS NULL)
           THEN
                    l_end_date_active := mem_dtls_rec.end_date_active;
           ELSIF(mem_dtls_rec.end_date_active IS NULL)
           THEN
                    l_end_date_active := mgr_rec.end_date_active;
           END IF;

           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then
             --call table handler
           OPEN dup_cur2(mgr_rec.role_relate_id,
  	               mem_dtls_rec.role_relate_id,
                       mem_dtls_rec.group_id);

            FETCH dup_cur2 INTO DUP;
            IF (dup_cur2%notfound)
            THEN
             --INSERT INTO TABLE
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

            jtf_rs_rep_managers_pkg.insert_row(
                 X_ROWID => x_row_id,
                 X_DENORM_MGR_ID  => l_denorm_mgr_id,
                 X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                 X_PERSON_ID => mem_dtls_rec.person_id,
                 X_CATEGORY  => mem_dtls_rec.category,
                 X_MANAGER_PERSON_ID => mgr_rec.person_id,
		 X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                 X_GROUP_ID  => mem_dtls_rec.group_id,
                 X_HIERARCHY_TYPE =>   l_hierarchy_type,
                 X_REPORTS_TO_FLAG   => l_reports_to_flag,
                 X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                 X_END_DATE_ACTIVE => trunc(l_end_date_active),
                 X_ATTRIBUTE2 => null,
                 X_ATTRIBUTE3 => null,
                 X_ATTRIBUTE4 => null,
                 X_ATTRIBUTE5 => null,
                 X_ATTRIBUTE6 => null,
                 X_ATTRIBUTE7 => null,
                 X_ATTRIBUTE8 => null,
                 X_ATTRIBUTE9 => null,
                 X_ATTRIBUTE10  => null,
                 X_ATTRIBUTE11  => null,
                 X_ATTRIBUTE12  => null,
                 X_ATTRIBUTE13  => null,
                 X_ATTRIBUTE14  => null,
                 X_ATTRIBUTE15  => null,
                 X_ATTRIBUTE_CATEGORY   => null,
                 X_ATTRIBUTE1       => null,
                 X_CREATION_DATE     => l_date,
                 X_CREATED_BY         => l_user_id,
                 X_LAST_UPDATE_DATE   => l_date,
                 X_LAST_UPDATED_BY    => l_user_id,
                 X_LAST_UPDATE_LOGIN  => l_login_id,
                 X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                 X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id);

                IF fnd_api.to_boolean (p_commit)
                THEN
                  l_count := l_count + 1;
                  if (l_count > 1000)
                  then
                     COMMIT WORK;
                     l_count := 0;
                  end if;
                END IF;

           END IF; -- END OF DUP CHECK
           CLOSE dup_cur2;
          end if; --end of st dt check


          --for manager the oppsite record has to be inserted
            IF mem_dtls_rec.manager_flag = 'Y'
            THEN
           --insert for group_id = parent_group_id
           --call to table handler
           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then
             OPEN dup_cur2(mgr_rec.role_relate_id,
	                 mem_dtls_rec.role_relate_id,
                         par_grp_rec.parent_group_id);

             FETCH dup_cur2 INTO DUP;
             IF (dup_cur2%notfound)
             THEN
             --INSERT INTO TABLE
               OPEN rep_mgr_seq_cur;
               FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
               CLOSE rep_mgr_seq_cur;

              jtf_rs_rep_managers_pkg.insert_row(
                X_ROWID => x_row_id,
                X_DENORM_MGR_ID  => l_denorm_mgr_id,
                X_RESOURCE_ID    => mem_dtls_rec.resource_id,
                X_PERSON_ID => mem_dtls_rec.person_id,
                X_CATEGORY  => mem_dtls_rec.category,
                X_MANAGER_PERSON_ID => mgr_rec.person_id,
		X_PARENT_RESOURCE_ID => mgr_rec.resource_id,
                X_GROUP_ID  => par_grp_rec.parent_group_id,
                X_REPORTS_TO_FLAG   => l_reports_to_flag,
                X_HIERARCHY_TYPE =>   l_hierarchy_type,
                X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                X_END_DATE_ACTIVE => trunc(l_end_date_active),
                X_ATTRIBUTE2 => null,
                X_ATTRIBUTE3 => null,
                X_ATTRIBUTE4 => null,
                X_ATTRIBUTE5 => null,
                X_ATTRIBUTE6 => null,
                X_ATTRIBUTE7 => null,
                X_ATTRIBUTE8 => null,
                X_ATTRIBUTE9 => null,
                X_ATTRIBUTE10  => null,
                X_ATTRIBUTE11  => null,
                X_ATTRIBUTE12  => null,
                X_ATTRIBUTE13  => null,
                X_ATTRIBUTE14  => null,
                X_ATTRIBUTE15  => null,
                X_ATTRIBUTE_CATEGORY   => null,
                X_ATTRIBUTE1       => null,
                X_CREATION_DATE     => l_date,
                X_CREATED_BY         => l_user_id,
                X_LAST_UPDATE_DATE   => l_date,
                X_LAST_UPDATED_BY    => l_user_id,
                X_LAST_UPDATE_LOGIN  => l_login_id,
                X_PAR_ROLE_RELATE_ID => mgr_rec.role_relate_id,
                X_CHILD_ROLE_RELATE_ID =>mem_dtls_rec.role_relate_id);

                IF fnd_api.to_boolean (p_commit)
                THEN
                  l_count := l_count + 1;
                  if (l_count > 1000)
                  then
                     COMMIT WORK;
                     l_count := 0;
                  end if;
                END IF;

             end if;
             CLOSE dup_cur2;
            end if; -- end of st dt check
          END IF;
          FETCH mgr_cur INTO mgr_rec;
       END LOOP;
       CLOSE mgr_cur;


     FETCH par_grp_cur INTO par_grp_rec;
    END LOOP;
    CLOSE par_grp_cur;


   END IF;--end of member details found if statement


   CLOSE mem_dtls_cur;

  --
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END INSERT_REP_MGR_PARENT;


   PROCEDURE   INSERT_GRP_DENORM(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2,
                   P_COMMIT          IN     VARCHAR2,
                   P_GROUP_DENORM_ID       IN     NUMBER,
                   P_GROUP_ID              IN     NUMBER,
                   P_PARENT_GROUP_ID       IN     NUMBER,
                   P_START_DATE_ACTIVE     IN     DATE,
                   P_END_DATE_ACTIVE       IN     DATE,
                   P_IMMEDIATE_PARENT_FLAG IN     VARCHAR2,
                   P_DENORM_LEVEL          IN   NUMBER,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GRP_DENORM';
  l_api_version CONSTANT NUMBER  :=1.0;
  l_date  Date;
  l_fnd_date  Date := to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR');
  l_user_id  Number;
  l_login_id  Number;
  j BINARY_INTEGER := 0;
  k BINARY_INTEGER := 0;


   TYPE  process_table_rec IS RECORD(resource_id          NUMBER,
                                   person_id            NUMBER,
                                   category             VARCHAR2(30),
                                   manager_person_id    NUMBER,
                                   group_id             NUMBER,
                                   hierarchy_type       VARCHAR2(240),
                                   reports_to_flag      VARCHAR2(1),
                                   start_date_active    DATE,
                                   end_date_active      DATE,
                                   par_role_relate_id   NUMBER,
                                   child_role_relate_id NUMBER,
                                   parent_resource_id   NUMBER);

  TYPE  process_table_tbl IS TABLE OF process_table_rec
  INDEX BY BINARY_INTEGER;

  l_process_table process_table_tbl;

  TYPE same_group_member_role_rec IS RECORD(resource_id NUMBER,
                                            person_id NUMBER,
                                            group_id NUMBER,
                                            role_id NUMBER,
                                            start_date_active DATE,
                                            end_date_active DATE,
                                            role_type VARCHAR2(10),
                                            category VARCHAR2(30),
                                            role_relate_id NUMBER);

  TYPE  same_group_member_role_tbl IS TABLE OF same_group_member_role_rec
  INDEX BY BINARY_INTEGER;

  l_same_group_member_role same_group_member_role_tbl;
  l_diff_grp_parent_mbr_role same_group_member_role_tbl;
  l_diff_grp_child_mbr_role same_group_member_role_tbl;


  CURSOR grp_member_role(p_group_id IN NUMBER) IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          DECODE('Y',nvl(rol.manager_flag,'N'),'MGR',nvl(rol.admin_flag,'N'),'ADMIN',
          nvl(rol.member_flag,'N'),'REP','OTHER') ROLE_TYPE,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id = p_group_id
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_resource_id   = mem.group_member_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  rlt.role_id            = rol.role_id
     AND  (nvl(rol.manager_flag, 'N') = 'Y'
           OR
           nvl(rol.admin_flag, 'N' ) = 'Y'
           OR
           nvl(rol.member_flag, 'N') = 'Y')
     AND  mem.resource_id        = rsc.resource_id;

  CURSOR grp_member_mgr_role(p_group_id IN NUMBER) IS
   SELECT mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          DECODE('Y',nvl(rol.manager_flag,'N'),'MGR',nvl(rol.admin_flag,'N'),'ADMIN',
          nvl(rol.member_flag,'N'),'REP','OTHER') ROLE_TYPE,
          rsc.category,
          rlt.role_relate_id
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members  mem,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_resource_id   = mem.group_member_id
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  mem.resource_id        = rsc.resource_id
     AND  mem.group_id = p_group_id
     AND  nvl(rol.manager_flag,'N') = 'Y';

  PROCEDURE load_processed_table IS
    k NUMBER := 0;
    l_denorm_manager_id number;
    skip_row exception ;
    l_start_date_active date;
    l_end_date_active date;
    l_count number := 0;
  BEGIN
    IF l_process_table.COUNT > 0 THEN
      k := l_process_table.FIRST;
      LOOP
        BEGIN
    l_start_date_active := to_date(to_char(l_process_table(k).START_DATE_ACTIVE,'DD-MM-RRRR'),'DD-MM-RRRR');
    l_end_date_active := to_date(to_char(nvl(l_process_table(k).END_DATE_ACTIVE,FND_API.G_MISS_DATE),
                                         'DD-MM-RRRR'),'DD-MM-RRRR');
          IF l_start_date_active  > l_end_date_active THEN
            RAISE skip_row;
          END IF;

          SELECT jtf_rs_rep_managers_s.nextval
            INTO l_denorm_manager_id
            FROM dual;

        /*    to_char(l_process_table(k).PERSON_ID)||'..'||
            l_process_table(k).CATEGORY||'..'||
            to_char(l_process_table(k).MANAGER_PERSON_ID)||'..'||
            to_char(l_process_table(k).GROUP_ID)||'..'||
            l_process_table(k).HIERARCHY_TYPE||'..'||
            l_process_table(k).REPORTS_TO_FLAG||'..'||
            to_char(l_process_table(k).START_DATE_ACTIVE, 'dd-MM-yyyy')||'..'||
            to_char(l_process_table(k).END_DATE_ACTIVE, 'dd-MM-yyyy')||'..'||
            to_char(l_process_table(k).PAR_ROLE_RELATE_ID)||'..'||
            to_char(l_process_table(k).CHILD_ROLE_RELATE_ID)||'..'||
            to_char(l_process_table(k).PARENT_RESOURCE_ID));

          */
          INSERT INTO JTF_RS_REP_MANAGERS
           ( DENORM_MGR_ID,
            RESOURCE_ID,
            PERSON_ID,
            CATEGORY,
            MANAGER_PERSON_ID,
            GROUP_ID,
            HIERARCHY_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REPORTS_TO_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            OBJECT_VERSION_NUMBER,
            PAR_ROLE_RELATE_ID,
            CHILD_ROLE_RELATE_ID,
            PARENT_RESOURCE_ID,
            DENORM_LEVEL)
          VALUES
            (L_DENORM_MANAGER_ID,
            l_process_table(k).RESOURCE_ID,
            l_process_table(k).PERSON_ID,
            l_process_table(k).CATEGORY,
            l_process_table(k).MANAGER_PERSON_ID,
            l_process_table(k).GROUP_ID,
            l_process_table(k).HIERARCHY_TYPE,
            l_user_id,
            l_date,
            l_user_id,
            l_date,
            l_login_id,
            l_process_table(k).REPORTS_TO_FLAG,
            trunc(l_process_table(k).START_DATE_ACTIVE),
            trunc(l_process_table(k).END_DATE_ACTIVE),
            1,
            l_process_table(k).PAR_ROLE_RELATE_ID,
            l_process_table(k).CHILD_ROLE_RELATE_ID,
            l_process_table(k).PARENT_RESOURCE_ID,
            p_denorm_level);


           IF fnd_api.to_boolean (p_commit)
           THEN
               l_count := l_count + 1;
               if (l_count > 1000)
               then
                  COMMIT WORK;
                  l_count := 0;
               end if;
            END IF;


         EXCEPTION when skip_row then null;
         END;
         EXIT WHEN k = l_process_table.LAST ;
         k := l_process_table.NEXT(k);

      END LOOP;
--        dbms_output.put_line (l_process_table.COUNT);
    END IF;
    NULL;
  END;


  PROCEDURE process_diff_group_member_role(p_immediate_parent_flag IN VARCHAR2,
                                           p_start_date_active IN DATE,
                                           p_end_date_active IN DATE) IS
    i number := 0;
    j number := 0;
    k number := 0;
    l_start_date_active  date;
    l_end_date_active  date;
    l_temp_fnd_end_date date;
    l_hierarchy_type   varchar2(30);
    l_reports_to_flag   varchar2(1);
  BEGIN
    IF l_process_table.COUNT > 0 THEN
      l_process_table.DELETE;
    END IF;
    IF  l_diff_grp_parent_mbr_role.COUNT > 0 THEN
      i := l_diff_grp_parent_mbr_role.FIRST;
      LOOP
        IF l_diff_grp_child_mbr_role.COUNT > 0 THEN
          j := l_diff_grp_child_mbr_role.FIRST;
          LOOP
            k := k+1;
            l_hierarchy_type := l_diff_grp_parent_mbr_role(i).ROLE_TYPE||'_TO_'||l_diff_grp_child_mbr_role(j).ROLE_TYPE;

            l_start_date_active := greatest(l_diff_grp_parent_mbr_role(i).start_date_active,
                                            l_diff_grp_child_mbr_role(j).start_date_active);
            l_start_date_active := greatest(l_start_date_active,p_start_date_active);
            l_temp_fnd_end_date := to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR');
            l_end_date_active   := least(nvl(l_diff_grp_parent_mbr_role(i).end_date_active,l_temp_fnd_end_date),
                                            nvl(l_diff_grp_child_mbr_role(j).end_date_active,l_temp_fnd_end_date));
            l_end_date_active   := least(l_end_date_active,nvl(p_end_date_active,l_temp_fnd_end_date));

            IF l_end_date_active = l_temp_fnd_end_date THEN
              l_end_date_active := NULL;
            END IF;

            IF l_hierarchy_type = 'MGR_TO_MGR'  AND p_immediate_parent_flag = 'Y' THEN
              l_reports_to_flag := 'Y';
            ELSE
              l_reports_to_flag := 'N';
            END IF;

            l_process_table(k).resource_id := l_diff_grp_child_mbr_role(j).resource_id;
            l_process_table(k).person_id := l_diff_grp_child_mbr_role(j).person_id;
            l_process_table(k).category := l_diff_grp_child_mbr_role(j).category;
            l_process_table(k).manager_person_id := l_diff_grp_parent_mbr_role(i).person_id;
            l_process_table(k).group_id := l_diff_grp_child_mbr_role(j).group_id;
            l_process_table(k).hierarchy_type := l_hierarchy_type;
            l_process_table(k).reports_to_flag := l_reports_to_flag;
            l_process_table(k).start_date_active := l_start_date_active;
            l_process_table(k).end_date_active := l_end_date_active;
            l_process_table(k).par_role_relate_id := l_diff_grp_parent_mbr_role(i).role_relate_id;
            l_process_table(k).child_role_relate_id := l_diff_grp_child_mbr_role(j).role_relate_id;
            l_process_table(k).parent_resource_id := l_diff_grp_parent_mbr_role(i).resource_id;

            IF l_hierarchy_type = 'MGR_TO_MGR'  THEN  -- have a reverse record with parent group's Id.
              k := k+1;
              l_process_table(k).resource_id := l_diff_grp_child_mbr_role(j).resource_id;
              l_process_table(k).person_id := l_diff_grp_child_mbr_role(j).person_id;
              l_process_table(k).category := l_diff_grp_child_mbr_role(j).category;
              l_process_table(k).manager_person_id := l_diff_grp_parent_mbr_role(i).person_id;
              l_process_table(k).group_id := l_diff_grp_parent_mbr_role(i).group_id;
              l_process_table(k).hierarchy_type := l_hierarchy_type;
              l_process_table(k).reports_to_flag := l_reports_to_flag;
              l_process_table(k).start_date_active := l_start_date_active;
              l_process_table(k).end_date_active := l_end_date_active;
              l_process_table(k).par_role_relate_id := l_diff_grp_parent_mbr_role(i).role_relate_id;
              l_process_table(k).child_role_relate_id := l_diff_grp_child_mbr_role(j).role_relate_id;
              l_process_table(k).parent_resource_id := l_diff_grp_parent_mbr_role(i).resource_id;
            END IF;

            EXIT WHEN j = l_diff_grp_child_mbr_role.LAST;
            j := l_diff_grp_child_mbr_role.NEXT(j);
          END LOOP;
        END IF;
        EXIT WHEN i = l_diff_grp_parent_mbr_role.LAST;
        i := l_diff_grp_parent_mbr_role.NEXT(i);
      END LOOP;
    END IF;

    load_processed_table;
  END;


  BEGIN
      SAVEPOINT member_denormalize;
     --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    x_return_status := fnd_api.g_ret_sts_success;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;


   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   IF(p_group_id <> p_parent_group_id)
   THEN
--dbms_output.put_line('xxx'||to_char(p_group_id));
      IF l_diff_grp_parent_mbr_role.COUNT > 0 THEN
        l_diff_grp_parent_mbr_role.DELETE;
      END IF;
      IF l_diff_grp_child_mbr_role.COUNT > 0 THEN
        l_diff_grp_child_mbr_role.DELETE;
      END IF;
      FOR l_grp_member_role IN grp_member_role(p_group_id) LOOP
        j := j+1;
        l_diff_grp_child_mbr_role(j).resource_id := l_grp_member_role.resource_id;
        l_diff_grp_child_mbr_role(j).person_id := l_grp_member_role.person_id;
        l_diff_grp_child_mbr_role(j).group_id := l_grp_member_role.group_id;
        l_diff_grp_child_mbr_role(j).role_id := l_grp_member_role.role_id;
        l_diff_grp_child_mbr_role(j).start_date_active := l_grp_member_role.start_date_active;
        l_diff_grp_child_mbr_role(j).end_date_active := l_grp_member_role.end_date_active;
        l_diff_grp_child_mbr_role(j).role_type := l_grp_member_role.role_type;
        l_diff_grp_child_mbr_role(j).category := l_grp_member_role.category;
        l_diff_grp_child_mbr_role(j).role_relate_id := l_grp_member_role.role_relate_id;
      END LOOP;

     FOR l_grp_member_mgr_role IN grp_member_mgr_role(p_parent_group_id) LOOP
        k := k+1;
        l_diff_grp_parent_mbr_role(k).resource_id := l_grp_member_mgr_role.resource_id;
        l_diff_grp_parent_mbr_role(k).person_id := l_grp_member_mgr_role.person_id;
        l_diff_grp_parent_mbr_role(k).group_id := l_grp_member_mgr_role.group_id;
        l_diff_grp_parent_mbr_role(k).role_id := l_grp_member_mgr_role.role_id;
        l_diff_grp_parent_mbr_role(k).start_date_active := l_grp_member_mgr_role.start_date_active;
        l_diff_grp_parent_mbr_role(k).end_date_active := l_grp_member_mgr_role.end_date_active;
        l_diff_grp_parent_mbr_role(k).role_type := l_grp_member_mgr_role.role_type;
        l_diff_grp_parent_mbr_role(k).category := l_grp_member_mgr_role.category;
        l_diff_grp_parent_mbr_role(k).role_relate_id := l_grp_member_mgr_role.role_relate_id;
      END LOOP;

      process_diff_group_member_role(p_immediate_parent_flag,
                                     p_start_date_active,
                                     p_end_date_active);


   END IF; --end of p_group_id = p_parent_group_id check

  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END INSERT_GRP_DENORM;


   PROCEDURE  DELETE_REP_MGR  (
              P_API_VERSION     IN  NUMBER,
              P_INIT_MSG_LIST   IN  VARCHAR2,
              P_COMMIT          IN  VARCHAR2,
              P_GROUP_ID        IN  JTF_RS_GROUPS_DENORM.GROUP_ID%TYPE,
              P_PARENT_GROUP_ID IN  JTF_RS_GROUPS_DENORM.PARENT_GROUP_ID%TYPE,
              X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
              X_MSG_COUNT       OUT NOCOPY NUMBER,
              X_MSG_DATA        OUT NOCOPY VARCHAR2)
      IS
      CURSOR c_child_role_relate_cur(l_group_id IN NUMBER) IS
      SELECT rlt.role_relate_id
      FROM   jtf_rs_role_relations rlt,
             jtf_rs_group_members  mem
      WHERE  rlt.role_resource_type = 'RS_GROUP_MEMBER'
        AND  rlt.role_resource_id   = mem.group_member_id
        AND  nvl(rlt.delete_flag,'N')       <> 'Y'
        AND  nvl(mem.delete_flag,'N')      <> 'Y'
        AND  mem.group_id = l_group_id;

        r_child_role_relate_rec   c_child_role_relate_cur%rowtype;

      CURSOR c_parent_role_relate_cur(l_parent_group_id IN NUMBER) IS
      SELECT rlt.role_relate_id
      FROM   jtf_rs_role_relations rlt,
             jtf_rs_group_members  mem
      WHERE  rlt.role_resource_type = 'RS_GROUP_MEMBER'
        AND  rlt.role_resource_id   = mem.group_member_id
        AND  nvl(rlt.delete_flag,'N')       <> 'Y'
        AND  nvl(mem.delete_flag,'N')      <> 'Y'
        AND  mem.group_id = l_parent_group_id;

        r_parent_role_relate_rec  c_parent_role_relate_cur%rowtype;

      --Declare the variables
      --
      l_api_name CONSTANT VARCHAR2(30) := 'DELETE_REP_MGR';
      l_api_version       CONSTANT      NUMBER        :=1.0;
      l_date  Date;
      l_user_id  Number;
      l_login_id  Number;

      l_return_status      VARCHAR2(200);
      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2(200);

    BEGIN

      --Standard Start of API SAVEPOINT
      SAVEPOINT DEL_REP_MGR_SP;

      x_return_status := fnd_api.g_ret_sts_success;

      --Standard Call to check  API compatibility
      IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
      IF FND_API.To_boolean(P_INIT_MSG_LIST) THEN
        FND_MSG_PUB.Initialize;
      END IF;


     l_date     := sysdate;
     l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
     l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

     --get all the child role relate id for this group
     OPEN c_child_role_relate_cur(p_group_id);
     FETCH c_child_role_relate_cur INTO r_child_role_relate_rec;
     WHILE(c_child_role_relate_cur%found)
       LOOP

	 OPEN c_parent_role_relate_cur(p_parent_group_id);
	 FETCH c_parent_role_relate_cur INTO r_parent_role_relate_rec;
	 WHILE(c_parent_role_relate_cur%found)
	   LOOP
	     DELETE JTF_RS_REP_MANAGERS
	     WHERE  child_role_relate_id = r_child_role_relate_rec.role_relate_id
	       AND  par_role_relate_id   = r_parent_role_relate_rec.role_relate_id ;

	      FETCH c_parent_role_relate_cur INTO r_parent_role_relate_rec;
            END LOOP;
         CLOSE c_parent_role_relate_cur;
         FETCH c_child_role_relate_cur INTO r_child_role_relate_rec;
       END LOOP; --end of par_mgr_cur
     CLOSE c_child_role_relate_cur;

     IF fnd_api.to_boolean (p_commit) THEN
       COMMIT WORK;
     END IF;

     FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

     EXCEPTION
       WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO del_rep_mgr_sp;
         FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
       WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO del_rep_mgr_sp;
         FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
       WHEN OTHERS THEN
         ROLLBACK TO del_rep_mgr_sp;
         fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
         fnd_message.set_token('P_SQLCODE',SQLCODE);
         fnd_message.set_token('P_SQLERRM',SQLERRM);
         fnd_message.set_token('P_API_NAME',l_api_name);
         FND_MSG_PUB.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

       END DELETE_REP_MGR;


  /*FOR INSERT IN JTF_RS_GRP_RELATIONS */
  --not being used now as this id done from group denorm which calls INSERT_GRP_DENORM
  PROCEDURE   INSERT_GRP_RELATIONS(
                   P_API_VERSION     IN     NUMBER,
                   P_INIT_MSG_LIST   IN     VARCHAR2,
                   P_COMMIT          IN     VARCHAR2,
                   P_GROUP_RELATE_ID IN     JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
                   X_RETURN_STATUS   OUT NOCOPY    VARCHAR2,
                   X_MSG_COUNT       OUT NOCOPY    NUMBER,
                   X_MSG_DATA        OUT NOCOPY    VARCHAR2 )
  IS
  l_group_relate_id JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE := p_group_relate_id;
  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_GRP_RELATIONS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  l_hierarchy_type JTF_RS_REP_MANAGERS.HIERARCHY_TYPE%TYPE;
  l_reports_to_flag  JTF_RS_REP_MANAGERS.REPORTS_TO_FLAG%TYPE := 'N';
  x_row_id              VARCHAR2(100);
  l_start_date_active DATE;
  l_end_date_active  DATE;

 --cursor for the direct parent
  CURSOR rel_grp_cur(l_group_relate_id JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE)
      IS
  SELECT related_group_id,
         group_id,
         start_date_active,
         end_date_active
    FROM jtf_rs_grp_relations
   WHERE group_relate_id = l_group_relate_id
     and  delete_flag        <> 'Y';

 rel_grp_rec rel_grp_cur%rowtype;

  l_related_group_id JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE;

  CURSOR par_mgr_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                     l_start_date_active DATE,
                     l_end_date_active   DATE)
      IS
  SELECT  mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_relate_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.admin_flag  ,
          rol.manager_flag
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_B rol
   WHERE   mem.group_id IN ( select distinct(parent_group_id)
                            from jtf_rs_groups_denorm
                            where group_id = l_group_id)
    /* this has been added to include all parents in the hierarchy */
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  nvl(rlt.delete_flag, 'N')        <> 'Y'
     AND  (rol.admin_flag         = 'Y'
            OR manager_flag       = 'Y')
     AND ((l_start_date_active between rlt.start_date_active
                                and nvl(rlt.end_date_active , l_start_date_active +1))
          OR ((nvl(l_end_date_active, rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, l_end_date_active + 1))
                  or (l_end_date_active is null and rlt.end_date_active is null)));

  par_mgr_rec par_mgr_cur%rowtype;

  TYPE MGR_TYPE IS RECORD
  ( p_resource_id        JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
    p_person_id          JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
    p_group_id           JTF_RS_GROUPS_B.GROUP_ID%TYPE,
    p_role_relate_id     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
    p_role_id            JTF_RS_ROLES_B.ROLE_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE,
    p_admin_flag         JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
    p_manager_flag       JTF_RS_ROLES_B.MANAGER_FLAG%TYPE);


  TYPE mgr_tab_type IS TABLE OF mgr_type INDEX BY BINARY_INTEGER;
  l_mgr_rec     MGR_TAB_TYPE;
  query_str     VARCHAR2(20000);
  i BINARY_INTEGER := 0;


  CURSOR  child_grp_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
      IS
  SELECT group_id,
         start_date_active,
         end_date_active,
         immediate_parent_flag
   FROM  jtf_rs_groups_denorm
  WHERE  parent_group_id = l_group_id
  AND  group_id    NOT IN (l_group_id);

 child_grp_rec child_grp_cur%ROWTYPE;

 CURSOR member_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                    l_start_date_active DATE,
                    l_end_date_active DATE)
     IS
SELECT    mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_relate_id,
          rlt.role_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rol.member_flag ,
          rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  mem.resource_id        = rsc.resource_id
     AND  ((rlt.start_date_active  between l_start_date_active and
                                           nvl(l_end_date_active ,rlt.start_date_active+1))
        OR (rlt.end_date_active between  l_start_date_active
                                          and nvl(l_end_date_active,rlt.end_date_active+1))
        OR ((rlt.start_date_active <= l_start_date_active)
                          AND (rlt.end_date_active >= l_end_date_active
                                          OR l_end_date_active IS NULL)));

/* SELECT   mem.resource_id,
          mem.person_id,
          mem.group_id,
          rlt.role_relate_id,
          rlt.role_id,
          rlt.start_date_active,
         rlt.end_date_active,
          rol.member_flag ,
	  rol.admin_flag  ,
          rol.lead_flag   ,
          rol.manager_flag,
          rsc.category
   FROM   jtf_rs_group_members  mem,
          jtf_rs_role_relations rlt,
          jtf_rs_roles_B rol,
          jtf_rs_resource_extns rsc
   WHERE  mem.group_id = l_group_id
     AND  mem.group_member_id = rlt.role_resource_id
     AND  nvl(rlt.delete_flag,'N')       <> 'Y'
     AND  nvl(mem.delete_flag,'N')      <> 'Y'
     AND  rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rlt.role_id            = rol.role_id
     AND  mem.resource_id        = rsc.resource_id
     AND  rlt.start_date_active >= to_date(to_char(l_start_date_active,'dd-MM-yyyy'),'dd-MM-yyyy')
     AND ((to_date(to_char(l_start_date_active,'dd-MM-yyyy'),'dd-MM-yyyy') between rlt.start_date_active
                                and nvl(rlt.end_date_active , to_date(to_char(l_start_date_active,'dd-MM-yyyy'),'dd-MM-yyyy')+1))
          OR ((nvl(to_date(to_char(l_start_date_active,'dd-MM-yyyy'),'dd-MM-yyyy'), rlt.start_date_active +1)
                      between rlt.start_date_active  and
                           nvl(rlt.end_date_active, to_date(to_char(l_end_date_active,'dd-MM-yyyy'),'dd-MM-yyyy')+ 1))
                  or (to_date(to_char(l_end_date_active,'dd-MM-yyyy'),'dd-MM-yyyy') is null and rlt.end_date_active is null)));
*/



 member_rec member_cur%rowtype;

 CURSOR rep_mgr_seq_cur
      IS
   SELECT jtf_rs_rep_managers_s.nextval
     FROM dual;

--dupliacte check cursor to be added

   CURSOR dup_cur2(l_par_role_relate_id         JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_child_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
                  l_group_id                   JTF_RS_GROUPS_B.GROUP_ID%TYPE)
     IS
     SELECT person_id
     FROM jtf_rs_rep_managers
    WHERE par_role_relate_id = l_par_role_relate_id
     AND  child_role_relate_id = l_child_role_relate_id
     AND  group_id   = l_group_id;
/*
     AND  ((l_start_date_active  between start_date_active and
                                           nvl(end_date_active,l_start_date_active+1))
              OR (l_end_date_active between start_date_active
                                          and nvl(end_date_active,l_end_date_active+1))
              OR ((l_start_date_active <= start_date_active)
                          AND (l_end_date_active >= end_date_active
                                          OR l_end_date_active IS NULL)));

  */



  dup     NUMBER := 0;


  l_denorm_mgr_id JTF_RS_REP_MANAGERS.DENORM_MGR_ID%TYPE;
l_commit number := 0;

l_count number := 0;
  BEGIN
   --Standard Start of API SAVEPOINT
	SAVEPOINT member_denormalize;

        x_return_status := fnd_api.g_ret_sts_success;

 --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
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

--
   OPEN rel_grp_cur(l_group_relate_id);
   FETCH rel_grp_cur INTO rel_grp_rec;
   CLOSE rel_grp_cur;

  --pick up all the managers and admin for the parent group
    OPEN par_mgr_cur(rel_grp_rec.related_group_id,
                     rel_grp_rec.start_date_active,
                     rel_grp_rec.end_date_active);

    FETCH par_mgr_cur INTO par_mgr_rec;
    WHILE(par_mgr_cur%FOUND)
    LOOP
--dbms_output.put_line('h2');
       i := i + 1;
       l_mgr_rec(i).p_resource_id := par_mgr_rec.resource_id;
       l_mgr_rec(i).p_person_id   := par_mgr_rec.person_id;
       l_mgr_rec(i).p_group_id    := par_mgr_rec.group_id;
       l_mgr_rec(i).p_role_relate_id   := par_mgr_rec.role_relate_id;
       l_mgr_rec(i).p_role_id          := par_mgr_rec.role_id;
       l_mgr_rec(i).p_start_date_active := par_mgr_rec.start_date_active;
       l_mgr_rec(i).p_end_date_active    := par_mgr_rec.end_date_active;
       l_mgr_rec(i).p_admin_flag        := par_mgr_rec.admin_flag;
       l_mgr_rec(i).p_manager_flag      := par_mgr_rec.manager_flag;


       FETCH par_mgr_cur  INTO par_mgr_rec;

    END LOOP; --end of par_mgr_cur
    CLOSE par_mgr_cur;
  --insert records for the same group for this parent
  OPEN member_cur(rel_grp_rec.group_id,
                  rel_grp_rec.start_date_active,
                  rel_grp_rec.end_date_active);
  FETCH member_cur INTO member_rec;

  WHILE(member_cur%FOUND)
  LOOP

--dbms_output.put_line('h3');
         --insert records for all the members of the group
          i := 0;
         FOR I IN 1 .. l_mgr_rec.COUNT
         LOOP
           IF(rel_grp_rec.related_group_id = l_mgr_rec(i).p_group_id)
           THEN

              IF(nvl(member_rec.manager_flag,'N') = 'Y')
              THEN
                  l_reports_to_flag  := 'Y';
              ELSE
                  l_reports_to_flag  := 'N';
              END IF;
           ELSE
               l_reports_to_flag  := 'N';
           END IF;

         --assign start date and end date for which this relation is valid
           IF(member_rec.start_date_active < l_mgr_rec(i).p_start_date_active)
           THEN
              l_start_date_active := l_mgr_rec(i).p_start_date_active;
           ELSE
              l_start_date_active := member_rec.start_date_active;
           END IF;

           IF(member_rec.end_date_active > l_mgr_rec(i).p_end_date_active)
           THEN
               l_end_date_active := l_mgr_rec(i).p_end_date_active;
           ELSIF(l_mgr_rec(i).p_end_date_active IS NULL)
           THEN
               l_end_date_active :=member_rec.end_date_active;
           ELSIF(member_rec.end_date_active IS NULL)
           THEN
               l_end_date_active := l_mgr_rec(i).p_end_date_active;
           END IF;

         --set the hierarchy type if of type manager
          IF l_mgr_rec(i).p_manager_flag = 'Y'
          THEN
             IF member_rec.manager_flag = 'Y'
             THEN
                  l_hierarchy_type := 'MGR_TO_MGR';
             ELSIF member_rec.admin_flag = 'Y'
             THEN
                  l_hierarchy_type := 'MGR_TO_ADMIN';
             ELSE
                  l_hierarchy_type := 'MGR_TO_REP';
             END IF;

           if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then

              open dup_cur2(l_mgr_rec(i).P_role_relate_id ,
                          member_rec.role_relate_id,
                          member_rec.group_id);
               fetch dup_cur2 INTO dup;
               IF(dup_cur2%NOTFOUND)
               THEN
             --CALL TABLE HANDLER FOR INSETING IN REP MANAGER
--dbms_output.put_line('h4');
                  OPEN rep_mgr_seq_cur;
                  FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                  CLOSE rep_mgr_seq_cur;

                  jtf_rs_rep_managers_pkg.insert_row(
                  X_ROWID => x_row_id,
                  X_DENORM_MGR_ID  => l_denorm_mgr_id,
                  X_RESOURCE_ID    => member_rec.resource_id,
                  X_PERSON_ID => member_rec.person_id,
                  X_CATEGORY  => member_rec.category,
                  X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
                  X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
                  X_GROUP_ID  => member_rec.group_id,
                 X_REPORTS_TO_FLAG   => l_reports_to_flag,
                 X_HIERARCHY_TYPE =>   l_hierarchy_type,
                 X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                 X_END_DATE_ACTIVE => trunc(l_end_date_active),
                 X_ATTRIBUTE2 => null,
                 X_ATTRIBUTE3 => null,
                 X_ATTRIBUTE4 => null,
                 X_ATTRIBUTE5 => null,
                 X_ATTRIBUTE6 => null,
                 X_ATTRIBUTE7 => null,
                 X_ATTRIBUTE8 => null,
                 X_ATTRIBUTE9 => null,
                 X_ATTRIBUTE10  => null,
                 X_ATTRIBUTE11  => null,
                 X_ATTRIBUTE12  => null,
                 X_ATTRIBUTE13  => null,
                 X_ATTRIBUTE14  => null,
                 X_ATTRIBUTE15  => null,
                 X_ATTRIBUTE_CATEGORY   => null,
                 X_ATTRIBUTE1       => null,
                 X_CREATION_DATE     => l_date,
                 X_CREATED_BY         => l_user_id,
                 X_LAST_UPDATE_DATE   => l_date,
                 X_LAST_UPDATED_BY    => l_user_id,
                 X_LAST_UPDATE_LOGIN  => l_login_id,
                 X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).P_role_relate_id,
                 X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

                IF fnd_api.to_boolean (p_commit)
                THEN
                  l_count := l_count + 1;
                  if (l_count > 1000)
                  then
                     COMMIT WORK;
                     l_count := 0;
                  end if;
                END IF;


               --insert the reverse record if manager flag = 'Y'
               IF member_rec.manager_flag = 'Y'
               THEN
                   OPEN rep_mgr_seq_cur;
                   FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                   CLOSE rep_mgr_seq_cur;

                   jtf_rs_rep_managers_pkg.insert_row(
                         X_ROWID => x_row_id,
                         X_DENORM_MGR_ID  => l_denorm_mgr_id,
                         X_RESOURCE_ID    => member_rec.resource_id,
                         X_PERSON_ID => member_rec.person_id,
                         X_CATEGORY  => member_rec.category,
                         X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
			 X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
                         X_GROUP_ID  => l_mgr_rec(i).p_group_id,
                         X_REPORTS_TO_FLAG   => l_reports_to_flag,
                         X_HIERARCHY_TYPE =>   l_hierarchy_type,
                         X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                         X_END_DATE_ACTIVE => trunc(l_end_date_active),
                         X_ATTRIBUTE2 => null,
                         X_ATTRIBUTE3 => null,
                         X_ATTRIBUTE4 => null,
                         X_ATTRIBUTE5 => null,
                         X_ATTRIBUTE6 => null,
                         X_ATTRIBUTE7 => null,
                         X_ATTRIBUTE8 => null,
                         X_ATTRIBUTE9 => null,
                         X_ATTRIBUTE10  => null,
                         X_ATTRIBUTE11  => null,
                         X_ATTRIBUTE12  => null,
                         X_ATTRIBUTE13  => null,
                         X_ATTRIBUTE14  => null,
                         X_ATTRIBUTE15  => null,
                         X_ATTRIBUTE_CATEGORY   => null,
                         X_ATTRIBUTE1       => null,
                         X_CREATION_DATE     => l_date,
                         X_CREATED_BY         => l_user_id,
                         X_LAST_UPDATE_DATE   => l_date,
                         X_LAST_UPDATED_BY    => l_user_id,
                         X_LAST_UPDATE_LOGIN  => l_login_id,
                         X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).P_role_relate_id,
                         X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

                IF fnd_api.to_boolean (p_commit)
                THEN
                  l_count := l_count + 1;
                  if (l_count > 1000)
                  then
                     COMMIT WORK;
                     l_count := 0;
                  end if;
                END IF;


               END IF; --end of reverse record insert
             END IF; --end of duplicate check
             close dup_cur2;

            END IF; --end of st dt and end dt check
           END IF; --MANAGER FLAG END


           IF l_mgr_rec(i).p_admin_flag = 'Y'
           THEN
             IF member_rec.manager_flag = 'Y'
             THEN
                  l_hierarchy_type := 'ADMIN_TO_MGR';
             ELSIF member_rec.admin_flag = 'Y'
             THEN
                  l_hierarchy_type := 'ADMIN_TO_ADMIN';
             ELSE
                  l_hierarchy_type := 'ADMIN_TO_REP';
             END IF;

            if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
            then
                 open dup_cur2(l_mgr_rec(i).P_role_relate_id ,
                          member_rec.role_relate_id,
                          member_rec.group_id);
                 fetch dup_cur2 INTO dup;
                 IF(dup_cur2%NOTFOUND)
                  THEN
             --CALL TABLE HANDLER FOR INSERTING IN REP MANAGER
                    OPEN rep_mgr_seq_cur;
                    FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                    CLOSE rep_mgr_seq_cur;

                     jtf_rs_rep_managers_pkg.insert_row(
                     X_ROWID => x_row_id,
                     X_DENORM_MGR_ID  => l_denorm_mgr_id,
                     X_RESOURCE_ID    => member_rec.resource_id,
                     X_PERSON_ID => member_rec.person_id,
                     X_CATEGORY  => member_rec.category,
                     X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
                     X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
                     X_GROUP_ID  => member_rec.group_id,
                     X_REPORTS_TO_FLAG   => l_reports_to_flag,
                     X_HIERARCHY_TYPE =>   l_hierarchy_type,
                     X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                     X_END_DATE_ACTIVE => trunc(l_end_date_active),
                     X_ATTRIBUTE2 => null,
                     X_ATTRIBUTE3 => null,
                     X_ATTRIBUTE4 => null,
                     X_ATTRIBUTE5 => null,
                     X_ATTRIBUTE6 => null,
                     X_ATTRIBUTE7 => null,
                     X_ATTRIBUTE8 => null,
                     X_ATTRIBUTE9 => null,
                     X_ATTRIBUTE10  => null,
                     X_ATTRIBUTE11  => null,
                     X_ATTRIBUTE12  => null,
                     X_ATTRIBUTE13  => null,
                     X_ATTRIBUTE14  => null,
                     X_ATTRIBUTE15  => null,
                     X_ATTRIBUTE_CATEGORY   => null,
                     X_ATTRIBUTE1       => null,
                     X_CREATION_DATE     => l_date,
                     X_CREATED_BY         => l_user_id,
                     X_LAST_UPDATE_DATE   => l_date,
                     X_LAST_UPDATED_BY    => l_user_id,
                     X_LAST_UPDATE_LOGIN  => l_login_id,
                     X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).p_role_relate_id,
                     X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

             END IF; --end of dup check
             close dup_cur2;
            END IF; --st dt check
           END IF; --ADMIN FLAG END
        END LOOP; --end of for loop for all managers and admin of parent table stored in pl/sql table
        FETCH member_cur INTO member_rec;
     END LOOP; --member cur
     CLOSE member_cur;

  --end of insert record for the same group and this parent


  --open child group cursor
  OPEN child_grp_cur(rel_grp_rec.group_id);
  FETCH child_grp_cur INTO child_grp_rec;
  WHILE(child_grp_cur%FOUND)
  LOOP

        OPEN member_cur(child_grp_rec.group_id,
                        rel_grp_rec.start_date_active,
                        rel_grp_rec.end_date_active);
        FETCH member_cur INTO member_rec;
        WHILE(member_cur%FOUND)
        LOOP
            --insert records for all the members of the child group
           /*IF((child_grp_rec.immediate_parent_flag = 'Y')
                         AND (nvl(member_rec.manager_flag,'N') = 'Y'))
           THEN
                    l_reports_to_flag  := 'Y';
           ELSE
                    l_reports_to_flag  := 'N';
           END IF;*/

          l_reports_to_flag  := 'N';


           i := 0;
           FOR I IN 1 .. l_mgr_rec.COUNT
           LOOP
            --assign start date and end date for which this relation is valid
            IF(member_rec.start_date_active < l_mgr_rec(i).p_start_date_active)
            THEN
                 l_start_date_active := l_mgr_rec(i).p_start_date_active;
            ELSE
                 l_start_date_active := member_rec.start_date_active;
            END IF;

            IF(member_rec.end_date_active > l_mgr_rec(i).p_end_date_active)
            THEN
                 l_end_date_active := l_mgr_rec(i).p_end_date_active;
            ELSIF(l_mgr_rec(i).p_end_date_active IS NULL)
            THEN
                 l_end_date_active :=member_rec.end_date_active;
            ELSIF(member_rec.end_date_active IS NULL)
            THEN
                 l_end_date_active := l_mgr_rec(i).p_end_date_active;
            END IF;

          --set the hierarchy type if of type manager
          IF l_mgr_rec(i).p_manager_flag = 'Y'
          THEN
             IF member_rec.manager_flag = 'Y'
             THEN
                  l_hierarchy_type := 'MGR_TO_MGR';
             ELSIF member_rec.admin_flag = 'Y'
             THEN
                  l_hierarchy_type := 'MGR_TO_ADMIN';
             ELSE
                  l_hierarchy_type := 'MGR_TO_REP';
             END IF;
            if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
            then
              open dup_cur2(l_mgr_rec(i).p_role_relate_id ,
                          member_rec.role_relate_id,
                          member_rec.group_id);
              fetch dup_cur2 INTO dup;
              IF(dup_cur2%NOTFOUND)
              THEN
             --CALL TABLE HANDLER FOR INSETING IN REP MANAGER
                OPEN rep_mgr_seq_cur;
                FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                CLOSE rep_mgr_seq_cur;

               jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    => member_rec.resource_id,
               X_PERSON_ID => member_rec.person_id,
               X_CATEGORY  => member_rec.category,
               X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
	       X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
               X_GROUP_ID  => member_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => trunc(l_start_date_active),
               X_END_DATE_ACTIVE => trunc(l_end_date_active),
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).P_role_relate_id,
               X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;



               --INSERT REVERSE RECORD FOR MGR_TO_MGR

              IF member_rec.manager_flag = 'Y'
              THEN

                 OPEN rep_mgr_seq_cur;
                 FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
                 CLOSE rep_mgr_seq_cur;

                 jtf_rs_rep_managers_pkg.insert_row(
                     X_ROWID => x_row_id,
                     X_DENORM_MGR_ID  => l_denorm_mgr_id,
                     X_RESOURCE_ID    => member_rec.resource_id,
                     X_PERSON_ID => member_rec.person_id,
                     X_CATEGORY  => member_rec.category,
                     X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
		     X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
                     X_GROUP_ID  => l_mgr_rec(i).p_group_id,
                     X_REPORTS_TO_FLAG   => l_reports_to_flag,
                     X_HIERARCHY_TYPE =>   l_hierarchy_type,
                     X_START_DATE_ACTIVE    => trunc(l_start_date_active),
                     X_END_DATE_ACTIVE => trunc(l_end_date_active),
                     X_ATTRIBUTE2 => null,
                     X_ATTRIBUTE3 => null,
                     X_ATTRIBUTE4 => null,
                     X_ATTRIBUTE5 => null,
                     X_ATTRIBUTE6 => null,
                     X_ATTRIBUTE7 => null,
                     X_ATTRIBUTE8 => null,
                     X_ATTRIBUTE9 => null,
                     X_ATTRIBUTE10  => null,
                     X_ATTRIBUTE11  => null,
                     X_ATTRIBUTE12  => null,
                     X_ATTRIBUTE13  => null,
                     X_ATTRIBUTE14  => null,
                     X_ATTRIBUTE15  => null,
                     X_ATTRIBUTE_CATEGORY   => null,
                     X_ATTRIBUTE1       => null,
                     X_CREATION_DATE     => l_date,
                     X_CREATED_BY         => l_user_id,
                     X_LAST_UPDATE_DATE   => l_date,
                     X_LAST_UPDATED_BY    => l_user_id,
                     X_LAST_UPDATE_LOGIN  => l_login_id,
                     X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).P_role_relate_id,
                     X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

                 END IF; --END OF MGR_TO_MGR REVERSE RECORD POSTING
             END IF; --end of dup check
             close dup_cur2;
            END IF; --end of st dt check
           END IF; --MANAGER FLAG END


           IF l_mgr_rec(i).p_admin_flag = 'Y'
           THEN
             IF member_rec.manager_flag = 'Y'
             THEN
                  l_hierarchy_type := 'ADMIN_TO_MGR';
             ELSIF member_rec.admin_flag = 'Y'
             THEN
                  l_hierarchy_type := 'ADMIN_TO_ADMIN';
             ELSE
                  l_hierarchy_type := 'ADMIN_TO_REP';
             END IF;
             if(l_start_date_active <= nvl(l_end_date_active, l_start_date_active))
           then

            open dup_cur2(l_mgr_rec(i).P_role_relate_id ,
                          member_rec.role_relate_id,
                          member_rec.group_id);
            fetch dup_cur2 INTO dup;
            IF(dup_cur2%NOTFOUND)
            THEN
             --CALL TABLE HANDLER FOR INSERTING IN REP MANAGER
              OPEN rep_mgr_seq_cur;
              FETCH rep_mgr_seq_cur INTO l_denorm_mgr_id;
              CLOSE rep_mgr_seq_cur;

               jtf_rs_rep_managers_pkg.insert_row(
               X_ROWID => x_row_id,
               X_DENORM_MGR_ID  => l_denorm_mgr_id,
               X_RESOURCE_ID    => member_rec.resource_id,
               X_PERSON_ID => member_rec.person_id,
               X_CATEGORY  => member_rec.category,
               X_MANAGER_PERSON_ID =>l_mgr_rec(i).p_person_id,
	       X_PARENT_RESOURCE_ID => l_mgr_rec(i).p_resource_id,
               X_GROUP_ID  => member_rec.group_id,
               X_REPORTS_TO_FLAG   => l_reports_to_flag,
               X_HIERARCHY_TYPE =>   l_hierarchy_type,
               X_START_DATE_ACTIVE    => l_start_date_active,
               X_END_DATE_ACTIVE => l_end_date_active,
               X_ATTRIBUTE2 => null,
               X_ATTRIBUTE3 => null,
               X_ATTRIBUTE4 => null,
               X_ATTRIBUTE5 => null,
               X_ATTRIBUTE6 => null,
               X_ATTRIBUTE7 => null,
               X_ATTRIBUTE8 => null,
               X_ATTRIBUTE9 => null,
               X_ATTRIBUTE10  => null,
               X_ATTRIBUTE11  => null,
               X_ATTRIBUTE12  => null,
               X_ATTRIBUTE13  => null,
               X_ATTRIBUTE14  => null,
               X_ATTRIBUTE15  => null,
               X_ATTRIBUTE_CATEGORY   => null,
               X_ATTRIBUTE1       => null,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY         => l_user_id,
               X_LAST_UPDATE_DATE   => l_date,
               X_LAST_UPDATED_BY    => l_user_id,
               X_LAST_UPDATE_LOGIN  => l_login_id,
               X_PAR_ROLE_RELATE_ID => l_mgr_rec(i).p_role_relate_id,
               X_CHILD_ROLE_RELATE_ID => member_rec.role_relate_id);

  IF fnd_api.to_boolean (p_commit)
  THEN
    l_count := l_count + 1;
    if (l_count > 1000)
    then
       COMMIT WORK;
       l_count := 0;
    end if;
  END IF;

              END IF; --end of dup check
              close dup_cur2;
             END IF; --END OF ST DATE CHECK
             END IF; --ADMIN FLAG END
           END LOOP; --end of for loop for all managers and admin of parent table stored in pl/sql table
           FETCH member_cur INTO member_rec;
        END LOOP; --member cur
        CLOSE member_cur;


       FETCH child_grp_cur INTO child_grp_rec;
  END LOOP; --CHILD GRP CUR
--
  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN

      ROLLBACK TO member_denormalize;
      --fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO member_denormalize;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO member_denormalize;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END INSERT_GRP_RELATIONS;
END JTF_RS_REP_MGR_DENORM_PVT;

/
