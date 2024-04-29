--------------------------------------------------------
--  DDL for Package Body CSM_DEBRIEF_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DEBRIEF_HEADERS_PKG" AS
/* $Header: csmudbhb.pls 120.5.12010000.2 2010/04/29 16:32:52 trajasek ship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Melvin P   08/05/03 Create

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_debrief_headers( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csm_debrief_headers_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_debrief_notes(p_debrief_header_id number, b_user_name varchar2, b_tranid number)
IS
SELECT jtf_note_id, source_object_id
FROM csf_m_notes_inq
WHERE tranid$$ = b_tranid
AND clid$$cs = b_user_name
AND source_object_code = 'SD'
AND source_object_id = p_debrief_header_id
FOR UPDATE OF source_object_id NOWAIT;

CURSOR c_debrief (p_task_assignment_id number)
IS
SELECT debrief_header_id
FROM csf_debrief_headers
WHERE task_assignment_id = p_task_assignment_id;

CURSOR c_debrief_signature(p_debrief_header_id IN NUMBER, b_user_name IN VARCHAR2,
                           b_tranid IN NUMBER)
IS
SELECT file_id, pk1_value
FROM csf_m_lobs_inq
WHERE tranid$$ = b_tranid
AND clid$$cs = b_user_name
AND entity_name = 'CSF_DEBRIEF_HEADERS'
AND to_number(pk1_value) = p_debrief_header_id
FOR UPDATE OF pk1_value NOWAIT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_debrief_headers%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS

cursor c_deb_head
       ( b_task_assignment_id number
       )
is
select debrief_header_id
,      debrief_number
,      debrief_date
,      debrief_status_id
,      task_assignment_id
,      last_updated_by
,      last_update_date
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE_CATEGORY
from   csf_debrief_headers
where  task_assignment_id = b_task_assignment_id;

r_deb_head c_deb_head%rowtype;

l_deb_rec                csf_debrief_pub.debrief_rec_type;
l_line_rec               csf_debrief_pub.debrief_line_rec_type;
l_line_tbl               csf_debrief_pub.debrief_line_tbl_type;

l_debrief_header_id      number;
l_date                   date           := sysdate;

l_msg_data               varchar2(1024);
l_msg_count              number;

l_transaction_id           number;
l_transaction_header_id    number;
l_profile_value         varchar2(240);

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

if l_debrief_header_id is null
THEN
   -- Create a debrief header record.
   l_deb_rec.debrief_date       := l_date;
   l_debrief_header_id          := p_record.debrief_header_id;
--   l_deb_rec.debrief_number     := To_Char( p_record.debrief_header_id );

   l_deb_rec.task_assignment_id := p_record.task_assignment_id;
   l_deb_rec.debrief_header_id  := l_debrief_header_id;
   l_deb_rec.debrief_status_id  := NULL;
   l_deb_rec.last_update_date   := l_date;
   l_deb_rec.last_updated_by    := NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID);  --12.1
   l_deb_rec.creation_date      := l_date;
   l_deb_rec.created_by         := NVL(p_record.created_by,FND_GLOBAL.USER_ID);  --12.1
   l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;
   l_deb_rec.attribute1         := p_record.attribute1;
   l_deb_rec.attribute2         := p_record.attribute2;
   l_deb_rec.attribute3         := p_record.attribute3;
   l_deb_rec.attribute4         := p_record.attribute4;
   l_deb_rec.attribute5         := p_record.attribute5;
   l_deb_rec.attribute6         := p_record.attribute6;
   l_deb_rec.attribute7         := p_record.attribute7;
   l_deb_rec.attribute8         := p_record.attribute8;
   l_deb_rec.attribute9         := p_record.attribute9;
   l_deb_rec.attribute10        := p_record.attribute10;
   l_deb_rec.attribute11        := p_record.attribute11;
   l_deb_rec.attribute12        := p_record.attribute12;
   l_deb_rec.attribute13        := p_record.attribute13;
   l_deb_rec.attribute14        := p_record.attribute14;
   l_deb_rec.attribute15        := p_record.attribute15;
   l_deb_rec.attribute_category := p_record.attribute_category;
   --Bug 5199436
   l_deb_rec.TRAVEL_START_TIME  := p_record.TRAVEL_START_TIME;
   l_deb_rec.TRAVEL_END_TIME    := p_record.TRAVEL_END_TIME;
   l_deb_rec.TRAVEL_DISTANCE_IN_KM := p_record.TRAVEL_DISTANCE_IN_KM;
   -- Create a debrief header.
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
               || ' for PK ' || p_record.DEBRIEF_HEADER_ID,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   ELSE
        -- successful insert...need to reject the record on client
        -- as debrief_header_id and debrief_number are generated by the API
            CSM_UTIL_PKG.LOG ( 'Record successfully processed, rejecting record ' || ' for PK '
                 || p_record.debrief_header_id
                 ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
                 ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

            CSM_UTIL_PKG.REJECT_RECORD
            (
             p_record.clid$$cs,
             p_record.tranid$$,
             p_record.seqno$$,
             p_record.debrief_header_id,
             g_object_name,
             g_pub_name,
             l_msg_data,
             x_return_status
             );

            IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
               /*** Reject successful ***/
               CSM_UTIL_PKG.LOG
               ( 'Debrief Header record rejected ' || ' for PK '
                || p_record.debrief_header_id
                ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
                ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here
            ELSE
               /*** Reject unsuccessful ***/
               CSM_UTIL_PKG.LOG
               ( 'Debrief Header record not rejected ' || ' for PK '
                || p_record.debrief_header_id
                ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
                ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
            END IF;
   end if;
ELSE
  -- debrief header already exists at the backend
  -- reject record on client
       CSM_UTIL_PKG.LOG ( 'Record successfully processed, rejecting record ' || ' for PK '
                || p_record.debrief_header_id
                 ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
                 ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

       CSM_UTIL_PKG.REJECT_RECORD
       (
         p_record.clid$$cs,
         p_record.tranid$$,
         p_record.seqno$$,
         p_record.debrief_header_id,
         g_object_name,
         g_pub_name,
         l_msg_data,
         x_return_status
        );

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          /*** Reject successful ***/
          CSM_UTIL_PKG.LOG
          ( 'Debrief Header record rejected ' || ' for PK '
             || p_record.debrief_header_id
             ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
             ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here
        ELSE
           /*** Reject unsuccessful ***/
           CSM_UTIL_PKG.LOG
           ( 'Debrief Header record not rejected ' || ' for PK '
              || p_record.debrief_header_id
              ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT'
              ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;

  -- check for conflict detection
  l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);

  -- SERVER_WINS profile value
  IF(l_profile_value = csm_profile_pkg.g_SERVER_WINS) AND
     ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_pub_name, p_record.seqno$$) <> FND_API.G_TRUE   THEN
    IF(r_deb_head.last_update_date <> p_record.server_last_update_date AND r_deb_head.last_updated_by <> NVL(p_record.last_updated_by,asg_base.get_user_id(p_record.clid$$cs))) THEN  --12.1
      p_error_msg := 'UPWARD SYNC CONFLICT: CLIENT LOST For CSF_DEBRIEF_HEADERS: CSM_DEBRIEF_HEADERS_PKG.APPLY_UPDATE: P_KEY = '
        || p_record.debrief_header_id;
      x_return_status := FND_API.G_RET_STS_ERROR;
      csm_util_pkg.log(p_error_msg, g_object_name || '.APPLY_UPDATE',  FND_LOG.LEVEL_ERROR);
      RETURN;
    END IF;
  ELSE -- client wins
       -- apply client DFF's incase they exist since the last_updated_by is the same
         -- Update the debrief header record.
         l_deb_rec.debrief_date       := r_deb_head.debrief_date;
         l_deb_rec.debrief_number     := r_deb_head.debrief_number;

         l_deb_rec.task_assignment_id := r_deb_head.task_assignment_id;
         l_deb_rec.debrief_header_id  := r_deb_head.debrief_header_id;
         l_deb_rec.debrief_status_id  := r_deb_head.debrief_status_id;
         l_deb_rec.last_update_date   := l_date;
         l_deb_rec.last_updated_by    := NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID);  --12.1
         l_deb_rec.creation_date      := l_date;
         l_deb_rec.created_by         := NVL(p_record.created_by,FND_GLOBAL.USER_ID);  --12.1
         l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;
         l_deb_rec.attribute1         := p_record.attribute1;
         l_deb_rec.attribute2         := p_record.attribute2;
         l_deb_rec.attribute3         := p_record.attribute3;
         l_deb_rec.attribute4         := p_record.attribute4;
         l_deb_rec.attribute5         := p_record.attribute5;
         l_deb_rec.attribute6         := p_record.attribute6;
         l_deb_rec.attribute7         := p_record.attribute7;
         l_deb_rec.attribute8         := p_record.attribute8;
         l_deb_rec.attribute9         := p_record.attribute9;
         l_deb_rec.attribute10        := p_record.attribute10;
         l_deb_rec.attribute11        := p_record.attribute11;
         l_deb_rec.attribute12        := p_record.attribute12;
         l_deb_rec.attribute13        := p_record.attribute13;
         l_deb_rec.attribute14        := p_record.attribute14;
         l_deb_rec.attribute15        := p_record.attribute15;
         l_deb_rec.attribute_category := p_record.attribute_category;
         --Bug 5199436
         l_deb_rec.TRAVEL_START_TIME  := p_record.TRAVEL_START_TIME;
         l_deb_rec.TRAVEL_END_TIME    := p_record.TRAVEL_END_TIME;
         l_deb_rec.TRAVEL_DISTANCE_IN_KM := p_record.TRAVEL_DISTANCE_IN_KM;


         -- update the debrief line
         csf_debrief_pub.Update_debrief(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_TRUE,
            p_commit               => FND_API.G_FALSE,
            p_debrief_rec          => l_deb_rec,
            X_Return_Status        => x_return_status,
            X_Msg_Count            => l_msg_count,
            X_Msg_Data             => l_msg_data
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
                        || ' for PK ' || r_deb_head.DEBRIEF_HEADER_ID,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
         end if;
    END IF;
END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

exception
  when others then
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );

     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
               || ' for PK ' || p_record.DEBRIEF_HEADER_ID,'CSM_DEBRIEF_HEADERS_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION );
     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;


PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_debrief_headers%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

CURSOR c_debrief_header
   ( b_debrief_header_id number,
     b_task_assignment_id number
   )
IS
SELECT dh.debrief_header_id
,      dh.debrief_number
,      dh.last_update_date
,      dh.last_updated_by
 FROM csf_debrief_headers dh
WHERE dh.debrief_header_id = b_debrief_header_id
UNION
SELECT dh.debrief_header_id
,      dh.debrief_number
,      dh.last_update_date
,      dh.last_updated_by
 FROM csf_debrief_headers dh
WHERE dh.task_assignment_id = b_task_assignment_id
;

r_debrief_header        c_debrief_header%ROWTYPE;
l_profile_value         varchar2(240);
l_deb_rec               csf_debrief_pub.debrief_rec_type;
l_date                  date           := sysdate;
-- Declare OUT parameters
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

BEGIN
  l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');

  IF l_profile_value = 'SERVER_WINS' AND
     ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_pub_name, p_record.seqno$$) <> FND_API.G_TRUE THEN
    OPEN c_debrief_header(b_debrief_header_id => p_record.debrief_header_id, b_task_assignment_id => p_record.task_assignment_id);
    FETCH c_debrief_header INTO r_debrief_header;
    IF c_debrief_header%FOUND THEN
      IF (r_debrief_header.last_update_date <> p_record.server_last_update_date AND r_debrief_header.last_updated_by <> NVL(p_record.last_updated_by,asg_base.get_user_id(p_record.clid$$cs))) THEN --12.1
        CLOSE c_debrief_header;
        CSM_UTIL_PKG.log( 'Record has stale data. Leaving  ' || g_object_name || '.APPLY_UPDATE:'
          || ' for PK ' || p_record.debrief_header_id,
          g_object_name || '.APPLY_UPDATE',
          FND_LOG.LEVEL_PROCEDURE );
        fnd_message.set_name
          ( 'JTM'
          , 'JTM_STALE_DATA'
          );
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    ELSE
      CSM_UTIL_PKG.log( 'No record found in Apps Database in ' || g_object_name || '.APPLY_UPDATE:',
          g_object_name || '.APPLY_UPDATE',
          FND_LOG.LEVEL_PROCEDURE );
    END IF;
    CLOSE c_debrief_header;
  ELSE--if client wins or if server wins and the record is deferred Bug 5088801
    OPEN c_debrief_header(b_debrief_header_id => p_record.debrief_header_id, b_task_assignment_id => p_record.task_assignment_id);
    FETCH c_debrief_header INTO r_debrief_header;
    CLOSE c_debrief_header;
  END IF;

    -- Update the debrief header record.
    l_deb_rec.debrief_date       := p_record.debrief_date;
    l_deb_rec.debrief_number     := r_debrief_header.debrief_number;

    l_deb_rec.task_assignment_id := p_record.task_assignment_id;
    l_deb_rec.debrief_header_id  := r_debrief_header.debrief_header_id;
    l_deb_rec.debrief_status_id  := p_record.debrief_status_id;
    l_deb_rec.last_update_date   := l_date;
    l_deb_rec.last_updated_by    := NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID); --12.1
    l_deb_rec.creation_date      := l_date;
    l_deb_rec.created_by         := NVL(p_record.created_by,FND_GLOBAL.USER_ID); --12.1
    l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;
    l_deb_rec.attribute1         := p_record.attribute1;
    l_deb_rec.attribute2         := p_record.attribute2;
    l_deb_rec.attribute3         := p_record.attribute3;
    l_deb_rec.attribute4         := p_record.attribute4;
    l_deb_rec.attribute5         := p_record.attribute5;
    l_deb_rec.attribute6         := p_record.attribute6;
    l_deb_rec.attribute7         := p_record.attribute7;
    l_deb_rec.attribute8         := p_record.attribute8;
    l_deb_rec.attribute9         := p_record.attribute9;
    l_deb_rec.attribute10        := p_record.attribute10;
    l_deb_rec.attribute11        := p_record.attribute11;
    l_deb_rec.attribute12        := p_record.attribute12;
    l_deb_rec.attribute13        := p_record.attribute13;
    l_deb_rec.attribute14        := p_record.attribute14;
    l_deb_rec.attribute15        := p_record.attribute15;
    l_deb_rec.attribute_category := p_record.attribute_category;
    --Bug 5199436
    l_deb_rec.TRAVEL_START_TIME  := p_record.TRAVEL_START_TIME;
    l_deb_rec.TRAVEL_END_TIME    := p_record.TRAVEL_END_TIME;
    l_deb_rec.TRAVEL_DISTANCE_IN_KM := p_record.TRAVEL_DISTANCE_IN_KM;

    -- update the debrief line
    csf_debrief_pub.Update_debrief(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_TRUE,
            p_commit               => FND_API.G_FALSE,
            p_debrief_rec          => l_deb_rec,
            X_Return_Status        => x_return_status,
            X_Msg_Count            => l_msg_count,
            X_Msg_Data             => l_msg_data
           );

    -- This could have failed, so we need to check.
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        /*** exception occurred in API -> return errmsg ***/
        p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
                         (
                          p_api_error      => TRUE
                         );
        CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
                        || ' ROOT ERROR: csf_debrief_pub.update_debrief'
                        || ' for PK ' || p_record.DEBRIEF_HEADER_ID,'CSM_DEBRIEF_HEADERS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR);
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
       || ' for PK ' || p_record.debrief_header_id,
       g_object_name || '.APPLY_UPDATE',
       FND_LOG.LEVEL_EXCEPTION );

       x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_debrief_headers%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
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
    -- Process delete not supported for this entity
      CSM_UTIL_PKG.LOG
        ( 'Delete is not supported for this entity'
      || ' for PK ' || p_record.debrief_header_id ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

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
    ( 'Exception occurred in CSM_DEBRIEF_HEADERS_PKG.APPLY_RECORD:' || ' ' || sqlerrm
      || ' for PK ' || p_record.debrief_header_id,'CSM_DEBRIEF_HEADERS_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION );

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
           x_return_status IN out nocopy VARCHAR2
         ) IS
l_process_status VARCHAR2(1);
l_error_msg      VARCHAR2(4000);
l_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE;

BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through debrief parts records in inqueue ***/
  FOR r_debrief_headers IN c_debrief_headers( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_debrief_headers
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      -- check to see if any notes exist for the debrief_header
      -- if exists update source_object_id column to new value for debrief_header_id

      OPEN c_debrief(r_debrief_headers.task_assignment_id);
      FETCH c_debrief INTO l_debrief_header_id;
      IF c_debrief%FOUND THEN
         FOR r_debrief_notes IN c_debrief_notes(r_debrief_headers.debrief_header_id, r_debrief_headers.clid$$cs, r_debrief_headers.tranid$$) LOOP
           UPDATE csf_m_notes_inq
           SET source_object_id = l_debrief_header_id
           WHERE CURRENT OF c_debrief_notes;
         END LOOP;

         FOR r_debrief_signature IN c_debrief_signature(r_debrief_headers.debrief_header_id, r_debrief_headers.clid$$cs, r_debrief_headers.tranid$$) LOOP
           UPDATE csf_m_lobs_inq
           SET pk1_value = l_debrief_header_id
           WHERE CURRENT OF c_debrief_signature;
         END LOOP;

      END IF;
      CLOSE c_debrief;

      /*** Yes -> delete record from inqueue ***/

      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_debrief_headers.seqno$$,
          r_debrief_headers.debrief_header_id,
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
      || ' for PK ' || r_debrief_headers.debrief_header_id,'CSM_DEBRIEF_HEADERS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      OPEN c_debrief(r_debrief_headers.task_assignment_id);
      FETCH c_debrief INTO l_debrief_header_id;
      IF c_debrief%FOUND THEN
         FOR r_debrief_notes IN c_debrief_notes(r_debrief_headers.debrief_header_id, r_debrief_headers.clid$$cs, r_debrief_headers.tranid$$) LOOP
           UPDATE csf_m_notes_inq
           SET source_object_id = l_debrief_header_id
           WHERE CURRENT OF c_debrief_notes;
         END LOOP;
         FOR r_debrief_signature IN c_debrief_signature(r_debrief_headers.debrief_header_id, r_debrief_headers.clid$$cs, r_debrief_headers.tranid$$) LOOP
           UPDATE csf_m_lobs_inq
           SET pk1_value = l_debrief_header_id
           WHERE CURRENT OF c_debrief_signature;
         END LOOP;

      END IF;
      CLOSE c_debrief;

      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_debrief_headers.debrief_header_id,'CSM_DEBRIEF_HEADERS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_debrief_headers.seqno$$
       , r_debrief_headers.debrief_header_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_debrief_headers.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
      || ' for PK ' || r_debrief_headers.debrief_header_id ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm
    ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
    x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 IS
l_profile_value VARCHAR2(30) ;
l_user_id NUMBER ;
cursor get_user_id(l_tran_id in number,
                   l_user_name in varchar2,
       l_sequence in number)
IS
SELECT b.last_updated_by
FROM csf_debrief_headers b,
     csm_debrief_headers_inq a
WHERE a.clid$$cs = l_user_name
AND tranid$$ = l_tran_id
AND seqno$$ = l_sequence
AND a.debrief_header_id = b.debrief_header_id ;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_DEBRIEF_HEADERS_PKG.CONFLICT_RESOLUTION_METHOD for user ' || p_user_name ,'CSM_DEBRIEF_HEADERS_PKG.CONFLICT_RESOLUTION_METHOD',FND_LOG.LEVEL_PROCEDURE);
 l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);
 OPEN get_user_id(p_tran_id, p_user_name, p_sequence) ;
 FETCH get_user_id  INTO l_user_id ;
 CLOSE get_user_id ;

  if l_profile_value = 'SERVER_WINS' AND l_user_id <> asg_base.get_user_id(p_user_name) then
      RETURN 'S' ;
  else
      RETURN 'C' ;
  END IF ;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'C';
END CONFLICT_RESOLUTION_METHOD;

--code for HA Debrief Header
PROCEDURE APPLY_HA_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_DEBRIEF_HEADER_ID   NUMBER;
L_DEB_HDR_REC         CSF_DEBRIEF_PUB.DEBRIEF_REC_TYPE;
L_LINE_REC               CSF_DEBRIEF_PUB.DEBRIEF_LINE_REC_TYPE;
L_LINE_TBL               CSF_DEBRIEF_PUB.DEBRIEF_LINE_TBL_TYPE;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Debrief Header
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'DEBRIEF_HEADER_ID' THEN
        L_DEB_HDR_REC.DEBRIEF_HEADER_ID := L_COL_VALUE_LIST(I);
        L_DEBRIEF_HEADER_ID             := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_NUMBER' THEN
        L_DEB_HDR_REC.DEBRIEF_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_DATE ' THEN
        L_DEB_HDR_REC.DEBRIEF_DATE  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_STATUS_ID' THEN
        L_DEB_HDR_REC.DEBRIEF_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_ASSIGNMENT_ID' THEN
        L_DEB_HDR_REC.TASK_ASSIGNMENT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_DEB_HDR_REC.CREATED_BY := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_DEB_HDR_REC.CREATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATED_BY ' THEN
        L_DEB_HDR_REC.LAST_UPDATED_BY  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_DATE' THEN
        L_DEB_HDR_REC.LAST_UPDATE_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_LOGIN' THEN
        L_DEB_HDR_REC.LAST_UPDATE_LOGIN := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_DEB_HDR_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_DEB_HDR_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_DEB_HDR_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_DEB_HDR_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_DEB_HDR_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_DEB_HDR_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_DEB_HDR_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_DEB_HDR_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_DEB_HDR_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_DEB_HDR_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_DEB_HDR_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_DEB_HDR_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_DEB_HDR_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_DEB_HDR_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_DEB_HDR_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_DEB_HDR_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
       L_DEB_HDR_REC.OBJECT_VERSION_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_START_TIME' THEN
       L_DEB_HDR_REC.TRAVEL_START_TIME := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_END_TIME' THEN
       L_DEB_HDR_REC.TRAVEL_END_TIME := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_DISTANCE_IN_KM' THEN
       L_DEB_HDR_REC.TRAVEL_DISTANCE_IN_KM := l_COL_VALUE_LIST(i);
      END IF;

     END IF;
  END LOOP;

  csf_debrief_pub.create_debrief(
    P_API_VERSION_NUMBER      => L_API_VERSION,
    P_INIT_MSG_LIST           => FND_API.G_TRUE,
    P_COMMIT                  => FND_API.G_FALSE,
    P_DEBRIEF_REC             => L_DEB_HDR_REC,
    p_debrief_line_tbl        => L_LINE_TBL,
    X_DEBRIEF_HEADER_ID       => L_DEBRIEF_HEADER_ID,
    X_RETURN_STATUS           => L_RETURN_STATUS,
    X_MSG_COUNT               => L_MSG_COUNT,
    X_MSG_DATA                => L_MSG_DATA
    );

   IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  END IF;

  x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Leaving CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_INSERT', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_HA_INSERT;
--Apply Update
PROCEDURE APPLY_HA_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_DEBRIEF_HEADER_ID   NUMBER;
L_DEB_HDR_REC         CSF_DEBRIEF_PUB.DEBRIEF_REC_TYPE;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Debrief Header
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'DEBRIEF_HEADER_ID' THEN
        L_DEB_HDR_REC.DEBRIEF_HEADER_ID := L_COL_VALUE_LIST(I);
        L_DEBRIEF_HEADER_ID             := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_NUMBER' THEN
        L_DEB_HDR_REC.DEBRIEF_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_DATE ' THEN
        L_DEB_HDR_REC.DEBRIEF_DATE  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_STATUS_ID' THEN
        L_DEB_HDR_REC.DEBRIEF_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_ASSIGNMENT_ID' THEN
        L_DEB_HDR_REC.TASK_ASSIGNMENT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_DEB_HDR_REC.CREATED_BY := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_DEB_HDR_REC.CREATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATED_BY ' THEN
        L_DEB_HDR_REC.LAST_UPDATED_BY  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_DATE' THEN
        L_DEB_HDR_REC.LAST_UPDATE_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_LOGIN' THEN
        L_DEB_HDR_REC.LAST_UPDATE_LOGIN := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_DEB_HDR_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_DEB_HDR_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_DEB_HDR_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_DEB_HDR_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_DEB_HDR_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_DEB_HDR_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_DEB_HDR_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_DEB_HDR_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_DEB_HDR_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_DEB_HDR_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_DEB_HDR_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_DEB_HDR_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_DEB_HDR_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_DEB_HDR_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_DEB_HDR_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_DEB_HDR_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
       L_DEB_HDR_REC.OBJECT_VERSION_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_START_TIME' THEN
       L_DEB_HDR_REC.TRAVEL_START_TIME := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_END_TIME' THEN
       L_DEB_HDR_REC.TRAVEL_END_TIME := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TRAVEL_DISTANCE_IN_KM' THEN
       L_DEB_HDR_REC.TRAVEL_DISTANCE_IN_KM := l_COL_VALUE_LIST(i);
      END IF;

     END IF;
  END LOOP;

  csf_debrief_pub.update_debrief(
    P_API_VERSION_NUMBER      => L_API_VERSION,
    P_INIT_MSG_LIST           => FND_API.G_TRUE,
    P_COMMIT                  => FND_API.G_FALSE,
    P_DEBRIEF_REC             => L_DEB_HDR_REC,
    X_RETURN_STATUS           => L_RETURN_STATUS,
    X_MSG_COUNT               => L_MSG_COUNT,
    X_MSG_DATA                => L_MSG_DATA
    );

   IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  END IF;

  x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Leaving CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_UPDATE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := S_MSG_DATA;
END APPLY_HA_UPDATE;

PROCEDURE APPLY_HA_HEADER_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_HA_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );

  NULL;
  END IF;

  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_DEBRIEF_HEADERS_PKG.APPLY_HA_HEADER_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_HEADER_CHANGES;

--code for HA Debrief Line
PROCEDURE APPLY_DEBRIEF_LINE_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_DEBRIEF_HEADER_ID   NUMBER;
L_DEB_HDR_REC         CSF_DEBRIEF_PUB.DEBRIEF_REC_TYPE;
L_LINE_REC               CSF_DEBRIEF_PUB.DEBRIEF_LINE_REC_TYPE;
L_LINE_TBL               CSF_DEBRIEF_PUB.DEBRIEF_LINE_TBL_TYPE;
L_UPD_TSKASSGNSTATUS       VARCHAR2(100):= NULL;
L_TASK_ASSIGNMENT_STATUS   VARCHAR2(100):= NULL;
L_SOURCE_OBJECT_TYPE_CODE  VARCHAR2(100):= NULL;

BEGIN

  CSM_UTIL_PKG.LOG('Entering APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Debrief Header
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'DEBRIEF_LINE_ID' THEN
        L_LINE_REC.DEBRIEF_LINE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DEBRIEF_HEADER_ID' THEN
        L_LINE_REC.DEBRIEF_HEADER_ID := L_COL_VALUE_LIST(I);
        L_DEBRIEF_HEADER_ID             := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_LINE_NUMBER' THEN
        L_LINE_REC.DEBRIEF_LINE_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SERVICE_DATE' THEN
        L_LINE_REC.SERVICE_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'BUSINESS_PROCESS_ID' THEN
        L_LINE_REC.BUSINESS_PROCESS_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'TXN_BILLING_TYPE_ID' THEN
        L_LINE_REC.TXN_BILLING_TYPE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INVENTORY_ITEM_ID' THEN
        L_LINE_REC.INVENTORY_ITEM_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INSTANCE_ID' THEN
        L_LINE_REC.INSTANCE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_INVENTORY_ORG_ID' THEN
        L_LINE_REC.ISSUING_INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RECEIVING_INVENTORY_ORG_ID' THEN
        L_LINE_REC.RECEIVING_INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_SUB_INVENTORY_CODE' THEN
        L_LINE_REC.ISSUING_SUB_INVENTORY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RECEIVING_SUB_INVENTORY_CODE' THEN
        L_LINE_REC.RECEIVING_SUB_INVENTORY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_LOCATOR_ID' THEN
        L_LINE_REC.ISSUING_LOCATOR_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RECEIVING_LOCATOR_ID' THEN
        L_LINE_REC.RECEIVING_LOCATOR_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'PARENT_PRODUCT_ID' THEN
        L_LINE_REC.PARENT_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'REMOVED_PRODUCT_ID' THEN
        L_LINE_REC.REMOVED_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'STATUS_OF_RECEIVED_PART' THEN
        L_LINE_REC.STATUS_OF_RECEIVED_PART := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_SERIAL_NUMBER' THEN
        L_LINE_REC.ITEM_SERIAL_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_REVISION' THEN
        L_LINE_REC.ITEM_REVISION := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_LOTNUMBER' THEN
        L_LINE_REC.ITEM_LOTNUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'UOM_CODE' THEN
        L_LINE_REC.UOM_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'QUANTITY' THEN
        L_LINE_REC.QUANTITY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RMA_HEADER_ID' THEN
        L_LINE_REC.RMA_HEADER_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DISPOSITION_CODE' THEN
        L_LINE_REC.DISPOSITION_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'MATERIAL_REASON_CODE' THEN
        L_LINE_REC.MATERIAL_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'LABOR_REASON_CODE' THEN
        L_LINE_REC.LABOR_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXPENSE_REASON_CODE' THEN
        L_LINE_REC.EXPENSE_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'LABOR_START_DATE' THEN
        L_LINE_REC.LABOR_START_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'STARTING_MILEAGE' THEN
        L_LINE_REC.STARTING_MILEAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ENDING_MILEAGE' THEN
        L_LINE_REC.ENDING_MILEAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'EXPENSE_AMOUNT' THEN
        L_LINE_REC.EXPENSE_AMOUNT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CURRENCY_CODE' THEN
        L_LINE_REC.CURRENCY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DEBRIEF_LINE_STATUS_ID' THEN
        L_LINE_REC.DEBRIEF_LINE_STATUS_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CHANNEL_CODE' THEN
        L_LINE_REC.CHANNEL_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_STATUS ' THEN
        L_LINE_REC.CHARGE_UPLOAD_STATUS  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_MSG_CODE' THEN
        L_LINE_REC.CHARGE_UPLOAD_MSG_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_MESSAGE' THEN
        L_LINE_REC.CHARGE_UPLOAD_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'IB_UPDATE_STATUS' THEN
        L_LINE_REC.IB_UPDATE_STATUS := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'IB_UPDATE_MSG_CODE' THEN
        L_LINE_REC.IB_UPDATE_MSG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'IB_UPDATE_MESSAGE' THEN
        L_LINE_REC.IB_UPDATE_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SPARE_UPDATE_STATUS' THEN
        L_LINE_REC.SPARE_UPDATE_STATUS := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SPARE_UPDATE_MSG_CODE' THEN
        L_LINE_REC.SPARE_UPDATE_MSG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SPARE_UPDATE_MESSAGE' THEN
        L_LINE_REC.SPARE_UPDATE_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ERROR_TEXT' THEN
        L_LINE_REC.ERROR_TEXT := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_LINE_REC.CREATED_BY := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_LINE_REC.CREATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATED_BY ' THEN
        L_LINE_REC.LAST_UPDATED_BY  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_DATE' THEN
        L_LINE_REC.LAST_UPDATE_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_LOGIN' THEN
        L_LINE_REC.LAST_UPDATE_LOGIN := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_LINE_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_LINE_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_LINE_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_LINE_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_LINE_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_LINE_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_LINE_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_LINE_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_LINE_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_LINE_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_LINE_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_LINE_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_LINE_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_LINE_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_LINE_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_LINE_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
       L_LINE_REC.OBJECT_VERSION_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RETURN_REASON_CODE' THEN
       L_LINE_REC.RETURN_REASON_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'TRANSACTION_TYPE_ID' THEN
       L_LINE_REC.TRANSACTION_TYPE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RETURN_DATE' THEN
       L_LINE_REC.RETURN_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'MATERIAL_TRANSACTION_ID' THEN
       L_LINE_REC.MATERIAL_TRANSACTION_ID := l_COL_VALUE_LIST(i);
      END IF;

     END IF;
  END LOOP;
    L_LINE_TBL(1):= L_LINE_REC;

  csf_debrief_pub.Create_debrief_lines(
    P_API_VERSION_NUMBER      => L_API_VERSION,
    P_INIT_MSG_LIST           => FND_API.G_TRUE,
    P_COMMIT                  => FND_API.G_FALSE,
    P_UPD_TSKASSGNSTATUS      => L_UPD_TSKASSGNSTATUS, --we do not update TASK Assignment status
    P_TASK_ASSIGNMENT_STATUS  => L_TASK_ASSIGNMENT_STATUS,
    P_DEBRIEF_LINE_TBL        => L_LINE_TBL,
    P_DEBRIEF_HEADER_ID       => L_DEBRIEF_HEADER_ID,
    P_SOURCE_OBJECT_TYPE_CODE => L_SOURCE_OBJECT_TYPE_CODE, --Its Not required as header is already created
    X_RETURN_STATUS           => L_RETURN_STATUS,
    X_MSG_COUNT               => L_MSG_COUNT,
    X_MSG_DATA                => L_MSG_DATA
    );

   IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  END IF;

  x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Leaving APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_DEBRIEF_LINE_INSERT', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_INSERT',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_DEBRIEF_LINE_INSERT;

--code for HA Debrief Line Update
PROCEDURE APPLY_DEBRIEF_LINE_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_DEBRIEF_HEADER_ID   NUMBER;
L_DEB_HDR_REC         CSF_DEBRIEF_PUB.DEBRIEF_REC_TYPE;
L_LINE_REC               CSF_DEBRIEF_PUB.DEBRIEF_LINE_REC_TYPE;
L_LINE_TBL               CSF_DEBRIEF_PUB.DEBRIEF_LINE_TBL_TYPE;
L_UPD_TSKASSGNSTATUS       VARCHAR2(100):= NULL;
L_TASK_ASSIGNMENT_STATUS   VARCHAR2(100):= NULL;

BEGIN

  CSM_UTIL_PKG.LOG('Entering APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Debrief Header
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'DEBRIEF_LINE_ID' THEN
        L_LINE_REC.DEBRIEF_LINE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DEBRIEF_HEADER_ID' THEN
        L_LINE_REC.DEBRIEF_HEADER_ID := L_COL_VALUE_LIST(I);
        L_DEBRIEF_HEADER_ID             := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEBRIEF_LINE_NUMBER' THEN
        L_LINE_REC.DEBRIEF_LINE_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SERVICE_DATE' THEN
        L_LINE_REC.SERVICE_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'BUSINESS_PROCESS_ID' THEN
        L_LINE_REC.BUSINESS_PROCESS_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'TXN_BILLING_TYPE_ID' THEN
        L_LINE_REC.TXN_BILLING_TYPE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INVENTORY_ITEM_ID' THEN
        L_LINE_REC.INVENTORY_ITEM_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INSTANCE_ID' THEN
        L_LINE_REC.INSTANCE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_INVENTORY_ORG_ID' THEN
        L_LINE_REC.ISSUING_INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RECEIVING_INVENTORY_ORG_ID' THEN
        L_LINE_REC.RECEIVING_INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_SUB_INVENTORY_CODE' THEN
        L_LINE_REC.ISSUING_SUB_INVENTORY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RECEIVING_SUB_INVENTORY_CODE' THEN
        L_LINE_REC.RECEIVING_SUB_INVENTORY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ISSUING_LOCATOR_ID' THEN
        L_LINE_REC.ISSUING_LOCATOR_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RECEIVING_LOCATOR_ID' THEN
        L_LINE_REC.RECEIVING_LOCATOR_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'PARENT_PRODUCT_ID' THEN
        L_LINE_REC.PARENT_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'REMOVED_PRODUCT_ID' THEN
        L_LINE_REC.REMOVED_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'STATUS_OF_RECEIVED_PART' THEN
        L_LINE_REC.STATUS_OF_RECEIVED_PART := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_SERIAL_NUMBER' THEN
        L_LINE_REC.ITEM_SERIAL_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_REVISION' THEN
        L_LINE_REC.ITEM_REVISION := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ITEM_LOTNUMBER' THEN
        L_LINE_REC.ITEM_LOTNUMBER := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'UOM_CODE' THEN
        L_LINE_REC.UOM_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'QUANTITY' THEN
        L_LINE_REC.QUANTITY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'RMA_HEADER_ID' THEN
        L_LINE_REC.RMA_HEADER_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DISPOSITION_CODE' THEN
        L_LINE_REC.DISPOSITION_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'MATERIAL_REASON_CODE' THEN
        L_LINE_REC.MATERIAL_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'LABOR_REASON_CODE' THEN
        L_LINE_REC.LABOR_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXPENSE_REASON_CODE' THEN
        L_LINE_REC.EXPENSE_REASON_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'LABOR_START_DATE' THEN
        L_LINE_REC.LABOR_START_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'STARTING_MILEAGE' THEN
        L_LINE_REC.STARTING_MILEAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ENDING_MILEAGE' THEN
        L_LINE_REC.ENDING_MILEAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'EXPENSE_AMOUNT' THEN
        L_LINE_REC.EXPENSE_AMOUNT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CURRENCY_CODE' THEN
        L_LINE_REC.CURRENCY_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DEBRIEF_LINE_STATUS_ID' THEN
        L_LINE_REC.DEBRIEF_LINE_STATUS_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CHANNEL_CODE' THEN
        L_LINE_REC.CHANNEL_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_STATUS ' THEN
        L_LINE_REC.CHARGE_UPLOAD_STATUS  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_MSG_CODE' THEN
        L_LINE_REC.CHARGE_UPLOAD_MSG_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CHARGE_UPLOAD_MESSAGE' THEN
        L_LINE_REC.CHARGE_UPLOAD_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'IB_UPDATE_STATUS' THEN
        L_LINE_REC.IB_UPDATE_STATUS := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'IB_UPDATE_MSG_CODE' THEN
        L_LINE_REC.IB_UPDATE_MSG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'IB_UPDATE_MESSAGE' THEN
        L_LINE_REC.IB_UPDATE_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SPARE_UPDATE_STATUS' THEN
        L_LINE_REC.SPARE_UPDATE_STATUS := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SPARE_UPDATE_MSG_CODE' THEN
        L_LINE_REC.SPARE_UPDATE_MSG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'SPARE_UPDATE_MESSAGE' THEN
        L_LINE_REC.SPARE_UPDATE_MESSAGE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ERROR_TEXT' THEN
        L_LINE_REC.ERROR_TEXT := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_LINE_REC.CREATED_BY := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_LINE_REC.CREATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATED_BY ' THEN
        L_LINE_REC.LAST_UPDATED_BY  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_DATE' THEN
        L_LINE_REC.LAST_UPDATE_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_LOGIN' THEN
        L_LINE_REC.LAST_UPDATE_LOGIN := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_LINE_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_LINE_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_LINE_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_LINE_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_LINE_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_LINE_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_LINE_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_LINE_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_LINE_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_LINE_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_LINE_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_LINE_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_LINE_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_LINE_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_LINE_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_LINE_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
       L_LINE_REC.OBJECT_VERSION_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RETURN_REASON_CODE' THEN
       L_LINE_REC.RETURN_REASON_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'TRANSACTION_TYPE_ID' THEN
       L_LINE_REC.TRANSACTION_TYPE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RETURN_DATE' THEN
       L_LINE_REC.RETURN_DATE := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'MATERIAL_TRANSACTION_ID' THEN
       L_LINE_REC.MATERIAL_TRANSACTION_ID := l_COL_VALUE_LIST(i);
      END IF;

     END IF;
  END LOOP;

  csf_debrief_pub.Update_debrief_line(
    P_API_VERSION_NUMBER      => L_API_VERSION,
    P_INIT_MSG_LIST           => FND_API.G_TRUE,
    P_COMMIT                  => FND_API.G_FALSE,
    P_UPD_TSKASSGNSTATUS      => L_UPD_TSKASSGNSTATUS, --we do not update TASK Assignment status
    P_TASK_ASSIGNMENT_STATUS  => L_TASK_ASSIGNMENT_STATUS,
    P_DEBRIEF_LINE_REC        => L_LINE_REC,
    X_RETURN_STATUS           => L_RETURN_STATUS,
    X_MSG_COUNT               => L_MSG_COUNT,
    X_MSG_DATA                => L_MSG_DATA
    );

   IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  END IF;

  x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Leaving APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_DEBRIEF_LINE_UPDATE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'APPLY_HA_LINE_CHANGES.APPLY_DEBRIEF_LINE_UPDATE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := S_MSG_DATA;
END APPLY_DEBRIEF_LINE_UPDATE;

PROCEDURE APPLY_HA_LINE_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_DEBRIEF_LINE_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_DEBRIEF_LINE_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );

  END IF;

  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'APPLY_HA_LINE_CHANGES.APPLY_HA_LINE_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_LINE_CHANGES;

END CSM_DEBRIEF_HEADERS_PKG;

/
