--------------------------------------------------------
--  DDL for Package Body CSM_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_QUERY_PKG" AS
/* $Header: csmqryb.pls 120.13.12010000.18 2010/07/06 11:12:52 ravir noship $ */

  /*
   * The function to be called by Mobile Admin page to store defined queries
   */
-- Purpose: Store the Query Definition done in the Mobile Admin page
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- TRAJASEK     11-APR-2009          Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_QUERY_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_QUERIES';  -- publication item name
g_debug_level           NUMBER; -- debug level
g_pub_item_qres      VARCHAR2(30) := 'CSM_QUERY_RESULTS';
g_pub_item_qry      VARCHAR2(50) := 'CSM_QUERY';
g_pub_item_qvar     VARCHAR2(50) := 'CSM_QUERY_VARIABLES';
g_pub_item_qval    VARCHAR2(50) := 'CSM_QUERY_VARIABLE_VALUES';
g_pub_item_qins      VARCHAR2(50) := 'CSM_QUERY_INSTANCES';


--Procedure to UPDATE the status of the Query Execution
PROCEDURE UPDATE_EXE_STATUS
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  NUMBER,
  p_QSTART_TIME          IN  DATE,
  p_QEND_TIME            IN  DATE,
  p_STATUS               IN  VARCHAR2,
  p_ERROR                IN  VARCHAR2
)
IS
l_access_id NUMBER;
l_mark_dirty  BOOLEAN;
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering UPDATE_EXE_STATUS for User ID, Query Id, Instance ID : ' || p_USER_ID ||
       ':' || p_QUERY_ID || ':' || p_INSTANCE_ID,
        FND_LOG.LEVEL_ERROR);

     UPDATE CSM_QUERY_INSTANCES_ACC
     SET    QUERY_START_TIME = NVL(p_QSTART_TIME,QUERY_START_TIME) ,
            QUERY_END_TIME   = NVL(p_QEND_TIME,QUERY_END_TIME) ,
            STATUS           = NVL(p_STATUS,STATUS),
            ERROR_DESCRIPTION= NVL(p_ERROR,ERROR_DESCRIPTION)
     WHERE  USER_ID     = p_USER_ID
     AND    QUERY_ID    = p_QUERY_ID
     AND    INSTANCE_ID = p_INSTANCE_ID
     RETURNING ACCESS_ID INTO l_access_id;

      IF csm_util_pkg.is_palm_user(p_USER_ID) AND l_access_id IS NOT NULL  THEN

          l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qins,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => p_USER_ID,
                                                   p_dml         => asg_download.upd,
                                                   p_timestamp   => sysdate);
      END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving UPDATE_EXE_STATUS for User ID, Query Id, Instance ID : ' || p_USER_ID ||
       ':' || p_QUERY_ID || ':' || p_INSTANCE_ID,
      FND_LOG.LEVEL_ERROR);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in UPDATE_EXE_STATUS for User ID, Query Id, Instance ID : ' || p_USER_ID ||
       ':' || p_QUERY_ID || ':' || p_INSTANCE_ID ||  SQLERRM, 'UPDATE_EXE_STATUS',
    FND_LOG.LEVEL_EXCEPTION);
  RAISE;
END UPDATE_EXE_STATUS;

/***
  This procedure is called by ASG team to insert a Query
  That is created in the Mobile Admin Page
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
  p_PROCEDURE            IN  VARCHAR2,
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
  p_EMAIL_ENABLED        IN  VARCHAR2,
  p_RESTRICTED_FLAG      IN  VARCHAR2,
  p_DISABLED_FLAG        IN  VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_get_query_id --get query_id
IS
SELECT CSM_QUERY_B_S.NEXTVAL
FROM DUAL;

l_query_id        NUMBER;
l_variable_count  NUMBER;
l_return_status   VARCHAR2(4000);
l_return_message   VARCHAR2(4000);
l_language        VARCHAR2(10) := 'US' ;
l_qry_with_no_var VARCHAR2(1) := 'N';
l_responsibility_id  NUMBER := NULL;
l_VARIABLE_VALUE_CHAR VARCHAR2(4000);
BEGIN
     CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
        FND_LOG.LEVEL_ERROR);

     IF p_LEVEL_ID = 10003 THEN
        l_responsibility_id := p_LEVEL_VALUE;
     END IF;
     --Do the Validation only if query type is SQL
     IF UPPER(P_QUERY_TYPE) ='SQL' THEN
          --Validate the Access to a Query
       VALIDATE_ACCESS( p_QUERY_ID          => NULL,
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
          x_error_message := 'Query Access Validation failed : ' || l_return_message;
          RETURN;
      END IF;
        --Validate the Query
      VALIDATE_QUERY( p_QUERY_ID       => NULL,
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
         VALIDATE_WORKFLOW
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

      ELSIF UPPER(P_QUERY_TYPE) = 'PROCEDURE' THEN

        VALIDATE_PROCEDURE
        ( p_QUERY_ID        => p_QUERY_ID,
          p_PROCEDURE        => p_PROCEDURE,
          x_return_status   => l_return_status,
          x_error_message   => l_return_message
        );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_PROCEDURE for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
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
    OPEN   c_get_query_id;
    FETCH  c_get_query_id INTO l_query_id;
    CLOSE  c_get_query_id;

    --Insert the Basic Query Definition into the base table
    INSERT INTO CSM_QUERY_B ( QUERY_ID,             QUERY_NAME,       QUERY_TYPE,
                              QUERY_TEXT1,          QUERY_TEXT2,      LEVEL_ID,
                              LEVEL_VALUE,          PARENT_QUERY_ID,  SAVED_QUERY,
                              QUERY_OUTPUT_FORMAT,  MIME_TYPE,        WORK_FLOW,
                              RETENTION_POLICY,     RETENTION_DAYS,   TEMPLATE,
                              TEMPLATE_FILE,        EXECUTION_MODE,   CREATION_DATE,
                              CREATED_BY,           LAST_UPDATE_DATE, LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN,    SEEDED,           PROCEDURE_NAME,
                              EMAIL_ENABLED,        RESTRICTED_FLAG,  DISABLED_FLAG )
    VALUES                 (  l_query_id,             p_QUERY_NAME,       p_QUERY_TYPE,
                              p_QUERY_TEXT1,          p_QUERY_TEXT2,      p_LEVEL_ID,
                              p_LEVEL_VALUE,          p_PARENT_QUERY_ID,  p_SAVED_QUERY,
                              p_QUERY_OUTPUT_FORMAT,  p_MIME_TYPE,        p_WORK_FLOW,
                              p_RETENTION_POLICY,     p_RETENTION_DAYS,   p_TEMPLATE,
                              p_TEMPLATE_FILE,        p_EXECUTION_MODE,   sysdate,
                              fnd_global.user_id,     sysdate,            fnd_global.user_id,
                              fnd_global.login_id,   'N',                 p_PROCEDURE,
                              p_EMAIL_ENABLED,        p_RESTRICTED_FLAG,  p_DISABLED_FLAG);

    --Insert the QUERY DESCRIPTION into the TL table
    INSERT INTO CSM_QUERY_TL ( QUERY_ID,             DESCRIPTION,      LANGUAGE,
                              CREATION_DATE,        CREATED_BY,
                              LAST_UPDATE_DATE,     LAST_UPDATED_BY,  LAST_UPDATE_LOGIN )
    VALUES                 (  l_query_id,             P_QUERY_DESC,       l_language,
                              sysdate,                fnd_global.user_id,
                              sysdate,                fnd_global.user_id, fnd_global.login_id);

    IF l_qry_with_no_var = 'N' THEN    --Proces only if the query has variables
      l_variable_count := p_VARIABLE_NAME.COUNT;

      FOR i in 1..l_variable_count LOOP
        --Insert the Query Variable Definition into the base table
        l_VARIABLE_VALUE_CHAR := SUBSTR(p_VARIABLE_VALUE_CHAR(i),1, 4000);
        INSERT INTO CSM_QUERY_VARIABLES_B ( QUERY_ID,         VARIABLE_ID,          VARIABLE_NAME,
                                          VARIABLE_TYPE,    VARIABLE_VALUE_CHAR,  VARIABLE_VALUE_DATE,
                                          HIDDEN,           DEFAULT_FLAG,         CREATION_DATE,
                                          CREATED_BY,        LAST_UPDATE_DATE,    LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN   )
        VALUES                            ( l_query_id,         i,          p_VARIABLE_NAME(i),
                                          p_VARIABLE_TYPE(i), l_VARIABLE_VALUE_CHAR,  p_VARIABLE_VALUE_DATE(i),
                                          NVL(p_HIDDEN_FLAG(i),'N'),   NVL(p_DEFAULT_FLAG(i),'N'),         sysdate,
                                          fnd_global.user_id,                  sysdate,                   fnd_global.user_id,
                                          fnd_global.login_id        );

      END LOOP;
    END IF;

    COMMIT;
    CSM_UTIL_PKG.LOG( 'Leaving INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
      FND_LOG.LEVEL_ERROR);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in INSERT_QUERY for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query insert failed for Query Name: ' || p_QUERY_NAME ||
                    ' : ' || SUBSTR(SQLERRM,1,3000);
  ROLLBACK;
END INSERT_QUERY;


/***
  This procedure is called by ASG team to Update a Query
  that is created in the Mobile Admin Page
***/
PROCEDURE UPDATE_QUERY
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
  p_PROCEDURE            IN  VARCHAR2,
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
  p_EMAIL_ENABLED        IN  VARCHAR2,
  p_RESTRICTED_FLAG      IN  VARCHAR2,
  p_DISABLED_FLAG        IN  VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_get_existing_var_count(c_query_id NUMBER)  --get the count of existing variables
IS
SELECT count(*)
FROM CSM_QUERY_VARIABLES_B
WHERE QUERY_ID  =c_query_id ;

CURSOR c_get_query(c_query_id NUMBER)  --get the existing query data
IS
SELECT  LEVEL_VALUE
FROM    CSM_QUERY_B
WHERE   QUERY_ID  = c_query_id ;


l_Existing_variable_count  NUMBER;
l_variable_count  NUMBER;
l_language        VARCHAR2(10) := 'US' ;
l_old_LEVEL_VALUE NUMBER;
l_return_status   VARCHAR2(100);
l_return_message  VARCHAR2(4000);
l_qry_with_no_var VARCHAR2(1) := 'N';
l_responsibility_id  NUMBER := NULL;
l_VARIABLE_VALUE_CHAR VARCHAR2(4000);

BEGIN
    CSM_UTIL_PKG.LOG
    ( 'Entering UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ,
      FND_LOG.LEVEL_ERROR);

     IF p_LEVEL_ID = 10003 THEN
        l_responsibility_id := p_LEVEL_VALUE;
     END IF;
     --Do the Validation only if query type is SQL
     IF UPPER(P_QUERY_TYPE) ='SQL' THEN
          --Validate the Access to a Query
       VALIDATE_ACCESS( p_QUERY_ID          => NULL,
                        p_QUERY_TEXT1       => p_QUERY_TEXT1,
                        p_QUERY_TEXT2       => p_QUERY_TEXT2,
                        p_RESPONSIBILITY_ID => l_responsibility_id,
                        x_return_status     => l_return_status,
                        x_error_message     => l_return_message);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_Access for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'UPDATE_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Access Validation failed : ' || l_return_message;
          RETURN;
       END IF;

        --Validate the Query
       VALIDATE_QUERY( p_QUERY_ID      => NULL,
                       p_QUERY_TEXT1   => p_QUERY_TEXT1,
                       p_QUERY_TEXT2   => p_QUERY_TEXT2,
                       x_return_status => l_return_status,
                       x_error_message => l_return_message);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_QUERY for Query Id ' || p_QUERY_ID ||  SQLERRM, 'UPDATE_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
      END IF;
    ELSIF UPPER(P_QUERY_TYPE) ='WORKFLOW' THEN
         VALIDATE_WORKFLOW
        ( p_QUERY_ID        => p_QUERY_ID,
          p_WORKFLOW        => p_WORK_FLOW,
          p_VARIABLE_NAME   => p_VARIABLE_NAME,
          x_return_status   => l_return_status,
          x_error_message   => l_return_message
        );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_WORLFLOW for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'UPDATE_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
        END IF;

      ELSIF UPPER(P_QUERY_TYPE) ='PROCEDURE' THEN
         VALIDATE_PROCEDURE
        ( p_QUERY_ID        => p_QUERY_ID,
          p_PROCEDURE        => p_PROCEDURE,
          x_return_status   => l_return_status,
          x_error_message   => l_return_message
        );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Exception occurred in VALIDATE_PROCEDURE for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'UPDATE_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Validation failed : ' || l_return_message;
          RETURN;
        END IF;
    END IF;

    OPEN  c_get_query(p_QUERY_ID);
    FETCH c_get_query INTO l_old_LEVEL_VALUE;
    CLOSE c_get_query;

    IF p_LEVEL_ID =10003  AND p_LEVEL_VALUE <> l_old_LEVEL_VALUE THEN

      CSM_UTIL_PKG.LOG
      ( 'Responsibility Mapping for the query changed : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ,
        FND_LOG.LEVEL_ERROR);
       --do soft delete to maintain history
       DELETE_QUERY
        ( p_QUERY_ID         => p_QUERY_ID,
          x_return_status    => l_return_status,
          x_error_message    => l_return_message
        );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          CSM_UTIL_PKG.LOG
          ( 'ERROR occurred in DELETE_QUERY for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'DELETE_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Delete failed durin Update: ' || l_return_message;
          RETURN;
        ELSE --Insert the query again for the new responsibility
          INSERT_QUERY
          ( p_QUERY_ID             => NULL,
            p_QUERY_NAME           => p_QUERY_NAME,
            P_QUERY_DESC           => P_QUERY_DESC,
            P_QUERY_TYPE           => P_QUERY_TYPE,
            p_QUERY_TEXT1          => p_QUERY_TEXT1,
            p_QUERY_TEXT2          => p_QUERY_TEXT2,
            p_LEVEL_ID             => p_LEVEL_ID,
            p_LEVEL_VALUE          => p_LEVEL_VALUE,
            p_PARENT_QUERY_ID      => p_PARENT_QUERY_ID,
            p_SAVED_QUERY          => p_SAVED_QUERY,
            p_QUERY_OUTPUT_FORMAT  => p_QUERY_OUTPUT_FORMAT,
            p_MIME_TYPE            => p_MIME_TYPE,
            p_WORK_FLOW            => p_WORK_FLOW,
            p_PROCEDURE            => p_PROCEDURE,
            p_RETENTION_POLICY     => p_RETENTION_POLICY,
            p_RETENTION_DAYS       => p_RETENTION_DAYS,
            p_TEMPLATE             => p_TEMPLATE,
            p_TEMPLATE_FILE        => p_TEMPLATE_FILE,
            p_EXECUTION_MODE       => p_EXECUTION_MODE,
            p_VARIABLE_NAME        => p_VARIABLE_NAME,
            p_VARIABLE_TYPE        => p_VARIABLE_TYPE,
            p_VARIABLE_VALUE_CHAR  => p_VARIABLE_VALUE_CHAR,
            p_VARIABLE_VALUE_DATE  => p_VARIABLE_VALUE_DATE,
            p_HIDDEN_FLAG          => p_HIDDEN_FLAG,
            p_DEFAULT_FLAG         => p_DEFAULT_FLAG,
            p_EMAIL_ENABLED        => p_EMAIL_ENABLED,
            p_RESTRICTED_FLAG      => p_RESTRICTED_FLAG,
            p_DISABLED_FLAG        => p_DISABLED_FLAG,
            x_return_status        => l_return_status,
            x_error_message        => l_return_message
          );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            CSM_UTIL_PKG.LOG
            ( 'ERROR occurred in INSERT_QUERY for Query Name ' || p_QUERY_NAME ||  SUBSTR(SQLERRM,1,3000) , 'INSERT_QUERY',
              FND_LOG.LEVEL_EXCEPTION);
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := 'INSERT_QUERY failed during UPDATE: ' || l_return_message;
            ROLLBACK;
            RETURN;
          ELSE
            CSM_UTIL_PKG.LOG
            ( 'Leaving UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ,
              FND_LOG.LEVEL_ERROR);
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            COMMIT;
            RETURN;
          END IF;

        END IF;
      END IF; --level value check

      --Update the Query Definition in the base table
      UPDATE    CSM_QUERY_B
      SET       QUERY_NAME = p_QUERY_NAME,       QUERY_TYPE = p_QUERY_TYPE,
                QUERY_TEXT1 = p_QUERY_TEXT1,     QUERY_TEXT2 = p_QUERY_TEXT2,
                LEVEL_ID  = p_LEVEL_ID,          LEVEL_VALUE  = p_LEVEL_VALUE,
                PARENT_QUERY_ID  = p_PARENT_QUERY_ID,           SAVED_QUERY  = p_SAVED_QUERY,
                QUERY_OUTPUT_FORMAT  = p_QUERY_OUTPUT_FORMAT,   MIME_TYPE  = p_MIME_TYPE,
                WORK_FLOW = p_WORK_FLOW,                        RETENTION_DAYS = p_RETENTION_DAYS,
                RETENTION_POLICY = p_RETENTION_POLICY,          TEMPLATE = p_TEMPLATE,
                TEMPLATE_FILE = p_TEMPLATE_FILE,                EXECUTION_MODE= p_EXECUTION_MODE,
                LAST_UPDATE_DATE = sysdate,                     LAST_UPDATED_BY = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id,
                PROCEDURE_NAME = p_PROCEDURE,
                EMAIL_ENABLED = p_EMAIL_ENABLED,
                RESTRICTED_FLAG = p_RESTRICTED_FLAG,
                DISABLED_FLAG = p_DISABLED_FLAG
      WHERE     QUERY_ID = p_QUERY_ID;

      UPDATE    CSM_QUERY_TL
      SET       DESCRIPTION = P_QUERY_DESC,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
      WHERE     QUERY_ID = p_QUERY_ID
      AND       LANGUAGE = l_language;

      IF p_VARIABLE_NAME IS NOT NULL  AND p_VARIABLE_TYPE IS NOT NULL THEN

        IF p_VARIABLE_NAME.COUNT <> p_VARIABLE_TYPE.COUNT THEN
            CSM_UTIL_PKG.LOG
            ( 'Variable Name and Variable Type Mismatch: Leaving UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME  ,
            FND_LOG.LEVEL_ERROR);

            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := ' UPDATE_QUERY Failed for Query Id and Query Name : ' || p_QUERY_ID || ' : ' ||
                             p_QUERY_NAME || ' because of Variable Name and Variable Type Mismatch';
            RETURN;
        END IF;
      ELSE
        IF p_VARIABLE_NAME IS NULL  AND p_VARIABLE_TYPE IS NULL THEN
          l_qry_with_no_var := 'Y';
        ELSE
            CSM_UTIL_PKG.LOG
            ( 'Variable Name and Variable Type Mismatch: Leaving UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME  ,
            FND_LOG.LEVEL_ERROR);

            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := ' UPDATE_QUERY Failed for Query Id and Query Name : ' || p_QUERY_ID || ' : ' ||
                             p_QUERY_NAME || ' because of Variable Name and Variable Type Mismatch';
            RETURN;
        END IF;

      END IF;

      OPEN  c_get_existing_var_count(p_QUERY_ID);
      FETCH c_get_existing_var_count INTO l_Existing_variable_count;
      CLOSE c_get_existing_var_count;

      --the check are done to avoid error during uninitialized Table types
      IF l_qry_with_no_var = 'N' THEN
        l_variable_count := p_VARIABLE_NAME.COUNT;
      ELSE
        l_variable_count := 0;
      END IF;


      --If the variable count has increased or Decreased then do
      IF l_Existing_variable_count <> l_variable_count THEN

        IF l_Existing_variable_count > 0 THEN
          --Delete all the existing variables and insert again
          DELETE FROM CSM_QUERY_VARIABLES_B WHERE QUERY_ID =p_QUERY_ID;
        END IF;
        FOR i in 1..l_variable_count LOOP
          --Insert the Query Variable Definition into the base table
          l_VARIABLE_VALUE_CHAR := SUBSTR(p_VARIABLE_VALUE_CHAR(i),1, 4000);
          INSERT INTO CSM_QUERY_VARIABLES_B ( QUERY_ID,         VARIABLE_ID,          VARIABLE_NAME,
                                              VARIABLE_TYPE,    VARIABLE_VALUE_CHAR,  VARIABLE_VALUE_DATE,
                                              HIDDEN,           DEFAULT_FLAG,         CREATION_DATE,
                                              CREATED_BY,        LAST_UPDATE_DATE,    LAST_UPDATED_BY,
                                              LAST_UPDATE_LOGIN   )
          VALUES                            ( p_QUERY_ID,         i,          p_VARIABLE_NAME(i),
                                              p_VARIABLE_TYPE(i), l_VARIABLE_VALUE_CHAR,  p_VARIABLE_VALUE_DATE(i),
                                              NVL(p_HIDDEN_FLAG(i),'N'),   NVL(p_DEFAULT_FLAG(i),'N'),         sysdate,
                                              fnd_global.user_id,                  sysdate,                   fnd_global.user_id,
                                              fnd_global.login_id        );


        END LOOP;

      ELSE
          --Update the Existing Variable as they are changed
        FOR i in 1..l_variable_count LOOP
          --Insert the Query Variable Definition into the base table
          l_VARIABLE_VALUE_CHAR := SUBSTR(p_VARIABLE_VALUE_CHAR(i),1, 4000);
          UPDATE CSM_QUERY_VARIABLES_B
          SET    VARIABLE_NAME    = p_VARIABLE_NAME(i),
                  VARIABLE_TYPE   = p_VARIABLE_TYPE(i),
                  VARIABLE_VALUE_CHAR = l_VARIABLE_VALUE_CHAR,
                  VARIABLE_VALUE_DATE = p_VARIABLE_VALUE_DATE(i),
                  HIDDEN              = NVL(p_HIDDEN_FLAG(i),'N'),
                  DEFAULT_FLAG        = NVL(p_DEFAULT_FLAG(i),'N'),
                  LAST_UPDATE_DATE    = sysdate,
                  LAST_UPDATED_BY     = fnd_global.user_id,
                  LAST_UPDATE_LOGIN   = fnd_global.login_id
          WHERE QUERY_ID =p_QUERY_ID
          AND   VARIABLE_ID = i	;

        END LOOP;

      END IF;

      COMMIT;
      CSM_UTIL_PKG.LOG
      ( 'Leaving UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ,
        FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ||  SQLERRM, 'UPDATE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Update Failed for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ||
                    ' : ' || SUBSTR(SQLERRM,1,3000);
  ROLLBACK;
END UPDATE_QUERY;

/***
  This procedure is called by ASG team to Delete a Query
  That is created in the Mobile Admin Page
***/
PROCEDURE DELETE_QUERY
( p_QUERY_ID             IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
      CSM_UTIL_PKG.LOG
      ( 'Entering DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

      --Update the Query Definition in the base table
      UPDATE    CSM_QUERY_B
      SET       DELETE_FLAG       = 'Y',
                LAST_UPDATE_DATE  = sysdate,
                LAST_UPDATED_BY   = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
      WHERE QUERY_ID = p_QUERY_ID;

      --Update the Query Definition in the base table for parent queries
      UPDATE    CSM_QUERY_B
      SET       DELETE_FLAG       = 'Y',
                LAST_UPDATE_DATE  = sysdate,
                LAST_UPDATED_BY   = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
      WHERE PARENT_QUERY_ID = p_QUERY_ID;

      COMMIT;

      CSM_UTIL_PKG.LOG
      ( 'Leaving DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ||  SQLERRM, 'DELETE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Delete Failed for Query Id and Query Name : ' || p_QUERY_ID ;
END DELETE_QUERY;

/***
  This procedure can be used to validate a given query
***/
PROCEDURE VALIDATE_QUERY
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_QUERY_TEXT1          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_TEXT2          IN  VARCHAR2 DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
 cursor_name INTEGER;
 --TYPE VARCHAR2S IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;
 l_query_lst     dbms_sql.varchar2s;
 l_qry_length1   NUMBER;
 l_qry_length2   NUMBER;
 l_qry_count1    NUMBER;
 l_qry_count2    NUMBER;
 l_qry_tot_count NUMBER;
 l_QUERY_TEXT1   VARCHAR2(4000);
 l_QUERY_TEXT2   VARCHAR2(4000);

 CURSOR c_get_query_txt (c_QUERY_ID NUMBER)
 IS
 SELECT QUERY_TEXT1,QUERY_TEXT2
 FROM   CSM_QUERY_B
 WHERE  QUERY_ID = c_QUERY_ID;
BEGIN
      CSM_UTIL_PKG.LOG
      ( 'Entering VALIDATE_QUERY for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

     l_QUERY_TEXT1 := p_QUERY_TEXT1;
     l_QUERY_TEXT2 := p_QUERY_TEXT2;

     --if the Query text is empty get the query text using the query id from the table
     IF l_QUERY_TEXT1 IS NULL AND l_QUERY_TEXT2 IS NULL THEN

      OPEN  c_get_query_txt(p_QUERY_ID);
      FETCH c_get_query_txt INTO l_QUERY_TEXT1,l_QUERY_TEXT2;
      CLOSE c_get_query_txt;

     END IF;

     --l_QUERY_TEXT1 := REPLACE(l_QUERY_TEXT1,'--','');
     --l_QUERY_TEXT2 := REPLACE(l_QUERY_TEXT2,'--','');

     IF l_QUERY_TEXT1 IS NULL AND l_QUERY_TEXT2 IS NULL THEN
       CSM_UTIL_PKG.LOG( 'Error in VALIDATE_QUERY for Query Id : ' || p_QUERY_ID, 'VALIDATE_QUERY',
        FND_LOG.LEVEL_EXCEPTION);
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := 'Query Text is Empty ';
       RETURN;
     END IF;

      IF l_QUERY_TEXT1 IS NOT NULL THEN
        IF l_QUERY_TEXT2 IS NOT NULL THEN
           --Open the Cursor
            l_qry_length1 := LENGTH(l_QUERY_TEXT1);
            l_qry_count1  := CEIL(l_qry_length1/256);

            FOR i in 1..l_qry_count1 LOOP

            l_query_lst(i) := substr(l_QUERY_TEXT1,(((i-1)*256)+1),((i)*256));

            END LOOP;
            l_qry_length2 := LENGTH(l_QUERY_TEXT2);
            l_qry_count2  := CEIL(l_qry_length2/256);
            FOR i in 1..l_qry_count2 LOOP

            l_query_lst(l_qry_count1 + i) := substr(l_QUERY_TEXT2,(((i-1)*256)+1),((i)*256));

            END LOOP;
            l_qry_tot_count := l_qry_count1 + l_qry_count2;
            cursor_name := dbms_sql.open_cursor;
            dbms_sql.parse(cursor_name, l_query_lst, 1, l_qry_tot_count, NULL, dbms_sql.native);
            dbms_sql.close_cursor(cursor_name);
        ELSE
           --Open the Cursor
            cursor_name := dbms_sql.open_cursor;
            dbms_sql.parse(cursor_name, l_QUERY_TEXT1,dbms_sql.native);
            dbms_sql.close_cursor(cursor_name);
        END IF;

        CSM_UTIL_PKG.LOG
        ( 'Leaving VALIDATE_QUERY for Query Id  : ' || p_QUERY_ID  ,
          FND_LOG.LEVEL_ERROR);

        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  dbms_sql.close_cursor(cursor_name);
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in VALIDATE_QUERY for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'VALIDATE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Validation Failed With Message : ' || SQLERRM ;
END VALIDATE_QUERY;



/***
  This procedure can be used to Execute a given query
***/
PROCEDURE EXECUTE_QUERY
( p_USER_ID              IN NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  p_source_module        IN  VARCHAR2 DEFAULT 'MOBILEADMIN'
)
AS
CURSOR c_check_query(c_QUERY_ID NUMBER)
IS
SELECT
QUERY_TEXT1,
QUERY_TEXT2,
QUERY_TYPE,
WORK_FLOW,
PROCEDURE_NAME
FROM  CSM_QUERY_B
WHERE QUERY_ID =c_QUERY_ID;

CURSOR c_check_instance(c_USER_ID NUMBER,c_QUERY_ID NUMBER,c_INSTANCE_ID NUMBER)
IS
SELECT INSTANCE_ID
FROM  CSM_QUERY_INSTANCES_ACC
WHERE QUERY_ID    = c_QUERY_ID
AND   USER_ID     = c_USER_ID
AND   INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_get_variables (c_USER_ID NUMBER,c_QUERY_ID NUMBER,c_INSTANCE_ID NUMBER)
IS
SELECT  vacc.VARIABLE_ID,
NVL(vacc.VARIABLE_VALUE_CHAR,vb.VARIABLE_VALUE_CHAR) as VARIABLE_VALUE_CHAR,
NVL(vacc.VARIABLE_VALUE_DATE,vb.VARIABLE_VALUE_DATE) as VARIABLE_VALUE_DATE,
vb.VARIABLE_TYPE,
vb.VARIABLE_NAME
FROM
CSM_QUERY_INSTANCES_ACC iacc,
CSM_QUERY_VARIABLE_VALUES_ACC vacc,
CSM_QUERY_VARIABLES_B     vb
WHERE iacc.USER_ID     = vacc.USER_ID
AND   iacc.QUERY_ID    = vacc.QUERY_ID
AND   iacc.INSTANCE_ID = vacc.INSTANCE_ID
AND   vacc.QUERY_ID    = vb.QUERY_ID
AND   vacc.VARIABLE_ID = vb.VARIABLE_ID
AND   iacc.USER_ID     = c_USER_ID
AND   iacc.QUERY_ID    = c_QUERY_ID
AND   iacc.INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_check_results(c_USER_ID NUMBER,c_QUERY_ID NUMBER,c_INSTANCE_ID NUMBER)
IS
SELECT ACCESS_ID
FROM  CSM_QUERY_RESULTS_ACC
WHERE QUERY_ID    = c_QUERY_ID
AND   USER_ID     = c_USER_ID
AND   INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_get_wf_root (c_process_item_type VARCHAR2)
IS
SELECT ACTIVITY_NAME
FROM   WF_PROCESS_ACTIVITIES
WHERE  process_item_type =c_process_item_type
AND    PROCESS_NAME ='ROOT';

 l_query_lst      dbms_sql.varchar2s;
 l_qry_length1    NUMBER;
 l_qry_length2    NUMBER;
 l_qry_count1     NUMBER;
 l_qry_count2     NUMBER;
 l_qry_tot_count  NUMBER;
 l_QUERY_TEXT1    VARCHAR2(4000);
 l_QUERY_TEXT2    VARCHAR2(4000);
 l_file           Utl_File.File_Type;
 l_xml            CLOB;
 l_xml_blob       BLOB;
 l_more           BOOLEAN := TRUE;
 l_query_using    VARCHAR2(4000);
 rows_processed   INTEGER;
 qrycontext       DBMS_XMLGEN.ctxHandle;
 l_instance_id    NUMBER;
 l_dest_offset    NUMBER := 1;
 l_Src_offset     NUMBER := 1;
 l_language       NUMBER := 0;
 l_warning        NUMBER := 0;
 l_access_id      NUMBER;
 l_mark_dirty     BOOLEAN;
 l_rs_access_id   NUMBER;
 l_QUERY_TYPE     VARCHAR2(255);
 l_item_type      VARCHAR2(8);
 l_item_key       VARCHAR2(240);
 l_WORK_FLOW      VARCHAR2(255);
 l_root_process   VARCHAR2(255);
 l_cursor_name          INTEGER;
 l_cursor_ret           INTEGER;
 l_PROCEDURE_NAME       VARCHAR2(255);
 l_procedure_stmt       VARCHAR2(32767);
 l_variable_id_lst      CSM_INTEGER_LIST;
 l_var_value_char_lst   CSM_VARCHAR_LIST;
 l_var_value_date_lst   CSM_DATE_LIST;
 l_var_type_lst         CSM_VARCHAR_LIST;
 l_var_name_lst         CSM_VARCHAR_LIST;
 l_return_status        VARCHAR2(4000);
 l_return_message       VARCHAR2(4000);
 i                      NUMBER;
 l_bind_count           NUMBER;

BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering EXECUTE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
    SAVEPOINT EXECUTE_QUERY;

    --Query Execution status update
    UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      SYSDATE,NULL,'RUNNING',NULL);
    OPEN  c_check_query(p_QUERY_ID);
    FETCH c_check_query INTO l_QUERY_TEXT1, l_QUERY_TEXT2,l_QUERY_TYPE,l_WORK_FLOW, l_PROCEDURE_NAME;
    IF c_check_query%NOTFOUND THEN
      CSM_UTIL_PKG.LOG( 'Invalid Query Id : ' || p_QUERY_ID  ,FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Invalid Query Id : ' || p_QUERY_ID ;
      CLOSE c_check_query;
      ROLLBACK TO EXECUTE_QUERY;
      RETURN;
    END IF;
    CLOSE   c_check_query;

    --Remove the concat string from Front end
    --l_QUERY_TEXT1 := REPLACE(l_QUERY_TEXT1,'--','');
    --l_QUERY_TEXT2 := REPLACE(l_QUERY_TEXT2,'--','');

    OPEN  c_check_instance(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_check_instance INTO l_instance_id;
    IF c_check_instance%NOTFOUND THEN
      CSM_UTIL_PKG.LOG( 'The User : ' || p_USER_ID || ' does not have valid Instance ID : ' || p_INSTANCE_ID  ,FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'The User : ' || p_USER_ID || ' does not have valid Instance ID : ' || p_INSTANCE_ID ;
      CLOSE c_check_instance;
      ROLLBACK TO EXECUTE_QUERY;
      RETURN;
    END IF;
    CLOSE c_check_instance;

    OPEN  c_check_results(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_check_results INTO l_rs_access_id;
    CLOSE c_check_results;

    IF (UPPER(l_QUERY_TYPE) ='SQL' OR UPPER(l_QUERY_TYPE) ='PROCEDURE') THEN

      IF UPPER(l_QUERY_TYPE) = 'SQL' THEN

        qrycontext := DBMS_XMLGEN.newcontext(l_QUERY_TEXT1 || l_QUERY_TEXT2) ;

        FOR l_variable_rec IN c_get_variables(p_USER_ID,p_QUERY_ID,p_INSTANCE_ID)
        LOOP
          IF UPPER(l_variable_rec.VARIABLE_TYPE) = 'DATE'  THEN
            DBMS_XMLGEN.setbindvalue (qrycontext, l_variable_rec.VARIABLE_ID, l_variable_rec.VARIABLE_VALUE_DATE);
          ELSE
            DBMS_XMLGEN.setbindvalue (qrycontext, l_variable_rec.VARIABLE_ID, l_variable_rec.VARIABLE_VALUE_CHAR);
          END IF;
        END LOOP;
        DBMS_XMLGEN.setnullhandling (qrycontext, DBMS_XMLGEN.empty_tag);
         --Execute the SQL query
        l_xml := DBMS_XMLGEN.getxml (qrycontext);

      END IF;

      IF UPPER(l_QUERY_TYPE) ='PROCEDURE' THEN

          l_cursor_name := DBMS_SQL.OPEN_CURSOR;
          l_procedure_stmt := 'BEGIN ' || l_PROCEDURE_NAME || '(' ;

          OPEN c_get_variables(p_USER_ID,p_QUERY_ID,p_INSTANCE_ID);
          FETCH c_get_variables BULK COLLECT INTO  l_variable_id_lst, l_var_value_char_lst, l_var_value_date_lst, l_var_type_lst, l_var_name_lst;
          CLOSE c_get_variables;

          l_bind_count := l_variable_id_lst.COUNT;
          FOR i IN 1..l_bind_count LOOP
            l_procedure_stmt := l_procedure_stmt || ':' || i || ',';
          END LOOP;

          l_procedure_stmt := l_procedure_stmt || ':' || TO_CHAR(l_bind_count + 1) || ',';
          l_procedure_stmt := l_procedure_stmt || ':' || TO_CHAR(l_bind_count + 2) || ',';
          l_procedure_stmt := l_procedure_stmt || ':' || TO_CHAR(l_bind_count + 3) || '); END;';

          DBMS_SQL.PARSE (l_cursor_name, l_procedure_stmt, DBMS_SQL.NATIVE);

          FOR i IN 1..l_variable_id_lst.COUNT LOOP
            IF UPPER(l_var_type_lst(i)) = 'DATE' THEN
              DBMS_SQL.BIND_VARIABLE (l_cursor_name, ':'|| i, l_var_value_date_lst(i));
            ELSE
              DBMS_SQL.BIND_VARIABLE (l_cursor_name, ':'|| i, l_var_value_char_lst(i));
            END IF;
          END LOOP;

          DBMS_SQL.BIND_VARIABLE (l_cursor_name, ':'|| TO_CHAR(l_bind_count + 1), l_xml);
          DBMS_SQL.BIND_VARIABLE (l_cursor_name, ':'|| TO_CHAR(l_bind_count + 2), l_return_status,4000);
          DBMS_SQL.BIND_VARIABLE (l_cursor_name, ':'|| TO_CHAR(l_bind_count + 3), l_return_message,4000);

          l_cursor_ret := DBMS_SQL.EXECUTE ( l_cursor_name );

          DBMS_SQL.VARIABLE_VALUE(l_cursor_name, ':'|| TO_CHAR(l_bind_count + 1), l_xml);
          DBMS_SQL.VARIABLE_VALUE(l_cursor_name, ':'|| TO_CHAR(l_bind_count + 2), l_return_status);
          DBMS_SQL.VARIABLE_VALUE(l_cursor_name, ':'|| TO_CHAR(l_bind_count + 3), l_return_message);

          DBMS_SQL.CLOSE_CURSOR (l_cursor_name);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      NULL,SYSDATE,'ERROR','Query Completed with Error: '||SUBSTR(l_return_message,1,3000));
            x_error_message := l_return_message;
            RETURN;
          END IF;
      END IF;

      IF DBMS_LOB.GETLENGTH(l_xml) > 0 THEN
        --Convert the XML output into BLOB and store it in the DB
        dbms_lob.createtemporary(l_xml_blob,TRUE);
        DBMS_LOB.convertToBlob(l_xml_blob,l_xml,DBMS_LOB.LOBMAXSIZE,
                          l_dest_offset,l_src_offset,DBMS_LOB.default_csid,l_language,l_warning);
        IF l_rs_access_id IS NOT NULL THEN
          UPDATE CSM_QUERY_RESULTS_ACC
          SET RESULT           = l_xml_blob,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATED_BY  = fnd_global.user_id
          WHERE ACCESS_ID = l_rs_access_id;

          l_access_id := l_rs_access_id;
        ELSE

          INSERT INTO  CSM_QUERY_RESULTS_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , LINE_ID,
                    RESULT ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
          VALUES       (CSM_QUERY_RESULTS_ACC_S.NEXTVAL, p_USER_ID, p_QUERY_ID, p_INSTANCE_ID, 1,
                    l_xml_blob, fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id)
          RETURNING ACCESS_ID into l_access_id;

        END IF;
      ELSE--empty results
        IF l_rs_access_id IS NOT NULL THEN
          UPDATE CSM_QUERY_RESULTS_ACC
          SET RESULT           = EMPTY_BLOB(),
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATED_BY  = fnd_global.user_id
          WHERE ACCESS_ID = l_rs_access_id;

          l_access_id := l_rs_access_id;
        ELSE
          INSERT INTO  CSM_QUERY_RESULTS_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , LINE_ID,
                    RESULT ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
          VALUES       (CSM_QUERY_RESULTS_ACC_S.NEXTVAL, p_USER_ID, p_QUERY_ID, p_INSTANCE_ID, 1,
                    EMPTY_BLOB(), fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id)
          RETURNING ACCESS_ID into l_access_id;
        END IF;

      END IF;

        IF csm_util_pkg.is_palm_user(p_USER_ID)  THEN
            IF l_rs_access_id IS NULL THEN
                l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                     p_accessid    => l_access_id,
                                                     p_userid      => p_USER_ID,
                                                     p_dml         => asg_download.ins,
                                                     p_timestamp   => sysdate);
            ELSE
                l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                     p_accessid    => l_access_id,
                                                     p_userid      => p_USER_ID,
                                                     p_dml         => asg_download.upd,
                                                     p_timestamp   => sysdate);

            END IF;
        END IF;

        UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      NULL,SYSDATE,'EXECUTED','Query Successfully Executed');

    ELSIF UPPER(l_QUERY_TYPE) ='WORKFLOW' THEN

      l_item_type := SUBSTR(l_WORK_FLOW,1,8);
      l_item_key  := SUBSTR(l_WORK_FLOW,1,8)||':' ||p_INSTANCE_ID ;

      OPEN  c_get_wf_root(l_item_type);
      FETCH c_get_wf_root INTO l_root_process;
      IF c_get_wf_root%NOTFOUND THEN
        CSM_UTIL_PKG.LOG( 'The Workflow : ' || l_item_type || ' does not have valid Root Process  '  ,FND_LOG.LEVEL_ERROR);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'The Workflow : ' || l_item_type || ' does not have valid Root Process  ' ;
        CLOSE c_get_wf_root;
        ROLLBACK TO EXECUTE_QUERY;
        RETURN;
      END IF;
      CLOSE c_get_wf_root;


      wf_engine.createprocess(l_item_type, l_item_key,l_root_process);

      wf_engine.setitemuserkey(itemtype => l_item_type
                              ,itemkey  => l_item_key
                              ,userkey  => 'USERKEY: ' || l_item_key);
      wf_engine.setitemowner(itemtype => l_item_type
                            ,itemkey  => l_item_key
                            ,owner    => 'SYSADMIN');

      --Set the  Default Variables
      wf_engine.setitemattrText(itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'USER_ID'
                       ,avalue   => p_USER_ID);

      wf_engine.setitemattrText(itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'QUERY_ID'
                       ,avalue   => p_QUERY_ID);

      wf_engine.setitemattrText(itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'INSTANCE_ID'
                       ,avalue   => p_INSTANCE_ID);

      --Set the parmeters for the Workflow
      FOR l_variable_rec IN c_get_variables(p_USER_ID,p_QUERY_ID,p_INSTANCE_ID)
      LOOP
        IF UPPER(l_variable_rec.VARIABLE_TYPE) = 'DATE'  THEN
                wf_engine.setitemattrDate(itemtype => l_item_type
                                 ,itemkey  => l_item_key
                                 ,aname    => l_variable_rec.VARIABLE_NAME
                                 ,avalue   => l_variable_rec.VARIABLE_VALUE_DATE);
        ELSE
                wf_engine.setitemattrText(itemtype => l_item_type
                                 ,itemkey  => l_item_key
                                 ,aname    => l_variable_rec.VARIABLE_NAME
                                 ,avalue   => l_variable_rec.VARIABLE_VALUE_CHAR);
        END IF;
      END LOOP;
      wf_engine.startprocess(l_item_type, l_item_key);
      --update Work flow status as running
      UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      NULL,SYSDATE,'RUNNING','Query Successfully Executed');

    END IF;--Query Type

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

	 IF UPPER(l_QUERY_TYPE) ='SQL' AND l_rs_access_id IS NULL THEN
	   --Notify user for auto sync on New Query result
       CSM_WF_PKG.RAISE_START_AUTO_SYNC_EVENT('CSM_QUERY_RESULTS',to_char(p_INSTANCE_ID),'NEW');
    END IF;


    CSM_UTIL_PKG.LOG
    ( 'Leaving EXECUTE_QUERY for Query Id and Instance Id after successfully Executing :
    ' || p_QUERY_ID ||  '-' || p_INSTANCE_ID ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/

  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in EXECUTE_QUERY for Instance id : ' || p_INSTANCE_ID  ||  SUBSTR(SQLERRM,1,3000), 'EXECUTE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Execution Failed With Message : ' || SUBSTR(SQLERRM,1,3000) ;
  IF FND_API.To_Boolean(p_commit) AND p_source_module ='MOBILEADMIN' THEN
    UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      NULL,SYSDATE,'ERROR','Query Completed with Error'||SUBSTR(SQLERRM,1,3000) );
     COMMIT WORK;
  ELSE
    ROLLBACK TO EXECUTE_QUERY;
  END IF;
END EXECUTE_QUERY;

--Procedure to Create a Instance for a Given Query and store in the Acc table

PROCEDURE INSERT_INSTANCE
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_INSTANCE_NAME        IN  VARCHAR2,
  p_VARIABLE_ID          IN  CSM_INTEGER_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_INSTANCE_ID          OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_check_query(c_QUERY_ID NUMBER)
IS
SELECT QUERY_NAME,LEVEL_ID,LEVEL_VALUE,QUERY_TYPE
FROM   CSM_QUERY_B
WHERE  QUERY_ID =c_QUERY_ID
AND    NVL(DELETE_FLAG,'N') = 'N';

CURSOR c_check_query_acc(c_QUERY_ID NUMBER, c_USER_ID NUMBER)
IS
SELECT QUERY_ID
FROM   CSM_QUERY_ACC
WHERE  QUERY_ID = c_QUERY_ID
AND    USER_ID  = c_USER_ID;

CURSOR c_get_variables (c_QUERY_ID NUMBER)
IS
SELECT  vb.VARIABLE_ID,
vb.VARIABLE_VALUE_CHAR,
vb.VARIABLE_VALUE_DATE,
vb.VARIABLE_TYPE
FROM  CSM_QUERY_VARIABLES_B     vb
WHERE vb.QUERY_ID = c_QUERY_ID;

CURSOR c_get_next_instance
IS
SELECT CSM_QUERY_INSTANCES_ACC_S.NEXTVAL
FROM DUAL;

CURSOR c_get_next_qvariableid
IS
SELECT CSM_QUERY_VARIABLE_VAL_ACC_S.NEXTVAL
FROM DUAL;

 l_variable_id_lst    CSM_INTEGER_LIST;
 l_var_value_char_lst CSM_VARCHAR_LIST;
 l_var_value_date_lst CSM_DATE_LIST;
 l_var_type_lst       CSM_VARCHAR_LIST;
 l_query_id         NUMBER;
 l_variable_cnt     NUMBER;
 l_ins_variable_cnt NUMBER;
 l_instance_name    VARCHAR2(255);
 l_instance_id      NUMBER;
 l_access_id        NUMBER;
 l_mark_dirty       BOOLEAN;
 l_dummy_qry_id     NUMBER;
 l_qvariable_id     NUMBER;
 l_level_id         NUMBER;
 l_level_value      NUMBER;
 l_responsibility_id NUMBER := NULL;
 l_return_status   VARCHAR2(4000);
 l_return_message  VARCHAR2(4000);
 l_query_type      VARCHAR2(255);
 l_VARIABLE_VALUE_CHAR VARCHAR2(4000);
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

    OPEN  c_check_query(p_QUERY_ID);
    FETCH c_check_query INTO l_instance_name, l_level_id, l_level_value,l_query_type;
    IF c_check_query%NOTFOUND THEN
      CSM_UTIL_PKG.LOG( 'Invalid Query Id : ' || p_QUERY_ID  ,FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Invalid Query Id : ' || p_QUERY_ID ;
      CLOSE c_check_query;
      RETURN;
    END IF;
    CLOSE   c_check_query;

    IF l_level_id = 10003 THEN
      l_responsibility_id := l_level_value;
    END IF;
    IF l_query_type ='SQL' THEN
        --Validate the Access to a Query
      VALIDATE_ACCESS( p_QUERY_ID         => p_QUERY_ID,
                      p_QUERY_TEXT1       => NULL,
                      p_QUERY_TEXT2       => NULL,
                      p_RESPONSIBILITY_ID => l_responsibility_id,
                      x_return_status     => l_return_status,
                      x_error_message     => l_return_message);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred in VALIDATE_ACCESS for Query Name ' || l_instance_name ||  SQLERRM, 'INSERT_INSTANCE',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Query Access Validation failed : ' || l_return_message;

        RETURN;
      END IF;
    END IF;
    /*OPEN  c_check_query_acc(p_QUERY_ID, p_USER_ID);
    FETCH c_check_query_acc INTO l_dummy_qry_id;
    IF c_check_query_acc%NOTFOUND THEN
      CSM_UTIL_PKG.LOG( 'User does not have access to the Query Id : ' || p_QUERY_ID  ,FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'User does not have access to the Query Id : ' || p_QUERY_ID ||
                         '. Please run the Concurrent program and try again';
      CLOSE c_check_query_acc;
      RETURN;
    END IF;
    CLOSE   c_check_query_acc;*/

    SAVEPOINT INSERT_INSTANCE;

    IF p_INSTANCE_NAME IS NOT NULL THEN
      l_instance_name := p_INSTANCE_NAME;
    ELSE
      l_instance_name := l_instance_name || p_USER_ID || ':'|| p_QUERY_ID;
    END IF;

    IF p_INSTANCE_ID IS NULL THEN
      OPEN  c_get_next_instance;
      FETCH c_get_next_instance INTO l_instance_id;
      CLOSE c_get_next_instance;
    ELSE
      l_instance_id:= p_INSTANCE_ID;
    END IF;
    --Insert the Instance
    INSERT INTO  CSM_QUERY_INSTANCES_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , INSTANCE_NAME,STATUS,
              CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    VALUES     (l_instance_id, p_USER_ID, p_QUERY_ID, l_instance_id,l_instance_name,'OPEN',
               fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id);


    IF csm_util_pkg.is_palm_user(p_USER_ID) THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qins,
                                                 p_accessid    => l_instance_id, --same as access id
                                                 p_userid      => p_USER_ID,
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => sysdate);
    END IF;

    --set the newly created instance id
    x_INSTANCE_ID := l_instance_id;

    OPEN  c_get_variables (p_QUERY_ID);
    FETCH c_get_variables BULK COLLECT INTO l_variable_id_lst, l_var_value_char_lst, l_var_value_date_lst, l_var_type_lst;
    CLOSE c_get_variables;

    IF l_variable_id_lst.COUNT = 0 THEN

      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
      CSM_UTIL_PKG.LOG
      ( 'Leaving INSERT_INSTANCE for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_error_message := 'Leaving INSERT_INSTANCE for Query Id  : ' || p_QUERY_ID ;
      RETURN;

    END IF;

    IF l_variable_id_lst.COUNT <> p_VARIABLE_ID.COUNT THEN
       CSM_UTIL_PKG.LOG
      ( 'Variable Count mismatch.Leaving INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Leaving INSERT_INSTANCE for Query Id  : ' || p_QUERY_ID ;
      ROLLBACK TO INSERT_INSTANCE;
      RETURN;
    END IF;
    --Check if the values send are proper according to the Type
    FOR i in 1..p_VARIABLE_ID.COUNT LOOP
      IF UPPER(l_var_type_lst(i)) = 'DATE' THEN
          IF p_VARIABLE_VALUE_DATE(i) IS NULL THEN
            CSM_UTIL_PKG.LOG
            ( 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ,
              FND_LOG.LEVEL_ERROR);
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id  : ' || p_QUERY_ID ;
            ROLLBACK TO INSERT_INSTANCE;
            RETURN;
          END IF;
      ELSE

          IF p_VARIABLE_VALUE_CHAR(i) IS NULL THEN
            CSM_UTIL_PKG.LOG
            ( 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ,
              FND_LOG.LEVEL_ERROR);
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := 'Variable Value sent not matching with Type.Leaving INSERT_INSTANCE for Query Id  : ' || p_QUERY_ID ;

            ROLLBACK TO INSERT_INSTANCE;
            RETURN;
          END IF;
      END IF;

    END LOOP;

    --Insert into variable values table
    FOR i in 1..p_VARIABLE_ID.COUNT LOOP

      OPEN  c_get_next_qvariableid;
      FETCH c_get_next_qvariableid INTO l_qvariable_id;
      CLOSE c_get_next_qvariableid;

      l_VARIABLE_VALUE_CHAR := SUBSTR(p_VARIABLE_VALUE_CHAR(i),1, 4000);

      INSERT INTO  CSM_QUERY_VARIABLE_VALUES_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,
                INSTANCE_ID , VARIABLE_ID,VARIABLE_VALUE_CHAR,VARIABLE_VALUE_DATE,
                CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,GEN_PK)
      VALUES     (l_qvariable_id, p_USER_ID, p_QUERY_ID,
                  l_instance_id,  i, l_VARIABLE_VALUE_CHAR, p_VARIABLE_VALUE_DATE(i),
                 fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id,l_qvariable_id)
      RETURNING ACCESS_ID into l_access_id;

      IF csm_util_pkg.is_palm_user(p_USER_ID) THEN
              l_mark_dirty := asg_Download.mark_dirty(p_pub_item => g_pub_item_qval,
                                                   p_accessid    => l_access_id,
                                                   p_userid      => p_USER_ID,
                                                   p_dml         => asg_download.ins,
                                                   p_timestamp   => sysdate);
      END IF;
    END LOOP;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_INSTANCE_ID := l_instance_id;
    CSM_UTIL_PKG.LOG
    ( 'Leaving INSERT_INSTANCE for Query Id and Query Name : ' || p_QUERY_ID  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := 'Insert Successful for  Instance Id : ' || p_INSTANCE_ID ;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'INSERT_INSTANCE',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Exception occurred in INSERT_INSTANCE With Message : ' || SUBSTR(SQLERRM,1,3000) ;

  ROLLBACK TO INSERT_INSTANCE;
END INSERT_INSTANCE;

/***
  This procedure can be used to validate a given query
***/
PROCEDURE VALIDATE_ACCESS
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_QUERY_TEXT1          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_TEXT2          IN  VARCHAR2 DEFAULT NULL,
  p_RESPONSIBILITY_ID    IN  NUMBER   DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
 cursor_name INTEGER;
 TYPE TABLE_TYPE IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;
 l_query_lst     dbms_sql.varchar2s;
 l_qry_length1   NUMBER;
 l_qry_length2   NUMBER;
 l_qry_count1    NUMBER;
 l_qry_count2    NUMBER;
 l_qry_tot_count NUMBER;
 l_QUERY_TEXT1   VARCHAR2(4000);
 l_QUERY_TEXT2   VARCHAR2(4000);
 l_from_count    NUMBER;
 l_found_from_num NUMBER;
 i                NUMBER;
 l_MQ_SCHEMA     VARCHAR2(30);
 l_dummy         NUMBER;
 l_TABLE_STR     VARCHAR2(4000);
 l_str_length    NUMBER;
 l_end_num       NUMBER;
 l_TABLE_LIST    TABLE_TYPE;
 l_from_start    NUMBER;
 l_where_start     NUMBER;
 l_query_clob    CLOB;
 l_temp_query_clob    CLOB;
 CURSOR c_get_query_txt (c_QUERY_ID NUMBER)
 IS
 SELECT QUERY_TEXT1,QUERY_TEXT2
 FROM   CSM_QUERY_B
 WHERE  QUERY_ID = c_QUERY_ID;

 CURSOR c_check_table_access (c_schema VARCHAR2,c_object_name VARCHAR2)
 IS
 SELECT 1 FROM ALL_OBJECTS
 WHERE  OBJECT_NAME = c_object_name
 AND    OWNER       = c_schema
 AND    OBJECT_TYPE IN('TABLE','VIEW','SYNONYM');

BEGIN
      CSM_UTIL_PKG.LOG
      ( 'Entering VALIDATE_ACCESS for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
     --Get profile Value
     l_MQ_SCHEMA := UPPER(CSM_PROFILE_PKG.Get_Mobile_Query_Schema(p_RESPONSIBILITY_ID));

     IF l_MQ_SCHEMA IS NULL THEN
       CSM_UTIL_PKG.LOG( 'Error in VALIDATE_ACCESS for Query Id : ' || p_QUERY_ID, 'VALIDATE_ACCESS',
        FND_LOG.LEVEL_EXCEPTION);
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := 'The Schema to Execute the Query is Null.Please set the profile CSM: Mobile Query Schema Name';

       RETURN;
     END IF;

     l_QUERY_TEXT1 := p_QUERY_TEXT1;
     l_QUERY_TEXT2 := p_QUERY_TEXT2;

     --if the Query text is empty get the query text using the query id from the table
     IF l_QUERY_TEXT1 IS NULL AND l_QUERY_TEXT2 IS NULL THEN
      OPEN  c_get_query_txt(p_QUERY_ID);
      FETCH c_get_query_txt INTO l_QUERY_TEXT1,l_QUERY_TEXT2;
      CLOSE c_get_query_txt;
     END IF;

     IF l_QUERY_TEXT1 IS NULL AND l_QUERY_TEXT2 IS NULL THEN
       CSM_UTIL_PKG.LOG( 'Error in VALIDATE_ACCESS for Query Id : ' || p_QUERY_ID, 'VALIDATE_ACCESS',
        FND_LOG.LEVEL_EXCEPTION);
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := 'Query Text is Empty ';
       RETURN;
     END IF;
    l_query_clob :=  l_QUERY_TEXT1 || l_QUERY_TEXT2;

    IF l_query_clob IS NOT NULL THEN
       l_from_count := 0;
       --l_query_clob := REPLACE(l_query_clob,'--','');
       l_temp_query_clob := l_query_clob;
        --get total FROM in the Query
       LOOP
          l_from_count         := l_from_count+1;
          l_found_from_num     := INSTR(UPPER(l_temp_query_clob),' FROM ',1,l_from_count);
          EXIT WHEN  l_found_from_num  = 0;
       END LOOP;

       IF  l_from_count-1 = 0 THEN
         CSM_UTIL_PKG.LOG( 'Error in VALIDATE_ACCESS for Query Id : ' || p_QUERY_ID, 'VALIDATE_ACCESS',
          FND_LOG.LEVEL_EXCEPTION);
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message := 'Query Does not have any From Please check the Query ';

         RETURN;
       END IF;
       --For all the From Get the Tables in a table_list
       i := 1;

       FOR j IN 1..l_from_count-1 LOOP
          l_where_start :=  INSTR(UPPER(l_temp_query_clob),' WHERE ');
          l_from_start  :=  INSTR(UPPER(l_temp_query_clob),' FROM ')+ 6;
          --to support Queries without where condition
          IF l_where_start =0 THEN
            l_where_start := LENGTH(l_temp_query_clob);
          END IF;

          l_TABLE_STR  := SUBSTR(l_temp_query_clob,l_from_start,l_where_start-l_from_start);
          l_temp_query_clob := SUBSTR(l_temp_query_clob,l_where_start+7,LENGTH(l_temp_query_clob));
          LOOP
            l_str_length := LENGTH(l_TABLE_STR);
            l_end_num    := INSTR(l_TABLE_STR,',',1);
            IF l_end_num = 0 THEN
              IF INSTR(l_TABLE_STR,' ',1) > 0 THEN
                l_TABLE_LIST(i)      :=  LTRIM(SUBSTR(l_TABLE_STR,1,INSTR(l_TABLE_STR,' ',1)-1));
              ELSE
                l_TABLE_LIST(i)      :=  LTRIM(l_TABLE_STR);
              END IF;
            ELSE
              l_TABLE_LIST(i)      := SUBSTR(l_TABLE_STR,1,l_end_num-1);
              l_TABLE_STR          := LTRIM(SUBSTR(l_TABLE_STR,l_end_num+1,l_str_length));
              IF INSTR(l_TABLE_LIST(i),' ',1) > 0 THEN
                l_TABLE_LIST(i)      := LTRIM(SUBSTR(l_TABLE_LIST(i),1,INSTR(l_TABLE_LIST(i),' ',1)-1));
              ELSE
                l_TABLE_LIST(i)      := LTRIM(l_TABLE_LIST(i));
              END IF;
             END IF;

            i := i+1;
            EXIT WHEN l_end_num=0;
          END LOOP; --loop to get all tables ends
       END LOOP; --For loop for all From Count Ends

       --Verify the Tables in the schema
       FOR j in 1..l_TABLE_LIST.COUNT LOOP
        OPEN  c_check_table_access (l_MQ_SCHEMA,UPPER(l_TABLE_LIST(j)));
        FETCH c_check_table_access INTO l_dummy;
        IF c_check_table_access%NOTFOUND THEN
              CSM_UTIL_PKG.LOG( 'Error in VALIDATE_ACCESS for Query Id : ' || p_QUERY_ID, 'VALIDATE_ACCESS',
                FND_LOG.LEVEL_EXCEPTION);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_error_message := 'The Object : ' || l_TABLE_LIST(j) || ' does not present in the Mobile Query Schema :' || l_MQ_SCHEMA || ' Please Check.' ;
              CLOSE c_check_table_access;
              RETURN;
        END IF;
        CLOSE c_check_table_access;
      END LOOP;

      CSM_UTIL_PKG.LOG
      ( 'Query Validation Succeeded for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_error_message := 'ACCESS VALIDATION SUCCESSFUL FOR QUERY ID : ' || p_QUERY_ID;
    END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in VALIDATE_ACCESS for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'VALIDATE_ACCESS',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Validation Failed With Message : ' || SQLERRM ;

END VALIDATE_ACCESS;

--Procedure to Delete a Instance for a Given Query

PROCEDURE DELETE_INSTANCE
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  NUMBER,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_get_instance (c_USER_ID NUMBER, c_QUERY_ID NUMBER, c_INSTANCE_ID NUMBER )
IS
SELECT  ACCESS_ID
FROM    CSM_QUERY_INSTANCES_ACC
WHERE   QUERY_ID = c_QUERY_ID
AND     USER_ID  = c_USER_ID
AND     INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_get_ins_varval (c_USER_ID NUMBER, c_QUERY_ID NUMBER, c_INSTANCE_ID NUMBER )
IS
SELECT  ACCESS_ID
FROM    CSM_QUERY_VARIABLE_VALUES_ACC
WHERE   QUERY_ID = c_QUERY_ID
AND     USER_ID  = c_USER_ID
AND     INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_get_results (c_USER_ID NUMBER, c_QUERY_ID NUMBER, c_INSTANCE_ID NUMBER )
IS
SELECT  ACCESS_ID
FROM    CSM_QUERY_RESULTS_ACC
WHERE   QUERY_ID = c_QUERY_ID
AND     USER_ID  = c_USER_ID
AND     INSTANCE_ID = c_INSTANCE_ID;

 l_access_id_list   ASG_DOWNLOAD.ACCESS_LIST;
 l_instance_name    VARCHAR2(255);
 l_access_id        NUMBER;
 l_mark_dirty       BOOLEAN;
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering DELETE_INSTANCE for Query Id : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

    SAVEPOINT DELETE_INSTANCE;

    --Delete the instance
    OPEN  c_get_instance(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_get_instance INTO l_access_id;
    CLOSE c_get_instance;

    IF l_access_id IS NULL THEN
      CSM_UTIL_PKG.LOG( 'Invalid Instance Id : ' || p_INSTANCE_ID  ,FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Invalid Instance Id : ' || p_INSTANCE_ID ;
      ROLLBACK TO DELETE_INSTANCE;
      RETURN;
    END IF;

    DELETE FROM CSM_QUERY_INSTANCES_ACC WHERE ACCESS_ID = l_access_id;

    IF csm_util_pkg.is_palm_user(p_USER_ID) THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item => g_pub_item_qins,
                                                  p_accessid    => l_access_id, --same as access id
                                                  p_userid      => p_USER_ID,
                                                  p_dml         => asg_download.del,
                                                  p_timestamp   => sysdate);
    END IF;

    --Delete the Variable Values attached to the instance
    OPEN  c_get_ins_varval(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_get_ins_varval BULK COLLECT INTO l_access_id_list;
    CLOSE c_get_ins_varval;

    FORALL  i in 1..l_access_id_list.COUNT
      DELETE FROM CSM_QUERY_VARIABLE_VALUES_ACC WHERE ACCESS_ID = l_access_id_list(i);

   IF csm_util_pkg.is_palm_user(p_USER_ID) THEN
      FOR i in 1..l_access_id_list.COUNT LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qval,
                                                 p_accessid    => l_access_id_list(i), --same as access id
                                                 p_userid      => p_USER_ID,
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => sysdate);
      END LOOP;
    END IF;

    IF l_access_id_list.COUNT > 0 THEN
      l_access_id_list.DELETE;
    END IF;
    --Delete the Results attached to the instance
    OPEN  c_get_results(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_get_results BULK COLLECT INTO l_access_id_list;
    CLOSE c_get_results;

    FORALL  i in 1..l_access_id_list.COUNT
      DELETE FROM CSM_QUERY_RESULTS_ACC WHERE ACCESS_ID = l_access_id_list(i);

   IF csm_util_pkg.is_palm_user(p_USER_ID) THEN
      FOR i in 1..l_access_id_list.COUNT LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                 p_accessid    => l_access_id_list(i), --same as access id
                                                 p_userid      => p_USER_ID,
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => sysdate);
      END LOOP;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving DELETE_INSTANCE for Query Id and Query Name : ' || p_QUERY_ID  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := 'Delete call Successful for  Instance Id : ' || p_INSTANCE_ID ;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in DELETE_INSTANCE for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'DELETE_INSTANCE',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Exception occurred in DELETE_INSTANCE With Message : ' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK TO DELETE_INSTANCE;
END DELETE_INSTANCE;

/***
  This procedure can be used to validate a given query
***/
PROCEDURE VALIDATE_WORKFLOW
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_WORKFLOW             IN  VARCHAR2 DEFAULT NULL,
  p_VARIABLE_NAME        IN  CSM_VARCHAR_LIST,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS

 l_WORKFLOW      VARCHAR2(8);
 l_TEMP_WORKFLOW VARCHAR2(8);
 l_TEMP_VARIABLE VARCHAR2(30);
 CURSOR c_get_wf (c_query_id NUMBER)
 IS
 SELECT WORK_FLOW
 FROM  CSM_QUERY_B
 WHERE QUERY_ID = c_query_id;

 CURSOR c_get_item_type (c_work_flow VARCHAR2)
 IS
 SELECT NAME
 FROM  WF_ITEM_TYPES
 WHERE NAME = c_work_flow;

 CURSOR c_get_item_variable (c_work_flow VARCHAR2, c_variable_name VARCHAR2)
 IS
 SELECT NAME
 FROM  WF_ITEM_ATTRIBUTES
 WHERE item_type = c_work_flow
 AND   name      = c_variable_name;

BEGIN
     CSM_UTIL_PKG.LOG
      ( 'Entering VALIDATE_WORKFLOW for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);


     l_WORKFLOW := p_WORKFLOW;
     --if the Work Flow is empty get the query text using the query id from the table
     IF l_WORKFLOW IS NULL THEN
        OPEN  c_get_wf(p_QUERY_ID);
        FETCH c_get_wf INTO l_WORKFLOW;
        CLOSE c_get_wf;
     END IF;


     IF l_WORKFLOW IS NULL THEN
       CSM_UTIL_PKG.LOG( 'Error in VALIDATE_WORKFLOW for Query Id : ' || p_QUERY_ID, 'VALIDATE_WORKFLOW',
        FND_LOG.LEVEL_EXCEPTION);
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := 'Workflow Name is Empty ';
       RETURN;
     END IF;

     IF l_WORKFLOW IS NOT NULL THEN
        l_WORKFLOW := SUBSTR(p_WORKFLOW,1,8);

        OPEN  c_get_item_type(l_WORKFLOW);
        FETCH c_get_item_type  INTO l_TEMP_WORKFLOW;
        CLOSE c_get_item_type;

       IF l_TEMP_WORKFLOW IS NULL THEN
         CSM_UTIL_PKG.LOG( 'The Given Work Flow for Query Id : ' || p_QUERY_ID || ' is not Valid.', 'VALIDATE_WORKFLOW',
          FND_LOG.LEVEL_EXCEPTION);
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message := 'The given Workflow Name is not Valid. ';
         RETURN;
       END IF;
       --check if work flow parameters are valid
       IF p_VARIABLE_NAME IS NOT NULL THEN

        FOR i in 1..p_VARIABLE_NAME.COUNT LOOP
          l_TEMP_VARIABLE := NULL;
          OPEN   c_get_item_variable (l_WORKFLOW, UPPER(p_VARIABLE_NAME(i)));
          FETCH  c_get_item_variable INTO l_TEMP_VARIABLE;
          CLOSE  c_get_item_variable;

          IF l_TEMP_VARIABLE IS NULL THEN
            CSM_UTIL_PKG.LOG( 'The Variable  : ' || p_VARIABLE_NAME(i) || ' is not Valid.', 'VALIDATE_WORKFLOW',
            FND_LOG.LEVEL_EXCEPTION);
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := 'The Variable Name is not Valid : '|| p_VARIABLE_NAME(i);
            RETURN;
          END IF;

        END LOOP;
       END IF;
     END IF;


    CSM_UTIL_PKG.LOG
        ( 'Leaving VALIDATE_WORKFLOW for Query Id  : ' || p_QUERY_ID  ,
          FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in VALIDATE_WORKFLOW for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'VALIDATE_WORKFLOW',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Validation Failed With Message : ' || SQLERRM ;
END VALIDATE_WORKFLOW;

/***
  This procedure can be used to validate a given query
***/
PROCEDURE VALIDATE_PROCEDURE
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_PROCEDURE             IN  VARCHAR2 DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS

 l_PROCEDURE          VARCHAR2(240);
 l_PACKAGE_NAME       VARCHAR2(240);
 l_SCHEMA_NAME	      VARCHAR2(30);

 CURSOR c_get_procedure (c_query_id NUMBER)
 IS
 SELECT procedure_name
 FROM  CSM_QUERY_B
 WHERE QUERY_ID = c_query_id;

CURSOR c_is_package_valid (c_package_name VARCHAR2, p_schema_name VARCHAR2)
 IS
 SELECT object_name
 FROM all_objects
 WHERE object_name = c_package_name
 AND OWNER = p_schema_name
 AND object_type = 'PACKAGE'
 AND status = 'VALID';

BEGIN
     CSM_UTIL_PKG.LOG
      ( 'Entering VALIDATE_PROCEDURE for Query Id  : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
     l_PROCEDURE := p_PROCEDURE;
     --if the Work Flow is empty get the query text using the query id from the table
     IF l_PROCEDURE IS NULL THEN
        OPEN  c_get_procedure(p_QUERY_ID);
        FETCH c_get_procedure INTO l_PROCEDURE;
        CLOSE c_get_procedure;
     END IF;


     IF l_PROCEDURE IS NULL THEN
       CSM_UTIL_PKG.LOG( 'Error in VALIDATE_PROCEDURE for Query Id : ' || p_QUERY_ID, 'VALIDATE_PROCEDURE',
        FND_LOG.LEVEL_EXCEPTION);
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := 'Procedure Name is Empty ';
       RETURN;
     END IF;

     SELECT oracle_username INTO l_SCHEMA_NAME
      FROM fnd_oracle_userid
     WHERE read_only_flag = 'U';

     IF l_PROCEDURE IS NOT NULL THEN
        l_PACKAGE_NAME := SUBSTR(l_PROCEDURE, 0, INSTR(l_PROCEDURE, '.') -1);

        OPEN  c_is_package_valid(l_PACKAGE_NAME, l_SCHEMA_NAME);
        FETCH c_is_package_valid  INTO l_PACKAGE_NAME;

        IF c_is_package_valid%NOTFOUND THEN
          CSM_UTIL_PKG.LOG( 'The Given Package : ' || l_PACKAGE_NAME || ' is not Valid.', 'VALIDATE_PROCEDURE',
          FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'The Given Package for Query Id : ' || p_QUERY_ID || ' is not Valid.';
          RETURN;
        END IF;

        CLOSE c_is_package_valid;
      END IF;

      CSM_UTIL_PKG.LOG
        ( 'Leaving VALIDATE_PROCEDURE for Query Id  : ' || p_QUERY_ID  ,
          FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in VALIDATE_PROCEDURE for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'VALIDATE_WORKFLOW',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Validation Failed With Message : ' || SQLERRM ;
END VALIDATE_PROCEDURE;


PROCEDURE INSERT_RESULT
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_RESULT         IN  BLOB,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
CURSOR c_check_results(c_USER_ID NUMBER,c_QUERY_ID NUMBER,c_INSTANCE_ID NUMBER)
IS
SELECT ACCESS_ID
FROM  CSM_QUERY_RESULTS_ACC
WHERE QUERY_ID    = c_QUERY_ID
AND   USER_ID     = c_USER_ID
AND   INSTANCE_ID = c_INSTANCE_ID;

 l_access_id   NUMBER;
 l_mark_dirty  BOOLEAN;
 l_rs_access_id   NUMBER;
 g_pub_item_qres      VARCHAR2(30) := 'CSM_QUERY_RESULTS';
 l_sqlerrno VARCHAR2(200);
 l_sqlerrmsg VARCHAR2(4000);
 l_error_msg VARCHAR2(4000);


BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_QUERY_PKG.INSERT_RESULT for Instance ID: ' || p_INSTANCE_ID,
                         'CSM_QUERY_PKG.INSERT_RESULT',FND_LOG.LEVEL_PROCEDURE);

    OPEN  c_check_results(p_USER_ID, p_QUERY_ID, p_INSTANCE_ID);
    FETCH c_check_results INTO l_rs_access_id;
    CLOSE c_check_results;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT INSERT_RESULT;

    IF   p_QUERY_RESULT IS NOT NULL THEN
       IF l_rs_access_id IS NOT NULL THEN
        UPDATE CSM_QUERY_RESULTS_ACC
        SET RESULT           = p_QUERY_RESULT,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY  = fnd_global.user_id
        WHERE ACCESS_ID = l_rs_access_id;

        l_access_id := l_rs_access_id;
      ELSE

        INSERT INTO  CSM_QUERY_RESULTS_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , LINE_ID,
                  RESULT ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
        VALUES       (CSM_QUERY_RESULTS_ACC_S.NEXTVAL, p_USER_ID, p_QUERY_ID, p_INSTANCE_ID, 1,
                  p_QUERY_RESULT, fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id)
        RETURNING ACCESS_ID into l_access_id;

      END IF;
    ELSE--empty results
      IF l_rs_access_id IS NOT NULL THEN
        UPDATE CSM_QUERY_RESULTS_ACC
        SET RESULT           = EMPTY_BLOB(),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY  = fnd_global.user_id
        WHERE ACCESS_ID = l_rs_access_id;

        l_access_id := l_rs_access_id;
      ELSE
        INSERT INTO  CSM_QUERY_RESULTS_ACC(ACCESS_ID ,   USER_ID ,   QUERY_ID ,   INSTANCE_ID , LINE_ID,
                  RESULT ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
        VALUES       (CSM_QUERY_RESULTS_ACC_S.NEXTVAL, p_USER_ID, p_QUERY_ID, p_INSTANCE_ID, 1,
                  EMPTY_BLOB(), fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.login_id)
        RETURNING ACCESS_ID into l_access_id;
      END IF;

    END IF;

    IF csm_util_pkg.is_palm_user(p_USER_ID)  THEN
        IF l_rs_access_id IS NULL THEN
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                 p_accessid    => l_access_id,
                                                 p_userid      => p_USER_ID,
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => sysdate);
        ELSE
            l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                 p_accessid    => l_access_id,
                                                 p_userid      => p_USER_ID,
                                                 p_dml         => asg_download.upd,
                                                 p_timestamp   => sysdate);

        END IF;
    END IF;
    --Update the Status of the Workflow
    UPDATE_EXE_STATUS( p_USER_ID,  p_QUERY_ID,  p_INSTANCE_ID,
                      NULL,SYSDATE,'EXECUTED','Query Successfully Executed');
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
   CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_PKG.INSERT_RESULT for Instance ID : ' || p_INSTANCE_ID,
                         'CSM_QUERY_PKG.INSERT_RESULT',FND_LOG.LEVEL_EXCEPTION);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_error_message := 'Query Result Successfully Inserted into the Access Table';

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message := l_error_msg;
        l_error_msg := ' Exception in  CSM_QUERY_PKG for Instance ID :' || to_char(p_INSTANCE_ID)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_QUERY_PKG.INSERT_RESULT',FND_LOG.LEVEL_EXCEPTION);
        ROLLBACK TO INSERT_RESULT;
END INSERT_RESULT;

END CSM_QUERY_PKG; -- Package spec


/
