--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_UTL_PUB" AS
  /* $Header: jtfrspnb.pls 120.2.12010000.3 2009/12/31 10:52:03 rgokavar ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

PROCEDURE  end_date_employee
  (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_END_DATE_ACTIVE      IN   DATE,
   X_OBJECT_VER_NUMBER    IN OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2  )
  IS
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'END_DATE_EMPLOYEE';
   L_RETURN_STATUS       VARCHAR2(2);
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   l_resource_id         NUMBER;

   l_fnd_date date;
   l_end_date_active date;
   end_date_active date;
   l_object_version_num_res number;

   l_updated_by  number;
  CURSOR term_res_cur(l_resource_id   number)
      IS
  SELECT rsc.resource_id
         , rsc.resource_number
         , rsc.source_id
         , rsc.object_version_number
         , rsc.start_date_active
         , rsc.end_date_active
   FROM  jtf_rs_resource_extns rsc
  WHERE  rsc.resource_id  = l_resource_id;

 term_res_rec term_res_cur%rowtype;


  --cursor to get group member roles for the resource
  CURSOR  res_role_cur(l_role_resource_id   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE)
      IS
  SELECT  rlt.role_relate_id
         , rlt.start_date_active
         , rlt.end_date_active
         , rlt.object_version_number
   FROM  jtf_rs_role_relations rlt
   WHERE rlt.role_resource_id = l_role_resource_id
     AND rlt.role_resource_type = 'RS_INDIVIDUAL'
     AND nvl(rlt.delete_flag, 'N') <> 'Y'
--     AND nvl(rlt.end_date_active,trunc(sysdate)) >= trunc(sysdate);
   AND   nvl(rlt.end_date_active, l_fnd_date) > p_end_date_active;

  res_role_rec   res_role_cur%rowtype;


   --cursor to get salesreps
  CURSOR  res_srp_cur(l_resource_id   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT  res.salesrep_id
         , res.org_id
         , res.start_date_active
         , res.end_date_active
         , res.object_version_number
         , res.sales_credit_type_id
   FROM  jtf_rs_salesreps res
   WHERE res.resource_id = l_resource_id;

  res_srp_rec   res_srp_cur%rowtype;

   --cursor to get salesrep territories
  CURSOR  res_srp_terr_cur(l_salesrep_id   JTF_RS_SALESREPS.SALESREP_ID%TYPE)
      IS
  SELECT  terr.salesrep_id
         ,terr.territory_id
         ,terr.salesrep_territory_id
         ,terr.start_date_active
         ,terr.end_date_active
         ,terr.object_version_number
   FROM  ra_salesrep_territories terr
   WHERE terr.salesrep_id = l_salesrep_id;

  res_srp_terr_rec   res_srp_terr_cur%rowtype;

   --cursor to get overlap salesrep territories
   CURSOR res_srp_terr_dup_cur(c_start_date_active      ra_salesrep_territories.start_date_active%type,
                               c_end_date_active        ra_salesrep_territories.end_date_active%type,
                               c_salesrep_id            ra_salesrep_territories.salesrep_id%type,
                               c_territory_id           ra_salesrep_territories.territory_id%type,
                               c_salesrep_territory_id  ra_salesrep_territories.salesrep_territory_id%type)
       IS
   SELECT salesrep_territory_id
   FROM ra_salesrep_territories
   WHERE salesrep_id  = c_salesrep_id
   AND   territory_id = c_territory_id
   and   salesrep_territory_id <> c_salesrep_territory_id
   AND (c_start_date_active between start_date_active and (nvl(end_date_active, l_fnd_date))
       OR (nvl(c_end_date_active, l_fnd_date) between start_date_active and nvl(end_date_active, l_fnd_date))
       OR (c_start_date_active < start_date_active and nvl(c_end_date_active, l_fnd_date) > nvl(end_date_active, l_fnd_date))
       );

  res_srp_terr_dup_rec   res_srp_terr_dup_cur%rowtype;

  --cursor to get team memebr roles for the resource
  CURSOR  res_team_cur(l_resource_id   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT  rlt.role_relate_id
         , rlt.start_date_active
         , rlt.end_date_active
         , rlt.object_version_number
   FROM  jtf_rs_role_relations rlt
         , jtf_rs_team_members mem
   WHERE mem.team_resource_id = l_resource_id
     AND mem.resource_type = 'INDIVIDUAL'
     AND nvl(mem.delete_flag, 'N') <> 'Y'
     AND rlt.role_resource_id =  mem.team_member_id
     AND rlt.role_resource_type = 'RS_TEAM_MEMBER'
     AND nvl(rlt.delete_flag ,'N')       <> 'Y'
--     AND nvl(rlt.end_date_active,trunc(sysdate)) >= trunc(sysdate);
     AND nvl(rlt.end_date_active, l_fnd_date) > p_end_date_active;

   res_team_rec   res_team_cur%rowtype;

 --cursor to get roles for the resource
   CURSOR  res_group_cur(l_resource_id   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
      IS
  SELECT  rlt.role_relate_id
         , rlt.start_date_active
         , rlt.end_date_active
         , rlt.object_version_number
   FROM  jtf_rs_role_relations rlt
         , jtf_rs_group_members mem
   WHERE mem.resource_id = l_resource_id
     AND nvl(mem.delete_flag, 'N') <> 'Y'
     AND rlt.role_resource_id =  mem.group_member_id
     AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
     AND nvl(rlt.delete_flag ,'N')   <> 'Y'
--     AND nvl(rlt.end_date_active,trunc(sysdate)) >= trunc(sysdate);
     AND nvl(rlt.end_date_active, l_fnd_date) > p_end_date_active;


     res_group_rec   res_group_cur%rowtype;

   i          NUMBER;
   l_value    varchar2(2000);
   l_count    number;

  BEGIN

   l_fnd_date      := to_date(to_char(fnd_api.g_miss_date, 'DD-MM-RRRR'), 'DD-MM-RRRR');
   end_date_active := to_date(to_char(p_end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
   l_updated_by    := jtf_resource_utl.updated_by;

  --Standard Start of API SAVEPOINT
   SAVEPOINT res_save;

  l_return_status := fnd_api.g_ret_sts_success;
  l_count := 0;
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;
  open term_res_cur(p_resource_id);
  fetch term_res_cur into term_res_rec;
  if(term_res_cur%found)
  then

     IF(nvl(trunc(term_res_rec.end_date_active), l_fnd_date) >
                                     nvl(trunc(p_end_date_active), l_fnd_date))
     THEN

        --get all team member roles to be terminated
        open res_team_cur(p_resource_id);
        fetch res_team_cur INTO res_team_rec;
        WHILE(res_team_cur%FOUND)
        LOOP

          l_return_status := fnd_api.g_ret_sts_success;
          l_end_date_active := to_date(to_char(res_team_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
          --if start date > sysdate -1 then delete the role
          IF(trunc(res_team_rec.start_date_active) > trunc(p_end_date_active) )
          THEN
             --call delete role relate api
             jtf_rs_role_relate_pub.delete_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_team_rec.role_relate_id,
                 P_OBJECT_VERSION_NUM  => res_team_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data);

          ELSIF(nvl(l_end_date_active, l_fnd_date)
                                     >= nvl(end_date_active, l_fnd_date))
          THEN
            --update end date with p_end_date_active -1 call update role relate api
            jtf_rs_role_relate_pub.update_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_team_rec.role_relate_id,
                 P_END_DATE_ACTIVE     => trunc(p_end_date_active)  ,
                 P_OBJECT_VERSION_NUM  => res_team_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data);

          END IF; -- end of start_date check

           if ( l_return_status <> fnd_api.g_ret_sts_success)
           then
              raise fnd_api.g_exc_error;
           END IF;
          FETCH res_team_cur INTO res_team_rec;
        END LOOP; -- end of res_team_cur
        CLOSE res_team_cur;

        --get all group member roles to be terminated
        open res_group_cur(p_resource_id);
        fetch res_group_cur INTO res_group_rec;
        WHILE(res_group_cur%FOUND)
        LOOP
          l_end_date_active := to_date(to_char(res_group_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
          IF(trunc(res_group_rec.start_date_active) > trunc(p_end_date_active))
          THEN
             --call delete role relate api
             jtf_rs_role_relate_pub.delete_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_group_rec.role_relate_id,
                 P_OBJECT_VERSION_NUM  => res_group_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data);

          ELSIF(nvl(l_end_date_active, l_fnd_date)
                                     >= nvl(end_date_active, l_fnd_date))
          THEN
            --update end date with p_end_date_active -1 call update role relate api
            jtf_rs_role_relate_pub.update_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_group_rec.role_relate_id,
                 P_END_DATE_ACTIVE     => trunc(p_end_date_active) ,
                 P_OBJECT_VERSION_NUM  => res_group_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data);

          END IF; -- end of start_date check
          if ( l_return_status <> fnd_api.g_ret_sts_success)
           then
              raise fnd_api.g_exc_error;
            END IF;
          FETCH res_group_cur INTO res_group_rec;
        END LOOP; -- end of res_group_cur
        CLOSE res_group_cur;

        --terminate the roles for the resource
        open res_role_cur(p_resource_id);
        fetch res_role_cur INTO res_role_rec;
        WHILE(res_role_cur%FOUND)
        LOOP
          l_end_date_active := to_date(to_char(res_role_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
          --if start date > sysdate -1 then delete the role
          IF(trunc(res_role_rec.start_date_active) > trunc(p_end_date_active))
          THEN
             --call delete role relate api
             jtf_rs_role_relate_pub.delete_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_role_rec.role_relate_id,
                 P_OBJECT_VERSION_NUM  => res_role_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data ) ;
          ELSIF(nvl(l_end_date_active, l_fnd_date)
                                     >= nvl(end_date_active, l_fnd_date))
          THEN
            --update end date with sysdate -1 call update role relate api
            jtf_rs_role_relate_pub.update_resource_role_relate
               ( P_API_VERSION   => 1.0,
                 P_ROLE_RELATE_ID   => res_role_rec.role_relate_id,
                 P_END_DATE_ACTIVE     => trunc(p_end_date_active)  ,
                 P_OBJECT_VERSION_NUM  => res_role_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data ) ;

          END IF; -- end of start_date check


          if ( l_return_status <> fnd_api.g_ret_sts_success)
           then
              raise fnd_api.g_exc_error;
            END IF;



          FETCH res_role_cur INTO res_role_rec;
        END LOOP; -- end of res_role_cur
        CLOSE res_role_cur;

        --terminate the salesrep for the resource
        open res_srp_cur(p_resource_id);
        fetch res_srp_cur INTO res_srp_rec;

        WHILE(res_srp_cur%FOUND)
        LOOP

           --terminate the salesrep territories for the resource
           open res_srp_terr_cur(res_srp_rec.salesrep_id);
           fetch res_srp_terr_cur INTO res_srp_terr_rec;

           WHILE(res_srp_terr_cur%FOUND)
           LOOP
             IF(res_srp_terr_rec.start_date_active > trunc(p_end_date_active)) THEN
                open res_srp_terr_dup_cur(trunc(p_end_date_active - 1),
                                          trunc(p_end_date_active),
                                          res_srp_rec.salesrep_id,
                                          res_srp_terr_rec.territory_id,
                                          res_srp_terr_rec.salesrep_territory_id);
                fetch res_srp_terr_dup_cur INTO res_srp_terr_dup_rec;
                IF res_srp_terr_dup_cur%FOUND THEN
                   fnd_message.set_name ('JTF','JTF_RS_DUP_TERR');
                   fnd_msg_pub.add;
                   CLOSE res_srp_terr_dup_cur;
                   raise fnd_api.g_exc_error;
                END IF;
                CLOSE res_srp_terr_dup_cur;

                update ra_salesrep_territories
                set    start_date_active = trunc(p_end_date_active - 1),
                       end_date_active = trunc(p_end_date_active),
                       object_version_number = object_version_number + 1,
                       last_update_date = sysdate,
                       last_updated_by = l_updated_by
                where  salesrep_territory_id = res_srp_terr_rec.salesrep_territory_id;
             ELSIF(nvl(res_srp_terr_rec.end_date_active, l_fnd_date) >= nvl(p_end_date_active, l_fnd_date)) THEN
                update ra_salesrep_territories
                set    end_date_active = trunc(p_end_date_active),
                       object_version_number = object_version_number + 1,
                       last_update_date = sysdate,
                       last_updated_by = l_updated_by
                where  salesrep_territory_id = res_srp_terr_REC.SALEsrep_territory_id;
             END IF; -- end of start_date check

             FETCH res_srp_terr_cur INTO res_srp_terr_rec;
           END LOOP; -- end of res_srp_terr_cur
           CLOSE res_srp_terr_cur;

          l_end_date_active := to_date(to_char(res_srp_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
          IF(res_srp_rec.start_date_active > trunc(p_end_date_active))
          THEN
             --update to sydate - 2 and sysdate -1
             jtf_rs_salesreps_pub.update_salesrep
               ( P_API_VERSION   => 1.0,
                 P_SALESREP_ID   => res_srp_rec.salesrep_id,
                 P_ORG_ID        => res_srp_rec.org_id,
                 P_SALES_CREDIT_TYPE_ID  => res_srp_rec.sales_credit_type_id,
                 P_START_DATE_ACTIVE     => trunc(p_end_date_active - 1) ,
                 P_END_DATE_ACTIVE     => trunc(p_end_date_active ) ,
                 P_OBJECT_VERSION_NUMBER  => res_srp_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data ) ;


          ELSIF(nvl(l_end_date_active, l_fnd_date)
                                     >= nvl(end_date_active, l_fnd_date))
          THEN

            --update end date with sysdate -1 call update role relate api
               jtf_rs_salesreps_pub.update_salesrep
               ( P_API_VERSION   => 1.0,
                 P_SALESREP_ID   => res_srp_rec.salesrep_id,
                 P_ORG_ID        => res_srp_rec.org_id,
                 P_SALES_CREDIT_TYPE_ID  => res_srp_rec.sales_credit_type_id,
                 P_END_DATE_ACTIVE     => trunc(p_end_date_active )  ,
                 P_OBJECT_VERSION_NUMBER  => res_srp_rec.object_version_number,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data ) ;
           END IF; -- end of start_date check
           if ( l_return_status <> fnd_api.g_ret_sts_success)
           then
              raise fnd_api.g_exc_error;
            END IF;



          FETCH res_srp_cur INTO res_srp_rec;
        END LOOP; -- end of res_srp_cur
        CLOSE res_srp_cur;


     END IF;  -- end of terminate employee
---------------------------------------------------
    l_object_version_num_res := term_res_rec.object_version_number;

    IF(term_res_rec.start_date_active >= trunc(p_end_date_active + 1))
     THEN

       --for future dated resources terminate it anyway
       jtf_rs_resource_pub.update_resource
           (P_API_VERSION               => 1,
            P_INIT_MSG_LIST             => fnd_api.g_true,
            P_COMMIT                    => fnd_api.g_false,
            P_RESOURCE_ID               => term_res_rec.resource_id,
            P_RESOURCE_NUMBER           => term_res_rec.resource_number,
            P_START_DATE_ACTIVE         => trunc(p_end_date_active - 1) ,
            P_END_DATE_ACTIVE           => trunc(p_end_date_active) ,
            P_OBJECT_VERSION_NUM        => l_object_version_num_res,
            X_RETURN_STATUS             => l_return_status,
            X_MSG_COUNT                 => l_msg_count,
            X_MSG_DATA                  => l_msg_data) ;

     ELSE

       --put end_date to p_end_date_active
      jtf_rs_resource_pub.update_resource
           (   P_API_VERSION            => 1,
            P_INIT_MSG_LIST             => fnd_api.g_true,
            P_COMMIT                    => fnd_api.g_false,
            P_RESOURCE_ID               => term_res_rec.resource_id,
            P_RESOURCE_NUMBER           => term_res_rec.resource_number,
            P_END_DATE_ACTIVE           => trunc(p_end_date_active) ,
            P_OBJECT_VERSION_NUM        => l_object_version_num_res,
            X_RETURN_STATUS             => l_return_status,
            X_MSG_COUNT                 => l_msg_count,
            X_MSG_DATA                  => l_msg_data) ;

     END IF;  -- end of terminate employee

     x_object_ver_number := l_object_version_num_res;

     if ( l_return_status <> fnd_api.g_ret_sts_success)
     then
         raise fnd_api.g_exc_error;
     END IF;
--------------------------------------------------
  --Bug9009376
  --When No Data Found against Resource Id then
  --raising an error.
  else -- else block of term_res_cur
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', p_resource_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

  end if; -- end of term_res_cur

  close term_res_cur;

   FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
  --Bug#8915500
  --Status in local varaible assigned to Out parameter.
  x_return_status := l_return_status;

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO res_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO res_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO res_save;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
 END end_date_employee;

 PROCEDURE  add_message
  (P_API_VERSION           IN   NUMBER,
   P_MESSAGE_CODE          IN   VARCHAR2,
   P_TOKEN1_NAME           IN   VARCHAR2,
   P_TOKEN1_VALUE          IN   VARCHAR2,
   P_TOKEN2_NAME           IN   VARCHAR2,
   P_TOKEN2_VALUE          IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   )
  AS
    l_api_name VARCHAR2(30);
  BEGIN
   l_api_name := 'ADD_MESSAGE';
   x_return_status := fnd_api.g_ret_sts_success;
   FND_MSG_PUB.Initialize;
   if(P_MESSAGE_CODE is not null)
   then
      fnd_message.set_name ('JTF', p_message_code);
      if((P_TOKEN1_NAME is not null) OR (P_TOKEN1_NAME <> fnd_api.g_miss_char))
      then
         fnd_message.set_token (p_token1_name, p_token1_value);
      end if;
      if((P_TOKEN2_NAME is not null) OR (P_TOKEN2_NAME <> fnd_api.g_miss_char))
      then
         fnd_message.set_token (p_token2_name, p_token2_value);
      end if;
      FND_MSG_PUB.add;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   end if;

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

  END  add_message ;

/* Function to check if user has resource update access */

Function    Validate_Update_Access( p_resource_id           number,
  			            p_resource_user_id      number default null
			          ) Return varchar2
IS
l_profile_value	     VARCHAR2(10);
l_user_id            number;
l_resource_user_id   number;

BEGIN

  l_profile_value := nvl(FND_PROFILE.VALUE('JTF_RS_EMP_RES_UPD_ACCESS'),'SELF');
  l_user_id       := nvl(FND_PROFILE.VALUE('USER_ID'),-1);

  IF (l_profile_value = 'SELF') THEN
       IF (p_resource_user_id IS NULL) THEN
          BEGIN
            SELECT  nvl(user_id,-99)
    	    INTO    l_resource_user_id
            FROM    jtf_rs_resource_extns
            WHERE   resource_id = p_resource_id;
          EXCEPTION WHEN NO_DATA_FOUND THEN
    	     l_resource_user_id := -99;
             WHEN OTHERS THEN
	     l_resource_user_id := -98;
          END;
        ELSE
          l_resource_user_id := p_resource_user_id;
        END IF;

        IF l_resource_user_id = l_user_id THEN
           Return 'SELF';
        ELSE
           Return 'OTHERS';
        END IF;

   ELSIF (l_profile_value = 'ANY') THEN
        Return 'ANY';
   ELSE
        Return 'OTHERS';
   END IF;

   END Validate_Update_Access;

/* Function to check if logged in user has access to Update Group Membership/Hierarchy */

FUNCTION    Group_Update_Access( p_group_id   IN  number default null) RETURN VARCHAR2
IS

l_profile_value	     VARCHAR2(10);
l_user_id            number;
l_resource_id        number := 0;
l_mgr                number := 0;

CURSOR parent_grp_cur(l_group_id number) IS
       SELECT  parent_group_id
       FROM    jtf_rs_groups_denorm
       WHERE   group_id = l_group_id
       AND     group_id <> parent_group_id
       AND     trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate));

BEGIN

  l_profile_value := nvl(FND_PROFILE.VALUE('JTF_RS_GROUP_UPD_ACCESS'),'NONE');
  l_user_id       := nvl(FND_PROFILE.VALUE('USER_ID'),-1);
--  l_profile_value := 'NONE';
--  l_user_id       := 1351;

  IF  (l_profile_value = 'ALL') THEN
      RETURN 'SU';
  ELSIF ((l_profile_value = 'NONE') AND (p_group_id IS NOT NULL)) THEN
      BEGIN
	SELECT resource_id
	INTO   l_resource_id
        FROM   jtf_rs_resource_extns
        WHERE  user_id = l_user_id
	AND    rownum  < 2;
        EXCEPTION
  	     WHEN NO_DATA_FOUND THEN
    	          l_resource_id := 0;
		  RETURN('RO');
             WHEN OTHERS THEN
	          l_resource_id := 0;
		  RETURN('RO');
      END;

      IF ((l_resource_id <> 0)) THEN
	-- Check if user is active Manager/Admin of any acive parent group
        FOR parent_grp_rec IN parent_grp_cur(p_group_id) LOOP
	  EXIT WHEN l_mgr = 1;
          BEGIN
	    SELECT  '1'
	    INTO    l_mgr
	    FROM    jtf_rs_roles_b c,
	            jtf_rs_role_relations b,
	            jtf_rs_group_members a
	    WHERE   a.group_id           = parent_grp_rec.parent_group_id
	      AND   a.resource_id        = l_resource_id
              AND   nvl(a.delete_flag, 'N') <> 'Y'
              AND   b.role_resource_id   = a.group_member_id
              AND   trunc(sysdate) between b.start_date_active and nvl(b.end_date_active, trunc(sysdate))
              AND   b.role_resource_type = 'RS_GROUP_MEMBER'
              AND   nvl(b.delete_flag, 'N') <> 'Y'
              AND   c.role_id            = b.role_id
              AND   'Y' in (c.manager_flag, c.admin_flag)
              AND   c.active_flag        = 'Y'
	      AND   rownum < 2 ;
            EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		      l_mgr := 0;
                 WHEN OTHERS THEN
		      l_mgr := 0;
          END;
	END LOOP;

	IF (l_mgr = 1) THEN
	    RETURN('FA');
        ELSE
	    -- Check if user is active Manager/Admin of group being queried
            BEGIN
	      SELECT  '2'
	      INTO    l_mgr
	      FROM    jtf_rs_roles_b c,
	              jtf_rs_role_relations b,
	              jtf_rs_group_members a
	      WHERE   a.group_id           = p_group_id
	        AND   a.resource_id        = l_resource_id
                AND   nvl(a.delete_flag, 'N') <> 'Y'
                AND   b.role_resource_id   = a.group_member_id
                AND   trunc(sysdate) between b.start_date_active and nvl(b.end_date_active, trunc(sysdate))
                AND   b.role_resource_type = 'RS_GROUP_MEMBER'
                AND   nvl(b.delete_flag, 'N') <> 'Y'
                AND   c.role_id            = b.role_id
                AND   'Y' in (c.manager_flag, c.admin_flag)
                AND   c.active_flag        = 'Y'
	        AND   rownum < 2 ;

              IF (l_mgr = 2) THEN
		RETURN('NPU');
              ELSIF (l_mgr = 0) THEN
		RETURN('RO');
              END IF;

            EXCEPTION
		      WHEN NO_DATA_FOUND THEN
		           l_mgr := 0;
			   RETURN('RO');
                      WHEN OTHERS THEN
		           l_mgr := 0;
			   RETURN('RO');
            END;
        END IF;  -- End of l_mgr value check
      ELSE       -- Resource id is invalid (0)
	RETURN('RO');
      END IF;    -- End of l_resource_id  value check
  ELSE           -- Profile value is NONE but p_group_id is NULL
    RETURN('RO');
  END IF;        -- End of profile value check

END Group_Update_Access;


/* Function to check if logged in user has access to Update role */

FUNCTION    Role_Update_Access RETURN VARCHAR2
IS

l_profile_value	     VARCHAR2(10);

BEGIN

  l_profile_value := nvl(FND_PROFILE.VALUE('JTF_RS_ROLE_UPD_ACCESS'),'NONE');
  if l_profile_value = 'ALL' then
     return 'FA';
  else
     return 'RO';
  end if;

END Role_Update_Access;



/* Function to check if user is HR manager for this resource */

Function    Is_HR_Manager( p_resource_id           number
			  ) Return varchar2
IS
l_user_id            number;

cursor mgr_usr_ids(p_res_id number) is
   select user_id
   from jtf_rs_resource_extns  connect by
   source_id = prior source_mgr_id
   start with resource_id = p_res_id;

BEGIN

  l_user_id       := nvl(FND_PROFILE.VALUE('USER_ID'),-1);

  for mgr_usr_id_rec in mgr_usr_ids(p_resource_id) loop
    if (l_user_id = mgr_usr_id_rec.user_id) then
      return 'Y';
    end if;
  end loop;

  return 'N';
END Is_HR_Manager;

PROCEDURE  end_date_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   NUMBER,
   P_END_DATE_ACTIVE      IN   DATE,
   X_OBJECT_VER_NUMBER    IN OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2  )
  IS
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'END_DATE_GROUP';
   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_group_id            NUMBER;

   l_fnd_date               date;
   l_end_date_active        date;
   end_date_active          date;
   l_object_version_num_grp number;

   --cursor to get details about group needs to end date
   CURSOR term_grp_cur(c_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE) IS
   SELECT grp.group_id,
          grp.group_number,
          grp.object_version_number,
          grp.start_date_active,
          grp.end_date_active
   FROM   jtf_rs_groups_b grp
   WHERE  grp.group_id  = c_group_id;

   term_grp_rec term_grp_cur%rowtype;

   --cursor to get all active member roles
   CURSOR group_mem_roles_cur(c_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                              c_group_end_date JTF_RS_GROUPS_B.END_DATE_ACTIVE%TYPE) IS
   SELECT rlt.role_relate_id,
          rlt.start_date_active,
          rlt.end_date_active,
          rlt.object_version_number
   FROM   jtf_rs_role_relations rlt,
          jtf_rs_group_members mem
   WHERE  mem.group_id = c_group_id
   AND    nvl(mem.delete_flag, 'N') <> 'Y'
   AND    rlt.role_resource_id =  mem.group_member_id
   AND    rlt.role_resource_type = 'RS_GROUP_MEMBER'
   AND    nvl(rlt.delete_flag ,'N')   <> 'Y'
   AND    nvl(rlt.end_date_active, l_fnd_date) > c_group_end_date
   UNION ALL
   SELECT rlt2.role_relate_id,
          rlt2.start_date_active,
          rlt2.end_date_active,
          rlt2.object_version_number
   FROM   jtf_rs_role_relations rlt2
   WHERE  rlt2.role_resource_id = c_group_id
   AND    rlt2.role_resource_type = 'RS_GROUP'
   AND    nvl(rlt2.delete_flag ,'N')   <> 'Y'
   AND    NVL(rlt2.end_date_active, l_fnd_date) > c_group_end_date;

   group_mem_roles_rec   group_mem_roles_cur%rowtype;

   --cursor to get all active parent or child group relations
   CURSOR grp_relations_cur(c_group_id JTF_RS_GROUPS_B.GROUP_ID%TYPE,
                            c_group_end_date JTF_RS_GROUPS_B.END_DATE_ACTIVE%TYPE) IS
   SELECT group_relate_id,
          group_id,
          related_group_id,
          start_date_active,
          end_date_active,
          object_version_number
   FROM   jtf_rs_grp_relations
   WHERE  nvl(delete_flag, 'N') <> 'Y'
   AND    group_id = c_group_id
   AND    nvl(end_date_active, l_fnd_date) > c_group_end_date
   UNION ALL
   SELECT group_relate_id,
          group_id,
          related_group_id,
          start_date_active,
          end_date_active,
          object_version_number
   FROM   jtf_rs_grp_relations
   WHERE  nvl(delete_flag, 'N') <> 'Y'
   AND    related_group_id = c_group_id
   AND    nvl(end_date_active, l_fnd_date) > c_group_end_date;

   grp_relations_rec grp_relations_cur%rowtype;

BEGIN

   l_fnd_date      := to_date(to_char(fnd_api.g_miss_date, 'DD-MM-RRRR'), 'DD-MM-RRRR');
   end_date_active := to_date(to_char(p_end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');

  --Standard Start of API SAVEPOINT
   SAVEPOINT group_mem_roles_save;

   l_return_status := fnd_api.g_ret_sts_success;

   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

   OPEN term_grp_cur(p_group_id);
   FETCH term_grp_cur into term_grp_rec;
   IF (term_grp_cur%found) THEN

      -- If condition to check whether the new group end_date is before old end_date or old end_date is null.
      IF(nvl(trunc(term_grp_rec.end_date_active), l_fnd_date) > nvl(trunc(p_end_date_active), l_fnd_date)) THEN

         --get all group member roles to be terminated
         open group_mem_roles_cur(p_group_id,p_end_date_active);
         fetch group_mem_roles_cur INTO group_mem_roles_rec;
         WHILE(group_mem_roles_cur%FOUND)
         LOOP
           l_end_date_active := to_date(to_char(group_mem_roles_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
           IF(trunc(group_mem_roles_rec.start_date_active) > trunc(p_end_date_active))
           THEN
              --call delete role relate api
              jtf_rs_role_relate_pub.delete_resource_role_relate
                ( P_API_VERSION         => 1.0,
                  P_ROLE_RELATE_ID      => group_mem_roles_rec.role_relate_id,
                  P_OBJECT_VERSION_NUM  => group_mem_roles_rec.object_version_number,
                  X_RETURN_STATUS       => l_return_status,
                  X_MSG_COUNT           => l_msg_count,
                  X_MSG_DATA            => l_msg_data);

           ELSIF(nvl(l_end_date_active, l_fnd_date)
                                      >= nvl(end_date_active, l_fnd_date))
           THEN
             --update end date with p_end_date_active call update role relate api
             jtf_rs_role_relate_pub.update_resource_role_relate
                ( P_API_VERSION         => 1.0,
                  P_ROLE_RELATE_ID      => group_mem_roles_rec.role_relate_id,
                  P_END_DATE_ACTIVE     => trunc(p_end_date_active) ,
                  P_OBJECT_VERSION_NUM  => group_mem_roles_rec.object_version_number,
                  X_RETURN_STATUS       => l_return_status,
                  X_MSG_COUNT           => l_msg_count,
                  X_MSG_DATA            => l_msg_data);

           END IF; -- end of start_date check
           if ( l_return_status <> fnd_api.g_ret_sts_success)
            then
               raise fnd_api.g_exc_error;
             END IF;
           FETCH group_mem_roles_cur INTO group_mem_roles_rec;
         END LOOP; -- end of group_mem_roles_cur
         CLOSE group_mem_roles_cur;

         --get all group relations to be terminated
         open grp_relations_cur(p_group_id,p_end_date_active);
         fetch grp_relations_cur INTO grp_relations_rec;
         WHILE(grp_relations_cur%FOUND)
         LOOP
           l_end_date_active := to_date(to_char(grp_relations_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR');
           IF(trunc(grp_relations_rec.start_date_active) > trunc(p_end_date_active))
           THEN
              --call delete group relate api
              jtf_rs_group_relate_pvt.delete_resource_group_relate
                ( P_API_VERSION         => 1.0,
                  P_GROUP_RELATE_ID     => grp_relations_rec.group_relate_id,
                  P_OBJECT_VERSION_NUM  => grp_relations_rec.object_version_number,
                  X_RETURN_STATUS       => l_return_status,
                  X_MSG_COUNT           => l_msg_count,
                  X_MSG_DATA            => l_msg_data);

           ELSIF(nvl(l_end_date_active, l_fnd_date)
                                      >= nvl(end_date_active, l_fnd_date))
           THEN
             --update end date with p_end_date_active call update group relate api
             jtf_rs_group_relate_pvt.update_resource_group_relate
                ( P_API_VERSION         => 1.0,
                  P_GROUP_RELATE_ID     => grp_relations_rec.group_relate_id,
                  P_END_DATE_ACTIVE     => trunc(p_end_date_active) ,
                  P_OBJECT_VERSION_NUM  => grp_relations_rec.object_version_number,
                  X_RETURN_STATUS       => l_return_status,
                  X_MSG_COUNT           => l_msg_count,
                  X_MSG_DATA            => l_msg_data);

           END IF; -- end of start_date check
           if ( l_return_status <> fnd_api.g_ret_sts_success)
            then
               raise fnd_api.g_exc_error;
             END IF;
           FETCH grp_relations_cur INTO grp_relations_rec;
         END LOOP; -- end of grp_relations_cur
         CLOSE grp_relations_cur;

      END IF;  -- end of If condition to check whether the new group end_date is before old end date or old end_date is null.
---------------------------------------------------
      l_object_version_num_grp := term_grp_rec.object_version_number;

      IF(term_grp_rec.start_date_active >= trunc(p_end_date_active + 1)) THEN

         --for future dated groups terminate it anyway
           jtf_rs_groups_pub.update_resource_group
            (P_API_VERSION               => 1.0,
             P_INIT_MSG_LIST             => fnd_api.g_true,
             P_COMMIT                    => fnd_api.g_false,
             P_GROUP_ID                  => term_grp_rec.group_id,
             P_GROUP_NUMBER              => term_grp_rec.group_number,
             P_START_DATE_ACTIVE         => trunc(p_end_date_active - 1) ,
             P_END_DATE_ACTIVE           => trunc(p_end_date_active) ,
             P_OBJECT_VERSION_NUM        => l_object_version_num_grp,
             X_RETURN_STATUS             => l_return_status,
             X_MSG_COUNT                 => l_msg_count,
             X_MSG_DATA                  => l_msg_data) ;

      ELSE

         --put end_date to p_end_date_active
         jtf_rs_groups_pub.update_resource_group
            (P_API_VERSION               => 1.0,
             P_INIT_MSG_LIST             => fnd_api.g_true,
             P_COMMIT                    => fnd_api.g_false,
             P_GROUP_ID                  => term_grp_rec.group_id,
             P_GROUP_NUMBER              => term_grp_rec.group_number,
             P_END_DATE_ACTIVE           => trunc(p_end_date_active),
             P_OBJECT_VERSION_NUM        => l_object_version_num_grp,
             X_RETURN_STATUS             => l_return_status,
             X_MSG_COUNT                 => l_msg_count,
             X_MSG_DATA                  => l_msg_data) ;

      END IF;  -- end of terminate group

      x_object_ver_number := l_object_version_num_grp;

      if ( l_return_status <> fnd_api.g_ret_sts_success) then
          raise fnd_api.g_exc_error;
      END IF;

   end if; -- end of term_grp_cur
   close term_grp_cur;

   FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO group_mem_roles_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO group_mem_roles_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS
    THEN
      ROLLBACK TO group_mem_roles_save;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

END end_date_group;

/* returns 'Y' for Yes and 'N' for No */
FUNCTION TAX_VENDOR_EXTENSION return VARCHAR2
IS
  val boolean;
BEGIN
  val := zx_r11i_tax_partner_pkg.TAX_VENDOR_EXTENSION;
  if (val = true) then
    return 'Y';
  else
    return 'N';
  end if;
END TAX_VENDOR_EXTENSION;

/* returns 'Y' for Yes and 'N' for No */
FUNCTION IS_GEOCODE_VALID(p_geocode IN VARCHAR2) return VARCHAR2
IS
  val boolean;
BEGIN
  val := zx_r11i_tax_partner_pkg.IS_GEOCODE_VALID(p_geocode);
  if (val = true) then
    return 'Y';
  else
    return 'N';
  end if;
END IS_GEOCODE_VALID;

/* returns 'Y' for Yes and 'N' for No */
FUNCTION IS_CITY_LIMIT_VALID(p_city_limit IN VARCHAR2) return VARCHAR2
IS
  val boolean;
BEGIN
  val := zx_r11i_tax_partner_pkg.IS_CITY_LIMIT_VALID(p_city_limit);
  if (val = true) then
    return 'Y';
  else
    return 'N';
  end if;
END IS_CITY_LIMIT_VALID;

END jtf_rs_resource_utl_pub;

/
