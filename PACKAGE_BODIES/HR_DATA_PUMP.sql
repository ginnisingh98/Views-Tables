--------------------------------------------------------
--  DDL for Package Body HR_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DATA_PUMP" as
/* $Header: hrdpump.pkb 120.8 2006/01/25 06:03:08 arashid noship $ */
/*
  NOTES
  o This package body contains the Data Pump engine code.
  o For documentation, see the following:
    - hld/hrdpump.lld   : low level design document.
    - txt/hrdsche.txt   : schema description document.
    *** These documents should be kept in step with the code ***
*/
/*---------------------------------------------------------------------------*/
/*----------------------- constant definitions ------------------------------*/
/*---------------------------------------------------------------------------*/
PURGE_MIN_ROWS     constant binary_integer := 2000;
PURGE_SIZE_DEFAULT constant binary_integer := 500;
RANGE_SIZE_DEFAULT constant binary_integer := 10;
THREADS_DEFAULT    constant binary_integer := 1;
ERRORS_DEFAULT     constant binary_integer := 20;
DEBUG_PAGES        constant binary_integer := 20;

/*---------------------------------------------------------------------------*/
/*------------- internal Data Pump engine data structures -------------------*/
/*---------------------------------------------------------------------------*/
/*
 *  The following record holds 'startup' information that will
 *  be passed to all the internal master procedures.  This includes
 *  information about number of slaves to start, range size and
 *  so on.  Collected into one place so it's easy to change.
 */
type master_env_r is record
(
   business_group_id number,
   security_group_id number,
   range_size        binary_integer,
   threads           binary_integer,
   error_limit       binary_integer
  ,pap_group_id      number
);

/*
 *  This record holds information about a particular
 *  slave process.  All held in one structure so it
 *  can be passed through the different slave
 *  procedures.  May well be useful for debug output.
 */
type slave_info_r is record
(
   lines_proc number,       -- number of batch lines processed.
   wrap_total number,       -- number of wrappers called.
   wcachehit  number,       -- number of times hit the cache.
   errortotal number,       -- total number of errors encountered.
   rangetotal number,       -- total number of ranges processed.
   fail_bline number,       -- batch line processed at failure.
   single_threaded boolean  -- running in single threaded mode.
);

/*
 *  The following holds information about
 *  the range of rows we are trying to
 *  insert for parallelisation.
 */
type range_info_r is record
(
  rows_in_range    number,
  range_number     number,
  range_start      number,
  range_end        number
);

/*
 *  The following data structure holds information for
 *  the API wrapper modules. This was primarily a cache
 *  for DBMS_SQL cursors. It is now used to cache the
 *  SQL call string.
 *  Note that in this first version, no upper limit is
 *  being put on the size of the cache.
 *  This might need alteration in future versions.
 *  There is more information held here than is strictly
 *  necessary for normal functioning.  Other information
 *  is for logging and debugging purposes.
 */
type wrap_cache_r is record
(
   api_module_id number,
   call_string varchar2(2000)
);

type wrap_cache_t is table of wrap_cache_r index by binary_integer;

/*
 *  Debug information.
 */

type debug_info_r is record
(
   message_dbg     boolean,   /* allow specific log messages */
   call_trace_dbg  boolean,   /* entry and exit macros */
   wrap_cache_dbg  boolean,   /* wrap cache information dump */
   api_module_dbg  boolean,   /* api module trace info  */
   stack_dump_dbg  boolean,   /* dump information on total failure */
   exit_info_dbg   boolean,   /* information on exit (success) */
   range_ins_dbg   boolean,   /* information about range inserts */
   range_proc_dbg  boolean,   /* info on processing ranges */
   get_id_dbg      boolean,   /* log info from failing get_id functions */
   conc_file_dbg   boolean,   /* send messages to concurrent log file */
   batch_line_info boolean    /* show batch_line information */
);

/*
 *  Holds some information about failures occurring
 *  in get_id functions.
 */

type fail_info_r is record
(
   fail_flag   boolean,
   func_name   varchar2(30),
   error_msg   varchar2(2000),
   arg_values  varchar2(2000)
);

/*
 * Types for different fetching and locking from HR_PUMP_RANGES. In the
 * single-threaded case, an ORDER BY statement is used, but not in the
 * multi-threaded case.
 */
type range_fetch_info_r is record
(rowid_                    urowid
,starting_process_sequence number
,ending_process_sequence   number
);

type range_fetch_cursor_t is ref cursor return range_fetch_info_r;
/*---------------------------------------------------------------------------*/
/*----------------------- Data Pump engine globals --------------------------*/
/*---------------------------------------------------------------------------*/
g_wrapper_cache wrap_cache_t;  -- holds API wrapper cache info.
g_debug         debug_info_r;  -- debug flags.
g_senv          slave_info_r;  -- slave environment.
g_fail_info     fail_info_r;   -- for special info messages.

/*
 * Procedure to get action parameter values.
 */
procedure get_action_parameter
(p_para_name   in         varchar2
,p_para_value  out nocopy varchar2
,p_found       out nocopy boolean
) is
begin
--
   --
   -- Ideally, the code should directly call
   -- pay_core_utils.get_action_parameter, but that restricts the
   -- back-portability of this code as it's an HRMS FP.E feature.
   --
   select parameter_value
   into p_para_value
   from pay_action_parameters
   where parameter_name = p_para_name;
--
   p_found := TRUE;
--
exception
   when no_data_found then
      p_found := FALSE;
--
end get_action_parameter;


/*---------------------------------------------------------------------------*/
/*------------------ local functions and procedures -------------------------*/
/*---------------------------------------------------------------------------*/

/*
 * header_core
 * Core code to fetch header information.
 */
procedure header_core
(p_batch_id            in            number
,p_batch_name             out nocopy varchar2
,p_business_group_id      out nocopy number
,p_business_group_name    out nocopy varchar2
,p_security_group_id      out nocopy number
,p_batch_status           out nocopy varchar2
,p_atomic_linked_calls    out nocopy varchar2
) is
begin
  --
  -- Get some information from the batch header. This includes the
  -- business_group_id and the current batch status. The outer join is
  -- necessary because the header does not have to have a business group
  -- name.
  --
  select grp.business_group_id
  ,      grp.security_group_id
  ,      pbh.batch_name
  ,      pbh.batch_status
  ,      pbh.business_group_name
  ,      nvl(upper(pbh.atomic_linked_calls), 'N')
  into   p_business_group_id
  ,      p_security_group_id
  ,      p_batch_name
  ,      p_batch_status
  ,      p_business_group_name
  ,      p_atomic_linked_calls
  from   per_business_groups_perf grp
  ,      hr_pump_batch_headers pbh
  where  pbh.batch_id = p_batch_id
  and    grp.name (+) = pbh.business_group_name
  for    update of pbh.batch_status
  ;
end header_core;

/*
 * headerTAS - header Test And Set
 * Lock the batch header and set the batch status to 'P' if the header is
 * not already processing.
 */
procedure headerTAS
(p_batch_id            in            number
,p_batch_name             out nocopy varchar2
,p_business_group_id      out nocopy number
,p_business_group_name    out nocopy varchar2
,p_security_group_id      out nocopy number
,p_batch_status           out nocopy varchar2
) is
l_batch_status varchar2(30);
l_atomic_linked_calls varchar2(30);
begin
  savepoint headerTAS;
  --
  header_core
  (p_batch_id            => p_batch_id
  ,p_batch_name          => p_batch_name
  ,p_business_group_id   => p_business_group_id
  ,p_business_group_name => p_business_group_name
  ,p_security_group_id   => p_security_group_id
  ,p_batch_status        => l_batch_status
  ,p_atomic_linked_calls => l_atomic_linked_calls
  );

  --
  -- Is the batch already processing ?
  --
  p_batch_status := l_batch_status;
  if l_batch_status = 'P' then
    --
    -- Somebody else is processing the batch.
    --
    rollback to headerTAS;
  else
    --
    -- Set the header status to processing.
    --
    update hr_pump_batch_headers h
    set    h.batch_status = 'P'
    where  h.batch_id = p_batch_id;
    --
    commit;
  end if;

exception
  when others then
    rollback to headerTAS;
    raise;
end headerTAS;

/*
 * header_read
 * Read information from the batch header and error if the batch does not exist.
 */
procedure header_read
(p_batch_id            in            number
,p_atomic_linked_calls    out nocopy boolean
) is
l_batch_name          hr_pump_batch_headers.batch_name%type;
l_business_group_id   number;
l_business_group_name hr_pump_batch_headers.batch_name%type;
l_security_group_id   number;
l_batch_status        hr_pump_batch_headers.batch_status%type;
l_atomic_linked_calls hr_pump_batch_headers.atomic_linked_calls%type;
begin
  --
  header_core
  (p_batch_id            => p_batch_id
  ,p_batch_name          => l_batch_name
  ,p_business_group_id   => l_business_group_id
  ,p_business_group_name => l_business_group_name
  ,p_security_group_id   => l_security_group_id
  ,p_batch_status        => l_batch_status
  ,p_atomic_linked_calls => l_atomic_linked_calls
  );

  p_atomic_linked_calls := (l_atomic_linked_calls = 'Y');
exception
  when no_data_found then
    hr_utility.set_message(800, 'HR_33798_DP_BATCH_NOT_FOUND');
    hr_utility.set_message_token('BATCH_ID', to_char(p_batch_id));
    hr_utility.raise_error;
end header_read;

procedure fail
(
   p_function_name in varchar2,
   p_error_message in varchar2,
   p_arg01         in varchar2 default null,
   p_arg02         in varchar2 default null,
   p_arg03         in varchar2 default null,
   p_arg04         in varchar2 default null,
   p_arg05         in varchar2 default null,
   p_arg06         in varchar2 default null,
   p_arg07         in varchar2 default null,
   p_arg08         in varchar2 default null
) is
begin
   g_fail_info.fail_flag  := TRUE; -- Indicate failure has occured.
   g_fail_info.func_name  := p_function_name;
   g_fail_info.error_msg  := p_error_message;

   -- Deal with logging of the argument values.
   g_fail_info.arg_values := NULL;
   if(p_arg01 is not null) then
      g_fail_info.arg_values := p_arg01;
   end if;

   if(p_arg02 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg02;
   end if;

   if(p_arg03 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg03;
   end if;

   if(p_arg04 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg04;
   end if;

   if(p_arg05 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg05;
   end if;

   if(p_arg06 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg06;
   end if;

   if(p_arg07 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg07;
   end if;

   if(p_arg08 is not null) then
      g_fail_info.arg_values := g_fail_info.arg_values || ':' || p_arg08;
   end if;

   fnd_message.set_name('PER','HR_DP_EXCEPTION');
   fnd_message.set_token('ROUTINE',p_function_name);
   fnd_message.set_token('SQL_ERROR',p_error_message);
   fnd_message.set_token('PARAM',g_fail_info.arg_values);
   fnd_message.raise_error;

end fail;

/* logs failure from get id functions */
procedure get_id_failure
is
begin
   if(not g_debug.get_id_dbg or not g_fail_info.fail_flag) then
      return;
   end if;

   -- Reset the failure flag.
   g_fail_info.fail_flag := FALSE;

   hr_utility.trace_on('F', 'REQID');
   hr_utility.trace('Fail [' || g_fail_info.func_name || ']');
   hr_utility.trace('args: ' || g_fail_info.arg_values);
   hr_utility.trace(g_fail_info.error_msg);
   hr_utility.trace_off;

end get_id_failure;

/* provides entry macro */
procedure entry
(
   p_procedure_name in varchar2
) is
begin
   if(not g_debug.call_trace_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');
   hr_utility.trace('In  : ' || p_procedure_name);
   hr_utility.trace_off;
end entry;

/* provides entry macro */
procedure exit
(
   p_procedure_name in varchar2
) is
begin
   if(not g_debug.call_trace_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');
   hr_utility.trace('Out : ' || p_procedure_name);
   hr_utility.trace_off;
end exit;

/* API trace on. */
procedure api_trc_on is
begin
   if(not g_debug.api_module_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');
end api_trc_on;

/* API trace off. */
procedure api_trc_off is
begin
   if(not g_debug.api_module_dbg) then
      return;
   end if;

   hr_utility.trace_off;
end api_trc_off;

/* general message procedure */
procedure message
(
   p_message varchar2
) is
begin

-- send message to concurrent log file, if enabled
   if(g_debug.conc_file_dbg) then
      fnd_file.put_line(fnd_file.log, p_message);
   end if;

   if(not g_debug.message_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');
   hr_utility.trace(p_message);
   hr_utility.trace_off;
end message;

/*
 *  Procedure to output information about the
 *  information in the wrapper cache.
 */
procedure wrap_cache_debug
is
begin
   -- Check for debug
   if(g_debug.wrap_cache_dbg) then
      -- Initialise the trace.
      hr_utility.trace_on('F', 'REQID');

      -- Output the information.
      hr_utility.trace('Wrapper cache debug....');

      -- Finished, no more trace.
      hr_utility.trace_off;
   end if;
end wrap_cache_debug;


/*
 *  Outputs information about range inserts.
 */
procedure range_ins_debug
(
   p_info in range_info_r
) is
   l_rows   varchar2(80);
   l_number varchar2(80);
   l_start  varchar2(80);
   l_end    varchar2(80);
   l_rows_in_range number;
begin

   if(not g_debug.range_ins_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');

   -- The following outputs a header line for every few
   -- rows of logging output to make things easier when
   -- there are lots of rows being processed.
   if(p_info.range_number = 1 or mod(p_info.range_number, DEBUG_PAGES) = 0)
   then
      hr_utility.trace(' * RRI Ins Info *  |---- Range ----|');
      hr_utility.trace(' Number       Rows    Start      End');
      hr_utility.trace(' -------- -------- -------- --------');
   end if;

   -- Number of rows is always over counted by one.
   l_rows_in_range := p_info.rows_in_range - 1;

   l_number := lpad(p_info.range_number,  9) || ' ';
   l_rows   := lpad(l_rows_in_range,      8) || ' ';
   l_start  := lpad(p_info.range_start,   8) || ' ';
   l_end    := lpad(p_info.range_end,     8);

   hr_utility.trace(l_number || l_rows || l_start || l_end);

   hr_utility.trace_off;

end range_ins_debug;

/*
 *  Outputs information about the processing of a range.
 */
procedure range_proc_debug
(
   p_range_start   in number,
   p_range_end     in number,
   p_errcnt        in binary_integer
) is
   l_total  varchar2(80);
   l_start  varchar2(80);
   l_end    varchar2(80);
   l_errcnt varchar2(80);
begin
   if(not g_debug.range_proc_dbg) then
      return;
   end if;

   hr_utility.trace_on('F', 'REQID');

   -- The following outputs a header line for every few
   -- rows of logging output to make things easier when
   -- there are lots of rows being processed.
   if(g_senv.rangetotal = 1 or mod(g_senv.rangetotal, DEBUG_PAGES) = 0)
   then
      hr_utility.trace('* Proc *  |---- Range ----|');
      hr_utility.trace('  Rge Num    Start      End Errcount');
      hr_utility.trace(' -------- -------- -------- --------');
   end if;

   l_total  := lpad(g_senv.rangetotal, 9) || ' ';
   l_start  := lpad(p_range_start,     8) || ' ';
   l_end    := lpad(p_range_end,       8) || ' ';
   l_errcnt := lpad(p_errcnt,          8);
   hr_utility.trace(l_total || l_start || l_end || l_errcnt);

   hr_utility.trace_off;

end range_proc_debug;

/*
 *  Outputs summary information following failure.
 *  Note that this information may be similar to
 *  that for success.
 */
procedure stack_dump
is
begin
   if(not g_debug.stack_dump_dbg) then
      return;
   end if;

   -- Give us some info!
   hr_utility.trace_on('F', 'REQID');

   hr_utility.trace('Stack Dump');
   hr_utility.trace('batch lines      : ' || g_senv.lines_proc);
   hr_utility.trace('wrappers called  : ' || g_senv.wrap_total);
   hr_utility.trace('wrap cache hits  : ' || g_senv.wcachehit);
   hr_utility.trace('total errors     : ' || g_senv.errortotal);
   hr_utility.trace('ranges processed : ' || g_senv.rangetotal);
   hr_utility.trace('batch id failed  : ' || g_senv.fail_bline);

   hr_utility.trace_off;
end stack_dump;

/*
 *  Outputs summary information following success.
 *  Note that this information may be similar to
 *  that for failure.
 */
procedure exit_info
is
begin
   if(not g_debug.exit_info_dbg) then
      return;
   end if;

   -- Give us some info.
   hr_utility.trace_on('F', 'REQID');

   hr_utility.trace('Exit information');
   hr_utility.trace('batch lines      : ' || g_senv.lines_proc);
   hr_utility.trace('wrappers called  : ' || g_senv.wrap_total);
   hr_utility.trace('wrap cache hits  : ' || g_senv.wcachehit);
   hr_utility.trace('total errors     : ' || g_senv.errortotal);
   hr_utility.trace('ranges processed : ' || g_senv.rangetotal);

   hr_utility.trace_off;
end exit_info;

/*
 * Procedure to clear the debug state. Used to
 * initialise the debug state and stop debugging if
 * there is an exception raised from the tracing code.
 */
procedure clear_debug
is
begin
   g_debug.message_dbg    := FALSE;
   g_debug.call_trace_dbg := FALSE;
   g_debug.wrap_cache_dbg := FALSE;
   g_debug.api_module_dbg := FALSE;
   g_debug.stack_dump_dbg := FALSE;
   g_debug.exit_info_dbg  := FALSE;
   g_debug.range_ins_dbg  := FALSE;
   g_debug.range_proc_dbg := FALSE;
   g_debug.get_id_dbg     := FALSE;
   g_debug.conc_file_dbg  := FALSE;
   g_debug.batch_line_info:= FALSE;
end clear_debug;

/*
 *  Function sets the appropriate debug levels.
 *  Also outputs 'header' information to help
 *  the interpretation of the output where
 *  this seems necessary.
 */
procedure set_debug
is
   l_debug_str pay_action_parameters.parameter_value%type;
   l_found     boolean;
begin
   -- Initialise the debugging information structure.
   clear_debug;

   -- Ensure trace is off when we start.
   hr_utility.trace_off;

   /*
    *  Attempt to get the debugging level
    *  from the action parameters table.
    *  If there is no row, return immediately.
    */
   get_action_parameter
   (p_para_name  => 'PUMP_DEBUG_LEVEL'
   ,p_para_value => l_debug_str
   ,p_found      => l_found
   );
   if not l_found then
     return;
   end if;

   /*
    *  Search the strings and look for the debug.
    */
   if(instr(l_debug_str, 'MSG') <> 0) then
      g_debug.message_dbg    := TRUE;
   end if;

   if(instr(l_debug_str, 'ROU') <> 0) then
      g_debug.call_trace_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'WCD') <> 0) then
      g_debug.wrap_cache_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'AMD') <> 0) then
      g_debug.api_module_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'STK') <> 0) then
      g_debug.stack_dump_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'EXT') <> 0) then
      g_debug.exit_info_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'RRI') <> 0) then
      g_debug.range_ins_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'RRP') <> 0) then
      g_debug.range_proc_dbg := TRUE;
   end if;

   if(instr(l_debug_str, 'GID') <> 0) then
      g_debug.get_id_dbg := TRUE;
   end if;

-- check for CLF debug setting
   if(instr(l_debug_str, 'CLF') <> 0) then
      g_debug.conc_file_dbg := TRUE;
   end if;
-- check for batch_line info setting
   if(instr(l_debug_str, 'BLI') <> 0) then
      g_debug.batch_line_info := TRUE;
   end if;


   -- Initialise the special info table.
   g_fail_info.func_name   := null;
   g_fail_info.error_msg   := null;
   g_fail_info.arg_values  := null;

end set_debug;

/*
 *  Post the error to exceptions table.
 *  Returns the actual error text, so we can
 *  pass this to the exit status message var.
 *  Note: there must be an exception handler
 *  around any trace code called by this function
 *  so that batch line and batch header rows are
 *  updated correctly.
 *  p_overmsg is an override message e.g. in validate mode
 *  the code saves error text before it rolls back any
 *  processing it performed. The saved error text is used
 *  as the override message in a call to post_error after the
 *  rollback.
 */
function post_error
(
   p_sqlcode in number,
   p_errmsg  in varchar2,
   p_overmsg in varchar2,
   p_level   in varchar2,
   p_type    in varchar2,
   p_id      in number,
   p_processing in boolean default false
) return varchar2 is
   l_exception_text hr_pump_batch_exceptions.exception_text%type;
   l_encoded varchar2(2000);   -- hold AOL encoded text.
begin

   -- Need to get text from appropriate place.
   if (p_overmsg is not null) then
      -- Use the override message, if available.
      l_exception_text := p_overmsg;
   elsif (sqlcode = hr_utility.HR_ERROR_NUMBER) then
      -- This is an application error.
      l_encoded := fnd_message.get_encoded;
      fnd_message.set_encoded(l_encoded);
      l_exception_text := fnd_message.get;
      if l_exception_text is null then
        l_exception_text := sqlerrm;
      end if;
   else
      -- Get message text for oracle error.
      l_exception_text := p_errmsg;
   end if;

   -- Update the appropriate status
   if(p_type = 'BATCH_HEADER' and not p_processing) then
      update hr_pump_batch_headers pbh
      set    pbh.batch_status = 'E'
      where  pbh.batch_id     = p_id;
   elsif (p_type <> 'BATCH_HEADER') then
      update hr_pump_batch_lines pbl
      set    pbl.line_status   = 'E'
      where  pbl.batch_line_id = p_id;
   end if;

   begin
      hr_data_pump.message('exception : ' || l_exception_text);
   exception
      -- Catch exceptions from logging code to allow status information
      -- to be updated.
      when others then
         clear_debug;
   end;

   insert into hr_pump_batch_exceptions (
           exception_sequence,
           exception_level,
           source_id,
           source_type,
           format,
           exception_text)
   values (hr_pump_batch_exceptions_s.nextval,
           p_level,
           p_id,
           p_type,
           'TRANSLATED',
           l_exception_text);

   return(l_exception_text);

end post_error;

/*
 *  Inserts a pump requests row.
 *  Gets the concurrent request from profile.
 *  Does not perform commit.
 */
procedure ins_pump_request
(
   p_batch_id     in number,
   p_process_type in varchar2
) is
   l_request_id number;
begin
   -- Get the request_id profile value.
   fnd_profile.get('CONC_REQUEST_ID', l_request_id);

   -- Following in case we are not running
   -- from the concurrent manager.
   if(l_request_id is null) then
      l_request_id := 0;
   end if;

   insert  into hr_pump_requests (
           batch_id,
           request_id,
           process_type)
   values (p_batch_id,
           l_request_id,
           p_process_type);

end ins_pump_request;

/*
 *  Deletes a pump request row for the
 *  current request_id.
 *  Does not perform commit.
 */
procedure del_pump_request
(
   p_batch_id number
) is
   l_request_id number;
begin
   -- Get the concurrent request id.
   fnd_profile.get('CONC_REQUEST_ID', l_request_id);

   -- Following in case we are not running
   -- from the concurrent manager.
   if(l_request_id is null) then
      l_request_id := 0;
   end if;

   delete from hr_pump_requests hpr
   where  hpr.batch_id   = p_batch_id
   and    hpr.request_id = l_request_id;

end del_pump_request;

/*
 * Procedure to disable continuous calc triggers.
 */
procedure disable_cont_calc
is
l_found     boolean;
l_pap_value pay_action_parameters.parameter_value%type;
begin
  get_action_parameter
  (p_para_name  => 'DATA_PUMP_DISABLE_CONT_CALC'
  ,p_para_value => l_pap_value
  ,p_found      => l_found
  );
  --
  -- The default value for the DATA_PUMP_DISABLE_CONT_CALC action
  -- parameter is to enable continous calc (existing behaviour).
  -- Continuous calc is only disabled when explicitly requested.
  --
  if l_found and upper(l_pap_value) = 'Y' then
    pay_continuous_calc.g_override_cc := true;
  end if;
end disable_cont_calc;

/*
 * Procedure to handle disabling of auditing.
 */
procedure disable_audit
is
l_found boolean;
l_pap_value pay_action_parameters.parameter_value%type;
begin
  get_action_parameter
  (p_para_name  => 'DATA_PUMP_NO_FND_AUDIT'
  ,p_para_value => l_pap_value
  ,p_found      => l_found
  );
  --
  -- The default value for the DATA_PUMP_NO_FND_AUDIT action parameter
  -- is to allow auditing to continue (existing behaviour). Auditing is
  -- only turned off when explicitly requested.
  --
  if l_found and upper(l_pap_value) = 'Y' then
    fnd_profile.put
    (name => 'AUDITTRAIL:ACTIVATE'
    ,val  => 'N'
    );
  end if;
end;

/*
 * Procedure to handle disabling of lookup checks.
 */
procedure disable_lookup_checks is
l_found boolean;
l_pap_value pay_action_parameters.parameter_value%type;
begin
  get_action_parameter
  (p_para_name  => 'DATA_PUMP_NO_LOOKUP_CHECKS'
  ,p_para_value => l_pap_value
  ,p_found      => l_found
  );
  --
  -- User must explicitly set the action parameter to 'N' to
  -- disable the lookup checks.
  --
  hr_data_pump.g_disable_lookup_checks :=
  l_found and upper(l_pap_value) = 'Y';
end;

/*
 * Procedure to handle the setting of the Date-Track foreign
 * key locking.
 */
procedure set_dt_foreign_locking is
l_found boolean;
l_pap_value pay_action_parameters.parameter_value%type;
l_lock  boolean;
begin
   get_action_parameter
   (p_para_name  => 'PUMP_DT_ENFORCE_FOREIGN_LOCKS'
   ,p_para_value => l_pap_value
   ,p_found      => l_found
   );

   --
   -- Default behaviour is to lock. Also lock is the parameter
   -- value is 'Y'.
   --
   l_lock :=
   not l_found or
   (l_found and (l_pap_value = 'Y' or l_pap_value = 'y'));

   hr_pump_utils.set_dt_enforce_foreign_locks(p_enforce => l_lock);

   if l_lock then
     hr_data_pump.message('Foreign key locking enforced');
   else
     hr_data_pump.message('***** Foreign key locking NOT enforced *****');
   end if;
end set_dt_foreign_locking;

/*
 *  Procedure to select important startup
 *  data for the master process.
 */
procedure get_startup_info
(
   p_batch_id     in  number,
   p_pap_group_id in  number,
   p_env          out nocopy master_env_r,
   p_batch_status out nocopy varchar2
) is
l_found       boolean;
l_bg_name     hr_pump_batch_headers.business_group_name%type;
l_batch_name  hr_pump_batch_headers.batch_name%type;
begin
   -- Give some defaults for the startup info.
   p_env.business_group_id := null;
   p_env.security_group_id := null;
   p_env.range_size  := RANGE_SIZE_DEFAULT;
   p_env.threads     := THREADS_DEFAULT;
   p_env.error_limit := ERRORS_DEFAULT;
   p_env.pap_group_id := p_pap_group_id;

   --
   -- Test-and-set the batch header.
   --
   headerTAS
   (p_batch_id            => p_batch_id
   ,p_business_group_id   => p_env.business_group_id
   ,p_batch_name          => l_batch_name
   ,p_business_group_name => l_bg_name
   ,p_security_group_id   => p_env.security_group_id
   ,p_batch_status        => p_batch_status
   );

   --
   -- Handle case of incorrect business group name.
   --
   if l_bg_name is not null and p_env.business_group_id is null then
     message('BUSINESS_GROUP_NAME[1]: ' || l_bg_name);
     hr_utility.set_message (800, 'HR_7208_API_BUS_GRP_INVALID');
     hr_utility.raise_error;
   end if;

   -- Get information about range size and
   -- threads parameters.  Defaults have already
   -- been set.  There do not have to be any rows.
   get_action_parameter
   (p_para_name  => 'CHUNK_SIZE'
   ,p_para_value => p_env.range_size
   ,p_found      => l_found
   );
   -- Check for reasonable values.
   if(not l_found or p_env.range_size < 1 or p_env.range_size > 100) then
      p_env.range_size := RANGE_SIZE_DEFAULT;
   end if;

   get_action_parameter
   (p_para_name  => 'THREADS'
   ,p_para_value => p_env.threads
   ,p_found      => l_found
   );
   -- Check for reasonable values.
   if(not l_found or p_env.threads < 1 or p_env.threads > 100) then
      p_env.threads := THREADS_DEFAULT;
   end if;

   get_action_parameter
   (p_para_name  => 'MAX_ERRORS_ALLOWED'
   ,p_para_value => p_env.error_limit
   ,p_found      => l_found
   );
   -- Check for reasonable values.
   if(not l_found or p_env.error_limit < 0) then
      p_env.error_limit := ERRORS_DEFAULT;
   end if;

   hr_data_pump.message('range      : ' || p_env.range_size);
   hr_data_pump.message('threads    : ' || p_env.threads);
   hr_data_pump.message('max errors : ' || p_env.error_limit);

exception
  when others then
    raise;

end get_startup_info;

/*
 *  Procedure to insert a row in the ranges table.
 *  Before insert, it checks that the range
 *  is not empty.
 */
procedure insert_range
(
   p_batch_id      in number,
   p_range_info    in range_info_r
) is
begin
   hr_data_pump.entry('insert_range');

   -- Check that there are actually some rows
   -- in the range we are about to insert.
   if(p_range_info.rows_in_range > 0) then
      insert into hr_pump_ranges (
              batch_id,
              range_number,
              range_status,
              starting_process_sequence,
              ending_process_sequence)
      values (p_batch_id,
              p_range_info.range_number,
              'U',
              p_range_info.range_start,
              p_range_info.range_end);
   end if;

   hr_data_pump.exit('insert_range');
end insert_range;

/*
 *  Procedure to insert range rows for parallelisation.
 *  Note that these rows are inserted afresh on every
 *  run on the process.  This function should not be
 *  called if there are rows in existence.
 */
function process_ranges
(
   p_env      in master_env_r,
   p_batch_id in number
) return number is
   -- Cursor returning rows to process.
   cursor c1 is
   select pbl.batch_line_id,
          pbl.link_value
   from   hr_pump_batch_lines pbl
   where  pbl.batch_id    = p_batch_id
   and    pbl.line_status <> 'C'
   order by nvl(pbl.user_sequence, pbl.batch_line_id);

   c1rec c1%rowtype;

   l_range_info   range_info_r;
   l_proc_seq     number;
   l_prv_link_val hr_pump_batch_lines.link_value%type;
begin
   hr_data_pump.entry('process_ranges');

   -- Initialise the variables for range insertion.
   l_range_info.rows_in_range := 0;
   l_range_info.range_number  := 0;
   l_range_info.range_start   := 1;
   l_range_info.range_end     := 0;

   l_proc_seq     := 0;
   l_prv_link_val := null;

   -- Use explicit cursor, because we want
   -- to examine the row fetched attribute.
   open c1;

   /*
    *  This section processes the batch lines we
    *  return from the cursor, deciding how these
    *  rows should be divided up into ranges.
    *  The only real difficulty here is ensuring
    *  that contiguous rows with the same
    *  link_value are inserted into the same
    *  range.
    */
   loop
      fetch c1 into c1rec;

      -- Look for no rows found at all condition.  i.e.
      -- we have no ranges to insert at all.
      exit when c1%notfound and l_proc_seq = 0;

      -- Must increment this value here.
      l_range_info.rows_in_range := l_range_info.rows_in_range + 1;

      -- Increment the absolute processing sequence.
      l_proc_seq := l_proc_seq + 1;

      if(c1%found) then
         -- This update will control the order in which
         -- rows are processed by the slave process.
         update hr_pump_batch_lines pbl
         set    pbl.process_sequence = l_proc_seq
         where  pbl.batch_line_id    = c1rec.batch_line_id;
      end if;

      -- Check if there is a new range to insert.
      -- We have a new range if we have the following
      -- conditions:
      -- Have reached end of rows to process or
      -- we have gone over range limit and the rows are not linked.
      if(c1%notfound
         or (l_range_info.rows_in_range > p_env.range_size and
            (c1rec.link_value is null or l_prv_link_val is null or
             c1rec.link_value <> l_prv_link_val))
        )
      then
         -- Set values for range before insert.
         l_range_info.range_end := l_proc_seq - 1;
         l_range_info.range_number := l_range_info.range_number + 1;

         -- Perform the insert of the previous range.
         insert_range(p_batch_id, l_range_info);
         range_ins_debug(l_range_info);

         -- Set values for new range.
         l_range_info.rows_in_range := 1;  -- already one row in range.
         l_range_info.range_start   := l_proc_seq;
      end if;

      -- We need to exit now if no row found.
      exit when c1%notfound;

      -- Finally, set previous link value
      l_prv_link_val := c1rec.link_value;
   end loop;

   close c1;

   return(l_range_info.range_number);

   hr_data_pump.exit('process_ranges');

end process_ranges;

/*
 *  This procedure spawns the slave processes on
 *  the concurrent manager.
 */
procedure start_slaves
(
   p_env       in master_env_r,
   p_batch_id  in number,
   p_validate  in varchar2 default 'N',
   p_num_ranges in number
) is
   l_count      number;
   l_request_id number;
   l_slaves     number;
begin
   hr_data_pump.entry('start_slaves');

   -- Start one less than threads.
   l_slaves := p_env.threads - 1;

   if (l_slaves > (p_num_ranges - 1)) then
     l_slaves := p_num_ranges - 1;
   end if;


   -- Start the slave processes.
   for l_count in 1..l_slaves loop

      hr_data_pump.message('fnd_request.submit_request : ' || l_count);

      l_request_id := fnd_request.submit_request
      (
         application => 'PER',
         program     => 'DATAPUMP_SLAVE',
         description => null,
         sub_request => FALSE,
         argument1   => to_char(p_env.business_group_id),
         argument2   => to_char(p_env.security_group_id),
         argument3   => to_char(p_batch_id),
         argument4   => to_char(p_env.error_limit),
         argument5   => p_validate
        ,argument6   => to_char(p_env.pap_group_id)
      );

      hr_data_pump.message('l_request_id : ' || l_request_id);

   end loop;

   hr_data_pump.exit('start_slaves');
end start_slaves;

/*
 *  This procedure calls the API wrapper module.
 *  It is the wrapper that calls the API itself.
 *  This wrapper has to be called dynamically.
 */
procedure call_wrapper
(
   p_business_group_id in number,
   p_batch_line_id     in number,
   p_api_module_id     in number,
   p_module_package    in varchar2,
   p_module_name       in varchar2
) is
   l_package_name   varchar2(30);
   l_view_name      varchar2(30);  -- don't actually need this.
   l_call_string    varchar2(2000);
   l_cache_entry    number;
begin

   hr_data_pump.entry('call_wrapper');

   -- Start by parsing the call if necessary.
   -- It may not be if the information is
   -- already in the wrapper cache.
   l_cache_entry := null;
   for i in 1 .. g_wrapper_cache.count loop
     if g_wrapper_cache(i).api_module_id = p_api_module_id then
       l_cache_entry := i;
       exit;
     end if;
   end loop;

   if(l_cache_entry is null) then
      -- Not in cache - will need to parse.
      -- Start by getting the appropriate name.
      hr_pump_utils.name(p_module_package, p_module_name,
                         l_package_name, l_view_name);

      -- Build call string.
      l_call_string := 'begin ' || l_package_name || '.' ||
                       'call(:p_business_group_id, :p_batch_line_id); end;';

      -- Store details of the wrapper.
      l_cache_entry := g_wrapper_cache.count + 1;
      g_wrapper_cache(l_cache_entry).api_module_id := p_api_module_id;
      g_wrapper_cache(l_cache_entry).call_string := l_call_string;

   else
      -- Get the call string for run.
      l_call_string := g_wrapper_cache(l_cache_entry).call_string;
      g_senv.wcachehit := g_senv.wcachehit + 1;  -- count for debug.
   end if;

   /*
    *  Execute the call. API module debug is now done by the generated
    *  code itself.
    */
   g_senv.wrap_total := g_senv.wrap_total + 1;  -- count for debug.

-- show batch_line_id
   if(g_debug.batch_line_info) then
     message('p_batch_line_id - ' || p_batch_line_id);
   end if;

   --
   -- Setup for multi-message support.
   -- 1. Clear the message list.
   -- 2. Reset multi message error flag.
   --
   hr_multi_message.enable_message_list;
   hr_pump_utils.set_multi_msg_error_flag(false);

   -- Call the API.
   execute immediate l_call_string
   using   in p_business_group_id
   ,       in p_batch_line_id
   ;

   --
   -- If there are multi-message errors then raise the exception. The
   -- exception cannot be propagated out from the call block because
   -- it gets converted to an unhandled user exception.
   --
   if hr_pump_utils.multi_msg_errors_exist then
      raise hr_multi_message.error_message_exist;
   end if;

   hr_data_pump.exit('call_wrapper');

end call_wrapper;

/*
 * Updates results for a range. Used at after the API have been executed
 * to:
 * DELETE existing rows from HR_PUMP_BATCH_EXCEPTIONS.
 * UPDATE HR_PUMP_BATCH_LINES LINE_STATUS.
 * INSERT rows into HR_PUMP_BATCH_EXCEPTIONS.
 */
procedure update_range_results
(p_failed_lines in dbms_sql.number_table
,p_exc_ids      in dbms_sql.number_table
,p_exc_text     in dbms_sql.varchar2_table
,p_ls_ids       in dbms_sql.number_table
,p_ls_statuses  in dbms_sql.varchar2s
) is
lbound binary_integer;
ubound binary_integer;
nrows  binary_integer;
begin
   hr_data_pump.entry('update_range_results');

   -- Delete the existing HR_PUMP_BATCH_EXCEPTIONS rows.
   lbound := 1;
   nrows := 250;
   while lbound <=  p_failed_lines.count loop
      ubound := lbound + nrows - 1;
      if ubound > p_failed_lines.count then
        ubound := p_failed_lines.count;
      end if;

      FORALL i IN lbound .. ubound
         delete from hr_pump_batch_exceptions e
         where  e.source_id = p_failed_lines(i)
         and    e.source_type = 'BATCH_LINE'
         ;

      lbound := lbound + nrows;
   end loop;

   -- Update  HR_PUMP_BATCH_LINES LINE_STATUS values.
   lbound := 1;
   nrows := 500;
   while lbound <=  p_ls_ids.count loop
      ubound := lbound + nrows - 1;
      if ubound > p_ls_ids.count then
        ubound := p_ls_ids.count;
      end if;

      FORALL i IN lbound .. ubound
         update hr_pump_batch_lines bl
         set    bl.line_status = p_ls_statuses(i)
         where  bl.batch_line_id = p_ls_ids(i);

      lbound := lbound + nrows;
   end loop;

   -- Insert new batch exceptions.
   lbound := 1;
   nrows := 100;
   while lbound <=  p_exc_ids.count loop
      ubound := lbound + nrows - 1;
      if ubound > p_exc_ids.count then
        ubound := p_exc_ids.count;
      end if;

      FORALL i IN lbound .. ubound
         insert into hr_pump_batch_exceptions
         (exception_sequence
         ,exception_level
         ,source_id
         ,source_type
         ,format
         ,exception_text
         )
         values
         (hr_pump_batch_exceptions_s.nextval
         ,'F'
         ,p_exc_ids(i)
         ,'BATCH_LINE'
         ,'TRANSLATED'
         ,p_exc_text(i)
         );

      lbound := lbound + nrows;
   end loop;

   hr_data_pump.exit('update_range_results');
end update_range_results;

/*
 * Handle API exceptions.
 */
procedure handle_api_exc
(p_multi_msg_error in            boolean
,p_module_package  in            varchar2
,p_module_name     in            varchar2
,p_batch_line_id   in            number
,p_exc_ids         in out nocopy dbms_sql.number_table
,p_exc_text        in out nocopy dbms_sql.varchar2_table
) is
l_message     varchar2(4000);
l_msg_index   number;
l_which_msg   number := fnd_msg_pub.g_first;
i             number;
l_procedure   varchar2(128);
l_ret         boolean;
begin
   -- Record the batch line that errored.
   g_senv.fail_bline := p_batch_line_id;

   --
   -- For debugging purposes, we look at function
   -- that outputs information about get_id failures.
   --
   get_id_failure;

   --
   -- API can implement multi-message support, but still raise an
   -- unrelated exception e.g. because of a locking failure. Add
   -- this to the message list. This should handle apps messages
   -- and non-apps messages cleanly.
   --
   -- Adding to the message list is appropriate as it preserves
   -- order and avoids problems with expanding message text for
   -- FND_MESSAGE.RAISE_ERROR case.
   --
   if not p_multi_msg_error then
      -- Use the API name as the error source.
      l_procedure := p_module_package || '.' || p_module_name;

      l_ret := hr_multi_message.unexpected_error_add(l_procedure);
   end if;

   --
   -- Update hr_pump_batch_exceptions error text list.
   --
   i := p_exc_ids.count + 1;
   for j in 1 .. fnd_msg_pub.count_msg loop
      --
      -- Standard multi-message code handling.
      --
      fnd_msg_pub.get
      (p_msg_index     => l_which_msg
      ,p_encoded       => fnd_api.g_false
      ,p_data          => l_message
      ,p_msg_index_out => l_msg_index
      );
      l_which_msg := fnd_msg_pub.g_next;

      p_exc_ids(i) := p_batch_line_id;
      p_exc_text(i) := l_message;

      i := i + 1;
   end loop;
end handle_api_exc;

/*
 *  Process all the batch lines in current range.
 */
procedure proc_lines_in_range
(
   p_batch_id          in  number,
   p_business_group_id in  number,
   p_security_group_id in  number,
   p_max_errors        in  binary_integer,
   p_validate          in  boolean,
   p_atomic_calls      in  boolean,
   p_range_start       in  number,
   p_range_end         in  number
) is
   cursor c1 is
   select pbl.batch_line_id
   ,      pbl.line_status
   ,      ham.api_module_id
   ,      ham.module_package
   ,      ham.module_name
   ,      pbl.link_value
   ,      grp.business_group_id
   ,      grp.security_group_id
   ,      pbl.business_group_name
   from   hr_pump_batch_lines pbl
   ,      hr_api_modules      ham
   ,      per_business_groups_perf grp
   where  pbl.batch_id      = p_batch_id
   and    ham.api_module_id = pbl.api_module_id
   and    pbl.process_sequence between
          p_range_start and p_range_end
   and    pbl.line_status <> 'C'
   and    grp.name (+)= pbl.business_group_name
   order by pbl.process_sequence;

   cursor c2(p_business_group_name in varchar2) is
   select business_group_id
   ,      security_group_id
   from   per_business_groups_perf
   where  name = p_business_group_name
   ;

   l_prv_link_val   hr_pump_batch_lines.link_value%type;
   l_err_mode       boolean;
   l_err_count      number;   -- count for this range only.
   l_bus_group_id   number;
   l_sec_group_id   number;

   -- Previous and this call are not linked.
   l_unlinked_calls boolean;

   -- Maximum errors exceeded during this execution.
   l_max_errors     boolean;

   --
   -- List of HR_PUMP_BATCH_LINES rows previously in error. This is
   -- used to delete existing exception lines.
   --
   l_failed_lines   dbms_sql.number_table;

   --
   -- Exceptions list. This is used to update HR_PUMP_BATCH_EXCEPTIONS.
   --
   l_exc_ids        dbms_sql.number_table;
   l_exc_text       dbms_sql.varchar2_table;

   --
   -- List for holding HR_PUMP_BATCH_LINES LINE_STATUS. This is used
   -- to update the LINE_STATUS column.
   --
   l_ls_statuses    dbms_sql.varchar2s;
   l_ls_ids         dbms_sql.number_table;
   l_ls_link_start  number;
   l_ls_pos         number;

   --
   -- Flag to indicate early loop termination e.g. after MAX_ERRORS_ALLOWED
   -- exceeded for this thread.
   --
   l_complete       boolean;

   -- Process errors after API exceptions.
   l_process_errors boolean;
begin

   hr_data_pump.entry('proc_lines_in_range');

   -- Initialise variables.
   l_prv_link_val := null;
   l_err_mode     := FALSE;
   l_err_count    := 0;
   l_max_errors   := false;
   l_complete     := false;
   l_process_errors := false;

   g_senv.rangetotal := g_senv.rangetotal + 1;   -- count for debug.

   --
   -- Set up savepoint so that the validate code may rollback all API results.
   --
   savepoint before_api_calls;

   for c1rec in c1 loop
      -- Count rows for debug purposes.
      g_senv.lines_proc := g_senv.lines_proc + 1;

      -- Set up failed lines list.
      if c1rec.line_status = 'E' then
        l_failed_lines(l_failed_lines.count + 1) := c1rec.batch_line_id;
      end if;

      -- Set up line status list.
      l_ls_pos := l_ls_ids.count + 1;
      l_ls_ids(l_ls_pos) := c1rec.batch_line_id;
      l_ls_statuses(l_ls_pos) := 'U';

      /*
       *  Check if we should call the wrapper.  The condition
       *  ensures that we do not call the wrapper if there
       *  was a previous error and we are processing items
       *  related by link_value - i.e. if one fails, the
       *  rest of the related items must not be processed.
       *
       *  Note: code can carry on after MAX_ERRORS_ALLOWED is
       *  exceeded.
       */

      l_unlinked_calls := c1rec.link_value is null or
                          l_prv_link_val is null or
                          c1rec.link_value <> l_prv_link_val;

      if not l_max_errors and (not l_err_mode or l_unlinked_calls) then

         begin
            --
            -- Set a SAVEPOINT to ROLLBACK failed API call. For atomic
            -- calls this is only done at the start of a set of linked
            -- calls.
            --
            if not p_atomic_calls or l_unlinked_calls then
               savepoint before_call_wrapper;

               if p_atomic_calls then
                  l_ls_link_start := l_ls_pos;
               end if;
            end if;

            --
            -- The batch line-specific business group information
            -- overrides that from the batch header.
            --
            if c1rec.business_group_name is not null and
               c1rec.business_group_id is null then
              --
              -- A business group name is present on the row, but it was
              -- not possible to match it against PER_BUSINESS_GROUPS.
              -- This may be because the business group was created by
              -- an API call earlier in the batch; such a business group
              -- is not picked up in the C1 rowset. In this case, use the
              -- C2 cursor to match the business group.
              --
              open c2(p_business_group_name => c1rec.business_group_name);
              fetch c2
              into  l_bus_group_id
              ,     l_sec_group_id
              ;
              if c2%notfound then
                close c2;
                --
                -- No match occurred, something is wrong with the batch
                -- setup.
                --
                message
                ('BUSINESS_GROUP_NAME[2]: ' || c1rec.business_group_name);
                --
                -- Initialise code for output of error message.
                --
                hr_multi_message.enable_message_list;
                hr_pump_utils.set_multi_msg_error_flag(false);
                --
                hr_utility.set_message (800, 'HR_7208_API_BUS_GRP_INVALID');
                hr_utility.raise_error;
              end if;
              close c2;
            else
               --
               -- Either BUSINESS_GROUP_NAME IS NULL or a match has been
               -- made. In the former case, override with the passed-in
               -- values (from HR_PUMP_BATCH_HEADERS).
               --
               l_bus_group_id :=
               nvl(c1rec.business_group_id, p_business_group_id);
               l_sec_group_id :=
               nvl(c1rec.security_group_id, p_security_group_id);
            end if;

            -- Set the security_group_id in the CLIENT_INFO before each
            -- API call, because a previous API call may have overridden
            -- a previous setting.
            hr_api.set_security_group_id(l_sec_group_id);
            -- Call the wrapper module.
            call_wrapper(l_bus_group_id, c1rec.batch_line_id,
                         c1rec.api_module_id, c1rec.module_package,
                         c1rec.module_name);

            -- If we reach here, no exception raised so
            -- able to reset the error mode.

            l_err_mode := FALSE;

            -- Record success by setting status.
            if (p_validate) then
               --
               -- Update range result table entry to say that line
               -- validated okay.
               --
               l_ls_statuses(l_ls_pos) := 'V';
            else
               l_ls_statuses(l_ls_pos) := 'C';
            end if;
         /*
          *  Deal with exceptions raised at batch line level.
          *  these do not cause failure of the entire process
          *  until they exceed the pre-set count.
          */
         exception
            when hr_multi_message.error_message_exist then
               l_process_errors := true;

               --
               -- Do the minimum necessary error handling here.
               --
               handle_api_exc
               (p_multi_msg_error => true
               ,p_module_package  => c1rec.module_package
               ,p_module_name     => c1rec.module_name
               ,p_batch_line_id   => c1rec.batch_line_id
               ,p_exc_ids         => l_exc_ids
               ,p_exc_text        => l_exc_text
               );

            when others then
               l_process_errors := true;

               --
               -- Do the minimum necessary error handling here.
               --
               handle_api_exc
               (p_multi_msg_error => false
               ,p_module_package  => c1rec.module_package
               ,p_module_name     => c1rec.module_name
               ,p_batch_line_id   => c1rec.batch_line_id
               ,p_exc_ids         => l_exc_ids
               ,p_exc_text        => l_exc_text
               );
         end;

         --
         -- Common error handling code.
         --
         if l_process_errors then

            l_process_errors := false;
            l_err_mode := true;

            --
            -- Undo the API call (or linked calls for atomic linked calls).
            --
            rollback to before_call_wrapper;

            --
            -- Set LINE_STATUS for the failed line.
            --
            l_ls_statuses(l_ls_pos) := 'E';

            --
            -- Set LINE_STATUS to R (ROLLED BACK) for atomic linked calls.
            --
            if p_atomic_calls and l_ls_pos <>  l_ls_link_start then
               for i in l_ls_link_start .. l_ls_pos - 1 loop
                  l_ls_statuses(i) := 'R';
               end loop;
            end if;

            -- Need to close C2.
            if c2%isopen then
              close c2;
            end if;

            l_err_count := l_err_count + 1;   -- count for this range.

            --
            -- Check if maximum errors exceeded.
            --
            g_senv.errortotal := g_senv.errortotal + 1;
            if g_senv.errortotal >= p_max_errors then

               l_max_errors := true;

               --
               -- For atomic linked calls some work still needs to be
               -- done. In all other cases, the work is complete.
               --
               l_complete := (not p_atomic_calls);
            end if;
         end if;

      --
      -- If one of the atomic linked calls had failed, the remaining
      -- linked calls must be set to status 'N' (not processed). This
      -- status allows Data Pump Purge to completely remove failed
      -- atomic linked calls as a set.
      --
      elsif l_err_mode and p_atomic_calls and not l_unlinked_calls then
         l_ls_statuses(l_ls_pos) := 'N';

      --
      -- The code was finishing off after MAX_ERRORS_ALLOWED was
      -- exceeded. This happens for atomic calls. The code has reached
      -- an unlinked API so do tidy up and set completion flag.
      --
      elsif l_max_errors then

         --
         -- Delete any information for this line from the lists.
         --
         if l_failed_lines.count > 0 and
            l_failed_lines(l_failed_lines.count) = c1rec.batch_line_id
         then
            l_failed_lines.delete(l_failed_lines.count);
         end if;

         l_ls_ids.delete(l_ls_pos);
         l_ls_statuses.delete(l_ls_pos);

         l_complete := true;
      end if;

      --
      -- Exit the loop early if necessary.
      --
      exit when l_complete;

      --
      -- Important to set this whether or not an exception occurred.
      --
      l_prv_link_val := c1rec.link_value;
   end loop;

   ----------------------------
   -- API EXECUTION COMPLETE --
   ----------------------------

   --
   -- Rollback all the API results in validate mode.
   --
   if p_validate then
      rollback to before_api_calls;
   end if;

   --
   -- Delete the old exception lines, update the line status and
   -- exception text.
   --
   update_range_results
   (p_failed_lines => l_failed_lines
   ,p_exc_ids      => l_exc_ids
   ,p_exc_text     => l_exc_text
   ,p_ls_ids       => l_ls_ids
   ,p_ls_statuses  => l_ls_statuses
   );

   --
   -- COMMIT the results.
   --
   commit;

   -- Output debugging.  Note error count is for this range.
   range_proc_debug(p_range_start, p_range_end, l_err_count);

   hr_data_pump.exit('proc_lines_in_range');

   --
   -- If MAXIMUM_ERRORS_ALLOWED exceeded, need to raise an error.
   --
   if l_max_errors then
      -- Raise error to exit completely.
      hr_utility.set_message (800, 'HR_7269_ASS_TOO_MANY_ERRORS');
      hr_utility.raise_error;
   end if;

end proc_lines_in_range;

/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

------------------------------- internal_slave --------------------------------
/*
  NAME
    internal_slave
  DESCRIPTION
    Internal entry point for slave process.
  NOTES
    This interface is called from either the master process
    when it becomes a 'slave' or from the direct concurrent
    manager interface.
*/
procedure internal_slave
(
   errbuf              out nocopy varchar2,
   retcode             out nocopy number,
   p_business_group_id in  number,
   p_security_group_id in  number,
   p_batch_id          in  number,
   p_max_errors        in  binary_integer,
   p_validate          in  varchar2 default 'N',
   p_single_threaded   in  boolean  default false
) is
   l_batch_status       varchar2(1);
   l_range_rowid        urowid;
   l_range_start        number;
   l_range_end          number;
   l_range_count        number;
   l_encoded            varchar2(2000);   -- hold AOL encoded text.
   l_validate           boolean;
   l_data_migrator_mode varchar2(30);
   l_found              boolean := false;
   l_pap_value          pay_action_parameters.parameter_value%type;
   l_csr_range_rows     range_fetch_cursor_t;
   l_atomic_calls       boolean;
begin

   hr_data_pump.entry('internal_slave');

   if p_single_threaded then
     hr_data_pump.message('SINGLE-THREADED');
   else
     hr_data_pump.message('MULTI-THREADED');
   end if;

   -- Initialise the slave environment record.
   -- Do this here rather than in initialisation
   -- section, because we might be running several times
   -- from one sqlplus session (for debugging and the like)
   -- which would mean these would not get re-set.
   g_senv.lines_proc := 0;
   g_senv.wcachehit  := 0;
   g_senv.wrap_total := 0;
   g_senv.errortotal := 0;
   g_senv.rangetotal := 0;
   g_senv.fail_bline := NULL;
   g_senv.single_threaded := p_single_threaded;

   if ( p_validate = 'Y' ) then
      l_validate := true;
   else
      l_validate := false;
   end if;

   -- Get any further required information from HR_PUMP_BATCH_HEADERS.
   header_read
   (p_batch_id            => p_batch_id
   ,p_atomic_linked_calls => l_atomic_calls
   );

   --
   -- Set global for data_migrator_mode. Only do this if the global
   -- has a value of 'N'.
   --
   hr_data_pump.entry('g_data_migrator_mode'||hr_general.g_data_migrator_mode);
   --
   l_data_migrator_mode := hr_general.g_data_migrator_mode;
   --
   if hr_general.g_data_migrator_mode = 'N' then
     get_action_parameter
     (p_para_name  => 'DATA_MIGRATOR_MODE'
     ,p_para_value => l_pap_value
     ,p_found      => l_found
     );
     if l_found then
       -- hr_general.g_data_migrator_mode is a varchar2(1).
       l_pap_value := substr(l_pap_value, 1, 1);
       --
       -- In case a stupid value has been put into the parameter set it
       -- back to 'N' in this case.
       --
       if l_pap_value not in ('P','Y','N') then
         l_pap_value := 'N';
       end if;
       hr_general.g_data_migrator_mode := l_pap_value;
     end if;
   end if;
   --
   hr_data_pump.entry('g_data_migrator_mode'||hr_general.g_data_migrator_mode);
   --
   -- Disable the FND audit.
   --
   disable_audit;
   --
   -- Disable Continuous Calc.
   --
   disable_cont_calc;
   --
   -- Disable lookup checks.
   --
   disable_lookup_checks;
   --
   -- Set Date-Track foreign key locking.
   --
   set_dt_foreign_locking;
   --
   -- Mark this session as a running Data Pump session.
   --
   hr_pump_utils.set_current_session_running(p_running => true);

   /*
    *  Main processing loop.  We attempt to grab a
    *  range of batch lines to process until there
    *  are none left.
    */
   loop
      --
      -- Open the cursor. Use an ORDER BY for the single-threaded case.
      --
      if g_senv.single_threaded then
         hr_data_pump.message('RR:SINGLE-THREADED');
         open l_csr_range_rows for
         select hpr.rowid,
                hpr.starting_process_sequence,
                hpr.ending_process_sequence
         from   hr_pump_ranges        hpr,
                hr_pump_batch_headers pbh
         where  hpr.batch_id     = p_batch_id
         and    hpr.range_status = 'U'
         and    pbh.batch_id     = hpr.batch_id
         and    pbh.batch_status <> 'E'
         order by
                hpr.starting_process_sequence
         for update of
                hpr.starting_process_sequence, pbh.batch_status
         ;
      else
         hr_data_pump.message('RR:MULTI-THREADED');
         open l_csr_range_rows for
         select hpr.rowid,
                hpr.starting_process_sequence,
                hpr.ending_process_sequence
         from   hr_pump_ranges        hpr,
                hr_pump_batch_headers pbh
         where  hpr.batch_id     = p_batch_id
         and    hpr.range_status = 'U'
         and    pbh.batch_id     = hpr.batch_id
         and    pbh.batch_status <> 'E'
         and    rownum           < 2   -- only get one row
         for update of
                hpr.starting_process_sequence, pbh.batch_status
         ;
      end if;

      fetch l_csr_range_rows
      into  l_range_rowid
      ,     l_range_start
      ,     l_range_end
      ;
      --
      -- There are no more unprocessed range rows or the batch has
      -- errored, so exit the loop.
      --
      if l_csr_range_rows%notfound then
         close l_csr_range_rows;
         exit;
      end if;
      close l_csr_range_rows;

      -- Change status to show we are processing this.
      update hr_pump_ranges hpr
      set    hpr.range_status = 'P'
      where  hpr.rowid = l_range_rowid;

      commit;  -- release the lock.

      -- Call procedure to process the current range.
      proc_lines_in_range (p_batch_id, p_business_group_id,
                           p_security_group_id,
                           p_max_errors, l_validate,
                           l_atomic_calls,
                           l_range_start, l_range_end);

      -- Finished with range, so remove it and commit.
      delete from hr_pump_ranges hpr
      where  hpr.rowid = l_range_rowid;
      commit;

   end loop;

   /*
    *  If we are exiting the loop, this means we could not
    *  lock a row.  This normally indicates we have finished
    *  but might mean another slave has errored and we have
    *  to exit.  Therefore, attempt to update the batch status
    *  as appropriate to what has happened.
    */

   -- Attempt to lock the row.
   select pbh.batch_status
   into   l_batch_status
   from   hr_pump_batch_headers pbh
   where  pbh.batch_id = p_batch_id
   for update of pbh.batch_status;

   -- Check the current status.
   -- Only want to change it if still processing.
   if(l_batch_status = 'P') then
      -- Need to know if we are the last process
      -- still working.  See if this is so by
      -- looking for any ranges still processing.
      select count(*)
      into   l_range_count
      from   hr_pump_ranges hpr
      where  hpr.batch_id = p_batch_id;

      if(l_range_count = 0) then
         -- We are the last, so update the batch status.
         update hr_pump_batch_headers pbh
         set    pbh.batch_status = 'C'
         where  pbh.batch_id     = p_batch_id;
      end if;
   end if;

   -- Show success information.
   exit_info;

   -- release any locks.
   commit;

   -- reset value of g_data_migrator

   hr_general.g_data_migrator_mode := l_data_migrator_mode;

   --
   -- This is no longer a running Data Pump session.
   --
   hr_pump_utils.set_current_session_running(p_running => false);

   hr_data_pump.exit('internal_slave');

/*
 *  Deal with any exceptions that came through.  This would
 *  most likely be the 'too many errors' error, although it
 *  might not be.
 */
exception
when others then
   if l_csr_range_rows%isopen then
     close l_csr_range_rows;
   end if;

   rollback;

   if l_range_rowid is not null then
     delete from hr_pump_ranges hpr
     where  hpr.rowid = l_range_rowid;
   end if;

   errbuf := post_error(sqlcode, sqlerrm, null, 'F', 'BATCH_HEADER',
                        p_batch_id);
   commit;

   -- Call debug logging.
   stack_dump;

   -- reset value of g_data_migrator

   hr_general.g_data_migrator_mode := l_data_migrator_mode;

   -- Set the exit conditions.
   retcode := 2;   -- error.

   --
   -- This is no longer a running Data Pump session.
   --
   hr_pump_utils.set_current_session_running(p_running => false);

end internal_slave;

---------------------------------- slave --------------------------------------
/*
  NAME
    slave
  DESCRIPTION
    Entry point for slave process.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
    The only difference is the SRS interface sets the debug
    and inserts a pump request row - both of which would already
    have been done if the slave is called directly from the master.
*/

procedure slave
(
   errbuf              out nocopy varchar2,
   retcode             out nocopy number,
   p_business_group_id in  number,
   p_security_group_id in  number,
   p_batch_id          in  number,
   p_max_errors        in  binary_integer,
   p_validate          in  varchar2 default 'N'
  ,p_pap_group_id      in  number   default null
) is
begin
   --
   -- Set action_parameter_group_id. This must be done before any
   -- code that accesses PAY_ACTION_PARAMETERS.
   --
   pay_core_utils.set_pap_group_id(p_pap_group_id => p_pap_group_id);

   -- Set any requested debug.
   set_debug;

   -- Insert a pump request row.
   ins_pump_request(p_batch_id, 'SLAVE');

   -- Start by assuming success.
   errbuf := null;
   retcode := 0;

   internal_slave(errbuf, retcode, p_business_group_id,
                  p_security_group_id,
                  p_batch_id, p_max_errors, p_validate);

   -- Delete the pump request row.
   del_pump_request(p_batch_id);
   commit;
end slave;

---------------------------------- main ---------------------------------------
/*
  NAME
    main
  DESCRIPTION
    Main entry point for Data Pump engine.
  NOTES
    This procedure should be called via the concurrent manager.
    Under normal circumstances, it should NOT be called directly.
*/

procedure main
(
   errbuf     out nocopy varchar2,
   retcode    out nocopy number,
   p_batch_id in  number,   -- batch_id
   p_validate in  varchar2 default 'N'
  ,p_pap_group_id in number default null
) is
   l_env          master_env_r;
   l_batch_status varchar2(1);
   l_processing   boolean := false;
   l_num_ranges   number;
begin

   -- Start by assuming success.
   errbuf := null;
   retcode := 0;

   --
   -- Set action_parameter_group_id. This must be done before any
   -- code that accesses PAY_ACTION_PARAMETERS.
   --
   pay_core_utils.set_pap_group_id(p_pap_group_id => p_pap_group_id);

   -- Set any requested debug.
   set_debug;

   hr_data_pump.message('p_batch_id : ' || p_batch_id);

   -- Get startup information for this process.
   -- Return batch status while we are at it.
   get_startup_info(p_batch_id, p_pap_group_id, l_env, l_batch_status);

   hr_data_pump.message('l_batch_status : ' || l_batch_status);

   --
   -- Only enter main processing if we are not doing so already.
   --
   if l_batch_status is not null and l_batch_status <> 'P' then

      -- Delete any existing pump request rows.
      delete from hr_pump_requests hpr
      where  hpr.batch_id = p_batch_id;

      -- Insert a new pump request row.
      ins_pump_request(p_batch_id, 'MASTER');

      -- Remove any messages that are might exist for
      -- the batch header.
      delete from hr_pump_batch_exceptions e
      where  e.source_id = p_batch_id
      and    e.source_type = 'BATCH_HEADER';

      -- We delete any existing range rows for this batch_id each time
      -- the process runs.
      delete from hr_pump_ranges where batch_id = p_batch_id;
      commit;

      -- Call the appropriate function
      -- to insert new range rows.
      l_num_ranges := process_ranges(l_env, p_batch_id);

      -- All ranges inserted, so commit;
      commit;

      -- Start slave processes.
      if l_num_ranges >0 then
        start_slaves(l_env, p_batch_id, p_validate, l_num_ranges);
      end if;

      -- The master becomes the slave....
      internal_slave(errbuf, retcode, l_env.business_group_id,
                     l_env.security_group_id,
                     p_batch_id, l_env.error_limit, p_validate, l_env.threads = 1);

      -- Delete the pump request row.
      del_pump_request(p_batch_id);

   --
   -- The batch was not found.
   --
   elsif l_batch_status is null then
     hr_utility.set_message(800, 'HR_33798_DP_BATCH_NOT_FOUND');
     hr_utility.set_message_token('BATCH_ID', to_char(p_batch_id));
     hr_utility.raise_error;

   --
   -- The batch is already being processed.
   --
   else
      -- Raise an error.
      l_processing := true;
      hr_utility.set_message(800, 'HR_50329_DP_ALREADY_PROCESSING');
      hr_utility.raise_error;
   end if;

   -- Ensure all commited before exit.
   commit;

exception
when others then
   rollback;

   --
   -- Write error to the exceptions table for this batch header.
   --
   if l_batch_status is not null then
     errbuf :=
     post_error(sqlcode, sqlerrm, null, 'F', 'BATCH_HEADER', p_batch_id,
                l_processing);
   else
     --
     -- No batch available.
     --
     errbuf := sqlerrm;
   end if;

   commit;

   -- Set exit code.
   retcode := 2;
end main;

----------------------------
--* DATA PUMP PURGE CODE *--
----------------------------

------------------------------- purgeEOC --------------------------------------
/*
   NAME
     purgeEOC purge End-Of-Chunk
   Description
     Carries End-Of-Chunk purge processing.
*/
procedure purgeEOC
(p_chunk_size in            number
,p_work_to_do    out nocopy boolean
)
is
begin
  --
  -- If all possible rows were not  processed then there is still work to
  -- do.
  --
  p_work_to_do := (sql%rowcount = p_chunk_size);
  --
  -- If rows were processed then commit the changes;
  --
  if sql%found then
    commit;
  end if;
end purgeEOC;

------------------------------- purgelines ------------------------------------
/*
   NAME
     purgelines
   Description
     Purge HR_PUMP_BATCH_LINES rows with a specified status.
*/
procedure purgelines
(p_batch_id    in number
,p_chunk_size  in number
,p_line_status in varchar2
) is
l_work_to_do boolean;
begin
  hr_data_pump.message('HR_PUMP_BATCH_LINES:' || p_line_status);

  l_work_to_do := true;
  while l_work_to_do loop
    delete
    from   hr_pump_batch_lines l
    where  l.batch_id = p_batch_id
    and    l.line_status = p_line_status
    and    rownum <= p_chunk_size
    ;
    --
    purgeEOC
    (p_chunk_size => p_chunk_size
    ,p_work_to_do => l_work_to_do
    );
  end loop;
end purgelines;

------------------------- purgeorphanuserkeys ---------------------------------
/*
   NAME
     purgeorphanuserkeys
   Description
     Purge orphaned user keys i.e. those with NULL BATCH_LINE_ID.
*/
procedure purgeorphanuserkeys
(p_chunk_size in number
,p_thread_number in     number
,p_threads       in     number
,p_write_log     in     boolean default false
,p_lower_bound   in     number
,p_upper_bound   in     number
,p_error_message out nocopy varchar2
) is
l_work_to_do boolean;
l_message    fnd_new_messages.message_text%type;
begin
  hr_data_pump.message('HR_PUMP_BATCH_LINE_USER_KEYS:BATCH_LINE_ID IS NULL');

  p_error_message := null;

  l_work_to_do := true;
  while l_work_to_do loop
    delete
    from   hr_pump_batch_line_user_keys uk
    where  uk.batch_line_id is null
    and    uk.user_key_id between
           p_lower_bound and p_upper_bound
    and    rownum <= p_chunk_size
    ;
    --
    purgeEOC
    (p_chunk_size => p_chunk_size
    ,p_work_to_do => l_work_to_do
    );
  end loop;
  ---------------------------------------
  -- Write success message to the log. --
  ---------------------------------------
  hr_utility.set_message(800, 'HR_33796_DP_PURGED_USER_KEYS');
  l_message := hr_utility.get_message;
  if p_write_log then
    fnd_file.put_line(fnd_file.log, l_message);
  end if;

  hr_data_pump.message(l_message);

exception
  when others then
    hr_utility.set_message(800, 'HR_33797_DP_USER_KEY_PURGE_ERR');
    hr_utility.set_message_token('ERROR_MESSAGE', sqlerrm);
    l_message := hr_utility.get_message;
    p_error_message := l_message;
    if p_write_log then
      fnd_file.put_line(fnd_file.log, l_message);
    end if;

    hr_data_pump.message(l_message);
    return;
end purgeorphanuserkeys;

------------------------------- purgebatch ------------------------------------
/*
  NAME
    purgebatch
  DESCRIPTION
    Internal purge routine for the data pump engine.
  NOTES
    This procedure purges a single batch. It is called from the concurrent
    manager routines.
*/
procedure purgebatch
(p_batch_id           in            number
,p_chunk_size         in            number
,p_write_log          in            boolean default false
,p_preserve_user_keys in            boolean
,p_purge_unprocessed  in            boolean
,p_purge_errored      in            boolean
,p_purge_completed    in            boolean
,p_delete_header      in            boolean
,p_error_message         out nocopy varchar2
) is
l_work_to_do          boolean;
l_status              varchar2(32);
l_business_group_name hr_pump_batch_headers.business_group_name%type;
l_batch_name          hr_pump_batch_headers.batch_name%type;
l_business_group_id   number;
l_security_group_id   number;
l_message             fnd_new_messages.message_text%type;
l_count               number;
begin
  p_error_message := null;
  ----------------------------------------
  -- 1. Check and set the batch header. --
  ----------------------------------------
  headerTAS
  (p_batch_id            => p_batch_id
  ,p_business_group_id   => l_business_group_id
  ,p_batch_name          => l_batch_name
  ,p_business_group_name => l_business_group_name
  ,p_security_group_id   => l_security_group_id
  ,p_batch_status        => l_status
  );
  --
  -- This header is already being processed.
  --
  if l_status = 'P' then
    hr_utility.set_message(800, 'HR_50329_DP_ALREADY_PROCESSING');
    hr_utility.raise_error;
  elsif l_status is null then
    --
    -- Batch does not exist - it may have been purged already.
    --
    return;
  end if;

  hr_data_pump.message('PURGE: ' || l_batch_name);

  -----------------------------------------------------
  -- 2. Preserve or delete user keys for this batch. --
  -----------------------------------------------------
  hr_data_pump.message('HR_PUMP_BATCH_LINE_USER_KEYS');

  l_work_to_do := true;
  while l_work_to_do loop
    if p_preserve_user_keys then
      update hr_pump_batch_line_user_keys uk
      set    uk.batch_line_id = null
      where  uk.batch_line_id in
             (
               select bl.batch_line_id
               from   hr_pump_batch_lines bl
               where  bl.batch_id = p_batch_id
             )
      and rownum <= p_chunk_size
      ;
    else
      delete
      from   hr_pump_batch_line_user_keys uk
      where  uk.batch_line_id in
             (
               select l.batch_line_id
               from   hr_pump_batch_lines l
               where  l.batch_id = p_batch_id
             )
      and rownum <= p_chunk_size
      ;
    end if;
    --
    purgeEOC
    (p_chunk_size => p_chunk_size
    ,p_work_to_do => l_work_to_do
    );
  end loop;

  ----------------------------------------------------
  -- 3. Delete the batch exceptions for this batch. --
  ----------------------------------------------------
  hr_data_pump.message('HR_PUMP_BATCH_EXCEPTIONS');

  l_work_to_do := true;
  while l_work_to_do loop
    delete
    from   hr_pump_batch_exceptions e
    where  (
             (
               e.source_id = p_batch_id and
               e.source_type = 'BATCH_HEADER'
             ) or
             (
               e.source_id in
               (
                 select l.batch_line_id
                 from   hr_pump_batch_lines l
                 where  l.batch_id = p_batch_id
               ) and
               e.source_type = 'BATCH_LINE'
             )
           )
    and rownum <= p_chunk_size;
    --
    purgeEOC
    (p_chunk_size => p_chunk_size
    ,p_work_to_do => l_work_to_do
    );
  end loop;

  -----------------------------------------------
  -- 4. Delete the batch lines for this batch. --
  -----------------------------------------------
  if p_purge_completed then
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'C'
    );
  end if;
  --
  if p_purge_errored then
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'E'
    );
    --
    -- Lines that had to be ROLLED BACK with ATOMIC linked APIs are effectively in
    -- error. Also, linked APIs that were not processed because of an error in a linked
    -- call are also in error. The relevant line statuses are R and N, respectively.
    --
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'R'
    );
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'N'
    );
  end if;
  if p_purge_unprocessed then
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'U'
    );
    --
    purgelines
    (p_batch_id    => p_batch_id
    ,p_chunk_size  => p_chunk_size
    ,p_line_status => 'V'
    );
  end if;

  ----------------------------------------------
  -- 5. Delete the range rows for this batch. --
  ----------------------------------------------
  hr_data_pump.message('HR_PUMP_RANGES');

  l_work_to_do := true;
  while l_work_to_do loop
    delete
    from   hr_pump_ranges r
    where  r.batch_id = p_batch_id
    and    rownum <= p_chunk_size
    ;
    --
    purgeEOC
    (p_chunk_size => p_chunk_size
    ,p_work_to_do => l_work_to_do
    );
  end loop;

  ------------------------------------------------------------
  -- 6. Delete the batch header or update the batch status. --
  ------------------------------------------------------------
  hr_data_pump.message('HR_PUMP_BATCH_HEADERS');

  delete from hr_pump_requests
  where  batch_id = p_batch_id;
  if p_delete_header then

    --
    -- Only do the delete if there are no remaining batch lines.
    --
    select count(*)
    into   l_count
    from   hr_pump_batch_lines
    where  batch_id = p_batch_id
    ;

    if l_count = 0 then
      delete
      from   hr_pump_batch_headers
      where  batch_id = p_batch_id
      ;
    else
      update hr_pump_batch_headers
      set    batch_status = 'C'
      where  batch_id = p_batch_id;
    end if;
  else
    update hr_pump_batch_headers
    set    batch_status = 'C'
    where  batch_id = p_batch_id;
  end if;
  --
  commit;

  ---------------------------------------
  -- Write success message to the log. --
  ---------------------------------------
  hr_utility.set_message(800, 'HR_33794_DP_COMPLETED_BATCH');
  hr_utility.set_message_token('BATCH_NAME', l_batch_name);
  l_message := hr_utility.get_message;
  if p_write_log then
    fnd_file.put_line(fnd_file.log, l_message);
  end if;

  hr_data_pump.message(l_message);

exception
  when others then
    hr_utility.set_message(800, 'HR_33795_DP_PROCESSING_ERROR');
    hr_utility.set_message_token('BATCH_NAME', l_batch_name);
    hr_utility.set_message_token('ERROR_MESSAGE', sqlerrm);
    l_message := hr_utility.get_message;
    p_error_message := l_message;
    if p_write_log then
      fnd_file.put_line(fnd_file.log, l_message);
    end if;

    hr_data_pump.message(l_message);

    --
    -- Reset the batch header.
    --
    update hr_pump_batch_headers
    set    batch_status = 'E'
    where  batch_id = p_batch_id;
    --
    commit;
end purgebatch;

------------------------------- purgeslave ------------------------------------
procedure purgeslave
(errbuf                  out nocopy varchar2
,retcode                 out nocopy number
,p_batch_id           in            number   default null
,p_all_batches        in            varchar2 default 'N'
,p_preserve_user_keys in            varchar2 default 'N'
,p_purge_unprocessed  in            varchar2 default 'Y'
,p_purge_errored      in            varchar2 default 'Y'
,p_purge_completed    in            varchar2 default 'Y'
,p_delete_header      in            varchar2 default 'Y'
,p_chunk_size         in            number
,p_thread_number      in            number
,p_threads            in            number
,p_pap_group_id       in            number
,p_lower_bound        in            number
,p_upper_bound        in            number
) is
l_all_batches        boolean;
l_preserve_user_keys boolean;
l_purge_unprocessed  boolean;
l_purge_errored      boolean;
l_purge_completed    boolean;
l_delete_header      boolean;
l_error              boolean;
l_error_message      fnd_new_messages.message_text%type;
--
-- Cursor to restrict the processed batches.
--
cursor csr_batches
(p_lower_bound in number
,p_upper_bound in number
) is
select h.batch_id
from   hr_pump_batch_headers h
where  h.batch_id between
       p_lower_bound and p_upper_bound
and    h.batch_status <> 'P'
;
begin
  --
  -- Start by assuming success.
  --
  errbuf := null;
  retcode := 0;
  l_error := false;

  ----------------------------
  -- 1. Process parameters. --
  ----------------------------

  --
  -- Set action_parameter_group_id. This must be done before any
  -- code that accesses PAY_ACTION_PARAMETERS.
  --
  pay_core_utils.set_pap_group_id(p_pap_group_id => p_pap_group_id);

  --
  -- Process debugging options.
  --
  set_debug;

  hr_data_pump.message('THREAD_NUMBER:' || to_char(p_thread_number));
  hr_data_pump.message('LOWER_BOUND:' || to_char(p_lower_bound));
  hr_data_pump.message('UPPER_BOUND:' || to_char(p_upper_bound));

  -- Note: interpret as restrictively as possible.
  l_all_batches := upper(p_all_batches) = 'Y';
  l_preserve_user_keys := upper(p_preserve_user_keys) <> 'N';
  l_purge_unprocessed := upper(p_purge_unprocessed) = 'Y';
  l_purge_errored := upper(p_purge_errored) = 'Y';
  l_purge_completed := upper(p_purge_completed) = 'Y';
  l_delete_header := upper(p_delete_header) = 'Y';

  -------------------------------
  -- 2. Process the batch(es). --
  -------------------------------
  if l_all_batches then
    for crec in csr_batches
                (p_lower_bound => p_lower_bound
                ,p_upper_bound => p_upper_bound
                ) loop
      message('ALL_THREADS:BATCH_ID:' || to_char(crec.batch_id));

      purgebatch
      (p_batch_id           => crec.batch_id
      ,p_chunk_size         => p_chunk_size
      ,p_write_log          => true
      ,p_preserve_user_keys => l_preserve_user_keys
      ,p_purge_unprocessed  => l_purge_unprocessed
      ,p_purge_errored      => l_purge_errored
      ,p_purge_completed    => l_purge_completed
      ,p_delete_header      => l_delete_header
      ,p_error_message      => l_error_message
      );

      --
      -- Only set return error status for the first error encountered.
      --
      if not l_error and l_error_message is not null then
        l_error := true;
        retcode := 2;
        errbuf := l_error_message;
      end if;
    end loop;
  elsif p_batch_id is not null then
    purgebatch
    (p_batch_id           => p_batch_id
    ,p_chunk_size         => p_chunk_size
    ,p_write_log          => true
    ,p_preserve_user_keys => l_preserve_user_keys
    ,p_purge_unprocessed  => l_purge_unprocessed
    ,p_purge_errored      => l_purge_errored
    ,p_purge_completed    => l_purge_completed
    ,p_delete_header      => l_delete_header
    ,p_error_message      => l_error_message
    );

    --
    -- Check and set the return error status.
    --
    if l_error_message is not null then
      retcode := 2;
      errbuf := l_error_message;
    end if;
  elsif not l_preserve_user_keys then
    purgeorphanuserkeys
    (p_chunk_size    => p_chunk_size
    ,p_thread_number => p_thread_number
    ,p_threads       => p_threads
    ,p_write_log     => true
    ,p_lower_bound   => p_lower_bound
    ,p_upper_bound   => p_upper_bound
    ,p_error_message => l_error_message
    );

    --
    -- Check and set the return error status.
    --
    if l_error_message is not null then
      retcode := 2;
      errbuf := l_error_message;
    end if;
  end if;

exception
  when others then
    errbuf := sqlerrm;
    retcode := 2;
end purgeslave;

-------------------------------- allocwork ------------------------------------
/*
  NAME
    allocwork
  DESCRIPTION
    Calculates the upper and lower values each slave has to process.

    p_lower, p_upper are set to NULL if calculated p_lower > p_max.

    Otherwise, p_lower and p_upper are allocated values between p_min and
    p_max.
  NOTES
    Expects that p_max >= p_min, and p_increment > 0.
*/
procedure allocwork
(p_increment in            number
,p_thread_no in            number
,p_min       in            number
,p_max       in            number
,p_lower        out nocopy number
,p_upper        out nocopy number
) is
l_upper number;
l_lower number;
begin
  --
  -- Calculate the lower value.
  --
  l_lower := p_min + (p_thread_no * p_increment);

  --
  -- Case 1: Calculated lower is in range.
  --
  if l_lower <= p_max then
    l_upper := l_lower + p_increment - 1;
    if l_upper > p_max then
      l_upper := p_max;
    end if;
  --
  -- Case 2: Calculated lower value is out of range.
  --
  else
    l_lower := null;
    l_upper := null;
  end if;

  p_lower := l_lower;
  p_upper := l_upper;

end allocwork;
-------------------------------- purgemain ------------------------------------
procedure purgemain
(errbuf                  out nocopy varchar2
,retcode                 out nocopy number
,p_batch_id           in            number   default null
,p_all_batches        in            varchar2 default 'N'
,p_preserve_user_keys in            varchar2 default 'N'
,p_purge_unprocessed  in            varchar2 default 'Y'
,p_purge_errored      in            varchar2 default 'Y'
,p_purge_completed    in            varchar2 default 'Y'
,p_delete_header      in            varchar2 default 'Y'
,p_pap_group_id       in            number   default null
) is
l_chunk_size    number;
l_threads       number;
l_increment     number;
l_all_batches   varchar2(32);
l_batch_count   number;
l_request_id    number;
l_found         boolean;
l_min           number;
l_max           number;
l_lower         number;
l_upper         number;
--
-- Find the maximum and minimum BATCH_ID from HR_PUMP_BATCH_HEADERS. The
-- queries utilise the INDEX FULL SCAN (MIN/MAX) optimization.
--
cursor csr_bh_minmax is
select A.maximum
,      B.minimum
from   (select max(batch_id) maximum from hr_pump_batch_headers) A
,      (select min(batch_id) minimum from hr_pump_batch_headers) B
;
--
-- Find maximum and minimum USER_KEY_ID from HR_PUMP_BATCH_LINE_USER_KEYS.
-- This is for case where BATCH_LINE_ID IS NULL but don't include
-- BATCH_LINE_ID to avoid FULL TABLE SCAN.
--
cursor csr_uk_minmax is
select A.maximum
,      B.minimum
from   (select max(user_key_id) maximum from hr_pump_batch_line_user_keys) A
,      (select min(user_key_id) minimum from hr_pump_batch_line_user_keys) B
;
begin
  --
  -- Start by assuming success.
  --
  errbuf := null;
  retcode := 0;

  ----------------------------
  -- 1. Process parameters. --
  ----------------------------

  --
  -- Set action_parameter_group_id. This must be done before any
  -- code that accesses PAY_ACTION_PARAMETERS.
  --
  pay_core_utils.set_pap_group_id(p_pap_group_id => p_pap_group_id);

  --
  -- Process debugging options.
  --
  set_debug;

  get_action_parameter
  (p_para_name  => 'DATA_PUMP_PURGE_CHUNK_SIZE'
  ,p_para_value => l_chunk_size
  ,p_found      => l_found
  );
  if(not l_found or l_chunk_size < 1 or l_chunk_size > 5000) then
    l_chunk_size := PURGE_SIZE_DEFAULT;
  end if;

  get_action_parameter
  (p_para_name  => 'THREADS'
  ,p_para_value => l_threads
  ,p_found      => l_found
  );
  if(not l_found or l_threads < 1 or l_threads > 100) then
    l_threads := THREADS_DEFAULT;
  end if;

  --
  -- Single batch overrides all batches.
  --
  if p_batch_id is null and upper(p_all_batches) = 'Y' then
    l_all_batches := 'Y';
  else
    l_all_batches := 'N';
  end if;

  hr_data_pump.message('P_BATCH_ID:' || to_char(p_batch_id));
  hr_data_pump.message('P_ALL_BATCHES:' || l_all_batches);
  hr_data_pump.message('P_PRESERVE_USER_KEYS:' || p_preserve_user_keys);
  hr_data_pump.message('P_PURGE_UNPROCESSED:' || p_purge_unprocessed);
  hr_data_pump.message('P_PURGE_ERRORED:' || p_purge_errored);
  hr_data_pump.message('P_PURGE_COMPLETED:' || p_purge_completed);
  hr_data_pump.message('P_DELETE_HEADER:' || p_delete_header);
  hr_data_pump.message('P_PAP_GROUP_ID:' || p_pap_group_id);
  hr_data_pump.message('THREADS:' || to_char(l_threads));
  hr_data_pump.message('CHUNK_SIZE:' || to_char(l_chunk_size));

  --
  -- Exit if there is nothing to do.
  --
  if p_all_batches = 'N' and p_batch_id is null and
     upper(p_preserve_user_keys) <> 'N' then
    hr_data_pump.message('NOTHING TO PURGE:ARGS');
    return;
  end if;

  -----------------------------------------------
  -- 2. Allocate threads and run if necessary. --
  -----------------------------------------------
  if l_all_batches = 'Y' or p_batch_id is null then

    --
    -- Case 1: Purging all batches.
    --
    if l_all_batches = 'Y' then
      open csr_bh_minmax;
      fetch csr_bh_minmax
      into  l_max
      ,     l_min
      ;
      if csr_bh_minmax%notfound or l_max is null then
        close csr_bh_minmax;
        hr_data_pump.message('NOTHING TO PURGE:BATCHES');
        return;
      end if;
      close csr_bh_minmax;

      --
      -- Reduce the number of threads if there are more batches than
      -- threads.
      --
      l_batch_count := l_max + 1 - l_min;
      if l_threads > l_batch_count then
        l_threads := ceil(l_batch_count / 2);

        hr_data_pump.message('THREADS(MODIFIED):BATCHES:' || to_char(l_threads));
      end if;

      l_increment := ceil((l_max + 1 - l_min) / l_threads);

      hr_data_pump.message('INCREMENT:BATCHES:' || to_char(l_increment));

    --
    -- Case 2: Purging user keys not connected with any batch.
    --
    elsif upper(p_preserve_user_keys) = 'N' then
      open csr_uk_minmax;
      fetch csr_uk_minmax
      into  l_max
      ,     l_min
      ;
      if csr_uk_minmax%notfound or l_max is null then
        close csr_uk_minmax;
        hr_data_pump.message('NOTHING TO PURGE:USER_KEYS');
        return;
      end if;
      close csr_uk_minmax;

      --
      -- Let each thread process PURGE_MIN_ROWS rows.
      --
      l_batch_count := ceil((l_max + 1 - l_min) / PURGE_MIN_ROWS);
      if l_threads > l_batch_count then
        l_threads := l_batch_count;

        hr_data_pump.message('THREADS(MODIFIED):USER_KEYS:' || to_char(l_threads));
      end if;

      l_increment := ceil((l_max + 1 - l_min) / l_threads);

      hr_data_pump.message('INCREMENT:USER_KEYS:' || to_char(l_increment));
    end if;

    --
    -- Start off the slave threads.
    --
    for thread in 1 .. l_threads - 1 loop
      hr_data_pump.message('FND_REQUEST.SUBMIT_REQUEST: ' || thread);

      allocwork
      (p_increment => l_increment
      ,p_thread_no => thread
      ,p_min       => l_min
      ,p_max       => l_max
      ,p_lower     => l_lower
      ,p_upper     => l_upper
      );

      --
      -- No need to proceed further as this and higher threads have no more work to do.
      --
      if l_lower is null then
        hr_data_pump.message('NO MORE THREADS REQUIRED:' || to_char(thread));
        exit;
      end if;

      l_request_id :=
      fnd_request.submit_request
      (application => 'PER'
      ,program     => 'DATAPUMP_PURGE_SLAVE'
      ,sub_request => FALSE
      ,argument1   => to_char(null)
      ,argument2   => p_all_batches
      ,argument3   => p_preserve_user_keys
      ,argument4   => p_purge_unprocessed
      ,argument5   => p_purge_errored
      ,argument6   => p_purge_completed
      ,argument7   => p_delete_header
      ,argument8   => to_char(l_chunk_size)
      ,argument9   => to_char(thread)
      ,argument10  => to_char(l_threads)
      ,argument11  => to_char(p_pap_group_id)
      ,argument12  => to_char(l_lower)
      ,argument13  => to_char(l_upper)
      );
    end loop;
  --
  -- Single batch will only have a single thread.
  --
  else
    l_threads := 1;

    --
    -- Indicate that allocwork is not to be called.
    --
    l_increment := null;
  end if;

  -------------------------------
  -- 3. Execute slave process. --
  -------------------------------

  if l_increment is not null then
    allocwork
    (p_increment => l_increment
    ,p_thread_no => 0
    ,p_min       => l_min
    ,p_max       => l_max
    ,p_lower     => l_lower
    ,p_upper     => l_upper
    );
  end if;

  purgeslave
  (errbuf               => errbuf
  ,retcode              => retcode
  ,p_batch_id           => p_batch_id
  ,p_all_batches        => l_all_batches
  ,p_preserve_user_keys => p_preserve_user_keys
  ,p_purge_unprocessed  => p_purge_unprocessed
  ,p_purge_errored      => p_purge_errored
  ,p_purge_completed    => p_purge_completed
  ,p_delete_header      => p_delete_header
  ,p_chunk_size         => l_chunk_size
  ,p_thread_number      => 0
  ,p_threads            => l_threads
  ,p_pap_group_id       => p_pap_group_id
  ,p_lower_bound        => l_lower
  ,p_upper_bound        => l_upper
  );

exception
  when others then
    if csr_bh_minmax%isopen then
      close csr_bh_minmax;
    end if;

    if csr_uk_minmax%isopen then
      close csr_uk_minmax;
    end if;

    errbuf := sqlerrm;
    retcode := 2;
end purgemain;

/*
 *  Data Pump initialisation section.
 */
begin
   -- Any package init here.
   null;

end hr_data_pump;

/
