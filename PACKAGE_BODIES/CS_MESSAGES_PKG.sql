--------------------------------------------------------
--  DDL for Package Body CS_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_MESSAGES_PKG" AS
/* $Header: csmesgb.pls 120.3 2006/01/19 22:15:01 varnaray noship $   */
-- ------------------------------------------------------------------------
-- Send_Message
--   Call the Workflow Notification API to send the message and insert a
--   new record into CS_MESSAGES.
-- ------------------------------------------------------------------------

  PROCEDURE Send_Message (
		p_source_object_type	IN	VARCHAR2,
		p_source_obj_type_code  IN	VARCHAR2,
		p_source_object_int_id	IN	NUMBER,
		p_source_object_ext_id	IN	VARCHAR2,
		p_sender		IN	VARCHAR2,
		p_sender_role		IN	VARCHAR2    DEFAULT NULL,
		p_receiver		IN	VARCHAR2,
		p_receiver_role		IN	VARCHAR2,
		p_priority		IN	VARCHAR2,
		p_expand_roles		IN	VARCHAR2,
		p_action_type		IN	VARCHAR2    DEFAULT NULL,
		p_action_code		IN	VARCHAR2    DEFAULT NULL,
		p_confirmation		IN	VARCHAR2,
		p_message		IN	VARCHAR2    DEFAULT NULL,
		p_function_name		IN	VARCHAR2    DEFAULT NULL,
		p_function_params	IN	VARCHAR2    DEFAULT NULL ) IS

    l_message_id	NUMBER;
    l_notification_id	NUMBER;
    l_ntf_group_id	NUMBER;
    l_source_obj_ext_id	VARCHAR2(200);
    l_user_id		NUMBER;
    l_login_id		NUMBER;
    l_priority		VARCHAR2(30);

    l_priority_number	NUMBER;

    CURSOR l_msgid_csr IS
      SELECT cs_messages_s.NEXTVAL
        FROM dual;

    CURSOR l_ntf_csr IS
      SELECT ntf.notification_id
        FROM wf_notifications ntf
       WHERE ntf.group_id = l_ntf_group_id;

    CURSOR l_priority_csr IS
      SELECT meaning
        FROM cs_lookups
       WHERE lookup_type = 'MESSAGE_PRIORITY'
         AND lookup_code = p_priority;

    -- --------------------------------------------------------------------
    -- SetAttributes
    --   Subprocedure used to set the message attibutes that are common to
    --   all the different types of messages
    -- --------------------------------------------------------------------

    PROCEDURE SetAttributes(	p_nid		IN	NUMBER,
                                p_priority      IN      VARCHAR2,
				p_ext_id	IN	VARCHAR2  DEFAULT NULL ) IS
    BEGIN
      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'OBJECT_ID',
			avalue		=>	p_ext_id );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'OBJECT_TYPE',
			avalue		=>	p_source_object_type );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'SENDER',
			avalue		=>	p_sender );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'MESSAGE_TEXT',
			avalue		=>	p_message );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'PRIORITY',
			avalue		=>	p_priority );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	p_nid,
			aname		=>	'OBJECT_FORM',
			avalue		=>	p_function_name||':'||p_function_params );

      WF_NOTIFICATION.SetAttrText(
                        nid             =>      p_nid,
                        aname           =>      '#FROM_ROLE',
                        avalue          =>      p_sender_role);


      -- Fix for bug 2122488--
      Wf_Notification.Denormalize_Notification(p_nid);

    END SetAttributes;


  BEGIN
    -- --------------------------------------------------------------------
    -- Begin of procedure Send_Message
    -- --------------------------------------------------------------------

    -- Get the message ID from the sequence
    OPEN l_msgid_csr;
    FETCH l_msgid_csr INTO l_message_id;
    CLOSE l_msgid_csr;

    --
    -- Attach a '#' character to the object ID if it's not NULL
    --
    IF (p_source_object_ext_id IS NOT NULL) THEN
      l_source_obj_ext_id := '#'||p_source_object_ext_id;
    ELSE
      l_source_obj_ext_id := NULL;
    END IF;

    -- Get the priority value
    OPEN l_priority_csr;
    FETCH l_priority_csr INTO l_priority;
    CLOSE l_priority_csr;

    -- Set priority Number for message.
    -- High (1-49), Medium (50), Low (51-99).
    -- We set arbitrarily : High=25, Medium=50, and Low=75
    IF (p_priority = 'HIGH') THEN
      l_priority_number := 25;
    ELSIF (p_priority = 'MED') THEN
      l_priority_number := 50;
    ELSE
      l_priority_number := 75;
    END IF;


    --
    -- First check to see if an action is being requested
    --
    IF (p_action_type IS NULL) THEN
      --
      -- No Action requested.  We'll be sending an FYI message
      -- Now check and see if expand roles is requested
      --
      IF (p_expand_roles = 'N') THEN

        -- Do not expand roles, just call the Send API
        l_ntf_group_id := WF_NOTIFICATION.Send(
			role		=>	p_receiver_role,
			msg_type	=>	'CS_MSGS',
			msg_name	=>	'FYI_MESSAGE',
			due_date	=>	NULL,
			callback	=>	'CS_MESSAGES_PKG.NOTIFICATION_CALLBACK',
			context		=>	to_char(l_message_id),
			send_comment	=>	NULL,
			priority        =>      l_priority_number );

      ELSE

        -- Expand Roles requested, call the SendGroup API instead
        l_ntf_group_id := WF_NOTIFICATION.SendGroup(
			role		=>	p_receiver_role,
			msg_type	=>	'CS_MSGS',
			msg_name	=>	'EXPANDED_FYI_MSG',
			due_date	=>	NULL,
			callback	=>	'CS_MESSAGES_PKG.NOTIFICATION_CALLBACK',
			context		=>	to_char(l_message_id),
			send_comment	=>	NULL,
			priority        =>      l_priority_number );

      END IF;

      --
      -- For each notification in the group, set up the message attributes.
      -- Note that if the Send API was called, the notification ID will be
      -- the same as the group ID.
      -- We are using a cursor loop until Workflow team provides an API for
      -- updating the notification attributes for the whole group
      --
      FOR l_ntf_rec IN l_ntf_csr LOOP

        l_notification_id := l_ntf_rec.notification_id;

        -- Call the subprocedure to set the notification attributes
	SetAttributes(l_notification_id, l_priority, l_source_obj_ext_id);

      END LOOP;

      l_notification_id := l_ntf_group_id;

    ELSE

      -- Action requested, send the ACTION_REQUEST_MSG message
      l_notification_id := WF_NOTIFICATION.Send(
			role		=>	p_receiver_role,
			msg_type	=>	'CS_MSGS',
			msg_name	=>	'ACTION_REQUEST_MSG',
			due_date	=>	NULL,
			callback	=>	'CS_MESSAGES_PKG.NOTIFICATION_CALLBACK',
			context		=>	to_char(l_message_id),
			send_comment	=>	NULL,
			priority        =>      l_priority_number );

      -- Set the notification attributes
      SetAttributes(l_notification_id, l_priority, l_source_obj_ext_id);

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_notification_id,
			aname		=>	'ACTION',
			avalue		=>	p_action_type );

    END IF;

    -- Get the user information for WHO columns
    l_user_id	:= to_number(FND_PROFILE.VALUE('USER_ID'));
    l_login_id	:= to_number(FND_PROFILE.VALUE('LOGIN_ID'));

    IF (l_user_id IS NULL) THEN
      l_user_id := -1;
    END IF;

    -- Insert a new record into the CS_MESSAGES table
    INSERT INTO cs_messages (
		message_id,
		notification_id,
		date_sent,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		source_object_type_code,
		source_object_int_id,
		source_object_ext_id,
		sender,
		sender_role,
		receiver,
		priority,
		expand_roles,
		action_code,
		confirmation,
		message,
		responder,
		response_date,
		response,
		responder_comment )
	VALUES (
		l_message_id,
		l_notification_id,
		sysdate,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_id,
		p_source_obj_type_code,
		p_source_object_int_id,
		p_source_object_ext_id,
		p_sender,
		p_sender_role,
		p_receiver,
		p_priority,
		p_expand_roles,
		p_action_code,
		p_confirmation,
 		p_message,
		NULL,
		NULL,
		NULL,
		NULL );

  END Send_Message;



-- ------------------------------------------------------------------------
-- Notification_Callback
--   Callback function for the Messages module.  This procedure will be
--   called by the Workflow Notification system when the recipient has
--   responded.
--   Note that the context parameter will contain the char representation
--   of the MESSAGE_ID.  Parameter text_value and number_value will contain
--   the values of RESPONSE and NOTIFICATION_ID respectively.  See the
--   WF_NOTIFICATION.Respond API for more detail.
-- ------------------------------------------------------------------------

  PROCEDURE Notification_Callback (
		command 	IN	VARCHAR2,
		context		IN	VARCHAR2,
		attr_name	IN	VARCHAR2    DEFAULT NULL,
		attr_type	IN 	VARCHAR2    DEFAULT NULL,
		text_value	IN OUT	NOCOPY VARCHAR2,
		number_value	IN OUT	NOCOPY NUMBER,
		date_value	IN OUT	NOCOPY DATE ) IS

    l_message_id  NUMBER;
    l_user_id	  NUMBER;
    l_login_id	  NUMBER;
    l_comment	  VARCHAR2(2000);
    l_confirmation_nid	NUMBER;
    l_source_type VARCHAR2(100);
    l_source_id   VARCHAR2(100);
    l_message     VARCHAR2(2000);
    l_response    VARCHAR2(30);

    CURSOR l_ntf_csr IS
      SELECT ntf.end_date,
             wf.display_name responder,
             msg.confirmation,
             msg.notification_id,
             msg.sender_role sender
        FROM wf_notifications ntf, wf_roles wf, cs_messages msg
       WHERE msg.message_id = l_message_id
         AND msg.notification_id = ntf.notification_id
         AND ntf.responder = wf.name(+)
         FOR UPDATE OF msg.message_id;

    CURSOR l_response_csr IS
      SELECT meaning
        FROM cs_lookups
       WHERE lookup_type = 'MESSAGE_RESPONSE'
         AND lookup_code = text_value;

    l_ntf_rec  l_ntf_csr%ROWTYPE;

begin
  --
  -- Get the message_id from the context
  --
  l_message_id := to_number(context);

  --
  -- We should never encounter a GET command because we never
  -- have attributes that are based on item attributes.  It we
  -- somehow get here, just return NULL for everything
  --
  IF (upper(command) = 'GET') THEN
    IF (attr_type = 'NUMBER') THEN
      number_value := to_number(NULL);
    ELSIF (attr_type = 'DATE') THEN
      date_value := to_date(NULL);
    ELSE
      text_value := to_char(NULL);
    END IF;

  ELSIF (upper(command) = 'SET') THEN
    --
    -- Do all the work in the COMPLETE command
    --
    null;

  ELSIF (upper(command) = wf_engine.eng_completed) THEN

    -- Get the user information for WHO columns
    l_user_id	:= to_number(FND_PROFILE.VALUE('USER_ID'));
    l_login_id	:= to_number(FND_PROFILE.VALUE('LOGIN_ID'));

    IF (l_user_id IS NULL) THEN
      l_user_id := -1;
    END IF;

    OPEN l_ntf_csr;
    FETCH l_ntf_csr INTO l_ntf_rec;

    -- Get the comment of the responder
    l_comment := WF_NOTIFICATION.GetAttrText(l_ntf_rec.notification_id, 'COMMENT');

    -- Update the row in the CS_MESSAGES table
    UPDATE cs_messages
       SET last_update_date	= sysdate,
           last_updated_by	= l_user_id,
           last_update_login    = l_login_id,
           responder		= l_ntf_rec.responder,
           response_date	= l_ntf_rec.end_date,
           responder_comment	= l_comment,
           response		= text_value
     WHERE CURRENT OF l_ntf_csr;

    -- If confirmation was requested, we need to send it now
    IF (l_ntf_rec.confirmation = 'Y') THEN

      -- Get the value for response
      OPEN l_response_csr;
      FETCH l_response_csr INTO l_response;
      CLOSE l_response_csr;

      l_source_type := WF_NOTIFICATION.GetAttrText(l_ntf_rec.notification_id, 'OBJECT_TYPE');
      l_source_id   := WF_NOTIFICATION.GetAttrText(l_ntf_rec.notification_id, 'OBJECT_ID');
      l_message     := WF_NOTIFICATION.GetATTRTEXT(l_ntf_rec.notification_id, 'MESSAGE_TEXT');

      l_confirmation_nid := WF_NOTIFICATION.Send(
			role		=>	l_ntf_rec.sender,
			msg_type	=>	'CS_MSGS',
			msg_name	=>	'CONFIRMATION_MESSAGE',
			due_date	=>	NULL,
			callback	=>	'CS_MESSAGES_PKG.NOTIFICATION_CALLBACK',
			context		=>	to_char(l_message_id),
			send_comment	=>	NULL );

      -- Set up the message attributes
      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'OBJECT_TYPE',
			avalue		=>	l_source_type );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'OBJECT_ID',
			avalue		=>	l_source_id );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'RESPONDER',
			avalue		=>	l_ntf_rec.responder );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'RESPONSE',
			avalue		=>	l_response );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'COMMENT',
			avalue		=>	l_comment );

      WF_NOTIFICATION.SetAttrText(
			nid		=>	l_confirmation_nid,
			aname		=>	'MESSAGE',
			avalue		=>	l_message );
    -- Fix for bug 2122488
    Wf_Notification.Denormalize_Notification(l_confirmation_nid);

    END IF;

    CLOSE l_ntf_csr;

  END IF;

end Notification_Callback;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_MESSAGE
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure physically deletes all the messages that are linked
--      to SRs that are to be purged.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug-2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure physically deletes all the messages that are linked to SRs
 * that are to be purged.
 * @param p_object_type Type of object for which this procedure is being called.
 * (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child
 * objects have to be deleted.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Messages
 */
PROCEDURE Delete_Message
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'DELETE_MESSAGE';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := 'CS_MESSAGES' || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count     NUMBER := 0;

x_msg_index_out NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
    (
      L_API_VERSION
    , p_api_version_number
    , L_API_NAME
    , 'CS_MESSAGES'
    )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_sr_message_start'
    , 'deleting data in table cs_messages'
    );
  END IF ;

  -- The following delete statement deletes the rows in the
  -- cs_messages table which correspond to the incident_ids in
  -- the global temp table jtf_object_purge_param_tmp which have
  -- purge_status NULL indicating that the SR is available for
  -- purge.

  DELETE /*+ index(m) */
    cs_messages m
  WHERE
    source_object_type_code = 'INC'
  AND
    source_object_int_id IN
    (
      SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
      FROM
        jtf_object_purge_param_tmp
      WHERE
        object_type = 'SR'
      AND p_processing_set_id = processing_set_id
      AND NVL(purge_status, 'S') = 'S'
    );
  l_row_count := SQL%ROWCOUNT;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_sr_message_end'
    , 'after deleting data in table cs_messages ' || l_row_count
    );
  END IF ;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' successfully'
    );
  END IF ;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data
            || ' [Index:' || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_MSG_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL
        || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Delete_Message;
--------------------------------------------------------------------------------

END CS_MESSAGES_PKG;

/
