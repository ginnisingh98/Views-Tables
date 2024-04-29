--------------------------------------------------------
--  DDL for Package Body CSM_QUERY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_QUERY_PUB" AS
/* $Header: csmqrypb.pls 120.0.12010000.5 2010/06/14 10:21:47 ravir noship $ */

  /*
   * The function to be called by Mobile Admin page to store defined queries
   */
-- Purpose: Store the Query Definition done in the Mobile Admin page
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- TRAJASEK     11-JUL-2009          Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

/*** Globals ***/

/***
  This procedure is called to insert a Query
***/
PROCEDURE INSERT_QUERY
(
  p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_QUERY_ID             IN  NUMBER,
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
BEGIN
     CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_QUERY for Query Name :' || p_QUERY_NAME ,
        FND_LOG.LEVEL_ERROR);

     SAVEPOINT CSM_INSERT_QUERY_PUB;

       CSM_QUERY_PKG.INSERT_QUERY
    ( p_QUERY_ID             => p_QUERY_ID,
      p_QUERY_NAME           => p_QUERY_NAME,
      P_QUERY_DESC           => p_QUERY_DESC,
      P_QUERY_TYPE           => p_QUERY_TYPE,
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
      p_EMAIL_ENABLED	     => p_EMAIL_ENABLED,
      p_RESTRICTED_FLAG      => p_RESTRICTED_FLAG,
      p_DISABLED_FLAG        => p_DISABLED_FLAG,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message);


     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           CSM_UTIL_PKG.LOG
          ( 'Error occurred in Insert Query for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'INSERT_QUERY',
            FND_LOG.LEVEL_EXCEPTION);
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Query Insert failed : ' || x_error_message;
          ROLLBACK TO CSM_INSERT_QUERY_PUB;
          RETURN;
    END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
        COMMIT WORK;
    END IF;
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
  ROLLBACK TO CSM_INSERT_QUERY_PUB;
END INSERT_QUERY;


/***
  This procedure is called  to Update a Query

***/
PROCEDURE UPDATE_QUERY
(
  p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_QUERY_ID             IN  NUMBER,
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
BEGIN
    CSM_UTIL_PKG.LOG
    ( 'Entering UPDATE_QUERY for Query Id and Query Name : ' || p_QUERY_ID || ' : ' || p_QUERY_NAME ,
      FND_LOG.LEVEL_ERROR);

     SAVEPOINT CSM_UPDATE_QUERY_PUB;

    CSM_QUERY_PKG.UPDATE_QUERY
    ( p_QUERY_ID             => p_QUERY_ID,
      p_QUERY_NAME           => p_QUERY_NAME,
      P_QUERY_DESC           => p_QUERY_DESC,
      P_QUERY_TYPE           => p_QUERY_TYPE,
      p_QUERY_TEXT1          => p_QUERY_TEXT1,
      p_QUERY_TEXT2          => p_QUERY_TEXT2,
      p_LEVEL_ID             => p_LEVEL_ID,
      p_LEVEL_VALUE          => p_LEVEL_VALUE,
      p_PARENT_QUERY_ID      => p_PARENT_QUERY_ID,
      p_SAVED_QUERY          => p_SAVED_QUERY,
      p_QUERY_OUTPUT_FORMAT  => p_QUERY_OUTPUT_FORMAT,
      p_MIME_TYPE            => p_MIME_TYPE,
      p_WORK_FLOW            => p_WORK_FLOW,
      p_PROCEDURE 	     => p_PROCEDURE,
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
      x_return_status        => x_return_status,
      x_error_message        => x_error_message);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred in UPDATE QUERY for Query Name ' || p_QUERY_NAME ||  SQLERRM, 'UPDATE_QUERY',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Query Update failed : ' || x_error_message;
        ROLLBACK TO CSM_UPDATE_QUERY_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
        COMMIT WORK;
    END IF;

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
  ROLLBACK TO CSM_UPDATE_QUERY_PUB;
END UPDATE_QUERY;

/***
  This procedure is called to Delete a Query
***/
PROCEDURE DELETE_QUERY
(
  p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_QUERY_ID             IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
      CSM_UTIL_PKG.LOG
      ( 'Entering DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

      SAVEPOINT CSM_DELETE_QUERY_PUB;

      CSM_QUERY_PKG.DELETE_QUERY
      (
        p_QUERY_ID             => p_QUERY_ID,
        x_return_status        => x_return_status,
        x_error_message        => x_error_message
      );

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred in DELETE QUERY for Query Id ' || p_QUERY_ID ||  SQLERRM, 'DELETE_QUERY',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Query Delete failed : ' || x_error_message;
        ROLLBACK TO CSM_DELETE_QUERY_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
        COMMIT WORK;
    END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := 'Delete Query Call Successful for Query id '|| p_QUERY_ID;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in DELETE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ||  SQLERRM, 'DELETE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Delete Failed for Query Id and Query Name : ' || p_QUERY_ID ;
  ROLLBACK TO CSM_DELETE_QUERY_PUB;
END DELETE_QUERY;

/***
  This procedure can be used to Execute a given query
***/
PROCEDURE EXECUTE_QUERY
( p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_USER_ID              IN NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering EXECUTE_QUERY for Query Id and Query Name : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);
    --Query Execution status update
      SAVEPOINT CSM_EXECUTE_QUERY_PUB;

      CSM_QUERY_PKG.EXECUTE_QUERY
      (
        p_USER_ID              => p_USER_ID,
        p_QUERY_ID             => p_QUERY_ID,
        p_INSTANCE_ID          => p_INSTANCE_ID,
        x_return_status        => x_return_status,
        x_error_message        => x_error_message,
        p_commit               => p_COMMIT
      );

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred in QUERY  Execution for Instance ID ' || p_INSTANCE_ID ||  SUBSTR(SQLERRM,1,3000), 'EXECUTE_QUERY',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Query Execution failed : ' || x_error_message;
        ROLLBACK TO CSM_EXECUTE_QUERY_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
        COMMIT WORK;
    END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving EXECUTE_QUERY for Query Id and Instance Id after successfully Executing :
    ' || p_QUERY_ID ||  '-' || p_INSTANCE_ID ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_error_message := 'Query Execution Successful ';
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/

  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in EXECUTE_QUERY for Instance id : ' || p_INSTANCE_ID  ||  SUBSTR(SQLERRM,1,3000), 'EXECUTE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Query Execution Failed With Message : ' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK TO CSM_EXECUTE_QUERY_PUB;
END EXECUTE_QUERY;

--Procedure to Create a Instance for a Given Query and store in the Acc table

PROCEDURE INSERT_INSTANCE
( p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_INSTANCE_NAME        IN  VARCHAR2,
  p_VARIABLE_ID          IN  CSM_INTEGER_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  x_INSTANCE_ID          OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ,
        FND_LOG.LEVEL_ERROR);

    SAVEPOINT CSM_INSERT_INSTANCE_PUB;

    CSM_QUERY_PKG.INSERT_INSTANCE
    ( p_USER_ID              => p_USER_ID,
      p_QUERY_ID             => p_QUERY_ID,
      p_INSTANCE_ID          => p_INSTANCE_ID,
      p_INSTANCE_NAME        => p_INSTANCE_NAME,
      p_VARIABLE_ID          => p_VARIABLE_ID,
      p_VARIABLE_VALUE_CHAR  => p_VARIABLE_VALUE_CHAR,
      p_VARIABLE_VALUE_DATE  => p_VARIABLE_VALUE_DATE,
      p_commit               => p_COMMIT,
      x_INSTANCE_ID          => x_INSTANCE_ID,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred  for Instance ID ' || p_INSTANCE_ID ||  SUBSTR(SQLERRM,1,3000), 'INSERT_INSTANCE',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Insert Instance failed : ' || x_error_message;
        ROLLBACK TO CSM_INSERT_INSTANCE_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
      COMMIT WORK;
    END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving INSERT_INSTANCE for Instance Id : ' || x_INSTANCE_ID  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := 'Insert Successful for  Instance Id : ' || x_INSTANCE_ID ;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in INSERT_INSTANCE for Query Id : ' || p_QUERY_ID  ||  SQLERRM, 'EXECUTE_QUERY',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Exception occurred in INSERT_INSTANCE With Message : ' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK TO CSM_INSERT_INSTANCE_PUB;
END INSERT_INSTANCE;

--Procedure to Delete a Instance for a Given Query
PROCEDURE DELETE_INSTANCE
( p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering DELETE_INSTANCE for Instance Id : ' || p_INSTANCE_ID  ,
        FND_LOG.LEVEL_ERROR);

    SAVEPOINT CSM_DELETE_INSTANCE_PUB;

    CSM_QUERY_PKG.DELETE_INSTANCE
    ( p_USER_ID              => p_USER_ID,
      p_QUERY_ID             => p_QUERY_ID,
      p_INSTANCE_ID          => p_INSTANCE_ID,
      p_commit               => p_COMMIT,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred  for Instance ID ' || p_INSTANCE_ID ||  SUBSTR(SQLERRM,1,3000), 'DELETE_INSTANCE',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Delete Instance failed : ' || x_error_message;
        ROLLBACK TO CSM_DELETE_INSTANCE_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
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
  ROLLBACK TO CSM_DELETE_INSTANCE_PUB;
END DELETE_INSTANCE;


--Public Procedure to Insert a Result once a Given Query is executed by Custom code

PROCEDURE INSERT_RESULT
( p_API_VERSION		  	   IN  NUMBER,
  p_INIT_MSG_LIST	  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_COMMIT    		  	   IN  VARCHAR2 	:= FND_API.G_FALSE,
  p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_RESULT         IN  BLOB,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
)
AS
BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering INSERT_RESULT for Instance Id : ' || p_INSTANCE_ID  ,
        FND_LOG.LEVEL_ERROR);

    SAVEPOINT CSM_INSERT_RESULT_PUB;

    CSM_QUERY_PKG.INSERT_RESULT
    ( p_USER_ID              => p_USER_ID,
      p_QUERY_ID             => p_QUERY_ID,
      p_INSTANCE_ID          => p_INSTANCE_ID,
      p_QUERY_RESULT         => p_QUERY_RESULT,
      p_commit               => p_COMMIT,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         CSM_UTIL_PKG.LOG
        ( 'Exception occurred  for Instance ID ' || p_INSTANCE_ID ||  SUBSTR(SQLERRM,1,3000), 'INSERT_RESULT',
          FND_LOG.LEVEL_EXCEPTION);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Insert Result for Instance failed : ' || x_error_message;
        ROLLBACK TO CSM_INSERT_RESULT_PUB;
        RETURN;
     END IF;

    IF FND_API.To_Boolean(p_COMMIT) THEN
      COMMIT WORK;
    END IF;

    CSM_UTIL_PKG.LOG
    ( 'Leaving INSERT_RESULT for Instance ID : ' || p_INSTANCE_ID  ,
      FND_LOG.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := 'Insert Result Successful for  Instance Id : ' || p_INSTANCE_ID ;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in INSERT_RESULT for Instance ID : ' || p_INSTANCE_ID  ||  SQLERRM, 'INSERT_RESULT',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'Exception occurred in INSERT_RESULT With Message : ' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK TO CSM_INSERT_RESULT_PUB;
END INSERT_RESULT;

END CSM_QUERY_PUB; -- Package spec

/
