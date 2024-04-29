--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLE_RELATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLE_RELATE_PVT" AS
/* $Header: jtfrsvlb.pls 120.0.12010000.2 2009/05/27 11:46:29 rgokavar ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource roles, like
   create, update and delete resource roles from other modules.
   Its main procedures are as following:
   Create Resource Role Relate
   Update Resource Role Relate
   Delete Resource Role Relate
   Calls to these procedures will invoke procedures from jtf_rs_role_relate_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_ROLE_RELATE_PVT';
  G_NAME             VARCHAR2(240);


/* private procedure to check that is updating role date for resource then
   group/team meber roles are still valid */
   procedure  validate_indv_role_date(p_role_relate_id IN NUMBER,
                   p_role_id        IN NUMBER ,
                   p_resource_id    IN NUMBER,
                   p_old_start_date IN DATE ,
                   p_old_end_date   IN DATE ,
                   p_new_start_date IN DATE ,
                   p_new_end_date   IN DATE ,
                   p_valid          OUT NOCOPY BOOLEAN);


   procedure validate_indv_role_date(p_role_relate_id IN NUMBER,
                   p_role_id        IN NUMBER ,
                   p_resource_id    IN NUMBER,
                   p_old_start_date IN DATE ,
                   p_old_end_date   IN DATE ,
                   p_new_start_date IN DATE ,
                   p_new_end_date   IN DATE ,
                   p_valid          OUT NOCOPY BOOLEAN)
   is

  CURSOR rsc_cur(ll_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT rsc.start_date_active,
         rsc.end_date_active
    FROM jtf_rs_resource_extns rsc
   WHERE rsc.resource_id = ll_resource_id;

  rsc_rec rsc_cur%rowtype;

  l_valid boolean := TRUE;

   cursor grp_mem_cur
       is
    select rlt.role_relate_id,
           rlt.start_date_active,
           rlt.end_date_active
     from  jtf_rs_role_relations rlt,
           jtf_rs_group_members mem
     where mem.resource_id = p_resource_id
       and nvl(mem.delete_flag, 'N') <> 'Y'
       and rlt.role_resource_id = mem.group_member_id
       and rlt.role_id = p_role_id                        --added vide bug#2474811
       and rlt.role_resource_type = 'RS_GROUP_MEMBER'
       and nvl(rlt.delete_flag, 'N') <> 'Y'
       and rlt.start_date_active between p_old_start_date  and
          to_date(to_char(nvl(p_old_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR');
   l_grp_valid BOOLEAN := TRUE;


    cursor team_mem_cur
       is
    select rlt.role_relate_id,
           rlt.start_date_active,
           rlt.end_date_active
     from  jtf_rs_role_relations rlt,
           jtf_rs_team_members mem
     where mem.team_resource_id = p_resource_id
       and mem.resource_type = 'INDIVIDUAL'
       and nvl(mem.delete_flag, 'N') <> 'Y'
       and rlt.role_resource_id = mem.team_member_id
       and rlt.role_id = p_role_id                       --added vide bug#2474811
       and rlt.role_resource_type = 'RS_TEAM_MEMBER'
       and nvl(rlt.delete_flag, 'N') <> 'Y'
       and rlt.start_date_active between p_old_start_date  and
          to_date(to_char(nvl(p_old_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR') ;
   l_team_valid BOOLEAN := TRUE;

/* removed the below parameter since it is not used anywhere */
--   l_end_date date := to_date(to_char(fnd_api.g_miss_date, 'DD-MM-RRRR'), 'DD-MM-RRRR');
   begin

    open rsc_cur(p_resource_id);
    fetch rsc_cur INTO rsc_rec;
    close rsc_cur;
    IF((rsc_rec.start_date_active > p_new_start_date)
      -- changed by sudarsana 11 feb 2002
      OR (rsc_rec.end_date_active < to_date(to_char(nvl(p_new_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR')))
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_DATE_ERR');
          FND_MSG_PUB.add;
          l_valid := FALSE;
    END IF;

   for grp_mem_rec in grp_mem_cur
   loop
        if(grp_mem_rec.start_date_active not between p_new_start_date
                                            and to_date(to_char(nvl(p_new_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
        then
          l_grp_valid := FALSE;
        end if;

        if(to_date(to_char(nvl(grp_mem_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR') not between p_new_start_date
                                            and to_date(to_char(nvl(p_new_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
        then
          l_grp_valid := FALSE;
        end if;

        if NOT(l_grp_valid)
        then
          fnd_message.set_name ('JTF', 'JTF_RS_RES_UPD_DT_ERR');
          FND_MSG_PUB.add;
          exit;
        end if;
   end loop; --end of grp_mem_cur

   for team_mem_rec in team_mem_cur
   loop
        if(team_mem_rec.start_date_active not between p_new_start_date
                       and to_date(to_char(nvl(p_new_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
        then
          l_team_valid := FALSE;
        end if;

        if(to_date(to_char(nvl(team_mem_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR')
             not between p_new_start_date and to_date(to_char(nvl(p_new_end_date, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
        then
          l_team_valid := FALSE;
        end if;

        if NOT(l_team_valid)
        then
          fnd_message.set_name ('JTF', 'JTF_RS_RES_UPD_DT_ERR');
          FND_MSG_PUB.add;
          exit;
        end if;
   end loop; --end of grp_mem_cur

   if NOT (l_grp_valid)
        OR NOT (l_team_valid)
        OR NOT (l_valid)
   then
          p_valid := FALSE;
   end if;

  end validate_indv_role_date;



/* private procedure to check that role type is active during
   this role relation dates */
   procedure  validate_role_type(p_role_id        IN NUMBER ,
                   p_start_date IN DATE ,
                   p_end_date   IN DATE ,
                   p_valid      OUT NOCOPY BOOLEAN);


   procedure  validate_role_type(p_role_id        IN NUMBER ,
                   p_start_date IN DATE ,
                   p_end_date   IN DATE ,
                   p_valid      OUT NOCOPY BOOLEAN)
   is

  CURSOR get_type_cur(l_role_id JTF_RS_ROLES_B.role_id%TYPE)
      IS
  SELECT role_type_code
    FROM jtf_rs_roles_b
   WHERE role_id = l_role_id;

  role_type_rec get_type_cur%rowtype;

   cursor chk_role_type_cur(l_role_type FND_LOOKUPS.LOOKUP_CODE%type)
       is
    select 'X'
     from  fnd_lookups
     where lookup_type = 'JTF_RS_ROLE_TYPE'
       and lookup_code = l_role_type
       and ENABLED_FLAG = 'Y'
       and START_DATE_ACTIVE <= p_start_date
       and (END_DATE_ACTIVE is NULL or
            (p_end_date is not null and
             END_DATE_ACTIVE >= p_end_date));

    chk_role_type_rec chk_role_type_cur%rowtype;

  begin
    p_valid := FALSE;
    open get_type_cur(p_role_id);
    fetch get_type_cur INTO role_type_rec;
    if (get_type_cur%found) then
      close get_type_cur;
      open chk_role_type_cur(role_type_rec.role_type_code);
      fetch chk_role_type_cur INTO chk_role_type_rec;
      if (chk_role_type_cur%found) then
        p_valid := TRUE;
      end if;
      close chk_role_type_cur;
    else
      close get_type_cur;
    end if;
  end validate_role_type;


  /* Procedure to create the resource roles
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_role_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_ROLE_RESOURCE_TYPE   IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE,
   P_ROLE_RESOURCE_ID     IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
   P_ROLE_ID              IN   JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE,
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
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_ROLE_RELATE_ID       OUT NOCOPY  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE
  )IS

  l_api_name              CONSTANT VARCHAR2(30)  := 'CREATE_RESOURCE_ROLE_RELATE';
  l_api_version           CONSTANT NUMBER	 := 1.0;
  l_bind_data_id          NUMBER;

  /* Moved the initial assignment of below variables to inside begin */
  l_role_resource_type   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE;
  l_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE;
  l_role_id              JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE;
  -- added truncate on 12 feb 2002
  l_start_date_active    JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE;
  l_end_date_active      JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE;

  l_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE;
  l_return_code          VARCHAR2(100);
  l_count                NUMBER;
  l_data                 VARCHAR2(200);

  l_return_status        VARCHAR2(200);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(200);
  l_rowid                VARCHAR2(200);

  l_date_invalid         boolean := FALSE;


  CURSOR  team_mem_cur(l_team_member_id JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE)
      IS
   SELECT resource_type,
          team_resource_id
     FROM jtf_rs_team_members
    WHERE team_member_id = l_team_member_id;


   CURSOR  grp_mem_cur(l_grp_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
      IS
   SELECT resource_id
     FROM jtf_rs_group_members
    WHERE group_member_id = l_grp_member_id;

   l_rsc_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   l_team_resource_type JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE;

 --changed the date comparison in the cursor 07/07/00
  CURSOR  res_role_cur(ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                       ll_role_id              JTF_RS_ROLES_B.ROLE_ID%TYPE,
                       ll_start_date_active    JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                       ll_end_date_active      JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE )
      IS
    SELECT 'X'
   FROM  jtf_rs_role_relations
  WHERE  role_resource_type = 'RS_INDIVIDUAL'
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  nvl(delete_flag, '0') <> 'Y'
    AND  to_date(to_char(start_date_active , 'dd-MM-yyyy'),'dd-MM-yyyy')  <=
                      to_date(to_char(ll_start_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
    AND  ( to_date(to_char(end_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
              >= to_date(to_char(ll_end_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
         OR ( end_date_active IS NULL AND ll_end_date_active IS NULL)
         OR (end_date_active IS NULL AND ll_end_date_active IS NOT NULL))
    AND  nvl(delete_flag, '0') <> 'Y';

  res_role_rec res_role_cur%rowtype;

  CURSOR  grp_role_cur(ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                       ll_role_id              JTF_RS_ROLES_B.ROLE_ID%TYPE,
                       ll_start_date_active    JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                       ll_end_date_active      JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE )
      IS
    SELECT 'X'
   FROM  jtf_rs_role_relations
  WHERE  role_resource_type = 'RS_GROUP'
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  start_date_active  <= ll_start_date_active
    AND  nvl(delete_flag, '0') <> 'Y'
    AND  ( end_date_active  >= ll_end_date_active
         OR ( end_date_active IS NULL AND ll_end_date_active IS NULL)
         OR (end_date_active IS NULL AND ll_end_date_active IS NOT NULL))
  AND  nvl(delete_flag, '0') <> 'Y';

  grp_role_rec grp_role_cur%rowtype;

  l_role_valid         boolean := FALSE;

  CURSOR check_date_cur(ll_role_resource_type   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE ,
                        ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                        ll_role_id              JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE)
      IS
  SELECT start_date_active,
         end_date_active
   FROM  jtf_rs_role_relations
  WHERE  role_resource_type = ll_role_resource_type
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  nvl(delete_flag, 'N') <> 'Y';

  check_date_rec    check_date_cur%rowtype;

  CURSOR group_cur(ll_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
      IS
  SELECT grp.start_date_active,
         grp.end_date_active
    FROM jtf_rs_groups_b grp,
         jtf_rs_group_members mem
   WHERE mem.group_member_id = ll_member_id
     AND mem.group_id = grp.group_id;

  group_rec group_cur%rowtype;

--
  CURSOR group_dt_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
      IS
  SELECT grp.start_date_active,
         grp.end_date_active
    FROM jtf_rs_groups_b grp
   WHERE grp.group_id = l_group_id;

  group_dt_rec group_dt_cur%rowtype;

 CURSOR team_dt_cur(l_team_id JTF_RS_TEAMS_B.TEAM_ID%TYPE)
      IS
  SELECT tm.start_date_active,
         tm.end_date_active
    FROM jtf_rs_teams_b tm
   WHERE tm.team_id = l_team_id;

  team_dt_rec team_dt_cur%rowtype;



  CURSOR team_cur(ll_member_id JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE)
      IS
  SELECT tm.start_date_active,
         tm.end_date_active
    FROM jtf_rs_teams_b tm,
         jtf_rs_team_members mem
   WHERE mem.team_member_id = ll_member_id
     AND mem.team_id = tm.team_id;

  team_rec team_cur%rowtype;


  CURSOR rsc_cur(ll_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT rsc.start_date_active,
         rsc.end_date_active
    FROM jtf_rs_resource_extns rsc
   WHERE rsc.resource_id = ll_resource_id;

  rsc_rec rsc_cur%rowtype;


  --exclusive flag check cursor
  CURSOR c_exclusive_group_check_cur(l_member_id  JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
                                 l_start_date_active  DATE,
                                 L_end_date_active    DATE)
    IS
  SELECT 'X'
      FROM jtf_rs_groups_b G1,
        jtf_rs_groups_b G2,
        jtf_rs_group_members GM1,
        jtf_rs_group_members GM2,
        jtf_rs_group_usages GU1,
        jtf_rs_group_usages GU2,
        jtf_rs_role_relations RR1
/* commented the below line to improve the performance. We are not using this table in the select statement. */
--        jtf_rs_role_relations RR2
      WHERE GM2.group_member_id = l_member_id
        AND G1.group_id = GM1.group_id
        AND G2.group_id = GM2.group_id
        AND nvl(GM1.delete_flag, 'N') <> 'Y'
        AND nvl(GM2.delete_flag, 'N') <> 'Y'
        AND GM1.resource_id = GM2.resource_id
        AND GM1.group_member_id = RR1.role_resource_id
        AND RR1.role_resource_type = 'RS_GROUP_MEMBER'
        AND nvl(RR1.delete_flag, 'N') <> 'Y'
        AND not (((nvl(l_end_date_active,RR1.start_date_active + 1) < RR1.start_date_active OR
                   l_start_date_active > RR1.end_date_active) AND
                   RR1.end_date_active IS NOT NULL)
                 OR ( nvl(l_end_date_active,RR1.start_date_active + 1) < RR1.start_date_active AND
                     RR1.end_date_active IS NULL ))
        AND G2.exclusive_flag = 'Y'
        AND G1.exclusive_flag = 'Y'
        AND GU1.group_id = G1.group_id
        AND GU2.group_id = G2.group_id
        AND GU1.usage = GU2.usage
        AND G1.group_id <> G2.group_id;


  c_exclusive_group_check_rec  c_exclusive_group_check_cur%rowtype;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  cursor get_group_cur(l_role_relate_id number)
     is
   select mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel
   where rel.role_relate_id = l_role_relate_id
     and rel.role_resource_id = mem.group_member_id;

  l_group_id  number;

  cursor get_child_cur(l_group_id number)
     is
   select count(*) child_cnt
    from  jtf_rs_grp_relations rel
   connect by related_group_id = prior group_id
     and   nvl(delete_flag, 'N') <> 'Y'
     AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
    start with related_group_id = l_group_id
     and   nvl(delete_flag, 'N') <> 'Y';

   l_child_cnt number := 0;
   l_request   number;

  cursor conc_prog_cur
     is
  select description
    from fnd_concurrent_programs_vl
   where concurrent_program_name = 'JTFRSRMG'
     and application_id = 690;

  l_role_type_valid boolean := false;

  BEGIN

   l_role_resource_type   := p_role_resource_type;
   l_role_resource_id     := p_role_resource_id;
   l_role_id              := p_role_id;
   l_start_date_active    := trunc(p_start_date_active);
   l_end_date_active      := trunc(p_end_date_active);

--dbms_output.put_line ('Debug Message begin 10');
     --Standard Start of API SAVEPOINT
     SAVEPOINT ROLE_RELATE_SP;

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

--dbms_output.put_line ('Debug Message 10');


  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


  -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then


            JTF_RS_ROLE_RELATE_CUHK.CREATE_RES_ROLE_RELATE_PRE(P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

    /*  	Vertial industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then

          JTF_RS_ROLE_RELATE_VUHK.CREATE_RES_ROLE_RELATE_PRE(P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

    /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then

          JTF_RS_ROLE_RELATE_IUHK.CREATE_RES_ROLE_RELATE_PRE(P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

--dbms_output.put_line ('Debug Message 11');


  -- end of user hook call

   --check start date null
   IF(l_start_date_active is NULL)
   THEN
       fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;


   --check start date less than end date
   IF(l_start_date_active > l_end_date_active)
   THEN
       fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;

   IF(l_role_resource_type = 'RS_TEAM' or
      l_role_resource_type = 'RS_GROUP' or
      l_role_resource_type = 'RS_INDIVIDUAL')
   THEN
     validate_role_type(l_role_id,
			l_start_date_active,
			l_end_date_active,
			l_role_type_valid);

     if (l_role_type_valid = false) then
	 fnd_message.set_name ('JTF', 'JTF_RS_ROLE_TYPE_INACTIVE');
	 FND_MSG_PUB.add;
	 RAISE fnd_api.g_exc_error;
     end if;
   END IF;

--dbms_output.put_line ('Debug Message 12');


    --check whether the start date and end date overlaps any existing start date and end date
   --for the resource type, resource id and role.
   open check_date_cur(l_role_resource_type,
                       l_role_resource_id,
                       l_role_id);
   fetch check_date_cur INTO check_date_rec;
   While(check_date_cur%found)
   loop
      IF((l_start_date_active >= check_date_rec.start_date_active)
         AND ((l_start_date_active <= check_date_rec.end_date_active)
              OR (check_date_rec.end_date_active IS NULL)))
      THEN
         l_date_invalid := TRUE;
      END IF;


     IF((to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR')
             between check_date_rec.start_date_active and
                           to_date(to_char(nvl(check_date_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
         OR (l_end_date_active IS NULL AND
                  check_date_rec.end_date_active IS NULL))
     THEN
           l_date_invalid := TRUE;
     END IF;

     -- added this check as a date range outside of the existing ranges was getting entered
     if(l_start_date_active < check_date_rec.start_date_active
        and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR') >
                   to_date(to_char(nvl(check_date_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
     THEN
        l_date_invalid := TRUE;
     END IF;

    IF(l_date_invalid)
    THEN
       exit;
    END IF;
    fetch check_date_cur INTO check_date_rec;
   end loop;
   CLOSE check_date_cur;

   IF(l_date_invalid)
   THEN
       fnd_message.set_name ('JTF', 'JTF_RS_OVERLAP_DATE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;
   --end of overlapping date range check


  --check whether team member is resource or group
  IF(l_role_resource_type = 'RS_TEAM_MEMBER')
  THEN
     OPEN team_mem_cur(l_role_resource_id);
     FETCH team_mem_cur INTO l_team_resource_type, l_rsc_id;
     CLOSE team_mem_cur;

  END IF;

--dbms_output.put_line ('Debug Message 14');

  IF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN
     OPEN grp_mem_cur(l_role_resource_id);
     FETCH grp_mem_cur INTO l_rsc_id;
     CLOSE grp_mem_cur;

  END IF;


   --valid role for the resource if being entered as a group member and team member
  IF((l_role_resource_type = 'RS_GROUP_MEMBER') OR
     ((l_role_resource_type = 'RS_TEAM_MEMBER') AND
       (l_team_resource_type = 'INDIVIDUAL')))
  THEN
  --if team member is of type resource or it is group member
  --then check for valid role and st date , end date for the resource
  --in role relations
       open res_role_cur(l_rsc_id,
                        l_role_id  ,
                        l_start_date_active ,
                        l_end_date_active   );
       fetch res_role_cur INTO res_role_rec;
       IF(res_role_cur%found)
       THEN
         l_role_valid := TRUE;

       ELSE
          l_role_valid := FALSE;
          fnd_message.set_name ('JTF', 'JTF_RS_ROLE_OR_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
       END IF;
       close res_role_cur;
   ELSIF((l_role_resource_type = 'RS_TEAM_MEMBER') AND
             (l_team_resource_type = 'GROUP'))
   THEN
  --if team member is of type group then check for valid role and st date ,
  --end date for the group in role relations

--dbms_output.put_line ('Debug Message 15');

      open grp_role_cur(l_rsc_id,
                        l_role_id  ,
                        l_start_date_active ,
                        l_end_date_active   );
       fetch grp_role_cur INTO grp_role_rec;
       IF(grp_role_cur%found)
       THEN
         l_role_valid := TRUE;

       ELSE
          l_role_valid := FALSE;
          fnd_message.set_name ('JTF', 'JTF_RS_ROLE_OR_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
       END IF;
       close grp_role_cur;
   END IF;
   -- end of valid role for the resource if being entered as a group member and team member

--dbms_output.put_line ('Debug Message 16');


  --if resource type is group member or team member then check against group and team
  --start date and end date
  IF(l_role_resource_type = 'RS_TEAM_MEMBER')
  THEN
    open team_cur(l_role_resource_id);
    fetch team_cur INTO team_rec;
    close team_cur;
    IF((trunc(team_rec.start_date_active) > trunc(l_start_date_active))
       OR to_date(to_char(nvl(team_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR') < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

   IF(team_rec.end_date_active is not null AND l_end_date_active is null)
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

--dbms_output.put_line ('Debug Message 17');


  ELSIF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN
    --date validation against group dates
    open group_cur(l_role_resource_id);
    fetch group_cur INTO group_rec;
    close group_cur;

    IF((trunc(group_rec.start_date_active) > trunc(l_start_date_active))
       OR to_date(to_char(nvl(group_rec.end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR') < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR'))
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;


    IF(group_rec.end_date_active is not null AND l_end_date_active is null)
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

    --exclusive flag validation
      open c_exclusive_group_check_cur(l_role_resource_id,
                                    l_start_date_active,
                                    l_end_date_active);

      fetch c_exclusive_group_check_cur into c_exclusive_group_check_rec;
      IF(c_exclusive_group_check_cur%FOUND)
      THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_USAGE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      close c_exclusive_group_check_cur;

  ELSIF(l_role_resource_type = 'RS_INDIVIDUAL')
  --check against res start and end dates
  THEN
    open rsc_cur(l_role_resource_id);
    fetch rsc_cur INTO rsc_rec;
    close rsc_cur;
    IF((rsc_rec.start_date_active > l_start_date_active)
      -- changed by sudarsana 11 feb 2002
      OR (rsc_rec.end_date_active < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date), 'DD-MM-RRRR'), 'DD-MM-RRRR')))
       THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
  ELSIF(l_role_resource_type = 'RS_GROUP')
 --check against group start and end dates
  THEN
    open group_dt_cur(l_role_resource_id);
    fetch group_dt_cur INTO group_dt_rec;
    close group_dt_cur;
    IF((group_dt_rec.start_date_active > l_start_date_active)
      -- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
      --OR (group_dt_rec.end_date_active < l_end_date_active))
      OR (to_date(to_char(nvl(group_dt_rec.end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
                      < (to_date(to_char(nvl(l_end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))))
       THEN
          fnd_message.set_name ('JTF', 'JTF_RS_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
  ELSIF(l_role_resource_type = 'RS_TEAM')
 --check against team start and end dates
  THEN
    open team_dt_cur(l_role_resource_id);
    fetch team_dt_cur INTO team_dt_rec;
    close team_dt_cur;
    IF((team_dt_rec.start_date_active > l_start_date_active)
      -- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
      --OR (team_dt_rec.end_date_active < l_end_date_active))
      OR (to_date(to_char(nvl(team_dt_rec.end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
                    < (to_date(to_char(nvl(l_end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))))
       THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TEAM_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

--dbms_output.put_line ('Debug Message 19');

  --get the primary key sequence value
  select  jtf_rs_role_relations_s.nextval
    into  l_role_relate_id
    from  dual;


  --call audit api for insert
  jtf_rs_role_relate_aud_pvt.insert_role_relate(
                               P_API_VERSION           => 1.0,
                               P_INIT_MSG_LIST         => p_init_msg_list,
                               P_COMMIT                => null,
                               P_ROLE_RELATE_ID        => l_role_relate_id,
                               P_ROLE_RESOURCE_TYPE    => l_role_resource_type,
                               P_ROLE_RESOURCE_ID      => l_role_resource_id,
                               P_ROLE_ID               => l_role_id,
                               P_START_DATE_ACTIVE     => l_start_date_active,
                               P_END_DATE_ACTIVE       => l_end_date_active,
                               P_OBJECT_VERSION_NUMBER => 1,
                               X_RETURN_STATUS         => l_return_status,
                               X_MSG_COUNT             => l_msg_count,
                               X_MSG_DATA              => l_msg_data  );

   IF(l_return_status <>  fnd_api.g_ret_sts_success)
   THEN
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

--dbms_output.put_line ('Debug Message 20');
--dbms_output.put_line ('Before Calling Table Handler : x_return_status=' ||x_return_status);
--dbms_output.put_line ('l_role_relate_id' || l_role_relate_id);
--dbms_output.put_line ('l_rowid ' || l_rowid);

   --Date Conversion before Insert_Row

/*     l_start_date_active := to_date(to_char(l_start_date_active, 'DD-MM-YYYY') || ' ' || to_char(sysdate, 'HH24:MI:SS'), 'DD-MM-YYYY HH24:MI:SS');
*/
     --dbms_output.put_line ('l_start_date_active' || to_char(l_start_date_active, 'DD-MM-YYYY HH24:MI:SS'));

   --call table handler to insert record in role relations
   jtf_rs_role_relations_pkg.insert_row(X_ROWID => l_rowid,
                                        X_ROLE_RELATE_ID => l_role_relate_id,
                                        X_ATTRIBUTE9         => p_attribute9,
                                        X_ATTRIBUTE10        => p_attribute10,
                                        X_ATTRIBUTE11        => p_attribute11,
                                        X_ATTRIBUTE12        => p_attribute12,
                                        X_ATTRIBUTE13        => p_attribute13,
                                        X_ATTRIBUTE14        => p_attribute14,
                                        X_ATTRIBUTE15        => p_attribute15,
                                        X_ATTRIBUTE_CATEGORY => p_attribute_category,
                                        X_ROLE_RESOURCE_TYPE => l_role_resource_type,
                                        X_ROLE_RESOURCE_ID   => l_role_resource_id,
                                        X_ROLE_ID            => l_role_id,
                                        X_START_DATE_ACTIVE  => l_start_date_active,
                                        X_END_DATE_ACTIVE    => l_end_date_active,
                                        X_DELETE_FLAG        => 'N',
                                        X_ATTRIBUTE2         => p_attribute2,
                                        X_ATTRIBUTE3         => p_attribute3,
                                        X_ATTRIBUTE4         => p_attribute4,
                                        X_ATTRIBUTE5         => p_attribute5,
                                        X_ATTRIBUTE6         => p_attribute6,
                                        X_ATTRIBUTE7         => p_attribute7,
                                        X_ATTRIBUTE8         => p_attribute8,
                                        X_ATTRIBUTE1         => p_attribute1,
                                        X_CREATION_DATE      => l_date,
                                        X_CREATED_BY         => l_user_id,
                                        X_LAST_UPDATE_DATE   => l_date,
                                        X_LAST_UPDATED_BY    => l_user_id,
                                        X_LAST_UPDATE_LOGIN  => l_login_id )  ;

--dbms_output.put_line (' After Calling Table Handler : x_return_status=' ||x_return_status);

--dbms_output.put_line ('Debug Message 21');

  IF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN
     -- get the group id of the member
        open get_group_cur(l_role_relate_id);
        fetch get_group_cur into l_group_id;
        close get_group_cur;

     --get no of children for the group
       BEGIN
	 open get_child_cur(l_group_id);
	 fetch get_child_cur into l_child_cnt;
	 close get_child_cur;
       EXCEPTION
         WHEN OTHERS THEN
           l_child_cnt := 101; -- use concurrent program
       END;

     if (nvl(l_child_cnt, 0)  > 100)
     then
       begin
         insert  into jtf_rs_chgd_role_relations
               (role_relate_id,
                role_resource_type,
                role_resource_id,
                role_id,
                start_date_active,
                end_date_active,
                delete_flag,
                operation_flag,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
        values(
                l_role_relate_id,
                l_role_resource_type,
                l_role_resource_id,
                l_role_id,
                l_start_date_active,
                l_end_date_active,
                'N',
                'I',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);

          exception
            when others then
              fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
              fnd_message.set_token('P_SQLCODE',SQLCODE);
              fnd_message.set_token('P_SQLERRM',SQLERRM);
              fnd_message.set_token('P_API_NAME', l_api_name);
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_unexpected_error;


        end;


         --call concurrent program

        begin
                 l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSRMG');

                     open conc_prog_cur;
                     fetch conc_prog_cur into g_name;
                     close conc_prog_cur;

                      fnd_message.set_name ('JTF', 'JTF_RS_CONC_START');
                      fnd_message.set_token('P_NAME',g_name);
                      fnd_message.set_token('P_ID',l_request);
                      FND_MSG_PUB.add;

                 exception when others then
                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      RAISE fnd_api.g_exc_unexpected_error;
        end;

     else
        --call to insert records in jtf_rs_rep_managers
             JTF_RS_REP_MGR_DENORM_PVT.INSERT_REP_MANAGER
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_ROLE_RELATE_ID  => l_role_relate_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

       IF(l_return_status <>  fnd_api.g_ret_sts_success)
       THEN
	  IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
        END IF;
    END IF; -- end of count check
   END IF;

--dbms_output.put_line ('Debug Message 22');
   -- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'A', 'C' ))
   then
         JTF_RS_ROLE_RELATE_CUHK.CREATE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID => l_role_relate_id,
								P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;


--dbms_output.put_line ('Debug Message 23');

    /*  	Verticle industry post- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then
            JTF_RS_ROLE_RELATE_VUHK.CREATE_RES_ROLE_RELATE_POST(p_role_relate_id => l_role_relate_id,
								P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

   /*  Internal post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'CREATE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then
            JTF_RS_ROLE_RELATE_IUHK.CREATE_RES_ROLE_RELATE_POST(p_role_relate_id => l_role_relate_id,
								P_ROLE_RESOURCE_TYPE  => p_role_resource_type,
                                                               P_ROLE_RESOURCE_ID  =>  p_role_resource_id,
                                                               P_ROLE_ID           =>  p_role_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <> FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

  -- end of user hook call

  x_role_relate_id := l_role_relate_id;

  IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'CREATE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN
  IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'CREATE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN

      IF (jtf_rs_role_relate_cuhk.ok_to_generate_msg(
            p_role_relate_id => l_role_relate_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_relate_id',
            l_role_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_RRL',
          p_action_code => 'I',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        END IF;

      END IF;

    END IF;
    END IF;

  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      /* Calling publish API to raise create resource role relation event. */
      /* added by baianand on 04/09/2003 */

      begin
         jtf_rs_wf_events_pub.create_resource_role_relate
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_role_relate_id            => l_role_relate_id
              ,p_role_resource_type        => l_role_resource_type
              ,p_role_resource_id          => l_role_resource_id
              ,p_role_id                   => l_role_id
              ,p_start_date_active         => l_start_date_active
              ,p_end_date_active           => l_end_date_active
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

      EXCEPTION when others then
         null;
      end;

     /* End of publish API call */

   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ROLE_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END  create_resource_role_relate;



  /* Procedure to update the resource roles
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_role_relate
   (P_API_VERSION        IN     NUMBER,
   P_INIT_MSG_LIST       IN     VARCHAR2,
   P_COMMIT              IN     VARCHAR2,
   P_ROLE_RELATE_ID      IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE   IN     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE     IN     JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE,
   P_OBJECT_VERSION_NUM  IN OUT NOCOPY JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
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
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  )IS
  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_ROLE_RELATE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data           VARCHAR2(200);


  L_ATTRIBUTE1		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_ROLE_RELATIONS.ATTRIBUTE_CATEGORY%TYPE;


  CURSOR role_relate_cur(ll_role_relate_id JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
   SELECT role_resource_type,
          role_resource_id,
          role_id,
          start_date_active,
          end_date_active,
          object_version_number,
          delete_flag,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category
   FROM   jtf_rs_role_relations
  WHERE   role_relate_id = ll_role_relate_id
    AND  nvl(delete_flag, '0') <> 'Y';

  role_relate_rec role_relate_cur%rowtype;

  l_role_resource_type    JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE ;
  l_role_resource_id      JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE   ;
  l_role_id               JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE            ;
  -- added trunc on 12th feb 2002
  /* Moved the initial assignment of below variables to inside begin */
  l_start_date_active     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE;
  l_end_date_active       JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE;
  l_role_relate_id        JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE;
  l_object_version_number JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE;
  l_delete_flag           JTF_RS_ROLE_RELATIONS.DELETE_FLAG%TYPE ;

  l_return_status         VARCHAR2(200);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_rowid                 VARCHAR2(200);

  l_date_invalid         boolean := FALSE;
  l_role_valid           boolean := FALSE;
  l_date                 Date;
  l_user_id              Number;
  l_login_id             Number;
  l_group_id             number;
  l_child_cnt            number := 0;
  l_request              number;

  l_valid                boolean := TRUE;

  CURSOR  team_mem_cur(l_team_member_id JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE)
      IS
   SELECT resource_type,
          team_resource_id
     FROM jtf_rs_team_members
    WHERE team_member_id = l_team_member_id
     AND  nvl(delete_flag, '0') <> 'Y';


  CURSOR  grp_mem_cur(l_grp_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
      IS
   SELECT resource_id
     FROM jtf_rs_group_members
    WHERE group_member_id = l_grp_member_id
      AND  nvl(delete_flag, '0') <> 'Y';

   l_rsc_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   l_team_resource_type JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE;

 --changed the date comparison in the cursor 07/07/00
  CURSOR  res_role_cur(ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                       ll_role_id              JTF_RS_ROLES_B.ROLE_ID%TYPE,
                       ll_start_date_active    JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                       ll_end_date_active      JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE )
      IS
    SELECT 'X'
   FROM  jtf_rs_role_relations
  WHERE  role_resource_type = 'RS_INDIVIDUAL'
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  to_date(to_char(start_date_active , 'dd-MM-yyyy'),'dd-MM-yyyy')  <=
                      to_date(to_char(ll_start_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
    AND  ( to_date(to_char(end_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
              >= to_date(to_char(ll_end_date_active, 'dd-MM-yyyy'),'dd-MM-yyyy')
         OR ( end_date_active IS NULL AND ll_end_date_active IS NULL)
         OR (end_date_active IS NULL AND ll_end_date_active IS NOT NULL))
    AND  nvl(delete_flag, '0') <> 'Y';

  res_role_rec res_role_cur%rowtype;

  CURSOR  grp_role_cur(ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                       ll_role_id              JTF_RS_ROLES_B.ROLE_ID%TYPE,
                       ll_start_date_active    JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                       ll_end_date_active      JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE )
      IS
    SELECT 'X'
   FROM  jtf_rs_role_relations
  WHERE  role_resource_type = 'RS_GROUP'
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  start_date_active  <= ll_start_date_active
    AND  ( end_date_active  >= ll_end_date_active
         OR ( end_date_active IS NULL AND ll_end_date_active IS NULL)
         OR (end_date_active IS NULL AND ll_end_date_active IS NOT NULL))
    AND  nvl(delete_flag, '0') <> 'Y';

  grp_role_rec grp_role_cur%rowtype;


  CURSOR check_date_cur(ll_role_resource_type   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE ,
                        ll_role_resource_id     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
                        ll_role_id              JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE,
                        ll_role_relate_id       JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
  SELECT start_date_active,
         end_date_active
   FROM  jtf_rs_role_relations
  WHERE  role_relate_id    <> ll_role_relate_id
    AND  role_resource_type = ll_role_resource_type
    AND  role_resource_id   = ll_role_resource_id
    AND  role_id            = ll_role_id
    AND  nvl(delete_flag, 'N') <> 'Y';


  check_date_rec    check_date_cur%rowtype;

  CURSOR group_cur(ll_member_id JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE)
      IS
  SELECT grp.start_date_active,
         grp.end_date_active
    FROM jtf_rs_groups_b grp,
         jtf_rs_group_members mem
   WHERE mem.group_member_id = ll_member_id
     AND mem.group_id = grp.group_id
     AND  nvl(mem.delete_flag, '0') <> 'Y';

  group_rec group_cur%rowtype;


  CURSOR team_cur(ll_member_id JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE)
      IS
  SELECT tm.start_date_active,
         tm.end_date_active
    FROM jtf_rs_teams_b tm,
         jtf_rs_team_members mem
   WHERE mem.team_member_id = ll_member_id
     AND mem.team_id = tm.team_id
     AND  nvl(mem.delete_flag, '0') <> 'Y';

  team_rec team_cur%rowtype;

  CURSOR rsc_cur(ll_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT rsc.start_date_active,
         rsc.end_date_active
    FROM jtf_rs_resource_extns rsc
   WHERE rsc.resource_id = ll_resource_id;

  rsc_rec rsc_cur%rowtype;


 CURSOR group_dt_cur(l_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE)
      IS
  SELECT grp.start_date_active,
         grp.end_date_active
    FROM jtf_rs_groups_b grp
   WHERE grp.group_id = l_group_id;

  group_dt_rec group_dt_cur%rowtype;

 CURSOR team_dt_cur(l_team_id JTF_RS_TEAMS_B.TEAM_ID%TYPE)
      IS
  SELECT tm.start_date_active,
         tm.end_date_active
    FROM jtf_rs_teams_b tm
   WHERE tm.team_id = l_team_id;

  team_dt_rec team_dt_cur%rowtype;

   --exclusive flag check cursor
  CURSOR c_exclusive_group_check_cur(l_member_id  JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
                                 l_start_date_active  DATE,
                                 L_end_date_active    DATE)
    IS
  SELECT 'X'
      FROM jtf_rs_groups_b G1,
        jtf_rs_groups_b G2,
        jtf_rs_group_members GM1,
        jtf_rs_group_members GM2,
        jtf_rs_group_usages GU1,
        jtf_rs_group_usages GU2,
        jtf_rs_role_relations RR1
/* commented the below line to improve the performance. We are not using this table in the select statement. */
--        jtf_rs_role_relations RR2
      WHERE GM2.group_member_id = l_member_id
        AND G1.group_id = GM1.group_id
        AND G2.group_id = GM2.group_id
        AND nvl(GM1.delete_flag, 'N') <> 'Y'
        AND nvl(GM2.delete_flag, 'N') <> 'Y'
        AND GM1.resource_id = GM2.resource_id
        AND GM1.group_member_id = RR1.role_resource_id
        AND RR1.role_resource_type = 'RS_GROUP_MEMBER'
        AND nvl(RR1.delete_flag, 'N') <> 'Y'
        AND not (((nvl(l_end_date_active,RR1.start_date_active + 1) < RR1.start_date_active OR
                   l_start_date_active > RR1.end_date_active) AND
                   RR1.end_date_active IS NOT NULL)
                 OR ( nvl(l_end_date_active,RR1.start_date_active + 1) < RR1.start_date_active AND
                     RR1.end_date_active IS NULL ))
        AND G2.exclusive_flag = 'Y'
        AND G1.exclusive_flag = 'Y'
        AND GU1.group_id = G1.group_id
        AND GU2.group_id = G2.group_id
        AND GU1.usage = GU2.usage
        AND G1.group_id <> G2.group_id;


  c_exclusive_group_check_rec  c_exclusive_group_check_cur%rowtype;

/*changed + 1 logic */
 --cursor to check for team member dates for resource
 CURSOR res_team_cur(l_resource_id JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
         l_start_date_active  DATE,
         L_end_date_active    DATE ,
         l_role_id           JTF_RS_ROLES_B.ROLE_ID%TYPE )
     IS
  SELECT 'X'
   FROM  jtf_rs_team_members mem,
         jtf_rs_role_relations rlt
   WHERE mem.team_resource_id = l_resource_id
     AND mem.resource_type = 'INDIVIDUAL'
     AND nvl(mem.delete_flag, 'N') <> 'Y'
     AND mem.team_member_id = rlt.role_resource_id
     AND rlt.role_resource_type = 'RS_TEAM_MEMBER'
     AND nvl(rlt.delete_flag, 'N') <> 'Y'
     AND ((l_start_date_active between rlt.start_date_active + 1
                              and nvl(rlt.end_date_active - 1, l_start_date_active +1))
         OR (l_end_date_active between rlt.start_date_active + 1
                              and nvl(rlt.end_date_active - 1, l_end_date_active - 1)))
     AND rlt.role_id = l_role_id;

 res_team_rec res_team_cur%rowtype;

/*changed + 1 logic */
 --cursor to check for group member dates for resource
 CURSOR res_group_cur(l_resource_id JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
         l_start_date_active  DATE,
         L_end_date_active    DATE ,
         l_role_id            JTF_RS_ROLES_B.ROLE_ID%TYPE)
     IS
  SELECT rlt.role_relate_id
   FROM  jtf_rs_group_members mem,
         jtf_rs_role_relations rlt
   WHERE mem.resource_id = l_resource_id
     AND nvl(mem.delete_flag, 'N') <> 'Y'
     AND mem.group_member_id = rlt.role_resource_id
     AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND nvl(rlt.delete_flag, 'N') <> 'Y'
     AND ((l_start_date_active between rlt.start_date_active+1
                              and nvl(rlt.end_date_active - 1, l_start_date_active +1))
         OR (l_end_date_active between rlt.start_date_active+1
                              and nvl(rlt.end_date_active - 1, l_end_date_active - 1)))
     AND rlt.role_id = l_role_id;

  res_group_rec res_group_cur%rowtype;



  cursor get_group_cur(l_role_relate_id number)
     is
   select mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel
   where rel.role_relate_id = l_role_relate_id
     and rel.role_resource_id = mem.group_member_id;


  cursor get_child_cur(l_group_id number)
     is
   select count(*) child_cnt
    from  jtf_rs_grp_relations rel
   connect by related_group_id = prior group_id
     and   nvl(delete_flag, 'N') <> 'Y'
     AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
    start with related_group_id = l_group_id
     and   nvl(delete_flag, 'N') <> 'Y';


    cursor conc_prog_cur
     is
  select description
    from fnd_concurrent_programs_vl
   where concurrent_program_name = 'JTFRSRMG'
     and application_id = 690;

  l_role_type_valid boolean := false;

   BEGIN

    l_start_date_active          := trunc(p_start_date_active);
    l_end_date_active            := trunc(p_end_date_active);
    l_role_relate_id             := p_role_relate_id;
    l_object_version_number      := p_object_version_num;

      --Standard Start of API SAVEPOINT
     SAVEPOINT ROLE_RELATE_SP;

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
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then
             JTF_RS_ROLE_RELATE_CUHK.UPDATE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                               P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then

            JTF_RS_ROLE_RELATE_VUHK.UPDATE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                                P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS) then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;

   /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then

            JTF_RS_ROLE_RELATE_IUHK.UPDATE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                               P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)   then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

  -- end of user hook call






   --fetch the details for the role relate id
  open role_relate_cur(l_role_relate_id);
  fetch role_relate_cur into role_relate_rec;
  close role_relate_cur;

  l_role_resource_type    := role_relate_rec.role_resource_type;
  l_role_resource_id      := role_relate_rec.role_resource_id;
  l_role_id               := role_relate_rec.role_id;
 --Bug8434591
 --Typo error attribute4 , attribute6 values are overwritten by
 --attribute1 value, corrected the code.
  IF(p_start_date_active = FND_API.G_MISS_DATE)
  THEN
     l_start_date_active := role_relate_rec.start_date_active;
  ELSE
      l_start_date_active := p_start_date_active;
  END IF;
  IF(p_end_date_active = FND_API.G_MISS_DATE)
  THEN
     l_end_date_active := role_relate_rec.end_date_active;
  ELSE
      l_end_date_active := p_end_date_active;
  END IF;
  IF(p_attribute1 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute1 := role_relate_rec.attribute1;
  ELSE
      l_attribute1 := p_attribute1;
  END IF;
  IF(p_attribute2= FND_API.G_MISS_CHAR)
  THEN
     l_attribute2 := role_relate_rec.attribute2;
  ELSE
      l_attribute2 := p_attribute2;
  END IF;
  IF(p_attribute3 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute3 := role_relate_rec.attribute3;
  ELSE
      l_attribute3 := p_attribute3;
  END IF;
  IF(p_attribute4 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute4 := role_relate_rec.attribute4;
  ELSE
      l_attribute4 := p_attribute4;
  END IF;
  IF(p_attribute5 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute5 := role_relate_rec.attribute5;
  ELSE
      l_attribute5 := p_attribute5;
  END IF;
  IF(p_attribute6 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute6 := role_relate_rec.attribute6;
  ELSE
      l_attribute6 := p_attribute6;
  END IF;
  IF(p_attribute7 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute7 := role_relate_rec.attribute7;
  ELSE
      l_attribute7 := p_attribute7;
  END IF;
  IF(p_attribute8 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute8 := role_relate_rec.attribute8;
  ELSE
      l_attribute8 := p_attribute8;
  END IF;
  IF(p_attribute9 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute9 := role_relate_rec.attribute9;
  ELSE
      l_attribute9 := p_attribute9;
  END IF;
  IF(p_attribute10 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute10 := role_relate_rec.attribute10;
  ELSE
      l_attribute10 := p_attribute10;
  END IF;
  IF(p_attribute11 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute11 := role_relate_rec.attribute11;
  ELSE
      l_attribute11 := p_attribute11;
  END IF;
  IF(p_attribute12 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute12 := role_relate_rec.attribute12;
  ELSE
      l_attribute12 := p_attribute12;
  END IF;
  IF(p_attribute13 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute13 := role_relate_rec.attribute13;
  ELSE
      l_attribute13 := p_attribute13;
  END IF;
 IF(p_attribute14 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute14 := role_relate_rec.attribute14;
  ELSE
      l_attribute14 := p_attribute14;
  END IF;
 IF(p_attribute15 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute15 := role_relate_rec.attribute15;
  ELSE
      l_attribute15 := p_attribute15;
  END IF;

 IF(p_attribute_category = FND_API.G_MISS_CHAR)
  THEN
     l_attribute_category := role_relate_rec.attribute_category;
  ELSE
      l_attribute_category := p_attribute_category;
  END IF;

  l_delete_flag := role_relate_rec.delete_flag;


  IF(l_start_date_active IS NULL)
  THEN
      l_start_date_active     := role_relate_rec.start_date_active;
  END IF;


   --check start date null
   IF(l_start_date_active is NULL)
   THEN
       fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;



  --check start date less than end date
   IF(l_start_date_active > l_end_date_active)
   THEN

       fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;


   IF(l_role_resource_type = 'RS_TEAM' or
      l_role_resource_type = 'RS_GROUP' or
      l_role_resource_type = 'RS_INDIVIDUAL')
   THEN
     validate_role_type(l_role_id,
                      l_start_date_active,
                      l_end_date_active,
                      l_role_type_valid);

      if (l_role_type_valid = false) then
        fnd_message.set_name ('JTF', 'JTF_RS_ROLE_TYPE_INACTIVE');
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
      end if;
    END IF;


  --l_end_date_active       := role_relate_rec.end_date_active;


  --check whether the start date and end date overlaps any existing start date and end date
  --for the resource type, resource id and role.
   open check_date_cur(l_role_resource_type,
                       l_role_resource_id,
                       l_role_id,
                       l_role_relate_id);
   fetch check_date_cur INTO check_date_rec;
   While(check_date_cur%found)
   loop

      IF((l_start_date_active >= check_date_rec.start_date_active)
         AND ((l_start_date_active <= check_date_rec.end_date_active)
              OR (check_date_rec.end_date_active IS NULL)))
      THEN

         l_date_invalid := TRUE;
      END IF;

     --IF((l_end_date_active between check_date_rec.start_date_active and check_date_rec.end_date_active)
      IF((to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
             between check_date_rec.start_date_active and
                           to_date(to_char(nvl(check_date_rec.end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
         OR (l_end_date_active IS NULL AND
                  check_date_rec.end_date_active IS NULL))
     THEN

         l_date_invalid := TRUE;
      END IF;
      -- added this check as a date range outside of the existing ranges was getting entered
      if(l_start_date_active < check_date_rec.start_date_active
        and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR') >
                   to_date(to_char(nvl(check_date_rec.end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
       THEN
        l_date_invalid := TRUE;
       END IF;

      IF(l_date_invalid)
      THEN
         exit;
       END IF;
       fetch check_date_cur INTO check_date_rec;
   end loop;
   CLOSE check_date_cur;
   IF(l_date_invalid)
   THEN
       fnd_message.set_name ('JTF', 'JTF_RS_DATE_RANGE_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   END IF;

   --end of overlapping date range check



  --valid role for the resource if being entered as a group member and team member
  --check whether team member is resource or group
  IF(l_role_resource_type = 'RS_TEAM_MEMBER')
  THEN
     OPEN team_mem_cur(l_role_resource_id);
     FETCH team_mem_cur INTO l_team_resource_type, l_rsc_id;
     CLOSE team_mem_cur;

  END IF;

  IF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN
     OPEN grp_mem_cur(l_role_resource_id);
     FETCH grp_mem_cur INTO l_rsc_id;
     CLOSE grp_mem_cur;

  END IF;


   --valid role for the resource if being entered as a group member and team member
  IF((l_role_resource_type = 'RS_GROUP_MEMBER') OR
     ((l_role_resource_type = 'RS_TEAM_MEMBER') AND
       (l_team_resource_type = 'INDIVIDUAL')))
  THEN
  --if team member is of type resource or it is group member
  --then check for valid role and st date , end date for the resource
  --in role relations
       open res_role_cur(l_rsc_id,
                        l_role_id  ,
                        l_start_date_active ,
                        l_end_date_active   );
       fetch res_role_cur INTO res_role_rec;
       --close res_role_cur;
       IF(res_role_cur%found)
       THEN
         l_role_valid := TRUE;

       ELSE

          l_role_valid := FALSE;
          fnd_message.set_name ('JTF', 'JTF_RS_ROLE_OR_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
       END IF;
       close res_role_cur;
   ELSIF((l_role_resource_type = 'RS_TEAM_MEMBER') AND
             (l_team_resource_type = 'GROUP'))
   THEN
  --if team member is of type group then check for valid role and st date ,
  --end date for the group in role relations

      open grp_role_cur(l_rsc_id,
                        l_role_id  ,
                        l_start_date_active ,
                        l_end_date_active   );
       fetch grp_role_cur INTO grp_role_rec;
       --close grp_role_cur;
       IF(grp_role_cur%found)
       THEN
         l_role_valid := TRUE;

       ELSE
          l_role_valid := FALSE;
          fnd_message.set_name ('JTF', 'JTF_RS_ROLE_OR_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
       END IF;
       close grp_role_cur;

   END IF;
   -- end of valid role for the resource if being entered as a group member and team member

  --if resource type is group member or team member then check against group and team
  --start date and end date
  IF(l_role_resource_type = 'RS_TEAM_MEMBER')
  THEN
    open team_cur(l_role_resource_id);
    fetch team_cur INTO team_rec;
    close team_cur;
    IF((trunc(team_rec.start_date_active) > trunc(l_start_date_active))
       OR to_date(to_char(nvl(team_rec.end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR') < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

    IF(team_rec.end_date_active is not null AND l_end_date_active is null)
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

  ELSIF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN
    open group_cur(l_role_resource_id);
    fetch group_cur INTO group_rec;
    close group_cur;

    IF((trunc(group_rec.start_date_active) > trunc(l_start_date_active))
       OR to_date(to_char(nvl(group_rec.end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR') < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
    THEN

          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;



    IF(group_rec.end_date_active is not null AND l_end_date_active is null)
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TM_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

    --exclusive flag validation
      open c_exclusive_group_check_cur(l_role_resource_id,
                                    l_start_date_active,
                                    l_end_date_active);

      fetch c_exclusive_group_check_cur into c_exclusive_group_check_rec;
      IF(c_exclusive_group_check_cur%FOUND)
      THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_USAGE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      close c_exclusive_group_check_cur;
  ELSIF(l_role_resource_type = 'RS_INDIVIDUAL')
  THEN

    open rsc_cur(l_role_resource_id);
    fetch rsc_cur INTO rsc_rec;
    close rsc_cur;

    IF((rsc_rec.start_date_active > l_start_date_active)
    --changed by sudarsana 11 feb 2002
       OR (rsc_rec.end_date_active < to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')))
    -- OR (rsc_rec.end_date_active < l_end_date_active))
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_DATE_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

  ELSIF(l_role_resource_type = 'RS_GROUP')
  THEN
    open group_dt_cur(l_role_resource_id);
    fetch group_dt_cur INTO group_dt_rec;
    close group_dt_cur;
    IF((group_dt_rec.start_date_active > l_start_date_active)
      -- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
      --OR (group_dt_rec.end_date_active < l_end_date_active))
      OR (to_date(to_char(nvl(group_dt_rec.end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
                    < (to_date(to_char(nvl(l_end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))))
       THEN
          fnd_message.set_name ('JTF', 'JTF_RS_GRP_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
  ELSIF(l_role_resource_type = 'RS_TEAM')
  THEN
    open team_dt_cur(l_role_resource_id);
    fetch team_dt_cur INTO team_dt_rec;
    close team_dt_cur;
    IF((team_dt_rec.start_date_active > l_start_date_active)
      -- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
      --OR (team_dt_rec.end_date_active < l_end_date_active))
      OR (to_date(to_char(nvl(team_dt_rec.end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
                    < (to_date(to_char(nvl(l_end_date_active,fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))))
       THEN
          fnd_message.set_name ('JTF', 'JTF_RS_TEAM_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

 --if resource type is RS_INDIVIDUAL then check whether the start and end dates do not
 --fall within the start and end dates if this resource is a team member or group member
  IF(l_role_resource_type = 'RS_INDIVIDUAL')
  THEN
    open res_team_cur(l_role_resource_id,
                       l_start_date_active,
                       l_end_date_active,
                       l_role_id);
    fetch res_team_cur INTO res_team_rec;

    If(res_team_cur%found)
    THEN

          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_RES_MEM_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
    close res_team_cur;

    open res_group_cur(l_role_resource_id,
                       l_start_date_active,
                       l_end_date_active,
                       l_role_id);
    fetch res_group_cur INTO res_group_rec;

    If(res_group_cur%found)
    THEN
          fnd_message.set_name ('JTF', 'JTF_RS_RES_MEM_DT_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;
    close res_group_cur;


   -- we also need to check that no group/team member role becomes invalid
   -- because of this change
    validate_indv_role_date(p_role_relate_id => l_role_relate_id,
                   p_role_id        => l_role_id,
                   p_resource_id    => l_role_resource_id,
                   p_old_start_date => role_relate_rec.start_date_active,
                   p_old_end_date   => role_relate_rec.end_date_active,
                   p_new_start_date => l_start_date_active,
                   p_new_end_date   => l_end_date_active,
                   p_valid          => l_valid);

    If NOT(l_valid)
    THEN
          --fnd_message.set_name ('JTF', 'JTF_RS_RES_UPD_DT_ERR');
          --FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
    END IF;

  END IF;

  --call update table handler
   BEGIN

      jtf_rs_role_relations_pkg.lock_row(
        x_role_relate_id => l_role_relate_id,
	x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;

  l_object_version_number := l_object_version_number +1;

   --call audit api for update
  jtf_rs_role_relate_aud_pvt.update_role_relate(
                               P_API_VERSION           => 1.0,
                               P_INIT_MSG_LIST         => p_init_msg_list,
                               P_COMMIT                => null,
                               P_ROLE_RELATE_ID        => l_role_relate_id,
                               P_ROLE_RESOURCE_TYPE    => l_role_resource_type,
                               P_ROLE_RESOURCE_ID      => l_role_resource_id,
                               P_ROLE_ID               => l_role_id,
                               P_START_DATE_ACTIVE     => l_start_date_active,
                               P_END_DATE_ACTIVE       => l_end_date_active,
                               P_OBJECT_VERSION_NUMBER => l_object_version_number,
                               X_RETURN_STATUS         => l_return_status,
                               X_MSG_COUNT             => l_msg_count,
                               X_MSG_DATA              => l_msg_data  );

   IF(l_return_status <>  fnd_api.g_ret_sts_success)
   THEN
          fnd_message.set_name ('JTF', 'JTF_RS_AUDIT_ERR');
          FND_MSG_PUB.add;
	  IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

   END IF;

    /* Calling publish API to raise update resource role relation event. */
    /* added by baianand on 04/09/2003 */

   begin

      jtf_rs_wf_events_pub.update_resource_role_relate
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_role_relate_id            => l_role_relate_id
              ,p_role_resource_type        => l_role_resource_type
              ,p_role_resource_id          => l_role_resource_id
              ,p_role_id                   => l_role_id
              ,p_start_date_active         => l_start_date_active
              ,p_end_date_active           => l_end_date_active
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

   EXCEPTION when others then
      null;
   end;

   /* End of publish API call */

   jtf_rs_role_relations_pkg.update_row(X_ROLE_RELATE_ID         => l_role_relate_id,
                                        X_ATTRIBUTE9             => l_attribute9,
                                        X_ATTRIBUTE10            => l_attribute10,
                                        X_ATTRIBUTE11            => l_attribute11,
                                        X_ATTRIBUTE12            => l_attribute12,
                                        X_ATTRIBUTE13            => l_attribute13,
                                        X_ATTRIBUTE14            => l_attribute14,
                                        X_ATTRIBUTE15            => l_attribute15,
                                        X_ATTRIBUTE_CATEGORY     => l_attribute_category,
                                        X_ROLE_RESOURCE_TYPE     => l_role_resource_type,
                                        X_ROLE_RESOURCE_ID       => l_role_resource_id,
                                        X_ROLE_ID                => l_role_id,
                                        X_START_DATE_ACTIVE      => l_start_date_active,
                                        X_END_DATE_ACTIVE        => l_end_date_active,
                                        X_DELETE_FLAG            => l_delete_flag,
                                        X_OBJECT_VERSION_NUMBER  => l_object_version_number ,
                                        X_ATTRIBUTE2             => l_attribute2,
                                        X_ATTRIBUTE3             => l_attribute3,
                                        X_ATTRIBUTE4             => l_attribute4,
                                        X_ATTRIBUTE5             => l_attribute5,
                                        X_ATTRIBUTE6             => l_attribute6,
                                        X_ATTRIBUTE7             => l_attribute7,
                                        X_ATTRIBUTE8             => l_attribute8,
                                        X_ATTRIBUTE1             => l_attribute1,
                                        X_LAST_UPDATE_DATE       => l_date,
                                        X_LAST_UPDATED_BY        => l_user_id,
                                        X_LAST_UPDATE_LOGIN      => l_login_id )  ;

  P_OBJECT_VERSION_NUM := l_object_version_number;


  IF(l_role_resource_type = 'RS_GROUP_MEMBER')
  THEN

    -- get the group id of the member
        open get_group_cur(l_role_relate_id);
        fetch get_group_cur into l_group_id;
        close get_group_cur;

     --get no of children for the group
       BEGIN
	 open get_child_cur(l_group_id);
	 fetch get_child_cur into l_child_cnt;
	 close get_child_cur;
       EXCEPTION
         WHEN OTHERS THEN
           l_child_cnt := 101;  -- use concurrent program
       END;

     if (nvl(l_child_cnt, 0)  > 100)
     then
       begin
         insert  into jtf_rs_chgd_role_relations
               (role_relate_id,
                role_resource_type,
                role_resource_id,
                role_id,
                start_date_active,
                end_date_active,
                delete_flag,
                operation_flag,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
        values(
                l_role_relate_id,
                l_role_resource_type,
                l_role_resource_id,
                l_role_id,
                l_start_date_active,
                l_end_date_active,
                'N',
                'U',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);

          exception
            when others then
              fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
              fnd_message.set_token('P_SQLCODE',SQLCODE);
              fnd_message.set_token('P_SQLERRM',SQLERRM);
              fnd_message.set_token('P_API_NAME', l_api_name);
              FND_MSG_PUB.add;
	      RAISE fnd_api.g_exc_unexpected_error;


        end;


         --call concurrent program

        begin
                 l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSRMG');

                     open conc_prog_cur;
                     fetch conc_prog_cur into g_name;
                     close conc_prog_cur;
                      fnd_message.set_name ('JTF', 'JTF_RS_CONC_START');
                      fnd_message.set_token('P_NAME',g_name);
                      fnd_message.set_token('P_ID',l_request);
                      FND_MSG_PUB.add;


                 exception when others then
                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      RAISE fnd_api.g_exc_unexpected_error;
        end;

     else



  --call to UPDATE records in jtf_rs_rep_managers
      JTF_RS_REP_MGR_DENORM_PVT.UPDATE_REP_MANAGER
                    ( P_API_VERSION => 1.0,
                      P_INIT_MSG_LIST  => p_init_msg_list,
                      P_COMMIT        => null,
                      P_ROLE_RELATE_ID  => l_role_relate_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

     IF(l_return_status <>  fnd_api.g_ret_sts_success)
     THEN
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


     END IF;
    END IF; -- END OF COUNT CHECK
   END IF;

      -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'A', 'C' ))
   then
             JTF_RS_ROLE_RELATE_CUHK.UPDATE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                                P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if(  l_return_code <>  FND_API.G_RET_STS_SUCCESS) then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;

    /*  	Vertical industry post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then

            JTF_RS_ROLE_RELATE_VUHK.UPDATE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                                P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;


  /*  	Internal post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'UPDATE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then

            JTF_RS_ROLE_RELATE_IUHK.UPDATE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_START_DATE_ACTIVE => P_start_date_active,
                                                               P_END_DATE_ACTIVE => P_end_date_active,
                                                                P_OBJECT_VERSION_NUM => P_OBJECT_VERSION_NUM,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)
              then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;
  -- end of user hook call

 IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'UPDATE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN
 IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'UPDATE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN

      IF (jtf_rs_role_relate_cuhk.ok_to_generate_msg(
            p_role_relate_id => l_role_relate_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_relate_id',
            l_role_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_RRL',
          p_action_code => 'U',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--          x_return_status := fnd_api.g_ret_sts_error;

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





  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ROLE_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

   END  update_resource_role_relate;


  /* Procedure to delete the resource roles. */

  PROCEDURE  delete_resource_role_relate
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2,
   P_COMMIT               IN     VARCHAR2,
   P_ROLE_RELATE_ID       IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN  JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  )IS


  CURSOR  chk_type_cur(l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE)
      IS
   SELECT role_resource_type,
          role_resource_id,
          role_id,
          start_date_active,
          end_date_active,
          object_version_number,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category
     FROM jtf_rs_role_relations
    WHERE role_relate_id = l_role_relate_id;


  chk_type_rec chk_type_cur%rowtype;

  CURSOR chk_grp_cur(l_resource_id       JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
                     l_role_id           JTF_RS_ROLES_B.ROLE_ID%TYPE,
                     l_start_date_active JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                     l_end_date_active   JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE)
      IS
  SELECT 'x'
    FROM  jtf_rs_role_relations rlt,
          jtf_rs_group_members mem
    WHERE mem.resource_id = l_resource_id
      AND rlt.role_resource_id  = mem.group_member_id
      AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
      AND rlt.role_id = l_role_id
      --AND nvl(end_date_active, TRUNC(sysdate) + 1)  > TRUNC(sysdate)
      AND  (start_date_active between l_start_date_active and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
            OR to_date(to_char(nvl(end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR') between l_start_date_active and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
      AND  nvl(rlt.delete_flag, '0') <> 'Y';

 chk_grp_rec chk_grp_cur%rowtype;

  CURSOR chk_team_cur(l_resource_id      JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
                     l_role_id           JTF_RS_ROLES_B.ROLE_ID%TYPE,
                     l_start_date_active JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
                     l_end_date_active   JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE)
      IS
  SELECT 'x'
    FROM  jtf_rs_role_relations rlt,
          jtf_rs_team_members mem
    WHERE mem.team_resource_id = l_resource_id
      AND mem.resource_type <> 'GROUP'
      AND rlt.role_resource_id  = mem.team_member_id
      AND rlt.role_resource_type = 'RS_TEAM_MEMBER'
      AND rlt.role_id = l_role_id
      --AND nvl(rlt.end_date_active, TRUNC(sysdate) + 1)  > TRUNC(sysdate)
      AND  (start_date_active between l_start_date_active and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR')
            OR to_date(to_char(nvl(end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR') between l_start_date_active and to_date(to_char(nvl(l_end_date_active, fnd_api.g_miss_date),'DD-MM-RRRR'),'DD-MM-RRRR'))
      AND  nvl(rlt.delete_flag, '0') <> 'Y';


 chk_team_rec chk_team_cur%rowtype;


  /* Moved the initial assignment of below variable to inside begin */
  l_role_relate_id  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE;

  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_ROLE_RELATE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_date  Date;
  l_g_miss_date Date;
  l_user_id  Number;
  l_login_id  Number;


  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data           VARCHAR2(200);

  L_ATTRIBUTE1		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_ROLE_RELATIONS.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_ROLE_RELATIONS.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_ROLE_RELATIONS.ATTRIBUTE_CATEGORY%TYPE;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

  cursor get_group_cur(l_role_relate_id number)
     is
   select mem.group_id
    from  jtf_rs_group_members mem,
          jtf_rs_role_relations rel
   where rel.role_relate_id = l_role_relate_id
     and rel.role_resource_id = mem.group_member_id;

  l_group_id  number;

  cursor get_child_cur(l_group_id number)
     is
   select count(*) child_cnt
    from  jtf_rs_grp_relations rel
   connect by related_group_id = prior group_id
     and   nvl(delete_flag, 'N') <> 'Y'
     AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
    start with related_group_id = l_group_id
     and   nvl(delete_flag, 'N') <> 'Y';

   l_child_cnt number := 0;
   l_request   number;


    cursor conc_prog_cur
     is
  select description
    from fnd_concurrent_programs_vl
   where concurrent_program_name = 'JTFRSRMG'
     and application_id = 690;
   BEGIN

     l_role_relate_id := p_role_relate_id;

      --Standard Start of API SAVEPOINT
     SAVEPOINT ROLE_RELATE_SP;

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

   -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'C' ))
   then
            JTF_RS_ROLE_RELATE_CUHK.DELETE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'V' ))
   then

           JTF_RS_ROLE_RELATE_VUHK.DELETE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                        P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                        p_data       =>    L_data,
                                                        p_count   =>   L_count,
                                                        P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;

 /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'B', 'I' ))
   then

           JTF_RS_ROLE_RELATE_IUHK.DELETE_RES_ROLE_RELATE_PRE(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                        P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                        p_data       =>    L_data,
                                                        p_count   =>   L_count,
                                                        P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

	     end if;
    end if;
    end if;


  -- end of user hook call


  --check the resource type
  --If resource type is individual then check whether this resource with the same role
  --is existing as a current team/group member

  OPEN chk_type_cur(l_role_relate_id);
  FETCH chk_type_cur INTO chk_type_rec;
  IF chk_type_cur%FOUND THEN

    --assign the attribute1..15 values to the local varialbles
    L_ATTRIBUTE1		:=     chk_type_rec.attribute1;
    L_ATTRIBUTE2		:=     chk_type_rec.attribute2;
    L_ATTRIBUTE3		:=     chk_type_rec.attribute3;
    L_ATTRIBUTE4		:=     chk_type_rec.attribute4;
    L_ATTRIBUTE5		:=     chk_type_rec.attribute5;
    L_ATTRIBUTE6		:=     chk_type_rec.attribute6;
    L_ATTRIBUTE7		:=     chk_type_rec.attribute7;
    L_ATTRIBUTE8		:=     chk_type_rec.attribute8;
    L_ATTRIBUTE9		:=     chk_type_rec.attribute9;
    L_ATTRIBUTE10	        :=     chk_type_rec.attribute10;
    L_ATTRIBUTE11	        :=     chk_type_rec.attribute11;
    L_ATTRIBUTE12	        :=     chk_type_rec.attribute12;
    L_ATTRIBUTE13	        :=     chk_type_rec.attribute13;
    L_ATTRIBUTE14	        :=     chk_type_rec.attribute14;
    L_ATTRIBUTE15	        :=     chk_type_rec.attribute15;
    L_ATTRIBUTE_CATEGORY	:=     chk_type_rec.attribute_category;


    IF chk_type_rec.role_resource_type = 'RS_INDIVIDUAL' THEN
      OPEN chk_team_cur (chk_type_rec.role_resource_id ,
                         chk_type_rec.role_id,
                         chk_type_rec.start_date_active,
                         chk_type_rec.end_date_active);
      FETCH chk_team_cur INTO chk_team_rec;
      IF(chk_team_cur%FOUND) THEN
        fnd_message.set_name ('JTF', 'JTF_RS_MEM_ROLE_EXIST_ERR');
        FND_MSG_PUB.add;
        CLOSE chk_team_cur;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE chk_team_cur;
      OPEN chk_grp_cur (chk_type_rec.role_resource_id ,
                        chk_type_rec.role_id,
                        chk_type_rec.start_date_active,
                        chk_type_rec.end_date_active);
      FETCH chk_grp_cur INTO chk_grp_rec;
      IF(chk_grp_cur%FOUND) THEN
        fnd_message.set_name ('JTF', 'JTF_RS_MEM_ROLE_EXIST_ERR');
        FND_MSG_PUB.add;
        CLOSE chk_grp_cur;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE chk_grp_cur;
    END IF;

  END IF; -- end of chk_type_cur
  CLOSE chk_type_cur;


   --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


  --call audit api for delete
  jtf_rs_role_relate_aud_pvt.delete_role_relate(
                               P_API_VERSION    =>  1.0,
                               P_INIT_MSG_LIST  =>  p_init_msg_list,
                               P_COMMIT         =>  null,
                               P_ROLE_RELATE_ID   =>  l_role_relate_id,
                               X_RETURN_STATUS    =>  l_return_status,
                               X_MSG_COUNT      =>    l_msg_count,
                               X_MSG_DATA      => l_msg_data  );

   IF(l_return_status <>  fnd_api.g_ret_sts_success)
   THEN
          --fnd_message.set_name ('JTF', 'JTF_RS_AUDIT_ERR');
          --FND_MSG_PUB.add;
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;


   --call update api to set the delete flag to 'Y'
  jtf_rs_role_relations_pkg.update_row(
     X_ROLE_RELATE_ID         => l_role_relate_id,
     X_ATTRIBUTE9             => l_attribute9,
     X_ATTRIBUTE10            => l_attribute10,
     X_ATTRIBUTE11            => l_attribute11,
     X_ATTRIBUTE12            => l_attribute12,
     X_ATTRIBUTE13            => l_attribute13,
     X_ATTRIBUTE14            => l_attribute14,
     X_ATTRIBUTE15            => l_attribute15,
     X_ATTRIBUTE_CATEGORY     => l_attribute_category,
     X_ROLE_RESOURCE_TYPE     => chk_type_rec.role_resource_type,
     X_ROLE_RESOURCE_ID       => chk_type_rec.role_resource_id,
     X_ROLE_ID                => chk_type_rec.role_id,
     X_START_DATE_ACTIVE      => chk_type_rec.start_date_active,
     X_END_DATE_ACTIVE        => chk_type_rec.end_date_active,
     X_DELETE_FLAG            => 'Y',
     X_OBJECT_VERSION_NUMBER  => chk_type_rec.object_version_number ,
     X_ATTRIBUTE2             => l_attribute2,
     X_ATTRIBUTE3             => l_attribute3,
     X_ATTRIBUTE4             => l_attribute4,
     X_ATTRIBUTE5             => l_attribute5,
     X_ATTRIBUTE6             => l_attribute6,
     X_ATTRIBUTE7             => l_attribute7,
     X_ATTRIBUTE8             => l_attribute8,
     X_ATTRIBUTE1             => l_attribute1,
     X_LAST_UPDATE_DATE       => l_date,
     X_LAST_UPDATED_BY        => l_user_id,
     X_LAST_UPDATE_LOGIN      => l_login_id );



  IF(chk_type_rec.role_resource_type = 'RS_GROUP_MEMBER')
  THEN
     -- get the group id of the member
        open get_group_cur(l_role_relate_id);
        fetch get_group_cur into l_group_id;
        close get_group_cur;

     --get no of children for the group
       BEGIN
	 open get_child_cur(l_group_id);
	 fetch get_child_cur into l_child_cnt;
	 close get_child_cur;
       EXCEPTION
         WHEN OTHERS THEN
           l_child_cnt := 101;  -- use concurrent program
       END;

     if (nvl(l_child_cnt, 0)  > 100)
     then
       begin
         insert  into jtf_rs_chgd_role_relations
               (role_relate_id,
                role_resource_type,
                role_resource_id,
                role_id,
                start_date_active,
                end_date_active,
                delete_flag,
                operation_flag,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
        values(
                l_role_relate_id,
                chk_type_rec.role_resource_type,
                chk_type_rec.role_resource_id,
                chk_type_rec.role_id,
                chk_type_rec.start_date_active,
                chk_type_rec.end_date_active,
                'Y',
                'D',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);

          exception
            when others then
              fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
              fnd_message.set_token('P_SQLCODE',SQLCODE);
              fnd_message.set_token('P_SQLERRM',SQLERRM);
              fnd_message.set_token('P_API_NAME', l_api_name);
              FND_MSG_PUB.add;
	      RAISE fnd_api.g_exc_unexpected_error;


        end;


         --call concurrent program

        begin
                 l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSRMG');
                     open conc_prog_cur;
                     fetch conc_prog_cur into g_name;
                     close conc_prog_cur;

                      fnd_message.set_name ('JTF', 'JTF_RS_CONC_START');
                      fnd_message.set_token('P_NAME',g_name);
                      fnd_message.set_token('P_ID',l_request);
                      FND_MSG_PUB.add;

                 exception when others then
                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;

                      RAISE fnd_api.g_exc_unexpected_error;
        end;

     else


      --call to delete records in jtf_rs_rep_managers
       JTF_RS_REP_MGR_DENORM_PVT.DELETE_MEMBERS
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_ROLE_RELATE_ID  => l_role_relate_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

        IF(l_return_status <>  fnd_api.g_ret_sts_success)
        THEN
          IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        END IF;
     END IF; -- END OF COUNT CHECK
   END IF;

     -- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'C' ))
   then
           JTF_RS_ROLE_RELATE_CUHK.DELETE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                               P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

    /*  	Verticle industry post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'V' ))
   then


    JTF_RS_ROLE_RELATE_VUHK.DELETE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                        P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                        p_data       =>    L_data,
                                                        p_count   =>   L_count,
                                                        P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;


   /*  Internal post- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_ROLE_RELATE_PVT', 'DELETE_RESOURCE_ROLE_RELATE', 'A', 'I' ))
   then


    JTF_RS_ROLE_RELATE_IUHK.DELETE_RES_ROLE_RELATE_POST(P_ROLE_RELATE_ID  => p_role_relate_id,
                                                        P_OBJECT_VERSION_NUM  =>  p_object_version_num,
                                                        p_data       =>    L_data,
                                                        p_count   =>   L_count,
                                                        P_return_code  =>  l_return_code);
              if (  l_return_code <>  FND_API.G_RET_STS_SUCCESS)  then
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
		   IF l_return_code = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
	     end if;
    end if;
    end if;

  IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'DELETE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN
  IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_ROLE_RELATE_PVT',
      'DELETE_RESOURCE_ROLE_RELATE',
      'M',
      'M')
    THEN

      IF (jtf_rs_role_relate_cuhk.ok_to_generate_msg(
            p_role_relate_id => p_role_relate_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
             SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'role_relate_id',
            p_role_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_RRL',
          p_action_code => 'D',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          --x_return_status := fnd_api.g_ret_sts_error;

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


  -- end of user hook call

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   /* Calling publish API to raise delete resource role relation event. */
   /* added by baianand on 11/09/2002 */

      begin
         jtf_rs_wf_events_pub.delete_resource_role_relate
                (p_api_version               => 1.0
                ,p_init_msg_list             => fnd_api.g_false
                ,p_commit                    => fnd_api.g_false
                ,p_role_relate_id            => l_role_relate_id
                ,x_return_status             => l_return_status
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);

      EXCEPTION when others then
         null;
      end;

   /* End of publish API call */

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO ROLE_RELATE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ROLE_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

 END delete_resource_role_relate;

END jtf_rs_role_relate_pvt;

/
