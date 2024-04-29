--------------------------------------------------------
--  DDL for Package Body CSM_DEBRIEF_LABOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DEBRIEF_LABOR_PKG" AS
/* $Header: csmudblb.pls 120.4.12010000.2 2009/09/04 06:05:55 trajasek ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     06/10/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_LABOR_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_DEBRIEF_LABOR';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_debrief_labor( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csf_m_debrief_labor_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_debrief_labor%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

cursor c_deb_head
       ( b_task_assignment_id number
       )
is
select debrief_header_id
,      task_assignment_id
from   csf_debrief_headers
where  task_assignment_id = b_task_assignment_id;

cursor c_task_obj_code
       ( b_task_assignment_id number
       )
is
select source_object_type_code
from   jtf_tasks_b jtb
,      jtf_task_assignments jta
where  jtb.task_id = jta.task_id
and    jta.task_assignment_id = b_task_assignment_id;

r_deb_head c_deb_head%rowtype;
r_task_obj_code c_task_obj_code%rowtype;

-- Cursor to check if the Assignment Status is either of the
-- following rejected, on_hold, cancelled, closed or completed
CURSOR c_chk_task_status
     (  p_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE
     ) IS
SELECT tst.rejected_flag, tst.on_hold_flag, tst.cancelled_flag,
       tst.closed_flag, tst.completed_flag
FROM csf_debrief_headers dh, jtf_task_assignments tas,
     jtf_task_statuses_b tst
WHERE dh.task_assignment_id = tas.task_assignment_id
AND tas.assignment_status_id = tst.task_status_id
AND dh.debrief_header_id = p_debrief_header_id;

l_rejected_flag          VARCHAR2(1);
l_on_hold_flag           VARCHAR2(1);
l_cancelled_flag         VARCHAR2(1);
l_closed_flag            VARCHAR2(1);
l_completed_flag         VARCHAR2(1);

l_deb_rec                csf_debrief_pub.debrief_rec_type;

l_line_rec               csf_debrief_pub.debrief_line_rec_type;
l_line_tbl               csf_debrief_pub.debrief_line_tbl_type;


l_debrief_header_id      number;
l_date                   date           := sysdate;

l_issuing_inventory_org_id   csf_debrief_lines.issuing_inventory_org_id%TYPE;
l_receiving_inventory_org_id   csf_debrief_lines.receiving_inventory_org_id%TYPE;

l_msg_data               varchar2(1024);
l_msg_count              number;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start with some initialization.
-- We need to know if a debrief header record has been made
-- form this task_assignment_id. In that case we have to
-- reuse it instead of creating one.
-- Prerequisite: at most one record exist with the
-- task_assignment_id we're looking for.
open c_deb_head
     ( p_record.task_assignment_id
     );
fetch c_deb_head into r_deb_head;
if c_deb_head%found
then
   l_debrief_header_id := r_deb_head.debrief_header_id;
else
   l_debrief_header_id := null;
end if;
close c_deb_head;



-- Create a debrief header record.
l_deb_rec.debrief_date       := l_date;
--l_deb_rec.debrief_number     := To_Char( l_debrief_header_id );

l_deb_rec.task_assignment_id := p_record.task_assignment_id;
l_deb_rec.debrief_header_id  := l_debrief_header_id;
l_deb_rec.debrief_status_id  := NULL;
l_deb_rec.last_update_date   := l_date;
l_deb_rec.last_updated_by    := NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID); --12.1
l_deb_rec.creation_date      := l_date;
l_deb_rec.created_by         := NVL(p_record.created_by,FND_GLOBAL.USER_ID);  --12.1
l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;


if l_debrief_header_id is null
then
   -- Create a debrief header.
   l_deb_rec.debrief_number     := null ;

   csf_debrief_pub.create_debrief
   ( p_api_version_number => 1.0
   , p_init_msg_list      => FND_API.G_TRUE
   , p_commit             => FND_API.G_FALSE
   , p_debrief_rec        => l_deb_rec
   , p_debrief_line_tbl   => l_line_tbl
   , x_debrief_header_id  => l_debrief_header_id
   , x_return_status      => x_return_status
   , x_msg_count          => l_msg_count
   , x_msg_data           => l_msg_data
   );
   -- This could have failed, so we need to check.
   if x_return_status <> FND_API.G_RET_STS_SUCCESS
   then
      /*** exception occurred in API -> return errmsg ***/
      p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
      CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
               || ' ROOT ERROR: csf_debrief_pub.create_debrief'
               || ' for PK ' || p_record.DEBRIEF_LINE_ID, 'CSM_DEBRIEF_LABOR_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR );
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   end if;
end if;

-- Make the debrief line.

-- Retrieve the issuing organization id.
-- We may have to replace this with another master_organization_id.


l_line_rec.debrief_line_id          := p_record.debrief_line_id;
l_line_rec.debrief_header_id        := l_debrief_header_id;

l_line_rec.issuing_inventory_org_id := l_issuing_inventory_org_id;
l_line_rec.receiving_inventory_org_id := l_receiving_inventory_org_id;
l_line_rec.last_update_date         := l_date;
l_line_rec.last_updated_by          := NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID); --12.1
l_line_rec.creation_date            := l_date;
l_line_rec.created_by               := NVL(p_record.created_by,FND_GLOBAL.USER_ID); --12.1
l_line_rec.last_update_login        := FND_GLOBAL.LOGIN_ID;
l_line_rec.inventory_item_id        := p_record.inventory_item_id;
l_line_rec.txn_billing_type_id      := p_record.txn_billing_type_id;
l_line_rec.service_date             := p_record.service_date;
--l_line_rec.debrief_line_number      := To_Char( p_record.debrief_line_id );
l_line_rec.labor_start_date         := p_record.labor_start_date;
l_line_rec.labor_end_date           := p_record.labor_end_date;
l_line_rec.business_process_id      := p_record.business_process_id;
l_line_rec.channel_code		    	:= 'CSF_MFS';
l_line_rec.transaction_type_id      := p_record.transaction_type_id;
l_line_rec.uom_code		            := p_record.uom_code;
l_line_rec.quantity		            := p_record.quantity;
l_line_rec.labor_reason_code	    := p_record.labor_reason_code;
l_line_rec.attribute1               := p_record.attribute1;
l_line_rec.attribute2               := p_record.attribute2;
l_line_rec.attribute3               := p_record.attribute3;
l_line_rec.attribute4               := p_record.attribute4;
l_line_rec.attribute5               := p_record.attribute5;
l_line_rec.attribute6               := p_record.attribute6;
l_line_rec.attribute7               := p_record.attribute7;
l_line_rec.attribute8               := p_record.attribute8;
l_line_rec.attribute9               := p_record.attribute9;
l_line_rec.attribute10              := p_record.attribute10;
l_line_rec.attribute11              := p_record.attribute11;
l_line_rec.attribute12              := p_record.attribute12;
l_line_rec.attribute13              := p_record.attribute13;
l_line_rec.attribute14              := p_record.attribute14;
l_line_rec.attribute15              := p_record.attribute15;
l_line_rec.attribute_category       := p_record.attribute_category;

l_line_tbl(1) := l_line_rec;

-- Fetch SOURCE_OBJECT_TYPE_CODE from task record
open c_task_obj_code
     ( p_record.task_assignment_id
     );
fetch c_task_obj_code into r_task_obj_code;
close c_task_obj_code;

csf_debrief_pub.create_debrief_lines
( p_api_version_number      => 1.0
, p_init_msg_list           => FND_API.G_TRUE
, p_commit                  => FND_API.G_FALSE
, x_return_status           => x_return_status
, x_msg_count               => l_msg_count
, x_msg_data                => l_msg_data
, p_debrief_header_id       => l_debrief_header_id
, p_debrief_line_tbl        => l_line_tbl
, p_source_object_type_code => r_task_obj_code.source_object_type_code
);
if x_return_status <> FND_API.G_RET_STS_SUCCESS
then
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
               || ' ROOT ERROR: csf_debrief_pub.create_debrief_lines'
               || ' for PK ' || p_record.DEBRIEF_LINE_ID ,'CSM_DEBRIEF_LABOR_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR );
   x_return_status := FND_API.G_RET_STS_ERROR;
   return;
end if;

-- For a given debrief header check the task Assignment status.
-- If it is one of the following -
-- rejected, on_hold, cancelled, closed or completed then call the api
--  csf_debrief_update_pkg.form_Call for processing charges

    OPEN c_chk_task_status ( l_debrief_header_id );
    FETCH c_chk_task_status INTO l_rejected_flag, l_on_hold_flag,
       l_cancelled_flag, l_closed_flag, l_completed_flag;

    IF c_chk_task_status%FOUND THEN
       IF ( (l_rejected_flag='Y') OR (l_on_hold_flag='Y') OR (l_cancelled_flag='Y')
          OR (l_closed_flag='Y') OR (l_completed_flag='Y') ) THEN
          csf_debrief_update_pkg.form_Call (1.0, l_debrief_header_id );
       END IF;
    END IF;

    CLOSE c_chk_task_status;

exception
  when others then
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
               || ' for PK ' || p_record.DEBRIEF_LINE_ID ,'CSM_DEBRIEF_LABOR_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);

     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_debrief_labor%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

CURSOR c_cdl( b_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE )
IS
    SELECT cdl.debrief_header_id
    ,      cdl.debrief_line_id
    ,      cdl.last_update_date
    ,      cdl.issuing_inventory_org_id
    FROM   csf_debrief_lines cdl
    WHERE  cdl.debrief_line_id = b_debrief_line_id;

r_cdl c_cdl%ROWTYPE;
l_line_rec               csf_debrief_pub.debrief_line_rec_type;
l_debrief_header_id      NUMBER;
l_date                   DATE  := sysdate;
l_msg_data               VARCHAR2(2000);
l_msg_count              NUMBER;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Lookup the debrief_header id. It must be there as this is an update
-- of a line.
  OPEN c_cdl    (b_debrief_line_id => p_record.debrief_line_id    );
  FETCH c_cdl  INTO r_cdl;
  IF c_cdl%found
  THEN
    l_debrief_header_id := r_cdl.debrief_header_id;
  ELSE
    -- Let the API complain about it.
    l_debrief_header_id := NULL;
  END IF;
  CLOSE c_cdl;

-- Make the debrief line.
l_line_rec.issuing_inventory_org_id := r_cdl.issuing_inventory_org_id;
l_line_rec.debrief_line_id          := p_record.debrief_line_id;
l_line_rec.debrief_header_id        := l_debrief_header_id;
l_line_rec.last_update_date         := l_date;
l_line_rec.last_updated_by          :=  NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID);  --12.1
l_line_rec.last_update_login        := FND_GLOBAL.LOGIN_ID;
l_line_rec.inventory_item_id        := p_record.inventory_item_id;
l_line_rec.txn_billing_type_id      := p_record.txn_billing_type_id;
l_line_rec.service_date             := p_record.service_date;
--l_line_rec.debrief_line_number      := To_Char( p_record.debrief_line_id );
l_line_rec.labor_start_date         := p_record.labor_start_date;
l_line_rec.labor_end_date           := p_record.labor_end_date;
l_line_rec.business_process_id      := p_record.business_process_id;
l_line_rec.channel_code		          := 'CSF_MFS';
l_line_rec.transaction_type_id      := p_record.transaction_type_id;
l_line_rec.quantity                 := p_record.quantity;
l_line_rec.uom_code                 := p_record.uom_code;
l_line_rec.labor_reason_code	      := p_record.labor_reason_code;
l_line_rec.attribute1               := p_record.attribute1;
l_line_rec.attribute2               := p_record.attribute2;
l_line_rec.attribute3               := p_record.attribute3;
l_line_rec.attribute4               := p_record.attribute4;
l_line_rec.attribute5               := p_record.attribute5;
l_line_rec.attribute6               := p_record.attribute6;
l_line_rec.attribute7               := p_record.attribute7;
l_line_rec.attribute8               := p_record.attribute8;
l_line_rec.attribute9               := p_record.attribute9;
l_line_rec.attribute10              := p_record.attribute10;
l_line_rec.attribute11              := p_record.attribute11;
l_line_rec.attribute12              := p_record.attribute12;
l_line_rec.attribute13              := p_record.attribute13;
l_line_rec.attribute14              := p_record.attribute14;
l_line_rec.attribute15              := p_record.attribute15;
l_line_rec.attribute_category       := p_record.attribute_category;

--check for the stale data
  -- SERVER_WINS profile value
  IF(fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE)
       = csm_profile_pkg.g_SERVER_WINS) THEN
    IF(r_cdl.last_update_date <> p_record.server_last_update_date) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg :=
          'UPWARD SYNC CONFLICT: CLIENT LOST: CSM_DEBRIEF_LABOR_PKG.APPLY_UPDATE: P_KEY = '
          || p_record.debrief_line_id;
       csm_util_pkg.log(p_error_msg,'CSM_DEBRIEF_LABOR_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR);
       return;
    END IF;
  END IF;

  --CLIENT_WINS (or client is allowd to update the record)

-- Update the debrief line
csf_debrief_pub.update_debrief_line
( p_api_version_number      => 1.0
, p_init_msg_list           => FND_API.G_TRUE
, p_commit                  => FND_API.G_FALSE
, x_return_status           => x_return_status
, x_msg_count               => l_msg_count
, x_msg_data                => l_msg_data
, p_debrief_line_rec        => l_line_rec
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS
THEN
   /*** exception occurred in API -> return errmsg ***/
   p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
   CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
               || ' ROOT ERROR: csf_debrief_pub.update_debrief_lines'
               || ' for PK ' || p_record.DEBRIEF_LINE_ID,'CSM_DEBRIEF_LABOR_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR );
   x_return_status := FND_API.G_RET_STS_ERROR;
   return;
END IF;

EXCEPTION
  WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (       p_api_error      => TRUE     );

     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.DEBRIEF_LINE_ID,'CSM_DEBRIEF_LABOR_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;


/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_debrief_labor%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
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
  ELSE
    -- Process delete; not supported for this entity
      CSM_UTIL_PKG.LOG
        ( 'Delete is not supported for this entity'
      || ' for PK ' || p_record.debrief_line_id ,'CSM_DEBRIEF_LABOR_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in CSM_DEBRIEF_labor_PKG.APPLY_RECORD:' || ' ' || sqlerrm
      || ' for PK ' || p_record.debrief_line_id ,'CSM_DEBRIEF_LABOR_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSM_UTIL_PKG when publication item <replace>
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
  csm_util_pkg.log('csm_debrief_labor_pkg.apply_client_changes entered','CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through debrief labor records in inqueue ***/
  FOR r_debrief_labor IN c_debrief_labor( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_debrief_labor
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
          r_debrief_labor.seqno$$,
          r_debrief_labor.debrief_line_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
      || ' for PK ' || r_debrief_labor.debrief_line_id ,'CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_debrief_labor.debrief_line_id ,'CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_debrief_labor.seqno$$
       , r_debrief_labor.debrief_line_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_debrief_labor.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
      || ' for PK ' || r_debrief_labor.debrief_line_id,'CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,'CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_DEBRIEF_LABOR_PKG;

/
