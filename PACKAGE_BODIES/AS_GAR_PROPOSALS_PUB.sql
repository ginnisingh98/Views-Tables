--------------------------------------------------------
--  DDL for Package Body AS_GAR_PROPOSALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_GAR_PROPOSALS_PUB" AS
/* $Header: asxgrppb.pls 120.11 2006/02/02 21:30 amagupta noship $ */
---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR_PROPOSALS_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--    --------
--    This package contains procedures to accomplish each of the following
--    tasks:
--    1: Call the JTY API to process data from JTY trans tables and
--       populate JTY winners.
--    2: Merge and insert records from winners into PRP_PROPOSAL_ACCESSES
--    3: Soft Delete unwanted records from PRP_PROPOSAL_ACCESSES
--
--    NOTE: No Owner Assignment and Cleanup steps required for PROPOSALS
---------------------------------------------------------------------------
/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_BUSINESS_EVENT  CONSTANT VARCHAR2(60) := 'oracle.apps.as.tap.batch_mode';
  DEADLOCK_DETECTED EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
  G_ENTITY CONSTANT VARCHAR2(17) := 'GAR::PROPOSALS::';
/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*
 |                              PUBLIC ROUTINES
 *------------------------------------------------------------------------*/

/************************** Start GAR Wrapper *****************************/
PROCEDURE GAR_WRAPPER(
    errbuf		OUT NOCOPY VARCHAR2,
    retcode		OUT NOCOPY VARCHAR2,
    p_run_mode		IN  VARCHAR2,
    p_debug_mode	IN  VARCHAR2,
    p_trace_mode	IN  VARCHAR2,
    p_worker_id		IN  VARCHAR2 ,
    P_percent_analyzed  IN  NUMBER )
  IS
    l_terr_globals   AS_GAR.TERR_GLOBALS;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_errbuf         VARCHAR2(4000);
    l_retcode        VARCHAR2(255);
    l_sub_exist      VARCHAR2(1);  -- ?
    l_return_status  VARCHAR2(1);
    l_target_type    VARCHAR2(15); -- ? not sure we need this
    l_status         BOOLEAN;
    l_proc           VARCHAR2(30):= 'GAR_WRAPPER::';
BEGIN
    AS_GAR.g_debug_flag := p_debug_mode;
	IF p_trace_mode = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || l_proc || AS_GAR.G_START);

     IF p_run_mode = AS_GAR.G_TOTAL_MODE THEN
         l_target_type := 'TOTAL';
     ELSIF p_run_mode = AS_GAR.G_NEW_MODE THEN
         l_target_type := 'INCREMENTAL';
     END If;

    -- Set the Global variables
    AS_GAR.INIT(
      p_run_mode,
      p_worker_id,
      l_terr_globals);

    /* This inserts into proposal winners */
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);
    JTY_ASSIGN_BULK_PUB.GET_WINNERS
    ( p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.G_TRUE,
      p_source_id             => -1001,
      p_trans_id	      => -1106,
      P_PROGRAM_NAME          => 'SALES/PROPOSAL PROGRAM',
      P_mode                  =>  l_target_type,
      P_percent_analyzed      => NVL(P_percent_analyzed,20),
      p_worker_id             => p_worker_id,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      ERRBUF                  => l_errbuf,
      RETCODE                 => l_retcode);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    COMMIT;

    -- Explode GROUPS if any inside winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.EXPLODE_GROUPS_PROPOSALS(
          x_errbuf        => l_errbuf,
          x_retcode       => l_retcode,
          p_terr_globals  => l_terr_globals,
          x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    COMMIT;

    -- Explode TEAMS if any inside winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.EXPLODE_TEAMS_PROPOSALS(
          x_errbuf        => l_errbuf,
          x_retcode       => l_retcode,
          p_terr_globals  => l_terr_globals,
          x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;
    COMMIT;
    -- Set team leader for Accounts
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.SET_TEAM_LEAD_PROPOSALS(
        x_errbuf        => l_errbuf,
        x_retcode       => l_retcode,
        p_terr_globals  => l_terr_globals,
        x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

	 -- Insert into proposal Accesses from Winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.INSERT_ACCESSES_PROPOSALS(
        x_errbuf        => l_errbuf,
        x_retcode       => l_retcode,
        p_terr_globals  => l_terr_globals,
        x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

	 -- Insert into territory Accesses
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.INSERT_TERR_ACCESSES_PROPOSALS(
        x_errbuf        => l_errbuf,
        x_retcode       => l_retcode,
        p_terr_globals  => l_terr_globals,
        x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;


    -- Remove (soft delete) records in access table that are not qualified
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_START);
    AS_GAR_PROPOSALS_PUB.Perform_Proposal_Cleanup(
              x_errbuf        => l_errbuf,
              x_retcode       => l_retcode,
              p_terr_globals  => l_terr_globals,
              x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    -- BES enhancement

     l_sub_exist := AS_GAR.exist_subscription(G_BUSINESS_EVENT);
     IF l_sub_exist = 'Y' THEN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_CBE_EXISTS);
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CBE_RAISE);
	AS_GAR.Raise_BE(l_terr_globals);
    END If;

    AS_GAR.LOG(G_ENTITY || l_proc || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END GAR_WRAPPER;

/**************************   End GAR Wrapper *****************************/

/************************** Start Explode Teams PROPOSALS ******************/
PROCEDURE EXPLODE_TEAMS_PROPOSALS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
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
l_res_type_count NUMBER;
l_res_prop_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_PROP_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;

CURSOR count_res_proposal
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_TEAM'
AND acc.access_type = 'PROPOSAL'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;

BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_request_id    := p_terr_globals.request_id;
   l_worker_id     := p_terr_globals.worker_id;
   l_resource_type := 'RS_TEAM';

   OPEN   count_res_proposal;
	FETCH  count_res_proposal INTO   l_res_prop_count;
   CLOSE  count_res_proposal;

   IF l_res_prop_count > 0 THEN
   OPEN   c_get_res_type_count(l_resource_type, l_request_id, l_worker_id);
      FETCH  c_get_res_type_count INTO   l_res_type_count;
   CLOSE  c_get_res_type_count;
   END IF;

   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_N_ROWS_PROCESSED  || l_res_type_count);
   IF l_res_type_count > 0 THEN
   /* Get resources within a resource team */
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
   /** Note
	 Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
         because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
	**/
	       INSERT INTO JTF_TAE_1001_PROP_WINNERS
            (trans_object_id,
             trans_detail_object_id,
             terr_id,
             resource_id,
             resource_type,
             group_id,
             full_access_flag,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             source_id,
             trans_object_type_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             absolute_rank,
             top_level_terr_id,
             num_winners,
             terr_rsc_id,
             role,
             primary_contact_flag,
             person_id,
             org_id,
             worker_id)
         SELECT T.trans_object_id,
               T.trans_detail_object_id,
               T.terr_id,
               J.resource_id,
               DECODE(J.resource_category,'PARTY','RS_PARTY',
                                          'PARTNER','RS_PARTNER',
                                          'EMPLOYEE','RS_EMPLOYEE','UNKNOWN'),
               J.group_id,
               T.full_access_flag,
               T.request_id,
               T.program_application_id,
               T.program_id, T.program_update_date,
               T.source_id,
               T.trans_object_type_id,
               SYSDATE,
               T.last_updated_by,
               SYSDATE,
               T.created_by,
               T.last_update_login,
               T.absolute_rank,
               T.top_level_terr_id,
               T.num_winners,
               T.terr_rsc_id,
               T.role,
               T.primary_contact_flag,
               J.person_id,
               T.org_id,
               T.worker_id
        FROM
               JTF_TAE_1001_PROP_WINNERS T,
               (
                 SELECT TM.team_resource_id resource_id,
                        TM.person_id person_id2,
                        MIN(G.group_id)group_id,
                        MIN(T.team_id) team_id,
                        TRES.category resource_category,
                        TRES.source_id person_id
                 FROM   jtf_rs_team_members TM, jtf_rs_teams_b T,
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
                        AND    res.category IN ('EMPLOYEE','PARTY','PARTNER')
                         )  G
                WHERE tm.team_id = t.team_id
                AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
                AND NVL(t.end_date_active,SYSDATE)
                AND   tu.team_id = t.team_id
                AND   tu.usage IN ('SALES','PRM')
                AND   tm.team_member_id = trr.role_resource_id
                AND   tm.delete_flag <> 'Y'
                AND   tm.resource_type = 'INDIVIDUAL'
                AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
                AND   trr.delete_flag <> 'Y'
                AND   SYSDATE BETWEEN trr.start_date_active AND
                                      NVL(trr.end_date_active,SYSDATE)
                AND   trr.role_id = tr.role_id
                AND   tr.role_type_code IN
                      ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                AND   tr.active_flag = 'Y'
                AND   tres.resource_id = tm.team_resource_id
                AND   tres.category IN ('EMPLOYEE','PARTY','PARTNER')
                AND   tm.team_resource_id = g.resource_id
                GROUP BY tm.team_resource_id,
                         tm.person_id,
                         tres.category,
                         tres.source_id
         UNION ALL
             SELECT MIN(m.resource_id) resource_id,
                       MIN(m.person_id) person_id2, MIN(m.group_id) group_id,
                       MIN(jtm.team_id) team_id, res.category resource_category,
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
                       AND   tres.category IN ('EMPLOYEE','PARTY','PARTNER')
                       ) jtm
                WHERE m.group_id = g.group_id
                AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                AND   NVL(g.end_date_active,SYSDATE)
                AND   u.group_id = g.group_id
                AND   u.usage IN ('SALES','PRM')
                AND   m.group_member_id = rr.role_resource_id
                AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
                AND   rr.delete_flag <> 'Y'
                AND   SYSDATE BETWEEN rr.start_date_active AND
                                  NVL(rr.end_date_active,SYSDATE)
                AND   rr.role_id = r.role_id
                AND   r.role_type_code IN
                      ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                AND   r.active_flag = 'Y'
                AND   res.resource_id = m.resource_id
                AND   res.category IN ('EMPLOYEE','PARTY','PARTNER')
                AND   jtm.group_id = g.group_id
                GROUP BY m.resource_id, m.person_id,
                jtm.team_id, res.category) J
     WHERE j.team_id = t.resource_id
        AND   t.request_id = l_request_id
        AND   t.worker_id =  l_worker_id
        AND   t.resource_type = 'RS_TEAM'
        AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_PROP_WINNERS rt1
                        WHERE rt1.resource_id = j.resource_id
                        AND   NVL(rt1.group_id,-1) = NVL(j.group_id,-1)
                        AND   rt1.request_id = t.request_id
                        AND   rt1.worker_id =  t.worker_id
                        AND   rt1.trans_object_id = t.trans_object_id
                        AND   NVL(rt1.trans_detail_object_id,-1) =
                                  NVL(t.trans_detail_object_id,-1));

	     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
	     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);


        COMMIT;

     END IF;  /* if l_res_type_count > 0 */
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END EXPLODE_TEAMS_PROPOSALS;
/************************** End Explode Teams PROPOSALS ******************/

/************************** Start Explode Groups PROPOSALS ******************/
PROCEDURE EXPLODE_GROUPS_PROPOSALS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
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
l_res_type_count NUMBER;
l_res_prop_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_PROP_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;


CURSOR count_res_proposal
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_GROUP'
AND acc.access_type = 'PROPOSAL'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;

BEGIN
     l_resource_type := 'RS_GROUP';
     l_request_id    := p_terr_globals.request_id;
     l_worker_id     := p_terr_globals.worker_id;

     OPEN   count_res_proposal;
	FETCH  count_res_proposal INTO   l_res_prop_count;
     CLOSE  count_res_proposal;

     IF l_res_prop_count > 0 THEN
     OPEN   c_get_res_type_count(l_resource_type, l_request_id, l_worker_id);
	FETCH  c_get_res_type_count  INTO   l_res_type_count;
     CLOSE  c_get_res_type_count;
     END IF;

     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_N_ROWS_PROCESSED  || l_res_type_count);
     IF l_res_type_count > 0 THEN
     /* Get resources within a resource group */
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
     /** Note
	      Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
         because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
     **/

    		INSERT INTO JTF_TAE_1001_PROP_WINNERS
            (trans_object_id,
             trans_detail_object_id,
             terr_id,
             resource_id,
             resource_type,
             group_id,
             full_access_flag,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             source_id,
             trans_object_type_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             absolute_rank,
             top_level_terr_id,
             num_winners,
             terr_rsc_id,
             role,
             primary_contact_flag,
             person_id,
             org_id,
             worker_id)
        SELECT T.trans_object_id,
               T.trans_detail_object_id,
               T.terr_id,
               J.resource_id,
               DECODE(J.resource_category,'PARTY','RS_PARTY',
                                          'PARTNER','RS_PARTNER',
                                          'EMPLOYEE','RS_EMPLOYEE','UNKNOWN'),
               J.group_id,
               T.full_access_flag,
               T.request_id,
               T.program_application_id,
               T.program_id,
               T.program_update_date,
               T.source_id,
               T.trans_object_type_id,
               SYSDATE,
               T.last_updated_by,
               SYSDATE,
               T.created_by,
               T.last_update_login,
               T.absolute_rank,
               T.top_level_terr_id,
               T.num_winners,
               T.terr_rsc_id,
               T.role,
               T.primary_contact_flag,
               J.person_id,
               T.org_id,
               T.worker_id
          FROM
                  JTF_TAE_1001_PROP_WINNERS t,
                  (
                   SELECT MIN(m.resource_id) resource_id,
                          res.CATEGORY resource_category,
                          m.group_id group_id, MIN(res.source_id) person_id
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
                   AND   SYSDATE BETWEEN rr.start_date_active AND
                                         NVL(rr.end_date_active,SYSDATE)
                   AND   r.role_type_code IN
                         ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                   AND   r.active_flag = 'Y'
                   AND   res.resource_id = m.resource_id
                   AND   res.category IN ('EMPLOYEE','PARTY','PARTNER')
                   GROUP BY m.group_member_id, m.resource_id, m.person_id,
                            m.group_id, res.category) j
          WHERE j.group_id = t.resource_id
	       AND   t.request_id = l_request_id
	       AND   t.worker_id  = l_worker_id
          AND   t.resource_type = 'RS_GROUP'
          AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_PROP_WINNERS rt1
                          WHERE rt1.resource_id = j.resource_id
                          AND   NVL(rt1.group_id,-1) = NVL(j.group_id,-1)
                          AND   rt1.request_id = t.request_id
                          AND   rt1.worker_id =  t.worker_id
                          AND   rt1.trans_object_id = t.trans_object_id
			  AND   NVL(rt1.trans_detail_object_id,-1) = NVL(t.trans_detail_object_id,-1));

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);

        COMMIT;
     END IF;   /* if l_res_type_count > 0 */

EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END EXPLODE_GROUPS_PROPOSALS;
/************************** End Explode Groups PROPOSALS ******************/

/************************** Start Set Accounts Team Leader *****************/

/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Winners table records are striped by worker id.
 | All the logic pertains to what happens within a single worker.
 | Get a list of resources who are marked as full access in winners but are
 | not marked as full access in accesses (CURSOR team_leader).
 | Loop within the worker for sets of records within winners ---?
 | Bulk collect from team_leader cursor into array.
 | Break up the array into batches based on global var bulk_size.
 | For each batch:
 | Try 3 times to bulk update acesses
 | if all 3 attempts fail because of deadlock:
 | Update on record at a time.
 +-------------------------------------------------------------------------*/

PROCEDURE SET_TEAM_LEAD_PROPOSALS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list    is TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;

    l_proposal_id      num_list;
    l_resource_id    num_list;
    l_resource_group_id   num_list;
    l_faf              faf_list;
    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;
    l_MAX_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts         NUMBER := 0;

	CURSOR team_leader(c_worker_id number) IS
	    SELECT  A.proposal_id, -- The use nested loop hint is removed in ACCOUNTS ONLY..
		   A.resource_id,
		   A.resource_group_id,
		   decode(NVL(WIN.full_access_flag,'N'),'Y','FULL','READ') full_access_flag
	    FROM PRP_PROPOSAL_ACCESSES A,
		 JTF_TAE_1001_PROP_WINNERS WIN
	    WHERE  NVL(A.ACCESS_LEVEL,'N') <> decode(NVL(WIN.full_access_flag,'N'),'Y','FULL','READ')
	    AND   WIN.SOURCE_ID = -1001
	    AND   WIN.worker_id = c_worker_id
	    AND   WIN.resource_type IN ('RS_EMPLOYEE','RS_PARTNER','RS_PARTY')
	    AND   WIN.trans_object_id = A.proposal_id
	    AND   WIN.resource_id     = A.resource_id
	    AND   NVL(WIN.group_id,-777) = NVL(A.resource_group_id,-777)
	    GROUP BY A.proposal_id,
		     A.resource_id,
		     A.resource_group_id,
		     WIN.full_access_flag;


BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
		IF (l_limit_flag) THEN EXIT; END IF;

		l_proposal_id.DELETE;
		l_resource_id.DELETE;
		l_resource_group_id.DELETE;
		l_faf.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'LOOPCOUNT :- ' || l_loop_count);

		--------------------------------
		OPEN team_leader(l_worker_id);
		    FETCH team_leader BULK COLLECT INTO
			      l_proposal_id, l_resource_id, l_resource_group_id, l_faf
		    LIMIT l_MAX_fetches;
		CLOSE team_leader;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_proposal_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

		IF  l_proposal_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_proposal_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_proposal_id.LAST THEN
					l_last := l_proposal_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i IN l_first .. l_last
							UPDATE  PRP_PROPOSAL_ACCESSES ACC
							SET	object_version_number =  NVL(object_version_number,0) + 1,
								 ACC.last_update_date = SYSDATE,
								 ACC.last_updated_by = p_terr_globals.user_id,
								 ACC.last_update_login = p_terr_globals.last_update_login,
								 ACC.ACCESS_LEVEL = l_faf(i)
							WHERE    ACC.proposal_id    = l_proposal_id(i)
							 AND	 ACC.resource_id  = l_resource_id(i)
							 AND	 NVL(ACC.resource_group_id,-777) = NVL(l_resource_group_id(i),-777);
						COMMIT;
						l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS ||AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-'|| l_last);
					 EXCEPTION
					 WHEN DEADLOCK_DETECTED THEN
						BEGIN
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_DEADLOCK ||l_attempts);
							ROLLBACK;
							l_attempts := l_attempts +1;
							IF l_attempts = 3 THEN
								FOR i IN l_first .. l_last
								LOOP
									BEGIN
										UPDATE  PRP_PROPOSAL_ACCESSES ACC
										SET	object_version_number =  NVL(object_version_number,0) + 1,
											 ACC.last_update_date = SYSDATE,
											 ACC.last_updated_by = p_terr_globals.user_id,
											 ACC.last_update_login = p_terr_globals.last_update_login,
											 ACC.ACCESS_LEVEL = l_faf(i)
										WHERE    ACC.proposal_id    = l_proposal_id(i)
										 AND	 ACC.resource_id  = l_resource_id(i)
										 AND	 NVL(ACC.resource_group_id,-777) = NVL(l_resource_group_id(i),-777);
									EXCEPTION
									WHEN OTHERS THEN
										AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
										AS_GAR.LOG('PROPOSAL_ID/RESOURCE_id/SALESGROUP_ID/ORG_ID - ' || l_proposal_id(i) || '/' || l_resource_id(i) || '/' || l_resource_group_id(i));
									END;
								END LOOP; -- for each record individually
								COMMIT;
							END IF;
						END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD, SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
					END;
				END LOOP; -- loop for 3 attempts
				/* For the next batch of records by bulk_size */
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_proposal_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; -- loop for more records within the bulk_size
		END IF; --l_proposal_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_N_ROWS_PROCESSED || l_proposal_id.COUNT);
	END LOOP; -- loop for more bulk_size fetches
	l_proposal_id.DELETE;
	l_resource_id.DELETE;
	l_resource_group_id.DELETE;
	l_faf.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END SET_TEAM_LEAD_PROPOSALS;

/************************** End Set PROPOSALS Team Leader *****************/

/************************** Start Insert Into Entity Accesses*************/

PROCEDURE INSERT_ACCESSES_PROPOSALS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    TYPE num_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list       is TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;

    l_proposal_id       num_id_list;
    l_resource_id       num_id_list;
    l_resource_group_id num_id_list;
    l_faf               faf_list;
    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;

    l_MAX_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts         NUMBER := 0;
    l_src_exists    VARCHAR2(1);


	CURSOR ins_acc2(c_worker_id number) IS
	SELECT W.resource_id,
	       W.group_id grp_id,
	       W.trans_object_id proposal_id,
	       DECODE(MAX(W.full_access_flag),'Y','FULL','READ') faf
	FROM  JTF_TAE_1001_PROP_WINNERS W
	WHERE W.source_id = -1001
	AND W.worker_id = c_worker_id
	AND W.resource_type = 'RS_EMPLOYEE'
	AND W.group_id IS NOT NULL --- Added to work around the JTY functionality which allows group_id to be NULL during setup of resources.
	GROUP BY W.trans_object_id,
		 W.resource_id,
		 W.group_id;
BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Check to see if the profile "OS: proposal Sales Team Default Role Type" is
 | set for atleast one user.
 | If it is set, then open the cursor to get all the records that need to be
 | inserted into accesses along with the default role for every user and bulk
 | collect into an array.
 | If it not set, then do the same, except that in this case, the default role
 | will always be null.
 | Try bulk inserting into accesses. If this fails, insert records one by one.
 |
 +-------------------------------------------------------------------------*/
 	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;

	OPEN ins_acc2(l_worker_id); -- Open the null salesforce role code cursor

	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
	        l_proposal_id.DELETE;
		l_resource_id.DELETE;
                l_resource_group_id.DELETE;
                l_faf.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'LOOPCOUNT :- ' || l_loop_count);

		FETCH ins_acc2 BULK COLLECT INTO
			     l_resource_id,l_resource_group_id,l_proposal_id,l_faf
			LIMIT l_MAX_fetches;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;

		IF l_proposal_id.count < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_proposal_id.count > 0 THEN
			l_flag := TRUE;
			l_first := l_proposal_id.first;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_proposal_id.last THEN
				   l_last := l_proposal_id.last;
				END IF;
				BEGIN
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' to '||l_last);
					FORALL i IN l_first .. l_last
						INSERT INTO PRP_PROPOSAL_ACCESSES
						(
						     proposal_access_id
						     ,object_version_number
						     ,proposal_id
						     ,resource_id
						     ,access_level
						     ,resource_group_id
						     ,keep_flag
						     ,created_by
						     ,creation_date
						     ,last_updated_by
						     ,last_update_date
						     ,last_update_login
						   )
						   (
						   SELECT prp_proposal_accesses_s1.nextval  -- Check With Sequence
						       ,1
						       ,l_proposal_id(i)
						       ,l_resource_id(i)
						       ,l_faf(i)
						       ,l_resource_group_id(i)
						       ,'N'
						       ,p_terr_globals.user_id
						       ,SYSDATE
						       ,p_terr_globals.user_id
						       ,SYSDATE
						       ,p_terr_globals.last_update_login
						    FROM  DUAL
						    WHERE NOT EXISTS ( SELECT  'X'
								       FROM PRP_PROPOSAL_ACCESSES AA
								       WHERE AA.proposal_id = l_proposal_id(i)
								       AND AA.resource_id   = l_resource_id(i)
								       AND NVL(AA.resource_group_id,-777)= NVL(l_resource_group_id(i),-777)
								      )
						 );
						 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
				EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
					 FOR i IN l_first .. l_last LOOP
						BEGIN
							INSERT INTO PRP_PROPOSAL_ACCESSES
							(
							     proposal_access_id
							     ,object_version_number
							     ,proposal_id
							     ,resource_id
							     ,access_level
							     ,resource_group_id
							     ,keep_flag
							     ,created_by
							     ,creation_date
							     ,last_updated_by
							     ,last_update_date
							     ,last_update_login
							   )
							   (
							   SELECT prp_proposal_accesses_s1.nextval  -- Check With Sequence
							       ,1
							       ,l_proposal_id(i)
							       ,l_resource_id(i)
							       ,l_faf(i)
							       ,l_resource_group_id(i)
							       ,'N'
							       ,p_terr_globals.user_id
							       ,SYSDATE
							       ,p_terr_globals.user_id
							       ,SYSDATE
							       ,p_terr_globals.last_update_login
							    FROM  DUAL
							    WHERE NOT EXISTS ( SELECT  'X'
									       FROM PRP_PROPOSAL_ACCESSES AA
									       WHERE AA.proposal_id = l_proposal_id(i)
									       AND AA.resource_id   = l_resource_id(i)
									       AND NVL(AA.resource_group_id,-777)= NVL(l_resource_group_id(i),-777)
									      )
							 );
						EXCEPTION
						WHEN OTHERS THEN
							NULL;
						END;
					END LOOP; /* loop for DUP_VAL_ON_INDEX individual insert */
					COMMIT;
				WHEN OTHERS THEN
					AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS, SQLERRM, TO_CHAR(SQLCODE));
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
					x_return_status := FND_API.G_RET_STS_ERROR;
					RAISE;
				END;
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_proposal_id.last THEN
					l_flag := FALSE;
				END IF;
			END LOOP; /* l_flag loop */
		END IF; --l_proposal_id.count > 0
	END LOOP; -- loop for more bulk_size fetches
        l_proposal_id.DELETE;
	l_resource_id.DELETE;
        l_resource_group_id.DELETE;
        l_faf.DELETE;
	IF ins_acc2%ISOPEN THEN CLOSE ins_acc2; END IF;
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_acc2%ISOPEN THEN CLOSE ins_acc2; END IF;
      RAISE;
END INSERT_ACCESSES_PROPOSALS;

/************************** End Insert Into Entity Accesses*************/

/************************** Start Insert Into Terr Accesses*************/

PROCEDURE INSERT_TERR_ACCESSES_PROPOSALS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
	TYPE num_id_list        IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

	l_proposal_id      num_id_list;
	l_resource_id    num_id_list;
	l_resource_group_id   num_id_list;

	l_var     NUMBER;
        l_limit_flag    BOOLEAN := FALSE;
	l_worker_id     NUMBER;
	l_MAX_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	l_flag    BOOLEAN;
	l_first   NUMBER;
	l_last    NUMBER;
	l_terr_id   num_id_list;

	CURSOR ins_tacc(c_worker_id number) IS
	SELECT w.terr_id
	       ,w.trans_object_id
	       ,w.resource_id
	       ,w.group_id
	 FROM JTF_TAE_1001_PROP_WINNERS W
	 WHERE  W.source_id = -1001
	 AND    W.worker_id = c_worker_id
	 AND    W.resource_type = 'RS_EMPLOYEE'
  	 AND W.group_id IS NOT NULL --- Added to work around the JTY functionality which allows group_id to be NULL during setup of resources.
	 GROUP BY W.terr_id,
		  W.trans_object_id,
		  W.resource_id,
		  W.group_id;


BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Almost the same as accesses, except the insertion is into prp_territory_accesses
 | and there is no involvement of role.
 |
 +-------------------------------------------------------------------------*/
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id := p_terr_globals.worker_id;
	l_var       := p_terr_globals.bulk_size;
	OPEN ins_tacc(l_worker_id);
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		EXIT WHEN ins_tacc%NOTFOUND;
		l_loop_count := l_loop_count + 1;
		l_proposal_id.DELETE;
		l_resource_id.DELETE;
		l_resource_group_id.DELETE;
		l_terr_id.DELETE;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'LOOPCOUNT :- ' || l_loop_count);
		BEGIN

			FETCH ins_tacc BULK COLLECT INTO l_terr_id,
			l_proposal_id, l_resource_id, l_resource_group_id
			LIMIT l_MAX_fetches;
			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF l_terr_id.COUNT < l_MAX_fetches THEN l_limit_flag := TRUE; END IF;
			IF  l_proposal_id.COUNT > 0 THEN
				l_flag := TRUE;
				l_first := l_proposal_id.first;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_proposal_id.last THEN
						l_last := l_proposal_id.last;
					END IF;
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						FORALL i IN l_first .. l_last
						INSERT INTO PRP_TERRITORY_ACCESSES
						( proposal_access_id
						  ,territory_id
						  ,object_version_number
						  ,created_by
						  ,creation_date
						  ,last_updated_by
						  ,last_update_date
						  ,last_update_login
						  ,program_id
						  ,program_login_id
						  ,program_application_id
						  ,request_id
						  ,program_update_date

						)
						(
							SELECT
							 V.acc_id,
							 l_terr_id(i),
							 1,
							 p_terr_globals.user_id,
							 SYSDATE,
							 p_terr_globals.user_id,
							 SYSDATE,
							 p_terr_globals.last_update_login,
							 p_terr_globals.prog_id,
							 p_terr_globals.prog_id,
							 p_terr_globals.prog_appl_id,
							 p_terr_globals.request_id,
							 SYSDATE
							 FROM
							( SELECT DISTINCT a.proposal_access_id acc_id
							     FROM PRP_PROPOSAL_ACCESSES A
							     WHERE   A.proposal_id=l_proposal_id(i)
							     AND   NVL(A.resource_group_id,-777)=NVL(l_resource_group_id(i),-777)
							     AND   A.resource_id=l_resource_id(i)
							     AND NOT EXISTS
									(SELECT 'X'
									FROM PRP_TERRITORY_ACCESSES AST
									WHERE AST.proposal_access_id = A.proposal_access_id
									  AND AST.territory_id = l_terr_id(i))
							) V
						);
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
					EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						FOR i IN l_first .. l_last LOOP
							BEGIN
								INSERT INTO PRP_TERRITORY_ACCESSES
								( proposal_access_id
								  ,territory_id
								  ,object_version_number
								  ,created_by
								  ,creation_date
								  ,last_updated_by
								  ,last_update_date
								  ,last_update_login
								  ,program_id
								  ,program_login_id
								  ,program_application_id
								  ,request_id
								  ,program_update_date

								)
								(
									SELECT
									 V.acc_id,
									 l_terr_id(i),
									 1,
									 p_terr_globals.user_id,
									 SYSDATE,
									 p_terr_globals.user_id,
									 SYSDATE,
									 p_terr_globals.last_update_login,
									 p_terr_globals.prog_id,
									 p_terr_globals.prog_id,
									 p_terr_globals.prog_appl_id,
									 p_terr_globals.request_id,
									 SYSDATE
									 FROM
									( SELECT DISTINCT a.proposal_access_id acc_id
									     FROM PRP_PROPOSAL_ACCESSES A
									     WHERE   A.proposal_id=l_proposal_id(i)
									     AND   NVL(A.resource_group_id,-777)=NVL(l_resource_group_id(i),-777)
									     AND   A.resource_id=l_resource_id(i)
									     AND NOT EXISTS
											(SELECT 'X'
											FROM PRP_TERRITORY_ACCESSES AST
											WHERE AST.proposal_access_id = A.proposal_access_id
											  AND AST.territory_id = l_terr_id(i))
									) V
								);
							EXCEPTION
								WHEN Others THEN
									NULL;
							END;
						END LOOP;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
					WHEN Others THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_BULK_INS, SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						IF ins_tacc%ISOPEN THEN CLOSE ins_tacc; END IF;
						RAISE;
					END;
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_proposal_id.last THEN
						l_flag := FALSE;
					END IF;
				END LOOP;
			END IF; --l_proposal_id.count > 0
		EXCEPTION
		WHEN Others THEN
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC , SQLERRM, TO_CHAR(SQLCODE));
			IF ins_tacc%ISOPEN THEN CLOSE ins_tacc; END IF;
				x_errbuf  := SQLERRM;
				x_retcode := SQLCODE;
				x_return_status := FND_API.G_RET_STS_ERROR;
				RAISE;
		END;
	END LOOP; -- end loop for insert into territory accesses
	l_proposal_id.DELETE;
	l_resource_id.DELETE;
	l_resource_group_id.DELETE;
	l_terr_id.DELETE;
	IF ins_tacc%ISOPEN THEN CLOSE ins_tacc; END IF;
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_tacc%ISOPEN THEN CLOSE ins_tacc; END IF;
      RAISE;
END INSERT_TERR_ACCESSES_PROPOSALS;

/************************** End Insert Into Terr Accesses*************/

/**************************   Start Proposal Cleanup ***********************/

PROCEDURE Perform_Proposal_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

	TYPE num_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_proposal_id              num_id_list;


	l_flag          BOOLEAN;
	l_first         NUMBER;
	l_last          NUMBER;
	l_var           NUMBER;
	l_attempts      NUMBER := 0;

	l_worker_id     NUMBER;

	l_del_flag      BOOLEAN:=FALSE;
	l_limit_flag    BOOLEAN := FALSE;
	l_MAX_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	G_NUM_REC  CONSTANT  NUMBER:=10000;
	G_DEL_REC  CONSTANT  NUMBER:=10001;



	CURSOR del_acct_totalmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_PROP_TRANS
		WHERE worker_id=c_worker_id;

	CURSOR del_acct_newmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_PROP_NM_TRANS
		WHERE worker_id=c_worker_id;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id   := p_terr_globals.worker_id;
	l_var      := p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;

	IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
		OPEN del_acct_totalmode(l_worker_id);
	ELSE
		OPEN del_acct_newmode(l_worker_id);
	END IF;
	LOOP --{L1
		IF (l_limit_flag) THEN EXIT; END IF;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || 'LOOPCOUNT :- ' ||l_loop_count);
		BEGIN
			IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
				EXIT WHEN del_acct_totalmode%NOTFOUND;
				FETCH del_acct_totalmode BULK COLLECT INTO l_proposal_id
				LIMIT l_MAX_fetches;
			ELSE
				EXIT WHEN del_acct_newmode%NOTFOUND;
				FETCH del_acct_newmode BULK COLLECT INTO l_proposal_id
				LIMIT l_MAX_fetches;
			END IF;
			-- Initialize variables (Ist Init)
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;
			l_attempts := 1;

			IF l_proposal_id.COUNT < l_MAX_fetches THEN
				l_limit_flag := TRUE;
			END IF;

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_START);
			IF l_proposal_id.count > 0 THEN --{I1
				l_flag  := TRUE;
				l_first := l_proposal_id.first;
				l_last  := l_first + l_var;
				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED ||
								 l_proposal_id.FIRST || '-' ||
								 l_proposal_id.LAST);
					IF l_last > l_proposal_id.LAST THEN
						l_last := l_proposal_id.LAST;
					END IF;
					l_del_flag  := FALSE;
					l_attempts  := 1;
					LOOP  --{L3 to update only 10k record at a time
						IF (l_del_flag) THEN EXIT; END IF;
						l_del_flag := FALSE;
						WHILE l_attempts < 3 LOOP --{L4
							BEGIN
								AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_UPD || AS_GAR.G_START);
								FORALL i in l_first..l_last
									DELETE  PRP_PROPOSAL_ACCESSES ACC
									WHERE ACC.PROPOSAL_ID=l_proposal_id(i)
									AND ACC.KEEP_FLAG = 'N'
									AND NOT EXISTS (SELECT  'X'
									  FROM JTF_TAE_1001_PROP_WINNERS W
									  WHERE  W.TRANS_OBJECT_ID = ACC.PROPOSAL_ID
									  AND  W.WORKER_ID = l_worker_id
									  AND  W.RESOURCE_ID = ACC.RESOURCE_ID
									  AND  NVL(W.GROUP_ID,-777)=NVL(ACC.RESOURCE_GROUP_ID,-777))
									AND ROWNUM < G_DEL_REC;
								COMMIT;
								l_attempts := 3;
								IF l_proposal_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
							EXCEPTION
							WHEN deadlock_detected THEN
							BEGIN --{I2
								AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_UPD || AS_GAR.G_DEADLOCK || l_attempts);
								ROLLBACK;
								l_attempts := l_attempts +1;
								IF l_attempts = 3 THEN
									FOR i IN l_first .. l_last LOOP --{L5
										BEGIN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_UPD || AS_GAR.G_START);
											DELETE  PRP_PROPOSAL_ACCESSES ACC
											WHERE ACC.PROPOSAL_ID=l_proposal_id(i)
											AND ACC.KEEP_FLAG = 'N'
											AND NOT EXISTS (SELECT  'X'
											  FROM JTF_TAE_1001_PROP_WINNERS W
											  WHERE  W.TRANS_OBJECT_ID = ACC.PROPOSAL_ID
											  AND  W.WORKER_ID = l_worker_id
											  AND  W.RESOURCE_ID = ACC.RESOURCE_ID
											  AND  NVL(W.GROUP_ID,-777)=NVL(ACC.RESOURCE_GROUP_ID,-777));
											COMMIT;
										END;
									END LOOP; --}L5
									COMMIT;
									l_del_flag := TRUE;
								END IF;
							END; --}I2 end of deadlock exception
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
								IF del_acct_totalmode%ISOPEN THEN CLOSE del_acct_totalmode; END IF;
								IF del_acct_newmode%ISOPEN THEN CLOSE del_acct_newmode; END IF;
								x_errbuf  := SQLERRM;
								x_retcode := SQLCODE;
								x_return_status := FND_API.G_RET_STS_ERROR;
								RAISE;
							END;
						 END LOOP;  --}L4  l_attempts loop 3 trys
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-' || l_last);
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_proposal_id.LAST THEN
					    l_flag := FALSE;
					END IF;
				END LOOP;  --}L2  while l_flag loop (10K cust loop)
			END IF;--}I1
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_END);
			COMMIT;
		EXCEPTION
		WHEN Others THEN
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
			IF del_acct_totalmode%ISOPEN THEN CLOSE del_acct_totalmode; END IF;
			IF del_acct_newmode%ISOPEN THEN CLOSE del_acct_newmode; END IF;
			x_errbuf  := SQLERRM;
			x_retcode := SQLCODE;
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE;
		END;
	END LOOP;--}L1
	IF del_acct_totalmode%ISOPEN THEN CLOSE del_acct_totalmode; END IF;
	IF del_acct_newmode%ISOPEN THEN CLOSE del_acct_newmode; END IF;
EXCEPTION
WHEN OTHERS THEN
    AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
    x_errbuf  := SQLERRM;
    x_retcode := SQLCODE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE;
END Perform_Proposal_Cleanup;

/**************************   End proposal Cleanup ***********************/

END AS_GAR_PROPOSALS_PUB;

/
