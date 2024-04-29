--------------------------------------------------------
--  DDL for Package Body CSM_MOBILE_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MOBILE_QUERY_PKG" AS
/* $Header: csmuqryb.pls 120.2.12010000.4 2009/10/13 12:20:49 trajasek noship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_MOBILE_QUERY_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_QUERY';
g_query_var_pub_name  CONSTANT VARCHAR2(30) := 'CSM_QUERY_VARIABLES';

g_debug_level           NUMBER; -- debug level

/* Select all inq records */
CURSOR c_query( b_user_name VARCHAR2, b_tranid NUMBER)
IS
SELECT *
  FROM  CSM_QUERY_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_query_var_inq( b_user_name VARCHAR2, b_tranid NUMBER, b_query_id NUMBER)
IS
SELECT *
  FROM  CSM_QUERY_VARIABLES_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   QUERY_ID = b_query_id;

/***
  This procedure is called Upload to insert a Saved Queries
  That is created in the Mobile Client
***/
PROCEDURE INSERT_QUERY
( p_QUERY_ID             IN  NUMBER,
  p_QUERY_NAME           IN  VARCHAR2,
  P_QUERY_DESC           IN  VARCHAR2,
  P_QUERY_TYPE           IN  VARCHAR2,
  p_QUERY_TEXT1          IN  VARCHAR2,
  p_QUERY_TEXT2          IN  VARCHAR2,
  p_LEVEL_ID             IN  NUMBER,
  p_LEVEL_VALUE          IN  NUMBER,
  p_PARENT_QUERY_ID      IN  NUMBER,
  p_SAVED_QUERY          IN  VARCHAR2,
  p_QUERY_OUTPUT_FORMAT  IN  VARCHAR2,
  p_MIME_TYPE            IN  VARCHAR2,
  p_WORK_FLOW            IN  VARCHAR2,
  p_RETENTION_POLICY     IN  VARCHAR2,
  p_RETENTION_DAYS       IN  NUMBER,
  p_TEMPLATE             IN  VARCHAR2,
  p_TEMPLATE_FILE        IN  VARCHAR2,
  p_EXECUTION_MODE       IN  VARCHAR2,
  p_VARIABLE_NAME        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_TYPE        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  p_HIDDEN_FLAG          IN  CSM_VARCHAR_LIST,
  p_DEFAULT_FLAG         IN  CSM_VARCHAR_LIST,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_get_query_id --get query_id
IS
SELECT CSM_QUERY_B_S.NEXTVAL
FROM DUAL;

CURSOR c_get_resp_id (c_parent_query_id NUMBER)
IS
SELECT LEVEL_ID, LEVEL_VALUE
FROM   CSM_QUERY_B
WHERE  QUERY_ID = c_parent_query_id;

l_query_id        NUMBER;
l_variable_count  NUMBER;
l_return_status   VARCHAR2(4000);
l_return_message   VARCHAR2(4000);
l_language        VARCHAR2(10) := 'US' ;
l_qry_with_no_var VARCHAR2(1) := 'N';
l_level_value     NUMBER := NULL;
l_level_id        NUMBER;
l_responsibility_id NUMBER;
BEGIN
     CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
        FND_LOG.LEVEL_ERROR);
     --Check if the user has valid access to responsibility
     OPEN  c_get_resp_id (p_PARENT_QUERY_ID);
     FETCH c_get_resp_id INTO l_level_id, l_level_value;
     CLOSE c_get_resp_id ;

     IF l_level_id = 10003 THEN
        l_responsibility_id := l_level_value;
     END IF;

     --Do the Validation only if query type is SQL
     IF UPPER(P_QUERY_TYPE) ='SQL' THEN
         --Validate the Access to a Query
        CSM_QUERY_PKG.VALIDATE_ACCESS( p_QUERY_ID       => NULL,
                        p_QUERY_TEXT1       => p_QUERY_TEXT1,
                        p_QUERY_TEXT2       => p_QUERY_TEXT2,
                        p_RESPONSIBILITY_ID => l_responsibility_id,
                        x_return_status     => l_return_status,
                        x_error_message     => l_return_message);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_ACCESS for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
        END IF;
        --Validate the Query
        CSM_QUERY_PKG.VALIDATE_QUERY( p_QUERY_ID       => NULL,
                        p_QUERY_TEXT1   => p_QUERY_TEXT1,
                        p_QUERY_TEXT2   => p_QUERY_TEXT2,
                        x_return_status => l_return_status,
                        x_error_message => l_return_message);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_QUERY for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
        END IF;
     ELSIF UPPER(P_QUERY_TYPE) ='WORKFLOW' THEN
         CSM_QUERY_PKG.VALIDATE_WORKFLOW
        ( p_QUERY_ID        => p_QUERY_ID,
          p_WORKFLOW        => p_WORK_FLOW,
          p_VARIABLE_NAME   => p_VARIABLE_NAME,
          x_return_status   => l_return_status,
          x_error_message   => l_return_message
        );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_WORLFLOW for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
        END IF;
    END IF;

    IF p_VARIABLE_NAME IS NOT NULL  AND p_VARIABLE_TYPE IS NOT NULL THEN

      IF p_VARIABLE_NAME.COUNT <> p_VARIABLE_TYPE.COUNT THEN
          CSM_UTIL_PKG.LOG
          ( 'Variable Name and Variable Type Mismatch: Leaving INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
          FND_LOG.LEVEL_ERROR);

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query insert failed for Query Name: ' || p_QUERY_NAME ||
                             ' because of Variable Name and Variable Type Mismatch' ;
          RETURN;
      END IF;
    ELSE
      IF p_VARIABLE_NAME IS NULL  AND p_VARIABLE_TYPE IS NULL THEN
        l_qry_with_no_var := 'Y';
      ELSE
          CSM_UTIL_PKG.LOG
          ( 'Variable Name and Variable Type Mismatch: Leaving INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
          FND_LOG.LEVEL_ERROR);

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query insert failed for Query Name: ' || p_QUERY_NAME ||
                             ' because of Variable Name and Variable Type Mismatch' ;
          RETURN;
      END IF;

    END IF;

    --Get the query id from the sequence.
    IF p_QUERY_ID IS NULL THEN
      OPEN   c_get_query_id;
      FETCH  c_get_query_id INTO l_query_id;
      CLOSE  c_get_query_id;
    ELSE
      l_query_id:= p_QUERY_ID;
    END IF;
    --Insert the Basic Query Definition into the base table
    INSERT INTO CSM_QUERY_B ( QUERY_ID,             QUERY_NAME,       QUERY_TYPE,
                              QUERY_TEXT1,          QUERY_TEXT2,      LEVEL_ID,
                              LEVEL_VALUE,          PARENT_QUERY_ID,  SAVED_QUERY,
                              QUERY_OUTPUT_FORMAT,  MIME_TYPE,        WORK_FLOW,
                              RETENTION_POLICY,     RETENTION_DAYS,   TEMPLATE,
                              TEMPLATE_FILE,        EXECUTION_MODE,   CREATION_DATE,
                              CREATED_BY,           LAST_UPDATE_DATE, LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN,    SEEDED  )
    VALUES                 (  l_query_id,             p_QUERY_NAME,       p_QUERY_TYPE,
                              p_QUERY_TEXT1,          p_QUERY_TEXT2,      p_LEVEL_ID,
                              p_LEVEL_VALUE,          p_PARENT_QUERY_ID,  p_SAVED_QUERY,
                              p_QUERY_OUTPUT_FORMAT,  p_MIME_TYPE,        p_WORK_FLOW,
                              p_RETENTION_POLICY,     p_RETENTION_DAYS,   p_TEMPLATE,
                              p_TEMPLATE_FILE,        p_EXECUTION_MODE,   sysdate,
                              p_LEVEL_VALUE,     sysdate,            p_LEVEL_VALUE,
                              fnd_global.login_id,   'N'  );

    --Insert the QUERY DESCRIPTION into the TL table
    INSERT INTO CSM_QUERY_TL ( QUERY_ID,             DESCRIPTION,      LANGUAGE,
                              CREATION_DATE,        CREATED_BY,
                              LAST_UPDATE_DATE,     LAST_UPDATED_BY,  LAST_UPDATE_LOGIN )
    VALUES                 (  l_query_id,             P_QUERY_DESC,       l_language,
                              sysdate,                p_LEVEL_VALUE,
                              sysdate,                p_LEVEL_VALUE, fnd_global.login_id);

    IF l_qry_with_no_var = 'N' THEN    --Proces only if the query has variables
      l_variable_count := p_VARIABLE_NAME.COUNT;

      FOR i in 1..l_variable_count LOOP
        --Insert the Query Variable Definition into the base table
        INSERT INTO CSM_QUERY_VARIABLES_B ( QUERY_ID,         VARIABLE_ID,          VARIABLE_NAME,
                                          VARIABLE_TYPE,    VARIABLE_VALUE_CHAR,  VARIABLE_VALUE_DATE,
                                          HIDDEN,           DEFAULT_FLAG,         CREATION_DATE,
                                          CREATED_BY,        LAST_UPDATE_DATE,    LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN   )
        VALUES                            ( l_query_id,         i,          p_VARIABLE_NAME(i),
                                          p_VARIABLE_TYPE(i), p_VARIABLE_VALUE_CHAR(i),  p_VARIABLE_VALUE_DATE(i),
                                          NVL(p_HIDDEN_FLAG(i),'N'),   NVL(p_DEFAULT_FLAG(i),'N'),         sysdate,
                                          p_LEVEL_VALUE,                  sysdate,                   p_LEVEL_VALUE,
                                          fnd_global.login_id        );

      END LOOP;
    END IF;

    CSM_UTIL_PKG.LOG( 'Leaving INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
      FND_LOG.LEVEL_ERROR);
    x_error_message := 'Query insert is Successful for Query Name: ' || p_QUERY_NAME ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in INSERT_QUERY for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query insert failed for Query Name: ' || p_QUERY_NAME ||
                    ' : ' || SUBSTR(SQLERRM,1,3000);
    RETURN;
END INSERT_QUERY;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_query%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         )
IS
CURSOR c_check_query(c_QUERY_ID NUMBER)
IS
SELECT QUERY_NAME, QUERY_TYPE, QUERY_TEXT1, QUERY_TEXT2,
       QUERY_OUTPUT_FORMAT, MIME_TYPE, WORK_FLOW, RETENTION_POLICY,
       RETENTION_DAYS, TEMPLATE, TEMPLATE_FILE, EXECUTION_MODE
FROM   CSM_QUERY_B
WHERE  QUERY_ID =c_QUERY_ID
AND    NVL(DELETE_FLAG,'N') = 'N';

CURSOR c_get_variables (c_QUERY_ID NUMBER)
IS
SELECT
    vb.VARIABLE_NAME,
    vb.VARIABLE_TYPE,
    vb.VARIABLE_VALUE_CHAR,
    vb.VARIABLE_VALUE_DATE,
    vb.HIDDEN,
    vb.DEFAULT_FLAG
FROM  CSM_QUERY_VARIABLES_INQ     vb
WHERE vb.QUERY_ID = c_QUERY_ID;

CURSOR c_get_user(c_user_name VARCHAR2)
IS
SELECT USER_ID
FROM   ASG_USER
WHERE  USER_NAME =c_user_name;
--Variable Declarations
  l_variable_name_lst  CSM_VARCHAR_LIST;
  l_var_type_lst       CSM_VARCHAR_LIST;
  l_var_value_char_lst CSM_VARCHAR_LIST;
  l_var_value_date_lst CSM_DATE_LIST;
  l_var_hidden_lst     CSM_VARCHAR_LIST;
  l_var_default_lst    CSM_VARCHAR_LIST;
  l_user_id          NUMBER;
  l_QUERY_ID            NUMBER;
  l_QUERY_NAME          VARCHAR2(255);
  l_QUERY_TYPE          VARCHAR2(255);
  l_QUERY_TEXT1         VARCHAR2(4000);
  l_QUERY_TEXT2         VARCHAR2(4000);
  l_LEVEL_ID            NUMBER;
  l_LEVEL_VALUE         NUMBER;
  l_PARENT_QUERY_ID     NUMBER;
  l_SAVED_QUERY         VARCHAR2(1);
  l_QUERY_OUTPUT_FORMAT VARCHAR2(255);
  l_MIME_TYPE           VARCHAR2(255);
  l_WORK_FLOW           VARCHAR2(255);
  l_RETENTION_POLICY    VARCHAR2(30);
  l_RETENTION_DAYS      NUMBER;
  l_TEMPLATE            VARCHAR2(30);
  l_TEMPLATE_FILE       VARCHAR2(255);
  l_EXECUTION_MODE      VARCHAR2(30);
  --x_return_status       VARCHAR2(255);
  --p_error_msg           VARCHAR2(4000);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Entering CSM_MOBILE_QUERY_PKG.APPLY_INSERT for Query ID ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  l_PARENT_QUERY_ID := p_record.PARENT_QUERY_ID;
  l_query_id        := p_record.QUERY_ID;

  IF l_PARENT_QUERY_ID IS NULL THEN
    CSM_UTIL_PKG.LOG( 'Parent Query Id is Invalid for Query Id: ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    p_error_msg     := 'Parent Query Id is Invalid for Query Id : ' || l_query_id ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  --Check if the Query id is valid
  OPEN  c_check_query(l_PARENT_QUERY_ID);
  FETCH c_check_query INTO l_QUERY_NAME, l_QUERY_TYPE, l_QUERY_TEXT1, l_QUERY_TEXT2,
                           l_QUERY_OUTPUT_FORMAT, l_MIME_TYPE, l_WORK_FLOW, l_RETENTION_POLICY,
                           l_RETENTION_DAYS,l_TEMPLATE, l_TEMPLATE_FILE, l_EXECUTION_MODE;

  IF c_check_query%NOTFOUND THEN
    CSM_UTIL_PKG.LOG( 'Parent Query Id is Invalid for Query Id: ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    p_error_msg     := 'Parent Query Id is Invalid for Query Id : ' || l_query_id ;
    CLOSE c_check_query;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE   c_check_query;
  --get user_id
  OPEN  c_get_user(p_record.CLID$$CS);
  FETCH c_get_user INTO l_user_id;
  CLOSE c_get_user;

  --Set the parameters for the Insert Query from INQ
  l_QUERY_ID            := p_record.QUERY_ID;
  l_PARENT_QUERY_ID     := p_record.PARENT_QUERY_ID;
  l_QUERY_NAME          := NVL(p_record.QUERY_NAME,l_QUERY_NAME);
  l_QUERY_TYPE          := NVL(p_record.QUERY_TYPE,l_QUERY_TYPE);
  l_LEVEL_ID            := 10004; --For user level
  l_LEVEL_VALUE         := l_user_id;
  l_SAVED_QUERY         := 'Y';    --from MFS Client;
  l_QUERY_OUTPUT_FORMAT := NVL(p_record.QUERY_TYPE,l_QUERY_TYPE);
  l_MIME_TYPE           := NVL(p_record.MIME_TYPE,l_MIME_TYPE);
  l_WORK_FLOW           := NVL(p_record.WORK_FLOW,l_WORK_FLOW);
  l_RETENTION_POLICY    := NVL(p_record.RETENTION_POLICY,l_RETENTION_POLICY);
  l_RETENTION_DAYS      := NVL(p_record.RETENTION_DAYS,l_RETENTION_DAYS);
  l_TEMPLATE            := NVL(p_record.TEMPLATE,l_TEMPLATE);
  l_TEMPLATE_FILE       := NVL(p_record.TEMPLATE_FILE,l_TEMPLATE_FILE);
  l_EXECUTION_MODE      := NVL(p_record.EXECUTION_MODE,l_EXECUTION_MODE);

  OPEN  c_get_variables (l_QUERY_ID);
  FETCH c_get_variables BULK COLLECT INTO l_variable_name_lst, l_var_type_lst, l_var_value_char_lst, l_var_value_date_lst,
                                          l_var_hidden_lst, l_var_default_lst;
  CLOSE c_get_variables;

INSERT_QUERY
( p_QUERY_ID             => l_QUERY_ID,
  p_QUERY_NAME           => l_QUERY_NAME,
  P_QUERY_DESC           => p_record.DESCRIPTION,
  P_QUERY_TYPE           => l_QUERY_TYPE,
  p_QUERY_TEXT1          => l_QUERY_TEXT1,
  p_QUERY_TEXT2          => l_QUERY_TEXT2,
  p_LEVEL_ID             => l_LEVEL_ID,
  p_LEVEL_VALUE          => l_LEVEL_VALUE,
  p_PARENT_QUERY_ID      => l_PARENT_QUERY_ID,
  p_SAVED_QUERY          => l_SAVED_QUERY,
  p_QUERY_OUTPUT_FORMAT  => l_QUERY_OUTPUT_FORMAT,
  p_MIME_TYPE            => l_MIME_TYPE,
  p_WORK_FLOW            => l_WORK_FLOW,
  p_RETENTION_POLICY     => l_RETENTION_POLICY,
  p_RETENTION_DAYS       => l_RETENTION_DAYS,
  p_TEMPLATE             => l_TEMPLATE,
  p_TEMPLATE_FILE        => l_TEMPLATE_FILE,
  p_EXECUTION_MODE       => l_EXECUTION_MODE,
  p_VARIABLE_NAME        => l_variable_name_lst,
  p_VARIABLE_TYPE        => l_var_type_lst,
  p_VARIABLE_VALUE_CHAR  => l_var_value_char_lst,
  p_VARIABLE_VALUE_DATE  => l_var_value_date_lst,
  p_HIDDEN_FLAG          => l_var_hidden_lst,
  p_DEFAULT_FLAG         => l_var_default_lst,
  x_return_status        => x_return_status,
  x_error_message        => p_error_msg);


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CSM_UTIL_PKG.LOG( 'Query Upload Failed for Query ID : ' || l_query_id  ,FND_LOG.LEVEL_ERROR);
    p_error_msg     := 'Query Upload Failed for Query ID : '|| l_query_id || ' with error ' || p_error_msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_MOBILE_QUERY_PKG.APPLY_INSERT for Query ID : ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  p_error_msg     := 'Query Upload is Successful for Query ID : '|| l_query_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION WHEN OTHERS THEN
     p_error_msg := 'Exeception in Query Upload for  Query Id : '|| l_query_id ||' with Error ' ||SUBSTR(SQLERRM,1,3000);
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT: ' || SUBSTR(SQLERRM,1,3000)
               || ' for Query ID ' || p_record.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);
     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_DELETE
         (
           p_record        IN c_query%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         )
IS
CURSOR c_check_query(c_QUERY_ID NUMBER, c_USER_ID NUMBER)
IS
SELECT NVL(DELETE_FLAG,'N')
FROM   CSM_QUERY_B
WHERE  QUERY_ID = c_QUERY_ID
AND    LEVEL_ID = 10004 --user level
AND    LEVEL_VALUE = c_USER_ID
AND    SAVED_QUERY = 'Y'
AND    NVL(DELETE_FLAG,'N') = 'N';


CURSOR c_get_user(c_user_name VARCHAR2)
IS
SELECT USER_ID
FROM   ASG_USER
WHERE  USER_NAME =c_user_name;

l_DELETE_FLAG VARCHAR2(1) := NULL;
l_USER_ID NUMBER := NULL;
l_QUERY_ID NUMBER;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_MOBILE_QUERY_PKG.APPLY_DELETE for Query ID ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_DELETE',FND_LOG.LEVEL_PROCEDURE);
  l_query_id        := p_record.QUERY_ID;

  OPEN  c_get_user(p_record.CLID$$CS);
  FETCH c_get_user INTO l_USER_ID;
  CLOSE c_get_user;

  IF l_USER_ID IS NULL THEN
    p_error_msg     := 'The user is invalid.Please Check. User Name : '|| p_record.CLID$$CS;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  OPEN  c_check_query(l_QUERY_ID, l_USER_ID);
  FETCH c_check_query INTO l_DELETE_FLAG;
  CLOSE c_check_query;

  IF l_DELETE_FLAG IS NULL THEN
    p_error_msg     := 'User may not have permission to Delete the Query or The Query is not available for Delete. Query ID : '|| l_query_id;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;
  --Update the Query Definition in the base table
  UPDATE    CSM_QUERY_B
  SET       DELETE_FLAG       = 'Y',
            LAST_UPDATE_DATE  = sysdate,
            LAST_UPDATED_BY   = fnd_global.user_id,
            LAST_UPDATE_LOGIN = fnd_global.login_id
  WHERE     QUERY_ID = l_QUERY_ID;

  CSM_UTIL_PKG.LOG('Leaving CSM_MOBILE_QUERY_PKG.APPLY_DELETE for Query ID : ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_DELETE',FND_LOG.LEVEL_PROCEDURE);
  p_error_msg     := 'Query Delete is Successful for Query ID : '|| l_query_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION WHEN OTHERS THEN
     p_error_msg := 'Exeception in Query Delete for  Query Id : '|| l_query_id ||' with Error ' ||SUBSTR(SQLERRM,1,3000);
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_DELETE: ' || SUBSTR(SQLERRM,1,3000)
               || ' for Query ID ' || p_record.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_DELETE',FND_LOG.LEVEL_EXCEPTION);
     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_DELETE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN  c_query%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_MOBILE_QUERY_PKG.APPLY_RECORD for Query ID ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF  p_record.dmltype$$='D' THEN
    -- Process DELETE
    APPLY_DELETE
      (
        p_record,
        p_error_msg,
        x_return_status
      );

  ELSE --Delete and update is not supported for this PI
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Query Instance ID ' || p_record.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_MOBILE_QUERY_PKG.APPLY_RECORD for Query ID ' || p_record.QUERY_ID ,
                         'CSM_MOBILE_QUERY_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || SUBSTR(SQLERRM,1,3000)
               || ' for Query ID ' || p_record.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_QUERY
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
CSM_UTIL_PKG.LOG('Entering CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue ***/
  FOR r_query_rec IN  c_query( p_user_name, p_tranid) LOOP
    SAVEPOINT save_rec ;
    /*** apply record ***/
    APPLY_RECORD
      (
        r_query_rec
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_query_rec.seqno$$,
          r_query_rec.QUERY_ID,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      IF   l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        FOR r_query_var_inq_rec IN  c_query_var_inq( p_user_name, p_tranid,r_query_rec.QUERY_ID ) LOOP
            CSM_UTIL_PKG.DELETE_RECORD
            (
              p_user_name,
              p_tranid,
              r_query_var_inq_rec.seqno$$,
              r_query_var_inq_rec.GEN_PK,
              g_object_name,
              g_query_var_pub_name,
              l_error_msg,
              l_process_status
            );
            EXIT WHEN l_process_status <> FND_API.G_RET_STS_SUCCESS;
        END LOOP;
      END IF;
      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
       /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
      || ' for Instance ID ' || r_query_rec.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_query_rec.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_query_rec.seqno$$
       , r_query_rec.QUERY_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_query_rec.dmltype$$
       );

      IF   l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        FOR r_query_var_inq_rec IN  c_query_var_inq( p_user_name, p_tranid,r_query_rec.QUERY_ID ) LOOP
            CSM_UTIL_PKG.DEFER_RECORD
            (
              p_user_name,
              p_tranid,
              r_query_var_inq_rec.seqno$$,
              r_query_var_inq_rec.GEN_PK,
              g_object_name,
              g_query_var_pub_name,
              l_error_msg,
              l_process_status,
              r_query_var_inq_rec.dmltype$$
            );
            EXIT WHEN l_process_status <> FND_API.G_RET_STS_SUCCESS;
        END LOOP;
      END IF;
      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_query_rec.QUERY_ID ,'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

END CSM_MOBILE_QUERY_PKG;

/
