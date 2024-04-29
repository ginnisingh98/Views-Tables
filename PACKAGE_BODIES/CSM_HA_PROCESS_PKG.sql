--------------------------------------------------------
--  DDL for Package Body CSM_HA_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HA_PROCESS_PKG" AS
/* $Header: csmhapb.pls 120.0.12010000.11 2010/06/08 17:40:19 trajasek noship $*/
g_debug_level           NUMBER; -- debug level

PROCEDURE SAVE_SEQUENCE(p_session_id   IN NUMBER, p_action IN VARCHAR2)
AS
	--Actions
--'A' Apply
--'R' Record
CURSOR c_get_limits(b_session_id NUMBER)
IS
 SELECT HA_PAYLOAD_START,HA_PAYLOAD_END FROM CSM_HA_SESSION_INFO WHERE SESSION_ID = b_session_id;

CURSOR c_get_sequences(b_payload_start NUMBER,b_payload_end NUMBER)
IS
    SELECT SEQ_MAPPING_ID,SEQUENCE_OWNER||'.'||SEQUENCE_NAME ,INCREMENT_BY
    FROM CSM_HA_SEQ_MAPPINGS
    WHERE BUSINESS_OBJECT_NAME IN (SELECT OBJECT_NAME
	                               FROM CSM_HA_PAYLOAD_DATA
                                   WHERE  HA_PAYLOAD_ID between b_payload_start AND b_payload_end
								   AND DML_TYPE='I');

l_start_sequence NUMBER;
l_End_sequence   NUMBER :=0;
l_inc_sequence   NUMBER :=0;
l_increment_by   NUMBER :=0;
L_SQL_QUERY      varchar2(4000);

l_sequence_list    CSM_VARCHAR_LIST;
L_CURRENT_SEQUENCE number;
L_APPLIED_SEQUENCE_VALUE NUMBER;

TYPE l_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_seq_map_list  l_num_type;
l_inc_list l_num_type;

l_payload_start NUMBER;
l_payload_end NUMBER;

BEGIN

  OPEN  C_GET_LIMITS (P_SESSION_ID);
  FETCH c_get_limits INTO l_payload_start,l_payload_end;
  CLOSE c_get_limits;

  OPEN  c_get_sequences(l_payload_start,l_payload_end);
  FETCH c_get_sequences BULK COLLECT INTO l_seq_map_list,l_sequence_list,l_inc_list;
  CLOSE c_get_sequences;

  IF l_seq_map_list.COUNT = 0 THEN
	CSM_UTIL_PKG.log( 'No Business Object Sequence seems to have been updated in this recording session',
                      'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);
    RETURN;
  END IF;

  FOR j in 1..l_seq_map_list.COUNT
  LOOP

      execute immediate 'SELECT  ' ||l_sequence_list(j) || '.NEXTVAL - '||l_inc_list(j)||' FROM dual'
      INTO L_CURRENT_SEQUENCE;

      IF p_action ='R' THEN

        CSM_UTIL_PKG.log( 'RECORD: SESSION_ID: ' || P_SESSION_ID || ' SEQUENCE_NAME: '
                       ||l_sequence_list(j) || ' Sequence Value: ' || l_current_sequence,
                        'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

        INSERT INTO CSM_HA_SESSION_SEQ_VALUES(SESSION_ID,SEQ_MAPPING_ID,
        RECORDED_SEQUENCE,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
        VALUES(p_session_id,l_seq_map_list(j),l_current_sequence,sysdate,1,sysdate,1,1);

      ELSE

        CSM_UTIL_PKG.log( 'APPLY: SESSION_ID: ' || P_SESSION_ID || ' SEQUENCE_NAME: '
                        ||l_sequence_list(j) || ' Sequence Value: ' || l_current_sequence,
                         'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

        UPDATE CSM_HA_SESSION_SEQ_VALUES
        SET APPLY_SEQUENCE    = L_CURRENT_SEQUENCE
        WHERE  SESSION_ID     = P_SESSION_ID
        and    SEQ_MAPPING_ID = L_SEQ_MAP_LIST(J)
        RETURNING APPLY_SEQUENCE,RECORDED_SEQUENCE INTO L_START_SEQUENCE,L_END_SEQUENCE;

        l_inc_sequence := l_End_sequence - l_start_sequence;

        IF(l_inc_sequence > 0) THEN
          L_SQL_QUERY := 'ALTER SEQUENCE '||L_SEQUENCE_LIST(J) ||' INCREMENT BY ' || L_INC_SEQUENCE;
          CSM_UTIL_PKG.log(L_SQL_QUERY, 'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);
          execute immediate L_SQL_QUERY;

          /* This select actually increments the sequence value */
          execute immediate 'SELECT ' ||L_SEQUENCE_LIST(J) || '.NEXTVAL  FROM dual'
          into L_APPLIED_SEQUENCE_VALUE;

          CSM_UTIL_PKG.log('Sequence: ' || L_SEQUENCE_LIST(J) ||
          ' Modified Sequence Value: ' || l_applied_sequence_value,
          'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

          UPDATE CSM_HA_SESSION_SEQ_VALUES
          set AFTER_APPLY_SEQUENCE   = L_APPLIED_SEQUENCE_VALUE
          WHERE  SESSION_ID=p_session_id
          and    SEQ_MAPPING_ID  = L_SEQ_MAP_LIST(J);

          /* Set the increment_by back to what it was */
          L_SQL_QUERY := 'ALTER SEQUENCE '||L_SEQUENCE_LIST(J) ||' INCREMENT BY ' || l_inc_list(J);
          CSM_UTIL_PKG.log(L_SQL_QUERY, 'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE',FND_LOG.LEVEL_STATEMENT);
          execute immediate L_SQL_QUERY;

        end if;
      END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in SAVE_SEQUENCE : ' ||   SUBSTR(SQLERRM,1,3000), 'CSM_HA_PROCESS_PKG.SAVE_SEQUENCE',
    FND_LOG.LEVEL_EXCEPTION);

END SAVE_SEQUENCE;

PROCEDURE DISABLE_WF_ONAPPLY
IS
l_t NUMBER;
BEGIN
 FOR rec IN (SELECT WF_ITEM_TYPE,WF_EVENT_NAME,WF_EVENT_SUBSCRIPTION_GUID
             FROM CSM_HA_ACTIVE_WF_COMPONENTS
			 WHERE AUTO_DISABLE_FLAG='Y' AND ENABLED_ON_APPLY='N')
 LOOP
   IF rec.WF_EVENT_NAME IS NOT NULL THEN
    IF rec.WF_EVENT_SUBSCRIPTION_GUID IS NULL THEN
      UPDATE wf_events SET STATUS='DISABLED' WHERE lower(name)=lower(rec.WF_EVENT_NAME);
    ELSE
      UPDATE wf_event_subscriptions SET STATUS='DISABLED'
      WHERE GUID=rec.WF_EVENT_SUBSCRIPTION_GUID
      AND EVENT_FILTER_GUID = (SELECT GUID FROM WF_EVENTS WHERE LOWER(NAME)=LOWER(REC.WF_EVENT_NAME));
    END IF;
  END IF;
 END LOOP;
END DISABLE_WF_ONAPPLY;

PROCEDURE ENABLE_WF_ONAPPLY
IS
l_t NUMBER;
BEGIN
 FOR rec IN (SELECT WF_ITEM_TYPE,WF_EVENT_NAME,WF_EVENT_SUBSCRIPTION_GUID
             FROM CSM_HA_ACTIVE_WF_COMPONENTS
			 WHERE AUTO_DISABLE_FLAG='Y' AND ENABLED_ON_APPLY='N')
 LOOP
   IF rec.WF_EVENT_NAME IS NOT NULL THEN
    IF rec.WF_EVENT_SUBSCRIPTION_GUID IS NULL THEN
      UPDATE wf_events SET STATUS='ENABLED' WHERE lower(name)=lower(rec.WF_EVENT_NAME);
    ELSE
      UPDATE wf_event_subscriptions SET STATUS='ENABLED'
      WHERE GUID=rec.WF_EVENT_SUBSCRIPTION_GUID
      AND EVENT_FILTER_GUID = (SELECT GUID FROM WF_EVENTS WHERE LOWER(NAME)=LOWER(REC.WF_EVENT_NAME));
    END IF;
	END IF;
 END LOOP;
END ENABLE_WF_ONAPPLY;

PROCEDURE SET_CONTEXT(  P_CON_NAME_LIST  CSM_VARCHAR_LIST,
                        p_CON_VALUE_LIST CSM_VARCHAR_LIST,
                        X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                        X_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
L_USER_ID NUMBER;
L_APPL_ID NUMBER;
L_RESP_ID NUMBER;

BEGIN
  IF P_CON_NAME_LIST IS NOT NULL THEN
      FOR I IN 1..P_CON_NAME_LIST.COUNT-1 LOOP

        IF  P_CON_VALUE_LIST(I) IS NOT NULL THEN
          IF p_CON_NAME_LIST(i) = 'USER_ID' THEN
            L_USER_ID := p_CON_VALUE_LIST(i);
          ELSIF  p_CON_NAME_LIST(i) = 'RESP_APPL_ID' THEN
            L_APPL_ID := p_CON_VALUE_LIST(I);
          ELSIF  p_CON_NAME_LIST(I) = 'RESP_ID' THEN
            L_RESP_ID := p_CON_VALUE_LIST(I);
          END IF;
        END IF;
        L_USER_ID := NVL(L_USER_ID,FND_GLOBAL.USER_ID);
        L_RESP_ID := NVL(L_USER_ID,FND_GLOBAL.RESP_ID);
        L_APPL_ID := NVL(L_USER_ID,FND_GLOBAL.RESP_APPL_ID);
      END LOOP;
  ELSE
        L_USER_ID := FND_GLOBAL.USER_ID;
        L_RESP_ID := FND_GLOBAL.RESP_ID;
        L_APPL_ID := FND_GLOBAL.RESP_APPL_ID;

  END IF;

  FND_GLOBAL.APPS_INITIALIZE(L_USER_ID, L_RESP_ID, L_APPL_ID);

END SET_CONTEXT;

PROCEDURE SET_DEFERRED( P_HA_SESSION_ID NUMBER,
                        p_HA_PAYLOAD_ID NUMBER,
                        P_STATUS       NUMBER,
                        P_ERROR_MESSAGE VARCHAR2)
IS
  CURSOR C_GET_RECORD (C_SESSION_ID NUMBER,C_HA_PAYLOAD_ID NUMBER)
  IS
  SELECT 1 FROM CSM_HA_DEFERRED_INFO
  WHERE SESSION_ID    = c_session_id
  AND   HA_PAYLOAD_ID = C_HA_PAYLOAD_ID;

  L_RECORD_EXIST NUMBER := NULL;

BEGIN
  OPEN  C_GET_RECORD(P_HA_SESSION_ID,p_HA_PAYLOAD_ID);
  FETCH C_GET_RECORD INTO   L_RECORD_EXIST;
  CLOSE C_GET_RECORD;

  IF L_RECORD_EXIST IS NOT NULL THEN
      UPDATE CSM_HA_DEFERRED_INFO
      SET    STATUS       = P_STATUS,
             ERROR_MSG    = P_ERROR_MESSAGE,
             FAILURES     = FAILURES +1 ,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY  = FND_GLOBAL.USER_ID
      WHERE SESSION_ID    = P_HA_SESSION_ID
      AND   HA_PAYLOAD_ID = p_HA_PAYLOAD_ID;
  ELSE
        INSERT INTO CSM_HA_DEFERRED_INFO(SESSION_ID,HA_PAYLOAD_ID,STATUS,ERROR_MSG,FAILURES,
              CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
        VALUES(P_HA_SESSION_ID,P_HA_PAYLOAD_ID,P_STATUS,P_ERROR_MESSAGE,1,
               SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID );
  END IF;

END SET_DEFERRED;

PROCEDURE PROCESS_HA(X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                     x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
AS
CURSOR c_get_payload_info(c_session_id NUMBER)
IS
SELECT HA_PAYLOAD_START,
       Ha_Payload_End
FROM  CSM_HA_SESSION_INFO
WHERE SESSION_ID = c_session_id;

CURSOR c_get_payload_to_process(c_payload_start NUMBER, c_payload_end NUMBER)
IS
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE,
       MOBILE_DATA
FROM   CSM_HA_PAYLOAD_DATA
WHERE  HA_PAYLOAD_ID >= C_PAYLOAD_START
And    Ha_Payload_Id <= C_Payload_End
AND    HA_PAYLOAD_ID = PARENT_PAYLOAD_ID
AND    NVL(STATUS,'NP') <> 'SUCCESS'
ORDER BY HA_PAYLOAD_ID ASC;

CURSOR c_get_session_to_process
IS
Select  Session_Id,Status
FROM    CSM_HA_SESSION_INFO
where   SESSION_ID > (select NVL(max(SESSION_ID),0) from CSM_HA_SESSION_INFO
                      where   SESSION_END_TIME is not null and
                      STATUS = 'PROCESSED')
AND     STATUS = 'COMPLETED'
ORDER BY Session_Id ASC;

 CURSOR c_date_f
 IS
 SELECT upper(VALUE)
 FROM NLS_SESSION_PARAMETERS
 WHERE PARAMETER='NLS_DATE_FORMAT';

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
ORDER BY HA_PAYLOAD_ID ASC;

r_Get_Aux_objects C_Get_Aux_objects%ROWTYPE;

TYPE PAYLOAD_ID IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE OBJECT_NAME IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE DML_TYPE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_HA_PAYLOAD_START NUMBER;
l_HA_PAYLOAD_END   NUMBER;
l_session_id       NUMBER;
l_HA_PAYLOAD_ID   PAYLOAD_ID;
l_HA_OBJECT_NAME  OBJECT_NAME;
l_COL_NAME_LIST  CSM_VARCHAR_LIST;
l_COL_VALUE_LIST CSM_VARCHAR_LIST;
l_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
l_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
L_STATUS         VARCHAR(250);
L_DML_TYPE       DML_TYPE;
L_MOBILE_DATA    DML_TYPE;
G_DATE_FORMAT           VARCHAR2(100);
L_DATE_FORMAT           VARCHAR2(100);
L_ENABLE_AUDIT  BOOLEAN;
begin

  CSM_UTIL_PKG.log
  ( 'Entering Process HA : ', 'CSM_HA_PROCESS_PKG.PROCESS_HA',
    FND_LOG.LEVEL_PROCEDURE);

  --Set the HA Profile to Apply
  CSM_HA_PROCESS_PKG.SET_HA_PROFILE('HA_APPLY');

  --DISABLE WF COMPONENTS
  DISABLE_WF_ONAPPLY;

  --Set the Task Manager Audit to No
  L_ENABLE_AUDIT := JTF_TASK_UTL.ENABLE_AUDIT (P_ENABLE => FALSE);

  --set the date format in accordance with recording
   IF g_date_format IS NULL THEN
     OPEN c_date_f;
     FETCH c_date_f INTO g_date_format;
     CLOSE c_date_f;
   END IF;

   L_DATE_FORMAT := g_date_format;

   IF g_date_format <> 'DD-MON-RR HH24:MI:SS' THEN
     CSM_UTIL_PKG.LOG('Setting Date format to DD-MON-RR HH24:MI:SS',
                    'CSM_HA_PROCESS_PKG.PROCESS_HA', FND_LOG.LEVEL_PROCEDURE);
	 EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-RR HH24:MI:SS''';
     g_date_format := 'DD-MON-RR HH24:MI:SS';
   END IF;

  --Get all the sessions to be processed
  FOR R_GET_SESSION_TO_PROCESS IN   C_GET_SESSION_TO_PROCESS LOOP

    --set the session to the local variabe
    L_SESSION_ID := R_GET_SESSION_TO_PROCESS.SESSION_ID;

    --Update the status
    UPDATE CSM_HA_SESSION_INFO
    SET    STATUS            = 'PROCESSING',
           COMMENTS          = 'HA is getting Processed.',
           CONC_REQUEST_ID   = G_CON_REQUEST_ID,
           APPLY_START_DATE  = SYSDATE,
           LAST_UPDATE_DATE  = SYSDATE,
           LAST_UPDATED_BY   = 1
   WHERE SESSION_ID = L_SESSION_ID;

    CSM_UTIL_PKG.log('PROCESS_HA: Selected Session_ID : '||  L_SESSION_ID,
   'CSM_HA_PROCESS_PKG.PROCESS_HA', FND_LOG.LEVEL_STATEMENT);

       --Set the max sequence during record in the CSM_HA_SEQ_MAPPINGS table
    CSM_UTIL_PKG.log( 'Syncing Sequences...', 'CSM_HA_PROCESS_PKG.PROCESS_HA',
        FND_LOG.LEVEL_STATEMENT);

    SAVE_SEQUENCE(P_SESSION_ID => L_SESSION_ID, P_ACTION => 'A');

    CSM_UTIL_PKG.log( 'Done Setting Sequences', 'CSM_HA_PROCESS_PKG.PROCESS_HA',
        FND_LOG.LEVEL_STATEMENT);

      --get the payloads interval
      OPEN c_get_payload_info(l_session_id);
      FETCH c_get_payload_info INTO l_HA_PAYLOAD_START,l_HA_PAYLOAD_END;
      CLOSE c_get_payload_info;

      --get the obects to be processed
      OPEN C_GET_PAYLOAD_TO_PROCESS(L_HA_PAYLOAD_START,L_HA_PAYLOAD_END);
      FETCH c_get_payload_to_process BULK COLLECT INTO l_HA_PAYLOAD_ID,l_HA_OBJECT_NAME,l_DML_TYPE,L_MOBILE_DATA;
      CLOSE C_GET_PAYLOAD_TO_PROCESS;


      FOR I IN 1..L_HA_PAYLOAD_ID.COUNT LOOP
        --Get the object in Table
        CSM_UTIL_PKG.log
         ('Processing Payload ID: ' || L_HA_PAYLOAD_ID(I),
          'CSM_HA_PROCESS_PKG.PROCESS_HA', FND_LOG.LEVEL_STATEMENT);
        --set the value to success for each object processing
        L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
        L_ERROR_MESSAGE := NULL;
        IF L_MOBILE_DATA(I) = 'N' THEN
          CSM_HA_PROCESS_PKG.PARSE_XML(p_HA_PAYLOAD_ID =>l_HA_PAYLOAD_ID(i),
                          x_COL_NAME_LIST  => l_COL_NAME_LIST,
                          X_COL_VALUE_LIST => L_COL_VALUE_LIST,
                          X_CON_NAME_LIST  => L_CON_NAME_LIST,
                          x_CON_VALUE_LIST => l_CON_VALUE_LIST,
                          x_RETURN_STATUS  => l_RETURN_STATUS,
                          X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
        END IF;
        BEGIN
          SAVEPOINT SAVE_REC;
          IF  L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS AND  L_COL_NAME_LIST.COUNT > 0 THEN
            --Set the context
            SET_CONTEXT(P_CON_NAME_LIST  => L_CON_NAME_LIST,
                        p_CON_VALUE_LIST => l_CON_VALUE_LIST,
                        X_RETURN_STATUS  => L_RETURN_STATUS,
                        X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
            --Set session before calling the api
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-RR HH24:MI:SS''';


            IF L_HA_OBJECT_NAME(I) = 'CS_INCIDENTS_ALL_B' THEN

              CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES
               (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
            ELSIF L_HA_OBJECT_NAME(I) = 'JTF_TASKS_B' THEN
              CSM_TASKS_PKG.APPLY_HA_CHANGES
               (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );

            ELSIF L_Ha_Object_Name(I) = 'JTF_TASK_ALL_ASSIGNMENTS' Then

              CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES
               (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
            ELSIF l_HA_OBJECT_NAME(i) = 'CS_INCIDENT_LINKS' THEN

              /*CSM_SR_ATTRIBUTES_PKG.APPLY_HA_LINK_CHANGES
                (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
                );*/
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
            ELSIF l_HA_OBJECT_NAME(i) = 'CUG_INCIDNT_ATTR_VALS_B' THEN

                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);

                FOR r_Get_Aux_objects IN C_Get_Aux_Objects(L_HA_PAYLOAD_ID(I)) LOOP
                  CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => r_Get_Aux_objects.HA_PAYLOAD_ID
                                      ,X_RETURN_STATUS => l_RETURN_STATUS
                                      ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
                END LOOP;

            ELSIF L_HA_OBJECT_NAME(I) = 'JTF_NOTES_B' THEN
              CSM_NOTES_PKG.APPLY_HA_CHANGES
                (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
                );
            ELSIF L_HA_OBJECT_NAME(I) = 'CSF_DEBRIEF_HEADERS' THEN
              CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES
                (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
                );
            ELSIF L_HA_OBJECT_NAME(I) = 'CSF_DEBRIEF_LINES' THEN
              CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_LINE_CHANGES
                (P_HA_PAYLOAD_ID  =>L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
                );
            ELSIF L_HA_OBJECT_NAME(I) = 'FND_DOCUMENTS' THEN
              CSM_LOBS_PKG.APPLY_HA_CHANGES
                (P_HA_PAYLOAD_ID => L_HA_PAYLOAD_ID(I),
                p_COL_NAME_LIST  => l_COL_NAME_LIST,
                P_COL_VALUE_LIST => L_COL_VALUE_LIST,
                p_dml_type       => l_DML_TYPE(I),
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
                );
            ELSIF  L_HA_OBJECT_NAME(I) = 'CSF_REQUIRED_SKILLS_B'THEN
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);

            ELSIF  L_HA_OBJECT_NAME(I) = 'CS_INCIDENT_LINKS_EXT'THEN
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);

            ELSIF  L_HA_OBJECT_NAME(I) = 'CAC_SR_OBJECT_CAPACITY'THEN
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);

            ELSIF  L_HA_OBJECT_NAME(I) = 'CSF_ACCESS_HOURS_B'THEN
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);

                FOR r_Get_Aux_objects IN C_Get_Aux_Objects(L_HA_PAYLOAD_ID(I)) LOOP
                  CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => r_Get_Aux_objects.HA_PAYLOAD_ID
                                      ,X_RETURN_STATUS => l_RETURN_STATUS
                                      ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
                END LOOP;

            ELSIF  L_MOBILE_DATA(I) ='Y' THEN
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML
                    (P_PAYLOAD_ID    => L_HA_PAYLOAD_ID(I)
                    ,X_RETURN_STATUS => l_RETURN_STATUS
                    ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
            END IF;

            IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

              UPDATE CSM_HA_PAYLOAD_DATA
              SET    STATUS    = 'SUCCESS',
                     PROCESSED = 'Y',
                     COMMENTS  = L_ERROR_MESSAGE
              WHERE  PARENT_PAYLOAD_ID = L_HA_PAYLOAD_ID(I);

              --Do Auditing if the Apply changes is successful.
             /* CSM_HA_AUDIT_PKG.AUDIT_RECORD(P_HA_PAYLOAD_ID => L_HA_PAYLOAD_ID(I)
                                         ,P_AUDIT_TYPE    => 'APPLY');*/
            Else
              ROLLBACK TO SAVE_REC;
              UPDATE CSM_HA_PAYLOAD_DATA
              SET    STATUS    = 'FAILED',
                     PROCESSED = 'Y',
                     COMMENTS  = L_ERROR_MESSAGE
              WHERE  PARENT_PAYLOAD_ID = L_HA_PAYLOAD_ID(I);
              --set the record to deferred
              SET_DEFERRED( P_HA_SESSION_ID => L_SESSION_ID,
                        P_HA_PAYLOAD_ID     => L_HA_PAYLOAD_ID(I),
                        P_STATUS            => 1, --1=>deferred
                        P_ERROR_MESSAGE     => L_ERROR_MESSAGE);
            End If;

          End If;
          COMMIT;
        Exception When Others Then
          ROLLBACK TO SAVE_REC;
          L_ERROR_MESSAGE := Substr(Sqlerrm,1,2000);
          UPDATE CSM_HA_PAYLOAD_DATA
          SET    STATUS    = 'FAILED',
                  PROCESSED = 'Y',
                  COMMENTS  = L_ERROR_MESSAGE
          Where  PARENT_PAYLOAD_ID = L_Ha_Payload_Id(I);
          /*** catch and log exceptions ***/
          CSM_UTIL_PKG.LOG
          ( 'Exception occurred in PROCESS_HA : ' ||  Substr(Sqlerrm,1,3000), 'CSM_HA_PROCESS_PKG.PROCESS_HA',
          FND_LOG.LEVEL_EXCEPTION);
        END;

        COMMIT;
      END LOOP; --Payload processing

      CSM_UTIL_PKG.log
       ( 'Done Processing all transactions', 'CSM_HA_PROCESS_PKG.PROCESS_HA',
        FND_LOG.LEVEL_STATEMENT);

      UPDATE CSM_HA_SESSION_INFO
      SET    STATUS            = 'PROCESSED',
             COMMENTS          = 'HA Successfully Processed.',
             CONC_REQUEST_ID   = G_CON_REQUEST_ID,
             APPLY_END_DATE    = SYSDATE,
             LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = 1
     WHERE SESSION_ID = L_SESSION_ID;
     COMMIT; --commit after every session is processed;

  END LOOP; --multiple session loop

  --Set the Task Manager Profile to TRUE to enable Audit
  L_ENABLE_AUDIT := JTF_TASK_UTL.ENABLE_AUDIT (P_ENABLE => TRUE);

  --ENABLE WF COMPONENTS
  ENABLE_WF_ONAPPLY;
  IF L_DATE_FORMAT IS NOT NULL THEN

     CSM_UTIL_PKG.LOG('Setting Date format to' || L_DATE_FORMAT ,
                    'CSM_HA_PROCESS_PKG.PROCESS_HA', FND_LOG.LEVEL_PROCEDURE);

     EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT='''|| L_DATE_FORMAT || '''';
     G_DATE_FORMAT := L_DATE_FORMAT;
  END IF;

  --Set the HA Profile to Stop telling HA stage is completed
  CSM_HA_PROCESS_PKG.SET_HA_PROFILE('HA_STOP');

  CSM_UTIL_PKG.log( 'Leaving PROCESS_HA', 'CSM_HA_PROCESS_PKG.PROCESS_HA',
        FND_LOG.LEVEL_STATEMENT);

  COMMIT;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in PROCESS_HA : ' ||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_PROCESS_PKG.PROCESS_HA',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := 'Process HA failed with error  : ' || SUBSTR(SQLERRM,1,3000) ;

      UPDATE CSM_HA_SESSION_INFO
      SET    STATUS            = 'PROCESSED',
             COMMENTS          = 'HA Successfully Processed.',
             APPLY_END_DATE    = SYSDATE,
             LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = 1
     WHERE SESSION_ID = L_SESSION_ID;

   IF L_DATE_FORMAT IS NOT NULL THEN

     CSM_UTIL_PKG.LOG('Setting Date format to' || L_DATE_FORMAT ,
                    'CSM_HA_PROCESS_PKG.PROCESS_HA', FND_LOG.LEVEL_PROCEDURE);

	 EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT='''|| L_DATE_FORMAT || '''';
     G_DATE_FORMAT := L_DATE_FORMAT;
   END IF;

  --Set the Task Manager Profile to TRUE to enable Audit
  L_ENABLE_AUDIT := JTF_TASK_UTL.ENABLE_AUDIT (P_ENABLE => TRUE);

  --ENABLE WF COMPONENTS
  ENABLE_WF_ONAPPLY;

  --Set the HA Profile to Null telling HA stage is completed
  CSM_HA_PROCESS_PKG.SET_HA_PROFILE('HA_STOP');

  COMMIT;
END PROCESS_HA;

PROCEDURE PARSE_XML(p_HA_PAYLOAD_ID    IN NUMBER,
                    X_COL_NAME_LIST  OUT  NOCOPY  CSM_VARCHAR_LIST,
                    X_COL_VALUE_LIST OUT  NOCOPY  CSM_VARCHAR_LIST,
                    X_CON_NAME_LIST  OUT  NOCOPY  CSM_VARCHAR_LIST,
                    X_CON_VALUE_LIST OUT  NOCOPY  CSM_VARCHAR_LIST,
                    X_RETURN_STATUS  OUT  NOCOPY VARCHAR2,
                    x_ERROR_MESSAGE  OUT  NOCOPY VARCHAR2)
AS
CURSOR c_get_xml(c_payload_id NUMBER)
IS
SELECT PAYLOAD,
       Context
FROM   CSM_HA_PAYLOAD_DATA
WHERE  HA_PAYLOAD_ID = c_payload_id;

 l_xml_payload XMLTYPE;
 l_xml_clob_payload CLOB;
 L_XML_CONTEXT XMLTYPE;
 L_XML_CLOB_CONTEXT CLOB;
 l_xml_doc    xmldom.DOMDocument;
 l_xml_parser xmlparser.Parser;
 l_xml_node_list xmldom.DOMNodeList;
 l_xml_node   xmldom.DOMNode;
 l_xml_node_len NUMBER;
 len2 number;
 l_COL_NAME_LIST CSM_VARCHAR_LIST := CSM_VARCHAR_LIST();
 L_COL_VALUE_LIST CSM_VARCHAR_LIST := CSM_VARCHAR_LIST();
 L_CON_NAME_LIST CSM_VARCHAR_LIST := CSM_VARCHAR_LIST();
 L_CON_VALUE_LIST CSM_VARCHAR_LIST := CSM_VARCHAR_LIST();
 L_TEMP_CLOB  CLOB;

BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering PARSE_XML for HA PAYLOAD ID : ' || p_HA_PAYLOAD_ID  ,
        FND_LOG.LEVEL_PROCEDURE);
--Parse Payload
  OPEN   c_get_xml(p_HA_PAYLOAD_ID);
  FETCH  c_get_xml INTO l_xml_payload,l_xml_context;
  CLOSE  c_get_xml;

  IF l_xml_payload IS  NULL THEN
    CSM_UTIL_PKG.LOG
    ( 'Error  occurred in PARSE_XML for HA PAYLOAD ID : ' || p_HA_PAYLOAD_ID, 'CSM_HA_PROCESS_PKG.PARSE_XML',
    FND_LOG.LEVEL_EXCEPTION);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'XML Value is Null ' ;
    RETURN;
  END IF;
  --Convert it to CLOB to parse it
  l_xml_clob_payload := l_xml_payload.getCLOBVal();
  --PARSE the XML
  l_xml_parser := xmlparser.newParser;
  xmlparser.parseClob(l_xml_parser, l_xml_clob_payload);
  L_XML_DOC := XMLPARSER.GETDOCUMENT(L_XML_PARSER);
  xmlparser.freeParser(l_xml_parser);
  l_xml_node_list := xmldom.getElementsByTagName(l_xml_doc, '*');
  L_XML_NODE_LEN := XMLDOM.GETLENGTH(L_XML_NODE_LIST);
  L_COL_NAME_LIST.EXTEND(L_XML_NODE_LEN);
  l_COL_VALUE_LIST.EXTEND(l_xml_node_len);
  -- loop through elements
   FOR I IN 2..L_XML_NODE_LEN-1 LOOP
      l_xml_node := xmldom.item(l_xml_node_list, i);
     -- e := xmldom.makeElement(n);
      --attrname := xmldom.getNodeName(n);
      l_COL_NAME_LIST(i-1) := xmldom.getNodeName(l_xml_node);
      L_XML_NODE := XMLDOM.GETFIRSTCHILD(L_XML_NODE);
      --Condition for Attachment to support BLOB
      IF L_COL_NAME_LIST(I-1) ='FILE_DATA' THEN
        DBMS_LOB.CREATETEMPORARY(L_TEMP_CLOB, TRUE);
        XMLDOM.WRITETOCLOB(L_XML_NODE,L_TEMP_CLOB);
        CSM_LOBS_PKG.G_FILE_ATTACHMENT := CLOB_TO_BLOB( p_clob_data => L_TEMP_CLOB);
      ELSE
        If xmldom.getNodeType(l_xml_node) = xmldom.TEXT_NODE THEN
          l_COL_VALUE_LIST(i-1) := xmldom.getNodeValue(l_xml_node);
        ELSE
          l_COL_VALUE_LIST(i-1) := NULL;
        END IF;
      END IF;
  END LOOP;
  x_COL_NAME_LIST := l_COL_NAME_LIST;
  X_COL_VALUE_LIST := L_COL_VALUE_LIST;

  --Process the Context
  IF L_XML_CONTEXT IS NOT NULL THEN
    --Convert it to CLOB to parse it
    L_XML_CLOB_CONTEXT := L_XML_CONTEXT.GETCLOBVAL();
    --PARSE the XML
    l_xml_parser := xmlparser.newParser;
    xmlparser.parseClob(l_xml_parser, L_XML_CLOB_CONTEXT);
    l_xml_doc := xmlparser.getDocument(l_xml_parser);
    xmlparser.freeParser(l_xml_parser);
    l_xml_node_list := xmldom.getElementsByTagName(l_xml_doc, '*');
    l_xml_node_len := xmldom.getLength(l_xml_node_list);

    L_CON_NAME_LIST.EXTEND(L_XML_NODE_LEN);
    l_CON_VALUE_LIST.EXTEND(l_xml_node_len);
    -- loop through elements
     FOR i IN 2..l_xml_node_len-1 LOOP
        l_xml_node := xmldom.item(l_xml_node_list, i);
        l_CON_NAME_LIST(i-1) := xmldom.getNodeName(l_xml_node);
        l_xml_node := xmldom.getFirstChild(l_xml_node);

       IF XMLDOM.GETNODETYPE(L_XML_NODE) = XMLDOM.TEXT_NODE THEN
          l_CON_VALUE_LIST(i-1) := xmldom.getNodeValue(l_xml_node);
       ELSE
          l_CON_VALUE_LIST(i-1) := NULL;
        END IF;
    END LOOP;
    X_CON_NAME_LIST  := L_CON_NAME_LIST;
    X_CON_VALUE_LIST := L_CON_VALUE_LIST;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_error_message := 'XML Parsing Successfully completed ';
     CSM_UTIL_PKG.LOG
      ( 'Leaving PARSE_XML for HA PAYLOAD ID after successfully Executing : ' || p_HA_PAYLOAD_ID , 'CSM_HA_PROCESS_PKG.PARSE_XML',
        FND_LOG.LEVEL_PROCEDURE);


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in PARSE_XML for HA PAYLOAD ID : ' || p_HA_PAYLOAD_ID  ||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_PROCESS_PKG.PARSE_XML',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'XML Retrieve Failed With Message : ' || SUBSTR(SQLERRM,1,3000) ;
END PARSE_XML;

FUNCTION PROCESS_HA
RETURN  NUMBER
IS
l_RETURN_STATUS VARCHAR2(100);
l_ERROR_MESSAGE VARCHAR2(4000);
L_RESULT BOOLEAN;

BEGIN
 FND_GLOBAL.APPS_INITIALIZE (FND_GLOBAL.USER_ID,FND_GLOBAL.RESP_ID,FND_GLOBAL.RESP_APPL_ID);
 G_CON_REQUEST_ID :=FND_REQUEST. SUBMIT_REQUEST('ASG','ASG_APPLY','Process HA', SYSDATE,FALSE,'Y');
 COMMIT;
 RETURN G_CON_REQUEST_ID;
END PROCESS_HA;



--Private Api
PROCEDURE PROCESS_DIRECT_UPDATE(P_TABLE_NAME IN VARCHAR2,P_PK_VALUE IN VARCHAR2,
                              P_COL_NAME_LIST IN CSM_VARCHAR_LIST,P_COL_VALUE_LIST IN CSM_VARCHAR_LIST,
                              x_RETURN_STATUS OUT NOCOPY VARCHAR2 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
 l_stmt           LONG;
  l_pk_cols VARCHAR2(300);
BEGIN

    l_pk_cols:=CSM_HA_EVENT_PKG.get_pk_column_name(P_TABLE_NAME);

    IF	l_pk_cols IS NULL THEN
	  RAISE_APPLICATION_ERROR(-20222,'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_UPDATE- NO PK COLUMN FOUND');
	END IF;

    l_stmt := 'UPDATE '||P_TABLE_NAME||' SET '||P_COL_NAME_LIST(1)||'='''||P_COL_VALUE_LIST(1)||''' ';

	FOR j IN 2..P_COL_NAME_LIST.COUNT
	LOOP
	   IF(P_COL_NAME_LIST(j) IS NOT NULL) THEN
	     l_stmt := l_stmt||', '||P_COL_NAME_LIST(j)||'='''||P_COL_VALUE_LIST(j)||''' ';
	   END IF;
    END LOOP;

	l_stmt := l_stmt ||CSM_HA_EVENT_PKG.get_predicate_clause(l_pk_cols,P_PK_VALUE);

    EXECUTE IMMEDIATE l_stmt;

    x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    x_ERROR_MESSAGE := 'Update Successful';

EXCEPTION
 WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in PROCESS_DIRECT_UPDATE:'||  SUBSTR(SQLERRM,1,3000),
    'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_UPDATE', FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'PROCESS_DIRECT_UPDATE failed with error:' || SUBSTR(SQLERRM,1,3000) ;
  RAISE;
END PROCESS_DIRECT_UPDATE;

--Private Api
PROCEDURE PROCESS_DIRECT_INSERT(P_TABLE_NAME IN VARCHAR2,P_PK_VALUE IN VARCHAR2,
                              P_COL_NAME_LIST IN CSM_VARCHAR_LIST,
                              P_COL_VALUE_LIST IN CSM_VARCHAR_LIST,
                              x_RETURN_STATUS OUT NOCOPY VARCHAR2 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
 L_STMT           LONG;
 L_SEL_STMT       LONG;
 L_PK_COLS        VARCHAR2(300);
 L_ACTION         VARCHAR2(300) :=  NULL;

BEGIN

  L_PK_COLS:=CSM_HA_EVENT_PKG.GET_PK_COLUMN_NAME(P_TABLE_NAME);

  L_STMT := 'INSERT INTO '||P_TABLE_NAME||'('||P_COL_NAME_LIST(1);
  L_SEL_STMT := 'SELECT 1 FROM '||P_TABLE_NAME||' ';
 	L_SEL_STMT := L_SEL_STMT ||CSM_HA_EVENT_PKG.GET_PREDICATE_CLAUSE(L_PK_COLS,P_PK_VALUE);
  BEGIN
    EXECUTE IMMEDIATE L_SEL_STMT INTO L_ACTION;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    L_ACTION := 'NODATAFOUND';
  END ;

  IF L_ACTION ='NODATAFOUND' THEN
    FOR j IN 2..P_COL_NAME_LIST.COUNT
    LOOP
       IF(P_COL_NAME_LIST(j) IS NOT NULL AND P_COL_VALUE_LIST(j) IS NOT NULL) THEN
         l_stmt := l_stmt||','||P_COL_NAME_LIST(j);
       END IF;
      END LOOP;

    l_stmt:= l_stmt||') VALUES('''||P_COL_VALUE_LIST(1)||'''';

    FOR j IN 2..P_COL_VALUE_LIST.COUNT
    LOOP
      IF(P_COL_NAME_LIST(j) IS NOT NULL AND  P_COL_VALUE_LIST(j) IS NOT NULL) THEN
        l_stmt := l_stmt||','''||P_COL_VALUE_LIST(j)||'''';
      END IF;
      END LOOP;

    L_STMT:= L_STMT||')';

      EXECUTE IMMEDIATE L_STMT;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    x_ERROR_MESSAGE := 'Insertion Successful';
  ELSE

    PROCESS_DIRECT_UPDATE(P_TABLE_NAME,P_PK_VALUE,P_COL_NAME_LIST ,P_COL_VALUE_LIST, X_RETURN_STATUS ,X_ERROR_MESSAGE);
    X_RETURN_STATUS := X_RETURN_STATUS;
    x_ERROR_MESSAGE := X_ERROR_MESSAGE;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in PROCESS_DIRECT_INSERT:'||  SUBSTR(SQLERRM,1,3000),
    'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_INSERT',  FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'PROCESS_DIRECT_INSERT failed with error:' || SUBSTR(SQLERRM,1,3000) ;
  RAISE;
END PROCESS_DIRECT_INSERT;
--Public Api
PROCEDURE PROCESS_DIRECT_DML(p_PAYLOAD_ID IN NUMBER
                            ,x_RETURN_STATUS OUT NOCOPY VARCHAR2
                            ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
  l_COL_NAME_LIST  CSM_VARCHAR_LIST;
  l_COL_VALUE_LIST CSM_VARCHAR_LIST;
  l_CON_NAME_LIST  CSM_VARCHAR_LIST;
  l_CON_VALUE_LIST CSM_VARCHAR_LIST;

  CURSOR c_details
  IS
   SELECT OBJECT_NAME,PK_VALUE,DML_TYPE,MOBILE_DATA,PROCESSED,STATUS
   FROM CSM_HA_PAYLOAD_DATA
   WHERE HA_PAYLOAD_ID=p_PAYLOAD_ID;

  l_tab_name VARCHAR2(255);
  l_pk_value VARCHAR2(1000);
  l_dml VARCHAR2(1);
  l_mobile VARCHAR2(1);
  l_proc VARCHAR2(1);
  L_PK_COLS VARCHAR2(300);
  l_status VARCHAR2(300);
BEGIN

   OPEN C_DETAILS;
   FETCH c_details INTO l_tab_name,l_pk_value,l_dml,l_mobile,l_proc,l_status;
   CLOSE C_DETAILS;

   IF l_proc='Y' and l_status ='SUCCESS' THEN
     CSM_UTIL_PKG.log
       ( 'Leaving PROCESS_DIRECT_DML as the PAYLOAD with Id:'||p_PAYLOAD_ID||' is already processed.'
	     , 'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML', FND_LOG.LEVEL_STATEMENT);

     RETURN;
   END IF;

   CSM_HA_PROCESS_PKG.PARSE_XML(p_HA_PAYLOAD_ID =>p_PAYLOAD_ID,
                        x_COL_NAME_LIST  => l_COL_NAME_LIST,
                        x_COL_VALUE_LIST => l_COL_VALUE_LIST,
                        x_CON_NAME_LIST  => l_CON_NAME_LIST,
                        x_CON_VALUE_LIST => l_CON_VALUE_LIST,
                        x_RETURN_STATUS  => x_RETURN_STATUS,
                        X_ERROR_MESSAGE  => X_ERROR_MESSAGE);
   IF x_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE_APPLICATION_ERROR(-20222,'CSM_HA_PROCESS_PKG.PARSE_XML-'||x_ERROR_MESSAGE);
   END IF;

    IF SUBSTR(l_tab_name,-4)='_INQ' THEN
     FOR j in 1..l_COL_NAME_LIST.count
      Loop
      l_COL_NAME_LIST(j):=replace(l_COL_NAME_LIST(j),'_x0024__x0024_','$$');
      End Loop;
    END IF;

   IF L_DML = 'I' OR l_dml = 'U' THEN

     PROCESS_DIRECT_INSERT(L_TAB_NAME,L_PK_VALUE,L_COL_NAME_LIST ,L_COL_VALUE_LIST, X_RETURN_STATUS ,X_ERROR_MESSAGE);
   --ELSIF l_dml = 'U' THEN
   --  PROCESS_DIRECT_UPDATE(l_tab_name,l_pk_value,l_COL_NAME_LIST ,l_COL_VALUE_LIST, x_RETURN_STATUS ,x_ERROR_MESSAGE);
   ELSE   --l_dml='D'
     l_pk_cols:=CSM_HA_EVENT_PKG.get_pk_column_name(l_tab_name);
     IF	l_pk_cols IS NULL THEN
      RAISE_APPLICATION_ERROR(-20222,'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML- NO PK COLUMN FOUND');
     END IF;
     EXECUTE IMMEDIATE 'DELETE FROM '||l_tab_name||CSM_HA_EVENT_PKG.get_predicate_clause(l_pk_cols,l_pk_value);
   END IF;

EXCEPTION
 WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in PROCESS_DIRECT_DML:'||SUBSTR(SQLERRM,1,3000),
    'CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := 'PROCESS_DIRECT_DML failed with error:' || SUBSTR(SQLERRM,1,3000) ;
  RAISE;
END PROCESS_DIRECT_DML;

PROCEDURE SET_HA_PROFILE(P_VALUE IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
X BOOLEAN;
BEGIN

CSM_UTIL_PKG.LOG('Setting HA Profile to value :'||p_value,
                    'CSM_HA_EVENT_PKG.SET_HA_PROFILE', FND_LOG.LEVEL_PROCEDURE);

X:=FND_PROFILE.SAVE('CSM_HA_MODE',P_VALUE,'SITE');
COMMIT;
END SET_HA_PROFILE;
--Function to convert clob to blob
FUNCTION CLOB_TO_BLOB( p_clob_data IN CLOB ) RETURN BLOB
IS
  POS PLS_INTEGER := 1;
  BUFFER RAW( 32767 );
  RES BLOB;
  lob_len PLS_INTEGER := DBMS_LOB.getLength( p_clob_data );

BEGIN
  DBMS_LOB.CREATETEMPORARY( RES, TRUE );
  DBMS_LOB.OPEN( res, DBMS_LOB.LOB_ReadWrite );


  LOOP
    BUFFER := UTL_RAW.CONCAT(DBMS_LOB.SUBSTR(P_CLOB_DATA,8000,POS));

    IF UTL_RAW.LENGTH( BUFFER ) > 0 THEN
      DBMS_LOB.WRITEAPPEND( RES, UTL_RAW.LENGTH( BUFFER ), BUFFER );
    END IF;

    POS := POS + 8000;
    EXIT WHEN POS > LOB_LEN;
  END LOOP;

  RETURN RES;
END CLOB_TO_BLOB;

END CSM_HA_PROCESS_PKG;

/
