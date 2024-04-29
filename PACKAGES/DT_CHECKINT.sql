--------------------------------------------------------
--  DDL for Package DT_CHECKINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_CHECKINT" AUTHID CURRENT_USER as
/* $Header: dtchkint.pkh 115.1 99/07/16 23:59:52 porting ship $ */

  --
  -- PUBLIC VARIABLES
  -- Exceptions
  -- Exception Pragmas
  --
  -- PUBLIC FUNCTIONS
  --

  -- Name
  --  set_options
  -- Purpose
  --  Allows default preferences to be overwritten
  -- Arguments
  --  p_schema		-- The schema which owns the tables to be checked
  --  p_output_dest     -- Set to DBMS_OUTPUT or DBMS_PIPE
  --
  procedure set_options ( p_schema       in varchar2,
		          p_output_dest  in varchar2 default 'DBMS_OUTPUT' ) ;

  -- Name
  --  check_table
  -- Purpose
  --  Checks a number of datetrack integrity rules for a given table
  --
  --  If an error is found the details of the current row are output.
  --  An error count threshold can be specified after which the routine
  --  will stop
  --
  -- Notes
  --  Will only work for datetrack tables which have a primary key
  --  Comprising of an id column + effective_start_date + effective_end_date
  --  The table must also have the standard who columns
  --  See the procedure check_all_tables for the tables which do not conform
  --  to this.
  -- Bugs
  --  The routine does not stop at the moment. p_max_errors has no
  --  effect.
  --  Will raise an exception if the table can not be found.
  procedure check_table ( p_table_name   in varchar2 ,
			  p_max_errors   in number   default 1 ) ;

  -- Name
  --  check_all_tables
  -- Purpose
  --  Checks All Datetracked tables for basic datetrack rules
  procedure check_all_tables ;

end dt_checkint ;

 

/
