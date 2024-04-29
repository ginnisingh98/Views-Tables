--------------------------------------------------------
--  DDL for Package XNP_TIMER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMER_CORE" AUTHID CURRENT_USER AS
/* $Header: XNPTBLPS.pls 120.1 2005/06/17 03:54:15 appldev  $ */

-- Recalculate the values for delay and interval for the given timer
--
PROCEDURE recalculate
(
	p_reference_id	IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Recalculate the values for delay and interval for timers
-- associated with the reference ID.
--
PROCEDURE recalculate_all
(
	p_reference_id IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Get status for the timer
--
PROCEDURE get_timer_status
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_timer_id OUT NOCOPY NUMBER
	,x_status OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Get status for the timer
--
PROCEDURE get_timer_status
(
	p_timer_id	IN NUMBER
	,x_status OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Update status for the timer
--
PROCEDURE update_timer_status
(
	p_timer_id IN NUMBER
	,p_status IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Update status for the timer
--
PROCEDURE update_timer_status
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,p_status IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove timer using reference_ID and timer name
--
PROCEDURE remove_timer
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
 );

-- Remove timer using timer_id
--
PROCEDURE remove_timer
(
	p_timer_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove timer using order_ID
--
PROCEDURE deregister
(
	p_order_id IN NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove all timers for a given Work Item
--
PROCEDURE deregister_for_workitem
 (
 p_workitem_instance_id IN NUMBER
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove timer using order_ID
--
FUNCTION get_next_timer(p_timer_id NUMBER)
RETURN VARCHAR2 ;

-- Remove timer using order_id
--
PROCEDURE restart
(
	p_reference_id IN VARCHAR2
	,p_timer_message_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Restart all timers for a specific reference ID
--
PROCEDURE restart_all
(
	p_reference_id IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2

);

-- Start timers related to a given message
--
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
);

-- Get jeopardy flag for the given order ID
--
PROCEDURE get_jeopardy_flag
(
	p_order_id IN NUMBER
	,x_flag OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

--  Wrapper to the XNP_<Timer Code>_U.FIRE procedure
--
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
                  p_fa_instance_id  IN NUMBER  DEFAULT NULL
                );

END xnp_timer_core;

 

/
