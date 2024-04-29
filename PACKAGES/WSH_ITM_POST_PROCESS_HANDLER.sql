--------------------------------------------------------
--  DDL for Package WSH_ITM_POST_PROCESS_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_POST_PROCESS_HANDLER" AUTHID CURRENT_USER AS
/* $Header: WSHITPHS.pls 120.2.12010000.1 2008/07/29 06:14:12 appldev ship $ */
	PROCEDURE CHECK_PENDING_CALL_API(p_request_control_id	NUMBER,
					 p_request_set_id	NUMBER,
					 p_application_id	NUMBER,
					 p_source		VARCHAR2);

	PROCEDURE CALL_CUSTOM_API( p_request_control_id	NUMBER,
				 p_request_set_id	NUMBER,
				 p_application_id	NUMBER,
				 p_source		VARCHAR2);
	-- Bug 5222683
    -- Overloaded API added for enabling shipping and OM debugging
	PROCEDURE CHECK_PENDING_CALL_API(p_request_control_id	NUMBER,
					 p_request_set_id	NUMBER,
					 p_application_id	NUMBER,
					 p_source		VARCHAR2,
                                         p_itm_log_level        NUMBER,
                                         p_log_filename         VARCHAR2);
END WSH_ITM_POST_PROCESS_HANDLER;

/
