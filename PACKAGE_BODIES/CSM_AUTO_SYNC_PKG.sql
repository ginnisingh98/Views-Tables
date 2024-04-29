--------------------------------------------------------
--  DDL for Package Body CSM_AUTO_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_AUTO_SYNC_PKG" AS
/* $Header: csmuasb.pls 120.5.12010000.2 2009/08/06 06:14:40 hbeeram noship $ */

  /*
   * The function is to upload csm_auto_sync table to base table
   */

--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- HBEERAM     29-APR-2009          Created
--
-- ---------   -------------------  ------------------------------------------
    -- Enter procedure, function bodies as shown below

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_AUTO_SYNC_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_AUTO_SYNC';  -- publication item name
g_debug_level           NUMBER; -- debug level

g_auto_sync_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_AUTO_SYNC_ACC';
g_auto_sync_table_name            CONSTANT VARCHAR2(30) := 'CSM_AUTO_SYNC';
g_auto_sync_seq_name              CONSTANT VARCHAR2(30) := 'CSM_AUTO_SYNC_ACC_S';
g_auto_sync_pk1_name              CONSTANT VARCHAR2(30) := 'ID';
g_auto_sync_pk2_name              CONSTANT VARCHAR2(30) := 'AUTO_SYNC_NUM';
g_auto_sync_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_AUTO_SYNC');


CURSOR c_auto_sync_inq( b_user_name VARCHAR2, b_tranid NUMBER) IS
  SELECT *
  FROM  csm_auto_sync_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


PROCEDURE INSERT_AUTO_SYNC_ACC (p_id NUMBER, p_user_id   IN fnd_user.user_id%TYPE,p_auto_sync_num NUMBER)
IS
  l_sysdate 	DATE;
  l_count NUMBER;
BEGIN
    CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_auto_sync_pubi_name
     ,P_ACC_TABLE_NAME         => g_auto_sync_acc_table_name
     ,P_SEQ_NAME               => g_auto_sync_seq_name
     ,P_PK1_NAME               => g_auto_sync_pk1_name
     ,P_PK1_NUM_VALUE          => p_id
     ,P_USER_ID                => p_user_id
     ,P_PK2_NAME               => g_auto_sync_pk2_name
     ,P_PK2_NUM_VALUE          => p_auto_sync_num
    );
EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in ' || g_object_name || '.INSERT_AUTO_SYNC_ACC: '
|| SQLERRM,' for PK ' || to_char(p_id) || g_object_name || '.INSERT_AUTO_SYNC_ACC',FND_LOG.LEVEL_EXCEPTION);

  RAISE;
END INSERT_AUTO_SYNC_ACC;-- end INSERT_AUTO_SYNC_ACC

/******************************************************************************************************************/
PROCEDURE AUTO_SYNC_ACC_PROCESSOR(p_user_id IN fnd_user.user_id%TYPE)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- get all notifications in which user is a recipient
CURSOR c_id(b_user_id fnd_user.user_id%TYPE) IS
 SELECT id, auto_sync_num
 FROM   csm_auto_sync;

BEGIN
   CSM_UTIL_PKG.LOG('Entering AUTO_SYNC_ACC_PROCESSOR for user_id: ' || p_user_id,
                                   g_object_name || '.AUTO_SYNC_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);


  -- get all notifications in which user is a recipient
  FOR l_rec IN c_id(p_user_id)
  LOOP
   INSERT_AUTO_SYNC_ACC (l_rec.id, p_user_id,l_rec.auto_sync_num);
  END LOOP;


    CSM_UTIL_PKG.LOG('Leaving AUTO_SYNC_ACC_PROCESSOR for user_id: ' || p_user_id,
                                   g_object_name || '.AUTO_SYNC_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  AUTO_SYNC_ACC_PROCESSOR for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_AUTO_SYNC_PKG.AUTO_SYNC_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
        RAISE;

END AUTO_SYNC_ACC_PROCESSOR;
/******************************************************************************************************************/

-------

/***
  This procedure is called by APPLY_CRECORD when
  an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_auto_sync_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           x_reject_row    OUT NOCOPY BOOLEAN
         ) IS


  l_id    csm_auto_sync.id%TYPE  ;
  l_flag  csm_auto_sync.flag%TYPE;
  l_rowid ROWID;

 CURSOR c_record_exists
  (b_id NUMBER
  )IS SELECT ROWID
      FROM   CSM_AUTO_SYNC
      WHERE  id = b_id;



BEGIN


CSM_UTIL_PKG.log( 'Entering ' || g_object_name || '.APPLY_INSERT:'
               || ' for PK ' || p_record.id,
               'CSM_AUTO_SYNC.APPLY_INSERT',
               FND_LOG.LEVEL_PROCEDURE );

/***************************************************************************
  ** Initialize API return status to success
  ***************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
insert into csm_auto_sync(ID,FLAG,AUTO_SYNC_NUM,DOWNLOAD_ONLY,CREATION_DATE ,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY)
 values (p_record.id,p_record.flag,p_record.auto_sync_num,p_record.download_only,p_record.creation_date ,p_record.created_by,p_record.last_update_date,p_record.last_updated_by)
RETURNING ID INTO l_id;
*/
/***************************************************************************
  ** Check whether the insert was succesfull
  ***************************************************************************/
  IF (c_record_exists%ISOPEN)THEN
    CLOSE c_record_exists;
  END IF;

  OPEN c_record_exists(l_id);
  FETCH c_record_exists INTO l_rowid;
  IF (c_record_exists%NOTFOUND)THEN
    IF (c_record_exists%ISOPEN)
    THEN
      CLOSE c_record_exists;
    END IF;
    RAISE no_data_found;
  END IF;

  IF (c_record_exists%ISOPEN) THEN
    CLOSE c_record_exists;
  END IF;



  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
      || ' ROOT ERROR: create statement'
      || ' for PK ' || p_record.ID,
      g_object_name || '.APPLY_INSERT',
      FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
       || ' for PK ' || p_record.id,
       g_object_name || '.APPLY_INSERT',
       FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_INSERT;


/***
  This procedure is called by APPLY_CRECORD when
  an updated record is to be processed.
  For CSM 11583, we support updates on the DFF columns
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_auto_sync_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
--variable declarations

  l_id    csm_auto_sync.id%TYPE  ;
  l_auto_sync_num csm_auto_sync.auto_sync_num%TYPE;
  l_user_id asg_user.user_id%TYPE;

  l_rowid ROWID;

BEGIN


CSM_UTIL_PKG.log( 'Entering ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.id,
               'CSM_AUTO_SYNC.APPLY_UPDATE',
               FND_LOG.LEVEL_PROCEDURE );
  /***************************************************************************
  ** Initialize API return status to success
  ***************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

l_user_id := asg_base.get_user_id(p_record.clid$$cs);
l_auto_sync_num := p_record.auto_sync_num;
l_id := p_record.id;

/***************************************************************************
  ** Update the record
  ***************************************************************************/

UPDATE csm_auto_sync_acc
SET AUTO_SYNC_NUM = l_auto_sync_num,
LAST_UPDATE_DATE = sysdate,
LAST_UPDATED_BY	= l_user_id
where ID=l_id
and USER_ID = l_user_id;



 /***************************************************************************
  ** Check if the update was succesful
  ***************************************************************************/

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
       || ' for PK ' || p_record.id,
       g_object_name || '.APPLY_UPDATE',
       FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_UPDATE;



/*****************************************************************************************/



PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_auto_sync_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           x_reject_row    OUT NOCOPY BOOLEAN
         ) IS
BEGIN

  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.INITIALIZE;


  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status,
        x_reject_row         --Bug 5288413
      );
  ELSIF p_record.dmltype$$='U' THEN -- YLIAO: for 11583, we do support UPDATE
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
      ( 'Delete and Update is not supported for this entity'
        || ' for PK ' || p_record.id ,
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
      || ' for PK ' || p_record.id ,
      g_object_name || '.APPLY_RECORD',
      FND_LOG.LEVEL_EXCEPTION);
  -- temp -- find more detail --remove comment
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', SQLERRM);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;
----------------------------------------------------------------------------------------------------------------------

/***
  APPLY_CLIENT_CHANGE procedure is called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
  publication item CSM_AUTO_SYNC
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
  l_return_status  VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
  l_reject_row     boolean;
BEGIN
  csm_util_pkg.log ( g_object_name || '.APPLY_CLIENT_CHANGES entered',
    FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through records in inqueue ***/
  FOR r_auto_sync IN c_auto_sync_inq( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;
/**--------------------------------------------**/
    /*** apply record ***/
    APPLY_RECORD
      (
        r_auto_sync
      , l_error_msg
      , l_process_status
      , l_reject_row
      );
/***--------------------------------------------------------------**/
    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** If Yes -> delete record from inqueue ***/
      IF l_reject_row THEN
       CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_auto_sync.seqno$$,
          r_auto_sync.id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_return_status
        );
      ELSE
       CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_auto_sync.seqno$$,
          r_auto_sync.id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_return_status --Introduced new variable l_return_status since Defer
        );                --process doesn't depend on this delete_record API
      END IF;

      /*** was delete/reject successful? ***/
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** If No -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Deleting from inqueue failed, rolling back to savepoint'
          || ' for PK ' || r_auto_sync.id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF; /*** end of IF l_process_status = FND_API.G_RET_STS_SUCCESS  ***/

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed
      -> defer and reject record ***/
      CSM_UTIL_PKG.LOG
      ( 'Record not processed successfully, deferring and rejecting record'
        || ' for PK ' || r_auto_sync.id ,
        g_object_name || '.APPLY_CLIENT_CHANGES',
        FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       ( p_user_name
       , p_tranid
       , r_auto_sync.seqno$$
       , r_auto_sync.id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_auto_sync.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_auto_sync.id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;


END CSM_AUTO_SYNC_PKG;

/
