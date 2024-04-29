--------------------------------------------------------
--  DDL for Package Body AS_RTTAP_OPPTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_RTTAP_OPPTY" as
/* $Header: asxrtopb.pls 120.11 2006/10/11 11:41:02 sariff noship $ */

G_ENTITY CONSTANT VARCHAR2(17) := 'OPPTYS::RT::';
G_LEAD_ID NUMBER;
G_PKG_NAME CONSTANT VARCHAR2(15) := 'AS_RTTAP_OPPTY';
PROCEDURE RTTAP_WRAPPER(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_LEAD_ID			 IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
	l_errbuf        VARCHAR2(4000);
	l_retcode       VARCHAR2(255);
	l_msg_count	NUMBER;
	l_msg_data	VARCHAR2(1000);
        l_trans_rec     JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
	l_WinningTerrMember_tbl	JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
	l_api_name                   CONSTANT VARCHAR2(30) := 'RTTAP_WRAPPER';
	l_api_version_number         CONSTANT NUMBER   := 1.0;
	L_RETURN_STATUS VARCHAR2(10);
BEGIN
    G_LEAD_ID := p_lead_id;
    SAVEPOINT RTTAP_WRAPPER_PVT;

    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       AS_GAR.G_DEBUG_FLAG := 'Y';
    END IF;
--    IF p_trace_mode = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PKG_NAME || AS_GAR.G_START);

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
		                     	 p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
		THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF NVL(FND_PROFILE.Value('AS_ENABLE_OPP_ONLINE_TAP'), 'N') <> 'Y' THEN
		/*------------------------------------------------------+
		|	If REALTIME TAP profile is turned on there is NO need
		|	to insert into changed accounts since the oppty is
		|	processed immediately.
		+-------------------------------------------------------*/
			INSERT INTO AS_CHANGED_ACCOUNTS_ALL
			(	   customer_id,
				   address_id,
				   lead_id,
				   last_update_date,
				   last_updated_by,
				   creation_date,
				   created_by,
				   last_update_login,
				   change_type )
			SELECT  customer_id,
				    address_id,
				    lead_id,
				    SYSDATE,
				    0,
				    SYSDATE,
				    0,
				    0,
				    'OPPORTUNITY'
			FROM    AS_LEADS_ALL LDS
			WHERE	lead_id = G_LEAD_ID
			AND NOT EXISTS
			(	SELECT 'X'
				FROM	AS_CHANGED_ACCOUNTS_ALL ACC
				WHERE	LDS.customer_id = ACC.customer_id
				--AND     LDS.address_id = ACC.address_id -- fix for bug#5116019
				AND     LDS.lead_id = ACC.lead_id
				AND	ACC.request_id IS NULL	);

	ELSE
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);
		l_trans_rec.trans_object_id1 := jtf_terr_number_list(G_LEAD_ID);
		l_trans_rec.trans_object_id2 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
		l_trans_rec.txn_date := jtf_terr_date_list(null);
		  JTY_ASSIGN_REALTIME_PUB.get_winners(
		    p_api_version_number       => 1.0,
		    p_init_msg_list            => FND_API.G_FALSE,
		    p_source_id                => -1001,
		    p_trans_id                 => -1004,
		    p_mode                     => 'REAL TIME:RESOURCE',
		    p_param_passing_mechanism  => 'PBR',
		    p_program_name             => 'SALES/OPPORTUNITY PROGRAM',
		    p_trans_rec                => l_trans_rec,
		    p_name_value_pair          => null,
		    p_role                     => null,
		    p_resource_type            => null,
		    x_return_status            => l_return_status,
		    x_msg_count                => l_msg_count,
		    x_msg_data                 => l_msg_data,
		    x_winners_rec              => l_WinningTerrMember_tbl);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_RETURN_STATUS || l_return_status);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			FND_MSG_PUB.Count_And_Get
				(  p_count          =>   l_msg_count,
				   p_data           =>   l_msg_data
			        );
			AS_UTILITY_PVT.Get_Messages(l_msg_count, l_msg_data);
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW, l_msg_data, 'ERROR');
			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_WinningTerrMember_tbl.resource_id.count > 0) THEN
		      FOR i IN l_WinningTerrMember_tbl.terr_id.FIRST .. l_WinningTerrMember_tbl.terr_id.LAST LOOP
		          AS_GAR.LOG(G_ENTITY ||  'Trans Object ID : ' || l_WinningTerrMember_tbl.trans_object_id(i) ||
					     'Trans Detail Object ID : ' || l_WinningTerrMember_tbl.trans_detail_object_id(i) ||
					     'Terr ID : ' || l_WinningTerrMember_tbl.terr_id(i) || ' Terr Name : ' || l_WinningTerrMember_tbl.terr_name(i) ||
					     ' Resource ID : ' || l_WinningTerrMember_tbl.resource_id(i) ||
					     ' Resource TYPE : ' || l_WinningTerrMember_tbl.resource_type(i));
		      END LOOP;
			-- Explode GROUPS if any inside winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_START);
			AS_RTTAP_OPPTY.EXPLODE_GROUPS_OPPTYS(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			-- Explode TEAMS if any inside winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
			AS_RTTAP_OPPTY.EXPLODE_TEAMS_OPPTYS(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			-- Set team leader for Opptys
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_START);
			AS_RTTAP_OPPTY.SET_TEAM_LEAD_OPPTYS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			 -- Insert into Oppty Accesses from Winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
			AS_RTTAP_OPPTY.INSERT_ACCESSES_OPPTYS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			 -- Insert into territory Accesses
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
			AS_RTTAP_OPPTY.INSERT_TERR_ACCESSES_OPPTYS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;
	      END IF;
		-- Remove (soft delete) records in access table that are not qualified
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_START);
		AS_RTTAP_OPPTY.PERFORM_OPPTY_CLEANUP(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_RETURN_STATUS || l_return_status);

		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
		  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC, l_errbuf, l_retcode);
		  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		End If;

		-- Opportunity Owner assignment
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_START);
		/* ----------------------------------------------------------------------+
		| G_TAP_FLAG is set to avoid calling the leads buid trigger .
		+------------------------------------------------------------------------*/
		AS_GAR.G_TAP_FLAG := 'Y';
		AS_RTTAP_OPPTY.ASSIGN_OPPTY_OWNER(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);
		AS_GAR.G_TAP_FLAG := 'N';
		/* ----------------------------------------------------------------------+
		| G_TAP_FLAG is reset.
		+------------------------------------------------------------------------*/
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_RETURN_STATUS || l_return_status);

		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
		  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO, l_errbuf, l_retcode);
		  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		End If;

		-- Opportunity Raising Business Event
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || 'Raising BE' || AS_GAR.G_START);

		AS_RTTAP_OPPTY.RAISE_BUSINESS_EVENT(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  x_return_status => l_return_status);

		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
		  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || 'Raising BE' , l_errbuf, l_retcode);
		  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		End If;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_RETURN_STATUS || l_return_status);

	END IF;

     -- Reset AS_ACCESSES_ALL.open_flag  added for bug 5592395

      UPDATE AS_ACCESSES_ALL acc
	SET object_version_number =  nvl(object_version_number,0) + 1, acc.OPEN_FLAG = 'Y'
	WHERE acc.LEAD_ID = p_lead_id
	AND EXISTS
        	(select 1
         	from as_leads_all ld,
              		as_statuses_b st
         	where st.opp_open_status_flag = 'Y'
         	and st.status_code = ld.status
         	and ld.lead_id = p_lead_id )
	AND nvl(acc.OPEN_FLAG, 'N') <> 'Y';

      UPDATE AS_ACCESSES_ALL acc
	SET object_version_number =  nvl(object_version_number,0) + 1, acc.OPEN_FLAG = 'N'
	WHERE  acc.LEAD_ID = p_lead_id
	AND NOT EXISTS
        	(select 1
         	from as_leads_all ld,
              		as_statuses_b st
         	where st.opp_open_status_flag = 'Y'
         	and st.status_code = ld.status
         	and ld.lead_id = p_lead_id )
	AND acc.OPEN_FLAG IS NOT NULL;


    -- Standard check for p_commit
	IF FND_API.to_Boolean( p_commit ) THEN
	  COMMIT WORK;
	END IF;
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => 'as.plsql.tap.realtime'
                  ,P_API_NAME => l_api_name
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => l_msg_count
                  ,X_MSG_DATA => l_msg_data
                  ,X_RETURN_STATUS => l_return_status);
	     X_Return_Status := FND_API.G_RET_STS_ERROR;
	     X_Msg_Count := 1;
	     X_Msg_Data  := 'ERROR IN OPPTY REALTIME TAP ASSIGNMENT';

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => 'as.plsql.tap.realtime'
                  ,P_API_NAME => l_api_name
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => l_msg_count
                  ,X_MSG_DATA => l_msg_data
                  ,X_RETURN_STATUS => l_return_status);
	     X_Return_Status := FND_API.G_RET_STS_ERROR;
	     X_Msg_Count := 1;
	     X_Msg_Data  := 'ERROR IN OPPTY REALTIME TAP ASSIGNMENT';

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => 'as.plsql.tap.realtime'
                  ,P_API_NAME => l_api_name
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => l_msg_count
                  ,X_MSG_DATA => l_msg_data
                  ,X_RETURN_STATUS => l_return_status);
	     X_Return_Status := FND_API.G_RET_STS_ERROR;
	     X_Msg_Count := 1;
	     X_Msg_Data  := 'ERROR IN OPPTY REALTIME TAP ASSIGNMENT';
END RTTAP_WRAPPER;


/************************** Start Explode Teams Opptys ******************/
PROCEDURE EXPLODE_TEAMS_OPPTYS(
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
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--   l_resource_type := 'RS_TEAM';
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
   IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
				IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_TEAM' THEN

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
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT
						||'FOR TEAM ' ||p_WinningTerrMember_tbl.resource_id(l_index));


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
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.person_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT) := 'RS_EMPLOYEE';
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);
								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_LEAD_ID;
								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.org_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
							   END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);
   END IF;  /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_TEAMS_OPPTYS;
/************************** End Explode Teams Opptys ******************/

/************************** Start Explode Groups Opptys ******************/
PROCEDURE EXPLODE_GROUPS_OPPTYS(
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
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--   l_resource_type := 'RS_TEAM';
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
   IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
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
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT
						||'FOR GROUP ' ||p_WinningTerrMember_tbl.resource_id(l_index));
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
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT ) := 'RS_EMPLOYEE';
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT ) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_LEAD_ID;
								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);
								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.resource_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
							   END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);
--        COMMIT;
   END IF;   /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_GROUPS_OPPTYS;

PROCEDURE SET_TEAM_LEAD_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN
     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
			AS_GAR.LOG(G_ENTITY || G_LEAD_ID || '::' || 'RESOURCE/GROUP::' || p_WinningTerrMember_tbl.resource_id(l_index) || '/' || p_WinningTerrMember_tbl.group_id(l_index));
			IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' THEN
					 UPDATE  AS_ACCESSES_ALL_ALL ACC
					 SET	 object_version_number =  nvl(object_version_number,0) + 1,
							 ACC.last_update_date = SYSDATE,
							 ACC.last_updated_by = FND_GLOBAL.USER_ID,
							 ACC.last_update_login = FND_GLOBAL.USER_ID,
							 ACC.team_leader_flag = NVL(p_WinningTerrMember_tbl.full_access_flag(l_index),'N')
					 WHERE	 ACC.lead_id    = G_LEAD_ID
					 AND	 ACC.salesforce_id  = p_WinningTerrMember_tbl.resource_id(l_index)
					 AND	 ACC.sales_group_id = p_WinningTerrMember_tbl.group_id(l_index)
					 AND     NVL(ACC.team_leader_flag,'N') <> NVL(p_WinningTerrMember_tbl.full_access_flag(l_index),'N');
			END IF;
		END LOOP;
	 END IF;
 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END SET_TEAM_LEAD_OPPTYS;


PROCEDURE INSERT_ACCESSES_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_START);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' AND p_WinningTerrMember_tbl.group_id(l_index) IS NOT NULL THEN
						AS_GAR.LOG(G_ENTITY || G_LEAD_ID || '::' || 'BEFORE INSERT INTO AS_ACCESSED_ALL RESOURCE/GROUP::' || p_WinningTerrMember_tbl.resource_id(l_index)
						|| '/' || p_WinningTerrMember_tbl.group_id(l_index));
						INSERT  INTO AS_ACCESSES_ALL
							       (access_id ,
								last_update_date ,
								last_updated_by,
								creation_date ,
								created_by ,
								last_update_login,
								access_type ,
								freeze_flag,
								reassign_flag,
								team_leader_flag ,
								customer_id ,
								address_id ,
								salesforce_id ,
								person_id ,
								sales_group_id,
								lead_id,
								created_by_tap_flag,
								owner_flag,
								open_flag,org_id)
						SELECT  AS_ACCESSES_S.NEXTVAL,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								FND_GLOBAL.USER_ID,
								'Online',
								'N',
								'N',
								DECODE(p_WinningTerrMember_tbl.full_access_flag(l_index),'Y','Y','N'),
								LDS.customer_id,
								LDS.address_Id,
								p_WinningTerrMember_tbl.resource_id(l_index),
								p_WinningTerrMember_tbl.person_id(l_index),
								p_WinningTerrMember_tbl.group_id(l_index),
								LDS.lead_id,
								'Y',
								'N',
								NVL(ST.opp_open_status_flag,'N'),
								p_WinningTerrMember_tbl.org_id(l_index)
						FROM AS_LEADS_ALL LDS, AS_STATUSES_B ST
						WHERE LDS.status = ST.status_code
						AND LDS.lead_id = G_LEAD_ID
						AND NOT EXISTS
								( SELECT NULL FROM AS_ACCESSES_ALL ACC
								   WHERE ACC.lead_id = LDS.lead_id
								   AND ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
								   AND ACC.sales_group_id = p_WinningTerrMember_tbl.group_id(l_index) );
					END IF;
			END LOOP;
	  END IF;
 	  AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_ACCESSES_OPPTYS;

PROCEDURE INSERT_TERR_ACCESSES_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
      /*------------------------------------------------------------------------------+
      | we are deleting all rows for the entity from as_territory_accesses prior to
      | inserting into it because the logic for removing only certain terr_id/access_id
      | combinations is very complex and could be slow..
      +-------------------------------------------------------------------------------*/
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      DELETE FROM AS_TERRITORY_ACCESSES TACC
      WHERE TACC.access_id IN
       (SELECT ACC.access_id
       FROM    AS_ACCESSES_ALL ACC
       WHERE   lead_id = G_LEAD_ID);
      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' THEN
						INSERT INTO AS_TERRITORY_ACCESSES
							(	access_id,
								territory_id,
								user_territory_id,
								last_update_date,
								last_updated_by,
								creation_date,
								created_by,
								last_update_login )
						SELECT
								ACC.access_id,
								p_WinningTerrMember_tbl.terr_id(l_index),
								p_WinningTerrMember_tbl.terr_id(l_index),
								SYSDATE,
								FND_GLOBAL.USER_ID,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								FND_GLOBAL.USER_ID
						FROM AS_ACCESSES_ALL ACC
						WHERE   ACC.lead_id = G_LEAD_ID
						AND	ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
						AND	ACC.sales_group_id = p_WinningTerrMember_tbl.group_id(l_index)
						AND NOT EXISTS ( SELECT 'Y'
								FROM AS_TERRITORY_ACCESSES
								WHERE ACCESS_ID = ACC.access_id
								AND TERRITORY_ID = p_WinningTerrMember_tbl.terr_id(l_index)) ;
					END IF;
			END LOOP;
	  END IF;
 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_TERR_ACCESSES_OPPTYS;

PROCEDURE PERFORM_OPPTY_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);
		DELETE FROM AS_ACCESSES_ALL ACC
		WHERE lead_id = G_LEAD_ID
	        AND NVL(freeze_flag, 'N') <> 'Y'
	        AND SALESFORCE_ID||SALES_GROUP_ID NOT IN (
				SELECT  RESTAB.RES||GRPTAB.GRP  FROM
				(SELECT rownum ROW_NUM,A.COLUMN_VALUE RES FROM TABLE(CAST(p_WinningTerrMember_tbl.resource_id AS jtf_terr_number_list)) a) RESTAB,
				(SELECT rownum ROW_NUM,b.COLUMN_VALUE GRP FROM TABLE(CAST(p_WinningTerrMember_tbl.group_id AS jtf_terr_number_list)) b) GRPTAB
				WHERE RESTAB.ROW_NUM = GRPTAB.ROW_NUM
				)
	        AND NOT EXISTS (SELECT  'X'
				FROM   AS_SALES_CREDITS
				WHERE   salesforce_id  =  ACC.salesforce_id
				AND   salesgroup_id = ACC.sales_group_id
				AND   lead_id = G_LEAD_ID) ;

      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END PERFORM_OPPTY_CLEANUP;

----------------------
PROCEDURE ASSIGN_OPPTY_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS

	CURSOR oppty_owner_rt IS
	SELECT MAX(AAA.access_id) access_id -- /*+ index(aaa as_accesses_n3) */
	  FROM AS_ACCESSES_ALL AAA
	 WHERE AAA.lead_id = G_LEAD_ID
	   AND NVL(AAA.CREATED_BY_TAP_FLAG,'N') = 'Y' ;

	CURSOR is_owner_set IS
	SELECT 'X'
	FROM   AS_ACCESSES_ALL
	WHERE  lead_id = G_LEAD_ID
	AND    owner_flag = 'Y';


	v_own_set VARCHAR2(1);
	v_acc_id NUMBER;
	v_srep_id NUMBER;
	v_grp_id  NUMBER;

BEGIN
 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START) ;
	 /* ----------------------------------------------------------------------+
	 | Select MAX(access_id) from as_accesses for this lead where the created_by_tap
	 | flag is set and owner flag is not set..Is there anything else that we need to do ?
	 | Then update accesses,leads,and scd
	 +------------------------------------------------------------------------*/
         x_return_status := FND_API.G_RET_STS_SUCCESS;
	 OPEN is_owner_set;
	 FETCH is_owner_set INTO v_own_set;
	 IF is_owner_set%NOTFOUND THEN
		OPEN oppty_owner_rt;
		FETCH oppty_owner_rt INTO v_acc_id;
		IF oppty_owner_rt%NOTFOUND THEN
			UPDATE AS_LEADS_ALL sl
			SET	SL.object_version_number =  nvl(sl.object_version_number,0) + 1,
			        SL.last_update_date = SYSDATE,
				SL.last_updated_by = FND_GLOBAL.USER_ID,
				SL.last_update_login = FND_GLOBAL.USER_ID,
				SL.owner_salesforce_id = NULL,
				SL.owner_sales_group_id = NULL
			WHERE SL.lead_id = G_LEAD_ID ;
			UPDATE AS_SALES_CREDITS_DENORM SCD
			SET	SCD.object_version_number =  nvl(scd.object_version_number,0) + 1,
				SCD.last_update_date = SYSDATE,
				SCD.last_updated_by =  FND_GLOBAL.USER_ID,
				SCD.last_update_login = FND_GLOBAL.USER_ID,
				SCD.owner_salesforce_id = NULL,
				SCD.owner_sales_group_id = NULL
			WHERE SCD.lead_id = G_LEAD_ID ;
		ELSE
			UPDATE AS_ACCESSES_ALL AAA
			SET	AAA.owner_flag = 'Y',
				AAA.object_version_number =  nvl(AAA.object_version_number,0) + 1,
			        AAA.last_update_date = SYSDATE,
				AAA.last_updated_by = FND_GLOBAL.USER_ID,
				AAA.last_update_login = FND_GLOBAL.USER_ID
			WHERE access_id = v_acc_id
			RETURNING salesforce_id,sales_group_id INTO v_srep_id,v_grp_id;
			UPDATE AS_LEADS_ALL sl
			SET	SL.object_version_number =  nvl(sl.object_version_number,0) + 1,
			        SL.last_update_date = SYSDATE,
				SL.last_updated_by = FND_GLOBAL.USER_ID,
				SL.last_update_login = FND_GLOBAL.USER_ID,
				SL.owner_salesforce_id = v_srep_id,
				SL.owner_sales_group_id = v_grp_id
			WHERE SL.lead_id = G_LEAD_ID ;
			UPDATE AS_SALES_CREDITS_DENORM SCD
			SET	SCD.object_version_number =  nvl(scd.object_version_number,0) + 1,
				SCD.last_update_date = SYSDATE,
				SCD.last_updated_by =  FND_GLOBAL.USER_ID,
				SCD.last_update_login = FND_GLOBAL.USER_ID,
				SCD.owner_salesforce_id = v_srep_id,
				SCD.owner_sales_group_id = v_grp_id
			WHERE SCD.lead_id = G_LEAD_ID ;
		END IF;
	 END IF;
	 CLOSE is_owner_set;
 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END ASSIGN_OPPTY_OWNER;

PROCEDURE RAISE_BUSINESS_EVENT(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    X_return_status    OUT NOCOPY VARCHAR2) IS
l_list          WF_PARAMETER_LIST_T;
l_param         WF_PARAMETER_T;
x_event_key     varchar2(1000);
l_event_name    VARCHAR2(240) := 'oracle.apps.as.opportunity.tap.realtime.post';
BEGIN
      X_return_status := FND_API.G_RET_STS_SUCCESS;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'Raising BE' || AS_GAR.G_START) ;

 -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

    -- Add Context values to the list
    l_param := WF_PARAMETER_T( NULL, NULL );

    -- fill the parameters list
    l_list.extend;
    l_param.SetName( 'LEAD_ID' );
    l_param.SetValue( G_LEAD_ID );
    l_list(l_list.last) := l_param;

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'Before Calling BE Procedure ' ||  AS_GAR.G_START);

    SELECT l_event_name || AS_BUSINESS_EVENT_S.nextval
      INTO x_event_key
      FROM DUAL;

    AS_BUSINESS_EVENT_PVT.raise_event(
        p_event_name        => l_event_name,
        p_event_key         => x_event_key,
        p_parameters        => l_list );
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'After  Calling BE Procedure ' || AS_GAR.G_END) ;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || 'RAISING BE' , SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;

END RAISE_BUSINESS_EVENT;
END AS_RTTAP_OPPTY;

/
