--------------------------------------------------------
--  DDL for Package Body CSM_COUNTER_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_COUNTER_VALUES_PKG" AS
/* $Header: csmucvb.pls 120.5 2008/03/24 08:57:02 ptomar ship $ */


error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_COUNTER_VALUES';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_CS_COUNTER_VALUES( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSF_M_COUNTER_VALUES_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
   This procedure is called by PROCESS_REQS and deletes all requirement headers from the inqueue,
   for a given user and transaction.
***/
PROCEDURE DELETE_PROP_READ_FROM_INQ
         (
           p_user_name     IN      VARCHAR2,
           p_tranid        IN      NUMBER,
       p_ctr_val_id IN    NUMBER,
           x_return_status IN OUT NOCOPY  VARCHAR2
         ) IS

  l_error_msg VARCHAR2(4000);
  l_pub_name     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROP_VALUES';  -- publication item name
  /***
    Cursor to retrieve all requirement headers for this user_name and tranid.
    This one is to be executed after all requirement lines with headers have been deleted from the inqueue.
  ***/
  CURSOR c_get_ctr_prop_read_from_inq ( b_user_name VARCHAR2, b_tranid NUMBER, b_ctr_val_id NUMBER) is
    SELECT *
    FROM   CSM_COUNTER_PROP_VALUES_INQ inq
    WHERE  inq.tranid$$ = b_tranid
    AND    inq.clid$$cs = b_user_name
  AND    inq.COUNTER_VALUE_ID = b_ctr_val_id;
BEGIN

  CSM_UTIL_PKG.LOG
       ( 'Entering CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_STATEMENT); -- put PK column here


  -- Loop through this cursor to delete all requirement headers from the requirement header inqueue
  FOR r_get_ctr_prop_read_from_inq IN c_get_ctr_prop_read_from_inq ( p_user_name, p_tranid, p_ctr_val_id) LOOP

    -- Delete the requirement header from the requirement header inqueue.
    CSM_UTIL_PKG.DELETE_RECORD
      (
        p_user_name,
        p_tranid,
        r_get_ctr_prop_read_from_inq.seqno$$,
        r_get_ctr_prop_read_from_inq.counter_prop_value_id, -- put PK column here
        g_object_name,
        l_pub_name,
        l_error_msg,
        x_return_status
      );

    /*** was delete successful? ***/
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** no -> rollback ***/

      CSM_UTIL_PKG.LOG
       ( 'Deleting from inqueue failed, rolling back to savepoinT'|| 'for PK '||r_get_ctr_prop_read_from_inq.counter_prop_value_id,
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here

      ROLLBACK TO save_rec;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/

      CSM_UTIL_PKG.LOG
       ( 'Record not processed successfully, deferring and rejecting record'|| 'for PK '|| r_get_ctr_prop_read_from_inq.counter_prop_value_id,
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here


      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_get_ctr_prop_read_from_inq.seqno$$
       , r_get_ctr_prop_read_from_inq.counter_prop_value_id -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       , r_get_ctr_prop_read_from_inq.dmltype$$
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/

        CSM_UTIL_PKG.LOG
       ( 'Defer record failed, rolling back to savepoint'|| 'for PK '||r_get_ctr_prop_read_from_inq.counter_prop_value_id,
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here


      END IF;
    END IF;
  END LOOP;

  CSM_UTIL_PKG.LOG
       ( 'Leaving CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ ',
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_STATEMENT); -- put PK column here


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/

  CSM_UTIL_PKG.LOG
       ( 'Exception occurred in DELETE_PROP_READ_FROM_INQ: '|| FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
         'CSM_COUNTER_VALUES_PKG.DELETE_PROP_READ_FROM_INQ',
          FND_LOG.LEVEL_EXCEPTION); -- put PK column here

  RAISE;
  x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_PROP_READ_FROM_INQ;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_CS_COUNTER_VALUES%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  CURSOR c_counter_value_id (b_counter_value_id number)
  IS
  SELECT counter_value_id
  FROM   cs_counter_values
  WHERE  counter_value_id = b_counter_value_id;

  --Cursor for counter property readings
  CURSOR c_ctr_prop_value (b_counter_value_id number, c_tranid NUMBER, c_user_name VARCHAR2)
  IS
  SELECT *
  FROM   CSM_COUNTER_PROP_VALUES_INQ
  WHERE  counter_value_id = b_counter_value_id
  AND    tranid$$       = c_tranid
  AND   clid$$cs      = c_user_name;

  -- Variables needed for public API
  l_ctr_grp_log_rec_pub Cs_Ctr_Capture_Reading_Pub.Ctr_Grp_Log_Rec_Type;
  l_ctr_rdg_rec_pub     Cs_Ctr_Capture_Reading_Pub.Ctr_Rdg_Rec_Type;
  l_ctr_rdg_tbl_pub     Cs_Ctr_Capture_Reading_Pub.Ctr_Rdg_Tbl_Type;
  l_prp_rdg_rec_pub     Cs_Ctr_Capture_Reading_Pub.PROP_RDG_Rec_Type;
  l_prp_rdg_tbl_pub     Cs_Ctr_Capture_Reading_Pub.PROP_RDG_Tbl_Type;


  l_ctr_grp_id          NUMBER;
  l_ctr_grp_log_id      NUMBER;
  l_customer_product_id NUMBER;
  i           NUMBER := 0;
  l_counter_value_id NUMBER;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
  l_err_msg      VARCHAR2(4000);

--  l_server_value_timestamp date;

BEGIN

  l_err_msg := 'Entering ' || g_object_name || '.APPLY_INSERT' || ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_VALUES_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

  --anu
  --initialize return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --end anu


  -- Fill the counter_group_log record and the counter_reading record needed
  l_ctr_grp_log_rec_pub.counter_group_id        := p_record.counter_group_id;
  l_ctr_grp_log_rec_pub.value_timestamp     := p_record.value_timestamp;
  l_ctr_grp_log_rec_pub.source_transaction_id   := p_record.source_object_id; -- p_record.customer_product_id;
  l_ctr_grp_log_rec_pub.source_transaction_code := 'FS';

  -- Fill counter_reading record

  l_ctr_rdg_rec_pub.counter_value_id:= p_record.counter_value_id;
  l_ctr_rdg_rec_pub.counter_id      := p_record.counter_id;
  l_ctr_rdg_rec_pub.value_timestamp := p_record.value_timestamp;
  l_ctr_rdg_rec_pub.counter_reading := p_record.counter_reading;
  l_ctr_rdg_rec_pub.reset_flag      := p_record.reset_flag;
  l_ctr_rdg_rec_pub.reset_reason    := p_record.reset_reason;
  l_ctr_rdg_rec_pub.pre_reset_last_rdg   := p_record.pre_reset_last_rdg;
  l_ctr_rdg_rec_pub.post_reset_first_rdg := p_record.post_reset_first_rdg;
  l_ctr_rdg_rec_pub.misc_reading_type := p_record.misc_reading_type;
  l_ctr_rdg_rec_pub.misc_reading      := p_record.misc_reading;
  l_ctr_rdg_rec_pub.comments          := p_record.comments;

  l_ctr_rdg_tbl_pub(1) := l_ctr_rdg_rec_pub;

  --Filling counter property reading data if any
  FOR c_ctr_prop_value_rec in c_ctr_prop_value(p_record.counter_value_id,p_record.tranid$$,p_record.clid$$cs)
  LOOP
      l_prp_rdg_rec_pub.COUNTER_PROP_VALUE_ID := c_ctr_prop_value_rec.counter_prop_value_id;
      l_prp_rdg_rec_pub.COUNTER_PROPERTY_ID   := c_ctr_prop_value_rec.counter_property_id;
      l_prp_rdg_rec_pub.PROPERTY_VALUE        := c_ctr_prop_value_rec.PROPERTY_VALUE ;

    l_prp_rdg_tbl_pub(i+1)          := l_prp_rdg_rec_pub;

  END LOOP;
  -- Call the public API
  Cs_Ctr_Capture_Reading_Pub.Capture_Counter_Reading
      ( p_api_version_number  => 1.0
      , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
      , p_init_msg_list       => FND_API.G_TRUE
      , p_commit              => FND_API.G_FALSE
      , p_ctr_rdg_tbl         => l_ctr_rdg_tbl_pub
      , p_ctr_grp_log_rec     => l_ctr_grp_log_rec_pub
    , p_PROP_RDG_Tbl      => l_prp_rdg_tbl_pub
      , x_return_status       => x_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );

 --setting the return status to SUCCESS because of bug 2470553
   x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN  c_counter_value_id(p_record.counter_value_id);
  FETCH c_counter_value_id INTO l_counter_value_id;

  IF c_counter_value_id%FOUND THEN
    --calling counter value insert into access table after succeful insertion
    CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS(l_counter_value_id, p_record.counter_id,
                            l_err_msg,          x_return_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  --delete the record from the inq as it got processed already
   DELETE_PROP_READ_FROM_INQ(
           p_record.clid$$cs,
           p_record.tranid$$,
       l_counter_value_id,
           x_return_status
         );
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_counter_value_id;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    l_err_msg:= 'Error' || g_object_name || '.APPLY_INSERT' || ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
    CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_VALUES_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
  END IF;

    l_err_msg:= 'Leaving ' || g_object_name || '.APPLY_INSERT' || ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
    CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_VALUES_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);


EXCEPTION WHEN OTHERS THEN
  l_err_msg := 'Exception occurred in ' || g_object_name || '.APPLY_INSERT: ' || sqlerrm|| ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_VALUES_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);


  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  l_err_msg := 'Leaving ' || g_object_name || '.APPLY_INSERT' || ' for PK ' || to_char( p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_CS_COUNTER_VALUES%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  CURSOR c_counter_value
    ( b_counter_value_id number
    )
  IS
    SELECT counter_id
    ,      counter_value_id
    ,      counter_grp_log_id
    ,      object_version_number
    ,      last_update_date
    FROM   cs_ctr_counter_values_v
    WHERE  counter_value_id = b_counter_value_id;

  CURSOR c_counter_value_check (b_counter_value_id NUMBER)
  IS
    SELECT counter_reading
    FROM   cs_counter_values
    WHERE  counter_value_id = b_counter_value_id;



  r_counter_value   c_counter_value%ROWTYPE;

  -- Variables needed for public API
  l_ctr_rdg_rec         CS_CTR_Capture_Reading_pub.CTR_Rdg_Rec_Type;
  l_ctr_rdg_tbl         CS_CTR_Capture_Reading_pub.CTR_Rdg_Tbl_Type;
  l_prp_rdg_rec_pub     Cs_Ctr_Capture_Reading_Pub.PROP_RDG_Rec_Type;
  l_prp_rdg_tbl_pub     Cs_Ctr_Capture_Reading_Pub.PROP_RDG_Tbl_Type;


  l_ctr_grp_id      number;
  l_ctr_grp_log_id  number;
  l_customer_product_id number;

  l_counter_reading number;
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(4000);
  l_err_msg  VARCHAR2(4000);

--  l_server_value_timestamp date;
BEGIN
  l_err_msg := 'Entering ' || g_object_name || '.APPLY_UPDATE' || ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_PROCEDURE );

  -- ANURAG Convert the client time to server time before storing in the backend
--  l_server_value_timestamp := csm_util_pkg.GetServerTime(
--      p_record.value_timestamp, p_record.clid$$cs);


  l_ctr_rdg_rec.counter_value_id   := p_record.counter_value_id;
  l_ctr_rdg_rec.counter_id         := p_record.counter_id;
  l_ctr_rdg_rec.value_timestamp    := p_record.value_timestamp;
  l_ctr_rdg_rec.counter_reading    := p_record.counter_reading;
  l_ctr_rdg_rec.reset_flag         := p_record.reset_flag;
  l_ctr_rdg_rec.reset_reason       := p_record.reset_reason;
  l_ctr_rdg_rec.pre_reset_last_rdg := p_record.pre_reset_last_rdg;
  l_ctr_rdg_rec.post_reset_first_rdg := p_record.post_reset_first_rdg;
  l_ctr_rdg_rec.misc_reading_type  := p_record.misc_reading_type;
  l_ctr_rdg_rec.misc_reading       := p_record.misc_reading;

  OPEN c_counter_value
    ( b_counter_value_id => p_record.counter_value_id
    );
  FETCH c_counter_value
  INTO r_counter_value;
  IF c_counter_value%FOUND
  THEN
    l_ctr_grp_log_id := r_counter_value.counter_grp_log_id;
    -- Make sure we have the right object_version_number
    l_ctr_rdg_rec.object_version_number := r_counter_value.object_version_number;
  ELSE
    -- Let the API complain with a good message.
    l_ctr_grp_log_id := FND_API.G_MISS_NUM;
    l_ctr_rdg_rec.object_version_number := FND_API.G_MISS_NUM;
  END IF;
  CLOSE c_counter_value;

  l_ctr_rdg_tbl(1) := l_ctr_rdg_rec;

  -- Make sure we have the right object_version_number
  l_ctr_rdg_tbl(1).object_version_number := r_counter_value.object_version_number;


  --check for the stale data
  -- SERVER_WINS profile value
  IF(fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE)
       = csm_profile_pkg.g_SERVER_WINS) THEN
    IF(r_counter_value.last_update_date <> p_record.server_last_update_date) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_err_msg:= 'UPWARD SYNC CONFLICT: CLIENT LOST: CSM_COUNTER_VALUES_PKG.APPLY_UPDATE: P_KEY = '
          || p_record.counter_value_id;
       CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR);
       p_error_msg := l_err_msg;
       RETURN;
    END IF;
  END IF;

  --CLIENT_WINS (or client is allowd to update the record)

  Cs_Ctr_Capture_Reading_pub.Update_Counter_Reading
    ( p_api_version_number => 1.0
    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    , p_init_msg_list      => FND_API.G_TRUE
    , p_commit             => FND_API.G_FALSE
    , p_ctr_rdg_tbl        => l_ctr_rdg_tbl
    , p_ctr_grp_log_id     => l_ctr_grp_log_id
    , x_return_status      => x_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    );

   --anu
 --setting the return status to SUCCESS because of bug 2470553
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 --end anu

 OPEN c_counter_value_check(p_record.counter_value_id);
  FETCH c_counter_value_check INTO l_counter_reading;
  IF c_counter_value_check%FOUND THEN
    IF l_counter_reading = p_record.counter_reading THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
     --calling counter value update to mark dirty
      CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS(p_record.counter_value_id, p_record.counter_id,
                              l_err_msg,          x_return_status);

    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_counter_value_check;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  l_err_msg := 'Leaving ' || g_object_name || '.APPLY_UPDATE'|| ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
   l_err_msg:= 'Exception occurred in ' || g_object_name || '.APPLY_UPDATE: ' || sqlerrm
               || ' for PK ' || p_record.COUNTER_VALUE_ID;
   CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EXCEPTION );

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  l_err_msg := 'Leaving ' || g_object_name || '.APPLY_UPDATE'|| ' for PK ' ||to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EXCEPTION  );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_CS_COUNTER_VALUES%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
l_err_msg  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;


  l_err_msg:= 'Entering ' || g_object_name || '.APPLY_RECORD' || ' for PK ' || to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  l_err_msg:=  'Processing ' || g_object_name || ' for PK ' || p_record.COUNTER_VALUE_ID /* put PK column here */ || ' ' ||
       'DMLTYPE = ' || p_record.dmltype$$ ;
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );

  ELSIF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
       p_record,
       p_error_msg,
       x_return_status
     );
  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity
    l_err_msg := 'Delete is not supported for this entity ' || g_object_name;
    CSM_UTIL_PKG.LOG( l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
    l_err_msg := 'Invalid DML type: ' || p_record.dmltype$$ || ' for this entity '|| g_object_name;
    CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  l_err_msg := 'Leaving ' || g_object_name || '.APPLY_RECORD' || ' for PK ' || to_Char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  l_err_msg:= 'Exception occurred in ' || g_object_name || '.APPLY_RECORD:' || ' ' || SQLERRM || ' for PK ' ||to_char( p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  l_err_msg := 'Leaving ' || g_object_name || '.APPLY_RECORD'|| ' for PK ' ||to_char(p_record.COUNTER_VALUE_ID);
  CSM_UTIL_PKG.LOG(l_err_msg,'CSM_COUNTER_VALUES_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CS_COUNTER_VALUES
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_error_msg := 'Entering ' || g_object_name || '.Apply_Client_Changes';
  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);


  /*** loop through CS_COUNTER_VALUES records in inqueue ***/
  FOR r_CS_COUNTER_VALUES IN c_CS_COUNTER_VALUES( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_CS_COUNTER_VALUES
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      l_error_msg :=  'Record successfully processed, deleting from inqueue ' || g_object_name
               || ' for PK ' || r_CS_COUNTER_VALUES.COUNTER_VALUE_ID;
      CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR);

      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_CS_COUNTER_VALUES.seqno$$,
          r_CS_COUNTER_VALUES.COUNTER_VALUE_ID, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
         l_error_msg := 'Deleting from inqueue failed, rolling back to savepoint for entity ' || g_object_name
               || ' and  PK ' || r_CS_COUNTER_VALUES.COUNTER_VALUE_ID ;
        CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR);

        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
        l_error_msg :='Record not processed successfully, deferring and rejecting record for entity ' || g_object_name
               || ' and PK ' || r_CS_COUNTER_VALUES.COUNTER_VALUE_ID ;
        CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR);

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_CS_COUNTER_VALUES.seqno$$
       , r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_CS_COUNTER_VALUES.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        l_error_msg :='Defer record failed, rolling back to savepoint for entity ' || g_object_name
               || ' and PK ' || r_CS_COUNTER_VALUES.COUNTER_VALUE_ID;
        CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR);

        ROLLBACK TO save_rec;
      END IF;
    END IF;

  END LOOP;

     l_error_msg :='Leaving ' || g_object_name || '.Apply_Client_Changes';
     CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  l_error_msg := 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm ;
  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_COUNTER_VALUES_PKG;

/
