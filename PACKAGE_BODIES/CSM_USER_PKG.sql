--------------------------------------------------------
--  DDL for Package Body CSM_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_USER_PKG" AS
/* $Header: csmuusrb.pls 120.4 2006/09/28 06:35:18 rsripada noship $ */

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_USER_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_USER';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_USER_inq( b_user_name VARCHAR2, b_tranid NUMBER) IS
  SELECT *
  FROM  CSF_M_USER_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


/***
  This procedure is called by APPLY_RECORD when
  an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_user_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END APPLY_INSERT;


/***
  This procedure is called by APPLY_CRECORD when
  an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_USER_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
l_resp_app VARCHAR2(5);
l_resp_key VARCHAR2(20):='CSL_IMOBILE' ;
l_security_group VARCHAR2(20) :='STANDARD' ;
BEGIN
 csm_util_pkg.log
  ( g_object_name || '.APPLY_UPDATE entered',
    g_object_name || '.APPLY_UPDATE',
    FND_LOG.LEVEL_PROCEDURE);

  UPDATE ASG_USER
  SET  MIGRATION_COMPLETED = p_record.MIGRATION_COMPLETED,
       MIGRATION_COMPLETED_DATE = p_record.MIGRATION_COMPLETED_DATE,
       MIGRATION_COMPLETION_VERSION = p_record.MIGRATION_COMPLETION_VERSION
  WHERE USER_ID=p_record.USER_ID;

  IF(p_record.MIGRATION_COMPLETION_VERSION =  12) THEN
    SELECT APPLICATION_SHORT_NAME INTO l_resp_app FROM fnd_application WHERE APPLICATION_ID=868; --CSL
    BEGIN
      FND_USER_PKG.DELRESP(p_record.USER_NAME,l_resp_app,l_resp_key,l_security_group);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   csm_util_pkg.log
  ( 'Leaving '|| g_object_name || '.APPLY_UPDATE',
    g_object_name || '.APPLY_UPDATE',
    FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
       || ' for PK ' || p_record.user_id,
       g_object_name || '.APPLY_UPDATE',
       FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_UPDATE;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when a record
  is to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_USER_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN

  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE
    -- Process delete and insert;
    -- Not supported for this entity
    CSM_UTIL_PKG.LOG
      ( 'Delete and Insert are not supported for this entity'
        || ' for PK ' || p_record.user_id ,
        g_object_name || '.APPLY_RECORD',
        FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  CSM_UTIL_PKG.LOG
    ( 'Exception occurred in ' || g_object_name || '.APPLY_RECORD:' || ' ' || SQLERRM
      || ' for PK ' || p_record.user_id ,
      g_object_name || '.APPLY_RECORD',
      FND_LOG.LEVEL_EXCEPTION);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', SQLERRM);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;


/***
  APPLY_CLIENT_CHANGES procedure is called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
  publication item CSF_M_USER
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
  IS
  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
  r_user  c_user_inq%ROWTYPE;
BEGIN
  csm_util_pkg.log
  ( g_object_name || '.APPLY_CLIENT_CHANGES entered',
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_USER_inq( p_user_name, p_tranid);
  FETCH c_user_inq INTO r_user;
  CLOSE c_user_inq;

  IF r_user.USER_ID IS NOT NULL THEN

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_USER
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** If Yes -> delete record from inqueue ***/
      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_USER.seqno$$,
          r_USER.user_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** If No -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Deleting from inqueue failed, rolling back to savepoint'
          || ' for PK ' || r_USER.user_id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed
      -> defer and reject record ***/
      CSM_UTIL_PKG.LOG
      ( 'Record not processed successfully, deferring and rejecting record'
        || ' for PK ' || r_USER.user_id ,
        g_object_name || '.APPLY_CLIENT_CHANGES',
        FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       ( p_user_name
       , p_tranid
       , r_USER.seqno$$
       , r_USER.user_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_USER.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_USER.user_id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

END CSM_USER_PKG;

/
