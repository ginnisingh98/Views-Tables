--------------------------------------------------------
--  DDL for Package XDP_Q_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_Q_ADMIN_PKG" AUTHID CURRENT_USER AS
/* $Header: XDPQADMS.pls 120.2 2006/04/10 23:21:35 dputhiye noship $ */

/********** Commented out - START - sacsharm - 11.5.6 **************

--  API specifications

--   Updates the queue state and initiates related processing, if any, depending on
--   the action code passed. Possible action code values are 'STARTUP', 'SHUTDOWN',
--   'RESUME' and 'SUSPEND'.

 PROCEDURE Update_Q_Status (
		p_q_name IN VARCHAR2,
		p_action_code IN VARCHAR2,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);

--   Returns number of DQers running for an enabled queue

 PROCEDURE Check_Q_Status (
		p_q_name IN VARCHAR2,
		p_dq_count OUT NUMBER,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);

--  Enables the queue for processing and starts the asscociated DQer processes for the queue

 PROCEDURE Start_Q (
		p_q_name IN VARCHAR2,
		p_q_display_name IN VARCHAR2,
		p_q_state IN VARCHAR2,
		p_q_count IN NUMBER,
		p_max_tries IN NUMBER DEFAULT 1,
		p_caller IN VARCHAR2 DEFAULT 'NON_CONC_JOB',
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);


--  Enables all queues for processing and starts the asscociated DQer processes for the queue

 PROCEDURE Start_All_Qs (
		p_caller IN VARCHAR2 DEFAULT 'CONC_JOB',
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);

--   Gets the sorted list (latest first) of exception messages associated with the queue.
--   Message text is in user's language and has parameter tokens substituted with the values.

 PROCEDURE Get_Q_Errors (
		p_q_name IN VARCHAR2,
		p_message_list OUT XDP_TYPES.MESSAGE_LIST,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);

*********** Commented out - END - sacsharm - 11.5.6 *************/

END XDP_Q_ADMIN_PKG;

 

/
