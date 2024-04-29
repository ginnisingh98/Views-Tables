--------------------------------------------------------
--  DDL for Package Body PRP_RTTAP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_RTTAP_INT_PVT" as
/* $Header: PRPVRTPB.pls 120.4 2006/02/20 16:59:24 hekkiral noship $ */

G_PROPOSAL_ID NUMBER;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'PRP_RTTAP_INT_PVT';

PROCEDURE LOG_MESSAGES(
    P_LOG_MESSAGE		IN   VARCHAR2,
    P_MODULE_NAME		IN   VARCHAR2,
    P_LOG_LEVEL			IN   NUMBER) IS
BEGIN

   IF ( P_LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(LOG_LEVEL => P_LOG_LEVEL,
                                   MODULE    => G_PKG_NAME ||':'|| P_MODULE_NAME,
                                   MESSAGE   => P_LOG_MESSAGE);
     END IF;

END LOG_MESSAGES;


PROCEDURE CALL_RUNTIME_TAP(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_Proposal_id		 IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
 	l_errbuf        		VARCHAR2(4000);
 	l_retcode       		VARCHAR2(255);
 	l_msg_count			NUMBER;
 	l_msg_data			VARCHAR2(1000);
        l_trans_rec     		JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
 	l_WinningTerrMember_tbl		JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
 	l_api_name             CONSTANT VARCHAR2(30) := 'CALL_RUNTIME_TAP';
 	l_api_version_number   CONSTANT NUMBER   := 1.0;
 	L_RETURN_STATUS 		VARCHAR2(10);
 BEGIN
     G_PROPOSAL_ID := p_proposal_id;
     SAVEPOINT CALL_RUNTIME_TAP;

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

     -- Log Debug Messages.
     LOG_MESSAGES(P_LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  P_MODULE_NAME    => l_api_name,
                  P_LOG_MESSAGE   => 'In CALL_RUNTIME_TAP.. Parameters: ' ||'P_Proposal_id: ' || p_proposal_id);


     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF NVL(FND_PROFILE.Value('PRP_ENABLE_ONLINE_TAP'), 'N') = 'Y' THEN

 		l_trans_rec.trans_object_id1 := jtf_terr_number_list(G_PROPOSAL_ID);
 		l_trans_rec.trans_object_id2 := jtf_terr_number_list(null);
 		l_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
 		l_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
 		l_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
 		l_trans_rec.txn_date := jtf_terr_date_list(null);

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling JTY_ASSIGN_REALTIME_PUB.get_winners');

 		  JTY_ASSIGN_REALTIME_PUB.get_winners(
 		    p_api_version_number       => 1.0,
 		    p_init_msg_list            => FND_API.G_FALSE,
 		    p_source_id                => -1001,
 		    p_trans_id                 => -1106,
 		    p_mode                     => 'REAL TIME:RESOURCE',
 		    p_param_passing_mechanism  => 'PBR',
 		    p_program_name             => 'SALES/PROPOSAL PROGRAM',
 		    p_trans_rec                => l_trans_rec,
 		    p_name_value_pair          => null,
 		    p_role                     => null,
 		    p_resource_type            => null,
 		    x_return_status            => l_return_status,
 		    x_msg_count                => l_msg_count,
 		    x_msg_data                 => l_msg_data,
 		    x_winners_rec              => l_WinningTerrMember_tbl);

 		-- Log Debug Messages.
		LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
			     P_MODULE_NAME    	=> l_api_name,
			     P_LOG_MESSAGE 	=> 'After Calling JTY_ASSIGN_REALTIME_PUB.get_winners.. x_return_status: '||l_return_status || ' x_message_data:  ' || l_msg_data);

 		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	         If l_msg_data is NOT NULL THEN
		       FND_MSG_PUB.Add_Exc_Msg('JTY_ASSIGN_REALTIME_PUB',
		                            'GET_WINNERS',
							   l_msg_data);
              End If;

 			FND_MSG_PUB.Count_And_Get
 				(  p_count          =>   x_msg_count,
 				   p_data           =>   x_msg_data
 			        );
 			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;

 		IF (l_WinningTerrMember_tbl.resource_id.count > 0) THEN

 		     FOR i IN l_WinningTerrMember_tbl.terr_id.FIRST .. l_WinningTerrMember_tbl.terr_id.LAST LOOP
 		          LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
			               P_MODULE_NAME   	=> l_api_name,
			               P_LOG_MESSAGE	=> 'Data from Winning Records... Trans Object ID : ' || l_WinningTerrMember_tbl.trans_object_id(i) ||
 					     'Trans Detail Object ID : ' || l_WinningTerrMember_tbl.trans_detail_object_id(i) ||
 					     'Terr ID : ' || l_WinningTerrMember_tbl.terr_id(i) || ' Terr Name : ' || l_WinningTerrMember_tbl.terr_name(i) ||
 					     ' Resource ID : ' || l_WinningTerrMember_tbl.resource_id(i) ||
 					     ' Resource TYPE : ' || l_WinningTerrMember_tbl.resource_type(i));
 		      END LOOP;

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling Explode_Groups');

	     	-- Explode GROUPS if any inside winners
 			EXPLODE_GROUPS(
 				  x_errbuf        		=> l_errbuf,
 				  x_retcode       		=> l_retcode,
 				  p_WinningTerrMember_tbl	=> l_WinningTerrMember_tbl,
 				  x_return_status 		=> l_return_status);


 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'After Calling Explode_Groups... ' ||'x_return_status: ' || l_return_status);

	  	     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  x_msg_data := l_errbuf;
 			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 			End If;

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling Explode_Teams');
 			-- Explode TEAMS if any inside winners
 			EXPLODE_TEAMS(
 				  x_errbuf        	   => l_errbuf,
 				  x_retcode                => l_retcode,
 				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
 				  x_return_status 	   => l_return_status);


 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'After Calling Explode_Teams... ' ||' x_return_Status: ' || l_return_status);

 			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  x_msg_data := l_errbuf;
 			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 			End If;

 			 -- Insert into Proposal Accesses from Winners

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling Insert_Accesses');
 			INSERT_ACCESSES(
 				x_errbuf        	=> l_errbuf,
 				x_retcode       	=> l_retcode,
 				p_WinningTerrMember_tbl => l_WinningTerrMember_tbl,
 				x_return_status 	=> l_return_status);

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'After Calling Insert_Accesses... ' ||' x_return_Status: ' || l_return_status);

		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  x_msg_data := l_errbuf;
 			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 			End If;

 			 -- Insert into territory Accesses

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling Insert_Terr_Accesses');
 			INSERT_TERR_ACCESSES(
 				x_errbuf        	=> l_errbuf,
 				x_retcode       	=> l_retcode,
 				p_WinningTerrMember_tbl => l_WinningTerrMember_tbl,
 				x_return_status 	=> l_return_status);

 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'After Calling Insert_Terr_Accesses... ' ||' x_return_Status: ' || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  x_msg_data := l_errbuf;
 			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 			End If;
 	      END IF;


 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'Before Calling Perform_Cleanup');
 		PERFORM_CLEANUP(
 				  x_errbuf        => l_errbuf,
 				  x_retcode       => l_retcode,
 				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
 				  x_return_status => l_return_status);


 		-- Log Debug Messages.
	  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
		             P_MODULE_NAME	=> l_api_name,
		             p_LOG_MESSAGE   	=> 'After Calling Perform_Cleanup... ' ||' x_return_Status: ' || l_return_status);

 		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  l_msg_data := l_errbuf;
 		       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 		End If;


 	END IF;

     -- Standard check for p_commit
 	IF FND_API.to_Boolean( p_commit ) THEN
 	  COMMIT WORK;
 	END IF;

 EXCEPTION
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		   ROLLBACK to CALL_RUNTIME_TAP;
 	        X_Return_Status := FND_API.G_RET_STS_ERROR;
 		   FND_MSG_PUB.Count_And_Get
 				(  p_count          =>   x_msg_count,
 				   p_data           =>   x_msg_data
 			        );
           WHEN OTHERS THEN
		   ROLLBACK to CALL_RUNTIME_TAP;
 	        X_Return_Status := FND_API.G_RET_STS_ERROR;
 		   FND_MSG_PUB.Count_And_Get
 				(  p_count          =>   x_msg_count,
 				   p_data           =>   x_msg_data
 			        );

 END CALL_RUNTIME_TAP;

 /************************** Start Explode Teams ******************/
 PROCEDURE EXPLODE_TEAMS(
     x_errbuf           	OUT NOCOPY VARCHAR2,
     x_retcode          	OUT NOCOPY VARCHAR2,
     p_WinningTerrMember_tbl    IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
     x_return_status    	OUT NOCOPY VARCHAR2)
 IS

  /*-------------------------------------------------------------------------+
  |                             LOGIC
  |
  | A RESOURCE team can be comprised OF resources who belong TO one OR more
  | GROUPS OF resources.
  | So get a LIST OF team members (OF TYPE employee AND play a ROLE OF salesrep )
  | AND get atleast one GROUP id that they belong TO
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Get resources within a resource team */

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
 								AND    u.usage = 'SALES'
 								AND    m.group_member_id = rr.role_resource_id
 								AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
 								AND    rr.delete_flag <> 'Y'
 								AND    SYSDATE BETWEEN rr.start_date_active
 								AND    NVL(rr.end_date_active,SYSDATE)
 								AND    rr.role_id = r.role_id
 								AND    r.role_type_code
 									   IN ('SALES', 'TELESALES', 'FIELDSALES')
 								AND    r.active_flag = 'Y'
 								AND    res.resource_id = m.resource_id
 								AND    res.CATEGORY IN ('EMPLOYEE')
 								 )  G
 							WHERE tm.team_id = t.team_id
 							AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
 							AND   NVL(t.end_date_active,SYSDATE)
 							AND   tu.team_id = t.team_id
 							AND   tu.usage = 'SALES'
 							AND   tm.team_member_id = trr.role_resource_id
 							AND   tm.delete_flag <> 'Y'
 							AND   tm.resource_type = 'INDIVIDUAL'
 							AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
 							AND   trr.delete_flag <> 'Y'
 							AND   SYSDATE BETWEEN trr.start_date_active
 									AND   NVL(trr.end_date_active,SYSDATE)
 							AND   trr.role_id = tr.role_id
 							AND   tr.role_type_code IN
 								  ('SALES', 'TELESALES', 'FIELDSALES')
 							AND   tr.active_flag = 'Y'
 							AND   tres.resource_id = tm.team_resource_id
 							AND   tres.category IN ('EMPLOYEE')
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
 								   AND   tu.usage = 'SALES'
 								   AND   tm.team_member_id = trr.role_resource_id
 								   AND   tm.delete_flag <> 'Y'
 								   AND   tm.resource_type = 'GROUP'
 								   AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
 								   AND   trr.delete_flag <> 'Y'
 								   AND   SYSDATE BETWEEN trr.start_date_active
 								   AND   NVL(trr.end_date_active,SYSDATE)
 								   AND   trr.role_id = tr.role_id
 								   AND   tr.role_type_code IN
 									 ('SALES', 'TELESALES', 'FIELDSALES')
 								   AND   tr.active_flag = 'Y'
 								   AND   tres.resource_id = tm.team_resource_id
 								   AND   tres.category IN ('EMPLOYEE')
 								   ) jtm
 							WHERE m.group_id = g.group_id
 							AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
 							AND   NVL(g.end_date_active,SYSDATE)
 							AND   u.group_id = g.group_id
 							AND   u.usage = 'SALES'
 							AND   m.group_member_id = rr.role_resource_id
 							AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
 							AND   rr.delete_flag <> 'Y'
 							AND   SYSDATE BETWEEN rr.start_date_active
 									AND   NVL(rr.end_date_active,SYSDATE)
 							AND   rr.role_id = r.role_id
 							AND   r.role_type_code IN
 								  ('SALES', 'TELESALES', 'FIELDSALES')
 							AND   r.active_flag = 'Y'
 							AND   res.resource_id = m.resource_id
 							AND   res.category IN ('EMPLOYEE')
 							AND   jtm.group_id = g.group_id
 							GROUP BY m.resource_id, m.person_id, jtm.team_id, res.CATEGORY) J
 						WHERE j.team_id = p_WinningTerrMember_tbl.resource_id(l_index);



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
 								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_PROPOSAL_ID;
 								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.org_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
 							   END IF;
 							END LOOP;
 						END IF;
 				END IF;
 		END LOOP;
    END IF;  /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
 EXCEPTION
 WHEN others THEN
       x_errbuf := SQLERRM;
       x_retcode := SQLCODE;
       x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Add_Exc_Msg('PRP_RTTAP_INT_PVT','EXPLODE_TEAMS',SQLERRM);
 	 -- Log Debug Messages.
  	 LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
	             P_MODULE_NAME	=> 'Insert_Terr_Accesses',
	             p_LOG_MESSAGE   	=> 'Error While Exploding Teams.. ' ||' x_errbuf: ' || x_errbuf);
 END EXPLODE_TEAMS;
/************************** End Explode Teams ******************/


/************************** Start Explode Groups ******************/
PROCEDURE EXPLODE_GROUPS(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2)
IS
-------------RS_GROUP---------
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | FOR EACH GROUP listed AS a winner within winners, get THE members who play
 | a sales ROLE AND are an employee AND INSERT back INTO  winners IF they are
 | NOT already IN winners.
 +-------------------------------------------------------------------------*/
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);

TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;

l_resource_id    num_list;
l_group_id   num_list;
l_person_id  num_list;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/

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
							   AND   u.usage = 'SALES'
							   AND   m.group_member_id = rr.role_resource_id
							   AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
							   AND   rr.role_id = r.role_id
							   AND   rr.delete_flag <> 'Y'
							   AND   SYSDATE BETWEEN rr.start_date_active
							   AND   NVL(rr.end_date_active,SYSDATE)
							   AND   r.role_type_code IN
									 ('SALES', 'TELESALES', 'FIELDSALES')
							   AND   r.active_flag = 'Y'
							   AND   res.resource_id = m.resource_id
							   AND   res.category IN ('EMPLOYEE')
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
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT ) := 'RS_EMPLOYEE';
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT ) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_PROPOSAL_ID;
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
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Add_Exc_Msg('PRP_RTTAP_INT_PVT','EXPLODE_GROUPS',SQLERRM);
 	 -- Log Debug Messages.
  	 LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
	             P_MODULE_NAME	=> 'Insert_Terr_Accesses',
	             p_LOG_MESSAGE   	=> 'Error While Exploding Groups.. ' ||' x_errbuf: ' || x_errbuf);
END EXPLODE_GROUPS;

/************************** End Explode Groups ******************/


/************************** Start Insert Accessses ***************/
PROCEDURE INSERT_ACCESSES(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2) IS
BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' AND p_WinningTerrMember_tbl.group_id(l_index) IS NOT NULL THEN

						INSERT  INTO PRP_PROPOSAL_ACCESSES
							       (proposal_access_id ,
								last_update_date ,
								last_updated_by,
								creation_date ,
								created_by ,
								last_update_login,
								proposal_id,
								resource_id,
								resource_group_id,
								Access_level,
								Keep_flag)
						SELECT  PRP_PROPOSAL_ACCESSES_S1.NEXTVAL,
							SYSDATE,
							FND_GLOBAL.USER_ID,
							SYSDATE,
							FND_GLOBAL.USER_ID,
							FND_GLOBAL.USER_ID,
							pp.Proposal_id,
							p_WinningTerrMember_tbl.resource_id(l_index),
							p_WinningTerrMember_tbl.group_id(l_index),
							DECODE(p_WinningTerrMember_tbl.full_access_flag(l_index),'Y','FULL','READ'),
							'N'
						FROM PRP_PROPOSALS pp
						WHERE pp.proposal_id = G_Proposal_ID
						AND NOT EXISTS
								( SELECT NULL FROM PRP_PROPOSAL_ACCESSES ACC
								   WHERE ACC.proposal_id = pp.proposal_id
								   AND ACC.resource_id = p_WinningTerrMember_tbl.resource_id(l_index)
								   AND ACC.resource_group_id = p_WinningTerrMember_tbl.group_id(l_index) );
					END IF;
			END LOOP;
	  END IF;

EXCEPTION
WHEN OTHERS THEN
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Add_Exc_Msg('PRP_RTTAP_INT_PVT','INSERT_ACCESS',SQLERRM);
 	 -- Log Debug Messages.
  	 LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
	             P_MODULE_NAME	=> 'Insert_Terr_Accesses',
	             p_LOG_MESSAGE   	=> 'Error While Inserting into PRP_Accesses... ' ||' x_errbuf: ' || x_errbuf);
END INSERT_ACCESSES;
/************************** End Insert Accessses ***************/

/************************** Start Insert Territory Accessses ***************/
PROCEDURE INSERT_TERR_ACCESSES(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2) IS
BEGIN

      /*------------------------------------------------------------------------------+
      | we are deleting all rows for the entity from as_territory_accesses prior to
      | inserting into it because the logic for removing only certain terr_id/access_id
      | combinations is very complex and could be slow..
      +-------------------------------------------------------------------------------*/
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      DELETE FROM PRP_TERRITORY_ACCESSES TACC
      WHERE TACC.proposal_access_id IN
       (SELECT ACC.proposal_access_id
       FROM    PRP_PROPOSAL_ACCESSES ACC
       WHERE   proposal_id = G_PROPOSAL_ID);

      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP

					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' THEN

						INSERT INTO PRP_TERRITORY_ACCESSES
							(proposal_access_id,
							 territory_id,
							 object_version_number,
							 last_update_date,
							 last_updated_by,
							 creation_date,
							 created_by,
							last_update_login )
						SELECT
							ACC.proposal_access_id,
							p_WinningTerrMember_tbl.terr_id(l_index),
							1,
							SYSDATE,
							FND_GLOBAL.USER_ID,
							SYSDATE,
							FND_GLOBAL.USER_ID,
							FND_GLOBAL.USER_ID
						FROM PRP_PROPOSAL_ACCESSES ACC
						WHERE   ACC.proposal_id = G_PROPOSAL_ID
						AND	ACC.resource_id = p_WinningTerrMember_tbl.resource_id(l_index)
						AND	ACC.resource_group_id = p_WinningTerrMember_tbl.group_id(l_index)
						AND NOT EXISTS ( SELECT 'Y'
								FROM PRP_TERRITORY_ACCESSES
								WHERE proposal_ACCESS_ID = ACC.Proposal_access_id
								AND TERRITORY_ID = p_WinningTerrMember_tbl.terr_id(l_index)) ;
					END IF;
			END LOOP;
	  END IF;

EXCEPTION
WHEN OTHERS THEN
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;

	 FND_MSG_PUB.Add_Exc_Msg('PRP_RTTAP_INT_PVT','INSERT_TERR_ACCESSES',SQLERRM);
 	-- Log Debug Messages.
  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
	             P_MODULE_NAME	=> 'Insert_Terr_Accesses',
	             p_LOG_MESSAGE   	=> 'Error While Inserting into PRP_Terroritory_Accesses... ' ||' x_errbuf: ' || x_errbuf);
END INSERT_TERR_ACCESSES;
/************************** End Insert Territory Accessses ***************/


/************************** Start Perform Cleanup ***************/
PROCEDURE PERFORM_CLEANUP(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2) IS

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

		DELETE FROM PRP_PROPOSAL_ACCESSES ACC
		WHERE proposal_id = G_PROPOSAL_ID
	        AND NVL(keep_flag, 'N') <> 'Y'
	        AND RESOURCE_ID||RESOURCE_GROUP_ID NOT IN (
				SELECT  RESTAB.RES||GRPTAB.GRP  FROM
				(SELECT rownum ROW_NUM,A.COLUMN_VALUE RES FROM TABLE(CAST(p_WinningTerrMember_tbl.resource_id AS jtf_terr_number_list)) a) RESTAB,
				(SELECT rownum ROW_NUM,b.COLUMN_VALUE GRP FROM TABLE(CAST(p_WinningTerrMember_tbl.group_id AS jtf_terr_number_list)) b) GRPTAB
				WHERE RESTAB.ROW_NUM = GRPTAB.ROW_NUM
				);

EXCEPTION
WHEN OTHERS THEN
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Add_Exc_Msg('PRP_RTTAP_INT_PVT','PERFORM_CLEANUP',SQLERRM);
 	-- Log Debug Messages.
  	LOG_MESSAGES(P_LOG_LEVEL 	=> FND_LOG.LEVEL_STATEMENT,
	             P_MODULE_NAME	=> 'Insert_Terr_Accesses',
	             p_LOG_MESSAGE   	=> 'Error in Perform_Cleanup... ' ||' x_errbuf: ' || x_errbuf);
END PERFORM_CLEANUP;
/************************** End Perform Cleanup ***************/

END PRP_RTTAP_INT_PVT;


/
