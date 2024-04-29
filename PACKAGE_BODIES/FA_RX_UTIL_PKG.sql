--------------------------------------------------------
--  DDL for Package Body FA_RX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_UTIL_PKG" as
/* $Header: FARXUTLB.pls 120.10.12010000.2 2009/07/19 11:45:14 glchen ship $ */


------------------------------------------------------------
-- Package types and global variables
------------------------------------------------------------

--
-- Values for <<WHO Columns>>
--
Request_Id number;
User_Id number;
Login_Id number;
Today date;

CURSOR_COLUMN_VALUES integer; --* bug#3266462, rravunny
--
Initialization_Required boolean := true;
Run_Report_At_Proc varchar2(70) := null;

-- Debug flag
m_debug_flag boolean := false;
m_dbms_output boolean := false;
m_output_cursor integer := null;

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

------------------------------------
-- Private Functions
------------------------------------
-----------------------------------------------------------
--
-- FUNCTION build_select
--
-- Parameters
-- 	None
--
-- Returns
--	Varchar2	Select statement
--
-- Description
--	Builds the select statement from
-- 	Rep_Columns as well as From_Clause, Where_Clause,
--	Group_By_Clause, Having_Clause, and Order_By_Clause.
--
-- Modificaiton History
--  KMIZUTA    12-MAR-99    Created.
--
-----------------------------------------------------------
function build_select return varchar2
is
  buffer varchar2(10000);
  idx number;
begin
  IF (g_print_debug) THEN
     fa_rx_util_pkg.debug('fa_rx_util_pkg.build_select('||to_char(Num_Columns)||')+');
  END IF;

  idx := 1;
  while idx <= Num_Columns and Rep_Columns(idx).select_column_name is null loop
	idx := idx + 1;
  end loop;
  buffer := 'SELECT '||Hint_Clause||'
	'||Rep_Columns(idx).select_column_name;
  loop
    idx := idx + 1;
    exit when idx > Num_Columns;

    if Rep_Columns(idx).select_column_name is not null then
      buffer := buffer ||',
	'||Rep_Columns(idx).select_column_name;
    end if;
  end loop;

  buffer := buffer || '
FROM '||From_Clause;
  if Where_Clause is not null then buffer := buffer ||'
WHERE '||Where_Clause;
  end if;
  if Group_By_Clause is not null then buffer := buffer ||'
GROUP BY '||Group_By_Clause;
  end if;
  if Having_Clause is not null then buffer := buffer ||'
HAVING '||Having_Clause;
  end if;
  if Order_By_Clause is not null then buffer := buffer ||'
ORDER BY '||Order_By_Clause;
  end if;

 IF (g_print_debug) THEN
    fa_rx_util_pkg.debug('SELECT Statement = ');
    fa_rx_util_pkg.debug(buffer);
    fa_rx_util_pkg.debug('fa_rx_util_pkg.build_select()-');
  END IF;

  return buffer;

exception
  when no_data_found then
     IF (g_print_debug) THEN
	fa_rx_util_pkg.debug('Missing item at '||to_char(idx));
	fa_rx_util_pkg.debug('Check your calls to assign_column() and make sure that you have that index');
     END IF;

     raise;
end build_select;

-----------------------------------------------------------
--
-- FUNCTION build_insert
--
-- Parameters
-- 	None
--
-- Returns
--	Varchar2	Insert statement
--
-- Description
--	Builds the insert statement from Rep_columns.

-- Modificaiton History
--  KMIZUTA    12-MAR-99    Created.
--
-----------------------------------------------------------
function build_insert return varchar2
is
  idx number;
  buf1 varchar2(10000);
  buf2 varchar2(10000);
begin

  IF (g_print_debug) THEN
     fa_rx_util_pkg.debug('fa_rx_util_pkg.build_insert()+');
  END IF;

  idx := 1;
  while idx <= Num_Columns and Rep_Columns(idx).insert_column_name is null loop
	idx := idx + 1;
  end loop;
  buf1 := 'INSERT INTO '||Interface_Table||' (
	'||Rep_Columns(idx).insert_column_name;
  buf2 := ') VALUES (
	:b'||to_char(idx);
  loop
    idx := idx + 1;
    exit when idx > Num_Columns;

    if Rep_Columns(idx).insert_column_name is not null then
      buf1 := buf1 ||',
	 '||Rep_Columns(idx).insert_column_name;
      buf2 := buf2 ||',
	 :b'||to_char(idx);
    end if;
  end loop;
  buf1 := buf1||', request_id, created_by, creation_date, last_updated_by, last_update_date, last_update_login';
  buf2 := buf2 ||', :b_request_id, :b_user_id, :b_today, :b_user_id, :b_today, :b_login_id)';

  IF (g_print_debug) THEN
     fa_rx_util_pkg.debug('INSERT Statement = ');
     fa_rx_util_pkg.debug(buf1||buf2);
     fa_rx_util_pkg.debug('fa_rx_util_pkg.build_insert()-');
  END IF;

  return(buf1||buf2);
end build_insert;


-----------------------------------------------------------
--
-- PROCEDURE bind_insert
--
-- Parameters
-- 	p_cursor	Cursor for the parsed insert statement
--
-- Description
--	The insert statement which is returned by the above
--	function (build_insert) returns an INSERT statement
--	with bind variables for the placeholder variables.
--	This function actually binds the values.
--
-- Modificaiton History
--  KMIZUTA    12-MAR-99    Created.
--
-----------------------------------------------------------

procedure bind_insert(p_cursor in number)
is
  buffer varchar2(30000);
  idx number;
  c integer;
  rows number;
begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.bind_insert()+');
 END IF;

  buffer := 'BEGIN ';
  for idx in 1..Num_Columns loop
    if Rep_Columns(idx).insert_column_name is not null then
	buffer := buffer ||'dbms_sql.bind_variable('||to_char(p_cursor)||
				', '':b'||to_char(idx)||
				''', '||Rep_Columns(idx).placeholder_name||');
';
    end if;
  end loop;
  buffer := buffer ||' END;';

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('bind_insert: ' || buffer);
 END IF;

  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, buffer, dbms_sql.native);
  rows := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);

  dbms_sql.bind_variable(p_cursor, 'b_request_id', Request_Id);
  dbms_sql.bind_variable(p_cursor, 'b_user_id', User_Id);
  dbms_sql.bind_variable(p_cursor, 'b_login_id', Login_Id);
  dbms_sql.bind_variable(p_cursor, 'b_today', Today);

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.bind_insert()-');
 END IF;
end bind_insert;

-----------------------------------------------------------
--
-- PROCEDURE define_columns
--
-- Parameters
-- 	p_cursor	Cursor for the parsed select statement
--
-- Description
--      When using dynamic SQL with a SELECT statement,
--      the select list must be described via a call to
--      dbms_sql.define_column.
--      This procedure does this.
--
-- Modificaiton History
--  KMIZUTA    12-MAR-99    Created.
--
-----------------------------------------------------------
procedure define_columns(p_cursor in number)
is
  sel_idx   number;
  idx       number;
  c         number;
  rows      number;

  buffer    varchar2(10000);

  l_varchar varchar2(10000);
  l_number  number;
  l_date    date;

begin

  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_util_pkg.define_columns()+');
  END IF;

  sel_idx := 1;

  -- Fix for Bug #3742493.  Replace dynamic sql method which creates a
  -- string to define_column with straight define_column statements.  This
  -- removes the literals issue which could drag performance.
  for idx in 1..Num_Columns loop
     if Rep_Columns(idx).select_column_name is not null then

        if Rep_Columns(idx).column_type = 'VARCHAR2' then

           dbms_sql.define_column(
              c           => p_cursor,
              position    => sel_idx,
              column      => l_varchar,
              column_size => to_char(Rep_Columns(idx).column_length));

        elsif Rep_Columns(idx).column_type = 'NUMBER' then

           dbms_sql.define_column(
              c        => p_cursor,
              position => sel_idx,
              column   => l_number);

        elsif Rep_Columns(idx).column_type = 'DATE' then

           dbms_sql.define_column(
              c        => p_cursor,
              position => sel_idx,
              column   => l_date);
        else

           dbms_sql.define_column(
              c        => p_cursor,
              position => sel_idx,
              column   => l_number);
        end if;

        sel_idx := sel_idx + 1;
     end if;
  end loop;

/*
  buffer := 'BEGIN ';
  for idx in 1..Num_Columns loop
    if Rep_Columns(idx).select_column_name is not null then
      buffer := buffer ||'dbms_sql.define_column('||
		to_char(p_cursor)||', '||
		to_char(sel_idx)||', '||
		Rep_Columns(idx).placeholder_name;
      if Rep_Columns(idx).column_type = 'VARCHAR2' then
	  buffer := buffer ||', '||to_char(Rep_Columns(idx).column_length);
      end if;
      buffer := buffer || ');
';
      sel_idx := sel_idx + 1;
    end if;
  end loop;
  buffer := buffer || 'END;';

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('define_columns: ' || buffer);
 END IF;

  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, buffer, dbms_sql.native);
  rows := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);
*/

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.define_columns()-');
 END IF;
end define_columns;


-----------------------------------------------------------
--
-- PROCEDURE column_values
--
-- Parameters
-- 	p_cursor	Cursor for the parsed select statement
--
-- Description
--      When using dynamic SQL with a SELECT statement,
--      the values from the select list must be retrieved using
--      dbms_sql.column_value.
--      This procedure does this.
--
-- Modificaiton History
--  KMIZUTA    12-MAR-99    Created.
--
-----------------------------------------------------------
procedure column_values(p_cursor in number)
is
  sel_idx number;
  idx number;
  c integer default cursor_column_values; --* bug#3266462, rravunny
  rows number;

  buffer varchar2(10000);
begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.column_values()+');
 END IF;

  sel_idx := 1;
  buffer := 'BEGIN ';
  for idx in 1..Num_Columns loop
    if Rep_Columns(idx).select_column_name is not null then
      buffer := buffer ||'dbms_sql.column_value('||
		to_char(p_cursor)||','||
		to_char(sel_idx)||','||
		Rep_Columns(idx).placeholder_name||');
';
      sel_idx := sel_idx + 1;
    end if;
  end loop;
  buffer := buffer || 'END;';

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('column_values: ' || buffer);
 END IF;

  --* bug#3266462, rravunny
  If c is null then
	fa_rx_util_pkg.debug('cursor cursor_column_values/ c is defined for first time');
	c := dbms_sql.open_cursor;
	dbms_sql.parse(c, buffer, dbms_sql.native);
  else
  	fa_rx_util_pkg.debug('cursor cursor_column_values/ c is already defined');
  End If;
  rows := dbms_sql.execute(c);
  --* bug#3266462, rravunny dbms_sql.close_cursor(c);

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.column_values()-');
 END IF;
 cursor_column_values := c; --* bug#3266462, rravunny
end column_values;

------------------------------------
-- Public Functions/Procedures
------------------------------------

-------------------------------------------------------------------------
--
-- PROCEDURE init_request
--
-- Parameters
--		p_request_id	Request ID of this concurrent request.
--
-- Description
--   This function initializes some of the parameters needed by RX.
--   These include:
--		User_ID
--		Login_ID
--		Today's Date <-- All three used in <WHO Columns>
--		Interface Table name <-- retrieved using p_request_id
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
		p_interface_table in varchar2 default null)
is
begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.init_request('||to_char(p_request_id)||')+');
 END IF;

  --
  -- If Initialization has already occurred, then exit
  if not Initialization_Required then return;
  end if;
  Initialization_Required := false;

  --
  -- This is the procedure that will actually run the report.
  Run_Report_At_Proc := p_calling_proc;
  Num_Sections := 0;
  Num_Columns := 0;
  From_Clause := null;
  Where_Clause := null;
  Group_By_Clause := null;
  Having_Clause := null;
  Order_By_Clause := null;
  User_Id := fnd_global.user_id;
  Login_Id := fnd_global.login_id;
  Today := sysdate;

  if p_request_id = 0 then
	--
	-- This is a debugging request
	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('init_request: ' || 'Running from SQL*Plus');
		fa_rx_util_pkg.debug('fa_rx_util_pkg.init_request(DEBUG)-');
	END IF;
  elsif p_interface_table is not null then
	Interface_Table := p_interface_table;
  else
	--
	-- Get the interface table name
  	select
	  rx.interface_table
	into
	  Interface_Table
	from
	  fnd_concurrent_requests r,
	  fa_rx_reports rx
	where
	  r.request_id = p_request_id and
	  r.program_application_id = rx.application_id and
	  r.concurrent_program_id = rx.concurrent_program_id;
  end if;

  Request_Id := p_request_id;

  --
  -- Delete rows with the same request id in the interface table
  -- NOTE: There should not be any rows here to delete except during debugging when
  --       request id 0 is used multiple times.
  declare
    c integer;
    rows integer;
  begin
    c := dbms_sql.open_cursor;
--*    bug#3207863, rravunny dbms_sql.parse(c, 'delete from '||Interface_Table||' where request_id = '||to_char(p_request_id), dbms_sql.native);
    dbms_sql.parse(c, 'delete from '||Interface_Table||' where request_id = :request_id', dbms_sql.native); --*    bug#3207863, rravunny
    DBMS_SQL.BIND_VARIABLE(c,':request_id',p_request_id); --*    bug#3207863, rravunny
    rows := dbms_sql.execute(c);

   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('init_request: ' || to_char(dbms_sql.last_row_count)||' row(s) deleted from table '||Interface_Table);
   END IF;
    dbms_sql.close_cursor(c);
  end;

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('init_request: ' || 'Using RX Interface Table = '||Interface_Table);
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.init_request()-');
 END IF;
exception
  when no_data_found then
   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('init_request: ' || 'No RX request with request id = '||to_char(p_request_id)||' found!');
   	fa_rx_util_pkg.debug('fa_rx_util_pkg.init_request(NO_DATA_FOUND)-');
   END IF;
end init_request;



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
--	2) Calls fa_rx_util_pkg.enable_debug
--	   Enable debugging for these routines
--	3) Calls fa_rx_util_pkg.init_debug
--	   Initialize these routines
--	4) Calls your RX report
--
-- Modification History
--  KMIZUTA    12-MAR-99	Created.
--
-------------------------------------------------------------------------
procedure init_debug(p_interface_table in varchar2)
is
begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.init_debug()+');
 	fa_rx_util_pkg.debug('init_debug: ' || 'This initialization routine should only be called during debugging sessions from SQL*Plus!');
 END IF;

  Interface_Table := p_interface_table;
  Request_Id := 0;

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('init_debug: ' || 'Using RX Interface Table = '||Interface_Table);
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.init_debug()-');
 END IF;
end init_debug;



-------------------------------------------------------------------------
--
-- PROCEDURE assign_column
--
-- Parameters
--	p_index		Position in report column table.
--			This is sort of like the primary key. Plug-ins
--			will be able to override what you specify
--			here using this index number.
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
			p_column_length in number default null)
is
  l_index number;

  function Find_Column_Index(pk in varchar2) return number
  is
    found_idx number;
  begin
    found_idx := null;
    for idx in 1..Num_Columns loop
      if Rep_Columns(idx).primary_key = pk then
	found_idx := idx;
	exit;
      end if;
    end loop;

    if found_idx is null then
      Num_Columns := Num_Columns + 1;
      found_idx := Num_Columns;
      Rep_Columns(found_idx).primary_key := pk;
    end if;

    return found_idx;
  end Find_Column_Index;

begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.assign_column('||
			p_key||','||
			p_select_column_name||','||
			p_insert_column_name||','||
			p_placeholder_name||','||
			p_column_type||'('||to_char(p_column_length)||'))+');
 END IF;

  if p_placeholder_name is null then
	log('Placeholder name must not be NULL.');
	app_exception.raise_exception;
  end if;
  if p_column_type not in ('VARCHAR2', 'DATE', 'NUMBER') then
	log('Unknown column type = '||p_column_type);
	app_exception.raise_exception;
  end if;
  if p_column_type = 'VARCHAR2' and p_column_length is null then
	log('Length must be specified for columns of type VARCHAR2');
	app_exception.raise_exception;
  end if;

  l_index := Find_Column_Index(p_key);

  Rep_Columns(l_index).select_column_name := p_select_column_name;
  Rep_Columns(l_index).insert_column_name := p_insert_column_name;
  Rep_Columns(l_index).placeholder_name := p_placeholder_name;
  Rep_Columns(l_index).column_type := p_column_type;
  Rep_Columns(l_index).column_length := p_column_length;

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.assign_column()-');
 END IF;
end assign_column;



-------------------------------------------------------------------------
--
-- PROCEDURE assign_report
--
-- Parameters
--	p_section_number	Your report may have multiple sections
--				where each section has a different
--				SELECT statement. You can have this model
--				run through each of your SELECT statements
--				in separate sections. Specify your section
--				number here.
--	p_before_report
--	p_bind
--	p_after_fetch
--	p_after_report		These are the event triggers. Specify the
--				name of your procedure that you would
--				like to have called in each event. Make
--				sure to fully specify the procedure name
--				(i.e., add package name).
--
--	p_before_report_process_level
--	p_bind_process_level
--	p_after_fetch_process_level
--	p_after_report_process_level
--				This tells this function how to process
--				the new event block. Should your block
--				run before/after/replace the current
--				block assigned to that event.
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
--	This may not really be necessary in most cases, but it is
--	here for you to do any cleaning up before exiting from the report.
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
			p_after_report in varchar2)
is
  l_section_number number;

  function Find_Report_Index(pk in varchar2) return number
  is
    l_index number;
  begin
    l_index := null;
    for idx in 1..nvl(Num_Sections,0) loop
      if Report(idx).section_name = pk then
	l_index := idx;
	exit;
      end if;
    end loop;

    if l_index is null then
      l_index := nvl(Num_Sections,0)+1;
      Report(l_index).section_name := pk;
      Report(l_index).enabled := false;
      Report(l_index).before_report := null;
      Report(l_index).bind := null;
      Report(l_index).after_fetch := null;
      Report(l_index).after_report := null;
    end if;

    Num_Sections := greatest(nvl(Num_Sections,0), l_index);

    return l_index;
  end Find_Report_Index;

begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.assign_report()+');
 END IF;

  l_section_number := Find_Report_Index(p_section_name);

  Report(l_section_number).enabled := p_enabled;

  Report(l_section_number).before_report :=
			Report(l_section_number).before_report || p_before_report;
  Report(l_section_number).bind :=
			Report(l_section_number).bind || p_bind;
  Report(l_section_number).after_fetch :=
			Report(l_section_number).after_fetch || p_after_fetch;
  Report(l_section_number).after_report :=
			Report(l_section_number).after_report || p_after_report;


 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.assign_report('||to_char(l_section_number)||')-');
 END IF;
end assign_report;



-------------------------------------------------------------------------
--
-- PROCEDURE run_report
--
-- Parameters
--	None
--
-- Description
--	This is the procedure which actually runs your report. The logic
--	flow that is described above (in assign_report), is actually
--	performed by this procedure. Make sure to call this procedure
--	only after you have called init_request (or init_debug) and
--	assign_report.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
procedure run_report(p_calling_proc in varchar2, retcode out nocopy number, errbuf out varchar2)
is
  l_user_id number;
  l_login_id number;
  l_today date;

  idx number;
  rows number;

  cursor_select integer;
  cursor_insert integer;
  cursor_before_report integer;
  cursor_bind integer;
  cursor_after_fetch integer;
  cursor_after_report integer;

begin
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.run_report()+');
 END IF;

  retcode := 0;
  errbuf := null;

  if not p_calling_proc = Run_Report_At_Proc then
	return; -- Don't run the report yet.
  end if;
  Initialization_Required := true;

  for idx in 1..Num_Sections loop
    Current_Section := Report(idx).section_name;
   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || 'Current section = '||current_Section);
   END IF;

    if not Report(idx).enabled then
	goto next_section;
    end if;

    -- Before calling the before report trigger
    -- reset the select/insert list. This will be initialized within
    -- the before report trigger itself.
    Num_Columns := 0;
    From_Clause := null;
    Where_Clause := null;
    Group_By_Clause := null;
    Having_Clause := null;
    Order_By_Clause := null;

    -- Before Report Trigger
   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || 'Before Report = '''||Report(idx).before_report||'''');
   END IF;
    if Report(idx).before_report is not null then
      cursor_before_report := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_before_report,
		'BEGIN '||Report(idx).before_report||' END;',
		dbms_sql.native);
      rows := dbms_sql.execute(cursor_before_report);
      dbms_sql.close_cursor(cursor_before_report);
    end if;


    -- Fetch
    cursor_select := dbms_sql.open_cursor;
    dbms_sql.parse(cursor_select,
			build_select,
			dbms_sql.native);
    if Report(idx).bind is not null then
    -- Bind variables in the select statement
     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('run_report: ' || ' Bind...');
     	fa_rx_util_pkg.debug('run_report: ' || Report(idx).bind);
     END IF;
      cursor_bind := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_bind,
			'BEGIN '||Report(idx).bind||' END;',
			dbms_sql.native);
      dbms_sql.bind_variable(cursor_bind,
				':CURSOR_SELECT',
				cursor_select);
      rows := dbms_sql.execute(cursor_bind);
      dbms_sql.close_cursor(cursor_bind);
    end if; -- of Bind
    define_columns(cursor_select);

   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || 'Executing SELECT statement');
   END IF;
    rows := dbms_sql.execute(cursor_select);

   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || 'Building INSERT');
   END IF;
    cursor_insert := dbms_sql.open_cursor;
    dbms_sql.parse(cursor_insert, build_insert, dbms_sql.native);

   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || 'After Fetch Initialization');
   END IF;
    if Report(idx).after_fetch is not null then
      cursor_after_fetch := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_after_fetch,
		'BEGIN '||Report(idx).after_fetch||' END;',
		dbms_sql.native);
    else
      cursor_after_fetch := null;
    end if;

    loop
	rows := dbms_sql.fetch_rows(cursor_select);
	exit when rows < 1;

	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('run_report: ' || 'Get values ');
	END IF;
	column_values(cursor_select);

	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('run_report: ' || 'After Fetch');
	END IF;
	if cursor_after_fetch is not null then
	  rows := dbms_sql.execute(cursor_after_fetch);
	end if;

	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('run_report: ' || 'Insert Row');
	END IF;
        bind_insert(cursor_insert);
        rows := dbms_sql.execute(cursor_insert);
    end loop; -- Fetch
    if cursor_after_fetch is not null then
      dbms_sql.close_cursor(cursor_after_fetch);
    end if;
    dbms_sql.close_cursor(cursor_insert);
    dbms_sql.close_cursor(cursor_select);
    if cursor_column_values is not null then
	dbms_sql.close_cursor(cursor_column_values);
    end if;

    -- After Report Trigger
   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('run_report: ' || ' After Report Trigger, Pass #'||to_char(idx));
   END IF;
    if Report(idx).after_report is not null then
      cursor_after_report := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_after_report,
		'BEGIN '||Report(idx).after_report||' END;',
		dbms_sql.native);
      rows := dbms_sql.execute(cursor_after_report);
      dbms_sql.close_cursor(cursor_after_report);
    end if;

  <<next_section>>
    null;
  end loop;

 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.run_report()-');
 END IF;
exception
when others then
 IF (g_print_debug) THEN
 	fa_rx_util_pkg.debug('run_report: ' || sqlerrm);
 	fa_rx_util_pkg.debug('fa_rx_util_pkg.run_report(EXCEPTION)-');
 END IF;

  retcode := 2; -- Error
  errbuf := sqlerrm;
end run_report;


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
procedure enable_debug
is
begin
  m_debug_flag := true;
 fa_rx_util_pkg.debug('Enabling debug...');
end enable_debug;

procedure enable_debug(debug_dir in varchar2, debug_file in varchar2)
is
begin
  fnd_file.put_names(debug_file||'.log', debug_file||'.out', debug_dir);
  enable_debug;
end enable_debug;

procedure enable_debug(bufsize in number)
is
  sqlstmt varchar2(100);
  rows number;
begin
  enable_debug;
  if not m_dbms_output then
    m_dbms_output := true;
    m_output_cursor := dbms_sql.open_cursor;
    sqlstmt := 'begin dbms_'||'output.enable(:b_size); end;';
    dbms_sql.parse(m_output_cursor, sqlstmt, dbms_sql.native);
    dbms_sql.bind_variable(m_output_cursor, 'b_size', bufsize);
    rows := dbms_sql.execute(m_output_cursor);
    dbms_sql.close_cursor(m_output_cursor);

    m_output_cursor := dbms_sql.open_cursor;
    sqlstmt := 'begin dbms_'||'output.put_line(:b_msg); end;';
    dbms_sql.parse(m_output_cursor, sqlstmt, dbms_sql.native);

--    dbms_output.enable(bufsize);
  end if;
end enable_debug;

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
procedure disable_debug
is
begin
 fa_rx_util_pkg.debug('Disabling debug...');
  if Request_Id = 0 then
    fnd_file.close;
  end if;
  m_debug_flag := false;
  if m_dbms_output then
    m_dbms_output := false;
    dbms_sql.close_cursor(m_output_cursor);
  end if;
end disable_debug;

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
--	If you have a whole bunch offa_rx_util_pkg.debug() calls in succession,
--	then it is preferable if you first check to see if debuggin
--	is enabled.
--
-- Modification History
--  KMIZUTA    12-MAR-99      Created.
--
-------------------------------------------------------------------------
function debug_enabled return boolean
is
begin
  return m_debug_flag;
end debug_enabled;

PROCEDURE dbms_log(msg IN VARCHAR2)
  IS
     maxidx NUMBER;
     rows NUMBER;
BEGIN
    maxidx := trunc(lengthb(msg)/255);
    for idx in 0..maxidx loop

      dbms_sql.bind_variable(m_output_cursor, 'b_msg', substrb(msg,idx*255+1,255));
      rows := dbms_sql.execute(m_output_cursor);
--      dbms_output.put_line(substrb(msg,idx*255+1,255));
    end loop;
END dbms_log;

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
procedure debug(msg in varchar2)
is
  idx number;
  maxidx number;
  rows number;
begin
  if not m_debug_flag then return;
  end if;

  if not m_dbms_output then
    fnd_file.put_line(fnd_file.log,msg);
  else
     dbms_log(msg);
  end if;

exception
when others then
  begin
    fnd_file.put_line(fnd_file.log, '**** Exception occurred while outputing to file...');
  exception when others then null;
  end;
end debug;


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
procedure log(msg in varchar2)
is
begin
  if not m_dbms_output then
    fnd_file.put_line(fnd_file.log,msg);
  else
    dbms_log(msg);
  end if;

exception
when others then
  begin
    fnd_file.put_line(fnd_file.log, '**** Exception occurred while outputing to file...');
  exception when others then null;
  end;
end log;

procedure out(msg in varchar2)
is
begin
  if not m_dbms_output then
    fnd_file.put_line(fnd_file.output,msg);
  else
    dbms_log(msg);
  end if;

exception
when others then
  begin
    fnd_file.put_line(fnd_file.log, '**** Exception occurred while outputing to file...');
  exception when others then null;
  end;
end out;


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
procedure enable_trace
is
begin
  --* bug#3344455, rravunny dbms_session.set_sql_trace(true);
  Null;
end enable_trace;


procedure disable_trace
is
begin
  --* bug#3344455, rravunny dbms_session.set_sql_trace(false);
  Null;
end disable_trace;

end fa_rx_util_pkg;

/
