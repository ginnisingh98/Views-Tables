--------------------------------------------------------
--  DDL for Package Body PAY_AU_GENERIC_CODE_CALLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_GENERIC_CODE_CALLER" as
  --  $Header: pyaugcc.pkb 115.3 2002/12/04 06:16:15 ragovind ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create AU HRMS generic code caller package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  04 Dec 2002 Ragovind 2689226   Added NOCOPY and dbdrv
  --  28 Feb 2000 JTurner            Renamed script and objects to use country
  --                                 identifier of "AU" instead of "NZ"
  --  24 Feb 2000 JTurner            Now supports R11i date format
  --  30 NOV 1999 JTURNER  N/A       Created

  -----------------------------------------------------------------------------
  --  private global declarations
  -----------------------------------------------------------------------------

  --  none

  -----------------------------------------------------------------------------
  --  execute_process procedure
  --
  --  This is a public procedure that is called to execute a process.
  -----------------------------------------------------------------------------

  procedure execute_process
  (p_business_group_id              in     number
  ,p_effective_date                 in     date
  ,p_process_id                     in     number
  ,p_assignment_action_id           in     number
  ,p_input_store                    in     t_variable_store_tab) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.execute_process' ;
    l_parameter_value               pay_au_module_parameters.constant_value%type ;
    l_dummy                         varchar2(2) ;
    l_legislation_code              pay_au_module_parameters.constant_value%type ;

    e_missing_process_parameter     exception ;
    e_bad_module_type               exception ;
    e_missing_legislation_code      exception ;
    e_missing_session_record        exception ;
    e_bad_process                   exception ;

    --  cursor to check process is valid for current business
    --  group / legislation

    cursor c_process (p_process_id number
                     ,p_business_group_id number
                     ,p_legislation_code varchar2) is
      select 'ok'
      from   pay_au_processes p
      where  p.process_id = p_process_id
      and    ((p.business_group_id is null
      and      p.legislation_code is null)
      or      (p.business_group_id = p_business_group_id)
      or      (p.legislation_code = p_legislation_code)) ;

    --  cursor to check fnd_sessions record exists

    cursor c_session is
      select 'ok'
      from   fnd_sessions
      where  session_id = userenv('sessionid') ;

    --  cursor to find process parameters

    cursor c_process_parameters(p_process_id number) is
      select pp.internal_name
      ,      pp.data_type
      from   pay_au_process_parameters pp
      where  pp.process_id = p_process_id
      and    pp.enabled_flag = 'Y' ;

    --  cursor to find the legislation code

    cursor c_legislation_code (p_business_group_id number) is
      select legislation_code
      from   per_business_groups
      where  business_group_id = p_business_group_id ;

    --  cursor to find the enabled modules for a process

    cursor c_modules(p_process_id number) is
      select m.name module_name
      ,      mt.name module_type
      ,      m.package_name
      ,      m.procedure_function_name
      ,      m.formula_name
      ,      m.module_id
      from   pay_au_process_modules pm
      ,      pay_au_modules m
      ,      pay_au_module_types mt
      where  pm.process_id = p_process_id
      and    pm.enabled_flag = 'Y'
      and    m.module_id = pm.module_id
      and    m.enabled_flag = 'Y'
      and    mt.module_type_id = m.module_type_id
      and    mt.enabled_flag = 'Y'
      order by
             pm.process_sequence ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
    hr_utility.trace('  p_effective_date: ' || fnd_date.date_to_canonical(p_effective_date)) ;
    hr_utility.trace('  p_process_id: ' || to_char(p_process_id)) ;
    hr_utility.trace('  p_assignment_action_id: ' || to_char(p_assignment_action_id)) ;

    --  check that there's a record in fnd_sessions (the Oracle
    --  FastFormula harness crashes if no fnd_sessions record present).

    open c_session ;
    fetch c_session
      into l_dummy ;
    if c_session%notfound
    then
      close c_session ;
      raise e_missing_session_record ;
    end if ;
    close c_session ;

    --  store the business group input parameter and effective date

    store_variable('BUSINESS_GROUP_ID'
                  ,'NUMBER'
                  ,p_business_group_id) ;

    store_variable('ASSIGNMENT_ACTION_ID'
                  ,'NUMBER'
                  ,p_assignment_action_id) ;

    store_variable('EFFECTIVE_DATE'
                  ,'DATE'
                  ,fnd_date.date_to_canonical(p_effective_date)) ;

    --  get the legislation code we're working under and store it

    open c_legislation_code(p_business_group_id) ;
    fetch c_legislation_code
      into l_legislation_code ;
    if c_legislation_code%notfound
    then

      close c_legislation_code ;
      raise e_missing_legislation_code ;

    end if ;
    close c_legislation_code ;

    store_variable('LEGISLATION_CODE'
                  ,'TEXT'
                  ,l_legislation_code) ;

    --  check that the process to be run is valid for this
    --  busines group/legislation

    open c_process(p_process_id, p_business_group_id, l_legislation_code) ;
    fetch c_process
      into l_dummy ;
    if c_process%notfound
    then
      close c_process ;
      raise e_bad_process ;
    end if ;
    close c_process ;

    --  initialise the variable store PL/SQL table with the values
    --  from the input PL/SQL table

    for i in p_input_store.first..p_input_store.last
    loop

      store_variable(p_input_store(i).name
                    ,p_input_store(i).data_type
                    ,p_input_store(i).value) ;

    end loop ;

    --  check that all the parameters the process requires have been
    --  supplied.  The pay_au_process_parameters table defines the
    --  parameters the process requires.

    for r_parameter in c_process_parameters(p_process_id)
    loop

      l_parameter_value := null ;

      retrieve_variable
      (r_parameter.internal_name
      ,r_parameter.data_type
      ,l_parameter_value) ;

      if l_parameter_value is null
      then

        raise e_missing_process_parameter ;

      end if ;

    end loop ;  --  c_process_parameters

    --  add the assignment action ID to the variable store PL/SQL table

    store_variable('ASSIGNMENT_ACTION_ID', 'NUMBER', p_assignment_action_id) ;

    --  loop through the enabled modules for this process

    for r_module in c_modules(p_process_id)
    loop

      --  store the module's name for future reference

      store_variable('MODULE_NAME'
                    ,'TEXT'
                    ,r_module.module_name) ;

      --  check the module's type and call the appropriate procedure

      if r_module.module_type = 'PROCEDURE'
      then

        hr_utility.trace('  exec procedure: ' || r_module.package_name
                         || '.' || r_module.procedure_function_name) ;

        execute_procedure(r_module.module_id
                         ,r_module.package_name
                         ,r_module.procedure_function_name) ;

      elsif r_module.module_type = 'FUNCTION'
      then

        hr_utility.trace('  exec function: ' || r_module.package_name
                         || '.' || r_module.procedure_function_name) ;

        execute_function(r_module.module_id
                        ,r_module.package_name
                        ,r_module.procedure_function_name) ;

      elsif r_module.module_type = 'FORMULA'
      then

        hr_utility.trace('  exec formula: ' || r_module.formula_name) ;

        execute_formula(r_module.module_id
                       ,r_module.formula_name) ;

      else

        raise e_bad_module_type ;

      end if ;

    end loop ;  --  c_modules

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_bad_process
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_PROCESS') ;
      hr_utility.raise_error ;

    when e_missing_session_record
    then
      hr_utility.set_message(801, 'HR_AU_MISSING_SESSION_DATE') ;
      hr_utility.raise_error ;

    when e_missing_legislation_code
    then
      hr_utility.set_message(801, 'HR_AU_MISSING_LEGISLATION_CODE') ;
      hr_utility.raise_error ;

    when e_missing_process_parameter
    then
      hr_utility.set_message(801, 'HR_AU_MISSING_PROC_PARAMETER') ;
      hr_utility.raise_error ;

    when e_bad_module_type
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_MODULE_TYPE') ;
      hr_utility.raise_error ;

  end execute_process ;

  -----------------------------------------------------------------------------
  --  store_variable procedure
  --
  --  This is a private procedure that is used to add or update a variable
  --  in the variable PL/SQL table.
  -----------------------------------------------------------------------------

  procedure store_variable
  (p_name      in     varchar2
  ,p_data_type in     varchar2
  ,p_value     in     varchar2) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.store_variable' ;
    l_variable_notfound_flag        boolean := true ;
    l_counter                       number := 1 ;

    e_data_type_mismatch            exception ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  loop through the records in the PL/SQL table.  Only start
    --  the loop if there are some records and stop when the variable
    --  has been found or we've reached the last record.

    while v_variable_store.count > 0
      and l_variable_notfound_flag
      and l_counter <= v_variable_store.last
    loop

      --  find the element that contains the variable name we want,
      --  or the variable name is null

      if v_variable_store(l_counter).name = p_name
        or v_variable_store(l_counter).name is null
      then

        --  we've found a suitable element so make sure that there
        --  isn't a type mismatch

        if v_variable_store(l_counter).name is not null
          and v_variable_store(l_counter).data_type <> p_data_type
        then

          raise e_data_type_mismatch ;

        end if ;

        --  store the variable and set the variable not found flag

        hr_utility.trace('  ' || p_name || ' -> ' || nvl(p_value,'null')) ;
        v_variable_store(l_counter).name := p_name ;
        v_variable_store(l_counter).data_type := p_data_type ;
        v_variable_store(l_counter).value := p_value ;
        l_variable_notfound_flag := false ;

      end if ;

      l_counter := l_counter + 1 ;

    end loop ;

    --  either the variable store was empty or the variable was not already
    --  in the store

    if l_variable_notfound_flag
    then

      hr_utility.trace('  ' || p_name || ' -> ' || nvl(p_value,'null')) ;
      v_variable_store(l_counter).name := p_name ;
      v_variable_store(l_counter).data_type := p_data_type ;
      v_variable_store(l_counter).value := p_value ;

    end if ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_data_type_mismatch
    then
      hr_utility.set_message(801, 'HR_AU_DATA_TYPE_MISMATCH') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.raise_error ;

  end store_variable ;

  -----------------------------------------------------------------------------
  --  retrieve_variable procedure
  --
  --  This is a private procedure that is used to retrieve a variable's
  --  value from the variable PL/SQL table.
  -----------------------------------------------------------------------------

  procedure retrieve_variable
  (p_name      in     varchar2
  ,p_data_type in     varchar2
  ,p_value     out NOCOPY varchar2) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.retrieve_variable' ;
    l_variable_value                pay_au_module_parameters.constant_value%type := null ;
    l_variable_notfound_flag        boolean := true ;
    l_counter                       number := 1 ;

    e_data_type_mismatch            exception ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  loop through the records in the PL/SQL table.  Only start
    --  the loop if there are some records and stop when the variable
    --  has been found or we've reached the last record.

    while v_variable_store.count > 0
      and l_variable_notfound_flag
      and l_counter <= v_variable_store.last
    loop

      --  does the element contain the variable we're looking for?

      if v_variable_store(l_counter).name = p_name
      then

        --  found the element containing the variable we're looking for
        --  make sure that the data type is ok

        if v_variable_store(l_counter).data_type <> p_data_type
        then

          raise e_data_type_mismatch ;

        end if ;

        --  get the value of the variable we're looking for

        l_variable_value := v_variable_store(l_counter).value ;
        l_variable_notfound_flag := false ;

      end if ;

      l_counter := l_counter + 1 ;

    end loop ;

    --  set the output parameter

    hr_utility.trace('  ' || p_name || ' -> ' || nvl(l_variable_value,'null')) ;
    p_value := l_variable_value ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_data_type_mismatch
    then
      hr_utility.set_message(801, 'HR_AU_DATA_TYPE_MISMATCH') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.raise_error ;

  end retrieve_variable ;

  -----------------------------------------------------------------------------
  --  execute_procedure procedure
  --
  --  This is a private procedure that is used to execute a package procedure
  --  type module.
  -----------------------------------------------------------------------------

  procedure execute_procedure
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_procedure_name               in     varchar2) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.execute_procedure' ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    execute_procedure_function
    (p_module_id
    ,p_package_name
    ,p_procedure_name
    ,'PROCEDURE') ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end execute_procedure ;

  -----------------------------------------------------------------------------
  --  execute_function procedure
  --
  --  This is a private procedure that is used to execute a package function
  --  type module.
  -----------------------------------------------------------------------------

  procedure execute_function
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_function_name                in     varchar2) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.execute_procedure_function' ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    execute_procedure_function
    (p_module_id
    ,p_package_name
    ,p_function_name
    ,'FUNCTION') ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end execute_function ;

  -----------------------------------------------------------------------------
  --  execute_procedure_function procedure
  --
  --  This is a private procedure that is used to execute a package procedure
  --  or package function type module.
  -----------------------------------------------------------------------------

  procedure execute_procedure_function
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_procedure_function_name      in     varchar2
  ,p_mode                         in     varchar2) is

    l_text_out_bind_var_init        pay_au_module_parameters.constant_value%type := ' ' ;
    l_date_out_bind_var_init        date := to_date('31/12/4712', 'dd/mm/yyyy') ;
    l_num_out_bind_var_init         number := 999 ;

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.execute_procedure_function' ;
    l_parameter_store               t_parameter_store_tab ;
    l_sql_stmt                      varchar2(4000) ;
    l_cursor_id                     integer ;
    l_variable_value                pay_au_module_parameters.constant_value%type ;
    l_return_code                   integer ;
    l_number_variable_value         number ;
    l_date_variable_value           date ;
    l_function_return_found_flag    boolean := false ;
    l_no_parameters_flag            boolean := true ;
    l_first_parameter_flag          boolean := true ;
    l_module                        pay_au_module_parameters.constant_value%type ;
    l_error                         pay_au_module_parameters.constant_value%type ;

    e_bad_mode                      exception ;
    e_bad_data_type                 exception ;
    e_missing_function_return       exception ;
    e_multiple_function_return      exception ;
    e_module_error                  exception ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    if not (p_mode = 'FUNCTION' or p_mode = 'PROCEDURE')
    then

      raise e_bad_mode ;

    end if ;

    --  call get_module_parameters to populate a PL/SQL table with the
    --  data from the pay_au_module_parameters table for the module
    --  beinmg executed.  This saves on database table accesses.

    get_module_parameters(p_module_id, l_parameter_store) ;

    --  build up a string that contains a PL/SQL block.  The PL/SQL block
    --  will execute the module.  The DBMS_SQL package will be used to
    --  execute the dynamically created PL/SQL block

    if p_mode = 'PROCEDURE'
    then

      l_sql_stmt := 'begin ' || p_package_name || '.' || p_procedure_function_name ;

    else  --  p_mode = 'FUNCTION'

      l_sql_stmt := 'begin ' ;

      --  one of the parameters should have been flagged as the function
      --  return - find it and add it to the string

      for i in l_parameter_store.first..l_parameter_store.last
      loop

        if l_parameter_store(i).function_return_flag = 'Y'
        then

          if l_function_return_found_flag
          then

            --  this is the second parameter found that is marked as the
            --  function return so raise an error.

            raise e_multiple_function_return ;

          else

            --  function return found so set up string:
            --    :<function return bind value> := <package name>.<function_name>
            --  set flag to show that function return has been found.  The flag is
            --  tested to find if multiple function returns have been defined and
            --  to find if no function return has been defined.

            l_sql_stmt := l_sql_stmt || ':' || l_parameter_store(i).internal_name
                            || ' := ' || p_package_name || '.' || p_procedure_function_name ;

            l_function_return_found_flag := true ;

          end if ;

        end if ;

      end loop ;

      --  test to see if no function return was defined and raise error if
      --  necessary

      if not l_function_return_found_flag
      then

        raise e_missing_function_return ;

      end if ;

    end if ;

    --  loop through each parameter and add it to the string, each bit added
    --  to the string looks like:
    --    <parameter_name> => :<bind variable name>
    --  the parameter name is the external name and the internal name is
    --  used for the bind variable name.

    if l_parameter_store.count > 0
    then

      for i in l_parameter_store.first..l_parameter_store.last
      loop

        --  only add the parameter if it is an input or output

        if (l_parameter_store(i).input_flag = 'Y'
          or l_parameter_store(i).output_flag = 'Y')
          and l_parameter_store(i).function_return_flag = 'N'
        then

          --  if this is the first parameter then an open bracket
          --  is required, otherwise an comma is required:
          --
          --    <procedure/function name>(param1, param2, ...)
          --                             ^      ^
          --                             |      |
          --                         first      second and
          --                     parameter      subsequent parameters

          if l_first_parameter_flag
          then

            l_sql_stmt := l_sql_stmt || '(' ;
            l_first_parameter_flag := false ;
            l_no_parameters_flag := false ;

          else

            l_sql_stmt := l_sql_stmt || ', ' ;

          end if ;

          --  if a constnt value has been supplied (for an input) then
          --  pass that value otherwise set up a bind variable

          if l_parameter_store(i).constant_value is not null
            and l_parameter_store(i).input_flag = 'Y'
          then

            if l_parameter_store(i).data_type = 'NUMBER'
            then

              l_sql_stmt := l_sql_stmt || l_parameter_store(i).external_name
                              || ' => to_number(''' || l_parameter_store(i).constant_value || ''')' ;

            elsif l_parameter_store(i).data_type = 'TEXT'
            then

              l_sql_stmt := l_sql_stmt || l_parameter_store(i).external_name
                              || ' => ''' || l_parameter_store(i).constant_value || '''' ;

            elsif l_parameter_store(i).data_type = 'DATE'
            then

              l_sql_stmt := l_sql_stmt || l_parameter_store(i).external_name
                              || ' => fnd_date.cannonical_to_date(''' || l_parameter_store(i).constant_value || ''')' ;

            else

              raise e_bad_data_type ;

            end if ;

          else

            l_sql_stmt := l_sql_stmt || l_parameter_store(i).external_name
                            || ' => :' || l_parameter_store(i).internal_name ;

          end if ;

        end if ;

      end loop ;

    end if ;

    --  the no_parameters_flag gets initialised to true at declaration.
    --  It is set to false when the opening bracket is added to the
    --  string when the first parameter is added to the string.
    --  If there are no parameters then a closing bracket is not
    --  required.

    if l_no_parameters_flag
    then
      l_sql_stmt := l_sql_stmt || '; end;' ;
    else
      l_sql_stmt := l_sql_stmt || '); end;' ;
    end if ;

    hr_utility.trace('  ' || l_sql_stmt) ;

    --  open a cursor for the the dynamic pl/sql block

    l_cursor_id := dbms_sql.open_cursor ;

    --  parse the dynamic pl/sql block

    dbms_sql.parse(l_cursor_id, l_sql_stmt, 1) ;

    --  Now set values for the bind variables.  The values for in or in/out
    --  parameters should be in the PL/SQL table variable store.  There will
    --  be no values for the out parameters.  The DBMS_SQL package requires
    --  that these out parameter bind variables are initialised so the
    --  l_num_out_bind_var_init, l_text_out_bind_var_init, and
    --  l_date_out_bind_var_init variables are used for this purpose.

    if l_parameter_store.count > 0
    then

      for i in l_parameter_store.first..l_parameter_store.last
      loop

        if l_parameter_store(i).input_flag = 'Y'
          or l_parameter_store(i).output_flag = 'Y'
        then

          --  get the value to bind

          retrieve_variable(l_parameter_store(i).internal_name
                           ,l_parameter_store(i).data_type
                           ,l_variable_value) ;

          --  the values are stored as characters so we have to convert them
          --  to their real data types here before binding

          if l_parameter_store(i).data_type = 'NUMBER'
          then

            if l_parameter_store(i).output_flag = 'Y'
              and l_parameter_store(i).input_flag = 'N'
            then

              --  initialise an out number bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,l_num_out_bind_var_init) ;

            else

              --  bind an in or in/out number bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,to_number(l_variable_value)) ;

            end if ;

          elsif l_parameter_store(i).data_type = 'TEXT'
          then

            if l_parameter_store(i).output_flag = 'Y'
              and l_parameter_store(i).input_flag = 'N'
            then

              --  initialise an out text bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,l_text_out_bind_var_init) ;

            else

              --  bind an in or in/out text bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,l_variable_value) ;

            end if ;

          elsif l_parameter_store(i).data_type = 'DATE'
          then

            if l_parameter_store(i).output_flag = 'Y'
              and l_parameter_store(i).input_flag = 'N'
            then

              --  initialise an out date bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,l_date_out_bind_var_init) ;

            else

              --  bind an in or in/out date bind variable

              dbms_sql.bind_variable(l_cursor_id
                                    ,':' || l_parameter_store(i).internal_name
                                    ,fnd_date.canonical_to_date(l_variable_value)) ;

            end if ;

          else

            raise e_bad_data_type ;

          end if ;

        end if ;

      end loop ;

    end if ;

    --  execute the dynamically created PL/SQL block.  (Note that the return
    --  code has no meaning when executing PL/SQL blocks and it is ignored).

    l_return_code := dbms_sql.execute(l_cursor_id) ;

    --  now we need to get the values of the bind variables associated with
    --  output parameters.  The function return appears to be a special case,
    --  however, as long as it has been flagged as an output parameter its
    --  bind value will be retrieved here.

    if l_parameter_store.count > 0
    then

      for i in l_parameter_store.first..l_parameter_store.last
      loop

        --  only get values for output parameter bind variables

        if l_parameter_store(i).output_flag = 'Y'
        then

          --  the bind values are returned as their real data types so we have
          --  to convert them to chars so that they can be stored in the
          --  variable store PL/SQL table

          if l_parameter_store(i).data_type = 'NUMBER'
          then

            l_number_variable_value := null ;

            dbms_sql.variable_value(l_cursor_id
                                  ,':' || l_parameter_store(i).internal_name
                                  ,l_number_variable_value) ;

            l_variable_value := to_char(l_number_variable_value) ;

          elsif l_parameter_store(i).data_type = 'TEXT'
          then

            dbms_sql.variable_value(l_cursor_id
                                  ,':' || l_parameter_store(i).internal_name
                                  ,l_variable_value) ;

          elsif l_parameter_store(i).data_type = 'DATE'
          then

            l_date_variable_value := null ;
            dbms_sql.variable_value(l_cursor_id
                                  ,':' || l_parameter_store(i).internal_name
                                  ,l_date_variable_value) ;

            l_variable_value := fnd_date.date_to_canonical(l_date_variable_value) ;

          else

            raise e_bad_data_type ;

          end if ;

          --  the variable l_variable_value now holds the value of the bind
          --  variable.

          --  if the output is flagged as an error message and is not null
          --  then raise an error

          if l_parameter_store(i).error_message_flag = 'Y'
            and l_variable_value is not null
          then

            l_error := l_variable_value ;
            retrieve_variable('MODULE_NAME'
                             ,'TEXT'
                             ,l_module) ;
            raise e_module_error ;

          end if ;

          --  The variable value needs to be stored in the variable store PL/SQL
          --  table (so that it can be used as an input to subsequent modules).
          --  If the parameter is marked as a result it must also be written to
          --  the database as a result.

          store_variable
          (l_parameter_store(i).internal_name
          ,l_parameter_store(i).data_type
          ,l_variable_value) ;

          if l_parameter_store(i).result_flag = 'Y'
          then

            save_result
            (l_parameter_store(i).database_item_name
            ,l_variable_value) ;

          end if ;

        end if ;

      end loop ;

    end if ;

    --  the cursor that contains the dynamically created PL/SQL block
    --  is now finished with so release it

    dbms_sql.close_cursor(l_cursor_id) ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_module_error
    then
      hr_utility.set_message(801, 'HR_AU_MODULE_ERROR') ;
      hr_utility.set_message_token('MODULE', l_module) ;
      hr_utility.set_message_token('ERROR', l_error) ;
      hr_utility.raise_error ;

    when e_bad_data_type
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_DATA_TYPE') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.raise_error ;

    when e_bad_mode
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_MODE') ;
      hr_utility.raise_error ;

    when e_missing_function_return
    then
      hr_utility.set_message(801, 'HR_AU_MISSING_FN_RETURN') ;
      hr_utility.raise_error ;

    when e_multiple_function_return
    then
      hr_utility.set_message(801, 'HR_AU_MULTIPLE_FN_RETURNS') ;
      hr_utility.raise_error ;

  end execute_procedure_function ;

  -----------------------------------------------------------------------------
  --  execute_formula procedure
  --
  --  This is a private procedure that is used to execute a Oracle FastFormula
  --  formula type module.
  -----------------------------------------------------------------------------

  procedure execute_formula
  (p_module_id                    in     number
  ,p_formula_name                 in     varchar2) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.execute_formula' ;
    l_formula_id                    ff_formulas_f.formula_id%type ;
    l_business_group_id             ff_formulas_f.business_group_id%type ;
    l_legislation_code              ff_formulas_f.legislation_code%type ;
    l_parameter_store               t_parameter_store_tab ;
    l_inputs_counter                number := 1 ;
    l_outputs_counter               number := 1 ;
    l_ff_inputs                     ff_exec.inputs_t ;
    l_ff_outputs                    ff_exec.outputs_t ;
    l_parameter_value               pay_au_module_parameters.constant_value%type ;
    l_effective_date                pay_au_module_parameters.constant_value%type ;
    l_module                        pay_au_module_parameters.constant_value%type ;
    l_error                         pay_au_module_parameters.constant_value%type ;
    l_sqlerrm                       varchar2(255) ;

    e_bad_formula                   exception ;
    e_module_error                  exception ;

    cursor c_formula (p_formula_name varchar2
                     ,p_business_group_id number
                     ,p_legislation_code varchar2) is
      select f.formula_id
      from   ff_formulas_f f
      where  f.formula_name = p_formula_name
      and    ((f.business_group_id is null
      and      f.legislation_code is null)
      or      (f.business_group_id = p_business_group_id)
      or      (f.legislation_code = p_legislation_code)) ;

    function get_ff_output (p_name varchar2) return varchar2 is

      --  local function to loop through the FF inputs PL/SQL table
      --  looking for a output name

      l_procedure_name                varchar2(61) := 'get_ff_output' ;
      l_output_value                  pay_au_module_parameters.constant_value%type := null ;

    begin

      hr_utility.trace('  In: ' || l_procedure_name) ;

      for i in l_ff_outputs.first..l_ff_outputs.last
      loop

        if l_ff_outputs(i).name = p_name
        then

          l_output_value := l_ff_outputs(i).value ;
          exit ;  --  (from loop)

        end if ;

      end loop ;

      hr_utility.trace('  Out: ' || l_procedure_name) ;

      return l_output_value ;

    end get_ff_output ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_module_id: ' || to_char(p_module_id)) ;
    hr_utility.trace('  p_formula_name: ' || p_formula_name) ;

    --  Get the business group ID and legislation code variables and then check
    --  that the formula is valid within this business group/legislation context.

    hr_utility.set_location(l_procedure_name, 10) ;
    retrieve_variable('BUSINESS_GROUP_ID'
                     ,'NUMBER'
                     ,l_business_group_id) ;

    hr_utility.set_location(l_procedure_name, 20) ;
    retrieve_variable('LEGISLATION_CODE'
                     ,'TEXT'
                     ,l_legislation_code) ;

    hr_utility.set_location(l_procedure_name, 30) ;
    open c_formula(p_formula_name, l_business_group_id, l_legislation_code) ;
    fetch c_formula
      into l_formula_id ;
    if c_formula%notfound
    then

      close c_formula ;
      raise e_bad_formula ;

    end if ;
    close c_formula ;

    --  call get_module_parameters to populate a PL/SQL table with the
    --  data from the pay_au_module_parameters table for the module
    --  beinmg executed.  This saves on database table accesses.

    hr_utility.set_location(l_procedure_name, 40) ;
    get_module_parameters(p_module_id, l_parameter_store) ;

    --  the Oracle FastFormula execution harness requires inputs
    --  to be passed in using a PL/SQL table and outputs to be passed
    --  out using another PL/SQL table.  Set up the FastFormula inputs
    --  and outputs tables.

    hr_utility.set_location(l_procedure_name, 50) ;
    for i in l_parameter_store.first..l_parameter_store.last
    loop

      --  look for inputs or contexts

      hr_utility.set_location(l_procedure_name, 60) ;
      if l_parameter_store(i).input_flag = 'Y'
        or l_parameter_store(i).context_flag = 'Y'
      then

        --  if there is a constant value defined for the parameter
        --  use it, otherwise get the value from the variable store

        hr_utility.set_location(l_procedure_name, 70) ;
        if l_parameter_store(i).constant_value is not null
        then

          hr_utility.set_location(l_procedure_name, 80) ;
          l_parameter_value := l_parameter_store(i).constant_value ;

        else

          hr_utility.set_location(l_procedure_name, 90) ;
          retrieve_variable(l_parameter_store(i).internal_name
                           ,l_parameter_store(i).data_type
                           ,l_parameter_value) ;

        end if ;

        --  set up the FF inputs table fields

        hr_utility.set_location(l_procedure_name, 100) ;
        l_ff_inputs(l_inputs_counter).name := l_parameter_store(i).external_name ;
        l_ff_inputs(l_inputs_counter).datatype := l_parameter_store(i).data_type ;
        l_ff_inputs(l_inputs_counter).value := l_parameter_value  ;

        hr_utility.set_location(l_procedure_name, 110) ;
        if l_parameter_store(i).input_flag = 'Y'
        then

          hr_utility.set_location(l_procedure_name, 120) ;
          l_ff_inputs(l_inputs_counter).class := 'INPUT' ;

        else

          hr_utility.set_location(l_procedure_name, 130) ;
          l_ff_inputs(l_inputs_counter).class := 'CONTEXT' ;

        end if ;

        hr_utility.set_location(l_procedure_name, 140) ;
        l_inputs_counter := l_inputs_counter + 1 ;

      end if ;

      --  look for outputs

      hr_utility.set_location(l_procedure_name, 150) ;
      if l_parameter_store(i).output_flag = 'Y'
      then

        hr_utility.set_location(l_procedure_name, 160) ;
        l_ff_outputs(l_outputs_counter).name := l_parameter_store(i).external_name ;
        l_outputs_counter := l_outputs_counter + 1 ;

      end if ;

    end loop ;

    --  the FF harness has an effective date parameter so get the
    --  effective date from the variable store

    hr_utility.set_location(l_procedure_name, 170) ;
    retrieve_variable('EFFECTIVE_DATE'
                     ,'DATE'
                     ,l_effective_date) ;

    --  call the FF harness

    hr_utility.set_location(l_procedure_name, 180) ;
    per_formula_functions.run_formula
    (p_formula_name       => p_formula_name
    ,p_business_group_id  => l_business_group_id
    ,p_calculation_date   => fnd_date.canonical_to_date(l_effective_date)
    ,p_inputs             => l_ff_inputs
    ,p_outputs            => l_ff_outputs) ;

    --  check the outputs

    hr_utility.set_location(l_procedure_name, 190) ;
    for i in l_parameter_store.first..l_parameter_store.last
    loop

      hr_utility.set_location(l_procedure_name, 200) ;
      if l_parameter_store(i).output_flag = 'Y'
      then

        --  get the parameter value from the FF outputs PL/SQL table

        hr_utility.set_location(l_procedure_name, 210) ;
        l_parameter_value := get_ff_output(l_parameter_store(i).external_name) ;

        --  if the output is flagged as an error message and is not null
        --  then raise an error

        hr_utility.set_location(l_procedure_name, 220) ;
        if l_parameter_store(i).error_message_flag = 'Y'
          and l_parameter_value is not null
        then

          hr_utility.set_location(l_procedure_name, 230) ;
          l_error := l_parameter_value ;
          retrieve_variable('MODULE_NAME'
                           ,'TEXT'
                           ,l_module) ;
          raise e_module_error ;

        end if ;

        --  The output needs to be stored in the variable store PL/SQL
        --  table (so that it can be used as an input to subsequent modules).
        --  If the parameter is marked as a result it must also be written to
        --  the database.

        hr_utility.set_location(l_procedure_name, 240) ;
        store_variable
        (l_parameter_store(i).internal_name
        ,l_parameter_store(i).data_type
        ,l_parameter_value) ;

        hr_utility.set_location(l_procedure_name, 250) ;
        if l_parameter_store(i).result_flag = 'Y'
        then

          hr_utility.set_location(l_procedure_name, 260) ;
          save_result
          (l_parameter_store(i).database_item_name
          ,l_parameter_value) ;

        end if ;

      end if ;

    end loop ;

    hr_utility.set_location(l_procedure_name, 260) ;
    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_bad_formula
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_FORMULA') ;
      hr_utility.set_message_token('FORMULA', p_formula_name) ;
      hr_utility.raise_error ;
    when e_module_error
    then
      hr_utility.set_message(801, 'HR_AU_MODULE_ERROR') ;
      hr_utility.set_message_token('MODULE', l_module) ;
      hr_utility.set_message_token('ERROR', l_error) ;
      hr_utility.raise_error ;

  end execute_formula ;

  -----------------------------------------------------------------------------
  --  save_result procedure
  --
  --  This is a private procedure that is used to save results from executed
  --  modules.
  -----------------------------------------------------------------------------

  procedure save_result
  (p_database_item_name  in     varchar2
  ,p_result_value        in     varchar2) is

    type t_context_store_rec is record
    (name                           varchar2(30)
    ,value                          varchar2(255)) ;

    type t_context_store_tab
      is table of t_context_store_rec
      index by binary_integer ;

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.save_result' ;
    l_archive_item_id               ff_archive_items.archive_item_id%type ;
    l_user_entity_id                ff_user_entities.user_entity_id%type ;
    l_assignment_action_id          pay_assignment_actions.assignment_action_id%type ;
    l_legislation_code              ff_user_entities.legislation_code%type ;
    l_object_version_number         ff_archive_items.object_version_number%type ;
    l_some_warning                  boolean ;
    l_context_store                 t_context_store_tab ;
    l_variable_value                pay_au_module_parameters.constant_value%type ;
    l_counter                       integer := 1 ;

    e_bad_user_entity               exception ;

    cursor c_user_entity (p_database_item_name varchar2
                         ,p_legislation_code varchar2) is
      select ue.user_entity_id
      from   ff_database_items dbi
      ,      ff_user_entities ue
      where  dbi.user_name = p_database_item_name
      and    ue.user_entity_id = dbi.user_entity_id
      and    ue.legislation_code = p_legislation_code ;

    cursor c_contexts(p_database_item_name varchar2
                     ,p_legislation_code varchar2) is
      select c.context_name
      ,      decode(c.data_type
                   ,'N', 'NUMBER'
                   ,'T', 'TEXT'
                   ,null) data_type
      from   ff_contexts c
      ,      ff_route_context_usages rcu
      ,      ff_routes r
      ,      ff_user_entities ue
      ,      ff_database_items dbi
      where  dbi.user_name = p_database_item_name
      and    ue.user_entity_id = dbi.user_entity_id
      and    ue.legislation_code = p_legislation_code
      and    r.route_id = ue.route_id
      and    rcu.route_id = r.route_id
      and    c.context_id = rcu.context_id
      order by
             rcu.sequence_no ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_database_item_name: ' || p_database_item_name) ;
    hr_utility.trace('  p_result_value: ' || p_result_value) ;

    --  get the legislation code and assignment action ID for later use

    retrieve_variable('LEGISLATION_CODE'
                     ,'TEXT'
                     ,l_legislation_code) ;

    retrieve_variable('ASSIGNMENT_ACTION_ID'
                     ,'NUMBER'
                     ,l_variable_value) ;

    l_assignment_action_id := to_number(l_variable_value) ;

    --  get the user entity ID for the DBI

    open c_user_entity(p_database_item_name, l_legislation_code) ;
    fetch c_user_entity
      into l_user_entity_id ;
    if c_user_entity%notfound
    then
      close c_user_entity ;
      raise e_bad_user_entity ;
    end if ;
    close c_user_entity ;

    --  now set up the contexts table

    --  initialisse the table to be full of null records

    for i in 1..31
    loop

      l_context_store(i).name := null ;
      l_context_store(i).value := null ;

    end loop ;

    --  get the contexts

    for r_context in c_contexts(p_database_item_name, l_legislation_code)
    loop

      retrieve_variable(r_context.context_name
                       ,r_context.data_type
                       ,l_variable_value) ;

      l_context_store(l_counter).name := r_context.context_name ;
      l_context_store(l_counter).value := l_variable_value ;
      l_counter := l_counter + 1 ;

    end loop ;  --  c_contexts

    --  call the API

    ff_archive_api.create_archive_item
    (p_validate                     => false
    ,p_archive_item_id              => l_archive_item_id
    ,p_user_entity_id               => l_user_entity_id
    ,p_archive_value                => p_result_value
    ,p_archive_type                 => 'AAP'
    ,p_action_id                    => l_assignment_action_id
    ,p_legislation_code             => l_legislation_code
    ,p_object_version_number        => l_object_version_number
    ,p_context_name1                => l_context_store(1).name
    ,p_context1                     => l_context_store(1).value
    ,p_context_name2                => l_context_store(2).name
    ,p_context2                     => l_context_store(2).value
    ,p_context_name3                => l_context_store(3).name
    ,p_context3                     => l_context_store(3).value
    ,p_context_name4                => l_context_store(4).name
    ,p_context4                     => l_context_store(4).value
    ,p_context_name5                => l_context_store(5).name
    ,p_context5                     => l_context_store(5).value
    ,p_context_name6                => l_context_store(6).name
    ,p_context6                     => l_context_store(6).value
    ,p_context_name7                => l_context_store(7).name
    ,p_context7                     => l_context_store(7).value
    ,p_context_name8                => l_context_store(8).name
    ,p_context8                     => l_context_store(8).value
    ,p_context_name9                => l_context_store(9).name
    ,p_context9                     => l_context_store(9).value
    ,p_context_name10               => l_context_store(10).name
    ,p_context10                    => l_context_store(10).value
    ,p_context_name11               => l_context_store(11).name
    ,p_context11                    => l_context_store(11).value
    ,p_context_name12               => l_context_store(12).name
    ,p_context12                    => l_context_store(12).value
    ,p_context_name13               => l_context_store(13).name
    ,p_context13                    => l_context_store(13).value
    ,p_context_name14               => l_context_store(14).name
    ,p_context14                    => l_context_store(14).value
    ,p_context_name15               => l_context_store(15).name
    ,p_context15                    => l_context_store(15).value
    ,p_context_name16               => l_context_store(16).name
    ,p_context16                    => l_context_store(16).value
    ,p_context_name17               => l_context_store(17).name
    ,p_context17                    => l_context_store(17).value
    ,p_context_name18               => l_context_store(18).name
    ,p_context18                    => l_context_store(18).value
    ,p_context_name19               => l_context_store(19).name
    ,p_context19                    => l_context_store(19).value
    ,p_context_name20               => l_context_store(20).name
    ,p_context20                    => l_context_store(20).value
    ,p_context_name21               => l_context_store(21).name
    ,p_context21                    => l_context_store(21).value
    ,p_context_name22               => l_context_store(22).name
    ,p_context22                    => l_context_store(22).value
    ,p_context_name23               => l_context_store(23).name
    ,p_context23                    => l_context_store(23).value
    ,p_context_name24               => l_context_store(24).name
    ,p_context24                    => l_context_store(24).value
    ,p_context_name25               => l_context_store(25).name
    ,p_context25                    => l_context_store(25).value
    ,p_context_name26               => l_context_store(26).name
    ,p_context26                    => l_context_store(26).value
    ,p_context_name27               => l_context_store(27).name
    ,p_context27                    => l_context_store(27).value
    ,p_context_name28               => l_context_store(28).name
    ,p_context28                    => l_context_store(28).value
    ,p_context_name29               => l_context_store(29).name
    ,p_context29                    => l_context_store(29).value
    ,p_context_name30               => l_context_store(30).name
    ,p_context30                    => l_context_store(30).value
    ,p_context_name31               => l_context_store(31).name
    ,p_context31                    => l_context_store(31).value
    ,p_some_warning                 => l_some_warning) ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_bad_user_entity
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_USER_ENTITY') ;
      hr_utility.set_message_token('USER_ENTITY', p_database_item_name) ;
      hr_utility.raise_error ;

  end save_result ;

  -----------------------------------------------------------------------------
  --  get_module_parameters procedure
  --
  --  This is a private procedure that is used to get module parameter details
  --  and store them in a PL/SQL table.  (This saves some of the repeated
  --  accesses of the module parameters table).
  -----------------------------------------------------------------------------

  procedure get_module_parameters
  (p_module_id                    in     number
  ,p_parameters                   out NOCOPY t_parameter_store_tab) is

    l_procedure_name                varchar2(61) := 'pay_au_generic_code_caller.get_module_parameters' ;
    l_counter                       number := 1 ;

    cursor c_module_parameters(p_module_id number) is
      select mp.internal_name
      ,      mp.data_type
      ,      mp.input_flag
      ,      mp.context_flag
      ,      mp.output_flag
      ,      mp.result_flag
      ,      mp.error_message_flag
      ,      mp.function_return_flag
      ,      mp.external_name
      ,      mp.database_item_name
      ,      mp.constant_value
      from   pay_au_module_parameters mp
      where  mp.module_id = p_module_id
      and    mp.enabled_flag = 'Y' ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    for r_module_parameter in c_module_parameters(p_module_id)
    loop

      p_parameters(l_counter).internal_name := r_module_parameter.internal_name ;
      p_parameters(l_counter).data_type := r_module_parameter.data_type ;
      p_parameters(l_counter).input_flag := r_module_parameter.input_flag ;
      p_parameters(l_counter).context_flag := r_module_parameter.context_flag ;
      p_parameters(l_counter).output_flag := r_module_parameter.output_flag ;
      p_parameters(l_counter).result_flag := r_module_parameter.result_flag ;
      p_parameters(l_counter).error_message_flag := r_module_parameter.error_message_flag ;
      p_parameters(l_counter).function_return_flag := r_module_parameter.function_return_flag ;
      p_parameters(l_counter).external_name := r_module_parameter.external_name ;
      p_parameters(l_counter).database_item_name := r_module_parameter.database_item_name ;
      p_parameters(l_counter).constant_value := r_module_parameter.constant_value ;

      l_counter := l_counter + 1 ;

    end loop ;  --  c_module_parameters

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end get_module_parameters ;

end pay_au_generic_code_caller ;

/
