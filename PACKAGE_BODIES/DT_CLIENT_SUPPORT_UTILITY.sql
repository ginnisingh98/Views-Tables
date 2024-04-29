--------------------------------------------------------
--  DDL for Package Body DT_CLIENT_SUPPORT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DT_CLIENT_SUPPORT_UTILITY" As
/* $Header: dtclsutl.pkb 120.0 2005/05/27 23:10:31 appldev noship $ */
--
-- Global package name
--
g_package               varchar2(33)    := '  dt_client_support_utility.';

g_debug                 boolean;
--
-- Global package constants
--
g_true_str              constant varchar2(6) := 'TRUE';
g_false_str             constant varchar2(6) := 'FALSE';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_update_mode_list >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure get_update_mode_list
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                       out nocopy boolean
  ,p_update                           out nocopy boolean
  ,p_update_override                  out nocopy boolean
  ,p_update_change_insert             out nocopy boolean
  ) is
  --
  -- Local constants
  --
  c_out_len constant integer := 6;      -- Value must correspond to the length
                                        -- of the (OUT bind) variables such as
                                        -- l_correction.
  --
  -- Local variables
  --
  l_cursor               integer;       -- Dynamic sql cursor identifier
  l_pl_sql               varchar2(900); -- Dynamic PL/SQL package procedure
                                        -- call source code text.
  l_execute              integer;       -- Value returned by dbms_sql.execute
  l_correction           varchar2(6);   -- Char version of boolean OUT value
  l_update               varchar2(6);   -- Char version of boolean OUT value
  l_update_override      varchar2(6);   -- Char version of boolean OUT value
  l_update_change_insert varchar2(6);   -- Char version of boolean OUT value
  --
  l_proc                 varchar2(72) := g_package||'get_update_mode_list';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Define dynamic PL/SQL block with package procedure call
  --
  -- Note: The varchar2 variables are required because
  -- dbms_sql.bind_variable does not support the boolean datatype.
  -- After the package procedure call the boolean values have to be
  -- converted to varchar2, just so they can be retreved from the
  -- dynamic PL/SQL using dbms_sql.bind_variable.
  --
  l_pl_sql := 'declare '                                                  ||
              'l_correction           boolean; '                          ||
              'l_update               boolean; '                          ||
              'l_update_override      boolean; '                          ||
              'l_update_change_insert boolean; '                          ||
              'begin {Package_Name}.{Procedure_Name}'                     ||
              '(p_effective_date       =>:p_effective_date '              ||
              ',p_base_key_value       =>:p_base_key_value '              ||
              ',p_correction           =>l_correction '                   ||
              ',p_update               =>l_update '                       ||
              ',p_update_override      =>l_update_override '              ||
              ',p_update_change_insert =>l_update_change_insert '         ||
              '); '                                                       ||
              'if l_correction then '                                     ||
              ' :correction := '||''''||g_true_str||''''||'; '            ||
              'else '                                                     ||
              ' :correction := '||''''||g_false_str||''''||'; '           ||
              'end if; '                                                  ||
              'if l_update then '                                         ||
              ' :update := '||''''||g_true_str||''''||'; '                ||
              'else '                                                     ||
              ' :update := '||''''||g_false_str||''''||'; '               ||
              'end if; '                                                  ||
              'if l_update_override then '                                ||
              ' :update_override := '||''''||g_true_str||''''||'; '       ||
              'else '                                                     ||
              ' :update_override := '||''''||g_false_str||''''||'; '      ||
              'end if; '                                                  ||
              'if l_update_change_insert then '                           ||
              ' :update_change_insert := '||''''||g_true_str||''''||'; '  ||
              'else '                                                     ||
              ' :update_change_insert := '||''''||g_false_str||''''||'; ' ||
              'end if; '                                                  ||
              'end;';
  --
  -- Replace the literal (token) strings in the PL/SQL package procedure call
  --
  l_pl_sql := replace(l_pl_sql, '{Package_Name}', p_package_name);
  l_pl_sql := replace(l_pl_sql, '{Procedure_Name}', p_procedure_name);
  hr_utility.set_location(l_proc, 20);
  --
  -- Execute the Dynamic PL/SQL statement
  --
  -- Open dynamic cursor
  l_cursor := dbms_sql.open_cursor;
  hr_utility.set_location(l_proc, 30);
  --
  -- Parse dynamic PL/SQL
  dbms_sql.parse(l_cursor, l_pl_sql, dbms_sql.v7);
  hr_utility.set_location(l_proc, 40);
  --
  -- Bind dynamic package procedure IN parameter values
  dbms_sql.bind_variable(l_cursor, ':p_effective_date', p_effective_date);
  dbms_sql.bind_variable(l_cursor, ':p_base_key_value', p_base_key_value);
  hr_utility.set_location(l_proc, 50);
  --
  -- Bind dynamic PL/SQL local variable (OUT parameter) values
  dbms_sql.bind_variable(l_cursor, ':correction', l_correction, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':update', l_update, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':update_override'
                        ,l_update_override, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':update_change_insert'
                        ,l_update_change_insert, c_out_len);
  hr_utility.set_location(l_proc, 60);
  --
  -- Execute the dynamic PL/SQL block
  l_execute := dbms_sql.execute(l_cursor);
  hr_utility.set_location(l_proc, 70);
  --
  -- Obtain the OUT parameter, as varchar2 values.
  --
  dbms_sql.variable_value(l_cursor, ':correction', l_correction);
  dbms_sql.variable_value(l_cursor, ':update', l_update);
  dbms_sql.variable_value(l_cursor, ':update_override', l_update_override);
  dbms_sql.variable_value(l_cursor, ':update_change_insert'
                         ,l_update_change_insert);
  hr_utility.set_location(l_proc, 80);
  --
  -- Close Dynamic Cursor
  --
  dbms_sql.close_cursor(l_cursor);
  hr_utility.set_location(l_proc, 90);
  --
  -- Convert the varchar2 values back into boolean so
  -- they can be returned from this procedure.
  --
  if l_correction = g_true_str then
    p_correction := true;
  else
    p_correction := false;
  end if;
  --
  if l_update = g_true_str then
    p_update := true;
  else
    p_update := false;
  end if;
  --
  if l_update_override = g_true_str then
    p_update_override := true;
  else
    p_update_override := false;
  end if;
  --
  if l_update_change_insert = g_true_str then
    p_update_change_insert := true;
  else
    p_update_change_insert := false;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
exception
  --
  -- In case of an unexpected error ensure
  -- that the Dynamic Cursor is closed.
  --
  when others then
    if dbms_sql.is_open(l_cursor) then
      dbms_sql.close_cursor(l_cursor);
    end if;
    raise;
end get_update_mode_list;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_delete_mode_list >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure get_delete_mode_list
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_zap                              out nocopy boolean
  ,p_delete                           out nocopy boolean
  ,p_future_change                    out nocopy boolean
  ,p_delete_next_change               out nocopy boolean
  ) is
  --
  -- Local constants
  --
  c_out_len constant integer := 6;      -- Value must correspond to the length
                                        -- of the (OUT bind) variables such as
                                        -- l_zap.
  --
  -- Local variables
  --
  l_cursor               integer;       -- Dynamic sql cursor identifier
  l_pl_sql               varchar2(900); -- Dynamic PL/SQL package procedure
                                        -- call source code text.
  l_execute              integer;       -- Value returned by dbms_sql.execute
  l_zap                  varchar2(6);   -- Char version of boolean OUT value
  l_delete               varchar2(6);   -- Char version of boolean OUT value
  l_future_change        varchar2(6);   -- Char version of boolean OUT value
  l_delete_next_change   varchar2(6);   -- Char version of boolean OUT value
  --
  l_proc                 varchar2(72) := g_package||'get_delete_mode_list';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Define dynamic PL/SQL block with package procedure call
  --
  -- Note: The varchar2 variables are required because
  -- dbms_sql.bind_variable does not support the boolean datatype.
  -- After the package procedure call the boolean values have to be
  -- converted to varchar2, just so they can be retreved from the
  -- dynamic PL/SQL using dbms_sql.bind_variable.
  --
  l_pl_sql := 'declare '                                                ||
              'l_zap                  boolean; '                        ||
              'l_delete               boolean; '                        ||
              'l_future_change        boolean; '                        ||
              'l_delete_next_change   boolean; '                        ||
              'begin {Package_Name}.{Procedure_Name}'                   ||
              '(p_effective_date       =>:p_effective_date '            ||
              ',p_base_key_value       =>:p_base_key_value '            ||
              ',p_zap                  =>l_zap '                        ||
              ',p_delete               =>l_delete '                     ||
              ',p_future_change        =>l_future_change '              ||
              ',p_delete_next_change   =>l_delete_next_change '         ||
              '); '                                                     ||
              'if l_zap then '                                          ||
              ' :zap := '||''''||g_true_str||''''||'; '                 ||
              'else '                                                   ||
              ' :zap := '||''''||g_false_str||''''||'; '                ||
              'end if; '                                                ||
              'if l_delete then '                                       ||
              ' :delete := '||''''||g_true_str||''''||'; '              ||
              'else '                                                   ||
              ' :delete := '||''''||g_false_str||''''||'; '             ||
              'end if; '                                                ||
              'if l_future_change then '                                ||
              ' :future_change := '||''''||g_true_str||''''||'; '       ||
              'else '                                                   ||
              ' :future_change := '||''''||g_false_str||''''||'; '      ||
              'end if; '                                                ||
              'if l_delete_next_change then '                           ||
              ' :delete_next_change := '||''''||g_true_str||''''||'; '  ||
              'else '                                                   ||
              ' :delete_next_change := '||''''||g_false_str||''''||'; ' ||
              'end if; '                                                ||
              'end;';
  --
  -- Replace the literal (token) strings in the PL/SQL package procedure call
  --
  l_pl_sql := replace(l_pl_sql, '{Package_Name}', p_package_name);
  l_pl_sql := replace(l_pl_sql, '{Procedure_Name}', p_procedure_name);
  hr_utility.set_location(l_proc, 20);
  --
  -- Execute the Dynamic PL/SQL statement
  --
  -- Open dynamic cursor
  l_cursor := dbms_sql.open_cursor;
  hr_utility.set_location(l_proc, 30);
  --
  -- Parse dynamic PL/SQL
  dbms_sql.parse(l_cursor, l_pl_sql, dbms_sql.v7);
  hr_utility.set_location(l_proc, 40);
  --
  -- Bind dynamic package procedure IN parameter values
  dbms_sql.bind_variable(l_cursor, ':p_effective_date', p_effective_date);
  dbms_sql.bind_variable(l_cursor, ':p_base_key_value', p_base_key_value);
  hr_utility.set_location(l_proc, 50);
  --
  -- Bind dynamic PL/SQL local variable (OUT parameter) values
  dbms_sql.bind_variable(l_cursor, ':zap', l_zap, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':delete', l_delete, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':future_change'
                        ,l_future_change, c_out_len);
  dbms_sql.bind_variable(l_cursor, ':delete_next_change'
                        ,l_delete_next_change, c_out_len);
  hr_utility.set_location(l_proc, 60);
  --
  -- Execute the dynamic PL/SQL block
  l_execute := dbms_sql.execute(l_cursor);
  hr_utility.set_location(l_proc, 70);
  --
  -- Obtain the OUT parameter, as varchar2 values.
  --
  dbms_sql.variable_value(l_cursor, ':zap', l_zap);
  dbms_sql.variable_value(l_cursor, ':delete', l_delete);
  dbms_sql.variable_value(l_cursor, ':future_change', l_future_change);
  dbms_sql.variable_value(l_cursor, ':delete_next_change'
                         ,l_delete_next_change);
  hr_utility.set_location(l_proc, 80);
  --
  -- Close Dynamic Cursor
  --
  dbms_sql.close_cursor(l_cursor);
  hr_utility.set_location(l_proc, 90);
  --
  -- Convert the varchar2 values back into boolean so
  -- they can be returned from this procedure.
  --
  if l_zap = g_true_str then
    p_zap := true;
  else
    p_zap := false;
  end if;
  --
  if l_delete = g_true_str then
    p_delete := true;
  else
    p_delete := false;
  end if;
  --
  if l_future_change = g_true_str then
    p_future_change := true;
  else
    p_future_change := false;
  end if;
  --
  if l_delete_next_change = g_true_str then
    p_delete_next_change := true;
  else
    p_delete_next_change := false;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
exception
  --
  -- In case of an unexpected error ensure
  -- that the Dynamic Cursor is closed.
  --
  when others then
    if dbms_sql.is_open(l_cursor) then
      dbms_sql.close_cursor(l_cursor);
    end if;
    raise;
end get_delete_mode_list;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lock_record >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure lock_record
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_object_version_number         in     number
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_uid_item_name                 in     varchar2
  ,p_base_key_value                in     number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
  --
  -- Local constants
  --
  c_date_len constant integer := 11;     -- Value corresponding to the length
                                         -- of the date (OUT bind) variables.
  --
  -- Local variables
  --
  l_cursor                integer;       -- Dynamic sql cursor identifier
  l_pl_sql                varchar2(900); -- Dynamic PL/SQL package procedure
                                         -- call source code text.
  l_execute               integer;       -- Value returned by dbms_sql.execute
  l_validation_start_date date;          -- Bind value from Dynamic PL/SQL.
  l_validation_end_date   date;          -- Bind value from Dynamic PL/SQL.
  --
  l_proc                 varchar2(72) := g_package||'lock_record';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Define dynamic PL/SQL block with package procedure call
  --
  -- Note: The varchar2 variables are required because
  -- dbms_sql.bind_variable does not support the boolean datatype.
  -- After the package procedure call the boolean values have to be
  -- converted to varchar2, just so they can be retreved from the
  -- dynamic PL/SQL using dbms_sql.bind_variable.
  --
  l_pl_sql := 'begin {Package_Name}.{Procedure_Name}'                ||
              '(p_effective_date        =>:p_effective_date '        ||
              ',p_datetrack_mode        =>:p_datetrack_mode '        ||
              ',{p_uid_item_name}       =>:p_base_key_value '        ||
              ',p_object_version_number =>:p_object_version_number ' ||
              ',p_validation_start_date =>:p_validation_start_date ' ||
              ',p_validation_end_date   =>:p_validation_end_date '   ||
              '); '                                                  ||
              'end;';
  --
  -- Replace the literal (token) strings in the PL/SQL package procedure call
  --
  l_pl_sql := replace(l_pl_sql, '{Package_Name}', p_package_name);
  l_pl_sql := replace(l_pl_sql, '{Procedure_Name}', p_procedure_name);
  l_pl_sql := replace(l_pl_sql, '{p_uid_item_name}', 'p_' || p_uid_item_name);
  hr_utility.set_location(l_proc, 20);
  --
  -- Execute the Dynamic PL/SQL statement
  --
  -- Open dynamic cursor
  l_cursor := dbms_sql.open_cursor;
  hr_utility.set_location(l_proc, 30);
  --
  -- Parse dynamic PL/SQL
  dbms_sql.parse(l_cursor, l_pl_sql, dbms_sql.v7);
  hr_utility.set_location(l_proc, 40);
  --
  -- Bind dynamic package procedure IN parameter values
  dbms_sql.bind_variable(l_cursor, ':p_effective_date', p_effective_date);
  dbms_sql.bind_variable(l_cursor, ':p_datetrack_mode', p_datetrack_mode);
  dbms_sql.bind_variable(l_cursor, ':p_base_key_value', p_base_key_value);
  dbms_sql.bind_variable(l_cursor, ':p_object_version_number',
                                                 p_object_version_number);
  hr_utility.set_location(l_proc, 50);
  --
  -- Bind dynamic PL/SQL local variable (OUT parameter) values
  dbms_sql.bind_variable(l_cursor, ':p_validation_start_date',
                           l_validation_start_date);
  dbms_sql.bind_variable(l_cursor, ':p_validation_end_date',
                           l_validation_end_date);
  hr_utility.set_location(l_proc, 60);
  --
  -- Execute the dynamic PL/SQL block
  l_execute := dbms_sql.execute(l_cursor);
  hr_utility.set_location(l_proc, 70);
  --
  -- Obtain the OUT parameter, as varchar2 values.
  --
  dbms_sql.variable_value(l_cursor, ':p_validation_start_date',
                                         l_validation_start_date);
  dbms_sql.variable_value(l_cursor, ':p_validation_end_date',
                                         l_validation_end_date);
  hr_utility.set_location(l_proc, 80);
  --
  -- Close Dynamic Cursor
  --
  dbms_sql.close_cursor(l_cursor);
  hr_utility.set_location(l_proc, 90);
  --
  -- Set Out parameters
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
exception
  --
  -- In case of an unexpected error ensure
  -- that the Dynamic Cursor is closed.
  --
  when others then
    if dbms_sql.is_open(l_cursor) then
      dbms_sql.close_cursor(l_cursor);
    end if;
    raise;
end lock_record;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_update_modes_and_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure get_update_modes_and_dates
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                    out nocopy number
  ,p_update                        out nocopy number
  ,p_update_override               out nocopy number
  ,p_update_change_insert          out nocopy number
  ,p_correction_start_date         out nocopy date
  ,p_correction_end_date           out nocopy date
  ,p_update_start_date             out nocopy date
  ,p_update_end_date               out nocopy date
  ,p_override_start_date           out nocopy date
  ,p_override_end_date             out nocopy date
  ,p_upd_chg_start_date            out nocopy date
  ,p_upd_chg_end_date              out nocopy date
  ) IS
 --
  -- Local variables
  --
  l_cursor               integer;       -- Dynamic sql cursor identifier
  l_pl_sql               varchar2(2000); -- Dynamic PL/SQL package procedure
                                        -- call source code text.

  --
  l_proc                 varchar2(72) := g_package||'get_update_modes_and_dates';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Define dynamic PL/SQL block with package procedure call
  --
  --
  l_pl_sql := 'declare '                                                  ||
              ' l_correction               BOOLEAN; '                     ||
              ' l_update                   BOOLEAN; '                     ||
              ' l_update_override          BOOLEAN; '                     ||
              ' l_update_change_insert     BOOLEAN; '                     ||
              'begin '                                                    ||
              '{Package_Name}.{Procedure_Name}'                           ||
              '(p_effective_date       =>:p_effective_date '              ||
              ',p_base_key_value       =>:p_base_key_value '              ||
              ',p_correction           => l_correction '                  ||
              ',p_update               => l_update '                      ||
              ',p_update_override      => l_update_override '             ||
              ',p_update_change_insert => l_update_change_insert '        ||
              ',p_correction_start_date => :p_correction_start_date '     ||
              ',p_correction_end_date   => :p_correction_end_date '       ||
              ',p_update_start_date     => :p_update_start_date '         ||
              ',p_update_end_date       => :p_update_end_date '           ||
              ',p_override_start_date   => :p_override_start_date '       ||
              ',p_override_end_date     => :p_override_end_date '         ||
              ',p_upd_chg_start_date    => :p_upd_chg_start_date '        ||
              ',p_upd_chg_end_date      => :p_upd_chg_end_date '          ||
              '); '                                                       ||
              'hr_utility.set_location('||''''||'dyn sql'||''''||', 11);' ||
              ':p_correction :=
                       hr_api.boolean_to_constant(l_correction); '        ||
              ':p_update    := hr_api.boolean_to_constant(l_update); '    ||
              ':p_update_override
                 := hr_api.boolean_to_constant(l_update_override); '      ||
              ':p_update_change_insert
                 := hr_api.boolean_to_constant(l_update_change_insert); ' ||
              'hr_utility.set_location('||''''||'dyn sql'||''''||', 12);' ||
              'end;';
  --
  -- Replace the literal (token) strings in the PL/SQL package procedure call
  --
  l_pl_sql := replace(l_pl_sql, '{Package_Name}', p_package_name);
  l_pl_sql := replace(l_pl_sql, '{Procedure_Name}', p_procedure_name);
  hr_utility.set_location(l_proc, 20);

  EXECUTE IMMEDIATE l_pl_sql USING    p_effective_date,
                                      p_base_key_value,
                                 OUT  p_correction_start_date,
                                 OUT  p_correction_end_date,
                                 OUT  p_update_start_date,
                                 OUT  p_update_end_date,
                                 OUT  p_override_start_date,
                                 OUT  p_override_end_date,
                                 OUT  p_upd_chg_start_date,
                                 OUT  p_upd_chg_end_date,
                                 OUT  p_correction,
                                 OUT  p_update,
                                 OUT  p_update_override,
                                 OUT  p_update_change_insert;

  hr_utility.set_location('Leaving:'|| l_proc, 30);
  --
exception
  --
  -- In case of an unexpected error raise the error
  --
  when others then

     RAISE;
end get_update_modes_and_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_delete_modes_and_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure get_delete_modes_and_dates
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_zap                           out nocopy number
  ,p_delete                        out nocopy number
  ,p_future_change                 out nocopy number
  ,p_delete_next_change            out nocopy number
  ,p_zap_start_date                out nocopy date
  ,p_zap_end_date                  out nocopy date
  ,p_delete_start_date             out nocopy date
  ,p_delete_end_date               out nocopy date
  ,p_del_future_start_date         out nocopy date
  ,p_del_future_end_date           out nocopy date
  ,p_del_next_start_date           out nocopy date
  ,p_del_next_end_date             out nocopy date
  )   IS
  --
  -- Local variables
  --
  l_cursor               integer;       -- Dynamic sql cursor identifier
  l_pl_sql               varchar2(2000); -- Dynamic PL/SQL package procedure
                                        -- call source code text.
  --
  l_proc                 varchar2(72) := g_package||'get_delete_modes_and_dates';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Define dynamic PL/SQL block with package procedure call
  --
  --
  l_pl_sql := 'declare '                                                 ||
              ' l_zap                  BOOLEAN; '                        ||
              ' l_delete               BOOLEAN; '                        ||
       	      ' l_future_change        BOOLEAN; '                        ||
              ' l_delete_next_change   BOOLEAN; '                        ||
              'begin {Package_Name}.{Procedure_Name}'                    ||
              '(p_effective_date       => :p_effective_date '            ||
              ',p_base_key_value       => :p_base_key_value '            ||
              ',p_zap                  => l_zap '                        ||
              ',p_delete               => l_delete '                     ||
              ',p_future_change        => l_future_change '              ||
              ',p_delete_next_change   => l_delete_next_change '         ||
              ',p_zap_start_date       => :p_zap_start_date '            ||
              ',p_zap_end_date         => :p_zap_end_date '              ||
              ',p_del_future_start_date =>:p_del_future_start_date '     ||
              ',p_del_future_end_date   => :p_del_future_end_date '      ||
              ',p_delete_start_date    => :p_delete_start_date '         ||
              ',p_delete_end_date      => :p_delete_end_date '           ||
              ',p_del_next_start_date   => :p_del_next_start_date '      ||
              ',p_del_next_end_date     => :p_del_next_end_date '        ||
              '); '                                                      ||
              ':p_zap        := hr_api.boolean_to_constant(l_zap); '     ||
              ':p_delete     := hr_api.boolean_to_constant(l_delete); '  ||
     ':p_future_change := hr_api.boolean_to_constant(l_future_change); ' ||
     ':p_delete_next_change :=
                    hr_api.boolean_to_constant(l_delete_next_change); '  ||
              'end;';
  --
  -- Replace the literal (token) strings in the PL/SQL package procedure call
  --
  l_pl_sql := replace(l_pl_sql, '{Package_Name}', p_package_name);
  l_pl_sql := replace(l_pl_sql, '{Procedure_Name}', p_procedure_name);
  hr_utility.set_location(l_proc, 20);

  EXECUTE IMMEDIATE l_pl_sql USING    p_effective_date,
                                      p_base_key_value,
                                 OUT  p_zap_start_date,
                                 OUT  p_zap_end_date,
                                 OUT  p_del_future_start_date,
                                 OUT  p_del_future_end_date,
                                 OUT  p_delete_start_date,
                                 OUT  p_delete_end_date,
                                 OUT  p_del_next_start_date,
                                 OUT  p_del_next_end_date,
                                 OUT  p_zap,
                                 OUT  p_delete,
                                 OUT  p_future_change,
                                 OUT  p_delete_next_change;

  hr_utility.set_location('Leaving:'|| l_proc, 30);
  --
exception
  --
  -- In case of an unexpected error raise the error
  --
  when others then

     RAISE;
end get_delete_modes_and_dates;

End dt_client_support_utility;

/
