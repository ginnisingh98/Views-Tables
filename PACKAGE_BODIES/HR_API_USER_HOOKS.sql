--------------------------------------------------------
--  DDL for Package Body HR_API_USER_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_USER_HOOKS" as
/* $Header: hrusrhok.pkb 120.0 2005/05/31 03:41:29 appldev noship $ */
--
-- Type Definitions
--
type tbl_parameter_name     is table of varchar2(30) index by binary_integer;
type tbl_parameter_datatype is table of number       index by binary_integer;
--
-- Error Exceptions which can be raised by dbms_describe.describe_procedure
--
  --
  -- Package does not exist in the database
  --
  Package_Not_Exists  exception;
  Pragma Exception_Init(Package_Not_Exists, -6564);
  --
  -- Procedure does not exist in the package
  --
  Proc_Not_In_Package  exception;
  Pragma Exception_Init(Proc_Not_In_Package, -20001);
  --
  -- Object is remote
  --
  Remote_Object  exception;
  Pragma Exception_Init(Remote_Object, -20002);
  --
  -- Package is invalid
  --
  Invalid_Package  exception;
  Pragma Exception_Init(Invalid_Package, -20003);
  --
  -- Invalid Object Name
  --
  Invalid_Object_Name  exception;
  Pragma Exception_Init(Invalid_Object_Name, -20004);
--
-- Other Error Exceptions
--
Plsql_Value_Error  exception;
Pragma Exception_Init(Plsql_Value_Error, -6502);
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_api_user_hooks.';
--
g_source         varchar2(32767);
g_error_expected boolean;
--
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
c_dtype_undefined constant number      default   0;
c_dtype_varchar2  constant number      default   1;
c_dtype_number    constant number      default   2;
c_dtype_long      constant number      default   8;
c_dtype_date      constant number      default  12;
c_dtype_boolean   constant number      default 252;
--
c_ptype_in        constant number      default   0;
--
c_default_defined constant number      default   1;
--
c_new_line        constant varchar2(1) default '
';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< clear_source >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Clears the source code store and when a package body creation error
--   is expected. Should be called when starting to define a new package body.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   The internal source and expected error stores are set to reset.
--
-- Post Failure:
--   The internal source and expected error stores are set to reset.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure clear_source is
  l_proc                varchar2(72) := g_package||'clear_source';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  g_source         := null;
  g_error_expected := false;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end clear_source;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< add_to_source >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Appends the specified source code to the end of the existing source code.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_text                         Yes  varchar2 Source code to add to the
--                                                existing store.
--
-- Post Success:
--   The extra source code is added to the existing code.
--
-- Post Failure:
--   If the source code size limit is exceeded then an application error
--   message is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure add_to_source
  (p_text                          in     varchar2
  ) is
  l_proc                varchar2(72) := g_package||'add_to_source';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  g_source := g_source || p_text;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when Plsql_Value_Error then
    -- Trap attempts to create more than 32K of package body source code.
    --
    -- Error: ORA-06502: PL/SQL: numeric or value error. Check whether you
    -- are attempting to create API hook package source code greater than 32K
    -- in size. If so, reduce the number of procedures which need to be
    -- called for this API module. The module will not execute until this
    -- problem is resolved.
    --
    hr_utility.set_message(800, 'HR_51940_AHC_PACK_TOO_LARGE');
    hr_utility.raise_error;
end add_to_source;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< error_expected >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Notes an important user hook error has already occurred. The
--   "INVALID_SEE_COMMENT_IN_SOURCE" text has been added to the source code
--   to deliberately stop the package body from compiling.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   Notes an error at execution time is expected.
--
-- Post Failure:
--   Notes an error at execution time is expected.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure error_expected
  is
  l_proc                varchar2(72) := g_package||'error_expected';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  g_error_expected := true;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end error_expected;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< execute_source >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Executes the 'create or replace package body...' statement which has
--   been built-up in source code store.
--
-- Prerequisites:
--   The complete valid package body source code has been placed in the source
--   store by calling the 'add_to_source' procedure one or more times.
--
-- In Parameters:
--   None
--
-- Post Success:
--   The extra source code created in the database.
--
-- Post Failure:
--   The extra source code will not be created in the database. In some cases
--   the package body source code will be created in the database, but will be
--   marked as invalid.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure execute_source is
  l_dynamic_cursor         integer;          -- Dynamic sql cursor
  l_execute                integer;          -- Value returned by
                                             -- dbms_sql.execute
  l_proc                   varchar2(72) := g_package||'execute_source';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- The whole of the new package body code has now been built,
  -- use dynamic SQL to execute the create or replace package statement
  --
  l_dynamic_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_dynamic_cursor, g_source, dbms_sql.v7);
  l_execute := dbms_sql.execute(l_dynamic_cursor);
  dbms_sql.close_cursor(l_dynamic_cursor);
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  --
  -- In case of an unexpected error close the dynamic cursor
  -- if it was successfully opened.
  --
  when others then
    if (dbms_sql.is_open(l_dynamic_cursor)) then
      dbms_sql.close_cursor(l_dynamic_cursor);
    end if;
    --
    -- If a compilation error is expected then sliently trap the error.
    -- A user hook specific error has already been logged in the
    -- hr_api_hook table.
    --
    if not g_error_expected then
      raise;
    end if;
end execute_source;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_param_in_hook_proc_call >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that a parameter exists in the hook package procedure, the
--   parameter has the same datatype and there are no overloaded versions.
--   If the parameter should be on a procedure checks the call is not to a
--   function. If an error is found AOL error details are set but a PL/SQL
--   exception is not raised. This function should be used when checking
--   hook procedure calls. 'chk_param_in_hook_leg_func' should be
--   used when checking return_legislation_code function parameters.
--
-- Prerequisites:
--   p_number_of_parameters, p_hook_parameter_names and
--   p_hook_parameter_datatypes are set with details of the hook package
--   procedure parameter details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_call_parameter_name          Yes  varchar2 Parameter in the procedure to
--                                                be called.
--   p_call_parameter_datatype      Yes  number   The internal code for the
--                                                parameter datatype.
--   p_call_parameter_in_out        Yes  number   The internal code for the
--                                                parameter IN/OUT type.
--   p_call_parameter_overload      Yes  number   The overload number for the
--                                                call procedure parameter.
--   p_previous_overload            Yes  number   The overload number for the
--                                                previous parameter on the
--                                                call procedure.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Returns true.
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--   function returns false the error has not been raised. It is up to the
--   calling logic to raise or process the error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function chk_param_in_hook_proc_call
  (p_call_parameter_name           in     varchar2
  ,p_call_parameter_datatype       in     number
  ,p_call_parameter_in_out         in     number
  ,p_call_parameter_overload       in     number
  ,p_previous_overload             in     number
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) return boolean is
  l_loop             number;            -- Loop counter
  l_para_found       boolean;           -- Indicates if the parameter has been
                                        -- found in the hook parameter list.
  l_para_valid       boolean;           -- Indicates if parameter is valid.
  l_proc             varchar2(72) := g_package||'chk_param_in_hook_proc_call';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Assume the parameter is valid until an error is found
  --
  l_para_valid := true;
  --
  -- Validate the call does not have any overload versions by
  -- checking that the overload number for the current parameter is the
  -- same as the previous parameter.
  --
  if p_call_parameter_overload <> p_previous_overload then
    -- Error: A call package procedure cannot have any PL/SQL overloaded
    -- versions. Code to carry out this hook call has not been created.
    hr_utility.set_message(800, 'HR_51941_AHC_CALL_NO_OVER');
    hr_utility.set_location(l_proc, 20);
    l_para_valid := false;
  --
  -- Check the argument name has been set. If it is not set the entry
  -- returned from hr_general.describe_procedure is for a function
  -- return value. Package functions should not be called.
  --
  elsif p_call_parameter_name is null then
    -- Error: A package function cannot be called. Only package procedures
    -- can be called. Code to carry out this hook call has not been created.
    hr_utility.set_message(800, 'HR_51942_AHC_NO_FUNCTIONS');
    hr_utility.set_location(l_proc, 30);
    l_para_valid := false;
  else
    --
    l_para_found := false;
    l_loop       := 0;
    hr_utility.set_location(l_proc, 40);
    --
    -- Keep searching through the parameter names table until the parameter
    -- name is found or the end of the list has been reached.
    --
    while (not l_para_found) and (l_loop < p_number_of_parameters) loop
      l_loop := l_loop + 1;
      if p_hook_parameter_names(l_loop) = p_call_parameter_name then
        l_para_found := true;
      end if;
    end loop;  -- end of while loop
    hr_utility.set_location(l_proc, 50);
    --
    -- If the parameter has been found carry out further parameter checks
    --
    if l_para_found then
      --
      -- Check the datatype of the parameter is the same
      -- as the parameter in the hook package.
      --
      if p_hook_parameter_datatypes(l_loop) <> p_call_parameter_datatype then
        -- Error: The *PARAMETER parameter to the call procedure must
        -- have the same datatype as the value available at the hook.
        -- Code to carry out this hook call has not been created.
        hr_utility.set_message(800, 'HR_51943_AHC_CALL_PARA_D_TYPE');
        hr_utility.set_message_token('PARAMETER', p_call_parameter_name);
        hr_utility.set_location(l_proc, 60);
        l_para_valid := false;
      --
      -- Check that the parameter to the call
      -- package procedure is of type IN
      --
      elsif p_call_parameter_in_out <> 0 then
        -- Error: At least one OUT or IN/OUT parameter has been specified
        -- on the call procedure. You can only use IN parameters. Code to
        -- carry out this hook call has not been created.
        hr_utility.set_message(800, 'HR_51944_AHC_CALL_ONLY_IN_PARA');
        hr_utility.set_location(l_proc, 70);
        l_para_valid := false;
      end if;
    else
      --
      -- The parameter in the call package procedure could not be
      -- found in the hook package procedure parameter list.
      --
      -- Error: There is a parameter to the call procedure which is not
      -- available at this hook. Check your call procedure parameters.
      -- Code to carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51945_AHC_CALL_NO_PARA');
      hr_utility.set_location(l_proc, 80);
      l_para_valid := false;
    end if;
  end if;
  --
  -- Return the parameter status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  return l_para_valid;
end chk_param_in_hook_proc_call;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_param_in_hook_leg_func >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that a parameter exists in the hook package procedure, the
--   parameter has the same datatype and there are no overloaded versions.
--   If the parameter should be on a procedure checks the call is not to a
--   function. If an error is found AOL error details are set but a PL/SQL
--   exception is not raised. This procedure should be used when checking
--   return_legislation_code function parameters. The
--   'chk_param_in_hook_proc_call' function should be used when checking
--   hook procedure call parameters.
--
-- Prerequisites:
--   p_number_of_parameters, p_hook_parameter_names and
--   p_hook_parameter_datatypes are set with details of the hook package
--   procedure parameter details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_call_parameter_name          Yes  varchar2 Parameter in the procedure to
--                                                be called.
--   p_call_parameter_datatype      Yes  number   The internal code for the
--                                                parameter datatype.
--   p_call_parameter_in_out        Yes  number   The internal code for the
--                                                parameter IN/OUT type.
--   p_call_parameter_overload      Yes  number   The overload number for the
--                                                call procedure parameter.
--   p_previous_overload            Yes  number   The overload number for the
--                                                previous parameter on the
--                                                call procedure.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Name                           Type     Description
--   p_parameter_valid              boolean  Set to TRUE a parameter name
--                                           match was found and other checks
--                                           were valid.
--   p_hook_parameter_name          varchar2 Set to the name of the parameter
--                                           which was matched. Either the
--                                           same as p_call_parameter_name or
--                                           the p_call_parameter_name _O
--                                           version.
--
-- Post Failure:
--   Name                           Type     Description
--   p_parameter_valid              boolean  Set to FALSE when a parameter
--                                           name match could not be found or
--                                           when other parameter validation
--                                           failed. Details of the error are
--                                           added to the AOL message stack,
--                                           but no PL/SQL exception is raised.
--                                           It is up to the calling logic to
--                                           raise or process the error.
--   p_hook_parameter_name          varchar2 Set to the NULL.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_param_in_hook_leg_func
  (p_call_parameter_name           in     varchar2
  ,p_call_parameter_datatype       in     number
  ,p_call_parameter_in_out         in     number
  ,p_call_parameter_overload       in     number
  ,p_previous_overload             in     number
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ,p_parameter_valid                  out nocopy boolean
  ,p_hook_parameter_name              out nocopy varchar2
  ) is
  l_loop                 number;        -- Loop counter
  l_find_parameter_name  varchar2(32);  -- Name of the parameter to search
                                        -- for in the hook procedure parameter
                                        -- list. Deliberately created as 32
                                        -- characters to allow for appending
                                        -- '_O'.
  l_para_found           boolean;       -- Indicates if the parameter has been
                                        -- found in the hook parameter list.
  l_para_valid           boolean;       -- Indicates if parameter is valid.
  l_proc              varchar2(72) := g_package||'chk_param_in_hook_leg_func';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Assume the parameter is valid until an error is found
  --
  l_para_valid := true;
  --
  -- Validate the call does not have any overload versions by
  -- checking that the overload number for the current parameter is the
  -- same as the previous parameter.
  --
  if p_call_parameter_overload <> p_previous_overload then
    -- Error: A legislation package function cannot have any PL/SQL
    -- overloaded versions. This API module will not execute until this
    -- problem has been resolved.
    hr_utility.set_message(800, 'HR_51946_AHK_LEG_NO_OVER');
    hr_utility.set_location(l_proc, 20);
    l_para_valid := false;
  else
    --
    l_find_parameter_name := p_call_parameter_name;
    l_para_found          := false;
    l_loop                := 0;
    hr_utility.set_location(l_proc, 30);
    --
    -- Keep searching through the parameter names table until the parameter
    -- name is found or the end of the list has been reached.
    --
    while (not l_para_found) and (l_loop < p_number_of_parameters) loop
      l_loop := l_loop + 1;
      if p_hook_parameter_names(l_loop) = l_find_parameter_name then
        l_para_found := true;
      end if;
    end loop;  -- end of while loop
    hr_utility.set_location(l_proc, 40);
    --
    -- If the parameter was not found attempt to search through the list
    -- again. Except this time looking for the parameter with _O on the
    -- end. There is no need to handle the case where the parameter name
    -- is already greater than 28 characters in length. The local
    -- variable is 32 characters in length, the search will fail and the
    -- HR_51949_AHK_LEG_NO_PARA error will be correctly raised later in
    -- this procedure.
    --
    if not l_para_found then
      hr_utility.set_location(l_proc, 50);
      l_find_parameter_name := p_call_parameter_name || '_O';
      l_loop                := 0;
      while (not l_para_found) and (l_loop < p_number_of_parameters) loop
        l_loop := l_loop + 1;
        if p_hook_parameter_names(l_loop) = l_find_parameter_name then
          l_para_found := true;
        end if;
      end loop; -- end of while loop
    end if;
    hr_utility.set_location(l_proc, 60);
    --
    -- If the parameter has been found carry out further parameter checks
    --
    if l_para_found then
      --
      -- Check the datatype of the parameter is the same as the parameter
      -- in the hook package.
      --
      if p_hook_parameter_datatypes(l_loop) <> p_call_parameter_datatype then
        -- Error: The *PARAMETER parameter to the legislation function must
        -- have the same datatype as the value available at the hook. This
        -- API module will not execute until this problem has been resolved.
        hr_utility.set_message(800, 'HR_51947_AHK_LEG_PARA_D_TYPE');
        hr_utility.set_message_token('PARAMETER', p_call_parameter_name);
        hr_utility.set_location(l_proc, 70);
        l_para_valid := false;
      --
      -- Check that the parameter to the call package function is
      -- of type IN
      --
      elsif p_call_parameter_in_out <> 0 then
        -- Error: All the parameters to the legislation function must be
        -- IN parameters. OUT or IN/OUT parameters are not allowed. This
        -- API module will not execute until this problem has been resolved.
        hr_utility.set_message(800, 'HR_51948_AHK_LEG_ONLY_IN_PARA');
        hr_utility.set_location(l_proc, 80);
        l_para_valid := false;
      end if;
    else
      --
      -- The parameter in the call function could not be
      -- found in the hook package procedure parameter list.
      --
      -- Error: There is a parameter to the legislation function which
      -- is not available at this hook. This API module will not execute
      -- until this problem has been resolved.
      hr_utility.set_message(800, 'HR_51949_AHK_LEG_NO_PARA');
      hr_utility.set_location(l_proc, 90);
      l_para_valid := false;
    end if;
  end if;
  hr_utility.set_location(l_proc, 100);
  --
  -- Pass out the parameter status values
  --
  if l_para_valid then
    p_hook_parameter_name := l_find_parameter_name;
  else
    p_hook_parameter_name := null;
  end if;
  p_parameter_valid := l_para_valid;
  hr_utility.set_location(' Leaving:'||l_proc, 110);
end chk_param_in_hook_leg_func;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< make_procedure_call >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to call another procedure.
--
-- Prerequisites:
--   p_number_of_parameters, p_hook_parameter_names and
--   p_hook_parameter_datatypes are set with details of the hook package
--   procedure parameter details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_call_id             Yes  number   ID of the hook call.
--   p_object_version_number        Yes  number   OVN of the hook call.
--   p_call_package                 Yes  varchar2 Name of the package to call.
--   p_call_procedure               Yes  varchar2 Name of the procedure within
--                                                p_call_package to call.
--   p_when_error_invalid_code      Yes  boolean  When an error is detected
--                                                this parameter indicates
--                                                if invalid code should be
--                                                deliberately created. Set
--                                                to true for application
--                                                and legislation calls.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code for one package procedure call.
--
-- Post Failure:
--   Details of any application errors and some Oracle errors are written
--   to the HR_API_HOOK_CALLS table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_procedure_call
  (p_api_hook_call_id              in     number
  ,p_object_version_number         in     number
  ,p_call_package                  in     varchar2
  ,p_call_procedure                in     varchar2
  ,p_when_error_invalid_code       in     boolean
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) is
  --
  -- Local variables to catch the values returned from
  -- hr_general.describe_procedure
  --
  l_overload            dbms_describe.number_table;
  l_position            dbms_describe.number_table;
  l_level               dbms_describe.number_table;
  l_argument_name       dbms_describe.varchar2_table;
  l_datatype            dbms_describe.number_table;
  l_default_value       dbms_describe.number_table;
  l_in_out              dbms_describe.number_table;
  l_length              dbms_describe.number_table;
  l_precision           dbms_describe.number_table;
  l_scale               dbms_describe.number_table;
  l_radix               dbms_describe.number_table;
  l_spare               dbms_describe.number_table;
  --
  -- Other local variables
  --
  l_loop                binary_integer;    -- Loop counter.
  l_pre_overload        number;            -- Overload number for the previous
                                           -- parameter.
  l_param_valid         boolean := true;   -- Indicates if the current
                                           -- parameter is valid for this hook.
  l_describe_error      boolean := false;  -- Indicates if the hr_general.
                                           -- describe_procedure raised an
                                           -- error for the call package
                                           -- procedure.
  l_encoded_err_text    varchar2(2000);    -- Set to the encoded error text
                                           -- when an error is written to the
                                           -- HR_API_HOOK_CALLS table.
  l_call_code           varchar2(32767) := null;
  l_proc                varchar2(72) := g_package||'make_procedure_call';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Call an RDMS procedure to obtain the list of parameters to the call
  -- package procedure. A separate begin ... end block has been specified so
  -- that errors raised by hr_general.describe_procedure can be trapped and
  -- handled locally.
  --
  begin
    hr_general.describe_procedure
      (object_name   => p_call_package || '.' || p_call_procedure
      ,reserved1     => null
      ,reserved2     => null
      ,overload      => l_overload
      ,position      => l_position
      ,level         => l_level
      ,argument_name => l_argument_name
      ,datatype      => l_datatype
      ,default_value => l_default_value
      ,in_out        => l_in_out
      ,length        => l_length
      ,precision     => l_precision
      ,scale         => l_scale
      ,radix         => l_radix
      ,spare         => l_spare
      );
  exception
    when Package_Not_Exists then
      -- Error: The call_package does not exist in the database. Code to
      -- carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51950_AHC_CALL_PKG_NO_EXIST');
      l_describe_error := true;
      hr_utility.set_location(l_proc, 20);
    when Proc_Not_In_Package then
      -- Error: The call_procedure does not exist in the call_package.
      -- Code to carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51951_AHC_CALL_PRO_NO_EXIST');
      l_describe_error := true;
      hr_utility.set_location(l_proc, 30);
    when Remote_Object then
      -- Error: Remote objects cannot be called from API User Hooks.
      -- Code to carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51952_AHC_CALL_REMOTE_OBJ');
      l_describe_error := true;
      hr_utility.set_location(l_proc, 40);
    when Invalid_Package then
      -- Error: The call_package code in the database is invalid.
      -- Code to carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51953_AHC_CALL_PKG_INVALID');
      l_describe_error := true;
      hr_utility.set_location(l_proc, 50);
    when Invalid_Object_Name then
      -- Error: An error has occurred while attempting to parse the name of
      -- the call package and call procedure. Check the package and procedure
      -- names. Code to carry out this hook call has not been created.
      hr_utility.set_message(800, 'HR_51954_AHC_CALL_PARSE');
      l_describe_error := true;
      hr_utility.set_location(l_proc, 60);
  end;
  hr_utility.set_location(l_proc, 70);
  --
  -- Only carry out the parameter validation if
  -- hr_general.describe_procedure did not raise an error.
  --
  if not l_describe_error then
    --
    -- If the first parameter in the list has a data type of 'UNDEFINED'
    -- then there are no parameters to the calling procedure.
    --
    if l_datatype(1) = c_dtype_undefined then
      --
      -- Build calling code with no parameters
      --
      l_call_code := p_call_package || '.' || p_call_procedure || ';';
      l_call_code := l_call_code || c_new_line;
      hr_utility.set_location(l_proc, 80);
    else
      --
      -- Build calling code with parameters
      --
      l_call_code := p_call_package || '.' || p_call_procedure || c_new_line;
      hr_utility.set_location(l_proc, 90);
      --
      -- Search through the tables returned to create the parameter list
      --
      l_loop         := 1;
      l_pre_overload := l_overload(1);
      begin
        --
        -- There is separate PL/SQL block for reading from the PL/SQL tables.
        -- We do not know how many parameters exist. So we have to keep reading
        -- from the tables until PL/SQL finds a row when has not been
        -- initialised and raises a NO_DATA_FOUND exception or an invalid
        -- parameter is found.
        --
        while l_param_valid loop
          --
          -- Check that the parameter to the package procedure to be
          -- called exists on the hook package procedure, it is of the same
          -- datatype, the code to call is not a function and there are no
          -- overload versions.
          --
          l_param_valid := chk_param_in_hook_proc_call
            (p_call_parameter_name      => l_argument_name(l_loop)
            ,p_call_parameter_datatype  => l_datatype(l_loop)
            ,p_call_parameter_in_out    => l_in_out(l_loop)
            ,p_call_parameter_overload  => l_overload(l_loop)
            ,p_previous_overload        => l_pre_overload
            ,p_number_of_parameters     => p_number_of_parameters
            ,p_hook_parameter_names     => p_hook_parameter_names
            ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
            );
          --
          -- If the parameter is valid add it to the calling code
          --
          if l_param_valid then
            if l_loop = 1 then
              -- This is the first parameter prefix with an opening bracket
              l_call_code := l_call_code || '(';
            else
              -- Have already processed the first parameter. Separate this
              -- parameter from the previous parameter with a ,
              l_call_code := l_call_code || ',';
            end if;
            l_call_code := l_call_code || l_argument_name(l_loop) || ' => ';
            l_call_code := l_call_code || l_argument_name(l_loop);
            l_call_code := l_call_code || c_new_line;
            --
            -- Remember the overload number for the next loop iteration.
            --
            l_pre_overload := l_overload(l_loop);
          end if;
          --
          -- Prepare loop variables for the next iteration
          --
          l_pre_overload := l_overload(l_loop);
          l_loop := l_loop + 1;
        end loop; -- end of while loop
        hr_utility.set_location(l_proc, 100);
      exception
        when no_data_found then
          -- Trap the PL/SQL no_data_found exception. Know we have already
          -- read the details of the last parameter from the tables.
          if l_loop > 1 then
            -- There must have been at least one parameter in the list. End the
            -- parameter list with a closing bracket. The bracket should not be
            -- included when there are zero parameters.
            l_call_code := l_call_code || ');' || c_new_line;
          end if;
      end;
    end if;
    hr_utility.set_location(l_proc, 110);
    --
    if l_param_valid then
      --
      -- If the last parameter processed was valid then all the parameters must
      -- be valid. Add the calling code which has been built-up to the rest of
      -- the source code. Update the HR_API_HOOK_CALLS table to note that the
      -- call has been successfully created.
      --
      add_to_source(l_call_code);
      -- Change the following update statement to
      -- call the row handler, when it is available.
      update hr_api_hook_calls
         set pre_processor_date    = sysdate
           , encoded_error         = null
           , status                = 'V'
           , object_version_number = object_version_number + 1
       where api_hook_call_id      = p_api_hook_call_id
         and object_version_number = p_object_version_number;
    end if;
  end if;
  --
  -- If hr_general.describe_procedure raised an error or the last parameter
  -- processed was invalid then the calling code which has been built-up is
  -- not complete and it should not be added to the rest of the source code.
  -- Either this procedure (for a hr_general.describe_procedure error) or
  -- the chk_param_in_hook_proc_call function (for a parameter error) has set
  -- the AOL message stack will details of the error. The error details should
  -- be written to the HR_API_HOOK_CALLS using the encoded format. Some comment
  -- text and a 'null' statement should be added to the hook package body
  -- source code to show there is a problem.
  --
  if l_describe_error or (not l_param_valid) then
    --
    -- Get the encoded error text
    --
    l_encoded_err_text := fnd_message.get_encoded;
    -- Change the following update DML statement to
    -- call the API when it is available.
    update hr_api_hook_calls
       set pre_processor_date    = sysdate
         , encoded_error         = l_encoded_err_text
         , status                = 'I'
         , object_version_number = object_version_number + 1
     where api_hook_call_id      = p_api_hook_call_id
       and object_version_number = p_object_version_number;
    --
    -- Add comment and null; statement to the hook package source code
    --
    add_to_source('-- The call to ' || p_call_package || '.');
    add_to_source(p_call_procedure || c_new_line);
    add_to_source('-- has not been created due to an error.' || c_new_line);
    add_to_source('-- Details of the error, in FND encoded format, can ');
    add_to_source('be obtained' || c_new_line);
    add_to_source('-- with the following sql statement:' || c_new_line);
    add_to_source('--  select c.encoded_error' || c_new_line);
    add_to_source('--    from hr_api_hook_calls c' || c_new_line);
    add_to_source('--   where c.api_hook_call_id = ');
    add_to_source(to_char(p_api_hook_call_id) || ';' || c_new_line);
    add_to_source('null;' || c_new_line);
    --
    -- When required add invalid code to force investigation of the problem
    --
    if p_when_error_invalid_code then
      error_expected;
      add_to_source('-- The following invalid code has been deliberately ');
      add_to_source('created to force' || c_new_line);
      add_to_source('-- investigation and resolution of this problem.');
      add_to_source(c_new_line);
      add_to_source('INVALID_SEE_COMMENT_IN_SOURCE;' || c_new_line);
    end if;
    hr_utility.set_location(l_proc, 120);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 130);
end make_procedure_call;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< make_leg_function_call >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to populate the l_legislation_code variable with
--   a call to a specified legislation package function.
--
-- Prerequisites:
--   The p_legislation_package and p_legislation_function parameters must both
--   contain not null values when this procedure is called.
--   The start of the hook procedure source code has already been created.
--   The if statement to enable legislation hook calls to be switched
--   off has been opened but not closed. This function assumes the
--   l_legislation_code variable has been declared in the hook package
--   procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_legislation_package          Yes  varchar2 The legislation_package as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_legislation_function         Yes  varchar2 The legislation_function as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
-- Post Success:
--   Creates source code to populate the l_legislation_code variable with the
--   legislation package function return value. Then this function returns
--   true to indicate the code was successfully created.
--
-- Post Failure:
--   An application error message is placed on the AOL message stack, but
--   a PL/SQL exception is not raised. This function then returns false to
--   indicate the code was not created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function make_leg_function_call
  (p_api_hook_id                   in     number
  ,p_legislation_package           in     varchar2
  ,p_legislation_function          in     varchar2
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) return boolean is
  --
  -- Local variables to catch the values returned from
  -- hr_general.describe_procedure
  --
  l_overload            dbms_describe.number_table;
  l_position            dbms_describe.number_table;
  l_level               dbms_describe.number_table;
  l_argument_name       dbms_describe.varchar2_table;
  l_datatype            dbms_describe.number_table;
  l_default_value       dbms_describe.number_table;
  l_in_out              dbms_describe.number_table;
  l_length              dbms_describe.number_table;
  l_precision           dbms_describe.number_table;
  l_scale               dbms_describe.number_table;
  l_radix               dbms_describe.number_table;
  l_spare               dbms_describe.number_table;
  --
  -- Other local variables
  --
  l_loop                number;            -- Loop counter
  l_err_found           boolean := false;  -- Indicates if an error has been
                                           -- found and a message has been
                                           -- placed on the AOL message stack.
  l_param_valid         boolean;           -- Indicates if the
                                           -- chk_param_in_hook_leg_func
                                           -- procedure found the current
                                           -- l_loop parameter was valid.
  l_hook_parameter_name varchar2(30);      -- Parameter matched by
                                           -- chk_param_in_hook_leg_func.
                                           -- Either exactly the same parameter
                                           -- name or the _O version.
  l_call_code           varchar2(1000);    -- The code to call the legislation
                                           -- package function.
  l_pre_overload        number;            -- Overload number for the previous
                                           -- parameter.
  l_proc                varchar2(72) := g_package||'make_leg_function_call';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Build the code to call the specified legislation package function.
  -- Call an RDMS procedure to obtain the list of parameters to the
  -- legislation package function. A separate begin ... end block has been
  -- specified so that errors raised by hr_general.describe_procedure can
  -- be trapped and handled locally.
  --
  begin
    hr_general.describe_procedure
      (object_name   => p_legislation_package || '.' ||
                        p_legislation_function
      ,reserved1     => null
      ,reserved2     => null
      ,overload      => l_overload
      ,position      => l_position
      ,level         => l_level
      ,argument_name => l_argument_name
      ,datatype      => l_datatype
      ,default_value => l_default_value
      ,in_out        => l_in_out
      ,length        => l_length
      ,precision     => l_precision
      ,scale         => l_scale
      ,radix         => l_radix
      ,spare         => l_spare
      );
  exception
    when Package_Not_Exists then
      -- Error: The legislation_package does not exist in the database.
      -- This API module will not execute until this problem has been resolved.
      hr_utility.set_message(800, 'HR_51955_AHK_LEG_PKG_NO_EXIST');
      l_err_found := true;
      hr_utility.set_location(l_proc, 20);
    when Proc_Not_In_Package then
      -- Error: The legislation_function does not exist in the
      -- legislation_package. This API module will not execute until this
      -- problem has been resolved.
      hr_utility.set_message(800, 'HR_51956_AHK_LEG_FUN_NO_EXIST');
      l_err_found := true;
      hr_utility.set_location(l_proc, 30);
    when Remote_Object then
      -- Error: Remote objects cannot be called to find out the legislation
      -- code. This API module will not execute until this problem has been
      -- resolved.
      hr_utility.set_message(800, 'HR_51957_AHK_LEG_REMOTE_OBJ');
      l_err_found := true;
      hr_utility.set_location(l_proc, 40);
    when Invalid_Package then
      -- Error: The legislation_package code in the database is invalid.
      -- This API module will not execute until this problem has been resolved.
      hr_utility.set_message(800, 'HR_51958_AHK_LEG_PKG_INVALID');
      l_err_found := true;
      hr_utility.set_location(l_proc, 50);
    when Invalid_Object_Name then
      -- Error: An error has occurred while attempting to parse the name of
      -- the legislation package and legislation function. Check the package
      -- and function names. This API module will not execute until this
      -- problem has been resolved.
      hr_utility.set_message(800, 'HR_51959_AHK_LEG_PARSE');
      l_err_found := true;
      hr_utility.set_location(l_proc, 60);
  end;
  hr_utility.set_location(l_proc, 70);
  --
  -- Only carry out the parameter validation if
  -- hr_general.describe_procedure did not raise an error.
  --
  if not l_err_found then
    --
    -- Ensure the legislation package function is really a function, and not
    -- a procedure, by checking the first parameter name returned by
    -- hr_general.describe_procedure is blank.
    --
    if l_argument_name(1) is not null then
      -- Error: The legislation function can only be a function. It cannot be
      -- a procedure. This API module will not execute until this problem has
      -- been resolved.
      hr_utility.set_message(800, 'HR_51965_AHK_LEG_MUST_FUN');
      l_err_found := true;
      hr_utility.set_location(l_proc, 80);
    --
    -- Ensure the function return datatype is varchar2.
    --
    elsif l_datatype(1) <> c_dtype_varchar2 then
      -- Error: The legislation function must return a varchar2 value. This
      -- API module will not execute until this problem has been resolved.
      hr_utility.set_message(800, 'HR_51966_AHK_LEG_RTN_VARCHAR');
      l_err_found := true;
      hr_utility.set_location(l_proc, 90);
    end if;
    hr_utility.set_location(l_proc, 100);
    if not l_err_found then
      --
      -- Build the function call and parameter list. Checking that the
      -- required parameters are available in the hook package procedure.
      -- (Details of the first parameter returned by
      -- hr_general.describe_procedure are not passed to the
      -- chk_param_in_hook_leg_func procedure. If it was passed
      -- across an error would be raised.
      --
      l_call_code := 'l_legislation_code := ' || p_legislation_package || '.';
      l_call_code := l_call_code || p_legislation_function;
      hr_utility.set_location(l_proc, 110);
      --
      -- Search through the tables returned to create the parameter list
      --
      l_loop         := 2;
      l_pre_overload := l_overload(2);
      l_param_valid  := true;
      begin
        --
        -- There is separate PL/SQL block for reading from the PL/SQL tables.
        -- We do not know how many parameters exist. So we have to keep reading
        -- from the tables until PL/SQL finds a row which has not been
        -- initialised and raises a NO_DATA_FOUND exception or an invalid
        -- parameter is found.
        --
        while l_param_valid loop
          --
          -- Check that the parameter to the legislation function exists
          -- in the hook package procedure, it is of the same datatype
          -- and there are no overloaded versions.
          --
          chk_param_in_hook_leg_func
            (p_call_parameter_name      => l_argument_name(l_loop)
            ,p_call_parameter_datatype  => l_datatype(l_loop)
            ,p_call_parameter_in_out    => l_in_out(l_loop)
            ,p_call_parameter_overload  => l_overload(l_loop)
            ,p_previous_overload        => l_pre_overload
            ,p_number_of_parameters     => p_number_of_parameters
            ,p_hook_parameter_names     => p_hook_parameter_names
            ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
            ,p_parameter_valid          => l_param_valid
            ,p_hook_parameter_name      => l_hook_parameter_name
            );
          if l_param_valid then
            --
            -- If the parameter is valid add it to the calling code
            --
            if l_loop = 2 then
              -- This is the first parameter prefix with an opening bracket
              l_call_code := l_call_code || '(';
            else
              -- Have already processed the first parameter. Separate this
              -- parameter from the previous parameter with a ,
              l_call_code := l_call_code || ',';
            end if;
            l_call_code := l_call_code || l_argument_name(l_loop) || ' => ';
            l_call_code := l_call_code || l_hook_parameter_name;
            l_call_code := l_call_code || c_new_line;
          else
            --
            -- If the parameter is invalid remember than an error has occurred
            -- Note: When this occurs the chk_param_in_hook function will
            -- have already placed an error message on the AOL message stack.
            --
            l_err_found := true;
          end if;
          --
          -- Prepare loop variables for the next iteration
          --
          l_pre_overload := l_overload(l_loop);
          l_loop         := l_loop + 1;
        end loop; -- end of while loop
        hr_utility.set_location(l_proc, 120);
      exception
        when no_data_found then
          -- Trap the PL/SQL no_data_found exception. Know we have already
          -- read the details of the last parameter from the tables.
          if l_loop > 2 then
            -- There must have been at least one parameter in the list. End the
            -- parameter list with a closing bracket. The bracket should not be
            -- included when there are zero parameters. Note: The loop counter
            -- check is for 2 and not 1 because the first entry in the
            -- parameter list details the function return datatype.
            l_call_code := l_call_code || ');' || c_new_line;
          end if;
      end;
    end if;
    hr_utility.set_location(l_proc, 130);
    --
    -- If no errors have been found then all the parameters must be valid.
    -- Add the find legislation source code to the rest of the hook package
    -- source code.
    --
    if not l_err_found then
      add_to_source(l_call_code);
    end if;
    hr_utility.set_location(l_proc, 140);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 150);
  return not l_err_found;
end make_leg_function_call;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< make_leg_bus_grp_call >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to populate the l_legislation_code variable with
--   a call to hr_api.return_legislation_code. Only generates the code if
---  the p_business_group_id or p_business_group_id_o parameter, with a
--   number datatype, is available at the current hook.
--
-- Prerequisites:
--   This procedure must NOT be called when the data for this API module is
--   outside the context of a business_group_id.
--   The start of the hook procedure source code has already been created.
--   The if statement to enable legislation hook calls to be switched
--   off has been opened but not closed. This function assumes the
--   l_legislation_code variable has been declared in the hook package
--   procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code to populate the hook package, l_legislation_code
--   variable with the hr_api.return_legislation_code return value. Then this
--   function returns true to indicate the code was successfully created.
--
-- Post Failure:
--   An application error message is placed on the AOL message stack, but
--   a PL/SQL exception is not raised. This function then returns false to
--   indicate the code was not created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function make_leg_bus_grp_call
  (p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) return boolean is
  --
  l_loop                number := 0;       -- Loop counter
  l_bus_grp_found       boolean := false;  -- Indicates if the
                                           -- p_business_group_id or
                                           -- p_business_group_id_o parameter
                                           -- has been found in the hook
                                           -- parameter list.
  l_find_parameter      varchar2(30);      -- Name of the parameter to find.
                                           -- Either p_business_group_id or
                                           -- p_business_group_id_o.
  l_proc                varchar2(72) := g_package||'make_leg_bus_grp_call';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check that the p_business_group_id parameter actually exists in the
  -- hook package procedure parameter list. Search through the parameter
  -- names table until the p_business_group_id parameter is found or the
  -- end of the list has been reached.
  --
  l_find_parameter := 'P_BUSINESS_GROUP_ID';
  while (not l_bus_grp_found) and (l_loop < p_number_of_parameters) loop
    l_loop := l_loop + 1;
    if p_hook_parameter_names(l_loop) = l_find_parameter then
      -- Check the datatype is NUMBER
      if p_hook_parameter_datatypes(l_loop) = c_dtype_number then
        l_bus_grp_found := true;
      end if;
    end if;
  end loop;
  hr_utility.set_location(l_proc, 20);
  --
  -- If the p_business_group_id parameter could not be found then search
  -- through the parameter list again for p_business_group_id_o.
  --
  if not l_bus_grp_found then
    l_find_parameter := 'P_BUSINESS_GROUP_ID_O';
    l_loop           := 0;
    hr_utility.set_location(l_proc, 30);
    while (not l_bus_grp_found) and (l_loop < p_number_of_parameters) loop
      l_loop := l_loop + 1;
      if p_hook_parameter_names(l_loop) = l_find_parameter then
        -- Check the datatype is NUMBER
        if p_hook_parameter_datatypes(l_loop) = c_dtype_number then
          l_bus_grp_found := true;
        end if;
      end if;
    end loop;
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  -- If the p_business_group_id or p_business_group_id_o number parameter
  -- has been found then generate a call to the hr_api.return_legislation_code
  -- function. Otherwise place an error message on the AOL message stack.
  --
  if l_bus_grp_found then
    add_to_source('l_legislation_code := hr_api.return_legislation_code');
    add_to_source('(p_business_group_id => ' || l_find_parameter);
    add_to_source(');' || c_new_line);
    hr_utility.set_location(l_proc, 50);
  else
    -- Error: The legislation specific code cannot be called from this hook.
    -- The legislation package function has not been specified in the
    -- HR_API_HOOKS table, and the business_group_id value is not available
    -- at this hook. This API module will not execute until this problem has
    -- been resolved.
    hr_utility.set_message(800, 'HR_51967_AHK_LEG_NO_SPECIFIC');
    hr_utility.set_location(l_proc, 60);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  return l_bus_grp_found;
end make_leg_bus_grp_call;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< make_find_legislation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to populate the l_legislation_code variable with
--   the current legislation code.
--
-- Prerequisites:
--   This procedure must NOT be called when the data for this API module is
--   outside the context of a business_group_id.
--   The start of the hook procedure source code has already been created.
--   The if statement to enable legislation hook calls to be switched
--   off has been opened but not closed. This function assumes at least one
--   legislation specific hook call exists and the l_legislation_code variable
--   has been declared in the hook package procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_legislation_package          Yes  varchar2 The legislation_package as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_legislation_function         Yes  varchar2 The legislation_function as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code to populate the l_legislation_code variable with
--   the current legislation code.
--
-- Post Failure:
--   Comment text and invalid code is added to the hook package source code.
--   Invalid code is deliberately included to ensure that the package body
--   does not compile. This will force investigation and resolution of the
--   problem. Details of the error are also written to the HR_API_HOOKS table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_find_legislation
  (p_api_hook_id                   in     number
  ,p_legislation_package           in     varchar2
  ,p_legislation_function          in     varchar2
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) is
  l_code_created     boolean;        -- Indicates if the make_leg_function_call
                                     -- or make_leg_bus_grp_call function has
                                     -- successfully created the code to derive
                                     -- the legislation_code.
  l_encoded_err_text varchar2(2000); -- When an error has occurred set to the
                                     -- AOL encoded error message text.
  l_proc             varchar2(72) := g_package||'make_find_legislation';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Build the source code which will find out the current legislation code
  --
  if (p_legislation_package is not null) and
     (p_legislation_function is not null) then
    --
    -- Build the code to call the specified legislation package function.
    --
    l_code_created := make_leg_function_call
      (p_api_hook_id              => p_api_hook_id
      ,p_legislation_package      => p_legislation_package
      ,p_legislation_function     => p_legislation_function
      ,p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- Otherwise the legislation_package and legislation_function has not
    -- been specified. Attempt to build the code which will use the
    -- p_business_group_id or p_business_group_id_o parameter to find out
    -- the current legislation code.
    --
    l_code_created := make_leg_bus_grp_call
      (p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  if not l_code_created then
    --
    -- The code to derive the legislation code could not be generated then
    -- place details of the error in the HR_API_HOOKS table.
    -- Also generate some invalid code in the hook package body to prevent
    -- the package from compiling. This will force somebody to investigate the
    -- problem and will prevent legislation specific logic from being
    -- by-passed.
    --
    -- It is not necessary to clear hr_api_hooks.encoded_error, from previous
    -- generates because that will have already been done by the
    -- make_parameter_list procedure.
    --
    -- Create comment text in the package body source code
    --
    error_expected;
    add_to_source('-- Code to derive the legislation code could not be ');
    add_to_source('created due to an error.' || c_new_line);
    if (p_legislation_package is not null) and
      (p_legislation_function is not null) then
      add_to_source('-- The call to ' || p_legislation_package || '.');
      add_to_source(p_legislation_function || ' has not been created.');
      add_to_source(c_new_line);
    end if;

    add_to_source('-- Details of the error, in FND encoded format, can ');
    add_to_source('be obtained' || c_new_line);
    add_to_source('-- with the following sql statement:' || c_new_line);
    add_to_source('--  select h.encoded_error' || c_new_line);
    add_to_source('--    from hr_api_hooks h' || c_new_line);
    add_to_source('--   where h.api_hook_id = ' || to_char(p_api_hook_id));
    add_to_source(';' || c_new_line);

    add_to_source('-- The following invalid code has been deliberately ');
    add_to_source('created to force' || c_new_line);
    add_to_source('-- investigation and resolution of this problem.');
    add_to_source(c_new_line);
    add_to_source('INVALID_SEE_COMMENT_IN_SOURCE;' || c_new_line);
    hr_utility.set_location(l_proc, 40);
    --
    -- Write details of the error to the HR_API_HOOKS table
    --
    l_encoded_err_text := fnd_message.get_encoded;
    --
    -- Change the following update statement to
    -- call the row handler, when it is available.
    --
    update hr_api_hooks
       set encoded_error = l_encoded_err_text
     where api_hook_id   = p_api_hook_id;
    hr_utility.set_location(l_proc, 50);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
end make_find_legislation;
--
-- ----------------------------------------------------------------------------
-- |------------------------< make_legislation_calls >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to carry out the legislation specific hook calls
--   or just call the return_legislation_code function.
--
-- Prerequisites:
--   The start of the hook procedure source code has already been created.
--   Up to or after the 'begin' statement. Assumes at least one legislation
--   specific hook call exists or the return_legislation_code function call
--   needs to be created. When data for this module is held within the
--   context of a business_group_id calls are included in an if elsif ladder.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_legislation_package          Yes  varchar2 The legislation_package as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_legislation_function         Yes  varchar2 The legislation_function as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_data_within_business_group   Yes  varchar2 Indicates if the data for
--                                                this module is held within
--                                                the context of a
--                                                business_group_id. From the
--                                                HR_API_MODULES table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code to carry out legislation specific hook calls.
--
-- Post Failure:
--   Any application errors and some system errors are written to the
--   corresponding row in the HR_API_HOOKS or HR_API_HOOK_CALLS tables.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_legislation_calls
  (p_api_hook_id                   in     number
  ,p_legislation_package           in     varchar2
  ,p_legislation_function          in     varchar2
  ,p_data_within_business_group    in     varchar2
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) is
  --
  -- Cursor to obtain the legislation hook call details
  --
  cursor csr_leg_calls is
    select api_hook_call_id
         , object_version_number
         , legislation_code
         , call_package
         , call_procedure
      from hr_api_hook_calls
     where legislation_code is not null
       and enabled_flag     = 'Y'
       and api_hook_id      = p_api_hook_id
     order by legislation_code, sequence;
  --
  l_first_leg_call         boolean;      -- Indicates if the first legislation
                                         -- specific call has been processed
                                         -- for the current hook package
                                         -- procedure.
  l_last_legislation       varchar2(30); -- Remembers which legislation the
                                         -- last specific call was for.
  l_proc                   varchar2(72) := g_package||'make_legislation_calls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Add support call to allow for legislation hook switch off
  --
  add_to_source('if hr_api.call_leg_hooks then' || c_new_line);
  hr_utility.set_location(l_proc, 20);
  --
  -- Build the source code which will find out the current legislation code
  -- when the data is held within the context of a business_group_id
  --
  if p_data_within_business_group = 'Y' then
    make_find_legislation
      (p_api_hook_id              => p_api_hook_id
      ,p_legislation_package      => p_legislation_package
      ,p_legislation_function     => p_legislation_function
      ,p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Build the list of legislation procedure calls
  --
  l_first_leg_call := true;
  for l_leg_calls in csr_leg_calls loop
    if l_first_leg_call then
      --
      -- If this is the first legislation specific call and data for this
      -- module is held within the context of a business_group_id then start
      -- the 'if' statement. Otherwise include some comment text that all
      -- legislation hook calls will be executed regardless of the legislation
      -- code.
      --
      if p_data_within_business_group = 'Y' then
        add_to_source('if l_legislation_code = ' || '''');
        add_to_source(l_leg_calls.legislation_code|| '''' || ' then');
        add_to_source(c_new_line);
      else
        add_to_source('-- Note: All legislation hook calls will be executed ');
        add_to_source('regardless of the' || c_new_line);
        add_to_source('-- legislation code because the data for this API ');
        add_to_source('module is not held within' || c_new_line);
        add_to_source('-- the context of a business_group_id.' || c_new_line);
      end if;
      l_last_legislation := l_leg_calls.legislation_code;
      l_first_leg_call   := false;
    else
      --
      -- If this is not the first legislation specific call, the legislation
      -- has changed since the last call and the data is held within the
      -- context of a business_group_id then create an 'elsif' statement.
      --
      if l_leg_calls.legislation_code <> l_last_legislation then
        if p_data_within_business_group = 'Y' then
          add_to_source('elsif l_legislation_code = ' || '''');
          add_to_source(l_leg_calls.legislation_code|| '''' || ' then');
          add_to_source(c_new_line);
        end if;
        l_last_legislation := l_leg_calls.legislation_code;
      end if;
    end if;
    --
    -- Build the actual procedure call
    --
    make_procedure_call
      (p_api_hook_call_id         => l_leg_calls.api_hook_call_id
      ,p_object_version_number    => l_leg_calls.object_version_number
      ,p_call_package             => l_leg_calls.call_package
      ,p_call_procedure           => l_leg_calls.call_procedure
      ,p_when_error_invalid_code  => true
      ,p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
  end loop;
  hr_utility.set_location(l_proc, 40);
  --
  -- Close the legislation if elsif ladder when the data is held within the
  -- context of a business_group_id and at least one legislation specific
  -- hook call has been made. (The if elsif ladder will not have started when
  -- only the return_legislation_code function is called.)
  --
  if p_data_within_business_group = 'Y' and (not l_first_leg_call) then
    add_to_source('end if;' || c_new_line);
  end if;
  --
  -- Close the support if statement
  --
  add_to_source('end if;' || c_new_line);
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end make_legislation_calls;
--
-- ----------------------------------------------------------------------------
-- |------------------------< make_application_calls >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to carry out the application specific hook calls.
--
-- Prerequisites:
--   The start of the hook procedure source code has already been created.
--   Up to or after the 'begin' statement. Assumes at least one application
--   specific hook call exists.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code to carry out application specific hook calls.
--
-- Post Failure:
--   Any application errors and some system errors are written to the
--   corresponding row in the HR_API_HOOKS or HR_API_HOOK_CALLS tables.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_application_calls
  (p_api_hook_id                   in     number
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) is
  --
  -- Cursor to obtain the application hook call details
  --
  cursor csr_app_calls is
    select ahc.api_hook_call_id
         , ahc.object_version_number
         , ahc.call_package
         , ahc.call_procedure
      from hr_api_hook_calls          ahc
         , fnd_product_installations  fpi
     where ahc.api_hook_id    = p_api_hook_id
       and ahc.enabled_flag   = 'Y'
       and ahc.application_id is not null
       and ahc.application_id = fpi.application_id
       and (   (    ahc.app_install_status IN ('I', 'S')
                and ahc.app_install_status = fpi.status)
            or (    ahc.app_install_status = 'I_OR_S'
                and fpi.status IN ('I', 'S')))
     order by ahc.sequence;
  --
  l_proc                   varchar2(72) := g_package||'make_application_calls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Add support call to allow for application hook switch off
  --
  add_to_source('if hr_api.call_app_hooks then' || c_new_line);
  hr_utility.set_location(l_proc, 20);
  --
  -- Build the list of legislation procedure calls
  --
  for l_app_calls in csr_app_calls loop
    --
    -- Build the actual procedure call
    --
    make_procedure_call
      (p_api_hook_call_id         => l_app_calls.api_hook_call_id
      ,p_object_version_number    => l_app_calls.object_version_number
      ,p_call_package             => l_app_calls.call_package
      ,p_call_procedure           => l_app_calls.call_procedure
      ,p_when_error_invalid_code  => true
      ,p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
  end loop;
  --
  -- Close the support if statement
  --
  add_to_source('end if;' || c_new_line);
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end make_application_calls;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< make_customer_calls >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code to do the customer specific hook calls.
--
-- Prerequisites:
--   The start of the hook procedure source code has already been created.
--   Up to or after the 'begin' statement. p_sequence_number_range must be set
--   to 'LOW', 'HIGH' or 'ALL'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--   p_sequence_number_range        Yes  varchar2 Affects which rows are
--                                                selected from the
--                                                HR_API_HOOK_CALLS table.
--                                                Must be set to 'LOW', 'HIGH'
--                                                or 'ALL'.
--
-- Post Success:
--   Creates source code to carry out customer specific hook calls within the
--   specified sequence number range.
--
-- Post Failure:
--   Any application errors and some Oracle errors are written to the
--   corresponding row in the HR_API_HOOK_CALLS table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_customer_calls
  (p_api_hook_id                   in     number
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ,p_sequence_number_range         in     varchar2
  ) is
  l_dynamic_sql            varchar2(2000); -- Dynamic SQL statement.
  l_dynamic_cursor         integer;        -- Dynamic SQL cursor identifier.
  l_first_cus_call         boolean;        -- Indicates if the first customer
                                           -- specific call has been processed
                                           -- for the current hook package
                                           -- procedure and sequence number
                                           -- range.
  l_execute                integer;        -- Value from dbms_sql.execute
  l_api_hook_call_id       number(15);     -- Value from Dynamic cursor
  l_object_version_number  number(15);     -- Value from Dynamic cursor
  l_call_package           varchar2(30);   -- Value from Dynamic cursor
  l_call_procedure         varchar2(30);   -- Value from Dynamic cursor
  l_proc                   varchar2(72) := g_package||'make_customer_calls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Construct the SQL statement to be used. Dynamic SQL is being used
  -- because the rows to be processed depending on the sequence number
  -- range.
  --
  l_dynamic_sql := 'select api_hook_call_id'                           ||
                   '     , object_version_number'                      ||
                   '     , call_package'                               ||
                   '     , call_procedure'                             ||
                   '  from hr_api_hook_calls'                          ||
                   ' where legislation_code is null'                   ||
                   '   and application_id   is null'                   ||
                   '   and enabled_flag     = ' || '''' || 'Y' || '''' ||
                   '   and api_hook_id      = :p_api_hook_id '         ||
                   ' {sequence_range} '                                ||
                   ' order by legislation_code, sequence';
  --
  -- Set the sequence range
  --
  if p_sequence_number_range = 'ALL' then
    l_dynamic_sql := replace (l_dynamic_sql, '{sequence_range}', null);
  elsif p_sequence_number_range = 'LOW' then
    l_dynamic_sql := replace (l_dynamic_sql, '{sequence_range}'
                             , 'and sequence < 1000'
                             );
  elsif p_sequence_number_range = 'HIGH' then
    l_dynamic_sql := replace (l_dynamic_sql, '{sequence_range}'
                             , 'and sequence > 1999'
                             );
  else
    --
    -- The p_sequence_number_range parameter
    -- has been set to an invalid value.
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  end if;
  --
  -- Execute the Dynamic SQL statement which has been created
  --
  -- Open dynamic cursor
  l_dynamic_cursor := dbms_sql.open_cursor;
  hr_utility.set_location(l_proc, 30);
  --
  -- Parse dynamic SQL
  dbms_sql.parse(l_dynamic_cursor, l_dynamic_sql, dbms_sql.v7);
  hr_utility.set_location(l_proc, 40);
  --
  -- Bind dynamic SQL variable
  dbms_sql.bind_variable(l_dynamic_cursor, ':p_api_hook_id', p_api_hook_id);
  hr_utility.set_location(l_proc, 50);
  --
  -- Define dynamic SQL columns
  dbms_sql.define_column(l_dynamic_cursor, 1, l_api_hook_call_id);
  dbms_sql.define_column(l_dynamic_cursor, 2, l_object_version_number);
  dbms_sql.define_column(l_dynamic_cursor, 3, l_call_package, 30);
  dbms_sql.define_column(l_dynamic_cursor, 4, l_call_procedure, 30);
  hr_utility.set_location(l_proc, 60);
  --
  -- Execute and fetch dynamic SQL
  --
  l_first_cus_call := true;
  l_execute := dbms_sql.execute(l_dynamic_cursor);
  hr_utility.set_location(l_proc, 70);
  while dbms_sql.fetch_rows(l_dynamic_cursor) > 0 loop
    --
    -- Get the column values for the current row
    --
    dbms_sql.column_value(l_dynamic_cursor, 1, l_api_hook_call_id);
    dbms_sql.column_value(l_dynamic_cursor, 2, l_object_version_number);
    dbms_sql.column_value(l_dynamic_cursor, 3, l_call_package);
    dbms_sql.column_value(l_dynamic_cursor, 4, l_call_procedure);
    if l_first_cus_call then
      --
      -- Add support call to allow for customer hook switch off
      --
      add_to_source('if hr_api.call_cus_hooks then' || c_new_line);
      hr_utility.set_location(l_proc, 80);
      l_first_cus_call := false;
    end if;
    --
    -- Build the actual procedure call
    --
    make_procedure_call
      (p_api_hook_call_id         => l_api_hook_call_id
      ,p_object_version_number    => l_object_version_number
      ,p_call_package             => l_call_package
      ,p_call_procedure           => l_call_procedure
      ,p_when_error_invalid_code  => false
      ,p_number_of_parameters     => p_number_of_parameters
      ,p_hook_parameter_names     => p_hook_parameter_names
      ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
      );
  end loop;
  hr_utility.set_location(l_proc, 90);
  --
  -- Close Dynamic Cursor
  --
  dbms_sql.close_cursor(l_dynamic_cursor);
  --
  -- Close the support if statement
  --
  if not l_first_cus_call then
    add_to_source('end if;' || c_new_line);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
exception
  --
  -- In case of an unexpected error ensure
  -- that the Dynamic Cursor is closed.
  --
  when others then
    if dbms_sql.is_open(l_dynamic_cursor) then
      dbms_sql.close_cursor(l_dynamic_cursor);
    end if;
    raise;
end make_customer_calls;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_disabled_calls >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Any disabled hook calls are set with the pre-processor date and any error
--   details are cleared. A developer could switch the enabled flag between
--   pre-processor runs. It would be misleading to leave any old error details
--   because:
--      i) the call_procedure may have also changed.
--     ii) the pre-processor has successfully executed the hook call,
--         from the latest version of the hook package body.
--
-- Prerequisites:
--   This hook is known to exist in the HR_API_HOOKS table.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--
-- Post Success:
--   Updates all the rows in the HR_API_HOOK_CALLS table which match the
--   api_hook_id and the enabled_flag is 'N'. Customer and legislation
--   hook calls are updated. The encoded_error, status and pre_processor_date
--   columns are populated.
--
-- Post Failure:
--   Any errors are raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_disabled_calls
  (p_api_hook_id                   in     number
  ) is
  --
  -- Cursor to find all the disabled, hook calls for one hook.
  --
  cursor csr_disabled is
    select api_hook_call_id
         , object_version_number
      from hr_api_hook_calls
     where enabled_flag = 'N'
       and api_hook_id  = p_api_hook_id;
  --
  l_proc                varchar2(72) := g_package||'update_disabled_calls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Update all disabled, hook calls for a particular hook
  --
  for l_disabled in csr_disabled loop
    -- Change the following update statement to
    -- call the row handler, when it is available.
    update hr_api_hook_calls
       set pre_processor_date    = sysdate
         , encoded_error         = null
         , status                = 'V'
         , object_version_number = object_version_number + 1
     where api_hook_call_id      = l_disabled.api_hook_call_id
       and object_version_number = l_disabled.object_version_number;
  end loop; -- End Disabled Loop
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end update_disabled_calls;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< procedure_code >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code after the parameter list for one hook package
--   procedure.
--
-- Prerequisites:
--   The procedure name and parameter list has already been created, up to
--   and including the 'is' statement.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of the hook package.
--   p_hook_procedure               Yes  varchar2 Name of the hook procedure
--                                                within the hook package.
--   p_api_hook_type                Yes  varchar2 Type of Hook.
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_legislation_package          Yes  varchar2 The legislation_package as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_legislation_function         Yes  varchar2 The legislation_function as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_module_name                  Yes  varchar2 API Module name from the
--                                                HR_API_MODULES table.
--   p_data_within_business_group   Yes  varchar2 Indicates if the data for
--                                                this module is held within
--                                                the context of a
--                                                business_group_id. From the
--                                                HR_API_MODULES table.
--   p_number_of_parameters         Yes  number   The number of parameters to
--                                                the hook package procedure.
--   p_hook_parameter_names         Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter names.
--   p_hook_parameter_datatypes     Yes  Table    When the number of hook
--                                                procedure parameters is
--                                                greater than zero, lists the
--                                                parameter data types.
--
-- Post Success:
--   Creates source code for the hook procedure in the source store.
--
-- Post Failure:
--   Most application and some Oracle errors are written to the corresponding
--   rows in the HR_API_HOOKS or HR_API_HOOK_CALLS tables. Some application
--   or Oracle errors are raised from this procedure as PL/SQL exceptions.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure procedure_code
  (p_hook_package                  in     varchar2
  ,p_hook_procedure                in     varchar2
  ,p_api_hook_type                 in     varchar2
  ,p_api_hook_id                   in     number
  ,p_legislation_package           in     varchar2
  ,p_legislation_function          in     varchar2
  ,p_module_name                   in     varchar2
  ,p_data_within_business_group    in     varchar2
  ,p_number_of_parameters          in     number
  ,p_hook_parameter_names          in     tbl_parameter_name
  ,p_hook_parameter_datatypes      in     tbl_parameter_datatype
  ) is
  --
  -- Cursor to find out if any enabled, customer specific
  -- hook calls exist for this hook.
  --
  cursor csr_cus_call_exist is
    select 1
      from hr_api_hook_calls
     where enabled_flag     = 'Y'
       and legislation_code is null
       and application_id   is null
       and api_hook_id      = p_api_hook_id;
  --
  -- Cursor to find out if any enabled, legislation specific
  -- hook calls exist for this hook.
  --
  cursor csr_leg_call_exist is
    select 1
      from hr_api_hook_calls
     where enabled_flag     = 'Y'
       and legislation_code is not null
       and api_hook_id      = p_api_hook_id;
  --
  -- Cursor to find out if any enabled, application specific
  -- hook calls exist  which match the called Application
  -- install status for this hook.
  --
  cursor csr_app_call_exist is
    select 1
      from hr_api_hook_calls          ahc
         , fnd_product_installations  fpi
     where ahc.api_hook_id    = p_api_hook_id
       and ahc.enabled_flag   = 'Y'
       and ahc.application_id is not null
       and ahc.application_id = fpi.application_id
       and (   (    ahc.app_install_status IN ('I', 'S')
                and ahc.app_install_status = fpi.status)
            or (    ahc.app_install_status = 'I_OR_S'
                and fpi.status IN ('I', 'S')));
  --
  -- For before_process hooks find out if any enabled, legislation
  -- specific hook calls exist for the corresponding after_process
  -- hook.
  --
  cursor csr_ap_leg_call_exist is
    select 1
      from hr_api_hook_calls  ahc
         , hr_api_hooks       ahk_ap
         , hr_api_modules     amk
         , hr_api_hooks       ahk_bp
     where    ahc.enabled_flag     = 'Y'
       and    ahc.legislation_code is not null
       and    ahc.api_hook_id      = ahk_ap.api_hook_id
       and ahk_ap.api_hook_type    = 'AP'
       and ahk_ap.api_module_id    =    amk.api_module_id
       and    amk.api_module_id    = ahk_bp.api_module_id
       and ahk_bp.api_hook_type    = 'BP'
       and ahk_bp.api_hook_id      = p_api_hook_id;
  --
  l_cus_call_exist      boolean;   -- Indicates if at least one customer
                                   -- specific hook call exists from this
                                   -- hook.
  l_leg_call_exist      boolean;   -- Indicates if at least one legislation
                                   -- specific hook call exists from this
                                   -- hook.
  l_app_call_exist      boolean;   -- Indicates if at least one application
                                   -- specific hook call exists from this
                                   -- hook and the called application install
                                   -- status matches with the hook call
                                   -- install status.
  l_ap_leg_call_exist   boolean;   -- Indicates this is a before_process
                                   -- hook (BP) and at least one legislation
                                   -- specific hook call exists from the
                                   -- corresponding after_process (AP) hook.
                                   -- Always set to false if this is not a
                                   -- before_process hook.
  l_exists              number(15);
  l_proc                varchar2(72) := g_package||'procedure_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Work out the status of the all the types of hook call. These values
  -- affect how much code should be created in the hook procedure.
  --
  -- Find out if any enabled, customer hook calls exist for the
  -- current hook package procedure
  --
  open csr_cus_call_exist;
  fetch csr_cus_call_exist into l_exists;
  l_cus_call_exist := csr_cus_call_exist%found;
  close csr_cus_call_exist;
  hr_utility.set_location(l_proc, 20);
  --
  -- Find out if any enabled, legislation hook calls exist for the
  -- current hook package procedure
  --
  open csr_leg_call_exist;
  fetch csr_leg_call_exist into l_exists;
  l_leg_call_exist := csr_leg_call_exist%found;
  close csr_leg_call_exist;
  hr_utility.set_location(l_proc, 30);
  --
  -- Find out if any enabled, application hook calls exist which
  -- match the called Application install status for the
  -- current hook package procedure
  --
  open csr_app_call_exist;
  fetch csr_app_call_exist into l_exists;
  l_app_call_exist := csr_app_call_exist%found;
  close csr_app_call_exist;
  hr_utility.set_location(l_proc, 35);
  --
  -- For before_process hooks where data is held within the context
  -- of a business group find out if any enabled, legislation
  -- specific hook calls exist for the corresponding after_process
  -- hook.
  --
  if p_api_hook_type = 'BP' and p_data_within_business_group = 'Y' then
    open csr_ap_leg_call_exist;
    fetch csr_ap_leg_call_exist into l_exists;
    l_ap_leg_call_exist := csr_ap_leg_call_exist%found;
    close csr_ap_leg_call_exist;
    hr_utility.set_location(l_proc, 40);
  else
    l_ap_leg_call_exist := false;
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Create the procedure code. Include or exclude sections depending
  -- on the existence of the different types of hook.
  --
  if l_cus_call_exist or l_leg_call_exist or
     l_app_call_exist or l_ap_leg_call_exist then
    --
    -- At least one hook call exists or just a call to a
    -- return_legislation_code function. Define all the possible local
    -- variables. (Even though all of them may not be used.) Also the
    -- create the begin statement, the 'entering' set_location.
    --
    -- Local variables
    add_to_source('l_commit_unit_number number;' || c_new_line);
    add_to_source('l_legislation_code   varchar2(30);' || c_new_line);
    -- Begin
    add_to_source('begin' || c_new_line);
    -- 'Entering' set location
    add_to_source('hr_utility.set_location(' || '''' ||  'Entering: ');
    add_to_source(p_hook_package || '.' || p_hook_procedure || '''');
    add_to_source(', 10);' || c_new_line);
    hr_utility.set_location(l_proc, 60);
    --
    if l_cus_call_exist or l_leg_call_exist or l_app_call_exist then
      -- When a hook call will be made obtain the commit unit number
      add_to_source('l_commit_unit_number := hr_api.return_commit_unit;');
      add_to_source(c_new_line);
      hr_utility.set_location(l_proc, 70);
    end if;
    --
    if l_leg_call_exist or l_app_call_exist or l_ap_leg_call_exist then
      --
      -- When a legislation specific call exists  or
      -- an application specific call exists or
      -- just calling a return_legilsation_code function:
      --   1st) Process any customer specific calls with a low sequence number.
      --   2nd) Process any application specific calls.
      --   3nd) Process any legislation specific calls.
      --   4th) Process any customer specific calls with a high sequence
      --        number.
      --
      -- If this is a before_process hook where data is held within the
      -- context of a business group and there is a legislation
      -- specific call from the corresponding after_process hook then
      -- the return_legislation_code function is called. Even if there are
      -- no legislation specific hook calls from this hook. This is done
      -- to ensure the return_legislation_code function package global
      -- variables are set, before a row is deleted from the database.
      -- If this was not done the legislation code could be derived just
      -- from the after_process hook, as the row will not exist.
      --
      -- If this is an after_process hook and there is at least one
      -- legislation or application specific hook call then include a
      -- call to hr_multi_message.end_validation_set. This is required
      -- to support Multiple Message Detection.
      --
      hr_utility.set_location(l_proc, 80);
      if l_cus_call_exist then
        --
        -- Process any customer specific calls with a low sequence number.
        --
        make_customer_calls
          (p_api_hook_id              => p_api_hook_id
          ,p_number_of_parameters     => p_number_of_parameters
          ,p_hook_parameter_names     => p_hook_parameter_names
          ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
          ,p_sequence_number_range    => 'LOW'
          );
      end if;
      --
      if l_app_call_exist then
        --
        -- Process any application specific calls if they exist.
        --
        make_application_calls
          (p_api_hook_id              => p_api_hook_id
          ,p_number_of_parameters     => p_number_of_parameters
          ,p_hook_parameter_names     => p_hook_parameter_names
          ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
          );
      end if;
      --
      if l_leg_call_exist or l_ap_leg_call_exist then
        --
        -- Process any legislation specific calls or
        -- just make the return_legislation_code function call.
        --
        make_legislation_calls
          (p_api_hook_id                => p_api_hook_id
          ,p_legislation_package        => p_legislation_package
          ,p_legislation_function       => p_legislation_function
          ,p_data_within_business_group => p_data_within_business_group
          ,p_number_of_parameters       => p_number_of_parameters
          ,p_hook_parameter_names       => p_hook_parameter_names
          ,p_hook_parameter_datatypes   => p_hook_parameter_datatypes
          );
      end if;
      --
      if l_cus_call_exist then
        --
        -- Process any customer specific calls with a high sequence number.
        --
        make_customer_calls
          (p_api_hook_id              => p_api_hook_id
          ,p_number_of_parameters     => p_number_of_parameters
          ,p_hook_parameter_names     => p_hook_parameter_names
          ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
          ,p_sequence_number_range    => 'HIGH'
          );
        hr_utility.set_location(l_proc, 110);
      end if;
      --
      if p_api_hook_type = 'AP' and
         (l_leg_call_exist or l_app_call_exist) then
        --
        -- For After_process user hooks which contain legislation
        -- or Application hook calls include a call to
        -- hr_multi_message.end_validation_set.
        --
        add_to_source('hr_multi_message.end_validation_set;' || c_new_line);
      end if;
      --
    else
      --
      -- When there are no legislation or application specific work,
      -- process all the customer specific calls together. This keeps
      -- the number of if statements in the generated source code to
      -- a minimum.
      --
      make_customer_calls
        (p_api_hook_id              => p_api_hook_id
        ,p_number_of_parameters     => p_number_of_parameters
        ,p_hook_parameter_names     => p_hook_parameter_names
        ,p_hook_parameter_datatypes => p_hook_parameter_datatypes
        ,p_sequence_number_range    => 'ALL'
        );
      hr_utility.set_location(l_proc, 120);
    end if;
    --
    if l_cus_call_exist or l_leg_call_exist or l_app_call_exist then
      -- When a hook call has be made check that commit unit
      -- number has not changed since the start of the hook.
      --
      add_to_source('hr_api.validate_commit_unit(l_commit_unit_number, ');
      add_to_source('''' || p_module_name || '''' || ', ' || '''');
      add_to_source(p_api_hook_type || '''' || ');' || c_new_line);
      hr_utility.set_location(l_proc, 130);
    end if;
  else
    --
    -- No enabled hook calls exist. Do not define any local variables.
    -- Just define the begin statement and the 'entering' set_location.
    --
    add_to_source('begin' || c_new_line);
    add_to_source('hr_utility.set_location(' || '''' ||  'Entering: ');
    add_to_source(p_hook_package || '.' || p_hook_procedure || '''');
    add_to_source(', 10);' || c_new_line);
    hr_utility.set_location(l_proc, 140);
  end if;
  --
  -- Any hook calls which have been disabled ensure the encoded_error,
  -- status and pre_processor_date columns are updated.
  -- (This has to be done here because the make_legislation_calls and
  -- make_customer_calls procedures are only called when corresponding
  -- enabled hook calls exists.)
  --
  update_disabled_calls
    (p_api_hook_id => p_api_hook_id
    );
  hr_utility.set_location(' Leaving:'|| l_proc, 150);
end procedure_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< make_parameter_list >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the list of parameters for one hook package procedure.
--
-- Prerequisites:
--   The start of the procedure code has already been created and added
--   to the source store. The hook_procedure is known to exist in the
--   hook_package.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of the hook package.
--   p_hook_procedure               Yes  varchar2 Name of the hook procedure
--                                                within the hook package.
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--
-- Post Success:
--   Creates the list of parameters in the source store.
--   p_param_list_error is set to false. p_number_of_parameters is set to the
--   number of parameters which exists in the hook package procedure. When
--   p_number_of_parameters is greater than zero then p_hook_parameter_names
--   is populated with the list of parameter names to hook package procedure.
--   p_hook_parameter_datatypes is set to the corresponding parameter
--   datatypes. The internal Oracle datatypes number codes are used, not the
--   text string representations. hr_api_hooks.encoded_error is updated to
--   null.
--
-- Post Failure:
--   When a hook package procedure header or parameter error occurs the
--   parameter list is not constructed. p_param_list_error is set to true.
--   Details of the error are written to the hr_api_hooks.encoded_error
--   column. A comment and invalid code is deliberately added to the source
--   code to force the problem to be investigated and resolved. The
--   p_number_of_parameters, p_hook_parameter_names and
--   p_hook_parameter_datatypes parameters contain undefined values and no
--   attempt should be made to use them. Details of the error are written to
--   hr_api_hooks.encoded_error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_parameter_list
  (p_hook_package                  in     varchar2
  ,p_hook_procedure                in     varchar2
  ,p_api_hook_id                   in     number
  ,p_number_of_parameters             out nocopy number
  ,p_hook_parameter_names             out nocopy tbl_parameter_name
  ,p_hook_parameter_datatypes         out nocopy tbl_parameter_datatype
  ,p_param_list_error                 out nocopy boolean
  ) is
  --
  -- Local variables to catch the values returned from
  -- hr_general.describe_procedure
  --
  l_overload            dbms_describe.number_table;
  l_position            dbms_describe.number_table;
  l_level               dbms_describe.number_table;
  l_argument_name       dbms_describe.varchar2_table;
  l_datatype            dbms_describe.number_table;
  l_default_value       dbms_describe.number_table;
  l_in_out              dbms_describe.number_table;
  l_length              dbms_describe.number_table;
  l_precision           dbms_describe.number_table;
  l_scale               dbms_describe.number_table;
  l_radix               dbms_describe.number_table;
  l_spare               dbms_describe.number_table;
  --
  -- Other local variables
  --
  l_loop              binary_integer;          -- Loop counter
  l_error             boolean := false;        -- Indicates if the
                                               -- hr_general.
                                               -- describe_procedure raised an
                                               -- error for the hook package
                                               -- procedure. Or shows there is
                                               -- a problem with a parameter
                                               -- to the hook package
                                               -- procedure.
  l_pre_overload      number;                  -- Previous parameter overload
                                               -- number.
  l_datatype_str      varchar2(20);            -- String equivalent of
                                               -- l_datatype number.
  l_param_code        varchar2(20000) := null; -- The parameter list code.
  l_encoded_err_text  varchar2(2000);          -- Set to the encoded error text
                                               -- when an error is written to
                                               -- the HR_API_HOOKS table.
  l_proc          varchar2(72) := g_package||'make_parameter_list';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Call an RDMS procedure to obtain the list of parameters to the hook
  -- package procedure. A separate begin ... end block has been specified so
  -- that errors raised by hr_general.describe_procedure can be trapped and
  -- handled locally.
  --
  begin
    hr_general.describe_procedure
      (object_name   => p_hook_package || '.' || p_hook_procedure
      ,reserved1     => null
      ,reserved2     => null
      ,overload      => l_overload
      ,position      => l_position
      ,level         => l_level
      ,argument_name => l_argument_name
      ,datatype      => l_datatype
      ,default_value => l_default_value
      ,in_out        => l_in_out
      ,length        => l_length
      ,precision     => l_precision
      ,scale         => l_scale
      ,radix         => l_radix
      ,spare         => l_spare
      );
  exception
    when Package_Not_Exists then
      -- Error: The hook package header source code cannot be found in the
      -- database. Either the package header has not been loaded into the
      -- database or the hook package name specified in the HR_API_HOOKS
      -- table is incorrect. This API module will not execute until this
      -- problem has been resolved.
      hr_utility.set_message(800, 'HR_51960_AHK_HK_PKG_NOT_FOUND');
      l_error := true;
      hr_utility.set_location(l_proc, 20);
    when Proc_Not_In_Package then
      -- Error: The hook procedure does not exist in the hook package.
      -- This API module will not execute until this problem has been
      -- resolved.
      hr_utility.set_message(800, 'HR_51961_AHK_HK_PRO_NO_EXIST');
      l_error := true;
      hr_utility.set_location(l_proc, 30);
    when Remote_Object then
      -- Error: Remote objects cannot used for API hook package procedures.
      -- This API module will not execute until this problem has been
      -- resolved.
      hr_utility.set_message(800, 'HR_51962_AHK_HK_REMOTE_OBJ');
      l_error := true;
      hr_utility.set_location(l_proc, 40);
    when Invalid_Package then
      -- Error: The hook package code in the database is invalid.
      -- This API module will not execute until this problem has been
      -- resolved.
      hr_utility.set_message(800, 'HR_51963_AHK_HK_PKG_INVALID');
      l_error := true;
      hr_utility.set_location(l_proc, 50);
    when Invalid_Object_Name then
      -- Error: An error has occurred while attempting to parse the name of
      -- the hook package and hook procedure. Check the package and procedure
      -- names. This API module will not execute until this problem has been
      -- resolved.
      hr_utility.set_message(800, 'HR_51964_AHK_HK_PARSE');
      l_error := true;
      hr_utility.set_location(l_proc, 60);
  end;
  hr_utility.set_location(l_proc, 70);
  --
  -- Only continue with the individual parameter validation if
  -- hr_general.describe_procedure did not raise an error.
  --
  if not l_error then
    --
    -- If the first parameter in the list has a data type of 'UNDEFINED'
    -- then there are no parameters to the procedure. The parameter
    -- list only has to be built if first parameter is not 'UNDEFINED'.
    --
    l_loop := 1;
    if l_datatype(1) <> c_dtype_undefined then
      --
      -- Search through the tables returned to create the parameter list
      --
      l_pre_overload := l_overload(1);
      begin
        --
        -- There is separate PL/SQL block for reading from the PL/SQL tables.
        -- We do not know how many parameters exist. So we have to keep reading
        -- from the tables until PL/SQL finds a row which has not been
        -- initialised and raises a NO_DATA_FOUND exception.
        --
        <<step_through_param_list>>
        loop
          --
          -- Check the parameter data type is VARCHAR2(1), NUMBER(2), DATE(12),
          -- BOOLEAN(252) or LONG(8). Record, table and all other datatypes
          -- are not allowed.
          --
          if l_datatype(l_loop) <> c_dtype_varchar2 and
             l_datatype(l_loop) <> c_dtype_number   and
             l_datatype(l_loop) <> c_dtype_date     and
             l_datatype(l_loop) <> c_dtype_boolean  and
             l_datatype(l_loop) <> c_dtype_long     then
            -- Error: In a hook package procedure all the parameter datatypes
            -- must be VARCHAR2, NUMBER, DATE, BOOLEAN or LONG. This API
            -- module will not execute until this problem has been resolved.
            hr_utility.set_message(800, 'HR_51968_AHK_HK_PARA_D_TYPE');
            l_error := true;
            hr_utility.set_location(l_proc, 80);
          else
            -- Set the datatype string with the corresponding word value
            if l_datatype(l_loop) = c_dtype_varchar2 then
              l_datatype_str := 'VARCHAR2';
            elsif l_datatype(l_loop) = c_dtype_number then
              l_datatype_str := 'NUMBER';
            elsif l_datatype(l_loop) = c_dtype_date then
              l_datatype_str := 'DATE';
            elsif l_datatype(l_loop) = c_dtype_boolean then
              l_datatype_str := 'BOOLEAN';
            else
              l_datatype_str := 'LONG';
            end if;
          end if;
          --
          -- Check the parameter is an IN parameter.
          -- OUT and IN/OUT is not allowed.
          --
          if l_in_out(l_loop) <> c_ptype_in then
            -- Error: In a hook package procedure all the parameters must IN
            -- parameters. OUT or IN/OUT parameters are not allowed. This API
            -- module will not execute until this problem has been resolved.
            hr_utility.set_message(800, 'HR_51969_AHK_HK_ONLY_IN_PARA');
            l_error := true;
            hr_utility.set_location(l_proc, 90);
          --
          -- Check the parameter does not have a default value.
          --
          elsif l_default_value(l_loop) = c_default_defined then
            -- Error: You cannot define default values for parameters to a
            -- hook package procedure. Ensure no defaults are defined. This
            -- API module will not execute until this problem has been
            -- resolved.
            hr_utility.set_message(800, 'HR_51970_AHK_HK_NO_DEFLT_PARA');
            l_error := true;
            hr_utility.set_location(l_proc, 100);
          --
          -- Check the overload number has not changed. More than one PL/SQL
          -- version of the same procedure is not allowed.
          --
          elsif l_pre_overload <> l_overload(l_loop) then
            -- Error: A hook package procedure cannot have any PL/SQL
            -- overloaded versions. This API module will not execute until
            -- this problem has been resolved.
            hr_utility.set_message(800, 'HR_51971_AHK_HK_NO_OVER');
            l_error := true;
            hr_utility.set_location(l_proc, 110);
          --
          -- Check the argument name has been set. If it is not set entry
          -- returned from hr_general.describe_procedure is for a function
          -- return value. Hook package functions should not be called.
          --
          elsif l_argument_name(l_loop) is null then
            -- Error: The hook package procedure can only be a procedure. It
            -- cannot be a function. This API module will not execute until
            -- this problem has been resolved.
            hr_utility.set_message(800, 'HR_51972_AHK_HK_NO_FUNCTIONS');
            l_error := true;
            hr_utility.set_location(l_proc, 120);
          end if;
          --
          if not l_error then
            --
            -- The parameter has passed all the validation. Add it to the
            -- source code.
            --
            if l_loop = 1 then
              -- This is the first parameter prefix with an opening bracket
              l_param_code := '(';
            else
              -- Have already processed the first parameter. Separate this
              -- parameter from the previous parameter with a ,
              l_param_code := l_param_code || ',';
            end if;
            hr_utility.set_location(l_proc, 130);
            --
            l_param_code := l_param_code || l_argument_name(l_loop) ||
                            ' in ' || l_datatype_str || c_new_line;
            --
            -- Remember details of the parameters so the hook call parameters
            -- can be validated later. i.e. Set the out parameter tables.
            --
            p_hook_parameter_names(l_loop)     := l_argument_name(l_loop);
            p_hook_parameter_datatypes(l_loop) := l_datatype(l_loop);
            --
            -- Prepare loop variables for the next iteration
            --
            l_pre_overload := l_overload(l_loop);
            l_loop := l_loop + 1;
          else
            --
            -- The parameter has failed a validation check. Exit out of the
            -- loop as there is no point is validating the rest of the
            -- parameters.
            --
            exit;
          end if;
        end loop step_through_param_list;
        hr_utility.set_location(l_proc, 140);
      exception
        when no_data_found then
          -- Trap the PL/SQL no_data_found exception. Know we have already
          -- read the details of the last parameter from the tables.
          if l_loop > 0 then
            -- There must have been at least one parameter in the list. End the
            -- parameter list with a closing bracket. The bracket should not be
            -- included when there are zero parameters.
            l_param_code := l_param_code || ')';
          end if;
      end;
    end if;
  end if;
  hr_utility.set_location(l_proc, 150);
  --
  -- Set the out parameters for this procedure and update
  -- the error details in the hr_api_hooks table.
  --
  if not l_error then
    --
    -- Remember how many parameters exist to the hook package procedure
    p_number_of_parameters := l_loop - 1;
    --
    -- Indicate that no hook package procedure or parameter list errors
    -- where found.
    p_param_list_error := false;
    --
    -- Ensure any error details placed in the HR_API_HOOKS table, from previous
    -- generates, are cleared. When the make_find_legislation procedure is
    -- executed, sometimes an error will be written to HR_API_HOOKS. In certain
    -- cases the 'clearing' update done here will be a waste of time. It is not
    -- possible to detect here when make_find_legislation will find an error.
    -- Also make_find_legislation will not be called if there are any hook
    -- calls. So the 'clearing' update is always done here.
    --
    -- Change the following update statement to
    -- call the row handler, when it is available.
    --
    update hr_api_hooks
       set encoded_error = null
     where api_hook_id   = p_api_hook_id;
    hr_utility.set_location(l_proc, 160);
  else
    --
    -- The parameter list code for this hook procedure could not be generated
    -- due to an error. Write details of the error to the HR_API_HOOKS table.
    -- Also deliberately create some invalid code in the hook package body
    -- to prevent the package from compiling. This will force somebody to
    -- investigate the problem.
    --
    p_number_of_parameters := null;
    p_param_list_error     := true;
    --
    -- Create comment text in the package body source code
    --
    error_expected;
    l_param_code := '-- The parameter list for this hook procedure could ' ||
                    'not be created due to' || c_new_line ||
                    '-- an error. Details of the error, in FND encoded ' ||
                    'format, can be obtained' || c_new_line ||
                    '-- with the following sql statement:' || c_new_line ||
                    '--  select h.encoded_error' || c_new_line ||
                    '--    from hr_api_hooks h' || c_new_line ||
                    '--   where h.api_hook_id = ' || to_char(p_api_hook_id) ||
                    ';' || c_new_line ||
                    '-- The following invalid code has been deliberately ' ||
                    'created to force' || c_new_line ||
                    '-- investigation and resolution of this problem.' ||
                    c_new_line || 'INVALID_SEE_COMMENT_IN_SOURCE;' ||
                    c_new_line;
    hr_utility.set_location(l_proc, 170);
    --
    -- Write details of the error to the HR_API_HOOKS table
    --
    l_encoded_err_text := fnd_message.get_encoded;
    --
    -- Change the following update statement to
    -- call the row handler, when it is available.
    --
    update hr_api_hooks
       set encoded_error = l_encoded_err_text
     where api_hook_id   = p_api_hook_id;
    hr_utility.set_location(l_proc, 180);
  end if;
  --
  -- Add the parameter list or error comment text
  -- to the rest of the hook package source code
  --
  add_to_source(l_param_code);
  hr_utility.set_location(' Leaving:'|| l_proc, 190);
end make_parameter_list;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< make_hook_procedure >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Makes the source code for one hook package procedure.
--
-- Prerequisites:
--   The start of the package body code has already been created and added
--   to the source store. The hook_procedure is known to exist in the
--   hook_package.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of the hook package.
--   p_hook_procedure               Yes  varchar2 Name of the hook procedure
--                                                within the hook package.
--   p_api_hook_type                Yes  varchar2 Type of Hook.
--   p_api_hook_id                  Yes  number   ID of the hook details from
--                                                the HR_API_HOOKS table.
--   p_legislation_package          Yes  varchar2 The legislation_package as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_legislation_function         Yes  varchar2 The legislation_function as
--                                                specified in the HR_API_HOOKS
--                                                table.
--   p_module_name                  Yes  varchar2 API Module name from the
--                                                HR_API_MODULES table.
--   p_data_within_business_group   Yes  varchar2 Indicates if the data for
--                                                this module is held within
--                                                the context of a
--                                                business_group_id. From the
--                                                HR_API_MODULES table.
--
-- Post Success:
--   Creates source code for the hook procedure in the source store.
--
-- Post Failure:
--   Most application and some Oracle errors are written to the corresponding
--   rows in the HR_API_HOOKS or HR_API_HOOK_CALLS tables. Some application
--   or Oracle errors are raised from this procedure as PL/SQL exceptions.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure make_hook_procedure
  (p_hook_package                  in     varchar2
  ,p_hook_procedure                in     varchar2
  ,p_api_hook_type                 in     varchar2
  ,p_api_hook_id                   in     number
  ,p_legislation_package           in     varchar2
  ,p_legislation_function          in     varchar2
  ,p_module_name                   in     varchar2
  ,p_data_within_business_group    in     varchar2
  ) is
  --
  -- Local variables
  --
  -- Indicates if there is an error with the hook package procedure header
  -- or one of it's parameters.
  l_param_list_error          boolean;
  --
  -- If l_param_list_error is false contains the number of parameters to the
  -- hook procedure. If l_param_list_error is true then the value is undefined
  -- and should not be used.
  l_number_of_parameters      number;
  --
  -- If l_param_list_error is false contains the names of all the parameters
  -- on the hook procedure. If l_param_list_error is true the values are
  -- undefined and should not be used.
  l_hook_parameter_names      tbl_parameter_name;
  --
  -- If l_param_list_error is false contains the datatype codes for the hook
  -- procedure parameters. If l_param_list_error is true the values are
  -- undefined and should not be used.
  l_hook_parameter_datatypes  tbl_parameter_datatype;
  --
  l_proc                      varchar2(72) := g_package||'make_hook_procedure';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Start of the procedure code
  --
  add_to_source('procedure ' || p_hook_procedure || c_new_line);
  --
  -- Make the hook procedure parameter list
  --
  make_parameter_list
    (p_hook_package               => p_hook_package
    ,p_hook_procedure             => p_hook_procedure
    ,p_api_hook_id                => p_api_hook_id
    ,p_number_of_parameters       => l_number_of_parameters
    ,p_hook_parameter_names       => l_hook_parameter_names
    ,p_hook_parameter_datatypes   => l_hook_parameter_datatypes
    ,p_param_list_error           => l_param_list_error
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- When there are no problems with the hook package procedure header and
  -- parameters then build the remainder of the hook procedure source code.
  --
  if not l_param_list_error then
    add_to_source('is' || c_new_line);
    --
    -- Main procedure code
    --
    procedure_code
      (p_hook_package               => p_hook_package
      ,p_hook_procedure             => p_hook_procedure
      ,p_api_hook_type              => p_api_hook_type
      ,p_api_hook_id                => p_api_hook_id
      ,p_legislation_package        => p_legislation_package
      ,p_legislation_function       => p_legislation_function
      ,p_module_name                => p_module_name
      ,p_data_within_business_group => p_data_within_business_group
      ,p_number_of_parameters       => l_number_of_parameters
      ,p_hook_parameter_names       => l_hook_parameter_names
      ,p_hook_parameter_datatypes   => l_hook_parameter_datatypes
      );
    hr_utility.set_location(l_proc, 30);
    --
    -- End of the procedure code
    --
    add_to_source('hr_utility.set_location(' || '''' ||  ' Leaving: ');
    add_to_source(p_hook_package || '.' || p_hook_procedure || '''');
    add_to_source(', 20);' || c_new_line ||'end ' || p_hook_procedure || ';');
    add_to_source(c_new_line);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end make_hook_procedure;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_procedures >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates all the procedures in one package body.
--
-- Prerequisites:
--   The start of the package body code has already been created and added
--   to the source store.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of the hook package.
--
-- Post Success:
--   Creates all the procedure bodies for the hook package. Only creates
--   those procedures which have been listed in the the HR_API_HOOKS table.
--
-- Post Failure:
--   Most application and some Oracle errors are written to the corresponding
--   rows in the HR_API_HOOKS or HR_API_HOOK_CALLS tables. Some application
--   or Oracle errors are raised from this procedure as PL/SQL exceptions.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_procedures
  (p_hook_package                  in     varchar2
  ) is
  --
  -- Cursor to select all the procedure names in a given hook package
  --
  cursor csr_procs is
    select ahk.hook_procedure
         , ahk.api_hook_type
         , ahk.api_hook_id
         , ahk.legislation_package
         , ahk.legislation_function
         , amd.module_name
         , amd.data_within_business_group
      from hr_api_modules  amd
         , hr_api_hooks    ahk
     where amd.api_module_id = ahk.api_module_id
       and ahk.hook_package  = p_hook_package;
  --
  l_proc                varchar2(72) := g_package||'create_procedures';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- For each procedure listed in the current hook package make
  -- the hook procedure call.
  --
  for l_proc in csr_procs loop
    make_hook_procedure
      (p_hook_package               => p_hook_package
      ,p_hook_procedure             => l_proc.hook_procedure
      ,p_api_hook_type              => l_proc.api_hook_type
      ,p_api_hook_id                => l_proc.api_hook_id
      ,p_legislation_package        => l_proc.legislation_package
      ,p_legislation_function       => l_proc.legislation_function
      ,p_module_name                => l_proc.module_name
      ,p_data_within_business_group => l_proc.data_within_business_group
      );
  end loop;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end create_procedures;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_header_line >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates the first line after the create or replace package statement
--   with the Header information.
--
-- Prerequisites:
--   The create or replace statement has already been added to the source
--   store.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of the hook package.
--
-- Post Success:
--   The Header line information has been added to the source code source.
--
-- Post Failure:
--   If the text could not been found then an error is not raised here.
--   When the hook package header does not exist in the database the
--   'make_parameter_list' procedure will raise an error and save the details
--   to the HR_API_HOOKS table. The 'make_parameter_list' procedure is called
--   as part of the 'create_procedures' work.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_header_line
  (p_hook_package                  in     varchar2
  ) is
  --
  -- Cursor to obtain the arcs header line from the hook package header
  --
  cursor csr_second_line (p_pkg_name VARCHAR2, p_pkg_type VARCHAR2) is
    select text
      from user_source
     where name = p_pkg_name
       and type = p_pkg_type
       and line = 2;
  --
  l_source_line         varchar2(2000);  -- Source header line which was
                                         -- derived from the user_source.
  l_header_line         varchar2(2000);  -- Header line string which is being
                                         -- built for inclusion into the
                                         -- user hook package body code.
  l_hook_pkg_type       varchar2(30);    -- The third and second last letters
                                         -- of the hook package name.
  l_pkg_find_name       varchar2(30);    -- Name of the package to search
                                         -- for the header line.
  l_pkg_find_type       varchar2(30);    -- Type of package code to find,
                                         -- either the package header or
                                         -- body.
  l_head_pos            number;          -- Position of dollar Header in the
                                         -- l_source_line.
  l_author_str          number;          -- Position of the arcs author name
                                         -- in l_source_line.
  l_author_end          number;          -- The last character position of the
                                         -- arcs author name in l_source_line.
  l_dplace_str          number;          -- Position of the decimal place in
                                         -- the revision number inside
                                         -- l_source_line.
  l_dplace_end          number;          -- The last character position of the
                                         -- revision number inside
                                         -- l_source_line.
  l_pkg_find_found      boolean;         -- Indicates if using the
                                         -- csr_second_line cursor found a
                                         -- row.
  l_non_standard_hook_pkg boolean;       -- Indicates if a non-standard hook
                                         -- package name has been defined.
                                         -- i.e. The third and second last
                                         -- letters do not equal 'RK' or 'BK'.
  l_proc                varchar2(72) := g_package||'create_header_line';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Primary Method
  -- --------------
  -- Where possible the filename and revision number for the hook package
  -- body should be derived from a package which is actually shipped in
  -- generated file name.
  -- i.e. Look at the third and second last letters of the hook package name.
  -- Where coding standards have been followed this should be like 'RK' or
  -- 'BK'.
  -- If 'RK' then this is a row handler hook package, so derive the
  -- filename and revision number from the corresponding '_SHD' package body.
  -- If 'BK' then this is a business process hook package, so dervie the
  -- filename and revision number from the corresponding '_API' package body.
  --
  -- Alternative Method
  -- ------------------
  -- If the coding standards have not been followed then either the third
  -- and second last letters of the hook package body name will not match
  -- 'RK'/'BK' or the '_SHD'/'_API' package body does not exist.
  -- In either of these cases use the alternative derivation method.
  -- Attempt to derive the dollar header line from the hook package header.
  -- Change 'pkh' to 'pkb' and change the revision number to end with '.0'.
  --
  -- Extract the third and second last letters of the package name
  l_hook_pkg_type := upper(substr(substr(p_hook_package, -3), 1, 2));
  l_non_standard_hook_pkg := false;
  l_pkg_find_found        := false;
  --
  if l_hook_pkg_type = 'RK' then
    -- This is a row handler user hook package so attempt to find
    -- details of the corresponding '_SHD' package body.
    l_pkg_find_name :=
      upper(substr(p_hook_package, 1, length(p_hook_package) -3) || 'SHD');
    l_pkg_find_type := 'PACKAGE BODY';
   --
  elsif l_hook_pkg_type = 'BK' then
    -- This is a business process user hook package so attempt to
    -- find details of the corresponding '_API' package body.
    l_pkg_find_name :=
      upper(substr(p_hook_package, 1, length(p_hook_package) -3) || 'API');
    l_pkg_find_type := 'PACKAGE BODY';
    --
  else
    -- Non-standard hook package name has been defined.
    -- Set flag so alternative strategy will be used.
    l_non_standard_hook_pkg := true;
    --
  end if;
  --
  -- Attempt to find the corresponding package body header line information.
  --
  if not l_non_standard_hook_pkg then
    open csr_second_line(l_pkg_find_name, l_pkg_find_type);
    fetch csr_second_line into l_source_line;
    l_pkg_find_found := csr_second_line%found;
    close csr_second_line;
  end if;
  --
  if l_non_standard_hook_pkg or (not l_pkg_find_found) then
    --
    -- If a non-standard hook package name exists or the package
    -- name for the primary method could not be found then attempt
    -- to obtain the hook package header line information.
    --
    l_pkg_find_name := upper(p_hook_package);
    l_pkg_find_type := 'PACKAGE';
    open csr_second_line(l_pkg_find_name, l_pkg_find_type);
    fetch csr_second_line into l_source_line;
    l_pkg_find_found := csr_second_line%found;
    close csr_second_line;
  end if;
  --
  -- If the text could not been found then do not raise an error here.
  -- When the hook package header does not exist in the database the
  -- 'make_parameter_list' procedure will raise an error and save the
  -- details to the HR_API_HOOKS table. The 'make_parameter_list'
  -- procedure is called as part of the 'create_procedures' work.
  --
  if l_pkg_find_found then
    --
    -- Build the second line of the hook package body, changing the arcs
    -- author name to 'generated'. If the alternative strategy is being
    -- used also change 'pkh' to 'pkb' and alter the revision number to
    -- end with '.0'.
    --
    -- Find the character position of the dollar header string
    l_head_pos := instr(l_source_line, '$Header', 1, 1);
    --
    -- Only continue with the string replacement if the second line of the hook
    -- package body contains a dollar header comment. If the dollar header
    -- does not exist then just assume the coder as forgotten to include it,
    -- don't create a dollar header line in the hook package body, but
    -- continue with the rest of the body generation.
    --
    if l_head_pos <> 0 then
      --
      -- Find the first character position of the author's name. Actually
      -- looking for the space immediately before the name.
      l_author_str := instr(l_source_line, ' ', l_head_pos, 5);
      --
      -- Only continue with the string replacement if the space immediately
      -- before the name was found. If the space cound not be found it could
      -- indicate that the hook package header has not been placed in arcs yet.
      -- i.e. This comment line has not been fully constructed yet.
      --
      if l_author_str <> 0 then
        --
        -- Find the last character position of the author's name. Actually
        -- looking for the space immediately after the name.
        l_author_end := instr(l_source_line, ' ', l_head_pos, 6);
        --
        -- Only continue with the string replacement if the space immediately
        -- after the name could be found.
        --
        if l_author_end <> 0 then
          --
          if l_pkg_find_type = 'PACKAGE' then
            --
            -- When the alternative method is being used also need to locate
            -- starting and ending position of the revision decimal place
            -- digits so they can be replaced with '0'.
            --
            -- Find the character position of the decimal place which is
            -- inside the revision number.
            l_dplace_str := instr(l_source_line, '.', l_head_pos, 2);
            --
            -- Only continue with the string replacement if the decimal place
            -- could be found.
            --
            if l_dplace_str <> 0 then
              --
              -- Find the last character position of the place number.
              -- Actually looking for the space immediately after the
              -- number.
              l_dplace_end := instr(l_source_line, ' ', l_head_pos, 3);
              --
              -- Only continue with the string replacement if the space
              -- immediately after the revision number could be found.
              --
              if l_dplace_end <> 0 then
                --
                -- Set the package body line to the same as the package header
                -- line, but changing the revision decimal package to .0,
                -- the author's name with the string 'generated' and 'pkh'
                -- to 'pkb'.
                l_header_line := substr(l_source_line, 1, l_dplace_str) ||
                  '0' ||
                  substr(l_source_line, l_dplace_end,
                    l_author_str - l_dplace_end) ||
                  ' generated' ||
                  substr(l_source_line, l_author_end,
                     length(l_source_line) - l_author_end);
                  l_header_line := replace(l_header_line, 'pkh', 'pkb');
                -- Add modified dollar header line to the package body source
                add_to_source(l_header_line || c_new_line);
              end if;
            end if;
          else  -- l_pkg_find_type = 'PACKAGE BODY'
            -- Primary method is being used so the revision number in the
            -- found package body Header line can be used directly. Only
            -- need to replace the author's name with the string 'generated'.
            l_header_line := substr(l_source_line, 1, l_author_str) ||
              'generated' ||
              substr(l_source_line, l_author_end,
                length(l_source_line) - l_author_end);
            -- Add modified dollar header line to the package body source
            add_to_source(l_header_line || c_new_line);
          end if;
        end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 140);
end create_header_line;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_package_body >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_package_body
  (p_hook_package                  in     varchar2
  ) is
  --
  l_proc                varchar2(72) := g_package||'create_package_body';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  clear_source;
  --
  -- Build code for the start of the hook package
  --
  add_to_source('create or replace package body ' || p_hook_package);
  add_to_source(' as' || c_new_line);
  --
  -- Build the dollar Header text for the hook package body.
  --
  create_header_line(p_hook_package);
  --
  -- Build the comments at the start of the package body
  --
  add_to_source('-- Code generated by the Oracle HRMS API Hook Pre-processor');
  add_to_source(c_new_line);
  -- add_to_source('-- Created on ' || to_char(sysdate, 'YY/MM/DD HH24:MI:SS'));
  -- add_to_source(' (YY/MM/DD HH:MM:SS)' || c_new_line);
  --
  -- Fix for bug 3315199
  add_to_source('-- Created on ' || fnd_date.date_to_canonical(sysdate));
  add_to_source(' (' || fnd_date.canonical_DT_mask || ')' || c_new_line);
  --
  -- Create all the procedures in this hook package
  --
  create_procedures(p_hook_package);
  --
  -- Build code for the end of the hook package
  --
  add_to_source('end ' || p_hook_package || ';' || c_new_line);
  --
  -- Execute the create or replace package body
  -- source code which has been built up.
  --
  execute_source;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
end create_package_body;

end hr_api_user_hooks;

/
