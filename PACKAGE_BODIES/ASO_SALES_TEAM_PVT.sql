--------------------------------------------------------
--  DDL for Package Body ASO_SALES_TEAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SALES_TEAM_PVT" as
/* $Header: asovastb.pls 120.11.12010000.6 2011/09/19 09:15:44 vidsrini ship $ */
-- Start of Comments
-- Package name    : ASO_SALES_TEAM_PVT
-- Purpose         :
-- History         :
-- NOTE       :
-- End of Comments


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_SALES_TEAM_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'asovstmb.pls';
G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;
G_LOGIN_ID    NUMBER                := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE INSERT_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    P_Qte_Header_Rec	IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN

     aso_debug_pub.add('Begin INSERT_ACCESSES_ACCOUNTS',1,'Y');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN

      			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP


		--added inline view in the select clause of Insert statement to fetch the salesforce role code for Employee resource --fix for bug 5869095

	IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' AND p_WinningTerrMember_tbl.group_id(l_index) IS NOT NULL THEN
          aso_debug_pub.add('Begin INSERT_ACCESSES_ACCOUNTS'|| p_WinningTerrMember_tbl.resource_type(l_index),1,'Y');

						Insert into ASO_QUOTE_ACCESSES
						(ACCESS_ID,
						QUOTE_NUMBER,
						RESOURCE_ID,
						RESOURCE_GRP_ID,
						CREATED_BY,
						CREATION_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						LAST_UPDATE_DATE,
						ROLE_ID,
						OBJECT_VERSION_NUMBER )
						select
						ASO_QUOTE_ACCESSES_S.nextval,
            P_Qte_Header_Rec.quote_number,
            p_WinningTerrMember_tbl.resource_id(l_index),
            p_WinningTerrMember_tbl.group_ID(l_index),
            FND_GLOBAL.USER_ID ,
            SYSDATE  ,
						FND_GLOBAL.USER_ID  ,
					FND_GLOBAL.USER_ID  ,
             SYSDATE,
             null,
             null
						from dual where not exists (select  1 from
            ASO_QUOTE_ACCESSES where resource_id =  p_WinningTerrMember_tbl.resource_id(l_index)
            and  quote_number = P_Qte_Header_Rec.quote_number);


	END IF;
  END LOOP;
 END IF;

EXCEPTION
WHEN OTHERS THEN

aso_debug_pub.add('Proc INSERT_ACCESSES_ACCOUNTS exception part',1,'Y');

      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_ACCESSES_ACCOUNTS;

/************************** Start Explode Teams  ******************/
PROCEDURE EXPLODE_TEAMS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

 /*-------------------------------------------------------------------------+
 |                             LOGIC
 |
 | A RESOURCE team can be comprised OF resources who belong TO one OR more
 | GROUPS OF resources.
 | So get a LIST OF team members (OF TYPE employee OR partner OR parter contact
 | AND play a ROLE OF salesrep ) AND get atleast one GROUP id that they belong TO
 | WHERE they play a similar ROLE.
 | UNION THE above WITH a LIST OF ALL members OF ALL GROUPS which BY themselves
 | are a RESOURCE within a team.
 | INSERT these members INTO winners IF they are NOT already IN winners.
 +-------------------------------------------------------------------------*/

l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;

l_resource_id    num_list;
l_group_id   num_list;
l_person_id   num_list;


BEGIN

aso_debug_pub.add('Explode Team',1,'Y');

   x_return_status := FND_API.G_RET_STS_SUCCESS;
--   l_resource_type := 'RS_TEAM';
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
     IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN

        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
				IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_TEAM' THEN
aso_debug_pub.add('Explode Team ' ||p_WinningTerrMember_tbl.resource_type(l_index),1,'Y');
						SELECT resource_id,  group_id , person_id
						BULK COLLECT INTO l_resource_id, l_group_id,l_person_id
						FROM
						(
							 SELECT TM.team_resource_id resource_id,
								TM.person_id person_id2,
								MIN(G.group_id)group_id,
								MIN(T.team_id) team_id,
								TRES.CATEGORY resource_category,
								MIN(TRES.source_id) person_id
							 FROM  jtf_rs_team_members TM, jtf_rs_teams_b T,
								   jtf_rs_team_usages TU, jtf_rs_role_relations TRR,
								   jtf_rs_roles_b TR, jtf_rs_resource_extns TRES,
								   (
								SELECT m.group_id group_id, m.resource_id resource_id
								FROM   jtf_rs_group_members m,
									   jtf_rs_groups_b g,
									   jtf_rs_group_usages u,
									   jtf_rs_role_relations rr,
									   jtf_rs_roles_b r,
									   jtf_rs_resource_extns res
								WHERE  m.group_id = g.group_id
								AND    SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
								AND    NVL(g.end_date_active,SYSDATE)
								AND    u.group_id = g.group_id
								AND    u.usage IN ('SALES','PRM')
								AND    m.group_member_id = rr.role_resource_id
								AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
								AND    rr.delete_flag <> 'Y'
								AND    SYSDATE BETWEEN rr.start_date_active
								AND    NVL(rr.end_date_active,SYSDATE)
								AND    rr.role_id = r.role_id
								AND    r.role_type_code
									   IN ('SALES', 'TELESALES', 'FIELDSALES','PRM')
								AND    r.active_flag = 'Y'
								AND    res.resource_id = m.resource_id
								AND    res.CATEGORY IN ('EMPLOYEE')--,'PARTY','PARTNER')
								 )  G
							WHERE tm.team_id = t.team_id
							AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
							AND   NVL(t.end_date_active,SYSDATE)
							AND   tu.team_id = t.team_id
							AND   tu.usage IN ('SALES','PRM')
							AND   tm.team_member_id = trr.role_resource_id
							AND   tm.delete_flag <> 'Y'
							AND   tm.resource_type = 'INDIVIDUAL'
							AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
							AND   trr.delete_flag <> 'Y'
							AND   SYSDATE BETWEEN trr.start_date_active
									AND   NVL(trr.end_date_active,SYSDATE)
							AND   trr.role_id = tr.role_id
							AND   tr.role_type_code IN
								  ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							AND   tr.active_flag = 'Y'
							AND   tres.resource_id = tm.team_resource_id
							AND   tres.category IN ('EMPLOYEE')--,'PARTY','PARTNER')
							AND   tm.team_resource_id = g.resource_id
							GROUP BY tm.team_resource_id,
								 tm.person_id,
								 tres.CATEGORY,
								 tres.source_id
						 UNION ALL
							 SELECT    MIN(m.resource_id) resource_id,
									   MIN(m.person_id) person_id2, MIN(m.group_id) group_id,
									   MIN(jtm.team_id) team_id, res.CATEGORY resource_category,
									   MIN(res.source_id) person_id
							FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
								  jtf_rs_group_usages u, jtf_rs_role_relations rr,
								  jtf_rs_roles_b r, jtf_rs_resource_extns res,
								  (
								   SELECT tm.team_resource_id group_id,
								   t.team_id team_id
								   FROM   jtf_rs_team_members tm, jtf_rs_teams_b t,
									  jtf_rs_team_usages tu,jtf_rs_role_relations trr,
									  jtf_rs_roles_b tr, jtf_rs_resource_extns tres
								   WHERE  tm.team_id = t.team_id
								   AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
								   AND   NVL(t.end_date_active,SYSDATE)
								   AND   tu.team_id = t.team_id
								   AND   tu.usage IN ('SALES','PRM')
								   AND   tm.team_member_id = trr.role_resource_id
								   AND   tm.delete_flag <> 'Y'
								   AND   tm.resource_type = 'GROUP'
								   AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
								   AND   trr.delete_flag <> 'Y'
								   AND   SYSDATE BETWEEN trr.start_date_active
								   AND   NVL(trr.end_date_active,SYSDATE)
								   AND   trr.role_id = tr.role_id
								   AND   tr.role_type_code IN
									 ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
								   AND   tr.active_flag = 'Y'
								   AND   tres.resource_id = tm.team_resource_id
								   AND   tres.category IN ('EMPLOYEE')--,'PARTY','PARTNER')
								   ) jtm
							WHERE m.group_id = g.group_id
							AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
							AND   NVL(g.end_date_active,SYSDATE)
							AND   u.group_id = g.group_id
							AND   u.usage IN ('SALES','PRM')
							AND   m.group_member_id = rr.role_resource_id
							AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
							AND   rr.delete_flag <> 'Y'
							AND   SYSDATE BETWEEN rr.start_date_active
									AND   NVL(rr.end_date_active,SYSDATE)
							AND   rr.role_id = r.role_id
							AND   r.role_type_code IN
								  ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							AND   r.active_flag = 'Y'
							AND   res.resource_id = m.resource_id
							AND   res.category IN ('EMPLOYEE')--,'PARTY','PARTNER')
							AND   jtm.group_id = g.group_id
							GROUP BY m.resource_id, m.person_id, jtm.team_id, res.CATEGORY) J

						WHERE j.team_id = p_WinningTerrMember_tbl.resource_id(l_index);
            aso_debug_pub.add('Explode Team ' || p_WinningTerrMember_tbl.resource_id(l_index),1,'Y');


						IF l_resource_id.COUNT > 0 THEN
							FOR i IN l_resource_id.FIRST .. l_resource_id.LAST LOOP
							/* No need to Check to see if it is already part of
							   p_WinningTerrMember_tbl because this will be slow,
							   So we insert into p_WinningTerrMember_tbl directly*/
							   IF l_group_id(i) IS NOT NULL THEN --- Resources without groups should NOT be added to the sales team
               								p_WinningTerrMember_tbl.resource_id.EXTEND;
								p_WinningTerrMember_tbl.group_id.EXTEND;
								p_WinningTerrMember_tbl.person_id.EXTEND;
								p_WinningTerrMember_tbl.resource_type.EXTEND;
								p_WinningTerrMember_tbl.full_access_flag.EXTEND;
								p_WinningTerrMember_tbl.terr_id.EXTEND;
								p_WinningTerrMember_tbl.trans_object_id.EXTEND;
								p_WinningTerrMember_tbl.org_id.EXTEND;
                                                                p_WinningTerrMember_tbl.ROLE.EXTEND;
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_id(i);
               								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_group_id(i);

								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.person_id.COUNT ) := l_person_id(i);

								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT) := 'RS_EMPLOYEE';

								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.full_access_flag(l_index);

								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);

								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := 1;

								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.org_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);

							   END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;
 /*   FOR i IN l_resource_id.FIRST .. l_resource_id.LAST LOOP
     aso_debug_pub.add('Explode Team praks1212 ' || p_WinningTerrMember_tbl.resource_id(i),1,'Y');
     end loop;
    */

   END IF;  /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN others THEN
     -- AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_TEAMS;
/************************** End Explode Teams  ******************/


PROCEDURE Assign_Sales_Team(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Tbl               IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			                        := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Operation                  IN    VARCHAR2     := FND_API.G_MISS_CHAR,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

   -- Change START
   -- Release 12 TAP Changes
   -- Changes Done by : Girish
   -- Comments : Call from release 12 has changed and also the record type

   --lx_gen_return_Rec            JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
   lx_gen_return_Rec              JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;


   TYPE Keep_Res_Id_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   Keep_Res_Id             Keep_Res_Id_Type;

   -- Change START
   -- Release 12 MOAC Changes : Bug 4500739
   -- Changes Done by : Girish
   -- Comments : Using HR EIT in place of org striped profile

   --l_default_salesrep_prof VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_PERSON_ID');
   l_default_salesrep_prof VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALESREP);

   --l_default_role_prof     VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_SALES_ROLE');
   l_default_role_prof     VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALES_ROLE);

   -- Change End


   l_ots_role_prof         VARCHAR2(50);
  -- := FND_PROFILE.Value('AST_DEFAULT_ROLE_AND_GROUP');

   l_ots_grp_prof          VARCHAR2(50);

  /* := NVL(FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE',
							        G_USER_ID, NULL, 522),
							        FND_PROFILE.Value_Specific(
                                           'AST_DEFAULT_ROLE_AND_GROUP',
							        G_USER_ID, NULL, 521));
  */

   l_role_prof             VARCHAR2(50);

   l_sales_team_prof       VARCHAR2(30) := NVL(FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN'),'NONE');

   i                       NUMBER;
   j                       NUMBER;
   l_api_name              CONSTANT VARCHAR2 ( 30 ) := 'ASSIGN_SALES_TEAM';
   l_api_version_number    CONSTANT NUMBER := 1.0;
   l_exists_flag           VARCHAR2(1);
   l_last_upd_date         DATE;
   l_Qte_Header_Rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
   l_reassign_flag         VARCHAR2(1) := 'N';
   l_creator_res           NUMBER := NULL;
   l_creator_found         VARCHAR2(1);
   l_creator_role          NUMBER;
   l_creator_grp           NUMBER;
   l_valid                 VARCHAR2(1);
   l_sequence              NUMBER := null;
   lx_return_status        VARCHAR2(1);
   l_dynamic               VARCHAR2(1000);
   l_primary_salesagent    NUMBER;
   l_primary_role          NUMBER;
   l_primary_res_grp       NUMBER;

   Leave_Proc              EXCEPTION;

   l_obsolete_status       varchar2(1);


   CURSOR C_Get_Header_Info (l_qte_hdr NUMBER) IS
    SELECT Quote_Header_Id, Quote_Number, Party_Id, Sold_To_Party_Site_Id, Cust_Party_Id,
    cust_account_id  -- Code change done for Bug 11076978
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_Header_Id = l_qte_hdr;

   CURSOR C_Get_Out_Hdr_Info (l_qte_hdr NUMBER) IS
    SELECT Quote_Header_Id, Last_Update_Date
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_header_Id = l_qte_hdr;

   CURSOR C_Quote_Exists (l_qte_hdr NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_Header_Id = l_qte_hdr;

   CURSOR C_Get_Update_Date(qte_hdr_id NUMBER) IS
    SELECT Last_Update_Date
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_Header_Id = qte_hdr_id;

   CURSOR C_Team_Exists (l_qte_number NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_ACCESSES
    WHERE Quote_Number = l_qte_number;

   CURSOR C_Get_All_Resource (l_qte_number NUMBER) IS
    SELECT Resource_Id
    FROM ASO_QUOTE_ACCESSES
    WHERE Quote_Number = l_qte_number;

   CURSOR C_Get_Creator_Res (l_user_id NUMBER) IS
    SELECT resource_id
    FROM JTF_RS_RESOURCE_EXTNS
    WHERE user_id = l_user_id
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

   CURSOR C_Check_Creator_Res (l_qte_num NUMBER, l_res NUMBER) IS
    SELECT 'Y', Resource_Grp_Id
    FROM ASO_QUOTE_ACCESSES
    WHERE Quote_Number = l_qte_num
    AND Resource_Id = l_res;

    CURSOR C_Valid_SalesRep (l_res_id NUMBER) IS
    SELECT 'Y'
    /* FROM JTF_RS_SRP_VL */ --Commented Code Yogeshwar (MOAC)
    FROM JTF_RS_SALESREPS_MO_V -- New Code Yogeshwar (MOAC)
    WHERE resource_id = l_res_id
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);
    --Commented Code start Yogeshwar (MOAC)
    /*
    AND NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)
   CURSOR C_Get_Role_From_Code (l_code VARCHAR2) IS
    SELECT Role_Id
    FROM JTF_RS_ROLES_B
    WHERE Role_Code = l_code
    AND Role_Type_Code IN ('TELESALES', 'SALES', 'FIELDSALES', 'PRM');

   CURSOR C_Get_Resource_Role (l_res NUMBER) IS
    SELECT Role_Id
    FROM JTF_RS_ROLE_RELATIONS
    WHERE Role_Resource_Id = l_res
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

   CURSOR C_Get_Res_From_Srep (l_Srep VARCHAR2) IS
    SELECT Resource_Id
    /* FROM JTF_RS_SRP_VL */ --Commented Code Yogeshwar (MOAC)
    FROM JTF_RS_SALESREPS_MO_V --New Code Yogeshwar (MOAC)
    WHERE Salesrep_Number = l_Srep
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;
    --Commented Code Start Yogeshwar (MOAC)
    /*
    AND NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)
BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT ASSIGN_SALES_TEAM_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                        	           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Begin Sales_Team_Assign',1,'Y');
END IF;
-- BASIC VALIDATIONS

-- Check if profiles are set
   IF (NVL(FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'),'N') = 'N') OR (l_sales_team_prof = 'NONE') THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('API_Enable_Sec is N or sales_team_prof is None: ',1,'Y');
END IF;

       RAISE Leave_Proc;

   END IF;

-- Check if quote header id exists
    OPEN C_Quote_Exists(P_Qte_Header_Rec.Quote_Header_Id);
    FETCH C_Quote_Exists INTO l_Exists_Flag;
    IF (C_Quote_Exists%NOTFOUND) OR l_Exists_Flag <> 'Y' THEN
        CLOSE C_Quote_Exists;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'ORIGINAL_QUOTE_ID', FALSE);
            FND_MESSAGE.Set_Token('VALUE', TO_CHAR(p_qte_header_rec.quote_header_id), FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE C_Quote_Exists;
-- End: Check if quote header id exists

-- Check Whether record has been changed
     OPEN C_Get_Update_Date(P_Qte_Header_Rec.Quote_Header_Id);
     FETCH C_Get_Update_Date INTO l_last_upd_date;

     IF (C_Get_Update_Date%NOTFOUND) OR
        (l_last_upd_date IS NULL OR l_last_upd_date = FND_API.G_MISS_DATE) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
             FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
             FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Get_Update_Date;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     CLOSE C_Get_Update_Date;

     IF (p_qte_header_rec.last_update_date IS NOT NULL AND
         p_qte_header_rec.last_update_date <> FND_API.G_MISS_DATE) AND
        (l_last_upd_date <> p_qte_header_rec.last_update_date) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
-- End: Check Whether record has been changed

-- Check if a concurrent lock exists
    ASO_CONC_REQ_INT.Lock_Exists(
      p_quote_header_id => p_qte_header_rec.quote_header_id,
      x_status          => lx_return_status);

    IF (lx_return_status = FND_API.G_TRUE) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
-- End: Check if a concurrent lock exists
-- END BASIC VALIDATIONS

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Operation_Code: '||P_Operation,1,'Y');
aso_debug_pub.add('Before Truncating Temp Table',1,'Y');
END IF;

   DELETE FROM ASO_STEAM_TEMP;

    IF P_Operation <> 'CREATE' THEN

        OPEN C_Get_Header_Info (p_qte_header_rec.Quote_header_id);
        FETCH C_Get_Header_Info INTO l_qte_header_rec.Quote_header_id,
                                     l_qte_header_rec.Quote_Number, l_qte_header_rec.party_id,
                                     l_qte_header_rec.sold_to_party_site_id, l_qte_header_rec.cust_party_id,
                                     l_qte_header_rec.cust_account_id;  -- Code change done for Bug 11076978
        CLOSE C_Get_Header_Info;

	/*** Start : Code change done for Bug 11076978 ***/
	If (NVL(FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'),'N') = 'Y') Then
	    If (l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL') Then
	        If (p_qte_header_rec.cust_account_id IS NOT NULL AND
	            p_qte_header_rec.cust_account_id <> FND_API.G_MISS_NUM) Then
                    If (l_qte_header_rec.cust_account_id <> P_Qte_Header_Rec.cust_account_id) Then
                        l_qte_header_rec := P_Qte_Header_Rec;
                    End If;
               End If;
            End If;
        End If;
        /*** End : Code change done for Bug 11076978 ***/

        OPEN C_Team_Exists(l_Qte_Header_Rec.Quote_Number);
        FETCH C_Team_Exists INTO l_Reassign_Flag;
        CLOSE C_Team_Exists;

    ELSE

        l_qte_header_rec := P_Qte_Header_Rec;

    END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Quote_Number: '||l_qte_header_rec.Quote_Number,1,'Y');
aso_debug_pub.add('Reassign_Flag: '||l_Reassign_Flag,1,'Y');
END IF;

    ASO_SALES_TEAM_PVT.Get_Sales_Team (
        P_Init_Msg_List        =>  FND_API.G_FALSE,
        P_Qte_Header_Rec       =>  l_Qte_Header_Rec,
        X_Winners_Rec          =>  lx_gen_return_rec,
        x_return_status        =>  x_return_status,
        x_msg_count            =>  x_msg_count,
        x_msg_data             =>  x_msg_data
     );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After ASO_SALES_TEAM_PVT.get_sales_team: '||x_return_status,1,'Y');
END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF nvl(lx_gen_return_Rec.resource_id.count,0) = 0 THEN
        IF P_Operation <> 'CREATE' AND P_Operation <> 'UPDATE' AND P_Operation <> 'SUBMIT' THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NO_SALES_TEAM');
              FND_MSG_PUB.ADD;
          END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After ASO_SALES_TEAM_PVT Added MSG: ',1,'Y');
END IF;

          X_Qte_Header_Rec := P_Qte_Header_Rec;
          RAISE Leave_Proc;
        ELSE
          IF P_Operation = 'UPDATE' THEN -- istore case

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Update_Primary_SalesAgent(oprn=update): ',1,'Y');
END IF;
             ASO_SALES_TEAM_PVT.Update_Primary_SalesInfo (
               P_Init_Msg_List        =>  FND_API.G_FALSE,
               P_Qte_Header_Rec       =>  l_Qte_Header_Rec,
               P_Primary_SalesAgent   =>  NULL,
               P_Primary_SalesGrp     =>  NULL,
               P_reassign_flag        =>  l_reassign_flag,
               X_Qte_Header_Rec       =>  x_Qte_Header_Rec,
               x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data
              );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After Update_Primary_SalesInfo(oprn=update): '||x_return_status,1,'Y');
END IF;

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            RAISE Leave_Proc;

          ELSIF P_Operation = 'CREATE' THEN -- create case

            OPEN C_Get_Creator_Res(G_USER_ID);
            FETCH C_Get_Creator_Res INTO l_creator_res;
            CLOSE C_Get_Creator_Res;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After ASO_SALES_TEAM_PVT No res returned:P_Operation: '||P_Operation,1,'Y');
aso_debug_pub.add('After ASO_SALES_TEAM_PVT No res returned:l_creator_res: '||l_creator_res,1,'Y');
END IF;
            IF l_creator_res IS NOT NULL THEN

                -- Role Defaulting Logic

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Assign_Sales_Team: Before calling Get_Profile_Obsolete_Status', 1, 'N');
                END IF;

                l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                                 p_application_id => 521);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
                END IF;

                if l_obsolete_status = 'T' then

                    l_ots_role_prof := fnd_profile.value('AST_DEFAULT_ROLE');

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_role_prof: ' || l_ots_role_prof, 1, 'N');
                        aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_creator_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                    END IF;

                    if l_creator_grp is null then

                        l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                        END IF;

                        l_creator_grp := to_number(l_ots_grp_prof);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                        END IF;

                    end if;

                else

                    l_ots_role_prof := fnd_profile.value('AST_DEFAULT_ROLE_AND_GROUP');

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_role_prof: ' || l_ots_role_prof, 1, 'N');
                        aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_creator_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                    END IF;

                    if l_creator_grp is null then

                        l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                        END IF;

                        l_creator_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                        END IF;

                    end if;

                end if;

                l_role_prof := SUBSTR(l_ots_role_prof, 1, INSTR(l_ots_role_prof, ':')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add(' nores:create:l_role_prof: ' || l_role_prof, 1, 'N');
                END IF;

                OPEN C_Get_Role_From_Code (l_role_prof);
                FETCH C_Get_Role_From_Code INTO l_creator_role;
                CLOSE C_Get_Role_From_Code;

                IF l_creator_role IS NULL THEN
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('nores:create:Creator Role From Res: '||l_creator_role,1,'N');
                    END IF;

                    OPEN C_Get_Resource_Role (l_creator_res);
                    FETCH C_Get_Resource_Role INTO l_creator_role;
                    CLOSE C_Get_Resource_Role;

                END IF;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('nores:create:Role Profile:  '||l_ots_role_prof,1,'Y');
                   aso_debug_pub.add('nores:create:Role Profile:  '||l_role_prof,1,'Y');
                   aso_debug_pub.add('nores:create:Creator Role:  '||l_creator_role,1,'Y');
                   aso_debug_pub.add('nores:create:Creator Group: '||l_creator_grp,1,'Y');
                END IF;

			 l_sequence := NULL;

                ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => l_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_creator_res,
                p_RESOURCE_GRP_ID        => l_creator_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => 'N',
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => 'N',
                p_ROLE_ID                => l_creator_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
			 p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
                );

                OPEN C_Valid_SalesRep (l_creator_res);
                FETCH C_Valid_SalesRep INTO l_valid;
                CLOSE C_Valid_SalesRep;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('nores:create:Creator Valid SalesRep : '||l_valid,1,'Y');
END IF;

                 IF l_valid = 'Y' THEN
                   l_primary_salesagent := l_creator_res;
                   l_primary_res_grp := l_creator_grp;
                 END IF;

            END IF; -- creator not null

            IF l_primary_salesagent IS NULL THEN

              IF l_default_salesrep_prof IS NOT NULL THEN
                  OPEN C_Get_Res_From_Srep (l_default_salesrep_prof);
                  FETCH C_Get_Res_From_Srep INTO l_primary_salesagent;
                  CLOSE C_Get_Res_From_Srep;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('nores:create:Assign_Sales_Team: Default SalesRep: '||l_primary_salesagent,1,'N');
aso_debug_pub.add('nores:create:Assign_Sales_Team: Default SalesGrp: '||l_primary_res_grp,1,'N');
END IF;
              ELSE
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		      -- Created new message to display the error message more appropriately - Girish Bug 4654938
                      -- FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
                      -- FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_PERSON_ID', FALSE);
		      FND_MESSAGE.Set_Name('ASO', 'ASO_NO_DEFAULT_VALUE');
                      FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_SALESREP', TRUE);

                      FND_MSG_PUB.Add;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF; -- salesrep_prof

              l_primary_role := l_default_role_prof;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Before calling Get_Profile_Obsolete_Status', 1, 'N');
              END IF;

              l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                               p_application_id => 521);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
              END IF;

              if l_obsolete_status = 'T' then

                  l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                  END IF;

                  l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                  END IF;

                  if l_primary_res_grp is null then

                      l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                      END IF;

                      l_primary_res_grp := to_number(l_ots_grp_prof);

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                      END IF;

                  end if;

              else

                  l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                  END IF;

                  l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                  END IF;

                  if l_primary_res_grp is null then

                      l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                      END IF;

                      l_primary_res_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                      END IF;

                   end if;

              end if;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('nores:create:Assign_Sales_Team: Default Role: '||l_primary_role,1,'N');
                 aso_debug_pub.add('nores:create:Assign_Sales_Team: Default Grp: '||l_primary_res_grp,1,'N');
              END IF;

            END IF; -- salesagent is NULL

            IF l_primary_role IS NULL THEN
                OPEN C_Get_Resource_Role (l_primary_salesagent);
                FETCH C_Get_Resource_Role INTO l_primary_role;
                CLOSE C_Get_Resource_Role;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('nores:create:Assign_Sales_Team: Role From Res: '||l_primary_role,1,'N');
END IF;
            END IF;

            IF l_valid IS NULL OR l_valid <> 'Y' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('nores:create:Assign_Sales_Team: Before primary salesagent insert:l_valid '||l_valid,1,'N');
END IF;
              l_sequence := NULL;

              ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => P_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_primary_salesagent,
                p_RESOURCE_GRP_ID        => l_primary_res_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => FND_API.G_MISS_CHAR,
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => FND_API.G_MISS_CHAR,
                p_ROLE_ID                => l_primary_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
			 p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
              );

            END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('nores:create:Assign_Sales_Team: Before primary salesagent insert in qte_hdr ',1,'N');
END IF;

             UPDATE ASO_QUOTE_HEADERS_ALL
             SET Resource_Id = l_primary_salesagent,
                 Resource_Grp_Id = l_primary_res_grp,
                 last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
                 last_update_login = fnd_global.conc_login_id,
                 object_version_number = object_version_number+1
             WHERE quote_number = P_Qte_Header_Rec.quote_number
             AND max_version_flag = 'Y'
             RETURNING quote_header_id, last_update_date, resource_id, resource_grp_id, object_version_number
             INTO l_qte_header_rec.Quote_Header_Id, l_qte_header_rec.Last_Update_Date,
                  l_qte_header_rec.resource_id, l_qte_header_rec.resource_grp_id, l_qte_header_rec.object_version_number;

          END IF;  -- operation = CREATE

          X_Qte_Header_Rec := l_Qte_Header_Rec;
          RAISE Leave_Proc;

        END IF;  -- p_operation ELSE
    END IF; -- res count = 0

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Temp_Insert'||NVL(lx_gen_return_Rec.resource_id.COUNT,0),1,'Y');
END IF;

        FORALL i IN lx_gen_return_Rec.resource_id.FIRST..lx_gen_return_Rec.resource_id.LAST
          INSERT INTO ASO_STEAM_TEMP (  Access_Id,
                                        Quote_Number,
                                        Resource_Id,
                                        Resource_Grp_Id,
                                        Created_By,
                                        Creation_Date,
                                        Last_Updated_By,
                                        Last_Update_Login,
                                        Last_Update_Date,
                                        Keep_Flag,
                                        Full_Access_Flag,
                                        Territory_Id,
                                        Territory_Source_Flag,
                                        Role_Id )
                                SELECT  null,
                                        l_Qte_Header_Rec.Quote_Number,
                                        lx_gen_return_Rec.resource_id(i),
                                        lx_gen_return_Rec.group_id(i),
                                        G_USER_ID,
                                        SYSDATE,
                                        G_USER_ID,
                                        G_LOGIN_ID,
                                        SYSDATE,
                                        NULL,
                                        lx_gen_return_Rec.full_access_flag(i),
                                        lx_gen_return_Rec.terr_id(i),
                                        'Y',
                                        DECODE(lx_gen_return_Rec.role(i),NULL,NULL,A.Role_Id)
                                FROM    JTF_RS_ROLES_B A
                                WHERE   A.Role_Code = NVL(lx_gen_return_Rec.role(i),A.Role_Code)
                                AND     rownum = 1;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After Temp Insert',1,'Y');
END IF;

   IF l_Reassign_Flag = 'Y' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Delete Not Kept Existing Res ',1,'Y');
END IF;
       DELETE FROM ASO_QUOTE_ACCESSES C
       WHERE C.resource_id NOT IN
       (SELECT A.resource_id
        FROM ASO_QUOTE_ACCESSES A , ASO_STEAM_TEMP B
        WHERE ((A.resource_id = B.resource_id
        AND NVL(A.resource_grp_id, -999) = NVL(B.resource_grp_id, -999)
        AND NVL(A.role_id, -999) = NVL(B.role_id, -999)
        AND NVL(A.keep_flag,'N') = 'N')
	   OR NVL(A.keep_flag,'N') = 'Y')
        AND A.Quote_Number = l_qte_header_rec.quote_number)
       AND C.Quote_Number = l_qte_header_rec.quote_number;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Delete Kept Res ',1,'Y');
END IF;
       OPEN C_Get_All_Resource(l_Qte_Header_Rec.Quote_Number);
       FETCH C_Get_All_Resource BULK COLLECT INTO Keep_Res_Id;
       CLOSE C_Get_All_Resource;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Keep_Res_Id.COUNT: '||NVL(Keep_Res_Id.COUNT,0),1,'Y');
END IF;
        IF NVL(Keep_Res_Id.COUNT,0) > 0 THEN
            FORALL i IN Keep_Res_Id.FIRST..Keep_Res_Id.LAST
              DELETE FROM ASO_STEAM_TEMP
              WHERE Resource_Id = Keep_Res_Id(i);
        END IF;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Delete Invalid Roles ',1,'Y');
END IF;
    DELETE FROM ASO_STEAM_TEMP
    WHERE Role_Id IS NOT NULL
    AND Role_Id NOT IN ( SELECT Role_Id
			   FROM JTF_RS_ROLES_B
			   WHERE Role_Type_Code IN ('TELESALES', 'SALES','FIELDSALES','PRM'));

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Delete Duplicate Res/Roles/Grp combos ',1,'Y');
END IF;
    l_dynamic := 'DELETE FROM ASO_STEAM_TEMP '||
                 'WHERE rowid NOT IN ( SELECT rowid '||
                                   'FROM ( SELECT rowid, dense_rank() OVER '||
                                           '( PARTITION BY Resource_Id '||
                                             'ORDER BY Role_Id DESC nulls last, Resource_Grp_Id DESC nulls last) AS Rank_Val '||
                                          'FROM ASO_STEAM_TEMP '||
                                          'ORDER BY Role_Id DESC nulls last, Resource_Grp_Id DESC nulls last ) '||
                                   'WHERE Rank_Val = 1 )';

    EXECUTE IMMEDIATE l_dynamic;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Delete Duplicate Resources ',1,'Y');
END IF;
    DELETE FROM ASO_STEAM_TEMP
    WHERE rowid  IN (
    SELECT rowid FROM ASO_STEAM_TEMP
    GROUP BY rowid, Resource_Id
    MINUS
    SELECT min(rowid) FROM ASO_STEAM_TEMP
    GROUP BY Resource_Id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into i from aso_steam_temp;
aso_debug_pub.add('count: '||i,1,'Y');

aso_debug_pub.add('Before Insert into Quote_Accesses ',1,'Y');
END IF;
    INSERT INTO ASO_QUOTE_ACCESSES ( ACCESS_ID,
                                     QUOTE_NUMBER,
                                     RESOURCE_ID,
                                     RESOURCE_GRP_ID,
                                     CREATED_BY,
                                     CREATION_DATE,
                                     LAST_UPDATED_BY,
                                     LAST_UPDATE_LOGIN,
                                     LAST_UPDATE_DATE,
                                     UPDATE_ACCESS_FLAG,
                                     TERRITORY_ID,
                                     TERRITORY_SOURCE_FLAG,
                                     ROLE_ID )
                              SELECT ASO_QUOTE_ACCESSES_S.nextval,
                                     Quote_Number,
                                     Resource_Id,
                                     Resource_Grp_Id,
                                     Created_By,
                                     Creation_Date,
                                     Last_Updated_By,
                                     Last_Update_Login,
                                     Last_Update_Date,
                                     Full_Access_Flag,
                                     Territory_Id,
                                     Territory_Source_Flag,
                                     Role_Id
                                FROM ASO_STEAM_TEMP
                               WHERE Quote_Number = l_Qte_Header_Rec.Quote_Number
		              and not exists (select  1 from
            ASO_QUOTE_ACCESSES where resource_id =  ASO_STEAM_TEMP.resource_id
            and  quote_number = l_Qte_Header_Rec.Quote_Number);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After Insert into Quote_Accesses ',1,'Y');
END IF;

     IF P_Operation = 'CREATE' THEN

          OPEN C_Get_Creator_Res(G_USER_ID);
          FETCH C_Get_Creator_Res INTO l_creator_res;
          CLOSE C_Get_Creator_Res;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Creator Res:l_creator_res: '||l_creator_res,1,'Y');
END IF;

          IF l_creator_res IS NOT NULL THEN

            OPEN C_Check_Creator_Res(l_Qte_Header_Rec.Quote_Number, l_creator_res);
            FETCH C_Check_Creator_Res INTO l_creator_found, l_creator_grp;
            CLOSE C_Check_Creator_Res;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Creator Res:G_USER_ID: '||G_USER_ID,1,'Y');
aso_debug_pub.add('Fetch Creator Res: '||l_creator_res,1,'Y');
aso_debug_pub.add('Fetch Creator Grp: '||l_creator_grp,1,'Y');
aso_debug_pub.add('Creator Found: '||l_creator_found,1,'Y');
END IF;

            IF l_creator_found IS NULL OR l_creator_found <> 'Y' THEN
                -- Role Defaulting Logic

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Assign_Sales_Team: Before calling Get_Profile_Obsolete_Status', 1, 'N');
                END IF;

                l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                                 p_application_id => 521);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
                END IF;

                if l_obsolete_status = 'T' then

                    l_ots_role_prof := fnd_profile.value('AST_DEFAULT_ROLE');

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_role_prof: ' || l_ots_role_prof, 1, 'N');
                        aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_creator_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                    END IF;

                    if l_creator_grp is null then

                        l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                        END IF;

                        l_creator_grp := to_number(l_ots_grp_prof);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                        END IF;

                    end if;

                else

                    l_ots_role_prof := fnd_profile.value('AST_DEFAULT_ROLE_AND_GROUP');

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_role_prof: ' || l_ots_role_prof, 1, 'N');
                        aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_creator_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                    END IF;

                    if l_creator_grp is null then

                        l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                        END IF;

                        l_creator_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_creator_grp: ' || l_creator_grp, 1, 'N');
                        END IF;

                    end if;

                end if;

                l_role_prof := SUBSTR(l_ots_role_prof, 1, INSTR(l_ots_role_prof, ':')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_role_prof: ' || l_role_prof, 1, 'N');
                END IF;

                OPEN C_Get_Role_From_Code (l_role_prof);
                FETCH C_Get_Role_From_Code INTO l_creator_role;
                CLOSE C_Get_Role_From_Code;

                IF l_creator_role IS NULL THEN
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('nores:create:Creator Role From Res: '||l_creator_role,1,'N');
                    END IF;

                    OPEN C_Get_Resource_Role (l_creator_res);
                    FETCH C_Get_Resource_Role INTO l_creator_role;
                    CLOSE C_Get_Resource_Role;

                END IF;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Role Profile:  '||l_ots_role_prof,1,'Y');
                   aso_debug_pub.add('Role Profile:  '||l_role_prof,1,'Y');
                   aso_debug_pub.add('Creator Role:  '||l_creator_role,1,'Y');
                   aso_debug_pub.add('Creator Group: '||l_creator_grp,1,'Y');
                END IF;

                l_sequence := NULL;

                ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => l_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_creator_res,
                p_RESOURCE_GRP_ID        => l_creator_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => 'N',
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => 'N',
                p_ROLE_ID                => l_creator_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
                p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
                );

            END IF;

		  OPEN C_Valid_SalesRep (l_creator_res);
		  FETCH C_Valid_SalesRep INTO l_valid;
		  CLOSE C_Valid_SalesRep;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Creator Valid SalesRep : '||l_valid,1,'Y');
END IF;

		  IF l_valid = 'Y' THEN
			 l_primary_salesagent := l_creator_res;
		  END IF;

          END IF; -- creator_res is not null

        END IF; -- CREATE

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Update_Primary_SalesAgent: ',1,'Y');
END IF;
         ASO_SALES_TEAM_PVT.Update_Primary_SalesInfo (
             P_Init_Msg_List        =>  FND_API.G_FALSE,
             P_Qte_Header_Rec       =>  l_Qte_Header_Rec,
             P_Primary_SalesAgent   =>  l_primary_salesagent,
             P_Primary_SalesGrp     =>  l_creator_grp,
             P_reassign_flag        =>  l_reassign_flag,
             X_Qte_Header_Rec       =>  x_Qte_Header_Rec,
             x_return_status        =>  x_return_status,
             x_msg_count            =>  x_msg_count,
             x_msg_data             =>  x_msg_data
          );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After Update_Primary_SalesInfo: '||x_return_status,1,'Y');
END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

-- Change START
-- Release 12 TAP Changes
-- Girish Sachdeva 8/30/2005
-- Adding the call to insert record in the ASO_CHANGED_QUOTES

IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('ASO_SALES_TEAM_PVT.Assign_Sales_Team : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_Qte_Header_Rec.Quote_Number, 1, 'Y');
END IF;

-- Call to insert record in ASO_CHANGED_QUOTES
ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_Qte_Header_Rec.Quote_Number);

-- Change END


    EXCEPTION
        WHEN Leave_Proc THEN
            NULL;

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Assign_Sales_Team;

-- Change START
-- Release 12 TAP Changes
-- Changes Done By Girish
-- Commenting the whole procedure as the realtime call has changed.
/*
PROCEDURE Get_Sales_Team(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Tbl               IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                       := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    X_Winners_Rec                OUT NOCOPY    JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type,
    X_Return_Status              OUT NOCOPY    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY    NUMBER,
    X_Msg_Data                   OUT NOCOPY    VARCHAR2
    )
IS

   CURSOR C_Get_Party_Info (l_party_id NUMBER) IS
    SELECT UPPER(party_name) party_name, UPPER(category_code) category_code, employees_total,
		 UPPER(SIC_Code) SIC_Code, UPPER(SIC_Code_Type) SIC_Code_Type
    FROM HZ_PARTIES
    WHERE party_id = l_party_id;

   CURSOR C_Get_Party_Site_Info (l_party_site_id NUMBER) IS
    SELECT UPPER(B.city) city, UPPER(B.county) county, UPPER(B.state) state, UPPER(B.province) province,
		 UPPER(B.postal_code) postal_code, UPPER(B.country) country
    FROM HZ_PARTY_SITES A, HZ_LOCATIONS B
    WHERE A.Location_Id = B.Location_Id
    AND A.party_site_id = l_party_site_id;

   CURSOR C_Get_Cust_Cont_Info (l_party_id NUMBER) IS
    SELECT UPPER(Phone_Area_Code) Phone_Area_Code
    FROM HZ_CONTACT_POINTS
    WHERE Owner_Table_Id = l_party_id
    AND Owner_Table_Name = 'HZ_PARTIES'
    AND Contact_Point_Type = 'PHONE'
    AND Status = 'A'
    AND Primary_Flag = 'Y';


   lp_gen_bulk_Rec         JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;

   C_Party_Rec             C_Get_Party_Info%ROWTYPE;
   C_Party_Site_Rec        C_Get_Party_Site_Info%ROWTYPE;
   C_Cust_Cont_Rec         C_Get_Cust_Cont_Info%ROWTYPE;

   l_api_name              CONSTANT VARCHAR2 ( 30 ) := 'Get_Sales_Team';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT GET_SALES_TEAM_PVT;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get input info to pass to TM
    OPEN C_Get_Party_Info (P_Qte_Header_Rec.cust_party_id);
    FETCH C_Get_Party_Info INTO C_Party_Rec;
    CLOSE C_Get_Party_Info;

    OPEN C_Get_Party_Site_Info (P_Qte_Header_Rec.sold_to_party_site_id);
    FETCH C_Get_Party_Site_Info INTO C_Party_Site_Rec;
    CLOSE C_Get_Party_Site_Info;

    OPEN C_Get_Cust_Cont_Info (P_Qte_Header_Rec.party_id);
    FETCH C_Get_Cust_Cont_Info INTO C_Cust_Cont_Rec;
    CLOSE C_Get_Cust_Cont_Info;
-- End: Get input info to pass to TM

-- Instantiate input rec for the input bulk_trans_rec_type
    -- bulk_trans_rec_type instantiation
    -- logic control properties
    lp_gen_bulk_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
    lp_gen_bulk_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

    lp_gen_bulk_rec.trans_object_id(1) := P_qte_header_rec.quote_header_id;

    -- extend qualifier elements
    lp_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR02.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR03.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR05.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR06.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR08.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR09.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR10.EXTEND;

    -- transaction qualifier values
    lp_gen_bulk_rec.SQUAL_CHAR01(1) := C_Party_Rec.party_name;    -- Customer Name Range
    lp_gen_bulk_rec.SQUAL_CHAR02(1) := C_Party_Site_Rec.city;     -- City
    lp_gen_bulk_rec.SQUAL_CHAR03(1) := C_Party_Site_Rec.county;    -- County
    lp_gen_bulk_rec.SQUAL_CHAR04(1) := C_Party_Site_Rec.state;    -- State
    lp_gen_bulk_rec.SQUAL_CHAR05(1) := C_Party_Site_Rec.province;    -- Province
    lp_gen_bulk_rec.SQUAL_CHAR06(1) := C_Party_Site_Rec.postal_code;    -- Postal Code
    lp_gen_bulk_rec.SQUAL_CHAR07(1) := C_Party_Site_Rec.country;    -- Country
    lp_gen_bulk_rec.SQUAL_CHAR08(1) := C_Cust_Cont_Rec.Phone_Area_Code;    -- Area Code
    lp_gen_bulk_rec.SQUAL_CHAR09(1) := C_Party_Rec.category_code;    -- Customer Category
    lp_gen_bulk_rec.SQUAL_CHAR10(1) := C_Party_Rec.SIC_Code_Type||': '||C_Party_Rec.SIC_Code; --SIC Code

    lp_gen_bulk_rec.SQUAL_NUM01.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM02.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM03.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM04.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM05.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM06.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM07.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM08.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM09.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM10.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM50.EXTEND;

    -- transaction qualifier values
    lp_gen_bulk_rec.SQUAL_NUM01(1) := P_Qte_Header_Rec.cust_party_id; -- PARTY_ID
    lp_gen_bulk_rec.SQUAL_NUM02(1) := P_Qte_Header_Rec.sold_to_party_site_id; -- PARTY_SITE_ID
    lp_gen_bulk_rec.SQUAL_NUM03(1) := P_Qte_Header_Rec.cust_party_id; -- Sales Partner Of
    lp_gen_bulk_rec.SQUAL_NUM04(1) := P_Qte_Header_Rec.cust_party_id; -- Acct Hierarchy
    lp_gen_bulk_rec.SQUAL_NUM05(1) := C_Party_Rec.employees_total; -- Number of Employees
    lp_gen_bulk_rec.SQUAL_NUM06(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM07(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM08(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM09(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM10(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM50(1) := P_qte_header_rec.quote_header_id;
-- End: Instantiate input rec

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: P_qte_header_rec.quote_header_id: '||P_qte_header_rec.quote_header_id,1,'N');
aso_debug_pub.add('Assign_Sales_Team: P_qte_header_rec.party_id: '||P_qte_header_rec.party_id,1,'N');
aso_debug_pub.add('Assign_Sales_Team: P_qte_header_rec.cust_party_id: '||P_qte_header_rec.cust_party_id,1,'N');
aso_debug_pub.add('Assign_Sales_Team: P_qte_header_rec.sold_to_party_site_id: '||P_qte_header_rec.sold_to_party_site_id,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Rec.party_name: '||C_Party_Rec.party_name,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Rec.category_code: '||C_Party_Rec.category_code,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Rec.SIC: '||C_Party_Rec.SIC_Code_Type||': '||C_Party_Rec.SIC_Code,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Rec.employees_total: '||C_Party_Rec.employees_total,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.city: '||C_Party_Site_Rec.city,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.county: '||C_Party_Site_Rec.county,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.state: '||C_Party_Site_Rec.state,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.country: '||C_Party_Site_Rec.country,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.province: '||C_Party_Site_Rec.province,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Party_Site_Rec.postal_code: '||C_Party_Site_Rec.postal_code,1,'N');
aso_debug_pub.add('Assign_Sales_Team: C_Cust_Cont_Rec.Phone_Area_Code: '||C_Cust_Cont_Rec.Phone_Area_Code,1,'N');

aso_debug_pub.add('Before Calling JTF_TERR_ASSIGN_PUB.get_winners',1,'Y');
END IF;

    -- Call the JTF Terr Assignment API
    JTF_TERR_ASSIGN_PUB.get_winners
    (   p_api_version_number       => 1.0,
        p_init_msg_list            => FND_API.G_FALSE,

        p_use_type                 => 'RESOURCE',
        p_source_id                => -1001, -- Oracle Sales and Telesales
        p_trans_id                 => -1105, -- Quoting
        p_trans_rec                => lp_gen_bulk_rec,

        p_resource_type            => FND_API.G_MISS_CHAR,
        p_role                     => FND_API.G_MISS_CHAR,
        p_top_level_terr_id        => FND_API.G_MISS_NUM,
        p_num_winners              => FND_API.G_MISS_NUM,

        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,

        x_winners_rec              => x_winners_rec
    );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: X_Return_Status: '||X_Return_Status,1,'N');
aso_debug_pub.add('Assign_Sales_Team: x_winners_rec.count: '||x_winners_rec.Resource_Id.count,1,'N');
IF x_winners_rec.Resource_Id.count > 0 THEN
FOR i IN x_winners_rec.Resource_Id.FIRST..x_winners_rec.Resource_Id.LAST LOOP
aso_debug_pub.add('Assign_Sales_Team: Trans_Object_Id: '||x_winners_rec.Trans_Object_Id(i),1,'N');
aso_debug_pub.add('Assign_Sales_Team: Terr_Id: '||x_winners_rec.Terr_Id(i),1,'N');
aso_debug_pub.add('Assign_Sales_Team: Resource_Id: '||x_winners_rec.Resource_Id(i),1,'N');
aso_debug_pub.add('Assign_Sales_Team: Full_Access_Flag: '||x_winners_rec.Full_Access_Flag(i),1,'N');
aso_debug_pub.add('Assign_Sales_Team: Group_Id: '||x_winners_rec.Group_Id(i),1,'N');
aso_debug_pub.add('Assign_Sales_Team: Role: '||x_winners_rec.Role(i),1,'N');
END LOOP;
END IF;
END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Get_Sales_Team;
*/

-- Change Start
-- Release 12 JTY / TAP Changes
-- Girish Sachdeva
-- This procedure is changed to call the new JTF Terr Assignment API.
PROCEDURE EXPLODE_GROUPS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
-------------RS_GROUP---------
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | FOR EACH GROUP listed AS a winner within winners, get THE members who play
 | a sales ROLE AND are either an employee OR partner AND INSERT back INTO
 | winners IF they are NOT already IN winners.
 +-------------------------------------------------------------------------*/
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);

TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;

l_resource_id    num_list;
l_group_id   num_list;
l_person_id  num_list;

BEGIN
aso_debug_pub.add('Proc EXPLODE_GROUPS_ACCOUNTS',1,'Y');

   x_return_status := FND_API.G_RET_STS_SUCCESS;
--   l_resource_type := 'RS_TEAM';
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
   IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
        aso_debug_pub.add('Proc EXPLODE_GROUPS_ACCOUNTS p_WinningTerrMember_tbl.resource_id(l_index) ' || p_WinningTerrMember_tbl.resource_id(l_index),1,'Y');
        aso_debug_pub.add('Proc EXPLODE_GROUPS_ACCOUNTS p_WinningTerrMember_tbl.resource_type(l_index) ' || p_WinningTerrMember_tbl.resource_type(l_index),1,'Y');
        aso_debug_pub.add('Proc EXPLODE_GROUPS_ACCOUNTS p_WinningTerrMember_tbl.resource_name(l_index) ' || p_WinningTerrMember_tbl.resource_name(l_index),1,'Y');
       aso_debug_pub.add('Proc EXPLODE_GROUPS_ACCOUNTS p_WinningTerrMember_tbl.group_ide(l_index) ' || p_WinningTerrMember_tbl.group_id(l_index),1,'Y');
				IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_GROUP' THEN
       						SELECT resource_id,  group_id,person_id
						BULK COLLECT INTO l_resource_id, l_group_id,l_person_id
						FROM
							  (
							   SELECT min(m.resource_id) resource_id,
									  res.category resource_category,
									  m.group_id group_id, min(res.source_id) person_id
							   FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
									 jtf_rs_group_usages u, jtf_rs_role_relations rr,
									 jtf_rs_roles_b r, jtf_rs_resource_extns res
							   WHERE m.group_id = g.group_id
							   AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
												 AND NVL(g.end_date_active,SYSDATE)
							   AND   u.group_id = g.group_id
							   AND   u.usage IN ('SALES','PRM')
							   AND   m.group_member_id = rr.role_resource_id
							   AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
							   AND   rr.role_id = r.role_id
							   AND   rr.delete_flag <> 'Y'
							   AND   SYSDATE BETWEEN rr.start_date_active
							   AND   NVL(rr.end_date_active,SYSDATE)
							   AND   r.role_type_code IN
									 ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							   AND   r.active_flag = 'Y'
							   AND   res.resource_id = m.resource_id
							   AND   res.category IN ('EMPLOYEE')--,'PARTY','PARTNER')
							   GROUP BY m.group_member_id, m.resource_id, m.person_id,
										m.group_id, res.CATEGORY) j
						WHERE j.group_id = p_WinningTerrMember_tbl.resource_id(l_index);

						IF l_resource_id.COUNT > 0 THEN
							FOR i IN l_resource_id.FIRST .. l_resource_id.LAST LOOP
							/* No need to Check to see if it is already part of
							   p_WinningTerrMember_tbl because this will be slow,
							   So we insert into p_WinningTerrMember_tbl directly*/
							   IF l_group_id(i) IS NOT NULL THEN --- Resources without groups should NOT be added to the sales team
								p_WinningTerrMember_tbl.resource_id.EXTEND;
								p_WinningTerrMember_tbl.group_id.EXTEND;
								p_WinningTerrMember_tbl.person_id.EXTEND;
								p_WinningTerrMember_tbl.resource_type.EXTEND;
								p_WinningTerrMember_tbl.full_access_flag.EXTEND;
								p_WinningTerrMember_tbl.trans_object_id.EXTEND;
								p_WinningTerrMember_tbl.terr_id.EXTEND;
								p_WinningTerrMember_tbl.org_id.EXTEND;
								p_WinningTerrMember_tbl.role.EXTEND;
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT ) := 'RS_EMPLOYEE';
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT ) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								--p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_LEAD_ID;
								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);
								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.resource_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
							   END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;


   END IF;   /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN OTHERS THEN
aso_debug_pub.add('exception in  EXPLODE_GROUPS_ACCOUNTS',1,'Y');

      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_GROUPS_ACCOUNTS;

PROCEDURE Get_Sales_Team(
    P_Init_Msg_List	IN  VARCHAR2 := FND_API.G_FALSE,
    P_Qte_Header_Rec	IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Tbl	IN  ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    X_Winners_Rec	OUT NOCOPY /* file.sql.39 change */   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    X_Return_Status	OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count		OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data		OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
	l_errbuf         VARCHAR2(4000);
      l_retcode        VARCHAR2(255);
      l_return_status         VARCHAR2(30);
	lp_bulk_trans_id	JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
	l_api_name		CONSTANT VARCHAR2 (30) := 'Get_Sales_Team';

BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT GET_SALES_TEAM_PVT;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	lp_bulk_trans_id.trans_object_id1 := jtf_terr_number_list(P_Qte_Header_Rec.quote_header_id);
	lp_bulk_trans_id.trans_object_id2 := jtf_terr_number_list(null);
	lp_bulk_trans_id.trans_object_id3 := jtf_terr_number_list(null);
	lp_bulk_trans_id.trans_object_id4 := jtf_terr_number_list(null);
	lp_bulk_trans_id.trans_object_id5 := jtf_terr_number_list(null);
	lp_bulk_trans_id.txn_date := jtf_terr_date_list(null);

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Get_Sales_Team: P_Qte_Header_Rec.quote_header_id: '||P_qte_header_rec.quote_header_id,1,'N');
		aso_debug_pub.add('Get_Sales_Team: P_qte_header_rec.party_id: '||P_qte_header_rec.party_id,1,'N');
		aso_debug_pub.add('Get_Sales_Team: P_qte_header_rec.cust_party_id: '||P_qte_header_rec.cust_party_id,1,'N');
		aso_debug_pub.add('Get_Sales_Team: P_qte_header_rec.sold_to_party_site_id: '||P_qte_header_rec.sold_to_party_site_id,1,'N');
		aso_debug_pub.add('Before Calling JTY_ASSIGN_REALTIME_PUB.get_winners',1,'Y');
          aso_utility_pvt.print_login_info();
	END IF;

	-- Call the new JTF Terr Assignment API
	JTY_ASSIGN_REALTIME_PUB.get_winners (
		P_api_version_number        => 1.0,
		P_init_msg_list             => FND_API.G_FALSE,
		P_source_id                 => -1001 ,                  /* Oracle Sales and Telesales */
		P_trans_id                  =>  -1105 ,                 /* Quoting */
		P_mode                      => 'REAL TIME:RESOURCE',    /* It will return winning territories and resources in real time */
		P_param_passing_mechanism   => 'PBR',
		P_program_name              => 'SALES/QUOTE PROGRAM',   /* Taken from JTY TDD*/
		P_trans_rec                 => lp_bulk_trans_id,
		P_name_value_pair           => NULL,
		P_resource_type             => null, --changed to null from 'RS_EMPLOYEE',vidya
		P_role                      => NULL,
		X_return_status             => x_return_status,
		X_msg_count                 => x_msg_count,
		X_msg_data                  => x_msg_data,
		X_winners_rec               => X_Winners_Rec
	);
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Get_Sales_Team: x_return_status '||x_return_status,1,'N');
          aso_utility_pvt.print_login_info();
		aso_debug_pub.add('Get_Sales_Team: lx_bulk_winners_rec.count: '||X_Winners_Rec.Resource_Id.count,1,'N');
		IF X_Winners_Rec.Resource_Id.count > 0 THEN
			FOR i IN X_Winners_Rec.Resource_Id.FIRST..X_Winners_Rec.Resource_Id.LAST LOOP
				aso_debug_pub.add('Get_Sales_Team: Trans_Object_Id: '||X_Winners_Rec.Trans_Object_Id(i),1,'N');
				aso_debug_pub.add('Get_Sales_Team: Terr_Id: '||X_Winners_Rec.Terr_Id(i),1,'N');
				aso_debug_pub.add('Get_Sales_Team: Resource_Id: '||X_Winners_Rec.Resource_Id(i),1,'N');
				aso_debug_pub.add('Get_Sales_Team: Full_Access_Flag: '||X_Winners_Rec.Full_Access_Flag(i),1,'N');
				aso_debug_pub.add('Get_Sales_Team: Group_Id: '||X_Winners_Rec.Group_Id(i),1,'N');
				aso_debug_pub.add('Get_Sales_Team: Role: '||X_Winners_Rec.Role(i),1,'N');
			END LOOP;
			  EXPLODE_GROUPS_ACCOUNTS(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => X_Winners_Rec,
				  x_return_status => l_return_status);

                             EXPLODE_TEAMS(
                                  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  =>  X_Winners_Rec,
				  x_return_status => l_return_status);


                            INSERT_ACCESSES_ACCOUNTS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
                                P_Qte_Header_Rec=>P_qte_header_rec ,
				p_WinningTerrMember_tbl  => X_Winners_Rec,
				x_return_status => l_return_status);



			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then

			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;


		END IF;
	END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Get_Sales_Team;

-- Change END


PROCEDURE Update_Primary_SalesInfo(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Primary_SalesAgent         IN    NUMBER,
    P_Primary_SalesGrp           IN    NUMBER,
    P_Reassign_Flag              IN    VARCHAR2,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
   )
IS

   CURSOR C_Get_Primary_Resource (l_qte_number NUMBER) IS
    SELECT Resource_Id, Resource_Grp_Id
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_Number = l_qte_number
    AND Max_Version_Flag = 'Y';

   CURSOR C_Primary_Res_Kept (l_res NUMBER, l_qte_num NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_ACCESSES
    WHERE Resource_Id = l_res
    AND Quote_Number = l_qte_num;

    CURSOR C_Valid_Salesagent (l_qte_num NUMBER) IS
    SELECT A.Resource_Id, A.Resource_Grp_Id, A.Role_Id
    /* FROM ASO_QUOTE_ACCESSES A, JTF_RS_SALESREPS B, */ --Commented Code Yogeshwar (MOAC)
    FROM ASO_QUOTE_ACCESSES A, JTF_RS_SALESREPS_MO_V B,  --New Code Yogeshwar (MOAC)
    OE_SALES_CREDIT_TYPES ST
    WHERE B.sales_credit_type_id = ST.sales_credit_type_id
    AND A.Resource_Id = B.Resource_Id
    AND A.Update_Access_Flag = 'Y'
    AND A.Quote_Number = l_qte_num
    AND NVL(B.status,'A') = 'A'
    AND SYSDATE BETWEEN B.start_date_active AND NVL(B.end_date_active, SYSDATE) ;
    --Commented code start yogeshwar (MOAC)
    /*
    AND NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), '',
        NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(
        USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)

   CURSOR C_Get_Resource_Role (l_res NUMBER) IS
    SELECT Role_Id
    FROM JTF_RS_ROLE_RELATIONS
    WHERE Role_Resource_Id = l_res
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

   CURSOR C_Get_Res_From_Srep (l_Srep VARCHAR2) IS
    SELECT Resource_Id
    /* FROM JTF_RS_SRP_VL */ --Commented Code Yogeshwar (MOAC)
    FROM JTF_RS_SALESREPS_MO_V --New Code Yogeshwar (MOAC)
    WHERE Salesrep_Number = l_Srep
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;
    --Commented Code Start Yogeshwar (MOAC)
    /*
    AND NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)
   l_primary_resource      NUMBER;
   l_primary_resource_grp  NUMBER;
   l_primary_salesagent    NUMBER;
   l_primary_res_kept      VARCHAR2(1) := 'N';
   l_primary_role          NUMBER;
   l_primary_res_grp       NUMBER;
   l_primary_res           NUMBER;
   l_sequence              NUMBER := null;
   l_api_name              CONSTANT VARCHAR2 ( 50 ) := 'Update_Primary_SalesInfo';

   -- Change START
   -- Release 12 MOAC Changes : Bug 4500739
   -- Changes Done by : Girish
   -- Comments : Using HR EIT in place of org striped profile

   --l_default_salesrep_prof VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_PERSON_ID');
   l_default_salesrep_prof VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALESREP);

   --l_default_role_prof     VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_SALES_ROLE');
   l_default_role_prof     VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALES_ROLE);

   -- Change End

   l_ots_grp_prof          VARCHAR2(50);

/*
   := NVL(FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE',
                                       G_USER_ID, NULL, 522),
                                       FND_PROFILE.Value_Specific(
                                       'AST_DEFAULT_ROLE_AND_GROUP',
                                       G_USER_ID, NULL, 521));
*/

   l_obsolete_status       varchar2(1);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_PRIMARY_SALESINFO_PVT;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_primary_salesagent := p_primary_salesagent;
    l_primary_res_grp := p_primary_salesgrp;
    x_qte_header_rec := p_qte_header_rec;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: l_primary_salesagent: '||l_primary_salesagent,1,'N');
END IF;

  IF l_primary_salesagent IS NULL THEN
    IF p_reassign_flag = 'Y' THEN

        OPEN C_Get_Primary_Resource (P_Qte_Header_Rec.Quote_Number);
        FETCH C_Get_Primary_Resource INTO l_primary_res, l_primary_res_grp;
        CLOSE C_Get_Primary_Resource;

        OPEN C_Primary_Res_Kept(l_Primary_res, P_qte_header_rec.Quote_Number);
        FETCH C_Primary_Res_Kept INTO l_primary_res_kept;
        CLOSE C_Primary_Res_Kept;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: l_primary_salesagent: '||l_primary_res,1,'N');
aso_debug_pub.add('Assign_Sales_Team: Primary Res kept: '||l_primary_res_kept,1,'N');
END IF;

        IF l_primary_res_kept = 'Y' THEN
            l_primary_salesagent := l_primary_res;
        END IF;

    END IF; -- Reassign_Flag

    IF (l_primary_res_kept IS NULL OR l_primary_res_kept <> 'Y') THEN
	 IF l_primary_salesagent IS NULL THEN

        OPEN C_Valid_Salesagent(P_qte_header_rec.Quote_Number);
        FETCH C_Valid_Salesagent INTO l_primary_salesagent, l_primary_res_grp, l_primary_role;
        CLOSE C_Valid_Salesagent;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: Valid Salesagent: '||l_primary_salesagent,1,'N');
END IF;

        IF l_primary_salesagent IS NOT NULL THEN
            l_primary_res_kept := 'Y';
        END IF;

      END IF; -- salesagent is NULL

      IF l_primary_salesagent IS NULL THEN
        IF l_default_salesrep_prof IS NOT NULL THEN

            OPEN C_Get_Res_From_Srep (l_default_salesrep_prof);
            FETCH C_Get_Res_From_Srep INTO l_primary_salesagent;
            CLOSE C_Get_Res_From_Srep;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: Default SalesRep: '||l_primary_salesagent,1,'N');
END IF;
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                -- Created new message to display the error message more appropriately - Girish Bug 4654938
                -- FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
                -- FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_PERSON_ID', FALSE);
		FND_MESSAGE.Set_Name('ASO', 'ASO_NO_DEFAULT_VALUE');
                FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_SALESREP', TRUE);

                FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF; -- salesrep_prof

        l_primary_role := l_default_role_prof;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Before calling Get_Profile_Obsolete_Status', 1, 'N');
        END IF;

        l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                         p_application_id => 521);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
        END IF;

        if l_obsolete_status = 'T' then

            l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
            END IF;

            l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
            END IF;

            if l_primary_res_grp is null then

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := to_number(l_ots_grp_prof);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

            end if;

        else

            l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
            END IF;

            l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
            END IF;

            if l_primary_res_grp is null then

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

            end if;

        end if;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Assign_Sales_Team: Default Role: '||l_primary_role,1,'N');
           aso_debug_pub.add('Assign_Sales_Team: Default Grp: '||l_primary_res_grp,1,'N');
        END IF;

	 END IF; -- salesagent is NULL

      IF l_primary_role IS NULL THEN
          OPEN C_Get_Resource_Role (l_primary_salesagent);
          FETCH C_Get_Resource_Role INTO l_primary_role;
          CLOSE C_Get_Resource_Role;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: Role From Res: '||l_primary_role,1,'N');
END IF;
      END IF;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: l_primary_res_kept: '||l_primary_res_kept,1,'N');
END IF;

      IF (l_primary_res_kept IS NULL OR l_primary_res_kept <> 'Y') THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: Before primary salesagent insert: ',1,'N');
END IF;
        l_sequence := NULL;

        ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => P_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_primary_salesagent,
                p_RESOURCE_GRP_ID        => l_primary_res_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => FND_API.G_MISS_CHAR,
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => FND_API.G_MISS_CHAR,
                p_ROLE_ID                => l_primary_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
                p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
            );
      END IF; -- primary_res_kept <> Y
    END IF; -- primary_res_kept <> Y
  END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Sales_Team: Update primary salesagent in Hdr ',1,'N');
END IF;
       UPDATE ASO_QUOTE_HEADERS_ALL
       SET Resource_Id = l_primary_salesagent,
           Resource_Grp_Id = l_primary_res_grp,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number+1
       WHERE quote_number = P_Qte_Header_Rec.quote_number
       AND max_version_flag = 'Y'
       RETURNING quote_header_id, last_update_date, resource_id, resource_grp_id, object_version_number
       INTO x_qte_header_rec.Quote_Header_Id, x_qte_header_rec.Last_Update_Date,
            x_qte_header_rec.resource_id, x_qte_header_rec.resource_grp_id, x_qte_header_rec.object_version_number;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Update_Primary_SalesInfo;


PROCEDURE Opp_Quote_Primary_SalesRep(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
   )
IS

   l_api_name              CONSTANT VARCHAR2 ( 30 ) := 'Assign_Sales_Team';
   l_api_version_number    CONSTANT NUMBER := 1.0;
   l_creator_res           NUMBER;
   l_creator_found         VARCHAR2(1);
   l_valid                 VARCHAR2(1);
   l_primary_salesagent    NUMBER;
   l_primary_res_grp       NUMBER;
   l_primary_role          NUMBER;
   l_sequence              NUMBER := null;
   l_role_prof             VARCHAR2(50);

   -- Change START
   -- Release 12 MOAC Changes : Bug 4500739
   -- Changes Done by : Girish
   -- Comments : Using HR EIT in place of org striped profile

   --l_default_salesrep_prof VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_PERSON_ID');
   l_default_salesrep_prof VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALESREP);

   --l_default_role_prof     VARCHAR2(50) := FND_PROFILE.Value('ASO_DEFAULT_SALES_ROLE');
   l_default_role_prof     VARCHAR2(50) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALES_ROLE);

   -- Change End

   l_ots_role_prof         VARCHAR2(50) := FND_PROFILE.Value('AST_DEFAULT_ROLE_AND_GROUP');
   l_ots_grp_prof          VARCHAR2(50);

/*
   := NVL(FND_PROFILE.Value_Specific(
                                           'ASF_DEFAULT_GROUP_ROLE',
                                           G_USER_ID, NULL, 522),
                                           FND_PROFILE.Value_Specific(
                                           'AST_DEFAULT_ROLE_AND_GROUP',
                                           G_USER_ID, NULL, 521));
*/

   l_obsolete_status       varchar2(1);

   CURSOR C_Get_Creator_Res (l_user_id NUMBER) IS
    SELECT resource_id
    FROM JTF_RS_RESOURCE_EXTNS
    WHERE user_id = l_user_id
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

    CURSOR C_Valid_SalesRep (l_res_id NUMBER) IS
    SELECT 'Y'
    /* FROM JTF_RS_SRP_VL  */       --Commented Code Yogeshwar (MOAC)
    FROM JTF_RS_SALESREPS_MO_V      --New Code Yogeshwar (MOAC)
    WHERE resource_id = l_res_id
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;
    --Commented Code Start Yogeshwar (MOAC)
    /*
    AND NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)

   CURSOR C_Valid_Salesagent (l_qte_num NUMBER) IS
    SELECT A.Resource_Id, A.Resource_Grp_Id
    /* FROM ASO_QUOTE_ACCESSES A, JTF_RS_SALESREPS B, */  --Commented Code Yogeshwar ( MOAC)
    FROM  ASO_QUOTE_ACCESSES A,JTF_RS_SALESREPS_MO_V B,   --New Code Yogeshwar (MOAC)
    OE_SALES_CREDIT_TYPES ST
    WHERE B.sales_credit_type_id = ST.sales_credit_type_id
    AND A.Resource_Id = B.Resource_Id
    AND A.Update_Access_Flag = 'Y'
    AND A.Quote_Number = l_qte_num
    AND NVL(B.status,'A') = 'A'
    AND SYSDATE BETWEEN B.start_date_active AND NVL(B.end_date_active, SYSDATE) ;
    --Commented Code Start Yogeshwar (MOAC)
    /*
    AND NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), '',
        NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(
        USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End  Yogeshwar (MOAC)

   CURSOR C_Check_Creator_Res (l_qte_num NUMBER, l_res NUMBER) IS
    SELECT 'Y', Resource_Grp_Id
    FROM ASO_QUOTE_ACCESSES
    WHERE Quote_Number = l_qte_num
    AND Resource_Id = l_res;

   CURSOR C_Get_Role_From_Code (l_code VARCHAR2) IS
    SELECT Role_Id
    FROM JTF_RS_ROLES_B
    WHERE Role_Code = l_code
    AND Role_Type_Code IN ('TELESALES', 'SALES', 'FIELDSALES', 'PRM');

   CURSOR C_Get_Resource_Role (l_res NUMBER) IS
    SELECT Role_Id
    FROM JTF_RS_ROLE_RELATIONS
    WHERE Role_Resource_Id = l_res
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

   CURSOR C_Get_Res_From_Srep (l_Srep VARCHAR2) IS
    SELECT Resource_Id
    /* FROM JTF_RS_SRP_VL */     --Commented Code Yogeshwar (MOAC)
    FROM JTF_RS_SALESREPS_MO_V   --New Code Yogeshwar (MOAC)
    WHERE Salesrep_Number = l_Srep
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;
    --Commented Code Start Yogeshwar (MOAC)
    /*
    AND NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
    --Commented Code End Yogeshwar (MOAC)
BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT OPP_QUOTE_PRIMARY_SALESREP_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Begin Opp_Quote_Primary_SalesRep',1,'Y');
END IF;

    x_qte_header_rec := p_qte_header_rec;

    OPEN C_Get_Creator_Res(G_USER_ID);
    FETCH C_Get_Creator_Res INTO l_creator_res;
    CLOSE C_Get_Creator_Res;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Before Creator Res:l_creator_res: '||l_creator_res,1,'Y');
END IF;

    IF l_creator_res IS NOT NULL THEN

      OPEN C_Valid_SalesRep (l_creator_res);
      FETCH C_Valid_SalesRep INTO l_valid;
      CLOSE C_Valid_SalesRep;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Before Creator Res:G_USER_ID: '||G_USER_ID,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Creator Resource : '||l_creator_res,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Creator Valid SalesRep : '||l_valid,1,'Y');
END IF;

      IF l_valid = 'Y' THEN

            l_primary_salesagent := l_creator_res;

            OPEN C_Check_Creator_Res(P_Qte_Header_Rec.Quote_Number, l_creator_res);
            FETCH C_Check_Creator_Res INTO l_creator_found, l_primary_res_grp;
            CLOSE C_Check_Creator_Res;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Fetch Creator Grp: '||l_primary_res_grp,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Creator Found: '||l_creator_found,1,'Y');
END IF;

            IF l_creator_found IS NULL OR l_creator_found <> 'Y' THEN
                -- Role Defaulting Logic
                l_role_prof := SUBSTR(l_ots_role_prof, 1, INSTR(l_ots_role_prof, ':')-1);

                OPEN C_Get_Role_From_Code (l_role_prof);
                FETCH C_Get_Role_From_Code INTO l_primary_role;
                CLOSE C_Get_Role_From_Code;

                IF l_primary_role IS NULL THEN
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('nores:create:Creator Role From Res: '||l_primary_role,1,'N');
                    END IF;

                    OPEN C_Get_Resource_Role (l_creator_res);
                    FETCH C_Get_Resource_Role INTO l_primary_role;
                    CLOSE C_Get_Resource_Role;

                END IF;


            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Before calling Get_Profile_Obsolete_Status', 1, 'N');
            END IF;

            l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                         p_application_id => 521);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
            END IF;

            if l_obsolete_status = 'T' then

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

                if l_primary_res_grp is null then

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_primary_res_grp := to_number(l_ots_grp_prof);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                    END IF;

                end if;

            else

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

                if l_primary_res_grp is null then

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_primary_res_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                    END IF;

                end if;

            end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Role Profile: '||l_ots_role_prof,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Role Profile: '||l_role_prof,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Creator Role : '||l_primary_role,1,'Y');
aso_debug_pub.add('Opp_Qte_PS: Creator Group : '||l_primary_res_grp,1,'Y');
END IF;

                l_sequence := NULL;

                ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => P_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_creator_res,
                p_RESOURCE_GRP_ID        => l_primary_res_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => 'N',
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => 'N',
                p_ROLE_ID                => l_primary_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
                p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
                );

            END IF; -- creator_found

      END IF; -- l_valid = Y

    END IF; -- creator_res not null

      IF l_primary_salesagent IS NULL THEN

        OPEN C_Valid_Salesagent(P_qte_header_rec.Quote_Number);
        FETCH C_Valid_Salesagent INTO l_primary_salesagent, l_primary_res_grp;
        CLOSE C_Valid_Salesagent;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Valid Salesagent: '||l_primary_salesagent,1,'N');
END IF;
      END IF;

      IF l_primary_salesagent IS NULL THEN
        IF l_default_salesrep_prof IS NOT NULL THEN

            OPEN C_Get_Res_From_Srep (l_default_salesrep_prof);
            FETCH C_Get_Res_From_Srep INTO l_primary_salesagent;
            CLOSE C_Get_Res_From_Srep;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Default SalesRep: '||l_primary_salesagent,1,'N');
END IF;
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		-- Created new message to display the error message more appropriately - Girish Bug 4654938
                -- FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
                -- FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_PERSON_ID', FALSE);
		FND_MESSAGE.Set_Name('ASO', 'ASO_NO_DEFAULT_VALUE');
                FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_SALESREP', TRUE);

                FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF; -- salesrep_prof

        l_primary_role := l_default_role_prof;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Before calling Get_Profile_Obsolete_Status', 1, 'N');
            END IF;

            l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                         p_application_id => 521);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
            END IF;

            if l_obsolete_status = 'T' then

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

                if l_primary_res_grp is null then

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_primary_res_grp := to_number(l_ots_grp_prof);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                    END IF;

                end if;

            else

                l_ots_grp_prof := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASF_DEFAULT_GROUP_ROLE value: l_ots_grp_prof:  ' || l_ots_grp_prof, 1, 'N');
                END IF;

                l_primary_res_grp := SUBSTR(l_ots_grp_prof, 1, INSTR(l_ots_grp_prof,'(')-1);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                END IF;

                if l_primary_res_grp is null then

                    l_ots_grp_prof := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('AST_DEFAULT_ROLE_AND_GROUP value :l_ots_grp_prof: ' || l_ots_grp_prof, 1, 'N');
                    END IF;

                    l_primary_res_grp := substr(l_ots_grp_prof, instr(l_ots_grp_prof,':', -1) + 1, length(l_ots_grp_prof));

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_primary_res_grp: ' || l_primary_res_grp, 1, 'N');
                    END IF;

                end if;

            end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Default Role: '||l_primary_role,1,'N');
aso_debug_pub.add('Opp_Qte_PS: Default Grp: '||l_primary_res_grp,1,'N');
END IF;

      IF l_primary_role IS NULL THEN
          OPEN C_Get_Resource_Role (l_primary_salesagent);
          FETCH C_Get_Resource_Role INTO l_primary_role;
          CLOSE C_Get_Resource_Role;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Role From Res: '||l_primary_role,1,'N');
END IF;
      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Before primary salesagent insert: ',1,'N');
END IF;
        l_sequence := NULL;

        ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => P_Qte_Header_Rec.Quote_Number,
                p_RESOURCE_ID            => l_primary_salesagent,
                p_RESOURCE_GRP_ID        => l_primary_res_grp,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM,
                p_PROGRAM_ID             => FND_API.G_MISS_NUM,
                p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE,
                p_KEEP_FLAG              => FND_API.G_MISS_CHAR,
                p_UPDATE_ACCESS_FLAG     => 'Y',
                p_CREATED_BY_TAP_FLAG    => FND_API.G_MISS_CHAR,
                p_TERRITORY_ID           => FND_API.G_MISS_NUM,
                p_TERRITORY_SOURCE_FLAG  => FND_API.G_MISS_CHAR,
                p_ROLE_ID                => l_primary_role,
                p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE16            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE17            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE18            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE19            => FND_API.G_MISS_CHAR,
                p_ATTRIBUTE20            => FND_API.G_MISS_CHAR,
                p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM
            );

      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Opp_Qte_PS: Update primary salesagent in Hdr ',1,'N');
END IF;
       UPDATE ASO_QUOTE_HEADERS_ALL
       SET Resource_Id = l_primary_salesagent,
           Resource_Grp_Id = l_primary_res_grp,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number+1
       WHERE quote_number = P_Qte_Header_Rec.quote_number
       AND max_version_flag = 'Y'
       RETURNING quote_header_id, last_update_date, resource_id, resource_grp_id, object_version_number
       INTO x_qte_header_rec.Quote_Header_Id, x_qte_header_rec.Last_Update_Date,
            x_qte_header_rec.resource_id, x_qte_header_rec.resource_grp_id, x_qte_header_rec.object_version_number;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Opp_Quote_Primary_SalesRep;


END ASO_SALES_TEAM_PVT;

/
