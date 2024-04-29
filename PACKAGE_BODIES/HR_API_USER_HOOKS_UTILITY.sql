--------------------------------------------------------
--  DDL for Package Body HR_API_USER_HOOKS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_USER_HOOKS_UTILITY" as
/* $Header: hrusrutl.pkb 115.6 2002/12/05 15:53:07 apholt ship $ */
--
-- Package Variables
--
g_package         varchar2(33) := '  hr_api_user_hooks_utility.';
g_number          number       default 0;
g_error_detected  boolean      default false;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< report_line >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Inserts one row to the HR_API_USER_HOOK_REPORTS table.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_text                         Yes  varchar2 Text to insert
--
-- Post success:
--   One row is inserted into the HR_API_USER_HOOK_REPORTS table. No commit
--   is issued.
--
-- Post Failure:
--   An Oracle error is raised. No application specific errors as raised from
--   this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure report_line
  (p_text                          in     varchar2
  ) is
  l_proc                varchar2(72) := g_package||'report_line';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Insert into reports table
  --
  insert into hr_api_user_hook_reports
  (session_id,
     line,
       text)
  values
  (userenv('SESSIONID'),
     g_number,
       p_text);
  --
  g_number := g_number + 1;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end report_line;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< report_title >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates a translated report title in the HR_API_USER_HOOK_REPORTS table.
--
-- Prerequisites:
--   The message name must exist in the message dictionary.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_title_message_name           Yes  varchar2 Name of the HR message, in
--                                                the message dictionary,
--                                                which contains the title for
--                                                this report.
--
-- Post success:
--   The title is created in the HR_API_USER_HOOK_REPORTS table.
--
-- Post Failure:
--   An exception error is raised and no rows are created in the
--   HR_API_USER_HOOK_REPORTS table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure report_title
  (p_title_message_name            in     varchar2
  ) is
  --
  -- Cursor to see if a report as already
  -- been started for the current session
  --
  cursor csr_report_started is
    select count(*)
      from hr_api_user_hook_reports
     where session_id = userenv('SESSIONID');
  --
  -- Local variables
  --
  l_title               varchar2(2000);
  l_created_on          varchar2(2000);
  l_report_lines        varchar2(30);
  l_proc                varchar2(72) := g_package||'report_title';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Output the report title if a report has not
  -- already started for the current database session
  --
  open csr_report_started;
  fetch csr_report_started into l_report_lines;
  close csr_report_started;
  --
  if l_report_lines = 0 then
    --
    -- Obtain translated report title text from the messages dictionary
    --
    fnd_message.set_name('PER', p_title_message_name);
    l_title := fnd_message.get;
    fnd_message.set_name('PER', 'HR_51988_AHR_CREATED_ON');
    l_created_on := fnd_message.get;
    --
    -- Output the report header, the translated version of:
    --   Translated Report Title
    --   =======================
    --   Created on YYYY/MM/DD HH:MM:SS (YYYY/MM/DD HH:MM:SS)
    --
    report_line('');
    report_line(l_title);
    report_line(rpad('=', length(l_title), '='));
    report_line(l_created_on || ' '
                || to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
                || ' (YYYY/MM/DD HH:MM:SS)');
    --
    -- Reset the global variable which indicates at least one
    -- generation error has been detected with the current set
    -- of API modules
    --
    g_error_detected := false;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end report_title;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_translated_prompts >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Obtains the translated prompts required for the report outout from the
--   message dictionary.
--
--   This procedure has been designed to be called from the
--   write_all_errors_report and write_one_errors_report procedures in
--   this package.
--
-- Prerequisites:
--   The message names must exist in the message dictionary.
--
-- In Parameters:
--   None.
--
-- Post success:
--   All the output parameters are set with the translated text for the
--   corresponding text prompt.
--
-- Post Failure:
--   An exception error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_translated_prompts
  (p_module_name_text                 out nocopy varchar2
  ,p_module_type_text                 out nocopy varchar2
  ,p_hook_text                        out nocopy varchar2
  ,p_hook_pkg_text                    out nocopy varchar2
  ,p_success_text                     out nocopy varchar2
  ) is
  l_title               varchar2(2000);
  l_created_on          varchar2(2000);
  l_proc                varchar2(72) := g_package||'get_translated_prompts';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Obtain translated text from the messages dictionary
  --
  fnd_message.set_name('PER', 'HR_51989_AHR_MOD_NAME');
  p_module_name_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_51990_AHR_MOD_TYPE');
  p_module_type_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_51991_AHR_HOOK');
  p_hook_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_51992_AHR_HOOK_PKG');
  p_hook_pkg_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_52545_AHR_SUCCESS');
  p_success_text := fnd_message.get;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end get_translated_prompts;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_hook_parameter_list >---------------------|
-- ----------------------------------------------------------------------------
--
procedure write_hook_parameter_list is
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
  -- Cursor to return the list of all RH and BP API modules
  --
  cursor csr_modules is
    select amd.api_module_id
         , hlk.meaning
         , amd.module_name
      from hr_lookups     hlk
         , hr_api_modules amd
     where hlk.lookup_type      = 'API_MODULE_TYPE'
       and hlk.lookup_code      = amd.api_module_type
       and amd.api_module_type in ('BP', 'RH')
     order by hlk.meaning, amd.module_name;
  --
  -- Cursor to return the list of hooks for one API module
  --
  cursor csr_hooks (p_module_id number) is
    select hlk.meaning
         , ahk.hook_package
         , ahk.hook_procedure
      from hr_lookups   hlk
         , hr_api_hooks ahk
     where hlk.lookup_type   = 'API_HOOK_TYPE'
       and hlk.lookup_code   = ahk.api_hook_type
       and ahk.api_module_id = p_module_id
     order by hlk.meaning;
  --
  -- Cursor to obtain the names of all the API hook packages
  --
  cursor cur_hooks is
    select distinct hook_package
      from hr_api_hooks;
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
  -- Other Local variables
  --
  l_param_details  varchar2(80);   -- Used to construct the user descriptions
                                   -- for the parameters.
  l_loop           number;         -- Loop counter.
  l_datatype_str   varchar2(20);   -- String equivalent of the parameter
                                   -- datatype.
  l_mod_name_text  varchar2(2000); -- 'Module Name' translated string.
  l_mod_type_text  varchar2(2000); -- 'Module Type' translated string.
  l_hook_text      varchar2(2000); -- 'Hook' translated string.
  l_no_dtype_text  varchar2(2000); -- 'Datatype not recognised' translated str.
  l_proc           varchar2(72) := g_package||'write_hook_parameter_list';
  c_new_line constant varchar2(1) default '
';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Obtain translated text from the message dictionary
  --
  fnd_message.set_name('PER', 'HR_51989_AHR_MOD_NAME');
  l_mod_name_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_51990_AHR_MOD_TYPE');
  l_mod_type_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_51991_AHR_HOOK');
  l_hook_text := fnd_message.get;
  fnd_message.set_name('PER', 'HR_52038_AHR_DTYPE_NOT_REC');
  l_no_dtype_text := fnd_message.get;
  hr_utility.set_location(l_proc, 20);
  --
  -- Output report header
  --
  report_title
    (p_title_message_name => 'HR_51985_AHR_PARM_LIST'
    );
  hr_utility.set_location(l_proc, 30);
  --
  -- Loop for all API Modules
  --
  for l_module in csr_modules loop
    report_line('');
    report_line(l_mod_name_text || ': ' || l_module.module_name);
    report_line(l_mod_type_text || ': ' || l_module.meaning);
    --
    -- Loop for all hooks in a particular API module
    --
    for l_hook in csr_hooks(l_module.api_module_id) loop
      --
      -- Output details of the hook
      --
      report_line('');
      report_line('  ' || l_hook_text || ': ' || l_hook.meaning);
      report_line('  ' || rpad('-', 2 + length(l_hook_text) +
                  length(l_hook.meaning), '-'));
      --
      -- Call an RDMS procedure to obtain the list of parameters to the
      -- hook package procedure. A separate begin ... end block has been
      -- specified so that errors raised by
      -- hr_general.describe_procedure can be trapped and handled
      -- locally.
      --
      begin
        hr_general.describe_procedure
          (object_name   => l_hook.hook_package || '.' ||
                            l_hook.hook_procedure
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
        --
        -- Loop through the values which have been returned.
        --
        begin
          --
          -- There is separate PL/SQL block for reading from the PL/SQL
          -- tables. We do not know how many parameter exist. So we have to
          -- keep reading from the tables until PL/SQL finds a row when has
          -- not been initialised and raises a NO_DATA_FOUND exception.
          --
          l_loop := 1;
          <<step_through_param_list>>
          loop
            --
            -- Work out the string name of the parameter datatype code
            --
            if l_datatype(l_loop) = 1 then
              l_datatype_str := 'VARCHAR2';
            elsif l_datatype(l_loop) = 2 then
              l_datatype_str := 'NUMBER';
            elsif l_datatype(l_loop) = 12 then
              l_datatype_str := 'DATE';
            elsif l_datatype(l_loop) = 252 then
              l_datatype_str := 'BOOLEAN';
            elsif l_datatype(l_loop) = 8 then
              l_datatype_str := 'LONG';
            else
              l_datatype_str := l_no_dtype_text;
            end if;
            --
            -- Construct parameter details to output
            --
            l_param_details := '  ' || rpad(l_argument_name(l_loop), 31) ||
                               l_datatype_str;
            --
            report_line(l_param_details);
            --
            l_loop := l_loop + 1;
          end loop step_through_param_list;
        exception
          when no_data_found then
            -- Trap the PL/SQL no_data_found exception. Know we have already
            -- read the details of the last parameter from the tables.
            null;
        end;
      exception
        -- Trap errors raised by hr_general.describe_procedure
        when Package_Not_Exists then
          -- Error: The hook package header source code cannot be found in the
          -- database. Either the package header has not been loaded into the
          -- database or the hook package name specified in the HR_API_HOOKS
          -- table is incorrect. This API module will not execute until this
          -- problem has been resolved.
          hr_utility.set_message(800, 'HR_51960_AHK_HK_PKG_NOT_FOUND');
        when Proc_Not_In_Package then
          -- Error: The hook procedure does not exist in the hook package.
          -- This API module will not execute until this problem has been
          -- resolved.
          hr_utility.set_message(800, 'HR_51961_AHK_HK_PRO_NO_EXIST');
        when Remote_Object then
          -- Error: Remote objects cannot used for API hook package
          -- procedures. This API module will not execute until this problem
          -- has been resolved.
          hr_utility.set_message(800, 'HR_51962_AHK_HK_REMOTE_OBJ');
        when Invalid_Package then
          -- Error: The hook package code in the database is invalid.
          -- This API module will not execute until this problem has been
          -- resolved.
          hr_utility.set_message(800, 'HR_51963_AHK_HK_PKG_INVALID');
        when Invalid_Object_Name then
          -- Error: An error has occurred while attempting to parse the name
          -- of the hook package and hook procedure. Check the package and
          -- procedure names. This API module will not execute until this
          -- problem has been resolved.
          hr_utility.set_message(800, 'HR_51964_AHK_HK_PARSE');
      end;
    end loop; -- End Hook Loop
  end loop;  -- End Module Loop
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end write_hook_parameter_list;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< write_module_errors >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Writes the hook error details, for one API module, to the
--   HR_API_USER_HOOK_REPORTS.
--
--   This procedure has been designed to be called from the
--   write_all_errors_report and write_one_errors_report procedures in
--   this package.
--
-- Prerequisites:
--   The API module must be defined in the HR_API_MODULES table.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_module_id                Yes  Number   ID of API module
--   p_module_name                  Yes  Varchar2 Module name
--   p_module_type_meaning          Yes  Varchar2 User module type description
--   p_module_name_text             Yes  Varchar2 'Module Name' translated text
--   p_module_type_text             Yes  Varchar2 'Module Type' translated text
--   p_hook_text                    Yes  Varchar2 'Hook' translated text
--   p_hook_pkg_text                Yes  Varchar2 'Hook Package' translated
--                                                text
--   p_success_text                 Yes  Varchar2 'Successful' translated text
--   p_include_success              Yes  Boolean  Indicates if successfully
--                                                processed modules should be
--                                                included in the report out
--
-- Post success:
--   Details of any hook package compilation and application errors will
--   be written to the HR_API_USER_HOOK_REPORTS table.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure write_module_errors
  (p_api_module_id                 in     number
  ,p_module_name                   in     varchar2
  ,p_module_type_meaning           in     varchar2
  ,p_module_name_text              in     varchar2
  ,p_module_type_text              in     varchar2
  ,p_hook_text                     in     varchar2
  ,p_hook_pkg_text                 in     varchar2
  ,p_success_text                  in     varchar2
  ,p_include_success               in     boolean
  ) is
  --
  -- Cursor to list hook packages for a given API module.
  -- Hook packages will only be listed if at least one of the following exists:
  --     i) a hook package body compilation error
  --    ii) An application error against the hook definition
  --   iii) An application error against a hook call definition
  -- If there are no errors the hook package will not be listed.
  --
  cursor csr_hook_pkgs is
    select distinct ahk.hook_package
      from hr_api_hooks ahk
     where ahk.api_module_id = p_api_module_id
       and (  (ahk.encoded_error is not null)
           or exists (select null
                        from hr_api_hook_calls ahc
                       where ahc.api_hook_id  = ahk.api_hook_id
                         and ahc.enabled_flag = 'Y'
                         and ahc.status       = 'I')
           or exists (select null
                        from user_errors uer
                       where uer.type = 'PACKAGE BODY'
                         and uer.name = ahk.hook_package)
           )
     order by ahk.hook_package;
  --
  -- Cursor to list hooks for a given API module and a given hook package.
  -- Hooks will only be listed if at least one of the following exists:
  --    ii) An application error against the hook definition
  --   iii) An application error against a hook call definition
  -- If there are no errors the hook will not be listed.
  --
  cursor csr_hooks (p_api_module_id number
                   ,p_hook_package  varchar2) is
    select hlk.meaning
         , ahk.api_hook_id
      from hr_lookups   hlk
         , hr_api_hooks ahk
     where hlk.lookup_type   = 'API_HOOK_TYPE'
       and hlk.lookup_code   = ahk.api_hook_type
       and ahk.api_module_id = p_api_module_id
       and ahk.hook_package  = p_hook_package
       and (  (ahk.encoded_error is not null)
           or exists (select null
                        from hr_api_hook_calls ahc
                       where ahc.api_hook_id  = ahk.api_hook_id
                         and ahc.enabled_flag = 'Y'
                         and ahc.status       = 'I'
           )          )
     order by hlk.meaning;
  --
  -- Cursor to obtain package body compilation errors for one given package
  -- i.e. Similar to "show errors package body <HOOK_PACKAGE>;"
  --
  cursor cur_pkg_err (p_hook_package varchar2) is
    select substr(to_char(line) || '/' || to_char(position), 1, 8) line_col
         , text
      from user_errors
     where type = 'PACKAGE BODY'
       and name = p_hook_package
     order by sequence;
  --
  -- Cursor to obtain hook level application errors for one given hook
  --
  cursor cur_ahk_err (p_api_hook_id number) is
    select encoded_error
      from hr_api_hooks
     where api_hook_id = p_api_hook_id
       and encoded_error is not null;
  --
  -- Cursor to obtain hook call level application errors
  -- for one given hook when the hook call is enabled
  --
  cursor cur_ahc_err (p_api_hook_id number) is
    select encoded_error
         , call_package
         , call_procedure
      from hr_api_hook_calls
     where api_hook_id  = p_api_hook_id
       and enabled_flag = 'Y'
       and status       = 'I'
     order by sequence;
  --
  -- Local variables
  --
  l_mod_name_output boolean default false; -- Indicates if the module name and
                                           -- type has already been output.
  l_encoded_error   varchar2(2000);        -- Encoded error message from
                                           -- HR_API_HOOKS or
                                           -- HR_API_HOOK_CALLS.
  l_read_error      varchar2(2000);        -- A de-encrypted version of
                                           -- l_encoded_error.
  l_line            varchar2(2000);        -- Line of text for report.
  l_err_cur_module  boolean default false; -- Indicates if at least one error
                                           -- has been detected with the
                                           -- current module.
  l_proc            varchar2(72) := g_package||'write_module_errors';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Loop for all hook packages in a particular API module
  --
  for l_hook_pkgs in csr_hook_pkgs loop
    --
    -- Set flag that at least one error has been detected
    --
    l_err_cur_module := true;
    --
    -- Output details of the module
    --
    if not l_mod_name_output then
      report_line('');
      report_line(p_module_name_text || ': ' || p_module_name);
      report_line(p_module_type_text || ': ' || p_module_type_meaning);
      l_mod_name_output := true;
    end if;
    --
    -- Output details of the hook package
    --
    report_line('');
    report_line(p_hook_pkg_text || ': ' || l_hook_pkgs.hook_package);
    report_line(rpad('-', 2 + length (p_hook_pkg_text) +
                length(l_hook_pkgs.hook_package), '-'));
    report_line('');
    --
    -- Output details of any hook package body system errors
    --
    for l_pkg_err in cur_pkg_err(l_hook_pkgs.hook_package) loop
      report_line(l_pkg_err.line_col || '  ' || l_pkg_err.text);
    end loop;
    --
    -- Loop for all hooks in a particular hook package and module
    --
    for l_hook in csr_hooks(p_api_module_id, l_hook_pkgs.hook_package) loop
      --
      -- Output details of the hook
      --
      report_line('');
      report_line(p_hook_text || ': ' || l_hook.meaning);
      report_line(rpad('-', 2 + length(p_hook_text) +
                  length(l_hook.meaning), '-'));
      --
      -- Output details of any hook level application errors
      --
      open cur_ahk_err(l_hook.api_hook_id);
      fetch cur_ahk_err into l_encoded_error;
      if cur_ahk_err%found then
        -- An error has occurred
        fnd_message.set_encoded(l_encoded_error);
        l_read_error := fnd_message.get;
        report_line(l_read_error);
      end if;
      close cur_ahk_err;
      --
      -- Output details of any hook call level application errors
      --
      for l_ahc_err in cur_ahc_err(l_hook.api_hook_id) loop
        fnd_message.set_encoded(l_ahc_err.encoded_error);
        l_read_error := fnd_message.get;
        l_line := '(' || l_ahc_err.call_package || '.' ||
                  l_ahc_err.call_procedure || ') ' ||
                  substr(l_read_error, 1, 1925);
        report_line(l_line);
      end loop; -- End hook call level application errors
    end loop; -- End Hooks in a module and hook package Loop
  end loop; -- End Hook package loop
  --
  -- If at least one error has been detected then update the
  -- global variable which will indicate to the 'clear_hook_report'
  -- procedure it needs to raise an error. Otherwise write a
  -- successful line to the report.
  --
  if l_err_cur_module then
    g_error_detected := true;
  else
    if p_include_success then
      report_line('');
      report_line(p_module_name || '(' || p_module_type_meaning || ') ' ||
                  p_success_text);
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end write_module_errors;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_all_errors_report >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure write_all_errors_report is
  --
  -- Cursor to return the list of all RH and BP API modules
  --
  cursor csr_modules is
    select amd.api_module_id
         , hlk.meaning
         , amd.module_name
      from hr_lookups     hlk
         , hr_api_modules amd
     where hlk.lookup_type      = 'API_MODULE_TYPE'
       and hlk.lookup_code      = amd.api_module_type
       and amd.api_module_type in ('BP', 'RH')
     order by hlk.meaning, amd.module_name;
  --
  l_module_name_text  varchar2(2000);
  l_module_type_text  varchar2(2000);
  l_hook_text         varchar2(2000);
  l_hook_pkg_text     varchar2(2000);
  l_success_text      varchar2(2000);
  l_proc              varchar2(72) := g_package||'write_all_errors_report';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Output report header
  --
  report_title
    (p_title_message_name => 'HR_51986_AHR_ALL_ERR_TITLE'
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Obtain translated text prompts
  --
  get_translated_prompts
    (p_module_name_text => l_module_name_text
    ,p_module_type_text => l_module_type_text
    ,p_hook_text        => l_hook_text
    ,p_hook_pkg_text    => l_hook_pkg_text
    ,p_success_text     => l_success_text
    );
  hr_utility.set_location(l_proc, 30);
  --
  -- Loop for all API Modules
  --
  for l_module in csr_modules loop
    write_module_errors
      (p_api_module_id       => l_module.api_module_id
      ,p_module_name         => l_module.module_name
      ,p_module_type_meaning => l_module.meaning
      ,p_module_name_text    => l_module_name_text
      ,p_module_type_text    => l_module_type_text
      ,p_hook_text           => l_hook_text
      ,p_hook_pkg_text       => l_hook_pkg_text
      ,p_success_text        => l_success_text
      ,p_include_success     => false
      );
  end loop;  -- End Module Loop
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end write_all_errors_report;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_one_errors_report >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure write_one_errors_report
  (p_api_module_id                 in     number
  ) is
  --
  -- Cursor to validate the API module exists
  -- and it is not an Alternative Interface or
  -- a Data Migrator module.
  --
  cursor cur_module is
    select amd.module_name
         , hlk.meaning
      from hr_lookups     hlk
         , hr_api_modules amd
     where amd.api_module_id    = p_api_module_id
       and hlk.lookup_type      = 'API_MODULE_TYPE'
       and hlk.lookup_code      = amd.api_module_type
       and amd.api_module_type in ('BP', 'RH');
  --
  l_module_name          varchar2(30);
  l_module_type_meaning  varchar2(80);
  l_module_name_text     varchar2(2000);
  l_module_type_text     varchar2(2000);
  l_hook_text            varchar2(2000);
  l_hook_pkg_text        varchar2(2000);
  l_success_text         varchar2(2000);
  l_proc                 varchar2(72) := g_package||'write_one_errors_report';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate this API module actually exists
  --
  open cur_module;
  fetch cur_module into l_module_name, l_module_type_meaning;
  if cur_module%found then
    --
    -- Output report header
    --
    report_title
      (p_title_message_name => 'HR_51987_AHR_ONE_ERR_TITLE'
      );
    hr_utility.set_location(l_proc, 20);
    --
    -- Obtain translated text prompts
    --
    get_translated_prompts
      (p_module_name_text => l_module_name_text
      ,p_module_type_text => l_module_type_text
      ,p_hook_text        => l_hook_text
      ,p_hook_pkg_text    => l_hook_pkg_text
      ,p_success_text     => l_success_text
      );
    hr_utility.set_location(l_proc, 30);
    --
    -- Output report details for the API module
    --
    write_module_errors
      (p_api_module_id       => p_api_module_id
      ,p_module_name         => l_module_name
      ,p_module_type_meaning => l_module_type_meaning
      ,p_module_name_text    => l_module_name_text
      ,p_module_type_text    => l_module_type_text
      ,p_hook_text           => l_hook_text
      ,p_hook_pkg_text       => l_hook_pkg_text
      ,p_success_text        => l_success_text
      ,p_include_success     => true
      );
    hr_utility.set_location(l_proc, 40);
  end if;
  close cur_module;
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end write_one_errors_report;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< clear_hook_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_hook_report is
  --
  -- Cursor to find other sessions
  --
  cursor csr_oth_ses is
    select distinct session_id
      from hr_api_user_hook_reports
     where session_id <> userenv('SESSIONID');
  --
  -- Cursor to find if a specific session is active
  --
  cursor csr_v_ses (p_session_id number) is
    select null
      from gv$session
     where audsid = p_session_id;
  --
  c_header_lines     constant number := 4;
  l_exists           varchar2(1);
  l_proc             varchar2(72) := g_package||'clear_hook_report';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Delete rows in the report table for this session
  --
  delete from hr_api_user_hook_reports
  where session_id = userenv('SESSIONID');
  --
  -- Delete rows from the report table for any sessions
  -- which no longer exist. (Clean-up to ensure unwanted
  -- rows do not build-up in this table.)
  --
  -- Note: Due to wwbug 854170, deliberately using a cursor
  --       loop instead of an join or sub-query between a
  --       standard table and a v$ view. These separate cursors
  --       and PL/SQL code are providing the same result as:
  --         delete from hr_api_user_hook_reports a
  --          where not exists (select null
  --                              from v$session s
  --                             where s.audsid = a.session_id);
  --
  for l_oth_ses in csr_oth_ses loop
    --
    open csr_v_ses(l_oth_ses.session_id);
    fetch csr_v_ses into l_exists;
    if csr_v_ses%notfound then
      -- Session is not active so remove corresponding
      -- rows from hr_api_user_hook_reports
      delete from hr_api_user_hook_reports
      where session_id = l_oth_ses.session_id;
    end if;
    close csr_v_ses;
    --
  end loop;  -- End Module Loop
  --
  commit;
  --
  -- If the report has output details of an error then raise
  -- an unhandled exception. So if AutoInstall had started the
  -- pre-processor it will detect that an error has occurred.
  --
  if g_error_detected then
    raise program_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end clear_hook_report;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_all_modules >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hooks_all_modules is
  --
  -- Cursor to obtain the names of all the API hook packages
  --
  cursor cur_hooks is
    select distinct hook_package
      from hr_api_hooks;
  --
  -- Local variables
  --
  l_proc            varchar2(72) := g_package||'create_hooks_all_modules';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Create each hook package which is defined in the HR_API_HOOKS table
  -- Commit after each package has been created to ensure any error
  -- information written to the HR_API_HOOKS and HR_API_HOOK_CALLS tables
  -- is kept.
  --
  for l_hook in cur_hooks loop
    hr_api_user_hooks.create_package_body(l_hook.hook_package);
    dbms_session.free_unused_user_memory;
    commit;
  end loop;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end create_hooks_all_modules;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_one_module >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hooks_one_module
  (p_api_module_id                 in     number
  ) is
  --
  -- Cursor to validate the API module exists
  -- and it is a business process or row handler
  --
  cursor cur_module is
    select 'Y'
      from hr_api_modules
     where api_module_id    = p_api_module_id
       and api_module_type in ('BP', 'RH');
  --
  -- Cursor to obtain the the API hook package names
  --
  cursor cur_hooks is
    select distinct hook_package
      from hr_api_hooks
     where api_module_id = p_api_module_id;
  --
  -- Local variables
  --
  l_exists          varchar2(30);
  l_proc            varchar2(72) := g_package||'create_hooks_one_module';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate this API module actually exists
  --
  open cur_module;
  fetch cur_module into l_exists;
  if cur_module%found then
    --
    -- For this API module, create each hook package defined in the
    -- HR_API_HOOKS table. Commit after each package has been created to
    -- ensure any error information written to the HR_API_HOOKS and
    -- HR_API_HOOK_CALLS tables is kept.
    --
    for l_hook in cur_hooks loop
      hr_api_user_hooks.create_package_body(l_hook.hook_package);
      dbms_session.free_unused_user_memory;
      commit;
    end loop;
  end if;
  close cur_module;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end create_hooks_one_module;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_add_report >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hooks_add_report
  (p_api_module_id                 in     number
  ) is
  --
  -- Local variables
  --
  l_proc            varchar2(72) := g_package||'create_hooks_add_report';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  create_hooks_one_module
    (p_api_module_id => p_api_module_id
    );
  --
  write_one_errors_report
    (p_api_module_id => p_api_module_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end create_hooks_add_report;
--
end hr_api_user_hooks_utility;

/
