--------------------------------------------------------
--  DDL for Package Body CSM_QUERY_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_QUERY_INSTANCE_PKG" AS
/* $Header: csmuqib.pls 120.5.12010000.8 2009/10/12 08:03:02 trajasek noship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_QUERY_INSTANCE_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_QUERY_INSTANCES';
g_pub_qvv_name     CONSTANT VARCHAR2(30) := 'CSM_QUERY_VARIABLE_VALUES';
g_debug_level           NUMBER; -- debug level
g_seqno_lst    CSM_INTEGER_LIST;
/* Select all inq records */
CURSOR c_query_instances( b_user_name VARCHAR2, b_tranid NUMBER, b_from_sync VARCHAR2) is
  SELECT inq.*
  FROM  CSM_QUERY_INSTANCES_INQ inq,
        CSM_QUERY_B b
  WHERE inq.tranid$$ = b_tranid
  AND   inq.clid$$cs = b_user_name
  AND   inq.QUERY_ID = b.QUERY_ID
  AND   ((b.EXECUTION_MODE = 'SYNCHRONOUS' AND b_from_sync ='Y') OR b_from_sync = 'N');

CURSOR c_query_variable_values( b_user_name VARCHAR2, b_tranid NUMBER, b_instance_id NUMBER) is
  SELECT *
  FROM  CSM_QUERY_VARIABLE_VALUES_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   INSTANCE_ID = b_instance_id;
/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_query_instances%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS

CURSOR c_check_query(c_QUERY_ID NUMBER)
IS
SELECT QUERY_NAME,LEVEL_ID,LEVEL_VALUE, QUERY_TYPE
FROM   CSM_QUERY_B
WHERE  QUERY_ID =c_QUERY_ID
AND    NVL(DELETE_FLAG,'N') = 'N';

CURSOR c_get_variables (c_QUERY_ID NUMBER)
IS
SELECT  vb.VARIABLE_ID,
vb.VARIABLE_VALUE_CHAR,
vb.VARIABLE_VALUE_DATE,
vb.VARIABLE_TYPE
FROM  CSM_QUERY_VARIABLES_B     vb
WHERE vb.QUERY_ID = c_QUERY_ID;

CURSOR c_get_variables_from_inq (c_user_name VARCHAR2,c_tran_id NUMBER,c_QUERY_ID NUMBER, c_instance_id NUMBER)
IS
SELECT  vb.VARIABLE_ID,
vb.VARIABLE_VALUE_CHAR,
vb.VARIABLE_VALUE_DATE,
vb.SEQNO$$
FROM  CSM_QUERY_VARIABLE_VALUES_INQ     vb
WHERE vb.CLID$$CS = c_user_name
AND   vb.TRANID$$ = c_tran_id
AND   vb.QUERY_ID = c_QUERY_ID
AND   vb.INSTANCE_ID = c_instance_id;

CURSOR c_get_next_instance
IS
SELECT CSM_QUERY_INSTANCES_ACC_S.NEXTVAL
FROM DUAL;

CURSOR c_get_user(c_user_name VARCHAR2)
IS
SELECT USER_ID
FROM   ASG_USER
WHERE  USER_NAME =c_user_name;

CURSOR c_get_next_qvariableid
IS
SELECT CSM_QUERY_VARIABLE_VAL_ACC_S.NEXTVAL
FROM DUAL;

--Variable Declarations
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);
 l_variable_id_lst    CSM_INTEGER_LIST;
 l_var_value_char_lst CSM_VARCHAR_LIST;
 l_var_value_date_lst CSM_DATE_LIST;
 l_var_type_lst       CSM_VARCHAR_LIST;
 l_variable_id_inq_lst    CSM_INTEGER_LIST;
 l_var_value_char_inq_lst CSM_VARCHAR_LIST;
 l_var_value_date_inq_lst CSM_DATE_LIST;
 l_query_id         NUMBER;
 l_variable_cnt     NUMBER;
 l_ins_variable_cnt NUMBER;
 l_instance_name    VARCHAR2(255);
 l_instance_id      NUMBER;
 l_access_id        NUMBER;
 l_mark_dirty       BOOLEAN;
 l_dummy_qry_id     NUMBER;
 l_user_id          NUMBER;
 l_qvariable_id     NUMBER;
 l_level_id         NUMBER;
 l_level_value      NUMBER;
 l_responsibility_id NUMBER := NULL;
 l_error_msg        VARCHAR2(4000);
 l_query_type       VARCHAR2(255);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Entering CSM_QUERY_INSTANCE_PKG.APPLY_INSERT for Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  l_query_id := p_record.QUERY_ID;
  --Check if the Query id is valid
  OPEN  c_check_query(l_query_id);
  FETCH c_check_query INTO l_instance_name, l_level_id, l_level_value,l_query_type;
  IF c_check_query%NOTFOUND THEN
    CSM_UTIL_PKG.LOG( 'Invalid Query Id : ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_error_msg     := 'Invalid Query Id : ' || l_query_id ;
    CLOSE c_check_query;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE   c_check_query;

  IF l_level_id = 10003 THEN
    l_responsibility_id := l_level_value;
  END IF;
  IF l_query_type ='SQL' THEN
    --Validate the Access to a Query
    CSM_QUERY_PKG.VALIDATE_ACCESS( p_QUERY_ID         => l_query_id,
                  p_QUERY_TEXT1       => NULL,
                  p_QUERY_TEXT2       => NULL,
                  p_RESPONSIBILITY_ID => l_responsibility_id,
                  x_return_status     => x_return_status,
                  x_error_message     => l_error_msg);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      CSM_UTIL_PKG.LOG
      ( 'Exception occurred in VALIDATE_ACCESS for Query Name ' || l_instance_name ||  SQLERRM, 'INSERT_INSTANCE',
        FND_LOG.LEVEL_EXCEPTION);
      x_return_status := FND_API.G_RET_STS_ERROR;
      p_error_msg := 'Query Access Validation failed : ' || l_error_msg;
      RETURN;
    END IF;
  END IF;

  IF p_record.INSTANCE_NAME IS NOT NULL THEN
    l_instance_name := p_record.INSTANCE_NAME;
  ELSE
    l_instance_name := 'Instance for Query id ' || ' : '|| l_query_id ||' at ' || sysdate;
  END IF;
  --get user_id
  OPEN  c_get_user(p_record.CLID$$CS);
  FETCH c_get_user INTO l_user_id;
  CLOSE c_get_user;
  l_instance_id := p_record.instance_id;

  SAVEPOINT INSERT_QUERY_INSTANCE;

  IF l_instance_id IS NULL THEN
    OPEN  c_get_next_instance;
    FETCH c_get_next_instance INTO l_instance_id;
    CLOSE c_get_next_instance;
  END IF;
  --Insert the Instance
  INSERT INTO  CSM_QUERY_INSTANCES_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , INSTANCE_NAME,STATUS,
            CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
  VALUES     (l_instance_id, l_user_id, l_query_id, l_instance_id,l_instance_name,'OPEN',
             fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id);

  IF csm_util_pkg.is_palm_user(l_user_id) THEN
          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_name,
                                               p_accessid    => l_instance_id, --same as access id
                                               p_userid      => l_user_id,
                                               p_dml         => asg_download.ins,
                                               p_timestamp   => sysdate);
  END IF;

  OPEN  c_get_variables (l_query_id);
  FETCH c_get_variables BULK COLLECT INTO l_variable_id_lst, l_var_value_char_lst, l_var_value_date_lst, l_var_type_lst;
  CLOSE c_get_variables;

  --Query does not have any where condition  so Execute and leave
  IF l_variable_id_lst.COUNT = 0 THEN

  --Execute the Query
    CSM_QUERY_PKG.EXECUTE_QUERY ( p_USER_ID        => l_user_id,
                                  p_QUERY_ID       => l_query_id,
                                  p_INSTANCE_ID    => l_instance_id,
                                  x_return_status  => x_return_status,
                                  x_error_message  => l_error_msg,
                                  p_commit         => fnd_api.G_FALSE,
                                  p_source_module  => 'MFSCLIENT'
                                );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CSM_UTIL_PKG.LOG( 'Query Upload Failed for  : ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    p_error_msg     := 'Query Upload Failed at execution for  Instance id : '
                        || l_instance_id || 'With Message' || l_error_msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO INSERT_QUERY_INSTANCE;
    RETURN;
  END IF;

   CSM_UTIL_PKG.LOG( 'Leaving INSERT_INSTANCE for Query Id  : ' || l_user_id  , FND_LOG.LEVEL_ERROR);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   p_error_msg     := 'Leaving INSERT_INSTANCE for Query Id  : ' || l_user_id ;
   RETURN;

  END IF;

  --Get variablefr from the INQ
  OPEN  c_get_variables_from_inq (p_record.CLID$$CS,p_record.TRANID$$,l_query_id,p_record.instance_id);
  FETCH c_get_variables_from_inq BULK COLLECT INTO l_variable_id_inq_lst, l_var_value_char_inq_lst, l_var_value_date_inq_lst, g_seqno_lst;
  CLOSE c_get_variables_from_inq;

  IF l_variable_id_lst.COUNT <> l_variable_id_inq_lst.COUNT THEN
     CSM_UTIL_PKG.LOG
    ( 'Variable Count mismatch.Leaving INSERT_INSTANCE for Query Id : ' || l_query_id  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_error_msg     := 'Variable Count mismatch.Leaving INSERT_INSTANCE for Query Id  : ' || l_query_id ;
    RETURN;
  END IF;
  --Check if the values send are proper according to the Type
  FOR i in 1..l_variable_id_inq_lst.COUNT LOOP
    IF UPPER(l_var_type_lst(i)) = 'DATE' THEN
        IF l_var_value_date_inq_lst(i) IS NULL THEN
          CSM_UTIL_PKG.LOG
          ( 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id : ' || l_query_id  ,
            FND_LOG.LEVEL_ERROR);
          x_return_status := FND_API.G_RET_STS_ERROR;
          p_error_msg     := 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id  : ' || l_query_id ;
          RETURN;
        END IF;
    ELSE

        IF l_var_value_char_inq_lst(i) IS NULL THEN
          CSM_UTIL_PKG.LOG
          ( 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id : ' || l_query_id  ,
            FND_LOG.LEVEL_ERROR);
          x_return_status := FND_API.G_RET_STS_ERROR;
          p_error_msg     := 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id  : ' || l_query_id ;
          RETURN;
        END IF;
    END IF;

  END LOOP;

  --Insert into variable values table
  FOR i in 1..l_variable_id_inq_lst.COUNT LOOP

    OPEN  c_get_next_qvariableid;
    FETCH c_get_next_qvariableid INTO l_qvariable_id;
    CLOSE c_get_next_qvariableid;

    INSERT INTO  CSM_QUERY_VARIABLE_VALUES_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,
              INSTANCE_ID , VARIABLE_ID,VARIABLE_VALUE_CHAR,VARIABLE_VALUE_DATE,
              CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,GEN_PK)
    VALUES     (l_qvariable_id, l_user_id, l_query_id,
                l_instance_id,  i, l_var_value_char_inq_lst(i), l_var_value_date_inq_lst(i),
               l_user_id, SYSDATE, l_user_id, SYSDATE, l_user_id,l_qvariable_id)
    RETURNING ACCESS_ID into l_access_id;

    IF csm_util_pkg.is_palm_user(l_user_id) THEN
            l_mark_dirty := asg_Download.mark_dirty(p_pub_item => g_pub_qvv_name,
                                                 p_accessid    => l_access_id,
                                                 p_userid      => l_user_id,
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => sysdate);
    END IF;
  END LOOP;

  --Execute the Query
    CSM_QUERY_PKG.EXECUTE_QUERY ( p_USER_ID        => l_user_id,
                                  p_QUERY_ID       => l_query_id,
                                  p_INSTANCE_ID    => l_instance_id,
                                  x_return_status  => x_return_status,
                                  x_error_message  => l_error_msg,
                                  p_commit         => fnd_api.G_FALSE,
                                  p_source_module  => 'MFSCLIENT'
                                );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CSM_UTIL_PKG.LOG( 'Query Upload Failed for  : ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    p_error_msg     := 'Query Upload Failed at execution for  Instance id : '
                        || l_instance_id || ' With Message ' || l_error_msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO INSERT_QUERY_INSTANCE;
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_INSTANCE_PKG.APPLY_INSERT for Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg     := 'Upload Successful for the Instance Id  : ' || l_instance_id ;
  RETURN;

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT: ' || sqlerrm
               || ' for Instance ID ' || p_record.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);
  p_error_msg     := 'Exception in APPLY_INSERT for Instance Id  : ' || l_instance_id || substr(SQLERRM, 1,2000);
  x_return_status := FND_API.G_RET_STS_ERROR;
  ROLLBACK TO INSERT_QUERY_INSTANCE;
END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an Delete  is to be processed.
***/
PROCEDURE APPLY_DELETE
         (
           p_record        IN c_query_instances%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         )
IS
CURSOR c_get_user(c_user_name VARCHAR2)
IS
SELECT USER_ID
FROM   ASG_USER
WHERE  USER_NAME =c_user_name;

--Variable Declarations
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);
 l_query_id         NUMBER;
 l_instance_id      NUMBER;
 l_user_id          NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Entering CSM_QUERY_INSTANCE_PKG.APPLY_DELETE for Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_DELETE',FND_LOG.LEVEL_PROCEDURE);
  l_query_id := p_record.QUERY_ID;
  l_instance_id := p_record.instance_id;
  --get user_id
  OPEN  c_get_user(p_record.CLID$$CS);
  FETCH c_get_user INTO l_user_id;
  CLOSE c_get_user;
  --Calling Query instance Delete
  CSM_QUERY_PKG.DELETE_INSTANCE
    ( p_USER_ID        => l_user_id,
      p_QUERY_ID       => l_query_id,
      p_INSTANCE_ID    => l_instance_id,
      p_commit         => fnd_api.G_FALSE,
      x_return_status  => x_return_status,
      x_error_message  => p_error_msg)  ;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CSM_UTIL_PKG.LOG( 'Query Instance Delete Failed for  : ' || l_instance_id  ,FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_INSTANCE_PKG.APPLY_DELETE for Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_DELETE',FND_LOG.LEVEL_PROCEDURE);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg     := 'Delete Successful for the Instance Id  : ' || l_instance_id ;
  RETURN;

EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_DELETE', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT  (p_api_error      => TRUE);
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_DELETE: ' || sqlerrm
               || ' for Instance ID ' || p_record.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_DELETE',FND_LOG.LEVEL_EXCEPTION);
     p_error_msg     := 'Exception in APPLY_DELETE for Instance Id  : ' || l_instance_id || substr(SQLERRM, 1,2000);
     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_DELETE;
/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_query_instances%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_QUERY_INSTANCE_PKG.APPLY_RECORD for Query Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF p_record.dmltype$$='D' THEN
    -- Process Delete
    APPLY_DELETE
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE -- update is not supported for this PI
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Query Instance ID ' || p_record.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_INSTANCE_PKG.APPLY_RECORD for Query Instance ID ' || p_record.INSTANCE_ID ,
                         'CSM_QUERY_INSTANCE_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || sqlerrm
               || ' for Query Instance ID ' || p_record.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_QUERY_INSTANCES
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           p_from_sync     IN VARCHAR2 DEFAULT 'N',
           x_return_status IN out nocopy VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

BEGIN
CSM_UTIL_PKG.LOG('Entering CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue ***/
  FOR r_qi_rec IN c_query_instances( p_user_name, p_tranid, p_from_sync) LOOP
    SAVEPOINT save_rec ;
    /*** apply record ***/
    APPLY_RECORD
      (
        r_qi_rec
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_qi_rec.seqno$$,
          r_qi_rec.INSTANCE_ID,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      /*** was Instance delete successful? ***/
      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        /*** Yes -> delete Variable Values record from inqueue ***/
        FOR r_qvv_rec IN c_query_variable_values( p_user_name, p_tranid, r_qi_rec.INSTANCE_ID) LOOP
          CSM_UTIL_PKG.REJECT_RECORD
            (
              p_user_name,
              p_tranid,
              r_qvv_rec.seqno$$,
              r_qvv_rec.GEN_PK,
              g_object_name,
              g_pub_qvv_name,
              l_error_msg,
              l_process_status
            );
            IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
              EXIT;
            END IF;
        END LOOP;
      END IF;

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
       /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
      || ' for Instance ID ' || r_qi_rec.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF  l_process_Status <> FND_API.G_RET_STS_SUCCESS AND p_from_sync = 'Y' THEN
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_qi_rec.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS AND p_from_sync ='N' THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_qi_rec.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_qi_rec.seqno$$
       , r_qi_rec.INSTANCE_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_qi_rec.dmltype$$
       );

        /*** was Instance defer successful? ***/
        IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
          /*** Yes -> defer Variable Values record from inqueue ***/
          FOR r_qvv_rec IN c_query_variable_values( p_user_name, p_tranid, r_qi_rec.INSTANCE_ID) LOOP
            CSM_UTIL_PKG.DEFER_RECORD
              (
                p_user_name,
                p_tranid,
                r_qvv_rec.seqno$$,
                r_qvv_rec.GEN_PK,
                g_object_name,
                g_pub_qvv_name,
                l_error_msg,
                l_process_status,
                r_qvv_rec.dmltype$$
              );
              IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
                EXIT;
              END IF;
          END LOOP;
        END IF;


      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_qi_rec.INSTANCE_ID ,'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

END CSM_QUERY_INSTANCE_PKG;

/
