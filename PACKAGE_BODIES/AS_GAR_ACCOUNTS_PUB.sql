--------------------------------------------------------
--  DDL for Package Body AS_GAR_ACCOUNTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_GAR_ACCOUNTS_PUB" AS
/* $Header: asxgracb.pls 120.11.12000000.2 2007/05/05 08:30:51 annsrini ship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR_ACCOUNTS_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--    --------
--    This package contains procedures to accomplish each of the following
--    tasks:
--    1: Call the JTY API to process data from JTY trans tables and
--       populate JTY winners.
--    2: Merge and insert records from winners into AS_ACCESSES_ALL_ALL
--    3: Soft Delete unwanted records from AS_ACCESSES_ALL_ALL
--
--    NOTE: No Owner Assignment and Cleanup steps required for Accounts
--    3-5-2007 annsrini included 2 cursors c_src and ins_acc. Also modified ins_acc2 cursor and INSERT_ACCESS_ACCOUNTS procedure to populate
--                  salesforce_role_code into as_accesses_all table by fetching it from as_terr_resources_tmp table. fix for bug (5869095)
---------------------------------------------------------------------------
/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_BUSINESS_EVENT  CONSTANT VARCHAR2(60) := 'oracle.apps.as.tap.batch_mode';
  DEADLOCK_DETECTED EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
  G_ENTITY CONSTANT VARCHAR2(15) := 'GAR::ACCOUNTS::';
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
    l_count         NUMBER;
CURSOR get_count(c_worker_id number) IS
		SELECT COUNT(*)
		FROM   JTF_TAE_1001_ACCOUNT_WINNERS
		WHERE  worker_id = c_worker_id
		AND    resource_type IN ('RS_PARTNER','RS_PARTY')
		AND    ROWNUM < 2;
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

    /* This inserts into account winners */
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);
    JTY_ASSIGN_BULK_PUB.GET_WINNERS
    ( p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.G_TRUE,
      p_source_id             => -1001,
      p_trans_id	      => -1002,
      P_PROGRAM_NAME          => 'SALES/ACCOUNT PROGRAM',
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
    AS_GAR_ACCOUNTS_PUB.EXPLODE_GROUPS_ACCOUNTS(
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
    AS_GAR_ACCOUNTS_PUB.EXPLODE_TEAMS_ACCOUNTS(
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
    AS_GAR_ACCOUNTS_PUB.SET_TEAM_LEAD_ACCOUNTS(
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

	 -- Insert into Account Accesses from Winners
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
    AS_GAR_ACCOUNTS_PUB.INSERT_ACCESSES_ACCOUNTS(
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
    AS_GAR_ACCOUNTS_PUB.INSERT_TERR_ACCESSES_ACCOUNTS(
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

    -- Create External Sales Team records for Account  (No partner processing for opptys and leads)
    OPEN   get_count(l_terr_globals.worker_id);
    FETCH  get_count INTO  l_count;
    CLOSE  get_count;
    IF l_count > 0  THEN -- If There are any PRM Resources assigned in JTY
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || 'PRM:: ' || AS_GAR.G_START);
	    AS_GAR_ACCOUNTS_PUB.SET_TEAM_LEAD_PRM_ACCOUNTS(
		x_errbuf        => l_errbuf,
		x_retcode       => l_retcode,
		p_terr_globals  => l_terr_globals,
		x_return_status => l_return_status);

	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || 'PRM:: ' || AS_GAR.G_END);
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || 'PRM:: ' || AS_GAR.G_RETURN_STATUS || l_return_status);

	    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
	      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || 'PRM:: ', l_errbuf, l_retcode);
	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    End If;

		 -- Insert into Account Accesses from Winners
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || 'PRM:: ' || AS_GAR.G_START);
	    AS_GAR_ACCOUNTS_PUB.INSERT_ACCESSES_PRM_ACCOUNTS(
		x_errbuf        => l_errbuf,
		x_retcode       => l_retcode,
		p_terr_globals  => l_terr_globals,
		x_return_status => l_return_status);

	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || 'PRM:: ' || AS_GAR.G_END);
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || 'PRM:: ' || AS_GAR.G_RETURN_STATUS || l_return_status);

	    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
	      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || 'PRM:: ', l_errbuf, l_retcode);
	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    End If;

		 -- Insert into territory Accesses
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || 'PRM:: ' || AS_GAR.G_START);
	    AS_GAR_ACCOUNTS_PUB.INSERT_TERR_ACCESSES_PRM_ACCS(
		x_errbuf        => l_errbuf,
		x_retcode       => l_retcode,
		p_terr_globals  => l_terr_globals,
		x_return_status => l_return_status);

	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || 'PRM:: ' || AS_GAR.G_END);
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || 'PRM:: ' || AS_GAR.G_RETURN_STATUS || l_return_status);

	    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
	      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || 'PRM:: ', l_errbuf, l_retcode);
	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    End If;

    END IF;

    -- Remove (soft delete) records in access table that are not qualified
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_START);
    AS_GAR_ACCOUNTS_PUB.Perform_Account_Cleanup(
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

/************************** Start Explode Teams Accounts ******************/
PROCEDURE EXPLODE_TEAMS_ACCOUNTS(
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
l_res_acct_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_ACCOUNT_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;

CURSOR count_res_account
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_TEAM'
AND acc.access_type = 'ACCOUNT'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;


BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_request_id    := p_terr_globals.request_id;
   l_worker_id     := p_terr_globals.worker_id;
   l_resource_type := 'RS_TEAM';

   OPEN  count_res_account;
      FETCH  count_res_account INTO   l_res_acct_count;
   CLOSE  count_res_account;

   IF l_res_acct_count > 0 THEN
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
	       INSERT INTO JTF_TAE_1001_ACCOUNT_WINNERS
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
               JTF_TAE_1001_ACCOUNT_WINNERS T,
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
        AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_ACCOUNT_WINNERS rt1
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
END EXPLODE_TEAMS_ACCOUNTS;
/************************** End Explode Teams Accounts ******************/

/************************** Start Explode Groups Accounts ******************/
PROCEDURE EXPLODE_GROUPS_ACCOUNTS(
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
l_res_acct_count NUMBER;
l_resource_type VARCHAR2(10);
l_request_id     NUMBER;
l_worker_id      NUMBER;

CURSOR c_get_res_type_count(c_resource_type VARCHAR2, c_request_id NUMBER, c_worker_id NUMBER)
IS
SELECT count(*)
FROM   JTF_TAE_1001_ACCOUNT_WINNERS
WHERE  request_id = c_request_id
AND    resource_type = c_resource_type
AND    worker_id = c_worker_id
AND    ROWNUM < 2;


CURSOR count_res_account
IS
SELECT count(*)
FROM    JTF_TERR_RSC_ALL rsc,
        JTF_TERR_DENORM_RULES_ALL rules,
        JTF_TERR_RSC_ACCESS_ALL acc
WHERE rules.terr_id = rsc.terr_id
AND rsc.resource_type = 'RS_GROUP'
AND acc.access_type = 'ACCOUNT'
AND rules.source_id = -1001
AND rsc.terr_rsc_id = acc.terr_rsc_id;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_resource_type := 'RS_GROUP';
     l_request_id    := p_terr_globals.request_id;
     l_worker_id     := p_terr_globals.worker_id;

     OPEN  count_res_account;
      FETCH  count_res_account INTO   l_res_acct_count;
     CLOSE  count_res_account;

     IF l_res_acct_count > 0 THEN
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

    		INSERT INTO JTF_TAE_1001_ACCOUNT_WINNERS
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
                  JTF_TAE_1001_ACCOUNT_WINNERS t,
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
          AND NOT EXISTS (SELECT 1 FROM JTF_TAE_1001_ACCOUNT_WINNERS rt1
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
END EXPLODE_GROUPS_ACCOUNTS;
/************************** End Explode Groups Accounts ******************/

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

PROCEDURE SET_TEAM_LEAD_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list            is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;

    l_customer_id      num_list;
    l_salesforce_id    num_list;
    l_sales_group_id   num_list;
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
	    SELECT /*+ LEADING(WIN) */ A.customer_id, -- The use nested loop hint is removed in ACCOUNTS ONLY..
		   A.salesforce_id,
		   A.sales_group_id,
		   NVL(WIN.full_access_flag,'N')
	    FROM AS_ACCESSES_ALL_ALL A,
		 JTF_TAE_1001_ACCOUNT_WINNERS WIN
	    WHERE A.lead_id is NULL
	    AND   A.delete_flag is NULL
	    AND   A.sales_lead_id is NULL
	    AND   NVL(A.team_leader_flag,'N') <> NVL(WIN.full_access_flag,'N')
	    AND   WIN.SOURCE_ID = -1001
	    AND   WIN.worker_id = c_worker_id
	    AND   WIN.resource_type ='RS_EMPLOYEE'
	    AND   WIN.trans_object_id = A.customer_id
	    AND   WIN.resource_id     = A.salesforce_id
	    AND   WIN.group_id = A.sales_group_id
	    GROUP BY A.customer_id,
		     A.salesforce_id,
		     A.sales_group_id,
		     WIN.full_access_flag;


BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
		IF (l_limit_flag) THEN EXIT; END IF;

		l_customer_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_faf.DELETE;
		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'LOOPCOUNT :- ' || l_loop_count);

		--------------------------------
		OPEN team_leader(l_worker_id);
		    FETCH team_leader BULK COLLECT INTO
			      l_customer_id, l_salesforce_id, l_sales_group_id, l_faf
		    LIMIT l_MAX_fetches;
		CLOSE team_leader;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;
		l_attempts := 1;

		IF l_customer_id.COUNT < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

		IF  l_customer_id.COUNT > 0 THEN
			l_flag := TRUE;
			l_first := l_customer_id.FIRST;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_customer_id.LAST THEN
					l_last := l_customer_id.LAST;
				END IF;
				WHILE l_attempts < 3 LOOP
					BEGIN
						FORALL i IN l_first .. l_last
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
							WHERE    ACC.lead_id is NULL
							 AND     ACC.delete_flag is NULL
							 AND	 ACC.sales_lead_id is NULL
							 AND 	 ACC.customer_id    = l_customer_id(i)
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
										 AND     ACC.delete_flag is NULL
										 AND	 ACC.sales_lead_id is NULL
										 AND	 ACC.customer_id    = l_customer_id(i)
										 AND	 ACC.salesforce_id  = l_salesforce_id(i)
										 AND	 ACC.sales_group_id = l_sales_group_id(i);
									EXCEPTION
									WHEN OTHERS THEN
										AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
										AS_GAR.LOG('CUSTOMER_ID/SALESFORCE_ID/SALESGROUP_ID/ORG_ID - ' || l_customer_id(i) || '/' || l_salesforce_id(i) || '/' || l_sales_group_id(i));
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
				IF l_first > l_customer_id.LAST THEN
					l_flag := FALSE;
				END IF;
			END LOOP; -- loop for more records within the bulk_size
		END IF; --l_customer_id.count > 0
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_N_ROWS_PROCESSED || l_customer_id.COUNT);
	END LOOP; -- loop for more bulk_size fetches
	l_customer_id.DELETE;
	l_salesforce_id.DELETE;
	l_sales_group_id.DELETE;
	l_faf.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END SET_TEAM_LEAD_ACCOUNTS;

/************************** End Set Accounts Team Leader *****************/

/************************** Start Insert Into Entity Accesses*************/

PROCEDURE INSERT_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list            is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE resource_type_list  is TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;

    l_customer_id      num_list;
    l_org_id           num_list; ---?
    l_salesforce_id    num_list;
    l_sales_group_id   num_list;
    l_address_id       num_list;
    l_faf              faf_list;
    l_person_id        num_list;
    l_src             resource_type_list;
    l_resource_type    resource_type_list;

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
	       MIN(W.person_id) person_id,
	       W.trans_object_id cus_id,
	       MIN(W.trans_detail_object_id) add_id,
	       MAX(W.full_access_flag) faf,
	       W.resource_type,
	       org_id,
	       NULL
	FROM  JTF_TAE_1001_ACCOUNT_WINNERS W
	WHERE W.source_id = -1001
	AND W.worker_id = c_worker_id
	AND W.resource_type ='RS_EMPLOYEE'
	AND W.group_id is NOT NULL
	GROUP BY W.trans_object_id,
		 W.resource_id,
		 W.group_id,
		 W.resource_type,
		 W.org_id;

    CURSOR ins_acc(c_worker_id number) IS
    SELECT W.RESOURCE_ID,
           W.GROUP_ID GRP_ID,
           MIN(W.PERSON_ID) PERSON_ID,
           W.TRANS_OBJECT_ID CUS_ID,
           MIN(W.TRANS_DETAIL_OBJECT_ID) ADD_ID,
           MAX(W.FULL_ACCESS_FLAG) FAF,
	     W.RESOURCE_TYPE,
           ORG_ID,
           ATR.RESOURCE_TYPE SALESFORCE_ROLE_CODE
    FROM  JTF_TAE_1001_ACCOUNT_WINNERS W,
          AS_TERR_RESOURCES_TMP ATR
    WHERE W.SOURCE_ID = -1001
    AND W.worker_id = c_worker_id
    AND W.RESOURCE_TYPE = 'RS_EMPLOYEE'
    AND W.PERSON_ID=ATR.RESOURCE_ID(+)
    GROUP BY W.TRANS_OBJECT_ID,
             W.RESOURCE_ID,
             W.GROUP_ID,
		 W.RESOURCE_TYPE,
             W.ORG_ID,
             ATR.RESOURCE_TYPE;

        CURSOR c_src IS
        select 'Y'
        from dual
        where exists ( SELECT 'Y'
                       FROM  FND_PROFILE_OPTION_VALUES VAL,
                             FND_PROFILE_OPTIONS OPTIONS,
                             FND_USER USERS
                       WHERE VAL.LEVEL_ID = 10004
                         AND USERS.USER_ID = VAL.LEVEL_VALUE
                         AND OPTIONS.PROFILE_OPTION_ID = VAL.PROFILE_OPTION_ID
                         AND OPTIONS.APPLICATION_ID = VAL.APPLICATION_ID
                         AND OPTIONS.PROFILE_OPTION_NAME = 'AS_DEF_CUST_ST_ROLE');


BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Check to see if the profile "OS: Customer Sales Team Default Role Type" is
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

    -- BEGIN salesforce role code check
      OPEN c_src;
      FETCH c_src INTO l_src_exists;
          if c_src%NOTFOUND then
             l_src_exists:='N';
          else
             l_src_exists:='Y';
         end if;
      CLOSE c_src;
   -- END Salesforce Role Code check


  if l_src_exists='Y' then
    OPEN ins_acc(l_worker_id); -- Open the salesforce role code cursor
    AS_GAR.LOG('---Opening ins_acc cursor--');
  else
    OPEN ins_acc2(l_worker_id); -- Open the null salesforce role code cursor
    AS_GAR.LOG('---Opening ins_acc2 cursor--');
  end if;

	LOOP
		IF (l_limit_flag) THEN EXIT; END IF;

		l_customer_id.DELETE;
		l_org_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_person_id.DELETE;
		l_address_id.DELETE;
		l_faf.DELETE;
		l_resource_type.DELETE;
		l_src.DELETE;


		    if l_src_exists='Y' then
		      EXIT when ins_acc%NOTFOUND;
		    else
		      EXIT when ins_acc2%NOTFOUND;
		    end if;

		l_loop_count := l_loop_count + 1;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'LOOPCOUNT :- ' || l_loop_count);

		 if l_src_exists='Y' then
		    FETCH ins_acc BULK COLLECT INTO
			  l_salesforce_id, l_sales_group_id, l_person_id,
			  l_customer_id,l_address_id,l_faf,l_resource_type,l_org_id,l_src
		    LIMIT l_max_fetches;
		  else
		    FETCH ins_acc2 BULK COLLECT INTO
			  l_salesforce_id, l_sales_group_id, l_person_id,
			  l_customer_id,l_address_id,l_faf,l_resource_type,l_org_id,l_src
		    LIMIT l_max_fetches;
		  end if;

		-- Initialize variables
		l_flag := TRUE;
		l_first := 0;
		l_last := 0;

		IF l_customer_id.count < l_MAX_fetches THEN
		   l_limit_flag := TRUE;
		END IF;

		IF  l_customer_id.count > 0 THEN
			l_flag := TRUE;
			l_first := l_customer_id.first;
			l_last := l_first + l_var;
			WHILE l_flag LOOP
				IF l_last > l_customer_id.last THEN
				   l_last := l_customer_id.last;
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
						   )
						   (
						   SELECT as_accesses_s.nextval
						       ,'X'
						       ,l_salesforce_id(i)
						       ,l_sales_group_id(i)
						       ,l_person_id(i)
						       ,l_src(i)
						       ,l_customer_id(i)
						       ,l_address_id(i)
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
						    FROM  DUAL
						    WHERE NOT EXISTS ( SELECT  'X'
								       FROM AS_ACCESSES_ALL_ALL AA
								       WHERE AA.sales_lead_id IS NULL
								       AND AA.lead_id IS NULL
								       AND AA.delete_flag is NULL
								       AND AA.customer_id = l_customer_id(i)
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
							(      access_id
							      ,access_type
							      ,salesforce_id
							      ,sales_group_id
							      ,person_id
							      ,salesforce_role_code
							      ,customer_id
							      ,address_id
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
							   )
							   (
							   SELECT as_accesses_s.NEXTVAL
							       ,'X'
							       ,l_salesforce_id(i)
							       ,l_sales_group_id(i)
							       ,l_person_id(i)
							       ,l_src(i)
							       ,l_customer_id(i)
							       ,l_address_id(i)
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
							  from  dual
							  where not exists ( SELECT  'X'
									       FROM AS_ACCESSES_ALL_ALL AA
									       WHERE AA.sales_lead_id IS NULL
									       AND AA.lead_id IS NULL
									       AND AA.delete_flag is NULL
									       AND AA.customer_id = l_customer_id(i)
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
				END;
				l_first := l_last + 1;
				l_last := l_first + l_var;
				IF l_first > l_customer_id.last THEN
					l_flag := FALSE;
				END IF;
			END LOOP; /* l_flag loop */
		END IF; --l_customer_id.count > 0
	END LOOP; -- loop for more bulk_size fetches
	l_customer_id.DELETE;
	l_org_id.DELETE;
	l_salesforce_id.DELETE;
	l_sales_group_id.DELETE;
	l_person_id.DELETE;
	l_address_id.DELETE;
	l_faf.DELETE;
	l_src.DELETE;
	l_resource_type.DELETE;

	IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;
	IF ins_acc2%ISOPEN THEN CLOSE ins_acc2; END IF;
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_acc%ISOPEN THEN CLOSE ins_acc; END IF;
      IF ins_acc2%ISOPEN THEN CLOSE ins_acc2; END IF;
END INSERT_ACCESSES_ACCOUNTS;

/************************** End Insert Into Entity Accesses*************/

/************************** Start Insert Into Terr Accesses*************/

PROCEDURE INSERT_TERR_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
	TYPE num_list        IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

	l_customer_id      num_list;
	l_salesforce_id    num_list;
	l_sales_group_id   num_list;
	l_terr_id          num_list;

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
	       ,w.group_id
	 FROM JTF_TAE_1001_ACCOUNT_WINNERS W
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
		l_customer_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_terr_id.DELETE;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'LOOPCOUNT :- ' || l_loop_count);
		BEGIN

			FETCH ins_tacc BULK COLLECT INTO l_terr_id,
			l_customer_id, l_salesforce_id, l_sales_group_id
			LIMIT l_MAX_fetches;
			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF l_terr_id.COUNT < l_MAX_fetches THEN l_limit_flag := TRUE; END IF;
			IF  l_customer_id.COUNT > 0 THEN
				l_flag := TRUE;
				l_first := l_customer_id.FIRST;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_customer_id.LAST THEN
						l_last := l_customer_id.LAST;
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
							( SELECT DISTINCT a.access_id acc_id
							     FROM AS_ACCESSES_ALL_ALL A
							     WHERE   A.customer_id=l_customer_id(i)
							     AND   A.delete_flag is NULL
							     AND   NVL(A.sales_group_id,-777) = NVL(l_sales_group_id(i),-777)
							     AND   A.salesforce_id=l_salesforce_id(i)
							     AND   A.sales_lead_id IS NULL
							     AND   A.lead_id IS NULL
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
								(  access_id,
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
									( SELECT distinct A.access_id acc_id
									     FROM AS_ACCESSES_ALL_ALL A
									     WHERE   A.customer_id=l_customer_id(i)
									     AND   A.delete_flag is NULL
									     AND   NVL(A.sales_group_id,-777) = NVL(l_sales_group_id(i),-777)
									     AND   A.salesforce_id=l_salesforce_id(i)
									     AND   A.sales_lead_id is NULL
									     AND   A.lead_id is NULL
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
					END;
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_customer_id.last THEN
						l_flag := FALSE;
					END IF;
				END LOOP;
			END IF; --l_customer_id.count > 0
		EXCEPTION
		WHEN Others THEN
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC , SQLERRM, TO_CHAR(SQLCODE));
			IF ins_tacc%ISOPEN THEN CLOSE ins_tacc; END IF;
				x_errbuf  := SQLERRM;
				x_retcode := SQLCODE;
				x_return_status := FND_API.G_RET_STS_ERROR;
		END;
	END LOOP; -- end loop for insert into territory accesses
	l_customer_id.DELETE;
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
END INSERT_TERR_ACCESSES_ACCOUNTS;

/************************** End Insert Into Terr Accesses*************/

/************************** Start Set Accounts Team Leader PRM****************/

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

PROCEDURE SET_TEAM_LEAD_PRM_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

    TYPE customer_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE salesforce_id_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE sales_group_id_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE part_cust_id_list   is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE part_cont_party_id_list   is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	TYPE faf_list            is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;
    l_customer_id      customer_id_list;
    l_salesforce_id    salesforce_id_list;
    l_sales_group_id   sales_group_id_list;
    l_part_cust_id     part_cust_id_list;
    l_part_cont_party_id     part_cont_party_id_list;
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
		SELECT  /*+ LEADING(WIN) USE_NL(A WIN) INDEX(A) */ A.customer_id,
			A.salesforce_id,
			A.sales_group_id,
			A.partner_customer_id,
			A.partner_cont_party_id,
			NVL(WIN.full_access_flag,'N')
		FROM AS_ACCESSES_ALL_ALL A,
		     JTF_TAE_1001_ACCOUNT_WINNERS WIN,
		     JTF_RS_ROLE_RELATIONS REL,
		     JTF_RS_ROLES_B ROL
		WHERE  WIN.source_id = -1001
		AND  A.delete_flag is NULL
		AND  WIN.worker_id = c_worker_id
		AND  NVL(A.team_leader_flag,'N') <> NVL(WIN.full_access_flag,'N')
		AND  WIN.resource_type in ('RS_PARTNER','RS_PARTY')
		AND  WIN.resource_id=REL.role_resource_id
		AND  REL.role_id=ROL.role_id
		AND  ROL.role_type_code='PRM'
		AND  REL.role_resource_type='RS_INDIVIDUAL'
		AND  REL.delete_flag <> 'Y'
		AND  SYSDATE between REL.start_date_active
		AND  NVL(REL.end_date_active,SYSDATE)
		AND  WIN.trans_object_id = A.customer_id
		AND  WIN.resource_id     = A.salesforce_id
		AND  NVL(WIN.group_id,-777) = NVL(A.sales_group_id,-777)
		AND  A.lead_id is NULL
		AND  A.sales_lead_id is NULL
		AND  (A.partner_customer_id IS NOT NULL OR A.partner_cont_party_id IS NOT NULL )
		GROUP BY A.customer_id,
			A.salesforce_id,
			A.sales_group_id,
			A.org_id,
			A.partner_customer_id,
			A.partner_cont_party_id,
			WIN.full_access_flag;


BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
	LOOP -- For l_limit_flag
			IF (l_limit_flag) THEN EXIT; END IF;

			l_customer_id.DELETE;
			l_salesforce_id.DELETE;
			l_sales_group_id.DELETE;
			l_part_cust_id.DELETE;
			l_part_cont_party_id.DELETE;
			l_faf.DELETE;

			l_loop_count := l_loop_count + 1;
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || 'LOOPCOUNT :- ' || l_loop_count);

			--------------------------------
			OPEN team_leader(l_worker_id);
			    FETCH team_leader BULK COLLECT INTO
				      l_customer_id, l_salesforce_id, l_sales_group_id, l_part_cust_id, l_part_cont_party_id,l_faf
			    LIMIT l_MAX_fetches;
			CLOSE team_leader;

			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;
			l_attempts := 1;

			IF l_customer_id.COUNT < l_MAX_fetches THEN
			   l_limit_flag := TRUE;
			END IF;
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_BULK_UPD || AS_GAR.G_START);

			IF  l_customer_id.COUNT > 0 THEN
				l_flag := TRUE;
				l_first := l_customer_id.FIRST;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_customer_id.LAST THEN
						l_last := l_customer_id.LAST;
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
								 AND	 ACC.sales_lead_id is NULL
								 AND     ACC.delete_flag is NULL
								 AND 	 ACC.customer_id    = l_customer_id(i)
								 AND	 ACC.salesforce_id  = l_salesforce_id(i)
								 AND	 NVL(ACC.sales_group_id,-777) = NVL(l_sales_group_id(i),-777)
								 AND	 (NVL(ACC.partner_customer_id,-777)= NVL(l_part_cust_id(i),-777)
								 OR	 NVL(ACC.partner_cont_party_id,-777)=NVL(l_part_cont_party_id(i),-777));
							COMMIT;
							l_attempts := 3;
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS ||AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_BULK_UPD || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-'|| l_last);
						 EXCEPTION
						 WHEN DEADLOCK_DETECTED THEN
							BEGIN
								AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_DEADLOCK ||l_attempts);
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
											 AND     ACC.delete_flag is NULL
											 AND	 ACC.sales_lead_id is NULL
											 AND	 ACC.customer_id    = l_customer_id(i)
											 AND	 ACC.salesforce_id  = l_salesforce_id(i)
											 AND	 NVL(ACC.sales_group_id,-777) = NVL(l_sales_group_id(i),-777)
											 AND	(NVL(ACC.partner_customer_id,-777)= NVL(l_part_cust_id(i),-777)
											 OR		NVL(ACC.partner_cont_party_id,-777)=NVL(l_part_cont_party_id(i),-777));
										EXCEPTION
										WHEN OTHERS THEN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_IND_UPD || AS_GAR.G_GENERAL_EXCEPTION);
											AS_GAR.LOG('CUSTOMER_ID/SALESFORCE_ID/SALESGROUP_ID/ORG_ID/PRM_CUST_ID/PRM_CUST_CONT_ID - ' || l_customer_id(i) || '/' || l_salesforce_id(i) || '/' || l_sales_group_id(i) || '/' ||  '/' || l_part_cust_id(i) || '/' || l_part_cont_party_id(i));
										END;
									END LOOP; -- for each record individually
									COMMIT;
								END IF;
							END; -- end of deadlock exception
						WHEN OTHERS THEN
							AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_BULK_UPD, SQLERRM, TO_CHAR(SQLCODE));
							x_errbuf  := SQLERRM;
							x_retcode := SQLCODE;
							x_return_status := FND_API.G_RET_STS_ERROR;
						END;
					END LOOP; -- loop for 3 attempts
					/* For the next batch of records by bulk_size */
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_customer_id.LAST THEN
						l_flag := FALSE;
					END IF;
				END LOOP; -- loop for more records within the bulk_size
			END IF; --l_customer_id.count > 0
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::' || AS_GAR.G_N_ROWS_PROCESSED || l_customer_id.COUNT);
		END LOOP; -- loop for more bulk_size fetches
		l_customer_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_part_cust_id.DELETE;
		l_part_cont_party_id.DELETE;
		l_faf.DELETE;
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || 'PRM::', SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END SET_TEAM_LEAD_PRM_ACCOUNTS;

/************************** End Set Accounts Team Leader PRM*****************/

/************************** Start Insert Into Entity Accesses PRM ***********/

PROCEDURE INSERT_ACCESSES_PRM_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
    TYPE customer_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE org_id_list         is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE salesforce_id_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE sales_group_id_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE address_id_list     is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list            is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE person_id_list      is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE src_list            is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE resource_type_list  is TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;

    l_customer_id      customer_id_list;
    l_org_id           org_id_list;
    l_salesforce_id    salesforce_id_list;
    l_sales_group_id   sales_group_id_list;
    l_address_id       address_id_list;
    l_faf              faf_list;
    l_person_id        person_id_list;
    l_src              src_list;
    l_resource_type    resource_type_list;

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

CURSOR ins_rs_partner(c_worker_id number) IS
		SELECT W.resource_id,
		       W.group_id grp_id,
		       MIN(W.person_id) person_id,
		       W.trans_object_id cus_id,
		       MIN(W.trans_detail_object_id) add_id,
		       MAX(W.full_access_flag) faf,
		       W.org_id,
		       W.resource_type,
		       RES.source_id
		FROM  JTF_TAE_1001_ACCOUNT_WINNERS W,
		    JTF_RS_RESOURCE_EXTNS RES,
		    JTF_RS_ROLE_RELATIONS REL,
		    JTF_RS_ROLES_B ROL
		WHERE W.source_id = -1001
		AND W.resource_id=REL.role_resource_id
		AND W.worker_id = c_worker_id
		AND W.resource_type in ('RS_PARTY','RS_PARTNER')
		AND REL.role_id=ROL.role_id
		AND ROL.role_type_code='PRM'
		AND REL.role_resource_type='RS_INDIVIDUAL'
		AND REL.delete_flag <> 'Y'
		AND SYSDATE between REL.start_date_active
		AND NVL(REL.end_date_active,SYSDATE)
		AND W.resource_id=RES.resource_id
		AND NOT EXISTS ( SELECT  1
				 FROM AS_ACCESSES_ALL_ALL AA
				 WHERE AA.sales_lead_id IS NULL
				 AND AA.lead_id IS NULL
				 AND (AA.partner_customer_id IS NOT NULL OR AA.partner_cont_party_id IS NOT NULL )
				 AND AA.customer_id = W.trans_object_id
				 AND AA.salesforce_id = W.resource_id
				 AND NVL(AA.sales_group_id,-777) = NVL(W.group_id,-777)
				 AND AA.delete_flag is NULL
				)
		GROUP BY W.trans_object_id,
			 W.resource_id,
			 W.group_id,
			 W.org_id,
			 W.resource_type,
			 RES.source_id;

BEGIN
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | Re-Initialize variables and null out if necessary.
 | Try bulk inserting into accesses. If this fails, insert records one by one.
 |
 +-------------------------------------------------------------------------*/
 	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
		OPEN ins_rs_partner(l_worker_id);
		LOOP
			IF (l_limit_flag) THEN EXIT; END IF;
			l_customer_id.DELETE;
			l_org_id.DELETE;
			l_salesforce_id.DELETE;
			l_sales_group_id.DELETE;
			l_person_id.DELETE;
			l_address_id.DELETE;
			l_faf.DELETE;
			l_src.DELETE;
			l_resource_type.DELETE;

			EXIT WHEN ins_rs_partner%NOTFOUND;

			l_loop_count := l_loop_count + 1;
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || 'LOOPCOUNT :- ' || l_loop_count);

			FETCH ins_rs_partner BULK COLLECT INTO
				      l_salesforce_id, l_sales_group_id, l_person_id,
				      l_customer_id,l_address_id,l_faf,l_org_id,l_resource_type,l_src
				LIMIT l_MAX_fetches;

			-- Initialize variables
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF l_customer_id.count < l_MAX_fetches THEN
			   l_limit_flag := TRUE;
			END IF;

			IF  l_customer_id.count > 0 THEN
				l_flag := TRUE;
				l_first := l_customer_id.first;
				l_last := l_first + l_var;
				WHILE l_flag LOOP
					IF l_last > l_customer_id.last THEN
					   l_last := l_customer_id.last;
					END IF;
					BEGIN
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' to '||l_last);
						FORALL i IN l_first .. l_last
							INSERT INTO AS_ACCESSES_ALL_ALL
							(      access_id
							      ,access_type
							      ,salesforce_id
							      ,sales_group_id
							      ,person_id
							      ,customer_id
							      ,address_id
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
							      ,partner_customer_id
							      ,partner_cont_party_id
							   )
							   (
							   SELECT as_accesses_s.NEXTVAL
							       ,'X'
							       ,l_salesforce_id(i)
							       ,l_sales_group_id(i)
							       ,null
							       ,l_customer_id(i)
							       ,l_address_id(i)
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
							       ,DECODE(l_resource_type(i),'RS_PARTNER',l_src(i),NULL)
							       ,DECODE(l_resource_type(i),'RS_PARTY',l_src(i),NULL)
							    FROM  DUAL
							 );
							 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
							COMMIT;
					EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
						 FOR i IN l_first .. l_last LOOP
							BEGIN
								INSERT INTO AS_ACCESSES_ALL_ALL
								(    access_id
								    ,access_type
								    ,salesforce_id
								    ,sales_group_id
								    ,person_id
								    ,customer_id
								    ,address_id
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
								    ,partner_customer_id
								    ,partner_cont_party_id
								 )
								 (
								 SELECT as_accesses_s.NEXTVAL
								     ,'X'
								     ,l_salesforce_id(i)
								     ,l_sales_group_id(i)
								     ,null
								     ,l_customer_id(i)
								     ,l_address_id(i)
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
								     ,DECODE(l_resource_type(i),'RS_PARTNER',l_src(i),NULL)
								     ,DECODE(l_resource_type(i),'RS_PARTY',l_src(i),NULL)
								  FROM  DUAL
								 );
							EXCEPTION
							WHEN OTHERS THEN
								NULL;
							END;
						END LOOP; /* loop for DUP_VAL_ON_INDEX individual insert */
						COMMIT;
					WHEN OTHERS THEN
						AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::' || AS_GAR.G_BULK_INS, SQLERRM, TO_CHAR(SQLCODE));
						x_errbuf  := SQLERRM;
						x_retcode := SQLCODE;
						x_return_status := FND_API.G_RET_STS_ERROR;
					END;
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_customer_id.last THEN
						l_flag := FALSE;
					END IF;
				END LOOP; /* l_flag loop */
			END IF; --l_customer_id.count > 0
		END LOOP; -- loop for more bulk_size fetches
		l_customer_id.DELETE;
		l_org_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		l_person_id.DELETE;
		l_address_id.DELETE;
		l_faf.DELETE;
		l_src.DELETE;
		l_resource_type.DELETE;
		IF ins_rs_partner%ISOPEN THEN CLOSE ins_rs_partner; END IF;

EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || 'PRM::', SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_rs_partner%ISOPEN THEN CLOSE ins_rs_partner; END IF;
END INSERT_ACCESSES_PRM_ACCOUNTS;

/************************** End Insert Into Entity Accesses PRM ********/

/************************** Start Insert Into Terr Accesses PRM *********/

PROCEDURE INSERT_TERR_ACCESSES_PRM_ACCS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

	TYPE num_list        IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

	l_customer_id      num_list;
	l_salesforce_id    num_list;
	l_sales_group_id   num_list;
	l_terr_id          num_list;

	l_var     NUMBER;
	l_limit_flag    BOOLEAN := FALSE;
	l_worker_id     NUMBER;
	l_MAX_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;
	l_flag    BOOLEAN;
	l_first   NUMBER;
	l_last    NUMBER;
	CURSOR ins_tacc_rs_partner(c_worker_id number) IS

		SELECT  w.terr_id
			   ,w.trans_object_id
			   ,w.resource_id
			   ,w.group_id
		 FROM JTF_TAE_1001_ACCOUNT_WINNERS W,JTF_RS_ROLE_RELATIONS REL,JTF_RS_ROLES_B ROL
		 WHERE  W.source_id = -1001
		 AND    W.worker_id = c_worker_id
		 AND    W.resource_type in ('RS_PARTNER','RS_PARTY')
		 AND  W.resource_id=REL.role_resource_id
		 AND  REL.role_id=ROL.role_id
		 AND  ROL.role_type_code='PRM'
		 AND  REL.role_resource_type='RS_INDIVIDUAL'
		 AND  REL.delete_flag <> 'Y'
		 AND  SYSDATE between REL.start_date_active
		 AND  NVL(REL.end_date_active,SYSDATE)
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
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id := p_terr_globals.worker_id;
	l_var       := p_terr_globals.bulk_size;
		OPEN ins_tacc_rs_partner(l_worker_id);
		LOOP
			IF (l_limit_flag) THEN EXIT; END IF;
			EXIT WHEN ins_tacc_rs_partner%NOTFOUND;
			l_loop_count := l_loop_count + 1;

			l_terr_id.DELETE;
			l_customer_id.DELETE;
			l_salesforce_id.DELETE;
			l_sales_group_id.DELETE;

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || 'LOOPCOUNT :- ' || l_loop_count);
			BEGIN
				FETCH ins_tacc_rs_partner BULK COLLECT INTO l_terr_id,l_customer_id,l_salesforce_id,l_sales_group_id
				LIMIT l_MAX_fetches;
				-- Initialize variables
				l_flag := TRUE;
				l_first := 0;
				l_last := 0;

				IF l_terr_id.COUNT < l_MAX_fetches THEN l_limit_flag := TRUE; END IF;
				IF  l_terr_id.COUNT > 0 THEN
					l_flag := TRUE;
					l_first := l_terr_id.first;
					l_last := l_first + l_var;
					WHILE l_flag LOOP
						IF l_last > l_terr_id.LAST THEN
							l_last := l_terr_id.LAST;
						END IF;
						BEGIN
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
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
									( SELECT distinct A.access_id acc_id
									     FROM AS_ACCESSES_ALL_ALL A
									     WHERE   A.customer_id=l_customer_id(i)
										 AND  (A.partner_customer_id is NOT NULL OR A.partner_cont_party_id is NOT NULL )
									     AND   A.delete_flag is NULL
									     AND   NVL(A.sales_group_id,-777)=NVL(l_sales_group_id(i),-777)
									     AND   A.salesforce_id=l_salesforce_id(i)
									     AND   A.sales_lead_id is NULL
									     AND   A.lead_id is NULL
									     AND NOT EXISTS
											(SELECT 'X'
												FROM AS_TERRITORY_ACCESSES AST
												WHERE AST.access_id = A.access_id
												  AND AST.territory_id = l_terr_id(i))
									) V
							);
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_BULK_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
							COMMIT;
						EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED ||l_first||' - '||l_last);
							FOR i IN l_first .. l_last LOOP
								BEGIN
									INSERT INTO AS_TERRITORY_ACCESSES
									(  access_id,
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
										( SELECT distinct A.access_id acc_id
											 FROM AS_ACCESSES_ALL_ALL A
											 WHERE   A.customer_id=l_customer_id(i)
											 AND   A.delete_flag is NULL
											 AND  (A.partner_customer_id is NOT NULL OR A.partner_cont_party_id is NOT NULL )
											 AND   NVL(A.sales_group_id,-777)=NVL(l_sales_group_id(i),-777)
											 AND   A.salesforce_id=l_salesforce_id(i)
											 AND   A.sales_lead_id is NULL
											 AND   A.lead_id is NULL
										     AND NOT EXISTS
												(SELECT 'X'
													FROM AS_TERRITORY_ACCESSES AST
													WHERE AST.access_id = A.access_id
													  AND AST.territory_id = l_terr_id(i))
										) V
									);
								EXCEPTION
									WHEN OTHERS THEN
										NULL;
								END;
							END LOOP;
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_IND_INS || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
							COMMIT;
						WHEN Others THEN
							AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_BULK_INS, SQLERRM, TO_CHAR(SQLCODE));
							x_errbuf  := SQLERRM;
							x_retcode := SQLCODE;
							x_return_status := FND_API.G_RET_STS_ERROR;
							IF ins_tacc_rs_partner%ISOPEN THEN CLOSE ins_tacc_rs_partner; END IF;
						END;
						l_first := l_last + 1;
						l_last := l_first + l_var;
						IF l_first > l_terr_id.last THEN
							l_flag := FALSE;
						END IF;
					END LOOP;
				END IF; --l_access_id.count > 0
			EXCEPTION
			WHEN Others THEN
				AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' , SQLERRM, TO_CHAR(SQLCODE));
				IF ins_tacc_rs_partner%ISOPEN THEN CLOSE ins_tacc_rs_partner; END IF;
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
					x_return_status := FND_API.G_RET_STS_ERROR;

			END;
		END LOOP; -- end loop for insert into territory accesses
		l_terr_id.DELETE;
		l_customer_id.DELETE;
		l_salesforce_id.DELETE;
		l_sales_group_id.DELETE;
		IF ins_tacc_rs_partner%ISOPEN THEN CLOSE ins_tacc_rs_partner; END IF;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::' || AS_GAR.G_END);
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || 'PRM::', SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ins_tacc_rs_partner%ISOPEN THEN CLOSE ins_tacc_rs_partner; END IF;
END INSERT_TERR_ACCESSES_PRM_ACCS;

/************************** End Insert Into Terr Accesses PRM ********/


/**************************   Start Account Cleanup ***********************/

PROCEDURE Perform_Account_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

	TYPE customer_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_customer_id      customer_id_list;



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
		FROM JTF_TAE_1001_ACCOUNT_TRANS
		WHERE worker_id=c_worker_id;

	CURSOR del_acct_newmode(c_worker_id number) IS
		SELECT  distinct trans_object_id
		FROM JTF_TAE_1001_ACCOUNT_NM_TRANS
		WHERE worker_id=c_worker_id;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_worker_id   := p_terr_globals.worker_id;
	l_var      := p_terr_globals.bulk_size;
	l_MAX_fetches := p_terr_globals.cursor_limit;
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || 'Bulk Size'|| l_var || 'Cursor Limit' || l_MAX_fetches);
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
				FETCH del_acct_totalmode BULK COLLECT INTO l_customer_id
				LIMIT l_MAX_fetches;
			ELSE
				EXIT WHEN del_acct_newmode%NOTFOUND;
				FETCH del_acct_newmode BULK COLLECT INTO l_customer_id
				LIMIT l_MAX_fetches;
			END IF;
			-- Initialize variables (Ist Init)
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;
			l_attempts := 1;

			IF l_customer_id.COUNT < l_MAX_fetches THEN
				l_limit_flag := TRUE;
			END IF;

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_START);
			IF l_customer_id.count > 0 THEN --{I1
				l_flag  := TRUE;
				l_first := l_customer_id.first;
				l_last  := l_first + l_var;
				AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED ||
								 l_customer_id.FIRST || '-' ||
								 l_customer_id.LAST);
				WHILE l_flag LOOP --{L2 10K cust loop
					IF l_last > l_customer_id.LAST THEN
						l_last := l_customer_id.LAST;
					END IF;
					l_del_flag  := FALSE;
					l_attempts  := 1;
					IF (l_del_flag) THEN EXIT; END IF;
					l_del_flag := FALSE;
					WHILE l_attempts < 3 LOOP --{L4
						BEGIN
							AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_UPD || AS_GAR.G_START);
							FORALL i in l_first..l_last
								UPDATE AS_ACCESSES_ALL_ALL ACC
								SET object_version_number =  NVL(object_version_number,0) + 1, ACC.DELETE_FLAG='Y'
								WHERE ACC.customer_id=l_customer_id(i)
								AND ACC.delete_flag is NULL
								AND NVL(ACC.freeze_flag,'N') = 'N'
								AND ACC.lead_id IS NULL
								AND ACC.sales_lead_id IS NULL
								AND NOT EXISTS (SELECT  'X'
								  FROM JTF_TAE_1001_ACCOUNT_WINNERS W
								  WHERE  W.trans_object_id = ACC.customer_id
								  AND  W.worker_id = l_worker_id
								  AND  W.resource_id = ACC.salesforce_id
								  AND  NVL(W.group_id,-777)=NVL(ACC.sales_group_id,-777))
								AND ROWNUM < G_DEL_REC;

							COMMIT;

							l_attempts := 3;
							IF l_customer_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
						EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
							BEGIN
								AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_BULK_DEL || AS_GAR.G_START);
								FORALL i in l_first..l_last
									DELETE FROM AS_ACCESSES_ALL_ALL ACC
									WHERE ACC.customer_id=l_customer_id(i)
									AND NVL(ACC.freeze_flag,'N') = 'N'
									AND ACC.lead_id IS NULL
									AND ACC.delete_flag is NULL
									AND ACC.sales_lead_id IS NULL
									AND NOT EXISTS (SELECT  'X'
									  FROM JTF_TAE_1001_ACCOUNT_WINNERS W
									  WHERE  W.trans_object_id = ACC.customer_id
									  AND  W.worker_id = l_worker_id
									  AND  W.resource_id = ACC.salesforce_id
									  AND  NVL(W.group_id,-777)= NVL(ACC.sales_group_id,-777))
									AND ROWNUM < G_DEL_REC;

								COMMIT;

								l_attempts := 3;
								IF l_customer_id.COUNT < G_NUM_REC THEN l_del_flag := TRUE; END IF;
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
										WHERE ACC.customer_id=l_customer_id(i)
										AND ACC.delete_flag is NULL
										AND NVL(ACC.freeze_flag,'N') = 'N'
										AND ACC.lead_id IS NULL
										AND ACC.sales_lead_id IS NULL
										AND NOT EXISTS (SELECT  'X'
										  FROM JTF_TAE_1001_ACCOUNT_WINNERS W
										  WHERE  W.trans_object_id = ACC.customer_id
										  AND  W.worker_id = l_worker_id
										  AND  W.resource_id = ACC.salesforce_id
										  AND  NVL(W.group_id,-777)= NVL(ACC.sales_group_id,-777));
										COMMIT;
									EXCEPTION
									WHEN DUP_VAL_ON_INDEX THEN
										BEGIN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_START);
											DELETE FROM AS_ACCESSES_ALL_ALL ACC
											WHERE ACC.customer_id=l_customer_id(i)
											AND NVL(ACC.freeze_flag,'N') = 'N'
											AND ACC.delete_flag is NULL
											AND ACC.lead_id IS NULL
											AND ACC.sales_lead_id IS NULL
											AND NOT EXISTS (SELECT  'X'
											  FROM JTF_TAE_1001_ACCOUNT_WINNERS W
											  WHERE  W.trans_object_id = ACC.customer_id
											  AND  W.worker_id = l_worker_id
											  AND  W.resource_id = ACC.salesforce_id
											  AND  NVL(W.group_id,-777)= NVL(ACC.sales_group_id,-777));
											COMMIT;

										EXCEPTION
										WHEN OTHERS THEN
											AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_GENERAL_EXCEPTION);
											AS_GAR.LOG('CUSTOMER_ID - ' || l_customer_id(i));
										END;
									END;
								END LOOP; --}L5
								COMMIT;
								l_del_flag := TRUE;
							END IF;
							l_attempts := 3;
						END; --}I2 end of deadlock exception
						WHEN OTHERS THEN
							AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
							IF del_acct_totalmode%ISOPEN THEN CLOSE del_acct_totalmode; END IF;
							IF del_acct_newmode%ISOPEN THEN CLOSE del_acct_newmode; END IF;
							x_errbuf  := SQLERRM;
							x_retcode := SQLCODE;
							x_return_status := FND_API.G_RET_STS_ERROR;
						END;
					 END LOOP;  --}L4  l_attempts loop 3 trys
					AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-' || l_last);
					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_customer_id.LAST THEN
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
END Perform_Account_Cleanup;

/**************************   End Account Cleanup ***********************/

END AS_GAR_ACCOUNTS_PUB;


/
