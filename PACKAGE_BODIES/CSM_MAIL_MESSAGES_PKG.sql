--------------------------------------------------------
--  DDL for Package Body CSM_MAIL_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MAIL_MESSAGES_PKG" AS
/* $Header: csmummsb.pls 120.5 2008/03/12 07:51:37 saradhak ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     06/10/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_MAIL_MESSAGES_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_MAIL_MESSAGES';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_mail_messages( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csf_m_mail_messages_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_mail_recipients( b_user_name VARCHAR2, b_tranid NUMBER, b_notification_id NUMBER) is
  SELECT *
  FROM  csf_m_mail_recipients_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND NOTIFICATION_ID = b_notification_id;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_mail_messages%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

cursor c_user_name
       ( b_user_name varchar2
       )
is
select fur.user_name
,      fur.start_date
,      fur.end_date
from   fnd_user fur
where  fur.user_name = b_user_name;

r_user_name        c_user_name%rowtype;

CURSOR l_sender_full_name_csr(p_username IN varchar2)
IS
SELECT source_name
FROM jtf_rs_resource_extns jtrs
WHERE jtrs.user_name = p_username
AND SYSDATE BETWEEN start_date_active AND nvl(end_date_active, sysdate);

CURSOR c_group(b_group_id NUMBER)
IS
SELECT 'y'
FROM JTF_RS_GROUPS_B
WHERE GROUP_ID=b_group_id;

l_return_status VARCHAR2(80);
l_notification_id  number;
l_valid_receiver   boolean;
l_sender_full_name varchar2(2000);
l_group_id varchar2(100);
l_prefix varchar2(100);
l_valid_group boolean :=false;
l_num_grp number;
BEGIN

--USMC changes
IF p_record.message_type='b' THEN

 l_prefix:=substr(p_record.receiver,1,instr(p_record.receiver,':')-1);
 l_group_id:=substr(p_record.receiver,instr(p_record.receiver,':')+1);
 BEGIN
  l_num_grp:=to_number(l_group_id);
 EXCEPTION
  WHEN Others THEN
  l_num_grp:=-1;
 END;

 IF l_num_grp IS NOT NULL AND l_num_grp<>-1 AND l_prefix='JRES_GRP' THEN
  OPEN c_group(l_num_grp);
  FETCH c_group INTO l_group_id;
  IF c_group%found THEN
   l_valid_group := true;
  END IF;
  CLOSE c_group;
 END IF;

END IF;

-- This API has no support for failing.
-- Therefore it is imperative to check if the receiver is correct.
-- The only information available for this receiver is that it must
-- correspond to user_name in fnd_user. The case in fnd_user is upper.
-- The mobile application ensures that the receiver (either chosen or
-- typed in manually) is always in uppercase. Thus, for comparision no
-- case changes is necessary.

open c_user_name
     ( p_record.receiver
     );
fetch c_user_name into r_user_name;
-- Note that this is only a check if the user_name exists as given.
-- No retrieval of additional information is necessary.
if c_user_name%found OR (p_record.message_type='b' AND l_valid_group)
then
   l_valid_receiver := true;
else
   l_valid_receiver := false;
   x_return_status := FND_API.G_RET_STS_ERROR;
   p_error_msg := 'The receiver '||p_record.receiver ||' of your message does not exist.';

/*
   p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_MAIL_RECEIVER_UNKNOWN'
      , p_token_name1    => 'MAIL_RECEIVER'
      , p_token_value1   => p_record.receiver
      );*/
end if;
close c_user_name;

-- Send the intended message to the receiver if the receiver is valid.
if l_valid_receiver
THEN

   OPEN l_sender_full_name_csr(p_record.sender);
   FETCH l_sender_full_name_csr INTO l_sender_full_name;
   CLOSE l_sender_full_name_csr;

   l_notification_id := wf_notification.Send
                        ( role     => p_record.receiver
                        , msg_type => 'CS_MSGS'
                        , msg_name => 'FYI_MESSAGE'
                        );

--Bug 5337816
  wf_notification.SetAttrText
   ( l_notification_id
   , '#FROM_ROLE'
   , p_record.sender
   );

   wf_notification.SetAttrText
   ( l_notification_id
   , 'SENDER'
   , l_sender_full_name
   );

  wf_notification.SetAttrText
   ( l_notification_id
   , 'MESSAGE_TEXT'
   , p_record.message
   );

--Bug 5337816
  wf_notification.AddAttr
    ( l_notification_id
     , 'MSG_SUBJECT'
     );
  wf_notification.SetAttrText
   ( l_notification_id
   , 'MSG_SUBJECT'
   , p_record.subject
   );


--12.1
  wf_notification.AddAttr
    ( l_notification_id
     , 'MESSAGE_TYPE'
     );
  wf_notification.SetAttrText
   ( l_notification_id
   , 'MESSAGE_TYPE'
   , NVL(p_record.message_type,'i')
   );

   CSM_NOTIFICATION_EVENT_PKG.DOWNLOAD_NOTIFICATION(l_notification_id,l_return_status);  --return_status doesn't matter here
   --success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
end if;

exception
  when others then
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
               || ' for PK ' || p_record.NOTIFICATION_ID ,'CSM_MAIL_MESSAGES_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);
     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_mail_messages%ROWTYPE,
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
  ELSE
    -- Process delete and update; not supported for this entity
      CSM_UTIL_PKG.LOG
        ( 'Delete and Update is not supported for this entity'
      || ' for PK ' || p_record.notification_id ,'CSM_MAIL_MESSAGES_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

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
    ( 'Exception occurred in CSM_mail_messages_PKG.APPLY_RECORD:' || ' ' || sqlerrm
      || ' for PK ' || p_record.notification_id,'CSM_MAIL_MESSAGES_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION );

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
  FOR r_mail_messages IN c_mail_messages( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_mail_messages
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN

      /*** Yes -> reject record because of changed pk ***/
      CSM_UTIL_PKG.LOG ( 'Record successfully processed, rejecting record ' || ' for PK '
            || r_mail_messages.notification_id
            ,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES'
            ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

      CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_mail_messages.seqno$$,
          r_mail_messages.notification_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );


      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        /*** Reject successfull than reject matching records in mail recipient ***/
          CSM_UTIL_PKG.LOG
          ( 'Mail message record rejected. Now rejecting records in mail recipient ' || ' for PK '
            || r_mail_messages.notification_id
            ,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES'
            ,FND_LOG.LEVEL_PROCEDURE); -- put PK column here

        FOR r_mail_recipients IN c_mail_recipients( p_user_name
                                                      , p_tranid
 					              , r_mail_messages.notification_id ) LOOP
          CSM_UTIL_PKG.REJECT_RECORD
           ( p_user_name,
             p_tranid,
             r_mail_recipients.seqno$$,
             r_mail_recipients.notification_id,
             g_object_name,
             'CSF_M_MAIL_RECIPIENTS',
             l_error_msg,
             l_process_status
           );
        END LOOP;
      END IF; -- end of l_process_status = success for REJECT_RECORD( mail_messages )


      /*** Yes -> delete record from inqueue ***/

      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_mail_messages.seqno$$,
          r_mail_messages.notification_id,
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
      || ' for PK ' || r_mail_messages.notification_id ,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_mail_messages.notification_id ,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_mail_messages.seqno$$
       , r_mail_messages.notification_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_mail_messages.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
      || ' for PK ' || r_mail_messages.notification_id,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm
    ,'CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_MAIL_MESSAGES_PKG;

/
