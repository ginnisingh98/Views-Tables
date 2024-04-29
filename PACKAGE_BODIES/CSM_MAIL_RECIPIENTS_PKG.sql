--------------------------------------------------------
--  DDL for Package Body CSM_MAIL_RECIPIENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MAIL_RECIPIENTS_PKG" AS
/* $Header: csmumrcb.pls 120.1 2005/07/25 01:15:19 trajasek noship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     06/12/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_MAIL_RECIPIENTS_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_MAIL_RECIPIENTS';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_mail_recipients( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csf_m_mail_recipients_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_mail_recipients%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

BEGIN

-- Insert in this table is not to be
-- transfered to CRM table. Therefore discard all inserts and report OK.
x_return_status := FND_API.G_RET_STS_SUCCESS;

END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_mail_recipients%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

-- Make the cursor generic to avoid defining several.
cursor c_notification_attributes
       ( b_notification_id number
       , b_flag_name       varchar2
       )
is
select wna.notification_id
,      wna.name
,      wna.text_value
,      wna.number_value
,      wna.date_value
from   wf_notification_attributes wna
where  wna.notification_id = b_notification_id
and    wna.name            = b_flag_name;

r_notification_attributes     c_notification_attributes%rowtype;

BEGIN

-- If a message is read or deleted a flag is set in csf_m_mail_recipients.
-- This is an update of the record and both updates can occur
-- seperately or combined.

-- Important. "Deleted" means on the mobile side. The notification
-- will *not* be deleted on the central database side.

-- The properties mentioned are stored in wf_notification_attributes.
-- For every update of the record a check must be done if the
-- attribute is allready present or that it must be inserted.
-- For example in the situation where both the notification is read and
-- deleted, it is impossible to detect if this is done in one or two
-- updates on the mobile side.

-- check if the value provided is non-null!
if p_record.read_flag is not NULL
then
   -- Start with having read the notification.
   open c_notification_attributes
        ( p_record.notification_id
        , 'READ_FLAG'
        );
   fetch c_notification_attributes into r_notification_attributes;
   if c_notification_attributes%found
   then
      -- This records exists allready. We're done.
      null;
   else
      wf_notification.AddAttr
      ( p_record.notification_id
      , 'READ_FLAG'
      );

      wf_notification.SetAttrText
      ( p_record.notification_id
      , 'READ_FLAG'
      , p_record.read_flag
      );
   end if;
   close c_notification_attributes;
end if;
-- Check the two possible flags seperately!
if p_record.delete_flag is not NULL
then
   -- Check if the flag exists
   open c_notification_attributes
        ( p_record.notification_id
        , 'DELETE_FLAG'
        );
   fetch c_notification_attributes into r_notification_attributes;
   if c_notification_attributes%found
   then
      -- This records exists allready. We're done.
      null;
   else
      wf_notification.AddAttr
      ( p_record.notification_id
      , 'DELETE_FLAG'
      );

      wf_notification.SetAttrText
      ( p_record.notification_id
      , 'DELETE_FLAG'
      , p_record.delete_flag
      );
   end if;
   close c_notification_attributes;
end if;

--success
x_return_status := FND_API.G_RET_STS_SUCCESS;

exception
  when others then
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.NOTIFICATION_ID,'CSM_MAIL_RECIPIENTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_mail_recipients%ROWTYPE,
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
      || ' for PK ' || p_record.notification_id,'CSM_MAIL_RECIPIENTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR );

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
    ( 'Exception occurred in CSM_mail_recipients_PKG.APPLY_RECORD:' || ' ' || sqlerrm
      || ' for PK ' || p_record.notification_id ,'CSM_MAIL_RECIPIENTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

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
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*** loop through debrief labor records in inqueue ***/
  FOR r_mail_recipients IN c_mail_recipients( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_mail_recipients
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
          r_mail_recipients.seqno$$,
          r_mail_recipients.notification_id,
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
      || ' for PK ' || r_mail_recipients.notification_id ,'CSM_MAIL_RECIPIENTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_mail_recipients.notification_id,'CSM_MAIL_RECIPIENTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_mail_recipients.seqno$$
       , r_mail_recipients.notification_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_mail_recipients.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
      || ' for PK ' || r_mail_recipients.notification_id,'CSM_MAIL_RECIPIENTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm
    ,'CSM_MAIL_RECIPIENTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_MAIL_RECIPIENTS_PKG;

/
