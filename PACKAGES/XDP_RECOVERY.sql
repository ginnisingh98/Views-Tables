--------------------------------------------------------
--  DDL for Package XDP_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_RECOVERY" AUTHID CURRENT_USER AS
/* $Header: XDPRECOS.pls 120.1 2005/06/16 02:28:26 appldev  $ */

-- Added sacsharm - Application Monitoring service

PROCEDURE Start_Watchdog_Process (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

END XDP_RECOVERY;


 

/
