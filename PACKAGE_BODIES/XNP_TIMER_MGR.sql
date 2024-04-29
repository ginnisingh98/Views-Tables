--------------------------------------------------------
--  DDL for Package Body XNP_TIMER_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMER_MGR" AS
/* $Header: XNPTMGRB.pls 120.1 2005/06/17 03:49:28 appldev  $ */

  G_NEW_LINE char := fnd_global.local_chr(10) ;

/* forward declaration */

PROCEDURE start_actual_timer( p_timer_code IN VARCHAR2,
		p_dummy_header IN xnp_message.msg_header_rec_type,
		p_dummy_text IN VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE move_to_inbound(
		p_msg_header IN xnp_message.msg_header_rec_type,
		p_msg_text IN VARCHAR2,
 		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2);

/**********************************************************************
*****  Procedure:    PROCESS()
*****  Purpose:      Checks if a timer message has arrived and starts
*****                the actual timer for a dummy timer.  In case the
*****                the dequeued message is an actual timer, it
*****                enqueus it back on the inbound message Q.
***********************************************************************/

PROCEDURE process
 (p_queue_name IN VARCHAR2
 )
 IS

/*  declare all local variables here  */

  l_error_code NUMBER ;
  l_error_message VARCHAR2(4000) ;

  l_msg_header     xnp_message.msg_header_rec_type ;

  -- Change to CLOB

  l_msg_text       VARCHAR2(32767) ;
  l_operation      VARCHAR2(4000) := NULL ;
  l_description    VARCHAR2(4000) := NULL ;
  l_fnd_message    VARCHAR2(4000) := NULL ;
  l_in_tmr_q       NUMBER ;
  l_next_timer	   VARCHAR2(20);

  invalid_dummy_timer		EXCEPTION;
  failed_to_move_message	EXCEPTION;
  timer_start_failed		EXCEPTION;
  failed_to_update_status	EXCEPTION;

BEGIN

	l_error_code := 0 ;
	l_error_message := NULL ;

	/*  dequeue a message from the AQ */

	SAVEPOINT	dequeue_timer ;

	xnp_message.pop (p_queue_name => p_queue_name,
			x_msg_header => l_msg_header,
			x_body_text => l_msg_text,
			x_error_code => l_error_code,
			x_error_message => l_error_message
			) ;

	/*  check if the pop timed out */

	IF ( l_error_code = xnp_errors.g_dequeue_timeout ) THEN
		COMMIT ;
		RETURN ;
	END IF ;

/*  check if it is a control message to stop the timer server */

/*

-- adabholk 03/2001
-- performance changes
-- This code is not required

	IF (l_msg_header.message_code  = 'TMR_SERVER')
	THEN
		xnp_xml_utils.decode(l_msg_text, 'OPERATION', l_operation) ;
		IF (l_operation = 'STOP') THEN
			COMMIT;
		END IF ;
	END IF;
*/

	IF (l_msg_header.message_code  = 'T_DUMMY')
	THEN

	/* update dummy timer status to EXPIRED */

	xnp_timer_core.update_timer_status(
			p_timer_id => l_msg_header.message_id,
			p_status => 'EXPIRED',
			x_error_code => l_error_code,
			x_error_message => l_error_message);

	IF (l_error_code <> 0) THEN
		RAISE failed_to_update_status;
	END IF ;

	/*
	** Get the actual message from the timer registry
	** Next_Timer column for the timer_id
	*/
		l_next_timer := xnp_timer_core.get_next_timer
					(l_msg_header.message_id);

		IF (l_next_timer IS NULL)
		THEN
			RAISE invalid_dummy_timer;
		END IF;

		/* Start Actual Timer */

    		start_actual_timer(l_next_timer,
				l_msg_header,
				l_msg_text,
				l_error_code,
				l_error_message);

		/* check for error code/message */

		IF (l_error_code <> 0) THEN
			RAISE timer_start_failed ;
		END IF;

	ELSE
		/* update dummy timer status to EXPIRED */

		xnp_timer_core.update_timer_status(
			p_timer_id => l_msg_header.message_id,
			p_status => 'EXPIRED',
			x_error_code => l_error_code,
			x_error_message => l_error_message);


		IF (l_error_code = 0) THEN

			move_to_inbound(l_msg_header,
				l_msg_text,
				l_error_code,
				l_error_message);

			IF (l_error_code <> 0) THEN
				RAISE failed_to_move_message ;
			END IF;
		ELSE
			RAISE failed_to_update_status;

		END IF ;

	END IF;

	COMMIT ;

	EXCEPTION

    	WHEN invalid_dummy_timer THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'INVALID_DUMMY_TIMER') ;

         	fnd_message.set_token ('DUMMY_TIMER_ID',
				l_msg_header.message_id) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

    	WHEN timer_start_failed THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'START_TIMER_FAILED') ;


         	fnd_message.set_token ('ACTUAL_TIMER_CODE',
				l_next_timer) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

    	WHEN failed_to_move_message THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'TIMER_MOVE_FAILED') ;

         	fnd_message.set_token ('TIMER_ID',
				l_msg_header.message_id) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

	/* failed to update timer status in registry */

    	WHEN failed_to_update_status THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'UPDATE_TIMER_STATUS_FAILED') ;

         	fnd_message.set_token ('TIMER_ID',
				l_msg_header.message_id) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;
END process;


PROCEDURE process(
	p_queue_name IN VARCHAR2,
	p_correlation_id IN VARCHAR2,
	x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS

/*  declare all local variables here  */

  l_error_code NUMBER ;
  l_error_message VARCHAR2(4000) ;

  l_msg_header     xnp_message.msg_header_rec_type ;

  -- Change to CLOB

  l_msg_text       VARCHAR2(32767) ;
  l_operation      VARCHAR2(4000) := NULL ;
  l_description    VARCHAR2(4000) := NULL ;
  l_fnd_message    VARCHAR2(4000) := NULL ;
  l_in_tmr_q       NUMBER ;
  l_next_timer	   VARCHAR2(20);

  invalid_dummy_timer		EXCEPTION;
  failed_to_move_message	EXCEPTION;
  timer_start_failed		EXCEPTION;
  failed_to_update_status	EXCEPTION;

BEGIN

	l_error_code := 0 ;
	l_error_message := NULL ;

	/*  dequeue a message from the AQ */

	SAVEPOINT	dequeue_timer ;

	xnp_message.pop (p_queue_name => p_queue_name,
			x_msg_header => l_msg_header,
			x_body_text => l_msg_text,
			x_error_code => l_error_code,
			x_error_message => l_error_message,
			p_correlation_id => process.p_correlation_id ) ;

	/*  check if the pop timed out */

	IF ( l_error_code = xnp_errors.g_dequeue_timeout ) THEN
                x_queue_timed_out := 'Y';
		COMMIT ;
		RETURN ;
	END IF ;

/*  check if it is a control message to stop the timer server */

	IF (l_msg_header.message_code  = 'T_DUMMY')
	THEN

	/* update dummy timer status to EXPIRED */

	xnp_timer_core.update_timer_status(
			p_timer_id => l_msg_header.message_id,
			p_status => 'EXPIRED',
			x_error_code => l_error_code,
			x_error_message => l_error_message);

	IF (l_error_code <> 0) THEN
		RAISE failed_to_update_status;
	END IF ;

	/*
	** Get the actual message from the timer registry
	** Next_Timer column for the timer_id
	*/
		l_next_timer := xnp_timer_core.get_next_timer
					(l_msg_header.message_id);

		IF (l_next_timer IS NULL)
		THEN
			RAISE invalid_dummy_timer;
		END IF;

		/* Start Actual Timer */

    		start_actual_timer(l_next_timer,
				l_msg_header,
				l_msg_text,
				l_error_code,
				l_error_message);

		/* check for error code/message */

		IF (l_error_code <> 0) THEN
			RAISE timer_start_failed ;
		END IF;

	ELSE
		/* update dummy timer status to EXPIRED */

		xnp_timer_core.update_timer_status(
			p_timer_id => l_msg_header.message_id,
			p_status => 'EXPIRED',
			x_error_code => l_error_code,
			x_error_message => l_error_message);


		IF (l_error_code = 0) THEN

			move_to_inbound(l_msg_header,
				l_msg_text,
				l_error_code,
				l_error_message);

			IF (l_error_code <> 0) THEN
				RAISE failed_to_move_message ;
			END IF;
		ELSE
			RAISE failed_to_update_status;

		END IF ;

	END IF;

	COMMIT ;

	EXCEPTION

    	WHEN invalid_dummy_timer THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'INVALID_DUMMY_TIMER') ;

         	fnd_message.set_token ('DUMMY_TIMER_ID',
				l_msg_header.message_id) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

    	WHEN timer_start_failed THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'START_TIMER_FAILED') ;


         	fnd_message.set_token ('ACTUAL_TIMER_CODE',
				l_next_timer) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

    	WHEN failed_to_move_message THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'TIMER_MOVE_FAILED') ;

         	fnd_message.set_token ('TIMER_ID',
				l_msg_header.message_id) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;

	/* failed to update timer status in registry */

    	WHEN failed_to_update_status THEN

		ROLLBACK TO dequeue_timer ;

         	fnd_message.set_name ('XNP', 'UPDATE_TIMER_STATUS_FAILED') ;

         	fnd_message.set_token ('TIMER_ID',
				l_msg_header.message_id) ;

         	fnd_message.set_token ('ERROR_CODE',
				l_error_code) ;

         	fnd_message.set_token ('ERROR_MESSAGE',
				l_error_message) ;

         	l_fnd_message:= FND_MESSAGE.get ;

		xnp_message.update_status(l_msg_header.message_id,
				'FAILED',
				l_fnd_message) ;
END process;


/***********************************************************************
*****	Procedure:	START_ACTUAL_TIMER()
*****	Purpose:	Starts the actual timer for a dummy.
***********************************************************************/

PROCEDURE start_actual_timer( p_timer_code IN VARCHAR2,
		p_dummy_header IN xnp_message.msg_header_rec_type,
		p_dummy_text IN VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2)

IS

	l_msg_text	VARCHAR2(32767);
	v_msg_header	xnp_message.msg_header_rec_type ;

	l_actual_interval_text	VARCHAR2(80) ;
	l_payload VARCHAR2(16000);
	l_actual_interval	NUMBER ;
	l_delay NUMBER := 0 ;
	l_num_rows NUMBER ;


BEGIN


	/* get the interval for the actual timer */

	xnp_xml_utils.decode(p_dummy_text,'PAYLOAD',l_payload);

	xnp_xml_utils.decode(l_payload,'INTERVAL',l_actual_interval_text);

	l_actual_interval := TO_NUMBER(l_actual_interval_text) ;

	/* construct the actual timer */

	construct_dynamic_message(p_msg_to_create => p_timer_code,
				p_old_msg_header => p_dummy_header,
				p_delay => 0,
				p_interval => l_actual_interval,
				x_new_msg_header => v_msg_header,
				x_new_msg_text => l_msg_text,
				x_error_code => x_error_code,
				x_error_message => x_error_message) ;


	IF ( x_error_code = 0) THEN

	/* start the timer */

		xnp_timer.start_timer(v_msg_header,
				l_msg_text,
				x_error_code,
				x_error_message) ;

	END IF ;


EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM ;

END START_ACTUAL_TIMER ;

/**********************************************************************
*****  Procedure:    MOVE_TO_INBOUND()
*****  Purpose:      Moves a message to inbound queue.
***********************************************************************/

PROCEDURE move_to_inbound(
		p_msg_header IN xnp_message.msg_header_rec_type,
		p_msg_text IN VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2)

IS
	l_message            system.xnp_message_type ;
	l_msg_id             XNP_MSGS.MSG_ID%TYPE ;
	my_enqueue_options   dbms_aq.enqueue_options_t ;
	message_properties   dbms_aq.message_properties_t ;
	message_handle       RAW(16) ;


	l_feedback           VARCHAR2(4000) := NULL ;

BEGIN

	message_properties.priority := 3 ;
	message_properties.correlation := 'MSG_SERVER' ;

-- adabholk 03/2001
-- Perfomance Changes
-- Changed incorrect enqueue option at the time of performance changes

--	my_enqueue_options.visibility := DBMS_AQ.IMMEDIATE ;
	my_enqueue_options.visibility := DBMS_AQ.ON_COMMIT ;

	l_message := system.xnp_message_type(p_msg_header.message_id) ;

	DBMS_AQ.ENQUEUE (
			queue_name => xnp_event.c_inbound_msg_q ,
			enqueue_options => my_enqueue_options,
			message_properties => message_properties,
			payload => l_message,
			msgid => message_handle ) ;

END move_to_inbound ;


/*****************************************************************************/

PROCEDURE construct_dynamic_message(
			p_msg_to_create  IN VARCHAR2,
			p_old_msg_header IN xnp_message.msg_header_rec_type,
			p_delay IN NUMBER DEFAULT NULL,
			p_interval IN NUMBER DEFAULT NULL,
			x_new_msg_header OUT NOCOPY xnp_message.msg_header_rec_type,
			x_new_msg_text OUT NOCOPY VARCHAR2,
			x_error_code OUT NOCOPY NUMBER,
			x_error_message OUT NOCOPY VARCHAR2)

IS

	l_sql_block VARCHAR2(32767) ;
	l_num_rows  NUMBER;

BEGIN


	l_sql_block :=
		'
	BEGIN
		DECLARE
		l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
		BEGIN
		' || g_new_line ;


		l_sql_block := l_sql_block || g_new_line ||
			p_msg_to_create ||
				'.CREATE_MSG(l_msg_header,
   		 			:l_msg_text,
					:error_code,
					:error_message,
					:l_sender_name,
					:l_recipient_list,
					:l_version,
					:l_reference_id,
					:l_opp_reference_id,
					:l_order_id,
					:l_wi_instance_id,
					:l_fa_instance_id
				' || g_new_line ;

		IF (p_delay IS NOT NULL) THEN


			l_sql_block := l_sql_block ||
			'
			,:delay

			' || g_new_line ;

		END IF ;

		IF (p_interval IS NOT NULL) THEN
			l_sql_block := l_sql_block ||
			'
			,:interval

			' || g_new_line ;

		END IF ;

		l_sql_block := l_sql_block ||
		'
		);
		:message_id := l_msg_header.message_id;
		:message_code := l_msg_header.message_code;
		:reference_id := l_msg_header.reference_id;
		:opp_ref_id := l_msg_header.opp_reference_id;
		:creation_date := l_msg_header.creation_date;
		:sender_name := l_msg_header.sender_name;
		:recipient_name := l_msg_header.recipient_name;
		:version := l_msg_header.version;
		:direction_indr := l_msg_header.direction_indr;
		:order_id := l_msg_header.order_id;
		:wi_instance_id := l_msg_header.wi_instance_id;
		:fa_instance_id := l_msg_header.fa_instance_id;
		END ;
	END ;

	' || g_new_line ; /* end dynamic sql block */


	IF (p_delay IS NULL AND p_interval IS NULL)
	THEN
		EXECUTE IMMEDIATE l_sql_block USING
			 OUT x_new_msg_text
			,OUT x_error_code
			,OUT x_error_message
			,p_old_msg_header.sender_name
			,p_old_msg_header.recipient_name
			,p_old_msg_header.version
			,p_old_msg_header.reference_id
			,p_old_msg_header.opp_reference_id
			,p_old_msg_header.order_id
			,p_old_msg_header.wi_instance_id
			,p_old_msg_header.fa_instance_id
			,OUT x_new_msg_header.message_id
			,OUT x_new_msg_header.message_code
			,OUT x_new_msg_header.reference_id
			,OUT x_new_msg_header.opp_reference_id
			,OUT x_new_msg_header.creation_date
			,OUT x_new_msg_header.sender_name
			,OUT x_new_msg_header.recipient_name
			,OUT x_new_msg_header.version
			,OUT x_new_msg_header.direction_indr
			,OUT x_new_msg_header.order_id
			,OUT x_new_msg_header.wi_instance_id
			,OUT x_new_msg_header.fa_instance_id;

	ELSIF (p_delay IS NOT NULL AND p_interval IS NULL)
	THEN
		EXECUTE IMMEDIATE l_sql_block USING
			 OUT x_new_msg_text
			,OUT x_error_code
			,OUT x_error_message
			,p_old_msg_header.sender_name
			,p_old_msg_header.recipient_name
			,p_old_msg_header.version
			,p_old_msg_header.reference_id
			,p_old_msg_header.opp_reference_id
			,p_old_msg_header.order_id
			,p_old_msg_header.wi_instance_id
			,p_old_msg_header.fa_instance_id
			,p_delay
			,OUT x_new_msg_header.message_id
			,OUT x_new_msg_header.message_code
			,OUT x_new_msg_header.reference_id
			,OUT x_new_msg_header.opp_reference_id
			,OUT x_new_msg_header.creation_date
			,OUT x_new_msg_header.sender_name
			,OUT x_new_msg_header.recipient_name
			,OUT x_new_msg_header.version
			,OUT x_new_msg_header.direction_indr
			,OUT x_new_msg_header.order_id
			,OUT x_new_msg_header.wi_instance_id
			,OUT x_new_msg_header.fa_instance_id;

	ELSIF (p_delay IS NULL and p_interval IS NOT NULL)
	THEN
		EXECUTE IMMEDIATE l_sql_block USING
			 OUT x_new_msg_text
			,OUT x_error_code
			,OUT x_error_message
			,p_old_msg_header.sender_name
			,p_old_msg_header.recipient_name
			,p_old_msg_header.version
			,p_old_msg_header.reference_id
			,p_old_msg_header.opp_reference_id
			,p_old_msg_header.order_id
			,p_old_msg_header.wi_instance_id
			,p_old_msg_header.fa_instance_id
			,p_interval
			,OUT x_new_msg_header.message_id
			,OUT x_new_msg_header.message_code
			,OUT x_new_msg_header.reference_id
			,OUT x_new_msg_header.opp_reference_id
			,OUT x_new_msg_header.creation_date
			,OUT x_new_msg_header.sender_name
			,OUT x_new_msg_header.recipient_name
			,OUT x_new_msg_header.version
			,OUT x_new_msg_header.direction_indr
			,OUT x_new_msg_header.order_id
			,OUT x_new_msg_header.wi_instance_id
			,OUT x_new_msg_header.fa_instance_id;
	ELSE


		EXECUTE IMMEDIATE l_sql_block USING
			 OUT x_new_msg_text
			,OUT x_error_code
			,OUT x_error_message
			,p_old_msg_header.sender_name
			,p_old_msg_header.recipient_name
			,p_old_msg_header.version
			,p_old_msg_header.reference_id
			,p_old_msg_header.opp_reference_id
			,p_old_msg_header.order_id
			,p_old_msg_header.wi_instance_id
			,p_old_msg_header.fa_instance_id
			,p_delay
			,p_interval
			,OUT x_new_msg_header.message_id
			,OUT x_new_msg_header.message_code
			,OUT x_new_msg_header.reference_id
			,OUT x_new_msg_header.opp_reference_id
			,OUT x_new_msg_header.creation_date
			,OUT x_new_msg_header.sender_name
			,OUT x_new_msg_header.recipient_name
			,OUT x_new_msg_header.version
			,OUT x_new_msg_header.direction_indr
			,OUT x_new_msg_header.order_id
			,OUT x_new_msg_header.wi_instance_id
			,OUT x_new_msg_header.fa_instance_id;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM ;

END construct_dynamic_message;

/***********************************************************************
*****	Procedure:	PROCESS_IN_TMR()
*****	Purpose:	Wrapper procedure for inbound Timer dequer
***********************************************************************/
PROCEDURE PROCESS_IN_TMR
IS
	l_in_tmr_q_state VARCHAR2(1024) ;
BEGIN

	LOOP

		l_in_tmr_q_state := xdp_aq_utilities.get_queue_state
				(xnp_event.cc_timer_q) ;

		IF ((l_in_tmr_q_state = 'SHUTDOWN') OR
			(l_in_tmr_q_state = 'DISABLED'))
		THEN
			RETURN ;
    		END IF ;

		process (xnp_event.c_timer_q);

	END LOOP;

END PROCESS_IN_TMR;

PROCEDURE  process_in_tmr (p_message_wait_timeout IN NUMBER DEFAULT 1,
			p_correlation_id IN VARCHAR2,
			x_message_key OUT NOCOPY VARCHAR2,
			x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
BEGIN

	process (xnp_event.c_timer_q, p_correlation_id, x_queue_timed_out) ;

END process_in_tmr ;

END XNP_TIMER_MGR;

/
