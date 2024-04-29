--------------------------------------------------------
--  DDL for Package Body XNP_TIMER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMER_CORE" AS
/* $Header: XNPTBLPB.pls 120.1 2005/06/17 03:55:24 appldev  $ */

-----------------------------------------------------------------------------
---- Name : Remove_Timer_From_AQ
---- Purpose : Remove timer from AQ
-----------------------------------------------------------------------------
PROCEDURE remove_timer_from_aq(
	p_timer_id	IN NUMBER,
	x_error_code	OUT NOCOPY	NUMBER,
	x_error_message	OUT NOCOPY VARCHAR2
	) ;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Recalculate
---- Purpose : Recalculate the delay and interval for the timer
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE recalculate(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	)
IS
	CURSOR c_timer_data IS
	SELECT timer_id, timer_message_code,
		next_timer,start_time
	FROM xnp_timer_registry
	WHERE reference_id = p_reference_id
	AND	(timer_message_code = p_timer_message_code
		 OR next_timer = p_timer_message_code
		)
	AND status = 'ACTIVE';

	l_timer_id		NUMBER DEFAULT NULL;
	l_next_timer_code	VARCHAR2(80) DEFAULT NULL;
	l_timer_code		VARCHAR2(80) DEFAULT NULL;
	l_status		VARCHAR2(80);
	l_start_time 		DATE;
	l_elapsed_time		NUMBER;
	l_current_time 		DATE := sysdate;
	l_msg_header		XNP_MESSAGE.MSG_HEADER_REC_TYPE;
	l_old_msg_header	XNP_MESSAGE.MSG_HEADER_REC_TYPE;
	l_msg_text		VARCHAR2(32767);
	l_new_interval		NUMBER;
	l_new_delay		NUMBER;
	l_interval_text		VARCHAR2(40);
	l_delay_text		VARCHAR2(40);
	l_interval		NUMBER;
	l_delay			NUMBER;

	l_EXCEPTION	EXCEPTION; -- adabholk 06142000 for error trapping

BEGIN
	-- Retrieve the timer_id
	OPEN c_timer_data;
	FETCH c_timer_data INTO
		l_timer_id,
		l_timer_code,
		l_next_timer_code,
		l_start_time;
        CLOSE c_timer_data;

	IF (l_timer_code <> 'T_DUMMY')
	THEN
		-- Call REMOVE_TIMER

		xnp_timer_core.remove_timer(
			p_timer_id => l_timer_id
			,x_error_code => x_error_code
    		,x_error_message => x_error_message
    		);

		IF x_error_code <> 0 THEN
			raise l_EXCEPTION;
		END IF;


		l_elapsed_time := round((l_current_time - l_start_time)*24*60*60);

		-- Construct timer with new_delay and new_interval

-- adabholk 03/2001
-- performance fix
-- new get() replaces two get calls

		xnp_message.get(
			p_msg_id => l_timer_id
			,x_msg_header => l_old_msg_header
			,x_msg_text => l_msg_text);
/*
--		xnp_message.get_header(
--			p_msg_id => l_timer_id
--			,x_msg_header => l_old_msg_header);
--
--		xnp_message.get(
--			p_msg_id => l_timer_id
--			,x_msg_text => l_msg_text);
*/
		-- Recalculate delay and interval

		xnp_xml_utils.decode(
			p_msg_text => l_msg_text
			,p_tag => 'DELAY'
			,x_value => l_delay_text
			);

		IF ( l_delay <> 0 )
		THEN
			l_delay := TO_NUMBER(l_delay_text);
			l_new_delay := l_delay - l_elapsed_time;
		ELSE
			l_new_delay := 0;
		END IF;


		xnp_xml_utils.decode(
			p_msg_text => l_msg_text
			,p_tag => 'INTERVAL'
			,x_value => l_interval_text
		);

		l_interval := TO_NUMBER(l_interval_text);
	   	l_new_interval := l_interval - l_elapsed_time;

		-- Reconstruct the message
		xnp_timer_mgr.construct_dynamic_message(
			p_msg_to_create => l_old_msg_header.message_code
			,p_old_msg_header => l_old_msg_header
			,p_delay => l_new_delay
			,p_interval => l_new_interval
			,x_new_msg_header => l_msg_header
			,x_new_msg_text => l_msg_text
			,x_error_code => x_error_code
			,x_error_message => x_error_message
			);


		IF x_error_code <> 0 THEN
			raise l_EXCEPTION;
		END IF;


		xnp_timer.start_timer(
			p_msg_header => l_msg_header
			,p_msg_text => l_msg_text
			,x_error_code => x_error_code
			,x_error_message =>	x_error_message
		);

		IF x_error_code <> 0 THEN
			raise l_EXCEPTION;
		END IF;

	-- Search for next_timer in registry

	ELSIF l_timer_code = 'T_DUMMY'

	THEN
			xnp_timer_core.remove_timer(
				p_timer_id => l_timer_id
				,x_error_code => x_error_code
    			        ,x_error_message => x_error_message
				);

			IF x_error_code <> 0 THEN
				raise l_EXCEPTION;
			END IF;

			-- Recalculate elapsed time

			l_elapsed_time := round((l_current_time - l_start_time)*24*60*60);

			-- Recalculate delay and interval

			xnp_message.get(
				p_msg_id => l_timer_id
				,x_msg_text => l_msg_text);

			xnp_xml_utils.decode(
				p_msg_text => l_msg_text
				,p_tag => 'DELAY'
				,x_value => l_delay_text
				);

			l_delay := TO_NUMBER(l_delay_text);

			l_new_delay := l_delay - l_elapsed_time;

			-- Construct timer with new_delay and interval

			xnp_message.get_header(
					p_msg_id => l_timer_id
					,x_msg_header => l_old_msg_header);

			xnp_timer_mgr.construct_dynamic_message(
					p_msg_to_create => l_next_timer_code
					,p_old_msg_header => l_old_msg_header
					,p_delay => l_new_delay
				    	,x_new_msg_header => l_msg_header
					,x_new_msg_text => l_msg_text
					,x_error_code => x_error_code
					,x_error_message => x_error_message
			);

			IF x_error_code <> 0 THEN
				raise l_EXCEPTION;
			END IF;


			xnp_timer.start_timer(
				p_msg_header => l_msg_header
				,p_msg_text => l_msg_text
				,x_error_code => x_error_code
				,x_error_message => x_error_message
			);

			IF x_error_code <> 0 THEN
				raise l_EXCEPTION;
			END IF;

	ELSE
		x_error_code := XNP_ERRORS.G_TIMER_NOT_FOUND;

	END IF;

EXCEPTION
	WHEN others THEN
		null; -- Just pass the x_error_code and x_error_message
			  -- to the calling procedure
END recalculate;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Recalculate_All
---- Purpose : Recalculate the delay and interval given the ref. id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

PROCEDURE recalculate_all
(
    p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
)
IS

CURSOR c_recalculate_all_timers IS
	SELECT timer_message_code
	FROM xnp_timer_registry
	WHERE reference_id = p_reference_id
	AND status = 'ACTIVE' ;


l_timer_message_code	VARCHAR2(20);
l_error_code 			NUMBER;
l_error_message 		VARCHAR2(80);

BEGIN

FOR rec IN c_recalculate_all_timers LOOP

	xnp_timer_core.recalculate(
		p_reference_id => p_reference_id
	        ,p_timer_message_code => rec.timer_message_code
		,x_error_code => l_error_code
		,x_error_message => l_error_message);
END LOOP;

END recalculate_all;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Get_Timer_Status
---- Purpose : Get the status given the timerId
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE get_timer_status(
	p_timer_id  IN NUMBER
	,x_status OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)

IS
	CURSOR c_timer_status IS
		SELECT status
		FROM xnp_timer_registry
		WHERE timer_id = p_timer_id;

BEGIN

	OPEN c_timer_status;
	FETCH c_timer_status into x_status;
	IF c_timer_status%NOTFOUND
	THEN
		x_error_code := XNP_ERRORS.G_TIMER_NOT_FOUND;
	END IF;
	CLOSE c_timer_status;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;

	IF c_timer_status%ISOPEN
	THEN
		CLOSE c_timer_status;
	END IF;

END get_timer_status;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Get_Timer_Status
---- Purpose : Get the status given the reference id and timer name
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

PROCEDURE get_timer_status
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_timer_id	OUT NOCOPY NUMBER
	,x_status	OUT NOCOPY	VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
 )
IS

-- Fixed as part of Bug 1351421
-- Logic changed for performance.
-- The timer status will be returned ordered by
--     status asc (ACTIVE, EXPIRED, REMOVED)
-- Only the first record will be processed.

	CURSOR c_timer_status IS
		SELECT timer_id, status FROM xnp_timer_registry
		WHERE reference_id = p_reference_id
		AND	timer_message_code = p_timer_message_code
		ORDER BY status ASC;

BEGIN
	x_error_code := 0;
	x_error_message := NULL;

	OPEN c_timer_status;
	FETCH c_timer_status into x_timer_id, x_status;
	IF c_timer_status%NOTFOUND
	THEN
		X_ERROR_CODE := xnp_errors.g_timer_not_found;
		fnd_message.set_name('XNP', 'TIMER_NOT_FOUND');
		fnd_message.set_token('REFERENCE_ID',p_reference_id);
		fnd_message.set_token('MESSAGE_CODE',p_timer_message_code);
		x_error_message := fnd_message.get;
	END IF;
	CLOSE c_timer_status;
	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;

	IF c_timer_status%ISOPEN
	THEN
		CLOSE c_timer_status;
	END IF;

END get_timer_status;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Update_Timer_Status
---- Purpose : Update the status given the reference id and timer name
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE update_timer_status
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,p_status IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

-- Fixed as part of Bug 1351421
-- Logic changed for performance.
-- The timer status will be returned ordered by
--     status asc (ACTIVE, EXPIRED, REMOVED)
-- Only the first record will be processed.

	CURSOR c_update_timer_status IS
	SELECT *
	FROM xnp_timer_registry
	WHERE reference_id = p_reference_id
	AND timer_message_code = p_timer_message_code
	ORDER BY status ASC
	FOR UPDATE OF status;

	v_Timer_Registry	xnp_timer_registry%ROWTYPE;
BEGIN
	x_error_code := 0;
	x_error_message := NULL ;

	OPEN c_update_timer_status;
	FETCH c_update_timer_status INTO v_Timer_Registry;
	IF c_update_timer_status%NOTFOUND THEN
		x_error_code := xnp_errors.g_timer_not_found;
	ELSE
		UPDATE xnp_timer_registry
		SET status = p_status
		WHERE CURRENT OF c_update_timer_status;
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_error_code := XNP_ERRORS.G_TIMER_NOT_FOUND;
			CLOSE c_update_timer_status;

END update_timer_status;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Update_Timer_Status
---- Purpose : Update the status given the timer_id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE update_timer_status
(
	p_timer_id	IN NUMBER
	,p_status IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_update_timer_status IS
	SELECT *
	FROM xnp_timer_registry
	WHERE timer_id = p_timer_id
	FOR UPDATE OF status;

	v_Timer_Registry	xnp_timer_registry%ROWTYPE;

BEGIN
	x_error_code := 0;
	x_error_message := NULL ;

	OPEN c_update_timer_status;
	FETCH c_update_timer_status INTO v_Timer_Registry;

	IF c_update_timer_status%NOTFOUND THEN
		x_error_code := xnp_errors.g_timer_not_found;
   		fnd_message.set_name ('XNP', 'TIMER_ID_NOT_FOUND') ;
		fnd_message.set_token ('TIMER_ID',p_timer_id) ;
   		x_error_message:= FND_MESSAGE.get ;
	ELSE
		UPDATE xnp_timer_registry
		SET status = p_status
		WHERE CURRENT OF c_update_timer_status;
	END IF;
	CLOSE c_update_timer_status;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;
			IF c_update_timer_status%ISOPEN
			THEN
				close c_update_timer_status;
			END IF;

END update_timer_status;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Remove_Timer
---- Purpose : Remove the timer given the timer_id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE remove_timer
(
	p_timer_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	remove_timer_failed	EXCEPTION ;

BEGIN


	xnp_timer_core.update_timer_status(
		p_timer_id => p_timer_id
		,p_status => 'REMOVED'
		,x_error_code => x_error_code
		,x_error_message => x_error_message
	);
	IF (x_error_code = 0) THEN
		remove_timer_from_aq(p_timer_id => p_timer_id,
				x_error_code => x_error_code,
				x_error_message => x_error_message);
		IF (x_error_code <> 0) THEN
			RAISE remove_timer_failed;
		END IF;
	END IF;


EXCEPTION

	WHEN remove_timer_failed THEN
		fnd_message.set_name ('XNP', 'REMOVE_TIMER_FAILED') ;
		fnd_message.set_token ('TIMER_ID',p_timer_id) ;
   		x_error_message := FND_MESSAGE.get ;

END remove_timer;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Remove_Timer_From_AQ
---- Purpose : Remove the timer from the AQ
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE remove_timer_from_aq(
	p_timer_id	IN NUMBER,
	x_error_code	OUT NOCOPY	NUMBER,
	x_error_message	OUT NOCOPY VARCHAR2
)
IS
	l_message	system.xnp_message_type ;
	l_message_id 	RAW(16) ;
	l_msg_header	xnp_message.msg_header_rec_type;
	l_msg_text	varchar2(32767) ;

BEGIN

	l_message := system.xnp_message_type(p_timer_id) ;

	SELECT msg_id INTO l_message_id
	FROM aq$xnp_in_tmr_qtab
	WHERE user_data = l_message ;

	IF (l_message_id IS NOT NULL) THEN

		xnp_message.pop(p_queue_name => xnp_event.c_timer_q,
			x_msg_header => l_msg_header,
			x_body_text => l_msg_text,
			x_error_code => x_error_code,
			x_error_message => x_error_message,
			p_msg_id => l_message_id );

		IF x_error_code = 0
		THEN
			xnp_message.update_status(p_msg_id=>p_timer_id
						,p_status=>'PROCESSED'
						,p_error_desc=>'Timer Removed') ;
        	END IF;

	END IF ;


EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM ;

END remove_timer_from_aq;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Remove_Timer
---- Purpose : Remove the timer given the ref. id and the timer name
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE remove_timer
 (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

-- Fix for bug 1608343 - rraheja
-- When removing expired timers, the cursor returns nothing and hence crashes
-- Handling case for no data found and gracefully exiting.
-- In case timer is not active, it will remain in its original state and
-- will not be removed as it is the business logic that timer has expired

	CURSOR c_timer_status_id IS
		SELECT timer_id FROM xnp_timer_registry
		WHERE reference_id = p_reference_id
		AND (timer_message_code = p_timer_message_code
		OR next_timer = p_timer_message_code)
		AND status = 'ACTIVE'
		FOR UPDATE OF status ;

	l_status	       VARCHAR2(20);
	l_timer_id	       NUMBER;
	l_error_code	       VARCHAR2(80);
	l_error_message	       VARCHAR2(80);

	ex_timer_not_found	EXCEPTION;

BEGIN
	-- Obtain the latest timer_id and status for the given
	-- Reference_Id and Timer_Message_code
	OPEN c_timer_status_id;
	FETCH c_timer_status_id INTO l_timer_id;
	IF c_timer_status_id%NOTFOUND
	THEN
		RAISE ex_timer_not_found;
	END IF;
	CLOSE c_timer_status_id;

	xnp_timer_core.remove_timer(
		p_timer_id => l_timer_id
		,x_error_code => x_error_code
		,x_error_message => x_error_message
	);
	IF (x_error_code <> 0) THEN
		x_error_code := xnp_errors.g_timer_not_found;
   		fnd_message.set_name ('XNP', 'TIMER_ID_NOT_FOUND') ;
		fnd_message.set_token ('TIMER_ID',l_timer_id) ;
   		x_error_message:= FND_MESSAGE.get ;
	END IF;

EXCEPTION
	WHEN ex_timer_not_found THEN

		x_error_code := 0;
		x_error_message := NULL;
		IF c_timer_status_id%ISOPEN
		THEN
			CLOSE c_timer_status_id;
		END IF;


	WHEN NO_DATA_FOUND THEN
		x_error_code := xnp_errors.g_timer_not_found;
   		fnd_message.set_name ('XNP', 'TIMER_ID_NOT_FOUND') ;
		fnd_message.set_token ('TIMER_ID',l_timer_id) ;
   		x_error_message:= FND_MESSAGE.get ;

		IF c_timer_status_id%ISOPEN
		THEN
			CLOSE c_timer_status_id;
		END IF;

	WHEN OTHERS THEN
		x_error_code := sqlcode;
		x_error_message := sqlerrm;
		IF c_timer_status_id%ISOPEN
		THEN
			CLOSE c_timer_status_id;
		END IF;

END remove_timer;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Deregister
---- Purpose : Remove all timers for the give order_id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE deregister
(
	p_order_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_deregister_timers IS
		SELECT timer_id FROM xnp_timer_registry
			 WHERE order_id = p_order_id
			 AND status = 'ACTIVE';

	l_error_code	NUMBER;
	l_error_message	VARCHAR2(80);

BEGIN
	l_error_code := 0;
	l_error_message := NULL;

	FOR rec IN c_deregister_timers LOOP
		xnp_timer_core.remove_timer (
			p_timer_id => rec.timer_id
	        	,x_error_code => l_error_code
       		 	,x_error_message => l_error_message
     		);
	IF (x_error_code <> 0) THEN
		x_error_code := xnp_errors.g_timer_not_found;
		x_error_message := 'Timer Id : ' || rec.timer_id || '-' || l_error_message;
	END IF;

	END LOOP;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		x_error_code := xnp_errors.g_timer_not_found;

	WHEN OTHERS THEN
		x_error_code := sqlcode;
		x_error_message := sqlerrm;

END deregister;

-----------------------------------------------------------------------------
---- Name : Deregister_for_workitem
---- Purpose : Remove all timers for the give Workitem Instance ID
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE deregister_for_workitem
(
	p_workitem_instance_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_deregister_timers IS
		SELECT timer_id FROM xnp_timer_registry
			 WHERE wi_instance_id = p_workitem_instance_id
			 AND status = 'ACTIVE';

	l_error_code	NUMBER;
	l_error_message	VARCHAR2(80);

BEGIN
	l_error_code := 0;
	l_error_message := NULL;

	FOR rec IN c_deregister_timers LOOP
		xnp_timer_core.remove_timer (
			p_timer_id => rec.timer_id
	        	,x_error_code => l_error_code
       		 	,x_error_message => l_error_message
     		);
	IF (x_error_code <> 0) THEN
		x_error_code := xnp_errors.g_timer_not_found;
		x_error_message := 'Timer Id : ' || rec.timer_id || '-' || l_error_message;
	END IF;

	END LOOP;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		x_error_code := xnp_errors.g_timer_not_found;

	WHEN OTHERS THEN
		x_error_code := sqlcode;
		x_error_message := sqlerrm;

END deregister_for_workitem;


-----------------------------------------------------------------------------
---- Name : get_next_timer
---- Purpose : Get the value for the next timer from the registry
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
FUNCTION get_next_timer(p_timer_id NUMBER)
	RETURN VARCHAR2
IS
	l_next_timer VARCHAR2(80) ;

CURSOR  c_next_timer IS
	SELECT next_timer
	FROM xnp_timer_registry
	WHERE timer_id = p_timer_id ;

BEGIN

        OPEN c_next_timer;
        FETCH c_next_timer INTO l_next_timer;
        CLOSE c_next_timer;

	RETURN l_next_timer ;
END ;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Restart
---- Purpose : Restart the timer given the timer name and ref. id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE restart
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_timer_data IS
	SELECT timer_id, timer_message_code,
			next_timer
	FROM xnp_timer_registry
	WHERE reference_id = p_reference_id
	AND	(timer_message_code = p_timer_message_code
		 OR next_timer = p_timer_message_code
		)
	AND status = 'ACTIVE';

	l_timer_id	NUMBER DEFAULT NULL;
	l_next_timer_code	VARCHAR2(80) DEFAULT NULL;
	l_timer_code	VARCHAR2(80) DEFAULT NULL;
	l_status	VARCHAR2(80);
	l_msg_header	XNP_MESSAGE.MSG_HEADER_REC_TYPE;
	l_old_msg_header	XNP_MESSAGE.MSG_HEADER_REC_TYPE;
	l_msg_text		VARCHAR2(32767);
	l_msg_to_create		VARCHAR2(80);

	l_EXCEPTION	EXCEPTION; -- adabholk 06142000 for error trapping
BEGIN
	/* Retrieve the timer_id */
	OPEN c_timer_data;
	FETCH c_timer_data into l_timer_id,l_timer_code,
		 l_next_timer_code;
	CLOSE c_timer_data;
	IF l_timer_code <> 'T_DUMMY'
	THEN
		l_msg_to_create := l_timer_code;
	ELSE
		l_msg_to_create := l_next_timer_code;
	END IF;

	xnp_timer_core.remove_timer(
		p_timer_id => l_timer_id
		,x_error_code => x_error_code
   		,x_error_message => x_error_message
   	);

	IF x_error_code <> 0 THEN
		raise l_EXCEPTION;
	END IF;

	xnp_message.get_header(
		p_msg_id => l_timer_id
		,x_msg_header => l_old_msg_header);

	-- Reconstruct the message

	xnp_timer_mgr.construct_dynamic_message(
		p_msg_to_create => l_msg_to_create
		,p_old_msg_header => l_old_msg_header
		,x_new_msg_header => l_msg_header
		,x_new_msg_text => l_msg_text
		,x_error_code => x_error_code
		,x_error_message =>	x_error_message
	);

	IF x_error_code <> 0 THEN
		raise l_EXCEPTION;
	END IF;

	xnp_timer.start_timer(
		p_msg_header => l_msg_header
		,p_msg_text => l_msg_text
		,x_error_code => x_error_code
		,x_error_message =>	x_error_message
	);
	IF x_error_code <> 0 THEN
		raise l_EXCEPTION;
	END IF;

EXCEPTION
	WHEN others THEN
		null; -- Just pass the x_error_code and x_error_message
			  -- to the calling procedure
END restart;


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Restart All
---- Purpose : Restart all timers for a given Reference Id
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE restart_all
(
	p_reference_id IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_restart_all_timers IS
		SELECT timer_message_code
		FROM xnp_timer_registry
		WHERE reference_id = p_reference_id
		AND status = 'ACTIVE' ;

	l_timer_message_code	VARCHAR2(20);
	l_error_code 	NUMBER;
	l_error_message	VARCHAR2(80);

BEGIN


	FOR rec IN c_restart_all_timers LOOP
		xnp_timer_core.restart(
			p_reference_id => p_reference_id
		        ,p_timer_message_code => rec.timer_message_code
		        ,x_error_code => l_error_code
		        ,x_error_message => l_error_message
		);
END LOOP;

END restart_all;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---- Name : Start_Related_Timers
---- Purpose : For the given message code, start the related timers
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE start_related_timers
(
	p_message_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_opp_reference_id IN VARCHAR2 DEFAULT NULL
	,p_sender_name IN VARCHAR2 DEFAULT NULL
	,p_recipient_name IN VARCHAR2 DEFAULT NULL
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL

)
IS
	CURSOR c_get_all_timers IS
		SELECT timer_message_code
		FROM xnp_timer_publishers
		WHERE source_message_code = p_message_code ;

	l_old_msg_header  xnp_message.msg_header_rec_type ;
	l_new_msg_header  xnp_message.msg_header_rec_type ;

	l_msg_text VARCHAR2(32767) ;

BEGIN

	x_error_code := 0;
	x_error_message := NULL ;

	l_old_msg_header.reference_id := p_reference_id ;
	l_old_msg_header.opp_reference_id := p_opp_reference_id ;
	l_old_msg_header.sender_name := p_sender_name ;
	l_old_msg_header.recipient_name := p_recipient_name ;
	l_old_msg_header.order_id := p_order_id ;
	l_old_msg_header.wi_instance_id := p_wi_instance_id ;
	l_old_msg_header.fa_instance_id := p_fa_instance_id ;

	FOR rec IN c_get_all_timers LOOP

		xnp_timer_mgr.construct_dynamic_message(
			p_msg_to_create => rec.timer_message_code,
			p_old_msg_header => l_old_msg_header,
			x_new_msg_header => l_new_msg_header,
			x_new_msg_text => l_msg_text,
			x_error_code => x_error_code,
			x_error_message => x_error_message) ;

		IF (x_error_code = 0) THEN

			xnp_timer.start_timer(l_new_msg_header,
				l_msg_text	,
				x_error_code,
				x_error_message);

			IF (x_error_code <> 0) THEN
				EXIT ;
			END IF ;

		ELSE
			EXIT;
		END IF ;

	END LOOP;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM ;

END start_related_timers;

--------------------------------------------------------------------------------
----- API Name    : Get Jeopardy Flag
----- Type        : Private
----- Purpose     : Get jeopardy flag for the given order id
----- Parameters  : p_order_id
-----               x_flag
-----               x_error_code
-----               x_error_message
-----  Changes	 : Changed to refer to xdp_order_headers
-----			   Earlier it was incorrectly refering to xdp_oe_order_headers
-----			   adabholk 03/2001
-----------------------------------------------------------------------------------
PROCEDURE get_jeopardy_flag
(
	p_order_id IN NUMBER
	,x_flag OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_get_jeopardy_flag
	IS
		SELECT jeopardy_enabled_flag
		FROM   xdp_order_headers
		WHERE  order_id = p_order_id;

	l_jeopardy_flag		VARCHAR2(1);

BEGIN

	OPEN c_get_jeopardy_flag;
	FETCH c_get_jeopardy_flag
		INTO l_jeopardy_flag;
	IF c_get_jeopardy_flag%NOTFOUND
	THEN
		x_flag := NULL;
	END IF;
        CLOSE c_get_jeopardy_flag;

		x_flag := l_jeopardy_flag;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := sqlcode;
		x_error_message := sqlerrm;

END get_jeopardy_flag;


--------------------------------------------------------------------------------
----- API Name    : FIRE
----- Type        : Public
----- Purpose     : A Wrapper to the XNP_<Timer Code>_U.FIRE procedure
                    -- VBhatia Created on 05/07/2002
-----------------------------------------------------------------------------------
PROCEDURE FIRE  ( p_timer_code IN VARCHAR2,
                  x_timer_id   OUT NOCOPY  NUMBER,
                  x_timer_contents   OUT NOCOPY  VARCHAR2,
                  x_error_code OUT NOCOPY  NUMBER,
                  x_error_message OUT NOCOPY VARCHAR2,
                  p_sender_name IN VARCHAR2 DEFAULT NULL,
                  p_recipient_list IN VARCHAR2 DEFAULT NULL,
                  p_version IN NUMBER DEFAULT 1,
                  p_reference_id IN VARCHAR2 DEFAULT NULL,
                  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,
                  p_order_id IN NUMBER DEFAULT NULL,
                  p_wi_instance_id  IN NUMBER DEFAULT NULL,
                  p_fa_instance_id  IN NUMBER  DEFAULT NULL )
IS

    l_pkg_name VARCHAR2(200) := NULL;
    l_proc_call VARCHAR2(32767) := NULL;

BEGIN

    l_pkg_name := XNP_MESSAGE.g_pkg_prefix || p_timer_code || XNP_MESSAGE.g_pkg_suffix;
    l_PROC_CALL :=
     'BEGIN
     '||l_pkg_name||'.fire(' ||
       ' :x_timer_id' ||
       ',:x_timer_contents' ||
       ',:x_error_code' ||
       ',:x_error_message' ||
       ',:p_sender_name' ||
       ',:p_recipient_list' ||
       ',:p_version' ||
       ',:p_reference_id' ||
       ',:p_opp_reference_id' ||
       ',:p_order_id' ||
       ',:p_wi_instance_id' ||
       ',:p_fa_instance_id' ||
       ');
     END;';

     BEGIN

         EXECUTE IMMEDIATE l_proc_call USING
                 OUT x_timer_id
                ,OUT x_timer_contents
                ,OUT x_error_code
                ,OUT x_error_message
                ,p_sender_name
                ,p_recipient_list
                ,p_version
                ,p_reference_id
                ,p_opp_reference_id
                ,p_order_id
                ,p_wi_instance_id
                ,p_fa_instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           -- Grab the error message and error no.
           x_error_code := SQLCODE;
           fnd_message.set_name('XNP','STD_ERROR');
           fnd_message.set_token('ERROR_LOCN'
              ,'XNP_TIMER_CORE.FIRE');
           fnd_message.set_token('ERROR_TEXT',SQLERRM);
           x_error_message := fnd_message.get;
    END;

END FIRE;


END xnp_timer_core;

/
