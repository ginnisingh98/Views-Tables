--------------------------------------------------------
--  DDL for Package Body CSL_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_REQUIREMENTS_PKG" AS
/* $Header: cslvreqb.pls 115.14 2002/11/08 14:00:12 asiegers ship $ */


error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_REQUIREMENTS_PKG';    -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_LINES'; -- publication item name
g_pub_name2    CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_HEADERS';   -- publication item name
g_debug_level  NUMBER;                                             -- debug level

/***
  Cursor to retrieve all requirement lines from the requirement line inqueue that
  have a requirement header record in the requirement header inqueue.
***/
CURSOR c_requirements ( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT reql.*
  FROM   CSL_CSP_REQUIREMENT_LNS_inq reql, CSL_CSP_REQUIREMENT_HDR_inq reqh
  WHERE  reql.tranid$$ = b_tranid
  AND    reql.clid$$cs = b_user_name
  AND    reql.requirement_header_id = reqh.requirement_header_id;

/***
  Cursor to retrieve all requirement lines from the requirement line inqueue that
  have no requirement header record in the requirement header inqueue but have one in the backend.
  This one is executed after all requirement lines with headers have been deleted from the inqueue.
  The requirement lines without header remain then.
***/
CURSOR c_requirements_no_headers ( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM   CSL_CSP_REQUIREMENT_LNS_inq
  WHERE  tranid$$ = b_tranid
  AND    clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
  If p_get_inqueue_header = TRUE  => fetch requirement header from the requirement header inqueue.
  If p_get_inqueue_header = FALSE => fetch requirement header from Apps.
***/
PROCEDURE APPLY_INSERT
         (
           p_record              IN      c_requirements%ROWTYPE,
           p_user_name           IN      VARCHAR2,
           p_tranid              IN      NUMBER,
           p_get_inqueue_header  IN      BOOLEAN,
           p_error_msg           OUT NOCOPY     VARCHAR2,
           x_return_status       IN OUT NOCOPY  VARCHAR2
         ) IS

  l_header_rec   CSP_PARTS_REQUIREMENT.HEADER_REC_TYPE;
  l_line_rec     CSP_PARTS_REQUIREMENT.LINE_REC_TYPE;
  l_line_table   CSP_PARTS_REQUIREMENT.LINE_TBL_TYPE;

  l_s_org_id     NUMBER := 207;
  l_d_org_id     NUMBER := 204;
  l_item_id      NUMBER := 155;
  l_quantity     NUMBER := 7;
  l_uom          VARCHAR2(3) := 'Ea';
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(240);

  -- Cursor to retrieve requirement header from the inqueue
  CURSOR c_get_requirement_from_inq ( b_user_name VARCHAR2, b_tranid NUMBER, b_requirement_header_id NUMBER) is
    SELECT *
    FROM   CSL_CSP_REQUIREMENT_HDR_inq
    WHERE  tranid$$ = b_tranid
    AND    clid$$cs = b_user_name
    AND    requirement_header_id = b_requirement_header_id;

  r_get_requirement_from_inq   c_get_requirement_from_inq%ROWTYPE;

  -- Cursor to retrieve requirement header from Apps
  CURSOR c_get_requirement_from_apps (b_requirement_header_id NUMBER) is
    SELECT *
    FROM   CSP_REQUIREMENT_HEADERS
    WHERE  requirement_header_id = b_requirement_header_id;

  r_get_requirement_from_apps  c_get_requirement_from_apps%ROWTYPE;

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF p_get_inqueue_header THEN

    -- Open cursor to retrieve requirement header from requirement header inqueue
    OPEN  c_get_requirement_from_inq (p_user_name, p_tranid, p_record.REQUIREMENT_HEADER_ID);
    FETCH c_get_requirement_from_inq INTO r_get_requirement_from_inq;
    CLOSE c_get_requirement_from_inq ;

    -- Initialization of the requirement header with inqueue header record
    l_header_rec.REQUIREMENT_HEADER_ID := r_get_requirement_from_inq.REQUIREMENT_HEADER_ID;
    l_header_rec.REQUISITION_NUMBER    := r_get_requirement_from_inq.REQUIREMENT_HEADER_ID;
    l_header_rec.ORDER_TYPE_ID         := fnd_profile.value('CSP_ORDER_TYPE');
    l_header_rec.SHIP_TO_LOCATION_ID   := r_get_requirement_from_inq.SHIP_TO_LOCATION_ID;
    l_header_rec.NEED_BY_DATE          := r_get_requirement_from_inq.NEED_BY_DATE;
    l_header_rec.DEST_ORGANIZATION_ID  := r_get_requirement_from_inq.DESTINATION_ORGANIZATION_ID;
    l_header_rec.DEST_SUBINVENTORY     := r_get_requirement_from_inq.DESTINATION_SUBINVENTORY;
    l_header_rec.OPERATION             := CSP_PARTS_REQUIREMENT.G_OPR_CREATE;
    l_header_rec.RESOURCE_TYPE         := r_get_requirement_from_inq.RESOURCE_TYPE;
    l_header_rec.RESOURCE_ID           := r_get_requirement_from_inq.RESOURCE_ID;

  ELSE

    -- Open cursor to retrieve requirement header from requirement header inqueue
    OPEN  c_get_requirement_from_apps (p_record.REQUIREMENT_HEADER_ID);
    FETCH c_get_requirement_from_apps INTO r_get_requirement_from_apps;
    CLOSE c_get_requirement_from_apps;

    -- Initialization of the requirement header with Apps header record
    l_header_rec.REQUIREMENT_HEADER_ID := r_get_requirement_from_apps.REQUIREMENT_HEADER_ID;
    l_header_rec.REQUISITION_NUMBER    := r_get_requirement_from_apps.REQUIREMENT_HEADER_ID;
    l_header_rec.ORDER_TYPE_ID         := fnd_profile.value('CSP_ORDER_TYPE');
    l_header_rec.SHIP_TO_LOCATION_ID   := r_get_requirement_from_apps.SHIP_TO_LOCATION_ID;
    l_header_rec.NEED_BY_DATE          := r_get_requirement_from_apps.NEED_BY_DATE;
    l_header_rec.DEST_ORGANIZATION_ID  := r_get_requirement_from_apps.DESTINATION_ORGANIZATION_ID;
    l_header_rec.DEST_SUBINVENTORY     := r_get_requirement_from_apps.DESTINATION_SUBINVENTORY;
    l_header_rec.OPERATION             := CSP_PARTS_REQUIREMENT.G_OPR_CREATE;
    l_header_rec.RESOURCE_TYPE         := r_get_requirement_from_apps.RESOURCE_TYPE;
    l_header_rec.RESOURCE_ID           := r_get_requirement_from_apps.RESOURCE_ID;

  END IF;

  -- Initialization of the requirement line
  l_line_rec.REQUIREMENT_LINE_ID     := p_record.REQUIREMENT_LINE_ID;
  l_line_rec.LINE_NUM		       := p_record.REQUIREMENT_LINE_ID;
  l_line_rec.INVENTORY_ITEM_ID       := p_record.INVENTORY_ITEM_ID;
  l_line_rec.QUANTITY                := p_record.REQUIRED_QUANTITY;
  l_line_rec.ORDERED_QUANTITY        := p_record.REQUIRED_QUANTITY;
  l_line_rec.UNIT_OF_MEASURE         := p_record.UOM_CODE;

  l_line_table(1) := l_line_rec;

  CSP_PARTS_REQUIREMENT.Process_Requirement
    ( P_API_VERSION       => 1
    , PX_HEADER_REC       => l_header_rec
    , PX_LINE_TABLE       => l_line_table
    , P_CREATE_ORDER_FLAG => 'Y'
    , X_RETURN_STATUS     => x_return_status
    , X_MSG_COUNT         => l_msg_count
    , X_MSG_DATA          => l_msg_data
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
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
           p_record        IN     c_requirements%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- No update possible so return success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in inqueue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record              IN      c_requirements%ROWTYPE
         , p_user_name           IN      VARCHAR2
         , p_tranid              IN      NUMBER
         , p_get_inqueue_header  IN      BOOLEAN
         , p_error_msg           OUT NOCOPY     VARCHAR2
         , x_return_status       IN OUT NOCOPY  VARCHAR2
         ) IS
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.requirement_line_id -- put PK column here
      , v_object_name => g_object_name
      , v_message     => 'Processing requirement = ' || p_record.requirement_line_id /* put PK column here */ || FND_GLOBAL.LOCAL_CHR(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_user_name,
        p_tranid,
        p_get_inqueue_header,
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
        ( v_object_id   => p_record.requirement_line_id -- put PK column here
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
      ( v_object_id   => p_record.requirement_line_id -- put PK column here
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
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.requirement_line_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
   This procedure is called by PROCESS_REQS and deletes all requirement headers from the inqueue,
   for a given user and transaction.
***/
PROCEDURE DELETE_REQ_HEADERS_FROM_INQ
         (
           p_user_name     IN      VARCHAR2,
           p_tranid        IN      NUMBER,
           x_return_status IN OUT NOCOPY  VARCHAR2
         ) IS

  l_error_msg VARCHAR2(4000);

  /***
    Cursor to retrieve all requirement headers for this user_name and tranid.
    This one is to be executed after all requirement lines with headers have been deleted from the inqueue.
  ***/
  CURSOR c_get_req_headers_from_inq ( b_user_name VARCHAR2, b_tranid NUMBER) is
    SELECT *
    FROM   CSL_CSP_REQUIREMENT_HDR_inq
    WHERE  tranid$$ = b_tranid
    AND    clid$$cs = b_user_name;

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.DELETE_REQ_HEADERS_FROM_INQ'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Loop through this cursor to delete all requirement headers from the requirement header inqueue
  FOR r_get_req_headers_from_inq IN c_get_req_headers_from_inq ( p_user_name, p_tranid) LOOP

    -- Delete the requirement header from the requirement header inqueue.
    CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
      (
        p_user_name,
        p_tranid,
        r_get_req_headers_from_inq.seqno$$,
        r_get_req_headers_from_inq.requirement_header_id, -- put PK column here
        g_object_name,
        g_pub_name2,
        l_error_msg,
        x_return_status
      );

    /*** was delete successful? ***/
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** no -> rollback ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_get_req_headers_from_inq.requirement_header_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      ROLLBACK TO save_rec;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_get_req_headers_from_inq.requirement_header_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_get_req_headers_from_inq.seqno$$
       , r_get_req_headers_from_inq.requirement_header_id -- put PK column here
       , g_object_name
       , g_pub_name2
       , l_error_msg
       , x_return_status
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_get_req_headers_from_inq.requirement_header_id -- put PK column here
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
    , v_message     => 'Leaving ' || g_object_name || '.DELETE_REQ_HEADERS_FROM_INQ'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in DELETE_REQ_HEADERS_FROM_INQ:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_REQ_HEADERS_FROM_INQ;

/***
  This procedure is called by APPLY_CLIENT_CHANGES and processes all inqueue requirement lines,
  that have a requirement header in the requirement header inqueue.
***/
PROCEDURE PROCESS_REQS
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_error_msg VARCHAR2(4000);

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Process_Reqs'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through c_requirements records in inqueue ***/
  FOR r_requirements IN c_requirements ( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
	  r_requirements
      , p_user_name
      , p_tranid
      , true -- requirement line has a header record in the inqueue which should be fetched.
      , l_error_msg
      , x_return_status
      );

    /*** was record processed successfully? ***/
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      -- Delete the requirement line from the requirement line inqueue.
      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_requirements.seqno$$,
          r_requirements.requirement_line_id, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          x_return_status
        );

      /*** was delete successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_requirements.seqno$$
       , r_requirements.requirement_line_id -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;
  END LOOP;

  -- Call delete procedure to delete all requirement headers from requirement header inqueue.
  DELETE_REQ_HEADERS_FROM_INQ(p_user_name, p_tranid, x_return_status);

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Process_Reqs'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END PROCESS_REQS;

/***
  This procedure is called by APPLY_CLIENT_CHANGES and processes all inqueue requirement lines,
  that have no requirement header in the requirement header inqueue (but have on in Apps).
***/
PROCEDURE PROCESS_REQS_NO_HEADERS
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_error_msg VARCHAR2(4000);

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Process_Reqs_No_Headers'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through c_requirements_no_headers records in inqueue ***/
  FOR r_requirements IN c_requirements_no_headers ( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
	  r_requirements
      , p_user_name
      , p_tranid
      , false -- requirement line has no header record in the inqueue but only in apps and this should be fetched.
      , l_error_msg
      , x_return_status
      );

    /*** was record processed successfully? ***/
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_requirements.seqno$$,
          r_requirements.requirement_line_id, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          x_return_status
        );

      /*** was delete successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_requirements.seqno$$
       , r_requirements.requirement_line_id -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_requirements.requirement_line_id -- put PK column here
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
    , v_message     => 'Leaving ' || g_object_name || '.Process_Reqs_No_Headers'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

END PROCESS_REQS_NO_HEADERS;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item CSP_REQUIREMENT_LINES
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

  -- First process all requirement lines that have a requirement header. Delete them after processing.
  PROCESS_REQS (p_user_name, p_tranid, x_return_status);

  -- Then process all remaining requirement lines (no requirement header). These already have a requirement header in Apps.
  PROCESS_REQS_NO_HEADERS(p_user_name, p_tranid, x_return_status);

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END APPLY_CLIENT_CHANGES;
END CSL_REQUIREMENTS_PKG;

/
