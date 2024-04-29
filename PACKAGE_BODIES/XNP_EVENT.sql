--------------------------------------------------------
--  DDL for Package Body XNP_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_EVENT" AS
/* $Header: XNPEVTPB.pls 120.1 2005/06/09 02:55:11 appldev  $ */

PROCEDURE deliver(
	p_msg_id IN NUMBER
	,p_callback_proc VARCHAR2
	,p_process_reference VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
) ;

e_procedure_exec_error  EXCEPTION ;

g_new_line CHAR := fnd_global.local_chr(10) ;


/***************************************************************************
*****  Procedure:    UNSUBSCRIBE()
*****  Purpose:      Deregisters a registered callback.
****************************************************************************/

PROCEDURE unsubscribe (
	p_cb_event_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,p_close_flag IN VARCHAR2 DEFAULT 'Y'
	)
IS
BEGIN

--	adabholk 03/01 - Performance fix
--	Cursors replaced by explicit updates

	IF (p_close_flag = 'Y') THEN

		UPDATE	xnp_callback_events
		SET		status = 'CLOSED',
				callback_timestamp = sysdate
		WHERE	callback_event_id = p_cb_event_id;

	END IF ;

	UPDATE	xnp_callback_events
	SET		status = 'EXPIRED',
			callback_timestamp = sysdate
	WHERE	process_reference = p_process_reference
	AND		status = 'WAITING'
	AND		close_reqd_flag = 'Y';

END unsubscribe;


/***************************************************************************
*****  Procedure:    DEREGISTER()
*****  Purpose:      Deregisters a registered callback.
****************************************************************************/

PROCEDURE deregister(
	p_msg_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
) IS

BEGIN

--	adabholk 03/01 - Performance fix
--	Cursors replaced by explicit updates

		UPDATE	xnp_callback_events
		SET		status = 'EXPIRED',
				callback_timestamp = sysdate
		WHERE	reference_id = p_reference_id
		AND		msg_code = p_msg_code;
END ;


/***************************************************************************
*****  Procedure:    DEREGISTER()
*****  Purpose:      Deregisters a callback procedure given the ORDER ID.
****************************************************************************/
PROCEDURE deregister(
	p_order_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
BEGIN
--	adabholk 03/01 - Performance fix
--	Cursors replaced by explicit updates

		UPDATE	xnp_callback_events
		SET		status = 'EXPIRED',
				callback_timestamp = sysdate
		WHERE	order_id = p_order_id;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM;
END ;

/***************************************************************************
*****  Procedure:    DEREGISTER_FOR_WORKITEM()
*****  Purpose:      Deregisters a callback procedure given the WORKITEM_INSTNACE_ID.
****************************************************************************/
PROCEDURE deregister_for_workitem
(
	p_workitem_instance_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
BEGIN
		UPDATE	xnp_callback_events
		SET		status = 'EXPIRED',
				callback_timestamp = sysdate
		WHERE	wi_instance_id = p_workitem_instance_id
		 AND    status = 'WAITING';

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM;
END ;




/***************************************************************************
*****  Procedure:    SUBSCRIBE()
*****  Purpose:      SUBSCRIBEs a callback.  Callbacks can be registered
*****                for any of the immediate responses from the peer
*****                system.  The response will be delivered to the
*****                registered application on receiving it.
****************************************************************************/

PROCEDURE subscribe (
	p_msg_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_process_reference IN VARCHAR2
	,p_procedure_name IN VARCHAR2
	,p_callback_type IN VARCHAR2
	,p_close_reqd_flag IN VARCHAR2 DEFAULT 'Y'
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
)
IS
BEGIN

	INSERT INTO xnp_callback_events (
		callback_event_id,
		reference_id,
		msg_code,
		status,
		process_reference,
		registered_timestamp,
		callback_type,
		callback_proc_name,
		close_reqd_flag,
		order_id,
		wi_instance_id,
		fa_instance_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date )
	VALUES (
		XNP_CALLBACK_EVENTS_S.nextval,
		p_reference_id,
		p_msg_code,
		'WAITING',
		p_process_reference,
		SYSDATE,
		p_callback_type,
		p_procedure_name,
		p_close_reqd_flag,
		p_order_id,
		p_wi_instance_id,
		p_fa_instance_id,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE );

END subscribe ;

/***************************************************************************
*****  Procedure:    PROCESS()
*****  Purpose:      Checks if a message has arrived and delivers it to all
*****                registered applications.  Returns a timeout error if
*****                no message is received in the specified interval.
****************************************************************************/

PROCEDURE process(
	p_queue_name IN VARCHAR2
)
IS

	l_error_code NUMBER ;
	l_error_message VARCHAR2(4000) ;

	l_msg_header     XNP_MESSAGE.MSG_HEADER_REC_TYPE ;

	l_msg_text       VARCHAR2(32767) ;
	l_num_apps       NUMBER := 0;
	l_operation      VARCHAR2(4000) := NULL ;
	l_description    VARCHAR2(4000) := NULL ;
	l_fnd_message    VARCHAR2(4000) := NULL ;

	l_order_id        NUMBER;
	l_wi_instance_id  NUMBER;
	l_fa_instance_id  NUMBER ;

	l_fatal_error     BOOLEAN := FALSE;
	l_queue_name	  VARCHAR2(40);
	l_dummy       	  NUMBER := 0;

-- Varrajar 3/2/2001
-- Peformance Fix Phase 4. Avoid the FTS on the Callback Events for default
-- subscribers by having a default "-1" value instead of NULL

	CURSOR registered_apps ( l_reference_id IN VARCHAR2,
                           l_msg_code IN VARCHAR2 )
	IS
		SELECT callback_event_id,
			callback_proc_name,
			process_reference,
			close_reqd_flag,
			order_id,
			wi_instance_id,
			fa_instance_id
		FROM XNP_CALLBACK_EVENTS
		WHERE reference_id in (l_reference_id, '-1')
		AND msg_code = l_msg_code
		AND status = 'WAITING' ;

	e_MSG_VALIDATION_ERROR      EXCEPTION ;
	e_MSG_PROCESSING_ERROR      EXCEPTION ;
	e_MSG_DELIVERY_ERROR        EXCEPTION ;
	e_DEFAULT_PROCESSING_ERROR  EXCEPTION ;

BEGIN
BEGIN

	l_error_code := 0 ;
	l_error_message := NULL ;

	xnp_message.pop (p_queue_name => p_queue_name,
		x_msg_header => l_msg_header,
		x_body_text => l_msg_text,
		x_error_code => l_error_code,
		x_error_message => l_error_message,
		p_correlation_id => 'MSG_SERVER' ) ;

	SAVEPOINT after_pop ;

	IF ( l_error_code = XNP_ERRORS.G_DEQUEUE_TIMEOUT ) THEN
		DBMS_LOCK.sleep(5) ;
		RETURN ;
	END IF ;

	xnp_message.validate ( l_msg_header,
		l_msg_text,
		l_error_code,
		l_error_message ) ;

	IF (l_error_code <> 0) THEN
		RAISE e_MSG_VALIDATION_ERROR ;
	END IF ;

-- Process and deliver message to all registered applications

	FOR app IN registered_apps ( l_msg_header.reference_id,
		l_msg_header.message_code ) LOOP

		l_order_id := app.order_id;
		l_wi_instance_id := app.wi_instance_id;
		l_fa_instance_id := app.fa_instance_id ;
		l_msg_header.order_id := app.order_id;
		l_msg_header.wi_instance_id := app.wi_instance_id;
		l_msg_header.fa_instance_id := app.fa_instance_id ;

		l_num_apps := l_num_apps + 1 ;

		SAVEPOINT  deliver_msg ;

		BEGIN

		xnp_message.process ( l_msg_header,
			l_msg_text,
			app.process_reference,
			l_error_code,
			l_error_message ) ;

		IF (l_error_code <> 0) THEN
			RAISE e_MSG_PROCESSING_ERROR ;
		END IF ;

		xnp_event.unsubscribe ( app.callback_event_id,
			app.process_reference, app.close_reqd_flag ) ;

		deliver ( l_msg_header.message_id,
			app.callback_proc_name,
			app.process_reference,
			l_error_code,
			l_error_message ) ;

		IF (l_error_code <> 0) THEN
			RAISE e_MSG_DELIVERY_ERROR ;
		END IF ;


		xnp_message.update_status(
			p_msg_id=>l_msg_header.message_id,
			p_status=>'PROCESSED',
			p_order_id=>l_order_id,
			p_wi_instance_id=>l_wi_instance_id,
			p_fa_instance_id=>l_fa_instance_id) ;

		EXCEPTION
		WHEN e_MSG_DELIVERY_ERROR THEN
			ROLLBACK to deliver_msg ;

			fnd_message.set_name ('XNP', 'MSG_DELIVERY_ERROR') ;
			fnd_message.set_token ('CALLBACK',
				app.callback_proc_name);
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

			l_fnd_message:= fnd_message.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;


		WHEN e_MSG_PROCESSING_ERROR THEN
			ROLLBACK to deliver_msg ;

			fnd_message.set_name ('XNP', 'MSG_PROCESSING_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message := fnd_message.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN OTHERS THEN

			ROLLBACK ;

			l_fatal_error := TRUE;
			fnd_message.set_name ('XNP', 'MSG_SERVER_EXCEPTION') ;
			fnd_message.set_token ('MSG_ID',
				l_msg_header.message_id) ;
			fnd_message.set_token ('ERROR_CODE', SQLCODE) ;
			fnd_message.set_token ('ERROR_MESSAGE', SQLERRM) ;
				l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_statuS(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;
		END ;

		COMMIT ;

	END LOOP ;

-- If no apps have registered, execute the default processing logic

	IF ( l_num_apps = 0 ) THEN

		xnp_message.default_process( l_msg_header,
			l_msg_text,
			l_error_code,
			l_error_message ) ;

		IF ( l_error_code <> 0 ) THEN
			RAISE e_DEFAULT_PROCESSING_ERROR ;
		END IF ;

		xnp_message.update_status(
			p_msg_id=>l_msg_header.message_id,
			p_status=>'PROCESSED',
			p_order_id=>l_order_id,
			p_wi_instance_id=>l_wi_instance_id,
			p_fa_instance_id=>l_fa_instance_id) ;
		COMMIT ;

	END IF ;


	EXCEPTION
		WHEN e_MSG_VALIDATION_ERROR THEN
			ROLLBACK to after_pop;
			fnd_message.set_name ('XNP',
				'MSG_VALIDATION_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message:= FND_MESSAGE.get ;


			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN e_DEFAULT_PROCESSING_ERROR THEN
			ROLLBACK to after_pop;
			fnd_message.set_name ('XNP',
				'DFLT_PROCESSING_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN OTHERS THEN

			ROLLBACK ;
			l_fatal_error := TRUE;
			fnd_message.set_name ('XNP',
				'MSG_SERVER_EXCEPTION') ;
			fnd_message.set_token ('MSG_ID',
				l_msg_header.message_id) ;
			fnd_message.set_token ('ERROR_CODE', SQLCODE) ;
			fnd_message.set_token ('ERROR_MESSAGE',
					SQLERRM) ;
			l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;
END;
	COMMIT;

	if l_fatal_error then
	  l_dummy := instr(p_queue_name,'.');
	  if l_dummy = 0 then
		l_queue_name := p_queue_name;
	  else
		l_queue_name := substr(p_queue_name, l_dummy +1, length(p_queue_name) - l_dummy);
	  end if;

          xdp_aq_utilities.handle_dq_exception(
                p_MESSAGE_ID => 'FF',
                p_WF_ITEM_TYPE => null,
                p_WF_ITEM_KEY => null,
                p_CALLER_NAME => 'XNP_EVENT.PROCESS' ,
                p_CALLBACK_TEXT => NULL ,
                p_Q_NAME => l_queue_name,
                p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
	end if;

END process;

/***************************************************************************
*****  Procedure:    PROCESS()
*****  Purpose:      Checks if a message has arrived and delivers it to all
*****                registered applications.  Returns a timeout error if
*****                no message is received in the specified interval.
****************************************************************************/

PROCEDURE process(
	p_queue_name IN VARCHAR2,
	p_correlation_id IN VARCHAR2,
	x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS

	l_error_code NUMBER ;
	l_error_message VARCHAR2(4000) ;

	l_msg_header     XNP_MESSAGE.MSG_HEADER_REC_TYPE ;

	l_msg_text       VARCHAR2(32767) ;
	l_num_apps       NUMBER := 0;
	l_operation      VARCHAR2(4000) := NULL ;
	l_description    VARCHAR2(4000) := NULL ;
	l_fnd_message    VARCHAR2(4000) := NULL ;

	l_order_id        NUMBER;
	l_wi_instance_id  NUMBER;
	l_fa_instance_id  NUMBER ;

	CURSOR registered_apps ( l_reference_id IN VARCHAR2,
                           l_msg_code IN VARCHAR2 )
	IS
		SELECT callback_event_id,
			callback_proc_name,
			process_reference,
			close_reqd_flag,
			order_id,
			wi_instance_id,
			fa_instance_id
		FROM XNP_CALLBACK_EVENTS
		WHERE reference_id in (l_reference_id, '-1')
--		WHERE ((reference_id = l_reference_id) OR (reference_id IS NULL))
		AND msg_code = l_msg_code
		AND status = 'WAITING' ;

	e_MSG_VALIDATION_ERROR      EXCEPTION ;
	e_MSG_PROCESSING_ERROR      EXCEPTION ;
	e_MSG_DELIVERY_ERROR        EXCEPTION ;
	e_DEFAULT_PROCESSING_ERROR  EXCEPTION ;

BEGIN
BEGIN

	l_error_code := 0 ;
	l_error_message := NULL ;

	xnp_message.pop (p_queue_name => p_queue_name,
		x_msg_header => l_msg_header,
		x_body_text => l_msg_text,
		x_error_code => l_error_code,
		x_error_message => l_error_message,
		p_correlation_id => process.p_correlation_id ) ;

	SAVEPOINT after_pop ;

	IF ( l_error_code = XNP_ERRORS.G_DEQUEUE_TIMEOUT ) THEN
		-- DBMS_LOCK.sleep(5) ;
		x_queue_timed_out := 'Y';
		RETURN ;
	END IF ;

	xnp_message.validate ( l_msg_header,
		l_msg_text,
		l_error_code,
		l_error_message ) ;

	IF (l_error_code <> 0) THEN
		RAISE e_MSG_VALIDATION_ERROR ;
	END IF ;

-- Process and deliver message to all registered applications

	FOR app IN registered_apps ( l_msg_header.reference_id,
		l_msg_header.message_code ) LOOP

		l_order_id := app.order_id;
		l_wi_instance_id := app.wi_instance_id;
		l_fa_instance_id := app.fa_instance_id ;
		l_msg_header.order_id := app.order_id;
		l_msg_header.wi_instance_id := app.wi_instance_id;
		l_msg_header.fa_instance_id := app.fa_instance_id ;

		l_num_apps := l_num_apps + 1 ;

		SAVEPOINT  deliver_msg ;

		BEGIN

		xnp_message.process ( l_msg_header,
			l_msg_text,
			app.process_reference,
			l_error_code,
			l_error_message ) ;

		IF (l_error_code <> 0) THEN
			RAISE e_MSG_PROCESSING_ERROR ;
		END IF ;

		xnp_event.unsubscribe ( app.callback_event_id,
			app.process_reference, app.close_reqd_flag ) ;

		deliver ( l_msg_header.message_id,
			app.callback_proc_name,
			app.process_reference,
			l_error_code,
			l_error_message ) ;

		IF (l_error_code <> 0) THEN
			RAISE e_MSG_DELIVERY_ERROR ;
		END IF ;


		xnp_message.update_status(
			p_msg_id=>l_msg_header.message_id,
			p_status=>'PROCESSED',
			p_order_id=>l_order_id,
			p_wi_instance_id=>l_wi_instance_id,
			p_fa_instance_id=>l_fa_instance_id) ;

		EXCEPTION
		WHEN e_MSG_DELIVERY_ERROR THEN
			ROLLBACK to deliver_msg ;

			fnd_message.set_name ('XNP', 'MSG_DELIVERY_ERROR') ;
			fnd_message.set_token ('CALLBACK',
				app.callback_proc_name);
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

			l_fnd_message:= fnd_message.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;


		WHEN e_MSG_PROCESSING_ERROR THEN
			ROLLBACK to deliver_msg ;

			fnd_message.set_name ('XNP', 'MSG_PROCESSING_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message := fnd_message.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN OTHERS THEN

			ROLLBACK ;
			fnd_message.set_name ('XNP', 'MSG_SERVER_EXCEPTION') ;
			fnd_message.set_token ('MSG_ID',
				l_msg_header.message_id) ;
			fnd_message.set_token ('ERROR_CODE', SQLCODE) ;
			fnd_message.set_token ('ERROR_MESSAGE', SQLERRM) ;
				l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_statuS(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;
		END ;

		COMMIT ;

	END LOOP ;

-- If no apps have registered, execute the default processing logic

	IF ( l_num_apps = 0 ) THEN

		xnp_message.default_process( l_msg_header,
			l_msg_text,
			l_error_code,
			l_error_message ) ;

		IF ( l_error_code <> 0 ) THEN
			RAISE e_DEFAULT_PROCESSING_ERROR ;
		END IF ;

		xnp_message.update_status(
			p_msg_id=>l_msg_header.message_id,
			p_status=>'PROCESSED',
			p_order_id=>l_order_id,
			p_wi_instance_id=>l_wi_instance_id,
			p_fa_instance_id=>l_fa_instance_id) ;
		COMMIT ;

	END IF ;


	EXCEPTION
		WHEN e_MSG_VALIDATION_ERROR THEN
			ROLLBACK to after_pop;
			fnd_message.set_name ('XNP',
				'MSG_VALIDATION_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message:= FND_MESSAGE.get ;


			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN e_DEFAULT_PROCESSING_ERROR THEN
			ROLLBACK to after_pop;
			fnd_message.set_name ('XNP',
				'DFLT_PROCESSING_ERROR') ;
			fnd_message.set_token ('MSG_CODE',
				l_msg_header.message_code) ;
			fnd_message.set_token ('ERROR_CODE',
				TO_CHAR(l_error_code)) ;
			fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;
			l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;

		WHEN OTHERS THEN

			ROLLBACK ;
			fnd_message.set_name ('XNP',
				'MSG_SERVER_EXCEPTION') ;
			fnd_message.set_token ('MSG_ID',
				l_msg_header.message_id) ;
			fnd_message.set_token ('ERROR_CODE', SQLCODE) ;
			fnd_message.set_token ('ERROR_MESSAGE',
					SQLERRM) ;
			l_fnd_message:= FND_MESSAGE.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message,
				p_order_id=>l_order_id,
				p_wi_instance_id=>l_wi_instance_id,
				p_fa_instance_id=>l_fa_instance_id) ;
END;
	COMMIT;

END process;
/***************************************************************************
*****  Procedure:    DELIVER()
*****  Purpose:      Delivers the message to the callback procedure.
****************************************************************************/

PROCEDURE deliver(
	p_msg_id IN NUMBER
	,p_callback_proc VARCHAR2
	,p_process_reference VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

	l_cursor             NUMBER ;
	l_sql                VARCHAR2(4000) ;
	l_num_rows           NUMBER ;
	l_error_code         NUMBER ;
	l_error_message      VARCHAR2(4000) ;

BEGIN

	l_sql := 'BEGIN' || g_new_line
		|| p_callback_proc || '( :message_id, :process_reference, '
		|| ':error_code, :error_message ) ;' || g_new_line
		|| 'END ;' ;

	EXECUTE IMMEDIATE l_sql USING
		p_msg_id
		,p_process_reference
		,OUT l_error_code
		,OUT l_error_message ;

	x_error_code := l_error_code ;
	x_error_message := l_error_message ;

END deliver;

/***************************************************************************
*****  Procedure:    SUBSCRIBE_FOR_ACKS()
*****  Purpose:      SUBSCRIBEs a callback for all the expected ACK messages
*****                from the remote system.  Callbacks can be registered
*****                for any of the immediate responses from the peer
*****                system.  The response will be delivered to the
*****                registered application on receiving it.
****************************************************************************/

PROCEDURE subscribe_for_acks(
	p_message_type IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
)
IS
	l_ack_code XNP_MSG_TYPES_B.MSG_CODE%TYPE ;

	CURSOR c_Acks IS
		SELECT ack_msg_code FROM XNP_MSG_ACKS
		WHERE source_msg_code = p_message_type;

BEGIN

	x_error_code := 0;
	x_error_message := NULL ;

	FOR cur_rec IN c_Acks LOOP

	xnp_event.subscribe(
		p_msg_code=>cur_rec.ack_msg_code
		,p_reference_id=>p_reference_id
		,p_process_reference=>p_process_reference
		,p_procedure_name=>'XNP_EVENT.RESUME_WORKFLOW'
		,p_callback_type=>'PL/SQL'
		,p_close_reqd_flag => 'Y'
		,p_order_id=>p_order_id
		,p_wi_instance_id=>p_wi_instance_id
		,p_fa_instance_id=>p_fa_instance_id
		);

	END LOOP;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;
END;

/***************************************************************************
*****  Procedure:    RESUME_WORKFLOW()
*****  Purpose:      Resumes the workflow instance.
****************************************************************************/

PROCEDURE resume_workflow (
	p_message_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

	l_wf_activity     VARCHAR2(256) ;
	l_wf_type         VARCHAR2(256) ;
	l_wf_key          VARCHAR2(256) ;
	l_fnd_message     VARCHAR2(4000) ;

	-- Should change to CLOB later

	l_msg_text        	VARCHAR2(32767) ;

	l_msg_header      	XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
	l_sdp_result_code 	VARCHAR2(40) := NULL;
	e_workflow_parameters_invalid EXCEPTION ;

BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;

	-- Derive the workflow itemtype, itemkey and activity

	xnp_utils.get_wf_instance( p_process_reference, l_wf_type,
		l_wf_key, l_wf_activity ) ;

	IF( (l_wf_key IS NULL) OR (l_wf_type IS NULL) OR
		(l_wf_activity IS NULL) )
	THEN
		raise e_workflow_parameters_invalid;
	END IF;

	-- Set the MESSAGE_BODY item attribute

-- adabholk 03/2001
-- performance fix
-- new get() replaces two get calls

	xnp_message.get(
			p_msg_id => p_message_id
			,x_msg_header => l_msg_header
			,x_msg_text => l_msg_text);

/*
--	xnp_message.get_header(p_message_id, l_msg_header) ;
--
--	xnp_message.get (p_message_id, l_msg_text) ;
--
*/

	/* Resume the workflow */

	xnp_xml_utils.decode (l_msg_text,
		'SDP_RESULT_CODE',
		l_sdp_result_code) ;

	IF (l_sdp_result_code IS NULL) THEN

		wf_engine.completeactivity(
			l_wf_type
			,l_wf_key
			,l_wf_activity
			,l_msg_header.message_code
			) ;
	ELSE
		wf_engine.completeactivity(
			l_wf_type
			,l_wf_key
			,l_wf_activity
			,l_sdp_result_code
		) ;
	END IF ;

	EXCEPTION
		WHEN e_workflow_parameters_invalid THEN
		fnd_message.set_name  ('XNP', 'INVALID_WF_SPECIFIED') ;
		fnd_message.set_token ('MSG_ID', l_msg_header.message_id) ;
		fnd_message.set_token ('P_REFERENCE', p_process_reference) ;
		l_fnd_message := FND_MESSAGE.get ;

		xnp_message.update_status(p_message_id,
			'FAILED',
			l_fnd_message) ;

		xnp_message.update_status(p_msg_id=>l_msg_header.message_id,
			p_status=>'FAILED',
			p_error_desc=>l_fnd_message) ;

		x_error_code := xnp_errors.g_invalid_workflow ;
		x_error_message := l_fnd_message ;

		WHEN OTHERS THEN
			x_error_code := SQLCODE ;
			x_error_message := SQLERRM ;

END resume_workflow ;

PROCEDURE sync_n_resume_wf (
        p_message_id IN NUMBER
        ,p_process_reference IN VARCHAR2
        ,x_error_code OUT NOCOPY NUMBER
        ,x_error_message OUT NOCOPY VARCHAR2
)
IS
  l_wf_activity     VARCHAR2(256) ;
  l_wf_type         VARCHAR2(256) ;
  l_wf_key          VARCHAR2(256) ;
  l_actid           NUMBER;
  l_fa_instance_id  NUMBER;

  CURSOR c_get_fa_instance_id IS
  SELECT fa_instance_id
    FROM xnp_msgs
   WHERE msg_id = p_message_id;

BEGIN

  -- Derive the workflow itemtype, itemkey and activity
  xnp_utils.get_wf_instance( p_process_reference, l_wf_type,
                             l_wf_key, l_wf_activity ) ;

  --get the activity id..
  l_actid := wf_process_activity.ActiveInstanceId(l_wf_type, l_wf_key,
                 l_wf_activity, wf_engine.eng_notified);

  FOR lv_rec IN c_get_fa_instance_id LOOP
    l_fa_instance_id := lv_rec.fa_instance_id;

    --STEP3 : upload FA parameters..
    xnp_wf_standard.uploadFAParams( l_wf_type, l_wf_key, l_actid, l_fa_instance_id);

    --STEP3 : download WI parameters..
    xnp_wf_standard.downloadWIParams( l_wf_type, l_wf_key );

  END LOOP;
  --Resume the workflow after synching the parameters..
  resume_workflow ( p_message_id, p_process_reference, x_error_code, x_error_message );

END sync_n_resume_wf;


/***************************************************************************
*****  Procedure:    RESTART_ACTIVITY()
*****  Purpose:      Restarts the specified workflow activity.
****************************************************************************/

PROCEDURE restart_activity (
	p_message_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

	l_wf_activity     VARCHAR2(256) ;
	l_wf_type         VARCHAR2(256) ;
	l_wf_key          VARCHAR2(256) ;
	l_fnd_message     VARCHAR2(4000) := NULL;
	l_msg_text        VARCHAR2(32767) ;
	l_msg_header      xnp_message.msg_header_rec_type ;
	l_sdp_result_code VARCHAR2(3) := NULL;

	l_result          VARCHAR2(200) := NULL;

	e_workflow_parameters_invalid EXCEPTION ;


BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;
	l_fnd_message := NULL ;

	xnp_utils.get_wf_instance( p_process_reference, l_wf_type,
		l_wf_key, l_wf_activity ) ;

	IF( (l_wf_key IS NULL) OR (l_wf_type IS NULL) OR
		(l_wf_activity IS NULL) )
	THEN
		raise e_workflow_parameters_invalid;
	END IF;

	wf_engine.setitemattrnumber(
		l_wf_type,
		l_wf_key,
		'MSG_ID',
		l_msg_header.message_id ) ;

	wf_engine.handleerror (
		l_wf_type
		,l_wf_key
		,l_wf_activity
		,'RETRY'
		,l_result
	) ;

	EXCEPTION
		WHEN e_workflow_parameters_invalid THEN

			fnd_message.set_name  ('XNP', 'INVALID_WF_SPECIFIED') ;
			fnd_message.set_token ('MSG_ID',
				l_msg_header.message_id) ;
			fnd_message.set_token ('P_REFERENCE',
				p_process_reference) ;
			l_fnd_message := FND_MESSAGE.get ;

			xnp_message.update_status(
				p_msg_id=>l_msg_header.message_id,
				p_status=>'FAILED',
				p_error_desc=>l_fnd_message);

      			x_error_code := XNP_ERRORS.G_INVALID_WORKFLOW ;
			x_error_message := l_fnd_message ;

		WHEN OTHERS THEN
			x_error_code := SQLCODE ;
			x_error_message := SQLERRM ;

END restart_activity ;



/***************************************************************************
*****  Procedure:    PROCESS_IN_MSG()
*****  Purpose:      Wrapper procedure for Inbound message dequer.
****************************************************************************/
PROCEDURE process_in_msg
IS
	l_inmsg_q_state VARCHAR2(1024) ;
BEGIN

LOOP
	l_inmsg_q_state := xdp_aq_utilities.get_queue_state(
		cc_inbound_msg_q) ;

	IF ((l_inmsg_q_state = 'SHUTDOWN')OR
		(l_inmsg_q_state = 'DISABLED')) THEN
		EXIT ;
	END IF ;

	process (c_inbound_msg_q) ;

END LOOP;

END process_in_msg ;

/***************************************************************************
*****  Procedure:    PROCESS_IN_MSG()
*****  Purpose:      Wrapper procedure for Inbound message dequer.
****************************************************************************/
PROCEDURE  process_in_msg (p_message_wait_timeout IN NUMBER DEFAULT 1,
									p_correlation_id IN VARCHAR2,
                                    x_message_key OUT NOCOPY VARCHAR2,
                                    x_queue_timed_out OUT NOCOPY VARCHAR2 )

IS
BEGIN

	process (c_inbound_msg_q, p_correlation_id, x_queue_timed_out) ;

END process_in_msg ;


/***************************************************************************
*****  Procedure:    PROCESS_IN_EVT()
*****  Purpose:      Wrapper procedure for internal event dequer.
****************************************************************************/
PROCEDURE process_in_evt
 IS
	l_inevt_q_state VARCHAR2(1024) ;
BEGIN

LOOP
	l_inevt_q_state := xdp_aq_utilities.get_queue_state(
		cc_internal_evt_q) ;

	IF ((l_inevt_q_state = 'SHUTDOWN')OR
		(l_inevt_q_state = 'DISABLED')) THEN
		EXIT ;
	END IF ;

	process (c_internal_evt_q) ;

END LOOP;

END process_in_evt ;

/***************************************************************************
*****  Procedure:    PROCESS_IN_EVT()
*****  Purpose:      Wrapper procedure for internal event dequer.
****************************************************************************/
PROCEDURE  process_in_evt (p_message_wait_timeout IN NUMBER DEFAULT 1,
									p_correlation_id IN VARCHAR2,
                                    x_message_key OUT NOCOPY VARCHAR2,
                                    x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
BEGIN

	process (c_internal_evt_q, p_correlation_id, x_queue_timed_out) ;

END process_in_evt ;


--Package initialization code

BEGIN

DECLARE
	l_ret		BOOLEAN;
	l_status	VARCHAR2(80);
	l_industry 	VARCHAR2(80);
	l_schema 	VARCHAR2(80) ;
BEGIN

	l_ret := FND_INSTALLATION.GET_APP_INFO(
		application_short_name=>'XNP'
		,status=>l_status
		,industry=>l_industry
		,oracle_schema=>l_schema
		);

	IF (l_schema IS NULL) THEN
		l_schema := 'XNP' ;
	END IF;

	c_inbound_msg_q := l_schema || '.' || cc_inbound_msg_q ;
	c_outbound_msg_q := l_schema || '.' || cc_outbound_msg_q ;
	c_internal_evt_q := l_schema || '.' || cc_internal_evt_q ;
	c_timer_q := l_schema || '.' || cc_timer_q ;

END ;

END xnp_event;

/
