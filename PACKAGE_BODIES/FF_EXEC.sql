--------------------------------------------------------
--  DDL for Package Body FF_EXEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_EXEC" as
/* $Header: ffexec.pkb 120.4.12000000.1 2007/01/17 17:44:40 appldev noship $ */
/*
  NOTES
    See ffrunf.lld for design documentation.
*/
/*---------------------------------------------------------------------------*/
/*----------------------- constant definitions ------------------------------*/
/*---------------------------------------------------------------------------*/
/*
 *  Values that formula indicator variables can hold.
 *  The FF_WAS_DEFAULTED is to indicate when a database
 *  item was defaulted.
 */
FF_NULL            constant binary_integer := 0;
FF_NOT_NULL        constant binary_integer := -1;
FF_WAS_DEFAULTED   constant binary_integer := -2;

/*
 *  Cache size limits and default.  No maximum specified, as
 *  should let the user find that!
 */
FF_DFLT_CACHE_SIZE constant binary_integer := 300;
FF_MIN_CACHE_SIZE  constant binary_integer := 5;
FF_MAX_CACHE_SIZE  constant binary_integer := 5120;

/*  increment value for database item cache values */
DBI_CACHE_INCR     constant binary_integer := 64;

/* Invalid position in parameter table. */
INVALID_POS        constant binary_integer := -1;

/* Action parameter to control formula execution mode. */
USE_FF_WRAPPER     constant varchar2(128)  := 'FF_USE_PLSQL_WRAPPER';

/* Action parameter to control formula cache size. */
FF_FMLA_CACHE_SIZE constant varchar2(128)  := 'FF_PLSQL_CACHE_SIZE';

/* Number of bits in a context level mask. */
C_MASK_BITS constant binary_integer := 31;

/* Maximum number of active contexts in the cache. */
C_MAX_CONTEXTS constant binary_integer := 62;

/* Data types. */
C_DATE   constant varchar2(10) := 'DATE';
C_NUMBER constant varchar2(10) := 'NUMBER';
C_TEXT   constant varchar2(10) := 'TEXT';

--
-- Exception raised when the wrapper package is invalid or does not exist.
--
CANNOT_FIND_PROG_UNIT exception;
pragma exception_init(CANNOT_FIND_PROG_UNIT, -6508);
--
-- Exception raised when attempting to execute a formula compiled with an
-- out-of-date formula compiler (missing FORMULA interfaces).
--
BAD_PLSQL exception;
pragma exception_init(BAD_PLSQL, -6550);

/*---------------------------------------------------------------------------*/
/*------------- internal execution engine data structures -------------------*/
/*---------------------------------------------------------------------------*/
type t_binary_integer is table of binary_integer index by binary_integer;
type t_small_varchar2 is table of varchar2(10)   index by binary_integer;
type t_big_varchar2   is table of varchar2(300)  index by binary_integer;

/*
 *  This structure holds state information
 *  about the execution engine.
 */
type exec_info_r is record
(
  formula_id      binary_integer, -- currently executing formula.
  cache_slot      binary_integer, -- cache slot in use.
  effective_date  date,     -- effective date used for formula execution.

  fmla_cache_size number,   -- size of the formula cache.

  /*  following allow sanity checking  */
  input_rows      number,   -- rows in the inputs table.
  output_rows     number    -- rows in the outputs table.

  /* Use FF_WRAPPER_PKG instead of dynamic SQL. */
  ,use_ff_wrapper boolean
);

--
-- Lookup type for mapping formula_id -> collection slot.
--
type fmla_lookup_t is table of binary_integer index by binary_integer;

/*-------------- internal execution cache data structures -------------------*/
/*
 *  The Fast Formula cache types.
 *  The cache consists of the following things:
 *  1)  A table of records that is essentially a combination of
 *      info from ff_formulas_f and ff_compiled_info_f.
 *      The formula cache size is limited, and is controlled by
 *      an internal variable.  It defaults to FF_DFLT_CACHE_SIZE.
 *      In addition, a table of records that holds information derived
 *      from the ff_fdi_usages_f table.
 *      NOTE - performula, the in core fdiu is held, ordered by
 *      a combination of class and item name.  i.e.
 *      U (Contexts)
 *      I (inputs), O (outputs), B (both),
 *      D (Database Items)
 *      Within this, the individual entries are ordered by item name.
 *      The reason for this is:
 *      a) Contexts must come before database items (to allow db item
 *         invalidation to work correctly).
 *      b) Make the ordering of the entries in the inputs and outputs
 *         tables predictable to the user, which may be of some benefit.
 *  2)  If the cache is full, then the cache behaves as a circular list.
 *      Formulas are evicted from the cache starting from the first cache
 *      entry and cycling around as necessary. The sticky flag is no
 *      longer used.
 */
type fmla_info_r is record      /* Formula info */
(
  formula_id            binary_integer,
  effective_start_date  date,
  effective_end_date    date,
  formula_name          varchar2(80),
  package_name          varchar2(80),     -- pack.proc we execute.
  first_fdiu            binary_integer,   -- first entry in fdiu for formula.
  fdiu_count            binary_integer,   -- number of fdiu rows.
  context_count         binary_integer,   -- how many contexts?
  input_count           binary_integer,   -- how many inputs?
  output_count          binary_integer    -- how many outputs?
);

--
-- The formula cache. Note: the size must match FF_MAX_CACHE_SIZE.
--
type fmla_info_t is varray(5120) of fmla_info_r;

type fdiu_info_r is record    /* in core fdiu  */
(
  name         varchar2(240),   -- the 'real' name of the item.
  varpos       binary_integer,  -- Position in variable table.
  indpos       binary_integer,  -- Position in indicator table.
  data_type     varchar2(6),     -- valid C_DATE, C_TEXT, C_NUMBER.
  usage        varchar2(1),     -- 'I', 'O', 'B', 'U', 'D'.
  context_sum1 binary_integer,  -- for database items and contexts.
  context_sum2 binary_integer,  -- for database items and contexts.
  context_id   binary_integer,  -- for database items and contexts.
  route_id     binary_integer   -- for database items
);

type fdiu_info_t is table of fdiu_info_r index by binary_integer;

type free_chunk_t is table of binary_integer index by binary_integer;

/*
 *  The database item cache types.
 *  The database item cache consists of three tables that holds details
 *  about contexts and database items as appropriate.  The details of
 *  these are:
 *  o A record and table type to hold the details of the contexts
 *    and database items in the cache.  A separate table is used
 *    for contexts and database items.  In the case of contexts,
 *    it is indexed directly by the context_id.
 *  o Since FF_DATABASE_ITEMS does not have a surrogate primary key,
 *    the formula compiler generates a hashed value, which is not
 *    guaranteed to be unique.  Therefore, the database item cache
 *    is not indexed directly.  Instead, there is a 'hash' data
 *    structure that points to the first possible entry in the
 *    database item cache table and the number of entries for this
 *    hash value.  This allows 'row chaining' to be implemented.
 *  NOTES:
 *    The context_level field is either the context_level of the
 *    context or sum of context dependencies for database items.
 *  o The value field stores the current value for that item.
 *    If it is NULL, it indicates that the value is currently
 *    invalid.  In the case of a database item, it means that we
 *    will need to fetch the value from the database.
 */
type dbi_hash_r is record
(
  first_entry   binary_integer,
  chain_count   binary_integer
);

type dbi_hash_t is table of dbi_hash_r index by binary_integer;

type dbi_cache_r is record   /* dbi and context info */
(
  item_name      ff_database_items.user_name%type,
  context_level1 binary_integer,
  context_level2 binary_integer,
  data_type      varchar2(10),
  dvalue         date,
  nvalue         number,
  tvalue         varchar2(255),       -- matches ff_exec.FF_BIND_LEN
  indicator      binary_integer
);

type dbi_cache_t is table of dbi_cache_r index by binary_integer;
type ctx_cache_t is table of dbi_cache_r index by binary_integer;

/*
 * Data structures for holding dynamic context level sums for routes.
 */
type context_sums_r is record
(
  context_sum1 binary_integer,
  context_sum2 binary_integer
);

type route_ctx_sums_t is table of context_sums_r index by binary_integer;

/*---------------------------------------------------------------------------*/
/*----------------------- execution engine globals --------------------------*/
/*---------------------------------------------------------------------------*/
g_decpoint  varchar2(100);   -- Decimal point character for number/string conversion.
g_exec_info exec_info_r;
g_inited boolean := false;   -- Cache initialised.
g_fmla_lookups fmla_lookup_t; -- Lookup table for formula information table.
g_fmla_info fmla_info_t;     -- formula information.
g_lru_slot  binary_integer;  -- Least-Recently-Used formula slot.
g_fdiu_info fdiu_info_t;     -- in core fdiu information.
g_free_fdiu free_chunk_t;    -- Table of free FDIU chunks.
g_hash_info dbi_hash_t;      -- Hash table for database item cache entries.
g_dbi_info  dbi_cache_t;     -- database item cache entries.
g_ctx_info  dbi_cache_t;     -- context entries.

--
-- g_ctx_levels1 and g_ctx_levels2 are allocated context levels.
-- g_route_ctx_sums caches the context levels for each route.
--
g_route_ctx_sums route_ctx_sums_t;
g_ctx_levels1 binary_integer := 0;
g_ctx_levels2 binary_integer := 0;

-- The next value for entry in database item cache table.
g_next_dbi_index binary_integer := 1;
/*---------------------------------------------------------------------------*/
/*------------------ local functions and procedures -------------------------*/
/*---------------------------------------------------------------------------*/

procedure set_use_ff_wrapper is
l_pap_found boolean;
l_pap_value varchar2(2000);
begin
  --
  -- Look for configuration information in PAY_ACTION_PARAMETERS.
  --
  pay_core_utils.get_action_parameter
  (p_para_name  => USE_FF_WRAPPER
  ,p_para_value => l_pap_value
  ,p_found      => l_pap_found
  );
  --
  g_exec_info.use_ff_wrapper := not l_pap_found or upper(l_pap_value) <> 'N';
end set_use_ff_wrapper;

procedure set_cache_size is
l_pap_found boolean;
l_pap_value varchar2(2000);
begin
  --
  -- Look for configuration information in PAY_ACTION_PARAMETERS.
  --
  begin
    pay_core_utils.get_action_parameter
    (p_para_name  => FF_FMLA_CACHE_SIZE
    ,p_para_value => l_pap_value
    ,p_found      => l_pap_found
    );
    if l_pap_found then
      g_exec_info.fmla_cache_size := trunc(to_number(l_pap_value));
    else
      g_exec_info.fmla_cache_size := null;
    end if;
  exception
    when others then
      g_exec_info.fmla_cache_size := null;
  end;

  if g_exec_info.fmla_cache_size is null then
    g_exec_info.fmla_cache_size := FF_DFLT_CACHE_SIZE;
  elsif g_exec_info.fmla_cache_size < FF_MIN_CACHE_SIZE then
    g_exec_info.fmla_cache_size := FF_MIN_CACHE_SIZE;
  elsif g_exec_info.fmla_cache_size > FF_MAX_CACHE_SIZE then
    g_exec_info.fmla_cache_size := FF_MAX_CACHE_SIZE;
  end if;
end set_cache_size;

/*
 *  Checks if the FF_DEBUG profile has been set, and if so,
 *  whether any of the PLSQL execution engine debug settings
 *  should be enabled.
 */
procedure check_profile_debug is
  l_value       varchar2(300);
  l_exec_debug  boolean := FALSE;
  l_routing     boolean := FALSE;
  l_ff_debug    boolean := FALSE;
  l_ff_cache    boolean := FALSE;
  l_dbi_cache   boolean := FALSE;
  l_mru         boolean := FALSE;
  l_io          boolean := FALSE;
  l_char        varchar2(1);
  l_debug_level binary_integer := 0;
begin
  -- Look for setting of FF_DEBUG profile.
  fnd_profile.get('FF_DEBUG', l_value);

  if(l_value is null) then
    return;
  end if;

  -- Debug setting is possible, process which ones.
  for l_pos in 1..length(l_value) loop
    l_char := substr(l_value, l_pos, 1);  -- get a single character.

    if(l_char = 'X' or l_char = 'x') then
      l_exec_debug := TRUE;
    elsif(l_char = 'R' or l_char = 'r') then
      l_routing := TRUE;
    elsif(l_char = 'F' or l_char = 'f') then
      l_ff_debug := TRUE;
    elsif(l_char = 'C' or l_char = 'c') then
      l_ff_cache := TRUE;
    elsif(l_char = 'D' or l_char = 'd') then
      l_dbi_cache := TRUE;
    elsif(l_char = 'M' or l_char = 'm') then
      l_mru := TRUE;
    elsif(l_char = 'I' or l_char = 'i') then
      l_io := TRUE;
    else
      null;   -- ignore spurious characters.
    end if;

  end loop;

  -- Need to have general execution engine logging set
  -- before we can use the other options.
  if(l_exec_debug) then
    -- Set the appropriate flags.
    if(l_routing) then
      l_debug_level := l_debug_level + ff_utils.ROUTING;
    end if;

    if(l_ff_debug) then
      l_debug_level := l_debug_level + ff_exec.FF_DBG;
    end if;

    if(l_ff_cache) then
      l_debug_level := l_debug_level + ff_exec.FF_CACHE_DBG;
    end if;

    if(l_dbi_cache) then
      l_debug_level := l_debug_level + ff_exec.DBI_CACHE_DBG;
    end if;

    if(l_mru) then
      l_debug_level := l_debug_level + ff_exec.MRU_DBG;
    end if;

    if(l_io) then
      l_debug_level := l_debug_level + ff_exec.IO_TABLE_DBG;
    end if;

    -- Set the global flag.
    ff_utils.g_debug_level := l_debug_level;

  end if;

end check_profile_debug;

/*
 *  Debug proceure to output information about formula
 *  cache contents for a specific formula.
 *  This procedure is overloaded.
 */
procedure fmla_cache_debug
(
  fid            in binary_integer,         -- formula_id
  p_fmla_lookups in fmla_lookup_t,
  p_fmla_info    in fmla_info_t,
  p_fdiu_info    in fdiu_info_t
) is

  name         varchar2(240);
  varpos       varchar2(100);
  indpos       varchar2(100);
  data_type     varchar2(10);
  usage        varchar2(10);
  class        varchar2(10);
  context_sum1 varchar2(30);
  context_sum2 varchar2(30);
  context_id   varchar2(10);
  first        binary_integer;
  last         binary_integer;
  i            binary_integer;
  fmla_info    fmla_info_r;
  fdiu_info    fdiu_info_r;

begin
  -- Check the debug flag settting.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
    -- Debug level set correctly, output debug information for
    -- specific formula.

    hr_utility.trace('');
    hr_utility.trace('FMLA CACHE info for formula_id ' || fid);
    hr_utility.trace('--------------------------------------');
    fmla_info := p_fmla_info(p_fmla_lookups(fid));
    hr_utility.trace('Eff Start   : ' ||
         to_char(fmla_info.effective_start_date, 'DD-MON-YYYY'));
    hr_utility.trace('Eff End     : ' ||
         to_char(fmla_info.effective_end_date, 'DD-MON-YYYY'));
    hr_utility.trace('Fmla Name   : ' || fmla_info.formula_name);
    hr_utility.trace('Package     : ' || fmla_info.package_name);
    hr_utility.trace('First FDIU  : ' || fmla_info.first_fdiu);
    hr_utility.trace('FDIU Count  : ' || fmla_info.fdiu_count);
    hr_utility.trace('Ctx count   : ' || fmla_info.context_count);
    hr_utility.trace('In count    : ' || fmla_info.input_count);
    hr_utility.trace('Out count   : ' || fmla_info.output_count);

    -- Output information about the fdiu rows.
    first := fmla_info.first_fdiu;
    last  := first + fmla_info.fdiu_count - 1;

    hr_utility.trace('');
    hr_utility.trace('FDIU ROWS');
    hr_utility.trace('[FDIU]Item Name           V[POS]     I[POS]     ' ||
                     'Dtype  U  CSum1    CSum2    ContextId');
    hr_utility.trace('------------------------- ---------- ---------- ' ||
                     '------ - --------- --------- ----------');

    for i in first..last loop
      fdiu_info := p_fdiu_info(i);

      /*  build up strings first, for clarity */
      name         := rpad(fdiu_info.name,               25) || ' ';
      varpos       := rpad(fdiu_info.varpos,             10) || ' ';
      indpos       := rpad(fdiu_info.indpos,             10) || ' ';
      data_type     := rpad(fdiu_info.data_type,            6 ) || ' ';
      usage        := rpad(fdiu_info.usage,               1 ) || ' ';
      context_sum1 := lpad(fdiu_info.context_sum1,        9 ) || ' ';
      context_sum2 := lpad(fdiu_info.context_sum2,        9 ) || ' ';
      context_id   := lpad(fdiu_info.context_id,         10);

      hr_utility.trace(name || varpos || indpos || data_type || usage ||
                       class || context_sum1 || context_sum2 ||
                       context_id);

    end loop;

  end if;
end fmla_cache_debug;

/*
 *  Debug procedure for db item cache.
 */
procedure dbi_cache_debug
(
  p_ctx_info  in dbi_cache_t,
  p_dbi_info  in dbi_cache_t,
  p_hash_info in dbi_hash_t
) is
  l_index        varchar2(20);
  item_name      varchar2(240);
  context_level1 varchar2(30);
  context_level2 varchar2(30);
  value          varchar2(255);
  indicator      number;
  first_entry    varchar2(80);
  chain_count    varchar2(80);
  i              binary_integer;

begin
  -- Check the debug flag settting.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  if(bitand(ff_utils.g_debug_level, ff_exec.DBI_CACHE_DBG) <> 0) then
    -- Debug level set correctly, output debug information for
    -- database item cache.
    hr_utility.trace('');
    hr_utility.trace('[DBI]Indx DbItem/Context Name Ctx Level1  Ctx Level2' ||
                      ' Value');
    hr_utility.trace('--------- ------------------- ----------- ----------- ' ||
                     '-----------------------------');

    /*
     *  Information about the contexts.
     */
    i := p_ctx_info.first;

    while(i is not null) loop

      value := '<NULL>';
      if p_ctx_info(i).data_type = C_DATE then
        if p_ctx_info(i).dvalue is not null then
          value := fnd_date.date_to_canonical( p_ctx_info(i).dvalue );
        end if;
      elsif  p_ctx_info(i).data_type = C_NUMBER then
        if p_ctx_info(i).nvalue is not null then
          value := replace(to_char(p_ctx_info(i).nvalue), g_decpoint, '.');
        end if;
      else
        if p_ctx_info(i).tvalue is not null then
          value := p_ctx_info(i).tvalue;
        end if;
      end if;

      -- Set up variables first, for clarity.
      l_index        := lpad(i,                             9) || ' ';
      item_name      := rpad(p_ctx_info(i).item_name,      20) || ' ';
      context_level1 := lpad(p_ctx_info(i).context_level1, 11) || ' ';
      context_level2 := lpad(p_ctx_info(i).context_level2, 11) || ' ';

      -- Now output the string.
      hr_utility.trace(l_index || item_name || context_level1 || context_level2 ||
                       value);

      i := p_ctx_info.next(i);

    end loop;

    /*
     *   Information about the database items.
     */
    i := p_dbi_info.first;

    while(i is not null) loop

      value := null;
      if p_dbi_info(i).indicator = FF_NOT_NULL then
        if p_dbi_info(i).data_type = C_DATE then
          value := fnd_date.date_to_canonical( p_dbi_info(i).dvalue );
        elsif  p_dbi_info(i).data_type = C_NUMBER then
          value := replace(to_char(p_dbi_info(i).nvalue), g_decpoint, '.');
        else
          value := p_dbi_info(i).tvalue;
        end if;
      end if;
      value := nvl(value, '<NULL>');
      value := value || ' ';

      -- Set up variables first, for clarity.
      l_index        := lpad(i,                             9) || ' ';
      item_name      := rpad(p_dbi_info(i).item_name,      20) || ' ';
      context_level1 := lpad(p_dbi_info(i).context_level1, 11) || ' ';
      context_level2 := lpad(p_dbi_info(i).context_level2, 11) || ' ';
      indicator      := p_dbi_info(i).indicator;

      -- Now output the string.
      hr_utility.trace(l_index || item_name || context_level1 || context_level2 ||
                       value || indicator);

      i := p_dbi_info.next(i);

    end loop;

    /*
     *  Information about db item hash table.
     */

    hr_utility.trace('[HSH]Indx     First     Count');
    hr_utility.trace('--------- --------- ---------');

    i := p_hash_info.first;

    while(i is not null) loop

      -- Set up variables first, for clarity.
      l_index       := lpad(i,                            9) || ' ';
      first_entry   := lpad(p_hash_info(i).first_entry,   9) || ' ';
      chain_count   := lpad(p_hash_info(i).chain_count,   9);

      -- Now output the string.
      hr_utility.trace(l_index || first_entry || chain_count);

      i := p_hash_info.next(i);

    end loop;

  end if;

end dbi_cache_debug;

/*
 *  Output some info about the invalidation of database
 *  items in the cache.
 */
procedure dbi_invalid_debug
(
  p_dbi_info     in dbi_cache_r,
  p_context_sum1 in binary_integer,
  p_context_sum2 in binary_integer
) is
  item_name      varchar2(240);
  context_level1 varchar2(30);
  context_sum1   varchar2(30);
  context_level2 varchar2(30);
  context_sum2   varchar2(30);
  value          varchar2(255);
begin
  -- Check the debug flag settting.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  if(bitand(ff_utils.g_debug_level, ff_exec.DBI_CACHE_DBG) <> 0) then

    item_name      := rpad(p_dbi_info.item_name,     20) || ' ';
    context_level1 := lpad(p_dbi_info.context_level1,10) || ' ';
    context_sum1   := lpad(p_context_sum1,           10) || ' ';
    context_level2 := lpad(p_dbi_info.context_level2,10) || ' ';
    context_sum2   := lpad(p_context_sum2,           10) || ' ';


    value := null;
    if p_dbi_info.indicator = FF_NOT_NULL then
      if p_dbi_info.data_type = C_DATE then
        value := fnd_date.date_to_canonical( p_dbi_info.dvalue );
      elsif  p_dbi_info.data_type = C_NUMBER then
         value := replace(to_char(p_dbi_info.nvalue), g_decpoint, '.');
      else
         value := p_dbi_info.tvalue;
      end if;
    end if;
    value := nvl(value, '<NULL>');

    hr_utility.trace('INVAL: ' || item_name || context_level1 ||
                     context_level2 || context_sum1 || context_sum2 ||
                     value);

  end if;

end dbi_invalid_debug;

/*
 *  Log information about a changed context.
 */
procedure ctx_change_debug
(
  p_item_name      in varchar2,
  p_context_level1 in binary_integer,
  p_context_level2 in binary_integer,
  p_old_value      in varchar2,
  p_new_value      in varchar2
) is
  item_name      varchar2(240);
  context_level1 varchar2(30);
  context_level2 varchar2(30);
  old_value      varchar2(255);
  new_value      varchar2(255);
begin
  -- Check the debug flag settting.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  if(bitand(ff_utils.g_debug_level, ff_exec.DBI_CACHE_DBG) <> 0) then

    item_name      := rpad(p_item_name,     20) || ' ';
    context_level1 := lpad(p_context_level1, 10) || ' ';
    context_level2 := lpad(p_context_level2, 10) || ' ';
    old_value      := nvl(p_old_value, '<NULL>') || ' ';
    new_value      := nvl(p_new_value, '<NULL>');

    hr_utility.trace('CTXCH: ' || item_name || context_level1 ||
                      context_level2 || old_value || new_value);
  end if;

end ctx_change_debug;

/*
 *  Input and Output table information.
 */
procedure io_table_debug
(
  p_inputs  in ff_exec.inputs_t,
  p_outputs in ff_exec.outputs_t,
  p_type    in varchar2
) is
  l_index       varchar2(20);
  name          varchar2(240);
  data_type      varchar2(20);
  class         varchar2(20);
  value         varchar2(255);
  i             binary_integer;

begin
  -- Check the debug flag settting.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  if(bitand(ff_utils.g_debug_level, ff_exec.IO_TABLE_DBG) <> 0) then
    -- Debug level set correctly, output debug information for
    -- input table information.

   if(p_type = 'INPUT') then

       /*
        *  Inputs table information.
        */

       hr_utility.trace('');
       hr_utility.trace('[IT]Index Input/Context Name             ' ||
                        'Dtype   Class   Value');
       hr_utility.trace('--------- ------------------------------ ' ||
                        '------- ------- -----------------------');

       i := p_inputs.first;

       while(i is not null) loop

         -- Set up variables first, for clarity.
         l_index       := lpad(i,                    9) || ' ';
         name          := rpad(p_inputs(i).name,    30) || ' ';
         data_type     := rpad(p_inputs(i).datatype, 7) || ' ';
         class         := rpad(p_inputs(i).class,    7) || ' ';
         value         := nvl(p_inputs(i).value, '<NULL>');

         -- Now output the string.
         hr_utility.trace(l_index || name || data_type || class || value);

         i := p_inputs.next(i);

       end loop;

    elsif(p_type = 'OUTPUT') then

       /*
        *  Outputs table information.
        */

       hr_utility.trace('');
       hr_utility.trace('[OT]Index Input/Context Name             ' ||
                        'Dtype   Value');
       hr_utility.trace('--------- ------------------------------ ' ||
                        '------- -------------------------------');

       i := p_outputs.first;

       while(i is not null) loop

         -- Set up variables first, for clarity.
         l_index       := lpad(i,                     9) || ' ';
         name          := rpad(p_outputs(i).name,    30) || ' ';
         data_type     := rpad(p_outputs(i).datatype, 7) || ' ';
         value         := nvl(p_outputs(i).value, '<NULL>');

         -- Now output the string.
         hr_utility.trace(l_index || name || data_type || value);

         i := p_outputs.next(i);

       end loop;

   end if;

  end if;

end io_table_debug;

------------------------------- find_free_chunk -------------------------------
/*
  NAME
    find_free_chunk
  DESCRIPTION
    Finds a free chunk to reuse and updates the free chunk list
    accordingly.
*/
procedure find_free_chunk
(p_chunk_size  in            number
,p_free_chunks in out nocopy free_chunk_t
,p_start          out nocopy number
) is
l_first_free binary_integer;
l_candidate  binary_integer := null;
i            binary_integer;
begin

  --
  -- Dump out the free chunk list.
  --
  if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
    hr_utility.trace('<- Free Chunk List ->');
    i := p_free_chunks.first;
    loop
      exit when not p_free_chunks.exists(i);

      hr_utility.trace('(' || i || ',' || p_free_chunks(i) || ')');

      i := p_free_chunks.next(i);
    end loop;
  end if;

  p_start := null;

  if p_chunk_size = 0 then
    return;
  end if;

  l_first_free := p_free_chunks.first;
  loop
    exit when not p_free_chunks.exists(l_first_free);

    --
    -- Got a suitable candidate free chunk. It should be
    -- as small as possible.
    --
    if p_free_chunks(l_first_free) >= p_chunk_size then
      if l_candidate is null or
         p_free_chunks(l_first_free) < p_free_chunks(l_candidate) then
        l_candidate := l_first_free;
      end if;
    end if;

    l_first_free := p_free_chunks.next(l_first_free);
  end loop;

  --
  -- Got a candidate.
  --
  if l_candidate is not null then

    --
    -- Adjust chunk if space is left. Take space from the end of the
    -- chunk to avoid having to delete the record.
    --
    if p_free_chunks(l_candidate) > p_chunk_size then
      p_free_chunks(l_candidate) :=
      p_free_chunks(l_candidate) - p_chunk_size;

      p_start := l_candidate + p_free_chunks(l_candidate);
    --
    -- The chunk is exactly p_chunk_size in length. Delete the
    -- record.
    --
    else
      p_start := l_candidate;
      p_free_chunks.delete(l_candidate);
    end if;

    if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
      hr_utility.trace('Reuse chunk:'||l_candidate||','||p_chunk_size);
    end if;

  end if;
end find_free_chunk;

------------------------------ add_to_free_list ------------------------------
/*
  NAME
    add_to_free_list
  DESCRIPTION
    Puts a range of rows onto the free list.
*/
procedure add_to_free_list
(p_first_chunk   in            binary_integer
,p_chunk_count   in            binary_integer
,p_free_chunks   in out nocopy free_chunk_t
) is
l_first_chunk binary_integer;
l_assertion  boolean;
l_next       binary_integer;
--
procedure chunk_merge
(p_free_chunks  in out nocopy free_chunk_t
,p_merge_index  in            binary_integer
,p_count1       in            binary_integer
,p_count2       in            binary_integer
,p_delete_index in            binary_integer
) is
begin
  p_free_chunks(p_merge_index) := p_count1 + p_count2;

  if p_delete_index is not null then
    p_free_chunks.delete(p_delete_index);
  end if;
end chunk_merge;
--
begin
  if p_chunk_count = 0 then
    return;
  end if;

  l_first_chunk := p_free_chunks.first;
  loop
    exit when not p_free_chunks.exists(l_first_chunk);

    --
    -- Look for overlap errors.
    --
    l_assertion :=
    (p_first_chunk + p_chunk_count - 1 < l_first_chunk) or
    (l_first_chunk + p_free_chunks(l_first_chunk) - 1 < p_first_chunk);

    if not l_assertion then
      if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
        hr_utility.trace
        ('AddToFreeList assert failed:'||p_first_chunk||','||
         to_char(p_chunk_count-1)|| ' overlaps :'||l_first_chunk||','||
         to_char(p_free_chunks(l_first_chunk)-1));
      end if;
    end if;

    ff_utils.assert
    (p_expression => l_assertion
    ,p_location   => 'add_to_free_list:1'
    );

    --
    -- Merge at the end of an existing chunk.
    --
    if p_first_chunk =
       l_first_chunk + p_free_chunks(l_first_chunk) then

      chunk_merge
      (p_free_chunks  => p_free_chunks
      ,p_merge_index  => l_first_chunk
      ,p_count1       => p_free_chunks(l_first_chunk)
      ,p_count2       => p_chunk_count
      ,p_delete_index => null
      );

      --
      -- Merged at low end, now see if it is possible to merge with
      -- the next record to keep the list as short as possible.
      --
      l_next :=  p_free_chunks.next(l_first_chunk);
      if p_free_chunks.exists(l_next) then
        if p_free_chunks(l_first_chunk) + l_first_chunk = l_next then

          chunk_merge
          (p_free_chunks  => p_free_chunks
          ,p_merge_index  => l_first_chunk
          ,p_count1       => p_free_chunks(l_first_chunk)
          ,p_count2       => p_free_chunks(l_next)
          ,p_delete_index => l_next
          );

        end if;
      end if;

      return;
    end if;

    --
    -- Merge at the start of an existing chunk.
    --
    if p_first_chunk + p_chunk_count = l_first_chunk then
      chunk_merge
      (p_free_chunks  => p_free_chunks
      ,p_merge_index  => p_first_chunk
      ,p_count1       => p_free_chunks(l_first_chunk)
      ,p_count2       => p_chunk_count
      ,p_delete_index => l_first_chunk
      );
      return;
    end if;

    l_first_chunk :=  p_free_chunks.next(l_first_chunk);
  end loop;

  --
  -- No merge possible so create a new record.
  --
  p_free_chunks(p_first_chunk) := p_chunk_count;
end add_to_free_list;

---------------------------- find_dbi_cache_entry -----------------------------
/*
  NAME
    find_dbi_cache_entry
  DESCRIPTION
    Finds the real index entry in database item cache.
  NOTES
    Passed the hashed context_id and returns the appropriate index
    value for the database item we are looking for, else null.
*/

function find_dbi_cache_entry
(
  p_context_id in binary_integer,
  p_item_name  in varchar2
) return binary_integer is
  l_start binary_integer;
  l_end   binary_integer;
  l_index binary_integer;
begin

  ff_utils.entry('find_dbi_cache_entry');

  if(not g_hash_info.exists(p_context_id)) then
    -- No entry at all for database item.
    ff_utils.exit('find_dbi_cache_entry');
    return(null);
  end if;

  -- We know there is an entry, need to find out which one.
  l_start := g_hash_info(p_context_id).first_entry;
  l_end   := l_start + g_hash_info(p_context_id).chain_count - 1;

  -- Now search for the appropriate entry.
  for l_count in l_start..l_end loop
    if(g_dbi_info(l_count).item_name = p_item_name) then
      l_index := l_count;
      exit;
    end if;
  end loop;

  ff_utils.exit('find_dbi_cache_entry');

  return(l_index);

end find_dbi_cache_entry;

------------------------------- read_dbi_cache --------------------------------
/*
  NAME
    read_dbi_cache
  DESCRIPTION
    Reads value from database item cache.
  NOTES
    Returns value from database item cache, based on the hashed
    context_id and the name.
*/

procedure read_dbi_cache
(
  p_context_id in binary_integer,
  p_item_name  in varchar2
 ,p_data_type  in varchar2
 ,p_dvalue     out nocopy date
 ,p_nvalue     out nocopy number
 ,p_tvalue     out nocopy varchar2
 ,p_indicator  out nocopy binary_integer
)  is
  l_index binary_integer;
begin

  if g_debug then
    ff_utils.entry('read_dbi_cache');
  end if;

  l_index := find_dbi_cache_entry(p_context_id, p_item_name);

  -- Entry should exist when reading from the cache.
  ff_utils.assert((l_index is not null), 'read_dbi_cache:1');

  if g_debug then
    ff_utils.exit('read_dbi_cache');
  end if;

  -- Simply return the value from cache.
  if g_dbi_info(l_index).indicator = FF_NOT_NULL then
    if p_data_type = C_DATE then
      p_dvalue := g_dbi_info(l_index).dvalue;
    elsif p_data_type = C_NUMBER then
      p_nvalue := g_dbi_info(l_index).nvalue;
    else
      p_tvalue := g_dbi_info(l_index).tvalue;
    end if;
  else
    p_nvalue := NULL;
    p_dvalue := NULL;
    p_tvalue := NULL;
  end if;

  p_indicator := g_dbi_info(l_index).indicator;

end read_dbi_cache;

------------------------------- write_dbi_cache -------------------------------
/*
  NAME
    write_dbi_cache
  DESCRIPTION
    Writes a value to db item cache.
  NOTES
    If the entry already exists, the current value is overwritten
    otherwise a new entry is created.  The chaining from clashing
    hash values is dealt with.

    Note that we default the context level to null, because
    we only need to pass this when the entry is first created.

    The default is not to write to an existing entry.
*/

procedure write_dbi_cache
(
  p_context_id     in binary_integer,
  p_item_name      in varchar2,
  p_data_type       in varchar2,
  p_dvalue         in date,
  p_nvalue         in number,
  p_tvalue         in varchar2,
  p_context_level1 in binary_integer  default null,
  p_context_level2 in binary_integer  default null,
  p_force_write    in boolean         default true
 ,p_indicator      in binary_integer  default FF_NULL
) is
  l_index binary_integer;
begin

  if g_debug then
    ff_utils.entry('write_dbi_cache');
  end if;

  -- Look for an existing entry in the dbi cache.
  l_index := find_dbi_cache_entry(p_context_id, p_item_name);

  if(l_index is not null) then

    ff_utils.assert
    (p_expression => p_data_type = g_dbi_info(l_index).data_type
    ,p_location   => 'write_dbi_cache:0'
    );

    -- An entry exists, but only write if told to.
    if(p_force_write) then
      if p_indicator <> FF_NOT_NULL then
        if g_dbi_info(l_index).data_type = C_DATE then
          g_dbi_info(l_index).dvalue := NULL;
        elsif g_dbi_info(l_index).data_type = C_NUMBER then
          g_dbi_info(l_index).nvalue := NULL;
        else
          g_dbi_info(l_index).tvalue := NULL;
        end if;
      else
        if g_dbi_info(l_index).data_type = C_DATE then
          g_dbi_info(l_index).dvalue := p_dvalue;
        elsif g_dbi_info(l_index).data_type = C_NUMBER then
          g_dbi_info(l_index).nvalue := p_nvalue;
        else
          g_dbi_info(l_index).tvalue := p_tvalue;
        end if;
      end if;

      g_dbi_info(l_index).indicator := p_indicator;
    end if;
  else
    /*
     *  No entry exists, so create new one.  Note that there
     *  are two conditions that could cause this:
     *  a) There is no hash table entry at all, in which
     *     case both hash and dbi cache entries need to be
     *     created.
     *  b) There is a hash table entry, but no dbi cache
     *     entry, in which case just the dbi cache entry
     *     is needed.
     */
    if(not g_hash_info.exists(p_context_id)) then
      -- Create new hash entry.
      g_hash_info(p_context_id).first_entry := g_next_dbi_index;
      g_hash_info(p_context_id).chain_count := 1;
      l_index := g_next_dbi_index;

      -- Point to next possible entry point.
      g_next_dbi_index := g_next_dbi_index + DBI_CACHE_INCR;
    else
      -- There is a hash index, but no entry in the cache
      -- itself.
      l_index := g_hash_info(p_context_id).first_entry +
                 g_hash_info(p_context_id).chain_count;

      -- Now have another entry on the chain.
      g_hash_info(p_context_id).chain_count :=
                      g_hash_info(p_context_id).chain_count + 1;

    end if;

    -- For new create, the context level should be not null.
    ff_utils.assert((p_context_level1 is not null), 'write_dbi_cache:1');
    ff_utils.assert((p_context_level2 is not null), 'write_dbi_cache:2');

    -- Now create the first dbi cache entry.
    g_dbi_info(l_index).item_name      := p_item_name;
    g_dbi_info(l_index).context_level1 := p_context_level1;
    g_dbi_info(l_index).context_level2 := p_context_level2;
    g_dbi_info(l_index).data_type      := p_data_type;

    if p_indicator <> FF_NOT_NULL then
      if g_dbi_info(l_index).data_type = C_DATE then
        g_dbi_info(l_index).dvalue := NULL;
      elsif g_dbi_info(l_index).data_type = C_NUMBER then
        g_dbi_info(l_index).nvalue := NULL;
      else
        g_dbi_info(l_index).tvalue := NULL;
      end if;
    else
      if g_dbi_info(l_index).data_type = C_DATE then
        g_dbi_info(l_index).dvalue := p_dvalue;
      elsif g_dbi_info(l_index).data_type = C_NUMBER then
        g_dbi_info(l_index).nvalue := p_nvalue;
      else
        g_dbi_info(l_index).tvalue := p_tvalue;
      end if;
    end if;

    g_dbi_info(l_index).indicator := p_indicator;
  end if;

  if g_debug then
    ff_utils.exit('write_dbi_cache');
  end if;

end write_dbi_cache;

------------------------ get_next_context_level -------------------------------
/*
  NAME
    get_next_context_level
  DESCRIPTION
    Allocates the next formula context level bit.
*/
procedure get_next_context_level
(p_context_level1 out nocopy binary_integer
,p_context_level2 out nocopy binary_integer
) is
begin
  if g_ctx_levels1 < C_MASK_BITS then
    p_context_level1 := 2 ** g_ctx_levels1;
    p_context_level2 := 0;
    g_ctx_levels1 := g_ctx_levels1 + 1;
  elsif g_ctx_levels2 < C_MASK_BITS then
    p_context_level2 := 2 ** g_ctx_levels2;
    p_context_level1 := 0;
    g_ctx_levels2 := g_ctx_levels2 + 1;
  else
    hr_utility.set_message(801, 'FF_33289_CONTEXT_CACHE_FULL');
    hr_utility.set_message_token('1', C_MAX_CONTEXTS);
    hr_utility.raise_error;
  end if;
end get_next_context_level;

----------------------------- dbi2route_id ------------------------------------
/*
  NAME
    dbi2route_id
  DESCRIPTION
    Fetches the route_id given a database item name.
  NOTES
    p_business_group_id and p_legislation_code must come direct from
    ff_formulas_f i.e. p_legislation_code must not be derived from
    p_business_group_id.
*/
function dbi2route_id
(p_formula_name      in varchar2
,p_dbi_name          in varchar2
,p_business_group_id in number
,p_legislation_code  in varchar2
) return binary_integer is
cursor csr_route_id
(p_dbi_name          in varchar2
,p_business_group_id in number
,p_legislation_code  in varchar2
) is
select u.route_id
from   ff_database_items d
,      ff_user_entities  u
where  d.user_name = p_dbi_name
and    d.user_entity_id = u.user_entity_id
and    (
         u.legislation_code is null and u.business_group_id is null or
         u.legislation_code = p_legislation_code or
         u.business_group_id = p_business_group_id or
         u.legislation_code =
         (
           select b.legislation_code
           from   per_business_groups_perf b
           where  b.business_group_id = p_business_group_id
         )
       )
;
l_route_id binary_integer;
begin
  open csr_route_id
       (p_dbi_name          => p_dbi_name
       ,p_business_group_id => p_business_group_id
       ,p_legislation_code  => p_legislation_code
       );
  fetch csr_route_id
  into  l_route_id
  ;
  if csr_route_id%notfound then
    close csr_route_id;
    --
    -- Ask user to recompile because of potential data dictionary
    -- problem.
    --
    hr_utility.set_message(801, 'FFXBIF71_NEED_TO_REVERIFY');
    hr_utility.set_message_token('1', p_formula_name);
    hr_utility.raise_error;
  end if;
  close csr_route_id;

  return l_route_id;
end dbi2route_id;

---------------------------- get_route_info -----------------------------------
/*
  NAME
    get_route_info
  DESCRIPTION
    Fetches the route context information for given a route_id.
*/
procedure get_route_info
(p_formula_name      in            varchar2
,p_route_id          in            binary_integer
,p_context_sum1         out nocopy binary_integer
,p_context_sum2         out nocopy binary_integer
) is
cursor csr_route_exists(p_route_id in binary_integer) is
select null
from   ff_routes r
where  r.route_id = p_route_id
;
--
cursor csr_route_contexts
(p_route_id          in number
) is
select rcu.context_id
from   ff_route_context_usages rcu
where  rcu.route_id = p_route_id
;

l_context_ids t_binary_integer;
l_sum1 binary_integer := 0;
l_sum2 binary_integer := 0;
l_dummy varchar2(1);
begin
  --
  -- Are the context sums for p_route_id already cached ?
  --
  if not g_route_ctx_sums.exists(p_route_id) then
    -- Validate that the route itself exists.
    open csr_route_exists(p_route_id => p_route_id);
    fetch csr_route_exists
    into  l_dummy;
    if csr_route_exists%notfound then
      close csr_route_exists;
      --
      -- Ask user to recompile because of potential data dictionary
      -- problem.
      --
      hr_utility.set_message(801, 'FFXBIF71_NEED_TO_REVERIFY');
      hr_utility.set_message_token('1', p_formula_name);
      hr_utility.raise_error;
    end if;
    close csr_route_exists;

    open csr_route_contexts(p_route_id => p_route_id);
    fetch csr_route_contexts bulk collect
    into  l_context_ids;
    close csr_route_contexts;
    for i in 1 .. l_context_ids.count loop
      if not g_ctx_info.exists(l_context_ids(i)) then
        --
        -- Ask user to recompile because of potential data dictionary
        -- problem.
        --
        hr_utility.set_message(801, 'FFXBIF71_NEED_TO_REVERIFY');
        hr_utility.set_message_token('1', p_formula_name);
        hr_utility.raise_error;
      end if;

      l_sum1 := l_sum1 + g_ctx_info(l_context_ids(i)).context_level1;
      l_sum2 := l_sum2 + g_ctx_info(l_context_ids(i)).context_level2;
    end loop;

    --
    -- Cache the context level sums.
    --
    g_route_ctx_sums(p_route_id).context_sum1 := l_sum1;
    g_route_ctx_sums(p_route_id).context_sum2 := l_sum2;
  end if;

  p_context_sum1 := g_route_ctx_sums(p_route_id).context_sum1;
  p_context_sum2 := g_route_ctx_sums(p_route_id).context_sum2;
end get_route_info;

------------------------------- ff_fetch --------------------------------------
/*
  NAME
    ff_fetch
  DESCRIPTION
    Fetches specified formula information.
  NOTES
    Performs the actual fetches to put load the data
    for a specified formula into the internal
    cache structures.
*/

procedure ff_fetch
(
  p_free_slot      in     binary_integer,
  p_formula_id     in     binary_integer,
  p_effective_date in     date,
  p_fmla_lookups   in out nocopy fmla_lookup_t,
  p_fmla_info      in out nocopy fmla_info_t,
  p_fdiu_info      in out nocopy fdiu_info_t,
  p_ctx_info       in out nocopy dbi_cache_t
) is

  cursor fdiuc1 is
  select fdiu.item_name name,
         to_number(substr(fdiu.item_generated_name, 2)) varpos,
         decode(fdiu.indicator_var_name, NULL, INVALID_POS,
                to_number(substr(fdiu.indicator_var_name, 2))) indpos,
         decode(fdiu.data_type,
                     'D', 'DATE',
                     'N', 'NUMBER',
                     'T', 'TEXT', 'XXX') data_type,
         fdiu.usage,
         decode(fdiu.usage,
                     'U', 1,
                     'I', 2, 'B', 2, 'O', 2,
                     'D', 3) usageorder,
         0 context_sum1,
         0 context_sum2,
         fdiu.context_id,
         fdiu.route_id
  from   ff_fdi_usages_f fdiu
  where  fdiu.formula_id = p_formula_id
  and    p_effective_date between
         fdiu.effective_start_date and fdiu.effective_end_date
  and    fdiu.load_when_running = 'Y'
  order  by 6, fdiu.item_name;  -- *** IMPORTANT.

  l_effective_start_date date;
  l_effective_end_date   date;
  l_formula_name         ff_formulas_f.formula_name%type;
  l_fdiu_entry_count     ff_compiled_info_f.fdiu_entry_count%type;
  l_package_name         varchar2(60);
  l_first_fdiu           binary_integer;
  l_fdiu_row             binary_integer;  -- latest fdiu row.
  l_fdiu_count           binary_integer;
  l_input_count          binary_integer := 0;  -- count inputs for formula.
  l_output_count         binary_integer := 0;  -- count outputs for formula.
  l_context_count        binary_integer := 0;  -- count contexts for formula.
  l_business_group_id    number;
  l_legislation_code     varchar2(30);

  --
  -- Separate tables making up the in-core FDIU to allow bulk binds.
  --
  l_fdiu_name         t_big_varchar2;
  l_fdiu_varpos       t_binary_integer;
  l_fdiu_indpos       t_binary_integer;
  l_fdiu_data_type    t_small_varchar2;
  l_fdiu_usage        t_small_varchar2;
  l_fdiu_usage_order  t_small_varchar2;
  l_fdiu_context_sum1 t_binary_integer;
  l_fdiu_context_sum2 t_binary_integer;
  l_fdiu_context_id   t_binary_integer;
  l_fdiu_route_id     t_binary_integer;

  --
  -- Local copies of the parameters which are only updated at the end
  -- of the procedure call to avoid exceptions.
  --
  l_fmla_info            fmla_info_r;
  l_fdiu_info            fdiu_info_t;
  i                      binary_integer;
  l_got_fdiu_chunks      boolean := false;
  l_reused               boolean := false;
  l_assertion            boolean;

begin

  if g_debug then
    ff_utils.entry('ff_fetch');
  end if;

  /*
   *  Fetch formula information.
   */
  begin
    select 'FFP' || fff.formula_id || '_' ||
                    to_char(fff.effective_start_date, 'DDMMYYYY'),
           fff.effective_start_date,
           fff.effective_end_date,
           fff.formula_name,
           fff.business_group_id,
           fff.legislation_code,
           fci.fdiu_entry_count
    into   l_package_name,
           l_effective_start_date,
           l_effective_end_date,
           l_formula_name,
           l_business_group_id,
           l_legislation_code,
           l_fdiu_entry_count
    from   ff_formulas_f      fff,
           ff_compiled_info_f fci
    where  fff.formula_id = p_formula_id
    and    p_effective_date between
           fff.effective_start_date and fff.effective_end_date
    and    fci.formula_id = fff.formula_id
    and    p_effective_date between
           fci.effective_start_date and fci.effective_end_date;
  exception
    --
    -- Handle the case where there is no compiled formula.
    --
    when no_data_found then
      hr_utility.set_message(801, 'FFX22J_FORMULA_NOT_FOUND');
      hr_utility.set_message_token('1', p_formula_id);
      hr_utility.raise_error;
    when others then
      raise;
  end;

  /*
   *  Load the formula cache structure.
   *  Note that the fdiu_count and mru_entry members
   *  are set up later in this procedure.
   */
  l_fmla_info.formula_id           := p_formula_id;
  l_fmla_info.effective_start_date := l_effective_start_date;
  l_fmla_info.effective_end_date   := l_effective_end_date;
  l_fmla_info.formula_name         := l_formula_name;
  l_fmla_info.package_name         := l_package_name;

  open fdiuc1;
  fetch fdiuc1 bulk collect
  into         l_fdiu_name,
               l_fdiu_varpos,
               l_fdiu_indpos,
               l_fdiu_data_type,
               l_fdiu_usage,
               l_fdiu_usage_order,
               l_fdiu_context_sum1,
               l_fdiu_context_sum2,
               l_fdiu_context_id,
               l_fdiu_route_id;
  close fdiuc1;

  -- Check that number of fdiu entries matches the fdiu count
  ff_utils.assert((l_fdiu_entry_count = l_fdiu_name.count),
                  'ff_fetch:1');

  --
  -- See if it is possible to reuse free fdiu records.
  --
  find_free_chunk
  (p_chunk_size  => l_fdiu_entry_count
  ,p_free_chunks => g_free_fdiu
  ,p_start       => l_first_fdiu
  );
  if l_first_fdiu is null then
    l_first_fdiu := nvl(p_fdiu_info.last, 0) + 1;

    if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
      hr_utility.trace
      ('ff_fetch add to FDIU from end of list:' || l_first_fdiu || ',' ||
       l_fdiu_entry_count
      );
    end if;

    --
    -- This is a check for free FDIU list consistency.
    --
    if g_free_fdiu.last is not null then
      l_assertion :=
      l_first_fdiu > g_free_fdiu.last + g_free_fdiu(g_free_fdiu.last) - 1;

      if not l_assertion and
         (bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
        hr_utility.trace
        ('ff_fetch assertion 2 failed:'||l_first_fdiu||','||
         to_char(g_free_fdiu.last + g_free_fdiu(g_free_fdiu.last) - 1)
        );
      end if;

      ff_utils.assert(l_assertion, 'ff_fetch:2');
    end if;
  else
    l_reused := true;
  end if;

  -- Init the counters as required.
  l_first_fdiu := nvl(l_first_fdiu, 0);
  l_fmla_info.first_fdiu := l_first_fdiu;
  l_fdiu_row := l_first_fdiu;

  -- Fetch the rows into fdiu for formula.
  for i in 1 .. l_fdiu_name.count loop

    -- Process according to usage.
    if(l_fdiu_usage(i) = 'U' or l_fdiu_usage(i) = 'D')
    then
      -- There MUST be a context_id for 'U' or 'D'.
      if(l_fdiu_context_id(i) is null) then
        hr_utility.set_message(801, 'FFPLX01_CONTEXT_ID_NULL');
        hr_utility.set_message_token('FMLA_NAME', l_formula_name);
        hr_utility.set_message_token('ITEM_NAME', l_fdiu_name(i));
        hr_utility.raise_error;
      end if;

      if(l_fdiu_usage(i) = 'U') then
        l_context_count := l_context_count + 1;  -- count contexts.

        -- Write to context cache if no existing entry.
        if(not p_ctx_info.exists(l_fdiu_context_id(i))) then

          -- Dynamically allocate the context level.
          get_next_context_level
          (p_context_level1 =>  l_fdiu_context_sum1(i)
          ,p_context_level2 =>  l_fdiu_context_sum2(i)
          );

          p_ctx_info(l_fdiu_context_id(i)).item_name := l_fdiu_name(i);
          p_ctx_info(l_fdiu_context_id(i)).dvalue := NULL;
          p_ctx_info(l_fdiu_context_id(i)).nvalue := NULL;
          p_ctx_info(l_fdiu_context_id(i)).tvalue := NULL;
          p_ctx_info(l_fdiu_context_id(i)).context_level1 :=
          l_fdiu_context_sum1(i);
          p_ctx_info(l_fdiu_context_id(i)).context_level2 :=
          l_fdiu_context_sum2(i);
        else

          -- Get context level from the context cache.
          l_fdiu_context_sum1(i) :=
          p_ctx_info(l_fdiu_context_id(i)).context_level1;
          l_fdiu_context_sum2(i) :=
          p_ctx_info(l_fdiu_context_id(i)).context_level2;
        end if;
      else
        -- Must be a database item.  Write an entry to cache
        -- if it doesn't exist.

        --
        -- First perform some route_id validation.
        --
        if l_fdiu_route_id(i) is null then
          l_fdiu_route_id(i) :=
          dbi2route_id
          (p_formula_name      => l_formula_name
          ,p_dbi_name          => l_fdiu_name(i)
          ,p_business_group_id => l_business_group_id
          ,p_legislation_code  => l_legislation_code
          );
        end if;
        --
        get_route_info
        (p_formula_name => l_formula_name
        ,p_route_id     => l_fdiu_route_id(i)
        ,p_context_sum1 => l_fdiu_context_sum1(i)
        ,p_context_sum2 => l_fdiu_context_sum2(i)
        );
        --
        write_dbi_cache
        (p_context_id     => l_fdiu_context_id(i)
        ,p_item_name      => l_fdiu_name(i)
        ,p_data_type      => l_fdiu_data_type(i)
        ,p_dvalue         => NULL
        ,p_nvalue         => NULL
        ,p_tvalue         => NULL
        ,p_context_level1 => l_fdiu_context_sum1(i)
        ,p_context_level2 => l_fdiu_context_sum2(i)
        ,p_force_write    => FALSE
        ,p_indicator      => FF_NULL
        );
      end if;

    end if;

    if(l_fdiu_usage(i) in ('I', 'B')) then
      l_input_count := l_input_count + 1;  -- count inputs and outputs.
    end if;

    if(l_fdiu_usage(i) in ('O', 'B')) then   -- count outputs.
      l_output_count := l_output_count + 1;
    end if;

    /*
     *  Set up in core fdiu entries.
     *  It is safe to update the global structure because it can't be used
     *  until the formula information structures are updated.
     */
    p_fdiu_info(l_fdiu_row).name        := l_fdiu_name(i);
    p_fdiu_info(l_fdiu_row).varpos      := l_fdiu_varpos(i);
    p_fdiu_info(l_fdiu_row).indpos      := l_fdiu_indpos(i);
    p_fdiu_info(l_fdiu_row).data_type    := l_fdiu_data_type(i);
    p_fdiu_info(l_fdiu_row).usage       := l_fdiu_usage(i);
    p_fdiu_info(l_fdiu_row).context_sum1 := l_fdiu_context_sum1(i);
    p_fdiu_info(l_fdiu_row).context_sum2 := l_fdiu_context_sum2(i);
    p_fdiu_info(l_fdiu_row).context_id  := l_fdiu_context_id(i);
    --
    if not l_got_fdiu_chunks then
      l_got_fdiu_chunks := true;
    end if;

    -- Increment the row counter.
    l_fdiu_row := l_fdiu_row + 1;

  end loop;

  -- Set up the number of rows in fdiu for this formula.
  l_fmla_info.fdiu_count := l_fdiu_row - l_first_fdiu;

  -- Record the context, input and output count.
  l_fmla_info.context_count := l_context_count;
  l_fmla_info.input_count   := l_input_count;
  l_fmla_info.output_count  := l_output_count;

  --
  -- Can safely update the global information now.
  --
  p_fmla_info(p_free_slot) := l_fmla_info;
  p_fmla_lookups(p_formula_id) := p_free_slot;

  if g_debug then
    ff_utils.exit('ff_fetch');
  end if;

exception
  when others then
    if fdiuc1%isopen then
      close fdiuc1;
    end if;
    --
    -- If chunks were reused then return them to the free list.
    --
    if l_reused then
      if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
        hr_utility.trace('ff_fetch return reused rows to free list.');
      end if;

      add_to_free_list
      (p_first_chunk => l_fmla_info.first_fdiu
      ,p_chunk_count => l_fdiu_entry_count
      ,p_free_chunks => g_free_fdiu
      );
    --
    -- If the chunks weren't reused then they were allocated from
    -- the end of the fdiu list.
    --
    elsif l_got_fdiu_chunks then
      if(bitand(ff_utils.g_debug_level, ff_exec.FF_CACHE_DBG) <> 0) then
        hr_utility.trace('ff_fetch add new rows to free list.');
      end if;

      add_to_free_list
      (p_first_chunk => l_fmla_info.first_fdiu
      ,p_chunk_count => p_fdiu_info.last - l_fmla_info.first_fdiu
      ,p_free_chunks => g_free_fdiu
      );
    end if;
    --
    if g_debug then
      ff_utils.exit('ff_fetch:2');
    end if;
    --
    raise;
end ff_fetch;

-------------------------------- set_lru_slot ---------------------------------
/*
  NAME
    set_lru_slot
  DESCRIPTION
    Set the LRU slot to (for deleting when the cache is full).
  NOTES
*/
procedure set_lru_slot
(p_fmla_lookups in         fmla_lookup_t
,p_exec_info    in            exec_info_r
,p_mru_slot     in            binary_integer
,p_lru_slot     in out nocopy binary_integer
) is
begin
  --
  -- The cache is full - LRU slot is used to cycle through a circular
  -- buffer. Only change the LRU slot if it's the same as the MRU slot.
  --
  if p_fmla_lookups.count >= p_exec_info.fmla_cache_size and
     p_lru_slot = p_mru_slot then

    -- Handle getting to the end of the buffer.
    if p_lru_slot = p_exec_info.fmla_cache_size then
      if(bitand(ff_utils.g_debug_level, ff_exec.MRU_DBG) <> 0) then
        hr_utility.trace('LRU = 1');
      end if;

      p_lru_slot := 1;
    else
      if(bitand(ff_utils.g_debug_level, ff_exec.MRU_DBG) <> 0) then
        hr_utility.trace('LRU := LRU + 1:' || to_char(p_lru_slot + 1));
      end if;

      p_lru_slot := p_lru_slot + 1;
    end if;
  end if;
end set_lru_slot;
---------------------------- load_formula -------------------------------------
/*
  NAME
    load_formula
  DESCRIPTION
    Loads information for specific formula into formula cache.
  NOTES
    Formula information is loaded as appropriate into the
    various cache structures.
*/

procedure load_formula
(
  p_formula_id     in     number,
  p_effective_date in     date,
  p_exec_info      in out nocopy exec_info_r,
  p_fmla_lookups   in out nocopy fmla_lookup_t,
  p_fmla_info      in out nocopy fmla_info_t,
  p_lru_slot       in out nocopy binary_integer,
  p_fdiu_info      in out nocopy fdiu_info_t,
  p_ctx_info       in out nocopy dbi_cache_t
) is
  -- Local variable defintions.
  l_cache_slot       binary_integer;
  l_need_to_fetch    boolean;

  /*
   *  Local procedure to zap cache rows
   *  for a specified formula.
   */
  procedure zap_fcr (p_free_slot    in            binary_integer,
                     p_fmla_lookups in out nocopy fmla_lookup_t,
                     p_fmla_info    in out nocopy fmla_info_t,
                     p_fdiu_info    in out nocopy fdiu_info_t) is
  begin

    if g_debug then
      ff_utils.entry('zap_fcr');
    end if;

    ff_utils.assert(p_fmla_info.exists(p_free_slot), 'zap_fcr:1');

    --
    -- Check that this slot has not been zapped previously.
    --
    if p_fmla_info(p_free_slot).formula_id is null then
      return;
    end if;

    --
    -- Make sure that the reference to this slot is removed.
    --
    p_fmla_lookups(p_fmla_info(p_free_slot).formula_id) := null;

    --
    -- Mark the FDIU rows as free for reuse.
    --
    if(p_fmla_info(p_free_slot).fdiu_count > 0) then
      add_to_free_list
      (p_first_chunk => p_fmla_info(p_free_slot).first_fdiu
      ,p_chunk_count => p_fmla_info(p_free_slot).fdiu_count
      ,p_free_chunks => g_free_fdiu
      );
    end if;

    --
    -- Make sure that this slot cannot be used.
    --
    p_fmla_info(p_free_slot).formula_id := null;
    p_fmla_info(p_free_slot).fdiu_count := null;
    p_fmla_info(p_free_slot).first_fdiu := null;

    if g_debug then
      ff_utils.exit('zap_fcr');
    end if;

  end zap_fcr;

begin

  if g_debug then
    ff_utils.entry('load_formula');
  end if;

  /*
   *  Load formula information into internal structures.
   */
  l_need_to_fetch := true;

  --
  -- Check for an entry for the formula in the cache and validate
  -- the date range.
  --
  if p_fmla_lookups.exists(p_formula_id) and
     p_fmla_lookups(p_formula_id) is not null then
    l_cache_slot := p_fmla_lookups(p_formula_id);
    if p_effective_date < p_fmla_info(l_cache_slot).effective_start_date or
       p_effective_date > p_fmla_info(l_cache_slot).effective_end_date
    then
      -- Zap rows from cache for this formula.
      zap_fcr(l_cache_slot, p_fmla_lookups, p_fmla_info, p_fdiu_info);
    else
      -- The dates match so there is no need to fetch.
      l_need_to_fetch := false;
    end if;
  --
  -- Handle the case where the formula is not in the cache, but the cache is
  -- full.
  --
  elsif p_fmla_lookups.count >= p_exec_info.fmla_cache_size then
    --
    -- Get the formula_id from the lru slot.
    --
    zap_fcr(p_lru_slot, p_fmla_lookups, p_fmla_info, p_fdiu_info);
    l_cache_slot := p_lru_slot;
  --
  -- Empty slots are available, so put onto the end of the cache list.
  --
  else
    l_cache_slot := p_fmla_info.count + 1;
    p_fmla_info.extend(1);
  end if;

  --
  -- Fetch formula details.
  --
  if (l_need_to_fetch) then
    ff_fetch (l_cache_slot, p_formula_id, p_effective_date, p_fmla_lookups,
              p_fmla_info, p_fdiu_info, p_ctx_info);
  end if;

  -- Debugging output.
  if g_debug then
    fmla_cache_debug(p_formula_id, p_fmla_lookups, p_fmla_info, p_fdiu_info);
  end if;

  -- Set up the global environment with current formula details.
  p_exec_info.formula_id     := p_formula_id;
  p_exec_info.cache_slot     := l_cache_slot;
  p_exec_info.effective_date := p_effective_date;

  -- Indicate to outside world how many contexts, inputs and
  -- outputs the formula is expecting.
  ff_exec.context_count := p_fmla_info(l_cache_slot).context_count;
  ff_exec.input_count   := p_fmla_info(l_cache_slot).input_count;
  ff_exec.output_count  := p_fmla_info(l_cache_slot).output_count;

  -- Reset the LRU slot.
  set_lru_slot(p_fmla_lookups, p_exec_info, l_cache_slot, p_lru_slot);

  if g_debug then
    ff_utils.exit('load_formula');
  end if;

end load_formula;

----------------------------- invalidate_db_items -----------------------------
/*
  NAME
    invalidate_db_items
  DESCRIPTION
    Invalidate db items if necessary, following context value change.
  NOTES
    Skulls through datbase item cache list, invalidating (writing null to)
    the item if necessary.
*/

procedure invalidate_db_items
(
  p_context_sum1 in binary_integer,
  p_context_sum2 in binary_integer
) is
  l_index binary_integer;
  l_path  binary_integer;
begin
  if g_debug then
    ff_utils.entry('invalidate_db_items');
  end if;

  if p_context_sum1 <> 0 and p_context_sum2 = 0 then
    l_path := 1;
  elsif p_context_sum1 = 0 and p_context_sum2 <> 0 then
    l_path := 2;
  elsif p_context_sum1 <> 0 and p_context_sum2 <> 0 then
    l_path := 3;
  else
    --
    -- The bit masks are both 0 so no need to do anything.
    --
    return;
  end if;

  if l_path = 1 then
    l_index := g_dbi_info.first;

    while(l_index is not null) loop

      if(bitand(p_context_sum1, g_dbi_info(l_index).context_level1) <> 0)
      then
        if g_debug then
          dbi_invalid_debug
          (g_dbi_info(l_index)
          ,p_context_sum1
          ,p_context_sum2
          );
        end if;
        g_dbi_info(l_index).indicator := FF_NULL;
        g_dbi_info(l_index).dvalue := NULL;
        g_dbi_info(l_index).nvalue := NULL;
        g_dbi_info(l_index).tvalue := NULL;
      end if;

      l_index := g_dbi_info.next(l_index);
    end loop;
  elsif l_path = 2 then

    l_index := g_dbi_info.first;

    while(l_index is not null) loop

      if(bitand(p_context_sum2, g_dbi_info(l_index).context_level2) <> 0)
      then
        if g_debug then
          dbi_invalid_debug
          (g_dbi_info(l_index)
          ,p_context_sum1
          ,p_context_sum2
          );
        end if;
        g_dbi_info(l_index).indicator := FF_NULL;
        g_dbi_info(l_index).dvalue := NULL;
        g_dbi_info(l_index).nvalue := NULL;
        g_dbi_info(l_index).tvalue := NULL;
      end if;

      l_index := g_dbi_info.next(l_index);
    end loop;
  else
    l_index := g_dbi_info.first;

    while(l_index is not null) loop

      if(bitand(p_context_sum1, g_dbi_info(l_index).context_level1) <> 0 or
         bitand(p_context_sum2, g_dbi_info(l_index).context_level2) <> 0)
      then
        if g_debug then
          dbi_invalid_debug
          (g_dbi_info(l_index)
          ,p_context_sum1
          ,p_context_sum2
          );
        end if;
        g_dbi_info(l_index).indicator := FF_NULL;
        g_dbi_info(l_index).dvalue := NULL;
        g_dbi_info(l_index).nvalue := NULL;
        g_dbi_info(l_index).tvalue := NULL;
      end if;

      l_index := g_dbi_info.next(l_index);
    end loop;
  end if;

  if g_debug then
    ff_utils.exit('invalidate_db_items');
  end if;

end invalidate_db_items;

------------------------------ bind_variables ---------------------------------
/*
  NAME
    bind_variables
  DESCRIPTION
    Deals with binding the anonymous block PLSQL variables.
  NOTES
    Called from the run_formula procedure.
*/

procedure bind_variables
(
  p_cache_slot    in            binary_integer,
  p_inputs        in            ff_exec.inputs_t,
  p_outputs       in            ff_exec.outputs_t,
  p_fmla_info     in            fmla_info_t,
  p_fdiu_info     in            fdiu_info_t,
  p_ctx_info      in out nocopy dbi_cache_t,
  p_d             in out nocopy ff_wrapper_pkg.t_date,
  p_n             in out nocopy ff_wrapper_pkg.t_number,
  p_t             in out nocopy ff_wrapper_pkg.t_text,
  p_i             in out nocopy ff_wrapper_pkg.t_number,
  p_use_dbi_cache in boolean
) is

  l_context_total1 binary_integer;
  l_context_total2 binary_integer;
  l_first_fdiu     binary_integer;
  l_last_fdiu      binary_integer;
  l_count          binary_integer;
  l_item_name      varchar2(240);
  l_varpos         binary_integer;
  l_indpos         binary_integer;
  l_indic_value    binary_integer;
  l_dvalue         date;
  l_nvalue         number;
  l_tvalue         varchar2(255);     -- matches ff_exec.FF_BIND_LEN
  l_data_type      varchar2(7);
  l_usage          varchar2(1);
  l_context_id     binary_integer;   -- context_id.
  l_context_sum1   binary_integer;
  l_context_sum2   binary_integer;
  l_context_count  binary_integer;
  l_in_index       binary_integer;   -- only interested in count of inputs.
begin

  if g_debug then
    ff_utils.entry('bind_variables');
  end if;

  l_context_total1 := 0;
  l_context_total2 := 0;
  l_context_count := 0;
  l_in_index      := 0;

  /*
   *  Bind variables body.
   */
  l_first_fdiu := p_fmla_info(p_cache_slot).first_fdiu;
  l_last_fdiu := l_first_fdiu + p_fmla_info(p_cache_slot).fdiu_count - 1;

  for l_count in l_first_fdiu..l_last_fdiu loop
    /*
     *  Get the value to bind.
     *  Where we get this from depends on the usage.
     *  Note how the fdiu is ordered, this is important.
     *  Assign some values to local variables to make the
     *  code a little easier to understand.
     */
    l_item_name    := p_fdiu_info(l_count).name;
    l_varpos       := p_fdiu_info(l_count).varpos;
    l_indpos       := p_fdiu_info(l_count).indpos;
    l_indic_value  := null;
    l_data_type    := p_fdiu_info(l_count).data_type;
    l_usage        := p_fdiu_info(l_count).usage;
    l_context_id   := p_fdiu_info(l_count).context_id;
    l_context_sum1 := p_fdiu_info(l_count).context_sum1;
    l_context_sum2 := p_fdiu_info(l_count).context_sum2;

    -- Initialise the bind variables to NULL each time.
    l_nvalue       := NULL;
    l_dvalue       := NULL;
    l_tvalue       := NULL;

    /*
     *  Take action, depending on the current usage.
     *  We are attempting to set a value for l_value.
     */
    if(l_usage = 'U') then
      /* context */

      -- Keep count of how many contexts we have processed.
      l_context_count := l_context_count + 1;

      l_in_index := l_in_index + 1; -- Count index of inputs table.

      /* user not allowed to supply NULL value for context */
      if(p_inputs(l_in_index).value is null) then
        hr_utility.set_message(801, 'FFX02_UIDCOL_MISSING');
        hr_utility.set_message_token('1',
                                 p_fmla_info(p_cache_slot).formula_name);
        hr_utility.set_message_token('2', l_item_name);
        hr_utility.raise_error;
      end if;

      -- read context value from cache.
      l_tvalue := p_ctx_info(l_context_id).tvalue;

      -- See if value is either NULL or different from
      -- the value the user has supplied.
      -- Note the value should only be NULL if this is
      -- the first time we have read the value.
      if(l_tvalue is null or l_tvalue <> p_inputs(l_in_index).value) then

        -- Log changed context.
        if g_debug then
          ctx_change_debug(l_item_name, l_context_sum1, l_context_sum2,
                           l_tvalue, p_inputs(l_in_index).value);
        end if;

        -- Add the current context level to the context total.
        if l_context_sum1 <> 0 then
          l_context_total1 := l_context_total1 + l_context_sum1;
        else
          l_context_total2 := l_context_total2 + l_context_sum2;
        end if;

        --
        -- Always set p_ctx_info(l_context_id).tvalue as it is used for the
        -- the comparison above.
        --
        p_ctx_info(l_context_id).tvalue := p_inputs(l_in_index).value;
        l_tvalue := p_inputs(l_in_index).value;

        --
        -- Get the value from the inputs table and write to the contexts
        -- cache.
        --
        if l_data_type = C_DATE then
          p_ctx_info(l_context_id).dvalue :=
          fnd_date.canonical_to_date(l_tvalue);
        elsif l_data_type = C_NUMBER then
          p_ctx_info(l_context_id).nvalue := replace(l_tvalue, '.', g_decpoint);
        end if;

      end if;

      --
      -- Set the context values for binding.
      --
      if l_data_type = C_DATE then
        l_dvalue := p_ctx_info(l_context_id).dvalue;
      elsif l_data_type = C_NUMBER then
        l_nvalue := p_ctx_info(l_context_id).nvalue;
      else
        l_tvalue := p_ctx_info(l_context_id).tvalue;
      end if;

      -- Have we reached the final context?
      if(l_context_count = p_fmla_info(p_cache_slot).context_count) then

        -- Have processed last context, see if need to invalidate
        -- any database items as a consequence.
        invalidate_db_items(l_context_total1, l_context_total2);

      end if;

      -- Following all this, value should NOT be null.
      ff_utils.assert((l_tvalue is not null), 'bind_variables:1');

    elsif(l_usage in ('I', 'B')) then
      /* An input variable (or input and output). */
      l_in_index := l_in_index + 1; -- Count index of inputs table.

      -- Convert the values from the inputs table as set by user.
      if l_data_type = C_DATE then
        l_dvalue := fnd_date.canonical_to_date(p_inputs(l_in_index).value);
      elsif l_data_type = C_NUMBER then
        l_nvalue := replace(p_inputs(l_in_index).value, '.', g_decpoint);
      elsif l_data_type = C_TEXT then
        l_tvalue := p_inputs(l_in_index).value;
      end if;

    elsif(l_usage = 'O') then
      /*  Output (return) variable. */
      -- Simply leave the value as NULL.
      null;

    elsif(l_usage = 'D') then
      /* Database item. */
      -- Get the value for database item.
      -- If the db item cache is in use, read the value from
      -- there, otherwise, set it to NULL.
      if(p_use_dbi_cache) then
        read_dbi_cache
        (p_context_id => l_context_id
        ,p_item_name  => l_item_name
        ,p_data_type  => l_data_type
        ,p_dvalue     => l_dvalue
        ,p_nvalue     => l_nvalue
        ,p_tvalue     => l_tvalue
        ,p_indicator  => l_indic_value
        );
      else
        --
        -- The bind variables are already set to NULL. Set the indicator
        -- to NULL.
        --
        l_indic_value := FF_NULL;
      end if;
    else
      -- Houston, we have a problem.
      ff_utils.assert(FALSE, 'bind_variables:2');
    end if;

    /*
     *  Bind the appropriate variable (and indicator)
     *  with the value we have obtained.
     */
    if(l_data_type = C_DATE) then
      p_d(l_varpos) := l_dvalue;
    elsif(l_data_type = C_NUMBER) then
      p_n(l_varpos) := l_nvalue;
    elsif(l_data_type = C_TEXT) then
      p_t(l_varpos) := l_tvalue;
    else
      hr_utility.set_message(801, 'FFIC874_UNKNOWN_DATATYPE');
      hr_utility.set_message_token('1', l_item_name);
      hr_utility.set_message_token('2', l_data_type);
      hr_utility.raise_error;
    end if;

    /*
     *  Bind the indicator (if appropriate).
     */
    if(l_indpos <> INVALID_POS) then
      -- Set indicator dependent on the value passed in.
      if l_indic_value is not null then
        p_i(l_indpos) := l_indic_value;
      else
        if l_dvalue is not null or
           l_nvalue is not null or
           l_tvalue is not null then
          p_i(l_indpos) := FF_NOT_NULL;
        else
          p_i(l_indpos) := FF_NULL;
        end if;
      end if;
    end if;
  end loop;

  if g_debug then
    ff_utils.exit('bind_variables');
  end if;

end bind_variables;

-------------------------------- set_outputs ----------------------------------
/*
  NAME
    set_outputs
  DESCRIPTION
    Sets outputs in outputs table from returned values.
  NOTES
    Called from the run_formula procedure.
*/
procedure set_outputs
(
  p_cache_slot in binary_integer,
  p_fmla_info  in fmla_info_t,
  p_fdiu_info  in fdiu_info_t,
  p_d          in ff_wrapper_pkg.t_date,
  p_n          in ff_wrapper_pkg.t_number,
  p_t          in ff_wrapper_pkg.t_text,
  p_i          in ff_wrapper_pkg.t_number,
  p_outputs    in out nocopy ff_exec.outputs_t
) is
  l_first_fdiu   binary_integer;
  l_last_fdiu    binary_integer;
  l_count_fdiu   binary_integer;
  l_out_index    binary_integer := 0;
  l_varpos       binary_integer;
  l_indpos       binary_integer;
  l_indic_value  binary_integer;
  l_usage        varchar2(1);
  l_data_type    varchar2(6);
  l_dvalue       date;
  l_nvalue       number;
  l_value        varchar2(255); -- matches ff_exec.FF_BIND_LEN
begin

  if g_debug then
    ff_utils.entry('set_outputs');
  end if;

  /*
   *  Set the output table from returned values.
   */
  l_first_fdiu := p_fmla_info(p_cache_slot).first_fdiu;
  l_last_fdiu := l_first_fdiu + p_fmla_info(p_cache_slot).fdiu_count - 1;

  for l_count_fdiu in l_first_fdiu..l_last_fdiu loop

    -- We only wish to process anything for
    -- output variables or database items.
    if(p_fdiu_info(l_count_fdiu).usage in ('O', 'B', 'D')) then

      -- Set up some locals for convenience.
      l_varpos      := p_fdiu_info(l_count_fdiu).varpos;
      l_indpos      := p_fdiu_info(l_count_fdiu).indpos;
      l_usage       := p_fdiu_info(l_count_fdiu).usage;
      l_data_type   := p_fdiu_info(l_count_fdiu).data_type;

      /* Get the variable value. */
      if l_usage <> 'D' then
        if(l_data_type = C_DATE) then
          -- Dates converted to apps Canonical format.
          l_value := fnd_date.date_to_canonical(p_d(l_varpos));
        elsif(l_data_type = C_NUMBER) then
          -- Numbers converted to canonical format.
          l_value := replace(to_char(p_n(l_varpos)),g_decpoint,'.');
        else
          l_value := p_t(l_varpos);
        end if;
      else
        if(l_data_type = C_DATE) then
          l_dvalue := p_d(l_varpos);
          l_nvalue := NULL;
          l_value := NULL;
        elsif(l_data_type = C_NUMBER) then
          l_nvalue := p_n(l_varpos);
          l_dvalue := NULL;
          l_value := NULL;
        else
          l_value := p_t(l_varpos);
          l_dvalue := NULL;
          l_nvalue := NULL;
        end if;
      end if;

      /* Get the indicator value. */
      l_indic_value := p_i(l_indpos);

      /* Process the indicator. */
      if(l_indic_value = FF_NULL) then
        -- The indicator shows we need to set the value to null.
        l_value := NULL;
        l_dvalue := NULL;
        l_nvalue := NULL;
      end if;

      /* process dependent on the usage */
      if(l_usage in ('O', 'B')) then

        l_out_index := l_out_index + 1;  -- Where are we in output table?

        -- The variable is an output type, so set output table entry.
        p_outputs(l_out_index).value := l_value;

      else /* usage is 'D' */

        --
        -- Database item was returned
        -- If the database item was not defaulted, we want to write
        -- the returned value to the db item cache. If it was defaulted
        -- then, we want to update the indicator value in the cache.
        --
        if(l_indic_value = FF_WAS_DEFAULTED) then
          l_value := NULL;
          l_nvalue := NULL;
          l_dvalue := NULL;
        end if;

        write_dbi_cache
        (p_context_id  => p_fdiu_info(l_count_fdiu).context_id
        ,p_item_name   => p_fdiu_info(l_count_fdiu).name
        ,p_data_type   => l_data_type
        ,p_dvalue      => l_dvalue
        ,p_nvalue      => l_nvalue
        ,p_tvalue      => l_value
        ,p_force_write => TRUE
        ,p_indicator   => l_indic_value
        );

      end if;

    end if;

  end loop;

  if g_debug then
    ff_utils.exit('set_outputs');
  end if;

exception
  when others then
    --
    -- NOCOPY change. The issue is to avoid the FF Outputs having partially
    -- filled-in values now that FF_EXEC.RUN_FORMULA is passing them in
    -- by reference i.e. using NOCOPY.
    -- Solution: Set the outputs to NULL.
    --
    l_out_index := 0;
    for l_count_fdiu in l_first_fdiu..l_last_fdiu loop
      --
      -- Only interested in values that get set on output. DBI behaviour is
      -- unchanged before because the code has used NOCOPY internally for
      -- some time.
      --
      if(p_fdiu_info(l_count_fdiu).usage in ('O', 'B')) then
        l_out_index := l_out_index + 1;
        p_outputs(l_out_index).value := null;
      end if;
    end loop;
    raise;
end set_outputs;

/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

------------------------------- reset_caches ----------------------------------
/*
  NAME
    reset_caches
  DESCRIPTION
    Resets the internal caches to their initial states.
  NOTES
*/
procedure reset_caches is
begin
  g_fmla_lookups.delete;
  if g_inited then
    g_fmla_info.delete;
  end if;
  g_inited := true;
  g_fmla_info := fmla_info_t();
  g_lru_slot := 1;
  g_free_fdiu.delete;
  g_fdiu_info.delete;
  g_hash_info.delete;
  g_dbi_info.delete;
  g_ctx_info.delete;
  g_next_dbi_index := 1;

  g_route_ctx_sums.delete;
  g_ctx_levels1 := 0;
  g_ctx_levels2 := 0;

  --
  -- Set debugging profile.
  --
  check_profile_debug;

  --
  -- Set the USE_FF_WRAPPER flag.
  --
  set_use_ff_wrapper;

  --
  -- Set the cache size.
  --
  set_cache_size;
end reset_caches;

---------------------------- init_formula -------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Initialises data structures for a specific formula.
  NOTES
    Very straight-forward.  Is really a cover for the formula
    information cache load function.

    As far as the user is concerned, the reason for calling
    this procedure is to obtain information about the inputs
    and outputs required by the formula.
*/

procedure init_formula
(
  p_formula_id     in     number,
  p_effective_date in     date,
  p_inputs         in out nocopy ff_exec.inputs_t,
  p_outputs        in out nocopy ff_exec.outputs_t
) is
  l_count      binary_integer;
  l_first_fdiu binary_integer;
  l_last_fdiu  binary_integer;
  l_in_index   binary_integer := 0;
  l_out_index  binary_integer := 0;
  l_cache_slot binary_integer;
begin
  /* Set decimal point character. */
  g_decpoint := substr(to_char(1.1),2,1);

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    ff_utils.entry('init_formula');
  end if;

  if g_debug then
    hr_utility.trace('fmla cache size: ' || g_exec_info.fmla_cache_size);
  end if;

  -- Load formula information into cache if necessary.
  -- Global variables are passed to aid modularity.
  load_formula (p_formula_id, p_effective_date, g_exec_info,
                g_fmla_lookups, g_fmla_info, g_lru_slot,
                g_fdiu_info, g_ctx_info);
  l_cache_slot := g_exec_info.cache_slot;

  /*
   *  Move the inputs and outputs into the table
   */
  p_inputs.delete;     -- must start with empty inputs table.
  p_outputs.delete;    -- must start with empty outputs table.

  -- Get parameters for loop
  l_first_fdiu := g_fmla_info(l_cache_slot).first_fdiu;
  l_last_fdiu := l_first_fdiu + g_fmla_info(l_cache_slot).fdiu_count - 1;

  -- Loop round the appropriate fdiu rows for the formula.
  -- Note that the index numbers for the input and output tables
  -- will start from 1 and be contiguous.
  for l_count in l_first_fdiu..l_last_fdiu loop
    if (g_fdiu_info(l_count).usage in ('I', 'U', 'B')) then
      -- Entry for inputs table.
      l_in_index := l_in_index + 1;
      p_inputs(l_in_index).name     := g_fdiu_info(l_count).name;
      p_inputs(l_in_index).datatype := g_fdiu_info(l_count).data_type;

      -- Set up the class for input.
      if(g_fdiu_info(l_count).usage in ('I', 'B')) then
        p_inputs(l_in_index).class := 'INPUT';
      else
        p_inputs(l_in_index).class := 'CONTEXT';
      end if;
    end if;

    if (g_fdiu_info(l_count).usage in ('O', 'B')) then
      -- Entry for output table.
      l_out_index := l_out_index + 1;
      p_outputs(l_out_index).name     := g_fdiu_info(l_count).name;
      p_outputs(l_out_index).datatype := g_fdiu_info(l_count).data_type;
    end if;
  end loop;

  /*
   *  Record the number of rows in the inputs and
   *  outputs tables.  This allows the run time
   *  system to perform a sanity check later on.
   */
  g_exec_info.input_rows  := p_inputs.count;
  g_exec_info.output_rows := p_outputs.count;

  if g_debug then
    ff_utils.exit('init_formula');
  end if;

end init_formula;

------------------------------ run_formula ------------------------------------
/*
  NAME
    run_formula
  DESCRIPTION
    Uses data structures built up to execute Fast Formula.
  NOTES
    <none>
*/

procedure run_formula
(
  p_inputs         in     ff_exec.inputs_t,
  p_outputs        in out nocopy ff_exec.outputs_t,
  p_use_dbi_cache  in     boolean             default true
) is
  l_formula_id     number;
  l_cache_slot     binary_integer;
  l_line_number    number := 0;
  l_err_number     number := 0;
  l_error_message  varchar2(255) := null;
  l_rows_processed number;
  l_first_fdiu     binary_integer;
  l_last_fdiu      binary_integer;
  l_count_fdiu     binary_integer;
  l_fmla_name      varchar2(80);
  l_d              ff_wrapper_pkg.t_date;
  l_n              ff_wrapper_pkg.t_number;
  l_t              ff_wrapper_pkg.t_text;
  l_i              ff_wrapper_pkg.t_number;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    ff_utils.entry('run_formula');
  end if;

  -- Check that the execution engine is initialised.
  if(g_exec_info.formula_id is null) then
    hr_utility.set_message(801, 'FFPLX03_NO_INIT');
    hr_utility.raise_error;
  end if;

  -- Sanity checks on the number of rows in the
  -- inputs and outputs tables.  This helps to
  -- ensure the caller hasn't messed with them.
  ff_utils.assert((g_exec_info.input_rows = p_inputs.count), 'run_formula:1');
  ff_utils.assert((g_exec_info.output_rows = p_outputs.count), 'run_formula:2');

  /*
   *  Set up a few useful variables.
   */
  l_cache_slot := g_exec_info.cache_slot;
  l_fmla_name  := g_fmla_info(l_cache_slot).formula_name;

  -- Show the inputs.
  if g_debug then
    io_table_debug(p_inputs, p_outputs, 'INPUT');
  end if;

  -- DBI cache debug.
  if g_debug then
    dbi_cache_debug(g_ctx_info, g_dbi_info, g_hash_info);
  end if;

  /*
   *  Call routine to bind variables from user supplied info.
   */
  bind_variables(l_cache_slot, p_inputs, p_outputs, g_fmla_info,
                 g_fdiu_info, g_ctx_info, l_d, l_n, l_t, l_i,
                 p_use_dbi_cache);

  /*
   *  Execute PLSQL block.
   */

  -- Actually run the formula.
  -- Use local exception block to catch any oracle error.
  if g_exec_info.use_ff_wrapper then
    begin
      ff_wrapper_main_pkg.formula
      (p_formula_name    => l_fmla_name
      ,p_ff_package_name => g_fmla_info(l_cache_slot).package_name
      ,p_d               => l_d
      ,p_n               => l_n
      ,p_t               => l_t
      ,p_i               => l_i
      ,p_fferln          => l_line_number
      ,p_ffercd          => l_err_number
      ,p_ffermt          => l_error_message
      );
    exception
      when CANNOT_FIND_PROG_UNIT then
        -- Wrapper package body needs to be regenerated.
        hr_utility.set_message(802, 'FF_33186_GENERATE_WRAPPER');
        hr_utility.set_message_token('1', l_fmla_name);
        hr_utility.raise_error;

      when others then
      -- Getting an unhandled exception from PLSQL.
      hr_utility.set_message(801, 'FFX18_PLSQL_ERROR');
      hr_utility.set_message_token('1', l_fmla_name);
      hr_utility.set_message_token('2', sqlerrm);
      hr_utility.raise_error;

    end;
  else
    begin
      ff_wrapper_pkg.g_d := l_d;
      ff_wrapper_pkg.g_i := l_i;
      ff_wrapper_pkg.g_n := l_n;
      ff_wrapper_pkg.g_t := l_t;
      ff_wrapper_pkg.g_fferln := null;
      ff_wrapper_pkg.g_ffercd := null;
      ff_wrapper_pkg.g_ffermt := null;
      execute immediate
      'begin ' || g_fmla_info(l_cache_slot).package_name || '.formula; end;';
    exception
      when bad_plsql then
      hr_utility.set_message(801,'FFX22J_FORMULA_NOT_FOUND');
      hr_utility.set_message_token('1',l_fmla_name);
      hr_utility.raise_error;

      when others then
      -- Getting an unhandled exception from PLSQL.
      hr_utility.set_message(801, 'FFX18_PLSQL_ERROR');
      hr_utility.set_message_token('1', l_fmla_name);
      hr_utility.set_message_token('2', sqlerrm);
      hr_utility.raise_error;
    end;
    --
    l_d := ff_wrapper_pkg.g_d;
    l_i := ff_wrapper_pkg.g_i;
    l_n := ff_wrapper_pkg.g_n;
    l_t := ff_wrapper_pkg.g_t;
    l_line_number := ff_wrapper_pkg.g_fferln;
    l_err_number := ff_wrapper_pkg.g_ffercd;
    l_error_message := ff_wrapper_pkg.g_ffermt;
  end if;

  /*
   *  Check for specific error conditions.
   */
  if(l_err_number > 0) then

    -- Precise error detected in plsql, set up tokens.
    if(l_err_number = 1) then
      hr_utility.set_message(801, 'FFX00_LOCAL_NOT_INITIALIZED');
    elsif(l_err_number = 2) then
      hr_utility.set_message(801, 'FFX00_ZERO_DIVISION');
    elsif(l_err_number = 3) then
      hr_utility.set_message(801, 'FFX00_DATA_NOT_FOUND');
    elsif(l_err_number = 4) then
      hr_utility.set_message(801, 'FFX00_TOO_MANY_ROWS');
    elsif(l_err_number = 5) then
      hr_utility.set_message(801, 'FFX00_VALUE_RANGE_ERROR');
    elsif(l_err_number = 6) then
      hr_utility.set_message(801, 'FFX00_INVALID_NUMBER');
    elsif(l_err_number = 7) then
      hr_utility.set_message(801, 'FFX00_NULL_VALUE');
    elsif(l_err_number = 8) then
      hr_utility.set_message(801, 'FFX00_UDF_ERROR');
    else
      hr_utility.set_message(801, 'FFPLX02_UNKNOWN_PLSQL_ERR');
      hr_utility.set_message_token('ERROR', l_err_number);
      hr_utility.raise_error;
    end if;

    hr_utility.set_message_token('1', l_fmla_name);
    hr_utility.set_message_token('2', l_line_number);
    hr_utility.set_message_token('3', l_error_message);
    hr_utility.raise_error;

  elsif(l_err_number < 0) then

    -- Oracle error has been trapped by Formula.
    hr_utility.set_message(801, 'FFX18_ORA_PLSQL');
    hr_utility.set_message_token('1', l_fmla_name);
    hr_utility.set_message_token('2', l_err_number);
    hr_utility.set_message_token('3', l_line_number);
    hr_utility.raise_error;

  end if;

  /*
   *  Set values in the outputs table and
   *  write to db item cache if necessary.
   */
  set_outputs
  ( l_cache_slot, g_fmla_info, g_fdiu_info, l_d, l_n, l_t, l_i, p_outputs);

  -- Show the contents of inputs and outputs table.
  if g_debug then
    io_table_debug(p_inputs, p_outputs, 'OUTPUT');
  end if;

  /*
   *  Finished!
   *  Now the user should have all his values in the outputs
   *  table and be able to process them.
   */

  if g_debug then
    ff_utils.exit('run_formula');
  end if;

end run_formula;

/*
 *  Global initialisation section.
 */
begin
  --
  -- Set the formula caches to their initial values.
  --
  reset_caches;
end ff_exec;

/
