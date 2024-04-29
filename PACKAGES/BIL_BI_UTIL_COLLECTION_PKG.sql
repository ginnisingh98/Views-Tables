--------------------------------------------------------
--  DDL for Package BIL_BI_UTIL_COLLECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_UTIL_COLLECTION_PKG" AUTHID CURRENT_USER AS
/*$Header: bilbutcs.pls 120.1 2006/03/27 22:04:46 jmahendr noship $*/

-- **********************************************************************
--	FUNCTION get_schema_name
--
--	Purpose:
--	To retrieve the schema name for the given Application Short Name
--
-- **********************************************************************

FUNCTION get_schema_name(p_appl_name 	IN VARCHAR2)
	   RETURN VARCHAR2;


-- **********************************************************************
--	FUNCTION get_apps_schema_name
--
--	Purpose:
--	To retrieve the apps schema name
--
-- **********************************************************************

FUNCTION get_apps_schema_name RETURN VARCHAR2;



-- **********************************************************************
--	PROCEDURE analyze_table
--
--	Purpose:
--	To Analyze the input Sales Intelligence table from the BIL
--    schema
--
-- **********************************************************************

PROCEDURE analyze_table (p_tbl_name IN VARCHAR2,
				 p_cascade IN BOOLEAN,
				 p_est_pct IN NUMBER,
				 p_granularity IN VARCHAR2);


-- ********************************************************************
--	PROCEDURE truncate_table
--
--	Purpose:
--	 To remove all the records from the table specified.
--
-- ********************************************************************

    PROCEDURE truncate_table (p_table_name IN varchar2);


-- ********************************************************************
--	PROCEDURE drop_table
--
--	Purpose:
--	 To drop the table specified.
--
-- ********************************************************************

    PROCEDURE drop_table (p_table_name IN varchar2) ;

-- ********************************************************************
--	FUNCTION get_profile_value
--
--	Purpose:
--	 To get the profile value of the specified parameter
--
-- ********************************************************************

FUNCTION get_profile_value (p_profile_parameter IN VARCHAR2)
RETURN VARCHAR2 ;


--  **********************************************************************
--	FUNCTION chkLogLevel
--
--	Purpose
--	To check if log is Enabled for Messages
--      This function is a wrapper on FND APIs for OA Common Error
--       logging framework
--
--        p_log_level = Severity; valid values are -
--			1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--			2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--			3. Event Level (FND_LOG.LEVEL_EVENT)
--			4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--			5. Error Level (FND_LOG.LEVEL_ERROR)
--			6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--
--	Output values:-
--                       = TRUE if FND Log is Enabled or BIS Log is Enabled
--	           = FALSE if both are DISABLED
--
--
--  **********************************************************************

FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN;



--  **********************************************************************
--	PROCEDURE writeLog
--
--	Purpose:
--	To log Messages
--      This procedure is a wrapper on FND APIs for OA Common Error
--       logging framework for Severity = Statement(1), Procedure(2)
--       , Event(3), Expected (4) and Error (5)
--
--      Input Variables :-
--        p_log_level = Severity; valid values are -
--			1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--			2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--			3. Event Level (FND_LOG.LEVEL_EVENT)
--			4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--			5. Error Level (FND_LOG.LEVEL_ERROR)
--			6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--        p_module = Module Source Details
--        p_msg    = Message String
--        p_force_log = Force message in log file. Default False.
--
--  **********************************************************************

PROCEDURE writeLog (p_log_level IN NUMBER,
	       p_module IN VARCHAR2,
	       p_msg IN VARCHAR2,
	       p_force_log IN BOOLEAN DEFAULT FALSE);



--  **********************************************************************
--	FUNCTION get_user_profile_name
--
--	Purpose
--	To return the User PRofile Name
--
--    Input value  = p_profile_name = Profile Name
--
--	Output values:-
--               = Profile Option Name for the User
--
--
--  **********************************************************************


FUNCTION get_user_profile_name (p_profile_name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_global_rate_p (code IN varchar2, rate_Date IN date) RETURN NUMBER PARALLEL_ENABLE;

FUNCTION get_global_rate_s (code IN varchar2, rate_Date IN date) RETURN NUMBER PARALLEL_ENABLE;

END bil_bi_util_collection_pkg;


 

/
