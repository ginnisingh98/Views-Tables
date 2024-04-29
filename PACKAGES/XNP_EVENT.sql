--------------------------------------------------------
--  DDL for Package XNP_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_EVENT" AUTHID CURRENT_USER AS
/* $Header: XNPEVTPS.pls 120.1 2005/06/18 00:26:38 appldev  $ */
-- Constant for Inbound Message Queue
 CC_INBOUND_MSG_Q CONSTANT VARCHAR2(40) := 'XNP_IN_MSG_Q'  ;
-- Constant for Outbound Message Queue
 CC_OUTBOUND_MSG_Q CONSTANT VARCHAR2(40) := 'XNP_OUT_MSG_Q' ;
-- Constant for Internal Event Queue
 CC_INTERNAL_EVT_Q CONSTANT VARCHAR2(40) := 'XNP_IN_EVT_Q' ;
-- Constant for Timer Queue
 CC_TIMER_Q  CONSTANT VARCHAR2(40) := 'XNP_IN_TMR_Q' ;

c_inbound_msg_q   VARCHAR2(80) ;
c_outbound_msg_q  VARCHAR2(80) ;
c_internal_evt_q  VARCHAR2(80) ;
c_timer_q         VARCHAR2(80) ;

-- Deregisters a registered callback procedure
--
PROCEDURE unsubscribe
(
	p_cb_event_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,p_close_flag IN VARCHAR2 DEFAULT 'Y'
);

-- Deregisters a registered callback procedure
--
PROCEDURE deregister
(
	p_msg_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
) ;

-- Unsubscribes all callback procedure using this order ID
--
PROCEDURE deregister
(
	p_order_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
) ;

-- Unsubscribes all callback procedure using this workitem instance ID
--
PROCEDURE deregister_for_workitem
(
	p_workitem_instance_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
) ;

-- Registers a callback with the event manager
--
PROCEDURE subscribe
(
	p_msg_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_process_reference IN VARCHAR2
	,p_procedure_name IN VARCHAR2
	,p_callback_type IN VARCHAR2
	,p_close_reqd_flag IN VARCHAR2 DEFAULT 'Y'
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
) ;


-- Subscribes for all message acks
--
PROCEDURE subscribe_for_acks
(
	p_message_type IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
) ;



-- Starts the Message server
--
PROCEDURE process_in_msg ;

PROCEDURE  process_in_msg(p_message_wait_timeout IN NUMBER DEFAULT 1,
									p_correlation_id IN VARCHAR2,
                                    x_message_key OUT NOCOPY VARCHAR2,
                                    x_queue_timed_out OUT NOCOPY VARCHAR2);

-- Starts the event server
--
PROCEDURE process_in_evt ;

PROCEDURE  process_in_evt(p_message_wait_timeout IN NUMBER DEFAULT 1,
									p_correlation_id IN VARCHAR2,
                                    x_message_key OUT NOCOPY VARCHAR2,
                                    x_queue_timed_out OUT NOCOPY VARCHAR2);

-- Processes a message from the specified Queue
--
PROCEDURE process(
	p_queue_name IN VARCHAR2
) ;

PROCEDURE process(
	p_queue_name IN VARCHAR2,
	p_correlation_id IN VARCHAR2,
	x_queue_timed_out OUT NOCOPY VARCHAR2
) ;

-- Resumes the given work flow instance
--
PROCEDURE resume_workflow
(
	p_message_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
) ;

-- Resumes the given work flow instance
--
PROCEDURE sync_n_resume_wf
(
	p_message_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
) ;

-- Restarts the specified workflow activity
--
PROCEDURE restart_activity
(
	p_message_id IN NUMBER
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

END xnp_event;

 

/
