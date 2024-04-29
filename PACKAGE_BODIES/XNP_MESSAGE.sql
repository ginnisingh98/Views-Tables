--------------------------------------------------------
--  DDL for Package Body XNP_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MESSAGE" AS
/* $Header: XNPMSGPB.pls 120.2 2006/02/24 17:57:16 sacsharm noship $ */

e_procedure_exec_error  EXCEPTION ;
-- g_schema_set	NUMBER := 0;
-- g_schema	VARCHAR2(1024) ;
g_fnd_schema   VARCHAR2(1024) ;
g_xnp_schema   VARCHAR2(1024) ;
g_logdir       VARCHAR2(100);
g_logdate      DATE;
g_APPS_MAINTENANCE_MODE VARCHAR2(10);

g_new_line CONSTANT VARCHAR2(10) := convert(fnd_global.local_chr(10),
		substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
		'WE8ISO8859P1')  ;

PROCEDURE decode_xnp_msgs (
	p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
	p_body_text  IN VARCHAR2
) ;

PROCEDURE check_run_time_data(
	p_msg_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE drop_packages(
	p_msg_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);


/***************************************************************************
*****  Procedure:    GET_HEADER()
*****  Purpose:      Retrieves the header of a message.
****************************************************************************/

PROCEDURE get_header(
	P_MSG_ID IN NUMBER
	,X_MSG_HEADER OUT NOCOPY MSG_HEADER_REC_TYPE
	)
IS


	CURSOR get_message ( message_id IN XNP_MSGS.MSG_ID%TYPE ) IS
		SELECT  msg_id,
			msg_code,
			reference_id,
			opp_reference_id,
			msg_creation_date,
			sender_name,
			recipient_name,
			msg_version,
			order_id,
			wi_instance_id,
			fa_instance_id
		FROM  xnp_msgs
		WHERE msg_id = message_id ;

BEGIN

	OPEN  get_message ( p_msg_id ) ;

	FETCH get_message INTO
		x_msg_header.message_id,
		x_msg_header.message_code,
		x_msg_header.reference_id,
		x_msg_header.opp_reference_id,
		x_msg_header.creation_date,
		x_msg_header.sender_name,
		x_msg_header.recipient_name,
		x_msg_header.version,
		x_msg_header.order_id,
		x_msg_header.wi_instance_id,
		x_msg_header.fa_instance_id ;

	CLOSE get_message ;

END get_header;

/***************************************************************************
*****  Procedure:    PROCESS()
*****  Purpose:      Executes the processing logic for the message .
****************************************************************************/

PROCEDURE process(
	p_msg_header IN MSG_HEADER_REC_TYPE
	,P_MSG_TEXT IN VARCHAR2
	,P_PROCESS_REFERENCE IN VARCHAR2
	,X_ERROR_CODE OUT NOCOPY NUMBER
	,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
)
IS

	l_cursor        NUMBER ;
	l_sql           VARCHAR2(16000) ;
	l_num_rows      NUMBER ;

BEGIN

x_error_code := 0 ;
x_error_message := NULL ;

l_sql:= 'BEGIN
	DECLARE
		l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
	BEGIN
		l_msg_header.message_id := :message_id ;
		l_msg_header.message_code := :message_code ;
		l_msg_header.reference_id := :reference_id ;
		l_msg_header.opp_reference_id := :opp_ref_id ;
		l_msg_header.creation_date := :creation_date;
		l_msg_header.sender_name := :sender_name ;
		l_msg_header.recipient_name := :recipient_name ;
		l_msg_header.version := :version;
		l_msg_header.direction_indr := :direction_indr ;
		l_msg_header.order_id := :order_id ;
		l_msg_header.wi_instance_id := :wi_instance_id ;
		l_msg_header.fa_instance_id := :fa_instance_id ; '
	|| g_new_line ;

	l_sql := l_sql || g_new_line || '    '
		|| g_pkg_prefix || p_msg_header.message_code
		|| g_pkg_suffix || '.' || 'PROCESS(' || g_new_line
		|| '    l_msg_header, ' || g_new_line
		|| '    :l_msg_body, ' || g_new_line
		|| '    :error_code, ' || g_new_line
		|| '    :error_message, ' || g_new_line
		|| '    :l_process_ref ) ; ' || g_new_line
		|| '  END ;' || g_new_line
		|| 'END ;' ;


	EXECUTE IMMEDIATE l_sql USING
		IN  p_msg_header.message_id
		,IN  p_msg_header.message_code
		,IN  p_msg_header.reference_id
		,IN  p_msg_header.opp_reference_id
		,IN  p_msg_header.creation_date
		,IN  p_msg_header.sender_name
		,IN  p_msg_header.recipient_name
		,IN  p_msg_header.version
		,IN  p_msg_header.direction_indr
		,IN  p_msg_header.order_id
		,IN  p_msg_header.wi_instance_id
		,IN  p_msg_header.fa_instance_id
		,IN  p_msg_text
		,OUT x_error_code
		,OUT x_error_message
		,IN  p_process_reference ;

END process;


/***************************************************************************
*****  Procedure:    DEFAULT_PROCESS()
*****  Purpose:      Executes the processing logic for the message .
****************************************************************************/

PROCEDURE default_process(
	p_msg_header IN MSG_HEADER_REC_TYPE
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2

)
IS

l_cursor        NUMBER ;
l_sql           VARCHAR2(16000) ;
l_num_rows      NUMBER ;

BEGIN


l_sql:= 'BEGIN
	DECLARE
		l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
	BEGIN
		l_msg_header.message_id := :message_id ;
	l_msg_header.message_code := :message_code ;
	l_msg_header.reference_id := :reference_id ;
	l_msg_header.opp_reference_id := :opp_ref_id ;
	l_msg_header.creation_date := :creation_date;
	l_msg_header.sender_name := :sender_name ;
	l_msg_header.recipient_name := :recipient_name ;
	l_msg_header.version := :version;
	l_msg_header.direction_indr := :direction_indr ;
	l_msg_header.order_id := :order_id ;
	l_msg_header.wi_instance_id := :wi_instance_id ;
	l_msg_header.fa_instance_id := :fa_instance_id ; ' || g_new_line ;

	l_sql := l_sql || g_new_line || '    '
	|| g_pkg_prefix || p_msg_header.message_code
	|| g_pkg_suffix || '.' || 'DEFAULT_PROCESS(' || g_new_line
	|| '    l_msg_header, ' || g_new_line
	|| '    :l_msg_body, ' || g_new_line
	|| '    :error_code, ' || g_new_line
	|| '    :error_message ) ; ' || g_new_line
	|| '  END ;' || g_new_line
	|| 'END ;' ;


	EXECUTE IMMEDIATE l_sql USING
		IN  p_msg_header.message_id
		,IN  p_msg_header.message_code
		,IN  p_msg_header.reference_id
		,IN  p_msg_header.opp_reference_id
		,IN  p_msg_header.creation_date
		,IN  p_msg_header.sender_name
		,IN  p_msg_header.recipient_name
		,IN  p_msg_header.version
		,IN  p_msg_header.direction_indr
		,IN  p_msg_header.order_id
		,IN  p_msg_header.wi_instance_id
		,IN  p_msg_header.fa_instance_id
		,IN  p_msg_text
		,OUT x_error_code
		,OUT x_error_message ;

END default_process;

/***************************************************************************
*****  Procedure:    VALIDATE()
*****  Purpose:      Validates a message using the customer's validation logic.
****************************************************************************/

PROCEDURE validate(
	p_msg_header IN OUT NOCOPY msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

	l_cursor        NUMBER ;
	l_sql           VARCHAR2(16000) ;
	l_num_rows      NUMBER ;

BEGIN


l_sql:= 'BEGIN
	DECLARE
		l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
	BEGIN
		l_msg_header.message_id := :message_id ;
		l_msg_header.message_code := :message_code ;
		l_msg_header.reference_id := :reference_id ;
		l_msg_header.opp_reference_id := :opp_ref_id ;
		l_msg_header.creation_date := :creation_date;
		l_msg_header.sender_name := :sender_name ;
		l_msg_header.recipient_name := :recipient_name ;
		l_msg_header.version := :version;
		l_msg_header.direction_indr := :direction_indr ;
		l_msg_header.order_id := :order_id ;
		l_msg_header.wi_instance_id := :wi_instance_id ;
		l_msg_header.fa_instance_id := :fa_instance_id ; '
			|| g_new_line ;

l_sql := l_sql || g_new_line || '    '
	|| g_pkg_prefix || p_msg_header.message_code
	|| g_pkg_suffix || '.' || 'VALIDATE(' || g_new_line
	|| '    l_msg_header, ' || g_new_line
	|| '    :l_msg_body, ' || g_new_line
	|| '    :error_code, ' || g_new_line
	|| '    :error_message ) ; ' || g_new_line
	||
	'
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
	'
	|| '  END ;' || g_new_line
	|| 'END ;' ;


	EXECUTE IMMEDIATE l_sql USING
		IN OUT p_msg_header.message_id
		,IN OUT p_msg_header.message_code
		,IN OUT p_msg_header.reference_id
		,IN OUT p_msg_header.opp_reference_id
		,IN OUT p_msg_header.creation_date
		,IN OUT p_msg_header.sender_name
		,IN OUT p_msg_header.recipient_name
		,IN OUT p_msg_header.version
		,IN OUT p_msg_header.direction_indr
		,IN OUT p_msg_header.order_id
		,IN OUT p_msg_header.wi_instance_id
		,IN OUT p_msg_header.fa_instance_id
		,IN p_msg_text
		,OUT x_error_code
		,OUT x_error_message ;

END validate;

/***************************************************************************
*****  Procedure:    GET_SEQUENCE()
*****  Purpose:      Gets the next sequence ID for the message .
****************************************************************************/

PROCEDURE get_sequence(
	x_msg_id OUT NOCOPY NUMBER
)
IS
BEGIN

	SELECT  ( XNP_MSGS_S.nextval )  INTO x_msg_id  FROM DUAL ;

END get_sequence;

/***************************************************************************
*****  Procedure:    GET()
*****  Purpose:      Overloaded to retrieve the header and the message
*****                adabholk 03/2001
*****                performance fix
****************************************************************************/

PROCEDURE get(
	P_MSG_ID IN NUMBER
	,X_MSG_HEADER OUT NOCOPY MSG_HEADER_REC_TYPE
	,X_MSG_TEXT OUT NOCOPY VARCHAR2
	)
IS

	l_lob_loc CLOB;
	l_amount_to_read INTEGER;
	l_rec_found BOOLEAN := false;

	CURSOR get_message (message_id IN XNP_MSGS.MSG_ID%TYPE ) IS
		SELECT  msg_id,
			msg_code,
			reference_id,
			opp_reference_id,
			msg_creation_date,
			sender_name,
			recipient_name,
			msg_version,
			order_id,
			wi_instance_id,
			fa_instance_id,
			body_text
		FROM  xnp_msgs
		WHERE msg_id = message_id ;

BEGIN

	FOR rec IN  get_message(p_msg_id)
	LOOP
		x_msg_header.message_id := rec.msg_id;
		x_msg_header.message_code := rec.msg_code;
		x_msg_header.reference_id := rec.reference_id;
		x_msg_header.opp_reference_id := rec.opp_reference_id;
		x_msg_header.creation_date := rec.msg_creation_date;
		x_msg_header.sender_name := rec.sender_name;
		x_msg_header.recipient_name := rec.recipient_name;
		x_msg_header.version := rec.msg_version;
		x_msg_header.order_id := rec.order_id;
		x_msg_header.wi_instance_id := rec.wi_instance_id;
		x_msg_header.fa_instance_id := rec.fa_instance_id;

		l_lob_loc := rec.body_text;

		l_rec_found := TRUE;

		exit;

	END LOOP;

	IF l_rec_found THEN

		l_amount_to_read := DBMS_LOB.GETLENGTH(l_lob_loc);

		DBMS_LOB.READ(lob_loc => l_lob_loc,
			amount => l_amount_to_read,
			offset => 1,
			buffer => x_msg_text );
	END IF;
END get;

/***************************************************************************
*****  Procedure:    GET()
*****  Purpose:      Gets a message for the given message ID .
****************************************************************************/

PROCEDURE get(
	p_msg_id IN NUMBER
	,x_msg_text OUT NOCOPY VARCHAR2
)
IS

	l_lob_loc  CLOB ;
	l_amount_to_read INTEGER;

	CURSOR get_lob_loc ( message_id IN XNP_MSGS.MSG_ID%TYPE ) IS
		SELECT body_text from xnp_msgs
		WHERE msg_id = message_id ;

BEGIN

	OPEN  get_lob_loc ( p_msg_id ) ;

	FETCH get_lob_loc INTO l_lob_loc ;

	IF (get_lob_loc%NOTFOUND) THEN
		CLOSE get_lob_loc ;
		x_msg_text := NULL;
		RETURN;
	END IF;

	CLOSE get_lob_loc ;

	l_amount_to_read := DBMS_LOB.GETLENGTH(l_lob_loc) ;

	DBMS_LOB.READ(lob_loc => l_lob_loc,
		amount => l_amount_to_read,
		offset => 1,
		buffer => x_msg_text ) ;
END get;

/***************************************************************************
*****  Procedure:    PUSH()
*****  Purpose:      Inserts a message into XNP_MSGS table
*****                and enqueues the message on a specified Queue .
****************************************************************************/

PROCEDURE push(
	p_msg_header IN msg_header_rec_type
	,p_body_text IN VARCHAR2
	,p_queue_name IN VARCHAR2
	,p_recipient_list IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_priority IN INTEGER DEFAULT 1
	,p_commit_mode IN NUMBER DEFAULT c_on_commit
	,p_delay IN NUMBER DEFAULT DBMS_AQ.NO_DELAY
	,p_fe_name IN VARCHAR2 DEFAULT NULL
	,p_adapter_name IN VARCHAR2 DEFAULT NULL
)
IS

	l_message            SYSTEM.XNP_MESSAGE_TYPE ;
	my_enqueue_options   dbms_aq.enqueue_options_t ;
	message_properties   dbms_aq.message_properties_t ;
	message_handle       RAW(16) ;
	recipients           dbms_aq.aq$_recipient_list_t ;

	l_recipient_name     VARCHAR2(80) ;
	l_recipient_count    INTEGER ;
	l_initial_pos        INTEGER ;
	l_delimeter_pos      INTEGER ;

	l_lob_loc	     	 CLOB ;
	l_correlation_id     VARCHAR2(1024) ;

	l_adapter_name       XNP_MSGS.ADAPTER_NAME%TYPE;
	l_fe_name            XNP_MSGS.FE_NAME%TYPE;

	l_msg_header 	     xnp_message.msg_header_rec_type ;
	l_temp_fe				 NUMBER;
	l_temp_adapter				 NUMBER;
BEGIN

	l_msg_header := p_msg_header ;
--
--	The following block is added to stop l_adapter_name or l_fe_name from
--  being longer than 40 chars
--	Anpwang 04/24/2001
--
	IF p_recipient_list IS NOT NULL THEN
		-- get the possition of the first comma
		l_temp_fe := INSTR(p_recipient_list,',')-1;
		l_temp_adapter := l_temp_fe;
		-- if no comma, then default to the length to the width of their database column
		IF(l_temp_fe < 0) THEN
			l_temp_fe := 40;
			l_temp_adapter := 40;
		END IF;
		-- In case it is still longer than its database column
		IF(l_temp_fe > 40) THEN
			l_temp_fe := 40;
		END IF;
		-- In case it is still longer than its database column
		IF(l_temp_adapter > 40 ) THEN
			l_temp_adapter := 40;
		END IF;

	END IF;

	IF (p_adapter_name IS NULL) THEN
		-- trucate to the maximun of its database column width
		l_adapter_name := SUBSTR(p_recipient_list,1,l_temp_adapter);
	ELSE
		l_adapter_name := p_adapter_name;
	END IF;

	IF (p_fe_name IS NULL) THEN
		-- trucate to the maximun of its database column width
		l_fe_name := SUBSTR(p_recipient_list,1,l_temp_fe);
	ELSE
		l_fe_name := p_fe_name;
	END IF;

-- end of change by Anpwang 04/24/2001


	-- adabholk 03/2001 performance
	-- We do not send control messages through AQ
	-- so the following code has been simplified

	--	IF (l_msg_header.message_code = 'CONTROL') THEN
	--		l_correlation_id := 'CONTROL' ;
	--	ELSE
	--		l_correlation_id := p_correlation_id ;
	--	END IF ;


	-- adabholk 07/2001 (1156)
	-- to support specialization  nowonwards correlation id
	-- can only be MESSAGE_CODE
	-- Ideally this should be followed by all the clients of
	-- this procedure.
	-- The hard coding at this place enforces this.
	-- l_correlation_id := p_correlation_id ;

	l_correlation_id := l_msg_header.message_code ;


	IF ( l_msg_header.message_id IS NULL ) THEN
		XNP_MESSAGE.get_sequence(l_msg_header.message_id) ;
	END IF ;

	IF (((l_msg_header.direction_indr = 'I') OR
  	    (l_msg_header.direction_indr IS NULL)) AND
            (xdp_utilities.g_message_list.COUNT < 0)
           ) THEN
		decode_xnp_msgs(l_msg_header, p_body_text) ;
	END IF ;

	INSERT into xnp_msgs (
		msg_id,
		msg_code,
		direction_indicator,
		reference_id,
		opp_reference_id,
		fe_name,
		msg_creation_date,
		sender_name,
		recipient_name,
		msg_status,
		msg_version,
		order_id,
		wi_instance_id,
		fa_instance_id,
		adapter_name,
		body_text,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date )
  	VALUES (
		l_msg_header.message_id,
		l_msg_header.message_code,
		l_msg_header.direction_indr,
		l_msg_header.reference_id,
		l_msg_header.opp_reference_id,
		l_fe_name,
		sysdate,
		l_msg_header.sender_name,
		l_msg_header.recipient_name,
		'READY',
		l_msg_header.version,
		l_msg_header.order_id,
		l_msg_header.wi_instance_id,
		l_msg_header.fa_instance_id,
		l_adapter_name,
		empty_clob(),
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE )
	RETURNING body_text INTO l_lob_loc ;

        IF xdp_utilities.g_message_list.COUNT > 0 THEN

           FOR i IN 1..xdp_utilities.g_message_list.COUNT
               LOOP

                  DBMS_LOB.WRITEAPPEND (lob_loc => l_lob_loc,
                                  amount  =>LENGTH(xdp_utilities.g_message_list(i)),
                                  buffer  =>xdp_utilities.g_message_list(i));
               END LOOP ;
        ELSE
  	       DBMS_LOB.WRITE (lob_loc => l_lob_loc,
	       	               amount  => LENGTH(p_body_text),
		               offset  => 1,
		               buffer  => p_body_text) ;
        END IF ;

--
-- For incoming messages, decode header fields from the XML Message
-- and populate the denormalized columns in XNP_MSGS table.
--

	IF (p_commit_mode = C_IMMEDIATE) THEN
		COMMIT ;
	END IF ;

	IF (p_priority IS NOT NULL) THEN
		message_properties.priority := p_priority ;
	END IF ;

	IF (p_delay IS NOT NULL) THEN
		message_properties.delay := p_delay ;
	END IF;

	l_message := SYSTEM.xnp_message_type( l_msg_header.message_id ) ;

--
-- check if there is a recipient, if there is no recipient, simply enqueue the
-- message on the specified queue
--

-- Use the correlation ID if one is specified

	IF ( l_correlation_id is NOT NULL ) THEN
		message_properties.correlation := l_correlation_id ;
	END IF ;

--
-- Check if there are recipients, if there is no recipient, simply enqueue the
-- message on the specified queue
--

	IF (p_recipient_list IS NOT NULL ) THEN
		l_recipient_count := 1 ;
		l_initial_pos := 1 ;

		LOOP

      			l_delimeter_pos := INSTR ( p_recipient_list, ',',
				l_initial_pos ) ;

			IF ( l_delimeter_pos = 0 ) THEN

                                /* vbhatia -- 05/16/2002 */
                                /* Populating recipients with the last of the */
                                /* recipient list values */
                                IF( l_recipient_count > 1 ) THEN
                                    l_recipient_name := SUBSTR( p_recipient_list,
                                        l_initial_pos );
                                END IF;

				EXIT ;
			END IF ;

			l_recipient_name := SUBSTR ( p_recipient_list,
			l_initial_pos, l_delimeter_pos - l_initial_pos ) ;

			recipients (l_recipient_count) := sys.aq$_agent (
				l_recipient_name,NULL, NULL ) ;

			l_initial_pos := l_delimeter_pos + 1 ;
			l_recipient_count := l_recipient_count + 1 ;

		END LOOP ;

        /* vbhatia -- 05/16/2002 */
        /* Only if there is only one recipient */
	IF (l_delimeter_pos = 0 AND l_recipient_count = 1) THEN
		l_recipient_name := p_recipient_list ;
	END IF ;

	recipients (l_recipient_count) := sys.aq$_agent ( l_recipient_name,
			NULL, NULL ) ;

	message_properties.recipient_list := recipients ;

	END IF ;

	IF (p_commit_mode = C_IMMEDIATE) THEN
		my_enqueue_options.visibility := DBMS_AQ.IMMEDIATE ;
	ELSE
		my_enqueue_options.visibility := DBMS_AQ.ON_COMMIT ;
	END IF ;


     /* smoolcha removed hard coded strings for bug 3537148 */

     --   IF    p_queue_name = 'XNP.XNP_IN_EVT_Q' THEN
     --         message_properties.exception_queue := 'XNP.XNP_IN_EVT_EXCEPTION_Q' ;
     --   ELSIF p_queue_name = 'XNP.XNP_IN_MSG_Q' THEN
     --         message_properties.exception_queue := 'XNP.XNP_IN_MSG_EXCEPTION_Q' ;
     --   ELSIF p_queue_name = 'XNP.XNP_IN_TMR_Q' THEN
     --         message_properties.exception_queue := 'XNP.XNP_IN_TMR_EXCEPTION_Q' ;
     --   ELSIF p_queue_name = 'XNP.XNP_OUT_MSG_Q' THEN
     --         message_properties.exception_queue := 'XNP.XNP_OUT_MSG_EXCEPTION_Q' ;
     --   END IF ;

        IF  instr(p_queue_name,'XNP_IN_EVT_Q') > 0 THEN
              message_properties.exception_queue := g_xnp_schema || '.XNP_IN_EVT_EXCEPTION_Q' ;
        ELSIF instr(p_queue_name ,'XNP_IN_MSG_Q') > 0 THEN
              message_properties.exception_queue := g_xnp_schema || '.XNP_IN_MSG_EXCEPTION_Q' ;
        ELSIF instr(p_queue_name,'XNP_IN_TMR_Q') > 0 THEN
              message_properties.exception_queue := g_xnp_schema || '.XNP_IN_TMR_EXCEPTION_Q' ;
        ELSIF instr(p_queue_name,'XNP_OUT_MSG_Q') > 0 THEN
              message_properties.exception_queue := g_xnp_schema || '.XNP_OUT_MSG_EXCEPTION_Q' ;
        END IF ;

	DBMS_AQ.ENQUEUE (
		queue_name => p_queue_name ,
		enqueue_options => my_enqueue_options,
		message_properties => message_properties,
		payload => l_message,
		msgid => message_handle ) ;

END push;

/***************************************************************************
*****  Procedure:    PUSH()
*****  Purpose:      Inserts a message into XNP_MSGS table
*****                and enqueues the message on a specified Queue .
****************************************************************************/

PROCEDURE push(
	p_message_id IN NUMBER
	,p_message_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_opp_reference_id IN VARCHAR2
	,p_direction_indr IN VARCHAR2
	,p_creation_date IN DATE
	,p_sender_name IN VARCHAR2
	,p_recipient_name IN VARCHAR2
	,p_version OUT NOCOPY VARCHAR2
	,p_order_id IN NUMBER
	,p_wi_instance_id IN NUMBER
	,p_fa_instance_id IN NUMBER
	,p_body_text IN VARCHAR2
	,p_queue_name IN VARCHAR2
	,p_recipient_list IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_priority IN INTEGER DEFAULT 1
	,p_commit_mode IN NUMBER DEFAULT c_on_commit
)
IS
	l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;

BEGIN

	l_msg_header.message_id := p_message_id ;

	IF p_message_code is null THEN
		xnp_xml_utils.decode(p_body_text,'MESSAGE_CODE',
		l_msg_header.message_code) ;
	ELSE
		l_msg_header.message_code := p_message_code ;
	END IF ;

	l_msg_header.reference_id := p_reference_id ;
	l_msg_header.opp_reference_id := p_opp_reference_id ;
	l_msg_header.direction_indr := p_direction_indr ;
	l_msg_header.creation_date := p_creation_date ;
	l_msg_header.sender_name := p_sender_name ;
	l_msg_header.recipient_name := p_recipient_name ;
	l_msg_header.version := p_version ;
	l_msg_header.order_id := p_order_id ;
	l_msg_header.wi_instance_id := p_wi_instance_id ;
	l_msg_header.fa_instance_id := p_fa_instance_id ;

	push( l_msg_header,
		p_body_text,
		p_queue_name,
		p_recipient_list,
		p_correlation_id,
		p_priority,
		p_commit_mode) ;

END push ;

/***************************************************************************
*****  Procedure:    POP()
*****  Purpose:      Retrieves a message from the specified message Q .
****************************************************************************/

PROCEDURE POP(
	p_queue_name IN VARCHAR2
	,x_msg_header OUT NOCOPY MSG_HEADER_REC_TYPE
	,x_body_text OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_consumer_name IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_commit_mode IN NUMBER DEFAULT C_ON_COMMIT
	,p_msg_id IN RAW DEFAULT NULL
)
IS

	l_msg_status          VARCHAR2(40) ;
	l_message             SYSTEM.XNP_MESSAGE_TYPE ;
	my_dequeue_options    dbms_aq.dequeue_options_t ;
	message_properties    dbms_aq.message_properties_t ;
	message_handle        RAW(16) ;
	l_timeout             NUMBER ;
	e_q_time_out          EXCEPTION ;
	l_fnd_message         VARCHAR2(4000) ;

        l_count               NUMBER;

	PRAGMA  EXCEPTION_INIT ( e_q_time_out, -25228 ) ;

BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;


	IF ( POP_TIMEOUT <> 0 ) THEN
		my_dequeue_options.wait := POP_TIMEOUT ;
	END IF ;

	my_dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE ;

--
--setting the consumer name would only dequeue messages
--destined for that consumer.
--

	IF ( p_consumer_name IS NOT NULL ) THEN
		my_dequeue_options.consumer_name := p_consumer_name ;
	END IF ;

-- Use the correlation ID if one is specified

	IF ( p_correlation_id IS NOT NULL ) THEN
		my_dequeue_options.correlation := p_correlation_id ;
	END IF ;

-- Dequeue by Message Id if one is specified

	IF ( p_msg_id IS NOT NULL ) THEN
		my_dequeue_options.msgid := p_msg_id ;
	END IF ;

	my_dequeue_options.DEQUEUE_MODE := DBMS_AQ.REMOVE ;

	IF (p_commit_mode = C_IMMEDIATE) THEN
		my_dequeue_options.visibility := DBMS_AQ.IMMEDIATE ;
	ELSE
		my_dequeue_options.visibility := DBMS_AQ.ON_COMMIT ;
	END IF ;

	/* Loop till the FIRST 'READY' message is obtained  */
	-- bellsouth 1482985
 	-- process 'READY' or 'PROCESSED' messaged
	-- First consumer would change the staus to PROCESSED
	-- In case of multiple consumers we want to pick up this
	-- 'PROCESSED' message also.

	LOOP

	DBMS_AQ.DEQUEUE (
			queue_name => p_queue_name ,
			dequeue_options => my_dequeue_options,
			message_properties => message_properties,
			payload => l_message,
			msgid => message_handle ) ;

	BEGIN
                XDP_AQ_UTILITIES.SET_CONTEXT( l_message.message_id, 'MESSAGE_OBJECT');

                IF(p_queue_name = xnp_event.c_inbound_msg_q) THEN

	            IF(g_APPS_MAINTENANCE_MODE = 'MAINT') THEN

       	       		 SELECT count(*)
               		   INTO l_count
               		 FROM xnp_timer_registry
               		 WHERE timer_id = l_message.message_id;

               		 IF(l_count = 0) THEN
               		     COMMIT;
               		     fnd_file.put_line(fnd_file.log,
               		         'SET_CONTEXT: Do not process further for
                                  Message Object '||l_message.message_id);
               		     RAISE stop_processing;
               		 END IF;

           	     END IF;

                END IF;

        EXCEPTION
       	WHEN stop_processing THEN
            x_error_code := XNP_ERRORS.G_DEQUEUE_TIMEOUT;
            return;
        END;

	x_msg_header.message_id := l_message.message_id ;

	get_status (l_message.message_id, l_msg_status) ;

	IF ( l_msg_status = 'READY' OR l_msg_status = 'PROCESSED' ) THEN

-- adabholk 03/2001
-- performance fix
-- new get() replaces two get calls

		xnp_message.get(
				p_msg_id => l_message.message_id
				,x_msg_header =>  x_msg_header
				,x_msg_text =>  x_body_text);
/*
--
--			get_header (
--				l_message.message_id ,
--				x_msg_header ) ;
--
--			get ( l_message.message_id, x_body_text  ) ;
*/
			EXIT ;

		END IF ;

	END LOOP ;

	EXCEPTION
		WHEN e_q_time_out THEN
			x_error_code := XNP_ERRORS.G_DEQUEUE_TIMEOUT ;

		FND_MESSAGE.set_name ('XNP', 'DEQUEUE_TIMEOUT') ;
		l_fnd_message := FND_MESSAGE.get ;

		x_error_message := l_fnd_message ;

END pop;

/***************************************************************************
*****  Procedure:    GET_SUBSCRIBER_LIST()
*****  Purpose:      Gets a comma separated subscriber list.
****************************************************************************/

PROCEDURE get_subscriber_list(
	p_msg_code IN VARCHAR2
	,x_subscriber_list OUT NOCOPY VARCHAR2
)
IS
	CURSOR get_subscribers (message_code IN VARCHAR2) IS
		SELECT xnp_utils.get_adapter_using_fe(
		FET.fulfillment_element_name) adapter_name
		FROM xdp_fes FET,
		xnp_event_subscribers ESS
		WHERE FET.FE_ID = ESS.FE_ID
		AND ESS.msg_code = message_code ;

	l_subscriber_count INTEGER ;

BEGIN

	x_subscriber_list := NULL ;
	l_subscriber_count := 1 ;

	FOR subscriber in get_subscribers(p_msg_code) LOOP

		IF (get_subscribers%NOTFOUND) THEN
			EXIT ;
		END IF ;

		IF ( l_subscriber_count > 1 ) THEN
			x_subscriber_list:= x_subscriber_list|| ',' ;
		END IF ;

		x_subscriber_list:= x_subscriber_list
			|| subscriber.adapter_name ;

		l_subscriber_count := l_subscriber_count + 1 ;

	END LOOP ;

END get_subscriber_list ;

/***************************************************************************
*****  Procedure:    POP()
*****  Purpose:      Overloaded to retrieve a message from the
*****                specified message Q .
****************************************************************************/

PROCEDURE POP(
	p_queue_name IN VARCHAR2
	,x_message_id OUT NOCOPY NUMBER
	,x_message_code OUT NOCOPY VARCHAR2
	,x_reference_id OUT NOCOPY VARCHAR2
	,x_opp_reference_id OUT NOCOPY VARCHAR2
	,x_body_text OUT NOCOPY VARCHAR2
	,x_creation_date OUT NOCOPY DATE
	,x_sender_name OUT NOCOPY VARCHAR2
	,x_recipient_name OUT NOCOPY VARCHAR2
	,x_version OUT NOCOPY VARCHAR2
	,x_order_id OUT NOCOPY NUMBER
	,x_wi_instance_id OUT NOCOPY NUMBER
	,x_fa_instance_id OUT NOCOPY NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_consumer_name IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
)
IS

l_msg_header   XNP_MESSAGE.MSG_HEADER_REC_TYPE ;

BEGIN

	x_error_code := 0 ;
	x_error_message := 'NOTFOUND' ;

	pop (
		p_queue_name,
		l_msg_header,
		x_body_text,
		x_error_code,
		x_error_message,
		p_consumer_name,
		p_correlation_id,
		C_ON_COMMIT ) ;
--	Changed on 110100
--  As we do not want pop to happen immediately anytime
--		c_immediate ) ;

	IF (x_body_text IS NULL) THEN
		x_body_text := 'NOTFOUND' ;
	END IF ;

	IF (l_msg_header.message_id IS NULL) THEN
		x_message_id:= 0 ;
	ELSE
		x_message_id := l_msg_header.message_id ;
	END IF ;

	IF (l_msg_header.message_code IS NULL) THEN
		x_message_code := 'NOTFOUND' ;
	ELSE
		x_message_code := l_msg_header.message_code ;
	END IF ;

	IF (l_msg_header.reference_id IS NULL) THEN
		x_reference_id := 'NOTFOUND' ;
	ELSE
		x_reference_id := l_msg_header.reference_id ;
	END IF ;

	IF (l_msg_header.opp_reference_id IS NULL) THEN
		x_opp_reference_id := 'NOTFOUND' ;
	ELSE
		x_opp_reference_id := l_msg_header.opp_reference_id ;
	END IF ;

	IF (l_msg_header.creation_date IS NULL) THEN
		x_creation_date := SYSDATE;
	ELSE
		x_creation_date := l_msg_header.creation_date ;
	END IF ;

	IF (l_msg_header.sender_name IS NULL) THEN
		x_sender_name := 'NOTFOUND' ;
	ELSE
		x_sender_name := l_msg_header.sender_name ;
	END IF ;

	IF (l_msg_header.recipient_name IS NULL) THEN
		x_recipient_name := 'NOTFOUND' ;
	ELSE
		x_recipient_name := l_msg_header.recipient_name ;
	END IF ;

	IF (l_msg_header.version IS NULL) THEN
		x_version:= 0;
	ELSE
		x_version := l_msg_header.version ;
	END IF ;

	IF (l_msg_header.order_id IS NULL) THEN
		x_order_id := 0;
	ELSE
		x_order_id := l_msg_header.order_id ;
	END IF ;

	IF (l_msg_header.wi_instance_id IS NULL) THEN
		x_wi_instance_id := 0;
	ELSE
		x_wi_instance_id := l_msg_header.wi_instance_id ;
	END IF ;

	IF (l_msg_header.fa_instance_id IS NULL) THEN
		x_fa_instance_id := 0;
	ELSE
		x_fa_instance_id := l_msg_header.fa_instance_id ;
	END IF ;

END pop;

/***************************************************************************
*****  Procedure:    UPDATE_STATUS()
*****  Purpose:      Updates message status.
****************************************************************************/

PROCEDURE update_status(
	p_msg_id IN NUMBER
	,p_status IN VARCHAR2
	,p_error_desc IN VARCHAR2 DEFAULT NULL
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
)
IS

BEGIN

-- mviswana 11/2001
-- bug fix # 1882340 to populate send_rcv_date

	IF (p_order_id IS NULL) THEN
		UPDATE XNP_MSGS SET msg_status = p_status,
                send_rcv_date = SYSDATE,
                last_update_date = SYSDATE,
		description = description || p_error_desc
		WHERE msg_id = p_msg_id ;
	ELSE
		UPDATE XNP_MSGS SET msg_status = p_status,
                        send_rcv_date = SYSDATE,
                        last_update_date = SYSDATE,
			description = description || p_error_desc,
			order_id = p_order_id,
			wi_instance_id = p_wi_instance_id,
			fa_instance_id = p_fa_instance_id
		WHERE msg_id = p_msg_id ;
	END IF;

	/* Notify Fallout Management Center of Failures */

	IF (p_status = 'FAILED') THEN
		notify_fmc(p_msg_id, p_error_desc) ;
	END IF ;

END update_status ;

/***************************************************************************
*****  Procedure:    GET_STATUS()
*****  Purpose:      Gets the Message Status for a given msg ID.
****************************************************************************/

PROCEDURE get_status(
	p_msg_id IN NUMBER
	,x_status OUT NOCOPY VARCHAR2
	)
IS

	CURSOR get_msg_status IS
		SELECT msg_status FROM XNP_MSGS
		WHERE msg_id = p_msg_id ;

BEGIN

	OPEN get_msg_status ;
	FETCH get_msg_status INTO x_status ;
	CLOSE get_msg_status ;

END get_status ;

/**********************************************************************************
****
***********************************************************************************/

PROCEDURE xnp_mte_insert_element (
	p_msg_code IN VARCHAR2
	,p_msg_type IN VARCHAR2
) IS

	L_PARENT_ID	   NUMBER;
	L_CHILD_ID	   NUMBER;
	L_GRANDCHILD_ID    NUMBER;
        L_STRUCTURE_ID     NUMBER;
BEGIN

--
-- CREATING DEFAULT ELEMENTS FOR A MESSAGE
--
        -- Inserting Message Type into Elements

--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

	INSERT INTO XNP_MSG_ELEMENTS(
		MSG_ELEMENT_ID
		,MSG_CODE
		,NAME
		,ELEMENT_DATATYPE
		,MANDATORY_FLAG
		,PARAMETER_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN)
	VALUES(
		 XNP_MSG_ELEMENTS_S.NEXTVAL
		,P_MSG_CODE
		,'MESSAGE' -- Always insert type to be 'Message' - even though it can be an event or a timer
		,'VARCHAR2'
		,'Y'
		,'N'
		,FND_GLOBAL.USER_ID
		,SYSDATE
		,FND_GLOBAL.USER_ID
		,SYSDATE
                ,FND_GLOBAL.LOGIN_ID)
	RETURNING MSG_ELEMENT_ID INTO L_PARENT_ID;

        -- Inserting Message Name into Elements

--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

	INSERT INTO XNP_MSG_ELEMENTS(
		MSG_ELEMENT_ID
		,MSG_CODE
		,NAME
		,ELEMENT_DATATYPE
		,MANDATORY_FLAG
		,PARAMETER_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
		)
	VALUES(
		XNP_MSG_ELEMENTS_S.NEXTVAL
		,P_MSG_CODE
		,P_MSG_CODE
		,'VARCHAR2'
		,'Y'
		,'N'
		,FND_GLOBAL.USER_ID
		,SYSDATE
		,FND_GLOBAL.USER_ID
		,SYSDATE
                ,FND_GLOBAL.LOGIN_ID
		)
	RETURNING MSG_ELEMENT_ID INTO L_CHILD_ID;

        -- Inserting Message Name into Structures with 'Message' as parent

--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

	INSERT INTO XNP_MSG_STRUCTURES(
                 STRUCTURE_ID
		,PARENT_ELEMENT_ID
		,CHILD_ELEMENT_ID
		,MSG_CODE
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
		)
	VALUES(
         XNP_MSG_STRUCTURES_S.NEXTVAL
		,L_PARENT_ID
		,L_CHILD_ID
		,P_MSG_CODE
		,FND_GLOBAL.USER_ID
		,SYSDATE
		,FND_GLOBAL.USER_ID
		,SYSDATE
        ,FND_GLOBAL.LOGIN_ID
		)
	RETURNING STRUCTURE_ID INTO L_STRUCTURE_ID;

        IF P_MSG_TYPE = 'TIMER' THEN

                 -- Inserting Delay into Elements

--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

		INSERT INTO XNP_MSG_ELEMENTS(
			MSG_ELEMENT_ID
			,MSG_CODE
			,NAME
			,ELEMENT_DATATYPE
			,ELEMENT_DEFAULT_VALUE
			,MANDATORY_FLAG
			,PARAMETER_FLAG
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
			)
		VALUES(
			XNP_MSG_ELEMENTS_S.NEXTVAL
			,P_MSG_CODE
			,'DELAY'
			,'NUMBER'
			,'0'
			,'Y'
			,'N'
			,FND_GLOBAL.USER_ID
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,SYSDATE
                        ,FND_GLOBAL.LOGIN_ID
			)
		RETURNING MSG_ELEMENT_ID INTO L_GRANDCHILD_ID;

                -- Inserting Delay into Structures with Message Name as parent
--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

		INSERT INTO XNP_MSG_STRUCTURES(
                         STRUCTURE_ID
			,PARENT_ELEMENT_ID
			,CHILD_ELEMENT_ID
			,MSG_CODE
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
			)
		VALUES(
			XNP_MSG_STRUCTURES_S.NEXTVAL
			,L_CHILD_ID
			,L_GRANDCHILD_ID
			,P_MSG_CODE
			,FND_GLOBAL.USER_ID
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,SYSDATE
                        ,FND_GLOBAL.LOGIN_ID
			)
		RETURNING STRUCTURE_ID INTO L_STRUCTURE_ID;

                -- Inserting Interval into Elements

--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

		INSERT INTO XNP_MSG_ELEMENTS(
			MSG_ELEMENT_ID
			,MSG_CODE
			,NAME
			,ELEMENT_DATATYPE
			,ELEMENT_DEFAULT_VALUE
			,MANDATORY_FLAG
			,PARAMETER_FLAG
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
			)
		VALUES(
			XNP_MSG_ELEMENTS_S.NEXTVAL
			,P_MSG_CODE
			,'INTERVAL'
			,'NUMBER'
			,'0'
			,'Y'
			,'N'
			,FND_GLOBAL.USER_ID
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,SYSDATE
            ,FND_GLOBAL.LOGIN_ID
			)
		RETURNING MSG_ELEMENT_ID INTO L_GRANDCHILD_ID;

          -- Inserting Interval into Structures with Message Name as parent
--	adabholk 03/2001
--	performance changes
--	Use of RETURNING

		INSERT INTO XNP_MSG_STRUCTURES(
            STRUCTURE_ID
			,PARENT_ELEMENT_ID
			,CHILD_ELEMENT_ID
			,MSG_CODE
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
			)
		VALUES(
			XNP_MSG_STRUCTURES_S.NEXTVAL
			,L_CHILD_ID
			,L_GRANDCHILD_ID
			,P_MSG_CODE
			,FND_GLOBAL.USER_ID
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,SYSDATE
            ,FND_GLOBAL.LOGIN_ID
			)
		RETURNING STRUCTURE_ID INTO L_STRUCTURE_ID;

	END IF; -- IF TIMER

END xnp_mte_insert_element ;

/*************************************************************************
  PROCEDURE : FIX()
  PURPOSE : Re-enqueues a message on the Inbound Message queue for processing
            by the Message Server. FIX() can only be used for Inbound Messages.
            It also updates the status to ready and clears any error message.
**************************************************************************/

PROCEDURE fix (
	P_MSG_ID IN NUMBER
)
IS
l_msg_header XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
l_msg_text	VARCHAR2(32767) ;

	l_message            SYSTEM.XNP_MESSAGE_TYPE ;
	l_msg_id             XNP_MSGS.MSG_ID%TYPE ;
	my_enqueue_options   dbms_aq.enqueue_options_t ;
	message_properties   dbms_aq.message_properties_t ;
	message_handle       RAW(16) ;


	l_feedback           VARCHAR2(4000) := NULL ;

BEGIN

  select msg_code into l_msg_header.message_code from xnp_msgs where msg_id = p_msg_id;

	UPDATE xnp_msgs SET msg_status = 'READY',
        last_update_date = SYSDATE,
	description = NULL
	WHERE msg_id = p_msg_id ;

	message_properties.priority := 3 ;
--  changed for specialization support adabholk 07/2001
--	message_properties.correlation := 'MSG_SERVER' ;
	message_properties.correlation := l_msg_header.message_code;
	my_enqueue_options.visibility := DBMS_AQ.ON_COMMIT ;

	l_message := SYSTEM.xnp_message_type(p_msg_id) ;

	DBMS_AQ.ENQUEUE (
			queue_name => XNP_EVENT.C_INBOUND_MSG_Q ,
			enqueue_options => my_enqueue_options,
			message_properties => message_properties,
			payload => l_message,
			msgid => message_handle ) ;

	COMMIT ;


-- Now this is not supported from HTML so commented out.

--	FND_MESSAGE.set_name ('XNP', 'MSG_FIX_FEEDBACK') ;
--	l_feedback := FND_MESSAGE.get ;
--
--	htp.htmlopen;
--	htp.bodyopen;
--	htp.p(l_feedback) ;
--	htp.bodyclose;
--	htp.htmlclose;

END fix ;

/*************************************************************************
  PROCEDURE : populate_xnp_msgs()
  PURPOSE : Decodes the header fields in the newly arrived XML message
            and populates the columns in XNP_MSGS table
**************************************************************************/

PROCEDURE decode_xnp_msgs (
	p_msg_header IN OUT NOCOPY xnp_message.msg_header_rec_type,
	p_body_text  IN VARCHAR2
) IS
	l_creation_date     VARCHAR2(512) ;
	l_header     VARCHAR2(4000) ;

BEGIN

-- adabholk 03/2001
-- performance fix
-- First get the header and then decode the header
-- to get the other fields.

	xnp_xml_utils.decode (p_body_text, 'HEADER', l_header) ;

	xnp_xml_utils.decode (l_header, 'OPP_REFERENCE_ID',
		p_msg_header.reference_id) ;

-- get their reference ID for tracking and accounting

	xnp_xml_utils.decode (l_header, 'REFERENCE_ID',
		p_msg_header.opp_reference_id) ;

	xnp_xml_utils.decode (l_header, 'MESSAGE_CODE',
		p_msg_header.message_code) ;

	xnp_xml_utils.decode (l_header, 'VERSION',
		p_msg_header.version ) ;

	xnp_xml_utils.decode (l_header, 'CREATION_DATE',
		l_creation_date) ;

	p_msg_header.creation_date := xnp_utils.canonical_to_date(
		l_creation_date) ;

	xnp_xml_utils.decode (l_header, 'SENDER_NAME',
		p_msg_header.sender_name) ;

	xnp_xml_utils.decode (l_header, 'RECIPIENT_NAME',
		p_msg_header.recipient_name) ;

END decode_xnp_msgs ;


/***************************************************************************
*****  Procedure:    NOTIFY_FMC()
*****  Purpose:      Notifies the FMC of Message Processing Failure.
*****  Description:  Starts a Workflow to notify the FMC. The FMC waits
*****                for a
*****                response from an FMC user.
****************************************************************************/

PROCEDURE notify_fmc(
	P_MSG_ID IN NUMBER
	,P_ERROR_DESC IN VARCHAR2
)
IS
l_item_type VARCHAR2(1024) ;
l_item_key  VARCHAR2(4000) ;
l_performer VARCHAR2(1024) ;
l_role_name VARCHAR2(1024) ;
l_msg_id    NUMBER ;

	CURSOR get_performer_name IS
		SELECT NVL(xms.role_name,'FND_RESP535:21704')
		FROM xnp_msg_types_b xms, xnp_msgs xmg
		WHERE xmg.msg_id = p_msg_id
		AND xms.msg_code = xmg.msg_code;

BEGIN


-- The Performer Name for the Message is already in the correct format
-- To send the notification. Thus the translation from Responsibility_key
-- to performer is not required.

	OPEN get_performer_name ;
	FETCH get_performer_name INTO l_performer ;
	CLOSE get_performer_name ;

	-- Notification performer is defaulted to 'NP_SYSADMIN'
	-- Bug 1658346
	-- Changed this to FND_RESP534:21689
        -- Changed notification performer to FND_RESP535:21704 (OP_SYSADMIN) rnyberg 03/08/02
	IF l_performer IS NULL OR l_performer IN ('NP_SYSADMIN','OP_SYSADMIN') THEN
		l_performer := 'FND_RESP535:21704';
	END IF;

--	l_performer := xdp_utilities.get_wf_notifrecipient(l_role_name) ;

	l_item_type := 'XDPWFSTD' ;

	xnp_message.get_sequence(l_msg_id) ;

	l_item_key := 'MESSAGE_' || TO_CHAR(p_msg_id) ||
		TO_CHAR(l_msg_id) ;

	wf_core.context('XDP_WF_STANDARD',
		'MSG_FAILURE_NOTIFICATION',
		l_item_type,
		l_item_key) ;

	wf_engine.createprocess(l_item_type,
		l_item_key,
		'MSG_FAILURE_NOTIFICATION') ;

	wf_engine.SetItemAttrNumber(
		ItemType=>l_item_type,
		itemkey=>l_item_key,
		aname=>'MSG_ID',
		avalue=>p_msg_id);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'MSG_ERROR',
		avalue=>p_error_desc);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'MSG_HANDLING_ROLE',
		avalue=>l_performer);

	wf_engine.startprocess(l_item_type,
		l_item_key ) ;

END notify_fmc ;

/*******************************************************************/

PROCEDURE push(
	P_QNAME IN VARCHAR2
	,P_MSG_TEXT IN VARCHAR2
	,P_FE_NAME IN VARCHAR2
	,P_ADAPTER_NAME IN VARCHAR2
	,X_ERROR_CODE OUT NOCOPY NUMBER
	,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
	,P_COMMIT_MODE IN NUMBER DEFAULT C_IMMEDIATE)
IS
       l_msg_id NUMBER;
BEGIN
       push(p_qname,
	p_msg_text,
	p_fe_name,
	p_adapter_name,
	l_msg_id,
	x_error_code,
	x_error_message,
	p_commit_mode);
END push;
--
-- This push is identical to the original push for an adapter, but returns message id to the caller
--
PROCEDURE push(
        P_QNAME IN VARCHAR2
        ,P_MSG_TEXT IN VARCHAR2
        ,P_FE_NAME IN VARCHAR2
        ,P_ADAPTER_NAME IN VARCHAR2
	,X_MSG_ID OUT NOCOPY NUMBER
        ,X_ERROR_CODE OUT NOCOPY NUMBER
        ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
	,P_COMMIT_MODE IN NUMBER DEFAULT C_IMMEDIATE)
IS
        l_msg_header MSG_HEADER_REC_TYPE ;
        l_queue_name VARCHAR2(1024) ;
        l_status   VARCHAR2(1024) ;
        l_industry VARCHAR2(1024) ;
        l_ret      BOOLEAN ;
BEGIN
        x_error_code := 0 ;
        x_error_message := 'NO_ERRORS' ;

        l_queue_name := g_xnp_schema || '.' || p_qname ;

        xnp_xml_utils.decode(p_msg_text, 'MESSAGE_CODE',
                l_msg_header.message_code) ;

        IF (l_msg_header.message_code IS NULL) THEN
                x_error_code := xnp_errors.g_invalid_msg_code ;
                x_error_message := 'Message Code or Name Required' ;
                return ;
        END IF ;

        xnp_message.get_sequence(l_msg_header.message_id) ;
                l_msg_header.direction_indr := 'I' ;
        xnp_xml_utils.decode(p_msg_text, 'REFERENCE_ID',
                l_msg_header.reference_id) ;
        xnp_xml_utils.decode(p_msg_text, 'OPP_REFERENCE_ID',
                l_msg_header.opp_reference_id) ;
        l_msg_header.creation_date := SYSDATE ;
        xnp_xml_utils.decode(p_msg_text, 'SENDER_NAME',
                l_msg_header.sender_name) ;
        xnp_xml_utils.decode(p_msg_text, 'RECIPIENT_NAME',
                l_msg_header.recipient_name) ;
        xnp_xml_utils.decode(p_msg_text, 'VERSION',
                l_msg_header.version) ;

        x_msg_id := l_msg_header.message_id;

        push( p_msg_header => l_msg_header,
                p_body_text => p_msg_text,
                p_queue_name => l_queue_name,
                p_correlation_id => l_msg_header.message_code,
                p_priority => 1,
                p_commit_mode => p_commit_mode,
                p_fe_name => p_fe_name,
                p_adapter_name => p_adapter_name) ;
        EXCEPTION
                WHEN OTHERS THEN
                        x_error_code := SQLCODE ;
                        x_error_message := SQLERRM ;

END push;

/**************************************************************************
****
****
**************************************************************************/

PROCEDURE pop(
	p_queue_name VARCHAR2
	,p_consumer_name VARCHAR2
	,x_msg_text OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_msg OUT NOCOPY VARCHAR2
	,p_timeout IN NUMBER DEFAULT 1)
IS

	l_msg_header MSG_HEADER_REC_TYPE ;
	l_queue_name VARCHAR2(1024) ;
	l_status   VARCHAR2(1024) ;
	l_industry VARCHAR2(1024) ;
	l_ret      BOOLEAN ;

BEGIN

	x_error_code := 0;
	x_error_msg := 'NO_ERRORS' ;

	POP_TIMEOUT := p_timeout;

/*
adabholk 03/2001
moved to initialization block to set g_xnp_schema

	IF (g_schema_set = 0) THEN

		l_ret := FND_INSTALLATION.GET_APP_INFO(
			application_short_name=>'XNP'
			,status=>l_status
			,industry=>l_industry
			,oracle_schema=>g_schema
			);

		g_schema_set := 1 ;

	END IF;
*/

	l_queue_name := g_xnp_schema || '.' || p_queue_name ;

	pop(p_queue_name=>l_queue_name,
		x_msg_header=>l_msg_header,
		x_body_text=>x_msg_text,
		x_error_code=>x_error_code,
		x_error_message=>x_error_msg,
		p_consumer_name=>p_consumer_name ) ;

END pop ;

/**************************************************************************
****
****
**************************************************************************/

PROCEDURE delete (
	p_msg_code IN VARCHAR2
)
IS
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000) := NULL;
BEGIN

	BEGIN

		check_run_time_data(p_msg_code,
			l_error_code,
			l_error_message);

		IF (l_error_code <> 0) THEN
	            fnd_message.set_name('XNP','XNP_RUNTIME_DATA_EXISTS');
                    app_exception.raise_exception;
		END IF;

		DELETE FROM xnp_msg_structures
		WHERE msg_code = p_msg_code;

		DELETE FROM xnp_msg_elements
		WHERE MSG_CODE = p_msg_code;

		DELETE FROM xnp_msg_acks
		WHERE source_msg_code = p_msg_code
		OR ack_msg_code = p_msg_code;

		DELETE FROM xnp_timer_publishers
		WHERE timer_message_code = p_msg_code
		OR source_message_code = p_msg_code;

                DELETE FROM xnp_event_subscribers
		WHERE msg_code = p_msg_code;

                BEGIN
		        xnp_msg_types_pkg.delete_row(p_msg_code) ;
	        	drop_packages(p_msg_code,
	                		l_error_code,
		                	l_error_message);

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
	END ;


END delete;

/**************************************************************************
****
****
**************************************************************************/

PROCEDURE check_run_time_data(
	p_msg_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	l_count NUMBER ;

BEGIN


-- adabholk 03/2001
-- performance
-- completely re-written to avoid full table scans due to aggregate functions
--
-- rnyberg 04/10/2001
-- added NO_DATA_FOUND handling to fix bug 2026233 CANNOT DELETE A MESSAGE
--

     BEGIN
	l_count := 0;
	SELECT  1
	INTO	l_count
	FROM	DUAL
	WHERE	EXISTS
		(SELECT	1
		FROM	XNP_CALLBACK_EVENTS
		WHERE	msg_code = p_msg_code);

	x_error_code := xnp_errors.g_run_time_data_exists ;
	FND_MESSAGE.set_name ('XNP', 'XNP_RUNTIME_DATA_EXISTS') ;
	x_error_message := FND_MESSAGE.get ;
	RETURN ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
     END;

     BEGIN
	l_count := 0;

	SELECT  1
	INTO	l_count
	FROM	DUAL
	WHERE	EXISTS
		(SELECT	1
		FROM XNP_MSGS
		WHERE msg_code=p_msg_code);

	x_error_code := xnp_errors.g_run_time_data_exists ;
	FND_MESSAGE.set_name ('XNP', 'XNP_RUN_TIME_DATA_EXISTS') ;
	x_error_message := FND_MESSAGE.get ;
	RETURN ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
     END;

     BEGIN
	l_count := 0;
	SELECT  1
	INTO	l_count
	FROM	DUAL
	WHERE	EXISTS
		(SELECT	1
		FROM XNP_TIMER_REGISTRY
		WHERE p_msg_code=timer_message_code);

	x_error_code := xnp_errors.g_run_time_data_exists ;
	FND_MESSAGE.set_name ('XNP', 'XNP_RUN_TIME_DATA_EXISTS') ;
	x_error_message := FND_MESSAGE.get ;
	RETURN ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
     END;
     x_error_code := 0;
/*
	l_count := 0;

	SELECT count(*) INTO l_count
	FROM XNP_CALLBACK_EVENTS
	WHERE msg_code=p_msg_code;

	IF (l_count <> 0) THEN
		x_error_code := xnp_errors.g_run_time_data_exists ;
		FND_MESSAGE.set_name ('XNP', 'XNP_RUNTIME_DATA_EXISTS') ;
		x_error_message := FND_MESSAGE.get ;
		RETURN ;
	END IF;

	SELECT count(*) INTO l_count
	FROM XNP_MSGS
	WHERE msg_code=p_msg_code;

	IF (l_count <> 0) THEN
		x_error_code := xnp_errors.g_run_time_data_exists ;
		FND_MESSAGE.set_name ('XNP', 'XNP_RUN_TIME_DATA_EXISTS') ;
		x_error_message := FND_MESSAGE.get ;
		RETURN ;
	END IF;

	SELECT count(*) INTO l_count
	FROM XNP_TIMER_REGISTRY
	WHERE p_msg_code=timer_message_code;

	IF (l_count <> 0) THEN
		x_error_code := xnp_errors.g_run_time_data_exists ;
		FND_MESSAGE.set_name ('XNP', 'RUN_TIME_DATA_EXISTS') ;
		x_error_message := FND_MESSAGE.get ;
		RETURN ;
	END IF;
*/

END check_run_time_data ;

/**************************************************************************
****
****
**************************************************************************/

PROCEDURE drop_packages(
	p_msg_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	l_sql_text VARCHAR2(16000) ;
	l_schema   VARCHAR2(1024) ;
	l_status   VARCHAR2(1024) ;
	l_industry VARCHAR2(1024) ;
	l_ret      BOOLEAN ;


BEGIN


/*
adabholk 03/2001
moved to initialization block to set g_fnd_schema

	l_ret := FND_INSTALLATION.GET_APP_INFO(
			application_short_name=>'FND'
			,status=>l_status
			,industry=>l_industry
			,oracle_schema=>l_schema
		);
*/

	l_sql_text := 'DROP PACKAGE ' || g_pkg_prefix ||
		p_msg_code || g_pkg_suffix ;

    -- 04/10/2001. rnyberg added exception to handle that package might
    --             not exist to fix bug 2026233
    DECLARE
        e_object_does_not_exist EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_object_does_not_exist, -4043);
    BEGIN
	AD_DDL.DO_DDL(
		applsys_schema=>g_fnd_schema
		,application_short_name=>'XNP'
		,statement_type=>ad_ddl.drop_package
		,statement=>l_sql_text
		,object_name=>g_pkg_prefix ||p_msg_code|| g_pkg_suffix
	);
    EXCEPTION
       WHEN e_object_does_not_exist THEN
          NULL;
    END;




END drop_packages ;


/***************************************************************************
*****  Procedure:    PUSH_CLOB()
*****  Purpose:      Enqueues the message and message body  on a specified Queue .
****************************************************************************/

PROCEDURE PUSH_WF(
	 p_msg_header      IN msg_header_rec_type ,
         p_body_text       IN VARCHAR2 ,
         p_queue_name      IN VARCHAR2 ,
         p_correlation_id  IN VARCHAR2 DEFAULT NULL ,
         p_priority        IN INTEGER DEFAULT 1 ,
         p_commit_mode     IN NUMBER DEFAULT c_on_commit ,
         p_delay           IN NUMBER DEFAULT DBMS_AQ.NO_DELAY ) IS

	l_event              WF_EVENT_T ;
        l_event_key          VARCHAR2(30) := '1';
	my_enqueue_options   dbms_aq.enqueue_options_t ;
	message_properties   dbms_aq.message_properties_t ;
	message_handle       RAW(16) ;
	recipients           dbms_aq.aq$_recipient_list_t ;

	l_recipient_name     VARCHAR2(80) ;
	l_recipient_count    INTEGER ;

	l_lob_loc	     CLOB ;
	l_correlation_id     VARCHAR2(1024) ;

	l_msg_header 	     xnp_message.msg_header_rec_type ;
        x_error_message      varchar2(4000);
        x_error_code         number;

BEGIN

	l_msg_header     := p_msg_header ;
	l_correlation_id := l_msg_header.message_code ;
        message_properties.priority := p_priority;

	IF ( l_msg_header.message_id IS NULL ) THEN
		XNP_MESSAGE.get_sequence(l_msg_header.message_id) ;
	END IF ;

-- Use the correlation ID if one is specified

	IF ( l_correlation_id is NOT NULL ) THEN
		message_properties.correlation := l_correlation_id ;
	END IF ;

	IF (p_commit_mode = C_IMMEDIATE) THEN
		my_enqueue_options.visibility := DBMS_AQ.IMMEDIATE ;
	ELSE
		my_enqueue_options.visibility := DBMS_AQ.ON_COMMIT ;
	END IF ;

        XDP_UTILITIES.WRITE_TABLE_TO_CLOB(p_source_table      => xdp_utilities.g_message_list,
                                          p_dest_clob         => xdp_utilities.g_clob,
                                          x_error_code        => x_error_code ,
                                          x_error_description => x_error_message );
        XNP_XML_UTILS.INITIALIZE_DOC;

        WF_EVENT_T.INITIALIZE(l_event);

        l_event.PRIORITY := p_priority;
        l_event.SEND_DATE := sysdate ;
        l_event.CORRELATION_ID := l_correlation_id ;
        l_event.EVENT_NAME     := l_msg_header.message_code;
        l_event.EVENT_KEY      := l_event_key ;
        l_event.EVENT_DATA     := xdp_utilities.g_clob ;

	DBMS_AQ.ENQUEUE (
		queue_name         => p_queue_name ,
		enqueue_options    => my_enqueue_options,
		message_properties => message_properties,
		payload            => l_event,
		msgid              => message_handle ) ;

        DBMS_LOB.FREETEMPORARY(XDP_UTILITIES.G_CLOB);

END PUSH_WF;
--Package initialization code

BEGIN

DECLARE
	l_pop_timeout VARCHAR2(40) := NULL;
	l_ret BOOLEAN;
	l_status   VARCHAR2(1024) ;
	l_industry VARCHAR2(1024) ;
BEGIN
	FND_PROFILE.GET( NAME => 'POP_TIMEOUT',
		VAL => l_pop_timeout ) ;
	IF (l_pop_timeout IS NULL) THEN
		POP_TIMEOUT := 5 ;
	ELSE
		POP_TIMEOUT := TO_NUMBER(l_pop_timeout) ;
	END IF ;

	l_ret := FND_INSTALLATION.GET_APP_INFO(
			application_short_name=>'FND'
			,status=>l_status
			,industry=>l_industry
			,oracle_schema=>g_fnd_schema
		);
	l_ret := FND_INSTALLATION.GET_APP_INFO(
			application_short_name=>'XNP'
			,status=>l_status
			,industry=>l_industry
			,oracle_schema=>g_xnp_schema
		);
END ;

    -- Get APPS_MAINTENANCE_MODE parameter for High Availability
    FND_PROFILE.GET('APPS_MAINTENANCE_MODE', g_APPS_MAINTENANCE_MODE);

    IF(g_APPS_MAINTENANCE_MODE = 'MAINT') THEN
    /**** Set Log and Output File Names and Directory  ****/

        SELECT nvl(substr(value,1,instr(value,',')-1),value)
          INTO g_logdir
        FROM v$parameter
        WHERE name = 'utl_file_dir';

        select sysdate into g_logdate from dual;

        fnd_file.put_names('XNPMSGPB'||to_char(g_logdate, 'YYYYMMDDHHMISS')||'.log',
                           'XNPMSGPB'||to_char(g_logdate, 'YYYYMMDDHHMISS')||'.out',
                           g_logdir);
    END IF;

END xnp_message;


/
