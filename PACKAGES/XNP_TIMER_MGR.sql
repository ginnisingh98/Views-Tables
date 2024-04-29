--------------------------------------------------------
--  DDL for Package XNP_TIMER_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMER_MGR" AUTHID CURRENT_USER AS
/* $Header: XNPTMGRS.pls 120.1 2005/06/24 04:48:41 appldev ship $ */

-- Wrapper process for the inbound timer queue.
-- Invokes process for enqueuing messages on the inbound timer queue.
--
PROCEDURE PROCESS_IN_TMR ;
--
-- Constructs the dynamic message for the timer.
--
PROCEDURE CONSTRUCT_DYNAMIC_MESSAGE
(
		p_msg_to_create  IN VARCHAR2,
		p_old_msg_header IN xnp_message.msg_header_rec_type,
		p_delay IN NUMBER DEFAULT NULL,
		p_interval IN NUMBER DEFAULT NULL,
		x_new_msg_header OUT NOCOPY xnp_message.msg_header_rec_type,
		x_new_msg_text OUT NOCOPY VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2) ;

-- Checks arrival of a timer and starts the actual timer when the dummy timer is dequeued.
-- If the dequeued message is an actual timer, it
-- enqueues it back on the inbound message queue.
--
PROCEDURE PROCESS
 (P_QUEUE_NAME IN VARCHAR2
 ) ;

PROCEDURE  process_in_tmr(p_message_wait_timeout IN NUMBER DEFAULT 1,
			p_correlation_id IN VARCHAR2,
			x_message_key OUT NOCOPY VARCHAR2,
			x_queue_timed_out OUT NOCOPY VARCHAR2);


PROCEDURE process(
	p_queue_name IN VARCHAR2,
	p_correlation_id IN VARCHAR2,
	x_queue_timed_out OUT NOCOPY VARCHAR2
) ;
END xnp_timer_mgr;

 

/
