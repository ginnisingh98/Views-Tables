--------------------------------------------------------
--  DDL for Package Body HR_PUMP_META_MAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PUMP_META_MAPPER" as
/* $Header: hrpumpmm.pkb 120.4.12010000.1 2008/07/28 03:43:20 appldev ship $ */

---------------------------------------
-- ERROR MESSAGING AND TRACING STUFF --
---------------------------------------
g_debug boolean;

--------------------------------
-- DATA STRUCTURE DEFINITIONS --
--------------------------------

--
-- Major parameter information structure.
--
type t_parameter is record
(
  seqno                number,
  api_seqno            number,
  batch_lines_seqno    number,
  batch_lines_column   varchar2(30),
  parameter_name       varchar2(30),
  datatype             number,
  in_out               number,
  defaultable          boolean,
  default_value        varchar2(256),
  call_default_value   varchar2(256),
  mapping_type         hr_pump_module_parameters.mapping_type%type,
  mapping_definition   hr_pump_module_parameters.mapping_definition%type
);

type t_parameter_tbl is table of t_parameter index by binary_integer;

-- Cache parameter mappings for use by Pump Station
g_last_api_id number := -1;
g_last_column_count number := 0;
g_params t_parameter_tbl;
--
-- Parameter seed data structure.
--
type t_seed_parameter is record
(
  parameter_name     hr_pump_module_parameters.api_parameter_name%type,
  mapping_type       hr_pump_module_parameters.mapping_type%type,
  mapping_definition hr_pump_module_parameters.mapping_definition%type,
  default_value      hr_pump_module_parameters.default_value%type,
  matched            boolean
);

type t_seed_parameter_tbl is table of t_seed_parameter index by binary_integer;

--
-- Structure to store parameter counts for code generation.
--
type t_parameter_counts is record
(
  total_parameters       number, -- Total number of parameters.
  api_parameters         number, -- Parameters in API call.
  batch_lines_parameters number, -- Parameters required in batch lines table.
  seed_parameters        number, -- Parameters for which data is seeded.
  functions              number, -- Functions for 'FUNCTION' mapping_type.
  distinct_parameters    number, -- Distinct parameters for above functions.
  call_parameters        number, -- Total parameters in all function calls.
  long_parameters        number  -- Number of long parameters.
);

--
-- Structure for 'FUNCTION' mapping_type function information.
--
type t_function is record
(
  --
  -- If the ALWAYS_CALL flag is false, the function is only called if
  -- all its parameters are NOT NULL and not defaulted with HR_API
  -- default values.
  --
  always_call   boolean default false,
  package_name  hr_pump_module_parameters.mapping_definition%type,
  function_name hr_pump_module_parameters.mapping_definition%type,
  ret_type      number,        -- Return type.
  seqno         number,        -- Sequence in parameter list.
  index1        number,        -- Start index in function call list.
  index2        number         -- End index in function call list.
);

type t_function_tbl is table of t_function index by binary_integer;

type t_function_parameter is record
(
  mapping_function   varchar2(30) default null,
  parameter_name     varchar2(30),
  function_parameter varchar2(30),
  datatype           number,
  batch_lines_column varchar2(30),
  defaultable        boolean,
  default_value      varchar2(256)
);

--
-- List of function parameters information.
--
type t_function_parameter_tbl is table of t_function_parameter index by
binary_integer;

--
-- List of mapping function packages.
--
type t_mapping_package is record
(
  --
  -- Use hr_pump_module_parameters.mapping_definition%type as it's larger
  -- than hr_pump_mapping_packages.mapping_package%type, and it can be
  -- the source of a package name.
  --
  mapping_package   hr_pump_module_parameters.mapping_definition%type
);

type t_mapping_package_tbl is table of t_mapping_package index by
binary_integer;

--------------------------
-- CONSTANT DEFINITIONS --
--------------------------
c_newline               constant varchar(1) default '
';
--
-- dbms_describe values for different data types.
--
c_dtype_undefined       constant number       default 0;
c_dtype_varchar2        constant number       default 1;
c_dtype_number          constant number       default 2;
c_dtype_binary_integer  constant number       default 3;
c_dtype_long            constant number       default 8;
c_dtype_date            constant number       default 12;
c_dtype_boolean         constant number       default 252;
--
-- dbms_describe values for different parameter passing modes.
--
c_ptype_in              constant number       default 0;
c_ptype_out             constant number       default 1;
c_ptype_in_out          constant number       default 2;
--
-- Defaulting style.
--
c_default_null          constant number       default 0;
c_default_hr_api        constant number       default 1;
--
-- Batch lines column information.
--
c_max_batch_lines_cols  constant number       default 230;
c_parameter_value_col   constant varchar2(30) default 'pval';
c_cursor_value_col      constant varchar2(30) default 'p';
c_def_check_col         constant varchar2(30) default 'd';
c_long_value_col        constant varchar2(30) default 'plongval';
--
-- Parameter mapping types.
--
c_mapping_type_aliased  constant varchar2(30) default 'ALIASED';
c_mapping_type_function constant varchar2(30) default 'FUNCTION';
c_mapping_type_lookup   constant varchar2(30) default 'LOOKUP';
c_mapping_type_normal   constant varchar2(30) default 'NORMAL';
c_mapping_type_user_key constant varchar2(30) default 'USER_KEY';
--
-- Package containing mapping functions.
--
c_get_function_package  constant varchar2(30) default 'hr_pump_get';
--
-- Format for date parameters.
--
c_date_format           constant varchar2(10) default 'YYYY/MM/DD';
c_date_format_len       constant number       default 10;
c_date_format1          constant varchar2(30) default 'YYYY/MM/DD HH24:MI:SS';
c_date_format1_len      constant number       default 19;

-- Signed date formats e.g. for hr_api.g_date.
c_date_format2          constant varchar2(30) default 'SYYYY/MM/DD';
c_date_format2_len      constant number       default 11;
c_date_format3          constant varchar2(30) default 'SYYYY/MM/DD HH24:MI:SS';
c_date_format3_len      constant number       default 20;

---------------------------
-- Global PL/SQL tables. --
---------------------------

type t_tbl_varchar2 is table of varchar2(32) index by binary_integer;
--
-- Tables to assist in code generation.
--
g_tbl_default_null   t_tbl_varchar2;
g_tbl_default_hr_api t_tbl_varchar2;
g_tbl_datatype       t_tbl_varchar2;

--
-- Tables to allow the use of shortened default values in the call
-- procedure.
--
g_tbl_call_default_null     t_tbl_varchar2;
g_tbl_call_default_hr_api   t_tbl_varchar2;

--
-- Generation Mode Flag.
--
g_standard_generate boolean;

----------------------
-- ERROR EXCEPTIONS --
----------------------

--
-- Error exceptions that may be raised by hr_general.describe_procedure.
--
package_not_exists  exception;
pragma exception_init(package_not_exists, -6564);
--
proc_not_in_package  exception;
pragma exception_init(proc_not_in_package, -20001);
--
remote_object  exception;
pragma exception_init(remote_object, -20002);
--
invalid_package  exception;
pragma exception_init(invalid_package, -20003);
--
invalid_object_name  exception;
pragma exception_init(invalid_object_name, -20004);
--
-- Exception for generated text exceeding the maximum allowable buffer size.
--
plsql_value_error    exception;
pragma exception_init(plsql_value_error, -6502);

---------------------------------------------------------------------------
--                          COMMON CODE                                  --
---------------------------------------------------------------------------
-- ------------------------- output_init ---------------------------------
-- Description:
-- Wrapper procedure for initialising text output mechanism.
-- ------------------------------------------------------------------------
procedure output_init
is
begin
  --
  -- Set dbms_output buffer to its maximum size.
  --
  dbms_output.enable( 1000000 );
end output_init;

-- ------------------------- output_text ----------------------------------
-- Description:
-- Wrapper procedure for text output.
-- ------------------------------------------------------------------------
procedure output_text
(
  p_text in varchar2
)
is
begin
  dbms_output.put_line( p_text );
 end output_text;

-- ----------------------- special_parameter -----------------------------
-- Description:
-- Returns true if the parameter_name is the name of a parameter whose
-- value will not be supplied from the batch lines table or a mapping e.g.
-- p_validate is always set to false.
-- ------------------------------------------------------------------------
function special_parameter
(
  p_parameter_name in varchar2
)
return boolean is
  l_special boolean;
begin
  l_special := upper( p_parameter_name ) in
               ( 'P_VALIDATE', 'P_BUSINESS_GROUP_ID',
                 'P_DATA_PUMP_ALWAYS_CALL' );
  return l_special;
end special_parameter;

-- --------------------- check_special_parameter --------------------------
-- Description:
-- Checks if p_function_parameter is consistent with the special parameter
-- with the same name.
-- ------------------------------------------------------------------------
procedure check_special_parameter
(
  p_function_parameter in t_function_parameter
)
is
begin
  if p_function_parameter.parameter_name = 'P_BUSINESS_GROUP_ID' then
    if p_function_parameter.datatype <> c_dtype_number and
       p_function_parameter.datatype <> c_dtype_binary_integer
    then
      hr_utility.set_message( 800, 'HR_50320_DP_FUN_ARG_USAGE' );
      hr_utility.set_message_token( 'ARGUMENT', 'P_BUSINESS_GROUP_ID' );
      hr_utility.raise_error;
    end if;
  elsif p_function_parameter.parameter_name = 'P_VALIDATE' then
    if p_function_parameter.datatype <> c_dtype_boolean then
      hr_utility.set_message( 800, 'HR_50320_DP_FUN_ARG_USAGE' );
      hr_utility.set_message_token( 'ARGUMENT', 'P_VALIDATE' );
      hr_utility.raise_error;
    end if;
  elsif p_function_parameter.parameter_name = 'P_DATA_PUMP_ALWAYS_CALL'
  then
    if p_function_parameter.datatype <> c_dtype_varchar2 then
      hr_utility.set_message( 800, 'HR_50320_DP_FUN_ARG_USAGE' );
      hr_utility.set_message_token( 'ARGUMENT', 'P_DATA_PUMP_ALWAYS_CALL' );
      hr_utility.raise_error;
    end if;
  end if;
end check_special_parameter;

-- ----------------------- match_seed_parameter ---------------------------
-- Description:
-- Match parameter name against the seeded data set up by get_seed_parameters.
-- If a match is made, the matched flag for the matched record is set to
-- true, p_match is set to true, and the record is returned. If there is no,
-- match then p_match is set to false.
-- ------------------------------------------------------------------------
procedure match_seed_parameter
(
  p_parameter_name      in     varchar2,
  p_no_seed_parameters  in     number,
  p_seed_parameter_tbl  in out nocopy t_seed_parameter_tbl,
  p_seed_parameter      out nocopy    t_seed_parameter,
  p_match               out nocopy    boolean
)
is
begin
  for i in 1 .. p_no_seed_parameters loop
    --
    -- For user_key parameters, the actual parameter name is in the
    -- mapping_definition.
    --
    if (p_seed_parameter_tbl(i).parameter_name = p_parameter_name) or
       (p_seed_parameter_tbl(i).mapping_type = c_mapping_type_user_key and
        p_seed_parameter_tbl(i).mapping_definition = p_parameter_name)
    then
      p_seed_parameter_tbl(i).matched := true;
      p_seed_parameter := p_seed_parameter_tbl(i);
      p_match := true;
      return;
    end if;
  end loop;
  p_match := false;
end match_seed_parameter;

-- ------------------------ get_seed_parameters ---------------------------
-- Description:
-- Fetches the seeded parameter information from HR_PUMP_MODULE_PARAMETERS.
-- ------------------------------------------------------------------------
procedure get_seed_parameters( p_module_package      in  varchar2,
                               p_module_name         in  varchar2,
                               p_seed_parameter_tbl out nocopy t_seed_parameter_tbl,
                               p_no_seed_parameters  out nocopy number )
is
  cursor csr_seed_parameters( p_module_package in varchar2,
                              p_module_name    in varchar2 ) is
  select upper(hrpmp.api_parameter_name),
         upper(hrpmp.mapping_type),
         upper(hrpmp.mapping_definition),
         hrpmp.default_value
  from   hr_api_modules ham,
         hr_pump_module_parameters hrpmp
  where  upper(ham.module_package) = upper(p_module_package)
  and    upper(ham.module_name) = upper(p_module_name)
  and    upper(ham.api_module_type) in ( 'AI', 'BP','DM' )
  and    upper(hrpmp.module_name) = upper(p_module_name)
  and    upper(hrpmp.api_module_type) = upper(ham.api_module_type);
  --
  l_seqno number;
  --
  l_parameter_name     hr_pump_module_parameters.api_parameter_name%type;
  l_mapping_type       hr_pump_module_parameters.mapping_type%type;
  l_mapping_definition hr_pump_module_parameters.mapping_definition%type;
  l_default_value      hr_pump_module_parameters.default_value%type;
begin
  l_seqno := 0;
  open csr_seed_parameters( p_module_package, p_module_name );
  loop
    fetch csr_seed_parameters into l_parameter_name,
                                   l_mapping_type,
                                   l_mapping_definition,
                                   l_default_value;
    exit when csr_seed_parameters%notfound;
    --
    -- Check that special parameters such as p_business_group_id don't
    -- appear in the seeded data.
    --
    if special_parameter( l_parameter_name ) or
       ( ( l_mapping_type = c_mapping_type_aliased or
           l_mapping_type = c_mapping_type_user_key ) and
         special_parameter( l_mapping_definition ) )
    then
      hr_utility.set_message( 800, 'HR_50328_DP_SEED_SPECIAL_ARG' );
      hr_utility.set_message_token( 'ARGUMENT', l_parameter_name );
      hr_utility.raise_error;
    end if;

    l_seqno := l_seqno + 1;
    p_seed_parameter_tbl(l_seqno).parameter_name := l_parameter_name;
    p_seed_parameter_tbl(l_seqno).mapping_type := l_mapping_type;
    p_seed_parameter_tbl(l_seqno).mapping_definition := l_mapping_definition;
    p_seed_parameter_tbl(l_seqno).default_value := l_default_value;
    p_seed_parameter_tbl(l_seqno).matched := false;
  end loop;
  close csr_seed_parameters;
  p_no_seed_parameters := l_seqno;
exception
  when others then
    p_no_seed_parameters := 0;
    if csr_seed_parameters%isopen then
      close csr_seed_parameters;
    end if;
    raise;
end get_seed_parameters;

-- ------------------------ get_mapping_packages --------------------------
-- Description:
-- Fetches the mapping function package information from
-- HR_PUMP_MAPPING_PACKAGES.
-- ------------------------------------------------------------------------
procedure get_mapping_packages
(
  p_module_package          in  varchar2,
  p_module_name             in  varchar2,
  p_mapping_package_tbl     out nocopy t_mapping_package_tbl
)
is
  cursor csr_mapping_packages
  (
    p_module_package        in varchar2,
    p_module_name           in varchar2
  ) is
  select mp.mapping_package
  from   hr_pump_mapping_packages mp,
         hr_api_modules am
  where  (mp.module_name is not null and
          upper(mp.module_name) = upper(p_module_name) and
          upper(am.module_name) = upper(p_module_name) and
          upper(am.api_module_type) = upper(mp.api_module_type))
  or     (mp.module_package is not null and
          upper(mp.module_package) = upper(p_module_package))
  or     (mp.module_package is null and mp.module_name is null)
  order by checking_order asc;
  --
  l_seqno           number;
  l_mapping_package hr_pump_mapping_packages.mapping_package%type;
begin
  l_seqno := 1;
  open csr_mapping_packages( p_module_package, p_module_name );
  loop
    fetch csr_mapping_packages into l_mapping_package;
    exit when csr_mapping_packages%notfound;
    p_mapping_package_tbl(l_seqno).mapping_package := l_mapping_package;
    l_seqno := l_seqno + 1;
  end loop;
  close csr_mapping_packages;
  --
  -- Add the default package onto the end of the list of packages.
  --
  p_mapping_package_tbl(l_seqno).mapping_package := c_get_function_package;
exception
  when others then
    p_mapping_package_tbl.delete;
    if csr_mapping_packages%isopen then
      close csr_mapping_packages;
    end if;
    raise;
end get_mapping_packages;

-- ---------------------------- get_latest_api ----------------------------
-- Description:
-- Uses the results of the hr_general.describe_procedure call to get
-- the latest API overload version. By "latest" we mean the overload with
-- the most mandatory parameters as this is the normal case with the
-- HRMS API strategy. Of course, the HRMS API strategy will allow APIs
-- to be overloaded to remove parameters also in which case the above
-- method is incorrect. If more than one interface has a given number
-- of mandatory parameters then an arbitrary choice is made. The above
-- algorithm was agreed by Peter Attwood (HRMS API strategy).
-- ------------------------------------------------------------------------
procedure get_latest_api
(
  p_overload          in out nocopy dbms_describe.number_table,
  p_position          in out nocopy dbms_describe.number_table,
  p_level             in out nocopy dbms_describe.number_table,
  p_argument_name     in out nocopy dbms_describe.varchar2_table,
  p_datatype          in out nocopy dbms_describe.number_table,
  p_default_value     in out nocopy dbms_describe.number_table,
  p_in_out            in out nocopy dbms_describe.number_table,
  p_length            in out nocopy dbms_describe.number_table,
  p_precision         in out nocopy dbms_describe.number_table,
  p_scale             in out nocopy dbms_describe.number_table,
  p_radix             in out nocopy dbms_describe.number_table,
  p_spare             in out nocopy dbms_describe.number_table,
  p_apis                 out nocopy boolean,
  p_parameters           out nocopy boolean
) is
  i                    binary_integer;
  j                    binary_integer;
  l_chosen_overload    number;
  l_max_mandatory_args number;
  l_distinct_overloads dbms_describe.number_table;
begin
  if g_debug then
    hr_utility.trace('Entered get_latest_api.');
  end if;

  --
  -- Want the latest overload for a procedure i.e. the maximum overload
  -- value and no p_position(i) = 0 entry.
  --
  i := p_overload.first;
  loop
    exit when not p_position.exists(i);

    --
    -- Always mark function or procedure with zero arguments in
    -- distinct overload table.
    --
    if p_position(i) = 0 or p_datatype(i) = c_dtype_undefined then
      l_distinct_overloads( p_overload(i) ) := -1;

      if g_debug then
        if p_position(i) = 0 then
          hr_utility.trace
          ('Unsuitable overload ' || p_overload(i) || ' is a function.');
        else
          hr_utility.trace
          ('Unsuitable overload ' || p_overload(i) || ' has no parameters');
        end if;
      end if;

    --
    -- Speculatively mark a possible procedure in the distinct overload
    -- table.
    --
    elsif not l_distinct_overloads.exists( p_overload(i) ) then
      l_distinct_overloads( p_overload(i) ) := 0;

      if g_debug then
        hr_utility.trace
        ('Overload ' || p_overload(i) || ' is a candidate API.');
      end if;
    end if;

    i := p_overload.next(i);
  end loop;

  --
  -- Delete the unsuitable overloads from the distinct overload
  -- list.
  --
  i := l_distinct_overloads.first;
  loop
    exit when not l_distinct_overloads.exists(i);
    j := l_distinct_overloads.next(i);

    if l_distinct_overloads(i) = -1 then
      l_distinct_overloads.delete(i);
    end if;

    i := j;
  end loop;

  --
  -- No procedures found hence not an API by definition.
  --
  if l_distinct_overloads.count = 0 then
    p_parameters := false;
    p_apis := false;

    if g_debug then
      hr_utility.trace('No candidate API procedures found.');
    end if;

    return;
  else
    p_parameters := true;
    p_apis := true;
  end if;

  --
  -- Count the mandatory parameters for each overload.
  --
  i := p_default_value.first;
  loop
    exit when not p_default_value.exists(i);

    if p_default_value(i) = 0 and
       l_distinct_overloads.exists( p_overload(i) ) then
        l_distinct_overloads( p_overload(i) ) :=
        l_distinct_overloads( p_overload(i) ) + 1;
    end if;

    i := p_default_value.next(i);
  end loop;

  --
  -- Now get the overload with the most parameters.
  --
  i :=  l_distinct_overloads.first;
  l_chosen_overload := i;
  l_max_mandatory_args := l_distinct_overloads(i);
  loop

    if g_debug then
      hr_utility.trace
      ('Overload: ' || i || ' Mandatory Args: ' || l_distinct_overloads(i)
      );
    end if;

    i :=  l_distinct_overloads.next(i);

    exit when not l_distinct_overloads.exists(i);

    if l_distinct_overloads(i) >= l_max_mandatory_args then
      l_chosen_overload :=  i;
      l_max_mandatory_args := l_distinct_overloads(i);
    end if;

  end loop;

  if g_debug then
    hr_utility.trace('Selected overload: ' || l_chosen_overload);
  end if;

  --
  -- Delete information that does not belong to the selected overload
  -- version.
  --
  i := p_position.first;
  loop
    --
    -- Exit the loop if nothing to get.
    --
    exit when not p_position.exists(i);
    j :=  p_position.next(i);

    if p_overload(i) <> l_chosen_overload then
      p_overload.delete(i);
      p_position.delete(i);
      p_level.delete(i);
      p_argument_name.delete(i);
      p_datatype.delete(i);
      p_default_value.delete(i);
      p_in_out.delete(i);
      p_length.delete(i);
      p_precision.delete(i);
      p_scale.delete(i);
      p_radix.delete(i);
      p_spare.delete(i);
    end if;

    i := j;
  end loop;

  if g_debug then
    hr_utility.trace('get_latest_api: deleted unwanted overloads');
  end if;
end get_latest_api;

-- -------------------------- describe_api --------------------------------
-- Description:
-- Calls hr_general.describe_procedure on the API specified by
-- p_module_package || '.' || p_module_name, and returns an initial
-- t_parameter_tbl and a count of the API parameters.
-- ------------------------------------------------------------------------
procedure describe_api
(
  p_module_package    in  varchar2,
  p_module_name       in  varchar2,
  p_parameter_tbl     out nocopy t_parameter_tbl,
  p_parameter_counts  out nocopy t_parameter_counts
)
is
  -- dbms_describe parameters.
  l_overload       dbms_describe.number_table;
  l_position       dbms_describe.number_table;
  l_level          dbms_describe.number_table;
  l_argument_name  dbms_describe.varchar2_table;
  l_datatype       dbms_describe.number_table;
  l_default_value  dbms_describe.number_table;
  l_in_out         dbms_describe.number_table;
  l_length         dbms_describe.number_table;
  l_precision      dbms_describe.number_table;
  l_scale          dbms_describe.number_table;
  l_radix          dbms_describe.number_table;
  l_spare          dbms_describe.number_table;
  --
  l_first          number;
  l_last           number;
  l_seqno          number; -- Sequence in dbms_describle list.
  i                number;
  --
  l_parameters     boolean;
  l_apis           boolean;
  --
begin
  if g_debug then
    hr_utility.trace('Entered describe_api.');
  end if;

  begin
    hr_general.describe_procedure
    ( object_name   => p_module_package || '.' || p_module_name,
      reserved1     => null,
      reserved2     => null,
      overload      => l_overload,
      position      => l_position,
      level         => l_level,
      argument_name => l_argument_name,
      datatype      => l_datatype,
      default_value => l_default_value,
      in_out        => l_in_out,
      length        => l_length,
      precision     => l_precision,
      scale         => l_scale,
      radix         => l_radix,
      spare         => l_spare );
  exception
    when package_not_exists or proc_not_in_package or invalid_object_name then
      hr_utility.set_message( 800, 'HR_50305_DP_NO_SUCH_API' );
      hr_utility.set_message_token( 'PACKAGE', p_module_package );
      hr_utility.set_message_token( 'MODULE', p_module_name );
      hr_utility.raise_error;
    when remote_object then
      hr_utility.set_message( 800, 'HR_50307_DP_REMOTE_OBJECT' );
      hr_utility.set_message_token
      ( 'OBJECT', p_module_package || '.' || p_module_name );
      hr_utility.raise_error;
    when invalid_package then
      hr_utility.set_message( 800, 'HR_50306_DP_INVALID_PKG' );
      hr_utility.set_message_token( 'PACKAGE', p_module_package );
      hr_utility.raise_error;
  end;

  if g_debug then
    hr_utility.trace('Successful dbms_describe.');
  end if;

  --
  -- Get the latest overloaded version of the API.
  --
  get_latest_api
  (p_overload      => l_overload
  ,p_position      => l_position
  ,p_level         => l_level
  ,p_argument_name => l_argument_name
  ,p_datatype      => l_datatype
  ,p_default_value => l_default_value
  ,p_in_out        => l_in_out
  ,p_length        => l_length
  ,p_precision     => l_precision
  ,p_scale         => l_scale
  ,p_radix         => l_radix
  ,p_spare         => l_spare
  ,p_apis          => l_apis
  ,p_parameters    => l_parameters
  );
  --
  -- Check that an API with parameters was found.
  --
  if not l_parameters and not l_apis then
    hr_utility.set_message( 800, 'HR_50308_DP_NOT_AN_API' );
    hr_utility.set_message_token
    ( 'OBJECT', p_module_package || '.' || p_module_name );
    hr_utility.raise_error;
  end if;

  --
  -- Process the parameters.
  --
  p_parameter_counts.long_parameters := 0;
  l_seqno := l_position.first;
  loop
    --
    -- Exit when no more parameters to get.
    --
    exit when not l_position.exists(l_seqno);
    --
    i := l_position(l_seqno);

    if g_debug then
      hr_utility.trace
      ('Parameter: ' || l_argument_name(l_seqno) || ' Call Position: ' || i ||
       ' Table Position: ' || l_seqno
      );
    end if;

    --
    -- Check that parameter names start with 'p_'.
    --
    if substr(lower(l_argument_name(l_seqno)), 1, 2) <> 'p_' then
      hr_utility.set_message( 800, 'HR_50310_DP_BAD_API_ARG_NAME');
      hr_utility.set_message_token( 'ARGUMENT', l_argument_name(l_seqno));
      hr_utility.raise_error;
    end if;

    --
    -- Check that the data type is supported.
    --
    if l_datatype(l_seqno) <> c_dtype_varchar2 and
       l_datatype(l_seqno) <> c_dtype_number   and
       l_datatype(l_seqno) <> c_dtype_date     and
       l_datatype(l_seqno) <> c_dtype_boolean  and
       l_datatype(l_seqno) <> c_dtype_long
    then
      hr_utility.set_message( 800, 'HR_50311_DP_BAD_API_ARG_TYPE' );
      hr_utility.set_message_token( 'ARGUMENT', l_argument_name(l_seqno) );
      hr_utility.set_message_token( 'TYPE', l_datatype(l_seqno) );
      hr_utility.raise_error;
    end if;

    --
    -- Set up the long parameter count.
    --
    if l_datatype(l_seqno) = c_dtype_long then
      p_parameter_counts.long_parameters :=
      p_parameter_counts.long_parameters + 1;
      if p_parameter_counts.long_parameters > 1 then
        hr_utility.set_message( 800, 'HR_50016_DP_TOO_MANY_LONGS' );
        hr_utility.set_message_token
        ( 'API', p_module_package || '.' || p_module_name );
        hr_utility.set_message_token( 'ARGUMENT', l_argument_name(l_seqno) );
        hr_utility.set_message_token( 'FUNCTION', p_module_name );
        hr_utility.raise_error;
      end if;
    end if;

    --
    -- Set up the rest of the parameter information.
    --
    p_parameter_tbl(i).seqno := i;
    p_parameter_tbl(i).api_seqno := i;
    p_parameter_tbl(i).in_out := l_in_out( l_seqno );
    p_parameter_tbl(i).parameter_name :=
    upper(l_argument_name( l_seqno ));
    p_parameter_tbl(i).datatype := l_datatype( l_seqno );
    if l_default_value(l_seqno) = 1 then
      p_parameter_tbl(i).defaultable := true;
    else
      p_parameter_tbl(i).defaultable := false;
    end if;

    -- Initialise the remaining fields.
    p_parameter_tbl(i).default_value := null;
    p_parameter_tbl(i).mapping_type := null;
    p_parameter_tbl(i).mapping_definition := null;

    l_seqno := l_position.next( l_seqno );
  end loop;

  --
  -- Set up counts of API and total parameters.
  --
  p_parameter_counts.api_parameters := p_parameter_tbl.count;
  p_parameter_counts.total_parameters := p_parameter_tbl.count;
end describe_api;

-- ---------------------- get_default_value -------------------------------
-- Description:
-- Gets the default value for the combination of p_defaulting_style and
-- p_datatype.
-- ------------------------------------------------------------------------
function get_default_value
(
  p_defaulting_style in number,
  p_datatype         in number,
  p_mapping_type     in varchar2
)
return varchar2 is
  l_default_value varchar2(64) := 'null';
begin
  --
  -- User-keys are VARCHAR2 and default NULL.
  --
  if p_mapping_type = c_mapping_type_user_key then
    l_default_value := g_tbl_default_null(c_dtype_varchar2);
  --
  -- Set defaults according to defaulting style.
  --
  elsif p_defaulting_style = c_default_null then
    l_default_value := g_tbl_default_null(p_datatype);
  elsif p_defaulting_style = c_default_hr_api then
    l_default_value := g_tbl_default_hr_api(p_datatype);
  end if;
  return l_default_value;
end get_default_value;

-- ---------------------- get_call_default_value --------------------------
-- Description:
-- Gets the default value for call procedure. This is to allow shorter
-- code to be generated.
-- ------------------------------------------------------------------------
function get_call_default_value
(
  p_default_value    in varchar2,
  p_datatype         in number,
  p_mapping_type     in varchar2
)
return varchar2 is
  l_call_default_value varchar2(64) := p_default_value;
begin
  --
  -- User-keys are VARCHAR2 and default NULL.
  --
  if p_mapping_type = c_mapping_type_user_key then
    l_call_default_value := g_tbl_call_default_null(c_dtype_varchar2);
  --
  -- Set other default values according to data type.
  --
  elsif p_default_value = g_tbl_default_null(p_datatype) then
    l_call_default_value := g_tbl_call_default_null(p_datatype);
  elsif p_default_value = g_tbl_default_hr_api(p_datatype) then
    l_call_default_value := g_tbl_call_default_hr_api(p_datatype);
  end if;
  return l_call_default_value;
end get_call_default_value;

-- ------------------------ default_is_null -------------------------------
-- Description:
-- Returns true if the default value supplied is null.
-- ------------------------------------------------------------------------
function default_is_null
(p_default_value in varchar2
) return boolean is
  l_default_value varchar2(2000);
begin
  l_default_value := upper(p_default_value);
  return l_default_value = 'NULL' or
         l_default_value = 'D(NULL)' or
         l_default_value = 'N(NULL)';
end default_is_null;

-- ------------------------ default_is_hr_api -----------------------------
-- Description:
-- Returns true if the default value supplied is one of the HR_API values.
-- ------------------------------------------------------------------------
function default_is_hr_api
(p_default_value in varchar2
) return boolean is
  l_default_value varchar2(2000);
begin
  l_default_value := upper(p_default_value);
  return l_default_value = 'HR_API.G_VARCHAR2' or
         l_default_value = 'HR_API.G_DATE' or
         l_default_value = 'HR_API.G_NUMBER';
end default_is_hr_api;

-- ----------------------- gen_batch_lines_column_name --------------------
-- Description:
-- Generates the batch lines column name, given a sequence number.
-- ------------------------------------------------------------------------
function gen_batch_lines_column_name
(
  p_seqno    in number,
  p_datatype in number
)
return varchar2 is
  l_column_name varchar2(30);
begin
  if p_datatype = c_dtype_long then
    l_column_name := c_long_value_col;
  else
    l_column_name := c_parameter_value_col || ltrim(to_char( p_seqno, '000' ));
  end if;
  return l_column_name;
end gen_batch_lines_column_name;

-- ----------------------- gen_def_check_name -----------------------------
-- Description:
-- Given a name, based on the cursor field name, generates the name
-- of the defaulting check column for a defaultable variable.
-- ------------------------------------------------------------------------
function gen_def_check_name
(
  p_cursor_field_name in varchar2
)
return varchar2 is
  l_check_name varchar2(30);
begin
  --
  -- When checking defaults an additional cursor column is required except
  -- in the case of long values where the value is passed unchanged because
  -- the DECODE function cannot handle long values.
  --
  if p_cursor_field_name like '%' || c_long_value_col then
    l_check_name := p_cursor_field_name;
  else
    l_check_name :=
    replace( p_cursor_field_name, c_cursor_value_col, c_def_check_col );
  end if;
  return l_check_name;
end gen_def_check_name;

-- ---------------------- merge_api_and_seed_data -------------------------
-- Description:
-- Merges seed data information into the API parameter list.
-- ------------------------------------------------------------------------
procedure merge_api_and_seed_data
(
  p_default_style       in     number,
  p_parameter_tbl       in out nocopy t_parameter_tbl,
  p_seed_parameter_tbl  in out nocopy t_seed_parameter_tbl,
  p_function_tbl           out nocopy t_function_tbl,
  p_parameter_counts    in out nocopy t_parameter_counts
)
is
  l_seed_parameter t_seed_parameter;
  l_match          boolean;
  l_package_name   hr_pump_module_parameters.mapping_definition%type;
  l_function_name  hr_pump_module_parameters.mapping_definition%type;
  l_dotpos         number;

  l_parameter_tbl t_parameter_tbl;
  l_seed_parameter_tbl t_seed_parameter_tbl;
  l_parameter_counts t_parameter_counts;
  --
  l_upper_defval hr_pump_module_parameters.default_value%type;
begin
  -- Remember IN OUT parameters.
  l_parameter_tbl      := p_parameter_tbl;
  l_seed_parameter_tbl := p_seed_parameter_tbl;
  l_parameter_counts   := p_parameter_counts;


  p_parameter_counts.batch_lines_parameters := 0;
  p_parameter_counts.functions := 0;
  for i in 1 .. p_parameter_counts.api_parameters loop
    --
    -- Do match against seeded data.
    --
    match_seed_parameter( p_parameter_tbl(i).parameter_name,
                          p_parameter_counts.seed_parameters,
                          p_seed_parameter_tbl,
                          l_seed_parameter,
                          l_match );
    if l_match then
      --
      -- Got a match.
      --
      --
      -- Check that seed data is set up correctly.
      --
      if ( l_seed_parameter.mapping_type is not null and
           l_seed_parameter.mapping_type <> c_mapping_type_normal and
           l_seed_parameter.mapping_definition is null ) or
         ( l_seed_parameter.mapping_type is null and
           l_seed_parameter.mapping_definition is not null ) then
        hr_utility.set_message( 800, 'HR_50312_DP_BAD_MAP_DATA' );
        hr_utility.set_message_token
        ( 'PARAMETER', l_seed_parameter.parameter_name );
        hr_utility.raise_error;
      end if;
      --
      -- Copy values over from the seed data.
      --
      p_parameter_tbl(i).mapping_type := l_seed_parameter.mapping_type;
      p_parameter_tbl(i).mapping_definition :=
      l_seed_parameter.mapping_definition;
      --
      -- Handling default values depends on the data type.
      --
      if l_seed_parameter.default_value is not null then
        if p_parameter_tbl(i).datatype = c_dtype_number
        then
          p_parameter_tbl(i).default_value := l_seed_parameter.default_value;
        elsif p_parameter_tbl(i).datatype = c_dtype_boolean then
          if upper(p_parameter_tbl(i).default_value) = 'NULL' then
            p_parameter_tbl(i).default_value := 'NULL';
          else
            p_parameter_tbl(i).default_value :=
            '''' || l_seed_parameter.default_value || '''';
          end if;
        elsif p_parameter_tbl(i).datatype = c_dtype_date then
          --
          -- Date parameters are converted to dates using the local date
          -- generation function.
          --
          l_upper_defval := upper(l_seed_parameter.default_value);
          if l_upper_defval = 'NULL' then
            p_parameter_tbl(i).default_value := 'D(NULL)';
          elsif l_upper_defval = 'HR_API.G_DATE' then
            p_parameter_tbl(i).default_value := l_upper_defval;
          else
            p_parameter_tbl(i).default_value :=
            'd(''' || l_seed_parameter.default_value || ''')';
          end if;
        else
          --
          -- varchar2 and long parameters.
          --
          l_upper_defval := upper(l_seed_parameter.default_value);
          if l_upper_defval = 'NULL' or
             l_upper_defval = 'HR_API.G_VARCHAR2' then
            p_parameter_tbl(i).default_value := l_upper_defval;
          else
            p_parameter_tbl(i).default_value :=
            '''' || l_seed_parameter.default_value || '''';
          end if;
        end if;
      end if;
      --
      -- For user_key values the mapping_definition is the API parameter
      -- name. The parameter_name is the name of the user_key parameter.
      --
      if l_seed_parameter.mapping_type = c_mapping_type_user_key then
        p_parameter_tbl(i).parameter_name := l_seed_parameter.parameter_name;
      end if;
    end if;
    --
    -- Set up mapping information for the parameter, if required.
    --
    if p_parameter_tbl(i).mapping_type is null then
      if ( p_parameter_tbl(i).in_out = c_ptype_in or
           p_parameter_tbl(i).in_out = c_ptype_in_out ) and
         ( lower(p_parameter_tbl(i).parameter_name) like '%_id' ) and
         ( lower(p_parameter_tbl(i).parameter_name) <> 'p_business_group_id' )
      then
        --
        -- Generate get_id function for _id parameter.
        -- For parameter p_xxx generate the function name get_xxx.
        --
        p_parameter_tbl(i).mapping_type := c_mapping_type_function;
        p_parameter_tbl(i).mapping_definition :=
        'get' || substr( lower(p_parameter_tbl(i).parameter_name), 2 );
      else
        p_parameter_tbl(i).mapping_type := c_mapping_type_normal;
        p_parameter_tbl(i).mapping_definition := null;
      end if;
    end if;

    --
    -- Set up batch lines column information for the parameter.
    --
    if ( p_parameter_tbl(i).mapping_type <> c_mapping_type_function ) and
       ( not special_parameter( p_parameter_tbl(i).parameter_name ) )
    then
      p_parameter_counts.batch_lines_parameters :=
      p_parameter_counts.batch_lines_parameters + 1;
      p_parameter_tbl(i).batch_lines_seqno :=
      p_parameter_counts.batch_lines_parameters;
      p_parameter_tbl(i).batch_lines_column :=
      gen_batch_lines_column_name
      (
        p_parameter_tbl(i).batch_lines_seqno,
        p_parameter_tbl(i).datatype
      );
    else
      p_parameter_tbl(i).batch_lines_seqno := null;
    end if;

    --
    -- Set up the function list entry for function calls.
    --
    if p_parameter_tbl(i).mapping_type = c_mapping_type_function then
      p_parameter_counts.functions := p_parameter_counts.functions + 1;
      --
      -- Set the package_name, and function_name from the mapping definition.
      --
      l_dotpos := instr(p_parameter_tbl(i).mapping_definition, '.');
      if l_dotpos <> 0 then
        l_function_name :=
        substr(p_parameter_tbl(i).mapping_definition, l_dotpos + 1);
        l_package_name :=
        substr(p_parameter_tbl(i).mapping_definition, 1, l_dotpos-1);
      else
        l_function_name := p_parameter_tbl(i).mapping_definition;
        l_package_name := null;
      end if;
      p_function_tbl(p_parameter_counts.functions).function_name :=
      l_function_name;
      p_function_tbl(p_parameter_counts.functions).package_name :=
      l_package_name;
      p_function_tbl(p_parameter_counts.functions).seqno :=
      p_parameter_tbl(i).seqno;
      --
      -- index1 = null means that the function has no parameters.
      --
      p_function_tbl(p_parameter_counts.functions).index1 := null;
      p_function_tbl(p_parameter_counts.functions).index2 := null;
    end if;

    --
    -- Set up default values for defaultable parameters.
    --
    if p_parameter_tbl(i).defaultable then
      if p_parameter_tbl(i).default_value is null then
        p_parameter_tbl(i).default_value :=
        get_default_value( p_default_style, p_parameter_tbl(i).datatype,
                           p_parameter_tbl(i).mapping_type );
      end if;
    end if;
  end loop;
exception
when others then
  -- Reset IN OUT parameters and set out parameters.
  p_parameter_tbl      := l_parameter_tbl;
  p_seed_parameter_tbl := l_seed_parameter_tbl;
  p_parameter_counts   := l_parameter_counts;
  p_function_tbl.delete;
  raise;
end  merge_api_and_seed_data;

-- ----------------------- describe_function ------------------------------
-- Description:
-- Calls hr_general.describe_procedure on a parameter mapping function.
-- Sets up the parameter lists for the functions and updates the relevant
-- counts.
-- ------------------------------------------------------------------------
procedure describe_function
(
  p_mapping_package_tbl     in     t_mapping_package_tbl,
  p_parameter               in     t_parameter,
  p_function                in out nocopy t_function,
  p_function_call_tbl       in out nocopy t_function_parameter_tbl,
  p_distinct_parameter_tbl  in out nocopy t_function_parameter_tbl,
  p_parameter_counts        in out nocopy t_parameter_counts
)
is
  -- dbms_describe parameters.
  l_overload       dbms_describe.number_table;
  l_position       dbms_describe.number_table;
  l_level          dbms_describe.number_table;
  l_argument_name  dbms_describe.varchar2_table;
  l_datatype       dbms_describe.number_table;
  l_default_value  dbms_describe.number_table;
  l_in_out         dbms_describe.number_table;
  l_length         dbms_describe.number_table;
  l_precision      dbms_describe.number_table;
  l_scale          dbms_describe.number_table;
  l_radix          dbms_describe.number_table;
  l_spare          dbms_describe.number_table;
  --
  l_first_overload binary_integer;
  l_seqno          binary_integer;
  l_currpos        binary_integer;
  -- Package for the mapping function.
  l_package        hr_pump_module_parameters.mapping_definition%type;
  --
  l_match           boolean;
  l_call_params     number;  -- Index into function call parameters list.
  l_distinct_params number;  -- Index into distinct parameters list.

  l_function                t_function;
  l_function_call_tbl       t_function_parameter_tbl;
  l_distinct_parameter_tbl  t_function_parameter_tbl;
  l_parameter_counts        t_parameter_counts;
  l_is_a_function           boolean := false;
  --
begin
  --

  -- Remember IN OUT parameters.
  l_function               := p_function;
  l_function_call_tbl      := p_function_call_tbl;
  l_distinct_parameter_tbl := p_distinct_parameter_tbl;
  l_parameter_counts       := p_parameter_counts;

  for i in 1 .. p_mapping_package_tbl.count loop
    begin
      l_package := p_mapping_package_tbl(i).mapping_package;
      hr_general.describe_procedure
      ( object_name   => l_package || '.' || p_function.function_name,
        reserved1     => null,
        reserved2     => null,
        overload      => l_overload,
        position      => l_position,
        level         => l_level,
        argument_name => l_argument_name,
        datatype      => l_datatype,
        default_value => l_default_value,
        in_out        => l_in_out,
        length        => l_length,
        precision     => l_precision,
        scale         => l_scale,
        radix         => l_radix,
        spare         => l_spare );
        --
        -- Found a function, so set up the package name and exit the loop.
        --
        p_function.package_name := l_package;
        exit;
    exception
      when package_not_exists or invalid_package then
        hr_utility.set_message( 800, 'HR_50313_DP_NO_MAP_PKG' );
        hr_utility.set_message_token( 'PACKAGE', l_package );
        hr_utility.raise_error;
      when remote_object then
        hr_utility.set_message( 800, 'HR_50307_DP_REMOTE_OBJECT' );
        hr_utility.set_message_token
        ( 'OBJECT', l_package || '.' || p_function.function_name );
        hr_utility.raise_error;
      when invalid_object_name then
        hr_utility.set_message( 800, 'HR_50315_DP_BAD_FUNCTION_NAME' );
        hr_utility.set_message_token
        ( 'OBJECT', l_package || '.' || p_function.function_name );
        hr_utility.raise_error;
      when proc_not_in_package then
        if i = p_mapping_package_tbl.count then
          hr_utility.set_message( 800, 'HR_50314_DP_NO_SUCH_FUNCTION' );
          hr_utility.set_message_token( 'FUNCTION', p_function.function_name );
          hr_utility.raise_error;
        end if;
    end;
  end loop;

  --
  -- Build up parameter lists.
  --
  l_seqno := l_position.first;
  l_first_overload := l_overload( l_seqno );
  loop
    --
    -- Exit when no more parameters to get.
    --
    exit when not l_position.exists( l_seqno );

    --
    -- Check for overloaded function call as overloading is not allowed.
    --
    if l_overload(l_seqno) <> l_first_overload then
      hr_utility.set_message( 800, 'HR_50318_DP_OVL_FUNCTION' );
      hr_utility.set_message_token
      ( 'OBJECT', c_get_function_package || '.' || p_function.function_name );
      hr_utility.raise_error;
    end if;

    --
    -- Handle the function return value.
    --
    if l_position( l_seqno ) = 0 then
      l_is_a_function := true;

      --
      -- Check that the function is of the correct type.
      --
      if l_datatype( l_seqno ) <> p_parameter.datatype and not
         ( l_datatype( l_seqno ) = c_dtype_binary_integer and
           p_parameter.datatype = c_dtype_number ) and not
         ( ( l_datatype( l_seqno ) = c_dtype_number or
             l_datatype( l_seqno ) = c_dtype_binary_integer ) and
           p_parameter.datatype = c_dtype_varchar2 )
      then
        hr_utility.set_message( 800, 'HR_50317_DP_BAD_FUNCTION_RET' );
        hr_utility.set_message_token
        ( 'FUNCTION', c_get_function_package || '.' || p_function.function_name );
        hr_utility.set_message_token( 'PARAMETER', p_parameter.parameter_name );
        hr_utility.raise_error;
      end if;

      p_function.ret_type := l_datatype( l_seqno );

    --
    -- Handle ordinary parameters.
    --
    else
      --
      -- Set l_currpos so that parameters appear in the same sequence as
      -- in the function call.
      --
      l_currpos := l_position( l_seqno ) + p_parameter_counts.call_parameters;

      --
      -- Check that the data type is supported.
      --
      if l_datatype(l_seqno) <> c_dtype_varchar2 and
         l_datatype(l_seqno) <> c_dtype_number   and
         l_datatype(l_seqno) <> c_dtype_date     and
         l_datatype(l_seqno) <> c_dtype_boolean  and
         l_datatype(l_seqno) <> c_dtype_long
      then
        hr_utility.set_message( 800, 'HR_50319_DP_FUN_BAD_ARG_TYPE' );
        hr_utility.set_message_token( 'FUNCTION', p_function.function_name );
        hr_utility.set_message_token( 'ARGUMENT', l_argument_name(l_seqno) );
        hr_utility.set_message_token( 'TYPE', l_datatype(l_seqno) );
        hr_utility.raise_error;
      end if;

      p_function_call_tbl(l_currpos).parameter_name :=
      upper(l_argument_name(l_seqno));
      p_function_call_tbl(l_currpos).function_parameter :=
      upper(l_argument_name(l_seqno));
      p_function_call_tbl(l_currpos).datatype := l_datatype(l_seqno);
      p_function_call_tbl(l_currpos).defaultable := p_parameter.defaultable;
      p_function_call_tbl(l_currpos).default_value := null;

      --
      -- Add parameter name to the distinct parameter list if necessary.
      --
      l_match := false;
      for i in 1 .. p_parameter_counts.distinct_parameters loop
        if p_distinct_parameter_tbl(i).parameter_name =
           upper(l_argument_name(l_seqno))
        then
          --
          -- Got a match. Check that parameter usage types are compatible.
          --
          if p_distinct_parameter_tbl(i).datatype <> l_datatype(l_seqno) then
            hr_utility.set_message( 800, 'HR_50320_DP_FUN_ARG_USAGE' );
            hr_utility.set_message_token( 'ARGUMENT', l_argument_name(l_seqno) );
            hr_utility.raise_error;
          end if;
          --
          -- If p_parameter is not defaultable then all parameters for its
          -- mapping function are not defaultable either. If this mapping
          -- function shares parameters with other mapping functions then
          -- those parameters must be marked as non-defaultable.
          --
          if not p_parameter.defaultable then
            p_distinct_parameter_tbl(i).defaultable := false;
          end if;
          --
          -- Flag the fact that there is a match and exit.
          --
          l_match := true;
          exit;
        end if;
      end loop;

      --
      -- If no match add to distinct parameter list.
      --
      if not l_match then
        l_distinct_params := p_parameter_counts.distinct_parameters + 1;
        p_parameter_counts.distinct_parameters := l_distinct_params;
        p_distinct_parameter_tbl(l_distinct_params).parameter_name :=
        upper(l_argument_name(l_seqno));
        p_distinct_parameter_tbl(l_distinct_params).mapping_function :=
        p_function.function_name;
        p_distinct_parameter_tbl(l_distinct_params).datatype :=
        l_datatype(l_seqno);
        p_distinct_parameter_tbl(l_distinct_params).defaultable :=
        p_parameter.defaultable;
        p_distinct_parameter_tbl(l_distinct_params).default_value := null;
        --
        -- The batch_lines_column field will be set in merge_function_data.
        --
        p_distinct_parameter_tbl(l_distinct_params).batch_lines_column := null;
      end if;

      --
      -- Look for ALWAYS_CALL flag parameter.
      --
      if upper(l_argument_name(l_seqno)) = 'P_DATA_PUMP_ALWAYS_CALL' then
        p_function.always_call := true;
      end if;

    end if;

    l_seqno := l_position.next(l_seqno);
  end loop;

  --
  -- Verify that this it was actually a function.
  --
  if not l_is_a_function then
    hr_utility.set_message( 800, 'HR_50316_DP_NOT_FUNCTION' );
    hr_utility.set_message_token( 'FUNCTION', p_function.function_name );
    hr_utility.raise_error;
  end if;

  --
  -- Update indexes in the function table, and the count of function call
  -- parameters.
  --
  if l_position.count <> 1 then
    p_function.index1 := p_parameter_counts.call_parameters + 1;
    -- Note: l_position.count includes the function return (position 0).
    p_function.index2 := p_function.index1 + l_position.count - 2;
    p_parameter_counts.call_parameters := p_function.index2;
  end if;
exception
when others then
  -- Reset IN OUT parameters.
  p_function               := l_function;
  p_function_call_tbl      := l_function_call_tbl;
  p_distinct_parameter_tbl := l_distinct_parameter_tbl;
  p_parameter_counts       := l_parameter_counts;
  raise;
end describe_function;

-- ---------------------- merge_function_data -----------------------------
-- Description:
-- Builds the function parameter information, and merges it with any remaining
-- seed data into p_parameter_tbl.
-- ------------------------------------------------------------------------
procedure merge_function_data
(
  p_module_package         in     varchar2,
  p_module_name            in     varchar2,
  p_defaulting_style       in     number,
  p_mapping_package_tbl    in     t_mapping_package_tbl,
  p_parameter_tbl          in out nocopy t_parameter_tbl,
  p_function_tbl           in out nocopy t_function_tbl,
  p_function_call_tbl      in out nocopy t_function_parameter_tbl,
  p_distinct_parameter_tbl in out nocopy t_function_parameter_tbl,
  p_parameter_counts       in out nocopy t_parameter_counts
)
is
  l_function_parameter t_function_parameter;
  l_api_parameter      t_parameter;
  l_total_parameters   number;
  l_batch_lines_params number;
  l_match              boolean;
  l_mapping_package_tbl t_mapping_package_tbl;

  l_parameter_tbl          t_parameter_tbl;
  l_function_tbl           t_function_tbl;
  l_function_call_tbl      t_function_parameter_tbl;
  l_distinct_parameter_tbl t_function_parameter_tbl;
  l_parameter_counts       t_parameter_counts;
  --
begin
  -- Remember IN OUT parameters.
  l_parameter_tbl          :=   p_parameter_tbl;
  l_function_tbl           :=  	p_function_tbl;
  l_function_call_tbl      :=  	p_function_call_tbl;
  l_distinct_parameter_tbl :=  	p_distinct_parameter_tbl;
  l_parameter_counts       :=  	p_parameter_counts;
  --
  -- Build up the function parameter lists.
  --
  p_parameter_counts.distinct_parameters := 0;
  p_parameter_counts.call_parameters := 0;
  for i in 1 .. p_parameter_counts.functions loop
    --
    -- Check whether or not the user wanted a specific mapping package.
    --
    if p_function_tbl(i).package_name is not null then
      l_mapping_package_tbl(1).mapping_package :=
      p_function_tbl(i).package_name;
    else
      l_mapping_package_tbl := p_mapping_package_tbl;
    end if;
    describe_function( l_mapping_package_tbl,
                       p_parameter_tbl(p_function_tbl(i).seqno),
                       p_function_tbl(i),
                       p_function_call_tbl,
                       p_distinct_parameter_tbl,
                       p_parameter_counts );
    l_mapping_package_tbl.delete;
  end loop;
  --
  -- Function parameter lists are built so check the function arguments
  -- against the API parameters.
  --
  for i in 1 .. p_parameter_counts.distinct_parameters loop
    l_match := false;
    l_function_parameter := p_distinct_parameter_tbl(i);
    for j in 1 .. p_parameter_counts.api_parameters loop
      --
      -- Handle aliased parameter mapping.
      --
      l_api_parameter := p_parameter_tbl(j);
      if l_api_parameter.mapping_type = c_mapping_type_aliased and
         (l_api_parameter.mapping_definition =
          l_function_parameter.parameter_name)
      then
        --
        -- Need to overwrite the parameter name with the alias name in the
        -- call list and distinct parameter list.
        --
        for k in 1 .. p_parameter_counts.call_parameters loop
          if p_function_call_tbl(k).parameter_name =
             l_api_parameter.mapping_definition
          then
            p_function_call_tbl(k).parameter_name :=
            l_api_parameter.parameter_name;
          end if;
        end loop;
        l_function_parameter.parameter_name := l_api_parameter.parameter_name;
        l_match := true;
      --
      -- Handle user_key.
      --
      elsif l_api_parameter.mapping_type = c_mapping_type_user_key and
            (l_api_parameter.parameter_name =
             l_function_parameter.parameter_name)
      then
        l_match := true;
      --
      -- Check for simple parameter name match.
      --
      elsif l_api_parameter.parameter_name =
            l_function_parameter.parameter_name and
            l_api_parameter.mapping_type <> c_mapping_type_function
      then
        l_match := true;
      end if;
      --
      if l_match then
        --
        -- At last we can set the function parameter default value.
        --
        l_function_parameter.default_value := l_api_parameter.default_value;
        --
        -- If the function parameter is mandatory (i.e. because one of
        -- the mapping functions that uses it corresponds to a mandatory
        -- API parameter) it is necessary to make the API parameter matched
        -- here mandatory also.
        --
        if not l_function_parameter.defaultable and
           l_api_parameter.defaultable
        then
          p_parameter_tbl(j).defaultable := false;
        --
        -- If the function parameter is defaultable and the corresponding
        -- API parameter is mandatory then mark the function parameter
        -- as mandatory also. This is for the code that determines the
        -- conditions under which a mapping function should be called.
        --
        elsif not l_api_parameter.defaultable and
              l_function_parameter.defaultable then
          l_function_parameter.defaultable := false;
        end if;
        --
        -- Check that parameter types match.
        --
        if l_api_parameter.datatype <> l_function_parameter.datatype then
          hr_utility.set_message( 800, 'HR_50320_DP_FUN_ARG_USAGE' );
          hr_utility.set_message_token
          ( 'ARGUMENT', l_api_parameter.parameter_name );
          hr_utility.raise_error;
        end if;
        --
        -- Get the batch lines column from the parameter list.
        --
        if not special_parameter( l_function_parameter.parameter_name ) then
          l_function_parameter.batch_lines_column :=
          l_api_parameter.batch_lines_column;
        end if;
        --
        -- Got a match so exit the loop.
        --
        exit;
      end if;
    end loop;
    --
    -- No match with the API parameters, but parameter name is that of
    -- a special parameter. Check that the parameters are consistent.
    --
    if not l_match and
       special_parameter( l_function_parameter.parameter_name )
    then
      check_special_parameter( l_function_parameter );
    end if;
    --
    -- If no match add to the parameter list. Function parameters (outside of
    -- the API) do not have any seed data. Special parameters are not handled
    -- here because they are not part of the batch lines information.
    --
    if not l_match and
       not special_parameter( l_function_parameter.parameter_name )
    then
      --
      -- Check for long parameters.
      --
      if l_function_parameter.datatype = c_dtype_long then
        p_parameter_counts.long_parameters :=
        p_parameter_counts.long_parameters + 1;
        if p_parameter_counts.long_parameters > 1 then
          hr_utility.set_message( 800, 'HR_50016_DP_TOO_MANY_LONGS' );
          hr_utility.set_message_token
          ( 'API', p_module_package || '.' || p_module_name );
          hr_utility.set_message_token
          ( 'ARGUMENT', l_function_parameter.parameter_name );
          hr_utility.set_message_token
          ( 'FUNCTION', l_function_parameter.mapping_function );
          hr_utility.raise_error;
        end if;
      end if;

      l_total_parameters := p_parameter_counts.total_parameters + 1;
      p_parameter_counts.total_parameters := l_total_parameters;

      --
      -- This is a batch lines parameter, but not an API parameter.
      --
      l_batch_lines_params := p_parameter_counts.batch_lines_parameters + 1;
      p_parameter_counts.batch_lines_parameters := l_batch_lines_params;

      p_parameter_tbl(l_total_parameters).seqno := l_total_parameters;
      p_parameter_tbl(l_total_parameters).api_seqno := null;
      p_parameter_tbl(l_total_parameters).batch_lines_seqno :=
      l_batch_lines_params;
      p_parameter_tbl(l_total_parameters).datatype :=
      l_function_parameter.datatype;
      p_parameter_tbl(l_total_parameters).batch_lines_column :=
      gen_batch_lines_column_name
      (
        p_parameter_tbl(l_total_parameters).batch_lines_seqno,
        p_parameter_tbl(l_total_parameters).datatype
      );
      l_function_parameter.batch_lines_column :=
      p_parameter_tbl(l_total_parameters).batch_lines_column;
      p_parameter_tbl(l_total_parameters).parameter_name :=
      l_function_parameter.parameter_name;
      if upper(p_parameter_tbl(l_total_parameters).parameter_name) like
         '%USER_KEY'
      then
        p_parameter_tbl(l_total_parameters).mapping_type :=
        c_mapping_type_user_key;
        p_parameter_tbl(l_total_parameters).mapping_definition := null;
      else
        p_parameter_tbl(l_total_parameters).mapping_type :=
        c_mapping_type_normal;
        p_parameter_tbl(l_total_parameters).mapping_definition := null;
      end if;
      p_parameter_tbl(l_total_parameters).defaultable :=
      l_function_parameter.defaultable;
      if l_function_parameter.defaultable then
        p_parameter_tbl(l_total_parameters).default_value :=
        get_default_value( p_defaulting_style, l_function_parameter.datatype,
                           p_parameter_tbl(l_total_parameters).mapping_type );
        l_function_parameter.default_value :=
        p_parameter_tbl(l_total_parameters).default_value;
      end if;
      --
      -- Parameter is an in parameter.
      --
      p_parameter_tbl(l_total_parameters).in_out := c_ptype_in;
    end if;
    --
    -- Update the values in the function call list using the current
    -- function parameter.
    --
    if not special_parameter( l_function_parameter.parameter_name ) then
      for j in 1 .. p_parameter_counts.call_parameters loop
        if p_function_call_tbl(j).parameter_name =
          l_function_parameter.parameter_name
        then
          p_function_call_tbl(j).defaultable :=
          l_function_parameter.defaultable;
          p_function_call_tbl(j).batch_lines_column :=
          l_function_parameter.batch_lines_column;
          p_function_call_tbl(j).default_value :=
          l_function_parameter.default_value;
        end if;
      end loop;
    end if;
  end loop;
 exception
 when others then
   -- Remember IN OUT parameters.
   p_parameter_tbl          :=   l_parameter_tbl;
   p_function_tbl           :=   l_function_tbl;
   p_function_call_tbl      :=   l_function_call_tbl;
   p_distinct_parameter_tbl :=   l_distinct_parameter_tbl;
   p_parameter_counts       :=   l_parameter_counts;
   raise;
end merge_function_data;

-- ---------------------- setup_parameter_data ----------------------------
-- Description:
-- Sets up all the parameter data structures for code generation.
-- ------------------------------------------------------------------------
procedure setup_parameter_data
(
  p_module_package    in     varchar2,
  p_module_name       in     varchar2,
  p_parameter_counts  in out nocopy t_parameter_counts,
  p_defaulting_style  in out nocopy number,
  p_parameter_tbl     in out nocopy t_parameter_tbl,
  p_function_tbl      in out nocopy t_function_tbl,
  p_function_call_tbl in out nocopy t_function_parameter_tbl
)
is
  cursor csr_defaulting_style( p_module_name in varchar2 ) is
  select decode( count(0), 0, c_default_hr_api, c_default_null )
  from  hr_pump_default_exceptions hrpde,
        hr_api_modules ham
  where upper(ham.module_package) = upper(p_module_package)
  and   upper(ham.module_name) = upper(p_module_name)
  and   upper(ham.api_module_type) in ('AI', 'BP', 'DM')
  and   upper(hrpde.module_name) = upper(p_module_name)
  and   upper(hrpde.api_module_type) = upper(ham.api_module_type);
  --
  l_seed_parameter_tbl     t_seed_parameter_tbl;
  l_distinct_parameter_tbl t_function_parameter_tbl;
  l_mapping_package_tbl    t_mapping_package_tbl;

  l_parameter_counts  t_parameter_counts;
  l_defaulting_style  number;
  l_parameter_tbl     t_parameter_tbl;
  l_function_tbl      t_function_tbl;
  l_function_call_tbl t_function_parameter_tbl;
  --
begin
-- Remember IN OUT parameters.
  l_parameter_counts    :=   p_parameter_counts;
  l_defaulting_style  	:=   p_defaulting_style;
  l_parameter_tbl     	:=   p_parameter_tbl;
  l_function_tbl      	:=   p_function_tbl;
  l_function_call_tbl 	:=   p_function_call_tbl;


  -- Get the defaulting style.
  if lower(p_module_name) not like 'create%' then
    open csr_defaulting_style( p_module_name );
    fetch csr_defaulting_style into p_defaulting_style;
    close csr_defaulting_style;
  else
    p_defaulting_style := c_default_null;
  end if;

  describe_api( p_module_package, p_module_name, p_parameter_tbl,
                p_parameter_counts );

  --
  -- Original data pump code generation, seed data and mapping functions.
  --
  if hr_pump_meta_mapper.g_standard_generate then
    get_seed_parameters( p_module_package, p_module_name,
                         l_seed_parameter_tbl,
                         p_parameter_counts.seed_parameters );

    merge_api_and_seed_data( p_defaulting_style, p_parameter_tbl,
                             l_seed_parameter_tbl, p_function_tbl,
                             p_parameter_counts );
    l_seed_parameter_tbl.delete;

    get_mapping_packages
    (p_module_package      => p_module_package
    ,p_module_name         => p_module_name
    ,p_mapping_package_tbl => l_mapping_package_tbl
    );

    merge_function_data( p_module_package, p_module_name,
                         p_defaulting_style, l_mapping_package_tbl,
                         p_parameter_tbl, p_function_tbl,
                         p_function_call_tbl, l_distinct_parameter_tbl,
                         p_parameter_counts );
    l_mapping_package_tbl.delete;
    l_distinct_parameter_tbl.delete;
  ----------------------------------------------------------------------
  -- Bare bones wrapper generation. No seed data and basic defaulting --
  -- rules.                                                           --
  ----------------------------------------------------------------------
  else
    --
    -- Zero the parameter counts.
    --
    p_parameter_counts.batch_lines_parameters := 0;
    p_parameter_counts.seed_parameters  := 0;
    p_parameter_counts.functions := 0;
    p_parameter_counts.distinct_parameters := 0;
    p_parameter_counts.call_parameters := 0;
    --
    -- Set up the default values, mapping types, and batch lines
    -- sequences for the API parameters.
    --
    for i in 1 .. p_parameter_counts.total_parameters loop
      if p_parameter_tbl(i).defaultable then
        p_parameter_tbl(i).default_value :=
        get_default_value
        (p_defaulting_style => p_defaulting_style
        ,p_datatype         => p_parameter_tbl(i).datatype
        ,p_mapping_type     => p_parameter_tbl(i).mapping_type
        );
      end if;
      --
      -- Set up batch lines column information for the parameter.
      --
      if not special_parameter(p_parameter_tbl(i).parameter_name) then
        p_parameter_counts.batch_lines_parameters :=
        p_parameter_counts.batch_lines_parameters + 1;
        p_parameter_tbl(i).batch_lines_seqno :=
        p_parameter_counts.batch_lines_parameters;
        p_parameter_tbl(i).batch_lines_column :=
        gen_batch_lines_column_name
        (
          p_parameter_tbl(i).batch_lines_seqno,
          p_parameter_tbl(i).datatype
        );
      else
        p_parameter_tbl(i).batch_lines_seqno := null;
      end if;
      --
      p_parameter_tbl(i).mapping_type := c_mapping_type_normal;
    end loop;
  end if;
  --
  -- Set up the call default parameters.
  --
  for i in 1 .. p_parameter_counts.total_parameters loop
    if p_parameter_tbl(i).defaultable then
      p_parameter_tbl(i).call_default_value :=
      get_call_default_value(p_parameter_tbl(i).default_value,
                             p_parameter_tbl(i).datatype,
                             p_parameter_tbl(i).mapping_type );
    end if;
  end loop;

  if p_parameter_counts.batch_lines_parameters > c_max_batch_lines_cols then
    hr_utility.set_message( 800, 'HR_50321_DP_TOO_MANY_ARGS' );
    hr_utility.set_message_token
    ( 'TOTAL', p_parameter_counts.batch_lines_parameters );
    hr_utility.set_message_token( 'MAXIMUM', c_max_batch_lines_cols );
    hr_utility.raise_error;
  end if;

exception
  when others then
-- Reset IN OUT parameters.
  p_parameter_counts     :=   l_parameter_counts;
  p_defaulting_style  	:=   l_defaulting_style;
  p_parameter_tbl     	:=   l_parameter_tbl;
  p_function_tbl      	:=   l_function_tbl;
  p_function_call_tbl 	:=   l_function_call_tbl;
    if csr_defaulting_style%isopen then
      close csr_defaulting_style;
    end if;
    raise;
end setup_parameter_data;

-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed.
-- ------------------------------------------------------------------------
procedure run_sql( p_sql in varchar2 )
is
  l_csr_sql integer;
  l_rows    number;
begin
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, p_sql, dbms_sql.native );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
exception
  when others then
    raise;
end run_sql;

-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Alternative interface for generating the large PLSQL packages.
-- Table index must begin at 1.
-- ------------------------------------------------------------------------
procedure run_sql( p_sql in dbms_sql.varchar2s )
is
  l_csr_sql integer;
  l_rows    number;
begin
  l_csr_sql := dbms_sql.open_cursor;
  --
  -- Do the parse without inserting linefeeds between each element.
  --
  dbms_sql.parse( l_csr_sql, p_sql, 1, p_sql.count, false, dbms_sql.native );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
exception
  when others then
    raise;
end run_sql;

-- ---------------------------- split_sql_text ---------------------------
-- Description
-- Procedure to split the package body into chunks to allow longer
-- generated packages.
-- -----------------------------------------------------------------------
procedure split_sql_text
(p_last        in            boolean
,p_text        in out nocopy varchar2
,p_text_pieces in out nocopy dbms_sql.varchar2s

) is
l_start  binary_integer;
j        binary_integer;
l_blen   number;
l_pieces number;
begin
  if p_text is null then
    return;
  end if;
  --
  l_pieces := lengthb(p_text) / 256;
  if p_last then
    if ceil(l_pieces) <> floor(l_pieces) then
      l_pieces := ceil(l_pieces);
    end if;
  else
    l_pieces := floor(l_pieces);
  end if;
  --
  l_start := p_text_pieces.count;
  j := 1;
  for i in 1 .. l_pieces loop
    p_text_pieces(i + l_start) := substr(p_text, j, 256);
    j := j + 256;
  end loop;
  --
  if not p_last then
    p_text := substr(p_text, j);
  else
    p_text := null;
  end if;
end split_sql_text;

---------------------------------------------------------------------------
--                      CODE GENERATION PROCEDURES                       --
---------------------------------------------------------------------------
-- ------------------------ check_compile ---------------------------------
-- Description:
-- Checks whether or not the generated package or view compiled okay.
-- ------------------------------------------------------------------------
procedure check_compile
(
  p_object_name in varchar2,
  p_object_type in varchar2
)
is
  cursor csr_check_compile
  (
    p_object_name in varchar2,
    p_object_type in varchar2
  ) is
  select status
  from   user_objects
  where  upper(object_name) = upper(p_object_name)
  and    upper(object_type) = upper(p_object_type);
  l_status varchar2(64);
begin
  open csr_check_compile( p_object_name, p_object_type );
  fetch csr_check_compile into l_status;
  close csr_check_compile;
  if upper( l_status ) <> 'VALID' then
    hr_utility.set_message( 800, 'HR_50322_DP_COMPILE_FAILED' );
    hr_utility.set_message_token( 'OBJECT', p_object_name );
    hr_utility.raise_error;
  end if;
end check_compile;

-- ------------------------ create_view -----------------------------------
-- Description:
-- Generates and executes the SQL for creating the view.
-- ------------------------------------------------------------------------
procedure create_view
(
  p_view_name        in varchar2,
  p_parameter_tbl    in t_parameter_tbl,
  p_parameter_counts in t_parameter_counts,
  p_api_module_id    in number
)
is
  l_create_statement varchar2(32767);
begin
  l_create_statement :=
  'create or replace force view ' || p_view_name || ' as' || c_newline ||
  'select ';
  --
  -- Add the common parameters.
  --
  l_create_statement := l_create_statement ||
         'batch_id            batch_id'            || c_newline ||
  ',      batch_line_id       batch_line_id'       || c_newline ||
  ',      api_module_id       api_module_id'       || c_newline ||
  ',      line_status         line_status'         || c_newline ||
  ',      user_sequence       user_sequence'       || c_newline ||
  ',      link_value          link_value'          || c_newline ||
  ',      business_group_name business_group_name'
  ;
  --
  -- Add the rest the batch lines parameters.
  --
  for i in 1 .. p_parameter_counts.total_parameters loop
    if p_parameter_tbl(i).batch_lines_seqno is not null then
      l_create_statement := l_create_statement ||
                            ',' || c_newline || '       ' ||
                            p_parameter_tbl(i).batch_lines_column || ' ' ||
                            p_parameter_tbl(i).parameter_name;
    end if;
  end loop;
  --
  -- Terminate the create statement. Use a check option constraint so
  -- that the view may not be used to create/update any rows so that
  -- it cannot select the created/updated row.
  --
  l_create_statement :=
  l_create_statement                          || c_newline ||
  'from hr_pump_batch_lines'                  || c_newline ||
  'where api_module_id = ' || p_api_module_id || c_newline ||
  'with check option constraint HRDPV_CONS_'  || p_api_module_id;
  --
  -- Create the view!
  --
  run_sql( l_create_statement );
  check_compile( p_view_name, 'VIEW' );
end create_view;

-- ----------------------- gen_local_variable -----------------------------
-- Description:
-- For parameter p_xxxx, generates the name l_xxxx.
-- ------------------------------------------------------------------------
function gen_local_variable( p_parameter_name in varchar2 )
return varchar2 is
  l_local_variable varchar2(30);
begin
  l_local_variable := 'L_' || substr( p_parameter_name, 3 );
  return l_local_variable;
end gen_local_variable;

-- ----------------------- generate_insert --------------------------------
-- Description:
-- Generates the insert procedure.
-- ------------------------------------------------------------------------
procedure generate_insert
(
  p_api_module_id    in     number,
  p_parameter_tbl    in     t_parameter_tbl,
  p_parameter_counts in     t_parameter_counts,
  p_header           in out nocopy varchar2,
  p_body             in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_insert_part1 varchar2(32767);
  l_insert_part2 varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_pre_insert   varchar2(32767) := null;
  l_local_var    varchar2(30);
  l_indicator    varchar2(30);
begin
  l_locals := c_newline || 'blid number := p_data_pump_batch_line_id;';
  --
  l_interface :=  c_newline ||
  '(p_batch_id      in number'                || c_newline ||
  ',p_data_pump_batch_line_id in number default null'   || c_newline ||
  ',p_data_pump_business_grp_name in varchar2 default null' || c_newline ||
  ',p_user_sequence in number default null'   || c_newline ||
  ',p_link_value    in number default null';
  --
  l_insert_part1 := c_newline ||
  'if blid is not null then' || c_newline ||
  'delete from hr_pump_batch_lines where batch_line_id = blid;' ||
  c_newline || 'delete from hr_pump_batch_exceptions' ||
  c_newline || 'where source_type = ''BATCH_LINE'' and source_id = blid;' ||
  c_newline || 'end if;'
  || c_newline ||
  'insert into hr_pump_batch_lines' || c_newline ||
  '(batch_id'                       || c_newline ||
  ',batch_line_id'                  || c_newline ||
  ',business_group_name'            || c_newline ||
  ',api_module_id'                  || c_newline ||
  ',line_status'                    || c_newline ||
  ',user_sequence'                  || c_newline ||
  ',link_value';
  --
  l_insert_part2 := 'values'        || c_newline ||
  '(p_batch_id'                     || c_newline ||
  ',nvl(blid,hr_pump_batch_lines_s.nextval)'  || c_newline ||
  ',p_data_pump_business_grp_name'  || c_newline ||
  ',' || to_char(p_api_module_id)   || c_newline ||
  ',''U'''                          || c_newline ||
  ',p_user_sequence'                || c_newline ||
  ',p_link_value';
  --
  for i in 1 .. p_parameter_counts.total_parameters loop
    l_indicator := null;
    --
    -- Only interested in batch lines parameters, and parameters that
    -- are in and in/out.
    --
    if p_parameter_tbl(i).batch_lines_seqno is not null and
       (p_parameter_tbl(i).in_out <> c_ptype_out or
        p_parameter_tbl(i).mapping_type = c_mapping_type_user_key )
    then
      --
      -- All parameters are in parameters.
      --
      l_interface :=
      l_interface || c_newline || ',' ||
      p_parameter_tbl(i).parameter_name || ' in ';
      --
      -- user_key parameters must be varchar2.
      --
      if p_parameter_tbl(i).mapping_type = c_mapping_type_user_key then
        l_interface := l_interface || 'varchar2';
      else
        l_interface :=
        l_interface || g_tbl_datatype( p_parameter_tbl(i).datatype );
      end if;
      --
      -- Default defaultable parameters to null so that they may be
      -- defaulted in the API call wrapper.
      --
      if p_parameter_tbl(i).defaultable then
        l_interface := l_interface || ' default null';
      end if;
      --
      -- Non-user-key, defaultable  NUMBER/DATE parameters need an
      -- indicator variable as the '<NULL>' default value is not a
      -- valid NUMBER/DATE. This is only necessary if the default value
      -- is NOT NULL.
      --
      if p_parameter_tbl(i).mapping_type <> c_mapping_type_user_key and
         p_parameter_tbl(i).defaultable and
         not default_is_null(p_parameter_tbl(i).default_value) and
         (p_parameter_tbl(i).datatype = c_dtype_number or
          p_parameter_tbl(i).datatype = c_dtype_date) then
        l_indicator := 'I' || substr(p_parameter_tbl(i).parameter_name, 2);
        l_interface :=
        l_interface || c_newline || ',' || l_indicator ||
        ' in varchar2 default ''N''';
      end if;
      --
      l_insert_part1 :=
      l_insert_part1 || c_newline || ',' ||
      p_parameter_tbl(i).batch_lines_column;
      --
      l_insert_part2 :=
      l_insert_part2 || c_newline || ',';
      --
      -- If there is an indicator and the parameter is of type DATE then
      -- call the Date Decode function.
      --
      if l_indicator is not null and
         p_parameter_tbl(i).datatype = c_dtype_date then
        l_insert_part2 :=
        l_insert_part2 || 'dd(' || p_parameter_tbl(i).parameter_name ||
        ',' || l_indicator || ')';
      --
      -- Put in a to_char date format conversion for date parameters.
      --
      elsif p_parameter_tbl(i).datatype = c_dtype_date then
        l_insert_part2 :=
        l_insert_part2 || 'dc(' || p_parameter_tbl(i).parameter_name || ')';
      --
      -- Need to have local variables for boolean->string conversion for
      -- boolean parameters.
      --
      elsif p_parameter_tbl(i).datatype = c_dtype_boolean then
        l_local_var := gen_local_variable( p_parameter_tbl(i).parameter_name );
        l_locals :=
        l_locals || c_newline || ' ' || l_local_var || ' varchar2(5);';
        --
        l_pre_insert :=
        l_pre_insert || c_newline ||
        'if ' || p_parameter_tbl(i).parameter_name || ' is null then' ||
        c_newline ||
        ' ' || l_local_var || ' := null;' || c_newline ||
        'elsif ' || p_parameter_tbl(i).parameter_name || ' then' ||
        c_newline ||
        ' ' || l_local_var || ' := ''TRUE'';' || c_newline ||
        'else ' || c_newline ||
        ' ' || l_local_var || ' := ''FALSE'';' || c_newline ||
        'end if;';
        --
        l_insert_part2 := l_insert_part2 || l_local_var;
      --
      -- If there is an indicator and the parameter is of type NUMBER then
      -- call the Number Decode function.
      --
      elsif l_indicator is not null and
            p_parameter_tbl(i).datatype = c_dtype_number then
        l_insert_part2 :=
        l_insert_part2 || 'nd(' || p_parameter_tbl(i).parameter_name ||
        ',' || l_indicator || ')';
      else
        l_insert_part2 := l_insert_part2 || p_parameter_tbl(i).parameter_name;
      end if;
    end if;
  end loop;
  l_interface := l_interface || ')';
  l_insert_part1 := l_insert_part1 || ')' || c_newline;
  l_insert_part2 := l_insert_part2 || ');' || c_newline;
  --
  p_header := p_header || 'procedure insert_batch_lines' || l_interface || ';';
  p_body :=
  p_body || 'procedure insert_batch_lines' || l_interface || ' is';
  if l_locals is not null then
    p_body := p_body || l_locals;
  end if;
  p_body :=
  p_body || c_newline || 'begin';
  if l_pre_insert is not null then
    p_body := p_body || l_pre_insert;
  end if;
  p_body :=
  p_body || l_insert_part1 || l_insert_part2 || 'end insert_batch_lines;';
end generate_insert;

-- ------------------------- gen_hr_api_vars ------------------------------
-- Description:
-- Generates code for global variables to hold values for hr_api.g_date,
-- hr_api.g_number, and hr_api.g_varchar2. This is to save space in the call
-- procedure.
-- ------------------------------------------------------------------------
procedure gen_hr_api_vars
(p_body in out nocopy varchar2
) is
begin
  p_body := p_body ||
  'dh constant date := hr_api.g_date;'             || c_newline ||
  'nh constant number := hr_api.g_number;'         || c_newline ||
  'vh constant varchar2(64) := hr_api.g_varchar2;' || c_newline;
end gen_hr_api_vars;

-- ------------------------- gen_null_vars -------------------------------
-- Description:
-- Generates code for global variables to hold values for to_date(null),
-- to_number(null), and to_char(null). This is to save space in the call
-- procedure.
-- ------------------------------------------------------------------------
procedure gen_null_vars
(p_body in out nocopy varchar2
) is
begin
  p_body := p_body ||
  'c_sot constant date := to_date(''01010001'',''DDMMYYYY'');' ||
  c_newline ||
  'cn constant varchar2(32) := ''<NULL>'';' || c_newline ||
  'dn constant date := null;'               || c_newline ||
  'nn constant number := null;'             || c_newline ||
  'vn constant varchar2(1) := null;';
end gen_null_vars;
-- ------------------------- gen_to_calls ----------------------------------
-- Description:
-- Generates code for the to_date and to_number replacement functions (to
-- save code space).
-- Added function to do the to_char conversion for date also.
-- ------------------------------------------------------------------------
procedure gen_to_calls
( p_body in out nocopy varchar2, p_header in out nocopy varchar2 )
is
begin
  p_body :=
  p_body ||
  'function dc(p in date) return varchar2 is'       || c_newline ||
  'begin'                                           || c_newline ||
  'if p<c_sot then'                                 || c_newline ||
  ' if p<>trunc(p) then'                            || c_newline ||
  '  return to_char(p,'''|| c_date_format3|| ''');' || c_newline ||
  ' end if;'                                        || c_newline ||
  ' return to_char(p,''' || c_date_format2|| ''');' || c_newline ||
  'elsif p<>trunc(p) then'                          || c_newline ||
  ' return to_char(p,'''|| c_date_format1|| ''');'  || c_newline ||
  'end if;'                                         || c_newline ||
  'return to_char(p,''' || c_date_format|| ''');'   || c_newline ||
  'end dc;'                                         || c_newline;
  p_body :=
  p_body ||
  'function d(p in varchar2) return date is'        || c_newline ||
  'begin'                                           || c_newline ||
  'if length(p)='||c_date_format_len||' then'       || c_newline ||
  'return to_date(p,''' || c_date_format || ''');'  || c_newline ||
  'elsif length(p)='||c_date_format1_len||' then'   || c_newline ||
  'return to_date(p,''' || c_date_format1 || ''');' || c_newline ||
  'elsif length(p)=' ||c_date_format2_len|| ' then' || c_newline ||
  'return to_date(p,''' || c_date_format2 || ''');' || c_newline ||
  'elsif length(p)=' ||c_date_format3_len|| ' then' || c_newline ||
  'return to_date(p,''' || c_date_format3 || ''');' || c_newline ||
  'end if;'                                         || c_newline ||
  '-- Try default format as last resort.'           || c_newline ||
  'return to_date(p,''' || c_date_format || ''');'  || c_newline ||
  'end d;'                                          || c_newline;
  p_body :=
  p_body ||
  'function n(p in varchar2) return number is'      || c_newline ||
  'begin'                                           || c_newline ||
  'return to_number(p);'                            || c_newline ||
  'end n;'                                          || c_newline;
  p_body :=
  p_body ||
  'function dd(p in date,i in varchar2)'            || c_newline ||
  'return varchar2 is'                              || c_newline ||
  'begin'                                           || c_newline ||
  'if upper(i) = ''N'' then return dc(p);'          || c_newline ||
  'else return cn; end if;'                         || c_newline ||
  'end dd;'                                         || c_newline;
  p_body :=
  p_body ||
  'function nd(p in number,i in varchar2)'          || c_newline ||
  'return varchar2 is'                              || c_newline ||
  'begin'                                           || c_newline ||
  'if upper(i) = ''N'' then return to_char(p);'     || c_newline ||
  'else return cn; end if;'                         || c_newline ||
  'end nd;';
  --
  -- Wanted to avoid putting this in the header, but the pragma requires
  -- that this is the case. Strictly, not necessarily for 8i onwards,
  -- but do in case of backport to R11.
  --
  p_header :=
  p_header || c_newline ||
  'function dc(p in date) return varchar2;'         || c_newline ||
  'pragma restrict_references(dc,WNDS);'            || c_newline;
  p_header :=
  p_header || c_newline ||
  'function d(p in varchar2) return date;'          || c_newline ||
  'pragma restrict_references(d,WNDS);'             || c_newline;
  p_header :=
  p_header ||
  'function n(p in varchar2) return number;'        || c_newline ||
  'pragma restrict_references(n,WNDS);'             || c_newline;
  p_header :=
  p_header ||
  'function dd(p in date,i in varchar2) return varchar2;' || c_newline ||
  'pragma restrict_references(dd,WNDS);'                  || c_newline;
  p_header :=
  p_header ||
  'function nd(p in number,i in varchar2) return varchar2;' || c_newline ||
  'pragma restrict_references(nd,WNDS);';
end gen_to_calls;

-- ----------------------- gen_ins_user_key -------------------------------
-- Description:
-- Generates code for the ins_user_key procedure.
-- ------------------------------------------------------------------------
procedure gen_ins_user_key( p_body in out nocopy varchar2 )
is
begin
  p_body :=
  p_body ||
  'procedure iuk'                             || c_newline ||
  '(p_batch_line_id  in number,'              || c_newline ||
  'p_user_key_value in varchar2,'             || c_newline ||
  'p_unique_key_id  in number)'               || c_newline ||
  'is'                                        || c_newline ||
  'begin'                                     || c_newline ||
  'hr_data_pump.entry(''ins_user_key'');'     || c_newline ||
  'insert into hr_pump_batch_line_user_keys'  || c_newline ||
  '(user_key_id, batch_line_id,user_key_value,unique_key_id)' ||
  c_newline ||
  'values' || c_newline ||
  '(hr_pump_batch_line_user_keys_s.nextval,' || c_newline ||
  'p_batch_line_id,'                         || c_newline ||
  'p_user_key_value,'                        || c_newline ||
  'p_unique_key_id);'                        || c_newline ||
  'hr_data_pump.exit(''ins_user_key'');'     || c_newline ||
  'end iuk;';
end gen_ins_user_key;

-- ------------------------- gen_cursor_field -----------------------------
-- Description:
-- For parameter p_xxxx, generates the field in the cursor record.
-- ------------------------------------------------------------------------
function gen_cursor_field
(p_parameter_name in varchar2
,p_prefix         in boolean default true
)
return varchar2 is
  l_name         varchar2(64);
begin
  --
  -- Shorten the name of the cursor fields.
  --
  l_name := replace(p_parameter_name, c_parameter_value_col,
                    c_cursor_value_col);
  --
  -- Get rid of numbers prefixed by 0 or 00.
  --
  l_name := replace(l_name, c_cursor_value_col || '00', c_cursor_value_col);
  l_name := replace(l_name, c_cursor_value_col || '0', c_cursor_value_col);
  --
  -- Add any necessary prefix.
  --
  if p_prefix then
    l_name := 'c.' || l_name;
  end if;
  return l_name;
end gen_cursor_field;

-- ---------------------------- add_to_locals -----------------------------
-- Description:
-- If required, generate a local variable for a parameter and add it to
-- the local variable text. Overloaded for parameters with 'FUNCTION'
-- mapping type.
-- ------------------------------------------------------------------------
procedure add_to_locals
(
  p_locals         in out nocopy varchar2,
  p_parameter      in     t_parameter,
  p_local_variable in out nocopy varchar2
)
is
begin
  --
  -- Boolean parameters need a local variable so that a string conversion
  -- may be performed pre-call or post-call.
  --
  if p_parameter.datatype = c_dtype_boolean    and
     p_parameter.batch_lines_seqno is not null and
     not special_parameter( p_parameter.parameter_name )
  then
    p_local_variable := gen_local_variable( p_parameter.parameter_name );
    p_locals := p_locals || c_newline || p_local_variable ||
                ' boolean;';
    return;
  end if;
  --
  -- For API out parameters that are user_key-mapped a local variable is
  -- required so that the user_key may be inserted into
  -- hr_pump_batch_line_user_keys.
  --
  if p_parameter.mapping_type = c_mapping_type_user_key and
     p_parameter.api_seqno is not null and
     (p_parameter.in_out = c_ptype_out or p_parameter.in_out = c_ptype_in_out)
  then
    p_local_variable := gen_local_variable( p_parameter.mapping_definition );
    p_locals := p_locals || c_newline || p_local_variable || ' ' ||
                g_tbl_datatype(p_parameter.datatype) || ';';
    return;
  end if;
  --
  -- For long parameters a local variable is required to check for the
  -- string '<NULL>', and to pass results back (to allow common code for
  -- in, in/out, and out parameters).
  --
  if p_parameter.datatype = c_dtype_long and
     p_parameter.batch_lines_seqno is not null
  then
    p_local_variable := gen_local_variable( p_parameter.parameter_name );
    p_locals :=
    p_locals || c_newline || p_local_variable || ' varchar2(32767);';
  end if;
end add_to_locals;
--
procedure add_to_locals
(
  p_locals         in out nocopy varchar2,
  p_function       in     t_function,
  p_parameter_tbl in     t_parameter_tbl,
  p_local_variable in out nocopy varchar2
)
is
  l_parameter t_parameter;
  l_seqno     number;
  l_datatype  number;
begin
  --
  -- Derive local variable name from the name of the parameter for which
  -- the mapping function exists. The parameter type is the return type of
  -- the function.
  --
  l_seqno := p_function.seqno;
  l_datatype := p_function.ret_type;
  l_parameter := p_parameter_tbl(l_seqno);
  p_local_variable := gen_local_variable( l_parameter.parameter_name );
  p_locals := p_locals || c_newline || p_local_variable || ' ';
  if l_parameter.datatype = c_dtype_varchar2 then
    p_locals := p_locals || 'varchar2(2000);';
  else
    p_locals := p_locals || g_tbl_datatype(l_datatype) || ';';
  end if;
end add_to_locals;

-- -------------------------- add_to_precall ------------------------------
-- Description:
-- Adds any code that needs to be executed before the API is called.
-- Overloaded versions for ordinary parameters and parameters with
-- 'FUNCTION' mapping type.
-- ------------------------------------------------------------------------
procedure add_to_precall
(
  p_precall        in out nocopy varchar2,
  p_parameter      in     t_parameter,
  p_local_variable in     varchar2
)
is
  l_cursor_field varchar2(64);
begin
  --
  -- For long in parameters, check for '<NULL>'.
  --
  if p_parameter.datatype = c_dtype_long and
     p_parameter.batch_lines_seqno is not null and
     ( p_parameter.in_out = c_ptype_in or p_parameter.in_out = c_ptype_in_out )
  then
    --
    -- The local varchar2 variable is set using the long parameter value.
    --
    l_cursor_field := gen_cursor_field( p_parameter.batch_lines_column );
    p_precall :=
    p_precall || c_newline || '--' || c_newline ||
    p_local_variable || ' := ' || l_cursor_field || ';' || c_newline;
    --
    -- For a defaultable parameter, the code needs to check for a null
    -- value and set the default accordingly.
    --
    if p_parameter.defaultable and
       not default_is_null(p_parameter.default_value)
    then
      p_precall :=
      p_precall ||
      'if ' || p_local_variable || ' is null then' || c_newline ||
      p_local_variable || ' := ' || p_parameter.call_default_value || ';' ||
      c_newline || 'elsif ';
    else
      p_precall := p_precall || 'if ';
    end if;
    --
    -- If the local variable has the value '<NULL>' then it is set to null.
    --
    p_precall :=
    p_precall || p_local_variable || ' = cn then' || c_newline ||
    p_local_variable || ' := null;' || c_newline || 'end if;';
  end if;
  --
  -- For boolean parameters need to convert local variable.
  --
  if p_parameter.datatype = c_dtype_boolean and
     p_parameter.batch_lines_seqno is not null and
     not special_parameter( p_parameter.parameter_name ) and
     ( p_parameter.in_out = c_ptype_in or p_parameter.in_out = c_ptype_in_out )
  then
    l_cursor_field := gen_cursor_field( p_parameter.batch_lines_column );
    p_precall :=
    p_precall || c_newline || '--' || c_newline ||
    'if upper(' || l_cursor_field || ') = ''TRUE'' then' ||
    c_newline || p_local_variable || ' := true;' || c_newline ||
    'elsif upper(' || l_cursor_field || ') = ''FALSE'' then' ||
    c_newline || p_local_variable || ' := false;' || c_newline;
    if p_parameter.defaultable and
       not default_is_null(p_parameter.default_value)
    then
      p_precall := p_precall ||
      'elsif ' || gen_def_check_name(l_cursor_field) || ' is not null then' ||
      c_newline;
    elsif p_parameter.defaultable then
      p_precall := p_precall ||
      'elsif ' || l_cursor_field || ' is not null then' || c_newline;
    else
      p_precall := p_precall || 'else' || c_newline;
    end if;
    p_precall := p_precall ||
    'hr_utility.set_message(800,''HR_50327_DP_TYPE_ERR'');'   || c_newline ||
    'hr_utility.set_message_token(''TYPE'',''BOOLEAN'');' || c_newline ||
    'hr_utility.set_message_token(''PARAMETER'',''' ||
    p_parameter.parameter_name || ''');' || c_newline ||
    'hr_utility.set_message_token(''VALUE'',' || l_cursor_field ||
    ');' || c_newline ||
    'hr_utility.set_message_token(''TABLE'',''HR_PUMP_BATCH_LINES'');' ||
    c_newline ||
    'hr_utility.raise_error;' || c_newline ||
    'end if;';
    return;
  end if;
end add_to_precall;
--
procedure add_to_precall
(
  p_precall            in out nocopy varchar2,
  p_parameter          in     t_parameter,
  p_function           in     t_function,
  p_function_call_tbl  in     t_function_parameter_tbl,
  p_local_variable     in     varchar2
)
is
--
-- Function call parameter.
--
l_call_param     t_function_parameter;
--
-- Function call statement.
--
l_function_call   varchar2(32767);
--
-- Parameter name to be used in function call.
--
l_param_call_name varchar2(64);
--
-- Parameter name to be used in checking code.
--
l_param_chk_name  varchar2(64);
--
-- Checking statement to set mapped value to NULL.
--
l_null_check      varchar2(32767) := null;
--
-- Checking statement to set the mapped value to its default.
--
l_def_check       varchar2(32767) := null;
--
-- Procedure to add to one of the checking if-statements that handle
-- NULL or defaulted mapping function parameters.
--
procedure add2chklist
(p_chk_name   in            varchar2
,p_is_null    in            boolean
,p_check_list in out nocopy varchar2
) is
begin
  --
  -- Handle case of NOT NULL check list, each check is add as an
  -- OR-condition to an existing statement.
  --
  if not p_check_list is null then
    p_check_list := p_check_list || ' or' || c_newline;
  end if;
  --
  -- Decide whether to add '<name> is null' or '<name>=cn' to
  -- the list (cn is the special string <NULL>).
  --
  if p_is_null then
    p_check_list := p_check_list || p_chk_name || ' is null';
  else
    p_check_list := p_check_list || p_chk_name || '=cn';
  end if;
end add2chklist;
--
begin
  --
  p_precall := p_precall || c_newline || '--' || c_newline;
  --------------------------------------
  -- Mapping function has parameters. --
  --------------------------------------
  if p_function.index1 is not null then
    --
    -- Build up parameter list for function.
    --
    l_function_call :=
    p_local_variable || ' := ' || c_newline ||
    p_function.package_name || '.' || p_function.function_name ||
    c_newline || '(';
    --
    -- Build up parameter check code.
    --
    for i in p_function.index1 .. p_function.index2 loop
      l_call_param := p_function_call_tbl(i);
      --
      -- Only add comma argument separator if this is the second or a later
      -- parameter in the function call.
      --
      if i <> p_function.index1 then
        l_function_call := l_function_call || c_newline || ',';
      end if;
      --
      -- Function parameters come from the batch lines table, therefore
      -- they are accessed from the c cursor.
      --
      if l_call_param.parameter_name = 'P_BUSINESS_GROUP_ID' then
        l_param_call_name := 'P_BUSINESS_GROUP_ID';
      elsif l_call_param.parameter_name = 'P_DATA_PUMP_ALWAYS_CALL'
      then
        --
        -- P_DATA_PUMP_ALWAYS_CALL is a dummy parameter, so just pass in
        -- NULL for it.
        --
        l_param_call_name := 'null';
      else
        l_param_call_name :=
        gen_cursor_field( l_call_param.batch_lines_column );
      end if;
      l_function_call :=
      l_function_call || l_call_param.function_parameter || ' => ' ||
      l_param_call_name;

      --
      -- Perform checks for NULL and HR_API defaulted parameters if
      -- ALWAYS_CALL is false. The checks prevent the function being called
      -- if a parameter is NULL or HR_API defaulted.
      --
      -- The P_BUSINESS_GROUP_ID parameter is exempted from these checks.
      --
      -- Where the user has supplied the value <NULL> for a mapping
      -- function parameter, then the mapped parameter is set to NULL.
      -- Where the user has supplied a default value of NULL or an HR_API
      -- default, the mapped parameter is set to its default value (or
      -- NULL if it does not have a default).
      ---------------------------------------------------------------------
      -- DO NOT ALTER THE FOLLOWING CODE UNLESS YOU FULLY UNDERSTAND HOW --
      -- THE MAPPER CODE WORKS.                                          --
      ---------------------------------------------------------------------
      if not p_function.always_call and
         l_param_call_name <> 'P_BUSINESS_GROUP_ID' then
        -------------------------------------------------------------------
        -- Case 1: The parameter being mapped is not defaultable, or the --
        -- parameter being mapped has a default of NULL.                 --
        -------------------------------------------------------------------
        if not p_parameter.defaultable or
           (p_parameter.defaultable and
            default_is_null(p_parameter.default_value)) then
          ----------------------------------------
          -- 1.1 Call parameter is defaultable. --
          ----------------------------------------
          if l_call_param.defaultable then
            --
            -- 1.1.1 NULL default.
            --
            if default_is_null(l_call_param.default_value) then
              add2chklist
              (p_chk_name   => l_param_call_name
              ,p_is_null    => true
              ,p_check_list => l_null_check
              );
            --
            -- 1.1.2 HR_API default.
            --
            elsif default_is_hr_api(l_call_param.default_value) then
              l_param_chk_name := gen_def_check_name(l_param_call_name);
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => true
              ,p_check_list => l_null_check
              );
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => false
              ,p_check_list => l_null_check
              );
            --
            -- 1.1.3 Other default value. The default value can be
            -- passed to the mapping function.
            --
            else
              add2chklist
              (p_chk_name   => gen_def_check_name(l_param_call_name)
              ,p_is_null    => false
              ,p_check_list => l_null_check
              );
            end if;
          --------------------------------------------
          -- 1.2 Call parameter is not defaultable. --
          --------------------------------------------
          else
            add2chklist
            (p_chk_name   => l_param_call_name
            ,p_is_null    => true
            ,p_check_list => l_null_check
            );
          end if;
        ------------------------------------------------------------------
        -- Case 2: The parameter being mapped is defaultable and has a  --
        -- NOT NULL default value.                                      --
        ------------------------------------------------------------------
        else
          ----------------------------------------
          -- 2.1 Call parameter is defaultable. --
          ----------------------------------------
          if l_call_param.defaultable then
            --
            -- 2.1.1 NULL default.
            --
            if default_is_null(l_call_param.default_value) then
              l_param_chk_name := gen_def_check_name(l_param_call_name);
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => false
              ,p_check_list => l_null_check
              );
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => true
              ,p_check_list => l_def_check
              );
            --
            -- 2.1.2 HR_API default.
            --
            elsif default_is_hr_api(l_call_param.default_value) then
              l_param_chk_name := gen_def_check_name(l_param_call_name);
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => false
              ,p_check_list => l_null_check
              );
              add2chklist
              (p_chk_name   => l_param_chk_name
              ,p_is_null    => true
              ,p_check_list => l_def_check
              );
            --
            -- 2.1.3 Other default value. The default value
            -- can be passed to the mapping function.
            --
            else
              add2chklist
              (p_chk_name   => gen_def_check_name(l_param_call_name)
              ,p_is_null    => false
              ,p_check_list => l_null_check
              );
            end if;
          --------------------------------------------
          -- 2.2 Call parameter is not defaultable. --
          --------------------------------------------
          else
            add2chklist
            (p_chk_name   => l_param_call_name
            ,p_is_null    => true
            ,p_check_list => l_null_check
            );
          end if;
        end if;
      end if;
    end loop;
    --
    -- Terminate the function call.
    --
    l_function_call := l_function_call || ');';
    ---------------------------------------------
    -- Add the parameter checks, if necessary. --
    ---------------------------------------------
    if l_null_check is not null or l_def_check is not null then
      --
      -- NULL check comes first.
      --
      if l_null_check is not null then
        p_precall := p_precall ||
        'if ' || l_null_check || ' then' || c_newline ||
        p_local_variable || ':=' ||
        g_tbl_call_default_null(p_parameter.datatype) || ';' || c_newline;
      end if;
      --
      -- Handle default value check.
      --
      if l_def_check is not null then
        if l_null_check is null then
          l_def_check := 'if '  || l_def_check;
        else
          l_def_check := 'elsif ' || l_def_check;
        end if;
        p_precall := p_precall ||
        l_def_check || ' then ' || c_newline ||
        p_local_variable || ':=' || p_parameter.call_default_value || ';'
        || c_newline;
      end if;
      --
      -- Need ELSE-part for the function call to go into.
      --
      p_precall := p_precall || 'else' || c_newline;
    end if;
    --
    -- Add the function call to the precall text.
    --
    p_precall := p_precall || l_function_call;
    --
    -- Terminate the precall text by ending the parameter check.
    --
    if l_null_check is not null or l_def_check is not null then
      p_precall := p_precall || c_newline || 'end if;';
    end if;
  -----------------------------------------
  -- Mapping function has no parameters. --
  -----------------------------------------
  else
    --
    l_function_call :=
    p_local_variable || ' := ' || c_newline ||
    p_function.package_name || '.' || p_function.function_name;
    --
    -- No parameter list, so no brackets.
    --
    p_precall := p_precall || l_function_call || ';';
  end if;
end add_to_precall;

-- ------------------------- add_to_call ----------------------------------
-- Description:
-- Builds up the API call a parameter at a time.
-- ------------------------------------------------------------------------
procedure add_to_call
(
  p_call           in out nocopy varchar2,
  p_parameter      in     t_parameter,
  p_local_variable in     varchar2,
  p_first_time     in out nocopy boolean
)
is
  l_local_variable varchar2(30);
begin
  --
  -- Only API parameters are passed to the API call.
  --
  if p_parameter.api_seqno is not null then
    --
    -- Only add comma argument separator if this is the second or a later
    -- parameter.
    --
    if p_first_time then
      p_first_time := false;
    else
      p_call := p_call || c_newline || ',';
    end if;
    --
    -- p_validate maps onto local parameter l_validate.
    --
    if p_parameter.parameter_name = 'P_VALIDATE' then
      p_call := p_call || 'p_validate => l_validate';
      return;
    end if;
    --
    -- p_business_group_id is passed in directly from the wrapper.
    --
    if p_parameter.parameter_name = 'P_BUSINESS_GROUP_ID' then
      p_call := p_call || 'p_business_group_id => p_business_group_id';
      return;
    end if;
    --
    -- If the parameter has an associated local variable then pass in that
    -- local variable.
    --
    if p_local_variable is not null then
      if p_parameter.mapping_type = c_mapping_type_user_key then
        p_call :=
        p_call || p_parameter.mapping_definition || ' => ' || p_local_variable;

        if g_debug then
          hr_utility.trace
          (p_parameter.parameter_name || ':' ||
           p_parameter.mapping_definition || ':' || p_local_variable
          );
        end if;

      else
        p_call :=
        p_call || p_parameter.parameter_name || ' => ' || p_local_variable;
      end if;
      return;
    end if;
    --
    -- Generate a local variable for parameters mapped onto functions.
    --
    if p_parameter.mapping_type = c_mapping_type_function then
      l_local_variable := gen_local_variable( p_parameter.parameter_name );
      p_call :=
      p_call || p_parameter.parameter_name || ' => ' || l_local_variable;
      return;
    end if;
    --
    -- Only possible case is a batch lines parameter which can be accessed
    -- from the c cursor.
    --
    p_call :=
    p_call || p_parameter.parameter_name || ' => ' ||
    gen_cursor_field( p_parameter.batch_lines_column );
  end if;
end add_to_call;

-- ------------------------- add_to_cursor --------------------------------
-- Description:
-- Adds a line for a parameter to the c cursor in the API call wrapper.
-- ------------------------------------------------------------------------
procedure add_to_cursor
(
  p_cursor                in out nocopy varchar2,
  p_parameter             in     t_parameter,
  p_effdate_parameter     in     varchar2 default null,
  p_langcode_parameter    in     varchar2 default null
)
is
  l_column_name varchar2(64); -- Holds column name for this parameter.
begin
  --
  -- Only update cursor text for batch lines parameters.
  --
  if p_parameter.batch_lines_seqno is not null then
    --
    l_column_name := 'l.' || p_parameter.batch_lines_column;
    --
    p_cursor := p_cursor || ',' || c_newline;
    --
    if p_parameter.datatype = c_dtype_long or
       ( p_parameter.in_out = c_ptype_out and
         p_parameter.datatype <> c_dtype_date )
    then
      --
      -- long, and non-date out-only parameters are returned
      -- unchanged from batch lines table.
      --
      p_cursor := p_cursor || l_column_name;
    else
      --
      -- Pass the parameter in a decode statement. A parameter value of
      -- '<NULL>' results in the returned value being null. date out-only
      -- parameters are handled here so that the cursor field has the
      -- correct type.
      --
      p_cursor :=
      p_cursor ||
      'decode(' || l_column_name || ',cn,';
      if p_parameter.datatype = c_dtype_date then
        --
        -- This needs to be done so that the return type is date, otherwise
        -- date value passed to the API depends on the NLS date format.
        --
        p_cursor := p_cursor || 'dn,';
      elsif p_parameter.datatype = c_dtype_number then
        --
        -- Do proper to_number conversion.
        --
        p_cursor := p_cursor || 'nn,';
      else
        p_cursor := p_cursor || 'vn,';
      end if;
      --
      -- If the parameter is defaultable then pass in the default value
      -- if the parameter returned from batch lines is null.
      --
      if p_parameter.defaultable then
        p_cursor :=
        p_cursor ||
        'vn,' || p_parameter.call_default_value || ',';
      end if;
      --
      -- Set up the defaults for the decode statement.
      --
      if p_parameter.mapping_type = c_mapping_type_lookup then
        --
        -- If the parameter is a lookup parameter then the default value
        -- for the decode statement is a call to hr_pump_get.gl.
        --
        p_cursor :=
        p_cursor || c_newline ||
        ' hr_pump_get.gl(' || l_column_name ||
        ',''' || p_parameter.mapping_definition || '''';
        --
        -- Add effective date parameter, if one is available. If such
        -- a parameter is not available hr_pump_get.gl uses the system
        -- date.
        --
        if p_effdate_parameter is not null then
          p_cursor := p_cursor || ',d(l.' || p_effdate_parameter || ')';
        else
          p_cursor := p_cursor || ',dn';
        end if;
        --
        -- Add the language code parameter, if one is available. If such
        -- a parameter is not available hr_pump_get.gl uses the value
        -- from USERENV('LANG').
        --
        if p_langcode_parameter is not null then
          p_cursor := p_cursor || ',l.' || p_langcode_parameter;
        else
          p_cursor := p_cursor || ',vn';
        end if;
        p_cursor := p_cursor || ')';
      elsif p_parameter.datatype = c_dtype_date then
        --
        -- For date parameters, it is necessary to do a to_date conversion.
        --
        p_cursor :=
        p_cursor || 'd(' || l_column_name || ')';
      elsif p_parameter.datatype = c_dtype_number then
        --
        -- For number parameters, it is necessary to do a to_number conversion.
        --
        p_cursor :=
        p_cursor || 'n(' || l_column_name || ')';
      else
        --
        -- Pass the column value itself.
        --
        p_cursor := p_cursor || l_column_name;
      end if;
      --
      -- Terminate the decode call.
      --
      p_cursor := p_cursor || ')';
    end if;
    --
    -- Cursor line is terminated with the batch lines column name.
    --
    p_cursor := p_cursor || ' ' ||
                gen_cursor_field(p_parameter.batch_lines_column, false);
    --
    -- If the parameter is defaultable then add the defaulting check column.
    -- Do not do this for long parameters because the default checking
    -- cannot be done using the decode function.
    --
    if p_parameter.defaultable and
       p_parameter.datatype <> c_dtype_long and
       hr_pump_meta_mapper.g_standard_generate
    then
      p_cursor :=
      p_cursor || ',' || c_newline ||
      'l.' || p_parameter.batch_lines_column || ' ' ||
      gen_def_check_name
      (gen_cursor_field(p_parameter.batch_lines_column, false)
      );
    end if;
  end if;
end add_to_cursor;

-- -------------------------- add_to_postcall -----------------------------
-- Description:
-- Does work after the API call e.g. converting boolean values back.
-- ------------------------------------------------------------------------
procedure add_to_postcall
(
  p_postcall       in out nocopy varchar2,
  p_parameter      in     t_parameter,
  p_local_variable in     varchar2,
  p_first_postcall in out nocopy boolean
)
is
  l_cursor_field varchar2(64);
begin
  if (p_parameter.in_out = c_ptype_out or p_parameter.in_out = c_ptype_in_out)
     and p_parameter.batch_lines_seqno is not null
  then
    l_cursor_field := gen_cursor_field( p_parameter.batch_lines_column );
    --
    -- For user_key-mapped parameters need to insert into
    -- hr_pump_batch_line_user_keys.
    --
    if p_parameter.mapping_type = c_mapping_type_user_key then
      if p_first_postcall then
        p_first_postcall := false;
      else
        p_postcall := p_postcall || c_newline;
      end if;
      p_postcall :=
      p_postcall || '--' || c_newline ||
      'iuk(p_batch_line_id,' || l_cursor_field ||
      ',' || p_local_variable || ');';
      return;
    end if;
    --
    -- Convert boolean parameters back.
    --
    if p_parameter.datatype = c_dtype_boolean then
      if p_first_postcall then
        p_first_postcall := false;
      else
        p_postcall := p_postcall || c_newline;
      end if;
      p_postcall :=
      p_postcall || '--' || c_newline ||
      'if ' || p_local_variable || ' then'       || c_newline ||
      l_cursor_field || ' := ''TRUE'';'  || c_newline ||
      'else'                                     || c_newline ||
      l_cursor_field || ' := ''FALSE'';' || c_newline ||
      'end if;';
      return;
    end if;
  end if;
end add_to_postcall;

-- --------------------------- add_to_update ------------------------------
-- Description:
-- Adds to the update statement to write back OUT parameters to the
-- batch lines table.
-- ------------------------------------------------------------------------
procedure add_to_update
(
  p_update         in out nocopy varchar2,
  p_parameter      in     t_parameter,
  p_local_variable in     varchar2,
  p_first_update   in out nocopy boolean
)
is
  l_cursor_field varchar2(64);
  l_column       varchar2(64);
begin
  --
  -- Only interested in batch lines out parameters.
  --
  if p_parameter.batch_lines_seqno is not null and
     ( p_parameter.in_out = c_ptype_out or p_parameter.in_out = c_ptype_in_out )
  then
    if p_first_update then
      p_first_update := false;
    else
      p_update := p_update || ',';
    end if;
    --
    -- For long parameters we use the varchar2 local variable. For other
    -- parameters, the cursor field is used.
    --
    if p_parameter.datatype = c_dtype_long then
      l_cursor_field := p_local_variable;
    else
      l_cursor_field := gen_cursor_field( p_parameter.batch_lines_column );
    end if;
    l_column := 'l.' || p_parameter.batch_lines_column;
    p_update :=
    p_update || c_newline ||
    l_column || ' = decode(' || l_cursor_field || ',null,cn,';
    if p_parameter.datatype = c_dtype_date then
      p_update := p_update || 'dc(' || l_cursor_field || ')';
    else
      p_update := p_update || l_cursor_field;
    end if;
    p_update := p_update || ')';
  end if;
end add_to_update;

-- --------------------------- generate_call ------------------------------
-- Description:
-- Generates the wrapper code for calling the API.
-- ------------------------------------------------------------------------
procedure generate_call
(
  p_module_package     in     varchar2,
  p_module_name        in     varchar2,
  p_parameter_tbl      in     t_parameter_tbl,
  p_function_tbl       in     t_function_tbl,
  p_function_call_tbl  in     t_function_parameter_tbl,
  p_parameter_counts   in     t_parameter_counts,
  p_header             in out nocopy varchar2,
  p_body               in out nocopy varchar2,
  p_body_pieces        in out nocopy dbms_sql.varchar2s
)
is
  l_locals          varchar2(32767); -- Local variables for call procedure.
  l_locals1         varchar2(32767); -- Local variables for call procedure.
  l_cursor          varchar2(32767); -- Cursor for getting batch lines data.
  l_precall         varchar2(32767); -- Pre-call code e.g. boolean conversion.
  l_precall1        varchar2(32767); -- Pre-call code e.g. boolean conversion.
  l_call            varchar2(32767); -- The API call itself.
  l_call1           varchar2(32767); -- The API call itself.
  l_call2           varchar2(32767); -- The API call itself.
  l_postcall        varchar2(32767); -- Post-call code e.g. boolean conversion.
  l_update          varchar2(32767); -- Update batch lines with output data.
  l_local_variable  varchar2(30);    -- Local variable for this parameter.
  l_parameter       t_parameter;
  l_first_call      boolean := true;
  l_first_update    boolean := true;
  l_first_postcall  boolean := true;
  l_effdate         varchar2(30);    -- P_EFFECTIVE_DATE batch lines column.
  l_langcode        varchar2(30);    -- P_LANGUAGE_CODE batch lines column.
begin
  --
  -- Get the effective date parameter's batch lines column name.
  --
  l_effdate := null;
  for i in 1 .. p_parameter_counts.total_parameters loop
    if (upper(p_parameter_tbl(i).parameter_name) = 'P_EFFECTIVE_DATE' or
        (p_parameter_tbl(i).mapping_type = c_mapping_type_aliased and
         p_parameter_tbl(i).mapping_definition = 'P_EFFECTIVE_DATE')) and
       p_parameter_tbl(i).datatype = c_dtype_date
    then
      l_effdate := p_parameter_tbl(i).batch_lines_column;
      exit;
    end if;
  end loop;
  --
  -- Get the language code parameter's batch lines column name.
  --
  l_langcode := null;
  for i in 1 .. p_parameter_counts.total_parameters loop
    if (upper(p_parameter_tbl(i).parameter_name) = 'P_LANGUAGE_CODE' or
        (p_parameter_tbl(i).mapping_type = c_mapping_type_aliased and
         p_parameter_tbl(i).mapping_definition = 'P_LANGUAGE_CODE')) and
       p_parameter_tbl(i).datatype = c_dtype_varchar2
    then
      l_langcode := p_parameter_tbl(i).batch_lines_column;
      exit;
    end if;
  end loop;
  --
  -- Simple header text addition.
  --
  p_header :=
  p_header ||
  'procedure call' || c_newline ||
  '(p_business_group_id in number,'   || c_newline ||
  'p_batch_line_id     in number);'   || c_newline;
  --
  p_body :=
  p_body ||
  'procedure call' || c_newline ||
  '(p_business_group_id in number,'    || c_newline ||
  'p_batch_line_id     in number) is';
  --
  -- Generate the body of the call procedure - this is the real work.
  --
  l_locals     := 'c cr%rowtype;' || c_newline ||
                  'l_validate boolean := false;';
  l_cursor     := 'cursor cr is' || c_newline || 'select l.rowid myrowid';
  l_precall    := '';
  --
  -- Only bracket API call if it has at least one parameter.
  --
  if p_parameter_counts.api_parameters > 0 then
    l_call := p_module_package || '.' || p_module_name ||
              c_newline || '(';
  else
    l_call := p_module_package || '.' || p_module_name || ';';
  end if;
  l_postcall   := null;
  l_update     := 'update hr_pump_batch_lines l set';
  for i in 1 .. p_parameter_counts.total_parameters loop
    l_local_variable := null;
    --
    add_to_locals( l_locals, p_parameter_tbl(i), l_local_variable );
    --
    add_to_cursor( l_cursor, p_parameter_tbl(i), l_effdate, l_langcode );
    --
    add_to_precall( l_precall, p_parameter_tbl(i), l_local_variable );
    --
    if i <= trunc(p_parameter_counts.total_parameters / 3) then
      add_to_call( l_call, p_parameter_tbl(i), l_local_variable, l_first_call );
    elsif i <= trunc(2 * p_parameter_counts.total_parameters / 3) then
      add_to_call( l_call1, p_parameter_tbl(i), l_local_variable, l_first_call );
    else
      add_to_call( l_call2, p_parameter_tbl(i), l_local_variable, l_first_call );
    end if;
    --
    add_to_postcall( l_postcall, p_parameter_tbl(i), l_local_variable,
                     l_first_postcall );
    --
    add_to_update( l_update, p_parameter_tbl(i), l_local_variable,
                   l_first_update );
  end loop;
  --
  -- Terminate the cursor text.
  --
  l_cursor :=
  l_cursor || c_newline || 'from hr_pump_batch_lines l' || c_newline ||
  'where l.batch_line_id = p_batch_line_id;';
  --
  -- Terminate the call.
  --
  if p_parameter_counts.api_parameters > 0 then
    l_call2 := l_call2 || ');' || c_newline;
  end if;
  --
  -- Terminate the update.
  --
  if not l_first_update then
    l_update :=
    l_update || c_newline ||
    'where l.rowid = c.myrowid;';
  else
    l_update := null;
  end if;
  --
  -- Handle any parameter mapping functions.
  --
  for i in 1 .. p_parameter_counts.functions loop
    l_local_variable := null;
    --
    add_to_locals( l_locals1, p_function_tbl(i), p_parameter_tbl,
                   l_local_variable );
    --
    add_to_precall( l_precall1, p_parameter_tbl( p_function_tbl(i).seqno ),
                    p_function_tbl(i), p_function_call_tbl,
                    l_local_variable );
  end loop;

  ---------------------------------------------------------------------
  -- At last we can build the package body. This is done by creating --
  -- body pieces in stages.                                          --
  ---------------------------------------------------------------------
  p_body :=
  p_body || c_newline || l_cursor || c_newline || '--' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body :=
  p_body || l_locals || l_locals1 || c_newline || '--' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body ||
  'begin'                                               || c_newline ||
  'hr_data_pump.entry(''call'');'                       || c_newline ||
  'open cr;'                                            || c_newline ||
  'fetch cr into c;'                                    || c_newline ||
  'if cr%notfound then'                                 || c_newline ||
  'hr_utility.set_message(800,''HR_50326_DP_NO_ROW'');' || c_newline ||
  'hr_utility.set_message_token(''TABLE'',''HR_PUMP_BATCH_LINES'');' ||
  c_newline ||
  'hr_utility.set_message_token(''COLUMN'',''P_BATCH_LINE_ID'');' ||
  c_newline ||
  'hr_utility.set_message_token(''VALUE'',p_batch_line_id);' ||
  c_newline ||
  'hr_utility.raise_error;'                             || c_newline ||
  'end if;';
  --
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_precall;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_precall1 || c_newline || '--' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body :=
  p_body || 'hr_data_pump.api_trc_on;' || c_newline || l_call;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_call1;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_call2 || 'hr_data_pump.api_trc_off;' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_postcall || c_newline || '--' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body || l_update || c_newline || '--' || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );

  p_body := p_body ||
  'close cr;'                                           || c_newline ||
  '--'                                                  || c_newline ||
  'hr_data_pump.exit(''call'');'                        || c_newline ||
  'exception'                                           || c_newline ||
  ' when hr_multi_message.error_message_exist then'     || c_newline ||
  '   if cr%isopen then'                                || c_newline ||
  '    close cr;'                                       || c_newline ||
  '   end if;'                                          || c_newline ||
  '   hr_pump_utils.set_multi_msg_error_flag(true);'    || c_newline ||
  ' when others then'                                   || c_newline ||
  ' if cr%isopen then'                                  || c_newline ||
  '  close cr;'                                         || c_newline ||
  ' end if;'                                            || c_newline ||
  ' raise;'                                             || c_newline ||
  'end call;'                                           || c_newline;
  split_sql_text
  (p_last        => false
  ,p_text        => p_body
  ,p_text_pieces => p_body_pieces
  );
end generate_call;

-- ------------------------- create_package -------------------------------
-- Description:
-- Generates the header and body text for the output packages, and compiles
-- the output packages.
-- ------------------------------------------------------------------------
procedure create_package
(
  p_module_package     in varchar2,
  p_module_name        in varchar2,
  p_package_name       in varchar2,
  p_api_module_id      in number,
  p_parameter_tbl      in t_parameter_tbl,
  p_function_tbl       in t_function_tbl,
  p_function_call_tbl  in t_function_parameter_tbl,
  p_parameter_counts   in t_parameter_counts
)
is
  l_header         varchar2(32767);
  l_body           varchar2(32767);
  l_header_comment varchar2(2048);
  l_body_pieces    dbms_sql.varchar2s;
begin
  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=
    '/*' || c_newline ||
    ' * Generated by hr_pump_meta_mapper at: '  ||
    to_char( sysdate, 'YYYY/MM/DD HH24:MM:SS' ) || c_newline ||
    ' * Generated for API: ' || p_module_package || '.' || p_module_name ||
    c_newline ||
    ' */' || c_newline || '--' || c_newline;
    l_header :=
    'create or replace package ' || p_package_name || ' as' || c_newline ||
    l_header_comment ||
    'g_generator_version constant varchar2(128) default ' ||
    '''$Revision: 120.4.12010000.1 $'';' || c_newline || '--' || c_newline;
    l_body :=
    'create or replace package body ' || p_package_name || ' as' || c_newline ||
    l_header_comment;
    --
    -- Generate the procedures and functions.
    --
    gen_hr_api_vars(l_body);
    gen_null_vars(l_body);
    l_body := l_body || c_newline || '--' || c_newline;
    gen_to_calls( l_body, l_header );
    l_body := l_body || c_newline || '--' || c_newline;
    l_header := l_header || c_newline || '--' || c_newline;
    gen_ins_user_key( l_body );
    l_body := l_body || c_newline || '--' || c_newline;
    generate_insert( p_api_module_id, p_parameter_tbl, p_parameter_counts,
                     l_header, l_body );
    split_sql_text
    (p_last        => false
    ,p_text        => l_body
    ,p_text_pieces => l_body_pieces
    );
    l_header := l_header || c_newline || '--' || c_newline;
    l_body := l_body || c_newline || '--' || c_newline;
    generate_call
    (p_module_package    => p_module_package
    ,p_module_name       => p_module_name
    ,p_parameter_tbl     => p_parameter_tbl
    ,p_function_tbl      => p_function_tbl
    ,p_function_call_tbl => p_function_call_tbl
    ,p_parameter_counts  => p_parameter_counts
    ,p_header            => l_header
    ,p_body              => l_body
    ,p_body_pieces       => l_body_pieces
    );
    --
    -- Terminate the package body and header.
    --
    l_header := l_header || 'end ' || p_package_name || ';';
    l_body := l_body || 'end ' || p_package_name || ';';
    split_sql_text
    (p_last        => true
    ,p_text        => l_body
    ,p_text_pieces => l_body_pieces
    );
  exception
    when plsql_value_error then
      hr_utility.set_message( 800, 'HR_50323_DP_CODE_TOO_BIG' );
      hr_utility.raise_error;
  end;
  --
  -- Compile the header and body.
  --
  run_sql( l_header );
  check_compile( p_package_name, 'PACKAGE' );
  run_sql( l_body_pieces );
  check_compile( p_package_name, 'PACKAGE BODY' );
end create_package;

---------------------------------------------------------------------------
--                          PUBLIC PROCEDURES                            --
---------------------------------------------------------------------------
-- -------------------------- generate ------------------------------------
-- Description:
-- Generates a package containing the following:
-- - A wrapper procedure to call the API.
-- - A procedure to insert data for this API in hr_pump_batch_lines.
-- - A procedure to list the view columns and the parameters required
--   for the above data insert function.
-- Generates a view on hr_pump_batch_lines to allow a user an alternative
-- mechanism to insert or update data.
-- ------------------------------------------------------------------------
procedure generate
(
  p_module_package in varchar2,
  p_module_name    in varchar2
 ,p_standard_generate in boolean default true
)
is
  l_parameter_counts  t_parameter_counts;
  l_defaulting_style  number;
  l_parameter_tbl     t_parameter_tbl;
  l_function_tbl      t_function_tbl;
  l_function_call_tbl t_function_parameter_tbl;
  --
  l_api_module_id     number;
  --
  l_view_name           varchar2(30);
  l_package_name        varchar2(30);
  --
  cursor csr_api_module_id
  (p_module_package in varchar2, p_module_name in varchar2) is
  select api_module_id
  from   hr_api_modules
  where  upper(module_name) = upper(p_module_name)
  and    upper(module_package) = upper(p_module_package)
  and    upper(api_module_type) in ('AI', 'BP', 'DM');
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.trace
    ('----------- Generate API: ' || p_module_package || '.' ||
      p_module_name || '----------');
  end if;

  hr_pump_meta_mapper.g_standard_generate := p_standard_generate;
  setup_parameter_data( p_module_package,
                        p_module_name,
                        l_parameter_counts,
                        l_defaulting_style,
                        l_parameter_tbl,
                        l_function_tbl,
                        l_function_call_tbl );

  open csr_api_module_id(p_module_package, p_module_name);
  fetch csr_api_module_id into l_api_module_id;
  if csr_api_module_id%notfound then
    close csr_api_module_id;
    hr_utility.set_message(800, 'HR_33156_DP_NOT_IN_API_MODULES');
    hr_utility.set_message_token
    ( 'API', p_module_package || '.' || p_module_name );
    hr_utility.raise_error;
  end if;
  close csr_api_module_id;

  purge( p_module_package, p_module_name );

  hr_pump_utils.name( p_module_package, p_module_name, l_package_name,
                      l_view_name );

  if g_debug then
    hr_utility.trace('Package: ' || l_package_name);
    hr_utility.trace('View:    ' || l_view_name);
  end if;

  create_view( l_view_name, l_parameter_tbl, l_parameter_counts,
               l_api_module_id );

  create_package( p_module_package, p_module_name, l_package_name,
                  l_api_module_id, l_parameter_tbl, l_function_tbl,
                  l_function_call_tbl, l_parameter_counts );
  l_parameter_tbl.delete;
  l_function_tbl.delete;
  l_function_call_tbl.delete;
end generate;

-- ------------------------- generateall ----------------------------------
-- Description:
-- Calls generate on all supported APIs.
-- ------------------------------------------------------------------------
procedure generateall is
begin
  generate( 'hr_employee_api', 'create_employee' );
  generate( 'hr_employee_api', 'create_gb_employee' );
  generate( 'hr_employee_api', 'create_us_employee' );
  generate( 'hr_assignment_api', 'activate_emp_asg' );
  generate( 'hr_assignment_api', 'actual_termination_emp_asg' );
  generate( 'hr_assignment_api', 'create_secondary_emp_asg' );
  generate( 'hr_assignment_api', 'create_gb_secondary_emp_asg' );
  generate( 'hr_assignment_api', 'create_us_secondary_emp_asg' );
  generate( 'hr_assignment_api', 'update_emp_asg' );
  generate( 'hr_assignment_api', 'update_emp_asg_criteria' );
  generate( 'hr_job_api', 'create_job' );
  generate( 'hr_position_api', 'create_position' );
  generate( 'hr_position_api', 'update_position' );
  generate( 'hr_valid_grade_api', 'create_valid_grade' );
  --
  generate( 'HR_PERSON_ADDRESS_API', 'CREATE_PERSON_ADDRESS' );
  generate( 'HR_PERSON_ADDRESS_API', 'CREATE_US_PERSON_ADDRESS' );
  generate( 'HR_PERSON_ADDRESS_API', 'CREATE_GB_PERSON_ADDRESS' );
  generate( 'HR_PERSON_ADDRESS_API', 'UPDATE_PERSON_ADDRESS' );
  generate( 'HR_PERSON_ADDRESS_API', 'UPDATE_US_PERSON_ADDRESS' );
  generate( 'HR_PERSON_ADDRESS_API', 'UPDATE_GB_PERSON_ADDRESS' );
  generate( 'HR_CONTACT_API', 'CREATE_PERSON' );
  generate( 'HR_CONTACT_REL_API', 'CREATE_CONTACT' );
  generate( 'PY_ELEMENT_ENTRY_API', 'CREATE_ELEMENT_ENTRY' );
  generate( 'PY_ELEMENT_ENTRY_API', 'UPDATE_ELEMENT_ENTRY' );
  generate( 'PY_ELEMENT_ENTRY_API', 'DELETE_ELEMENT_ENTRY' );
--temporarily comment out these lines for 2734761
--WIP on grade rate APIs is done to seed correct data for hr_rate_values_api
--  generate( 'HR_RATE_VALUES_API', 'CREATE_RATE_VALUE' );
--  generate( 'HR_RATE_VALUES_API', 'UPDATE_RATE_VALUE' );
--  generate( 'HR_RATE_VALUES_API', 'DELETE_RATE_VALUE' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_GB_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_US_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_GB_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_US_PERSONAL_PAY_METHOD' );
  generate( 'HR_PERSONAL_PAY_METHOD_API', 'DELETE_PERSONAL_PAY_METHOD' );
  generate( 'HR_SIT_API', 'CREATE_SIT' );
  generate( 'HR_APPLICANT_API', 'CREATE_APPLICANT' );
  generate( 'HR_APPLICANT_API', 'CREATE_GB_APPLICANT' );
  generate( 'HR_APPLICANT_API', 'CREATE_US_APPLICANT' );
  generate( 'HR_JOB_REQUIREMENT_API', 'CREATE_JOB_REQUIREMENT' );
  generate( 'HR_POSITION_REQUIREMENT_API', 'CREATE_POSITION_REQUIREMENT' );
  generate( 'HR_PERSON_API', 'UPDATE_PERSON' );
  generate( 'HR_PERSON_API', 'UPDATE_GB_PERSON' );
  generate( 'HR_PERSON_API', 'UPDATE_US_PERSON' );
--temporarily comment out these lines for 2734761
--WIP on these APIs is done to seed correct data for hr_pay_scale_api
--  generate( 'HR_PAY_SCALE_API', 'CREATE_PAY_SCALE_VALUE' );
--  generate( 'HR_PAY_SCALE_API', 'UPDATE_PAY_SCALE_VALUE' );
--  generate( 'HR_PAY_SCALE_API', 'DELETE_PAY_SCALE_VALUE' );
  generate( 'HR_EX_EMPLOYEE_API', 'ACTUAL_TERMINATION_EMP' );
  generate( 'HR_EX_EMPLOYEE_API', 'FINAL_PROCESS_EMP' );
  --
  generate( 'HR_ASSIGNMENT_API', 'SUSPEND_EMP_ASG' );
  generate( 'HR_ASSIGNMENT_API', 'UPDATE_US_EMP_ASG' );
  generate( 'HR_ASSIGNMENT_API', 'UPDATE_GB_EMP_ASG' );
/*
  -- Taking out as generateall should not be updated. 3296375.
  -- Adnan
  --Location
  generate('HR_LOCATION_API','CREATE_LOCATION');
  --Org Hierarchy Element
  generate('HR_HIERARCHY_ELEMENT_API','CREATE_HIERARCHY_ELEMENT');
  --Salary Basis
  generate('HR_SALARY_BASIS_API','CREATE_SALARY_BASIS');
  --Salary Proposal
  generate('HR_UPLOAD_PROPOSAL_API','UPLOAD_SALARY_PROPOSAL');
*/
end generateall;

-- ---------------------------- purgeall ----------------------------------
-- Description:
-- Calls purge on all supported APIs.
-- ------------------------------------------------------------------------
procedure purgeall is
begin
  purge( 'hr_employee_api', 'create_employee' );
  purge( 'hr_employee_api', 'create_gb_employee' );
  purge( 'hr_employee_api', 'create_us_employee' );
  purge( 'hr_assignment_api', 'activate_emp_asg' );
  purge( 'hr_assignment_api', 'actual_termination_emp_asg' );
  purge( 'hr_assignment_api', 'create_secondary_emp_asg' );
  purge( 'hr_assignment_api', 'create_gb_secondary_emp_asg' );
  purge( 'hr_assignment_api', 'create_us_secondary_emp_asg' );
  purge( 'hr_assignment_api', 'update_emp_asg' );
  purge( 'hr_assignment_api', 'update_emp_asg_criteria' );
  purge( 'hr_job_api', 'create_job' );
  purge( 'hr_position_api', 'create_position' );
  purge( 'hr_position_api', 'update_position' );
  purge( 'hr_valid_grade_api', 'create_valid_grade' );
  --
  purge( 'HR_PERSON_ADDRESS_API', 'CREATE_PERSON_ADDRESS' );
  purge( 'HR_PERSON_ADDRESS_API', 'CREATE_US_PERSON_ADDRESS' );
  purge( 'HR_PERSON_ADDRESS_API', 'CREATE_GB_PERSON_ADDRESS' );
  purge( 'HR_PERSON_ADDRESS_API', 'UPDATE_PERSON_ADDRESS' );
  purge( 'HR_PERSON_ADDRESS_API', 'UPDATE_US_PERSON_ADDRESS' );
  purge( 'HR_PERSON_ADDRESS_API', 'UPDATE_GB_PERSON_ADDRESS' );
  purge( 'HR_CONTACT_API', 'CREATE_PERSON' );
  purge( 'HR_CONTACT_REL_API', 'CREATE_CONTACT' );
  purge( 'PY_ELEMENT_ENTRY_API', 'CREATE_ELEMENT_ENTRY' );
  purge( 'PY_ELEMENT_ENTRY_API', 'UPDATE_ELEMENT_ENTRY' );
  purge( 'PY_ELEMENT_ENTRY_API', 'DELETE_ELEMENT_ENTRY' );
--temporarily comment out these lines for 2734761
--WIP on grade rate APIs is done to seed correct data for hr_rate_values_api
--  purge( 'HR_RATE_VALUES_API', 'CREATE_RATE_VALUE' );
--  purge( 'HR_RATE_VALUES_API', 'UPDATE_RATE_VALUE' );
--  purge( 'HR_RATE_VALUES_API', 'DELETE_RATE_VALUE' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_GB_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'CREATE_US_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_GB_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'UPDATE_US_PERSONAL_PAY_METHOD' );
  purge( 'HR_PERSONAL_PAY_METHOD_API', 'DELETE_PERSONAL_PAY_METHOD' );
  purge( 'HR_SIT_API', 'CREATE_SIT' );
  purge( 'HR_APPLICANT_API', 'CREATE_APPLICANT' );
  purge( 'HR_APPLICANT_API', 'CREATE_GB_APPLICANT' );
  purge( 'HR_APPLICANT_API', 'CREATE_US_APPLICANT' );
  purge( 'HR_JOB_REQUIREMENT_API', 'CREATE_JOB_REQUIREMENT' );
  purge( 'HR_POSITION_REQUIREMENT_API', 'CREATE_POSITION_REQUIREMENT' );
  purge( 'HR_PERSON_API', 'UPDATE_PERSON' );
  purge( 'HR_PERSON_API', 'UPDATE_GB_PERSON' );
  purge( 'HR_PERSON_API', 'UPDATE_US_PERSON' );
--temporarily comment out these lines for 2734761
--WIP on these APIs is done to seed correct data for hr_pay_scale_api
--  purge( 'HR_PAY_SCALE_API', 'CREATE_PAY_SCALE_VALUE' );
--  purge( 'HR_PAY_SCALE_API', 'UPDATE_PAY_SCALE_VALUE' );
--  purge( 'HR_PAY_SCALE_API', 'DELETE_PAY_SCALE_VALUE' );
  purge( 'HR_EX_EMPLOYEE_API', 'ACTUAL_TERMINATION_EMP' );
  purge( 'HR_EX_EMPLOYEE_API', 'FINAL_PROCESS_EMP' );
  --
  purge( 'HR_ASSIGNMENT_API', 'SUSPEND_EMP_ASG' );
  purge( 'HR_ASSIGNMENT_API', 'UPDATE_US_EMP_ASG' );
  purge( 'HR_ASSIGNMENT_API', 'UPDATE_GB_EMP_ASG' );
end purgeall;

-- ---------------------------- help --------------------------------------
-- Description:
-- Displays the following help text for the API specified by p_module_name
-- and p_module_package:
-- - The generated package and view name.
-- - Batch lines parameter information.
-- ------------------------------------------------------------------------
procedure help
(
  p_module_package in varchar2,
  p_module_name    in varchar2
 ,p_standard_generate in boolean default true
)
is
  l_parameter_counts  t_parameter_counts;
  l_defaulting_style  number;
  l_parameter_tbl     t_parameter_tbl;
  l_function_tbl      t_function_tbl;
  l_function_call_tbl t_function_parameter_tbl;
  --
  l_view_name         varchar2(30);
  l_package_name      varchar2(30);
  --
  -- Batch lines parameter help information.
  --
  l_helpstring        varchar2(84);
  l_parameter_name    varchar2(31);
  l_parameter_type    varchar2(10);
  l_in_out            varchar2(4);
  l_lookup_type       varchar2(31);
  l_default           varchar2(8);
  --
  l_message           varchar2(2048);
begin
  hr_pump_meta_mapper.g_standard_generate := p_standard_generate;
  setup_parameter_data( p_module_package,
                        p_module_name,
                        l_parameter_counts,
                        l_defaulting_style,
                        l_parameter_tbl,
                        l_function_tbl,
                        l_function_call_tbl );

  hr_pump_utils.name( p_module_package, p_module_name, l_package_name,
                      l_view_name );

  --
  -- Initialise the output mechanism.
  --
  output_init;

  --
  -- Generate and output the messages saying what has been created.
  --
  hr_utility.set_message( 800, 'HR_50324_DP_GEN_PKG' );
  hr_utility.set_message_token( 'PACKAGE', l_package_name );
  l_message := hr_utility.get_message;
  output_text( l_message);
  --
  hr_utility.set_message( 800, 'HR_50325_DP_GEN_VIEW' );
  hr_utility.set_message_token( 'VIEW', l_view_name );
  l_message := hr_utility.get_message;
  output_text( l_message);
  --
  -- Generate the header.
  --
  output_text( 'Parameter Name    Type    In/Out    Default?    Lookup Type' );
  output_text( '---------------   -----   -------   --------    ------------' );

  for i in 1 .. l_parameter_counts.total_parameters loop
    --
    -- Only list information for batch lines parameters.
    --
    if l_parameter_tbl(i).batch_lines_seqno is not null then
      --
      l_parameter_name := rpad( l_parameter_tbl(i).parameter_name, 31 );
      --
      -- Only lookup parameters have an associated lookup type.
      --
      if l_parameter_tbl(i).mapping_type = 'USER_KEY' then
        l_parameter_type := 'USER_KEY';
        l_lookup_type := rpad( ' ', 31 );
      elsif l_parameter_tbl(i).mapping_type = 'LOOKUP' then
        l_parameter_type := 'LOOKUP';
        l_lookup_type := rpad( l_parameter_tbl(i).mapping_definition, 31 );
      else
        l_parameter_type := g_tbl_datatype( l_parameter_tbl(i).datatype );
        l_lookup_type := rpad( ' ', 31 );
      end if;
      l_parameter_type := upper( rpad( l_parameter_type, 10 ) );
      --
      if l_parameter_tbl(i).defaultable then
        l_default := rpad( 'DEFAULT', 8 );
      else
        l_default := rpad( ' ', 8 );
      end if;
      --
      -- Set up the in/out field. For user key parameters we make the in/out
      -- 'IN' because the user has to supply the user key.
      --
      if l_parameter_tbl(i).in_out = c_ptype_out and
         l_parameter_tbl(i).mapping_type <> c_mapping_type_user_key
      then
        l_in_out := rpad( 'OUT', 4 );
      else
        l_in_out := rpad( 'IN', 4 );
      end if;
      --
      -- Output is almost identical to the output of the desc command.
      --
      l_helpstring :=
      l_parameter_name || l_parameter_type || l_in_out || l_default ||
      l_lookup_type;
      --
      -- Output the help string.
      --
      output_text( l_helpstring );
    end if;
  end loop;

  l_parameter_tbl.delete;
  l_function_tbl.delete;
  l_function_call_tbl.delete;
end help;

-- -------------------------- purge ---------------------------------------
-- Description:
-- Purges all data created by a generate call for the API.
-- ------------------------------------------------------------------------
procedure purge( p_module_package in varchar2,
                 p_module_name    in varchar2 )
is
  --
  cursor csr_find_view( p_view_name in varchar2 ) is
  select 1 from user_views
  where  upper(view_name) = upper(p_view_name);
  --
  cursor csr_find_pkg( p_pkg_name in varchar2 ) is
  select 1 from user_objects
  where  upper(object_name) = upper(p_pkg_name)
  and    object_type = 'PACKAGE';
  --
  l_package_name   varchar2(30);
  l_view_name      varchar2(30);
  l_found          integer;
begin
  hr_pump_utils.name( p_module_package, p_module_name, l_package_name,
                      l_view_name );

  -- Delete the package if it exists.
  begin
    --
    open csr_find_pkg( l_package_name );
    fetch csr_find_pkg into l_found;
    if csr_find_pkg%notfound then
      l_found := 0;
    end if;
    close csr_find_pkg;
  exception
    when others then
      if csr_find_pkg%isopen then
        close csr_find_pkg;
      end if;
      raise;
  end;
  --
  if l_found <> 0 then
    run_sql( 'drop package ' || l_package_name );
  end if;

  -- Delete the view if it exists.
  begin
    --
    open csr_find_view( l_view_name );
    fetch csr_find_view into l_found;
    if csr_find_view%notfound then
      l_found := 0;
    end if;
    close csr_find_view;
  exception
    when others then
      if csr_find_view%isopen then
        close csr_find_view;
      end if;
      raise;
  end;
  --
  if l_found <> 0 then
    run_sql( 'drop view ' || l_view_name );
  end if;
end purge;
--
-- --------------- init_parameter_list ----------------------------
-- Description:
-- Initialise the cached parameter list for subsequent reuse
-- in the Pump Station UI. Only refreshes the parameter list if
-- the API passed in is different to the one currently cached.
-- Returns the total number of parameters accepted by the API,
-- even if the cache isn't refreshed.
-- ----------------------------------------------------------------
function init_parameter_list(p_api_id in number) return number is
  --
  l_param_counts t_parameter_counts;
  l_func t_function_tbl;
  l_func_param t_function_parameter_tbl;
  l_defl_style number;
  --
  l_module_package varchar2(30);
  l_module_name varchar2(30);
  l_parameter_name varchar2(240);
begin
  if g_last_api_id <> p_api_id then
    --
    g_last_api_id := p_api_id;
    --
    select module_package,module_name
    into l_module_package,l_module_name
    from hr_api_modules
    where api_module_id = p_api_id;
    --
    hr_pump_meta_mapper.g_standard_generate := true;
    setup_parameter_data(
      l_module_package,
      l_module_name,
      l_param_counts,
      l_defl_style,
      g_params,
      l_func,
      l_func_param
    );
    --
    g_last_column_count := l_param_counts.total_parameters;
    --
  end if;
  return g_last_column_count;
end init_parameter_list;
--
-- ----------------- get_parameter_info --------------------------
-- Description:
-- Get information about a given parameter to an API. Returns
-- p_success as 1 if p_index is valid for the API specified by
-- p_api_id, in which case the other parameters are also valid,
-- otherwise returns p_success as 0 and everything else as null.
-- ---------------------------------------------------------------
procedure get_parameter_info
(
  p_api_id             in  number,
  p_index              in  number,
  p_batch_lines_seqno  out nocopy number,
  p_batch_lines_column out nocopy varchar2,
  p_parameter_name     out nocopy varchar2,
  p_success            out nocopy number
) is
  l_count number := 0;
begin
  l_count := init_parameter_list(p_api_id);
  --
  p_batch_lines_seqno := 0;
  p_batch_lines_column := null;
  p_parameter_name := null;
  p_success := 0;
  --
  if p_index <= l_count then
    if p_batch_lines_seqno is not null then
      p_batch_lines_seqno := g_params(p_index).batch_lines_seqno;
      p_batch_lines_column := g_params(p_index).batch_lines_column;
      p_parameter_name := g_params(p_index).parameter_name;
    end if;
    p_success := 1;
  end if;
end get_parameter_info;
--
-- Initialisation code.
--
begin
  --
  -- Set up code generation tables.
  --
  g_tbl_datatype(c_dtype_varchar2)       := 'varchar2';
  g_tbl_datatype(c_dtype_number)         := 'number';
  -- Use number instead of binary_integer data type.
  g_tbl_datatype(c_dtype_binary_integer) := 'number';
  g_tbl_datatype(c_dtype_long)           := 'long';
  g_tbl_datatype(c_dtype_date)           := 'date';
  g_tbl_datatype(c_dtype_boolean)        := 'boolean';
  -------------------------------------------------
  g_tbl_default_hr_api(c_dtype_varchar2) := 'hr_api.g_varchar2';
  g_tbl_default_hr_api(c_dtype_number)   := 'hr_api.g_number';
  g_tbl_default_hr_api(c_dtype_date)     := 'hr_api.g_date';
  -- No hr_api defaults for long and boolean.
  g_tbl_default_hr_api(c_dtype_long)     := 'null';
  g_tbl_default_hr_api(c_dtype_boolean)  := 'null';
  -------------------------------------------------
  g_tbl_default_null(c_dtype_varchar2)   := 'null';
  g_tbl_default_null(c_dtype_number)     := 'n(null)';
  g_tbl_default_null(c_dtype_date)       := 'd(null)';
  g_tbl_default_null(c_dtype_long)       := 'null';
  g_tbl_default_null(c_dtype_boolean)    := 'null';
  -------------------------------------------------
  g_tbl_call_default_hr_api(c_dtype_varchar2) := 'vh';
  g_tbl_call_default_hr_api(c_dtype_number)   := 'nh';
  g_tbl_call_default_hr_api(c_dtype_date)     := 'dh';
  -- No hr_api defaults for long and boolean.
  g_tbl_call_default_hr_api(c_dtype_long)     := 'null';
  g_tbl_call_default_hr_api(c_dtype_boolean)  := 'null';
  -------------------------------------------------
  g_tbl_call_default_null(c_dtype_varchar2)   := 'vn';
  g_tbl_call_default_null(c_dtype_number)     := 'nn';
  g_tbl_call_default_null(c_dtype_date)       := 'dn';
  g_tbl_call_default_null(c_dtype_long)       := 'null';
  g_tbl_call_default_null(c_dtype_boolean)    := 'null';
end hr_pump_meta_mapper;

/
