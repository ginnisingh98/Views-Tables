--------------------------------------------------------
--  DDL for Package XNP_TIMER_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMER_STANDARD" AUTHID CURRENT_USER AS
/* $Header: XNPTSTAS.pls 120.2 2006/02/13 07:58:30 dputhiye ship $ */

-- Start the timer. Each timer package has a default method
-- called fire that is invoked to start the timer.
--
PROCEDURE FIRE
 (p_order_id NUMBER DEFAULT NULL
 ,p_workitem_instance_id NUMBER DEFAULT NULL
 ,p_fa_instance_id NUMBER DEFAULT NULL
 ,p_timer_code VARCHAR2
 ,p_callback_ref_id VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 );

-- Start timers related to the messge.
--
PROCEDURE START_RELATED_TIMERS
 (p_message_code VARCHAR2
 ,p_order_id NUMBER DEFAULT NULL
 ,p_workitem_instance_id NUMBER DEFAULT NULL
 ,p_fa_instance_id NUMBER DEFAULT NULL
 ,p_callback_ref_id VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 );

-- Retrieve the status for the given timer
--
PROCEDURE GET_TIMER_STATUS
(
 p_reference_id IN VARCHAR2
 ,p_timer_message_code IN VARCHAR2
 ,x_timer_id OUT NOCOPY NUMBER
 ,x_status OUT NOCOPY VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Restart all timers for the reference ID
--
PROCEDURE RESTART_ALL
 (
 p_reference_id IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Recalculate all timers for the reference ID
--
PROCEDURE RECALCULATE_ALL
 (
 p_reference_id IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove the timer for the given reference_ID
--
PROCEDURE REMOVE
 (
 p_reference_id IN VARCHAR2
 ,p_timer_message_code IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove all timers for the given order ID
--
PROCEDURE DEREGISTER
 (
 p_order_id IN NUMBER
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Remove all timers for a given Work Item
--
PROCEDURE DEREGISTER_FOR_WORKITEM
 (
 p_workitem_instance_id IN NUMBER
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);

-- Retrieve the jeopardy flag given the order ID
--
PROCEDURE GET_JEOPARDY_FLAG
(
 p_order_id IN NUMBER
 ,x_flag OUT NOCOPY VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
);
END XNP_TIMER_STANDARD;

 

/
