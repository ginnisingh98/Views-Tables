--------------------------------------------------------
--  DDL for Package WSM_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMVLOGS.pls 120.0 2005/06/21 04:03 sthangad noship $ */

--   FND_LOG_LEVELS
--     --------------
--
--     LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
--     LEVEL_ERROR      CONSTANT NUMBER  := 5;
--     LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
--     LEVEL_EVENT      CONSTANT NUMBER  := 3;
--     LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
--     LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
--
--     FND_LOG.G_CURRENT_RUNTIME_LEVEL;  --> Will give the current runtime log level....
--
--     Logging Level  Value	Meaning
--     ---------------------------------------------------------------------------------------------------------------------------------------------------------
--
--     OFF		0	Logging is disabled.				<<----- For administrative use only (Java layer only) ----->>
--
--     STATEMENT		1	Low severity message offering maximum detail.	<<----- Internal development and support teams ----->>
--
--				"Obtained Connection from Pool"
--				"Got request parameter"
--				"Set Cookie with name, value"
--
--     PROCEDURE		2	Logging message called upon entry and/or exit from a method.	<<------ Internal development and support teams    ------>>
--
--				"Calling PL/SQL proc xyz"
--				"Returning from PL/SQL proc xyz"
--
--      EVENT		3	A significant milestone in the normal execution path of an application.	<<------ Internal development and support teams	------>>
--
--      				"User authenticated successfully"
--				"Retrieved user preferences successfully"
--				"Menu rendering completed"
--
--      EXCEPTION		4	A lower-level API is returning a failure code or exception,
--      				but the error does not necessarily indicate a problem at the level of the calling code.	 <<----- Internal development and support teams	------->>
--
--				"Profile not found"
--				"Region not found"
--				"Network routine could not connect; retrying"
--
--      ERROR		5	An error message to the end-user.	 <<------     Customer sysadmins, internal development and support teams  ------>>
--
--				"Invalid username or password."
--				"User entered a duplicate value for field."
--
--      UNEXPECTED	6	An unexpected situation occurred which is likely to indicate or cause
--      				instabilities in the runtime behavior, and which the system administrator
--				needs to take action on.		<<------ Customer sysadmins, internal development and support teams	----------->>
--
--				"Out of memory"
--				"Required file not found"
--				"Data integrity error"
--				"Network integrity error"
--				"Configuration error; required property not set, cannot access configuration file."
--				"Failed to place new order due to DB SQLException."
--				"Failed to obtain Connection for processing request. "
--
--
--     FND_MSG_PUB levels
--     -------------------
--
--     FND_PROFILE.VALUE('FND_AS_MSG_LEVEL_THRESHOLD') ); --> will give the current msg logging level..
--
--     G_MSG_LVL_UNEXP_ERROR	CONSTANT NUMBER	:= 60;
--     G_MSG_LVL_ERROR		CONSTANT NUMBER	:= 50;
--     G_MSG_LVL_SUCCESS    	CONSTANT NUMBER	:= 40;
--     G_MSG_LVL_DEBUG_HIGH   	CONSTANT NUMBER	:= 30;
--     G_MSG_LVL_DEBUG_MEDIUM 	CONSTANT NUMBER	:= 20;
--     G_MSG_LVL_DEBUG_LOW   	CONSTANT NUMBER	:= 10;
--
--
--     1.	For all messages we should consider
--	a.	Alert Category
--	i.	Product
--	ii.	System
--	iii.	NULL
--	b.	Alert Severity
--	i.	Critical
--	ii.	Error
--	iii.	Warning
--	iv.	NULL
--	c.	Log Severity
--	i.	Unexpected
--	ii.	Error
--	iii.	Exception
--	iv.	Event
--	v.	Procedure
--	vi.	Statement
--
--	2.	For now, the only alertable message is, WSM_GENERIC_ERROR - 'An unexpected error has occurred.
--		Please contact your System Administrator' with 'Alert Category = System' and 'Alert Severity = Error'
--
--	3. Message Categories
--	(A1) SQL error: SQLERRM
--	(A2) SQL error: generic error message WSM_GENERIC_ERROR
--	(B)  Functional error: translated message in wsmmsg.ldt
--	(C1) Functional warning: translated message in wsmmsg.ldt
--	(C2) Warning, defaulting: translated message WSM_DEFAULTING_WARNING
--	(D)  Progress, high level: for example "starting LBJ worker..."
--	(E)  Progress, detailed level: for example, number of rows inserted,
--	calling a procedure, etc.
--	(F)	Statement level info
--
--	4. Places to log
--	a.	Messaging: put message into FND_MSG_PUB. Controlled by 'FND: Message Level Threshold'.
--		The called procedure will write message into FND_MSG_PUB by calling FND_MSG_PUB.Add
--
--	Profile = 60 will write (A2)
--	Profile = 50 will write above + All (B)
--	Profile = 40 will write above + (C1)
--	Profile = 30 will write above + (C2)
--
--	b.	FND Logging: put message into FND_LOG table
--
--	Profile = Unexpected Error, log (A2) + (A1)
--	Profile = Expected Error,   log above + All (B)
--	Profile = Exception,        log above + (C1) + (C2)
--	Profile = Event,            log above + (D)
--	Profile = Procedure,        log above + (E)
--	Profile = Statement,        log above + (F)
--
--	c.	Write into WIE: this is for interface only. We will use the same profile 'FND: Message Level Threshold' to
--		control this to log the (A2) + (B) + (C1) + (C2)
--
--	d.	Concurrent Logging: FND_FILE.put_line, this is also for interface only.
--
--		We will ignore MRP_DEBUG profile and only log (A2) + (B). The concurrent log will only have high level translated information like:
--		i.	Inside the manager, 'Start PROGRAM_NAME'
--		ii.	When launching any request inside the manager 'Launching <concurrent program> in concurrent request REQUEST_ID'
--		iii.	At the end, 'End PROGRAM_NAME'
--		iv.	Inside the worker, 'Start PROGRAM_NAME'
--		v.	In case of error only, show the record info like
--			'The above error occurred when processing the record with header HEADER_ID and job JOB_NAME' after the actual error.
--		vi.	When launching any request inside the worker 'Launching <concurrent program> in concurrent request REQUEST_ID'
--		vii.	At the end, 'Total number of records = TOTAL_NO_REC, Successful records = SUC_NO_REC and Errored records = ERR_NO_REC'.
--		viii.	Finally, if there are warnings, 'Please check WSM_INTERFACE_ERRORS for warnings during this request'
--		ix.	At the end, 'End PROGRAM_NAME'
--
--	5.	Every message in FND LOG of level unexpected or error, should have a corresponding message at level
--		unexpected or error with all the debug details. Module will have the program name, stmt no etc.
--	6.	We can define the g_error_msg_tbl in WSMPUTIL as global PL/SQL table and use it in our interfaces.
--	7.	Due to the auto logging done by the logging framework we can have duplicate messages in the FND_LOG table in some situations.
--	8.	Store FND_LOG.CURRENT_RUNTIME_LEVEL by creating global variables in each package

-- Parameter PL/SQL tables..
TYPE param_rec_type is record(paramName VARCHAR2(255), paramValue VARCHAR2(255));
TYPE param_tbl_type is table of param_rec_type index by binary_integer;

-- PL/SQL table for WIE..
TYPE error_msg_tbl_type is table of WSM_INTERFACE_ERRORS%ROWTYPE index by binary_integer;
g_error_msg_tbl         WSM_log_PVT.error_msg_tbl_type;


TYPE token_rec_type IS RECORD
(
  TokenName  varchar2(2000),
  TokenValue varchar2(2000)
);

TYPE token_rec_tbl is table of token_rec_type index by binary_integer;


-- This procedure will be invoked to log the parameters...
PROCEDURE LogProcParams ( p_module_name       IN     varchar2  ,
			  p_param_tbl	      IN     WSM_log_PVT.param_tbl_type,
			  p_fnd_log_level     IN     number
			);

-- This procedure is to Log a message..(a non-translated logging message or a transalated message)
-- When the message name is passed, the message will be logged into
-- FND_MSG_PUB and WIE table if logging is enabled
-- If p_msg_text is not null, the message is considered as a non-translated
-- and will be logged into FND_LOG_MESSAGES table alone
PROCEDURE LogMessage  ( p_module_name	    IN     varchar2  			    ,
			p_msg_name  	    IN 	   varchar2  		DEFAULT NULL,
			p_msg_appl_name	    IN     VARCHAR2  		DEFAULT NULL,
			p_msg_text	    IN	   varchar2  		DEFAULT NULL,
			p_stmt_num	    IN	   NUMBER    		DEFAULT NULL,
			p_msg_tokens	    IN	   token_rec_tbl 	,
			-- pass 1 to p_wsm_warning if the message is a a warning message (purely for WIE purposes..)
			p_wsm_warning	    IN     NUMBER		DEFAULT NULL,
			p_fnd_msg_level     IN     NUMBER		DEFAULT NULL,
			p_fnd_log_level     IN     NUMBER			    ,
			p_run_log_level	    IN	   NUMBER
		       );

-- This procedure is to handle any ORA exception and will be invoked from WHEN OTHERS exception handler
PROCEDURE  handle_others ( p_module_name	    IN varchar2,
			   p_stmt_num		    IN NUMBER,
			   p_fnd_log_level     	    IN NUMBER,
			   p_run_log_level	    IN NUMBER
			 );

-- This procedure is to write the messages in the PL/SQL table g_error_msg_tbl to the database ...
PROCEDURE WriteToWIE;

-- This procedure will be used to update the g_error_msg_tbl with
-- error messages populated by the other product API's
Procedure update_errtbl (p_start_index IN NUMBER,
			 p_end_index   IN NUMBER
			);

-- Global variable indicating interface code.
-- When set to 1, the PL/SQL table g_error_msg_tbl will be filled with the messages
-- which will be then written to the WSM_INTERFACE_ERRORS table by the interface program by invoking WriteToWIE
g_write_to_WIE NUMBER := 0;
g_header_id    NUMBER;
g_txn_id       NUMBER;

-- Populate Interface information...
-- This will also set the Global variable g_conc_log_enabled to 1.
-- When g_conc_log_enabled is set to 1 all event and above log messages at event level and above will
-- be logged to the log file and the based on MSG_LEVEL messages will be added to the WIE global PL/SQL
-- table..
Procedure PopulateIntfInfo ( p_header_id IN  	NUMBER,
			     p_txn_id	 IN	NUMBER
			   );


END WSM_log_PVT;

 

/
