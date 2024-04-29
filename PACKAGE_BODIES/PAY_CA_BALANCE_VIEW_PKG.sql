--------------------------------------------------------
--  DDL for Package Body PAY_CA_BALANCE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_BALANCE_VIEW_PKG" AS
/* $Header: pycabalv.pkb 115.4 2004/02/17 03:47:35 sdahiya noship $ */


--------- TExt from US Tax balance Package-------------------------------------

-- BHOMAN todo
bh_bal_error EXCEPTION;


--------------------------------------------------------------------------------
-- PROCEDURE debug_init
--------------------------------------------------------------------------------
PROCEDURE debug_init
IS
BEGIN
        DebugOn := FALSE;
        DebugLineCount := 0;
        DebugLineMax := 50000;
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_msg
--------------------------------------------------------------------------------
PROCEDURE debug_msg( p_debug_message IN VARCHAR2 )
IS
BEGIN
  if DebugOn then
    DebugList(DebugLineCount) := to_char(sysdate, 'DDMONHH24:MI:SS: ')                                            || rtrim(p_debug_message);
    DebugLineCount := DebugLineCount + 1;

    if DebugLineCount > DebugLineMax then
                        debug_wrap;
    end if;
  end if;
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_err
--------------------------------------------------------------------------------
PROCEDURE debug_err( p_debug_message IN VARCHAR2 )
IS
BEGIN
        if DebugOn then
                debug_msg('***ERROR: ' || p_debug_message);
        end if;
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_wrap
--------------------------------------------------------------------------------
PROCEDURE debug_wrap
IS
        l_new_start NUMBER;
        l_source_line NUMBER;
        l_dest_line NUMBER;
        l_last_line NUMBER;
BEGIN
        -- BHOMAN todo:  wrap by moving last xxx lines down,
        -- for now, just leave lines allocated, but start
        -- count over.
        l_last_line := DebugLineCount - 1;
        DebugLineCount := 0;
        debug_msg('debug list wrapped!');

        if DebugLineCount < 20 then
                return;
        end if;

        l_new_start := round(((l_last_line + 5) / 2), 0);
        l_dest_line := 0;

        for l_source_line in l_new_start .. l_last_line LOOP

                DebugList(l_dest_line) := DebugList(l_source_line);
                l_dest_line := l_dest_line + 1;

        end LOOP;

END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_reset
--------------------------------------------------------------------------------
PROCEDURE debug_reset
IS
BEGIN
        -- just leave lines allocated, but start count over.
        DebugLineCount := 0;
        debug_msg('debug list reset!');
        if DebugOn then
                hr_utility.trace('  Debug is currently on');
        else
                hr_utility.trace('  Debug is currently off');
        end if;

END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_dump
--------------------------------------------------------------------------------
PROCEDURE debug_dump(p_start_line IN NUMBER,
                                                        p_end_line IN NUMBER)
IS
        l_start_line NUMBER;
        l_end_line NUMBER;
        l_tmp_line VARCHAR2(120);
BEGIN

        hr_utility.trace('');
        hr_utility.trace('');
        if DebugLineCount = 0 then
                hr_utility.trace('DEBUG DUMP:  no lines to dump');
                if DebugOn then
                        hr_utility.trace('  Debug is currently on');
                else
                        hr_utility.trace('  Debug is currently off');
                end if;
                hr_utility.trace('');
                hr_utility.trace('');
                return;
        end if;

        l_start_line := p_start_line;
        l_end_line := p_end_line;

        if l_start_line < 0 then
                l_start_line := 0;
                hr_utility.trace('start line negative: ' ||
                                p_start_line || ', using 0.');
        end if;

        if l_start_line > DebugLineCount then
                l_start_line := 0;
                hr_utility.trace('start line too high: ' ||
                                p_start_line || ', using 0.');
        end if;

        if l_end_line >= DebugLineCount then
                l_end_line := (DebugLineCount - 1);
                hr_utility.trace('end line too high: ' ||
                                p_end_line || ', using end of list: ' ||
                                l_end_line);
        end if;

        if l_end_line < l_start_line then
                l_end_line := (l_start_line + 1);
                hr_utility.trace('end line lower than start line: ' ||
                                                                        p_end_line ||
                                                                        ', using start line + 1: ' ||
                                                                        l_end_line);
        end if;

        hr_utility.trace('DEBUG DUMP:  lines: ' ||
                                                                l_start_line    ||
                                                                ' to '  ||
                                                                l_end_line);
        if DebugOn then
                hr_utility.trace('  Debug is currently on');
        else
                hr_utility.trace('  Debug is currently off');
        end if;

        FOR l_current_line in l_start_line .. l_end_line LOOP
                begin
                        l_tmp_line := DebugList(l_current_line);
                        hr_utility.trace(l_current_line ||
                                                                        ': ' ||
                                                                        rtrim(l_tmp_line));
                exception
        when no_data_found then
                                hr_utility.trace('Error retrieving debug line!');
                                return;
                end;
        END LOOP;

        hr_utility.trace('');
        hr_utility.trace('');
        hr_utility.trace('END OF DEBUG DUMP');
        hr_utility.trace('');
        hr_utility.trace('');

END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_dump
--------------------------------------------------------------------------------
PROCEDURE debug_dump
IS
BEGIN
        if DebugLineCount <= 0 then
                debug_dump(0, 0);
        end if;
        debug_dump(0, (DebugLineCount - 1));
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_dump_like
--------------------------------------------------------------------------------
PROCEDURE debug_dump_like(p_string_like IN VARCHAR2)
IS
        l_start_line NUMBER;
        l_end_line NUMBER;
        l_tmp_line VARCHAR2(120);
BEGIN

        hr_utility.trace('');
        hr_utility.trace('');
        if DebugLineCount = 0 then
                hr_utility.trace('DEBUG DUMP LIKE:  no lines to dump');
                if DebugOn then
                        hr_utility.trace('  Debug is currently on');
                else
                        hr_utility.trace('  Debug is currently off');
                end if;
                hr_utility.trace('');
                hr_utility.trace('');
                return;
        end if;

        l_start_line := 0;
        l_end_line := (DebugLineCount - 1);

        if l_end_line < l_start_line then
                l_end_line := (l_start_line + 1);
        end if;

        hr_utility.trace('DEBUG DUMP LINES LIKE: ' || p_string_like);
        if DebugOn then
                hr_utility.trace('  Debug is currently on');
        else
                hr_utility.trace('  Debug is currently off');
        end if;

        FOR l_current_line in l_start_line .. l_end_line LOOP
                begin
                        l_tmp_line := DebugList(l_current_line);
                        if l_tmp_line like ('%' || p_string_like || '%') then
                           hr_utility.trace(l_current_line || ': ' ||
                                            rtrim(l_tmp_line));
                        end if;
                exception
        when no_data_found then
                                hr_utility.trace('Error retrieving debug line!');
                                return;
                end;
        END LOOP;

        hr_utility.trace('');
        hr_utility.trace('');
        hr_utility.trace('END OF DEBUG DUMP LIKE');
        hr_utility.trace('');
        hr_utility.trace('');

END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_dump_err
--------------------------------------------------------------------------------
PROCEDURE debug_dump_err
IS
BEGIN
        debug_dump_like('ERR');
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_dump_to_trace
--
-- Same as debug_dump, but uses hr_utility.trace.
--
-- p_trace_id is passed to hr_utility.trace_on, see pyutilty.pkb
-- for description of this parameter.
--
--------------------------------------------------------------------------------
PROCEDURE debug_dump_to_trace(p_trace_id IN VARCHAR2 DEFAULT NULL)
IS
        l_start_line NUMBER;
        l_end_line NUMBER;
        l_tmp_line VARCHAR2(120);
        l_existing_trace_id VARCHAR2(32);
BEGIN

        -- only trace if there are debug lines
        if DebugLineCount = 0 then
                debug_msg('DEBUG TRACE:  no lines to trace');
                if DebugOn then
                        debug_msg('  Debug is currently on');
                else
                        debug_msg('  Debug is currently off');
                end if;
                return;
        end if;

        if DebugLineCount < 0 then
                debug_msg('  Invalid debug lines, caanot trace');
                return;
        end if;

        -- see if trace is already on, null trace ID means no
        l_existing_trace_id := hr_utility.get_trace_id;

        -- turn on trace (if not already on)
        if l_existing_trace_id is NULL then
                hr_utility.trace_on(NULL, p_trace_id);
        end if;

        hr_utility.trace('======================================');
        hr_utility.trace('BALANCE VIEW DEBUG LINES');

        l_start_line := 0;
        l_end_line := (DebugLineCount - 1);

        hr_utility.trace('DEBUG DUMP:  lines: ' ||
                                                                l_start_line    ||
                                                                ' to '  ||
                                                                l_end_line);
        if DebugOn then
                hr_utility.trace('  Debug is currently on');
        else
                hr_utility.trace('  Debug is currently off');
        end if;

        FOR l_current_line in l_start_line .. l_end_line LOOP
                begin
                        l_tmp_line := DebugList(l_current_line);
                        hr_utility.trace(l_current_line ||
                                                                        ': ' ||
                                                                        rtrim(l_tmp_line));
                exception
        when no_data_found then
                                hr_utility.trace('Error retrieving debug line!');
                                -- turn off trace, but only if *we* turned it on
                                if l_existing_trace_id is not NULL then
                                        hr_utility.trace_off;
                                end if;
                                return;
                end;
        END LOOP;

        hr_utility.trace(' ');
        hr_utility.trace(' ');
        hr_utility.trace('END OF BALANCE VIEW DEBUG LINES');
        hr_utility.trace('=========================================');

        -- turn the trace back off, if it was not already on
        if l_existing_trace_id is NULL then
                hr_utility.trace_off;
        end if;

END;

--------------------------------------------------------------------------------
-- FUNCTION debug_get_line
--------------------------------------------------------------------------------
FUNCTION debug_get_line
        (p_line_number IN NUMBER)
return VARCHAR2 IS
        l_tmp_line VARCHAR2(120);
BEGIN
        if p_line_number < 0 then
                return NULL;
        end if;
        if p_line_number >= DebugLineCount then
                return NULL;
        end if;

        begin
                l_tmp_line := DebugList(p_line_number);
                return l_tmp_line;
        exception
      when no_data_found then
                        hr_utility.trace('Error retrieving debug line!');
                        return NULL;
        end;
END;

--------------------------------------------------------------------------------
-- FUNCTION debug_get_count
--------------------------------------------------------------------------------
FUNCTION debug_get_count
return NUMBER IS
BEGIN
        return DebugLineCount;
END;
--------------------------------------------------------------------------------
-- PROCEDURE debug_set_max
--------------------------------------------------------------------------------
PROCEDURE debug_set_max( p_max IN NUMBER)
IS
BEGIN
        if p_max <= 0 then
        debug_err( '******** DEBUG MAX TOO LOW: ' ||
                                                DebugLineMax    ||
                                                ' using default of 50000');
                DebugLineMax := 50000;
        else
                DebugLineMax := p_max;
        end if;
   debug_msg( '******** DEBUG MAX SET TO ' || DebugLineMax);
END;

-- BHOMAN - moved debug_msg def above debug_toggle def
--------------------------------------------------------------------------------
-- PROCEDURE debug_toggle
--------------------------------------------------------------------------------
PROCEDURE debug_toggle
IS
BEGIN
  if DebugOn then
    debug_msg( '******** DEBUGGING STOPPED ***********' );
  end if;
  DebugOn := not DebugOn;
  if DebugOn then
    debug_msg( '******** DEBUGGING STARTED ***********' );
  end if;
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_on
--------------------------------------------------------------------------------
PROCEDURE debug_on
IS
BEGIN
  DebugOn := TRUE;
  debug_msg( '******** DEBUGGING STARTED ***********' );
END;

--------------------------------------------------------------------------------
-- PROCEDURE debug_off
--------------------------------------------------------------------------------
PROCEDURE debug_off
IS
BEGIN
  if DebugOn then
    debug_msg( '******** DEBUGGING STOPPED ***********' );
  end if;
  DebugOn := FALSE;
END;

--------------------------------------------------------------------------------
-- SESSION VARIABLE FUNCTIONS
--------------------------------------------------------------------------------
--
-- The following functions use the PLSQL index by tables:
-- SessionVarNames, table of VARCHAR2(64); and SessionVarValues,
-- also index by table of VARCHAR2(64).
--      index by VARCHAR2;

--------------------------------------------------------------------------------
-- The Functions get and set session_var force the name parameter to upper case
-- before storing in, or searching the table.  The value is not converted.
--
--------------------------------------------------------------------------------
-- FUNCTION get_session_var
--
-- get_session_var performs a (dumb) linear search of the names table for
-- p_name.   If found, it returns the value from the values table at the
-- corresponding index.   This dumb method should be performant for small
-- amounts of variables (< 100 ?).   Larger amounts would require review
-- of alternative methods.   Of course, if PLSQL ever supports indexing
-- of PLSQL tables by VARCHAR, or other types besides BINARY INTEGER, this
-- would not be an issue.
--
-- NOTE the exception when a value is not found at the same index as
-- where a name is found.   Such an event would signal serious problems
-- with the state of the tables.   We should consider throwing an
-- HR or other exception if this ever happes.
--
-- NOTE that since we do not allow NULL values for session vars, the
-- get_session_var function can be used to test whether a var is set:
-- if it returns NULL, the var is not set.
--
FUNCTION get_session_var
        (p_name VARCHAR2)
return VARCHAR2 is
        l_temp_name VARCHAR2(150);
        l_temp_value VARCHAR2(150);
        l_loop_count NUMBER;
BEGIN

        -- no NULL names
        if p_name is NULL then
                return NULL;
        end if;

        -- check whether var tables are empty
        if SessionVarCount = 0 then
                return NULL;
        end if;

        -- force upper case name, remove leading/trailin spaces
        l_temp_name := rtrim(ltrim(upper(p_name)));

        -- search name table
        -- NOTE the level of PLSQL certified for 10.7 Apps does not support
        -- use of NEXT .. LAST attributes on PLSQL index by tables for WNDS
        -- pure code.  So we use hard coded table row count to drive our search.
        FOR l_loop_count IN 1 .. SessionVarCount LOOP
        if SessionVarNames(l_loop_count) = l_temp_name then
                        -- debug trace - found our var
                        -- use exception in case values is out of sync with names
                        -- NOTE: the level of PLSQL certified with 10.7 Apps does
                        -- not support using the exists attribute, so we must use
                        -- an exception here.
                        begin
                                l_temp_value := SessionVarValues(l_loop_count);
                exception
                when no_data_found then
                -- index not found, big problem here - should trhow exception
                --
                        return NULL;
                end;
                        return l_temp_value;
                end if;
        END LOOP;

        -- debug trace
        return NULL;
END get_session_var;

--------------------------------------------------------------------------------
-- FUNCTION get_session_var - overloaded with p_default.  Calls base
-- get_session_var; but if var is not set, returns p_default.
--
FUNCTION get_session_var
        (p_name VARCHAR2,
        p_default VARCHAR)
return VARCHAR2 is
        l_temp_value VARCHAR2(150);
BEGIN
        l_temp_value := NULL;

        -- use base function to get value
        l_temp_value := get_session_var(p_name);

        -- if NULL value, return p_default
        if l_temp_value is NULL then
                return p_default;
        end if;
END get_session_var;

--------------------------------------------------------------------------------
-- PROCEDURE set_session_var
--
-- Sets name and value in session var tables.  Converts name to upper case,
-- does *not* convert value.
--
-- The set function does not store NULL names or values.  However,
-- an attempt to set a NULL value will result in the variable of
-- that name being deleted from both the names and values tables.
--
PROCEDURE set_session_var
        (p_name IN VARCHAR2,
        p_value IN VARCHAR2)
IS
        l_temp_name VARCHAR2(150);
        l_temp_value VARCHAR2(150);
        l_loop_count NUMBER;
BEGIN
        -- no NULL names
        if p_name is NULL then
                return;
        end if;

        -- force upper case name, remove leading/trailin spaces
        l_temp_name := rtrim(ltrim(upper(p_name)));

/*
        hr_utility.trace('set session var, p_name: ' || p_name ||
                                        ', l_temp_name: ' || l_temp_name ||
                                        ', p_value: ' || p_value);
*/
        if SessionVarCount > 0 then
                -- search name table, we may already have this var
                -- NOTE the level of PLSQL certified for 10.7 Apps does not support
                -- use of NEXT .. LAST attributes on PLSQL index by tables for WNDS
                -- pure code.  So we use hard coded table row count to drive our search.
                FOR l_loop_count IN 1 .. SessionVarCount LOOP
                if SessionVarNames(l_loop_count) = l_temp_name then
                                -- debug trace - found our var
                                -- set value table row to new value
                                SessionVarValues(l_loop_count) := p_value;
                                -- and return
                                return;
                        end if;
                END LOOP;
        end if;

        -- not found in names table, make new entries
        -- debug trace - log new var count
        SessionVarCount := SessionVarCount + 1;
        SessionVarNames(SessionVarCount) := l_temp_name;
        SessionVarValues(SessionVarCount) := p_value;

END set_session_var;

--------------------------------------------------------------------------------
PROCEDURE clear_session_vars
IS
BEGIN
        -- delete tavbles by assigning empty tables.  The level of PLSQL
        -- supported with 10.7 does not support the delete attribute on
        -- whole tables.
        SessionVarNames := EmptyTable;
        SessionVarValues := EmptyTable;
        SessionVarCount := 0;
END clear_session_vars;

--------------------------------------------------------------------------------
-- FUNCTION get_view_mode
--------------------------------------------------------------------------------
FUNCTION get_view_mode
return VARCHAR2 is
BEGIN
        return balance_view_mode;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PROCEDURE set_view_mode
--------------------------------------------------------------------------------
PROCEDURE set_view_mode
        ( p_view_mode IN VARCHAR2)
IS
BEGIN
        debug_msg('===========================================');
   debug_msg('Enter set_view_mode' );
   debug_msg('  p_view_mode: ' || p_view_mode );
        -- force NULL to default 'ASG'
        if p_view_mode in ('ASG', 'PER', 'GRE') then
                balance_view_mode := p_view_mode;
        elsif p_view_mode is NULL then
        debug_msg('  NULL param, defaulting to ' || 'ASG');
                balance_view_mode := 'ASG';
        else
        debug_err('  invalid param, defaulting to ' || 'ASG');
                balance_view_mode := 'ASG';
        end if;
        return;
END;
--------------------------------------------------------------------------------
-- FUNCTION get_calc_all_timetypes_flag
--------------------------------------------------------------------------------
FUNCTION get_calc_all_timetypes_flag
return NUMBER is
BEGIN
        return CalcAllTimeTypes;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PROCEDURE set_calc_all_timetypes_flag
--------------------------------------------------------------------------------
PROCEDURE set_calc_all_timetypes_flag
        ( p_calc_all IN NUMBER)
IS
BEGIN
        debug_msg('===========================================');
   debug_msg('Enter set_calc_all_timetypes_flag' );
        if (p_calc_all <> 1) AND (p_calc_all <> 0) then
        debug_msg('  p_calc_all must be 1 or 0, defaulting to 0');
                CalcAllTimeTypes := 0;
        else
                CalcAllTimeTypes := p_calc_all;
        end if;
   debug_msg('  p_calc_all set to ' || to_char(CalcAllTimeTypes));
END;
--------------------------------------------------------------------------------
-- FUNCTION ALBStart_is_found
--------------------------------------------------------------------------------
function ALBStart_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val number;
begin
        begin
                l_temp_val := ALBStart(p_bindex);
   exception
      when no_data_found then
      -- index not found
      --
        return FALSE;
   end;
        return TRUE;
end;

--------------------------------------------------------------------------------
-- FUNCTION ALB2CStart_is_found
--------------------------------------------------------------------------------
function ALB2CStart_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val number;
begin
        begin
                l_temp_val := ALB2CStart(p_bindex);
        exception
        when no_data_found then
                -- index not found
                --
                return FALSE;
        end;

        return TRUE;
end;

--------------------------------------------------------------------------------
-- FUNCTION PLBStart_is_found
--------------------------------------------------------------------------------
function PLBStart_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val number;
begin
        begin
                l_temp_val := PLBStart(p_bindex);
        exception
        when no_data_found then
                -- index not found
                --
                return FALSE;
        end;

        return TRUE;
end;

--------------------------------------------------------------------------------
-- FUNCTION PLB2CStart_is_found
--------------------------------------------------------------------------------
function PLB2CStart_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val number;
begin
        begin
                l_temp_val := PLB2CStart(p_bindex);
        exception
        when no_data_found then
                -- index not found
                --
                return FALSE;
        end;

        return TRUE;
end;

--------------------------------------------------------------------------------
-- FUNCTION CtxValueByPos_is_found
--------------------------------------------------------------------------------
function CtxValueByPos_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val pay_balance_context_values.value%type;
begin
        begin
                l_temp_val := CtxValueByPos(p_bindex);
        exception
        when no_data_found then
                -- index not found
                --
                return FALSE;
        end;

        return TRUE;
end;

--------------------------------------------------------------------------------
-- FUNCTION DBCDimName_is_found
--------------------------------------------------------------------------------
function DBCDimName_is_found
        (p_bindex IN NUMBER)
return BOOLEAN is
        l_temp_val pay_balance_dimensions.dimension_name%type;
begin
        begin
                l_temp_val := DBCDimName(p_bindex);
        exception
        when no_data_found then
                -- index not found
                --
                return FALSE;
        end;

        return TRUE;
end;

--------------------------------------------------------------------------------
-- PROCEDURE clear_contexts
--------------------------------------------------------------------------------
PROCEDURE clear_contexts
IS
  l_ctxid NUMBER;
BEGIN
  --
  -- Just null out any cached context values. Keep context_id
  -- information to avoid rerunning any SQL.
  --
  -- if CtxValueByPos.exists(pos_assignment_action_id) then
  if CtxValueByPos_is_found(pos_assignment_action_id) then
    l_ctxid := CtxIdByPos(pos_assignment_action_id);
    CtxValueByPos(pos_assignment_action_id) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  -- if CtxValueByPos.exists(pos_jurisdiction_code) then
  if CtxValueByPos_is_found(pos_jurisdiction_code) then
    l_ctxid := CtxIdByPos(pos_jurisdiction_code);
    CtxValueByPos(pos_jurisdiction_code) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_tax_unit_id) then
    l_ctxid := CtxIdByPos(pos_tax_unit_id);
    CtxValueByPos(pos_tax_unit_id) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_tax_group) then
    l_ctxid := CtxIdByPos(pos_tax_group);
    CtxValueByPos(pos_tax_group) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_date_earned) then
    l_ctxid := CtxIdByPos(pos_date_earned);
    CtxValueByPos(pos_date_earned) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_balance_date) then
    l_ctxid := CtxIdByPos(pos_balance_date);
    CtxValueByPos(pos_balance_date) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_business_group_id) then
    l_ctxid := CtxIdByPos(pos_business_group_id);
    CtxValueByPos(pos_business_group_id) := null;
    CtxValueById(l_ctxid) := null;
  end if;
  --
  if CtxValueByPos_is_found(pos_source_id) then
    l_ctxid := CtxIdByPos(pos_source_id);
    CtxValueByPos(pos_source_id) := null;
    CtxValueById(l_ctxid) := null;
  end if;
END;

--------------------------------------------------------------------------------
-- PROCEDURE set_context
--------------------------------------------------------------------------------
PROCEDURE set_context
(
  p_context_name  IN VARCHAR2,
  p_context_value IN VARCHAR2
)
IS
  l_pos       NUMBER;
  l_ctxid     NUMBER;
  l_gre_table_count NUMBER;
  l_tax_group VARCHAR2(150);
  --
BEGIN
  debug_msg( '===========================================');
   debug_msg( 'Enter set_context' );
   debug_msg( 'p_context_name: ' || p_context_name );
   debug_msg( 'p_context_value: ' || p_context_value );

   l_pos := pos_invalid;

   -- Look through list of supported contexts.
   if p_context_name = 'ASSIGNMENT_ACTION_ID' then
     l_pos := pos_assignment_action_id;
   elsif p_context_name = 'JURISDICTION_CODE' then
     l_pos := pos_jurisdiction_code;
   elsif p_context_name = 'TAX_UNIT_ID' then
     l_pos := pos_tax_unit_id;
   elsif p_context_name = 'TAX_GROUP' then
     l_pos := pos_tax_group;
   elsif p_context_name = 'DATE_EARNED' then
     l_pos := pos_date_earned;
   elsif p_context_name = 'BUSINESS_GROUP_ID' then
     l_pos := pos_business_group_id;
   elsif p_context_name = 'BALANCE_DATE' then
     l_pos := pos_balance_date;
   elsif p_context_name = 'SOURCE_ID' then
     l_pos := pos_source_id;
   end if;

   debug_msg( 'l_pos = ' || l_pos );

   if l_pos <> pos_invalid then
     if CtxValueByPos_is_found(l_pos) then
       -- Use existing information.
       l_ctxid := CtxIdByPos(l_pos);
       CtxValueByPos(l_pos)     := p_context_value;
       CtxValueById(l_ctxid)    := p_context_value;
     else
       -- No existing information, so go to the database.
       begin
         select context_id
         into l_ctxid
         from ff_contexts
         where  context_name = p_context_name;
       exception
         when no_data_found then
           debug_err( 'set_context: context_name not found: '
                                                                                                                || p_context_name );
           l_ctxid := null;
       end;
       if l_ctxid is not null then
         CtxIdByPos(l_pos)              := l_ctxid;
         CtxNameByPos(l_pos)    := p_context_name;
         CtxValueByPos(l_pos)   := p_context_value;
         CtxIdById(l_ctxid)             := l_ctxid;
         CtxNameById(l_ctxid)   := p_context_name;
         CtxValueById(l_ctxid)  := p_context_value;
       end if;
     end if;

     -- Need to set the TAX_GROUP for the TAX_UNIT_ID.
     -- Added decode for Canadian Tax Group.
     if l_pos = pos_tax_unit_id then
        -- TCL check to see if a row for the tax_unit_id is stored in the
        -- session_gre_table.  If it is use it.  If not then
        --  the 'TAX_GROUP' session variable is set via the query.
        l_tax_group := null;

        if session_gre_table.count > 0 then  -- we have data in the table.
           FOR i in session_gre_table.first .. session_gre_table.last
           LOOP
              if session_gre_table(i).tax_unit_id = to_number(p_context_value)then
                 l_tax_group := session_gre_table(i).tax_group_name;
                 exit;
              end if;
           END LOOP;
        end if;

        if l_tax_group IS NULL then
           begin
               select decode(hoi_bg.org_information9,
                       'US', hoi_gre.org_information5,
                       'CA', hoi_gre.org_information4)
               into   l_tax_group
               from
                      hr_organization_information hoi_bg,   -- Business Group
                      hr_organization_information hoi_gre,  -- US or CA Context
                      hr_all_organization_units hou         -- GRE
               where  hou.organization_id = to_number(p_context_value)
               and    hoi_gre.organization_id = hou.organization_id
               and    hoi_bg.organization_id = hou.business_group_id
               and    hoi_gre.org_information_context =
                         decode(hoi_bg.org_information9,
                                'US', 'Federal Tax Rules',
                                'CA', 'Canada Employer Identification',
                                'Not Applicable')
               and hoi_bg.org_information_context =  'Business Group Information';

           exception
             when no_data_found then
                                -- BHOMAN this exception occurs with pmadore text case
                                -- raise bh_bal_error;
               l_tax_group := null;
           end;
           if l_tax_group is null then
             l_tax_group := 'No Tax Group';
           end if;
           l_gre_table_count := session_gre_table.count;
           session_gre_table(l_gre_table_count).tax_unit_id := to_number(p_context_value);
           session_gre_table(l_gre_table_count).tax_group_name := l_tax_group;

        end if;
        set_context( 'TAX_GROUP', l_tax_group );

       end if;
   end if;
   debug_msg( 'Exiting set_context' );
END set_context;

--------------------------------------------------------------------------------
-- PROCEDURE get_context
--------------------------------------------------------------------------------
FUNCTION get_context
(
  p_context_name  IN VARCHAR2
)
return VARCHAR2 is
  l_pos       NUMBER;
  l_context_value     VARCHAR2(64);
BEGIN
  debug_msg( '===========================================');
  debug_msg( 'Enter get_context' );
  debug_msg( 'p_context_name: ' || p_context_name );

   l_pos := pos_invalid;

   -- Look through list of supported contexts.
   if p_context_name = 'ASSIGNMENT_ACTION_ID' then
     l_pos := pos_assignment_action_id;
   elsif p_context_name = 'JURISDICTION_CODE' then
     l_pos := pos_jurisdiction_code;
   elsif p_context_name = 'TAX_UNIT_ID' then
     l_pos := pos_tax_unit_id;
   elsif p_context_name = 'TAX_GROUP' then
     l_pos := pos_tax_group;
   elsif p_context_name = 'DATE_EARNED' then
     l_pos := pos_date_earned;
   elsif p_context_name = 'BALANCE_DATE' then
     l_pos := pos_balance_date;
   elsif p_context_name = 'BUSINESS_GROUP_ID' then
     l_pos := pos_business_group_id;
   elsif p_context_name = 'SOURCE_ID' then
     l_pos := pos_source_id;
   end if;

   debug_msg( 'l_pos = ' || l_pos );

   if l_pos = pos_invalid then
        debug_err( 'get_context: invalid context: ' || p_context_name);
                return NULL;
        end if;


   if CtxValueByPos_is_found(l_pos) then
       -- Use existing information.
       l_context_value := CtxValueByPos(l_pos);
       debug_msg( 'l_context_value = ' || l_context_value );
       return l_context_value;
   end if;

   debug_msg( 'context ' || p_context_name || ' is not set');
        return NULL;

END get_context;

--------------------------------------------------------------------------------
-- PROCEDURE dump_context
--------------------------------------------------------------------------------
PROCEDURE dump_context
(
  p_known_name  IN VARCHAR2,
  p_pos IN NUMBER
)
IS
  l_pos       NUMBER;
  l_ctxid     NUMBER;
  --
BEGIN
        l_pos := p_pos;
        hr_utility.trace('');
        hr_utility.trace('==== CONTEXT KNOWN AS: ' || p_known_name);
   if CtxValueByPos_is_found(l_pos) then
      l_ctxid := CtxIdByPos(l_pos);
                hr_utility.trace('   context id:  ' || l_ctxid);
                hr_utility.trace('   name by pos: ' || CtxNameByPos(l_pos));
                hr_utility.trace('   val by pos:  ' || CtxValueByPos(l_pos));
                hr_utility.trace('   id  by pos:  ' || CtxIdByPos(l_pos));
                hr_utility.trace('   val by id:   ' || CtxValueById(l_ctxid));
                hr_utility.trace('   id  by id:   ' || CtxIdById(l_ctxid));
                hr_utility.trace('   name by id:  ' || CtxNameById(l_ctxid));
        else
                hr_utility.trace('   NOT SET   ');
        end if;
        hr_utility.trace('');

   debug_msg( 'Exiting dump_context' );
END dump_context;

--------------------------------------------------------------------------------
-- PROCEDURE dump_context
--------------------------------------------------------------------------------
PROCEDURE dump_context
IS
  l_pos       NUMBER;
  l_ctxid     NUMBER;
  --
BEGIN
  debug_msg( '===========================================');
   debug_msg( 'Enter dump_context' );

        dump_context('ASSIGNMENT_ACTION_ID', pos_assignment_action_id);
        dump_context('JURISDICTION_CODE', pos_jurisdiction_code);
        dump_context('TAX_UNIT_ID', pos_tax_unit_id);
        dump_context('TAX_GROUP', pos_tax_group);
        dump_context('DATE_EARNED', pos_date_earned);
        dump_context('BUSINESS_GROUP_ID', pos_business_group_id);
        dump_context('BALANCE_DATE', pos_balance_date);
        dump_context('SOURCE_ID', pos_source_id);

   debug_msg( 'Exiting dump_context' );
END dump_context;

--------------------------------------------------------------------------------
-- PROCEDURE clear_asgbal_cache
--------------------------------------------------------------------------------
PROCEDURE clear_asgbal_cache
IS
BEGIN
  MaxALBIndex := 0;

  ALBStart      := ZeroBounds;
  ALBEnd        := ZeroBounds;
  ALBLatBalId   := ZeroLatBalId;
  ALBAssActId   := ZeroAssActId;
  ALBValue      := ZeroValue;
  ALBActSeq     := ZeroActSeq;
  ALBEffDate    := ZeroEffDate;
  ALBExpAssActId := ZeroExpAssActId;
  ALBExpValue   := ZeroExpValue;
  ALBExpActSeq  := ZeroExpActSeq;
  ALBExpEffDate := ZeroExpEffDate;

  MaxALB2CIndex := 0;

  ALB2CStart    := ZeroBounds;
  ALB2CEnd      := ZeroBounds;
  ALB2CtxId     := ZeroCtxId;
  ALB2CtxName   := ZeroCtxName;
  ALB2CtxValue  := ZeroCtxValue;

  cached_assignment_id := -1;

END clear_asgbal_cache;

--------------------------------------------------------------------------------
-- PROCEDURE clear_perbal_cache
--------------------------------------------------------------------------------
PROCEDURE clear_perbal_cache
IS
BEGIN

  MaxPLBIndex := 0;

  PLBStart      := ZeroBounds;
  PLBEnd        := ZeroBounds;
  PLBLatBalId   := ZeroLatBalId;
  PLBAssActId   := ZeroAssActId;
  PLBValue      := ZeroValue;
  PLBActSeq     := ZeroActSeq;
  PLBEffDate    := ZeroEffDate;
  PLBExpAssActId := ZeroExpAssActId;
  PLBExpValue   := ZeroExpValue;
  PLBExpActSeq  := ZeroExpActSeq;
  PLBExpEffDate := ZeroExpEffDate;

  MaxPLB2CIndex := 0;

  PLB2CStart    := ZeroBounds;
  PLB2CEnd      := ZeroBounds;
  PLB2CtxId     := ZeroCtxId;
  PLB2CtxName   := ZeroCtxName;
  PLB2CtxValue  := ZeroCtxValue;

  cached_person_id := -1;
END clear_perbal_cache;

--------------------------------------------------------------------------------
-- FUNCTION get_value
-- Lowest level (and therefore most dangerous) get_value call. Don't want
-- users to call this. Provides the option not to cache latest balance values
-- (p_dont_cache <> 0), or not use latest balance values (p_always_get_dbi
-- <> 0). The p_date_mode and p_effective_date arguments are specifically
-- for calling from get_value in date mode (p_date_mode <> 0).
--------------------------------------------------------------------------------
FUNCTION get_value
(
p_assignment_action_id IN NUMBER,
p_defined_balance_id   IN NUMBER,
p_dont_cache           IN NUMBER,
p_always_get_dbi       IN NUMBER,
p_date_mode            IN NUMBER,
p_effective_date       IN DATE
)
RETURN NUMBER IS
  balance              NUMBER;
  l_assignment_id      NUMBER;
  l_person_id          NUMBER;
  l_action_sequence    NUMBER;
  l_assact_effdate     DATE;
  l_run_route          varchar2(5);
  l_run_route_bool     boolean;
  l_temp_num           number;
  --
  l_dimension_type     pay_balance_dimensions.dimension_type%type;
  l_dbi_suffix         pay_balance_dimensions.database_item_suffix%type;
  l_dimension_name     pay_balance_dimensions.dimension_name%type;
  l_balance_type_id    pay_defined_balances.balance_type_id%type;
  l_jurisdiction_level pay_balance_types.jurisdiction_level%type;
  l_leg_code           pay_balance_dimensions.legislation_code%type;

  CURSOR csr_context_exists IS
    SELECT 1
    FROM   ff_contexts cxt
    WHERE  context_name = 'SOURCE_ID';

BEGIN

  debug_msg( '===========================================');
  debug_msg( 'Entered get_value' );
  debug_msg( 'p_assignment_action_id = ' || p_assignment_action_id );
  debug_msg( 'p_defined_balance_id = ' || p_defined_balance_id );
  debug_msg( 'p_dont_cache = ' || p_dont_cache );
  debug_msg( 'p_always_get_dbi = ' || p_always_get_dbi );
  debug_msg( 'p_date_mode = ' || p_date_mode );
  debug_msg( 'p_effective_date = ' || p_effective_date );
  --
  -- Get details for this defined_balance_id.
  --
  -- BHOMAN - todo - since below changed from DBC to DBCDimName,
  -- consider whether DimName table was init'd to satisfy the exists
  -- clause
  debug_msg( 'get_value: looking in DBCache for details of defined_balance '
                                                                                                                                || p_defined_balance_id
                                                                                                                                || ' ...');

  -- check for the 'RUN_ROUTE' parameter_name in the pay_action_parameters
  -- table to determine if we want to call the run_result route instead of
  -- the run_balance route.
  begin

      select parameter_value
      into l_run_route
      from PAY_ACTION_PARAMETERS
      where parameter_name = 'RUN_ROUTE';

  exception
     WHEN others then
     l_run_route := 'FALSE';
  end;

  IF l_run_route <> 'TRUE' THEN
     l_run_route_bool := false;
  ELSE
     l_run_route_bool := true;
  END IF;


  if DBCDimName_is_found(p_defined_balance_id) then
    --
    l_dbi_suffix        := DBCDbiSuffix(p_defined_balance_id);
    l_balance_type_id   := DBCBalTypeId(p_defined_balance_id);
    l_dimension_type    := DBCDimType(p_defined_balance_id);

--
-- JGOSWAMI - quick fix for Canadian Patch but needs to get l_leg_code value from cache.
--
    begin
      select pbd.legislation_code
      into   l_leg_code
      from   pay_defined_balances pdb,
             pay_balance_dimensions pbd
      where  pdb.defined_balance_id = p_defined_balance_id
      and    pbd.balance_dimension_id = pdb.balance_dimension_id;
    exception
      when no_data_found then
        -- Invalid legislation code.
        --
        l_leg_code  := null;
        debug_msg( 'No such legislation code: ' || l_leg_code );
        --
    end;

    debug_msg( 'get_value: DBCache details found for _defined_balance_id:  '
                                                                                                                                        || p_defined_balance_id);
    debug_msg( '    dbi_suffix:      ' || l_dbi_suffix);
    debug_msg( '    balance_type_id: ' || l_balance_type_id);
    debug_msg( '    dimension_type:  ' || l_dimension_type);
    debug_msg( '    l_leg_code:  ' || l_leg_code);
  else
    -- Need to go to database.
    --
    debug_msg( 'get_value: details not found in DBCache, going to database...' );
    --
    begin
      select pdb.balance_type_id,
             pbd.database_item_suffix,
             pbd.dimension_type,
             pbd.dimension_name,
             pbt.jurisdiction_level,
             pbd.legislation_code
      into   l_balance_type_id,
             l_dbi_suffix,
             l_dimension_type,
             l_dimension_name,
             l_jurisdiction_level,
             l_leg_code
      from   pay_defined_balances pdb,
             pay_balance_dimensions pbd,
             pay_balance_types pbt
      where  pdb.defined_balance_id = p_defined_balance_id
      and    pbd.balance_dimension_id = pdb.balance_dimension_id
      and    pbt.balance_type_id = pdb.balance_type_id;
    exception
      when no_data_found then
        -- Invalid defined_balance_id.
        --
        debug_msg( 'No such defined_balance_id: ' || p_defined_balance_id );
        debug_msg( 'Exit get_value' );
        --
        balance := null;
        return balance;
    end;

    -- Update the Defined Balance Cache.
    DBCBalTypeId(p_defined_balance_id)  := l_balance_type_id;
    DBCJurisLvl(p_defined_balance_id)   := l_jurisdiction_level;
    DBCDbiSuffix(p_defined_balance_id)  := l_dbi_suffix;
    DBCDimType(p_defined_balance_id)    := l_dimension_type;
    DBCDimName(p_defined_balance_id)    := l_dimension_name;
    debug_msg( 'get_value: DBCache details updated for _defined_balance_id:  '
                                                                                                                                        || p_defined_balance_id);
    debug_msg( '    balance_type_id:     ' || l_balance_type_id);
    debug_msg( '    dbi_suffix:          ' || l_dbi_suffix);
    debug_msg( '    dimension_type:      ' || l_dimension_type);
    debug_msg( '    l_dimension_name:    ' || l_dimension_name);
    debug_msg( '    jurisdiction_level:  ' || l_jurisdiction_level);
  end if;
  --
  -- set session variable for legislation code, so that when run_route is
  -- called appropriate CA or US route can be called.
  --
  set_session_var('LEG_CODE',l_leg_code);
  --
  set_context( 'ASSIGNMENT_ACTION_ID', p_assignment_action_id );
  begin
    select paa.assignment_id, paa.action_sequence, ppa.effective_date
    into   l_assignment_id, l_action_sequence, l_assact_effdate
    from   pay_assignment_actions paa,
           pay_payroll_actions ppa
    where  paa.assignment_action_id = p_assignment_action_id
    and    paa.payroll_action_id = ppa.payroll_action_id;
  exception
    when no_data_found then
      --
      debug_msg( 'Could not find assignment_action_id: ' ||
                 p_assignment_action_id );
      debug_msg( 'Exit get_value' );
      --
      return null;
  end;

  ----------------------------------------------------------------------
  -- Run the route if the caller requested it (p_always_get_dbi <> 0) or
  -- if the balance type is one of:
  -- N: not fed, not stored
  -- F: fed and not stored
  -- R: Run level
  ----------------------------------------------------------------------
  if (p_always_get_dbi <> 0) or
     (DBCDimType(p_defined_balance_id) in ( 'N', 'F', 'R' )) then
    --
    debug_msg( 'Go to route, dimension_type = ' || DBCDimType(p_defined_balance_id) );
    --
    -- balance := goto_route( p_assignment_action_id, p_defined_balance_id );

    IF CtxNameByPos(pos_balance_date) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_balance_date),
                        CtxValueByPos(pos_balance_date));
    END IF;

    IF CtxNameByPos(pos_tax_unit_id) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_unit_id),
                        CtxValueByPos(pos_tax_unit_id));
    END IF;

    IF CtxNameByPos(pos_jurisdiction_code) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_jurisdiction_code),
                        CtxValueByPos(pos_jurisdiction_code));
    END IF;

   /*
    * If the SOURCE_ID context exists but has no value set it to NULL
    */
   OPEN csr_context_exists;
   FETCH csr_context_exists INTO l_temp_num;
   IF csr_context_exists%FOUND THEN
       IF NOT CtxValueByPos_is_found(pos_source_id) THEN
          pay_balance_pkg.set_context('SOURCE_ID',
                      NULL);
        ELSE
          pay_balance_pkg.set_context(CtxNameByPos(pos_source_id),
                       CtxValueByPos(pos_source_id));

        END IF;

   END IF;
   CLOSE csr_context_exists;


    IF CtxNameByPos(pos_tax_group) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_group),
                        CtxValueByPos(pos_tax_group));
    END IF;

    IF CtxNameByPos(pos_date_earned) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_date_earned),
                        CtxValueByPos(pos_date_earned));
    END IF;


    balance := pay_balance_pkg.get_value(
                   p_defined_balance_id   => p_defined_balance_id
                  ,p_assignment_action_id => p_assignment_action_id
                  ,p_get_rr_route         => l_run_route_bool
                  ,p_get_rb_route         => FALSE);

    ----------------------------------------------------------------
    -- Need to expiry check Person and Assignment level balances, if
    -- get_value is being called in date mode.
    ----------------------------------------------------------------
    if (balance <> 0) and (p_date_mode <> 0) and
       (DBCDimType(p_defined_balance_id) in ('P', 'A')) then
      if date_expired( p_assignment_action_id, p_assignment_action_id,
                       l_assact_effdate, p_effective_date,
                       DBCDimName(p_defined_balance_id), 1) then
        balance := 0;
      end if;
    end if;

    debug_msg( 'Exit get_value, balance = ' || balance );
    return balance;
  end if;

  -------------------------------
  -- Try to get a latest balance.
  -------------------------------
  --
  debug_msg( 'Get a latest balance' );
  --
  if DBCDimType(p_defined_balance_id) = 'A' then
    debug_msg( 'Assignment latest balance' );
/*    balance := goto_asg_latest_balances( p_assignment_action_id,
                                         p_defined_balance_id,
                                         l_assignment_id,
                                         l_action_sequence,
                                         l_assact_effdate,
                                         p_dont_cache,
                                         p_date_mode,
                                         p_effective_date );
*/

    IF CtxNameByPos(pos_balance_date) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_balance_date),
                        CtxValueByPos(pos_balance_date));
    END IF;

    IF CtxNameByPos(pos_tax_unit_id) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_unit_id),
                        CtxValueByPos(pos_tax_unit_id));
    END IF;

    IF CtxNameByPos(pos_jurisdiction_code) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_jurisdiction_code),
                        CtxValueByPos(pos_jurisdiction_code));
    END IF;

   /*
    * If the SOURCE_ID context exists but has no value set it to NULL
    */
   OPEN csr_context_exists;
   FETCH csr_context_exists INTO l_temp_num;
   IF csr_context_exists%FOUND THEN
       IF NOT CtxValueByPos_is_found(pos_source_id) THEN
          pay_balance_pkg.set_context('SOURCE_ID',
                      NULL);
        ELSE
          pay_balance_pkg.set_context(CtxNameByPos(pos_source_id),
                       CtxValueByPos(pos_source_id));

        END IF;

   END IF;
   CLOSE csr_context_exists;

    IF CtxNameByPos(pos_tax_group) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_group),
                        CtxValueByPos(pos_tax_group));
    END IF;

    IF CtxNameByPos(pos_date_earned) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_date_earned),
                        CtxValueByPos(pos_date_earned));
    END IF;

    balance := pay_balance_pkg.get_value(
                   p_defined_balance_id   => p_defined_balance_id
                  ,p_assignment_action_id => p_assignment_action_id
                  ,p_get_rr_route         => l_run_route_bool
                  ,p_get_rb_route         => FALSE);


  elsif DBCDimType(p_defined_balance_id) = 'P' then
    debug_msg( 'Person latest balance' );
    --
    -- The following SQL must succeed because l_assignment_id
    -- is a valid assignment_id at this stage.
    --
/*    select distinct person_id
    into   l_person_id
    from   per_assignments_f
    where  assignment_id = l_assignment_id;
    debug_msg( 'Person id ' || l_person_id || ' for assignment id ' ||
               l_assignment_id );
    balance := goto_per_latest_balances( p_assignment_action_id,
                                         p_defined_balance_id,
                                         l_person_id,
                                         l_action_sequence,
                                         l_assact_effdate,
                                         p_dont_cache,
                                         p_date_mode,
                                         p_effective_date );
*/

    IF CtxNameByPos(pos_balance_date) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_balance_date),
                        CtxValueByPos(pos_balance_date));
    END IF;

    IF CtxNameByPos(pos_tax_unit_id) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_unit_id),
                        CtxValueByPos(pos_tax_unit_id));
    END IF;

    IF CtxNameByPos(pos_jurisdiction_code) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_jurisdiction_code),
                        CtxValueByPos(pos_jurisdiction_code));
    END IF;

   /*
    * If the SOURCE_ID context exists but has no value set it to NULL
    */
   OPEN csr_context_exists;
   FETCH csr_context_exists INTO l_temp_num;
   IF csr_context_exists%FOUND THEN
       IF NOT CtxValueByPos_is_found(pos_source_id) THEN
          pay_balance_pkg.set_context('SOURCE_ID',
                      NULL);
        ELSE
          pay_balance_pkg.set_context(CtxNameByPos(pos_source_id),
                       CtxValueByPos(pos_source_id));

        END IF;

   END IF;
   CLOSE csr_context_exists;

    IF CtxNameByPos(pos_tax_group) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_tax_group),
                        CtxValueByPos(pos_tax_group));
    END IF;

    IF CtxNameByPos(pos_date_earned) is not null then
       pay_balance_pkg.set_context(CtxNameByPos(pos_date_earned),
                        CtxValueByPos(pos_date_earned));
    END IF;

    balance := pay_balance_pkg.get_value(
                   p_defined_balance_id   => p_defined_balance_id
                  ,p_assignment_action_id => p_assignment_action_id
                  ,p_get_rr_route         => l_run_route_bool
                  ,p_get_rb_route         => FALSE);


  else
    debug_msg( 'Invalid latest balance type: ' ||
               DBCDimType(p_defined_balance_id) );
    balance := null;
  end if;

  return balance;
END;

--------------------------------------------------------------------------------
-- FUNCTION get_value
-- assignment_action mode, caller has the option of not using the latest
-- balance values (p_always_get_dbi <> 0), or not caching latest balance
-- values (p_dont_cache <> 0).
--------------------------------------------------------------------------------
FUNCTION get_value
(
  p_assignment_action_id IN NUMBER,
  p_defined_balance_id   IN NUMBER,
  p_dont_cache           IN NUMBER,
  p_always_get_dbi       IN NUMBER
)
RETURN NUMBER IS
  l_balance NUMBER;
BEGIN
  l_balance := get_value( p_assignment_action_id, p_defined_balance_id,
                          p_dont_cache, p_always_get_dbi, 0, null );
  return l_balance;
END get_value;

--------------------------------------------------------------------------------
-- FUNCTION get_value
-- assignment_action mode, uses and caches latest balance values.
--------------------------------------------------------------------------------
FUNCTION get_value
(
  p_assignment_action_id IN NUMBER,
  p_defined_balance_id   IN NUMBER
)
RETURN NUMBER IS
  l_balance NUMBER;
BEGIN
  l_balance :=
  get_value( p_assignment_action_id, p_defined_balance_id, 0, 0, 0, null );
  return l_balance;
END get_value;

--------------------------------------------------------------------------------
-- FUNCTION get_value
-- date mode, uses the latest balance values with caching.
--------------------------------------------------------------------------------
FUNCTION get_value
(
  p_assignment_id        IN NUMBER,
  p_defined_balance_id   IN NUMBER,
  p_effective_date       IN DATE
)
RETURN NUMBER IS
  l_balance NUMBER;
BEGIN
  l_balance :=
  get_value( p_assignment_id, p_defined_balance_id, p_effective_date, 0 );
  return l_balance;
END get_value;

--------------------------------------------------------------------------------
-- FUNCTION get_value
-- date mode, uses the latest balance values with the option of turning
-- caching off (p_dont_cache <> 0).
--------------------------------------------------------------------------------
FUNCTION get_value
(
  p_assignment_id        IN NUMBER,
  p_defined_balance_id   IN NUMBER,
  p_effective_date       IN DATE,
  p_dont_cache           IN NUMBER
)
RETURN NUMBER IS
  l_assignment_action_id NUMBER;
  l_balance              NUMBER;
  --
  -- Cursor for getting the latest sequenced assignment_action_id for the
  -- assignment_id and date.
  --
  CURSOR get_latest_assactid( p_assignment_id  IN NUMBER,
                              p_effective_date IN DATE ) IS
  select to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                   paa.assignment_action_id),16))
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa
  where paa.assignment_id = p_assignment_id
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.effective_date <= p_effective_date
  and   ppa.action_type in ('R', 'Q', 'I', 'V', 'B' );
BEGIN
  begin
    open get_latest_assactid( p_assignment_id, p_effective_date );
    fetch get_latest_assactid into l_assignment_action_id;
    close get_latest_assactid;
  exception
    when others then
      if get_latest_assactid%isopen then
        close get_latest_assactid;
      end if;
      raise;
  end;
  if l_assignment_action_id is null then
    debug_msg( 'get_value (date mode) did not find assignment_action_id' );
    debug_msg( '  p_assignment_id = ' || p_assignment_id );
    debug_msg( '  p_effective_date = ' || p_effective_date );
    l_balance := null;
  else
    l_balance := get_value( l_assignment_action_id, p_defined_balance_id,
                            p_dont_cache, 0, 1, p_effective_date );
  end if;
  return l_balance;
END get_value;

--------------------------------------------------------------------------------
-- Expiry Checking Code (mostly taken from pyusexc.pkb).
--------------------------------------------------------------------------------
/*---------------------------- next_period  -----------------------------------
   NAME
      next_period
   DESCRIPTION
      Given a date and a payroll action id, returns the date of the day after
      the end of the containing pay period.
   NOTES
      <none>
*/
FUNCTION next_period
(
   p_assactid    IN  NUMBER,
   p_date        IN  DATE
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   select TP.end_date + 1
   into   l_return_val
   from   per_time_periods TP,
          pay_payroll_actions PACT,
          pay_assignment_actions ASSACT
   where  ASSACT.assignment_action_id = p_assactid
   and    PACT.payroll_action_id = ASSACT.payroll_action_id
   and    PACT.payroll_id = TP.payroll_id
   and    p_date between TP.start_date and TP.end_date;

   RETURN l_return_val;

END next_period;

/*---------------------------- next_month  ------------------------------------
   NAME
      next_month
   DESCRIPTION
      Given a date, returns the date of the first day of the next month.
   NOTES
      <none>
*/
FUNCTION next_month
(
   p_date        IN  DATE
) return DATE is
BEGIN

  RETURN trunc(add_months(p_date,1),'MM');

END next_month;

/*--------------------------- next_quarter  -----------------------------------
   NAME
      next_quarter
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      quarter.
   NOTES
      <none>
*/
FUNCTION next_quarter
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,3),'Q');

END next_quarter;

/*---------------------------- next_year  ------------------------------------
   NAME
      next_year
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      year.
   NOTES
      <none>
*/
FUNCTION next_year
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,12),'Y');

END next_year;

/*------------------------- next_fiscal_quarter  -----------------------------
   NAME
      next_fiscal_quarter
   DESCRIPTION
      Given a date, returns the date of the first day of the next fiscal
      quarter.
   NOTES
      <none>
*/
FUNCTION next_fiscal_quarter
(
   p_beg_of_fiscal_year  IN  DATE,
   p_date                IN  DATE
) RETURN DATE is

-- get offset of fiscal year start in relative months and days
  l_fy_rel_month NUMBER(2) := to_char(p_beg_of_fiscal_year, 'MM') - 1;
  l_fy_rel_day   NUMBER(2) := to_char(p_beg_of_fiscal_year, 'DD') - 1;

BEGIN

  RETURN (add_months(next_quarter(add_months(p_date, -l_fy_rel_month)
                                  - l_fy_rel_day),
                     l_fy_rel_month) + l_fy_rel_day);

END next_fiscal_quarter;

/*--------------------------- next_fiscal_year  ------------------------------
   NAME
      next_fiscal_year
   DESCRIPTION
      Given a date, returns the date of the first day of the next fiscal year.
   NOTES
      <none>
*/
FUNCTION next_fiscal_year
(
   p_beg_of_fiscal_year  IN  DATE,
   p_date                IN  DATE
) RETURN DATE is

-- get offset of fiscal year start relative to calendar year
  l_fiscal_year_offset   NUMBER(3) := to_char(p_beg_of_fiscal_year, 'DDD') - 1;

BEGIN

  RETURN (next_year(p_date - l_fiscal_year_offset) + l_fiscal_year_offset);

END next_fiscal_year;
/*------------------------------ date_expired  --------------------------------
   NAME
      date_expired
   DESCRIPTION
      Expiry checking code for the following date-related dimensions:
        Assignment/Person/neither and GRE/not GRE and
        Run/Period TD/Month/Quarter TD/Year TD/Fiscal Quarter TD/
          Fiscal Year TD
   NOTES
      This function assumes the date portion of the dimension name
      is always at the end to allow accurate identification since
      this is used for many dimensions.
*/
FUNCTION date_expired
(
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact.
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_date_mode                  in     number    -- running in date mode.
)
RETURN BOOLEAN IS

  l_beg_of_fiscal_year DATE := NULL;
  l_expiry_date DATE := NULL;

BEGIN

  IF p_dimension_name like '%Run' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_date_mode = 0 THEN
      IF p_owner_assignment_action_id <> p_user_assignment_action_id THEN
        l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      IF ( p_user_effective_date <> p_owner_effective_date ) OR
         ( p_owner_assignment_action_id <> p_user_assignment_action_id ) THEN
        l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
        RETURN FALSE;
      END IF;
    END IF;

  ELSIF p_dimension_name like '%Payments%' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_date_mode = 0 THEN
      IF p_owner_assignment_action_id <> p_user_assignment_action_id THEN
        l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      IF ( p_user_effective_date <> p_owner_effective_date ) OR
         ( p_owner_assignment_action_id <> p_user_assignment_action_id ) THEN
        l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
        RETURN FALSE;
      END IF;
    END IF;

  ELSIF p_dimension_name like '%Period to Date' THEN
    l_expiry_date := next_period(p_owner_assignment_action_id,
                                 p_owner_effective_date);

  ELSIF p_dimension_name like '%Month' THEN
    l_expiry_date := next_month(p_owner_effective_date);

  ELSIF p_dimension_name like '%Fiscal Quarter to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           pay_assignment_actions ASSACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = ASSACT.payroll_action_id
    AND    ASSACT.assignment_action_id = p_owner_assignment_action_id;

    l_expiry_date := next_fiscal_quarter(l_beg_of_fiscal_year,
                                         p_owner_effective_date);

  ELSIF p_dimension_name like '%Fiscal Year to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           pay_assignment_actions ASSACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = ASSACT.payroll_action_id
    AND    ASSACT.assignment_action_id = p_owner_assignment_action_id;

    l_expiry_date := next_fiscal_year(l_beg_of_fiscal_year,
                                      p_owner_effective_date);

  ELSIF p_dimension_name like '%Quarter to Date' THEN
    l_expiry_date := next_quarter(p_owner_effective_date);

  ELSIF p_dimension_name like '%Year to Date' THEN
    l_expiry_date := next_year(p_owner_effective_date);

  ELSIF p_dimension_name like '%Lifetime to Date' THEN
    RETURN FALSE;

/*
  ELSE
    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_THIS_DIMENSION');
    hr_utility.raise_error;
*/

  END IF;

  RETURN p_user_effective_date >= l_expiry_date;

END date_expired;

/*
** current_time
**
** Returns a number like 10660377
** which is the current time expressed
** in seconds since 1-Jan-97
*/
FUNCTION CurrentTime
  RETURN INTEGER
IS
  v_now             varchar2(16);
  v_return          integer;
  v_seconds         integer;
  v_minutes         integer;
  v_hours           integer;
  v_days            integer;
  v_base            integer :=
         to_char ( to_date ( '01/12/1997', 'DD/MM/YYYY' ), 'J' );
begin
  select to_char ( sysdate, 'J HH24:MI:SS' )
    into v_now
    from dual;

  v_days    := to_number ( substr ( v_now,  1, 7 ) );
  v_hours   := to_number ( substr ( v_now,  9, 2 ) );
  v_minutes := to_number ( substr ( v_now, 12, 2 ) );
  v_seconds := to_number ( substr ( v_now, 15, 2 ) );

--hr_utility.trace ( chr(10)                      || /* for sanity check */
--                       to_char ( v_hours )   || ':' ||
--                       to_char ( v_minutes ) || ':' ||
--                       to_char ( v_seconds )        ||
--                       chr(10)
--                     );
  v_return := (
               (
                (
                 (
                  (
                   ( v_days - v_base ) * 24
                  ) + v_hours
                 ) * 60
                ) + v_minutes
               ) * 60
              ) + v_seconds;
  return v_return;
end CurrentTime;


--------------------------------------------------------------------------------
-- Initialisation Code
--------------------------------------------------------------------------------
BEGIN
  -- Initialise the context lists.
  set_context( 'ASSIGNMENT_ACTION_ID', null );
  set_context( 'JURISDICTION_CODE', null );
  set_context( 'TAX_UNIT_ID', null );
  set_context( 'TAX_GROUP_ID', null );
  set_context( 'DATE_EARNED', null );
  set_context( 'BALANCE_DATE', null );
  set_context( 'BUSINESS_GROUP_ID', null );
  -- Initialise the debug message state.
  debug_init;
  -- set view mode
  set_view_mode('ASG');
  -- Initialise the SessionVarCount
  SessionVarCount := 0;

END pay_ca_balance_view_pkg;

/
