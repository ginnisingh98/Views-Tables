--------------------------------------------------------
--  DDL for Package Body CN_SFP_GROUP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_GROUP_UTIL_PVT" AS
-- $Header: cnvsfgrb.pls 115.4 2003/08/19 22:31:44 sbadami noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_SFP_GROUP_UTIL_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvsfgrb.pls';


PROCEDURE check_success(p_return_status IN VARCHAR2) IS
    BEGIN
     IF p_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
END;

FUNCTION check_exist_group(p_grp_list IN grpnum_tbl_type,
                           p_grp      IN NUMBER)
RETURN VARCHAR2 IS
  x_exist VARCHAR2(1);
BEGIN
   x_exist := 'N';

   IF p_grp_list.COUNT > 0 THEN
     FOR i IN p_grp_list.first..p_grp_list.last LOOP
        IF (p_grp_list(i) = p_grp) THEN
           x_exist := 'Y';
        END IF;
     END LOOP;
   END IF;

   RETURN x_exist;
END;

FUNCTION check_exist_srprole(p_srprole_list IN srprole_tbl_type,
                             p_srp_role IN NUMBER,
                             p_comp_group IN NUMBER)
RETURN VARCHAR2 IS
  x_exist VARCHAR2(1);
BEGIN
   x_exist := 'N';

   IF p_srprole_list.COUNT > 0 THEN
     FOR i IN p_srprole_list.first..p_srprole_list.last LOOP
        IF ((p_srprole_list(i).srp_role_id = p_srp_role) AND (p_srprole_list(i).comp_group_id = p_comp_group) )THEN
           x_exist := 'Y';
        END IF;
     END LOOP;
   END IF;

   RETURN x_exist;
END;

PROCEDURE pre_process_groups(p_selected_groups IN  grpnum_tbl_type,
                             x_process_groups  OUT NOCOPY grpnum_tbl_type) IS
    l_selected_groups grpnum_tbl_type;
    l_found boolean := false;
    l_out_counter NUMBER := 0;
    CURSOR groups_cur(p_comp_group_id NUMBER) IS
    SELECT group_id,parent_group_id from jtf_rs_groups_denorm
    where group_id = p_comp_group_id and parent_group_id <> p_comp_group_id;
BEGIN
    l_selected_groups := p_selected_groups;
    IF (p_selected_groups.COUNT > 0) THEN
       FOR i IN l_selected_groups.FIRST .. l_selected_groups.LAST LOOP
         l_found := false;
         FOR eachrec in groups_cur(l_selected_groups(i)) LOOP
             FOR z in p_selected_groups.FIRST .. p_selected_groups.LAST LOOP
                IF (eachrec.parent_group_id = p_selected_groups(z)) THEN
                  l_found := true;
                END IF;
             END LOOP;
         END LOOP;

         IF (l_found = false) THEN
            x_process_groups(l_out_counter) := l_selected_groups(i);
            l_out_counter := l_out_counter + 1;
         END IF;
       END LOOP;
    END IF;
END;


-- Start of comments
--    API name        : Get_Descendant_Groups
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_selected_groups     IN   DBMS_SQL.NUMBER_TABLE,
--                      p_effective_date
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_descendant_groups   OUT DBMS_SQL.NUMBER_TABLE
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedures takes many comp group ids as parameters
--                      and tries to generate the distinct comp group id list.
--
-- End of comments

PROCEDURE Get_Descendant_Groups
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_selected_groups         IN  grpnum_tbl_type,
   p_effective_date          IN  DATE := SYSDATE,
   x_descendant_groups       OUT NOCOPY    grpnum_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Get_Descendant_Groups';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_temp_groups grpnum_tbl_type;
      l_counter NUMBER := 0;
      l_selected_groups grpnum_tbl_type;
      j NUMBER;
      CURSOR desc_groups_cur(p_comp_group_id NUMBER,p_date DATE) IS
      select
      rgd.group_id,
      rg.group_name,
      rgd.parent_group_id,
      rgd.start_date_active,
      rgd.end_date_active
      from jtf_rs_groups_denorm rgd,jtf_rs_group_usages rgu,jtf_rs_groups_vl rg
      where
          rgd.group_id = rgu.group_id
          and rg.group_id = rgu.group_id
          and rg.group_id = rgd.group_id
          and rgu.usage = 'SF_PLANNING'
          and rgd.parent_group_id = p_comp_group_id
          and p_date between rgd.start_date_active and nvl(rgd.end_date_active,p_date)
      ORDER by rgd.denorm_level;

BEGIN

   SAVEPOINT   Get_Descendant_Groups;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* OLD CODE WITH NO ORDERING */
   /*
   FOR i IN p_selected_groups.first..p_selected_groups.last LOOP
     FOR l_desc_grp IN desc_groups_cur(p_selected_groups(i),p_effective_date) LOOP
           l_temp_groups(l_desc_grp.group_id) := nvl(l_desc_grp.group_id,0) + 1;
     END LOOP;
   END LOOP ;

   j := l_temp_groups.FIRST;
   WHILE j IS NOT NULL LOOP
      x_descendant_groups(l_counter) := j;
      l_counter := l_counter + 1;
      j := l_temp_groups.NEXT(j);
   END LOOP;
   */

   /* New Groups Code with Ordering */

   pre_process_groups(p_selected_groups,l_selected_groups);


   FOR i IN l_selected_groups.first..l_selected_groups.last LOOP
        FOR l_desc_grp IN desc_groups_cur(l_selected_groups(i),p_effective_date) LOOP
           IF (check_exist_group(l_temp_groups,l_desc_grp.group_id) = 'N') THEN
              l_temp_groups(l_counter) := l_desc_grp.group_id;
              l_counter := l_counter + 1;
           END IF;
        END LOOP;
   END LOOP ;

   x_descendant_groups := l_temp_groups;

   -- End of API body.

   << end_Get_Descendant_Groups >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Descendant_Groups  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Descendant_Groups ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN OTHERS THEN
      ROLLBACK TO Get_Descendant_Groups ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
END Get_Descendant_Groups;


-- Start of comments
--    API name        : Get_Salesrep_Roles
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_selected_groups     IN  DBMS_SQL.NUMBER_TABLE,
--                      p_status              IN  VARCHAR2
--                      p_effective_date      IN  DATE
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_roles      OUT srprole_tbl_type
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets the srp role ids for all the
--                      groups that have been selected based on the status
--                      Status could be PENDING, LOCKED,GENERATED, SUBMITTED
--                      APPROVED, ISSUED and ACCEPTED or ALL
--
-- End of comments

PROCEDURE Get_Salesrep_Roles
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_selected_groups         IN  grpnum_tbl_type,
   p_status                  IN  VARCHAR2 := 'ALL',
   p_effective_date          IN  DATE := SYSDATE,
   x_salesrep_roles          OUT NOCOPY    srprole_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 )IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Get_Salesrep_Roles';
    l_api_version  CONSTANT NUMBER  := 1.0;
    l_error_code NUMBER;
    l_temp_srproles grpnum_tbl_type;
    l_counter NUMBER := 0;
    j NUMBER;
    l_status VARCHAR2(20);
    l_descendant_groups grpnum_tbl_type;
    l_return_status VARCHAR2(2);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(255);
         CURSOR srp_roles_cur(p_comp_group_id NUMBER,p_date DATE,p_status VARCHAR2) IS
          select srd.srp_role_id,
	         comp_group_id,
	         group_name,
	         qmsg.srp_id,
	         qmsg.role_id,
	         qmsg.role_name,
	         start_date,
	         end_date,
	         srd.status,
	         srd.plan_activate_status,
	         srd.org_code
	  from cn_qm_mgr_srp_groups qmsg, cn_srp_role_dtls_v srd
	  where comp_group_id = p_comp_group_id
	  and   qmsg.srp_role_id = srd.srp_role_id
	  and   srd.role_model_id is null
	  and   srd.job_title_id <> -99
	  and   p_date between start_date_active and nvl(end_date_active,p_date)
	  and   p_date between srd.start_date and nvl(srd.end_date,p_date)
	  and   srd.status like p_status
	 order by manager_flag desc;

BEGIN
   SAVEPOINT   Get_Salesrep_Roles;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
     l_status := p_status;
     IF (l_status = 'ALL') THEN
       l_status := '%';
     END IF;

     cn_sfp_group_util_pvt.get_descendant_groups(p_api_version,
                                                 p_init_msg_list,
                                                 p_commit,
                                                 p_validation_level,
                                                 p_selected_groups,
                                                 p_effective_date,
                                                 l_descendant_groups,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data);
     check_success(p_return_status => l_return_status);

     /*
     FOR i IN l_descendant_groups.first..l_descendant_groups.last LOOP
       FOR l_srp_role IN srp_roles_cur(l_descendant_groups(i),p_effective_date,l_status) LOOP
             l_temp_srproles(l_srp_role.srp_role_id) := l_srp_role.comp_group_id;
       END LOOP;
     END LOOP ;

     j :=l_temp_srproles.FIRST;
     WHILE j IS NOT NULL LOOP
        x_salesrep_roles(l_counter).srp_role_id := j;
        x_salesrep_roles(l_counter).comp_group_id := l_temp_srproles(j);
        l_counter := l_counter + 1;
        j :=l_temp_srproles.NEXT(j);
     END LOOP;*/


     FOR i IN l_descendant_groups.first..l_descendant_groups.last LOOP
        FOR l_srp_role IN srp_roles_cur(l_descendant_groups(i),p_effective_date,l_status) LOOP
             IF(check_exist_srprole(x_salesrep_roles,
	                            l_srp_role.srp_role_id,
                                    l_srp_role.comp_group_id) = 'N') THEN
                      x_salesrep_roles(l_counter).srp_role_id := l_srp_role.srp_role_id;
		      x_salesrep_roles(l_counter).comp_group_id := l_srp_role.comp_group_id;
		      x_salesrep_roles(l_counter).org_code := l_srp_role.org_code;
		      l_counter := l_counter + 1;
             END IF;
         END LOOP;
     END LOOP ;

   -- End of API body.
   << end_Get_Salesrep_Roles >>
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Salesrep_Roles  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Salesrep_Roles ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Get_Salesrep_Roles ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name) ;
      END IF ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
END Get_Salesrep_Roles;

-- Start of comments
--    API name        : Get_Grp_Organization_Access
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_comp_group_id       IN  NUMBER,
--                      p_effective_date      IN  DATE
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_updview_organization OUT grporg_tbl_type
--                      x_upd_organization OUT grporg_tbl_type
--                      x_view_organization OUT grporg_tbl_type
--                      x_noview_organization OUT grporg_tbl_type
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure given a comp group id and an effective
--                      date lists the Organization user has UPDATE/VIEW or
--                      NO_READ accesses for that group.
--
-- End of comments

PROCEDURE Get_Grp_Organization_Access
(  p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_comp_group_id           IN  NUMBER,
   p_effective_date          IN  DATE := SYSDATE,
   x_updview_organization    OUT NOCOPY    grporg_tbl_type,
   x_upd_organization        OUT NOCOPY    grporg_tbl_type,
   x_view_organization       OUT NOCOPY    grporg_tbl_type,
   x_noview_organization     OUT NOCOPY    grporg_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Get_Grp_Organization_Access';
    l_api_version  CONSTANT NUMBER  := 1.0;
    l_updview_counter NUMBER := 0;
    l_upd_counter NUMBER:= 0;
    l_view_counter NUMBER:= 0;
    l_noview_counter NUMBER:= 0;
    l_updview_organization grporg_tbl_type;
    l_upd_organization grporg_tbl_type;
    l_view_organization grporg_tbl_type;
    l_noview_organization grporg_tbl_type;
    l_update_groups SYS.DBMS_SQL.NUMBER_TABLE;
    l_view_groups SYS.DBMS_SQL.NUMBER_TABLE;
    l_return_status VARCHAR2(10);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(300);
    l_privilege VARCHAR2(10);

    CURSOR c_lkup is
    SELECT LOOKUP_CODE , MEANING FROM CN_LOOKUPS
    WHERE lookup_type = 'ORGANIZATION' order by meaning;

BEGIN
   SAVEPOINT   Get_Grp_Organization_Access;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   for eachrec in c_lkup LOOP
      l_view_groups.delete;
      l_update_groups.delete;
      cn_sfp_srp_util_pvt.get_all_groups_access(p_api_version => l_api_version,
                                                p_org_code => eachrec.lookup_code,
                                                p_date => p_effective_date,
                                                x_update_groups => l_update_groups,
                                                x_view_groups => l_view_groups,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data);
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	  cn_sfp_srp_util_pvt.get_group_access(p_api_version => l_api_version,
					       p_group_id => p_comp_group_id,
					       p_update_groups => l_update_groups,
					       p_view_groups => l_view_groups,
					       x_privilege => l_privilege,
					       x_return_status => l_return_status,
					       x_msg_count => l_msg_count,
					       x_msg_data => l_msg_data);

	  IF (l_privilege = 'READ') THEN
	     l_updview_organization(l_updview_counter).org_code := eachrec.lookup_code;
	     l_updview_organization(l_updview_counter).org_meaning := eachrec.meaning;
	     l_updview_counter := l_updview_counter + 1;

	     l_view_organization(l_view_counter).org_code := eachrec.lookup_code;
	     l_view_organization(l_view_counter).org_meaning := eachrec.meaning;
	     l_view_counter := l_view_counter + 1;
	  END IF;


	  IF (l_privilege = 'WRITE') THEN
	     l_updview_organization(l_updview_counter).org_code := eachrec.lookup_code;
	     l_updview_organization(l_updview_counter).org_meaning := eachrec.meaning;
	     l_updview_counter := l_updview_counter + 1;

	     l_upd_organization(l_upd_counter).org_code := eachrec.lookup_code;
	     l_upd_organization(l_upd_counter).org_meaning := eachrec.meaning;
	     l_upd_counter := l_upd_counter + 1;
	  END IF;

	  IF (l_privilege = 'NO_READ') THEN
	     l_noview_organization(l_noview_counter).org_code := eachrec.lookup_code;
	     l_noview_organization(l_noview_counter).org_meaning := eachrec.meaning;
	     l_noview_counter := l_noview_counter + 1;
	  END IF;

      END IF;
   end loop;

   x_updview_organization := l_updview_organization;
   x_upd_organization := l_upd_organization;
   x_view_organization := l_view_organization;
   x_noview_organization := l_noview_organization;

   -- End of API body.
   << end_Get_Grp_Organ_Access >>
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Grp_Organization_Access  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Grp_Organization_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Get_Grp_Organization_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name) ;
      END IF ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
END Get_Grp_Organization_Access;

END CN_SFP_GROUP_UTIL_PVT;

/
