--------------------------------------------------------
--  DDL for Package Body CSM_UNDO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_UNDO_PKG" AS
/* $Header: csmucudb.pls 120.0.12010000.3 2009/09/02 07:28:59 saradhak noship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_UNDO_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_CLIENT_UNDO_REQUEST';
g_debug_level           NUMBER; -- debug level

/* Select all inq records */
CURSOR c_client_undo( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSM_CLIENT_UNDO_REQUEST_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;
/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_UNDO
         (
           p_record           IN c_client_undo%ROWTYPE,
           p_error_msg        OUT NOCOPY    VARCHAR2,
           x_return_status    IN  OUT NOCOPY VARCHAR2
         )
IS


/*CURSOR c_get_undo_inq ( c_user_name VARCHAR2, c_tranid NUMBER,c_pk1_value NUMBER)
IS
SELECT SEQNO$$
FROM  CSM_CLIENT_UNDO_REQUEST_INQ
WHERE tranid$$  = c_tranid
AND   clid$$cs  = c_user_name
AND   PK1_VALUE = c_pk1_value;
*/
CURSOR c_get_ta_from_inq(c_task_assignment_id NUMBER, c_user_name VARCHAR2)
IS
SELECT INQ.TASK_ASSIGNMENT_ID,INQ.TRANID$$,INQ.SEQNO$$,DMLTYPE$$, TASK_ID
FROM   CSM_TASK_ASSIGNMENTS_INQ INQ
WHERE  INQ.TASK_ASSIGNMENT_ID = c_task_assignment_id
AND    INQ.CLID$$CS           = c_user_name;

CURSOR c_get_ta_from_acc(c_task_assignment_id NUMBER,c_user_id NUMBER)
IS
SELECT ACCESS_ID
FROM   CSM_TASK_ASSIGNMENTS_ACC acc
WHERE  ACC.USER_ID            = c_user_id
AND    ACC.TASK_ASSIGNMENT_ID = c_task_assignment_id;

CURSOR c_get_ta_from_base(c_task_assignment_id NUMBER)
IS
SELECT TASK_ID
FROM   JTF_TASK_ASSIGNMENTS b
WHERE  B.TASK_ASSIGNMENT_ID = c_task_assignment_id;

CURSOR c_get_taa_from_inq(c_task_assignment_id NUMBER, c_user_name VARCHAR2)
IS
SELECT INQ.ASSIGNMENT_AUDIT_ID,INQ.TRANID$$,INQ.SEQNO$$,INQ.DMLTYPE$$
FROM   CSM_TASK_ASSIGNMENTS_AUDIT_INQ INQ
WHERE  INQ.ASSIGNMENT_ID = c_task_assignment_id
AND    INQ.CLID$$CS           = c_user_name;

CURSOR c_get_task_from_inq(c_task_id NUMBER,c_user_name VARCHAR2)
IS
SELECT INQ.TRANID$$,INQ.SEQNO$$,DMLTYPE$$,SOURCE_OBJECT_TYPE_CODE,SOURCE_OBJECT_ID
FROM   CSM_TASKS_INQ inq
WHERE  inq.TASK_ID  = c_task_id
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_task_from_acc(c_task_id NUMBER,c_user_id NUMBER)
IS
SELECT ACCESS_ID
FROM   CSM_TASKS_ACC acc
WHERE  acc.TASK_ID  = c_task_id
AND    acc.USER_ID  = c_user_id;

CURSOR c_get_task_from_base(c_task_id NUMBER)
IS
SELECT SOURCE_OBJECT_TYPE_CODE,SOURCE_OBJECT_ID
FROM   JTF_TASKS_B b
WHERE  b.TASK_ID  = c_task_id;

CURSOR c_get_incident_from_inq(c_incident_id NUMBER,c_user_name VARCHAR2)
IS
SELECT INQ.TRANID$$,INQ.SEQNO$$,DMLTYPE$$
FROM   CSM_INCIDENTS_ALL_INQ inq
WHERE  inq.INCIDENT_ID = c_incident_id
AND    inq.CLID$$CS    = c_user_name;

CURSOR c_get_incident_from_acc(c_incident_id NUMBER,c_user_id NUMBER)
IS
SELECT ACCESS_ID
FROM   CSM_INCIDENTS_ALL_ACC acc
WHERE  acc.USER_ID     = c_user_id
AND    acc.INCIDENT_ID = c_incident_id;

CURSOR c_get_debrief_header(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_HEADER_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_HEADERS_ACC acc,
       CSM_DEBRIEF_HEADERS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_HEADER_ID = acc.DEBRIEF_HEADER_ID(+)
AND    inq.CLID$$CS = c_user_name;


CURSOR c_get_debrief_expenses(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_EXPENSES_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID     = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_debrief_labor(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_LABOR_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_debrief_parts(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_PARTS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_req_header(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.REQUIREMENT_HEADER_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_REQ_HEADERS_ACC acc,
       CSM_REQ_HEADERS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID    = c_task_assg_id
AND    inq.REQUIREMENT_HEADER_ID = acc.REQUIREMENT_HEADER_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_req_line(c_req_header_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.REQUIREMENT_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_REQ_LINES_ACC acc,
       CSM_REQ_LINES_INQ inq
WHERE  acc.USER_ID (+)    = c_user_id
AND    inq.REQUIREMENT_HEADER_ID = c_req_header_id
AND    inq.REQUIREMENT_LINE_ID   = acc.REQUIREMENT_LINE_ID (+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_notes(c_task_id NUMBER,c_incident_id NUMBER,c_debrief_header_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.JTF_NOTE_ID,INQ.TRANID$$,INQ.SEQNO$$, INQ.DMLTYPE$$
FROM   CSM_NOTES_ACC acc,
       CSF_M_NOTES_INQ inq
WHERE  acc.USER_ID (+)     = c_user_id
AND    inq.JTF_NOTE_ID = acc.JTF_NOTE_ID (+)
AND    inq.CLID$$CS    = c_user_name
AND (
    ( inq.SOURCE_OBJECT_CODE = 'TASK' AND inq.SOURCE_OBJECT_ID = c_task_id )
OR  ( inq.SOURCE_OBJECT_CODE = 'SR' AND inq.SOURCE_OBJECT_ID = c_incident_id)
OR  ( inq.SOURCE_OBJECT_CODE = 'SD' AND inq.SOURCE_OBJECT_ID = c_debrief_header_id)
   );

CURSOR c_get_lobs(c_task_id NUMBER,c_incident_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.FILE_ID,INQ.TRANID$$,INQ.SEQNO$$, INQ.DMLTYPE$$
FROM   CSM_FND_LOBS_ACC acc,
       CSF_M_LOBS_INQ inq
WHERE  acc.USER_ID (+)  = c_user_id
AND    inq.FILE_ID      = acc.FILE_ID (+)
AND    inq.CLID$$CS     = c_user_name
AND (
    ( inq.ENTITY_NAME = 'JTF_TASKS_B' AND inq.PK1_VALUE = c_task_id )
OR  ( inq.ENTITY_NAME = 'CS_INCIDENTS' AND inq.PK1_VALUE = c_incident_id)
   );

 CURSOR c_get_user_id (c_user_name VARCHAR2)
 IS
 SELECT USER_ID
 FROM   ASG_USER
 WHERE  USER_NAME = c_user_name;

--Pub items and object declarations


l_ta_obj_name VARCHAR2(30) := 'CSM_TASK_ASSIGNMENT_PKG';  -- package name
l_ta_pub_name VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS';

l_taa_obj_name VARCHAR2(30) := 'CSM_TA_AUDIT_PKG';  -- package name
l_taa_pub_name VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS_AUDIT';

l_task_obj_name VARCHAR2(30) := 'CSM_TASKS_PKG';  -- package name
l_task_pub_name VARCHAR2(30) := 'CSM_TASKS';

l_sr_obj_name VARCHAR2(30) := 'CSM_SERVICE_REQUEST_PKG';
l_sr_pub_name VARCHAR2(30) := 'CSM_INCIDENTS_ALL';

l_dbh_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS_PKG';
l_dbh_pub_name VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS';

l_dble_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_EXPENSES_PKG';
l_dble_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_EXPENSES';

l_dbll_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_LABOR_PKG';
l_dbll_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_LABOR';

l_dblp_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_PARTS_PKG';
l_dblp_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_PARTS';

l_notes_obj_name VARCHAR2(30)  := 'CSM_NOTES_PKG';
l_notes_pub_name VARCHAR2(30)  := 'CSF_M_NOTES';

l_reqh_obj_name VARCHAR2(30) := 'CSM_REQUIREMENTS_PKG';
l_reqh_pub_name VARCHAR2(30) := 'CSM_REQ_HEADERS';

l_reql_obj_name VARCHAR2(30) := 'CSM_REQUIREMENTS_PKG';
l_reql_pub_name VARCHAR2(30) := 'CSM_REQ_LINES';

l_lobs_obj_name VARCHAR2(30) := 'CSM_LOBS_PKG';
l_lobs_pub_name VARCHAR2(30) := 'CSF_M_LOBS';

l_undo_pub_name VARCHAR2(30) := 'CSM_CLIENT_UNDO_REQUEST';

l_access_id     NUMBER;
l_mark_dirty	  BOOLEAN;
l_incident_id   NUMBER;
l_debrief_header_id NUMBER;
l_tran_id       NUMBER;
l_user_name     VARCHAR2(100);
l_user_id       NUMBER;
l_task_assignment_id       NUMBER;
l_task_assignment_id_tmp       NUMBER;
l_task_id         NUMBER;
l_debrief_line_id NUMBER;
l_req_header_id   NUMBER;
l_req_line_id     NUMBER;
l_note_id         NUMBER;
l_process_status  VARCHAR2(1);
l_error_msg       VARCHAR2(4000);
l_markdirty_all   VARCHAR2(1):= 'Y';
l_sequence        NUMBER;
l_dml_type        VARCHAR2(1) := '';
l_source_object_type VARCHAR2(240);

type t_curs is ref cursor;
cur t_curs;

r_pub_item_store Varchar2(100);

BEGIN
  --set variables from the record
  l_user_name := p_record.CLID$$CS;
  l_tran_id   := p_record.TRANID$$;
  l_sequence  := p_record.SEQNO$$;
  l_task_assignment_id := p_record.PK1_VALUE;

  l_error_msg := 'Deferring Record As UNDO Called For';

  OPEN  c_get_user_id(l_user_name);
  FETCH c_get_user_id INTO l_user_id;
  CLOSE c_get_user_id;

  IF l_user_id Is NULL OR l_user_name IS NULL THEN
      CSM_UTIL_PKG.log( g_object_name || '.APPLY_UNDO:'
      || ' Task Assignment ID :' || l_task_assignment_id
      || 'UNDO Failed.User Invalid',
      g_object_name || '.APPLY_UNDO',FND_LOG.LEVEL_ERROR );
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;


  --Check Task Assignment ID
  OPEN  c_get_ta_from_inq (l_task_assignment_id ,l_user_name );
  FETCH c_get_ta_from_inq INTO l_task_assignment_id_tmp,l_tran_id,l_sequence,l_dml_type,l_task_id;
  CLOSE c_get_ta_from_inq;

  IF l_dml_type = 'U' THEN
    OPEN  c_get_ta_from_acc (l_task_assignment_id ,l_user_id );
    FETCH c_get_ta_from_acc INTO l_access_id;
    CLOSE c_get_ta_from_acc;
    --Check if the task assignment has been changed to another user before this UNDO
    IF l_access_id IS NULL THEN
        l_markdirty_all := 'N';
        CSM_UTIL_PKG.log( g_object_name || '.APPLY_UNDO:'
        || ' Task Assignment ID :' || l_task_assignment_id
        || 'is no longer assigned to the user. UNDO Failed',
        g_object_name || '.APPLY_UNDO',FND_LOG.LEVEL_ERROR );
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      --Task Assignment Markdirty
      l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => 'CSM_TASK_ASSIGNMENTS',
                                             p_accessid    => l_access_id,
                                             p_userid      => l_user_id,
                                             p_dml         => asg_download.upd,
                                             p_timestamp   => sysdate);

    END IF;
    CSM_UTIL_PKG.REJECT_RECORD
   ( l_user_name
   , l_tran_id
   , l_sequence
   , l_task_assignment_id
   , l_ta_obj_name
   , l_ta_pub_name
   , l_error_msg
   , l_process_status
   );
  ELSIF l_dml_type = 'I' THEN --insert
    --Reject the Insert record
      CSM_UTIL_PKG.REJECT_RECORD
     ( l_user_name
     , l_tran_id
     , l_sequence
     , l_task_assignment_id
     , l_ta_obj_name
     , l_ta_pub_name
     , l_error_msg
     , l_process_status
     );
  ELSIF l_dml_type IS NULL THEN

    OPEN  c_get_ta_from_base (l_task_assignment_id );
    FETCH c_get_ta_from_base INTO l_task_id;
    CLOSE c_get_ta_from_base;
  END IF;


  OPEN cur FOR 'select DISTINCT STORE from '||asg_base.G_OLITE_SCHEMA||'.c$inq c_inq
                       WHERE CLID$$CS ='''||l_user_name||''' AND   TRANID$$ = '||l_tran_id
                       ||' AND EXISTS(SELECT 1 FROM ASG_PUB_ITEM WHERE ITEM_ID = c_inq.STORE) ' ;
  LOOP
    FETCH cur INTO r_pub_item_store;
    EXIT WHEN cur%NOTFOUND;

    IF r_pub_item_store = l_taa_pub_name AND l_task_assignment_id IS NOT NULL THEN
      --Task Assignment Audit Markdirty
      FOR r_get_taa_from_inq IN c_get_taa_from_inq(l_task_assignment_id, l_user_name) LOOP
        IF r_get_taa_from_inq.ASSIGNMENT_AUDIT_ID IS NOT NULL THEN
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_taa_from_inq.TRANID$$
             , r_get_taa_from_inq.SEQNO$$
             , r_get_taa_from_inq.ASSIGNMENT_AUDIT_ID
             , l_taa_obj_name
             , l_taa_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
     END LOOP;
    ELSIF r_pub_item_store = l_task_pub_name AND l_task_id IS NOT NULL THEN
      l_access_id := NULL;
      l_tran_id   := NULL;
      l_sequence  := NULL;
      l_source_object_type := NULL;
      l_dml_type  := NULL;
      --Task Markdirty
      OPEN  c_get_task_from_inq(l_task_id , l_user_name);
      FETCH c_get_task_from_inq INTO l_tran_id,l_sequence,l_dml_type,l_source_object_type,l_incident_id;
      CLOSE c_get_task_from_inq;
      IF l_dml_type = 'U' THEN
        OPEN  c_get_task_from_acc (l_task_id ,l_user_id );
        FETCH c_get_task_from_acc INTO l_access_id;
        CLOSE c_get_task_from_acc;
        --Check if the task assignment has been changed to another user before this UNDO
        IF l_markdirty_all = 'Y' AND l_access_id IS NOT NULL THEN
          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_task_pub_name,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => l_user_id,
                                                   p_dml         => asg_download.upd,
                                                   p_timestamp   => sysdate);
        END IF;          --Task  Markdirty
        CSM_UTIL_PKG.REJECT_RECORD
       ( l_user_name
       , l_tran_id
       , l_sequence
       , l_task_id
       , l_task_obj_name
       , l_task_pub_name
       , l_error_msg
       , l_process_status
       );
      ELSIF l_dml_type = 'I' THEN --insert
        --Reject the Insert record
        CSM_UTIL_PKG.REJECT_RECORD
       ( l_user_name
       , l_tran_id
       , l_sequence
       , l_task_id
       , l_task_obj_name
       , l_task_pub_name
       , l_error_msg
       , l_process_status
       );
      ELSIF l_dml_type IS NULL THEN

        OPEN  c_get_task_from_base (l_task_id );
        FETCH c_get_task_from_base INTO l_source_object_type,l_incident_id;
        CLOSE c_get_task_from_base;
      END IF;

    ELSIF r_pub_item_store =l_sr_pub_name AND l_source_object_type = 'SR' AND l_incident_id IS NOT NULL THEN --Process incidents
      l_access_id := NULL;
      l_tran_id   := NULL;
      l_sequence  := NULL;
      l_dml_type  := NULL;
      --Incident Markdirty
      OPEN  c_get_incident_from_inq(l_incident_id,l_user_name);
      FETCH c_get_incident_from_inq INTO l_tran_id,l_sequence,l_dml_type;
      CLOSE c_get_incident_from_inq;
      IF l_dml_type = 'U' THEN
        OPEN  c_get_incident_from_acc (l_incident_id ,l_user_id );
        FETCH c_get_incident_from_acc INTO l_access_id;
        CLOSE c_get_incident_from_acc;

        IF l_markdirty_all = 'Y' AND l_access_id IS NOT NULL THEN
          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_sr_pub_name,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => l_user_id,
                                                   p_dml         => asg_download.upd,
                                                   p_timestamp   => sysdate);
        END IF;
          --Reject the record as it not needed for upload anymore
          CSM_UTIL_PKG.REJECT_RECORD
         ( l_user_name
         , l_tran_id
         , l_sequence
         , l_incident_id
         , l_sr_obj_name
         , l_sr_pub_name
         , l_error_msg
         , l_process_status
         );
      ELSIF l_dml_type = 'I' THEN --insert
        --Reject the Insert record
          CSM_UTIL_PKG.REJECT_RECORD
         ( l_user_name
         , l_tran_id
         , l_sequence
         , l_incident_id
         , l_sr_obj_name
         , l_sr_pub_name
         , l_error_msg
         , l_process_status
         );

      END IF;
    ELSIF r_pub_item_store =l_dbh_pub_name  AND l_task_assignment_id IS NOT NULL  THEN
      l_access_id := NULL;
      l_tran_id   := NULL;
      l_sequence  := NULL;

      --Debrief Header Markdirty
      OPEN  c_get_debrief_header(l_task_assignment_id , l_user_id,l_user_name);
      FETCH c_get_debrief_header INTO l_access_id,l_debrief_header_id,l_tran_id,l_sequence;
      CLOSE c_get_debrief_header;
      IF l_debrief_header_id IS NOT NULL THEN
        IF l_markdirty_all = 'Y' AND l_access_id IS NOT NULL THEN
          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_dbh_pub_name,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => l_user_id,
                                                   p_dml         => asg_download.upd,
                                                   p_timestamp   => sysdate);
        END IF;
          --Reject the record as it not needed for upload anymore
            CSM_UTIL_PKG.REJECT_RECORD
           ( l_user_name
           , l_tran_id
           , l_sequence
           , l_debrief_header_id
           , l_dbh_obj_name
           , l_dbh_pub_name
           , l_error_msg
           , l_process_status
           );

      END IF;
    ELSIF r_pub_item_store =l_dble_pub_name AND l_task_assignment_id IS NOT NULL THEN
      --Debrief Expense Markdirty
      FOR r_get_debrief_expenses IN c_get_debrief_expenses(l_task_assignment_id, l_user_id,l_user_name) LOOP
        IF r_get_debrief_expenses.DEBRIEF_LINE_ID IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_debrief_expenses.ACCESS_ID IS NOT NULL THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_dble_pub_name,
                                                     p_accessid    => r_get_debrief_expenses.ACCESS_ID,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_debrief_expenses.TRANID$$
             , r_get_debrief_expenses.SEQNO$$
             , r_get_debrief_expenses.DEBRIEF_LINE_ID
             , l_dble_obj_name
             , l_dble_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
     END LOOP;
    ELSIF r_pub_item_store =l_dbll_pub_name AND l_task_assignment_id IS NOT NULL  THEN
      --Debrief Labor Markdirty
      FOR r_get_debrief_labor IN c_get_debrief_labor(l_task_assignment_id, l_user_id,l_user_name) LOOP
        IF r_get_debrief_labor.DEBRIEF_LINE_ID IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_debrief_labor.ACCESS_ID IS NOT NULL  THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_dbll_pub_name,
                                                     p_accessid    => r_get_debrief_labor.ACCESS_ID,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_debrief_labor.TRANID$$
             , r_get_debrief_labor.SEQNO$$
             , r_get_debrief_labor.DEBRIEF_LINE_ID
             , l_dbll_obj_name
             , l_dbll_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
      END LOOP;
    ELSIF r_pub_item_store =l_dblp_pub_name AND l_task_assignment_id IS NOT NULL  THEN
      --Debrief Parts Markdirty
      FOR r_get_debrief_parts IN c_get_debrief_parts(l_task_assignment_id, l_user_id,l_user_name) LOOP
        IF r_get_debrief_parts.DEBRIEF_LINE_ID IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_debrief_parts.ACCESS_ID IS NOT NULL  THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_dblp_pub_name,
                                                     p_accessid    => r_get_debrief_parts.ACCESS_ID,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_debrief_parts.TRANID$$
             , r_get_debrief_parts.SEQNO$$
             , r_get_debrief_parts.DEBRIEF_LINE_ID
             , l_dblp_obj_name
             , l_dblp_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
      END LOOP;
    ELSIF r_pub_item_store =l_reqh_pub_name AND l_task_assignment_id IS NOT NULL  THEN
      --Debrief Requirement Header Markdirty
      l_access_id := NULL;
      l_tran_id   := NULL;
      l_sequence  := NULL;

      OPEN  c_get_req_header(l_task_assignment_id , l_user_id, l_user_name);
      FETCH c_get_req_header INTO l_access_id,l_req_header_id,l_tran_id,l_sequence;
      CLOSE c_get_req_header;
      IF l_req_header_id IS NOT NULL THEN
        IF l_markdirty_all = 'Y' AND l_access_id IS NOT NULL THEN
          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_reqh_pub_name,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => l_user_id,
                                                   p_dml         => asg_download.upd,
                                                   p_timestamp   => sysdate);
        END IF;
          --Reject the record as it not needed for upload anymore
            CSM_UTIL_PKG.REJECT_RECORD
           ( l_user_name
           , l_tran_id
           , l_sequence
           , l_req_header_id
           , l_reqh_obj_name
           , l_reqh_pub_name
           , l_error_msg
           , l_process_status
           );

      END IF;
    ELSIF r_pub_item_store =l_reql_pub_name AND l_req_header_id IS NOT NULL  THEN
      --Debrief Requriement line  Markdirty
      FOR r_get_req_line IN c_get_req_line(l_req_header_id , l_user_id,l_user_name) LOOP
        IF r_get_req_line.requirement_line_id IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_req_line.ACCESS_ID IS NOT NULL THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_reql_pub_name,
                                                     p_accessid    => r_get_req_line.ACCESS_ID,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_req_line.TRANID$$
             , r_get_req_line.SEQNO$$
             , r_get_req_line.requirement_line_id
             , l_reql_obj_name
             , l_reql_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
      END LOOP;
    ELSIF r_pub_item_store =l_notes_pub_name THEN
      --Notes Markdirty
      FOR r_get_notes IN c_get_notes(l_task_id, l_incident_id, l_debrief_header_id, l_user_id,l_user_name) LOOP
        IF r_get_notes.jtf_note_id IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_notes.access_id IS NOT NULL THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_notes_pub_name,
                                                     p_accessid    => r_get_notes.access_id,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_notes.TRANID$$
             , r_get_notes.SEQNO$$
             , r_get_notes.jtf_note_id
             , l_notes_obj_name
             , l_notes_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
      END LOOP;
    ELSIF r_pub_item_store =l_lobs_pub_name THEN
      --Notes Markdirty
      FOR r_get_lobs IN c_get_lobs(l_task_id, l_incident_id, l_user_id,l_user_name) LOOP
        IF r_get_lobs.file_id IS NOT NULL THEN
          IF l_markdirty_all = 'Y' AND r_get_lobs.access_id IS NOT NULL THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => l_lobs_pub_name,
                                                     p_accessid    => r_get_lobs.access_id,
                                                     p_userid      => l_user_id,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);
          END IF;
            --Reject the record as it not needed for upload anymore
              CSM_UTIL_PKG.REJECT_RECORD
             ( l_user_name
             , r_get_lobs.TRANID$$
             , r_get_lobs.SEQNO$$
             , r_get_lobs.FILE_ID
             , l_lobs_obj_name
             , l_lobs_pub_name
             , l_error_msg
             , l_process_status
             );

        END IF;
      END LOOP;

    END IF;--Pub item
  END LOOP;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UNDO:' ||g_object_name || '.APPLY_UNDO',
       FND_LOG.LEVEL_EXCEPTION );
    x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UNDO;



/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_client_undo%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_UNDO_PKG.APPLY_RECORD for PK1 Value ' || p_record.PK1_VALUE ,
                         'CSM_UNDO_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_UNDO
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE --Delete and update is not supported for this PI
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Undo Request ID ' || p_record.PK1_VALUE ,'CSM_UNDO_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_UNDO_PKG.APPLY_RECORD for Undo Request ID ' || p_record.PK1_VALUE ,
                         'CSM_UNDO_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || sqlerrm
               || ' for Undo Request ID ' || p_record.PK1_VALUE ,'CSM_UNDO_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_CLIENT_UNDO_REQUEST
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN out nocopy VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

BEGIN
CSM_UTIL_PKG.LOG('Entering CSM_UNDO_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue ***/
  FOR r_client_undo_rec IN c_client_undo( p_user_name, p_tranid) LOOP
    --SAVEPOINT save_rec ;
    /*** apply record ***/
    APPLY_RECORD
      (
        r_client_undo_rec
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> Reject record from inqueue ***/
      CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_client_undo_rec.seqno$$,
          r_client_undo_rec.REQUEST_ID,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Reject record failed,  rolling back to savepoint'
          || ' for PK ' || r_client_undo_rec.REQUEST_ID ,'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_client_undo_rec.REQUEST_ID ,'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.REJECT_RECORD
       (
         p_user_name
       , p_tranid
       , r_client_undo_rec.seqno$$
       , r_client_undo_rec.REQUEST_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Reject record failed, No rolling back to savepoint'
          || ' for PK ' || r_client_undo_rec.REQUEST_ID ,'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_UNDO_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;


END CSM_UNDO_PKG;

/
