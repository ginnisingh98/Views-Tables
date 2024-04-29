--------------------------------------------------------
--  DDL for Package FA_RX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: FARXUTLS.pls 120.3.12010000.3 2009/07/19 11:45:44 glchen ship $ */

------------------------------------
-- Global types
------------------------------------
--
-- Used to identify the select list as well as the columns to insert

type Rep_Columns_Rec is record (
	-- Primary Key to this table of records
	--
	primary_key varchar2(40),
	-- The name of the column that is being selected
	-- Fully qualify the column name to include the table alias
        -- Bug 1379946:  increased size of select_column_name
	select_column_name varchar2(4000),
	-- The name of the column where it will be inserted
	-- If this column is not to be inserted, then make this NULL
	insert_column_name varchar2(30),
	-- This is the variable that will hold the value temporarily
	-- Make sure it is of the same type and fully qualify the variable
	-- name and include the package name
	placeholder_name varchar2(60),
	-- Other values
	column_type varchar2(30),
	column_length number
);
type Rep_Columns_Array is table of Rep_Columns_Rec index by binary_integer;

--
-- This record assigns the values of the events for each section
-- as well as if this section is even enabled.
--
type Report_Record is record (
	section_name varchar2(20),
	enabled boolean,
	before_report varchar2(300),
	bind varchar2(300),
	after_fetch varchar2(300),
	after_report varchar2(300)
);
type Report_Array is table of Report_Record index by binary_integer;


------------------------------------
-- Global (public) variables
------------------------------------

--
-- Report sections
-- These variables are set using the procedure assign_report().
-- You should only manipulate these variables if you need to do something a bit more complex
-- then what the assign_report() procedure provides.
-- e.g., in your plug-in code, you may want to have a before report trigger which fires
--       before the main before report trigger. assign_report() always sets the
--	 triggers to run after the core report.
Num_Sections number;
Report Report_Array;
-- During your report triggers, you may want to know which section you are running currently.
-- This value is made available to use within your triggers.
-- NOTE: Changing this value will not change which section is begin run. This is provided as
-- informational only. It's value will be reset to the current section whenever a new section begins.
Current_Section varchar2(20);

--
-- Column mappings
-- These variables are set during init_request() and assign_column() procedures. They are provided
-- as informational only and you should not change these values - EVER!
Num_Columns number;
Rep_Columns Rep_Columns_Array;
Interface_Table varchar2(30);

--
-- SELECT statement parts
-- The different parts of the SELECT statement (From/Where/Group by/Having/Order by) are available for
-- developers to manipulate. These should be manipulated from within the before_report event.
-- If you are the main report developer (not the plug-in), then you should simply assign your PL/SQL
-- statements here. Plug-in developers should make sure to concatenate their listing.
--
-- NOTE: Plug-ins --> Make sure to include and ',' or 'AND' (for where clauses) when appending your part.
--
-- These parts will be used to create a SELECT statement.
-- assign_column() function creates the select list portion. These parts will be used as follows:
-- 'SELECT '||<select list from assign_column()>||
-- ' FROM '||<From_Clause>||
-- DECODE(Where_Clause, NULL, NULL, ' WHERE '||Where_Clause)||
-- DECODE(Group_By_Clause, NULL, NULL, ' GROUP BY '||Group_By_Clause)||
-- DECODE(Having_Clause, NULL, NULL, ' HAVING '||Having_Clause)||
-- DECODE(Order_By_Clause, NULL, NULL, ' ORDER BY '||Order_By_Clause)
--
--
-- Assigned values to this record by the function assign_columns
-- This record is to store the specifics of a single column
-- in the SELECT and/or the INSERT statement.
--
-- NOTE: Unlike some of the other global public variables,
--       these should be assigned values directly. There are no functions
--       which will set these up for you.
Hint_Clause varchar2(500);
From_Clause varchar2(10000);
Where_Clause varchar2(10000);
Group_By_Clause varchar2(10000);
Having_Clause varchar2(10000);
Order_By_Clause varchar2(10000);


------------------------------------
-- Functions/Procedures
------------------------------------

-------------------------------------------------------------------------
--
-- PROCEDURE init_request
--
-- Parameters
--		p_calling_proc  The name of the procedure calling this function
--		p_request_id	Request ID of this concurrent request.
--		p_interface_table	Optional parameter to pass the name
--					of the interface table to insert into.
--
-- Description
--   This function initializes some of the parameters needed by RX.
--   These include:
--		User_ID
--		Login_ID
--		Today's Date <-- All three used in <WHO Columns>
--		Interface Table name <-- retrieved using p_request_id
--   The first time this procedure is called, this function caches the
--   value of p_calling_proc. The procedure run_report() will run the report
--   only when called with the same value.
--   This allows for init_request(), assign_report(), and run_report() to
--   be called multiple times (which is needed when creating a plug-in.
--
-- NOTES
--   If this function is called with a request id of 0, it will assume
--   that you are trying to debug this code from SQL*Plus and skip
--   this routine. It assumes that your testing script has already
--   called init_debug (below) to initialize these routines.
--
-- Modification History
--  KMIZUTA    12-MAR-99	Created.
--
-------------------------------------------------------------------------
procedure init_request(p_calling_proc in varchar2, p_request_id in number,
		p_interface_table in varchar2 default null);


-------------------------------------------------------------------------
--
-- PROCEDURE init_debug
--
-- Parameters
--		p_interface_table	Interface table for the RX Report
--
-- Description
-- 	Does pretty much the same as init_request() except it initializes
--	the Interface Table name from the parameter. When debugging
--	using SQL*Plus, there will be no request_id from which you could
--	find out the interface table name.
--	You should prepare a test script whenever testing RX reports which
--	1) Calls fnd_global.initialize
--	   This initializes Oracle Applications.
--	2) Calls fa_rx_util_pkg.enable_debug(debug_dir, debug_file)
--	   Enable debugging for these routines (if you want)
--	3) Calls fa_rx_util_pkg.init_debug
--	   Initialize these routines
--	4) Calls your RX report
--
-- Modification History
--  KMIZUTA    12-MAR-99	Created.
--
-------------------------------------------------------------------------
procedure init_debug(p_interface_table in varchar2);


-------------------------------------------------------------------------
--
-- PROCEDURE assign_column
--
-- Parameters
--	p_key		This is sort of like the primary key. Plug-ins
--			will be able to override what you specify
--			here using this key.
--	p_select_column_name
--			This is the name of the column that you will
--			be selecting from. Make sure to fully qualify
--			the column name (i.e., make sure the table
--			alias is included as in cc.code_combination_id).
--	p_insert_column_name
--			This is the name of the column in the interface
--			table where this value will be stored.
--	p_placeholder_name
--			This is the name of the package variable into
--			which this value is temporarily stored.
--			Make sure to fully qualify your variable name
--			with the package name (i.e., package_foo.struct_bar.var_name)
--	p_column_type	Data type. Must be either VARCHAR2, NUMBER, DATE
--	p_column_length	Needed only if the column type is VARCHAR2.
--			The length of the PLACEHOLDER variable.
--
-- Description
--	This procedure assigns this column to the report. These values
--	will be used to construct the SELECT statement as well as the
--	INSERT statement.
--
-- NOTES:
--	You may want to SELECT from a column which will be used in your
--	after fetch trigger. If you do not want to insert this value into
--	the interface table, simply keep p_insert_column_name NULL.
--	On the other hand, you may have a value which you calculate in
--	the after fetch trigger, but there is no source column from
--	the select statement. In this case, simply leave p_select_column_name
--	NULL.
--	In either case, you must specify p_placeholder_name
--
-- Modification History
--  KMIZUTA    12-MAR-99       Created.
--
-------------------------------------------------------------------------
procedure assign_column(p_key in varchar2,
			p_select_column_name in varchar2,
			p_insert_column_name in varchar2,
			p_placeholder_name in varchar2,
			p_column_type in varchar2,
			p_column_length in number default NULL);

-------------------------------------------------------------------------
--
-- PROCEDURE assign_report
--
-- Parameters
--	p_section_name		Your report may have multiple sections
--				where each section has a different
--				SELECT statement. You can have this model
--				run through each of your SELECT statements
--				in separate sections. Specify your section
--				name here.
--	p_before_report
--	p_bind
--	p_after_fetch
--	p_after_report		These are the event triggers. Specify the
--				name of your procedure that you would
--				like to have called in each event. Make
--				sure to fully specify the procedure name
--				(i.e., add package name). Also, make sure
--				you add the ';' at the end.
--
--
-- Description
--	This procedure assigns the different event blocks for a given
--	section.
--
-- NOTES
--	The before report, after fetch, and after report event blocks
--	should not use any host variables.
--	The bind event must pass the host variable :CURSOR_SELECT.
--	This variable should be of type number or integer and you
--	should use this value as the cursor you pass to
--	dbms_sql.bind_variable().
--
-- Logic Flow
--	Blocks marked with a (*) are the events that are being set
--	by this procedure.
--
--         ------------------
--         | Before Report* |<----|
--         ------------------     |
--                 |              |
--                 v              |
--         ------------------     |
--         | Build Select   |     |
--         ------------------     |
--                 |              |
--                 v              |
--         ------------------     |
--         | Bind Select*   |     |
--         ------------------     |
--                 |              |
--                 v              |
--         ------------------     |
--         | Fetch Row      |<-|  |
--         ------------------  |  |
--                 |           |  |
--                 v           |  |
--         ------------------  |  |
--         | After Fetch*   |  |  |
--         ------------------  |  |
--                 |           |  |
--                 v           |  |
--         ------------------  |  |
--         | Insert Row     |  |  |
--         ------------------  |  |
--                 |           |  |
--                 v           |  |
--         ------------------  |  |
--         | Get Next Row   |--|  |
--         ------------------     |
--                 |              |
--               no more          |
--                 |              |
--                 v              |
--         ------------------     |
--         | Next Section   |-----|
--         ------------------
--                 |
--               no more
--                 |
--                 v
--         ------------------
--         | After Report*  |
--         ------------------
--                 |
--                 v
--
-- Before Report
--	Before report should call assign_column and set values to
--	From_Clause, Where_Clause, Group_By_Clause, Having_Clause,
--	Order_By_Clause. This is basically building up the SELECT
--	statement and the insert statement.
--	You may also do any preprocessing that may be required such
--	as leaving an audit of your run.
--
-- Bind
--	The bind event is called once after the select statement is
--	built and it has been parsed. You will be passed the value
--	of the cursor for the SELECT statement in a host variable
--	by the name of :CURSOR_SELECT. You will need to call
--	dbms_sql.bind_variabe to bind any variables that you may
--	have included in your Where_Clause, Group_By_Clause,
--	Having_Clause, or Order_By_Clause.
--
-- After Fetch
--	This event is called after each row is fetched. You can
--	assume that the placeholder variables that you specified
--	in your calls to assign_column are holding the value
-- 	for the current row. Do any processing that needs to
--	be done before the insert.
--
-- After Report
--	This event is called after the report section finishes.
--	You should do any cleanup here.
--	e.g., you may have opened a cursor which is used within
--	your after fetch event. You will want to close this
--	cursor within this routine.
--
-- Modification History
--  KMIZUTA    12-MAR-99       Created.
--
-------------------------------------------------------------------------
procedure assign_report(p_section_name in varchar2,
			p_enabled in boolean,
			p_before_report in varchar2,
			p_bind in varchar2,
			p_after_fetch in varchar2,
			p_after_report in varchar2);

-------------------------------------------------------------------------
--
-- PROCEDURE run_report
--
-- Parameters
-- 	p_calling_proc		This is the procedure that is calling the
--				run_report() function.
--	retcode			Concurrent program return code
--	errbuf			Error/Warning message buffer
--
-- Description
--	This is the procedure which actually runs your report. The logic
--	flow that is described above (in assign_report), is actually
--	performed by this procedure. Make sure to call this procedure
--	only after you have called init_request (or init_debug) and
--	assign_report.
--
--      The sucessful/warning/error status will be returned in retcode and errbuf
--
-- NOTES
--   The first time init_request() procedure is called, this function caches the
--   value of p_calling_proc. The procedure run_report() will run the report
--   only when called with the same value.
--   This allows for init_request(), assign_report(), and run_report() to
--   be called multiple times (which is needed when creating a plug-in.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure run_report(p_calling_proc in varchar2, retcode out nocopy number, errbuf out varchar2);


-------------------------------------------------------------------------
--
-- PROCEDURE log
-- PROCEDURE out
--
-- Parameters
--	msg	String to be logged/outputted
--
-- Description
--	These files are wrappers to other routines. It basically handles
--	your output to log and output files. This was added here so that
--	if you ever need to quickly make it so that all output goes
--	through dbms_output, you can just modify these functions.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure log(msg in varchar2);
procedure out(msg in varchar2);


------------------------------------
-- Debuggin Routines
------------------------------------
-------------------------------------------------------------------------
-- PROCEDURE enable_debug
--
-- Parameters
--	None
--		OR
--	debug_dir	Directory where the debug file will reside
--	debug_file	Filename of debug file.
--
-- Description
--	If you are calling this routine from a PL/SQL concurrent program
--	then you should call the version with no parameters. This will
--	automatically route all of your debug statements to the log file.
--	If you are calling this routine from a PL/SQL package called from
--	within SQL*Plus, you must specify the directory and file name
--	of the debug file. NOTE: the database must have write permission.
--	(Such as /sqlcom/log).
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure enable_debug;
procedure enable_debug(debug_dir in varchar2, debug_file in varchar2);
procedure enable_debug(bufsize in number);

-------------------------------------------------------------------------
-- PROCEDURE disable_debug
--
-- Parameters
--	None
--
-- Description
--	Stop debugging
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure disable_debug;

-------------------------------------------------------------------------
-- PROCEDURE debug_enabled
--
-- Parameters
--	None
--
-- Returns
--	Boolean		Returns true if debugging is enabled.
--
-- Description
--	Checks to see if debugging is enabled. Call this function
--	if you want to have a block of code run only if debugging
--	is enabled.
--	If you have a whole bunch of debug() calls in succession,
--	then it is preferable if you first check to see if debuggin
--	is enabled.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
function debug_enabled return boolean;

-------------------------------------------------------------------------
-- PROCEDURE debug
--
-- Parameters
--	msg	String to be logged to the debug file
--
-- Description
--	Send debug message to the debug (log) file.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure debug(msg in varchar2);


-------------------------------------------------------------------------
-- PROCEDURE enable_trace, disable_trace
--
-- Parameters
--	None
--
-- Description
--	Enable and disable SQL Tracing
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure enable_trace;
procedure disable_trace;

end fa_rx_util_pkg;

/
