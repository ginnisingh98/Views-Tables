--------------------------------------------------------
--  DDL for Package Body XNP_TIMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMER" AS
/* $Header: XNPTIMRB.pls 120.2 2006/02/13 07:57:10 dputhiye ship $ */

/* forward declarations */
PROCEDURE add_timer (
	p_msg_header IN xnp_message.msg_header_rec_type,
	p_msg_text IN VARCHAR2,
	p_dummy_for IN VARCHAR2 DEFAULT NULL,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2 ) ;

/* end forward declarations */

--------------------------------------------------------------------------
---- PROCEDURE:   start_timer()
---- PURPOSE:     Checks the delay and the interval, if delay is greater
----              than zero, introduces a dummy timer into the system.
----              Otherwise enqueues the actual timer.
--------------------------------------------------------------------------
PROCEDURE start_timer (

	p_msg_header IN xnp_message.msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2

)
IS

	l_delay NUMBER := 0 ;
	l_interval NUMBER  := 0 ;

	l_temp VARCHAR2(1024) ;
	l_msg_header  xnp_message.msg_header_rec_type;
	l_msg_text  VARCHAR2(32767) ;

	l_payload varchar2(32767) ;

BEGIN
	x_error_code := 0;
	x_error_message := NULL;


	xnp_xml_utils.decode(p_msg_text,'DELAY',l_temp) ;
	l_delay := TO_NUMBER(l_temp) ;

	xnp_xml_utils.decode(p_msg_text,'INTERVAL',l_temp) ;
	l_interval := TO_NUMBER(l_temp) ;


	IF (l_delay <= 0) THEN

		add_timer(p_msg_header => p_msg_header,
			p_msg_text => p_msg_text,
			x_error_code => x_error_code,
			x_error_message => x_error_message);
	ELSE
		xnp_xml_utils.decode(p_msg_text,
			p_msg_header.message_code,
			l_payload) ;

		xnp_t_dummy_u.create_msg(x_msg_header => l_msg_header,
			x_msg_text => l_msg_text,
			x_error_code => x_error_code,
			x_error_message => x_error_message,
			p_sender_name => p_msg_header.sender_name,
			p_recipient_list => p_msg_header.recipient_name,
			p_version => p_msg_header.version,
			p_reference_id => p_msg_header.reference_id,
			p_opp_reference_id => p_msg_header.opp_reference_id,
			p_order_id => p_msg_header.order_id,
			p_wi_instance_id => p_msg_header.wi_instance_id,
			p_fa_instance_id => p_msg_header.fa_instance_id,
			p_delay => 0,
			p_interval => l_delay,
			xnp$payload => l_payload);

		IF (x_error_code = 0) THEN

			add_timer(p_msg_header => l_msg_header,
				p_msg_text => l_msg_text,
				p_dummy_for => p_msg_header.message_code,
				x_error_code => x_error_code,
				x_error_message => x_error_message);

		END IF ;

	END IF ;

END start_timer;

---------------------------------------------------------------------
-- Purpose:	Bug # 1351421
--			Get the timer_id for the ACTIVE timer with
-- 			same reference_id and timer_message_code.
--			checks both for DUMMY and the actual timer
--			and wrt both DUMMY and actual timer.
-- Caller:	add_to_registry
----------------------------------------------------------------------

PROCEDURE get_active_timer(
  p_msg_header IN xnp_message.msg_header_rec_type,
  p_dummy_for IN VARCHAR2,
  p_timer_id OUT NOCOPY NUMBER,
  x_error_code OUT NOCOPY NUMBER,
  x_error_message OUT NOCOPY VARCHAR2)
IS
  CURSOR c_timer_reg(p_message_code IN VARCHAR2) IS
    SELECT timer_id,timer_message_code,next_timer
    FROM  xnp_timer_registry
    WHERE
          reference_id=p_msg_header.reference_id
    AND
    (
          timer_message_code = p_message_code
       OR
          next_timer= p_message_code
    )
    AND   status = 'ACTIVE';

   l_msg_code VARCHAR2(20); -- AS PER XNP_TIMER_REGISTRY.TIMER_MESSAGE_CODE
BEGIN
  x_error_code := 0;
  IF p_dummy_for IS NULL THEN
  	l_msg_code := p_msg_header.message_code;
  ELSE
  	l_msg_code := p_dummy_for;
  END IF;

  FOR rec in c_timer_reg(l_msg_code)
    LOOP
       p_timer_id := rec.timer_id;
       EXIT;
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      x_error_code := SQLCODE;
      x_error_message := SQLERRM;
END;

-------------------------------------------------------------------------
---- PROCEDURE:   add_timer()
---- PURPOSE:     Adds the timer to the queue and to the registry.
-------------------------------------------------------------------------
PROCEDURE add_timer (
	p_msg_header IN xnp_message.msg_header_rec_type,
	p_msg_text IN VARCHAR2,
	p_dummy_for IN VARCHAR2 DEFAULT NULL,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2 )

IS

	l_interval  NUMBER ;
	l_interval_txt  VARCHAR2(1024) ;
	l_dummy_text VARCHAR2(32767) ;

	l_status VARCHAR2(1024) ;
	l_timer_id NUMBER ;

	l_start_time DATE ;
	l_end_time DATE ;

BEGIN

	-- Bug # 1351421
	-- Check if there is a ACTIVE timer already fired for
	-- same reference_id and message_code
	-- If so remove that timer.
	-- Note that add_timer is called both for dummy as well
	-- as the actual timer.  For each case need to take care
	-- of earlier DUMMY or actual timers.


	get_active_timer(
		p_msg_header => p_msg_header,
		p_dummy_for => p_dummy_for,
		p_timer_id => l_timer_id,
		x_error_code => x_error_code,
		x_error_message => x_error_message);

	IF (x_error_code <> 0) THEN
		return;
	ELSE
		IF l_timer_id IS NOT NULL THEN
			xnp_timer_core.remove_timer(
				p_timer_id => l_timer_id,
				x_error_code => x_error_code,
				x_error_message => x_error_message) ;

			IF (x_error_code <> 0) THEN
				RETURN ;
			END IF ;
		END IF;
	END IF;

	IF (p_msg_header.message_code = 'T_DUMMY') THEN

		xnp_xml_utils.decode(p_msg_text,'T_DUMMY',l_dummy_text);

		xnp_xml_utils.decode(l_dummy_text, 'INTERVAL',
			l_interval_txt) ;
	ELSE

		xnp_xml_utils.decode(p_msg_text, 'INTERVAL', l_interval_txt) ;

	END IF ;

	l_interval := TO_NUMBER(l_interval_txt) ;

	xnp_message.push(p_msg_header => p_msg_header,
		p_body_text => p_msg_text,
		p_queue_name => xnp_event.c_timer_q,
		p_priority => 1,
		p_delay => l_interval,
		p_commit_mode => xnp_message.c_on_commit) ;


	l_start_time := SYSDATE ;
	l_end_time := l_start_time + (l_interval/86400) ; --24*3600 replaced by 86400

	INSERT INTO xnp_timer_registry (
		timer_id,
		reference_id,
		timer_message_code,
		status,
		start_time,
		end_time,
		next_timer,
		order_id,
		wi_instance_id,
		fa_instance_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date
	)
	VALUES (
		p_msg_header.message_id,
		p_msg_header.reference_id,
		p_msg_header.message_code,
		'ACTIVE',
		l_start_time,
		l_end_time,
		p_dummy_for,
		p_msg_header.order_id,
		p_msg_header.wi_instance_id,
		p_msg_header.fa_instance_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate
		);

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;

END add_timer ;


END xnp_timer;

/
