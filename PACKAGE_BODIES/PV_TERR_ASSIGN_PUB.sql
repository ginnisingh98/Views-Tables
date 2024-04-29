--------------------------------------------------------
--  DDL for Package Body PV_TERR_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TERR_ASSIGN_PUB" AS
/* $Header: pvxpptab.pls 120.6 2006/05/04 03:19:21 rdsharma ship $ */

-- Start of Comments
--
-- NAME
--   PV_TERR_ASSIGN_PUB
--
-- PURPOSE
--   This package is a public API for manipulating Channel Team related info into
--   PRM. It contains specification for pl/sql records and tables and the
--   Public API's for access and channel team manipulation
--
--   Procedures:
--	Create_Channel_Team
--      Create_Online_Channel_Team
--      Create_Vad_Channel_Team
--	Update_Channel_Team
--
-- NOTES
--   This package is for public use.
--
-- HISTORY
--   12/08/05   PINAGARA    Fixes for SQL Repository violations(Bug # 4869726)
--   07/27/05   PINAGARA    Restructured the APIs for easier handling
--   07/24/03   RDSHARMA    Created
--
-- End of Comments

 g_pkg_name            CONSTANT VARCHAR2(30):='PV_TERR_ASSIGN_PUB';

PROCEDURE Write_Log(p_which number, p_mssg  varchar2) IS
BEGIN
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
END Write_Log;

-- Start of Comments
--
--      Funtion name  : chk_prtnr_qflr_enabled
--      Type      : Public
--      Function  : The purpose of this function is to find out, whether
--                  the supplied partner qualifiers is enabled or not.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			p_prtnr_qualifier   IN NUMBER
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Procedure to find out, whther the supplied partner qualifier
--                      is enabled in the Qualifier Setup.
--
--
-- End of Comments
FUNCTION chk_prtnr_qflr_enabled (p_prtnr_qualifier IN  NUMBER )
RETURN VARCHAR2
IS

  l_prtnr_qlfr_enabled  VARCHAR2(1) ;

  CURSOR l_prtnr_qflr_csr(cv_prtnr_qualifier NUMBER) IS
     SELECT nvl(partner.Enabled_Flag,'N')
     FROM   JTF_QUAL_USGS_ALL partner
     WHERE  partner.org_id= 204
       AND  partner.Seeded_Qual_Id = cv_prtnr_qualifier
       AND  partner.QUAL_TYPE_USG_ID=-1701 ;

BEGIN

  l_prtnr_qlfr_enabled  := 'N';

   OPEN l_prtnr_qflr_csr(p_prtnr_qualifier);
   FETCH l_prtnr_qflr_csr INTO l_prtnr_qlfr_enabled ;
   CLOSE l_prtnr_qflr_csr ;

   return l_prtnr_qlfr_enabled;


END chk_prtnr_qflr_enabled ;

-- Start of Comments
--
--      Funtion name  : chk_partner_qflr_updated
--      Type      : Public
--      Function  : The purpose of this function is to find out, whether
--                  any of the updated partner qualifiers is enabled or not.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			p_upd_prtnr_qflr_flg_rec   IN prtnr_qflr_flg_rec_type
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Procedure to find out, whther the updated partner qualifier
--                      is enabled in the Qualifier Setup.
--
--
-- End of Comments
FUNCTION chk_partner_qflr_updated(p_upd_prtnr_qflr_flg_rec IN  prtnr_qflr_flg_rec_type )
RETURN VARCHAR2
IS
  l_prtnr_qflr_enabled    VARCHAR2(1) ;

BEGIN

  l_prtnr_qflr_enabled    := 'N';
   /*  Partner Qualifier Enabled Check for Partner_Name. */
   IF (p_upd_prtnr_qflr_flg_rec.partner_name_flg = 'Y' ) THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_name) = 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.partner_name_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_name)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Area Code. */
   IF (p_upd_prtnr_qflr_flg_rec.area_code_flg = 'Y' )THEN
       IF ( chk_prtnr_qflr_enabled(g_area_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.area_code_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_area_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for City. */
   IF (p_upd_prtnr_qflr_flg_rec.city_flg = 'Y' ) THEN
       IF ( chk_prtnr_qflr_enabled(g_city)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.city_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_city)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Country. */
   IF (p_upd_prtnr_qflr_flg_rec.country_flg = 'Y' ) THEN
       IF ( chk_prtnr_qflr_enabled(g_country)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.country_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_country)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for County. */
   IF (p_upd_prtnr_qflr_flg_rec.county_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_county)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.county_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_county)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Postal Code. */
   IF (p_upd_prtnr_qflr_flg_rec.postal_code_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_postal_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.postal_code_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_postal_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Province. */
   IF (p_upd_prtnr_qflr_flg_rec.province_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_province)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.province_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_province)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for State. */
   IF (p_upd_prtnr_qflr_flg_rec.state_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_state)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.state_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_state)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Annual Revenue. */
   IF (p_upd_prtnr_qflr_flg_rec.Annual_Revenue_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_Annual_Revenue)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.Annual_Revenue_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_Annual_Revenue)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Number Of Employees. */
   IF (p_upd_prtnr_qflr_flg_rec.number_of_employee_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_number_of_employee)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.number_of_employee_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_number_of_employee)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Customer Category Code. */
   IF (p_upd_prtnr_qflr_flg_rec.cust_catgy_code_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_cust_catgy_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.cust_catgy_code_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_cust_catgy_code)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Partner Type. */
   IF (p_upd_prtnr_qflr_flg_rec.partner_type_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_type)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.partner_type_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_type)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   /*  Partner Qualifier Enabled Check for Partner Level. */
   IF (p_upd_prtnr_qflr_flg_rec.partner_level_flg = 'Y'  ) THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_level)= 'Y') THEN
            l_prtnr_qflr_enabled := 'Y';
	    return l_prtnr_qflr_enabled;
       END IF;
   ELSIF (p_upd_prtnr_qflr_flg_rec.partner_level_flg = 'U') THEN
       IF ( chk_prtnr_qflr_enabled(g_partner_level)= 'Y') THEN
            l_prtnr_qflr_enabled := 'U';
       END IF;
   END IF;

   return l_prtnr_qflr_enabled;

END chk_partner_qflr_updated;



-- Start of Comments
--
--      Funtion name  : GET_RES_FROM_TEAM_GROUP
--      Type      : Public
--      Function  : The purpose of this procedure is to explode the resources,
--                  if the resource_type is 'RS_TEAM' or 'RS_GROUP'.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			P_RESOURCE_ID   IN NUMBER,
--			P_RESOURCE_TYPE IN VARCHAR2,
--      OUT             :
--			X_RESOURCE_REC  OUT PV_TERR_ASSIGN_PUB.ResourceRec
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Procedure to explode the resource team or resource group upto
--                      individual level.
--
--
-- End of Comments
PROCEDURE GET_RES_FROM_TEAM_GROUP(
 P_RESOURCE_ID   IN NUMBER,
 P_RESOURCE_TYPE IN VARCHAR2,
 X_RESOURCE_REC  OUT NOCOPY PV_TERR_ASSIGN_PUB.ResourceRec
)
IS

l_resource_group_id number;
l_resource_team_id number;

BEGIN

if (p_resource_type is null OR p_resource_id is null) then

   return;
end if;
/* PINAGARA: introduced m.group_id = u.group_id join condition as bug fix # 4869726 */
if p_resource_type = 'RS_GROUP' then

   l_resource_group_id := p_resource_id;

   SELECT resource_id, person_id, resource_category, group_id
   BULK COLLECT INTO
   	     x_resource_rec.resource_id,
   	     x_resource_rec.person_id,
   	     x_resource_rec.resource_category,
   	     x_resource_rec.group_id
   FROM
   ( SELECT  distinct m.resource_id resource_id,
                    m.person_id person_id,
                    res.category resource_category,
                    m.group_id group_id
     FROM  jtf_rs_groups_b g,
           jtf_rs_group_usages u,
           jtf_rs_group_members m,
           jtf_rs_role_relations rr,
           jtf_rs_roles_b r,
           jtf_rs_resource_extns res
    WHERE g.group_id = l_resource_group_id
    AND sysdate between nvl(g.start_date_active,sysdate) and
                      nvl(g.end_date_active,sysdate)
    AND u.group_id = g.group_id
    AND u.usage  =  'PRM'
    AND m.group_id = g.group_id
    AND m.group_id = u.group_id
    AND m.group_member_id = rr.role_resource_id
    AND rr.role_resource_type = 'RS_GROUP_MEMBER'
    AND NVL(rr.delete_flag,'N') <> 'Y'
    AND sysdate between rr.start_date_active and
                    nvl(rr.end_date_active,sysdate)
    AND rr.role_id = r.role_id
    AND r.role_code in ('CHANNEL_MANAGER', 'CHANNEL_REP')
    AND r.role_type_code = 'PRM'
    AND r.active_flag = 'Y'
    AND r.member_flag = 'Y'
    AND res.resource_id = m.resource_id
    AND res.category IN ('EMPLOYEE', 'PARTY')
    AND sysdate between nvl(res.start_date_active,sysdate) and
                      nvl(res.end_date_active,sysdate)
    AND res.user_id IS NOT NULL ) j
    WHERE j.group_id = l_resource_group_id;


end if;

if p_resource_type = 'RS_TEAM' then

   l_resource_team_id := p_resource_id;

   SELECT resource_id, person_id, resource_category, group_id
    BULK COLLECT INTO
   	     x_resource_rec.resource_id,
   	     x_resource_rec.person_id,
   	     x_resource_rec.resource_category,
   	     x_resource_rec.group_id
	     FROM (
   SELECT min(tm.team_resource_id) resource_id,
       min(tm.person_id) person_id,
       min(g.group_id) group_id,
       min(t.team_id) team_id,
       tres.category resource_category
FROM   jtf_rs_team_members tm,
       jtf_rs_teams_b t,
       jtf_rs_team_usages tu,
       jtf_rs_role_relations trr,
       jtf_rs_roles_b tr,
       jtf_rs_resource_extns tres,
       (
       SELECT m.group_id group_id,
              m.resource_id resource_id
       FROM   jtf_rs_group_members m,
              jtf_rs_groups_b g,
              jtf_rs_group_usages u,
              jtf_rs_role_relations rr,
              jtf_rs_roles_b r,
              jtf_rs_resource_extns res
       WHERE  m.group_id = g.group_id
       AND    sysdate BETWEEN nvl(g.start_date_active,sysdate)
                          AND nvl(g.end_date_active,sysdate)
       AND    u.group_id = g.group_id
       AND    u.usage = 'PRM'
       AND    m.group_member_id = rr.role_resource_id
       AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
       AND    rr.delete_flag <> 'Y'
       AND    sysdate between rr.start_date_active
                          AND nvl(rr.end_date_active,sysdate)
       AND    rr.role_id = r.role_id
       AND    r.role_type_code in ('PRM')
       AND    r.active_flag = 'Y'
       AND    res.resource_id = m.resource_id
       AND    sysdate between nvl(res.start_date_active,sysdate) and
                      nvl(res.end_date_active,sysdate)
       AND    res.category IN ('EMPLOYEE','PARTY') )  g         /* Added PARTY category also */
WHERE  tm.team_id = t.team_id
AND    sysdate between nvl(t.start_date_active,sysdate)
                   AND nvl(t.end_date_active,sysdate)
AND    tu.team_id = t.team_id
AND    tu.usage = 'PRM'
AND    tm.team_member_id = trr.role_resource_id
AND    tm.delete_flag <> 'Y'
AND    tm.resource_type = 'INDIVIDUAL'
AND    trr.role_resource_type = 'RS_TEAM_MEMBER'
AND    trr.delete_flag <> 'Y'
AND   sysdate between trr.start_date_active
                AND nvl(trr.end_date_active,sysdate)
AND   trr.role_id = tr.role_id
AND   tr.role_type_code in ('PRM')
AND   tr.active_flag = 'Y'
AND   tres.resource_id = tm.team_resource_id
AND   sysdate between nvl(tres.start_date_active,sysdate) and
                      nvl(tres.end_date_active,sysdate)
AND   tres.category IN ('EMPLOYEE','PARTY')
AND   tm.team_resource_id = g.resource_id
GROUP BY tm.team_member_id, tm.team_resource_id, tm.person_id, tres.category
UNION
  SELECT min(m.resource_id) resource_id,
         min(m.person_id) person_id,
         min(m.group_id) group_id,
         min(jtm.team_id) team_id,
         res.category resource_category
  FROM  jtf_rs_group_members m,
        jtf_rs_groups_b g,
        jtf_rs_group_usages u,
        jtf_rs_role_relations rr,
        jtf_rs_roles_b r,
        jtf_rs_resource_extns res,
        (
        SELECT tm.team_resource_id group_id, t.team_id team_id
        FROM   jtf_rs_team_members tm,
               jtf_rs_teams_b t,
               jtf_rs_team_usages tu,
               jtf_rs_role_relations trr,
               jtf_rs_roles_b tr,
               jtf_rs_resource_extns tres
        WHERE  tm.team_id = t.team_id
        AND    sysdate between nvl(t.start_date_active,sysdate)
                                          and nvl(t.end_date_active,sysdate)
        AND   tu.team_id = t.team_id
        AND   tu.usage = 'PRM'
        AND   tm.team_member_id = trr.role_resource_id
        AND   tm.delete_flag <> 'Y'
        AND   tm.resource_type = 'GROUP'
        AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
        AND   trr.delete_flag <> 'Y'
        AND   sysdate between trr.start_date_active and
                                          nvl(trr.end_date_active,sysdate)
        AND   trr.role_id = tr.role_id
        AND   tr.role_type_code in ('PRM')
        AND   tr.active_flag = 'Y'
        AND   tres.resource_id = tm.team_resource_id
        AND   sysdate between nvl(tres.start_date_active,sysdate) and
                      nvl(tres.end_date_active,sysdate)
        AND   tres.category IN ('EMPLOYEE','PARTY')  ) jtm
  WHERE m.group_id = g.group_id
  AND  sysdate between nvl(g.start_date_active,sysdate) and
                      nvl(g.end_date_active,sysdate)
  AND   u.group_id = g.group_id
  AND   u.usage = 'PRM'
  AND   m.group_member_id = rr.role_resource_id
  AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
  AND   rr.delete_flag <> 'Y'
  AND   sysdate between rr.start_date_active and
                                  nvl(rr.end_date_active,sysdate)
  AND   rr.role_id = r.role_id
  AND   r.role_type_code in ( 'PRM')
  AND   r.active_flag = 'Y'
  AND   res.resource_id = m.resource_id
  AND   res.category IN ('EMPLOYEE','PARTY')
  AND   sysdate between nvl(res.start_date_active,sysdate) and
                      nvl(res.end_date_active,sysdate)
  AND   jtm.group_id = g.group_id
group by m.resource_id, m.person_id, m.group_id, res.category ) j
        where
              j.team_id = l_resource_team_id
        and   j.resource_category IN ('EMPLOYEE', 'PARTY');

end if;

EXCEPTION
WHEN others THEN
     PVX_UTILITY_PVT.debug_message('Exception: others in Get_resource_from_team_group');
     PVX_UTILITY_PVT.debug_message('SQLCODE ' || to_char(SQLCODE) ||
				   'SQLERRM ' || substr(SQLERRM, 1, 100));
END GET_RES_FROM_TEAM_GROUP;

-- Start of Comments
--
--      Funtion name  : check_resource_exist
--      Type      : Private
--      Function  : The purpose of this function is to to check, whether the
--                  given resource and the partner org record does not exists
--                  in the PV_PARTNER_ACCESSES table.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_partner_id           IN      NUMBER,
--              p_resource_id          IN      NUMBER
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments
FUNCTION check_resource_exist(p_partner_id IN NUMBER , p_resource_id IN NUMBER)
RETURN VARCHAR2
IS
    l_resource_exist   VARCHAR2(1) ;

    CURSOR l_chk_resource_exist_csr(cv_partner_id NUMBER, cv_resource_id NUMBER) IS
        SELECT 'Y'
        FROM PV_PARTNER_ACCESSES
        WHERE partner_id = cv_partner_id
        AND resource_id = cv_resource_id ;
BEGIN
    l_resource_exist   := 'N';
      OPEN l_chk_resource_exist_csr(p_partner_id, p_resource_id );
      FETCH l_chk_resource_exist_csr INTO l_resource_exist;

      IF ( l_chk_resource_exist_csr%NOTFOUND ) THEN
           l_resource_exist := 'N';
      END IF;
      CLOSE l_chk_resource_exist_csr;

     return l_resource_exist;
END check_resource_exist;

-- Start of Comments
--
--      Funtion name  : check_channel_team_exist
--      Type      : Private
--      Function  : The purpose of this function is to to check, whether there is any channel team
--                  assigned for this PARTNER
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_partner_id           IN      NUMBER,
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a channel team
--
--
-- End of Comments
FUNCTION check_channel_team_exist(p_partner_id IN NUMBER )
RETURN VARCHAR2
IS
    l_exist   VARCHAR2(1) ;

    CURSOR l_chk_channel_team_exist_csr(cv_partner_id NUMBER) IS
        SELECT 'Y'
        FROM PV_PARTNER_ACCESSES
        WHERE partner_id = cv_partner_id;
BEGIN
    l_exist   := 'N';
      OPEN l_chk_channel_team_exist_csr(p_partner_id);
      FETCH l_chk_channel_team_exist_csr INTO l_exist;

      IF ( l_chk_channel_team_exist_csr%NOTFOUND ) THEN
           l_exist := 'N';
      END IF;
      CLOSE l_chk_channel_team_exist_csr;

     return l_exist;
END check_channel_team_exist;
-- Start of Comments
--
--      Funtion name  : Check_Territory_Exist
--      Type      : Private
--      Function  : The purpose of this function is to to check, whether for
--                  the given territory_id and the partner_access_id, record
--                  exists in the PV_TAP_ACCESS_TERRS table or not.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--		    p_terr_id              IN      NUMBER,
--                  p_partner_access_id    IN      NUMBER
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a record for a given
--                      terr_id and the partner_access_id
--
--
-- End of Comments
FUNCTION Check_Territory_Exist(p_terr_id IN NUMBER , p_partner_access_id IN NUMBER)
RETURN VARCHAR2
IS
    l_territory_exist   VARCHAR2(1) ;
    CURSOR l_chk_terr_exist_csr(cv_terr_id NUMBER, cv_partner_access_id NUMBER) IS
      SELECT 'Y'
      FROM PV_TAP_ACCESS_TERRS
      WHERE terr_id =  cv_terr_id
      AND partner_access_id = cv_partner_access_id ;
BEGIN
      l_territory_exist   := 'N';
      OPEN l_chk_terr_exist_csr(p_terr_id,  p_partner_access_id );
      FETCH l_chk_terr_exist_csr INTO l_territory_exist;
      CLOSE l_chk_terr_exist_csr;

      return nvl(l_territory_exist,'N');
END Check_Territory_Exist;

-- Start of Comments
--
--      Funtion name  : Chk_Res_Is_Vad_Employee
--      Type      : Private
--      Function  : The purpose of this procedure is to check, whether the resource
--                  belongs to the supplied vad_partner_id is an employee also of
--                  that vad organization.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_vad_partner_id     IN  NUMBER,
--                          p_resource_id        IN  NUMBER,
--
--      OUT             :
--
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments

FUNCTION Chk_Res_Is_Vendor_CM(p_resource_id    IN  NUMBER )
RETURN VARCHAR2
IS

 l_res_is_vendor_CM  VARCHAR2(1) ;

 /* PINAGARA: Introduced jtf_rs_groups_b table as bug fix for 4869726 */
  CURSOR l_res_is_vendor_CM_csr(cv_resource_id NUMBER) IS
      SELECT 'Y'
       FROM   jtf_rs_resource_extns RES,
              jtf_rs_group_members GRPMEM,
              jtf_rs_group_usages GRPUSG,
              jtf_rs_role_relations ROLRELAT ,
              jtf_rs_roles_vl ROLE,
              jtf_rs_groups_b b

       WHERE  RES.resource_id = cv_resource_id
         AND  RES.category = 'EMPLOYEE'
         AND  sysdate between nvl(RES.start_date_active,sysdate) and
                      nvl(RES.end_date_active,sysdate)
         AND  RES.resource_id = GRPMEM.resource_id
         AND  nvl(GRPMEM.delete_flag, 'N') = 'N'
         AND  GRPMEM.group_id = GRPUSG.group_id
         AND  GRPMEM.group_id = b.group_id
         AND  b.group_id = GRPUSG.group_id
         AND  GRPUSG.usage IN ('PRM')
         AND  GRPMEM.group_member_id=ROLRELAT.role_resource_id
         AND  ROLRELAT.role_resource_type = 'RS_GROUP_MEMBER'
         AND  NVL(ROLRELAT.delete_flag,'N') = 'N'
         AND  ROLRELAT.start_date_active <= sysdate
         AND  NVL(ROLRELAT.end_date_active,sysdate) >= sysdate
         AND  ROLRELAT.role_id = ROLE.ROLE_ID
         AND  ROLE.role_code in( 'CHANNEL_MANAGER' ,'CHANNEL_REP')
         AND  ROLE.role_type_code in ('PRM')
         AND  ROLE.MEMBER_FLAG = 'Y'  ;

BEGIN
   l_res_is_vendor_CM  := 'N';
   OPEN l_res_is_vendor_CM_csr( p_resource_id);
   FETCH l_res_is_vendor_CM_csr INTO l_res_is_vendor_CM ;

   IF (l_res_is_vendor_CM_csr%NOTFOUND) THEN
     l_res_is_vendor_CM := 'N' ;
   END IF;

   CLOSE l_res_is_vendor_CM_csr;
   return l_res_is_vendor_CM;

END Chk_Res_Is_Vendor_CM;

-- Start of Comments
--
--      Funtion name  : Chk_Res_Is_Vad_CM
--      Type      : Private
--      Function  : The purpose of this procedure is to check, whether the resource
--                  belongs to the supplied vad_partner_id is an employee also of
--                  that vad organization.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_vad_partner_id     IN  NUMBER,
--                          p_resource_id        IN  NUMBER,
--
--      OUT             :
--
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments
FUNCTION Chk_Res_Is_Vad_CM(p_res_vad_partner_id IN  NUMBER,
                                 p_resource_id    IN  NUMBER )
RETURN VARCHAR2
IS
 l_res_is_vad_employee  VARCHAR2(1) ;
 l_is_vad_partner  VARCHAR2(1) ;

 -- Changed the logic to fix the SQL Repository violation
 -- by checking the partner_type check first and then checking the
 -- resource.
  CURSOR l_is_vad_partner_csr(cv_partner_id NUMBER) IS
      SELECT 'Y'
      FROM pv_enty_attr_values ATTR
      WHERE ATTR.entity_id = cv_partner_id
      AND ATTR.entity= 'PARTNER'
      AND ATTR.attribute_id = 3
      AND ATTR.attr_value = 'VAD'
      AND ATTR.latest_flag = 'Y'
      AND ATTR.enabled_flag = 'Y' ;

  CURSOR l_res_is_vad_emp_csr(cv_partner_id NUMBER, cv_resource_id NUMBER) IS
-- PINAGARA Changed the code to use subquery as a fix for bug # 4869726
SELECT 'Y'
      FROM
         pv_partner_profiles PROFILE,
         hz_relationships HZPR_PART_CONT ,
         hz_parties CONTACT ,
         jtf_rs_resource_extns RES
      WHERE
      PROFILE.partner_id = cv_partner_id
      AND PROFILE.partner_party_id = HZPR_PART_CONT.object_id
      AND HZPR_PART_CONT.RELATIONSHIP_TYPE = 'EMPLOYMENT'
      AND HZPR_PART_CONT.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND HZPR_PART_CONT.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND HZPR_PART_CONT.status = 'A'
      AND HZPR_PART_CONT.start_date <= SYSDATE
      AND NVL(HZPR_PART_CONT.end_date,SYSDATE) >= SYSDATE
      AND HZPR_PART_CONT.subject_id = CONTACT.PARTY_ID
      AND HZPR_PART_CONT.subject_type = 'PERSON'
      AND HZPR_PART_CONT.party_id = RES.source_id
      AND RES.category = 'PARTY'
      AND RES.resource_id = cv_resource_id -- 100000944 100069925
      AND sysdate between nvl(RES.start_date_active,sysdate) and
                      nvl(RES.end_date_active,sysdate)
      AND RES.resource_id IN (
                            SELECT GRPMEM.resource_id
                            FROM
                                jtf_rs_group_members GRPMEM,
                                jtf_rs_groups_b GROUPB,
                                jtf_rs_group_usages GRPUSG,
                                jtf_rs_role_relations ROLRELAT ,
                                jtf_rs_roles_vl ROLE

                            WHERE GRPMEM.resource_id = RES.resource_id
                            AND nvl(GRPMEM.delete_flag, 'N') = 'N'
                            AND GRPMEM.group_id = GROUPB.group_id
                            AND GROUPB.group_id = GRPUSG.group_id
                            AND GRPUSG.usage IN ('PRM')
                            AND GRPMEM.group_member_id=ROLRELAT.role_resource_id
                            AND ROLRELAT.role_resource_type = 'RS_GROUP_MEMBER'
                            AND NVL(ROLRELAT.delete_flag,'N') = 'N'
                            AND ROLRELAT.start_date_active <= sysdate
                            AND NVL(ROLRELAT.end_date_active,sysdate) >= sysdate
                            AND ROLRELAT.role_id = ROLE.ROLE_ID
                            AND ROLE.role_code in( 'CHANNEL_MANAGER' ,'CHANNEL_REP')
                            AND ROLE.role_type_code in ('PRM')
                            AND ROLE.MEMBER_FLAG = 'Y') ;

BEGIN
   l_res_is_vad_employee  := 'N';
   l_is_vad_partner  := 'N';

   OPEN l_is_vad_partner_csr(p_res_vad_partner_id);
   FETCH l_is_vad_partner_csr INTO l_is_vad_partner ;

   IF ( l_is_vad_partner_csr%FOUND) THEN
   	OPEN l_res_is_vad_emp_csr(p_res_vad_partner_id, p_resource_id);
   	FETCH l_res_is_vad_emp_csr INTO l_res_is_vad_employee ;
   	CLOSE l_res_is_vad_emp_csr;
   END IF;

   CLOSE l_res_is_vad_emp_csr;
   return l_res_is_vad_employee;

END Chk_Res_Is_Vad_CM;

-- Start of Comments
--
--      Funtion name  : Chk_To_Create_Access_Rec
--      Type      : Private
--      Function  : The purpose of this procedure is to check, whether we can cretae a
--                  record in PV_PARTNER_ACCESSES table for the supplied resource_id
--                  and the given partner_id.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_partner_id         IN  NUMBER,
--                          p_resource_id        IN  NUMBER,
--                          p_resource_category  IN  VARCHAR2,
--                          p_partner_type       IN  NUMBER
--      OUT             :
--                         x_res_created_flg    OUT NOCOPY VARCHAR2,
--                         x_partner_access_id  OUT NOCOPY NUMBER
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments
PROCEDURE Chk_To_Create_Access_Rec(
    p_partner_id        IN NUMBER,
    p_resource_id       IN NUMBER,
    p_resource_category IN VARCHAR2,
    p_partner_type      IN VARCHAR2,
    p_vad_partner_id    IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_res_created_flg   OUT NOCOPY VARCHAR2,
    x_tap_created_flg   OUT NOCOPY VARCHAR2,
    x_partner_access_id OUT NOCOPY NUMBER)
 IS
   l_res_created_flg   VARCHAR2(1)  ;
   l_tap_created_flg   VARCHAR2(1)  ;
   l_partner_access_id     NUMBER;
   l_VAD_partner_id    NUMBER;
   l_partner_access_rec  PV_Partner_Accesses_PVT.partner_access_rec_type;

   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR(2000);

   -- Cursor l_chk_resource_exist_csr to check whether given resource_id and partner_id exists in
   -- PV_PARTNER_ACCESSES table or not.
   CURSOR l_chk_resource_exist_csr (cv_partner_id IN NUMBER, cv_resource_id IN NUMBER) IS
      SELECT partner_access_id,
             created_by_tap_flag
      FROM PV_PARTNER_ACCESSES
      WHERE partner_id = cv_partner_id
      AND   resource_id = cv_resource_id;

   CURSOR l_VAD_Org_csr(cv_resource_id IN NUMBER) IS
      SELECT source_org_id
      FROM   jtf_rs_resource_extns RES
      WHERE resource_id = cv_resource_id;

 BEGIN

      -- Initialize the return status
      x_return_status := FND_API.g_ret_sts_success;
    /* Logic for Resource Validation, whether the resource is a 'EMPLOYEE' or a 'PARTY' */
    l_res_created_flg   := 'N' ;
    l_tap_created_flg   := 'N' ;
    l_res_created_flg := 'N' ;
    l_partner_access_id := -1;
    OPEN l_chk_resource_exist_csr( p_partner_id,  p_resource_id);
    FETCH l_chk_resource_exist_csr INTO l_partner_access_id, l_tap_created_flg ;

    /************************************ MODIFIED LOGIC  *******************************************/

      IF (l_chk_resource_exist_csr%NOTFOUND) THEN

        CLOSE l_chk_resource_exist_csr;
        l_partner_access_rec.vad_partner_id := NULL;
        IF ( p_vad_partner_id IS NULL or p_vad_partner_id = FND_API.G_MISS_NUM ) THEN
             IF (p_partner_type <> 'VAD' ) THEN
	         IF ( p_resource_category = 'EMPLOYEE' ) THEN
	              IF ( chk_res_is_Vendor_CM(p_resource_id) = 'Y' ) THEN
		           l_res_created_flg := 'Y';
		      END IF;
                 ELSIF ( p_resource_category = 'PARTY' ) THEN
                      OPEN l_VAD_Org_csr(p_resource_id);
	                  FETCH l_VAD_Org_csr INTO l_VAD_partner_id;
	                  IF ( l_VAD_Org_csr%FOUND ) THEN
                               CLOSE l_VAD_Org_csr;
		               IF (Chk_Res_Is_Vad_CM(l_VAD_partner_id, p_resource_id )= 'Y' ) THEN
                                   l_res_created_flg := 'Y';
  		                   l_partner_access_rec.vad_partner_id := l_vad_partner_id;
		               END IF;
		          ELSE
                               CLOSE l_VAD_Org_csr;
		          END IF;
	         END IF;
	     ELSIF (p_partner_type = 'VAD') THEN
                IF ( p_resource_category = 'EMPLOYEE' ) THEN
	             IF ( chk_res_is_Vendor_CM(p_resource_id) = 'Y' ) THEN
		          l_res_created_flg := 'Y';
		     END IF;
                END IF;
            END IF;
      ELSE    /* p_vad_partner_id IS NOT NULL */
         IF (p_partner_type ='VAD' ) THEN
	         l_res_created_flg := 'E' ;
	     ELSE  /* ELSE part of p_partner_type IS NOT 'VAD'  */
	         IF ( p_resource_category = 'EMPLOYEE' ) THEN
	              IF ( chk_res_is_Vendor_CM(p_resource_id) = 'Y' ) THEN
		               l_res_created_flg := 'Y';
		          END IF;
             ELSIF (p_resource_category = 'PARTY') THEN
                OPEN l_VAD_Org_csr(p_resource_id);
	            FETCH l_VAD_Org_csr INTO l_VAD_partner_id;
                IF ( l_VAD_Org_csr%FOUND ) THEN
                     CLOSE l_VAD_Org_csr;
		             IF (Chk_Res_Is_Vad_CM(l_VAD_partner_id, p_resource_id )= 'Y' ) THEN
                          l_res_created_flg := 'Y';
  		                  l_partner_access_rec.vad_partner_id := l_vad_partner_id;
		             END IF;
		        ELSE
                     CLOSE l_VAD_Org_csr;
		        END IF;
             END IF;
	     END IF;
      END IF;  -- l_chk_resource_exist_csr%NOTFOUND

  /********************************** END MODIFIED LOGIC ******************************************/
    IF ( l_res_created_flg = 'Y') THEN
         /* Set the p_partner_access_rec record */
	 l_partner_access_rec.partner_id  := p_partner_id;
         l_partner_access_rec.resource_id := p_resource_id;
	 l_partner_access_rec.keep_flag   := 'N';
         l_partner_access_rec.created_by_tap_flag := 'Y';
         l_partner_access_rec.access_type := 'F';

	 PV_Partner_Accesses_PVT.Create_Partner_Accesses(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_partner_access_rec => l_partner_access_rec,
            x_partner_access_id  => l_partner_access_id );

	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

    END IF; /* l_res_created_flg = 'Y' */

    -- Store output variables
    x_res_created_flg := l_res_created_flg;
    x_partner_access_id := l_partner_access_id ;
    x_tap_created_flg := l_tap_created_flg;
    END IF;

 EXCEPTION
  WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;
 END Chk_To_Create_Access_Rec;

-- Start of Comments
--
--      Funtion name  : Cr_Login_User_Access_Rec
--      Type      : Private
--      Function  : The purpose of this procedure is to add the logged-in user to
--                  PV_PARTNER_ACCESSES table as a Channel team member, if the logged
--                  in user has a 'CHANNEL_MANAGER' or CHANNEL_REP' role.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			    p_partner_id           IN      NUMBER,
--                          p_login_user_id        IN      NUMBER,
--      OUT             :
--                          x_cm_added             OUT     VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments
PROCEDURE Cr_Login_User_Access_Rec(
              p_partner_id     IN NUMBER,
              p_login_user_id  IN NUMBER,
	      x_return_status  OUT  NOCOPY  VARCHAR2,
              x_msg_count      OUT  NOCOPY  NUMBER,
              x_msg_data       OUT  NOCOPY  VARCHAR2,
              x_cm_added       OUT  NOCOPY  VARCHAR2,
	      x_res_created_flg   OUT NOCOPY VARCHAR2,
              x_partner_access_id OUT NOCOPY NUMBER )
IS

-- CURSOR to check, the logged-in user(Vendor Employee) has
-- a CHANNEL_MANAGER or 'CHANNEL_REP' role.

  CURSOR l_get_resource_id_csr (cv_user_id  NUMBER) IS
       SELECT resource_id
       FROM   jtf_rs_resource_extns
       WHERE  user_id = cv_user_id
         AND sysdate between nvl(start_date_active,sysdate) and
                      nvl(end_date_active,sysdate);

   CURSOR l_user_exists_csr(cv_partner_id NUMBER,
                            cv_resource_id NUMBER ) IS
	SELECT 'Y'
	FROM PV_PARTNER_ACCESSES
        WHERE partner_id = cv_partner_id
	AND   resource_id = cv_resource_id;

 l_resource_id       NUMBER ;
 l_return_status     VARCHAR2(1);
 l_msg_count         NUMBER;
 l_msg_data          VARCHAR(2000);
 l_resource_category VARCHAR2(30);
 l_res_created_flg   VARCHAR2(1) ;
 l_partner_access_id NUMBER;
 l_cm_added          VARCHAR2(1) ;
 l_user_exists       VARCHAR2(1) ;
 l_partner_access_rec  PV_Partner_Accesses_PVT.partner_access_rec_type;

BEGIN

    l_res_created_flg := 'N';
    l_cm_added        := 'N';
    l_user_exists     := 'N';

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       PVX_Utility_PVT.debug_message('Procedure : Cr_Login_User_Access_Rec Start');
    END IF;

    OPEN l_get_resource_id_csr(p_login_user_id) ;
    FETCH l_get_resource_id_csr INTO l_resource_id ;

    IF (l_get_resource_id_csr%FOUND) THEN
        CLOSE l_get_resource_id_csr;
   	IF (Chk_Res_Is_Vendor_CM(l_resource_id) = 'Y' ) THEN

            OPEN l_user_exists_csr(p_partner_id, l_resource_id);
	    FETCH l_user_exists_csr  INTO l_user_exists ;
            IF (l_user_exists_csr%NOTFOUND ) THEN
               /* Call Chk_To_Create_Access_Rec procedure to create the logged
                  in user record in the PV_PARTNER_ACCESSES table */
               /* Set the p_partner_access_rec record */
	       l_partner_access_rec.partner_id  := p_partner_id;
               l_partner_access_rec.resource_id := l_resource_id;
	       l_partner_access_rec.keep_flag   := 'Y';
               l_partner_access_rec.created_by_tap_flag := 'N';
               l_partner_access_rec.access_type := 'F';

	       PV_Partner_Accesses_PVT.Create_Partner_Accesses(
                       p_api_version_number => 1.0,
                       p_init_msg_list      => FND_API.G_FALSE,
                       p_commit             => FND_API.G_FALSE,
                       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                       x_return_status      => l_return_status,
                       x_msg_count          => l_msg_count,
                       x_msg_data           => l_msg_data,
                       p_partner_access_rec => l_partner_access_rec,
                       x_partner_access_id  => l_partner_access_id );

	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                       RAISE FND_API.G_EXC_ERROR;
                   ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

               -- Store the output variables.
               x_res_created_flg   := 'Y';
               x_partner_access_id := l_partner_access_id;
               x_cm_added          := 'Y';
            END IF;  /* l_user_exists = 'Y' */
            CLOSE l_user_exists_csr;
        END IF ; /*Chk_Res_Is_Vendor_CM(l_resource_id) = 'Y'*/
    ELSE
       CLOSE l_get_resource_id_csr;
    END IF; /* (l_get_resource_id_csr%FOUND) */

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       PVX_Utility_PVT.debug_message('Procedure : Cr_Login_User_Access_Rec End');
    END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Cr_Login_User_Access_Rec(-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Cr_Login_User_Access_Rec(-)');
      END IF;

    WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Cr_Login_User_Access_Rec(-)');
      END IF;
END Cr_Login_User_Access_Rec;

-- Start of Comments
--
--      Funtion name  : TAP_Get_Channel_Team
--      Type      : Private
--      Function  : The purpose of this function is to get the Channel Manager and
--                  Channel Rep by calling the JTF owned Territroy Assignment API.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--	        p_prtnr_qualifier_rec  IN     QUALIFIER_REC_TYPE,
--
--      OUT             :
--              x_return_Status        OUT  NOCOPY  VARCHAR2,
--              x_msg_Count            OUT  NOCOPY  NUMBER,
--              x_msg_Data             OUT  NOCOPY  VARCHAR2,
--              x_winners_rec          OUT  NOCOPY  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Function for checking the existence of a given partner_id
--                      and the resource_id.
--
--
-- End of Comments
PROCEDURE TAP_Get_Channel_Team(
   p_prtnr_qualifier_rec    IN   partner_qualifiers_rec_type,
   x_return_Status          OUT  NOCOPY  VARCHAR2,
   x_msg_Count              OUT  NOCOPY  NUMBER,
   x_msg_Data               OUT  NOCOPY  VARCHAR2,
   x_winners_rec            OUT  NOCOPY  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type
   ) IS

  CURSOR l_get_Currency(cv_party_id NUMBER) IS
   SELECT pref_functional_currency
     FROM HZ_ORGANIZATION_PROFILES
    WHERE effective_end_date is NULL
      AND party_id = cv_party_id;

  l_counter  NUMBER;
  l_winners_rec	        JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_gen_bulk_rec        JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR(2000);
  l_curr_code         VARCHAR2(30):= null;

 BEGIN
     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message('Procedure TAP_Get_Channel_Managers Start.');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Initialize message list.
     FND_MSG_PUB.initialize;

     -- bulk_trans_rec_type instantiation
   -- logic control properties
   l_gen_bulk_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
   l_gen_bulk_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

   l_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR02.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR03.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR05.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR06.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR08.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR09.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR10.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR11.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR12.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR13.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR14.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR15.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR16.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR17.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR18.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR19.EXTEND;
   l_gen_bulk_rec.SQUAL_CHAR20.EXTEND;

   l_gen_bulk_rec.SQUAL_NUM01.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM02.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM03.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM04.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM05.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM06.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM07.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM08.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM09.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM10.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM11.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM12.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM13.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM14.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM15.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM16.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM17.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM18.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM19.EXTEND;
   l_gen_bulk_rec.SQUAL_NUM20.EXTEND;

   /* Added for Currency Code suggested by ARPATEL in bug #3556250 */
   l_gen_bulk_rec.SQUAL_CURC01.EXTEND;

   -- transaction qualifier values
   l_gen_bulk_rec.SQUAL_CHAR01(1) := p_prtnr_qualifier_rec.partner_name;    -- Partner Name Range
   l_gen_bulk_rec.SQUAL_CHAR02(1) := p_prtnr_qualifier_rec.city;            -- City
   l_gen_bulk_rec.SQUAL_CHAR03(1) := p_prtnr_qualifier_rec.county;          -- County
   l_gen_bulk_rec.SQUAL_CHAR04(1) := p_prtnr_qualifier_rec.state;           -- State
   l_gen_bulk_rec.SQUAL_CHAR05(1) := p_prtnr_qualifier_rec.province;        -- Province
   l_gen_bulk_rec.SQUAL_CHAR06(1) := p_prtnr_qualifier_rec.postal_code;     -- Postal Code
   l_gen_bulk_rec.SQUAL_CHAR07(1) := p_prtnr_qualifier_rec.country;         -- Country
   l_gen_bulk_rec.SQUAL_CHAR08(1) := p_prtnr_qualifier_rec.area_code;       -- Area Code
   l_gen_bulk_rec.SQUAL_CHAR09(1) := p_prtnr_qualifier_rec.customer_category_code;   -- Customer Category
   l_gen_bulk_rec.SQUAL_CHAR10(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR11(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR12(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR13(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR14(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR15(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR16(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR17(1) := null;
   l_gen_bulk_rec.SQUAL_CHAR18(1) := p_prtnr_qualifier_rec.partner_type;
   l_gen_bulk_rec.SQUAL_CHAR19(1) := p_prtnr_qualifier_rec.partner_level;
   l_gen_bulk_rec.SQUAL_CHAR20(1) := null;

      -- transaction qualifier values
   l_gen_bulk_rec.SQUAL_NUM01(1) := p_prtnr_qualifier_rec.party_id;                 -- PARTY_ID
   l_gen_bulk_rec.SQUAL_NUM02(1) := null;
   l_gen_bulk_rec.SQUAL_NUM03(1) := null;
   l_gen_bulk_rec.SQUAL_NUM04(1) := null;
   l_gen_bulk_rec.SQUAL_NUM05(1) := p_prtnr_qualifier_rec.number_of_employee;       -- Number of Employees
   l_gen_bulk_rec.SQUAL_NUM06(1) := p_prtnr_qualifier_rec.Annual_Revenue;           -- Company Annual Revenue
   l_gen_bulk_rec.SQUAL_NUM07(1) := null;
   l_gen_bulk_rec.SQUAL_NUM08(1) := null;
   l_gen_bulk_rec.SQUAL_NUM09(1) := null;
   l_gen_bulk_rec.SQUAL_NUM10(1) := null;
   l_gen_bulk_rec.SQUAL_NUM11(1) := null;
   l_gen_bulk_rec.SQUAL_NUM12(1) := null;
   l_gen_bulk_rec.SQUAL_NUM13(1) := null;
   l_gen_bulk_rec.SQUAL_NUM14(1) := null;
   l_gen_bulk_rec.SQUAL_NUM15(1) := null;
   l_gen_bulk_rec.SQUAL_NUM16(1) := null;
   l_gen_bulk_rec.SQUAL_NUM17(1) := null;
   l_gen_bulk_rec.SQUAL_NUM18(1) := null;
   l_gen_bulk_rec.SQUAL_NUM19(1) := null;
   l_gen_bulk_rec.SQUAL_NUM20(1) := null;

   /* Added by Rahul for Currency code suggested by ARPATEL 04/19/2004 in bug# 3556250 */
   OPEN  l_get_Currency(p_prtnr_qualifier_rec.party_id);
   FETCH l_get_Currency INTO l_curr_code;
   CLOSE l_get_Currency;

   l_gen_bulk_rec.SQUAL_CURC01(1) := l_curr_code;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
       PVX_UTILITY_PVT.debug_message('Partner Details - Partner Type:'||p_prtnr_qualifier_rec.partner_type);
       PVX_UTILITY_PVT.debug_message('party_id        = ' || to_char(p_prtnr_qualifier_rec.party_id));
       PVX_UTILITY_PVT.debug_message('prtnr name Range= ' || p_prtnr_qualifier_rec.partner_name);
       PVX_UTILITY_PVT.debug_message('city            = ' || p_prtnr_qualifier_rec.city);
       PVX_UTILITY_PVT.debug_message('county          = ' || p_prtnr_qualifier_rec.county);
       PVX_UTILITY_PVT.debug_message('country         = ' || p_prtnr_qualifier_rec.country);
       PVX_UTILITY_PVT.debug_message('state           = ' || p_prtnr_qualifier_rec.state);
       PVX_UTILITY_PVT.debug_message('postal_code     = ' || p_prtnr_qualifier_rec.postal_code);
       PVX_UTILITY_PVT.debug_message('area_code       = ' || p_prtnr_qualifier_rec.area_code);
       PVX_UTILITY_PVT.debug_message('province        = ' || p_prtnr_qualifier_rec.province);
       PVX_UTILITY_PVT.debug_message('Customer Catgy  = ' || p_prtnr_qualifier_rec.customer_category_code);
       PVX_UTILITY_PVT.debug_message('Partner Level   = ' || p_prtnr_qualifier_rec.partner_level);
       PVX_UTILITY_PVT.debug_message('employees_total = ' || to_char(p_prtnr_qualifier_rec.number_of_employee));
       PVX_UTILITY_PVT.debug_message('Annual_Revenue  = ' || to_char(p_prtnr_qualifier_rec.Annual_Revenue));
    END IF;

    JTF_TERR_ASSIGN_PUB.get_winners
    (   p_api_version_number       => 1.0,
        p_use_type                 => 'RESOURCE',
        p_source_id                => -1700,
        p_trans_id                 => -1701,
        p_trans_rec                => l_gen_bulk_rec,
        p_resource_type            => FND_API.G_MISS_CHAR,
        p_role                     => FND_API.G_MISS_CHAR,
        p_top_level_terr_id        => FND_API.G_MISS_NUM,
        p_num_winners              => FND_API.G_MISS_NUM,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data,
        x_winners_rec              => l_winners_rec
    );

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        IF (l_winners_rec.resource_id.count > 0 ) THEN
           FOR k IN 1..l_winners_rec.resource_id.last
            LOOP
              PVX_UTILITY_PVT.debug_message('Resource Id  = '||to_char(l_winners_rec.resource_id(k)));
            END LOOP;
	END IF;
  END IF;
   -- -------------------------------------------------------------------------
   -- Print out winners and assign to the output parameters.
   -- -------------------------------------------------------------------------
    x_winners_rec := l_winners_rec;

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('TAP_Get_Channel_Team(-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('TAP_Get_Channel_Team(-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('TAP_Get_Channel_Team(-)');
      END IF;

END TAP_Get_Channel_Team;

-- Start of Comments
--
--      API name  : Process_TAP_Resources
--      Type      : Public
--      Function  : The purpose of this procedure is to processes all the resources
--                  retunred by Tap_Get_Channel_Team for a given Partner_id.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--              p_partner_id           IN  NUMBER
--              p_partner_type         IN  VARCHAR2
--              p_vad_partner_id       IN  NUMBER
--              p_mode                 IN  VARCHAR2
--              p_winners_rec          IN  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments
PROCEDURE Process_TAP_Resources(
  p_partner_id        IN  NUMBER,
   p_partner_type      IN  VARCHAR2,
   p_vad_partner_id    IN  NUMBER,
   p_winners_rec       IN  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type)
IS

  -- Get the Individual resource information
 CURSOR l_get_res_category(cv_resource_id NUMBER) IS
   SELECT category
     FROM jtf_rs_resource_extns res,
          jtf_rs_role_relations rr,
          jtf_rs_roles_b r
    WHERE res.resource_id = cv_resource_id
      AND res.resource_id = rr.role_resource_id
      AND rr.role_resource_type ='RS_INDIVIDUAL'
      AND NVL(rr.delete_flag,'N') <> 'Y'
      AND sysdate between rr.start_date_active and
                    nvl(rr.end_date_active,sysdate)
      AND rr.role_id = r.role_id
      AND r.role_code in ('CHANNEL_MANAGER', 'CHANNEL_REP')
      AND r.role_type_code = 'PRM'
      AND r.active_flag = 'Y'
      AND r.member_flag = 'Y';

 l_api_name           CONSTANT VARCHAR2(30) := 'Process_TAP_Resources';
 l_winners_rec        JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type := p_winners_rec;
 l_partner_id         NUMBER ;
 l_res_category          VARCHAR2(30);
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_res_created_flg       VARCHAR2(1);
 l_tap_created_flg       VARCHAR2(1);
 l_partner_access_id     NUMBER;
 l_territory_access_rec  PV_TAP_ACCESS_TERRS_PVT.TAP_ACCESS_TERRS_REC_TYPE ;
 l_resource_cnt          NUMBER ;
 l_resource_rec          PV_TERR_ASSIGN_PUB.ResourceRec;
 l_partner_type          VARCHAR2(500) ;
 j_index                 NUMBER;


BEGIN
  --------------- INSERTION OF THE LOGIC BEGIN ---------------------------
  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_Utility_PVT.debug_message('Procedure Process_TAP_Resources Start.');
  END IF;

  -- Initialize the return status
  x_return_status := FND_API.g_ret_sts_success;

  l_partner_id    := p_partner_id;
  l_resource_cnt  := 0;
  l_partner_type  := p_partner_type;

  -- Check all the returned resources.
  IF ( l_winners_rec.resource_id.last > 0 ) THEN
       FOR i_index IN 1..l_winners_rec.resource_id.last
       LOOP
	  -- Check if the returned resources are of type 'RS_TEAM' or 'RS_GROUP'
	  IF l_winners_rec.resource_type(i_index) = 'RS_TEAM' or
	     l_winners_rec.resource_type(i_index) = 'RS_GROUP' THEN


	     GET_RES_FROM_TEAM_GROUP(
	         P_RESOURCE_ID   => l_winners_rec.resource_id(i_index),
	         P_RESOURCE_TYPE => l_winners_rec.resource_type(i_index),
	         X_RESOURCE_REC  => l_resource_rec );

	     IF ( l_resource_rec.resource_id.count > 0) THEN

	          FOR j_index IN 1..l_resource_rec.resource_id.last
	          LOOP

                  Chk_To_Create_Access_Rec(
		     p_partner_id        => l_partner_id,
                     p_resource_id       => l_resource_rec.resource_id(j_index),
                     p_resource_category => l_resource_rec.resource_category(j_index),
                     p_partner_type      => l_partner_type,
                     p_vad_partner_id    => p_vad_partner_id,
                     x_return_status     => l_return_status,
                     x_msg_count         => l_msg_count,
                     x_msg_data          => l_msg_data,
	             x_res_created_flg   => l_res_created_flg,
		     x_tap_created_flg   => l_tap_created_flg,
                     x_partner_access_id => l_partner_access_id);

	          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                  END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

		  IF ( l_res_created_flg = 'Y' OR
		     ( l_res_created_flg = 'N' AND l_partner_access_id IS NOT NULL AND l_tap_created_flg = 'Y' ) )THEN

                     -- Setting the Territory Accesses record
                     l_territory_access_rec.partner_access_id := l_partner_access_id;
                     l_territory_access_rec.terr_id := l_winners_rec.terr_id(i_index);
                     l_territory_access_rec.object_version_number := 1;

                     --- ====== Check for duplicate territory record for a given partner access id
	             IF ( Check_Territory_Exist(
                             l_territory_access_rec.partner_access_id,
                             l_territory_access_rec.terr_id ) = 'N' ) THEN

 			--- Create a Territory Accesses record for the given Partner_access_id.
                        PV_TAP_ACCESS_TERRS_PVT.Create_Tap_Access_Terrs(
                          p_api_version_number   => 1.0,
                          p_init_msg_list        => FND_API.G_FALSE,
                          p_commit               => FND_API.G_FALSE,
                          p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status        => l_return_status,
                          x_msg_count            => l_msg_count,
                          x_msg_data             => l_msg_data,
                          p_tap_access_terrs_rec => l_territory_access_rec);

                       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                           END IF;
                       END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

			  END IF; /*** Check_Territory_Exist ***/

		     ELSIF (l_res_created_flg = 'E') THEN
			    -- Raise and Error that a VAD cannot create another VAD partner_type
			    RAISE FND_API.G_EXC_ERROR;
		     END IF;     /* l_res_created_flg = 'N' */


		     l_resource_cnt := l_resource_cnt + 1;
		     x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_partner_access_id;

		  END LOOP;   /* j_index IN 1..l_resource_rec.resource_id.last */
	     END IF;        /* l_resource_rec.resource_id.count > 0 */

          ELSIF ( l_winners_rec.resource_type(i_index) = 'RS_EMPLOYEE' OR
                  l_winners_rec.resource_type(i_index) = 'RS_PARTY' ) THEN
	         --------------------- Portion for Individual resources -----------------------
             OPEN l_get_res_category(l_winners_rec.resource_id(i_index));
             FETCH l_get_res_category INTO l_res_category ;

             IF ( l_get_res_category%FOUND ) THEN

                CLOSE l_get_res_category;
                Chk_To_Create_Access_Rec(
                    p_partner_id        => l_partner_id,
                    p_resource_id       => l_winners_rec.resource_id(i_index),
                    p_resource_category => l_res_category,
                    p_partner_type      => l_partner_type,
                    p_vad_partner_id    => p_vad_partner_id,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
	            x_res_created_flg   => l_res_created_flg,
		    x_tap_created_flg   => l_tap_created_flg,
                    x_partner_access_id => l_partner_access_id);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

                IF ( l_res_created_flg = 'Y' OR
		   ( l_res_created_flg = 'N' AND l_partner_access_id IS NOT NULL AND l_tap_created_flg = 'Y' ) )THEN
                   /*** Setting the Territory Accesses record ***/
                   l_territory_access_rec.partner_access_id := l_partner_access_id;
                   l_territory_access_rec.terr_id := l_winners_rec.terr_id(i_index);
                   l_territory_access_rec.object_version_number := 1;

                   /*** Check for duplicate territory record for a given terr_id and partner_access_id ***/
		   IF ( Check_Territory_Exist(
                        l_territory_access_rec.partner_access_id,
                        l_territory_access_rec.terr_id ) = 'N' ) THEN

			            /* Create a Territory Accesses record for the given Partner_access_id */
                        PV_TAP_ACCESS_TERRS_PVT.Create_Tap_Access_Terrs(
                           p_api_version_number   => 1.0,
                           p_init_msg_list        => FND_API.G_FALSE,
                           p_commit               => FND_API.G_FALSE,
                           p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                           x_return_status        => l_return_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data,
                           p_tap_access_terrs_rec => l_territory_access_rec);

		        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                               RAISE FND_API.G_EXC_ERROR;
                            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
			END IF; /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

		   END IF;    /*** Check for check_Territory_Exist ***/
                   l_resource_cnt := l_resource_cnt + 1;
		   x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_partner_access_id;
		  ELSIF (l_res_created_flg = 'E') THEN
		    -- Raise and Error that a VAD cannot create another VAD partner_type
--	            fnd_message.Set_Name('PV', 'PV_VAD_CANNOT_CREATE_VAD_PTYPE');
--                    fnd_msg_pub.Add;
		    RAISE FND_API.G_EXC_ERROR;
		  END IF;    /* l_resource_create_flg = 'E' */
              ELSE
                  CLOSE l_get_res_category;
              END IF;    /* l_get_res_category */
	  END IF; -- l_winners_rec.resource_type(i_index) = 'RS_EMPLOYEE'  or 'RS_PARTY'
       END LOOP; --  FOR i_index IN 1..l_winners_rec.resource_id.last
  END IF; -- l_winners_rec.resource_id.last

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Process_TAP_Resources (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Process_TAP_Resources (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Process_TAP_Resources (-)');
      END IF;
END Process_TAP_Resources;

-- Start of Comments
--
--      API name  : Get_Partner_Details
--      Type      : Public
--      Function  : The purpose of this procedure is to build a partner qualifiers
--                  table for a given party_id
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--              p_party_id             IN  NUMBER
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_partner_qualifiers_tbl  OUT   partner_qualifiers_tbl_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments
PROCEDURE get_partner_details (
   p_party_id                IN   NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_partner_qualifiers_tbl  OUT NOCOPY  partner_qualifiers_tbl_type )
IS
  -- Cursor l_partner_details_csr, which takes party_id as an input paramter, and gives
  -- the Partners details.
  CURSOR l_partner_details_csr(cv_party_id NUMBER) IS
           SELECT PARTY.party_id party_id,
	    SITE.party_site_id party_site_id,
            PARTY.city city,
            PARTY.country country,
  	    PARTY.county county,
  	    PARTY.state state,
  	    PARTY.province province,
  	    PARTY.postal_code postal_code,
            PARTY.primary_phone_area_code phone_area_code,
            PARTY.employees_total employees_total,
	    upper(PARTY.party_name) party_name,
	    PARTY.category_code category_code,
	    PARTY.curr_fy_potential_revenue annual_revenue
     FROM   HZ_PARTY_SITES   SITE,
       	    HZ_PARTIES   PARTY
     WHERE  SITE.status = 'A'
     AND    SITE.identifying_address_flag = 'Y'
     AND    PARTY.party_id = cv_party_id
     AND    SITE.party_id = PARTY.party_id
     AND    PARTY.party_type = 'ORGANIZATION'
     AND    PARTY.status = 'A';

/*********  Commented out.
     SELECT PARTY.party_id party_id,
	    SITE.party_site_id party_site_id,
        LOC.city city,
        LOC.country country,
  	    LOC.county county,
  	    LOC.state state,
  	    LOC.province province,
  	    LOC.postal_code postal_code,
 	    CNTPNT.phone_area_code phone_area_code,
        PARTY.employees_total employees_total,
	    upper(PARTY.party_name) party_name,
	    PARTY.category_code category_code,
	    PARTY.curr_fy_potential_revenue annual_revenue
     FROM   HZ_PARTY_SITES   SITE,
       	    HZ_CONTACT_POINTS   CNTPNT,
       	    HZ_LOCATIONS   LOC,
       	    HZ_PARTIES   PARTY
     WHERE  SITE.status = 'A'
     AND    SITE.identifying_address_flag = 'Y'
     AND    PARTY.party_id = cv_party_id
     AND    SITE.party_id = PARTY.party_id
     AND    PARTY.party_type = 'ORGANIZATION'
     AND    PARTY.status = 'A'
     AND    CNTPNT.owner_table_name(+) = 'HZ_PARTY_SITES'
     AND    CNTPNT.owner_table_id(+) = SITE.party_site_id
     AND    CNTPNT.status(+) = 'A'
     AND    CNTPNT.primary_flag(+) = 'Y'
     AND    CNTPNT.contact_point_type(+) = 'PHONE'
     AND    LOC.location_id = SITE.location_id
   UNION ALL
     SELECT to_number(null) party_id,
            to_number(NULL) party_site_id ,
	    to_char(NULL) city ,
	    to_char(NULL) country,
	    to_char(NULL) county ,
	    to_char(NULL) state ,
	    to_char(NULL) province ,
	    to_char(NULL) postal_code ,
	    CP.phone_area_code phone_area_code,
	    PARTY.employees_total employees_total,
	    upper(PARTY.party_name) party_name,
	    PARTY.category_code category_code,
	    PARTY.curr_fy_potential_revenue annual_revenue
     FROM   HZ_CONTACT_POINTS CP,
            HZ_PARTIES PARTY
     WHERE  CP.owner_table_name(+) = 'HZ_PARTIES'
     AND    CP.owner_table_id(+) = PARTY.party_id
     AND    PARTY.party_id = cv_party_id
     AND    PARTY.party_type = 'ORGANIZATION'
     AND    PARTY.status = 'A'
     AND    CP.status(+) = 'A'
     AND    CP.primary_flag(+) = 'Y'
     AND    CP.contact_point_type(+) = 'PHONE';
*************/


  l_partner_qualifiers_tbl   partner_qualifiers_tbl_type ;
  rec_index             NUMBER := 0;
  lc_party_id           NUMBER := 0;
  l_partner_rec   l_partner_details_csr%ROWTYPE;
BEGIN

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    rec_index := 0;

    -- FOR l_partner_rec IN l_partner_details_csr(p_party_id) LOOP
    OPEN l_partner_details_csr(p_party_id);
    LOOP
       FETCH l_partner_details_csr INTO l_partner_rec;
       EXIT WHEN l_partner_details_csr%NOTFOUND;
       rec_index := rec_index + 1;
       l_partner_qualifiers_tbl(rec_index).party_id   := l_partner_rec.party_id;
       l_partner_qualifiers_tbl(rec_index).party_site_id := l_partner_rec.party_site_id;
       l_partner_qualifiers_tbl(rec_index).city       := l_partner_rec.city ;
       l_partner_qualifiers_tbl(rec_index).country    := l_partner_rec.country ;
       l_partner_qualifiers_tbl(rec_index).county     := l_partner_rec.county;
       l_partner_qualifiers_tbl(rec_index).state      := l_partner_rec.state;
       l_partner_qualifiers_tbl(rec_index).province   := l_partner_rec.province;
       l_partner_qualifiers_tbl(rec_index).postal_code:= l_partner_rec.postal_code;
       l_partner_qualifiers_tbl(rec_index).area_code  := l_partner_rec.phone_area_code;
       l_partner_qualifiers_tbl(rec_index).number_of_employee := l_partner_rec.employees_total;
       l_partner_qualifiers_tbl(rec_index).partner_name:=  l_partner_rec.party_name;
       l_partner_qualifiers_tbl(rec_index).customer_category_code := l_partner_rec.category_code;
       l_partner_qualifiers_tbl(rec_index).Annual_Revenue := l_partner_rec.annual_revenue;
   END LOOP;
   CLOSE l_partner_details_csr;

   IF ( rec_index = 0 ) THEN
	 fnd_message.Set_Name('PV', 'PV_API_NO_PARTNER_PARTY_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
              PVX_Utility_PVT.debug_message('After successfully getting the Partner Details ***************');
    END IF;

    -- Store in the output variable.
    x_partner_qualifiers_tbl := l_partner_qualifiers_tbl;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
    );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF l_partner_details_csr%ISOPEN THEN
         CLOSE l_partner_details_csr;
      END IF;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('get_partner_details (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF l_partner_details_csr%ISOPEN THEN
         CLOSE l_partner_details_csr;
      END IF;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('get_partner_details (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF l_partner_details_csr%ISOPEN THEN
         CLOSE l_partner_details_csr;
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('get_partner_details (-)');
      END IF;

END get_partner_details;

-- Start of Comments
--
--      API name  : Delete_Channel_Team
--      Type      : Private
--      Function  : The purpose of this procedure is to delete a Channel
--                  team for a given Partner_id in the PV_PARTNER_ACCESSES
--                  table and also delete the territory information for that
--                  Channel team member from PV_TAP_ACCESS_TERRS table.
--
--      Pre-reqs  : It deletes the Channel team members, if any exists in the
--                  PV_PARTNER_ACCESSES table for a given partner_id. It also
--                  deletes the information about territory for that channel
--                  team member, if any exists in the PV_TAP_ACCESS_TERRS table.
--
--      Paramaeters     :
--      IN              :
--              p_partner_id           IN  NUMBER
--
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for deleting a Channel Team for a gievn Partner Organization.
--
--
-- End of Comments

PROCEDURE Delete_Channel_Team(
    p_partner_id          IN  NUMBER ,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2 )
IS

   l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Channel_Team';
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR(2000);
   l_partner_id            NUMBER;

  -- Cursor l_channel_team_csr to get all the channel team members for a given
  -- partner_id, which we have to delete from PV_PARTNER_ACCESSES table.
  CURSOR l_channel_team_csr (cv_partner_id IN NUMBER) IS
     SELECT partner_access_id, object_version_number
     FROM PV_PARTNER_ACCESSES
     WHERE partner_id = cv_partner_id
       AND KEEP_FLAG = 'N'
       AND CREATED_BY_TAP_FLAG = 'Y';

  -- Cursor l_territory_csr to get all the territory record  for a given
  -- partner_access_id, which we have to delete from PV_TAP_ACCESS_TERRS table.
  CURSOR l_territory_csr (cv_partner_access_id IN NUMBER) IS
     SELECT partner_access_id, terr_id, object_version_number
     FROM PV_TAP_ACCESS_TERRS
     WHERE partner_access_id = cv_partner_access_id;

BEGIN

   -- Debug Message
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
       PVX_UTILITY_PVT.debug_message('Private Procedure: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Find out all the Channel Team members for a given partner_id from l_channel_team_csr.
    FOR l_channel_team_rec IN l_channel_team_csr(p_partner_id)
    LOOP
       /*** First Delete, if any territory record exists in the PV_TAP_ACCESS_TERRS table for
        a gievn partner_access_id ***/

	FOR l_territory_rec IN l_territory_csr( l_channel_team_rec.partner_access_id)
	LOOP
	   -- Delete the Territory record for the given PARTNER_ACCESS_ID and TERR_ID
	   -- from PV_TAP_ACCESS_TERRS table.

           PV_TAP_ACCESS_TERRS_PVT.Delete_Tap_Access_Terrs(
              p_api_version_number    => 1.0,
              p_init_msg_list         => FND_API.G_FALSE,
              p_commit                => FND_API.G_FALSE,
              p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              p_partner_access_id     => l_territory_rec.partner_access_id,
              p_terr_id               => l_territory_rec.terr_id,
              p_object_version_number => l_territory_rec.object_version_number );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
-- 		   FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
--                   FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TAP_ACCESS_TERRS_PVT.Delete_Tap_Access_Terrs');
--                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
           END IF;

	END LOOP; /* FOR l_territory_rec IN l_territory_csr( l_channel_team_rec.partner_access_id) */

	-- Delete the Partner Access record for the given PARTNER_ACCESS_ID
	-- from PV_PARTNER_ACCESSES table.
	PV_Partner_Accesses_PVT.Delete_Partner_Accesses(
           p_api_version_number    => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_partner_access_id     => l_channel_team_rec.partner_access_id,
           p_object_version_number => l_channel_team_rec.object_version_number );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
--	      FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
--              FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_Partner_Accesses_PVT.Delete_Partner_Accesses');
--              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       END IF;
    END LOOP;  /* FOR l_channel_team_rec IN l_channel_team_csr(p_partner_id) */

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       PVX_UTILITY_PVT.debug_message('Private Procedure: ' || l_api_name || 'end.');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
    );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Delete_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Delete_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Delete_Channel_Team (-)');
      END IF;

END Delete_Channel_Team;

-- Start of Comments
--
--      API name  : Create_Terr_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to create a Channel
--                  team based on the territory for a partner
--
--      Pre-reqs  : Resources returned should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number   IN      NUMBER,
--			p_init_msg_list        IN      VARCHAR2
--			p_commit               IN      VARCHAR2
--    		p_validation_level     IN      NUMBER
--
--      	p_partner_id           IN  NUMBER
--      	p_vad_partner_id       IN  NUMBER
--      	p_mode                 IN  VARCHAR2
--      	p_login_user           IN  NUMBER
--			p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
--      OUT             :
--          x_return_status        OUT     VARCHAR2(1)
--          x_msg_count            OUT     NUMBER
--          x_msg_data             OUT     VARCHAR2(2000)
--          x_prtnr_access_id_tbl  OUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE Create_Terr_Channel_Team (
   p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

 l_api_name              CONSTANT VARCHAR2(30) := 'Create_Terr_Channel_Team';
 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_changed_partner_rec   PV_BATCH_CHG_PRTNR_PVT.batch_chg_prtnrs_rec_type ;

 -- Local variable declaration for all the Partner Qualifiers.
 l_party_site_id         NUMBER;
 l_party_id              NUMBER;
 l_partner_party_id      NUMBER;
 l_city                  VARCHAR2(60);
 l_country               VARCHAR2(60);
 l_county                VARCHAR2(60);
 l_state                 VARCHAR2(60);
 l_province              VARCHAR2(60);
 l_postal_code           VARCHAR2(60);
 l_phone_area_code       VARCHAR2(10);
 l_employees_total       NUMBER;
 l_party_name            VARCHAR2(360);
 l_category_code         VARCHAR2(30);
 l_curr_fy_potential_revenue NUMBER;
 l_partner_types         PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
 l_prtnr_access_id_tbl   JTF_NUMBER_TABLE;
 l_vad_prtnr_access_id_tbl prtnr_aces_tbl_type;
 l_partner_id            NUMBER;
 l_partner_types_cnt     NUMBER := 0;
 i     					 NUMBER := 0;
 l_partner_qualifier_rec partner_qualifiers_rec_type ;
 l_winners_rec	         JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_ind_winners_rec       JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_resource_cnt          NUMBER := 0;
 l_cm_added              VARCHAR2(1) := 'N' ;
 l_partner_level         VARCHAR2(30);
 l_resource_rec          PV_TERR_ASSIGN_PUB.ResourceRec;
 l_partner_access_id_tbl prtnr_aces_tbl_type;
 l_partner_qualifiers_tbl partner_qualifiers_tbl_type;

  -- Cursor l_party_id_csr to get the party_id and partner_level for a given partner_id.
  CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, pacv.attr_code
    FROM   pv_partner_profiles ppp,
           PV_ATTRIBUTE_CODES_VL pacv
    WHERE  ppp.partner_id = cv_partner_id
    AND	   ppp.status = 'A'
    AND    ppp.partner_level = pacv.ATTR_CODE_ID(+);

  -- Cursor l_partner_types_csr, which takes partner_id as an input paramter, and gives
  -- the Partners types.
  CURSOR l_partner_type_csr (cv_partner_id NUMBER) IS
    SELECT attr_value
    FROM pv_enty_attr_values
    WHERE attribute_id = 3
    AND entity= 'PARTNER'
    AND entity_id = cv_partner_id
    AND latest_flag = 'Y';

  -- Cursor l_chk_territory_exist_csr to check whether given partner_access_id and terr_id exists in
  -- PV_TAP_ACCESS_TERRS table or not.
  CURSOR l_chk_territory_exist_csr (cv_partner_access_id IN NUMBER, cv_terr_id IN NUMBER) IS
      SELECT 'Y'
      FROM PV_TAP_ACCESS_TERRS
      WHERE partner_access_id = cv_partner_access_id
      AND   terr_id = cv_terr_id;

BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- =========================================================================
     -- Validate Environment
     -- =========================================================================

     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
         l_partner_id := p_partner_id;
     END IF;


     -- Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.
     -- Debug Message

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message('START : Procesing of TAP returned resources with CHANNEL_MANAGER or CHANNEL_REP role.');
     END IF;

     -- Get the Partner Party Id for the given Partner_Id
     OPEN l_party_id_csr(l_partner_id);
     FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
     IF l_party_id_csr%NOTFOUND THEN
          CLOSE l_party_id_csr;
          -- Raise an error saying partner is not active
          fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
     ELSE
         CLOSE l_party_id_csr;
     END IF;

     -- Get the Partner Types details from l_partner_type_csr CURSOR.
     l_partner_types_cnt := 0;
     FOR prtnr_type_rec IN l_partner_type_csr(l_partner_id)
     LOOP
         l_partner_types_cnt := l_partner_types_cnt + 1;
	     l_partner_types(l_partner_types_cnt).attr_value := prtnr_type_rec.attr_value ;
     END LOOP;



     l_partner_qualifiers_tbl := p_partner_qualifiers_tbl;

     IF ( l_partner_qualifiers_tbl.count >= 0) THEN
       FOR i IN 1..l_partner_qualifiers_tbl.last
       LOOP
	     l_party_site_id := l_partner_qualifiers_tbl(i).party_site_id;
         l_city := l_partner_qualifiers_tbl(i).city ;
       	 l_country := l_partner_qualifiers_tbl(i).country;
       	 l_county := l_partner_qualifiers_tbl(i).county;
       	 l_state := l_partner_qualifiers_tbl(i).state;
       	 l_province := l_partner_qualifiers_tbl(i).province;
       	 l_postal_code := l_partner_qualifiers_tbl(i).postal_code;
       	 l_phone_area_code := l_partner_qualifiers_tbl(i).area_code;
       	 l_employees_total := l_partner_qualifiers_tbl(i).number_of_employee;
       	 l_party_name := l_partner_qualifiers_tbl(i).partner_name;
       	 l_category_code := l_partner_qualifiers_tbl(i).customer_category_code;
       	 l_curr_fy_potential_revenue := l_partner_qualifiers_tbl(i).annual_revenue;

         -- Process with each partner type, one by one record.
	     FOR j IN 1..l_partner_types_cnt
	 LOOP
	    -- Make a place to store the Partner qualifiers in the l_partner_qualifier_tbl.
	    --l_partner_qualifier_tbl.extend;
	    --l_partner_qualifier_rec := g_miss_partner_qualifiers_rec;

            -- Initilize the Partner Qualifers table with valid values.
			l_partner_qualifier_rec.partner_name := l_party_name;
			l_partner_qualifier_rec.party_id  := l_partner_party_id;
			l_partner_qualifier_rec.area_code := l_phone_area_code;
			l_partner_qualifier_rec.city      := l_city ;
			l_partner_qualifier_rec.country   := l_country ;
			l_partner_qualifier_rec.county    := l_county ;
			l_partner_qualifier_rec.postal_code := l_postal_code;
			l_partner_qualifier_rec.province  := l_province ;
			l_partner_qualifier_rec.state     := l_state;
			l_partner_qualifier_rec.annual_Revenue := l_curr_fy_potential_revenue;
			l_partner_qualifier_rec.number_of_employee := l_employees_total;
			l_partner_qualifier_rec.customer_category_code := l_category_code ;
			l_partner_qualifier_rec.partner_type  := l_partner_types(j).attr_value;
			l_partner_qualifier_rec.partner_level := l_partner_level;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('START : -- Call the TAP_Get_Channel_Team API ');
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.party_site_id);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') city => '|| l_partner_qualifier_rec.city);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') country => '|| l_partner_qualifier_rec.country);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') county => '|| l_partner_qualifier_rec.county);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') state => '|| l_partner_qualifier_rec.state);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') province => '|| l_partner_qualifier_rec.province);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') postal_code => '|| l_partner_qualifier_rec.postal_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') area_code => '|| l_partner_qualifier_rec.area_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.partner_name);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') annual_revenue => '|| l_partner_qualifier_rec.annual_revenue);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') number_of_employee => '|| l_partner_qualifier_rec.number_of_employee);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') customer_category_code => '|| l_partner_qualifier_rec.customer_category_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner type => '|| l_partner_qualifier_rec.partner_type);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner level => '|| l_partner_qualifier_rec.partner_level);
        END IF;

        -- Call the TAP_Get_Channel_Team API
        TAP_Get_Channel_Team(
            p_prtnr_qualifier_rec => l_partner_qualifier_rec,
	        x_return_Status       => l_return_status,
            x_msg_Count           => l_msg_count,
            x_msg_Data            => l_msg_data,
            x_winners_rec	      => l_winners_rec ) ;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
--	       FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
--               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.TAP_Get_Channel_Team');
--               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('SUCCESSFULLY END : -- TAP_Get_Channel_Team ');
        END IF;


        IF ( l_winners_rec.resource_id.count > 0) THEN
            -- Call the Process_TAP_Resource procedure to process all the returned resources
    	    -- from TAP_Get_Channel_Team
	    Process_TAP_Resources(
			p_partner_id        => l_partner_id,
			p_partner_type      => l_partner_types(j).attr_value,
			p_vad_partner_id    => p_vad_partner_id,
			p_winners_rec       => l_winners_rec,
			x_return_status     => l_return_status,
			x_msg_count         => l_msg_count,
			x_msg_data          => l_msg_data,
			x_prtnr_access_id_tbl => l_partner_access_id_tbl);

              IF (l_partner_access_id_tbl.count > 0 ) THEN
                  l_resource_cnt := l_resource_cnt + l_partner_access_id_tbl.count ;
              END IF;
        END IF;
	 END LOOP;  -- FOR j IN 1..l_partner_types_cnt
   END LOOP; -- FOR i IN 1..l_partner_qualifiers_tbl.party_name.last

  END IF; --( l_partner_qualifiers_tbl.last > 0)

  IF (l_resource_cnt> 0 ) THEN
         l_cm_added := 'Y';
  ELSE
         l_cm_added := 'N';
  END IF;

  -- End of Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Terr_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Terr_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Terr_Channel_Team (-)');
      END IF;


end Create_Terr_Channel_Team;


-- Start of Comments
--
--      API name  : Create_User_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to create a Channel
--                  team based on the logged in User for a partner
--
--      Pre-reqs  : User and his associated team should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number   IN      NUMBER,
--			p_init_msg_list        IN      VARCHAR2
--			p_commit               IN      VARCHAR2
--    		p_validation_level     IN      NUMBER
--
--      	p_partner_id           IN  NUMBER
--      	p_vad_partner_id       IN  NUMBER
--      	p_mode                 IN  VARCHAR2
--      	p_login_user           IN  NUMBER
--      OUT             :
--          x_return_status        OUT     VARCHAR2(1)
--          x_msg_count            OUT     NUMBER
--          x_msg_data             OUT     VARCHAR2(2000)
--          x_prtnr_access_id_tbl  INOUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE Create_User_Channel_Team (
   p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl IN OUT NOCOPY prtnr_aces_tbl_type
   ) IS

	 l_api_name              CONSTANT VARCHAR2(30) := 'Create_User_Channel_Team';
	 l_api_version_number    CONSTANT NUMBER   := 1.0;
	 l_return_status         VARCHAR2(1);
	 l_msg_count             NUMBER;
	 l_msg_data              VARCHAR(2000);

	 -- Local variable declaration

	 l_vad_prtnr_access_id_tbl prtnr_aces_tbl_type;
	 l_partner_id            NUMBER;
	 i     NUMBER := 0;
	 l_partner_access_id     NUMBER := 0;
	 l_partner_access_rec    PV_Partner_Accesses_PVT.partner_access_rec_type;
	 l_resource_cnt          NUMBER := 0;
	 l_cm_added              VARCHAR2(1) := 'N' ;
	 l_res_created_flg       VARCHAR2(1) := 'N' ;
	 l_login_user_id         NUMBER;
	 l_def_cm                  number;


	  -- Get the value of Profile  PV_DEFAULT_CM.
  CURSOR l_get_default_cm_csr(cv_profile_name IN VARCHAR2) IS
     SELECT nvl(fnd_profile.value(cv_profile_name),0) from dual;

	BEGIN

	     -- Standard call to check for call compatibility.
	      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
	                                           p_api_version_number,
	                                           l_api_name,
	                                           G_PKG_NAME)
	      THEN
	          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;

	     -- Initialize message list if p_init_msg_list is set to TRUE.
	      IF FND_API.to_Boolean( p_init_msg_list )
	      THEN
	         FND_MSG_PUB.initialize;
	      END IF;

	     -- Debug Message
	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
	     END IF;

	     -- Initialize API return status to SUCCESS
	     x_return_status := FND_API.G_RET_STS_SUCCESS;

	     -- =========================================================================
	     -- Validate Environment
	     -- =========================================================================

	     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
	         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
	         fnd_message.set_token('FIELD', 'PARTNER_ID');
	         fnd_msg_pub.Add;
	         RAISE FND_API.G_EXC_ERROR;
	     ELSE
	         l_partner_id := p_partner_id;
	     END IF;

	     -- STEP (i) :
	     -- Logic for inserting the logged in user's(Vendor employee) resource_id in the
	     -- PV_PARTNER_ACCESSES table, IF the user is playing a role of
	     -- 'CHANNEL_MANAGER' or 'CHANNEL_REP'

		     IF (p_mode <> 'UPDATE') THEN
		        IF (p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) THEN
		            IF (p_login_user IS NULL OR p_login_user = FND_API.g_miss_num) THEN
		               l_login_user_id := FND_GLOBAL.user_id;
		            ELSE
		               l_login_user_id := p_login_user;
		            END IF;

		            Cr_Login_User_Access_Rec(
						p_partner_id        => l_partner_id,
						p_login_user_id     => l_login_user_id,
						x_return_status     => l_return_status,
						x_msg_count         => l_msg_count,
						x_msg_data          => l_msg_data,
						x_cm_added          => l_cm_added,
						x_res_created_flg   => l_res_created_flg,
						x_partner_access_id => l_partner_access_id);

					IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
					        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					           RAISE FND_API.G_EXC_ERROR;
					        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
--					           FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
--					           FND_MESSAGE.SET_TOKEN('API_NAME', 'Cr_Login_User_Access_Rec');
--					           FND_MSG_PUB.Add;
					           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					        END IF;
					END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

		            IF (l_cm_added = 'Y' ) THEN

				       l_resource_cnt := x_prtnr_access_id_tbl.count();
				       x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id:= l_partner_access_id ;
--				       l_resource_cnt := l_resource_cnt + 1;
		            END IF;
		         END IF; -- p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num
		      END IF;  -- p_mode <> 'UPDATE'


		  -- Step2: If p_vad_partner_id is not null, then add all the CMs( Employees Of VAD Organinzation)
		  -- to the p_partner_id's channel team. Ensure that you check for duplicates in access table. No territory
		  -- records are added. set tap created flag to 'N' and keep flag = 'Y'
		  IF ( NOT(p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) ) THEN

		      -- Debug Message
		      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		         PVX_Utility_PVT.debug_message('START : Step3: If p_vad_partner_id is not null, then all the CMs( Employees of VAD Organization.');
		      END IF;

		      -- Get the VAD Channel Team -
			  Create_VAD_Channel_Team(
					p_api_version_number  => 1.0 ,
					p_init_msg_list       => FND_API.G_FALSE ,
					p_commit              => FND_API.G_FALSE ,
					p_validation_level    => FND_API.G_VALID_LEVEL_FULL ,
					x_return_status       => l_return_status,
					x_msg_count           => l_msg_count,
					x_msg_data            => l_msg_data,
					p_partner_id          => l_partner_id,
					p_vad_partner_id      => p_vad_partner_id,
					x_prtnr_access_id_tbl => l_vad_prtnr_access_id_tbl );

			  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		             RAISE FND_API.G_EXC_ERROR;
		          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*				     FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
		             FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_VAD_Channel_Team');
		             FND_MSG_PUB.Add;
*/		             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		          END IF;
		      END IF;

		      --- ===================================================================
		      --- Store the returned resources from Create_VAD_Channel_Team procedure
		      --- to the main output variable x_prtnr_access_id_tbl.
		      --- ===================================================================
		      IF (l_vad_prtnr_access_id_tbl.count > 0 ) THEN
			     l_cm_added := 'Y';
		         FOR k_index IN 1..l_vad_prtnr_access_id_tbl.last
			 	 LOOP
		           	l_resource_cnt := l_resource_cnt + 1;
			   		x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_vad_prtnr_access_id_tbl(k_index).partner_access_id;
			 	 END LOOP;
		      END IF;

		      -- Debug Message
		      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		         PVX_Utility_PVT.debug_message('SUCCESSFULLY END : Step3.');
		      END IF;

		   END IF; -- l_vad_partner_id IS NOT NULL OR l_vad_partner_id <> FND_API.g_miss_num

	   -- Assign Default Channel Manager as a Channel Team member, if both the above (Logged_in_User and
	   -- TAP procedure call failed to add any channel team member.
	   -- Debug Message

		   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		      PVX_Utility_PVT.debug_message('START : Step4: Assign Default Channel Manager as a Channel Team member : l_cm_added => '||l_cm_added );
		   END IF;

		   if x_prtnr_access_id_tbl.count > 0 then
				l_cm_added := 'Y';
		   end if;

		   IF ( l_cm_added <> 'Y' ) THEN

        	   	OPEN l_get_default_cm_csr('PV_DEFAULT_CM');
        		FETCH l_get_default_cm_csr INTO l_def_cm;
        		CLOSE l_get_default_cm_csr;

                IF (l_def_cm = 0 ) THEN
        			FND_MESSAGE.SET_NAME('PV', 'PV_NO_DEFAULT_CMM');
        			FND_MSG_PUB.Add;
        			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        		END IF;
		        -- Set the p_partner_access_rec record
				l_partner_access_rec.partner_id  := l_partner_id;
				l_partner_access_rec.resource_id := fnd_profile.value('PV_DEFAULT_CM');
				l_partner_access_rec.keep_flag   := 'Y';
				l_partner_access_rec.created_by_tap_flag := 'Y';
				l_partner_access_rec.access_type := 'F';

			  --- ==================================================================
		      ---  Before adding the default CM, check to see if there are any CMs
		      ---  added manually for a given p_partner_id.If yes, skip adding the
			  ---  default CM.
			  --- ==================================================================
					IF (check_channel_team_exist(
						p_partner_id   => l_partner_id) = 'N') THEN


						PV_Partner_Accesses_PVT.Create_Partner_Accesses(
						    p_api_version_number => 1.0,
						    p_init_msg_list      => FND_API.G_FALSE,
						    p_commit             => FND_API.G_FALSE,
						    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
						    x_return_status      => l_return_status,
						    x_msg_count          => l_msg_count,
						    x_msg_data           => l_msg_data,
						    p_partner_access_rec => l_partner_access_rec,
						    x_partner_access_id  => l_partner_access_id );

						     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
						             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
						                RAISE FND_API.G_EXC_ERROR;
						             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*						            	FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
						                FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_Partner_Accesses_PVT.Create_Partner_Accesses');
						                FND_MSG_PUB.Add;
*/						                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
						             END IF;
						     END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

						 -- Store the PARTNER_ACCESS_ID in the Out variable
						 l_resource_cnt := l_resource_cnt + 1;
						 x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_partner_access_id;

					END IF ; --  check_resource_exist
		     END IF; -- l_cm_added <> 'Y'

		    -- Standard check for p_commit
		     IF FND_API.to_Boolean( p_commit )
		     THEN
		         COMMIT WORK;
		     END IF;

		     -- Debug Message
		     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
		     END IF;

		     -- Standard call to get message count and if count is 1, get message info.
		     FND_MSG_PUB.Count_And_Get
		        (p_count          =>   x_msg_count,
		         p_data           =>   x_msg_data
		      );

	 EXCEPTION
	   WHEN FND_API.g_exc_error THEN
	      x_return_status := FND_API.g_ret_sts_error;
	      FND_MSG_PUB.count_and_get (
	           p_encoded => FND_API.g_false
	         ,p_count   => x_msg_count
	          ,p_data    => x_msg_data
	          );

	      -- Debug Message
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	         hz_utility_v2pub.debug_return_messages (
	          x_msg_count, x_msg_data, 'ERROR');
	         hz_utility_v2pub.debug('Create_User_Channel_Team (-)');
	      END IF;

	    WHEN FND_API.g_exc_unexpected_error THEN

	     x_return_status := FND_API.g_ret_sts_unexp_error ;
	      FND_MSG_PUB.count_and_get (
	           p_encoded => FND_API.g_false
	          ,p_count   => x_msg_count
	          ,p_data    => x_msg_data
	          );
	      -- Debug Message
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	         hz_utility_v2pub.debug_return_messages (
	          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
	         hz_utility_v2pub.debug('Create_User_Channel_Team (-)');
	      END IF;

	    WHEN OTHERS THEN

	     x_return_status := FND_API.g_ret_sts_unexp_error ;

	      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
			THEN
	         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
	      END IF;

	      FND_MSG_PUB.count_and_get(
	           p_encoded => FND_API.g_false
	          ,p_count   => x_msg_count
	          ,p_data    => x_msg_data
	          );

	            -- Debug Message
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	         hz_utility_v2pub.debug_return_messages (
	          x_msg_count, x_msg_data, 'SQL ERROR');
	         hz_utility_v2pub.debug('Create_User_Channel_Team (-)');
	      END IF;


end Create_User_Channel_Team;

-- Start of Comments
--
-- NAME
--   PV_TERR_ASSIGN_PUB
--
-- PURPOSE
--   This package is a public API to create the channel team based on the user as well
--   as the pre defined qualifiers for the partner. This API inturn calls apis to create
--   the channel team based on territory as well as the logged in user.
--
--   Procedures:
--	Do_Create_Channel_Team
--
-- NOTES
--   This package is for private use only
--
--      Pre-reqs  : Existing resource should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    	p_validation_level     IN      NUMBER
--      p_partner_id           IN  NUMBER
--      p_vad_partner_id       IN  NUMBER
--      p_mode                 IN  VARCHAR2
--      p_login_user          IN  NUMBER ,
--      p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
--
--
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     PV_TERR_ASSIGN_PUB.PartnerAccessRec
--
--      Version :
--                      Initial version         1.0
--
-- HISTORY
--   07/27/05   pinagara    Created
--
-- End of Comments



PROCEDURE Do_Create_Channel_Team
(  p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
)IS

 l_api_name              CONSTANT VARCHAR2(30) := 'Create_Channel_Team';
 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_partner_id            NUMBER;
 l_prtnr_access_id_tbl   JTF_NUMBER_TABLE;
 l_tap_assign_online     VARCHAR2(1);
 l_changed_partner_rec   PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;
 l_partner_access_id_tbl prtnr_aces_tbl_type ;
 l_partner_exist         VARCHAR2(1):= 'N';
 l_login_user            NUMBER := FND_GLOBAL.user_id;
 l_mode                  VARCHAR2(10);
 l_processed_flag        VARCHAR2(1) := 'P';
 l_object_version_number NUMBER ;

   -- Cursor l_chk_partner_exist_csr to check whether given partner_id exists in
  -- PV_TAP_BATCH_CHG_PARTNERS table or not.
  CURSOR l_chk_partner_exist_csr (cv_partner_id IN NUMBER) IS
      SELECT processed_flag, object_version_number
      FROM PV_TAP_BATCH_CHG_PARTNERS
      WHERE partner_id = cv_partner_id;

  -- Get the value of Profile  PV_TAP_ASSIGN_ONLINE.
  CURSOR l_get_tap_prfl_value_csr(cv_profile_name IN VARCHAR2) IS
     SELECT fnd_profile.value(cv_profile_name) from dual;

BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT create_channel_team_pub;

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
     IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- =========================================================================
     -- Validate Environment
     -- =========================================================================

     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num
     THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
         l_partner_id := p_partner_id;
     END IF;

     IF p_mode IS NULL OR p_mode = FND_API.g_miss_char
     THEN
         l_mode := 'CREATE';
     ELSE
         l_mode := p_mode ;
     END IF;

     -- Local variable initialization - Get the Profile value for PV_TAP_ASSIGN_ONLINE profile.
     OPEN l_get_tap_prfl_value_csr('PV_TAP_ASSIGN_ONLINE');
     FETCH l_get_tap_prfl_value_csr INTO l_tap_assign_online;
     CLOSE l_get_tap_prfl_value_csr;

     IF ( l_tap_assign_online = 'Y' ) THEN

		    IF ( l_mode = 'UPDATE' ) THEN

		       -- Call the Delete_Channel_Team for a given Partner_id
		           Delete_Channel_Team(
		              p_partner_id          => l_partner_id ,
		              x_return_status       => l_return_status,
		              x_msg_count           => l_msg_count,
		              x_msg_data            => l_msg_data );


		           	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		                  RAISE FND_API.G_EXC_ERROR;
		               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
		                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		               END IF;
		       		END IF;

			END IF;    /*** p_mode = 'UPDATE'  ***/

		  	Create_Terr_Channel_Team(
                    p_api_version_number => 1.0,
		            p_init_msg_list      => FND_API.G_FALSE,
		            p_commit             => FND_API.G_FALSE,
		            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		            x_return_status      => l_return_status,
		            x_msg_count          => l_msg_count,
		            x_msg_data           => l_msg_data,
		            p_partner_id         => l_partner_id,
		    	    p_vad_partner_id     => p_vad_partner_id,
			        p_mode               => p_mode,
			        p_partner_qualifiers_tbl => p_partner_qualifiers_tbl,
		            p_login_user         => p_login_user,

		            x_prtnr_access_id_tbl=> l_partner_access_id_tbl );


		    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	               	RAISE FND_API.G_EXC_ERROR;
	            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
/*					FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
					FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_Terr_Channel_Team');
					FND_MSG_PUB.Add;
*/					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	            END IF;
	         END IF;

	 -- Store the output variables
         	x_prtnr_access_id_tbl := l_partner_access_id_tbl;

     ELSIF ( l_tap_assign_online = 'N' ) THEN

			-- Initialize the l_changed_partner_rec.partner_id
			l_changed_partner_rec.partner_id := l_partner_id;
			l_changed_partner_rec.vad_partner_id := p_vad_partner_id;
			l_changed_partner_rec.processed_flag := 'P';

		       -- Check if the supplied partner_id already exist in PV_TAP_BATCH_CHG_PARTNERS table
		       -- then do not insert the record for that partner_id.
		       OPEN l_chk_partner_exist_csr(l_partner_id);
		       FETCH l_chk_partner_exist_csr INTO l_processed_flag, l_object_version_number;

		       IF (l_chk_partner_exist_csr%NOTFOUND ) THEN

		           CLOSE l_chk_partner_exist_csr;
		           -- Call the Create_Batch_Chg_Partners API from PV_BATCH_CHG_PRTNR_PVT
			   -- to create a record in PV_TAP_BATCH_CHG_PARTNERS table.

			   PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
					p_api_version_number    => 1.0
					,p_init_msg_list        => FND_API.G_FALSE
					,p_commit               => FND_API.G_FALSE
					,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
					,x_return_status        => l_return_status
					,x_msg_count            => l_msg_count
					,x_msg_data             => l_msg_data
					,p_batch_chg_prtnrs_rec => l_changed_partner_rec
					,x_partner_id           => l_partner_id
			    );

			  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		               RAISE FND_API.G_EXC_ERROR;
		            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*			       FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
		               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners');
		               FND_MSG_PUB.Add;
*/		               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		            END IF;
		          END IF;

		       ELSE

		         CLOSE l_chk_partner_exist_csr;

		         IF (l_processed_flag <> 'P') THEN

			    	l_changed_partner_rec.object_version_number := l_object_version_number;
		            PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
							p_api_version_number    => 1.0
							,p_init_msg_list        => FND_API.G_FALSE
							,p_commit               => FND_API.G_FALSE
							,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
							,x_return_status        => l_return_status
							,x_msg_count            => l_msg_count
							,x_msg_data             => l_msg_data
							,p_batch_chg_prtnrs_rec => l_changed_partner_rec);

			    	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

		              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		              	RAISE FND_API.G_EXC_ERROR;
		              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*						FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
						FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
						FND_MSG_PUB.Add;
*/						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		              END IF;
		            END IF;

		        END IF; --l_processed_flag <> 'P'
		       END IF; -- l_chk_partner_exist_csr%NOTFOUND
     END IF;  -- l_tap_assign_online


	Create_User_Channel_Team( p_api_version_number => 1.0,
		p_init_msg_list      => FND_API.G_FALSE,
		p_commit             => FND_API.G_FALSE,
		p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		p_partner_id         => l_partner_id,
		p_vad_partner_id     => p_vad_partner_id,
		p_mode               => p_mode,
		p_login_user         => p_login_user,
		x_return_status      => l_return_status,
		x_msg_count          => l_msg_count,
		x_msg_data           => l_msg_data,
		x_prtnr_access_id_tbl=> l_partner_access_id_tbl );

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*			FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
			FND_MESSAGE.SET_TOKEN('API_NAME', 'Create_User_Channel_Team');
			FND_MSG_PUB.Add;
*/			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	END IF;


     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' End');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

END Do_Create_Channel_Team;

-- Start of Comments
--
-- NAME
--   PV_TERR_ASSIGN_PUB
--
-- PURPOSE
--   This package is a public API to create the channel team based on the user as well
--   as the pre defined qualifiers for the partner. This API will call the Do_Create_channel_team
--   which does all the required processing.This is more of an overloaded method for Do_Create_channel_team
--
--   Procedures:
--	Do_Create_Channel_Team
--
-- NOTES
--   This package is for private use only
--
--      Pre-reqs  : Existing resource should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    	p_validation_level     IN      NUMBER
--      p_partner_id           IN  NUMBER
--      p_vad_partner_id       IN  NUMBER
--      p_mode                 IN  VARCHAR2
--      p_login_user          IN  NUMBER ,
--
--
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     PV_TERR_ASSIGN_PUB.PartnerAccessRec
--
--      Version :
--                      Initial version         1.0
--
-- HISTORY
--   07/27/05   pinagara    Created
--
-- End of Comments

PROCEDURE Create_Channel_Team
(  p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
) IS

 l_api_name              CONSTANT VARCHAR2(30) := 'Create_Channel_Team';
 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_partner_id            NUMBER := p_partner_id;
 l_prtnr_access_id_tbl   prtnr_aces_tbl_type;
 l_tap_assign_online     VARCHAR2(1);
 l_changed_partner_rec   PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;
 l_partner_exist         VARCHAR2(1):= 'N';
 l_login_user            NUMBER := FND_GLOBAL.user_id;
 l_mode                  VARCHAR2(10);
 l_processed_flag        VARCHAR2(1) := 'P';
 l_object_version_number NUMBER ;

 l_partner_party_id      NUMBER;
 l_partner_level         VARCHAR2(30);
 l_partner_qualifiers_tbl partner_qualifiers_tbl_type;



 CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, pacv.attr_code
    FROM   pv_partner_profiles ppp,
           PV_ATTRIBUTE_CODES_VL pacv
    WHERE  ppp.partner_id = cv_partner_id
    AND	   ppp.status = 'A'
    AND    ppp.partner_level = pacv.ATTR_CODE_ID(+);


BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT create_channel_team_pub;

     -- Get the Partner Party Id for the given Partner_Id
     OPEN l_party_id_csr(l_partner_id);
     FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
     IF l_party_id_csr%NOTFOUND THEN
          CLOSE l_party_id_csr;
          -- Raise an error saying partner is not active
          fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
     ELSE
         CLOSE l_party_id_csr;
     END IF;


        get_partner_details(
		         p_party_id               => l_partner_party_id ,
		         x_return_status          => l_return_status ,
		         x_msg_count              => l_msg_count ,
		         x_msg_data               => l_msg_data ,
		         x_partner_qualifiers_tbl => l_partner_qualifiers_tbl );

    	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        Do_Create_Channel_Team (
               p_api_version_number  => p_api_version_number,
               p_init_msg_list       => p_init_msg_list,
               p_commit              => p_commit,
               p_validation_level	 => p_validation_level,
               p_partner_id          => p_partner_id,
               p_vad_partner_id      => p_vad_partner_id,
               p_mode                => p_mode,
               p_login_user          => p_login_user,
               p_partner_qualifiers_tbl => l_partner_qualifiers_tbl,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data,
               x_prtnr_access_id_tbl => l_prtnr_access_id_tbl);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
/*	           FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Do_Create_Channel_Team');
               FND_MSG_PUB.Add;
*/               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_channel_team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Channel_Team (-)');
      END IF;

END Create_Channel_Team;

--PN Obsoleted
PROCEDURE Do_Cr_Online_Chnl_Team (
   p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
   ) IS
/*
 l_api_name              CONSTANT VARCHAR2(30) := 'Create_Online_Channel_Team';
 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_changed_partner_rec   PV_BATCH_CHG_PRTNR_PVT.batch_chg_prtnrs_rec_type ;

 -- Local variable declaration for all the Partner Qualifiers.
 l_party_site_id         NUMBER;
 l_party_id              NUMBER;
 l_partner_party_id      NUMBER;
 l_city                  VARCHAR2(60);
 l_country               VARCHAR2(60);
 l_county                VARCHAR2(60);
 l_state                 VARCHAR2(60);
 l_province              VARCHAR2(60);
 l_postal_code           VARCHAR2(60);
 l_phone_area_code       VARCHAR2(10);
 l_employees_total       NUMBER;
 l_party_name            VARCHAR2(360);
 l_category_code         VARCHAR2(30);
 l_curr_fy_potential_revenue NUMBER;
 l_partner_types         PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
 l_prtnr_access_id_tbl   JTF_NUMBER_TABLE;
 l_vad_prtnr_access_id_tbl prtnr_aces_tbl_type;
 l_partner_id            NUMBER;
 l_partner_types_cnt     NUMBER := 0;
 i     NUMBER := 0;
 l_partner_qualifier_rec partner_qualifiers_rec_type ;
 l_partner_exist         VARCHAR2(1) := 'N';
 l_territory_exist       VARCHAR2(1) := 'N';
 l_partner_access_id     NUMBER := 0;
 l_partner_access_rec    PV_Partner_Accesses_PVT.partner_access_rec_type;
 l_winners_rec	         JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_ind_winners_rec       JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_territory_access_rec  PV_TAP_ACCESS_TERRS_PVT.TAP_ACCESS_TERRS_REC_TYPE ;
 l_resource_cnt          NUMBER := 0;
 l_cm_added              VARCHAR2(1) := 'N' ;
 l_res_created_flg       VARCHAR2(1) := 'N' ;
 l_tap_created_flg       VARCHAR2(1) := 'N' ;
 l_login_user_id         NUMBER;
 l_partner_level         VARCHAR2(30);
 l_resource_rec          PV_TERR_ASSIGN_PUB.ResourceRec;
 l_partner_access_id_tbl prtnr_aces_tbl_type;
 l_partner_qualifiers_tbl partner_qualifiers_tbl_type;

  -- Cursor l_party_id_csr to get the party_id and partner_level for a given partner_id.
  CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, pacv.attr_code
    FROM   pv_partner_profiles ppp,
           PV_ATTRIBUTE_CODES_VL pacv
    WHERE  ppp.partner_id = cv_partner_id
    AND	   ppp.status = 'A'
    AND    ppp.partner_level = pacv.ATTR_CODE_ID(+);

  -- Cursor l_partner_types_csr, which takes partner_id as an input paramter, and gives
  -- the Partners types.
  CURSOR l_partner_type_csr (cv_partner_id NUMBER) IS
    SELECT attr_value
    FROM pv_enty_attr_values
    WHERE attribute_id = 3
    AND entity= 'PARTNER'
    AND entity_id = cv_partner_id
    AND latest_flag = 'Y';

  -- Cursor l_chk_territory_exist_csr to check whether given partner_access_id and terr_id exists in
  -- PV_TAP_ACCESS_TERRS table or not.
  CURSOR l_chk_territory_exist_csr (cv_partner_access_id IN NUMBER, cv_terr_id IN NUMBER) IS
      SELECT 'Y'
      FROM PV_TAP_ACCESS_TERRS
      WHERE partner_access_id = cv_partner_access_id
      AND   terr_id = cv_terr_id;
*/
BEGIN
    --PN Not in use, Replaced by TERR and User APIs

--    dbms_output.put_line('Dummy stmt ');
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message('This procedure is not in use');
    END IF;
/*
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- =========================================================================
     -- Validate Environment
     -- =========================================================================

     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
         l_partner_id := p_partner_id;
     END IF;

     -- STEP (i) :
     -- Logic for inserting the logged in user's(Vendor employee) resource_id in the
     -- PV_PARTNER_ACCESSES table, IF the user is playing a role of
     -- 'CHANNEL_MANAGER' or 'CHANNEL_REP'

     IF (p_mode <> 'UPDATE') THEN
        IF (p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) THEN
            IF (p_login_user IS NULL OR p_login_user = FND_API.g_miss_num) THEN
               l_login_user_id := FND_GLOBAL.user_id;
            ELSE
               l_login_user_id := p_login_user;
            END IF;

            Cr_Login_User_Access_Rec(
     	       p_partner_id        => l_partner_id,
               p_login_user_id     => l_login_user_id,
	       x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
	       x_msg_data          => l_msg_data,
	       x_cm_added          => l_cm_added,
	       x_res_created_flg   => l_res_created_flg,
	       x_partner_access_id => l_partner_access_id);

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                   FND_MESSAGE.SET_TOKEN('API_NAME', 'Cr_Login_User_Access_Rec');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

            IF (l_cm_added = 'Y' ) THEN
               x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id:= l_partner_access_id ;
	       l_resource_cnt := l_resource_cnt + 1;
            END IF;
         END IF; -- p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num
      END IF;  -- p_mode <> 'UPDATE'

     -- STEP (ii) : Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.
     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message('START : STEP (ii) : Procesing of TAP returned resources with CHANNEL_MANAGER or CHANNEL_REP role.');
     END IF;

     -- Get the Partner Party Id for the given Partner_Id
     OPEN l_party_id_csr(l_partner_id);
     FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
     IF l_party_id_csr%NOTFOUND THEN
          CLOSE l_party_id_csr;
          -- Raise an error saying partner is not active
          fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
     ELSE
         CLOSE l_party_id_csr;
     END IF;

     -- Get the Partner Types details from l_partner_type_csr CURSOR.
     l_partner_types_cnt := 0;
     FOR prtnr_type_rec IN l_partner_type_csr(l_partner_id)
     LOOP
         l_partner_types_cnt := l_partner_types_cnt + 1;
	     l_partner_types(l_partner_types_cnt).attr_value := prtnr_type_rec.attr_value ;
     END LOOP;

/*
     --l_partner_types_cnt := l_partner_types_cnt - 1;
     -- Get the Partner qualifiers details
     get_partner_details(
         p_party_id               => l_partner_party_id ,
         x_return_status          => l_return_status ,
         x_msg_count              => l_msg_count ,
         x_msg_data               => l_msg_data ,
         x_partner_qualifiers_tbl => l_partner_qualifiers_tbl );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'get_partner_details');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     END IF;
*/


/*

        l_partner_qualifiers_tbl := p_partner_qualifiers_tbl;

     IF ( l_partner_qualifiers_tbl.count >= 0) THEN
       FOR i IN 1..l_partner_qualifiers_tbl.last
       LOOP
	     l_party_site_id := l_partner_qualifiers_tbl(i).party_site_id;
         l_city := l_partner_qualifiers_tbl(i).city ;
       	 l_country := l_partner_qualifiers_tbl(i).country;
       	 l_county := l_partner_qualifiers_tbl(i).county;
       	 l_state := l_partner_qualifiers_tbl(i).state;
       	 l_province := l_partner_qualifiers_tbl(i).province;
       	 l_postal_code := l_partner_qualifiers_tbl(i).postal_code;
       	 l_phone_area_code := l_partner_qualifiers_tbl(i).area_code;
       	 l_employees_total := l_partner_qualifiers_tbl(i).number_of_employee;
       	 l_party_name := l_partner_qualifiers_tbl(i).partner_name;
       	 l_category_code := l_partner_qualifiers_tbl(i).customer_category_code;
       	 l_curr_fy_potential_revenue := l_partner_qualifiers_tbl(i).annual_revenue;

         -- Process with each partner type, one by one record.
	     FOR j IN 1..l_partner_types_cnt
	 LOOP
	    -- Make a place to store the Partner qualifiers in the l_partner_qualifier_tbl.
	    --l_partner_qualifier_tbl.extend;
	    --l_partner_qualifier_rec := g_miss_partner_qualifiers_rec;

            -- Initilize the Partner Qualifers table with valid values.
	    l_partner_qualifier_rec.partner_name := l_party_name;
	    l_partner_qualifier_rec.party_id  := l_partner_party_id;
            l_partner_qualifier_rec.area_code := l_phone_area_code;
            l_partner_qualifier_rec.city      := l_city ;
            l_partner_qualifier_rec.country   := l_country ;
            l_partner_qualifier_rec.county    := l_county ;
            l_partner_qualifier_rec.postal_code := l_postal_code;
            l_partner_qualifier_rec.province  := l_province ;
            l_partner_qualifier_rec.state     := l_state;
            l_partner_qualifier_rec.annual_Revenue := l_curr_fy_potential_revenue;
            l_partner_qualifier_rec.number_of_employee := l_employees_total;
            l_partner_qualifier_rec.customer_category_code := l_category_code ;
            l_partner_qualifier_rec.partner_type  := l_partner_types(j).attr_value;
	    l_partner_qualifier_rec.partner_level := l_partner_level;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('START : -- Call the TAP_Get_Channel_Team API ');
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.party_site_id);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') city => '|| l_partner_qualifier_rec.city);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') country => '|| l_partner_qualifier_rec.country);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') county => '|| l_partner_qualifier_rec.county);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') state => '|| l_partner_qualifier_rec.state);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') province => '|| l_partner_qualifier_rec.province);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') postal_code => '|| l_partner_qualifier_rec.postal_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') area_code => '|| l_partner_qualifier_rec.area_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.partner_name);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') annual_revenue => '|| l_partner_qualifier_rec.annual_revenue);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') number_of_employee => '|| l_partner_qualifier_rec.number_of_employee);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') customer_category_code => '|| l_partner_qualifier_rec.customer_category_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner type => '|| l_partner_qualifier_rec.partner_type);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner level => '|| l_partner_qualifier_rec.partner_level);
        END IF;

        -- Call the TAP_Get_Channel_Team API
        TAP_Get_Channel_Team(
            p_prtnr_qualifier_rec => l_partner_qualifier_rec,
	        x_return_Status       => l_return_status,
            x_msg_Count           => l_msg_count,
            x_msg_Data            => l_msg_data,
            x_winners_rec	      => l_winners_rec ) ;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	       FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.TAP_Get_Channel_Team');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('SUCCESSFULLY END : -- TAP_Get_Channel_Team ');
        END IF;


        IF ( l_winners_rec.resource_id.count > 0) THEN
            -- Call the Process_TAP_Resource procedure to process all the returned resources
    	    -- from TAP_Get_Channel_Team
	    Process_TAP_Resources(
              p_partner_id        => l_partner_id,
              p_partner_type      => l_partner_types(j).attr_value,
              p_vad_partner_id    => p_vad_partner_id,
	      p_winners_rec       => l_winners_rec,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data,
              x_prtnr_access_id_tbl => l_partner_access_id_tbl);

              IF (l_partner_access_id_tbl.count > 0 ) THEN
                  l_resource_cnt := l_resource_cnt + l_partner_access_id_tbl.count ;
              END IF;
        END IF;
	 END LOOP;  -- FOR j IN 1..l_partner_types_cnt
   END LOOP; -- FOR i IN 1..l_partner_qualifiers_tbl.party_name.last

  END IF; --( l_partner_qualifiers_tbl.last > 0)

  IF (l_resource_cnt> 0 ) THEN
         l_cm_added := 'Y';
  ELSE
         l_cm_added := 'N';
  END IF;

  -- End of Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.

  -- Step3: If p_vad_partner_id is not null, then add all the CMs( Employees Of VAD Organinzation)
  -- to the p_partner_id's channel team. Ensure that you check for duplicates in access table. No territory
  -- records are added. set tap created flag to 'N' and keep flag = 'Y'
  IF ( NOT(p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) ) THEN

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_Utility_PVT.debug_message('START : Step3: If p_vad_partner_id is not null, then all the CMs( Employees of VAD Organization.');
      END IF;

      -- Get the VAD Channel Team -
	  Create_VAD_Channel_Team(
	      p_api_version_number  => 1.0 ,
              p_init_msg_list       => FND_API.G_FALSE ,
              p_commit              => FND_API.G_FALSE ,
              p_validation_level    => FND_API.G_VALID_LEVEL_FULL ,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data,
	      p_partner_id          => l_partner_id,
              p_vad_partner_id      => p_vad_partner_id,
              x_prtnr_access_id_tbl => l_vad_prtnr_access_id_tbl );

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_VAD_Channel_Team');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

      --- ===================================================================
      --- Store the returned resources from Create_VAD_Channel_Team procedure
      --- to the main output variable x_prtnr_access_id_tbl.
      --- ===================================================================
      IF (l_vad_prtnr_access_id_tbl.count > 0 ) THEN
	     l_cm_added := 'Y';
         FOR k_index IN 1..l_vad_prtnr_access_id_tbl.last
	 LOOP
           l_resource_cnt := l_resource_cnt + 1;
	   x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_vad_prtnr_access_id_tbl(k_index).partner_access_id;
	 END LOOP;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_Utility_PVT.debug_message('SUCCESSFULLY END : Step3.');
      END IF;

   END IF; -- l_vad_partner_id IS NOT NULL OR l_vad_partner_id <> FND_API.g_miss_num

   -- Assign Default Channel Manager as a Channel Team member, if both the above (Logged_in_User and
   -- TAP procedure call failed to add any channel team member.
   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message('START : Step4: Assign Default Channel Manager as a Channel Team member : l_cm_added => '||l_cm_added );
   END IF;

   IF ( l_cm_added <> 'Y' ) THEN
        -- Set the p_partner_access_rec record
	l_partner_access_rec.partner_id  := l_partner_id;
        l_partner_access_rec.resource_id := fnd_profile.value('PV_DEFAULT_CM');
	l_partner_access_rec.keep_flag   := 'Y';
        l_partner_access_rec.created_by_tap_flag := 'Y';
        l_partner_access_rec.access_type := 'F';

	  --- ==================================================================
      ---  Before adding the default CM, check to see if there are any CMs
      ---  added manually for a given p_partner_id.If yes, skip adding the
	  ---  default CM.
	  --- ==================================================================
	  IF (check_resource_exist(
	        p_partner_id   => l_partner_id
	        ,p_resource_id => l_partner_access_rec.resource_id ) = 'N') THEN


	     PV_Partner_Accesses_PVT.Create_Partner_Accesses(
                p_api_version_number => 1.0,
                p_init_msg_list      => FND_API.G_FALSE,
                p_commit             => FND_API.G_FALSE,
                p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_partner_access_rec => l_partner_access_rec,
                x_partner_access_id  => l_partner_access_id );

	     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	            FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                    FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_Partner_Accesses_PVT.Create_Partner_Accesses');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

             -- Store the PARTNER_ACCESS_ID in the Out variable
	     l_resource_cnt := l_resource_cnt + 1;
	     x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_partner_access_id;

          END IF ; --  check_resource_exist
     END IF; -- l_cm_added <> 'Y'

    -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;
*/

end Do_Cr_Online_Chnl_Team;
-- Start of Comments
--
--      API name  : Create_Online_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to create a Channel
--                  team for a given Partner_id in the PV_PARTNER_ACCESSES
--                  table.
--
--      Pre-reqs  : Existing resource should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    		p_validation_level     IN      NUMBER
--
--              p_partner_id           IN      NUMBER
--              p_vad_partner_id       IN      NUMBER
--              p_mode                 IN      VARCHAR2 ,
--              p_login_user           IN      NUMBER ,
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     NOCOPY PV_TERR_ASSIGN_PUB.prtnr_aces_tbl_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

--PN Obsoleted
PROCEDURE Create_Online_Channel_Team (
   p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
   ) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Dummy Declaration';
begin
--PN Not in use, Replaced by TERR and User APIs
--    dbms_output.put_line('Dummy stmt ');
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message('This procedure is not in use');
    END IF;

/*

 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_changed_partner_rec   PV_BATCH_CHG_PRTNR_PVT.batch_chg_prtnrs_rec_type ;

 -- Local variable declaration for all the Partner Qualifiers.
 l_party_site_id         NUMBER;
 l_party_id              NUMBER;
 l_partner_party_id      NUMBER;
 l_city                  VARCHAR2(60);
 l_country               VARCHAR2(60);
 l_county                VARCHAR2(60);
 l_state                 VARCHAR2(60);
 l_province              VARCHAR2(60);
 l_postal_code           VARCHAR2(60);
 l_phone_area_code       VARCHAR2(10);
 l_employees_total       NUMBER;
 l_party_name            VARCHAR2(360);
 l_category_code         VARCHAR2(30);
 l_curr_fy_potential_revenue NUMBER;
 l_partner_types         PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
 l_prtnr_access_id_tbl   JTF_NUMBER_TABLE;
 l_vad_prtnr_access_id_tbl prtnr_aces_tbl_type;
 l_partner_id            NUMBER;
 l_partner_types_cnt     NUMBER := 0;
 i     NUMBER := 0;
 l_partner_qualifier_rec partner_qualifiers_rec_type ;
 l_partner_exist         VARCHAR2(1) := 'N';
 l_territory_exist       VARCHAR2(1) := 'N';
 l_partner_access_id     NUMBER := 0;
 l_partner_access_rec    PV_Partner_Accesses_PVT.partner_access_rec_type;
 l_winners_rec	         JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_ind_winners_rec       JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 l_territory_access_rec  PV_TAP_ACCESS_TERRS_PVT.TAP_ACCESS_TERRS_REC_TYPE ;
 l_resource_cnt          NUMBER := 0;
 l_cm_added              VARCHAR2(1) := 'N' ;
 l_res_created_flg       VARCHAR2(1) := 'N' ;
 l_tap_created_flg       VARCHAR2(1) := 'N' ;
 l_login_user_id         NUMBER;
 l_partner_level         VARCHAR2(30);
 l_resource_rec          PV_TERR_ASSIGN_PUB.ResourceRec;
 l_partner_access_id_tbl prtnr_aces_tbl_type;
 l_partner_qualifiers_tbl partner_qualifiers_tbl_type;

  -- Cursor l_party_id_csr to get the party_id and partner_level for a given partner_id.
  CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, pacv.attr_code
    FROM   pv_partner_profiles ppp,
           PV_ATTRIBUTE_CODES_VL pacv
    WHERE  ppp.partner_id = cv_partner_id
    AND	   ppp.status = 'A'
    AND    ppp.partner_level = pacv.ATTR_CODE_ID(+);

  -- Cursor l_partner_types_csr, which takes partner_id as an input paramter, and gives
  -- the Partners types.
  CURSOR l_partner_type_csr (cv_partner_id NUMBER) IS
    SELECT attr_value
    FROM pv_enty_attr_values
    WHERE attribute_id = 3
    AND entity= 'PARTNER'
    AND entity_id = cv_partner_id
    AND latest_flag = 'Y';

  -- Cursor l_chk_territory_exist_csr to check whether given partner_access_id and terr_id exists in
  -- PV_TAP_ACCESS_TERRS table or not.
  CURSOR l_chk_territory_exist_csr (cv_partner_access_id IN NUMBER, cv_terr_id IN NUMBER) IS
      SELECT 'Y'
      FROM PV_TAP_ACCESS_TERRS
      WHERE partner_access_id = cv_partner_access_id
      AND   terr_id = cv_terr_id;

BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- =========================================================================
     -- Validate Environment
     -- =========================================================================

     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
         l_partner_id := p_partner_id;
     END IF;

     -- STEP (i) :
     -- Logic for inserting the logged in user's(Vendor employee) resource_id in the
     -- PV_PARTNER_ACCESSES table, IF the user is playing a role of
     -- 'CHANNEL_MANAGER' or 'CHANNEL_REP'

     IF (p_mode <> 'UPDATE') THEN
        IF (p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) THEN
            IF (p_login_user IS NULL OR p_login_user = FND_API.g_miss_num) THEN
               l_login_user_id := FND_GLOBAL.user_id;
            ELSE
               l_login_user_id := p_login_user;
            END IF;

            Cr_Login_User_Access_Rec(
     	       p_partner_id        => l_partner_id,
               p_login_user_id     => l_login_user_id,
	       x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
	       x_msg_data          => l_msg_data,
	       x_cm_added          => l_cm_added,
	       x_res_created_flg   => l_res_created_flg,
	       x_partner_access_id => l_partner_access_id);

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                   FND_MESSAGE.SET_TOKEN('API_NAME', 'Cr_Login_User_Access_Rec');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

            IF (l_cm_added = 'Y' ) THEN
               x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id:= l_partner_access_id ;
	       l_resource_cnt := l_resource_cnt + 1;
            END IF;
         END IF; -- p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num
      END IF;  -- p_mode <> 'UPDATE'

     -- STEP (ii) : Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.
     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message('START : STEP (ii) : Procesing of TAP returned resources with CHANNEL_MANAGER or CHANNEL_REP role.');
     END IF;

     -- Get the Partner Party Id for the given Partner_Id
     OPEN l_party_id_csr(l_partner_id);
     FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
     IF l_party_id_csr%NOTFOUND THEN
          CLOSE l_party_id_csr;
          -- Raise an error saying partner is not active
          fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
     ELSE
         CLOSE l_party_id_csr;
     END IF;

     -- Get the Partner Types details from l_partner_type_csr CURSOR.
     l_partner_types_cnt := 0;
     FOR prtnr_type_rec IN l_partner_type_csr(l_partner_id)
     LOOP
         l_partner_types_cnt := l_partner_types_cnt + 1;
	     l_partner_types(l_partner_types_cnt).attr_value := prtnr_type_rec.attr_value ;
     END LOOP;
     --l_partner_types_cnt := l_partner_types_cnt - 1;
     -- Get the Partner qualifiers details
     get_partner_details(
         p_party_id               => l_partner_party_id ,
         x_return_status          => l_return_status ,
         x_msg_count              => l_msg_count ,
         x_msg_data               => l_msg_data ,
         x_partner_qualifiers_tbl => l_partner_qualifiers_tbl );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'get_partner_details');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     END IF;

     IF ( l_partner_qualifiers_tbl.count >= 0) THEN
       FOR i IN 1..l_partner_qualifiers_tbl.last
       LOOP
	     l_party_site_id := l_partner_qualifiers_tbl(i).party_site_id;
         l_city := l_partner_qualifiers_tbl(i).city ;
       	 l_country := l_partner_qualifiers_tbl(i).country;
       	 l_county := l_partner_qualifiers_tbl(i).county;
       	 l_state := l_partner_qualifiers_tbl(i).state;
       	 l_province := l_partner_qualifiers_tbl(i).province;
       	 l_postal_code := l_partner_qualifiers_tbl(i).postal_code;
       	 l_phone_area_code := l_partner_qualifiers_tbl(i).area_code;
       	 l_employees_total := l_partner_qualifiers_tbl(i).number_of_employee;
       	 l_party_name := l_partner_qualifiers_tbl(i).partner_name;
       	 l_category_code := l_partner_qualifiers_tbl(i).customer_category_code;
       	 l_curr_fy_potential_revenue := l_partner_qualifiers_tbl(i).annual_revenue;

         -- Process with each partner type, one by one record.
	     FOR j IN 1..l_partner_types_cnt
	 LOOP
	    -- Make a place to store the Partner qualifiers in the l_partner_qualifier_tbl.
	    --l_partner_qualifier_tbl.extend;
	    --l_partner_qualifier_rec := g_miss_partner_qualifiers_rec;

            -- Initilize the Partner Qualifers table with valid values.
	    l_partner_qualifier_rec.partner_name := l_party_name;
	    l_partner_qualifier_rec.party_id  := l_partner_party_id;
            l_partner_qualifier_rec.area_code := l_phone_area_code;
            l_partner_qualifier_rec.city      := l_city ;
            l_partner_qualifier_rec.country   := l_country ;
            l_partner_qualifier_rec.county    := l_county ;
            l_partner_qualifier_rec.postal_code := l_postal_code;
            l_partner_qualifier_rec.province  := l_province ;
            l_partner_qualifier_rec.state     := l_state;
            l_partner_qualifier_rec.annual_Revenue := l_curr_fy_potential_revenue;
            l_partner_qualifier_rec.number_of_employee := l_employees_total;
            l_partner_qualifier_rec.customer_category_code := l_category_code ;
            l_partner_qualifier_rec.partner_type  := l_partner_types(j).attr_value;
	    l_partner_qualifier_rec.partner_level := l_partner_level;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('START : -- Call the TAP_Get_Channel_Team API ');
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.party_site_id);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') city => '|| l_partner_qualifier_rec.city);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') country => '|| l_partner_qualifier_rec.country);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') county => '|| l_partner_qualifier_rec.county);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') state => '|| l_partner_qualifier_rec.state);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') province => '|| l_partner_qualifier_rec.province);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') postal_code => '|| l_partner_qualifier_rec.postal_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') area_code => '|| l_partner_qualifier_rec.area_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner_name => '|| l_partner_qualifier_rec.partner_name);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') annual_revenue => '|| l_partner_qualifier_rec.annual_revenue);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') number_of_employee => '|| l_partner_qualifier_rec.number_of_employee);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') customer_category_code => '|| l_partner_qualifier_rec.customer_category_code);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner type => '|| l_partner_qualifier_rec.partner_type);
           PVX_Utility_PVT.debug_message('('||to_char(i)||') partner level => '|| l_partner_qualifier_rec.partner_level);
        END IF;

        -- Call the TAP_Get_Channel_Team API
        TAP_Get_Channel_Team(
            p_prtnr_qualifier_rec => l_partner_qualifier_rec,
	        x_return_Status       => l_return_status,
            x_msg_Count           => l_msg_count,
            x_msg_Data            => l_msg_data,
            x_winners_rec	      => l_winners_rec ) ;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	       FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.TAP_Get_Channel_Team');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('SUCCESSFULLY END : -- TAP_Get_Channel_Team ');
        END IF;


        IF ( l_winners_rec.resource_id.count > 0) THEN
            -- Call the Process_TAP_Resource procedure to process all the returned resources
    	    -- from TAP_Get_Channel_Team
	    Process_TAP_Resources(
              p_partner_id        => l_partner_id,
              p_partner_type      => l_partner_types(j).attr_value,
              p_vad_partner_id    => p_vad_partner_id,
	      p_winners_rec       => l_winners_rec,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data,
              x_prtnr_access_id_tbl => l_partner_access_id_tbl);

              IF (l_partner_access_id_tbl.count > 0 ) THEN
                  l_resource_cnt := l_resource_cnt + l_partner_access_id_tbl.count ;
              END IF;
        END IF;
	 END LOOP;  -- FOR j IN 1..l_partner_types_cnt
   END LOOP; -- FOR i IN 1..l_partner_qualifiers_tbl.party_name.last

  END IF; --( l_partner_qualifiers_tbl.last > 0)

  IF (l_resource_cnt> 0 ) THEN
         l_cm_added := 'Y';
  ELSE
         l_cm_added := 'N';
  END IF;

  -- End of Procesing of TAP returned resources with 'CHANNEL_MANAGER' or 'CHANNEL_REP' role.

  -- Step3: If p_vad_partner_id is not null, then add all the CMs( Employees Of VAD Organinzation)
  -- to the p_partner_id's channel team. Ensure that you check for duplicates in access table. No territory
  -- records are added. set tap created flag to 'N' and keep flag = 'Y'
  IF ( NOT(p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num) ) THEN

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_Utility_PVT.debug_message('START : Step3: If p_vad_partner_id is not null, then all the CMs( Employees of VAD Organization.');
      END IF;

      -- Get the VAD Channel Team -
	  Create_VAD_Channel_Team(
	      p_api_version_number  => 1.0 ,
              p_init_msg_list       => FND_API.G_FALSE ,
              p_commit              => FND_API.G_FALSE ,
              p_validation_level    => FND_API.G_VALID_LEVEL_FULL ,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data,
	      p_partner_id          => l_partner_id,
              p_vad_partner_id      => p_vad_partner_id,
              x_prtnr_access_id_tbl => l_vad_prtnr_access_id_tbl );

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_VAD_Channel_Team');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

      --- ===================================================================
      --- Store the returned resources from Create_VAD_Channel_Team procedure
      --- to the main output variable x_prtnr_access_id_tbl.
      --- ===================================================================
      IF (l_vad_prtnr_access_id_tbl.count > 0 ) THEN
	     l_cm_added := 'Y';
         FOR k_index IN 1..l_vad_prtnr_access_id_tbl.last
	 LOOP
           l_resource_cnt := l_resource_cnt + 1;
	   x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_vad_prtnr_access_id_tbl(k_index).partner_access_id;
	 END LOOP;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_Utility_PVT.debug_message('SUCCESSFULLY END : Step3.');
      END IF;

   END IF; -- l_vad_partner_id IS NOT NULL OR l_vad_partner_id <> FND_API.g_miss_num

   -- Assign Default Channel Manager as a Channel Team member, if both the above (Logged_in_User and
   -- TAP procedure call failed to add any channel team member.
   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message('START : Step4: Assign Default Channel Manager as a Channel Team member : l_cm_added => '||l_cm_added );
   END IF;

   IF ( l_cm_added <> 'Y' ) THEN
        -- Set the p_partner_access_rec record
	l_partner_access_rec.partner_id  := l_partner_id;
        l_partner_access_rec.resource_id := fnd_profile.value('PV_DEFAULT_CM');
	l_partner_access_rec.keep_flag   := 'Y';
        l_partner_access_rec.created_by_tap_flag := 'Y';
        l_partner_access_rec.access_type := 'F';

	  --- ==================================================================
      ---  Before adding the default CM, check to see if there are any CMs
      ---  added manually for a given p_partner_id.If yes, skip adding the
	  ---  default CM.
	  --- ==================================================================
	  IF (check_resource_exist(
	        p_partner_id   => l_partner_id
	        ,p_resource_id => l_partner_access_rec.resource_id ) = 'N') THEN


	     PV_Partner_Accesses_PVT.Create_Partner_Accesses(
                p_api_version_number => 1.0,
                p_init_msg_list      => FND_API.G_FALSE,
                p_commit             => FND_API.G_FALSE,
                p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_partner_access_rec => l_partner_access_rec,
                x_partner_access_id  => l_partner_access_id );

	     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	            FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                    FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_Partner_Accesses_PVT.Create_Partner_Accesses');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

             -- Store the PARTNER_ACCESS_ID in the Out variable
	     l_resource_cnt := l_resource_cnt + 1;
	     x_prtnr_access_id_tbl(l_resource_cnt).partner_access_id := l_partner_access_id;

          END IF ; --  check_resource_exist
     END IF; -- l_cm_added <> 'Y'

    -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN

     x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_Online_Channel_Team (-)');
      END IF;
*/
END Create_Online_Channel_Team;

-- Start of Comments
--
--      API name        : Create_VAD_Channel_Team
--      Type            : Public
--      Function        : The purpose of this procedure is to create a Channel
--                        team of all VAD employees for a given VAD_Partner_id in
--                        the PV_PARTNER_ACCESSES table.
--
--      Pre-reqs        : Existing resource should be a "Channel Manager" or
--                        "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number          	IN      NUMBER,
--		p_init_msg_list                 IN      VARCHAR2
--		p_commit                        IN      VARCHAR2
--    		p_validation_level		        IN	    NUMBER
--
--              p_partner_id                    IN      NUMBER
--              p_vad_partner_id                IN      NUMBER
--      OUT             :
--              x_return_status                 OUT     VARCHAR2(1)
--              x_msg_count                     OUT     NUMBER
--              x_msg_data                      OUT     VARCHAR2(2000)
--
--              x_prtnr_access_id_tbl  	        OUT     NUMBER
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team of VAD employees for a
--                      Partner Organization.
--
--
-- End of Comments

PROCEDURE Create_VAD_Channel_Team
(       p_api_version_number  IN  NUMBER ,
        p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
 	    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
 	    p_partner_id          IN  NUMBER,
        p_vad_partner_id      IN  NUMBER,
        x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
)IS

 l_api_name              CONSTANT VARCHAR2(30) := 'Create_VAD_Channel_Team';
 l_api_version_number    CONSTANT NUMBER   := 1.0;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR(2000);
 l_resourse_cnt          NUMBER:= 0;

 l_partner_id            NUMBER;
 l_vad_partner_id        NUMBER;
 l_vad_party_id          NUMBER;
 l_resource_id           NUMBER;
 l_partner_access_id     NUMBER;
 l_partner_access_rec  PV_PARTNER_ACCESSES_PVT.partner_access_rec_type;

  -- Cursor l_party_id_csr to get the VAD Partner Org Id by supplying the
  -- VAD Partner id.
  CURSOR l_VAD_party_id_csr (cv_vad_partner_id NUMBER) IS
    SELECT partner_party_id
    FROM   pv_partner_profiles a,
           pv_enty_attr_values b
    WHERE  a.partner_id = cv_vad_partner_id
    AND	   a.status = 'A'
    AND    a.partner_id = b.entity_id
    AND    b.entity = 'PARTNER'
    AND    b.attribute_id = 3
    AND    b.attr_value = 'VAD'
    AND    b.latest_flag = 'Y';

  -- Cursor l_VAD_contacts_csr to get the VAD Partner Contacts( with 'ChannelManager'
  -- or 'Channel Rep' role by supplying the VAD Org Id.
  CURSOR l_VAD_contacts_csr (cv_vad_party_id NUMBER) IS
    SELECT DISTINCT
         RES.resource_id
      FROM
         hz_relationships HZPR_PART_CONT ,
         hz_parties CONTACT ,
         jtf_rs_resource_extns RES ,
         jtf_rs_group_members GRPMEM,
         jtf_rs_group_usages GRPUSG,
         jtf_rs_role_relations ROLRELAT ,
         jtf_rs_roles_vl ROLE
    WHERE HZPR_PART_CONT.RELATIONSHIP_TYPE = 'EMPLOYMENT'
      AND HZPR_PART_CONT.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND HZPR_PART_CONT.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND HZPR_PART_CONT.status = 'A'
      AND HZPR_PART_CONT.start_date <= SYSDATE
      AND NVL(HZPR_PART_CONT.end_date,SYSDATE) >= SYSDATE
      AND HZPR_PART_CONT.object_id = cv_vad_party_id
      AND HZPR_PART_CONT.subject_id = CONTACT.PARTY_ID
      AND CONTACT.party_type = 'PERSON'
      AND HZPR_PART_CONT.party_id = RES.source_id
      AND RES.category = 'PARTY'
      AND sysdate between nvl(RES.start_date_active,sysdate) and
                      nvl(RES.end_date_active,sysdate)
      AND RES.resource_id = GRPMEM.resource_id
      AND NVL(GRPMEM.delete_flag,'N') = 'N'
      AND GRPMEM.group_id = GRPUSG.group_id
      AND GRPUSG.usage = 'PRM'
      AND GRPMEM.group_member_id=ROLRELAT.role_resource_id
      AND ROLRELAT.role_resource_type = 'RS_GROUP_MEMBER'
      AND NVL(ROLRELAT.delete_flag,'N') = 'N'
      AND ROLRELAT.start_date_active <= sysdate
      AND NVL(ROLRELAT.end_date_active,sysdate) >= sysdate
      AND ROLRELAT.role_id = ROLE.ROLE_ID
      AND ROLE.role_type_code = 'PRM'
      AND ROLE.MEMBER_FLAG = 'Y'
      AND ROLE.role_code IN ('CHANNEL_MANAGER', 'CHANNEL_REP')
      AND RES.user_id is not null;

 BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- =========================================================================
     -- Validate Environment
     -- =========================================================================

     IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
         l_partner_id := p_partner_id;
     END IF;

     -- Initialize the l_vad_partner_id.
     IF p_vad_partner_id IS NULL OR p_vad_partner_id = FND_API.g_miss_num THEN
         fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
         fnd_message.set_token('FIELD', 'VAD_PARTNER_ID');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
        l_vad_partner_id := p_vad_partner_id;
     END IF;

     -- Get the VAD Orgnization ID for the given VAD_Partner_id.
     OPEN l_VAD_party_id_csr(l_vad_partner_id);
     FETCH l_VAD_party_id_csr INTO l_vad_party_id;

     IF ( l_VAD_party_id_csr%NOTFOUND ) THEN
        CLOSE l_VAD_party_id_csr;
        -- Raise an error ;
	fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
     ELSE
        CLOSE l_VAD_party_id_csr;
     END IF;

     -- Some Common initilization of partner_accesses_rec
     l_partner_access_rec.partner_id := l_partner_id;
     l_partner_access_rec.keep_flag := 'Y';
     l_partner_access_rec.created_by_tap_flag := 'N';
     l_partner_access_rec.access_type := 'F';
     l_partner_access_rec.vad_partner_id := l_vad_partner_id;

     -- Get the VAD Orgnization Contacts with 'Channel Manager' or 'Channel Rep' role
     -- for the given VAD Org Id got from the previous step.
     OPEN l_VAD_contacts_csr(l_vad_party_id);
     LOOP
       FETCH l_VAD_contacts_csr INTO l_resource_id;
       EXIT WHEN l_VAD_contacts_csr%NOTFOUND;

       IF (check_resource_exist(l_partner_id, l_resource_id) = 'N')
       THEN
         l_resourse_cnt := l_resourse_cnt + 1;
         -- Create the resourse as a Channel Team member in PV_PARTNER_ACCESSES
         -- table by calling the PV_PARTNER_ACCESS_PVT.Create_Partner_Accesses
         -- procedure.

        -- set the resourse_id
         l_partner_access_rec.resource_id := l_resource_id;

         -- call the API
         PV_PARTNER_ACCESSES_PVT.Create_Partner_Accesses(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            p_commit               => FND_API.G_FALSE,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_partner_access_rec   => l_partner_access_rec,
            x_partner_access_id    => l_partner_access_id
         );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*	       FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
               FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_PARTNER_ACCESSES_PVT.Create_Partner_Accesses');
               FND_MSG_PUB.Add;
*/               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         -- Store the output variable
         x_prtnr_access_id_tbl(l_resourse_cnt).partner_access_id:= l_partner_access_id ;
       END IF;
     END LOOP;
     CLOSE l_VAD_contacts_csr;

     --
     -- End of API body.
     --

     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;


     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
     ( p_count          =>   l_msg_count,
       p_data           =>   l_msg_data
     );

  EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF ( l_VAD_contacts_csr%ISOPEN ) THEN
           CLOSE l_VAD_contacts_csr;
      END IF;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Create_VAD_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF ( l_VAD_contacts_csr%ISOPEN ) THEN
           CLOSE l_VAD_contacts_csr;
      END IF;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Create_VAD_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF ( l_VAD_contacts_csr%ISOPEN ) THEN
           CLOSE l_VAD_contacts_csr;
      END IF;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Create_VAD_Channel_Team (-)');
      END IF;
END Create_VAD_Channel_Team;

-- Start of Comments
--
--      API name  : Update_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to Update a Channel
--                  team of a given partner_id, whenever there is an update
--                  in any of the partner qualifiers.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    		p_validation_level     IN      NUMBER
--
--              p_partner_id           IN  NUMBER
--              p_vad_partner_id       IN  NUMBER
--              p_mode                 IN  VARCHAR2
--              p_prtnr_qualifier_rec  IN  partner_qualifiers_rec_type
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     prtnr_aces_tbl_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE Update_Channel_Team
(  p_api_version_number      IN  NUMBER ,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id              IN  NUMBER ,
   p_vad_partner_id          IN  NUMBER ,
   p_mode                    IN  VARCHAR2 := 'UPDATE',
   p_login_user              IN  NUMBER ,
   p_upd_prtnr_qflr_flg_rec  IN  prtnr_qflr_flg_rec_type,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl     OUT NOCOPY prtnr_aces_tbl_type
) IS
  l_partner_id              NUMBER;
  l_partner_party_id        NUMBER;
  l_vad_partner_id          NUMBER;
  l_partner_level           VARCHAR2(30);
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_Channel_Team';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR(2000);

  l_partner_access_id_tbl   prtnr_aces_tbl_type;

  -- Cursor l_party_id_csr to get the party_id and partner_level for a given partner_id.
  CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, partner_level
    FROM   pv_partner_profiles
    WHERE  partner_id = cv_partner_id
    AND	   status = 'A';

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Update_Channel_Team_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- =========================================================================
  -- Validate Environment
  -- =========================================================================

  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_Utility_PVT.debug_message('Validating the supplied partner Id.');
  END IF;

  IF p_partner_id IS NULL OR p_partner_id = FND_API.g_miss_num THEN
     fnd_message.Set_Name('PV', 'PV_REQUIRED_VALIDATION');
     fnd_message.set_token('FIELD', 'PARTNER_ID');
     fnd_msg_pub.Add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     l_partner_id := p_partner_id;
  END IF;

  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_Utility_PVT.debug_message('After successful validating the supplied partner Id.');
  END IF;

  -- Initialize the l_vad_partner_id.
  l_vad_partner_id := p_vad_partner_id;

  -- Get the Partner Party Id for the given Partner_Id
  OPEN l_party_id_csr(l_partner_id);
  FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
  IF l_party_id_csr%NOTFOUND THEN
     CLOSE l_party_id_csr;
  -- Raise an error saying partner is not active
     fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
     fnd_msg_pub.Add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     CLOSE l_party_id_csr;
  END IF;

  --  chk_partner_qflr_update(p_upd_prtnr_qflr_flg_rec);
  -- IF (chk_partner_qflr_updated(p_upd_prtnr_qflr_flg_rec ) = 'Y' OR
  --     chk_partner_qflr_updated(p_upd_prtnr_qflr_flg_rec ) = 'U' ) THEN

      Create_Channel_Team (
          p_api_version_number  => 1.0 ,
          p_init_msg_list       => FND_API.G_FALSE ,
          p_commit              => FND_API.G_FALSE ,
          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL ,
          p_partner_id          => l_partner_id ,
          p_vad_partner_id      => l_vad_partner_id ,
          p_mode                => p_mode ,
          p_login_user          => p_login_user,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          x_prtnr_access_id_tbl => l_partner_access_id_tbl );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*	     FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_Channel_Team');
             FND_MSG_PUB.Add;
*/             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

  -- END IF; /*** chk_partner_qflr_updated(p_upd_prtnr_qflr_flg_rec ) = 'U' ***/

  --
  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
      COMMIT WORK;
  END IF;

  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  ( p_count          =>   l_msg_count,
    p_data           =>   l_msg_data
  );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;
END Update_Channel_Team;

-- Start of Comments
--
--      API name  : Process_Channel_Team
--      Type      : Public
--      Function  : This is a common procedure, which one can call in the following case -
--			* Re-define channel team for partners in TOTAL/INCREMENTAL mode
--                      * Re-define channel team for all partners affected by the few territory
--                        definition change.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--              p_partner_id           IN  NUMBER
--              p_vad_partner_id       IN  NUMBER
--              p_login_user           IN  VARCHAR2
--              p_prtnr_qualifier_rec  IN  partner_qualifiers_rec_type
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     prtnr_aces_tbl_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for re-define a Channel Team for Partners Organization.
--
--
-- End of Comments

PROCEDURE Process_Channel_Team (
   p_partner_id              IN  NUMBER ,
   p_vad_partner_id          IN  NUMBER ,
   p_login_user              IN  NUMBER ,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl     OUT NOCOPY prtnr_aces_tbl_type
  ) IS

  l_return_status   VARCHAR2(1) ;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_partner_access_id_tbl  prtnr_aces_tbl_type;
  l_partner_qualifiers_tbl partner_qualifiers_tbl_type;
  l_partner_party_id    NUMBER;
  l_partner_level       VARCHAR2(30);


  CURSOR l_party_id_csr (cv_partner_id NUMBER) IS
    SELECT partner_party_id, pacv.attr_code
    FROM   pv_partner_profiles ppp,
           PV_ATTRIBUTE_CODES_VL pacv
    WHERE  ppp.partner_id = cv_partner_id
    AND	   ppp.status = 'A'
    AND    ppp.partner_level = pacv.ATTR_CODE_ID(+);


  BEGIN

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_UTILITY_PVT.debug_message('Private Procedure:Process_Channel_Team Start');
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Call the Delete_Channel_Team for a given Partner_id
     Delete_Channel_Team(
           p_partner_id          => p_partner_id ,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Delete_Channel_Team');
            FND_MSG_PUB.Add;
*/            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     END IF;



        -- Get the Partner Party Id for the given Partner_Id
        OPEN l_party_id_csr(p_partner_id);
        FETCH l_party_id_csr INTO l_partner_party_id, l_partner_level;
        IF l_party_id_csr%NOTFOUND THEN
          CLOSE l_party_id_csr;
          -- Raise an error saying partner is not active
          fnd_message.Set_Name('PV', 'PV_PARTNER_NOT_ACTIVE');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
         CLOSE l_party_id_csr;
        END IF;

        get_partner_details(
             p_party_id               => l_partner_party_id ,
             x_return_status          => l_return_status ,
             x_msg_count              => l_msg_count ,
             x_msg_data               => l_msg_data ,
             x_partner_qualifiers_tbl => l_partner_qualifiers_tbl );

    	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

     -- Call the Create_Channel_Team_Online for a given Partner_id

     	Create_Terr_Channel_Team(
                    p_api_version_number => 1.0,
		            p_init_msg_list      => FND_API.G_FALSE,
		            p_commit             => FND_API.G_FALSE,
		            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		            x_return_status      => l_return_status,
		            x_msg_count          => l_msg_count,
		            x_msg_data           => l_msg_data,
		            p_partner_id         => p_partner_id,
		    	    p_vad_partner_id     => p_vad_partner_id,
			        p_mode               => 'BATCH',
			        p_partner_qualifiers_tbl => l_partner_qualifiers_tbl,
		            p_login_user         => p_login_user,
		            x_prtnr_access_id_tbl=> x_prtnr_access_id_tbl );


		    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	               	RAISE FND_API.G_EXC_ERROR;
	            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
/*					FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
					FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_TERR_ASSIGN_PUB.Create_Terr_Channel_Team');
					FND_MSG_PUB.Add;
*/					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	            END IF;
	         END IF;



	         Create_User_Channel_Team( p_api_version_number => 1.0,
					p_init_msg_list      => FND_API.G_FALSE,
					p_commit             => FND_API.G_FALSE,
					p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
					p_partner_id         => p_partner_id,
					p_vad_partner_id     => p_vad_partner_id,
					p_mode               => 'BATCH',
					p_login_user         => p_login_user,
					x_return_status      => l_return_status,
					x_msg_count          => l_msg_count,
					x_msg_data           => l_msg_data,
					x_prtnr_access_id_tbl=> x_prtnr_access_id_tbl );

				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

					IF l_return_status = FND_API.G_RET_STS_ERROR THEN
							RAISE FND_API.G_EXC_ERROR;
					ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*						FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
						FND_MESSAGE.SET_TOKEN('API_NAME', 'Create_User_Channel_Team');
						FND_MSG_PUB.Add;
*/						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;

				END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_UTILITY_PVT.debug_message('Private Procedure:Process_Channel_Team End.');
     END IF;

  EXCEPTION
     WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');

         hz_utility_v2pub.debug('Process_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Process_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Process_Channel_Team (-)');
      END IF;
END Process_Channel_Team;
-- Start of Comments
--
--      API name  : do_Channel_Team_Assignment
--      Type      : Public
--      Function  : This procedure is to be called by all the newly swapned child preocess by the
--                  CC job.
--
--
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--              ERRBUF                OUT NOCOPY VARCHAR2,
--              RETCODE               OUT NOCOPY VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Concurrent request program for re-assignment of Channel Team
--                      for all the Partner Organizations stored in PV_PARTNER_PROFILES
--                      table.
--
--
-- End of Comments
PROCEDURE do_Channel_Team_Assignment(
    p_mode                IN  VARCHAR2,
    p_first_partner_id    IN  NUMBER,
    p_last_partner_id     IN  NUMBER,
    x_error_count         OUT NOCOPY  NUMBER)
IS

   -- Local variables declaration
   l_partner_id             NUMBER;
   lv_partner_id            NUMBER;
   l_vad_partner_id         NUMBER;
   l_login_user_id          NUMBER ;
   l_status                 BOOLEAN;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_err_mesg               VARCHAR2(255);
   l_partner_access_id_tbl  prtnr_aces_tbl_type;
   l_request_id             NUMBER := fnd_profile.value('CONC_REQUEST_ID');
   l_program_application_id NUMBER := fnd_profile.value('CONC_PROGRAM_APPICATION_ID');
   l_program_id             NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
   l_program_update_date    DATE   := sysdate;
   l_change_partner         PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_rec_type;
   rec_index                NUMBER := 0;
   l_newline                VARCHAR2(1) := FND_GLOBAL.Newline;
   l_batch_partner_id       NUMBER;
   l_batch_oversion_number  NUMBER;
   l_mode                   VARCHAR2(15) := p_mode;
   l_first_partner_id	    NUMBER := p_first_partner_id;
   l_last_partner_id	    NUMBER := p_last_partner_id;
   l_total_records          NUMBER ;

--New
   l_partner_name           VARCHAR2(360);
   l_partner_err_cnt        NUMBER;


   TYPE partner_list_rec_type IS RECORD
   (
--New
       partner_name         VARCHAR2(360),
       partner_id           NUMBER,
       vad_partner_id       NUMBER,
       object_version_number NUMBER,
       created_by           NUMBER
   ) ;

   g_miss_partner_list_rec          partner_list_rec_type := NULL;
   TYPE  partner_list_tbl_type      IS TABLE OF partner_list_rec_type INDEX BY BINARY_INTEGER;
   g_miss_partner_list_tbl          partner_list_tbl_type;

   l_partner_list_tbl      partner_list_tbl_type ;
   l_object_version_number  NUMBER;
   l_active_partner        VARCHAR2(1) := 'N';

   -- Cursor to select all partner_id's between cv_first_partner_id and cv_last_partner_id
   -- from PV_TAP_BATCH_CHG_PARTNERS table to delete them from the table, if running mode is TOTAL
   CURSOR l_batch_partners_csr(cv_first_partner_id  NUMBER, cv_last_partner_id NUMBER) IS
     SELECT partner_id , object_version_number
     FROM   PV_TAP_BATCH_CHG_PARTNERS
     WHERE PARTNER_ID BETWEEN cv_first_partner_id AND cv_last_partner_id;

   -- Cursor to select all the partner_id's between cv_first_partner_id and cv_last_partner_id
   -- from PV_TAP_BATCH_CHG_PARTNERS table for channel team re-assignment in case of INCREMENTAL mode.
   CURSOR l_chng_prtnrs_csr(cv_first_partner_id  NUMBER, cv_last_partner_id NUMBER) IS
/*
     SELECT partner_id, vad_partner_id, object_version_number,created_by
     FROM   PV_TAP_BATCH_CHG_PARTNERS
     WHERE  PROCESSED_FLAG = 'P'
     AND PARTNER_ID BETWEEN cv_first_partner_id AND cv_last_partner_id;
*/
--New
    SELECT hzp.party_name partner_name,ptbcp.partner_id, ptbcp.vad_partner_id, ptbcp.object_version_number,ptbcp.created_by
      FROM   PV_TAP_BATCH_CHG_PARTNERS ptbcp,
             PV_PARTNER_PROFILES ppp,
             HZ_PARTIES hzp
      WHERE  ptbcp.PROCESSED_FLAG = 'P'
--      AND ptbcp.PARTNER_ID BETWEEN cv_first_partner_id AND cv_last_partner_id
      AND ptbcp.PARTNER_ID >= cv_first_partner_id AND ptbcp.PARTNER_ID <= cv_last_partner_id
      AND    ptbcp.partner_id = ppp.partner_id
      AND    ppp.partner_party_id= hzp.party_id
      ORDER BY hzp.party_name ;

   -- Cursor to select all the partner_id's between cv_first_partner_id and cv_last_partner_id
   -- from PV_PARTNER_PROFILES table for channel team re-assignment in case of TOTAL mode.
   CURSOR l_profile_partners_csr(cv_first_partner_id  NUMBER, cv_last_partner_id NUMBER) IS
/*
     SELECT distinct partner_id, NULL "vad_partner_id", NULL "object_version_number" , created_by
     FROM   PV_PARTNER_PROFILES
     WHERE  STATUS = 'A'
     AND PARTNER_ID BETWEEN cv_first_partner_id AND cv_last_partner_id;
*/
--New
    SELECT distinct hzp.party_name partner_name, partner_id,
             NULL "vad_partner_id", NULL "object_version_number" , ppp.created_by
      FROM   PV_PARTNER_PROFILES ppp,
             HZ_PARTIES hzp
      WHERE  ppp.partner_party_id = hzp.party_id
--      AND ppp.PARTNER_ID BETWEEN cv_first_partner_id AND cv_last_partner_id;
      AND ppp.PARTNER_ID >= cv_first_partner_id AND ppp.PARTNER_ID <= cv_last_partner_id
      AND ppp.STATUS = 'A'
      order by hzp.party_name;


BEGIN
     -- Standard Start of savepoint
     SAVEPOINT do_Assign_Channel_Team_Pvt;

     -- RETCODE := FND_API.G_RET_STS_SUCCESS;

    -- Header Message for Processing starts
    fnd_message.set_name('PV', 'PV_TAP_CTEAM_HDR');
    fnd_message.set_token( 'P_DATE_TIME', TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
    Write_log (1, substrb(fnd_message.get, 1, 1000));

    rec_index := 0;
    IF ( l_mode = 'TOTAL' ) THEN
       FOR  l_profile_partner_rec IN l_profile_partners_csr(l_first_partner_id, l_last_partner_id)
       LOOP
            rec_index := rec_index + 1;
            l_partner_list_tbl(rec_index).partner_name := l_profile_partner_rec.partner_name;
            l_partner_list_tbl(rec_index).partner_id := l_profile_partner_rec.partner_id;
            l_partner_list_tbl(rec_index).vad_partner_id := null;
            l_partner_list_tbl(rec_index).object_version_number := 1;
            l_partner_list_tbl(rec_index).created_by := l_profile_partner_rec.created_by;
       END LOOP;


       -- WIPE OUT ALL THE PARTNER RECORDS FROM PV_TAP_BATCH_CHNG_PARTNERS TABLE --
       FOR l_batch_partner_list IN l_batch_partners_csr(l_first_partner_id, l_last_partner_id)
       LOOP
   	  l_batch_partner_id := l_batch_partner_list.partner_id;
          l_batch_oversion_number := l_batch_partner_list.object_version_number;
          PV_BATCH_CHG_PRTNR_PVT.Delete_Batch_Chg_Prtnrs(
             p_api_version_number    => 1.0 ,
             p_init_msg_list         => FND_API.G_FALSE,
             p_commit                => FND_API.G_FALSE,
             p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data,
             p_partner_id            => l_batch_partner_id,
             p_object_version_number => l_batch_oversion_number);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;
	END LOOP;

    ELSIF ( l_mode = 'INCREMENTAL') THEN
       FOR  l_change_partner_rec IN l_chng_prtnrs_csr(l_first_partner_id, l_last_partner_id)
       LOOP
            rec_index := rec_index + 1;
            l_partner_list_tbl(rec_index).partner_name := l_change_partner_rec.partner_name;
            l_partner_list_tbl(rec_index).partner_id := l_change_partner_rec.partner_id;
            l_partner_list_tbl(rec_index).vad_partner_id := l_change_partner_rec.vad_partner_id;
            l_partner_list_tbl(rec_index).object_version_number := l_change_partner_rec.object_version_number;
            l_partner_list_tbl(rec_index).created_by := l_change_partner_rec.created_by;
       END LOOP;
    END IF;

    -- Process all the Partner records selected in l_partners_list PL/SQL table
    IF ( l_partner_list_tbl.count > 0) THEN
       FOR i IN 1..l_partner_list_tbl.last
       LOOP
         BEGIN
           -- Standard Start of savepoint
           SAVEPOINT Process_Partner_Channel_Team;

           -- Initilize the local variables.
           l_partner_name := l_partner_list_tbl(i).partner_name;
           l_partner_id := l_partner_list_tbl(i).partner_id ;
	       l_vad_partner_id := l_partner_list_tbl(i).vad_partner_id;
           l_object_version_number := l_partner_list_tbl(i).object_version_number;
           l_login_user_id := l_partner_list_tbl(i).created_by;

           Process_Channel_Team(
	       p_partner_id          => l_partner_id ,
               p_vad_partner_id      => l_vad_partner_id ,
               p_login_user          => l_login_user_id  ,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count ,
               x_msg_data            => l_msg_data ,
               x_prtnr_access_id_tbl => l_partner_access_id_tbl );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

	   IF ( l_mode = 'TOTAL' ) THEN
              -- Create an error record in PV_TAP_BATCH_CHG_PARTNERS table with following
	      -- Concurrent request related attribute values
	      --         * REQUEST_ID
	      --         * PROGRAM_APPLICATION_ID
	      --         * PROGRAM_ID
	      --         * PROGRAM_UPDATE_DATE
	      ------------------------------------------------------------
              l_change_partner.partner_id := l_partner_id ;
              l_change_partner.request_id := l_request_id ;
              l_change_partner.program_application_id := l_program_application_id ;
              l_change_partner.program_id := l_program_id ;
              l_change_partner.program_update_date := l_program_update_date;
              l_change_partner.object_version_number := 1;
	      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		   l_change_partner.processed_flag := 'P';
	      ELSE
		   l_change_partner.processed_flag := 'S';
	      END IF;

	      PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
     		   p_api_version_number   => 1.0 ,
                   p_init_msg_list        => FND_API.G_TRUE,
                   p_commit               => FND_API.G_FALSE,
                   p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_batch_chg_prtnrs_rec => l_change_partner,
                   x_partner_id           => lv_partner_id );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;
	   ELSIF ( l_mode = 'INCREMENTAL' ) THEN
               -- Update the PV_TAP_BATCH_CHG_PARTNERS table for following
	       -- Concurrent request related attribute values
	       --         * REQUEST_ID
	       --         * PROGRAM_APPLICATION_ID
	       --         * PROGRAM_ID
	       --         * PROGRAM_UPDATE_DATE
	       ------------------------------------------------------------
               l_change_partner.partner_id := l_partner_id ;
               l_change_partner.request_id := l_request_id ;
               l_change_partner.program_application_id := l_program_application_id ;
               l_change_partner.program_id := l_program_id ;
               l_change_partner.program_update_date := l_program_update_date;
               l_change_partner.object_version_number := l_object_version_number;
               l_change_partner.last_update_date := sysdate;
               l_change_partner.last_update_by := FND_GLOBAL.user_id;
               l_change_partner.creation_date := sysdate;
               l_change_partner.created_by := FND_GLOBAL.user_id;
               l_change_partner.last_update_login :=  FND_GLOBAL.user_id;

               IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
           		l_change_partner.processed_flag := 'S';
	       END IF;

	       PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                 p_api_version_number   => 1.0 ,
                 p_init_msg_list        => FND_API.G_TRUE,
                 p_commit               => FND_API.G_FALSE,
                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data,
                 p_batch_chg_prtnrs_rec => l_change_partner );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;
	   END IF;

       COMMIT;

       -- Debug statement for each partner_id
       fnd_message.set_name('PV', 'PV_TAP_CTEAM_MSG');
---New
       fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
       fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--       fnd_message.set_token('PARTNER_ID', l_partner_id);
       Write_log (1, substrb(fnd_message.get, 1, 255));

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
            FND_MSG_PUB.count_and_get (
                 p_encoded => FND_API.g_false
                ,p_count   => l_msg_count
                ,p_data    => l_msg_data
                );
--new
--            RETCODE := FND_API.G_RET_STS_ERROR;
            l_partner_err_cnt := l_partner_err_cnt +1;
            apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
            l_msg_data := substr(apps.fnd_message.get,1,254);

            -- Debug statement for each partner_id
	    fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
--new
       fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
       fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--       fnd_message.set_token('PARTNER_ID', l_partner_id);

            fnd_message.set_token('ERROR', l_msg_data);
            Write_log (1, substrb(fnd_message.get, 1, 255));
            ROLLBACK TO Process_Partner_Channel_Team;
            fnd_msg_pub.Delete_Msg;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            FND_MSG_PUB.count_and_get (
                 p_encoded => FND_API.g_false
                ,p_count   => l_msg_count
                ,p_data    => l_msg_data
                );
--new
--                RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
                l_partner_err_cnt := l_partner_err_cnt +1;
                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                l_msg_data := substr(apps.fnd_message.get,1,254);

            -- Debug statement for each partner_id
	    fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
--new
       fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
       fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--       fnd_message.set_token('PARTNER_ID', l_partner_id);
            fnd_message.set_token('ERROR', l_msg_data);
            Write_log (1, substrb(fnd_message.get, 1, 255));
            ROLLBACK TO Process_Partner_Channel_Team;
            fnd_msg_pub.Delete_Msg;

       WHEN OTHERS THEN
            FND_MSG_PUB.count_and_get (
                 p_encoded => FND_API.g_false
                ,p_count   => l_msg_count
                ,p_data    => l_msg_data
                );

--                RETCODE := '2';
                l_partner_err_cnt := l_partner_err_cnt +1;
                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                l_msg_data := substr(apps.fnd_message.get,1,254);

            -- Debug statement for each partner_id
	    fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
--new
        fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
        fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--       fnd_message.set_token('PARTNER_ID', l_partner_id);
            fnd_message.set_token('ERROR', l_msg_data);
            Write_log (1, substrb(fnd_message.get, 1, 255));
            ROLLBACK  TO Process_Partner_Channel_Team;
            fnd_msg_pub.Delete_Msg;
	 END ;
   END LOOP;
  END IF ;


--New
    x_error_count := l_partner_err_cnt;
 -- Footer Message for Processing End.
   fnd_message.set_name('PV', 'PV_TAP_CTEAM_FOOTER');
   fnd_message.set_token('TOT_PRTNR_CNT', to_char(l_partner_list_tbl.count) );
   fnd_message.set_token('SUC_PRTNR_CNT', to_char(l_partner_list_tbl.count-l_partner_err_cnt) );
   fnd_message.set_token('ERR_PRTNR_CNT', to_char(l_partner_err_cnt) );
   fnd_message.set_token('P_DATE_TIME', TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
   Write_log (1, substrb(fnd_message.get, 1, 1000));


--till here

  COMMIT;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Assign_Channel_Team_Pvt;
          --RETCODE := FND_API.G_RET_STS_ERROR;
          l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
          --ERRBUF := l_err_mesg ;
          l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
          Write_log (1, l_err_mesg);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Assign_Channel_Team_Pvt;
          --RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
          l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
          --ERRBUF := l_err_mesg ;
          l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
          Write_log (1, l_err_mesg);

    WHEN OTHERS THEN
          ROLLBACK  TO Assign_Channel_Team_Pvt;
          --RETCODE := '2';
          l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
          --ERRBUF := l_err_mesg ;
          l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
          Write_log (1, l_err_mesg);

END do_Channel_Team_Assignment;

-- Start of Comments
--
--      API name  : Assign_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to Update the Channel
--                  team for all partner_id by running in TOTAL_MODE. This procedure attached to
--                  'Territory assignment for partners in TOTAL mode' concurrent request program.
--                  It reads all the partner_id from PV_PARTNER_PROFILES table and re-assign the
--                  channel team.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--              ERRBUF                OUT NOCOPY VARCHAR2,
--              RETCODE               OUT NOCOPY VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Concurrent request program for re-assignment of Channel Team
--                      for all the Partner Organizations stored in PV_PARTNER_PROFILES
--                      table.
--
--
-- End of Comments

PROCEDURE Assign_Channel_Team(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_mode                IN  VARCHAR2,
    p_first_partner_id    IN  NUMBER,
    p_last_partner_id     IN  NUMBER
 )
IS
   -- Cursor to select count of all the partner_id's from PV_TAP_BATCH_CHG_PARTNERS table
   -- for channel team re-assignment in case of INCREMENTAL mode.
   CURSOR l_change_partners_count_csr IS
          SELECT  /*+ index(ptbcp1 PV_TAP_BATCH_CHG_PARTNERS_N1) */ count(*)
          FROM PV_TAP_BATCH_CHG_PARTNERS
	  WHERE PROCESSED_FLAG = 'P' ;

   -- Cursor to select all count of all the partner_id's from PV_PARTNER_PROFILES table
   -- for channel team re-assignment in case of TOTAL mode.
   CURSOR l_profile_partners_count_csr IS
          SELECT count(*)
          FROM PV_PARTNER_PROFILES
	  WHERE STATUS = 'A' ;

   -- Cursor to select single partner_id from PV_TAP_BATCH_CHG_PARTNERS table
   -- for channel team re-assignment in case if only one partner exist.
   CURSOR l_single_batch_partner_csr IS
          SELECT /*+ index(ptbcp1 PV_TAP_BATCH_CHG_PARTNERS_N1) */ partner_id
          FROM PV_TAP_BATCH_CHG_PARTNERS
	  WHERE PROCESSED_FLAG = 'P' ;

   -- Cursor to select single partner_id from PV_PARTNER_PROFILES table
   -- for channel team re-assignment in case if only one partner exist.
   CURSOR l_single_profile_partner_csr IS
          SELECT partner_id
          FROM PV_PARTNER_PROFILES
	  WHERE STATUS = 'A' ;

   -- Cursor to select partner_id's in batches from PV_TAP_BATCH_CHG_PARTNERS table
   -- for channel team re-assignment in case of INCREMENTAL mode based on batch size.
   CURSOR l_change_partners_csr(cv_batch_size  NUMBER) IS
     SELECT first.f,decode(last.l,null,(SELECT max(partner_id)
                                        FROM PV_TAP_BATCH_CHG_PARTNERS
					WHERE partner_id >= first.f
					AND PROCESSED_FLAG = 'P'
					AND last.l is null),last.l) la
     FROM
        (SELECT decode(mod(rn,cv_batch_size),1,partner_id,null) f,null last,rownum rn
	   FROM ( SELECT PARTNER_ID,ROWNUM RN
	          FROM ( SELECT /*+ index(ptbcp1 PV_TAP_BATCH_CHG_PARTNERS_N1) */  partner_id
	                 FROM PV_TAP_BATCH_CHG_PARTNERS
		         WHERE PROCESSED_FLAG = 'P'
		         ORDER BY partner_id asc ) )
                  WHERE decode(mod(rn,cv_batch_size),1,partner_id,null) IS NOT null ) first,
        (SELECT null first,decode(mod(rn,cv_batch_size),0,partner_id,null) l,rownum rn
	   FROM ( SELECT PARTNER_ID,ROWNUM RN
	          FROM ( SELECT /*+ index(ptbcp1 PV_TAP_BATCH_CHG_PARTNERS_N1) */  partner_id
	                 FROM PV_TAP_BATCH_CHG_PARTNERS
		         WHERE PROCESSED_FLAG = 'P'
		         ORDER BY partner_id asc) )
           WHERE decode(mod(rn,cv_batch_size),0,partner_id,null) is not null) last
    WHERE first.rn=last.rn(+);

   -- Cursor to select partner_id's in batches from PV_PARTNER_PROFILES table
   -- for channel team re-assignment in case of TOTAL mode based on batch size.
   CURSOR l_profile_partners_csr(cv_batch_size  NUMBER) IS
         SELECT first.f,decode(last.l,null,(SELECT max(partner_id)
                                              FROM PV_PARTNER_PROFILES
					     WHERE partner_id >= first.f
				               AND STATUS = 'A'
				               AND last.l is null),last.l) la
     FROM
        (SELECT decode(mod(rn,cv_batch_size),1,partner_id,null) f,null last,rownum rn
	   FROM ( SELECT PARTNER_ID,ROWNUM RN
	          FROM ( SELECT partner_id
                         FROM PV_PARTNER_PROFILES
                         WHERE STATUS = 'A'
                         ORDER BY partner_id asc ) )
          WHERE decode(mod(rn,cv_batch_size),1,partner_id,null) IS NOT null ) first ,
        (SELECT null first,decode(mod(rn,cv_batch_size),0,partner_id,null) l,rownum rn
	   FROM ( SELECT PARTNER_ID,ROWNUM RN
	           FROM( SELECT partner_id
                         FROM PV_PARTNER_PROFILES
                         WHERE STATUS = 'A'
                         ORDER BY partner_id asc) )
         WHERE decode(mod(rn,cv_batch_size),0,partner_id,null) is not null) last
    WHERE first.rn=last.rn(+);

    -- Declaration of Local variables.

    l_batch_size	NUMBER;
    l_total_records	NUMBER;
    l_mode              VARCHAR2(15) := p_mode;
    l_status            BOOLEAN;
    l_request_id	NUMBER;
    l_total_children	NUMBER;

    l_first_partner_id  NUMBER := p_first_partner_id;
    l_last_partner_id   NUMBER := p_last_partner_id;
    l_new_request_id	NUMBER;

    l_partner_err_cnt   NUMBER;

    l_wait_status        BOOLEAN;
    l_err_mesg           VARCHAR2(4000);
    x_phase              VARCHAR2(30);
    x_status             VARCHAR2(30);
    x_dev_phase          VARCHAR2(30);
    x_dev_status         VARCHAR2(30);
    x_message            VARCHAR2(240);

    TYPE request_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_request_id_tbl request_id_tbl;

BEGIN
     -- Standard Start of savepoint
     SAVEPOINT Assign_Channel_Team_Pvt;
     l_partner_err_cnt := 0;
     RETCODE := FND_API.G_RET_STS_SUCCESS;

     IF p_first_partner_id IS NOT NULL THEN

       do_Channel_Team_Assignment(
		p_mode => p_mode,
		p_first_partner_id => p_first_partner_id,
		p_last_partner_id => p_last_partner_id,
        x_error_count => l_partner_err_cnt);

      IF (l_partner_err_cnt > 0) THEN
         RETCODE := FND_API.G_RET_STS_ERROR;
         l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', SQLERRM);
      END IF;



    ELSIF p_first_partner_id is NULL THEN
        -- Get the total_records for processing for Channel Team Assignment
        IF p_mode = 'TOTAL' THEN
	   OPEN l_profile_partners_count_csr;
	   FETCH l_profile_partners_count_csr INTO l_total_records;
	   CLOSE l_profile_partners_count_csr;
	ELSE
	   OPEN l_change_partners_count_csr;
	   FETCH l_change_partners_count_csr INTO l_total_records;
	   CLOSE l_change_partners_count_csr;
	END IF;

        -- IF l_total_recors is NULL then initialize with 0.
        IF (l_total_records < 0 OR l_total_records is NULL) THEN
	   l_total_records := 0;
	END IF;

        --Get the batch size for each thread from profile
        l_batch_size := nvl(to_number(FND_PROFILE.value('PV_BATCH_SIZE_FOR_TAP_PROCESSING')),0);

	--handle condition if batch size for parallel import is set to -ve or zero.
        IF l_batch_size <= 0 THEN
           l_batch_size := l_total_records;
        END IF;

        IF l_total_records > 1 THEN

	   --Calculate number of child processes required
           l_total_children := ceil(l_total_records/l_batch_size);

	   IF (l_total_children <= 0 ) THEN
	       l_total_children := 1;
	   END IF;

	   IF ( p_mode = 'TOTAL' ) THEN
	      OPEN l_profile_partners_csr(l_batch_size);
	   ELSE
	      OPEN l_change_partners_csr(l_batch_size);
	   END IF;

	   --Spawn child conc requests
           FOR child_idx IN 1..l_total_children
	   LOOP

	      IF ( p_mode = 'TOTAL' ) THEN
		 FETCH l_profile_partners_csr INTO l_first_partner_id, l_last_partner_id ;
	      ELSE
		 FETCH l_change_partners_csr INTO l_first_partner_id, l_last_partner_id ;
	      END IF;

              l_new_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      application       => 'PV',
                      program           => 'PVTAPTR',
                      argument1         => p_mode,
                      argument2         => l_first_partner_id,
		      argument3         => l_last_partner_id
                   );

               IF l_new_request_id = 0 THEN
	          write_log(1, 'Error during submission of child request #'||child_idx);
	       END IF;

               write_log(1, 'Spawned child# '||to_char(child_idx)||' request_id: '||to_char(l_new_request_id));

	       l_request_id_tbl(child_idx) := l_new_request_id;
           END LOOP;

           IF ( p_mode = 'TOTAL' ) THEN
	      CLOSE l_profile_partners_csr;
	   ELSE
	      CLOSE l_change_partners_csr;
	   END IF;

	   commit;
	   --Wait for children to finish
           FOR child_idx IN 1 .. l_request_id_tbl.count
	   LOOP

               l_wait_status := FND_CONCURRENT.WAIT_FOR_REQUEST (
                        request_id        => l_request_id_tbl(child_idx),
                        phase             => x_phase,
                        status            => x_status,
                        dev_phase         => x_dev_phase,
                        dev_status        => x_dev_status,
                        message           => x_message
                        );

           END LOOP;
        ELSIF (l_total_records = 1 ) THEN
           IF ( p_mode = 'TOTAL' ) THEN
	      OPEN l_single_profile_partner_csr;
	      FETCH l_single_profile_partner_csr INTO l_first_partner_id;
	      CLOSE l_single_profile_partner_csr;
	      l_last_partner_id := l_first_partner_id;
	   ELSE
	      OPEN l_single_batch_partner_csr;
	      FETCH l_single_batch_partner_csr INTO l_first_partner_id;
	      CLOSE l_single_batch_partner_csr;
	      l_last_partner_id := l_first_partner_id;
	   END IF;

           do_Channel_Team_Assignment(
		p_mode => l_mode,
		p_first_partner_id => l_first_partner_id,
		p_last_partner_id => l_last_partner_id,
        x_error_count => l_partner_err_cnt);
	ELSE   -- l_total_records = 0
           write_log(3, 'Batch size: 0');
           l_total_children := 0;
	END IF;  --- l_total_records > 0
    END IF;  ---  p_first_partner_id is NULL

    -- Footer Message for Main Processing End.
    fnd_message.set_name('PV', 'PV_TAP_CTEAM_FOOTER');
    fnd_message.set_token('P_DATE_TIME', TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
    Write_log (1, substrb(fnd_message.get, 1, 255));

    EXCEPTION
        WHEN OTHERS THEN
		ROLLBACK TO Assign_Channel_Team_Pvt;
		RETCODE := FND_API.G_RET_STS_ERROR;
		l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
		ERRBUF := l_err_mesg ;
		l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
		Write_log (1, l_err_mesg);

END Assign_Channel_Team;


-- Start of Comments
--
--      API name  : Process_Sub_Territories
--      Type      : Public
--      Function  : The purpose  of  this procedure  is  to  Update the  Channel team for
--                  all those Partner's,  who  get  affected  by the  change in territory
--                  definition.  This  procedure attached to  'Re-define Channel team for
--                  specific territories'  concurrent request  program. It  reads all the
--                  partner_id  from  PV_PARTNER_ACCESSES table and re-assign the channel
--                  team.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--              ERRBUF                OUT NOCOPY VARCHAR2,
--              RETCODE               OUT NOCOPY VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Concurrent request program for re-assignment of Channel Team
--                      for all the Partner Organizations stored in PV_PARTNER_PROFILES
--                      table.
--
--
-- End of Comments

PROCEDURE Process_Sub_Territories(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_terr_id1            IN  NUMBER,
    p_terr_id2            IN  NUMBER,
    p_terr_id3            IN  NUMBER,
    p_terr_id4            IN  NUMBER,
    p_terr_id5            IN  NUMBER,
    p_terr_id6            IN  NUMBER,
    p_terr_id7            IN  NUMBER,
    p_terr_id8            IN  NUMBER,
    p_terr_id9            IN  NUMBER,
    p_terr_id10           IN  NUMBER,
    p_terr_id11           IN  NUMBER,
    p_terr_id12           IN  NUMBER,
    p_terr_id13           IN  NUMBER,
    p_terr_id14           IN  NUMBER,
    p_terr_id15           IN  NUMBER,
    p_terr_id16           IN  NUMBER,
    p_terr_id17           IN  NUMBER,
    p_terr_id18           IN  NUMBER,
    p_terr_id19           IN  NUMBER,
    p_terr_id20           IN  NUMBER )

IS
   -- Local variables declaration
   l_partner_id             NUMBER;
   lv_partner_id            NUMBER;
   l_vad_partner_id         NUMBER ;
   l_login_user_id          NUMBER := FND_GLOBAL.user_id;
   l_status                 BOOLEAN;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_err_mesg               VARCHAR2(255);
   l_partner_access_id_tbl  prtnr_aces_tbl_type;
   l_request_id             NUMBER := fnd_profile.value('CONC_REQUEST_ID');
   l_program_application_id NUMBER := fnd_profile.value('CONC_PROGRAM_APPICATION_ID');
   l_program_id             NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
   l_program_update_date    DATE   := sysdate;
   l_change_partner         PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_rec_type;
   rec_index                NUMBER := 0;
   l_newline                VARCHAR2(1) := FND_GLOBAL.Newline;
   l_batch_partner_id       NUMBER;
   l_batch_oversion_number  NUMBER;
   l_return_terr_str        VARCHAR2(2000);
   l_partner_rec_exists     VARCHAR2(1) := 'N';
   l_object_version_number  NUMBER;
   l_partner_err_cnt        NUMBER;

   TYPE partner_list_rec_type IS RECORD
   (
       partner_id           NUMBER
   ) ;

   g_miss_partner_list_rec          partner_list_rec_type := NULL;
   TYPE  partner_list_tbl_type      IS TABLE OF partner_list_rec_type INDEX BY BINARY_INTEGER;
   g_miss_partner_list_tbl          partner_list_tbl_type;

   l_partner_list_tbl      partner_list_tbl_type ;
   l_partner_name           VARCHAR2(360);


   -- Cursor to select all partner_id's from PV_TAP_BATCH_CHG_PARTNERS table
   -- to delete them from the table, if running mode is TOTAL
   CURSOR l_batch_partners_csr(cv_partner_id NUMBER) IS
     SELECT partner_id , object_version_number
     FROM   PV_TAP_BATCH_CHG_PARTNERS
     WHERE partner_id = cv_partner_id;

   -- Cursor to select all the partner_id's from PV_TAP_BATCH_CHG_PARTNERS table
   -- for channel team re-assignment in case of INCREMENTAL mode.
   CURSOR l_terr_chng_prtnrs_csr(
            cv_terr_id1  NUMBER, cv_terr_id2  NUMBER,
            cv_terr_id3  NUMBER, cv_terr_id4  NUMBER,
            cv_terr_id5  NUMBER, cv_terr_id6  NUMBER,
            cv_terr_id7  NUMBER, cv_terr_id8  NUMBER,
            cv_terr_id9  NUMBER, cv_terr_id10 NUMBER,
            cv_terr_id11 NUMBER, cv_terr_id12 NUMBER,
            cv_terr_id13 NUMBER, cv_terr_id14 NUMBER,
            cv_terr_id15 NUMBER, cv_terr_id16 NUMBER,
            cv_terr_id17 NUMBER, cv_terr_id18 NUMBER,
            cv_terr_id19 NUMBER, cv_terr_id20 NUMBER ) IS
     SELECT  ppa.partner_id
     FROM pv_partner_accesses ppa,
          pv_partner_profiles ppp,
          pv_tap_access_terrs ptat
     WHERE ppa.partner_access_id = ptat.partner_access_id
           AND ppa.partner_id = ppp.partner_id
           AND ppp.status = 'A'
           AND ptat.terr_id IN (
            cv_terr_id1,  cv_terr_id2,  cv_terr_id3,  cv_terr_id4,
            cv_terr_id5,  cv_terr_id6,  cv_terr_id7,  cv_terr_id8,
            cv_terr_id9,  cv_terr_id10, cv_terr_id11, cv_terr_id12,
            cv_terr_id13, cv_terr_id14, cv_terr_id15, cv_terr_id16,
            cv_terr_id17, cv_terr_id18, cv_terr_id19, cv_terr_id20);

   -- Cursor to select all the partner_id's from PV_TAP_BATCH_CHG_PARTNERS table
   -- for channel team re-assignment in case of INCREMENTAL mode.
   CURSOR l_chk_partner_exists_csr(cv_partner_id IN NUMBER )IS
     SELECT object_version_number
     FROM PV_TAP_BATCH_CHG_PARTNERS
     WHERE partner_id = cv_partner_id
     AND processed_flag = 'P';

      -- Cursor to select partner detail for the given partner_id's from
    -- PV_PARTNER_PROFILES table for channel team re-assignment in case of Process
    -- territories.
    CURSOR l_prof_partner_info_csr(cv_partner_id NUMBER) IS
      SELECT distinct hzp.party_name partner_name
      FROM   PV_PARTNER_PROFILES ppp,
             HZ_PARTIES hzp
      WHERE  ppp.partner_id = cv_partner_id
      AND ppp.partner_party_id = hzp.party_id
      AND ppp.STATUS = 'A';
 --     order by hzp.party_name;


BEGIN
     -- Standard Start of savepoint
     SAVEPOINT Process_Sub_Territories_Pvt;
 -- initialize the error count to zero.
      l_partner_err_cnt := 0;

    -- Header Message for Processing starts
    fnd_message.set_name('PV', 'PV_TAP_CTEAM_HDR');
    fnd_message.set_token('P_DATE_TIME', to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
    Write_log (1, substrb(fnd_message.get, 1, 1000));

    rec_index := 0;
--    FOR  l_change_partner_rec IN l_terr_chng_prtnrs_csr(l_return_terr_str)
    FOR  l_change_partner_rec IN l_terr_chng_prtnrs_csr(
             p_terr_id1,  p_terr_id2,  p_terr_id3,  p_terr_id4,
             p_terr_id5,  p_terr_id6,  p_terr_id7,  p_terr_id8,
             p_terr_id9,  p_terr_id10, p_terr_id11, p_terr_id12,
             p_terr_id13, p_terr_id14, p_terr_id15, p_terr_id16,
             p_terr_id17, p_terr_id18, p_terr_id19, p_terr_id20)
    LOOP
         rec_index := rec_index + 1;
	     l_partner_list_tbl(rec_index).partner_id := l_change_partner_rec.partner_id;
    END LOOP;

    -- Process all the Partner records selected in l_partners_list PL/SQL table
    IF ( l_partner_list_tbl.count > 0) THEN
       FOR i IN 1..l_partner_list_tbl.last
       LOOP
         BEGIN
           -- Standard Start of savepoint
           SAVEPOINT Process_Partner_Channel_Team;

           -- Initilize the local variables.
           l_partner_id := l_partner_list_tbl(i).partner_id ;
	   l_vad_partner_id := null;
           l_object_version_number := null;

       /****** Get the Partner Details ******/
            OPEN l_prof_partner_info_csr(l_partner_id);
            FETCH l_prof_partner_info_csr INTO l_partner_name;
            CLOSE l_prof_partner_info_csr;

           Process_Channel_Team(
	       p_partner_id          => l_partner_id ,
               p_vad_partner_id      => l_vad_partner_id ,
               p_login_user          => l_login_user_id  ,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count ,
               x_msg_data            => l_msg_data ,
               x_prtnr_access_id_tbl => l_partner_access_id_tbl );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

	   -- Check, whether that non-processed PARTNER_ID already exists in
	   -- PV_TAP_BATCH_CHG_PARTNERS table.
	      -- IF it exists, THEN
	      --    UPDATE the record for that PARTNER_ID with the appropriate PROCESSED_FLAG status.
	      -- ELSE
	      --    CREATE a record for that PARTNER_ID with the appropriate PROCESSED_FLAG status.
	      -- END IF;

	   OPEN l_batch_partners_csr(l_partner_id);
	   FETCH l_batch_partners_csr INTO lv_partner_id, l_object_version_number;

	   IF ( l_batch_partners_csr%NOTFOUND ) THEN
                CLOSE l_batch_partners_csr;
            -- Create an error record in PV_TAP_BATCH_CHG_PARTNERS table with following
	        -- Concurrent request related attribute values
	        --         * REQUEST_ID
	        --         * PROGRAM_APPLICATION_ID
	        --         * PROGRAM_ID
	        --         * PROGRAM_UPDATE_DATE
	        ------------------------------------------------------------
                l_change_partner.partner_id := l_partner_id ;
                l_change_partner.request_id := l_request_id ;
                l_change_partner.program_application_id := l_program_application_id ;
                l_change_partner.program_id := l_program_id ;
                l_change_partner.program_update_date := l_program_update_date;
                l_change_partner.object_version_number := 1;
		IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	         l_change_partner.processed_flag := 'P';
    	ELSE
	         l_change_partner.processed_flag := 'S';
		END IF;

        PV_BATCH_CHG_PRTNR_PVT.create_Batch_Chg_Partners(
           p_api_version_number   => 1.0 ,
           p_init_msg_list        => FND_API.G_FALSE,
           p_commit               => FND_API.G_FALSE,
           p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           p_batch_chg_prtnrs_rec => l_change_partner,
           x_partner_id           => lv_partner_id );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*		FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners');
                FND_MSG_PUB.Add;
*/                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF;
	   ELSIF ( l_batch_partners_csr%FOUND ) THEN
               CLOSE l_batch_partners_csr;
              -- Update the PV_TAP_BATCH_CHG_PARTNERS table for following
              -- Concurrent request related attribute values
              --         * REQUEST_ID
	          --         * PROGRAM_APPLICATION_ID
	          --         * PROGRAM_ID
	          --         * PROGRAM_UPDATE_DATE
	          ------------------------------------------------------------
               l_change_partner.partner_id := l_partner_id ;
               l_change_partner.request_id := l_request_id ;
               l_change_partner.program_application_id := l_program_application_id ;
               l_change_partner.program_id := l_program_id ;
               l_change_partner.program_update_date := l_program_update_date;
               l_change_partner.object_version_number := l_object_version_number;
               l_change_partner.last_update_date := sysdate;
               l_change_partner.last_update_by := FND_GLOBAL.user_id;
               l_change_partner.creation_date := sysdate;
               l_change_partner.created_by := FND_GLOBAL.user_id;
               l_change_partner.last_update_login :=  FND_GLOBAL.user_id;

               IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
          		    l_change_partner.processed_flag := 'S';
	           END IF;

	           PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                  p_api_version_number   => 1.0 ,
                  p_init_msg_list        => FND_API.G_FALSE,
                  p_commit               => FND_API.G_FALSE,
                  p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data,
                  p_batch_chg_prtnrs_rec => l_change_partner );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
/*		    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                    FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                    FND_MSG_PUB.Add;
*/                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;
	   END IF; -- l_chk_partner_exists_csr%FOUND

           -- Debug statement for each partner_id
    	   fnd_message.set_name('PV', 'PV_TAP_CTEAM_MSG');
    	   fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
    	   fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--           fnd_message.set_token('PARTNER_ID', l_partner_id);
           Write_log (1, substrb(fnd_message.get, 1, 255));

          EXCEPTION
              WHEN FND_API.G_EXC_ERROR THEN

	        IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
		END IF;

                FND_MSG_PUB.count_and_get (
                    p_encoded => FND_API.g_false
                   ,p_count   => l_msg_count
                   ,p_data    => l_msg_data
                );

                l_partner_err_cnt := l_partner_err_cnt +1;
                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                l_msg_data := substr(apps.fnd_message.get,1,254);


                -- Debug statement for each partner_id
	        fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
    	   fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
    	   fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--           fnd_message.set_token('PARTNER_ID', l_partner_id);
                fnd_message.set_token('ERROR', l_msg_data);
                Write_log (1, substrb(fnd_message.get, 1, 255));
                ROLLBACK TO Process_Partner_Channel_Team;
                fnd_msg_pub.Delete_Msg;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
	       END IF;

                FND_MSG_PUB.count_and_get (
                    p_encoded => FND_API.g_false
                   ,p_count   => l_msg_count
                   ,p_data    => l_msg_data
                );

                l_partner_err_cnt := l_partner_err_cnt +1;
                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                l_msg_data := substr(apps.fnd_message.get,1,254);

                -- Debug statement for each partner_id
           fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
    	   fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
    	   fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--           fnd_message.set_token('PARTNER_ID', l_partner_id);
                fnd_message.set_token('ERROR', l_msg_data);
                Write_log (1, substrb(fnd_message.get, 1, 255));
                ROLLBACK TO Process_Partner_Channel_Team;
                fnd_msg_pub.Delete_Msg;

             WHEN OTHERS THEN

	        IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
	        END IF;

                FND_MSG_PUB.count_and_get (
                    p_encoded => FND_API.g_false
                   ,p_count   => l_msg_count
                   ,p_data    => l_msg_data
                );

                l_partner_err_cnt := l_partner_err_cnt +1;
                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                l_msg_data := substr(apps.fnd_message.get,1,254);


                -- Debug statement for each partner_id
               fnd_message.set_name('PV', 'PV_TAP_CTEAM_ERR');
        	   fnd_message.set_token('PARTNER_NAME', rpad(l_partner_name,40));
        	   fnd_message.set_token('PARTNER_ID', rpad(l_partner_id,15));
--           fnd_message.set_token('PARTNER_ID', l_partner_id);
                fnd_message.set_token('ERROR', l_msg_data);
                Write_log (1, substrb(fnd_message.get, 1, 255));
                ROLLBACK TO Process_Partner_Channel_Team;
                fnd_msg_pub.Delete_Msg;

	     END ;
       END LOOP; --FOR i IN 1..l_partner_list_tbl.last
    END IF ;  -- l_partner_list_tbl.count > 0

      -- Footer Message for Processing End.
     fnd_message.set_name('PV', 'PV_TAP_CTEAM_FOOTER');
     fnd_message.set_token('TOT_PRTNR_CNT', to_char(l_partner_list_tbl.count) );
     fnd_message.set_token('SUC_PRTNR_CNT', to_char(l_partner_list_tbl.count-l_partner_err_cnt) );
     fnd_message.set_token('ERR_PRTNR_CNT', to_char(l_partner_err_cnt) );
     fnd_message.set_token('P_DATE_TIME', TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
     Write_log (1, substrb(fnd_message.get, 1, 1000));

     IF (l_partner_err_cnt > 0) THEN
          RETCODE := FND_API.G_RET_STS_ERROR;
          l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', SQLERRM);
     END IF;


    COMMIT;

    EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
	         IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
             END IF;
             ROLLBACK TO Process_Sub_Territories_Pvt;
             RETCODE := FND_API.G_RET_STS_ERROR;
             l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
             ERRBUF := l_err_mesg ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, l_err_mesg);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	         IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
             END IF;
             ROLLBACK TO Process_Sub_Territories_Pvt;
             RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
             l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
             ERRBUF := l_err_mesg ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, l_err_mesg);

         WHEN OTHERS THEN
	         IF l_batch_partners_csr%ISOPEN THEN
                   CLOSE l_batch_partners_csr;
             END IF;

             ROLLBACK  TO Process_Sub_Territories_Pvt;
             RETCODE := '2';
             l_err_mesg := 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100);
             ERRBUF := l_err_mesg ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, l_err_mesg);

END Process_Sub_Territories;

END PV_TERR_ASSIGN_PUB;

/
