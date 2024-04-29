--------------------------------------------------------
--  DDL for Package FII_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_UTIL" AUTHID CURRENT_USER AS
/* $Header: FIIUTILS.pls 115.11 2004/08/10 23:24:19 phu noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: FIIUTILS.pls 115.11 2004/08/10 23:24:19 phu noship $';

-- ------------------------
-- Global Variables
-- ------------------------
g_obj_name VARCHAR2(100);

-- ------------------------
-- Public Procedures
-- ------------------------

-- ------------------------------------------------------------------
-- Name: Initializes variables for logging other utility functions
-- Desc: 1. Setup which directory to put the log and what the log file
--          name is.  The directory setup is used only if the program
--          is not run thru concurrent manager.
--       2. Set up the debug flag if the debug profile is set
-- -----------------------------------------------------------------
PROCEDURE initialize(
	p_log_file		VARCHAR2 default 'fii_debug.log',
	p_out_file		VARCHAR2 default 'fii_debug.out',
	p_directory		VARCHAR2 default NULL,
        p_obj_name              VARCHAR2 default 'FII'
);

-- ------------------------------------------------------------------
-- Name: debug_line
-- Desc: If debug flag is turned on, the message will be printed
--       All debug messages are concatenated with "DEBUG: " prefix
-- -----------------------------------------------------------------
PROCEDURE debug_line(
        p_text			VARCHAR2);

-- ------------------------------------------------------------------
-- Name: put_line
-- Desc: For now, just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE put_line(
        p_text			VARCHAR2);

-- ------------------------------------------------------------------
-- Name: put_timestamp
-- Desc: Prints the message along with the current timestamp
-- -----------------------------------------------------------------
PROCEDURE put_timestamp(
	p_text			VARCHAR2 default 'Time Stamp');


-- ------------------------------------------------------------------
-- Name: start_timer
-- Desc: Starts the internal timer. If timer already started, it
--       re-sets the start time
-- -----------------------------------------------------------------
PROCEDURE start_timer;

-- ------------------------------------------------------------------
-- Name: stop_timer
-- Desc: Stop the internal timer and stores the duration in
--       number of days.
-- -----------------------------------------------------------------
PROCEDURE stop_timer;

-- ------------------------------------------------------------------
-- Name: print_timer
-- Desc: Prints the message along with the current timer display.
--       If the timer is still running, it prints the duration since
--       the timer was started.  If the timer has been stopped, it
--       prints the duration between last timer start and stop.
--	 The duration are printed in the following format: x days HH:MM:SS
-- -----------------------------------------------------------------
PROCEDURE print_timer(
	p_text			VARCHAR2 default 'Duration');


-- -----------------------------------------------------------------
-- Name: get_schema_name
-- Desc: Return the schema name of p_app_short_name, which is
--       default to 'FII'.
--       Return null for error.
-- -----------------------------------------------------------------
FUNCTION get_schema_name(
	p_app_short_name	in varchar2 default 'FII'
) return varchar2;


-- -----------------------------------------------------------------
-- Name: get_apps_schema_name
-- Desc: Return the schema name of APPS
--       Return NULL for error
-- -----------------------------------------------------------------
FUNCTION get_apps_schema_name return varchar2;


-- -----------------------------------------------------------------
-- Name: truncate_table
-- Desc: Truncate table p_table_name in the schema of
--       p_app_short_name, which is default to 'FII'.
--       Set p_retcode to '-1' if error occurs, otherwise
--       set p_retcode to '0'.
-- -----------------------------------------------------------------
PROCEDURE truncate_table(
	p_table_name		in varchar2,
	p_app_short_name	in varchar2 default 'FII',
    p_retcode        	out nocopy varchar2
);

-- -----------------------------------------------------------------
-- Name: drop_table
-- Desc: Drop table p_table_name in the schema of
--       p_app_short_name, which is default to 'FII'.
--       Set p_retcode to '-1' if error occurs, otherwise
--       set p_retcode to '0'.
-- -----------------------------------------------------------------
PROCEDURE drop_table(
    p_table_name		in varchar2,
    p_app_short_name	in varchar2 default 'FII',
    p_retcode        	out nocopy varchar2
);


/*---------------------------------------------------------------------
 Call to get the log directory when running program from SQLPLUS

 Doing so by parsing the 'utl_file_dir' init.ora parameter and scanning
 for the word log and getting that string out.
---------------------------------------------------------------------*/
Function get_Utl_File_Dir return VARCHAR2;

-- ------------------------------------------------------------------
-- Name: write_log
-- Desc: just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE write_log( p_text VARCHAR2);

-- ------------------------------------------------------------------
-- Name: write_output
-- Desc: just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE write_output( p_text VARCHAR2);

end;

 

/
