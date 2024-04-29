--------------------------------------------------------
--  DDL for Package Body XDP_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_MESSAGE" AS
/* $Header: XDPMSGPB.pls 120.2 2006/04/10 23:23:26 dputhiye noship $ */

-- Procedure:   retry_failed_message
-- Purpose:     Retries Failed message
-- Parameters:  Message to retry (character matching allowed, e.g. 'XNP%')
-- Comments:    Responds to Workflow notification sent for failed message.
--              which in turn invokes workflow which retries message.
-- Called from: Concurrent program 'XDP Resubmit Failed Messages' (XDPRESUB.sql)

PROCEDURE retry_failed_message
              ( errbuf         OUT NOCOPY VARCHAR2   --Fixing 3957604. GSCC warning to add NOCOPY hint. Added hint
              , retcode        OUT NOCOPY VARCHAR2   --to errbuf and retcode arguments.
              , p_msg_to_retry IN  VARCHAR2 ) IS

  -- Cursor to find notification for FAILED messages in XNP_MSGS matching msg_code pattern sent in to procedure
  -- Logic depends on that subject for notification ends with ' - <msg_id>'.

  /* Corrected the following SQL to fix bug 3957604. dputhiye. 27/10/04 */
--  CURSOR c_notification_to_respond_to IS
--    SELECT wf.notification_id, msg.msg_id, msg.msg_code
--    FROM wf_notifications wf
--       , xnp_msgs msg
--    WHERE wf.message_name like 'MSG_FAILURE_NOTIF'
--    AND wf.status = 'OPEN'
--    AND msg.msg_code like '||p_msg_to_retry||'
--    AND msg.msg_status = 'FAILED'
--    AND msg.msg_id =
--                     SUBSTR(subject,INSTR(subject,' - ')+3,LENGTH(subject));

  CURSOR c_notification_to_respond_to IS
    SELECT wf.notification_id, msg.msg_id, msg.msg_code
    FROM wf_notifications wf
       , xnp_msgs msg
    WHERE wf.message_name like 'MSG_FAILURE_NOTIF'
    AND wf.status = 'OPEN'
    AND msg.msg_code like p_msg_to_retry
    AND msg.msg_status = 'FAILED'
    AND TO_CHAR(msg.msg_id) =
                     SUBSTR(subject,INSTR(subject,' - ')+3,LENGTH(subject));

    l_num_of_messages_success NUMBER := 0;
    l_num_of_messages_fail    NUMBER := 0;
BEGIN
  FOR rec_notification_to_respond_to IN c_notification_to_respond_to
  LOOP
     BEGIN

       wf_notification.SetAttrText(
                       nid => rec_notification_to_respond_to.notification_id
                     , aname => 'RESULT'
                     , avalue => 'RETRY_MSG');

       wf_notification.Respond(
                       nid => rec_notification_to_respond_to.notification_id
                     , respond_comment => 'Retried processing message in batch '||
                                          'together with messages with code '||p_msg_to_retry
                     , responder => fnd_global.user_id);

       fnd_file.put_line(fnd_file.log,'Successfully Resubmitted Msg Code: '||
                         rec_notification_to_respond_to.msg_code||
                         ' Msg ID: '||rec_notification_to_respond_to.msg_id );

        l_num_of_messages_success := l_num_of_messages_success + 1;
     EXCEPTION
       WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'Resubmit failed '||
                          ' Error: '||sqlcode||
                          ' Msg Code: '|| rec_notification_to_respond_to.msg_code||
                          ' Msg ID: '||rec_notification_to_respond_to.msg_id );
         l_num_of_messages_fail := l_num_of_messages_fail + 1;
     END;
  END LOOP;
  fnd_file.put_line(fnd_file.log,'-----------------------------------------------');
  fnd_file.put_line(fnd_file.log,l_num_of_messages_success||' messages successfully resubmitted');
  fnd_file.put_line(fnd_file.log,l_num_of_messages_fail||' messages not resubmitted');
  retcode := 0;
  errbuf := 'Success';
EXCEPTION
  WHEN OTHERS THEN
     retcode := 2;
     errbuf := SQLERRM;
END retry_failed_message;

END xdp_message;

/
