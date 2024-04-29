--------------------------------------------------------
--  DDL for Package Body AS_ATA_TOTAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ATA_TOTAL_PUB" as
/* $Header: asxtatab.pls 120.13.12000000.2 2007/05/05 08:33:01 annsrini ship $ */


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
  G_ENTITY CONSTANT VARCHAR2(20) := 'ATA TOTAL MODE : ';
  DEADLOCK_DETECTED EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
G_PR_ACCOUNT          VARCHAR2(25) := 'PROCESS ACCOUNT TRANS';
G_PR_LEAD             VARCHAR2(20) := 'PROCESS LEAD TRANS';
G_PR_OPPTY            VARCHAR2(30) := 'PROCESS OPPORTUNITY TRANS';
G_PR_QUOTE            VARCHAR2(25) := 'PROCESS QUOTES TRANS';
G_PR_PROPOSAL         VARCHAR2(25) := 'PROCESS PROPOSAL TRANS';
G_PR_TRANS            VARCHAR2(20) := 'PROCESS JTY TRANS';
G_WHERE               VARCHAR2(20) := 'ADDL. WHERE CLAUSE';
G_GAR_SUBMIT          VARCHAR2(20) := 'SUBMITTING GAR';

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES SPECIFICATION
 |
 *-------------------------------------------------------------------------*/
PROCEDURE Process_trans_data(
 p_trans_id	IN NUMBER,
 P_addl_where	IN VARCHAR2,
 P_percent_analyzed    IN  NUMBER,
 P_trace_mode   IN  VARCHAR2,
 x_return_Status OUT NOCOPY  VARCHAR2);
PROCEDURE Assign_Account_Terr_Accesses(
    ERRBUF             out NOCOPY VARCHAR2,
    RETCODE            out NOCOPY VARCHAR2,
    P_submit_acc_tap  IN  VARCHAR2,
    P_account_type     IN  VARCHAR2,
    P_addl_where       IN  VARCHAR2,
    P_perc_analyzed    IN  NUMBER,
    P_debug            IN  VARCHAR2,
    P_trace            IN  VARCHAR2
)
IS
l_addl_where     VARCHAR2(2000);
l_return_status  VARCHAR2(10);
l_status         BOOLEAN;
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
l_oracle_schema  VARCHAR2(32) := 'OSM';
BEGIN
    AS_GAR.g_debug_flag := p_debug;
    IF P_trace = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PR_ACCOUNT || AS_GAR.G_START);
   IF P_submit_acc_tap='Y' THEN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_START);
      AS_GAR.Set_Area_Sizes;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_END);
      IF P_account_type = 'ORGANIZATION' THEN
         l_addl_where := ' Where party_type  = ''ORGANIZATION''';
      ELSIF P_account_type = 'PERSON' THEN
         l_addl_where :=  ' Where party_type  = ''PERSON''';
      END IF;
      IF p_addl_where is NOT NULL THEN
          IF nvl(p_account_type,'ALL') = 'ALL' THEN
	     l_addl_where :=  ' Where ' || p_addl_Where;
	   ELSE
	     l_addl_where := l_Addl_Where || ' and ' ||p_addl_Where;
	   END IF;
      END IF;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_ACCOUNT || G_WHERE || l_addl_where);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_ACCOUNT || AS_GAR.G_START);

      DELETE_CHANGED_ENTITY(p_entity        => 'ACCOUNT',
	                    x_errbuf        => l_errbuf,
		            x_retcode       => l_retcode,
	                    x_return_status => l_return_status);
      PROCESS_TRANS_DATA(
	   p_trans_id	  => -1002
          ,P_addl_where	  => l_addl_where
	  ,P_percent_analyzed =>P_perc_analyzed
	  ,P_trace_mode    => p_trace
	  ,x_return_status => l_return_status);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_ACCOUNT || AS_GAR.G_END ||l_return_status);
    AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_ACCOUNT || AS_GAR.G_RETURN_STATUS || l_return_status);
    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_ACCOUNT, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    --fix for bug(5869095) --populating as_terr_resources_tmp table

	EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_oracle_schema || '.AS_TERR_RESOURCES_TMP REUSE STORAGE';

       INSERT /*+ append parallel(AS_TERR_RESOURCES_TMP) */
          INTO AS_TERR_RESOURCES_TMP
        (RESOURCE_ID,
         RESOURCE_TYPE,
         PARTY_ID,
         TERR_ID)
        ( SELECT DISTINCT USERS.EMPLOYEE_ID,
                          VAL.PROFILE_OPTION_VALUE,-1,-1
          FROM  FND_PROFILE_OPTION_VALUES VAL,
                FND_PROFILE_OPTIONS OPTIONS,
                FND_USER USERS
          WHERE VAL.LEVEL_ID = 10004
          AND USERS.EMPLOYEE_ID is not null
          AND VAL.PROFILE_OPTION_VALUE is not null
          AND USERS.USER_ID = VAL.LEVEL_VALUE
          AND VAL.PROFILE_OPTION_VALUE is not null
          AND OPTIONS.PROFILE_OPTION_ID = VAL.PROFILE_OPTION_ID
          AND OPTIONS.APPLICATION_ID = VAL.APPLICATION_ID
          AND OPTIONS.PROFILE_OPTION_NAME = 'AS_DEF_CUST_ST_ROLE'
         );

       COMMIT;

    dbms_stats.gather_table_stats('OSM','AS_TERR_RESOURCES_TMP',
    estimate_percent=>10, degree=>8, granularity=>'GLOBAL', cascade=>TRUE) ;
    COMMIT;

   --fix for bug(5869095) --populating as_terr_resources_tmp table

   END IF;
      AS_GAR.LOG(G_ENTITY || G_PR_ACCOUNT || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Assign_Account_Terr_Accesses;

PROCEDURE Assign_Lead_Terr_Accesses(
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY VARCHAR2,
    P_submit_lead_tap  IN  VARCHAR2,
    P_lead_status       IN  VARCHAR2,
    P_addl_where        IN  VARCHAR2,
    P_perc_analyzed     IN  NUMBER,
    P_debug             IN  VARCHAR2,
    P_trace             IN  VARCHAR2
)
IS
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
l_addl_where     VARCHAR2(2000);
l_return_status  VARCHAR2(10);
l_status         BOOLEAN;
BEGIN
    AS_GAR.g_debug_flag := p_debug;
    IF P_trace = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PR_LEAD || AS_GAR.G_START);

   IF P_submit_lead_tap='Y' THEN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_START);
      AS_GAR.Set_Area_Sizes;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_END);

      DELETE_CHANGED_ENTITY(p_entity        => 'LEAD',
       	                    x_errbuf        => l_errbuf,
		            x_retcode       => l_retcode,
	                    x_return_status => l_return_status);
      IF P_lead_status = 'OPEN' THEN
         l_addl_where := ' Where open_flag  = ''Y''';
      ELSIF P_lead_status = 'CLOSED' THEN
         l_addl_where :=  ' WHere open_Flag  = ''N''';
      END IF;
      IF p_addl_where is NOT NULL THEN
          IF nvl(P_lead_status,'ALL') = 'ALL' THEN
	     l_addl_where :=  ' Where ' || p_addl_Where;
	   ELSE
	     l_addl_where := l_Addl_Where || ' and ' ||p_addl_Where;
	   END IF;
      END IF;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_LEAD || G_WHERE || l_addl_where);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_LEAD || AS_GAR.G_START);
      Process_trans_data(
	   p_trans_id	  => -1003
          ,P_addl_where	  => l_addl_where
	  ,P_percent_analyzed =>P_perc_analyzed
	  ,P_trace_mode    => p_trace
	  ,x_return_status => l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_LEAD || AS_GAR.G_END ||l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_LEAD || AS_GAR.G_RETURN_STATUS || l_return_status);
      If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_LEAD, l_errbuf, l_retcode);
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;
   END IF;
   AS_GAR.LOG(G_ENTITY || G_PR_LEAD || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Assign_Lead_Terr_Accesses;

PROCEDURE Assign_Oppty_Terr_Accesses(
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY VARCHAR2,
    P_submit_oppty_tap  IN  VARCHAR2,
    P_oppty_status      IN  VARCHAR2,
    P_addl_where        IN  VARCHAR2,
    P_perc_analyzed     IN  NUMBER,
    P_debug             IN  VARCHAR2,
    P_trace             IN  VARCHAR2
)
IS
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
l_addl_where     VARCHAR2(2000);
l_return_status  VARCHAR2(10);
l_status         BOOLEAN;

BEGIN
    AS_GAR.g_debug_flag := p_debug;
    IF P_trace = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PR_OPPTY || AS_GAR.G_START);
   IF P_submit_oppty_tap='Y' THEN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_START);
      AS_GAR.Set_Area_Sizes;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_END);

      DELETE_CHANGED_ENTITY(p_entity        => 'OPPTY',
      	                    x_errbuf        => l_errbuf,
		            x_retcode       => l_retcode,
	                    x_return_status => l_return_status);
      IF P_oppty_status = 'OPEN' THEN
         l_addl_where := ' Where open_flag  = ''Y''';
      ELSIF P_oppty_status = 'CLOSED' THEN
         l_addl_where :=  ' Where open_Flag  = ''N''';
      END IF;
      IF p_addl_where is NOT NULL THEN
          IF nvl(P_oppty_status,'ALL') = 'ALL' THEN
	     l_addl_where :=  ' Where ' || p_addl_Where;
	   ELSE
	     l_addl_where := l_Addl_Where || ' and ' ||p_addl_Where;
	   END IF;
      END IF;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_OPPTY || G_WHERE || l_addl_where);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_OPPTY || AS_GAR.G_START);
      Process_trans_data(
	   p_trans_id	  => -1004
          ,P_addl_where	  => l_addl_where
	  ,P_percent_analyzed =>P_perc_analyzed
	  ,P_trace_mode    => p_trace
	  ,x_return_status => l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_OPPTY || AS_GAR.G_END ||l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_OPPTY || AS_GAR.G_RETURN_STATUS || l_return_status);
      If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_OPPTY, l_errbuf, l_retcode);
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;
   END IF;
 AS_GAR.LOG(G_ENTITY || G_PR_OPPTY || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Assign_Oppty_Terr_Accesses;


PROCEDURE Assign_Quote_Terr_Accesses(
    ERRBUF			OUT NOCOPY VARCHAR2,
    RETCODE			OUT NOCOPY VARCHAR2,
    P_submit_quote_tap		IN  VARCHAR2,
    P_exclude_ord_quote		IN  VARCHAR2,
    P_exclude_exp_quote		IN  VARCHAR2,
    P_addl_where		IN  VARCHAR2,
    P_perc_analyzed             IN  NUMBER,
    P_debug			IN  VARCHAR2,
    P_trace			IN  VARCHAR2
)
IS
    l_errbuf         VARCHAR2(4000);
    l_retcode        VARCHAR2(255);
    l_addl_where     VARCHAR2(2000);
    l_return_status  VARCHAR2(10);
    l_status         BOOLEAN;
BEGIN
    AS_GAR.g_debug_flag := p_debug;
    IF P_trace = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PR_QUOTE || AS_GAR.G_START);
   IF P_submit_quote_tap='Y' THEN
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_START);
        AS_GAR.Set_Area_Sizes;
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_END);

	DELETE_CHANGED_ENTITY(p_entity        => 'QUOTE',
	                      x_errbuf        => l_errbuf,
		              x_retcode       => l_retcode,
	                      x_return_status => l_return_status);
      IF nvl(P_exclude_ord_quote,'N') = 'Y' THEN
         l_addl_where :=  ' WHERE  ORDER_ID IS NULL';
      END IF;
      IF nvl(P_exclude_exp_quote,'N') = 'Y' THEN
         IF nvl(P_exclude_ord_quote,'N') ='N' THEN
             l_addl_where := ' WHERE trunc(quote_expiration_date) >= trunc(sysdate) ';
	 ELSE
             l_addl_where := l_addl_where || ' AND trunc(quote_expiration_date) >= trunc(sysdate) ';
	 END IF;
      END IF;
      IF p_addl_where is NOT NULL THEN
           IF nvl(P_exclude_ord_quote,'N') = 'N' AND nvl(P_exclude_ord_quote,'N') ='N' THEN
	     l_addl_where :=  ' Where ' || p_addl_Where;
	   ELSE
	     l_addl_where := l_Addl_Where || ' and ' ||p_addl_Where;
	   END IF;
      END IF;
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_QUOTE || G_WHERE || l_addl_where);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_QUOTE || AS_GAR.G_START);
      Process_trans_data(
	   p_trans_id	  => -1105
          ,P_addl_where	  => l_addl_where
	  ,P_percent_analyzed =>P_perc_analyzed
	  ,P_trace_mode    => p_trace
	  ,x_return_status => l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_QUOTE || AS_GAR.G_END ||l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_QUOTE || AS_GAR.G_RETURN_STATUS || l_return_status);
      If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_QUOTE, l_errbuf, l_retcode);
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;
   END IF;
 AS_GAR.LOG(G_ENTITY || G_PR_QUOTE || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Assign_Quote_Terr_Accesses;

PROCEDURE Assign_Proposal_Terr_Accesses(
    ERRBUF             out NOCOPY VARCHAR2,
    RETCODE            out NOCOPY VARCHAR2,
    P_submit_prp_tap  IN  VARCHAR2,
    P_addl_where       IN  VARCHAR2,
    P_perc_analyzed    IN  NUMBER,
    P_debug            IN  VARCHAR2,
    P_trace            IN  VARCHAR2
)
IS
	l_errbuf         VARCHAR2(4000);
	l_retcode        VARCHAR2(255);
	l_addl_where     VARCHAR2(2000);
	l_return_status  VARCHAR2(10);
	l_status         BOOLEAN;
BEGIN
    AS_GAR.g_debug_flag := p_debug;
    IF P_trace = 'Y' THEN AS_GAR.SETTRACE; END IF;
    AS_GAR.LOG(G_ENTITY || G_PR_PROPOSAL || AS_GAR.G_START);
   IF P_submit_prp_tap = 'Y' THEN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_START);
        AS_GAR.Set_Area_Sizes;
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_SETAREASIZE || AS_GAR.G_END);

	DELETE_CHANGED_ENTITY(p_entity        => 'PROPOSAL',
       			      x_errbuf        => l_errbuf,
		              x_retcode       => l_retcode,
	                      x_return_status => l_return_status);


        IF p_addl_where IS NOT NULL THEN
         l_addl_where := 'Where ' || p_addl_Where;
        END IF;
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_PROPOSAL || G_WHERE || l_addl_where);
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_PROPOSAL || AS_GAR.G_START);
        Process_trans_data(
	   p_trans_id	  => -1106
          ,P_addl_where	  => l_addl_where
	  ,P_percent_analyzed =>P_perc_analyzed
	  ,P_trace_mode    => p_trace
	  ,x_return_status => l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_PROPOSAL || AS_GAR.G_END ||l_return_status);
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_PROPOSAL || AS_GAR.G_RETURN_STATUS || l_return_status);
      If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || G_PR_PROPOSAL, l_errbuf, l_retcode);
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;
   END IF;
   AS_GAR.LOG(G_ENTITY || G_PR_PROPOSAL || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Assign_Proposal_Terr_Accesses;

PROCEDURE Process_trans_data
(
 p_trans_id	IN NUMBER,
 P_addl_where	IN VARCHAR2,
 P_percent_analyzed IN NUMBER,
 P_trace_mode   IN  VARCHAR2,
 x_return_Status OUT NOCOPY VARCHAR2
 )
IS
l_return_status VARCHAR2(10);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_errbuf        VARCHAR2(1000);
l_retcode       VARCHAR2(1000);
l_con_req_name  VARCHAR2(150);
l_program_name  VARCHAR2(150);
l_req_id	NUMBER;
l_number	NUMBER;
l_status         BOOLEAN;
l_prof_no_of_workers  NUMBER;
l_entity	VARCHAR2(25);
BEGIN
    IF p_trans_id = -1002 THEN
       AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || G_PR_ACCOUNT || AS_GAR.G_START);
       l_program_name := 'SALES/ACCOUNT PROGRAM';
       l_con_req_name :='ASXGARAC';
       l_prof_no_of_workers := fnd_profile.value('AS_TAP_NUM_CHILD_ACCOUNT_WORKERS');
       l_entity := ': ACCOUNT :';
    ELSIF p_trans_id = -1003 THEN
       AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || G_PR_LEAD || AS_GAR.G_START);
       l_program_name := 'SALES/LEAD PROGRAM';
       l_con_req_name :='ASXGARLD';
       l_prof_no_of_workers := fnd_profile.value('AS_TAP_NUM_CHILD_LEAD_WORKERS');
       l_entity := ' : LEAD : ';
    ELSIF p_trans_id = -1004 THEN
       AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || G_PR_OPPTY || AS_GAR.G_START);
       l_program_name := 'SALES/OPPORTUNITY PROGRAM';
       l_con_req_name :='ASXGAROP';
       l_prof_no_of_workers := fnd_profile.value('AS_TAP_NUM_CHILD_OPPOR_WORKERS');
       l_entity := ' : OPPORTUNITY : ';
    ELSIF p_trans_id = -1105 THEN
       AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || G_PR_QUOTE || AS_GAR.G_START);
       l_program_name := 'SALES/QUOTE PROGRAM';
       l_con_req_name :='ASXGARQT';
       l_prof_no_of_workers := fnd_profile.value('AS_TAP_NUM_CHILD_QUOTE_WORKERS');
       l_entity := ' : QUOTE : ';
    ELSIF p_trans_id = -1106 THEN
       AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || G_PR_PROPOSAL || AS_GAR.G_START);
       l_program_name := 'SALES/PROPOSAL PROGRAM';
       l_con_req_name :='ASXGARPR';
       l_prof_no_of_workers := fnd_profile.value('AS_TAP_NUM_CHILD_PROPOSAL_WORKERS');
       l_entity := ' : PROPOSAL : ';
    END IF;
    IF l_prof_no_of_workers >10 then
        l_prof_no_of_workers := 10;
    END IF;
    AS_GAR.LOG(G_ENTITY ||l_entity|| 'No of Workers :'|| l_prof_no_of_workers ||'% Analyzed:'|| P_percent_analyzed);
    AS_GAR.LOG(G_ENTITY ||l_entity|| 'Additioal Where Clause :'|| P_addl_where);
    AS_GAR.LOG(G_ENTITY ||l_entity|| AS_GAR.G_CALL_TO || G_PR_TRANS || AS_GAR.G_START);
        JTY_ASSIGN_BULK_PUB.collect_trans_data  (
	P_api_version_number => 1.0,
	P_init_msg_list => FND_API.G_FALSE,
	P_source_id => -1001,
	P_trans_id =>p_trans_id,
	P_program_name => l_program_name,
	P_mode => 'TOTAL',
	P_where => P_addl_where,
	P_NO_OF_WORKERS => l_prof_no_of_workers,
	P_percent_analyzed => NVL(P_percent_analyzed,20),
	P_request_id => FND_GLOBAL.Conc_Request_Id,
	X_return_status => l_return_status,
	X_msg_count => l_msg_count,
	X_msg_data => l_msg_data,
	Errbuf => l_errbuf,
	Retcode => l_retcode);
      AS_GAR.LOG(G_ENTITY ||l_entity || AS_GAR.G_CALL_TO || G_PR_TRANS||l_msg_count||l_msg_data|| AS_GAR.G_END);
      AS_GAR.LOG(G_ENTITY ||l_entity || AS_GAR.G_CALL_TO || G_PR_TRANS || AS_GAR.G_RETURN_STATUS || l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY ||l_entity || AS_GAR.G_CALL_TO || G_PR_TRANS||l_msg_count||l_msg_data, l_errbuf, l_retcode);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    FOR i in 1..l_prof_no_of_workers
    LOOP
            AS_GAR.LOG(G_ENTITY ||l_entity || G_GAR_SUBMIT || AS_GAR.G_START ||' Worker ID : ' || i);
	    l_req_id := FND_REQUEST.SUBMIT_REQUEST('AS',
						   l_con_req_name,
						   '',
						   '',
						   FALSE,
						   'TOTAL',
						   AS_GAR.g_debug_flag,
						   P_trace_mode ,
						   i,
						   P_percent_analyzed,
						   CHR(0));

            AS_GAR.LOG(G_ENTITY ||l_entity || G_GAR_SUBMIT || AS_GAR.G_END ||' Request ID : ' || l_req_id);
	    IF l_req_id = 0
	    THEN
		 l_msg_data:=FND_MESSAGE.GET;
                 AS_GAR.LOG(G_ENTITY ||l_entity || G_GAR_SUBMIT || AS_GAR.G_END ||' ERRPR :' || l_msg_data);
		 RAISE  FND_API.G_EXC_ERROR;
	    END IF;
    END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      AS_GAR.LOG_EXCEPTION(G_ENTITY ||l_entity||G_GAR_SUBMIT, SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
 END PROCESS_TRANS_DATA;

-------------Modified as per Bug#5027026-----------------
PROCEDURE DELETE_CHANGED_ENTITY(p_entity IN VARCHAR2,
			        x_errbuf  OUT NOCOPY VARCHAR2,
				x_retcode OUT NOCOPY VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2)IS

	TYPE entity_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
	l_entity_id      entity_id_list;

	CURSOR del_acct_changed IS
	   SELECT  distinct customer_id
	   FROM AS_CHANGED_ACCOUNTS_ALL
	   WHERE lead_id IS NULL
	   AND sales_lead_id IS NULL;

	CURSOR del_lead_changed IS
	   SELECT  distinct sales_lead_id
	   FROM AS_CHANGED_ACCOUNTS_ALL
	   WHERE lead_id IS NULL
	   AND sales_lead_id IS NOT NULL;

	CURSOR del_oppty_changed IS
	   SELECT  distinct lead_id
	   FROM AS_CHANGED_ACCOUNTS_ALL
	   WHERE lead_id IS NOT NULL
	   AND sales_lead_id IS NULL;

	CURSOR del_proposal_changed IS
	   SELECT  distinct proposal_id
	   FROM PRP_CHANGED_PROPOSALS;

	CURSOR del_quote_changed IS
	   SELECT  distinct quote_number
	   FROM ASO_CHANGED_QUOTES;

	l_flag          BOOLEAN;
	l_first         NUMBER;
	l_last          NUMBER;
	l_var           NUMBER;

	l_worker_id     NUMBER;

	l_del_flag      BOOLEAN:=FALSE;
	l_limit_flag    BOOLEAN := FALSE;
	l_MAX_fetches   NUMBER  := 10000;
	l_loop_count    NUMBER  := 0;

	G_DEL_REC  CONSTANT  NUMBER:=10001;
	l_status         BOOLEAN;

BEGIN
	l_var         := nvl(to_number(fnd_profile.value('AS_BULK_COMMIT_SIZE')),10000);
	l_MAX_fetches := nvl(to_number(fnd_profile.value('AS_TERR_RECORDS_TO_OPEN')) ,10000);
	LOOP --{L1
		IF (l_limit_flag) THEN EXIT; END IF;
		l_loop_count := l_loop_count + 1;
		BEGIN
			AS_GAR.LOG(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || ': LOOPCOUNT :- ' ||l_loop_count);
			l_flag := TRUE;
			l_first := 0;
			l_last := 0;

			IF p_entity = 'ACCOUNT' THEN
				OPEN del_acct_changed;
				EXIT WHEN del_acct_changed%NOTFOUND;
				FETCH del_acct_changed BULK COLLECT INTO l_entity_id LIMIT l_MAX_fetches;
			ELSIF p_entity = 'LEAD' THEN
				OPEN del_lead_changed;
				EXIT WHEN del_lead_changed%NOTFOUND;
				FETCH del_lead_changed BULK COLLECT INTO l_entity_id LIMIT l_MAX_fetches;
			ELSIF p_entity = 'OPPTY' THEN
				OPEN del_oppty_changed;
				EXIT WHEN del_oppty_changed%NOTFOUND;
				FETCH del_oppty_changed BULK COLLECT INTO l_entity_id LIMIT l_MAX_fetches;
			ELSIF p_entity = 'QUOTE' THEN
				OPEN del_quote_changed;
				EXIT WHEN del_quote_changed%NOTFOUND;
				FETCH del_quote_changed BULK COLLECT INTO l_entity_id LIMIT l_MAX_fetches;
			ELSIF p_entity = 'PROPOSAL' THEN
				OPEN del_proposal_changed;
				EXIT WHEN del_proposal_changed%NOTFOUND;
				FETCH del_proposal_changed BULK COLLECT INTO l_entity_id LIMIT l_MAX_fetches;
			END IF;

			IF l_entity_id.COUNT < l_MAX_fetches THEN
				l_limit_flag := TRUE;
			END IF;
			IF l_entity_id.count > 0 THEN --{I1
				l_flag  := TRUE;
				l_first := l_entity_id.first;
				l_last  := l_first + l_var;
				AS_GAR.LOG(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || AS_GAR.G_N_ROWS_PROCESSED ||
								 l_entity_id.FIRST || '-' ||
								 l_entity_id.LAST);
				WHILE l_flag LOOP --{L2 10K cust loop
					IF l_last > l_entity_id.LAST THEN
						l_last := l_entity_id.LAST;
					END IF;

							BEGIN
								IF p_entity = 'ACCOUNT' THEN
								   FORALL i in l_first..l_last
									DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
									WHERE ACC.customer_id=l_entity_id(i)
									AND ACC.lead_id IS NULL
									AND ACC.sales_lead_id IS NULL;

								ELSIF p_entity = 'LEAD' THEN
								   FORALL i in l_first..l_last
									DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
									WHERE ACC.sales_lead_id=l_entity_id(i)
									AND ACC.lead_id IS NULL;

								ELSIF p_entity = 'OPPTY' THEN
								   FORALL i in l_first..l_last
									DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
									WHERE ACC.lead_id=l_entity_id(i)
									AND ACC.change_type = 'OPPORTUNITY';

								--Fix for #4891555
								ELSIF p_entity = 'QUOTE' THEN
								   FORALL i in l_first..l_last
									DELETE FROM ASO_CHANGED_QUOTES ACC
									WHERE ACC.quote_number=l_entity_id(i);

								ELSIF p_entity = 'PROPOSAL' THEN
								   FORALL i in l_first..l_last
									DELETE FROM PRP_CHANGED_PROPOSALS ACC
									WHERE ACC.proposal_id=l_entity_id(i);

								END IF;
							   COMMIT;


							EXCEPTION
							WHEN DEADLOCK_DETECTED THEN
								BEGIN --{I2

									ROLLBACK;
									AS_GAR.LOG('processing Individual Delete');
										FOR i IN l_first .. l_last LOOP --{L5
											BEGIN
												AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_UPD_ACCESSES || AS_GAR.G_IND_DEL || AS_GAR.G_START);
												IF p_entity = 'ACCOUNT' THEN
													DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
													WHERE ACC.customer_id=l_entity_id(i)
													AND ACC.lead_id IS NULL
													AND ACC.sales_lead_id IS NULL;
												ELSIF p_entity = 'LEAD' THEN
													DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
													WHERE ACC.sales_lead_id=l_entity_id(i)
													AND ACC.lead_id IS NULL;
												ELSIF p_entity = 'OPPTY' THEN
													DELETE FROM AS_CHANGED_ACCOUNTS_ALL ACC
													WHERE ACC.lead_id=l_entity_id(i)
													AND ACC.change_type = 'OPPORTUNITY';
													--Fix for #4891555

												ELSIF p_entity = 'QUOTE' THEN
													DELETE FROM ASO_CHANGED_QUOTES ACC
													WHERE ACC.quote_number=l_entity_id(i);
												ELSIF p_entity = 'PROPOSAL' THEN
													DELETE FROM PRP_CHANGED_PROPOSALS ACC
													WHERE ACC.proposal_id=l_entity_id(i);
												END IF;
												COMMIT;
											EXCEPTION
												WHEN OTHERS THEN
													AS_GAR.LOG(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || AS_GAR.G_IND_DEL || AS_GAR.G_GENERAL_EXCEPTION);
													AS_GAR.LOG('ENTITY_ID - ' || l_entity_id(i));
											END;
										END LOOP; --}L5
										COMMIT;


								END; --}I2 end of deadlock exception
							WHEN OTHERS THEN
								AS_GAR.LOG_EXCEPTION(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
								IF del_acct_changed%ISOPEN THEN CLOSE del_acct_changed; END IF;
								IF del_lead_changed%ISOPEN THEN CLOSE del_lead_changed; END IF;
								IF del_oppty_changed%ISOPEN THEN CLOSE del_oppty_changed; END IF;

								--IF del_quote_changed%ISOPEN THEN CLOSE del_quote_changed; END IF;
								IF del_proposal_changed%ISOPEN THEN CLOSE del_proposal_changed; END IF;
								x_errbuf  := SQLERRM;
								x_retcode := SQLCODE;
								x_return_status := FND_API.G_RET_STS_ERROR;
							END;

						AS_GAR.LOG(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || AS_GAR.G_N_ROWS_PROCESSED || l_first || '-' || l_last);

					l_first := l_last + 1;
					l_last := l_first + l_var;
					IF l_first > l_entity_id.LAST THEN
					    l_flag := FALSE;
					END IF;
				END LOOP;  --}L2  while l_flag loop (10K cust loop)
			END IF;--}I1
			AS_GAR.LOG(G_ENTITY ||'DELETE FROM CHANGED ENTITY::' || AS_GAR.G_END);
			COMMIT;
		EXCEPTION
			WHEN Others THEN
				AS_GAR.LOG_EXCEPTION(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity || AS_GAR.G_GENERAL_EXCEPTION, SQLERRM, TO_CHAR(SQLCODE));
				IF del_acct_changed%ISOPEN THEN CLOSE del_acct_changed; END IF;
				IF del_lead_changed%ISOPEN THEN CLOSE del_lead_changed; END IF;
				IF del_oppty_changed%ISOPEN THEN CLOSE del_oppty_changed; END IF;
				IF del_quote_changed%ISOPEN THEN CLOSE del_quote_changed; END IF;
				IF del_proposal_changed%ISOPEN THEN CLOSE del_proposal_changed; END IF;
				x_errbuf  := SQLERRM;
				x_retcode := SQLCODE;
				x_return_status := FND_API.G_RET_STS_ERROR;
		END;
	END LOOP;--}L1
	IF del_acct_changed%ISOPEN THEN CLOSE del_acct_changed; END IF;
	IF del_lead_changed%ISOPEN THEN CLOSE del_lead_changed; END IF;
	IF del_oppty_changed%ISOPEN THEN CLOSE del_oppty_changed; END IF;
	IF del_quote_changed%ISOPEN THEN CLOSE del_quote_changed; END IF;
	IF del_proposal_changed%ISOPEN THEN CLOSE del_proposal_changed; END IF;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      AS_GAR.LOG_EXCEPTION(G_ENTITY || 'DELETE FROM CHANGED ENTITY::' || p_entity , SQLERRM, TO_CHAR(SQLCODE));
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END;


END AS_ATA_TOTAL_PUB;

/
