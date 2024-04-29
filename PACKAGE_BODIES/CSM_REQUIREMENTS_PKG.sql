--------------------------------------------------------
--  DDL for Package Body CSM_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_REQUIREMENTS_PKG" AS
/* $Header: csmureqb.pls 120.4 2006/08/11 12:25:18 utekumal noship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_REQUIREMENTS_PKG';    -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_REQ_LINES'; -- publication item name
g_pub_name2    CONSTANT VARCHAR2(30) := 'CSM_REQ_HEADERS';   -- publication item name

/***
  Cursor to retrieve all requirement lines from the requirement line inqueue that
  have no requirement header record in the requirement header inqueue but have one in the backend.
  This one is executed after all requirement lines with headers have been deleted from the inqueue.
  The requirement lines without header remain then.
***/
CURSOR c_requirements_no_headers ( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM   CSM_REQ_LINES_INQ l
  WHERE  l.tranid$$ = b_tranid
  AND    l.clid$$cs = b_user_name
  AND EXISTS
  (SELECT 1
   FROM csp_requirement_headers h
   WHERE h.requirement_header_id = l.requirement_header_id
   );

/***
  Cursor to retrieve all requirement lines from the requirement line inqueue that
  have a requirement header record in the requirement header inqueue.
***/

CURSOR c_requirements ( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT reql.*
  FROM   CSM_REQ_LINES_INQ reql, CSM_REQ_HEADERS_INQ reqh
  WHERE  reql.tranid$$ = reqh.tranid$$
  AND    reql.clid$$cs = reqh.clid$$cs
  AND    reql.tranid$$ = b_tranid
  AND    reql.clid$$cs = b_user_name
  AND    reql.requirement_header_id = reqh.requirement_header_id;

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
  l_msg_data     VARCHAR2(4000);

  -- Cursor to retrieve requirement header from the inqueue
  CURSOR c_get_requirement_from_inq ( b_user_name VARCHAR2, b_tranid NUMBER, b_requirement_header_id NUMBER) is
    SELECT *
    FROM   CSM_REQ_HEADERS_INQ
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

  CSM_UTIL_PKG.LOG
       ( 'Entering CSM_REQUIREMENTS_PKG.APPLY_INSERT'|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_INSERT',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here


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
--    l_header_rec.ADDRESS_TYPE          := NVL(r_get_requirement_from_inq.ADDRESS_TYPE, CSP_PARTS_REQUIREMENT.G_ADDR_RESOURCE);
    l_header_rec.NEED_BY_DATE          := r_get_requirement_from_inq.NEED_BY_DATE;
    l_header_rec.DEST_ORGANIZATION_ID  := r_get_requirement_from_inq.DESTINATION_ORGANIZATION_ID;
    l_header_rec.DEST_SUBINVENTORY     := r_get_requirement_from_inq.DESTINATION_SUBINVENTORY;
    l_header_rec.OPERATION             := CSP_PARTS_REQUIREMENT.G_OPR_CREATE;
    l_header_rec.RESOURCE_TYPE         := r_get_requirement_from_inq.RESOURCE_TYPE;
    l_header_rec.RESOURCE_ID           := r_get_requirement_from_inq.RESOURCE_ID;
    l_header_rec.TASK_ID               := r_get_requirement_from_inq.TASK_ID;
    l_header_rec.TASK_ASSIGNMENT_ID    := r_get_requirement_from_inq.TASK_ASSIGNMENT_ID;
    l_header_rec.attribute_category      := r_get_requirement_from_inq.attribute_category;
    l_header_rec.attribute1              := r_get_requirement_from_inq.attribute1;
    l_header_rec.attribute2              := r_get_requirement_from_inq.attribute2;
    l_header_rec.attribute3              := r_get_requirement_from_inq.attribute3;
    l_header_rec.attribute4              := r_get_requirement_from_inq.attribute4;
    l_header_rec.attribute5              := r_get_requirement_from_inq.attribute5;
    l_header_rec.attribute6              := r_get_requirement_from_inq.attribute6;
    l_header_rec.attribute7              := r_get_requirement_from_inq.attribute7;
    l_header_rec.attribute8              := r_get_requirement_from_inq.attribute8;
    l_header_rec.attribute9              := r_get_requirement_from_inq.attribute9;
    l_header_rec.attribute10             := r_get_requirement_from_inq.attribute10;
    l_header_rec.attribute11             := r_get_requirement_from_inq.attribute11;
    l_header_rec.attribute12             := r_get_requirement_from_inq.attribute12;
    l_header_rec.attribute13             := r_get_requirement_from_inq.attribute13;
    l_header_rec.attribute14             := r_get_requirement_from_inq.attribute14;
    l_header_rec.attribute15             := r_get_requirement_from_inq.attribute15;

  ELSE
    -- Open cursor to retrieve requirement header from requirement header inqueue
    OPEN  c_get_requirement_from_apps (p_record.REQUIREMENT_HEADER_ID);
    FETCH c_get_requirement_from_apps INTO r_get_requirement_from_apps;
    CLOSE c_get_requirement_from_apps;

    -- Initialization of the requirement header with Apps header record
    l_header_rec.REQUIREMENT_HEADER_ID := r_get_requirement_from_apps.REQUIREMENT_HEADER_ID;
    l_header_rec.REQUISITION_NUMBER    := r_get_requirement_from_apps.REQUIREMENT_HEADER_ID;
    l_header_rec.ORDER_TYPE_ID         := r_get_requirement_from_apps.ORDER_TYPE_ID;
    l_header_rec.SHIP_TO_LOCATION_ID   := r_get_requirement_from_apps.SHIP_TO_LOCATION_ID;
    l_header_rec.shipping_method_code  := r_get_requirement_from_apps.shipping_method_code;
    l_header_rec.NEED_BY_DATE          := r_get_requirement_from_apps.NEED_BY_DATE;
    l_header_rec.DEST_ORGANIZATION_ID  := r_get_requirement_from_apps.DESTINATION_ORGANIZATION_ID;
    l_header_rec.DEST_SUBINVENTORY     := r_get_requirement_from_apps.DESTINATION_SUBINVENTORY;
    l_header_rec.OPERATION             := CSP_PARTS_REQUIREMENT.G_OPR_CREATE;
    l_header_rec.RESOURCE_TYPE         := r_get_requirement_from_apps.RESOURCE_TYPE;
    l_header_rec.RESOURCE_ID           := r_get_requirement_from_apps.RESOURCE_ID;
    l_header_rec.TASK_ID               := r_get_requirement_from_apps.TASK_ID;
    l_header_rec.TASK_ASSIGNMENT_ID    := r_get_requirement_from_apps.TASK_ASSIGNMENT_ID;
    l_header_rec.attribute_category    := r_get_requirement_from_apps.attribute_category;
    l_header_rec.attribute1            := r_get_requirement_from_apps.attribute1;
    l_header_rec.attribute2            := r_get_requirement_from_apps.attribute2;
    l_header_rec.attribute3            := r_get_requirement_from_apps.attribute3;
    l_header_rec.attribute4            := r_get_requirement_from_apps.attribute4;
    l_header_rec.attribute5            := r_get_requirement_from_apps.attribute5;
    l_header_rec.attribute6            := r_get_requirement_from_apps.attribute6;
    l_header_rec.attribute7            := r_get_requirement_from_apps.attribute7;
    l_header_rec.attribute8            := r_get_requirement_from_apps.attribute8;
    l_header_rec.attribute9            := r_get_requirement_from_apps.attribute9;
    l_header_rec.attribute10           := r_get_requirement_from_apps.attribute10;
    l_header_rec.attribute11           := r_get_requirement_from_apps.attribute11;
    l_header_rec.attribute12           := r_get_requirement_from_apps.attribute12;
    l_header_rec.attribute13           := r_get_requirement_from_apps.attribute13;
    l_header_rec.attribute14           := r_get_requirement_from_apps.attribute14;
    l_header_rec.attribute15           := r_get_requirement_from_apps.attribute15;

  END IF;

  -- Initialization of the requirement line
  l_line_rec.REQUIREMENT_LINE_ID     := p_record.REQUIREMENT_LINE_ID;
  l_line_rec.LINE_NUM		       := p_record.REQUIREMENT_LINE_ID;
  l_line_rec.INVENTORY_ITEM_ID       := p_record.INVENTORY_ITEM_ID;
  l_line_rec.QUANTITY                := p_record.REQUIRED_QUANTITY;
  l_line_rec.ORDERED_QUANTITY        := p_record.REQUIRED_QUANTITY;
  l_line_rec.UNIT_OF_MEASURE         := p_record.UOM_CODE;
  l_line_rec.attribute_category      := p_record.attribute_category;
  l_line_rec.attribute1              := p_record.attribute1;
  l_line_rec.attribute2              := p_record.attribute2;
  l_line_rec.attribute3              := p_record.attribute3;
  l_line_rec.attribute4              := p_record.attribute4;
  l_line_rec.attribute5              := p_record.attribute5;
  l_line_rec.attribute6              := p_record.attribute6;
  l_line_rec.attribute7              := p_record.attribute7;
  l_line_rec.attribute8              := p_record.attribute8;
  l_line_rec.attribute9              := p_record.attribute9;
  l_line_rec.attribute10             := p_record.attribute10;
  l_line_rec.attribute11             := p_record.attribute11;
  l_line_rec.attribute12             := p_record.attribute12;
  l_line_rec.attribute13             := p_record.attribute13;
  l_line_rec.attribute14             := p_record.attribute14;
  l_line_rec.attribute15             := p_record.attribute15;
  --Bug 5255643
  l_line_rec.SHIP_COMPLETE           := p_record.SHIP_COMPLETE_FLAG;
  l_line_rec.REVISION                := p_record.REVISION;


  l_line_table(1) := l_line_rec;

  CSP_PARTS_REQUIREMENT.Process_Requirement
    ( P_API_VERSION       => 1
    , P_INIT_MSG_LIST     => FND_API.G_TRUE
    , PX_HEADER_REC       => l_header_rec
    , PX_LINE_TABLE       => l_line_table
    , P_CREATE_ORDER_FLAG => 'Y'
    , X_RETURN_STATUS     => x_return_status
    , X_MSG_COUNT         => l_msg_count
    , X_MSG_DATA          => l_msg_data
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );
  END IF;

  CSM_UTIL_PKG.LOG
       ( 'Leaving CSM_REQUIREMENTS_PKG.APPLY_INSERT'|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_INSERT',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here


EXCEPTION WHEN OTHERS THEN

  CSM_UTIL_PKG.LOG
     ( 'Exception occurred in CSM_REQUIREMENTS_PKG.APPLY_INSERT'|| 'for PK '||p_record.requirement_line_id || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
       'CSM_REQUIREMENTS_PKG.APPLY_INSERT',
        FND_LOG.LEVEL_EXCEPTION ); -- put PK column here

  fnd_msg_pub.Add_Exc_Msg( 'CSM_REQUIREMENTS_PKG', 'APPLY_INSERT', sqlerrm);

  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

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

  CSM_UTIL_PKG.LOG
     ( 'Entering CSM_REQUIREMENTS_PKG.APPLY_UPDATE'|| 'for PK '||p_record.requirement_line_id ,
       'CSM_REQUIREMENTS_PKG.APPLY_UPDATE',
        FND_LOG.LEVEL_STATEMENT ); -- put PK column here

  -- No update possible so return success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error => TRUE
      );
  END IF;

  CSM_UTIL_PKG.LOG
     ( 'Leaving CSM_REQUIREMENTS_PKG.APPLY_UPDATE'|| 'for PK '||p_record.requirement_line_id ,
       'CSM_REQUIREMENTS_PKG.APPLY_UPDATE',
        FND_LOG.LEVEL_STATEMENT ); -- put PK column here


EXCEPTION WHEN OTHERS THEN

  CSM_UTIL_PKG.LOG
     ( 'Exception occurred in CSM_REQUIREMENTS_PKG.APPLY_UPDATE'|| 'for PK '||p_record.requirement_line_id || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
       'CSM_REQUIREMENTS_PKG.APPLY_UPDATE',
        FND_LOG.LEVEL_EXCEPTION); -- put PK column here


  fnd_msg_pub.Add_Exc_Msg( 'CSM_REQUIREMENTS_PKG', 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

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

  CSM_UTIL_PKG.LOG
       ( 'Entering CSM_REQUIREMENTS_PKG.APPLY_RECORD'|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

  CSM_UTIL_PKG.LOG
       ( 'Processing requirement '|| 'for PK '||p_record.requirement_line_id ||'DMLTYPE = ' || p_record.dmltype$$,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

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
    CSM_UTIL_PKG.LOG
       ( 'Delete is not supported for this entity'|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_ERROR ); -- put PK column here


    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type

    CSM_UTIL_PKG.LOG
       ( 'Invalid DML type: ' || p_record.dmltype$$|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_ERROR ); -- put PK column here

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG
       ( 'Leaving CSM_REQUIREMENTS_PKG.APPLY_RECORD'|| 'for PK '||p_record.requirement_line_id,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  CSM_UTIL_PKG.LOG
       ( 'Exception occurred in CSM_REQUIREMENTS_PKG.APPLY_RECORD'|| 'for PK '||p_record.requirement_line_id || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
         'CSM_REQUIREMENTS_PKG.APPLY_RECORD',
          FND_LOG.LEVEL_EXCEPTION); -- put PK column here


  fnd_msg_pub.Add_Exc_Msg( 'CSM_REQUIREMENTS_PKG', 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

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
    FROM   CSM_REQ_HEADERS_INQ h
    WHERE  h.tranid$$ = b_tranid
    AND    h.clid$$cs = b_user_name
    AND NOT EXISTS (SELECT 1
                    FROM csm_req_lines_inq l
                    WHERE l.tranid$$ = b_tranid
                    AND  l.clid$$cs = b_user_name
                    AND  l.requirement_header_id = h.requirement_header_id
                    );

BEGIN

  CSM_UTIL_PKG.LOG
       ( 'Entering CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_STATEMENT); -- put PK column here


  -- Loop through this cursor to delete all requirement headers from the requirement header inqueue
  FOR r_get_req_headers_from_inq IN c_get_req_headers_from_inq ( p_user_name, p_tranid) LOOP

    -- Delete the requirement header from the requirement header inqueue.
    CSM_UTIL_PKG.DELETE_RECORD
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

      CSM_UTIL_PKG.LOG
       ( 'Deleting from inqueue failed, rolling back to savepoinT'|| 'for PK '||r_get_req_headers_from_inq.requirement_header_id,
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here

      ROLLBACK TO save_rec;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/

      CSM_UTIL_PKG.LOG
       ( 'Record not processed successfully, deferring and rejecting record'|| 'for PK '||r_get_req_headers_from_inq.requirement_header_id,
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here


      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_get_req_headers_from_inq.seqno$$
       , r_get_req_headers_from_inq.requirement_header_id -- put PK column here
       , g_object_name
       , g_pub_name2
       , l_error_msg
       , x_return_status
       , r_get_req_headers_from_inq.dmltype$$
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/

        CSM_UTIL_PKG.LOG
       ( 'Defer record failed, rolling back to savepoint'|| 'for PK '||r_get_req_headers_from_inq.requirement_header_id,
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_PROCEDURE); -- put PK column here

        ROLLBACK TO save_rec;
      END IF;
    END IF;
  END LOOP;

  CSM_UTIL_PKG.LOG
       ( 'Leaving CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ ',
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_STATEMENT); -- put PK column here


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/

  CSM_UTIL_PKG.LOG
       ( 'Exception occurred in DELETE_REQ_HEADERS_FROM_INQ: '|| FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
         'CSM_REQUIREMENTS_PKG.DELETE_REQ_HEADERS_FROM_INQ',
          FND_LOG.LEVEL_EXCEPTION); -- put PK column here


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

   CSM_UTIL_PKG.LOG
         ( 'Entering CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

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
       CSM_UTIL_PKG.LOG
         ( 'Record successfully processed, deleting from inqueue'|| ' for PK ' || r_requirements.requirement_line_id,
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          FND_LOG.LEVEL_PROCEDURE ); -- put PK column here


      -- Delete the requirement line from the requirement line inqueue.
      CSM_UTIL_PKG.DELETE_RECORD
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
        CSM_UTIL_PKG.LOG
         ( 'Deleting from inqueue failed, rolling back to savepoint'|| ' for PK ' || r_requirements.requirement_line_id,
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          FND_LOG.LEVEL_PROCEDURE ); -- put PK column here

        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      CSM_UTIL_PKG.LOG
         ( 'Record not processed successfully, deferring and rejecting record'|| ' for PK ' || r_requirements.requirement_line_id,
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          FND_LOG.LEVEL_PROCEDURE ); -- put PK column here


      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_requirements.seqno$$
       , r_requirements.requirement_line_id -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       , r_requirements.dmltype$$
       );


      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
       CSM_UTIL_PKG.LOG
         ( 'Defer record failed, rolling back to savepoint'|| ' for PK ' || r_requirements.requirement_line_id,
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
          FND_LOG.LEVEL_PROCEDURE ); -- put PK column here

        ROLLBACK TO save_rec;
      END IF;
    END IF;
  END LOOP;

  -- Call delete procedure to delete all requirement headers from requirement header inqueue.
  DELETE_REQ_HEADERS_FROM_INQ(p_user_name, p_tranid, x_return_status);

  CSM_UTIL_PKG.LOG
     ( 'Leaving CSM_REQUIREMENTS_PKG.PROCESS_REQS',
       'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
       FND_LOG.LEVEL_STATEMENT ); -- put PK column here


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
     ( 'Exception occurred in PROCESS_REQS:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
       'CSM_REQUIREMENTS_PKG.PROCESS_REQS',
       FND_LOG.LEVEL_EXCEPTION ); -- put PK column here

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

   CSM_UTIL_PKG.LOG
         ( 'Entering CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

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
      CSM_UTIL_PKG.LOG
         ( 'Record successfully processed, deleting from inqueue'|| ' for PK ' ||r_requirements.requirement_line_id,
          'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
          FND_LOG.LEVEL_PROCEDURE ); -- put PK column here


      CSM_UTIL_PKG.DELETE_RECORD
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
       CSM_UTIL_PKG.LOG
         ( 'Deleting from inqueue failed, rolling back to savepoint'|| ' for PK ' ||r_requirements.requirement_line_id,
           'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
           FND_LOG.LEVEL_PROCEDURE ); -- put PK column here

        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/

      CSM_UTIL_PKG.LOG
         ( 'Record not processed successfully, deferring and rejecting record'|| ' for PK ' ||r_requirements.requirement_line_id,
           'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
           FND_LOG.LEVEL_PROCEDURE ); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_requirements.seqno$$
       , r_requirements.requirement_line_id -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       , r_requirements.dmltype$$
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
         ( 'Defer record failed, rolling back to savepoint'|| ' for PK ' ||r_requirements.requirement_line_id,
           'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
           FND_LOG.LEVEL_PROCEDURE ); -- put PK column here

        ROLLBACK TO save_rec;
      END IF;
    END IF;
  END LOOP;

  CSM_UTIL_PKG.LOG
      ( 'Leaving CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
        'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
         FND_LOG.LEVEL_STATEMENT ); -- put PK column here


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/

    CSM_UTIL_PKG.LOG
      ( 'Exception occurred in APPLY_CLIENT_CHANGES:'|| FND_GLOBAL.LOCAL_CHR(10) || sqlerrm,
        'CSM_REQUIREMENTS_PKG.PROCESS_REQS_NO_HEADERS',
         FND_LOG.LEVEL_EXCEPTION ); -- put PK column here


  x_return_status := FND_API.G_RET_STS_ERROR;

END PROCESS_REQS_NO_HEADERS;


/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_REQ_LINES
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

  CSM_UTIL_PKG.LOG
     ( 'Entering CSM_REQUIREMENTS_PKG.APPLY CLIENT CHANGES',
       'CSM_REQUIREMENTS_PKG.APPLY_CLIENT_CHANGES',
        FND_LOG.LEVEL_STATEMENT ); -- put PK column here

  -- First process all requirement lines that have a requirement header. Delete them after processing.
  PROCESS_REQS (p_user_name, p_tranid, x_return_status);

  -- Then process all remaining requirement lines (no requirement header). These already have a requirement header in Apps.
  PROCESS_REQS_NO_HEADERS(p_user_name, p_tranid, x_return_status);

  CSM_UTIL_PKG.LOG
       ( 'Leaving CSM_REQUIREMENTS_PKG.APPLY CLIENT CHANGES',
         'CSM_REQUIREMENTS_PKG.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_STATEMENT ); -- put PK column here

END APPLY_CLIENT_CHANGES;


   -- Enter further code below as specified in the Package spec.
END;

/
