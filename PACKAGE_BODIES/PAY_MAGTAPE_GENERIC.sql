--------------------------------------------------------
--  DDL for Package Body PAY_MAGTAPE_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAGTAPE_GENERIC" 
/* $Header: pymaggen.pkb 120.7.12010000.1 2008/07/27 23:08:56 appldev ship $ */
as
    g_debug boolean;  /* NOTE: CANNOT be initialised here !! */
--
    type cursname_array is table of pay_magnetic_blocks.cursor_name%TYPE
                       index by binary_integer;
    type num_array is table of  number
                       index by binary_integer;
    type bool_array is table of boolean
                       index by binary_integer;
-- Cursor Level arrays
    curs                     cursname_array;
    column_num               num_array;
    block_id                 num_array;
    formulas                 num_array;
    first_run_flag           num_array;
    row_counts               num_array;
    intermediate_run         bool_array;
    running_intermediate     bool_array;
    level_no                 number;
    report_id                pay_magnetic_blocks.report_format%TYPE;
    int_prm_names            pay_mag_tape.host_array;
    int_prm_values           pay_mag_tape.host_array;
--
-- Formula level details
    formula_next_block       pay_magnetic_records.next_block_id%TYPE;
    formula_id               pay_magnetic_records.formula_id%TYPE;
    formula_frequency        pay_magnetic_records.frequency%TYPE;
    formula_overflow         pay_magnetic_records.overflow_mode%TYPE;
    formula_inter_repeat     pay_magnetic_records.last_run_executed_mode%TYPE;
    formula_action_level     pay_magnetic_records.action_level%TYPE;
    formula_block_label      pay_magnetic_records.block_label%TYPE;
    formula_block_row_label  pay_magnetic_records.block_row_label%TYPE;
    xml_proc_name            pay_magnetic_records.xml_proc_name%TYPE;
    rec_sequence             pay_magnetic_records.sequence%TYPE;
    return_arr_offset        number;
--
--

    procedure clear_cache
    is
    begin
      level_no := 0;
      formula_next_block := NULL;
      use_action_block := 'N';
      process_action_rec := 'N';
    end clear_cache;
--

  -----------------------------------------------------------------------------
  -- Name
  --   date_earned
  -- Purpose
  --   Returns the least of the maximum date of an assignment and a date.
  -- Arguments
  -- Notes
  --   Used within cursor definitions ie. can only be used from 7.1 of RDBMS
  --   onwards.
  -----------------------------------------------------------------------------
 --
 function date_earned
 (
  p_report_date   date,
  p_assignment_id number
 ) return date is
   v_max_assignment_date date;
   v_report_date         date := p_report_date;
 begin
   select max(SS.effective_end_date)
   into   v_max_assignment_date
   from   per_all_assignments_f SS
   where  SS.assignment_id = p_assignment_id;
   if v_max_assignment_date < v_report_date then
     return (v_max_assignment_date);
   else
     return (v_report_date);
   end if;
 end date_earned;
 --

procedure set_paramter_value(asg_act_id number,
			     prm_name varchar,
			     prm_value varchar)
is

begin
   INSERT INTO FF_ARCHIVE_ITEMS
                    (ARCHIVE_ITEM_ID,
                     USER_ENTITY_ID,
                     CONTEXT1,
                     VALUE  ,
                     ARCHIVE_TYPE,
                     NAME
                    )
   VALUES
                  (ff_archive_items_s.nextval,
                   -1,
                   asg_act_id,
                   prm_value,
                   'AAP',
                   prm_name
                    );

end;


/*  Function - get_parameter_value
    Action   - This returns the value of a named parameter from the
               pay_mag_tape paramater tables.
*/
    function get_parameter_value(prm_name varchar2)
    return varchar2 is
     cnt number;
     cnt2 number;
     val varchar2(256);
    begin
      cnt := 1;
      while cnt <= int_prm_values(1) loop
         if int_prm_names(cnt) = prm_name then
            val := int_prm_values(cnt);
         end if;
         cnt := cnt + 1;
      end loop;
      return val;
    exception
       when NO_DATA_FOUND then
          return NULL;
    end;
--
/*  Function - get_cursor_return
    Action   - This returns a value retrieved by a named cursor and position
               in that the column was selected.
*/
    function get_cursor_return(curs_name pay_magnetic_blocks.cursor_name%TYPE,
                               pos number) return varchar is
        column_no number;
        level_cnt number;
        cnt number;
    begin
        column_no := 0;
        level_cnt := 1;
-- Find the cursor required
        while curs(level_cnt) <> curs_name and level_cnt <> level_no loop
           level_cnt := level_cnt + 1;
        end loop;
        if curs(level_cnt) = curs_name then
           cnt := 1;
           while cnt < level_cnt loop -- Find the position of column in
                                      -- the returns table.
               column_no := column_no + column_num(cnt);
               cnt := cnt + 1;
           end loop;
           column_no := column_no + pos;
           return ret_vals(column_no);
        else
           return NULL;
        end if;
    end;
--
/*  Function curs_is_open
    Action:- This function is passed a cursor name and test to see if the
             cursor is open.
*/
    function curs_is_open(cur_name pay_magnetic_blocks.cursor_name%TYPE)
    return boolean is
      sql_curs number;
      rows_processed number;
      statem varchar2(256);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.curs_is_open');
       end if;
       statem := 'BEGIN IF '||cur_name||'%ISOPEN THEN '||
                           'pay_magtape_generic.boolean_flag := TRUE; '||
                           'ELSE pay_magtape_generic.boolean_flag := FALSE;'||
                           ' END IF; END;';
      sql_curs := dbms_sql.open_cursor;
      dbms_sql.parse(sql_curs,
                     statem,
                     dbms_sql.v7);
      rows_processed := dbms_sql.execute(sql_curs);
      dbms_sql.close_cursor(sql_curs);
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.curs_is_open');
       end if;
      return boolean_flag;
    end curs_is_open;

/*  Procedure - curs_close
    Actions   - This procedure close an already open cursor
*/
    procedure curs_close(cur_name pay_magnetic_blocks.cursor_name%TYPE) is
      sql_curs number;
      rows_processed number;
      statem varchar2(256);
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.curs_close');
      end if;
      statem := 'BEGIN CLOSE '||cur_name||'; '||'end;';
      sql_curs := dbms_sql.open_cursor;
      dbms_sql.parse(sql_curs,
                     statem,
                     dbms_sql.v7);
      rows_processed := dbms_sql.execute(sql_curs);
      dbms_sql.close_cursor(sql_curs);
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.curs_close');
      end if;
    end curs_close;

/*  Procedure - new_formula
    Action    - This procedure sets up the context and the parameters table
                for the core C program from values setup in the controlling
                tables and cursors.
*/
    PROCEDURE new_formula
    IS
       found boolean;
       cnt number;
       no_rows number;
       temp_formula_block_label      pay_magnetic_records.block_label%TYPE;
       temp_formula_block_row_label   pay_magnetic_records.block_row_label%TYPE;
       i number;
       prm_cnt number;

/*   Function tab_is_open
     Action:- Test a number in a table to see if it relates to an open
              cursor and returns TRUE is the cursor is open False
              otherwise.
*/
    function tab_is_open(sql_cur num_array, sql_pos number) return boolean is
      res boolean;
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.tab_is_open' || sql_cur(sql_pos));
      end if;
      res := dbms_sql.is_open(sql_cur(sql_pos));
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.tab_is_open');
      end if;
      return res;
    exception
       when NO_DATA_FOUND then
          return FALSE;
    end;
--
/*  Function first_run
    Action:- THis function is passed a numeric value relating to a position
             in the first_run_flag table and returns False if the value is
             0 (ie. it is not the first run of this block) otherwise TRUE.
*/
    function first_run(pos number) return boolean is
      res boolean;
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.first_run');
      end if;
      if first_run_flag(pos) = 1 then
         first_run_flag(pos) := 0;
         if g_debug then
            hr_utility.trace('Exiting pay_magtape_generic.first_run');
         end if;
         return FALSE;
      else
         first_run_flag(pos) := 1;
         if g_debug then
            hr_utility.trace('Exiting pay_magtape_generic.first_run');
         end if;
         return TRUE;
      end if;
    exception
       when NO_DATA_FOUND then
         first_run_flag(pos) := 1;
         if g_debug then
            hr_utility.trace('Exiting pay_magtape_generic.first_run');
         end if;
          return TRUE;
    end;
--
--
/*  Function curs_no_data
    Action:- This function is passed a cursor name and test to see if data
             was retrieved on the last fetch.
*/
    function curs_no_data(cur_name pay_magnetic_blocks.cursor_name%TYPE)
    return boolean is
      sql_curs number;
      rows_processed number;
      statem varchar2(256);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.curs_no_data');
       end if;
       statem := 'BEGIN IF '||cur_name||'%FOUND THEN '||
                           'pay_magtape_generic.boolean_flag := FALSE; '||
                           'ELSE pay_magtape_generic.boolean_flag := TRUE;'||
                           ' END IF; END;';
      sql_curs := dbms_sql.open_cursor;
      dbms_sql.parse(sql_curs,
                     statem,
                     dbms_sql.v7);
      rows_processed := dbms_sql.execute(sql_curs);
      dbms_sql.close_cursor(sql_curs);
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.curs_no_data');
      end if;
      return boolean_flag;
    end curs_no_data;
--
/*  Procedure - curs_open
    Action    - This opens a specified cursor.
*/
    procedure curs_open(cur_name pay_magnetic_blocks.cursor_name%TYPE) is
      sql_curs number;
      rows_processed number;
      statem varchar2(256);
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.curs_open');
      end if;
      statem := 'BEGIN OPEN '||cur_name||'; '||'end;';
      sql_curs := dbms_sql.open_cursor;
      dbms_sql.parse(sql_curs,
                     statem,
                     dbms_sql.v7);
      rows_processed := dbms_sql.execute(sql_curs);
      dbms_sql.close_cursor(sql_curs);
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.curs_open');
      end if;
    end curs_open;
--
/*  Procedure - curs_fetch
    Action    - This procedure executes a fetch into the retrieval table,
                given the cursor name and the number of vales being selected.
*/
    procedure curs_fetch(cur_name pay_magnetic_blocks.cursor_name%TYPE,
                         return_no pay_magnetic_blocks.no_column_returned%TYPE)
    is
      sql_curs number;
      rows_processed number;
      statem varchar2(6000);
      cnt number;
      first boolean;
      arr_num number;
      pkg_name varchar2(50);
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.curs_fetch');
      end if;
      cnt := 1;
--
-- Workaround for bug #297130
--
      pkg_name := substr(cur_name, 1, instr(cur_name, '.'));
      statem := 'BEGIN '||pkg_name||'level_cnt := '||pkg_name||
                    'level_cnt; FETCH '||cur_name||' INTO ';
/*
      statem := 'BEGIN FETCH '||cur_name||' INTO ';
*/
      first := TRUE;
      while cnt <= return_no loop   -- loop for the number of columns in
         if first then              -- the select statement
            first := FALSE;
         else
            statem := statem||',';
         end if;
         arr_num := return_arr_offset + cnt;  -- Add the off set so that
                                              -- this cursor retrieves into
                                              -- its own allocated area.
--
         statem := statem||' pay_magtape_generic.ret_vals('||arr_num||')';
         cnt := cnt + 1;
      end loop;
      statem := statem||'; END;';
hr_utility.trace(statem);
     sql_curs := dbms_sql.open_cursor;
      dbms_sql.parse(sql_curs,
                     statem,
                     dbms_sql.v7);
      rows_processed := dbms_sql.execute(sql_curs);
      dbms_sql.close_cursor(sql_curs);
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.curs_fetch');
      end if;
    end curs_fetch;
--
--
/*  Function - is_intermediate_required
    Action   - This returns true if any rows of the formula table for a
               particular block,  may require to be run after the last row
               of the cursor for that block is retrieved.
*/
    function is_intermediate_required(level_no number) return boolean is
      dummy char(1);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.is_intermediate_required');
       end if;
       select 'M'
       into dummy
       from pay_magnetic_records pmr
       where pmr.magnetic_block_id = block_id(level_no)
       and   pmr.last_run_executed_mode in ('A', 'R', 'F');
--
       return TRUE;
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.is_intermediate_required');
       end if;
    exception
       when NO_DATA_FOUND then
          if g_debug then
             hr_utility.trace('Exiting pay_magtape_generic.is_intermediate_required');
          end if;
          return FALSE;
       when TOO_MANY_ROWS then
          if g_debug then
             hr_utility.trace('Exiting pay_magtape_generic.is_intermediate_required');
          end if;
          return TRUE;
    end;
--
/*  Function - open_formula
    Action   - This opens a cursor for the formula for a particular cursor
               and returns the new cursor id
*/
    function open_formula(block pay_magnetic_blocks.magnetic_block_id%TYPE)
    return number is
      sql_cur number;
      ignore number;
      statem varchar2(256);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.open_formula');
       end if;
       sql_cur := dbms_sql.open_cursor;
       statem := 'select formula_id, next_block_id,'||
                 ' frequency, overflow_mode, '||
                 'last_run_executed_mode, action_level ,'||
                 'block_label,block_row_label,xml_proc_name,sequence '||
                 ' from pay_magnetic_records '||
                 'where magnetic_block_id = '||block||
                 ' order by sequence';
       dbms_sql.parse(sql_cur,
                  statem,
                  dbms_sql.v7);
       dbms_sql.define_column(sql_cur, 1, formula_id);
       dbms_sql.define_column(sql_cur, 2, formula_next_block);
       dbms_sql.define_column(sql_cur, 3, formula_frequency);
       dbms_sql.define_column(sql_cur, 4, formula_overflow, 1);
       dbms_sql.define_column(sql_cur, 5, formula_inter_repeat, 1);
       dbms_sql.define_column(sql_cur, 6, formula_action_level, 1);
       dbms_sql.define_column(sql_cur, 7, formula_block_label,30);
       dbms_sql.define_column(sql_cur, 8, formula_block_row_label,30);
       dbms_sql.define_column(sql_cur, 9, xml_proc_name,256);
       dbms_sql.define_column(sql_cur, 10, rec_sequence);
       ignore := dbms_sql.execute(sql_cur);
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.open_formula');
       end if;
       return sql_cur;
    end open_formula;
--

/*  Function - intermediate_needed
    Action   - This function determines if an extra run is required after the
               last row of the cursor is retrieved.
*/
    function intermediate_needed return boolean is
    found boolean;
    begin
      if g_debug then
         hr_utility.trace('Entering pay_magtape_generic.intermediate_needed');
      end if;
      found := FALSE;
      if formula_inter_repeat = 'A' then
         found := TRUE;
      else
         if formula_inter_repeat = 'R' then
            if intermediate_run(level_no) then
               found := TRUE;
            end if;
         else
            if not intermediate_run(level_no) then
               found := TRUE;
            end if;
         end if;
      end if;
      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.intermediate_needed');
      end if;
      return found;
    end;
--
/*  Function - open_inter_formula
    Action   - This function does the same as open_formula except it select
               statement only selects rows that have their last_run_execute
               flag set to R, A or F (ie if a run may be required).
*/
    function open_inter_formula(block
           pay_magnetic_blocks.magnetic_block_id%TYPE) return number is
      sql_cur number;
      ignore number;
      statem varchar2(512);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.intermediate_needed');
       end if;
       sql_cur := dbms_sql.open_cursor;
       statem := 'select formula_id,next_block_id,'||
                 'frequency,overflow_mode,'||
                 'last_run_executed_mode,action_level,'||
                 'block_label,block_row_label,xml_proc_name,sequence '||
                 'from pay_magnetic_records '||
                 'where magnetic_block_id='||block||
                 ' and last_run_executed_mode in (''R'',''A'',''F'')'||
                 ' order by sequence';
       dbms_sql.parse(sql_cur,
                  statem,
                  dbms_sql.v7);
       dbms_sql.define_column(sql_cur, 1, formula_id);
       dbms_sql.define_column(sql_cur, 2, formula_next_block);
       dbms_sql.define_column(sql_cur, 3, formula_frequency);
       dbms_sql.define_column(sql_cur, 4, formula_overflow, 1);
       dbms_sql.define_column(sql_cur, 5, formula_inter_repeat, 1);
       dbms_sql.define_column(sql_cur, 6, formula_action_level, 1);
       dbms_sql.define_column(sql_cur, 7, formula_block_label, 30);
       dbms_sql.define_column(sql_cur, 8, formula_block_row_label, 30);
       dbms_sql.define_column(sql_cur, 9, xml_proc_name, 256);
       dbms_sql.define_column(sql_cur, 10, rec_sequence);
       ignore := dbms_sql.execute(sql_cur);
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.intermediate_needed');
       end if;
       return sql_cur;
    end open_inter_formula;
--
/*  Function - run_overflow
    Action   - This function searches the parameter table for the parameter
               TRANSFER_RUN_OVERFLOW, if it is found and its value is set to
               Y then the boolean value true is returned otherwise false is
               returned.
*/
    function run_overflow return boolean is
      cnt number;
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.run_overflow');
       end if;
       cnt := 2;
       while cnt <= pay_mag_tape.internal_prm_values(1) loop
         if ((pay_mag_tape.internal_prm_names(cnt) = 'TRANSFER_RUN_OVERFLOW')
             and (pay_mag_tape.internal_prm_values(cnt) = 'Y')) then
            pay_mag_tape.internal_prm_values(cnt) := 'N';
            return TRUE;
         end if;
         cnt := cnt + 1;
       end loop;
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.run_overflow');
       end if;
       return FALSE;
    exception
       when NO_DATA_FOUND then
          if g_debug then
             hr_utility.trace('Exiting pay_magtape_generic.run_overflow');
          end if;
          return FALSE;
    end run_overflow;
--
/*  Procedure - set_report_id
    Action    - This procedure sets the report id on the first run of the
                procedure.
*/
    procedure set_report_id is
    cnt number;
    report_name varchar2(30);
    begin
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.set_report_id');
       end if;
       report_id := '0';
       cnt := 1;
--
       if (use_action_block = 'Y') then
          report_name := 'MAGTAPE_ASG_REPORT_ID';
       else
          report_name := 'MAGTAPE_REPORT_ID';
       end if;
--
       while cnt <= pay_mag_tape.internal_prm_values(1) loop
          if pay_mag_tape.internal_prm_names(cnt) = report_name then
             hr_utility.trace('Match');
             report_id := pay_mag_tape.internal_prm_values(cnt);
             hr_utility.trace('Set Value');
          end if;
          cnt := cnt + 1;
       end loop;
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.set_report_id');
       end if;
    end;
--
/*  Procedure - setup return_values
    Action    - This procedure sets up the PL/SQL tables for the Fast Formula
                The context rules and the parameters are transfered from the
                retrieval table.
*/
    procedure setup_return_values (formula_id number,xml_proc_name varchar,
                    return_num number) is
    cnt number;
    cxt_cnt number;
    prm_cnt number;
    xml_cnt number;
    chk_cxt number;
    pos number;
    str varchar(256);
    con_str varchar(256);
    begin
-- Set up the Contexts
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.setup_return_values');
       end if;
       cnt := return_num + return_arr_offset;  -- Set up the outer loop to
       cxt_cnt := 1;                           -- run from the last entry
       while cnt > 0 loop                      -- in the retrieval list to
          pos := instr(ret_vals(cnt), '=');    -- the first.
          if pos <> 0 then
             str := substr(ret_vals(cnt),
                            pos + 1, pos + 2);
             con_str := substr(ret_vals(cnt),0, pos - 1);
                                               -- If entry is a context rule
             if str = 'C' then                 -- then search context table
                found := FALSE;                -- for an existing entry for
                chk_cxt := 1;                  -- this context.
                while chk_cxt <= cxt_cnt loop
                   if pay_mag_tape.internal_cxt_names(chk_cxt) =
                                              con_str then
                       found := TRUE;
                   end if;
                   chk_cxt := chk_cxt + 1;
                end loop;
                if not found then              -- If there was no entry for
                   cxt_cnt := cxt_cnt + 1;     -- the context then enter one.
                   pay_mag_tape.internal_cxt_names(cxt_cnt) :=
                                substr(ret_vals(cnt),
                                      0, pos - 1);
                   pay_mag_tape.internal_cxt_values(cxt_cnt) := ret_vals(cnt +
                                                                1);
-- Bug 259276. Fix between the two following lines
-- Problem with using the to_char fuction within the dynamically called
-- cursors.
-- This code is now redundant as the value of the date context is
-- already in canonical form.
-- ---------------------------------------------------------------------------
--                   if pay_mag_tape.internal_cxt_names(cxt_cnt) like 'DATE%'
--                   then
--                     pay_mag_tape.internal_cxt_values(cxt_cnt) :=
--                     to_char(to_date(pay_mag_tape.internal_cxt_values(cxt_cnt), 'YYYY/MM/DD'),
--                             'YYYY/MM/DD');
--                   end if;
-- --------------------------------------------------------------------------
                 end if;
              end if;
          end if;
          cnt := cnt - 1;
       end loop;
-- Set up the parameters
       cnt := return_arr_offset + 1;                     -- Search the returns
       while cnt <= return_num + return_arr_offset loop  -- table for the new
          pos := instr(ret_vals(cnt), '=');              -- parameter values
          if pos <> 0 then
             str := substr(ret_vals(cnt),
                            pos + 1, pos + 2);
             con_str := substr(ret_vals(cnt),0, pos - 1);
             if str = 'P' then
                found := FALSE;
                prm_cnt := 1;
                while prm_cnt <= pay_mag_tape.internal_prm_values(1) loop
                   if pay_mag_tape.internal_prm_names(prm_cnt) = con_str then
                      found := TRUE;
                      cnt := cnt + 1;
                      pay_mag_tape.internal_prm_values(prm_cnt) :=
                                                           ret_vals(cnt);
                   end if;
                   prm_cnt := prm_cnt + 1;
                end loop;
                if not found then              -- Add new parameter to table
                   pay_mag_tape.internal_prm_names(prm_cnt) := con_str;
                   cnt := cnt + 1;
                   pay_mag_tape.internal_prm_values(prm_cnt) :=
                                                      ret_vals(cnt);
                   pay_mag_tape.internal_prm_values(1) := prm_cnt;
                end if;
             end if;
            end if;
            cnt := cnt + 1;
         end loop;
      cnt := return_arr_offset + 1;                     -- Search the returns
       xml_cnt := pay_mag_tape.internal_xml_values(1);
       while cnt <= return_num + return_arr_offset loop  -- table for the new
          pos := instr(ret_vals(cnt), '=');              -- parameter values
          if pos <> 0 then
             str := substr(ret_vals(cnt),
                            pos + 1, pos + 2);
             con_str := substr(ret_vals(cnt),0, pos - 1);
             if str = 'X' then
                   xml_cnt := pay_mag_tape.internal_xml_values(1)+1;
                   pay_mag_tape.internal_xml_names(xml_cnt) := con_str;
                   cnt := cnt + 1;
                   pay_mag_tape.internal_xml_values(xml_cnt) :=
                                                      ret_vals(cnt);
                   xml_cnt := pay_mag_tape.internal_xml_values(1)+2;
                   pay_mag_tape.internal_xml_names(xml_cnt) := '/'||con_str;
                   pay_mag_tape.internal_xml_values(1) := xml_cnt;
             end if;
            end if;
            cnt := cnt + 1;
         end loop;
--
--  Set up the formula id and context count
       pay_mag_tape.internal_cxt_values(1) := cxt_cnt;
       pay_mag_tape.internal_xml_values(1) := xml_cnt;
       pay_mag_tape.internal_prm_values(2) := formula_id;
       pay_mag_tape.internal_xml_values(2) := xml_proc_name;
       int_prm_names := pay_mag_tape.internal_prm_names;
       int_prm_values := pay_mag_tape.internal_prm_values;
       if (nvl(formula_action_level, 'N') = 'A') then
         process_action_rec := 'Y';
       else
         process_action_rec := 'N';
       end if;
       if g_debug then
          hr_utility.trace('Exiting pay_magtape_generic.setup_return_values');
       end if;
    end setup_return_values;
--
    BEGIN
       g_debug := hr_utility.debug_enabled;
       if g_debug then
          hr_utility.trace('Entering pay_magtape_generic.new_formula');
       end if;
                                -- First run through setup report details
       int_prm_names := pay_mag_tape.internal_prm_names;
       int_prm_values := pay_mag_tape.internal_prm_values;
       if level_no = 0 then
          g_debug := hr_utility.debug_enabled;
          set_report_id;
          level_no := 1;
          return_arr_offset := 0;
          select cursor_name, nvl(no_column_returned,0), magnetic_block_id
          into   curs(1),  column_num(1), block_id(1)
          from   pay_magnetic_blocks
          where main_block_flag = 'Y'
          and   report_format = report_id;

          hr_utility.trace(curs(1)||'..'||to_char(column_num(1))||'..'||to_char(block_id(1)));

       prm_cnt :=pay_mag_tape.internal_prm_values(1)+1;
       pay_mag_tape.internal_prm_names(prm_cnt) :='magnetic_block_id';
       pay_mag_tape.internal_prm_values(prm_cnt):=block_id(1);
       prm_cnt :=pay_mag_tape.internal_prm_values(1)+2;
       pay_mag_tape.internal_prm_names(prm_cnt) :='rec_sequence';
       pay_mag_tape.internal_prm_values(1):=prm_cnt;
       int_prm_names := pay_mag_tape.internal_prm_names;
       int_prm_values := pay_mag_tape.internal_prm_values;

       end if;
       if formula_block_label is not null
       then
           pay_mag_tape.internal_xml_names(2) := formula_block_label;
           pay_mag_tape.internal_xml_values(1) := 2;
       end if;
                                -- The previous formula requests a new
                                -- block to be set up
       if formula_next_block is not null then
          return_arr_offset := return_arr_offset + column_num(level_no);
          level_no := level_no + 1;
          select cursor_name, nvl(no_column_returned,0), magnetic_block_id
          into   curs(level_no),  column_num(level_no), block_id(level_no)
          from   pay_magnetic_blocks
          where magnetic_block_id = formula_next_block
          and   report_format = report_id;
          hr_utility.trace(to_char(level_no)||'..'||curs(level_no)||'..'||to_char(column_num(level_no))||'..'||to_char(block_id(level_no)));
        i:=1;
        while (pay_mag_tape.internal_prm_names(i) <>'magnetic_block_id')
        loop
             i:=i+1;
        end loop;
        pay_mag_tape.internal_prm_values(i):=block_id(level_no);
         int_prm_values := pay_mag_tape.internal_prm_values;
       end if;
       found := FALSE;
--
-- Is formula an overflow repeat and is the overflow formula requested to run
--
       if (formula_overflow = 'R') then
          if run_overflow then
             if not running_intermediate(level_no) then
                found := TRUE;
             else
                if intermediate_needed then
                   found := TRUE;
                end if;
             end if;
          end if;
       end if;
--
-- Loop until the next formula is found
--

       cur_fetch:=FALSE;
       while not found loop
                            -- If formulas cursor is not open then open
                            -- cursor
          if not tab_is_open(formulas, level_no) then
                            -- If a driving cursor exists and its not open
                            -- then set the cursor up.
             if not(curs(level_no) is null) then
                 if not curs_is_open(curs(level_no)) then
                    curs_open(curs(level_no));
                    row_counts(level_no) := 0;
                    running_intermediate(level_no) := FALSE;
                    intermediate_run(level_no) := FALSE;
                 end if;
                 curs_fetch(curs(level_no), column_num(level_no));
                 row_counts(level_no) := row_counts(level_no) + 1;
                             -- If no data is retrieved from the driving
                             -- cursor return to the previous level after
                             -- an intermediate run if required.
                 if curs_no_data(curs(level_no)) then
                    cur_fetch:=FALSE;
                    if (is_intermediate_required(level_no)
                        and not running_intermediate(level_no)) then
                      formulas(level_no) := open_inter_formula(
                                               block_id(level_no));
                      running_intermediate(level_no) := TRUE;
                    else
                      if (formula_id=-9999 and xml_proc_name is null) then

                        no_rows :=  dbms_sql.last_row_count;
                        if (level_no >1) then
                         dbms_sql.column_value(formulas(level_no-1), 7,
                                                    temp_formula_block_label);
                       /*  if (no_rows=0 and temp_formula_block_label is not NULL) then
                           cnt :=pay_mag_tape.internal_xml_values(1)-1;
                           pay_mag_tape.internal_xml_values(1) := cnt;
                         els*/if (temp_formula_block_label is not NULL) then
                           cnt :=pay_mag_tape.internal_xml_values(1)+1;
                           pay_mag_tape.internal_xml_names(cnt) := '/'||temp_formula_block_label;
                           pay_mag_tape.internal_xml_values(1) := cnt;
                         end if;
                        end if;
                      end if;
                      curs_close(curs(level_no));
                      level_no := level_no - 1;
                      return_arr_offset := return_arr_offset -
                                             column_num(level_no);
                    end if;
                 else
                      cur_fetch:=TRUE;
                      formulas(level_no) := open_formula(block_id(level_no));
                 end if;
             else
                 if first_run(level_no) then
                      formulas(level_no) := open_formula(block_id(level_no));
                      running_intermediate(level_no) := FALSE;
                      intermediate_run(level_no) := FALSE;
                 else
                    level_no := level_no -1;
                 end if;
              end if;
          else
-- Get formula details
           if dbms_sql.fetch_rows(formulas(level_no)) > 0 then
             dbms_sql.column_value(formulas(level_no), 1, formula_id);
             dbms_sql.column_value(formulas(level_no), 2, formula_next_block);
             dbms_sql.column_value(formulas(level_no), 3, formula_frequency);
             dbms_sql.column_value(formulas(level_no), 4, formula_overflow);
             dbms_sql.column_value(formulas(level_no), 5,
                                                       formula_inter_repeat);
             dbms_sql.column_value(formulas(level_no), 6,
                                                       formula_action_level);
             dbms_sql.column_value(formulas(level_no), 7,
                                                       formula_block_label);
             dbms_sql.column_value(formulas(level_no), 8,
                                                       formula_block_row_label);
             dbms_sql.column_value(formulas(level_no), 9, xml_proc_name);
             dbms_sql.column_value(formulas(level_no), 10, rec_sequence);

-- set up mgnetic record id a s a paramter
        i:=1;
        while (pay_mag_tape.internal_prm_names(i) <>'rec_sequence')
        loop
             i:=i+1;
        end loop;
        pay_mag_tape.internal_prm_values(i):=rec_sequence;
         int_prm_values := pay_mag_tape.internal_prm_values;

--
-- Is formula an overflow and is the overflow formula requested to run
--
             if ((formula_overflow = 'Y') or (formula_overflow = 'R')) then
                if run_overflow then
                   if not running_intermediate(level_no) then
                     found := TRUE;
                   else
                      if intermediate_needed then
                         found := TRUE;
                      end if;
                   end if;
                end if;
             else
--
-- Is formula a skip count and has the count reached the run point
--
                if formula_frequency is not null then
                   if not running_intermediate(level_no) then
                      if (row_counts(level_no)
                                 mod formula_frequency) = 0 then
                         intermediate_run(level_no) := TRUE;
                         found := TRUE;
                      end if;
                   else
                      if ((row_counts(level_no) -1)
                                 mod formula_frequency <> 0) and
                                  intermediate_needed then
                         found := TRUE;
                      end if;
                   end if;
                else
--
-- Ordinary formula that runs everytime
--
                   if not running_intermediate(level_no) then
                      found := TRUE;
                   else
                      if intermediate_needed then
                         found := TRUE;
                      end if;
                   end if;
                end if;
              end if;
           else
              dbms_sql.close_cursor(formulas(level_no));
           end if;
          end if;
      end loop;

     if (formula_id=-9999 and xml_proc_name is null) then
      if (level_no>1) then
       dbms_sql.column_value(formulas(level_no-1), 8, temp_formula_block_row_label);
       if (cur_fetch=TRUE and temp_formula_block_row_label is not null)
       then
         hr_utility.trace(to_char(cnt)||temp_formula_block_row_label);
        cnt :=pay_mag_tape.internal_xml_values(1)+1;
        pay_mag_tape.internal_xml_names(cnt) := temp_formula_block_row_label;
        pay_mag_tape.internal_xml_values(1) := cnt;
        setup_return_values(formula_id,xml_proc_name, column_num(level_no));
         hr_utility.trace(to_char(cnt)||'..'||pay_mag_tape.internal_xml_values(1));
        cnt :=pay_mag_tape.internal_xml_values(1)+1;
         hr_utility.trace(to_char(cnt));
        pay_mag_tape.internal_xml_names(cnt) := '/'||temp_formula_block_row_label;
        pay_mag_tape.internal_xml_values(1) := cnt;
       elsif (cur_fetch=TRUE)  then
        setup_return_values(formula_id,xml_proc_name,  column_num(level_no));
       end if;
      elsif  (cur_fetch=TRUE)  then
        setup_return_values(formula_id,xml_proc_name, column_num(level_no));
      end if;
     else
        setup_return_values(formula_id,xml_proc_name, column_num(level_no));
     end if;

      if g_debug then
         hr_utility.trace('Exiting pay_magtape_generic.new_formula');
      end if;
    END new_formula;
--
procedure clear_cursors is
begin
while level_no >0
loop
 if (dbms_sql.is_open(formulas(level_no))) then
  dbms_sql.close_cursor(formulas(level_no));
 end if;
 if curs_is_open(curs(level_no)) then
  curs_close(curs(level_no));
 end if;
 level_no := level_no-1;
end loop;
return_arr_offset := 0;
formula_next_block := NULL;
process_action_rec := 'N';

end;

   BEGIN
      level_no := 0;
      formula_next_block := NULL;
      use_action_block := 'N';
      process_action_rec := 'N';
   END pay_magtape_generic;

/
