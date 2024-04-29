--------------------------------------------------------
--  DDL for Package Body CSL_COUNTER_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_COUNTER_VALUES_PKG" AS
/* $Header: cslvcvab.pls 120.1 2005/08/30 01:32:17 utekumal noship $*/

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_COUNTER_VALUES_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CS_COUNTER_VALUES';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_CS_COUNTER_VALUES( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_CS_COUNTER_VALUES_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_CS_COUNTER_VALUES%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  -- Variables needed for public API

  -- Rewrite for Sql Performance - Venky
  cursor c_counter_group
    ( b_counter_id number
    )
  is
    select c.counter_id
    ,      c.counter_group_id
    ,      g.source_object_id
    from   cs_counters c, cs_counter_groups g
    where  c.counter_id = b_counter_id
           AND c.counter_group_id = g.counter_group_id
           AND g.source_object_code = 'CP' ;

  r_counter_group       c_counter_group%rowtype;

  -- Variables needed for public API
  l_ctr_grp_log_rec_pub Cs_Ctr_Capture_Reading_Pub.Ctr_Grp_Log_Rec_Type;
  l_ctr_rdg_rec_pub     Cs_Ctr_Capture_Reading_Pub.Ctr_Rdg_Rec_Type;
  l_ctr_rdg_tbl_pub     Cs_Ctr_Capture_Reading_Pub.Ctr_Rdg_Tbl_Type;

  -- Variables needed for private API
  --Bug 4496299
  /*
  l_ctr_grp_log_rec_pvt Cs_Ctr_Capture_Reading_Pvt.Ctr_Grp_Log_Rec_Type;
  l_ctr_rdg_rec_pvt     Cs_Ctr_Capture_Reading_Pvt.Ctr_Rdg_Rec_Type;
  */

  l_ctr_grp_id          number;
  l_ctr_grp_log_id      number;
  l_customer_product_id number;
  l_prop_val_cnt        number;

  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(240);

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  --Bug 4496299

  -- For mobile Field Service we know that a counter_group_id is not
  -- known, but the counter_id is known. Therefore we need to retrieve
  -- the counter_group_id, using the counter_id.

  /*

  open c_counter_group
    ( b_counter_id => p_record.counter_id
    );
  fetch c_counter_group
  into r_counter_group;
  if c_counter_group%found
  then
    l_ctr_grp_id := r_counter_group.counter_group_id;
    l_customer_product_id := r_counter_group.source_object_id;
  else
    l_ctr_grp_id := FND_API.G_MISS_NUM;
    l_customer_product_id := FND_API.G_MISS_NUM;
  end if;
  close c_counter_group;

  -- The public API closes a counter log after inserting a counter value. After
  -- that it's not possible to insert new counter property values for this
  -- counter value.
  -- Therefore the public API may only be called when there are no counter
  -- property values. Otherwise the private API, which doesn't close a
  -- counter log, should be called.

  SELECT COUNT(1) INTO l_prop_val_cnt
  FROM CSL_cs_counter_prop_vals_inq
  WHERE COUNTER_VALUE_ID = P_Record.COUNTER_VALUE_ID;

  if l_prop_val_cnt = 0
  then
    -- There are no counter_property_values for this counter_value.
    -- Fill the counter_group_log record and the counter_reading record needed
    -- for the public API and then call the public API.
    -- Fill counter_group_log record

    l_ctr_grp_log_rec_pub.counter_group_id        := l_ctr_grp_id;
    l_ctr_grp_log_rec_pub.value_timestamp := p_record.value_timestamp;
    l_ctr_grp_log_rec_pub.source_transaction_id   := l_customer_product_id; -- p_record.customer_product_id;
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

    l_ctr_rdg_tbl_pub(1) := l_ctr_rdg_rec_pub;

    -- Call the public API

    Cs_Ctr_Capture_Reading_Pub.Capture_Counter_Reading
      ( p_api_version_number  => 1.0
      , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
      , p_init_msg_list       => FND_API.G_TRUE
      , p_commit              => FND_API.G_FALSE
      , p_ctr_rdg_tbl         => l_ctr_rdg_tbl_pub
      , p_ctr_grp_log_rec     => l_ctr_grp_log_rec_pub
      , x_return_status       => x_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );
  else
    -- There are counter property values for this counter value.
    -- Fill the counter_group_log record and the counter_reading record needed
    -- for the private API and then call the private API.

    -- Fill counter_group_log record

    l_ctr_grp_log_rec_pvt.counter_group_id        := l_ctr_grp_id;
    l_ctr_grp_log_rec_pvt.value_timestamp := p_record.value_timestamp;
    l_ctr_grp_log_rec_pvt.source_transaction_id   := l_customer_product_id;
    l_ctr_grp_log_rec_pvt.source_transaction_code := 'FS';

    -- Call the (first of the) private API(s)

    Cs_Ctr_Capture_Reading_Pvt.Pre_Capture_Counter_Reading
      ( p_api_version_number => 1.0
      , p_init_msg_list      => FND_API.G_TRUE
      , p_commit             => FND_API.G_FALSE
      , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      , p_ctr_grp_log_rec    => l_ctr_grp_log_rec_pvt
      , x_counter_grp_log_id => l_ctr_grp_log_id
      , x_return_status      => x_return_status
      , x_msg_count          => l_msg_count
      , x_msg_data           => l_msg_data
      );

    if x_return_status = FND_API.G_RET_STS_SUCCESS
    then
    -- Call the (second of the) private API(s)

    l_ctr_rdg_rec_pvt.counter_value_id     := p_record.counter_value_id;
    l_ctr_rdg_rec_pvt.counter_id           := p_record.counter_id;
    l_ctr_rdg_rec_pvt.value_timestamp      := p_record.value_timestamp;
    l_ctr_rdg_rec_pvt.counter_reading      := p_record.counter_reading;
    l_ctr_rdg_rec_pvt.reset_flag           := p_record.reset_flag;
    l_ctr_rdg_rec_pvt.reset_reason         := p_record.reset_reason;
    l_ctr_rdg_rec_pvt.pre_reset_last_rdg   := p_record.pre_reset_last_rdg;
    l_ctr_rdg_rec_pvt.post_reset_first_rdg := p_record.post_reset_first_rdg;
    l_ctr_rdg_rec_pvt.misc_reading_type    := p_record.misc_reading_type;
    l_ctr_rdg_rec_pvt.misc_reading         := p_record.misc_reading;

    Cs_Ctr_Capture_Reading_Pvt.Capture_Counter_Reading
      ( p_api_version_number => 1.0
      , p_init_msg_list      => FND_API.G_TRUE
      , p_commit             => FND_API.G_FALSE
      , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      , p_ctr_rdg_rec        => l_ctr_rdg_rec_pvt
      , p_counter_grp_log_id => l_ctr_grp_log_id
      , x_return_status      => x_return_status
      , x_msg_count          => l_msg_count
      , x_msg_data           => l_msg_data
      );
   end if;
  end if;
  */

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

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

  -- Rewrite for Sql Performance - Venky
  cursor c_counter_group
    ( b_counter_id number
    )
  is
    select c.counter_id
    ,      c.counter_group_id
    ,      g.source_object_id
    from   cs_counters c, cs_counter_groups g
    where  c.counter_id = b_counter_id
           AND c.counter_group_id = g.counter_group_id
           AND g.source_object_code = 'CP' ;

  cursor c_counter_value
    ( b_counter_value_id number
    )
  is
    select counter_id
    ,      counter_value_id
    ,      counter_grp_log_id
    ,      object_version_number
    from   cs_ctr_counter_values_v
    where  counter_value_id = b_counter_value_id;

  r_counter_group   c_counter_group%rowtype;
  r_counter_value   c_counter_value%rowtype;

  --Bug 4496299
  /*
  l_ctr_grp_log_rec CS_CTR_Capture_Reading_pub.CTR_Grp_Log_Rec_Type;
  l_ctr_rdg_rec     CS_CTR_Capture_Reading_pub.CTR_Rdg_Rec_Type;
  */
  l_ctr_rdg_tbl     CS_CTR_Capture_Reading_pub.CTR_Rdg_Tbl_Type;
  l_ctr_grp_id      number;
  l_ctr_grp_log_id  number;
  l_customer_product_id number;

  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(240);
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  --Bug 4496299
  /*
  -- For mobile Field Service we know that a counter_group_id is not
  -- known, but the counter_id is known. Therefore we need to retrieve
  -- the counter_group_id, using the counter_id.

  open c_counter_group
    ( b_counter_id => p_record.counter_id
    );
  fetch c_counter_group
  into r_counter_group;
  if c_counter_group%found
  then
    l_ctr_grp_id := r_counter_group.counter_group_id;
    l_customer_product_id := r_counter_group.source_object_id;
  else
    l_ctr_grp_id := FND_API.G_MISS_NUM;
    l_customer_product_id := FND_API.G_MISS_NUM;
  end if;
  close c_counter_group;

  l_ctr_grp_log_rec.counter_group_id := l_ctr_grp_id;
  l_ctr_grp_log_rec.value_timestamp  := p_record.value_timestamp;
  l_ctr_grp_log_rec.source_transaction_id   := l_customer_product_id;
  l_ctr_grp_log_rec.source_transaction_code := 'FS';

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

  open c_counter_value
    ( b_counter_value_id => p_record.counter_value_id
    );
  fetch c_counter_value
  into r_counter_value;
  if c_counter_value%found
  then
    l_ctr_grp_log_id := r_counter_value.counter_grp_log_id;
    -- Make sure we have the right object_version_number
    l_ctr_rdg_rec.object_version_number := r_counter_value.object_version_number;
  else
    -- Let the API complain with a good message.
    l_ctr_grp_log_id := FND_API.G_MISS_NUM;
    l_ctr_rdg_rec.object_version_number := FND_API.G_MISS_NUM;
  end if;
  close c_counter_value;

  l_ctr_rdg_tbl(1) := l_ctr_rdg_rec;

  -- Make sure we have the right object_version_number
  l_ctr_rdg_tbl(1).object_version_number := r_counter_value.object_version_number;

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

  */

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

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
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID-- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
      , v_object_name => g_object_name
      , v_message     => 'Processing CS_COUNTER_VALUE = ' || p_record.COUNTER_VALUE_ID /* put PK column here */ || fnd_global.local_chr(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

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
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Delete is not supported for this entity'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
      , v_object_name => g_object_name
      , v_message     => 'Invalid DML type: ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.COUNTER_VALUE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item CS_COUNTER_VALUES
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

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

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
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
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
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_CS_COUNTER_VALUES.seqno$$
       , r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_CS_COUNTER_VALUES.COUNTER_VALUE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSL_COUNTER_VALUES_PKG;

/
