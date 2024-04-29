--------------------------------------------------------
--  DDL for Package Body AS_GAR_QOT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_GAR_QOT_PUB" AS
/* $Header: asxgrqtb.pls 120.22 2006/02/02 21:30 amagupta noship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR_QOT_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--    --------
--    This package contains procedures to accomplish each of the following
--    tasks:
--    1: Call the JTY API to process data from JTY trans tables and
--       populate JTY winners.
--    2: Merge and insert records from winners into AS_ACCESSES_ALL_ALL
--    3: Soft Delete unwanted records from AS_ACCESSES_ALL_ALL
--    4: Lead Owner Assignment
--
---------------------------------------------------------------------------
/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_BUSINESS_EVENT  CONSTANT VARCHAR2(60) := 'oracle.apps.as.tap.batch_mode';
  DEADLOCK_DETECTED EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
  G_ENTITY CONSTANT VARCHAR2(10) := 'GAR::QOT::';
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
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    P_percent_analyzed  IN  NUMBER )
  IS
    l_terr_globals   AS_GAR.TERR_GLOBALS;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_errbuf         VARCHAR2(4000);
    l_retcode        VARCHAR2(255);
    l_sub_exist      VARCHAR2(1);
    l_return_status  VARCHAR2(1);
    l_target_type    VARCHAR2(15);
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

    /* This inserts into Oppty winners */
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);
    JTY_ASSIGN_BULK_PUB.GET_WINNERS
    ( p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.G_TRUE,
      p_source_id             => -1001,
      p_trans_id	      => -1105,
      P_PROGRAM_NAME          => 'SALES/QUOTE PROGRAM',
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

    --Commenting the following call since Real Time API is not supporting other than rs_employee
    -- Explode GROUPS if any inside winners
/*    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_START);
    AS_GAR_QOT_PUB.EXPLODE_GROUPS_QOT(
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
    AS_GAR_QOT_PUB.EXPLODE_TEAMS_QOT(
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
*/
    -- Set team leader for Quotes
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_START);
    AS_GAR_QOT_PUB.SET_TEAM_LEAD_QOT(
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

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || 'UPDATE FAF::' || AS_GAR.G_START);
    AS_GAR_QOT_PUB.SET_FAF_QOT(
        x_errbuf        => l_errbuf,
        x_retcode       => l_retcode,
        p_terr_globals  => l_terr_globals,
        x_return_status => l_return_status);

    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || 'UPDATE FAF::' || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || 'UPDATE FAF::' || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || 'UPDATE FAF::', l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

	 -- Insert into Qot Accesses from Winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
    AS_GAR_QOT_PUB.INSERT_ACCESSES_QOT(
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
    AS_GAR_QOT_PUB.INSERT_TERR_ACCESSES_QOT(
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

    -- Remove records in access table that are not qualified
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_START);
    AS_GAR_QOT_PUB.PERFORM_QOT_CLEANUP(
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
-- Quote Owner assignment
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_START);
    AS_GAR_QOT_PUB.ASSIGN_QOT_OWNER(
              x_errbuf        => l_errbuf,
              x_retcode       => l_retcode,
              p_terr_globals  => l_terr_globals,
              x_return_status => l_return_status);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    AS_GAR.LOG(G_ENTITY || l_proc || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END GAR_WRAPPER;

/**************************   End GAR Wrapper *****************************/

/************************** Start Explode Teams Opptys ******************/
PROCEDURE EXPLODE_TEAMS_QOT(
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
l_res_quot_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_QUOTE_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;

CURSOR count_res_quotes
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_TEAM'
AND acc.access_type = 'QUOTE'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;

BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_request_id    := p_terr_globals.request_id;
   l_worker_id     := p_terr_globals.worker_id;
   l_resource_type := 'RS_TEAM';

   OPEN   count_res_quotes;
	FETCH  count_res_quotes INTO   l_res_quot_count;
   CLOSE  count_res_quotes;

   IF l_res_quot_count > 0 THEN
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
	       INSERT INTO JTF_TAE_1001_QUOTE_WINNERS
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
             ROLE,
             ROLE_ID,
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
               T.ROLE,
               T.ROLE_ID,
               T.primary_contact_flag,
               J.person_id,
               T.org_id,
               T.worker_id
        FROM
               JTF_TAE_1001_QUOTE_WINNERS T,
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
                        AND    res.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
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
                AND   tres.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
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
                       AND   tres.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
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
                AND   res.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
                AND   jtm.group_id = g.group_id
                GROUP BY m.resource_id, m.person_id, jtm.team_id, res.CATEGORY) J
     WHERE j.team_id = t.resource_id
        AND   t.request_id = l_request_id
        AND   t.worker_id =  l_worker_id
        AND   t.resource_type = 'RS_TEAM'
        AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_QUOTE_WINNERS rt1
                        WHERE rt1.resource_id = j.resource_id
                        AND   NVL(rt1.group_id,-1) = NVL(j.group_id,-1)
                        AND   rt1.request_id = t.request_id
                        AND   rt1.worker_id =  t.worker_id
                        AND   rt1.trans_object_id = t.trans_object_id
                        AND   NVL(rt1.trans_detail_object_id,-1) = NVL(t.trans_detail_object_id,-1));

	     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
	     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);


        COMMIT;

     END IF;  /* if l_res_type_count > 0 */
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END EXPLODE_TEAMS_QOT;
/************************** End Explode Teams Quotes ******************/

/************************** Start Explode Groups Quotes ******************/
PROCEDURE EXPLODE_GROUPS_QOT(
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
l_res_quot_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_QUOTE_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;


CURSOR count_res_quotes
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_GROUP'
AND acc.access_type = 'QUOTE'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id ;

BEGIN
     l_resource_type := 'RS_GROUP';
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_request_id    := p_terr_globals.request_id;
     l_worker_id     := p_terr_globals.worker_id;

     OPEN   count_res_quotes;
	FETCH  count_res_quotes INTO   l_res_quot_count;
     CLOSE  count_res_quotes;

     IF l_res_quot_count > 0 THEN
     OPEN   c_get_res_type_count(l_resource_type, l_request_id, l_worker_id);
     FETCH  c_get_res_type_count  INTO  l_res_type_count;
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

    		INSERT INTO JTF_TAE_1001_QUOTE_WINNERS
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
             ROLE,
	     ROLE_ID,
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
               T.ROLE,
               T.ROLE_ID,
               T.primary_contact_flag,
               J.person_id,
               T.org_id,
               T.worker_id
          FROM
                  JTF_TAE_1001_QUOTE_WINNERS t,
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
                   AND   SYSDATE BETWEEN rr.start_date_active
				   AND   NVL(rr.end_date_active,SYSDATE)
                   AND   r.role_type_code IN
                         ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                   AND   r.active_flag = 'Y'
                   AND   res.resource_id = m.resource_id
                   AND   res.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
                   GROUP BY m.group_member_id, m.resource_id, m.person_id,
                            m.group_id, res.CATEGORY) j
          WHERE j.group_id = t.resource_id
	      AND   t.request_id = l_request_id
	      AND   t.worker_id  = l_worker_id
          AND   t.resource_type = 'RS_GROUP'
          AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_QUOTE_WINNERS rt1
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
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END EXPLODE_GROUPS_QOT;
/************************** End Explode Groups Quotes ******************/

/************************** Start Set Quotes Team Leader *****************/

/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | The name of the procedure is a misnomer. The name is only for maintaining
 | consistency. The functionality achieved is as follows:
 | Get all records which are there in quote accesses table and
 | in winners (the equi join will ensure this) . Out of these
 | records get records which do not exist with same info
 | for role,group,full access flag , terr_id in the winners
 | These records are the candidates to be merged.
 | The NOT EXISTS is written into this cursor rather than
 | the merge update as this cursor should a diMINishing one
 | when it is reopened repeatedly.
 +-------------------------------------------------------------------------*/

PROCEDURE SET_TEAM_LEAD_QOT(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list   is TABLE of NUMBER INDEX BY BINARY_INTEGER;



    l_quote_number_id   num_list;
    l_resource_id       num_list;
    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;
    l_MAX_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts    NUMBER := 0;

	CURSOR merge_records(c_worker_id number) IS
        SELECT DISTINCT
               A.quote_number , A.resource_id
        FROM   JTF_TAE_1001_QUOTE_WINNERS WIN,
               ASO_QUOTE_ACCESSES A
        WHERE  WIN.trans_object_id = A.quote_number
        AND    WIN.source_id       = -1001
        AND    WIN.resource_id     = A.RESOURCE_ID
        AND    WIN.worker_id       = c_worker_id
        AND    WIN.resource_type   = 'RS_EMPLOYEE'
        AND    NVL(A.keep_flag,'N')  <>   'Y'
    	AND    (NVL(win.group_id,-777) <> NVL(A.resource_grp_id,-777)
	 OR     NVL(win.role_id,-777) <> NVL(A.role_id,-777))
	AND NOT EXISTS
	(SELECT 'X'
        FROM    JTF_TAE_1001_QUOTE_WINNERS WIN1
        WHERE  WIN1.trans_object_id = A.quote_number
        AND    WIN1.source_id       = -1001
        AND    WIN1.resource_id     = A.RESOURCE_ID
        AND    WIN1.worker_id       = c_worker_id
        AND    WIN1.resource_type   = 'RS_EMPLOYEE'
        AND    NVL(A.keep_flag,'N')  <>   'Y'
	AND    NVL(WIN1.group_id,-777) = NVL(A.resource_grp_id,-777)
    	AND    NVL(WIN1.role_id,-777)  = NVL(A.role_id,-777))
        ORDER BY quote_number;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
		IF (l_limit_flag) THEN EXIT; END IF;
		l_resource_id.DELETE;
		l_quote_number_id.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'LOOPCOUNT :- ' || l_loop_count);

		--------------------------------
		OPEN merge_records(l_worker_id);
		    FETCH merge_records BULK COLLECT INTO
			      l_quote_number_id, l_resource_id LIMIT l_MAX_fetches;
		    CLOSE merge_records;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_quote_number_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

		IF  l_quote_number_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_quote_number_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_quote_number_id.LAST THEN
					l_last := l_quote_number_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i IN l_first .. l_last
							UPDATE ASO_QUOTE_ACCESSES A
							SET  (update_access_flag ,
								resource_grp_id ,
								role_id ,
								territory_id  )
							= (
								SELECT MAX(W.full_access_flag ),MIN( W.group_id),MIN(w.role_id) ,MIN(W.terr_id)
								FROM JTF_TAE_1001_QUOTE_WINNERS W
								WHERE trans_object_id = l_quote_number_id(I)
								AND resource_id       = l_resource_id(i)
								GROUP BY trans_object_id,resource_id
							)
							WHERE quote_number = l_quote_number_id(I)
							AND   resource_id  = l_resource_id(i) ;
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
										UPDATE ASO_QUOTE_ACCESSES A
										SET  (update_access_flag ,
											resource_grp_id ,
											role_id ,
											territory_id  )
										= (
											SELECT MAX(W.full_access_flag ),MIN( W.group_id),MIN(w.role_id) ,MIN(W.terr_id)
											FROM JTF_TAE_1001_QUOTE_WINNERS W
											WHERE trans_object_id = l_quote_number_id(I)
											AND   resource_id       = l_resource_id(i)
											GROUP BY trans_object_id,resource_id
										)
										WHERE quote_number = l_quote_number_id(I)
										AND   resource_id  = l_resource_id(i) ;
									EXCEPTION
									WHEN OTHERS THEN
										AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
										AS_GAR.LOG('QUOTE_NUMBER/RESOURCE_ID - ' || l_quote_number_id(i) || '/' || l_resource_id(i));
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
						RAISE;
					END;
				END LOOP; -- loop for 3 attempts
				/* For the next batch of records by bulk_size */
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_quote_number_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; -- loop for more records within the bulk_size
		END IF; --l_quote_number_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_N_ROWS_PROCESSED || l_quote_number_id.COUNT);
	END LOOP; -- loop for more bulk_size fetches
	l_quote_number_id.DELETE;
	l_resource_id.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END SET_TEAM_LEAD_QOT;

/************************** End Set Quote Team Leader *****************/
/************************** Start Set Full Access Flag *****************/
PROCEDURE SET_FAF_QOT(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list   is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE char_list   is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;

    l_access_id   num_list;
    l_terr_id       num_list;
    l_faf           char_list;
    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;
    l_MAX_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts    NUMBER := 0;

	CURSOR merge_records(c_worker_id number) IS
        SELECT DISTINCT
               A.access_id,WIN.full_access_flag,WIN.terr_id
        FROM   JTF_TAE_1001_QUOTE_WINNERS WIN,
               ASO_QUOTE_ACCESSES A
        WHERE  WIN.trans_object_id = A.quote_number
        AND    WIN.source_id       = -1001
        AND    WIN.resource_id     = A.RESOURCE_ID
        AND    WIN.worker_id       = c_worker_id
        AND    WIN.resource_type   = 'RS_EMPLOYEE'
        AND    NVL(A.keep_flag,'N')  <>   'Y'
    	AND    NVL(WIN.group_id,-777) = NVL(A.resource_grp_id,-777)
	AND    NVL(WIN.role_id,-777) = NVL(A.role_id,-777)
	AND    (WIN.full_access_flag <> A.update_access_flag
	 OR     WIN.terr_id <> A.territory_id)
        ORDER BY access_id;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
		IF (l_limit_flag) THEN EXIT; END IF;
		l_access_id.DELETE;
		l_terr_id.DELETE;
		l_faf.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || 'LOOPCOUNT :- ' || l_loop_count);

		--------------------------------
		OPEN merge_records(l_worker_id);
		    FETCH merge_records BULK COLLECT INTO
			      l_access_id,l_faf, l_terr_id LIMIT l_MAX_fetches;
		CLOSE merge_records;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_access_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

		IF  l_access_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_access_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_access_id.LAST THEN
					l_last := l_access_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i IN l_first .. l_last
							UPDATE ASO_QUOTE_ACCESSES A
							SET  update_access_flag = l_faf(i),
							     territory_id = l_terr_id(i)
							WHERE access_id = l_access_id(i);
						COMMIT;
						l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_BULK_UPD || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-'|| l_last);
					 EXCEPTION
					 WHEN DEADLOCK_DETECTED THEN
						BEGIN
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_DEADLOCK ||l_attempts);
							ROLLBACK;
							l_attempts := l_attempts +1;
							IF l_attempts = 3 THEN
								FOR i IN l_first .. l_last
								LOOP
									BEGIN
										UPDATE ASO_QUOTE_ACCESSES A
										SET  update_access_flag = l_faf(i),
										     territory_id = l_terr_id(i)
										WHERE access_id = l_access_id(i);
									EXCEPTION
									WHEN OTHERS THEN
										AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
										AS_GAR.LOG('ACCESS_ID - ' || l_access_id(i));
									END;
								END LOOP; -- for each record individually
								COMMIT;
							END IF;
						END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_BULK_UPD, SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP; -- loop for 3 attempts
				/* For the next batch of records by bulk_size */
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_access_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; -- loop for more records within the bulk_size
		END IF; --l_quote_number_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::' || AS_GAR.G_N_ROWS_PROCESSED || l_access_id.COUNT);
	END LOOP; -- loop for more bulk_size fetches
	l_access_id.DELETE;
	l_terr_id.DELETE;
	l_faf.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || 'UPDATE FAF::', SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END SET_FAF_QOT;
/************************** End Set Full Access Flag*****************/
/************************** Start Insert Into Entity Accesses*************/

PROCEDURE INSERT_ACCESSES_QOT(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list   IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list    IS TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;


    l_quote_number_id  num_list;
    l_terr_id          num_list;
    l_resource_id      num_list;
    l_sales_group_id   num_list;
    l_person_id        num_list;
    l_role_id          num_list;
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

/*----------------------------------------------------------------------------+
| Slightly different from the others because each resource is allowed only once
| in the sales team. Hence the MIN/MAX etc..
|-----------------------------------------------------------------------------*/
	CURSOR ins_acc(c_worker_id number) IS
	SELECT  W.trans_object_id,
		W.resource_id,
		MIN(w.person_id),
		MIN(W.group_id),
		MIN(W.role_id) ,
		MAX(W.full_access_flag ) faf,
		MIN(W.terr_id)
	FROM  JTF_TAE_1001_QUOTE_WINNERS W
	WHERE    W.resource_type = 'RS_EMPLOYEE'
	AND      W.source_id = -1001
	AND      W.worker_id = c_worker_id
	AND    NOT EXISTS
		(SELECT 'X'
		FROM   aso_quote_accesses A
		WHERE  W.trans_object_id = A.quote_number
		AND  W.resource_id     = a.RESOURCE_ID)
	GROUP BY W.trans_object_id, W.resource_id;

BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Try bulk inserting into accesses. If this fails, insert records one by one.
 |
 +-------------------------------------------------------------------------*/
 	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	OPEN ins_acc(l_worker_id);
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;

		l_quote_number_id.DELETE;
		l_resource_id.DELETE;
		l_person_id.DELETE;
		l_sales_group_id.DELETE;
		l_role_id.DELETE;
		l_faf.DELETE;
		l_terr_id.DELETE;

	    EXIT WHEN ins_acc%NOTFOUND;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'LOOPCOUNT :- ' || l_loop_count);

		FETCH ins_acc BULK COLLECT INTO
			l_quote_number_id,l_resource_id, l_person_id,l_sales_group_id, l_role_id,l_faf,l_terr_id
			LIMIT l_MAX_fetches;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;

		IF l_quote_number_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF      l_quote_number_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_quote_number_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_quote_number_id.LAST THEN
				   l_last := l_quote_number_id.LAST;
				END IF;
				BEGIN
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' to '||l_last);
											FORALL i IN l_first .. l_last
					INSERT INTO ASO_QUOTE_ACCESSES (
						ACCESS_ID,
						QUOTE_NUMBER,
						RESOURCE_ID,
						RESOURCE_GRP_ID,
						CREATED_BY,
						CREATION_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						LAST_UPDATE_DATE,
						REQUEST_ID,
						PROGRAM_APPLICATION_ID,
						PROGRAM_ID,
						PROGRAM_UPDATE_DATE,
						KEEP_FLAG,
						UPDATE_ACCESS_FLAG,
						CREATED_BY_TAP_FLAG,
						TERRITORY_ID,
						TERRITORY_SOURCE_FLAG,
						ROLE_ID
					 ) VALUES (
						ASO_QUOTE_ACCESSES_S.nextval,
						l_quote_number_id(i),
						l_resource_id(i),
						l_sales_group_id(i),
						p_terr_globals.user_id,
						SYSDATE,
						p_terr_globals.user_id,
						p_terr_globals.last_update_login,
						SYSDATE,
						p_terr_globals.request_id,
						p_terr_globals.prog_appl_id,
						p_terr_globals.prog_id,
						SYSDATE,
						'N',
						l_faf(i),
						'Y',
						l_terr_id(i),
						'Y',
						l_role_id(i)
					);
						 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
				EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
					 FOR i IN l_first .. l_last LOOP
						BEGIN
							INSERT INTO ASO_QUOTE_ACCESSES (
								access_id,
								quote_number,
								resource_id,
								resource_grp_id,
								created_by,
								creation_date,
								last_updated_by,
								last_update_login,
								last_update_date,
								request_id,
								program_application_id,
								program_id,
								program_update_date,
								keep_flag,
								update_access_flag,
								created_by_tap_flag,
								territory_id,
								territory_source_flag,
								role_id
							 ) VALUES (
								aso_quote_accesses_s.NEXTVAL,
								l_quote_number_id(i),
								l_resource_id(i),
								l_sales_group_id(i),
								p_terr_globals.user_id,
								SYSDATE,
								p_terr_globals.user_id,
								p_terr_globals.last_update_login,
								SYSDATE,
								p_terr_globals.request_id,
								p_terr_globals.prog_appl_id,
								p_terr_globals.prog_id,
								SYSDATE,
								'N',
								l_faf(i),
								'Y',
								l_terr_id(i),
								'Y',
								l_role_id(i)
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
				IF l_first > l_quote_number_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; /* l_flag loop */
		END IF; --l_quote_number_id.COUNT > 0
	END LOOP; -- loop for more bulk_size fetches
		l_quote_number_id.DELETE;
		l_resource_id.DELETE;
		l_person_id.DELETE;
		l_sales_group_id.DELETE;
		l_role_id.DELETE;
		l_faf.DELETE;
		l_terr_id.DELETE;
	IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;
      RAISE;
END INSERT_ACCESSES_QOT;

/************************** End Insert Into Entity Accesses*************/
/************************** Start Insert Into Quote Terr Accesses*************/

PROCEDURE INSERT_TERR_ACCESSES_QOT(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
	TYPE num_list        IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_terr_id          num_list;
	l_quote_number_id  num_list;
	l_resource_id      num_list;


	l_var     NUMBER;
	l_limit_flag    BOOLEAN := FALSE;
	l_worker_id     NUMBER;
	l_MAX_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	l_flag    BOOLEAN;
	l_first   NUMBER;
	l_last    NUMBER;

	CURSOR ins_tacc(c_worker_id number) IS
	SELECT w.terr_id
	       ,w.trans_object_id
	       ,w.resource_id
	 FROM JTF_TAE_1001_QUOTE_WINNERS W
	 WHERE  W.SOURCE_ID = -1001
	 AND    W.worker_id = c_worker_id
	 AND    W.resource_type = 'RS_EMPLOYEE'
	 GROUP BY W.TERR_ID,
		  W.TRANS_OBJECT_ID,
		  W.RESOURCE_ID;
BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Almost the same as accesses, except the insertion is into as_territory_accesses
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
		l_quote_number_id.DELETE;
		l_resource_id.DELETE;
		l_terr_id.DELETE;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'LOOPCOUNT :- ' || l_loop_count);
		BEGIN

			FETCH ins_tacc BULK COLLECT INTO l_terr_id,l_quote_number_id, l_resource_id
			LIMIT l_MAX_fetches;
			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF l_quote_number_id.COUNT < l_MAX_fetches THEN l_limit_flag := TRUE; END IF;
			IF  l_quote_number_id.COUNT > 0 THEN
				l_flag := TRUE;
				l_first := l_quote_number_id.FIRST;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_quote_number_id.LAST THEN
						l_last := l_quote_number_id.LAST;
					END IF;
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						FORALL i IN l_first .. l_last
						INSERT INTO ASO_TERRITORY_ACCESSES
						(    access_id,
							 territory_id,
							 last_update_date,
							 last_updated_by,
							 creation_date,
							 created_by,
							 last_update_login,
							 request_id,
							 program_application_id,
							 program_id,
							 program_update_date
						)
						(
							SELECT
							 V.acc_id,
							 l_terr_id(i),
							 SYSDATE,
							 p_terr_globals.user_id,
							 SYSDATE,
							 p_terr_globals.user_id,
							 p_terr_globals.last_update_login,
							 p_terr_globals.request_id,
							 p_terr_globals.prog_appl_id,
							 p_terr_globals.prog_id,
							 SYSDATE
							 FROM
							(SELECT AA.acc_id
							 FROM ( SELECT DISTINCT a.access_id acc_id
									FROM ASO_QUOTE_ACCESSES A
									WHERE A.quote_number = l_quote_number_id(i)
									AND   A.resource_id=l_resource_id(i)
									) AA
							 WHERE NOT EXISTS
								(SELECT 'X'
								FROM ASO_TERRITORY_ACCESSES AST
								WHERE AST.access_id = AA.acc_id
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
								INSERT INTO AS_TERRITORY_ACCESSES
								(    access_id,
									 territory_id,
									 user_territory_id,
									 last_update_date,
									 last_updated_by,
									 creation_date,
									 created_by,
									 last_update_login,
									 request_id,
									 program_application_id,
									 program_id,
									 program_update_date
								)
								(
									SELECT
									 V.acc_id,
									 l_terr_id(i),
									 l_terr_id(i),
									 SYSDATE,
									 p_terr_globals.user_id,
									 SYSDATE,
									 p_terr_globals.user_id,
									 p_terr_globals.last_update_login,
									 p_terr_globals.request_id,
									 p_terr_globals.prog_appl_id,
									 p_terr_globals.prog_id,
									 SYSDATE
									FROM
										(SELECT AA.acc_id
										 FROM ( SELECT DISTINCT a.access_id acc_id
												FROM ASO_QUOTE_ACCESSES A
												WHERE A.quote_number = l_quote_number_id(i)
												AND   A.resource_id=l_resource_id(i)
												) AA
										 WHERE NOT EXISTS
											(SELECT 'X'
											FROM ASO_TERRITORY_ACCESSES AST
											WHERE AST.access_id = AA.acc_id
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
					IF l_first > l_quote_number_id.LAST THEN
						l_flag := FALSE;
					END IF;
				END LOOP;
			END IF; --l_quote_number_id.COUNT > 0
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
	l_quote_number_id.DELETE;
	l_resource_id.DELETE;
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
END INSERT_TERR_ACCESSES_QOT;

/************************** End Insert Into Quote Terr Accesses*************/
/****************************   Start Assign Quote Owner  ********************/
PROCEDURE ASSIGN_QOT_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

/*-------------------------------------------------------------------------------
| SCENARIO # 1
| -------------
| Get all the quote numbers and accessids of those resources which are valid in jtf
| by joining the current accesses with the list of quotes which are processed in
| the current batch excluding the list of quotes that we need not process..
| Note: These quotes will contain atleast one valid resource in the salesteam.
| The one instance that is not handled in the above scenarios is Q8.
| Note that R12 is not valid but Q8 will not be picked up in the first cursor or
| the second..because of the existance of Q8 R10 F !!! This is handled by introducing
| the valid salesrep joins in the not exists clause..
|-------------------------------------------------------------------------------*/
	CURSOR set_primary_srep_sc1_total(c_worker_id number) IS
	SELECT W.trans_object_id, MAX(access_id)
	FROM   ASO_QUOTE_ACCESSES AQA1,
	      ( SELECT DISTINCT trans_object_id  -- Q8
		FROM JTF_TAE_1001_QUOTE_TRANS TRANS ,ASO_QUOTE_HEADERS_ALL AQH
		WHERE worker_id=c_worker_id
		AND TRANS.trans_object_id  = AQH.quote_number
		AND NOT EXISTS
			(
			SELECT 'X'
			FROM  ASO_QUOTE_ACCESSES AQA2, JTF_RS_SRP_Vl SREP1
			WHERE AQH.resource_Id  = AQA2.resource_id
			AND   AQH.quote_number = AQA2.quote_number
			AND   SREP1.resource_id = AQA2.resource_id
			AND   NVL(AQA2.update_access_flag,'N') = 'Y'
			AND   NVL(SREP1.status,'A') = 'A'
			AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
			AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
			)--  all Q except Q8 (pick only the record which has an invalid resource set in header and access)
		) W, JTF_RS_SRP_Vl SREP
	WHERE AQA1.quote_number = W.trans_object_id
	AND   AQA1.resource_id  = SREP.resource_id
	AND   NVL(AQA1.update_access_flag,'N') ='Y'
	AND   NVL(SREP.status,'A') = 'A'
	AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
	AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
	GROUP BY  W.trans_object_id;

	CURSOR set_primary_srep_sc1_nm(c_worker_id number) IS
	SELECT W.trans_object_id, MAX(access_id)
	FROM   ASO_QUOTE_ACCESSES AQA1,
	      ( SELECT DISTINCT trans_object_id  -- Q8
		FROM JTF_TAE_1001_QUOTE_NM_TRANS  TRANS ,ASO_QUOTE_HEADERS_ALL AQH
		WHERE worker_id=c_worker_id
		AND TRANS.trans_object_id  = AQH.quote_number
		AND NOT EXISTS
			(
			SELECT 'X'
			FROM  ASO_QUOTE_ACCESSES AQA2, JTF_RS_SRP_Vl SREP1
			WHERE AQH.resource_Id  = AQA2.resource_id
			AND   AQH.quote_number = AQA2.quote_number
			AND   SREP1.resource_id = AQA2.resource_id
			AND   NVL(AQA2.update_access_flag,'N') = 'Y'
			AND   NVL(SREP1.status,'A') = 'A'
			AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
			AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
			)--  all Q except Q8 (pick only the record which has an invalid resource set in header and access)
		) W, JTF_RS_SRP_Vl SREP
	WHERE AQA1.quote_number = W.trans_object_id
	AND   AQA1.resource_id  = SREP.resource_id
	AND   NVL(AQA1.update_access_flag,'N') ='Y'
	AND   NVL(SREP.status,'A') = 'A'
	AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
	AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
	GROUP BY  W.trans_object_id;

/*-------------------------------------------------------------------------------
| SCENARIO # 2
| -------------
| Get the list of quotes which do not have any valid resources in the sales team
| These quote headers and accesses should be updated with the profile defaults
|-------------------------------------------------------------------------------*/
	CURSOR set_primary_srep_sc2_total(c_worker_id NUMBER) IS
	SELECT DISTINCT trans_object_id -- Q9, Q10
	FROM JTF_TAE_1001_QUOTE_TRANS TRANS ,ASO_QUOTE_HEADERS_ALL AQH
	WHERE worker_id=c_worker_id
	AND TRANS.trans_object_id  = AQH.quote_number
	AND NOT EXISTS
		(SELECT 'X'
		FROM  ASO_QUOTE_ACCESSES AQA2, JTF_RS_SRP_Vl SREP
		WHERE SREP.resource_Id  = AQA2.resource_id
		AND   AQH.quote_number = AQA2.quote_number
		AND   NVL(AQA2.update_access_flag,'N') = 'Y'
		AND   NVL(SREP.status,'A') = 'A'
		AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
		AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
		)  -- R1,R7,R8,R9,R3,R4,R2,R5,R10,R11
	GROUP BY  trans_object_id;

	CURSOR set_primary_srep_sc2_nm(c_worker_id NUMBER) IS
	SELECT DISTINCT trans_object_id -- Q9, Q10
	FROM JTF_TAE_1001_QUOTE_NM_TRANS TRANS ,ASO_QUOTE_HEADERS_ALL AQH
	WHERE worker_id=c_worker_id
	AND TRANS.trans_object_id  = AQH.quote_number
	AND NOT EXISTS
		(SELECT 'X'
		FROM  ASO_QUOTE_ACCESSES AQA2, JTF_RS_SRP_Vl SREP
		WHERE SREP.resource_Id  = AQA2.resource_id
		AND   AQH.quote_number = AQA2.quote_number
		AND   NVL(AQA2.update_access_flag,'N') = 'Y'
		AND   NVL(SREP.status,'A') = 'A'
		AND   NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
		AND   NVL(TRUNC(end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
		)  -- R1,R7,R8,R9,R3,R4,R2,R5,R10,R11
	GROUP BY  trans_object_id;


   TYPE num_list IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

   l_quote_number_id num_list;
   l_access_id       num_list;
   l_org_id          num_list;
   l_sales_grp_id    num_list;
   l_sales_rep_id    num_list;

   l_limit_flag    BOOLEAN := FALSE;
   l_MAX_fetches   NUMBER  := 10000;
   l_loop_count    NUMBER  := 0;

   l_attempts         NUMBER := 0;
   l_exceptions       BOOLEAN := FALSE;

   l_flag    BOOLEAN;
   l_first   NUMBER;
   l_last    NUMBER;
   l_worker_id    NUMBER;
   l_var     NUMBER;
   l_ind_org_id NUMBER;
   l_ind_sales_rep_id NUMBER;
   l_ind_sales_grp_id NUMBER;

  NOT_NULL EXCEPTION;
  PRAGMA EXCEPTION_INIT(NOT_NULL, -1400);

BEGIN
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_worker_id:=p_terr_globals.worker_id;
    l_var      :=p_terr_globals.bulk_size;
    l_MAX_fetches := p_terr_globals.cursor_limit;
	/*-------------------------------------------------------------------+
	| SCENARIO # 1
	| ------------
	+--------------------------------------------------------------------*/
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'SCENARIO # 1' || AS_GAR.G_START);
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);
		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
			OPEN  set_primary_srep_sc1_total(l_worker_id);
			FETCH set_primary_srep_sc1_total BULK COLLECT INTO l_quote_number_id,l_access_id LIMIT l_MAX_fetches;
			CLOSE set_primary_srep_sc1_total;
		ELSE
			OPEN set_primary_srep_sc1_nm(l_worker_id);
			FETCH set_primary_srep_sc1_nm BULK COLLECT INTO l_quote_number_id,l_access_id LIMIT l_MAX_fetches;
			CLOSE set_primary_srep_sc1_nm;
		END IF;
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_quote_number_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_quote_number_id.COUNT > 0 THEN
			 l_flag := TRUE;
			 l_first := l_quote_number_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_quote_number_id.LAST THEN
					l_last := l_quote_number_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE ASO_QUOTE_HEADERS_ALL');
					BEGIN
						 FORALL i in l_first .. l_last
							UPDATE ASO_QUOTE_HEADERS_ALL AQH
							SET	last_update_date = SYSDATE,
								last_updated_by = FND_GLOBAL.USER_ID,
								last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
								(resource_id,resource_grp_id) =
								( SELECT resource_id,resource_grp_id
								  FROM ASO_QUOTE_ACCESSES AQA
								  WHERE AQA.access_id = l_access_id(i)
								)
							WHERE quote_number = l_quote_number_id(I);
							COMMIT;
						l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_first || ' - '|| l_last);
					EXCEPTION
					WHEN deadlock_detected THEN
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_DEADLOCK ||l_attempts);
						ROLLBACK;
						l_attempts := l_attempts +1;
						IF l_attempts = 3 THEN
							FOR i IN l_first .. l_last  LOOP
							BEGIN
							UPDATE ASO_QUOTE_HEADERS_ALL AQH
							SET	last_update_date = SYSDATE,
								last_updated_by = FND_GLOBAL.USER_ID,
								last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
								(resource_id,resource_grp_id) =
								( SELECT resource_id,resource_grp_id
								  FROM ASO_QUOTE_ACCESSES AQA
								  WHERE AQA.access_id = l_access_id(i)
								)
							WHERE quote_number = l_quote_number_id(I);
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF ASO_QUOTE_HEADERS', SQLERRM, TO_CHAR(SQLCODE));
								AS_GAR.LOG('QUOTE NUMBER:- ' || l_quote_number_id(I));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE ASO_QUOTE_HEADERS', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_quote_number_id.LAST THEN
					l_flag := FALSE;
				END IF;
  		    END LOOP;
		END IF; --l_quote_number_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_quote_number_id.COUNT);
	END LOOP;
	l_access_id.delete;
	l_quote_number_id.delete;
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'SCENARIO # 1' || AS_GAR.G_END);
        l_limit_flag := FALSE;
	/*-------------------------------------------------------------------+
	| SCENARIO # 2
	| ------------
	+--------------------------------------------------------------------*/
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'SCENARIO # 2' || AS_GAR.G_START);
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);
		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
			OPEN  set_primary_srep_sc2_total(l_worker_id);
			FETCH set_primary_srep_sc2_total BULK COLLECT INTO l_quote_number_id LIMIT l_MAX_fetches;
			CLOSE set_primary_srep_sc2_total;
		ELSE
			OPEN set_primary_srep_sc2_nm(l_worker_id);
			FETCH set_primary_srep_sc2_nm BULK COLLECT INTO l_quote_number_id LIMIT l_MAX_fetches;
			CLOSE set_primary_srep_sc2_nm;
		END IF;
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_quote_number_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_quote_number_id.COUNT > 0 THEN
		/*---------------------------------------------------------------------+
		| Get default Rep, Role from profile
		| Find out if Profile Rep is person_id or resource_id or salesrep_id
		| Accordingly get the resource_id and store in var
		| Get default group ? Talk to PMs
		| Insert into quote accesses
		| Update quote headers
		| We have requested quoting team for more info on how to obtain the
		| following default values:
		|  <default sales rep resource id>
		|  <default sales rep group id>
		|  <default sales rep role id>
		+---------------------------------------------------------------------*/
			 l_flag := TRUE;
			 l_first := l_quote_number_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_quote_number_id.LAST THEN
					l_last := l_quote_number_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE ASO_QUOTE_HEADERS_ALL');
					BEGIN
						FORALL i in l_first .. l_last
							UPDATE ASO_QUOTE_HEADERS_ALL AQH
							SET	last_update_date = SYSDATE,
								last_updated_by = FND_GLOBAL.USER_ID,
								last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
								(resource_id,resource_grp_id) =
								( SELECT resource_id,org_information3
								  FROM jtf_rs_Salesreps a , hr_organization_information b
								  WHERE a.salesrep_number = b.org_information2
								   AND a.org_id = b.organization_id
								   AND b.org_information_context = 'ASO_ORG_INFO'
								   AND b.organization_id = AQH.org_id)
							WHERE quote_number = l_quote_number_id(I) RETURNING ORG_ID,RESOURCE_ID,RESOURCE_GRP_ID
							BULK COLLECT INTO l_org_id,l_sales_rep_id,l_sales_grp_id;
							COMMIT;
						FORALL i in l_first .. l_last
							INSERT INTO ASO_QUOTE_ACCESSES (
								  ACCESS_ID,
								  QUOTE_NUMBER,
								  RESOURCE_ID,
								  RESOURCE_GRP_ID,
								  CREATED_BY,
								  CREATION_DATE,
								  LAST_UPDATED_BY,
								  LAST_UPDATE_LOGIN,
								  LAST_UPDATE_DATE,
								  REQUEST_ID,
								  PROGRAM_APPLICATION_ID,
								  PROGRAM_ID,
								  PROGRAM_UPDATE_DATE,
								  KEEP_FLAG,
								  UPDATE_ACCESS_FLAG,
								  CREATED_BY_TAP_FLAG,
								  TERRITORY_ID,
								  TERRITORY_SOURCE_FLAG,
								  ROLE_ID
								)
								  SELECT 								  ASO_QUOTE_ACCESSES_S.nextval,
								  l_quote_number_id(i),
								  l_sales_rep_id(i),
								  l_sales_grp_id(i),
								  p_terr_globals.user_id,
								  SYSDATE,
								  p_terr_globals.user_id,
								  p_terr_globals.last_update_login,
								  SYSDATE,
								  p_terr_globals.request_id,
								  p_terr_globals.prog_appl_id,
								  p_terr_globals.prog_id,
								  SYSDATE,
								  'N',
								  'Y',
								  'Y',
								  NULL,
								  'N',
								  org_information4
							         from hr_organization_information
								where org_information_context = 'ASO_ORG_INFO'
								 and organization_id = l_org_id(i);
							COMMIT;
						l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_first || ' - '|| l_last);
					EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						FOR i IN l_first .. l_last LOOP
							BEGIN
								INSERT INTO ASO_QUOTE_ACCESSES (
								  ACCESS_ID,
								  QUOTE_NUMBER,
								  RESOURCE_ID,
								  RESOURCE_GRP_ID,
								  CREATED_BY,
								  CREATION_DATE,
								  LAST_UPDATED_BY,
								  LAST_UPDATE_LOGIN,
								  LAST_UPDATE_DATE,
								  REQUEST_ID,
								  PROGRAM_APPLICATION_ID,
								  PROGRAM_ID,
								  PROGRAM_UPDATE_DATE,
								  KEEP_FLAG,
								  UPDATE_ACCESS_FLAG,
								  CREATED_BY_TAP_FLAG,
								  TERRITORY_ID,
								  TERRITORY_SOURCE_FLAG,
								  ROLE_ID
								)
								  SELECT 								  ASO_QUOTE_ACCESSES_S.nextval,
								  l_quote_number_id(i),
								  l_sales_rep_id(i),
								  l_sales_grp_id(i),
								  p_terr_globals.user_id,
								  SYSDATE,
								  p_terr_globals.user_id,
								  p_terr_globals.last_update_login,
								  SYSDATE,
								  p_terr_globals.request_id,
								  p_terr_globals.prog_appl_id,
								  p_terr_globals.prog_id,
								  SYSDATE,
								  'N',
								  'Y',
								  'Y',
								  NULL,
								  'N',
								  org_information4
							         from hr_organization_information
								where org_information_context = 'ASO_ORG_INFO'
								 and organization_id = l_org_id(i);
							EXCEPTION
							WHEN Others THEN
								NULL;
							END;
						END LOOP;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
						l_attempts := 3;
					WHEN DEADLOCK_DETECTED THEN
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_DEADLOCK ||l_attempts);
						ROLLBACK;
						l_attempts := l_attempts +1;
						IF l_attempts = 3 THEN
							FOR i IN l_first .. l_last  LOOP
							BEGIN
							UPDATE ASO_QUOTE_HEADERS_ALL AQH
							SET	last_update_date = SYSDATE,
								last_updated_by = FND_GLOBAL.USER_ID,
								last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
								(resource_id,resource_grp_id) =
								( SELECT resource_id,org_information3
								  FROM jtf_rs_Salesreps a , hr_organization_information b
								  WHERE a.salesrep_number = b.org_information2
								   AND a.org_id = b.organization_id
								   AND b.org_information_context = 'ASO_ORG_INFO'
								   AND b.organization_id = AQH.org_id)
							WHERE quote_number = l_quote_number_id(I) RETURNING ORG_ID,RESOURCE_ID,RESOURCE_GRP_ID
							INTO l_ind_org_id,l_ind_sales_rep_id,l_ind_sales_grp_id;

								INSERT INTO ASO_QUOTE_ACCESSES (
								  ACCESS_ID,
								  QUOTE_NUMBER,
								  RESOURCE_ID,
								  RESOURCE_GRP_ID,
								  CREATED_BY,
								  CREATION_DATE,
								  LAST_UPDATED_BY,
								  LAST_UPDATE_LOGIN,
								  LAST_UPDATE_DATE,
								  REQUEST_ID,
								  PROGRAM_APPLICATION_ID,
								  PROGRAM_ID,
								  PROGRAM_UPDATE_DATE,
								  KEEP_FLAG,
								  UPDATE_ACCESS_FLAG,
								  CREATED_BY_TAP_FLAG,
								  TERRITORY_ID,
								  TERRITORY_SOURCE_FLAG,
								  ROLE_ID
								)
								  SELECT 								  ASO_QUOTE_ACCESSES_S.nextval,
								  l_quote_number_id(i),
								  l_sales_rep_id(i),
								  l_sales_grp_id(i),
								  p_terr_globals.user_id,
								  SYSDATE,
								  p_terr_globals.user_id,
								  p_terr_globals.last_update_login,
								  SYSDATE,
								  p_terr_globals.request_id,
								  p_terr_globals.prog_appl_id,
								  p_terr_globals.prog_id,
								  SYSDATE,
								  'N',
								  'Y',
								  'Y',
								  NULL,
								  'N',
								  org_information4
							         from hr_organization_information
								where org_information_context = 'ASO_ORG_INFO'
								 and organization_id = l_org_id(i);
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF ASO_QUOTE_HEADERS', SQLERRM, TO_CHAR(SQLCODE));
								AS_GAR.LOG('QUOTE NUMBER:- ' || l_quote_number_id(I));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN NOT_NULL THEN
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_PROCESS || 'NOT NULL Condition Exception');
						ROLLBACK;
						FOR i IN l_first .. l_last  LOOP
						BEGIN
							IF aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.G_DEFAULT_SALESREP,l_org_id(i)) IS NOT NULL THEN
								INSERT INTO ASO_QUOTE_ACCESSES (
								  ACCESS_ID,
								  QUOTE_NUMBER,
								  RESOURCE_ID,
								  RESOURCE_GRP_ID,
								  CREATED_BY,
								  CREATION_DATE,
								  LAST_UPDATED_BY,
								  LAST_UPDATE_LOGIN,
								  LAST_UPDATE_DATE,
								  REQUEST_ID,
								  PROGRAM_APPLICATION_ID,
								  PROGRAM_ID,
								  PROGRAM_UPDATE_DATE,
								  KEEP_FLAG,
								  UPDATE_ACCESS_FLAG,
								  CREATED_BY_TAP_FLAG,
								  TERRITORY_ID,
								  TERRITORY_SOURCE_FLAG,
								  ROLE_ID
								)
								  SELECT 								  ASO_QUOTE_ACCESSES_S.nextval,
								  l_quote_number_id(i),
								  l_sales_rep_id(i),
								  l_sales_grp_id(i),
								  p_terr_globals.user_id,
								  SYSDATE,
								  p_terr_globals.user_id,
								  p_terr_globals.last_update_login,
								  SYSDATE,
								  p_terr_globals.request_id,
								  p_terr_globals.prog_appl_id,
								  p_terr_globals.prog_id,
								  SYSDATE,
								  'N',
								  'Y',
								  'Y',
								  NULL,
								  'N',
								  org_information4
							         from hr_organization_information
								where org_information_context = 'ASO_ORG_INFO'
								 and organization_id = l_org_id(i);
							  END IF;
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF ASO_QUOTE_HEADERS', SQLERRM, TO_CHAR(SQLCODE));
								AS_GAR.LOG('QUOTE NUMBER:- ' || l_quote_number_id(I));
							END;
							END LOOP;
							COMMIT;
						l_attempts := 3;
					END; -- NOT NULL CONDITION
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE ASO_QUOTE_HEADERS', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP; -- L_attempt
			l_first := l_last + 1;
			l_last := l_first + l_var;
			IF l_first > l_quote_number_id.LAST THEN
				l_flag := FALSE;
			END IF;
		   END LOOP; -- l_Flag
		END IF; --l_quote_number_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_quote_number_id.COUNT);
	END LOOP;

	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'SCENARIO # 2' || AS_GAR.G_END);
	l_limit_flag    := FALSE;
	l_loop_count    := 0;
	l_access_id.delete;
	l_quote_number_id.delete;
	l_attempts    := 1;

EXCEPTION
WHEN OTHERS THEN
	AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
	x_errbuf  := SQLERRM;
	x_retcode := SQLCODE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE;
END ASSIGN_QOT_OWNER;

/****************************   End Assign Qot Owner  ********************/
/**************************   Start Quote Cleanup ***********************/

PROCEDURE PERFORM_QOT_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

	TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_quote_number_id      num_list;
	l_access_id            num_list;


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


/* This cursor different from other entities since Quoting Real time tap is not removing
sales person if winners not returning any records so same kind of logic followed here also
*/
	CURSOR del_quote_totalmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_QUOTE_WINNERS
		WHERE worker_id=c_worker_id;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id   := p_terr_globals.worker_id;
	l_var      := p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	OPEN del_quote_totalmode(l_worker_id);
	LOOP --{L1
		IF (l_limit_flag) THEN EXIT; END IF;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || 'LOOPCOUNT :- ' ||l_loop_count);
		BEGIN
			EXIT WHEN del_quote_totalmode%NOTFOUND;
			FETCH del_quote_totalmode BULK COLLECT INTO l_quote_number_id
			LIMIT l_MAX_fetches;
			-- Initialize variables (Ist Init)
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;
			l_attempts := 1;

			IF l_quote_number_id.COUNT < l_MAX_fetches THEN
				l_limit_flag := TRUE;
			END IF;

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_START);
			IF l_quote_number_id.count > 0 THEN --{I1
				l_flag  := TRUE;
				l_first := l_quote_number_id.FIRST;
				l_last  := l_first + l_var;
				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED ||
								 l_quote_number_id.FIRST || '-' ||
								 l_quote_number_id.LAST);
				WHILE l_flag LOOP --{L2 10K cust loop
					IF l_last > l_quote_number_id.LAST THEN
						l_last := l_quote_number_id.LAST;
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
									DELETE FROM ASO_QUOTE_ACCESSES ACC
									WHERE ACC.QUOTE_NUMBER =l_quote_number_id(i)
									  AND NVL(ACC.KEEP_FLAG,'N')  <>   'Y'
									  AND NOT EXISTS (SELECT  'X'
										   FROM JTF_TAE_1001_QUOTE_WINNERS W
										  WHERE  W.TRANS_OBJECT_ID = ACC.QUOTE_NUMBER
										  AND  W.WORKER_ID = l_worker_id
										  AND  W.RESOURCE_ID = ACC.RESOURCE_ID)
									 AND ROWNUM < G_DEL_REC;
								COMMIT;
								l_attempts := 3;
								IF l_access_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
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
											DELETE FROM ASO_QUOTE_ACCESSES ACC
											WHERE ACC.QUOTE_NUMBER =l_quote_number_id(i)
											  AND NVL(ACC.KEEP_FLAG,'N')  <>   'Y'
											  AND NOT EXISTS (SELECT  'X'
												   FROM JTF_TAE_1001_QUOTE_WINNERS W
												  WHERE  W.TRANS_OBJECT_ID = ACC.QUOTE_NUMBER
												  AND  W.WORKER_ID = l_worker_id
												  AND  W.RESOURCE_ID = ACC.RESOURCE_ID);
											COMMIT;
										EXCEPTION
										WHEN OTHERS THEN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_GENERAL_EXCEPTION);
											AS_GAR.LOG('QUOTE id - ' || l_quote_number_id(i));
										END;
									END LOOP; --}L5
									COMMIT;
									l_del_flag := TRUE;
								END IF;
							END; --}I2 end of deadlock exception
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
								IF del_quote_totalmode%ISOPEN THEN CLOSE del_quote_totalmode; END IF;
								x_errbuf  := SQLERRM;
								x_retcode := SQLCODE;
								x_return_status := FND_API.G_RET_STS_ERROR;
								RAISE;
							END;
						 END LOOP;  --}L4  l_attempts loop 3 trys
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-' || l_last);
					END LOOP; --}L3  -- to update only 10k record at a time on accesses
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_quote_number_id.LAST THEN
					    l_flag := FALSE;
					END IF;
				END LOOP;  --}L2  while l_flag loop (10K cust loop)
			END IF;--}I1
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_END);
			COMMIT;
		EXCEPTION
		WHEN Others THEN
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
			IF del_quote_totalmode%ISOPEN THEN CLOSE del_quote_totalmode; END IF;
			x_errbuf  := SQLERRM;
			x_retcode := SQLCODE;
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE;
		END;
	END LOOP;--}L1
	IF del_quote_totalmode%ISOPEN THEN CLOSE del_quote_totalmode; END IF;
EXCEPTION
WHEN OTHERS THEN
    AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
    x_errbuf  := SQLERRM;
    x_retcode := SQLCODE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE;
END PERFORM_QOT_CLEANUP;

/**************************   End Quote Cleanup ***********************/


END AS_GAR_QOT_PUB;

/
