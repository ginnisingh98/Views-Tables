--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_RELATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_RELATE_PVT" AS
  /* $Header: jtfrsvfb.pls 120.0 2005/05/11 08:22:58 appldev ship $ */

  /*****************************************************************************************
   This is a private API that caller will invoke.
   It provides procedures for managing resource group relations, like
   create, update and delete resource group relations from other modules.
   Its main procedures are as following:
   Create Resource Group Relate
   Update Resource Group Relate
   Delete Resource Group Relate
   All bUsiness logic validations are done through this API
   ******************************************************************************************/

   G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_GROUP_RELATE_PVT';
   G_NAME             VARCHAR2(200);

  /* Procedure to create the resource group relation
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RELATED_GROUP_ID     IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RELATION_TYPE        IN   JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
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
   X_GROUP_RELATE_ID      OUT NOCOPY  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE
  )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP_RELATE';
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

  l_GROUP_ID            JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE          := p_group_id;
  l_RELATED_GROUP_ID    JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE          := p_related_group_id;
  l_RELATION_TYPE       JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE     := p_relation_type;
  l_start_date_active   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE := p_start_date_active;
  l_end_date_active     JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   := p_end_date_active;
  l_temp_end_date_active     JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE  ;
  l_group_relate_id     JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE;

  l_g_miss_date date := to_date(to_char(fnd_api.g_miss_date,'DD-MM-RRRR'),'DD-MM-RRRR') ;

 --CHECK THIS CURSOR FOR VALIDITY OF DATES

 CURSOR check_overlap_cur(l_group_id  JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE,
                        l_start_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
                        l_end_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE)
  IS
  SELECT  'X'
    FROM  jtf_rs_grp_relations rel
   WHERE  rel.group_id = l_group_id
     AND  NVL(rel.delete_flag,'N') <> 'Y'
     AND  rel.relation_type = 'PARENT_GROUP'
     AND  ((l_start_date_active  between rel.start_date_active and
                                           nvl(rel.end_date_active,l_start_date_active+1))
        OR (l_end_date_active between rel.start_date_active
                                          and nvl(rel.end_date_active,l_end_date_active))
        OR ((l_start_date_active <= rel.start_date_active)
                          AND (l_end_date_active >= rel.end_date_active
                                          OR l_end_date_active IS NULL  )));
                                          --OR rel.end_date_active IS NULL))) ;

    /*((l_end_date_active >= rel.start_date_active
                AND l_start_date_active <=  rel.end_date_active
           AND rel.end_date_active is not null)
         OR ( l_end_date_active >= rel.start_date_active
             AND rel.end_date_active IS NULL));*/

  check_overlap_rec check_overlap_cur%ROWTYPE;

  CURSOR check_group_dt_cur(l_group_id  JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE ,
                          l_start_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
                        l_end_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE)
  IS
  SELECT  'X'
    FROM  jtf_rs_groups_b grp
   WHERE  grp.group_id = l_group_id
   -- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
--    AND   l_start_date_active >= grp.start_date_active
--    AND   ((grp.end_date_active IS NULL)
--            OR (grp.end_date_active >= nvl(l_end_date_active,grp.end_date_active)));
    AND   trunc(l_start_date_active) between trunc(grp.start_date_active)
          and nvl(trunc(grp.end_date_active),l_g_miss_date)
    AND   nvl(trunc(l_end_date_active),l_g_miss_date)
          between trunc(l_start_date_active)
          and nvl(trunc(grp.end_date_active),l_g_miss_date);

  check_group_dt_rec  check_group_dt_cur%rowtype;


  CURSOR check_dates_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE ,
                     l_related_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE )
      IS
     SELECT 'X'
   FROM  jtf_rs_groups_b g1
         ,jtf_rs_groups_b g2
   WHERE g1.group_id = l_group_id
     AND g2.group_id = l_related_group_id
     AND ((g1.start_date_active <= g2.end_date_active and g2.end_date_active <> NULL)
          or ((g2.end_date_active IS NULL) AND (g1.end_date_active <> NULL) AND
                                  (g1.end_date_active >= g2.start_date_active))
          OR((g2.end_date_active IS NULL) AND (g1.end_date_active IS NULL)));

  check_dates_rec check_dates_cur%rowtype;

--cursor for cyclic dependency check
  cursor dep_cur(L_GROUP_ID number,
                 l_related_group_id  number,
                 l_start_date_active  date,
                 l_end_date_active    date)
      is
   select 'x'
    from  jtf_rs_groups_denorm
   where  parent_group_id = l_group_id
     and  group_id        = l_related_group_id
    and (  ( (l_start_date_active >= start_date_active)
             AND ((l_start_date_active <= end_date_active)
                  OR (end_date_active IS NULL))
           )
          OR (
                  (l_end_date_active between start_date_active and nvl(end_date_active,l_g_miss_date))
               OR ((nvl(l_end_date_active,start_date_active) >= start_date_active)
                    AND  (end_date_active IS NULL))
             --  OR (nvl(l_end_date_active,sysdate) <= end_date_active)
             )
          OR (
               (l_start_date_active <= start_date_active)
               AND
               (nvl(l_end_date_active,l_g_miss_date) >= nvl(end_date_active,l_g_miss_date))
             )
        );


  dep_rec dep_cur%rowtype;


 CURSOR seq_cur
     IS
 SELECT jtf_rs_grp_relations_s.nextval
   FROM dual;


 CURSOR parent_count_cur(l_group_id number)
    IS
 SELECT count(*) par_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.group_id = prior related_group_id
   and nvl(delete_flag, 'N') <> 'Y'
   and  rel.related_group_id <> l_group_id
   AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';


 CURSOR child_count_cur(l_group_id number)
    IS
 SELECT count(*) par_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.related_group_id = prior group_id
   and nvl(delete_flag, 'N') <> 'Y'
   and  rel.group_id <> l_group_id
   AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.related_group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';

  l_parent number;
  l_child number;
  l_request number;

 cursor conc_prog_cur
    is
 select description
   from fnd_concurrent_programs_vl
 where  concurrent_program_name = 'JTFRSDEN'
  and  application_id = 690;


  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT GROUP_RELATE_SP;

   x_return_status := fnd_api.g_ret_sts_success;
   l_return_status := fnd_api.g_ret_sts_success;

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
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then


            JTF_RS_GROUP_RELATE_CUHK.CREATE_RES_GROUP_RELATE_PRE(P_GROUP_ID         => p_group_id,
                                                               P_RELATED_GROUP_ID     => p_related_group_id,
                                                               P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then

                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then

            JTF_RS_GROUP_RELATE_VUHK.CREATE_RES_GROUP_RELATE_PRE(P_GROUP_ID         => p_group_id,
                                                               P_RELATED_GROUP_ID     => p_related_group_id,
                                                               P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

 /*  	Internal pre- processing section  -  mandatory     */

   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then

            JTF_RS_GROUP_RELATE_IUHK.CREATE_RES_GROUP_RELATE_PRE(P_GROUP_ID         => p_group_id,
                                                               P_RELATED_GROUP_ID     => p_related_group_id,
                                                               P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

  -- end of user hook call

  l_start_date_active := trunc(l_start_date_active);
  l_end_date_active := trunc(l_end_date_active);
  --call default date validation utl
  JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(l_start_date_active,
                                        l_end_date_active,
                                        l_return_status);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_error;
     RAISE fnd_api.g_exc_error;
  END IF;



 --check whether the same set of child and parent group have overlapping records for the same
 --time period if relation_type = PARENT_GROUP
 IF (l_relation_type='PARENT_GROUP')
 THEN
    IF  (l_end_date_active is null) THEN
      l_temp_end_date_active := to_date(to_char(fnd_api.g_miss_date,'dd-MM-RRRR'),'dd-MM-RRRR');
      --l_temp_end_date_active := to_date('31-DEC-4712','dd-MM-RRRR');
    ELSE l_temp_end_date_active := l_end_date_active;
    END IF;
    OPEN check_overlap_cur(l_group_id,
                        l_start_date_active,
                        l_temp_end_date_active);

    FETCH check_overlap_cur INTO check_overlap_rec;

    IF(check_overlap_cur%FOUND)
    THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_RS_GRP_REL_OVERLAP');
         FND_MSG_PUB.add;
         RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE check_overlap_cur;

  END IF;

  --dates within child group dates
  OPEN  check_group_dt_cur(l_group_id,
                           l_start_date_active,
                           l_end_date_active);
  FETCH check_group_dt_cur INTO check_group_dt_rec;
  IF(check_group_dt_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CHILD_GRP_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_group_dt_cur;

   --dates within related group dates
  OPEN  check_group_dt_cur(l_related_group_id,
                           l_start_date_active,
                           l_end_date_active);
  FETCH check_group_dt_cur INTO check_group_dt_rec;
  IF(check_group_dt_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_RELATED_GRP_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_group_dt_cur;

  --check that child group dates are within the related group dates
 /* OPEN check_dates_cur(l_group_id,
                       l_related_group_id);
  FETCH check_dates_cur INTO check_dates_rec;

  IF(check_dates_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CHILD_REL_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_dates_cur;*/

 --check for cyclic dependency
  open dep_cur(p_group_id,
               p_related_group_id,
               p_start_date_active ,
               p_end_date_active );
  fetch dep_cur into dep_rec;
  if(dep_cur%found)
  then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CYCLIC_DEP_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
   end if;
  close dep_cur;



 --call to generate the next id
 OPEN seq_cur;
 FETCH seq_cur INTO l_group_relate_id;
 CLOSE seq_cur;

 --call audit api

 JTF_RS_GROUP_RELATE_AUD_PVT.insert_group_relate(
       P_API_VERSION           => 1.0,
       P_INIT_MSG_LIST         => p_init_msg_list,
       P_COMMIT                => null,
       P_GROUP_RELATE_ID       => l_group_relate_id,
       P_GROUP_ID              => l_group_id,
       P_RELATED_GROUP_ID      => l_related_group_id,
       P_RELATION_TYPE          => l_relation_type,
       P_START_DATE_ACTIVE     => l_start_date_active,
       P_END_DATE_ACTIVE       => l_end_date_active,
       P_OBJECT_VERSION_NUMBER => 1.0,
       X_RETURN_STATUS         => l_return_status,
       X_MSG_COUNT             => l_msg_count,
       X_MSG_DATA              => l_msg_data);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;


 --call table handler to insert record
 jtf_rs_grp_relations_pkg.insert_row(
                  X_ROWID           => l_rowid,
                  X_GROUP_RELATE_ID => l_group_relate_id,
                  X_GROUP_ID           => l_group_id,
                  X_RELATED_GROUP_ID    => l_related_group_id,
                  X_RELATION_TYPE        => l_relation_type,
                  X_START_DATE_ACTIVE    => l_start_date_active,
                  X_END_DATE_ACTIVE       => l_end_date_active,
                  X_DELETE_FLAG           => 'N',
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
                  X_ATTRIBUTE1            => p_attribute1,
                  X_CREATION_DATE        => l_date,
                  X_CREATED_BY           => l_user_id,
                  X_LAST_UPDATE_DATE     => l_date,
                  X_LAST_UPDATED_BY      => l_user_id,
                  X_LAST_UPDATE_LOGIN    => l_login_id); --call to insert records in jtf_rs_groups_denorm
   IF(l_relation_type = 'PARENT_GROUP')
   THEN

    l_parent := 0;
    l_child := 0;
    BEGIN
      OPEN parent_count_cur(l_group_id);
      FETCH parent_count_cur INTO l_parent;
      CLOSE parent_count_cur;

      OPEN child_count_cur(l_group_id);
      FETCH child_count_cur INTO l_child;
      CLOSE child_count_cur;
    EXCEPTION
      WHEN OTHERS THEN
        -- use concurrent program
        l_parent := 10;
        l_child := 10;
    END;

     IF (l_parent < 1) then l_parent := 1; end if;
     IF (l_child < 1) then l_child := 1; end if;

      IF(l_parent * l_child > 50)
      THEN
       begin
        insert into jtf_rs_chgd_grp_relations
               (GROUP_RELATE_ID,
                GROUP_ID       ,
                 RELATED_GROUP_ID,
               RELATION_TYPE  ,
               START_DATE_ACTIVE,
               END_DATE_ACTIVE,
               OPERATION_FLAG,
               CREATED_BY    ,
               CREATION_DATE  ,
               LAST_UPDATED_BY ,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN)
         values(l_group_relate_id,
                p_group_id,
                p_related_group_id,
                p_relation_type,
                p_start_date_active,
                p_end_date_active,
                'I',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);


               --call concurrent program

              begin
                 l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSDEN');
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
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;
              end;
              exception when others then

                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

        end;

     ELSE

       JTF_RS_GROUP_DENORM_PVT.INSERT_GROUPS
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_GROUP_ID        => l_group_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

       IF(l_return_status <>  fnd_api.g_ret_sts_success)
       THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_GRP_DENORM_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

       END IF;


     --call to insert records in jtf_rs_rep_managers
    -- this call has moved to groups denorm
    /*  JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_RELATIONS
                    ( P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => p_init_msg_list,
                      P_COMMIT           => null,
                      P_GROUP_RELATE_ID  => l_group_relate_id,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data);

     IF(l_return_status <>  fnd_api.g_ret_sts_success)
     THEN

          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_REP_MGR_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

      END IF; */
    END IF; -- end of count check
   END IF;


  -- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
             JTF_RS_GROUP_RELATE_CUHK.CREATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => l_group_relate_id,
								  P_GROUP_ID         => p_group_id,
                                                                  P_RELATED_GROUP_ID     => p_related_group_id,
                                                                 P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry post- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then

             JTF_RS_GROUP_RELATE_VUHK.CREATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => l_group_relate_id,
                                                                  P_GROUP_ID         => p_group_id,
                                                                  P_RELATED_GROUP_ID     => p_related_group_id,
                                                                  P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    l_msg_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

   /* Internal post- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'CREATE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then

             JTF_RS_GROUP_RELATE_IUHK.CREATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => l_group_relate_id,
                                                                  P_GROUP_ID         => p_group_id,
                                                                  P_RELATED_GROUP_ID     => p_related_group_id,
                                                                  P_RELATION_TYPE      => p_relation_type,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               p_data       =>    l_msg_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

  -- end of user hook call




  x_group_relate_id := l_group_relate_id;

   IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'CREATE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN
   IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'CREATE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN

    IF (jtf_rs_group_relate_cuhk.ok_to_generate_msg(
            p_group_relate_id => l_group_relate_id,
            x_return_status => x_return_status) )
    THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
         SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_relate_id',
          l_group_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_GRL',
          p_action_code => 'I',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
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

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_relate_sp;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_relate_sp;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_relate_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END create_resource_group_relate;


  /* Procedure to update the resource group relation
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
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
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP_RELATE';
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


  l_GROUP_ID              JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE;
  l_RELATED_GROUP_ID      JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE  ;
  l_RELATION_TYPE         JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE  ;
  l_start_date_active     JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE ;
  l_end_date_active       JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE  ;
  l_temp_end_date_active     JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE  ;
  l_object_version_number JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE;
  l_delete_flag           JTF_RS_GRP_RELATIONS.DELETE_FLAG%TYPE;

  l_group_relate_id       JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE := p_group_relate_id;

  l_g_miss_date date := to_date(to_char(fnd_api.g_miss_date,'DD-MM-RRRR'),'DD-MM-RRRR') ;

  L_ATTRIBUTE1		     JTF_RS_GRP_RELATIONS.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_GRP_RELATIONS.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_GRP_RELATIONS.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_GRP_RELATIONS.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_GRP_RELATIONS.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_GRP_RELATIONS.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_GRP_RELATIONS.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_GRP_RELATIONS.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_GRP_RELATIONS.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_GRP_RELATIONS.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_GRP_RELATIONS.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_GRP_RELATIONS.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_GRP_RELATIONS.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_GRP_RELATIONS.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_GRP_RELATIONS.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_GRP_RELATIONS.ATTRIBUTE_CATEGORY%TYPE;



  CURSOR grp_rel_cur(l_group_relate_id     JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE )
      IS
  SELECT group_id,
         related_group_id,
         start_date_active,
         end_date_active,
         relation_type,
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
   FROM  jtf_rs_grp_relations
  WHERE  group_relate_id = l_group_relate_id;

 grp_rel_rec grp_rel_cur%rowtype;



  CURSOR check_overlap_cur(l_group_id  JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE ,
                        l_start_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
                        l_end_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
                        l_group_relate_id JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE)
  IS
  SELECT  'X'
    FROM  jtf_rs_grp_relations rel
   WHERE  rel.group_relate_id <> l_group_relate_id
     AND  rel.group_id = l_group_id
     AND  NVL(rel.delete_flag,'N') <> 'Y'
     AND  rel.relation_type = 'PARENT_GROUP'
     AND  rel.group_relate_id <> p_group_relate_id
     AND  ((l_start_date_active  between rel.start_date_active and
                                           nvl(rel.end_date_active,l_start_date_active+1))
        OR (l_end_date_active between rel.start_date_active
                                          and nvl(rel.end_date_active,l_end_date_active))
        OR ((l_start_date_active <= rel.start_date_active)
                          AND (l_end_date_active >= rel.end_date_active
                                          OR l_end_date_active IS NULL )));
                                        --  OR rel.end_date_active IS NULL)));

  check_overlap_rec check_overlap_cur%ROWTYPE;

  CURSOR check_group_dt_cur(l_group_id  JTF_RS_GRP_RELATIONS.GROUP_ID%TYPE ,
                          l_start_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
                        l_end_date_active JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE)
  IS
  SELECT  'X'
    FROM  jtf_rs_groups_b grp
   WHERE  grp.group_id = l_group_id
-- changed by nsinghai 20 May 2002 to handle null value of l_end_date_active
--    AND   l_start_date_active >= grp.start_date_active
--    AND   ((grp.end_date_active IS NULL)
--            OR (grp.end_date_active >= nvl(l_end_date_active,grp.end_date_active)));
    AND   trunc(l_start_date_active) between trunc(grp.start_date_active)
          and nvl(trunc(grp.end_date_active),l_g_miss_date)
    AND   nvl(trunc(l_end_date_active),l_g_miss_date)
          between trunc(l_start_date_active)
          and nvl(trunc(grp.end_date_active),l_g_miss_date);

  check_group_dt_rec  check_group_dt_cur%rowtype;


  CURSOR check_dates_cur(l_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE ,
                     l_related_group_id  JTF_RS_GROUPS_B.GROUP_ID%TYPE )
      IS
  SELECT 'X'
   FROM  jtf_rs_groups_b g1
         ,jtf_rs_groups_b g2
   WHERE g1.group_id = l_group_id
     AND g2.group_id = l_related_group_id
     AND ((g1.start_date_active <= g2.end_date_active and g2.end_date_active <> NULL)
          or ((g2.end_date_active IS NULL) AND (g1.end_date_active <> NULL) AND
                                  (g1.end_date_active >= g2.start_date_active))
          OR((g2.end_date_active IS NULL) AND (g1.end_date_active IS NULL)));

  check_dates_rec check_dates_cur%rowtype;


  --cursor for cyclic dependency check
  cursor dep_cur(L_GROUP_ID number,
                 l_related_group_id  number,
                 l_start_date_active  date,
                 l_end_date_active    date)
      is
   select 'x'
    from  jtf_rs_groups_denorm
   where  parent_group_id = l_group_id
     and  group_id        = l_related_group_id
     and (  ( (l_start_date_active >= start_date_active)
             AND ((l_start_date_active <= end_date_active)
                  OR (end_date_active IS NULL))
           )
          OR (
                  (l_end_date_active between start_date_active and nvl(end_date_active,l_g_miss_date))
               OR ((nvl(l_end_date_active,start_date_active) >= start_date_active)
                    AND  (end_date_active IS NULL))
             --  OR (nvl(l_end_date_active,sysdate) <= end_date_active)
             )
          OR (
               (l_start_date_active <= start_date_active)
               AND
               (nvl(l_end_date_active,l_g_miss_date) >= nvl(end_date_active,l_g_miss_date))
             )
        );

  dep_rec   dep_cur%rowtype;

CURSOR parent_count_cur(l_group_id number)
    IS
 SELECT count(*) par_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.group_id = prior related_group_id
   and nvl(delete_flag, 'N') <> 'Y'
   and  rel.related_group_id <> l_group_id
   AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';


 CURSOR child_count_cur(l_group_id number)
    IS
 SELECT count(*) par_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.related_group_id = prior group_id
   and nvl(delete_flag, 'N') <> 'Y'
   and  rel.group_id <> l_group_id
   AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.related_group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';

  l_parent number;
  l_child number;
  l_request number;



 cursor conc_prog_cur
    is
 select description
   from fnd_concurrent_programs_vl
 where  concurrent_program_name = 'JTFRSDEN'
  and  application_id = 690;



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

   -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then
             JTF_RS_GROUP_RELATE_CUHK.UPDATE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID         => p_group_relate_id,
                                                                 P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then

           JTF_RS_GROUP_RELATE_VUHK.UPDATE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID  => p_group_relate_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE    => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               => l_data,
                                                               p_count              => l_count,
                                                               P_return_code        => l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Internal pre- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then

           JTF_RS_GROUP_RELATE_IUHK.UPDATE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID  => p_group_relate_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE    => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               => l_data,
                                                               p_count              => l_count,
                                                               P_return_code        => l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

  -- end of user hook call


   --assign the values to the local variables
   OPEN grp_rel_cur(l_group_relate_id);
   FETCH grp_rel_cur INTO grp_rel_rec;
   CLOSE grp_rel_cur;

   l_group_id := grp_rel_rec.group_id;

   l_related_group_id := grp_rel_rec.related_group_id;
   l_delete_flag := grp_rel_rec.delete_flag;
   l_object_version_number := grp_rel_rec.object_version_number;
   l_relation_type := grp_rel_rec.relation_type;


  IF(p_start_date_active = FND_API.G_MISS_DATE)
  THEN
     l_start_date_active := grp_rel_rec.start_date_active;
  ELSE
      l_start_date_active := p_start_date_active;
  END IF;
  IF(p_end_date_active = FND_API.G_MISS_DATE)
  THEN
     l_end_date_active := grp_rel_rec.end_date_active;
  ELSE
      l_end_date_active := p_end_date_active;
  END IF;
  IF(p_attribute1 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute1 := grp_rel_rec.attribute1;
  ELSE
      l_attribute1 := p_attribute1;
  END IF;
  IF(p_attribute2= FND_API.G_MISS_CHAR)
  THEN
     l_attribute2 := grp_rel_rec.attribute2;
  ELSE
      l_attribute2 := p_attribute2;
  END IF;
  IF(p_attribute3 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute3 := grp_rel_rec.attribute3;
  ELSE
      l_attribute3 := p_attribute3;
  END IF;
  IF(p_attribute4 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute4 := grp_rel_rec.attribute1;
  ELSE
      l_attribute4 := p_attribute4;
  END IF;
  IF(p_attribute5 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute5 := grp_rel_rec.attribute5;
  ELSE
      l_attribute5 := p_attribute5;
  END IF;
  IF(p_attribute6 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute6 := grp_rel_rec.attribute1;
  ELSE
      l_attribute6 := p_attribute6;
  END IF;
  IF(p_attribute7 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute7 := grp_rel_rec.attribute7;
  ELSE
      l_attribute7 := p_attribute7;
  END IF;
  IF(p_attribute8 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute8 := grp_rel_rec.attribute8;
  ELSE
      l_attribute8 := p_attribute8;
  END IF;
  IF(p_attribute9 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute9 := grp_rel_rec.attribute9;
  ELSE
      l_attribute9 := p_attribute9;
  END IF;
  IF(p_attribute10 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute10 := grp_rel_rec.attribute10;
  ELSE
      l_attribute10 := p_attribute10;
  END IF;
  IF(p_attribute11 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute11 := grp_rel_rec.attribute11;
  ELSE
      l_attribute11 := p_attribute11;
  END IF;
  IF(p_attribute12 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute12 := grp_rel_rec.attribute12;
  ELSE
      l_attribute12 := p_attribute12;
  END IF;
  IF(p_attribute13 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute13 := grp_rel_rec.attribute13;
  ELSE
      l_attribute13 := p_attribute13;
  END IF;
 IF(p_attribute14 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute14 := grp_rel_rec.attribute14;
  ELSE
      l_attribute14 := p_attribute14;
  END IF;
 IF(p_attribute15 = FND_API.G_MISS_CHAR)
  THEN
     l_attribute15 := grp_rel_rec.attribute15;
  ELSE
      l_attribute15 := p_attribute15;
  END IF;

 IF(p_attribute_category = FND_API.G_MISS_CHAR)
  THEN
     l_attribute_category := grp_rel_rec.attribute_category;
  ELSE
      l_attribute_category := p_attribute_category;
  END IF;

-- do the validations
  l_start_date_active := trunc(l_start_date_active);
  l_end_date_active := trunc(l_end_date_active);

  JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(l_start_date_active,
                                        l_end_date_active,
                                        l_return_status);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_error;
     RAISE fnd_api.g_exc_error;
  END IF;



 --check whether the same set of child and parent group have overlapping records for the same
 --time period if relation_type = PARENT_GROUP
 IF (l_relation_type='PARENT_GROUP')
 THEN
    IF (l_end_date_active is null) THEN
      l_temp_end_date_active := to_date(to_char(fnd_api.g_miss_date,'dd-MM-RRRR'),'dd-MM-RRRR');
      --l_temp_end_date_active := to_date('31-DEC-4712','dd-MM-RRRR');
    ELSE l_temp_end_date_active := l_end_date_active;
    END IF;

    OPEN check_overlap_cur(l_group_id,
                        l_start_date_active,
                        l_end_date_active,
                        l_group_relate_id);

    FETCH check_overlap_cur INTO check_overlap_rec;

    IF(check_overlap_cur%FOUND)
    THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_RS_GRP_REL_OVERLAP');
         FND_MSG_PUB.add;
         RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE check_overlap_cur;

  END IF;


   --check for cyclic dependency
  IF (l_relation_type='PARENT_GROUP')
  THEN
    open dep_cur(l_group_id,
               l_related_group_id,
               l_start_date_active ,
               l_end_date_active );
    fetch dep_cur into dep_rec;
    if(dep_cur%found)
    then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CYCLIC_DEP_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;
     end if;
     close dep_cur;
  END IF;


  --dates within child group dates
  OPEN  check_group_dt_cur(l_group_id,
                           l_start_date_active,
                           l_end_date_active);

  FETCH check_group_dt_cur INTO check_group_dt_rec;
  IF(check_group_dt_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CHILD_GRP_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_group_dt_cur;

   --dates within related group dates
  OPEN  check_group_dt_cur(l_related_group_id,
                           l_start_date_active,
                           l_end_date_active);
  FETCH check_group_dt_cur INTO check_group_dt_rec;
  IF(check_group_dt_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_RELATED_GRP_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_group_dt_cur;

  --check that child group dates are within the related group dates
 /* OPEN check_dates_cur(l_group_id,
                       l_related_group_id);
  FETCH check_dates_cur INTO check_dates_rec;
  IF(check_dates_cur%NOTFOUND)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_CHILD_REL_DT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;
  CLOSE check_dates_cur;*/



  --call lock row for updation
  BEGIN

      jtf_rs_grp_relations_pkg.lock_row(
        x_group_relate_id => l_group_relate_id,
	x_object_version_number => p_object_version_num
      );


    EXCEPTION

	 WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;


  l_object_version_number := p_object_version_num +1;

  --call update table handler
  --call audit api

 JTF_RS_GROUP_RELATE_AUD_PVT.update_group_relate(
       P_API_VERSION           => 1.0,
       P_INIT_MSG_LIST         => p_init_msg_list,
       P_COMMIT                => null,
       P_GROUP_RELATE_ID       => l_group_relate_id,
       P_GROUP_ID              => l_group_id,
       P_RELATED_GROUP_ID      => l_related_group_id,
       P_RELATION_TYPE          => l_relation_type,
       P_START_DATE_ACTIVE     => l_start_date_active,
       P_END_DATE_ACTIVE       => l_end_date_active,
       P_OBJECT_VERSION_NUMBER => l_object_version_number,
       X_RETURN_STATUS         => l_return_status,
       X_MSG_COUNT             => l_msg_count,
       X_MSG_DATA              => l_msg_data);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;





  jtf_rs_grp_relations_pkg.update_row(
         X_GROUP_RELATE_ID    => l_group_relate_id,
         X_GROUP_ID           => l_group_id,
         X_RELATED_GROUP_ID   => l_related_group_id,
         X_RELATION_TYPE      => l_relation_type,
         X_START_DATE_ACTIVE  => l_start_date_active,
         X_END_DATE_ACTIVE      => l_end_date_active,
         X_DELETE_FLAG          => l_delete_flag,
         X_OBJECT_VERSION_NUMBER => l_object_version_number,
         X_ATTRIBUTE2         =>  l_attribute2,
         X_ATTRIBUTE3         =>  l_attribute3,
         X_ATTRIBUTE4         =>  l_attribute4,
         X_ATTRIBUTE5         =>  l_attribute5,
         X_ATTRIBUTE6         =>   l_attribute6,
         X_ATTRIBUTE7         =>   l_attribute7,
         X_ATTRIBUTE8         => l_attribute8,
         X_ATTRIBUTE9         => l_attribute9,
         X_ATTRIBUTE10        => l_attribute10,
         X_ATTRIBUTE11        => l_attribute11,
         X_ATTRIBUTE12        => l_attribute12,
         X_ATTRIBUTE13        => l_attribute13,
         X_ATTRIBUTE14        =>  l_attribute14,
         X_ATTRIBUTE15        => l_attribute15,
         X_ATTRIBUTE_CATEGORY => l_attribute_category,
         X_ATTRIBUTE1        =>  l_attribute1,
         X_LAST_UPDATE_DATE   => l_date,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN    => l_login_id);


   p_object_version_num := l_object_version_number;



   --call to insert records in jtf_rs_groups_denorm FOR UPDATION EFFECT
   IF(l_relation_type = 'PARENT_GROUP')
   THEN
     IF (l_start_date_active <> grp_rel_rec.start_date_active
        OR nvl(l_end_date_active, fnd_api.g_miss_date) <>
                         nvl(grp_rel_rec.end_date_active, fnd_api.g_miss_date)
        OR l_relation_type   <> grp_rel_rec.relation_type)
     THEN
    l_parent := 0;
    l_child := 0;
         BEGIN
	   OPEN parent_count_cur(l_group_id);
	   FETCH parent_count_cur INTO l_parent;
	   CLOSE parent_count_cur;

	   OPEN child_count_cur(l_group_id);
	   FETCH child_count_cur INTO l_child;
	   CLOSE child_count_cur;
	 EXCEPTION
	   WHEN OTHERS THEN
             -- use concurrent program
	     l_parent := 10;
	     l_child := 10;
	 END;

         IF (l_parent < 1) then l_parent := 1; end if;
         IF (l_child < 1) then l_child := 1; end if;
         IF(l_parent * l_child > 50)
         THEN
           begin
            insert into jtf_rs_chgd_grp_relations
               (GROUP_RELATE_ID,
                GROUP_ID       ,
                 RELATED_GROUP_ID,
               RELATION_TYPE  ,
               START_DATE_ACTIVE,
               END_DATE_ACTIVE,
               OPERATION_FLAG,
               CREATED_BY    ,
               CREATION_DATE  ,
               LAST_UPDATED_BY ,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN)
            values(p_group_relate_id,
                l_group_id,
                l_related_group_id,
                l_relation_type,
                l_start_date_active,
                l_end_date_active,
                'U',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);

              exception when others then
                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count,  p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

             end;


             begin

                    l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSDEN');
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
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count,  p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

            end;
            ELSE
              JTF_RS_GROUP_DENORM_PVT.UPDATE_GROUPS
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_GROUP_ID        => l_group_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

       IF(l_return_status <>  fnd_api.g_ret_sts_success)
       THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_GRP_DENORM_ERR');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

       END IF;
     END IF; --end of count check
    else
       null;
    END IF; -- check of anything has changed at all
   END IF;



  --end of update
-- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
           JTF_RS_GROUP_RELATE_CUHK.UPDATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                               P_START_DATE_ACTIVE   => p_start_date_active,
                                                               P_END_DATE_ACTIVE     => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM  => p_object_version_num,
                                                               p_data                => L_data,
                                                               p_count               => l_count,
                                                               P_return_code         => l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry post- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then
          JTF_RS_GROUP_RELATE_VUHK.UPDATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE    => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               =>    L_data,
                                                               p_count              =>   L_count,
                                                               P_return_code        =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

   /* Internal post- processing section  -  mandatory     */

  if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then
  if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'UPDATE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then
          JTF_RS_GROUP_RELATE_IUHK.UPDATE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                               P_START_DATE_ACTIVE  => p_start_date_active,
                                                               P_END_DATE_ACTIVE    => p_end_date_active,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               =>    L_data,
                                                               p_count              =>   L_count,
                                                               P_return_code        =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

  -- end of user hook call
  IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'UPDATE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN
  IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'UPDATE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN

      IF (jtf_rs_group_relate_cuhk.ok_to_generate_msg(
            p_group_relate_id => l_group_relate_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_relate_id',
       l_group_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_GRL',
          p_action_code => 'U',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
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


   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_relate_sp;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_relate_sp;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO group_relate_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END update_resource_group_relate;


  /* Procedure to delete the resource group relation. */

  PROCEDURE  delete_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  )
  IS
   l_api_name CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_GROUP_RELATE';
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



  CURSOR grp_rel_cur(l_group_relate_id     JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE )
      IS
  SELECT group_id,
         related_group_id,
         start_date_active,
         end_date_active,
         relation_type,
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
   FROM  jtf_rs_grp_relations
  WHERE  group_relate_id = l_group_relate_id;

  grp_rel_rec grp_rel_cur%rowtype;

  CURSOR parent_count_cur(l_group_id number)
    IS
 SELECT count(*) par_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.group_id = prior related_group_id
   and nvl(delete_flag, 'N') <> 'Y'
  and  rel.related_group_id <> l_group_id
  AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';


 CURSOR child_count_cur(l_group_id number)
    IS
 SELECT count(*) child_count
   from jtf_rs_grp_relations rel
  where rel.relation_type = 'PARENT_GROUP'
  connect by rel.related_group_id = prior group_id
   and nvl(delete_flag, 'N') <> 'Y'
   and  rel.group_id <> l_group_id
   AND ((trunc(rel.start_date_active) <= prior rel.start_date_active
	  AND nvl(rel.end_date_active, prior rel.start_date_active) >=
	   trunc(prior rel.start_date_active)) OR
	 (rel.start_date_active > trunc(prior rel.start_date_active)
	  AND trunc(rel.start_date_active) <= nvl(prior rel.end_date_active,
					   rel.start_date_active)))
  start with rel.related_group_id = l_group_id
  and nvl(rel.delete_flag,'N') <> 'Y';

  l_parent number;
  l_child number;
  l_request number;

 cursor conc_prog_cur
    is
 select description
   from fnd_concurrent_programs_vl
 where  concurrent_program_name = 'JTFRSDEN'
  and  application_id = 690;


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

  -- user hook calls for customer
  -- Customer pre- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'C' ))
   then
            JTF_RS_GROUP_RELATE_CUHK.DELETE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID         => p_group_relate_id,
                                                                P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data       =>    L_data,
                                                               p_count   =>   L_count,
                                                               P_return_code  =>  l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry pre- processing section  -  mandatory     */

 if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then
 if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'V' ))
   then


            JTF_RS_GROUP_RELATE_VUHK.DELETE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID  => p_group_relate_id,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               => l_data,
                                                               p_count              => l_count,
                                                               P_return_code        => l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		  x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;



    /*  	Internal pre- processing section  -  mandatory     */

 if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then
 if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'B', 'I' ))
   then


            JTF_RS_GROUP_RELATE_IUHK.DELETE_RES_GROUP_RELATE_PRE(P_GROUP_RELATE_ID  => p_group_relate_id,
                                                               P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               => l_data,
                                                               p_count              => l_count,
                                                               P_return_code        => l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		  x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;
  -- end of user hook call


   OPEN grp_rel_cur(p_group_relate_id);
   FETCH grp_rel_cur INTO grp_rel_rec;
   CLOSE grp_rel_cur;


   --call audit api

 JTF_RS_GROUP_RELATE_AUD_PVT.delete_group_relate(
       P_API_VERSION           => 1.0,
       P_INIT_MSG_LIST         => p_init_msg_list,
       P_COMMIT                => null,
       P_GROUP_RELATE_ID       => p_group_relate_id,
       X_RETURN_STATUS         => l_return_status,
       X_MSG_COUNT             => l_msg_count,
       X_MSG_DATA              => l_msg_data);

  IF(l_return_status <> fnd_api.g_ret_sts_success)
  THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name ('JTF', 'JTF_RS_GRP_RELATE_AUDIT_ERR');
       FND_MSG_PUB.add;
       RAISE fnd_api.g_exc_error;

  END IF;



  --call lock row for updation
  BEGIN

      jtf_rs_grp_relations_pkg.lock_row(
        x_group_relate_id => p_group_relate_id,
	x_object_version_number => p_object_version_num
      );


    EXCEPTION

	 WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;


  --fetch table handler to update the delete flag to 'Y'
  jtf_rs_grp_relations_pkg.update_row(
         X_GROUP_RELATE_ID    => p_group_relate_id,
         X_GROUP_ID           => grp_rel_rec.group_id,
         X_RELATED_GROUP_ID   =>  grp_rel_rec.related_group_id,
         X_RELATION_TYPE      =>  grp_rel_rec.relation_type,
         X_START_DATE_ACTIVE  => grp_rel_rec.start_date_active,
         X_END_DATE_ACTIVE      =>  grp_rel_rec.end_date_active,
         X_DELETE_FLAG          => 'Y',
         X_OBJECT_VERSION_NUMBER =>  grp_rel_rec.object_version_number,
         X_ATTRIBUTE2         =>   grp_rel_rec.attribute2,
         X_ATTRIBUTE3         =>   grp_rel_rec.attribute3,
         X_ATTRIBUTE4         =>   grp_rel_rec.attribute4,
         X_ATTRIBUTE5         =>   grp_rel_rec.attribute5,
         X_ATTRIBUTE6         =>    grp_rel_rec.attribute6,
         X_ATTRIBUTE7         =>    grp_rel_rec.attribute7,
         X_ATTRIBUTE8         =>  grp_rel_rec.attribute8,
         X_ATTRIBUTE9         =>  grp_rel_rec.attribute9,
         X_ATTRIBUTE10        =>  grp_rel_rec.attribute10,
         X_ATTRIBUTE11        =>  grp_rel_rec.attribute11,
         X_ATTRIBUTE12        =>  grp_rel_rec.attribute12,
         X_ATTRIBUTE13        =>  grp_rel_rec.attribute13,
         X_ATTRIBUTE14        =>   grp_rel_rec.attribute14,
         X_ATTRIBUTE15        =>  grp_rel_rec.attribute15,
         X_ATTRIBUTE_CATEGORY =>  grp_rel_rec.attribute_category,
         X_ATTRIBUTE1        =>   grp_rel_rec.attribute1,
         X_LAST_UPDATE_DATE   =>  l_date,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN    => l_login_id);




   --call to delete records in jtf_rs_groups_denorm
  IF(grp_rel_rec.relation_type = 'PARENT_GROUP')
   THEN
    l_parent := 0;
    l_child := 0;
         BEGIN
	   OPEN parent_count_cur(grp_rel_rec.related_group_id);
	   FETCH parent_count_cur INTO l_parent;
	   CLOSE parent_count_cur;

	   OPEN child_count_cur(grp_rel_rec.group_id);
	   FETCH child_count_cur INTO l_child;
	   CLOSE child_count_cur;
         EXCEPTION
           WHEN OTHERS THEN
             -- use concurrent program
             l_parent := 10;
             l_child := 10;
         END;

         IF (l_parent < 1) then l_parent := 1; end if;
         IF (l_child < 1) then l_child := 1; end if;
         IF(l_parent * l_child > 50)
         THEN
           begin
            insert into jtf_rs_chgd_grp_relations
               (GROUP_RELATE_ID,
                GROUP_ID       ,
                 RELATED_GROUP_ID,
               RELATION_TYPE  ,
               START_DATE_ACTIVE,
               END_DATE_ACTIVE,
               OPERATION_FLAG,
               CREATED_BY    ,
               CREATION_DATE  ,
               LAST_UPDATED_BY ,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN)
            values(p_group_relate_id,
                grp_rel_rec.group_id,
                grp_rel_rec.related_group_id,
                grp_rel_rec.relation_type,
                grp_rel_rec.start_date_active,
                grp_rel_rec.end_date_active,
                'D',
                l_user_id,
                l_date,
                l_user_id,
                l_date,
                l_login_id);
               exception when others then
                      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
                      fnd_message.set_token('P_SQLCODE',SQLCODE);
                      fnd_message.set_token('P_SQLERRM',SQLERRM);
                      fnd_message.set_token('P_API_NAME', l_api_name);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count,  p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

           end;
           begin
                 l_request := fnd_request.submit_request(APPLICATION => 'JTF',
                                            PROGRAM    => 'JTFRSDEN');


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
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      FND_MSG_PUB.count_and_get (p_count => x_msg_count,  p_data => x_msg_data);
                      RAISE fnd_api.g_exc_unexpected_error;

           end;
         ELSE
        /*     JTF_RS_GROUP_DENORM_PVT.DELETE_GROUPS
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_GROUP_ID        => grp_rel_rec.group_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);   */

             JTF_RS_GROUP_DENORM_PVT.DELETE_GRP_RELATIONS
                    ( P_API_VERSION     => 1.0,
                      P_INIT_MSG_LIST   => p_init_msg_list,
                      P_COMMIT          => null,
                      P_group_relate_id        => p_group_relate_id,
                      P_GROUP_ID        => grp_rel_rec.group_id,
                      P_RELATED_GROUP_ID        => grp_rel_rec.related_group_id,
                      X_RETURN_STATUS   => l_return_status,
                      X_MSG_COUNT       => l_msg_count,
                      X_MSG_DATA        => l_msg_data);

                IF(l_return_status <>  fnd_api.g_ret_sts_success)
                THEN
                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_GRP_DENORM_ERR');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;

                END IF;
          END IF; -- end of count
   END IF;


  -- user hook calls for customer
  -- Customer post- processing section  -  mandatory
   if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
   if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'C' ))
   then
            JTF_RS_GROUP_RELATE_CUHK.DELETE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                               P_OBJECT_VERSION_NUM  => p_object_version_num,
                                                               p_data                => L_data,
                                                               p_count               => l_count,
                                                               P_return_code         => l_return_code);
             if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

    /*  	Vertical industry post- processing section  -  mandatory     */

 if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then
 if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'V' ))
   then

             JTF_RS_GROUP_RELATE_VUHK.DELETE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                                  P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               =>    L_data,
                                                               p_count              =>   L_count,
                                                               P_return_code        =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

 /* Internal industry post- processing section  -  mandatory     */

 if  ( JTF_RESOURCE_UTL.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then
 if  ( JTF_USR_HKS.Ok_to_execute( 'JTF_RS_GROUP_RELATE_PVT', 'DELETE_RESOURCE_GROUP_RELATE', 'A', 'I' ))
   then

             JTF_RS_GROUP_RELATE_IUHK.DELETE_RES_GROUP_RELATE_POST(P_GROUP_RELATE_ID => p_group_relate_id,
                                                                  P_OBJECT_VERSION_NUM => p_object_version_num,
                                                               p_data               =>    L_data,
                                                               p_count              =>   L_count,
                                                               P_return_code        =>  l_return_code);
              if (  l_return_code =  FND_API.G_RET_STS_ERROR) OR
                       (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
		   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
	     end if;
    end if;
    end if;

  -- end of user hook call
   IF jtf_resource_utl.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'DELETE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN
   IF jtf_usr_hks.ok_to_execute(
      'JTF_RS_GROUP_RELATE_PVT',
      'DELETE_RESOURCE_GROUP_RELATE',
      'M',
      'M')
    THEN

      IF (jtf_rs_group_relate_cuhk.ok_to_generate_msg(
            p_group_relate_id => p_group_relate_id,
            x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object
      SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'group_relate_id',
        p_group_relate_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
          p_prod_code => 'JTF',
          p_bus_obj_code => 'RS_GRL',
          p_action_code => 'I',    /*    I/U/D   */
          p_bind_data_id => l_bind_data_id,
          x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
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


   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
  --    ROLLBACK TO group_relate_sp;
      --fnd_message.set_name ('JTF', 'JTF_RS_GROUP_DENORM_ERR');
      --FND_MSG_PUB.add;
      --x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
 --     ROLLBACK TO group_relate_sp;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
--      ROLLBACK TO group_relate_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  END delete_resource_group_relate;
END jtf_rs_group_relate_pvt;

/
