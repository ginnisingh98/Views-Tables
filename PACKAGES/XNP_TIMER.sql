--------------------------------------------------------
--  DDL for Package XNP_TIMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMER" AUTHID CURRENT_USER AS
/* $Header: XNPTIMRS.pls 120.2 2006/02/13 07:57:39 dputhiye ship $ */

-- Checks the delay and interval of the timer.
-- If the delay is greater than 0 , it introduces
-- a dummy timer into the system
-- Otherwise enqueues the actual timer.
--
PROCEDURE start_timer
(
	p_msg_header IN xnp_message.msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

END XNP_TIMER;

 

/
