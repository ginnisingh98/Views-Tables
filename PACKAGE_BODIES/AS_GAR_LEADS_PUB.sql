--------------------------------------------------------
--  DDL for Package Body AS_GAR_LEADS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_GAR_LEADS_PUB" AS
/* $Header: asxgrldb.pls 120.8.12010000.2 2010/03/01 10:38:13 sariff ship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR_LEADS_PUB
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
  G_ENTITY CONSTANT VARCHAR2(12) := 'GAR::LEADS::';
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
    l_assign_manual_flag   VARCHAR2(1);
    l_resource_id          NUMBER;

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

    /* This inserts into Lead winners */
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);
    JTY_ASSIGN_BULK_PUB.GET_WINNERS
    ( p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.G_TRUE,
      p_source_id             => -1001,
      p_trans_id	      => -1003,
      P_PROGRAM_NAME          => 'SALES/LEAD PROGRAM',
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
    AS_GAR_LEADS_PUB.EXPLODE_GROUPS_LEADS(
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
    AS_GAR_LEADS_PUB.EXPLODE_TEAMS_LEADS(
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

    -- Set team leader for Leads
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_START);
    AS_GAR_LEADS_PUB.SET_TEAM_LEAD_LEADS(
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

	 -- Insert into Lead Accesses from Winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
    AS_GAR_LEADS_PUB.INSERT_ACCESSES_LEADS(
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
    AS_GAR_LEADS_PUB.INSERT_TERR_ACCESSES_LEADS(
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
    AS_GAR_LEADS_PUB.PERFORM_LEAD_CLEANUP(
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

   -- LEAD Owner assignment
   -- Lead Owner logic is re-written to sync with real time TAP for bug 8615468
   -- Logic is as:
   -- If profile 'OS: Assign New Lead' set to 'No' then
   -- owner will be any Resource assigned via TAP. If no resource assigned by TAP then
   -- owner is based on profile OS: Default Resource ID used for Sales Lead Assignment.
   -- If profile 'OS: Assign New Lead' set to 'Yes' then
   -- owner is based on profile OS: Default Resource ID used for Sales Lead Assignment.

   l_assign_manual_flag := nvl(FND_PROFILE.Value('AS_LEAD_ASSIGN_MANUAL'),'N');
   l_resource_id	:= fnd_profile.value('AS_DEFAULT_RESOURCE_ID');

   AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_START);
   IF l_assign_manual_flag = 'N' THEN
	AS_GAR_LEADS_PUB.ASSIGN_LEAD_OWNER(
              x_errbuf        => l_errbuf,
              x_retcode       => l_retcode,
              p_terr_globals  => l_terr_globals,
              x_return_status => l_return_status);
	IF l_resource_id IS NOT NULL THEN
	  AS_GAR_LEADS_PUB.ASSIGN_DEFAULT_LEAD_OWNER(
	      x_errbuf        => l_errbuf,
	      x_retcode       => l_retcode,
	      p_terr_globals  => l_terr_globals,
	      x_return_status => l_return_status);
	END IF;
    ELSE
       IF l_resource_id IS NOT NULL THEN
         AS_GAR_LEADS_PUB.UNCHECK_LEAD_OWNER(
            x_errbuf        => l_errbuf,
            x_retcode       => l_retcode,
            p_terr_globals  => l_terr_globals,
            x_return_status => l_return_status);
         AS_GAR_LEADS_PUB.ASSIGN_DEFAULT_LEAD_OWNER(
            x_errbuf        => l_errbuf,
            x_retcode       => l_retcode,
            p_terr_globals  => l_terr_globals,
            x_return_status => l_return_status);
	ELSE
	 AS_GAR_LEADS_PUB.UNCHECK_ASSIGN_SALESFORCE(
            x_errbuf        => l_errbuf,
            x_retcode       => l_retcode,
            p_terr_globals  => l_terr_globals,
            x_return_status => l_return_status);
	END IF;
    END IF;
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_END);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO || AS_GAR.G_RETURN_STATUS || l_return_status);

    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CO, l_errbuf, l_retcode);
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

/************************** Start Explode Teams Leads ******************/
PROCEDURE EXPLODE_TEAMS_LEADS(
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
l_res_lead_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_LEAD_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;


CURSOR count_res_lead
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_TEAM'
AND acc.access_type = 'LEAD'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;

BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_request_id    := p_terr_globals.request_id;
   l_worker_id     := p_terr_globals.worker_id;
   l_resource_type := 'RS_TEAM';


   OPEN   count_res_lead;
      FETCH  count_res_lead INTO   l_res_lead_count;
   CLOSE  count_res_lead;

   IF l_res_lead_count > 0 THEN
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
	       INSERT INTO JTF_TAE_1001_LEAD_WINNERS
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
               JTF_TAE_1001_LEAD_WINNERS T,
               (
                 SELECT TM.team_resource_id resource_id,
                        TM.person_id person_id2,
                        MIN(G.group_id)group_id,
                        MIN(T.team_id) team_id,
                        TRES.category resource_category,
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
                        AND    res.category IN ('EMPLOYEE','PARTY','PARTNER')
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
                AND   tres.category IN ('EMPLOYEE','PARTY','PARTNER')
                AND   tm.team_resource_id = g.resource_id
                GROUP BY tm.team_resource_id,
                         tm.person_id,
                         tres.category,
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
     WHERE j.team_id = t.resource_id
        AND   t.request_id = l_request_id
        AND   t.worker_id =  l_worker_id
        AND   t.resource_type = 'RS_TEAM'
        AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_LEAD_WINNERS rt1
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
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END EXPLODE_TEAMS_LEADS;
/************************** End Explode Teams Leads ******************/

/************************** Start Explode Groups Leads ******************/
PROCEDURE EXPLODE_GROUPS_LEADS(
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
l_res_lead_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_LEAD_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;

CURSOR count_res_lead
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_GROUP'
AND acc.access_type = 'LEAD'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id ;

BEGIN
     l_resource_type := 'RS_GROUP';
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_request_id    := p_terr_globals.request_id;
     l_worker_id     := p_terr_globals.worker_id;

     OPEN   count_res_lead;
	 FETCH  count_res_lead INTO   l_res_lead_count;
     CLOSE  count_res_lead;

     IF l_res_lead_count > 0 THEN
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

    		INSERT INTO JTF_TAE_1001_LEAD_WINNERS
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
                  JTF_TAE_1001_LEAD_WINNERS t,
                  (
                   SELECT MIN(m.resource_id) resource_id,
                          res.category resource_category,
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
                   AND   res.category IN ('EMPLOYEE')--,'PARTY','PARTNER')
                   GROUP BY m.group_member_id, m.resource_id, m.person_id,
                            m.group_id, res.CATEGORY) j
          WHERE j.group_id = t.resource_id
	      AND   t.request_id = l_request_id
	      AND   t.worker_id  = l_worker_id
          AND   t.resource_type = 'RS_GROUP'
          AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_LEAD_WINNERS rt1
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
END EXPLODE_GROUPS_LEADS;
/************************** End Explode Groups Leads ******************/

/************************** Start Set Leads Team Leader *****************/

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

PROCEDURE SET_TEAM_LEAD_LEADS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list  is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;

    l_sales_lead_id    num_list;
    l_salesforce_id    num_list;
    l_sales_group_id   num_list;
    l_faf              faf_list;
    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts         NUMBER := 0;

	CURSOR team_leader(c_worker_id number) IS
	    SELECT /*+ LEADING(WIN) USE_NL(A WIN) INDEX(A) */ A.sales_lead_id,
		      A.salesforce_id,
		      A.sales_group_id,
		      NVL(WIN.full_access_flag,'N')
	    FROM  AS_ACCESSES_ALL_ALL A,
		      JTF_TAE_1001_LEAD_WINNERS WIN
	    WHERE A.lead_id is NULL
	    AND   A.sales_lead_id is NOT NULL
	    AND   A.delete_flag is NULL
	    AND   NVL(A.team_leader_flag,'N') <> NVL(WIN.full_access_flag,'N')
	    AND   WIN.source_id = -1001
	    AND   WIN.worker_id = c_worker_id
	    AND   WIN.resource_type = 'RS_EMPLOYEE'
	    AND   WIN.trans_object_id = A.sales_lead_id
	    AND   WIN.resource_id     = A.salesforce_id
	    AND   WIN.group_id = A.sales_group_id
	    GROUP BY A.sales_lead_id,
		         A.salesforce_id,
		         A.sales_group_id,
				 WIN.full_access_flag;


BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_max_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
		IF (l_limit_flag) THEN EXIT; END IF;

		l_sales_lead_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_faf.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'LOOPCOUNT :- ' || l_loop_count);

		--------------------------------
		OPEN team_leader(l_worker_id);
		    FETCH team_leader BULK COLLECT INTO
			      l_sales_lead_id, l_salesforce_id, l_sales_group_id, l_faf
		    LIMIT l_max_fetches;
		CLOSE team_leader;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

		IF  l_sales_lead_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_sales_lead_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
					l_last := l_sales_lead_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i IN l_first .. l_last
							UPDATE  AS_ACCESSES_ALL_ALL ACC
							SET	 object_version_number =  NVL(object_version_number,0) + 1,
								 ACC.last_update_date = SYSDATE,
								 ACC.last_updated_by = p_terr_globals.user_id,
								 ACC.last_update_login = p_terr_globals.last_update_login,
								 ACC.request_id = p_terr_globals.request_id,
								 ACC.program_application_id = p_terr_globals.prog_appl_id,
								 ACC.program_id = p_terr_globals.prog_id,
								 ACC.program_update_date = SYSDATE,
								 ACC.team_leader_flag = l_faf(i)
							WHERE    ACC.lead_id is NULL
							 AND	 ACC.sales_lead_id is NOT NULL
							 AND 	 ACC.sales_lead_id    = l_sales_lead_id(i)
							 AND	 ACC.salesforce_id  = l_salesforce_id(i)
							 AND	 ACC.sales_group_id = l_sales_group_id(i);
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
										UPDATE  AS_ACCESSES_ALL_ALL ACC
										SET	object_version_number =  NVL(object_version_number,0) + 1,
											 ACC.last_update_date = SYSDATE,
											 ACC.last_updated_by = p_terr_globals.user_id,
											 ACC.last_update_login = p_terr_globals.last_update_login,
											 ACC.request_id = p_terr_globals.request_id,
											 ACC.program_application_id = p_terr_globals.prog_appl_id,
											 ACC.program_id = p_terr_globals.prog_id,
											 ACC.program_update_date = SYSDATE,
											 ACC.team_leader_flag = l_faf(i)
										 WHERE	 ACC.lead_id is NULL
										 AND	 ACC.sales_lead_id is NOT NULL
										 AND	 ACC.sales_lead_id    = l_sales_lead_id(i)
										 AND	 ACC.salesforce_id  = l_salesforce_id(i)
										 AND	 ACC.sales_group_id = l_sales_group_id(i);
									EXCEPTION
									WHEN OTHERS THEN
										AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
										AS_GAR.LOG('SALES_LEAD_ID/SALESFORCE_ID/SALESGROUP_ID/ORG_ID - ' || l_sales_lead_id(i) || '/' || l_salesforce_id(i) || '/' || l_sales_group_id(i) );
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
				IF l_first > l_sales_lead_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; -- loop for more records within the bulk_size
		END IF; --l_sales_lead_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_N_ROWS_PROCESSED || l_sales_lead_id.COUNT);
	END LOOP; -- loop for more bulk_size fetches
	l_sales_lead_id.DELETE;
	l_faf.DELETE;
	l_salesforce_id.DELETE;
	l_sales_group_id.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END SET_TEAM_LEAD_LEADS;

/************************** End Set Leads Team Leader *****************/

/************************** Start Insert Into Entity Accesses*************/

PROCEDURE INSERT_ACCESSES_LEADS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list  is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;



    l_sales_lead_id    num_list;
    l_org_id           num_list;
    l_salesforce_id    num_list;
    l_sales_group_id   num_list;
    l_person_id        num_list;
    l_faf              faf_list;


    l_var     NUMBER;
    l_worker_id     NUMBER;
    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_attempts         NUMBER := 0;
    l_src_exists    VARCHAR2(1);

	CURSOR ins_acc(c_worker_id number) IS
	SELECT W.resource_id,
	       W.group_id,
	       MIN(W.person_id) person_id,
	       W.trans_object_id sales_lead_id,
	       MAX(W.full_access_flag) FAF,
	       W.org_id
	FROM  JTF_TAE_1001_LEAD_WINNERS W
	WHERE W.source_id = -1001
	AND W.worker_id = c_worker_id
	AND W.resource_type = 'RS_EMPLOYEE'
	AND W.group_id IS NOT NULL --- Added to work around the JTY functionality which allows group_id to be NULL during setup of resources.
	GROUP BY W.trans_object_id,
		     W.resource_id,
	     	 W.group_id,
	   	     W.org_id;

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

		l_sales_lead_id.DELETE;
		l_org_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_person_id.DELETE;
		l_faf.DELETE;

	    EXIT WHEN ins_acc%NOTFOUND;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'LOOPCOUNT :- ' || l_loop_count);

		FETCH ins_acc BULK COLLECT INTO
			      l_salesforce_id, l_sales_group_id, l_person_id,
			      l_sales_lead_id,l_faf,l_org_id
			LIMIT l_max_fetches;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_sales_lead_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_sales_lead_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
				   l_last := l_sales_lead_id.LAST;
				END IF;
				BEGIN
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' to '||l_last);
						FORALL i IN l_first .. l_last
						INSERT INTO AS_ACCESSES_ALL_ALL
						(      access_id
						      ,access_type
						      ,salesforce_id
						      ,sales_group_id
						      ,person_id
						      ,salesforce_role_code
						      ,customer_id
						      ,address_id
					          ,sales_lead_id
						      ,freeze_flag
						      ,reassign_flag
						      ,team_leader_flag
						      ,last_update_date
						      ,last_updated_by
						      ,creation_date
						      ,created_by
						      ,last_update_login
						      ,request_id
						      ,program_application_id
						      ,program_id
						      ,program_update_date
						      ,created_by_tap_flag
						      ,org_id
						      ,open_flag
						      ,lead_rank_score
							  ,object_creation_date
						   )
						   (
						   SELECT as_accesses_s.nextval
						       ,'X'
						       ,l_salesforce_id(i)
						       ,l_sales_group_id(i)
						       ,l_person_id(i)
						       ,NULL
						       ,L.customer_id
						       ,L.address_id
				               ,l_sales_lead_id(i)
						       ,'N'
						       ,'N'
						       ,l_faf(i)
						       ,SYSDATE
						       ,p_terr_globals.user_id
						       ,SYSDATE
						       ,p_terr_globals.user_id
						       ,p_terr_globals.last_update_login
						       ,p_terr_globals.request_id
						       ,p_terr_globals.prog_appl_id
						       ,p_terr_globals.prog_id
						       ,SYSDATE
						       ,'Y'
						       ,l_org_id(i)
				               ,DECODE(STS.opp_open_status_flag, 'Y', 'Y', NULL)
				               ,L.lead_rank_score
					           ,L.creation_date
						    FROM  DUAL, AS_SALES_LEADS L, AS_STATUSES_B STS
						    WHERE L.sales_lead_id = l_sales_lead_id(i)
							  AND L.status_code = STS.status_code
							  AND NOT EXISTS ( SELECT  'X'
								       FROM AS_ACCESSES_ALL_ALL AA
								       WHERE AA.sales_lead_id IS NOT NULL
								       AND AA.lead_id IS NULL
								       AND AA.delete_flag IS NULL
								       AND AA.sales_lead_id = l_sales_lead_id(i)
								       AND AA.salesforce_id = l_salesforce_id(i)
								       AND AA.sales_group_id = l_sales_group_id(i)
								      )
						 );
						 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
						COMMIT;
				EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
					 FOR i IN l_first .. l_last LOOP
						BEGIN
							INSERT INTO AS_ACCESSES_ALL_ALL
							(    access_id
							    ,access_type
							    ,salesforce_id
							    ,sales_group_id
							    ,person_id
							    ,salesforce_role_code
							    ,customer_id
							    ,address_id
								,sales_lead_id
							    ,freeze_flag
							    ,reassign_flag
							    ,team_leader_flag
							    ,last_update_date
							    ,last_updated_by
							    ,creation_date
							    ,created_by
							    ,last_update_login
							    ,request_id
							    ,program_application_id
							    ,program_id
							    ,program_update_date
							    ,created_by_tap_flag
							    ,org_id
								,open_flag
								,lead_rank_score
								,object_creation_date
							 )
							 (
							 SELECT as_accesses_s.NEXTVAL
							     ,'X'
							     ,l_salesforce_id(i)
							     ,l_sales_group_id(i)
							     ,l_person_id(i)
							     ,NULL
							     ,L.customer_id
							     ,L.address_id
								 ,l_sales_lead_id(i)
							     ,'N'
							     ,'N'
							     ,l_faf(i)
							     ,SYSDATE
							     ,p_terr_globals.user_id
							     ,SYSDATE
							     ,p_terr_globals.user_id
							     ,p_terr_globals.last_update_login
							     ,p_terr_globals.request_id
							     ,p_terr_globals.prog_appl_id
							     ,p_terr_globals.prog_id
							     ,SYSDATE
							     ,'Y'
							     ,l_org_id(i)
								 ,DECODE(STS.opp_open_status_flag, 'Y', 'Y', NULL)
								 ,L.lead_rank_score
								 ,L.creation_date
							  FROM  DUAL,AS_SALES_LEADS L, AS_STATUSES_B STS
							  WHERE L.sales_lead_id = l_sales_lead_id(i)
							    AND L.status_code = STS.status_code
								AND NOT EXISTS ( SELECT  'X'
									       FROM AS_ACCESSES_ALL_ALL AA
									       WHERE AA.sales_lead_id IS NOT NULL
									       AND AA.lead_id IS NULL
									       AND AA.delete_flag IS NULL
									       AND AA.sales_lead_id = l_sales_lead_id(i)
									       AND AA.salesforce_id = l_salesforce_id(i)
									       AND AA.sales_group_id = l_sales_group_id(i)
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
				IF l_first > l_sales_lead_id.last THEN
					l_flag := FALSE;
				END IF;
			END LOOP; /* l_flag loop */
		END IF; --l_sales_lead_id.count > 0
	END LOOP; -- loop for more bulk_size fetches
	l_sales_lead_id.DELETE;
	l_org_id.DELETE;
	l_salesforce_id.DELETE;
	l_sales_group_id.DELETE;
	l_person_id.DELETE;
	l_faf.DELETE;
	IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;

EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;
      RAISE;
END INSERT_ACCESSES_LEADS;

/************************** End Insert Into Entity Accesses*************/

/************************** Start Insert Into Terr Accesses*************/

PROCEDURE INSERT_TERR_ACCESSES_LEADS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
	TYPE num_list        IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

	l_sales_lead_id    num_list;
	l_salesforce_id    num_list;
	l_sales_group_id   num_list;
	l_terr_id   num_list;

	l_var     NUMBER;
        l_limit_flag    BOOLEAN := FALSE;
	l_worker_id     NUMBER;
	l_max_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	l_flag    BOOLEAN;
	l_first   NUMBER;
	l_last    NUMBER;


	CURSOR ins_tacc(c_worker_id number) IS
	SELECT w.terr_id
	       ,w.trans_object_id
	       ,w.resource_id
	       ,w.group_id
	 FROM JTF_TAE_1001_LEAD_WINNERS W
	 WHERE  W.source_id = -1001
	 AND    W.worker_id = c_worker_id
	 AND    W.resource_type = 'RS_EMPLOYEE'
  	 AND	W.group_id IS NOT NULL --- Added to work around the JTY functionality which allows group_id to be NULL during setup of resources.
	 GROUP BY W.terr_id,
		      W.trans_object_id,
		      W.resource_id,
		      W.group_id;

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
		l_sales_lead_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_terr_id.DELETE;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'LOOPCOUNT :- ' || l_loop_count);
		BEGIN

			FETCH ins_tacc BULK COLLECT INTO l_terr_id,
			l_sales_lead_id, l_salesforce_id, l_sales_group_id
			LIMIT l_max_fetches;
			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF l_sales_lead_id.COUNT < l_max_fetches THEN l_limit_flag := TRUE; END IF;
			IF  l_sales_lead_id.COUNT > 0 THEN
				l_flag := TRUE;
				l_first := l_sales_lead_id.first;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_sales_lead_id.last THEN
						l_last := l_sales_lead_id.last;
					END IF;
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						FORALL i IN l_first .. l_last
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
							( SELECT DISTINCT A.access_id acc_id
							     FROM AS_ACCESSES_ALL_ALL A
							     WHERE A.sales_lead_id=l_sales_lead_id(i)
							     AND   A.sales_group_id = l_sales_group_id(i)
							     AND   A.salesforce_id=l_salesforce_id(i)
							     AND   A.sales_lead_id is NOT NULL
							     AND   A.delete_flag IS NULL
							     AND   A.lead_id is NULL
							     AND NOT EXISTS
									(SELECT 'X'
									FROM AS_TERRITORY_ACCESSES AST
									WHERE AST.access_id = A.access_id
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
									 v.acc_id,
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
									( SELECT DISTINCT a.access_id acc_id
									     FROM AS_ACCESSES_ALL_ALL A
									     WHERE A.sales_lead_id=l_sales_lead_id(i)
									     AND   A.sales_group_id = l_sales_group_id(i)
									     AND   A.salesforce_id=l_salesforce_id(i)
									     AND   A.sales_lead_id is NOT NULL
									     AND   A.lead_id is NULL
									     AND   A.delete_flag IS NULL
									     AND NOT EXISTS
											(SELECT 'X'
											FROM AS_TERRITORY_ACCESSES AST
											WHERE AST.access_id = A.access_id
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
					IF l_first > l_sales_lead_id.last THEN
						l_flag := FALSE;
					END IF;
				END LOOP;
			END IF; --l_sales_lead_id.count > 0
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
	l_sales_lead_id.DELETE;
	l_salesforce_id.DELETE;
	l_sales_group_id.DELETE;
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
END INSERT_TERR_ACCESSES_LEADS;

/************************** End Insert Into Terr Accesses*************/


/**************************   Start Lead Cleanup ***********************/

PROCEDURE Perform_Lead_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

	TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_sales_lead_id      num_list;
	l_access_id          num_list;


	l_flag          BOOLEAN;
	l_first         NUMBER;
	l_last          NUMBER;
	l_var           NUMBER;
	l_attempts      NUMBER := 0;

	l_worker_id     NUMBER;

	l_del_flag      BOOLEAN:=FALSE;
	l_limit_flag    BOOLEAN := FALSE;
	l_max_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	G_NUM_REC  CONSTANT  NUMBER:=10000;
	G_DEL_REC  CONSTANT  NUMBER:=10001;



	CURSOR del_lead_totalmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_LEAD_TRANS
		WHERE worker_id=c_worker_id;

	CURSOR del_lead_newmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_LEAD_NM_TRANS
		WHERE worker_id=c_worker_id;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id   := p_terr_globals.worker_id;
	l_var      := p_terr_globals.bulk_size;
	l_max_fetches := p_terr_globals.cursor_limit;

	IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
		OPEN del_lead_totalmode(l_worker_id);
	ELSE
		OPEN del_lead_newmode(l_worker_id);
	END IF;
	LOOP --{L1
		IF (l_limit_flag) THEN EXIT; END IF;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || 'LOOPCOUNT :- ' ||l_loop_count);
		BEGIN
			IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
				EXIT WHEN del_lead_totalmode%NOTFOUND;
				FETCH del_lead_totalmode BULK COLLECT INTO l_sales_lead_id
				LIMIT l_max_fetches;
			ELSE
				EXIT WHEN del_lead_newmode%NOTFOUND;
				FETCH del_lead_newmode BULK COLLECT INTO l_sales_lead_id
				LIMIT l_max_fetches;
			END IF;
			-- Initialize variables (Ist Init)
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;
			l_attempts := 1;

			IF l_sales_lead_id.COUNT < l_max_fetches THEN
				l_limit_flag := TRUE;
			END IF;

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_START);
			IF l_sales_lead_id.count > 0 THEN --{I1
				l_flag  := TRUE;
				l_first := l_sales_lead_id.first;
				l_last  := l_first + l_var;
				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED ||
								 l_sales_lead_id.FIRST || '-' ||
								 l_sales_lead_id.LAST);
				WHILE l_flag LOOP --{L2 10K cust loop
					IF l_last > l_sales_lead_id.LAST THEN
						l_last := l_sales_lead_id.LAST;
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
									UPDATE AS_ACCESSES_ALL_ALL ACC
									SET object_version_number =  NVL(object_version_number,0) + 1, ACC.DELETE_FLAG='Y'
									WHERE ACC.sales_lead_id=l_sales_lead_id(i)
									AND ACC.freeze_flag = 'N'
									AND ACC.lead_id IS NULL
									AND ACC.sales_lead_id IS NOT NULL
									AND ACC.delete_flag IS NULL
									AND NOT EXISTS (SELECT  'X'
									  FROM JTF_TAE_1001_LEAD_WINNERS W
									  WHERE  W.trans_object_id = ACC.sales_lead_id
									  AND  W.worker_id = l_worker_id
									  AND  W.resource_id = ACC.salesforce_id
									  AND  W.group_id = ACC.sales_group_id)
									AND ROWNUM < G_DEL_REC;
								COMMIT;
								l_attempts := 3;
								IF l_access_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
							EXCEPTION
							WHEN DUP_VAL_ON_INDEX THEN
								BEGIN
									AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_DEL || AS_GAR.G_START);
									FORALL i in l_first..l_last
										DELETE FROM AS_ACCESSES_ALL_ALL ACC
										WHERE ACC.sales_lead_id=l_sales_lead_id(i)
										AND ACC.freeze_flag = 'N'
										AND ACC.lead_id IS NULL
										AND ACC.sales_lead_id IS NOT NULL
										AND NOT EXISTS (SELECT  'X'
										  FROM JTF_TAE_1001_LEAD_WINNERS W
										  WHERE  W.trans_object_id = ACC.sales_lead_id
										  AND  W.worker_id = l_worker_id
										  AND  W.resource_id = ACC.salesforce_id
										  AND  W.group_id = ACC.sales_group_id)
										AND ROWNUM < G_DEL_REC;
									COMMIT;
									l_attempts := 3;
									IF l_access_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
								EXCEPTION
								WHEN OTHERS THEN
									AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_DEL, SQLERRM, TO_CHAR(SQLCODE));
								END;
							WHEN deadlock_detected THEN
							BEGIN --{I2
								AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_UPD || AS_GAR.G_DEADLOCK || l_attempts);
								ROLLBACK;
								l_attempts := l_attempts +1;
								IF l_attempts = 3 THEN
									FOR i IN l_first .. l_last LOOP --{L5
										BEGIN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_UPD || AS_GAR.G_START);
											UPDATE AS_ACCESSES_ALL_ALL ACC
											SET object_version_number =  NVL(object_version_number,0) + 1, ACC.DELETE_FLAG='Y'
											WHERE ACC.sales_lead_id = l_sales_lead_id(i)
											AND ACC.freeze_flag = 'N'
											AND ACC.lead_id IS NULL
											AND ACC.sales_lead_id IS NOT NULL
											AND ACC.delete_flag IS NULL
											AND NOT EXISTS (SELECT  'X'
											  FROM JTF_TAE_1001_LEAD_WINNERS W
											  WHERE  W.trans_object_id = ACC.sales_lead_id
											  AND  W.resource_id = ACC.salesforce_id
											  AND  W.worker_id = l_worker_id
											  AND  W.group_id = ACC.sales_group_id);
											COMMIT;
										EXCEPTION
										WHEN DUP_VAL_ON_INDEX THEN
											BEGIN
												AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_START);
												DELETE FROM AS_ACCESSES_ALL_ALL ACC
												WHERE ACC.sales_lead_id=l_sales_lead_id(i)
												AND ACC.freeze_flag = 'N'
												AND ACC.lead_id IS NULL
												AND ACC.sales_lead_id IS NOT NULL
												AND NOT EXISTS (SELECT  'X'
												  FROM JTF_TAE_1001_LEAD_WINNERS W
												  WHERE  W.trans_object_id = ACC.sales_lead_id
												  AND  W.resource_id = ACC.salesforce_id
												  AND  W.worker_id = l_worker_id
												  AND  W.group_id = ACC.sales_group_id);
											EXCEPTION
											WHEN OTHERS THEN
												AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_GENERAL_EXCEPTION);
												AS_GAR.LOG('SALES_LEAD_ID - ' || l_sales_lead_id(i));
											END;
										END;
									END LOOP; --}L5
									COMMIT;
									l_del_flag := TRUE;
								END IF;
							END; --}I2 end of deadlock exception
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
								IF del_lead_totalmode%ISOPEN THEN CLOSE del_lead_totalmode; END IF;
								IF del_lead_newmode%ISOPEN THEN CLOSE del_lead_newmode; END IF;
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
					IF l_first > l_sales_lead_id.LAST THEN
					    l_flag := FALSE;
					END IF;
				END LOOP;  --}L2  while l_flag loop (10K cust loop)
			END IF;--}I1
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_END);
			COMMIT;
		EXCEPTION
		WHEN Others THEN
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
			IF del_lead_totalmode%ISOPEN THEN CLOSE del_lead_totalmode; END IF;
			IF del_lead_newmode%ISOPEN THEN CLOSE del_lead_newmode; END IF;
			x_errbuf  := SQLERRM;
			x_retcode := SQLCODE;
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE;
		END;
	END LOOP;--}L1
	IF del_lead_totalmode%ISOPEN THEN CLOSE del_lead_totalmode; END IF;
	IF del_lead_newmode%ISOPEN THEN CLOSE del_lead_newmode; END IF;
EXCEPTION
WHEN OTHERS THEN
    AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
    x_errbuf  := SQLERRM;
    x_retcode := SQLCODE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE;
END PERFORM_LEAD_CLEANUP;

/**************************   End Lead Cleanup ***********************/
/****************************   Start Assign Lead Owner  ********************/
PROCEDURE ASSIGN_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    CURSOR lead_owner_totalmode(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id ,
           max(DECODE(aaa.created_by_tap_flag,'Y',aaa.access_id,-999)) access_id
    FROM   AS_ACCESSES_ALL_ALL aaa,
           ( SELECT distinct trans_object_id
             FROM JTF_TAE_1001_LEAD_TRANS
             WHERE worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is NULL
    AND    aaa.sales_lead_id is NOT NULL
    AND    aaa.delete_flag is NULL
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING SUM(DECODE(aaa.CREATED_BY_TAP_FLAG,'Y',1,0)) > 0
    AND    SUM(DECODE(aaa.owner_flag,'Y',1,0)) = 0
    UNION -- Union added for Bug#4035168
    SELECT trans_object_id ,0
    FROM   JTF_TAE_1001_LEAD_TRANS w
    WHERE worker_id = c_worker_id
    AND NOT EXISTS
     (SELECT 'x'
      FROM AS_ACCESSES_ALL aaa
      WHERE aaa.sales_lead_id =w.trans_object_id
      AND (aaa.CREATED_BY_TAP_FLAG = 'Y'
      OR   aaa.owner_flag='Y'));


    CURSOR lead_owner_newmode(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id ,
           max(DECODE(aaa.created_by_tap_flag,'Y',aaa.access_id,-999)) access_id
    FROM   AS_ACCESSES_ALL_ALL aaa,
           ( SELECT distinct trans_object_id
             FROM JTF_TAE_1001_LEAD_NM_TRANS
             WHERE worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    AND    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING SUM(DECODE(aaa.CREATED_BY_TAP_FLAG,'Y',1,0)) > 0
    AND    SUM(DECODE(aaa.owner_flag,'Y',1,0)) = 0
    UNION -- Union added for Bug#4035168
    SELECT trans_object_id ,0
    FROM   JTF_TAE_1001_LEAD_NM_TRANS w
    WHERE worker_id = c_worker_id
    AND NOT EXISTS
     (SELECT 'x'
      FROM AS_ACCESSES_ALL aaa
      WHERE aaa.sales_lead_id =w.trans_object_id
      AND (aaa.CREATED_BY_TAP_FLAG = 'Y'
      OR   aaa.owner_flag='Y'));



   TYPE num_list IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

   l_sales_lead_id num_list;
   l_access_id     num_list;

   l_limit_flag    BOOLEAN := FALSE;
   l_max_fetches   NUMBER  := 10000;
   l_loop_count    NUMBER  := 0;

   l_attempts         NUMBER := 0;
   l_exceptions       BOOLEAN := FALSE;

   l_flag    BOOLEAN;
   l_first   NUMBER;
   l_last    NUMBER;
   l_worker_id    NUMBER;
   l_var     NUMBER;



BEGIN
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_worker_id:=p_terr_globals.worker_id;
    l_var      :=p_terr_globals.bulk_size;
    l_max_fetches := p_terr_globals.cursor_limit;
    IF fnd_profile.value('AS_LEAD_ASSIGNMENT_UHK') = 'Y'
    THEN
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'CUSTOM AS PER PROFILE---AS_LEAD_ASSIGNMENT_UHK:- Y---');
        AS_CUSTOM_HOOKS_UHK.Lead_TOTTAP_Owner_Assignment(
                      p_request_id           => p_terr_globals.request_id,
                      p_worker_id            => p_terr_globals.worker_id,
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data);
    ELSE
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);
		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
			OPEN lead_owner_totalmode(l_worker_id);
			FETCH lead_owner_totalmode BULK COLLECT INTO l_sales_lead_id,l_access_id LIMIT l_max_fetches;
			CLOSE lead_owner_totalmode;
		ELSE
			OPEN lead_owner_newmode(l_worker_id);
			FETCH lead_owner_newmode BULK COLLECT INTO l_sales_lead_id,l_access_id LIMIT l_max_fetches;
			CLOSE lead_owner_newmode;
		END IF;
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_sales_lead_id.COUNT > 0 THEN
			 l_flag := TRUE;
			 l_first := l_sales_lead_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
					l_last := l_sales_lead_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS');
					BEGIN
						 FORALL i in l_first .. l_last
							UPDATE AS_SALES_LEADS sl
							SET	sl.last_update_date = SYSDATE,
								sl.last_updated_by = p_terr_globals.user_id,
								sl.last_update_login = p_terr_globals.last_update_login,
								sl.request_id = p_terr_globals.request_id,
								sl.program_application_id = p_terr_globals.prog_appl_id,
								sl.program_id = p_terr_globals.prog_id,
								sl.program_update_date = SYSDATE,
								( sl.assign_to_salesforce_id,
								  sl.assign_sales_group_id,
								  sl.assign_to_person_id
								) =
								( SELECT salesforce_id,sales_group_id,person_id
								  FROM as_accesses_all_all
								  WHERE access_id = l_access_id(i)
								)
								WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
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
								UPDATE AS_SALES_LEADS sl
								SET	sl.last_update_date = SYSDATE,
									sl.last_updated_by = p_terr_globals.user_id,
									sl.last_update_login = p_terr_globals.last_update_login,
									sl.request_id = p_terr_globals.request_id,
									sl.program_application_id = p_terr_globals.prog_appl_id,
									sl.program_id = p_terr_globals.prog_id,
									sl.program_update_date = SYSDATE,
									( sl.assign_to_salesforce_id,
									sl.assign_sales_group_id,
									sl.assign_to_person_id
									) =
									( SELECT salesforce_id,sales_group_id,person_id
									  FROM as_accesses_all_all
									  WHERE access_id = l_access_id(i)
									)
									WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF SALES LEADS', SQLERRM, TO_CHAR(SQLCODE));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;

				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES');
				l_attempts := 1;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i in l_first .. l_last
						   UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  NVL(object_version_number,0) + 1,
						    ACC.LAST_UPDATE_DATE = SYSDATE,
						    ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
						    ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
						    ACC.REQUEST_ID = p_terr_globals.request_id,
						    ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
						    ACC.PROGRAM_ID = p_terr_globals.prog_id,
						    ACC.PROGRAM_UPDATE_DATE = SYSDATE,
						    ACC.owner_flag = 'Y'
						   WHERE ACC.access_id = l_access_id(i);
						 COMMIT;
						 l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES::' || AS_GAR.G_N_ROWS_PROCESSED || l_first || ' - '|| l_last);
					EXCEPTION
					WHEN deadlock_detected THEN
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES::' || AS_GAR.G_DEADLOCK ||l_attempts );
						l_attempts := l_attempts +1;
						ROLLBACK;
						IF l_attempts = 3 THEN
							FOR i IN l_first .. l_last LOOP
								BEGIN
								       UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  NVL(object_version_number,0) + 1,
									ACC.LAST_UPDATE_DATE = SYSDATE,
									ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
									ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
									ACC.REQUEST_ID = p_terr_globals.request_id,
									ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
									ACC.PROGRAM_ID = p_terr_globals.prog_id,
									ACC.PROGRAM_UPDATE_DATE = SYSDATE,
									ACC.owner_flag = 'Y'
									WHERE ACC.access_id = l_access_id(i);
								EXCEPTION
								WHEN OTHERS THEN
									AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF SALES LEADS ACCESSES', SQLERRM, TO_CHAR(SQLCODE));
								END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE SALES_LEADS ACCESSES', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_sales_lead_id.LAST THEN
				     l_flag := FALSE;
				END IF;
			END LOOP;
		END IF; --l_sales_lead_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_sales_lead_id.COUNT);
	END LOOP;
	l_limit_flag    := FALSE;
	l_loop_count    := 0;
	l_access_id.delete;
	l_sales_lead_id.delete;
	l_attempts    := 1;
    END IF; -- (Custom or Non Custom)

EXCEPTION
WHEN OTHERS THEN
	AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
	x_errbuf  := SQLERRM;
	x_retcode := SQLCODE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE;
END ASSIGN_LEAD_OWNER;

/****************************   End Assign Lead Owner  ********************/
/****************************   Start Assign_Default_Lead_Owner  ********************/
PROCEDURE ASSIGN_DEFAULT_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

   CURSOR tot_lead_owner_def(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from jtf_tae_1001_lead_trans
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING sum(decode(aaa.owner_flag,'Y',1,0)) = 0
    UNION -- Union added for Bug#4035168
     select trans_object_id from jtf_tae_1001_lead_trans w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);

   CURSOR tot_lead_owner_tap(c_worker_id number) IS
    Select trans_object_id from jtf_tae_1001_lead_trans w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);

   CURSOR new_lead_owner_def(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from JTF_TAE_1001_LEAD_NM_TRANS
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING sum(decode(aaa.owner_flag,'Y',1,0)) = 0
    UNION -- Union added for Bug#4035168
     select trans_object_id from JTF_TAE_1001_LEAD_NM_TRANS w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);

   CURSOR new_lead_owner_tap(c_worker_id number) IS
    Select trans_object_id from JTF_TAE_1001_LEAD_NM_TRANS w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);

   CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

   TYPE num_list IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

   l_sales_lead_id num_list;
   l_access_id     num_list;

   l_limit_flag    BOOLEAN := FALSE;
   l_max_fetches   NUMBER  := 10000;
   l_loop_count    NUMBER  := 0;

   l_attempts         NUMBER := 0;
   l_exceptions       BOOLEAN := FALSE;

   l_flag    BOOLEAN;
   l_first   NUMBER;
   l_last    NUMBER;
   l_worker_id    NUMBER;
   l_var     NUMBER;

   l_assign_manual_flag   VARCHAR2(1);
   l_resource_id          NUMBER;
   l_group_id             NUMBER;
   l_person_id            NUMBER;

BEGIN
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_worker_id:=p_terr_globals.worker_id;
    l_var      :=p_terr_globals.bulk_size;
    l_max_fetches := p_terr_globals.cursor_limit;

    l_assign_manual_flag := nvl(FND_PROFILE.Value('AS_LEAD_ASSIGN_MANUAL'),'N');

    IF fnd_profile.value('AS_LEAD_ASSIGNMENT_UHK') = 'Y'
    THEN
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'CUSTOM AS PER PROFILE---AS_LEAD_ASSIGNMENT_UHK:- Y---');
        AS_CUSTOM_HOOKS_UHK.Lead_TOTTAP_Owner_Assignment(
                      p_request_id           => p_terr_globals.request_id,
                      p_worker_id            => p_terr_globals.worker_id,
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data);
    ELSE

	 l_resource_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');

	 OPEN c_get_group_id (l_resource_id);
	 FETCH c_get_group_id INTO l_group_id;
	 CLOSE c_get_group_id;
	 OPEN c_get_person_id (l_resource_id);
	 FETCH c_get_person_id INTO l_person_id;
	 CLOSE c_get_person_id;
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);

		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
		   IF l_assign_manual_flag = 'N' THEN
			OPEN  tot_lead_owner_tap(l_worker_id);
			FETCH tot_lead_owner_tap BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE tot_lead_owner_tap;
		   ELSE
		        OPEN  tot_lead_owner_def(l_worker_id);
			FETCH tot_lead_owner_def BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE tot_lead_owner_def;
		   END IF;
		ELSE
		   IF l_assign_manual_flag = 'N' THEN
			OPEN  new_lead_owner_tap(l_worker_id);
			FETCH new_lead_owner_tap BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE new_lead_owner_tap;
		   ELSE
		        OPEN  new_lead_owner_def(l_worker_id);
			FETCH new_lead_owner_def BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE new_lead_owner_def;
		   END IF;
		END IF;

		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_sales_lead_id.COUNT > 0 THEN
			 l_flag := TRUE;
			 l_first := l_sales_lead_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
					l_last := l_sales_lead_id.LAST;
				END IF;

				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'INSERT INTO AS_ACCESSES_ALL_ALL');
					BEGIN
						 FORALL i in l_first .. l_last
						      INSERT INTO AS_ACCESSES_ALL_ALL
							(ACCESS_ID,
							  LAST_UPDATE_DATE,
							  LAST_UPDATED_BY,
							  CREATION_DATE,
							  CREATED_BY,
							  LAST_UPDATE_LOGIN,
							  PROGRAM_APPLICATION_ID,
							  PROGRAM_UPDATE_DATE,
							  ACCESS_TYPE,
							  FREEZE_FLAG,
							  REASSIGN_FLAG,
							  TEAM_LEADER_FLAG,
							  OWNER_FLAG,
							  CREATED_BY_TAP_FLAG,
							  CUSTOMER_ID,
							  ADDRESS_ID,
							  SALES_LEAD_ID,
							  SALESFORCE_ID,
							  PERSON_ID,
							  SALES_GROUP_ID,
							  REQUEST_ID,
							  OPEN_FLAG,
							  LEAD_RANK_SCORE,
							  OBJECT_CREATION_DATE)
						      ( SELECT
							  as_accesses_s.nextval,
							  SYSDATE,
							  p_terr_globals.user_id,
							  SYSDATE,
							  p_terr_globals.user_id,
							  p_terr_globals.last_update_login,
							  p_terr_globals.prog_appl_id,
							  SYSDATE,
							  'X',
							  NVL(L.accept_flag, 'N'),
							  'N',
							  'Y',
							  'Y',
							  'N',
							  L.customer_id,
							  L.address_id,
							  l_sales_lead_id(i),
							  l_resource_id,
							  l_person_id,
							  l_group_id,
							  p_terr_globals.request_id,
							  L.status_open_flag,
							  L.lead_rank_score,
							  L.creation_date
						       FROM DUAL ,
							    AS_SALES_LEADS L
						       WHERE L.sales_lead_id = l_sales_lead_id(i)
						       AND NOT EXISTS ( select 'X'
								    from AS_ACCESSES_ALL_ALL aa
								    where aa.sales_lead_id is not null
								    and aa.lead_id is null
								    and aa.delete_flag is null
								    and aa.sales_lead_id = l_sales_lead_id(i)
								    and aa.salesforce_id = l_resource_id
								    and nvl(aa.sales_group_id,-777) = nvl(l_group_id,-777)
								      )
							);

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
								INSERT INTO AS_ACCESSES_ALL_ALL
								(ACCESS_ID,
								  LAST_UPDATE_DATE,
								  LAST_UPDATED_BY,
								  CREATION_DATE,
								  CREATED_BY,
								  LAST_UPDATE_LOGIN,
								  PROGRAM_APPLICATION_ID,
								  PROGRAM_UPDATE_DATE,
								  ACCESS_TYPE,
								  FREEZE_FLAG,
								  REASSIGN_FLAG,
								  TEAM_LEADER_FLAG,
								  OWNER_FLAG,
								  CREATED_BY_TAP_FLAG,
								  CUSTOMER_ID,
								  ADDRESS_ID,
								  SALES_LEAD_ID,
								  SALESFORCE_ID,
								  PERSON_ID,
								  SALES_GROUP_ID,
								  REQUEST_ID,
								  OPEN_FLAG,
								  LEAD_RANK_SCORE,
								  OBJECT_CREATION_DATE)
							      ( SELECT
								  as_accesses_s.nextval,
								  SYSDATE,
								  p_terr_globals.user_id,
								  SYSDATE,
								  p_terr_globals.user_id,
								  p_terr_globals.last_update_login,
								  p_terr_globals.prog_appl_id,
								  SYSDATE,
								  'X',
								  NVL(L.accept_flag, 'N'),
								  'N',
								  'Y',
								  'Y',
								  'N',
								  L.customer_id,
								  L.address_id,
								  l_sales_lead_id(i),
								  l_resource_id,
								  l_person_id,
								  l_group_id,
								  p_terr_globals.request_id,
								  L.status_open_flag,
								  L.lead_rank_score,
								  L.creation_date
							       FROM DUAL ,
								    AS_SALES_LEADS L
							       WHERE L.sales_lead_id = l_sales_lead_id(i)
							       AND NOT EXISTS ( select 'X'
									    from AS_ACCESSES_ALL_ALL aa
									    where aa.sales_lead_id is not null
									    and aa.lead_id is null
									    and aa.delete_flag is null
									    and aa.sales_lead_id = l_sales_lead_id(i)
									    and aa.salesforce_id = l_resource_id
									    and nvl(aa.sales_group_id,-777) = nvl(l_group_id,-777)
									      )
								);
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW INSERT INTO AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'INSERT INTO AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;

				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES_ALL_ALL');
					BEGIN
						 FORALL i in l_first .. l_last
							UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  nvl(object_version_number,0) + 1,
							     ACC.LAST_UPDATE_DATE = SYSDATE,
							     ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
							     ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
							     ACC.REQUEST_ID = p_terr_globals.request_id,
							     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
							     ACC.PROGRAM_ID = p_terr_globals.prog_id,
							     ACC.PROGRAM_UPDATE_DATE = SYSDATE,
							     ACC.owner_flag = 'Y'
							    WHERE ACC.sales_lead_id is not null
							      and ACC.lead_id is null
							      and ACC.delete_flag is null
							      and ACC.sales_lead_id = l_sales_lead_id(i)
							      and ACC.salesforce_id = l_resource_id
							      and nvl(ACC.sales_group_id,-777) = nvl(l_group_id,-777);
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
								UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  nvl(object_version_number,0) + 1,
									ACC.LAST_UPDATE_DATE = SYSDATE,
									ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
									ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
									ACC.REQUEST_ID = p_terr_globals.request_id,
									ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
									ACC.PROGRAM_ID = p_terr_globals.prog_id,
									ACC.PROGRAM_UPDATE_DATE = SYSDATE,
									ACC.owner_flag = 'Y'
								      WHERE ACC.sales_lead_id is not null
									and ACC.lead_id is null
									and ACC.delete_flag is null
									and ACC.sales_lead_id = l_sales_lead_id(i)
									and ACC.salesforce_id = l_resource_id
									and nvl(ACC.sales_group_id,-777) = nvl(l_group_id,-777);
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;

				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS');
				l_attempts := 1;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i in l_first .. l_last
						   UPDATE AS_SALES_LEADS sl SET
						     sl.last_update_date = SYSDATE,
						     sl.last_updated_by = p_terr_globals.user_id,
						     sl.last_update_login = p_terr_globals.last_update_login,
						     sl.request_id = p_terr_globals.request_id,
						     sl.program_application_id = p_terr_globals.prog_appl_id,
						     sl.program_id = p_terr_globals.prog_id,
						     sl.program_update_date = SYSDATE,
						     sl.assign_to_salesforce_id = l_resource_id,
						     sl.assign_sales_group_id = l_group_id,
						     sl.assign_to_person_id = l_person_id
						    WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
						 COMMIT;
						 l_attempts := 3;
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS::' || AS_GAR.G_N_ROWS_PROCESSED || l_first || ' - '|| l_last);
					EXCEPTION
					WHEN deadlock_detected THEN
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS::' || AS_GAR.G_DEADLOCK ||l_attempts );
						l_attempts := l_attempts +1;
						ROLLBACK;
						IF l_attempts = 3 THEN
							FOR i IN l_first .. l_last LOOP
								BEGIN
								       UPDATE AS_SALES_LEADS sl SET
									     sl.last_update_date = SYSDATE,
									     sl.last_updated_by = p_terr_globals.user_id,
									     sl.last_update_login = p_terr_globals.last_update_login,
									     sl.request_id = p_terr_globals.request_id,
									     sl.program_application_id = p_terr_globals.prog_appl_id,
									     sl.program_id = p_terr_globals.prog_id,
									     sl.program_update_date = SYSDATE,
									     sl.assign_to_salesforce_id = l_resource_id,
									     sl.assign_sales_group_id = l_group_id,
									     sl.assign_to_person_id = l_person_id
									    WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
								EXCEPTION
								WHEN OTHERS THEN
									AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE AS_SALES_LEADS', SQLERRM, TO_CHAR(SQLCODE));
								END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_sales_lead_id.LAST THEN
				     l_flag := FALSE;
				END IF;
			END LOOP;
		END IF; --l_sales_lead_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_sales_lead_id.COUNT);
	END LOOP;
	l_limit_flag    := FALSE;
	l_loop_count    := 0;
	l_access_id.delete;
	l_sales_lead_id.delete;
	l_attempts    := 1;
    END IF; -- (Custom or Non Custom)

EXCEPTION
WHEN OTHERS THEN
	AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
	x_errbuf  := SQLERRM;
	x_retcode := SQLCODE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE;
END ASSIGN_DEFAULT_LEAD_OWNER;

/****************************   End Assign_Default_Lead_Owner  ********************/
/****************************   Start Uncheck_Lead_Owner  ********************/
PROCEDURE UNCHECK_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    CURSOR tot_lead_owner(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from jtf_tae_1001_lead_trans
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING sum(decode(aaa.owner_flag,'Y',1,0)) = 1;

    CURSOR new_lead_owner(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from JTF_TAE_1001_LEAD_NM_TRANS
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    HAVING sum(decode(aaa.owner_flag,'Y',1,0)) = 1;

   TYPE num_list IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

   l_sales_lead_id num_list;
   l_access_id     num_list;

   l_limit_flag    BOOLEAN := FALSE;
   l_max_fetches   NUMBER  := 10000;
   l_loop_count    NUMBER  := 0;

   l_attempts         NUMBER := 0;
   l_exceptions       BOOLEAN := FALSE;

   l_flag    BOOLEAN;
   l_first   NUMBER;
   l_last    NUMBER;
   l_worker_id    NUMBER;
   l_var     NUMBER;

BEGIN
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_worker_id:=p_terr_globals.worker_id;
    l_var      :=p_terr_globals.bulk_size;
    l_max_fetches := p_terr_globals.cursor_limit;
    IF fnd_profile.value('AS_LEAD_ASSIGNMENT_UHK') = 'Y'
    THEN
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'CUSTOM AS PER PROFILE---AS_LEAD_ASSIGNMENT_UHK:- Y---');
        AS_CUSTOM_HOOKS_UHK.Lead_TOTTAP_Owner_Assignment(
                      p_request_id           => p_terr_globals.request_id,
                      p_worker_id            => p_terr_globals.worker_id,
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data);
    ELSE
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);
		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
			OPEN  tot_lead_owner(l_worker_id);
			FETCH tot_lead_owner BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE tot_lead_owner;
		ELSE
			OPEN  new_lead_owner(l_worker_id);
			FETCH new_lead_owner BULK COLLECT INTO l_sales_lead_id LIMIT l_max_fetches;
			CLOSE new_lead_owner;
		END IF;
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_sales_lead_id.COUNT > 0 THEN
			 l_flag := TRUE;
			 l_first := l_sales_lead_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
					l_last := l_sales_lead_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES_ALL_ALL');
					BEGIN
						 FORALL i in l_first .. l_last
							UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  nvl(object_version_number,0) + 1,
							     ACC.LAST_UPDATE_DATE = SYSDATE,
							     ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
							     ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
							     ACC.REQUEST_ID = p_terr_globals.request_id,
							     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
							     ACC.PROGRAM_ID = p_terr_globals.prog_id,
							     ACC.PROGRAM_UPDATE_DATE = SYSDATE,
							     ACC.owner_flag = 'N'
							    WHERE ACC.sales_lead_id = l_sales_lead_id(i)
							      and ACC.owner_flag = 'Y'
							      and ACC.freeze_flag = 'N';
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
								UPDATE  AS_ACCESSES_ALL_ALL ACC SET object_version_number =  nvl(object_version_number,0) + 1,
								     ACC.LAST_UPDATE_DATE = SYSDATE,
								     ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
								     ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
								     ACC.REQUEST_ID = p_terr_globals.request_id,
								     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
								     ACC.PROGRAM_ID = p_terr_globals.prog_id,
								     ACC.PROGRAM_UPDATE_DATE = SYSDATE,
								     ACC.owner_flag = 'N'
								    WHERE ACC.sales_lead_id = l_sales_lead_id(i)
								      and ACC.owner_flag = 'Y'
								      and ACC.freeze_flag = 'N';
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_ACCESSES_ALL_ALL', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;

				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_sales_lead_id.LAST THEN
				     l_flag := FALSE;
				END IF;
			END LOOP;
		END IF; --l_sales_lead_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_sales_lead_id.COUNT);
	END LOOP;
	l_limit_flag    := FALSE;
	l_loop_count    := 0;
	l_access_id.delete;
	l_sales_lead_id.delete;
	l_attempts    := 1;
    END IF; -- (Custom or Non Custom)

EXCEPTION
WHEN OTHERS THEN
	AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
	x_errbuf  := SQLERRM;
	x_retcode := SQLCODE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE;
END UNCHECK_LEAD_OWNER;

/****************************   End Uncheck_Lead_Owner  ********************/
/****************************   Start Uncheck_Assign_Salesforce  ********************/
PROCEDURE UNCHECK_ASSIGN_SALESFORCE(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    CURSOR tot_lead_owner(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id ,
           max(decode(aaa.owner_flag,'Y',aaa.access_id,-999)) access_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from jtf_tae_1001_lead_trans
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    UNION -- Union added for Bug#4035168
     select trans_object_id ,0 from jtf_tae_1001_lead_trans w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);


   CURSOR new_lead_owner(c_worker_id number) IS
    SELECT /*+ index(aaa as_accesses_n6) */ aaa.sales_lead_id ,
           max(decode(aaa.owner_flag,'Y',aaa.access_id,-999)) access_id
    FROM   as_accesses_all_all aaa,
           ( select distinct trans_object_id
             from JTF_TAE_1001_LEAD_NM_TRANS
             where worker_id=c_worker_id ) w
    WHERE  aaa.lead_id is null
    and    aaa.delete_flag is null
    AND    aaa.sales_lead_id=w.trans_object_id
    AND    aaa.sales_lead_id+0=w.trans_object_id
    GROUP BY aaa.sales_lead_id
    UNION -- Union added for Bug#4035168
     select trans_object_id ,0 from JTF_TAE_1001_LEAD_NM_TRANS w
     where worker_id = c_worker_id and not exists
     (select 'x' from as_accesses_all aaa
      where aaa.sales_lead_id =w.trans_object_id);

   TYPE num_list IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

   l_sales_lead_id num_list;
   l_access_id     num_list;

   l_limit_flag    BOOLEAN := FALSE;
   l_max_fetches   NUMBER  := 10000;
   l_loop_count    NUMBER  := 0;

   l_attempts         NUMBER := 0;
   l_exceptions       BOOLEAN := FALSE;

   l_flag    BOOLEAN;
   l_first   NUMBER;
   l_last    NUMBER;
   l_worker_id    NUMBER;
   l_var     NUMBER;

BEGIN
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_START);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_worker_id:=p_terr_globals.worker_id;
    l_var      :=p_terr_globals.bulk_size;
    l_max_fetches := p_terr_globals.cursor_limit;
    IF fnd_profile.value('AS_LEAD_ASSIGNMENT_UHK') = 'Y'
    THEN
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'CUSTOM AS PER PROFILE---AS_LEAD_ASSIGNMENT_UHK:- Y---');
        AS_CUSTOM_HOOKS_UHK.Lead_TOTTAP_Owner_Assignment(
                      p_request_id           => p_terr_globals.request_id,
                      p_worker_id            => p_terr_globals.worker_id,
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data);
    ELSE
	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'LOOPCOUNT:- '|| l_loop_count);
		IF p_terr_globals.run_mode = AS_GAR.G_TOTAL_MODE THEN
			OPEN  tot_lead_owner(l_worker_id);
			FETCH tot_lead_owner BULK COLLECT INTO l_sales_lead_id,l_access_id LIMIT l_max_fetches;
			CLOSE tot_lead_owner;
		ELSE
			OPEN  new_lead_owner(l_worker_id);
			FETCH new_lead_owner BULK COLLECT INTO l_sales_lead_id,l_access_id LIMIT l_max_fetches;
			CLOSE new_lead_owner;
		END IF;
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_sales_lead_id.COUNT < l_max_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_sales_lead_id.COUNT > 0 THEN
			 l_flag := TRUE;
			 l_first := l_sales_lead_id.FIRST;
			 l_last := l_first + l_var;
			 WHILE l_flag LOOP
				IF l_last > l_sales_lead_id.LAST THEN
					l_last := l_sales_lead_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS');
					BEGIN
						 FORALL i in l_first .. l_last
							UPDATE AS_SALES_LEADS sl SET
							     sl.last_update_date = SYSDATE,
							     sl.last_updated_by = p_terr_globals.user_id,
							     sl.last_update_login = p_terr_globals.last_update_login,
							     sl.request_id = p_terr_globals.request_id,
							     sl.program_application_id = p_terr_globals.prog_appl_id,
							     sl.program_id = p_terr_globals.prog_id,
							     sl.program_update_date = SYSDATE,
							     ( sl.assign_to_salesforce_id,
							       sl.assign_sales_group_id,
							       sl.assign_to_person_id
							     ) =
							     ( SELECT salesforce_id,sales_group_id,person_id
							       FROM as_accesses_all_all
							       WHERE access_id = l_access_id(i)
							     )
							    WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
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
								UPDATE AS_SALES_LEADS sl SET
								     sl.last_update_date = SYSDATE,
								     sl.last_updated_by = p_terr_globals.user_id,
								     sl.last_update_login = p_terr_globals.last_update_login,
								     sl.request_id = p_terr_globals.request_id,
								     sl.program_application_id = p_terr_globals.prog_appl_id,
								     sl.program_id = p_terr_globals.prog_id,
								     sl.program_update_date = SYSDATE,
								     ( sl.assign_to_salesforce_id,
								       sl.assign_sales_group_id,
								       sl.assign_to_person_id
								     ) =
								     ( SELECT salesforce_id,sales_group_id,person_id
								       FROM as_accesses_all_all
								       WHERE access_id = l_access_id(i)
								     )
								    WHERE sl.sales_lead_id = l_sales_lead_id(i) ;
							EXCEPTION
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'ROW-BY-ROW UPDATE OF SALES LEADS', SQLERRM, TO_CHAR(SQLCODE));
							END;
							END LOOP;
							COMMIT;
						END IF;
					END; -- end of deadlock exception
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || 'UPDATE AS_SALES_LEADS', SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE;
					END;
				END LOOP;

				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_sales_lead_id.LAST THEN
				     l_flag := FALSE;
				END IF;
			END LOOP;
		END IF; --l_sales_lead_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_N_ROWS_PROCESSED || l_sales_lead_id.COUNT);
	END LOOP;
	l_limit_flag    := FALSE;
	l_loop_count    := 0;
	l_access_id.delete;
	l_sales_lead_id.delete;
	l_attempts    := 1;
    END IF; -- (Custom or Non Custom)

EXCEPTION
WHEN OTHERS THEN
	AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CO || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
	x_errbuf  := SQLERRM;
	x_retcode := SQLCODE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE;
END UNCHECK_ASSIGN_SALESFORCE;

/****************************   End Uncheck_Assign_Salesforce  ********************/

END AS_GAR_LEADS_PUB;


/
